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

    _rearPos = _locPos getPos [600, _dir];
    [getPos _atkTrg, _rearPos, 3, 2] spawn dyn_spawn_atk_complex;
};

dyn_forest_defence_edge = {
    params ["_locPos", "_dir", ["_amount", 2]];

    private _lineCenter = _locPos getPos [1000, _dir];
    private _watchPos = _locPos getPos [4000, _dir];

    _accuracy = 100;
    private _lineWidth = 2000;
    private _lineHeight = 1500;
    private _terrain = [_lineCenter getPos [500, _dir], _dir, _lineWidth,_lineHeight, _accuracy] call dyn_terrain_scan;
    
    dyn_terrain = _terrain;
    // forest
    // if ((_terrain#0) < (_accuracy * _accuracy) * 0.15) exitWith {hint "cancel"};

    private _lineStartPos = _lineCenter getPos [_lineWidth / 2, _dir - 90];
    private _positionAmount = 20;
    private _offsetStep = round (_accuracy / _positionAmount);
    private _offset = 0;

    private _terrainGrid = _terrain#3; 

    private _forestPosEdge = [];
    private _forestPosCenter = [];
    private _ii = 0;
    for "_i" from 1 to _positionAmount do {
        _checkGridLine = _terrainGrid#_offset;

        if (((_checkGridLine#0)#1) != "forest") then {
            _ii = 0;
            while {_ii < 99} do {

                _checkPos = _checkGridLine#_ii;
                if ((_checkPos#1) == "forest") exitWith {

                    // _m = createMarker [str (random 4), _checkPos#0];
                    // _m setMarkerType "mil_marker";
                    // _m setMarkerColor "colorRed";

                    _forestPosEdge pushBack [_checkPos#0, "edge"];
                };
                _ii = _ii + 1;
            };
        } else {
            // _m = createMarker [str (random 4), (_checkGridLine#0)#0];
            // _m setMarkerType "mil_marker";
            // _m setMarkerColor "colorBlue";
            _forestPosCenter pushBack [(_checkGridLine#0)#0, "center"];
        };
        _offset = _offset + _offsetStep;
    };

    if (count _forestPosEdge <= 0) exitWith {
        // if (count _forestPosCenter > 3) then {
            // [_locPos, _endTrg, _dir, _forestPosCenter, _watchPos] spawn dyn_forest_defence_center;
        // } else {
            // [_locPos getPos [[1300, 1700] call BIS_fnc_randomInt, _dir], 2000, _dir, true] spawn dyn_spawn_mine_field;
        // };
    };


    _forestPosEdge = [_forestPosEdge, [], {(_x#0) distance2D ((_terrainGrid#50)#50)#0}, "ASCEND"] call BIS_fnc_sortBy;

    if ((count _forestPosEdge) > _amount) then {_forestPosEdge resize _amount};

    for "_j" from 0 to ([1, (count _forestPosEdge) - 1] call BIS_fnc_randomInt) do {

        _spawnPos = (_forestPosEdge#_j)#0;
        _spawnPos = _spawnPos getpos [30, _dir - 180];

        _grp = [_spawnPos, east, dyn_standart_squad] call BIS_fnc_spawnGroup;
        _grp setFormDir _dir;
        (leader _grp) setDir _dir;
        _grp enableDynamicSimulation true;

        if ((random 1) > 0.5) then {
            [_spawnPos getPos [30, _dir + 90], _dir, true, true, selectRandom dyn_standart_statics_atgm] call dyn_spawn_static_weapon;
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
    [getPos _aoPos, _dir, [1, 2] call BIS_fnc_randomInt] spawn dyn_forest_defence_edge;

    // Bridge Defense
    [getPos _aoPos, 1500, 400, _watchPos] spawn dyn_spawn_bridge_defense;

    // side Town Guards
    [_aoPos, getPos _aoPos, 2000, (getPos _aoPos) getPos [2000, _dir]] spawn dyn_spawn_side_town_guards;

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

    // dyn_terrain = _terrain;

    // forest
    if ((_terrain#0) > (_accuracy * _accuracy) * 0.25) exitWith {dyn_defense_active = false};
    // town
    if ((_terrain#1) > (_accuracy * _accuracy) * 0.07) exitWith {dyn_defense_active = false};
    // water
    if ((_terrain#2) > (_accuracy * _accuracy) * 0.025) exitWith {dyn_defense_active = false};

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
    _fireSupport = selectRandom [1,2,2,2,3,4,5,6];
    switch (_fireSupport) do { 
        case 1 : {[10, "rocket"] spawn dyn_arty}; 
        case 2 : {[10] spawn dyn_arty};
        case 3 : {[_locPos, _dir] spawn dyn_spawn_heli_attack};
        case 4 : {[_locPos, _dir, objNull, dyn_attack_plane] spawn dyn_air_attack};
        case 5 : {[10, "rocketffe"] spawn dyn_arty};
        case 6 : {[8, "balistic"] spawn dyn_arty};
        default {}; 
     };

    [_atkPos, _rearPos, 2, 3] spawn dyn_spawn_atk_complex;

    _waves = [2, 2] call BIS_fnc_randomInt;
    // [objNull, _atkPos, _rearPos, 2, 4, true, [dyn_standart_light_amored_vic], dyn_standart_light_amored_vics - [dyn_standart_light_amored_vic]] spawn dyn_spawn_atk_simple;

    for "_i" from 1 to _waves do {

        sleep 120;
        [objNull, _atkPos, _rearPos, 3, 2, true] spawn dyn_spawn_atk_simple;

        _fireSupport = selectRandom [1,1,1,1,2,2,2,3,3];
        switch (_fireSupport) do { 
            case 1 : {[5, "light"] spawn dyn_arty}; 
            case 2 : {[5] spawn dyn_arty};
            case 3 : {[_defPos, _defPos getDir _atkPos, objNull, dyn_attack_plane] spawn dyn_air_attack};
            default {}; 
         }; 
    };

    // player sideChat "spawn end";
    _time = time + 200;
    waitUntil {sleep 1;time >= _time and (count (allGroups select {(side (leader _x)) isEqualTo east})) <= (count dyn_opfor_grps) + 5};

    dyn_intel_markers = [];
    deleteMarker _arrowMarker;
    // deleteMarker _lineMarker;

    _defPos = [400 * (sin (_defPos getDir _atkPos)), 400 * (cos (_defPos getDir _atkPos)), 0] vectorAdd _defPos;

    [objNull, _defPos, allGroups select {(side (leader _x)) isEqualTo east and !(_x in dyn_opfor_grps)}, true] spawn dyn_retreat;

    sleep 60;

    dyn_defense_active = false;

    [format ["defTask%1", _atkPos], "SUCCEEDED", true] call BIS_fnc_taskSetState;

    deleteMarker _unitMarker;
    deleteMarker _areaMarker;
};
