CTradeRequestTipsWnd = class (SQRDialog)


-------------------------------�������ϵ���ҽ�������btn-----------------------
function CTradeRequestTipsWnd:Ctor()
    self:CreateFromRes("PlayerTradesRequest", g_GameMain)
    self.m_Btn = self:GetDlgChild("PlayerTradeBtn")
end


function CTradeRequestTipsWnd:OnCtrlmsg(Child, uMsgID, uParam1, uParam2)
    if uMsgID == BUTTON_LCLICK then
        if Child == self.m_Btn then
            if g_GameMain.m_PlayersTradeWnd.m_WaitingRequestMsg then    --�鿴����������Ϣ�ѷ��ͣ����Ժ�����
               MsgClient(6015)
               return  
            end
            if g_GameMain.m_PlayersTradeWnd:IsShow() then       --���ڽ��ײ��ܲ鿴��������
               MsgClient(6011)
               return 
            end
            g_GameMain.m_PlayersTradeWnd:CloseTradeInvitationWnd()
            g_GameMain.m_PlayersTradeWnd.m_WaitingRequestMsg = true
            Gac2Gas:GetPlayersTradeRequestList(g_Conn)
        end
    end
end
