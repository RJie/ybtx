gas_require "world/scene_mgr/SceneType/AreaSceneInc"
gac_gas_require "team/TeamMgr"
--gas_require "fb_game/AreaFbServer"
--���򸱱� ��



--�ж��Ƿ��������ø��������� ����������,����ĸ�����
function CAreaScene:JoinScene(Player, SceneName)
	--�Ƿ������������
	if not CSceneBase.IfJoinScene(self, Player) then
		return nil
	end
	return true  --����֮ǰ�ṹ������������,������AreaFbChangeScene �м����жϸý��ĸ�����
end

function CAreaScene:OnPlayerChangeIn(Player)
	CAreaFbServer.IntoAreaFbScene(Player)
	CScenePkMgr.ChangePkState(Player)
	
	--���ս��ͳ�Ƶ��˲��Ҵ򿪴���
	--CFbDpsServer.OpenFbDpsInfoWnd(Player, "1��")
	--AddMercenaryLevelCount(Player.m_Conn, "Ӷ������", Player.m_Scene.m_SceneName)
end

function CAreaScene:OnPlayerLogIn(Player)
	CAreaFbServer.LoginAreaFbScene(Player)
	CScenePkMgr.ChangePkState(Player)
	
	--���ս��ͳ�Ƶ��˲��Ҵ򿪴���
	--CFbDpsServer.OpenFbDpsInfoWnd(Player, "1��")
end

function CAreaScene:OnPlayerChangeOut(Player)
	--�ر�ս��ͳ�ƴ���
	--CFbDpsServer.CloseFbDpsInfoWnd(Player)
end
function CAreaScene:OnPlayerLogOut(Player)
	--�ر�ս��ͳ�ƴ���
	--CFbDpsServer.CloseFbDpsInfoWnd(Player)
end
