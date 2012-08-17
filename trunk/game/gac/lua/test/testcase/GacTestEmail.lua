gac_require "test/common/CTstLoginControler"
engine_require "common/Misc/TypeCheck"
function InitGacTestEmail()
 	local test_Email=TestCase("GacTestEmail")
	--�������
	function test_Email:TestBegin()
		controler = CTstLoginControler:new()
		controler:OneStepLoginEx("123456","����")
		controler:LoginOutFromGame()		
		controler:OneStepLogin()
	end
	
	--�ʼ�ϵͳ������
	function test_Email:TestEmailBox()
    	local m_EmailBox = g_GameMain.m_EmailBox	
  		local m_EmailListBox = m_EmailBox:GetDlgChild("EmailListBox")
    
   		Gac2Gas:GM_Execute( g_Conn, "$openpanel(5)" )
    	local strRet = WaitEvent( true, nil, Event.Test.OpenEmailWnd )
		SetEvent( Event.Test.OpenEmailWnd, false )
      
    	assert_true(m_EmailBox:IsShow())
    	assert_equal(m_EmailListBox:GetWndText(),"","[Doesn'tHaveEmail]")
    	assert_false(m_EmailBox:GetDlgChild("CheckMail"):IsEnable(),"[NoMailBtnDisable]")
    	assert_false(m_EmailBox:GetDlgChild("TakeAttachment"):IsEnable(),"[NoMailBtnDisable]")
    	assert_false(m_EmailBox:GetDlgChild("DeleteEmail"):IsEnable(),"[NoMailBtnDisable]")
    
    	--[[m_EmailBox:OnCtrlmsg(m_EmailBox:GetDlgChild("TakeAttachment") ,BUTTON_LCLICK,0, 0)
    	--������ȡ�����Ƿ���ȷ�������
    	--]]
    	--����ɾ���ʼ�  < �����ʼ�������� ,ɾ��ȫ���ʼ� >
    	local strRet = WaitEvent(true, nil, Event.Test.GetEmailListEnded) --�ʼ��б�������
   		for i=1,m_EmailListBox:GetItemCount() do--ɾ�����и���
   			local itemvalue = m_EmailListBox:GetSubItem( i-1, 0 ):GetDlgChild( "mailItem" )
   			m_EmailBox:OnCtrlmsg(itemvalue:GetDlgChild("SelectToken") ,BUTTON_LCLICK,0, 0)
   		end
   		if(m_EmailListBox:GetItemCount()>0) then
   			m_EmailBox:OnCtrlmsg(m_EmailBox:GetDlgChild("DeleteEmail") ,BUTTON_LCLICK,0, 0)
   		end
       	m_EmailBox:OnCtrlmsg(m_EmailBox:GetDlgChild("Close") ,BUTTON_LCLICK,0, 0)
       	assert_false(m_EmailBox:IsShow())
	end
   	
	--������ͻ��˲�������	
  	function test_Email:TestSendEmail()
  	
    	local m_EmailBox = g_GameMain.m_EmailBox
		local m_SendBox = g_GameMain.m_SendBox
    	
    	m_EmailBox:OnCtrlmsg(m_EmailBox:GetDlgChild("NewEmail") ,BUTTON_LCLICK,0, 0)
    	
    	local m_ReceiverName = m_SendBox.m_ReceiverName
    	local m_EmailTitle = m_SendBox.m_EmailTitle
    	local m_Tong = m_SendBox.m_Tong
    	local m_SendBtn    = m_SendBox.m_SendBtn
    	local m_EmailText  = m_SendBox.m_EmailText
    	local m_CancelBtn  = m_SendBox:GetDlgChild("Cancel")
    	
    	local function Check_MsgBox_Msg( expect_str )
    	  	state_sendbox = g_GameMain.m_SendBox
    		assert( state_sendbox.m_MsgBox )
    		local wnd = state_sendbox.m_MsgBox:GetDlgChild("WndInfo")
    		assert( wnd )
    	
    		assert_equal( wnd:GetWndText(), expect_str )
    	end
    	local function Click_MsgBox_OKBtn()
    		state_sendbox = g_GameMain.m_SendBox
    		assert( state_sendbox.m_MsgBox )
    		local wnd = state_sendbox.m_MsgBox:GetDlgChild("BtnOK")
    		assert( wnd )
     
    		assert( getmetatable(wnd) ~= nil )
    		wnd:SendMsg( WM_LBUTTONDOWN, 0, 0 )
    		wnd:SendMsg( WM_LBUTTONUP, 0, 0 )

   		end  
    	local function Click_MsgBox_CancelBtn()
    		state_sendbox = g_GameMain.m_SendBox
    		assert( state_sendbox.m_MsgBox )
    		local wnd = state_sendbox.m_MsgBox:GetDlgChild("BtnCancel")
    		assert( wnd )
        	
    		assert( getmetatable(wnd) ~= nil )
    		wnd:SendMsg( WM_LBUTTONDOWN, 0, 0 )
    		wnd:SendMsg( WM_LBUTTONUP, 0, 0 )
   		end 
    
    	m_EmailBox:ShowWnd(true)
    	assert_true(m_SendBox:IsShow(),"[SendEmailBoxIsShow]")
    	m_SendBox:OnCtrlmsg(m_SendBox:GetDlgChild("Cancel") ,BUTTON_LCLICK,0, 0)
    	assert_false(m_SendBox:IsShow(),"[SendEmailBoxNotShow]")
    	
    	
    	m_SendBox:ShowWnd(true)
    	
    	--�����ռ��˺��ʼ��������ͬʱ��Ϊ��
    	m_EmailTitle:SetWndText("")
    	m_ReceiverName:SetWndText("fjsaf")
    	m_SendBox:OnCtrlmsg(m_SendBox.m_ReceiverName and m_SendBox.m_EmailTitle,WND_NOTIFY,WM_IME_CHAR or WM_CHAR , 0)
    	assert_false(m_SendBtn:IsEnable(),"[EmailTitleCanNotBeFree]")
    	
    	m_ReceiverName:SetWndText("")
    	m_EmailTitle:SetWndText("fjsaf")
    	assert_false(m_SendBtn:IsEnable(),"[EmailTitleCanNotBeFree]")
    	
    	m_ReceiverName:SetWndText("fafadsfew")
    	m_EmailTitle:SetWndText("��˵���Ŵ�")
    	m_EmailText:SetWndText("11111111")
    	m_SendBox:OnCtrlmsg(m_SendBox.m_ReceiverName and m_SendBox.m_EmailTitle,WND_NOTIFY,WM_IME_CHAR or WM_CHAR , 0)
    	assert_true(m_SendBtn:IsEnable(),"[SendBtnEnableTrue]")  
    	
    	--�ռ��˲���Ϊ�Լ�
    	m_ReceiverName:SetWndText(g_MainPlayer.m_Properties:GetCharName())
    	m_EmailTitle:SetWndText("�ķ���")
    	m_SendBox:OnCtrlmsg(m_SendBox.m_ReceiverName and m_SendBox.m_EmailTitle,WND_NOTIFY,WM_IME_CHAR or WM_CHAR , 0)
    	m_SendBox:OnCtrlmsg(m_SendBox:GetDlgChild("Send") ,BUTTON_LCLICK,0, 0)
    	Check_MsgBox_Msg("�ռ��˲������Լ�")
    	Click_MsgBox_OKBtn()
    	assert_true(m_SendBox:IsShow(),"[ReceiverCannotBeOneself]")
    	 
		-------------------------------------------------------------
		--�����ż��ɹ���
		--��Ҫ���� ������Ҫ�ȼ�Ǯ
		Gac2Gas:GM_Execute( g_Conn, "$addmoney(1000)" );
		local strRet = WaitEvent(true,nil,Event.Test.AddMoneyGM)
		SetEvent(Event.Test.AddMoneyGM,false)
		m_ReceiverName:SetWndText("����")
		m_EmailTitle:SetWndText("�ķ���")
		m_EmailText:SetWndText("text")
		m_SendBox:OnCtrlmsg(m_SendBox:GetDlgChild("Send") ,BUTTON_LCLICK,0, 0)
		--Check_MsgBox_Msg("ȷ��Ҫ����".. "12"   .. "��Ŀ�Ľ����")
		--Click_MsgBox_OKBtn()
		local strRet = WaitEvent(true,nil,Event.Test.SendEmailEnded)
		SetEvent(Event.Test.SendEmailEnded,false)
		if strRet[1] == EEventState.Success then
			assert_true(strRet[2][1])
			if strRet[2][1] == true then
				--print("���ͳɹ�")
				assert_false(m_SendBox:IsShow(),"[SendSuccessfully]")
			end
		end

		m_SendBox:ShowWnd(true)
		--�ռ��˲����ڣ������ż�����ʧ��
		m_ReceiverName:SetWndText("wwwww")
		m_EmailTitle:SetWndText("�ķ���")
		m_Tong:SetWndText("12")
		m_SendBox:OnCtrlmsg(m_SendBox.m_MoneyAmount ,WND_NOTIFY,WM_IME_CHAR or WM_CHAR , 0)
    	
		m_SendBox:OnCtrlmsg(m_SendBox:GetDlgChild("Send") ,BUTTON_LCLICK,0, 0)
		Check_MsgBox_Msg("ȷ��Ҫ���ͽ���12ͭ ��")
		Click_MsgBox_CancelBtn()
		assert_true(m_SendBox:IsShow(),"[CancelSendingEmail]")
    	
		SetEvent(Event.Test.MsgToClient,false)
		m_SendBox:OnCtrlmsg(m_SendBox:GetDlgChild("Send") ,BUTTON_LCLICK,0, 0)
		--Click_MsgBox_OKBtn()
    	
		local strRet = WaitEvent(true,nil,Event.Test.MsgToClient)
		SetEvent(Event.Test.MsgToClient,false)
		if strRet[1] == EEventState.Success then
			assert_equal("�ռ���wwwww������", strRet[2][1])
		else
			assert_fail("MessageToConn Failed TimeOut")
		end
		m_SendBox:ShowWnd(true)
		local strRet = WaitEvent(true,nil,Event.Test.SendEmailEnded)
		SetEvent(Event.Test.SendEmailEnded,false)
		if strRet[1] == EEventState.Success then
			assert_false(strRet[2][1])
			if strRet[2][1] == false then
				assert_true(m_SendBox:IsShow(),"[SendFailed]")
			end
		 end
		assert_true(m_SendBox:IsShow(),"[SendBoxShowTrue]")
		m_SendBox:ShowWnd(false)
		m_EmailBox:ShowWnd(false)
	end
  

	--�ռ���ͻ��˲������� 
	function test_Email:TestReceiveEmail()
		controler:LoginOutFromGame()
		controler:OneStepLoginEx("123456","����")
		    
    	local m_EmailBox = g_GameMain.m_EmailBox	
  		--local g_CGameHook = CGameAccelerator:new()
  		local m_ReceiveBox = g_GameMain.m_ReceiveBox
  		local m_SendBox = g_GameMain.m_SendBox
  		local m_EmailListBox = m_EmailBox:GetDlgChild("EmailListBox")
    	
		m_EmailListBox:SelectItem(0) 
    	Gac2Gas:GM_Execute( g_Conn, "$openpanel(5)" )
    	local strRet = WaitEvent( true, nil, Event.Test.OpenEmailWnd )
		SetEvent( Event.Test.OpenEmailWnd, false )
			
    	assert_true(m_EmailBox:IsShow())
   		-- local itemWnd = m_EmailBox:GetDlgChild("EmailListBox"):GetSubItem( 0,0 )
    	local strRet = WaitEvent(true,nil,Event.Test.GetEmailListEnded)
		SetEvent(Event.Test.GetEmailListEnded,false)
		
		--print("��Ϊ��:" .. itemWnd:GetWndText())
		if strRet[1] == EEventState.Success then
			assert_true(strRet[2][1])
			if strRet[2][1] == true then
				--print("��ȡ�ʼ��б�ɹ�")
				--assert_true(g_GameMain.m_EmailBox:GetDlgChild("EmailListBox"):GetWndText() ~= "","[HasEmail]")
			end
		end
    	
    	m_EmailBox:OnCtrlmsg("",ITEM_LBUTTONCLICK,0,0)
    	local strRet = WaitEvent(true,nil,Event.Test.GetEmailListEnded)
    	local itemvalue = m_EmailListBox:GetSubItem( 0, 0 ):GetDlgChild( "mailItem" )
    	itemvalue:OnCtrlmsg(itemvalue:GetDlgChild("SelectToken") ,BUTTON_LCLICK,0, 0)
    	
    	assert_true(m_EmailBox:GetDlgChild("CheckMail"):IsEnable(),"[HasMailBtnEnable]")
    	assert_true(m_EmailBox:GetDlgChild("TakeAttachment"):IsEnable(),"[HasMailBtnEnable]")
    	assert_true(m_EmailBox:GetDlgChild("DeleteEmail"):IsEnable(),"[HasMailBtnEnable]")
		m_EmailBox:OnCtrlmsg(m_EmailBox:GetDlgChild("CheckMail") ,BUTTON_LCLICK,0, 0)
		-- Gac2Gas:GetMail(g_Conn,choosedMail.ID)
    	
    	local strGetRet = WaitEvent(true,nil,Event.Test.GetEmailEnded)
    	SetEvent(Event.Test.GetEmailEnded,false)
    	local m_senderName = m_ReceiveBox:GetDlgChild("SenderName"):GetWndText()
		local m_emailTitle = m_ReceiveBox:GetDlgChild("EmailTitle"):GetWndText()
    	if strGetRet[1] == EEventState.Success then
			if strGetRet[2][1] == "GetEmailSuccessfully" then
		       assert_true(m_ReceiveBox:IsShow())
		       assert_false(m_senderName == "")
		       assert_false(m_emailTitle == "")
			end
		end
    	
		--�ռ����Ѵ򿪣����ռ��䴰��������
		m_ReceiveBox:OnCtrlmsg(m_ReceiveBox:GetDlgChild("Reply"),BUTTON_LCLICK,0,0)
		assert_false(m_ReceiveBox:IsShow())
		assert_true(m_SendBox:IsShow())
		assert_equal(m_SendBox:GetDlgChild("ReceiverName"):GetWndText(),m_senderName)
		assert_equal(m_SendBox:GetDlgChild("EmailTitle"):GetWndText(),"Re:" .. m_emailTitle)
		m_SendBox:ShowWnd(false)
		
		m_EmailListBox:SelectItem(0) 
		      
    	m_EmailBox:OnCtrlmsg("",ITEM_LBUTTONCLICK,0,0)
    	assert_true(m_EmailBox:GetDlgChild("CheckMail"):IsEnable(),"[HasMailBtnEnable]")
    	assert_true(m_EmailBox:GetDlgChild("TakeAttachment"):IsEnable(),"[HasMailBtnEnable]")
    	assert_true(m_EmailBox:GetDlgChild("DeleteEmail"):IsEnable(),"[HasMailBtnEnable]")
    	
		m_EmailBox:OnCtrlmsg(m_EmailBox:GetDlgChild("CheckMail") ,BUTTON_LCLICK,0, 0)
		local strGetRet = WaitEvent(true,nil,Event.Test.GetEmailEnded)
    	SetEvent(Event.Test.GetEmailEnded,false)
		assert_true(m_ReceiveBox:IsShow())
		  
		  
		m_ReceiveBox:OnCtrlmsg(m_ReceiveBox:GetDlgChild("DeleteEmail"),BUTTON_LCLICK,0,0)
    	
		local strDelRet = WaitEvent(true,nil,Event.Test.DeleteMailEnded)
		SetEvent(Event.Test.DeleteMailEnded,false)
		
		if strDelRet[1] == EEventState.Success then
			assert_true(strRet[2][1])
			if strDelRet[2][1] == 1 then
				--print("ɾ���ʼ��ɹ�")
				assert_false(m_ReceiveBox:IsShow(),"[DeleteSuccessfully]")
				assert_false(m_EmailBox:GetDlgChild("CheckMail"):IsEnable())
			end
		end
		 		  			
		m_EmailBox:ShowWnd(false)																					
	end   
           
	--�˳�����
	function test_Email:TestEnd()
		controler:LoginOutFromGame()
	end
	
	function test_Email:teardown()
	end

end
