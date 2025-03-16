dyn_global_smoke_limit = 0;

dyn_random_weather = {
    skipTime -24;
    _overcast = selectRandom [0, 0, 0.1, 0.1, 0.3, 0.5, 0.8, 0.9, 1];
    // _overcast = 1;
    86400 setOvercast _overcast;
    // 86400 setFog [selectRandom [0, 0, 0, 0.05, 0.1, 0.12], 0.01, 250];

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
            if ((wind#0) < 1 and (wind#0) > -1) then {setWind [1, wind#1, true]};
            if ((wind#1) < 1 and (wind#1) > -1) then {setWind [wind#0, 1, true]};
            simulWeatherSync;
            sleep 1800;
        };
    };
};

dyn_random_day_time = {
  
    setDate [date#0, date#1, date#2, [6, 14] call BIS_fnc_randomInt, [0, 60] call BIS_fnc_randomInt];  

};

dyn_cvivilian_presence = {
    params ["_loc", ["_civAmount", 30], ["_maxParkedCars", 10], ["_maxMovingCars", 6], ["_area", 400]];

    // if (true) exitwith {};

    private _locPos = getPos _loc;
    private _allBuildings = nearestObjects [getPos _loc, ["house"], _area];
    private _allRoads = _locPos nearRoads _area;

    _moduleGrp = createGroup civilian;

    _main = _moduleGrp createUnit ["ModuleCivilianPresence_F", [_locPos#0, _locPos#1, 0], [], 0, "NONE"];
    _main setVariable ["#useagents", true];
    _main setVariable ["#unitcount", _civAmount];
    _main setVariable ["#usepanicmode", true];
    _main setVariable ["#debug", false];
    _main setVariable ["objectarea", [_area + 100, _area + 100, 20,false,0]];

    private _limit = 0;
    // for "_i" from 0 to (count _allBuildings) step 6 do {
        for "_i" from 0 to 10 step 1 do {

        _building = selectRandom _allBuildings;
        _allBuildings deleteAt (_allBuildings find _building);

        _buildMod = _moduleGrp createUnit ["ModuleCivilianPresenceSafeSpot_F", getPos _building, [], 0, "NONE"];
        _buildMod setVariable ["#capacity", 4];
        _buildMod setVariable ["#usebuilding", true];
        _buildMod setVariable ["#type", 0];
        if (_i % 4 == 0) then {
            _wpMod = _moduleGrp createUnit ["ModuleCivilianPresenceUnit_F", getPos _building, [], 0, "NONE"];
        };
        _limit = _limit + 1;
        if (_limit > 45) exitWith {};
    };

    _limit = 0;
    // for "_i" from 0 to (count _allRoads) step 10 do {
    for "_i" from 0 to 10 step 1 do {
        _road = selectRandom _allRoads;
        _allRoads deleteAt (_allRoads find _road);

        _wpMod = _moduleGrp createUnit ["ModuleCivilianPresenceSafeSpot_F", getPos _road, [], 0, "NONE"];
        _wpMod setVariable ["#capacity", 3];
        _wpMod setVariable ["#usebuilding", false];
        _wpMod setVariable ["#type", 2];

        if (_i % 4 == 0) then {
            _wpMod = _moduleGrp createUnit ["ModuleCivilianPresenceUnit_F", getPos _road, [], 0, "NONE"];
        };


        _limit = _limit + 1;
        if (_limit > 45) exitWith {};

    };

    // _furModule = _moduleGrp createUnit ["gm_moduleFurniture", _locPos, [],0 , ""];
    // _furModule setVariable ["objectarea", [500, 500, 20,false,0]];

    _allRoads = _locPos nearRoads _area;
    for "_i" from 1 to (round (count _allBuildings) / 20) do {
        _road = selectRandom _allRoads;
        _allRoads deleteAt (_allRoads find _road);
        _info = getRoadInfo _road;    
        _roadWidth = _info#1;
        _endings = [_info#6, _info#7];
        _roadDir = (_endings#1) getDir (_endings#0);
        _vicType = selectRandom dyn_civilian_cars;

        _car = createVehicle [_vicType, (getPos _road) getPos [_roadWidth / 2, _roadDir + (selectRandom [90, -90])], [], 0, "NONE"];
        _car setDir _roadDir;
        _car enableDynamicSimulation true;
    };

    _allRoads = _locPos nearRoads _area * 2;
    for "_i" from 1 to _maxMovingCars do {
        _road = selectRandom _allRoads;
        _info = getRoadInfo _road;    
        _roadWidth = _info#1;
        _endings = [_info#6, _info#7];
        _roadDir = (_endings#1) getDir (_endings#0);
        _allRoads deleteAt (_allRoads find _road);
        _car = createVehicle [selectRandom dyn_civilian_cars, getPos _road, [], 0, "NONE"];
        _car setDir _roadDir;
        _car limitSpeed 20;
        _car forceSpeed 20;
        _car enableDynamicSimulation true;
        // _car forceFollowRoad true;
        _carGrp = createVehicleCrew _car;
        _carGrp setBehaviour "SAFE";
        _carGrp enableDynamicSimulation true;

        _allRoads = _allRoads call BIS_fnc_arrayShuffle;
        _targetRoad = {
            if ((getPos _x) distance2d (getPos _road) > 150) exitWith {_x};
            objNull
        } forEach _allRoads;
        _allRoads deleteAt (_allRoads find _targetRoad);
        _allRoads = _allRoads call BIS_fnc_arrayShuffle;
        _targetRoad2 = {
            if ((getPos _x) distance2d (getPos _targetRoad) > 150) exitWith {_x};
            objNull
        } forEach _allRoads;
        _allRoads deleteAt (_allRoads find _targetRoad2);

        _wp = _carGrp addWaypoint [getPos _targetRoad, -1];
        // _wp = _carGrp addWaypoint [_targetRoad2, -1];
        _wp = _carGrp addWaypoint [getPos _road, -1];
        _wp = _carGrp addWaypoint [getPos _road, -1];
        _wp setWaypointType "CYCLE";
    };

    //furniture

    // _furModule = _moduleGrp createUnit ["gm_moduleFurniture", [_locPos#0, _locPos#1, 0], [],0 , ""];
    // _furModule setVariable ["objectarea", [500, 500, 20,false,0]];
    // _furModule setVariable ["gm_furniturefilllevel", 0.45];
    

};


dyn_destroyed_mil_vic = {
    params ["_centerPos", "_amount", ["_vicTypes", dyn_standart_combat_vehicles + dyn_standart_trasnport_vehicles], ["_menTypes", [dyn_standart_soldier]], ["_excactPos", false], ["_radius", 1800]];
    private ["_road", "_roadDir"];

    private _allCivs = [];
    private _spawnPos = [[[_centerPos, _radius]], [[_centerPos, 50], "water"]] call BIS_fnc_randomPos;

    for "_l" from 0 to _amount do {
        _spawnPos = [[[_centerPos, _radius]], [[_centerPos, 50], "water"]] call BIS_fnc_randomPos;
        _vic = createVehicle [selectRandom _vicTypes, _spawnPos, [], 10, "NONE"];
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
};

dyn_destroyed_cars = {
    params ["_centerPos", "_amount", ["_excactPos", false]];
    private ["_road", "_roadDir"];

    private _smokeGroup = createGroup [civilian, true];
    private _roads = _centerPos nearRoads 2000;
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

        private _smoke = objNull;
        private _fire = objNull;

        if ((random 1) > 0.6) then {
            _smokeFire = [getPosATLVisual _vic, [1, 3] call BIS_fnc_randomInt] call dyn_spawn_ambiant_smoke;
            _smoke = _smokeFire#0;
            _fire = _smokeFire#1;
        };

        [_vic, _smoke, _fire] spawn {
            params ["_vic", "_smoke", "_fire"];
            sleep 10;

            if !(isNull _smoke) then {
                _vic setPosATL (getPosATLVisual _smoke);
            };
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
};

dyn_destroyed_buildings = {
    params ["_centerPos", "_amount"];

    private _smokeGroup = createGroup [civilian, true];
    private _houses = nearestTerrainObjects [_centerPos, ["HOUSE"], 2000, false, true];
    private _allCivs = [];

    private _validBuildings = [];
    {
        if (count ([_x] call BIS_fnc_buildingPositions) >= 2) then {
            _validBuildings pushBack _x;
        };
    } forEach _houses;

    for "_i" from 0 to _amount do {
        _house = selectRandom _validBuildings;
        _house setDamage [1, false];
        _pos = getPosATLVisual _house;

        private _smoke = objNull;
        private _fire = objNull;

        if ((random 1) > 0.8) then {
            _smokeFire = [getPosATLVisual _house, [4, 6] call BIS_fnc_randomInt] call dyn_spawn_ambiant_smoke;
            _smoke = _smokeFire#0;
            _fire = _smokeFire#1;
        };
        // _support = _smokeGroup createUnit ["ModuleOrdnance_F", _pos, [],0 , ""];
        // _support setVariable ["type", "ModuleOrdnanceMortar_F_ammo"];

        for "_j" from 0 to ([1, 2] call BIS_fnc_randomInt) do {
            _civ = createAgent [selectRandom [dyn_civilian, (typeof (selectRandom (allUnits select {side _x == playerSide})))], getPos _house, [], 8, "NONE"];
            _allCivs pushBack _civ;
            _civ setVariable ["dyn_dont_delete", true];
            _civ setDamage [1, false];
            [_civ] spawn {
                params ["_civ"];
                _civ setDir ([0, 359] call BIS_fnc_randomInt);
                sleep 20;
                _civ enableSimulation false;
            };
        };

        _fire setPosATL _pos;
        _smoke setPosATL _pos;
    };
};

dyn_random_dead = {
    params ["_centerPos", "_amount"]; 

    private _allCivs = [];
    for "_i" from 0 to _amount do {

        _spawnPos = [[[_centerPos, 1700]], ["water"]] call BIS_fnc_randomPos;
        // _m = createMarker [str (random 1), _spawnPos];
        // _m setMarkerType "mil_dot";

         for "_j" from 0 to ([0, 2] call BIS_fnc_randomInt) do {
            _civ = createAgent [selectRandom [dyn_civilian, (typeof (selectRandom (allUnits select {side _x == playerSide})))], _spawnPos, [], 8, "NONE"];
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


dyn_random_craters = {
    params ["_centerPos", "_amount"]; 

    private _smokeGroup = createGroup [civilian, true];
    private _spawnPos = _centerPos;

    for "_l" from 0 to _amount do {

        _craterType = selectRandom ["Land_ShellCrater_02_extralarge_F", "Land_ShellCrater_02_large_F", "Land_ShellCrater_02_small_F"];
        _spawnPos = [[[_centerPos, 2000]],["water"]] call BIS_fnc_randomPos;
        _spawnPos = _spawnPos findEmptyPosition [0, 50, _craterType];

        if (_spawnPos isEqualTo []) then {continue};

        _crater = createVehicle [_craterType, _spawnPos, [], 15, "NONE"];
        _crater setDir ([0, 359] call BIS_fnc_randomInt);

        private _smoke = objNull;
        private _fire = objNull;

        if ((random 1) > 0.8) then {

            _smokeFire = [getPosATLVisual _crater, [2, 4] call BIS_fnc_randomInt] call dyn_spawn_ambiant_smoke;
            _smoke = _smokeFire#0;
            _fire = _smokeFire#1;
        };

        // _m = createMarker [str (random 1), _spawnPos];
        // _m setMarkerType "mil_dot";


        [_crater, _smoke, _fire] spawn {
            params ["_crater", "_smoke", "_fire"];
            sleep 10;

            if !(isNull _smoke) then {
                _crater setPosATL (getPosATLVisual _smoke);
            };
            // sleep 20;
        };
        sleep 0.1;
        // };
    };
};

dyn_spawn_ambiant_smoke = {
    params ["_pos", ["_sizeFactor", [1, 5] call BIS_fnc_randomInt], ["_weakeningIntervall", 500]];

    // _sizeFactor = 1;

    if (dyn_global_smoke_limit >= 4) exitWith {[objNull, objNull]};

    dyn_global_smoke_limit = dyn_global_smoke_limit + 1;

    private _smokeGroup = createGroup [civilian, true];

    _smokeBlackness = random 0.3;


    _smoke = _smokeGroup createUnit ["ModuleEffectsSmoke_F", _pos, [],0 , ""];
    _smoke setVariable ["effectsize", 1 * _sizeFactor];
    _smoke setVariable ["particledensity", 15 * _sizeFactor];
    _smoke setVariable ["particlelifetime", 50 + (10 * _sizeFactor)];
    _smoke setVariable ["windeffect", 1 - (0.05 * _sizeFactor)];
    _smoke setVariable ["colorblue", _smokeBlackness];
    _smoke setVariable ["colorred", _smokeBlackness];
    _smoke setVariable ["colorgreen", _smokeBlackness];
    
    _fire = _smokeGroup createUnit ["ModuleEffectsFire_F", _pos, [],0 , ""];
    _fire setVariable ["effectsize", 1 * _sizeFactor];
    _fire setVariable ["particledensity", 5 * _sizeFactor];
    _fire setVariable ["particlesize", 1 * _sizeFactor];
    

    [_smoke, _fire, _sizeFactor, _weakeningIntervall, _smokeGroup, _smokeBlackness, _pos] spawn {
        params ["_smoke", "_fire", "_sizeFactor", "_weakeningIntervall", "_smokeGroup", "_smokeBlackness", "_pos"];

        for "_i" from _sizeFactor to 1 step -1 do {

            sleep _weakeningIntervall;
            _sizeFactor = _sizeFactor - 1;
            if (_sizeFactor < 1) then {_sizeFactor = 1};

            _smokeOld = _smoke;
            _smoke = _smokeGroup createUnit ["ModuleEffectsSmoke_F", getPos _smokeOld, [],0 , ""];
            _smoke setPosATL (getPosATLVisual _smokeOld);
            _smoke setVariable ["effectsize", 1 * _sizeFactor];
            _smoke setVariable ["particledensity", 15 * _sizeFactor];
            _smoke setVariable ["particlelifetime", 50 + (10 * _sizeFactor)];
            _smoke setVariable ["windeffect", 1 - (0.05 * _sizeFactor)];
            _smoke setVariable ["colorblue", _smokeBlackness];
            _smoke setVariable ["colorred", _smokeBlackness];
            _smoke setVariable ["colorgreen", _smokeBlackness];
            deleteVehicle ((_smokeOld getVariable "effectEmitter") select 0);
            deleteVehicle _smokeOld;
            

            _fireOld = _fire;
            _fire = _smokeGroup createUnit ["ModuleEffectsFire_F", getPos _fireOld, [],0 , ""];
            _fire setPosATL (getPosATLVisual _smoke);
            _fire setVariable ["effectsize", 1 * _sizeFactor];
            _fire setVariable ["particledensity", 5 * _sizeFactor];
            _fire setVariable ["particlesize", 1 * _sizeFactor];
            deleteVehicle ((_fireOld getVariable "effectEmitter") select 0);
            deleteVehicle _fireOld;
        };

        {
            deleteVehicle ((_x getVariable "effectEmitter") select 0);  
            // deleteVehicle ((_x getVariable "effectLight") select 0);
            deleteVehicle _x;
        } forEach (units _smokeGroup);

        dyn_global_smoke_limit = dyn_global_smoke_limit - 1;

    };

    [_smoke, _fire]

};

dyn_side_town_destruction = {
    params ["_centerPos"];

    _civilTowns = nearestLocations [_centerPos, ["NameCity", "NameVillage", "NameCityCapital"], 2000];
    _artyGroup = createGroup [civilian, false];
    {

        for "_j" from 0 to ([1, 2] call BIS_fnc_randomInt) do {
            private _impactPos = [[[getPos _x, 180]],[]] call BIS_fnc_randomPos;
            _support = _artyGroup createUnit ["ModuleOrdnance_F", _impactPos, [],0 , ""];
            _support setVariable ["type", "ModuleOrdnanceHowitzer_F_Ammo"];

            // _m = createMarker [str (random 1), _impactPos];
            // _m setMarkerType "mil_dot";
            // _m setMarkerColor "colorRED";

            sleep (random 5);
        };

        sleep (5 + (random 5));

    } forEach _civilTowns;
};


dyn_AO_destruction = {
    params ["_centerPos", "_playerStart"];

    [_centerPos getpos [600, _centerPos getDir _playerStart], dyn_strength + ([2, 6 + dyn_strength] call BIS_fnc_randomInt), [typeof (selectRandom (vehicles select {side _x == playerSide}))], [typeof (selectRandom (allUnits select {side _x == playerSide}))]] spawn dyn_destroyed_mil_vic;

    [_centerPos getpos [600, _centerPos getDir _playerStart], dyn_strength + ([2, 6 + dyn_strength] call BIS_fnc_randomInt)] spawn dyn_destroyed_cars;

    [_centerPos getpos [300, _centerPos getDir _playerStart], dyn_strength + ([2, 6 + dyn_strength] call BIS_fnc_randomInt)] spawn dyn_destroyed_buildings;

    [_centerPos getpos [400, _centerPos getDir _playerStart], dyn_strength + ([2, 6 + dyn_strength] call BIS_fnc_randomInt)] spawn dyn_random_dead;

    [_centerPos getpos [400, _centerPos getDir _playerStart], dyn_strength + ([2, 6 + dyn_strength] call BIS_fnc_randomInt)] spawn dyn_random_craters;

    [_centerPos getpos [500, _centerPos getDir _playerStart]] spawn dyn_side_town_destruction;

        
        

    [] spawn {
        sleep 20;

        {
            deleteVehicle _x;
        } forEach (allMissionObjects "WeaponHolder");
    };
};


dyn_random_continous_neutral_arty = {
    private ["_impactPos, _support"];

    _artyGroup = createGroup [civilian, false];
    while {alive player} do {

        // sleep 5;

        sleep ([120, 200] call BIS_fnc_randomInt);

        _cords = [[[getPos player, 1000]],[]] call BIS_fnc_randomPos;

        for "_j" from 0 to ([0, 2] call BIS_fnc_randomInt) do {
            private _impactPos = [[[_cords, 100]],[]] call BIS_fnc_randomPos;
            _support = _artyGroup createUnit ["ModuleOrdnance_F", _impactPos, [],0 , ""];
            _support setVariable ["type", "ModuleOrdnanceHowitzer_F_Ammo"];

            sleep (random 5);
        };

    };
};

dyn_random_continous_allied_arty = {
    params ["_centerPos", "_playerStart"];
    private ["_cords", "_support"];

    private _cDir = _playerStart getDir _centerPos;
    private _artyGroup = createGroup [civilian, false];

    while {alive player} do {

        sleep 20;

        private _impactPos = _centerPos getpos [[2000, 3000] call BIS_fnc_randomInt, _cDir + ([-110, 110] call BIS_fnc_randomInt)];

        // _m = createMarker [str (random 1), _impactPos];
        // _m setMarkerType "mil_dot";
        // _m setMarkerColor "colorRED";

        for "_i" from 0 to (dyn_strength + ([1, 2] call BIS_fnc_randomInt)) do {
            for "_j" from 1 to 2 do {
                _support = _artyGroup createUnit ["ModuleOrdnance_F", [[[_impactPos, [10, 100] call BIS_fnc_randomInt]],[]] call BIS_fnc_randomPos, [],0 , ""];
                _support setVariable ["type", "ModuleOrdnanceHowitzer_F_Ammo"];
                sleep ([1, 3] call BIS_fnc_randomInt);
            };
            sleep ([2, 6] call BIS_fnc_randomInt);
        };

        if ((random 1) > 0.5 or dyn_global_smoke_limit <= 2) then {
            _smokeFire = [_impactPos, [2, 6] call BIS_fnc_randomInt] call dyn_spawn_ambiant_smoke;
        };

        sleep ([80, 180] call BIS_fnc_randomInt);

    };
};

dyn_random_aa_fire = {
    params ["_centerPos", "_playerStart"];

    private _cDir = _playerStart getDir _centerPos;
    private _tracerGroup = createGroup [civilian, false]; 

    while {alive player} do {

        for "_j" from 0 to (dyn_strength + ([0, 2] call BIS_fnc_randomInt)) do {

            _tracerPos = _centerPos getpos [[1300, 1900] call BIS_fnc_randomInt, _cDir + ([-90, 90] call BIS_fnc_randomInt)];

            _support = _tracerGroup createUnit ["ModuleTracers_F", _tracerPos, [],0 , ""];
            _min = [0, 5] call BIS_fnc_randomInt;
            _max = _min + 1 + ([0, 5] call BIS_fnc_randomInt);
            _support setVariable ["min", _min];
            _support setVariable ["min", _max];
            _support setVariable ["side", selectRandom [1, 2]];

            // sleep ([5, 10] call BIS_fnc_randomInt);

            // if (((date#3) >= 17) or ((date#3) <= 6)) then {
            //     // if ((random 1) > 0.4) then {
            //         "ModuleFlare_F" createUnit [_tracerPos, _tracerGroup, "this setVariable ['BIS_fnc_initModules_disableAutoActivation', false, true];"];
            //     // };
            // };
        };


        {
            if ((random 1) > 0.4) then {
                _support = _tracerGroup createUnit ["ModuleTracers_F", _playerStart getpos [1500, _cDir + _x], [],0 , ""];
            };
        } forEach [-90, 90];

        sleep ([40, 100] call BIS_fnc_randomInt);

        {
            deleteVehicle _x;
        } forEach (units _tracerGroup);


    };

};


dyn_allied_plane_flyby = {
    params ["_centerPos", "_playerStart"];

    sleep ([40, 80] call BIS_fnc_randomInt);
    private _cDir = _playerStart getDir _centerPos;

    while {alive player} do {

        sleep 1;

        private _fireAtTarget = true;

        if ((random 1) > 1) then {
            _fireAtTarget = false;
        };

        private _planeType = selectRandom [pl_cas_plane_1, pl_cas_plane_3];  
        private _targetPos = _centerPos getpos [[1200, 2000] call BIS_fnc_randomInt, _cDir + ([-120, 120] call BIS_fnc_randomInt)];

        for "_i" from 0 to 1 do {

            [_targetPos, _fireAtTarget, _planeType, _cDir] spawn {
                params ["_targetPos", "_fireAtTarget", "_planeType", "_cDir"];
                _rearPos = _targetPos getpos [8000, _cDir - 180];

                _spawnHeight = 800;
                _fligthHeight = 60; 

                _casGroup = createGroup [civilian, true];
                _p = [_rearPos, _cDir, _planeType, _casGroup] call BIS_fnc_spawnVehicle;
                _plane = _p#0;
                [_plane, _spawnHeight, _rearPos, "ATL"] call BIS_fnc_setHeight;
                _plane forceSpeed 1000;
                _plane flyInHeight _fligthHeight;
                _wp = _casGroup addWaypoint [_targetPos, 0];
                // _wp setWaypointType "SAD";
                _time = time + 300;
                _casGroup setBehaviourStrong "CARELESS";

                private _weapons = [];
                {
                    if (tolower ((_x call bis_fnc_itemType) select 1) in ["bomblauncher", "missilelauncher", "rocketLauncher"]) then {
                        _modes = getarray (configfile >> "cfgweapons" >> _x >> "modes");
                        if (count _modes > 0) then {
                            _mode = _modes select 0;
                            if (_mode == "this") then {_mode = _x;};
                                _weapons set [count _weapons,[_x,_mode]];
                        };
                    };
                } foreach ((typeOf _plane) call bis_fnc_weaponsEntityType);

                if (_fireAtTarget) then {
                    waitUntil {sleep 0.25; (_plane distance2D _targetPos) <= 1000 or time >= _time or !alive _plane};
                } else {
                    waitUntil {sleep 0.25; (_plane distance2D player) <= 400 or time >= _time};
                };

                // _plane fireAtTarget [objNull, "RHS_weap_gau8"];
                
                {
                    _plane fireattarget [objNull,(_x select 0)];
                } foreach _weapons;
                sleep 1.5;
                
                {
                    _plane fireattarget [objNull,(_x select 0)];
                } foreach _weapons;

                sleep 2;

                _rearPos = _rearPos getPos [500, _targetPos getdir _rearPos];
                if (_fireAtTarget) then {
                    [_casGroup, (currentWaypoint _casGroup)] setWaypointType "MOVE";
                    [_casGroup, (currentWaypoint _casGroup)] setWaypointPosition [getPosASL (leader _casGroup), -1];
                    sleep 0.1;
                    deleteWaypoint [_casGroup, (currentWaypoint _casGroup)];
                    for "_i" from count waypoints _casGroup - 1 to 0 step -1 do {
                        deleteWaypoint [_casGroup, _i];
                    };
                };
                _wp = _casGroup addWaypoint [_rearPos, 0];
                _time = time + 300;
                // waitUntil {(_plane distance2D (waypointPosition _wp)) <= 800 or time >= _time};

                if ((random 1) > 0.3 or dyn_global_smoke_limit <= 3) then {
                    _smokeFire = [_targetPos, [2, 6] call BIS_fnc_randomInt] call dyn_spawn_ambiant_smoke;
                };


                waitUntil {sleep 0.25; (_plane distance2D (waypointPosition _wp)) <= 600 or time >= _time};

                {
                    deleteVehicle _x;
                } forEach (units _casGroup);
                deleteVehicle _plane;
            };

            sleep 1.5;
        };

        // sleep 30;
        sleep ([300 - (60 * dyn_strength), 600 - (60 * dyn_strength)] call BIS_fnc_randomInt);
    };
};

dyn_enemy_plane_flyby = {
    params ["_centerPos", "_playerStart"];

    sleep ([10, 30] call BIS_fnc_randomInt);
    private _cDir = _playerStart getDir _centerPos;

    private _first = 0;
    while {alive player} do {

        sleep 1;

        private _dirOffset = selectRandom [90, 0, -90];

        if (_first == 0) then {
            _dirOffset = 0;
        };
        _first = 1;

        for "_i" from 0 to 1 do {

            [_centerPos, _cDir, _dirOffset] spawn {
                params ["_centerPos", "_cDir", "_dirOffset"];

                _rearPos = _centerPos getpos [5000, _cDir + _dirOffset];

                _targetPos = getPos player getpos [5000, _rearPos getdir _centerPos];

                _spawnHeight = 800;
                _fligthHeight = 25; 

                _casGroup = createGroup [civilian, true];
                _p = [_rearPos, _rearPos getdir _centerPos, dyn_standart_jet, _casGroup] call BIS_fnc_spawnVehicle;
                _plane = _p#0;
                [_plane, _spawnHeight, _rearPos, "ATL"] call BIS_fnc_setHeight;
                _plane forceSpeed 500;
                _plane flyInHeight _fligthHeight;
                _wp = _casGroup addWaypoint [_targetPos, 0];

                _time = time + 300;
                _casGroup setBehaviourStrong "CARELESS";

                waitUntil {sleep 0.25; (_plane distance2D (waypointPosition _wp)) <= 1000 or time >= _time};

                {
                    deleteVehicle _x;
                } forEach (units _casGroup);

                deleteVehicle _plane;
            };

            sleep 1.5;
        };

        // sleep 20;
        sleep ([400 - (60 * dyn_strength), 700 - (60 * dyn_strength)] call BIS_fnc_randomInt);
    };
};


dyn_random_fires = {
    params ["_centerPos", "_playerStart"];

    [] spawn dyn_random_continous_neutral_arty;

    // [_centerPos, _playerStart] spawn dyn_random_aa_fire;

    [_centerPos, _playerStart] spawn dyn_random_continous_allied_arty;

    [_centerPos, _playerStart] spawn dyn_allied_plane_flyby;

    // [_centerPos, _playerStart] spawn dyn_enemy_plane_flyby;
    
};


