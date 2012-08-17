-- yy 09 05 14 

local ChannelID = ChannelIdTbl["NPC"]

--NPCֻ�������¼���Ƶ��˵��
local ChannelIdTbl = {
	["ϵͳ"] = 1, --"ϵͳ"
	["����"] = 2, --"����"
	["��ͼ"] = 4, --"��ͼ"
	["����"] = 5, --"����"
}

local ChannelConnTbl = {
	[1] = function () return g_AllPlayerSender end, --"ϵͳ"
	[2] = function () return g_AllPlayerSender end, --"����"
	[4] = function (Npc) return Npc.m_Scene.m_CoreScene end, --"��ͼ"
	[5] = function (Npc) return Npc:GetIS(0) end, --"����"
	[9] = function (Npc) return Npc:GetIS(0) end, --"NPC"
}

--�õ����õĸ���
local function RandomIsShow(ContentCfg)
	local TriggerProbability = 0
	local Arg = ContentCfg.Arg
	local rate = Arg
	if IsTable(Arg) then
		rate = Arg[2]
	end
	rate = tonumber(rate)
	if not IsNumber(rate) or rate == 1 then
		return true
	end
	return (math.random(1,100)) <= (rate*100)
end

local function TalkingInBattling(Tick, Npc,ContentCfg,NpcEntityID, NpcName)
	if RandomIsShow(ContentCfg) then
		if IsCppBound(Npc) then
			local ContentTbl = ContentCfg["ContentTbl"]
			local Info = math.random(1,table.maxn(ContentTbl))
			if not ContentCfg.Channel or ContentCfg.Channel == "" then
				return
			end
			for _, ChannelTbl in pairs(ContentCfg.Channel) do
				for _, Channel in pairs(ChannelTbl) do
					local SendId = ChannelIdTbl[Channel] or ChannelID
					Gas2Gac:RetShowTextNpc( ChannelConnTbl[SendId](Npc), NpcEntityID, NpcName, SendId, Info, 5)
				end
			end
		end
	end
end

--NPC  ����ʱ��ʾ�Ի�
local function BornShow( Npc, NpcName, ContentCfg, NpcEntityID, SkillName)
	if RandomIsShow(ContentCfg) then
		local function tickfun()
			local ContentTbl = ContentCfg["ContentTbl"]
			local Info = math.random(1,table.maxn(ContentTbl))
			if not ContentCfg.Channel or ContentCfg.Channel == "" then
				return
			end
			for _, ChannelTbl in pairs(ContentCfg.Channel) do
				for _, Channel in pairs(ChannelTbl) do
					local SendId = ChannelIdTbl[Channel] or ChannelID
					Gas2Gac:RetShowTextNpc( ChannelConnTbl[SendId](Npc), NpcEntityID, NpcName, SendId, Info, 1)
				end
			end
		end
		RegisterOnceTick(Npc, "BornShowContentTick", tickfun, 300)
	end
end 

--NPC  ����ʱ��ʾ�Ի�
local function DeadShow( Npc, NpcName, ContentCfg, NpcEntityID, SkillName)
	if RandomIsShow(ContentCfg) then
		local ContentTbl = ContentCfg["ContentTbl"]
		local Info = math.random(1,table.maxn(ContentTbl))
		if not ContentCfg.Channel or ContentCfg.Channel == "" then
			return
		end
		for _, ChannelTbl in pairs(ContentCfg.Channel) do
			for _, Channel in pairs(ChannelTbl) do
				local SendId = ChannelIdTbl[Channel] or ChannelID
				Gas2Gac:RetShowTextNpc( ChannelConnTbl[SendId](Npc), NpcEntityID, NpcName, SendId, Info, 2)
			end
		end
	end
end
 
--NPC  ����ս����ʾ�Ի�
local function LeaveBattleState( Npc, NpcName, ContentCfg, NpcEntityID, SkillName)
	if RandomIsShow(ContentCfg) then
		local ContentTbl = ContentCfg["ContentTbl"]
		local Info = math.random(1,table.maxn(ContentTbl))
		if not ContentCfg.Channel or ContentCfg.Channel == "" then
			return
		end
		for _, ChannelTbl in pairs(ContentCfg.Channel) do
			for _, Channel in pairs(ChannelTbl) do
				local SendId = ChannelIdTbl[Channel] or ChannelID
				Gas2Gac:RetShowTextNpc( ChannelConnTbl[SendId](Npc), NpcEntityID, NpcName, SendId, Info, 4)
			end
		end
	end
end

--NPC���ͷż��� ��ʾ�Ի�
local function DoSkill( Npc, NpcName, ContentCfg, NpcEntityID, SkillName, TargetID)
	if SkillName == nil or SkillName == "" then
		return
	end
	NpcShowContent( "���ܾ�����ʾ", Npc, SkillName, TargetID)
	if ContentCfg[SkillName] then
		local ContentTbl = ContentCfg[SkillName]["ContentTbl"]
		local Info = math.random(1,table.maxn(ContentTbl))
		if ContentCfg[SkillName].Channel and ContentCfg[SkillName].Channel ~= "" then
			for _, ChannelTbl in pairs(ContentCfg[SkillName].Channel) do
				for _, Channel in pairs(ChannelTbl) do
					local SendId = ChannelIdTbl[Channel] or ChannelID
					Gas2Gac:NpcDoSkillTalk( ChannelConnTbl[SendId](Npc), NpcEntityID, NpcName, SendId, Info, SkillName)
				end
			end
		end
	end
	return
end

local function CheckReplaceStr(Content, Replace, TargetID)
	if not TargetID then
		return
	end
	local Char = CCharacterDictator_GetCharacterByID(TargetID)
	if not IsCppBound(Char) then
		return
	end
	if not IsPlayer(Char) then
		return
	end
	if Replace == "#name#" then
		return Char.m_Properties:GetCharName()
	end
end

--NPC�����ܾ�����ʾ
local function DoSkillAdvise( Npc, NpcName, ContentCfg, NpcEntityID, SkillName, TargetID)
	
	if SkillName == nil or SkillName == "" then
		return
	end
	if ContentCfg[SkillName] then
		local ContentTbl = ContentCfg[SkillName]["ContentTbl"]
		local index = math.random(1,table.maxn(ContentTbl))
		local Content = ContentTbl[index][1]
		local replaceStr = ContentCfg[SkillName]["Replace"][index]
		if not ContentCfg[SkillName].Channel or ContentCfg[SkillName].Channel == "" then
			return
		end
		if replaceStr then
			local Str = CheckReplaceStr(Content, replaceStr, TargetID)
			if Str then
				for _, ChannelTbl in pairs(ContentCfg[SkillName].Channel) do
					for _, Channel in pairs(ChannelTbl) do
						local SendId = ChannelIdTbl[Channel] or ChannelID
						Gas2Gac:NpcDoSkillAdviseRepl( ChannelConnTbl[SendId](Npc), NpcName, index, SkillName, replaceStr, Str)
					end
				end
			end
		else
			for _, ChannelTbl in pairs(ContentCfg[SkillName].Channel) do
				for _, Channel in pairs(ChannelTbl) do
					local SendId = ChannelIdTbl[Channel] or ChannelID
					Gas2Gac:NpcDoSkillAdvise( ChannelConnTbl[SendId](Npc), NpcName, index, SkillName)
				end
			end
		end
	end
	return
end

--NPC  ս����˵��TICK
local function RegisterTalkingInBattling( Npc, NpcName, NpcEntityID, NpcOperation)
	local BattlingCfg = g_NpcShowContentCfg[NpcName] and g_NpcShowContentCfg[NpcName]["ս����"]
	if not BattlingCfg then
		return
	end
	
	if Npc.BattlingTick then
		UnRegisterTick(Npc.BattlingTick )
		Npc.BattlingTick  = nil
		if NpcOperation == "����ս��" or NpcOperation == "����" then
			return
		end
	else
		if NpcOperation ~= "����ս��" then
			return
		end
	end
	
	local Arg = BattlingCfg.Arg
	local TickTime = 5000
	if IsNumber(Arg[1]) then
		TickTime = Arg[1]
	end
	Npc.BattlingTick = RegisterTick("BattlingTick",	TalkingInBattling, TickTime, Npc, BattlingCfg,NpcEntityID, NpcName)	
end

--NPC  ����ս����ʾ�Ի�
local function EntryBattleState( Npc, NpcName, ContentCfg, NpcEntityID, SkillName)
	if not IsCppBound(Npc) or not Npc:CppIsLive() then
		return
	end
	if RandomIsShow(ContentCfg) then
		local ContentTbl = ContentCfg["ContentTbl"]
		local info = math.random(1,table.maxn(ContentTbl))
		if not ContentCfg.Channel or ContentCfg.Channel == "" then
			return
		end
		for _, ChannelTbl in pairs(ContentCfg.Channel) do
			for _, Channel in pairs(ChannelTbl) do
				local SendId = ChannelIdTbl[Channel] or ChannelID
				Gas2Gac:RetShowTextNpc( ChannelConnTbl[SendId](Npc), NpcEntityID, NpcName, SendId, info, 3)
			end
		end
	end
end

local g_Operation =
{
	["����"] = BornShow,
	["����"] = DeadShow,
	["����ս��"] = EntryBattleState,
	["����ս��"] = LeaveBattleState,
	["�ͷż���"] = DoSkill,
	["���ܾ�����ʾ"] = DoSkillAdvise
}

--���뺯����  
function NpcShowContent( NpcOperation, Npc, SkillName, TargetID)
	
	local NpcName = Npc.m_Properties:GetCharName()   -- NpcName
	
	local cfg = g_NpcShowContentCfg[NpcName] 
	local ContentCfg = cfg and cfg[NpcOperation]
	local NpcEntityID = Npc:GetEntityID()
	RegisterTalkingInBattling( Npc, NpcName, NpcEntityID, NpcOperation)
	
	if not ContentCfg then
		return
	end
	if ContentCfg.Arg == 10 then
		local sMsg = ContentCfg.ShowContext
		if sMsg ~= nil and sMsg ~= "" then
			ShowContentToAllPlayer(sMsg)
		end
		return
	end
	
	g_Operation[NpcOperation]( Npc, NpcName, ContentCfg, NpcEntityID, SkillName, TargetID)
end

function ShowContentToAllPlayer(sMsg)
	CChatChannelMgr.SendMsg(sMsg, 0, 1)
	Gas2Gac:SysMovementNotifyToClient(g_AllPlayerSender, sMsg)
end

