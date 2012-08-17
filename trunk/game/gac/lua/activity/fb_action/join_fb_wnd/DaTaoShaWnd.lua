CDaTaoShaWnd = class(SQRDialog)
local m_FbName = "�Ƕ���"--GetStaticTextClient(9400)--�Ƕ���

function CDaTaoShaWnd:Ctor(parent)
	self:CreateFromRes("Fb_PVPApplyWnd",parent) 
	self.m_JoinBtn = self:GetDlgChild("JoinBtn")
	self.m_CancelBtn = self:GetDlgChild("CancelBtn")
	self.m_CloseBtn = self:GetDlgChild("CloseBtn")
	self.m_FbGameInfo = self:GetDlgChild("FbGameInfo")
	self.m_Title = self:GetDlgChild("WndName")
	
	self.m_Title:SetWndText(GetStaticTextClient(9400))
	self.m_FbGameInfo:SetWndText(GetDescriptionDisplayName("�Ƕ�������"))
	
	g_ExcludeWndMgr:InitExcludeWnd(self, 1)
	self:ShowWnd(false)
end

function CDaTaoShaWnd:GetWnd()
	local Wnd = g_GameMain.m_DaTaoShaWnd
	if not Wnd then
		Wnd = CDaTaoShaWnd:new(g_GameMain)
		g_GameMain.m_DaTaoShaWnd = Wnd
	end
	return Wnd
end

function CDaTaoShaWnd:InitDaTaoShaWnd(IsInWait, IsCancel, WaitNum)
	self:ShowWnd(true)
	
	local IsShow1 = not IsInWait
	local IsShow2 = not IsCancel
	
	self.m_JoinBtn:EnableWnd(IsShow1)
	self.m_CancelBtn:EnableWnd(IsShow2)
	
	--self.m_WaitNumWnd:SetWndText(WaitNum)
	local AutoCloseWnd = CAutoCloseWnd:new()
	AutoCloseWnd:AutoCloseWnd(self)
end

function CDaTaoShaWnd:OnCtrlmsg(Child, uMsgID, uParam1, uParam2 )
	--local EntityID = g_MainPlayer.m_LockCenter.m_LockingObj:GetEntityID()
	if(uMsgID == BUTTON_LCLICK) then
		if ( Child == self.m_JoinBtn) then
			--�����μӴ���ɱ
			Gac2Gas:JoinDaTaoSha(g_Conn)
			self:ShowWnd(false)
		elseif(Child == self.m_CheckWaitNumBtn) then
			--�鿴�ȴ�����
			--Gac2Gas:CheckDaTaoShaWaitNum(g_Conn, EntityID)
		elseif(Child == self.m_CancelBtn ) then
			--�����μӴ���ɱ
			Gac2Gas:NotJoinFbAction(g_Conn,m_FbName)
			if g_GameMain.m_FbActionMsgWnd[m_FbName] then
				g_GameMain.m_FbActionMsgWnd[m_FbName]:DeleteTick(m_FbName)
			end
			self:ShowWnd(false)
		elseif(Child == self.m_CloseBtn) then
			--�رմ���
			self:ShowWnd(false)
		end
	end
end

function CDaTaoShaWnd:RetShowDaTaoShaWnd(IsInWait, EntityID)
	self.m_NpcID = EntityID
	self:InitDaTaoShaWnd(IsInWait, not IsInWait, 0)
end

function CDaTaoShaWnd:RetSetSceneStateForClient(SceneState)
	g_GameMain.m_SceneStateForClient = SceneState
	if(1 == SceneState) then --����ɱ����
		g_GameMain.m_SmallMapBG:ShowWnd(false)
	else
		g_GameMain.m_SmallMapBG:ShowWnd(true)
	end
	--������Χ��NPC��OBJ
	g_GameMain.m_TeamMarkSignMgr:UpdateCharacterInView()
	--������Χ�����
	g_GameMain.m_CharacterInSyncMgr:UpdateCharacterInSync()
end
