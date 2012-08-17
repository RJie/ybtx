gas_require "world/tong_area/DynamicCreateMgr"
cfg_load "trigger/TriggerEvent_Server"

CTriggerScript = class()

function CTriggerScript:RunScriptByIndex(Index, Trigger, Player, Arg)
	local info = TriggerEvent_Server(tostring(Index))
	if not info then
--		print(Index.."��TriggerEvent_Server������")
		return {Index.."��TriggerEvent_Server������"}
	end
	local arg = GetCfgTransformValue(true, "TriggerEvent_Server", tostring(Index), "Arg")
	if Arg then	--��չargs
		for i=1, #arg do
			for index, value in pairs(Arg) do
				arg[i][index] = value
			end
		end
	end
	self:RunScript(info("Script"), arg, Trigger, Player)
end

function CTriggerScript:RunScript(TriggerAction, Arg, Trigger, Player)
	if not self.ScriptFun[TriggerAction] then
		CfgLogErr("�����ű���д���ִ���!", TriggerAction.." �����ű�������!")
		return
	end
	for i, v in pairs(Arg) do
		self.ScriptFun[TriggerAction](v, Trigger, Player)
	end	
end

function CTriggerScript:Ctor()

local AllScript =
{
	--ͨ�ýű�?
	["����"] = "world/trigger_action/trigger_script/CreateOnPos",
	["�Ի�"] = "world/trigger_action/trigger_script/DeleteMySelf",
	
	["�����糡"] = "world/trigger_action/trigger_script/TriggerTheater",
	["�糡����"] = "world/trigger_action/trigger_script/UnLockTheater",
	
	--["�����������"] = "world/trigger_action/trigger_script/AddQuestNum",
	["������������"] = "world/trigger_action/trigger_script/ActivationHideQuest",
	["���������"] = "world/trigger_action/trigger_script/DelClearObject",
	["������ʬ�帴��"] = "world/trigger_action/trigger_script/ReplaceAllObject",
	["�����õ���ʱ"] = "world/trigger_action/trigger_script/GameCountdownStart",
	["�رյ���ʱ"] = "world/trigger_action/trigger_script/GameCountdownOver",
	["����״̬"] = "world/trigger_action/trigger_script/SceneChangeState",
	["��������"] = "world/trigger_action/trigger_script/TriggerCountNpc",
	["��ʱ����"] = "world/trigger_action/trigger_script/TimeTriggerStart",
	["���ѡ��"] = "world/trigger_action/trigger_script/RandomSelect",
	["������̬�ڹ��ļ�"] = "world/trigger_action/trigger_script/CreateDynamicFile",
	
	["�����������"] = "world/trigger_action/trigger_script/TriggerPlayerDead",
	["�����¼�"] = "world/trigger_action/trigger_script/TriggerEvent",
	["����ҷ���Ϣ"] = "world/trigger_action/trigger_script/TriggerSendMsg",
	--["���þ���ʯ"] = "world/trigger_action/trigger_script/ResetResourceStone",
	["���ñ������������"] = "world/trigger_action/trigger_script/SetMatchGameText",
	["�ͷż���"] = "world/trigger_action/trigger_script/DoSkill",
	
	--Npcר���ű�
	
	["��Ӷ�̬·��"] = "world/trigger_action/npc_script/AddDynamicPath",
	["�����������̬·��"] = "world/trigger_action/npc_script/AddMercenaryDynamicPath",
	["�����Ӷ�̬·��"] = "world/trigger_action/npc_script/RandomAddDynamicPath",
	["�����������Ӷ�̬·��"] = "world/trigger_action/npc_script/YbEduRandomAddDynamicPath",
	["ѡȡ���·��"] = "world/trigger_action/npc_script/ChooseShortCut",
	["������ѡȡ���·��"] = "world/trigger_action/npc_script/YbEduChooseShortCut",
	
	["����Ŀ��"] = "world/trigger_action/npc_script/AimLock",
	["��ʱ����Ŀ��"] = "world/trigger_action/npc_script/DelayAimLock",
	["���ó���"] = "world/trigger_action/npc_script/SetDirection",
	["ռ��"] = "world/trigger_action/npc_script/Occupy",
	["С��Ϸ��̬ˢ��"] = "world/trigger_action/npc_script/CreateNpcByGame",
	["����ר�ýű�"] = "world/trigger_action/npc_script/CreateBossAndTrap",
	["����ƶ�"] = "world/trigger_action/npc_script/BornRandomMove",
	["ͷ��Ʈ��"] = "world/trigger_action/npc_script/PlayHeadEffect",
	["��ս����"] = "world/trigger_action/npc_script/ChallengeOver",
	["������"] = "world/trigger_action/npc_script/BuildingDropResource",
	["Npcפ�ؽ�����"] = "world/trigger_action/npc_script/StationNpcDropResource",
	
	["�л���������"] = "world/trigger_action/npc_script/ChangeBackgroundMusic",
	["��ԭ��������"] = "world/trigger_action/npc_script/RevertBackgroundMusic",
	
	--��Player������¿ɴ���
	--["����"] = "�����ű�,�ͻ����Ѿ���ס������",
	["С��Ϸ"] = "smallgames/NpcSmallGameManager",
	["��"] = "world/trigger_action/trigger_script/Cuddle",
	["�����Ʒ"] = "world/trigger_action/trigger_script/GetItem",
	["�滻"] = "world/trigger_action/trigger_script/ReplaceSelf",
	["��Ӫ�滻"] = "world/trigger_action/trigger_script/ReplaceByCamp",
	
	["�����Ź�"] = "world/trigger_action/trigger_script/AddTongProffer",
	["����"] = "world/trigger_action/trigger_script/Transport",
	--["С�����Ӽ���"] = "world/trigger_action/trigger_script/SmallFbAddNum",
	["��Trap������"] = "world/trigger_action/trigger_script/TriggerPlayerAward",
	--["��buff��Trap�ӻ����"] = "world/trigger_action/trigger_script/AddNumByBuff",
	["��Trap�ı�����״̬"] = "world/trigger_action/trigger_script/InChangeBoxState",
	["��Trap�ı�����״̬"] = "world/trigger_action/trigger_script/OutChangeBoxState",
	["������ֵ"] = "world/trigger_action/trigger_script/TriggerAddHp",
	["�Ӽ���"] = "world/trigger_action/trigger_script/AddNumByType",
	["��ռҰ�⸴���"] = "world/trigger_action/trigger_script/RobRebornPlace",
	["ɾ��"] = "world/trigger_action/trigger_script/TriggerDelete",
	["���͵�ָ��λ��"] = "world/trigger_action/trigger_script/TransSamePos",
	["ָ����"] = "world/trigger_action/trigger_script/TriggerCompass",
	["��Ѩ�"] = "world/trigger_action/npc_script/DragonCaveBossDead",

}
	self.ScriptFun = {}
	AddCheckLeakFilterObj(self.ScriptFun)
	self.ScriptFun["ֹͣ����"] = function(Arg, Trigger) Trigger.m_StopTrigger= true end
	for ScriptName,fileName in pairs(AllScript) do
		self.ScriptFun[ScriptName] = gas_require (fileName)
		assert(IsFunction(self.ScriptFun[ScriptName]), fileName.." �ļ��к�������ȷ")
	end
end
