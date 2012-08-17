g_JFSPlayerCmpTick = nil

local m_FbName = "������"
local m_RoomName = "����������"

g_JiFenSaiRoomTbl = {}

local WaitEnterSceneTime = 30 --50 	--��ҿ��Խ�����ʱ��
local BeginGameTime = 60 --60  			--�ӳ�����������ʼ��ʱ��(��)

local PlayerGameState ={}
PlayerGameState.InGame = 1	--��ʾ����Ϸ��(������Ϣ)
PlayerGameState.InGameDead = 2	--��ʾ����Ϸ������
PlayerGameState.Running = 3	--��ʾ����
PlayerGameState.LeaveGame = 4	--��ʾ�����˳�(�������մ�����Ϣ)

local TeamCamp ={}
TeamCamp.One = 1	--��ʾ����1
TeamCamp.Two = 2	--��ʾ����2

local function FindPlayer(jfsInfo, charId)
	local charInfo = jfsInfo.m_PlayerIndex[charId]
	if charInfo then
		return jfsInfo.m_TeamTbl[charInfo.m_TeamId], charInfo
	end
end

local function DestroyRoom(RoomId)
	local Scene = g_SceneMgr:GetScene(RoomId)
	if not Scene then
		return
	end

	if Scene:IsHavePlayer() then
		return
	end
	Scene:Destroy()
end

local function PlayerExitFb(PlayerId,SpareTimes,MatchInfo)
	if SpareTimes < 0 then
		SpareTimes = 0
	end
	local Player = g_GetPlayerInfo(PlayerId)
	if IsCppBound(Player) then
		Gas2Gac:RetCloseFbActionWnd(Player.m_Conn,m_FbName)
		Gas2Gac:RetDelQueueFbAction(Player.m_Conn, m_FbName, true)
		MatchInfo = MatchInfo or ""
		Gas2Gac:RetOpenCountScoreWnd(Player.m_Conn,m_FbName,SpareTimes,MatchInfo)
	end
end

local function addexp_callback(PlayerId,LevelInfo)
	--�Ӿ���
	if LevelInfo then
		local Player = g_GetPlayerInfo(PlayerId)
		if IsCppBound(Player) then
			local AddExpTbl = {}
			AddExpTbl["Level"] = LevelInfo["CurLevel"]
			AddExpTbl["Exp"] = LevelInfo["LevelExp"]
			AddExpTbl["AddExp"] = LevelInfo["addExp"]
			AddExpTbl["uInspirationExp"] = 0
			CRoleQuest.AddPlayerExp_DB_Ret(Player, AddExpTbl)
		end
	end
end

local function AllPlayerExitFb(jfsInfo, DeadTeamID, IsAllExit)
	--�����˳�״̬��,�Ͳ����ٽ���
	if jfsInfo.m_State == g_FbRoomState.GameEnd then
		return
	end
	--�ı䵱ǰ����Ϸ״̬
	jfsInfo.m_State = g_FbRoomState.GameEnd
	
	--�������Ҫ�ӻ��߼��Ļ�����
	local TeamType = jfsInfo.m_GameType
	
	local ChannelIDList = {}
	local Member = {}
	local DeadRunAwayTbl = {}
	local PlayerKillNumTbl = {}
	local PlayerDeadNumTbl = {}
	for charId,charInfo in pairs(jfsInfo.m_PlayerIndex) do
		PlayerKillNumTbl[charId] = charInfo.m_KillCount
		PlayerDeadNumTbl[charId] = charInfo.m_BekillCount
		if not DeadRunAwayTbl[charInfo.m_TeamId] then
			DeadRunAwayTbl[charInfo.m_TeamId] = {}
		end
		
		DeadRunAwayTbl[charInfo.m_TeamId][charId] = charInfo.m_GameState
		
		if charInfo.m_TeamId ~= DeadTeamID and not IsAllExit then
			MsgToConnById(charId, 3422)
		else
			MsgToConnById(charId, 3423)
		end
		
		local Target = g_GetPlayerInfo(charId)
		if IsCppBound(Target) then
			table.insert(ChannelIDList, Target.m_AccountID)
			table.insert(Member, Target)
		else
			table.insert(ChannelIDList, charId)
		end
	end
	
	local function CallBack(result)
		if result then
			for index,_ in pairs(result) do
				local PlayerId = result[index]["PlayerId"]
				
				if result[index]["MatchPoint"] and result[index]["MatchPoint"] ~= 0 then
					MsgToConnById(PlayerId, 3402, result[index]["MatchPoint"])
					MsgToConnById(PlayerId, 3403, result[index]["CountPoint"])
				end
				
				if result[index]["PlayerState"] == 1 or result[index]["PlayerState"] == 2 then
					PlayerExitFb(PlayerId,result[index]["MatchTimes"],result[index]["MatchInfo"])
				end
				
				if result[index]["MatchTimes"] > 0 and result[index]["GloryPoint"] ~= 0 then
					Gas2GacById:UpdatePlayerPoint(PlayerId, 5, result[index]["GloryPoint"])
				end
				
				--�Ӿ���
				if result[index]["LevelInfo"] then
					addexp_callback(PlayerId, result[index]["LevelInfo"])
				end		
				
			end
		end
	end
	
	local parameters = {}
	parameters["DeadRunAwayTbl"] = DeadRunAwayTbl
	parameters["PlayerKillNumTbl"] = PlayerKillNumTbl
	parameters["PlayerDeadNumTbl"] = PlayerDeadNumTbl
	parameters["TeamType"] = TeamType
	parameters["time"] = os.time()
	parameters["DeadTeamID"] = DeadTeamID
	parameters["IsAllExit"] = IsAllExit
	OnSavePlayerExpFunc(Member)
	CallDbTrans("JiFenSaiFbDB", "UpdateDataInfo", CallBack, parameters, unpack(ChannelIDList))
end

local function GetTeamNum(jfsInfo,charId)
	local charInfo = jfsInfo.m_PlayerIndex[charId]
	
	local FriendNum = 0
	local EnemyNum = 0
	for teamid,teaminfo in pairs(jfsInfo.m_TeamTbl) do
		if charInfo.m_TeamId == teamid then
			FriendNum = teaminfo.m_PlayerNum
		else
			EnemyNum = teaminfo.m_PlayerNum
		end
	end
	return FriendNum,EnemyNum
end

--���¿ͻ��˵�������Ϣ
local function UpdateAllClientInfo(jfsInfo)
	for charId,charInfo in pairs(jfsInfo.m_PlayerIndex) do
		local player = g_GetPlayerInfo(charId)
		if player and charInfo.m_IsInScene then --δ�����Ĳ�����
			if charInfo.m_GameState == PlayerGameState.InGame then
				--or charInfo.m_GameState == PlayerGameState.InGameDead then
				
				local FriendNum,EnemyNum = GetTeamNum(jfsInfo,charId)
				Gas2Gac:RetJFSUpdateMemberInfo(player.m_Conn,FriendNum,EnemyNum)
				
			end
		end
	end
end

--�������е�����,����������
local function CheckTeamPlayer(jfsInfo, DeadTeamID)
	for charId,charInfo in pairs(jfsInfo.m_TeamTbl[DeadTeamID].m_PlayerTbl) do
		if charInfo.m_GameState == PlayerGameState.InGame then
			--or charInfo.m_GameState == PlayerGameState.InGameDead then
				
			return true--��ʾ������
				
		end
	end
	
	return false--��ʾû������
end


local function PlayerRunGame(jfsInfo,charInfo,charId)
	if jfsInfo.m_State == g_FbRoomState.GameEnd then
		return
	end
	
	for TargetId,_ in pairs(jfsInfo.m_TeamTbl[charInfo.m_TeamId].m_PlayerTbl) do
		if charId ~= TargetId then
			MsgToConnById(TargetId, 3424, charInfo.m_Name)
--			local Target = g_GetPlayerInfo(TargetId)
--			if IsCppBound(Target) then
--				MsgToConn(Target.m_Conn, 3424)--RunningName)
--			end
		end
	end
end

--�������������˳���״̬
local function RemovePlayer(jfsInfo, charId, GameState, IsExit)
	local teamInfo, charInfo = FindPlayer(jfsInfo, charId)
	if charInfo then
		local char = g_GetPlayerInfo(charId)
		--�ı�����������״̬
		if charInfo.m_IsInScene then
			if IsCppBound(char) then
				Gas2Gac:RetCloseFbActionWnd(char.m_Conn, m_FbName)
			end
		end
		
		--��������һ����
		if charInfo.m_GameState == PlayerGameState.InGame then
			if charInfo.m_IsInScene then
				teamInfo.m_PlayerNum = teamInfo.m_PlayerNum - 1
			end
			
			charInfo.m_GameState = GameState
		elseif charInfo.m_GameState == PlayerGameState.InGameDead then
			charInfo.m_GameState = PlayerGameState.LeaveGame
		end
		
		--����Ϣ˵,��������
		if GameState == PlayerGameState.Running then
			PlayerRunGame(jfsInfo,charInfo,charId)
		end
		
		UpdateAllClientInfo(jfsInfo)
		
		--����ǻ�û�б������˳��Ļ�,���ø����е��˼Ƿ�
		if IsExit or jfsInfo.m_State == g_FbRoomState.PlayerCanIn then
			return
		end
		
		--�жϿ��ǲ��ǻ�����ֻ�����ڱ���
		if not CheckTeamPlayer(jfsInfo, charInfo.m_TeamId) then
			AllPlayerExitFb(jfsInfo, charInfo.m_TeamId)
		end
	end
end

--������������
function DeadUpdateJiFenSaiInfo(killer, deader)
	local jfsInfo = deader.m_Scene.m_JfsInfo
	if IsCppBound(killer) then
		local killerId = killer.m_uID
		local killerTeam, killerInfo = FindPlayer(jfsInfo, killerId)
		if killerInfo then
			killerInfo.m_KillCount = killerInfo.m_KillCount + 1
		end
		local deaderId = deader.m_uID
		local deaderTeam, deaderInfo = FindPlayer(jfsInfo, deaderId)
		if deaderInfo then
			deaderInfo.m_BekillCount = deaderInfo.m_BekillCount + 1
		end
		
		CallAccountAutoTrans(killer.m_Conn.m_Account, "JiFenSaiFbDB", "UpdateKillNumSort", nil, {killerId})
	end
	
	--�޸ĵ�ǰ��ҵ�״̬(��������Ϸ��)............
	RemovePlayer(jfsInfo, deader.m_uID, PlayerGameState.InGameDead)
	
--	--������Ӿ���
--	if IsCppBound(deader) then
--		local data = {}
--		data["charId"] = deader.m_uID
--		local function CallBack(resExpInfo)
--			addexp_callback(data["charId"], resExpInfo)
--		end
--		OnSavePlayerExpFunc({deader})
--		CallAccountAutoTrans(deader.m_Conn.m_Account, "JiFenSaiFbDB", "JfsAddExp", CallBack, data)
--	end
	
	if jfsInfo.m_State == g_FbRoomState.GameEnd then
		deader.m_NotShowJFSMsgWnd = true--Ҫȫ�˳���ʱ��,�Ͳ�����ʾ�Ƿ�Ҫ����۲�ģʽ����
		if IsCppBound(killer) then
			killer.m_NotShowJFSMsgWnd = true--Ϊ�˷�ֹ������ͬ���ھ�(��һ���˻ᵯ���ڳ���)
		end
	end
	
end

--�����󵯳���ʾ����,ѡ���˳�����
function MsgSelExitIntegralMatch(Player)
	if IsCppBound(Player) then
		local jfsInfo = Player.m_Scene.m_JfsInfo
		--�޸ĵ�ǰ��ҵ�״̬(������)............
		ExitJiFenSaiGame(jfsInfo, Player.m_uID, PlayerGameState.LeaveGame, true)		
	end
end

--����ʱ����
function PlayerOffLineJiFenSaiFb(Player)
	local jfsInfo = Player.m_Scene.m_JfsInfo
	if jfsInfo then
		ExitJiFenSaiGame(jfsInfo, Player.m_uID, PlayerGameState.Running, true)
	end
end

local function CheckAllPlayerInFb(jfsInfo)
	--1��ʾû���˵�ȷ��;2��ʾֻ��һ�ӵ��˽����˸���;3��ʾ���븱��������������
	local TeamInScene = {}
	TeamInScene[TeamCamp.One] = {}
	TeamInScene[TeamCamp.Two] = {}
	TeamInScene[TeamCamp.One].HavePeople = false
	TeamInScene[TeamCamp.One].TeamId = 0
	TeamInScene[TeamCamp.Two].HavePeople = false
	TeamInScene[TeamCamp.Two].TeamId = 0
	for teamid,teaminfo in pairs(jfsInfo.m_TeamTbl) do
		TeamInScene[teaminfo.m_TeamNum].TeamId = teamid
		for charId,charInfo in pairs(teaminfo.m_PlayerTbl) do
			local player = g_GetPlayerInfo(charId)
			if player and charInfo.m_IsInScene and charInfo.m_GameState == PlayerGameState.InGame then
				TeamInScene[teaminfo.m_TeamNum].HavePeople = true
				break
			end
		end
	end
	
	if not TeamInScene[TeamCamp.One].HavePeople and not TeamInScene[TeamCamp.Two].HavePeople then
		AllPlayerExitFb(jfsInfo,nil,true)
		DestroyRoom(jfsInfo.m_Scene.m_SceneId)
	elseif not TeamInScene[TeamCamp.One].HavePeople then
		AllPlayerExitFb(jfsInfo,TeamInScene[TeamCamp.One].TeamId)
	elseif not TeamInScene[TeamCamp.Two].HavePeople then
		AllPlayerExitFb(jfsInfo,TeamInScene[TeamCamp.Two].TeamId)
	else
		return true
	end
end

local function BeginJiFenSaiTick(jfsInfo)
	jfsInfo.m_AllTeamCount = jfsInfo.m_LiveTeamCount
	
	if jfsInfo.m_State == g_FbRoomState.GameEnd then
		return
	end
	
	--������ڻ��ò��ÿ�����,���Ǳ�������
	if not CheckAllPlayerInFb(jfsInfo) then
		return
	end
	
	--�ı���Ϸ�е�״̬
	for charId,charInfo in pairs(jfsInfo.m_PlayerIndex) do
		local player = g_GetPlayerInfo(charId)
		if player and charInfo.m_IsInScene then
			local TeamNum = jfsInfo.m_TeamTbl[charInfo.m_TeamId].m_TeamNum
			player:SetGameCamp(TeamNum)
		end
	end
	for charId,charInfo in pairs(jfsInfo.m_PlayerIndex) do
		local player = g_GetPlayerInfo(charId)
		if player and charInfo.m_IsInScene then
			Gas2Gac:RetSetJFSPlayerCamp(player.m_Conn)
		end
	end
	
	jfsInfo.m_State = g_FbRoomState.BeginGame
end

local function ClearNotInFbTick(jfsInfo)
	if jfsInfo.m_State == g_FbRoomState.GameEnd then
		return
	end
	
	--����δ�볡�����
	for _, teamInfo in pairs(jfsInfo.m_TeamTbl) do
		for charId, charInfo in pairs(teamInfo.m_PlayerTbl) do
			local player = g_GetPlayerInfo(charId)
			if not (player and charInfo.m_IsInScene) then
				if charInfo.m_GameState ~= PlayerGameState.Running then
					ExitJiFenSaiGame(jfsInfo, charId, PlayerGameState.Running, true)
				end
			end
		end
	end
	
	--������ڻ��ò��ÿ�����,���Ǳ�������
	if not CheckAllPlayerInFb(jfsInfo) then
		return
	end
	
	UpdateAllClientInfo(jfsInfo)
	
	jfsInfo.m_State = g_FbRoomState.CountDown
	RegisterOnceTick(jfsInfo.m_Scene, "BeginJiFenSaiTick", BeginJiFenSaiTick, 1000 * (BeginGameTime-WaitEnterSceneTime), jfsInfo)
end

local EnterPos = {--��ҽ��븱����,1�Ӻ�2�ӵ�����
		[1] = {59,76},
		[2] = {59,33},
}

--��������,�öԿ�������������뷿��
function OnJiFenSaiCreateRoom(scene, roomId, actionName, roomMembers, JiFenSaiInfo)
	local jfsInfo = {}
	jfsInfo.m_RoomId = roomId
	jfsInfo.m_Scene = scene
	jfsInfo.m_GameType = JiFenSaiInfo["RoomType"]--����������(2V2,3V3,5V5);����Ϊ1,2,3
	jfsInfo.m_PlayerIndex = {}	--ͨ��charId ��������ұ�
	jfsInfo.m_TeamTbl = {}			--�����
	
	local index = 0
	for teamId, v in pairs(roomMembers) do
		index = index + 1
		jfsInfo.m_TeamTbl[teamId] = {}
		jfsInfo.m_TeamTbl[teamId].m_PlayerTbl = {}
		jfsInfo.m_TeamTbl[teamId].m_PlayerNum = 0
		jfsInfo.m_TeamTbl[teamId].m_TeamNum = index
		jfsInfo.m_TeamTbl[teamId].m_EnterPos = EnterPos[index]
		
		for _, charId in pairs(v) do
			local charInfo = {}
			charInfo.m_TeamId = teamId
			charInfo.m_KillCount = 0
			charInfo.m_BekillCount = 0
			charInfo.m_GameState = PlayerGameState.InGame
			charInfo.m_Name = JiFenSaiInfo["NameTbl"][charId]
			
			jfsInfo.m_PlayerIndex[charId] = charInfo
			jfsInfo.m_TeamTbl[teamId].m_PlayerTbl[charId] = charInfo
			
			Gas2GacById:RetIsJoinFbActionAffirm(charId, actionName, WaitEnterSceneTime-10, 0)
		end
	end
	
	scene.m_JfsInfo = jfsInfo
	g_JiFenSaiRoomTbl[roomId] = jfsInfo
	jfsInfo.m_State = g_FbRoomState.PlayerCanIn
	RegisterOnceTick(jfsInfo.m_Scene, "JiFenSaiClearTick", ClearNotInFbTick, 1000 * WaitEnterSceneTime, jfsInfo)
	jfsInfo.m_CreateSceneTime = os.time()
end

function GetJiFenSaiEnterPos(roomId, charId)
	local jfsInfo = g_JiFenSaiRoomTbl[roomId]
	if jfsInfo then
		local teamInfo, charInfo = FindPlayer(jfsInfo, charId)
		if charInfo then
			return jfsInfo.m_Scene.m_SceneId, teamInfo.m_EnterPos
		end
	end
end

function Gac2Gas:JoinJiFenSai(Conn, NpcID)
	if SearchClosedActionTbl(m_FbName) then
		MsgToConn(Conn,3521)--��Ѿ��ر�,�����Ա���
		return
	end
	
	local function CallBack(suc,result,msg)
		if IsCppBound(Conn) then
			if suc then
				MultiServerJoinAction(Conn, m_FbName)
			else
				if msg then
					MsgToConn(Conn,result,unpack(msg))
				elseif result then
					MsgToConn(Conn,result)
				end
			end
		end
	end
	
	local parameters = {}
	parameters["charID"] = Conn.m_Player.m_uID
	parameters["ActionName"] = m_FbName
	parameters["TeamNum"] = g_JfsTeamNum
	CallAccountManualTrans(Conn.m_Account, "JiFenSaiFbDB", "CheckTeamMemberNum", CallBack, parameters)
end

local function ChangeSceneLeave(Player)
	if Player.m_Scene.m_JfsInfo then --˵�����ڸ�����
		local _, charInfo = FindPlayer(Player.m_Scene.m_JfsInfo, Player.m_uID)
		if charInfo and charInfo.m_IsInScene then
			charInfo.m_IsInScene = nil
			
			local sceneName = Player.m_MasterSceneName
			local pos = Player.m_MasterScenePos 
			if Player.m_EnterObserverMode then
				Player:LeaveObserverMode()
			end
			Player:SetGameCamp(0)
			ChangeSceneByName(Player.m_Conn,sceneName,pos.x,pos.y)
			
		end
	end
end

function Gac2Gas:ExitJFSFbAction(Conn)
	local player = Conn.m_Player
	if IsCppBound(player) then
		ChangeSceneLeave(player)
	end
end

function OnDestroyJiFenSaiScene(scene)
	local jfsInfo = scene.m_JfsInfo
	g_JiFenSaiRoomTbl[jfsInfo.m_RoomId] = nil
end

function IsCanEnterJiFenSaiScene(scene, charId)
	local jfsInfo = scene.m_JfsInfo
	if jfsInfo.m_State == g_FbRoomState.PlayerCanIn and FindPlayer(jfsInfo, charId) then
		return true
	end
end

function ExitJiFenSaiGame(jfsInfo, charId, GameState, mustDelDb)
	if mustDelDb then
		RemovePlayer(jfsInfo, charId, GameState)
		Gas2GacById:RetDelQueueFbAction(charId, m_FbName, true)
		
		local data = {}
		data["CharId"] = charId
		data["RoomId"] = jfsInfo.m_RoomId
		CallDbTrans("JoinActionDB", "CancelActionByRoom", nil, data, charId, m_FbName)
	else
		RemovePlayer(jfsInfo, charId, GameState, true)
	end
	local player = g_GetPlayerInfo(charId)
	if IsCppBound(player) then
		ChangeSceneLeave(player)
	end
end

function Gac2Gas:ShowJiFenSaiWnd(Conn, NpcID)
	if not CheckAllNpcFunc(Conn.m_Player,NpcID,"������������") then
		return
	end
	
	if not CheckActionIsBeginFunc(m_FbName) then
		MsgToConn(Conn,3520)--���û�п���,�����Ա���
		return
	end
	
	Gas2Gac:RetShowJiFenSaiWnd(Conn, NpcID)
end

function IntoJFSScene(player)
	local jfsInfo = player.m_Scene.m_JfsInfo
	local teamInfo, charInfo = FindPlayer(jfsInfo, player.m_uID)
	assert(teamInfo and charInfo, "��ҷǷ��������������")
	charInfo.m_IsInScene = true
	teamInfo.m_PlayerNum = teamInfo.m_PlayerNum + 1
	
	player:SetGameCamp(1)--����Ϊͳһ���淨��Ӫ
	
	local time = BeginGameTime - (os.time() - jfsInfo.m_CreateSceneTime)
	Gas2Gac:RetSetJoinBtnEnable(player.m_Conn,m_FbName)
	Gas2Gac:RetOpenFbActionWnd(player.m_Conn, m_FbName, time)
	UpdateAllClientInfo(jfsInfo)
	
	--���븱����һ����
	local limitName = FbActionDirect_Common(m_FbName, "MaxTimes")
	if limitName and limitName ~= "" then
		local parameters = {}
		parameters["ActionName"] = m_FbName
		parameters["PlayerId"] = player.m_uID
		parameters["ActivityName"] = limitName
		CallAccountAutoTrans(player.m_Conn.m_Account, "JoinActionDB", "OnEnterRoom", nil, parameters)
	end
end

function LeaveJFSScene(Player, sceneId)
	local scene = g_SceneMgr:GetScene(sceneId)
	local jfsInfo = scene.m_JfsInfo
	Gas2GacById:RetCloseCountScoreWnd(Player.m_uID, m_FbName)
	Player:PlayerDoFightSkillWithoutLevel("�淨�����ָ�")
	ExitJiFenSaiGame(jfsInfo, Player.m_uID, PlayerGameState.Running, true)
end

function Gac2Gas:ShowJiFenSaiInfoWnd(Conn, NpcID)
	if not (IsCppBound(Conn) and IsCppBound(Conn.m_Player)) then
		return
	end
	if not CheckAllNpcFunc(Conn.m_Player,NpcID,"������������") then
		return
	end
	
	local function CallBack(InfoTbl)
		local tbl = InfoTbl[3]
		Gas2Gac:RetShowJiFenSaiInfoWnd(Conn, tbl.WinNum, tbl.LoseNum, tbl.RunNum, tbl.WinPro, tbl.KillNum, tbl.DeadNum, tbl.Point)
	end
	local data = {}
	data["CharId"] = Conn.m_Player.m_uID
	CallDbTrans("JiFenSaiFbDB", "GetPlayerPanelInfo", CallBack, data)
end