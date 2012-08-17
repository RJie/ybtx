cfg_load "tong/TongStartTime_Common"
CTongRobResMgr = class()
local StartSignTime = GetCfgTransformValue(false, "TongStartTime_Common", "������Դ�㱨��ʱ��", "OpenTime")  --��ҿ��Կ�ʼ������ʱ��(��)
local WaitJointTime = TongStartTime_Common("������Դ�㱨��ʱ��", "OpenTime")   		--���Լ���������ʱ��(��)
local WaitEnterSceneTime = TongStartTime_Common("������Դ�����ʱ��", "OpenTime")	--��ҿ��Խ�����ʱ��(��)
local GameLength = TongStartTime_Common("������Դ����Ϸʱ��", "OpenTime")
local ResetTime = GetCfgTransformValue(false, "TongStartTime_Common", "������Դ�㽱������ʱ��", "OpenTime")
local CampTbl = {
	[1] = 1111111,
	[2] = 1111112,
	[3] = 1111113
}


local ObjNameAndLvStepTbl = {
	["��ɽ��Ѩ������Դ��"] = 4,
	["�����ͱ�������Դ��"] = 5,
	["ѩ���ͱ�������Դ��"] = 6,
	["����ɽ��������Դ��"] = 7,
	["���ܵ�������Դ��"] = 8,
	["����֮צ��Ѩ������Դ��"] = 9,
	["��������ǰӪ������Դ��"] = 10,
	["���������̳������Դ��"] = 11,
	["����Ӫ��������Դ��"] = 12,
	["�����ֵ�������Դ��"] = 13,
	["�ݹ�Ĺ��������Դ��"] = 14,
	["��������������Դ��"] = 15,
	["����ɭ��������Դ��"] = 16,
	["�䷨ɭ��������Դ��"] = 17,
	["����ɳ��������Դ��"] = 18,
	["������Ӫ��������Դ��"] = 19,
	["�����ݵ�������Դ��"] = 20,
	["����ɳ̲������Դ��"] = 21,
	["����ս��������Դ��"] = 22,
	["�ѹȷس�������Դ��"] = 23,
	["��������Ӫ��������Դ��"] = 24,
	["�һ��̻�Ӫ��������Դ��"] = 25,
	["������ʿӪ��������Դ��"] = 26,
	["�������������Դ��"] = 27,
	["���������ӵ�������Դ��"] = 28,
	["���뷥ľ��������Դ��"] = 29,
	["ѩ��¶̨������Դ��"] = 30,
	["ʨ����������Դ��"]= 31,
	["��轻ս��������Դ��"]= 32,
	["�籩�ͱ�������Դ��"]= 33,
	["�籩���������Դ��"]= 34,
	["������������Դ��"]= 35,
	["Ԧ���߳�Ѩ������Դ��"]= 36,
	["ħ����������Դ��"]= 37,
	["�Ͻ�����Ӫ��������Դ��"]= 38,
	["�־��������Դ��"]= 39,
	["���ּ�̳������Դ��"]= 40,
	["���ֽ�ս��������Դ��"]= 41
}

g_RobResWinTbl = {}
local function GetProfferTime()
	local nowdate = os.date("*t")
	local year = nowdate.year.. ""
	local month = nowdate.month.. ""
	local day = nowdate.day.. ""
	if nowdate.month < 10 then
		month = "0"..month
	end
	if nowdate.day < 10 then
		day = "0"..day
	end
	local str = year..month..day 
	return str
end

--���ʱ��
local function GetSignOverTime(strTime, strTime1)
	local index1 = string.find(strTime, ":")
	local index2 = string.find(strTime, ":", index1 + 1) or 0
	local hour = tonumber(string.sub(strTime, 1, index1 - 1))
	local min = tonumber(string.sub(strTime, index1 + 1, index2 -1))
	if min + strTime1 >= 60 then
		hour = (min + strTime1) / 60 + hour
		min = (min + strTime1) % 60
	else
		hour = hour
		min = min + strTime1
	end
	local str = hour..":"..min
	return str
end

local function ShowEnterScenePanel()
	
	local function CallBack(result)
		if not result then
			return 
		end
		for _, charId in pairs(result) do
			local Player = g_GetPlayerInfo(charId)
			if IsCppBound(Player) and IsCppBound(Player.m_Conn) then 
				if Player.m_Scene.m_SceneAttr.SceneType ~= 26 then
					Gas2Gac:CreateRobTransprot(Player.m_Conn)
				end
			end
		end
	end
	CallDbTrans("GasTongRobResDB", "SelectAllTongId", CallBack, {}, "ShowEnterScenePanel")
end


local function ShowMessage()
	
	local function CallBack(result)
		if not result then
			return 
		end
		for _, charId in pairs(result) do
			local Player = g_GetPlayerInfo(charId)
			if IsCppBound(Player) and IsCppBound(Player.m_Conn) and Player.m_Scene.m_SceneAttr.SceneType ~= 26 then 
				MsgToConn(Player.m_Conn, 9478)
			end
		end
	end
	CallDbTrans("GasTongRobResDB", "SelectAllTongId", CallBack, {}, "ShowMessage")
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

local function ForbitGameOver()
	--�õ����еĳ���,�������������,
	local function CallBack(result)
		if not result then
			return 
		end
		CTongRobResMgr.GetRobResWinInfo()
		for _, info in pairs(result) do
			local flag, tongName, sceneId = info[1],info[2],info[3]
			local Scene = g_SceneMgr:GetScene(sceneId)
			if Scene then 
				if Scene.m_ResourceTick then
					UnRegisterTick(Scene.m_ResourceTick)
					Scene.m_ResourceTick = nil
				end
				if flag then
					Gas2Gac:ShowRobResZeroExitWnd(Scene.m_CoreScene, tongName)
				else
					Gas2Gac:ShowRobResOverExit(Scene.m_CoreScene)
				end
			end
		end
	end
	CallDbTrans("GasTongRobResDB", "FormitLeaveFb", CallBack, {}, "leaveRobRes")
end

local function ClearRobRes()
	if g_RobResMgr.m_ClearRobResTick then
		UnRegisterTick(g_RobResMgr.m_ClearRobResTick)
		g_RobResMgr.m_ClearRobResTick = nil
	end
	if g_RobResMgr.m_OpenTime then
		g_RobResMgr.m_OpenTime = nil
	end
	if g_RobResMgr.m_CurrentType then
		g_RobResMgr.m_CurrentType = nil
	end
	local function callback(result)
		if not result then
			return
		end
		local len = table.getn(result)
		if len == 0 then
			return
		end
		for _, sceneId in pairs(result) do
			local Scene = g_SceneMgr:GetScene(sceneId)
			if Scene ~= nil then 	--���˸��� ���˳��˾����ڴ�
				Scene:Destroy()
			end
		end
	end
	CallDbTrans("GasTongRobResourceDB","DeleteTempRobResData", callback, {}, "clearRobRes")
end

local function EndRobRes()
	g_RobResMgr.m_CurrentType = "Ending"
	local data = {}
	data["state"] = g_RobResMgr.m_CurrentType
	if g_RobResMgr.m_EndRobResTick then
		UnRegisterTick(g_RobResMgr.m_EndRobResTick)
		g_RobResMgr.m_EndRobResTick = nil
	end
	ForbitGameOver()
	g_RobResMgr.m_ClearRobResTick = RegisterTick("RobResClearTick", ClearRobRes, 2 * 60 * 1000)
	CallDbTrans("GasTongRobResDB","UpdateRobResState", nil, data, "updatestate")
end

local function IntoRobResScene(Player)

	local scene = Player.m_Scene
	scene.m_IsFlag = {}
	scene.m_OpenTime = {}
	if not scene.m_IsFlag[scene.m_SceneId] then
		scene.m_IsFlag[scene.m_SceneId] = true
	end
	local time = 0
	local curDate = os.date("*t")
	local ostime = (curDate.hour * 60 + curDate.min) * 60 + curDate.sec
	
	if g_RobResMgr.m_OpenTime then
		time = WaitEnterSceneTime - (os.time() - g_RobResMgr.m_OpenTime)
	else
		time = WaitJointTime * 60 + GetOffsetSecond(StartSignTime.time[1]) + WaitEnterSceneTime - ostime
	end	
	Gas2Gac:RetOpenFbActionWnd(Player.m_Conn, "������Դ��", time)
	if scene.m_objName and scene.m_Time then
		Gas2Gac:ShowCountDown(Player.m_Conn, scene.m_objName, scene.m_Time)
	end
end

function CTongRobResMgr.IntoRobResScene(Player)
	IntoRobResScene(Player)
	Player:CppSetPKState(true)
	Gas2Gac:UpdatePkSwitchState(Player.m_Conn)
	Gas2Gac:UpdateHeadInfoByEntityID(Player:GetIS(0), Player:GetEntityID())
	MsgToConn(Player.m_Conn, 193034)
end


local function BeginRobRes()
	if g_RobResMgr.m_BeginRobResTick then
		UnRegisterTick(g_RobResMgr.m_BeginRobResTick)
		g_RobResMgr.m_BeginRobResTick = nil
	end
	local function CallBack(result)
		if result then
			ShowMessage()
		end
	end
	
	g_RobResMgr.m_CurrentType = "Playing"
	g_RobResMgr.m_EndRobResTick = RegisterTick("TongWarEndTick", EndRobRes, GameLength * 60 * 1000)
	local data = {}
	data["state"] = g_RobResMgr.m_CurrentType
	CallDbTrans("GasTongRobResDB","UpdateRobResState", CallBack, data, "updatestate")
end

local function SignEnd()
	--���ͽ���
	local scene
	if g_RobResMgr.m_SignEndTick then
		UnRegisterTick(g_RobResMgr.m_SignEndTick)
		g_RobResMgr.m_SignEndTick = nil
	end
	if not g_RobResMgr.m_OpenTime then
		g_RobResMgr.m_OpenTime = os.time()
	end
	local function CallBack(result, sceneInfo)
		if result then
			ShowEnterScenePanel()
		end
		for _, info in pairs(sceneInfo) do
			local sceneId = info[1]
			local serverId = info[2]
			if not g_SceneMgr:GetScene(sceneId) then
				scene = g_SceneMgr:CreateScene("������Դ��", sceneId, nil)
			end
		end
	end
	g_RobResMgr.m_CurrentType = "Waiting"
	g_RobResMgr.m_BeginRobResTick = RegisterTick("TongWarEndTick", BeginRobRes, WaitEnterSceneTime * 1000)
	local data = {}
	data["state"] = g_RobResMgr.m_CurrentType
	CallDbTrans("GasTongRobResDB","UpdateRobResState", CallBack, data, "updatestate")
end

local function SignBeginTick()
	if g_RobResMgr.m_ChangeTypeTask then
		g_AlarmClock:RemoveTask(g_RobResMgr.m_ChangeTypeTask)
		g_RobResMgr.m_ChangeTypeTask = nil
	end
	g_RobResMgr.m_CurrentType = "Signning"
	g_RobResMgr.m_SignEndTick = RegisterTick("TongWarEndTick", SignEnd, WaitJointTime * 60 * 1000)
	--�����ݿ�
	local data = {}
	data["state"] = g_RobResMgr.m_CurrentType
	CallDbTrans("GasTongRobResDB","AddRobResState", nil, data, "AddState")
end

local function ChangeScene(playerId, SceneId, ServerId, x, y)
	local Player = g_GetPlayerInfo(playerId)
	if not IsCppBound(Player) or not IsCppBound(Player.m_Conn) then
		return 
	end
	MultiServerChangeScene(Player.m_Conn, SceneId, ServerId, x, y)
end

local function GetChangeInfo(Conn, Isflag)
	if not IsCppBound(Conn) or not IsCppBound(Conn.m_Player) then
		return 
	end
	if Conn.m_Player.m_Properties:GetTongID() == 0 then
		MsgToConn(Conn, 9450)
		return
	end
	
	local camp = Conn.m_Player:CppGetCamp()
	local data = {}
	data["charId"] = Conn.m_Player.m_uID
	data["objName"] = Conn.m_Player.m_SignUpId
	data["flag"] = Isflag
	local function CallBack(res, result)
		if not res then
			MsgToConn(Conn, result)
			return
		end
		local sceneId = result[1]
		local server = result[2]
		local flag = result[3]
		local state = result[4]
		if IsCppBound(Conn) and IsCppBound(Conn.m_Player) then
			if state == "Winning" or state == "Ending" then
				MsgToConn(Conn, 9466)
				return 
			end
			if not flag then
				MsgToConn(Conn, 9477)
				return 
			end
			if g_RobResMgr.m_CurrentType ~= "Playing" and g_RobResMgr.m_CurrentType ~= "Waiting" then
				MsgToConn(Conn, 9476)
				return 	
			end
			local PosId = CampTbl[camp]
			local posx, posy  = GetScenePosition(PosId)
			ChangeScene(Conn.m_Player.m_uID, sceneId, server, posx, posy)
		end
	end
	CallAccountManualTrans(Conn.m_Account, "GasTongRobResDB", "GetSceneInfo", CallBack, data)
end

function CTongRobResMgr.EnterRobScene(Conn, flag)
	 GetChangeInfo(Conn, flag) 
end


function CTongRobResMgr:InitRobResInfo()
	local function CallBack(result)
		if not result or not result[3] then
			g_AlarmClock:AddTask("BeginRobRes", StartSignTime, SignBeginTick, nil)
		else
			local tbl, enterTime, type = result[1], result[2],result[3]
			local data = {}
			data["time"] = {enterTime}
			data["wday"] = StartSignTime.wday
			g_RobResMgr.m_CurrentType = type
			if type == "Signning" then
				g_RobResMgr.m_ChangeTypeTask = g_AlarmClock:AddTask("ChangeType", data, SignEnd, nil)
			elseif type == "Waiting" then
				g_RobResMgr.m_ChangeTypeTask = g_AlarmClock:AddTask("ChangeType", data, BeginRobRes, nil)
			elseif type == "Playing" then
				g_RobResMgr.m_ChangeTypeTask = g_AlarmClock:AddTask("ChangeType", data, EndRobRes, nil)
			end
			g_AlarmClock:AddTask("BeginRobRes", StartSignTime, SignBeginTick, nil)
			--��������
			if type == "Waiting" or type == "Playing" then
				for _, info in pairs(tbl) do
					local sceneId = info[1]
					local serverId = info[2]
					if serverId == g_CurServerId then
						local scene = g_SceneMgr:CreateScene("������Դ��", sceneId, nil)
					else
						Gas2GasAutoCall:CreateRobScene(GetServerAutoConn(serverId), sceneId, "������Դ��")
					end
				end
			end
		end
	end
	CallDbTrans("GasTongRobResDB", "GetRobResState", CallBack, {}, "rob_state")
end


function CTongRobResMgr:JoinRobResFb(Conn)
	if g_RobResMgr.m_CurrentType ~= "Signning" then
		MsgToConn(Conn, 320001)
		return
	end
	if not IsCppBound(Conn) then
		return 
	end
	local Player = Conn.m_Player
	local PlayerId = Player.m_uID
	local parameters = {}
	parameters["charId"] = PlayerId
	parameters["objName"] = Player.m_SignUpId
	parameters["serverId"] = g_CurServerId 
	parameters["sceneName"] = "������Դ��"
	if Player.m_Properties:GetTongID() == 0 then
		MsgToConn(Conn, 9450)
		return
	end
	local scene 
	--�Ƿ�������ֱ�������
	local function CallBack(result)
		if not result then
			return 
		end
		local msg = result[1]
		local winPlayerTbl = result[2]
		local lossPlayerTbl = result[3]
--		local sceneId = result[4]
--		local serverId = result[5]
		if msg == true then
			Gas2Gac:ShowJudgnJoinWnd(Conn, result[2])
			return
		end
		if msg == 9453 then
			if lossPlayerTbl then
				for _, id in pairs(lossPlayerTbl) do
					MsgToConnById(id, 9470)
				end
			end
			if winPlayerTbl then
				for _, id in pairs(winPlayerTbl) do
					if id ~= PlayerId then
						MsgToConnById(id, 9461)
					end
				end
			end
		end
		MsgToConn(Conn, msg)
--		if not g_SceneMgr:GetScene(sceneId) then
--			scene = g_SceneMgr:CreateScene("������Դ��", sceneId, nil)
--		end
	end
	CallAccountManualTrans(Conn.m_Account, "GasTongRobResDB", "JudgeRobResSign", CallBack, parameters, "RobResSignLock")
end

--����ʱʹ��
function CTongRobResMgr.PlayerOffLineRobResFb(Player)
	local Conn = Player.m_Conn
	local Scene = Player.m_Scene
	local nSceneID = Scene.m_SceneId
	local nPlayerID = Player.m_uID
-- ��¼����ʱ��
	local nowdate = os.date("*t")
	local nowmin = nowdate.min
	local nowsec = nowdate.sec
	Scene.m_OffLineTime = {}
	Scene.PlayerOffLine = {}
	Scene.PlayerOffLine = true
end

function CTongRobResMgr.PlayerLoginRobRes(Player)
	local	Scene = Player.m_Scene
	local PlayerId = Player.m_uID
	if Scene and Scene.m_OffLineTime then
		if Scene.m_OffLineTime[Player.m_uID] then
			Scene.m_OffLineTime[Player.m_uID] = nil
		end	
	end
	if g_RobResMgr.m_CurrentType == "Playing" or g_RobResMgr.m_CurrentType == "Waiting" then
		local curDate = os.date("*t")
		local ostime = (curDate.hour * 60 + curDate.min) * 60 + curDate.sec
		if g_RobResMgr.m_OpenTime then
			time = WaitEnterSceneTime - (os.time() - g_RobResMgr.m_OpenTime)
		else
			time = WaitJointTime * 60 + GetOffsetSecond(StartSignTime.time[1]) + WaitEnterSceneTime - ostime
		end	
		Gas2Gac:RetOpenFbActionWnd(Player.m_Conn, "������Դ��", time)
		if Scene.m_objName and Scene.m_Time then
			Gas2Gac:ShowCountDown(Player.m_Conn, Scene.m_objName, Scene.m_Time)
		end
	end
end


function CTongRobResMgr.IsCanEnterRobResScene(scene, charId)
	if g_RobResMgr.m_CurrentType == "Playing" then
		return true
	end
	if g_RobResMgr.m_CurrentType == "Waiting" then
		return true
	end
end



function CTongRobResMgr:CancelSignResource(Conn)
	if not IsCppBound(Conn) then
		return 
	end
	if not IsCppBound(Conn.m_Player) then
		return 
	end
	local tongid = Conn.m_Player.m_Properties:GetTongID()
	if tongid == 0 then
		MsgToConn(Conn, 9450)
		return 
	end
	local data = {}
	data["charId"] = Conn.m_Player.m_uID
	local function CallBack(flag, state,sceneId, serverId, onlineMember)
		if flag then
			for _, charId in pairs(onlineMember) do
				MsgToConnById(charId, 9474)
			end
			if state == "Waiting" or state == "Playing" then
				local function ChangeSceneByDelete(serverId, sceneId, tongid)
					if sceneId ~= 0 then
						Gas2GasAutoCall:ChangeByCancel(GetServerAutoConn(serverId), sceneId, tongid)
					end
				end
				RegisterOnceTick(Conn.m_Player, "ChangeSceneByDelete", ChangeSceneByDelete, 2000, serverId, sceneId, tongid)
			end
		end
	end
	CallAccountManualTrans(Conn.m_Account, "GasTongRobResourceDB", "DeleteTongById", CallBack, data)
end

function Gas2GasDef:ChangeByCancel(Conn, sceneId, tongid)
	local scene = g_SceneMgr:GetScene(sceneId)
	local playerTbl = nil
	if scene then
		playerTbl = scene.m_tbl_Player
	end
	if playerTbl then
		for playerId, Player in pairs(playerTbl) do
			if Player.m_Properties:GetTongID() == tongid then
				local sceneName = Player.m_MasterSceneName
				local pos = Player.m_MasterScenePos
				ChangeSceneByName(Player.m_Conn,sceneName,pos.x,pos.y)
			end
		end	
	end
end

function Gas2GasDef:UpdateRobResWin(Conn)
	local function CallBack(result)
		g_RobResWinTbl = {}
		local num = result:GetRowNum()
		if num > 0 then
			for i = 0, num - 1  do
				g_RobResWinTbl[result:GetData(i,1)] = {result:GetData(i,0),result:GetData(i,2)}
			end
		end
	end
	CallDbTrans("GasTongRobResourceDB", "GetRobResDataTong", CallBack, {})
end

function CTongRobResMgr:ShowCancelWnd(Conn)
	if not IsCppBound(Conn) then
		return 
	end
	if not IsCppBound(Conn.m_Player) then
		return 
	end
	if Conn.m_Player.m_Properties:GetTongID() == 0 then
		MsgToConn(Conn, 9450)
		return 
	end
	local data = {}
	data["tongId"] = Conn.m_Player.m_Properties:GetTongID()
	data["charId"] = Conn.m_Player.m_uID
	local function CallBack(flag, objName, purview)
		if not purview then
			MsgToConn(Conn, 9451)
			return 
		end
		if objName ~= Conn.m_Player.m_SignUpId then
			MsgToConn(Conn, 9477)
			return 
		end
		if flag then
			Gas2Gac:RetShowCancelWnd(Conn)
		else
			MsgToConn(Conn, 9475) -- ������Ӷ����δ�μ���Դ������
		end
	end
	CallAccountManualTrans(Conn.m_Account, "GasTongRobResourceDB", "SelectObjNameByTongId", CallBack, data)
end

function CTongRobResMgr:OpenSignQueryWnd(Conn)
	if not IsCppBound(Conn) then
		return 
	end
	if not IsCppBound(Conn.m_Player) then
		return 
	end
	local parameters = {}
	parameters["signUpId"] = Conn.m_Player.m_SignUpId
	
	local function CallBack(result)
		Gas2Gac:DelItem(Conn)
		if result then
			for _, resTbl in pairs(result) do
				local tongName = resTbl[1]
				local tongCamp = resTbl[2]  -- 1:����  2:��ʥ  3:��˹
				local exploitPoint = resTbl[3]
				local winName = resTbl[4]
				local str = nil
				if winName then
					str = GetStaticTextServer(330001,winName)
				else
					str = GetStaticTextServer(330002)
				end
				if tongName and tongCamp then
					Gas2Gac:RetOpenSignQueryWnd(Conn, tongName, tongCamp, exploitPoint,str)
				else
					Gas2Gac:RetNoneOpenSignQueryWnd(Conn, str)
				end
			end
		else
			local str = GetStaticTextServer(330002)
			Gas2Gac:RetNoneOpenSignQueryWnd(Conn, str)
		end
	end
	CallAccountManualTrans(Conn.m_Account, "GasTongRobResourceDB", "SelectSignUpTongName", CallBack, parameters)
end


function CTongRobResMgr:GetProffer(Conn)
	if not IsCppBound(Conn) then
		return 
	end
	local Player = Conn.m_Player
	if not IsCppBound(Player) then
		return 
	end
	if Player.m_Properties:GetTongID() == 0 then
		MsgToConn(Conn, 9450)
		return 
	end
	
	
	local parameters = {}
	parameters["charId"] = Player.m_uID
	parameters["objName"] = Player.m_SignUpId
--	parameters["getTime"] = GetProfferTime()
	local function CallBack(result)
		if not result then
			return
		end
		local flag = result[1]
		local proffer = result[2]
		if flag then
			MsgToConn(Conn, 9471, proffer)
			return
		end
		MsgToConn(Conn, proffer)
	end
	CallAccountManualTrans(Conn.m_Account, "GasTongRobResourceDB", "GetProffer", CallBack, parameters)
end

function CTongRobResMgr:UpdateJoinInfo(Conn)
	if not IsCppBound(Conn) then
		return 
	end
	local Player = Conn.m_Player
	if not IsCppBound(Player) then
		return 
	end
	local parameters = {}
	parameters["charId"] = Player.m_uID
	parameters["objName"] = Player.m_SignUpId
	local function CallBack(result)
		if not result then
			return 
		end
		local msg = result[1]
		local winPlayerTbl = result[2]
		local lossPlayerTbl = result[3]
		local sceneId = result[4]
		local serverId = result[5]
	
		if lossPlayerTbl then
			for _, id in pairs(lossPlayerTbl) do
				MsgToConnById(id, 9470)
			end
		end
		if winPlayerTbl then
			for _, id in pairs(winPlayerTbl) do
				if id ~= PlayerId then
					MsgToConnById(id, 9461)
				end
			end
		end
		MsgToConn(Conn, msg)
	end
	CallAccountManualTrans(Conn.m_Account, "GasTongRobResDB", "UpdateJoinInfo", CallBack, parameters, "updateJoinInfo")
end


function CTongRobResMgr.LeaveRobResFbScene(Conn)
	if g_RobResMgr.m_SignEndTick then
		UnRegisterTick(g_RobResMgr.m_SignEndTick)
		g_RobResMgr.m_SignEndTick = nil
	end
	
	if g_RobResMgr.m_BeginRobResTick then
		UnRegisterTick(g_RobResMgr.m_BeginRobResTick)
		g_RobResMgr.m_BeginRobResTick = nil
	end
	
	if not IsCppBound(Conn) then
		return 
	end
	local Player = Conn.m_Player
	if not IsCppBound(Player) then
		return 
	end
	
	if g_RobResMgr.m_EndRobResTick then
		UnRegisterTick(g_RobResMgr.m_EndRobResTick)
		g_RobResMgr.m_EndRobResTick = nil
	end
--	TestPrint("֪ͨ����г�����")
	if Player.m_Scene.m_SceneAttr.SceneType == 26 then --˵�����ڴ���ɱ������
		local sceneName = Player.m_MasterSceneName
		local pos = Player.m_MasterScenePos 
		ChangeSceneByName(Player.m_Conn,sceneName,pos.x,pos.y)
	end
end

function CTongRobResMgr.PlayerOutFb(Conn)
	if not IsCppBound(Conn) then
		return 
	end
	local Player = Conn.m_Player
	if not IsCppBound(Player) then
		return 
	end
	local sceneName = Player.m_MasterSceneName
	local pos = Player.m_MasterScenePos 
	ChangeSceneByName(Player.m_Conn,sceneName,pos.x,pos.y)
end

function CTongRobResMgr.ClearRobResTick()
	if g_RobResMgr then
		if g_RobResMgr.m_SignEndTick then
			UnRegisterTick(g_RobResMgr.m_SignEndTick)
			g_RobResMgr.m_SignEndTick = nil
		end
		if g_RobResMgr.m_BeginRobResTick then
			UnRegisterTick(g_RobResMgr.m_BeginRobResTick)
			g_RobResMgr.m_BeginRobResTick = nil
		end
		if g_RobResMgr.m_EndRobResTick then
			UnRegisterTick(g_RobResMgr.m_EndRobResTick)
			g_RobResMgr.m_EndRobResTick = nil
		end
	end
end

function Gas2GasDef:CreateRobScene(Conn, sceneId, sceneName)
	local scene = g_SceneMgr:CreateScene(sceneName, sceneId, nil)
end

local function GetGold(money)
	return math.floor (money / 10000)
end

local function GetArgent(money)
	return math.floor ((money - GetGold(money) * 10000)/ 100)
end

local function GetCopper(money)
	return math.floor((money - GetGold(money) * 10000 - GetArgent(money) * 100))
end

function CTongRobResMgr:GetHeaderAward(Conn)
	if not IsCppBound(Conn) then
		return 
	end
	local Player = Conn.m_Player
	if not IsCppBound(Player) then
		return 
	end
	if Player.m_Properties:GetTongID() == 0 then
		MsgToConn(Conn, 9450)
		return 
	end
	
	local parameters = {}
	parameters["charId"] = Player.m_uID
	parameters["objName"] = Player.m_SignUpId
	--parameters["getTime"] = GetProfferTime()
	local function CallBack(result)
		if not result then
			return
		end
		local flag = result[1]
		local msg = result[2]
		if flag then
			MsgToConn(Conn, 9482, GetGold(msg),GetArgent(msg),GetCopper(msg))
			return
		end
		
		MsgToConn(Conn, msg)
	end
	CallAccountManualTrans(Conn.m_Account, "GasTongRobResDB", "GetHeaderAward", CallBack, parameters)
end

function Gas2GasDef:GetRobResWinInfo(Conn, charId, sceneId, objName, tongName, tongCamp)
	local scene = g_SceneMgr:GetScene(sceneId)
	local sceneName = scene.m_SceneName
	local obj = GetOnlyIntObj(sceneId, objName)
	if obj then
		Gas2GacById:RobResWinOnMiddleMap(charId, sceneName, objName, tongName, tongCamp)
	end
end

function CTongRobResMgr.ShowRobResOnMiddleMap(Conn, SceneName)
	if not (IsCppBound(Conn) and IsCppBound(Conn.m_Player)) then
		return
	end
	local sceneId, serverId = g_SceneMgr:GetSceneByName(SceneName)
	for ObjName, _ in pairs(ObjNameAndLvStepTbl) do
		if g_RobResWinTbl[ObjName] then
			Gas2GasAutoCall:GetRobResWinInfo(GetServerAutoConn(serverId), Conn.m_Player.m_uID, sceneId, ObjName, g_RobResWinTbl[ObjName][1], g_RobResWinTbl[ObjName][2])
		else
			Gas2GasAutoCall:GetRobResWinInfo(GetServerAutoConn(serverId), Conn.m_Player.m_uID, sceneId, ObjName, "", 0)
		end
	end
end

function CTongRobResMgr.GetRobResWinInfo()
	for server_id in pairs(g_ServerList) do  --obj, name, camp
		Gas2GasAutoCall:UpdateRobResWin(GetServerAutoConn(server_id))
	end
end

function CTongRobResMgr.StartUpGetRobInfo()
	local function CallBack(result)
		g_RobResWinTbl = {}
		local num = result:GetRowNum()
		if num > 0 then
			for i = 0, num - 1  do
				g_RobResWinTbl[result:GetData(i,1)] = {result:GetData(i,0),result:GetData(i,2)}
			end
		end
	end
	CallDbTrans("GasTongRobResourceDB", "GetRobResDataTong", CallBack, {})
end

function CTongRobResMgr.StartRobSign(Conn)
	if not IsCppBound(Conn) then
		return 
	end
		
	if not IsCppBound(Conn.m_Player) then
		return
	end
	local Player = Conn.m_Player
	local data = {}
	data["state"] = "Signning"
	g_RobResMgr.m_CurrentType = "Signning"
	CallAccountAutoTrans(Conn.m_Account, "GasTongRobResDB", "AddRobResState", CallBack, data)
	CallAccountAutoTrans(Conn.m_Account, "GasTongRobResDB", "DeleteSceneInfo", CallBack, {})
end

function CTongRobResMgr.EndRobSign(Conn)
	if not IsCppBound(Conn) then
		return 
	end
		
	if not IsCppBound(Conn.m_Player) then
		return
	end
	local Player = Conn.m_Player
	local data = {}
	data["state"] = "Waiting"
	g_RobResMgr.m_CurrentType = "Waiting"
	g_RobResMgr.m_OpenTime = os.time()
	CallAccountAutoTrans(Conn.m_Account, "GasTongRobResDB", "UpdateRobResState", CallBack, data)
end

function CTongRobResMgr.StartRobRes(Conn)
	if not IsCppBound(Conn) then
		return 
	end
		
	if not IsCppBound(Conn.m_Player) then
		return
	end
	local Player = Conn.m_Player
	local data = {}
	data["state"] = "Playing"
	g_RobResMgr.m_CurrentType = "Playing"
	CallAccountAutoTrans(Conn.m_Account, "GasTongRobResDB", "UpdateRobResState", CallBack, data)
end

function CTongRobResMgr.StopRobRes(Conn)
	if not IsCppBound(Conn) then
		return 
	end
		
	if not IsCppBound(Conn.m_Player) then
		return
	end
	local Player = Conn.m_Player
	local data = {}
	data["state"] = "Ending"
	data["charId"] = Conn.m_Player.m_uID
	g_RobResMgr.m_CurrentType = "Ending"
	CallAccountAutoTrans(Conn.m_Account, "GasTongRobResDB", "UpdateRobResState", nil, data)
	local function callback(result)
		if not result then
			return
		end
		local len = table.getn(result)
		if len == 0 then
			return
		end
		for _, sceneId in pairs(result) do
			local Scene = g_SceneMgr:GetScene(sceneId)
			if Scene ~= nil then 	--���˸��� ���˳��˾����ڴ�
				Scene:Destroy()
			end
		end
	end
	CallDbTrans("GasTongRobResourceDB","DeleteTempRobResData", callback, {}, "clearRobRes")
end

function CTongRobResMgr.ClearAwardInfo()
	local function ClearAwardInfo()
		
		CallDbTrans("GasTongRobResDB","DelHeaderAwardInfo", nil, {})
	end
	g_AlarmClock:AddTask("ClearAwardInfo", ResetTime, ClearAwardInfo)  
end



function CTongRobResMgr.StartClearAwardInfo()
	CallDbTrans("GasTongRobResDB","StartClearAwardInfo", nil, {})
end

