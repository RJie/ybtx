gas_require "world/scene_mgr/SceneType/ScopesExplorationSceneInc"


--�ж��Ƿ��������ø��������� ����������,����ĸ�����
function CScopesExplorationScene:JoinScene(Player, SceneName)
	--�Ƿ������������
	if not CSceneBase.IfJoinScene(self, Player) then
		return nil
	end
	return true  --����֮ǰ�ṹ������������,������AreaFbChangeScene �м����жϸý��ĸ�����
end

function CScopesExplorationScene:IsCanDestroy()
	if self:IsHavePlayer() then
		return false
	end
--	if self.m_State ~= g_FbRoomState.GameEnd then
--		return false
--	end
	return true
end

function CScopesExplorationScene:OnPlayerChangeIn(Player)
	CScopesExploration.IntoScene(Player)
	CScenePkMgr.ChangePkState(Player)
end
