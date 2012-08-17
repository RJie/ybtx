gac_require "relation/cofc/CofCNpcDialogInc"
gac_require "relation/cofc/CofCMain"

--׼���ӷ���˵õ��ϻ��б���Ϣ����ʼ���������
function Gas2Gac:RetOpenCofCNpcDialogBegin(Conn)
	if g_GameMain.CofCNpcDialogWnd == nil then
		g_GameMain.m_CofCNpcDialogWnd = CreateCofCNpcDialog(g_GameMain)
		g_GameMain.m_CofCNpcDialogWnd:ShowWnd(true)
	elseif g_GameMain.m_CofCNpcDialogWnd:IsShow() == false then
		g_GameMain.m_CofCNpcDialogWnd:ShowWnd(true)
	end
	g_GameMain.m_CofCNpcDialogWnd.m_CofCListTbl 	= {}
	g_GameMain.m_CofCNpcDialogWnd.m_CofCListItemTbl = {}
end

--���̻��б�
function Gas2Gac:RetOpenCofCNpcDialog(Conn, cofcId, cofcName, memberNo)
	local node 		= 	{}
	node.CofCId		=	cofcId
	node.CofCName 	= 	cofcName
	node.MemberNo	=	memberNo
	
	table.insert(g_GameMain.m_CofCNpcDialogWnd.m_CofCListTbl, node)
end

--���̻��б�������ڿͻ�����ʾ�����Ϣ
function Gas2Gac:RetOpenCofCNpcDialogEnd(Conn)
	local wnd	=	g_GameMain.m_CofCNpcDialogWnd
	wnd:EnableJoinCofCWnd(false)
	wnd:ShowCofCList()
	local AutoCloseWnd = CAutoCloseWnd:new()
	AutoCloseWnd:AutoCloseWnd(wnd)
end

--�����̻�ɹ����غ���
function Gas2Gac:RetRequestCreateCofc(Conn)
	local cofcNpcDialog = g_GameMain.m_CofCNpcDialogWnd
	local CofCName = cofcNpcDialog.m_InputCofCNameWnd.m_InputArea:GetWndText()
	cofcNpcDialog.m_InputCofCNameWnd:ShowWnd(false)
	--�����̻ᴰ��
	if g_GameMain.m_CofCMainWnd	== nil then
		g_GameMain.m_CofCMainWnd = CreateChamberOfCommerce(g_GameMain)
		g_GameMain.m_CofCMainWnd:ShowWnd(true)
		g_GameMain.m_CofCMainWnd.m_CofCName:SetWndText(CofCName)
		g_GameMain.m_CofCMainWnd.m_CofCModifyPurposeBtn:EnableWnd(true)
	end
	local AutoCloseWnd = CAutoCloseWnd:new()
	AutoCloseWnd:AutoCloseWnd(g_GameMain.m_CofCMainWnd)
	
	local cofc_id = g_MainPlayer.m_Properties:GetCofcID()
	Gac2Gas:GetCofcInfo(g_Con, cofc_id)
end


--�����ʹ����̻��npc�Ի�����
function CreateCofCNpcDialog(Parent)
	local wnd = CCofCNpcDialogWnd:new()
	wnd:CreateFromRes("CofCNpcDialog", Parent)
	wnd:ShowWnd( true )
	g_ExcludeWndMgr:InitExcludeWnd(wnd, 1)
	wnd:InitCofCNpcDialogChild()
	return wnd
end

--��ʼ���̻�npc�Ի����ڵ��Ӵ���
function CCofCNpcDialogWnd:InitCofCNpcDialogChild()
	self.m_CloseBtn		=	self:GetDlgChild("Close")			--�رհ�ť
	self.m_CancelBtn	=	self:GetDlgChild("CancelBtn")		--ȡ����ť
	self.m_CreateBtn	=	self:GetDlgChild("CreateBtn")		--�����̻ᰴť
	self.m_RequestBtn	=	self:GetDlgChild("RequestBtn")		--������ᰴť
	self.m_IntroBtn		=	self:GetDlgChild("IntroBtn")		--�������
	self.m_CofCList		=	self:GetDlgChild("CofCList")		--�̻��б�
end

--�̻�npc�Ի������¼���Ӧ����
function CCofCNpcDialogWnd:OnCtrlmsg( Child, uMsgID, uParam1, uParam2 )
	if (uMsgID == BUTTON_LCLICK) then
	  	if(Child == self.m_CloseBtn or Child == self.m_CancelBtn) then 			
	  		self:ShowWnd(false)
	  	elseif(Child == self.m_CreateBtn)    then 	
	  		self:OpenCreateCofC()	
	  	elseif(Child == self.m_RequestBtn) then
			self:EnableJoinCofCWnd(false)
			self:RequestJoinCofC()
		elseif(Child == self.m_IntroBtn) then
			self:EnableJoinCofCWnd(false)
			self:RequestIntroToCofC()
		end
	
	elseif( uMsgID == ITEM_LBUTTONCLICK ) then
		local cofcId = self:ClickedCofCListItem()
		if cofcId ~= nil then
			self:EnableJoinCofCWnd(true)
			self.m_ChoosedJoinCofCId = cofcId
		else
			self:EnableJoinCofCWnd(false)
		end
	end
end

--���׵�ѡ�����ĸ��̻�,����ֵΪ����ѡ���̻�id
function CCofCNpcDialogWnd:ClickedCofCListItem()
	local index = self:GetSelectedItemOrder()
	if index == nil then
		return
	end

	local cofcId = self.m_CofCListTbl[index].CofCId
	return cofcId
end

--�������ĸ������Ϣ��ѡ����
function CCofCNpcDialogWnd:GetSelectedItemOrder()
	local choosedItem = nil 
	choosedItem = self.m_CofCList:GetSelectItem( -1 ) + 1
  
	if choosedItem == 0 then
		return nil
	end
  
	return choosedItem
end


--������������������ᰴť״̬Ϊ�ɵ�򲻿ɵ����������true��false
function CCofCNpcDialogWnd:EnableJoinCofCWnd(clickedState)
	self.m_RequestBtn:EnableWnd(clickedState)
end

--ȷ��Ҫ�����̻��Ĵ����̻ᴰ��
function CCofCNpcDialogWnd:OpenCreateCofC()
	g_GameMain.m_CanCreateCofCLevel = 0
	if	g_MainPlayer:CppGetLevel()	>=	g_GameMain.m_CanCreateCofCLevel	then
		if	self.m_InputCofCNameWnd == nil then
			self.m_InputCofCNameWnd = CreateInputCofCNameWnd(self)
			self.m_InputCofCNameWnd:ShowWnd(true)
		elseif self.m_InputCofCNameWnd:IsShow() == false then
			self.m_InputCofCNameWnd:ShowWnd(true)
		end
	else	
		self.m_MsgBox  = MessageBox( self, MsgBoxMsg(16002), MB_BtnOK )
	end
end

--���̻�npc��������ʾ�̻��б�
function CCofCNpcDialogWnd:ShowCofCList()
	local cofcList	=	self.m_CofCListTbl
	self.m_CofCList:DeleteAllItem()
	for i=1, table.maxn( cofcList ) do
		if ( i == 1 ) then
		  self.m_CofCList:InsertColumn( 0, self.m_CofCList:GetWndWidth())
		end
		self.m_CofCList:InsertItem( i-1, 25 )
		
		local cofCItemWnd = SQRDialog:new()
		local item = self.m_CofCList:GetSubItem( i-1, 0)
		cofCItemWnd:CreateFromRes( "CofCNpcDialogItem", item )
		cofCItemWnd:ShowWnd( true )
		cofCItemWnd:SetStyle( 0x60000000 )
		cofCItemWnd:GetDlgChild("CofCName"):SetWndText(cofcList[i].CofCName)
		cofCItemWnd:GetDlgChild("MemberNo"):SetWndText(cofcList[i].MemberNo)
		table.insert(self.m_CofCList, cofCItemWnd)
	end
end

--���������ᰴť����ʾ����������
function CCofCNpcDialogWnd:RequestJoinCofC()
	if self.m_RequestJoinCofC == nil then 
		self.m_RequestJoinCofC = CreateJoinCofcInputDes(self)
		self.m_RequestJoinCofC:ShowWnd(true)
		return
	elseif self.m_RequestJoinCofC:IsShow() == false then
		self.m_RequestJoinCofC:ShowWnd(true)
		self.m_RequestJoinCofC.m_SelfDes:SetWndText("")
	end
end

--���������ᰴť����ʾ����������
function CCofCNpcDialogWnd:RequestIntroToCofC()
	if self.m_RequestIntroToCofC == nil then 
		self.m_RequestIntroToCofC = CreateIntroToCofcInputDes(self)
		self.m_RequestIntroToCofC:ShowWnd(true)
		return
	elseif self.m_RequestIntroToCofC:IsShow() == false then
		self.m_RequestIntroToCofC:ShowWnd(true)
		self.m_RequestIntroToCofC.m_InputIntroeeName:SetWndText("")
		self.m_RequestIntroToCofC.m_DesText:SetWndText("")
	end
end

----------------------------------ȷ��Ҫ�������̻�ʱ�����̻����ƵĴ���--------------------------------------------------

--�������̻�ʱ�������̻����ƵĴ���
function CreateInputCofCNameWnd(Parent)
	local wnd 			=	CInputCofCNameWnd:new()
	wnd:CreateFromRes("CofCCreate",Parent)
	wnd:ShowWnd( true )
	wnd.m_OkBtn 		= 	wnd:GetDlgChild("OkBtn")
	wnd.m_CancelBtn		=	wnd:GetDlgChild("CancelBtn")
	wnd.m_Close			=	wnd:GetDlgChild("Close")
	wnd.m_InputArea		=	wnd:GetDlgChild("InputArea")
	g_ExcludeWndMgr:InitExcludeWnd(wnd, 3, false, {g_GameMain.m_CofCNpcDialogWnd})
	return wnd
end

function CInputCofCNameWnd:OnCtrlmsg( Child, uMsgID, uParam1, uParam2 )
	if (uMsgID == BUTTON_LCLICK) then
	  	if(Child == self.m_Close or Child == self.m_CancelBtn) then 			
	  		self:ShowWnd(false)
	  	elseif(Child == self.m_OkBtn)    then 
	  		
	  		local CofCName = self.m_InputArea:GetWndText()
	  		local CofCNameLen = string.len(CofCName)
	  		if CofCName == "" then
	  			self.m_MsgBox = MessageBox(self, MsgBoxMsg(16003), MB_BtnOK)
	  			return
	  		end
	  		if CofCNameLen > math.pow(2,30) then 	--���ݿ��ж����̻����Ʋ��ܳ���
	  			self.m_MsgBox = MessageBox(self, MsgBoxMsg(16004), MB_BtnOK)
	  		else
	  			Gac2Gas:RequestCreateCofc( g_Conn, CofCName )	
	  		end				
			self:ShowWnd(false)
		end
	end
end


-------------------------------------------ȷ��Ҫ�����̻�ʱ����д�������ʱ�Ĵ���-------------------------------------------------
--�����������,��д�������������Ĵ��ڣ�Des��description����д��
function CreateJoinCofcInputDes(Parent)
	local wnd		=	CJoinCofcInputDes:new()
	wnd:CreateFromRes("CofCRequest",Parent)
	wnd:ShowWnd( true )
	wnd.m_CloseBtn 	= 	wnd:GetDlgChild("Close")
	wnd.m_CancelBtn	=	wnd:GetDlgChild("CancelBtn")
	wnd.m_OkBtn		=	wnd:GetDlgChild("OkBtn")
	wnd.m_SelfDes	=	wnd:GetDlgChild("DesText")
	g_ExcludeWndMgr:InitExcludeWnd(wnd, 3, false, {g_GameMain.m_CofCNpcDialogWnd})
	return wnd
end

--���������д���������Ĵ���
function CJoinCofcInputDes:OnCtrlmsg( Child, uMsgID, uParam1, uParam2 )
	if (uMsgID == BUTTON_LCLICK) then
	  	if(Child == self.m_CloseBtn or Child == self.m_CancelBtn) then 			
	  		self:ShowWnd(false)
	  	elseif(Child == self.m_OkBtn) then
			local des = self.m_SelfDes:GetWndText()
			local cofcId =	g_GameMain.m_CofCNpcDialogWnd.m_ChoosedJoinCofCId
			self:ShowWnd(false)
			Gac2Gas:RequestJoinCofC(g_Conn, cofcId, des )
		end
	end
end


---------------------------------��������������ļ�Ҫ��������---------------------------------------------------
--�����������������������������Ϣ�Ĵ���
function CreateIntroToCofcInputDes(Parent)
	local	wnd				=	CIntroToCofCInputDes:new()
	wnd:CreateFromRes("CofCIntro",Parent)
	wnd:ShowWnd( true )
	wnd.m_CloseBtn			=	wnd:GetDlgChild("Close")
	wnd.m_CancelBtn			=	wnd:GetDlgChild("CancelBtn")
	wnd.m_InputIntroeeName	=	wnd:GetDlgChild("InputIntroeeName")
	wnd.m_DesText			=	wnd:GetDlgChild("DesText")
	wnd.m_OkBtn				=	wnd:GetDlgChild("OkBtn")
	g_ExcludeWndMgr:InitExcludeWnd(wnd, 3, false, {g_GameMain.m_CofCNpcDialogWnd})
	return wnd
end


--�������������������������Ϣ�Ĵ��ڣ��¼���Ӧ����
function CIntroToCofCInputDes:OnCtrlmsg( Child, uMsgID, uParam1, uParam2 )
	if (uMsgID == BUTTON_LCLICK) then
	  	if(Child == self.m_CloseBtn or Child == self.m_CancelBtn) then 			
	  		self:ShowWnd(false)
	  	elseif(Child == self.m_OkBtn) then
	  		local name = self.m_InputIntroeeName:GetWndText()
	  		if name == nil or name == "" then
	  			self.m_MsgBox = MessageBox( self, MsgBoxMsg(16005), MB_BtnOK )
	  			return
	  		end
			local des = self.m_DesText:GetWndText()
			self:ShowWnd(false)
			Gac2Gas:IntroduceJoinCofC(g_Conn, name, des )
		end
	end
end

