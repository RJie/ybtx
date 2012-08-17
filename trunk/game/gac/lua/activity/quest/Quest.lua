gac_gas_require "relation/tong/TongMgr"
cfg_load "npc/NotFunNpcTypeMap"
--cfg_load "player/MercenaryLevel_Common"
cfg_load "npc/SubFunOnMiddleMap_Common"

g_QuestGiverGlobalID = {}
g_QuestFinishGlobalID = {}
AutoTrackColorStr = "#c"..g_ColorMgr:GetColor("�Զ�Ѱ·")

CQuest = class()

local firstQuest = {
	["��Ӷ��֮·�����ף�"] = true,
	["��Ӷ��֮·����ʥ��"] = true,
	["��Ӷ��֮·����˹��"] = true,
}

local smallYbQuest = {
	["�µ�Ӷ������"] = true,
	["�µ�����ƪ��"] = true,
	["�ɳ��ĵ�·"] = true,
}
local GLevelQuest = {
	["ǰ��ϣ����"] = true,
	["ǰ����ѧѵ����"] = true,
	["ǰ�����Ͽ�"] = true,
}

local function CheckMercenaryLevelStatus(QuestName)
	if g_GameMain.m_MercenaryLevelTrace.m_MercenLevState --��û�����ֵ��ʱ�򣬴��ж���Ч
		and g_MercenaryLevelTbl[g_MainPlayer.m_uMercenaryLevel]
		and g_MercenaryLevelTbl[g_MainPlayer.m_uMercenaryLevel]["��ս����"].Subject == "��ս����" then
			local NameTbl = g_MercenaryLevelTbl[g_MainPlayer.m_uMercenaryLevel]["��ս����"].Arg
			local Camp = g_MainPlayer:CppGetBirthCamp()
			local Status = g_GameMain.m_MercenaryLevelTrace.m_MercenLevState.m_State
			if QuestName==NameTbl[Camp] and Status~=2 then
				return false
			end
	end
	return true
end

--�ж������Ƿ�ɽ�
local function CheckQuestAvavilable(QuestName, NotCheckMap)
	--�ж���ҵ�ǰ���ڵ�ͼ�Ƿ���ȷ
	if not NotCheckMap then
		if IfAcceptQuestMap(g_GameMain.m_SceneName,QuestName) == false then
			return false
		end
	end
	
	local QuestNode = Quest_Common(QuestName)
	--��������
	if QuestNode("��������") == 9 then
		return false
	end
	
	if g_GameMain.m_MercenaryLevelTrace.m_IsCheckIn then
		return false
	end
	
	--������������ж�yy
	if g_HideQuestMgr[QuestName] then
		if g_GameMain.m_QuestRecordWnd.g_QuestHide[QuestName] ~= QuestName then
			return false
		end
	end
	
	if g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[QuestName] ~= nil then  --�����б��Ѿ��и�����
		if g_RepeatQuestMgr[QuestName] then
			if g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[QuestName].m_State ~= QuestState.finish then
				return false, 3052, {g_GetLanQuestName(QuestName)}  --����Ϊ���
			end
		else
			return false --���񲻿��ظ���ȡ!
		end
	end
	
	--local mutexQuestTbl = GetCfgTransformValue(true, "Quest_Common", QuestName, "�����ϵ")
	--if mutexQuestTbl then
	--	for i = 1,table.getn(mutexQuestTbl) do
	--		if g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[mutexQuestTbl[i]] then
	--			local q_state = g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[mutexQuestTbl[i]].m_State 
	--			if q_state ~= nil then 
	--			return false	--"���񻥳�"
	--		end
	--	end
	--end
	
	--�ж�ǰ������(�����,������)
	if QuestNode("ǰ������") then
		local Keys = QuestNode:GetKeys("ǰ������")
		local IsAvailable = true
		local IsEffective = false
		for i = 1,table.getn(Keys) do
			local Subject = QuestNode("ǰ������", Keys[i], "Subject")
			local Arg = QuestNode("ǰ������", Keys[i], "Arg")
			if Subject ~= "" then
				IsEffective = true
				if g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[Subject] then
					local pre_state = g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[Subject].m_State
					if Arg == "�����" and pre_state ~= QuestState.finish then
						IsAvailable = false
					elseif Arg == "������" and pre_state ~= QuestState.finish and pre_state ~= QuestState.init then
						IsAvailable = false
					end
				else
					IsAvailable = false
				end
			end
		end
		if IsEffective and not IsAvailable then
			return false
		end
	end
	
	if QuestNode("����ǰ��������һ") then
		local Keys = QuestNode:GetKeys("����ǰ��������һ")
		local IsAvailable = false
		local IsEffective = false
		for i = 1,table.getn(Keys) do
			local Subject = QuestNode("����ǰ��������һ", Keys[i], "Subject")
			local Arg = QuestNode("����ǰ��������һ", Keys[i], "Arg")
			if Subject ~= "" then
				IsEffective = true
				if g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[Subject] then
					local pre_state = g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[Subject].m_State
					if Arg == "�����" and pre_state == QuestState.finish then
						IsAvailable = true
						break
					elseif Arg == "������" and pre_state ~= QuestState.failure then
						IsAvailable = true
						break
					end
				end
			end
		end
		if IsEffective and not IsAvailable then
			return false
		end
	end
	
	if smallYbQuest[QuestName] then
		if g_MainPlayer.m_uMercenaryLevel < 1 then
			return false
		end
	end
	if GLevelQuest[QuestName] then
		if g_MainPlayer.m_uMercenaryLevel < 2 then
			return false
		end
	end
	--�ж������Ƿ������������Ӫ����
	if not IfAcceptQuestCamp(g_MainPlayer ,QuestName) then
		return false, 3069
	end
	--�ж������Ƿ����������ְҵ����
	if not IfAcceptQuestClass(g_MainPlayer ,QuestName) then
		return false
	end
	
	if QuestNode("��������ʽ", "Subject") == "Npc" then
		local NpcName = QuestNode("��������ʽ", "Arg")
		local NpcCamp = Npc_Common(NpcName,"Camp")
		if not IsPasserbyCamp(NpcCamp, g_MainPlayer:CppGetBirthCamp(), 0, g_MainPlayer:CppGetGameCamp()) then
			return false
		end
	end
	
	--�ж������Ƿ����������ĵȼ�����
	if not IfAcceptQuestMinLev(g_MainPlayer ,QuestName) then
		return false, 3070
	end
	if not IfAcceptQuestMaxLev(g_MainPlayer ,QuestName) then
		return false, 300023
	end
	--�ж��Ƿ�Ӷ���ȼ�ָ������ս�����Լ�Ӷ���ȼ�״̬
	--if not CheckMercenaryLevelStatus(QuestName) then
	--	return false
	--end
	--�ж��Ƿ�����Ӷ��������
	if QuestNode("Ӷ��������") and QuestNode("Ӷ��������") ~= 0 then
		local TongId = g_MainPlayer.m_Properties:GetTongID()
		if TongId == 0 then
			return false
		end
	end
	--�ж��Ƿ�����Ӷ�����ų�����
	if QuestNode("Ӷ�����ų�����") == 1 then
		if g_GameMain.m_TongBase.m_TongPos ~= g_TongMgr.m_tblPosInfo["�ų�"] then
			return false
		end
	end
	
	--������ϲ���ͬʱ��2������ͬ1��ϵ���ܻ�����
	if QuestNode("��������") == 10 then
		local tbl = GetCfgTransformValue(true, "Quest_Common", QuestName, "������", "1")
		if g_GameMain.m_QuestRecordWnd.m_LoopTbl[tbl[1]] then
			return false
		end
	end
	
	return true
end

--�ж������Ƿ����
local function CheckCanFinishQuest(QuestName)
	if not Quest_Common(QuestName) then
		return false
	end	
	--�ж���ҵ�ǰ���ڵ�ͼ�Ƿ���ȷ
	if IfFinishQuestMap(g_GameMain.m_SceneName, QuestName) == false then
		return false
	end
	if g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[QuestName] == nil then
		return
	end
	local queststate = g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[QuestName].m_State
	local playerquestvar = g_GameMain.m_QuestRecordWnd.m_DoingQuestInfo[QuestName]
	if queststate == nil or playerquestvar==nil then
		return false
	elseif queststate == QuestState.finish then
		return false
	elseif queststate == QuestState.failure then
		return false 
	else
		for varname, v in pairs(playerquestvar) do
			if v.DoNum<v.NeedNum then
				return false
			end
		end
	end
	return true
end

--��Goods��������
local function OnRClickQuestItem(Conn,uBigID,uIndex)
	if (uBigID == 16 or uBigID == 1) and g_WhereGiveQuestMgr["Goods"][uIndex] then
		local QuestName = g_WhereGiveQuestMgr["Goods"][uIndex][1]
		if g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[QuestName] then
			if g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[QuestName] == QuestState.finish
			 	and not g_RepeatQuestMgr[QuestName] then
			 	--��������ɣ������ظ���ȡ
			 	MsgClient(3025)
				return   --����Ϊ���
			end
		end
		
		local IsTrue,MsgID,Msg = CheckQuestAvavilable(QuestName)
		if IsTrue then
			g_GameMain.m_takeTask:ShowTakeQuestWnd(QuestName)
			return
		else
			if MsgID then
				if Msg then
					MsgClient(MsgID, unpack(Msg))
				else
					MsgClient(MsgID)
				end
			end
		end
	end
	--Gac2Gas:ClickItem(g_Conn, uIndex) --�ظ�ʹ����...��g_GacUseItem�Ѿ�����
end

--��NPC��ObjΪĿ���ѯ������ ������������tbl
local function QueryQuest(sType,sName,uTargetID)
	local result = {} 
	if not g_WhereGiveQuestMgr[sType][sName] then
		return result
	end
	for i,QuestName in pairs(g_WhereGiveQuestMgr[sType][sName]) do
		if CheckQuestAvavilable(QuestName) then
			table.insert(result, QuestName)		
			if g_QuestGiverGlobalID[QuestName]==nil then
				g_QuestGiverGlobalID[QuestName]={}
				g_QuestGiverGlobalID[QuestName].GiverGlobalID=uTargetID
			else
				g_QuestGiverGlobalID[QuestName].GiverGlobalID=uTargetID
			end
		end
	end
	return result
end

--��NPC��ObjΪĿ���ѯ�Ѿ���ɵ����� ������������tbl
local function QueryFinishQuest(sType,sName,uTargetID)
	local result = {}
	if not g_WhereFinishQuestMgr[sType][sName] then
		return result
	end
	for i,QuestName in pairs(g_WhereFinishQuestMgr[sType][sName]) do
		if CheckCanFinishQuest(QuestName) then
			table.insert(result, QuestName)	
			if g_QuestFinishGlobalID[QuestName]==nil then
				g_QuestFinishGlobalID[QuestName]={}
				g_QuestFinishGlobalID[QuestName].FinishGlobalID=uTargetID
			else
				g_QuestFinishGlobalID[QuestName].FinishGlobalID=uTargetID
			end
		end
	end
	return result
end

local function CheckIsHaveContinualQuest(sType,sName)
	local ViewObjTbl = g_GameMain.m_NpcHeadSignMgr.m_SeeNpcAndObjTbl
	if sType == "Npc" then
		for i,uEntityID in pairs(ViewObjTbl) do
			local NpcObj = CCharacterFollower_GetCharacterByID(uEntityID)
			if NpcObj then
				local CharName = NpcObj.m_Properties:GetCharName()
				if CharName == sName
					and (#(QueryQuest(sType,sName,uEntityID)) > 0 
					or #(QueryFinishQuest(sType,sName,uEntityID)) > 0) then
					g_MainPlayer:LockObj( NpcObj )
					g_MainPlayer:OnLButtonClickObj(NpcObj)
					
					if g_GameMain.m_NpcDlg.m_ShowDlgListWnd then
						g_MainPlayer.m_IsShowListWnd = true
					end
					return
				end
			end
		end
	elseif sType == "Obj" then
		for i,uEntityID in pairs(ViewObjTbl) do
			local IntObjClient = CIntObjClient_GetIntObjByID(uEntityID)
			if IntObjClient then
				local CharName = IntObjClient.m_Properties:GetCharName()
				if CharName == sName
					and (#(QueryQuest(sType,sName,uEntityID)) > 0 
					or #(QueryFinishQuest(sType,sName,uEntityID)) > 0) then
					g_MainPlayer:LockIntObj( IntObjClient )
					g_MainPlayer:OnLButtonClickObj(IntObjClient)
					
					if g_GameMain.m_NpcDlg.m_ShowDlgListWnd then
						g_MainPlayer.m_IsShowListWnd = true
					end
					return
				end
			end
		end
	end
end

local function CountAddExpAndSoulNum(PlayerLevel,PlayerYbLevel,QuestName)
	local questExp   = 0
	local questSoul  = 0
	if Quest_Common(QuestName, "���齱��") then
		--local Coefficient = Quest_Common(QuestName, "���齱��", "HyperLink")
		--if not IsNumber(Coefficient) then
		--	Coefficient = 1
		--end
		local str = Quest_Common(QuestName, "���齱��", "Subject")
		if str and str ~= "" then
			questExp = g_ReturnSentenceParse(str, QuestName)
		end
		
		str = Quest_Common(QuestName, "���齱��", "Arg")
		if str and str ~= "" then
			questSoul = g_ReturnSentenceParse(str, QuestName)
		end
		
		if g_MasterStrokeQuestMgr[QuestName] then
			local QuestLevel = g_RetNoneMercSentenceParse(Quest_Common(QuestName, "����ȼ�"))
			QuestLevel = (QuestLevel~=0 and QuestLevel) or 1
			if PlayerLevel - QuestLevel >= 3 then
				questExp = questExp*0.5
			end
		end
	end
	
	questExp = math.floor(questExp)
	questSoul = math.floor(questSoul)
	return questExp,questSoul
end

--��ÿ��Եõ���Ӷ������ֵ
local function CountAddMercenaryIntegralNum(PlayerLevel,PlayerYbLevel,QuestName)
	if not g_AllMercenaryQuestMgr[QuestName] then
		return 0
	end
	
	local questMercenaryIntegral = 0
	local strIntegral = Quest_Common(QuestName, "Ӷ�����ֽ���")
	if strIntegral then
		if strIntegral ~= "" then
			questMercenaryIntegral = g_ReturnSentenceParse(strIntegral, QuestName)
		end
	--	local MinLevel = Quest_Common(QuestName, "��������СӶ���ȼ�")
	--	if MinLevel and MinLevel ~= "" then
			--for i=1, #(MercenaryLevel_Common) do
			--	if MercenaryLevel_Common[i].MercenaryLevel == MinLevel then
			--		Level = i
			--		break
			--	end
			--end
			--if (PlayerYbLevel - Level) >= 2 then
			--	questMercenaryIntegral = 0
			--end
	--	end
	end
	return questMercenaryIntegral
end

function CountMasterStrokeQuest()
	local QuestStateTbl = g_GameMain.m_QuestRecordWnd.m_QuestStateTbl
	local count = 0
	for QuestName, v in pairs(QuestStateTbl) do
		if v.m_State == QuestState.finish and g_MasterStrokeQuestMgr[QuestName] then
			count = count + 1
		end
	end
	return count
end

--�жϸ�Npc��Obj���� �Ƿ��й���(�������)
local function IsObjectContainFun(Target)
	if not Target then
		return
	end
	
	local TargetName = Target.m_Properties:GetCharName()
	local sType = nil
	local nType = Target.m_Properties:GetType()
	if nType == ECharacterType.Npc then
		if Target:GetNpcType() == ENpcType.ENpcType_Summon then return end --�ٻ���
		sType = "Npc"
	elseif nType == ECharacterType.IntObj then
		sType = "Obj"
	else
		return
	end
	
	if g_WhereGiveQuestMgr[sType][TargetName] then
		for i,QuestName in pairs(g_WhereGiveQuestMgr[sType][TargetName]) do
			if CheckQuestAvavilable(QuestName) then
				return true
			end
		end
	end
	
	if g_WhereFinishQuestMgr[sType][TargetName] then
		for i,QuestName in pairs(g_WhereFinishQuestMgr[sType][TargetName]) do
			local queststatetbl = g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[QuestName]
			if  queststatetbl and queststatetbl.m_State == QuestState.init then
				return true
			end
		end
	end
	
	if sType == "Npc" then
		if g_NpcShowContentCfg[TargetName]
			and g_NpcShowContentCfg[TargetName].ShowContext ~= "" then
			return true
		end
		local funcnametbl = Npc_Common(TargetName,"FuncName")
		if funcnametbl ~= "" then
			funcnametbl = loadstring("return {" .. funcnametbl.."}")()
			
			if ( type(funcnametbl[1]) == "table" ) then
				funcnametbl = funcnametbl[1]
			end
			
			for i = 1,#(funcnametbl) do
				local funcname = funcnametbl[i]
				if funcname == "����NPC" or funcname == "����NPC" then
					return true
				end
				local funindex = CNpcDialogBox.DlgTextType[funcname]
				if funindex~=nil and funindex>=2 then
					return true
				end
			end
		end
	elseif sType == "Obj" then
		local TriggerAction = IntObj_Common(TargetName, "TriggerAction")
		if TriggerAction ~= "" then
			if TriggerAction == "��ս������ѧϰ"
				or TriggerAction == "����Obj"
				or TriggerAction == "Ӷ�������"
				or TriggerAction == "С��Ϸ" then
					return true
			end
		end
	end
	return false
end

local function GetFuncNameByNpcName(NpcName)
	local NpcCfg = Npc_Common(NpcName)
	if not NpcCfg then
		return nil
	end
	
	if g_WhereFinishQuestMgr["Npc"][NpcName] ~= nil then
		for i,p in pairs(g_WhereFinishQuestMgr["Npc"][NpcName]) do
			if CheckCanFinishQuest(p) then		--���������ɸ����������
				return "�������"  --���ڴ�Npc���ύ����
			end
		end
	end
	
	if g_WhereGiveQuestMgr["Npc"][NpcName] ~= nil then
		for i,p in pairs(g_WhereGiveQuestMgr["Npc"][NpcName]) do
  			if CheckQuestAvavilable(p) then		--���������ܸ����������
  				return "��ȡ����"  --���ڴ�Npc����ȡ����
  			end
		end
	end
	
	if g_WhereFinishQuestMgr["Npc"][NpcName] ~= nil then
		for i,p in pairs(g_WhereFinishQuestMgr["Npc"][NpcName]) do
			if g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[p] then
				local state = g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[p].m_State
				--�ж���ҵ�ǰ���ڵ�ͼ�Ƿ���ȷ
				if state == QuestState.init then
					return "���������"	--����������ڽ����е���δ�����ύ
				end
			end
		end
	end

	local FuncNameTbl = Npc_Common(NpcName,"FuncName")
	local IconType		= Npc_Common(NpcName,"IconType")		-- ������Դ����
	local FuncName = "��"
	if FuncNameTbl ~= "" then
		FuncNameTbl = loadstring("return {" .. FuncNameTbl.."}")()
		
		if( type(FuncNameTbl[1]) == "table" ) then
			FuncNameTbl = FuncNameTbl[1]
		end
		
		FuncName = FuncNameTbl[1]
	end
	if FuncName == "����NPC" then--�ȼ�������Ҫ�󣬲��ܽ����񣬵�����ͨnpc
		return -1
	end

	if not NotFunNpcTypeMap(FuncName)  then
		LogErr("����û���ڱ�NotFunNpcTypeMap����д",FuncName)
	end
	local npcType = tonumber(NotFunNpcTypeMap(FuncName, "NpcTypeInSmallMapShow") )
	
	local TexSrc = nil
	if IconType ~= "" and SubFunOnMiddleMap_Common(IconType) then			-- IconType�� �� TexSrc�� ����
		TexSrc = SubFunOnMiddleMap_Common(IconType, "TexSrc")		
	end
	if not TexSrc and NotFunNpcTypeMap(FuncName) then
		TexSrc = NotFunNpcTypeMap(FuncName, "TexSrc")
	end
	return npcType, TexSrc
end

--local function SpanSceneAutoTrack(PointName,SceneName,x,y)
--	local sFile = Scene_Common[g_GameMain.m_SceneName].NpcSceneFile
--	if not g_BetweenSceneTransportTrapPos[sFile]
--		or g_BetweenSceneTransportTrapPos[sFile][SceneName] then
--		return
--	end
--	local playerpos = CPos:new()
--	g_MainPlayer:GetGridPos(playerpos)
--end
--
--function PlayerAutoTrack(PointName,SceneName,x,y)
--	if SceneName ~= g_GameMain.m_SceneName then
--		SpanSceneAutoTrack(PointName,SceneName,x,y)
--	else
--		QuestAutoTrack(PointName,x,y)
--	end
--end

--function CQuest:GetAvaliableMasterStrokeQuestByName(QuestName)
function CQuest.GetAvaliableMasterStrokeQuestByName(QuestName)
	local Type = Quest_Common(QuestName, "��������ʽ", "Subject")
	local HyperLink = Quest_Common(QuestName, "��������ʽ", "HyperLink")
	local RealName = Quest_Common(QuestName, "��������ʽ", "Arg")
	local SceneName = QuestPos_Common(HyperLink, "SceneName")
	local PosX = QuestPos_Common(HyperLink, "PosX")
	local PosY = QuestPos_Common(HyperLink, "PosY")
	local ShowName = ""
	if Type == "Npc" then
		ShowName = GetNpcDisplayName(RealName)
	elseif Type == "Obj" then
		ShowName =  GetIntObjDispalyName(RealName)
	end
	return {RealName, SceneName, PosX, PosY, g_GetLanQuestName(QuestName), ShowName, QuestLev}
end

--function CQuest:GetAvaliableMasterStrokeQuests(LevelDiff)
function CQuest.GetAvaliableMasterStrokeQuests(LevelDiff)
	local PlayerLev = g_MainPlayer:CppGetLevel()
	local minLev = PlayerLev - LevelDiff
	minLev = (minLev >= 1) and minLev or 1
	
	local tbl = {}
	local function InsertQuestInfo(QuestName, QuestLev)
		if g_HideQuestMgr[QuestName] or Quest_Common(QuestName, "��������ʽ", "Subject") == "Goods" then
			return
		end
		local tblInfo = CQuest.GetAvaliableMasterStrokeQuestByName(QuestName)
		table.insert(tbl, tblInfo)
	end
	
	for i=minLev, PlayerLev do
		if g_MasterStrokeQuestLevTbl[i] then
			for QuestName, _ in pairs(g_MasterStrokeQuestLevTbl[i]) do
				if CheckQuestAvavilable(QuestName, true) then
					InsertQuestInfo(QuestName, i)
				end
			end
		end
	end
	for QuestName, LevelStr in pairs(g_MasterStrokeQuestLevTbl["DynamicLev"]) do
		local level = g_ReturnSentenceParse(LevelStr, QuestName)
		if level >= minLev and level <= PlayerLev and CheckQuestAvavilable(QuestName, true) then
			InsertQuestInfo(QuestName, level)
		end
	end
	
	return tbl
end

--function CQuest:GetLoopQuestState()
function CQuest.GetLoopQuestState()
	local tbl = {}
	for LoopName, v in pairs(g_LoopQuestMgr) do
		local FirstQuestName = v[1][1].QuestName
		local MaxLoopNum = table.maxn(v)
		local LoopNum = g_GameMain.m_QuestRecordWnd.m_LoopTbl[LoopName] or 0
		local Level = g_ReturnSentenceParse(Quest_Common(FirstQuestName, "����ȼ�"), FirstQuestName)
		if LoopNum ~= 0 or CheckQuestAvavilable(FirstQuestName, true) then
			table.insert(tbl, {LoopName, LoopNum, MaxLoopNum, Level})
		end
	end
	return tbl
end

----------------------------------------------------------------------

--�������԰�
local function LoadLanAllQuestCfg()
	local tbl = {}
	for i=1, 3 do
		table.insert(tbl,"quest/Lan_QuestAll_CommonA"..i)
		table.insert(tbl,"quest/Lan_QuestAll_CommonB"..i)
		table.insert(tbl,"quest/Lan_QuestAll_CommonC"..i)
	end
	
	table.insert(tbl,"quest/Lan_CallBack_Quest_Common")
	table.insert(tbl,"quest/Lan_ZhiYin_Quest_Common")
	
	table.insert(tbl,"quest/Lan_Hide_Quest_Common")
	table.insert(tbl,"quest/Lan_TreeBar_Quest_Common")
	table.insert(tbl,"quest/Lan_HeYangDaCaoYuan_Quest_Common")
	table.insert(tbl,"quest/Lan_ShengXueShan_Quest_Common")
	table.insert(tbl,"quest/Lan_ShiZiHeGu_Quest_Common")
	table.insert(tbl,"quest/Lan_XiLinDao_Quest_Common")
	table.insert(tbl,"quest/Lan_MercenaryQuest_Direct_Common")
	table.insert(tbl,"quest/Lan_MercenaryQuest_XiLinDao_CommonA")
	table.insert(tbl,"quest/Lan_MercenaryQuest_XiLinDao_CommonB")
	table.insert(tbl,"quest/Lan_MercenaryQuest_XiLinDao_CommonC")
	
	for i=1, 5 do
		table.insert(tbl,"quest/Lan_MercenaryQuest_CommonA"..i)
		table.insert(tbl,"quest/Lan_MercenaryQuest_CommonB"..i)
		table.insert(tbl,"quest/Lan_MercenaryQuest_CommonC"..i)
	end
	
	for i=1, 3 do
		table.insert(tbl,"quest/Lan_DareQuest_Common"..i)
		table.insert(tbl,"quest/Lan_ActionQuest_Common"..i)
		table.insert(tbl,"quest/Lan_LoopQuest_Common"..i)
	end
	
	lan_load_list("Lan_QuestCommon", unpack(tbl))
end
LoadLanAllQuestCfg()

function SetQuestNeedTrackInfo()
	for QuestName,QuestTbl in pairs(g_QuestNeedMgr) do
		for VarName,_ in pairs(QuestTbl) do
			local str = g_QuestNeedMgr[QuestName][VarName].TrackInfo
			if str then
				g_QuestNeedMgr[QuestName][VarName].TrackInfo = Lan_QuestCommon(MemH64(str), "NewContent")
			end
		end
	end
	for QuestName,QuestTbl in pairs(g_BuffQuestMgr) do
		for VarName,_ in pairs(QuestTbl) do
			local str = g_BuffQuestMgr[QuestName][VarName].TrackInfo
			if str then
				g_BuffQuestMgr[QuestName][VarName].TrackInfo = Lan_QuestCommon(MemH64(str), "NewContent")
			end
		end
	end
end
SetQuestNeedTrackInfo()

function g_GetLanQuestInfo(str)
	if Lan_QuestCommon(MemH64(str)) then
		return Lan_QuestCommon(MemH64(str), "NewContent")
	else
		if string.find(str, "��������") then
			str = string.gsub(str, "��������", "�����ȡ�Ի�")
			if Lan_QuestCommon(MemH64(str)) then
				return Lan_QuestCommon(MemH64(str), "NewContent")
			end
		end
		
		return ""
	end
end

function g_GetLanQuestName(str)
	str = str.."������"
	if Lan_QuestCommon(MemH64(str)) then
		return Lan_QuestCommon(MemH64(str), "NewContent")
	else
		return ""
	end
end

function g_GetQuestNameMH64ByDisplayName(sDisplayName)
	local questnameTbl = {}
	local Keys = Lan_QuestCommon:GetKeys()
	for i=1, table.getn(Keys) do
		if sDisplayName == Lan_QuestCommon(Keys[i], "NewContent") then
			local longName = MemH64ToMbcs(Keys[i])
			if( "������" == string.sub( longName, -6 ) ) then
				local mh64Name = MemH64( string.sub( longName, 1, -7) )
				table.insert( questnameTbl, mh64Name )
			end
		end
	end
	return questnameTbl
end

--�Ƚ��������ʾ��,һ���Ͳ��ý�������
function g_CheckQuestShowName(AcceptQuestName)
	local AcceptShowName = g_GetLanQuestName(AcceptQuestName)
	local QuestTbl = g_GameMain.m_QuestRecordWnd.m_DoingQuestInfo[QuestName]
	for QuestName,_ in pairs(g_GameMain.m_QuestRecordWnd.m_DoingQuestInfo) do
		local ShowName = g_GetLanQuestName(QuestName)
		if AcceptShowName == ShowName then
			return false, 300017	--�����Ѿ���Щ������
		end
	end
	return true
end

--�ؼ��ֵĳ�����
function g_SetKeyHypeLink(questname, str, DownColor)
	local QuestHypeLink = {}
	if Quest_Common(questname, "������") then
		local Keys = Quest_Common:GetKeys(questname, "������")
		for i=table.getn(Keys),1,-1 do
			local Subject = Quest_Common(questname, "������", Keys[i], "Subject")
			local HyperLink = Quest_Common(questname, "������", Keys[i], "HyperLink")
			if Subject~="" and HyperLink~=0 and QuestPos_Common(HyperLink) then
				local SceneName = QuestPos_Common(HyperLink, "SceneName")
				local PosX = QuestPos_Common(HyperLink, "PosX")
				local PosY = QuestPos_Common(HyperLink, "PosY")
				local Mark = QuestPos_Common(HyperLink, "Mark")
				local FindStr = "%b{"..Subject.."}"
				local sTblInfo = string.match(str,FindStr)
				if sTblInfo then
					local RealName = Mark or ""
					local num = string.find(sTblInfo,",")
					local strHipeLink = string.sub(sTblInfo,2,num-1)
					local linkstr = AutoTrackColorStr.."#u#l"..strHipeLink.."#i[".. MemH64(RealName) .."]#l#u#W"..DownColor
					str = string.gsub(str, FindStr, linkstr)
					if not QuestHypeLink[RealName] then
						local tbl = {SceneName, PosX ,PosY}
						QuestHypeLink[RealName] = tbl
					end
				end
			end
		end
	end
	return str,QuestHypeLink
end

--��Ʒ�ĳ�����
function g_SetItemHypeLink(questname, str, DownColor)
	local ItemTbl = {}
	if Quest_Common(questname, "��Ʒ������") then
		local Keys = Quest_Common:GetKeys(questname, "��Ʒ������")
		for i=table.getn(Keys),1,-1 do
			local subject = Quest_Common(questname, "��Ʒ������", Keys[i], "Subject")
			local itemlink = GetCfgTransformValue(false, "Quest_Common", questname, "��Ʒ������", Keys[i], "Arg")
			if subject~="" and itemlink[1] then
				local FindStr = "%b{"..subject.."}"
				local sTblInfo = string.match(str,FindStr)
				if sTblInfo then
					local num = string.find(sTblInfo,",")
					local strHipeLink = string.sub(sTblInfo,2,num-1)
					str = string.gsub(str,FindStr,"#cffff33#u#l"..strHipeLink.."#i[".. MemH64(itemlink[2]) .."]#l#u#W"..DownColor)
					ItemTbl[itemlink[2]] = itemlink[1]
				end
			end
		end
	end
	return str,ItemTbl
end

function g_QuestInfoTextTransfer(Discription)
	if not Discription then
		return ""
	end
	if IsCppBound(g_MainPlayer) then
		local CharName = g_MainPlayer.m_Properties:GetCharName()
		Discription = string.gsub(Discription, "#name#", CharName)
		local ClassStr = g_GameMain.m_DisplayCommonObj:GetPlayerClassForShow(g_MainPlayer:CppGetClass())
		Discription = string.gsub(Discription, "#class#", ClassStr)
		Discription = string.gsub(Discription, "#newline#", "#r")       --2009.05.06�����
		Discription = string.gsub(Discription, "#space#", " ")
	end
	return Discription
end

function g_ReturnSentenceParse(str, QuestName)
	if not str or str == "" then
		return 0
	end
	
	local PlayerLevel = 0
	local PlayerYbLevel = 0
	local LoopNum = 1
	if IsCppBound(g_MainPlayer) then
		PlayerLevel = g_MainPlayer:CppGetLevel()
		PlayerYbLevel = g_MainPlayer.m_uMercenaryLevel or 0
		if Quest_Common(QuestName, "��������") == 10 then
			local tbl = GetCfgTransformValue(true, "Quest_Common", QuestName, "������", "1")
			if tbl and tbl[1] then
				LoopNum = g_GameMain.m_QuestRecordWnd.m_LoopTbl[tbl[1]] or LoopNum
			end
		end
	end
	
	str = string.gsub( str, "yblevel", PlayerYbLevel)
	str = string.gsub( str, "level", PlayerLevel)
	str = string.gsub( str, "loop", LoopNum)
	local count = assert(loadstring( "return " .. str))()
	count = math.floor(count)
	return count
end

function g_RetNoneMercSentenceParse(str)
	local PlayerLevel = 0
	if IsCppBound(g_MainPlayer) then
		PlayerLevel = g_MainPlayer:CppGetLevel()
	end
	
	str = string.gsub( str, "level", PlayerLevel)
	local count = assert(loadstring( "return " .. str))()
	count = math.floor(count)
	return count
end

function g_SoulPearlSentenceParse(str, QuestName)
	local i = string.find(str, ":")
	return string.sub(str, 1, i) .. g_ReturnSentenceParse(string.sub(str, i+1), QuestName)
end

function g_GetQuestAwardInfo(QuestName)
	local info = {}
	local PlayerLevel = g_MainPlayer:CppGetLevel()
	local PlayerYbLevel = g_MainPlayer.m_uMercenaryLevel
	
	info.Exp, info.Soul = CQuest.CountAddExpAndSoulNum(PlayerLevel, PlayerYbLevel, QuestName)
	info.MercIntegral = 	CQuest.CountAddMercenaryIntegralNum(PlayerLevel, PlayerYbLevel, QuestName)
	info.Money = 					g_ReturnSentenceParse(Quest_Common(QuestName, "��Ǯ����"), QuestName)
	info.BindMoney = 			g_ReturnSentenceParse(Quest_Common(QuestName, "�󶨵Ľ�Ǯ����"), QuestName)
	info.BindTicket = 		g_ReturnSentenceParse(Quest_Common(QuestName, "�󶨵�Ԫ������"), QuestName)
	info.TongProffer = 		g_ReturnSentenceParse(Quest_Common(QuestName, "����Ź�����"), QuestName)
	info.BindMercTicket = g_ReturnSentenceParse(Quest_Common(QuestName, "�󶨵�Ӷ��ȯ����"), QuestName)
	info.Development = 		g_ReturnSentenceParse(Quest_Common(QuestName, "��չ�Ƚ���"), QuestName)
	info.TongHonor = 			g_ReturnSentenceParse(Quest_Common(QuestName, "�����������"), QuestName)
	
	return info
end

function g_GetQuestAwardInfoAndStr(QuestName)
	local info = g_GetQuestAwardInfo(QuestName)
	local awardString = ""
	
	if info.Exp ~= 0 then
		awardString = awardString .. GetStaticTextClient(8302) .. info.Exp .. "#r"
	end
	if info.Soul ~= 0 then
		awardString = awardString .. GetStaticTextClient(8303) .. info.Soul .. "#r"
	end
	if info.MercIntegral ~= 0 then
		awardString = awardString .. GetStaticTextClient(8343) .. info.MercIntegral .. "#r"
	end
	if info.Money ~= 0 then
		awardString = awardString .. GetStaticTextClient(8304) .. g_MoneyMgr:ChangeMoneyToString(info.Money, EGoldType.GoldCoin) .. "#r"
	end
	if info.BindMoney ~= 0 then
		awardString = awardString .. GetStaticTextClient(8305) .. g_MoneyMgr:ChangeMoneyToString(info.BindMoney, EGoldType.GoldBar) .. "#r"
	end
	if info.BindTicket ~= 0 then
		awardString = awardString .. GetStaticTextClient(8306) .. info.BindTicket .. "#r"
	end
	if info.TongProffer ~= 0 then
		awardString = awardString .. GetStaticTextClient(8342) .. info.TongProffer .. "#r"
	end
	if info.BindMercTicket ~= 0 then
		awardString = awardString .. GetStaticTextClient(8343) .. info.BindMercTicket .. "#r"
	end
	if info.Development ~= 0 then
		awardString = awardString .. GetStaticTextClient(8345) .. info.Development .. "#r"
	end
	if info.TongHonor ~= 0 then
		awardString = awardString .. GetStaticTextClient(8328) .. info.TongHonor .. "#r"
	end
	
	return info, awardString
end

----------------------------------------------------------------------

function CQuest.CheckQuestAvavilable(QuestName, NotCheckMap)
	return CheckQuestAvavilable(QuestName, NotCheckMap)
end

function CQuest.CheckCanFinishQuest(QuestName)
	return CheckCanFinishQuest(QuestName)
end

function CQuest.OnRClickQuestItem(Conn,uBigID,uIndex)
	return OnRClickQuestItem(Conn,uBigID,uIndex)
end

function CQuest.QueryQuest(sType,sName,uTargetID)
	return QueryQuest(sType,sName,uTargetID)
end

function CQuest.QueryFinishQuest(sType,sName,uTargetID)
	return QueryFinishQuest(sType,sName,uTargetID)
end

function CQuest.CheckIsHaveContinualQuest(sType,sName)
	return CheckIsHaveContinualQuest(sType,sName)
end

function CQuest.CountAddExpAndSoulNum(PlayerLevel,PlayerYbLevel,QuestName)
	return CountAddExpAndSoulNum(PlayerLevel,PlayerYbLevel,QuestName)
end

function CQuest.CountAddMercenaryIntegralNum(PlayerLevel,PlayerYbLevel,QuestName)
	return CountAddMercenaryIntegralNum(PlayerLevel,PlayerYbLevel,QuestName)
end

function CQuest.CountMasterStrokeQuest()
	return CountMasterStrokeQuest()
end

function CQuest.IsObjectContainFun(Target)
	return IsObjectContainFun(Target)
end

function CQuest.GetFuncNameByNpcName(NpcName)
	return GetFuncNameByNpcName(NpcName)
end
