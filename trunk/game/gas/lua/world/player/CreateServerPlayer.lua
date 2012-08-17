cfg_load "fb_game/FbActionDirect_Common"
gas_require "world/player/CreateServerPlayerInc"
gas_require "character/CharacterMediator"

-----------------------------------------------------------------
local function InitGroupMultiSender(Connection,friendGroupIdRes)
	local friendGroupIdTbl = friendGroupIdRes:GetTableSet()
	for i = 1,friendGroupIdRes:GetRowNum() do
		if not g_FriendGroupMultiMsgSenderTbl[friendGroupIdTbl(i,1)] then
			local friendGroupMsgSender = g_App:GetMultiMsgSender()
			g_FriendGroupMultiMsgSenderTbl[friendGroupIdTbl(i,1)] = friendGroupMsgSender
		end
		g_FriendGroupMultiMsgSenderTbl[friendGroupIdTbl(i,1)]:AddPipe(Connection)
	end
end

--��ҽ��볡��
local function _OnPlayerChangeInScene(Connection, uCharID, result)
	SaveCharLoginFuncFlow(uCharID,"_OnPlayerChangeInScene_begin")
	local function CallBack(team_id, oldServerId, friendGroupIdTbl)
		SaveCharLoginFuncFlow(uCharID,"CallBack")
		g_TemporaryTeamMgr:InitTemporaryTeamInfo(uCharID)
		CGasTeam.InitAllServerTeamInfo(team_id,uCharID)
		InitGroupMultiSender(Connection,friendGroupIdTbl)
	end
	local data = {}
	data["char_id"] = uCharID
	CallAccountAutoTrans(Connection.m_Account, "CharacterMediatorDB", "CharUpdateOnServerPos", CallBack, data, uCharID)
	
	apcall(g_PlayerInSceneFb,Connection.m_Player)
	local quest_info = CQuestNotepad:new(uCharID)
	quest_info:ChangeInScene_GetAllQuest(Connection.m_Player,result["QuestAllTbl"])
	SaveCharLoginFuncFlow(uCharID,"_OnPlayerChangeInScene_end")
end

--���ߺ���ϵС������Ϣ
local function SendSystemMsg(SysteMsgTbl,Connection)
	if SysteMsgTbl:GetRowNum() > 0 then
		for i = 1,SysteMsgTbl:GetRowNum() do
			SystemFriendMsgToClient(Connection,SysteMsgTbl(i,1))
		end
	end
end

local function InitAssociationInfo(Connection,ret,uCharID)
	local AssociationInfo = ret["AssociationInfo"]
	local friendClassList	= AssociationInfo.friendClassList
	local friendsInfo		= AssociationInfo.friendsInfo
	local playerTbl			= AssociationInfo.playerTbl
	--��ͻ��˷��ͺ��ѷ�����Ϣ
	CGasFriendBasic.SendFriendClassList(Connection, friendClassList)
	--��ͻ��˷�����Һ�����Ϣ
	CGasFriendBasic.SendFriendInfo(Connection, friendsInfo)
	local friendGroupIdTbl = AssociationInfo.friendGroupIdTbl
	InitGroupMultiSender(Connection,friendGroupIdTbl)

	if playerTbl:GetRowNum() > 0 then
		Gas2Gac:ReturnGetAssociationPersonalInfo(Conn,playerTbl(1,1),playerTbl(1,2),playerTbl(1,3),
		playerTbl(1,4),playerTbl(1,5),playerTbl(1,6),playerTbl(1,7),playerTbl(1,8))
	end
	
	local groupIdRes = friendGroupIdTbl
	local groupIdTbl = {}
	if groupIdRes:GetRowNum() > 0 then
		local tblSet = groupIdRes:GetTableSet()
		for i = 1,groupIdRes:GetRowNum() do
			table.insert(groupIdTbl,tblSet(i,1))
		end
	end
	
	local data = {["CharID"] = uCharID}
	if Connection.m_Account then
		local function CallBack(result)
			local friendGroupList	= result.friendGroupList
			local allFriendsInfo	= result.allFriendsInfo
			--��ͻ��˷��ͺ��ѷ�����Ϣ
			CGasFriendBasic.SendFriendGroupList(Connection, friendGroupList)
			--��ͻ��˷�����Һ���Ⱥ������Ϣ
			CGasFriendBasic.SendFriendInfoToClent(Connection, allFriendsInfo)
			Gas2Gac:ReturnInitFriendGroupInfoEnd(Connection)
		end
		
		local FriendsDB = "FriendsDB"
		CallAccountLoginTrans(Connection.m_Account, FriendsDB, "InitFriendGroupInfo", CallBack, data,unpack(groupIdTbl))
	end
end

local function InitGuideInfo(Conn, result)
	Gas2Gac:ReturnGetActionCountExBegin(Conn)
	for ActionName, CountsTbl in pairs(result[1]) do
		Gas2Gac:ReturnGetActionCountEx(Conn, ActionName, CountsTbl[1], CountsTbl[2])
	end
	for i = 1, result[2]:GetRowNum() do
		Gas2Gac:ReturnGetActionAllTimes( Conn, result[2]:GetData(i-1,0), result[2]:GetData(i-1,1) )
	end
	Gas2Gac:ReturnGetActionCountExEnd(Conn)
end

local function ShowMatchGameSign(Connection, playerLevel, uCharID)
	local actionNameTbl = {}
	for _, ActionName in pairs(FbActionDirect_Common:GetKeys()) do
		local IsShowPanel = FbActionDirect_Common(ActionName, "IsShowPanel")
		local MinMsgLevel = tonumber(FbActionDirect_Common(ActionName, "MinMsgLevel"))
		local MaxMsgLevel = tonumber(FbActionDirect_Common(ActionName, "MaxMsgLevel"))
		if IsShowPanel ~= "" and IsShowPanel == 1 then
			if CheckActionIsBeginFunc(ActionName) then
				if playerLevel >= MinMsgLevel and playerLevel <= MaxMsgLevel then
					table.insert(actionNameTbl, ActionName)
				end
			end
		end
	end
	return actionNameTbl
end

local function InitPlayerCanJoinAction(Connection, ret)
	if not IsCppBound(Connection) then
		return
	end
	if ret and table.getn(ret) > 0 then
		for _, canJoinAction in pairs(ret) do
			Gas2Gac:CreateMatchGameWnd(Connection, canJoinAction)
		end
	end
end

--������ߵ���
local function _OnPlayerLoginGame(Connection, uCharID, result)
	SaveCharLoginFuncFlow(uCharID,"_OnPlayerLoginGame")
	--������߸��������
	apcall(g_PlayerLoginSceneFb,Connection.m_Player)
--	Connection.m_Player.m_DoingQuest = {}
	local quest_info = CQuestNotepad:new(uCharID)
	quest_info:GetAllQuest(Connection.m_Player,result["QuestAllTbl"],result["QuestVarTbl"],result["QuestAwardItemIndex"],result["QuestLoopTbl"],result["TongBuildTbl"])
	local actionNameTbl = ShowMatchGameSign(Connection, result["CharInfo"](1,10), uCharID)
	
	local function CallBack(ret)
		SaveCharLoginFuncFlow(uCharID,"CallBack(ret)")
		CGasTeam.InitAllServerTeamInfo(ret["TeamID"])
		InitAssociationInfo(Connection,ret,uCharID)
		SendSystemMsg(ret["SysteMsgTbl"],Connection)
		apcall(InitGuideInfo, Connection, ret["GuideInfo"])
		InitPlayerCanJoinAction(Connection, ret["CanJoinAction"])
	end
	local data = {}
	data["char_id"] = uCharID
	data["char_level"] = result["CharInfo"](1,10)
	data["actionInfo"] = actionNameTbl
	CallAccountAutoTrans(Connection.m_Account, "CharacterMediatorDB", "CharLoginGame", CallBack, data)
end

local function _AdultCheckOnLogin(uCharID)
	if GasConfig.SkipAdultCheck == 1 then return end
	local function CallBack(ret)
		if ret(1,1) > 0 then
				LogoutForAdultCheck(uCharID)
		end
	end
	local data = {}
	data["char_id"] = uCharID
	CallDbTrans("LoginServerDB", "GetOneCharLeftTimeInfo", CallBack,data)
end

-------------------------------------------------------------------

function ReuseServerPlayer( Connection, player, result, lastMsgIdStr)
	apcall(CCharacterMediator.ReUsePlayer,CCharacterMediator,Connection, player, result, lastMsgIdStr)
	apcall(player.DisableDirectorMoving,player,false)
	
	local char_id = player.m_uID
	local CChannelInitRes	= result["CChannelInitRes"]
	local teamInfo = result["teamInfo"]
	apcall(InitNewTongMemberPanel,char_id)
	local tong_id = result["TongID"]
	
	apcall(CChatChannelMgr.Init,char_id,CChannelInitRes)
	
	--֪ͨС�Ӻ��Ŷӳ�Ա�����߲�ˢ�±����Ϣ
	apcall(CGasTeam.NotifyTeamInfoOnline,{Connection, char_id,teamInfo})
	--����Ӷ�������б�
	apcall(CRoleQuest.PlayerSendTempQuestList,Connection.m_Player)
	Connection.m_bCanCallTrans = true
	
	apcall(_OnPlayerLoginGame,Connection, char_id, result)
	g_AllConnection[char_id] = Connection
end

function CreateServerPlayer(Connection, ChangeType, uCharID, result, sceneInfo, lastMsgIdStr)
	SaveCharLoginFuncFlow(uCharID,"CreateServerPlayer_begin")
	local IsForbidLogin	= result["IsForbidLogin"]
	local CChannelInitRes	= result["CChannelInitRes"]
	if IsForbidLogin and Connection.ShutDown then
		--֪ͨһ�¿ͻ���˵�Ѿ�����ֹ��½��,����е�����
		--�������ֹ��ǰ������ݿ�����Ѿ�����ȴʱ���buff�����ݿ�dataɾ�����Ժ���
		Connection:ShutDown("�û�����ֹ��¼,�Ͽ�����")
		LogErr("�û�����ֹ��¼,�Ͽ�����","char_id:" .. uCharID)
		return
	end

	apcall(CCharacterMediator.Create,CCharacterMediator,Connection, uCharID, ChangeType, result, sceneInfo, lastMsgIdStr)
	
	apcall(g_AddPlayerInfo,uCharID, Connection.m_Player.m_Properties:GetCharName(), Connection.m_Player)
	------------------------------��������������ҵ���ɫ����-----------------------------------

	apcall(CChatChannelMgr.Init,uCharID,CChannelInitRes)
	
	Connection.m_bCanCallTrans = true
	----
	if ChangeType == 1 then--�з���¼��
		apcall(_OnPlayerChangeInScene,Connection, uCharID, result)
	else
		apcall(_OnPlayerLoginGame,Connection, uCharID, result)
			--֪ͨС�Ӻ��Ŷӳ�Ա�����߲�ˢ�±����Ϣ
		apcall(CGasTeam.NotifyTeamInfoOnline,{Connection, uCharID,result["teamInfo"]})
		apcall(_AdultCheckOnLogin,uCharID)
		Gas2GacById:SendUserGameID(uCharID,Connection.m_nGameID)
	end
	apcall(CCharacterMediator.InitTongMember,Connection.m_Player,result,Connection)
	apcall(InitNewTongMemberPanel,uCharID)
	apcall(CCharacterMediator.InitTongTechInfo,Connection.m_Player,result,Connection)
	--����Ӷ�������б�
	apcall(CRoleQuest.PlayerSendTempQuestList,Connection.m_Player)
	g_AllConnection[uCharID] = Connection
	SaveCharLoginFuncFlow(uCharID,"CreateServerPlayer_end")
	UnRegisterCharLoginFuncFlowTick(uCharID)
	return Connection.m_Player
end

function DestroyServerPlayer( player, result, IsChangeScene)
	local function Init()
		if( not player or not IsCppBound(player))then
			return
		end
		
		local uCharID = player.m_uID
		local uObjID = player:GetEntityID()
		local sCharName = player.m_Properties:GetCharName()
		local Scene = player.m_Scene
		
		if IsChangeScene then
			local LeaveSceneQuestFailure = result["LeaveSceneQuestFailure"]
			if LeaveSceneQuestFailure and next(LeaveSceneQuestFailure) then
				for i=1, #(LeaveSceneQuestFailure) do
					if LeaveSceneQuestFailure[i]["DelSucc"] then
						CRoleQuest.QuestFailure_DB_Ret(player,LeaveSceneQuestFailure[i]["QuestName"])
					end
				end
			end
		end
		
		--������߾Ͳ���Ҫ��ȡ����λ����
		apcall(CGasTeammatePosMgr.PlayerStopGetTeammatePos, player)
		
		if player.m_ActionLoadingTick then
			apcall(BreakPlayerActionLoading,player)
		end
		
		--���������ڲɼ�Obj����Ҫ����Obj��״̬
		if player.m_CollIntObjID then
			apcall(BreakPlayerCollItem,player)
		end
		--����������ʰȡNpc����
		if player.m_PickUpNpcID then
			apcall(BreakPlayerPickUpItem,player)
		end
		local Conn = player.m_Conn
		local function busystate_apcall()
			--����ڽ��׹��������ߣ���֪ͨ���׶Է�----------------------------------------------------------
			
			if Conn then
				if player.m_Conn.busystate ~= nil and
					player.m_Conn.busystate == 1 then
					local playerTran = CPlayerTran:new(uCharID)
					playerTran:ClearTradeState(player.m_Conn)
				end
				Conn.m_Player = nil
			end
		end
		
		apcall(busystate_apcall)
		
		local function logout_apcall()
			--����ʱ��С���Ŷ������Ϣ���ж�
			if result ~= nil and IsTable(result["teamInfo"]) then
				local teamInfo = result["teamInfo"]
				CGasTeam.DealWithTeamInfoLogout(uCharID, teamInfo)
			end
			g_GasTongMgr:MemberLogout(uCharID, player.m_Properties:GetTongID())

            local charTongTechInfo = result["TongTechInfo"]
			apcall(CTongTech.InitTongTechInfo,Conn, false, charTongTechInfo)

			--��Ⱥϵͳ����֪ͨ����
			local allFriendsInfo = result["allFriends"]
			if allFriendsInfo:GetRowNum() > 0 then
				local allFriendsInfoTbl = allFriendsInfo:GetTableSet()
				for i = 1, allFriendsInfo:GetRowNum() do
					--������Id,���ID
					Gas2GacById:NotifyFriendOffline(allFriendsInfoTbl(i,2), allFriendsInfoTbl(i,1),uCharID)
				end
			end
			--��Ⱥϵͳ����֪ͨ����Ⱥ��Ա
			local groupfriends = result["groupfriends"]
			if groupfriends:GetRowNum() > 0 then
				for i = 1, groupfriends:GetRowNum() do
					--���ID,����ȺID
					Gas2GacById:NotifyFriendGroupOffline(groupfriends(i,1),uCharID,groupfriends(i,2))
				end
			end
		end
		
		if not IsChangeScene then
			apcall(logout_apcall)
		end
		
		local TongID = result["TongID"] --player.m_Properties:GetTongID()
		if TongID and TongID > 0 then
			apcall(CGasTongmatePosMgr.PlayerStopGetTongmatePos,player)	--������߾Ͳ���Ҫ��ȡ����Աλ����
			apcall(CGasTongmatePosMgr.StopSendLeavedTongmatePos,TongID, uCharID) -- ֪ͨ�������������Ա����ʾ���߳�Ա��ͼ��
		end
				
		apcall(CFbPlayerPosMgr.StopSendLeavedFbPlayerPos, Scene, player)	-- ������߾Ͳ���ȡ���������λ����
			
		--������ڸ����У����ݲ�ͬ��ɾ������
		Scene.m_tbl_Player[uCharID] = nil
		--g_MainSceneAreaMgr:UndateAreaPlayerInfo(Scene)
		apcall(LeaveScene,Scene, player)
		
		apcall(player.Destroy, player)	
		player = nil
		g_DelPlayerInfo(uCharID, sCharName)
		g_AllConnection[uCharID] = nil
		------------------------------------
	end
	apcall(Init)
end 

--ԭʼ���г�������
function NewServerPlayerChangeScene( Player)
	
	local uCharID = Player.m_uID
	
	--���������ڲɼ�Obj����Ҫ����Obj��״̬
	if Player.m_CollIntObjID then
		BreakPlayerCollItem(Player)
	end
	--����������ʰȡNpc����
	if Player.m_PickUpNpcID then
		BreakPlayerPickUpItem(Player)
	end
	
	--�����淨���
	g_PlayerChangeSceneInFb(Player)
	
	--����ڽ��׹��������ߣ���֪ͨ���׶Է�--------------------------------
	if Player.m_Conn.busystate ~= nil and
		Player.m_Conn.busystate == 1 then
		local playerTran = CPlayerTran:new(uCharID)
		playerTran:ClearTradeState(Player.m_Conn)
	end
	---------------------------------------------------------------------------
		
end


--���������������֤���е����Ƕ�ִ����destory�������ٵ���EndService��ʱ��
local function OnSaveAllPlayerJobEnd()
	local function callback()
		EndService()
	end
	CallDbTrans("CharacterMediatorDB", "OnSaveAllPlayerJobEnd", callback, {})
end

function KickAllPlayer()
	g_bServerShuttingDown = true
	for _,v in pairs(g_AllConnection) do
		if v.m_Player then
			v.m_Player.m_bDisabled = true
			local function callback()
				if v.ShutDown then
					v:ShutDown("�ط�")
				end
			end
			LeaveGame(v.m_Player, v.m_Player.m_AccountID, v.m_UserName, callback)
			StopUpdateOnlineTime(v.m_UpOnlineTimeTick)
		end
	end
	
	for _, o in pairs(g_AllDisabledPlayer) do
		local function callback()
			if o.m_Conn and o.m_Conn.ShutDown then
				o.m_Conn:ShutDown("�ط�")
			end
		end
		LeaveGame(o, o.m_AccountID, o.m_UserName, callback)
	end
	
	OnSaveAllPlayerJobEnd()
end
--��ȡ��֤��
--[[
	ʵ�ַ�ʽ������һ��4λ���ֵ������
--]]


