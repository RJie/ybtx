CMailTextAttachWnd = class(SQRDialog)

function CMailTextAttachWnd.CreateMailTextAttachWnd(Parent)
	local wnd = CMailTextAttachWnd:new()
	wnd:CreateFromRes("MailTextAttach",Parent)
	wnd:ShowWnd( true )
	g_ExcludeWndMgr:InitExcludeWnd(wnd, 3)
	return wnd
end

--�ó�Ա�����洢�鿴�ʼ�����е��ӿؼ�
function CMailTextAttachWnd:OnChildCreated()
	self.m_Close		=	self:GetDlgChild("Close")
	self.m_MailText		=	self:GetDlgChild("MailText")
	self.m_MailText:SetMouseWheel(true)
end

function CMailTextAttachWnd:OnCtrlmsg(Child, uMsgID, uParam1, uParam2)
	if(uMsgID == BUTTON_LCLICK) then
		if Child == self.m_Close then
			self:ShowWnd(false)
		end
	end
end
