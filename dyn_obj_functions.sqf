dyn_defense_line = {
    params ["_locPos", "_townTrg", "_dir", ["_exactPos", false]];
    private ["_aoPos", "_defPos", "_objs", "_objAmount", "_road", "_dir", "_patrollPos", "_rearPos", "_grps", "_blkPos", "_width", "_pPos"];

    _width = 1000;

    if (_exactPos) then {
        _defPos = _locPos;
    }
    else
    {
        _distance = [350, 450] call BIS_fnc_randomInt;
        _defPos = [_distance * (sin _dir), _distance * (cos _dir), 0] vectorAdd _locPos;
    };
    // _road = [_defPos, 400, ["TRAIL"]] call BIS_fnc_nearestRoad;
    // if !(isNull _road) then {_defPos = getPos _road};
    _aoPos = createTrigger ["EmptyDetector", _defPos, true];
    _aoPos setTriggerActivation ["WEST SEIZED", "PRESENT", false];
    _aoPos setTriggerStatements ["this", " ", " "];
    _aoPos setTriggerArea [_width, 65, _dir, true];
    _aoPos setTriggerTimeout [30, 40, 50, false];

    _objs = [];
    _objAmount = [3, 4] call BIS_fnc_randomInt;
    // _dir = 360 + ((triggerArea _aoPos)#2);
    _patrollPos = [];
    _blkPos = [[0, 0, 0]];
    _grps = [];

    _area = [400, 600] call BIS_fnc_randomInt;;
    for "_i" from -40 to 40 step (80 / _objAmount) do {
        _pPos = [_area * (sin (_dir + _i)), _area * (cos (_dir + _i)), 0] vectorAdd _defPos;

        _trees = nearestTerrainObjects [_pPos, ["TREE"], 60, true, true];
        if ((count _trees) > 0) then {
            _pPos = getPos (_trees#0);
        };

        _pDir = _dir + _i;
        _grp = [_pPos, _pDir, true, 20] call dyn_spawn_small_trench;
        _grps pushBack _grp;
        _patrollPos pushBack (getPos (leader _grp));
        _leftRight = selectRandom [90, -90];
        _vPos = [10 * (sin (_pDir - _leftRight)), 10 * (cos (_pDir - _leftRight)), 0] vectorAdd (getPos (leader _grp));
        _vGrp = [_vPos, selectRandom dyn_standart_light_amored_vics, _pDir, true] call dyn_spawn_covered_vehicle;
        _grps pushBack _vGrp;
        // natowire
        {
            _rPos = [18 * (sin (_pDir + _x)), 18 * (cos (_pDir + _x)), 0] vectorAdd _pPos;
            _razor =  "Land_Razorwire_F" createVehicle _rPos;
            _razor setDir (_pDir + _x);
            for "_j" from 0 to 4 do {
                _bush = "gm_b_crataegus_monogyna_01_summer" createVehicle _rPos;
                _bush setDir ([0, 360] call BIS_fnc_randomInt);
                // _bush setPos ([0,0, -0.3] vectorAdd (getPos _bush));
                _bush enableSimulation false;
            };  
        } forEach [90, -90];

        // debug
        // _m = createMarker [str (random 1), _pPos];
        // _m setMarkerType "mil_dot";

        sleep 1;
    };
    
    // Spawn Groups at Position
    // _startPos = _defPos; // [250 * (sin - 90), 250 * (cos - 90), 0] vectorAdd _defPos;
    // _offSet = _width / 2;
    // for "_i" from 0 to (_objAmount - 1) do {
    //     // _pos = [[_aoPos], [[_blkPos#_i, 60], "water"]] call BIS_fnc_randomPos;
    //     _offset = _offset - (_width / _objAmount);
    //     _pos = [_offSet * (sin (_dir + 90)), _offSet * (cos (_dir + 90)), 0] vectorAdd _startPos;
    //     // _grp = [_pos, _dir, true, false, false] call dyn_spawn_covered_inf;
    //     _grp = [_pos, _dir, true] call dyn_spawn_small_trench;
    //     _grps pushBack _grp;
    //     _patrollPos pushBack (getPos (leader _grp));
    //     // _blkPos pushBack (getPos (leader _grp));
    //     _leftRight = selectRandom [90, -90];
    //     _vPos = [10 * (sin (_dir - _leftRight)), 10 * (cos (_dir - _leftRight)), 0] vectorAdd (getPos (leader _grp));
    //     _vGrp = [_vPos, selectRandom dyn_standart_light_amored_vics, _dir, false] call dyn_spawn_covered_vehicle;
    //     _grps pushBack _vGrp;
    //     // natowire
    //     {
    //         _rPos = [18 * (sin (_dir + _x)), 18 * (cos (_dir + _x)), 0] vectorAdd _pos;
    //         _razor =  "Land_Razorwire_F" createVehicle _rPos;
    //         _razor setDir (_dir + _x);  
    //     } forEach [90, -90];  
    // };




    // create Patroll
    for "_i" from 0 to 1 do {
        _grp = [_patrollPos, selectRandom _patrollPos] call dyn_spawn_patrol;
        _grps pushBack _grp;
    };

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
    if ((random 1) > 0.85) then {
        _rearPos = [1200 * (sin (_dir - 180)), 1200 * (cos (_dir - 180)), 0] vectorAdd _locPos;
        [_rearPos, _aoPos] spawn dyn_spawn_rocket_arty;
    };

    // heli atk
    if ((random 1) > 0.5) then {
        [_locPos, _dir, _aoPos] spawn dyn_spawn_heli_attack;
    };

    //create counterattack;
    // if ((random 1) > 0.25) then {
        [_aoPos, getPos _aoPos, getPos _townTrg, 2, 3, 2, false, dyn_standart_light_amored_vics, 0] spawn dyn_spawn_counter_attack;
        // [_aoPos, _grps] spawn dyn_attack_nearest_enemy;
        [getPos _townTrg, _grps, _aoPos, 700] spawn dyn_spawn_delay_action;
    // };

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
         _distance = [500, 700] call BIS_fnc_randomInt;
    };

    _offsets = [-10, 10];//[[-5, -30] call BIS_fnc_randomInt, [5, 30] call BIS_fnc_randomInt];
    for "_i" from 0 to 1 do {
        _defPos = [_distance * (sin (_dir + (_offsets#_i))), _distance * (cos (_dir + (_offsets#_i))), 0] vectorAdd _locPos;
        // _defPos = getPos ((nearestTerrainObjects [_defPos, ["TREE", "FOREST BORDER", "FOREST TRIANGLE", "FOREST SQUARE"], 300, true, true]) select 0);
        _aoPos = createTrigger ["EmptyDetector", _defPos, true];
        _aoPos setTriggerActivation ["WEST", "PRESENT", false];
        _aoPos setTriggerStatements ["this", " ", " "];
        _aoPos setTriggerArea [350, 350, _dir, false];

        _grps = [];
        _degree = [-90, 90];
        _watchDegree = [-20, 20];
        for "_j" from 0 to 1 do {
            _nDir = _dir + (_degree#_j);
            _nPos = [55 * (sin _nDir), 55 * (cos _nDir), 0] vectorAdd _defPos;
            _grp = [_nPos, _dir + (_watchDegree#_j), false, true, false, true, true] call dyn_spawn_covered_inf;
            _grps pushBack _grp;

            _nvPos = [20 * (sin (_dir - 180)), 20 * (cos (_dir - 180)), 0] vectorAdd _nPos;
            _grp = [_nvPos, dyn_standart_combat_vehicles#0, _dir] call dyn_spawn_covered_vehicle;
            _grps pushBack _grp;
        };
        _grp = [_defPos, dyn_standart_MBT, _dir] call dyn_spawn_covered_vehicle;
        _grps pushBack _grp;



        if ((random 1) > 0.45) then {
            [_aoPos, _defPos, getPos _townTrg, [2, 3] call BIS_fnc_randomInt, [1, 2] call BIS_fnc_randomInt, 1, false, [dyn_standart_MBT], 0] spawn dyn_spawn_counter_attack;
        };
        if ((random 1) > 0.7) then {
            _rearPos = [1200 * (sin (_dir - 180)), 1200 * (cos (_dir - 180)), 0] vectorAdd _locPos;
            [_rearPos, _aoPos] spawn dyn_spawn_rocket_arty;
        };
        // [_townTrg, getPos _townTrg, _grps] spawn dyn_retreat;
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
    // _atkTrg setTriggerTimeout [30, 45, 70, false];

    private _allTankGrps = [];

    // _m = createMarker [str (random 1), _trgPos];
    // _m setMarkerType "mil_dot";

    for "_i" from 0 to ([3, 4] call BIS_fnc_randomInt) do {
        _vPos = [(70 * _i) * (sin (_dir + 90)), (70 * _i) * (cos (_dir + 90)), 0] vectorAdd _stagingPos;
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
            _isForest = [_lPos] call dyn_is_forest;
            if !(_isForest) then {
                _lWp = _leader addWaypoint [_lPos, 0];
                _syncWps pushBack _lWp;
            };
            {
                _wPos = [(_wpIntervall * _i) * (sin _atkDir), (_wpIntervall * _i) * (cos _atkDir), 0] vectorAdd (getPos (leader _x));
                _isForest = [_wPos] call dyn_is_forest;
                if !(_isForest) then {
                    _gWp = _x addWaypoint [_wPos, 0];
                    _gWp synchronizeWaypoint _syncWps;
                    _syncWps pushBack _gWp;
                };
            } forEach _allTankGrps - [_leader];
        };

        waitUntil {sleep 1; ({alive _x} count _leaders) <= 3};

        // [objNull, _defPos, _allTankGrps, false] spawn dyn_retreat;
        [_defPos, _allTankGrps] spawn dyn_spawn_delay_action;
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
    private ["_allGrps", "_validRoads", "_iGrps"];

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
    // _grad = "cwr3_o_bm21" createVehicle _rearPos;
    // _grp = createVehicleCrew _grad;

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
        _endings = [_endings, [], {_x distance2D _trgPos}, "ASCEND"] call BIS_fnc_sortBy;
        _rPos = _endings#0;
        _rDir = (_endings#1) getDir (_endings#0);
        _vicType = _vicTypes#_i;
        _vic = _vicType createVehicle _rPos;
        _vic setDir _rDir;
        _vic limitSpeed 45;
        _vic setUnloadInCombat [true, false];
        // _vic forceFollowRoad true;
        _grp = createVehicleCrew _vic;
        _grp setBehaviour "SAFE";
        _allGrps pushBack _grp;
        if (_vicType isEqualTo "cwr3_o_btr80") then {
            _iGrp = [_rPos, east, dyn_standart_squad] call BIS_fnc_spawnGroup;
            {
                _x assignAsCargo _vic;
                _x moveInCargo _vic;
                [_x] joinSilent _grp;
            } forEach (units _iGrp);
        };  
    };

    [_allGrps, _atkTrg, _rearPos, _townTrg, _locPos, _dir] spawn {
        params ["_allGrps", "_atkTrg", "_rearPos", "_townTrg", "_locPos", "_dir"];

         
        _targetRaod = getPos ([getPos _atkTrg, 600] call BIS_fnc_nearestRoad);
        waitUntil { sleep 1; triggerActivated _atkTrg };

        reverse _allGrps;
        {
            _wp = _x addWaypoint [_targetRaod, 20];
            _wp setWaypointType "TR UNLOAD";
            // sleep 1;
        } forEach _allGrps;

        waitUntil {sleep 1; ({alive (leader _x)} count _allGrps) < (count _allGrps)};
        
        _fireSupport = selectRandom [1,2,3];

        //debug
        // _fireSupport = 1;

        switch (_fireSupport) do { 
            case 1 : {[_rearPos, _atkTrg] spawn dyn_spawn_rocket_arty}; 
            case 2 : {[true] spawn dyn_arty};
            case 3 : {[_locPos, _dir] spawn dyn_spawn_heli_attack};
            default {}; 
         }; 

        [objNull, _allGrps] spawn dyn_attack_nearest_enemy;

        //create counterattack;
        // if ((random 1) > 0.25) then {
            [objNull, getPos _atkTrg, getPos _townTrg, [3, 5] call BIS_fnc_randomInt, [2, 3] call BIS_fnc_randomInt, 2] spawn dyn_spawn_counter_attack;
            // [_aoPos, _grps] spawn dyn_attack_nearest_enemy;
        // };
    };
};


dyn_town_defense = {
    params ["_aoPos", "_endTrg", "_dir"];
    private ["_watchPos", "_validBuildings", "_patrollPos", "_allGrps"];
    // private _dir = 360 + ((triggerArea _aoPos)#2);
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

    _garAmount = [2, 3] call BIS_fnc_randomInt;

    // front Garrison
    for "_i" from 0 to (_garAmount - 1) step ([1, 3] call BIS_fnc_randomInt) do {
        _grp = [getPos _aoPos, east, dyn_standart_fire_team] call BIS_fnc_spawnGroup;
        [(_validBuildings#_i), _grp, _dir] spawn dyn_garrison_building;
        if ((random 1) > 0.5) then {_patrollPos pushBack (getPos (_validBuildings#_i))};
        _allGrps pushBack _grp;
    };

    // Flank Attack
    if ((random 1) >= 0.4) then {
        _side = selectRandom [90, -90];
        _flankPos = [1500 * (sin (_dir + _side)), 1500 * (cos (_dir + _side)), 0] vectorAdd (getPos (_validBuildings#0));
        [_aoPos, getPos _aoPos, _flankPos, 3, 1, 0, true, [dyn_standart_MBT], 0, [true, 100], true, false] spawn dyn_spawn_counter_attack;
    };

    // create roádblock
    _bRoad = [getPos (_validBuildings#0), 80] call BIS_fnc_nearestRoad;
    [_bRoad, true] call dyn_spawn_razor_road_block;

    // create static Vehicle
    _validInfBuilding = + _validBuildings;

    for "_i" from 0 to ([1, 2] call BIS_fnc_randomInt) do {
        _vicB = _validInfBuilding#([0, 12] call BIS_fnc_randomInt);
        _validInfBuilding deleteAt (_validInfBuilding find _vicB);
        _vicPos = getPos _vicB;
        _distance = [90, 120] call BIS_fnc_randomInt;
        _vDir = [-20, 20] call BIS_fnc_randomInt;
        _vPos = [_distance * (sin (_dir + _vDir)), _distance * (cos (_dir + _vDir)), 0] vectorAdd _vicPos;
        _vicType = selectRandom dyn_standart_combat_vehicles;
        _vPos = _vPos findEmptyPosition [0, 150, _vicType];
        // _vPos = [_vPos, 1, 100, 3, 0, 20, 0] call BIS_fnc_findSafePos;
        _grp = [_vPos, _vicType, _dir] call dyn_spawn_covered_vehicle;
        if !(isNull _grp) then {
            _patrollPos pushBack (getPos (leader _grp));
            _allGrps pushBack _grp;
        };
    };

    // create static Infantry
    // for "_i" from 0 to ([0, 1] call BIS_fnc_randomInt) do {
    //     _infB = (_validInfBuilding#([0, 6] call BIS_fnc_randomInt));
    //     _validInfBuilding deleteAt (_validInfBuilding find _infB);
    //     _infPos = getPos _infB;
    //     _distance = [30, 50] call BIS_fnc_randomInt;
    //     _tDir = [-20, 20] call BIS_fnc_randomInt;
    //     _infPos = [_distance * (sin (_dir + _tDir)), _distance * (cos (_dir + _tDir)), 0] vectorAdd _infPos;
    //     _grp = [_infPos, _dir, false, false, true, false, false, false] call dyn_spawn_covered_inf;
    //     if !(isNull _grp) then {
    //         _patrollPos pushBack (getPos (leader _grp));
    //         _allGrps pushBack _grp;
    //     };
    // };

    private _solitaryBuildings = [];
    {
        _b = _x;
        _ditances = (_validBuildings - [_b]) apply {_x distance2D _b};
        _valid = {
            if (_x <= 20) exitWith {false};
            true
        } forEach _ditances;
        if (_valid) then {
            _solitaryBuildings pushBack _b;

            ////debug
            // _m = createMarker [str (random 1), getPos _b];
            // _m setMarkerType "mil_dot";
        };
    } forEach _validBuildings;
    _solitaryBuildings = [_solitaryBuildings, [], {_x distance2D _watchPos}, "ASCEND"] call BIS_fnc_sortBy;

    // small trench Inf
    for "_i" from 0 to ([1, 2] call BIS_fnc_randomInt) do {
        _infB = (_solitaryBuildings#([0, 7] call BIS_fnc_randomInt));
        _solitaryBuildings deleteAt (_solitaryBuildings find _infB);
        _infPos = getPos _infB;
        _distance = [10, 20] call BIS_fnc_randomInt;
        _tDir = [-10, 10] call BIS_fnc_randomInt;
        _infPos = [_distance * (sin (_dir + _tDir)), _distance * (cos (_dir + _tDir)), 0] vectorAdd _infPos;
        // _grp = [_infPos, _dir] spawn dyn_spawn_small_trench;
        _grp = [_infPos, getDir _infB] spawn dyn_spawn_small_trench;
        _allGrps pushBack _grp;
    };


    // large trench Inf
    // if ((random 1) > 0.25) then {
    //     _distance = [70, 100] call BIS_fnc_randomInt;
    //     _tDir = [-30, 30] call BIS_fnc_randomInt;
    //     _infPos = getPos (_validBuildings#0);
    //     _infPos = [_distance * (sin (_dir + _tDir)), _distance * (cos (_dir + _tDir) ), 0] vectorAdd _infPos;
    //     _grp = [_infPos, _dir, false, false, false, true, true] call dyn_spawn_covered_inf;
    //     _allGrps pushBack _grp;
    // };

    // create static Weapons
    // for "_i" from 0 to ([0, 1] call BIS_fnc_randomInt) do {
    //     _sPos = getPos (_validInfBuilding#_i);
    //     _distance = [30, 60] call BIS_fnc_randomInt;
    //     _sDir = [-20, 20] call BIS_fnc_randomInt;
    //     _sPos = [_distance * (sin (_dir + _sDir)), _distance * (cos (_dir + _sDir)), 0] vectorAdd _sPos;
    //     [_sPos, _dir] call dyn_spawn_static_weapon;
    // };

    // create HQ
    reverse _solitaryBuildings;
    _hqB = _solitaryBuildings#([4, 15] call BIS_fnc_randomInt);
    _solitaryBuildings deleteAt (_solitaryBuildings find _hqB);
    _hqPos = getPos _hqB;
    _hq = [_hqPos, 250, _dir] call dyn_spawn_hq_garrison;

    // [_aoPos, getPos _hq, "o_hq", "CP"] spawn dyn_spawn_intel_markers;

    // create Strongpoint
    [_aoPos, _solitaryBuildings, [1, 2] call BIS_fnc_randomInt, _dir] spawn dyn_spawn_strongpoint;

    //create Tank/APC
    private _vGrps = [];
    for "_i" from 0 to ([1, 2] call BIS_fnc_randomInt) do {
        _grp = [getPos _aoPos, 250, dyn_standart_combat_vehicles + [dyn_standart_MBT] + [dyn_standart_light_amored_vic]] call dyn_spawn_parked_vehicle;
        _vGrps pushBack _grp;
        _allGrps pushBack _grp;
    };
    if ((random 1) > 0.75) then {
        [_aoPos, _vGrps] spawn dyn_attack_nearest_enemy;
    };

    // Supply Convoy
    [_aoPos, getPos _hq, _dir - 180] spawn dyn_spawn_supply_convoy;

    //AA
    if ((random 1) > 0.25) then {
        _grp = [getPos _aoPos, _dir] call dyn_spawn_aa;
        _allGrps pushBack _grp;
        [_aoPos, getPos (leader _grp), "o_antiair", "AA"] spawn dyn_spawn_intel_markers;
    };

    // Forest Patrols
    [getPos _aoPos, 2000, [1, 2] call BIS_fnc_randomInt, _aoPos] spawn dyn_spawn_forest_patrol;

    // Hill Cover
    // [getPos _aoPos, 2000, 1, _aoPos] spawn dyn_spawn_hill_overwatch;

    // Bridge Defense
    [getPos _aoPos, 2000, 400, _watchPos] spawn dyn_spawn_bridge_defense;

    // side Town Guards
    [_aoPos, getPos _aoPos, [800, 1300] call BIS_fnc_randomInt, _watchPos] spawn dyn_spawn_side_town_guards;

    // Continuos Inf Spawn 
    [_aoPos, _hq, _endTrg] spawn dyn_spawn_def_waves;


    _allGrps
};

dyn_defense = {
    params ["_atkPos", "_defPos", "_waitTime"];

    dyn_defense_active = true;

    _linePos = [300 * (sin (_atkPos getDir _defPos)), 300 * (cos (_atkPos getDir _defPos)), 0] vectorAdd _atkPos;
    _lineMarker = createMarker [format ["clLeft%1", _atkPos], _linePos];
    _lineMarker setMarkerShape "RECTANGLE";
    _lineMarker setMarkerSize [8, 800];
    _lineMarker setMarkerDir ((_atkPos getDir _defPos) - 90);
    _lineMarker setMarkerBrush "Horizontal";
    _lineMarker setMarkerColor "colorBLUFOR";

    sleep _waitTime;
    // sleep 2;

    [playerSide, "HQ"] sideChat format ["SPOTREP: Soviet MotRifBtl at GRID: %1 advancing towards %2", mapGridPosition _defPos, [round (_defPos getDir _atkPos)] call dyn_get_cardinal];

    _arrowPos = [(_defPos distance2d _atkPos) / 2 * (sin (_defPos getDir _atkPos)), (_defPos distance2d _atkPos) / 2 * (cos (_defPos getDir _atkPos)), 0] vectorAdd _defPos;
    _arrowMarker = createMarker [format ["arrow%1", _atkPos], _arrowPos];
    _arrowMarker setMarkerType "marker_CATK";
    _arrowMarker setMarkerSize [1, 1];
    _arrowMarker setMarkerColor "colorOPFOR";
    _arrowMarker setMarkerDir ((_defPos getDir _atkPos) - 90);

    sleep 10;

    if (random 1 < 0.5) then {
        [true] spawn dyn_arty;
    }
    else
    {
        [_defPos, _defPos getDir _atkPos] spawn dyn_spawn_heli_attack;
    };

    _waves = [2, 3] call BIS_fnc_randomInt;
    // _waves = 0;

    for "_i" from 0 to _waves do {
        _infAmount = 6;//[4, 5] call BIS_fnc_randomInt;
        _vicAmount = [1, 2] call BIS_fnc_randomInt;
        _delay = [true, 600];
        _vicTypes = ["cwr3_o_t55"];
        _mech = true;
        if (_i == 0) then {
            _vicTypes = [dyn_standart_MBT];
            _vicAmount = _infAmount - 1};
            _mech = true;
        if !(_mech) then {
            _vicAmount = _infAmount;
            _vicTypes = dyn_standart_combat_vehicles
        };
        [objNull, _atkPos, _defPos, _infAmount, _vicAmount, 2, _mech, _vicTypes, 2000, _delay, true, true] spawn dyn_spawn_counter_attack;

        // player sideChat "wave spawn";

        sleep 5;
        { 
            _x addCuratorEditableObjects [allUnits, true]; 
            _x addCuratorEditableObjects [vehicles, true];  
       } forEach allCurators; 

        sleep 120;

        if (random 1 < 0.5) then {
            [] spawn dyn_arty;
        };
    };

    // player sideChat "spawn end";
    _time = time + 200;
    waitUntil {(count (allGroups select {(side (leader _x)) isEqualTo east})) <= 14};

    deleteMarker _arrowMarker;
    deleteMarker _lineMarker;

    _defPos = [400 * (sin (_defPos getDir _atkPos)), 400 * (cos (_defPos getDir _atkPos)), 0] vectorAdd _defPos;

    [objNull, _defPos, allGroups select {(side (leader _x)) isEqualTo east}, true] spawn dyn_retreat;

    sleep 60;

    dyn_defense_active = false;
};
