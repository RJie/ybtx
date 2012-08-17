gac_require "relation/association/AssociationBaseInc"

--[[
������ID��Լ��:"�ҵĺ���"��IDΪ1,"������"��IDΪ2
--]]

function CreateAssociationBase()
	local base = CAssociationBase:new()
	base:Init()
	return base
end

function CAssociationBase:Init()
	self.m_IsRecChatMsg = false --�Ƿ��¼������Ϣ
--	self.m_sChatMsgPath = string.gsub(g_RootPath, "/", "\\") .. "var\\gac\\cm"
--	os.execute("if not exist " .. self.m_sChatMsgPath .. " mkdir " .. self.m_sChatMsgPath)
	
	self.m_tblTongMember	= {{},{}}
	self.m_tblOpenRecord	= {}
	
	self:InitBlackList()
	self:InitFriend()
	self:InitGroup()
end

function CAssociationBase:InitFriend()
	self.m_tblFriendClassIndex				= {} --����ID��Ӧ����
	self.m_tblFriendListClass				= {} --������ĺ����б�{name, level, feeling, state, playerId, bOnline}
	self.m_tblFriendListClass[1]			= {}
	self.m_tblFriendListClass[1].className	= GetStaticTextClient(2006) --"�ҵĺ���"
	self.m_tblFriendListClass[1].classId	= 1
end

function CAssociationBase:InitBlackList()
	self.m_tblBlackList				= {} --�������б�
	self.m_tblBlackList.className	= GetStaticTextClient(2007) --"������" 
	self.m_tblBlackList.classId		= 2
end

function CAssociationBase:InitGroup()
	self.m_tblFriendGroupIndex	= {} --��ȺID��Ӧ����
	self.m_tblFriendGroup		= {} --����Ⱥ{ { {groupName, groupId, groupType, groupLable, groupDeclare, ctrlType}, {name, id, ctrlType, bOnline} }, ...} --ctrlType:1,������;2,����Ա;3,��ͨ��Ա
	self.m_tblCreateGroupIndex	= {} --�Լ�������Ⱥ������
	self.m_tblManageGroupIndex	= {} --�Լ��ǹ���Ա��ݵ�Ⱥ����
	self.m_RefuseGroupMsgGroupId = {} --����Ⱥ��Ϣ��Ⱥid
end

--�����Ƿ������������
function CAssociationBase:SortFriendListByBeOnline(classId)
	local tblFriendListClass		= self.m_tblFriendListClass
	local tblThisClassInfo			= tblFriendListClass[self.m_tblFriendClassIndex[classId]]
	tblThisClassInfo.nOnlineCount	= #(tblThisClassInfo)
	table.sort(tblThisClassInfo, function (a, b) return a.nOnline < b.nOnline end)
	for i, v in ipairs(tblThisClassInfo) do
		if(2 == v.nOnline) then
			tblThisClassInfo.nOnlineCount = i - 1
			break
		end
	end
end

--�����Ƿ���������ĳȺ����
function CAssociationBase:SortFriendGroupByBeOnline(groupId)
	local tblFriendGroup	= self.m_tblFriendGroup
	local tblThisGroupInfo	= tblFriendGroup[self.m_tblFriendGroupIndex[groupId]]
	table.sort(tblThisGroupInfo[2], function (a, b) return a[4] < b[4] end)
end

--�����趨������������
function CAssociationBase:ResetClassIndex()
	local tblFriendListClass	= self.m_tblFriendListClass
	self.m_tblFriendClassIndex	= {}
	for i = 1, #tblFriendListClass do
		self.m_tblFriendClassIndex[tblFriendListClass[i].classId] = i --һ������id�������Ķ�Ӧ��
	end
end

--�����趨����Ⱥ������
function CAssociationBase:ResetGroupIndex()
	local tblFriendGroup	= self.m_tblFriendGroup
	self.m_tblFriendGroupIndex	= {}
	self.m_tblCreateGroupIndex	= {}
	self.m_tblManageGroupIndex	= {}
	for i = 1, #tblFriendGroup do
		self.m_tblFriendGroupIndex[tblFriendGroup[i][1][2]] = i
		if(1 == tblFriendGroup[i][1][6]) then
			table.insert(self.m_tblCreateGroupIndex, i)
		elseif(2 == tblFriendGroup[i][1][6]) then
			table.insert(self.m_tblManageGroupIndex, i)
		end
	end
end

--�����趨����Ⱥ����Ȩ�ޱ�
function CAssociationBase:ResetCtrlTypeList()
	local tblFriendGroup	= self.m_tblFriendGroup
	self.m_tblCreateGroupIndex	= {}
	self.m_tblManageGroupIndex	= {}
	for i = 1, #tblFriendGroup do
		if(1 == tblFriendGroup[i][1][6]) then
			table.insert(self.m_tblCreateGroupIndex, i)
		elseif(2 == tblFriendGroup[i][1][6]) then
			table.insert(self.m_tblManageGroupIndex, i)
		end
	end
end

function CAssociationBase:ResetFriendGroupList()
	local wnd	= g_GameMain.m_AssociationWnd.m_AssociationListWnd
	if(2 == wnd.m_ListPage) then --����Ⱥ�б����
		wnd.m_tblList[2]:SetFriendGroupList()
	end
end

--���ؼ�Ϊ����
function CAssociationBase:RetAddFriendToClass(classId, playerId, playerName, level, nCamp, nClass, nTeamSize, sScene, nBeOnline, nTongId)
	local tblFriendListClass	= self.m_tblFriendListClass
	local classIndex			= self.m_tblFriendClassIndex[classId]
	local tblBlackMemList		= self.m_tblBlackList
	
	local tblInfo = {}
	tblInfo.playerId		= playerId
	tblInfo.playerName		= playerName
	tblInfo.playerLevel		= level
	tblInfo.nPlayerCamp		= nCamp
	tblInfo.nPlayerClass	= nClass
	tblInfo.nTeamSize		= nTeamSize
	tblInfo.sScene			= sScene
	tblInfo.nTongId			= nTongId
	tblInfo.nOnline			= nBeOnline
	
	table.insert(tblFriendListClass[classIndex], tblInfo)
	self:SortFriendListByBeOnline(classId)
	g_GameMain.m_AssociationWnd.m_AssociationListWnd.m_tblList[1].m_tblItemWnd[classIndex]:ResetItem()
	
	for i = 1, #tblBlackMemList do --������������д���,���
		if(playerId == tblBlackMemList[i].playerId) then
			table.remove(tblBlackMemList, i)
			local tblItem = g_GameMain.m_AssociationWnd.m_AssociationListWnd.m_tblList[1].m_tblItemWnd
			tblItem[#tblItem]:ResetItem()
			break
		end
	end
end

--����ɾ������/������ɾ��
function CAssociationBase:DeleteFriendById(playerId, classId)
	local tblFriendListClass	= self.m_tblFriendListClass
	local classIndex			= self.m_tblFriendClassIndex[classId]
	local tbl = tblFriendListClass[classIndex]
	for i, v in ipairs(tbl) do
		if(playerId == v.playerId) then
			table.remove(tbl, i)
			break
		end
	end
	self:SortFriendListByBeOnline(classId)
	g_GameMain.m_AssociationWnd.m_AssociationListWnd.m_tblList[1].m_tblItemWnd[classIndex]:ResetItem()
end

function CAssociationBase:AddBlackListByName(playerName)
	if(self:IsInBlackList(playerName)) then
		MsgClient(5001)
		return
	end
	local index, classId = self:SearchFriendInListByName(playerName)
	if(index) then
		local tblItem		= g_GameMain.m_AssociationWnd.m_AssociationListWnd.m_tblList[1].m_tblItemWnd
		local classIndex	= self.m_tblFriendClassIndex[classId]
		tblItem[classIndex]:PreMoveToBlackList({classId, index})
	else
		Gac2Gas:AddBlackListByName(g_Conn, playerName)
	end
end

function CAssociationBase:ReceivePrivateChatMsg(fromId, fromName, text, time)
	local tbl = g_GameMain.m_tblAssociationPriChat
	for i = 1, #tbl do
		local chatWnd = tbl[i]
		if(chatWnd.m_ChatWithId == fromId) then --�ͶԷ�����ĶԻ����Ѿ���
			chatWnd:AddNewLineInfoWithTime(fromName, text, time)
			g_GameMain.m_MsgListParentWnd.m_MsgListWnd:FlashOneItemByTypeAndId("˽��", fromId)
			return
		end
	end
	g_GameMain.m_MsgListParentWnd.m_MsgListWnd:InsertChatMsg("˽��", fromId, fromName, text, time)
end

--���������ߴ���
function CAssociationBase:NotifyFriendBeOnline(memberId, classId, beOnline)
	local classIndex			= self.m_tblFriendClassIndex[classId]
	local tblThisClassMemInfo	= self.m_tblFriendListClass[classIndex]
	for i = 1, #tblThisClassMemInfo do
		if(memberId == tblThisClassMemInfo[i].playerId) then
			tblThisClassMemInfo[i].nOnline = beOnline
			break
		end
	end
	self:SortFriendListByBeOnline(classId)
	g_GameMain.m_AssociationWnd.m_AssociationListWnd.m_tblList[1].m_tblItemWnd[classIndex]:ResetItem()
end

--Ⱥ��Ա�����ߴ���
function CAssociationBase:NotifyGroupMemberBeOnline(memberId, groupId, beOnline)
	local groupIndex			= self.m_tblFriendGroupIndex[groupId]
	local tblThisGroupMemInfo	= self.m_tblFriendGroup[groupIndex][2]
	for i = 1, #tblThisGroupMemInfo do
		if(memberId == tblThisGroupMemInfo[i][2]) then
			tblThisGroupMemInfo[i][4] = beOnline
			break
		end
	end
	self:SortFriendGroupByBeOnline(groupId)
	self:FindAndReDrawPubChatWnd(groupId)
end

--�뿪Ⱥ
function CAssociationBase:LeaveGroup(groupId)
	local tblFriendGroup	= self.m_tblFriendGroup
	local groupIndex		= self.m_tblFriendGroupIndex[groupId]
	table.remove(tblFriendGroup, groupIndex)
	self:ResetGroupIndex()
	self:ResetFriendGroupList()
	self:FindAndClosePubChatWnd(groupId)
	self:DeleteGroupCallInfo(groupId)
end

--���groupId�˴����,�͹ر�
function CAssociationBase:FindAndClosePubChatWnd(groupId)
	local tblPubChatWnd = g_GameMain.m_tblAssociationPubChat
	for i = 1, #tblPubChatWnd do
		if(groupId == tblPubChatWnd[i].m_GroupId) then
			tblPubChatWnd[i]:ShowWnd(false)
			break
		end
	end
end

--���groupId�˴����,��ˢ�³�Ա�б�
function CAssociationBase:FindAndReDrawPubChatWnd(groupId)
	local tblPubChatWnd = g_GameMain.m_tblAssociationPubChat
	for i = 1, #tblPubChatWnd do
		if(groupId == tblPubChatWnd[i].m_GroupId) then
			tblPubChatWnd[i]:DrawMemListItem()
			break
		end
	end
end

--�򿪳�Ա��岢��ʾ��Ա��Ϣ
function CAssociationBase:ShowPersonalInfo(context)
	local memberId, memberName = unpack(context)
	local tbl = g_GameMain.m_tblPerInfoShowWnd
	for i = 1, #tbl do
		if(memberId == tbl[i].m_MemberId) then
			return
		end
	end
	local wnd = CreateAssociationPersonalInfoShowWnd(g_GameMain, memberId, memberName)
	wnd.m_NameLable:SetWndText(memberName)
	wnd.m_IdLable:SetWndText("ID:" .. memberId)
	table.insert(tbl, wnd)
	Gac2Gas:GetAssociationMemberInfo(g_Conn, memberId)
end

--ɾ����Ⱥ��Ⱥ����Ϣ
function CAssociationBase:DeleteGroupMsgCallInfo(groupId)
	g_GameMain.m_MsgListParentWnd.m_MsgListWnd:CloseOne("Ⱥ��", groupId)
end

--ɾ����Ⱥ��������Ϣ
function CAssociationBase:DeleteGroupAppCallInfo(groupId)
	g_GameMain.m_MsgListParentWnd.m_MsgListWnd:CloseOne("����Ⱥ����", groupId)
end

--ɾ����Ⱥ��������Ϣ
function CAssociationBase:DeleteGroupCallInfo(groupId)
	self:DeleteGroupAppCallInfo(groupId)
	self:DeleteGroupMsgCallInfo(groupId)
end

--ɾ����id��������Ϣ
function CAssociationBase:DeletePriChatCallInfo(chatWithId)
	g_GameMain.m_MsgListParentWnd.m_MsgListWnd:CloseOne("˽��", groupId)
end

--ͨ�������ں��ѱ��в���
function CAssociationBase:SearchFriendInListByName(playerName)
	local tbl = self.m_tblFriendListClass
	for i, p in pairs(tbl) do
		for j, v in ipairs(p) do
			if(playerName == v.playerName) then
				return j, p.classId
			end
		end
	end
	return nil
end

--�ж��Ƿ��ں�������
function CAssociationBase:IsInBlackList(idOrName)
	if(IsNumber(idOrName)) then
		return self:IsInBlackListById(idOrName)
	else
		return self:IsInBlackListByName(idOrName)
	end
end

--ͨ���Է�ID�ж϶Է��Ƿ����Լ��ĺ�������
function CAssociationBase:IsInBlackListById(memberId)
	local blackList = self.m_tblBlackList
	for i = 1, #blackList do
		if(memberId == blackList[i].playerId) then
			return true
		end
	end
	return false
end

--ͨ���Է������ж϶Է��Ƿ����Լ��ĺ�������
function CAssociationBase:IsInBlackListByName(memberName)
	local blackList = self.m_tblBlackList
	for i = 1, #blackList do
		if(memberName == blackList[i].playerName) then
			return true
		end
	end
	return false
end

--��Ӻ���Ⱥ��Ա
function CAssociationBase:AddGroupMem(memberId, memberName, memberType, groupId, bOnline)
	local tblFriendGroup		= self.m_tblFriendGroup
	local tblGroupIndex			= self.m_tblFriendGroupIndex
	
	if(memberId == g_MainPlayer.m_uID) then
		tblFriendGroup[tblGroupIndex[groupId]][1][6] = memberType
		if(1 == memberType) then
			table.insert(self.m_tblCreateGroupIndex, tblGroupIndex[groupId])
		elseif(2 == memberType) then
			table.insert(self.m_tblManageGroupIndex, tblGroupIndex[groupId])
		end
	end
	table.insert(tblFriendGroup[tblGroupIndex[groupId]][2], {memberName, memberId, memberType, bOnline})
end

function CAssociationBase:AddGroupMemEnd(groupId)
	if(0 == groupId) then
		for k, v in pairs(self.m_tblFriendGroupIndex) do
			self:SortFriendGroupByBeOnline(k)
			self:FindAndReDrawPubChatWnd(k)
		end
	else
		self:SortFriendGroupByBeOnline(groupId)
		self:FindAndReDrawPubChatWnd(groupId)
	end
end

function CAssociationBase:RemoveChatRecord()
	local rootPath = string.gsub(g_RootPath, "/", "\\")
	os.execute("if exist " .. self.m_sChatMsgPath .. " rd /s/q " .. self.m_sChatMsgPath)
end

--�ӿͻ��˱����ļ��ж�ȡ�����ϵ����Ϣ
--[[
function CAssociationBase:ImportRecentContactInfo()
	local filePath = g_RootPath .. "var/gac/assolog/recentcontact/RecentContact.asv"
	local f = CLuaIO_Open(filePath, "r")
	f:Close()
end
--]]
----------------------------------------------------------------------------------------------------------

function Gas2Gac:ReturnInitAssociationInfo(Conn)
	g_GameMain.m_AssociationWnd.m_AssociationListWnd.m_tblList[1]:SetFriendList()
end

------���ѻ�������------
--���غ��ѷ��鿪ʼ
function Gas2Gac:ReturnGetAllFriendClassBegin(Conn)
	g_GameMain.m_AssociationBase:InitFriend()
	g_GameMain.m_AssociationBase:InitBlackList()
end

--���غ��ѷ���
function Gas2Gac:ReturnGetAllFriendClass(Conn, classId, className) --���������ҵĺ��ѡ�, �͡���������
	local base = g_GameMain.m_AssociationBase
	local tblFriendListClass = base.m_tblFriendListClass
	
	local tblInfo		= {}
	tblInfo.className	= className
	tblInfo.classId		= classId
	table.insert(tblFriendListClass, tblInfo)
end

--���غ��ѷ������
function Gas2Gac:ReturnGetAllFriendClassEnd(Conn)
	g_GameMain.m_AssociationBase:ResetClassIndex()
end

--�������к�����Ϣ(����������)
--������ID, ���ID, ����name, �ȼ�, ��Ӫ, ְҵ, С������, ���ڳ���, �Ƿ�����
function Gas2Gac:ReturnGetAllFriendInfo(Conn, classId, playerId, playerName, level, nCamp, nClass, nTeamSize, sScene, bOnline, nTongId)
	local base = g_GameMain.m_AssociationBase
	local tblBlackList			= base.m_tblBlackList
	local tblFriendListClass	= base.m_tblFriendListClass
	local tblClassIndex			= base.m_tblFriendClassIndex
	
	local tblInfo = {}
	tblInfo.playerId		= playerId
	tblInfo.playerName		= playerName
	tblInfo.playerLevel		= level
	tblInfo.nPlayerCamp		= nCamp
	tblInfo.nPlayerClass	= nClass
	tblInfo.nTeamSize		= nTeamSize
	tblInfo.sScene			= sScene
	tblInfo.nTongId			= nTongId
	tblInfo.nOnline			= bOnline
	if(2 == classId) then
		table.insert(tblBlackList, tblInfo)
	else
		table.insert(tblFriendListClass[tblClassIndex[classId]], tblInfo)
	end
end

--�������к�����Ϣ����(����������)
function Gas2Gac:ReturnGetAllFriendInfoEnd(Conn)
	local base = g_GameMain.m_AssociationBase
	for k, v in pairs(base.m_tblFriendClassIndex) do
		base:SortFriendListByBeOnline(k)
	end
--	print("----------���Ѽ������----------")
end

--ˢ��ָ��������Ϣ
function Gas2Gac:ReturnUpdateFriendInfo(Conn, classId, level, nTeamSize, sScene, nFriendId, nTongId)
	local base			= g_GameMain.m_AssociationBase
	local classIndex	= base.m_tblFriendClassIndex[classId]
	local tblForThisOne	= base.m_tblFriendListClass[classIndex]
	for i, v in ipairs(tblForThisOne) do
		if( v.playerId == nFriendId ) then
			v.playerLevel	= level
			v.nTeamSize		= nTeamSize
			v.sScene		= sScene
			v.nTongId		= nTongId
			break
		end
	end
	g_GameMain.m_AssociationWnd.m_AssociationListWnd.m_tblList[1].m_tblItemWnd[classIndex]:ResetItemInfoById(nFriendId)
end

--ˢ�����ߺ�����Ϣ
function Gas2Gac:ReturnUpdateOnlineFriendInfo(Conn, classId, playerId, level, nTeamSize, sScene, nTongId)
	local base					= g_GameMain.m_AssociationBase
	local tblFriendListClass	= base.m_tblFriendListClass
	local tblClassIndex			= base.m_tblFriendClassIndex
	
	local classIndex			= tblClassIndex[classId]
	local tblForThisOne			= tblFriendListClass[classIndex]
	for i, v in ipairs(tblForThisOne) do
		if( v.playerId == playerId ) then
			v.playerLevel	= level
			v.nTeamSize		= nTeamSize
			v.sScene		= sScene
			v.nTongId		= nTongId
			break
		end
	end
end

--���鷵�غ���ʵʱ��Ϣ����(ֻˢ��Ӧ��)
function Gas2Gac:ReturnUpdateOnlineFriendInfoClassEnd(Conn, classId)
	local tblClassIndex	= g_GameMain.m_AssociationBase.m_tblFriendClassIndex
	local classIndex	= tblClassIndex[classId]
	g_GameMain.m_AssociationWnd.m_AssociationListWnd.m_tblList[1].m_tblItemWnd[classIndex]:ResetItemInfoOnline()
end

--��������
function Gas2Gac:NotifyFriendOnline(Conn, classId, memberId)
	if g_GameMain.m_AssociationWnd.m_bNotInitBefore then
		return
	end
	if(2 == classId) then return end --����Ǻ�������Ա�ͷ���
	g_GameMain.m_AssociationBase:NotifyFriendBeOnline(memberId, classId, 1)
end

--��������
function Gas2Gac:NotifyFriendOffline(Conn, classId, memberId)
	if g_GameMain.m_AssociationWnd.m_bNotInitBefore then
		return
	end
	if(2 == classId) then return end --����Ǻ�������Ա�ͷ���
	g_GameMain.m_AssociationBase:NotifyFriendBeOnline(memberId, classId, 2)
end

--������Ӻ�����
function Gas2Gac:ReturnAddFriendClass(Conn, bFlag, classId, className)
	if(bFlag) then
		local base = g_GameMain.m_AssociationBase
		local tblInfo		= {}
		tblInfo.className	= className
		tblInfo.classId		= classId
		table.insert(base.m_tblFriendListClass, tblInfo)
		g_GameMain.m_AssociationBase:ResetClassIndex()
	end
	g_GameMain.m_AssociationWnd.m_AssociationListWnd.m_tblList[1]:SetFriendList()
end

------�������------
--���ؾ�ȷ�������
function Gas2Gac:ReturnSearchPlayer(Conn, id, name, level, bOnline)
	local context	= {id, name, level, bOnline}
	local tbl		= g_GameMain.m_AssociationFindWnd.m_AssociationRetFindPlayerWnd.m_tblBeFoundPlayerInfo
	table.insert(tbl, context)
end

--���ؾ�ȷ������ҽ���
function Gas2Gac:ReturnSearchPlayerEnd(Conn)
	g_GameMain.m_AssociationFindWnd.m_AssociationRetFindPlayerWnd:ShowWnd(true)
	g_GameMain.m_AssociationFindWnd.m_AssociationRetFindPlayerWnd:DrawPlayerList()
end

------�Ժ��Ѳ���------
--������Ӻ���
function Gas2Gac:ReturnAddFriendToClass(Conn, classId, playerId, playerName, level, nCamp, nClass, nTeamSize, sScene, nBeOnline,nTongId)
	if g_GameMain.m_AssociationWnd.m_bNotInitBefore then
		return
	end
	g_GameMain.m_AssociationBase:RetAddFriendToClass(classId, playerId, playerName, level, nCamp, nClass, nTeamSize, sScene, nBeOnline,nTongId)
end

--�õ���Ϊ���ѵ�����
function Gas2Gac:ReturnInviteToBeFriend(Conn, sInviterName, nJoinClassId, nInviterId)
	if( g_GameMain.m_AssociationBase:IsInBlackList(nInviterId) ) then
		return
	end
	g_GameMain.m_MsgListParentWnd.m_MsgListWnd:CreateFriendInvMsgMinimum(nInviterId, sInviterName, nJoinClassId)
end

--����ɾ������
function Gas2Gac:ReturnDeleteMyFriend(Conn, bFlag, nFriendId, nClassId)
	if(bFlag) then
		g_GameMain.m_AssociationBase:DeleteFriendById(nFriendId, nClassId)
	end
end

--������ɾ��
function Gas2Gac:ReturnBeDeleteByFriend(Conn, playerId, classId)
	if g_GameMain.m_AssociationWnd.m_bNotInitBefore then
		return
	end
	g_GameMain.m_AssociationBase:DeleteFriendById(playerId, classId)
end

--�����ƶ���������
function Gas2Gac:ReturnMoveToBlackList(Conn, bFlag)
	if(bFlag) then
		if(g_GameMain.m_AssociationBase.RetMoveToBlackList) then
			g_GameMain.m_AssociationBase:RetMoveToBlackList()
		end
	end
end

--������ӵ�������
function Gas2Gac:ReturnAddToBlackList(Conn, playerId, bFlag, playerName)
	if( not bFlag or g_GameMain.m_AssociationWnd.m_bNotInitBefore ) then
		return
	end
	local base = g_GameMain.m_AssociationBase
	local tblItem = g_GameMain.m_AssociationWnd.m_AssociationListWnd.m_tblList[1].m_tblItemWnd
	
	local tblInfo = {}
	tblInfo.playerId		= playerId
	tblInfo.playerName		= playerName
	tblInfo.playerLevel		= 0
	tblInfo.nPlayerCamp		= nil
	tblInfo.nPlayerClass	= nil
	tblInfo.nTeamSize		= 0
	tblInfo.sScene			= ""
	tblInfo.nOnline			= 2
	table.insert(base.m_tblBlackList, tblInfo)
	
	tblItem[#tblItem]:ResetItem()
end

--�����ƶ�����
function Gas2Gac:ReturnChangeToClass(Conn, bFlag)
	if(bFlag) then
		g_GameMain.m_AssociationBase:RetChangeToClass()
	end
end

--����ɾ����
function Gas2Gac:ReturnDeleteFriendClass(Conn, bFlag, nClassId)
	local base		= g_GameMain.m_AssociationBase
	local index		= base.m_tblFriendClassIndex[nClassId]
	local tblFriend	= base.m_tblFriendListClass[index]
	
	for i = 1, #(tblFriend) do
		table.insert(base.m_tblFriendListClass[1], tblFriend[i])
	end
	table.remove(base.m_tblFriendListClass, index)
	base:ResetClassIndex()
	base:SortFriendListByBeOnline(1)
	g_GameMain.m_AssociationWnd.m_AssociationListWnd.m_tblList[1]:SetFriendList()
end

--����������������
function Gas2Gac:ReturnRenameFriendClass(Conn, bFlag, nClassId, sNewName, sOldName)
	local base		= g_GameMain.m_AssociationBase
	local index		= base.m_tblFriendClassIndex[nClassId]
	local tblFriend	= base.m_tblFriendListClass[index]
	local listWnd	= g_GameMain.m_AssociationWnd.m_AssociationListWnd
	
	if bFlag then
		tblFriend.className = sNewName
	end
	if(1 == listWnd.m_ListPage) then
		local titleWnd	= listWnd.m_tblList[1].m_tblItemWnd[index]
		titleWnd:ResetTitle()
	end
end

--����ɾ����������Ա
function Gas2Gac:ReturnDeleteBlackListMem(Conn, bFlag, blackMemID)
	if(bFlag) then
		local tbl = g_GameMain.m_AssociationBase.m_tblBlackList
		local tblItem = g_GameMain.m_AssociationWnd.m_AssociationListWnd.m_tblList[1].m_tblItemWnd
		for i, v in ipairs(tbl) do
			if( v.playerId == blackMemID ) then
				table.remove(tbl, i)
				tblItem[#tblItem]:ResetItem()
			end
		end
	end
end

------����------
--˽����Ϣ
function Gas2Gac:PrivateChatReceiveMsg(Conn, fromId, fromName, text)
	g_GameMain.m_AssociationBase:ReceivePrivateChatMsg(fromId, fromName, text)
end

function Gas2Gac:ReceiveSendOfflineMsg(Conn, fromId, fromName, time, text) --���id��������ơ�����Ϣ��ʱ�䡢����
	g_GameMain.m_AssociationBase:ReceivePrivateChatMsg(fromId, fromName, text, time)
end

function Gas2Gac:ReturnGetMemberIdbyNameForPrivateChat(Conn, memberId, memberName, str)
	local wnd = g_GameMain.m_AssociationWnd:CreateAssociationPriChatWnd(memberId, memberName)
	if(wnd and "" ~= str) then
		wnd:SendMsg(str)
	end
end

--Ⱥ����Ϣ
function Gas2Gac:PublicChatReceiveMsg(Conn, groupId, playerName, text)
	if(g_GameMain.m_AssociationBase.m_RefuseGroupMsgGroupId[groupId] ~= 0) then return end
	local wnd = g_GameMain.m_AssociationWnd:FindAssociationPubChatWndByGroupId(groupId)
	if(wnd) then
		wnd:AddNewLineInfoWithTime(playerName, text)
		g_GameMain.m_MsgListParentWnd.m_MsgListWnd:FlashOneItemByTypeAndId("Ⱥ��", groupId)
	else
		g_GameMain.m_MsgListParentWnd.m_MsgListWnd:InsertChatMsg("Ⱥ��", groupId, playerName, text)
	end
end

--*************************************************************************************************
--����Ⱥ
--*************************************************************************************************
--���غ���Ⱥ�鿪ʼ
function Gas2Gac:ReturnGetAllFriendGroupBegin(Conn)
	g_GameMain.m_AssociationBase:InitGroup()
end

--���غ���Ⱥ��
function Gas2Gac:ReturnGetAllFriendGroup(Conn, groupId, groupName, groupType, groupLable, groupDeclare,uRefuseMsgFlag)
	local base = g_GameMain.m_AssociationBase
	table.insert(base.m_tblFriendGroup, {{groupName, groupId, groupType, groupLable, groupDeclare}, {}})
	base.m_RefuseGroupMsgGroupId[groupId] = uRefuseMsgFlag
end

--���غ���Ⱥ�����
function Gas2Gac:ReturnGetAllFriendGroupEnd(Conn)
	g_GameMain.m_AssociationBase:ResetGroupIndex()
end

--�������к���Ⱥ�ĳ�Ա��Ϣ
function Gas2Gac:ReturnGetAllGroupMemInfo(Conn, memberId, memberName, memberType, groupId, bOnline)
	g_GameMain.m_AssociationBase:AddGroupMem(memberId, memberName, memberType, groupId, bOnline)
end

--�������к���Ⱥ�ĳ�Ա��Ϣ����
function Gas2Gac:ReturnGetAllGroupMemInfoEnd(Conn, groupId)
	if g_GameMain.m_AssociationWnd.m_bNotInitBefore then
		return
	end
	g_GameMain.m_AssociationBase:AddGroupMemEnd(groupId)
end

function Gas2Gac:ReturnAddGroupMem(Conn, memberId, memberName, memberType, groupId, bOnline)
	if g_GameMain.m_AssociationWnd.m_bNotInitBefore then
		return
	end
	g_GameMain.m_AssociationBase:AddGroupMem(memberId, memberName, memberType, groupId, bOnline)
	g_GameMain.m_AssociationBase:AddGroupMemEnd(groupId)
end

--�յ���ͬ��������Ⱥ����Ϣ����
function Gas2Gac:ReturnRequestJoinIntoFriendGroupEnd(Conn)
	local base = g_GameMain.m_AssociationBase
	base:ResetFriendGroupList()
end

--����������Ⱥ
function Gas2Gac:BeInviteToGroupEnd(Conn)
	local base = g_GameMain.m_AssociationBase
	base:ResetFriendGroupList()
end

--���ش�������Ⱥ
function Gas2Gac:ReturnCreateFriendGroup(Conn, groupId)
	if(0 == groupId) then
		MsgClient(5002)
	else
		g_GameMain.m_AssociationBase:RetCreateFriendGroup(groupId)
		g_GameMain.m_AssociationBase.m_RefuseGroupMsgGroupId[groupId] = 0
	end
end

--�����޸�Ⱥ����
function Gas2Gac:ReturnChangeGroupDeclare(Conn, groupId, groupDeclare)
	if g_GameMain.m_AssociationWnd.m_bNotInitBefore then
		return
	end
	local base				= g_GameMain.m_AssociationBase
	local tblFriendGroup	= base.m_tblFriendGroup
	local tblGroupIndex		= base.m_tblFriendGroupIndex
	local groupIndex		= tblGroupIndex[groupId]
	tblFriendGroup[groupIndex][1][5] = groupDeclare
	
	local wnd = g_GameMain.m_AssociationWnd:FindAssociationPubChatWndByGroupId(groupId)
	if(wnd) then
		wnd.m_DeclareRichText:SetWndText(groupDeclare)
	end
end

--�������ÿ���/�ر�Ⱥ��Ϣ
function Gas2Gac:ReturnRefuseGroupMsgOrNot(Conn,groupId,uRefuseOrNot)
	g_GameMain.m_AssociationBase.m_RefuseGroupMsgGroupId[groupId] = uRefuseOrNot
end

--�յ���Ⱥ����
function Gas2Gac:RecevieRequestJoinIntoFriendGroup(Conn, nInviterId, sInviterName, nGroupId)
	if( g_GameMain.m_AssociationBase:IsInBlackList(nInviterId) ) then
		return
	end
	g_GameMain.m_MsgListParentWnd.m_MsgListWnd:CreateFriendGroAppMsgMinimum(nInviterId, sInviterName, nGroupId)
end

--�յ���Ⱥ����
function Gas2Gac:ReceiveInviteToGroup(Conn, inviterId, inviterName, groupId, groupName)
	if( g_GameMain.m_AssociationBase:IsInBlackList(inviterId) ) then
		return
	end
	g_GameMain.m_MsgListParentWnd.m_MsgListWnd:CreateFriendGroInvMsgMinimum(inviterId, inviterName, groupId, groupName)
end

--�����뿪Ⱥ
function Gas2Gac:ReturnLeaveGroup(g_Conn, groupId)
	local base = g_GameMain.m_AssociationBase
	base:LeaveGroup(groupId)
	base:DeleteGroupMsgCallInfo(groupId)
end

--�յ����߳�Ⱥ����Ϣ
function Gas2Gac:ReceiveBeKickOutOfGroup(g_Conn, groupId)
	if g_GameMain.m_AssociationWnd.m_bNotInitBefore then
		return
	end
	local base = g_GameMain.m_AssociationBase
	base:LeaveGroup(groupId)
	base:DeleteGroupMsgCallInfo(groupId)
end

--�յ�ĳ����뿪Ⱥ
function Gas2Gac:ReceiveMemberLeaveGroup(Conn, memberId, groupId)
	if g_GameMain.m_AssociationWnd.m_bNotInitBefore then
		return
	end
	local base				= g_GameMain.m_AssociationBase
	local tblFriendGroup	= base.m_tblFriendGroup
	local tblGroupIndex		= base.m_tblFriendGroupIndex
	local groupIndex		= tblGroupIndex[groupId]
	local tbl = tblFriendGroup[groupIndex][2]
	for i = 1, #tbl do
		if(tbl[i][2] == memberId) then
			table.remove(tbl, i)
			base:ResetFriendGroupList()
			break
		end
	end
	base:FindAndReDrawPubChatWnd(groupId)
end

--�յ���ɢȺ����Ϣ
function Gas2Gac:ReturnDisbandGroup(Conn, groupId)
	if g_GameMain.m_AssociationWnd.m_bNotInitBefore then
		return
	end
	local base				= g_GameMain.m_AssociationBase
	local tblFriendGroup	= base.m_tblFriendGroup
	local tblGroupIndex		= base.m_tblFriendGroupIndex
	local groupIndex		= tblGroupIndex[groupId]
	table.remove(tblFriendGroup, groupIndex)
	base:ResetGroupIndex()
	base:ResetFriendGroupList()
	base:FindAndClosePubChatWnd(groupId)
	base:DeleteGroupCallInfo(groupId)
end

--�յ�����ĳ��Ȩ�޵���Ϣ
function Gas2Gac:ReturnSetCtrlType(Conn, memberId, groupId, ctrlType)
	if g_GameMain.m_AssociationWnd.m_bNotInitBefore then
		return
	end
	local base				= g_GameMain.m_AssociationBase
	local tblFriendGroup	= base.m_tblFriendGroup
	local tblGroupIndex		= base.m_tblFriendGroupIndex
	local groupIndex		= tblGroupIndex[groupId]
	local tbl = tblFriendGroup[groupIndex][2]
	if(1 == ctrlType) then --�����ת��Ⱥ��, ����ɾ��ԭ����Ⱥ����¼
		for i = 1, #tbl do
			if(1 == tbl[i][3]) then
				tbl[i][3] = 3
				break
			end
		end
		if(1 == tblFriendGroup[groupIndex][1][6] and memberId ~= g_MainPlayer.m_uID) then
			tblFriendGroup[groupIndex][1][6] = 3
			base:ResetCtrlTypeList()
		end
	end
	for i = 1, #tbl do
		if(memberId == tbl[i][2]) then
			tbl[i][3] = ctrlType
			break
		end
	end
	if(memberId == g_MainPlayer.m_uID) then
		tblFriendGroup[groupIndex][1][6] = ctrlType
		base:ResetCtrlTypeList()
	end
	base:FindAndReDrawPubChatWnd(groupId)
end

--��������֪ͨ����Ⱥ��Ա
function Gas2Gac:NotifyFriendGroupOnline(Conn, memberId, groupId)
	if g_GameMain.m_AssociationWnd.m_bNotInitBefore then
		return
	end
	g_GameMain.m_AssociationBase:NotifyGroupMemberBeOnline(memberId, groupId, 1)
end

--��������֪ͨ����Ⱥ��Ա
function Gas2Gac:NotifyFriendGroupOffline(Conn, memberId, groupId)
	if g_GameMain.m_AssociationWnd.m_bNotInitBefore then
		return
	end
	g_GameMain.m_AssociationBase:NotifyGroupMemberBeOnline(memberId, groupId, 2)
end

------���Һ���Ⱥ------
--���ؾ�ȷ���Һ�����
function Gas2Gac:ReturnSearchGroup(Conn, id, name, masterName)
	local context	= {id, name, masterName}
	local tbl		= g_GameMain.m_AssociationFindWnd.m_AssociationRetFindGroupWnd.m_tblBeFoundGroupInfo
	table.insert(tbl, context)
end

--���ؾ�ȷ���Һ��������
function Gas2Gac:ReturnSearchGroupEnd(Conn)
	g_GameMain.m_AssociationFindWnd.m_AssociationRetFindGroupWnd:ShowWnd(true)
	g_GameMain.m_AssociationFindWnd.m_AssociationRetFindGroupWnd:DrawGroupList()
end

-----������Ϣ------
--�����Լ��ĸ�����Ϣ
function Gas2Gac:ReturnGetAssociationPersonalInfo(Conn, mood, showSen, strInterest, bodyShape, personality, makeFriendsState, style, detail)
	local context = {mood, showSen, strInterest, bodyShape, personality, makeFriendsState, style, detail}
	local personalInfoWnd = g_GameMain.m_AssociationPersonalInfoWnd
	if(personalInfoWnd) then--���������Ϣ������,��ˢ�¸�����Ϣ���
		personalInfoWnd:ShowInfo(context)
	end
	g_GameMain.m_AssociationWnd:ChangePersonalInfo(showSen)
end

--���ر��������Ϣ�ɹ�
function Gas2Gac:ReturnSaveAssociationPersonalInfo(Conn)
	g_GameMain.m_AssociationPersonalInfoWnd:CallBackFuncChangePersonalInfo()
end

--[[
mood              --����               I
showSen           --����               s
class             --ְҵ               I
level             --�ȼ�               I
tongName          --Ӷ����             s
cofcName          --�̻�               s
location          --���������򣨵�ͼ�� I
strInterest       --��Ȥ               s
bodyShape         --����               I
personality       --����               I
makeFriendsState  --����״̬           I
style             --����               I
detail			--����˵��				s
--]]

--����ĳ��ҵĸ�����Ϣ
function Gas2Gac:ReturnGetAssociationMemberInfo(Conn, memberId, mood, showSen, class, level, tongName, cofcName, location, strInterest, bodyShape, personality, makeFriendsState, style, detail)
	local ClassStr = g_GameMain.m_DisplayCommonObj:GetPlayerClassForShow(class)
	local context = {mood, showSen, ClassStr, level, tongName, cofcName, location,
					strInterest, bodyShape, personality, makeFriendsState, style, detail}
	local tbl = g_GameMain.m_tblPerInfoShowWnd
	for i = 1, #tbl do
		if(memberId == tbl[i].m_MemberId) then
			tbl[i]:ShowInfo(context)
			break
		end
	end
end

--�����޸��������
function Gas2Gac:ReturnChangeShowSentence(Conn, bFlag, sNewSen)
	g_GameMain.m_AssociationWnd:RetChangeShowSen(bFlag, sNewSen)
end
