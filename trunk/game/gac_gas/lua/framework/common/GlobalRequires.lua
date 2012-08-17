cfg_load "int_obj/IntObj_Common"
cfg_load "int_obj/ObjDropItemTeam_Server"
cfg_load "int_obj/ObjRandomDropItem_Server"
cfg_load "model_res/IntObjRes_Client"
cfg_load "smallgame/SmallGame_Common"

cfg_load "scene/Transport_Server"
cfg_load "scene/Trap_Common"
gac_gas_require "scene_mgr/SceneCfg"
gac_gas_require "activity/item/ItemUseInfoMgr"

cfg_load "liveskill/CultivateFlowers_Common"

cfg_load "item/OreAreaMap_Common"

cfg_load "fb_game/AreaFb_Common"
gac_gas_require "scene_mgr/SceneCfg"

--[[
����ļ�����õĺ������������߻�����������ĵ�
��Ϊ����һ�н����������Ҫ��飬�Ǻǡ���
--]]

gac_gas_require "item/Equip/EquipCommonFunc"
gac_gas_require "item/Equip/EquipDef"
engine_require "common/Misc/TypeCheck"

cfg_load "int_obj/ObjRandomDropItem_Server"

--������±� 
gac_gas_require "activity/npc/CheckNpcCommon"

--װ��������
gac_gas_require "activity/int_obj/LoadIntObjActionArg"

gac_gas_require "activity/npc/LifeOriginCommon"
--��ʼ����������

--��ⲻͬ��Ӫ��Ӧ�Ĳ�ͬ��ͼ���Ƿ����
cfg_load "scene/SceneMapDifCamp_Common"
gac_gas_require "scene_mgr/SceneCfg"

