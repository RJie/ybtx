--�������ĸ�������,
--����Ժ󸱱��б���ʱ��, ֻ���һ�� ������ߵĴ��� OnPlayerLogon

local function OnLeaveFbSceneTick(player)
	if IsCppBound(player ) 
		and player.m_LeaveFbScene
		and player.m_Scene.m_SceneId == player.m_LeaveFbScene["oldSceneId"] then -- ���ͨ��������ʽ�뿪�˸���,���贫����,
		local sceneName = player.m_MasterSceneName
		local pos = player.m_MasterScenePos
		ChangeSceneByName(player.m_Conn, sceneName, pos.x, pos.y)
	end
	player.m_LeaveFbScene = nil
end

--ע��:�벻Ҫ�������κ�λ�ö� scene �� m_OwnerTeamId ���Խ����޸�, 
--     ֻ����TeamSceneMgr:AddScene �и�ֵ ����TeamSceneMgr:RemoveScene ��ɾ��
--     (OnReleaseTeam�Ƚ�����,Ϊ��Ч��û�ж�ÿ��scene����RemoveScene ����ֱ�ӽ�m_OwnerTeamIdɾ��)
function Gac2Gas:AgreedChangeOut(Conn)
	if Conn and Conn.m_Player and Conn.m_Player.m_LeaveFbScene then
		OnLeaveFbSceneTick (Conn.m_Player)
	end
end

--ǿ������뿪����,������֮ǰ��������(�����Ժ���).
--������ time Ϊ nil ���� 0 ʱ�� ������ͷ��˷�ȷ����Ϣ
--�� msg Ϊ nil �����ͷ��˷� Gas2Gac:RetIsChangeOut ��Ϣ
function NotifyPlayerLeaveFbScene(playerId, time, msgID)
	local  player = g_GetPlayerInfo(playerId)
	if player == nil
		or not IsCppBound(player.m_Conn)
		or player.m_Scene.m_SceneAttr.SceneType == 1 then
		return
	end
	local sceneName = player.m_MasterSceneName
	local pos = player.m_MasterScenePos
	
	if time and time > 0 then
		if player.m_LeaveFbScene  then
			return
		end
		player.m_LeaveFbScene = {}
		player.m_LeaveFbScene["oldSceneId"] = player.m_Scene.m_SceneId
		RegisterOnceTick(player,"LeaveFbSceneTick", OnLeaveFbSceneTick, time * 1000, player)
		if msgID then
			Gas2Gac:RetIsChangeOut(player.m_Conn ,time, msgID)
		end
	else
		ChangeSceneByName(player.m_Conn, sceneName, pos.x, pos.y)
	end
end

--���,���˳���������Ϣ
function Gas2GasDef:NotifyPlayerLeaveFbScene(ServerConn, playerId, time, msgID)
	NotifyPlayerLeaveFbScene(playerId, time, msgID)
end
