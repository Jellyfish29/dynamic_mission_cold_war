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
        [2, "light"] call dyn_arty;
    };
};