
dyn_standart_squad = configFile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry" >> "cwr3_o_rifle_squad";
dyn_standart_fire_team = configFile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry" >> "cwr3_o_fire_team";
dyn_standart_at_team = configFile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry" >> "cwr3_o_at_team";
dyn_standart_recon_team = configFile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry" >> "cwr3_o_spetsnaz_team";
dyn_standart_soldier = "cwr3_o_soldier";
dyn_standart_mg = "cwr3_o_soldier_mg";
dyn_standart_at_soldier = "cwr3_o_soldier_at_rpg7";
dyn_standart_trasnport_vehicles = ["cwr3_o_ural_open", "cwr3_o_ural"];
dyn_standart_combat_vehicles = ["cwr3_o_bmp1", "cwr3_o_bmp2", "cwr3_o_t55amv", "cwr3_o_mtlb_pk"];
dyn_standart_mechs = ["cwr3_o_bmp1", "cwr3_o_bmp2"]; //"cwr3_o_mtlb_pk"
dyn_standart_light_armed_transport = ["cwr3_o_uaz_dshkm", "cwr3_o_uaz_ags30"];
dyn_standart_tanks = ["cwr3_o_t72a", "cwr3_o_t72b1", "cwr3_o_t64bv", "cwr3_o_t55amv"];
dyn_standart_supply_vics = ["cwr3_o_ural_refuel", "cwr3_o_ural_reammo"];
dyn_standart_MBT = "cwr3_o_t72b1";
dyn_standart_light_amored_vic = "cwr3_o_btr80";
dyn_standart_light_amored_vics = ["cwr3_o_btr80", "cwr3_o_brdm2", "cwr3_o_brdm2_atgm"];
dyn_standart_flag = "cwr3_flag_ussr";
dyn_standart_statics_high = ["vn_o_vc_static_pk_high"]; //["cwr3_o_nsv_high"];
dyn_standart_statics_low = ["vn_o_vc_static_pk_low"]; //["cwr3_o_nsv_low", "cwr3_o_ags30", "cwr3_o_spg9"];
dyn_standart_statics_atgm = ["cwr3_o_konkurs_tripod"];
dyn_standart_statics_atgun = ["cwr3_o_spg9"];
dyn_standart_arty = "gm_gc_army_2s1";//"cwr3_o_d30";
dyn_standart_rocket_arty = "gm_gc_army_ural375d_mlrs";
dyn_standart_light_arty = "cwr3_o_2b14";
dyn_attack_heli = "cwr3_o_mi24d";
dyn_recon_convoy = ["cwr3_o_btr80", "cwr3_o_btr80", "cwr3_o_brdm2_atgm", "cwr3_o_brdm2um", "cwr3_o_brdm2"];
dyn_hq_vehicles = ["cwr3_o_bmp2_hq", "cwr3_o_ural_hq"];
dyn_map_center = [worldSize / 2, worldsize / 2, 0];
dyn_opfor_comp = [["o_mech_inf", "232. MechInfBtl"], ["o_inf", "16. GdsInfBtl"], ["o_motor_inf", "45. MotInfBtl"], ["o_motor_inf", "101. MotInfBtl"], ["o_armor", "3. ArmBtl"]];
dyn_uniforms_dic = createHashMapFromArray [["o_mech_inf", "cwr3_o_uniform_kzs_v1"], ["o_inf", "cwr3_o_uniform_m1982"], ["o_motor_inf", "cwr3_o_uniform_kzs_v2"], ["o_armor", "cwr3_o_uniform_kzs_v2"]];

execVM "dyn_ai_functions.sqf";
execVm "dyn_satic_placements_functions.sqf";
execVM "dyn_dynamic_placements_functions.sqf";
execVm "dyn_ai_supports_functions.sqf";
execVM "dyn_obj_functions.sqf";
execVM "dyn_setup_functions.sqf";

"Group" setDynamicSimulationDistance 800;

sleep 10;
dyn_player_support_vic_type = typeOf dyn_support_vic;
dyn_player_repair_vic_type = typeOf dyn_repair_vic;

// Plmod Support Setup

pl_arty_enabled = false;
[] call pl_show_fire_support_menu;

pl_cas_Heli_1 = "gm_ge_army_bo105p_pah1a1";
pl_medevac_Heli_1 = "cwr3_b_uh1_mev";
pl_cas_plane_1 = "RHS_A10";
pl_cas_plane_2 = "RHS_A10";
pl_cas_plane_3 = "RHS_A10";
