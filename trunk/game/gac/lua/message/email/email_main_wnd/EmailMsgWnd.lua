CWndEmailMSG = class(SQRDialog) --������

function CWndEmailMSG:OnCtrlmsg( Child, uMsgID, uParam1, uParam2 )           --��Ϣ��ʾȷ���¼�
	if (uMsgID == BUTTON_LCLICK) then
		if( Child == self:GetDlgChild( "Btn_Ok" ) ) then
			g_GameMain.m_EmailBox:DelMail()
			self:ShowWnd(false)
		else
			self:ShowWnd(false)
			return
		end
	end	
end
