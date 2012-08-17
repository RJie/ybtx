gas_require "activity/quest/RoleQuest"
gas_require "world/npc/NpcDropItem"
gas_require "activity/quest/GiveUpQuest"

CQuestNotepad = class()

--���캯��
--������±��������ĳ����ɫ����
function CQuestNotepad:Ctor(uPlayerId)
	assert(IsNumber(uPlayerId))
	self.m_uPlayerId = uPlayerId
end

--��������������Ϣ
function CQuestNotepad:GetAllQuest(Player,QuestAllTbl,QuestVarTbl,QuestAwardItemTbl,QuestLoopTbl,TongBuildTbl)
	for i=1, #(QuestLoopTbl) do
		Gas2Gac:RetGetQuestLoop(Player.m_Conn, QuestLoopTbl[i][1], QuestLoopTbl[i][2])
	end
	
	--self.m_DbQuestAll = QuestAllTbl
	for i = 1, #(QuestAllTbl) do
		local QuestName = QuestAllTbl[i][1]
		local QuestAcceptTime = QuestAllTbl[i][2]
		local State = QuestAllTbl[i][3]
		local IsLimitTime = QuestAllTbl[i][4]
		
		--�����assert��Ϊ��Ԥ���ڿ����ڲ߻����������ñ��µ�Bug�������ڿ���ȥ��
		local IsSend = true
		if not Quest_Common(QuestName) then
			CfgLogErr("�������ñ����Ѿ��Ҳ�����������"..QuestName.."�����߻��Ѿ������ñ����޸Ļ���ɾ����������")
			IsSend = false
--			assert(false, "�������ñ����Ѿ��Ҳ�����������"..QuestName.."�����߻��Ѿ������ñ����޸Ļ���ɾ��������������֪ͨ����������Ա�ֶ������ݿ���ɾ������������ؽ����ݿ⣡���˽����ֶ�ɾ�������񣡣�delete from tbl_quest where q_sName = '"..QuestName.."'��")
		else
			if QuestVarTbl[QuestName] then
				for j = 1, table.getn(QuestVarTbl[QuestName]) do
					local varname = QuestVarTbl[QuestName][j][1]
					if not g_QuestNeedMgr[QuestName] 
						or not g_QuestNeedMgr[QuestName][varname] then
						IsSend = false
						CfgLogErr("����"..QuestName.."�����������ñ��е���������"..varname.."���Ѿ����߻��޸�")
						break
					end
				end
			end
		end
		
		if IsSend then
			if State == QuestState.init then
				CRoleQuest.NpcFromQuest_Add(Player, QuestName)
			end
			Gas2Gac:RetGetQuest(Player.m_Conn, QuestName, State, QuestAcceptTime, IsLimitTime, QuestAwardItemTbl[QuestName] or 0)
			if State ~= QuestState.finish then
				if Quest_Common(QuestName, "������״̬����") then
					local Keys = Quest_Common:GetKeys(QuestName, "������״̬����")
					for k = 1, table.getn(Keys) do
						local tbl = GetCfgTransformValue(true, "Quest_Common", QuestName, "������״̬����", Keys[k], "Function")
						local needbuff = tbl[1]		--�����Buff��
						if Player:ExistState(needbuff) then
							Gas2Gac:RetQuestBuffVar(Player.m_Conn, QuestName, needbuff, 1)
						end
					end
				end
				if QuestVarTbl[QuestName] then
					for j = 1, table.getn(QuestVarTbl[QuestName]) do
						local varname = QuestVarTbl[QuestName][j][1]
						local donum = QuestVarTbl[QuestName][j][2]
						Gas2Gac:RetQuestVar(Player.m_Conn, QuestName,varname,donum)
					end
				end
			end
		end
	end
	
	Gas2Gac:InitMasterStrokeQuestLevTbl(Player.m_Conn)
	
	if Player.m_Properties:GetTongID() ~= 0 then
		AddVarNumForTeamQuest(Player, "�������", 1)
	end
	for _, BuildName in pairs(TongBuildTbl) do
		AddVarNumForTeamQuest(Player, "���"..BuildName, 1)
	end
end

function CQuestNotepad:ChangeInScene_GetAllQuest(Player,QuestAllTbl)
	for i = 1, #(QuestAllTbl) do
		local QuestName = QuestAllTbl[i][1]
		local QuestAcceptTime = QuestAllTbl[i][2]
		if Quest_Common(QuestName) then
			CRoleQuest.NpcFromQuest_Add(Player, QuestName)
		end
	end
end

function KillNpcAddQuestVar(AddQuestResTbl)
	local resnum = #(AddQuestResTbl)
	for i = 1,resnum do
		local restbl = AddQuestResTbl[i]
		local PlayerId = restbl[1]
		local Member = g_GetPlayerInfo(PlayerId)
		if Member ~= nil then
			--local RoleQuest = CRoleQuest:new(PlayerId)
			local addres = restbl[2]
			local num = table.getn(addres)
			for j=1,num do
				local res = addres[j]
				Gas2Gac:RetAddQuestVar(Member.m_Conn, res["QuestName"], res["VarName"], res["AddNum"])
			end
		end
	end
end

---------------------------------rpc function--------------------------------------------

function Gac2Gas:SendSuccStateName(Conn, questname, StateName)
	local Player = Conn.m_Player
	if not IsCppBound(Player) then
		return
	end
	
	local PlayerId = Player.m_uID
	local function CallBack(result)
		if result and IsCppBound(Player) then
			Gas2Gac:RetAddQuestVar(Player.m_Conn, questname, StateName, 1)
		end
	end
	
	if Player:ExistState(StateName)
		and g_QuestNeedMgr[questname] 
		and g_QuestNeedMgr[questname][StateName] then
			local params = {
			["sQuestName"] = questname,
			["sVarName"] = StateName,
			["iNum"] = 1,
			["char_id"] = PlayerId
			}
			CallAccountAutoTrans(Conn.m_Account, "RoleQuestDB","AddQuestVarNum",CallBack,params)
	end
end

function AddQuestTheaterVar(TheaterName, SceneId, Pos, Radius)
	local CoreScene = g_SceneMgr.m_tbl_Scene[SceneId].m_CoreScene
	if not CoreScene then
		return
	end
	local IsDestory = CoreScene:Destroying()
	if IsDestory then
		return
	end		
	local QueryMgr = CGameGridRadiusCallback:new()
	QueryMgr:QueryObjs(CoreScene, Pos, Radius)
	local PlayerTbl = QueryMgr:QueryByECharacterType(ECharacterType.Player)
	local function CallBack(result)
		--print("run AddQuestTheaterVar...")
		for PlayerId,v in pairs(result) do
			local Player = g_GetPlayerInfo(PlayerId)
			if Player then
				Gas2Gac:RetAddQuestVar(Player.m_Conn, v["questname"], v["VarName"], v["AddNum"])
			end
		end
	end
	
	local ChannelIDList = {}
	local params = {}
	params["TheaterName"] = TheaterName
	params["PlayerTbl"] = {}
	for i = 1, table.getn(PlayerTbl) do
		table.insert(params["PlayerTbl"],PlayerTbl[i].m_uID)
		table.insert(ChannelIDList,PlayerTbl[i].m_AccountID)
	end
	
	if not next(ChannelIDList) then
		ChannelIDList[1] = 1
	end
	CallDbTrans("RoleQuestDB", "AddQuestTheater",CallBack,params,unpack(ChannelIDList))
end

function TriggerHideQuest(Player, HideQuestName)
	if g_HideQuestMgr[HideQuestName] ~= nil then
		--��ѯPlayer�Ƿ����
		--��ѯ�����Ƿ��Ѿ�����Ӧ����.���ݿ�
		--��ѯ�����Ƿ�Ϊ���ظ�����.�ڴ�
		local TeamID = Player.m_Properties:GetTeamID()
		if TeamID ~= 0 then
			local tblMembers = g_TeamMgr:GetMembers(TeamID)
			local membernum = #(tblMembers)
			for k = 1, membernum do
				local memberid = tblMembers[k]
				local TeamMember = g_GetPlayerInfo(memberid)
				if TeamMember ~= nil then
					g_HideQuestMgr[HideQuestName][memberid] = true
					Gas2Gac:SendHideQuestSign(TeamMember.m_Conn, HideQuestName)
				end
			end
		else
			g_HideQuestMgr[HideQuestName][Player.m_uID] = true
			Gas2Gac:SendHideQuestSign(Player.m_Conn, HideQuestName)
		end
	end
end

-- ���Ӷ���ָ������sQuestName��ָ������sVarName�ļ���
function g_AddQuestVarNumForTeam(Player, QuestName,VarName,AddNum)
--	local QuestName = data["sQuestName"]
	if not IsCppBound(Player) or not IsCppBound(Player.m_Conn) then
		return	
	end
	
	if not QuestName then
		CfgLogErr("�����޷����:ԭ����������������!")
		return
	end
	
	if g_QuestNeedMgr[QuestName] == nil then
		CfgLogErr("�����޷����:ԭ���ǲ���������["..QuestName.."]")
		return
	end
	
	if not VarName then
		CfgLogErr("�����޷����:ԭ���������������Ϊ��!")
		return
	end
	
	if g_QuestNeedMgr[QuestName][VarName] == nil then
		CfgLogErr("�����޷����:ԭ���������в����������������["..VarName.."]")
		return
	end
	
	if not IsNumber(AddNum) then
		CfgLogErr("�����޷����:ԭ�������������������ֵ!")
		return
	end
	
	local function CallBack(tbl)
		for PlayerId, isSuccess in pairs(tbl) do
			local Player = g_GetPlayerInfo(PlayerId)
			if isSuccess and Player then
				Gas2Gac:RetAddQuestVar(Player.m_Conn, QuestName, VarName,AddNum)
			end
		end
	end
	
	local TeamID = Player.m_Properties:GetTeamID()
	local data = {}
	data["char_id"] = Player.m_uID
	data["iNum"] = AddNum
	data["sQuestName"] = QuestName
	data["sVarName"] = VarName
	data["CanShareTeamMateTbl"] = {}
	
	local ChannelIDList = {}
	if TeamID and TeamID ~= 0 then
		local SceneName = Player.m_Scene.m_SceneName
		local bNotShare = g_QuestNeedMgr[QuestName][VarName].bNotShare
		if not bNotShare then
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
	end
	
	CallAccountAutoTrans(Player.m_Conn.m_Account, "RoleQuestDB", "AddQuestVarNumForTeam", CallBack, data, unpack(ChannelIDList))
end

--���ӶӶ�����������Ϊ��sVarName������������ļ���
function AddVarNumForTeamQuest(Player, sVarName, AddNum)
--	local varname = data["sVarName"]
	if g_VarQuestMgr[sVarName] == nil then
		return
	end
	
	local Conn = Player.m_Conn
	if not IsCppBound(Conn) then
		return
	end
	local function CallBack(tbl)
		for PlayerId, QuestTbl in pairs(tbl) do 
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
	
	local TeamID = Player.m_Properties:GetTeamID()
	local data = {}
	data["iNum"] = AddNum
	data["sVarName"] = sVarName
	data["char_id"] = Player.m_uID
	data["CanShareTeamMateTbl"] = {}
	
	local ChannelIDList = {}
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
	
	CallAccountAutoTrans(Conn.m_Account, "RoleQuestDB","AddVarNumForTeamQuests", CallBack, data,unpack(ChannelIDList))
end

function GetQuestAddItemErrorMsgID(ErrorNum)
	if ErrorNum == 3 then
		return 160000
	elseif ErrorNum == 4 then
		return 3030
	elseif ErrorNum == 5 then
		return 3031
	end
	return nil
end

function Gas2GasDef:AddVarNumForTeamQuest(Conn, PlayerId, sVarName, AddNum)
	local Player = g_GetPlayerInfo(PlayerId)
	if Player and IsCppBound(Player) then
		AddVarNumForTeamQuest(Player, sVarName, AddNum)
	end
end