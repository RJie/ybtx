gas_require "world/scene_mgr/SceneType/OreAreaSceneInc"
--�������� ��

--�ж��Ƿ��������ø���������
function COreAreaScene:JoinScene(Player)
	--�Ƿ������������
	
	return nil
end

function COreAreaScene:OnCreate()
	CreateOreAreaNpc(self)
end

function COreAreaScene:OnPlayerChangeIn(Player)
	CScenePkMgr.ChangePkState(Player)
end

function COreAreaScene:OnPlayerLogIn(Player)
	CScenePkMgr.ChangePkState(Player)
end
