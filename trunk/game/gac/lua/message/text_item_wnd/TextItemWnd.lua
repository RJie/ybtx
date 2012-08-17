gac_require "message/text_item_wnd/TextItemWndInc"

function CreateTextItemWnd(Parent)
	local wnd = CTextItemWnd:new()
	wnd:CreateFromRes("TextItemWnd", Parent)
	wnd:Init()
	g_ExcludeWndMgr:InitExcludeWnd(wnd, "�ǻ���")
	return wnd
end

--�ó�Ա�����洢�鿴�ʼ�����е��ӿؼ�
function CTextItemWnd:Init()
	self.m_XBtn = self:GetDlgChild("XBtn")
	self.m_Text = self:GetDlgChild("Text")
	self.m_Text:SetMouseWheel(true)
end

function CTextItemWnd:OnCtrlmsg(Child, uMsgID, uParam1, uParam2)
	if(uMsgID == BUTTON_LCLICK) then
		if(Child == self.m_XBtn) then
			self:ShowWnd(false)
		end
	end
end