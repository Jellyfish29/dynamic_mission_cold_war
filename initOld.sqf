
player addRating 99999999;


dyn_valid_cover = ["TREE", "SMALL TREE", "BUSH", "FOREST BORDER", "FOREST TRIANGLE", "FOREST SQUARE", "CHAPEL", "CROSS", "FOUNTAIN", "QUAY", "FENCE", "WALL", "HIDE", "BUSSTOP", "FOREST", "TRANSMITTER", "STACK", "RUIN", "TOURISM", "WATERTOWER", "ROCK", "ROCKS", "POWER LINES", "POWERSOLAR", "POWERWAVE", "POWERWIND", "SHIPWRECK"];
dyn_covers = [];

dyn_find_cover = {
    params ["_unit", "_watchDir", "_radius", "_moveBehind"];

    _covers = nearestTerrainObjects [getPos _unit, dyn_valid_cover, _radius, true, true];
    // _unit enableAI "AUTOCOMBAT";
    _watchPos = [1000*(sin _watchDir), 1000*(cos _watchDir), 0] vectorAdd (getPos _unit);
    _unit setUnitPos "AUTO";
    if ((count _covers) > 0) then {
        {
            if !(_x in dyn_covers) exitWith {
                dyn_covers pushBack _x;
                _unit doMove (getPos _x);
                waitUntil {sleep 0.1; (unitReady _unit) or (!alive _unit)};
                _unit setUnitPos "MIDDLE";
                sleep 1;
                if (_moveBehind) then {
                    _moveDir = _watchDir - 180;
                    _coverPos =  [2*(sin _moveDir), 2*(cos _moveDir), 0] vectorAdd (getPos _unit);
                    _unit doMove _coverPos;
                    sleep 1;
                    waitUntil {sleep 0.1; (unitReady _unit) or (!alive _unit)};
                    doStop _unit;
                    _unit doWatch _watchPos;
                _unit disableAI "PATH";
                }
                else
                {
                    doStop _unit;
                    _unit doWatch _watchPos;
                };
            };
        } forEach _covers;
        if ((unitPos _unit) == "Auto") then {
            _unit setUnitPos "DOWN";
            doStop _unit;
            _unit doWatch _watchPos;
            _unit disableAI "PATH";
        };
    }
    else
    {
        _unit setUnitPos "DOWN";
        if (_moveBehind) then {
            sleep 2;
            _checkPos = [15*(sin _watchDir), 15*(cos _watchDir), 0.25] vectorAdd (getPosASL _unit);

            // _helper = createVehicle ["Sign_Sphere25cm_F", _checkPos, [], 0, "none"];
            // _helper setObjectTexture [0,'#(argb,8,8,3)color(1,0,1,1)'];
            // _helper setposASL _checkPos;
            // _cansee = [_helper, "VIEW"] checkVisibility [(eyePos _unit), _checkPos];

            _cansee = [objNull, "VIEW"] checkVisibility [(eyePos _unit), _checkPos];
            // _unit sideChat str _cansee;
            if (_cansee < 0.6) then {
                _unit setUnitPos "MIDDLE";
            };
        };
        doStop _unit;
        _unit doWatch _watchPos;
        _unit disableAI "PATH";
    };
};


dyn_garrison_building = {
    params ["_building", "_grp", "_dir"];
    private ["_validPos", "_allPos", "_bPos", "_units", "_watchPos", "_pos", "_unit"];
    _validPos = [];
    _allPos = [];
    _bPos = [_building] call BIS_fnc_buildingPositions;
    _units = units _grp;
    {
        _allPos pushBack _x;
        _watchPos = [10*(sin _dir), 10*(cos _dir), 1.7] vectorAdd _x;
        _standingPos = [0, 0, 1.7] vectorAdd _x;
        _standingPos = ATLToASL _standingPos;
        _watchPos = ATLToASL _watchPos;

        // _helper = createVehicle ["Sign_Sphere25cm_F", _x, [], 0, "none"];
        // _helper setObjectTexture [0,'#(argb,8,8,3)color(1,0,1,1)'];
        // _helper setposASL _standingPos;

        _cansee = [objNull, "VIEW"] checkVisibility [_standingPos, _watchPos];
        if (_cansee == 1) then {
            _validPos pushBack _x;
        };
    } forEach _bPos;

    _watchPos = [500 * (sin _dir), 500 * (cos _dir), 0] vectorAdd (getPos _building);
    _validPos = [_validPos, [], {_x distance2D _watchPos}, "ASCEND"] call BIS_fnc_sortBy;
    _allPos = _allPos - _validPos;
    _allPos = [_allPos, [], {_x distance2D _watchPos}, "ASCEND"] call BIS_fnc_sortBy;

    for "_i" from 0 to (count _units) - 1 step 1 do {

        if (_i < (count _validPos)) then {
            _pos = _validPos#_i;
            _unit = _units#_i;
        }
        else
        {
            _pos = _allPos#_i;
            _unit = _units#_i;
        };
        _pos = ATLToASL _pos;
        private _unitPos = "UP";
        _checkPos = [7*(sin _dir), 7*(cos _dir), 1.7] vectorAdd _pos;
        _crouchPos = [0, 0, 0.6] vectorAdd _pos;
        if (([objNull, "VIEW"] checkVisibility [_crouchPos, _checkPos]) == 1) then {
            _unitPos = "MIDDLE";
        };
        if (([objNull, "VIEW"] checkVisibility [_pos, _checkPos]) == 1) then {
            _unitPos = "DOWN";
        };

        _pos = ASLToATL _pos;

        _unit setPos _pos;
        _unit doWatch _watchPos;
        doStop _unit;
        _unit setUnitPos _unitPos;
        _unit disableAI "PATH";
    };
};



dyn_defense_line = {
    params ["_locPos", "_townTrg"];
    private ["_aoPos", "_objs", "_objAmount", "_road", "_dir", "_patrollPos", "_rearPos", "_grps"];

    _defPos = [1300 * (sin _dir), 1300 * (cos _dir), 0] vectorAdd _locPos;
    _road = [_defPos, 200, ["TRAIL"]] call BIS_fnc_nearestRoad;
    if !(isNull _road) then {_defPos = getPos _road};
    _aoPos = createTrigger ["EmptyDetector", _defPos, true];
    _aoPos setTriggerActivation ["WEST", "PRESENT", false];
    _aoPos setTriggerStatements ["this", " ", " "];
    _aoPos setTriggerArea [1000, 65, _dir, true];

    _objs = [];
    _objAmount = [3, 5] call BIS_fnc_randomInt;
    _dir = 360 + ((triggerArea _aoPos)#2);
    _patrollPos = [];
    _grps = [];

    // create Roadblock
    if !(isNull _road) then {
        _roadDir = getPos ((roadsConnectedTo _road) select 0) getDir (getPos _road);
        [getPos _road, sideEmpty, (configFile >> "CfgGroups" >> "Empty" >> "military" >> "RoadBlocks" >> "gm_barrier_light"),[],[],[],[],[], _roadDir] call BIS_fnc_spawnGroup;
    };
    
    // create Positions
    for "_i" from 0 to _objAmount - 1 do {
        _t = createTrigger ["EmptyDetector", [0,0,0]];
        _t setTriggerArea [50, 50, 45, false];
        _objs pushBack _t;
    };

    // Spawn Groups at Position
    {
        _pos = [[_aoPos], [(_objs#0), (_objs#1), (_objs#2), "water"]] call BIS_fnc_randomPos;
        _pos = getPos ((nearestTerrainObjects [_pos, ["TREE", "FOREST BORDER", "FOREST TRIANGLE", "FOREST SQUARE"], 300, true, true]) select 0);
        _patrollPos pushBack _pos;
        // [_pos, sideEmpty, (configFile >> "CfgGroups" >> "Empty" >> "military" >> "gm_bunkers" >> "gm_bunker_small")] call BIS_fnc_spawnGroup;
        _comp = selectRandom ["land_gm_camonet_01_east", "land_gm_camonet_02_east"];
        _fort = _comp createVehicle _pos;
        _fort setVectorUp surfaceNormal position _fort;
        _fort setDir _dir;

        // _grp = [_pos, west, (configFile >> "CfgGroups" >> "West" >> "BLU_F" >> "Infantry" >> "BUS_InfSquad")] call BIS_fnc_spawnGroup;
        _grp = [_pos, east, (configFile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry" >> "cwr3_o_rifle_squad")] call BIS_fnc_spawnGroup;
        _grp setVariable ["onTask", true];
        _grps pushBack _grp;
        [_grp, _dir] spawn {
            params ["_grp", "_dir"];
            _grp setFormation "LINE";
            _grp setFormDir _dir;
            (leader _grp) setDir _dir;
            sleep 30;
            {
                [_x, _dir, 7, true] spawn dyn_find_cover;
            } forEach (units _grp);
        };
    } forEach _objs;

    // create Patroll
    _grp = [getPos _aoPos, east, (configFile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry" >> "cwr3_o_at_team")] call BIS_fnc_spawnGroup;
    _grp setBehaviour "SAFE";
    {
        _grp addWaypoint [_x, 20];
    } forEach _patrollPos;
    _wp = _grp addWaypoint [getPos _aoPos, 20];
    _wp setWaypointType "CYCLE";

    // create garrison
    _buildings = nearestObjects [(getPos _aoPos), ["house"], (triggerArea _aoPos)#0];

    _garAmount = [1, 3] call BIS_fnc_randomInt;
    private _garCount = 0;

    {
        if (count ([_x] call BIS_fnc_buildingPositions) >= 4 and ((getPos _x inArea _aoPos)) and _garCount < _garAmount) then {
            _garCount = _garCount + 1;
            _grp = [getPos _aoPos, east, (configFile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry" >> "cwr3_o_fire_team")] call BIS_fnc_spawnGroup;
            [_x, _grp, _dir] spawn dyn_garrison_building;
        };
    } forEach _buildings;

    //create counterattack;


    [_patrollPos, _aoPos, _dir, _grps, _townTrg] spawn {
        params ["_patrollPos", "_aoPos", "_dir", "_grps", "_townTrg"];
        private _counterAttack = [];
        private _isCounter = false;

        waitUntil {sleep 1; triggerActivated _aoPos};

        if ((random 1) > 0.5) then {[] spawn dyn_arty};

        if ((random 1) > 0.5) then {

            _isCounter = true;

            private _rearPos = [1500 * (sin (_dir - 180)), 1500 * (cos (_dir - 180)), 0] vectorAdd (getPos _aoPos);

            for "_i" from 0 to ([3, 5] call BIS_fnc_randomInt) do {
                _sPos = [[[_rearPos, 100]], ["water"]] call BIS_fnc_randomPos;
                _sPos = _sPos findEmptyPosition [0, 60];
                _grp = [_sPos, east, (configFile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry" >> "cwr3_o_rifle_squad")] call BIS_fnc_spawnGroup;
                _counterAttack pushBack _grp;
                _grp setFormation "LINE";
                {
                    _x disableAI "AUTOCOMBAT";
                } forEach (units _grp);
            };

            for "_i" from 0 to ([1, 3] call BIS_fnc_randomInt) do {
                _vicType = selectRandom ["cwr3_o_bmp1", "cwr3_o_btr80", "cwr3_o_bmp2", "cwr3_o_t55"];
                _sPos = [[[_rearPos, 100]], ["water"]] call BIS_fnc_randomPos;
                _sPos = _sPos findEmptyPosition [0, 150];
                _vic = _vicType createVehicle _sPos;
                _grp = createVehicleCrew _vic;
                _counterAttack pushBack _grp;
            };
            sleep 5;
            {
                _x addWaypoint [(selectRandom _patrollPos), 20];
                _vic forceSpeed 15;
                (vehicle (leader _x)) forceSpeed 15;
            } forEach _counterAttack;
        };

        // Retreat to obj/town
        sleep ([180, 360] call BIS_fnc_randomInt);

        _rPos = getPos _townTrg;

        {
            _grp = _x;
            {
                _x enableAI "PATH";
                _x disableAI "AUTOCOMBAT";
                _x setUnitPos "AUTO";
                _x doFollow (leader _grp);
            } forEach (units _grp);

            if (_isCounter) then {
                _grp addWaypoint [(selectRandom _patrollPos), 20];
            }
            else
            {
                _grp addWaypoint [_rPos, 150];
            };

            _grp setBehaviour "AWARE";
        } forEach _grps;

    };
};

dyn_strong_point_defence = {
    params ["_locPos", "_townTrg", "_dir"];
    private ["_aoPos", "_grps"];

    _offset = [-40 , 40] call BIS_fnc_randomInt;
    _defPos = [1300 * (sin (_dir + _offset)), 1300 * (cos (_dir + _offset)), 0] vectorAdd _locPos;
    _defPos = getPos ((nearestTerrainObjects [_defPos, ["TREE", "FOREST BORDER", "FOREST TRIANGLE", "FOREST SQUARE"], 300, true, true]) select 0);
    _aoPos = createTrigger ["EmptyDetector", _defPos, true];
    _aoPos setTriggerActivation ["WEST", "PRESENT", false];
    _aoPos setTriggerStatements ["this", " ", " "];
    _aoPos setTriggerArea [700, 700, _dir, false];

    _grps = [];
    _degree = [0, -75, 75];
    for "_i" from 0 to 2 do {
        _nDir = _dir + (_degree#_i);
        _nPos = [100 * (sin _nDir), 100 * (cos _nDir), 0] vectorAdd _defPos;
        _grp = [_nPos, _nDir] call dyn_spawn_covered_inf;
        _grps pushBack _grp;
    };
    _grp = [_defPos, "cwr3_o_t55", _dir] dyn_spawn_covered_vehicle
    _grps pushBack _grp;
    [_aoPos, _defPos, getPos _townTrg, 0, [3,4] call BIS_fnc_randomInt, 1] spawn dyn_spawn_counter_attack;
};

dyn_town_defense = {
    params ["_aoPos"];
    private ["_dir", "_watchPos", "_validBuildings", "_patrollPos", "_allGrps"];
    _dir = 360 + ((triggerArea _aoPos)#2);
    _watchPos = [1000 * (sin _dir), 1000 * (cos _dir), 0] vectorAdd (getPos _aoPos);
    _validBuildings = [];
    _patrollPos = [];

    // create outer Garrison
    _buildings = nearestObjects [(getPos _aoPos), ["house"], (triggerArea _aoPos)#0];


    {
        if (count ([_x] call BIS_fnc_buildingPositions) >= 4 and ((getPos _x inArea _aoPos))) then {
            _validBuildings pushBack _x;
        };
    } forEach _buildings;

    _validBuildings = [_validBuildings, [], {_x distance2D _watchPos}, "ASCEND"] call BIS_fnc_sortBy;

    _garAmount = [2, 4] call BIS_fnc_randomInt;

    for "_i" from 0 to (_garAmount * 3) step 3 do {
        _grp = [getPos _aoPos, east, (configFile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry" >> "cwr3_o_fire_team")] call BIS_fnc_spawnGroup;
        [(_validBuildings#_i), _grp, _dir] spawn dyn_garrison_building;
        if ((random 1) > 0.5) then {_patrollPos pushBack (getPos (_validBuildings#_i))}
    };

    for "_i" from 1 to 2 do {
        _grp = [getPos _aoPos, east, (configFile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry" >> "cwr3_o_fire_team")] call BIS_fnc_spawnGroup;
        [(_validBuildings#((count _validBuildings) - _i)), _grp, _dir - 180] spawn dyn_garrison_building;
        if ((random 1) > 0.5) then {_patrollPos pushBack (getPos (_validBuildings#((count _validBuildings) - _i)))}
    };

    // create static Vehicle / Inf
    _step = [2, 8] call BIS_fnc_randomInt;
    for "_i" from 0 to _step step _step do {
        _vPos = getPos (_validBuildings#_i);
        _vicType = selectRandom ["cwr3_o_bmp1", "cwr3_o_btr80", "cwr3_o_bmp2", "cwr3_o_t55"];
        _vPos = [_vPos, 1, 100, 3, 0, 20, 0] call BIS_fnc_findSafePos;
        _vPos = _vPos findEmptyPosition [0, 100, _vicType];
        if ((count _vPos) > 0) then {
            _vic = _vicType createVehicle _vPos;
            _vic setDir _dir;
            _vic setFuel 0;
            _grp = createVehicleCrew _vic;
            _grp setBehaviour "SAFE";
            for "_i" from 0 to 3 do {
                _camoPos = [6 * (sin ((getDir _vic) + ([-10, 10] call BIS_fnc_randomInt))), 6 * (cos ((getDir _vic) + ([-10, 10] call BIS_fnc_randomInt))), 0] vectorAdd (getPos _vic);
                "gm_b_crataegus_monogyna_01_summer" createVehicle _camoPos;
            };
            _net = "Land_CamoNetVar_EAST" createVehicle _vPos;
        };
    };

    _distance = [20, 50] call BIS_fnc_randomInt;
    for "_i" from -30 to 30 step 60 do {
        _infPos = getPos (_validBuildings#([0, 8] call BIS_fnc_randomInt));
        _infPos = [_distance * (sin (_dir + _i)), _distance * (cos (_dir + _i)), 0] vectorAdd _infPos;
        _grp = [_infPos, east, (configFile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry" >> "cwr3_o_rifle_squad")] call BIS_fnc_spawnGroup;
        _grp setVariable ["onTask", true];
        [_grp, _dir] spawn {
            params ["_grp", "_dir"];
            _grp setFormation "LINE";
            _grp setFormDir _dir;
            (leader _grp) setDir _dir;
            sleep 20;
            _units = units _grp;
            for "_i" from 0 to ((count _units) - 1) step 4 do {
                _cPos = getPos (_units#0);
                _cDir =  getDir (_units#0);
                _cPos = [1.5 * (sin _cDir), 1.5 * (cos _cDir), 0] vectorAdd _cPos;
                _cover = "land_gm_sandbags_01_round_01" createVehicle _cPos;
                _cover setDir _cDir;
                _cover setVectorUp surfaceNormal position _cover;
            };
            sleep 10;
            {
                [_x, _dir, 15, true] spawn dyn_find_cover;
            } forEach (units _grp);
        };
        _comp = selectRandom ["land_gm_camonet_02_east", "Land_CamoNetVar_EAST"];
        _net = _comp createVehicle _infPos;
        
    };



    _validBuildings = [_validBuildings, [], {_x distance2D (getPos _aoPos)}, "ASCEND"] call BIS_fnc_sortBy;

    // create HQ
    _hq = _validBuildings#0;
    _grp = [getPos _aoPos, east, (configFile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry" >> "cwr3_o_rifle_squad")] call BIS_fnc_spawnGroup;
    [_hq, _grp, _dir] spawn dyn_garrison_building;
    _tentPos = (getPos _hq) findEmptyPosition [25, 150, "Land_BagBunker_Large_F"];
    if ((count _tentPos) > 0) then {
        [_tentPos, sideEmpty, (configFile >> "CfgGroups" >> "Empty" >> "military" >> "gm_tents" >> "gm_tent_command")] call BIS_fnc_spawnGroup;
        _grp = [_tentPos, east, (configFile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry" >> "cwr3_o_rifle_squad")] call BIS_fnc_spawnGroup;
        _grp setFormation "DIAMOND";
        _grp setBehaviour "SAFE";
    };

    for "_i" from 0 to 1 do {
        _netPos = [[[getPos _hq, 20]], [[getPos _hq, 10], "water"]] call BIS_fnc_randomPos;
        _comp = selectRandom ["land_gm_camonet_01_east", "land_gm_camonet_02_east"];
        _net = _comp createVehicle _netpos;
        _net setVectorUp surfaceNormal position _net;
        _net setDir _dir;
        _grp = [_netPos, east, (configFile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry" >> "cwr3_o_fire_team")] call BIS_fnc_spawnGroup;
        _grp setFormation "DIAMOND";
        _grp setBehaviour "SAFE";
    };

    // create empty Vehicles with Fireteam
    for "_i" from 0 to ([1, 3] call BIS_fnc_randomInt) do {
        _vicType = selectRandom ["cwr3_o_uaz", "cwr3_o_ural"];
        _vPos = [[_aoPos], ["water"]] call BIS_fnc_randomPos;
        _road = selectRandom ((getPos _aoPos) nearRoads (((triggerArea _aoPos)#0) - 100));
        _roadDir = getPos ((roadsConnectedTo _road) select 0) getDir (getPos _road);
        _vpos = getPos _road;
        _vic = _vicType createVehicle _vPos;
        _vic setDir _roadDir;
        _grp = [_vPos, east, (configFile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry" >> "cwr3_o_fire_team")] call BIS_fnc_spawnGroup;
        _grp setFormation "DIAMOND";
        _grp setBehaviour "SAFE";

        _patrollPos pushBack _vpos;
    };

    // create Patrols
    for "_i" from 0 to ([1, 2] call BIS_fnc_randomInt) do {
        _grp = [selectRandom _patrollPos, east, (configFile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry" >> "cwr3_o_at_team")] call BIS_fnc_spawnGroup;
        _grp setBehaviour "SAFE";

        {
        _grp addWaypoint [_x, 20];
        } forEach _patrollPos;
        _wp = _grp addWaypoint [getPos _hq, 20];
        _wp setWaypointType "CYCLE";
    };

    // create raodblock
    _roads = (getPos _aoPos) nearRoads ((triggerArea _aoPos)#0);
    _watchPos = [1000 * (sin _dir), 1000 * (cos _dir), 0] vectorAdd (getPos _aoPos);
    _roads = [_roads, [], {_x distance2D _watchPos}, "ASCEND"] call BIS_fnc_sortBy;
    _road = _roads#0;
    _roadDir = getPos ((roadsConnectedTo _road) select 0) getDir (getPos _road);
    [getPos _road, sideEmpty, (configFile >> "CfgGroups" >> "Empty" >> "military" >> "RoadBlocks" >> "gm_barrier_light"),[],[],[],[],[], _roadDir] call BIS_fnc_spawnGroup;

    //create Tank/APC
    for "_i" from 0 to ([0, 1] call BIS_fnc_randomInt) do {
        _vicType = selectRandom ["cwr3_o_bmp1", "cwr3_o_btr80", "cwr3_o_bmp2", "cwr3_o_t55"];
        // _vPos = [[_aoPos], ["water"]] call BIS_fnc_randomPos;
        _road = selectRandom ((getPos _aoPos) nearRoads (((triggerArea _aoPos)#0) - 200));
        _roadDir = getPos ((roadsConnectedTo _road) select 0) getDir (getPos _road);
        _vpos = getPos _road;
        _vic = _vicType createVehicle _vPos;
        _grp = createVehicleCrew _vic;
        _grp setBehaviour "SAFE";

        [_grp, _hq, _aoPos] spawn {
            params  ["_grp", "_hq", "_aoPos"];

             waitUntil {sleep 1; triggerActivated _aoPos};

             sleep ([20, 120] call BIS_fnc_randomInt);

             _grp addWaypoint [(getpos _hq), 100];
             _grp setBehaviour "COMBAT";
             (vehicle (leader _grp)) forceSpeed 15;
        };
    };

    //create QRF
    if ((random 1) > 0.3) then {
        [_aoPos, _dir, getPos _hq] spawn {
            params ["_aoPos", "_dir", "_hq"];
            private _qrf = [];

            waitUntil {sleep 1; triggerActivated _aoPos};

            // private _atkPos = [400 * (sin _dir), 400 * (cos _dir), 0] vectorAdd (getPos _aoPos);
            private _atkPos = {
                if (_x distance2D _hq < 500) exitWith {getPos _x};
            } forEach (allUnits+vehicles select {side _x == west});
            // private _rearPos = [500 * (sin (_dir - 180)), 500 * (cos (_dir - 180)), 0] vectorAdd (getPos _aoPos);

            for "_i" from 0 to ([1, 2] call BIS_fnc_randomInt) do {
                _sPos = [[[_hq, 40]], ["water"]] call BIS_fnc_randomPos;
                _sPos = _sPos findEmptyPosition [0, 60];
                _grp = [_sPos, east, (configFile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry" >> "cwr3_o_fire_team")] call BIS_fnc_spawnGroup;
                _qrf pushBack _grp;
                _grp setFormation "LINE";
                {
                    _x disableAI "AUTOCOMBAT";
                } forEach (units _grp);
            };

            sleep 5;
            {
                _x addWaypoint [_atkPos, 100];
                (vehicle (leader _x)) limitSpeed 15;
            } forEach _qrf;
        };
    };

    // create Alarmposten

    for "_i" from 0 to 3 do {
        _diff = 360 / 4;
        _degree = 1 + _i * _diff;
        _aPos = [700 * (sin _degree), 700 * (cos _degree), 0] vectorAdd (getPos _aoPos);
        _apos = getPos ((nearestTerrainObjects [_aPos, ["TREE", "FOREST BORDER", "FOREST TRIANGLE", "FOREST SQUARE"], 400, true, true]) select 0);
        _aPos =  ASLToATL _apos;
        _grp = [_aPos, east, ["cwr3_o_soldier_tl", "cwr3_o_soldier_at_rpg18", "cwr3_o_soldier_ar"]] call BIS_fnc_spawnGroup;
        _grp setBehaviour "STEALTH";
        (leader _grp) setDir _dir;
        _grp setFormDir _dir;
        _watchDir = _degree;

        [_grp, _hq, _aoPos] spawn {
            params  ["_grp", "_hq", "_aoPos"];

             waitUntil {sleep 1; triggerActivated _aoPos};

             {
                _x disableAI "AUTOCOMBAT";
             } forEach (units _grp);
             _grp setBehaviour "AWARE";
             _grp addWaypoint [(getpos _hq), 100];
        };
    };
};


dyn_raid = {
    params ["_atkPos", "_defPos"];

    

    private _raid = [];
    private _dir =  _atkPos getDir _defPos;
    _rearPos = [2000 * (sin _dir), 2000 * (cos _dir), 0] vectorAdd _atkPos;

    for "_i" from 0 to ([3, 5] call BIS_fnc_randomInt) do {
        _nDir = _dir + 90;
        _sPos = [(80 * _i) * (sin _nDir), (80 * _i) * (cos _nDir), 0] vectorAdd _rearPos;
        _sPos = _sPos findEmptyPosition [0, 60];
        _grp = [_sPos, east, (configFile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry" >> "cwr3_o_rifle_squad"),[],[],[],[],[], (_dir -180)] call BIS_fnc_spawnGroup;
        _raid pushBack _grp;
        _grp setFormation "LINE";
        {
            _x disableAI "AUTOCOMBAT";
        } forEach (units _grp);
    };

    for "_i" from 0 to ([2, 3] call BIS_fnc_randomInt) do {
        _vicType = selectRandom ["cwr3_o_bmp1", "cwr3_o_btr80", "cwr3_o_bmp2", "cwr3_o_t55"];
        _nDir = _dir + 90;
        _sPos = [(80 * _i) * (sin _nDir), (80 * _i) * (cos _nDir), 0] vectorAdd _rearPos;
        _sPos = _sPos findEmptyPosition [0, 150];
        _vic = _vicType createVehicle _sPos;
        _vic setDir (_dir -180);
        _grp = createVehicleCrew _vic;
        _raid pushBack _grp;
    };
    sleep 5;
    private _leaders = [];
    {
        _wpPos = [2000 * (sin (_dir - 180)), 2000 * (cos (_dir - 180)), 0] vectorAdd getPos (leader _x);
        _x addWaypoint [_wpPos, 0];
        (vehicle (leader _x)) forceSpeed 15;
        _leaders pushBack (leader _x);
    } forEach _raid;

    waitUntil {sleep 1; ({(_atkPos distance2D _x) < 800} count _leaders) > 0};

    if ((random 1) > 0.3) then {[] spawn dyn_arty};

    waitUntil {sleep 1; ({alive _x} count _leaders) <= 5};

    [_defPos, _raid] spawn dyn_retreat;

};

dyn_create_markers = {
    params ["_pos", "_dir", "_trg"];

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
    _marker3 setMarkerSize [20, 1800];
    _marker3 setMarkerDir _dir;
    _marker3 setMarkerBrush "Vertical";
    _marker3 setMarkerColor "colorOPFOR";

    _marker4 = createMarker [format ["right%1", _pos], _rightPos];
    _marker4 setMarkerShape "RECTANGLE";
    _marker4 setMarkerSize [20, 1800];
    _marker4 setMarkerDir _dir;
    _marker4 setMarkerBrush "Vertical";
    _marker4 setMarkerColor "colorOPFOR";

    waitUntil {sleep 1; triggerActivated _trg};

    deleteMarker _marker1;
    deleteMarker _marker2;
    deleteMarker _marker3;
    deleteMarker _marker4;
};


dyn_retreat = {
    params ["_dest", "_grps"];

    if ((random 1) > 0.5) then {[] spawn dyn_arty};

    {
        _grp = _x;
        {
            _x enableAI "PATH";
            _x doFollow (leader _grp);
            _x disableAI "AUTOCOMBAT";
            _x setUnitPos "AUTO";
        } forEach (units _grp);

        [_grp, (currentWaypoint _grp)] setWaypointType "MOVE";
        [_grp, (currentWaypoint _grp)] setWaypointPosition [getPosASL (leader _grp), -1];
        sleep 0.1;
        deleteWaypoint [_grp, (currentWaypoint _grp)];
        for "_i" from count waypoints _grp - 1 to 0 step -1 do {
            deleteWaypoint [_grp, _i];
        };


        _grp addWaypoint [_dest, 150];
        _grp setFormation "COLUMN";
        _grp setBehaviour "AWARE";
        
    } forEach _grps;

    sleep 240;

    {
        _grp = _x;
        {
            _wGrp = _x;
            {
                _wGrp forgetTarget _x;
            } forEach (units _grp);
        } forEach (allGroups select {side _x == playerSide});
    } forEach _grps;
};

dyn_arty = {
    _target = selectRandom (allUnits select {side _x == west});
    _pos = getPos _target;
    _amount = [3, 6] call BIS_fnc_randomInt;

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


// dyn_place_player = {
//     params ["_pos", "_dest"];
//     private ["_startPos", "_infGroups", "_vehicles", "_roads"];
//     _startPos = getPos player;
//     _infGroups = [];
//     _vehicles = nearestObjects [_startPos,["LandVehicle"],300];
//     {
//         if(((player distance2D (leader _x)) < 300) and !(vehicle (leader _x) in _vehicles)) then {
//             _infGroups pushBack _x;
//         }
//     } forEach (allGroups select {side _x isEqualTo playerSide});

//     _roads = _pos nearRoads 300;
//     private _dir = _pos getDir _dest;
//     for "_i" from 0 to (count _vehicles) - 1 step 1 do {
//         private _road = _roads#_i;
//         (_vehicles#_i) setPos getPos (_road);
//         _near = roadsConnectedTo _road;
//         _near = [_near, [], {(getPos _x) distance2D _dest}, "DESCEND"] call BIS_fnc_sortBy;
//         _dir = (getPos (_near#0)) getDir (getPos _road);
//         (_vehicles#_i) setDir _dir;
//     };
//     {
//         _pos = [getPos (_vehicles#0), 1, 150, 3, 0, 20, 0] call BIS_fnc_findSafePos;
//         {
//             _x setPos _pos;
//         } forEach (units _x);
//     } forEach _infGroups;
// };


dyn_place_player = {
    params ["_pos", "_dest"];
    private ["_startPos", "_infGroups", "_vehicles", "_roads", "_road"];
    _startPos = getPos player;
    _infGroups = [];
    _vehicles = nearestObjects [_startPos,["LandVehicle"],300];
    {
        if(((player distance2D (leader _x)) < 300) and !(vehicle (leader _x) in _vehicles)) then {
            _infGroups pushBack _x;
        }
    } forEach (allGroups select {side _x isEqualTo playerSide});

    _roads = _pos nearRoads 300;

    _road = _roads#0;
    _usedRoads = [];
    for "_i" from 0 to (count _vehicles) - 1 step 1 do {
        _road = ((roadsConnectedTo _road) - [_road]) select 0;
        (_vehicles#_i) setPos getPos (_road);
        _near = roadsConnectedTo _road;
        _near = [_near, [], {(getPos _x) distance2D _dest}, "DESCEND"] call BIS_fnc_sortBy;
        _dir = (getPos (_near#0)) getDir (getPos _road);
        (_vehicles#_i) setDir _dir;
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

dyn_endings = ["dyn_end_0", "dyn_end_1", "dyn_end_2", "dyn_end_3", "dyn_end_4", "dyn_end_5"];
dyn_starts = ["dyn_start_0", "dyn_start_1", "dyn_start_2", "dyn_start_3", "dyn_start_4", "dyn_start_5"];
dyn_start = selectRandom dyn_starts;
dyn_end = selectRandom dyn_endings;
{
    deleteMarker _x;
} forEach (dyn_endings - [dyn_end]);
{
    deleteMarker _x;
} forEach (dyn_starts - [dyn_start]);


_aoStart = ((getMarkerPos dyn_start) nearRoads 300) select 0;
_aoEnd = ((getMarkerPos dyn_end) nearRoads 300) select 0;

[getPos _aoStart, getPos _aoEnd] call dyn_place_player;
[_aoStart, _aoEnd] call dyn_define_msr;

dyn_locations = [];

{
    _loc = nearestLocation [_x, "NameVillage"];
    if ((_x distance2D (getPos _loc)) < 500 and (((getPos _loc) distance2D (getMarkerPos dyn_start)) > 2500)) then {
        if !(_loc in dyn_locations) then {
            dyn_locations pushBack _loc;
        };
    };
    _loc = nearestLocation [_x, "NameCity"];
    if ((_x distance2D (getPos _loc)) < 500 and (((getPos _loc) distance2D (getMarkerPos dyn_start)) > 2500)) then {
        if !(_loc in dyn_locations) then {
            dyn_locations pushBack _loc;
        };
    };
} forEach dyn_msr_markers;

reverse dyn_locations;


// debug
// _i = 0;
// {
//     _m = createMarker [str (random 1), getPos _x];
//     _m setMarkerText str _i;
//     _m setMarkerType "mil_circle";
//     _i = _i + 1;
// } forEach dyn_locations;


[dyn_locations] spawn {
    params ["_locations"];


    for "_i" from 0 to (count _locations) - 1 do {
        _loc = _locations#_i;

        private _dir = 0;
        private _outerDefenses = false;
        if (_i > 0) then {
            _pos = getPos (_locations#(_i - 1));
            _dir = (getPos _loc) getDir _pos;
            if (((getPos _loc) distance2D _pos) > 1600) then {
                _outerDefenses = true;
            };
        }
        else
        {  
            _dir = (getPos _loc) getDir (getMarkerPos dyn_start);
            if (((getPos _loc) distance2D (getMarkerPos dyn_start)) > 1600) then {
                _outerDefenses = true;
            };


        };
        _trg = createTrigger ["EmptyDetector", (getPos _loc), true];
        _trg setTriggerActivation ["WEST", "PRESENT", false];
        _trg setTriggerStatements ["this", " ", " "];
        _trg setTriggerArea [400, 400, _dir, false];
        // _trg setTriggerTimeout [10, 30, 60, false];


        _locationName = text _loc;
        [west, format ["task_%1", _i], ["Offensive", format ["Capture %1", _locationName], ""], getPos _loc, "ASSIGNED", 1, true, "attack", false] call BIS_fnc_taskCreate;

        _endTrg = createTrigger ["EmptyDetector", (getPos _loc), true];
        _endTrg setTriggerActivation ["WEST SEIZED", "PRESENT", false];
        _endTrg setTriggerStatements ["this", " ", " "];
        _endTrg setTriggerArea [500, 500, _dir, false];
        _endTrg setTriggerTimeout [60, 80, 120, false];

        [_trg] call dyn_town_defense;
        [getPos _loc, _dir, _trg] spawn dyn_create_markers;
        [getPos _loc, _dir, _endTrg] spawn dyn_ambiance;

        if (_outerDefenses) then {
            [getPos _loc, _trg] call dyn_defense_line;
            // [getPos _loc, _trg, _dir] call dyn_strong_point_defence;
        };

        waitUntil {sleep 1; triggerActivated _endTrg};

        [format ["task_%1", _i], "SUCCEEDED", true] call BIS_fnc_taskSetState;

        sleep 5;
        if (_i < ((count _locations) - 1)) then {
            _retreatPos = getPos (_locations#(_i + 1));
            [_retreatPos, (allGroups select {side _x == east})] spawn dyn_retreat;
            sleep 5;
            if ((random 1) > 0.6) then {
                [getPos (_locations#_i) , getPos (_locations#(_i + 1))] spawn dyn_raid;
            };
        };
        sleep 20;


    };
};







// [ao_test] call dyn_defense_line;
// [ao_town] call dyn_town_defense;


//  "land_gm_sandbags_01_round_01"

// [getPos ao_test, 0] call dyn_strong_point_defence;

// [getPos ao_test1, getPos ao_test2] spawn dyn_raid;