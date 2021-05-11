

[objNull, getMarkerPos "test_m_1", getMarkerPos "test_m_2", 6, 2, 2, false, dyn_standart_combat_vehicles, 0] spawn dyn_spawn_counter_attack;


{
    _x setStamina 120;
} forEach allUnits;