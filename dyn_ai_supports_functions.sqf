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
    params [["_heavy", false]];
    _target = selectRandom (allUnits select {side _x == west});
    _pos = getPos _target;
    _amount = [5, 10] call BIS_fnc_randomInt;
    if (_heavy) then {_amount = _amount / 2};
    _artyGroup = createGroup east;
    for "_i" from 0 to _amount do {
        _artyPos = [[[_pos, 300]], [[_pos, 50]]] call BIS_fnc_randomPos;

        // private _marker = createMarker [str _i, _artyPos];
        // _marker setMarkerShape "ICON";
        // _marker setMarkerColor "colorBLUFOR";
        // _marker setMarkerType "MIL_DOT";
        _support = _artyGroup createUnit ["ModuleOrdnance_F", _artyPos, [],0 , ""];
        if (_heavy) then {
            _support setVariable ["type", "ModuleOrdnanceHowitzer_F_Ammo"];
        }
        else
        {
            _support setVariable ["type", "ModuleOrdnanceMortar_F_Ammo"];
        };
        sleep ([2, 6] call BIS_fnc_randomInt);
    };
};

dyn_spawn_harresment_arty = {
    params ["_locPos", "_dir", "_endTrg"];

    _trgPos = _locPos getPos [2000, _dir];
    private _atkTrg = createTrigger ["EmptyDetector", _trgPos, true];
    _atkTrg setTriggerActivation ["WEST", "PRESENT", false];
    _atkTrg setTriggerStatements ["this", " ", " "];
    _atkTrg setTriggerArea [2500, 65, _dir, true];

    // debug
    // _m = createMarker [str (random 1), _trgPos];
    // _m setMarkerType "mil_dot";

    waitUntil { sleep 1; triggerActivated _atkTrg };

    while {!triggerActivated _endTrg} do {
        sleep ([180, 300] call BIS_fnc_randomInt);
        _target = selectRandom (allUnits select {side _x == west});
        _pos = getPos _target;
        _amount = [3, 5] call BIS_fnc_randomInt;
        _artyGroup = createGroup east;
        for "_i" from 0 to _amount do {
            _artyPos = [[[_pos, 450]], [[_pos, 80]]] call BIS_fnc_randomPos;
            _support = _artyGroup createUnit ["ModuleOrdnance_F", _artyPos, [],0 , ""];
            _support setVariable ["type", "ModuleOrdnanceMortar_F_Ammo"];
            sleep ([7, 15] call BIS_fnc_randomInt);
        };
    };
};