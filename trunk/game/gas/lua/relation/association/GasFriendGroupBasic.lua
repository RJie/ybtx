
local FriendGroupDB = "FriendGroupDB"
CGasFriendGroupBasic = class()
---------------------------------------------------------------------------------------------
--@brief ��������Ⱥ
--@param groupname��Ⱥ����
--@param groupkind��Ⱥ����
--@param keyword���ؼ���
--@param groupannoun��Ⱥ����
function CGasFriendGroupBasic.CreateFriendGroup(Conn,groupname,groupkind,keyword,groupannoun)
	local player = Conn.m_Player
	if not IsCppBound(player) then
		return
	end
	
	local data = {
								["playerId"] = player.m_uID,
								["groupname"] = groupname,
								["groupkind"] = groupkind,
								["keyword"] = keyword,
								["groupannoun"] = groupannoun
								}
								

	local function CallBack(succ,count,groupid )
		if not suc and nil ~= count and count ~= 0 and IsNumber(count) then
			MsgToConn(Conn,count)
		end
		if succ then
			Gas2Gac:ReturnCreateFriendGroup(Conn, groupid)
			local friendGroupMsgSender = g_App:GetMultiMsgSender()
			g_FriendGroupMultiMsgSenderTbl[groupid] = friendGroupMsgSender
			g_FriendGroupMultiMsgSenderTbl[groupid]:AddPipe(Conn)
		end
	end
	--local FriendGroupDB = (g_DBTransDef["FriendGroupDB"])
	CallAccountManualTrans(Conn.m_Account, FriendGroupDB, "CreateFriendGroup", CallBack, data)
end
---------------------------------------------------------------------------------------------
local function SetAdminRequest(Conn,succ,errorcode,member_Id,group_Id,ctrlType)
	if succ then
		for i = 1,errorcode:GetRowNum() do
			Gas2GacById:ReturnSetCtrlType(errorcode(i,1),member_Id,group_Id,ctrlType)
		end
	elseif not succ and IsNumber(errorcode) then
		MsgToConn(Conn,errorcode)
	end
end
--@brief ����/ȡ������Ա
--@param Member_Id��Ҫ���õ����ID
--@param Group_Id������ȺID
--@param ctrlType��Ҫ���õ���� 1--Ⱥ��ת��Ȩ�� ��2--���ù���Ա��3--ȡ������ԱȨ��
function CGasFriendGroupBasic.SetCtrlType(Conn,Member_Id,Group_Id,ctrlType)
	local player = Conn.m_Player
	if not IsCppBound(player) then
		return
	end
	local data = {
								["playerId"] = player.m_uID,
								["Group_Id"] = Group_Id,
								["Member_Id"] = Member_Id,
								["type"] = ctrlType
							 }
	local function callback( succ,errorcode)
		SetAdminRequest(Conn,succ,errorcode,Member_Id,Group_Id,ctrlType)
	end
	
	--local FriendGroupDB = (g_DBTransDef["FriendGroupDB"])
	CallAccountManualTrans(Conn.m_Account, FriendGroupDB, "SetAdminRequest", callback, data,Group_Id)
end
---------------------------------------------------------------------------------------------
--@brief ��ȷ���Һ���Ⱥ
--@param f_name:����name
--@param f_id:����ID
function CGasFriendGroupBasic.SearchGroupAccurately(Conn,friendGroupName,friendGroupId)
	local data = {
								["friendGroupId"] = friendGroupId,
								["friendGroupName"] = friendGroupName
								}

	local function CallBack(result)
		if nil ~= result and #result > 0 then
			--���͵���ȺID��Ⱥ���ƣ�Ⱥ��
			for i = 1,#result do
				Gas2Gac:ReturnSearchGroup(Conn, result[i][1],result[i][2],result[i][3])
			end
		end
		Gas2Gac:ReturnSearchGroupEnd(Conn)
	end
	
	--local FriendGroupDB = (g_DBTransDef["FriendGroupDB"])
	CallAccountManualTrans(Conn.m_Account, FriendGroupDB, "SearchFriendGroupAccurately", CallBack, data)
end
------------------------------------------------------------------------------------------------
--@brief �������Һ���Ⱥ
--@param keyword:�ؼ���
--@param groupkind:Ⱥ���
function CGasFriendGroupBasic.SearchGroupCondition(Conn,keyword,groupkind)
	local data = {
								["keyword"] = keyword,
								["groupkind"] = groupkind
								}
	local function CallBack(result)
		if result:GetRowNum() > 0 then
			--���͵���ȺID��Ⱥ���ƣ�Ⱥ��
			local resultTbl = result:GetTableSet()
			for i= 1,result:GetRowNum() do
				Gas2Gac:ReturnSearchGroup(Conn, resultTbl(i,1),resultTbl(i,2),resultTbl(i,3))
			end
		end
		Gas2Gac:ReturnSearchGroupEnd(Conn)
	end
	
	--local FriendGroupDB = (g_DBTransDef["FriendGroupDB"])
	CallAccountManualTrans(Conn.m_Account, FriendGroupDB, "SearchFriendGroupByRequest", CallBack, data)
end
------------------------------------------------------------------------------------------------
--@brief ����������Ⱥ
--@param groupId:���ѽ�Ҫ����ĺ���ȺID
function CGasFriendGroupBasic.RequestJoinIntoFriendGroup(Conn,groupId)
	local player = Conn.m_Player
	if not IsCppBound(player) then
		return
	end
	local data = {
								["InvitorId"] = player.m_uID,
								["groupId"] = groupId
								}
	local function CallBack(succ,errorMsg)
		if succ then
			if errorMsg ~= nil and IsTable(errorMsg) then
				for i = 1,#errorMsg do
					--Ⱥ��/����ԱID��Ҫ��������name��ȺID��Ҫ��������ID
					Gas2GacById:RecevieRequestJoinIntoFriendGroup(errorMsg[i],player.m_uID, player.m_Properties:GetCharName(),groupId)
				end
			end
		else
			if nil ~= errorMsg and IsNumber(errorMsg) then
				MsgToConn(Conn,errorMsg)
			end
		end
	end

	--local FriendGroupDB = (g_DBTransDef[FriendGroupDB])
	CallAccountManualTrans(Conn.m_Account, "FriendGroupDB", "AddFriendToGroup", CallBack, data,groupId)
end
-----------------------------------------------------------------------------------------------------
local function ResponseRequestJoinGroup(Conn,succ,playerName,grouplist,m_memberlist,InvitorId,groupId,isOnline)
	if succ then
		--�������߷��͸ú���Ⱥ�Ļ�����Ϣ
		if grouplist:GetRowNum() > 0 then
			--����Ⱥ��ţ�����Ⱥ���ƣ�����Ⱥ���ͣ�����Ⱥ��ǩ������Ⱥ����
			local tbl = grouplist:GetTableSet()
			Gas2GacById:ReturnGetAllFriendGroup(InvitorId, tbl(1,1),tbl(1,2),tbl(1,3),tbl(1,4),tbl(1,5),tbl(1,6))
			Gas2GacById:ReturnGetAllFriendGroupEnd(InvitorId)
		end
		--�������߷��͸�Ⱥ�����г�Ա
		if m_memberlist:GetRowNum() > 0 then
			--���ID,���name,���ְλ��ʶ(1:Ⱥ����2:����Ա(���ֻ������)��3:��ͨ��Ա),
			--�������ȺID,����ǲ�������(1--���ߣ�2--����)
			for i = 1,m_memberlist:GetRowNum() do
				local uOnline = 2
				if m_memberlist(i,5) ~= 0 then
					uOnline = 1
				end
				Gas2GacById:ReturnGetAllGroupMemInfo(InvitorId, m_memberlist(i,1),m_memberlist(i,2),
				m_memberlist(i,3),m_memberlist(i,4),uOnline)

				if InvitorId ~= m_memberlist(i,1) then
					Gas2GacById:ReturnAddGroupMem(m_memberlist(i,1), InvitorId,playerName,3,groupId,isOnline)
				end
			end
			Gas2GacById:ReturnGetAllGroupMemInfoEnd(InvitorId,groupId)
			Gas2GacById:ReturnRequestJoinIntoFriendGroupEnd(InvitorId)
		end
	else
		if nil ~= playerName and IsNumber(playerName) then
			MsgToConn(Conn,playerName)
		end
	end
end

--@brief ͬ�����Ⱥ
--@param InvitorId:Ҫ����Ⱥ����ҵ�ID
--@param groupId:ȺID
function CGasFriendGroupBasic.ResponseRequestJoinGroup(Conn, InvitorId,groupId,index)
	local player = Conn.m_Player
	if not IsCppBound(player) then
		return
	end
	
	local data = {
								["selfId"] = player.m_uID,
								["playerId"] = InvitorId,
								["groupId"] = groupId,
								["index"] = index
								}
	local function CallBack(succ,playerName,grouplist,m_memberlist,b_flag)
		ResponseRequestJoinGroup(Conn,succ,playerName,grouplist,m_memberlist,InvitorId,groupId,b_flag)
	end

	--local FriendGroupDB = (g_DBTransDef[FriendGroupDB])
	CallAccountManualTrans(Conn.m_Account, "FriendGroupDB", "RespondAddPlayerToGroup", CallBack, data,groupId)
end
-----------------------------------------------------------------------------------------------------
--Ⱥ��
local function GroupChatRequest(Conn,group_id,message)
	local textFltMgr = CTextFilterMgr:new()
	--ȥ��ǰ��ո�
	message = textFltMgr:RemoveTab1(message)
	--�á�**���滻���в��Ϸ��ַ�
	message = textFltMgr:ReplaceInvalidChar(message)
	local sender = Conn.m_Player
	if g_FriendGroupMultiMsgSenderTbl[group_id] then
		g_FriendGroupMultiMsgSenderTbl[group_id]:DelPipe(Conn)
		Gas2Gac:PublicChatReceiveMsg(g_FriendGroupMultiMsgSenderTbl[group_id],group_id,sender.m_Properties:GetCharName(),message)
		g_FriendGroupMultiMsgSenderTbl[group_id]:AddPipe(Conn)
	end
	for _, otherServerConn in pairs(g_OtherServerConnList) do
		Gas2GasCall:PublicChatSendMsgDef(otherServerConn, group_id,sender.m_Properties:GetCharName(),message)
	end
end
--@brief Ⱥ��
--@param Group_id:ȺId
--@param text:���������
function CGasFriendGroupBasic.PublicChatSendMsg(Conn,group_id,text)
	local player = Conn.m_Player
	if not IsCppBound(player) then
		return
	end
	GroupChatRequest(Conn,group_id,text)
end
-----------------------------------------------------------------------------------------------------

local function KickMemberRequest(Conn,succ,errorcode,bekicker_id,group_id)
	if not succ and IsNumber(errorcode) then
		MsgToConn(Conn,errorcode)
	else
		Gas2GacById:ReceiveBeKickOutOfGroup( bekicker_id, group_id)
		for i = 1,errorcode:GetRowNum() do
			if errorcode(i,1) ~= bekicker_id then
				Gas2GacById:ReceiveMemberLeaveGroup(errorcode(i,1),bekicker_id,group_id)
			end
		end		
	end
end
--@brief ����
--@param Group_Id:ȺID
--@param Member_Id��Ҫ�߳������ID
function CGasFriendGroupBasic.KickOutOfGroup(Conn,Member_Id,Group_Id)
	local player = Conn.m_Player
	if not IsCppBound(player) then
		return
	end
	local data = {
								["playerId"] = player.m_uID,
								["Group_Id"] = Group_Id,
								["bekicker_id"] = Member_Id
							 }
	local function callback( succ,errorcode)
		KickMemberRequest(Conn,succ,errorcode,Member_Id,Group_Id)
	end

	--local FriendGroupDB = (g_DBTransDef["FriendGroupDB"])
	CallAccountManualTrans(Conn.m_Account, FriendGroupDB, "DelMember", callback, data,Group_Id)
end
-----------------------------------------------------------------------------------------------------
local function AddMemberInvite(Conn,succ,groupname,groupId,inviteeId)
	if succ and groupname ~= nil then
		Gas2GacById:ReceiveInviteToGroup(inviteeId,Conn.m_Player.m_uID,Conn.m_Player.m_Properties:GetCharName(),groupId,groupname)	
	elseif not succ then
		if nil ~= groupname and IsNumber(groupname) then
			MsgToConn(Conn,groupname)
		end
	end
end

--@brief �������
--@param Group_Id��ȺID
--@param Player_Id������������ID
function CGasFriendGroupBasic.InviteToGroup(Conn,inviteeId, groupId)
	local player = Conn.m_Player
	if not IsCppBound(player) then
		return
	end
	
	local data = {
								["playerId"] = player.m_uID,
								["group_id"] = groupId,
								["invitee_id"] = inviteeId
							 }
	local function callback(succ,groupname)
		AddMemberInvite(Conn,succ,groupname,groupId,inviteeId)
	end
	--local FriendGroupDB = (g_DBTransDef["FriendGroupDB"])
	CallAccountManualTrans(Conn.m_Account, FriendGroupDB, "AddMemberInvite", callback, data,groupId) 
end
----------------------------------------------------------------------------------------------------------
local function ExitGroupRequest(Conn,succ,errorcode,groupid)
	if not succ and IsNumber(errorcode) then
		MsgToConn(Conn,errorcode)
	else
		if IsCppBound(Conn) then
			Gas2GacById:ReturnLeaveGroup( Conn.m_Player.m_uID,groupid)
		end
		for i = 1,errorcode:GetRowNum() do
			if errorcode(i,1) ~= Conn.m_Player.m_uID then
				Gas2GacById:ReceiveMemberLeaveGroup(errorcode(i,1),Conn.m_Player.m_uID,groupid)
			end
		end
	end
end

--@brief �˳�Ⱥ
--@param Group_Id��ȺID
function CGasFriendGroupBasic.LeaveGroup(Conn,Group_Id)
	local player = Conn.m_Player
	if not IsCppBound(player) then
		return
	end
	local data = {
								["playerId"] = player.m_uID,
								["group_id"] = Group_Id
							 }
	local function callback(succ,errorcode)
		ExitGroupRequest(Conn,succ,errorcode,Group_Id)
	end
	--local FriendGroupDB = (g_DBTransDef["FriendGroupDB"])
	CallAccountManualTrans(Conn.m_Account, FriendGroupDB, "ExitGroupRequest", callback, data,Group_Id) 
end

-------------------------------------------------------------------------------------------------------
local function AddToGroup(Conn,succ,playerName,grouplist,m_memberlist,groupId,isOnline)
	if succ then
		--�������߷��͸ú���Ⱥ�Ļ�����Ϣ
		if grouplist:GetRowNum() > 0 then
			--����Ⱥ��ţ�����Ⱥ���ƣ�����Ⱥ���ͣ�����Ⱥ��ǩ������Ⱥ����
			if nil ~= g_GetPlayerInfo(Conn.m_Player.m_uID) then
				local tbl = grouplist:GetTableSet()
				Gas2Gac:ReturnGetAllFriendGroup(Conn, tbl(1,1),tbl(1,2),tbl(1,3),tbl(1,4),tbl(1,5),tbl(1,6))
				Gas2Gac:ReturnGetAllFriendGroupEnd(Conn)
			end
		end
		
		--�������߷��͸�Ⱥ�����г�Ա
		if m_memberlist:GetRowNum() > 0 then
			--���ID,���name,���ְλ��ʶ(1:Ⱥ����2:����Ա(���ֻ������)��3:��ͨ��Ա),
			--�������ȺID,����ǲ�������(1--���ߣ�2--����)
			if nil ~= g_GetPlayerInfo(Conn.m_Player.m_uID) then
				for i = 1,m_memberlist:GetRowNum() do
					local uOnline = 2
					if m_memberlist(i,5) ~= 0 then
						uOnline = 1
					end
					Gas2Gac:ReturnGetAllGroupMemInfo(Conn, m_memberlist(i,1),m_memberlist(i,2),
					m_memberlist(i,3),m_memberlist(i,4),uOnline)
					
					if Conn.m_Player.m_uID ~= m_memberlist(i,1) then
						Gas2GacById:ReturnAddGroupMem(m_memberlist(i,1), Conn.m_Player.m_uID,playerName,3,groupId,isOnline)
					end
				end
				Gas2Gac:ReturnGetAllGroupMemInfoEnd(Conn,groupId)
				Gas2Gac:ReturnRequestJoinIntoFriendGroupEnd(Conn)
			end
		end
	else
		if nil ~= playerName and IsNumber(playerName) then
			MsgToConn(Conn,playerName)
		end
	end
end
--@brief ��Ӧ�������Ⱥ
--@param Group_Id:ȺID
function CGasFriendGroupBasic.ResponseInviteToGroup(Conn,Group_Id,inviterId,index)
	local player = Conn.m_Player
	if not IsCppBound(player) then
		return
	end
	local data = {
								["playerId"] = player.m_uID,
								["group_id"] = Group_Id,
								["inviterId"] = inviterId,
								["index"] = index
								}
	local function callback(succ,playerName,groupinfo,m_memberlist,isOnline)
		AddToGroup(Conn,succ,playerName,groupinfo,m_memberlist,Group_Id,isOnline)
	end
	--local FriendGroupDB = (g_DBTransDef["FriendGroupDB"])
	CallAccountManualTrans(Conn.m_Account, FriendGroupDB, "AddToGroup", callback, data,Group_Id) 
end
-------------------------------------------------------------------------------------------------------
local function DismissalGroup(Conn,suc,errorcode,Group_Id)
	if suc then
		for i = 1,errorcode:GetRowNum() do
			Gas2GacById:ReturnDisbandGroup(errorcode(i,1),Group_Id)
		end
	elseif not suc and IsNumber(errorcode) then
		MsgToConn(Conn,errorcode)
	end
end

--@brief ��ɢȺ
--@param Group_Id:ȺID
function CGasFriendGroupBasic.DisbandGroup(Conn,Group_Id)
	local player = Conn.m_Player
	if not IsCppBound(player) then
		return
	end
	local data = {
								["playerId"] = player.m_uID,
								["group_id"] = Group_Id
							 }
	local function callback(suc,errorcode)
		DismissalGroup(Conn,suc,errorcode,Group_Id)
	end
	--local FriendGroupDB = (g_DBTransDef["FriendGroupDB"])
	CallAccountManualTrans(Conn.m_Account, FriendGroupDB, "DismissalGroup", callback, data,Group_Id) 
end
-------------------------------------------------------------------------------------------------------
--@brief �޸�Ⱥ����
--@param groupannoun���µ�Ⱥ����
function CGasFriendGroupBasic.ChangeGroupDeclare(Conn, groupid, groupannoun)
	local data = {
								["playerId"] = Conn.m_Player.m_uID,
								["groupid"]    = groupid,
								["groupannoun"] = groupannoun
							 }
	local function CallBack(succ,memberIdTbl)
		if succ then
			for i = 1,memberIdTbl:GetRowNum() do
				Gas2GacById:ReturnChangeGroupDeclare(memberIdTbl(i,1),groupid, groupannoun)
			end
		else
			if IsNumber(memberIdTbl) then
				MsgToConn(Conn,memberIdTbl)
			end
		end
	end
	
	CallAccountManualTrans(Conn.m_Account, FriendGroupDB, "ChangeGroupDeclare", CallBack, data,groupid)
end

-------------------------------------------------------------------------------------------------
--@brief ����/���κ���Ⱥ��Ϣ
--@param groupId:Ⱥid
--@param uRefuseOrNot�������������εı�ʶ
function CGasFriendGroupBasic.RefuseGroupMsgOrNot(Conn,groupId,uRefuseOrNot)
	local data = {
								["charId"] = Conn.m_Player.m_uID,
								["groupId"] = groupId,
								["uRefuseOrNot"] = uRefuseOrNot
								}
	local function CallBack(succ)
		if succ then
			Gas2Gac:ReturnRefuseGroupMsgOrNot(Conn,groupId,uRefuseOrNot)
		end
	end
								
	CallAccountManualTrans(Conn.m_Account, FriendGroupDB, "RefuseGroupMsgOrNot", CallBack, data,groupid)
end

---------------------------------------------------------------
function CGasFriendGroupBasic.PublicChatSendMsgDef(Conn, group_id,senderName,message)
	if g_FriendGroupMultiMsgSenderTbl[group_id] then
		Gas2Gac:PublicChatReceiveMsg(g_FriendGroupMultiMsgSenderTbl[group_id],group_id,senderName,message)
	end
end
----------------------------------------------------------------
--@brief ��Ⱥ����ӳ�Ա
function CGasFriendGroupBasic.AddMemberToFriendGroup(data)
	local groupId = data.group_id
	local playerId = data.playerId
	--���Ⱥ��������ҷ��ͱ������ߵĻ�����Ϣ
	local Invitor = g_GetPlayerInfo(playerId)
	if not g_FriendGroupMultiMsgSenderTbl[groupId] then
		local friendGroupMsgSender = g_App:GetMultiMsgSender()
		g_FriendGroupMultiMsgSenderTbl[groupId] = friendGroupMsgSender
	end
	if IsCppBound(Invitor) then
		g_FriendGroupMultiMsgSenderTbl[groupId]:AddPipe(Invitor.m_Conn)
	end
end

--@brief ��ɢȺ
function CGasFriendGroupBasic.DismissalGroup(data)
	local groupid = data.groupid
	if g_FriendGroupMultiMsgSenderTbl[groupid] then
		g_FriendGroupMultiMsgSenderTbl[groupid]:Release()
		g_FriendGroupMultiMsgSenderTbl[groupid] = nil
	end
end

--@brief ����
function CGasFriendGroupBasic.DelMember(data)
	local bekicker_id = data.bekicker_id
	local group_id = data.group_Id
	local bekicker = g_GetPlayerInfo(bekicker_id)
	if g_FriendGroupMultiMsgSenderTbl[group_id] then
		if IsCppBound(bekicker) then
			g_FriendGroupMultiMsgSenderTbl[group_id]:DelPipe(bekicker.m_Conn)
		end
	end
end


