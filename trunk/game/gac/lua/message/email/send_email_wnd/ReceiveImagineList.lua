
CReceiveImagineList = class(SQRDialog) 

--�ó�Ա�����洢�ռ����б����е��ӿؼ�
function CReceiveImagineList:InitReceiveImagineListChild()
	self.m_friendslist			=	self:GetDlgChild("friendslist")
end


function CReceiveImagineList:OnCtrlmsg(Child, uMsgID, uParam1, uParam2 )
	if(uMsgID == ITEM_LBUTTONCLICK)then
		local index = self.m_friendslist:GetSelectItem( -1 )
		local wnd = self.m_friendslist:GetSubItem(index,0)
		g_GameMain.m_SendBox.m_ReceiverName:SetWndText(wnd:GetWndText())
		g_GameMain.m_SendBox.m_ImagineList:ShowWnd(false)
		g_GameMain.m_SendBox.m_ImagineList.m_friendslist:DeleteAllItem()
	end
end