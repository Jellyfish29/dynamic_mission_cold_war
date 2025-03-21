
dyn_valid_cover = ["TREE", "SMALL TREE", "BUSH", "FOREST BORDER", "FOREST TRIANGLE", "FOREST SQUARE", "CHAPEL", "CROSS", "FOUNTAIN", "QUAY", "FENCE", "WALL", "HIDE", "BUSSTOP", "FOREST", "TRANSMITTER", "STACK", "RUIN", "TOURISM", "WATERTOWER", "ROCK", "ROCKS", "POWER LINES", "POWERSOLAR", "POWERWAVE", "POWERWIND", "SHIPWRECK"];
dyn_covers = [];

dyn_find_cover = {
    params ["_unit", "_watchDir", "_radius", "_moveBehind", ["_covers",  []]];

    (group _unit) setVariable ["dyn_in_convoy", true];
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
    params ["_grp", "_watchDir", "_lineSpacing", "_findCover", ["_addCovers", []], ["_entropy", 0], ["_sandbags", false], ["_startPos", []]];
    private ["_startPos", "_offSet", "_moveDir", "_setPos"];

    _units = units _grp;
    if (_startPos isEqualTo []) then {_startPos = getPos (leader _grp)};
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

    [_grp] call dyn_arty_dmg_reduction;
};

dyn_convoy_speed = 35;

dyn_convoy = {
    params ["_groups", "_dest"];

    private _r2 = [_dest, 100,[]] call BIS_fnc_nearestRoad;

    {
        // [_x] spawn {
        //     (_this#0) spawn pl_reset;
        //     sleep 0.5;
        //     (_this#0) spawn pl_reset;
        // };
        _r1 = [getPos (vehicle (leader _x)) , 50,[]] call BIS_fnc_nearestRoad;
        if (isNull _r1) then {
            _groups deleteAt (_groups find _x)
        } else {
            _path = [_r1, _r2] call dyn_convoy_parth_find;
            _x setVariable ["dyn_convoy_path", _path];
        };
    } forEach _groups;

    _groups = ([_groups, [], {count (_x getVariable "dyn_convoy_path")}, "ASCEND"] call BIS_fnc_sortBy);

    // sleep 1;
    _convoyLeaderGroup = _groups#0;
    _convoyLeader = vehicle (leader _convoyLeaderGroup);
    _groups = ([_groups, [], {_convoyLeader distance2d (leader _x)}, "ASCEND"] call BIS_fnc_sortBy);

    if ((_convoyLeaderGroup getVariable ["dyn_convoy_path", []]) isEqualTo []) exitWith {
        {
            _x addWaypoint [_dest, 20];
            _x setBehaviour "SAFE";
        } forEach _groups;
    };

    private _bridges = [];
    private _destroyedBridges = [];

    {
        _info = getRoadInfo _x;
        if (_info#8) then {
            if ((getDammage _x) < 1) then {
                _bridges pushBackUnique _x;
            } else {
                _destroyedBridges pushBackUnique _x;
            };
        };
    } forEach (_convoyLeaderGroup getVariable "dyn_convoy_path");

    private _ppMarkers = [];
    private _passigPoints = [[0,0,0]];
    _noPPn = 0;
    for "_p" from 0 to count (_convoyLeaderGroup getVariable "dyn_convoy_path") - 1 do {
        private _r = (_convoyLeaderGroup getVariable "dyn_convoy_path")#_p;

        private _nearBridge = false;
        if !(_bridges isEqualTo []) then {
            _nearBridge = {
                if ((_x distance2D _r) < 50) exitWith {true};
                false
            } forEach _bridges;
        };

        if !(_nearBridge) then {
            if (count (roadsConnectedTo _r) > 2) then {
                _valid = {
                    if (_x distance2D _r < 50) exitWith {false};
                    true
                } forEach _passigPoints;
                if (_valid) then {
                    _passigPoints pushBackUnique (getPosATL _r);
                    _noPPn = 0;
                };
            } else {
                if (_p > 0) then {
                    if (((getRoadInfo _r)#0) != (getRoadInfo ((_convoyLeaderGroup getVariable "dyn_convoy_path")#(_p - 1)))#0) then {
                        _valid = {
                            if (_x distance2D _r < 50) exitWith {false};
                            true
                        } forEach _passigPoints;
                        if (_valid) then {
                            _passigPoints pushBackUnique (getPosATL _r);
                            _noPPn = 0;
                        };
                    } else {
                        if (_p > 1 and _p < (count (_convoyLeaderGroup getVariable "dyn_convoy_path") - 2)) then {
                            _dir1 = ((_convoyLeaderGroup getVariable "dyn_convoy_path")#(_p - 1)) getDir _r;
                            _dir2 = _r getDir ((_convoyLeaderGroup getVariable "dyn_convoy_path")#(_p + 1));
                            _dirs = [_dir1, _dir2];
                            _dirs sort false;
                            if ((_dirs#0) - (_dirs#1) > 50) then {
                                _valid = {
                                    if (_x distance2D _r < 80) exitWith {false};
                                    true
                                } forEach _passigPoints;
                                if (_valid) then {
                                    _passigPoints pushBackUnique (getPosATL _r);
                                    _noPPn = 0;
                                };
                            } else {
                                _noPPn = _noPPn + 1;
                                if (_noPPn > 20) then {
                                    _noPPn = 0;
                                    _passigPoints pushBackUnique (getPosATL _r);
                                };
                            };
                        };
                    };
                };
            };
        };
    };
    _passigPoints deleteAt 0;
    _passigPoints pushback getposATL _r2;

    for "_i" from 0 to (count _groups) - 1 do {
        // doStop (vehicle (leader _x));

        private _group = _groups#_i;
        private _vic = vehicle (leader _group);
        _vic limitSpeed dyn_convoy_speed;
        _group setVariable ["dyn_in_convoy", true];
        
        // _vic setConvoySeparation 5;
        // _vic forceFollowRoad true;
        _group setVariable ["dyn_pp_idx", 0];

        {
            _x disableAI "AUTOCOMBAT";
        } forEach (units _group);
        _group setBehaviourStrong "CARELESS";
        _vic doMove (_passigPoints#0);
        _vic setDestination [(_passigPoints#0),"VEHICLE PLANNED" , true];

        // _vic setDriveOnPath (_group getVariable "dyn_convoy_path");

        if (_vic != _convoyLeader) then {

            // player hcRemoveGroup _group;

            [_group ,_vic, _convoyLeader, _groups, _i, _convoyLeaderGroup, _r2, _passigPoints] spawn {
                params ["_group" , "_vic", "_convoyLeader", "_groups", "_i", "_convoyLeaderGroup", "_r2", "_passigPoints"];
                private ["_ppidx"];

                // _vic setDriveOnPath (_group getVariable "dyn_convoy_path");

                sleep 2;
                _ppidx = 0;
                private _startReset = false;
                private _forward = vehicle (leader (_groups#(_i - 1)));
                while {(_convoyLeaderGroup getVariable ["dyn_in_convoy", false]) and ((_groups#(_i - 1)) getVariable ["dyn_in_convoy", true])} do {

                    if (!alive _vic or ({alive _x and (lifeState _x) != "INCAPACITATED"} count (units _group)) <= 0 or count (crew _vic) <= 0) exitWith {};
                    if (!(alive _convoyLeader) or !(alive _forward)) exitWith {};
                    if !(_group getVariable ["dyn_in_convoy", false]) exitWith {};

                    _ppidx = _group getVariable "dyn_pp_idx";
                    if (_vic distance2D (_passigPoints#_ppidx) < 35) then {
                        _ppidx = _ppidx + 1;
                        _group setVariable ["dyn_pp_idx", _ppidx];
                        _vic doMove (_passigPoints#_ppidx);
                        _vic setDestination [(_passigPoints#_ppidx),"VEHICLE PLANNED" , true];
                    };

                    private _convoyLeaderSpeedStr = vehicle (leader (_convoyLeaderGroup)) getVariable ["pl_speed_limit", "50"];
                    private _convoyLeaderSpeed = dyn_convoy_speed;
                    if ([getPOs _vic] call pl_is_city or [getPOs _vic] call pl_is_forest) then {
                        _convoyLeaderSpeed = dyn_convoy_speed / 2 + 5;
                    };
                    _vic forceSpeed -1;
                    _vic limitSpeed _convoyLeaderSpeed;
                    _distance = _vic distance2D _forward;
                    if (_distance > 60) then {
                        _vic limitSpeed (_convoyLeaderSpeed + 5 + (_distance - 60));
                    };
                    if (_distance < 60) then {
                        _vic limitSpeed _convoyLeaderSpeed;
                    };
                    if (_distance < 40) then {
                        _vic limitSpeed (_convoyLeaderSpeed * 0.5);
                    };
                    if (_distance < 20) then {
                        _vic forceSpeed 0;
                        _vic limitSpeed 0;
                    };
                    if (_distance > 40 and (speed _vic) < 8) then {
                        _vic limitSpeed 1000;
                    };
                    if ((speed _vic) <= 5) then {
                        [getPos _vic, 20] call dyn_clear_obstacles;
                        _time = time + 10;
                        if !(_startReset) then {
                            _time = time + 5;
                            _startReset = true;
                        };
                        waitUntil {sleep 0.5; speed _vic > 5 or time > _time or !(_group getVariable ["dyn_in_convoy", true])};
                        if (((speed _vic) <= 3) and (_group getVariable ["dyn_in_convoy", true]) and (speed _forward) >= 5 and alive _vic) then {
                            doStop _vic;
                            sleep 0.3;
                            _group setBehaviour "CARELESS";
                            // _vic setVariable ["pl_phasing", true];
                            _r0 = [getpos _vic, 100,[]] call BIS_fnc_nearestRoad;
                            _r1 = ([roadsConnectedTo _r0, [], {(_passigPoints#_ppidx) distance2d _x}, "ASCEND"] call BIS_fnc_sortBy)#0;
                            _vic setVehiclePosition [getPos _r1, [], 0, "NONE"];
                            _vic setDir  (_r0 getDir _r1);
                            sleep 0.1;
                            _vic limitSpeed dyn_convoy_speed;
                            _vic doMove (_passigPoints#_ppidx);
                            _vic setDestination [(_passigPoints#_ppidx),"VEHICLE PLANNED" , true];
                        }; 
                    };
                    sleep 1;
                };
                _vic doMove getPos _vic;
                _group setVariable ["dyn_in_convoy", false];
                {
                    _x enableAI "AUTOCOMBAT";
                } forEach (units _group);
                _group setBehaviour "AWARE";
            };
        } else {
            [_group ,_vic, _convoyLeader, _groups, _i, _convoyLeaderGroup, _r2, _passigPoints] spawn {
                params ["_group" , "_vic", "_convoyLeader", "_groups", "_i", "_convoyLeaderGroup", "_r2", "_passigPoints"];
                private ["_ppidx"];

                sleep 2;

                private _dest = getPos ((_convoyLeaderGroup getVariable "dyn_convoy_path")#((count (_convoyLeaderGroup getVariable "dyn_convoy_path")) - 1));

                while {(_convoyLeaderGroup getVariable ["dyn_in_convoy", false]) and (vehicle (leader _convoyLeaderGroup)) distance2D _dest > 40} do {

                    if (!alive _vic or count (crew _vic) <= 0) exitWith {};

                    private _convoyLeaderSpeedStr = vehicle (leader (_convoyLeaderGroup)) getVariable ["pl_speed_limit", "50"];
                    private _convoyLeaderSpeed = dyn_convoy_speed;
                    if ([getPOs _vic] call pl_is_city or [getPOs _vic] call pl_is_forest) then {
                        _convoyLeaderSpeed = dyn_convoy_speed / 2 + 5;
                    };
                    _vic forceSpeed -1;
                    _vic limitSpeed _convoyLeaderSpeed;

                    _ppidx = _group getVariable "dyn_pp_idx";
                    if (_vic distance2D (_passigPoints#_ppidx) < 35) then {
                        _ppidx = _ppidx + 1;
                        _convoyLeaderGroup setVariable ["dyn_pp_idx", _ppidx];
                        _vic doMove (_passigPoints#_ppidx);
                        _vic setDestination [(_passigPoints#_ppidx),"VEHICLE PLANNED" , true];
                    };

                    if ((speed _vic) <= 5) then {
                        [getPos _vic, 20] call dyn_clear_obstacles;
                        _time = time + 10;
                        waitUntil {sleep 0.5; speed _vic > 5 or time > _time or !(_group getVariable ["dyn_in_convoy", true])};
                        if ((speed _vic) <= 3 and (_group getVariable ["dyn_in_convoy", true]) and alive _vic) then {
                            // [_group] call pl_reset;
                            [getPos _vic, 20] call pl_clear_obstacles;
                            doStop _vic;
                            sleep 0.3;
                            _group setBehaviourStrong "SAFE";
                            _r0 = [getpos _vic, 100,[]] call BIS_fnc_nearestRoad;
                            _r1 = ([roadsConnectedTo _r0, [], {(_passigPoints#_ppidx) distance2d _x}, "ASCEND"] call BIS_fnc_sortBy)#0;
                            _vic setVehiclePosition [getPos _r1, [], 0, "NONE"];
                            _vic setDir  (_r0 getDir _r1);
                            sleep 0.1;
                            _vic limitSpeed dyn_convoy_speed;
                            _vic doMove (_passigPoints#_ppidx);
                            _vic setDestination [(_passigPoints#_ppidx),"VEHICLE PLANNED" , true];

                        }; 
                    };
                    sleep 1;
                };
                _vic doMove getPos _vic;
                _convoyLeaderGroup setVariable ["dyn_in_convoy", false];
                {
                    _x enableAI "AUTOCOMBAT";
                } forEach (units _group);
                _group setBehaviour "AWARE"
            };
        };
        _time = time + 1.5;
        waituntil {(time >= _time and speed _vic > 13) or !((_convoyLeaderGroup) getVariable ["dyn_in_convoy", true])};
    };
};

dyn_convoy_parth_find = {
    params ["_start", "_goal"];

    if (isNull _start or isNull _goal) exitWith {[]};

    private _dummyGroup = createGroup [sideLogic, true];
    private _closedSet = [];
    private _openSet = [_start];
    private _current = _start;
    private _nodeCount = 0;
    private _allRoads = [];
    private _n = 0;
    private _returnPath = [];
    private _time = time + 4;
    while {!(_openSet isEqualTo []) and time < _time} do {
        private _closest = objNull;
        {
            if (_goal distance _x < _goal distance _closest) then {
                _closest = _x;
            };
            nil
        } count _openSet;
        _current = _closest;
        _nodeCount = _nodeCount + 1;
        if (_current == _goal) exitWith {
            private _parent = _dummyGroup getVariable ("NF_neighborParent_" + str _current);
            while {!(isNil "_parent")} do {
                _allRoads pushBack _parent;

                _returnPath pushback getPos _parent;
                _allRoads pushBackUnique _parent;
                _parent = _dummyGroup getVariable ("NF_neighborParent_" + str _parent);
                if (dyn_debug) then {
                    // private _marker = createMarker [str (random 5), getPos _parent];
                    // _marker setMarkerShape "ICON";
                    // _marker setMarkerColor "colorBLUFOR";
                    // _marker setMarkerType "MIL_DOT";
                    // _marker setMarkerSize [0.3, 0.3];
                    // dyn_convoy_path_marker pushBack _marker;
                };
            };
        };
        _openSet = _openSet - [_current];
        _closedSet pushBack _current;
        private _neighbors = (getPos _current) nearRoads 20; // This includes current
        _neighbors append (roadsConnectedTo [_current, true]);
        {
            if (!(_x in _closedSet)) then {
                private _currentG = _dummyGroup getVariable ["NF_neighborG_" + str _current, 0];
                private _gScore = _currentG + 1;
                private _gScoreIsBest = false;
                if (!(_x in _openSet)) then {
                    _gScoreIsBest = true;
                    _openSet pushBack _x;
                } else {
                    private _neighborG = _dummyGroup getVariable ("NF_neighborG_" + str _x);
                    if (isNil "_neighborG") exitWith {};
                    _gScoreIsBest = _gScore < _neighborG;
                };
                if (isNil "_gScoreIsBest") exitWith {};
                if (_gScoreIsBest) then {
                    _dummyGroup setVariable ["NF_neighborParent_" + str _x, _current];
                    _dummyGroup setVariable ["NF_neighborG_" + str _x, _gScore];
                };
            };
        } forEach _neighbors;
    };
    if (time > _time) exitWith {[]};
    reverse _allRoads;
    // _returnPath deleteRange [0, 3];
    _allRoads
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

dyn_opfor_reset = {
    params ["_grp"];

    _grp setvariable ["pl_opf_in_pos", false];
    {
        _unit = _x;
        // if ((currentCommand _unit) isEqualTo "SUPPORT") then {
        //     [_unit] spawn pl_hard_reset;
        // };
        if !(_grp getVariable ["pl_on_hold", false]) then {_unit enableAI "PATH"};
        _unit enableAI "AUTOCOMBAT";
        _unit enableAI "AUTOTARGET";
        _unit enableAI "TARGET";
        _unit enableAI "SUPPRESSION";
        _unit enableAI "COVER";
        _unit enableAI "ANIM";
        _unit enableAI "FSM";
        _unit enableAI "AIMINGERROR";
        _unit enableAI "WEAPONAIM";
        _unit setUnitPos "AUTO";
        _unit setUnitTrait ["camouflageCoef", 1, true];
        _unit setVariable ["pl_damage_reduction", false];
        // sleep 0.5;
        _unit doWatch objNull;
        _unit allowDamage true;
        if (vehicle _unit == _unit) then {
            _unit doFollow (leader _grp);
        };
    } forEach (units _grp);

    _leader = leader _grp;
    (units _grp) joinSilent _grp;
    _grp selectLeader _leader;

    [_grp, (currentWaypoint _grp)] setWaypointType "MOVE";
    [_grp, (currentWaypoint _grp)] setWaypointPosition [getPosASL (leader _grp), -1];
    sleep 0.1;
    deleteWaypoint [_grp, (currentWaypoint _grp)];
    for "_i" from count waypoints _grp - 1 to 0 step -1 do {
        deleteWaypoint [_grp, _i];
    };
};

dyn_opfor_join_grp = {
    params ["_grp", "_side"];

    private _targets = (((getPos (leader _grp)) nearEntities [["Man"], 300]) select {side _x == _side and ((group _x) getVariable ["pl_opf_task", "advance"]) != "flanking"});
    _targets = _targets - (units _grp);
    private _target = ([_targets, [], {(leader _grp) distance2D _x}, "ASCEND"] call BIS_fnc_sortBy)#0;
    if !(isNil "_target") exitWith {
        private _targetGrp = group _target;
        {
            if (alive _x) then {
                [_x] joinSilent _targetGrp;
                _x enableAI "PATH";
                _x disableAI "AUTOCOMBAT";
                _x setBehaviour "AWARE";
                _x setUnitPos "AUTO";
                _x doMove (getPos (leader _targetGrp));
                _x doFollow (leader _targetGrp);
            };
        } forEach (units _grp);
        true
    };
    false
};

dyn_opfor_pow_pos = getPos player;

dyn_opfor_surrender = {
    params ["_grp"];

    sleep 5;

    [_grp] spawn dyn_opfor_reset;

    if (vehicle (leader _grp) != leader _grp) then {
        _grp leaveVehicle (vehicle (leader _grp));
    };

    _surrenderGrp = createGroup [civilian , true];

    {
        if (alive _x) then {
            [_x] joinSilent _surrenderGrp;
            _x setCaptive true;
            removeAllWeapons _x;
            _x disableAI "PATH";
            _x setUnitPos "DOWN";
            _x enableDynamicSimulation true;
            // [_x] spawn {
            //  sleep 5;
            //  (_this#0) playActionNow selectRandom ["agonyStart", "surrender"];
            // };
        };
    } forEach (units _grp) ;
    _surrenderGrp setBehaviour "CARELESS";
    _surrenderGrp setSpeedMode "LIMITED";

    // sleep 80;

    waitUntil {sleep 5; !((((getPos (leader _surrenderGrp)) nearEntities [["Man", "Tank", "Car"], 120]) select {side _x == playerSide}) isEqualto [])};

    {

        if (alive _x) then {
            [_x] spawn {
                (_this#0) setUnitPos "MIDDLE";
                sleep 3;
                (_this#0) playActionNow "surrender";
            };
            sleep 0.5 + (random 2);
        };
    } forEach (units _surrenderGrp) ;

    waitUntil {sleep 5; !((((getPos (leader _surrenderGrp)) nearEntities [["Man", "Tank", "Car"], 10]) select {side _x == playerSide}) isEqualto [])};

    {
        _x forceSpeed 1;
        _x enableAI "PATH";
        _x switchMove "";
        _x setUnitPos "UP";
        _x doMove dyn_opfor_pow_pos;
    } forEach (units _surrenderGrp);
    _surrenderGrp addWaypoint [dyn_opfor_pow_pos , 100];

    waitUntil {sleep 10; (leader _surrenderGrp) distance2D dyn_opfor_pow_pos < 100 or ({alive _x} count (units _surrenderGrp)) <= 0};

    {
        deleteVehicle _x;
    } forEach (units _surrenderGrp);
    deleteGroup _surrenderGrp;
};

dyn_continous_surrender = {

    sleep 500;

    while {sleep 1; true} do {
        {
            _grp = _x;
            if ((count (units _grp) <= 2 and (vehicle (leader _grp)) == (leader _grp))) then {
                _joined = [_grp, side _grp] call dyn_opfor_join_grp;
                if !(_joined) then {
                    [_grp] spawn dyn_opfor_surrender;
                };
            };
        } forEach (allGroups select {side _x  == east});

        sleep 240;
    };
};

[] spawn dyn_continous_surrender;

dyn_arty_dmg_reduction = {
    params ["_grp"];

    { 
        _x addEventHandler ['HandleDamage', {
            params['_unit', '_selName', '_damage', '_source'];

            if ((getNumber (configFile >> "CfgVehicles" >> typeOf _source >> "artilleryScanner")) == 1 and (speed _unit) <= 1) then {

                _damage = _damage * 0.05;

                if (_damage > 0.8) then {
                    if ((random 1) > 0.15) then {
                        _unit setUnitPosWeak "DOWN";
                        _unit setSuppression 1;
                        _damage = 0;
                    };
                };
            };
            _damage
        }];
    } forEach (units _grp);  
};
