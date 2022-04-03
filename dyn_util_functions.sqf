dyn_get_turn_vehicle = {
    params ["_vic", "_turnDir"];

    private _pos = [];
    private _min = 20;      // Minimum range
    private _i = 0;         // iterations

    while {_pos isEqualTo []} do {
        _pos = (_vic getPos [_min, _turnDir]) findEmptyPosition [0, 2.2, typeOf _vic];

        // water
        if !(_pos isEqualTo []) then {if (surfaceIsWater _pos) then {_pos = []};};

        // update
        _min = _min + 15;
        _i = _i + 1;
        if (_i > 6) exitWith {_pos = _vic modelToWorldVisual [0, -100, 0]};
    };
    _pos
};

dyn_garbage_clear = {

    sleep 240;

    {
        if (side _x != playerSide and !(_x getVariable ["dyn_dont_delete", false])) then {
            deleteVehicle _x;
        };
    } forEach allDeadMen; 

    sleep 1;
    {
        deleteVehicle _x;
    } forEach (allMissionObjects "WeaponHolder");

    sleep 1;
    {
        if ((count units _x) isEqualTo 0) then {
            deleteGroup _x;
        };
    } forEach allGroups;

    sleep 1;
    {
        deleteVehicle _x;
    } forEach (allMissionObjects "CraterLong");

    sleep 1;
    _deadVicLimiter = 0;
    {
        if ((_x distance2D player) > 2000 and _deadVicLimiter <= 10 and !(_x getVariable ["dyn_dont_delete", false])) then {
            deleteVehicle _x;
            _deadVicLimiter = _deadVicLimiter + 1;
        };
    } forEach (allDead - allDeadMen);

    sleep 1;
    {
        if ((count (crew _x)) == 0) then {
            deleteVehicle _x;
        };
    } forEach (allMissionObjects "StaticWeapon");
};


dyn_forget_targets = {
    params ["_units"];

    {
        _wGrp = _x;
        {
            _wGrp forgetTarget _x;
        } forEach _units;
    } forEach (allGroups select {side _x == playerSide});  
};

dyn_get_cardinal = {
    params ["_ang"];
    private ["_compass"];
    _ang = _this select 0;
    _ang = _ang + 11.25; 
    if (_ang > 360) then {_ang = _ang - 360};
    _points = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"];
    _num = floor (_ang / 22.5);
    _compass = _points select _num;
    _compass  
};

dyn_is_forest = {
    params ["_pos", ["_radius", 50]];

    _trees = nearestTerrainObjects [_pos, ["Tree"], _radius, false, true];

    if (count _trees > 25) exitWith {true};

    false
};


dyn_opfor_change_uniform = {
    params ["_comp"];
    _uniformType = dyn_uniforms_dic get _comp;
    {
        _unit = _x;
        if (vehicle _unit == _unit) then {
            _mags = getMagazineCargo uniformContainer _unit;     
            _unit addUniform _uniformType;
            _unit addMagazines [(_mags#0)#0, (_mags#1)#0];
        };
    } forEach (allUnits select {side _x isEqualTo east});   
};

dyn_opfor_change_uniform_grp = {
    params ["_grp"];
    _uniformType = dyn_uniforms_dic get (dyn_en_comp#0);
    {    
        _unit = _x;
        _mags = getMagazineCargo uniformContainer _unit;     
        _unit addUniform _uniformType;
        _unit addMagazines [(_mags#0)#0, (_mags#1)#0];
    } forEach (units _grp);
};

dyn_is_town = {
    params ["_pos"];
    _buildings = nearestTerrainObjects [_pos, ["House"], 100, false, true];
    if (count _buildings >= 3) exitWith {true};
    false
};
dyn_is_water = {
    params ["_pos"];
    private ["_isWater"];

    _isWater = {
        if (surfaceIsWater (_pos getPos [35, _x])) exitWith {true};
        false
    } forEach [0, 90, 180, 270]; 
    if (surfaceIsWater _pos) then {_isWater = true};
    _isWater 
};

dyn_hide_group_icon = {
    params ["_group"];

    _group setVariable ["pl_show_info", false];
    player hcRemoveGroup _group;
    clearGroupIcons _group;
};

dyn_convert_to_heigth_ASL = {
    params ["_pos", "_height"];

    _pos = ASLToATL _pos;
    _pos = [_pos#0, _pos#1, _height];
    _pos = ATLToASL _pos;

    _pos
};

dyn_is_indoor = {
    params ["_pos"];
    _pos = AGLToASL _pos;
    if (lineIntersects [_pos, _pos vectorAdd [0, 0, 10]]) exitWith {true};
    false
};

dyn_nearestRoad = {
    params ["_center", "_radius", ["_blackList", []]];
    private ["_return"];

    private _roads = _center nearRoads _radius;
    _validRoads = _roads select {!(((getRoadInfo _x)#0) in _blackList)};
    _return = ([_validRoads, [], {(getpos _x) distance2D _center}, "ASCEND"] call BIS_fnc_sortBy)#0;
    if (isNil "_return") then {_return = objNull};

    _return
};

dyn_terrain_scan = {
    params ["_scanPos", "_scanDir", ["_xSize", 3000], ["_ySize", 3000], ["_accuracy", 100]];
    private ["_markerColor", "_terrainType"];

    private _terrain = [];
    _scanStart = (_scanPos getPos [_xSize / 2, _scanDir]) getPos [_xSize / 2, _scanDir - 90];

    private _xOffset = 0;
    private _xOffsetStep = _xSize / _accuracy;
    private _forestAmount = 0;
    private _townAmount = 0;
    private _waterAmount = 0;

    for "_i" from 0 to _accuracy do {
        private _xPos = _scanStart getPos [_xOffset, _scanDir + 90];

        private _ySet = [];
        private _yOffset = 0;

        for "_j" from 0 to _accuracy do {
            _yPos = _xPos getPos [_yOffset, _scanDir - 180];
            _yOffsetStep = _ySize / _accuracy;
            _yOffset = _yOffset + _yOffsetStep;
            _markerColor = "colorBlack";
            _terrainType = "field";

            if ([_yPos] call dyn_is_forest) then {
                _markerColor = "colorGreen";
                _terrainType = "forest";
                _forestAmount = _forestAmount + 1;
            } else {
                if ([_yPos] call dyn_is_town) then {
                    _markerColor = "colorRed";
                    _terrainType = "town";
                    _townAmount = _townAmount + 1;
                } else {
                    if ([_yPos] call dyn_is_water) then {
                        _markerColor = "colorBlue";
                        _terrainType = "water";
                        _waterAmount = _waterAmount + 1;
                    };
                };
            };
            _ySet pushBack [_yPos, _terrainType];

            // _m = createMarker [str (random 4), _yPos];
            // _m setMarkerType "mil_dot";
            // _m setMarkerSize [0.2, 0.2];
            // _m setMarkerColor _markerColor;
        };

        _xOffset = _xOffset + _xOffsetStep;
        _terrain pushBack _ySet;
    };

    [_forestAmount, _townAmount, _waterAmount, _terrain];
};

// [getpos player, 0] spawn dyn_terrain_scan;