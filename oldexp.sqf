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


    dyn_start_markers = [];

    for "_i" from 0 to 15 do {
        _m1 = format ["start_%1", _i];
        _m2 = format ["obj_%1", _i];
        _m3 = format ["support_%1", _i];

        dyn_start_markers pushBack [_m1, _m2, _m3];        
    };

    dyn_locations = [];

    ///-------------------Version 1 ------------------------
    // dyn_map_center = [worldSize / 2, worldsize / 2, 0];
    // _locations = nearestLocations [dyn_map_center, ["NameVillage", "NameCity"], worldSize * 0.3];
    // _startLoc = selectRandom _locations;
    // _startPos = getPos _startLoc;
    // private _campaignDir = ((getPos _startLoc) getDir dyn_map_center) - 180;
    // _playerStart = [3600 * (sin _campaignDir), 3600 * (cos _campaignDir), 0] vectorAdd _startPos;
    // dyn_locations pushBack _startLoc;

    ////---------------------Version 2------------------------------
    dyn_map_center = [worldSize / 2, worldsize / 2, 0];
    
    _startPair = selectRandom dyn_start_markers;

    // debug override
    // _startPair = ["start_14", "obj_14", "support_14"];
    _playerStartDir = markerDir (_startPair#0);

    _playerStart = getMarkerPos (_startPair#0);
    _startLoc = nearestLocation [getMarkerPos (_startPair#1), ""];
    _startPos = getPos _startLoc;
    _supportPos = getMarkerPos (_startPair#2);
    dyn_locations pushBack _startLoc;
    private _campaignDir = ((getPos _startLoc) getDir dyn_map_center) - 180;

    if (dyn_debug) then {
        _pm = createMarker [str (random 1), _playerStart];
        _pm setMarkerType "mil_marker";
        _lm = createMarker [str (random 1), _startPos];
        _lm setMarkerType "mil_circle";
    };

    if !(dyn_debug) then {
        {
            deleteMarker (_x#0);
            deleteMarker (_x#1);
            deleteMarker (_x#2);
        } forEach dyn_start_markers;

        deleteMarker "test_m_1";
        deleteMarker "test_m_2";
        
    };


    _intervals = 2000;
    _campaignDir = _campaignDir + ([-20, 20] call BIS_fnc_randomInt);
    _offsetPos = [1500 * (sin (_campaignDir - 180)), 1500 * (cos (_campaignDir - 180)), 0] vectorAdd _startPos;
    for "_i" from 0 to 8 do {
        _pos = [(_intervals * _i) * (sin (_campaignDir - 180)), (_intervals * _i) * (cos (_campaignDir - 180)), 0] vectorAdd _offsetPos;
        _loc = nearestLocation [_pos, "NameVillage"];
        if ((_pos distance2D (getPos _loc)) < 3000) then {
            _valid = {
                if (((getPos _x) distance2D (getPos _loc)) < 2500) exitWith {false};
                true 
            } forEach dyn_locations;
            if (_valid) then {dyn_locations pushBackUnique _loc};
        };
        _loc = nearestLocation [_pos, "NameCity"];
        if ((_pos distance2D (getPos _loc)) < 3000) then {
            _valid = {
                if (((getPos _x) distance2D (getPos _loc)) < 2500) exitWith {false};
                true 
            } forEach dyn_locations;
            if (_valid) then {dyn_locations pushBackUnique _loc};
        };
        _loc = nearestLocation [_pos, "NameCityCapital"];
        if ((_pos distance2D (getPos _loc)) < 3000) then {
            _valid = {
                if (((getPos _x) distance2D (getPos _loc)) < 2500) exitWith {false};
                true 
            } forEach dyn_locations;
            if (_valid) then {dyn_locations pushBackUnique _loc};
        };
        // debug
        if (dyn_debug) then {
            _m = createMarker [str (random 1), _pos];
            _m setMarkerText str _i;
            _m setMarkerType "mil_dot";
        };
    };

    if (dyn_debug) then {
        _i = 0;
        {
            _m = createMarker [str (random 1), getPos _x];
            _m setMarkerText str _i;
            _m setMarkerType "mil_circle";
            _i = _i + 1;
        } forEach dyn_locations;
    };

    
dyn_msr_markers = [];

dyn_define_msr = {
    params ["_start", "_goal"];
    private _dummyGroup = createGroup sideLogic;
    private _closedSet = [];
    private _openSet = [_start];
    private _current = _start;
    private _nodeCount = 0;
    private _allRoads = [];
    while {!(_openSet isEqualTo [])} do {
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
                dyn_msr_markers pushBack (getPos _parent);

                // private _marker = createMarker [str _parent, getPos _parent];
                // _marker setMarkerShape "ICON";
                // _marker setMarkerColor "colorBLUFOR";
                // _marker setMarkerType "MIL_DOT";
                // _marker setMarkerSize [0.3, 0.3];

                _parent = _dummyGroup getVariable ("NF_neighborParent_" + str _parent);
            };
        };
        _openSet = _openSet - [_current];
        _closedSet pushBack _current;
        private _neighbors = (getPos _current) nearRoads 15; // This includes current
        _neighbors append (roadsConnectedTo _current);
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
                    _gScoreIsBest = _gScore < _neighborG;
                };
                if (_gScoreIsBest) then {
                    _dummyGroup setVariable ["NF_neighborParent_" + str _x, _current];
                    _dummyGroup setVariable ["NF_neighborG_" + str _x, _gScore];
                };
            };
        } forEach _neighbors;
    };
    // count _allRoads
};


dyn_place_support_deployed = {
    params ["_startPos", "_dest"];

    _spawnPos = getMarkerPos "support_spawn";
    deleteMarker "support_spawn";

    _vehicles = nearestObjects [_spawnPos,["LandVehicle"], 100];

    _road = [_startPos, 300] call BIS_fnc_nearestRoad;
    _usedRoads = [];
    // reverse _vehicles;

    _roadsPos = [];
    for "_i" from 0 to (count _vehicles) - 1 step 1 do {
        _road = ((roadsConnectedTo _road) - [_road]) select 0;
        _roadPos = getPos _road;
        _near = roadsConnectedTo _road;
        _near = [_near, [], {(getPos _x) distance2D _dest}, "DESCEND"] call BIS_fnc_sortBy;
        _dir = (getPos (_near#0)) getDir (getPos _road);
        _roadsPos pushBack [_roadPos, _dir];
    };

    _roadsPos = [_roadsPos, [], {(_x#0) distance2D _dest}, "ASCEND"] call BIS_fnc_sortBy;

    for "_i" from 0 to (count _vehicles) - 1 step 1 do {
        (_vehicles#_i) setPos ((_roadsPos#_i)#0);
        (_vehicles#_i) setdir ((_roadsPos#_i)#1);
        group (driver (_vehicles#_i)) addWaypoint [(_roadsPos#_i)#0, 0];
    };
};

dyn_place_player_deployed = {
    params ["_startPos", "_startDir", "_placePos", "_dest", "_supportPos"];
    _vehicles = nearestObjects [_startPos,["LandVehicle"], 300];
    {
        _dis = _startPos distance2D _x;
        _dir = _startPos getDir _x;
        _x setVariable ["dyn_rel_data", [_dis, _dir]];
    } forEach _vehicles;

    {
        _relData = _x getVariable "dyn_rel_data";
        _setPos = _placePos getPos [_relData#0, _startDir - (_relData#1)];
        _x setPos _setPos;
        _x setDir _startDir;
        group (driver _x) addWaypoint [_setPos, 0];
    } forEach _vehicles;

    [_supportPos, _dest] call dyn_place_support_deployed;
};



dyn_create_markers = {
    params ["_pos", "_dir", "_trg", "_campaignDir", "_playerPos", "_comp"];

    _pos = [250 * (sin 0), 250 * (cos 0), 0] vectorAdd _pos;

    _marker1 = createMarker [str _pos, _pos];
    _marker1 setMarkerColor "colorOPFOR";
    _marker1 setMarkerType (_comp#0);
    _marker1 setMarkerText (_comp#1);
    _marker1 setMarkerSize [1.2, 1.2];

    _strengthPos = _pos getPos [20, 0];
    _marker2 = createMarker [format ["btl%1", _pos], _strengthPos];
    _marker2 setMarkerType "group_5";
    _marker2 setMarkerSize [1.2, 1.2];


    // _leftPos = [1800 * (sin (_dir - 90)), 1800 * (cos (_dir - 90)), 0] vectorAdd _pos;
    // _rightPos = [1800 * (sin (_dir + 90)), 1800 * (cos (_dir + 90)), 0] vectorAdd _pos;

    // _marker3 = createMarker [format ["left%1", _pos], _leftPos];
    // _marker3 setMarkerShape "RECTANGLE";
    // _marker3 setMarkerSize [8, 2100];
    // _marker3 setMarkerDir _dir;
    // _marker3 setMarkerBrush "SolidFull";
    // _marker3 setMarkerColor "colorBLACK";

    // _marker4 = createMarker [format ["right%1", _pos], _rightPos];
    // _marker4 setMarkerShape "RECTANGLE";
    // _marker4 setMarkerSize [8, 2100];
    // _marker4 setMarkerDir _dir;
    // _marker4 setMarkerBrush "SolidFull";
    // _marker4 setMarkerColor "colorBLACK";

    // _clRightPos = [8000 * (sin (_campaignDir + 90)), 8000 * (cos (_campaignDir + 90)), 0] vectorAdd _pos;
    // _marker5 = createMarker [format ["clright%1", _pos], _clRightPos];
    // _marker5 setMarkerShape "RECTANGLE";
    // _marker5 setMarkerSize [40, 5500];
    // _marker5 setMarkerDir _campaignDir + 90;
    // _marker5 setMarkerBrush "Horizontal";
    // _marker5 setMarkerColor "colorOPFOR";

    // _clLeftPos = [8000 * (sin (_campaignDir - 90)), 8000 * (cos (_campaignDir - 90)), 0] vectorAdd _pos;
    // _marker6 = createMarker [format ["clLeft%1", _pos], _clLeftPos];
    // _marker6 setMarkerShape "RECTANGLE";
    // _marker6 setMarkerSize [40, 5500];
    // _marker6 setMarkerDir _campaignDir - 90;
    // _marker6 setMarkerBrush "Horizontal";
    // _marker6 setMarkerColor "colorOPFOR";

    _marker7 = createMarker [format ["player%1", _pos], _playerPos];
    _marker7 setMarkerType "flag_usa";

    _arrowPos = [(_playerPos distance2d _pos) / 2 * (sin (_playerPos getDir _pos)), (_playerPos distance2d _pos) / 2 * (cos (_playerPos getDir _pos)), 0] vectorAdd _playerPos;
    _marker8 = createMarker [format ["arrow%1", _pos], _arrowPos];
    _marker8 setMarkerType "marker_std_atk";
    _marker8 setMarkerSize [1.5, 1.5];
    _marker8 setMarkerColor "colorBLUFOR";
    _marker8 setMarkerDir (_playerPos getDir _pos);
    _marker8 setMarkerAlpha 0;

    // _teamPos = [2200 * (sin _dir), 2200 * (cos _dir), 0] vectorAdd _rightPos;
    // _marker9 = createMarker [format ["team%1", _pos], _teamPos];
    // _marker9 setMarkerType "b_armor";
    // _marker9 setMarkerSize [0.5, 0.5];
    // // _marker9 setMarkerDir _dir;
    // _marker9 setMarkerText "Team Yankee";

    // _marker10 = createMarker [format ["teamsize%1", _pos], _teamPos];
    // _marker10 setMarkerType "group_4";
    // _marker10 setMarkerSize [0.5, 0.5];

    // _unitLeftPos = [100 * (sin (_dir - 90)), 100 * (cos (_dir - 90)), 0] vectorAdd _leftPos;
    // _type = selectRandom ["group_5", "group_7", "group_6"];
    // _marker11 = createMarker [format ["leftUnit%1", _pos], _unitLeftPos];
    // _marker11 setMarkerType _type;
    // _marker11 setMarkerSize [1.5, 1.5];
    // _marker11 setMarkerDir _dir + 90;

    // _unitRightPos = [100 * (sin (_dir - 90)), 100 * (cos (_dir - 90)), 0] vectorAdd _RightPos;
    // _type = selectRandom ["group_5", "group_7", "group_6"];
    // _marker12 = createMarker [format ["rightUnit%1", _pos], _unitRightPos];
    // _marker12 setMarkerType _type;
    // _marker12 setMarkerSize [1.5, 1.5];
    // _marker12 setMarkerDir _dir + 90;

    sleep 1;

    waitUntil {!(dyn_defense_active)};

    _marker8 setMarkerAlpha 1;

    waitUntil {sleep 1; triggerActivated _trg};

    deleteMarker _marker1;
    deleteMarker _marker2;
    deleteMarker _marker3;
    deleteMarker _marker4;
    // deleteMarker _marker5;
    // deleteMarker _marker6;
    deleteMarker _marker7;
    deleteMarker _marker8;
    deleteMarker _marker9;
    deleteMarker _marker10;
    deleteMarker _marker11;
    deleteMarker _marker12;
};



dyn_strong_point_defence = {
    params ["_locPos", "_townTrg", "_dir", ["_exactPos", false]];
    private ["_distance","_aoPos", "_grps"];

    if (_exactPos) then {
        _distance = 0;
    }
    else
    {
         _distance = [800, 1000] call BIS_fnc_randomInt;
         _locPos = _locPos getPos [_distance, _dir + ([-15, 15] call BIS_fnc_randomInt)];
    };

    _grps = [];
    _infGrp = grpNull;
    {
        _trenchPos = _locPos getPos [_x#1, _dir + (_x#0)];
        _isWater = [_trenchPos] call dyn_is_water;
        _isTown = [_trenchPos] call dyn_is_town;

        if !(_isWater) then {
            if !(_isTown) then {
                _isForest = [_trenchPos] call dyn_is_forest;
                if !(_isForest) then {
                    _infGrp = [_trenchPos, _dir, false, false, false, true, true] call dyn_spawn_covered_inf;
                }
                else
                {
                    _infGrp = [_trenchPos, _dir, false, false, true, false, false] call dyn_spawn_covered_inf;
                };

                _vicPos = _trenchPos getPos [15, _dir - 180];
                _vicGrp = [_vicPos, dyn_standart_combat_vehicles#1, _dir, true, false] call dyn_spawn_covered_vehicle;

                [_infGrp, _vicGrp] spawn {
                    params ["_infGrp", "_vicGrp"];
                    sleep 5;
                    (units _infGrp) joinSilent _vicGrp;
                };

                _grps pushBack _vicGrp;

                _mbtPos = _trenchPos getPos [50, _dir + 90];
                _mbtGrp = [_mbtPos, dyn_standart_MBT, _dir, true, false] call dyn_spawn_covered_vehicle;
            }
            else
            {
                _buildings = nearestObjects [_trenchPos, ["house"], 100];

                _building = {
                    if (count ([_x] call BIS_fnc_buildingPositions) >= 8) exitWith {_x};
                    objNull
                } forEach _buildings;

                if !(isNull _building) then { 
                    _grp = [[0,0,0], east, dyn_standart_squad] call BIS_fnc_spawnGroup;
                    [_building, _grp, _dir] call dyn_garrison_building;
                };
            };
        };
    } forEach [[90, [150, 200] call BIS_fnc_randomInt],  [0, 0], [-90, [150, 200] call BIS_fnc_randomInt], [-180, [200, 250] call BIS_fnc_randomInt]];

    _opPos = createTrigger ["EmptyDetector", _locPos getPos [500, _dir], true];
    _opPos setTriggerActivation ["WEST", "PRESENT", false];
    _opPos setTriggerStatements ["this", " ", " "];
    _opPos setTriggerArea [1500, 10, _dir, true, 30];

    // // debug
    // _m = createMarker [str (random 1), getPos _opPos];
    // _m setMarkerType "mil_dot";

    [_grps, _opPos] spawn {
        params ["_grps", "_opPos"];

        waitUntil {triggerActivated _opPos};

        {
            [_x, 600, false, true] spawn dyn_auto_suppress;
        } forEach _grps;
    };

    {
        if ((random 1) > 0.25 ) then {
            _fieldPos = _locPos getPos [500, _dir + _x];
            [_fieldPos, 500, _dir] call dyn_spawn_mine_field;
        };
    } forEach [90, -90];

};


dyn_ambush = {
    params ["_locPos", "_townTrg", "_dir", ["_exactPos", false]];

    _defPos = _locPos getPos [1400, _dir];

    _trgPos = _defPos getPos [300, _dir];
    private _atkTrg = createTrigger ["EmptyDetector", _trgPos, true];
    _atkTrg setTriggerActivation ["WEST", "PRESENT", false];
    _atkTrg setTriggerStatements ["this", " ", " "];
    _atkTrg setTriggerArea [2500, 65, _dir, true, 30];

    // //debug
    // _m = createMarker [str (random 1), _trgPos];
    // _m setMarkerType "mil_objective";

    _amount = [2, 4] call BIS_fnc_randomInt;
    _ambushLocs = selectBestPlaces [_defPos, 300, "meadow + forest", 95, _amount];

    private _mgGrps = []; 
    {
        [_x#0, _dir, true, true, selectRandom dyn_standart_statics_atgm] call dyn_spawn_static_weapon;

        // //debug
        // _m = createMarker [str (random 1), _x#0];
        // _m setMarkerType "mil_dot";

        _grp = createGroup [east, true];
        _grp setVariable ["pl_not_recon_able", true];
        _mgGrps pushBack _grp;
        for "_i" from 0 to 2 do {
            _mgPos = (_x#0) getPos [8 * _i, _dir + 90];
            _mg = _grp createUnit [dyn_standart_mg, _mgPos, [], 0, "NONE"];
            doStop _mg;
            _mg disableAI "PATH"; 
            _mg setUnitPos "Middle";
            _mg setDir _dir;
            _mg enableDynamicSimulation true;
            _bush = (selectRandom dyn_bushes) createVehicle _mgPos;
        };
    } forEach _ambushLocs;

    _playerVicsCount = count (vehicles select {side _x == playerSide and alive _X});

    [_atkTrg, _locPos, _dir, _mgGrps, _playerVicsCount, _townTrg] spawn {
        params ["_atkTrg", "_locPos", "_dir", "_mgGrps", "_playerVicsCount", "_townTrg"];
        _rearPos = _locPos getPos [1800, _dir - 180];

        waitUntil{sleep 1; triggerActivated _atkTrg or (count (vehicles select {side _x == playerSide and alive _X}) < _playerVicsCount)};

        // [objNull, getPos _atkTrg, getPos _townTrg, [2, 3] call BIS_fnc_randomInt, [2, 3] call BIS_fnc_randomInt, 2] spawn dyn_spawn_counter_attack;
        [objNull, getPos _atkTrg, getPos _townTrg, [2, 3] call BIS_fnc_randomInt, [1, 2] call BIS_fnc_randomInt] spawn dyn_spawn_atk_simple;

        _fireSupport = selectRandom [2,3,2,2,4,4,4,1,1,5,5,5,6,6];

        switch (_fireSupport) do { 
            case 1 : {[6, "rocket"] spawn dyn_arty}; 
            case 2 : {[9, "light"] spawn dyn_arty};
            case 3 : {[6, "heavy"] spawn dyn_arty};
            case 4 : {[_locPos, _locPos getDir _atkTrg, objNull, dyn_attack_plane] spawn dyn_air_attack;};
            case 5 : {[6, "rocketffe"] spawn dyn_arty};
            case 6 : {[8, "balistic"] spawn dyn_arty};
            default {}; 
         }; 
    };
};

dyn_spawn_observation_post = {
    params ["_townTrg", "_dir"];

    _opPos = (getPos _townTrg) getPos [[600, 800] call BIS_fnc_randomInt, _dir];
    _opPos = ((selectBestPlaces [_opPos, 300, "meadow + 2*forest", 100, 1])#0)#0;

    // //debug
    // _m = createMarker [str (random 1), _opPos];
    // _m setMarkerType "mil_dot";

    _grp = createGroup [east, true];
    _grp setVariable ["pl_not_recon_able", true];
    {    
        _s = _grp createUnit [_x, _opPos, [], 0, "NONE"];
        _s disableAI "PATH"; 
        _s setUnitPos "MIDDLE";
        _s setDir _dir;
        _s enableDynamicSimulation true;
        _bPos = _s getPos [10, _dir];
        for "_i" from 0 to 1 do {
            _bush = (selectRandom dyn_bushes) createVehicle _bPos;
            _bush setDir ([0, 360] call BIS_fnc_randomInt);
        };
    } forEach [dyn_standart_mg, dyn_standart_at_soldier];

    [_grp, _dir, 2, false] call dyn_line_form_cover;

    _sPos = _opPos getPos [2, _dir];
    _sCover =  "land_gm_sandbags_01_wall_01" createVehicle _sPos;
    _sCover setDir _dir; 

    _tNetPos = _opPos getPos [6, _dir];
    _tNet = "land_gm_camonet_01_nato" createVehicle _tNetPos;
    _tNet allowDamage false;
    _tNet setDir (_dir - 90);
    _tNet setPos ((getPos _tNet) vectorAdd [0,0,-2.7]);

    _trgPos = (getPos _townTrg) getPos [1300, _dir];
    private _atkTrg = createTrigger ["EmptyDetector", _trgPos, true];
    _atkTrg setTriggerActivation ["WEST", "PRESENT", false];
    _atkTrg setTriggerStatements ["this", " ", " "];
    _atkTrg setTriggerArea [2500, 65, _dir, true, 30];

    // //debug
    // _m = createMarker [str (random 1), _trgPos];
    // _m setMarkerType "mil_dot";

    [_atkTrg, getPos _townTrg, _dir] spawn {
        params ["_atkTrg", "_locPos", "_dir"];
        _rearPos = _locPos getPos [1800, _dir - 180];

        waitUntil{sleep 1; triggerActivated _atkTrg};

        _fireSupport = selectRandom [1,2,2,3,3,3,4,4,4,4];
        // _fireSupport = 2;

        switch (_fireSupport) do {
            case 1 : {[_locPos, _locPos getDir _atkTrg, objNull, dyn_attack_plane] spawn dyn_air_attack;};
            case 2 : {[4] spawn dyn_arty};
            case 3 : {[2] spawn dyn_arty};
            case 4 : {};
            default {}; 
         }; 
    };
};


// dyn_spawn_heli_attack = {
//     params ["_locPos", "_dir", ["_trg", objNull]];

//     // if (true) exitWith {};

//     if !(isNull _trg) then {
//         waitUntil { sleep 1; triggerActivated _trg };
//     };

//     _rearPos = [3000 * (sin (_dir - 180)), 3000 * (cos (_dir - 180)), 0] vectorAdd _locPos;
//     _units = allUnits+vehicles select {side _x == west};
//     _targetPos = getPos (_units#0);

//     // _frontPos = [3000 * (sin _dir), 3000 * (cos _dir), 0] vectorAdd _targetPos;

//     // for "_i" from 0 to 1 do {

//         [_rearPos, _targetPos, _dir] spawn {
//             params ["_rearPos", "_targetPos", "_dir"];

//             _casGroup = createGroup east;
//             _p = [_rearPos, _dir, dyn_attack_heli, _casGroup] call BIS_fnc_spawnVehicle;
//             _plane = _p#0;
//             [_plane, 40] call BIS_fnc_setHeight;
//             // _plane forceSpeed 140;
//             _plane flyInHeight 40;
//             _wp = _casGroup addWaypoint [_targetPos, 0];
//             _time = time + 300;

//             waitUntil {(_plane distance2D (waypointPosition _wp)) <= 200 or time >= _time};

//             _wp = _casGroup addWaypoint [_rearPos, 0];
//             _time = time + 300;
//             _casGroup setBehaviourStrong "CARELESS";

//             waitUntil {(_plane distance2D (waypointPosition _wp)) <= 200 or time >= _time};

//             {
//                 deleteVehicle _x;
//             } forEach (units _casGroup);
//             deleteVehicle _plane;
//         };
//         // sleep 10;
//     // };
// };

dyn_mobile_armor_defense = {
    params ["_locPos", "_townTrg", "_dir", ["_exactPos", false]];
    private ["_stagingPos"];

    if (_exactPos) then {
        _stagingPos = _locPos;
    }
    else
    {
        _stagingPos = [550 * (sin _dir), 550 * (cos _dir), 0] vectorAdd _locPos;
    };

    _accuracy = 100;
    private _terrain = [_stagingPos getPos [500, _dir], _dir, 1500, 2000, _accuracy] call dyn_terrain_scan;

    // forest
    if ((_terrain#0) > (_accuracy * _accuracy) * 0.25) exitWith {[_locPos, _townTrg, _dir] spawn dyn_recon_convoy};
    // town
    if ((_terrain#1) > (_accuracy * _accuracy) * 0.07) exitWith {};
    // water
    if ((_terrain#2) > (_accuracy * _accuracy) * 0.025) exitWith {};

    _trgPos = [2000 * (sin _dir), 2000 * (cos _dir), 0] vectorAdd _locPos;
    private _atkTrg = createTrigger ["EmptyDetector", _trgPos, true];
    _atkTrg setTriggerActivation ["WEST", "PRESENT", false];
    _atkTrg setTriggerStatements ["this", " ", " "];
    _atkTrg setTriggerArea [2500, 65, _dir, true, 30];
    // _atkTrg setTriggerTimeout [30, 45, 70, false];

    private _allTankGrps = [];

    // _m = createMarker [str (random 1), _trgPos];
    // _m setMarkerType "mil_dot";

    for "_i" from 0 to ([5, 7] call BIS_fnc_randomInt) do {
        _vPos = [(70 * _i) * (sin (_dir + 90)), (70 * _i) * (cos (_dir + 90)), 0] vectorAdd _stagingPos;
        _isForest = [_vPos] call dyn_is_forest;
        if !(_isForest) then {
            _grp = [_vPos, 0, [dyn_standart_MBT], _dir] call dyn_spawn_parked_vehicle;
            (vehicle (leader _grp)) limitSpeed 30;
            _allTankGrps pushBack _grp;
        }
        else
        {
            _grp = [_vPos, _dir, true, true, true, true] call dyn_spawn_covered_inf;
        };
    };

    [_atkTrg, _allTankGrps, getPos _townTrg] spawn {
        params ["_atkTrg", "_allTankGrps", "_defPos"];
        _trgPos = getPos _atkTrg;

        waitUntil {sleep 1, triggerActivated _atkTrg};
        
        _leader = _allTankGrps#0;
        _units = allUnits+vehicles select {side _x == west};
        _units = [_units, [], {_x distance2D (leader _leader)}, "ASCEND"] call BIS_fnc_sortBy;
        _atkPos = getPos (_units#0);
        _atkDistance = _atkPos distance2D (getPos (leader _leader));
        _wpIntervall = _atkDistance / 6;
        _atkDir = (getPos (leader _leader)) getDir _atkPos;

        _leaders = [];
        {
            _leaders pushBack (leader _x);
            _x setBehaviour "COMBAT";
        } forEach _allTankGrps;

        private _syncWps = [];
        for "_i" from 1 to 6 do {
            _syncWps = [];
            _lPos = [(_wpIntervall * _i) * (sin _atkDir), (_wpIntervall * _i) * (cos _atkDir), 0] vectorAdd (getPos (leader _leader));
            _isForest = [_lPos] call dyn_is_forest;
            if !(_isForest) then {
                _lWp = _leader addWaypoint [_lPos, 0];
                _syncWps pushBack _lWp;
            };
            {
                _wPos = [(_wpIntervall * _i) * (sin _atkDir), (_wpIntervall * _i) * (cos _atkDir), 0] vectorAdd (getPos (leader _x));
                _isForest = [_wPos] call dyn_is_forest;
                if !(_isForest) then {
                    _gWp = _x addWaypoint [_wPos, 0];
                    _gWp synchronizeWaypoint _syncWps;
                    _syncWps pushBack _gWp;
                };
            } forEach _allTankGrps - [_leader];
        };

        waitUntil {sleep 1; ({alive _x} count _leaders) <= 3};

        // [objNull, _defPos, _allTankGrps, false] spawn dyn_retreat;
        [_defPos, _allTankGrps] spawn dyn_spawn_delay_action;
    };

};

dyn_recon_convoy = {
    params ["_locPos", "_townTrg", "_dir", ["_exactPos", false]];
    private ["_allGrps", "_validRoads", "_iGrps"];

    _trgPos =_locPos getPos [2700, _dir];
    private _atkTrg = createTrigger ["EmptyDetector", _trgPos, true];
    _atkTrg setTriggerActivation ["WEST", "PRESENT", false];
    _atkTrg setTriggerStatements ["this", " ", " "];
    _atkTrg setTriggerArea [3000, 65, _dir, true, 30];
    // _atkTrg setTriggerTimeout [30, 45, 70, false];

    // // debug
    // _m = createMarker [str (random 1), _trgPos];
    // _m setMarkerType "mil_dot";


    waitUntil { sleep 1; triggerActivated _atkTrg };

    _rearPos = _locPos getPos [600, _dir];
    [getPos player, _rearPos, 2, 1] spawn dyn_spawn_atk_complex;
};

dyn_attack_deployed = {
    params ["_locPos", "_townTrg", "_dir", ["_exactPos", false]];

    private _rearPos = _locPos getPos [[500, 1000] call BIS_fnc_randomInt, _dir];
    if (_exactPos) then {_rearPos = _locPos};
    private _atkPos = _rearPos getpos [100, _dir];

    [objNull, _atkPos, _rearPos, 2, 2, true, dyn_standart_mechs, dyn_standart_tanks, true, 150] spawn dyn_spawn_atk_simple
};


dyn_road_blocK = {
    params ["_aoPos", "_endTrg", "_dir", ["_exactPos", false]];

    private _searchPos = _aoPos getPos [800, _dir];
    _searchPos = [_searchPos, 300, _dir] call dyn_find_highest_point;

    if (_exactPos) then {_searchPos = _aoPos};
    private _roads = [];

    for "_i" from 1 to 4 do {

        private _dirOffset = 90;
        if (_i % 2 == 0) then {_dirOffset = -90};
        _p = _searchPos getPos [300 * _i, _dir + _dirOffset];
        _road = [_p, 300, ["TRAIL", "TRACK"]] call dyn_nearestRoad;
        if !(isNull _road) then {_roads pushBack _road};
    };

    // if (_roads isEqualTo []) exitWith {hint "cancel"};


    _road = ([_roads, [], {(getpos _x) distance2D _searchPos}, "ASCEND"] call BIS_fnc_sortBy)#0;

    // _m = createMarker [str (random 3), getPos _road];
    // _m setMarkerType "mil_marker";

    _info = getRoadInfo _road;    
    _endings = [_info#6, _info#7];
    _endings = [_endings, [], {_x distance2D player}, "ASCEND"] call BIS_fnc_sortBy;
    private _roadWidth = _info#1;
    private _rPos = ASLToATL (_endings#0);
    private _roadDir = (_endings#1) getDir (_endings#0);

    [_rPos getPos [100, _roadDir] , _roadWidth * 2, _roadDir, false, 4] spawn dyn_spawn_mine_field;

    [_road] spawn dyn_spawn_razor_road_block;

    _accuracy = 40;
    private _terrain = [_rPos getPos [300, _roadDir], _roadDir, 500, 500, _accuracy] call dyn_terrain_scan;

    // forest
    if ((_terrain#0) > (_accuracy * _accuracy) * 0.5) exitWith {};

    [_rPos getPos [200, _roadDir - 180], _roadDir, 2, 400, 200, 30] spawn dyn_forest_defence_edge;

    _rightPos = _rPos getPos [_roadWidth * 2 + ([0, 20] call BIS_fnc_randomInt), _roadDir + 90];
    _leftPos = _rPos getPos [_roadWidth * 2 + ([0, 20] call BIS_fnc_randomInt), _roadDir - 90];

    private _allGrps = [];

    _allGrps pushBack ([_rightPos, dyn_standart_MBT, _roadDir, true, true] call dyn_spawn_covered_vehicle);
    _allGrps pushBack ([_leftPos, dyn_standart_MBT, _roadDir, true, true] call dyn_spawn_covered_vehicle);

    private _validBuildings = [];
    private _buildings = nearestObjects [_rPos, ["house"], 300];
    {
        if (count ([_x] call BIS_fnc_buildingPositions) >= 8) then {
            _validBuildings pushBack _x;
        };
    } forEach _buildings;

    {
        _x enableDynamicSimulation true;
        _x setVariable ["pl_not_recon_able", true];
    } forEach _allGrps;

    if !(_validBuildings isEqualTo []) then {
        _validBuildings = [_validBuildings, [], {_x distance2D _rPos}, "ASCEND"] call BIS_fnc_sortBy;
        [objNull, _validBuildings#0, _roadDir, _endTrg] spawn dyn_spawn_strongpoint;
    };

    private _revealTrg = createTrigger ["EmptyDetector", _rPos getPos [1000, _dir] , true];
    _revealTrg setTriggerActivation ["WEST", "PRESENT", false];
    _revealTrg setTriggerStatements ["this", " ", " "];
    _revealTrg setTriggerArea [4000, 4000, _dir, true, 30];

    // _m = createMarker [str (random 3), getPos _revealTrg];
    // _m setMarkerType "mil_marker";

    waitUntil {sleep 1; triggerActivated _revealTrg};

    _fireSupport = selectRandom [0,0,0,1,1,2,2,2,3,4,5,6];
    switch (_fireSupport) do { 
        case 0 : {[5, "light"] spawn dyn_arty};
        case 1 : {[5, "rocket"] spawn dyn_arty}; 
        case 2 : {[5] spawn dyn_arty};
        case 3 : {[_rPos, _dir] spawn dyn_air_attack};
        case 4 : {[_rPos, _dir, objNull, dyn_attack_plane] spawn dyn_air_attack};
        case 5 : {[10, "rocketffe"] spawn dyn_arty};
        case 6 : {[8, "balistic"] spawn dyn_arty};
        default {}; 
     };

    {
        _grp = _x;
        {
            (leader _grp) reveal [leader _x, 3];
        } forEach (allGroups select {(hcLeader _x) == player});
    } forEach _allGrps;

};

dyn_town_at_defence = {
    params ["_locPos", "_dir", "_allBuildings", "_trg", "_amount"];
    private ["_losPos"];

    if (_amount == 0) exitWith {};

    private _watchPos = _locPos getPos [1000, _dir];

    _allBuildings = [_allBuildings, [], {_x distance2D _watchPos}, "ASCEND"] call BIS_fnc_sortBy;;

    private _losOffset = 15;
    private _maxLos = 0;
    private _losStartLine = (getpos (_allBuildings#0)) getpos [[5, 20] call BIS_fnc_randomInt, _dir];
    private _validLosPos = [];
    private _accuracy = [10, 20] call BIS_fnc_randomInt;
    private _defenceArea = [100, 250] call BIS_fnc_randomInt;

    for "_j" from 0 to _accuracy do {
        if (_j % 2 == 0) then {
            _losPos = (_losStartLine getPos [2, _dir]) getPos [_losOffset, _dir + 90];
        }
        else
        {
            _losPos = (_losStartLine getPos [2, _dir]) getPos [_losOffset, _dir - 90];
        };
        _losOffset = _losOffset + (_defenceArea / _accuracy);


        _losPos = [_losPos, 1] call dyn_convert_to_heigth_ASL;

        private _losCount = 0;
        for "_l" from 10 to 510 step 50 do {

            _checkPos = _losPos getPos [_l, _dir];
            _checkPos = [_checkPos, 1] call dyn_convert_to_heigth_ASL;
            _vis = lineIntersectsSurfaces [_losPos, _checkPos, objNull, objNull, true, 1, "VIEW"];

            if !(_vis isEqualTo []) exitWith {};

            _losCount = _losCount + 1;
        };
        if (isNull (roadAt _losPos)) then {
            _validLosPos pushback [_losPos, _losCount];
        };
    };

    _validLosPos = [_validLosPos, [], {_x#1}, "DESCEND"] call BIS_fnc_sortBy;

    for "_i" from 1 to _amount do {
        [(_validLosPos#_i)#0, _dir, true, true, selectRandom dyn_standart_statics_atgm] call dyn_spawn_static_weapon;

        _spawnPos = ((_validLosPos#_i)#0) getpos [10, _dir + 90];

        // _grp = createGroup [east, true];
        // _grp setVariable ["pl_not_recon_able", true];
        // {    
        //     _s = _grp createUnit [_x, _spawnPos, [], 0, "NONE"];
        //     _s disableAI "PATH"; 
        //     _s setUnitPos "MIDDLE";
        //     _s setDir _dir;
        //     _s enableDynamicSimulation true;
        //     _bPos = _s getPos [[8, 15] call BIS_fnc_randomInt, _dir + ([-15, 15] call BIS_fnc_randomInt)];
        //     for "_i" from 0 to ([0, 1] call BIS_fnc_randomInt) do {
        //         _bush = (selectRandom dyn_bushes) createVehicle _bPos;
        //         _bush setDir ([0, 360] call BIS_fnc_randomInt);
        //     };
        // } forEach [dyn_standart_at_soldier, dyn_standart_at_soldier];

        // [_grp, _dir, 2, false] call dyn_line_form_cover;

        _sPos = _spawnPos getPos [2, _dir];
        _sCover =  "land_gm_sandbags_01_wall_01" createVehicle _sPos;
        _sCover setDir _dir; 

        _tNetPos = _spawnPos getPos [8, _dir];
        _tNet = "land_gm_camonet_01_nato" createVehicle _tNetPos;
        _tNet allowDamage false;
        _tNet setDir (_dir - 90);
        _tNet setPos ((getPos _tNet) vectorAdd [0,0,-2.7]);
    };

};

dyn_spawn_cp = {
    params ["_pos", "_dir", ["_endTrg", objNull]];

    {
        _rPos = _pos getpos [5, _x];
        _vic = createVehicle [selectRandom dyn_hq_vehicles, _rPos, [], 0, "NONE"];
        _vic setDir _x;

        _net = createVehicle ["land_gm_camonet_02_east", getPosATL _vic, [], 0, "CAN_COLLIDE"];
        _net setVectorUp surfaceNormal position _net;
        _net setDir _x;
    } forEach [0, -90, 90, 180];

    _grp = [_pos getPos [15, _dir], east, dyn_standart_at_team] call BIS_fnc_spawnGroup;
    _grp setBehaviour "SAFE";
    _wpPos = _pos getpos [15, _dir - 180];
    _grp addWaypoint [_wpPos, 50];
    _wp = _grp addWaypoint [_pos, 50];
    _wp setWaypointType "CYCLE";
};


dyn_spawn_sandbag_positions = {
    params ["_roads", "_amount"];
    private ["_bPos", "_roadDir"];

    _vGrp = createGroup [east, true];
    for "_i" from 0 to _amount - 1 do {
        _road = selectRandom _roads;
        {
            _roads deleteAt (_roads find _x);
        } forEach ((getPos _road) nearRoads 30);

        _info = getRoadInfo _road;    
        _endings = [_info#6, _info#7];
        _endings = [_endings, [], {_x distance2D player}, "ASCEND"] call BIS_fnc_sortBy;
        _roadWidth = _info#1;
        _bPos = ASLToATL (_endings#0);
        _roadDir = (_endings#1) getDir (_endings#0);
        _leftOrRight = selectRandom [-90, 90];


        // Main Wall
        _sPos = _bPos getPos [(_roadWidth / 2) + 2, _roadDir + _leftOrRight];
        _sCover =  "land_gm_sandbags_01_wall_01" createVehicle _sPos;
        _sCover setDir _roadDir;
        _mgPos = (_sPos getPos [0.5, _roadDir + 90]) getPos [1.1, _roadDir -180];
        _mgSoldier = _vGrp createUnit [dyn_standart_mg, _mgPos, [], 0, "NONE"];

        // Sidewall
        _sPos2 = ((getPosATLVisual _sCover) getPos [0.6, _roadDir -180]) getPos [1.7, _roadDir + 90];
        _sPos3 = ((getPosATLVisual _sCover) getPos [0.6, _roadDir -180]) getPos [2, _roadDir - 90];
        _sandBag2 = createVehicle ["land_gm_sandbags_01_short_01", _sPos2, [], 0, "CAN_COLLIDE"];
        _sandBag3 = createVehicle ["land_gm_sandbags_01_short_01", _sPos3, [], 0, "CAN_COLLIDE"];
        _sandBag2 setDir _roadDir + 90;
        _sandBag3 setDir _roadDir + 90;

        _at = _vGrp createUnit [dyn_standart_at_soldier, _mgPos getPos [1.2, _roadDir - 90], [], 0, "CAN_COLLIDE"];
        _at setDir _roadDir;

        {
            _x disableAI "PATH";
            _x setUnitPos "MIDDLE";
            _x setDir _roadDir;
            _x doWatch _sPos;
        } forEach [_mgSoldier, _at]
    };
    _vGrp enableDynamicSimulation true;
};

dyn_spawn_raod_block = {
    params ["_pos"];

    _road = [_pos, 400, ["TRAIL"]] call BIS_fnc_nearestRoad;
    _roadDir = ((roadsConnectedTo _road) select 0) getDir _road;
    _block = [getPos _road, sideEmpty, (configFile >> "CfgGroups" >> "Empty" >> "military" >> "RoadBlocks" >> "gm_barrier_light"),[],[],[],[],[], _roadDir] call BIS_fnc_spawnGroup;

    // debug
    // _m = createMarker [str (random 1), getPos _road];
    // _m setMarkerText str _i;
    // _m setMarkerType "mil_circle";   
};

dyn_spawn_hill_overwatch = {
    params ["_pos", "_area", "_amount", "_trg"];

    private _hills = selectBestPlaces [_pos, _area, "2*hills", 70, 5];
    private _hillPos = [];
    private _allGrps = [];

    {
        _hillPos pushBack (_x#0);
    } forEach _hills;

    _hillPos = [_hillPos, [], {_x distance2D (getPos player)}, "ASCEND"] call BIS_fnc_sortBy;

    for "_i" from 0 to (_amount - 1) do {
        _pPos = _hillPos#_i;
        _dir = _pPos getDir Player; 
        _grp = [_pPos, _dir, true, true, true] call dyn_spawn_covered_inf;
        _allGrps pushBack _grp;
    };

    [_trg, getPos _trg, _allGrps, false] spawn dyn_retreat;

    // debug
    // _i = 0;
    // {
        // _m = createMarker [str (random 1), _x];
        // _m setMarkerText str _i;
        // _m setMarkerType "mil_dot";
        // _i = _i + 1
    // } forEach _hillPos;
};

dyn_spawn_forest_position = {
    params ["_pos", "_area", "_amount", "_trg", "_defDir"];

    private _forest = selectBestPlaces [_pos, _area, "(1 + forest + trees) * (1 - sea) * (1 - houses)", 70, 20];
    _patrollPos = [];
    private _allGrps = [];;

    {
        _patrollPos pushBack (_x#0);
    } forEach _forest;

    _defPos = _pos getPos [1700, _defDir];
    _patrollPos = [_patrollPos, [], {_x distance2D _defPos}, "ASCEND"] call BIS_fnc_sortBy;

    for "_i" from 0 to (_amount - 1) do {
        _pPos = _patrollPos#(2 * _i);
        _grp = [_pPos, _defDir, true, false, true] call dyn_spawn_covered_inf;
        _grp enableDynamicSimulation true;
    };

};


dyn_spawn_small_trench = {
    params ["_tPos", "_tDir", ["_camo", false], ["_delay", 15]];

    private _grp = [_tPos, east, dyn_standart_fire_team] call BIS_fnc_spawnGroup;
    // [_grp, _tPos, _tDir, _camo, _delay] spawn {
    //     params ["_grp", "_tPos", "_tDir", "_camo", "_delay"];
    //     sleep 1;
    //     _grp setFormation "LINE";
    //     _grp setFormDir _tDir;
    //     [_grp, _tDir, 2, false] call dyn_line_form_cover;
    //     (leader _grp) setDir _tDir;
    //     sleep _delay;
    //     {
    //         _x disableAI "PATH";
    //         _x setUnitPos "MIDDLE";
    //     } forEach (units _grp);

    //     {
    //         _t2Pos = [2.5 * (sin (_tDir + _x)), 2.5 * (cos (_tDir + _x)), 0] vectorAdd (getPos (leader _grp));
    //         _t = createVehicle ["Land_vn_b_trench_05_01", _t2Pos, [], 0, "CAN_COLLIDE"];
    //         _t setDir (getDir (leader _grp));
    //     } forEach [90, -90];
    //     _rPos = [8 * (sin _tDir), 8 * (cos _tDir), 0] vectorAdd _tPos;
    //     _razor =  "Land_Razorwire_F" createVehicle _rPos;
    //     _razor setDir _tDir;
    //     if (_camo) then {
    //         for "_i" from 0 to 3 do {
    //             _camoPos = [8 * (sin (_tDir + ([-10, 10] call BIS_fnc_randomInt))), 8 * (cos (_tDir + ([-10, 10] call BIS_fnc_randomInt))), 0] vectorAdd _tPos;
    //             (selectRandom dyn_bushes) createVehicle _camoPos;
    //         };
    //         _tNetPos = [9 * (sin _tDir), 9 * (cos _tDir), 0] vectorAdd _tPos;
    //         _tNet = "land_gm_camonet_01_nato" createVehicle _tNetPos;
    //         _tNet allowDamage false;
    //         _tNet setDir (_tDir - 90);
    //         _tNet setPos ((getPos _tNet) vectorAdd [0,0,-2.3]);
    //     };
    // };
    _grp enableDynamicSimulation true;
    _grp
};

dyn_spawn_strongpoint = {
    params ["_trg", "_building", "_dir", "_endTrg"];
    private ["_vicType", "_vicGrp"];

    _bDir = getDir _building;

    // debug
    // _m = createMarker [str (random 1), getPos _building];
    // _m setMarkerType "mil_dot";

    // vehicle
    _xMax = ((boundingBox _building)#1)#0;
    _vPos = [(_xMax + 7) * (sin _bDir), (_xMax + 7) * (cos _bDir), 0] vectorAdd (getPos _building);
    _vicType = selectRandom dyn_standart_trasnport_vehicles;
    if ((random 1) > 0.5) then {
        _vicType = selectRandom dyn_standart_combat_vehicles;
    };
    // _vicType = selectRandom dyn_hq_vehicles;
    // _vPos findEmptyPosition [0, 30, _vicType];
    if !(_vPos isEqualTo []) then {
        // _vic = _vicType createVehicle _vPos;
        _vic = createVehicle [_vicType, _vPos, [], 0, "NONE"];
        _vicGrp = createVehicleCrew _vic;
        _vic setDir _bDir;
        _net = createVehicle ["land_gm_camonet_02_east", getPosATL _vic, [], 0, "CAN_COLLIDE"];
        _net setVectorUp surfaceNormal position _net;
        _net setDir _bdir;
        (driver _vic) disableAI "PATH";
    };
    _vicGrp enableDynamicSimulation true;

    // Continious Inf Spawn (90 degrees)
    // [_trg, _building, _endTrg] spawn dyn_spawn_def_waves;

    // small trench

    _tPos = [10 * (sin (_bDir + 90)), 10 * (cos (_bDir + 90)), 0] vectorAdd _vPos;
    [_tPos, _bDir] spawn dyn_spawn_small_trench;


    {
        _rPos = [8 * (sin (_bDir + _x)), 8 * (cos (_bDir + _x)), 0] vectorAdd (getPos _building);
        _razor =  "Land_Razorwire_F" createVehicle _rPos;
        _razor setDir (_bDir + _x);
    } forEach [-90, 90, 180];

    // garrison
    _grp = [[0,0,0], east, dyn_standart_fire_team] call BIS_fnc_spawnGroup;
    [_building, _grp, _dir] spawn dyn_garrison_building;
    sleep 1;
    (units _grp) joinSilent _vicGrp;

    // Inf
    // _infPos = [10 * (sin (_dir - 180)), 10 * (cos (_dir - 180)), 0] vectorAdd (getPos _building);
    // [_infPos, _dir, false, false, false, false, false, dyn_standart_at_team] spawn dyn_spawn_covered_inf;

    // Roadblock
    _road = [getPos _building, 80] call BIS_fnc_nearestRoad;
    [_road, false] spawn dyn_spawn_razor_road_block;

    // Intel
    // [_trg, getPos _building, "loc_Bunker", "", "colorOPFOR"] call dyn_spawn_intel_markers;
};


dyn_garrison_lines = {
    params ["_locPos", "_dir", "_validBuildings", "_idx", "_limit"];
    private ["_spawnBuildings"];

    private _startPos = (getPos (_validBuildings#_idx)) getpos [50, _dir - 180];
    private _mgGrp = createGroup [east, true];
    private _buildingAmount = 0;
    private _spawnBuildingsFinal = [];

    for "_i" from 0 to ([3, 5] call BIS_fnc_randomInt) do {
        _lineMarker = createMarker [format ["im%1", random 2], _startPos getpos [([40, 60] call BIS_fnc_randomInt) * _i, _dir - ([170, 190] call BIS_fnc_randomInt)]];
        _lineMarker setMarkerShape "RECTANGLE";
        _lineMarker setMarkerBrush "SolidFull";
        _lineMarker setMarkerColor "colorOPFOR";
        _lineMarker setMarkerDir _dir;
        _lineMarker setMarkerAlpha 0.5;
        _lineMarker setMarkerSize [400, 20];

        _spawnBuildings = [];

        {
            if (_x inArea _lineMarker) then {
                _spawnBuildings pushback _x;
            };
        } forEach _validBuildings;

        if ((count _spawnBuildings) > _buildingAmount) then {
            _buildingAmount = count _spawnBuildings;
            _spawnBuildingsFinal = _spawnBuildings;
        };

        deleteMarker _lineMarker;
    };

    for "_i" from 0 to (count _spawnBuildingsFinal) - 1 step round (((count _spawnBuildingsFinal) - 1) / _limit) do {
        _building = _spawnBuildingsFinal#_i;

        // _m = createMarker [str (random 2), getPos _building];
        // _m setMarkerType "mil_dot";
        _bDir = getDir _building;
        _xMax = ((boundingBox _building)#1)#0;

        _bSidePosArray = [];
        {
            _bSidePosArray pushback [_building getpos [_xMax + 1.5, _bDir + _x], _x];
        } forEach [0, 90, 180, 270];

        _bSidePosArray = [_bSidePosArray, [], {(_x#0) distance2D player}, "ASCEND"] call BIS_fnc_sortBy;

        _bPos = (_bSidePosArray#0)#0;
        _bPosDir = _bDir + (_bSidePosArray#0)#1;

        _grp = createGroup [east, true];
        dyn_standart_mg createUnit [[0,0,0], _grp];
        dyn_standart_soldier createUnit [[0,0,0], _grp];
        [_building, _grp, _dir] call dyn_garrison_building;

        if ((random 1) > 0.25) then {

            if !([_bPos] call dyn_is_indoor) then {

                _bunker = createVehicle [selectRandom ["land_gm_woodbunker_01_bags", "land_gm_sandbags_02_bunker_high", "land_gm_sandbags_01_round_01"], _bPos , [], 0, "CAN_COLLIDE"];
                _bunker setDir _bPosDir;
                _mg = _grp createUnit [dyn_standart_mg, _bPos, [], 0, "CAN_COLLIDE"];
                _mg setDir _bPosDir;
                _mg disableAI "PATH";

                _sPos = _bPos getPos [2.5, _bPosDir + (selectRandom [-90, 90])];
                _sandBag = createVehicle ["land_gm_sandbags_01_short_01", _sPos, [], 0, "CAN_COLLIDE"];
                _sandBag setDir _bPosDir;

                _at = _grp createUnit [dyn_standart_at_soldier, _sPos getPos [1, _bPosDir - 180], [], 0, "CAN_COLLIDE"];
                _at setDir _bPosDir;
                _at disableAI "PATH";
                _at setUnitPos "MIDDLE";

                // [_bPos getPos [15, _dir], _dir + ([-10, 10] call BIS_fnc_randomInt)] call dyn_spawn_barriers;
            };

            (units _grp) joinSilent _mgGrp;
        } else {

            (units _grp) joinSilent _mgGrp;

            if !([_bPos] call dyn_is_indoor) then {
                _vGrp = [_bPos getPos [3, _bPosDir], selectRandom dyn_standart_combat_vehicles, _bPosDir, true, false] call dyn_spawn_covered_vehicle;
            };
        };
    };
    // _mgGrp setVariable ["pl_not_recon_able", true];
    _mgGrp enableDynamicSimulation true;
};

{
    deleteVehicle _x;
} forEach allMines;


dyn_spawn_covered_trench = {
    params ["_pos", "_dir", ["_infType", dyn_standart_squad]];

    if (_pos isEqualTo []) exitWith {grpNull};

    private _grp = grpNull; 
    _grp = [_pos, east, _infType] call BIS_fnc_spawnGroup;
    _grp setVariable ["onTask", true];

    [_grp, _pos, _dir] spawn {
        params ["_grp", "_pos", "_dir"];
        _grp setFormation "LINE";
        _grp setFormDir _dir;
        (leader _grp) setDir _dir;

        [_grp] call dyn_arty_dmg_reduction;
        [_grp, _dir, round ((count (units _grp)) / 30), false] call dyn_line_form_cover;

        sleep 1;

        private _fortPos = getPosATLVisual (leader _grp);

        [_fortPos, _dir] call dyn_dig_trench;

        _t = createVehicle ["Land_vn_b_trench_tee_01", _fortPos, [], 0, "CAN_COLLIDE"];
        _t setDir ((getDir (leader _grp)) - 180);
        [_grp, (getDir _t) - 180, round ((count (units _grp)) / 30), false, [], 0, false,( getPosASLVisual _t) getPos [0.75, (getDir _t) - 180]] call dyn_line_form_cover;
        {
            _tPos = [13 * (sin (_dir + _x)), 13 * (cos (_dir + _x)), 0] vectorAdd _fortPos;
            _t = createVehicle ["Land_vn_b_trench_45_01", _tPos, [], 0, "CAN_COLLIDE"];
            if (_x > 0 ) then {_t setDir ((getDir (leader _grp)) + 225)} else {_t setDir ((getDir (leader _grp)) + 180)};
            
        } forEach [90, -90];

        _tPos = [5 * (sin _dir), 5 * (cos _dir), 0] vectorAdd _fortPos;
        _tPos = [18 * (sin (_dir - 90)), 18 * (cos (_dir - 90)), 0] vectorAdd _tpos;


        if (random 1) > 0.5 then {
            _offset = 0;
            for "_i" from 0 to 3 do {
                _trenchPos = [_offset * (sin (_dir + 90)), _offset * (cos (_dir + 90)), 0] vectorAdd _tPos;
                _offset = _offset + 10;
                _wPos = [1.1 * (sin _dir), 1.1 * (cos _dir ), 0] vectorAdd _trenchPos;
                _w = createVehicle [selectRandom dyn_bushes, _wPos, [], 3, "CAN_COLLIDE"];
                _w setDir (_dir - 180);
            };
        };

        {
            _x setUnitPos "AUTO";
            _x setUnitPosWeak "UP";
        } forEach (units _grp);

        [_grp, _fortPos, _dir] spawn {
            params ["_grp", "_pos", "_dir"];

            _callsign = groupId _grp;
            waitUntil {sleep 5; _callsign in pl_marta_dic};
            [_pos, 45, _dir, 2] call dyn_draw_mil_symbol_fortification_line;
        };
    };
    _grp enableDynamicSimulation true;
    _grp
};

            //////////////////////// CUP Trench ////////////////////////

            // _tPos = [4.5 * (sin _dir), 4.5 * (cos _dir), 0] vectorAdd _fortPos;
            // _tPos = [18 * (sin (_dir - 90)), 18 * (cos (_dir - 90)), 0] vectorAdd _tpos;

            // // {
            // //     [getPosASL _x, 4, 4, 2] spawn dyn_lowerTerrain;
            // // } forEach (units _grp);

            // _offset = 0;
            // for "_i" from 0 to (count (units _grp)) / 2 - 1 do {
            //     _trenchPos = [_offset * (sin (_dir + 90)), _offset * (cos (_dir + 90)), 0] vectorAdd _tPos;

            //     // _tCover = createVehicle ["land_fort_rampart", _trenchPos, [], 0, "CAN_COLLIDE"];
            //     _comp = selectRandom ["land_fort_rampart"];
            //     // _tCover =  _comp createVehicle _trenchPos;
            //     _tCover = createVehicle [_comp, _trenchPos, [], 0, "CAN_COLLIDE"];
            //     _tCover setDir (_dir - 180);
            //     _tCover setPos ([0,0, -0.5] vectorAdd (getPos _tCover));
            //     // [getPosASL _tCover, 2, 2, 1] spawn dyn_lowerTerrain;
            //     _tPosASL = getPosASL _tCover;
            //     _offset = _offset + 9;
            //     // _wPos = [3 * (sin _dir), 3 * (cos _dir ), 0] vectorAdd _trenchPos;
            //     // // _w = createVehicle ["Land_Razorwire_F", _wPos, [], 0, "CAN_COLLIDE"];
            //     // _w = "Land_Razorwire_F" createVehicle _wPos;
            //     // _w setDir (_dir - 180);

            //     // _tNetPos = _trenchPos getPos [6, _dir];
            //     // _tNet = "land_gm_camonet_01_nato" createVehicle _tNetPos;
            //     // _tNet allowDamage false;
            //     // _tNet setDir (_dir - 90);
            //     // _tNet setPos ((getPos _tNet) vectorAdd [0,0,-2.8]);

            //     if (_bushes) then {
            //         for "_j" from 0 to 1 do {
            //             _bush = (selectRandom dyn_bushes) createVehicle _trenchPos;
            //             _bush setDir ([0, 360] call BIS_fnc_randomInt);
            //             _bush setPos (_trenchPos getPos [[3, 6] call BIS_fnc_randomInt, _dir]);
            //         };
            //     };
            // };

            // _tPos2 = [4.5 * (sin (_dir - 180)), 4.5 * (cos (_dir - 180)), 0] vectorAdd _fortPos;
            // _tPos2 = [18 * (sin (_dir - 90)), 18 * (cos (_dir - 90)), 0] vectorAdd _tpos2;

            // _offset2 = 0;
            // for "_i" from 0 to (count (units _grp)) / 2 - 1 do {
            //     _trenchPos2 = [_offset2 * (sin (_dir + 90)), _offset2 * (cos (_dir + 90)), 0] vectorAdd _tPos2;
            //     // _tCover = createVehicle ["land_fort_rampart", _trenchPos2, [], 0, "CAN_COLLIDE"];
            //     _comp = selectRandom ["land_fort_rampart"];
            //     // _tCover =  _comp createVehicle _trenchPos2;
            //     _tCover = createVehicle [_comp, _trenchPos2, [], 0, "CAN_COLLIDE"];
            //     _tCover setDir _dir;
            //     _tCover setPos ([0,0, -0.5] vectorAdd (getPos _tCover));
            //     // [getPosASL _tCover, 2, 2, 1] spawn dyn_lowerTerrain;
            //     _offset2 = _offset2 + 9;
            // };