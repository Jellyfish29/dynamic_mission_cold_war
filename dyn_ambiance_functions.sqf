dyn_civ_vics = ["cwr3_c_gaz24", "cwr3_c_mini", "cwr3_c_rapid", "gm_ge_civ_typ1200"];
dyn_civilian = "cwr3_c_civilian_random";
// dyn_ambient_sound_mod attachTo [player, [0,0,0]];

dyn_random_weather = {
    skipTime -24;
    _overcast = selectRandom [0, 0.1, 0.3, 0.5, 0.8, 0.9, 1];
    // _overcast = 1;
    86400 setOvercast _overcast;
    86400 setFog [selectRandom [0, 0, 0.1, 0.3, 0.5], 0.01, 250];

    skipTime 24;

    if (overcast >= 0.8) then {
        0 setRain (_overcast - 0.3);
        if (_overcast >= 0.95) then {
            0 setLightnings 0.5;
        };
    };

    4800 setFog 0;
    0 = [] spawn {
        sleep 0.1;
        simulWeatherSync;

        while {true} do {
            _overcast = selectRandom [0, 0.1, 0.3, 0.5, 0.8, 0.9, 1];
            1800 setOvercast _overcast;
            if (overcast >= 0.8) then {
                500 setRain (_overcast - 0.3);
                if (_overcast >= 0.95) then {
                    500 setLightnings 0.5;
                } else {
                    500 setLightnings 0;
                };
            } else {
                500 setRain 0;
                500 setLightnings 0;
            };
            sleep 0.1;
            simulWeatherSync;
            sleep 1800;
        };
    };
};

dyn_allied_start_position = {
    
    _startPos = (getPos player) getPos [10, (getDir (vehicle player)) - 180];
    _startDir = (getDir (vehicle player)) - 180;

    _vicGrp = [_startPos, "cwr3_b_m577_hq", _startDir, true, false] call dyn_spawn_covered_vehicle;
    // _infGrp = [_startPos, west, ["cwr3_b_soldier", "cwr3_b_soldier", "cwr3_b_soldier", "cwr3_b_soldier", "cwr3_b_soldier"]] call BIS_fnc_spawnGroup;
    // [_infGrp, _startDir, 10, true, [], 15, false] call dyn_line_form_cover;
    // [_infGrp] call pl_hide_group_icon;
    // _infGrp setVariable ["pl_not_addalbe", true];

    {
        deleteVehicle _x;
    } forEach (units _vicGrp);

    player setPos (_startPos getPos [5, _startDir - 180]);
    player setDir _startDir;

    sleep 2;

    cutText ["<t color='#0030cc' size='5'>Team Yankee!</t><br/>", "PLAIN", -1, true, true];

    [west, "task_getin", ["Offensive", "Get in Vehicle", ""], getPos dyn_player_vic, "CREATED", 1, true, "getin", false] call BIS_fnc_taskCreate;

    waitUntil {sleep 1; (vehicle player) == dyn_player_vic};

    ["task_getin", "SUCCEEDED", true] call BIS_fnc_taskSetState;

};

dyn_allied_arty = {
    params ["_centerPos", "_salvos", "_dispersion"];

    // _centerPos = (getPos player) getPos [400, (getPos player) getdir _enemyPos];

    _artyGroup = createGroup [civilian, true];

    // [playerSide, "HQ"] sideChat format ["Incomming Firemission"];

    // _markerName = createMarker [str (random 1), _centerPos];
    // _markerName setMarkerColor pl_side_color;
    // _markerName setMarkerShape "ELLIPSE";
    // _markerName setMarkerBrush "Border";
    // // _markerName setMarkerAlpha 0.9;
    // _markerName setMarkerSize [_dispersion + 50, _dispersion + 50];

    for "_i" from 1 to _salvos do {
        for "_j" from 1 to 3 do {
            _cords = [[[_centerPos, _dispersion]],[]] call BIS_fnc_randomPos;
            _support = _artyGroup createUnit ["ModuleOrdnance_F", _cords, [],0 , ""];
            _support setVariable ["type", "ModuleOrdnanceHowitzer_F_Ammo"];
            sleep 0.8;
        };
        sleep 2; 
    };

    sleep 5;

    // deleteMarker _markerName;
};

dyn_allied_plane_flyby = {
    params ["_targetPos"];

    for "_i" from 0 to 1 do {

        [_targetPos] spawn {
            params ["_targetPos"];
            _rearPos = _targetPos getpos [(_targetPos distance2D player) + 1500, _targetPos getDir (getPos player)];

            _spawnHeight = 500;
            _fligthHeight = 40; 

            _casGroup = createGroup civilian;
            _p = [_rearPos, player getDir _targetPos, "RHS_A10", _casGroup] call BIS_fnc_spawnVehicle;
            _plane = _p#0;
            [_plane, _spawnHeight, _rearPos, "ATL"] call BIS_fnc_setHeight;
            _plane forceSpeed 1000;
            _plane flyInHeight _fligthHeight;
            _wp = _casGroup addWaypoint [_targetPos, 0];
            // _wp setWaypointType "SAD";
            _time = time + 300;
            _casGroup setBehaviourStrong "CARELESS";

            waitUntil {(_plane distance2D player) <= 400 or time >= _time};

            // _plane fireAtTarget [objNull, "RHS_weap_gau8"];
            _plane fireAtTarget [objNull, "rhs_weap_agm65d"];
            sleep 0.5;
            _plane fireAtTarget [objNull, "rhs_weap_agm65d"];

            sleep 2;

            _rearPos = _rearPos getPos [500, _targetPos getdir _rearPos];
            _wp = _casGroup addWaypoint [_rearPos, 0];
            _time = time + 300;
            // waitUntil {(_plane distance2D (waypointPosition _wp)) <= 800 or time >= _time};


            waitUntil {(_plane distance2D (waypointPosition _wp)) <= 200 or time >= _time};

            {
                deleteVehicle _x;
            } forEach (units _casGroup);
            deleteVehicle _plane;
        };

        sleep 1.5;
    };
};

dyn_allied_heli_flyby = {
    params ["_targetPos"];

    for "_i" from 0 to 1 do {

        [_targetPos] spawn {
            params ["_targetPos"];
            _rearPos = _targetPos getpos [(_targetPos distance2D player) + 800, _targetPos getDir (getPos player)];

            _spawnHeight = 100;
            _fligthHeight = 50; 

            _casGroup = createGroup civilian;
            _p = [_rearPos, player getDir _targetPos, "cwr3_b_ah1f", _casGroup] call BIS_fnc_spawnVehicle;
            _plane = _p#0;
            [_plane, _spawnHeight, _rearPos, "ATL"] call BIS_fnc_setHeight;
            _plane forceSpeed 1000;
            _plane flyInHeight _fligthHeight;
            _wp = _casGroup addWaypoint [_targetPos, 0];
            // _wp setWaypointType "SAD";
            _time = time + 100;
            _casGroup setBehaviourStrong "CARELESS";

            waitUntil {(_plane distance2D player) <= 250 or time >= _time};

            // _plane fireAtTarget [objNull, "RHS_weap_gau8"];
            // _plane fireAtTarget [objNull, "cwr3_vmlauncher_tow_veh"];
            sleep 0.5;
            // _plane fireAtTarget [objNull, "cwr3_vmlauncher_tow_veh"];

            sleep 2;

            _rearPos = _rearPos getPos [500, _targetPos getdir _rearPos];
            _wp = _casGroup addWaypoint [_rearPos, 0];
            _time = time + 100;
            // waitUntil {(_plane distance2D (waypointPosition _wp)) <= 800 or time >= _time};


            waitUntil {(_plane distance2D (waypointPosition _wp)) <= 300 or time >= _time};

            {
                deleteVehicle _x;
            } forEach (units _casGroup);
            deleteVehicle _plane;
        };

        sleep 6;
    };
};

dyn_msr_desolation = {
    params ["_locPos", "_trg"];

    _msr = [[_locPos, 200] call dyn_nearestRoad, [getPos player, 200] call dyn_nearestRoad] call dyn_convoy_parth_find;

    for "_i" from 30 to (count _msr) - 1 step ([20, 30] call BIS_fnc_randomInt) do {

        if ((random 1) > 0.5) then {
            _spawnPos = (getPos (_msr#_i)) getpos [25, (getdir (_msr#_i)) + (selectRandom [90, -90])];

            [_spawnPos, 0, _trg, 0, true] spawn dyn_destroyed_cars;

            // _m = createMarker [str (random 1), _spawnPos];
            // _m setMarkerType "mil_dot";
        };

    };
};

dyn_destroyed_mil_vic = {
    params ["_centerPos", "_dir", "_trg", "_amount", ["_vicTypes", dyn_standart_combat_vehicles], ["_menTypes", [dyn_standart_soldier]], ["_excactPos", false]];
    private ["_road", "_roadDir"];

    private _allCivs = [];
    private _spawnPos = _centerPos;

    for "_l" from 0 to _amount do {
        _vic = createVehicle [selectRandom _vicTypes, _spawnPos, [], 15, "NONE"];
        _vic setDir ([0, 359] call BIS_fnc_randomInt);
        _vic setDamage [1, false];
        _vic setVariable ["dyn_dont_delete", true];

        [_vic] spawn {
            params ["_vic"];
            sleep 15;
            _vic enableSimulation false;
            {
                deleteVehicle _x;
            } forEach (allMissionObjects "WeaponHolder");
            // sleep 20;
        };

        for "_j" from 0 to ([1, 2] call BIS_fnc_randomInt) do {
            _civ = createAgent [selectRandom _menTypes , getPos _vic, [], 8, "NONE"];
            _allCivs pushBack _civ;
            _civ setVariable ["dyn_dont_delete", true];
            _civ setDamage 1;
            [_civ] spawn {
                params ["_civ"];
                _civ setDir ([0, 359] call BIS_fnc_randomInt);
                sleep 20;
                _civ enableSimulation false;
            };
        };
        sleep 1;
        // };
    };

    if !(isNull _trg) then { 
        waitUntil {sleep 5; triggerActivated _trg};

        {
            deleteVehicle _x;
            sleep 20;
        } forEach _allCivs;
    };
};

    
dyn_destroyed_cars = {
    params ["_centerPos", "_dir", "_trg", "_amount", ["_excactPos", false]];
    private ["_road", "_roadDir"];

    private _smokeGroup = createGroup [civilian, true];
    private _roads = _centerPos nearRoads 1000;
    private _allCivs = [];
    private _spawnPos = _centerPos;

    for "_l" from 0 to _amount do {
        if !(_excactPos) then {
            _road = selectRandom _roads;
            _roadDir = (getpos ((roadsConnectedTo _road)#0)) getDir (getpOs _road);
            if !(isNil "_roadDir") then {
                _spawnPos = (getPos _road) getPos [[5, 15] call BIS_fnc_randomInt, _roadDir + 90];
            };
        };
        _vic = createVehicle [selectRandom dyn_civ_vics, _spawnPos, [], 15, "NONE"];
        _vic setDir ([0, 359] call BIS_fnc_randomInt);
        _vic setDamage [1, false];
        _vic setVariable ["dyn_dont_delete", true];
        _smoke = _smokeGroup createUnit ["ModuleEffectsSmoke_F", getPosATLVisual _vic, [],0 , ""];
        _fire = _smokeGroup createUnit ["ModuleEffectsFire_F", getPosATLVisual _vic, [],0 , ""];

        [_vic, _smoke, _fire] spawn {
            params ["_vic", "_smoke", "_fire"];
            sleep 15;
            _vic setPosATL (getPosATLVisual _smoke);
            _vic enableSimulation false;
            // sleep 20;
        };
        for "_j" from 0 to ([1, 2] call BIS_fnc_randomInt) do {
            _civ = createAgent [dyn_civilian, getPos _vic, [], 8, "NONE"];
            _allCivs pushBack _civ;
            _civ setVariable ["dyn_dont_delete", true];
            _civ setDamage 1;
            [_civ] spawn {
                params ["_civ"];
                _civ setDir ([0, 359] call BIS_fnc_randomInt);
                sleep 20;
                _civ enableSimulation false;
            };
        };
        sleep 1;
        // };
    };

    if !(isNull _trg) then { 
        waitUntil {sleep 5; triggerActivated _trg};

        {
            sleep 30;
            deleteVehicle _x;
        } forEach (units _smokeGroup);

        {
            deleteVehicle _x;
            sleep 20;
        } forEach _allCivs;
    };
};


dyn_destroyed_buildings = {
    params ["_centerPos", "_dir", "_trg", "_amount"];

    private _smokeGroup = createGroup [civilian, true];
    private _houses = nearestTerrainObjects [_centerPos, ["HOUSE"], 400, false, true];
    private _allCivs = [];

    for "_i" from 0 to _amount do {
        _house = selectRandom _houses;
        _house setDamage [1, false];
        _pos = getPosATLVisual _house;
        _smoke = _smokeGroup createUnit ["ModuleEffectsSmoke_F", _pos, [],0 , ""];
        _fire = _smokeGroup createUnit ["ModuleEffectsFire_F", _pos, [],0 , ""];
        // _support = _smokeGroup createUnit ["ModuleOrdnance_F", _pos, [],0 , ""];
        // _support setVariable ["type", "ModuleOrdnanceMortar_F_ammo"];

        for "_j" from 0 to ([1, 2] call BIS_fnc_randomInt) do {
            _civ = createAgent [dyn_civilian, getPos _house, [], 8, "NONE"];
            _allCivs pushBack _civ;
            _civ setVariable ["dyn_dont_delete", true];
            _civ setDamage 1;
            [_civ] spawn {
                params ["_civ"];
                _civ setDir ([0, 359] call BIS_fnc_randomInt);
                sleep 20;
                _civ enableSimulation false;
            };
        };

        _fire setPosATL _pos;
        _smoke setPosATL _pos;

        sleep 15;
    };

    if !(isNull _trg) then {
        waitUntil {sleep 5; triggerActivated _trg};

        {
            sleep 30;
            deleteVehicle _x;
        } forEach (units _smokeGroup);

        {
            deleteVehicle _x;
            sleep 20;
        } forEach _allCivs;
    };
};

dyn_random_dead = {
    params ["_centerPos", "_dir", "_trg", "_amount"]; 

    private _allCivs = [];
    for "_i" from 0 to _amount do {

        _spawnPos = [[[_centerPos, 300]], ["water"]] call BIS_fnc_randomPos;
        // _m = createMarker [str (random 1), _spawnPos];
        // _m setMarkerType "mil_dot";

         for "_j" from 0 to ([0, 2] call BIS_fnc_randomInt) do {
            _civ = createAgent [dyn_civilian, _spawnPos, [], 8, "NONE"];
            _allCivs pushBack _civ;
            _civ setVariable ["dyn_dont_delete", true];
            _civ setDamage 1;
            [_civ] spawn {
                params ["_civ"];
                _civ setDir ([0, 359] call BIS_fnc_randomInt);
                sleep 20;
                _civ enableSimulation false;
            };
        };
    };
};

dyn_civilian_presence = {
    params ["_centerPos", "_dir", "_trg"];

    private _civGroup = createGroup [civilian, true];
    private _houses = nearestTerrainObjects [_centerPos, ["HOUSE", "BUILDING"], 300, false, true];
    private _roads = _centerPos nearRoads 300;
    private _allCivs = [];

    for "_i" from 0 to ([4, 7] call BIS_fnc_randomInt) do {

        _road = selectRandom _roads;
        _info = getRoadInfo _road;    
        _endings = [_info#6, _info#7];
        _endings = [_endings, [], {_x distance2D player}, "ASCEND"] call BIS_fnc_sortBy;
        _cPos = _endings#0;
        _roadDir = (_endings#1) getDir (_endings#0);
        _cPos = _cPos getPos [((_info#1) / 2) + 2, _roadDir + 90];

        // _m = createMarker [str (random 1), _cPos];
        // _m setMarkerType "mil_dot";

        // _spawnPos = (getpos _house) getPos [(sizeOf (typeof _house)) + 4, getDir _house];
        for "_j" from 0 to ([0, 1] call BIS_fnc_randomInt) do {
            _civ = createAgent [dyn_civilian, _cPos, [], 0, "NONE"];
            _civ setDir ((_civ getDir _road) + ([-10, 10] call BIS_fnc_randomInt));
            _civ setVariable ["dyn_dont_delete", true];
            sleep 0.5;
            _animation = selectRandom ["Acts_CivilIdle_1", "Acts_CivilIdle_2"];
            _civ switchMove _animation;
            _allCivs pushBack _civ;
        };
    };

    private _garages = _houses select {(typeof _x) == "land_gm_euro_misc_garage_01_01" or (typeOf _x) == "land_gm_euro_misc_garage_01_02"};

    {
        _house = _x;
        _vpos = (getPos _house) getpOs [10, (getDir _house) - 180];
        if !(isOnRoad _vPos) then {
            _vic = createVehicle [selectRandom dyn_civ_vics, _vPos, [], 0, "NONE"];
            _vic setDir ((getDir _house) - 180);
            _vic enableSimulation false;

            // _m = createMarker [str (random 1), _vPos];
            // _m setMarkerType "mil_dot";
            // _m setMarkerColor "colorRED";
        };
    } forEach _garages;

    if !(isNull _trg) then {
        waitUntil {sleep 5; triggerActivated _trg};

        {
            deleteVehicle _x;
        } forEach (units _civGroup);
    };
};

// [getMarkerPos "civ1", 0, objNull] spawn dyn_civilian_presence;


dyn_ambiance_execute = {
    params ["_centerPos", "_dir", "_trg", ["_isFriendly", false]];

    // if (true) exitwith {};

    [_centerPos, _dir, _trg, ([1, 2] call BIS_fnc_randomInt)] spawn dyn_destroyed_cars;
    [_centerPos, _dir, _trg, ([1, 2] call BIS_fnc_randomInt)] spawn dyn_destroyed_buildings;
    [_centerPos, _dir, _trg, ([6, 10] call BIS_fnc_randomInt)] spawn dyn_random_dead;
    if (_isFriendly) then {[_centerPos, _dir, _trg] spawn dyn_civilian_presence};
};



// (getRoadInfo ([getpos player, 20] call BIS_fnc_nearestRoad))#3

// (nearestTerrainObjects [getpos player, ["HOUSE", "BUILDING"], 300, false, true]) apply {typeof _x}