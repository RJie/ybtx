gac_gas_require "framework/text_filter_mgr/TextFilterMgr"
local CFriendGroup = {}

local CTextFilterMgr = CTextFilterMgr
local FriendGroupDbBox = CreateDbBox(...)
---------------------------------------------------------------------------------------------
--@brief ��������Ⱥ
--@param groupname��Ⱥ����
--@param groupkind��Ⱥ����
--@param keyword���ؼ���
--@param groupannoun��Ⱥ����

function FriendGroupDbBox.CreateFriendGroup(data)
	local playerId = data["playerId"]
	local groupname = data["groupname"]
	local groupkind = data["groupkind"]
	local keyword = data["keyword"]
	local groupannoun = data["groupannoun"]
	if(string.len(groupname) > 32) then
		return false,130022 --"Ⱥ�����ܳ���32���ַ�!"
	end

	local textFltMgr = CTextFilterMgr:new()
	if (not textFltMgr:IsValidName(groupname)) then
		return false,130023 --"Ⱥ���ƷǷ�!"
	end
	
	if (not textFltMgr:IsValidMsg(groupannoun)) then
		return false,130028 --"����Ƿ�������������!"
	end
	
	local succ,code,groupid = FriendGroupDbBox.AddChatGroup(groupname,groupkind,groupannoun,playerId,keyword)
	
	return succ,code,groupid 
end
-------------------------------------------------------------------------------------------------
--@brief ������������Ⱥ
--@param keyword��Ⱥ�Ĺؼ���
--@param groupkind��Ⱥ������
function FriendGroupDbBox.SearchFriendGroupByRequest(data)
	local keyword = data["keyword"]
	local groupkind = data["groupkind"]
	local query_sql = "select a.fg_uId,a.fg_sName,b.c_sName from tbl_friends_group a,tbl_char b,tbl_group_manager c where a.fg_uId = c.fg_uId and c.cs_uId = b.cs_uId and c.gm_uIdentity = 1 "
	if nil ~= keyword and keyword ~= "" then
		query_sql = query_sql .. " and (a.fg_sKeyWord like '\%" .. keyword .. "\%' or a.fg_sName like '\%" .. keyword .. "\%')"
	end
	if nil ~= groupkind and groupkind ~= 0 then
		query_sql = query_sql .. " and a.fg_uGroupKind = " .. groupkind
	end
	local _, query_result = g_DbChannelMgr:TextExecute(query_sql)
	return query_result
end
-------------------------------------------------------------------------------------------------
--@brief ����ȺID����Ⱥname��ȷ����Ⱥ(ȺID���Ȳ�)
--@param friendGroupName��Ҫ���ҵ�Ⱥname
--@param friendGroupId��Ҫ���ҵ�ȺId

function FriendGroupDbBox.SearchFriendGroupAccurately(data)
	local friendGroupId = data["friendGroupId"]
	local friendGroupName = data["friendGroupName"]

	local friendGroupInfo = nil
	if(0 ~= friendGroupId) then
		friendGroupInfo = FriendGroupDbBox.SearchGroupById(friendGroupId)
	end
	if(not friendGroupInfo and "" ~= friendGroupName) then
		friendGroupInfo = FriendGroupDbBox.SearchGroupByName(friendGroupName)
	end
	return friendGroupInfo
end
-------------------------------------------------------------------------------------------------
local StmtDef = {
		"Search_Group_ByName",
		[[ 
			select
				a.fg_uId,
				b.c_sName
			from 
				tbl_friends_group a,
				tbl_char b,
				tbl_group_manager c
			where
				a.fg_uId = c.fg_uId and c.cs_uId = b.cs_uId and a.fg_sName = ? and c.gm_uIdentity = 1
		]]
}
DefineSql (StmtDef,CFriendGroup)

--@brief ��Ⱥ������Ⱥ
--@param Group_Name:Ⱥ����
function FriendGroupDbBox.SearchGroupByName(Group_Name)
	local result = CFriendGroup.Search_Group_ByName:ExecStat(Group_Name)
	local groupTbl = {}
	if result == nil then
		result:Release()
		return nil
	end
	
	if( 0 == result:GetRowNum()) then
		result:Release()
		return nil
	end
	
	for i = 1,result:GetRowNum() do
		local groupinfo = {}
		groupinfo[1] = result:GetData(i-1,0)
		groupinfo[2] = Group_Name
		groupinfo[3] = result:GetData(i-1,1)
		table.insert(groupTbl,groupinfo)
	end
	
	return groupTbl
end
-------------------------------------------------------------------------------------------------
local StmtDef = {
		"Search_Group_ById",
		[[
			select
				a.fg_sName,
				b.c_sName
			from
				tbl_friends_group a,
				tbl_char b,
				tbl_group_manager c
			where 
				a.fg_uId = c.fg_uId and c.cs_uId = b.cs_uId and a.fg_uId = ? and c.gm_uIdentity = 1
		]]
}
DefineSql (StmtDef,CFriendGroup)
--@brief ��ID����Ⱥ
--@param Group_Id:Ҫ���ҵ�ȺID
function FriendGroupDbBox.SearchGroupById(Group_Id)
	assert(IsNumber(Group_Id))
	local groupTbl = {}
	local result = CFriendGroup.Search_Group_ById:ExecStat(Group_Id)
	
	if result == nil then
		result:Release()
		return groupTbl
	end
	
	if(0 == result:GetRowNum()) then
		result:Release()
		return groupTbl
	end	
	
	for i = 1,result:GetRowNum() do
		local groupinfo = {}
		groupinfo[1] = Group_Id
		groupinfo[2] = result:GetData(i-1,0)
		groupinfo[3] = result:GetData(i-1,1)
		table.insert(groupTbl,groupinfo)
	end
	
	return groupTbl
end
-------------------------------------------------------------------------------------------------
--�鿴���һ�������˶��ٸ�Ⱥ
local StmtDef = {
		"Get_GroupsId",
		[[ select count(*) from tbl_group_manager where cs_uId=? and gm_uIdentity = 1]]
}
DefineSql ( StmtDef, CFriendGroup )

--�鿴Ҫ������Ⱥ�����ǲ��Ǻ����е�Ⱥ�����ظ�
local StmtDef = {
		"Get_SameGroupsId",
		[[ select count(*) from tbl_friends_group fg,tbl_group_manager gm where fg.fg_uId = gm.fg_uId gm.cs_uId=? and fg_sName = ? and gm.gm_uIdentity = 1]]
}
DefineSql ( StmtDef, CFriendGroup )

--�����ݿ�������ӹ�����Ⱥ�ļ�¼
local StmtDef = {
		"Add_NewGroup",
		[[ insert into tbl_friends_group(fg_sName,fg_sAnnouncement,fg_sKeyWord,fg_uGroupKind) values(?,?,?,?)]]
}
DefineSql ( StmtDef, CFriendGroup )

--�����Ա�����������
local StmtDef = {
		"Add_Member_Stmt",
		[[ insert into tbl_group_manager(fg_uId,cs_uId,gm_uIdentity) values(?,?,?) ]]
}
DefineSql ( StmtDef, CFriendGroup )

--�޸�Ⱥ����
local StmtDef = {
		"Change_GroupAnnouncement",
		[[ update tbl_friends_group set fg_sAnnouncement = ? where fg_uId = ?]]
}
DefineSql ( StmtDef, CFriendGroup )


local StmtDef = {
		"_GetCharLevel",
		[[ select cb_uLevel from tbl_char_basic where cs_uId=?]]
}
DefineSql ( StmtDef, CFriendGroup )


--@brief ��������Ⱥ
--@param groupname��Ⱥ����
--@param groupkind��Ⱥ����
--@param keyword���ؼ���
--@param groupannoun��Ⱥ����

function FriendGroupDbBox.AddChatGroup(Group_Name,Group_Kind,Group_Announ,playerId,keyword)
	local level_res = CFriendGroup._GetCharLevel:ExecStat(playerId)
	if level_res:GetRowNum() == 0 then
		return false,130024
	end
	local char_level = level_res:GetData(0,0)
	if char_level <= 4 then
		return false,130059 --�ȼ�����5������Խ�����һ��Ⱥ
	end
	
	--�鿴���һ�������˶��ٸ�Ⱥ
	local groups = CFriendGroup.Get_GroupsId:ExecStat(playerId)
	if groups == nil then
		return false,130024 --"���ݿ����ʧ��!"
	end
	local groups_num = groups:GetData(0,0)
	if char_level >=5 and char_level < 15  then
		if groups_num >= 1 then
			return false,130060
		end
	elseif char_level >=15 and char_level < 35 then
		if groups_num >= 2 then
			return false,130061
		end
	elseif char_level >=35 then
		if groups_num >= 3 then
			return false,130062
		end
	end
	
	groups:Release()
	
	if Group_Announ == nil then
		Group_Announ = "  "
	end

	if Group_Announ == "" then
		Group_Announ = "  "
	end

	if(string.len(Group_Announ)>255) then
		return false,130027 --"Ⱥ����ĳ��Ȳ��ܳ���255���ַ�!"
	end

	local textFltMgr = CTextFilterMgr:new()	
	if(not textFltMgr:IsValidMsg(Group_Announ)) then
		return false,130028 --"�������ݷǷ�!"
	end

	CFriendGroup.Add_NewGroup:ExecStat(Group_Name,Group_Announ,keyword,Group_Kind)
	if g_DbChannelMgr:LastAffectedRowNum() <= 0 then
		CancelTran()
		return false,130029 --"��������Ⱥʧ��!"
	end
	
	local groupid = g_DbChannelMgr:LastInsertId()
	
	CFriendGroup.Add_Member_Stmt:ExecStat(groupid,playerId,1)
	if g_DbChannelMgr:LastAffectedRowNum() <= 0 then
		CancelTran()
		return false,130030 --"��Ⱥ�б��������ʧ��!"
	end
					
	return g_DbChannelMgr:LastAffectedRowNum()>0,0,groupid
end
------------------------------------------------------------------------------------------------- 
--@brief ����/ȡ������Ա
--@param group_id��Ҫ���õ�ȺId
--@param newadmin_id���¹���Ա��Id
function FriendGroupDbBox.SetAdminRequest(data)
	local playerId = data["playerId"]
	local group_id = data["Group_Id"]
	local newadmin_id = data["Member_Id"]
	local type = data["type"]
	local succ,code = FriendGroupDbBox.SetIdentity(playerId,newadmin_id,group_id,type)
	if(not succ) then
		return succ,code
	else
		local memberSet = FriendGroupDbBox.GetMemberIdByGroupId(group_id)	
		return succ,memberSet
	end
end
------------------------------------------------------------------------------------------------- 
----��ȡĳ����Ա��Ϣ
local StmtDef = {
		"Get_Member_Info_Stmt",
		[[ select gm_uIdentity from tbl_group_manager where cs_uId= ? and fg_uId = ?]]
}
DefineSql ( StmtDef, CFriendGroup)

--�鿴����Ա������
local StmtDef = {
		"Get_AdminNum_Stmt",
		[[ select count(*) from tbl_group_manager where fg_uId = ? and gm_uIdentity = ?]]
}
DefineSql (StmtDef,CFriendGroup)

--���ù���Ա
local StmtDef = {
		"Set_Identity_Stmt",
		[[ update tbl_group_manager set gm_uIdentity = ? where cs_uId = ? and fg_uId = ?]]
}
DefineSql (StmtDef, CFriendGroup)

--@brief ����/ȡ������ԱȨ��
--@param selfId��Ⱥ��ID
--@param g_Id��Ҫ���õ�ȺId
--@param Player_Id��Ҫ����/ȡ���¹���ԱȨ�޵����Id
--@param Identity��1--Ⱥ��ת��Ȩ�� ��2--���ù���Ա�� 3--ȡ������ԱȨ��
function FriendGroupDbBox.SetIdentity(selfId,Player_Id,g_Id,Identity)
	assert(IsNumber(Player_Id))
	assert(IsNumber(g_Id))
	assert(IsNumber(selfId))
	--�鿴����ڸ�Ⱥ������
	local playerinfo = CFriendGroup.Get_Member_Info_Stmt:ExecStat(Player_Id,g_Id)
	--�鿴�Լ��ڸ�Ⱥ�����
	local selfinfo = CFriendGroup.Get_Member_Info_Stmt:ExecStat(selfId,g_Id)
	
	if playerinfo == nil or selfinfo == nil then
		return false,130031 --"����ְλʧ��!"
	end
	
	if(playerinfo:GetRowNum() == 0 or selfinfo:GetRowNum() == 0) then
		playerinfo:Release()
		selfinfo:Release()
		return false,130031 --"����ְλʧ��"
	end
	
	if(Player_Id == selfId) then
		playerinfo:Release()
		selfinfo:Release()
		return false,130032 --"�����޸��Լ���ְλ!"
	end
		
	if(selfinfo:GetData(0,0) ~= 1) then
		playerinfo:Release()
		selfinfo:Release()
		return false,130033 --"��û��Ȩ��"
	end
	if(1 == Identity) then --ת����ΪȺ��
		--�鿴���һ�������˶��ٸ�Ⱥ
		local groups = CFriendGroup.Get_GroupsId:ExecStat(Player_Id)
		if groups == nil then
			return false,130024 --"���ݿ����ʧ��!"
		end
	
		--�������Ⱥ�����Ѵﵽ����
		if(groups:GetData(0,0) >= 10) then  --�ж�����
			groups:Release()
			return false,5018 --"�Է�������Ⱥ�����Ѿ��ﵽ����!"
		end
	
		CFriendGroup.Set_Identity_Stmt:ExecStat(1,Player_Id,g_Id) --ת��Ⱥ�����
		if not (g_DbChannelMgr:LastAffectedRowNum()>0) then
			CancelTran()
			playerinfo:Release()
			selfinfo:Release()
			return false,130034 --"�Բ���,Ȩ��ת��ʧ��!"
		end
		
		CFriendGroup.Set_Identity_Stmt:ExecStat(3,selfId,g_Id) --��Ϊ��ͨ��Ա
		if not (g_DbChannelMgr:LastAffectedRowNum()>0) then
			CancelTran()
			playerinfo:Release()
			selfinfo:Release()
			return false,130034 --"�Բ���,Ȩ��ת��ʧ��!"
		end
	end
		
	--���ù���Ա
	if Identity == 2 then   --���ù���Ա
		--�鿴ָ����Ⱥ����Ĺ���Ա�ĸ���
		local admins = CFriendGroup.Get_AdminNum_Stmt:ExecStat(g_Id,2)
		--�жϹ���Ա����
		if( admins:GetData(0,0) >=3) then
			admins:Release()
			return false,130035 --"����Ա�������Ѿ��ﵽ����!"
		end
		admins:Release()
		
		if(playerinfo:GetData(0,0) == 2)	 then
			playerinfo:Release()
			selfinfo:Release()
			return false,130036 --"�Է��Ѿ��ǹ���Ա��!"
		end
		
		--���ù���Ա
		CFriendGroup.Set_Identity_Stmt:ExecStat(Identity,Player_Id,g_Id)
		playerinfo:Release()
		selfinfo:Release()
		return g_DbChannelMgr:LastAffectedRowNum()>0  
	end
	
	--ȡ������ԱȨ��
	if(Identity == 3) then
		--�ж��Ƿ��Ѿ��ǹ���Ա
		if(playerinfo:GetData(0,0) == 3)	 then
			playerinfo:Release()
			selfinfo:Release()
			return false,130037 --"�Է��Ѿ���ͨ��Ա��!"
		end
		
		CFriendGroup.Set_Identity_Stmt:ExecStat(Identity,Player_Id,g_Id)
		return g_DbChannelMgr:LastAffectedRowNum()>0
	end
	
	return true
end
------------------------------------------------------------------------------------------------- 
local StmtDef = {
		"Get_My_GroupId_Stmt",
		[[ select fg_uId from tbl_group_manager where cs_uId = ? ]]
}
DefineSql ( StmtDef, CFriendGroup )

--��ȡ���г�Ա
local StmtDef = {
		"Get_All_Members_Stmt",
		[[
		select 
			a.cs_uId,
			b.c_sName,
			a.gm_uIdentity,
			a.fg_uId,
			ifnull(co_uOnServerId,0)
		from
			tbl_group_manager a,
			tbl_char b
		left join 
			tbl_char_online c on b.cs_uId = c.cs_uId
		where 
			a.cs_uId = b.cs_uId and a.fg_uId in (select fg_uId from tbl_group_manager where cs_uId = ?)
		union
		select 
			a.cs_uId,
			b.cd_sName,
			a.gm_uIdentity,
			a.fg_uId,
			0
		from
			tbl_group_manager a,
			tbl_char_deleted b
		where 
			a.cs_uId = b.cs_uId and a.fg_uId in (select fg_uId from tbl_group_manager where cs_uId = ?)
		]]
}
DefineSql (StmtDef,CFriendGroup)

function FriendGroupDbBox.GetAllMembers(playerId)
	local result = CFriendGroup.Get_All_Members_Stmt:ExecStat(playerId,playerId)
	return result
end
----------------------------------------------------------------------------------------------------------
--��ȡ���г�Ա
local StmtDef = {
		"_GetOnlineGroupMembers",
		[[
		select 
			a.cs_uId,
			a.fg_uId
		from
			tbl_group_manager a,
			tbl_char_online b
		where 
			a.cs_uId = b.cs_uId and a.fg_uId in (select fg_uId from tbl_group_manager where cs_uId = ?)
		]]
}
DefineSql (StmtDef,CFriendGroup)

function FriendGroupDbBox.GetOnlineGroupMembers(playerId)
	local result = CFriendGroup._GetOnlineGroupMembers:ExecStat(playerId)

	return result
end
----------------------------------------------------------------------------------------------------------
--��ȡ���г�Ա
local StmtDef = {
		"_GetAllMembers_StmtByGroupId",
		[[
		select 
			a.cs_uId,
			b.c_sName,
			a.gm_uIdentity,
			a.fg_uId,
			ifnull(co_uOnServerId,0)
		from
			tbl_group_manager a,
			tbl_char b
		left join
			tbl_char_online c on b.cs_uId = c.cs_uId
		where 
			a.cs_uId = b.cs_uId and a.fg_uId = ?
		union
		select 
			a.cs_uId,
			b.cd_sName,
			a.gm_uIdentity,
			a.fg_uId,
			0
		from
			tbl_group_manager a,
			tbl_char_deleted b
		where 
			a.cs_uId = b.cs_uId and a.fg_uId = ?
		]]
}
DefineSql (StmtDef,CFriendGroup)

function FriendGroupDbBox.GetAllMembersByGroupId(groupid)
	local result = CFriendGroup._GetAllMembers_StmtByGroupId:ExecStat(groupid,groupid)
	return result
end
----------------------------------------------------------------------------------------------------------
--��ȡ��������������Ⱥ��Ϣ
--����Ⱥ���ƣ�����Ⱥ���ͣ�����Ⱥ��ǩ������Ⱥ����
local StmtDef = {
		"_GetGroupInfoStmt",
		[[
			select
				fg.fg_uId,fg.fg_sName,ifnull(fg.fg_uGroupKind,0),ifnull(fg.fg_sKeyWord,""),fg.fg_sAnnouncement,gm.gm_uRefuseMsgFlag
			from
				tbl_friends_group fg,tbl_group_manager gm
			where 
				fg.fg_uId = gm.fg_uId and gm.cs_uId = ?	
		]]
}
DefineSql (StmtDef,CFriendGroup)

--@brief  ��ȡ��ҵ����к�������
function FriendGroupDbBox.GetAllFriendsGroup(uCharId)
	local groupInfo = CFriendGroup._GetGroupInfoStmt:ExecStat(uCharId)
	return groupInfo
end
----------------------------------------------------------------------------------------------------------
local StmtDef = {
		"_Get_All_Group_Stmt",
		[[
			select
				fg.fg_uId,fg.fg_sName,ifnull(fg.fg_uGroupKind,0),ifnull(fg.fg_sKeyWord,""),fg.fg_sAnnouncement,gm.gm_uRefuseMsgFlag
			from
				tbl_friends_group fg,tbl_group_manager gm
			where 
				fg.fg_uId = gm.fg_uId and fg.fg_uId = ?	
		]]
}
DefineSql (StmtDef,CFriendGroup)

--@brief ���ݺ���ȺID��ȡ����Ⱥ������Ϣ
function FriendGroupDbBox.GetAllFriendsGroupById(groupid)
	local result = CFriendGroup._Get_All_Group_Stmt:ExecStat(groupid)
	return result
end
-----------------------------------------------------------------------------------------------------------
local StmtDef = {
		"Select_AddToGroupRequest",
		[[
			select rag_uManager,fg_uId from tbl_request_add_group where rag_uInvitee = ? and rag_uType = 2
		]]
}
DefineSql (StmtDef,CFriendGroup)

--@brief ���ߺ���ʾ������������Ⱥ����
--@param ra_uInvitee:��������Id
function FriendGroupDbBox.SendAddToGroupRequest(ra_uInvitee)
	local addGroupRequest = {}
	local ex = RequireDbBox("Exchanger")
	local requestList = CFriendGroup.Select_AddToGroupRequest:ExecStat(ra_uInvitee)
	if requestList ~= nil and requestList:GetRowNum() > 0 then
		for i = 1,requestList:GetRowNum()  do
			local addTbl = {}
			addTbl[1] = requestList:GetData(i-1,0)
			addTbl[2] = ex.getPlayerNameById(requestList:GetData(i-1,0))
			addTbl[3] = requestList:GetData(i-1,1)
			local group = CFriendGroup.Get_GroupInfo:ExecStat(requestList:GetData(i-1,1))
			local groupName = ""
			if group ~= nil and group:GetRowNum() > 0 then
				groupName = group:GetData(0,0)
			end
			addTbl[4] = groupName
			table.insert(addGroupRequest,addTbl)
		end
	end
	return addGroupRequest
end
-----------------------------------------------------------------------------------------------------------
local StmtDef = {
		"Select_AddToGroupRequestToManger",
		[[
			select rag_uInvitee,fg_uId from tbl_request_add_group where rag_uManager = ? and rag_uType = 1
		]]
}
DefineSql (StmtDef,CFriendGroup)

--@brief ���ߺ���ʾ����������Ⱥ����
--@param rag_uManager:����ԱId
function FriendGroupDbBox.SendAddToGroupRequestToManger(rag_uManager)
	local addGroupRequest = {}
	local ex = RequireDbBox("Exchanger")
	local requestList = CFriendGroup.Select_AddToGroupRequestToManger:ExecStat(rag_uManager)
	if requestList ~= nil and requestList:GetRowNum() > 0 then
		for i = 1,requestList:GetRowNum()  do
			local addTbl = {}
			addTbl[1] = requestList:GetData(i-1,0)
			addTbl[2] = ex.getPlayerNameById(requestList:GetData(i-1,0))
			addTbl[3] = requestList:GetData(i-1,1)
			table.insert(addGroupRequest,addTbl)
		end
	end

	return addGroupRequest
end
-----------------------------------------------------------------------------------------------------------
--����ȺID��Ⱥname
local StmtDef = {
		"Get_GroupInfo",
		[[ select fg_sName from tbl_friends_group where fg_uId = ? ]]
}
DefineSql (StmtDef,CFriendGroup)

--�鿴Ⱥ��������Ա
local StmtDef = {
		"Get_AdminInfo",
		[[ select cs_uId,gm_uIdentity from tbl_group_manager where fg_uId = ? ]]
}
DefineSql (StmtDef,CFriendGroup)
--��Ҫ�������Ⱥ������������
local StmtDef = {
		"Save_AddToGroupRequest",
		[[
			replace into tbl_request_add_group(rag_uManager,rag_uInvitee,fg_uId,rag_uType) values(?,?,?,?)
		]]
}
DefineSql (StmtDef,CFriendGroup)


--�鿴Ⱥ��������Ա
local StmtDef = {
		"_GetAdminInfo",
		[[ select cs_uId from tbl_group_manager where fg_uId = ? and gm_uIdentity <> 3 ]]
}
DefineSql (StmtDef,CFriendGroup)

--@brief �����Ⱥ
--@param playerId:���ID
--@param groupId:ȺID
function FriendGroupDbBox.AddFriendToGroup(data)
	local playerId = data["InvitorId"]
	local groupId = data["groupId"]
	local adminId = {}
	local group = CFriendGroup.Get_GroupInfo:ExecStat(groupId)
	if nil == group or group:GetRowNum() == 0 then
		return false,130038 --"��Ⱥ������!"
	end
	
	local playerinfo = CFriendGroup.Get_Member_Info_Stmt:ExecStat(playerId,groupId)
	if playerinfo ~= nil and playerinfo:GetRowNum() >0 then
		return false,130039 --"���Ѿ��Ǹ�Ⱥ�ĳ�Ա"
	end
	
	local adminInfo = CFriendGroup._GetAdminInfo:ExecStat(groupId)
	if nil == adminInfo or adminInfo:GetRowNum() == 0 then
		return false,130038 --"��Ⱥ������!"
	end
	
	local LoginServerSql = RequireDbBox("LoginServerDB")
	for i = 1,adminInfo:GetRowNum() do
		local manager_id = adminInfo:GetData(i-1,0)
		if LoginServerSql.IsPlayerOnLine(manager_id) then
			table.insert(adminId,manager_id)
		end
		CFriendGroup.Save_AddToGroupRequest:ExecStat(manager_id,playerId,groupId,1)
	end

	if #adminId == 0 then
		return false,130004
	end
	return true,adminId
end
----------------------------------------------------------------------------------------------------------
--ɾ���������Ⱥ������
local StmtDef = {
		"Delete_AddToGroupRequest",
		[[
			delete from tbl_request_add_group where rag_uManager = ? and rag_uInvitee = ? and fg_uId = ? and rag_uType = ?
		]]
}
DefineSql (StmtDef,CFriendGroup)
--@brief ��Ӧ�����������Ⱥ
--@param selfId:��׼���ID
--@param playerId���������ID
--@param groupId�����Ҫ�����ȺID
function FriendGroupDbBox.RespondAddPlayerToGroup(data)
	local selfId = data["selfId"]
	local playerId = data["playerId"]
	local groupId = data["groupId"]
	local index = data["index"] -- 1-ͬ�⣻2-�ܾ�
	CFriendGroup.Delete_AddToGroupRequest:ExecStat(selfId,playerId,groupId,1)
	if g_DbChannelMgr:LastAffectedRowNum() <= 0 then
		CancelTran()
		return false
	end
	if index == 2 then
		return false
	end
	
	local adminInfo = CFriendGroup.Get_AdminInfo:ExecStat(groupId)
	if nil == adminInfo or adminInfo:GetRowNum() == 0 then
		return false,130038 --"�Բ��𣬸�Ⱥ������!"
	end
	
	for i =1,adminInfo:GetRowNum() do
		if selfId == adminInfo:GetData(i-1,0) and adminInfo:GetData(i-1,1) == 3 then
			return false,130033 --"�Բ�����û��Ȩ��!"
		end
	end
	
	local playerinfo = CFriendGroup.Get_Member_Info_Stmt:ExecStat(playerId,groupId)
	if playerinfo ~= nil and playerinfo:GetRowNum()>0 then
		return false,130041 --"������Ѿ��Ǹ�Ⱥ�ĳ�Ա��!"
	end
	--�����Ⱥ������������
	CFriendGroup.Add_Member_Stmt:ExecStat(groupId,playerId,3)
	if g_DbChannelMgr:LastAffectedRowNum() <= 0 then
		CancelTran()
		return false,130030 --"��Ⱥ�б��������ʧ��!"
	end
	
	local ex = RequireDbBox("Exchanger")
	local playerName = ex.getPlayerNameById(playerId)
	
	local grouplist = {}
	--��ѯ��Ⱥ�Ļ�����Ϣ
	--����Ⱥ���ƣ�����Ⱥ���ͣ�����Ⱥ��ǩ������Ⱥ����
	local groupInfo = FriendGroupDbBox.GetAllFriendsGroupById(groupId)
	local m_memberlist = FriendGroupDbBox.GetAllMembersByGroupId(groupId)
	local LoginServerSql = RequireDbBox("LoginServerDB")
	local isOnline = LoginServerSql.IsPlayerOnLine(playerId)
	local b_flag
	if isOnline then
		b_flag = 1 --����
	else
		b_flag = 2 --����					
	end
	local data = {}
	data.playerId = playerId
	data.group_id = groupId
	Db2GasCall("AddMemberToFriendGroup", data)
	return true,playerName,groupInfo,m_memberlist,b_flag
end
----------------------------------------------------------------------------------------------------------
local StmtDef = {
		"Del_Member_Stmt",
		[[ delete from tbl_group_manager where cs_uId = ? and fg_uId = ? ]]
}
DefineSql (StmtDef, CFriendGroup)
--@brief ����
--@param playerId������Ա
--@param bekicker_id:Ҫ�޳������ID
--@param g_Id����Ҫ���޳���������ڵ�Ⱥ
function FriendGroupDbBox.DelMember(data)
	local playerId = data["playerId"]
	local bekicker_id = data["bekicker_id"]
	local g_Id = data["Group_Id"]
	if(playerId == bekicker_id) then --�ж��Ƿ��ǳ�Ա
		return false,130042 --"�����޳��Լ�!"
	end
	
	local selfinfo = CFriendGroup.Get_Member_Info_Stmt:ExecStat(playerId,g_Id)
	local playerinfo = CFriendGroup.Get_Member_Info_Stmt:ExecStat(bekicker_id,g_Id)
	
	if playerinfo == nil or selfinfo == nil or playerinfo:GetRowNum() == 0 or playerinfo:GetRowNum() == 0 then
		return false,130043 --"�޳�ʧ��!"
	end
	
	if selfinfo:GetData(0,0) == 1 or (selfinfo:GetData(0,0) == 2 and playerinfo:GetData(0,0) == 3) then
		CFriendGroup.Del_Member_Stmt:ExecStat(bekicker_id,g_Id) 
		if not (g_DbChannelMgr:LastAffectedRowNum()>0) then
			CancelTran()
			playerinfo:Release()
			selfinfo:Release()
			return false,130043 --"�޳�ʧ��!"
		else
			local data = {}
			data.bekicker_id = bekicker_id
			data.group_Id = g_Id
			Db2GasCall("DelMember", data)
			local memberSet = FriendGroupDbBox.GetMemberIdByGroupId(g_Id)
			return true,memberSet
		end
		
	end
	return false,130043 --"�޳�ʧ��!"
end
----------------------------------------------------------------------------------------------------------
--@brief �������
--@param playerId��������ID
--@param group_id��ȺID
--@param invitee_id����������ID
function FriendGroupDbBox.AddMemberInvite(data)
	local playerId = data["playerId"]
	local group_id = data["group_id"]
	local invitee_id = data["invitee_id"]
	local ex = RequireDbBox("Exchanger")
	
	local setting_box = RequireDbBox("GameSettingDB")
 	if setting_box.GetOneSettingInfo(invitee_id,3) ~= 1 then
 		return false, 130044 --"�Է������˾ܾ�Ⱥ���룡"
 	end
 	
	local selfInfo = CFriendGroup.Get_Member_Info_Stmt:ExecStat(playerId,group_id)
	if selfInfo:GetRowNum() == 0 or selfInfo:GetData(0,0) == 3 then					--���ǹ���Ա
		return false,130033 --"�Բ���,��û��Ȩ��!"
	end
	
	if(ex.getPlayerNameById(invitee_id) == "" ) then
		return false,130013 --"�Բ���,����Ҳ�����!"
	end
	
	local info = CFriendGroup.Get_Member_Info_Stmt:ExecStat(invitee_id,group_id)
	if(0 ~= info:GetRowNum()) then
		return false,130045 --"�Բ���,������Ѿ������Ⱥ!"
	end
	
	local group = CFriendGroup.Get_GroupInfo:ExecStat(group_id)
	if nil == group or group:GetRowNum() == 0 then
		return false,130038 --"��Ⱥ������!"
	end
	local groupname = group:GetData(0,0)
	
	local LoginServerSql = RequireDbBox("LoginServerDB")
	local isOnline = LoginServerSql.IsPlayerOnLine(invitee_id)
	CFriendGroup.Save_AddToGroupRequest:ExecStat(playerId,invitee_id,group_id,2)
	--�������߲����ߣ�������������
	if not isOnline then
		return false,130004
	end
	return true,groupname
end
-------------------------------------------------------------------------------------
--@brief �˳�Ⱥ
function FriendGroupDbBox.ExitGroupRequest(data)
	local playerId = data["playerId"]
	local groupid = data["group_id"]
	local succ,erroyMsg = FriendGroupDbBox.ExitFromGroup(playerId,groupid)
	if succ then
		local data = {}
		data.bekicker_id = playerId
		data.group_Id = groupid
		Db2GasCall("DelMember", data)
		local memberSet = FriendGroupDbBox.GetMemberIdByGroupId(groupid)
		return succ,memberSet
	end
	return succ,erroyMsg
end
------------------------------------------------------------------------------------------------------
--@brief ��Ⱥ
--@param playerId��Ҫ��Ⱥ�����ID
--@param g_Id��ȺID
function FriendGroupDbBox.ExitFromGroup(playerId,g_Id)
	assert(IsNumber(g_Id))
	local result = FriendGroupDbBox.SearchGroupById(g_Id)
	if(#result == 0) then
		return false,130038 --"��Ⱥ�Ѿ���������!"
	end
	
	local res = CFriendGroup.Get_Member_Info_Stmt:ExecStat(playerId,g_Id)
	if nil == res then
		return false,130046 --"���ݿ���������쳣!"
	end
	
	local num = res:GetRowNum()
	if num == 0 then
		return false,130047 --"�Բ������Ѿ��˳���Ⱥ!"
	end
	
	if res:GetData(0,0) == 1 or res:GetData(0,0) == 2 then
		return false,130048 --"�Բ���,���˳�Ⱥ֮ǰ����ת��Ȩ��!"
	end
	
	CFriendGroup.Del_Member_Stmt:ExecStat(playerId,g_Id)
	
	if g_DbChannelMgr:LastAffectedRowNum() > 0 then
		return true
	else
		return false,130049 --"�˳�Ⱥ�����쳣!"
	end
end
------------------------------------------------------------------------------------------------------------
--��Ӧ�������Ⱥ
function FriendGroupDbBox.AddToGroup(data)
	local playerId = data["playerId"]
	local group_id = data["group_id"]
	local inviterId = data["inviterId"]
	local index = data["index"] -- 1-ͬ�⣻2-�ܾ�
	CFriendGroup.Delete_AddToGroupRequest:ExecStat(inviterId,playerId,group_id,2)
	if g_DbChannelMgr:LastAffectedRowNum() <= 0 then
		CancelTran()
		return false
	end
	if index == 2 then
		return false
	end
	local playerGroupId = CFriendGroup.Get_My_GroupId_Stmt:ExecStat(playerId)
	if nil ~= playerGroupId and playerGroupId:GetRowNum() > 0 then
		for i = 1,playerGroupId:GetRowNum() do
			if group_id == playerGroupId:GetData(i-1,0) then
				return false,130039 --"�Բ������Ѿ������Ⱥ!"
			end
		end
	end
	
	local group = CFriendGroup.Get_GroupInfo:ExecStat(group_id)
	if nil == group or group:GetRowNum() == 0 then
		return false,130038 --"��Ⱥ������!"
	end
	
	--�����Ⱥ������������
	CFriendGroup.Add_Member_Stmt:ExecStat(group_id,playerId,3)
	if g_DbChannelMgr:LastAffectedRowNum() <= 0 then
		CancelTran()
		return false,130030 --"��Ⱥ�б��������ʧ��!"
	end
	
	local ex = RequireDbBox("Exchanger")
	local playerName = ex.getPlayerNameById(playerId)

	local grouplist = {}
	--��ѯ��Ⱥ�Ļ�����Ϣ
	--����Ⱥ���ƣ�����Ⱥ���ͣ�����Ⱥ��ǩ������Ⱥ����
	local groupinfo = FriendGroupDbBox.GetAllFriendsGroupById(group_id)
	local m_memberlist = FriendGroupDbBox.GetAllMembersByGroupId(group_id)
	
	local LoginServerSql = RequireDbBox("LoginServerDB")
	local isOnline = LoginServerSql.IsPlayerOnLine(playerId)
	local b_flag
	if isOnline then
		b_flag = 1 --����
	else
		b_flag = 2 --������
	end
	local data = {}
	data.group_id = group_id
	data.playerId = playerId
	Db2GasCall("AddMemberToFriendGroup", data)
	return true,playerName,groupinfo,m_memberlist,b_flag
end
----------------------------------------------------------------------------------------------------
function FriendGroupDbBox.DismissalGroup(data)
	local playerId = data["playerId"]
	local groupid = data["group_id"]
	
	local selfInfo = CFriendGroup.Get_Member_Info_Stmt:ExecStat(playerId,groupid)
	if nil ~= selfInfo and selfInfo:GetRowNum() == 0 then--���ǹ���Ա
		return false,130050 --"�����ڸ�Ⱥ��!"
	end
	if selfInfo:GetData(0,0) ~= 1 then
		return false,130033 --"�Բ���,��û��Ȩ��!"
	end
	
	local suc,errorcode = FriendGroupDbBox.AutoDismissal(playerId,groupid)
	if suc then
		local data = {}
		data.groupid = groupid
		Db2GasCall("DismissalGroup", data)
		
		return suc,errorcode
	end
	return suc,errorcode
end
----------------------------------------------------------------------------------------------------
local StmtDef = {
		"Del_Group_Stmt",
		[[ delete from tbl_friends_group where fg_uId = ? ]]
}
DefineSql (StmtDef, CFriendGroup)

local StmtDef = {
		"Delete_AddToGroupRequestByGroupId",
		[[
			delete from tbl_request_add_group where fg_uId = ?
		]]
}
DefineSql (StmtDef,CFriendGroup)

--@brief �Զ���ɢȺ
--@param playerId��Ⱥ��ID
--@param g_Id��ȺID
function FriendGroupDbBox.AutoDismissal(playerId,g_Id)
	assert(IsNumber(g_Id))
	local groupInfo = FriendGroupDbBox.SearchGroupById(g_Id)
	if nil == groupInfo and #groupInfo == 0 then
		return false,130038 --"��Ⱥ�Ѿ���������!"
	end
	
	CFriendGroup.Delete_AddToGroupRequestByGroupId:ExecStat(g_Id)
	
	local memberSet = FriendGroupDbBox.GetMemberIdByGroupId(g_Id)
		
	--ɾ��Ⱥ
	CFriendGroup.Del_Group_Stmt:ExecStat(g_Id)
	if not (g_DbChannelMgr:LastAffectedRowNum()>0) then
		CancelTran()
		return false
	end
	return true,memberSet
end
-----------------------------------------------------------------------------------------
local function ChangeGroupDeclare(groupid,groupannoun)
	local textFltMgr = CTextFilterMgr:new()
	if (not textFltMgr:IsValidMsg(groupannoun)) then
		return false,130028 --"Ⱥ����Ƿ�!"
	end
	
	if string.len(groupannoun)> 255 then
		return false,130052 --"�Բ���,�������Ⱥ�������!"
	end
	CFriendGroup.Change_GroupAnnouncement:ExecStat(groupannoun, groupid)
	if g_DbChannelMgr:LastAffectedRowNum()>0 then
		local memberSet = FriendGroupDbBox.GetMemberIdByGroupId(groupid)	
		return true,memberSet
	else
		return false
	end		
end

--@brief �޸�Ⱥ����
--@param groupid��ȺID
--@param groupannoun��Ⱥ���¹���
function FriendGroupDbBox.ChangeGroupDeclare(data)
	local groupid     = data["groupid"]
	local groupannoun = data["groupannoun"]
	local playerId = data["playerId"]
	
	local textFltMgr = CTextFilterMgr:new()
	if not groupannoun or textFltMgr:RemoveTab1(groupannoun) == "" then
		return false,5008 --Ⱥ���治��Ϊ�ա�
	end
	
	local selfInfo = CFriendGroup.Get_Member_Info_Stmt:ExecStat(playerId,groupid)
	if selfInfo:GetRowNum() == 0 then --���Ǹ�Ⱥ�ĳ�Ա
		return false,130050 --"�����ڸ�Ⱥ��!"
	end
	if selfInfo:GetData(0,0) ~= 1 then
		return false,130033 --"�Բ���,��û��Ȩ��!"
	end
	return ChangeGroupDeclare(groupid,groupannoun)
end

--------------------------------------------------------------------------------------------------------
--�鿴����ں���Ⱥ���浣�ε�ְλ
local StmtDef = {
		"SelectPlayerRoleInGroup",
		[[ 
		select
			fg_uId,gm_uIdentity
		from
			tbl_group_manager
		where
			cs_uId = ?
		]]
}
DefineSql (StmtDef, CFriendGroup)

--�Ӻ���Ⱥ���潫�����ɾ��
local StmtDef = {
		"DelCharIdFromGroupTable",
		[[ 
		delete
		from
			tbl_group_manager
		where
			cs_uId = ? and fg_uId = ?
		]]
}
DefineSql (StmtDef, CFriendGroup)

--�Ӻ���Ⱥ���潫�����ɾ��
local StmtDef = {
		"DelFriends",
		[[ 
		delete
		from
			tbl_player_friends
		where
			cs_uId = ?
		]]
}
DefineSql (StmtDef, CFriendGroup)

--�鿴Ⱥ��Ա
local StmtDef = {
		"Get_AdminInfoStmt",
		[[ select cs_uId from tbl_group_manager where fg_uId = ? and gm_uIdentity = ? and cs_uId <> ? limit 1]]
}
DefineSql (StmtDef,CFriendGroup)

local StmtDef = {
		"Get_CharName_by_CharID",
		[[	select cd_sName from tbl_char_deleted where cs_uId = ? 
		]]
}
DefineSql( StmtDef, CFriendGroup )

--@brief ɾ����ɫ��ʱ���������Ǻ���Ⱥ��Ⱥ������ôת��Ⱥ��
--@brief ���������Ǳ����ҵĺ��ѣ���ôɾ��������ҵ��������
--@param char_id:Ҫɾ���Ľ�ɫId

function FriendGroupDbBox.DelPlayerFromGroupAndClass(char_id,msg)
	--�鿴����Ƿ���������Ⱥ
	local playerRoleInfo = CFriendGroup.SelectPlayerRoleInGroup:ExecStat(char_id)
	
	local bFlag1,bFlag2 = false,false
	local new_adminId = nil
	
	if playerRoleInfo:GetRowNum() > 0 then
		local playerGroupInfo = playerRoleInfo:GetTableSet()
		for i = 1,playerRoleInfo:GetRowNum() do
			--����������ĳ��Ⱥ��Ⱥ������ô��Ȩ��ת�ø�����һ������Ա��û�й���Ա�Ļ�ת�ø���ͨ��Ա
			if playerGroupInfo(i,2) == 1 then
				--�鿴��Ⱥ����Ĺ���Ա
				local admins = CFriendGroup.Get_AdminInfoStmt:ExecStat(playerGroupInfo(i,1),2,char_id)
				local ex = RequireDbBox("Exchanger")
				local del_res = CFriendGroup.Get_CharName_by_CharID:ExecStat(char_id)
				local del_char = del_res:GetData(0,0)
				if admins:GetRowNum() > 0 then
					--ת��Ⱥ����ݸ�����Ա
					new_adminId = admins:GetData(0,0)
					CFriendGroup.Set_Identity_Stmt:ExecStat(1,new_adminId,playerGroupInfo(i,1)) --ת��Ⱥ�����
					if g_DbChannelMgr:LastAffectedRowNum() > 0 then
						bFlag1 = true
					end
					local new_manger = ex.getPlayerNameById(new_adminId)
					local str = del_char .. msg .. new_manger
					ChangeGroupDeclare(playerGroupInfo(i,1),str)
				else
					admins = CFriendGroup.Get_AdminInfoStmt:ExecStat(playerGroupInfo(i,1),3,char_id)
					if admins:GetRowNum() > 0 then
						new_adminId = admins:GetData(0,0)
						--ת��Ⱥ����ݸ���ͨ��Ա
						CFriendGroup.Set_Identity_Stmt:ExecStat(1,new_adminId,playerGroupInfo(i,1)) --ת��Ⱥ�����
						if g_DbChannelMgr:LastAffectedRowNum() > 0 then
							bFlag1 = true	
						end
						local new_manger = ex.getPlayerNameById(new_adminId)
						local str = del_char .. msg .. new_manger
						ChangeGroupDeclare(playerGroupInfo(i,1),str)
					end
				end
			else
				--�Ӻ���Ⱥ���潫�����ɾ��
				CFriendGroup.DelCharIdFromGroupTable:ExecStat(char_id,playerGroupInfo(i,1))
				bFlag2 = g_DbChannelMgr:LastAffectedRowNum() > 0
			end
		end
	end
	--ɾ���Լ��ĺ���
	CFriendGroup.DelFriends:ExecStat(char_id)
end
----------------------------------------------------------------------------------
function FriendGroupDbBox.GetFriendGroupId(char_id)
	local myGroupIdRes = CFriendGroup.Get_My_GroupId_Stmt:ExecStat(char_id)
	return myGroupIdRes
end
-----------------------------------------------------------------------------------
local StmtDef = {
		"_UpdateRefuseMsgFlag",
		[[	
			update tbl_group_manager set gm_uRefuseMsgFlag = ? where fg_uId = ? and cs_uId = ? 
		]]
}
DefineSql( StmtDef, CFriendGroup )

function FriendGroupDbBox.RefuseGroupMsgOrNot(data)
	local charId = data["charId"]
	local groupId = data["groupId"]
	local uRefuseOrNot = data["uRefuseOrNot"]
	CFriendGroup._UpdateRefuseMsgFlag:ExecStat(uRefuseOrNot,groupId,charId)
	return g_DbChannelMgr:LastAffectedRowNum() > 0
end
-------------------------------------------------------------------------------------
local StmtDef = {
		"_GetMemberIdByGroupId",
		[[ select cs_uId from tbl_group_manager where fg_uId = ? ]]
}
DefineSql ( StmtDef, CFriendGroup )

function FriendGroupDbBox.GetMemberIdByGroupId(groupid)
	local res = CFriendGroup._GetMemberIdByGroupId:ExecStat(groupid)
	return res
end

return FriendGroupDbBox
