gas_require "world/facial_action/FacialActionInc"
gas_require "world/player/CreateServerPlayerInc"
gas_require "log_mgr/CLogMgr"

----------------------------------------�����ķָ���-------------------------------------
--      								һЩ�ֲ�����
-----------------------------------------------------------------------------------------
--������Ǯ
local function FacialAddMoneyDB()
	
end

--������Ʒ
local function FacialAddItemDB(Player, ItemType, ItemName, nCount)
	--local Player=g_GetPlayerInfo(CharId)

	local function callback(result)
		if IsNumber(result) and IsCppBound(Player) then
			if result == 3 then
				MsgToConn(Player.m_Conn, 160000)
			elseif result == 0 then
				MsgToConn(Player.m_Conn, 8003, 'CreateFightItem error')
			end
			return
		end
		CRoleQuest.add_item_DB_Ret(Player, ItemType, ItemName, nCount, result)
	end

	local data = {}
	data["char_id"]		= Player.m_uID
	data["nType"]		= ItemType
	data["sName"] 		= ItemName
	data["nCount"]		= nCount
	data["createType"] = event_type_tbl["���鶯��"]
	--local CharacterMediatorDB = (g_DBTransDef["CharacterMediatorDB"])
	local Conn = Player.m_Conn
	CallAccountManualTrans(Conn.m_Account, "CharacterMediatorDB", "AddItem", callback, data)
end

--�����Ѻö�
local function FacialAddMarkDB(PlayerID, NpcOrObjId)
	
end

--��������
local function FacialAddExpDB(Player, uLevelExp)
	Player.m_uLevelExp = Player.m_uLevelExp + uLevelExp
	local nCurlevel = Player:CppGetLevel()
	local old_level = nCurlevel
	if nCurlevel == LevelExp_Common.GetHeight() then
		return
	end
	if nCurlevel == g_TestRevisionMaxLevel then
		return
	end
	while Player.m_uLevelExp >= LevelExp_Common(nCurlevel, "ExpOfCurLevelUp") do
		--���������������ǰ����Ϊ0
		if( LevelExp_Common(nCurlevel, "ExpOfCurLevelUp") == 0 ) then
			Player.m_uLevelExp = 0
			break
		end
		--��ȥ�������飬��������һ��
		Player.m_uLevelExp = Player.m_uLevelExp - LevelExp_Common(nCurlevel, "ExpOfCurLevelUp")
		--self:CppLevelUp()

		nCurlevel=nCurlevel+1
		if nCurlevel == LevelExp_Common.GetHeight() then
			Player.m_uLevelExp=0
		end
		if nCurlevel == g_TestRevisionMaxLevel then
			Player.m_uLevelExp=0
		end
	end
	
	local function callback(result) --����DBAddExp��������İ�callback����������
		CLevelUpGas.SetLevel(Player,nCurlevel)
		--Player:CppSetLevel(nCurlevel)
		Player:SetSkillToPlayer()
		local nCurlevel = Player:CppGetLevel()
		if old_level ~= nCurlevel then
			CGasTeam.SetTeamMemberLevel(Player.m_uID)
		end
		if(nCurlevel==60) then
			Gas2Gac:NotifyOpenPanel(Player.m_Conn,2)
		end
		if(nCurlevel==120) then
			Gas2Gac:NotifyOpenPanel(Player.m_Conn,2)
			Gas2Gac:NotifyOpenPanel(Player.m_Conn,3)
		end
		Gas2Gac:SetExp( Player.m_Conn, Player.m_uLevelExp, 0, LevelExp_Common(nCurlevel, "ExpOfCurLevelUp") )
	end
	
	local data = {}
	data["char_id"] 		= Player.m_Properties:GetCharID()
	data["char_level"]	= nCurlevel
	data["char_exp"]	= Player.m_uLevelExp
	data["nAdd"] 		= nCurlevel - Player:CppGetLevel()
	--local CharacterMediatorDB = (g_DBTransDef["CharacterMediatorDB"])
	--CharacterMediatorDB.AddLevel(data)
	local Conn = Player.m_Conn
	--CallAccountManualTrans(Conn.m_Account, "CharacterMediatorDB", "AddLevel", callback, data)
end

local function ChangeCampBackTick(Tick, Npc, Camp)
	Npc:CppSetCamp(Camp)
	UnRegisterTick(Npc.ChangeCampTick)
	Npc.ChangeCampTick = nil
end

local function ChangeModel(Player, npc, NewNpcName, NewNpcLevel)
	local scene = npc.m_Scene
	local pos = CFPos:new()
	npc:GetPixelPos(pos)

	npc:SetOnDisappear(true)
	
	local otherData = {}
	if IsCppBound(Player) then
		otherData["m_CreatorEntityID"] = Player:GetEntityID()    --yy 
		otherData["m_OwnerId"] = Player.m_uID
	end
	
	local newNpc = g_NpcServerMgr:CreateServerNpc(NewNpcName, NewNpcLevel, scene, pos, otherData)
	
	return true
end

--���������yy  2009-7-16 15:44:58
local function FacialAddQuestNum(Player, Target, ActName)
	local TargetName = Target.m_Properties:GetCharName()
	local varname = "��" .. TargetName .. ActName	
	AddVarNumForTeamQuest(Player, varname,1)
end

-----------------------------------------------------------------------------------------------------------------------

function CFacialAction:Ctor()
	self.m_tblFacialAction = {}
	self.m_tblReaction = {}
	self.m_tblFacialCoolDown = {}
--	for i, v in pairs(NpcFacialResponse_Server) do
--		self.m_tblFacialAction[v["NPCName"]] = self.m_tblFacialAction[v["NPCName"]] or {}
--		self.m_tblFacialAction[v["NPCName"]][v["Action"]] = self.m_tblFacialAction[v["NPCName"]][v["Action"]] or {}
--		self.m_tblFacialAction[v["NPCName"]][v["Action"]][v["Condition"]] = v
--		--table.insert(self.m_tblFacialAction[v["NPCName"]][v["Action"]], v)
--	end
end



function CFacialAction:BeDoReaction(Player, ActionName, Target)
	local NpcOrObjId = Target:GetEntityID()
	local TargetType = Target.m_Properties:GetType()
	local TargetName = Target.m_Properties:GetCharName()
	if(self.m_tblFacialCoolDown[NpcOrObjId] ~= nil and self.m_tblFacialCoolDown[NpcOrObjId][ActionName] ~= nil) then
		return
	end
	FacialAddQuestNum(Player, Target, ActionName)
--	local tbl_priority = 
--	{
--		["��ͨ"] 	= 1,
--		["�ȼ�"] 	= 2,
--		["����"] 	= 3,
--	}
--	
	if self.m_tblReaction[NpcOrObjId] then
		return
	end
	
	if not self.m_tblFacialAction[TargetName] then
		return
	end
	
	if not self.m_tblFacialAction[TargetName][ActionName] then
		return
	end
	
	if next(self.m_tblFacialAction[TargetName][ActionName]) == nil then
		return
	end
	
	local ActionMgr = self.m_tblFacialAction[TargetName][ActionName]
	local PlayerEntityID = Player:GetEntityID()
	
	local function ReactionFunc(result)
		local Npc = CCharacterDictator_GetCharacterByID(NpcOrObjId)
		local Obj = CIntObjServer_GetIntObjServerByID(NpcOrObjId)
		local Target = Npc or Obj
		if not Target then
			return
		end
		
		if self.m_tblReaction[NpcOrObjId] then
			return
		end
		
		if(self.m_tblFacialCoolDown[NpcOrObjId] ~= nil and self.m_tblFacialCoolDown[NpcOrObjId][ActionName] ~= nil) then
			return
		end
		
		local Player = CEntityServerManager_GetEntityByID(PlayerEntityID)
		if Player == nil then
			return
		end
		
		if result == QuestState.init then
			self.m_tblReaction[NpcOrObjId] = ActionMgr["����"]
		elseif ActionMgr["�ȼ�"] 
			and Player:CppGetLevel() >= tonumber(ActionMgr["�ȼ�"]["ConditionArg"])
			and GetProcessTime() % 100 <= tonumber(ActionMgr["�ȼ�"]["Probability"]) then
				
			self.m_tblReaction[NpcOrObjId] = ActionMgr["�ȼ�"]
		elseif ActionMgr["��ͨ"] and GetProcessTime() % 100 <= tonumber(ActionMgr["��ͨ"]["Probability"]) then
			self.m_tblReaction[NpcOrObjId] = ActionMgr["��ͨ"]
		end
		if self.m_tblReaction[NpcOrObjId] == nil then
			return
		end
		
		if TargetType == ECharacterType.Npc then
			Npc:FacialActionHappened(PlayerEntityID, ActionName)	
		elseif TargetType == ECharacterType.IntObj then
--			print("��Obj�����鶯����")
			self:DoRealReaction( PlayerEntityID, NpcOrObjId)
		end
	end
	
	if ActionMgr["����"] and ActionMgr["����"]["ConditionArg"] ~= "" then
		if CRoleQuest.DoingQuest_Check(Player, ActionMgr["����"]["ConditionArg"]) then
			ReactionFunc(QuestState.init)
		end
		return
	elseif ActionMgr["�ȼ�"] 
		and Player:CppGetLevel() >= tonumber(ActionMgr["�ȼ�"]["ConditionArg"]) 
		and GetProcessTime() % 100 <= tonumber(ActionMgr["�ȼ�"]["Probability"]) then
		self.m_tblReaction[NpcOrObjId] = ActionMgr["�ȼ�"]
	elseif ActionMgr["��ͨ"] and GetProcessTime() % 100 <= tonumber(ActionMgr["��ͨ"]["Probability"]) then
		self.m_tblReaction[NpcOrObjId] = ActionMgr["��ͨ"]
	end
	if self.m_tblReaction[NpcOrObjId] then
		local Npc = CCharacterDictator_GetCharacterByID(NpcOrObjId)
		local Obj = CIntObjServer_GetIntObjServerByID(NpcOrObjId)
		local Target = Npc or Obj
		if not Target then
			return
		end
		
		if TargetType == ECharacterType.Npc then
			Npc:FacialActionHappened(PlayerEntityID, ActionName)	
		elseif TargetType == ECharacterType.IntObj then
--			print("��Obj�����鶯����")
			self:DoRealReaction( PlayerEntityID, NpcOrObjId)
		end
	end
	return
end

function CFacialAction:GetPlayerInfoTbl(Player)
	local tbl = {}
	tbl ={
			["#level#"]	= Player:CppGetLevel(),
		}
	return tbl
end

function CFacialAction:GetResult(Player, Str)
	local ustr = Str
	local Tbl = self:GetPlayerInfoTbl(Player)
	
	for i,v in pairs(Tbl) do
		ustr = string.gsub(ustr, i, v)
	end
	
	return loadstring("return " .. ustr)()
end

function CFacialAction:DoRealReaction(EntityId, NpcOrObjId)
	local Player = CEntityServerManager_GetEntityByID(EntityId)
	local Npc = CCharacterDictator_GetCharacterByID(NpcOrObjId)
	local Obj = CIntObjServer_GetIntObjServerByID(NpcOrObjId)
	local Target = Npc or Obj
	if not Target then
		return
	end
	local TargetType = Target.m_Properties:GetType()
	local tblReaction = self.m_tblReaction[NpcOrObjId]
	local ActionName = tblReaction["Action"]
--	print(EntityId.."��"..NpcOrObjId.."ʹ�ñ��鶯��"..ActionName)
	--�����񴥷�.yy
	-- ʹ�ñ���ɹ�
	local it = 1
	while tblReaction["Reaction" .. tostring(it)] ~= "" do
		if tblReaction["Reaction" .. tostring(it)] == "������������" then
			local HideQuestName = tblReaction["ReactionArg" .. tostring(it)]  -- ������������
			--g_HideQuestMgr[HideQuestName][Player.m_uID] = true 
			--Gas2Gac:SendHideQuestSign(Player.m_Conn, HideQuestName)
			TriggerHideQuest(Player, HideQuestName)
		elseif tblReaction["Reaction" .. tostring(it)] == "˵��" then
			if TargetType == ECharacterType.Npc then
				Gas2Gac:SendNpcRpcMessage(Target:GetIS(0), NpcOrObjId,ChannelIdTbl["����"], tblReaction["ReactionArg" .. tostring(it)])
			end
		
		elseif tblReaction["Reaction" .. tostring(it)] == "����" then
			if TargetType == ECharacterType.Npc then
				local ActionState = CActorCfg_GetEnumByString(tblReaction["ReactionArg" .. tostring(it)])	
				Target:SetAndSyncActionState(ActionState)
			end

		elseif tblReaction["Reaction" .. tostring(it)] == "����Ӫ" then
			if TargetType == ECharacterType.Npc then
				local info = loadstring("return " .. tblReaction["ReactionArg" .. tostring(it)])()
				local OldCamp = Target:CppGetCamp()
				Target:CppSetCamp(tonumber(info[1]))
				Target.ChangeCampTick = RegisterTick("ChangeCampBackTick", ChangeCampBackTick, tonumber(info[2]) * 1000, Target, OldCamp)
			end
		
		elseif tblReaction["Reaction" .. tostring(it)] == "����" then
			if TargetType == ECharacterType.Npc then
				local newnpcinfo = loadstring("return " .. tblReaction["ReactionArg" .. tostring(it)])()
				local NewNpcName = newnpcinfo[1]
				local NewNpcLevel = newnpcinfo[2]			
				ChangeModel(Player ,Target, NewNpcName, NewNpcLevel)
			end
		elseif tblReaction["Reaction" .. tostring(it)] == "������Ʒ" then
			local ItemInfo = loadstring("return " .. tblReaction["ReactionArg" .. tostring(it)])()
			local ItemType = ItemInfo[1]
			local ItemName = ItemInfo[2]
			local nCount   = ItemInfo[3]
			--local CharId   = Player.m_uID
			FacialAddItemDB(Player, ItemType, ItemName, nCount)
				
		elseif tblReaction["Reaction" .. tostring(it)] == "��������" then	
		elseif tblReaction["Reaction" .. tostring(it)] == "�����Ѻö�" then
			
		elseif tblReaction["Reaction" .. tostring(it)] == "��������"	then
			local str = tonumber(tblReaction["ReactionArg" .. tostring(it)])
			local res = self:GetResult(Player, str)
			FacialAddExpDB(Player, res)
		end
		it = it + 1
	end
	if(self.m_tblFacialCoolDown[NpcOrObjId] == nil) then
		self.m_tblFacialCoolDown[NpcOrObjId] = {}
		self.m_tblFacialCoolDown[NpcOrObjId][ActionName] = {}
	elseif self.m_tblFacialCoolDown[NpcOrObjId][ActionName] == nil then
		self.m_tblFacialCoolDown[NpcOrObjId][ActionName] = {}
	end
	self.m_tblFacialCoolDown[NpcOrObjId][ActionName].m_coolDown = true;
	self.m_tblFacialCoolDown[NpcOrObjId][ActionName].m_pTick = RegisterTick("Facial_OnTick",Facial_OnTick,tblReaction["CoolDownTime"]*1000,NpcOrObjId,ActionName)
	self.m_tblReaction[NpcOrObjId] = nil
end

function Facial_OnTick(Tick, NpcOrObjId,ActionName)
--	UnRegisterTick(g_FacialAction.m_tblFacialCoolDown[NpcOrObjId][ActionName].m_pTick)
--	g_FacialAction.m_tblFacialCoolDown[NpcOrObjId][ActionName] = nil
end
	

function CFacialAction:DoReaction(Player, ActionName, NpcOrObjId)
	local Npc = CCharacterDictator_GetCharacterByID(NpcOrObjId)
	local Obj = CIntObjServer_GetIntObjServerByID(NpcOrObjId)
	local Target = Npc or Obj
	if not Target then
		return
	end
	local TargetName = Target.m_Properties:GetCharName()
	local strMsg = Player.m_Properties:GetCharName() .. "��" .. TargetName .. "����һ��" .. ActionName .. "����" 
	CChatChannelMgr.SendMsg(strMsg, Player.m_uID, 3)
	self:BeDoReaction(Player, ActionName, Target)
end

--g_FacialAction = g_FacialAction or CFacialAction:new() 

function Gac2Gas:FacialAction(Connection, NpcOrObjId, ActionName)
--	print(NpcOrObjId, ActionName)
	local player = Connection.m_Player
	--Gas2Gac:OtherPlayFacial(player:GetIS(1), player:GetEntityID(), ActionName)
	if NpcOrObjId ~= 0 then
--		g_FacialAction:DoReaction(player, ActionName, NpcOrObjId)
		return
	end
	local strMsg = "���Կյ�����һ��" .. ActionName .. "����"  
	Gas2Gac:PlayFacialActionFailed(Connection, strMsg)
end

function UnRegisterFacialTick()
--	for i,v in pairs(g_FacialAction.m_tblFacialCoolDown) do
--		for k,t in pairs(v) do
--			if(t.m_pTick ~= nil) then
--				UnRegisterTick(t.m_pTick)
----				print("ɾ��TICK")
--			end
--		end
--	end
end
				
