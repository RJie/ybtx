gas_require "world/scene_mgr/SceneType/SceneInc"

--��ͨ���� ��

function CScene:Init(uSceneId, sSceneName, CoreScene)
	CSceneBase.Init(self, uSceneId, sSceneName, CoreScene)
	self.m_AreaInfoTbl = {}
end



--�ж��Ƿ��������ø���������(����ֻ�ǻ�������)
function CScene:JoinScene(Player, SceneName)
	--�Ƿ������������
	if not CSceneBase.IfJoinScene(self, Player) then
		return 
	end
	local sceneId, serverId = g_SceneMgr:GetSceneByName(SceneName)
	assert(sceneId, " ������: " .. SceneName .. " δ�� g_SceneMgr.m_tbl_MainScene_name ���д���")

	return sceneId, serverId
end
