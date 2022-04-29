// dyn_standart_squad = configFile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry" >> "cwr3_o_rifle_squad";
// dyn_standart_fire_team = configFile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry" >> "cwr3_o_fire_team";
// dyn_standart_at_team = configFile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry" >> "cwr3_o_at_team";
// dyn_standart_trasnport_vehicles = ["cwr3_o_ural_open", "cwr3_o_ural"];
// dyn_standart_combat_vehicles = ["cwr3_o_bmp1", "cwr3_o_bmp2", "cwr3_o_t55"];
// dyn_standart_light_armed_transport = ["cwr3_o_uaz_dshkm", "cwr3_o_uaz_ags30"];
// dyn_standart_MBT = "cwr3_o_t72a";
// dyn_standart_light_amored_vic = "cwr3_o_btr80";
// dyn_standart_flag = "cwr3_flag_ussr";
// dyn_standart_statics_high = ["cwr3_o_nsv_high"];
// dyn_standart_statics_low = ["cwr3_o_nsv_low", "cwr3_o_ags30", "cwr3_o_spg9"];
// dyn_attack_heli = "cwr3_o_mi24d";

dyn_spawn_random_garrison = {
    params ["_buildings", "_amount", "_dir"];

    _rBuildings = +_buildings;
    // _rGrp = createGroup [east, true];
    for "_i" from 0 to _amount - 1 do {
        _grp = createGroup [east, true];
        _b = selectRandom _rBuildings;
        _rBuildings deleteAt (_rBuildings find _b);
        for "_j" from 0 to 2 do {
            _soldier = _grp createUnit [selectRandom [dyn_standart_soldier, dyn_standart_soldier, dyn_standart_mg, dyn_standart_at_soldier], [0,0,0], [], 0, "NONE"];
            _soldier setDir _dir;
        };
        [_b, _grp, _dir] call dyn_garrison_building;
        // (units _grp) joinSilent _rGrp;
        // deleteGroup _grp;
        _grp enableDynamicSimulation true;
    };
    // _rGrp enableDynamicSimulation true;
    // _rGrp setVariable ["pl_not_recon_able", true];
};

dyn_spawn_barriers = {
    params ["_pos", "_dir"];

    for "_i" from 0 to 2 do {
        _rPos = [(10 * _i) * (sin (_dir + ([80, 100] call BIS_fnc_randomInt))), ((10 * _i) * (cos (_dir + ([80, 100] call BIS_fnc_randomInt)))), 0] vectorAdd _pos;
        _razor =  "Land_Razorwire_F"  createVehicle _rPos; // "Land_Razorwire_F" 
        _razor setDir _dir;
        // _trap =  "land_gm_tanktrap_01" createVehicle _rPos;
    };
};

dyn_spawn_mg_team_garrisons = {
    params ["_validBuildings", "_amount", "_dir"];

    _mgGrp = createGroup [east, true];
    _n = 0;
    for "_i" from 0 to 15 do {
        if ((random 1) > 0.4 and _n < _amount) then { 
            _grp = createGroup [east, true];
            dyn_standart_mg createUnit [[0,0,0], _grp];
            dyn_standart_soldier createUnit [[0,0,0], _grp];
            [(_validBuildings#_i), _grp, _dir] call dyn_garrison_building;
            (units _grp) joinSilent _mgGrp;
            _n = _n + 1;
        };
    };
    _mgGrp setVariable ["pl_not_recon_able", true];
    _mgGrp enableDynamicSimulation true;
};

dyn_spawn_covered_vehicle = {
    params ["_pos", "_vicType", "_dir", ["_netOn", true], ["_dismounted", false]];
    private ["_dismountGrp"];
    _grp = grpNull;
    _pos = _pos findEmptyPosition [0, 100, _vicType];
    if ((count _pos) > 0) then {
        _vic = createVehicle [_vicType, _pos];
        _vic setDir _dir;
        // _vic setFuel 0;
        _grp = createVehicleCrew _vic;
        _vic allowCrewInImmobile true;
        {
            _x disableAI "PATH";
        } forEach (units _grp);
        // _grp setBehaviour "SAFE";
        for "_i" from 0 to 3 do {
            _camoPos = [6 * (sin ((getDir _vic) + ([-10, 10] call BIS_fnc_randomInt))), 6 * (cos ((getDir _vic) + ([-10, 10] call BIS_fnc_randomInt))), 0] vectorAdd (getPos _vic);
            (selectRandom dyn_bushes) createVehicle _camoPos;
        };
        // _net =  createVehicle (getPos _vic);

        if (_netOn) then {
            _net = createVehicle ["land_gm_camonet_02_east", getPosATL _vic, [], 0, "CAN_COLLIDE"];
            _net setVectorUp surfaceNormal position _net;
            _net setDir _dir;
        };
    };
    if (_dismounted) then {
        _diPos = [5 * (sin (_dir + 90)), 5 * (cos (_dir + 90)), 0] vectorAdd _pos;
        _dismountGrp = [_diPos, east, dyn_standart_fire_team] call BIS_fnc_spawnGroup;
        _dismountGrp enableDynamicSimulation true;
        [_grp, _dismountGrp, _dir] spawn {
            params ["_grp", "_dismountGrp", "_dir"];

            sleep 20;
            {
                [_x] joinSilent _grp;
            } forEach (units _dismountGrp);

        };
    };

    _grp enableDynamicSimulation true;


    _grp
};

dyn_spawn_parked_vehicle = {
    params ["_pos", "_area", ["_vicTypes", dyn_standart_combat_vehicles], ["_roadDir", 0], ["_empty", false]];
    private ["_vPos", "_roadDir"];
    _vicType = selectRandom _vicTypes;
    private _r = grpNull;
    if (_area > 0) then {
        _road = selectRandom (_pos nearRoads _area);
        _info = getRoadInfo _road;    
        _endings = [_info#6, _info#7];
        _endings = [_endings, [], {_x distance2D player}, "ASCEND"] call BIS_fnc_sortBy;
        _vPos = _endings#0;
        _roadDir = (_endings#1) getDir (_endings#0);
        _vPos = _vPos getPos [(_info#1) / 2, _roadDir + 90];
    }
    else
    {
        _vPos = _pos findEmptyPosition [0, 65, _vicType];
    };
    if !(_vPos isEqualTo []) then {
        _vic = _vicType createVehicle _vPos;
        _vic setDir _roadDir;
        if !(_empty) then {
            _grp = createVehicleCrew _vic;
            _vic allowCrewInImmobile true;
            _r = _grp;
        }
        else
        {
            _vic enableDynamicSimulation true;
        };
        // _grp setBehaviour "SAFE";
    };

    _r
};

dyn_spawn_covered_inf = {
    params ["_pos", "_dir", ["_tree", false], ["_net", false], ["_sandBag", false], ["_bushes", false], ["_trench", false], ["_infType", dyn_standart_squad], ["_covers", []]];
    if (_tree) then {
        _trees = nearestTerrainObjects [_pos, ["TREE", "FOREST BORDER", "FOREST TRIANGLE", "FOREST SQUARE", "FOREST"], 80, true, true];
        if ((count _trees) > 0) then {
            _pos = getPos (_trees#0);
        };
    };
    if (_pos isEqualTo []) exitWith {grpNull};
    private _grp = grpNull; 
    _grp = [_pos, east, _infType] call BIS_fnc_spawnGroup;
    _grp setVariable ["onTask", true];

    [_grp, _pos, _dir, _net, _sandBag, _bushes, _trench, _covers] spawn {
        params ["_grp", "_pos", "_dir", "_net", "_sandBag", "_bushes", "_trench", "_covers"];
        _grp setFormation "LINE";
        _grp setFormDir _dir;
        (leader _grp) setDir _dir;

        if (_net and !_trench) then {
            _comp = selectRandom ["land_gm_camonet_02_east", "Land_CamoNetVar_EAST"];
            _net = _comp createVehicle (getPos (leader _grp));
        };

        if (_trench) then {

            _fortPos = getPos (leader _grp);
            //////////////////////// CUP Trench ////////////////////////

            // _tPos = [5 * (sin _dir), 5 * (cos _dir), 0] vectorAdd _pos;
            // _tPos = [18 * (sin (_dir - 90)), 18 * (cos (_dir - 90)), 0] vectorAdd _tpos;

            // _offset = 0;
            // for "_i" from 0 to 3 do {
            //     _trenchPos = [_offset * (sin (_dir + 90)), _offset * (cos (_dir + 90)), 0] vectorAdd _tPos;
            //     // _tCover = createVehicle ["land_fort_rampart", _trenchPos, [], 0, "CAN_COLLIDE"];
            //     _comp = selectRandom ["land_fort_rampart"];
            //     _tCover =  _comp createVehicle _trenchPos;
            //     _tCover setDir (_dir - 180);
            //     _tCover setPos ([0,0, -0.5] vectorAdd (getPos _tCover));
            //     _offset = _offset + 10;
            //     _wPos = [2 * (sin _dir), 2 * (cos _dir ), 0] vectorAdd _trenchPos;
            //     // _w = createVehicle ["Land_Razorwire_F", _wPos, [], 0, "CAN_COLLIDE"];
            //     _w = "Land_Razorwire_F" createVehicle _wPos;
            //     _w setDir (_dir - 180);

            //     if (_bushes) then {
            //         for "_j" from 0 to 1 do {
            //             _bush = (selectRandom dyn_bushes) createVehicle _trenchPos;
            //             _bush setDir ([0, 360] call BIS_fnc_randomInt);
            //             _bush setPos ([0,0, -0.3] vectorAdd (getPos _bush));
            //         };
            //     };
            // };

            // _tPos2 = [5 * (sin (_dir - 180)), 5 * (cos (_dir - 180)), 0] vectorAdd _pos;
            // _tPos2 = [18 * (sin (_dir - 90)), 18 * (cos (_dir - 90)), 0] vectorAdd _tpos2;

            // _offset2 = 0;
            // for "_i" from 0 to 3 do {
            //     _trenchPos2 = [_offset2 * (sin (_dir + 90)), _offset2 * (cos (_dir + 90)), 0] vectorAdd _tPos2;
            //     _comp = selectRandom ["land_fort_rampart"];
            //     _tCover =  _comp createVehicle _trenchPos2;
            //     _tCover setDir _dir;
            //     _tCover setPos ([0,0, -0.5] vectorAdd (getPos _tCover));
            //     _offset2 = _offset2 + 9;
            // };

            //////////////////////// SOG PF Trench ////////////////////////
            {
                _tPos = [8 * (sin (_dir + _x)), 8 * (cos (_dir + _x)), 0] vectorAdd _fortPos;
                _t = createVehicle ["Land_vn_b_trench_20_01", _tPos, [], 0, "CAN_COLLIDE"];
                _t setDir (getDir (leader _grp));
            } forEach [90, -90];

            _tPos = [5 * (sin _dir), 5 * (cos _dir), 0] vectorAdd _fortPos;
            _tPos = [18 * (sin (_dir - 90)), 18 * (cos (_dir - 90)), 0] vectorAdd _tpos;

            _offset = 0;
            for "_i" from 0 to 3 do {
                _trenchPos = [_offset * (sin (_dir + 90)), _offset * (cos (_dir + 90)), 0] vectorAdd _tPos;
                _offset = _offset + 10;
                _wPos = [1.1 * (sin _dir), 1.1 * (cos _dir ), 0] vectorAdd _trenchPos;
                _w = "Land_Razorwire_F" createVehicle _wPos;
                _w setDir (_dir - 180);

                _tNetPos = [9 * (sin (_dir + 90)), 9 * (cos (_dir + 90)), 0] vectorAdd _trenchPos;
                _tNet = "land_gm_camonet_01_nato" createVehicle _tNetPos;
                _tNet allowDamage false;
                _tNet setDir (_dir - 90);
                _tNet setPos ((getPos _tNet) vectorAdd [0,0,-2.3]);

                if (_bushes) then {
                    for "_j" from 0 to 1 do {
                        _bush = (selectRandom dyn_bushes) createVehicle _wPos;
                        _bush setDir ([0, 360] call BIS_fnc_randomInt);
                        _bush setPos ([0,0, -0.3] vectorAdd (getPos _bush));
                        _bush enableSimulation false;
                    };
                };
            };
        };


        if (_bushes and !_trench) then {
            {
                if ((random 1) > 0.3) then {
                    _distance = [1, 3] call BIS_fnc_randomInt;
                    _bPos = [_distance * (sin (getDir _x)), _distance * (cos (getDir _x)), 0] vectorAdd (getPos _x);
                    _bush = (selectRandom dyn_bushes) createVehicle _bPos;
                    _bush setDir ([0, 360] call BIS_fnc_randomInt);
                    _covers pushBack _bush;
                };
            } forEach (units _grp);
        };


        if !(_trench) then {
            [_grp, _dir, 10, true, _covers, 15, _sandBag] call dyn_line_form_cover;
        }
        else
        {
            [_grp, _dir, 4, false] call dyn_line_form_cover;
        };

    };
    _grp enableDynamicSimulation true;
    _grp
};

dyn_spawn_dimounted_inf = {
    params ["_pos", "_area", ["_barrier", false], ["_armed", false]];
    private ["_vPos", "_roadDir"];

    if (isNil "_pos") exitWith {grpNull};
    _grp = grpNull;
    _vicType = selectRandom dyn_standart_trasnport_vehicles;
    _roadDir = 0;
    if (_armed) then {
        _vicType = selectRandom (dyn_standart_light_armed_transport + dyn_standart_light_amored_vics);
    };
    if (_area > 0) then {
        _road = selectRandom (_pos nearRoads _area);
        if (isNil "_road") exitWith {grpNull};

        _info = getRoadInfo _road;    
        _endings = [_info#6, _info#7];
        _endings = [_endings, [], {_x distance2D player}, "ASCEND"] call BIS_fnc_sortBy;
        _vPos = _endings#0;
        _roadDir = (_endings#1) getDir (_endings#0);
    }
    else
    {
        _vPos = _pos;
    };
    if (isNil "_vPos") exitWith {grpNull};
    _vic = _vicType createVehicle _vPos;
    if (isNil "_roadDir") then {_roadDir = 0};
    _vic setDir _roadDir;
    _grp = [_vPos, east, dyn_standart_fire_team] call BIS_fnc_spawnGroup;
    _grp setFormation "DIAMOND";
    _grp setBehaviour "SAFE";
    if (_armed) then {
        _gunner = (units _grp)#1;
        _gunner moveInGunner _vic;
    };
    if (_barrier) then {
        _vicDir = getDir _vic;
        _bPos = [6 * (sin _vicDir), 6 * (cos _vicDir), 0] vectorAdd getPos _vic;
        _b = "Land_Razorwire_F" createVehicle _bPos;
        _b setDir _vicDir;
    };
    _grp enableDynamicSimulation true;
    _grp
};




dyn_spawn_strongpoint = {
    params ["_trg", "_building", "_dir", "_endTrg"];
    private ["_vicType", "_vicGrp"];

    _bDir = getDir _building;

    // debug
    // _m = createMarker [str (random 1), getPos _building];
    // _m setMarkerType "mil_dot";

    // vehicle
    _xMax = ((boundingBox _building)#1)#0;
    _vPos = [(_xMax + 7) * (sin _bDir), (_xMax + 7) * (cos _bDir), 0] vectorAdd (getPos _building);
    _vicType = selectRandom dyn_standart_trasnport_vehicles;
    if ((random 1) > 0.5) then {
        _vicType = selectRandom dyn_standart_combat_vehicles;
    };
    // _vicType = selectRandom dyn_hq_vehicles;
    // _vPos findEmptyPosition [0, 30, _vicType];
    if !(_vPos isEqualTo []) then {
        // _vic = _vicType createVehicle _vPos;
        _vic = createVehicle [_vicType, _vPos, [], 0, "NONE"];
        _vicGrp = createVehicleCrew _vic;
        _vic setDir _bDir;
        _net = createVehicle ["land_gm_camonet_02_east", getPosATL _vic, [], 0, "CAN_COLLIDE"];
        _net setVectorUp surfaceNormal position _net;
        _net setDir _bdir;
        (driver _vic) disableAI "PATH";
    };
    _vicGrp enableDynamicSimulation true;

    // Continious Inf Spawn (90 degrees)
    // [_trg, _building, _endTrg] spawn dyn_spawn_def_waves;

    // small trench

    _tPos = [10 * (sin (_bDir + 90)), 10 * (cos (_bDir + 90)), 0] vectorAdd _vPos;
    [_tPos, _bDir] spawn dyn_spawn_small_trench;


    {
        _rPos = [8 * (sin (_bDir + _x)), 8 * (cos (_bDir + _x)), 0] vectorAdd (getPos _building);
        _razor =  "Land_Razorwire_F" createVehicle _rPos;
        _razor setDir (_bDir + _x);
    } forEach [-90, 90, 180];

    // garrison
    _grp = [[0,0,0], east, dyn_standart_fire_team] call BIS_fnc_spawnGroup;
    [_building, _grp, _dir] spawn dyn_garrison_building;
    sleep 1;
    (units _grp) joinSilent _vicGrp;

    // Inf
    // _infPos = [10 * (sin (_dir - 180)), 10 * (cos (_dir - 180)), 0] vectorAdd (getPos _building);
    // [_infPos, _dir, false, false, false, false, false, dyn_standart_at_team] spawn dyn_spawn_covered_inf;

    // Roadblock
    _road = [getPos _building, 80] call BIS_fnc_nearestRoad;
    [_road, false] spawn dyn_spawn_razor_road_block;

    // Intel
    // [_trg, getPos _building, "loc_Bunker", "", "colorOPFOR"] call dyn_spawn_intel_markers;
};

dyn_spawn_small_strong_point = {
    params ["_building", "_dir"];

    _gGrp = [[0,0,0], east, dyn_standart_fire_team] call BIS_fnc_spawnGroup;
    [_building, _gGrp, _dir] spawn dyn_garrison_building;

    _bDir = getDir _building;
    _xMax = ((boundingBox _building)#1)#0;
    _infPos = [(_xMax + 2) * (sin _bDir), (_xMax + 2) * (cos _bDir), -0.1] vectorAdd (getPosATL _building);

    _mgGrp = createGroup [east, true];

    _bunker = createVehicle ["land_gm_woodbunker_01_bags", _infPos , [], 0, "CAN_COLLIDE"];
    _bunker setDir _bDir;

    _mg = _mgGrp createUnit [dyn_standart_mg, _infPos, [], 0, "CAN_COLLIDE"];
    _mg setDir _bDir;
    _mg disableAI "PATH";

    _sPos = _infPos getPos [2.5, _bDir + 90];
    _sandBag = createVehicle ["land_gm_sandbags_01_short_01", _sPos, [], 0, "CAN_COLLIDE"];
    _sandBag setDir _bDir;

    _at = _mgGrp createUnit [dyn_standart_at_soldier, _sPos getPos [1, _bDir - 180], [], 0, "CAN_COLLIDE"];
    _at setDir _bDir;
    _at disableAI "PATH";
    _at setUnitPos "MIDDLE";

    _oGrp = [_infPos, _dir, false, false, false, false, false, dyn_standart_fire_team] call dyn_spawn_covered_inf;

    // Wire
    {
        _rPos = [8 * (sin (_bDir + _x)), 8 * (cos (_bDir + _x)), 0] vectorAdd (getPos _building);
        _razor =  "Land_Razorwire_F" createVehicle _rPos;
        _razor setDir (_bDir + _x);
    } forEach [90, -90, 180];

    // Roadblock
    _road = [getPos _building, 80] call BIS_fnc_nearestRoad;
    [_road, false] spawn dyn_spawn_razor_road_block;

    [_gGrp, _oGrp, _mgGrp] spawn {
        params ["_gGrp", "_oGrp", "_mgGrp"];

        sleep 20;

        (units _oGrp) joinSilent _gGrp;
        (units _mgGrp) joinSilent _gGrp;
        _gGrp enableDynamicSimulation true;
    };

    // _gGrp enableDynamicSimulation true;
    _gGrp
};

dyn_spawn_small_trench = {
    params ["_tPos", "_tDir", ["_camo", false], ["_delay", 15]];

    private _grp = [_tPos, east, dyn_standart_fire_team] call BIS_fnc_spawnGroup;
    [_grp, _tPos, _tDir, _camo, _delay] spawn {
        params ["_grp", "_tPos", "_tDir", "_camo", "_delay"];
        sleep 1;
        _grp setFormation "LINE";
        _grp setFormDir _tDir;
        [_grp, _tDir, 2, false] call dyn_line_form_cover;
        (leader _grp) setDir _tDir;
        sleep _delay;
        {
            _x disableAI "PATH";
            _x setUnitPos "MIDDLE";
        } forEach (units _grp);

        {
            _t2Pos = [2.5 * (sin (_tDir + _x)), 2.5 * (cos (_tDir + _x)), 0] vectorAdd (getPos (leader _grp));
            _t = createVehicle ["Land_vn_b_trench_05_01", _t2Pos, [], 0, "CAN_COLLIDE"];
            _t setDir (getDir (leader _grp));
        } forEach [90, -90];
        _rPos = [8 * (sin _tDir), 8 * (cos _tDir), 0] vectorAdd _tPos;
        _razor =  "Land_Razorwire_F" createVehicle _rPos;
        _razor setDir _tDir;
        if (_camo) then {
            for "_i" from 0 to 3 do {
                _camoPos = [8 * (sin (_tDir + ([-10, 10] call BIS_fnc_randomInt))), 8 * (cos (_tDir + ([-10, 10] call BIS_fnc_randomInt))), 0] vectorAdd _tPos;
                (selectRandom dyn_bushes) createVehicle _camoPos;
            };
            _tNetPos = [9 * (sin _tDir), 9 * (cos _tDir), 0] vectorAdd _tPos;
            _tNet = "land_gm_camonet_01_nato" createVehicle _tNetPos;
            _tNet allowDamage false;
            _tNet setDir (_tDir - 90);
            _tNet setPos ((getPos _tNet) vectorAdd [0,0,-2.3]);
        };
    };
    _grp enableDynamicSimulation true;
    _grp
};


dyn_spawn_static_weapon = {
    params ["_pos", "_dir", ["_low", false], ["_camo", true], ["_weapon", ""]];

    if (_weapon isEqualTo "") then { 
        _weapon = selectRandom dyn_standart_statics_high;
        if (_low) then {
            _weapon = selectRandom dyn_standart_statics_low;
        };
    };
    // _swPos = _pos findEmptyPosition [0, 50, _weapon];
    // _static = _weapon createVehicle _swPos;

    _vGrp = grpNull;
    _static = createVehicle [_weapon, _pos, [], 20, "NONE"];
    if !(isNull _static) then {
        _static setDir _dir;
        // _vGrp = createVehicleCrew _static;
        _vGrp = createGroup [east, true];
        _vGrp setVariable ["pl_not_recon_able", true];
        _soldier1 = _vGrp createUnit [dyn_standart_soldier, _pos, [], 2, "NONE"];
        _soldier1 assignAsGunner _static;
        _soldier1 moveInGunner _static;
        _soldier2 = _vGrp createUnit [dyn_standart_soldier, _pos, [], 2, "NONE"];
        _soldier2 setPos ((getPos _static) getPos [4, _dir - 135]);
        _soldier2 setDir _dir;
        doStop _soldier2;
        private _comp = selectRandom ["land_gm_sandbags_01_round_01"];
        if (_low) then {
            _comp = "land_gm_sandbags_01_low_01";
            _soldier2 setUnitPos "DOWN";
        };
        _sPos = [2.5 * (sin _dir), 2.5 * (cos _dir), 0] vectorAdd _pos;
        private _sCover =  _comp createVehicle _sPos;
        _sCover setDir _dir;
        if !(isNil "_sCover") then {
            if (_low) then {
                _sCover attachTo [_static, [0,2,-1.2]];
            }
            else
            {
                _sCover attachTo [_static, [0,2,-2]];
            };
        };
        if (!_low and _camo) then {
            for "_i" from 0 to 1 do {
                _bPos = [1 * (sin _dir), 1 * (cos _dir), 0] vectorAdd _sPos;
                _bush = (selectRandom dyn_bushes) createVehicle _bPos;
                _bush setDir ([0, 360] call BIS_fnc_randomInt);
            };
        };

        {
            _x disableAI "PATH";
        } forEach (units _vGrp);
        // detach _sCover;
        [_vGrp] spawn {
            params ["_vGrp"];
            sleep 5;
            _vGrp enableDynamicSimulation true;
        };
    };
    _vGrp
};

dyn_spawn_aa = {
    params ["_pos", "_dir"];

    _rearPos = [150 * (sin (_dir - 180)), 150 * (cos (_dir - 180)), 0] vectorAdd _pos;
    _rearPos = _rearPos findEmptyPosition [0, 200, "cwr3_o_mtlb_sa13"];
    _aa = "cwr3_o_mtlb_sa13" createVehicle _rearPos;
    _aa setDir _dir;
    createVehicleCrew _aa;
    _iPos = getPos _aa;
    _iPos = [5, 5] vectorAdd _iPos;
    _grp = [_iPos, east, dyn_standart_fire_team] call BIS_fnc_spawnGroup;
    _grp enableDynamicSimulation true;
    _grp
};



dyn_spawn_patrol = {
    params ["_patrolPos", ["_startPos", []]];

    _grp = grpNull;
    if (_startPos isEqualTo []) then {
        _startPos = selectRandom _patrolPos;
        _patrolPos = _patrolPos - [_startPos]
    };
    _grp = [_startPos, east, dyn_standart_at_team] call BIS_fnc_spawnGroup;
    _grp setBehaviour "SAFE";
    {
        _grp addWaypoint [_x, 20];
    } forEach _patrollPos;
    _wp = _grp addWaypoint [_startPos, 20];
    _wp setWaypointType "CYCLE";

    _grp
};

dyn_spawn_forest_patrol = {
    params ["_pos", "_area", "_amount", "_trg", "_defDir"];

    private _forest = selectBestPlaces [_pos, _area, "(1 + forest + trees) * (1 - sea) * (1 - houses)", 70, 20];
    _patrollPos = [];
    private _allGrps = [];;

    {
        _patrollPos pushBack (_x#0);
    } forEach _forest;

    _defPos = _pos getPos [1700, _defDir];
    _patrollPos = [_patrollPos, [], {_x distance2D _defPos}, "ASCEND"] call BIS_fnc_sortBy;

    for "_i" from 0 to (_amount - 1) do {
        _pPos = _patrollPos#(2 * _i);
        _grp = [_pPos, east, dyn_standart_at_team] call BIS_fnc_spawnGroup;
        _grp setBehaviour "SAFE";
        _wpPos = [[[_pPos, 200]], [[_pPos, 50]]] call BIS_fnc_randomPos;
        _grp addWaypoint [_wpPos, 50];
        _wp = _grp addWaypoint [_pPos, 50];
        _wp setWaypointType "CYCLE";
        _allGrps pushBack _grp;
    };

    [_trg, getPos _trg, _allGrps, false] spawn dyn_retreat;

    ////debug
    // _i = 0;
    // {
    //     _m = createMarker [str (random 1), _x];
    //     _m setMarkerText str _i;
    //     _m setMarkerType "mil_dot";
    //     _i = _i + 1
    // } forEach _patrollPos;
};

dyn_spawn_forest_position = {
    params ["_pos", "_area", "_amount", "_trg", "_defDir"];

    private _forest = selectBestPlaces [_pos, _area, "(1 + forest + trees) * (1 - sea) * (1 - houses)", 70, 20];
    _patrollPos = [];
    private _allGrps = [];;

    {
        _patrollPos pushBack (_x#0);
    } forEach _forest;

    _defPos = _pos getPos [1700, _defDir];
    _patrollPos = [_patrollPos, [], {_x distance2D _defPos}, "ASCEND"] call BIS_fnc_sortBy;

    for "_i" from 0 to (_amount - 1) do {
        _pPos = _patrollPos#(2 * _i);
        _grp = [_pPos, _defDir, true, false, true] call dyn_spawn_covered_inf;
        _grp enableDynamicSimulation true;
    };

};

dyn_spawn_hill_overwatch = {
    params ["_pos", "_area", "_amount", "_trg"];

    private _hills = selectBestPlaces [_pos, _area, "2*hills", 70, 5];
    private _hillPos = [];
    private _allGrps = [];

    {
        _hillPos pushBack (_x#0);
    } forEach _hills;

    _hillPos = [_hillPos, [], {_x distance2D (getPos player)}, "ASCEND"] call BIS_fnc_sortBy;

    for "_i" from 0 to (_amount - 1) do {
        _pPos = _hillPos#_i;
        _dir = _pPos getDir Player; 
        _grp = [_pPos, _dir, true, true, true] call dyn_spawn_covered_inf;
        _allGrps pushBack _grp;
    };

    [_trg, getPos _trg, _allGrps, false] spawn dyn_retreat;

    // debug
    // _i = 0;
    // {
        // _m = createMarker [str (random 1), _x];
        // _m setMarkerText str _i;
        // _m setMarkerType "mil_dot";
        // _i = _i + 1
    // } forEach _hillPos;
};


dyn_defended_bridges = [];
dyn_all_bridge_guards = [];

dyn_spawn_bridge_defense = {
    params ["_pos", "_area", "_blkList", "_searchPos"];

    sleep (random 2);

    private _bridges = [];

    _allRoads = _searchPos nearRoads _area;
    {
        if ((_x distance _pos) > _blkList) then {
            if ((getRoadInfo _x) select 8 and surfaceIsWater (getPos _x)) then {
                _bridges pushBack _x;
            };
        };
    } forEach _allRoads;

    _bridges = [_bridges, [], {_x distance2D (getPos player)}, "ASCEND"] call BIS_fnc_sortBy;
    private _defendedBridges = [_bridges#0];

    // debug

    if !(_bridges isEqualTo []) then {
        {
            _bridge = _x;
            _valid = {
                if ((_bridge distance2D _x) < 300) exitWith {false};
                true
            } forEach _defendedBridges;

            if (_valid and !(_bridge in dyn_defended_bridges)) then {
                _defendedBridges pushBack _bridge;
                dyn_defended_bridges pushBack _bridge;
            };
        } forEach _bridges;

        if !(_defendedBridges isEqualTo []) then {
            {
                _bPos = getPos _x;
                _dir = getDir _x;
                _facing = selectRandom [0, -180];
                _distance = [70, 120] call BIS_fnc_randomInt;
                _iPos = [_distance * (sin (_dir + _facing)), _distance * (cos (_dir + _facing)), 0] vectorAdd _bPos;
                _grp = [_iPos, 20, true, true] call dyn_spawn_dimounted_inf;
                _grp enableDynamicSimulation true;
                dyn_all_bridge_guards pushBack _grp;
            } forEach _defendedBridges;
        };
    };

    ////debug
    // _i = 0;
    // {
    //     _m = createMarker [str (random 1), _x];
    //     _m setMarkerText str _i;
    //     _m setMarkerType "mil_dot";
    //     _i = _i + 1;
    // } forEach _defendedBridges;
    // _marker3 = createMarker [format ["left%1", _pos], _searchPos];
    // _marker3 setMarkerShape "ELLIPSE";
    // _marker3 setMarkerSize [_area, _area];
    // _marker3 setMarkerBrush "Border";
    // _marker3 setMarkerColor "colorYellow";
};



dyn_spawn_raod_block = {
    params ["_pos"];

    _road = [_pos, 400, ["TRAIL"]] call BIS_fnc_nearestRoad;
    _roadDir = ((roadsConnectedTo _road) select 0) getDir _road;
    _block = [getPos _road, sideEmpty, (configFile >> "CfgGroups" >> "Empty" >> "military" >> "RoadBlocks" >> "gm_barrier_light"),[],[],[],[],[], _roadDir] call BIS_fnc_spawnGroup;

    // debug
    // _m = createMarker [str (random 1), getPos _road];
    // _m setMarkerText str _i;
    // _m setMarkerType "mil_circle";   
};

dyn_spawn_razor_road_block = {
    params ["_road", ["_armed", false], ["_vehicle", false]];
    private ["_bPos", "_roadDir"];

    _info = getRoadInfo _road;    
    _endings = [_info#6, _info#7];
    _endings = [_endings, [], {_x distance2D player}, "ASCEND"] call BIS_fnc_sortBy;
    _bPos = _endings#0;
    _roadDir = (_endings#1) getDir (_endings#0);

    if (isNil "_bPos") exitWith {};
    _b = "Land_Razorwire_F" createVehicle _bPos;
    _b setDir _roadDir;

    if (_armed) then {
        _sPos = [4 * (sin (_roadDir - 180)), 4 * (cos (_roadDir - 180)), 0] vectorAdd (getPos _b);
        _sPos = [2 * (sin (_roadDir - 90)), 2 * (cos (_roadDir - 90)), 0] vectorAdd _sPos;
        [_sPos, _roadDir, false, false] spawn dyn_spawn_static_weapon;

        // _sCover =  "land_gm_sandbags_01_round_01" createVehicle _sPos;
        // _sCover setDir _roadDir;

        // _vGrp = createGroup east;
        // for "_i" from 0 to 1 do {
        //     _soldier = _vGrp createUnit [dyn_standart_soldier, _sPos, [], 2, "NONE"];
        //     [_soldier] joinSilent _vGrp;
        // };
    };

    if (_vehicle) then {
        _vic = createVehicle [selectRandom (dyn_standart_mechs + [dyn_standart_light_amored_vic]), _bPos getPos [4, _roadDir - 180], [], 0, "CAN_COLLIDE"];
        _grp = createVehicleCrew _vic;
        _vic setDir _roadDir;
        _grp enableDynamicSimulation true;
        _vic enableDynamicSimulation true;

    };
};

dyn_spawn_sandbag_positions = {
    params ["_roads", "_amount"];
    private ["_bPos", "_roadDir"];

    _vGrp = createGroup [east, true];
    for "_i" from 0 to _amount - 1 do {
        _road = selectRandom _roads;
        {
            _roads deleteAt (_roads find _x);
        } forEach ((getPos _road) nearRoads 30);

        _info = getRoadInfo _road;    
        _endings = [_info#6, _info#7];
        _endings = [_endings, [], {_x distance2D player}, "ASCEND"] call BIS_fnc_sortBy;
        _roadWidth = _info#1;
        _bPos = ASLToATL (_endings#0);
        _roadDir = (_endings#1) getDir (_endings#0);

        _sPos = [(_roadWidth / 2) * (sin (_roadDir - 90)), (_roadWidth / 2) * (cos (_roadDir - 90)), -0.2] vectorAdd _bPos;

        _sCover =  "land_gm_sandbags_01_wall_01" createVehicle _sPos;
        _sCover setDir _roadDir;

        _mgPos = [1.1 * (sin (_roadDir - 180)), 1.1 * (cos (_roadDir - 180)), 0] vectorAdd _sPos;
        _lPos = [1.4 * (sin (_roadDir - 90)), 1.4 * (cos (_roadDir - 90)), 0] vectorAdd _mgPos;

        _mgSoldier = _vGrp createUnit [dyn_standart_mg, _mgPos, [], 0, "NONE"];
        // _leSoldier = _vGrp createUnit [dyn_standart_soldier, _lPos, [], 0, "NONE"];

        {
            _x disableAI "PATH";
            _x setUnitPos "MIDDLE";
            _x setDir _roadDir;
            _x doWatch _sPos;
        } forEach [_mgSoldier];//, _leSoldier];
    };
    _vGrp enableDynamicSimulation true;
};


dyn_crossroad_position = {
    params ["_pos", "_area", ["_limit", 4]];
    _allRoads = _pos nearRoads _area;
    _crossRoads = [];
    {
        _r = _x;
        if (count (roadsConnectedTo _r) > 2) then {
            if (count _crossRoads == 0) then {
                _crossRoads pushBackUnique _r;
            }
            else
            {
                _valid = {
                    if (_x distance2D _r < 50) exitWith {false};
                    true
                } forEach _crossRoads;
                if (_valid) then {_crossRoads pushBackUnique _r;};
            };
        }; 
    } forEach _allRoads;

    _allRoads = [_allRoads, [], {_x distance2D _pos}, "ASCEND"] call BIS_fnc_sortBy;

    private _n = 0;
    {
        // //debug
        // _m = createMarker [str (random 1), getPos _x];
        // _m setMarkerType "mil_dot";

        _road = _x;
        _info = getRoadInfo _road;    
        _endings = [_info#6, _info#7];
        _endings = [_endings, [], {_x distance2D player}, "ASCEND"] call BIS_fnc_sortBy;
        _roadWidth = _info#1;
        _rPos = ASLToATL (_endings#0);
        _roadDir = (_endings#1) getDir (_endings#0);
        _bPos = _rPos getPos [_roadWidth - 2, _roadDir + 90];

        _grp = createGroup [east, true];

        _bunker = createVehicle ["land_gm_woodbunker_01_bags", _bPos , [], 0, "CAN_COLLIDE"];
        _bunker setDir _roadDir;

        _mg = _grp createUnit [dyn_standart_mg, _bPos, [], 0, "CAN_COLLIDE"];
        _mg setDir _roadDir;
        _mg disableAI "PATH";

        _sPos = _rPos getPos [_roadWidth - 4.5, _roadDir + 90];
        _sandBag = createVehicle ["land_gm_sandbags_01_short_01", _sPos, [], 0, "CAN_COLLIDE"];
        _sandBag setDir _roadDir;

        _at = _grp createUnit [dyn_standart_at_soldier, _sPos getPos [1, _roadDir - 180], [], 0, "CAN_COLLIDE"];
        _at setDir _roadDir;
        _at disableAI "PATH";
        _at setUnitPos "MIDDLE";

        _sPos2 = _bPos getPos [6, _roadDir - 180];
        _sandBag = createVehicle ["land_gm_sandbags_01_wall_01", _sPos2, [], 0, "CAN_COLLIDE"];
        _sandBag setDir _roadDir;

        _s = _grp createUnit [dyn_standart_soldier, _sPos2 getPos [1, _roadDir], [], 0, "CAN_COLLIDE"];
        _s setDir (_roadDir - 180);
        _s disableAI "PATH";
        _s setUnitPos "MIDDLE";

        [_road, false, true] call dyn_spawn_razor_road_block;
        _grp enableDynamicSimulation true;
        // [_grp, 300, false] spawn dyn_auto_suppress;
        _n = _n + 1;
        if (_n >= _limit) exitWith {};

    } forEach _crossRoads;
};

dyn_town_at_defence = {
    params ["_locPos", "_dir", "_allBuildings", "_trg", "_amount"];
    private ["_losPos"];

    if (_amount == 0) exitWith {};

    private _watchPos = _locPos getPos [1000, _dir];

    _allBuildings = [_allBuildings, [], {_x distance2D _watchPos}, "ASCEND"] call BIS_fnc_sortBy;;

    private _losOffset = 15;
    private _maxLos = 0;
    private _losStartLine = (getpos (_allBuildings#0)) getpos [[5, 20] call BIS_fnc_randomInt, _dir];
    private _validLosPos = [];
    private _accuracy = [10, 20] call BIS_fnc_randomInt;
    private _defenceArea = [100, 250] call BIS_fnc_randomInt;

    for "_j" from 0 to _accuracy do {
        if (_j % 2 == 0) then {
            _losPos = (_losStartLine getPos [2, _dir]) getPos [_losOffset, _dir + 90];
        }
        else
        {
            _losPos = (_losStartLine getPos [2, _dir]) getPos [_losOffset, _dir - 90];
        };
        _losOffset = _losOffset + (_defenceArea / _accuracy);


        _losPos = [_losPos, 1] call dyn_convert_to_heigth_ASL;

        private _losCount = 0;
        for "_l" from 10 to 510 step 50 do {

            _checkPos = _losPos getPos [_l, _dir];
            _checkPos = [_checkPos, 1] call dyn_convert_to_heigth_ASL;
            _vis = lineIntersectsSurfaces [_losPos, _checkPos, objNull, objNull, true, 1, "VIEW"];

            if !(_vis isEqualTo []) exitWith {};

            _losCount = _losCount + 1;
        };
        if (isNull (roadAt _losPos)) then {
            _validLosPos pushback [_losPos, _losCount];
        };
    };

    _validLosPos = [_validLosPos, [], {_x#1}, "DESCEND"] call BIS_fnc_sortBy;

    for "_i" from 1 to _amount do {
        [(_validLosPos#_i)#0, _dir, true, true, selectRandom dyn_standart_statics_atgm] call dyn_spawn_static_weapon;

        _spawnPos = ((_validLosPos#_i)#0) getpos [10, _dir + 90];

        _grp = createGroup [east, true];
        _grp setVariable ["pl_not_recon_able", true];
        {    
            _s = _grp createUnit [_x, _spawnPos, [], 0, "NONE"];
            _s disableAI "PATH"; 
            _s setUnitPos "MIDDLE";
            _s setDir _dir;
            _s enableDynamicSimulation true;
            _bPos = _s getPos [[8, 15] call BIS_fnc_randomInt, _dir + ([-15, 15] call BIS_fnc_randomInt)];
            for "_i" from 0 to ([0, 1] call BIS_fnc_randomInt) do {
                _bush = (selectRandom dyn_bushes) createVehicle _bPos;
                _bush setDir ([0, 360] call BIS_fnc_randomInt);
            };
        } forEach [dyn_standart_at_soldier, dyn_standart_at_soldier];

        [_grp, _dir, 2, false] call dyn_line_form_cover;

        _sPos = _spawnPos getPos [2, _dir];
        _sCover =  "land_gm_sandbags_01_wall_01" createVehicle _sPos;
        _sCover setDir _dir; 

        _tNetPos = _spawnPos getPos [8, _dir];
        _tNet = "land_gm_camonet_01_nato" createVehicle _tNetPos;
        _tNet allowDamage false;
        _tNet setDir (_dir - 90);
        _tNet setPos ((getPos _tNet) vectorAdd [0,0,-2.7]);
    };

};

dyn_forest_defence_edge = {
    params ["_lineCenter", "_dir", ["_amount", 2], ["_lineWidth", 2000], ["_lineHeight", 1500], ["_accuracy", 100]];

    private _watchPos = _lineCenter getPos [3000, _dir];
    private _terrain = [_lineCenter, _dir, _lineWidth,_lineHeight, _accuracy] call dyn_terrain_scan;
    
    dyn_terrain = _terrain;
    // forest
    // if ((_terrain#0) < (_accuracy * _accuracy) * 0.15) exitWith {hint "cancel"};

    private _lineStartPos = _lineCenter getPos [_lineWidth / 2, _dir - 90];
    private _positionAmount = round (_accuracy * 0.2);
    private _offsetStep = round (_accuracy / _positionAmount);
    private _offset = 0;

    private _terrainGrid = _terrain#3; 

    private _forestPosEdge = [];
    private _forestPosCenter = [];
    private _ii = 0;
    for "_i" from 1 to _positionAmount do {
        _checkGridLine = _terrainGrid#_offset;

        if (((_checkGridLine#0)#1) != "forest") then {
            _ii = 0;
            while {_ii < _accuracy - 1} do {

                _checkPos = _checkGridLine#_ii;
                if ((_checkPos#1) == "forest") exitWith {

                    // _m = createMarker [str (random 4), _checkPos#0];
                    // _m setMarkerType "mil_marker";
                    // _m setMarkerColor "colorRed";

                    _forestPosEdge pushBack [_checkPos#0, "edge"];
                };
                _ii = _ii + 1;
            };
        } else {
            // _m = createMarker [str (random 4), (_checkGridLine#0)#0];
            // _m setMarkerType "mil_marker";
            // _m setMarkerColor "colorBlue";
            _forestPosCenter pushBack [(_checkGridLine#0)#0, "center"];
        };
        _offset = _offset + _offsetStep;
    };

    if (count _forestPosEdge <= 0 or _amount <= 0) exitWith {};


    _forestPosEdge = [_forestPosEdge, [], {(_x#0) distance2D ((_terrainGrid#(round (_accuracy / 2)))#(round (_accuracy / 2)))#0}, "ASCEND"] call BIS_fnc_sortBy;

    if ((count _forestPosEdge) > _amount) then {_forestPosEdge resize _amount};

    for "_j" from 0 to (count _forestPosEdge) - 1 do {

        _spawnPos = (_forestPosEdge#_j)#0;
        _spawnPos = _spawnPos getpos [30, _dir - 180];

        _grp = [_spawnPos, east, dyn_standart_squad] call BIS_fnc_spawnGroup;
        _grp setFormDir _dir;
        (leader _grp) setDir _dir;
        _grp enableDynamicSimulation true;

        if ((random 1) > 0.5) then {
            [_spawnPos getPos [30, _dir + 90], _dir, true, true, selectRandom dyn_standart_statics_atgm] call dyn_spawn_static_weapon;
        };
    };
};


dyn_intel_markers = [];

dyn_spawn_intel_markers = {
    params ["_trg", "_pos", "_type", "_text", ["_color", ""], ["_size", 0.7], ["_alpha", 1]];

    if !(isNull _trg) then { waitUntil {sleep 1; triggerActivated _trg}};

    _pos = [[[_pos, 50]], []] call BIS_fnc_randomPos;
    _intelMarker = createMarker [format ["im%1", random 2], _pos];
    _intelMarker setMarkerType _type;
    _intelMarker setMarkerSize [_size, _size];
    _intelMarker setMarkerText _text;
    _intelMarker setMarkerAlpha _alpha;
    if !(_color isEqualTo "") then {
        _intelMarker setMarkerColor _color;
    };

    dyn_intel_markers pushBack _intelMarker;
    _intelMarker
};


dyn_spawn_intel_markers_area = {
    params ["_trg", "_pos", ["_color", "colorOpfor"], ["_size", 1500], ["_sizeYoff", 0.66], ["_mDir", [0, 359] call BIS_fnc_randomInt]];

    if !(isNull _trg) then { waitUntil {sleep 1; triggerActivated _trg}};

    _intelMarker = createMarker [format ["im%1", random 2], _pos];
    _intelMarker setMarkerColor _color;
    _intelMarker setMarkerShape "ELLIPSE";
    _intelMarker setMarkerBrush "BDiagonal";
    _intelMarker setMarkerAlpha 0.9;
    _intelMarker setMarkerDir _mDir;
    _intelMarker setMarkerSize [_size, _size * _sizeYoff];

    dyn_intel_markers pushBack _intelMarker;
    _intelMarker
};