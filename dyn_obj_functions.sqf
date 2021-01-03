dyn_defense_line = {
    params ["_locPos", "_townTrg", "_dir", ["_exactPos", false]];
    private ["_aoPos", "_defPos", "_objs", "_objAmount", "_road", "_dir", "_patrollPos", "_rearPos", "_grps", "_blkPos"];

    if (_exactPos) then {
        _defPos = _locPos;
    }
    else
    {
        _distance = [900, 1200] call BIS_fnc_randomInt;
        _defPos = [_distance * (sin _dir), _distance * (cos _dir), 0] vectorAdd _locPos;
    };
    _road = [_defPos, 400, ["TRAIL"]] call BIS_fnc_nearestRoad;
    if !(isNull _road) then {_defPos = getPos _road};
    _aoPos = createTrigger ["EmptyDetector", _defPos, true];
    _aoPos setTriggerActivation ["WEST", "PRESENT", false];
    _aoPos setTriggerStatements ["this", " ", " "];
    _aoPos setTriggerArea [750, 65, _dir, true];

    _objs = [];
    _objAmount = [3, 5] call BIS_fnc_randomInt;
    // _dir = 360 + ((triggerArea _aoPos)#2);
    _patrollPos = [];
    _blkPos = [[0, 0, 0]];
    _grps = [];

    // create Roadblock
    // if !(isNull _road) then {
    //     [_defPos] call dyn_spawn_raod_block;
    // };
    
    // Spawn Groups at Position
    for "_i" from 0 to (_objAmount - 1) do {
        _pos = [[_aoPos], [[_blkPos#_i, 60], "water"]] call BIS_fnc_randomPos;
        _grp = [_pos, _dir, true, false, false] call dyn_spawn_covered_inf;
        _patrollPos pushBack (getPos (leader _grp));
        _blkPos pushBack (getPos (leader _grp));
        _grps pushBack _grp;
    };

    // create Static vehicle
    {
        if ((random 1) > 0.5) then {
            _vPos = [25 * (sin (_dir - 180)), 25 * (cos (_dir - 180)), 0] vectorAdd _x;
            [_vPos, dyn_standart_light_amored_vic, _dir] call dyn_spawn_covered_vehicle;
        };
    } forEach _patrollPos;



    // create Patroll
    _grp = [_patrollPos, getPos _aoPos] call dyn_spawn_patrol;
    _grps pushBack _grp;

    // create garrison
    _buildings = nearestObjects [(getPos _aoPos), ["house"], (triggerArea _aoPos)#0];

    _garAmount = [1, 3] call BIS_fnc_randomInt;
    private _garCount = 0;

    {
        if (count ([_x] call BIS_fnc_buildingPositions) >= 4 and ((getPos _x inArea _aoPos)) and _garCount < _garAmount) then {
            _garCount = _garCount + 1;
            _grp = [getPos _aoPos, east, dyn_standart_fire_team] call BIS_fnc_spawnGroup;
            [_x, _grp, _dir] spawn dyn_garrison_building;
        };
    } forEach _buildings;

    // rocketArty
    if ((random 1) > 0.5) then {
        _rearPos = [1200 * (sin (_dir - 180)), 1200 * (cos (_dir - 180)), 0] vectorAdd _locPos;
        [_rearPos, _aoPos] spawn dyn_spawn_rocket_arty;
    };

    //create counterattack;
    if ((random 1) > 0.25) then {
        [_aoPos, getPos _aoPos, getPos _townTrg, [4, 5] call BIS_fnc_randomInt, [3, 4] call BIS_fnc_randomInt, 2] spawn dyn_spawn_counter_attack;
        [_aoPos, _grps] spawn dyn_attack_nearest_enemy;
    };

    // Retreat
    [_townTrg, getPos _townTrg, _grps, false] spawn dyn_retreat;
};

dyn_strong_point_defence = {
    params ["_locPos", "_townTrg", "_dir", ["_exactPos", false]];
    private ["_distance","_aoPos", "_grps"];

    if (_exactPos) then {
        _distance = [200, 300] call BIS_fnc_randomInt;
    }
    else
    {
         _distance = [800, 1000] call BIS_fnc_randomInt;
    };

    _offsets = [[-5, -30] call BIS_fnc_randomInt, [5, 30] call BIS_fnc_randomInt];
    for "_i" from 0 to 1 do {
        _defPos = [_distance * (sin (_dir + (_offsets#_i))), _distance * (cos (_dir + (_offsets#_i))), 0] vectorAdd _locPos;
        // _defPos = getPos ((nearestTerrainObjects [_defPos, ["TREE", "FOREST BORDER", "FOREST TRIANGLE", "FOREST SQUARE"], 300, true, true]) select 0);
        _aoPos = createTrigger ["EmptyDetector", _defPos, true];
        _aoPos setTriggerActivation ["WEST", "PRESENT", false];
        _aoPos setTriggerStatements ["this", " ", " "];
        _aoPos setTriggerArea [350, 350, _dir, false];

        _grps = [];
        _degree = [-90, 90];
        for "_j" from 0 to 1 do {
            _nDir = _dir + (_degree#_j);
            _nPos = [55 * (sin _nDir), 55 * (cos _nDir), 0] vectorAdd _defPos;
            _grp = [_nPos, _dir, false, false, false, true, true] call dyn_spawn_covered_inf;
            _grps pushBack _grp;
        };
        _grp = [_defPos, dyn_standart_MBT, _dir] call dyn_spawn_covered_vehicle;
        _grps pushBack _grp;
        if ((random 1) > 0.5) then {
            [_aoPos, _defPos, getPos _townTrg, [2, 3] call BIS_fnc_randomInt, [1, 2] call BIS_fnc_randomInt, 1, false] spawn dyn_spawn_counter_attack;
        };
        if ((random 1) > 0.7) then {
            _rearPos = [1200 * (sin (_dir - 180)), 1200 * (cos (_dir - 180)), 0] vectorAdd _locPos;
            [_rearPos, _aoPos] spawn dyn_spawn_rocket_arty;
        };
        [_townTrg, getPos _townTrg, _grps] spawn dyn_retreat;
    };
};

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

    _trgPos = [2000 * (sin _dir), 2000 * (cos _dir), 0] vectorAdd _locPos;
    private _atkTrg = createTrigger ["EmptyDetector", _trgPos, true];
    _atkTrg setTriggerActivation ["WEST", "PRESENT", false];
    _atkTrg setTriggerStatements ["this", " ", " "];
    _atkTrg setTriggerArea [2500, 65, _dir, true];
    _atkTrg setTriggerTimeout [30, 45, 70, false];

    private _allTankGrps = [];

    // _m = createMarker [str (random 1), _trgPos];
    // _m setMarkerType "mil_dot";

    for "_i" from 0 to ([3, 5] call BIS_fnc_randomInt) do {
        _vPos = [(110 * _i) * (sin (_dir + 90)), (110 * _i) * (cos (_dir + 90)), 0] vectorAdd _stagingPos;
        _grp = [_vPos, 0, [dyn_standart_MBT], _dir] call dyn_spawn_parked_vehicle;
        (vehicle (leader _grp)) limitSpeed 30;
        _allTankGrps pushBack _grp;
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
            _lWp = _leader addWaypoint [_lPos, 0];
            _syncWps pushBack _lWp;
            {
                _wPos = [(_wpIntervall * _i) * (sin _atkDir), (_wpIntervall * _i) * (cos _atkDir), 0] vectorAdd (getPos (leader _x));
                _gWp = _x addWaypoint [_wPos, 0];
                _gWp synchronizeWaypoint _syncWps;
                _syncWps pushBack _lWp;
            } forEach _allTankGrps - [_leader];
        };

        waitUntil {sleep 1; ({alive _x} count _leaders) <= 2};

        [objNull, _defPos, _allTankGrps, false] spawn dyn_retreat;
    };

};

dyn_road_emplacemnets = {
    params ["_locPos", "_townTrg", "_dir", ["_exactPos", false]];
    private ["_aoPos", "_defPos", "_objs", "_objAmount", "_road", "_dir", "_patrollPos", "_rearPos", "_grps", "_blkPos"];

    if (_exactPos) then {
        _defPos = _locPos;
    }
    else
    {
        _distance = [600, 750] call BIS_fnc_randomInt;
        _defPos = [_distance * (sin _dir), _distance * (cos _dir), 0] vectorAdd _locPos;
    };
    _aoPos = createTrigger ["EmptyDetector", _defPos, true];
    _aoPos setTriggerActivation ["WEST", "PRESENT", false];
    _aoPos setTriggerStatements ["this", " ", " "];
    _aoPos setTriggerArea [1500, 10, _dir, true];

    _allRoad = _defPos nearRoads 1500;
    private _validRoads = [];
    private _grps = [];
    {
        _road = _x;
        if ((getPos _road) inArea _aoPos and !((getRoadInfo _road)#2)) then {
            _valid = true;
            {
                if (((getPos _road) distance2D (getPos _x)) < 200) exitWith {_valid = false};
            } forEach _validRoads;
            if (_valid) then {
                // if (((getRoadInfo _road)#0) in ["ROAD", "MAIN ROAD"]) then {
                    _validRoads pushBackUnique _x;
                // };
            };
        };
    } forEach _allRoad;

    _blockLimiter = 0;
    {
        if (_blockLimiter <= 4) then {
            _info = getRoadInfo _x;
            _type = _info#0;
            _width = (_info#1) / 2;
            _endings = [_info#6, _info#7];
            _endings = [_endings, [], {_x distance2D _locPos}, "DESCEND"] call BIS_fnc_sortBy;
            _rPos = _endings#0;
            _rDir = (_endings#1) getDir (_endings#0);


            if (_type isEqualTo "ROAD" or _type isEqualTo "MAIN ROAD") then {
                _infleftPos = [(_width + 40) * (sin (_rdir + 90)), (_width + 40) * (cos (_rdir + 90)), 0] vectorAdd _rPos;
                _infrigthPos = [(_width + 40) * (sin (_rdir - 90)), (_width + 40) * (cos (_rdir - 90)), 0] vectorAdd _rPos;
                {
                    _building = nearestBuilding _x;
                    if ((_building distance2D _x) > 70) then {
                        _grp = [_x, _rDir, false, false, false, true, true] call dyn_spawn_covered_inf;
                        _grps pushBack _grp;
                    }
                    else
                    {
                        _grp = [_x, east, dyn_standart_fire_team] call BIS_fnc_spawnGroup;
                        [_building, _grp, _rDir] spawn dyn_garrison_building;
                    };
                } forEach [_infleftPos, _infrigthPos];

                _staticleftPos = [(_width + ([1, 5] call BIS_fnc_randomInt)) * (sin (_rdir + 90)), (_width + ([1, 5] call BIS_fnc_randomInt)) * (cos (_rdir + 90)), 0] vectorAdd _rPos;
                _staticrigthPos = [(_width + ([1, 5] call BIS_fnc_randomInt)) * (sin (_rdir - 90)), (_width + ([1, 5] call BIS_fnc_randomInt)) * (cos (_rdir - 90)), 0] vectorAdd _rPos;
                [selectRandom [_staticleftPos, _staticrigthPos], _rDir, true] call dyn_spawn_static_weapon;

                _vPos = [25 * (sin (_rDir - 180)), 25 * (cos (_rDir - 180)), 0] vectorAdd (selectRandom [_infleftPos, _infrigthPos]);
                [_vPos, dyn_standart_light_amored_vic, _rDir] call dyn_spawn_covered_vehicle;
            }
            else
            {
                _grp = [_rPos, _rDir, true, false, false, false, false] call dyn_spawn_covered_inf;
                _grps pushBack _grp;
            };

            _b = "Land_Razorwire_F" createVehicle _rPos;
            _b setDir _rDir;
            _blockLimiter = _blockLimiter + 1;
        };
    } forEach _validRoads;

    _distance = [400, 600] call BIS_fnc_randomInt;
    _caPos = [_distance * (sin _dir), _distance * (cos _dir), 0] vectorAdd _defPos;
    _aoPos setPos _caPos;

    if ((random 1) > 0.25) then {
        _rearPos = [1200 * (sin (_dir - 180)), 1200 * (cos (_dir - 180)), 0] vectorAdd _locPos;
        [_rearPos, _aoPos] spawn dyn_spawn_rocket_arty;
    };

    //debug
    // _m = createMarker [str (random 1), getPos _aoPos];
    // _m setMarkerType "mil_dot";

    //create counterattack;
    if ((random 1) > 0.25) then {
        [_aoPos, getPos _aoPos, getPos _townTrg, [4, 5] call BIS_fnc_randomInt, [3, 5] call BIS_fnc_randomInt, 2] spawn dyn_spawn_counter_attack;
        // [_aoPos, _grps] spawn dyn_attack_nearest_enemy;
    };

    // Retreat
    [_townTrg, getPos _townTrg, _grps] spawn dyn_retreat;


    ////debug
    // _i = 0;
    // {
    //     _m = createMarker [str (random 1), getPos _x];
    //     _m setMarkerText str _i;
    //     _m setMarkerType "mil_dot";
    //     _i = _i + 1
    // } forEach _validRoads;
};

dyn_recon_convoy = {
    params ["_locPos", "_townTrg", "_dir", ["_exactPos", false]];
    private ["_allGrps", "_validRoads"];

    _trgPos = [2500 * (sin _dir), 2500 * (cos _dir), 0] vectorAdd _locPos;
    private _atkTrg = createTrigger ["EmptyDetector", _trgPos, true];
    _atkTrg setTriggerActivation ["WEST", "PRESENT", false];
    _atkTrg setTriggerStatements ["this", " ", " "];
    _atkTrg setTriggerArea [2500, 65, _dir, true];
    // _atkTrg setTriggerTimeout [30, 45, 70, false];

    // debug
    // _m = createMarker [str (random 1), _trgPos];
    // _m setMarkerType "mil_dot";

    _rearPos = [2500 * (sin (_dir - 180)), 2500 * (cos (_dir - 180)), 0] vectorAdd _locPos;
    _rearPos = _rearPos findEmptyPosition [0, 250, "cwr3_o_bm21"];
    _grad = "cwr3_o_bm21" createVehicle _rearPos;
    _grp = createVehicleCrew _grad;

    _allGrps = [];
    _validRoads = [];
    _roads = _locPos nearRoads 500;

    {
        if (((getRoadInfo _x)#0) in ["ROAD", "MAIN ROAD"]) then {
            _validRoads pushBack _x;
        };
    } forEach _roads;
    _validRoads = [_validRoads, [], {(getPos _x) distance2D _trgPos}, "ASCEND"] call BIS_fnc_sortBy;
    _road = _validRoads#0;

    _vicTypes = ["cwr3_o_btr80", "cwr3_o_btr80", "cwr3_o_brdm2_atgm", "cwr3_o_brdm2um", "cwr3_o_brdm2"];
    for "_i" from 0 to 4 do {
        _road = ((roadsConnectedTo _road) - [_road]) select 0;
        _near = roadsConnectedTo _road;
        _info = getRoadInfo _road;
        _endings = [_info#6, _info#7];
        _endings = [_endings, [], {(getPos _road) distance2D _trgPos}, "ASCEND"] call BIS_fnc_sortBy;
        _rPos = _endings#0;
        _rDir = (_endings#1) getDir (_endings#0);
        _vicType = _vicTypes#_i;
        _vic = _vicType createVehicle _rPos;
        _vic setDir _rDir;
        _vic limitSpeed 45;
        // _vic forceFollowRoad true;
        _grp = createVehicleCrew _vic;
        _grp setBehaviour "SAFE";
        _allGrps pushBack _grp;
        if (_vicType isEqualTo "cwr3_o_btr80") then {
            _iGrp = [_rPos, east, dyn_standart_squad] call BIS_fnc_spawnGroup;
            {
                _x assignAsCargo _vic;
                _x moveInCargo _vic;
            } forEach (units _iGrp);
        };  
    };

    [_allGrps, _atkTrg, _grad] spawn {
        params ["_allGrps", "_atkTrg", "_grad"];

        _targetRaod = getPos ([getPos _atkTrg, 600] call BIS_fnc_nearestRoad);
        waitUntil { sleep 1; triggerActivated _atkTrg };

        reverse _allGrps;
        {
            _wp = _x addWaypoint [_targetRaod, 20];
            _wp setWaypointType "TR UNLOAD";
            sleep 3;
        } forEach _allGrps;

        waitUntil {sleep 1; ({alive (leader _x)} count _allGrps) < (count _allGrps)};

        for "_i" from 0 to 3 do {
            _target = selectRandom (allUnits select {side _x == west});
            _tPos = getPos _target;
            _artyPos = [[[_tPos, 350]], [[_tPos, 80]]] call BIS_fnc_randomPos;
            _grad commandArtilleryFire [_artyPos, "CUP_40Rnd_GRAD_HE", 10];
            sleep 15;
        };
    };
};


dyn_town_defense = {
    params ["_aoPos"];
    private ["_dir", "_watchPos", "_validBuildings", "_patrollPos", "_allGrps"];
    _dir = 360 + ((triggerArea _aoPos)#2);
    _watchPos = [1400 * (sin _dir), 1400 * (cos _dir), 0] vectorAdd (getPos _aoPos);
    _validBuildings = [];
    _patrollPos = [];
    _allGrps = [];

    // create outer Garrison
    _buildings = nearestObjects [(getPos _aoPos), ["house"], (triggerArea _aoPos)#0];


    {
        if (count ([_x] call BIS_fnc_buildingPositions) >= 8 and ((getPos _x inArea _aoPos))) then {
            _validBuildings pushBack _x;
        };
    } forEach _buildings;

    _validBuildings = [_validBuildings, [], {_x distance2D _watchPos}, "ASCEND"] call BIS_fnc_sortBy;

    _garAmount = [2, 4] call BIS_fnc_randomInt;

    // front Garrison
    for "_i" from 0 to (_garAmount - 1) step 1 do {
        _grp = [getPos _aoPos, east, dyn_standart_fire_team] call BIS_fnc_spawnGroup;
        [(_validBuildings#_i), _grp, _dir] spawn dyn_garrison_building;
        if ((random 1) > 0.5) then {_patrollPos pushBack (getPos (_validBuildings#_i))};
        _allGrps pushBack _grp;
    };

    // Rear Garrison
    _grp = [getPos _aoPos, east, dyn_standart_fire_team] call BIS_fnc_spawnGroup;
    [(_validBuildings#((count _validBuildings) - 1)), _grp, _dir - 180] spawn dyn_garrison_building;
    if ((random 1) > 0.5) then {_patrollPos pushBack (getPos (_validBuildings#((count _validBuildings) - _i)))};
    _allGrps pushBack _grp;

    // random Garrison
    for "_i" from 0 to ([1, 2] call BIS_fnc_randomInt) do {
        _grp = [getPos _aoPos, east, dyn_standart_fire_team] call BIS_fnc_spawnGroup;
        [(_validBuildings#([4, ((count _validBuildings) - 2)] call BIS_fnc_randomInt)), _grp, _dir] spawn dyn_garrison_building;
        _allGrps pushBack _grp;
    };

    // create raodblock
    // [getPos (_validBuildings#0)] call dyn_spawn_raod_block;

    // create static Vehicle
    _step = [1, 3] call BIS_fnc_randomInt;
    for "_i" from 0 to _step step _step do {
        _vPos = getPos (_validBuildings#_i);
        _vicType = selectRandom dyn_standart_combat_vehicles;
        _vPos = [_vPos, 1, 100, 3, 0, 20, 0] call BIS_fnc_findSafePos;
        _grp = [_vPos, _vicType, _dir] call dyn_spawn_covered_vehicle;
        if !(isNull _grp) then {
            _patrollPos pushBack (getPos (leader _grp));
            _allGrps pushBack _grp;
        };
    };

    // create static Infantry
    for "_i" from 0 to ([0, 1] call BIS_fnc_randomInt) do {
        _distance = [20, 50] call BIS_fnc_randomInt;
        _infPos = getPos (_validBuildings#([0, 10] call BIS_fnc_randomInt));
        _infPos = [_distance * (sin (_dir + (10 * _i))), _distance * (cos (_dir + (10 * _i))), 0] vectorAdd _infPos;
        _grp = [_infPos, _dir, false, true, true] call dyn_spawn_covered_inf;
        if !(isNull _grp) then {
            _patrollPos pushBack (getPos (leader _grp));
            _allGrps pushBack _grp;
        };
    };
    // rear Inf
    _infPos = getPos (_validBuildings#((count _validBuildings) - 1));
    _infPos = [40 * (sin (_dir - 180)), 40 * (cos (_dir - 180)), 0] vectorAdd _infPos;
    _grp = [_infPos, _dir - 180, false, true, true] call dyn_spawn_covered_inf;
    _allGrps pushBack _grp;

    // trench Inf
    _tDir = [-30, 30] call BIS_fnc_randomInt;
    if ((random 1) > 0.4) then {
        _infPos = getPos (_validBuildings#0);
        _infPos = [60 * (sin (_dir + _tDir)), 60 * (cos (_dir + _tDir) ), 0] vectorAdd _infPos;
        _grp = [_infPos, _dir, false, false, false, true, true] call dyn_spawn_covered_inf;
        _allGrps pushBack _grp;
    };

    // create static Weapon
    for "_i" from 1 to ([1, 2] call BIS_fnc_randomInt) do {
        _sPos = getPos (_validBuildings#_i);
        _sPos = [45 * (sin _dir), 45 * (cos _dir), 0] vectorAdd _sPos;
        [_sPos, _dir] call dyn_spawn_static_weapon;
    };


    

    // create HQ
    _hq = [getPos _aoPos, 250] call dyn_spawn_hq_garrison;
    

    // create empty Vehicles with Fireteam
    for "_i" from 0 to ([0, 1] call BIS_fnc_randomInt) do {
        // _vPos = [[_aoPos], ["water"]] call BIS_fnc_randomPos;
        _grp = [getPos _aoPos, 300] call dyn_spawn_dimounted_inf;
        if !(isNull _grp) then {
            _patrollPos pushBack (getPos (leader _grp));
            _allGrps pushBack _grp;
        };
    };

    // create Patrols
    for "_i" from 0 to ([0, 1] call BIS_fnc_randomInt) do {
        _grp = [_patrollPos] call dyn_spawn_patrol;
        _allGrps pushBack _grp;
    };

    //create Tank/APC
    private _vGrps = [];
    for "_i" from 0 to ([0, 1] call BIS_fnc_randomInt) do {
        _grp = [getPos _aoPos, 150] call dyn_spawn_parked_vehicle;
        _vGrps pushBack _grp;
        _allGrps pushBack _grp;
    };
    [_aoPos, _vGrps] spawn dyn_attack_nearest_enemy;

    //create QRF
    if ((random 1) > 0.3) then {
        [_aoPos, getPos _hq, 500, ([2, 3] call BIS_fnc_randomInt)] spawn dyn_spawn_qrf;
    };

    // Supply Convoy
    if ((random 1) > 0.4) then {
        [_aoPos, getPos _hq, _dir - 180] spawn dyn_spawn_supply_convoy;
    };

    // create Alarmposten

    // for "_i" from 0 to 3 do {
    //     _diff = 360 / 4;
    //     _degree = 1 + _i * _diff;
    //     _aPos = [700 * (sin _degree), 700 * (cos _degree), 0] vectorAdd (getPos _aoPos);
    //     _apos = getPos ((nearestTerrainObjects [_aPos, ["TREE", "FOREST BORDER", "FOREST TRIANGLE", "FOREST SQUARE"], 400, true, true]) select 0);
    //     _aPos =  ASLToATL _apos;
    //     _grp = [_aPos, east, ["cwr3_o_soldier_tl", "cwr3_o_soldier_at_rpg18", "cwr3_o_soldier_ar"]] call BIS_fnc_spawnGroup;
    //     _grp setBehaviour "STEALTH";
    //     (leader _grp) setDir _dir;
    //     _grp setFormDir _dir;
    //     _watchDir = _degree;

    //     [_grp, _hq, _aoPos] spawn {
    //         params  ["_grp", "_hq", "_aoPos"];

    //          waitUntil {sleep 1; triggerActivated _aoPos};

    //          {
    //             _x disableAI "AUTOCOMBAT";
    //          } forEach (units _grp);
    //          _grp setBehaviour "AWARE";
    //          _grp addWaypoint [(getpos _hq), 100];
    //     };
    // };
    //AA
    if ((random 1) > 0.5) then {
        _grp = [getPos _aoPos, _dir] call dyn_spawn_aa;
        _allGrps pushBack _grp;
    };

    // Forest Patrols
    [getPos _aoPos, 2000, [1, 2] call BIS_fnc_randomInt, _aoPos] spawn dyn_spawn_forest_patrol;

    // Hill Cover
    [getPos _aoPos, 2000, 1, _aoPos] spawn dyn_spawn_hill_overwatch;

    // Bridge Defense
    [getPos _aoPos, 2000, 400, _watchPos] spawn dyn_spawn_bridge_defense;

    // side Town Guards
    [_aoPos, getPos _aoPos, [800, 1300] call BIS_fnc_randomInt, _watchPos] spawn dyn_spawn_side_town_guards;

    _allGrps
};

