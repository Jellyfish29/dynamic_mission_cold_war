dyn_debug = false;
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

dyn_draw_phase_lines = {
    params ["_campaignDir", "_endPos"];

    private _centerPositionsLeft = [];
    private _centerPositionsRight = [];
    private _locations = [player] + dyn_locations;
    private _lastPos = getpos (leader artGrp_1);
    private _lastDir = -1;
    {
        _locPos = getPos _x;

        // _dir = _lastPos getdir _locPos;
        _centerPositionsLeft pushBack (_locPos getpos [3500, _campaignDir + 90]);
        _centerPositionsRight pushBack (_locPos getpos [3500, _campaignDir - 90]);

        _lastPos = _locPos;

    } forEach _locations;

    private _posIdx = 1;
    for "_i" from 0 to (count _centerPositionsRight) - 2 step 1 do {
        _currentPosRight = _centerPositionsRight#_i;
        private _nextPosRight = _centerPositionsRight#(_i+1);
        private _dirRight = _currentPosRight getDir _nextPosRight;

        _distanceRight = _currentPosRight distance2d _nextPosRight;

        _midPointRight = _currentPosRight getPos [_distanceRight / 2, _dirRight];

        _lineMarkerRight = createMarker [format ["Right%1", random 3], _midPointRight];
        _lineMarkerRight setMarkerShape "RECTANGLE";
        _lineMarkerRight setMarkerSize [8, _distanceRight / 2];
        _lineMarkerRight setMarkerDir _dirRight;
        _lineMarkerRight setMarkerBrush "SolidFull";
        _lineMarkerRight setMarkerColor "colorBLACK";

        _currentPosLeft = _centerPositionsLeft#_i;
        _nextPosLeft = _centerPositionsLeft#(_i+1);
        _dirLeft = _currentPosLeft getDir _nextPosLeft;
        _distance = _currentPosLeft distance2d _nextPosLeft;

        _midPointLeft = _currentPosLeft getPos [_distance / 2, _dirLeft];
        _lineMarker = createMarker [format ["left%1", random 3], _midPointLeft];
        _lineMarker setMarkerShape "RECTANGLE";
        _lineMarker setMarkerSize [8, _distance / 2];
        _lineMarker setMarkerDir _dirLeft;
        _lineMarker setMarkerBrush "SolidFull";
        _lineMarker setMarkerColor "colorBLACK";

        if (_i > 0 ) then {

            _plNameMarker = createMarker [format ["left%1", random 3], _midPointLeft];
            _plNameMarker setMarkerType "mil_dot";
            _plNameMarker setMarkerSize [0,0];
            _plNameMarker setMarkerDir _dirLeft;
            _name = (selectRandom dyn_phase_names);
            _plNameMarker setMarkerText _name;
            dyn_phase_names deleteAt (dyn_phase_names find _name);

            _phaseMidDistance = _midPointLeft distance2d _midPointRight;
            _phaseMidDir = _midPointLeft getDir _midPointRight;
            _phaseMidPoint = _midPointLeft getPos [_phaseMidDistance / 2, _phaseMidDir];

            _lineMarkerPhase = createMarker [format ["Right%1", random 3], _phaseMidPoint];
            _lineMarkerPhase setMarkerShape "RECTANGLE";
            _lineMarkerPhase setMarkerSize [4, _phaseMidDistance / 2];
            _lineMarkerPhase setMarkerDir _phaseMidDir;
            _lineMarkerPhase setMarkerBrush "SolidFull";
            _lineMarkerPhase setMarkerColor "colorBLACK";
        };
    };
};


dyn_place_player = {
    params ["_pos", "_dest"];
    private ["_startPos", "_infGroups", "_vehicles", "_roads", "_road", "_roadsPos", "_dir", "_roadPos"];
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
    

    _road = [_pos, 300] call BIS_fnc_nearestRoad;
    _usedRoads = [];
    // reverse _vehicles;

    _roadsPos = [];
    _roadBlackList = [];
    for "_i" from 0 to (count _vehicles) - 1 step 1 do {
        // _road = ((roadsConnectedTo _road) - [_road]) select 0;
        // if !(_road in _roadBlackList) then {
        //     _roadBlackList pushBack _road;
        //     _roadPos = getPos _road;
        //     _near = roadsConnectedTo _road;
        //     _near = [_near, [], {(getPos _x) distance2D _dest}, "DESCEND"] call BIS_fnc_sortBy;
        //     _dir = (getPos (_near#0)) getDir (getPos _road);
        //     _roadsPos pushBack [_roadPos, _dir];
        // } else {

        // };
        _road = ([roadsConnectedTo _road, [], {(getpos _x) distance2D _dest}, "DESCEND"] call BIS_fnc_sortBy)#0;

        if (isNil "_road" or isNull _road) then {
            _roadPos = [[[_pos, 150]], ["water"]] call BIS_fnc_randomPos;
            _roadPos = _roadPos findEmptyPosition [0, 50, typeOf (_vehicles#_i)];
            _dir = _pos getDir _dest;
        } else {
            _roadPos = getPos _road;
            _info = getRoadInfo _road;    
            _endings = [_info#6, _info#7];
            _endings = [_endings, [], {_x distance2D _dest}, "ASCEND"] call BIS_fnc_sortBy;
            _dir = (_endings#1) getDir (_endings#0);
        };

        if !((_vehicles#_i) setVehiclePosition [_roadPos, [], 0, "NONE"]) then {
            _roadPos = [[[_pos, 150]], ["water"]] call BIS_fnc_randomPos;
            _roadPos = _roadPos findEmptyPosition [0, 50, typeOf (_vehicles#_i)];
            _dir = _pos getDir _dest;
            (_vehicles#_i) setVehiclePosition [_roadPos, [], 0, "NONE"];
        };

        (_vehicles#_i) setdir _dir;

        sleep 0.1;

    };

    // _roadsPos = [_roadsPos, [], {(_x#0) distance2D _dest}, "ASCEND"] call BIS_fnc_sortBy;

    // for "_i" from 0 to (count _vehicles) - 1 step 1 do {
    //     (_vehicles#_i) setPos ((_roadsPos#_i)#0);
    //     (_vehicles#_i) setdir ((_roadsPos#_i)#1);
    // };
};

dyn_customice_playerside = {

    {
        // _x addGoggles (selectRandom ["gm_headgear_foliage_summer_forest_01", "gm_headgear_foliage_summer_forest_02", "gm_headgear_foliage_summer_forest_03", "gm_headgear_foliage_summer_forest_04"]);
        _faceunit = (face _x + (selectRandom ["_cfaces_BWTarn", "_cfaces_BWStripes"]));
        _x setVariable ["JgKp_Face", _faceunit, true];
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
    } forEach ((units artGrp_1) - [_artyLeader] + (units artGrp_2));

    _batteryPos = (getPos player) getPos [2000, _rearDir];
    _batteryPos = ((selectBestPlaces [_batteryPos, 500, "2*meadow", 95, 1])#0)#0;
    // _batteryPos = _batteryPos findEmptyPosition [0, 500, typeOf (vehicle _artyLeader)];

    (vehicle _artyLeader) setPos _batteryPos;

    {
        (vehicle _x) setDir (getDir vehicle player);
        _x disableAI "PATH";
    } forEach ((units artGrp_1) + (units artGrp_2));

    {
        _pos1 = getPosWorldVisual (vehicle _artyLeader);
        _pos2 = _x getVariable "dyn_rel_pos";
        _setPos = [(_pos1 select 0) + (_pos2 select 0), (_pos1 select 1) + (_pos2 select 1)];
        (vehicle _x) setPos _setPos;
    } forEach ((units artGrp_1) - [_artyLeader] + (units artGrp_2));

    _aaPOs = _batteryPos getPos [050, 90];
    dyn_aa_vic setPos _aaPOs;
    // [dyn_aa_vic_grp] call dyn_hide_group_icon;
    // [artGrp_1] call dyn_hide_group_icon;

    // [objNull, getPos (leader artGrp_1), "b_art", "ArtCoy", "colorBLUFOR", 0.6] call dyn_spawn_intel_markers;
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
        dyn_opfor_grps pushBack _grp;

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
};


dyn_main_setup = {
    private ["_startPos", "_startRoad", "_campaignDir", "_endPos"];


    dyn_locations = [];

    private _dummygrp = createGroup [civilian, true];

    while {(count dyn_locations) < 3} do {

        _startPair = selectRandom [["dyn_start_zone_1", "dyn_start_zone_2"], ["dyn_start_zone_2", "dyn_start_zone_1"], ["dyn_start_zone_4", "dyn_start_zone_3"], ["dyn_start_zone_3", "dyn_start_zone_4"]];// ["dyn_start_zone_5", "dyn_start_zone_6"], ["dyn_start_zone_6", "dyn_start_zone_5"], ["dyn_start_zone_8", "dyn_start_zone_7"], ["dyn_start_zone_7", "dyn_start_zone_8"]];

        _startPos = [[_startPair#0], ["water"]] call BIS_fnc_randomPos;

        _startRoad = [_startPos, 400, ["TRAIL", "TRACK", "HIDE"]] call dyn_nearestRoad;
        if (isNull _startRoad) then {
            _startRoad = [_startPos, 2000] call dyn_nearestRoad;
        };


        _endPos = [[_startPair#1], ["water"]] call BIS_fnc_randomPos;

        // _m = createMarker [format ["team%1", random 1], _endPos];
        // _m setMarkerType "mil_marker";
        // _m setMarkerText "End";


        _intervals = ((getpos _startRoad) distance2d _endPos) / 8;
        _campaignDir = _endPos getDir (getpos _startRoad);

        _dummy = _dummygrp createUnit ["C_man_polo_1_F", (getPos _startRoad) getPos [600, _campaignDir - 180], [], 0, "NONE"];
        _dummy hideObjectGlobal true;
        dyn_locations = [_dummy];

        _offsetPos = (getpos _startRoad) getPos [600, _campaignDir];

        for "_i" from 0 to 8 do {
            _pos = [(_intervals * _i) * (sin (_campaignDir - 180)), (_intervals * _i) * (cos (_campaignDir - 180)), 0] vectorAdd _offsetPos;
            _loc = nearestLocation [_pos, "NameVillage"];
            if ((_pos distance2D (getPos _loc)) < 2500) then {
                _valid = {
                    if (((getPos _x) distance2D (getPos _loc)) < 4000) exitWith {false};
                    true 
                } forEach dyn_locations;
                if (_valid) then {dyn_locations pushBackUnique _loc};
            };
            _loc = nearestLocation [_pos, "NameCity"];
            if ((_pos distance2D (getPos _loc)) < 2500) then {
                _valid = {
                    if (((getPos _x) distance2D (getPos _loc)) < 4000) exitWith {false};
                    true 
                } forEach dyn_locations;
                if (_valid) then {dyn_locations pushBackUnique _loc};
            };
            _loc = nearestLocation [_pos, "NameCityCapital"];
            if ((_pos distance2D (getPos _loc)) < 2500) then {
                _valid = {
                    if (((getPos _x) distance2D (getPos _loc)) < 4000) exitWith {false};
                    true 
                } forEach dyn_locations;
                if (_valid) then {dyn_locations pushBackUnique _loc};
            };
            // debug
            // _m = createMarker [str (random 1), _pos];
            // _m setMarkerText str _i;
            // _m setMarkerType "mil_dot";
        };

        dyn_locations deleteAt 0;
        deleteVehicle _dummy;
    };

        // debug
        // if (dyn_debug) then {
        // };
    [getPos _startRoad, (getPos _startRoad) getPos [1000, _campaignDir - 180]] call dyn_place_player;

    // _i = 0;
    // {
    //     _m = createMarker [str (random 1), getPos _x];
    //     _m setMarkerText str _i;
    //     _m setMarkerType "mil_circle";
    //     _i = _i + 1;
    // } forEach dyn_locations;


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

    [(getpos (dyn_locations#0)) getdir player] call dyn_place_arty;

    [_campaignDir, _endPos] spawn dyn_draw_phase_lines;

    [dyn_locations, getpos _startRoad, _campaignDir] spawn {
        params ["_locations", "_playerStart", "_campaignDir"];
        private ["_midPoint"];


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
            if (_i > 0) then {
                _pos = getPos (_locations#(_i - 1));
                _dir = (getPos _loc) getDir _pos;
                if (((getPos _loc) distance2D _pos) > 1600) then {
                    _outerDefenses = true;
                };

                // between town Defenses
                if (((getPos _loc) distance2D _pos) > 4500) then {
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


            // if (_i + 1 < (count _locations)) then {
            //     _mP1 = getPos (_locations#(_i + 1)) getPos [200, 0];
            //     [objNull, _mP1 , "o_hq", "RegCP.", "colorOPFOR", 0.8] call dyn_spawn_intel_markers;
            //     [objNull, _mP1, "colorOpfor", 1000] call dyn_spawn_intel_markers_area;
            // };
            // if (_i + 2 < (count _locations)) then {
            //     _mP2 = getPos (_locations#(_i + 2)) getPos [200, 0];
            //     [objNull, _mP2, "o_art", "ArtReg.", "colorOPFOR", 0.8] call dyn_spawn_intel_markers;
            //     [objNull, _mP2, "colorOpfor", 1600] call dyn_spawn_intel_markers_area;
            //     _artyPos2 = getPos (_locations#(_i + 2)) getPos [300, 0];
            //     [_artyPos2, _campaignDir] call dyn_place_opfor_arty;
            //     _artyPos3 = getPos (_locations#(_i + 2)) getPos [300, 180];
            //     [_artyPos3, _campaignDir] call dyn_place_opfor_rocket_arty;
            //     _artyPos4 = getPos (_locations#(_i + 2)) getPos [1000, _campaignDir - 180];
            //     [_artyPos4, _campaignDir] call dyn_palace_opfor_balistic_arty;
            // } else {
            _lastPos =  getPos _loc;
            // [objNull, _lastPos, "o_art", "ArtReg.", "colorOPFOR", 0.8] call dyn_spawn_intel_markers;
            // [objNull, _lastPos, "colorOpfor", 1600] call dyn_spawn_intel_markers_area;
            _artyPos2 = (_lastPos getpos [5500, _campaignDir - 180]) getPos [300, 0];
            [_artyPos2, _campaignDir] call dyn_place_opfor_arty;
            _artyPos3 = (_lastPos getpos [5500, _campaignDir - 180]) getPos [300, 180];
            [_artyPos3, _campaignDir] call dyn_place_opfor_rocket_arty;
            _artyPos4 = (_lastPos getpos [5500, _campaignDir - 180]) getPos [1000, _campaignDir - 180];
            [_artyPos4, _campaignDir] call dyn_palace_opfor_balistic_arty;
            // };  
            
            _defenseAllowed = true;
            if (_defenseAllowed) then {       
                dyn_defense_active = false;

                _dyn_defense_atkPos = getPos player;
                private _waitTime = 500;
                if (_i > 0) then {
                    _waitTime = 700;
                    _dyn_defense_atkPos = getPos (_locations#(_i - 1))
                };
                [_dyn_defense_atkPos, getPos _loc, _waitTime] spawn dyn_defense;
                sleep 5;

                waitUntil {!(dyn_defense_active)};

                sleep 5;
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
            };
            
            // [getPos _loc, _dir, _endTrg] spawn dyn_ambiance_execute;

            [west, format ["task_%1", _i], ["Offensive", format ["Capture %1", _locationName], ""], getPos _loc, "ASSIGNED", 1, true, "attack", false] call BIS_fnc_taskCreate;

            if (_i > 0 and !dyn_debug) then {
                sleep 120;
            };


            _townDefenseGrps = [_trg, _endTrg, _dir] call dyn_town_defense;

            if (_midDefenses) then {

                _defenseType = selectRandom ["minefield", "recon", "road"];

                // debug
                // _defenseType = "ambush";

                switch (_defenseType) do {
                    case "road" : {[getPos _loc, _trg, _dir] spawn dyn_road_blocK};
                    case "mobileTank" : {[_midPoint, _trg, _dir, true] spawn dyn_mobile_armor_defense};
                    case "recon" : {[_midPoint, _trg, _dir] spawn dyn_recon_convoy};
                    case "minefield" : {[_midPoint, 2500, _dir, true] spawn dyn_spawn_mine_field};
                    default {}; 
                };

                [_midPoint, 2000, [2, 4] call BIS_fnc_randomInt, _trg, _dir] spawn dyn_spawn_forest_patrol;

                [_midPoint, 2000, 400, _midPoint] spawn dyn_spawn_bridge_defense;

                [_endTrg, _midPoint, 1500, _midPoint] spawn dyn_spawn_side_town_guards;

                [_midPoint, _dir, [1, 3] call BIS_fnc_randomInt] spawn dyn_forest_defence_edge;

                [objNull, _midPoint getPos [[100, 300] call BIS_fnc_randomInt, [0, 359] call BIS_fnc_randomInt], "o_mech_inf", "MechInfCoy.", "colorOPFOR", 0.8] call dyn_spawn_intel_markers;

                if (dyn_debug) then {
                    _m = createMarker [str (random 1), _midPoint];
                    _m setMarkerType "mil_marker";
                };
            };

            if (_outerDefenses) then {

                _defenseType = selectRandom ["mobileTank", "recon", "recon", "minefield", "road"];

                // debug
                // _defenseType = "road";

                switch (_defenseType) do { 
                    case "road" : {[getPos _loc, _trg, _dir] spawn dyn_road_blocK};
                    case "mobileTank" : {[getPos _loc, _trg, _dir] spawn dyn_mobile_armor_defense};
                    case "recon" : {[getPos _loc, _trg, _dir] spawn dyn_recon_convoy};
                    case "minefield" : {[(getPos _loc) getPos [[1300, 1700] call BIS_fnc_randomInt, _dir], 2000, _dir, true] spawn dyn_spawn_mine_field};
                    case "empty" : {};
                    default {}; 
                };
            };

            sleep 5;

            [dyn_en_comp#0] call dyn_opfor_change_uniform;

               { 
                    _x addCuratorEditableObjects [allUnits, true]; 
                    _x addCuratorEditableObjects [vehicles, true];  
               } forEach allCurators; 

            sleep 10;
            if (_i < ((count _locations) - 1)) then {
                _retreatPos = getPos (_locations#(_i + 1));
                _allGrps = (allGroups select {(side _x) == east}) - dyn_opfor_grps;
                [_endTrg, _retreatPos, _allGrps] spawn dyn_retreat;
            } else {
                {
                    [_x] spawn dyn_opfor_surrender;
                    sleep 2;
                } forEach (allGroups select {(side _x) == east});
            };

            _garbagePos = getPos _endTrg;

            waitUntil {sleep 2; triggerActivated _endTrg or (count (allGroups select {(side (leader _x)) isEqualTo east})) <= 6};

            // waitUntil {sleep 1; triggerActivated _trg};
            
            {
                deleteMarker _x;
            } forEach dyn_intel_markers;

            [] spawn dyn_garbage_clear;

            [format ["task_%1", _i], "SUCCEEDED", true] call BIS_fnc_taskSetState;

            sleep 5;

            [west, format ["task_clear_%1", _i], ["Deffensive", format ["Secure %1 and wait for tasking", _locationName], ""], getPos _loc, "ASSIGNED", 1, true, "wait", false] call BIS_fnc_taskCreate;
            
            if !(dyn_debug) then {sleep 240};

            [format ["task_clear_%1", _i], "SUCCEEDED", true] call BIS_fnc_taskSetState;
        };

        hint "VICTORY";
    };
};

[] call dyn_main_setup;
