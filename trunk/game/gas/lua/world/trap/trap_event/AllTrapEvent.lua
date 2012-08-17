cfg_load "npc/Npc_Common"  --yy 09.05.31
cfg_load "int_obj/IntObj_Common"
cfg_load "fb_game/AreaFb_Common"
gas_require "log_mgr/CLogMgr"

CCommonTrap = class()
CNonCleanTrap = class()
CAddTemporarySkill = class()
CDoSkillOnPos = class()
CChangeBoxStateTrap = class()
CTransportTrap = class()
CDaTaoShaTransportTrap = class()
CDaDuoBaoTransportTrap = class()
CYbEducateActionTrap = class()
CYbEducateActionAddNum = class()
CInTrapCancelBuf = class()
CPlayerInTrapAddVar = class()
CNpcInExistTrapAddVar = class()
CNpcInPutTrapAddVar = class()
CPlayerInTrapAddRes = class()  
CNpcInExistTrapAddRes = class()
CNpcInPutTrapAddRes = class()
CDestroyMySelf = class()
CTriggerTheater = class()
CNpcInTrapDeleteNpc = class()
CPlayerInTrapAddNpcOrObj = class()
CInPutTrapAddVar = class()
CInPutTrapAddItem = class()
CSmallEctypeAddCount = class()
CCreateNpcOnPos = class()
CReplaceNpc = class()
CAddHp = class()
CNamedObjInPutTrapDelete = class()
CPlayerAddMoney = class()
CPlayerAddExper = class()  --		��Trap������
CPlayerTransport = class()  --		��Ҳ�Trap���͵�ָ��λ��
CBugRunOut = class()
CNpcOutTrapDeleteNpc = class()
CInTrapSendMsg = class()
CMatchGameAddCount = class()
CAddDifferentCount = class()
CAddDifferentStateCount = class()
CNpcIntoTrapDeleted = class()
CRapRebornPoint = class()
CAddSameNpcCount = class()
CYbActionNpcAddNum = class()
CAreaFbTransportTrap = class()
CSpecilAreaTrap = class()
CChangeTongSceneByTrap = class()
CTakeBuffAddCount = class()

local function DoSkillToCharacter(pTrapHandler, pCharacter, TrapArg)
	if pCharacter == nil then
		return
	end
	--���ܶ�OBJʩ��
	if pCharacter.m_Properties:GetType() == ECharacterType.IntObj then
		return 
	end 

	local NpcCamp = pCharacter:CppGetCamp()
	if NpcCamp == ECamp.eCamp_Passerby then
		return
	end
	
	local SkLevel = TrapArg[2] 
	if SkLevel == nil or IsString(SkLevel) or SkLevel == 0 then
		SkLevel = 1
	end 
--	if pTrapHandler.m_Owner.m_OwnerId ~= nil then
--		local TrapOwner = g_GetPlayerInfo(pTrapHandler.m_Owner.m_OwnerId)
--		if TrapOwner then
--			if NpcCamp == TrapOwner:CppGetCamp() then
--				return
--			end
--			if IsCppBound( TrapOwner) then
--				TrapOwner:ServerDoNoRuleSkill(TrapArg[1], pCharacter)
--			end
--			return
--		end
--	end
	if IsCppBound(pTrapHandler.m_Owner) then
		pTrapHandler.m_Owner:DoIntObjSkill(TrapArg[1],SkLevel,pCharacter)
	end	
end

function CCommonTrap.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
	DoSkillToCharacter(pTrapHandler, pCharacter, TrapArg)
end
function CCommonTrap.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)
	if pCharacter.m_Properties:GetType() == ECharacterType.IntObj then
		return 
	end 
--	local Name = pCharacter.m_Properties:GetCharName()
--	print("���",Name,"״̬",TrapArg[1])
	if IsString(TrapArg[2]) then
		DoSkillToCharacter(pTrapHandler, pCharacter, {TrapArg[2]})
--	else
--		pCharacter:ClearState(TrapArg[1])
	end
end

function CAddHp.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
	if pCharacter.m_Properties:GetCharName() == TrapArg[2] then
		local Trap = pTrapHandler.m_Owner
		local FireNpc = Trap.m_FireNpc
		if not FireNpc then
			return
		end
		local fullHp = FireNpc:CppGetMaxHP()
		local curHp = FireNpc:CppGetHP()
		FireNpc:CppSetHP(fullHp * 0.05 + curHp)
	end
end

function CAddHp.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)
	
end

function CNonCleanTrap.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
--	print"CNonCleanTrap.OnStepInTrap"
	DoSkillToCharacter(pTrapHandler, pCharacter, TrapArg)
end

function CNonCleanTrap.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)
end

--����ʱ����-------------
function CAddTemporarySkill.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
	if pCharacter == nil then
		return
	end
	--ֻ�ܶ����ʹ����ʱ����
	if pCharacter.m_Properties:GetType() == ECharacterType.Player then
		local BuffSkillName = TrapArg[1]
		if BuffSkillName and BuffSkillName ~= "" then
			pCharacter:AddTempSkill(BuffSkillName,1)
		end
	end
end

function CAddTemporarySkill.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)
end
-------------------------

--�ӵص㼼��-------------
function CDoSkillOnPos.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
	if pCharacter == nil then
		return
	end
	--ֻ�ܶ����ʹ����ʱ����
	if pCharacter.m_Properties:GetType() == ECharacterType.Player then
		local SkillName = TrapArg[1]
		if SkillName and SkillName ~= "" then
			local CenterPos = CFPos:new()
			pTrapHandler.m_Owner:GetPixelPos(CenterPos)
			pTrapHandler.m_Owner:DoPosIntObjSkill(SkillName, 1, CenterPos)
		end
	end
end

function CDoSkillOnPos.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)
end
---------------------------

--�ı�����״̬
function CChangeBoxStateTrap.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)

	if  TrapArg[1] == nil or TrapArg[1] == "" then
		return
	end
	local SceneId = pCharacter.m_Scene.m_SceneId
--	if pCharacter.m_Properties:GetType() == ECharacterType.IntObj then
--		local name = pCharacter.m_Properties:GetCharName()
--		db()
--	end
	local IntObj = GetOnlyIntObj(SceneId, TrapArg[1])
	if IntObj == nil then
		return
	end
--	print("������������(����"..TrapArg[1]..")")
	if next(pTrapHandler.m_Owner.m_OnTrapCharIDTbl) then
		g_IntObjServerMgr:IntObjChangeState(IntObj, 1)
	else 
		g_IntObjServerMgr:IntObjChangeState(IntObj, 0)
	end
end
function CChangeBoxStateTrap.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)
	local Trap = pTrapHandler.m_Owner
	
	if table.maxn(Trap.m_OnTrapCharIDTbl) > 0 then
		return
	end
	
	if TrapArg[1] == nil or TrapArg[1] == "" then
		return
	end
	local SceneId = pCharacter.m_Scene.m_SceneId
	local IntObj = GetOnlyIntObj(SceneId, TrapArg[1])
	if IntObj == nil then
		return
	end
--	print("�뿪��������(����"..TrapArg[1]..")")
	if next(Trap.m_OnTrapCharIDTbl) then
		g_IntObjServerMgr:IntObjChangeState(IntObj, 0)
	else 
		g_IntObjServerMgr:IntObjChangeState(IntObj, 1)
	end
end

local function Transport(pTrapHandler, pCharacter, TrapArg)
	local Type = pCharacter.m_Properties:GetType()
	if Type ~= ECharacterType.Player then
		return
	end
--	if pTrapHandler.m_Owner.m_Properties:GetCanUseState() == 0 then
----		print("���͵㲻����")
--		return
--	end
	local TrapName = pTrapHandler.m_Owner.m_Properties:GetCharName()
	local SceneName = pCharacter.m_Scene.m_LogicSceneName 
	local PlayerId = pCharacter.m_uID
	if Transport_Server(TrapName) then
		for _, i in pairs(Transport_Server:GetKeys(TrapName, "����")) do
			local TransInfo = Transport_Server(TrapName, "����", i.."")
	 		if (TransInfo("BeginScene") == "" or SceneName == TransInfo("BeginScene"))
	 			and CheckPlayerLev(pCharacter:CppGetLevel(), TransInfo("LeastLev"), TransInfo("MaxLev")) 
				and (TransInfo("Camp") == 0 or TransInfo("Camp") == pCharacter:CppGetCamp()) then
				if Scene_Common[TransInfo("EndScene")] == nil then
					return
				end
				local Pos = CPos:new()
				Pos.x, Pos.y = TransInfo("PosX"), TransInfo("PosY")
	--			if p.QuestNeed == "" then
				if TransInfo("EndScene") == SceneName then
					pCharacter:SetGridPosByTransport(Pos)
					---�������������Ҫ����Ա���ͼ�ڿ�trapѰ·
					Gas2Gac:PlayerTransportSetGrid(pCharacter.m_Conn)
				else
					local SaveX,SaveY = nil,nil
					if TransInfo("SavePosX") ~= "" and TransInfo("SavePosY") ~= "" then
						SaveX,SaveY = TransInfo("SavePosX"), TransInfo("SavePosY")
					end
					NewChangeScene(pCharacter.m_Conn, TransInfo("EndScene"), Pos.x , Pos.y, SaveX,SaveY)
				end
				break
			end	
		end
	end
end

--���͵�
function CTransportTrap.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
	Transport(pTrapHandler, pCharacter, TrapArg)
end
function CTransportTrap.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)
end

-------------------------------------------------------
--����ɱ�淨 ����Trap
function CDaTaoShaTransportTrap.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
--	print("CDaTaoShaTransportTrap.OnStepInTrap")
	local Type = pCharacter.m_Properties:GetType()
	if Type ~= ECharacterType.Player then
		return
	end
	DaTaoShaTransport(pTrapHandler.m_Owner, pCharacter)
end

function CDaTaoShaTransportTrap.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)
end
------------------------------------------------------

--��ᱦ�淨 ����Trap=======================
function CDaDuoBaoTransportTrap.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
	local Type = pCharacter.m_Properties:GetType()
	if Type ~= ECharacterType.Player then
		return
	end
	
	local MaxRoomNum = table.getn(g_DaTaoShaPointMgr)
	local SelRoomNum = math.random(1,MaxRoomNum)
	--print("SelRoomNum",SelRoomNum)
	if g_DaTaoShaPointMgr[SelRoomNum] then
		local Pos = CPos:new()
		Pos.x = g_DaTaoShaPointMgr[SelRoomNum]["IntoRoomPoint"][1]
		Pos.y = g_DaTaoShaPointMgr[SelRoomNum]["IntoRoomPoint"][2]
		pCharacter:SetGridPosByTransport( Pos )
	end
end

function CDaDuoBaoTransportTrap.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)
end
--===========================================

--Ӷ��ѵ������========================
function CYbEducateActionTrap.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
	--print("                   ")
	--print("��������������Trap")
	local Type = pCharacter.m_Properties:GetType()
	if Type ~= ECharacterType.Player then
		return
	end
	
	local Scene = pCharacter.m_Scene
	-- �����һ���ǲ��ǽ�����
		Scene.m_MercenaryActionInfo.m_IsRewardFloor = CMercenaryEducateAct.IsNextRewardFloor(Scene)
	-- ������һ��ķ����
	local SelRoomNum = CMercenaryEducateAct.GetNextRoomNum(pCharacter)	
	--print("ѡ������ SelRoomNum = "..SelRoomNum)

	if g_MercenaryEduActMgr.m_RoomPoints[SelRoomNum] then
		--����,���õ������ڲ����������ļ��ش���(����ӿ����д��͵���������)
		CMercenaryRoomCreate.RandomLoadYbActionInfo(pCharacter, SelRoomNum)
		DestroyServerTrap(pTrapHandler.m_Owner, false)
	end
	CMercenaryRoomCreate.SetGameState(Scene, CMercenaryRoomCreate.GameState.BeforeGame)
	local GameID = Scene.m_MercenaryActionInfo.m_GameID
	CMercenaryRoomCreate.YbEduActAddOrResetSkill(pCharacter, GameID, true)
	--print("�������������")
end

function CYbEducateActionTrap.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)
end
--=====================================

--Ӷ����Ӽ���
function CYbEducateActionAddNum.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
	local Player = nil 
	if pCharacter.m_OwnerId ~= nil then
		Player = g_GetPlayerInfo(pCharacter.m_OwnerId)
	else
		Player = pCharacter
	end
	if not IsCppBound(Player) then
		return
	end
	local TargetName = TrapArg[1]
	if not TargetName or TargetName == "" then
		return
	end
	
	CMercenaryRoomCreate.KillTargetAddNum(Player.m_Scene, TargetName)
end
function CYbEducateActionAddNum.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)
end

--��Trapȡ��buffer
function CInTrapCancelBuf.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
	if TrapArg[1] == "" or TrapArg[1] == nil or TrapArg[2] == "" or TrapArg[2] == nil then
		return
	end
	--���ܶ�OBJʩ��
	if pCharacter.m_Properties:GetType() == ECharacterType.IntObj then
		return 
	end 
	
	if Quest_Common(TrapArg[1], "��������") then
		local Buffname = Quest_Common(TrapArg[1], "��������", "Arg")
	end
	if Buffname == nil or Buffname == "" then
		return
	end
	if pCharacter:ExistState(Buffname) then
		pCharacter:ClearState(Buffname)
		if Quest_Common(TrapArg[1], "�����ﵽ״̬����") then
			local Keys = Quest_Common:GetKeys(TrapArg[1], "�����ﵽ״̬����")
			for k = 1, table.getn(Keys) do
				local tbl = GetCfgTransformValue(true, "Quest_Common", TrapArg[1], "�����ﵽ״̬����", Keys[k], "Function")
				pCharacter:ClearState(tbl[1])
			end
		end
		
		local RoleQuestDB = "RoleQuestDB"
		local parm = 
		{
			["iNum"] = TrapArg[3],
			["sQuestName"] = TrapArg[1],
			["sVarName"] = TrapArg[2],
			["char_id"] = pCharacter.m_uID
		}
		
		local function CallBack(isSuccess)
			if isSuccess and IsCppBound(pCharacter) then
				Gas2Gac:RetAddQuestVar(pCharacter.m_Conn, parm["sQuestName"], parm["sVarName"],parm["iNum"])
			end
		end
		local SceneMgrDB = "SceneMgrDB"
		CallAccountManualTrans(pCharacter.m_Conn.m_Account,RoleQuestDB,"AddQuestVarNum", CallBack, parm)	
	end
end
function CInTrapCancelBuf.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)
end

--++++++++++++++++++++++++++++begin+++++++++++++++++++++++++++++++++++++++++
local function InTrapAddQuestNum(pTrapHandler, pCharacter, TrapArg)
	if pCharacter.m_Properties:GetType() == ECharacterType.IntObj then
		return 
	end 
	local QuestName = TrapArg[1]
	local VarName = TrapArg[2]
	local AddNum = TrapArg[3]
--	if g_QuestNeedMgr[QuestName] == nil or g_QuestNeedMgr[QuestName][VarName] == nil then
--		return
--	end
	g_AddQuestVarNumForTeam(pCharacter, QuestName,VarName,AddNum)
end

--��Trap������Ҽ��������
function CInPutTrapAddVar.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
	--Npc�Ȱڷ�Trap ��Ҽ��������
--	print("........................in")
	local PlayerId = pTrapHandler.m_Owner.m_OwnerId
	if PlayerId then
		local Player = g_GetPlayerInfo(PlayerId)
		if Player then
			InTrapAddQuestNum(pTrapHandler, Player, TrapArg)
		end
		return
	end
	-----------------------------------
	
	--Npc����ȻTrap ��Ҽ��������
	if pCharacter.m_OwnerId then
		local Player = g_GetPlayerInfo(pCharacter.m_OwnerId)
		if Player then
			InTrapAddQuestNum(pTrapHandler, Player, TrapArg)
		end
		return
	end
	------------------------------------
	
	--��Ҳ�Trap  ��Ҽ��������
	InTrapAddQuestNum(pTrapHandler, Player, TrapArg)
	-------------------------------------
end

function CInPutTrapAddVar.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)
end
--+++++++++++++++++++++++++++++end+++++++++++++++++++++++++++++++++++++++++++

--Npc�Ȱڷ�Trap��������� ��Ҽ��������
function CNpcInPutTrapAddVar.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
	local PlayerId = pTrapHandler.m_Owner.m_OwnerId
	if PlayerId == nil then
		return
	end
	local Player = g_GetPlayerInfo(PlayerId)
	if not Player then
		return
	end
	CPlayerInTrapAddVar.OnStepInTrap(pTrapHandler, Player, TrapArg)
end

function CNpcInPutTrapAddVar.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)
end
--Npc����ȻTrap��������� ��Ҽ��������
function CNpcInExistTrapAddVar.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
	--local Player = pCharacter
	--pCharacter ΪNPC
	if pCharacter.m_OwnerId == nil then
		return
	end
	local Player = g_GetPlayerInfo(pCharacter.m_OwnerId)
	if not Player then
		return
	end
	CPlayerInTrapAddVar.OnStepInTrap(pTrapHandler, Player, TrapArg)
end

function CNpcInExistTrapAddVar.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)

end

--��Ҳ�Trap���������yy
-- pTrapHandler Trap  ���
function CPlayerInTrapAddVar.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
	--Obj��������
	if pCharacter.m_Properties:GetType() == ECharacterType.IntObj then
		return 
	end 
	local QuestName = TrapArg[1]
	local VarName = TrapArg[2]
	local AddNum = TrapArg[3]
--	if g_QuestNeedMgr[QuestName] == nil or g_QuestNeedMgr[QuestName][VarName] == nil then
--		return
--	end
	g_AddQuestVarNumForTeam(pCharacter, QuestName,VarName,AddNum)
end

function CPlayerInTrapAddVar.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)
end


--++++++++++++++++++++++++++++begin+++++++++++++++++++++++++++++++++++++++++
local function InTrapAddItem(pTrapHandler, pCharacter, TrapArg)
	if pCharacter.m_Properties:GetType() == ECharacterType.IntObj then
		return 
	end 
	local PlayerID = pCharacter.m_uID;	--���ID]
	local TaskName = 			TrapArg[1]--��������	
	local ItemType = 			TrapArg[2]--��Ʒ����
	local ItemName = 		  TrapArg[3]--��Ʒ����
	local ItemNum = 			TrapArg[4]--��Ʒ����
	local questneed				--�������
	
	local parameter = {}
	parameter["sQuestName"] = TaskName
	parameter["char_id"]		= PlayerID
	parameter["nType"]		= ItemType
	parameter["sName"] 		= ItemName
	parameter["nCount"]		= ItemNum
	parameter["sceneName"]		= pCharacter.m_Scene.SceneName
	local Conn = pCharacter.m_Conn
	local function CallBack(result)
		if IsNumber(result) then
			if result == 3 then
				if IsCppBound(Conn) then
					MsgToConn(Conn,160000)
				end
			end
			return
		end
		CRoleQuest.add_item_DB_Ret_By_Id(PlayerID,ItemType,ItemName,ItemNum,result)
	end
	CallAccountManualTrans(Conn.m_Account, "RoleQuestDB","IntoTrapAddItem", CallBack, parameter)
end

--��Trap������Ҽ���Ʒ
function CInPutTrapAddItem.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
	--Npc�Ȱڷ�Trap ��Ҽ���Ʒ
	local PlayerId = pTrapHandler.m_Owner.m_OwnerId
	if PlayerId then
		local Player = g_GetPlayerInfo(PlayerId)
		if Player then
			InTrapAddItem(pTrapHandler, Player, TrapArg)
		end
		return
	end
	-----------------------------------
	
	--Npc����ȻTrap ��Ҽ���Ʒ
	if pCharacter.m_OwnerId then
		local Player = g_GetPlayerInfo(pCharacter.m_OwnerId)
		if Player then
			InTrapAddItem(pTrapHandler, Player, TrapArg)
		end
		return
	end
	------------------------------------
	
	--��Ҳ�Trap  ��Ҽ���Ʒ
	InTrapAddItem(pTrapHandler, Player, TrapArg)
	-------------------------------------
end

function CInPutTrapAddItem.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)
end
--+++++++++++++++++++++++++++++end+++++++++++++++++++++++++++++++++++++++++++

--Npc����ȻTrap ��Ҽ���Ʒ
function CNpcInExistTrapAddRes.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
	local PlayerId = pCharacter.m_OwnerId
	if PlayerId == nil then
		return
	end
	local Player = g_GetPlayerInfo(PlayerId)
	if not Player then
		return
	end
	CPlayerInTrapAddRes.OnStepInTrap(pTrapHandler, Player, TrapArg)
end

function CNpcInExistTrapAddRes.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)
end

--Npc�Ȱڷ�Trap ��Ҽ���Ʒ
function CNpcInPutTrapAddRes.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
	--local PlayerId = pTrapHandler.m_Owner.m_OwnerId or pCharacter.m_OwnerId
	local PlayerId = pTrapHandler.m_Owner.m_OwnerId
	if PlayerId == nil then
		return
	end
	local Player = g_GetPlayerInfo(PlayerId)
	if not Player then
		return
	end
	CPlayerInTrapAddRes.OnStepInTrap(pTrapHandler, Player, TrapArg)
end
function CNpcInPutTrapAddRes.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)
end



--��Ҳ�Trap ��ұ����������Ʒ yy
-- pTrapHandler Trap ID
-- pCharacter �����Ϣ
function CPlayerInTrapAddRes.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
	if pCharacter.m_Properties:GetType() == ECharacterType.IntObj then
		return 
	end 
	local PlayerID = pCharacter.m_uID;	--���ID]
	local TaskName = 			TrapArg[1]--��������	
	local ItemType = 			TrapArg[2]--��Ʒ����
	local ItemName = 		  TrapArg[3]--��Ʒ����
	local ItemNum = 			TrapArg[4]--��Ʒ����
	local questneed				--�������
	
--	print "TaskName";
--	print (TaskName)
	
	local parameter = {}
	parameter["sQuestName"] = TaskName
	parameter["char_id"]		= PlayerID
	parameter["nType"]		= ItemType
	parameter["sName"] 		= ItemName
	parameter["nCount"]		= ItemNum
	parameter["sceneName"]		= pCharacter.m_Scene.m_SceneName
	local Conn = pCharacter.m_Conn
	local function CallBack(result)
		if IsNumber(result) then
			if result == 3 then
				if IsCppBound(Conn) then
					MsgToConn(Conn,160000)
				end
			end
			return
		end
		CRoleQuest.add_item_DB_Ret_By_Id(PlayerID,ItemType,ItemName,ItemNum,result)
	end
	if IsCppBound(Conn) and Conn.m_Account then
		CallAccountAutoTrans(Conn.m_Account, "RoleQuestDB","IntoTrapAddItem", CallBack, parameter)
	end
end

function CPlayerInTrapAddRes.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)

end
--�����糡
function CTriggerTheater.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
	local ObjectType = pCharacter.m_Properties:GetType()
	local SceneId = pCharacter.m_Scene.m_SceneId
	local TheaterMgr = pCharacter.m_Scene.m_TheaterMgr
	local EntityID = pCharacter:GetEntityID()
	if TrapArg[1] == "" then
		TheaterMgr:RunTriggerTheater(TrapArg[2], nil)
	elseif ObjectType == ECharacterType.Npc then
		TheaterMgr:RunTriggerTheater(TrapArg[2], nil)
	elseif ObjectType == ECharacterType.Player then
		if CRoleQuest.DoingQuest_Check(pCharacter, TrapArg[1]) then
			TheaterMgr:RunTriggerTheater(TrapArg[2], EntityID)
		end
	end
end

function CTriggerTheater.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)

end
--������ɾ��
function CDestroyMySelf.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
	
	DestroyServerTrap(pTrapHandler.m_Owner, true)
end 

function CDestroyMySelf.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)

end

function CNpcInTrapDeleteNpc.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
	if pCharacter.m_Properties:GetType() == ECharacterType.IntObj then
		return 
	end
	pCharacter:SetOnDisappear(true) 
end 

function CNpcInTrapDeleteNpc.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)

end

function CNpcIntoTrapDeleted.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
	if pCharacter.m_Properties:GetType() == ECharacterType.IntObj then
		return 
	end
	if pCharacter.m_TgtSentryIndex then
		if pTrapHandler.m_Owner.m_SentryIndex == pCharacter.m_TgtSentryIndex and
			 pTrapHandler.m_Owner.m_InBattleNum == 0 then
			pCharacter:SetOnDisappear(false)
		end
	end
end

function CNpcIntoTrapDeleted.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)

end

function CRapRebornPoint.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
	local timeLength = 60 * 1000
	
	local function ProgressSucceed()
		pTrapHandler.m_Occupyer = pCharacter.m_Properties:GetTongID()
	end
	
	local function ProgressFail()
		
	end
	TongLoadProgress(pCharacter, timeLength, ProgressSucceed, ProgressFail,{}) 
	
end

function CRapRebornPoint.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)

end


function CNamedObjInPutTrapDelete.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
	if pCharacter.m_Properties:GetCharName() == TrapArg[2] then
		pCharacter:SetOnDisappear(true)
	end
end 

function CNamedObjInPutTrapDelete.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)

end

-- yy 09.6.1 �õ���Χ�ڵĵ�.
local function GetRandomPos( CenterPos, max, min)
	if max == min == 0 then
		return CenterPos
	end
	local pos = CPos:new()
	assert(min <= max, "��ȡ���λ��, ���� min ����С�ڵ��� max")
	local radius = min + math.random()*(max - min)
	local angle = 2 * math.pi * math.random()
	pos.x = CenterPos.x + radius * math.sin(angle)
	pos.y = CenterPos.y + radius * math.cos(angle)
	return pos
end

-- yy  Player ����Trap ADD Npc Or Obj
-- Npc, name , number , ��Χ  ����Ϊtrap����
function CPlayerInTrapAddNpcOrObj.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)

	--print("CPlayerInTrapAddNpcOrObj")
	if pCharacter.m_Properties:GetType() == ECharacterType.IntObj then
		return 
	end
	local scene = pTrapHandler.m_Owner.m_Scene
	local CenterPos = CPos:new()
	pTrapHandler.m_Owner:GetGridPos(CenterPos)
	local min = 0
	local max = TrapArg[4]
	if max == nil then
--		local error_str = "max Ϊ nil"
		--error( error_str)
--		print( error_str)
		max = 0
	end
	local Num = TrapArg[3]
	local Name = TrapArg[2]
	if TrapArg[1] == "Npc" then
		local NpcInfoTb = Npc_Common(Name)
		if NpcInfoTb == nil then
--			print ("Npc_Common ����û����Ϊ"..Name.."Npc")
			return
		end
		local NpcLevel = NpcInfoTb("MaxLevel")
		for i = 1, Num do 
			local pos = GetRandomPos( CenterPos, max, min)
			local fPos = CFPos:new( pos.x * EUnits.eGridSpan, pos.y * EUnits.eGridSpan )
			local otherData = {["m_OwnerId"]=pCharacter.m_uID}
			local CreNpc = g_NpcServerMgr:CreateServerNpc( Name, NpcLevel, scene, fPos, otherData)
		end
	elseif TrapArg[1] == "Obj" then
		local ObjInfoTb = IntObj_Common(Name)
		if ObjInfoTb == nil then
--			print ("IntObj_Common ����û����Ϊ"..Name.."Obj")
			return
		end
		for i = 1, Num do 
			local pos = GetRandomPos( CenterPos, max, min)
			CreateIntObj(scene, pos, Name, true, nil, nil)
		end
	end
end

function CPlayerInTrapAddNpcOrObj.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)

end 

--С�����Ӽ���
function CSmallEctypeAddCount.OnStepInTrap( pTrapHandler, pCharacter, TrapArg)

	local Player = nil 
	if pCharacter.m_OwnerId ~= nil then
		Player = g_GetPlayerInfo(pCharacter.m_OwnerId)
	else
		Player = pCharacter
	end
	if not Player or not IsCppBound(Player) then
		return
	end
	
	if not Player.m_MatchGameCount then
		Player.m_MatchGameCount = 0
	end
	
	g_MatchGameMgr:AddMatchGameCount(Player, 2, pTrapHandler.m_Owner.m_Properties:GetCharName())
end

function CSmallEctypeAddCount.OnStepOutTrap( pTrapHandler, pCharacter, TrapArg)
end

--С�����Ӽ���
function CMatchGameAddCount.OnStepInTrap( pTrapHandler, pCharacter, TrapArg)
	local scene = pCharacter.m_Scene
	g_MatchGameMgr:AllTeamAddCount(scene, 2, pTrapHandler.m_Owner.m_Properties:GetCharName())
end

function CMatchGameAddCount.OnStepOutTrap( pTrapHandler, pCharacter, TrapArg)
	
end

function CInTrapSendMsg.OnStepInTrap( pTrapHandler, pCharacter, TrapArg)
	local scene = pTrapHandler.m_Owner.m_Scene
	local Player = nil 
	if pCharacter.m_OwnerId ~= nil then
		Player = g_GetPlayerInfo(pCharacter.m_OwnerId)
	else
		Player = pCharacter
	end
	if not Player or not IsCppBound(Player) then
		return
	end
	
	local playername = Player.m_Properties:GetCharName()
	MsgToConn(scene.m_CoreScene, TrapArg[1], playername)
end

function CInTrapSendMsg.OnStepOutTrap( pTrapHandler, pCharacter, TrapArg)
end

--����ˢNPC
function CCreateNpcOnPos.OnStepInTrap( pTrapHandler, pCharacter, TrapArg)
--	local CreatType  = TrapArg[1]
--	local CreatName  = TrapArg[2]
--	local CreatScene = pCharacter.m_Scene
--	local pos = GetCreatePos(pTrapHandler.m_Owner)
--	if TrapArg[5] == "�������" then
--		pos.x = pos.x + TrapArg[3]
--		pos.y = pos.y + TrapArg[4]
--	else
--		local ID = TrapArg[3]
--		pos.x, pos.y, scene = GetScenePosition(ID, CreatScene)
--		if scene ~= CreatScene.m_SceneName then
--			CfgLogErr("Trap���ñ�ű���д����",pTrapHandler.m_Owner.m_Properties:GetCharName().."(ָ��ˢ��)�ű�����д������ID("..ID..")�����������д�ĵ�ͼ(".. scene ..")��ʵ�ʵ�ͼ(".. CreatScene.m_SceneName ..")������")
--			return
--		end
--	end
--	CreateOnPos(CreatType, CreatName, CreatScene, pos, pCharacter:GetEntityID())
	local ArgTbl = TrapArg
	ArgTbl["Scene"] = pCharacter.m_Scene
	ArgTbl["Pos"] = GetCreatePos(pTrapHandler.m_Owner)
	ArgTbl["CreatorEntityID"] = pCharacter:GetEntityID()
	g_TriggerScript:RunScript("����", {ArgTbl}, pTrapHandler.m_Owner, pCharacter)
end

function CCreateNpcOnPos.OnStepOutTrap( pTrapHandler, pCharacter, TrapArg)
end

--�滻
function CReplaceNpc.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
	if pCharacter.m_Properties:GetType() == ECharacterType.Npc then
		local CreatName  = TrapArg[1]
		local Level = g_NpcBornMgr:GetNpcBornLevel(CreatName)
		local fPos = CFPos:new() 
		pCharacter:GetPixelPos(fPos)
		local dir = pCharacter:GetActionDir()
		local Npc = g_NpcServerMgr:CreateServerNpc(CreatName,Level,pCharacter.m_Scene,fPos)
		if not IsServerObjValid(Npc) then
			return
		end
		if TrapArg[2] and TrapArg[2] == "��ʧ������" then
			pCharacter:SetNoDissolve()
		end
		pCharacter:SetOnDisappear(true)
		Npc:SetAndSyncActionDir(dir)
	end 	
end 

function CReplaceNpc.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)

end

function CPlayerAddExper.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
	if not IsCppBound(pCharacter) then
		return
	end
	if pCharacter.m_Properties:GetType() == ECharacterType.Player then
		local AddExpFun = g_TriggerMgr:GetExpressions(TrapArg[1])
		local addExp = AddExpFun(pCharacter:CppGetLevel())
		local function callback(CurLevel,LevelExp)
			if IsCppBound(pCharacter) and CurLevel then
				if CurLevel then
					local AddExpTbl = {}
					AddExpTbl["Level"] = CurLevel
					AddExpTbl["Exp"] = LevelExp
					AddExpTbl["AddExp"] = addExp
					AddExpTbl["uInspirationExp"] = 0
					CRoleQuest.AddPlayerExp_DB_Ret(pCharacter, AddExpTbl)
				end
			end
		end
		local data = {}
		data["char_id"] = pCharacter.m_uID
		data["addExp"] = addExp
		data["addExpType"] = event_type_tbl["��Ҳ�Trap������"]
		
		OnSavePlayerExpFunc({pCharacter})
		CallAccountManualTrans(pCharacter.m_Conn.m_Account, "RoleQuestDB", "AddExp", callback, data)
	end
end

function CPlayerAddExper.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)
end

function CPlayerTransport.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
	if not IsCppBound(pCharacter) then
		return
	end
	if pCharacter.m_Properties:GetType() == ECharacterType.Player then
		local npc = pCharacter.m_ReplaceModel
		local NpcPos = CPos:new()
		npc:GetGridPos(NpcPos)
		pCharacter:SetGridPosByTransport(NpcPos)
		if IsCppBound(npc) then
			g_NpcServerMgr:DestroyServerNpcNow(npc, false)
			npc = nil
		end
	end
end

function CPlayerTransport.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)
end

function CPlayerAddMoney.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
	if not IsCppBound(pCharacter) then
		return
	end
	if pCharacter.m_Properties:GetType() == ECharacterType.Player then
		local AddMoneyFun = g_TriggerMgr:GetExpressions(TrapArg[1])
		local nMoney = AddMoneyFun(pCharacter:CppGetLevel())
		local type = 2
		if TrapArg[2] == "�ǰ�" then
			type = 1
		end
		local function callback(result,uMsgID)
			if IsNumber(uMsgID) then
				MsgToConn(pCharacter.m_Conn,uMsgID)
			end
			if IsCppBound(pCharacter) then
				if result then
					MsgToConn(pCharacter.m_Conn, 3602, nMoney)
				end
			end
		end
		local data = {}
		data["char_id"] = pCharacter.m_uID
		data["money_count"] = nMoney
		data["addType"]	= event_type_tbl["��Ҳ�trap��Ǯ"]
		data["money_type"] = type
		CallAccountAutoTrans(pCharacter.m_Conn.m_Account, "MoneyMgrDB", "AddMoneyForRpc", callback, data)
	end
end

function CPlayerAddMoney.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)

end

-- �����ܳ�ȥ
function CBugRunOut.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)
	if not IsCppBound(pCharacter) then
		return
	end
	local scene = pCharacter.m_Scene
	g_MatchGameMgr:AllTeamAddCount(scene, 2, pTrapHandler.m_Owner.m_Properties:GetCharName())
end

function CBugRunOut.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)

end

function CNpcOutTrapDeleteNpc.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)

end 

function CNpcOutTrapDeleteNpc.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)
	if pCharacter.m_Properties:GetType() == ECharacterType.IntObj then
		return 
	end
	pCharacter:SetOnDisappear(true) 
end
-- ��ͬNpc�Ӳ�ͬ��
function CAddDifferentCount.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
	if not IsCppBound(pCharacter) then
		return
	end
	local Player = nil 
	local Score = nil
	if pCharacter.m_OwnerId ~= nil then
		Player = g_GetPlayerInfo(pCharacter.m_OwnerId)
	else
		Player = pCharacter
	end
	if not IsCppBound(Player) then
		return
	end
	
	for i=1, #(TrapArg) do
		NpcName = TrapArg[i][1]
		if NpcName == pCharacter.m_Name then
			Score = TrapArg[i][2]
			CMercenaryRoomCreate.KillTargetAddNum(Player.m_Scene, NpcName, Score)
			break
		end
	end
end

function CAddDifferentCount.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)

end

-- ��ͬ ״̬��Npc�Ӳ�ͬ��
function CAddDifferentStateCount.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
	if not IsCppBound(pCharacter) then
		return
	end
	local Player = nil 
	local Score = nil
	if pCharacter.m_OwnerId ~= nil then
		Player = g_GetPlayerInfo(pCharacter.m_OwnerId)
	else
		Player = pCharacter
	end
	if not IsCppBound(Player) then
		return
	end
	
	for i=1, #(TrapArg) do
		NpcState = TrapArg[i][1]
		if pCharacter:ExistState(NpcState)  then
			Score = TrapArg[i][2]
			CMercenaryRoomCreate.KillTargetAddNum(Player.m_Scene, pCharacter.m_Name, Score)
			break
		end
	end
end

function CAddDifferentStateCount.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)
	
end

-- 2����ͬNPC�Ž�TRAP�ͼӷ֣�����NPC��ʧ  
function CAddSameNpcCount.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
	if not IsCppBound(pCharacter) then
		return
	end
	
	-- ����
	if not IsCppBound(pTrapHandler.FirstNpc) then
		if pCharacter.m_CreateAnotherPigTick then
			UnRegisterTick(pCharacter.m_CreateAnotherPigTick)
			pCharacter.m_CreateAnotherPigTick = nil
		end
		pTrapHandler.NpcCount = 1
		pTrapHandler.FirstNpc	= pCharacter
		pTrapHandler.ExistNpcName = pCharacter.m_Name -- ����NPC����
	else
		-- ����ȷ ������
		if pCharacter.m_Name == pTrapHandler.ExistNpcName
				and pTrapHandler.NpcCount == 1 then				-- �ɹ���pTrapHandler.NpcCount��Ϊ����
					
			pTrapHandler.NpcCount = pTrapHandler.NpcCount + 1
				-- ȡ��Tick����ԭ������NPC
			if pCharacter.m_CreateAnotherPigTick then
				UnRegisterTick(pCharacter.m_CreateAnotherPigTick)
				pCharacter.m_CreateAnotherPigTick = nil
			end
			
			if pTrapHandler.FirstNpc.m_CreateAnotherPigTick then
				UnRegisterTick(pTrapHandler.FirstNpc.m_CreateAnotherPigTick)
				pTrapHandler.FirstNpc.m_CreateAnotherPigTick = nil
			end	
			
			pCharacter.m_IsNotEmbrace = true
			pTrapHandler.FirstNpc.m_IsNotEmbrace = true
			
			-- ��Ч
			local ModelString = "fx/setting/other/other/fuwen_green/explode.efx"
			local StateString = "fuwen_green/explode"
			local PlayerID = pCharacter.m_OwnerId
			local Player = g_GetPlayerInfo(PlayerID)
			local NpcID = pCharacter:GetEntityID()
			local FirstNpcID = pTrapHandler.FirstNpc:GetEntityID()
			if IsCppBound(Player) then
				Gas2Gac:UseItemTargetEffect(Player.m_Conn, ModelString,StateString,NpcID)
				Gas2Gac:UseItemTargetEffect(Player.m_Conn, ModelString,StateString,FirstNpcID)
			end
			--Gas2Gac:UseItemTargetEffect(Player:GetIS(0), ModelString, StateString, Player:GetEntityID())
			
			local function DeleteTwoNpc()
				-- ������������ʧ
				pCharacter:SetNoDissolve()
				g_NpcServerMgr:DestroyServerNpcNow(pCharacter, false)
				-- ��һ������ʧ
				if IsCppBound(pTrapHandler.FirstNpc) then
					pTrapHandler.FirstNpc:SetNoDissolve()
					g_NpcServerMgr:DestroyServerNpcNow(pTrapHandler.FirstNpc, false)
				end		
			end
			
			RegisterOnceTick(pCharacter, "DeleteTwoNpcTick", DeleteTwoNpc, 1000)
		end
	end
	
	-- �������2��
	if pTrapHandler.NpcCount == 2 then
		-- �ӷ�
		local TargetName = TrapArg[1]
		if not TargetName or TargetName == "" then
			return
		end
		local Player = g_GetPlayerInfo(pCharacter.m_OwnerId)
		if not IsCppBound(Player) then
			return		
		end
		CMercenaryRoomCreate.KillTargetAddNum(Player.m_Scene, TargetName)	
	end
end

function CAddSameNpcCount.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)

end

function CYbActionNpcAddNum.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
	if not IsCppBound(pCharacter) then
		return
	end
		-- �ӷ�
	local TargetName = TrapArg[1]
	if not TargetName or TargetName == "" then
		return
	end
	CMercenaryRoomCreate.KillTargetAddNum(pCharacter.m_Scene, TargetName)
end

function CYbActionNpcAddNum.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)

end

function CAreaFbTransportTrap.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
	local TrapName = pTrapHandler.m_Owner.m_Properties:GetCharName()
	
	if not IsCppBound(pCharacter) then
		return
	end
	
	local SceneName = pCharacter.m_Scene.m_SceneName 
	local EndScene = nil
	local PosX,PosY = nil,nil
	if Transport_Server(TrapName) then
		for _, i in pairs(Transport_Server:GetKeys(TrapName, "����")) do
			local TransInfo = Transport_Server(TrapName, "����", i.."")
			if TransInfo("BeginScene") ~= "" 
				and TransInfo("BeginScene") == SceneName then
				EndScene = TransInfo("EndScene") 
				PosX = TransInfo("PosX") 
				PosY = TransInfo("PosY") 
				break
			end
		end
	end
	if EndScene == nil or EndScene == "" 
		or PosX == nil or PosX == "" 
		or PosY == nil or PosY == "" then
		return
	end
	if g_AreaFbLev[EndScene] == nil then
		return
	end
	
	CAreaFbServer.ChangeToAreaFb(pCharacter.m_Conn, EndScene)
end

function CAreaFbTransportTrap.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)

end

--������
function CSpecilAreaTrap.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
--	if not IsCppBound(pCharacter) then
--		return
--	end
--	
--	if not pTrapHandler.m_Owner.m_IsCanTransSpecilAreaFb then
--		--print("������û�д����ɹ�,�ȵ��ٽ�")
--		return
--	end
--	
--	if pCharacter.m_Properties:GetType() == ECharacterType.Player then
--		local Camp = pCharacter:CppGetBirthCamp()
--		
--		local TrapName = pTrapHandler.m_Owner.m_Properties:GetCharName()
--		local SceneId = pTrapHandler.m_Owner.m_SceneId
--		local ServerId = pTrapHandler.m_Owner.m_ServerId
--		local SceneName = pTrapHandler.m_Owner.m_SceneName
--		local TrapCamp = pTrapHandler.m_Owner.m_CreateSceneCamp
--		
--		local function CallBack(result)
--			if IsCppBound(pCharacter) then
--				if result then
--					local PosX,PosY = nil,nil
--					for _,v in pairs(Transport_Server) do
--						if v.ObjectName == TrapName and v.Type == "����" then
--							if SceneName == v.EndScene then
--								PosX = v.PosX
--								PosY = v.PosY
--								break
--							end
--						end
--					end
--					
--					if PosX and PosY then
--						MultiServerChangeScene(pCharacter.m_Conn, SceneId, ServerId, PosX, PosY)
--					end
--				else
--					--MsgToConn(pCharacter.m_Conn,)
--				end
--			end
--		end
--		
--		local param = {}
--		param["uCharId"] = pCharacter.m_uID
--		param["PlayerCamp"] = Camp
--		param["TrapCamp"] = TrapCamp
--		param["SceneId"] = SceneId
--		--CallAccountAutoTrans
--		CallAccountManualTrans(pCharacter.m_Conn.m_Account, "SceneMgrDB", "IsEnterScopesFb", CallBack, param)
--	end
end

function CChangeTongSceneByTrap.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
	if not IsCppBound(pCharacter) then
		return
	end
	ChangeTongSceneByTrap(pCharacter.m_Conn)
end

function CChangeTongSceneByTrap.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)

end


function CTakeBuffAddCount.OnStepInTrap(pTrapHandler, pCharacter, TrapArg)
	if not IsCppBound(pCharacter) then
		return
	end
	
	local stateCascade = pCharacter:GetStateCascade(TrapArg[1])
	if stateCascade > 0 then
		g_MatchGameMgr:AddMatchGameCount(pCharacter, 11, TrapArg[1], stateCascade)
	end
end

function CTakeBuffAddCount.OnStepOutTrap(pTrapHandler, pCharacter, TrapArg)

end
