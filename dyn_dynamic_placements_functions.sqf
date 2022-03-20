dyn_retreat = {
    params ["_trg", "_dest", "_grps", ["_arty", true]];

    if !(isNull _trg) then {
        waitUntil {sleep 1; triggerActivated _trg};
    };


    if (((random 1) > 0.4) and _arty) then {[6] spawn dyn_arty};

    private _allUnits = [];

    _i = 0;
    _distance = 40;
    {
        _grp = _x;
        _grp setVariable ["dyn_is_retreating", true];
        _grp setVariable ["pl_opfor_retreat", true];
        _grp enableDynamicSimulation false;
        if (vehicle (leader _grp) != leader _grp) then {
            vehicle (leader _grp) setFuel 1;
            [vehicle (leader _grp), "SmokeLauncher"] call BIS_fnc_fire;
        };

        {
            _x enableAI "PATH";
            _x doFollow (leader _grp);
            _x disableAI "AUTOCOMBAT";
            _x setUnitPos "UP";
            _x setUnitPos "AUTO";
            _x disableAI "TARGET";
            _x disableAI "AUTOTARGET";
            _x disableAI "SUPPRESSION";
            _x setCombatBehaviour "AWARE";
            _allUnits pushBack _x;
        } forEach (units _grp);

        // [_grp] call dyn_spawn_smoke;
        [_grp, (currentWaypoint _grp)] setWaypointType "MOVE";
        [_grp, (currentWaypoint _grp)] setWaypointPosition [getPosASL (leader _grp), -1];
        sleep 0.1;
        deleteWaypoint [_grp, (currentWaypoint _grp)];
        for "_i" from count waypoints _grp - 1 to 0 step -1 do {
            deleteWaypoint [_grp, _i];
        };

        _dir = (leader _x) getDir _dest;

        _nDir = _dir - 90;
        if (_i % 2 == 0) then {
            _nDir = _dir + 90;
            _distance = 70 * _i;
        };
        _retreatPos = [_distance * (sin _nDir), _distance * (cos _nDir), 0] vectorAdd _dest;
        _i = _i + 1;


        _grp addWaypoint [_retreatPos, 100];

        [_grp, _retreatPos] spawn {
            params ["_grp", "_retreatPos"];

            waitUntil { sleep 10; [units _grp] call dyn_forget_targets; (leader _grp) distance2D _retreatPos < 100};
            _grp setVariable ["pl_opfor_retreat", false];

            {
                _x doFollow (leader _grp);
                _x setUnitPos "AUTO";
                _x enableAI "AUTOCOMBAT";
                _x enableAI "TARGET";
                _x enableAI "AUTOTARGET";
                _x enableAI "SUPPRESSION";
            } forEach (units _grp);

            if (pl_opfor_enhanced_ai) then {
                if (vehicle (leader _grp) == (leader _grp)) then {
                    _grp execFSM "\Plmod\fsm\pl_opfor_cmd.fsm";
                } else {
                    _grp execFSM "\Plmod\fsm\pl_opfor_cmd_vic.fsm";
                };
            };
        };
    } forEach _grps;
};





dyn_spawn_delay_action = {
    params ["_defPos", "_allGrps", ["_trg", objNull], ["_distance", 400]];

    if !(isNull _trg) then {
        waitUntil { sleep 1; triggerActivated _trg };
    };

    // [4, "heavy", true] spawn dyn_arty;

    {
        private _grp = _x;
        private _dir = _defPos getDir (leader _grp);
        private _atkPos = getPos (leader _grp);
        private _retreatPos = _atkPos getPos [_distance, (_dir - 180) + ([-20, 20] call BIS_fnc_randomInt)];

        [_grp] call dyn_spawn_smoke;
        [_grp, (currentWaypoint _grp)] setWaypointType "MOVE";
        [_grp, (currentWaypoint _grp)] setWaypointPosition [getPosASL (leader _grp), -1];
        sleep 0.1;
        deleteWaypoint [_grp, (currentWaypoint _grp)];
        for "_i" from count waypoints _grp - 1 to 0 step -1 do {
            deleteWaypoint [_grp, _i];
        };


        _grp setVariable ["dyn_is_retreating", true];
        _grp setVariable ["pl_opfor_retreat", true];

        {
            _x disableAI "AUTOCOMBAT";
            // _x disableAI "FSM";
            _x disableAI "AUTOTARGET";
            _x disableAI "TARGET";
            _x enableAI "PATH";
            _x doFollow (leader _grp);
            _x setUnitPos "Auto";
            _x setCombatBehaviour "AWARE";
        } forEach (units _grp);
        // _grp setBehaviour "AWARE";
        if (vehicle (leader _grp) != (leader _grp)) then {
            _vic = vehicle (leader _grp);
            _vic setFuel 1;
            [_vic, "SmokeLauncher"] call BIS_fnc_fire;
            _grp setBehaviour "COMBAT";
        };

        _wp = _grp addWaypoint [_retreatPos, 0];
        vehicle (leader _grp) doMove _retreatPos;
        [_grp, _atkPos, _wp, _dir] spawn {
            params ["_grp", "_atkPos", "_wp", "_atkDir"];

            waitUntil {sleep 1; ({alive _x} count (units _grp)) <= 0 or ((leader _grp) distance2D (waypointPosition _wp)) <= 70};
            [_grp, (currentWaypoint _grp)] setWaypointType "MOVE";
            [_grp, (currentWaypoint _grp)] setWaypointPosition [getPosASL (leader _grp), -1];
            sleep 0.1;
            deleteWaypoint [_grp, (currentWaypoint _grp)];
            for "_i" from count waypoints _grp - 1 to 0 step -1 do {
                deleteWaypoint [_grp, _i];
            };
            {
                _x doFollow (leader _grp);
                _x setUnitPos "AUTO";
                _x enableAI "AUTOCOMBAT";
                _x enableAI "TARGET";
                _x enableAI "AUTOTARGET";
                _x enableAI "SUPPRESSION";
            } forEach (units _grp);

            sleep 1;

            if (vehicle (leader _grp) != leader _grp) then {
                _movepos = [vehicle (leader _grp), _atkDir] call dyn_get_turn_vehicle;
                (vehicle (leader _grp)) doMove _movePos;
            } else {
                _grp setFormDir _atkDir;
            };
            // _aWp setWaypointType "SAD";
            if (pl_opfor_enhanced_ai) then {
                _grp setVariable ["pl_opfor_ai_enabled", true];
                if (vehicle (leader _grp) == (leader _grp)) then {
                    _grp execFSM "\Plmod\fsm\pl_opfor_cmd.fsm";
                } else {
                    _grp execFSM "\Plmod\fsm\pl_opfor_cmd_vic.fsm";
                };
            };
            
        };

    } forEach _allGrps;

    // [5, "rocket"] spawn dyn_arty;
};

dyn_spawn_def_waves = {
    params ["_trg", "_building", "_endTrg"];

    private _pos = getPos _building;
    _vicType = dyn_standart_trasnport_vehicles#1;
    _vDir = (getDir _building) + 90;
    _xMax = ((boundingBox _building)#1)#0;
    _vicPos = [(_xMax + 7) * (sin _vDir), (_xMax + 7) * (cos _vDir), 0] vectorAdd (getPos _building);
    // _tVic = _vicType createVehicle _vicPos;
    _tVic = createVehicle [_vicType, _vicPos, [], 0, "NONE"];
    _tVic setDir _vDir;
    sleep 1;
    if (alive _tVic) then {
        _net = createVehicle ["land_gm_camonet_02_east", getPosATL _tVic, [], 0, "CAN_COLLIDE"];
        _net setVectorUp surfaceNormal position _net;
        _net setDir getDir _tVic;

        // _tPos = [10 * (sin _vDir), 10 * (cos _vDir), 0] vectorAdd (getPos _tVic);
        // [_tPos, _vDir] spawn dyn_spawn_small_trench;

        _spawnEndTrg = createTrigger ["EmptyDetector", getPos _tVic, true];
        _spawnEndTrg setTriggerActivation ["WEST", "PRESENT", false];
        _spawnEndTrg setTriggerStatements ["this", " ", " "];
        _spawnEndTrg setTriggerArea [100, 100, 0, false, 30];

        waitUntil {sleep 1; triggerActivated _trg};

        while {!(triggerActivated _spawnEndTrg) and !(triggerActivated _endTrg)} do {
            _grp = [_pos, east, dyn_standart_squad] call BIS_fnc_spawnGroup;
            // _grp setFormation "DIAMOND";
            _grp setCombatMode "RED";
            {
                _x disableAI "AUTOCOMBAT";
                _x moveInCargo _tVic;
            } forEach (units _grp);
            // [_building, _grp, 0] spawn dyn_garrison_building;
            [_grp] call dyn_opfor_change_uniform_grp;
            sleep 5;
            _grp leaveVehicle _tVic;
            [objNull, [_grp]] spawn dyn_attack_nearest_enemy;
            sleep ([600, 900] call BIS_fnc_randomInt);
        };
    };                                                                                                                                                                                                                                                                                                       
};


dyn_spawn_supply_convoy = { 
    params ["_trg", "_hqPos"];

    if !(isNull _trg) then {
        waitUntil {sleep 1, triggerActivated _trg};
    };

    private _dir = player getDir _hqPos;

    private _spawnDir = _dir + ([-90, 90] call BIS_fnc_randomInt);
    private _rearPos = _hqPos getPos [2000, _spawnDir];

    private _targetRoad = [_hqPos, 1000] call BIS_fnc_nearestRoad;
    private _rearRoad = [_rearPos, 1000] call BIS_fnc_nearestRoad;

    private _vicTypes = dyn_standart_trasnport_vehicles + [dyn_standart_light_amored_vic] + dyn_hq_vehicles + dyn_standart_supply_vics;

    if (!(isnull _targetRoad) and !(isNull _rearRoad)) then {

        private _supplyGrps = [];
        private _infGrps = [];
        private _road = _rearRoad;
        for "_i" from 0 to ([2, 4] call BIS_fnc_randomInt) do {
            _road = ((roadsConnectedTo _road) - [_road]) select 0;
            _roadPos = getPos _road;
            _info = getRoadInfo _road;    
            _endings = [_info#6, _info#7];
            _endings = [_endings, [], {_x distance2D player}, "ASCEND"] call BIS_fnc_sortBy;
            _dir = (_endings#1) getDir (_endings#0);
            _vic = createVehicle [selectRandom _vicTypes, _roadPos, [], 0, "CAN_COLLIDE"];
            _grp = createVehicleCrew _vic;
            _vic setDir _dir;
            _supplyGrps pushBack _grp;
            _transportCap = getNumber (configFile >> "cfgVehicles" >> typeOf _vic >> "transportSoldier");
            if (_transportCap >= 4) then {
                _infGrp = [[0,0,0], east, dyn_standart_fire_team] call BIS_fnc_spawnGroup;
                _infGrp addVehicle _vic,
                _infGrps pushBack _infGrp;
                {
                    _x moveInCargo _vic;
                } forEach (units _infGrp);
                sleep 0.2;
                {
                    if (vehicle _x == _x) then {
                        deleteVehicle _x;
                    };
                } forEach (units _infGrp);
            };
        };

        [_supplyGrps, getpos _targetRoad] spawn dyn_convoy;

        waitUntil {sleep 1; ({alive (leader _x)} count _supplyGrps) < (count _supplyGrps) or ({(leader _x) distance2D (getpos _targetRoad) < 100} count _supplyGrps) > 0};

        {
            _x leaveVehicle (vehicle (leader _x));
        } forEach _infGrps;

    };
};

// [objNull, getMarkerPos "target"] spawn dyn_spawn_supply_convoy;


dyn_spawn_qrf = {
    params ["_trg", "_qrfPos", "_area", "_amount"];

    waitUntil {sleep 1; triggerActivated _trg};


    private _atkPos = {
        if ((_x distance2D _qrfPos) < _area) exitWith {getPos _x};
    } forEach (allUnits+vehicles select {side _x == west});


    private _qrf = [];
    for "_i" from 0 to (_amount - 1) do {
        _sPos = _qrfPos findEmptyPosition [0, 60];
        _grp = [_sPos, east, dyn_standart_fire_team] call BIS_fnc_spawnGroup;
        _qrf pushBack _grp;
        _grp setFormation "LINE";
        _grp setSpeedMode "FULL";
        {
            _x disableAI "AUTOCOMBAT";
        } forEach (units _grp);
    };

    sleep 5;
    {
        _x addWaypoint [_atkPos, 50];
        (vehicle (leader _x)) limitSpeed 15;
    } forEach _qrf;
    _qrf
};

dyn_spawn_qrf_patrol = {
    params ["_townPos", "_area", "_qrfTrg", "_amount"];

    private _PatrolGrps = [];
    private _roads = _townPos nearRoads _area;
    for "_i" from 1 to _amount do {
        _sPos = getPos (selectRandom _roads);
        _grp = [_sPos, east, dyn_standart_fire_team] call BIS_fnc_spawnGroup;
        _PatrolGrps pushBack _grp;
        // _grp enableDynamicSimulation true;
    };
    [_qrfTrg, _PatrolGrps] spawn dyn_attack_nearest_enemy;
};

dyn_spawn_atk_simple = {
    params ["_trg", "_atkPos", "_rearPos", "_inf", "_tank", ["_mech", false], ["_mechVics", dyn_standart_mechs], ["_tankVics", dyn_standart_tanks]];
    private ["_spawnPos", "_spawnPosFinal"];

    if !(isNull _trg) then {
        waitUntil {sleep 1; triggerActivated _trg};
    };

    private _tankType = selectRandom _tankVics;
    private _mechType = selectRandom _mechVics;

    private _atkDir = _rearPos getDir _atkPos;

    private _infGrps = [];
    private _tankGrps = [];
    private _offset = 0;
    private _offsetStep = 30;
    for "_i" from 0 to _inf - 1 do {
        if (_i % 2 == 0) then {
            _spawnPos = _rearPos getPos [_offset, _atkDir + 90];
        } else {
            _spawnPos = _rearPos getPos [_offset, _atkDir - 90];
        };
        _offset = _offset + _offsetStep;
        _spawnPosFinal = [_spawnPos, 0, 90, 0, 0, 0, 0, [], [_spawnPos, []]] call BIS_fnc_findSafePos;
        _infGrp = [_spawnPosFinal, east, dyn_standart_squad,[],[],[],[],[], _atkDir] call BIS_fnc_spawnGroup;
        // [_infGrp] call dyn_opfor_change_uniform_grp;
        

        if (_mech and !([_spawnPosFinal] call dyn_is_forest)) then {
            _vic = _mechType createVehicle _spawnPosFinal;
            _mechGrp = createVehicleCrew _vic;
            _infGrps pushBack _mechGrp;
            {
                _x moveInCargo _vic;
            } forEach (units _infGrp);
            sleep 0.2;
            {
                if (vehicle _x == _x) then {
                    deleteVehicle _x;
                };
            } forEach (units _infGrp);
            private _step = (_vic distance2D _atkPos) / 3;
            _wpPos = getPos _vic;
            for "_j" from 1 to 3 do {
                _wpPos = _wpPos getpos [_step, _atkDir];
                if (!([_wpPos] call dyn_is_forest) and !([_wpPos] call dyn_is_town) or _j == 3) then {
                    _gWp = _mechGrp addWaypoint [_wpPos, 0];
                    if (_j == 3) then {_gWp setWaypointType "SAD"};
                };
            };
        } else {
            _infGrps pushBack _infGrp;
            private _step = ((leader _infGrp) distance2D _atkPos) / 3;
            _wpPos = getPos (leader _infGrp);
            for "_j" from 1 to 3 do {
                _wpPos = _wpPos getpos [_step, _atkDir];
                _gWp = _infGrp addWaypoint [_wpPos, 0];
                if (_j == 3) then {_gWp setWaypointType "SAD"};
            };
        };
    };

    private _tankPos = _rearPos getPos [50, _atkDir];
    _offset = 0;
    for "_i" from 0 to _tank - 1 do {
        if (_i % 2 == 0) then {
            _spawnPos = _tankPos getPos [_offset, _atkDir + 90];
        } else {
            _spawnPos = _tankPos getPos [_offset, _atkDir - 90];
        };
        _offset = _offset + _offsetStep;
        _spawnPosFinal = [_spawnPos, 0, 90, 0, 0, 0, 0, [], [_spawnPos, []]] call BIS_fnc_findSafePos;
        if !([_spawnPosFinal] call dyn_is_forest) then {
            _vic = _tankType createVehicle _spawnPosFinal;
            _tankGrp = createVehicleCrew _vic;
            _tankGrps pushBack _tankGrp;

            private _step = (_vic distance2D _atkPos) / 3;
            _wpPos = getPos _vic;
            for "_j" from 1 to 3 do {
                _wpPos = _wpPos getpos [_step, _atkDir];
                if (!([_wpPos] call dyn_is_forest) and !([_wpPos] call dyn_is_town) or _j == 3) then {
                    _gWp = _tankGrp addWaypoint [_wpPos, 0];
                    if (_j == 3) then {_gWp setWaypointType "SAD"};
                };
            };
        };
    };

    private _allGrps = _infGrps + _tankGrps;

    waitUntil {sleep 1; ({alive (leader _x)} count _allGrps) < (round ((count _allGrps) * 0.33))};

    [_rearPos, _allGrps, objNull, 400] spawn dyn_spawn_delay_action;
};

// [objNull, getMarkerPos "atk", getMarkerPos "rear", 4, 4] spawn dyn_spawn_atk_simple;


dyn_spawn_atk_complex = {
    params ["_atkPos", "_rearPos", "_inf", "_tanks", ["_enableRecon", true], ["_mechVics", dyn_standart_mechs], ["_tankVics", dyn_standart_tanks], ["_reconVics", dyn_standart_light_amored_vics]];

    private _tankType = selectRandom _tankVics;
    private _mechType = selectRandom _mechVics;


    //recon -> artillery -> main attack -> retreat / artillery

    private _targetRoad = [_atkPos, 1000] call BIS_fnc_nearestRoad;
    private _rearRoad = [_rearPos, 1000] call BIS_fnc_nearestRoad;

    // _m = createMarker [str (random 1), _targetRoad];
    // _m setMarkerType "mil_marker"; 

    if (!(isnull _targetRoad) and !(isNull _rearRoad)) then {
        if (_enableRecon) then {
            private _reconGrps = [];
            private _reconInfGrp = [];
            private _road = _rearRoad;
            for "_i" from 0 to ([3, 5] call BIS_fnc_randomInt) do {
                _road = ((roadsConnectedTo _road) - [_road]) select 0;
                _roadPos = getPos _road;
                _info = getRoadInfo _road;    
                _endings = [_info#6, _info#7];
                _endings = [_endings, [], {_x distance2D player}, "ASCEND"] call BIS_fnc_sortBy;
                _dir = (_endings#1) getDir (_endings#0);
                _vic = createVehicle [selectRandom _reconVics, _roadPos, [], 0, "CAN_COLLIDE"];
                _grp = createVehicleCrew _vic;
                _vic setDir _dir;
                _reconGrps pushBack _grp;
                _transportCap = getNumber (configFile >> "cfgVehicles" >> typeOf _vic >> "transportSoldier");
                if (_transportCap >= 4) then {
                    _infGrp = [[0,0,0], east, dyn_standart_recon_team] call BIS_fnc_spawnGroup;
                    _infGrp addVehicle _vic,
                    _reconInfGrp pushBack _infGrp;
                    {
                        _x moveInCargo _vic;
                    } forEach (units _infGrp);
                    sleep 0.2;
                    {
                        if (vehicle _x == _x) then {
                            deleteVehicle _x;
                        };
                    } forEach (units _infGrp);
                };
            };
            [_reconGrps, getpos _targetRoad] spawn dyn_convoy;

            waitUntil {sleep 1; ({alive (leader _x)} count _reconGrps) < (count _reconGrps) or ({(leader _x) distance2D (getpos _targetRoad) < 100} count _reconGrps) > 0};

            {
                _x leaveVehicle (vehicle (leader _x));
            } forEach _reconInfGrp;

            {
                vehicle (leader _x) limitSpeed 1000;
            } forEach _reconGrps;

            _targetRoad = [getPos (leader (((_reconGrps) select {alive (leader _x)})#0)), 1000] call BIS_fnc_nearestRoad;

            // _m = createMarker [str (random 1), _targetRoad];
            // _m setMarkerType "mil_marker"; 

            _fireSupport = selectRandom [1,2,2,2,3,4,5];
            switch (_fireSupport) do { 
                case 1 : {[10, "rocket"] spawn dyn_arty}; 
                case 2 : {[10] spawn dyn_arty};
                case 3 : {[_locPos, _dir] spawn dyn_spawn_heli_attack};
                case 4 : {[_locPos, _dir, objNull, dyn_attack_plane] spawn dyn_air_attack};
                case 5 : {[10, "rocketffe"] spawn dyn_arty}; 
                default {}; 
             }; 

            [_rearPos, _reconGrps, objNull, 200] spawn dyn_spawn_delay_action;
        };

        private _atkColumn = [];
        private _allGrps = [];
        private _atkTanks = [];
        private _road = _rearRoad;
        for "_i" from 0 to _tanks do {
            _road = ((roadsConnectedTo _road) - [_road]) select 0;
            _roadPos = getPos _road;
            _info = getRoadInfo _road;    
            _endings = [_info#6, _info#7];
            _endings = [_endings, [], {_x distance2D player}, "ASCEND"] call BIS_fnc_sortBy;
            _dir = (_endings#1) getDir (_endings#0);
            _vic = createVehicle [_tankType, _roadPos, [], 0, "CAN_COLLIDE"];
            _atkTanks pushBack _vic;
            _grp = createVehicleCrew _vic;
            _vic setDir _dir;
            _atkColumn pushBack _grp;
        };

        sleep 4;

        private _atkMech = [];
        for "_i" from 0 to _inf do {
            _road = ((roadsConnectedTo _road) - [_road]) select 0;
            _roadPos = getPos _road;
            _info = getRoadInfo _road;    
            _endings = [_info#6, _info#7];
            _endings = [_endings, [], {_x distance2D player}, "ASCEND"] call BIS_fnc_sortBy;
            _dir = (_endings#1) getDir (_endings#0);
            _vic = createVehicle [_mechType, _roadPos, [], 0, "CAN_COLLIDE"];
            _atkMech pushBack _vic;
            _grp = createVehicleCrew _vic;
            _vic setDir _dir;
            _atkColumn pushBack _grp;
            _infGrp = [[0,0,0], east, dyn_standart_squad] call BIS_fnc_spawnGroup;
            _infGrp addVehicle _vic,
            [_infGrp] call dyn_opfor_change_uniform_grp;
            _allGrps pushBack _infGrp;
            {
                _x moveInCargo _vic;
            } forEach (units _infGrp);
            sleep 0.2;
            {
                if (vehicle _x == _x) then {
                    deleteVehicle _x;
                };
            } forEach (units _infGrp);
        };
        [_atkColumn, getpos _targetRoad] spawn dyn_convoy;

        sleep 10;

        private _atkLeader = leader (([_atkColumn, [], {(leader _x) distance2D _atkPos}, "ASCEND"] call BIS_fnc_sortBy)#0);

        waitUntil {sleep 1; ({alive (leader _x)} count _atkColumn) < (count _atkColumn) or ({(leader _x) distance2D (getpos _targetRoad) < 100} count _atkColumn) > 0};

        private _atkDir = _atkLeader getDir _atkPos;

        private _offset = 0;
        private _offsetStep = 50 - (count _atkColumn);
        private _atkLeaderPos = (getPos _atkLeader) getPos [100, _atkDir];
        private _wpPos = [];
        for "_i" from 0 to (count (_atkTanks select {alive _x})) - 1 do {
            if (_i % 2 == 0) then {
                _wpPos = _atkLeaderPos getPos [_offset, _atkDir + 90];
            } else {
                _wpPos = _atkLeaderPos getPos [_offset, _atkDir - 90];
            };
            _tank = (_atkTanks select {alive _X})#_i;
            
            _offset = _offset + _offsetStep;

            [_tank, _wpPos, _atkDir, _atkPos] spawn {
                params ["_tank", "_wpPos", "_atkDir", "_atkPos"];

                _tank doMove _wpPos;
                _tank setDestination [_wpPos,"VEHICLE PLANNED" , true];
                _tank limitSpeed 30;
                group (driver _tank) setVariable ["dyn_in_convoy", false];
                group (driver _tank) setBehaviourStrong "COMBAT";

                sleep 4;

                group (driver _tank) addWaypoint [_wpPos, 0];

                private _step = (_tank distance2D _atkPos) / 7;
                for "_j" from 1 to 6 do {
                    _wpPos = _wpPos getpos [_step, _atkDir];
                    if (!([_wpPos] call dyn_is_forest) and !([_wpPos] call dyn_is_town) or _j == 6) then {
                        _gWp = group (driver _tank) addWaypoint [_wpPos, 0];
                        if (_j == 6) then {_gWp setWaypointType "SAD"};
                    };
                };
            };
        };

        sleep 1;

        private _atkLeaderPos = (getPos _atkLeader) getPos [10, _atkDir];
        _offset = 0;
        for "_i" from 0 to (count (_atkMech select {alive _x})) - 1 do {
            if (_i % 2 == 0) then {
                _wpPos = _atkLeaderPos getPos [_offset, _atkDir + 90];
            } else {
                _wpPos = _atkLeaderPos getPos [_offset, _atkDir - 90];
            };
            _mech = (_atkMech select {alive _X})#_i;
            _offset = _offset + _offsetStep;

            [_mech, _wpPos, _atkDir, _atkPos] spawn {
                params ["_mech", "_wpPos", "_atkDir", "_atkPos"];

                _mech doMove _wpPos;
                _mech setDestination [_wpPos,"VEHICLE PLANNED" , true];
                _mech limitSpeed 30;
                group (driver _mech) setVariable ["dyn_in_convoy", false];
                group (driver _mech) setBehaviourStrong "COMBAT";

                sleep 4;

                group (driver _mech) addWaypoint [_wpPos, 0];

                private _step = (_mech distance2D _atkPos) / 6;
                for "_j" from 1 to 6 do {
                    _wpPos = _wpPos getpos [_step, _atkDir];
                    if (!([_wpPos] call dyn_is_forest) and !([_wpPos] call dyn_is_town) or _j == 6) then {
                        _gWp = group (driver _mech) addWaypoint [_wpPos, 0];
                        if (_j == 6) then {_gWp setWaypointType "SAD"};
                    };
                };
            };
        };

        _allGrps = _allGrps + _atkColumn;

        waitUntil {sleep 1; ({alive (leader _x)} count _atkColumn) < (round ((count _atkColumn) * 0.33))};

        [_rearPos, _allGrps, objNull, 400] spawn dyn_spawn_delay_action;

        _fireSupport = selectRandom [1,2,5];
        switch (_fireSupport) do { 
            case 1 : {[8, "rocket"] spawn dyn_arty}; 
            case 2 : {[8] spawn dyn_arty};
            case 3 : {[_locPos, _dir] spawn dyn_spawn_heli_attack};
            case 4 : {[_locPos, _dir, objNull, dyn_attack_plane] spawn dyn_air_attack};
            case 5 : {[8, "rocketffe"] spawn dyn_arty};
            default {}; 
         }; 
    };
};

// [getMarkerPos "target", getMarkerPos "rear", 4, 4] spawn dyn_spawn_atk_complex;