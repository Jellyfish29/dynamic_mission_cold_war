dyn_ambush = {
    params ["_pos", "_endTrg", "_dir"];

    _ambushPos = _pos getPos [[1000, 1500] call BIS_fnc_randomInt, _dir];

    if (isNil "_ambushPos") exitWith {};

    private _ambushTrg = createTrigger ["EmptyDetector", _ambushPos getpos [500, _dir], true];
    _ambushTrg setTriggerActivation ["WEST", "PRESENT", false];
    _ambushTrg setTriggerStatements ["this", " ", " "];
    _ambushTrg setTriggerArea [4000, 30, _dir, true, 10];

    // _m  = createMarker [str (random 1), getPos _ambushTrg];
    // _m setMarkerType "mil_dot";

    _amount = [4, 6] call BIS_fnc_randomInt;
    private _allGrps = [];
    private _patrollPos = [];

    for "_i" from 0 to _amount do {
        _spawnPos = _ambushPos getpos [150 * _i, _dir + (selectRandom [90, -90])];

        _trees = nearestTerrainObjects [_spawnPos, ["TREE", "FOREST BORDER", "FOREST TRIANGLE", "FOREST SQUARE", "FOREST"], 80, true, true];

        if ((count _trees) > 0) then {
            _spawnPos = getPos (_trees#0);
           _grp = [_spawnPos, _dir, true, false, false, true, false, dyn_standart_at_team] call dyn_spawn_covered_inf;
           _grp setVariable ["pl_not_recon_able", true];
           _allGrps pushBack _grp;

           [_spawnPos getPos [200, _dir], 100, _dir + ([-10, 10] call BIS_fnc_randomInt), false, 10, 2, false] call dyn_spawn_mine_field;
        } else {
            if ((random 1) > 0.25) then {
                _spawnPos getPos [[-50, 50] call BIS_fnc_randomInt, _dir];
                _grp = [_spawnPos, _dir, false, true, selectRandom (dyn_standart_statics_atgm + dyn_standart_statics_atgun), false] call dyn_spawn_static_weapon;
                _grp setVariable ["pl_not_recon_able", true];
                _allGrps pushBack _grp;

                [_spawnPos getPos [200, _dir], 100, _dir + ([-10, 10] call BIS_fnc_randomInt), false, 10, 2, false] call dyn_spawn_mine_field;
            };
        };

        _patrollPos pushBack _spawnPos;
    };

    [_ambushPos, _dir, 1, 800, 200, 100] spawn dyn_forest_defence_edge;

    _allGrps pushBack ([_patrollPos, _patrollPos#0] call dyn_spawn_patrol);

    // [_ambushPos, 800, 1, _endTrg, _dir] spawn dyn_spawn_forest_patrol;

    [_allGrps, east, "inf"] spawn dyn_spawn_unit_intel_markers;

    [_allGrps, _ambushPos, _dir] spawn {
        params ["_allGrps", "_pos", "_dir"];

        waitUntil {sleep 5; ({(groupId _x) in pl_marta_dic} count _allGrps) > 0};

        [_pos, _dir] call dyn_draw_mil_symbol_screen;
    };

    waitUntil {sleep 2; triggerActivated _ambushTrg};

    {
        _grp = _x;
        {
            (leader _grp) reveal [(leader _x), 3];
        } forEach (allGroups select {(side _x) == playerSide});
    } forEach _allGrps;

    _fireSupport = selectRandom [2,2,2,2,3,3,3,4,4,4,4,4,4,4,4,4,4,5];
    // _fireSupport = 3;
    switch (_fireSupport) do { 
        case 1 : {[8, "rocket"] spawn dyn_arty}; 
        case 2 : {[8] spawn dyn_arty};
        case 3 : {[_ambushPos, _dir, objNull, dyn_attack_plane] spawn dyn_air_attack; [_ambushPos getPos [100, 0], _dir, objNull, dyn_attack_plane] spawn dyn_air_attack};
        case 4 : {[_ambushPos, _dir, objNull, dyn_attack_plane] spawn dyn_air_attack};
        case 5 : {[8, "rocketffe"] spawn dyn_arty};
        default {}; 
     };

    waitUntil {sleep 2; ((_allGrps select {({alive _x} count (units _x)) > 0}) isNotEqualTo _allGrps) or triggerActivated _endTrg};

    _fireSupport = selectRandom [2,2,2,2,3,3,3,4,4,4,4,4,4,4,4,4,4,5];
    // _fireSupport = 3;
    switch (_fireSupport) do { 
        case 1 : {[8, "rocket"] spawn dyn_arty}; 
        case 2 : {[8] spawn dyn_arty};
        case 3 : {[_ambushPos, _dir, objNull, dyn_attack_plane] spawn dyn_air_attack; [_ambushPos getPos [100, 0], _dir, objNull, dyn_attack_plane] spawn dyn_air_attack};
        case 4 : {[_ambushPos, _dir, objNull, dyn_attack_plane] spawn dyn_air_attack};
        case 5 : {[8, "rocketffe"] spawn dyn_arty};
        default {}; 
     };

    sleep ([180, 500] call BIS_fnc_randomInt);

    [objNull, _pos, _allGrps, false] spawn dyn_retreat; 
};


dyn_road_blocK = {
    params ["_aoPos", "_endTrg", "_dir", ["_exactPos", false]];
    // MSR
    _msr = [[getPos player, 200] call dyn_nearestRoad, [_aoPos, 200] call dyn_nearestRoad] call dyn_convoy_parth_find;
    private _road = _msr select (count _msr * 0.75);

    if (isNil "_road") exitWith {};

    // _m = createMarker [str (random 3), getPos _road];
    // _m setMarkerType "mil_marker";

    _info = getRoadInfo _road;    
    _endings = [_info#6, _info#7];
    _endings = [_endings, [], {_x distance2D player}, "ASCEND"] call BIS_fnc_sortBy;
    private _roadWidth = _info#1;
    private _rPos = ASLToATL (_endings#0);
    private _roadDir = (_endings#1) getDir (_endings#0);

    [_rPos getPos [100, _roadDir] , _roadWidth * 2, _roadDir, false, 4] spawn dyn_spawn_mine_field;

    if !((_info#0) in ["TRACK", "TRAIL", "HIDE"]) then {
        [_road] spawn dyn_spawn_heavy_roadblock;
    } else {
        [_road] spawn dyn_spawn_razor_road_block;
    };

    _rightPos = _rPos getPos [_roadWidth * 2 + ([10, 50] call BIS_fnc_randomInt), _roadDir + 90];
    _leftPos = _rPos getPos [_roadWidth * 2 + ([10, 50] call BIS_fnc_randomInt), _roadDir - 90];

    private _allGrps = [];

    _allGrps pushBack ([_rightPos, dyn_standart_MBT, _roadDir, true, true] call dyn_spawn_covered_vehicle);
    _allGrps pushBack ([_leftPos, dyn_standart_MBT, _roadDir, true, true] call dyn_spawn_covered_vehicle);

    if ((random 1) > 0.25) then {
        _allGrps pushBack ([_rightPos getPos [50, _roadDir + 90], _roadDir + ([-10, 10] call BIS_fnc_randomInt), false, false, false, true, true] call dyn_spawn_covered_inf);
    };
    if ((random 1) > 0.25) then {
        _allGrps pushBack ([_leftPos getPos [50, _roadDir - 90], _roadDir + ([-10, 10] call BIS_fnc_randomInt), false, false, false, true, true] call dyn_spawn_covered_inf);
    };

    [(_rightPos getPos [100, _roadDir]) getPos [300, _roadDir + 90] , 450, _roadDir, false, 20] spawn dyn_spawn_mine_field;
    [(_leftPos getPos [100, _roadDir]) getPos [300, _roadDir - 90] , 450, _roadDir, false, 20] spawn dyn_spawn_mine_field;

    _wireStart = _rightPos getPos [50, _roadDir];
    for "_i" from 0 to 7 do {
        _wrPos = _wireStart getPos [30 * _i, _roadDir - 90];
        [_wrPos, _roadDir + ([-20, 20] call BIS_fnc_randomInt)] call dyn_spawn_barriers;
    };


    private _validBuildings = [];
    private _buildings = nearestObjects [_rPos, ["house"], 300];
    {
        if (count ([_x] call BIS_fnc_buildingPositions) >= 8) then {
            _validBuildings pushBack _x;
        };
    } forEach _buildings;

    {
        _x enableDynamicSimulation true;
        // _x setVariable ["pl_not_recon_able", true];
    } forEach _allGrps;

    if !(_validBuildings isEqualTo []) then {
        _validBuildings = [_validBuildings, [], {_x distance2D _rPos}, "ASCEND"] call BIS_fnc_sortBy;
        // [objNull, _validBuildings#0, _roadDir, _endTrg] spawn dyn_spawn_strongpoint;
        [_validBuildings, 1, _roadDir] spawn dyn_spawn_random_garrison;
    };

    // [_rPos, _roadDir] call dyn_draw_mil_symbol_block;

    [_allGrps, east, "armor"] spawn dyn_spawn_unit_intel_markers;

    private _revealTrg = createTrigger ["EmptyDetector", _rPos getPos [400, _dir] , true];
    _revealTrg setTriggerActivation ["WEST", "PRESENT", false];
    _revealTrg setTriggerStatements ["this", " ", " "];
    _revealTrg setTriggerArea [4000, 100, _dir, true, 30];

    [getPos _revealTrg , 400, _dir, false, 20] spawn dyn_spawn_mine_field;

    [_rPos, _roadDir] spawn dyn_spawn_screen;

    // _m = createMarker [str (random 3), getPos _revealTrg];
    // _m setMarkerType "mil_marker";

    [_allGrps, getPos _road, _roadDir] spawn {
        params ["_allGrps", "_rPos", "_roadDir"];

        waitUntil {sleep 5; ({(groupId _x) in pl_marta_dic} count _allGrps) > 0};

        [_rPos, 400, _roadDir, 20] call dyn_draw_mil_symbol_fortification_line;
    };

    waitUntil {sleep 1; triggerActivated _revealTrg};

    _fireSupport = selectRandom [1,1,2,2,2,2,3,4,4,4,4,4,5,6];
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

dyn_forward_recon_element = {
    params ["_pos", "_endTrg", "_dir"];

    _reconPos = _pos getPos [[600, 900] call BIS_fnc_randomInt, _dir];

    if (isNil "_reconPos") exitWith {};

    private _reconTrg = createTrigger ["EmptyDetector", _reconPos getpos [[500, 700] call BIS_fnc_randomInt, _dir], true];
    _reconTrg setTriggerActivation ["WEST", "PRESENT", false];
    _reconTrg setTriggerStatements ["this", " ", " "];
    _reconTrg setTriggerArea [4000, 30, _dir, true, 10];

    // _m  = createMarker [str (random 1), getPos _reconTrg];
    // _m setMarkerType "mil_dot";

    _amount = [2, 4] call BIS_fnc_randomInt;
    private _allGrps = [];
    _patrollPos = [];

    for "_i" from 0 to _amount do {
        _spawnPos = _reconPos getpos [100 * _i, _dir + (selectRandom [90, -90])];


        _trees = nearestTerrainObjects [_spawnPos, ["TREE", "FOREST BORDER", "FOREST TRIANGLE", "FOREST SQUARE", "FOREST"], 80, true, true];

        if ((count _trees) > 0) then {
            _spawnPos = getPos (_trees#0);
            _grp = [_spawnPos getPos [10, _dir - 180], selectRandom dyn_standart_light_amored_vics, _dir, false, true] call dyn_spawn_covered_vehicle;
            _allGrps pushBack _grp;

            // _m  = createMarker [str (random 1), _spawnPos];
            // _m setMarkerType "mil_dot";
        } else {
            if ((random 1) > 0.5) then {
                _spawnPos getPos [[-50, 50] call BIS_fnc_randomInt, _dir];
                _grp = [_spawnPos, dyn_standart_MBT, _dir, false, true] call dyn_spawn_covered_vehicle;
                _allGrps pushBack _grp;

                // _m  = createMarker [str (random 1), _spawnPos];
                // _m setMarkerType "mil_dot";
            };
        };

        _patrollPos pushBack _spawnPos;

    };

    _allGrps pushBack ([_patrollPos, _patrollPos#0] call dyn_spawn_patrol);

    [_allGrps, east, "inf"] spawn dyn_spawn_unit_intel_markers;

    [_allGrps, _reconPos, _dir] spawn {
        params ["_allGrps", "_pos", "_dir"];

        waitUntil {sleep 5; ({(groupId _x) in pl_marta_dic} count _allGrps) > 0};

        [_pos, _dir] call dyn_draw_mil_symbol_screen;
    };

    waitUntil {sleep 2; triggerActivated _reconTrg};


    {
        _grp = _x;
        {
            (leader _grp) reveal [(leader _x), 3];
        } forEach (allGroups select {(side _x) == playerSide});
    } forEach _allGrps;

    _fireSupport = selectRandom [2,2,2,2,3,3,3,3,3,3,3,5];
    // _fireSupport = 3;
    switch (_fireSupport) do { 
        case 1 : {[8, "rocket"] spawn dyn_arty}; 
        case 2 : {[8] spawn dyn_arty};
        case 3 : {[_reconPos, _dir, objNull, dyn_attack_plane] spawn dyn_air_attack; [_reconPos getPos [100, 0], _dir, objNull, dyn_attack_plane] spawn dyn_air_attack};
        case 4 : {[_reconPos, _dir, objNull, dyn_attack_plane] spawn dyn_air_attack};
        case 5 : {[8, "rocketffe"] spawn dyn_arty};
        default {}; 
     };

    waitUntil {sleep 2; ((_allGrps select {({alive _x} count (units _x)) > 0}) isNotEqualTo _allGrps) or triggerActivated _endTrg};

    _fireSupport = selectRandom [2,2,2,2,3,3,3,3,3,3,3,5];
    // _fireSupport = 3;
    switch (_fireSupport) do { 
        case 1 : {[8, "rocket"] spawn dyn_arty}; 
        case 2 : {[8] spawn dyn_arty};
        case 3 : {[_reconPos, _dir, objNull, dyn_attack_plane] spawn dyn_air_attack; [_reconPos getPos [100, 0], _dir, objNull, dyn_attack_plane] spawn dyn_air_attack};
        case 4 : {[_reconPos, _dir, objNull, dyn_attack_plane] spawn dyn_air_attack};
        case 5 : {[8, "rocketffe"] spawn dyn_arty};
        default {}; 
     };

    sleep ([20, 60] call BIS_fnc_randomInt);

    [objNull, _pos, _allGrps, false] spawn dyn_retreat;

    
};

dyn_trench_line_large = {
    params ["_pos", "_endTrg", "_dir"];

    private _validBuildings = [];
    _allBuildings = nearestObjects [_pos, ["house"], 500];
    _watchPos = _pos getPos [1400, _dir];

    // Valid Buildings
    {
        if (count ([_x] call BIS_fnc_buildingPositions) >= 8) then {
            _validBuildings pushBack _x;
        };
    } forEach _allBuildings;

    _validBuildings = [_validBuildings, [], {_x distance2D _watchPos}, "ASCEND"] call BIS_fnc_sortBy;

    private _forwardPos = (getPos (_validBuildings#0)) getPos [[250, 350] call BIS_fnc_randomInt, _dir];
    private _allGrps = [];

    // trenches
    private _trAmount = [2, 3] call BIS_fnc_randomInt;
    for "_i" from 0 to _trAmount do {
        _tPos = _forwardPos getpos [([80, 120] call BIS_fnc_randomInt) * _i, _dir + (selectRandom [90, -90])];
        if !([_tPos] call dyn_is_water) then {
            _allGrps pushBack ([_tPos, _dir + ([-10, 10] call BIS_fnc_randomInt), false, false, false, true, true] call dyn_spawn_covered_inf);

            _vicType = selectRandom dyn_standart_mechs;
            // if ((random 1) > 0.5) then {
                _vPos = _tPos getpos [20, _dir -180];
                _allGrps pushBack ([_vPos, _vicType, _dir, false, false] call dyn_spawn_covered_vehicle);
            // };
        };
    };

    _wireStart = (_forwardPos getPos [20, _dir]) getpos [100, _dir + 90];
    for "_i" from 0 to 20 do {
        _rPos = _wireStart getPos [30 * _i, _dir - 90];
        [_rPos, _dir + ([-20, 20] call BIS_fnc_randomInt)] call dyn_spawn_barriers;
        [_rPos getPos [25, _dir], 30, _dir + ([-10, 10] call BIS_fnc_randomInt), false, 15, 1] call dyn_spawn_mine_field;
    };

    [_forwardPos, _dir, false] spawn dyn_spawn_screen;

    [_allGrps, east, "mech"] spawn dyn_spawn_unit_intel_markers;

    // [_forwardPos, 800, _dir, 20] call dyn_draw_mil_symbol_fortification_line;

    [_allGrps, _forwardPos, _dir] spawn {
        params ["_allGrps", "_pos", "_dir"];

        waitUntil {sleep 5; ({(groupId _x) in pl_marta_dic} count _allGrps) > 0};

        [_pos, 800, _dir, 20] call dyn_draw_mil_symbol_fortification_line;
    };

    _groupCount = count +_allGrps;

    waitUntil {sleep 5; ({({alive _x} count (units _x)) > 0} count _allGrps) <= (_groupCount - 3)};

    sleep ([20, 60] call BIS_fnc_randomInt);

    [objNull, _pos, _allGrps, false] spawn dyn_retreat;
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


    //////// Define Buildings ////////
    _allBuildings = nearestObjects [(getPos _aoPos), ["house"], (triggerArea _aoPos)#0];

    // Valid Buildings
    {
        if (count ([_x] call BIS_fnc_buildingPositions) >= 8 and ((getPos _x inArea _aoPos))) then {
            _validBuildings pushBack _x;
        };
    } forEach _allBuildings;

    _validBuildings = [_validBuildings, [], {_x distance2D _watchPos}, "ASCEND"] call BIS_fnc_sortBy;

    private _forwardPos = (getPos (_validBuildings#0)) getPos [[30, 200] call BIS_fnc_randomInt, _dir];


    // [_forwardPos, 1500, _dir] call dyn_draw_mil_symbol_fortification_line;

    [getpos _aoPos, _validBuildings, selectRandom dyn_phase_names] call dyn_draw_mil_symbol_objectiv;

    // Solitary Buildings
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

    // for "_i" from 0 to (count _solitaryBuildings) - 1 do {
    //     _m = createMarker [str (random 2), getPos (_solitaryBuildings#_i)];
    //     _m setMarkerType "mil_dot";
    //     _m setMarkerText (str _i);
    // };

    _solitaryBuildings = [_solitaryBuildings, [], {_x distance2D _watchPos}, "ASCEND"] call BIS_fnc_sortBy;
    private _buildingCount = count _solitaryBuildings;

    ////// Reinforcements ////////

    // Continuos Inf Spawn
    _solCount = count _solitaryBuildings;
    _infB = _solitaryBuildings#(_solCount - ([1, round (_solCount * 0.25)] call BIS_fnc_randomInt));
    _solitaryBuildings deleteAt (_solitaryBuildings find _infB);
    [_aoPos, _infB, _endTrg] spawn dyn_spawn_def_waves;

    //continous ai fire Support
    [_aoPos, _endTrg, _dir] spawn dyn_continous_support;

    // continous counterattacks
    _cAtkTrg = createTrigger ["EmptyDetector", (getPos _aoPos), true];
    _cAtkTrg setTriggerActivation ["WEST", "PRESENT", false];
    _cAtkTrg setTriggerStatements ["this", " ", " "];
    _cAtkTrg setTriggerArea [1500, 1500, _dir, false, 30];
    [_cAtkTrg, _endTrg, _dir] spawn dyn_continous_counterattack;

    // Supply Convoy
    if ((random 1) > 0.75) then {
        [_aoPos, (getPos _aoPos) getpos [[-500, 1000] call BIS_fnc_randomInt, _dir] , ([1, 2] call BIS_fnc_randomInt), dyn_standart_trasnport_vehicles + [dyn_standart_light_amored_vic] + dyn_hq_vehicles + dyn_standart_supply_vics, [120, 300] call BIS_fnc_randomInt] spawn dyn_spawn_supply_convoy;
        [_aoPos, (getPos _aoPos) getpos [[-500, 1000] call BIS_fnc_randomInt, _dir] , ([1, 2] call BIS_fnc_randomInt), dyn_standart_light_amored_vics + dyn_standart_trasnport_vehicles, [800, 1500] call BIS_fnc_randomInt] spawn dyn_spawn_supply_convoy;
    } else {
        if ((random 1) > 0.5) then {
            [_aoPos, (getPos _aoPos) getpos [[-500, 1000] call BIS_fnc_randomInt, _dir] , ([1, 2] call BIS_fnc_randomInt), dyn_standart_light_amored_vics + dyn_standart_trasnport_vehicles, [300, 500] call BIS_fnc_randomInt] spawn dyn_spawn_supply_convoy;
        } 
    };

    ///// In Town Defenses /////

    // [_validBuildings, [1, 2] call BIS_fnc_randomInt, _dir] call dyn_spawn_mg_team_garrisons; //[2, 4] call BIS_fnc_randomInt

    // First Line Position
    for "_i" from 0 to ([0, 1] call BIS_fnc_randomInt) do {
        _b = _solitaryBuildings#0;
        _solitaryBuildings deleteAt 0;
        // {
        //     if ((_b distance2d _x) < 100) then {
        //         _solitaryBuildings deleteAt (_solitaryBuildings find _x);

        //         // _m = createMarker [str (random 1), getPos _x];
        //         // _m setMarkerType "mil_dot";
        //         // _m setMarkerColor "colorRed";
        //     };
        // } forEach (+_solitaryBuildings);
        _xMax = ((boundingBox _b)#1)#0;
        _vicType = selectRandom dyn_standart_combat_vehicles;
        _vPos = [(_xMax + 5) * (sin _dir), (_xMax + 5) * (cos _dir), 0] vectorAdd (getPos _b);
        _grp = [_vPos, _vicType, _dir, true, true] call dyn_spawn_covered_vehicle;
        [[_b], 1, _dir] spawn dyn_spawn_random_garrison;
    };

    // for "_i" from 0 to ([2,3] call BIS_fnc_randomInt) do {
    //     _b = _solitaryBuildings#_i;
    //     _solitaryBuildings deleteAt (_solitaryBuildings find _b);
    //     [_b, _dir] spawn dyn_spawn_small_strongpoint;
    // };

    // create Tank/APC
    private _vGrps = [];
    private _vicAmount = (round ((count _solitaryBuildings) / 10) - 1);
    if (_vicAmount > 2) then {_vicAmount = 2};
    [getPos _aoPos, 400, _vicAmount] spawn dyn_crossroad_position;

    // Random Log Vehicles
    private _vicAmount = (round ((count _validBuildings) / 15) - 1);
    if (_vicAmount > 2) then {_vicAmount = 2};
    for "_i" from 0 to _vicAmount do {
        _pPos = [[[getPos _aoPos, 300]], ["water"]] call BIS_fnc_randomPos;
        _pPos findEmptyPosition [0, 100, "cwr3_o_ural_open"];

        0 = [getPos _aoPos, 250, dyn_standart_supply_vics + dyn_standart_trasnport_vehicles, 0, true] call dyn_spawn_parked_vehicle;
    };

    // Random Garrison
    private _garAmount = (round ((count _validBuildings) / 10) - 1);
    if (_garAmount > 3) then {_garAmount = 3};
    if (_garAmount < 1) then {_garAmount = 1};
    // [_validBuildings, _garAmount, _dir] call dyn_spawn_random_garrison;
    for "_i" from 0 to _garAmount do {
        _b = selectRandom _validBuildings;
        _validBuildings deleteAt (_solitaryBuildings find _b);
        [_b, _dir] spawn dyn_spawn_small_strongpoint;
    };

    // Strongpoint
    private _SPamount = (round (_buildingCount / 10)) - 1;
    if (_SPamount > 1) then {_SPamount = 1};
    for "_i" from 0 to _SPamount do {
        _infB = selectRandom _solitaryBuildings;
        {
            if ((_infB distance2d _x) < 100) then {
                _solitaryBuildings deleteAt (_solitaryBuildings find _x);

                // _m = createMarker [str (random 1), getPos _x];
                // _m setMarkerType "mil_dot";
                // _m setMarkerColor "colorRed";
            };
        } forEach (+_solitaryBuildings);
        _solitaryBuildings deleteAt (_solitaryBuildings find _infB);
        _grp = [_infB, _dir] spawn dyn_spawn_strong_point;
    };

    //AA
    if ((random 1) > 0.5) then {
        _grp = [getPos _aoPos, _dir] call dyn_spawn_aa;
        _allGrps pushBack _grp;
        // [_aoPos, getPos (leader _grp), "o_antiair", "AA"] spawn dyn_spawn_intel_markers;
    };

    ////// Outer Defense ////////

    // checkpoints
    [getPos _aoPos, ((getpos (_validBuildings#0)) distance2D (getpos _aoPos)) + 75] call dyn_town_entry_checkpoints;

    // trenches
    if ((random 1) > 0.35) then {
        private _trAmount = (round (_buildingCount / 15)) - 1;
        if (_trAmount > 1) then {_trAmount = 1};
        for "_i" from 0 to _trAmount do {
            _tPos = _forwardPos getpos [([100, 180] call BIS_fnc_randomInt) * _i, _dir + (selectRandom [90, -90])];
            if !([_tPos] call dyn_is_water) then {
                [_tPos, _dir + ([-10, 10] call BIS_fnc_randomInt), false, false, false, true, true] call dyn_spawn_covered_inf;
            };
        };
    };

    // create Razor Wire
    if (random (1) > 0.5) then {
        _wireStart = (_forwardPos getPos [20, _dir]) getpos [100, _dir + 90];
        for "_i" from 0 to 10 do {
            _rPos = _wireStart getPos [30 * _i, _dir - 90];
            [_rPos, _dir + ([-20, 20] call BIS_fnc_randomInt)] call dyn_spawn_barriers;
        };
    };

    // mines
    if ((random 1) > 0.5) then {

        _mineStart = (_forwardPos getPos [150, _dir]) getpos [500, _dir + 90];
        for "_i" from 0 to 20 do {
            _rPos = _mineStart getPos [(1000 / 20) * _i, _dir - (90 + ([-3, 3] call BIS_fnc_randomInt))];

            if ((random 1) > 0.8 and !([_rPos ] call dyn_is_forest)) then { 
                [_rPos, (1000 / 20) + 20, _dir + ([-10, 10] call BIS_fnc_randomInt), false, 10, 1] call dyn_spawn_mine_field;

                    // _m = createMarker [str (random 1), _rPos];
                    // _m setMarkerType "mil_dot";
                    // _m setMarkerColor "colorRed";
            };
        };
    };

    // Forest Patrols
    [getPos _aoPos, 2000, [0,2] call BIS_fnc_randomInt, _aoPos, _dir] spawn dyn_spawn_forest_patrol;

    // Forest Position
    if ((random 1) > 0.5) then {
        [(getPos _aoPos) getPos [500, _dir], _dir, [1, 2] call BIS_fnc_randomInt] spawn dyn_forest_defence_edge;
    };

    // side Screens
    if ((random 1) > 0.5) then {
        [getPos _aoPos, _dir] spawn dyn_spawn_screen;
    };


    // Unit Symbol
    [getpos _aoPos] spawn {
        params ["_pos"];

        sleep 10;

        private _townGrps = [];

        {
            if (((_pos distance2D (leader _x)) < 500)) then {
                _townGrps pushBack _x;
            }
        } forEach ((allGroups select {(side _x) isEqualTo east}) - dyn_opfor_grps);

        [_townGrps, east, selectRandom ["armor", "mech", "mech", "inf"]] spawn dyn_spawn_unit_intel_markers;
    };
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
    // {
    //     // [objNull, (getPos _x) getPos [150, 0], "n_installation", "CIV", "ColorCivilian", 0.6] call dyn_spawn_intel_markers;
    //     [getPos _x, 0, _endTrg, true] spawn dyn_ambiance_execute;
    // } forEach (_friendlyLocs - _validLocs - [_mainLoc]);

    if !(_validLocs isEqualTo []) then {

        _validLocs = [_validLocs, [], {(getPos _x) distance2D _searchPos}, "ASCEND"] call BIS_fnc_sortBy;
        private _n = 0;
        {
            // [getPos _x, 0, _endTrg] spawn dyn_ambiance_execute;
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
                    [_qrfTrg, getPos _x, (getPos _x) getpos [800, (getpos _x) getdir (getpos dyn_current_location)], 2, 1] spawn dyn_spawn_atk_simple;
                };

                [_validBuildings, [2, 3] call BIS_fnc_randomInt, _dir] call dyn_spawn_random_garrison;

                if ((random 1) > 0.5) then {
                    [_qrfTrg, getPos (selectRandom _validBuildings)] spawn dyn_spawn_supply_convoy;
                };

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
                    [getPos _x, 400, 1, true] spawn dyn_crossroad_position;
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
    // water
    // if ((_terrain#2) > (_accuracy * _accuracy) * 0.02) exitWith {dyn_defense_active = false};
    // town
    if ((_terrain#1) > (_accuracy * _accuracy) * 0.07) then {_mainType = "complex"};

    [west, format ["defTask%1", _atkPos], ["Deffensive", "Defend against Counter Attack", ""], _atkPos, "ASSIGNED", 1, true, "defend", false] call BIS_fnc_taskCreate;

    _arrowPos = [(_defPos distance2d _atkPos) / 2 * (sin (_defPos getDir _atkPos)), (_defPos distance2d _atkPos) / 2 * (cos (_defPos getDir _atkPos)), 0] vectorAdd _defPos;
    _arrowMarker = createMarker [format ["arrow%1", _atkPos], _arrowPos];
    _arrowMarker setMarkerType "marker_std_atk";
    _arrowMarker setMarkerSize [1.5, 1.5];
    _arrowMarker setMarkerColor "colorOPFOR";
    _arrowMarker setMarkerText "CATK";
    _arrowMarker setMarkerDir (_defPos getDir _atkPos);

    // private _unitMarker = [objNull, _defPos getPos [500, _defPos getdir _atkPos], "o_b_armor_pl", "Mech Btl.", "colorOPFOR", 0.8] call dyn_spawn_intel_markers;
    // private _areaMarker = [objNull, _defPos getPos [500, _defPos getdir _atkPos], "colorOpfor", 800] call dyn_spawn_intel_markers_area;
    [_defPos getPos [500, _defPos getdir _atkPos], 800, "Assembly Area"] call dyn_draw_mil_symbol_objectiv_free;

    sleep _waitTime;
    // sleep 2;

    [playerSide, "HQ"] sideChat format ["SPOTREP: Soviet MotRifBtl at GRID: %1 advancing towards %2", mapGridPosition _defPos, [round (_defPos getDir _atkPos)] call dyn_get_cardinal];


    sleep 10;

    [6, "heavy", true] spawn dyn_arty;
    [10] spawn dyn_arty;

        // [_defPos, _defPos getDir _atkPos] spawn dyn_air_attack;
    _fireSupport = selectRandom [1,1,1,1,2,2,2,4,4,5,6];
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

    _waves = [1, 2] call BIS_fnc_randomInt;
    [objNull, _atkPos, _spawnPos, [1, 2] call BIS_fnc_randomInt, [1, 2] call BIS_fnc_randomInt, true, [dyn_standart_light_amored_vic], dyn_standart_light_amored_vics - [dyn_standart_light_amored_vic]] spawn dyn_spawn_atk_simple;

    for "_i" from 1 to _waves do {

        _time = time + 60 + (120 * _i);
        waitUntil {sleep 1; time >= _time and (count (allGroups select {(side (leader _x)) isEqualTo east})) <= ((count dyn_opfor_grps) + 15)};

        _units = [_units, [], {_x distance2D _rearPos}, "ASCEND"] call BIS_fnc_sortBy;
        _targetPos = getPos (_units#0);
        _spawnPos = _targetPos getpos [2000, _atkPos getdir _rearPos];

        switch (_mainType) do { 
            case "simple" : {
                [objNull, _atkPos, _spawnPos, 2 + _i, 2 + _i, true] spawn dyn_spawn_atk_simple;
                // [_atkPos, _spawnPos, 1, 1, false] spawn dyn_spawn_atk_complex;
            }; 
            case "complex" : {
                [objNull, _atkPos, _spawnPos, 2, 1, true] spawn dyn_spawn_atk_simple;
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
