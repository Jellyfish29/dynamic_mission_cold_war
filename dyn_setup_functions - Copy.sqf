dyn_debug = false;
// dyn_debug = true;
dyn_no_spawn = false;
// dyn_no_spawn = true;

dyn_place_on_road = false;

// setGroupIconsVisible [true,false];

addMissionEventHandler ["TeamSwitch", {
    params ["_previousUnit", "_newUnit"];
    _hcc = allMissionObjects "HighCommand" select 0;
    _hcs = allMissionObjects "HighCommandSubordinate" select 0;
    _zeus = allMissionObjects "ModuleCurator_F" select 0;
    _hcUnits = synchronizedObjects _hcs;
    deleteVehicle _previousUnit;
    deleteVehicle _hcc;
    deleteVehicle _hcs;
    deleteVehicle _zeus;
    _logicGroup = createGroup sideLogic;
    _newHcc = _logicGroup createUnit ["HighCommand", [0, 0, 0], [], 0, "NONE"];
    _newHcs = _logicGroup createUnit ["HighCommandSubordinate", [0, 0, 0], [], 0, "NONE"];
    _newZeus = _logicGroup createUnit ["ModuleCurator_F", [0, 0, 0], [], 0, "NONE"];
    _newUnit synchronizeObjectsAdd [_newHcc];
    _newUnit synchronizeObjectsAdd [_newZeus];
    _newHcs synchronizeObjectsAdd _hcUnits;
    _newHcc synchronizeObjectsAdd [_newHcs];
    (group _newUnit) selectLeader _newUnit;
    player hcSetGroup [group player];
    // [] call dyn_add_all_groups;

    [] spawn {

        sleep 3;

        onGroupIconOverEnter {scriptname "HC: onGroupIconOverEnter";
            if !(hcshownbar) exitwith {};

            _is3D = _this select 0;
            _group = _this select 1;
            _wpID = _this select 2;
            _posx = _this select 3;
            _posy = _this select 4;
            _logic = player getvariable "BIS_HC_scope";

            if (_wpID < 0) then {
                _logic setvariable ["groupover",_group];
                _logic setvariable ["wpover",[grpnull]];
            } else {
                if (_group in hcallgroups player && !(_logic getvariable "LMB_hold")) then {
                    _logic setvariable ["groupover",grpnull];
                    _logic setvariable ["wpover",[_group,_wpID]];
                };
            };

        };
    };

    _newUnit addEventHandler ["GetInMan", {
        params ["_unit", "_role", "_vehicle", "_turret"];
        private ["_group"];
        _group = group player;
        _vicGroup = group (driver (vehicle player));
        if (_vicGroup != (group player)) then {
            player setVariable ["pl_player_vicGroup", _vicGroup];
            // _vicGroup setVariable ["setSpecial", true];
            // _vicGroup setVariable ["specialIcon", "\A3\ui_f\data\igui\cfg\simpleTasks\types\truck_ca.paa"];
            _vicGroup setVariable ["pl_has_cargo", true];
            // _group setVariable ["pl_show_info", false];
            [_group] call pl_hide_group_icon;
            // player hcRemoveGroup _group;
        };
    }];

    _newUnit addEventHandler ["GetOutMan", {
        params ["_unit", "_role", "_vehicle", "_turret"];
        private ["_group"];
        _group = group player;
        _vicGroup = player getVariable ["pl_player_vicGroup", (group player)];
        _group setVariable ["setSpecial", false];
        _group setVariable ["onTask", false];
        // _group setVariable ["pl_show_info", true];
        if !(_group getVariable ["pl_show_info", false]) then {
            [_group, "hq"] call pl_show_group_icon;
        };
        // player hcSetGroup [_group];

        _cargo = fullCrew [(vehicle ((units _vicGroup)#0)), "cargo", false];
        if ((count _cargo == 0)) exitWith {
            // _vicGroup setVariable ["setSpecial", false];
            _vicGroup setVariable ["pl_has_cargo", false];
        };
        if (({(group (_x#0)) isEqualTo _group} count _cargo) > 0) then {
            [_vicGroup, _cargo, _group] spawn {
                params ["_vicGroup", "_cargo", "_group"];
                waitUntil {sleep 1; (({(group (_x#0)) isEqualTo _group} count (fullCrew [(vehicle ((units _vicGroup)#0)), "cargo", false])) == 0)};
                // _vicGroup setVariable ["setSpecial", false];
                _vicGroup setVariable ["pl_has_cargo", false];
            };
        };
    }];
}];

dyn_add_all_groups = {
    {
        _x setVariable ["pl_show_info", true];
        player hcSetGroup [_x];
    } forEach (allGroups select {side (leader _x) == playerSide});
};


dyn_place_player = {
    params ["_StartPos", "_dest", "_startRoad"];
    private ["_startPos", "_infGroups", "_vehicles", "_roads", "_road", "_roadsPos", "_dir", "_roadPos"];


    dyn_player_vic = vehicle player;

    private _reconVics = nearestObjects [getMarkerPos "dyn_start_recon", ["LandVehicle"], 150];
    private _c1Vics = nearestObjects [getMarkerPos "dyn_start_c_1", ["LandVehicle"], 150];
    // reverse _c1Vics;
    private _c2Vics = nearestObjects [getMarkerPos "dyn_start_c_2", ["LandVehicle"], 150];
    // reverse _c2Vics;
    private _supportVics = nearestObjects [getMarkerPos "dyn_start_support", ["LandVehicle"], 150];
    private _roadVics = +_supportVics;
    // reverse _supportVics;
    {
        deleteMarker _x;
    } forEach ["dyn_start_recon","dyn_start_c_1", "dyn_start_c_2", "dyn_start_support"];
    
    private _campaignDir = _startPos getDir _dest;

    // Recon
    _reconPos = _startPos getPos [100, _campaignDir];

    for "_i" from 0 to (count _reconVics) - 1 step 1 do {
        private _setPos = _reconPos getpos [30 * _i, _campaignDir + 90];
        _setPos = _setPos findEmptyPosition [0, 100, typeOf (_reconVics#_i)];

        if (_setPos isEqualTo []) then {
            _setPos = _setPos findEmptyPosition [0, 1000, typeOf (_reconVics#_i)];
        };

        (_reconVics#_i) setVehiclePosition [_setPos, [], 0, "NONE"];
        (_reconVics#_i) setdir _campaignDir;
    };

    if !(dyn_place_on_road) then { 


        // column 1
        _c1Pos = _startPos getPos [60, _campaignDir + 90];
        for "_i" from 0 to (count _c1Vics) - 1 step 1 do {
            private _toSetDir = _campaignDir - 25;
            if (_i % 2 == 0) then {
                _toSetDir = _campaignDir + 25;
            };
            _setPos = _c1Pos getpos [25 * _i, _campaignDir - 180];
            _setPos = _setPos findEmptyPosition [0, 100, typeOf (_c1Vics#_i)];

            if (_setPos isEqualTo []) then {
                _setPos = _setPos findEmptyPosition [0, 1000, typeOf (_c1Vics#_i)];
            };

            (_c1Vics#_i) setVehiclePosition [_setPos getpos [5, _toSetDir], [], 0, "NONE"];
            (_c1Vics#_i) setdir _toSetDir;
        };

        // column 2
        _c2Pos = _startPos getPos [60, _campaignDir - 90];
        for "_i" from 0 to (count _c2Vics) - 1 step 1 do {
            private _toSetDir = _campaignDir - 25;
            if (_i % 2 == 0) then {
                _toSetDir = _campaignDir + 25;
            };
            _setPos = _c2Pos getpos [25 * _i, _campaignDir - 180];
            _setPos = _setPos findEmptyPosition [0, 100, typeOf (_c2Vics#_i)];

            if (_setPos isEqualTo []) then {
                _setPos = _setPos findEmptyPosition [0, 1000, typeOf (_c2Vics#_i)];
            };
            (_c2Vics#_i) setVehiclePosition [_setPos getpos [5, _toSetDir], [], 0, "NONE"];
            (_c2Vics#_i) setdir _toSetDir;
        };
    } else {
        _roadVics = _supportVics + _c2Vics + _c1Vics; 
    }; 

    // place on Road
    private _road = _startRoad;
    private _lastRoad = _road;
    private _sortBy = "DESCEND";
    _roadPos = [];
    _roadBlackList = [];
    _usedRoads = [];
    for "_i" from 0 to (count _roadVics) - 1 step 1 do {

        private _connected = (roadsConnectedTo [_road, true]);

        if ((count _connected) <= 1) then {
            _road = ([roadsConnectedTo [_startRoad, true], [], {(getpos _x) distance2D _dest}, "ASCEND"] call BIS_fnc_sortBy)#0;
            _connected = (roadsConnectedTo [_road, true]);
            _startRoad = _road;
            _sortBy = "ASCEND";
        };
        _road = ([_connected, [], {(getpos _x) distance2D _dest}, _sortBy] call BIS_fnc_sortBy)#0;

        _roadPos = getPos _road;
        _info = getRoadInfo _road;    
        _endings = [_info#6, _info#7];
        _endings = [_endings, [], {_x distance2D _dest}, "ASCEND"] call BIS_fnc_sortBy;
        _dir = (_endings#1) getDir (_endings#0);

        private _spawnDir = _dir;

        (_roadVics#_i) setVehiclePosition [_roadPos, [], 0, "NONE"];

        (_roadVics#_i) setdir _spawnDir;


        sleep 0.1;
    };

    [getPos player, 700, "Assembly Area", "colorBlack"] call dyn_draw_mil_symbol_objectiv_free;
};

dyn_place_player_old = {
    params ["_pos", "_dest"];
    private ["_startPos", "_infGroups", "_vehicles", "_roads", "_road", "_roadsPos", "_dir", "_roadPos"];

    dyn_player_vic = vehicle player;

    _startPos = getMarkerPos "spawn_start";
    deleteMarker "spawn_start";
    _infGroups = [];
    _vehicles = nearestObjects [_startPos,["LandVehicle"],200];
    {
        if(((_startPos distance2D (leader _x)) < 300) and !(vehicle (leader _x) in _vehicles)) then {
            _infGroups pushBack _x;
        }
    } forEach (allGroups select {side _x isEqualTo playerSide});

    // _roads = _pos nearRoads 300;
    
    private _campaignDir = _pos getDir _dest;
    _road = [_pos, 300] call BIS_fnc_nearestRoad;
    private _startRoad = _road;
    private _lastRoad = _road;
    private _sortBy = "DESCEND";
    _usedRoads = [];

    private _roadPos = [];

    _forwardPos = (getPos _road) getPos [50, _campaignDir];
    private _leftRight = -90;

    _roadsPos = [];
    _roadBlackList = [];
    for "_i" from 0 to (count _vehicles) - 1 step 1 do {

        private _connected = (roadsConnectedTo [_road, true]);

        if ((count _connected) <= 1) then {
            _road = ([roadsConnectedTo [_startRoad, true], [], {(getpos _x) distance2D _dest}, "ASCEND"] call BIS_fnc_sortBy)#0;
            _connected = (roadsConnectedTo [_road, true]);
            _startRoad = _road;
            _sortBy = "ASCEND";
        };
        _road = ([_connected, [], {(getpos _x) distance2D _dest}, _sortBy] call BIS_fnc_sortBy)#0;


        _roadPos = getPos _road;
        _info = getRoadInfo _road;    
        _endings = [_info#6, _info#7];
        _endings = [_endings, [], {_x distance2D _dest}, "ASCEND"] call BIS_fnc_sortBy;
        _dir = (_endings#1) getDir (_endings#0);

        // _m = createMarker [str (random 1), _roadPos];
        // _m setMarkerType "mil_dot";
        // _m setMarkerText (str _i);

        private _spawnDir = _dir;

        if (_i < _fieldElement) then {
            if (_i % 2 == 0 or _i == 0) then {_leftRight = -90} else {_leftRight = 90};

            _spawnPos = _roadPos getpos [[40, 50] call BIS_fnc_randomInt, _dir + _leftRight];

            if (!([_spawnPos] call dyn_is_town) and !([_spawnPos] call dyn_is_forest) and !([_spawnPos] call dyn_is_water)) then {
                _roadPos = _spawnPos;
                _spawnDir = _dir + ((_leftRight / 2) + ([-5, 5] call BIS_fnc_randomInt));
            };
        };

        (_vehicles#_i) setVehiclePosition [_roadPos, [], 0, "NONE"];

        (_vehicles#_i) setdir _spawnDir;


        sleep 0.1;
    };
};

dyn_customice_playerside = {

    {
        // _x addGoggles (selectRandom ["gm_headgear_foliage_summer_forest_01", "gm_headgear_foliage_summer_forest_02", "gm_headgear_foliage_summer_forest_03", "gm_headgear_foliage_summer_forest_04"]);
        _faceunit = (face _x + (selectRandom ["_cfaces_BWTarn", "_cfaces_BWStripes"]));
        _x setVariable ["JgKp_Face", _faceunit, true];
        // _x addItem "gm_handgrenade_frag_dm51a1";
        // _x addItem "gm_handgrenade_frag_dm51a1";
    } forEach (allUnits select {side _x == playerSide});

};

[] call dyn_customice_playerside;

dyn_place_arty = {
    params ["_rearDir"];

    artGrp_1 setVariable ["pl_not_addalbe", true];
    artGrp_2 setVariable ["pl_not_addalbe", true];

    _artyLeader = leader artGrp_1;
    {
        _pos1 = getPosWorldVisual (vehicle _artyLeader);
        _pos2 = getPosWorldVisual (vehicle _x);
        _relPos = [(_pos1 select 0) - (_pos2 select 0), (_pos1 select 1) - (_pos2 select 1)];
        _x setVariable ["dyn_rel_pos", _relPos];
    } forEach (((units artGrp_1) + (units artGrp_2)) - [_artyLeader]);

    _batteryPos = (getPos player) getPos [4500, _rearDir];
    _batteryPos = ((selectBestPlaces [_batteryPos, 1500, "2*meadow", 95, 1])#0)#0;
    // _batteryPos = _batteryPos findEmptyPosition [0, 500, typeOf (vehicle _artyLeader)];

    (vehicle _artyLeader) setPos _batteryPos;

    {
        (vehicle _x) setDir (_rearDir - 180);
        // _x disableAI "PATH";
        doStop (vehicle _x);
    } forEach ((units artGrp_1) + (units artGrp_2));

    {
        _pos1 = getPosWorldVisual (vehicle _artyLeader);
        _pos2 = _x getVariable "dyn_rel_pos";
        _setPos = [(_pos1 select 0) + (_pos2 select 0), (_pos1 select 1) + (_pos2 select 1)];
        (vehicle _x) setPos _setPos;
    } forEach (((units artGrp_1) + (units artGrp_2)) - [_artyLeader]);

    _aaPOs = _batteryPos getPos [50, 90];
    dyn_aa_vic setPos _aaPOs;


    [_batteryPos] spawn {
        params ["_batteryPos"];

        sleep 10;

        [objNull, _batteryPos, "b_art", "", "colorBLUFOR", 1] call dyn_spawn_intel_markers;
        [_batteryPos, 500, "DEU BrgArt", "colorBlack"] call dyn_draw_mil_symbol_objectiv_free;
        [dyn_aa_vic_grp] call pl_hide_group_icon;
        [artGrp_1] call pl_hide_group_icon;
        [artGrp_2] call pl_hide_group_icon;
    };
    // [objNull, getPos (leader artGrp_1), "colorBLUFOR", 400] call dyn_spawn_intel_markers_area;
};

dyn_opfor_arty = [];
dyn_opfor_grps = [];

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
        dyn_opfor_grps pushBack _grp;
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
        dyn_opfor_grps pushBack _grp;
    };
};

dyn_opfor_balistic_arty = [];

dyn_palace_opfor_balistic_arty = {
    params ["_artyPos", "_dir"];

    if (count dyn_opfor_balistic_arty > 0) then {
        {
            {
                deleteVehicle _x;
            } forEach (crew _x);
            deleteVehicle _x;
        } forEach dyn_opfor_balistic_arty;
    };
    dyn_opfor_balistic_arty = [];
    _artyPos = ((selectBestPlaces [_artyPos, 1000, "2*meadow", 95, 1])#0)#0;
    _artyPos = _artyPos findEmptyPosition [100, 500, dyn_standart_balistic_arty];
    _arty = createVehicle [dyn_standart_balistic_arty, _artyPos, [], 0, "NONE"];
    _arty setdir _dir;
    _grp = createVehicleCrew _arty;
    dyn_opfor_balistic_arty pushBack _arty;
    dyn_opfor_grps pushBack _grp;
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
    _artyPos = ((selectBestPlaces [_artyPos, 350, "2*meadow", 95, 1])#0)#0;

    _lightArtyGrp = createGroup [east, false];
    dyn_opfor_grps pushBack _lightArtyGrp;
    for "_i" from 0 to 2 do {
        _offsetDir = 90;
        if (_i == 1) then {_offsetDir = 70};
        _aPos = _artyPos getPos [10 * _i, _dir - _offsetDir];
        _arty = createVehicle [dyn_standart_light_arty, _aPos, [], 0, "NONE"];
        _arty setdir _dir;
        _grp = createVehicleCrew _arty;
        _grp setVariable ["pl_not_recon_able", true];
        (units _grp) joinSilent _lightArtyGrp;
        dyn_opfor_light_arty pushBack _arty;
        // dyn_opfor_grps pushBack _grp;

        _sPos = (getPos _arty) getPos [1, _dir];
        _sandBag = createVehicle ["land_gm_sandbags_01_round_01", _sPos, [], 0, "CAN_COLLIDE"];
        _sandBag setDir (getDir _arty);
        if (_i == 1) then {
            _guardPos = _aPos getPos [15, _dir - 180];
            _gGrp = [_guardPos, 0] call dyn_spawn_dimounted_inf;
            _gGrp setVariable ["pl_not_recon_able", true];
            [units _gGrp] joinSilent _lightArtyGrp;
            dyn_opfor_grps pushBack _gGrp;
        };
    };

    _lightArtyGrp deleteGroupWhenEmpty true;
};


dyn_main_setup = {
    private ["_startPos", "_startRoad", "_campaignDir", "_endPos", "_playerStart"];


    dyn_locations = [];

    [] spawn dyn_garbage_loop;

    private _dummygrp = createGroup [civilian, true];

    private _allLocations = nearestLocations [dyn_map_center, ["NameCity", "NameVillage", "NameCityCapital"], worldSize];
    dyn_all_towns = +_allLocations;
    private _validLocations = [];
    {
        _loc = _x;
        {
            if ((getpos _loc) inArea _x) then {
                _validLocations pushBack _loc;
            };
        } forEach ["dyn_start_zone_1", "dyn_start_zone_2", "dyn_start_zone_3", "dyn_start_zone_4"];
        [getPos _loc, 600] spawn dyn_hide_fences;
    } forEach _allLocations;

    private _campaignDir = 0;
    private _startLoc = selectRandom _validLocations;
    private _startPos = getPos _startLoc;

    while {(count dyn_locations) <= 2} do {

        _startLoc = selectRandom _validLocations;
        _startPos = getPos _startLoc;

        // West
        // if ((_startPos#0) < (dyn_map_center#0)) then {
            // South
            // if ((_startPos#1) < (dyn_map_center#1)) then {
            //     _campaignDir = 45 + ([-50, 50] call BIS_fnc_randomInt);
            // // North
            // } else {
            //     _campaignDir = 135 + ([-50, 50] call BIS_fnc_randomInt);
            // };

        // East
        // } else {
            // // South
            // if ((_startPos#1) < (dyn_map_center#1)) then {
            //     _campaignDir = 315 + ([-50, 50] call BIS_fnc_randomInt);
            // // North
            // } else {
            //     _campaignDir = 225 + ([-50, 50] call BIS_fnc_randomInt);
            // };
        // };

        _campaignDir = [0, 360] call BIS_fnc_randomInt;


        // _campaignDir = _endPos getDir (getpos _startRoad);

        // _dummy = _dummygrp createUnit ["C_man_polo_1_F", (getPos _startRoad) getPos [600, _campaignDir - 180], [], 0, "NONE"];
        // _dummy hideObjectGlobal true;
        // dyn_locations = [_dummy];
        dyn_locations = [_startLoc];

        _offsetPos = _startPos getPos [1000, _campaignDir];
        _intervals = 3500;

        private _distLimit = 2000;
        private _delta = 2000;
        for "_i" from 0 to 6 do {
            _pos = [(_intervals * _i) * (sin (_campaignDir)), (_intervals * _i) * (cos (_campaignDir)), 0] vectorAdd _offsetPos;
            _loc = nearestLocation [_pos, "NameCityCapital"];
            if ((_pos distance2D (getPos _loc)) < _delta) then {
                _valid = {
                    if (((getPos _x) distance2D (getPos _loc)) < _distLimit) exitWith {false};
                    true 
                } forEach dyn_locations;
                if (_valid) then {dyn_locations pushBackUnique _loc};
            };
            _loc = nearestLocation [_pos, "NameCity"];
            if ((_pos distance2D (getPos _loc)) < _delta) then {
                _valid = {
                    if (((getPos _x) distance2D (getPos _loc)) < _distLimit) exitWith {false};
                    true 
                } forEach dyn_locations;
                if (_valid) then {dyn_locations pushBackUnique _loc};
            };
            _loc = nearestLocation [_pos, "NameVillage"];
            if ((_pos distance2D (getPos _loc)) < _delta) then {
                _valid = {
                    if (((getPos _x) distance2D (getPos _loc)) < _distLimit) exitWith {false};
                    true 
                } forEach dyn_locations;
                if (_valid) then {dyn_locations pushBackUnique _loc};
            };
            // _distLimit = 2800;
            // debug
            if (dyn_debug) then {
                _m = createMarker [str (random 1), _pos];
                _m setMarkerText str _i;
                _m setMarkerType "mil_dot";

                _m = createMarker [str (random 1), _pos];
                _m setMarkerShape "ELLIPSE";
                _m setMarkerBrush "Border";
                _m setMarkersize [_delta, _delta];
            };
        };

        // dyn_locations deleteAt 0;
        // deleteVehicle _dummy;
        _playerStart = (getPos _startLoc) getPos [[2800, 3200] call BIS_fnc_randomInt, _campaignDir - (180 + ([-25, 25] call BIS_fnc_randomInt))];
        _playerStart = ((selectBestPlaces [_playerStart, 500, "2*meadow", 95, 1])#0)#0;

        if (([_playerStart, 70] call dyn_is_forest) or ([_playerStart] call dyn_is_town) or ([_playerStart] call dyn_is_water) or [_playerStart] call dyn_is_empty) then {
            dyn_locations = [];
        };
    };

    private _endPos = getPos (dyn_locations#((count dyn_locations) - 1));

    _startRoad = [_playerStart getpos [500, _campaignDir - 180], 500, ["TRAIL", "TRACK", "HIDE"]] call dyn_nearestRoad;
    if (isNull _startRoad) then {
        _startRoad = [_playerStart getpos [500, _campaignDir - 180], 3000] call dyn_nearestRoad;
    };

    //debug

    [_playerStart, getPos _startLoc, _startRoad] spawn dyn_place_player;

    // [] spawn dyn_allied_start_position;

    if (dyn_debug) then {
        _i = 0;
        {
            _m = createMarker [str (random 1), getPos _x];
            _m setMarkerText str _i;
            _m setMarkerType "mil_circle";
            _i = _i + 1;
        } forEach dyn_locations;

        _m = createMarker [str (random 1), _playerStart];
        _m setMarkerType "mil_marker";

        _m = createMarker [str (random 1), _startRoad];
        _m setMarkerType "mil_marker";
        _m setMarkerColor "colorBlue";
    };


    for "_i" from 0 to 15 do {
        deleteMarker (format ["start_%1", _i]);
        deleteMarker (format ["obj_%1", _i]);
        deleteMarker (format ["support_%1", _i]);   
    };

    {
        {
            deleteMarker _x;
        } forEach _x;
    } forEach [["dyn_start_zone_1", "dyn_start_zone_2"], ["dyn_start_zone_2", "dyn_start_zone_1"], ["dyn_start_zone_4", "dyn_start_zone_3"], ["dyn_start_zone_3", "dyn_start_zone_4"], ["dyn_start_zone_5", "dyn_start_zone_6"], ["dyn_start_zone_6", "dyn_start_zone_5"], ["dyn_start_zone_8", "dyn_start_zone_7"], ["dyn_start_zone_7", "dyn_start_zone_8"]];

    deleteMarker "spawn_start";

    // [(getpos (dyn_locations#0)) getdir player] call dyn_place_arty;

    private _blueUnits = [];
    {
        if (((player distance2D (leader _x)) < 300)) then {
            _blueUnits pushBack _x;
        }
    } forEach (allGroups select {side _x isEqualTo playerSide});

    [_blueUnits, west, "armor"] spawn dyn_spawn_unit_intel_markers;

    // [_campaignDir - 180, _endPos] spawn dyn_draw_phase_lines;

    [] call dyn_random_weather;

    [dyn_locations, _playerStart, _campaignDir - 180, _startRoad] spawn {
        params ["_locations", "_playerStart", "_campaignDir", "_startRoad"];
        private ["_midPoint"];

        private _drawLocations = +_locations apply {getpos _x};

        reverse _drawLocations;
        _drawLocations pushBack _playerStart;
        reverse _drawLocations;
        _drawLocations pushBack ((_drawLocations#((count _drawLocations) - 1)) getPos [2500, _campaignDir - 180]);

        for "_i" from 0 to (count _locations) - 1 do {
            _loc = _locations#_i;
            dyn_current_location = _loc;
            if (_i <= ((count _locations) - 2)) then {
                dyn_next_location = _locations#(_i + 1);
            } else {
               dyn_next_location = locationNull;
            };

            private _dir = 0;
            private _outerDefenses = false;
            private _midDefenses = false;
            private _allowDefense = false;
            if (_i > 0) then {
                _pos = getPos (_locations#(_i - 1));
                _dir = (getPos _loc) getDir _pos;
                _midDistance = ((getPos _loc) distance2D _pos) / 2;
                _midPoint = [_midDistance * (sin (_dir - 180)), _midDistance * (cos (_dir - 180)), 0] vectorAdd _pos;
                if (((getPos _loc) distance2D _pos) > 1600) then {
                    _outerDefenses = true;
                };
                // between town Defenses
                if (((getPos _loc) distance2D _pos) > 3500) then {
                    _midDistance = ((getPos _loc) distance2D _pos) / 2;
                    _midDefenses = true;
                };
                if (((getPos _loc) distance2D _pos) >= 3500) then {
                    _allowDefense = true;
                };
                // [_drawLocations#(_i+1), _drawLocations#(_i+2), _drawLocations#_i, _dir - 180] call dyn_draw_frontline;
            }
            else
            {  
                if (dyn_place_on_road) then {
                    _dir = (getPos _loc) getDir (getPos _startRoad)
                } else {
                    _dir = (getPos _loc) getDir _playerStart;
                };
                _midDistance = ((getPos _loc) distance2D _playerStart) / 2;
                _midPoint = [_midDistance * (sin (_dir - 180)), _midDistance * (cos (_dir - 180)), 0] vectorAdd _playerStart;
                if (((getPos _loc) distance2D _playerStart) > 1600) then {
                    _outerDefenses = true;
                };

                if (((getPos _loc) distance2D _playerStart) > 4000) then {
                    _midDistance = ((getPos _loc) distance2D _playerStart) / 2;
                    _midDefenses = true;
                };
                if (((getPos _loc) distance2D _playerStart) >= 3000) then {
                    _allowDefense = true;
                };
                // [_drawLocations#(_i+1), _drawLocations#(_i+2), _drawLocations#_i, _dir - 180, true] call dyn_draw_frontline;
            };

            _size = ((getPos _loc) distance2D _startRoad) / 2;
            dyn_terrain = [(getPos _loc) getPos [_size * 0.8, _dir], _dir, _size * 1.25, _size * 1.25, 100] call dyn_terrain_scan;

            dyn_read_terrain = [] call pl_ai_terrain_reading;

            // _trg setTriggerTimeout [10, 30, 60, false];

            [(getPos _loc) getdir player] call dyn_place_arty;

            _locationName = text _loc;
            dyn_en_comp = selectRandom dyn_opfor_comp;

            _artyPos1 = getPos (_locations#_i) getPos [300, _dir - 180];
            [_artyPos1, _dir] call dyn_place_opfor_light_arty;

            _lastPos =  getPos _loc;

            _artyPos2 = (_lastPos getpos [5500, _campaignDir - 180]) getPos [300, 0];
            [_artyPos2, _campaignDir] call dyn_place_opfor_arty;
            _artyPos3 = (_lastPos getpos [5500, _campaignDir - 180]) getPos [300, 180];
            [_artyPos3, _campaignDir] call dyn_place_opfor_rocket_arty;
            _artyPos4 = (_lastPos getpos [5500, _campaignDir - 180]) getPos [1000, _campaignDir - 180];
            [_artyPos4, _campaignDir] call dyn_palace_opfor_balistic_arty;

            // _allowDefense = true;
            if (_i > 0 and _allowDefense) then {

                dyn_defense_active = false;
                _dyn_defense_atkPos = getPos player;
                private _waitTime = 500;
                if (_i > 0) then {
                    _waitTime = 500;
                    _dyn_defense_atkPos = getPos (_locations#(_i - 1))
                };

                if (dyn_debug) then {
                    _waitTime = 0;
                };
                [_dyn_defense_atkPos getPos [500, _dir - 180], _dir, 2000] call dyn_get_retreat_in_def;
                [_dyn_defense_atkPos, getPos _loc, _waitTime] spawn dyn_defense;
                // [getpos player, getPos dyn_current_location, 0] spawn dyn_defense;
                sleep 5;

                waitUntil {!(dyn_defense_active)};

                sleep 5;
            };

            {
                deleteMarker _x;
            } forEach dyn_intel_markers;

            sleep 0.1;

            if !(_midDefenses) then {
                // if (_i <= 0) then {
                    [getPos _loc, _campaignDir - 180, true] call dyn_draw_frontline;
                    // [getPos _loc, _campaignDir] spawn dyn_draw_frontline;
                // } else {
                //     [getPos _loc, _campaignDir - 180, true] call dyn_draw_frontline;
                // };
            } else {
                [_midPoint, _campaignDir - 180, false, (getPos _loc) distance2D _midPoint] call dyn_draw_frontline;
                // [_midPoint, _campaignDir] spawn dyn_draw_frontline;
            };

            private _aoArea = 600;
            if(_locationName == "" or _locationName == "Weferlingen" or _locationName == "Grasleben" or _locationName == "Velpke") then {_aoArea = 1000};
            _trg = createTrigger ["EmptyDetector", (getPos _loc), true];
            _trg setTriggerActivation ["WEST", "PRESENT", false];
            _trg setTriggerStatements ["this", " ", " "];
            _trg setTriggerArea [_aoArea, _aoArea, _dir, false, 30];

            _endTrg = createTrigger ["EmptyDetector", (getPos _loc), true];
            _endTrg setTriggerActivation ["WEST SEIZED", "PRESENT", false];
            _endTrg setTriggerStatements ["this", " ", " "];
            _endTrg setTriggerArea [600, 600, _dir, false, 30];
            _endTrg setTriggerTimeout [240, 300, 400, false];
            

            if (_i > 0) then {
                _dyn_defense_atkPos = getPos (_locations#(_i - 1));

                // Supply Reinforcements
                // if (({alive _x} count (units dyn_support_group)) <= 0 or !alive dyn_support_vic or isNull dyn_repair_vic) then {
                //     dyn_support_vic = createVehicle [dyn_player_support_vic_type, _playerStart, [], 40, "NONE"];
                //     dyn_support_vic setVariable ["pl_is_supply_vehicle", true];
                //     dyn_support_group = createVehicleCrew dyn_support_vic;
                //     dyn_support_group setGroupId [format ["TraTrp %1", 2 +_i]];
                //     player hcSetGroup [dyn_support_group];
                // };

                // sleep 1;
                // if (({alive _x} count (units dyn_repair_group)) <= 0 or !alive dyn_repair_vic or isNull dyn_repair_vic) then {
                //     dyn_repair_vic = createVehicle [dyn_player_repair_vic_type, _playerStart, [], 40, "NONE"];
                //     dyn_repair_vic setVariable ["pl_is_repair_vehicle", true];
                //     dyn_repair_group = createVehicleCrew dyn_repair_vic;
                //     dyn_repair_group setGroupId [format ["GSITrp %1", 3 +_i]];
                //     player hcSetGroup [dyn_repair_group];
                // };
            };
            
            // [getPos _loc, _dir, _endTrg] spawn dyn_ambiance_execute;

            // _friendlyLocs = nearestLocations [getPos player, ["NameVillage", "NameCity", "NameCityCapital"], 2000];
            // {
            //     [objNull, (getPos _x) getPos [150, 0], "n_installation", "CIV", "ColorCivilian", 0.6] call dyn_spawn_intel_markers;
            //     [getPos _x, 0, _endTrg] spawn dyn_civilian_presence;
            // } forEach _friendlyLocs;

            [west, format ["task_%1", _i], ["Offensive", format ["Capture %1", _locationName], ""], getPos _loc, "ASSIGNED", 1, true, "default", false] call BIS_fnc_taskCreate;

            // start ACTION!
            if (_i == 0) then {
                [_loc, _campaignDir, _trg] spawn {
                    params ["_loc", "_campaignDir", "_trg"];

                    // [getPos _loc, _trg] spawn dyn_msr_desolation;

                    _ambiantPos = (getPos player) getPos [750, _campaignDir - 180];
                    // [getPos player, 700, "Assembly Area", "colorBlack"] call dyn_draw_mil_symbol_objectiv_free;

                    // for "_i" from 0 to ([2, 4] call BIS_fnc_randomInt) do {
                    //     [[[[_ambiantPos, 400]], ["water"]] call BIS_fnc_randomPos, 0, _trg, [0, 1] call BIS_fnc_randomInt] spawn dyn_destroyed_mil_vic;
                    // };

                    sleep 10;

                    // playSound "radioina";
                    // [playerSide, "HQ"] sideChat format ["INTRO TEXT BOTTOM TEXT"];


                    // _alliedSupport = selectRandom [1,1,1];

                    // switch (_alliedSupport) do { 
                    //     case 1 : {[_ambiantPos getPos [350, _campaignDir - 180], 10, 300] spawn dyn_allied_arty;}; 
                    //     case 2 : {[getPos _loc] spawn dyn_allied_plane_flyby;};
                    //     case 3:  {[(getPos _loc) getPos [800, _campaignDir]] spawn dyn_allied_heli_flyby;};
                    //     default {  /*...code...*/ }; 
                    // };

                    // [getPos _loc, false] spawn dyn_allied_plane_flyby;


                    dyn_opfor_pow_pos = getPos player;
                };
            };

            if (_i > 0 and !dyn_debug) then {
                sleep 10;
            };

            if !(dyn_no_spawn) then {

                if (_midDefenses) then {

                    _defenseType = selectRandom ["catk", "supply", "recon_convoy", "ambush", "recon"];

                    // debug
                    // _defenseType = "catk";

                    switch (_defenseType) do {
                        case "road" : {[_midPoint, _trg, _dir, true] spawn dyn_road_blocK};
                        case "catk" : {[objNull, getPos player, (getPos _loc) getPos [1000, _campaignDir] , [2, 4] call BIS_fnc_randomInt, [2, 3] call BIS_fnc_randomInt, true] spawn dyn_spawn_atk_simple;};
                        case "supply" : {[objNull, _midPoint, ([3, 6] call BIS_fnc_randomInt)] spawn dyn_spawn_supply_convoy};
                        case "recon_convoy" : {[objNull, _midPoint, ([3, 5] call BIS_fnc_randomInt), dyn_standart_light_amored_vics + dyn_standart_light_armed_transport + dyn_standart_trasnport_vehicles] spawn dyn_spawn_supply_convoy};
                        case "recon" : {[getPos _loc, _trg, _dir, _reveal, dyn_read_terrain] spawn dyn_forward_recon_element};
                        case "ambush" : {[getPos _loc, _trg, _dir, _reveal, dyn_read_terrain] spawn dyn_ambush};
                        case "minefield" : {[_midPoint, 4000, _dir, true] spawn dyn_spawn_mine_field};
                        case "empty" : {};
                        default {}; 
                    };

                    // get retreat units in Pos;
                    if (_i > 0) then {
                        [_midPoint, _dir, 2500] spawn dyn_get_retreat_in_def;
                    };

                    sleep 4;



                    [_midPoint, 2000, [2, 4] call BIS_fnc_randomInt, _trg, _dir] spawn dyn_spawn_forest_patrol;

                    [_midPoint, 2000, 400, _midPoint] spawn dyn_spawn_bridge_defense;

                    [_midPoint, _campaignDir] spawn dyn_spawn_screen;

                    [_midPoint, 1000, [1, 3] call BIS_fnc_randomInt, true] spawn dyn_crossroad_position;

                    [objNull, _midPoint getPos [600, _campaignDir], ([2, 4] call BIS_fnc_randomInt)] spawn dyn_spawn_supply_convoy;

                    [_midPoint, _dir, [2, 3] call BIS_fnc_randomInt] spawn dyn_forest_defence_edge;

                    // [objNull, _midPoint getPos [[100, 300] call BIS_fnc_randomInt, [0, 359] call BIS_fnc_randomInt], "o_mech_inf", "MechInfCoy.", "colorOPFOR", 0.8] call dyn_spawn_intel_markers;
                    // [_midPoint getPos [[100, 300] call BIS_fnc_randomInt], _campaignDir - 180, "G"] call dyn_draw_mil_symbol_screen;
                    [_midPoint, _dir, 400] call dyn_draw_mil_symbol_block;

                    if (_i > 0 ) then {
                        [_trg, getPos _trg, 800, _midPoint, 1] spawn dyn_spawn_side_town_guards;
                    };

                    if (dyn_debug) then {
                        _m = createMarker [str (random 1), _midPoint];
                        _m setMarkerType "mil_marker";
                    };

                    sleep 10;

                } else {

                    if (_i > 0) then {
                        [_midPoint, _dir, 2500] spawn dyn_get_retreat_in_def;
                    };
                };

                if (_outerDefenses) then {

                    // private _defenseType = selectRandom ["minefield", "minefield", "empty", "catk", "supply", "recon", "road", "road", "recon_convoy", "ambush", "ambush", "trench", "trench", "trench", "road"];



                    _reveal = false;
                    private _defenseType = "";
                    if (_i == 0) then {
                        _reveal = true;
                        _defenseType =  selectRandom ["trench", "minefield", "defense", "ambush"];
                        // _defenseType =  selectRandom ["trench", "minefield"];
                    } else {
                        _defenseType = selectRandom ["catk", "supply", "recon_convoy", "ambush", "recon"];
                    };

                    // debug
                    // _defenseType = "ambush";
                    // hint _defenseType;

                    switch (_defenseType) do {
                        case "catk" : {[objNull, getPos player, (getPos _loc) getPos [800, _campaignDir] , [2, 4] call BIS_fnc_randomInt, [2, 3] call BIS_fnc_randomInt, true] spawn dyn_spawn_atk_simple;};
                        case "road" : {[getPos _loc, _trg, _dir, false, _reveal] spawn dyn_road_blocK};
                        case "supply" : {[objNull, (getPos player) getPos [600, _campaignDir - 180], ([3, 5] call BIS_fnc_randomInt)] spawn dyn_spawn_supply_convoy};
                        case "recon" : {[getPos _loc, _trg, _dir, _reveal, dyn_read_terrain] spawn dyn_forward_recon_element};
                        case "ambush" : {[getPos _loc, _trg, _dir, _reveal, dyn_read_terrain] spawn dyn_ambush};
                        case "trench" : {[getPos _loc, _trg, _dir, _reveal, dyn_read_terrain] spawn dyn_trench_line_large};
                        case "ditch" : {[getPos _loc, _trg, _dir, _reveal, dyn_read_terrain] spawn dyn_anti_tank_ditch};
                        case "minefield" : {[(getPos _loc) getPos [[1600, 2000] call BIS_fnc_randomInt, _dir], 2500, _dir, true, [70, 100] call BIS_fnc_randomInt, [6,8] call BIS_fnc_randomInt, _reveal, [30, 90] call BIS_fnc_randomInt, dyn_read_terrain] spawn dyn_spawn_mine_field};
                        case "recon_convoy" : {[objNull, (getPos player) getPos [600, _campaignDir - 180], ([3, 5] call BIS_fnc_randomInt), dyn_standart_light_amored_vics + dyn_standart_trasnport_vehicles] spawn dyn_spawn_supply_convoy};
                        case "defense" : {[_playerStart, getPos _loc, 60] call dyn_defense}; //[300, 500] call BIS_fnc_randomInt
                        case "empty" : {};
                        default {}; 
                    };
                };

                sleep 5; 

                [getPos _trg] call dyn_spawn_furniture;

                _townDefenseGrps = [_trg, _endTrg, _dir] call dyn_town_defense;

                sleep 5;

                [dyn_en_comp#0] call dyn_opfor_change_uniform;
            };

               { 
                    _x addCuratorEditableObjects [allUnits, true]; 
                    _x addCuratorEditableObjects [vehicles, true];  
               } forEach allCurators; 

            sleep 10;

            _garbagePos = getPos _endTrg;

            if !(dyn_debug) then {
                waitUntil {sleep 2; triggerActivated _endTrg or (count (allGroups select {(side (leader _x)) isEqualTo east})) <= 6};
            } else {
                waitUntil {sleep 1; triggerActivated _trg};
            };

            sleep 2;

            if (_i < ((count _locations) - 1)) then {
                _retreatPos = getPos (_locations#(_i + 1));
                _allGrps = (allGroups select {(side _x) == east}) - dyn_opfor_grps;
                [objNull, _retreatPos, _allGrps] spawn dyn_retreat;
            } else {
                {
                    [_x] spawn dyn_opfor_surrender;
                    sleep 2;
                } forEach (allGroups select {(side _x) == east});
            };
            
            

            // [] spawn dyn_garbage_clear;

            [format ["task_%1", _i], "SUCCEEDED", true] call BIS_fnc_taskSetState;

            pl_sorties = pl_sorties + 10;
            // pl_arty_ammo = pl_arty_ammo + 36;
            // {
            //     (vehicle _x) setVehicleAmmo 1;
            // } forEach (units artGrp_1);

            sleep 5;

            [west, format ["task_clear_%1", _i], ["Deffensive", format ["Secure %1 and wait for tasking", _locationName], ""], getPos _loc, "ASSIGNED", 1, true, "wait", false] call BIS_fnc_taskCreate;

            _secureTrg = createTrigger ["EmptyDetector", (getPos _loc), true];
            _secureTrg setTriggerActivation ["EAST", "NOT PRESENT", false];
            _secureTrg setTriggerStatements ["this", " ", " "];
            _secureTrg setTriggerArea [350, 350, _dir, false, 30];
            _secureTrg setTriggerTimeout [10, 20, 30, false];

            if !(dyn_debug) then {
                waitUntil {sleep 2; triggerActivated _secureTrg};
            };
            
            // if !(dyn_debug) then {sleep 240};

            [format ["task_clear_%1", _i], "SUCCEEDED", true] call BIS_fnc_taskSetState;
        };

        hint "VICTORY";
    };
};

sleep 2;

[] call dyn_main_setup;
