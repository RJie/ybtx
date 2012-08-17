CFbDpsServer = class()

local SendTime = 4000	--��λ��ms
local ShowTypeNum = {
	["�˺�"] = 1,
	["����"] = 2,
	["�����˺�"] = 3,
	["����"] = 4,
}


local function SendClientInfo(Player, Target)
	local Data1 = 0
	local Data2 = 0
	local Name = Target.m_Properties:GetCharName()
	
	local hurt = 0
	local dps = 0
	local heal = 0
	local hps = 0
	local besubHurt = 0
	local dead = 0
	local PlayerFbDps = Target.m_Scene.m_PlayerFbDPS
	if PlayerFbDps and PlayerFbDps[Target.m_uID] then
		hurt = PlayerFbDps[Target.m_uID]["Hurt"]
		dps = PlayerFbDps[Target.m_uID]["Dps"]
		heal = PlayerFbDps[Target.m_uID]["Heal"]
		hps = PlayerFbDps[Target.m_uID]["Hps"]
		besubHurt = PlayerFbDps[Target.m_uID]["BesubHurt"]
		dead = PlayerFbDps[Target.m_uID]["Dead"]
	end
	
	if Player.m_DpsShowType == 2 then
		--�ܵ���������ÿ���������
		Data1 = Target:GetStatisticFightHeal(Player.m_FbDpsBossName) + heal
		Data2 = Target:GetStatisticHps(Player.m_FbDpsBossName) + hps
	elseif Player.m_DpsShowType == 3 then
		--�ܵı��˺���
		Data1 = Target:GetStatisticBeSubHurt(Player.m_FbDpsBossName) + besubHurt
	elseif Player.m_DpsShowType == 4 then
		--��������
		Data1 = Target:GetStatisticDeadTimes(Player.m_FbDpsBossName) + dead
	else
		--�ܵ��˺�����ÿ����˺���
		Data1 = Target:GetStatisticFightHurt(Player.m_FbDpsBossName) + hurt
		Data2 = Target:GetStatisticDps(Player.m_FbDpsBossName) + dps
	end
	--print(Name, Data1, Data2)
	Gas2Gac:UpdateMemberDpsInfo(Player.m_Conn, Name, Data1, Data2)
end

function CFbDpsServer.SendDpsInfo(Player)
	--�õ���ص�  �˺�  ����(Ĭ�ϵ����˺�����Ϣ)
	--�����ͻ���(������5���˵���Ϣ,����һ��)
	local function SendMsg()
		if IsCppBound(Player) and Player.m_FbDpsSendState then
			--�����Լ�����Ϣ
			SendClientInfo(Player, Player)
			
			local Scene = Player.m_Scene
			--���������˵���Ϣ
			for MemberID,IsSend in pairs (Scene.m_FbDpsMemberTbl[Player.m_FbDpsTeamType]) do
				local Member = g_GetPlayerInfo(MemberID)
				if IsSend and IsCppBound(Member) and Member.m_uID ~= Player.m_uID
					and Player.m_Scene.m_SceneId == Member.m_Scene.m_SceneId then
					SendClientInfo(Player, Member)
				end
			end
			
		end
	end
	
	if Player.m_DpsInfoTick then
		UnRegisterTick(Player.m_DpsInfoTick)
		Player.m_DpsInfoTick = nil
	end
	Player.m_DpsInfoTick = RegisterTick("DpsInfoTick", SendMsg, SendTime)
end

function CFbDpsServer.OpenFbDpsInfoWnd(Player, TeamType)
	local Scene = Player.m_Scene
	--���ó�ʼ�����ݵĽӿ�
	Player.m_DpsShowType = ShowTypeNum["�˺�"]
	Player.m_FbDpsBossName = "all"
	Player.m_FbDpsTeamType = TeamType
	
	if not Scene.m_FbDpsMemberTbl then
		Scene.m_FbDpsMemberTbl = {}
	end
	if not Scene.m_FbDpsMemberTbl[TeamType] then
		Scene.m_FbDpsMemberTbl[TeamType] = {}
	end
	--if not Scene.m_FbDpsMemberTbl[TeamType][Player.m_uID] then
		Scene.m_FbDpsMemberTbl[TeamType][Player.m_uID] = true
	--end
	
	Player:BeginStatistic(Player.m_FbDpsBossName)
	--֪ͨ�ͻ��˴򿪴���
	Gas2Gac:OpenFbDpsInfoWnd(Player.m_Conn)
	--�����������	
	CFbDpsServer.SendDpsInfo(Player)
end

local function OffLineSaveDpsInfo(Player)
	local Scene = Player.m_Scene
	local hurt,dps,heal,hps,besubHurt,dead
	--�ܵ��˺�����ÿ����˺���
	hurt = Player:GetStatisticFightHurt(Player.m_FbDpsBossName)
	dps = Player:GetStatisticDps(Player.m_FbDpsBossName)
	--�ܵ���������ÿ���������
	heal = Player:GetStatisticFightHeal(Player.m_FbDpsBossName)
	hps = Player:GetStatisticHps(Player.m_FbDpsBossName)
	--�ܵı��˺���
	besubHurt = Player:GetStatisticBeSubHurt(Player.m_FbDpsBossName)
	--��������
	dead = Player:GetStatisticDeadTimes(Player.m_FbDpsBossName)
	
	if not Scene.m_PlayerFbDPS then
		Scene.m_PlayerFbDPS = {}
	end
	if not Scene.m_PlayerFbDPS[Player.m_uID] then
		Scene.m_PlayerFbDPS[Player.m_uID] = {["Hurt"]=0,["Dps"]=0,["Heal"]=0,["Hps"]=0,["BesubHurt"]=0,["Dead"]=0}
	end
	
	Scene.m_PlayerFbDPS[Player.m_uID]["Hurt"] = Scene.m_PlayerFbDPS[Player.m_uID]["Hurt"] + hurt
	Scene.m_PlayerFbDPS[Player.m_uID]["Dps"] = Scene.m_PlayerFbDPS[Player.m_uID]["Dps"] + dps
	Scene.m_PlayerFbDPS[Player.m_uID]["Heal"] = Scene.m_PlayerFbDPS[Player.m_uID]["Heal"] + heal
	Scene.m_PlayerFbDPS[Player.m_uID]["Hps"] = Scene.m_PlayerFbDPS[Player.m_uID]["Hps"] + hps
	Scene.m_PlayerFbDPS[Player.m_uID]["BesubHurt"] = Scene.m_PlayerFbDPS[Player.m_uID]["BesubHurt"] + besubHurt
	Scene.m_PlayerFbDPS[Player.m_uID]["Dead"] = Scene.m_PlayerFbDPS[Player.m_uID]["Dead"] + dead
end

function CFbDpsServer.CloseFbDpsInfoWnd(Player)
	if Player.m_DpsInfoTick then
		UnRegisterTick(Player.m_DpsInfoTick)
		Player.m_DpsInfoTick = nil
	end
	
	if IsCppBound(Player) then
		--��������ʱ��ս����Ϣ
		OffLineSaveDpsInfo(Player)
		--����Ϣ�ص�����
		Gas2Gac:CloseFbDpsInfoWnd(Player.m_Conn)
		--֪ͨ������,�����뿪��
		local Name = Player.m_Properties:GetCharName()
		Player.m_Scene.m_FbDpsMemberTbl[Player.m_FbDpsTeamType][Player.m_uID] = false
		for MemberID in pairs (Player.m_Scene.m_FbDpsMemberTbl[Player.m_FbDpsTeamType]) do
			local Member = g_GetPlayerInfo(MemberID)
			if IsCppBound(Member) and Member.m_uID ~= Player.m_uID
				and Player.m_Scene.m_SceneId == Member.m_Scene.m_SceneId then
				Gas2Gac:DeleteMemberDpsInfo(Member.m_Conn,Name)
			end
		end
		--���������ݵĽӿ�
		Player:EndStatistic(Player.m_FbDpsBossName)
		Player:ClearAllStatisticData()
	end
	
	Player.m_DpsShowType = nil
	Player.m_FbDpsBossName = nil
	Player.m_FbDpsTeamType = nil
end

function CFbDpsServer.BeginSendFbDpsInfo(Conn)
	local Player = Conn.m_Player
	if IsCppBound(Player) then
		Player.m_FbDpsSendState = true
	end
end
function CFbDpsServer.EndSendFbDpsInfo(Conn)
	local Player = Conn.m_Player
	if IsCppBound(Player) then
		Player.m_FbDpsSendState = nil
	end
end

function CFbDpsServer.GetBossDpsInfo(Conn, BossName)
	local Player = Conn.m_Player
	if IsCppBound(Player) then
		Player.m_FbDpsBossName = BossName
	end
end

function CFbDpsServer.ChangeDpsShowType(Conn, ShowTypeName)
	local Player = Conn.m_Player
	if IsCppBound(Player) then
		Player.m_DpsShowType = ShowTypeNum[ShowTypeName]
	end
end
