
dyn_valid_cover = ["TREE", "SMALL TREE", "BUSH", "FOREST BORDER", "FOREST TRIANGLE", "FOREST SQUARE", "CHAPEL", "CROSS", "FOUNTAIN", "QUAY", "FENCE", "WALL", "HIDE", "BUSSTOP", "FOREST", "TRANSMITTER", "STACK", "RUIN", "TOURISM", "WATERTOWER", "ROCK", "ROCKS", "POWER LINES", "POWERSOLAR", "POWERWAVE", "POWERWIND", "SHIPWRECK"];
dyn_covers = [];

dyn_find_cover = {
    params ["_unit", "_watchDir", "_radius", "_moveBehind", ["_covers",  []]];

    (group _unit) setVariable ["onTask", true];
    _addCovers = nearestTerrainObjects [getPos _unit, dyn_valid_cover, _radius, true, true];
    _covers = _covers + _addCovers;
    {
        
    } forEach _addCovers;
    // _unit enableAI "AUTOCOMBAT";
    _watchPos = [1000*(sin _watchDir), 1000*(cos _watchDir), 0] vectorAdd (getPos _unit);
    _unit setUnitPos "AUTO";
    if ((count _covers) > 0) then {
        {
            if !(_x in dyn_covers) exitWith {
                dyn_covers pushBack _x;
                _unit doMove (getPos _x);
                waitUntil {sleep 0.1; (unitReady _unit) or (!alive _unit)};
                _unit setUnitPos "MIDDLE";
                sleep 1;
                if (_moveBehind) then {
                    _moveDir = _watchDir - 180;
                    _coverPos =  [2*(sin _moveDir), 2*(cos _moveDir), 0] vectorAdd (getPos _unit);
                    _unit doMove _coverPos;
                    sleep 1;
                    waitUntil {sleep 0.1; (unitReady _unit) or (!alive _unit)};
                    doStop _unit;
                    _unit doWatch _watchPos;
                _unit disableAI "PATH";
                }
                else
                {
                    doStop _unit;
                    _unit doWatch _watchPos;
                };
            };
        } forEach _covers;
        if ((unitPos _unit) == "Auto") then {
            _unit setUnitPos "DOWN";
            doStop _unit;
            _unit doWatch _watchPos;
            _unit disableAI "PATH";
        };
    }
    else
    {
        _unit setUnitPos "DOWN";
        if (_moveBehind) then {
            _checkPos = [15*(sin _watchDir), 15*(cos _watchDir), 0.25] vectorAdd (getPosASL _unit);

            // _helper = createVehicle ["Sign_Sphere25cm_F", _checkPos, [], 0, "none"];
            // _helper setObjectTexture [0,'#(argb,8,8,3)color(1,0,1,1)'];
            // _helper setposASL _checkPos;
            // _cansee = [_helper, "VIEW"] checkVisibility [(eyePos _unit), _checkPos];

            _unitPos = [0, 0, 0.25] vectorAdd (getPosASL _unit);
            _cansee = [_unit, "VIEW"] checkVisibility [_unitPos, _checkPos];
            // _unit sideChat str _cansee;
            if (_cansee < 0.6) then {
                _unit setUnitPos "MIDDLE";
            };
        };
        doStop _unit;
        _unit doWatch _watchPos;
        _unit disableAI "PATH";
    };
};


dyn_garrison_building = {
    params ["_building", "_grp", "_dir"];
    private ["_validPos", "_allPos", "_bPos", "_units", "_watchPos", "_pos", "_unit"];
    _validPos = [];
    _allPos = [];
    _bPos = [_building] call BIS_fnc_buildingPositions;
    _units = units _grp;
    {
        _allPos pushBack _x;
        _watchPos = [10*(sin _dir), 10*(cos _dir), 1.7] vectorAdd _x;
        _standingPos = [0, 0, 1.7] vectorAdd _x;
        _standingPos = ATLToASL _standingPos;
        _watchPos = ATLToASL _watchPos;

        // _helper = createVehicle ["Sign_Sphere25cm_F", _x, [], 0, "none"];
        // _helper setObjectTexture [0,'#(argb,8,8,3)color(1,0,1,1)'];
        // _helper setposASL _standingPos;

        _cansee = [objNull, "VIEW"] checkVisibility [_standingPos, _watchPos];
        if (_cansee == 1) then {
            _validPos pushBack _x;
        };
    } forEach _bPos;

    _watchPos = [500 * (sin _dir), 500 * (cos _dir), 0] vectorAdd (getPos _building);
    _validPos = [_validPos, [], {_x distance2D _watchPos}, "ASCEND"] call BIS_fnc_sortBy;
    _allPos = _allPos - _validPos;
    _allPos = [_allPos, [], {_x distance2D _watchPos}, "ASCEND"] call BIS_fnc_sortBy;

    for "_i" from 0 to (count _units) - 1 step 1 do {

        if (_i < (count _validPos)) then {
            _pos = _validPos#_i;
            _unit = _units#_i;
        }
        else
        {
            _pos = _allPos#_i;
            _unit = _units#_i;
        };
        _pos = ATLToASL _pos;
        private _unitPos = "UP";
        _checkPos = [7*(sin _dir), 7*(cos _dir), 1.7] vectorAdd _pos;
        _crouchPos = [0, 0, 0.6] vectorAdd _pos;
        if (([objNull, "VIEW"] checkVisibility [_crouchPos, _checkPos]) == 1) then {
            _unitPos = "MIDDLE";
        };
        if (([objNull, "VIEW"] checkVisibility [_pos, _checkPos]) == 1) then {
            _unitPos = "DOWN";
        };

        _pos = ASLToATL _pos;

        _unit setPos _pos;
        _unit doWatch _watchPos;
        doStop _unit;
        _unit setUnitPos _unitPos;
        _unit disableAI "PATH";
    };
};

dyn_garbage_clear = {

    sleep 240;

    {
        if (side _x != playerSide) then {
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
        if ((_x distance2D player) > 2000 and _deadVicLimiter <= 8) then {
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