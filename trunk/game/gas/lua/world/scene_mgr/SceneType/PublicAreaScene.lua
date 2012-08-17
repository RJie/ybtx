gas_require "world/scene_mgr/SceneType/PublicAreaSceneInc"
gas_require "fb_game/PublicArea/PublicAreaSceneMgr"
--������ͼ����


--�ж��Ƿ��������ø���������
function CPublicAreaScene:JoinScene(Player, SceneName)
	local scene = g_PublicAreaSceneMgr:GetCanEnterScene(Player, SceneName)
	if scene then
		return scene.m_SceneId
	end
	return SceneName
end


function CPublicAreaScene:OnCreate()
	g_PublicAreaSceneMgr:AddPublicAreaScene(self)
end

function CPublicAreaScene:OnDestroy()
	OnDestroyPublicAreaScene(self)
end
