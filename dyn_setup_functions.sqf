dyn_debug = false;

addMissionEventHandler ["TeamSwitch", {
    params ["_previousUnit", "_newUnit"];
    _hcc = allMissionObjects "HighCommand" select 0;
    _hcs = allMissionObjects "HighCommandSubordinate" select 0;
    deleteVehicle _hcc;
    // deleteVehicle _previousUnit;
    createGroup (sideLogic) createUnit ["HighCommand", [0, 0, 0], [], 0, "NONE"];
    _hcc = allMissionObjects "HighCommand" select 0;
    _newUnit synchronizeObjectsAdd [_hcc];
    _hcc synchronizeObjectsAdd [_hcs];
    [] call dyn_add_all_groups;
}];

dyn_add_all_groups = {
    {
        _x setVariable ["pl_show_info", true];
        player hcSetGroup [_x];
    } forEach (allGroups select {side (leader _x) == playerSide});
};


dyn_create_markers = {
    params ["_pos", "_dir", "_trg", "_campaignDir", "_playerPos"];

    _pos = [250 * (sin 0), 250 * (cos 0), 0] vectorAdd _pos;

    _marker1 = createMarker [str _pos, _pos];
    _marker1 setMarkerColor "colorOPFOR";
    _comp = selectRandom [["b_mech_inf", "232. MechInfBtl"], ["b_inf", "16. GdsInfBtl"], ["b_motor_inf", "45. MotInfBtl"], ["b_motor_inf", "101. MotInfBtl"], ["b_armor", "3. ArmBtl"]];
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
    _marker7 setMarkerType "flag_USA";

    _arrowPos = [(_playerPos distance2d _pos) / 2 * (sin (_playerPos getDir _pos)), (_playerPos distance2d _pos) / 2 * (cos (_playerPos getDir _pos)), 0] vectorAdd _playerPos;
    _marker8 = createMarker [format ["arrow%1", _pos], _arrowPos];
    _marker8 setMarkerType "cwr3_marker_arrow";
    _marker8 setMarkerSize [1.5, 1.5];
    _marker8 setMarkerColor "colorBLUFOR";
    _marker8 setMarkerDir (_playerPos getDir _pos);
    _marker8 setMarkerAlpha 0;

    _teamPos = [2200 * (sin _dir), 2200 * (cos _dir), 0] vectorAdd _rightPos;
    _marker9 = createMarker [format ["team%1", _pos], _teamPos];
    _marker9 setMarkerType "b_mech_inf";
    _marker9 setMarkerSize [0.5, 0.5];
    // _marker9 setMarkerDir _dir;
    _marker9 setMarkerText "Team YANKEE";

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

    _leftPos = [2000 * (sin (_dir - 90)), 2000 * (cos (_dir - 90)), 0] vectorAdd _centerPos;
    _rightPos = [2000 * (sin (_dir + 90)), 2000 * (cos (_dir + 90)), 0] vectorAdd _centerPos;
    _leftPosA = [2500 * (sin (_dir - 90)), 2500 * (cos (_dir - 90)), 0] vectorAdd _centerPos;
    _rightPosA = [2500 * (sin (_dir + 90)), 2500 * (cos (_dir + 90)), 0] vectorAdd _centerPos;

    private _ambGroup = createGroup east;
    for "_i" from 0 to 6 do {
        _nPos = [[[selectRandom [_leftPos, _rightPos], 400]], []] call BIS_fnc_randomPos;
        _unit = _ambGroup createUnit ["ModuleTracers_F", _nPos, [],0 , ""];
        sleep 2;
    };

    while {!(triggerActivated _trg)} do {
        _amount = [2, 4] call BIS_fnc_randomInt;
        for "_i" from 0 to _amount do {
            _artyPos = [[[selectRandom [_leftPosA, _rightPosA], 200]], []] call BIS_fnc_randomPos;
            _support = _ambGroup createUnit ["ModuleOrdnance_F", _artyPos, [],0 , ""];
            _support setVariable ["type", "ModuleOrdnanceHowitzer_F_Ammo"];
            sleep ([1, 4] call BIS_fnc_randomInt);
        };
        sleep ([40, 120] call BIS_fnc_randomInt);
    };

    {
        deleteVehicle _x;
    } forEach (units _ambGroup);
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
    _startPos = getPos player;
    _infGroups = [];
    _vehicles = nearestObjects [_startPos,["LandVehicle"],300];
    {
        if(((player distance2D (leader _x)) < 300) and !(vehicle (leader _x) in _vehicles)) then {
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

dyn_main_setup = {

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
    _startPairs = [["start_0", "obj_0"], ["start_1", "obj_1"], ["start_2", "obj_2"], ["start_3", "obj_3"], ["start_4", "obj_4"], ["start_5", "obj_5"], ["start_6", "obj_6"], ["start_7", "obj_7"], ["start_8", "obj_8"], ["start_9", "obj_9"], ["start_10", "obj_10"]];
    _startPair = selectRandom _startPairs;

    // debug override
    // _startPair = ["start_0", "obj_0"];

    _playerStart = getMarkerPos (_startPair#0);
    _startLoc = nearestLocation [getMarkerPos (_startPair#1), ""];
    _startPos = getPos _startLoc;
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
        } forEach _startPairs
    };


    _intervals = 2000;
    _campaignDir = _campaignDir + ([-20, 20] call BIS_fnc_randomInt);
    _offsetPos = [1500 * (sin (_campaignDir - 180)), 1500 * (cos (_campaignDir - 180)), 0] vectorAdd _startPos;
    for "_i" from 0 to 8 do {
        _pos = [(_intervals * _i) * (sin (_campaignDir - 180)), (_intervals * _i) * (cos (_campaignDir - 180)), 0] vectorAdd _offsetPos;
        _loc = nearestLocation [_pos, "NameVillage"];
        if ((_pos distance2D (getPos _loc)) < 2500) then {
            _valid = {
                if (((getPos _x) distance2D (getPos _loc)) < 3000) exitWith {false};
                true 
            } forEach dyn_locations;
            if (_valid) then {dyn_locations pushBackUnique _loc};
        };
        _loc = nearestLocation [_pos, "NameCity"];
        if ((_pos distance2D (getPos _loc)) < 2500) then {
            _valid = {
                if (((getPos _x) distance2D (getPos _loc)) < 3000) exitWith {false};
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

    [getPos _aoStart, _startPos] call dyn_place_player;

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
                if (((getPos _loc) distance2D _pos) > 4000) then {
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
            
            dyn_defense_active = false;

            _dyn_defense_atkPos = getPos player;
            _startDefense = true;
            
            if (((random 1) > 0.35 and (_dyn_defense_atkPos distance2D (getPos _loc)) > 3000 and _i > 0) or _startDefense) then {
                _waitTime = 900;
                if (_startDefense) then {_waitTime = 360};
                [_dyn_defense_atkPos, getPos _loc, _waitTime] spawn dyn_defense;
                sleep 5;
                _defDir = _dyn_defense_atkPos getDir (getPos _loc);
                _linePos = [300 * (sin _defDir), 300 * (cos _defDir), 0] vectorAdd _dyn_defense_atkPos;
                [west, format ["defTask_%1", _i], ["Deffensive", "Take and Hold Position", ""], _linePos, "ASSIGNED", 1, true, "defend", false] call BIS_fnc_taskCreate;

                waitUntil {!(dyn_defense_active)};

                [format ["defTask_%1", _i], "SUCCEEDED", true] call BIS_fnc_taskSetState;
                sleep 10;
            };

            _trg = createTrigger ["EmptyDetector", (getPos _loc), true];
            _trg setTriggerActivation ["WEST", "PRESENT", false];
            _trg setTriggerStatements ["this", " ", " "];
            _trg setTriggerArea [400, 400, _dir, false];

            _endTrg = createTrigger ["EmptyDetector", (getPos _loc), true];
            _endTrg setTriggerActivation ["WEST SEIZED", "PRESENT", false];
            _endTrg setTriggerStatements ["this", " ", " "];
            _endTrg setTriggerArea [250, 250, _dir, false];
            _endTrg setTriggerTimeout [120, 180, 240, false];

            if (_i > 0) then {
                [getPos _loc, _dir, _endTrg, _campaignDir, getPos (_locations#(_i - 1))] spawn dyn_create_markers;
                _dyn_defense_atkPos = getPos (_locations#(_i - 1));

                // Supply Reinforcements
                if (({alive _x} count (units dyn_support_group)) <= 0 or !alive dyn_support_vic or isNull dyn_repair_vic) then {
                    dyn_support_vic = createVehicle ["cwr3_b_m939", _playerStart, [], 40, "NONE"];
                    dyn_support_group = createVehicleCrew dyn_support_vic;
                    dyn_support_group setGroupId [format ["Echo %1", 2 +_i]];
                    player hcSetGroup [dyn_support_group];
                };

                sleep 1;
                if (({alive _x} count (units dyn_repair_group)) <= 0 or !alive dyn_repair_vic or isNull dyn_repair_vic) then {
                    dyn_repair_vic = createVehicle ["cwr3_b_m939_repair", _playerStart, [], 40, "NONE"];
                    dyn_repair_group = createVehicleCrew dyn_repair_vic;
                    dyn_repair_group setGroupId [format ["Echo %1", 3 +_i]];
                    player hcSetGroup [dyn_repair_group];
                };
            }
            else
            {
                [getPos _loc, _dir, _endTrg, _campaignDir, getPos player] spawn dyn_create_markers;
                // if ((random 1) > 0.35) then {_startDefense = true};
            };
            [getPos _loc, _dir, _endTrg] spawn dyn_ambiance;

            [west, format ["task_%1", _i], ["Offensive", format ["Capture %1", _locationName], ""], getPos _loc, "ASSIGNED", 1, true, "attack", false] call BIS_fnc_taskCreate;
            _townDefenseGrps = [_trg] call dyn_town_defense;

            if (_midDefenses) then {

                _defenseType = selectRandom ["line", "point", "mobileTank", "roadem", "recon"];

                // debug
                // _defenseType = "mobileTank";

                switch (_defenseType) do { 
                    case "line" : {[_midPoint, _trg, _dir, true] call dyn_defense_line}; 
                    case "point" : {[_midPoint, _trg, _dir, true] call dyn_strong_point_defence};
                    case "mobileTank" : {[_midPoint, _trg, _dir, true] call dyn_mobile_armor_defense};
                    case "roadem" : {[_midPoint, _trg, _dir] call dyn_road_emplacemnets};
                    case "recon" : {[_midPoint, _trg, _dir] call dyn_recon_convoy};
                    default {[_midPoint, _trg, _dir, true] call dyn_defense_line}; 
                };

                if (dyn_debug) then {
                    _m = createMarker [str (random 1), _midPoint];
                    _m setMarkerType "mil_marker";
                };
            };

            if (_outerDefenses) then {

                _defenseType = selectRandom ["line", "mobileTank", "recon"];

                // debug
                // _defenseType = "recon";

                switch (_defenseType) do { 
                    case "line" : {[getPos _loc, _trg, _dir] call dyn_defense_line}; 
                    // case "point" : {[getPos _loc, _trg, _dir] call dyn_strong_point_defence};
                    case "mobileTank" : {[getPos _loc, _trg, _dir] call dyn_mobile_armor_defense};
                    // case "roadem" : {[getPos _loc, _trg, _dir] call dyn_road_emplacemnets};
                    case "recon" : {[getPos _loc, _trg, _dir] call dyn_recon_convoy};
                    case "empty" : {};
                    default {[getPos _loc, _trg, _dir] call dyn_defense_line}; 
                };
            };

            sleep 5;

               { 
                    _x addCuratorEditableObjects [allUnits, true]; 
                    _x addCuratorEditableObjects [vehicles, true];  
               } forEach allCurators; 

            sleep 10;
            if (_i < ((count _locations) - 1)) then {
                if ((random 1) > 0.5) then {
                    // [_endTrg, getPos (_locations#_i) , getPos (_locations#(_i + 1)), 5, 3, 4, false, dyn_standart_combat_vehicles, 800] spawn dyn_spawn_counter_attack;
                    // [_endTrg, (allGroups select {side _x == east})] spawn dyn_attack_nearest_enemy;
                    _retreatPos = getPos (_locations#(_i + 1));
                    [_endTrg, _retreatPos, _townDefenseGrps, false] spawn dyn_retreat;
                }
                else
                {
                    _retreatPos = getPos (_locations#(_i + 1));
                    [_endTrg, _retreatPos, _townDefenseGrps] spawn dyn_retreat;
                };
            };

            _garbagePos = getPos _endTrg;

            // sleep 10;

            // {
            //     if (((leader _x) distance2D (getPos _trg)) > 3500) then {
            //         [objNull, getPos _endTrg, [_x]] spawn dyn_retreat;
            //     };
            // } forEach dyn_all_side_town_guards;

            
            // {
            //     if (((leader _x) distance2D (getPos _trg)) > 3500) then {
            //         [objNull, getPos _endTrg, [_x]] spawn dyn_retreat;
            //     };
            // } forEach dyn_all_bridge_guards;

            if !(dyn_debug) then {
                waitUntil {sleep 1; triggerActivated _endTrg};
            }
            else
            {
                waitUntil {sleep 1; triggerActivated _trg};
            };

            [] spawn dyn_garbage_clear;

            [format ["task_%1", _i], "SUCCEEDED", true] call BIS_fnc_taskSetState;
            if !(dyn_debug) then {sleep 60};
        };
    };
};

[] call dyn_main_setup;

