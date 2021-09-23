dyn_spawn_smoke = {
    params ["_grp"];

    _sdir = getDir (leader _grp);
    _smokePos = [60 * (sin _sDir), 60 * (cos _sDir), 0] vectorAdd getPos (leader _grp);
    // _smokePos = getPos (leader _grp);
    _smokeGroup = createGroup east;
    _smoke = _smokeGroup createUnit ["ModuleSmoke_F", _smokePos, [],0 , ""];
    _smoke setVariable ["type", "SmokeShell"]
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

        // for "_i" from 0 to 1 do {

            [_rearPos, _targetPos, _dir] spawn {
                params ["_rearPos", "_targetPos", "_dir"];

                _casGroup = createGroup east;
                _p = [_rearPos, _dir, dyn_attack_heli, _casGroup] call BIS_fnc_spawnVehicle;
                _plane = _p#0;
                [_plane, 40] call BIS_fnc_setHeight;
                // _plane forceSpeed 140;
                _plane flyInHeight 40;
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
            // sleep 10;
        // };
};

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
    params ["_shells", ["_type", "heavy"]];
    private ["_eh", "_cords", "_ammoType", "_gunArray"];

    switch (_type) do { 
        case "heavy" : {_gunArray = dyn_opfor_arty}; 
        case "light" : {_gunArray = dyn_opfor_light_arty};
        case "rocket" : {_gunArray = dyn_opfor_rocket_arty};
        default {_gunArray = dyn_opfor_arty}; 
    };


    for "_i" from 1 to _shells do {
        _target = selectRandom (allUnits select {side _x == west});
        _cords = getPos _target;
        {
            if (isNull _x) exitWith {};
            _ammoType = (getArray (configFile >> "CfgVehicles" >> typeOf _x >> "Turrets" >> "MainTurret" >> "magazines")) select 0;
            _firePos = [[[_cords, 300]], [[_cords, 50]]] call BIS_fnc_randomPos;
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

    sleep 20;

    {
        _ammoType = (getArray (configFile >> "CfgVehicles" >> typeOf _x >> "Turrets" >> "MainTurret" >> "magazines")) select 0;
        _x addMagazineTurret [_ammoType, [-1]];
        _x removeEventHandler ["Fired", _eh];
    } forEach _gunArray;
};

// [10] call dyn_arty;

dyn_spawn_harresment_arty = {
    params ["_locPos", "_dir", "_endTrg"];

    _trgPos = _locPos getPos [2000, _dir];
    private _atkTrg = createTrigger ["EmptyDetector", _trgPos, true];
    _atkTrg setTriggerActivation ["WEST", "PRESENT", false];
    _atkTrg setTriggerStatements ["this", " ", " "];
    _atkTrg setTriggerArea [4000, 65, _dir, true];

    // debug
    // _m = createMarker [str (random 1), _trgPos];
    // _m setMarkerType "mil_dot";

    waitUntil { sleep 1; triggerActivated _atkTrg };

    while {!triggerActivated _endTrg} do {
        sleep ([200, 400] call BIS_fnc_randomInt);
        [3, "light"] call dyn_arty;
    };
};

dyn_air_attack = {
    params ["_dir"];
    private ["_vicPos"];

    _vicPos = getPos (selectRandom (vehicles select {side _x == playerSide and !((getNumber (configFile >> "CfgVehicles" >> typeOf _x >> "artilleryScanner")) == 1)}));
     

    _group = createGroup [east, true];
    {
        _atkPos = _vicPos getPos [_x, _dir + 90];
        _support = _group createUnit ["ModuleCAS_F", _atkPos, [],0 , ""];
        _support setVariable ["vehicle", "O_Plane_Fighter_02_F"];
        _support setVariable ["type", 2];
        _support setDir _dir;
        sleep 3;
    } forEach [0, 70];
};

dyn_continous_support = {
    params ["_activationTrg", "_endTrg", "_dir"];

    if !(isNull _activationTrg) then {
        waitUntil{sleep 1; triggerActivated _activationTrg};
        sleep ([10, 40] call BIS_fnc_randomInt);
    };

    while {!triggerActivated _endTrg} do {

        _fireSupport = selectRandom [1,1,1,2,2,3,4,4,5];

        switch (_fireSupport) do { 
            case 1 : {[6, "light"] spawn dyn_arty}; 
            case 2 : {[3, "heavy"] spawn dyn_arty};
            case 3 : {[getPos _endTrg, _dir, objNull] spawn dyn_spawn_heli_attack};
            case 4 : {[_dir] spawn dyn_air_attack};
            case 5 : {[3, "rocket"] spawn dyn_arty};
            default {}; 
         }; 
        sleep ([200, 400] call BIS_fnc_randomInt);
    };
};


dyn_continous_counterattack = {
    params ["_activationTrg", "_endTrg", "_dir"];

    _atkPos = getPos _activationTrg;

    if !(isNull _activationTrg) then {
        waitUntil{sleep 1; triggerActivated _activationTrg};
        sleep ([20, 80] call BIS_fnc_randomInt);
    };

    while {!triggerActivated _endTrg} do {

        _atkType = selectRandom [0,0,1,1,1,2,2,3,3];

        switch (_atkType) do {
            case 0 : {
                [2] spawn dyn_arty;
            };  
            case 1 : {
                _rearPos = _atkPos getPos [1000, _dir + selectRandom [90, -90, 180]];
                [objNull, _atkPos, _rearPos, 3, 3, 0, false, dyn_standart_light_amored_vics, 0, [false, 100], true, false] spawn dyn_spawn_counter_attack;
            }; 
            case 2 : {
                _rearPos = _atkPos getPos [1200, _dir + selectRandom [90, -90, 180]];
                [objNull, _atkPos, _rearPos, 2, 2, 0, true, dyn_standart_combat_vehicles , 0, [false, 100], true, false] spawn dyn_spawn_counter_attack;
            };
            case 3 : {
                _rearPos = _atkPos getPos [1500, _dir + selectRandom [90, -90, 180]];
                [objNull, _atkPos, _rearPos, 3, 2, 0, true, [dyn_standart_MBT], 0, [false, 100], true, false] spawn dyn_spawn_counter_attack
            };
            default {}; 
         }; 

        sleep ([480, 900] call BIS_fnc_randomInt);
    };
};