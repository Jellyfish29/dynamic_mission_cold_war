

// CWR 3 Soviets 85
dyn_standart_squad = configFile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry" >> "cwr3_o_rifle_squad";
dyn_standart_fire_team = configFile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry" >> "cwr3_o_fire_team";
dyn_standart_at_team = configFile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry" >> "cwr3_o_at_team";
dyn_standart_recon_team = configFile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry" >> "cwr3_o_spetsnaz_team";
dyn_standart_soldier = "cwr3_o_soldier";
dyn_standart_sniper = "cwr3_o_soldier_marksman";
dyn_standart_mg = "cwr3_o_soldier_mg";
dyn_standart_at_soldier = "cwr3_o_soldier_at_rpg7";
dyn_standart_trasnport_vehicles = ["cwr3_o_ural_open", "cwr3_o_ural"];
dyn_standart_combat_vehicles = ["cwr3_o_bmp1", "cwr3_o_bmp2", "cwr3_o_t55amv", "cwr3_o_t55a", "cwr3_o_mtlb_pk", "cwr3_o_bmp1p", "cwr3_o_bmp2_zu23"];
dyn_standart_mechs = ["cwr3_o_bmp1", "cwr3_o_bmp1p", "cwr3_o_bmp2", "cwr3_o_bmp2"]; //"cwr3_o_mtlb_pk"
dyn_standart_light_armed_transport = ["cwr3_o_uaz_dshkm", "cwr3_o_uaz_ags30"];
dyn_standart_tanks = ["cwr3_o_t72a", "cwr3_o_t72b1", "cwr3_o_t64bv", "cwr3_o_t55amv"];
dyn_standart_supply_vics = ["cwr3_o_ural_refuel", "cwr3_o_ural_reammo"];
dyn_standart_MBT = selectRandom ["cwr3_o_t72a", "cwr3_o_t72b1", "cwr3_o_t64bv"];
dyn_standart_light_amored_vic = "cwr3_o_btr80";
dyn_standart_light_amored_vics = ["cwr3_o_btr80", "cwr3_o_brdm2", "cwr3_o_brdm2_atgm"];
dyn_standart_flag = "cwr3_flag_ussr";
dyn_standart_statics_high = ["vn_o_vc_static_pk_high"]; //["cwr3_o_nsv_high"];
dyn_standart_statics_low = ["vn_o_vc_static_pk_low"]; //["cwr3_o_nsv_low", "cwr3_o_ags30", "cwr3_o_spg9"];
dyn_standart_statics_atgm = ["cwr3_o_konkurs_tripod"];
dyn_standart_statics_atgun = ["cwr3_o_spg9"];
dyn_standart_arty = "gm_gc_army_2s1";//"cwr3_o_d30";
dyn_standart_rocket_arty = "gm_gc_army_ural375d_mlrs";
dyn_standart_balistic_arty = "gm_gc_army_2p16";
dyn_standart_light_arty = "cwr3_o_2b14";
dyn_attack_heli = "cwr3_o_mi24d";
dyn_attack_plane = "RHS_Su25SM_vvsc";
dyn_recon_convoy = ["cwr3_o_btr80", "cwr3_o_btr80", "cwr3_o_brdm2_atgm", "cwr3_o_brdm2um", "cwr3_o_brdm2"];
dyn_hq_vehicles = ["cwr3_o_bmp2_hq", "cwr3_o_ural_hq"];
dyn_map_center = [worldSize / 2, worldsize / 2, 0];
dyn_opfor_comp = [["o_mech_inf", "232. MechInfBtl"], ["o_inf", "16. GdsInfBtl"], ["o_motor_inf", "45. MotInfBtl"], ["o_motor_inf", "101. MotInfBtl"], ["o_armor", "3. ArmBtl"]];
dyn_uniforms_dic = createHashMapFromArray [["o_mech_inf", "cwr3_o_uniform_kzs_v1"], ["o_inf", "cwr3_o_uniform_m1982"], ["o_motor_inf", "cwr3_o_uniform_kzs_v2"], ["o_armor", "cwr3_o_uniform_kzs_v2"]];
dyn_bushes = ["gm_b_crataegus_monogyna_01_summer", "gm_b_crataegus_monogyna_02_summer", "gm_b_corylus_avellana_01_summer", "gm_b_sambucus_nigra_01_summer"];
dyn_phase_names = ["OBJ VICTORY", "OBJ ABLE", "OBJ RHINO", "OBJ BISON", "OBJ HAMMER", "OBJ WIDOW", "OBJ FIONA", "OBJ IRINE", "OBJ DAVID", "OBJ DAWN", "OBJ DIAMOND", "OBJ GOLD", "OBJ REAPER", "OBJ MARY"];
dyn_allied_vics = ["gm_ge_army_luchsa2", "gm_ge_army_m113a1g_apc", "gm_ge_army_leopard1a5"];
dyn_allied_soldier = "gm_ge_army_rifleman_g3a3_80_ols";
dyn_allied_unit_names = [["b_b_armor_pl", "2nd Btl/4th Armored"], ["b_b_armor_pl", "1st Btl/4th Armored"], ["b_c_armor_pl", "1st Btl/1st Armored"], ["b_b_armor_pl", "DEU PzBtl 208"], ["b_b_mech_pl", "3rd Btl/1st Inf"], ["b_b_mech_pl", "2nd Btl/1st Inf"]];
dyn_civ_vics = ["cwr3_c_gaz24", "cwr3_c_mini", "cwr3_c_rapid", "gm_ge_civ_typ1200", "gm_ge_civ_w123", "gm_ge_civ_w123", "gm_ge_civ_typ247"];
dyn_civilian = "cwr3_c_civilian_random";
dyn_uniform_change = true;

// CWR 3 Soviets 70s
// dyn_standart_squad = configfile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry82" >> "cwr3_o_rifle_squad82";
// dyn_standart_fire_team = configfile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry82" >> "cwr3_o_fire_team82";
// dyn_standart_at_team = configfile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry82" >> "cwr3_o_at_team82";
// dyn_standart_recon_team = configfile >> "CfgGroups" >> "East" >> "CWR3_RUS" >> "Infantry82" >> "cwr3_o_fire_team82";
// dyn_standart_soldier = "cwr3_o_soldier82";
// dyn_standart_sniper = "cwr3_o_soldier82_marksman";
// dyn_standart_mg = "cwr3_o_soldier82_mg";
// dyn_standart_at_soldier = "cwr3_o_soldier82_at_rpg7";
// dyn_standart_trasnport_vehicles = ["cwr3_o_ural_open", "cwr3_o_ural"];
// dyn_standart_combat_vehicles = ["cwr3_o_bmp1", "cwr3_o_t55a", "cwr3_o_mtlb_pk", "cwr3_o_bmp1p", "cwr3_o_bmp2_zu23"];
// dyn_standart_mechs = ["cwr3_o_bmp1", "cwr3_o_bmp1p", "cwr3_o_bmp2"]; //"cwr3_o_mtlb_pk"
// dyn_standart_light_armed_transport = ["cwr3_o_uaz_dshkm", "cwr3_o_uaz_ags30"];
// dyn_standart_tanks = ["cwr3_o_t72a", "cwr3_o_t55a"];
// dyn_standart_supply_vics = ["cwr3_o_ural_refuel", "cwr3_o_ural_reammo"];
// dyn_standart_MBT = "cwr3_o_t72a";
// dyn_standart_light_amored_vic = "cwr3_o_btr80";
// dyn_standart_light_amored_vics = ["cwr3_o_btr80", "cwr3_o_brdm2", "cwr3_o_brdm2_atgm"];
// dyn_standart_flag = "cwr3_flag_ussr";
// dyn_standart_statics_high = ["vn_o_vc_static_pk_high"]; //["cwr3_o_nsv_high"];
// dyn_standart_statics_low = ["vn_o_vc_static_pk_low"]; //["cwr3_o_nsv_low", "cwr3_o_ags30", "cwr3_o_spg9"];
// dyn_standart_statics_atgm = ["cwr3_o_konkurs_tripod"];
// dyn_standart_statics_atgun = ["cwr3_o_spg9"];
// dyn_standart_arty = "gm_gc_army_2s1";//"cwr3_o_d30";
// dyn_standart_rocket_arty = "gm_gc_army_ural375d_mlrs";
// dyn_standart_balistic_arty = "gm_gc_army_2p16";
// dyn_standart_light_arty = "cwr3_o_2b14";
// dyn_attack_heli = "cwr3_o_mi24d";
// dyn_attack_plane = "RHS_Su25SM_vvsc";
// dyn_recon_convoy = ["cwr3_o_btr80", "cwr3_o_btr80", "cwr3_o_brdm2_atgm", "cwr3_o_brdm2um", "cwr3_o_brdm2"];
// dyn_hq_vehicles = ["cwr3_o_bmp2_hq", "cwr3_o_ural_hq"];
// dyn_map_center = [worldSize / 2, worldsize / 2, 0];
// dyn_opfor_comp = [["o_mech_inf", "232. MechInfBtl"], ["o_inf", "16. GdsInfBtl"], ["o_motor_inf", "45. MotInfBtl"], ["o_motor_inf", "101. MotInfBtl"], ["o_armor", "3. ArmBtl"]];
// dyn_uniforms_dic = createHashMapFromArray [["o_mech_inf", "cwr3_o_uniform_kzs_v1"], ["o_inf", "cwr3_o_uniform_m1982"], ["o_motor_inf", "cwr3_o_uniform_kzs_v2"], ["o_armor", "cwr3_o_uniform_kzs_v2"]];
// dyn_bushes = ["gm_b_crataegus_monogyna_01_summer", "gm_b_crataegus_monogyna_02_summer", "gm_b_corylus_avellana_01_summer", "gm_b_sambucus_nigra_01_summer"];
// dyn_phase_names = ["OBJ VICTORY", "OBJ ABLE", "OBJ RHINO", "OBJ BISON", "OBJ HAMMER", "OBJ WIDOW", "OBJ FIONA", "OBJ IRINE", "OBJ DAVID", "OBJ DAWN", "OBJ DIAMOND", "OBJ GOLD", "OBJ REAPER", "OBJ MARY"];
// dyn_allied_vics = ["gm_ge_army_luchsa2", "gm_ge_army_m113a1g_apc", "gm_ge_army_leopard1a5"];
// dyn_allied_soldier = "gm_ge_army_rifleman_g3a3_80_ols";
// dyn_allied_unit_names = [["b_b_armor_pl", "2nd Btl/4th Armored"], ["b_b_armor_pl", "1st Btl/4th Armored"], ["b_c_armor_pl", "1st Btl/1st Armored"], ["b_b_armor_pl", "DEU PzBtl 208"], ["b_b_mech_pl", "3rd Btl/1st Inf"], ["b_b_mech_pl", "2nd Btl/1st Inf"]];
// dyn_civ_vics = ["cwr3_c_gaz24", "cwr3_c_mini", "cwr3_c_rapid", "gm_ge_civ_typ1200", "gm_ge_civ_w123", "gm_ge_civ_w123", "gm_ge_civ_typ247"];
// dyn_civilian = "cwr3_c_civilian_random";
// dyn_uniform_change = false;

// RHS_RU
// dyn_standart_squad = configfile >> "CfgGroups" >> "East" >> "rhs_faction_msv" >> "rhs_group_rus_msv_infantry_emr" >> "rhs_group_rus_msv_infantry_emr_squad";
// dyn_standart_fire_team = configfile >> "CfgGroups" >> "East" >> "rhs_faction_vdv" >> "rhs_group_rus_vdv_infantry" >> "rhs_group_rus_vdv_infantry_fireteam";
// dyn_standart_at_team = configfile >> "CfgGroups" >> "East" >> "rhs_faction_msv" >> "rhs_group_rus_msv_infantry_emr" >> "rhs_group_rus_msv_infantry_emr_section_AT";
// dyn_standart_recon_team = configfile >> "CfgGroups" >> "East" >> "rhs_faction_vdv" >> "rhs_group_rus_vdv_infantry_recon" >> "rhs_group_rus_vdv_infantry_recon_MANEUVER";
// dyn_standart_soldier = "rhs_vmf_emr_rifleman";
// dyn_standart_sniper = "rhs_vmf_emr_rifleman";
// dyn_standart_mg = "rhs_vmf_emr_machinegunner";
// dyn_standart_at_soldier = "rhs_vmf_emr_LAT";
// dyn_standart_trasnport_vehicles = ["rhs_kamaz5350_vmf", "rhs_kamaz5350_open_vmf"];
// dyn_standart_combat_vehicles = ["rhs_bmp2d_tv", "rhs_bmp2k_tv", "rhs_btr80a_msv", "rhs_btr80_msv", "rhs_bmd2k", "rhs_bmd4_vdv"];
// dyn_standart_mechs = ["rhs_bmp2d_tv", "rhs_bmp2k_tv", "rhs_bmp3_late_msv"]; //"cwr3_o_mtlb_pk"
// dyn_standart_light_armed_transport = ["rhs_tigr_sts_vdv", "rhs_tigr_sts_3_camo_vdv"];
// dyn_standart_tanks = ["rhs_t80u", "rhs_t72bd_tv", "rhs_t80bv", "rhs_t72bb_tv"];
// dyn_standart_supply_vics = ["RHS_Ural_Fuel_VMF_01", "RHS_Ural_Ammo_VMF_01"];
// dyn_standart_MBT = "rhs_t90a_tv";
// dyn_standart_light_amored_vic = "rhs_btr80_msv";
// dyn_standart_light_amored_vics = ["rhs_btr80_msv", "rhs_btr80a_msv"];
// dyn_standart_flag = "cwr3_flag_ussr";
// dyn_standart_statics_high = ["vn_o_vc_static_pk_high"]; //["cwr3_o_nsv_high"];
// dyn_standart_statics_low = ["vn_o_vc_static_pk_low"]; //["cwr3_o_nsv_low", "cwr3_o_ags30", "cwr3_o_spg9"];
// dyn_standart_statics_atgm = ["cwr3_o_konkurs_tripod"];
// dyn_standart_statics_atgun = ["cwr3_o_spg9"];
// dyn_standart_arty = "gm_gc_army_2s1";//"cwr3_o_d30";
// dyn_standart_rocket_arty = "gm_gc_army_ural375d_mlrs";
// dyn_standart_balistic_arty = "gm_gc_army_2p16";
// dyn_standart_light_arty = "cwr3_o_2b14";
// dyn_attack_heli = "RHS_Ka52_vvsc";
// dyn_attack_plane = "RHS_Su25SM_vvsc";
// dyn_recon_convoy = ["rhs_btr80_msv", "rhs_btr80a_msv", "rhs_btr80_msv", "rhs_btr80a_msv"];
// dyn_hq_vehicles = ["RHS_Ural_Repair_VMF_01"];
// dyn_map_center = [worldSize / 2, worldsize / 2, 0];
// dyn_opfor_comp = [["o_mech_inf", "232. MechInfBtl"], ["o_inf", "16. GdsInfBtl"], ["o_motor_inf", "45. MotInfBtl"], ["o_motor_inf", "101. MotInfBtl"], ["o_armor", "3. ArmBtl"]];
// dyn_uniforms_dic = createHashMapFromArray [["o_mech_inf", "cwr3_o_uniform_kzs_v1"], ["o_inf", "cwr3_o_uniform_m1982"], ["o_motor_inf", "cwr3_o_uniform_kzs_v2"], ["o_armor", "cwr3_o_uniform_kzs_v2"]];
// dyn_bushes = ["gm_b_crataegus_monogyna_01_summer", "gm_b_crataegus_monogyna_02_summer", "gm_b_corylus_avellana_01_summer", "gm_b_sambucus_nigra_01_summer"];
// dyn_phase_names = ["OBJ VICTORY", "OBJ ABLE", "OBJ RHINO", "OBJ BISON", "OBJ HAMMER", "OBJ WIDOW", "OBJ FIONA", "OBJ IRINE", "OBJ DAVID", "OBJ DAWN", "OBJ APOBJE", "OBJ DIAMOND", "OBJ GOLD", "OBJ REAPER", "OBJ MARY"];
// dyn_allied_unit_names = [["b_b_armor_pl", "2nd Btl/4th Armored"], ["b_b_armor_pl", "1st Btl/4th Armored"], ["b_c_armor_pl", "1st Btl/1st Armored"], ["b_b_armor_pl", "DEU PzBtl 208"], ["b_b_mech_pl", "3rd Btl/1st Inf"], ["b_b_mech_pl", "2nd Btl/1st Inf"]];
// dyn_civ_vics = ["C_Hatchback_01_F", "C_Van_01_transport_F", "C_SUV_01_F"];
// dyn_civilian = "cwr3_c_civilian_random";
// dyn_uniform_change = false;

// CSAT_Pacific
// dyn_standart_squad = configFile >> "CfgGroups" >> "East" >> "OPF_T_F" >> "Infantry" >> "O_T_InfSquad";
// dyn_standart_fire_team = configFile >> "CfgGroups" >> "East" >> "OPF_T_F" >> "Infantry" >> "O_T_InfTeam";
// dyn_standart_at_team = configFile >> "CfgGroups" >> "East" >> "OPF_T_F" >> "Infantry" >> "O_T_InfTeam_AT";
// dyn_standart_recon_team = configFile >>"CfgGroups" >> "East" >> "OPF_T_F" >> "Infantry" >> "O_T_reconTeam";
// dyn_standart_soldier = "O_T_Soldier_F";
// dyn_standart_sniper = "O_T_Soldier_F";
// dyn_standart_mg = "O_T_Soldier_AR_F";
// dyn_standart_at_soldier = "O_T_Soldier_LAT_F";
// dyn_standart_trasnport_vehicles = ["O_T_Truck_02_covered_F", "O_T_Truck_03_covered_F", "O_T_Truck_02_transport_F", "O_T_Truck_03_transport_F"];
// dyn_standart_combat_vehicles = ["O_T_APC_Wheeled_02_rcws_v2_ghex_F", "O_T_MRAP_02_hmg_ghex_F", "O_T_APC_Tracked_02_cannon_ghex_F"];
// dyn_standart_mechs = ["O_T_APC_Wheeled_02_rcws_v2_ghex_F", "O_T_APC_Tracked_02_cannon_ghex_F"]; //"cwr3_O_T_mtlb_pk"
// dyn_standart_light_armed_transport = ["O_T_LSV_02_armed_F", "O_T_LSV_02_unarmed_F", "O_T_LSV_02_AT_F"];
// dyn_standart_tanks = ["O_T_APC_Tracked_02_cannon_ghex_F", "O_T_MBT_04_cannon_F"];
// dyn_standart_supply_vics = ["O_T_Truck_02_covered_F", "O_T_Truck_03_covered_F", "O_T_Truck_02_transport_F", "O_T_Truck_03_transport_F"];
// dyn_standart_MBT = "O_T_MBT_04_cannon_F";
// dyn_standart_light_amored_vic = "O_T_MRAP_02_hmg_ghex_F";
// dyn_standart_light_amored_vics = ["O_T_MRAP_02_hmg_F"];
// dyn_standart_flag = "cwr3_flag_ussr";
// dyn_standart_statics_high = ["O_T_HMG_01_high_f"]; //["cwr3_O_T_nsv_high"];
// dyn_standart_statics_low = ["O_T_HMG_01_f"]; //["cwr3_o_nsv_low", "cwr3_o_ags30", "cwr3_o_spg9"];
// dyn_standart_statics_atgm = ["O_T_HMG_01_high_f"];
// dyn_standart_statics_atgun = ["O_T_HMG_01_high_f"];
// dyn_standart_arty = "gm_gc_army_2s1";//"cwr3_o_d30";
// dyn_standart_rocket_arty = "gm_gc_army_ural375d_mlrs";
// dyn_standart_balistic_arty = "gm_gc_army_2p16";
// dyn_standart_light_arty = "cwr3_o_2b14";
// dyn_attack_heli = "O_T_Heli_Light_02_dynamicLoadout_F";
// dyn_attack_plane = "RHS_Su25SM_vvsc";
// dyn_recon_convoy = ["O_T_MRAP_02_hmg_F", "O_T_MRAP_02_hmg_F", "O_T_MRAP_02_hmg_F", "O_T_MRAP_02_hmg_F"];
// dyn_hq_vehicles = ["O_T_Truck_03_covered_F"];
// dyn_map_center = [worldSize / 2, worldsize / 2, 0];
// dyn_opfor_comp = [["o_mech_inf", "232. MechInfBtl"], ["o_inf", "16. GdsInfBtl"], ["o_motor_inf", "45. MotInfBtl"], ["o_motor_inf", "101. MotInfBtl"], ["o_armor", "3. ArmBtl"]];
// dyn_uniforms_dic = createHashMapFromArray [["o_mech_inf", "cwr3_o_uniform_kzs_v1"], ["o_inf", "cwr3_o_uniform_m1982"], ["o_motor_inf", "cwr3_o_uniform_kzs_v2"], ["o_armor", "cwr3_o_uniform_kzs_v2"]];
// dyn_bushes = ["gm_b_crataegus_monogyna_01_summer", "gm_b_crataegus_monogyna_02_summer", "gm_b_corylus_avellana_01_summer", "gm_b_sambucus_nigra_01_summer"];
// dyn_phase_names = ["OBJ VICTORY", "OBJ ABLE", "OBJ RHINO", "OBJ BISON", "OBJ HAMMER", "OBJ WIDOW", "OBJ FIONA", "OBJ IRINE", "OBJ DAVID", "OBJ DAWN", "OBJ DIAMOND", "OBJ GOLD", "OBJ REAPER", "OBJ MARY"];
// dyn_allied_vics = ["gm_ge_army_luchsa2", "gm_ge_army_m113a1g_apc", "gm_ge_army_leopard1a5"];
// dyn_allied_soldier = "gm_ge_army_rifleman_g3a3_80_ols";
// dyn_allied_unit_names = [["b_b_armor_pl", "2nd Btl/4th Armored"], ["b_b_armor_pl", "1st Btl/4th Armored"], ["b_c_armor_pl", "1st Btl/1st Armored"], ["b_b_armor_pl", "DEU PzBtl 208"], ["b_b_mech_pl", "3rd Btl/1st Inf"], ["b_b_mech_pl", "2nd Btl/1st Inf"]];
// dyn_civ_vics = ["C_Hatchback_01_F", "C_Van_01_transport_F", "C_SUV_01_F"];;
// dyn_civilian = "cwr3_c_civilian_random";
// dyn_uniform_change = false;

// CSAT
// dyn_standart_squad = configFile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfSquad";
// dyn_standart_fire_team = configFile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfTeam";
// dyn_standart_at_team = configFile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfTeam_AT";
// dyn_standart_recon_team = configFile >>"CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OI_reconTeam";
// dyn_standart_soldier = "O_Soldier_F";
// dyn_standart_sniper = "O_Soldier_F";
// dyn_standart_mg = "O_Soldier_AR_F";
// dyn_standart_at_soldier = "O_Soldier_LAT_F";
// dyn_standart_trasnport_vehicles = ["O_Truck_02_covered_F", "O_Truck_03_covered_F", "O_Truck_02_transport_F", "O_Truck_03_transport_F"];
// dyn_standart_combat_vehicles = ["O_APC_Wheeled_02_rcws_v2_F", "O_MRAP_02_hmg_F", "O_APC_Tracked_02_cannon_F"];
// dyn_standart_mechs = ["O_APC_Wheeled_02_rcws_v2_F", "O_APC_Tracked_02_cannon_F"]; //"cwr3_o_mtlb_pk"
// dyn_standart_light_armed_transport = ["O_LSV_02_armed_F", "O_LSV_02_unarmed_F", "O_LSV_02_AT_F"];
// dyn_standart_tanks = ["O_APC_Tracked_02_cannon_F", "O_MBT_04_cannon_F"];
// dyn_standart_supply_vics = ["O_Truck_02_covered_F", "O_Truck_03_covered_F", "O_Truck_02_transport_F", "O_Truck_03_transport_F"];
// dyn_standart_MBT = "O_MBT_04_cannon_F";
// dyn_standart_light_amored_vic = "O_MRAP_02_hmg_F";
// dyn_standart_light_amored_vics = ["O_MRAP_02_hmg_F"];
// dyn_standart_flag = "cwr3_flag_ussr";
// dyn_standart_statics_high = ["O_HMG_01_high_f"]; //["cwr3_o_nsv_high"];
// dyn_standart_statics_low = ["O_HMG_01_f"]; //["cwr3_o_nsv_low", "cwr3_o_ags30", "cwr3_o_spg9"];
// dyn_standart_statics_atgm = ["cwr3_o_konkurs_tripod"];
// dyn_standart_statics_atgun = ["cwr3_o_spg9"];
// dyn_standart_arty = "gm_gc_army_2s1";//"cwr3_o_d30";
// dyn_standart_rocket_arty = "gm_gc_army_ural375d_mlrs";
// dyn_standart_balistic_arty = "gm_gc_army_2p16";
// dyn_standart_light_arty = "cwr3_o_2b14";
// dyn_attack_heli = "O_Heli_Light_02_dynamicLoadout_F";
// dyn_attack_plane = "RHS_Su25SM_vvsc";
// dyn_recon_convoy = ["O_MRAP_02_hmg_F", "O_MRAP_02_hmg_F", "O_MRAP_02_hmg_F", "O_MRAP_02_hmg_F"];
// dyn_hq_vehicles = ["O_Truck_03_covered_F"];
// dyn_map_center = [worldSize / 2, worldsize / 2, 0];
// dyn_opfor_comp = [["o_mech_inf", "232. MechInfBtl"], ["o_inf", "16. GdsInfBtl"], ["o_motor_inf", "45. MotInfBtl"], ["o_motor_inf", "101. MotInfBtl"], ["o_armor", "3. ArmBtl"]];
// dyn_uniforms_dic = createHashMapFromArray [["o_mech_inf", "cwr3_o_uniform_kzs_v1"], ["o_inf", "cwr3_o_uniform_m1982"], ["o_motor_inf", "cwr3_o_uniform_kzs_v2"], ["o_armor", "cwr3_o_uniform_kzs_v2"]];
// dyn_bushes = ["gm_b_crataegus_monogyna_01_summer", "gm_b_crataegus_monogyna_02_summer", "gm_b_corylus_avellana_01_summer", "gm_b_sambucus_nigra_01_summer"];
// dyn_phase_names = ["OBJ VICTORY", "OBJ ABLE", "OBJ RHINO", "OBJ BISON", "OBJ HAMMER", "OBJ WIDOW", "OBJ FIONA", "OBJ IRINE", "OBJ DAVID", "OBJ DAWN", "OBJ DIAMOND", "OBJ GOLD", "OBJ REAPER", "OBJ MARY"];
// dyn_allied_vics = ["gm_ge_army_luchsa2", "gm_ge_army_m113a1g_apc", "gm_ge_army_leopard1a5"];
// dyn_allied_soldier = "gm_ge_army_rifleman_g3a3_80_ols";
// dyn_allied_unit_names = [["b_b_armor_pl", "2nd Btl/4th Armored"], ["b_b_armor_pl", "1st Btl/4th Armored"], ["b_c_armor_pl", "1st Btl/1st Armored"], ["b_b_armor_pl", "DEU PzBtl 208"], ["b_b_mech_pl", "3rd Btl/1st Inf"], ["b_b_mech_pl", "2nd Btl/1st Inf"]];
// dyn_civ_vics = ["cwr3_c_gaz24", "cwr3_c_mini", "cwr3_c_rapid", "gm_ge_civ_typ1200", "gm_ge_civ_w123", "gm_ge_civ_w123", "gm_ge_civ_typ247"];
// dyn_civilian = "cwr3_c_civilian_random";
// dyn_uniform_change = false;

execVM "dyn_util_functions.sqf";
execVM "dyn_ai_functions.sqf";
execVM "dyn_ambiance_functions.sqf";
execVm "dyn_satic_placements_functions.sqf";
execVM "dyn_dynamic_placements_functions.sqf";
execVm "dyn_ai_supports_functions.sqf";
execVM "dyn_obj_functions.sqf";
execVM "dyn_setup_functions.sqf";

"Group" setDynamicSimulationDistance 800;

sleep 10;
// dyn_player_support_vic_type = typeOf dyn_support_vic;
// dyn_player_repair_vic_type = typeOf dyn_repair_vic;

// Plmod Support Setup

pl_arty_enabled = false;
[] call pl_show_fire_support_menu;

pl_cas_Heli_1 = "cwr3_b_ah1f";
// pl_cas_Heli_1 = "RHS_AH64D_wd";
pl_medevac_Heli_1 = "cwr3_b_uh1_mev";
pl_supply_Heli_1 = "cwr3_b_ch47";

// pl_medevac_Heli_1 = "gm_ge_army_bo105p1m_vbh_swooper";
// pl_supply_Heli_1 = "gm_ge_army_ch_53g";

// pl_cas_Heli_1 = "BWA3_Tiger_RMK_Heavy";
// pl_supply_Heli_1 = "BWA3_NH90_TTH_M3M_Fleck";
// pl_medevac_Heli_1 = "BWA3_NH90_TTH_Fleck";

pl_cas_plane_1 = "cwr3_b_f16c";
pl_cas_plane_2 = "cwr3_b_f16c";
pl_cas_plane_3 = "cwr3_b_f16c";
// pl_cas_plane_3 = "RHS_A10";

