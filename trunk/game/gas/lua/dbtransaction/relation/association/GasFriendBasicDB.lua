gas_require "relation/RevertValidateMgr"
gac_gas_require "framework/text_filter_mgr/TextFilterMgr"
local CFriend = {}

local CTextFilterMgr = CTextFilterMgr
local FriendNumLimit = 100
local RevertValidateMgr = RevertValidateMgr:new()

local FriendDbBox = CreateDbBox(...)

--[[����������ҵĺ������ࣺ
--	1: ����
--	2: ������
--]]

-----------------------------------------------------------------------------------------------------------
--@brief ��Ӻ���
--@param InvitorId:������ID
--@param InviteeId:����Ϊ���ѵ����ID
function FriendDbBox.AddFriendToClass(data)
	local InvitorId = data["InvitorId"]
	local InviteeId = data["InviteeId"]
	local classId = data["classId"]
	--�ж��ǲ����ܽ�����Ҽ�Ϊ����
	local succ, errorMsg = FriendDbBox.CanAddFriend(InvitorId, InviteeId)
	if (succ) then
		if (not errorMsg) then  --�Է������ߣ���������Ϣ��ʱ���뵽���ݿ���
			FriendDbBox.AddOfflineFriendMgr(InvitorId, InviteeId,classId)
			return false, 130004  --"�Է�������"
		end
		return succ
	else
		return succ, errorMsg
	end
end
-----------------------------------------------------------------------------------------------------------
--@brief ��Ӻ���ͨ�����name
--@param InvitorId:������ID
--@param playerName:����Ϊ���ѵ����name
function FriendDbBox.AddFriendToClassByName(data)
	local InvitorId = data["InvitorId"]
	local playerName = data["playerName"]
	local classId = data["classId"]
	
	--�ж��ǲ����ܽ�����Ҽ�Ϊ����
	local ex = RequireDbBox("Exchanger")
	local InviteeId = ex.getPlayerIdByName(playerName)
	
	if InviteeId == 0 then
		return false, 130013 --�����Ҳ�����
	end
	
	local succ, errorMsg = FriendDbBox.CanAddFriend(InvitorId, InviteeId)
	if (succ) then
		if (not errorMsg) then  --�Է������ߣ���������Ϣ��ʱ���뵽���ݿ���
			FriendDbBox.AddOfflineFriendMgr(InvitorId, InviteeId,classId)
			return false, 130004  --"�Է�������"
		end
		return succ,InviteeId
	else
		return succ, errorMsg
	end
end
-----------------------------------------------------------------------------------------------------------
--@brief ��Ӧ��Ϊ����
--@param InvitorId:������ID
--@param InviteeId:����Ϊ���ѵ����ID
function FriendDbBox.RequestAddFriend(data)
	local InviteeId = data["InviteeId"]
	local InvitorId = data["InvitorId"]
	local InvitorClassId = data["InvitorClassId"]
	local InviteeClassId = data["InviteeClassId"]
	local RevertValidateBox = RequireDbBox("RevertValidateDB")
	if not RevertValidateBox.DelValidateInfo(InvitorId,InviteeId,RevertValidateMgr:GetFunIndexByStr("AddFriend")) then
		return false
	end
	if InvitorId == 0 then
		return false,130013 --"����Ҳ�����!"
	end
	return FriendDbBox.AddFriend(InvitorId,InvitorClassId,InviteeId,InviteeClassId)
end
-----------------------------------------------------------------------------------------------------------
local StmtDef =
{
	"_GetPlayerLevelCampClass",
	[[
		select
			a.cb_uLevel,
			b.cs_uCamp,
			b.cs_uClass
		from
			tbl_char_basic a,
			tbl_char_static b
		where
			b.cs_uId = a.cs_uId and a.cs_uId = ? 
	]]
}
DefineSql( StmtDef , CFriend )

--@brief ������ҵȼ�
--@param charId:������ID
function FriendDbBox.GetPlayerLevelCampClass(charId)
	local tblInfo = {}
	local result = CFriend._GetPlayerLevelCampClass:ExecSql('n',charId)
	if result and result:GetRowNum() > 0 then
		table.insert( tblInfo, result:GetData(0,0) )
		table.insert( tblInfo, result:GetData(0,1) )
		table.insert( tblInfo, result:GetData(0,2) )
		result:Release()
	end
	return tblInfo
end
------------------------------------------------------------------------------------------------------------
--�������ID�ͺ�����Id���Һ�����name
local StmtDef = {
		"SelectFriendClassName",
		[[	
			select fc_sName from tbl_friends_class where fc_uId = ? and cs_uId = ?  
		]]
}
DefineSql( StmtDef, CFriend )

--����ѱ�����������
local StmtDef = {
		"AddNewFriend",
		[[
			replace into tbl_player_friends values(?,?,?)
		]]
}
DefineSql( StmtDef, CFriend )

local StmtDef = {
		"SelectPlayerLevel",
		[[	
			select  cb_uLevel from tbl_char_basic where cs_uId = ?
		]]
}
DefineSql( StmtDef, CFriend )

function FriendDbBox.AddFriendCommon(Id,ClassId,BeAddId)
	local g_LogMgr				= RequireDbBox("LogMgrDB")
	local SceneMgrDB			= RequireDbBox("SceneMgrDB")
	local GasTeamDB				= RequireDbBox("GasTeamDB")
	local ex					= RequireDbBox("Exchanger")
	local LoginServerSql		= RequireDbBox("LoginServerDB")
	local nLevel, nCamp, nClass = unpack( FriendDbBox.GetPlayerLevelCampClass(Id) )
	
	local classname = CFriend.SelectFriendClassName:ExecSql("",ClassId,Id)
	
	if( (not classname) or classname:GetRowNum() ) == 0 then
		ClassId = 1
		CFriend.AddNewFriend:ExecSql("",Id,BeAddId,1)
	else
		CFriend.AddNewFriend:ExecSql("",Id,BeAddId,ClassId)
	end
	g_LogMgr.AddFriend(Id,nLevel,BeAddId)
	classname:Release()
	
	local nTeamId		= GasTeamDB.GetTeamID(Id)
	local nSceneId		= SceneMgrDB.GetPlayerCurScene(Id)
	local CTongBasicBox  = RequireDbBox("GasTongBasicDB")
	local tblInfo = {}
	tblInfo.nClassId	= ClassId
	tblInfo.sName		= ex.getPlayerNameById(Id)
	tblInfo.nLevel		= nLevel
	tblInfo.nCamp		= nCamp
	tblInfo.nClass		= nClass
	tblInfo.nTeamSize	= GasTeamDB.CountTeamMems(nTeamId)
	tblInfo.sSceneName	= SceneMgrDB._GetSceneNameById(nSceneId)
	tblInfo.nBeOnline	= LoginServerSql.IsPlayerOnLine(Id) and 1 or 2
	
  local nTongID = CTongBasicBox.GetTongID(Id)
	tblInfo.nTongId = nTongID
	
	return tblInfo
end

--@brief ��Ӧ��Ӻ���
function FriendDbBox.AddFriend(InvitorId,InvitorClassId,InviteeId,InviteeClassId)
	local data =	{	{ ["self_id"] = InvitorId, ["player_id"] = InviteeId },
						{ ["self_id"] = InviteeId, ["player_id"] = InviteeId }
					}
	for i = 1, 2 do
		if FriendDbBox.IsBlackName(InvitorId, InviteeId) then
			if not FriendDbBox.DeleteBlackList(data[i]) then
				CancelTran()
				return false
			end
		end
	end
	
	local playerInfo = FriendDbBox.GetFriendInfo(InvitorId, InviteeId)
	if playerInfo then
		if playerInfo == 1 then
			return false  --"������Ѿ�����ĺ����б���"
		end
	end
	
	--classId, sName, level, camp, class, teamSize, sceneName, nBeOnline
	local tblInvitor = FriendDbBox.AddFriendCommon(InvitorId,InvitorClassId,InviteeId,InviteeClassId)
	local tblInvitee = FriendDbBox.AddFriendCommon(InviteeId,InviteeClassId,InvitorId,InvitorClassId)
	
	return true, tblInvitor, tblInvitee
end
-----------------------------------------------------------------------------------------------------------
local StmtDef = {
		"Friend_Kind",
		[[
			select fc_uId from tbl_player_friends where cs_uId = ? and pf_uFriendId = ? 
		]]
}
DefineSql( StmtDef, CFriend )
--@brief ���Һ�����Ϣ
function FriendDbBox.GetFriendInfo(invitorId, inviteeId)
	local query_result = CFriend.Friend_Kind:ExecSql("n", invitorId, inviteeId)
	if query_result == nil then
		return nil
	end
	
	if (0 == query_result:GetRowNum()) then --Ҫ��Ϊ���ѵ���Ҳ����Լ��ĺ����б�����
		query_result:Release()
		return nil
	end
	
	if query_result:GetData(0,0) ~= 2 then
		query_result:Release()
		return 1 --"������Ѿ�����ĺ����б���"
	else
		query_result:Release()
		return 2 --"���������ĺ������б���"
	end
end
---------------------------------------------------------------------------------------------------------
local StmtDef = {
		"Friend_All",
		[[
			select count(*) from tbl_player_friends	where cs_uId = ? and fc_uId = 1
		]]
}
DefineSql( StmtDef, CFriend )

--@brief �ж��ܷ���Ӻ�������
function FriendDbBox.CanAddFriend(invitorId, inviteeId)
	local RevertValidateBox = RequireDbBox("RevertValidateDB")
	if not RevertValidateBox.AddValidateInfo(invitorId,inviteeId,RevertValidateMgr:GetFunIndexByStr("AddFriend")) then
		return false
	end
	local setting_box = RequireDbBox("GameSettingDB")
 	if setting_box.GetOneSettingInfo(inviteeId,4) ~= 1 then
 		return false, 130000   --�Է������˾ܾ���������!
 	end
 	
	if invitorId == inviteeId then					--������Ҫ�ӵĺ������Լ�
		return false, 130001 --���ܽ��Լ���Ϊ����
	end
	
	local playerInfo = FriendDbBox.GetFriendInfo(invitorId, inviteeId)
	if playerInfo ~= nil then
		if playerInfo == 1 then
			return false,130002 --������Ѿ�����ĺ����б���
		end
	end
	
	local friends = CFriend.Friend_All:ExecSql("n", invitorId)
	if friends:GetRowNum() >= FriendNumLimit then
		friends:Release()
		return false, 130003 --��ĺ�����Ŀ�Ѿ��ﵽ����,�����ټӺ�����
	end
	friends:Release()
	local LoginServerSql = RequireDbBox("LoginServerDB")
	local isOnline = LoginServerSql.IsPlayerOnLine(inviteeId)	
	return true,isOnline
end
---------------------------------------------------------------------------------------------------------
local StmtDef={
		"Select_OfflineFriend_Mgr",
		[[
			select
				a.c_sName,
				b.fc_uId,
				b.ra_uInviter
			from
				tbl_char a,
				tbl_request_addfriend b
			where a.cs_uId = b.ra_uInviter and b.ra_uInvitee = ?
		
		]]
}
DefineSql(StmtDef, CFriend)

--@brief ����(������������)���ߺ�����������
--@param inviteeId:��������
function FriendDbBox.SendOfflineFriendRequest(inviteeId)
	local inviterSet = CFriend.Select_OfflineFriend_Mgr:ExecSql('s[32]nn', inviteeId)
	return inviterSet
end
---------------------------------------------------------------------------------------------------------
local StmtDef={
		"Add_OfflineFriend_Mgr",
		[[ replace into tbl_request_addfriend values(?,?,?) ]]
}
DefineSql(StmtDef, CFriend)

--@brief ������(������������)����д�뵽���ݿ�
--@param inviterId:������
--@param inviteeId:��������
function FriendDbBox.AddOfflineFriendMgr(inviterId,inviteeId,classId)
	if inviterId == 0 or inviteeId == 0 then
		return false
	end
	
	CFriend.Add_OfflineFriend_Mgr:ExecSql('', inviterId,inviteeId,classId)
	return g_DbChannelMgr:LastAffectedRowNum() > 0
end

---------------------------------------------------------------------------------------------------------
--������ʾ��ɺ������ʱ����Ӻ�����Ϣ�����ݿ�ɾ����
local StmtDef={
		"Delete_OfflineFriendRequest",
		[[
			delete from tbl_request_addfriend where ra_uInvitee = ? 
		]]
}
DefineSql( StmtDef, CFriend )

--@brief ɾ���Ѿ���ʾ���������Ϣ
function FriendDbBox.DeletOfflineFriendRequest(player_id)
	CFriend.Delete_OfflineFriendRequest:ExecSql('',player_id)
	return g_DbChannelMgr:LastAffectedRowNum() > 0
end
---------------------------------------------------------------------------------------------------------
local StmtDef = {
		"_SelectBlackName",
		[[
			select fc_uId from tbl_player_friends where cs_uId = ? and pf_uFriendId  = ? 
		]]
}
DefineSql( StmtDef, CFriend )

--@brief ����Ƿ��ں���������
function FriendDbBox.IsBlackName(invitorId, inviteeId)
	local black_info = CFriend._SelectBlackName:ExecSql("n", invitorId, inviteeId)
	if black_info == nil then
		return false
	end
	if black_info:GetRowNum() == 0 then
		black_info:Release()
		return false
	end

	if black_info:GetData(0,0) == 2 then
		black_info:Release()
		return true
	end
	return false
end
---------------------------------------------------------------------------------------------------
--@brief �������Һ���
--@param area:Ҫ���ҵ������������
--@param class:Ҫ���ҵ���ҵ�ְҵ
--@param gender:Ҫ���ҵ���ҵ��Ա� 1-�У�2-Ů
--@param low_level:Ҫ���ҵ���ҵ���͵ȼ�
--@param up_level:Ҫ���ҵ���ҵ���ߵȼ�
function FriendDbBox.SearchPlayerByRequest(data)
	local area = data["area"]
	local class = data["class"]
	local gender = data["gender"]
	local low_level = data["low_level"]
	local up_level = data["up_level"]
	local sSceneName = data["sSceneName"]
	local querySql = ""
	local playerTbl = {}
	local query_sql = " select a.cs_uId,a.c_sName,b.cb_uLevel from tbl_char a,tbl_char_basic b,tbl_char_static c,tbl_char_position cp,tbl_scene s,tbl_char_online co where a.cs_uId = b.cs_uId and b.cs_uId = c.cs_uId and c.cs_uId = cp.cs_uId and cp.cs_uId = co.cs_uId and cp.sc_uId = s.sc_uId "
	if nil ~= class and class ~= 0 then
		query_sql = query_sql .. " and c.cs_uClass = " .. class
	end
	
	if nil ~= gender and gender ~= 0 then
		query_sql = query_sql .. " and c.cs_uSex = " .. gender
	end
	
	if nil ~= low_level then
		query_sql = query_sql .. " and b.cb_uLevel >= " .. low_level
	end
	
	if nil ~= up_level then
		query_sql = query_sql .. " and b.cb_uLevel <= " .. up_level
	end

	if nil ~= sSceneName and sSceneName ~= "" then
		query_sql = query_sql .. " and s.sc_sSceneName = " .. "'" .. sSceneName .. "'"
	end 
	query_sql = query_sql .. " limit 80 "
	local _, query_result = g_DbChannelMgr:TextExecute(query_sql)
	if query_result == nil or query_result:GetRowNum() == 0 then
		query_result:Release()
		return playerTbl
	end
	
	local LoginServerSql = RequireDbBox("LoginServerDB")
	for i = 1,query_result:GetRowNum() do
		local playerinfo = {}
		playerinfo[1] = query_result:GetData(i-1,0)
		playerinfo[2] = query_result:GetData(i-1,1)
		playerinfo[3] = query_result:GetData(i-1,2)
		playerinfo[4] = LoginServerSql.IsPlayerOnLine(playerinfo[1])
		table.insert(playerTbl,playerinfo)
	end
	query_result:Release()
	return playerTbl
end
---------------------------------------------------------------------------------------------------
--@brief �������ID�������name��ȷ�������(���ID���Ȳ�)
--@param playerName��Ҫ���ҵ����name
--@param playerId��Ҫ���ҵ����Id
function FriendDbBox.SearchPlayerAccurately(data)
	local playerName = data["InviteeName"]
	local playerId = data["InviteeId"]
	local playeyInfo = nil
	if(0 ~= playerId) then
		playeyInfo = FriendDbBox.SearchPlayerAccuratelyById(playerId)
	end
	if(not playeyInfo and "" ~= playerName) then
		playeyInfo = FriendDbBox.SearchPlayerAccuratelyByName(playerName)
	end
	return playeyInfo
end
------------------------------------------------------------------------------------------------------
local StmtDef = {
		"SearchPlayerByName",
		[[
		select
			a.cs_uId,
			a.c_sName,
			b.cb_uLevel,
			ifnull(c.co_uOnServerId,0)
		from
			tbl_char a,
			tbl_char_basic b
		left join
			tbl_char_online c on b.cs_uId = c.cs_uId
		where
			a.cs_uId = b.cs_uId and a.c_sName = ?
		]]
}
DefineSql( StmtDef, CFriend )
--@brief ͨ����������������
--@param playerName��Ҫ���ҵ����name
function FriendDbBox.SearchPlayerAccuratelyByName(playerName)
	local ret = CFriend.SearchPlayerByName:ExecSql("nn", playerName)
	return ret
end
------------------------------------------------------------------------------------------------------
local StmtDef = {
		"SearchPlayerById",
		[[
		select
			a.cs_uId,
			a.c_sName,
			b.cb_uLevel,
			ifnull(c.co_uOnServerId,0)
		from
			tbl_char a,
			tbl_char_basic b
		left join
			tbl_char_online c on b.cs_uId = c.cs_uId
		where
			a.cs_uId = b.cs_uId and a.cs_uId = ?
		]]
}
DefineSql( StmtDef, CFriend )

--@brief ͨ�����Id�������
--@param playerId��Ҫ���ҵ����ID
function FriendDbBox.SearchPlayerAccuratelyById(playerId)
	local ret = CFriend.SearchPlayerById:ExecSql("s[32]n", playerId)
	return ret
end
---------------------------------------------------------------------------------------------------------
--�����Լ�����Һ��������ID
local StmtDef = {
		"Select_ClassId",
		[[
			select  fc_uId from tbl_player_friends where cs_uId = ? and pf_uFriendId = ?	
		]]
}
DefineSql( StmtDef, CFriend )

local StmtDef = {
		"Friend_delete",
		[[
			delete from tbl_player_friends where cs_uId = ? and pf_uFriendId = ?	
		]]
}
DefineSql( StmtDef, CFriend )

--@brief ɾ������
--@param invitorId������Լ���ID
--@param inviteeId�����Ҫɾ���ĺ��ѵ�ID
function FriendDbBox.DeleteFriend(data)
	local invitorId = data["self_id"]
	local inviteeId = data["player_id"]
	local nMyClassIdInFriend, nFriendClassIdInMy = 0, 0
	local g_LogMgr = RequireDbBox("LogMgrDB")
	--���Լ��ĺ����б�������Ҫɾ���ĺ���
	local info = FriendDbBox.GetFriendInfo(invitorId, inviteeId)
	if (not info) then
		return false
	end
	
	--�ڶԷ��ĺ����б��������Լ����ڵĺ�����ID
	local friendClassIdList = CFriend.Select_ClassId:ExecSql('',inviteeId,invitorId)
	--���Լ��ĺ����б��������Է����ڵĺ�����ID
	local myClassIdList = CFriend.Select_ClassId:ExecSql('',invitorId,inviteeId)
	
	if ( friendClassIdList and friendClassIdList:GetRowNum() > 0 ) then
		nMyClassIdInFriend = friendClassIdList:GetData(0,0)
	end
	if ( myClassIdList and myClassIdList:GetRowNum() > 0 ) then
		nFriendClassIdInMy = myClassIdList:GetData(0,0)
	end
	
	--���Լ��ĺ����б����潫�ú���ɾ��
	CFriend.Friend_delete:ExecSql('', invitorId, inviteeId)
	g_LogMgr.DeleteFriend(invitorId,inviteeId)
	if g_DbChannelMgr:LastAffectedRowNum() <= 0 then
		CancelTran()
		return false
	end
	
	--�ӶԷ��ĺ����б����潫�Լ�ɾ��
	if FriendDbBox.GetFriendInfo(inviteeId,invitorId) then
		CFriend.Friend_delete:ExecSql('', inviteeId,invitorId)
		g_LogMgr.DeleteFriend(inviteeId,invitorId)
		if g_DbChannelMgr:LastAffectedRowNum() <= 0 then
			CancelTran()
			return false
		end
	end
	
	local ex = RequireDbBox("Exchanger")
	local invitee_name = ex.getPlayerNameById(inviteeId)
	
	return true, nMyClassIdInFriend, nFriendClassIdInMy
end
------------------------------------------------------------------------------------------------------------
local StmtDef = {
		"Get_Group_Exist",
		[[	select 1 from tbl_friends_class where cs_uId = ? and fc_sName = ?]]
}
DefineSql( StmtDef, CFriend)

local StmtDef = {
		"Add_Friend_Group",
		[[	insert into tbl_friends_class (fc_sName,cs_uId) values (?, ?) ]]
}
DefineSql( StmtDef, CFriend )
--@brief ��Ӻ��ѷ���
--@param uCharId:���ID
--@param groupName:Ⱥ����
--@return ���سɼ��ɹ����

function FriendDbBox.AddFriendClass(data)
	local uCharId = data["CharID"]
	local groupName = data["GroupName"]
	
	local textFltMgr = CTextFilterMgr:new()
	groupName = textFltMgr:RemoveTab1(groupName)
	if "" == groupName then
		return false,130005 --"�Բ���,�½���������Ϊ��!"
	end
	
	if string.len(groupName)>32 then
		return false,130006 --"�Բ���,���������������!"
	end
	
	local textFltMgr = CTextFilterMgr:new()
	if(not textFltMgr:IsValidName(groupName)) then
		return false,130007 --"�Բ���,������ĺ����������Ϸ�!"
	end
	
	local query_result = CFriend.Get_Friend_All_Class:ExecSql('ns[32]', uCharId)
	--������17�����ٽ�ֵ����Ϊ�����������Ѿ��к��Ѻͺ���������Ĭ�ϵĺ������ˡ�
	if query_result and query_result:GetRowNum() >= 17 then 
		query_result:Release()
		return false,130051 --"���ѷ�����������15�������������ˡ�"
	end
	
	--�ж�����
	local query_result = CFriend.Get_Group_Exist:ExecSql('n', uCharId, groupName)
	if query_result == nil then
		return false
	end
	
	if (0 ~= query_result:GetRowNum()) then
		query_result:Release()
		return false,130008  -- "���Ѿ�����,���������ظ�!"
	end
	
	query_result:Release()
	CFriend.Add_Friend_Group:ExecSql('', groupName,uCharId)
	local newClassId = g_DbChannelMgr:LastInsertId()
	if g_DbChannelMgr:LastAffectedRowNum() > 0 then
		return true,130009,newClassId  -- "�鴴���ɹ�!",g_DbChannelMgr:LastInsertId()
	else
		return false,130010 -- "�鴴��ʧ��!"
	end
end
---------------------------------------------------------------------------------------------------------
--@brief  ��ȡ��ҵ����к�������
function FriendDbBox.GetGroupCount(fc_uId,playerId)
	local grouplist = {}
	local query_result = CFriend.SelectFriendClassName:ExecSql('s[32]',fc_uId,playerId)
	if query_result == nil then
		return grouplist
	end
	
	if (0 == query_result:GetRowNum()) then
		query_result:Release()
		return grouplist
	end
	
	local num = query_result:GetRowNum()
	for i = 1, num do
		table.insert(grouplist, query_result:GetData(i-1,0))
	end
	query_result:Release()
	return grouplist
end
--------------------------------------------------------------------------------------------------------------
local StmtDef = {
		"Insert_Friend_Group",
		[[insert into tbl_friends_class (fc_uId,fc_sName,cs_uId) values (?,?, ?) ]]
}
DefineSql( StmtDef, CFriend )

function FriendDbBox.InitAddFriendGoodClassAndBlackClass(uCharId)

	if 0 == #(FriendDbBox.GetGroupCount(1,uCharId)) then
		CFriend.Insert_Friend_Group:ExecSql('', 1,"�ҵĺ���",uCharId)
	end
	if 0 == #(FriendDbBox.GetGroupCount(2,uCharId)) then
		CFriend.Insert_Friend_Group:ExecSql('', 2,"������",uCharId)
	end

	return g_DbChannelMgr:LastAffectedRowNum() > 0
end
--------------------------------------------------------------------------------------------------------------
--������Һ��ѵ����ں�����
local StmtDef = {
		"Update_Friend_Class",
		[[
			update tbl_player_friends set fc_uId = ?  where cs_uId = ? and pf_uFriendId = ?
		]]
}
DefineSql( StmtDef, CFriend )

--ɾ����ҵĺ�����
local StmtDef = {
		"Delete_Friend_Class",
		[[
			delete from tbl_friends_class where fc_uId = ? and cs_uId = ?
		]]
}
DefineSql( StmtDef, CFriend )

--��ȡ�������к���
local StmtDef = {
		"Selece_Group_Member",
		[[	select pf_uFriendId from tbl_player_friends where cs_uId = ? and fc_uId = ?	]]
}
DefineSql( StmtDef, CFriend )

local StmtDef={
		"Update_FriendRequestByClassId",
		[[
			update tbl_request_addfriend set fc_uId = ? where fc_uId = ?
		]]
}
DefineSql( StmtDef, CFriend )

--@brief ɾ��������
--@param uCharId:���ID
--@param class_id:Ҫɾ������ID
function FriendDbBox.DeleteFriendClass(data)
	local uCharId		=	data["CharID"]
	local class_id		=	data["class_id"]
	if nil == FriendDbBox.GetGroupCount(class_id,uCharId) then
		return false,130011 --"�Բ���,Ҫɾ�������Ѳ�����!"
	end
	
	CFriend.Update_FriendRequestByClassId:ExecSql('', 1,class_id)

	local member_result = CFriend.Selece_Group_Member:ExecSql('n', uCharId, class_id)
	if ( member_result:GetRowNum() > 0 ) then
		for i = 1,member_result:GetRowNum() do
			CFriend.Update_Friend_Class:ExecSql("",1,uCharId,member_result:GetData(i-1,0))
			if g_DbChannelMgr:LastAffectedRowNum() < 1 then
				CancelTran()
				return false,130012 --"�ƶ����ѵ�������ʧ��!"
			end
		end
	end

	member_result:Release()
	CFriend.Delete_Friend_Class:ExecSql('', class_id,uCharId)
	if g_DbChannelMgr:LastAffectedRowNum() < 1 then
		CancelTran()
		return false,130017 --"ɾ��������ʧ��!"
	end
	return true
end
-----------------------------------------------------------------------------------------------------------
--�������Ƶ�����
local StmtDef = {
		"Move_To_Type",
		[[	update tbl_player_friends set fc_uId = ? where cs_uId = ? and pf_uFriendId = ?	]]
}
DefineSql( StmtDef, CFriend )

--@brief ����������ĳ��������
--@param uCharId:���ID
--@param playerId��Ҫ�ƶ������ID
--@param class_id��Ҫ�ƶ��ĺ�����Id
function FriendDbBox.MoveFriendToClass(data)
	local uCharId = data["CharID"]
	local playerId = data["PlayerID"]
	local class_id = data["newclass_id"]
	if FriendDbBox.GetFriendInfo(uCharId, playerId) == 1 then
		local invitor_classname = CFriend.SelectFriendClassName:ExecStat(class_id,uCharId)
		if (not invitor_classname) or invitor_classname:GetRowNum() == 0 then
			return false
		end
		CFriend.Move_To_Type:ExecSql("",class_id,uCharId,playerId)
		return g_DbChannelMgr:LastAffectedRowNum() > 0
	end
	return false
end
-----------------------------------------------------------------------------------------------------
--������ʾ��ɺ������ʱ����Ӻ�����Ϣ�����ݿ�ɾ����
local StmtDef={
		"Delete_OfflineFriend_Mgr",
		[[
			delete from tbl_offline_msg where om_uReciever = ? 
		]]
}
DefineSql( StmtDef, CFriend )

--���ߺ���ʾ����ʱ���˷��͵���Ӻ�����Ϣ
local StmtDef={
		"SelectOfflineMsg",
		[[ 
			select 
				om_uSender,c_sName,om_dtCreateTime,om_sContent 
			from 
				tbl_offline_msg,tbl_char 
			where om_uSender = cs_uId and om_uReciever = ? 
		]] 
}
DefineSql(StmtDef, CFriend)
	
--@brief ���ߺ���ʾ������Ϣ
function FriendDbBox.SelectOfflineMsg(playerId)
	local query_list = CFriend.SelectOfflineMsg:ExecStat(playerId)
	if query_list:GetRowNum() == 0 then
		return nil
	end
	CFriend.Delete_OfflineFriend_Mgr:ExecStat(playerId)
	return query_list
end
-----------------------------------------------------------------------------------------------------
local StmtDef={
		"_SelectOfflineGMMsg",
		[[ 
			select 
				gm_uSenderId,gm_dtCreateTime,gm_sContent 
			from 
				tbl_gm_msg 
			where gm_uRecieverId = ? and gm_uReadFlag = 1
		]] 
}
DefineSql(StmtDef, CFriend)

local StmtDef={
		"_ReadOfflineGMMsg",
		[[ 
			update tbl_gm_msg set gm_uReadFlag = 0 where gm_uRecieverId = ? 
		]] 
}
DefineSql(StmtDef, CFriend)
	
--@brief ���ߺ���ʾGM������Ϣ
function FriendDbBox.SelectOfflineGMMsg(playerId)
	local query_list = CFriend._SelectOfflineGMMsg:ExecStat(playerId)
	if query_list:GetRowNum() == 0 then
		return nil
	end
	CFriend._ReadOfflineGMMsg:ExecStat(playerId)
	return query_list
end
-------------------------------------------------------------------------------------------------------
--���º��ѱ�ʶ
local StmtDef = {
		"_UpdateFriendFlag",
		[[ 
			update tbl_player_friends set fc_uId = ? where cs_uId = ? and pf_uFriendId = ? 
		]]
}
DefineSql( StmtDef, CFriend )

--@brief ��Ӻ�����
function FriendDbBox.AddBlackList(data)
	local uCharId = data["CharID"]
	local playerId = data["PlayerID"]
	local classId = 0
	local g_LogMgr = RequireDbBox("LogMgrDB")
	--�鿴�Լ��ǲ��ǶԷ��ĺ���
	if FriendDbBox.GetFriendInfo(playerId,uCharId) == 1 then
		--�ڶԷ��ĺ����б��������Լ����ڵĺ�����ID
		local classIdList = CFriend.Select_ClassId:ExecSql("n", playerId, uCharId)
		if nil ~= classIdList or classIdList:GetRowNum() > 0 then
			classId = classIdList:GetData(0,0)
			--�ӶԷ��ĺ����б����潫�Լ�ɾ��
			CFriend.Friend_delete:ExecSql('', playerId, uCharId)
			g_LogMgr.DeleteFriend(playerId, uCharId)
			if g_DbChannelMgr:LastAffectedRowNum() <= 0 then
				CancelTran()
				return false
			end
		end
	end
	
	--����������Լ��ĺ����б�����ı�־
	CFriend._UpdateFriendFlag:ExecSql("",2,uCharId,playerId)
	if g_DbChannelMgr:LastAffectedRowNum() <= 0 then
		if 0 == #(FriendDbBox.GetGroupCount(2,uCharId)) then
			CFriend.Insert_Friend_Group:ExecSql('', 2,"������",uCharId)
		end
		CFriend.AddNewFriend:ExecSql("",uCharId,playerId,2)
	else
		g_LogMgr.DeleteFriend(uCharId, playerId)
	end
	
	return true,classId
end
-------------------------------------------------------------------------------------------------------
function FriendDbBox.AddBlackListByName(data)
	local uCharId = data["CharID"]
	local player_name = data["player_name"]
	local ex = RequireDbBox("Exchanger")
	local playerId = ex.getPlayerIdByName(player_name)
	if playerId == 0 then
		return false
	end
	local query_data = {
			["CharID"] = uCharId,
			["PlayerID"] = playerId
		}
	local suc,classId = FriendDbBox.AddBlackList(query_data)
	return suc,classId,playerId
end
-------------------------------------------------------------------------------------------------------
----@brief ɾ��������
function FriendDbBox.DeleteBlackList(data)
	return FriendDbBox.DeleteFriend(data)
end
----------------------------------------------------------------------------------------------------------
----��ȡ��������group
local StmtDef = {
		"Get_Friend_All_Class",
		[[	
			select fc_uId,fc_sName from tbl_friends_class where cs_uId = ?
		]]
}
DefineSql( StmtDef, CFriend)

--@brief  ��ȡ��ҵ����к�������
function FriendDbBox.GetAllFriendsClass(uCharId)
	local grouplist = {}
	local query_result = CFriend.Get_Friend_All_Class:ExecSql('ns[32]', uCharId)
	if query_result == nil then
		return grouplist
	end
	
	if (0 == query_result:GetRowNum()) then
		query_result:Release()
		return grouplist
	end
	
	local num = query_result:GetRowNum()
	
	for i = 1, num do
		local groupset = {}
		groupset[1] = query_result:GetData(i-1,0)
		groupset[2] = query_result:GetData(i-1,1)
		grouplist[i] = groupset
	end
	
	query_result:Release()
	return grouplist
end
----------------------------------------------------------------------------------------------------------
local StmtDef = {
		"SelectFriendInfo",
		[[
			select
				d.fc_uId,
				c.pf_uFriendId,
				a.c_sName,
				b.cb_uLevel,
				e.cs_uCamp,
				e.cs_uClass
			from
				tbl_char a,
				tbl_char_basic b,
				tbl_player_friends c,
				tbl_friends_class d,
				tbl_char_static e
			where
				a.cs_uId = b.cs_uId and c.pf_uFriendId = b.cs_uId and c.cs_uId = d.cs_uId and c.fc_uId = d.fc_uId
				and e.cs_uId = b.cs_uId and c.cs_uId = ?
			union
			select
				fc.fc_uId,
				pf.pf_uFriendId,
				cd.cd_sName,
				cb.cb_uLevel,
				cs.cs_uCamp,
				cs.cs_uClass
			from
				tbl_char_deleted cd,
				tbl_char_basic cb,
				tbl_player_friends pf,
				tbl_friends_class fc,
				tbl_char_static cs
			where
				cd.cs_uId = cb.cs_uId and pf.pf_uFriendId = cb.cs_uId and pf.cs_uId = fc.cs_uId and pf.fc_uId = fc.fc_uId
				and cs.cs_uId = cb.cs_uId and pf.cs_uId = ?
		]]
		
}
DefineSql( StmtDef, CFriend )

--@brief ���Һ�����Ϣ
function FriendDbBox.SelectFriendInfo(invitorId)
	local m_memberlist = {}
	local query_result = CFriend.SelectFriendInfo:ExecStat(invitorId,invitorId)
	
	if query_result == nil then
		return m_memberlist
	end
	
	if (0 == query_result:GetRowNum()) then --��ҵĺ����б�Ϊ��
		query_result:Release()
		return m_memberlist
	end
	local LoginServerSql	= RequireDbBox("LoginServerDB")
	local SceneMgrDB		= RequireDbBox("SceneMgrDB")
	local GasTeamDB			= RequireDbBox("GasTeamDB")
	local tong_box = RequireDbBox("GasTongBasicDB")
	for i=1, query_result:GetRowNum() do
		--������ID, ���ID, ����name, �ȼ�, ��Ӫ, ְҵ, С������, ���ڳ���, �Ƿ�����
		local friendsInfo = {}
		friendsInfo[1]	= query_result:GetData(i-1,0)
		friendsInfo[2]	= query_result:GetData(i-1,1)
		friendsInfo[3]	= query_result:GetData(i-1,2)
		friendsInfo[4]	= query_result:GetData(i-1,3)
		friendsInfo[5]	= query_result:GetData(i-1,4)
		friendsInfo[6]	= query_result:GetData(i-1,5)
		
		local nTeamId	= GasTeamDB.GetTeamID(friendsInfo[2])
		local nSceneId	= SceneMgrDB.GetPlayerCurScene(friendsInfo[2])
		local isOnline	= LoginServerSql.IsPlayerOnLine(friendsInfo[2])
		friendsInfo[7]	= GasTeamDB.CountTeamMems(nTeamId)
		friendsInfo[8]	= SceneMgrDB._GetSceneNameById(nSceneId)
		friendsInfo[9]	= isOnline and 1 or 2
		friendsInfo[10] = tong_box.GetTongID(friendsInfo[2])	
		table.insert(m_memberlist,friendsInfo)
	end
	query_result:Release()
	return m_memberlist
end
----------------------------------------------------------------------------------------------------------
local StmtDef = {
		"UpdateFriendInfo",
		[[
			select
				c.fc_uId,
				a.cb_uLevel
			from
				tbl_char_basic a,
				tbl_player_friends b,
				tbl_friends_class c
			where
				b.cs_uId = c.cs_uId and b.fc_uId = c.fc_uId and a.cs_uId = b.pf_uFriendId and
				b.cs_uId = ? and b.pf_uFriendId = ?
		]]
}
DefineSql( StmtDef, CFriend )

--@brief ����ָ��������Ϣ
function FriendDbBox.UpdateFriendInfo(data)
	local nCharID		= data["CharID"]
	local nFriendID		= data["FriendID"]
	local query_result	= CFriend.UpdateFriendInfo:ExecSql("", nCharID, nFriendID)
	
	if query_result == nil then
		return nil
	end
	
	if (0 == query_result:GetRowNum()) then
		query_result:Release()
		return nil
	end
	
	local SceneMgrDB	= RequireDbBox("SceneMgrDB")
	local GasTeamDB		= RequireDbBox("GasTeamDB")
	local tong_box = RequireDbBox("GasTongBasicDB")
	local tblFriendsInfo = {}
	--������ID, �ȼ�, С������, ���ڳ���
	tblFriendsInfo.classId	= query_result:GetData(0,0)
	tblFriendsInfo.level	= query_result:GetData(0,1)
	tblFriendsInfo.tongId = tong_box.GetTongID(nFriendID)	
		
	local nTeamId				= GasTeamDB.GetTeamID(nFriendID)
	local nSceneId				= SceneMgrDB.GetPlayerCurScene(nFriendID)
	tblFriendsInfo.teamSize		= GasTeamDB.CountTeamMems(nTeamId)
	tblFriendsInfo.sceneName	= SceneMgrDB._GetSceneNameById(nSceneId)

	query_result:Release()
	return tblFriendsInfo
end
----------------------------------------------------------------------------------------------------------
local StmtDef = {
		"UpdateOnlineFriendInfo",
		[[
			select
				c.fc_uId,
				b.pf_uFriendId,
				a.cb_uLevel
			from
				tbl_char_basic a,
				tbl_player_friends b,
				tbl_friends_class c,
				tbl_char_online d
			where
				c.fc_uId <> 2				and
				b.pf_uFriendId = a.cs_uId	and
				b.cs_uId = c.cs_uId			and
				b.fc_uId = c.fc_uId			and
				d.cs_uId = b.pf_uFriendId	and
				b.cs_uId = ?
			order by
				c.fc_uId
		]]
}
DefineSql( StmtDef, CFriend )

--@brief �������ߺ�����Ϣ
function FriendDbBox.UpdateOnlineFriendInfo(data)
	local nCharID		= data["CharID"]
	local tblUpdateList	= {}
	local query_result	= CFriend.UpdateOnlineFriendInfo:ExecSql("", nCharID)
	
	if query_result == nil then
		return tblUpdateList
	end
	
	if (0 == query_result:GetRowNum()) then --��ҵĺ����б�Ϊ��
		query_result:Release()
		return tblUpdateList
	end
	
	local SceneMgrDB	= RequireDbBox("SceneMgrDB")
	local GasTeamDB		= RequireDbBox("GasTeamDB")
	local tong_box = RequireDbBox("GasTongBasicDB")
	for i=1, query_result:GetRowNum() do
		--������ID, ���ID, �ȼ�, С������, ���ڳ���
		local friendsInfo = {}
		friendsInfo[1]	= query_result:GetData(i-1,0)
		friendsInfo[2]	= query_result:GetData(i-1,1)
		friendsInfo[3]	= query_result:GetData(i-1,2)
		
		local nTeamId	= GasTeamDB.GetTeamID(friendsInfo[2])
		local nSceneId	= SceneMgrDB.GetPlayerCurScene(friendsInfo[2])
		friendsInfo[4]	= GasTeamDB.CountTeamMems(nTeamId)
		friendsInfo[5]	= SceneMgrDB._GetSceneNameById(nSceneId)
		friendsInfo[6]	= tong_box.GetTongID(friendsInfo[2])	
		table.insert(tblUpdateList, friendsInfo)
	end
	query_result:Release()
	return tblUpdateList
end

----------------------------------------------------------------------------------------------------------
local StmtDef = {
		"SelectOffLineFriendInfo",
		[[
			select 
				fc_uId,cs_uId
			from
				tbl_player_friends
			where
				pf_uFriendId = ?
		]]
}
DefineSql( StmtDef, CFriend )

--@brief ����������ҵĺ�����Ϣ
function FriendDbBox.SelectOffLineFriendsInfo(playerId)
	local query_result = CFriend.SelectOffLineFriendInfo:ExecSql("nn",playerId)
	return query_result
end
-----------------------------------------------------------------------------------------------------------
function FriendDbBox.InitFriendGroupInfo(data)
	local uCharId		=	data["CharID"]
	local result = {}
	local FriendGroupDB = RequireDbBox("FriendGroupDB")
	--���Һ���Ⱥ��Ϣ
	result.friendGroupList = FriendGroupDB.GetAllFriendsGroup(uCharId)
	--������Һ�����Ϣ
	result.allFriendsInfo = FriendGroupDB.GetAllMembers(uCharId)
	
	return result
end
-----------------------------------------------------------------------------------------------------------

--������Ҳ����ߵ�˽����Ϣ
--������Ϣ���ID��������Ϣ���Id��С��Ϣ��ʱ�䣬��Ϣ������
local StmtDef = {
		"SavePrivateChatMsg",
		[[
			insert into tbl_offline_msg(om_uSender,om_uReciever,om_dtCreateTime,om_sContent) values(?,?,now(),?)
		]]
}
DefineSql( StmtDef, CFriend)


--��ѯ��ɫ����״̬
local StmtDef =
{
	"FindPlayerOnLineState",
	"select co_uOnServerId from  tbl_char_online where cs_uId = ?"
}
DefineSql( StmtDef, CFriend)

local StmtDef = {
		"SaveGMChatMsg",
		[[
			insert into tbl_gm_msg(gm_uSenderId,gm_uRecieverId,gm_dtCreateTime,gm_sContent,gm_uReadFlag) values(?,?,now(),?,?)
		]]
}
DefineSql( StmtDef, CFriend)

--@brief ˽��
function FriendDbBox.PrivateChatRequest(data)
	local playerId = data["playerId"]
	local object_id = data["object_id"]
	local message = data["text"]
	local textFltMgr = CTextFilterMgr:new()
	if object_id == 0 then
		CFriend.SaveGMChatMsg:ExecSql("n", playerId,object_id,message,0)
		return
	elseif playerId == 0 then
		local onlineState = CFriend.FindPlayerOnLineState:ExecSql("n", object_id)
		local beOnline = false
		if onlineState:GetRowNum() > 0 then
			beOnline = true
		else
			beOnline = false
		end
		if beOnline then
			CFriend.SaveGMChatMsg:ExecSql("n", playerId,object_id,message,0)
		else
			CFriend.SaveGMChatMsg:ExecSql("n", playerId,object_id,message,1)
		end
		return beOnline, beOnline
	end
	
	local isInBlackList = FriendDbBox.IsBlackName(object_id,playerId)
	if isInBlackList then
		return false,130014 --"���ڶԷ��ĺ�������,����˽��!"
	end
	
	local isInBlackList = FriendDbBox.IsBlackName(playerId, object_id)
	
	if isInBlackList then
		return false,130018 --"�Է�����ĺ������У�����˽��!"
	end
	
	--ȥ��ǰ��ո�
	message = textFltMgr:RemoveTab1(message)
	--�á�**���滻���в��Ϸ��ַ�
	message = textFltMgr:ReplaceInvalidChar(message)
	
	local onlineState = CFriend.FindPlayerOnLineState:ExecSql("n", object_id)
	local beOnline = false
	if onlineState:GetRowNum() > 0 then
		beOnline = true
		onlineState:Release()
	else
		onlineState:Release()
		--˽�Ķ�������,��������Ϣ
		CFriend.SavePrivateChatMsg:ExecSql("",playerId,object_id,message)
		return false,130004 --"����Ҳ�����"
	end

	local ex = RequireDbBox("Exchanger")
	local char_name = ex.getPlayerNameById(playerId)
	return true, beOnline,char_name
end
-------------------------------------------------------------------------------------------------------------     		
local StmtDef = {
		"Update_Class_Name_Stmt",
		[[
			update tbl_friends_class set fc_sName = ? where fc_uId = ?
		]]
}
DefineSql (StmtDef,CFriend)

--@brief �޸�����
function FriendDbBox.UpdateFriendClassName(data)
	local playerId = data["playerId"]
	local friend_classId = data["friend_classId"]
	local new_className = data["new_className"]
	
	if friend_classId == 1 or friend_classId == 2 then
		return false,130019 --"�Բ���,ϵͳĬ���鲻��������!"
	end
	
	--�ж�����
	local query_result = CFriend.Get_Group_Exist:ExecSql('n', playerId, new_className)
	if query_result == nil then
		return false
	end
	
	if (0 ~= query_result:GetRowNum()) then
		query_result:Release()
		return false,130020  --new_className .. "���Ѿ�����,���������ظ�!"
	end
	
	if string.len(new_className)>32 then
		return false,130006 --"�Բ���,���������������!"
	end
	
	CFriend.Update_Class_Name_Stmt:ExecSql('',new_className,friend_classId)
	local b_flag = g_DbChannelMgr:LastAffectedRowNum() > 0
	if not b_flag then
		return false,130021 --"����������ʧ��!"
	else
		return true
	end
end

-----------------------------------------------------------------------------------------------------------
--@brief ͨ��������ֵõ����ID
function FriendDbBox.GetMemberIdByName(data)
	local memberName = data["memberName"]
	local ex = RequireDbBox("Exchanger")
	local memberId = ex.getPlayerIdByName(memberName)
	if(0 == memberId) then
		return false
	else
		return true, memberId
	end
end
----------------------------------------------------------------------------------------------------
local StmtDef = {
		"Save_FellStatement",
		[[ 
		call SaveShowSentence(?,?)
		]]
}
DefineSql (StmtDef, CFriend)
--@brief �����������
--@param fellStatement:�������
function FriendDbBox.SaveShowSen(data)
	local playerId = data["playerId"]
	local showSen = data["showSen"]

	if not playerId or playerId == 0 then
		return false
	end
	if string.len(showSen) > 32 then
		return false,130053 --�����������������
	end
	
	CFriend.Save_FellStatement:ExecStat(playerId, showSen)
	return g_DbChannelMgr:LastAffectedRowNum() > 0
end
----------------------------------------------------------------------------------------------------
local StmtDef = {
		"Save_PlayerInfo",
		[[ 
		replace into 
			tbl_friends_info(cs_uId,fi_uFellState,fi_sFellStatement,fi_sHobby,fi_uBodyShape,fi_uPersonality,fi_uMakeFriendState,fi_uStyle,fi_sDetail)
		values(?,?,?,?,?,?,?,?,?)
		]]
}
DefineSql (StmtDef, CFriend)
--@brief ����Ⱥ����ĸ�����Ϣ
--@param fellState:����
--@param fellStatement:�������
--@param hobby:��Ȥ����
--@param bodyShape:����
--@param personality:����
--@param makeFriendState:����״̬
--@param style:����
--@param first_newest:���¶�̬1
--@param second_newest:���¶�̬2
--@param third_newest:���¶�̬3
function FriendDbBox.SavaPlayerInfo(data)
	local playerId = data["playerId"]
	local fellState = data["fellState"]			--fell���������ô��������
	local fellStatement = data["fellStatement"]
	local hobby = data["hobby"]
	local bodyShape = data["bodyShape"]
	local personality = data["personality"]
	local makeFriendState = data["makeFriendState"]
	local style = data["style"]
	local detail = data["detail"]
	
	if playerId == nil or playerId == 0 then
		return false
	end
	if string.len(fellStatement) > 32 then
		return false,130053 --�����������������
	end
	if string.len(hobby) > 255 then
		return false,130054 --�������Ȥ���ù�����
	end
	if string.len(detail) > 255 then
		return false,130055 --����˵��
	end
	
	CFriend.Save_PlayerInfo:ExecStat(playerId,fellState,fellStatement,hobby,bodyShape,personality,makeFriendState,style,detail)
														
	return g_DbChannelMgr:LastAffectedRowNum() > 0
end
----------------------------------------------------------------------------------------------------
local StmtDef = {
		"Select_PersonalInfo",
		[[ 
		select
			ifnull(fi_uFellState,0),ifnull(fi_sFellStatement,""),ifnull(fi_sHobby,""),ifnull(fi_uBodyShape,0),
			ifnull(fi_uPersonality,0),ifnull(fi_uMakeFriendState,0),ifnull(fi_uStyle,0),ifnull(fi_sDetail,"") 
		from 
			tbl_friends_info
		where
			cs_uId = ?
		]]
}
DefineSql (StmtDef, CFriend)

--@brief �鿴���˻�����Ϣ
function FriendDbBox.SelectPersonalInfo(data)
	local playerId = data["uPlayerID"]
	if playerId == nil or playerId == 0 then
		return playerTbl
	end
	local playerInfo = CFriend.Select_PersonalInfo:ExecStat(playerId)
	return playerInfo
end
----------------------------------------------------------------------------------------------------
--�鿴���ѵĻ�����Ϣ
local StmtDef = {
		"Select_PlayerInfo",
		[[ 
		select
			a.cs_uClass,b.cb_uLevel,s.sc_sSceneName
		from
			tbl_char_static a,
			tbl_char_basic b,
			tbl_char_position c,
			tbl_scene s
		where
			a.cs_uId = b.cs_uId and b.cs_uId = c.cs_uId and c.sc_uId = s.sc_uId and a.cs_uId = ?
		]]
}
DefineSql (StmtDef, CFriend)

--�鿴���ѵ�Ӷ������Ϣ
local StmtDef = {
		"Select_TongInfo",
		[[ 
		select
			b.t_sName
		from
			tbl_member_tong a,
			tbl_tong b
		where
			a.t_uId = b.t_uId and a.cs_uId = ?
		]]
}
DefineSql (StmtDef, CFriend)

--@brief �鿴��һ�����Ϣ
function FriendDbBox.GetAssociationMemberInfo(data)
	local playerId = data["playerId"]
	local playerTbl = {}
	local tongName = ""
	local class = 1
	local level = 1
	local position = 1
	if playerId == nil or playerId == 0 then
		return playerTbl
	end
	
	local playerInfo = CFriend.Select_PlayerInfo:ExecStat(playerId)
	local playerTongInfo = CFriend.Select_TongInfo:ExecStat(playerId)
	
	if nil ~= playerInfo or playerInfo:GetRowNum() > 0 then
		class = playerInfo:GetData(0,0)
		level = playerInfo:GetData(0,1)
		position = playerInfo:GetData(0,2)
	end
	
	if playerTongInfo ~= nil and playerTongInfo:GetRowNum() > 0 then
		tongName = playerTongInfo:GetData(0,0)
	end
	
	playerTbl[1] = 0
	playerTbl[2] = ""
	playerTbl[3] = class
	playerTbl[4] = level
	playerTbl[5] = tongName
	playerTbl[6] = ""
	playerTbl[7] = position
	playerTbl[8] = ""
	playerTbl[9] = 0
	playerTbl[10] = 0
	playerTbl[11] = 0
	playerTbl[12] = 0
	playerTbl[13] = ""
	
	
	local playerOtherInfo = CFriend.Select_PersonalInfo:ExecStat(playerId)
	
	if nil ~= playerOtherInfo or playerOtherInfo:GetRowNum() > 0 then
		for i = 1 ,playerOtherInfo:GetRowNum() do
			playerTbl[1] = playerOtherInfo:GetData(i-1,0) or 0 
			playerTbl[2] = playerOtherInfo:GetData(i-1,1) or ""
			playerTbl[8] = playerOtherInfo:GetData(i-1,2) or ""
			playerTbl[9] = playerOtherInfo:GetData(i-1,3) or 0
			playerTbl[10] = playerOtherInfo:GetData(i-1,4) or 0
			playerTbl[11] = playerOtherInfo:GetData(i-1,5) or 0
			playerTbl[12] = playerOtherInfo:GetData(i-1,6) or 0
			playerTbl[13] = playerOtherInfo:GetData(i-1,7) or ""
		end

		return playerTbl
	end
	return playerTbl
end
-----------------------------------------------------------------------------------------------------------
SetDbLocalFuncType(FriendDbBox.AddFriendClass)
SetDbLocalFuncType(FriendDbBox.SearchPlayerAccurately)
SetDbLocalFuncType(FriendDbBox.SearchPlayerByRequest)
SetDbLocalFuncType(FriendDbBox.AddFriendToClass)
SetDbLocalFuncType(FriendDbBox.RequestAddFriend)
SetDbLocalFuncType(FriendDbBox.DeleteFriend)
SetDbLocalFuncType(FriendDbBox.MoveFriendToClass)
SetDbLocalFuncType(FriendDbBox.PrivateChatRequest)
SetDbLocalFuncType(FriendDbBox.AddBlackList)
SetDbLocalFuncType(FriendDbBox.AddBlackListByName)
SetDbLocalFuncType(FriendDbBox.DeleteBlackList)
SetDbLocalFuncType(FriendDbBox.SelectOfflineMsg)
SetDbLocalFuncType(FriendDbBox.UpdateFriendClassName)
SetDbLocalFuncType(FriendDbBox.DeleteFriendClass)
SetDbLocalFuncType(FriendDbBox.GetMemberIdByName)
SetDbLocalFuncType(FriendDbBox.AddFriendToClassByName)
return FriendDbBox
