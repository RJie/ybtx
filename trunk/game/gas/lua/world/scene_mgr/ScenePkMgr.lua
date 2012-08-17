cfg_load "scene/PkRuleInfo_Common"
CScenePkMgr = class()

local TempAreaTbl = {
	["���׵۹�������ǲӪ��"] = true,
	["��ʥ������������ʿӪ��"]= true,
	["��˹�¾�������ǲӪ��"]= true,
	["��ʨ��Ѫ��Ӫ��"] = true,
	["��ʥ�����ӹ�Ӫ��"]= true,
	
	["�ӹ��¾�Ӫ��"]= true,
	["���׻�ʨ�ӿ���Ӫ��"]= true,
	["��ʥ��������Ӫ��"]= true,
	["�����¾�Ӫ��"]= true,
	
	["ѩ��¶̨"]= true,
	["��ԷС��"]= true,
	["���С��"]= true,

	["���ִ�"]= true,
	["��ʥ����Ӫ��"]= true,
	["��˹���ִ���"]= true,
	["���ֽ�ս��"]= true,
	
	["��������Ӫ��"]= true,
}

----����������ʱ��ʼ���
--��ó����е���������
local function GetSceneArea(Scene)
	local sceneName = Scene.m_SceneName 
	local tbl = {}
	if g_AreaMgr.m_SceneAreaTbl[sceneName] then
		for _, areaName in pairs(g_AreaMgr.m_SceneAreaTbl[sceneName].AreaNames)do
			table.insert(tbl, areaName)
		end	
		return tbl
	end
end

--��õ�ǰʱ��
local function GetOffSet()
 	local osTime = os.date("*t")
	local hour = osTime.hour
	local minute = osTime.min
	local second = osTime.sec
	local time = hour * 60 * 60 + minute * 60  + second 
	return time 
end

--�ж���ҵĵȼ�
local function JudgePlayerLevel(Scene, areaName, player)
	local PlayerMinLevel
	local PlayerMaxLevel
	local PlayerLevel
	if Scene.m_AreaInfoTbl[areaName] then	
		local pkRuleKeys = PkRuleInfo_Common:GetKeys()
		for i, pkRuleAreaTemp in pairs(pkRuleKeys) do
			if pkRuleAreaTemp == areaName then
				local pkRuleTemp = PkRuleInfo_Common(pkRuleAreaTemp)
				local tempKeys = pkRuleTemp:GetKeys()
				for _, temp in pairs(tempKeys) do
					PlayerMinLevel = pkRuleTemp(temp, "MinLevel")
					PlayerMaxLevel = pkRuleTemp(temp, "MaxLevel")
					if not IsCppBound(player) then
						return 
					end
					PlayerLevel = player:CppGetLevel()
					if PlayerLevel >= PlayerMinLevel and PlayerLevel <= PlayerMaxLevel then
						return true
					else 
						return false
					end
				end
			end
		end
	end
	return false
end

--������Ϣ(�е�ͼ��ʾ)
local function SendMsg(Scene, areaName, detectTime)
	local sceneName = Scene.m_SceneName
	local playerTbl = Scene.m_tbl_Player
	if playerTbl then
		for playerId, player in pairs(playerTbl) do
			local EternalState = 0
			Gas2Gac:AreaPkOnMiddleMap(player.m_Conn, sceneName, areaName, Scene.m_AreaInfoTbl[areaName].m_AreaState, detectTime, EternalState)	
		end 
	end
end

--�������pk��״̬
local function SendPlayerUpdateState(player,value)
	--player.m_SwitchState = value
	if IsCppBound(player) then
		player:CppSetPKState(value)
	end
end

--�����ҵĿ���״̬
local function GetPlayerSwitch(player)
	return player.m_SwitchState 
end

local function SendRpcMessage(player)
	if IsCppBound(player) and IsCppBound(player.m_Conn) then
		Gas2Gac:TransferSwitchState(player.m_Conn, GetPlayerSwitch(player))	
		Gas2Gac:UpdatePkSwitchState(player.m_Conn)
		Gas2Gac:UpdateHeadInfoByEntityID(player:GetIS(0), player:GetEntityID())
	end
end

--������ҵ�״̬
local function UpdatePlayerState(Scene, areaName)
	if Scene.m_AreaInfoTbl[areaName] then
		if Scene.m_AreaInfoTbl[areaName].m_AreaState == true then	
			for _, player in pairs(Scene.m_AreaInfoTbl[areaName]. m_PlayerTbl) do
				MsgToConn(player.m_Conn, 193030, areaName)
				if not IsCppBound(player) then
					return 
				end
				if player:ExistState("��������״̬") then
					SendPlayerUpdateState(player, false)
				else
					local playerLevelFlag = JudgePlayerLevel(Scene, areaName, player)
					if playerLevelFlag == false then
						SendPlayerUpdateState(player, false)
					else
						SendPlayerUpdateState(player, true)
					end
				end
				SendRpcMessage(player)
			end
		else
			for _, player in pairs(Scene.m_AreaInfoTbl[areaName]. m_PlayerTbl) do
				MsgToConn(player.m_Conn, 193031, areaName)
				SendPlayerUpdateState(player, false)
				SendRpcMessage(player)
			end
		end
	end	
end


function CScenePkMgr.DetectArea(Scene)
	local sceneName = Scene.m_SceneName
	local AreaTbl = GetSceneArea(Scene)
	
	local PlayerMinLevel 
	local PlayerMaxLevel 
	local DetectTime
	
	if AreaTbl then
		for _, areaName in pairs(AreaTbl) do
			local pkRuleKeys = PkRuleInfo_Common:GetKeys()
			for i, pkRuleAreaTemp in pairs(pkRuleKeys) do
				if pkRuleAreaTemp == areaName then
					local pkRuleTemp = PkRuleInfo_Common(pkRuleAreaTemp)
					local tempKeys = pkRuleTemp:GetKeys()
					for _, temp in pairs(tempKeys) do
						if temp == sceneName then
							DetectTime = pkRuleTemp(temp, "DetectTime") * 60 * 1000
							Percent = pkRuleTemp(temp, "Percent") 
							local function DetectAreaTick(Tick, Scene, areaName)
								
								Tick.m_Time = GetOffSet()
								local flag 
								local PlayerNum = 0
								local agreePkNum = 0  --����ʱ,Ĭ��Ϊ��ͬ��pk
								if not Scene.m_AreaInfoTbl[areaName] then
								
									Scene.m_AreaInfoTbl[areaName] = {}
									Scene.m_AreaInfoTbl[areaName].m_AreaState = false
									Scene.m_AreaInfoTbl[areaName].m_PlayerTbl = {}
									Scene.m_AreaInfoTbl[areaName].m_PlayerNum = 0
									if pkRuleAreaTemp == areaName then
										local time = pkRuleTemp(temp, "DetectTime") * 60 * 1000
										SendMsg(Scene, areaName, time)
									end
								else	
									if Scene.m_AreaInfoTbl[areaName].m_PlayerTbl then
										if Scene.m_AreaInfoTbl[areaName].m_PlayerNum == 0 then
											Scene.m_AreaInfoTbl[areaName].m_AreaState = false	
											if pkRuleAreaTemp == areaName then
												local time = pkRuleTemp(temp, "DetectTime") * 60 * 1000
												SendMsg(Scene, areaName, time)
											end
										end
										
										for _, player in pairs(Scene.m_AreaInfoTbl[areaName].m_PlayerTbl) do
											local playLevelFlag = JudgePlayerLevel(Scene, areaName, player)
											if playLevelFlag == true then
												PlayerNum = PlayerNum + 1
												if Scene.m_AreaInfoTbl[areaName] then
													local playerPkState = GetPlayerSwitch(player)
													if playerPkState == true then
														agreePkNum = agreePkNum + 1
													end
												end
											end
											if playLevelFlag == false then
												SendPlayerUpdateState(player, false)		
											end
										end
										if PlayerNum ~= 0 then
											if agreePkNum/PlayerNum >= Percent then
												Scene.m_AreaInfoTbl[areaName].m_AreaState = true
											else
												Scene.m_AreaInfoTbl[areaName].m_AreaState = false
											end	
										else
											Scene.m_AreaInfoTbl[areaName].m_AreaState = false
										end
										if pkRuleAreaTemp == areaName then
											local time = pkRuleTemp(temp, "DetectTime") * 60 * 1000
											SendMsg(Scene, areaName, time)
										end
										UpdatePlayerState(Scene, areaName)
									end
								end
							end
						
							if TempAreaTbl[areaName] ~= true then
								local tick = RegisterTick("PkDetectTick", DetectAreaTick, DetectTime, Scene, areaName)
								tick.m_Time = GetOffSet()
								tick.m_AreaName = areaName
								if not Scene.m_pkTick then
									Scene.m_pkTick = {}
								end
								Scene.m_pkTick[areaName] = tick
								--table.insert(Scene.m_pkTick, tick)
							end
						end
					end
				end
			end
		end		
	end
end

function CScenePkMgr.OpenPkSwitch(Conn, PkSwitchValue)
	local Player = Conn.m_Player
	if not IsCppBound(Player) then
		return
	end
	if PkSwitchValue == true then
		Player.m_SwitchState = false  
		Gas2Gac:TransferSwitchState(Conn, Player.m_SwitchState)
	elseif PkSwitchValue == false then
		Player.m_SwitchState = true
		Gas2Gac:TransferSwitchState(Conn, Player.m_SwitchState)
	end
end

function CScenePkMgr.ChangePkState(Player)
	Player:CppSetPKState(false)
	Gas2Gac:TransferSwitchState(Player.m_Conn,Player.m_SwitchState)
	Gas2Gac:UpdatePkSwitchState(Player.m_Conn)
	Gas2Gac:UpdateHeadInfoByEntityID(Player:GetIS(0), Player:GetEntityID())
end


local function ClearPkData()
	CallDbTrans("CharacterMediatorDB", "ClearPkInfo", nil, {})
end

local function ClearPkFlagData()
	CallDbTrans("CharacterMediatorDB", "ClearPkFlagInfo", nil, {})
end

g_AlarmClock:AddTask("ClearPkFlagData", {wday = {1,2,3,4,5,6,7},time = {"00:00"}}, ClearPkFlagData)
g_AlarmClock:AddTask("ClearPkData", {wday = {1,2,3,4,5,6,7},time = {"00:00"}}, ClearPkData)
