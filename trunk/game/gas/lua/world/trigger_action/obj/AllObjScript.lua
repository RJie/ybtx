g_AllObjScript = 
{
	["������"]     =	"world/trigger_action/obj/MailBox/MailBoxServer",
	["�ٻ�����"] =	"world/trigger_action/obj/CallPlayerObj/IntObjCallPlayerServer",
	["����"]	 		= "world/trigger_action/obj/Transport",
	["���򱾴���"] = "world/trigger_action/obj/Scopes_Transport",
	["Ӷ�������"] = "world/trigger_action/obj/mercenary_questpool/MercenaryQuestPool",
	["������"] = "world/trigger_action/obj/OrderClick",
	["���ڸ����б�"] = "world/trigger_action/obj/fb_list/FbList",
	--�Զ�ʰȡ��OBJ
	["��ʰȡ��Obj"]     = "world/trigger_action/obj/ItemObj",   --ƻ���ȵ�������ֱ�ӽ��뱳����Obj
	["ʰȡ��ʯ"]     = "world/trigger_action/obj/ore_obj/CollectOreObj",
	["�ɼ�����"]     = "world/trigger_action/obj/CollObj/IntObjCollObjServer",
	["��ʰȡ��Obj��ʱ��"]	= "world/trigger_action/obj/TemporaryBuffObj",
	["���"] = "world/trigger_action/obj/BuffObj",
	["��ʱ�����"] = "world/trigger_action/obj/TemporaryBuffObj",
	---------------
	["�����Obj"]		= "world/trigger_action/obj/SignUpObj",
	["������ս"]		= "world/trigger_action/obj/ChallengeFlagObj",
	["����Obj"]		= "world/trigger_action/obj/QuestObjServer",
	["�ɼ���Ʒ"] 	= "world/trigger_action/obj/CollObj/IntObjCollObjServer",
	["�����ɼ���Ʒ"] 	= "world/trigger_action/obj/CollObj/FbCollObj",
	["�����ɼ���ƷObj����"] 	= "world/trigger_action/obj/CollObj/IntObjCollObjServer",
	["�����ɼ���ƷObj��ʧ"] 	= "world/trigger_action/obj/CollObj/IntObjCollObjServer",
	["���������ɼ���ƷObj��ʧ"] 	= "world/trigger_action/obj/CollObj/IntObjCollObjServer",
	
	["�������ɼ���ƷObj��ʧ"] 	= "world/trigger_action/obj/CollObj/IntObjCollObjServer",
	["����������������"] 	= "world/trigger_action/obj/CollObj/IntObjPerfectCollServer",
	["������"] = "world/trigger_action/obj/BulletinBoard",
	["С��Ϸ"] = "smallgames/ObjSmallGameManager",
	["ħ��Ȫ"] = "world/trigger_action/obj/MoFaQuanObj/MoFaQuanObj",
	["���������"] = "world/trigger_action/obj/AddQuestCount",
	["������������Obj"] = "world/trigger_action/obj/AddQuestCount",
	["�ռ���Դ"] = "world/trigger_action/obj/CollectRes",
	["��ս������ѧϰ"] = "world/trigger_action/obj/LearnNoneFightSkill",
	---------��ս����Ϊ-------------
	--�ֲ���������
	["��"] = "world/trigger_action/obj/action/HandBehavior",
	["��"] = "world/trigger_action/obj/action/HandBehavior",
	["��"] = "world/trigger_action/obj/action/HandBehavior",
	--�Ų���������
	["������Obj����"] = "world/trigger_action/obj/action/FeetBehavior",
	["������Obj��ʧ"] = "world/trigger_action/obj/action/FeetBehavior",
	["С��Obj����"] = "world/trigger_action/obj/action/FeetBehavior",
	["С��Obj��ʧ"] = "world/trigger_action/obj/action/FeetBehavior",
	-----------------------------------
	["����"] = "world/trigger_action/obj/HeadFishingObj",
	["��սռ��"] = "world/trigger_action/obj/ChallengeOccupy",
	["��ʱ��ʰȡOBJ"] = "world/trigger_action/obj/CollectTempBag",
	["ˢ������NPC"] = "world/trigger_action/obj/CreateAwardNpc",
	["����������Դ��"] 	= "world/trigger_action/obj/RobResource",
	["���³Ǽ���"] = "world/trigger_action/obj/AreaFbTakeCount",
	["���������������"] 	= "world/trigger_action/obj/CollObj/IntObjCollObjServer",
}

--�������ȫ�ֱ�
--{[PlayerID] = {[ObjID] = Time, [ObjID1] = Time1}, [PlayerID1] = {[ObjID] = Time, [ObjID1] = Time1}}
g_NeedAssignTbls = {}
g_AcutionAssignTbls = {}
g_AcutionAssignTeamTbls = {}
RegMemCheckTbl("NeedAssignTbls", g_NeedAssignTbls)
RegMemCheckTbl("AcutionAssignTbls", g_AcutionAssignTbls)
RegMemCheckTbl("AcutionAssignTeamTbls", g_AcutionAssignTeamTbls)