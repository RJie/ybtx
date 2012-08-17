gas_require "world/scene_mgr/SceneType/WarZoneSceneInc"
cfg_load "npc/Npc_Common"


function CWarZoneScene:JoinScene(Player, SceneName)
	--�Ƿ������������
	if not CSceneBase.IfJoinScene(self, Player) then
		return
	end
end


function CWarZoneScene:LeaveScene(Scene)
end

function CWarZoneScene:OnCreate()
	local warZoneId = self.m_Process    --����ս������ Process ������� ս�����
	assert(IsNumber(warZoneId))
	g_WarZoneMgr:AddWarZoneScene(warZoneId, self)
end

function CWarZoneScene:OnPlayerChangeOut(Player)
	LeaveWarZoneScene(Player, self.m_SceneId)
end

function CWarZoneScene:OnPlayerChangeIn(Player)
	IntoWarZoneScene(Player)
	Player:CppSetPKState(true)
	Gas2Gac:UpdatePkSwitchState(Player.m_Conn)
	Gas2Gac:UpdateHeadInfoByEntityID(Player:GetIS(0), Player:GetEntityID())
	MsgToConn(Player.m_Conn, 193034)
end

function CWarZoneScene:OnPlayerLogIn(Player)
	PlayerLoginWarZone(Player)
	Player:CppSetPKState(true)
	Gas2Gac:UpdatePkSwitchState(Player.m_Conn)
	Gas2Gac:UpdateHeadInfoByEntityID(Player:GetIS(0), Player:GetEntityID())
	MsgToConn(Player.m_Conn, 193034)
end

function CWarZoneScene:OnPlayerLogOut(Player)
	PlayerOffLineWarZone(Player)
end



function Gac2Gas:EnterWarZone(Conn, NpcId, sceneName)
	local Player = Conn.m_Player
	if not CheckAllNpcFunc(Player, NpcId, "ս������") then
		return
	end
	
	if not Player then
		return
	end
	
	local function CallBack(Flag, MsgId)
		if Flag then
			if IsServerObjValid(Player) then
				local pos = g_WarZoneMgr:GetEnterPos(Player:CppGetCamp())
				ChangeSceneByName(Conn, sceneName, pos[1] , pos[2])
			end
		else
			MsgToConn(Conn, MsgId)
			return
		end
	end
	
	local data = {}
	data["uPlayerID"] = Player.m_uID
	CallDbTrans("GasTongBasicDB", "CanEnterWarZone", CallBack, data, Player.m_uID)
end


