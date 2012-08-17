CLevelUpGas = class()

local FirstTimeSendMsgTbl = {
			[2] = {"�ȼ�2",3002},
			[4] = {"�ȼ�4",3004},
			[5] = {"�ȼ�5",3005},
			[6] = {"�ȼ�6",3006},
			[8] = {"�ȼ�8",3008},
			[10] = {"�ȼ�10",3010},
			[15] = {"�ȼ�15",3015},
			[20] = {"�ȼ�20",3020},
			[30] = {"�ȼ�30",3030},
			[40] = {"�ȼ�40",3040},
			}

local function SendPlayerFirstInfo(Player,Level)
	local MsgType = FirstTimeSendMsgTbl[Level]
	if MsgType then
		Player:IsFirstTimeAndSendMsg(MsgType[1], MsgType[2], sMsg)
	end
end


--���ȼ����������������ߵȼ��йصĲ���
local function AddVarNumForLevelQuest(Player, uLevel)
	if not (IsCppBound(Player) and IsCppBound(Player.m_Conn)) then
		return
	end
	
	local sVarName = "�ȼ�"..uLevel
	if g_VarQuestMgr[sVarName] == nil then
		sVarName = nil
	end
	
	local function CallBack(LevelQuestInfo)
		if LevelQuestInfo["PlayerAddQuestInfo"] then
			for PlayerId, QuestTbl in pairs(LevelQuestInfo["PlayerAddQuestInfo"]) do 
				local num = table.getn(QuestTbl)
				for i = 1, num do
					local Player = g_GetPlayerInfo(PlayerId)
					if IsCppBound(Player) then
						local res = QuestTbl[i]
						Gas2Gac:RetAddQuestVar(Player.m_Conn, res[1],res[2],res[3])
					end
				end
			end
		end
		
		if LevelQuestInfo["PlayerFailQuestInfo"] and IsCppBound(Player) then
			for i=1, #(LevelQuestInfo["PlayerFailQuestInfo"]) do
				local succ = LevelQuestInfo["PlayerFailQuestInfo"][i][1]
				local QuestName = LevelQuestInfo["PlayerFailQuestInfo"][i][2]
				if succ then
					CRoleQuest.QuestFailure_DB_Ret(Player,QuestName)
				end
			end
		end
	end
	
	--�ó�������ȼ�����������ʧ��
	local data = {}
	data["iNum"] = 1
	data["sVarName"] = sVarName
	data["char_id"] = Player.m_uID
	data["Level"] = uLevel
	data["CanShareTeamMateTbl"] = {}
	
	local ChannelIDList = {}
	local TeamID = Player.m_Properties:GetTeamID()
	if TeamID and TeamID ~= 0 then
		local SceneName = Player.m_Scene.m_SceneName
		local tblMembers = g_TeamMgr:GetMembers(TeamID)
		for i = 1, #(tblMembers) do
			local Member = g_GetPlayerInfo(tblMembers[i])
			if tblMembers[i] ~= Player.m_uID 
				and Member 
				and SceneName == Member.m_Scene.m_SceneName
				and g_AreaMgr:CheckIsInSameArea(SceneName,Player,Member) then
					table.insert(ChannelIDList, Member.m_AccountID)
					table.insert(data["CanShareTeamMateTbl"],tblMembers[i])
			end
		end
	end
	
	CallAccountAutoTrans(Player.m_Conn.m_Account, "RoleQuestDB","AddVarNumForLevelQuests", CallBack, data,unpack(ChannelIDList))
end

local function ClearActionJoinCount(Player, ulevel)
	local Conn = Player.m_Conn 
	if IsCppBound(Conn) then
		if(ulevel == 15) then
			local data = {}
			data.CharId = Player.m_uID
			data.ActivityName = "Ӷ��ѵ���"
--			CallAccountAutoTrans(Conn.m_Account, "ActivityCountDB", "ClearActionJoinCount", nil, data)
			CallDbTrans("ActivityCountDB", "ClearCurCycAndHistoryCount", nil, data, Player.m_uID)
		end
	end
end

local function SetPlayerPkState(Player, ulevel)
	if string.find(Player.m_AreaName, "ǰ��") and not string.find(Player.m_AreaName,"ǰ��ɽ��") then
		if ulevel > 40 then
			Player:CppSetPKState(true)
		else
			Player:CppSetPKState(false)
		end
		Gas2Gac:TransferSwitchState(Player.m_Conn,Player.m_SwitchState)
		Gas2Gac:UpdatePkSwitchState(Player.m_Conn)
		Gas2Gac:UpdateHeadInfoByEntityID(Player:GetIS(0), Player:GetEntityID())
	end
end

function CLevelUpGas.SetLevel(Player,ulevel)
	Player:CppSetLevel(ulevel)
	SendPlayerFirstInfo(Player,ulevel)
	SetPlayerPkState(Player, ulevel)
	CRoleQuest.PlayerSendTempQuestList(Player)
	--�������������һЩ�����ȼ�������ʧ��
	AddVarNumForLevelQuest(Player, ulevel)
	--����Ӷ���ȼ�׷�ٴ���
	--AddLevelUpdateMercenaryLevelTraceWnd(Player)
	
	-- �������15��ʱ����������������
	ClearActionJoinCount(Player, ulevel)
	
	-- �����󣬼�¼������ʱ��
	local data = {}
	data.CharID = Player.m_uID
	data.LevelNum = Player:CppGetLevel()
	--��ɫ����ˢ��ս����
	CGasFightingEvaluation.UpdateFightingEvaluationInfo(Player)
	CallAccountAutoTrans(Player.m_Conn.m_Account, "GasRoleLevelUpAttentionDB","SavePlayerLevelUpTime", nil, data)
end
