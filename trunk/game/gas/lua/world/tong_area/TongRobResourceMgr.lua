gas_require "world/tong_area/TongRobResourceMgrInc"
cfg_load "tong/TongStartTime_Common"

g_CTongRobResMgr = CTongRobResourceMgr:new()
g_TongRobResMes = {}
local _ActionName = "������Դ��"

local StartSignTime = GetCfgTransformValue(false, "TongStartTime_Common", "������Դ�㱨��ʱ��", "OpenTime")  --��ҿ��Կ�ʼ������ʱ��(��)
local WaitJointTime = TongStartTime_Common("������Դ�㱨��ʱ��", "OpenTime")   		--���Լ���������ʱ��(��)
local WaitEnterSceneTime = TongStartTime_Common("������Դ�����ʱ��", "OpenTime")	--��ҿ��Խ�����ʱ��(��)
local GameLength = TongStartTime_Common("������Դ����Ϸʱ��", "OpenTime")
local BeginGameTime = 60  			--�ӳ�����������ʼ��ʱ��(��)
g_RobResRoomTbl = {} 
local CampTbl = {
	[1] = 1111111,
	[2] = 1111112,
	[3] = 1111113
}

local PlayerGameState ={}
PlayerGameState.InGame = 1	--��ʾ����Ϸ��(������Ϣ)
PlayerGameState.InGameDead = 2	--��ʾ����Ϸ������
PlayerGameState.Running = 3	--��ʾ����
PlayerGameState.LeaveGame = 4	--��ʾ�����˳�(�������մ�����Ϣ)

--������
local function TestPrint(...)
	print("----������Դ��������:  ", ...)
end

--����Player��teamId��
local function FindPlayer(rrInfo, charId)
	local charInfo = rrInfo.m_PlayerIndex[charId]
	if charInfo then
		return rrInfo.m_TeamTbl[charInfo.m_TeamId], charInfo
	end
end

--��charInfo���ڳ���״̬()
local function AddState(rrInfo, charId)  --����,״̬
	local charInfo = rrInfo.m_PlayerIndex[charId]
	local teamInfo = rrInfo.m_TeamTbl[charInfo.m_TeamId]
	if charInfo then
		charInfo.m_IsInScene = true
	end
end


--���charInfo����״̬
local function GetState(rrInfo, charId)
	local charInfo = rrInfo.m_PlayerIndex[charId]
	if charInfo then
		return charInfo.m_IsInScene 
	end
end

function GetPlayerRobResState(rrInfo, charId)
	local state = GetState(rrInfo, charId)
	return state
end


local function GetOffsetSecond(strTime)
	local index1 = string.find(strTime, ":")
	local index2 = string.find(strTime, ":", index1 + 1) or 0
	local hour = tonumber(string.sub(strTime, 1, index1 - 1))
	local min = tonumber(string.sub(strTime, index1 + 1, index2 -1))
	local sec = 0
	if index2 ~= 0 then
		sec = tonumber(string.sub(strTime, index2 + 1, -1))
	end
	assert(hour and min and sec, "ʱ���ʽ����")
	return (hour * 60 + min) * 60  + sec
end

local function GetGameOverTime(strTime, GameLength, WaitEnterSceneTime, WaitJointTime)
	local index1 = string.find(strTime, ":")
	local index2 = string.find(strTime, ":", index1 + 1) or 0
	local hour = tonumber(string.sub(strTime, 1, index1 - 1))
	local min = tonumber(string.sub(strTime, index1 + 1, index2 -1))
	local sec = 0
	if (min + GameLength + WaitJointTime) >= 60 then
		hour = hour + (min + GameLength + WaitJointTime) % 60
		min = (min + GameLength + WaitJointTime) / 60
	else
		hour = hour 
		min = min + GameLength + WaitJointTime
	end
	
	sec = WaitEnterSceneTime
	local time = hour..":"..min..":"..sec
	local date = {}
	date["time"] = {time}
	return date
end

local function ForbitGameOver(rrInfo)
	local tbl = {}
	rrInfo.m_State = g_FbRoomState.GameEnd
	for playerId, _ in pairs(rrInfo.m_Scene.m_tbl_Player) do
		table.insert(tbl, playerId)
	end
	local parameters = {}
	parameters["PlayerIdTbl"] = tbl
	if rrInfo.m_IntoScene == true then
		local function CallBack(result)
			if result then
				for _, tempresult in pairs(result) do
					local IsFlag, tongName = tempresult[1],tempresult[2]
					for temp, charId in pairs(tbl) do
						local Player = g_GetPlayerInfo(charId)
						if not Player then
							return
						end
						if not IsFlag then
							Gas2Gac:ShowRobResOverExit(Player.m_Conn)
							Gas2GacById:RetDelQueueFbAction(charId, _ActionName, true)
						else	
							Gas2Gac:ShowRobResZeroExitWnd(Player.m_Conn, tongName)
						end
					end
				end
			end
		end
		CallDbTrans("GasTongRobResourceDB", "GetTempRobResObj", CallBack, parameters)
	end
end

local function BeginGame(rrInfo)
	--TestPrint("��ʼ����")
	rrInfo.m_State = g_FbRoomState.BeginGame
	--rrInfo.m_Scene.m_ForbidTick = RegisterTick("ForbidGameOverTick", ForbitGameOver, 1000 * GameLength * 60 , rrInfo.m_Scene)
	RegisterOnceTick(rrInfo.m_Scene, "ForbidGameOverTick", ForbitGameOver, 1000 * GameLength * 60 , rrInfo)   --һ��Сʱ��ǿ���˳�
end

local function IsInOpenTime(data, length)
	
	local curDate = os.date("*t")
	local week = curDate.wday - 1
	for _, i in pairs(data.wday) do
		if week == i then
			local hour = curDate.hour
			local minute = curDate.min
			local second = curDate.sec
			local todayCurSecond = (hour * 60 + minute) * 60 + second 
			local offSet = GetOffsetSecond(data.time[1])
			local endOffSet = offSet + length * 60
			if todayCurSecond >= offSet and todayCurSecond <= endOffSet then
				return true, endOffSet - todayCurSecond
			end
		end
	end
	return false
end

local function LeaveRobResFbScene(player)
--	TestPrint("֪ͨ����г�����")
	if player.m_Scene.m_RrInfo then --˵�����ڴ���ɱ������
		local sceneName = player.m_MasterSceneName
		local pos = player.m_MasterScenePos 
--		TestPrint(sceneName, pos.x, pos.y)
		ChangeSceneByName(player.m_Conn,sceneName,pos.x,pos.y)
		local parameters = {}
		parameters["charId"] = player.m_uID
		CallDbTrans("GasTongRobResourceDB", "DeleteObjInfo", nil, parameters)  --ɾ������Obj
	end
end

local function LeaveRobResAction(player)
	if player.m_Scene.m_RrInfo then --˵������������Դ�㸱����
		local sceneName = player.m_MasterSceneName
		local pos = player.m_MasterScenePos 
		ChangeSceneByName(player.m_Conn,sceneName,pos.x,pos.y)
	end
end

local function PlayerRunGame(rrInfo,charInfo,charId)
	local teamInfo, charInfo = FindPlayer(rrInfo, charId)
	if rrInfo.m_State == g_FbRoomState.GameEnd then
		return
	end
	local playerState = GetState(rrInfo, charId)
	local char = g_GetPlayerInfo(charId)
	if char then
		Gas2Gac:RetCloseFbActionWnd(char.m_Conn,_ActionName)
		Gas2Gac:RetDelQueueFbAction(char.m_Conn, _ActionName, true)
	end
end

local function playerExitFbAction(rrInfo, charId)
	local teamInfo, charInfo = FindPlayer(rrInfo, charId)
	local player = g_GetPlayerInfo(charId)
	if not teamInfo.m_PlayerTbl then
		return 
	end
	local playerNum = table.maxn(teamInfo.m_PlayerTbl)
	player.m_Scene.m_playerNum = playerNum - 1
	local tongName = player.m_Properties:GetTongName()
	if player.m_Scene.m_RrInfo then --˵������������Դ�㸱����
		if player.m_Scene.m_playerNum == 0 then
			local data = {}
			data["tongName"] = tongName
			CallAccountManualTrans(player.m_Conn.m_Account, "GasTongRobResourceDB", "DeleteTongInfo", nil, data)  --�ж�Ȩ��
		end
		local sceneName = player.m_MasterSceneName
		local pos = player.m_MasterScenePos 
--		TestPrint(sceneName, pos.x, pos.y)
		ChangeSceneByName(player.m_Conn,sceneName,pos.x,pos.y)
	end
end 

--�������������˳���״̬
local function RemovePlayer(rrInfo, charId, GameState, IsExit)
	local teamInfo, charInfo = FindPlayer(rrInfo, charId)
	if charInfo then
		local char = g_GetPlayerInfo(charId)
		--�ı�����������״̬
		local state = GetState(rrInfo, charId)
		if state then
			if IsCppBound(char) then
				Gas2Gac:RetCloseFbActionWnd(char.m_Conn,_ActionName)
				playerExitFbAction(rrInfo, charId)
				return 
			end
		end
		--����Ϣ˵,��������
		if GameState == PlayerGameState.Running then
			PlayerRunGame(rrInfo,charInfo,charId)
		end
		--����ǻ�û�б������˳��Ļ�,���ø����е��˼Ƿ�
		if IsExit or rrInfo.m_State == g_FbRoomState.PlayerCanIn then
			return
		end
	end
end

local function WaitRobPlayerJoinEnd(rrInfo)  --����������ʱ,�ı�room��״̬
	local function CallBack(result)
		if not result then
			return 
		end
		for _, charId in pairs(result) do   --teamId = roomId
			local Player = g_GetPlayerInfo(charId)
			if Player then
				local sceneType = Player.m_Scene.m_SceneAttr.SceneType
				if sceneType ~= 26 then
					Gas2GacById:RetDelQueueFbAction(charId, _ActionName, true)
				end
			end
		end
	end
	CallDbTrans("JoinActionDB", "GetAllActionMembers", CallBack, {})
	rrInfo.m_State = g_FbRoomState.CountDown
	RegisterOnceTick(rrInfo.m_Scene, "RobResBeginTick", BeginGame, 1000 , rrInfo)  --������X�뿪ʼ����
	CallDbTrans("JoinActionDB","WaitPlayerEnd", nil, {["RoomId"] = rrInfo.m_RoomId}, _ActionName)
end

function IntoRobResScene(player)
	local rrInfo = player.m_Scene.m_RrInfo
	player.m_Scene.m_playerNum = player.m_Scene.m_playerNum + 1
	rrInfo.m_IntoScene = true
	AddState(rrInfo, player.m_uID)
	local time = WaitEnterSceneTime - (os.time() - rrInfo.m_OpenTime)
	Gas2Gac:RetSetJoinBtnEnable(player.m_Conn,_ActionName)
	local playerCamp = player:CppGetCamp()
	
	if time <= 0 then
		Gas2Gac:RetOpenFbActionWnd(player.m_Conn, _ActionName, 0)
	else
		Gas2Gac:RetOpenFbActionWnd(player.m_Conn, _ActionName, time)
	end
	
end

function GetRobResEnterPos(Conn, roomId, charId)
	local rrInfo = g_RobResRoomTbl[roomId]
	if rrInfo then
		local teamInfo, charInfo = FindPlayer(rrInfo, charId)
		
		if charInfo then
			local sceneId = rrInfo.m_Scene.m_SceneId
			local sceneName = rrInfo.m_Scene.m_SceneName
			local data = {}
			data["charId"] = charId
			local function CallBack(result)
				if result then
					local PosId = CampTbl[result]
					local posx, posy  = GetScenePosition(PosId)
					if sceneId then
						Gas2GasAutoCall:RetSrcServerChangeScene(Conn, charId, sceneId, posx, posy)
					end
				end
			end
			CallDbTrans("CharacterMediatorDB", "GetCampById", CallBack, data)  --�ж�Ȩ��
		end
	end
end

function OnRobResCreateRoom(scene, roomId, actionName, roomMembers)
	local rrInfo = {}
	rrInfo.m_RoomId = roomId
	rrInfo.m_Scene = scene
	rrInfo.m_PlayerIndex = {}	--ͨ��charId ��������ұ�
	rrInfo.m_TeamTbl = {}			--�����
	local index = 0
	
	local function CallBack(result)
		if result then
			for teamId, v in pairs(roomMembers) do   --teamId = roomId
				index = index + 1
				rrInfo.m_TeamTbl[teamId] = {}
				rrInfo.m_TeamTbl[teamId].m_PlayerTbl = {}
				rrInfo.m_TeamTbl[teamId].m_PlayerNum = 0
				rrInfo.m_TeamTbl[teamId].m_TeamNum = index
				local playerId
				for _, charId in pairs(result) do   --teamId = roomId
					local charInfo = {}
					if playerId ~= charId then
						rrInfo.m_PlayerIndex[charId] = charInfo
						rrInfo.m_TeamTbl[teamId].m_PlayerTbl[charId] = charInfo
						charInfo.m_TeamId = teamId
						charInfo.m_GameState = PlayerGameState.InGame
						playerId = charId
						--Gas2GacById:RetIsJoinFbActionAffirm(charId, actionName, WaitEnterSceneTime)  -- 30�����ʱ
					end
				end
			end
		end
	end
	CallDbTrans("JoinActionDB", "GetAllActionMembers", CallBack, {})
	
	scene.m_playerNum = 0
	scene.m_RrInfo = rrInfo
	g_RobResRoomTbl[roomId] = rrInfo
	rrInfo.m_State = g_FbRoomState.PlayerCanIn
	
	RegisterOnceTick(rrInfo.m_Scene, "RobResWaitJoinTick", WaitRobPlayerJoinEnd, 1000 * WaitEnterSceneTime , rrInfo)  -- �ӵ����Ի��򵽽���
	rrInfo.m_OpenTime = os.time()
end

function ExitRobResGame(rrInfo, charId, GameState, mustDelDb)
	if mustDelDb then
		RemovePlayer(rrInfo, charId, GameState)
		Gas2GacById:RetDelQueueFbAction(charId, _ActionName, true)
		local data = {}
		data["CharId"] = charId
		data["RoomId"] = rrInfo.m_RoomId
		local player = g_GetPlayerInfo(charId)
		
		if IsCppBound(player) then
			LeaveRobResAction(player)
		end
		CallDbTrans("JoinActionDB", "CancelActionByRoom", nil, data, charId, _ActionName)
	else
		RemovePlayer(rrInfo, charId, GameState, false)
	end
end

--function ChangeOutRobResScene(Player, sceneId)
--	local scene = g_SceneMgr:GetScene(sceneId)
--	local rrInfo = scene.m_RrInfo
--	playerExitFbAction(rrInfo, Player.m_uID)
--end
--
--function IsCanEnterRobResScene(scene, charId)
--	local rrInfo = scene.m_RrInfo
--	if rrInfo.m_State == g_FbRoomState.PlayerCanIn and FindPlayer(rrInfo, charId) then
--		return true
--	end
--	if rrInfo.m_State == g_FbRoomState.BeginGame and FindPlayer(rrInfo, charId) then
--		return true
--	end
--end
--
----����ʱʹ��
--function PlayerOffLineRobResFb(Player)
--	local Conn = Player.m_Conn
--	local Scene = Player.m_Scene
--	local nSceneID = Scene.m_SceneId
--	local nPlayerID = Player.m_uID
---- ��¼����ʱ��
--	local nowdate = os.date("*t")
--	local nowmin = nowdate.min
--	local nowsec = nowdate.sec
--	Scene.m_RrInfo.m_OffLineTime = nowmin*60+nowsec
--	Scene.m_RrInfo.PlayerOffLine = true
--end
--
--function PlayerLoginRobRes(Player)
--	local curDate =  os.date("*t")
--	local	Scene = Player.m_Scene
--	local PlayerId = Player.m_uID
--	if Scene.m_RrInfo.PlayerOffLine then
--		Scene.m_RrInfo.PlayerOffLine = nil
--	end	
--	
--	-- ����ϴε����������TICK
--	if Scene.m_CloseRobResActionTick then
--		UnRegisterTick(Scene.m_CloseRobResActionTick)
--		Scene.m_CloseRobResActionTick = nil
--	end
--	
--	local isOpenBeginTime, lengthBegin = IsInOpenTime(StartSignTime, WaitJointTime)
--	local isOpenEndTime, lengthEnd = IsInOpenTime(StartSignTime, (WaitJointTime + GameLength))
--	if isOpenEndTime then
--			
--		if Scene.m_RrInfo.m_State == g_FbRoomState.BeginGame then
--			Gas2Gac:RetInitFbActionQueueWnd(Player.m_Conn,_ActionName)
--			local time = WaitEnterSceneTime - (os.time() - Scene.m_RrInfo.m_OpenTime)
--			Gas2Gac:RetOpenFbActionWnd(Player.m_Conn, _ActionName, 0)
--		elseif Scene.m_RrInfo.m_State == g_FbRoomState.PlayerCanIn then
--			Gas2Gac:RetInitFbActionQueueWnd(Player.m_Conn,_ActionName)
--			local time = WaitEnterSceneTime - (os.time() - Scene.m_RrInfo.m_OpenTime)
--			Gas2Gac:RetOpenFbActionWnd(Player.m_Conn, _ActionName, time)
--		elseif Scene.m_RrInfo.m_State == g_FbRoomState.GameEnd then
--			Gas2Gac:ShowRobResOverExit(Player.m_Conn)
--			Gas2Gac:RetInitFbActionQueueWnd(Player.m_Conn,_ActionName)
--			local time = WaitEnterSceneTime - (os.time() - Scene.m_RrInfo.m_OpenTime)
--			Gas2Gac:RetOpenFbActionWnd(Player.m_Conn, _ActionName, 0)
--		end
--		local playerCamp = Player:CppGetCamp()
--	end
--end
--
--function Gac2Gas:PlayerExitFb(Conn)
--	LeaveRobResFbScene(Conn.m_Player)
--end
--
--function Gac2Gas:CloseActionWnd(Conn)
--	Gas2GacById:RetDelQueueFbAction(Conn.m_Player.m_uID, "������Դ��")
--end
--
----�򿪱����鿴���(������û�д�,����Ϣ���ͻ�����ʾ�鿴���)
--function Gac2Gas:OpenSignQueryWnd(Conn)
--	local Player = Conn.m_Player
--	local parameters = {}
--	parameters["signUpId"] = Player.m_SignUpId
--	local function CallBack(result)
--		local isOpenTime, length = IsInOpenTime(StartSignTime, (WaitJointTime + GameLength))
--		if isOpenTime then
--			if result then
--				for _, resTbl in pairs(result) do
--					local tongName = resTbl[1]
--					local tongCamp = resTbl[2]  -- 1:����  2:��ʥ  3:��˹
--					Gas2Gac:RetOpenSignQueryWnd(Conn, tongName, tongCamp)
--				end
--			else
--				MsgToConn(Conn, 9458)
--			end
--		else
--			MsgToConn(Conn, 9460)
--			return
--		end
--	end
--	CallAccountManualTrans(Conn.m_Account, "GasTongRobResourceDB", "SelectSignUpTongName", CallBack, parameters)  --�ж�Ȩ��
--end
--
----�ж�Player�Ƿ��ܹ�����(�Ƿ���Ӷ����,ְλ���),��������Է�����Ϣ���ͻ���,����ʾ;�������,����鿴�б�,����ʾ
--function Gac2Gas:JoinRobResFb(Conn)
--	local isOpenTime, length = IsInOpenTime(StartSignTime, WaitJointTime)
--	if not isOpenTime then
--		MsgToConn(Conn, 320001)
--		return
--	end
--	
--	--�����ݿ��ж�
--	local Player = Conn.m_Player 
--	local PlayerId = Player.m_uID
--	--local PlayerLevel = Player:CppGetLevel()
--	local PlayerCamp = Player:CppGetCamp()
--	local signObjName = Player.m_SignUpId
--	local parameters = {}
--	parameters["charId"] = PlayerId
--	parameters["objName"] = signObjName
--	parameters["campType"] = PlayerCamp
--	parameters["serverId"] = g_CurServerId
--	
--	--�Ƿ�������ֱ�������
--	local function CallBack(result)
--		if not result then
--			return 
--		end
--		local msg = result[1]
--		local winPlayerTbl = result[2]
--		local lossPlayerTbl = result[3]
--		if msg == 9453 then
--			if lossPlayerTbl then
--				for _, id in pairs(lossPlayerTbl) do
--					MsgToConnById(id, 9470)
--					Gas2GacById:RetDelQueueFbAction(id, _ActionName) 
--				end
--			end
--			if winPlayerTbl then
--				for _, id in pairs(winPlayerTbl) do
--					if id ~= PlayerId then
--						MsgToConnById(id, 9461)
--					end
--				end
--			end
--			MsgToConn(Conn, msg)
--			MultiServerJoinAction(Conn, _ActionName)
--			--LogErr("������Դ�㱨��������", "���id:" .. PlayerId .. " �����Ӫ:" .. PlayerCamp.."������id"..g_CurServerId.."ObjId"..signObjName)
--		else
--			MsgToConn(Conn, msg)
--		end
--	end
--	CallAccountManualTrans(Conn.m_Account, "GasTongRobResourceDB", "JudgeRobResSign", CallBack, parameters)
--end
--
----�Ź���ȡͨ��ʱ������
--local function GetProfferTime()
--	local nowdate = os.date("*t")
--	local year = nowdate.year.. ""
--	local month = nowdate.month.. ""
--	local day = nowdate.day.. ""
--	if nowdate.month < 10 then
--		month = "0"..month
--	end
--	if nowdate.day < 10 then
--		day = "0"..day
--	end
--	local str = year..month..day 
--	return str
--end
--
--function Gac2Gas:GetProffer(Conn)
--	if not IsCppBound(Conn) then
--		return 
--	end
--	local Player = Conn.m_Player
--	if not IsCppBound(Player) then
--		return 
--	end
--	local parameters = {}
--	parameters["charId"] = Player.m_uID
--	parameters["objName"] = Player.m_SignUpId
--	parameters["getTime"] = GetProfferTime()
--	local function CallBack(result)
--		if not result then
--			return
--		end
--		local flag = result[1]
--		local proffer = result[2]
--		if flag then
--			MsgToConn(Conn, 9471, proffer)
--			return
--		end
--		MsgToConn(Conn, proffer)
--	end
--	CallAccountManualTrans(Conn.m_Account, "GasTongRobResourceDB", "GetProffer", CallBack, parameters)
--end
--
----���ʱ��
--local function GetSignOverTime(strTime, strTime1)
--	local index1 = string.find(strTime, ":")
--	local index2 = string.find(strTime, ":", index1 + 1) or 0
--	local hour = tonumber(string.sub(strTime, 1, index1 - 1))
--	local min = tonumber(string.sub(strTime, index1 + 1, index2 -1))
--	if min + strTime1 >= 60 then
--		hour = (min + strTime1) / 60 + hour
--		min = (min + strTime1) % 60
--	else
--		hour = hour
--		min = min + strTime1
--	end
--	local str = hour..":"..min
--	return str
--end
--
--function CTongRobResourceMgr:Init()
--	local time = GetSignOverTime(StartSignTime.time[1],WaitJointTime)
--	local data = {}
--	data["time"] = {time}
--	local tempdata = {}
--	tempdata["time"] = {StartSignTime.time[1]}
--	local parameter = {}
--	parameter["IsAlarm"] = true
--	g_AlarmClock:AddTask("TestSignOver", data, JudgeAlarm, nil)
--	g_AlarmClock:AddTask("ClearTempRobResData", tempdata, ClearTempRobResData, nil)
--	g_AlarmClock:AddTask("DeleteAllTeamAndTime", tempdata, DeleteAllTeamAndTime, nil)
--end
--
--function ClearTempRobResData()
--	CallDbTrans("GasTongRobResourceDB", "DeleteTempRobResData", nil, {}, "robres")
--end
--
--function DeleteAllTeamAndTime()
--	CallDbTrans("GasTongRobResourceDB", "DeleteAllTeamAndTime", nil, {}, "delTime")
--end
--
--function JudgeAlarm()
--	local data = {}
--	local function CallBack(result)
--	
--		if result then
--			for _, resTbl in pairs(result) do
--				if resTbl then
--					local isSucceed = resTbl[1]
--					local args = resTbl[2]
--					if not args then
--						return 
--					end
--					local _, roomId, serverId = args[1],args[2],args[3]
--					if isSucceed then
--						local state = args[1]
--						if state == "IntoUnfullRoom" then
--							JoinAction_IntoUnfullRoom(_ActionName, args)
--						elseif state == "StartNewRoom" then
--							Gas2GasAutoCall:CreateActionRoom(GetServerAutoConn(serverId), roomId, _ActionName)
--						else--if state == "QueueUp" then
--							JoinAction_QueueUp(_ActionName, args)
--						end
--					else
--						if args then
--							MsgToConn(Conn, unpack(args))
--						end
--					end
--				end
--			end
--		end
--	end
--	CallDbTrans("GasTongRobResourceDB", "SelectAllTong", CallBack, data, _ActionName)
--end
--
--
--function ResumeData()
--	local startTime = GetOffsetSecond(StartSignTime.time[1]) -- ��ʼʱ��
--	local overTime = startTime + WaitJointTime * 60 + WaitEnterSceneTime + GameLength * 60
--	local nowtime = os.time()
--	local nowdate = os.date("*t")
--	local nowhour = nowdate.hour
--	local nowmin = nowdate.min
--	local nowsec = nowdate.sec
--	local time = (nowhour * 60 + nowmin) * 60 + nowsec
--	local data = {}
--	data["serverId"] = g_CurServerId
--	if time >= startTime and time <= overTime then
--		
--		local function CallBack(result)
--			if result then
--				for _, charTbl in pairs(result) do
--					if charTbl then
--						for _,charId in pairs(charTbl) do
--							g_TongRobResMes[charId] = _ActionName
--						end
--					end
--				end
--			end
--		end
--		CallDbTrans("GasTongRobResourceDB", "GetSignUpTeamTimeCount", CallBack, data)
--	else
--		CallDbTrans("GasTongRobResourceDB", "DealTempData", nil, {}) 
--	end
--end
--

