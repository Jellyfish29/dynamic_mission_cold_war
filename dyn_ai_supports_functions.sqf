dyn_spawn_smoke = {
    params ["_grp"];

    _sdir = getDir (leader _grp);
    _smokePos = [60 * (sin _sDir), 60 * (cos _sDir), 0] vectorAdd getPos (leader _grp);
    // _smokePos = getPos (leader _grp);
    _smokeGroup = createGroup [sideLogic, true];
    _smoke = _smokeGroup createUnit ["ModuleSmoke_F", _smokePos, [],0 , ""];
    _smoke setVariable ["type", "SmokeShell"]
};


dyn_air_attack = {
    params ["_locPos", "_dir", ["_trg", objNull], ["_type", dyn_attack_heli]];     
    
    // if (true) exitWith {};

    if !(isNull _trg) then {
        waitUntil { sleep 1; triggerActivated _trg };
    };

    private _rearPos = [3000 * (sin (_dir - 180)), 3000 * (cos (_dir - 180)), 0] vectorAdd (getPos dyn_current_location);
    _units = allUnits+vehicles select {side _x == playerSide};
    _units = [_units, [], {_x distance2D _rearPos}, "ASCEND"] call BIS_fnc_sortBy;
    _targetPos = getPos (_units#0);
    _target = _units#0;


    // [getpos player, 0, objNull, dyn_attack_plane] spawn dyn_air_attack

    // _frontPos = [3000 * (sin _dir), 3000 * (cos _dir), 0] vectorAdd _targetPos;

    // for "_i" from 0 to dyn_attack_heli do {

        [_rearPos, _targetPos, _dir, _type, _target] spawn {
            params ["_rearPos", "_targetPos", "_dir", "_type", "_target"];
            private ["_spawnHeight", "_fligthHeight"];

            switch (_type) do { 
                case dyn_attack_heli : {_spawnHeight = 60; _fligthHeight = 40}; 
                case dyn_attack_plane : {_spawnHeight = 500; _fligthHeight = 60}; 
                default {_spawnHeight = 500; _fligthHeight = 60}; 
            };

            _casGroup = createGroup east;
            _p = [_rearPos, _dir, _type, _casGroup] call BIS_fnc_spawnVehicle;
            _plane = _p#0;
            [_plane, _spawnHeight, _rearPos, "ATL"] call BIS_fnc_setHeight;
            _plane forceSpeed 1000;
            _plane flyInHeight _fligthHeight;
            _wp = _casGroup addWaypoint [_targetPos, 0];
            // _wp setWaypointType "SAD";
            _time = time + 300;

            _casGroup reveal _target;
            _plane doTarget _target;
            _plane selectWeapon "rhs_weap_fab500";

            waitUntil {(_plane distance2D (waypointPosition _wp)) <= 800 or time >= _time};

            _plane fireAtTarget [_target, "rhs_weap_fab250"];
            sleep 1;
            _plane fireAtTarget [_target, "rhs_weap_fab250"];

            sleep 10;

            _casGroup setBehaviourStrong "CARELESS";
            _wp = _casGroup addWaypoint [_rearPos, 0];
            _time = time + 300;

            waitUntil {(_plane distance2D (waypointPosition _wp)) <= 200 or time >= _time};

            {
                deleteVehicle _x;
            } forEach (units _casGroup);
            deleteVehicle _plane;
        };
        // sleep 10;
    // };
};

// [O Bravo 1-3:1 (Clemens) (bis_o1),"rhs_weap_fab250","rhs_weap_fab250","rhs_weap_fab250","rhs_ammo_fab250","rhs_mag_fab250",1890033: rhs_m_fab250.p3d,bis_o1]

dyn_spawn_rocket_arty = {
    params ["_pos", "_trg"];

    _pos = _pos findEmptyPosition [0, 250, "cwr3_o_bm21"];
    _grad = "cwr3_o_bm21" createVehicle _pos;
    _grp = createVehicleCrew _grad;
    _gPos = [25,0,0] vectorAdd _pos;
    [_gPos, 0, false, false] spawn dyn_spawn_dimounted_inf;


    waitUntil {sleep 1; triggerActivated _trg};
    _units = allUnits+vehicles select {side _x == west};
    _units = [_units, [], {_x distance2D _grad}, "ASCEND"] call BIS_fnc_sortBy;
    _target = _units#([4, 15] call BIS_fnc_randomInt);
    _targetPos = getPos _target;
    _artyCenter = [[[_targetPos, 200]], [[_targetPos, 80]]] call BIS_fnc_randomPos;
    for "_i" from 0 to ([8, 16] call BIS_fnc_randomInt) do {
        _artyPos = [[[_artyCenter, 200]], [[getPos player, 40]]] call BIS_fnc_randomPos;
        _grad commandArtilleryFire [_artyPos, "CUP_40Rnd_GRAD_HE", 1];
        sleep 2.5;
    };
};


dyn_arty = {
    params ["_shells", ["_type", "heavy"], ["_smoke", false], ["_staticPos", []]];
    private ["_eh", "_cords", "_ammoType", "_gunArray"];

    switch (_type) do { 
        case "heavy" : {_gunArray = dyn_opfor_arty}; 
        case "light" : {_gunArray = dyn_opfor_light_arty};
        case "rocket" : {_gunArray = dyn_opfor_rocket_arty};
        case "rocketffe" : {_gunArray = dyn_opfor_rocket_arty};
        case "balistic" : {_gunArray = dyn_opfor_balistic_arty, _shells = 1};
        default {_gunArray = dyn_opfor_arty}; 
    };


    if (_staticPos isEqualTo []) then {
        _target = selectRandom (allUnits select {side _x == west});
        _cords = getPos _target;
    }
    else
    {
        _cords = _staticPos;
    };
    if (_type != "rocketffe") then {
        for "_i" from 1 to _shells do {
            {
                if (isNull _x) exitWith {};
                _ammoType = (getArray (configFile >> "CfgVehicles" >> typeOf _x >> "Turrets" >> "MainTurret" >> "magazines")) select 0;
                if (_smoke) then {
                    _ammoType = (getArray (configFile >> "CfgVehicles" >> typeOf _x >> "Turrets" >> "MainTurret" >> "magazines") select {["smoke", _x] call BIS_fnc_inString})#0;
                };
                if (isNil "_ammoType") exitWith {};
                _firePos = [[[_cords, 350]], [[position player, 100]]] call BIS_fnc_randomPos;
                // player sidechat str (_firePos inRangeOfArtillery [[_x], _ammoType]);
                _x commandArtilleryFire [_firePos, _ammoType, 1];
                _x setVariable ["dyn_waiting_for_fired", true];
                _eh = _x addEventHandler ["Fired", {
                    params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
                    _unit setVariable ["dyn_waiting_for_fired", false];
                }];
                // sleep 1;
            } forEach _gunArray;
            sleep 1;
            _time = time + 10;
            waitUntil {({_x getVariable ["dyn_waiting_for_fired", true]} count _gunArray) == 0 or time >= _time};
            sleep 1;
        };
    } else {
        {
            if (isNull _x) exitWith {};
            _ammoType = (getArray (configFile >> "CfgVehicles" >> typeOf _x >> "Turrets" >> "MainTurret" >> "magazines")) select 0;
            if (isNil "_ammoType") exitWith {};
            _firePos = [[[_cords, 450]], [[_cords, 25]]] call BIS_fnc_randomPos;
            _x commandArtilleryFire [_firePos, _ammoType, 10];
            sleep 1;
        } forEach _gunArray;
    };

    sleep 20;

    {
        _ammoType = (getArray (configFile >> "CfgVehicles" >> typeOf _x >> "Turrets" >> "MainTurret" >> "magazines")) select 0;
        _x addMagazineTurret [_ammoType, [-1]];
        if !(isNil "_eh") then {
            _x removeEventHandler ["Fired", _eh];
        };
        _x setVehicleAmmo 1;
    } forEach _gunArray;
};

// [20, "rocket"] call dyn_arty;

dyn_spawn_harresment_arty = {
    params ["_locPos", "_dir", "_endTrg"];

    _trgPos = _locPos getPos [2000, _dir];
    private _atkTrg = createTrigger ["EmptyDetector", _trgPos, true];
    _atkTrg setTriggerActivation ["WEST", "PRESENT", false];
    _atkTrg setTriggerStatements ["this", " ", " "];
    _atkTrg setTriggerArea [4000, 65, _dir, true, 30];

    // debug
    // _m = createMarker [str (random 1), _trgPos];
    // _m setMarkerType "mil_dot";

    waitUntil { sleep 1; triggerActivated _atkTrg };

    while {!triggerActivated _endTrg} do {
        sleep ([200, 400] call BIS_fnc_randomInt);
        [3, "light"] call dyn_arty;
    };
};


dyn_continous_support = {
    params ["_activationTrg", "_endTrg", "_dir"];

    if (isNull dyn_next_location) exitWith {hint "no next loc"};

    if !(isNull _activationTrg) then {
        waitUntil{sleep 1; triggerActivated _activationTrg};
        sleep ([10, 40] call BIS_fnc_randomInt);
    };

    while {!triggerActivated _endTrg} do {

        _fireSupport = selectRandom [0,0,1,1,1,2,2,2,2,2,2,2,2,2,4,4,4,4,5,5,5,5,5];

        switch (_fireSupport) do {
            case 0 : {}; 
            case 1 : {[5, "light"] spawn dyn_arty}; 
            case 2 : {[4, "heavy"] spawn dyn_arty};
            case 3 : {[getPos _endTrg, _dir, objNull] spawn dyn_air_attack};
            case 4 : {[getPos _endTrg, _dir, objNull, dyn_attack_plane] spawn dyn_air_attack};
            case 5 : {[6, "rocket"] spawn dyn_arty};
            default {}; 
         }; 
        sleep ([200, 400] call BIS_fnc_randomInt);
    };
};


dyn_continous_counterattack = {
    params ["_activationTrg", "_endTrg", "_dir"];

    if (isNull dyn_next_location) exitWith {hint "no next loc"};

    if !(isNull _activationTrg) then {
        // _m = createMarker [str (random 1), getPos _activationTrg];
        // _m setMarkerType "mil_marker"; 
        waitUntil{sleep 1; triggerActivated _activationTrg};
        // sleep ([20, 80] call BIS_fnc_randomInt);
    };

    sleep ([600, 1200] call BIS_fnc_randomInt);

    while {!triggerActivated _endTrg} do {

        _westUnits = allUnits select {side _x == west};
        _westUnits = [_westUnits, [], {_x distance2D (getPos _endTrg)}, "ASCEND"] call BIS_fnc_sortBy;
        _atkPos = getPos (_westUnits#0);
        private _rearDir = (getpos dyn_current_location) getdir (getPos dyn_next_location);
        private _rearPos = (getPos _endTrg) getPos [2500, _rearDir + (selectRandom [10, -10])];

        _atkType = selectRandom [-1,-1,-1,-1,0,0,0,0,0,0,0,1,1,1,1,1,1,1,2,2,2,2,2,3,3,4];
        _atkType = 4;
        switch (_atkType) do {
            case -1 : {}; 
            case 0 : {
                _fireSupport = selectRandom [1,1,1,2,2,3,3,4,4,5,6];
                switch (_fireSupport) do { 
                    case 1 : {[8, "rocket"] spawn dyn_arty}; 
                    case 2 : {[8] spawn dyn_arty};
                    case 3 : {[_locPos, _dir] spawn dyn_spawn_heli_attack};
                    case 4 : {[_locPos, _dir, objNull, dyn_attack_plane] spawn dyn_air_attack};
                    case 5 : {[8, "rocketffe"] spawn dyn_arty};
                    case 6 : {[8, "balistic"] spawn dyn_arty};
                    default {}; 
                 }; 
            };  
            case 1 : {
                if (((getPos dyn_current_location) distance2D (getPos dyn_next_location)) < 3500) then {
                    _rearPos = (getPos dyn_next_location) getPos [500, (_rearDir + (selectRandom [20, -20])) - 180];
                };
                [_atkPos, _rearPos, 2, 0, false, [dyn_standart_light_amored_vic]] spawn dyn_spawn_atk_complex;
            }; 
            case 2 : {
                if (((getPos dyn_current_location) distance2D (getPos dyn_next_location)) < 3500) then {
                    _rearPos = (getPos dyn_next_location) getPos [500, (_rearDir + (selectRandom [20, -20])) - 180];
                };
                [_atkPos, _rearPos, 1, 1, false] spawn dyn_spawn_atk_complex;
            };
            case 3 : {
                if (((getPos dyn_current_location) distance2D (getPos dyn_next_location)) < 3500) then {
                    _rearPos = (getPos dyn_next_location) getPos [500, (_rearDir + (selectRandom [20, -20])) - 180];
                };
                [_atkPos, _rearPos, 2, 1, false] spawn dyn_spawn_atk_complex;
            };
            case 4 : {
                _rearPos = (getPos _endTrg) getPos [1500, _rearDir + (selectRandom [10, -10])];
                [objNull, _atkPos, _rearPos, 2, 1, true] spawn dyn_spawn_atk_simple;
            };
            default {}; 
         }; 

        sleep ([1000, 1800] call BIS_fnc_randomInt);
    };
};

dyn_spawn_mine_field = {
    params ["_startPos", "_length", "_dir", ["_isObj", false], ["_mineSpacing", 20], ["_mineRows", 3], ["_revealMines", true], ["_rowSpacing", 20], ["_readTerrain", []]];

    private _allMines = [];
    if (_readTerrain isEqualTo []) then {
        _startPos = _startPos getPos [20, _dir - 180];
    } else {
            _clearings = _readTerrain#0;
        if !(_clearings isEqualTo []) then {
            private _lagestClearing = [];
            private _limit = 0;
            {
                if ((count _x) > _limit) then {
                    _lagestClearing = _x;
                    _limit = count _x;
                };
            } forEach _clearings;

            _startPos = [_lagestClearing] call dyn_find_centroid_of_points;
            _startPos = _startPos getPos [_rowSpacing * _mineRows / 2, _dir];
        };
    };

    for "_j" from 0 to _mineRows - 1 do {
        _minesAmount = round (_length / _mineSpacing);
        _offset = 0;
        for "_i" from 0 to _minesAmount do {
            _minePos = _startPos getPos [_offset, _dir + 90];
            if (_i % 2 == 0) then {
                _minePos = _startPos getPos [_offset, _dir - 90];
                _offset = _offset + _mineSpacing;
            };

            _mine = createMine ["ATMine", _minePos, [], 0];
            _mine enableDynamicSimulation true;
            _allMines pushBack _mine;

            // debug
            // _m = createMarker [str (random 5), _minePos];
            // _m setMarkerType "mil_dot";
            // _m setMarkerSize [0.5, 0.5];
        };
        _mineSpacing = _mineSpacing * 0.66;
        _startPos = _startPos getPos [_rowSpacing, _dir - 180];
    };

    if (_isObj) then {
        if ((random 1) > 0.25) then {
            [_startPos getPos [[200, 400] call BIS_fnc_randomInt, _dir - 180], _dir] spawn dyn_spawn_screen;
        };

        if ((random 1) > 0.25) then {
            _reservePos = _startPos getpos [[200, 400] call BIS_fnc_randomInt, _dir -90];
            0 = [_reservePos getPos [[300, 600] call BIS_fnc_randomInt, _dir + 90], _dir, false, false, false, true, true, selectRandom [dyn_standart_squad, dyn_standart_at_team, dyn_standart_fire_team], [], true] call dyn_spawn_covered_inf;
            if ((random 1) > 0.25) then {
                0 = [_reservePos getPos [[300, 600] call BIS_fnc_randomInt, _dir - 90], _dir, false, false, false, true, true, selectRandom [dyn_standart_squad, dyn_standart_at_team, dyn_standart_fire_team], [], true] call dyn_spawn_covered_inf;
            };
        };

        if ((random 1) > 0.2) then {
            _strongPos1 = _startPos getPos [[-400, 400] call BIS_fnc_randomInt, _dir + (90 + ([-10, 10] call BIS_fnc_randomInt))];
            0 = [_strongPos1, _dir] call dyn_spawn_trench_strong_point;
            if ((random 1) > 0.35) then {
                0 = [_strongPos1 getPos [[300, 600] call BIS_fnc_randomInt, _dir + 90], _dir, false, false, false, true, true, selectRandom [dyn_standart_squad, dyn_standart_at_team, dyn_standart_fire_team], [], true] call dyn_spawn_covered_inf;
                0 = [_strongPos1 getPos [[300, 600] call BIS_fnc_randomInt, _dir - 90], _dir, false, false, false, true, true, selectRandom [dyn_standart_squad, dyn_standart_at_team, dyn_standart_fire_team], [], true] call dyn_spawn_covered_inf;
            };
        };

        if (_revealMines) then {
            [_startPos, [900, 1200] call BIS_fnc_randomInt, _dir, 20] call dyn_draw_mil_symbol_fortification_line;
        };

        _forestEdges = _readTerrain#1;
        0 = ([_startPos, _forestEdges, 4, 1000] call dyn_spawn_forest_edge_trench);

        _forestCenters = _readTerrain#2;

        if ((count _forestCenters) > 2) then {

            0 = [[_forestCenters] call dyn_pop_random, _dir, false, false, false, true, true, selectRandom [dyn_standart_squad, dyn_standart_at_team, dyn_standart_fire_team], [], true] call dyn_spawn_covered_inf;
            0 = [[_forestCenters] call dyn_pop_random, _dir, false, false, false, true, true, selectRandom [dyn_standart_squad, dyn_standart_at_team, dyn_standart_fire_team], [], true] call dyn_spawn_covered_inf;
        };

        [objNull, getPos dyn_current_location, 800, _startPos, 2] spawn dyn_spawn_side_town_guards;
    };

    [_allMines, _startPos, _dir, _length, _isObj, _revealMines] spawn {
        params ["_allMines", "_startPos", "_dir", "_length", "_isObj", "_revealMines"];

        sleep 2;

        _mineCount = count _allMines;

        waitUntil {sleep 5; ({alive _x} count _allMines) < _mineCount};

        // if (_revealMines) then {
        //     [objNull, _startPos, "colorRed", (_length / 2) + 20, 0.1, _dir, "RECTANGLE", "SolidFull", 0.5] call dyn_spawn_intel_markers_area;
        // };
        // [objNull, _startPos, "hd_warning", "Mine Field", "colorRED"] call dyn_spawn_intel_markers;

        if (_isObj) then {

            sleep ([20, 240] call BIS_fnc_randomInt);

            [[5, 10] call BIS_fnc_randomInt, "rocket"] spawn dyn_arty;
            [[5, 10] call BIS_fnc_randomInt, "heavy"] spawn dyn_arty;

            _rearPos = _startPos getPos [1000, _dir - 180];
            if ((random 1) > 0.35) then {
                sleep ([180, 200] call BIS_fnc_randomInt);
                [objNull, _startPos getPos [100, _dir - 180], _rearPos, [3, 4] call BIS_fnc_randomInt, [2, 3] call BIS_fnc_randomInt] spawn dyn_spawn_atk_simple;
            } else {
                sleep ([240, 600] call BIS_fnc_randomInt);
                [[5, 10] call BIS_fnc_randomInt, "heavy"] spawn dyn_arty;
                [8, "rocketffe"] spawn dyn_arty
            };
        };
    };

    [_allMines, _startPos, _dir] spawn {
        params ["_allMines", "_startPos", "_dir"];

        _trg = createTrigger ["EmptyDetector", _startPos getPos [3000, _dir - 180], true];
        _trg setTriggerActivation ["WEST", "PRESENT", false];
        _trg setTriggerStatements ["this", " ", " "];
        _trg setTriggerArea [6000, 30, _dir, false, 30];

        waitUntil {sleep 2; triggerActivated _trg};

        {
            deleteVehicle _x;
        } forEach _allMines;
    }
};