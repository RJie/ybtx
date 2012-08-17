gac_gas_require "scene_mgr/SceneCfg"
cfg_load "fb_game/FbActionDirect_Common"
gac_gas_require "framework/common/CAlarmClock"
gac_gas_require "activity/scene/AreaFbSceneMgr"

CAreaFbServer = class()


--function CAreaFbServer:ShowAreaFbSelWnd(Conn, NpcID)
function CAreaFbServer.ShowAreaFbSelWnd(Conn, NpcID)
	if not (IsCppBound(Conn) and Conn.m_Player) then
		return
	end
	if not CheckAllNpcFunc(Conn.m_Player, NpcID, "���³Ǵ��ʹ�" ) then
		return
	end
	
--	if not CheckActionIsBeginFunc("���³�̽��") then
--		MsgToConn(Conn,3520)--���û�п���,�����Ա���
--		return
--	end
--	
--	if SearchClosedActionTbl("���³�̽��") then
--		MsgToConn(Conn,3521)--��Ѿ��ر�,�����Ա���
--		return
--	end
	
	Gas2Gac:RetShowAreaFbSelWnd(Conn, NpcID)
end

--ʱ�䵽��,������뿪����,��ɾ������
local function LeaveAreaFbSceneTick(Scene)
	Scene.m_State = g_FbRoomState.GameEnd
	if Scene.m_tbl_Player and next(Scene.m_tbl_Player) then
		return
	else
		Scene:Destroy()
	end
end


--function CAreaFbServer:CheckAreaFbState(Conn, PlayerID, ServerId, SceneId, SceneName)
function CAreaFbServer.CheckAreaFbState(Conn, PlayerID, ServerId, SceneId, SceneName)
	-- �жϸø����Ƿ��Ѿ��н��ȡ��н��ȵĻ���ʾ����������Ƿ���롣
	local Scene = g_SceneMgr:GetScene(SceneId)
	-- �������ڣ�playerû�мӹ������������Ѿ��ӹ�����
	if Scene then
		if Scene.m_BossEnterBattleState then
			--print("���ڴ�BOSS���㲻�ܽ�ȥ!")
			MsgToConnById(PlayerID, 191043)
			return
		elseif Scene.m_AddAreaFbCount 
			and Scene.m_AddCountPlayerList 
			and not Scene.m_AddCountPlayerList[PlayerID] then
			local TotalNum = g_AreaFbSceneMgr.BossNum[Scene.m_SceneName]
			local LeftNum = TotalNum - Scene.m_KilledBossNum
			Gas2GacById:RetAreaFbBossNum(PlayerID, Scene.m_SceneName, SceneId, ServerId, LeftNum, TotalNum)
			--print("�õ��³����ڽ����У�����ʣ������Ϊ "..Scene.m_KilledBossNum.."/"..g_AreaFbSceneMgr.BossNum[SceneName].."�����������һ�ε��³ǻ��ᡣ")
			return
		end
	
		--���ط�һ����Ϣ,˵������������,���Խ�����
		Gas2GasAutoCall:RetAreaFbState(Conn, PlayerID, SceneName, SceneId, ServerId, false)
		return
	else
		-- �¸������ȴ����������ٸ������˵�����
		local function CallBack(IsExist, SceneName, otherArg)
			if not IsExist then
				return
			end
			local scene = g_SceneMgr:GetScene(SceneId)
			if not scene then
				local scene = g_SceneMgr:CreateScene(SceneName, SceneId, otherArg)
				if scene then
					local SceneCommon = Scene_Common[SceneName]
					local lifetime = SceneCommon.LifeCycle
					local TickTime = 1*60--��ʱ��ľ���������1��
					if lifetime > 0 then
						TickTime = lifetime * 60
					end
					scene.m_State = g_FbRoomState.PlayerCanIn
					RegisterOnceTick(scene, "DestroySceneTick", LeaveAreaFbSceneTick, TickTime * 1000, scene)
				else
					return
				end
			end
			--���ط�һ����Ϣ,˵������������,���Խ�����
			Gas2GasAutoCall:RetAreaFbState(Conn, PlayerID, SceneName, SceneId, ServerId, true)
		end
		
		local data = {}
		data["sceneId"] = SceneId
		data["serverId"] = g_CurServerId
		CallDbTrans("SceneMgrDB", "IsSceneExistent", CallBack, data, SceneId, SceneName)
	end
end

function CAreaFbServer.SendResistanceValueToGac(Conn, SceneName, TeamID, PlayerID)
	CCharacterMediator.SendResistanceValueToGac(SceneName, TeamID, PlayerID)
end

function CAreaFbServer.RetAreaFbState(Conn, PlayerID, SceneName, SceneId, ServerId, IsShowInfoWnd)	
	local Player = g_GetPlayerInfo(PlayerID)
	if not IsCppBound(Player) then
		return
	end
	
	if IsShowInfoWnd then
		
		local function CallBack(res)
			local InviteTbl = res.inviteTbl
			local PlayerInfo = res["PlayerInfo"]
			local inviteServerTbl = res.inviteServerTbl
			local TeamID = Player.m_Properties:GetTeamID()
			
			if not next(InviteTbl) then
				return
			end
			
			CCharacterMediator.SendPlayerInfoToGac(PlayerInfo.Res)

			for _, TeamMateID in pairs(InviteTbl) do
				local FbDifficulty = 1
				Gas2GacById:RetIsJoinAreaFb(TeamMateID, SceneName, FbDifficulty, g_AreaFbLev[SceneName], SceneId, ServerId)
			end
			
			-- �������Ϣ
			if TeamID == 0 then
				CAreaFbServer.SendResistanceValueToGac(Conn, SceneName, TeamID, PlayerID)
			else
				for ServerID, _ in pairs(inviteServerTbl) do
					Gas2GasAutoCall:SendResistanceValueToGac(GetServerAutoConn(ServerID), SceneName, TeamID, PlayerID)
				end
			end
		end
		
		local TeamID = Player.m_Properties:GetTeamID()
		
		local data = {}
		data.SceneID = SceneId
		data.TeamID = TeamID
		data.charId = PlayerID
		CallAccountManualTrans(Player.m_Conn.m_Account, "SceneMgrDB", "GetAreaFbCharInfo", CallBack, data, TeamID)
	else
		local x  = Scene_Common[SceneName].InitPosX
		local y = Scene_Common[SceneName].InitPosY
		local function Invite_CallBack(isSucceed)
			if not IsCppBound(Player) then
				return
			end
			if isSucceed then
				MultiServerChangeScene(Player.m_Conn, SceneId, ServerId, x, y)
			else
				MsgToConn(Player.m_Conn, 190017)
			end
		end
		local data = {}
		data["teamId"] = Player.m_Properties:GetTeamID()
		data["SceneName"] = SceneName
		data["Proc"] = 0
		CallAccountManualTrans(Player.m_Conn.m_Account, "TeamSceneMgrDB", "GetScene", Invite_CallBack, data)
	end
end


-- function CAreaFbServer:ChangeToAreaFb(Conn, SceneName)
function CAreaFbServer.ChangeToAreaFb(Conn, SceneName)
-- �õ���ҵȼ�
	local player = Conn.m_Player
	local PlayerLev = player:CppGetLevel()
	-- �ж���ҵȼ��Ƿ���ڸ���Ҫ��ĵȼ�
	if PlayerLev < g_AreaFbLev[SceneName] then
		MsgToConn(Conn,190012,SceneName,g_AreaFbLev[SceneName])
		return
	end
	
	local teamId = player.m_Properties:GetTeamID()
	
	local data = {}
	data["charId"] = player.m_uID
	data["teamId"] = teamId
	data["SceneName"] = SceneName
	
	local function CallBack(isSucceed, errMsg, res)
		if not (IsCppBound(Conn) and IsCppBound(player)) then
			return
		end
		
		if isSucceed then
			local sceneId = res.sceneId
			local serverId = res.serverId
			-- ��⵱ǰ������״̬
			Gas2GasAutoCall:CheckAreaFbState(GetServerAutoConn(serverId), player.m_uID, serverId, sceneId, SceneName)
		else
			if errMsg and errMsg[1] then
				if errMsg[1] == 1 then -- ��ʾΪ ���³�̽�� ���ƴ�������
					local msgId = 191019
					local ActionName = AreaFb_Common(SceneName, "ActionName")
					local limitType = FbActionDirect_Common(ActionName, "MaxTimes")
					if JoinCountLimit_Server(limitType, "Cycle") == "week" then
						msgId = 191020																							
					end										
					local ActionName = AreaFb_Common(SceneName, "ActionName")																								
					MsgToConn(player.m_Conn, msgId, "", ActionName)
					return
				elseif errMsg[1] == 2 then -- ��ʾΪ ��ǰ�������� ���ƴ�������
					local msgId = 191038
					if JoinCountLimit_Server(SceneName, "Cycle") == "week" then
						msgId = 191039																							
					end																																				
					MsgToConn(player.m_Conn, msgId, "", SceneName)
					return	
				elseif errMsg[1] == 3 then
					local msgId = 191040
					local hour = 24 * g_AreaFbSceneMgr.ResetMode[SceneName][2]
					MsgToConn(player.m_Conn, msgId, hour, SceneName)
				elseif errMsg[1] == 4 then
					--print("ֻ�жӳ����Ա���!")
					local msgId = 191047
					MsgToConn(player.m_Conn, msgId)
				elseif errMsg[1] == 5 then
					if errMsg[2] then
						local MemberID = errMsg[2]
						local pMember = g_GetPlayerInfo(MemberID)
						local MemberName = ""
						if IsCppBound(pMember) then
							MemberName = pMember.m_Properties:GetCharName()
						end
						--print("��Ա"..MemberName.."�ĵȼ�������С�ӱ���ʧ�ܡ�")
						local msgId = 191045
						MsgToConn(player.m_Conn, msgId, MemberName)
					end
				elseif errMsg[1] == 6 then
					local MemberID = errMsg[2]
					local pMember = g_GetPlayerInfo(MemberID)
					local MemberName = ""
					if IsCppBound(pMember) then
						MemberName = pMember.m_Properties:GetCharName()
					end
					--print("��Ա "..MemberName.." �Ѿ�������"..SceneName.."�Ľ����޴Σ�С�ӱ���ʧ�ܡ�")
					local msgId = 191046
					MsgToConn(player.m_Conn, msgId, MemberName, SceneName)
				end
			end
		end
	end
	
	CallAccountManualTrans(Conn.m_Account, "SceneMgrDB", "GetAreaFbScene", CallBack, data, teamId)
end


--function CAreaFbServer:EnterGeneralAreaFb(Conn, NpcID, SceneName)
function CAreaFbServer.EnterGeneralAreaFb(Conn, NpcID, SceneName)
	local player = Conn.m_Player
	if not (IsCppBound(Conn) and IsCppBound(player)) then
		return
	end
	if not CheckAllNpcFunc(player, NpcID, "���³Ǵ��ʹ�" ) or g_AreaFbLev[SceneName] == nil then
		return
	end

	local Truck = player:GetServantByType(ENpcType.ENpcType_Truck)
	if IsServerObjValid(Truck) then 
		MsgToConn(player.m_Conn, 190018)
		return
	end
	CAreaFbServer.ChangeToAreaFb(Conn, SceneName)
end

--function CAreaFbServer:AgreedJoinAreaFb(Conn,SceneName)
function CAreaFbServer.AgreedJoinAreaFb(Conn, SceneName, SceneID, ServerID)
	if not (IsCppBound(Conn) and Conn.m_Player) then
		return
	end

	--�ж��ǲ�����ͨ����
	--��ʹ�� IsTodayAreaFbTbl �жϵ�ԭ���ǿ��ܶӳ��ڸ���ˢ��ʱ������, ���ܶ��ѻ�Ӧ��ʱ���ո����Ա�
	if not AreaFb_Common(SceneName) then 
		return
	end
	
	local Player = Conn.m_Player
	
	local Truck = Player:GetServantByType(ENpcType.ENpcType_Truck)
	if IsServerObjValid(Truck) then 
		MsgToConn(Conn, 190018)
		return
	end
	CAreaFbServer.DecideJoinAreaFb(Conn, SceneName, SceneID, ServerID)
end

-- function CAreaFbServer:IntoAreaFbScene(player)
function CAreaFbServer.IntoAreaFbScene(player)
	local scene = player.m_Scene
		
	local parameters = {}
	parameters["PlayerId"] = player.m_uID
	parameters["SceneId"] = scene.m_SceneId
	CallDbTrans("SceneMgrDB", "EnterAreaFbScene", nil, parameters, player.m_AccountID)	

	-- �жϸ������BOSS�Ƿ��Ѿ����ɵ���
	if scene.m_AddAreaFbCount then
		-- ����
	 	CAreaFbServer.RecordAreaFbSinglePlayerCount(scene, player.m_uID)
	end
end

-- function CAreaFbServer:RecordAreaFbSinglePlayerCount(Scene, PlayerID)
function CAreaFbServer.RecordAreaFbSinglePlayerCount(Scene, PlayerID)
	-- �Ѿ��ӹ��Ͳ�����
	if Scene.m_AddCountPlayerList[PlayerID] then
		--print("�ӹ��ˣ������ټ�!!")
		return	
	end
	
	local SceneName = Scene.m_LogicSceneName
	local parameters = {}
	parameters["SceneID"] = Scene.m_SceneId

	local ResetMode = g_AreaFbSceneMgr.ResetMode[SceneName]
	if ResetMode[1] == 1 or ResetMode[1] == 2 then
		parameters["ExtraLimitType"] = SceneName
	end
	local ActionName = AreaFb_Common(SceneName, "ActionName")	
	local limitType = FbActionDirect_Common(ActionName, "MaxTimes")
	parameters["ActivityName"] = limitType
	parameters["SceneName"]	= SceneName
	parameters["PlayerId"] = PlayerID
	--print(PlayerID.."����")
	local function CallBack()
		-- ��ʾPlayerID�ӹ�����
		if not Scene.m_AddCountPlayerList then
			Scene.m_AddCountPlayerList = {}
		end
		Scene.m_AddCountPlayerList[PlayerID] = true
	end
	CallDbTrans("ActivityCountDB", "AddAreaFbCount", CallBack, parameters, PlayerID)
end

--function CAreaFbServer:LoginAreaFbScene(player)
function CAreaFbServer.LoginAreaFbScene(player)
	CAreaFbServer.IntoAreaFbScene(player)
end

-- function CAreaFbServer:DecideJoinAreaFb(Conn, SceneName, SceneId, ServerId)
function CAreaFbServer.DecideJoinAreaFb(Conn, SceneName, SceneId, ServerId)
	local x  = Scene_Common[SceneName].InitPosX
	local y = Scene_Common[SceneName].InitPosY
	MultiServerChangeScene(Conn, SceneId, ServerId, x , y)
end

-- function CAreaFbServer:InviteJoinAreaFb(Conn, SceneName, SceneId, ServerId)
function CAreaFbServer.InviteJoinAreaFb(Conn, SceneName, SceneId, ServerId)
	local Player = Conn.m_Player
	
	local Truck = Player:GetServantByType(ENpcType.ENpcType_Truck)
	if IsServerObjValid(Truck) then 
		MsgToConn(Player.m_Conn, 190018)
		return
	end
	Gas2GasAutoCall:CheckAreaFbState(GetServerAutoConn(ServerId), Player.m_uID, ServerId, SceneId, SceneName)
end

-- function CAreaFbServer:BossEnterBattleState(Scene, NpcName)
function CAreaFbServer.BossEnterBattleState(Scene, NpcName)
	local SceneName = Scene.m_SceneName
	if g_AreaFbSceneMgr.BossNames[SceneName][NpcName] then
		--print("BOSS�뿪ս��״̬�������� "..NpcName)
		Scene.m_BossEnterBattleState = true
	end	
end

-- function CAreaFbServer:BossLeaveBattleState(Scene, NpcName)
function CAreaFbServer.BossLeaveBattleState(Scene, NpcName)
	local SceneName = Scene.m_SceneName
	if g_AreaFbSceneMgr.BossNames[SceneName][NpcName] then
		--print("BOSS�뿪ս��״̬�������� "..NpcName)
		Scene.m_BossEnterBattleState = false
	end	
end

-- function CAreaFbServer:IsAreaFbBossDead(Scene, NpcName)
function CAreaFbServer.IsAreaFbBossDead(Scene, NpcName)
	local SceneName = Scene.m_LogicSceneName
	if g_AreaFbSceneMgr.BossNames[SceneName][NpcName]  then
		--print("��ɵ���BOSS"..NpcName)
		Scene.m_KilledBossNum = Scene.m_KilledBossNum + 1
		
		--�����ֵ
		local uAfflatusValue = FbAfflatus_Common(SceneName, "AfflatusValue")
		if uAfflatusValue and IsNumber(uAfflatusValue)then
			for _,Target in pairs(Scene.m_tbl_Player) do
				if IsCppBound(Target) then
					Target:AddPlayerAfflatusValue(uAfflatusValue)
				end
			end
		end
		
		-- ����Ѿ��ƹ����Ͳ��ټ���
		if Scene.m_AddAreaFbCount then
			return
		end
	
		Scene.m_AddAreaFbCount = true	-- ��ʾ�Ѿ����ǹ���
		local parameters = {}
		parameters["SceneID"] = Scene.m_SceneId
		
		local ResetMode = g_AreaFbSceneMgr.ResetMode[SceneName]
		if ResetMode[1] == 1 or ResetMode[1] == 2 then
			parameters["ExtraLimitType"] = SceneName
		end
		local ActionName = AreaFb_Common(SceneName, "ActionName")	
		local limitType = FbActionDirect_Common(ActionName, "MaxTimes")
		parameters["ActivityName"] = limitType
		parameters["SceneName"]	= SceneName
		
		
		local PlayerTbl = {}
		for PlayerID, _ in pairs(Scene.m_tbl_Player) do
			table.insert(PlayerTbl, PlayerID)
		end
		parameters["PlayerTbl"] = PlayerTbl
		
		local function CallBack()
			-- ��ʾPlayerID�ӹ�����
			if not Scene.m_AddCountPlayerList then
				Scene.m_AddCountPlayerList = {}
			end
			for _, ID in pairs(PlayerTbl) do
				Scene.m_AddCountPlayerList[ID] = true
			end
		end
			
		CallDbTrans("ActivityCountDB", "AddTeamAreaFbCount", CallBack, parameters, PlayerID)
		
	end
end

-- BOSS�������ٽ��������Ҳ��Ӽ���
-- ��Ҹ��������ߣ�
-- BOSS������ٽ��븱��
-- 
