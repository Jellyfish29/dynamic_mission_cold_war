dyn_spawn_counter_attack = {
    params ["_trg", "_atkPos", "_defPos", "_inf", "_vics", "_breakPoint", ["_mech", false], ["_vicTypes", dyn_standart_combat_vehicles], ["_spawnDistance", 300], ["_delayAction", [false, 0]], ["_excactPos", false], ["_fromAtk", false]];
    private ["_rearPos"];

    if !(isNull _trg) then {
        waitUntil {sleep 1; triggerActivated _trg};
    };

    // sleep 10;

    private _counterattack = [];
    private _dir = _atkPos getDir _defPos;
    _rearPos = [_spawnDistance * (sin (_dir - 180)), _spawnDistance * (cos (_dir - 180)), 0] vectorAdd _defPos;
    if (_fromAtk) then {
        _rearPos = [_spawnDistance * (sin _dir), _spawnDistance * (cos _dir), 0] vectorAdd _atkPos;
    };

    if (_inf > 0) then {
        _distance = 25;
        for "_i" from 1 to _inf do {
            _nDir = _dir - 90;
            if (_i % 2 == 0) then {
                _nDir = _dir + 90;
                _distance = 50 * _i;
            };
            _iPos = [_distance * (sin _nDir), _distance * (cos _nDir), 0] vectorAdd _rearPos;
            // _iPosFinal = _iPos findEmptyPosition [0, 150, "cwr3_o_t55"];
            _iPosFinal = [_iPos, 0, 90, 0, 0, 0, 0, [], [_iPos, []]] call BIS_fnc_findSafePos;
            _isForest = [_iPosFinal] call dyn_is_forest;
            private _grp = grpNull;
            if (_iPosFinal isEqualTo dyn_map_center) then {
                _grp = [_iPos, east, dyn_standart_squad,[],[],[],[],[], (_dir - 180)] call BIS_fnc_spawnGroup;
                [_grp] call dyn_opfor_change_uniform_grp;
            }
            else
            {
                if (_mech and !(_isForest)) then {
                    _mechType = selectRandom ["cwr3_o_bmp1", "cwr3_o_bmp2", "cwr3_0_mtlb_pk", "cwr3_0_mtlb_pk"];
                    _vic = _mechType createVehicle _iPosFinal;
                    _vic setDir (_dir -180);
                    _grp = createVehicleCrew _vic;
                    _infGrp = [_iPosFinal, east, dyn_standart_squad,[],[],[],[],[], (_dir - 180)] call BIS_fnc_spawnGroup;
                    [_infGrp] call dyn_opfor_change_uniform_grp;
                    {
                        _x assignAsCargo _vic;
                        _x moveInAny _vic;
                        [_x] joinSilent _grp;
                    } forEach (units _infGrp);
                    _vic setUnloadInCombat [true, false];
                    _vic allowCrewInImmobile true;
                    _vic limitSpeed 55;
                    _counterattack pushBack _grp;
                }
                else
                {
                    _grp = [_iPosFinal, east, dyn_standart_squad,[],[],[],[],[], (_dir - 180)] call BIS_fnc_spawnGroup;
                    [_grp] call dyn_opfor_change_uniform_grp;
                };
            };
        };
    };

    if (_vics > 0) then {
        private _vicType = selectRandom _vicTypes;
        _distance = 25;
        for "_i" from 1 to _vics do {
            _nDir = _dir - 90;
            if (_i % 2 == 0) then {
                _nDir = _dir + 90;
                _distance = 50 * _i;
            };
            _vPos = [_distance * (sin _nDir), _distance * (cos _nDir), 0] vectorAdd _rearPos;
            _vPosFinal = [_vPos, 0, 90, 0, 0, 0, 0, [], []] call BIS_fnc_findSafePos;
            _isForest = [_vPosFinal] call dyn_is_forest;
            if (_vPosFinal isEqualTo dyn_map_center or _isForest) then {
                _grp = [_vPos, east, dyn_standart_at_team,[],[],[],[],[_vPos, []], (_dir - 180)] call BIS_fnc_spawnGroup;
                _grp2 = [_vPos, east, dyn_standart_fire_team,[],[],[],[],[_vPos, []], (_dir - 180)] call BIS_fnc_spawnGroup;
                (units _grp2) joinSilent _grp;
                [_grp] call dyn_opfor_change_uniform_grp;
                _counterattack pushBack _grp;
            }
            else
            {
                _vic = _vicType createVehicle _vPosFinal;
                _vic setDir (_dir -180);
                _vic limitSpeed 20;
                if (_mech) then {_vic limitSpeed 40};
                _vic setUnloadInCombat [true, false];
                _vic allowCrewInImmobile true;
                _grp = createVehicleCrew _vic;
                _counterattack pushBack _grp;
            };
            sleep 0.2;
        };
    };
    sleep 5;
    _leader = _counterattack#0;
    if !(_excactPos) then {
        _units = allUnits+vehicles select {side _x == west};
        _units = [_units, [], {_x distance2D (leader _leader)}, "ASCEND"] call BIS_fnc_sortBy;
        _atkPos = getPos (_units#0);
    };
    _atkDistance = _atkPos distance2D (getPos (leader _leader));
    _wpIntervall = _atkDistance / 6;
    _atkDir = (getPos (leader _leader)) getDir _atkPos;

    _leaders = [];
    {
        _leaders pushBack (leader _x);
    } forEach _counterattack;

    private _syncWps = [];
    _unloadaAt = 3;
    if (_atkDistance > 1900) then {_unloadaAt = 4};

    ////  WPS /////
    for "_i" from 1 to 6 do {
        {
            _wPos = [(_wpIntervall * _i) * (sin _atkDir), (_wpIntervall * _i) * (cos _atkDir), 0] vectorAdd (getPos (leader _x));
            _isForest = [_wPos] call dyn_is_forest;
            if (!(_isForest) or _i == 6) then {
                _gWp = _x addWaypoint [_wPos, 0];
                // if (_i == ([3, 4] call BIS_fnc_randomInt) and _mech) then {
                //     _gWp setWaypointType "UNLOAD";
                //     // _gWp setWaypointTimeout [60, 60, 60];
                // };
                // if (_mech and _i == 4) then {_gWp setWaypointType "UNLOAD"};
                if (_i == 6) then {_gWp setWaypointType "SAD"};
            };
        } forEach _counterattack;
    };

    //// PATH ////
    // {
    //     _grp = _x;
    //     _path = [];
    //     for "_i" from 1 to 6 do {
    //         _wPos = [(_wpIntervall * _i) * (sin _atkDir), (_wpIntervall * _i) * (cos _atkDir), 0] vectorAdd (getPos (leader _grp));
    //         _path pushBack _wPos;
    //         _m = createMarker [str (random 1), _wPos];
    //         _m setMarkerType "mil_dot";
    //     };
    //     { _x pushBack 25; } forEach _path;
    //     (vehicle (leader _grp)) setDriveOnPath _path;
    // } forEach _counterattack;

    waitUntil {sleep 1; ({(_atkPos distance2D _x) < 500} count _leaders) > 0 or ({alive _x} count _leaders) <= _breakPoint};

    if ((random 1) > 0.5) then {[8, "rocket"] spawn dyn_arty; [4, "heavy", true] spawn dyn_arty};

    waitUntil {sleep 1; ({alive _x} count _leaders) <= _breakPoint};

    if (random 1 > 0.5 and !(_delayAction#0)) then {
        [objNull, _rearPos, _counterattack, false] spawn dyn_retreat;
    }
    else
    {
        [_rearPos, _counterattack, objNull, _delayAction#1] spawn dyn_spawn_delay_action;
    };

    [] spawn dyn_garbage_clear;
};


dyn_defense_line = {
    params ["_locPos", "_townTrg", "_dir", ["_exactPos", false]];
    private ["_aoPos", "_defPos", "_objs", "_objAmount", "_road", "_dir", "_patrollPos", "_rearPos", "_grps", "_blkPos", "_width", "_pPos"];

    _width = 500;

    if (_exactPos) then {
        _defPos = _locPos;
    }
    else
    {
        _distance = [350, 450] call BIS_fnc_randomInt;
        _defPos = [_distance * (sin _dir), _distance * (cos _dir), 0] vectorAdd _locPos;
    };
    // _road = [_defPos, 400, ["TRAIL"]] call BIS_fnc_nearestRoad;
    // if !(isNull _road) then {_defPos = getPos _road};
    _aoPos = createTrigger ["EmptyDetector", _defPos, true];
    _aoPos setTriggerActivation ["WEST SEIZED", "PRESENT", false];
    _aoPos setTriggerStatements ["this", " ", " "];
    _aoPos setTriggerArea [_width, 65, _dir, true, 30];
    _aoPos setTriggerTimeout [30, 40, 50, false];

    _objs = [];
    _objAmount = [2, 3] call BIS_fnc_randomInt;
    // _dir = 360 + ((triggerArea _aoPos)#2);
    _patrollPos = [];
    _blkPos = [[0, 0, 0]];
    _grps = [];

    _area = [400, 600] call BIS_fnc_randomInt;;
    for "_i" from -40 to 40 step (80 / _objAmount) do {
        _pPos = [_area * (sin (_dir + _i)), _area * (cos (_dir + _i)), 0] vectorAdd _defPos;

        _trees = nearestTerrainObjects [_pPos, ["TREE"], 60, true, true];
        if ((count _trees) > 0) then {
            _pPos = getPos (_trees#0);
        };

        _pDir = _dir + _i;
        _grp = [_pPos, _pDir, true, 20] call dyn_spawn_small_trench;
        _grps pushBack _grp;
        _patrollPos pushBack (getPos (leader _grp));
        _leftRight = selectRandom [90, -90];
        _vPos = [10 * (sin (_pDir - _leftRight)), 10 * (cos (_pDir - _leftRight)), 0] vectorAdd (getPos (leader _grp));
        _vGrp = [_vPos, selectRandom dyn_standart_light_amored_vics, _pDir, true] call dyn_spawn_covered_vehicle;
        _grps pushBack _vGrp;
        // natowire
        {
            _rPos = [18 * (sin (_pDir + _x)), 18 * (cos (_pDir + _x)), 0] vectorAdd _pPos;
            _razor =  "Land_Razorwire_F" createVehicle _rPos;
            _razor setDir (_pDir + _x);
            for "_j" from 0 to 4 do {
                _bush = "gm_b_crataegus_monogyna_01_summer" createVehicle _rPos;
                _bush setDir ([0, 360] call BIS_fnc_randomInt);
                // _bush setPos ([0,0, -0.3] vectorAdd (getPos _bush));
                _bush enableSimulation false;
            };  
        } forEach [90, -90];

        //static
        // _rightLeft = 90;
        // if (_leftRight == 90) then {_rightLeft = -90};

        // _stPos = [12 * (sin (_pDir - _rightLeft)), 12 * (cos (_pDir - _rightLeft)), 0] vectorAdd _pPos;
        // _staticGrp = [_stPos, _pDir, false, true] call dyn_spawn_static_weapon;
        // [_grp, _staticGrp] spawn {
        //     params ["_grp", "_staticGrp"];

        //     sleep 40;

        //     (units _staticGrp) joinSilent _grp;
        // };

        // debug
        // _m = createMarker [str (random 1), _pPos];
        // _m setMarkerType "mil_dot";

        sleep 1;
    };
    
    // Spawn Groups at Position
    // _startPos = _defPos; // [250 * (sin - 90), 250 * (cos - 90), 0] vectorAdd _defPos;
    // _offSet = _width / 2;
    // for "_i" from 0 to (_objAmount - 1) do {
    //     // _pos = [[_aoPos], [[_blkPos#_i, 60], "water"]] call BIS_fnc_randomPos;
    //     _offset = _offset - (_width / _objAmount);
    //     _pos = [_offSet * (sin (_dir + 90)), _offSet * (cos (_dir + 90)), 0] vectorAdd _startPos;
    //     // _grp = [_pos, _dir, true, false, false] call dyn_spawn_covered_inf;
    //     _grp = [_pos, _dir, true] call dyn_spawn_small_trench;
    //     _grps pushBack _grp;
    //     _patrollPos pushBack (getPos (leader _grp));
    //     // _blkPos pushBack (getPos (leader _grp));
    //     _leftRight = selectRandom [90, -90];
    //     _vPos = [10 * (sin (_dir - _leftRight)), 10 * (cos (_dir - _leftRight)), 0] vectorAdd (getPos (leader _grp));
    //     _vGrp = [_vPos, selectRandom dyn_standart_light_amored_vics, _dir, false] call dyn_spawn_covered_vehicle;
    //     _grps pushBack _vGrp;
    //     // natowire
    //     {
    //         _rPos = [18 * (sin (_dir + _x)), 18 * (cos (_dir + _x)), 0] vectorAdd _pos;
    //         _razor =  "Land_Razorwire_F" createVehicle _rPos;
    //         _razor setDir (_dir + _x);  
    //     } forEach [90, -90];  
    // };




    // create Patroll
    for "_i" from 0 to 1 do {
        _grp = [_patrollPos, selectRandom _patrollPos] call dyn_spawn_patrol;
        _grps pushBack _grp;
    };

    // create garrison
    _buildings = nearestObjects [(getPos _aoPos), ["house"], (triggerArea _aoPos)#0];

    _garAmount = [1, 3] call BIS_fnc_randomInt;
    private _garCount = 0;

    {
        if (count ([_x] call BIS_fnc_buildingPositions) >= 4 and ((getPos _x inArea _aoPos)) and _garCount < _garAmount) then {
            _garCount = _garCount + 1;
            _grp = [getPos _aoPos, east, dyn_standart_fire_team] call BIS_fnc_spawnGroup;
            [_x, _grp, _dir] spawn dyn_garrison_building;
        };
    } forEach _buildings;

    // rocketArty
    if ((random 1) > 0.85) then {
        [7, "rocket"] spawn dyn_arty;
    };
    // heli atk
    if ((random 1) > 0.5) then {
        [_locPos, _dir, _aoPos] spawn dyn_air_attack;
    };

    //create counterattack;
    // if ((random 1) > 0.25) then {
        // [_aoPos, getPos _aoPos, getPos _townTrg, 2, 3, 2, false, dyn_standart_light_amored_vics, 0] spawn dyn_spawn_counter_attack;
        // [_aoPos, _grps] spawn dyn_attack_nearest_enemy;
        [getPos _townTrg, _grps, _aoPos, 700] spawn dyn_spawn_delay_action;
    // };

    // Retreat
    [_townTrg, getPos _townTrg, _grps, false] spawn dyn_retreat;
};

dyn_road_emplacemnets = {
    params ["_locPos", "_townTrg", "_dir", ["_exactPos", false]];
    private ["_aoPos", "_defPos", "_objs", "_objAmount", "_road", "_dir", "_patrollPos", "_rearPos", "_grps", "_blkPos"];

    if (_exactPos) then {
        _defPos = _locPos;
    }
    else
    {
        _distance = [600, 750] call BIS_fnc_randomInt;
        _defPos = [_distance * (sin _dir), _distance * (cos _dir), 0] vectorAdd _locPos;
    };
    _aoPos = createTrigger ["EmptyDetector", _defPos, true];
    _aoPos setTriggerActivation ["WEST", "PRESENT", false];
    _aoPos setTriggerStatements ["this", " ", " "];
    _aoPos setTriggerArea [1500, 10, _dir, true, 30];

    _allRoad = _defPos nearRoads 1500;
    private _validRoads = [];
    private _grps = [];
    {
        _road = _x;
        if ((getPos _road) inArea _aoPos and !((getRoadInfo _road)#2)) then {
            _valid = true;
            {
                if (((getPos _road) distance2D (getPos _x)) < 200) exitWith {_valid = false};
            } forEach _validRoads;
            if (_valid) then {
                // if (((getRoadInfo _road)#0) in ["ROAD", "MAIN ROAD"]) then {
                    _validRoads pushBackUnique _x;
                // };
            };
        };
    } forEach _allRoad;

    _blockLimiter = 0;
    {
        if (_blockLimiter <= 4) then {
            _info = getRoadInfo _x;
            _type = _info#0;
            _width = (_info#1) / 2;
            _endings = [_info#6, _info#7];
            _endings = [_endings, [], {_x distance2D _locPos}, "DESCEND"] call BIS_fnc_sortBy;
            _rPos = _endings#0;
            _rDir = (_endings#1) getDir (_endings#0);


            if (_type isEqualTo "ROAD" or _type isEqualTo "MAIN ROAD") then {
                _infleftPos = [(_width + 40) * (sin (_rdir + 90)), (_width + 40) * (cos (_rdir + 90)), 0] vectorAdd _rPos;
                _infrigthPos = [(_width + 40) * (sin (_rdir - 90)), (_width + 40) * (cos (_rdir - 90)), 0] vectorAdd _rPos;
                {
                    _building = nearestBuilding _x;
                    if ((_building distance2D _x) > 70) then {
                        _grp = [_x, _rDir, false, false, false, true, true] call dyn_spawn_covered_inf;
                        _grps pushBack _grp;
                    }
                    else
                    {
                        _grp = [_x, east, dyn_standart_fire_team] call BIS_fnc_spawnGroup;
                        [_building, _grp, _rDir] spawn dyn_garrison_building;
                    };
                } forEach [_infleftPos, _infrigthPos];

                _staticleftPos = [(_width + ([1, 5] call BIS_fnc_randomInt)) * (sin (_rdir + 90)), (_width + ([1, 5] call BIS_fnc_randomInt)) * (cos (_rdir + 90)), 0] vectorAdd _rPos;
                _staticrigthPos = [(_width + ([1, 5] call BIS_fnc_randomInt)) * (sin (_rdir - 90)), (_width + ([1, 5] call BIS_fnc_randomInt)) * (cos (_rdir - 90)), 0] vectorAdd _rPos;
                [selectRandom [_staticleftPos, _staticrigthPos], _rDir, true] call dyn_spawn_static_weapon;

                _vPos = [25 * (sin (_rDir - 180)), 25 * (cos (_rDir - 180)), 0] vectorAdd (selectRandom [_infleftPos, _infrigthPos]);
                [_vPos, dyn_standart_light_amored_vic, _rDir] call dyn_spawn_covered_vehicle;
            }
            else
            {
                _grp = [_rPos, _rDir, true, false, false, false, false] call dyn_spawn_covered_inf;
                _grps pushBack _grp;
            };

            _b = "Land_Razorwire_F" createVehicle _rPos;
            _b setDir _rDir;
            _blockLimiter = _blockLimiter + 1;
        };
    } forEach _validRoads;

    _distance = [400, 600] call BIS_fnc_randomInt;
    _caPos = [_distance * (sin _dir), _distance * (cos _dir), 0] vectorAdd _defPos;
    _aoPos setPos _caPos;

    if ((random 1) > 0.25) then {
        [6, "rocket"] spawn dyn_arty;
    };

    //debug
    // _m = createMarker [str (random 1), getPos _aoPos];
    // _m setMarkerType "mil_dot";

    //create counterattack;
    if ((random 1) > 0.25) then {
        [_aoPos, getPos _aoPos, getPos _townTrg, [4, 5] call BIS_fnc_randomInt, [3, 5] call BIS_fnc_randomInt, 2] spawn dyn_spawn_counter_attack;
        // [_aoPos, _grps] spawn dyn_attack_nearest_enemy;
    };

    // Retreat
    [_townTrg, getPos _townTrg, _grps] spawn dyn_retreat;


    ////debug
    // _i = 0;
    // {
    //     _m = createMarker [str (random 1), getPos _x];
    //     _m setMarkerText str _i;
    //     _m setMarkerType "mil_dot";
    //     _i = _i + 1
    // } forEach _validRoads;
};

dyn_spawn_hq_garrison = {
    params ["_pos", "_area", "_atkDir"];

    _buildings = nearestObjects [_pos, ["house"], _area];

    private _validBuildings = [];
    {
        if ((count ([_x] call BIS_fnc_buildingPositions)) >= 8) then {
            _validBuildings pushBack _x;
        };
    } forEach _buildings;

    _validBuildings = [_validBuildings, [], {_x distance2D _pos}, "ASCEND"] call BIS_fnc_sortBy;

    _hq = _validBuildings#([0, 4] call BIS_fnc_randomInt);
    _dir = getDir _hq;

    _grp = [_pos, east, dyn_standart_fire_team] call BIS_fnc_spawnGroup;
    [_hq, _grp, _dir] spawn dyn_garrison_building;

    _atkTrg = createTrigger ["EmptyDetector", _pos, true];
    _atkTrg setTriggerActivation ["WEST", "PRESENT", false];
    _atkTrg setTriggerStatements ["this", " ", " "];
    _atkTrg setTriggerArea [100, 100, 0, false, 30];

    // small trench
    _tPos = [[[getPos _hq, 30]], [[getPos _hq, 10], "water"]] call BIS_fnc_randomPos;
    [_tPos, _dir] spawn dyn_spawn_small_trench;

    // [_atkTrg, _grps] spawn dyn_attack_nearest_enemy;

    // sorounding garrisons
    _validBuildings = [_validBuildings, [], {_x distance2D (getPos _hq)}, "ASCEND"] call BIS_fnc_sortBy;

    for "_i" from 1 to ([1, 2] call BIS_fnc_randomInt) do {
        _grp = [_pos, east, dyn_standart_fire_team] call BIS_fnc_spawnGroup;
        [(_validBuildings#_i), _grp, _dir] spawn dyn_garrison_building;   
    };

    // hq Vehicles
    _roads = (getPos _hq) nearRoads 70;
    _roads = [_roads, [], {_x distance2D (getPos _hq)}, "ASCEND"] call BIS_fnc_sortBy;

    for "_i" from 0 to ([0, 1] call BIS_fnc_randomInt) do {
        _vic = createVehicle [selectRandom dyn_hq_vehicles, getPos (_roads#_i), [], 0, "CAN_COLLIDE"];
        _roadDir = (getPos ((roadsConnectedTo (_roads#0)) select 0)) getDir getPos (_roads#_i);
        _vic setDir _roadDir;
    };

    // Roadblocks
    _roads = [_roads, [], {_x distance2D player}, "ASCEND"] call BIS_fnc_sortBy;
    _grp = [_roads#0, 20, true, true] spawn dyn_spawn_dimounted_inf;
    // reverse _roads;
    // _grp = [_roads#0, 20, true, true] spawn dyn_spawn_dimounted_inf;

    // static Weapon
    _stDir = _atkDir + ([-20, 20] call BIS_fnc_randomInt);
    _stPos = [18 * (sin _stDir), 18 * (cos _stDir), 0] vectorAdd (getPos _hq);
    [_stPos, _stDir, false, false] spawn dyn_spawn_static_weapon;

    _tentPos = [10 * (sin _dir), 10 * (cos _dir), 0] vectorAdd (getPos _hq);
    _tent = "gm_gc_tent_5x5m" createVehicle _tentPos;
    _tent setDir _dir;

    _flagPos = [6 * (sin _dir), 6 * (cos _dir), 0] vectorAdd _tentPos;
    _flag = "cwr3_flag_ussr" createVehicle _flagPos;
    _hq
};