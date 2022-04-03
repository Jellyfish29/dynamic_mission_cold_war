dyn_civ_vics = ["cwr3_c_gaz24", "cwr3_c_mini", "cwr3_c_rapid", "gm_ge_civ_typ1200"];
dyn_civilian = "cwr3_c_civilian_random";
dyn_ambient_sound_mod attachTo [player, [0,0,0]];

dyn_random_weather = {
    skipTime -24;
    86400 setOvercast (selectRandom [0.1, 0.3, 0.5]);
    skipTime 24;
    0 = [] spawn {
        sleep 0.1;
        simulWeatherSync;
    };
};

[] call dyn_random_weather;
    
dyn_destroyed_cars = {
    params ["_centerPos", "_dir", "_trg"];
    private ["_road", "_roadDir"];

    private _smokeGroup = createGroup [civilian, true];
    private _roads = _centerPos nearRoads 1000;
    private _allCivs = [];

    for "_l" from 0 to ([1, 2] call BIS_fnc_randomInt) do {
        _road = selectRandom _roads;
        _roadDir = (getpos ((roadsConnectedTo _road)#0)) getDir (getpOs _road);
        if !(isNil "_roadDir") then {
            _vic = createVehicle [selectRandom dyn_civ_vics, (getPos _road) getPos [[15, 35] call BIS_fnc_randomInt, _roadDir + 90] , [], 15, "NONE"];
            _vic setDir ([0, 359] call BIS_fnc_randomInt);
            _vic setDamage 1;
            _vic setVariable ["dyn_dont_delete", true];
            _smoke = _smokeGroup createUnit ["ModuleEffectsSmoke_F", getPosATLVisual _vic, [],0 , ""];
            _fire = _smokeGroup createUnit ["ModuleEffectsFire_F", getPosATLVisual _vic, [],0 , ""];

            [_vic] spawn {
                params ["_vic"];
                sleep 20;
                _vic enableSimulation false;
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
        };
    };

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


dyn_destroyed_buildings = {
    params ["_centerPos", "_dir", "_trg"];

    private _smokeGroup = createGroup [civilian, true];
    private _houses = nearestTerrainObjects [_centerPos, ["HOUSE"], 400, false, true];
    private _allCivs = [];

    for "_i" from 0 to ([1, 2] call BIS_fnc_randomInt) do {
        _house = selectRandom _houses;
        _house setDamage 1;
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

dyn_random_dead = {
    params ["_centerPos", "_dir", "_trg"]; 

    private _allCivs = [];
    for "_i" from 0 to ([3, 6] call BIS_fnc_randomInt) do {

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

    if (true) exitwith {};

    [_centerPos, _dir, _trg] spawn dyn_destroyed_cars;
    [_centerPos, _dir, _trg] spawn dyn_destroyed_buildings;
    [_centerPos, _dir, _trg] spawn dyn_random_dead;
    if (_isFriendly) then {[_centerPos, _dir, _trg] spawn dyn_civilian_presence};
};



// (getRoadInfo ([getpos player, 20] call BIS_fnc_nearestRoad))#3

(nearestTerrainObjects [getpos player, ["HOUSE", "BUILDING"], 300, false, true]) apply {typeof _x}