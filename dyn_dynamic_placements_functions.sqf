dyn_retreat = {
    params ["_trg", "_dest", "_grps", ["_arty", true]];

    if !(isNull _trg) then {
        waitUntil {sleep 1; triggerActivated _trg};
    };


    if (((random 1) > 0.4) and _arty) then {[2] spawn dyn_arty};

    private _allUnits = [];

    _i = 0;
    _distance = 40;
    {
        _grp = _x;
        _grp setVariable ["dyn_is_retreating", true];
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
            _allUnits pushBack _x;
        } forEach (units _grp);

        [_grp] call dyn_spawn_smoke;
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
        // _grp setFormation "COLUMN";
        _grp setBehaviour "AWARE";
        
    } forEach _grps;

    [_allUnits] call dyn_forget_targets;

    for "_i" from 0 to 20 do {
        sleep 30;
        [_allUnits] call dyn_forget_targets;
    };
};


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
                    _mechType = selectRandom ["cwr3_o_bmp1", "cwr3_o_bmp2"];
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
            [_grp] spawn dyn_select_atk_mode;
            _counterattack pushBack _grp;
            _grp setFormation "VEE";
            _grp setSpeedMode "Normal";
            {
                _x disableAI "AUTOCOMBAT";
            } forEach (units _grp);
            sleep 0.2;
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
                _grp setFormation "LINE";
                _grp setSpeedMode "FULL";
                [_grp] call dyn_opfor_change_uniform_grp;
                {
                    _x disableAI "AUTOCOMBAT";
                    _x disableAI "COVER";
                    _x disableAI "SUPPRESSION";
                } forEach (units _grp);
                if ((random 1) > 0.5) then {[_grp, 400, true] spawn dyn_auto_suppress};
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
                if ((random 1) > 0.5) then {[_grp, 800, false] spawn dyn_auto_suppress};
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
        _x setBehaviour "AWARE";
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
                if (_mech and _i == 4) then {_gWp setWaypointType "UNLOAD"};
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

    if ((random 1) > 0.5) then {[4] spawn dyn_arty};

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


dyn_spawn_delay_action = {
    params ["_defPos", "_allGrps", ["_trg", objNull], ["_distance", 400]];

    if !(isNull _trg) then {
        waitUntil { sleep 1; triggerActivated _trg };
    };

    {
        _grp = _x;
        _dir = _defPos getDir (leader _grp);
        _retreatPos = [_distance * (sin _dir), _distance * (cos _dir), 0] vectorAdd _defPos;
        _atkPos = getPos (leader _grp);

        [_grp] call dyn_spawn_smoke;
        [_grp, (currentWaypoint _grp)] setWaypointType "MOVE";
        [_grp, (currentWaypoint _grp)] setWaypointPosition [getPosASL (leader _grp), -1];
        sleep 0.1;
        deleteWaypoint [_grp, (currentWaypoint _grp)];
        for "_i" from count waypoints _grp - 1 to 0 step -1 do {
            deleteWaypoint [_grp, _i];
        };

        if (vehicle (leader _grp) != (leader _grp)) then {
            _vic = vehicle (leader _grp);
            _vic setFuel 1;
            [_vic, "SmokeLauncher"] call BIS_fnc_fire;
        };

        _grp setVariable ["dyn_is_retreating", true];

        {
            // _x disableAI "AUTOCOMBAT";
            // _x disableAI "FSM";
            _x disableAI "AUTOTARGET";
            _x disableAI "TARGET";
            _x enableAI "PATH";
            _x doFollow (leader _grp);
            _x setUnitPos "Auto";
        } forEach (units _grp);
        // _grp setBehaviour "AWARE";

        _wp = _grp addWaypoint [_retreatPos, 0];
        [_grp, _atkPos, _wp] spawn {
            params ["_grp", "_atkPos", "_wp"];

            waitUntil {sleep 1; ({alive _x} count (units _grp)) <= 0 or ((leader _grp) distance2D (waypointPosition _wp)) <= 70};
            [_grp, (currentWaypoint _grp)] setWaypointType "MOVE";
            [_grp, (currentWaypoint _grp)] setWaypointPosition [getPosASL (leader _grp), -1];
            sleep 0.1;
            deleteWaypoint [_grp, (currentWaypoint _grp)];
            for "_i" from count waypoints _grp - 1 to 0 step -1 do {
                deleteWaypoint [_grp, _i];
            };

            {
                _x enableAI "AUTOTARGET";
                _x enableAI "TARGET";
                _x enableAI "FSM";
            } forEach (units _grp);

            sleep 1;
            _aWp = _grp addWaypoint [_atkPos, 0];
            // _aWp setWaypointType "SAD";
            
        };

    } forEach _allGrps;

    [3] spawn dyn_arty;
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

        _tPos = [10 * (sin _vDir), 10 * (cos _vDir), 0] vectorAdd (getPos _tVic);
        [_tPos, _vDir] spawn dyn_spawn_small_trench;

        _spawnEndTrg = createTrigger ["EmptyDetector", getPos _tVic, true];
        _spawnEndTrg setTriggerActivation ["WEST", "PRESENT", false];
        _spawnEndTrg setTriggerStatements ["this", " ", " "];
        _spawnEndTrg setTriggerArea [100, 100, 0, false];

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

dyn_spawn_heli_attack = {
        params ["_locPos", "_dir", ["_trg", objNull]];

        if !(isNull _trg) then {
            waitUntil { sleep 1; triggerActivated _trg };
        };

        _rearPos = [3000 * (sin (_dir - 180)), 3000 * (cos (_dir - 180)), 0] vectorAdd _locPos;
        _units = allUnits+vehicles select {side _x == west};
        _targetPos = getPos (_units#0);

        // _frontPos = [3000 * (sin _dir), 3000 * (cos _dir), 0] vectorAdd _targetPos;

        for "_i" from 0 to 1 do {

            [_rearPos, _targetPos, _dir] spawn {
                params ["_rearPos", "_targetPos", "_dir"];

                _casGroup = createGroup east;
                _p = [_rearPos, _dir, dyn_attack_heli, _casGroup] call BIS_fnc_spawnVehicle;
                _plane = _p#0;
                [_plane, 60] call BIS_fnc_setHeight;
                // _plane forceSpeed 140;
                _plane flyInHeight 60;
                _wp = _casGroup addWaypoint [_targetPos, 0];
                _time = time + 300;

                waitUntil {(_plane distance2D (waypointPosition _wp)) <= 200 or time >= _time};

                _wp = _casGroup addWaypoint [_rearPos, 0];
                _time = time + 300;

                waitUntil {(_plane distance2D (waypointPosition _wp)) <= 200 or time >= _time};

                {
                    deleteVehicle _x;
                } forEach (units _casGroup);
                deleteVehicle _plane;
            };
            sleep 10;
        };
};

dyn_spawn_supply_convoy = { 
    params ["_trg", "_hqPos", "_dir"];

    _dir = player getDir _hqPos;

    _spawnDir = _dir - ([-90, 90] call BIS_fnc_randomInt);
    _rearPos = [1400 * (sin _spawnDir), 1400 * (cos _spawnDir), 0] vectorAdd _hqPos;

    // debug
    // _m = createMarker [str (random 1), _rearPos];
    // _m setMarkerType "mil_circle"; 

    // _road = [_rearPos, 1000 , ["TRAIL"]] call BIS_fnc_nearestRoad;
    _roads = _rearPos nearRoads 1500;
    _roads = [_roads, [], {(getPos _x) distance2D _rearPos}, "ASCEND"] call BIS_fnc_sortBy;
    _road = _roads#0;
    _usedRoads = [];
    private _vics = [];
    private _grps = [];
    _vicType = selectRandom (dyn_standart_trasnport_vehicles + [dyn_standart_light_amored_vic]);
    for "_i" from 0 to 1 step 1 do {
        _road = ((roadsConnectedTo _road) - [_road]) select 0;
        _vic = vehicle (leader ([getPos _road, 0, [_vicType]] call dyn_spawn_parked_vehicle));
        _vics pushBack _vic;
        _near = roadsConnectedTo _road;
        _near = [_near, [], {(getPos _x) distance2D _hqPos}, "DESCEND"] call BIS_fnc_sortBy;
        _vDir = (getPos (_near#0)) getDir (getPos _road);
        _vic setDir _vDir;
        _grp = [_rearPos, east, dyn_standart_squad] call BIS_fnc_spawnGroup;
        _grp setFormation "DIAMOND";
        {
            _x assignAsCargo _vic;
            _x moveInCargo _vic;
        } forEach (units _grp);
        _vic setVariable ["dyn_supply_con_trasnported_grp", _grp];
    };

    waitUntil {sleep 1, triggerActivated _trg};

    // sleep ([60, 180] call BIS_fnc_randomInt);

    {
        _g = (group (driver _x));
        _wpPos = [[[_hqPos, 50]],[], {isOnRoad _this}] call BIS_fnc_randomPos;
        _wp = _g addWaypoint [_wpPos, 2];
        _wp setWaypointType "UNLOAD";
        _x limitSpeed 35;
        _g setBehaviour "CARELESS";
        [_x, _wp] spawn {
            params ["_vic", "_wp"];
            waitUntil {sleep 1; ((_vic distance2D (waypointPosition _wp)) < 25) or !(alive _vic)};
            doStop _vic;
            sleep 10;
            _tGrp = _vic getVariable ["dyn_supply_con_trasnported_grp", grpNull];
            _tGrp leaveVehicle _vic;
            [objNull, [_tGrp]] spawn dyn_attack_nearest_enemy;
        }; 
    } forEach _vics;
};


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

dyn_spawn_recon_provbe = {
    params ["trg", "_defPos", "_atkPos"];

    if !(isNull _trg) then {
        waitUntil { sleep 1; triggerActivated _trg };
    };
    
};