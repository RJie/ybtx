gas_require "world/scene_mgr/SceneType/PVPSceneInc"
--PVP���� ��

local m_FbName = "������"

function CPVPScene:IsCanDestroy()
	if self:IsHavePlayer() then
		return false
	end
	if self.m_JfsInfo.m_State ~= g_FbRoomState.BeginGame
		and self.m_JfsInfo.m_State ~= g_FbRoomState.GameEnd then
		return false
	end
	return true
end

function CPVPScene:GetDestroyChannel()
	return self.m_SceneId, m_FbName
end


function CPVPScene:OnDestroy()
	OnDestroyJiFenSaiScene(self)
end

function CPVPScene:OnPlayerChangeOut(Player)
	LeaveJFSScene(Player, self.m_SceneId)
end

function CPVPScene:OnPlayerDeadInScene(Attacker, BeAttacker)
	DeadUpdateJiFenSaiInfo(Attacker, BeAttacker)
end


function CPVPScene:OnPlayerChangeIn(Player)
	IntoJFSScene(Player)
	CScenePkMgr.ChangePkState(Player)
	AddVarNumForTeamQuest(Player, "��ɾ�����", 1)
	--AddMercenaryLevelCount(Player.m_Conn, "Ӷ������", Player.m_Scene.m_SceneName)
end

function CPVPScene:OnPlayerLogOut(Player)
	PlayerOffLineJiFenSaiFb(Player)
end
