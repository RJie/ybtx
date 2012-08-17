gac_require "test/common/CTstLoginControler"

function InitGacTestNPCShop()
	local test_NPCShop = TestCase("GacTestNPCShop")
	--�������
	function test_NPCShop:TestBegin()
		controler = CTstLoginControler:new()
		controler:OneStepLogin()
	end
	
	--NPC�̵깺�򴰿ڼ����ܲ���
	function test_NPCShop:test_NPCShopSell()
		local m_NPCShopSellWnd 	= g_GameMain.m_NPCShopSell
		local tbl 				= m_NPCShopSellWnd.m_NPCShopGoodsList       --NPC�̵�������Ʒ�б�
	  	local tblPlayerSold		= g_GameMain.m_NPCShopGoodsList        		--���������Ʒ�б�
	  	local sellGoodListWnd	= m_NPCShopSellWnd:GetDlgChild("ItemList")
		local m_NPCShopPlayerSoldWnd = g_GameMain.m_NPCShopPlayerSold
	 
		--������ͨ��GMָ��򿪵�
		Gac2Gas:GM_Execute( g_Conn, "$openpanel(3)" )
    	local strRet = WaitEvent( true, nil, Event.Test.OpenNpcSellWnd )
		SetEvent( Event.Test.OpenNpcSellWnd, false )
    
  	 	local m_MainBagWnd = g_GameMain.m_WndMainBag
  	 	assert_true( m_NPCShopSellWnd:IsShow() )
  	 	assert_false( m_NPCShopPlayerSoldWnd:IsShow() )
  	 	assert_true( m_MainBagWnd:IsShow() ) 
  	 	assert_true( m_MainBagWnd:IsShow() )
  	 	
  	 	--����NPC�̵깺�򴰿ڵĹرհ�ť����
  	 	m_NPCShopSellWnd:OnCtrlmsg( m_NPCShopSellWnd:GetDlgChild("Close"), BUTTON_LCLICK, 0, 0 )
  	 	assert_false( m_NPCShopSellWnd:IsShow() )
  	 	assert_false( m_MainBagWnd:IsShow() )
  	 	m_NPCShopSellWnd:ShowWnd( true )
  	 	m_MainBagWnd:ShowWnd( true )
  	 	
  	 	local function Check_MsgBox_Msg( expect_str )
  	 	  state_m_NPCShopSellWnd = g_GameMain.m_NPCShopSell
  	 		assert( state_m_NPCShopSellWnd.m_MsgBox )
  	 		local wnd = state_m_NPCShopSellWnd.m_MsgBox:GetDlgChild("WndInfo")
  	 		assert( wnd )
  	 	
  	 		assert_equal( wnd:GetWndText(), expect_str )
  	 	end
  	 	local function Click_MsgBox_OKBtn()
  	 		state_m_NPCShopSellWnd = g_GameMain.m_NPCShopSell
  	 		assert( state_m_NPCShopSellWnd.m_MsgBox )
  	 		local wnd = state_m_NPCShopSellWnd.m_MsgBox:GetDlgChild("BtnOK")
  	 		assert( wnd )
  	 	 
  	 		assert( getmetatable(wnd) ~= nil )
  	 		wnd:SendMsg( WM_LBUTTONDOWN, 0, 0 )
  	 		wnd:SendMsg( WM_LBUTTONUP, 0, 0 )
  	 	
  	 	end  
  	 	local function Click_MsgBox_CancelBtn()
  	 		state_m_NPCShopSellWnd = g_GameMain.m_NPCShopSell
  	 		assert( state_m_NPCShopSellWnd.m_MsgBox )
  	 		local wnd = state_m_NPCShopSellWnd.m_MsgBox:GetDlgChild("BtnCancel")
  	 		assert( wnd )
  	 	
  	 		assert( getmetatable(wnd) ~= nil )
  	 		wnd:SendMsg( WM_LBUTTONDOWN, 0, 0 )
  	 		wnd:SendMsg( WM_LBUTTONUP, 0, 0 )
  	 	end 
  	 	
  	 	--û���㹻��Ǯ����ѡ��Ʒʱ
  	 	local btn  = sellGoodListWnd:GetSubItem(0, 0)		--�����۳��б��еĵ�һ����Ʒ
  	 	m_NPCShopSellWnd:OnCtrlmsg( btn, ITEM_RBUTTONCLICK,  0, 0 )
  	 	Check_MsgBox_Msg("��Ҳ��㣬ѡ�����ַ�ʽ��")
  	 	Click_MsgBox_CancelBtn()
  	 	
  	 	m_NPCShopSellWnd:OnCtrlmsg(  btn, ITEM_RBUTTONCLICK, 0, 0 )
  	 	Check_MsgBox_Msg("��Ҳ��㣬ѡ�����ַ�ʽ��")
  	 	Click_MsgBox_OKBtn()
  	 	Check_MsgBox_Msg( "û���㹻�Ľ�ҹ������Ʒ" )
  	 	Click_MsgBox_OKBtn()
																
			SetEvent(Event.Test.AddMoneyGM, false)
  	 	--�󶨽����Ŀ����,����ͨ������Թ�����ѡ��Ʒʱ,�Ҽ�ѡ��NPC�̵��е���Ʒֱ�ӹ���  	 	
  	 	Gac2Gas:GM_Execute( g_Conn, "$addbindingmoney(10000000)" )
  	 	
  	 	local strRet = WaitEvent(true,nil,Event.Test.AddBindingMoneyGM)
  	 	
																	
  	 	m_NPCShopSellWnd:OnCtrlmsg(  btn, ITEM_RBUTTONCLICK, 0, 0 )
  	 	
  	 	local strRet = WaitEvent(true, nil, Event.Test.ChangedMoneyCount)
  	 	
  	 	if strRet[1] == EEventState.Success then
  	 		if strRet[2][1] == true then
  	 			local Grid = m_MainBagWnd.m_ctItemRoom:GetGridByIndex( 0, 0, 1 )
  	 			local num = Grid:Size()
					assert_true( num == 1 )
					assert_true( g_MainPlayer.m_nBindMoney < 10000000)
				end
  	 	end		
  	 	SetEvent(Event.Test.ChangedMoneyCount, false)
  	
  		--�󶨽����Ŀ���Թ�����ѡ��Ʒ,���ѡ����Ʒ�϶�����������һ������
  		 m_NPCShopSellWnd:OnCtrlmsg( btn, ITEM_RBUTTONCLICK, 0, 0 )
  		 m_MainBagWnd:OnCtrlmsg( m_MainBagWnd.m_ctItemRoom, ITEM_LBUTTONCLICK , 0, 0 )
  		 local strRet = WaitEvent(true, nil, Event.Test.ChangedMoneyCount)
  		 if strRet[1] == EEventState.Success then
			if strRet[2][1] == true then
   		  		local Grid = m_MainBagWnd.m_ctItemRoom:GetGridByIndex( 0, 0, 1 )
   		  		local num = Grid:Size()
    	    	assert_true( num == 1)
    	    	assert_true( g_MainPlayer.m_nBindMoney < 10000000 )
			end
    	end		
    	SetEvent(Event.Test.ChangedMoneyCount, false)
    	
		 
		--���������������
			m_NPCShopSellWnd:OnCtrlmsg( m_NPCShopSellWnd:GetDlgChild("BuyMany_Btn"), BUTTON_LCLICK,  0, 0 )
			m_NPCShopSellWnd:OnCtrlmsg( btn, ITEM_LBUTTONCLICK,  0, 0 )
    	assert_true( m_NPCShopSellWnd.m_buyBatchWnd:IsShow() )
    	
    	m_NPCShopSellWnd:OnCtrlmsg(btn, BUTTON_LCLICK,  0, 0 )
    	assert_true( m_NPCShopSellWnd.m_buyBatchWnd:IsShow() )
    	m_NPCShopSellWnd.m_buyBatchWnd:GetDlgChild( "EditMoney" ):SetWndText( 3 )
    	m_NPCShopSellWnd.m_buyBatchWnd:OnCtrlmsg( m_NPCShopSellWnd.m_buyBatchWnd:GetDlgChild("BtnOk"), BUTTON_LCLICK, 0, 0 )
    	m_MainBagWnd:OnCtrlmsg( m_MainBagWnd.m_ctItemRoom, ITEM_LBUTTONCLICK , 0, 1 )
    	
    	local strRet = WaitEvent( true, nil, Event.Test.ChangedMoneyCount )
    	if strRet[1] == EEventState.Success then
    		if strRet[2][1] == true then
    			local Grid = m_MainBagWnd.m_ctItemRoom:GetGridByIndex( 0, 1, 1)
    			local num = Grid:Size()
					assert_true( num == 1 )
				end
    	end		
		SetEvent(Event.Test.ChangedMoneyCount,false)

		--NPC������"����"��ť���ܵĲ���
		m_NPCShopSellWnd:OnCtrlmsg(  m_NPCShopSellWnd:GetDlgChild("BuyBack"), BUTTON_LCLICK, 0, 0 )
		assert_false( m_NPCShopSellWnd:IsShow() )
		assert_true( m_NPCShopPlayerSoldWnd:IsShow() )
	end
  
  
	--NPC�̵깺�ش��ڼ����ܲ���
	function test_NPCShop:test_NPCShopPlayerSold()
    	local tbl = g_GameMain.m_PlayerSoldGoodsList
    	--������ͨ��GMָ��򿪵�
		
  		local m_NPCShopSellWnd = g_GameMain.m_NPCShopSell
  		local m_NPCShopPlayerSoldWnd = g_GameMain.m_NPCShopPlayerSold  
  		local m_MainBagWnd = g_GameMain.m_WndMainBag
			m_NPCShopPlayerSoldWnd:OnCtrlmsg(  m_NPCShopPlayerSoldWnd:GetDlgChild("Buy"), BUTTON_LCLICK, 0, 0 )
    	assert_true( m_NPCShopSellWnd:IsShow() )
			assert_false( m_NPCShopPlayerSoldWnd:IsShow() )
    	m_NPCShopSellWnd:ShowWnd(false)
    	m_NPCShopPlayerSoldWnd:ShowWnd( true )
    	
    	--����Ʒ�����ϳ�һ����Ʒ����NPC���ش���,����������Ʒ
    	local itemBtn  = m_NPCShopPlayerSoldWnd:GetDlgChild("Goods_01")		--�����۳��б��еĵ�һ����Ʒ
    	m_MainBagWnd:OnCtrlmsg(m_MainBagWnd.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 2  )
    	m_NPCShopPlayerSoldWnd:OnCtrlmsg(itemBtn, BUTTON_LCLICK, 0, 0 )
    	local strRet = WaitEvent( true, nil, Event.Test.ChangedMoneyCount )

	  	SetEvent( Event.Test.ChangedMoneyCount, false )
	  	if strRet == EEventState.Success then
				if strRet[2][1] == true then
	  		  local Grid = m_MainBagWnd.m_ctItemRoom:GetGridByIndex( 0, 2, 1 )
					local num = Grid:Size()
					assert_true( num == 0 )
					assert_equal( table.maxn(tbl), 1 )
      		end
    	end
   
			--����Ʒ�����ϳ�һ����Ʒ����NPC���ش�������������۳���Ʒ�Ĵ���,���ش˴����е���Ʒ
			m_MainBagWnd:OnCtrlmsg( m_MainBagWnd.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 0  )
			m_NPCShopPlayerSoldWnd:OnCtrlmsg( itemBtn, BUTTON_LCLICK, 0, 0 )
			local strRet = WaitEvent( true, nil,  Event.Test.ChangedMoneyCount )

			SetEvent( Event.Test.ChangedMoneyCount, false )
			if strRet == EEventState.Success then
				if strRet[2][1] == true then
					local Grid = m_MainBagWnd.m_ctItemRoom:GetGridByIndex( 0, 2, 1 )
					local num = Grid:Size()
					assert_true( num == 0 )
					assert_equal( table.maxn(tbl), 0 )
				end
    	end
    
    	local itemBtn2 = m_NPCShopPlayerSoldWnd:GetDlgChild("Goods_02")		--�����۳��б��еĵڶ�����Ʒ
   		--������Ʒ֮��,�����������ѡ�г��۵���Ʒ
   		m_NPCShopPlayerSoldWnd:OnCtrlmsg( itemBtn2, BUTTON_RIGHTCLICKDOWN, 0, 0 )
   			
   		local strRet = WaitEvent( true, nil, Event.Test.ChangedMoneyCount )
			SetEvent( Event.Test.ChangedMoneyCount, false )
			if strRet == EEventState.Success then
				if strRet[2][1] == true then	      
					local Grid = m_MainBagWnd.m_ctItemRoom:GetGridByIndex( 0, 2, 1 )
					local num = Grid:Size()
					assert_true( num == 1 )
					assert_equal( table.maxn(tbl),1 )
				end
			end
   		 
		m_MainBagWnd:OnCtrlmsg( m_MainBagWnd.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 0  )
		m_NPCShopPlayerSoldWnd:OnCtrlmsg( itemBtn, BUTTON_LCLICK, 0, 0 )
		local strRet = WaitEvent( true, nil, Event.Test.ChangedMoneyCount )
		SetEvent( Event.Test.ChangedMoneyCount, false )
		if strRet == EEventState.Success then
			if strRet[2][1] == true then
				local Grid = m_MainBagWnd.m_ctItemRoom:GetGridByIndex( 0, 1, 1 )
				local num = Grid:Size()
				assert_true( num == 0 )
				assert_equal( table.maxn(tbl), 2)
			end
		end

    	--ȫ���������������Ʒ
    	m_NPCShopPlayerSoldWnd:OnCtrlmsg( m_NPCShopPlayerSoldWnd:GetDlgChild("BuyBackAll"), BUTTON_LCLICK, 0, 0 )
    	local strRet = WaitEvent( true, nil, Event.Test.ChangedMoneyCount )
		SetEvent( Event.Test.ChangedMoneyCount, false )
		if strRet == EEventState.Success then
			if strRet[2][1] == true then
				local Grid = m_MainBagWnd.m_ctItemRoom:GetGridByIndex( 0, 1, 1 )
				local num = Grid:Size()
				assert_true( num == 3 )
				local Grid = m_MainBagWnd.m_ctItemRoom:GetGridByIndex( 0, 2, 1 )
				local num = Grid:Size()
				assert_true( num == 3 )
				assert_equal( table.maxn(tbl), 0 )
			end
		end
    
    	--NPC�̵깺�ش����е�"Buy"(����)��ť���ܵĲ���
    	local m_BuyBtn = m_NPCShopPlayerSoldWnd:GetDlgChild("Buy")    
    	m_NPCShopPlayerSoldWnd:OnCtrlmsg( m_BuyBtn, BUTTON_LCLICK, 0, 0 )
    	assert_false( m_NPCShopPlayerSoldWnd:IsShow())
    	assert_true( m_NPCShopSellWnd:IsShow() )
    	
    	m_NPCShopSellWnd:OnCtrlmsg(  m_NPCShopSellWnd:GetDlgChild("BuyBack"), BUTTON_LCLICK, 0, 0 )
		  
		--NPC�̵깺�ش��ڵĹرհ�ť
		m_NPCShopPlayerSoldWnd:OnCtrlmsg( m_NPCShopPlayerSoldWnd:GetDlgChild("Close"), BUTTON_LCLICK, 0, 0 )
		assert_false( m_NPCShopPlayerSoldWnd:IsShow() )
		assert_false( m_MainBagWnd:IsShow() )
	end        
           
	--�˳�����
	function test_NPCShop:TestEnd()
		controler:LoginOutFromGame()
	end
end