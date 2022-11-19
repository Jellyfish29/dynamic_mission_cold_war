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
    private ["_dismountGrp", "_diPos"];
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

        if (_dismounted) then {
            _diPos = _pos getpos [5, 90];
            _dismountGrp = [_diPos, east, dyn_standart_fire_team] call BIS_fnc_spawnGroup;
            if !([_diPos] call dyn_is_town) then {
                [_dismountGrp, _dir, 10, true, [], 15, false] call dyn_line_form_cover;
            };
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
    };
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

            [_grp] call dyn_arty_dmg_reduction;

            _fortPos = getPos (leader _grp);
            //////////////////////// CUP Trench ////////////////////////

            _tPos = [5 * (sin _dir), 5 * (cos _dir), 0] vectorAdd _pos;
            _tPos = [18 * (sin (_dir - 90)), 18 * (cos (_dir - 90)), 0] vectorAdd _tpos;

            _offset = 0;
            for "_i" from 0 to 3 do {
                _trenchPos = [_offset * (sin (_dir + 90)), _offset * (cos (_dir + 90)), 0] vectorAdd _tPos;

                // _tCover = createVehicle ["land_fort_rampart", _trenchPos, [], 0, "CAN_COLLIDE"];
                _comp = selectRandom ["land_fort_rampart"];
                _tCover =  _comp createVehicle _trenchPos;
                _tCover setDir (_dir - 180);
                _tCover setPos ([0,0, -0.5] vectorAdd (getPos _tCover));
                _tPosASL = getPosASL _tCover;
                _offset = _offset + 10;
                // _wPos = [3 * (sin _dir), 3 * (cos _dir ), 0] vectorAdd _trenchPos;
                // // _w = createVehicle ["Land_Razorwire_F", _wPos, [], 0, "CAN_COLLIDE"];
                // _w = "Land_Razorwire_F" createVehicle _wPos;
                // _w setDir (_dir - 180);

                _tNetPos = _trenchPos getPos [6, _dir];
                _tNet = "land_gm_camonet_01_nato" createVehicle _tNetPos;
                _tNet allowDamage false;
                _tNet setDir (_dir - 90);
                _tNet setPos ((getPos _tNet) vectorAdd [0,0,-2.5]);

                if (_bushes) then {
                    for "_j" from 0 to 1 do {
                        _bush = (selectRandom dyn_bushes) createVehicle _trenchPos;
                        _bush setDir ([0, 360] call BIS_fnc_randomInt);
                        _bush setPos (_trenchPos getPos [[3, 6] call BIS_fnc_randomInt, _dir]);
                    };
                };
            };

            _tPos2 = [5 * (sin (_dir - 180)), 5 * (cos (_dir - 180)), 0] vectorAdd _pos;
            _tPos2 = [18 * (sin (_dir - 90)), 18 * (cos (_dir - 90)), 0] vectorAdd _tpos2;

            _offset2 = 0;
            for "_i" from 0 to 3 do {
                _trenchPos2 = [_offset2 * (sin (_dir + 90)), _offset2 * (cos (_dir + 90)), 0] vectorAdd _tPos2;
                // _tCover = createVehicle ["land_fort_rampart", _trenchPos2, [], 0, "CAN_COLLIDE"];
                _comp = selectRandom ["land_fort_rampart"];
                _tCover =  _comp createVehicle _trenchPos2;
                _tCover setDir _dir;
                _tCover setPos ([0,0, -0.5] vectorAdd (getPos _tCover));
                _offset2 = _offset2 + 9;
            };

            [_grp, _pos, _dir] spawn {
                params ["_grp", "_pos", "_dir"];

                _callsign = groupId _grp;
                waitUntil {sleep 5; _callsign in pl_marta_dic};
                [objNull, _pos, "marker_position", "", "colorOpfor", 0.8, 1, _dir, false] spawn dyn_spawn_intel_markers;
            };

            //////////////////////// SOG PF Trench ////////////////////////
            // {
            //     _tPos = [8 * (sin (_dir + _x)), 8 * (cos (_dir + _x)), 0] vectorAdd _fortPos;
            //     _t = createVehicle ["Land_vn_b_trench_20_01", _tPos, [], 0, "CAN_COLLIDE"];
            //     _t setDir (getDir (leader _grp));
            // } forEach [90, -90];

            // _tPos = [5 * (sin _dir), 5 * (cos _dir), 0] vectorAdd _fortPos;
            // _tPos = [18 * (sin (_dir - 90)), 18 * (cos (_dir - 90)), 0] vectorAdd _tpos;

            // _offset = 0;
            // for "_i" from 0 to 3 do {
            //     _trenchPos = [_offset * (sin (_dir + 90)), _offset * (cos (_dir + 90)), 0] vectorAdd _tPos;
            //     _offset = _offset + 10;
            //     _wPos = [1.1 * (sin _dir), 1.1 * (cos _dir ), 0] vectorAdd _trenchPos;
            //     _w = "Land_Razorwire_F" createVehicle _wPos;
            //     _w setDir (_dir - 180);

            //     _tNetPos = [9 * (sin (_dir + 90)), 9 * (cos (_dir + 90)), 0] vectorAdd _trenchPos;
            //     _tNet = "land_gm_camonet_01_nato" createVehicle _tNetPos;
            //     _tNet allowDamage false;
            //     _tNet setDir (_dir - 90);
            //     _tNet setPos ((getPos _tNet) vectorAdd [0,0,-2.3]);

            //     if (_bushes) then {
            //         for "_j" from 0 to 1 do {
            //             _bush = (selectRandom dyn_bushes) createVehicle _wPos;
            //             _bush setDir ([0, 360] call BIS_fnc_randomInt);
            //             _bush setPos ([0,0, -0.3] vectorAdd (getPos _bush));
            //             _bush enableSimulation false;
            //         };
            //     };
            // };
        };


        if (_bushes and !_trench) then {
            {
                if ((random 1) > 0.3) then {
                    _distance = [4, 6] call BIS_fnc_randomInt;
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


dyn_spawn_strong_point = {
    params ["_building", "_dir"];

    _gGrp = [[0,0,0], east, dyn_standart_fire_team] call BIS_fnc_spawnGroup;
    [_building, _gGrp, _dir] spawn dyn_garrison_building;

    _bDir = getDir _building;
    _xMax = ((boundingBox _building)#1)#0;

    private _bSidePosArray = [];
    {
        _bSidePosArray pushback [_building getpos [_xMax + 2, _bDir + _x], _bDir + _x];
    } forEach [0, 90, 180, 270];

    _bSidePosArray = [_bSidePosArray, [], {(_x#0) distance2D player}, "ASCEND"] call BIS_fnc_sortBy;

    _infPos = (_bSidePosArray#0)#0;

    _mgGrp = createGroup [east, true];

    _bunker = createVehicle ["land_gm_woodbunker_01_bags", _infPos , [], 0, "CAN_COLLIDE"];
    _bunker setDir (_bSidePosArray#0)#1;

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

    for "_i" from 1 to 3 do {
        _rPos = (_bSidePosArray#_i)#0;;
        _razor =  "Land_Razorwire_F" createVehicle _rPos;
        _razor setDir (_bSidePosArray#_i)#1;;
    };


    // Roadblock
    _road = [getPos _building, 80] call BIS_fnc_nearestRoad;
    if !(isNull _road) then {
    // [_road, false] spawn dyn_spawn_razor_road_block;

        [_road, player, selectRandom [true, false]] call dyn_spawn_heavy_roadblock;
    };

    [_gGrp, _oGrp, _mgGrp] spawn {
        params ["_gGrp", "_oGrp", "_mgGrp"];

        sleep 20;

        (units _oGrp) joinSilent _gGrp;
        (units _mgGrp) joinSilent _gGrp;
        _gGrp enableDynamicSimulation true;

        [_gGrp] call dyn_arty_dmg_reduction;
    };

    // _gGrp enableDynamicSimulation true;

    [_gGrp, getPos _building, _dir] spawn {
        params ["_grp", "_pos", "_dir"];

        _callsign = groupId _grp;
        waitUntil {sleep 5; _callsign in pl_marta_dic};
        [objNull, _pos, "loc_bunker", "", "colorOpfor", 1.5, 1, 0, false] spawn dyn_spawn_intel_markers;
    };
    _gGrp
};

dyn_spawn_small_strongpoint = {
    params ["_building", "_dir"];

    // _m = createMarker [str (random 2), getPos _building];
    // _m setMarkerType "mil_dot";
    _bDir = getDir _building;
    _xMax = ((boundingBox _building)#1)#0;

    _bSidePosArray = [];
    {
        _bSidePosArray pushback [_building getpos [_xMax + 1.5, _bDir + _x], _x];
    } forEach [0, 90, 180, 270];

    _bSidePosArray = [_bSidePosArray, [], {(_x#0) distance2D player}, "ASCEND"] call BIS_fnc_sortBy;

    _bPos = (_bSidePosArray#0)#0;
    _bPosDir = _bDir + (_bSidePosArray#0)#1;

    _grp = createGroup [east, true];
    for "_i" from 0 to 2 do {
        dyn_standart_soldier createUnit [[0,0,0], _grp];
    };
    [_building, _grp, _dir] call dyn_garrison_building;

    if !([_bPos] call dyn_is_indoor) then {

        _bunker = createVehicle ["land_gm_sandbags_01_round_01", _bPos , [], 0, "CAN_COLLIDE"];
        _bunker setDir _bPosDir;
        _mg = _grp createUnit [dyn_standart_mg, _bPos, [], 0, "CAN_COLLIDE"];
        _mg setDir _bPosDir;
        _mg disableAI "PATH";

        _sPos = _bPos getPos [2.5, _bPosDir + (selectRandom [-90, 90])];
        _sandBag = createVehicle ["land_gm_sandbags_01_short_01", _sPos, [], 0, "CAN_COLLIDE"];
        _sandBag setDir _bPosDir;

        _at = _grp createUnit [dyn_standart_at_soldier, _sPos getPos [1, _bPosDir - 180], [], 0, "CAN_COLLIDE"];
        _at setDir _bPosDir;
        _at disableAI "PATH";
        _at setUnitPos "MIDDLE";

        // [_bPos getPos [15, _dir], _dir + ([-10, 10] call BIS_fnc_randomInt)] call dyn_spawn_barriers;
    };

    _grp setVariable ["pl_not_recon_able", true];
    _grp enableDynamicSimulation true;

};

dyn_spawn_static_weapon = {
    params ["_pos", "_dir", ["_low", false], ["_camo", true], ["_weapon", ""], ["_sandBag", true]];

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
        } else {
            _soldier2 setUnitPos "MIDDLE";
        };
        _sPos = [2.5 * (sin _dir), 2.5 * (cos _dir), 0] vectorAdd _pos;
        if (_sandBag) then {
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
        };
        if (!_low and _camo) then {
            for "_i" from 0 to 2 do {
                _bPos = [1 * (sin _dir), 1 * (cos _dir), 0] vectorAdd (getPosATLVisual _static);
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
        // _patrolPos = _patrolPos - [_startPos]
    };
    _grp = [_startPos, east, dyn_standart_at_team] call BIS_fnc_spawnGroup;
    _grp setBehaviour "SAFE";
    _grp setVariable ["pl_not_recon_able", true];
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
        _grp setVariable ["pl_not_recon_able", true];
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
                [[_iPos, 50, []] call dyn_nearestRoad] call dyn_spawn_heavy_roadblock
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


dyn_crossroad_position = {
    params ["_pos", "_area", ["_limit", 4], ["_checkPoint", false]];
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
        if (_checkPoint) then {
            [_x, player, true, true] call dyn_spawn_heavy_roadblock;
        } else {
            _grp = [_x, 25, dyn_standart_combat_vehicles + [dyn_standart_MBT] + [dyn_standart_light_amored_vic]] call dyn_spawn_parked_vehicle;
        };
        _n = _n + 1;

        // _m = createMarker [str (random 1), _x];
        // _m setMarkerType "mil_marker";

        if (_n >= _limit) exitWith {};

    } forEach _crossRoads;
};

dyn_town_entry_checkpoints = {
    params ["_townPos", ["_radius", 450], ["_limit", 4]];

    private _lastPos = [0,0,0];
    private _cpPositions = [];
    for "_i" from 0 to 359 do {

        _checkPos = _townPos getpos [_radius, _i];
        if (isOnRoad _checkPos and ((_checkPos distance2D _lastPos) > 50)) then {

            _road = roadAt _checkPos;
            _info = getRoadInfo _road;

            if ((_info#0) in ["ROAD", "MAIN ROAD"]) then { 
                _lastPos = _checkPos;
                _cpPositions pushback [_road, _checkPos getPos [100, _i]];
            };
        };
    }; 

    _cpPositions = [_cpPositions, [], {(getpos (_x#0)) distance2D player}, "ASCEND"] call BIS_fnc_sortBy;

    private _n = 0;
    {
        _n = _n + 1;
        if (_n > _limit) exitWith {};

        [_x#0, _x#1, true, false] call dyn_spawn_heavy_roadblock;

        //debug
        // _m = createMarker [str (random 1), getpos (_x#0)];
        // _m setMarkerType "mil_dot";
    } forEach _cpPositions;
};

dyn_spawn_heavy_roadblock = {
    params ["_road", ["_dirCheck", player], ["_armedVehicle", true], ["_mines", false]];

    private _info = getRoadInfo _road;    
    private _endings = [_info#6, _info#7];
    private _endings = [_endings, [], {_x distance2D _dirCheck}, "ASCEND"] call BIS_fnc_sortBy;
    private _roadWidth = _info#1;
    private _rPos = ASLToATL (_endings#0);
    private _roadDir = (_endings#1) getDir (_endings#0);

    _leftOrRight = selectRandom [90, -90];

    _bPos = _rPos getPos [_roadWidth - 2, _roadDir +_leftOrRight];

    _grp = createGroup [east, true];

    // bunker
    _bunker = createVehicle [selectRandom ["land_gm_woodbunker_01_bags", "land_gm_sandbags_02_bunker_high"], _bPos , [], 0, "CAN_COLLIDE"];
    _bunker setDir _roadDir;

    _mg = _grp createUnit [dyn_standart_mg, _bPos, [], 0, "CAN_COLLIDE"];
    _mg setDir _roadDir;
    _mg disableAI "PATH";

    // side sandbag with RPG
    if (random (1) > 0.25) then {
        _sPos = _rPos getPos [_roadWidth - 4.5, _roadDir + _leftOrRight];
        _sandBag = createVehicle ["land_gm_sandbags_01_short_01", _sPos, [], 0, "CAN_COLLIDE"];
        _sandBag setDir _roadDir;

        _at = _grp createUnit [dyn_standart_at_soldier, _sPos getPos [1, _roadDir - 180], [], 0, "CAN_COLLIDE"];
        _at setDir _roadDir;
        _at disableAI "PATH";
        _at setUnitPos "MIDDLE";
    };

    // reverse Sandbag
    if (random (1) > 0.5) then {
        _sPos2 = _bPos getPos [6, _roadDir - 180];
        _sandBag = createVehicle ["land_gm_sandbags_01_wall_01", _sPos2, [], 0, "CAN_COLLIDE"];
        _sandBag setDir _roadDir;

        _s = _grp createUnit [dyn_standart_soldier, _sPos2 getPos [1, _roadDir], [], 0, "CAN_COLLIDE"];
        _s setDir (_roadDir - 180);
        _s disableAI "PATH";
        _s setUnitPos "MIDDLE";
    };

    // other side sandbag
    if (random (1) > 0.5) then {
        _bPos2 = _rPos getPos [_roadWidth - 2, _roadDir - _leftOrRight];
        _sandBag = createVehicle [ selectRandom ["land_gm_sandbags_01_round_01", "land_gm_sandbags_02_bunker_high"], _bPos2 , [], 0, "CAN_COLLIDE"];
        _sandBag setDir _roadDir;

        _s2 = _grp createUnit [dyn_standart_at_soldier, _bPos2, [], 0, "CAN_COLLIDE"];
        _s2 setDir _roadDir;
        _s2 disableAI "PATH";
        _s2 setUnitPos "MIDDLE";

        // reverse
        if (random (1) > 0.25) then {
            _bPos3 = _bPos2 getPos [10, _roadDir - 180];
            _sandBag = createVehicle ["land_gm_sandbags_01_round_01", _bPos3 , [], 0, "CAN_COLLIDE"];
            _sandBag setDir _roadDir - 180;

            _s3 = _grp createUnit [dyn_standart_soldier, _bPos3 getPos [1, _roadDir], [], 0, "CAN_COLLIDE"];
            _s3 setDir _roadDir -180;
            _s3 disableAI "PATH";
            _s3 setUnitPos "MIDDLE";
        };
    };

    // RazorWire
    if (random(1) > 0.5) then {
        _b = "Land_Razorwire_F" createVehicle (_rPos getPos [5, _roadDir]);
        _b setDir _roadDir;
    } else {
        _comp = selectRandom ["Land_CncBlock_D", "Land_TyreBarrier_01_line_x4_F"];
        _leftPos = (_rPos getPos [5, _roadDir]) getPos [_roadWidth * 0.25, _roadDir - 90];
        _b = createVehicle [_comp, _leftPos , [], 0, "CAN_COLLIDE"];
        _b setDir _roadDir - 180;

        _rightPos = (_rPos getPos [15, _roadDir]) getPos [_roadWidth * 0.25, _roadDir + 90];
        _b = createVehicle [_comp, _rightPos , [], 0, "CAN_COLLIDE"];
        _b setDir _roadDir - 180;
    };

    [_grp] call dyn_arty_dmg_reduction;

    _grp enableDynamicSimulation true;
    private _vicGrp = grpNull;
    if (_armedVehicle) then {
        _vic = createVehicle [selectRandom (dyn_standart_mechs + [dyn_standart_light_amored_vic] + dyn_standart_combat_vehicles), _rPos getPos [4, _roadDir - 180], [], 0, "CAN_COLLIDE"];
        _VicGrp = createVehicleCrew _vic;
        _vic setDir _roadDir;

        (units _grp) joinSilent _vicGrp;
        _VicGrp enableDynamicSimulation true;
        _vic enableDynamicSimulation true;

    };

    // if ((random 1) > 0.33) then {
    //     [(getPos _road) getPos [50, _roadDir] , _roadDir, objNull, 0, true] spawn dyn_destroyed_cars;
    // };

    if (_mines) then {
        [_rPos getPos [45, _roadDir] , _roadWidth * 4, _roadDir, false, 2, 1] spawn dyn_spawn_mine_field;
    };


    [[_grp, _VicGrp], _rPos, _roadDir] spawn {
        params ["_allGrps", "_pos", "_dir"];

        waitUntil {sleep 5; ({(groupId _x) in pl_marta_dic} count _allGrps) > 0};

        [_pos, 80, _dir, 8] call dyn_draw_mil_symbol_fortification_line;
    };

};

dyn_spawn_screen = {
    params ["_aoPos", "_dir", ["_vics", true]];

    {
        _spawnPos = _aoPos getPos [[600, 800] call BIS_fnc_randomInt, _dir + _x];
        if (_vics) then {
            _grp = [_spawnPos getPos [10, _dir - 180], selectRandom dyn_standart_light_amored_vics, _dir, false, true] call dyn_spawn_covered_vehicle;
            _grp setVariable ["pl_not_recon_able", true];
        };
        _patrollPos = [_spawnPos, _spawnPos getPos [300, _dir - _x], _spawnPos getPos [200, _dir - 180]];
        _grp2 = [_patrollPos] call dyn_spawn_patrol;
        _grp2 setVariable ["pl_not_recon_able", true];
    } forEach [90, - 90];
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


