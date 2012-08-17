gas_require "world/area_server/AreaServerInc"
gas_require "fb_game/match_game/MatchGameMgr"
cfg_load "scene/PkRuleInfo_Common"

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
	
	["����ǰ�ߴ�����"]= true,
	["����ǰ�ߴ�����פ��"]= true,
	["����ǰ�ߴ�����ƽԭ"]= true,
	["��ʥǰ�ߴ�����"]= true,
	["��ʥǰ�ߴ�����פ��"]= true,
	["��ʥǰ�ߴ�����ƽԭ"]= true,
	["��˹ǰ�ߴ�����"]= true,
	["��˹ǰ�ߴ�����פ��"]= true,
	["��˹ǰ�ߴ�����ƽԭ"]= true,
	["ǰ������2"]= true,
	["ǰ������"]= true,
	
}

local PeaceAreaTbl = {
	["��������Ӫ��"]= true,
}


local function GetAreaDate(scene, areaName)

	local areaTbl = nil
	if scene.m_AreaInfoTbl then
		areaTbl = scene.m_AreaInfoTbl[areaName]
		if not areaTbl then
			areaTbl = {}
			areaTbl.m_PlayerTbl = {}
			areaTbl.m_PlayerNum  = 0
			areaTbl.m_AreaState  = false
			scene.m_AreaInfoTbl[areaName] = areaTbl
		end
	end
	return areaTbl
end

function Gac2Gas:GetMatchGameNpcTips(Conn, PointName)						
	local Tips = ""
	local GameNames = g_MatchGameMgr:GetCurOpenGames(PointName)
	Gas2Gac:SetMatchGameNpcTips(Conn, PointName, GameNames)
end


function Gas2GasDef:GetPkState(Conn, charId, sceneId)
	local scene = g_SceneMgr:GetScene(sceneId)
	local sceneName = scene.m_SceneName
	if g_AreaMgr.m_SceneAreaTbl[sceneName] then
		for _, areaName in pairs(g_AreaMgr.m_SceneAreaTbl[sceneName].AreaNames)do
			local pkAreaTbl = GetAreaDate(scene, areaName)
			if not pkAreaTbl then
				return 
			end
			local areaPkState = pkAreaTbl.m_AreaState
			local osTime = os.date("*t")
			local hour = osTime.hour
			local minute = osTime.min
			local second = osTime.sec
			local tickTime 
			local Time 
			local tempTime = hour * 60 * 60 + minute * 60 + second 
			if not scene.m_pkTick then
				return 
			end
			
			--for _ ,tick in pairs(scene.m_pkTick) do
			local tick = scene.m_pkTick[areaName]
			if tick then
				if tick.m_AreaName == areaName then
					tickTime = tick.m_Time
					tempTime = tempTime - tickTime 
					
					local pkRuleKeys = PkRuleInfo_Common:GetKeys()
					for i, pkRuleAreaTemp in pairs(pkRuleKeys) do
						if pkRuleAreaTemp == areaName then
							local pkRuleTemp = PkRuleInfo_Common(pkRuleAreaTemp)
							local tempKeys = pkRuleTemp:GetKeys()
							for _, temp in pairs(tempKeys) do
								local detectTime = pkRuleTemp(temp, "DetectTime")
								if tempTime < detectTime * 60 then
									Time = detectTime * 60 * 1000 - tempTime * 1000
								else
									Time = (tempTime * 1000) % (detectTime * 60 * 1000)
								end
								local EternalState = 0
								Gas2GacById:AreaPkOnMiddleMap(charId, sceneName, areaName, areaPkState, Time, EternalState)
							end
						end
					end				
				end
			else
				areaPkState = true
				local EternalState = 1
				Time = 0
				Gas2GacById:AreaPkOnMiddleMap(charId, sceneName, areaName, areaPkState, Time, EternalState)
			end		
		end
	end
	
--	for  do
--		Gas2GacById:AreaPkOnMiddleMap(charId, scene.m_SceneName, areaName, areaPkState, Time)
--	end
--	
end

function Gac2Gas:SendAreaPkOnMiddleMap(Conn, sceneName)
	local sceneId, serverId = g_SceneMgr:GetSceneByName(sceneName)
	if not (IsCppBound(Conn) and IsCppBound(Conn.m_Player)) then
		return
	end
	Gas2GasAutoCall:GetPkState(GetServerAutoConn(serverId), Conn.m_Player.m_uID, sceneId)
end


function CAreaServer:GetPlayerSceneAreaInfo(Conn,SceneName)
	
end

function CAreaServer:FinishAreaQuest(Conn, AreaName)
	
end

local function FirstTimeIntoArea(Conn, AreaName)
	local Player = Conn.m_Player	
	if AreaName == nil or AreaName == "" then
		return
	end
	

	local function CallBack(ret)
		if IsCppBound(Player) and ret[1] then
			if AreaName == "����ũ��"
				or AreaName == "�糵ũ��"
				or AreaName == "��ܽׯ԰" then
				Player:IsFirstTimeAndSendMsg("������", 4003, sMsg)
			end
			
			Gas2Gac:RetFirstTimeIntoArea(Player.m_Conn, AreaName, ret[1], ret[2])
		end
	end
	local data = {Player.m_uID, AreaName}
	--local AreaDB = (g_DBTransDef["AreaDB"])
	CallAccountAutoTrans(Conn.m_Account, "AreaDB", "FirstTimeIntoArea", CallBack, data)	
end

function Gac2Gas:GetPlayerSceneAreaInfo(Conn,SceneName)
	if not IsCppBound(Conn.m_Player) then
		return
	end
	
	if SceneArea_Common_Shell(SceneName) then
		local function CallBack(ret)
			for i = 1, table.getn(ret) do
				Gas2Gac:RetPlayerAreaInfo(Conn,ret[i][1],ret[i][2],ret[i][3])
			end
			Gas2Gac:RetPlayerSceneAreaInfo(Conn,SceneName)
		end
		local data = {Conn.m_Player.m_uID,SceneName}
		--local AreaDB = (g_DBTransDef["AreaDB"])
		CallAccountAutoTrans(Conn.m_Account, "AreaDB", "GetPlayerSceneAreaInfo", CallBack, data)
	end
end

local function CallDbChangeArea(player, areaName, isFirstInArea)
	local function OnSaveAreaTick()
		if player.m_SaveAreaTick then
			UnRegisterTick(player.m_SaveAreaTick)
			player.m_SaveAreaTick = nil
		end
		if not ( IsCppBound(player) and IsCppBound(player.m_Conn) ) then
			return
		end
		local areaName = player.ChangeAreaBuffer[1]
		local isFirstInArea = player.ChangeAreaBuffer[2]
		if isFirstInArea then
			FirstTimeIntoArea(player.m_Conn, areaName)
		else
			local PlayerId = player.m_uID
			if areaName ~= "" then
					local data = {PlayerId, areaName}
					CallAccountAutoTrans(player.m_Conn.m_Account, "AreaDB", "PlayerIntoArea", nil, data)
			else
				local data = {PlayerId}
				CallAccountAutoTrans(player.m_Conn.m_Account, "AreaDB", "PlayerOutFromArea", nil, data)
			end
		end
		player.LastSaveAreaTime = os.time()
		--print ("��������   " .. areaName)
	end
	
	player.ChangeAreaBuffer = {areaName, isFirstInArea}
	
	if isFirstInArea then
		OnSaveAreaTick()
		return
	end
	local now = os.time()
	if player.LastSaveAreaTime and now - player.LastSaveAreaTime < 5 then --��Ҫ����
		--print "��Ҫ����"
		if not player.m_SaveAreaTick then
			--print "ע��tick"
			player.m_SaveAreaTick = RegisterTick("SaveAreaTick", OnSaveAreaTick, 5000)
		else
			--print "�Ѿ���tick"
		end
	else
		--print "����Ҫ����"
		OnSaveAreaTick()
	end
end


function Gac2Gas:PlayerChangeAreaPlace(Conn, x, y, areaName, isFirstInArea)
	local player = Conn.m_Player
	if not IsCppBound(player) then
		return
	end
	
	local serverPos = CPos:new()
	player:GetGridPos(serverPos)
	local dx = serverPos.x - x
	local dy = serverPos.y - y
	if dx * dx + dy * dy > 25 then
		--print("�ͻ��˺ͷ��������������̫��")
		return
	end
	
	local scene = player.m_Scene
	local SceneName = scene.m_SceneName
	local pos = {x = x, y = y}
	local area = g_AreaMgr:GetSceneAreaName(SceneName, pos)
	if area ~= areaName then
		return
	end
	
	CallDbChangeArea(player, areaName, isFirstInArea)
	
	if player.m_AreaName ~= areaName then
		if not g_PublicAreaSceneMgr:OnPlayerChangeArea(player, areaName, pos) then
			OnPlayerChangeOutArea(player, player.m_AreaName)
			OnPlayerChangeInArea(player, areaName, true)
		end
	end
end

local function PlayerPkChange(player, scene, areaName)
	local sceneType = scene.m_SceneAttr.SceneType
	if not IsCppBound(player) then
		return 
	end
	if player:ExistState("��������״̬") and not TempAreaTbl[areaName] and sceneType ~=26 and sceneType ~= 27 and sceneType ~= 7 then
		player:CppSetPKState(false)
		Gas2Gac:TransferSwitchState(player.m_Conn,player.m_SwitchState)
		Gas2Gac:UpdatePkSwitchState(player.m_Conn)
		Gas2Gac:UpdateHeadInfoByEntityID(player:GetIS(0), player:GetEntityID())
		return 
	end
	local SceneName = scene.m_SceneName
	if not scene.m_AreaInfoTbl then
		return 
	end
	local pkStateFlag = scene.m_AreaInfoTbl[areaName].m_AreaState
	local playerLevel = player:CppGetLevel()
	if IsServerObjValid(player) then
		
		if player:CppGetPKState() ~= pkStateFlag then  --��ƽ(false)
			if player:CppGetPKState() == true then
				
				if pkStateFlag == true then
					local pkRuleKeys = PkRuleInfo_Common:GetKeys()
					for i, pkRuleAreaTemp in pairs(pkRuleKeys) do
						if pkRuleAreaTemp == self.m_AreaName then
							local pkRuleTemp = PkRuleInfo_Common(pkRuleAreaTemp)
							local tempKeys = pkRuleTemp:GetKeys()
							for _, temp in pairs(tempKeys) do
								if temp == SceneName then
									local PlayerMinLevel = pkRuleTemp(temp, "MinLevel")
									local PlayerMaxLevel = pkRuleTemp(temp, "MaxLevel")
									if playerLevel >= PlayerMinLevel and playerLevel <= PlayerMaxLevel then
										MsgToConn(player.m_Conn, 193034) --��Ϊս��״̬
									end
								end
							end
						end
					end
				else
				
					if player.m_ChangerTick then
						return 
					else
						MsgToConn(player.m_Conn, 193033) -- 10����Ϊ��ƽ
					end
				end

				local function KeepPkStateTick(Tick,player)
					if not IsCppBound(player) then
						if player.m_ChangerTick then
							UnRegisterTick(player.m_ChangerTick)
							player.m_ChangerTick = nil
						end
						return 
					end
					if player:CppGetCtrlState(EFighterCtrlState.eFCS_InBattle) then
						player.m_InBattle = true
						if player.m_ChangerTick then
							UnRegisterTick(player.m_ChangerTick)
							player.m_ChangerTick = nil
						end
						return
					end
					local Pos = CPos:new()
				
					player:GetGridPos(Pos)
					local SceneName = player.m_Scene.m_SceneName
					local areaName = g_AreaMgr:GetSceneAreaName(SceneName, Pos)
			
					local tbl = GetAreaDate(player.m_Scene, areaName)
					if not tbl then
						return 
					end
					local pkState = tbl.m_AreaState
					if IsCppBound(player) then
						local pkRuleKeys = PkRuleInfo_Common:GetKeys()
						for i, pkRuleAreaTemp in pairs(pkRuleKeys) do
							if pkRuleAreaTemp == areaName then
								local pkRuleTemp = PkRuleInfo_Common(pkRuleAreaTemp)
								local tempKeys = pkRuleTemp:GetKeys()
								for _, temp in pairs(tempKeys) do
									PlayerMinLevel = pkRuleTemp(temp, "MinLevel")
									PlayerMaxLevel = pkRuleTemp(temp, "MaxLevel")
									if playerLevel >= PlayerMinLevel and playerLevel <= PlayerMaxLevel then
										player:CppSetPKState(pkState)
										Gas2Gac:TransferSwitchState(player.m_Conn,player.m_SwitchState)
										Gas2Gac:UpdatePkSwitchState(player.m_Conn)
										Gas2Gac:UpdateHeadInfoByEntityID(player:GetIS(0), player:GetEntityID())
										UnRegisterTick(player.m_ChangerTick)
										player.m_ChangerTick = nil	
										return 
									end
								
									player:CppSetPKState(false)
									Gas2Gac:TransferSwitchState(player.m_Conn,player.m_SwitchState)
									Gas2Gac:UpdatePkSwitchState(player.m_Conn)
									Gas2Gac:UpdateHeadInfoByEntityID(player:GetIS(0), player:GetEntityID())
									UnRegisterTick(player.m_ChangerTick)
									player.m_ChangerTick = nil	
									return
								end
							end
							player:CppSetPKState(false)
							Gas2Gac:TransferSwitchState(player.m_Conn,player.m_SwitchState)
							Gas2Gac:UpdatePkSwitchState(player.m_Conn)
							Gas2Gac:UpdateHeadInfoByEntityID(player:GetIS(0), player:GetEntityID())
							UnRegisterTick(player.m_ChangerTick)
							player.m_ChangerTick = nil	
							return 
						end
					end
				end
				if player.m_ChangerTick then
					UnRegisterTick(player.m_ChangerTick)
					player.m_ChangerTick = nil
				end
				player.m_ChangerTick = RegisterTick("PlayerPkStateTick", KeepPkStateTick, 30000, player)
			else
				if player.m_ChangerTick then
					UnRegisterTick(player.m_ChangerTick)
					player.m_ChangerTick = nil
				end
				local pkRuleKeys = PkRuleInfo_Common:GetKeys()
				for i, pkRuleAreaTemp in pairs(pkRuleKeys) do
					if pkRuleAreaTemp == areaName then
						local pkRuleTemp = PkRuleInfo_Common(pkRuleAreaTemp)
						local tempKeys = pkRuleTemp:GetKeys()
						for _, temp in pairs(tempKeys) do
							local pkState = scene.m_AreaInfoTbl[areaName].m_AreaState
							PlayerMinLevel = pkRuleTemp(temp, "MinLevel")
							PlayerMaxLevel = pkRuleTemp(temp, "MaxLevel")
							if playerLevel >= PlayerMinLevel and playerLevel <= PlayerMaxLevel then
								MsgToConn(player.m_Conn, 193034)
								player:CppSetPKState(pkState)
								Gas2Gac:TransferSwitchState(player.m_Conn,player.m_SwitchState)
								Gas2Gac:UpdatePkSwitchState(player.m_Conn)
								Gas2Gac:UpdateHeadInfoByEntityID(player:GetIS(0), player:GetEntityID())
							end
						end
					end
				end
			end
			return
		end
		if player:CppGetPKState() == pkStateFlag then
			if player.m_ChangerTick then
				UnRegisterTick(player.m_ChangerTick)
				player.m_ChangerTick = nil
			end
			if pkStateFlag == true then
				if TempAreaTbl[areaName] then
					if string.find(areaName, "ǰ��") and player:CppGetLevel() <= 40 then
						player:CppSetPKState(false)
						Gas2Gac:TransferSwitchState(player.m_Conn,player.m_SwitchState)
						Gas2Gac:UpdatePkSwitchState(player.m_Conn)
						Gas2Gac:UpdateHeadInfoByEntityID(player:GetIS(0), player:GetEntityID())
						return
					end
					player:CppSetPKState(true)
					Gas2Gac:TransferSwitchState(player.m_Conn,player.m_SwitchState)
					Gas2Gac:UpdatePkSwitchState(player.m_Conn)
					Gas2Gac:UpdateHeadInfoByEntityID(player:GetIS(0), player:GetEntityID())
					return
				end
				if PeaceAreaTbl[areaName] then
					player:CppSetPKState(false)
					Gas2Gac:TransferSwitchState(player.m_Conn,player.m_SwitchState)
					Gas2Gac:UpdatePkSwitchState(player.m_Conn)
					Gas2Gac:UpdateHeadInfoByEntityID(player:GetIS(0), player:GetEntityID())
					return
				end
				local pkRuleKeys = PkRuleInfo_Common:GetKeys()
				for i, pkRuleAreaTemp in pairs(pkRuleKeys) do
					if pkRuleAreaTemp == areaName then
						local pkRuleTemp = PkRuleInfo_Common(pkRuleAreaTemp)
						local tempKeys = pkRuleTemp:GetKeys()
						for _, temp in pairs(tempKeys) do
							local pkState = scene.m_AreaInfoTbl[areaName].m_AreaState
							local PlayerMinLevel = pkRuleTemp(temp, "MinLevel")
							local PlayerMaxLevel = pkRuleTemp(temp, "MaxLevel")
							if playerLevel >= PlayerMinLevel and playerLevel <= PlayerMaxLevel then
								MsgToConn(player.m_Conn, 193034)
							else
								player:CppSetPKState(false)
								Gas2Gac:TransferSwitchState(player.m_Conn,player.m_SwitchState)
								Gas2Gac:UpdatePkSwitchState(player.m_Conn)
								Gas2Gac:UpdateHeadInfoByEntityID(player:GetIS(0), player:GetEntityID())
							end
						end
					end
				end
			end
			return 
		end
	end
end


function OnPlayerChangeInArea(player, areaName, isStepCheck)
	if player.m_InBattle then
		player.m_InBattle = false
	end
	local scene = player.m_Scene
	player.m_AreaName = areaName
	local sceneType = scene.m_SceneAttr.SceneType
	local sceneType = scene.m_SceneAttr.SceneType
	if not isStepCheck and g_PublicAreaSceneMgr:OnPlayerChangeArea(player, areaName) then
		return --������������, ������д�������߼���Ӱ��
	end
	
	if sceneType == 1 then --ֻ������������������Աͳ��
		local areaTbl = GetAreaDate(scene, areaName)
		if not areaTbl then
			areaTbl = {}
			areaTbl.m_PlayerTbl = {}
			areaTbl.m_PlayerNum  = 0
			areaTbl.m_AreaState  = false
			scene.m_AreaInfoTbl[areaName] = areaTbl
			
		end
		if areaTbl.m_PlayerTbl then
			if not areaTbl.m_PlayerTbl[player.m_uID] then
				areaTbl.m_PlayerTbl[player.m_uID] = player
				if not areaTbl.m_PlayerNum then
					areaTbl.m_PlayerNum = 0
				end
				areaTbl.m_PlayerNum = areaTbl.m_PlayerNum + 1
			end
		end
		if TempAreaTbl[areaName] == true then
			MsgToConn(player.m_Conn, 193034)
			player:CppSetPKState(true)
			Gas2Gac:TransferSwitchState(player.m_Conn,player.m_SwitchState)
			Gas2Gac:UpdatePkSwitchState(player.m_Conn)
			Gas2Gac:UpdateHeadInfoByEntityID(player:GetIS(0), player:GetEntityID())
			scene.m_AreaInfoTbl[areaName].m_AreaState = true
		elseif PeaceAreaTbl[areaName] == true then
			MsgToConn(player.m_Conn, 193033)
			player:CppSetPKState(false)
			Gas2Gac:TransferSwitchState(player.m_Conn,player.m_SwitchState)
			Gas2Gac:UpdatePkSwitchState(player.m_Conn)
			Gas2Gac:UpdateHeadInfoByEntityID(player:GetIS(0), player:GetEntityID())
			scene.m_AreaInfoTbl[areaName].m_AreaState = false
		
		elseif player.m_Scene.m_SceneAttr.SceneType == 7 then
			return 
		end
		PlayerPkChange(player, scene, areaName)
	end
	--�����߼�������д

end

function OnPlayerChangeOutArea(player, areaName)
	if player.m_InBattle then
		player.m_InBattle = false
	end
	local scene = player.m_Scene
	local sceneType = scene.m_SceneAttr.SceneType
	if sceneType == 1 then --ֻ������������������Աͳ��
		local areaTbl = GetAreaDate(scene, areaName)
		if areaTbl and areaTbl.m_PlayerTbl[player.m_uID] then
			areaTbl.m_PlayerTbl[player.m_uID] = nil
			assert(areaTbl.m_PlayerNum > 0)
			areaTbl.m_PlayerNum = areaTbl.m_PlayerNum -1
		end
	end
	
	--�����߼�������д
end


function Gac2Gas:GetBornNpcOnMiddleMap(Conn)
	local Player = Conn.m_Player
	if not IsCppBound(Player) then
		return
	end
	local Scene = Player.m_Scene
	if Scene.NpcOnMiddleMap then
		for NpcID, PosTbl in pairs(Scene.NpcOnMiddleMap) do
			for _, tbl in ipairs(PosTbl) do
				local NpcName = tbl[1]
				local PosX = tbl[2]
				local PosY = tbl[3]
				--print("Gas2Gac:BornNpcOnMiddleMap(Conn, Scene.m_SceneName, NpcName, PosX, PosY)")
				Gas2Gac:BornNpcOnMiddleMap(Conn, Scene.m_SceneName, NpcName, PosX, PosY)
			end
		end
	end
end

function Gac2Gas:GetFbBossOnMiddleMap(Conn)
	local Player = Conn.m_Player
	if not IsCppBound(Player) then
		return
	end
	local Scene = Player.m_Scene
	local SceneName = Scene.m_SceneName
	if not AreaFb_Common(SceneName) then
		return
	end
	local bossTbl = GetCfgTransformValue(false, "AreaFb_Common", SceneName, "BossName") 
	local len = table.getn(bossTbl)
	if len <= 0 then
		return 
	end
	for _, bossName in pairs(bossTbl) do
		local npc = GetOnlyNpc(Scene.m_SceneId, bossName)
		local Pos = CPos:new()
		if npc and npc:CppIsLive() then
			npc:GetGridPos(Pos)
			PosX = Pos.x
			PosY = Pos.y
			Gas2Gac:BornNpcOnMiddleMap(Conn, Scene.m_SceneName, bossName, PosX, PosY)
		else
			Gas2Gac:DeadNpcOnMiddleMap(Conn, Scene.m_SceneName, bossName)
		end
	end
end

function Gas2GasDef:RetSendWarZoneState(Conn, charId, sceneId)
	local Scene = g_SceneMgr:GetScene(sceneId)
	if Scene then
		local SceneName = Scene.m_SceneName
		local WarZone = Scene.m_WarZone
		local StationOwnerCamp = WarZone.m_StationOwnerCamp
		local StationOwnerTongName = WarZone.m_StationOwnerTongName
		for StationId, CampId in pairs(StationOwnerCamp) do
			local TongName = StationOwnerTongName[StationId]
			Gas2GacById:RetShowWarZoneState(charId, StationId, CampId, TongName)
		end
		Gas2GacById:EndSendWarZoneState(charId)
	end
end

function Gac2Gas:GetWarZoneState(Conn, SceneName)
	if not (IsCppBound(Conn) and IsCppBound(Conn.m_Player)) then
		return
	end
	local function CallBack(res)
		if not res then
			LogErr("���ս���е�ͼפ��ռ����Ϣʱ��tbl_scene��ս����"..SceneName.."��Ϣ")
		else
			if #res == 1 then
				local warZoneInfo = res[1]
				local sceneId = warZoneInfo[1]
				local serverId = warZoneInfo[2]
				--�ɿ���鿴ս����Ϣ
				Gas2GasAutoCall:RetSendWarZoneState(GetServerAutoConn(serverId), Conn.m_Player.m_uID, sceneId)
			else
				LogErr("���ս���е�ͼפ��ռ����Ϣʱ��tbl_sceneս����"..SceneName.."��Ϣ�ظ�����"..#res.."��")
			end
		end
	end
	local data = {}
	data["SceneName"] = SceneName
	CallAccountAutoTrans(Conn.m_Account, "SceneMgrDB", "GetSceneInfoByName", CallBack, data)
end

function DbCallBack:OnReleaseTeamCancelAreaFb(TeamID)
	local tblMembers = g_TeamMgr:GetMembers(TeamID)
	for i = 1, #(tblMembers) do
		local MemberId = tblMembers[i]
		-- ȡ������
		Gas2GacById:RetDelAllAreaFb(MemberId)
	end
end

function DbCallBack:OnLeaveTeamCancelAreaFb(TeamID, MemberId)
	-- ȡ������
	Gas2GacById:RetDelAllAreaFb(MemberId)
end
