gac_require "test/common/CTstLoginControler"
gac_require "test/common/CTstMakeMgr"

function InitGacTestDynEquip(TestTest)
	local controler = {}
	local WndItemBag,WndMainBag = {},{}
	
	function TestTest:setup()
	end
	
	--�������
	function TestTest:TestBegin()
		controler = CTstLoginControler:new()
		controler:OneStepLoginEx( "DynEquip_Test", "DynEquip" )
		g_GameMain.m_FunctionArea:OnCtrlmsg( g_GameMain.m_FunctionArea:GetDlgChild("package"), BUTTON_LCLICK, 0, 0 )
		
		WndMainBag = g_GameMain.m_WndMainBag 
		--�㿪�����������,�ȴ�������Ϣ
		g_GameMain.m_FunctionArea:OnCtrlmsg( g_GameMain.m_FunctionArea.m_ChkBtnProp,BUTTON_LCLICK,0,0 )
		RoleStatus = g_GameMain.m_RoleStatus 
		
		--���������������
		BagMgr = CTstBagMgr:new(WndMainBag)
		--������Ϣ����
		--PlayInfoMgr = CTstPlayerInfoMgr:new()
		--���������
		--MakeEquipMgr = CTstMakeMgr:new()
		--MakeEquipMgr:OpenFuntion()
	end
	
	--[[
	function TestTest:TestOpenSmallBag()
		--����һ���±������������ŵ���һ��������
		--print("In the TestOpenSmallBag")
		BagMgr:AddItem(2,"������",1)
		BagMgr:PlaceBag2MainBag(0,0,0,0)
	end
	
	
	--ɾ����ʼ��װ��
	function TestTest:TestDelInitEquip()

		RoleStatus:OnCtrlmsg(RoleStatus.m_WndWear,BUTTON_LCLICK,0,0)
	 	g_GameMain:OnLButtonUp( 0, 0, 0 )
	 	local wnd = RoleStatus.m_WndWear.m_MsgBox:GetDlgChild("BtnOK")
		wnd:SendMsg( WM_LBUTTONDOWN, 0, 0 )
		wnd:SendMsg( WM_LBUTTONUP, 0, 0 )
		WaitEvent(true,nil,Event.Test.FetchEquip)
		SetEvent( Event.Test.FetchEquip,false, "" )
		assert_equal(nil, RoleStatus.m_WndWear.m_Info,"")
		
		RoleStatus:OnCtrlmsg(RoleStatus.m_WndWeapon,BUTTON_LCLICK,0,0)
	 	g_GameMain:OnLButtonUp( 0, 0, 0 )
	 	local wnd = RoleStatus.m_WndWeapon.m_MsgBox:GetDlgChild("BtnOK")
		wnd:SendMsg( WM_LBUTTONDOWN, 0, 0 )
		wnd:SendMsg( WM_LBUTTONUP, 0, 0 )
		WaitEvent(true,nil,Event.Test.FetchEquip)
		SetEvent( Event.Test.FetchEquip,false, "" )
		assert_equal(nil, RoleStatus.m_WndWeapon.m_Info,"")
	end
	--]]
	
	--��̬װ��
	function TestTest:TestUseStatic()
		BagMgr:AddItem(5,"1�ٽ�",1)
		BagMgr:AddItem(6,"�·�",1)
		BagMgr:AddItem(6,"ñ��",1)
		BagMgr:AddItem(6,"����",1)
		BagMgr:AddItem(6,"Ь��",1)
		--BagMgr:AddItem(7,"��ʼ����",1)
		BagMgr:AddItem(8,"�ҵĽ�ָ",1)	--��ָ
		BagMgr:AddItem(8,"�ҵĽ�ָ",1)	--��ָ
		local Mgr = g_GameMain.m_BagSpaceMgr
	
		BagMgr:UseItemInMainBag(0,0)
		local BagGrid = Mgr:GetGridByRoomPos(g_StoreRoomIndex.PlayerBag, 1)
		local nBigID,nIndex = BagGrid:GetType()
		assert_equal(nil, nBigID, '')

		BagMgr:UseItemInMainBag(0,1)
		local BagGrid = Mgr:GetGridByRoomPos(g_StoreRoomIndex.PlayerBag, 2)
		local nBigID,nIndex = BagGrid:GetType()
		assert_equal(nil, nBigID, '')

		BagMgr:UseItemInMainBag(0,2)
		local BagGrid = Mgr:GetGridByRoomPos(g_StoreRoomIndex.PlayerBag, 3)
		local nBigID,nIndex = BagGrid:GetType()
		assert_equal(nil, nBigID, '')
		
		BagMgr:UseItemInMainBag(0,3)
		local BagGrid = Mgr:GetGridByRoomPos(g_StoreRoomIndex.PlayerBag, 4)
		local nBigID,nIndex = BagGrid:GetType()
		assert_equal(nil, nBigID, '')
		
		BagMgr:UseItemInMainBag(0,4)
		local BagGrid = Mgr:GetGridByRoomPos(g_StoreRoomIndex.PlayerBag, 5)
		local nBigID,nIndex = BagGrid:GetType()
		assert_equal(nil, nBigID, '')
		
		BagMgr:UseItemInMainBag(0,5)
		local BagGrid = Mgr:GetGridByRoomPos(g_StoreRoomIndex.PlayerBag, 6)
		local nBigID,nIndex = BagGrid:GetType()
		assert_equal(nil, nBigID, '')
		
		BagMgr:UseItemInMainBag(1,0)
		local BagGrid = Mgr:GetGridByRoomPos(g_StoreRoomIndex.PlayerBag, 7)
		local nBigID,nIndex = BagGrid:GetType()
		assert_equal(nil, nBigID, '')
		
--		BagMgr:UseItemInMainBag(1,1)
--		local BagGrid = Mgr:GetGridByRoomPos(g_StoreRoomIndex.PlayerBag, 8)
--		local nBigID,nIndex = BagGrid:GetType()
--		assert_equal(nil, nBigID, '')
		
	end
	

	function TestTest:TestReLogin()
		controler:LoginOutFromGame()
		controler:OneStepReLoginEx( "DynEquip_Test", "DynEquip" )
		--���´򿪱���
		WndItemBag = g_GameMain.m_FunctionArea.m_WndItemBag
		--�㿪��������
		g_GameMain.m_FunctionArea:OnCtrlmsg( g_GameMain.m_FunctionArea:GetDlgChild("package"), BUTTON_LCLICK, 0, 0 )
		WndMainBag = g_GameMain.m_WndMainBag
		BagMgr = CTstBagMgr:new(WndMainBag)
		--�㿪�����������,�ȴ�������Ϣ
		SetEvent(Event.Test.PlayerInfo,false) --��Ϊ��װ��Ҳ��setevent�������������
		g_GameMain.m_FunctionArea:OnCtrlmsg( g_GameMain.m_FunctionArea.m_ChkBtnProp,BUTTON_LCLICK,0,0 )
		RoleStatus = g_GameMain.m_RoleStatus
	end
	
	--��ж��װ���ٴ���װ��
	function TestTest:TestFetchThenEquip()
		local Mgr = g_GameMain.m_BagSpaceMgr
		--����
		RoleStatus:OnCtrlmsg(RoleStatus.Part[12].iconbtn,BUTTON_LCLICK,0,0)
		BagMgr:MainBagClicked(0,0)
		WaitEvent(true,nil,Event.Test.FetchEquip)
		SetEvent( Event.Test.FetchEquip,false, "" )
		local BagGrid = Mgr:GetGridByRoomPos(g_StoreRoomIndex.PlayerBag, 1)
		local nBigID,nIndex = BagGrid:GetType()
		assert_equal(5, nBigID,"")
		BagMgr:UseItemInMainBag(0,0)
		assert_equal(0, BagGrid:Size(),"")

		--ȡ���ָ
		RoleStatus:OnCtrlmsg(RoleStatus.Part[4].iconbtn ,BUTTON_LCLICK,0,0)
		BagMgr:MainBagClicked(0,0)
		WaitEvent(true,nil,Event.Test.FetchEquip)
		SetEvent( Event.Test.FetchEquip,false, "" )
		nBigID,nIndex = BagGrid:GetType()
		assert_equal(8, nBigID,"")
		BagMgr:UseItemInMainBag(0,0)
		assert_equal(0, BagGrid:Size(),"")

		--ȡ�ҽ�ָ
		RoleStatus:OnCtrlmsg(RoleStatus.Part[5].iconbtn ,BUTTON_LCLICK,0,0)
		BagMgr:MainBagClicked(0,0)
		WaitEvent(true,nil,Event.Test.FetchEquip)
		SetEvent( Event.Test.FetchEquip,false, "" )
		nBigID,nIndex = BagGrid:GetType()
		assert_equal(8, nBigID,"")
		BagMgr:UseItemInMainBag(0,0)
		assert_equal(0, BagGrid:Size(),"")

		--����
--		RoleStatus:OnCtrlmsg(RoleStatus.m_WndAssociateWeapon,BUTTON_LCLICK,0,0)
--		BagMgr:MainBagClicked(0,0)
--		WaitEvent(true,nil,Event.Test.FetchEquip)
--		SetEvent( Event.Test.FetchEquip,false, "" )
--		nBigID,nIndex = BagGrid:GetType()
--		assert_equal(7, nBigID,"")
--		BagMgr:UseItemInMainBag(0,0)
--		assert_equal(0, BagGrid:Size(),"")
		--ͷ��
		RoleStatus:OnCtrlmsg(RoleStatus.Part[7].iconbtn ,BUTTON_LCLICK,0,0)
	 	BagMgr:MainBagClicked(0,0)
		WaitEvent(true,nil,Event.Test.FetchEquip)
		SetEvent( Event.Test.FetchEquip,false, "" )
		local BagGrid = Mgr:GetGridByRoomPos(g_StoreRoomIndex.PlayerBag, 1)
		nBigID,nIndex = BagGrid:GetType()
		assert_equal(6, nBigID,"")
		BagMgr:UseItemInMainBag(0,0)
		assert_equal(0, BagGrid:Size(),"")
		--�·�
		RoleStatus:OnCtrlmsg(RoleStatus.Part[9].iconbtn ,BUTTON_LCLICK,0,0)
		BagMgr:MainBagClicked(0,0)
		WaitEvent(true,nil,Event.Test.FetchEquip)
		SetEvent( Event.Test.FetchEquip,false, "" )
		nBigID,nIndex = BagGrid:GetType()
		assert_equal(6, nBigID,"")
		BagMgr:UseItemInMainBag(0,0)
		assert_equal(0, BagGrid:Size(),"")
		--����
		RoleStatus:OnCtrlmsg(RoleStatus.Part[3].iconbtn ,BUTTON_LCLICK,0,0)
		BagMgr:MainBagClicked(0,0)
		WaitEvent(true,nil,Event.Test.FetchEquip)
		SetEvent( Event.Test.FetchEquip,false, "" )
		nBigID,nIndex = BagGrid:GetType()
		assert_equal(6, nBigID,"")
		BagMgr:UseItemInMainBag(0,0)
		assert_equal(0, BagGrid:Size(),"")
		--Ь��
		RoleStatus:OnCtrlmsg(RoleStatus.Part[11].iconbtn ,BUTTON_LCLICK,0,0)
		BagMgr:MainBagClicked(0,0)
		WaitEvent(true,nil,Event.Test.FetchEquip)
		SetEvent( Event.Test.FetchEquip,false, "" )
		nBigID,nIndex = BagGrid:GetType()
		assert_equal(6, nBigID,"")
		BagMgr:UseItemInMainBag(0,0)
		assert_equal(0, BagGrid:Size(),"")
	end
	--ɾ��װ��
	function TestTest:TestDelEquip()
		--ɾ������
		RoleStatus:OnCtrlmsg(RoleStatus.Part[12].iconbtn,BUTTON_LCLICK,0,0)
	 	g_GameMain:OnLButtonUp( 0, 0, 0 )
	 	local wnd = RoleStatus.Part[12].iconbtn.m_MsgBox:GetDlgChild("BtnOK")
		wnd:SendMsg( WM_LBUTTONDOWN, 0, 0 )
		wnd:SendMsg( WM_LBUTTONUP, 0, 0 )
		WaitEvent(true,nil,Event.Test.FetchEquip)
		SetEvent( Event.Test.FetchEquip,false, "" )
		assert_equal(nil,RoleStatus.Part[12].iconbtn.m_Info,"")
		--ɾ�����ҽ�ָ
		RoleStatus:OnCtrlmsg(RoleStatus.Part[4].iconbtn,BUTTON_LCLICK,0,0)
	 	g_GameMain:OnLButtonUp( 0, 0, 0 )
	 	local wnd = RoleStatus.Part[4].iconbtn.m_MsgBox:GetDlgChild("BtnOK")
		wnd:SendMsg( WM_LBUTTONDOWN, 0, 0 )
		wnd:SendMsg( WM_LBUTTONUP, 0, 0 )
		WaitEvent(true,nil,Event.Test.FetchEquip)
		SetEvent( Event.Test.FetchEquip,false, "" )
		assert_equal(nil, RoleStatus.Part[4].iconbtn.m_Info,"")
		
		RoleStatus:OnCtrlmsg(RoleStatus.Part[5].iconbtn,BUTTON_LCLICK,0,0)
	 	g_GameMain:OnLButtonUp( 0, 0, 0 )
	 	wnd = RoleStatus.Part[5].iconbtn.m_MsgBox:GetDlgChild("BtnOK")
		wnd:SendMsg( WM_LBUTTONDOWN, 0, 0 )
		wnd:SendMsg( WM_LBUTTONUP, 0, 0 )
		WaitEvent(true,nil,Event.Test.FetchEquip)
		SetEvent( Event.Test.FetchEquip,false, "" )
		assert_equal(nil, RoleStatus.Part[5].iconbtn.m_Info,"")

		--ɾ������
		--
--		RoleStatus:OnCtrlmsg(RoleStatus.m_WndAssociateWeapon,BUTTON_LCLICK,0,0)
--	 	g_GameMain:OnLButtonUp( 0, 0, 0 )
--	 	local wnd = RoleStatus.m_WndAssociateWeapon.m_MsgBox:GetDlgChild("BtnOK")
--		wnd:SendMsg( WM_LBUTTONDOWN, 0, 0 )
--		wnd:SendMsg( WM_LBUTTONUP, 0, 0 )
--		WaitEvent(true,nil,Event.Test.FetchEquip)
--		SetEvent( Event.Test.FetchEquip,false, "" )
--		assert_equal(nil, RoleStatus.m_WndAssociateWeapon.m_Info,"")
		--
		--ͷ��
		RoleStatus:OnCtrlmsg(RoleStatus.Part[7].iconbtn,BUTTON_LCLICK,0,0)
	 	g_GameMain:OnLButtonUp( 0, 0, 0 )
	 	local wnd = RoleStatus.Part[7].iconbtn.m_MsgBox:GetDlgChild("BtnOK")
		wnd:SendMsg( WM_LBUTTONDOWN, 0, 0 )
		wnd:SendMsg( WM_LBUTTONUP, 0, 0 )
		WaitEvent(true,nil,Event.Test.FetchEquip)
		SetEvent( Event.Test.FetchEquip,false, "" )
		assert_equal(nil, RoleStatus.Part[7].iconbtn.m_Info,"")
		--�·�
		RoleStatus:OnCtrlmsg(RoleStatus.Part[9].iconbtn,BUTTON_LCLICK,0,0)
	 	g_GameMain:OnLButtonUp( 0, 0, 0 )
	 	local wnd = RoleStatus.Part[9].iconbtn.m_MsgBox:GetDlgChild("BtnOK")
		wnd:SendMsg( WM_LBUTTONDOWN, 0, 0 )
		wnd:SendMsg( WM_LBUTTONUP, 0, 0 )
		WaitEvent(true,nil,Event.Test.FetchEquip)
		SetEvent( Event.Test.FetchEquip,false, "" )
		assert_equal(nil, RoleStatus.Part[9].iconbtn.m_Info,"")
		--����
		RoleStatus:OnCtrlmsg(RoleStatus.Part[3].iconbtn,BUTTON_LCLICK,0,0)
	 	g_GameMain:OnLButtonUp( 0, 0, 0 )
	 	local wnd = RoleStatus.Part[3].iconbtn.m_MsgBox:GetDlgChild("BtnOK")
		wnd:SendMsg( WM_LBUTTONDOWN, 0, 0 )
		wnd:SendMsg( WM_LBUTTONUP, 0, 0 )
		WaitEvent(true,nil,Event.Test.FetchEquip)
		SetEvent( Event.Test.FetchEquip,false, "" )
		assert_equal(nil, RoleStatus.Part[3].iconbtn.m_Info,"")
		--ɾ��Ь��
		RoleStatus:OnCtrlmsg(RoleStatus.Part[11].iconbtn,BUTTON_LCLICK,0,0)
		g_GameMain:OnLButtonUp( 0, 0, 0 )
	 	local wnd = RoleStatus.Part[11].iconbtn.m_MsgBox:GetDlgChild("BtnOK")
		wnd:SendMsg( WM_LBUTTONDOWN, 0, 0 )
		wnd:SendMsg( WM_LBUTTONUP, 0, 0 )
		WaitEvent(true,nil,Event.Test.FetchEquip)
		SetEvent( Event.Test.FetchEquip,false, "" )
		assert_equal(nil, RoleStatus.Part[11].iconbtn.m_Info,"")
	end
	
	function TestTest:TestEnd()
		controler:LoginOutFromGame()
	end
	function TestTest:teardown()
	end
end