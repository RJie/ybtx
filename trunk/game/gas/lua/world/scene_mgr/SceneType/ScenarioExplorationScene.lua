CSenarioExplorationScene = class(CSceneBase)

--�ж��Ƿ��������ø��������� ����������,����ĸ�����
function CSenarioExplorationScene:JoinScene(Player, SceneName)
	--�Ƿ������������
	if not CSceneBase.IfJoinScene(self, Player) then
		return nil
	end
	return true  --����֮ǰ�ṹ������������,������AreaFbChangeScene �м����жϸý��ĸ�����
end

function CSenarioExplorationScene:IsCanDestroy()
	if self:IsHavePlayer() then
		return false
	end
	if self.m_State ~= g_FbRoomState.GameEnd then
		return false
	end
	return true
end

function CSenarioExplorationScene:OnDestroy()
	if self.m_matchTeam and self.m_matchTeam.m_TempTeamId then
		g_TemporaryTeamMgr:BreakTeam(self.m_matchTeam.m_TempTeamId)
	end
	SavePlayerWarnValue(self.m_SceneId)
	CScenarioExploration.Destroy(self)
end

function CSenarioExplorationScene:OnPlayerChangeIn(Player)
	Player:BeginStatistic("")
	CScenarioExploration.IntoScene(Player)
	CScenePkMgr.ChangePkState(Player)
	
	--���ս��ͳ�Ƶ��˲��Ҵ򿪴���
	--CFbDpsServer.OpenFbDpsInfoWnd(Player, "1��")
end

function CSenarioExplorationScene:OnPlayerChangeOut(Player)
	SavePlayerWarnValue(self.m_SceneId, Player.m_uID)
	CScenarioExploration.LeaveScene(Player, true)
	CScenePkMgr.ChangePkState(Player)
	
	--�ر�ս��ͳ�ƴ���
	--CFbDpsServer.CloseFbDpsInfoWnd(Player)
end


function CSenarioExplorationScene:OnPlayerLogIn(Player)
	Player:BeginStatistic("")
	CScenarioExploration.LogIn(Player)
	
	--���ս��ͳ�Ƶ��˲��Ҵ򿪴���
	--CFbDpsServer.OpenFbDpsInfoWnd(Player, "1��")
end

function CSenarioExplorationScene:OnPlayerLogOut(Player)
	CScenarioExploration.LeaveScene(Player)
	
	--�ر�ս��ͳ�ƴ���
	--CFbDpsServer.CloseFbDpsInfoWnd(Player)
end
