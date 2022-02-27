
dyn_valid_cover = ["TREE", "SMALL TREE", "BUSH", "FOREST BORDER", "FOREST TRIANGLE", "FOREST SQUARE", "CHAPEL", "CROSS", "FOUNTAIN", "QUAY", "FENCE", "WALL", "HIDE", "BUSSTOP", "FOREST", "TRANSMITTER", "STACK", "RUIN", "TOURISM", "WATERTOWER", "ROCK", "ROCKS", "POWER LINES", "POWERSOLAR", "POWERWAVE", "POWERWIND", "SHIPWRECK"];
dyn_covers = [];

dyn_find_cover = {
    params ["_unit", "_watchDir", "_radius", "_moveBehind", ["_covers",  []]];

    (group _unit) setVariable ["onTask", true];
    _addCovers = nearestTerrainObjects [getPos _unit, dyn_valid_cover, _radius, true, true];
    _covers = _covers + _addCovers;
    // _unit enableAI "AUTOCOMBAT";
    _watchPos = [1000*(sin _watchDir), 1000*(cos _watchDir), 0] vectorAdd (getPos _unit);
    _unit setUnitPos "AUTO";
    if ((count _covers) > 0) then {
        {
            if !(_x in dyn_covers) exitWith {
                dyn_covers pushBack _x;
                _unit doMove (getPosASL _x);
                waitUntil {sleep 0.1; (unitReady _unit) or (!alive _unit)};
                _unit setUnitPos "MIDDLE";
                sleep 1;
                if (_moveBehind) then {
                    _moveDir = _watchDir - 180;
                    _coverPos =  [2*(sin _moveDir), 2*(cos _moveDir), 0] vectorAdd (getPosASL _unit);
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

dyn_line_form_cover = {
    params ["_grp", "_watchDir", "_lineSpacing", "_findCover", ["_addCovers", []], ["_entropy", 0], ["_sandbags", false]];
    private ["_startPos", "_offSet", "_moveDir", "_setPos"];

    _units = units _grp;
    _startPos = getPos (leader _grp);
    _offSet = 0;
    for "_i" from 0 to ((count (units _grp))- 1) do {
        _unit = _units#_i;
        if ((_i % 2) != 0) then {
            _offSet = _offSet + _lineSpacing + ([0, round (_entropy  * 0.25)] call BIS_fnc_randomInt);
            _moveDir = _watchDir - 90 + ([0, _entropy] call BIS_fnc_randomInt);
        }
        else
        {
            _moveDir = _watchDir + 90 + ([0, _entropy] call BIS_fnc_randomInt);
        };
        _setPos = _startPos getPos [_offSet, _moveDir];
        _covers = nearestTerrainObjects [_setPos, dyn_valid_cover, 6, true, true];
        _covers = _covers + _addCovers;
        // _unit enableAI "AUTOCOMBAT";
        _watchPos = _setPos getPos [1000, _watchDir];
        if (_sandbags) then {
            _sandBag = createVehicle ["land_gm_sandbags_01_low_01", _setPos getPos [1, _watchDir], [], 0, "CAN_COLLIDE"];
            _sandBag setDir _watchDir;
        };

        if (((count _covers) > 0) and _findCover and !_sandbags) then {
            {
                if !(_x in dyn_covers) then {
                    dyn_covers pushBack _x;
                    _moveDir = _watchDir - 180;
                    _coverPos = (getPos _x) getPos [2, _moveDir];
                    _unit setPos _coverPos;
                    _unit setUnitPos "MIDDLE";
                    _unit doWatch _watchPos;
                    _unit setDir _watchDir;
                    _unit disableAI "PATH";
                }
                else
                {
                    _unit setPos _setPos;
                };
            } forEach _covers;

            if ((unitPos _unit) == "Auto") then {
                _unit setUnitPos "DOWN";
                _unit doWatch _watchPos;
                _unit disableAI "PATH";
            };
        }
        else
        {
            _unit setPos _setPos;
            _unit setUnitPos "MIDDLE";
            _unit doWatch _watchPos;
            _unit setDir _watchDir;
            _unit disableAI "PATH";
        };
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



dyn_suppressing_grps = 0;

dyn_select_atk_mode = {
    params ["_grp"];

    if (true) exitWith {};

    // waitUntil { sleep 10; ((leader  _grp) distance2D ((leader  _grp) findNearestEnemy (leader  _grp))) < 450};

    // _nearestGrp = {
    //     if ((group _x) != _grp) exitWith {group _x};
    //     grpNull
    // } forEach (nearestObjects [getPos (leader _grp), ["Man"], 400, true]);
    // if !(isNull _nearestGrp) then {
    //     if (_nearestGrp getVariable ["dyn_is_suppressing", false]) then {
    //         [_grp] spawn dyn_auto_attack;
    //     }
    //     else
    //     {
    //         [_grp] spawn dyn_auto_suppress;
    //     };
    // }
    // else
    // {
    //     [_grp] spawn dyn_auto_suppress;
    // };

};

dyn_auto_suppress = {
    params ["_grp", ["_range", 400], ["_cover", true], ["_reveal", true]];

    if (true) exitWith {};

    // _units = units _grp;
    // _grp setVariable ["dyn_is_suppressing", true];

    // waitUntil { sleep 2; ((leader  _grp) distance2D ((leader  _grp) findNearestEnemy (leader  _grp))) < _range};

    // if (_cover) then {
    //     {
    //         [_x, getDir _x, 10, true] spawn dyn_find_cover;
    //     } forEach _units;

    //     sleep 15;
    // };

    // if (_reveal) then {
    //     {
    //         (leader _grp) reveal [_x, 3];
    //     } forEach (allUnits select {side _x == west});
    // };

    // while {({alive _x} count _units) > 2} do {
    //     _target = (leader  _grp) findNearestEnemy (leader  _grp);
    //     {
    //         if !((currentCommand _x) isEqualTo "Suppress") then {
    //             _targetPos = [[[getPos _target, 30]], []] call BIS_fnc_randomPos;
    //             _targetPos = ATLToASL _targetPos;
    //             _vis = lineIntersectsSurfaces [eyePos _x, _targetPos, _x, vehicle _x, true, 1];
    //             if !(_vis isEqualTo []) then {
    //                 _targetPos = (_vis select 0) select 0;
    //             };
    //             _x doSuppressiveFire _targetPos;
    //         };
    //     } forEach _units;
    //     sleep 20;
    //     if (_grp getVariable ["dyn_is_retreating", false]) exitWith {};
    // };
    // _grp setVariable ["dyn_is_suppressing", false];
};

dyn_auto_attack = {
    params ["_grp"];

    if (true) exitWith {};

    // _units = units _grp;
    // // [_grp] call dyn_spawn_smoke;

    // // waitUntil { sleep 10; ((leader  _grp) distance2D ((leader  _grp) findNearestEnemy (leader  _grp))) < 650};

    // _grp setSpeedMode "FULL";
    // {   
    //     _X setUnitPos "UP";
    //     _X disableAI "AUTOCOMBAT";
    //     _X disableAI "SUPPRESSION";
    //     _X disableAI "COVER";
    //     _x setSuppression 0;
    //     // _X disableAI "TARGET";
    //     _x setStamina 240;
    //     // _X disableAI "AUTOTARGET";
    // } forEach (units _grp);

    // [_grp, (currentWaypoint _grp)] setWaypointType "MOVE";
    // [_grp, (currentWaypoint _grp)] setWaypointPosition [getPosASL (leader _grp), -1];
    // sleep 0.1;
    // deleteWaypoint [_grp, (currentWaypoint _grp)];
    // for "_i" from count waypoints _grp - 1 to 0 step -1 do {
    //     deleteWaypoint [_grp, _i];
    // };

    // _targetPos = getPos ((leader  _grp) findNearestEnemy (leader  _grp));
    // _wp = _grp addWaypoint [_targetPos, 20];
    // _wp setWaypointType "SAD";

    // waitUntil { sleep 2; ((leader  _grp) distance2D ((leader  _grp) findNearestEnemy (leader  _grp))) < 40 or _grp getVariable ["dyn_is_retreating", false]};

    // {   
    //     _X setUnitPos "UP";
    //     _X enableAI "AUTOCOMBAT";
    //     _X enableAI "SUPPRESSION";
    //     _X enableAI "COVER";
    // } forEach (units _grp);
    // _grp setCombatMode "YELLOW";

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
    params ["_pos"];

    _trees = nearestTerrainObjects [_pos, ["Tree"], 50, false, true];

    if (count _trees > 25) exitWith {true};

    false
};

dyn_attack_nearest_enemy = {
    params ["_trg", "_grps"];

    if !(isNull _trg) then {
        waitUntil { sleep 1, triggerActivated _trg };
    };

    {
        _grp = _x;
        {
            _x enableAI "PATH";
            _x doFollow (leader _grp);
            _x setUnitPos "Auto";
            _x disableAI "AUTOCOMBAT"
        } forEach (units _grp);

        _grp setSpeedMode "Full";
        _grp setBehaviour "AWARE";

        [_grp] spawn {
            params ["_grp"];

            while {({alive _x} count (units _grp)) > 0} do {

                _units = allUnits+vehicles select {side _x == playerSide};
                _units = [_units, [], {_x distance2D (leader _grp)}, "ASCEND"] call BIS_fnc_sortBy;
                _atkPos = getPos (_units#0);

                [_grp, (currentWaypoint _grp)] setWaypointType "MOVE";
                [_grp, (currentWaypoint _grp)] setWaypointPosition [getPosASL (leader _grp), -1];
                sleep 0.1;
                deleteWaypoint [_grp, (currentWaypoint _grp)];
                for "_i" from count waypoints _grp - 1 to 0 step -1 do {
                    deleteWaypoint [_grp, _i];
                };

                _wp = _grp addWaypoint [_atkPos, 20];
                _wp setWaypointType "SAD";

                sleep 60;
            };
        };
    } forEach _grps;
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

    _buildings = nearestObjects [_pos, ["house"], 80];

    if (count _buildings > 1) exitWith {true};

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