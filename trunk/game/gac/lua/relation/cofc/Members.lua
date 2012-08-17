gac_require "relation/cofc/MembersInc"

--��ұ��߳��̻�
function Gas2Gac:RetKickOutCofCMember(Conn)

end

function Gas2Gac:RetGetCofCMembersInfoBegin(Conn)
	if not g_GameMain.m_CofCMemberWnd then
		g_GameMain.m_CofCMemberWnd = CreateCofCMemberWnd(g_GameMain)
	end
	g_GameMain.m_CofCMemberWnd.m_CurPlayerInfo 	= {}		--��¼�̻��Ա�б���Ϣ��tbl
	g_GameMain.m_CofCMemberWnd.m_MemberListTbl	= {}		--�����洢�̻��Ա��item�ؼ�
end

function Gas2Gac:RetGetCofCAppInfoBegin(Conn)
	g_GameMain.m_CofCMemberWnd.m_ApplicationInfo	= {}	--��¼��������̻������б���Ϣ��tbl
	g_GameMain.m_CofCMemberWnd.m_ApplicationListTbl	= {}	--�����洢��������ߵ�listctrl�е�item�ؼ�
end

--�����̻��Ա��嵱ǰ��Ա��Ϣ(��ɫid,��ɫ��,�̻��е�ְλ,�ȼ�,����,ְҵ,�������,״̬,����,����Ƿ�����)
function Gas2Gac:RetGetCurCofCMembersInfo(Conn, listId, playerName, pos, level, race, occupation, feeling, state, mood, beOnline)
	local node		=	{}
	node.ListId		=	listId
	node.PlayerName	=	playerName
	node.Pos		=	pos
	node.Level		=	level
	node.Race		=	race
	node.Occupation	=	occupation
	node.Feeling	=	feeling
	node.State		=	state
	node.Mood		=	mood
	node.BeOnline	=	beOnline
	table.insert(g_GameMain.m_CofCMemberWnd.m_CurPlayerInfo,node)
end

--�����̻��Ա����������������Ǽ���Ϣ
function Gas2Gac:RetGetCurCofCAppInfo(Conn, listId, playerName, level, race, occupation, introPlayer, description)
	local node  		=	{}
	node.ListId			=	listId
	node.PlayerName		=	playerName
	node.Level			=	level
	node.Race			=	race
	node.Occupation		=	occupation
	node.IntroPlayer	=	introPlayer
	node.Description	=	description
	table.insert(g_GameMain.m_CofCMemberWnd.m_ApplicationInfo,node)
end

--�����̻��Ա��嵱ǰ��Ա��Ϣ
function Gas2Gac:RetGetCofCMembersInfoEnd(Conn, totalPlayerNo)
	g_GameMain.m_CofCMemberWnd:ShowCofCMemberInfo( totalPlayerNo)
	
	g_GameMain.m_AssociationBase.m_tblCofCMember[2] = {}
	local tblCofCMemInfo = g_GameMain.m_CofCMemberWnd.m_CurPlayerInfo
	for i = 1, #tblCofCMemInfo do
		g_GameMain.m_AssociationBase.m_tblCofCMember[2][i] = {tblCofCMemInfo[i].PlayerName, tblCofCMemInfo[i].Level, tblCofCMemInfo[i].Feeling, tblCofCMemInfo[i].State, tblCofCMemInfo[i].ListId, tblCofCMemInfo[i].BeOnline} --{name, level, feeling, state, playerId, bOnline}
	end
	
	local assoListWnd = g_GameMain.m_AssociationWnd.m_AssociationListWnd
	if(assoListWnd) then
		assoListWnd:RetSetCofCListEnd()
	end
end

--�����̻��Ա�����������Ա��Ϣ
function Gas2Gac:RetGetCofCAppInfoEnd(Conn, totalAppNo)
	g_GameMain.m_CofCMemberWnd:ShowCofCAppInfo(totalAppNo)
end
------------------------------------------------------------------------------------------

--�����̻��Ա���
function CreateCofCMemberWnd(Parent)
	local wnd = CCofCMemberWnd:new()
	wnd:CreateFromRes("CofCMember",Parent)
	g_ExcludeWndMgr:InitExcludeWnd(wnd, 3, false, {g_GameMain.m_CofCMainWnd})
	wnd:ShowWnd(false)
	wnd:InitCofCMemberChild()
	
	return wnd
end

--��ʼ���̻��Ա����ӿؼ�
function CCofCMemberWnd:InitCofCMemberChild()
	self.m_CofCName			=	self:GetDlgChild("Name")
	self.m_CloseBtn			=	self:GetDlgChild("Close")
	self.m_CancelBtn		=	self:GetDlgChild("ShutDownBtn")
	self.m_RefuseBtn		=	self:GetDlgChild("RefuseBtn")				--�ܾ�����
	self.m_ChangePosBtn		=	self:GetDlgChild("ChangePosBtn")			--�޸�ְλ
	self.m_MemberList		=	self:GetDlgChild("MemberList")				--��Ա�б�
	self.m_ApplicationList	=	self:GetDlgChild("ApplicationList")			--�����б�
	self.m_ApproveBtn		=	self:GetDlgChild("ApproveBtn")				--���ܼ���
	self.m_KickOutBtn		=	self:GetDlgChild("KickOutBtn")				--����
	self.m_MemberNum1		=	self:GetDlgChild("MemberNum1")				--ӵ�г�Ա��Ŀ
	self.m_MemberNum2		=	self:GetDlgChild("MemberNum2")				--�����Ա��Ŀ
	
	self:EnableCofCModifyPlayerWnd(false)			--���������޸�ְλ���������ӿؼ���״̬Ϊ���ɵ��
	self:EnableCofCModifyAppWnd(false)
end


--�̻��Ա����¼���Ӧ����
function CCofCMemberWnd:OnCtrlmsg( Child, uMsgID, uParam1, uParam2 )
	if (uMsgID == BUTTON_LCLICK) then
	  	if(Child == self.m_CloseBtn or Child == self.m_CancelBtn) then 			--�رհ�ť
	  		self:ShowWnd(false)
	  	
	  	elseif(Child == self.m_KickOutBtn)    then 	
	  		local listId = self:GetClickedListId(self.m_MemberList)				
	  		local function callback(Context,Button)
				if(Button == MB_BtnOK) then
					Gac2Gas:KickOutCofCMember(g_Conn, listId)
				end
				return true
			end			
			if listId ~= nil then 
				self:EnableCofCModifyPlayerWnd(false)
				self.m_MsgBox = MessageBox( self, MsgBoxMsg(16009), BitOr( MB_BtnOK, MB_BtnCancel),callback)
				return 
			end
	  	
	  	elseif(Child == self.m_ChangePosBtn)      then	
	  		self:EnableCofCModifyPlayerWnd(false)																
	  		if self.m_CofCChagePosWnd == nil then
	  			self.m_CofCChagePosWnd = CreateCofCChangePosWnd(self)
	  		elseif self.m_CofCChagePosWnd:IsShow() == false then
	  			self.m_CofCChagePosWnd:ShowWnd(true)
	  		end
	  	
	  	elseif(Child == self.m_ApproveBtn)       then								
			local listId = self:GetClickedListId(self.m_ApplicationList)
			if listId ~= nil then 
				self:EnableCofCModifyAppWnd(false)
				Gac2Gas:ApproveJoinCofC(g_Conn, listId)
			end	  		
	  		
	  	elseif(Child == self.m_RefuseBtn) then						
			local listId = self:GetClickedListId(self.m_ApplicationList)
			if listId ~= nil then 
				self:EnableCofCModifyAppWnd(false)
				Gac2Gas:RefuseJoinCofC(g_Conn, listId)
			end
		end
	
	elseif( uMsgID == ITEM_LBUTTONCLICK ) then
		
		if (Child == self.m_MemberList) then							--��ѡ���ǳ�Ա�б��е�ĳ�����
			if g_GameMain.m_CofCMainWnd.m_selfOccu == "�᳤" or 
				g_GameMain.m_CofCMainWnd.m_selfOccu == "���᳤" then
				self:ClickPlayerList()
			else
				return
			end
		elseif (Child == self.m_ApplicationList) then					--��ѡ������������ĳ�����
			if g_GameMain.m_CofCMainWnd.m_selfOccu == "�᳤" or 
				g_GameMain.m_CofCMainWnd.m_selfOccu == "���᳤" then
				self:ClickApplicationList()	
			else
				return
			end
		end
	end
end

function CCofCMemberWnd:GetClickedListId(ListWnd)
	local index = self:GetSelectedItemOrder(ListWnd)
	if index == nil then
		return
	end

	if ListWnd == self.m_MemberList then	
		local listId = self.m_CurPlayerInfo[index].ListId 
		return listId
	elseif ListWnd == self.m_ApplicationList then
		local listId = self.m_ApplicationInfo[index].ListId 
		return listId
	end
end

--��ѡ���̻��Ա����е�ǰ��Ա���б����Ҫ������Ӧ�жϺ���Ӧ
function CCofCMemberWnd:ClickPlayerList()
	local index = self:GetSelectedItemOrder(self.m_MemberList)
	if index == nil then
		return
	end

	local playerPos = self.m_CurPlayerInfo[index].Pos
	if g_GameMain.m_CofCMainWnd.m_selfOccu == "�᳤" then
		self.m_ChangePosBtn:EnableWnd(true)
		if playerPos ~= "�᳤" then
			self.m_KickOutBtn:EnableWnd(true)
		else
			self.m_KickOutBtn:EnableWnd(false)
		end
		self.m_ChangePosBtn:EnableWnd(true)
		return
	else
		self:EnableCofCModifyPlayerWnd(false)	
	end
	if g_GameMain.m_CofCMainWnd.m_selfOccu == "���᳤" then
		if playerPos ~= "�᳤" then
			self.m_KickOutBtn:EnableWnd(true)
		else
			self.m_KickOutBtn:EnableWnd(false)
		end
		if playerPos ~= "�᳤" and	playerPos ~= "���᳤" then
			self.m_ChangePosBtn:EnableWnd(true)
		else
			self.m_ChangePosBtn:EnableWnd(false)
		end
		return
	else
		self:EnableCofCModifyPlayerWnd(false)	
	end
end

--��ѡ���̻��Ա�����������������б����Ҫ������Ӧ�жϺ���Ӧ
function CCofCMemberWnd:ClickApplicationList()
	local index = self:GetSelectedItemOrder(self.m_ApplicationList)
	if index ~= nil then
		self:EnableCofCModifyAppWnd(true)
	else
		self:EnableCofCModifyAppWnd(false)
	end
end

--���ݲ���canClick�������̻��Ա����е�ǰ��Ա���޸�ְλ�������Ӵ��ڵĿɵ�״̬
function CCofCMemberWnd:EnableCofCModifyPlayerWnd(canClick)
	self.m_ChangePosBtn:EnableWnd(canClick)
	self.m_KickOutBtn:EnableWnd(canClick)
end

--���ݲ���canClick�������̻��Ա����е�ǰ����������ң���׼���ܾ��Ӵ��ڵĿɵ�״̬
function CCofCMemberWnd:EnableCofCModifyAppWnd(canClick)
	self.m_RefuseBtn:EnableWnd(canClick)
	self.m_ApproveBtn:EnableWnd(canClick)
end

--��ʾ�̻��Ա���
function CCofCMemberWnd:ShowCofCMemberInfo(totalPlayerNo)
	local playerTblLen	=	table.getn(self.m_CurPlayerInfo )
	self.m_MemberNum1:SetWndText(playerTblLen .. "/" .. totalPlayerNo )
	self:ShowCurPlayerInfo()
end

function CCofCMemberWnd:ShowCofCAppInfo( totalAppNo)
	local appTblLen		=	table.getn(self.m_ApplicationInfo)
	self.m_MemberNum2:SetWndText(appTblLen .. "/" .. totalAppNo )
	self:ShowAppPlayerInfo()
end

--��ʾ��Ա�б���Ϣ
function CCofCMemberWnd:ShowCurPlayerInfo()
	local playerTbl =	self.m_CurPlayerInfo 
	self.m_MemberList:DeleteAllItem()
	for i=1, table.maxn( playerTbl ) do
		if ( i == 1 ) then
		  self.m_MemberList:InsertColumn( 0, self.m_MemberList:GetWndWidth())
		end
		self.m_MemberList:InsertItem( i-1, 25 )
		
		local playerItemWnd = SQRDialog:new()
		local item = self.m_MemberList:GetSubItem( i-1, 0)
		playerItemWnd:CreateFromRes( "CofCMemberItem", item )
		playerItemWnd:ShowWnd( true )
		playerItemWnd:SetStyle( 0x60000000 )
		playerItemWnd:GetDlgChild("PlayerName"):SetWndText(playerTbl[i].PlayerName)
		playerItemWnd:GetDlgChild("Pos"):SetWndText(playerTbl[i].Pos)
		playerItemWnd:GetDlgChild("Level"):SetWndText(playerTbl[i].Level .. "/" .. playerTbl[i].Race .. "/" ..playerTbl[i].Occupation)
		table.insert(self.m_MemberListTbl, playerItemWnd)
	end
end

--��ʾ������������Ϣ
function CCofCMemberWnd:ShowAppPlayerInfo()
	local appTbl	=	self.m_ApplicationInfo
	self.m_ApplicationList:DeleteAllItem()
	for i=1, table.maxn( appTbl ) do
		if ( i == 1 ) then
		  self.m_ApplicationList:InsertColumn( 0, self.m_ApplicationList:GetWndWidth())
		end
		self.m_ApplicationList:InsertItem( i-1, 25 )
		
		local appItemWnd = SQRDialog:new()
		local item = self.m_ApplicationList:GetSubItem( i-1, 0)
		appItemWnd:CreateFromRes( "CofCAppItem", item )
		appItemWnd:ShowWnd( true )
		appItemWnd:SetStyle( 0x60000000 )
		appItemWnd:GetDlgChild("PlayerName"):SetWndText(appTbl[i].PlayerName)
		appItemWnd:GetDlgChild("Level"):SetWndText(appTbl[i].Level .. "/" .. appTbl[i].Race .. "/" .. appTbl[i].Occupation)
		appItemWnd:GetDlgChild("IntroPlayer"):SetWndText(appTbl[i].IntroPlayer)
		appItemWnd:GetDlgChild("Desription"):SetWndText(appTbl[i].Description)
		table.insert(self.m_ApplicationListTbl, appItemWnd)
	end
end		


--�������ĸ������Ϣ��ѡ����
function CCofCMemberWnd:GetSelectedItemOrder(listWnd)
	local choosedItem = nil 
	choosedItem = listWnd:GetSelectItem( -1 ) + 1
  
	if choosedItem == 0 then
		return nil
	end
  
	return choosedItem
end

----------------------------------------------------------------------------------
--�����޸��̻��Աְλ���
function CreateCofCChangePosWnd(Parent)
	local wnd = CCreateCofCChangePosWnd:new()
	wnd:CreateFromRes("CofCChangePos",Parent)
	wnd:ShowWnd( true )
	wnd.m_CloseBtn		=	wnd:GetDlgChild("Close")
	wnd.m_CancelBtn		=	wnd:GetDlgChild("CancelBtn")
	wnd.m_NewPosText	=	wnd:GetDlgChild("NewPosText")
	wnd.m_OkBtn			=	wnd:GetDlgChild("OkBtn")
	g_ExcludeWndMgr:InitExcludeWnd(wnd, 3, false, {g_GameMain.m_CofCMemberWnd})
	return
end

function CCreateCofCChangePosWnd:OnCtrlmsg( Child, uMsgID, uParam1, uParam2 )
	if (uMsgID == BUTTON_LCLICK) then
		if Child == self.m_CloseBtn or Child == self.m_CancelBtn then
			self:ShowWnd(false)
		elseif Child == self.m_OkBtn then
			local newPos = self.m_NewPosText:GetWndText()
			if newPos == nil or newPos == "" then
				self.m_MsgBox = MessageBox( self, MsgBoxMsg(16010), MB_BtnOK )
				return
			end
			if g_GameMain.m_CofCMainWnd.m_selfOccu == "���᳤" and newPos == "���᳤" then
				self.m_MsgBox = MessageBox( self, MsgBoxMsg(16011), MB_BtnOK )
				return
			end
		
			self:ShowWnd(false)
			local listId = g_GameMain.m_CofCMemberWnd:GetClickedListId(g_GameMain.m_CofCMemberWnd.m_MemberList)
			if listId ~= nil then 
				Gac2Gas:ChangeCofCMemberPos(g_Conn, listId, newPos)
			end
		end
	end
end
