dyn_debug = false;
// setGroupIconsVisible [true,false];

// addMissionEventHandler ["TeamSwitch", {
//     params ["_previousUnit", "_newUnit"];
//     _hcc = allMissionObjects "HighCommand" select 0;
//     _hcs = allMissionObjects "HighCommandSubordinate" select 0;
//     deleteVehicle _hcc;
//     // deleteVehicle _previousUnit;
//     createGroup (sideLogic) createUnit ["HighCommand", [0, 0, 0], [], 0, "NONE"];
//     _hcc = allMissionObjects "HighCommand" select 0;
//     _newUnit synchronizeObjectsAdd [_hcc];
//     _hcc synchronizeObjectsAdd [_hcs];
//     [] call dyn_add_all_groups;

//     _newUnit addEventHandler ["GetInMan", {
//         params ["_unit", "_role", "_vehicle", "_turret"];
//         private ["_group"];
//         _group = group player;
//         _vicGroup = group (driver (vehicle player));
//         if (_vicGroup != (group player)) then {
//             player setVariable ["pl_player_vicGroup", _vicGroup];
//             // _vicGroup setVariable ["setSpecial", true];
//             // _vicGroup setVariable ["specialIcon", "\A3\ui_f\data\igui\cfg\simpleTasks\types\truck_ca.paa"];
//             _vicGroup setVariable ["pl_has_cargo", true];
//             // _group setVariable ["pl_show_info", false];
//             [_group] call pl_hide_group_icon;
//             // player hcRemoveGroup _group;
//         };
//     }];

//     _newUnit addEventHandler ["GetOutMan", {
//         params ["_unit", "_role", "_vehicle", "_turret"];
//         private ["_group"];
//         _group = group player;
//         _vicGroup = player getVariable ["pl_player_vicGroup", (group player)];
//         _group setVariable ["setSpecial", false];
//         _group setVariable ["onTask", false];
//         // _group setVariable ["pl_show_info", true];
//         if !(_group getVariable ["pl_show_info", false]) then {
//             [_group, "hq"] call pl_show_group_icon;
//         };
//         // player hcSetGroup [_group];

//         _cargo = fullCrew [(vehicle ((units _vicGroup)#0)), "cargo", false];
//         if ((count _cargo == 0)) exitWith {
//             // _vicGroup setVariable ["setSpecial", false];
//             _vicGroup setVariable ["pl_has_cargo", false];
//         };
//         if (({(group (_x#0)) isEqualTo _group} count _cargo) > 0) then {
//             [_vicGroup, _cargo, _group] spawn {
//                 params ["_vicGroup", "_cargo", "_group"];
//                 waitUntil {sleep 1; (({(group (_x#0)) isEqualTo _group} count (fullCrew [(vehicle ((units _vicGroup)#0)), "cargo", false])) == 0)};
//                 // _vicGroup setVariable ["setSpecial", false];
//                 _vicGroup setVariable ["pl_has_cargo", false];
//             };
//         };
//     }];
// }];

dyn_add_all_groups = {
    {
        _x setVariable ["pl_show_info", true];
        player hcSetGroup [_x];
    } forEach (allGroups select {side (leader _x) == playerSide});
};


dyn_create_markers = {
    params ["_pos", "_dir", "_trg", "_campaignDir", "_playerPos", "_comp"];

    _pos = [250 * (sin 0), 250 * (cos 0), 0] vectorAdd _pos;

    _marker1 = createMarker [str _pos, _pos];
    _marker1 setMarkerColor "colorOPFOR";
    _marker1 setMarkerType (_comp#0);
    _marker1 setMarkerText (_comp#1);
    _marker1 setMarkerSize [1.2, 1.2];

    _marker2 = createMarker [format ["btl%1", _pos], _pos];
    _marker2 setMarkerType "group_5";
    _marker2 setMarkerSize [1.2, 1.2];


    _leftPos = [1800 * (sin (_dir - 90)), 1800 * (cos (_dir - 90)), 0] vectorAdd _pos;
    _rightPos = [1800 * (sin (_dir + 90)), 1800 * (cos (_dir + 90)), 0] vectorAdd _pos;

    _marker3 = createMarker [format ["left%1", _pos], _leftPos];
    _marker3 setMarkerShape "RECTANGLE";
    _marker3 setMarkerSize [8, 2100];
    _marker3 setMarkerDir _dir;
    _marker3 setMarkerBrush "SolidFull";
    _marker3 setMarkerColor "colorBLACK";

    _marker4 = createMarker [format ["right%1", _pos], _rightPos];
    _marker4 setMarkerShape "RECTANGLE";
    _marker4 setMarkerSize [8, 2100];
    _marker4 setMarkerDir _dir;
    _marker4 setMarkerBrush "SolidFull";
    _marker4 setMarkerColor "colorBLACK";

    // _clRightPos = [8000 * (sin (_campaignDir + 90)), 8000 * (cos (_campaignDir + 90)), 0] vectorAdd _pos;
    // _marker5 = createMarker [format ["clright%1", _pos], _clRightPos];
    // _marker5 setMarkerShape "RECTANGLE";
    // _marker5 setMarkerSize [40, 5500];
    // _marker5 setMarkerDir _campaignDir + 90;
    // _marker5 setMarkerBrush "Horizontal";
    // _marker5 setMarkerColor "colorOPFOR";

    // _clLeftPos = [8000 * (sin (_campaignDir - 90)), 8000 * (cos (_campaignDir - 90)), 0] vectorAdd _pos;
    // _marker6 = createMarker [format ["clLeft%1", _pos], _clLeftPos];
    // _marker6 setMarkerShape "RECTANGLE";
    // _marker6 setMarkerSize [40, 5500];
    // _marker6 setMarkerDir _campaignDir - 90;
    // _marker6 setMarkerBrush "Horizontal";
    // _marker6 setMarkerColor "colorOPFOR";

    _marker7 = createMarker [format ["player%1", _pos], _playerPos];
    _marker7 setMarkerType "flag_Germany";

    _arrowPos = [(_playerPos distance2d _pos) / 2 * (sin (_playerPos getDir _pos)), (_playerPos distance2d _pos) / 2 * (cos (_playerPos getDir _pos)), 0] vectorAdd _playerPos;
    _marker8 = createMarker [format ["arrow%1", _pos], _arrowPos];
    _marker8 setMarkerType "cwr3_marker_arrow";
    _marker8 setMarkerSize [1.5, 1.5];
    _marker8 setMarkerColor "colorBLUFOR";
    _marker8 setMarkerDir (_playerPos getDir _pos);
    _marker8 setMarkerAlpha 0;

    _teamPos = [2200 * (sin _dir), 2200 * (cos _dir), 0] vectorAdd _rightPos;
    _marker9 = createMarker [format ["team%1", _pos], _teamPos];
    _marker9 setMarkerType "b_armor";
    _marker9 setMarkerSize [0.5, 0.5];
    // _marker9 setMarkerDir _dir;
    _marker9 setMarkerText "2./PzBtl 203";

    _marker10 = createMarker [format ["teamsize%1", _pos], _teamPos];
    _marker10 setMarkerType "group_4";
    _marker10 setMarkerSize [0.5, 0.5];

    _unitLeftPos = [100 * (sin (_dir - 90)), 100 * (cos (_dir - 90)), 0] vectorAdd _leftPos;
    _type = selectRandom ["group_5", "group_7", "group_6"];
    _marker11 = createMarker [format ["leftUnit%1", _pos], _unitLeftPos];
    _marker11 setMarkerType _type;
    _marker11 setMarkerSize [1.5, 1.5];
    _marker11 setMarkerDir _dir + 90;

    _unitRightPos = [100 * (sin (_dir - 90)), 100 * (cos (_dir - 90)), 0] vectorAdd _RightPos;
    _type = selectRandom ["group_5", "group_7", "group_6"];
    _marker12 = createMarker [format ["rightUnit%1", _pos], _unitRightPos];
    _marker12 setMarkerType _type;
    _marker12 setMarkerSize [1.5, 1.5];
    _marker12 setMarkerDir _dir + 90;

    sleep 1;

    waitUntil {!(dyn_defense_active)};

    _marker8 setMarkerAlpha 1;

    waitUntil {sleep 1; triggerActivated _trg};

    deleteMarker _marker1;
    deleteMarker _marker2;
    deleteMarker _marker3;
    deleteMarker _marker4;
    // deleteMarker _marker5;
    // deleteMarker _marker6;
    deleteMarker _marker7;
    deleteMarker _marker8;
    deleteMarker _marker9;
    deleteMarker _marker10;
    deleteMarker _marker11;
    deleteMarker _marker12;
};

dyn_ambiance = {
    params ["_centerPos", "_dir", "_trg"];


    dyn_ambient_sound_mod attachTo [player, [0,0,0]];

    _smokeGroup = createGroup [civilian, true];
    _civVics = ["cwr3_c_gaz24", "cwr3_c_mini", "cwr3_c_rapid", "gm_ge_civ_typ1200"];
    _roads = _centerPos nearRoads 1300;

    for "_l" from 0 to ([5, 9] call BIS_fnc_randomInt) do {
        _vic = createVehicle [selectRandom _civVics, getPos (selectRandom _roads) , [], 15, "NONE"];
        _vic setDir ([0, 359] call BIS_fnc_randomInt);
        _vic setDamage 1;
        _vic setVariable ["dyn_dont_delete", true];
        [_vic] spawn {
            params ["_vic"];
            sleep 20;
            _vic enableSimulation false;
        };
        for "_j" from 0 to ([1, 2] call BIS_fnc_randomInt) do {
            _civ = _smokeGroup createUnit ["cwr3_c_civilian_random", getPos _vic, [], 8, "NONE"];
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

    _houses = nearestTerrainObjects [_centerPos, ["HOUSE"], 1500, false, true];

    for "_i" from 0 to ([3, 7] call BIS_fnc_randomInt) do {
        _house = selectRandom _houses;
        _house setDamage 1;
        _pos = getPosATLVisual _house;
        _smoke = _smokeGroup createUnit ["ModuleEffectsSmoke_F", _pos, [],0 , ""];
        _fire = _smokeGroup createUnit ["ModuleEffectsFire_F", _pos, [],0 , ""];
        // _support = _smokeGroup createUnit ["ModuleOrdnance_F", _pos, [],0 , ""];
        // _support setVariable ["type", "ModuleOrdnanceMortar_F_ammo"];

        for "_j" from 0 to ([1, 2] call BIS_fnc_randomInt) do {
            _civ = _smokeGroup createUnit ["cwr3_c_civilian_random", _pos, [], 20, "NONE"];
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

    waitUntil {triggerActivated _trg};

    {
        sleep 30;
        deleteVehicle _x;
    } forEach (units _smokeGroup);
};


dyn_msr_markers = [];

dyn_define_msr = {
    params ["_start", "_goal"];
    private _dummyGroup = createGroup sideLogic;
    private _closedSet = [];
    private _openSet = [_start];
    private _current = _start;
    private _nodeCount = 0;
    private _allRoads = [];
    while {!(_openSet isEqualTo [])} do {
        private _closest = objNull;
        {
            if (_goal distance _x < _goal distance _closest) then {
                _closest = _x;
            };
            nil
        } count _openSet;
        _current = _closest;
        _nodeCount = _nodeCount + 1;
        if (_current == _goal) exitWith {
            private _parent = _dummyGroup getVariable ("NF_neighborParent_" + str _current);
            while {!(isNil "_parent")} do {
                _allRoads pushBack _parent;
                dyn_msr_markers pushBack (getPos _parent);

                // private _marker = createMarker [str _parent, getPos _parent];
                // _marker setMarkerShape "ICON";
                // _marker setMarkerColor "colorBLUFOR";
                // _marker setMarkerType "MIL_DOT";
                // _marker setMarkerSize [0.3, 0.3];

                _parent = _dummyGroup getVariable ("NF_neighborParent_" + str _parent);
            };
        };
        _openSet = _openSet - [_current];
        _closedSet pushBack _current;
        private _neighbors = (getPos _current) nearRoads 15; // This includes current
        _neighbors append (roadsConnectedTo _current);
        {
            if (!(_x in _closedSet)) then {
                private _currentG = _dummyGroup getVariable ["NF_neighborG_" + str _current, 0];
                private _gScore = _currentG + 1;
                private _gScoreIsBest = false;
                if (!(_x in _openSet)) then {
                    _gScoreIsBest = true;
                    _openSet pushBack _x;
                } else {
                    private _neighborG = _dummyGroup getVariable ("NF_neighborG_" + str _x);
                    _gScoreIsBest = _gScore < _neighborG;
                };
                if (_gScoreIsBest) then {
                    _dummyGroup setVariable ["NF_neighborParent_" + str _x, _current];
                    _dummyGroup setVariable ["NF_neighborG_" + str _x, _gScore];
                };
            };
        } forEach _neighbors;
    };
    // count _allRoads
};

dyn_place_player = {
    params ["_pos", "_dest"];
    private ["_startPos", "_infGroups", "_vehicles", "_roads", "_road", "_roadsPos"];
    _startPos = getMarkerPos "spawn_start";
    deleteMarker "spawn_start";
    _infGroups = [];
    _vehicles = nearestObjects [_startPos,["LandVehicle"],300];
    {
        if(((_startPos distance2D (leader _x)) < 300) and !(vehicle (leader _x) in _vehicles)) then {
            _infGroups pushBack _x;
        }
    } forEach (allGroups select {side _x isEqualTo playerSide});

    // _roads = _pos nearRoads 300;
    

    _road = [_pos, 300] call BIS_fnc_nearestRoad;
    _usedRoads = [];
    reverse _vehicles;

    _roadsPos = [];
    for "_i" from 0 to (count _vehicles) - 1 step 1 do {
        _road = ((roadsConnectedTo _road) - [_road]) select 0;
        _roadPos = getPos _road;
        _near = roadsConnectedTo _road;
        _near = [_near, [], {(getPos _x) distance2D _dest}, "DESCEND"] call BIS_fnc_sortBy;
        _dir = (getPos (_near#0)) getDir (getPos _road);
        _roadsPos pushBack [_roadPos, _dir];
    };

    _roadsPos = [_roadsPos, [], {(_x#0) distance2D _dest}, "ASCEND"] call BIS_fnc_sortBy;

    for "_i" from 0 to (count _vehicles) - 1 step 1 do {
        (_vehicles#_i) setPos ((_roadsPos#_i)#0);
        (_vehicles#_i) setdir ((_roadsPos#_i)#1);
    };

    

    private _vicId = 0;
    private _oDir = 90;
    for "_i" from 0 to (count _infGroups) - 1 step 1 do {
        if (_vicId > ((count _infGroups) - 1)) then {
            _vicId = 0;
            _oDir = -90;
        };
        _vic = (_vehicles#_vicId);
        _vDir = getDir _vic;
        _iPos = [35 * (sin (_vDir + _oDir)), 35 * (cos (_vDir + _oDir)), 0] vectorAdd getPos _vic;
        _iPos = [_iPos, 0, 20, 1, 0, 0, 0, [], [_iPos]] call BIS_fnc_findSafePos;
        {
            _x setPos _iPos;
        } forEach (units (_infGroups#_i));
        _vicId = _vicId + 1;
    };
};

dyn_customice_playerside = {

    {
        _x addGoggles (selectRandom ["gm_headgear_foliage_summer_forest_01", "gm_headgear_foliage_summer_forest_02", "gm_headgear_foliage_summer_forest_03", "gm_headgear_foliage_summer_forest_04"]);
        _faceunit = (face _x + (selectRandom ["_cfaces_BWTarn", "_cfaces_BWStripes"]));
        _x setVariable ["JgKp_Face", _faceunit, true];
    } forEach (allUnits select {side _x == playerSide});

};

[] call dyn_customice_playerside;

dyn_place_support_deployed = {
    params ["_startPos", "_dest"];

    _spawnPos = getMarkerPos "support_spawn";
    deleteMarker "support_spawn";

    _vehicles = nearestObjects [_spawnPos,["LandVehicle"], 100];

    _road = [_startPos, 300] call BIS_fnc_nearestRoad;
    _usedRoads = [];
    // reverse _vehicles;

    _roadsPos = [];
    for "_i" from 0 to (count _vehicles) - 1 step 1 do {
        _road = ((roadsConnectedTo _road) - [_road]) select 0;
        _roadPos = getPos _road;
        _near = roadsConnectedTo _road;
        _near = [_near, [], {(getPos _x) distance2D _dest}, "DESCEND"] call BIS_fnc_sortBy;
        _dir = (getPos (_near#0)) getDir (getPos _road);
        _roadsPos pushBack [_roadPos, _dir];
    };

    _roadsPos = [_roadsPos, [], {(_x#0) distance2D _dest}, "ASCEND"] call BIS_fnc_sortBy;

    for "_i" from 0 to (count _vehicles) - 1 step 1 do {
        (_vehicles#_i) setPos ((_roadsPos#_i)#0);
        (_vehicles#_i) setdir ((_roadsPos#_i)#1);
        group (driver (_vehicles#_i)) addWaypoint [(_roadsPos#_i)#0, 0];
    };
};

dyn_place_player_deployed = {
    params ["_startPos", "_startDir", "_placePos", "_dest", "_supportPos"];
    _vehicles = nearestObjects [_startPos,["LandVehicle"], 300];
    {
        _dis = _startPos distance2D _x;
        _dir = _startPos getDir _x;
        _x setVariable ["dyn_rel_data", [_dis, _dir]];
    } forEach _vehicles;

    {
        _relData = _x getVariable "dyn_rel_data";
        _setPos = _placePos getPos [_relData#0, _startDir - (_relData#1)];
        _x setPos _setPos;
        _x setDir _startDir;
        group (driver _x) addWaypoint [_setPos, 0];
    } forEach _vehicles;

    [_supportPos, _dest] call dyn_place_support_deployed;
};



dyn_place_arty = {

    artGrp_1 setVariable ["pl_not_addalbe", true];

    _artyLeader = leader artGrp_1;
    {
        _pos1 = getPosWorldVisual (vehicle _artyLeader);
        _pos2 = getPosWorldVisual (vehicle _x);
        _relPos = [(_pos1 select 0) - (_pos2 select 0), (_pos1 select 1) - (_pos2 select 1)];
        _x setVariable ["dyn_rel_pos", _relPos];
    } forEach ((units artGrp_1) - [_artyLeader]);

    _batteryPos = (getPos player) getPos [2000, (getDir (vehicle player) + 190)];
    _batteryPos = ((selectBestPlaces [_batteryPos, 500, "2*meadow", 95, 1])#0)#0;
    // _batteryPos = _batteryPos findEmptyPosition [0, 500, typeOf (vehicle _artyLeader)];

    (vehicle _artyLeader) setPos _batteryPos;

    {
        (vehicle _x) setDir (getDir vehicle player);
        _x disableAI "PATH";
    } forEach (units artGrp_1);

    {
        _pos1 = getPosWorldVisual (vehicle _artyLeader);
        _pos2 = _x getVariable "dyn_rel_pos";
        _setPos = [(_pos1 select 0) + (_pos2 select 0), (_pos1 select 1) + (_pos2 select 1)];
        (vehicle _x) setPos _setPos;
    } forEach ((units artGrp_1) - [_artyLeader]);

    _aaPOs = _batteryPos getPos [050, 90];
    dyn_aa_vic setPos _aaPOs;
    clearGroupIcons dyn_aa_vic_grp;
    dyn_aa_vic_grp addGroupIcon ["b_antiair"];  
};

dyn_opfor_arty = [];

dyn_place_opfor_arty = {
    params ["_artyPos", "_dir"];

    if (count dyn_opfor_arty > 0) then {
        {
            {
                deleteVehicle _x;
            } forEach (crew _x);
            deleteVehicle _x;
        } forEach dyn_opfor_arty;
    };
    dyn_opfor_arty = [];
    _artyPos = ((selectBestPlaces [_artyPos, 1500, "2*meadow", 95, 1])#0)#0;

    for "_i" from 0 to 2 do {
        _aPos = _artyPos getPos [20 * _i, _dir + 90];
        _arty = createVehicle [dyn_standart_arty, _aPos, [], 0, "NONE"];
        _arty setdir _dir;
        _grp = createVehicleCrew _arty;
        dyn_opfor_arty pushBack _arty;
    };
};

dyn_opfor_rocket_arty = [];

dyn_place_opfor_rocket_arty = {
    params ["_artyPos", "_dir"];

    if (count dyn_opfor_rocket_arty > 0) then {
        {
            {
                deleteVehicle _x;
            } forEach (crew _x);
            deleteVehicle _x;
        } forEach dyn_opfor_rocket_arty;
    };
    dyn_opfor_rocket_arty = [];
    _artyPos = ((selectBestPlaces [_artyPos, 1000, "2*meadow", 95, 1])#0)#0;

    for "_i" from 0 to 1 do {
        _aPos = _artyPos getPos [20 * _i, _dir + 90];
        _arty = createVehicle [dyn_standart_rocket_arty, _aPos, [], 0, "NONE"];
        _arty setdir _dir;
        _grp = createVehicleCrew _arty;
        dyn_opfor_rocket_arty pushBack _arty;
    };
};

dyn_opfor_light_arty = [];

dyn_place_opfor_light_arty = {
    params ["_artyPos", "_dir"];

    if (count dyn_opfor_light_arty > 0) then {
        {
            _art = _x;
            {
                (group _x) leaveVehicle _art;
            } forEach (crew _x);
            deleteVehicle _x;
        } forEach dyn_opfor_light_arty;
    };
    dyn_opfor_light_arty = [];
    _artyPos = ((selectBestPlaces [_artyPos, 500, "2*meadow", 95, 1])#0)#0;

    _lightArtyGrp = createGroup [east, true];
    for "_i" from 0 to 2 do {
        _offsetDir = 90;
        if (_i == 1) then {_offsetDir = 70};
        _aPos = _artyPos getPos [10 * _i, _dir - _offsetDir];
        _arty = createVehicle [dyn_standart_light_arty, _aPos, [], 0, "NONE"];
        _arty setdir _dir;
        _grp = createVehicleCrew _arty;
        _grp setVariable ["pl_not_recon_able", true];
        [units _grp] joinSilent _lightArtyGrp;
        dyn_opfor_light_arty pushBack _arty;

        _sPos = (getPos _arty) getPos [1, _dir];
        _sandBag = createVehicle ["land_gm_sandbags_01_round_01", _sPos, [], 0, "CAN_COLLIDE"];
        _sandBag setDir (getDir _arty);
        if (_i == 1) then {
            _guardPos = _aPos getPos [15, _dir - 180];
            _gGrp = [_guardPos, 0] call dyn_spawn_dimounted_inf;
            _gGrp setVariable ["pl_not_recon_able", true];
            [units _gGrp] joinSilent _lightArtyGrp;
        };
    };
};

// dyn_start_markers = [["start_0", "obj_0"], ["start_1", "obj_1"], ["start_2", "obj_2"], ["start_3", "obj_3"], ["start_4", "obj_4"], ["start_5", "obj_5"], ["start_6", "obj_6"], ["start_7", "obj_7"], ["start_8", "obj_8"], ["start_9", "obj_9"], ["start_10", "obj_10"], ["start_11", "obj_11"], ["start_12", "obj_12"], ["start_13", "obj_13"], ["start_14", "obj_14"], ["start_15", "obj_15"]];



dyn_main_setup = {

    dyn_start_markers = [];

    for "_i" from 0 to 15 do {
        _m1 = format ["start_%1", _i];
        _m2 = format ["obj_%1", _i];
        _m3 = format ["support_%1", _i];

        dyn_start_markers pushBack [_m1, _m2, _m3];        
    };

    dyn_locations = [];

    ///-------------------Version 1 ------------------------
    // dyn_map_center = [worldSize / 2, worldsize / 2, 0];
    // _locations = nearestLocations [dyn_map_center, ["NameVillage", "NameCity"], worldSize * 0.3];
    // _startLoc = selectRandom _locations;
    // _startPos = getPos _startLoc;
    // private _campaignDir = ((getPos _startLoc) getDir dyn_map_center) - 180;
    // _playerStart = [3600 * (sin _campaignDir), 3600 * (cos _campaignDir), 0] vectorAdd _startPos;
    // dyn_locations pushBack _startLoc;

    ////---------------------Version 2------------------------------
    dyn_map_center = [worldSize / 2, worldsize / 2, 0];
    
    _startPair = selectRandom dyn_start_markers;

    // debug override
    // _startPair = ["start_14", "obj_14", "support_14"];
    _playerStartDir = markerDir (_startPair#0);

    _playerStart = getMarkerPos (_startPair#0);
    _startLoc = nearestLocation [getMarkerPos (_startPair#1), ""];
    _startPos = getPos _startLoc;
    _supportPos = getMarkerPos (_startPair#2);
    dyn_locations pushBack _startLoc;
    private _campaignDir = ((getPos _startLoc) getDir dyn_map_center) - 180;

    if (dyn_debug) then {
        _pm = createMarker [str (random 1), _playerStart];
        _pm setMarkerType "mil_marker";
        _lm = createMarker [str (random 1), _startPos];
        _lm setMarkerType "mil_circle";
    };

    if !(dyn_debug) then {
        {
            deleteMarker (_x#0);
            deleteMarker (_x#1);
            deleteMarker (_x#2);
        } forEach dyn_start_markers;

        deleteMarker "test_m_1";
        deleteMarker "test_m_2";
        
    };


    _intervals = 2000;
    _campaignDir = _campaignDir + ([-20, 20] call BIS_fnc_randomInt);
    _offsetPos = [1500 * (sin (_campaignDir - 180)), 1500 * (cos (_campaignDir - 180)), 0] vectorAdd _startPos;
    for "_i" from 0 to 8 do {
        _pos = [(_intervals * _i) * (sin (_campaignDir - 180)), (_intervals * _i) * (cos (_campaignDir - 180)), 0] vectorAdd _offsetPos;
        _loc = nearestLocation [_pos, "NameVillage"];
        if ((_pos distance2D (getPos _loc)) < 3000) then {
            _valid = {
                if (((getPos _x) distance2D (getPos _loc)) < 2500) exitWith {false};
                true 
            } forEach dyn_locations;
            if (_valid) then {dyn_locations pushBackUnique _loc};
        };
        _loc = nearestLocation [_pos, "NameCity"];
        if ((_pos distance2D (getPos _loc)) < 3000) then {
            _valid = {
                if (((getPos _x) distance2D (getPos _loc)) < 2500) exitWith {false};
                true 
            } forEach dyn_locations;
            if (_valid) then {dyn_locations pushBackUnique _loc};
        };
        _loc = nearestLocation [_pos, "NameCityCapital"];
        if ((_pos distance2D (getPos _loc)) < 3000) then {
            _valid = {
                if (((getPos _x) distance2D (getPos _loc)) < 2500) exitWith {false};
                true 
            } forEach dyn_locations;
            if (_valid) then {dyn_locations pushBackUnique _loc};
        };
        // debug
        if (dyn_debug) then {
            _m = createMarker [str (random 1), _pos];
            _m setMarkerText str _i;
            _m setMarkerType "mil_dot";
        };
    };

    if (dyn_debug) then {
        _i = 0;
        {
            _m = createMarker [str (random 1), getPos _x];
            _m setMarkerText str _i;
            _m setMarkerType "mil_circle";
            _i = _i + 1;
        } forEach dyn_locations;
    };

    _aoStart = [_playerStart, 2500, ["TRAIL", "TRACK"]] call BIS_fnc_nearestRoad;

    // [getPos _aoStart, _startPos] call dyn_place_player;

    [getMarkerPos "spawn_start", _playerStartDir, getPos _aoStart, _startPos, _supportPos] call dyn_place_player_deployed;
    deleteMarker "spawn_start";

    [] call dyn_place_arty;

    [dyn_locations, _playerStart, _campaignDir] spawn {
        params ["_locations", "_playerStart", "_campaignDir"];
        private ["_midPoint"];


        for "_i" from 0 to (count _locations) - 1 do {
            _loc = _locations#_i;

            private _dir = 0;
            private _outerDefenses = false;
            private _midDefenses = false;
            if (_i > 0) then {
                _pos = getPos (_locations#(_i - 1));
                _dir = (getPos _loc) getDir _pos;
                if (((getPos _loc) distance2D _pos) > 1600) then {
                    _outerDefenses = true;
                };

                // between town Defenses
                if (((getPos _loc) distance2D _pos) > 3500) then {
                    _midDistance = ((getPos _loc) distance2D _pos) / 2;
                    _midPoint = [_midDistance * (sin (_dir - 180)), _midDistance * (cos (_dir - 180)), 0] vectorAdd _pos;
                    _midDefenses = true;
                };
            }
            else
            {  
                _dir = (getPos _loc) getDir _playerStart;
                if (((getPos _loc) distance2D _playerStart) > 1600) then {
                    _outerDefenses = true;
                };


            };


            // _trg setTriggerTimeout [10, 30, 60, false];

            _locationName = text _loc;
            dyn_en_comp = selectRandom dyn_opfor_comp;

            _artyPos1 = getPos (_locations#_i) getPos [300, _dir - 180];
            [_artyPos1, _dir] call dyn_place_opfor_light_arty;


            if (_i + 1 < (count _locations) - 1) then {
                _mP1 = getPos (_locations#(_i + 1)) getPos [200, 0];
                [objNull, _mP1 , "b_hq", "RegCP.", "colorOPFOR", 0.8] call dyn_spawn_intel_markers;
                [objNull, _mP1, "colorOpfor", 1000] call dyn_spawn_intel_markers_area;

                if (_i + 2 > (count _locations) - 1) then {
                    _artyPos2 = getPos (_locations#(_i + 1)) getPos [300, 0];
                    [_artyPos2, _campaignDir] call dyn_place_opfor_arty;
                    _artyPos3 = getPos (_locations#(_i + 1)) getPos [300, 180];
                    [_artyPos3, _campaignDir] call dyn_place_opfor_rocket_arty;
                };
            };
            if (_i + 2 < (count _locations) - 1) then {
                _mP2 = getPos (_locations#(_i + 2)) getPos [200, 0];
                [objNull, _mP2, "b_art", "ArtReg.", "colorOPFOR", 0.8] call dyn_spawn_intel_markers;
                [objNull, _mP2, "colorOpfor", 1600] call dyn_spawn_intel_markers_area;
                _artyPos2 = getPos (_locations#(_i + 2)) getPos [300, 0];
                [_artyPos2, _campaignDir] call dyn_place_opfor_arty;
                _artyPos3 = getPos (_locations#(_i + 2)) getPos [300, 180];
                [_artyPos3, _campaignDir] call dyn_place_opfor_rocket_arty;
            };
                        
            dyn_defense_active = false;

            _dyn_defense_atkPos = getPos player;
            if (_i > 0) then {_dyn_defense_atkPos = getPos (_locations#(_i - 1))};

            _startDefense = false;
            
            if (((random 1) > 0.6 and (_dyn_defense_atkPos distance2D (getPos _loc)) > 3000 and _i > 0) or _startDefense) then {
                _waitTime = 900;
                if (_startDefense) then {_waitTime = 360};
                if (dyn_debug) then {_waitTime = 5};
                [_dyn_defense_atkPos, getPos _loc, _waitTime] spawn dyn_defense;
                sleep 5;
                _defDir = _dyn_defense_atkPos getDir (getPos _loc);
                _linePos = [300 * (sin _defDir), 300 * (cos _defDir), 0] vectorAdd _dyn_defense_atkPos;
                [west, format ["defTask_%1", _i], ["Deffensive", "Defend against Counter Attack", ""], _linePos, "ASSIGNED", 1, true, "defend", false] call BIS_fnc_taskCreate;

                waitUntil {!(dyn_defense_active)};

                [format ["defTask_%1", _i], "SUCCEEDED", true] call BIS_fnc_taskSetState;
                sleep 10;
            };

            private _aoArea = 400;
            if(_locationName == "" or _locationName == "Weferlingen" or _locationName == "Grasleben" or _locationName == "Velpke") then {_aoArea = 800};
            _trg = createTrigger ["EmptyDetector", (getPos _loc), true];
            _trg setTriggerActivation ["WEST", "PRESENT", false];
            _trg setTriggerStatements ["this", " ", " "];
            _trg setTriggerArea [_aoArea, _aoArea, _dir, false, 30];

            _endTrg = createTrigger ["EmptyDetector", (getPos _loc), true];
            _endTrg setTriggerActivation ["WEST SEIZED", "PRESENT", false];
            _endTrg setTriggerStatements ["this", " ", " "];
            _endTrg setTriggerArea [_aoArea + 100, _aoArea + 100, _dir, false, 30];
            _endTrg setTriggerTimeout [180, 240, 300, false];
            

            if (_i > 0) then {
                [getPos _loc, _dir, _endTrg, _campaignDir, getPos (_locations#(_i - 1)), dyn_en_comp] spawn dyn_create_markers;
                _dyn_defense_atkPos = getPos (_locations#(_i - 1));

                // Supply Reinforcements
                if (({alive _x} count (units dyn_support_group)) <= 0 or !alive dyn_support_vic or isNull dyn_repair_vic) then {
                    dyn_support_vic = createVehicle [dyn_player_support_vic_type, _playerStart, [], 40, "NONE"];
                    dyn_support_vic setVariable ["pl_set_supply_vic", true];
                    dyn_support_group = createVehicleCrew dyn_support_vic;
                    dyn_support_group setGroupId [format ["TraTrp %1", 2 +_i]];
                    player hcSetGroup [dyn_support_group];
                };

                sleep 1;
                if (({alive _x} count (units dyn_repair_group)) <= 0 or !alive dyn_repair_vic or isNull dyn_repair_vic) then {
                    dyn_repair_vic = createVehicle [dyn_player_repair_vic_type, _playerStart, [], 40, "NONE"];
                    dyn_repair_vic setVariable ["pl_set_repair_vic", true];
                    dyn_repair_group = createVehicleCrew dyn_repair_vic;
                    dyn_repair_group setGroupId [format ["GSITrp %1", 3 +_i]];
                    player hcSetGroup [dyn_repair_group];
                };
            }
            else
            {
                [getPos _loc, _dir, _endTrg, _campaignDir, getPos player, dyn_en_comp] spawn dyn_create_markers;
                // if ((random 1) > 0.35) then {_startDefense = true};
            };
            
            [getPos _loc, _dir, _endTrg] spawn dyn_ambiance;

            [west, format ["task_%1", _i], ["Offensive", format ["Capture %1", _locationName], ""], getPos _loc, "ASSIGNED", 1, true, "attack", false] call BIS_fnc_taskCreate;

            if (_i > 0 and !dyn_debug) then {
                sleep 120;
            };


            _townDefenseGrps = [_trg, _endTrg, _dir] call dyn_town_defense;

            if (_midDefenses) then {

                _defenseType = selectRandom ["point", "ambush", "minefield"];

                // debug
                // _defenseType = "ambush";

                switch (_defenseType) do { 
                    case "line" : {[_midPoint, _trg, _dir, true] call dyn_defense_line}; 
                    case "point" : {[_midPoint, _trg, _dir, true] call dyn_strong_point_defence};
                    case "mobileTank" : {[_midPoint, _trg, _dir, true] call dyn_mobile_armor_defense};
                    case "roadem" : {[_midPoint, _trg, _dir] call dyn_road_emplacemnets};
                    case "recon" : {[_midPoint, _trg, _dir] call dyn_recon_convoy};
                    case "ambush" : {[_midPoint, _trg, _dir] call dyn_ambush};
                    case "minefield" : {[_midPoint, 2500, _dir, true] call dyn_spawn_mine_field};
                    default {[_midPoint, _trg, _dir, true] call dyn_defense_line}; 
                };

                [_midPoint, 2000, [2, 3] call BIS_fnc_randomInt, _trg, _dir] spawn dyn_spawn_forest_patrol;

                [_midPoint, 2000, 400, _midPoint] spawn dyn_spawn_bridge_defense;

                [_midPoint, 2000, 1, _trg] spawn dyn_spawn_hill_overwatch;

                [_endTrg, _midPoint, 1500, _midPoint] spawn dyn_spawn_side_town_guards;

                [objNull, _midPoint getPos [[100, 300] call BIS_fnc_randomInt, [0, 359] call BIS_fnc_randomInt], "b_mech_inf", "MechInfCoy.", "colorOPFOR", 0.8] call dyn_spawn_intel_markers;

                if (dyn_debug) then {
                    _m = createMarker [str (random 1), _midPoint];
                    _m setMarkerType "mil_marker";
                };
            };

            if (_outerDefenses) then {

                _defenseType = selectRandom ["mobileTank", "recon", "ambush", "minefield", "point"];

                // debug
                // _defenseType = "point";

                switch (_defenseType) do { 
                    case "line" : {[getPos _loc, _trg, _dir] call dyn_defense_line}; 
                    case "point" : {[getPos _loc, _trg, _dir] call dyn_strong_point_defence};
                    case "mobileTank" : {[getPos _loc, _trg, _dir] call dyn_mobile_armor_defense};
                    // case "roadem" : {[getPos _loc, _trg, _dir] call dyn_road_emplacemnets};
                    case "recon" : {[getPos _loc, _trg, _dir] call dyn_recon_convoy};
                    case "ambush" : {[getPos _loc, _trg, _dir] call dyn_ambush};
                    case "minefield" : {[(getPos _loc) getPos [[1300, 1700] call BIS_fnc_randomInt, _dir], 2000, _dir, true] call dyn_spawn_mine_field};
                    case "empty" : {};
                    default {[getPos _loc, _trg, _dir] call dyn_defense_line}; 
                };
            };

            // _artyPos1 = getPos (_locations#_i) getPos [300, _dir - 180];
            // [_artyPos1, _dir] call dyn_place_opfor_light_arty;


            // if (_i + 1 < (count _locations) - 1) then {
            //     _mP1 = getPos (_locations#(_i + 1)) getPos [200, 0];
            //     [objNull, _mP1 , "b_hq", "RegCP.", "colorOPFOR", 0.8] call dyn_spawn_intel_markers;
            //     [objNull, _mP1, "colorOpfor", 1000] call dyn_spawn_intel_markers_area;
            // };
            // if (_i + 2 < (count _locations) - 1) then {
            //     _mP2 = getPos (_locations#(_i + 2)) getPos [200, 0];
            //     [objNull, _mP2, "b_art", "ArtReg.", "colorOPFOR", 0.8] call dyn_spawn_intel_markers;
            //     [objNull, _mP2, "colorOpfor", 1600] call dyn_spawn_intel_markers_area;
            //     _artyPos2 = getPos (_locations#(_i + 1)) getPos [300, 0];
            //     [_artyPos2, _campaignDir] call dyn_place_opfor_arty;
            //     _artyPos3 = getPos (_locations#(_i + 1)) getPos [300, 180];
            //     [_artyPos3, _campaignDir] call dyn_place_opfor_rocket_arty;
            // };

            // [getPos _loc, _dir] spawn dyn_spawn_heli_attack;

            sleep 5;

            [dyn_en_comp#0] call dyn_opfor_change_uniform;

               { 
                    _x addCuratorEditableObjects [allUnits, true]; 
                    _x addCuratorEditableObjects [vehicles, true];  
               } forEach allCurators; 

            sleep 10;
            if (_i < ((count _locations) - 1)) then {
                _retreatPos = getPos (_locations#(_i + 1));
                [_endTrg, _retreatPos, (allGroups select {side _x == east})] spawn dyn_retreat;
            };

            _garbagePos = getPos _endTrg;

            if !(dyn_debug) then {
                waitUntil {sleep 2; triggerActivated _endTrg or (count (allGroups select {(side (leader _x)) isEqualTo east})) <= 6};

            }
            else
            {
                waitUntil {sleep 1; triggerActivated _trg};
            };
            
            {
                deleteMarker _x;
            } forEach dyn_intel_markers;

            [] spawn dyn_garbage_clear;

            [format ["task_%1", _i], "SUCCEEDED", true] call BIS_fnc_taskSetState;

            sleep 5;

            [west, format ["task_clear_%1", _i], ["Deffensive", format ["Secure %1 and wait for tasking", _locationName], ""], getPos _loc, "ASSIGNED", 1, true, "wait", false] call BIS_fnc_taskCreate;
            
            if !(dyn_debug) then {sleep 180};

            [format ["task_clear_%1", _i], "SUCCEEDED", true] call BIS_fnc_taskSetState;
        };
    };
};

[] call dyn_main_setup;


