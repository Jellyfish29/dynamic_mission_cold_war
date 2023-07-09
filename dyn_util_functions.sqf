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
    params [["_now", false]];

    if !(_now) then {
        sleep 240;
    };

    {
        if (side _x != playerSide and !(_x getVariable ["dyn_dont_delete", false])) then {
            if ((_x distance2D player) > 500) then {
                deleteVehicle _x;
            } else {
                _x enableSimulation false;
            };
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
        if ((_x distance2D player) > 500 and _deadVicLimiter <= 10 and !(_x getVariable ["dyn_dont_delete", false])) then {
            deleteVehicle _x;
            _deadVicLimiter = _deadVicLimiter + 1;
        } else {
            _x enableSimulation false; 
        };
    } forEach (allDead - allDeadMen);

    sleep 1;
    {
        if ((count (crew _x)) == 0) then {
            deleteVehicle _x;
        };
    } forEach (allMissionObjects "StaticWeapon");
};


dyn_garbage_loop = {
  
   while {true} do {
        sleep 900;
        [true] spawn dyn_garbage_clear;
   };
};

dyn_clear_obstacles = {
    params ["_pos", "_radius"];
    
    {
        if (!(canMove _x) or ({alive _x} count (crew _x)) <= 0) then {
            deleteVehicle _x;
        };
    } forEach (vehicles select {(_x distance2D _pos) < _radius});

    {
         deleteVehicle _x;
    } forEach (allDead select {(_x distance2D _pos) < _radius});
    // remove Fences
    {
        deleteVehicle _x;
    } forEach ((_pos nearObjects _radius) select {["fence", typeOf _x] call BIS_fnc_inString or ["barrier", typeOf _x] call BIS_fnc_inString or ["wall", typeOf _x] call BIS_fnc_inString or ["sand", typeOf _x] call BIS_fnc_inString});
    // remove Bunkers
    {
        deleteVehicle _x;;
    } forEach ((_pos nearObjects _radius) select {["bunker", typeOf _x] call BIS_fnc_inString});
    // remove wire
    {
        deleteVehicle _x;
    } forEach ((_pos nearObjects _radius) select {["wire", typeOf _x] call BIS_fnc_inString});
    // kill trees
    {
        _x setDamage 1;
    } forEach (nearestTerrainObjects [_pos, ["TREE", "SMALL TREE", "BUSH"], _radius, false, true]);
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

dyn_pop_random = {
    params ["_array"];

    private _r = selectRandom _array;
    _array deleteAt (_array find _r);
    _r
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

dyn_is_forest = {
    params ["_pos", ["_radius", 50]];

    _trees = nearestTerrainObjects [_pos, ["Tree"], _radius, false, true];

    if (count _trees > 25) exitWith {true};

    false
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

dyn_is_field = {
    params ["_pos", ["_radius", 50]];

    _objects = nearestTerrainObjects [_pos, [], _radius, false, true];

    if (count _objects <= 0) exitWith {true};

    false
};

dyn_is_empty = {
    params ["_pos"];

    _objects = nearestTerrainObjects [_pos, [], 300, false, true];

    if (count _objects <= 0) exitWith {true};

    false
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
    params ["_center", "_radius", ["_blackList", []], ["_bridgeDistance", 25]];
    private ["_return"];

    private _roads = _center nearRoads _radius;
    private _bridges = [];
    private _validRoads = [];

    {
        _info = getRoadInfo _x;
        if (_info#8) then {
            _bridges pushBackUnique _x;
        };
    } forEach _roads;

    {
        _road = _x;
        _info = getRoadInfo _road;
        if (!((_info#0) in _blackList) and !(_info#2)) then {
            if (_bridges isEqualTo []) then {
                _validRoads pushBack _road;
            } else {
                {
                    if (((getpos _road) distance2D (getpos _x)) > _bridgeDistance) then {
                        _validRoads pushBack _road;
                    };
                } forEach _bridges;
            };
        };
    } forEach _roads;

    // _validRoads = _roads select {!(((getRoadInfo _x)#0) in _blackList) and !((getRoadInfo _x)#2) and !(_x#8)};
    _return = ([_validRoads, [], {(getpos _x) distance2D _center}, "ASCEND"] call BIS_fnc_sortBy)#0;
    if (isNil "_return") then {_return = objNull};

    _return
};

dyn_find_highest_point = {
    params ["_center", "_radius", ["_uDir", 0]];

    private _scanStart = (_center getPos [_radius / 2, _uDir]) getPos [_radius / 2, _uDir + 90];
    private _widthOffSet = 0;
    private _heigthOffset = 0;
    private _maxZ = 0;
    private _r = _center;
    for "_i" from 0 to 100 do {
        _heigthOffset = 0;
        _scanPos = _scanStart getPos [_widthOffSet, _uDir - 180];
        for "_j" from 0 to 100 do {
            _checkPos = _scanPos getPos [_heigthOffset, _uDir - 90];
            _checkPos = ATLToASL _checkPos;

            // _m = createMarker [str (random 1), _checkPos];
   //       _m setMarkerType "mil_dot";
   //       _m setMarkerSize [0.3, 0.3];

            _z = _checkPos#2;
            if (_z > _maxZ) then {
                _r = _checkPos;
                _maxZ = _z;
            };
            _heigthOffset = _heigthOffset + (_radius / 100);
        };
        _widthOffSet = _widthOffSet + (_radius / 100);
    };

    // _m = createMarker [str (random 1), _r];
    // _m setMarkerColor "colorGreen";
    // _m setMarkerType "mil_dot";
    ASLToATL _r;
    _r
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

    for "_x" from 0 to _accuracy do {
        private _xPos = _scanStart getPos [_xOffset, _scanDir + 90];

        private _ySet = [];
        private _yOffset = 0;

        for "_y" from 0 to _accuracy do {
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

            // if (_y == 0) then {
            //     _m setMarkerText ("x" + (str _x));
            // };
            // if (_x == 0) then {
            //     _m setMarkerText ("y" + (str _y));
            // }
        };

        _xOffset = _xOffset + _xOffsetStep;
        _terrain pushBack _ySet;
    };

    // _m = createMarker [str (random 4), ((_terrain#30)#70)#0];
    // _m setMarkerType "mil_marker";
    // _m setMarkerSize [0.7, 0.7];
    // _m setMarkerColor "colorYellow";


    [_forestAmount, _townAmount, _waterAmount, _terrain];
};

pl_ai_terrain_reading = {

    // Returns 3 len Array
    // 1. Clearing Array [[clearing1 Pos1, clearing1 PosN], [clearing2 Pos1, clearing2 PosN]]
    // 2. Position on Edge of Forest Array [Pos1, Posn];
    // 2. Position inside Forest Array [Pos1, Posn];

    private _terrain = +dyn_terrain;
    private _terrainGrid = _terrain#3; 

    _accuracy = 100;
    private _positionAmount = round (_accuracy * 0.5);
    private _offsetStep = round (_accuracy / _positionAmount);

    private _forestPosEdge = [];
    private _forestPosCenter = [];
    private _clearings = [];
    private _clearingTemp = [];
    private _clearingsFinal = [];

    private _yStart = [30, 40] call BIS_fnc_randomInt;
    private _ylimit = [65, 75] call BIS_fnc_randomInt;
    private _y = _yStart;
    private _forestYPos = _yStart;

    for "_xx" from 0 to _accuracy step _offsetStep do {

        if ((((_terrainGrid#_xx)#_yStart)#1) != "forest") then {
            _y = _yStart;
            while {_y < _ylimit} do {

                _checkPos = (_terrainGrid#_xx)#_y;
                if ((_checkPos#1) == "forest") exitWith {

                    // _m = createMarker [str (random 4), _checkPos#0];
                    // _m setMarkerType "mil_marker";
                    // _m setMarkerColor "colorRed";

                    _forestPosEdge pushBack (_checkPos#0);

                    _forestYPos = _y;

                    if !(_clearingTemp isEqualTo []) then {

                        {
                            if ((_x#1) == _yStart) then {
                                _x set [1, _forestYPos];
                            };
                        } forEach _clearingTemp;

                        _clearings pushback _clearingTemp;
                        _clearingTemp = [];
                    };

                };
                _y = _y + 1;
            };

            if (_y == _ylimit) then {
                // _clearingTemp pushback ((_terrainGrid#_xx)#_forestYPos);
                _clearingTemp pushback [_xx, _forestYPos];
            };

        } else {

            // _m = createMarker [str (random 4), ((_terrainGrid#_xx)#_yStart)#0];
            // _m setMarkerType "mil_marker";
            // _m setMarkerColor "colorBlue";

            _forestPosCenter pushBack (((_terrainGrid#_xx)#_yStart)#0);
            _forestYPos = _yStart;

            if !(_clearingTemp isEqualTo []) then {

                {
                    if ((_x#1) == _yStart) then {
                        _x set [1, _forestYPos];
                    };
                } forEach _clearingTemp;

                _clearings pushback _clearingTemp;
                _clearingTemp = [];
            };
        };
    };

    if !(_clearingTemp isEqualTo []) then {

        {
            if ((_x#1) == _yStart) then {
                _x set [1, _forestYPos];
            };
        } forEach _clearingTemp;
        _clearings pushback _clearingTemp;
    };

    {
        _c = _x;
        _clearingsFinal pushBack (_c apply {((_terrainGrid#(_x#0))#(_x#1))#0});
        
    } forEach _clearings;


    private _clearingID = 1;
    {
        _cc = _x;
        {
            // _m = createMarker [str (random 4), _x];
            // _m setMarkerType "mil_marker";
            // _m setMarkerColor "colorYellow";
            // _m setMarkerText (str _clearingID);
        } forEach _cc;
        _clearingID = _clearingID + 1;
    } forEach _clearingsFinal;

    [_clearingsFinal, _forestPosEdge, _forestPosCenter]
};


dyn_find_centroid_of_groups = {
    params ["_groups"];

    _groups = _groups select {(({alive _x} count (units _x)) > 0) and !isNull _x};
    private _sumX = 0;
    private _sumY = 0;
    private _len = count _groups;

    {
        // if (alive (leader _x)) then {
            _sumX = _sumX + ((getPos (leader _x))#0);
            _sumY = _sumY + ((getPos (leader _x))#1);

            // _m = createMarker [str (random 2), (getPos (leader _x))];
            // _m setMarkerType "mil_marker";
        // };

    } forEach _groups;

    [_sumX / _len, _sumY / _len, 0] 
};

dyn_find_centroid_of_points = {
    params ["_points"];

    private _sumX = 0;
    private _sumY = 0;
    private _len = count _points;

    {
        _sumX = _sumX + _X#0;
        _sumY = _sumY + _x#1;

    } forEach _points;

    [_sumX / _len, _sumY / _len, 0]
};

dyn_hide_fences = {
    params ["_pos", "_radius"];
 
    _fences = nearestTerrainObjects [_pos, ["FENCE", "WALL"], _radius, false, true];

    for "_i" from 0 to (count _fences) - 1 do {
        if (_i % 3 == 0) then {
            hideObject (_fences#_i);
        };
    };
};

// [getpos player, 0] spawn dyn_terrain_scan;

dyn_intel_markers = [];

dyn_spawn_intel_markers = {
    params ["_trg", "_pos", "_type", "_text", ["_color", ""], ["_size", 0.7], ["_alpha", 1], ["_dir", 0], ["_posRandom", true]];

    if !(isNull _trg) then { waitUntil {sleep 1; triggerActivated _trg}};

    if (_posRandom) then {
        _pos = [[[_pos, 50]], []] call BIS_fnc_randomPos;
    };
    _intelMarker = createMarker [format ["im%1", random 2], _pos];
    _intelMarker setMarkerType _type;
    _intelMarker setMarkerSize [_size, _size];
    _intelMarker setMarkerText _text;
    _intelMarker setMarkerAlpha _alpha;
    _intelMarker setMarkerDir _dir;
    if !(_color isEqualTo "") then {
        _intelMarker setMarkerColor _color;
    };

    dyn_intel_markers pushBack _intelMarker;
    _intelMarker
};


dyn_spawn_intel_markers_area = {
    params ["_trg", "_pos", ["_color", "colorOpfor"], ["_size", 1500], ["_sizeYoff", 0.66], ["_mDir", [0, 359] call BIS_fnc_randomInt], ["_shape", "ELLIPSE"], ["_brush", "BDiagonal"], ["_alpha", 1]];

    if !(isNull _trg) then { waitUntil {sleep 1; triggerActivated _trg}};

    _intelMarker = createMarker [format ["im%1", random 2], _pos];
    _intelMarker setMarkerColor _color;
    _intelMarker setMarkerShape _shape;
    _intelMarker setMarkerBrush _brush;
    _intelMarker setMarkerAlpha 0.9;
    _intelMarker setMarkerDir _mDir;
    _intelMarker setMarkerAlpha _alpha;
    _intelMarker setMarkerSize [_size, _size * _sizeYoff];

    dyn_intel_markers pushBack _intelMarker;
    _intelMarker
};

dyn_spawn_unit_intel_markers = {
    params ["_grps", "_side", "_type", ["_attack", false]];

    if (_side != playerSide) then {
        waitUntil {sleep 5; ({(groupId _x) in pl_marta_dic} count _grps) >= 2};
    };

    _attack = false;

    private _sideStr = "b";
    private _sizeStr = "c";
    private _size = 1.8;

    switch (_side) do { 
        case east : {_sideStr = "o"}; 
        case west : {_sideStr = "b"}; 
        default {_sideStr = "b"}; //n
    };

    private _unitSize = count _grps;

    if (_unitSize < 6) then {_sizeStr = "p", _size = 1.3} else {
    if (_unitSize > 25) then {_sizeStr = "b", _size = 2 }};

    _markerNameUnit = createMarker [format ["%1unit", random 1], [0,0,0]];
    _markerNameUnit setMarkerType format ["%1_%2_%3_pl", _sideStr, _sizeStr, _type];
    _markerNameUnit setMarkerSize [_size,_size];

    _centroid = [_grps] call dyn_find_centroid_of_groups;
    _markerNameUnit setMarkerPos _centroid;

    private _markerNameAttack = format ["%1Attack", random 1];
    if (_attack) then {
        _atkArrowPos = _centroid getpos [100, _centroid getDir player];

        _markerNameAttack = createMarker [_markerNameAttack, _atkArrowPos];
        _markerNameAttack setMarkerType "marker_std_atk";
        _markerNameAttack setMarkerSize [1.5, 1.5];
        _markerNameAttack setMarkerColor "colorOPFOR";
        _markerNameAttack setMarkerDir (_centroid getDir player);
    };

    while {sleep 10; (count (_grps select {(({alive _x} count (units _x)) > 0) and !isNull _x})) > 1} do {
        _centroid = [_grps] call dyn_find_centroid_of_groups;
        _markerNameUnit setMarkerPos _centroid;

        if (_attack) then {
            _markerNameAttack setMarkerPos (_centroid getpos [200, _centroid getDir player]);
            _markerNameAttack setMarkerDir (_centroid getDir player);
        };

        sleep 10;
    };

    deleteMarker _markerNameUnit;
    if (_attack) then {
        deleteMarker _markerNameAttack;
    };
};

dyn_draw_mil_symbol_fortification_line = {
    params ["_centerPos", "_width", "_dir", ["_spacing", 40]];

    // private _spacing = 40;
    private _steps = round (_width / _spacing);

    private _path = [];
    private _pos1Array = [];
    private _pos2Array = []; 

    private _startPos = _centerPos getPos [_width / 2, _dir + 90];
    for "_i" from 0 to _steps do {
        _pos1 = _startPos getPos [_spacing * _i, _dir - 90];
        _pos2 = _pos1 getPos [_spacing, _dir - 180];

        _pos1Array pushBack _pos1;
        _pos2Array pushBack _pos2;
    };

    _pos1Array deleteAt 0;

    for "_i" from 0 to count (_pos2Array) - 2 step 2 do {
        _path pushBack ((_pos2Array#_i))#0;
        _path pushBack ((_pos2Array#_i))#1;
        _path pushBack ((_pos2Array#(_i + 1)))#0;
        _path pushBack ((_pos2Array#(_i + 1)))#1;

        _path pushBack ((_pos1Array#_i))#0;
        _path pushBack ((_pos1Array#_i))#1;
        _path pushBack ((_pos1Array#(_i + 1)))#0;
        _path pushBack ((_pos1Array#(_i + 1)))#1;
    };

    _lineMarker = createMarker [str (random 3), [0,0,0]];
    _lineMarker setMarkerShape "POLYLINE";
    _lineMarker setMarkerPolyline _path;
    _lineMarker setMarkerColor "colorOPFOR";

    dyn_intel_markers pushBack _lineMarker;
};

dyn_draw_mil_symbol_objectiv = {
    params ["_objPos", "_buildings", "_name"];

    private _path = [];

    {
        _watchPos = _objPos getpos [1000, _x];
        _b = ([_buildings, [], {_x distance2D _watchPos}, "ASCEND"] call BIS_fnc_sortBy)#0;
        _path pushBack ((getPos _b)#0);
        _path pushBack ((getPos _b)#1);
        if (_x == 90) then {
            _textPos = (getPos _b) getPos [50, _x];
            _m = createMarker [str (random 3), _textPos];
            _m setMarkerType "mil_dot",
            _m setMarkerText _name;
            _m setMarkerSize [0,0];
            _m setMarkerColor "colorOPFOR";

            dyn_intel_markers pushBack _m;

        };
    } forEach [0, 90, 180, 270];

    _path pushBack (_path#0);
    _path pushBack (_path#1);

    _objMarker = createMarker [str (random 3), [0,0,0]];
    _objMarker setMarkerShape "POLYLINE";
    _objMarker setMarkerPolyline _path;
    _objMarker setMarkerColor "colorOPFOR";

    dyn_intel_markers pushBack _objMarker;
};

dyn_draw_mil_symbol_objectiv_free = {
    params ["_objPos", "_size", "_name", ["_color", "colorOpfor"]];

    private _path = [];

    {
        _pos = _objPos getpos [_size, _x + ([-45, 45] call BIS_fnc_randomInt)];

        _path pushBack (_pos#0);
        _path pushBack (_pos#1);
        if (_x == 90) then {
            _textPos = _pos getPos [50, _x];
            _m = createMarker [str (random 3), _textPos];
            _m setMarkerType "mil_dot",
            _m setMarkerText _name;
            _m setMarkerSize [0,0];
            _m setMarkerColor _color;

            dyn_intel_markers pushBack _m;

        };
    } forEach [0, 90, 180, 270];

    _path pushBack (_path#0);
    _path pushBack (_path#1);

    _objMarker = createMarker [str (random 3), [0,0,0]];
    _objMarker setMarkerShape "POLYLINE";
    _objMarker setMarkerPolyline _path;
    _objMarker setMarkerColor _color;

    dyn_intel_markers pushBack _objMarker;
};

// [getPos player, 400, "Test"] call dyn_draw_mil_symbol_objectiv_free;

dyn_draw_mil_symbol_block = {
    params ["_pos", "_dir", ["_size", 200], ["_color", "colorOpfor"]];

    private _path = [_pos#0, _pos#1];

    _pos2 = _pos getPos [_size, _dir];
    _path pushBack (_pos2#0);
    _path pushBack (_pos2#1);
    _pos3 = _pos2 getPos [_size / 2, _dir + 90];
    _path pushBack (_pos3#0);
    _path pushBack (_pos3#1);
    _pos4 = _pos2 getPos [_size / 2, _dir - 90];
    _path pushBack (_pos4#0);
    _path pushBack (_pos4#1);

    _blockMarker = createMarker [str (random 3), [0,0,0]];
    _blockMarker setMarkerShape "POLYLINE";
    _blockMarker setMarkerPolyline _path;
    _blockMarker setMarkerColor _color;

    _m = createMarker [str (random 3), _pos getPos [_size / 2, _dir]];
    _m setMarkerType "mil_dot",
    _m setMarkerText "B";
    _m setMarkerSize [0,0];
    _m setMarkerColor _color;

    dyn_intel_markers pushBack _m;
    dyn_intel_markers pushBack _blockMarker;
};

dyn_draw_mil_symbol_screen = {
    params ["_pos", "_dir", ["_type", "S"], ["_color", "colorOpfor"]];


    {
        private _path = [];
        _sidePos = _pos getpos [100, _dir + _x];
        _sidePos3 = _sidePos getpos [300, _dir + _x];
        _sidePos2 = _sidePos3 getpos [50, _dir];
        _sidePos4 = _sidePos2 getpos [300, _dir + _x];
        _sidePos5 = _sidePos3 getpos [260, _dir + _x];
        _sidePos6 = (_sidePos2 getpos [260, _dir + _x]) getPos [30, _dir];

        _path pushBack (_sidePos#0);
        _path pushBack (_sidePos#1);
        _path pushBack (_sidePos2#0);
        _path pushBack (_sidePos2#1);
        _path pushBack (_sidePos3#0);
        _path pushBack (_sidePos3#1);
        _path pushBack (_sidePos4#0);
        _path pushBack (_sidePos4#1);
        _path pushBack (_sidePos5#0);
        _path pushBack (_sidePos5#1);
        _path pushBack (_sidePos4#0);
        _path pushBack (_sidePos4#1);
        _path pushBack (_sidePos6#0);
        _path pushBack (_sidePos6#1);


        _screenMarker = createMarker [str (random 3), [0,0,0]];
        _screenMarker setMarkerShape "POLYLINE";
        _screenMarker setMarkerPolyline _path;
        _screenMarker setMarkerColor _color;

        dyn_intel_markers pushBack _screenMarker;
    } forEach [90, -90];

    _m = createMarker [str (random 3), _pos];
    _m setMarkerType "mil_dot",
    _m setMarkerText _type;
    _m setMarkerSize [0,0];
    _m setMarkerColor _color;

    dyn_intel_markers pushBack _m;
};


dyn_draw_phase_lines = {
    params ["_campaignDir", "_endPos"];

    private _centerPositionsLeft = [];
    private _centerPositionsRight = [];
    private _locations = [player] + dyn_locations;
    private _lastPos = getpos (leader artGrp_1);
    private _lastDir = -1;
    {
        _locPos = getPos _x;

        // _dir = _lastPos getdir _locPos;
        _centerPositionsLeft pushBack (_locPos getpos [2000, _campaignDir + 90]);
        _centerPositionsRight pushBack (_locPos getpos [2000, _campaignDir - 90]);

        _lastPos = _locPos;

    } forEach _locations;

    private _pathLeft = [];
    private _pathRight = [];

    private _posIdx = 1;
    for "_i" from 0 to (count _centerPositionsRight) - 2 step 1 do {
        _currentPosRight = _centerPositionsRight#_i;
        private _nextPosRight = _centerPositionsRight#(_i+1);
        private _dirRight = _currentPosRight getDir _nextPosRight;

        _distanceRight = _currentPosRight distance2d _nextPosRight;

        _midPointRight = _currentPosRight getPos [_distanceRight / 2, _dirRight];

        _pathRight pushBack (_midPointRight#0);
        _pathRight pushBack (_midPointRight#1);

        _currentPosLeft = _centerPositionsLeft#_i;
        _nextPosLeft = _centerPositionsLeft#(_i+1);
        _dirLeft = _currentPosLeft getDir _nextPosLeft;
        _distance = _currentPosLeft distance2d _nextPosLeft;

        _midPointLeft = _currentPosLeft getPos [_distance / 2, _dirLeft];

        _pathLeft pushBack (_midPointLeft#0);
        _pathLeft pushBack (_midPointLeft#1);

    };

    _lineMarkerRight = createMarker [format ["Right%1", random 3], [0,0,0]];
    _lineMarkerRight setMarkerShape "POLYLINE";
    _lineMarkerRight setMarkerPolyline _pathRight;
    _lineMarkerRight setMarkerColor "colorBLACK";

    _lineMarkerLeft = createMarker [format ["Left%1", random 3], [0,0,0]];
    _lineMarkerLeft setMarkerShape "POLYLINE";
    _lineMarkerLeft setMarkerPolyline _pathLeft;
    _lineMarkerLeft setMarkerColor "colorBLACK";
};

dyn_frontline_path = [];

dyn_phaseline_path = [];

dyn_draw_frontline = {
    params ["_objPos", "_campaignDir", ["_start", false], ["_midDistance", 0]];

    private _pathLeft = [];
    private _pathRight = [];

    _centerPositionsLeft = (_objPos getpos [1800, _campaignDir + 90]);
    _centerPositionsRight = (_objPos getpos [1800, _campaignDir - 90]);

    _xLength = 15000;

    private _spacing = 90;
    private _steps = round (_xLength / _spacing);

    private _loaLinePath = [];
    private _unitNames = +dyn_allied_unit_names;

    // main Frontline
    {
        _startPos1 = (_x#0)#0;
        _startPos2 = (_x#0)#1;
        _color = _x#1;
        {
            private _dirChangeInterval = round (_steps / ([4, 8] call BIS_fnc_randomInt));
            private _path = [];
            private _flotPath = [];
            private _pos1Array = [];
            private _pos2Array = [];
            private _startPos = _x#0;
            private _frontDirFix = _campaignDir + (_x#1);
            private _frontDir = _campaignDir + (_x#1);
            private _alliedLineInterval = round (_steps / 2);
            
            private _n = 0;
            for "_i" from 0 to _steps do {
                _pos1 = _startPos getPos [_spacing * _n, _frontDir];
                _pos2 = _pos1 getPos [_spacing, _frontDir - 90];

                _flotPos = _pos1 getPos [1500, _frontDir + (_x#1)];
                _flotPath pushBack (_flotPos#0);
                _flotPath pushBack (_flotPos#1);

                _n = _n + 1;

                if (_i % _dirChangeInterval == 0) then {

                    if (_start) then {
                        _frontDir = _frontDir + ([-10, 10] call BIS_fnc_randomInt);
                    } else {
                        if ((_x#1) < 0 ) then {
                            _frontDir = _frontDir + ([-12, 5] call BIS_fnc_randomInt);
                        } else {
                            _frontDir = _frontDir + ([-5, 12] call BIS_fnc_randomInt);
                        };
                    };

                    // if (_frontDir > _frontDirFix + 10) then {
                    //     _frontDir = _frontDirFix;
                    // };
                    // if (_frontDir < _frontDirFix - 10) then {
                    //     _frontDir = _frontDirFix;
                    // };
                    _startPos = _pos1;
                    _n = 0;

                    // _flotPos = _pos2 getPos [1500, _frontDir + (_x#1)];
                    // _flotPath pushBack (_flotPos#0);
                    // _flotPath pushBack (_flotPos#1);

                };

                // Unit diverdier Lines
                if (_i % _alliedLineInterval == 0) then {
                    // _mFEBA = createMarker [str (random 4), _pos2];
                    _mFEBA = createMarker [str (random 4), _pos2 getPos [1500, _frontDir + (_x#1)]];
                    _mFEBA setMarkerType "mil_objective";
                    _mFEBA setMarkerText "FEBA";
                    _mFEBA setMarkerSize [0.5, 0.5];
                    dyn_intel_markers pushBack _mFEBA;

                    // _mFLOT = createMarker [str (random 4), _pos2 getPos [1500, _frontDir + (_x#1)]];
                    // _mFLOT setMarkerType "mil_dot";
                    // _mFLOT setMarkerText "FLOT";
                    // _mFLOT setMarkerSize [0.7, 0.7];
                    // dyn_intel_markers pushBack _mFLOT;

                    private _dividerLinePath = [];
                    _dPos = _pos2;
                    _intervals = [[1000, 1600] call BIS_fnc_randomInt,[1000, 1600] call BIS_fnc_randomInt,[1000, 1600] call BIS_fnc_randomInt,[1000, 1600] call BIS_fnc_randomInt,[1000, 1600] call BIS_fnc_randomInt,[1000, 1600] call BIS_fnc_randomInt];
                    if (_i == 0) then {

                        _loaPos = _pos1 getPos [_midDistance + ([1000, 1100] call BIS_fnc_randomInt), _frontDir - (_x#1)];

                        _mLOA = createMarker [str (random 4), _loaPos];
                        _mLOA setMarkerType "mil_dot";
                        _mLOA setMarkerText "LOA";
                        _mLOA setMarkerSize [0.7, 0.7];

                        dyn_intel_markers pushBack _mLOA;

                        _loaLinePath pushBack (_loaPos#0);
                        _loaLinePath pushBack (_loaPos#1);

                        _dividerLinePath pushBack (_loaPos#0);
                        _dividerLinePath pushBack (_loaPos#1);
                    };

                    _dividerLinePath pushBack (_pos2#0);
                    _dividerLinePath pushBack (_pos2#1); 

                    for "_j" from 0 to 5 do {

                        _dPos = _dPos getPos [_intervals#_j, _frontDir + (_x#1) + ([-5, 5] call BIS_fnc_randomInt)];
                        _dividerLinePath pushBack (_dPos#0);
                        _dividerLinePath pushBack (_dPos#1);


                        // Btl Markers
                        if (_j == 2) then {

                            _unitName = _unitNames#0;
                            [objNull, _dPos getPos [3500, _frontDir], _unitName#0, _unitName#1, "", 1] spawn dyn_spawn_intel_markers;
                            _unitNames deleteAt 0;
                            {
                                _p1p1 = _dPos getPos [_x, _frontDir];
                                _p1p2 = _p1p1 getpos [120, _frontDir + 90];
                                _path1 = [_p1p1#0, _p1p1#1, _p1p2#0, _p1p2#1];

                                _p2p1 = _dPos getPos [_x, _frontDir];
                                _p2p2 = _p2p1 getpos [120, _frontDir + 90];
                                _path2 = [_p2p1#0, _p2p1#1, _p2p2#0, _p2p2#1];

                                _p3p1 = _dPos getPos [_x, _frontDir - 180];
                                _p3p2 = _p3p1 getpos [120, _frontDir + 90];
                                _path3 = [_p3p1#0, _p3p1#1, _p3p2#0, _p3p2#1];

                                _p4p1 = _dPos getPos [_x, _frontDir - 180];
                                _p4p2 = _p4p1 getpos [120, _frontDir + 90];
                                _path4 = [_p4p1#0, _p4p1#1, _p4p2#0, _p4p2#1];

                                _pM1 = createMarker [str (random 3), [0,0,0]];
                                _pM1 setMarkerShape "POLYLINE";
                                _pM1 setMarkerPolyline _path1;

                                _pM2 = createMarker [str (random 3), [0,0,0]];
                                _pM2 setMarkerShape "POLYLINE";
                                _pM2 setMarkerPolyline _path2;

                                _pM3 = createMarker [str (random 3), [0,0,0]];
                                _pM3 setMarkerShape "POLYLINE";
                                _pM3 setMarkerPolyline _path3;

                                _pM4 = createMarker [str (random 3), [0,0,0]];
                                _pM4 setMarkerShape "POLYLINE";
                                _pM4 setMarkerPolyline _path4;

                                dyn_intel_markers pushBack _pM1;
                                dyn_intel_markers pushBack _pM2;
                                dyn_intel_markers pushBack _pM3;
                                dyn_intel_markers pushBack _pM4;

                            } forEach [150, 240];

                        };
                    };

                    _dividerLineMarker = createMarker [str (random 3), [0,0,0]];
                    _dividerLineMarker setMarkerShape "POLYLINE";
                    _dividerLineMarker setMarkerPolyline _dividerLinePath;
                    _dividerLineMarker setMarkerColor "colorBLACK";
                    _dividerLineMarker setMarkerAlpha 0.7;

                    dyn_intel_markers pushBack _dividerLineMarker;

                };
                _pos1Array pushBack _pos1;
                _pos2Array pushBack _pos2;
            };

            _pos1Array deleteAt 0;

            // for "_i" from 0 to count (_pos2Array) - 2 step 2 do {
            //     _path pushBack ((_pos2Array#_i))#0;
            //     _path pushBack ((_pos2Array#_i))#1;
            //     _path pushBack ((_pos2Array#(_i + 1)))#0;
            //     _path pushBack ((_pos2Array#(_i + 1)))#1;

            //     _path pushBack ((_pos1Array#_i))#0;
            //     _path pushBack ((_pos1Array#_i))#1;
            //     _path pushBack ((_pos1Array#(_i + 1)))#0;
            //     _path pushBack ((_pos1Array#(_i + 1)))#1;
            // };

            for "_i" from 0 to count (_pos2Array) - 2 step 2 do {
                _path pushBack (_pos2Array#_i)#0;
                _path pushBack (_pos2Array#_i)#1;
            };

            // _lineMarker = createMarker [str (random 3), [0,0,0]];
            // _lineMarker setMarkerShape "POLYLINE";
            // _lineMarker setMarkerPolyline _path;
            // _lineMarker setMarkerColor "colorBLACK";
            // _lineMarker setMarkerAlpha 0.7;

            _flotLineMarker = createMarker [str (random 3), [0,0,0]];
            _flotLineMarker setMarkerShape "POLYLINE";
            _flotLineMarker setMarkerPolyline _flotPath;
            _flotLineMarker setMarkerColor "colorBlack";
            _flotLineMarker setMarkerAlpha 0.7;

            dyn_intel_markers pushBack _flotLineMarker;
            // dyn_intel_markers pushBack _lineMarker;
        } forEach [[_startPos1, 90], [_startPos2, -90]];
    } forEach [[[_centerPositionsLeft, _centerPositionsRight], "colorOPFOR"]];//, [[_bluLineStartLeft, _bluLineStartRight], "colorBLUFOR"]];

    _loaLineMarker = createMarker [str (random 3), [0,0,0]];
    _loaLineMarker setMarkerShape "POLYLINE";
    _loaLineMarker setMarkerPolyline _loaLinePath;
    _loaLineMarker setMarkerColor "colorBLACK";
    _loaLineMarker setMarkerAlpha 0.5;

    dyn_intel_markers pushBack _loaLineMarker;
};

// dyn_draw_frontline = {
//     params ["_locPos", "_campaigndir"];

//     // private _locPos = getPos _loc;
//     private _allLocs = +dyn_all_towns;
//     // _allLocs = _allLocs - [_loc];
//     private _steps = 20;
//     private _interval = (worldSize / _steps) / 2 ;


//     {
//         private _alliedLocs = [];
//         private _drawPathL = [];
//         private _drawPathR = []; 
//         for "_i" from 0 to _steps do {

//             _checkPos1 = _locPos getPos [_interval * _i, _campaigndir + _x];

//             if ([_checkPos1] call dyn_is_water) exitWith {_alliedLocs pushBackUnique _checkPos1};

//             // _m = createMarker [str (random 5), _checkPos1];
//             // _m setMarkerType "mil_circle";

//             private _locs = nearestLocations [_checkPos1, ["NameCity", "NameVillage", "NameCityCapital"], _interval];
//             if !(_locs isEqualTo []) then {
//                 if (!((_locs#0) in _alliedLocs) and ((getpos (_locs#0)) distance2D _locPos) > 1600) then {
//                     _unitMarker = createMarker [str (random 5), getPos (_locs#0)];
//                     _unitMarker setMarkerType (selectRandom ["b_p_inf_pl", "b_c_inf_pl", "b_p_mech_pl"]);
//                     // _unitMarker setMarkerColor "colorBLUFOR";

//                     _unitMarker = createMarker [str (random 5), (getPos (_locs#0)) getpos [800, _campaigndir - 180]];
//                     _unitMarker setMarkerType (selectRandom ["o_c_inf_pl", "o_p_mech_pl"]);
//                 };
//                 _alliedLocs pushBackUnique (getPos (_locs#0));
//             } else {
//                 if ((random 1) > 0.6 and (_checkPos1 distance2D _locPos) > 2000) then {
//                     _unitMarker = createMarker [str (random 5), _checkPos1];
//                     _unitMarker setMarkerType "b_f_s_recon_pl";
//                     _unitMarker setMarkerSize [0.5, 0.5];

//                     if ((random 1) > 0.6) then {
//                         _unitMarker = createMarker [str (random 5), _checkPos1 getpos [800, _campaigndir - 180]];
//                         _unitMarker setMarkerType (selectRandom ["o_c_inf_pl", "o_p_mech_pl"]);
//                     };
//                 };
//                 _alliedLocs pushBackUnique _checkPos1;
//             };
//         };

//         _alliedLocs deleteAt 0;

//         {
//             _dP1 = _x getPos [[300, 450] call BIS_fnc_randomInt, _campaigndir - 180];
//             _dP2 = _dp1 getPos [[150, 200] call BIS_fnc_randomInt, _campaigndir];
//             _drawPathL pushBack _dP1#0;
//             _drawPathL pushBack _dP1#1;

//             _drawPathR pushBack _dP2#0;
//             _drawPathR pushBack _dP2#1;

//         } forEach _alliedLocs;


//         if ((count _drawPathL) > 2) then { 
//             _lineLMarker = createMarker [str (random 3), [0,0,0]];
//             _lineLMarker setMarkerShape "POLYLINE";
//             _lineLMarker setMarkerPolyline _drawPathL;
//             _lineLMarker setMarkerColor "colorOPFOR";
//          };

//         // _lineLMarker = createMarker [str (random 3), [0,0,0]];
//         // _lineLMarker setMarkerShape "POLYLINE";
//         // _lineLMarker setMarkerPolyline _drawPathR;
//         // _lineLMarker setMarkerColor "colorBLUFOR";

//         _textPos = (_alliedLocs#((count _alliedLocs) - 1)) getPos [400, _campaigndir - 180];

//         _textMarker = createMarker [str (random 5), _textPos];
//         _textMarker setMarkerType "mil_marker";
//         _textMarker setMarkerText "CONTACT LINE";
//         _textMarker setMarkerSize [0,0];
//         _textMarker setMarkerColor "colorOPFOR"



//     } forEach [90, -90];
// };