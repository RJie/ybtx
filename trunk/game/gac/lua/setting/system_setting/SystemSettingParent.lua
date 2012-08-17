gac_require "setting/key_map/KPmap"

CSystemSettingParent = class(SQRDialog)

function CSystemSettingParent:Ctor()
	self:CreateFromRes("SysSettingMainWnd",g_GameMain)
	g_ExcludeWndMgr:InitExcludeWnd(self, "�ǻ���")
	
	self.m_VedioSettingWnd		= CVideoSettingWnd:new(self)	--��Ƶ����
	self.m_AudioSettingWnd		= CAudioSettingWnd:new(self)	--��Ƶ����
	self.m_KPmap				= CreateKPmap(self)				--��������
	self.m_MouseSettingWnd		= CMouseSetting:new(self)		--�������
	self.m_UISettingWnd			= CUISettingWnd:new(self)		--��������
	self.m_GameSettingWnd		= CGameSettingWnd:new(self)		--��Ϸ����
	self.m_SysOtherSettingWnd	= SysOtherSettingWnd:new(self)	--��������
end

function CSystemSettingParent:OnChildCreated()
	self.m_tblCheckBtn = {}
	for i = 1, 7 do
		self.m_tblCheckBtn[i] = self:GetDlgChild("CheckBtn" .. i)
	end
	self.m_CloseBtn		= self:GetDlgChild("CloseBtn")
	self.m_DefaultBtn	= self:GetDlgChild("ReplaceBtn")
	self.m_OkBtn		= self:GetDlgChild("OkBtn")
	self.m_CancelBtn	= self:GetDlgChild("CancelBtn")
	self.m_AppBtn		= self:GetDlgChild("AppBtn")
	self.m_HelpBtn		= self:GetDlgChild("HelpBtn")
	
	self.m_tblCheckBtn[1]:SetCheck(true)
end

function CSystemSettingParent:OnCtrlmsg( Child, uMsgID, uParam1, uParam2 )
	if uMsgID == BUTTON_LCLICK then
		if Child == self.m_DefaultBtn then
			self:SetDefault()							--�ָ�Ĭ������
		elseif Child == self.m_OkBtn then
			Gac2Gas:SysSettingBegain(g_Conn)
			self.m_VedioSettingWnd:ChangeSettings()		--��Ƶ
			self.m_KPmap:ChangeSettings()				--����
			self.m_MouseSettingWnd:ChangeMouseCtrl()	--���
			self.m_GameSettingWnd:GameSetting()			--��Ϸ����
			self.m_UISettingWnd:SaveUISetting()			--��������
			Gac2Gas:SysSettingEnd(g_Conn)
			g_GameMain.m_CharacterInSyncMgr:UpdateHeadModelInSync()
			self:ShowWnd(false)
		elseif Child == self.m_CloseBtn or Child == self.m_CancelBtn then
			if(self.m_MouseSettingWnd:IsShow() == true) then
				self.m_MouseSettingWnd:SetInfo()
			end
			if(self.m_KPmap:IsShow() == true) then
				self.m_KPmap:RegisterAccelKeyKey()
			end
			self.m_KPmap:SetCancel() --����
			self:ShowWnd(false)
		elseif Child == self.m_AppBtn then
			Gac2Gas:SysSettingBegain(g_Conn)
			self.m_VedioSettingWnd:ChangeSettings()  --��Ƶ
			self.m_KPmap:ChangeSettings()            --����
			self.m_MouseSettingWnd:ChangeMouseCtrl() --���
			self.m_GameSettingWnd:GameSetting()      --��Ϸ����
			self.m_UISettingWnd:SaveUISetting()      --��������
			Gac2Gas:SysSettingEnd(g_Conn)
			g_GameMain.m_CharacterInSyncMgr:UpdateHeadModelInSync()
		else
			for i = 1, 7 do
				if(Child == self.m_tblCheckBtn[i]) then
					self:SetPanelShow()
				end
			end
		end
	end
end

--�ظ�Ĭ������
function CSystemSettingParent:SetDefault()
	if( self.m_VedioSettingWnd:IsShow() ) then
		self.m_VedioSettingWnd:SetDefault()
	elseif( self.m_AudioSettingWnd:IsShow() ) then
		self.m_AudioSettingWnd:SetDefault()
	elseif( self.m_KPmap:IsShow() ) then
		self.m_KPmap:SetDefault()
	elseif( self.m_MouseSettingWnd:IsShow() ) then
		self.m_MouseSettingWnd:SetDefault()
	elseif( self.m_UISettingWnd:IsShow() ) then
		self.m_UISettingWnd:SetDefault()
	elseif( self.m_GameSettingWnd:IsShow() ) then
		self.m_GameSettingWnd:SetDefault()
	elseif( self.m_SysOtherSettingWnd:IsShow()) then
	    self.m_SysOtherSettingWnd:SetDefault()
	end
	Gac2Gas:SysSettingEnd(g_Conn)
end

function CSystemSettingParent:SetPanelShow()
	self.m_VedioSettingWnd:ShowWnd(self.m_tblCheckBtn[1]:GetCheck())	--��Ƶ
	self.m_UISettingWnd:ShowWnd(self.m_tblCheckBtn[2]:GetCheck())		--��������
	self.m_AudioSettingWnd:ShowWnd(self.m_tblCheckBtn[3]:GetCheck())	--��Ƶ����
	self.m_GameSettingWnd:ShowWnd(self.m_tblCheckBtn[4]:GetCheck())		--��Ϸ����
	self.m_MouseSettingWnd:OpenPanel(self.m_tblCheckBtn[5]:GetCheck())	--���
	self.m_KPmap:OpenPanel(self.m_tblCheckBtn[6]:GetCheck())			--����
	local flag = self.m_tblCheckBtn[7]:GetCheck()
	self.m_SysOtherSettingWnd:ShowWnd(self.m_tblCheckBtn[7]:GetCheck())
	if self.m_SysOtherSettingWnd:IsShow() then
	    self.m_SysOtherSettingWnd:UpdateSettingShopTipChkBtn()
	end
end

function CSystemSettingParent:OpenPanel()
	self:ShowWnd(true)
	self.m_VedioSettingWnd:GetInfo()
	self.m_UISettingWnd:GetSettingInfo()
	self.m_AudioSettingWnd:GetInfo()
	self:SetPanelShow()
	Gac2Gas:GetGameSettingInfo(g_Conn)
end
