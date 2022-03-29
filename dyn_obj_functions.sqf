

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

    _trgPos = [2000 * (sin _dir), 2000 * (cos _dir), 0] vectorAdd _locPos;
    private _atkTrg = createTrigger ["EmptyDetector", _trgPos, true];
    _atkTrg setTriggerActivation ["WEST", "PRESENT", false];
    _atkTrg setTriggerStatements ["this", " ", " "];
    _atkTrg setTriggerArea [2500, 65, _dir, true, 30];
    // _atkTrg setTriggerTimeout [30, 45, 70, false];

    private _allTankGrps = [];

    // _m = createMarker [str (random 1), _trgPos];
    // _m setMarkerType "mil_dot";

    for "_i" from 0 to ([4, 6] call BIS_fnc_randomInt) do {
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

    _rearPos = _locPos getPos [400, _dir];
    [getPos _atkTrg, _rearPos, 3, 2] spawn dyn_spawn_atk_complex;
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


dyn_town_defense = {
    params ["_aoPos", "_endTrg", "_dir"];
    private ["_watchPos", "_validBuildings", "_patrollPos", "_allGrps", "_weferlingen"];
    // private _dir = 360 + ((triggerArea _aoPos)#2);
    _watchPos = [1400 * (sin _dir), 1400 * (cos _dir), 0] vectorAdd (getPos _aoPos);
    _validBuildings = [];
    _patrollPos = [];
    _allGrps = [];
    _weferlingen = false;
    if (((triggerArea _aoPos)#0) == 800) then {_weferlingen = true};

    [getPos _aoPos, 0, _endTrg] spawn dyn_ambiance_execute;

    // create outer Garrison
    _allBuildings = nearestObjects [(getPos _aoPos), ["house"], (triggerArea _aoPos)#0];

    {
        if (count ([_x] call BIS_fnc_buildingPositions) >= 8 and ((getPos _x inArea _aoPos))) then {
            _validBuildings pushBack _x;
        };
    } forEach _allBuildings;

    _validBuildings = [_validBuildings, [], {_x distance2D _watchPos}, "ASCEND"] call BIS_fnc_sortBy;

    // front Garrison
    [_validBuildings, [2, 4] call BIS_fnc_randomInt, _dir] call dyn_spawn_mg_team_garrisons; //[2, 4] call BIS_fnc_randomInt

    // Random Garrison
    [_validBuildings, [5, 7] call BIS_fnc_randomInt, _dir] call dyn_spawn_random_garrison;
    if (_weferlingen) then {
        [_validBuildings, 2, _dir] call dyn_spawn_random_garrison;
    };


    // create roadblock
    // _bRoad = [getPos (_validBuildings#0), 80] call BIS_fnc_nearestRoad;
    // [_bRoad, true] call dyn_spawn_razor_road_block;

    // create Razor Wire
    for "_i" from 0 to 3 do {
        _rPos = [30 * (sin _dir), 30 * (cos _dir), 0] vectorAdd (getPos (_validBuildings#_i));
        [_rPos, _dir + ([-20, 20] call BIS_fnc_randomInt)] call dyn_spawn_barriers;
    };

    private _solitaryBuildings = [];
    for "_i" from 0 to (count _validBuildings) - 1 do {
        _b = _validBuildings#_i;
        _xMax = ((boundingBox _b)#1)#0;
        _yMax = ((boundingBox _b)#1)#1;

        _ditances = (_validBuildings - [_b]) apply {_x distance2D _b};
        _valid = {
            if (_x <= 20 or _xMax > 10 or _yMax > 10) exitWith {false};
            true
        } forEach _ditances;
        if (_valid) then {
            _solitaryBuildings pushBack _b;

            ////debug
            // _m = createMarker [str (random 1), getPos _b];
            // _m setMarkerType "mil_dot";
        };
    };
    _solitaryBuildings = [_solitaryBuildings, [], {_x distance2D _watchPos}, "ASCEND"] call BIS_fnc_sortBy;

    // Vehicle in Position
    _vicAmount = ([0, 1] call BIS_fnc_randomInt) * 2;
    for "_i" from 0 to _vicAmount step 2 do {
        _b = _solitaryBuildings#_i;
        _solitaryBuildings deleteAt _i;
        _xMax = ((boundingBox _b)#1)#0;
        _vicType = selectRandom dyn_standart_combat_vehicles;
        _vPos = [(_xMax + 5) * (sin _dir), (_xMax + 5) * (cos _dir), 0] vectorAdd (getPos _b);
        _grp = [_vPos, _vicType, _dir, true, true] call dyn_spawn_covered_vehicle;
    };

    // small Strongpoint
    for "_i" from 0 to ([0, 1] call BIS_fnc_randomInt) do {
        _infB = selectRandom _solitaryBuildings;
        _solitaryBuildings deleteAt (_solitaryBuildings find _infB);
        _grp = [_infB, _dir] spawn dyn_spawn_small_strong_point;
    };

    // create Strongpoint
    _infB = selectRandom _solitaryBuildings;
    _solitaryBuildings deleteAt (_solitaryBuildings find _infB);
    [_aoPos, _infB, _dir, _endTrg] spawn dyn_spawn_strongpoint;

    // create Tank/APC
    private _vGrps = [];
    for "_i" from 0 to ([0, 1] call BIS_fnc_randomInt) do {
        _grp = [getPos _aoPos, 250, dyn_standart_combat_vehicles + [dyn_standart_MBT] + [dyn_standart_light_amored_vic]] call dyn_spawn_parked_vehicle;
        _vGrps pushBack _grp;
        _allGrps pushBack _grp;
        if (_weferlingen) then {
            _grp = [getPos _aoPos, 250, dyn_standart_combat_vehicles + [dyn_standart_MBT] + [dyn_standart_light_amored_vic]] call dyn_spawn_parked_vehicle;
            _vGrps pushBack _grp;
            _allGrps pushBack _grp;
        };
    };

    // Supply Convoy
    if ((random 1) > 0.5) then {
        [_aoPos, getPos (selectRandom _solitaryBuildings)] spawn dyn_spawn_supply_convoy;
    };

    //AA
    if ((random 1) > 0.5) then {
        _grp = [getPos _aoPos, _dir] call dyn_spawn_aa;
        _allGrps pushBack _grp;
        [_aoPos, getPos (leader _grp), "o_antiair", "AA"] spawn dyn_spawn_intel_markers;
    };

    // Forest Patrols
    [getPos _aoPos, 2000, 2, _aoPos, _dir] spawn dyn_spawn_forest_patrol;

    // Forest Position
    // [getPos _aoPos, 2000, 2, _aoPos, _dir] spawn dyn_spawn_forest_position;

    // Bridge Defense
    [getPos _aoPos, 1500, 400, _watchPos] spawn dyn_spawn_bridge_defense;

    // side Town Guards
    [_aoPos, getPos _aoPos, 2000, (getPos _aoPos) getPos [2000, _dir]] spawn dyn_spawn_side_town_guards;

    //harrasment Arty
    [getPos _aoPos, _dir, _endTrg] spawn dyn_spawn_harresment_arty;

    //continous ai fire Support
    [_aoPos, _endTrg, _dir] spawn dyn_continous_support;

    // continous counterattacks
    _cAtkTrg = createTrigger ["EmptyDetector", (getPos _aoPos), true];
    _cAtkTrg setTriggerActivation ["WEST", "PRESENT", false];
    _cAtkTrg setTriggerStatements ["this", " ", " "];
    _cAtkTrg setTriggerArea [1000, 1000, _dir, false, 30];
    [_cAtkTrg, _endTrg, _dir] spawn dyn_continous_counterattack;

    // QRF Patrol
    [getPos _aoPos, (triggerArea _aoPos)#0, _aoPos, [0, 2] call BIS_fnc_randomInt] spawn dyn_spawn_qrf_patrol;

    // OP
    // if ((random 1) > 0.2) then {
    //     [_aoPos, _dir + ([-20, 20] call BIS_fnc_randomInt)] spawn dyn_spawn_observation_post;
    // };

    //atgms
    [getpos _aoPos, _dir, _allBuildings, _aoPos, [0, 2] call BIS_fnc_randomInt] spawn dyn_town_at_defence;

    // CrossRoad
    [getPos _aoPos, (triggerArea _aoPos)#0, 2] spawn dyn_crossroad_position;

    [(getpos _aoPos) nearRoads ((triggerArea _aoPos)#0), [0, 1] call BIS_fnc_randomInt] spawn dyn_spawn_sandbag_positions;

    // Continuos Inf Spawn
    _solCount = count _solitaryBuildings;
    _infB = _solitaryBuildings#(_solCount - ([1, round (_solCount * 0.25)] call BIS_fnc_randomInt));
    _solitaryBuildings deleteAt (_solitaryBuildings find _infB);
    [_aoPos, _infB, _endTrg] spawn dyn_spawn_def_waves;


    _allGrps
};

dyn_defense = {
    params ["_atkPos", "_defPos", "_waitTime"];

    dyn_defense_active = true;

    // _linePos = [300 * (sin (_atkPos getDir _defPos)), 300 * (cos (_atkPos getDir _defPos)), 0] vectorAdd _atkPos;
    // _lineMarker = createMarker [format ["clLeft%1", _atkPos], _linePos];
    // _lineMarker setMarkerShape "RECTANGLE";
    // _lineMarker setMarkerSize [8, 800];
    // _lineMarker setMarkerDir ((_atkPos getDir _defPos) - 90);
    // _lineMarker setMarkerBrush "Horizontal";
    // _lineMarker setMarkerColor "colorBLUFOR";

    _arrowPos = [(_defPos distance2d _atkPos) / 2 * (sin (_defPos getDir _atkPos)), (_defPos distance2d _atkPos) / 2 * (cos (_defPos getDir _atkPos)), 0] vectorAdd _defPos;
    _arrowMarker = createMarker [format ["arrow%1", _atkPos], _arrowPos];
    _arrowMarker setMarkerType "marker_std_atk";
    _arrowMarker setMarkerSize [1.5, 1.5];
    _arrowMarker setMarkerColor "colorOPFOR";
    _arrowMarker setMarkerDir (_defPos getDir _atkPos);

    [objNull, _defPos getPos [500, _defPos getdir _atkPos], "o_mech_inf", "Mech Btl.", "colorOPFOR", 0.8] call dyn_spawn_intel_markers;
    [objNull, _defPos getPos [500, _defPos getdir _atkPos], "colorOpfor", 800] call dyn_spawn_intel_markers_area;

    sleep _waitTime;
    // sleep 2;

    [playerSide, "HQ"] sideChat format ["SPOTREP: Soviet MotRifBtl at GRID: %1 advancing towards %2", mapGridPosition _defPos, [round (_defPos getDir _atkPos)] call dyn_get_cardinal];


    sleep 10;

    if (random 1 < 0.5) then {
        [4, "heavy", true] spawn dyn_arty;
        // [8, "rocket"] spawn dyn_arty;
        [1, "rocketffe"] spawn dyn_arty;
    }
    else
    {
        [4, "heavy", true] spawn dyn_arty;
        // [_defPos, _defPos getDir _atkPos] spawn dyn_air_attack;
        [_defPos, _defPos getDir _atkPos, objNull, dyn_attack_plane] spawn dyn_air_attack;
    };

    _rearPos = _defPos getPos [400, _defPos getDir _atkPos];
    [_atkPos, _rearPos, 6, 5] spawn dyn_spawn_atk_complex;

    // _waves = [2, 3] call BIS_fnc_randomInt;
    // _waves = 0;

    // for "_i" from 0 to _waves do {
    //     _infAmount = [4, 5] call BIS_fnc_randomInt;
    //     _vicAmount = [1, 2] call BIS_fnc_randomInt;
    //     _delay = [true, 600];
    //     _vicTypes = ["cwr3_o_t55"];
    //     _mech = true;
    //     if (_i == 0) then {
    //         _vicTypes = [dyn_standart_MBT];
    //         _vicAmount = _infAmount - 1};
    //         _mech = true;
    //     if !(_mech) then {
    //         _vicAmount = _infAmount;
    //         _vicTypes = dyn_standart_combat_vehicles
    //     };
    //     [objNull, _atkPos, _defPos, _infAmount, _vicAmount, 2, _mech, _vicTypes, 2000, _delay, true, true] spawn dyn_spawn_counter_attack;

    //     // player sideChat "wave spawn";

    //     sleep 5;
    //     { 
    //         _x addCuratorEditableObjects [allUnits, true]; 
    //         _x addCuratorEditableObjects [vehicles, true];  
    //    } forEach allCurators; 

    //     sleep 120;

    //     if (random 1 < 0.5) then {
    //         [5] spawn dyn_arty;
    //     };
    // };

    // player sideChat "spawn end";
    _time = time + 200;
    waitUntil {sleep 1;time >= _time and (count (allGroups select {(side (leader _x)) isEqualTo east})) <= 6};

    dyn_intel_markers = [];
    deleteMarker _arrowMarker;
    // deleteMarker _lineMarker;

    _defPos = [400 * (sin (_defPos getDir _atkPos)), 400 * (cos (_defPos getDir _atkPos)), 0] vectorAdd _defPos;

    [objNull, _defPos, allGroups select {(side (leader _x)) isEqualTo east}, true] spawn dyn_retreat;

    sleep 60;

    dyn_defense_active = false;
};
