dyn_standart_squad = configFile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry" >> "cwr3_o_rifle_squad";
dyn_standart_fire_team = configFile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry" >> "cwr3_o_fire_team";
dyn_standart_at_team = configFile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry" >> "cwr3_o_at_team";
dyn_standart_trasnport_vehicles = ["cwr3_o_ural_open", "cwr3_o_ural"];
dyn_standart_combat_vehicles = ["cwr3_o_bmp1", "cwr3_o_btr80", "cwr3_o_bmp2", "cwr3_o_t55"];
dyn_standart_light_armed_transport = ["cwr3_o_uaz_dshkm", "cwr3_o_uaz_ags30"];
dyn_standart_MBT = "cwr3_o_t72a";
dyn_standart_light_amored_vic = "cwr3_o_btr80";
dyn_standart_flag = "cwr3_flag_ussr";
dyn_standart_statics_high = ["cwr3_o_nsv_high"];
dyn_standart_statics_low = ["cwr3_o_nsv_low", "cwr3_o_ags30", "cwr3_o_spg9"];

dyn_spawn_covered_vehicle = {
    params ["_pos", "_vicType", "_dir"];
    _grp = grpNull;
    _pos = _pos findEmptyPosition [0, 100, _vicType];
    if ((count _pos) > 0) then {
        _vic = _vicType createVehicle _pos;
        _vic setDir _dir;
        _vic setFuel 0;
        _grp = createVehicleCrew _vic;
        // _grp setBehaviour "SAFE";
        for "_i" from 0 to 3 do {
            _camoPos = [6 * (sin ((getDir _vic) + ([-10, 10] call BIS_fnc_randomInt))), 6 * (cos ((getDir _vic) + ([-10, 10] call BIS_fnc_randomInt))), 0] vectorAdd (getPos _vic);
            "gm_b_crataegus_monogyna_01_summer" createVehicle _camoPos;
        };
        _net = "Land_CamoNetVar_EAST" createVehicle (getPos _vic);
        // _net allowDamage false;
        _net setDir _dir;
    };
    _grp
};

dyn_spawn_parked_vehicle = {
    params ["_pos", "_area", ["_vicTypes", dyn_standart_combat_vehicles], ["_roadDir", 0]];
    private ["_vPos"];
    _vicType = selectRandom _vicTypes;
    private _r = grpNull;
    if (_area > 0) then {
        _road = selectRandom (_pos nearRoads _area);
        _vpos = getPos _road;
        _vpos = _vpos vectorAdd [1 - random 2, 1 - random 2, 0];
        _roadDir = (getPos ((roadsConnectedTo _road) select 0)) getDir _vpos;
    }
    else
    {
        _vPos = _pos findEmptyPosition [0, 65, _vicType];
    };
    if !(_vPos isEqualTo []) then {
        _vic = _vicType createVehicle _vPos;
        _vic setDir _roadDir;
        _grp = createVehicleCrew _vic;
        _r = _grp;
        // _grp setBehaviour "SAFE";
    };

    _r
};

dyn_spawn_covered_inf = {
    params ["_pos", "_dir", ["_tree", false], ["_net", false], ["_sandBag", false], ["_bushes", false], ["_trench", false]];
    if (_tree) then {
        _pos = getPos ((nearestTerrainObjects [_pos, ["TREE", "FOREST BORDER", "FOREST TRIANGLE", "FOREST SQUARE", "FOREST"], 300, true, true]) select 0);
    };
    if (_pos isEqualTo []) exitWith {grpNull};
    _grp = grpNull;
    _grp = [_pos, east, dyn_standart_squad] call BIS_fnc_spawnGroup;
    _grp setVariable ["onTask", true];

    [_grp, _pos, _dir, _net, _sandBag, _bushes, _trench] spawn {
        params ["_grp", "_pos", "_dir", "_net", "_sandBag", "_bushes", "_trench"];
        private _covers = [];
        _grp setFormation "LINE";
        _grp setFormDir _dir;
        (leader _grp) setDir _dir;
        sleep 20;
        if (_sandBag) then {
            _sPos = getPos (leader _grp);
            _sDir =  getDir (leader _grp);
            _sPos = [0.5 * (sin _sDir), 0.5 * (cos _sDir), 0] vectorAdd _sPos;
            _comp = selectRandom ["land_gm_sandbags_01_round_01", "land_gm_sandbags_01_wall_01"];
            _sCover =  _comp createVehicle _sPos;
            _sCover setDir _sDir;
            _covers pushBack _sCover;
        };

        if (_net) then {
            _comp = selectRandom ["land_gm_camonet_02_east", "Land_CamoNetVar_EAST"];
            _net = _comp createVehicle (getPos (leader _grp));
        };

        if (_trench) then {
            _tPos = [5 * (sin _dir), 5 * (cos _dir), 0] vectorAdd _pos;
            _tPos = [18 * (sin (_dir - 90)), 18 * (cos (_dir - 90)), 0] vectorAdd _tpos;

            _offset = 0;
            for "_i" from 0 to 3 do {
                _trenchPos = [_offset * (sin (_dir + 90)), _offset * (cos (_dir + 90)), 0] vectorAdd _tPos;
                _comp = selectRandom ["land_fort_rampart"];
                _tCover =  _comp createVehicle _trenchPos;
                _tCover setDir (_dir - 180);
                _tCover setPos ([0,0, -0.4] vectorAdd (getPos _tCover));
                _offset = _offset + 10;
            };

            _tPos2 = [4.5 * (sin (_dir - 180)), 4.5 * (cos (_dir - 180)), 0] vectorAdd _pos;
            _tPos2 = [18 * (sin (_dir - 90)), 18 * (cos (_dir - 90)), 0] vectorAdd _tpos2;

            _offset2 = 0;
            for "_i" from 0 to 3 do {
                _trenchPos2 = [_offset2 * (sin (_dir + 90)), _offset2 * (cos (_dir + 90)), 0] vectorAdd _tPos2;
                _comp = selectRandom ["land_fort_rampart"];
                _tCover =  _comp createVehicle _trenchPos2;
                _tCover setDir _dir;
                _tCover setPos ([0,0, -0.4] vectorAdd (getPos _tCover));
                _offset2 = _offset2 + 9;
            };
        };

        sleep 1;

        if (_bushes) then {
            {
                if ((random 1) > 0.3) then {
                    _distance = [1, 3] call BIS_fnc_randomInt;
                    _bPos = [_distance * (sin (getDir _x)), _distance * (cos (getDir _x)), 0] vectorAdd (getPos _x);
                    _bush = "gm_b_crataegus_monogyna_01_summer" createVehicle _bPos;
                    _bush setDir ([0, 360] call BIS_fnc_randomInt);
                    _covers pushBack _bush;
                };
            } forEach (units _grp);
        };

        sleep 5;
        {
            if !(_trench) then {
                [_x, _dir, 15, true, _covers] spawn dyn_find_cover;
            }
            else
            {
                _x disableAI "PATH";
                _x setUnitPos "MIDDLE";
            };
        } forEach (units _grp);

    };
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
        _vicType = selectRandom dyn_standart_light_armed_transport;
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

    _grp
};

dyn_spawn_hq_garrison = {
    params ["_pos", "_area"];

    _buildings = nearestObjects [_pos, ["house"], _area];

    private _validBuildings = [];
    {
        if ((count ([_x] call BIS_fnc_buildingPositions)) >= 8) then {
            _validBuildings pushBack _x;
        };
    } forEach _buildings;

    _validBuildings = [_validBuildings, [], {_x distance2D _pos}, "ASCEND"] call BIS_fnc_sortBy;

    _hq = _validBuildings#([0, 4] call BIS_fnc_randomInt);
    _dir = getDir _hq;

    _grp = [_pos, east, dyn_standart_fire_team] call BIS_fnc_spawnGroup;
    [_hq, _grp, _dir] spawn dyn_garrison_building;

    for "_i" from 0 to ([0, 1] call BIS_fnc_randomInt) do {
        _netPos = [[[getPos _hq, 20]], [[getPos _hq, 10], "water"]] call BIS_fnc_randomPos;
        _net = "land_gm_camonet_02_east" createVehicle _netpos;
        _net setVectorUp surfaceNormal position _net;
        _net setDir _dir;
        _grp = [_netPos, east, dyn_standart_fire_team] call BIS_fnc_spawnGroup;
        _grp setFormation "DIAMOND";
        _grp setBehaviour "SAFE";
    };

    _tentPos = [10 * (sin _dir), 10 * (cos _dir), 0] vectorAdd (getPos _hq);
    _tent = "gm_gc_tent_5x5m" createVehicle _tentPos;
    _tent setDir _dir;

    _flagPos = [6 * (sin _dir), 6 * (cos _dir), 0] vectorAdd _tentPos;
    _flag = "cwr3_flag_ussr" createVehicle _flagPos;
    _hq
};

dyn_spawn_static_weapon = {
    params ["_pos", "_dir", ["_low", false]];

    private _weapon = selectRandom dyn_standart_statics_high;
    if (_low) then {
        _weapon = selectRandom dyn_standart_statics_low;
    };
    _swPos = _pos findEmptyPosition [0, 30, _weapon];
    _static = _weapon createVehicle _swPos;
    _static setDir _dir;
    _vGrp = createVehicleCrew _static;
    _soldier = _vGrp createUnit ["cwr3_o_soldier_amg", _swPos, [], 2, "NONE"];
    _soldier setPos ([2, 2] vectorAdd (getPos _static));
    _soldier setDir _dir;
    doStop _soldier;
    _comp = selectRandom ["land_gm_sandbags_01_round_01"];
    if (_low) then {
        _comp = "land_gm_sandbags_01_low_01"
    };
    _sPos = [2.5 * (sin _dir), 2.5 * (cos _dir), 0] vectorAdd _swPos;
    _sCover =  _comp createVehicle _sPos;
    _sCover setDir _dir;
    _sCover attachTo [_static, [0,2,-1]];
    // detach _sCover;
};

dyn_spawn_aa = {
    params ["_pos", "_dir"];

    _rearPos = [150 * (sin (_dir - 180)), 150 * (cos (_dir - 180)), 0] vectorAdd _pos;
    _rearPos = _rearPos findEmptyPosition [0, 200, "cwr3_o_zu23"];
    _aa = "cwr3_o_zu23" createVehicle _rearPos;
    _aa setDir _dir;
    createVehicleCrew _aa;
    _iPos = getPos _aa;
    _iPos = [5, 5] vectorAdd _iPos;
    _grp = [_iPos, east, dyn_standart_fire_team] call BIS_fnc_spawnGroup;
    _grp
};

dyn_spawn_qrf = {
    params ["_trg", "_qrfPos", "_area", "_amount"];

    waitUntil {sleep 1; triggerActivated _trg};


    private _atkPos = {
        if ((_x distance2D _qrfPos) < _area) exitWith {getPos _x};
    } forEach (allUnits+vehicles select {side _x == west});


    private _qrf = [];
    for "_i" from 0 to (_amount - 1) do {
        _sPos = _qrfPos findEmptyPosition [0, 60];
        _grp = [_sPos, east, dyn_standart_fire_team] call BIS_fnc_spawnGroup;
        _qrf pushBack _grp;
        _grp setFormation "LINE";
        _grp setSpeedMode "FULL";
        {
            _x disableAI "AUTOCOMBAT";
        } forEach (units _grp);
    };

    sleep 5;
    {
        _x addWaypoint [_atkPos, 50];
        (vehicle (leader _x)) limitSpeed 15;
    } forEach _qrf;
    _qrf
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
    params ["_pos", "_area", "_amount", "_trg"];

    private _forest = selectBestPlaces [_pos, _area, "(1 + forest + trees) * (1 - sea) * (1 - houses)", 70, 20];
    _patrollPos = [];
    private _allGrps = [];;

    {
        _patrollPos pushBack (_x#0);
    } forEach _forest;

    _patrollPos = [_patrollPos, [], {_x distance2D (getPos player)}, "ASCEND"] call BIS_fnc_sortBy;

    for "_i" from 0 to (_amount - 1) do {
        _pPos = _patrollPos#_i;
        _grp = [_pPos, east, dyn_standart_fire_team] call BIS_fnc_spawnGroup;
        _grp setBehaviour "SAFE";
        _wpPos = [[[_pPos, 200]], [[_pPos, 50]]] call BIS_fnc_randomPos;
        _grp addWaypoint [_wpPos, 50];
        _wp = _grp addWaypoint [_pPos, 50];
        _wp setWaypointType "CYCLE";
        _allGrps pushBack _grp;
    };

    [_trg, getPos _trg, _allGrps] spawn dyn_retreat;

    ////debug
    // _i = 0;
    // {
    //     _m = createMarker [str (random 1), _x];
    //     _m setMarkerText str _i;
    //     _m setMarkerType "mil_dot";
    //     _i = _i + 1
    // } forEach _patrollPos;
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

    [_trg, getPos _trg, _allGrps] spawn dyn_retreat;

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
                _distance = [40, 70] call BIS_fnc_randomInt;
                _iPos = [_distance * (sin (_dir + _facing)), _distance * (cos (_dir + _facing)), 0] vectorAdd _bPos;
                _grp = [_iPos, 20, true, true] spawn dyn_spawn_dimounted_inf;
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

dyn_defended_side_towns = [];
dyn_all_side_town_guards = [];

dyn_spawn_side_town_guards = {
    params ["_trg", "_pos", "_area", "_searchPos"];

    _mainLoc =  nearestLocation [_pos, ""];
    _locs = nearestLocations [_searchPos, ["NameVillage", "NameCity", "NameCityCapital"], _area];
    private _validLocs = [];
    private _allGrps = [];
    {
        if !(_x in dyn_locations) then {
            _validLocs pushBackUnique _x;
            dyn_defended_side_towns pushBackUnique _x;
        };
    } forEach (_locs - [_mainLoc]);

    if !(_validLocs isEqualTo []) then {
        {
            _validBuildings = [];
            _buildings = nearestObjects [(getPos _x), ["house"], 400];
            {
                if (count ([_x] call BIS_fnc_buildingPositions) >= 8) then {
                    _validBuildings pushBack _x;
                };
            } forEach _buildings;

            _validBuildings = [_validBuildings, [], {_x distance2D (getPos player)}, "ASCEND"] call BIS_fnc_sortBy;

            _dir = (getPos _x) getDir player;
            for "_i" from 0 to ([0,2] call BIS_fnc_randomInt) do {
                _grp = [getPos _x, east, dyn_standart_fire_team] call BIS_fnc_spawnGroup;
                dyn_all_side_town_guards pushBack _grp;
                _buildingIdx = [0, 7] call BIS_fnc_randomInt;
                [_validBuildings#_buildingIdx, _grp, _dir] spawn dyn_garrison_building;
                _allGrps pushBack _grp;
            };

            _buildingIdx = [0,6] call BIS_fnc_randomInt;
            if ((random 1) > 0.5) then {
                _vicGrp = [getPos (_validBuildings#_buildingIdx), 60, true, true] spawn dyn_spawn_dimounted_inf;
                dyn_all_side_town_guards pushBack _vicGrp;
                _allGrps pushBack _vicGrp;
            } 
            else
            {
                _vicGrp = [getPos (_validBuildings#_buildingIdx), 60, false, false] spawn dyn_spawn_dimounted_inf;
                dyn_all_side_town_guards pushBack _vicGrp;
                _allGrps pushBack _vicGrp;
            };

            if ((random 1) > 0.5) then {
                _qrfTrg = createTrigger ["EmptyDetector", getPos _x , true];
                _qrfTrg setTriggerActivation ["WEST", "PRESENT", false];
                _qrfTrg setTriggerStatements ["this", " ", " "];
                _qrfTrg setTriggerArea [300, 300, _dir, true];

                [_qrfTrg, getPos _x, 1000, [2, 3] call BIS_fnc_randomInt] spawn dyn_spawn_qrf;
            };
        } forEach _validLocs;
    };



    // debug
    // _i = 0;
    // {
    //     _m = createMarker [str (random 1), getPos _x];
    //     _m setMarkerText str _i;
    //     _m setMarkerType "mil_dot";
    //     _i = _i + 1;
    // } forEach _validLocs;

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

dyn_spawn_supply_convoy = {
    params ["_trg", "_hqPos", "_dir"];

    waitUntil {sleep 1, triggerActivated _trg};

    // sleep ([60, 180] call BIS_fnc_randomInt);
    _dir = player getDir _hqPos;

    _rearPos = [800 * (sin _dir), 800 * (cos _dir), 0] vectorAdd _hqPos;

    // debug
    // _m = createMarker [str (random 1), _rearPos];
    // _m setMarkerType "mil_circle"; 

    // _road = [_rearPos, 1000 , ["TRAIL"]] call BIS_fnc_nearestRoad;
    _roads = _rearPos nearRoads 1500;
    _roads = [_roads, [], {(getPos _x) distance2D _rearPos}, "ASCEND"] call BIS_fnc_sortBy;
    _road = _roads#0;
    _usedRoads = [];
    private _vics = [];
    for "_i" from 0 to 1 step 1 do {
        _road = ((roadsConnectedTo _road) - [_road]) select 0;
        _vic = vehicle (leader ([getPos _road, 0, ["cwr3_o_ural"]] call dyn_spawn_parked_vehicle));
        _vics pushBack _vic;
        _near = roadsConnectedTo _road;
        _near = [_near, [], {(getPos _x) distance2D _hqPos}, "DESCEND"] call BIS_fnc_sortBy;
        _vDir = (getPos (_near#0)) getDir (getPos _road);
        _vic setDir _vDir;
        _grp = [_rearPos, east, dyn_standart_fire_team] call BIS_fnc_spawnGroup;
        {
            _x assignAsCargo _vic;
            _x moveInCargo _vic;
        } forEach (units _grp);
    };

    {
        _g = (group (driver _x));
        _wp = _g addWaypoint [_hqPos, 20];
        _wp setWaypointType "TR UNLOAD";
        _x limitSpeed 50;
        _g setBehaviour "SAFE";
    } forEach _vics;
};

dyn_retreat = {
    params ["_trg", "_dest", "_grps", ["_arty", true]];

    if !(isNull _trg) then {
        waitUntil {sleep 1; triggerActivated _trg};
    };


    if (((random 1) > 0.5) and _arty) then {[] spawn dyn_arty};

    private _allUnits = [];

    {
        _grp = _x;
        if (vehicle (leader _grp) != leader _grp) then {
            vehicle (leader _grp) setFuel 1;
        };

        {
            _x enableAI "PATH";
            _x doFollow (leader _grp);
            _x disableAI "AUTOCOMBAT";
            _x setUnitPos "AUTO";
            _allUnits pushBack _x;
        } forEach (units _grp);

        [_grp, (currentWaypoint _grp)] setWaypointType "MOVE";
        [_grp, (currentWaypoint _grp)] setWaypointPosition [getPosASL (leader _grp), -1];
        sleep 0.1;
        deleteWaypoint [_grp, (currentWaypoint _grp)];
        for "_i" from count waypoints _grp - 1 to 0 step -1 do {
            deleteWaypoint [_grp, _i];
        };


        _grp addWaypoint [_dest, 150];
        // _grp setFormation "COLUMN";
        _grp setBehaviour "AWARE";
        
    } forEach _grps;

    [_allUnits] call dyn_forget_targets;

    for "_i" from 0 to 20 do {
        sleep 30;
        [_allUnits] call dyn_forget_targets;
    };
};

dyn_spawn_counter_attack = {
    params ["_trg", "_atkPos", "_defPos", "_inf", "_vics", "_breakPoint", ["_mech", false], ["_vicTypes", dyn_standart_combat_vehicles], ["_spawnDistance", 1400]];

    waitUntil {sleep 1; triggerActivated _trg};

    // sleep 10;

    private _counterattack = [];
    private _dir = _atkPos getDir _defPos;
    _rearPos = [_spawnDistance * (sin _dir), _spawnDistance * (cos _dir), 0] vectorAdd _atkPos;

    if (_inf > 0) then {
        for "_i" from 0 to (_inf - 1) do {
            _nDir = _dir + 90;
            _sPos = [(80 * _i) * (sin _nDir), (80 * _i) * (cos _nDir), 0] vectorAdd _rearPos;
            _sPos = _sPos findEmptyPosition [0, 60];
            private _grp = grpNull;
            if (_mech) then {
                _comp = format ["cwr3_o_mechanized_infantry_%1", selectRandom ["bmp1", "bmp2", "btr"]];
                _grp = [_sPos, east, (configFile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Mechanized" >> _comp),[],[],[],[],[], (_dir -180)] call BIS_fnc_spawnGroup;
            }
            else
            {
                _grp = [_sPos, east, dyn_standart_squad,[],[],[],[],[], (_dir - 180)] call BIS_fnc_spawnGroup;
            };
            _counterattack pushBack _grp;
            _grp setFormation "LINE";
            // {
            //     _x disableAI "AUTOCOMBAT";
            // } forEach (units _grp);
        };
    };

    if (_vics > 0) then {
        private _vicType = selectRandom _vicTypes;
        for "_i" from 0 to (_vics - 1) do {
            _nDir = _dir + 90;
            _sPos = [(80 * _i) * (sin _nDir), (80 * _i) * (cos _nDir), 0] vectorAdd _rearPos;
            _sPos = _sPos findEmptyPosition [0, 150];
            _vic = _vicType createVehicle _sPos;
            _vic setDir (_dir -180);
            _grp = createVehicleCrew _vic;
            _counterattack pushBack _grp;
        };
    };
    sleep 5;
    _formationLeader = _counterattack#0;
    private _leaders = [leader _formationLeader];
    _wpPos1 = [800 * (sin (_dir - 180)), 800 * (cos (_dir - 180)), 0] vectorAdd getPos (leader _formationLeader);
    _wpPos2 = [1500 * (sin (_dir - 180)), 1500 * (cos (_dir - 180)), 0] vectorAdd getPos (leader _formationLeader);
    _lWP = _formationLeader addWaypoint [_wpPos1, 0];
    private _syncWps = [_lWP];
    _formationLeader addWaypoint [_wpPos2, 0];

    {
        _wpPos1 = [800 * (sin (_dir - 180)), 800 * (cos (_dir - 180)), 0] vectorAdd getPos (leader _x);
        _wpPos2 = [1500 * (sin (_dir - 180)), 1500 * (cos (_dir - 180)), 0] vectorAdd getPos (leader _x);
        _gWP = _x addWaypoint [_wpPos1, 0];
        (vehicle (leader _x)) limitSpeed 40;
        _leaders pushBack (leader _x);
        // _gWp synchronizeWaypoint _syncWps;
        _syncWps pushBack _gWp;
        _x addWaypoint [_wpPos2, 0];
    } forEach _counterattack - [_formationLeader];

    waitUntil {sleep 1; ({(_atkPos distance2D _x) < 700} count _leaders) > 0};

    if ((random 1) > 0.3) then {[] spawn dyn_arty};

    waitUntil {sleep 1; ({alive _x} count _leaders) <= _breakPoint};

    [objNull, _defPos, _counterattack] spawn dyn_retreat;

    [] spawn dyn_garbage_clear;
};




dyn_arty = {
    _target = selectRandom (allUnits select {side _x == west});
    _pos = getPos _target;
    _amount = [6, 10] call BIS_fnc_randomInt;

    _artyGroup = createGroup east;
    for "_i" from 0 to _amount do {
        _artyPos = [[[_pos, 300]], [[_pos, 50]]] call BIS_fnc_randomPos;

        // private _marker = createMarker [str _i, _artyPos];
        // _marker setMarkerShape "ICON";
        // _marker setMarkerColor "colorBLUFOR";
        // _marker setMarkerType "MIL_DOT";

        _support = _artyGroup createUnit ["ModuleOrdnance_F", _artyPos, [],0 , ""];
        _support setVariable ["type", "ModuleOrdnanceMortar_F_Ammo"];
        sleep ([2, 10] call BIS_fnc_randomInt);
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
    for "_i" from 0 to 2 do {
        _target = selectRandom (allUnits select {side _x == west});
        _pos = getPos _target;
        _artyPos = [[[_pos, 350]], [[_pos, 80]]] call BIS_fnc_randomPos;
        _grad commandArtilleryFire [_artyPos, "CUP_40Rnd_GRAD_HE", 15];
        sleep 15;
    };
};

dyn_attack_nearest_enemy = {
    params ["_trg", "_grps"];

    waitUntil { sleep 1, triggerActivated _trg };

    _units = allUnits+vehicles select {side _x == playerSide};
    {
        _grp = _x;
        _units = [_units, [], {_x distance2D (leader _grp)}, "ASCEND"] call BIS_fnc_sortBy;
        _atkPos = getPos (_units#0);

        [_grp, (currentWaypoint _grp)] setWaypointType "MOVE";
        [_grp, (currentWaypoint _grp)] setWaypointPosition [getPosASL (leader _grp), -1];
        sleep 0.1;
        deleteWaypoint [_grp, (currentWaypoint _grp)];
        for "_i" from count waypoints _grp - 1 to 0 step -1 do {
            deleteWaypoint [_grp, _i];
        };
        {
            _x enableAI "PATH";
            _x doFollow (leader _grp);
        } forEach (units _grp);

        _wp = _grp addWaypoint [_atkPos, 20];
        _wp setWaypointType "SAD";
    } forEach _grps;
};