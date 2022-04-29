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
    [getPos player, _rearPos, 3, 3] spawn dyn_spawn_atk_complex;
};

dyn_attack_deployed = {
    params ["_locPos", "_townTrg", "_dir", ["_exactPos", false]];

    private _rearPos = _locPos getPos [[500, 1000] call BIS_fnc_randomInt, _dir];
    if (_exactPos) then {_rearPos = _locPos};
    private _atkPos = _rearPos getpos [100, _dir];

    [objNull, _atkPos, _rearPos, 3, 3, true, dyn_standart_mechs, dyn_standart_tanks, true, 150] spawn dyn_spawn_atk_simple
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

    if (_roads isEqualTo []) exitWith {hint "cancel"};


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
    // private _unitMarker = [objNull, (getpos _aoPos) getPos [[200, 400] call BIS_fnc_randomInt, 0], dyn_en_comp#0, dyn_en_comp#1, "colorOPFOR", 1.3, 0.7] call dyn_spawn_intel_markers;

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
    [_validBuildings, [2, 4] call BIS_fnc_randomInt, _dir] call dyn_spawn_random_garrison;
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
    [getPos _aoPos, 2000, [1,2] call BIS_fnc_randomInt, _aoPos, _dir] spawn dyn_spawn_forest_patrol;

    // Forest Position
    [(getPos _aoPos) getPos [1500, _dir], _dir, [1, 2] call BIS_fnc_randomInt] spawn dyn_forest_defence_edge;

    // Bridge Defense
    [getPos _aoPos, 1500, 400, _watchPos] spawn dyn_spawn_bridge_defense;

    // side Town Guards
    [_aoPos, getPos _aoPos, 3000, (getPos _aoPos) getPos [1500, _dir]] spawn dyn_spawn_side_town_guards;

    //continous ai fire Support
    [_aoPos, _endTrg, _dir] spawn dyn_continous_support;

    // continous counterattacks
    _cAtkTrg = createTrigger ["EmptyDetector", (getPos _aoPos), true];
    _cAtkTrg setTriggerActivation ["WEST", "PRESENT", false];
    _cAtkTrg setTriggerStatements ["this", " ", " "];
    _cAtkTrg setTriggerArea [1500, 1500, _dir, false, 30];
    [_cAtkTrg, _endTrg, _dir] spawn dyn_continous_counterattack;

    // QRF Patrol
    [getPos _aoPos, (triggerArea _aoPos)#0, _aoPos, [0, 1] call BIS_fnc_randomInt] spawn dyn_spawn_qrf_patrol;

    // OP
    // if ((random 1) > 0.2) then {
    //     [_aoPos, _dir + ([-20, 20] call BIS_fnc_randomInt)] spawn dyn_spawn_observation_post;
    // };

    //atgms
    [getpos _aoPos, _dir, _allBuildings, _aoPos, [0, 1] call BIS_fnc_randomInt] spawn dyn_town_at_defence;

    // CrossRoad
    [getPos _aoPos, (triggerArea _aoPos)#0, [0, 2] call BIS_fnc_randomInt] spawn dyn_crossroad_position;

    [(getpos _aoPos) nearRoads ((triggerArea _aoPos)#0), [0, 1] call BIS_fnc_randomInt] spawn dyn_spawn_sandbag_positions;

    // Continuos Inf Spawn
    _solCount = count _solitaryBuildings;
    _infB = _solitaryBuildings#(_solCount - ([1, round (_solCount * 0.25)] call BIS_fnc_randomInt));
    _solitaryBuildings deleteAt (_solitaryBuildings find _infB);
    [_aoPos, _infB, _endTrg] spawn dyn_spawn_def_waves;

    _allGrps
};


dyn_defended_side_towns = [];
dyn_all_side_town_guards = [];

dyn_spawn_side_town_guards = {
    params ["_endTrg", "_pos", "_area", "_searchPos", ["_limit", 1]];
    private ["_taskname", "_endTrg"];

    sleep (random 2);

    _mainLoc =  nearestLocation [_pos, ""];
    _locs = nearestLocations [_searchPos, ["NameVillage", "NameCity", "NameCityCapital"], _area];
    private _validLocs = [];
    private _allGrps = [];
    {
        if (!(_x in dyn_locations) and !(_x in dyn_defended_side_towns)) then {
            if (((getpos _x) distance2D player) > 1000) then {
                _validLocs pushBackUnique _x;
                
                dyn_defended_side_towns pushBackUnique _x;
            };
        };
    } forEach (_locs - [_mainLoc]);

    _friendlyLocs = nearestLocations [getPos player, ["NameVillage", "NameCity", "NameCityCapital"], 1500];
    {
        // [objNull, (getPos _x) getPos [150, 0], "n_installation", "CIV", "ColorCivilian", 0.6] call dyn_spawn_intel_markers;
        [getPos _x, 0, _endTrg, true] spawn dyn_ambiance_execute;
    } forEach (_friendlyLocs - _validLocs - [_mainLoc]);

    if !(_validLocs isEqualTo []) then {

        _validLocs = [_validLocs, [], {(getPos _x) distance2D _searchPos}, "ASCEND"] call BIS_fnc_sortBy;
        private _n = 0;
        {
            [getPos _x, 0, _endTrg] spawn dyn_ambiance_execute;
            private _validBuildings = [];
            private _buildings = nearestObjects [(getPos _x), ["house"], 400];
            {
                if (count ([_x] call BIS_fnc_buildingPositions) >= 8) then {
                    _validBuildings pushBack _x;
                };
            } forEach _buildings;

            _validBuildings = [_validBuildings, [], {_x distance2D (getPos player)}, "ASCEND"] call BIS_fnc_sortBy;

            _dir = (getPos _x) getDir player;

            if (_n < _limit) then {

                // [objNull, (getPos _x) getPos [200, 270], "o_s_s_inf_pl", "INF", "colorOPFOR", 1.2, 0.6] call dyn_spawn_intel_markers;

                private _qrfTrg = createTrigger ["EmptyDetector", getPos _x , true];
                _qrfTrg setTriggerActivation ["WEST", "PRESENT", false];
                _qrfTrg setTriggerStatements ["this", " ", " "];
                _qrfTrg setTriggerArea [300, 300, _dir, true, 30];

                _amount = [0,1] call BIS_fnc_randomInt;
                if (type _x == "NameCityCapital") then {
                    _amount = [2, 4] call BIS_fnc_randomInt;
                };
                for "_i" from 0 to _amount do {
                    _grp = [getPos _x, east, dyn_standart_fire_team] call BIS_fnc_spawnGroup;
                    _grp enableDynamicSimulation true;
                    dyn_all_side_town_guards pushBack _grp;
                    _buildingIdx = [0, 7] call BIS_fnc_randomInt;
                    [_validBuildings#_buildingIdx, _grp, _dir] spawn dyn_garrison_building;
                    _allGrps pushBack _grp;
                };

                _buildingIdx = [0,6] call BIS_fnc_randomInt;
                if ((random 1) > 0.5) then {
                    _vicGrp = [getPos (_validBuildings#_buildingIdx), 60, true, true] spawn dyn_spawn_dimounted_inf;
                    dyn_all_side_town_guards pushBack _vicGrp;
                    _allGrps pushBack _vicGrp;
                } 
                else
                {
                    _vicGrp = [getPos (_validBuildings#_buildingIdx), 60, false, false] spawn dyn_spawn_dimounted_inf;
                    dyn_all_side_town_guards pushBack _vicGrp;
                    _allGrps pushBack _vicGrp;
                };

                if ((random 1) > 0.5) then {
                    _grp = [getPos _x, 250, dyn_standart_light_amored_vics] call dyn_spawn_parked_vehicle;
                };

                if ((random 1) > 0.5) then {
                    _vPos = [25 * (sin _dir), 25 * (cos _dir), 0] vectorAdd (getPos (_validBuildings#([0, 4] call BIS_fnc_randomInt)));
                    _grp = [_vPos, selectRandom dyn_standart_light_amored_vics, _dir, true, true] call dyn_spawn_covered_vehicle;
                };

                if ((random 1) > 0.5) then {
                    // CrossRoad
                    [getPos _x, 400, 1] spawn dyn_crossroad_position;
                };

                if ((random 1) > 0.5) then {
                    [_qrfTrg, getPos _x, (getPos _x) getpos [800, (getpos _x) getdir (getpos dyn_current_location)], 2, 1] spawn dyn_spawn_atk_simple;
                };

                [_validBuildings, [2, 3] call BIS_fnc_randomInt, _dir] call dyn_spawn_random_garrison;

                if ((random 1) > 0.5) then {

                    [_qrfTrg, getPos _x, 1000, [1, 2] call BIS_fnc_randomInt] spawn dyn_spawn_qrf;
                };

                if ((random 1) > 0.5) then {
                    [getPos _x, 700, 1, _qrfTrg, _dir] spawn dyn_spawn_forest_patrol;
                };

                if ((random 1) > 0.5) then {
                    [_qrfTrg, getPos (selectRandom _validBuildings)] spawn dyn_spawn_supply_convoy;
                };

                [getPos _x, _dir, _buildings, _qrfTrg, [0, 2] call BIS_fnc_randomInt] spawn dyn_town_at_defence;

                [getPos _x, 200, _qrfTrg, [0, 1] call BIS_fnc_randomInt] spawn dyn_spawn_qrf_patrol;

                _endTrg = createTrigger ["EmptyDetector", (getPos _x), true];
                _endTrg setTriggerActivation ["WEST SEIZED", "PRESENT", false];
                _endTrg setTriggerStatements ["this", " ", " "];
                _endTrg setTriggerArea [600, 600, _dir, false, 30];
                _endTrg setTriggerTimeout [30, 60, 120, false];
                _taskname = format ["task_%1", random 1];

                [west, _taskname, ["Offensive", format ["SEIZE %1", text _x], ""], getPos _x, "CREATED", 1, false, "default", false] call BIS_fnc_taskCreate;
            }
            else
            {
                [_validBuildings, [1, 4] call BIS_fnc_randomInt, _dir] call dyn_spawn_random_garrison;
                if ((random 1) > 0.8) then {
                    // CrossRoad
                    [getPos _x, 400, 1] spawn dyn_crossroad_position;
                };
                // [objNull, (getPos _x) getPos [150, 0], "u_installation", "CIV", "ColorUNKNOWN", 0.6] call dyn_spawn_intel_markers;
                // [objNull, (getPos _x) getPos [200, 270], "o_s_t_inf_pl", "", "colorOPFOR", 1.2, 0.6] call dyn_spawn_intel_markers;
            };
            _n = _n + 1;
        } forEach _validLocs;

        waitUntil {sleep 2; triggerActivated _endTrg};

        [_taskname, "SUCCEEDED", true] call BIS_fnc_taskSetState;
    };




    // debug
    // _i = 0;
    // {
    //     _m = createMarker [str (random 1), getPos _x];
    //     _m setMarkerText str _i;
    //     _m setMarkerType "mil_dot";
    //     _i = _i + 1;
    // } forEach _validLocs;

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
    _rearPos = _atkPos getPos [3000, _atkPos getDir _defPos];

    _accuracy = 100;
    private _terrain = [_rearPos getPos [1500, _rearPos getdir _atkPos], _rearPos getdir _atkPos, 1000, 3000, _accuracy] call dyn_terrain_scan;

    dyn_terrain = _terrain;

    private _mainType = "simple";
    // forest
    if ((_terrain#0) > (_accuracy * _accuracy) * 0.3) exitWith {dyn_defense_active = false}; // 23
    // town
    if ((_terrain#1) > (_accuracy * _accuracy) * 0.07) then {_mainType = "complex"};
    // water
    if ((_terrain#2) > (_accuracy * _accuracy) * 0.02) then {_mainType = "complex"};

    [west, format ["defTask%1", _atkPos], ["Deffensive", "Defend against Counter Attack", ""], _atkPos, "ASSIGNED", 1, true, "defend", false] call BIS_fnc_taskCreate;

    _arrowPos = [(_defPos distance2d _atkPos) / 2 * (sin (_defPos getDir _atkPos)), (_defPos distance2d _atkPos) / 2 * (cos (_defPos getDir _atkPos)), 0] vectorAdd _defPos;
    _arrowMarker = createMarker [format ["arrow%1", _atkPos], _arrowPos];
    _arrowMarker setMarkerType "marker_std_atk";
    _arrowMarker setMarkerSize [1.5, 1.5];
    _arrowMarker setMarkerColor "colorOPFOR";
    _arrowMarker setMarkerDir (_defPos getDir _atkPos);

    private _unitMarker = [objNull, _defPos getPos [500, _defPos getdir _atkPos], "o_mech_inf", "Mech Btl.", "colorOPFOR", 0.8] call dyn_spawn_intel_markers;
    private _areaMarker = [objNull, _defPos getPos [500, _defPos getdir _atkPos], "colorOpfor", 800] call dyn_spawn_intel_markers_area;

    sleep _waitTime;
    // sleep 2;

    [playerSide, "HQ"] sideChat format ["SPOTREP: Soviet MotRifBtl at GRID: %1 advancing towards %2", mapGridPosition _defPos, [round (_defPos getDir _atkPos)] call dyn_get_cardinal];


    sleep 10;

    [6, "heavy", true] spawn dyn_arty;
    [10] spawn dyn_arty;

        // [_defPos, _defPos getDir _atkPos] spawn dyn_air_attack;
    _fireSupport = selectRandom [1,1,1,1,2,2,2,3,3,4,4,5,6];
    switch (_fireSupport) do { 
        case 1 : {[10, "rocket"] spawn dyn_arty}; 
        case 2 : {[10] spawn dyn_arty};
        case 3 : {[_defPos, _atkPos getDir _defPos] spawn dyn_air_attack};
        case 4 : {[_defPos, _atkPos getDir _defPos, objNull, dyn_attack_plane] spawn dyn_air_attack; [_defPos getPos [100,0], _defPos getDir _atkPos, objNull, dyn_attack_plane] spawn dyn_air_attack};
        case 5 : {[10, "rocketffe"] spawn dyn_arty};
        case 6 : {[8, "balistic"] spawn dyn_arty};
        default {}; 
     };

    private _units = allUnits+vehicles select {side _x == playerSide};
    _units = [_units, [], {_x distance2D _rearPos}, "ASCEND"] call BIS_fnc_sortBy;
    private _targetPos = getPos (_units#0);
    private _spawnPos = _targetPos getpos [2000, _atkPos getdir _rearPos];

    [_atkPos, _spawnPos, [1, 2] call BIS_fnc_randomInt, [1, 2] call BIS_fnc_randomInt] spawn dyn_spawn_atk_complex;

    _waves = [2, 3] call BIS_fnc_randomInt;
    [objNull, _atkPos, _spawnPos, [1, 2] call BIS_fnc_randomInt, [1, 2] call BIS_fnc_randomInt, true, [dyn_standart_light_amored_vic], dyn_standart_light_amored_vics - [dyn_standart_light_amored_vic]] spawn dyn_spawn_atk_simple;

    for "_i" from 1 to _waves do {

        _time = time + 240 + (30 * _i);
        waitUntil {sleep 1; time >= _time and (count (allGroups select {(side (leader _x)) isEqualTo east})) <= ((count dyn_opfor_grps) + 15)};

        _units = [_units, [], {_x distance2D _rearPos}, "ASCEND"] call BIS_fnc_sortBy;
        _targetPos = getPos (_units#0);
        _spawnPos = _targetPos getpos [2000, _atkPos getdir _rearPos];

        switch (_mainType) do { 
            case "simple" : {
                [objNull, _atkPos, _spawnPos, 1 + _i, 1 + _i, true] spawn dyn_spawn_atk_simple;
                [_atkPos, _spawnPos, 1, 1, false] spawn dyn_spawn_atk_complex;
            }; 
            case "complex" : {
                [objNull, _atkPos, _spawnPos, 1, 1, true] spawn dyn_spawn_atk_simple;
                [_atkPos, _spawnPos, 1 + _i, 1 + _i, false] spawn dyn_spawn_atk_complex;}; 
            default {}; 
        };

        

        _fireSupport = selectRandom [1,1,1,2,2,2,2,2,3,3];
        switch (_fireSupport) do { 
            case 1 : {[7, "rocket"] spawn dyn_arty};
            case 2 : {[7] spawn dyn_arty};
            case 3 : {[_defPos, _defPos getDir _atkPos, objNull, dyn_attack_plane] spawn dyn_air_attack; [_defPos getPos [100,0], _defPos getDir _atkPos, objNull, dyn_attack_plane] spawn dyn_air_attack};
            default {}; 
         }; 
    };

    // player sideChat "spawn end";
    _time = time + 200;
    waitUntil {sleep 5; time >= _time and (count (allGroups select {(side (leader _x)) isEqualTo east})) <= (count dyn_opfor_grps) + 8};

    dyn_intel_markers = [];
    deleteMarker _arrowMarker;
    // deleteMarker _lineMarker;

    _defPos = [400 * (sin (_defPos getDir _atkPos)), 400 * (cos (_defPos getDir _atkPos)), 0] vectorAdd _defPos;

    [objNull, _defPos, allGroups select {(side (leader _x)) isEqualTo east and !(_x in dyn_opfor_grps)}, true] spawn dyn_retreat;

    sleep 60;

    // [] spawn dyn_garbage_clear;

    dyn_defense_active = false;

    [format ["defTask%1", _atkPos], "SUCCEEDED", true] call BIS_fnc_taskSetState;

    deleteMarker _unitMarker;
    deleteMarker _areaMarker;
};
