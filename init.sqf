
dyn_standart_squad = configFile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry" >> "cwr3_o_rifle_squad";
dyn_standart_fire_team = configFile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry" >> "cwr3_o_fire_team";
dyn_standart_at_team = configFile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry" >> "cwr3_o_at_team";
dyn_standart_soldier = "cwr3_o_soldier_amg";
dyn_standart_trasnport_vehicles = ["cwr3_o_ural_open", "cwr3_o_ural"];
dyn_standart_combat_vehicles = ["cwr3_o_bmp1", "cwr3_o_bmp2", "cwr3_o_t55"];
dyn_standart_light_armed_transport = ["cwr3_o_uaz_dshkm", "cwr3_o_uaz_ags30"];
dyn_standart_MBT = "cwr3_o_t72a";
dyn_standart_light_amored_vic = "cwr3_o_btr80";
dyn_standart_light_amored_vics = ["cwr3_o_btr80", "cwr3_o_brdm2", "cwr3_o_brdm2_atgm"];
dyn_standart_flag = "cwr3_flag_ussr";
dyn_standart_statics_high = ["cwr3_o_nsv_high"];
dyn_standart_statics_low = ["cwr3_o_nsv_low", "cwr3_o_ags30", "cwr3_o_spg9"];
dyn_attack_heli = "cwr3_o_mi24d";
dyn_recon_convoy = ["cwr3_o_btr80", "cwr3_o_btr80", "cwr3_o_brdm2_atgm", "cwr3_o_brdm2um", "cwr3_o_brdm2"];
dyn_hq_vehicles = ["cwr3_o_bmp2_hq", "cwr3_o_ural_hq"];
dyn_map_center = [worldSize / 2, worldsize / 2, 0];

execVM "dyn_ai_functions.sqf";
execVM "dyn_spawn_functions.sqf";
execVM "dyn_obj_functions.sqf";
execVM "dyn_setup_functions.sqf";


sleep 10;


// "CUP_B_A10_DYN_USA"
pl_cas_Heli_1 = "cwr3_b_ah64";
pl_medevac_Heli_1 = "cwr3_b_uh1_mev";
pl_cas_plane_1 = "RHS_A10";
pl_cas_plane_2 = "RHS_A10";
pl_cas_plane_3 = "RHS_A10";
