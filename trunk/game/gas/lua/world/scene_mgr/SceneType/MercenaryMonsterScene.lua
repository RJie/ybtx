gas_require "world/scene_mgr/SceneType/MercenaryMonsterSceneInc"
gac_gas_require "team/TeamMgr"
--Ӷ����ˢ�ֱ� ��



--�ж��Ƿ��������ø��������� ����������,����ĸ�����
function CMercenaryMonsterScene:JoinScene(Player, SceneName)
	--�Ƿ������������
	if not CSceneBase.IfJoinScene(self, Player) then
		return nil
	end
	return true  --����֮ǰ�ṹ������������,������AreaFbChangeScene �м����жϸý��ĸ�����
end


function CMercenaryMonsterScene:OnPlayerChangeOut(Player)
	LeaveMercenaryMonsterFbScene(Player, self.m_SceneId)
end

function CMercenaryMonsterScene:OnPlayerChangeIn(Player)
	IntoMercenaryMonsterFbScene(Player)
	CScenePkMgr.ChangePkState(Player)
	--AddMercenaryLevelCount(Player.m_Conn, "Ӷ������", Player.m_Scene.m_SceneName)
end
