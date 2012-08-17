gac_gas_require "item/item_info_mgr/ItemInfoMgr"
gac_require "test/common/CTstLoginControler"

function InitGacPlayerBag( TestTest )
	local controler = {}
	local WndItemBag,WndMainBag,ctItemRoom,WndMainDepot,m_lcAddBagSlotsWnd = {},{},{},{},{}
	
	function TestTest:setup()
	end
	--�������
	function TestTest:TestBegin()
		controler = CTstLoginControler:new()
		controler:OneStepLogin()
		
	  WndItemBag = g_GameMain.m_FunctionArea.m_WndItemBag
	
		--�㿪��������
		g_GameMain.m_FunctionArea:OnCtrlmsg( g_GameMain.m_FunctionArea:GetDlgChild("package"), BUTTON_LCLICK, 0, 0 )
		WndMainBag = g_GameMain.m_WndMainBag
		ctItemRoom = WndMainBag.m_ctItemRoom
	  m_lcAddBagSlotsWnd = g_GameMain.m_WndBagSlots.m_lcAddBagSlots
	
		--�㿪�ֿ�
		WndItemBag:OnCtrlmsg( WndItemBag.m_BtnDepot,BUTTON_LCLICK,0,0 )
		WndMainDepot = g_GameMain.m_WndDepot
		--���������������
		BagMgr = CTstBagMgr:new(WndMainBag)
		
		MasterSkillArea = g_GameMain.m_MasterSkillArea
		MainSkillsToolBar = g_GameMain.m_MainSkillsToolBar
	end
	
	--[[
	--ģ�������ӳ٣�ѡ��Ŀ��󣬵���˶����ͬ�ĵط�
	function TestTest:TestMove2MorePlace()
	 	 Gac2Gas:GM_Execute( g_Conn, "$additem(1,1,3)" );
		 local strRet = WaitEvent(true,nil,Event.Test.AddItem)
		 SetEvent(Event.Test.AddItem,false)
		 local Mgr = g_GameMain.m_BagSpaceMgr
		 local srcPos = ctItemRoom:GetPosByIndex(0,0)
		 local descPos1 = ctItemRoom:GetPosByIndex(0,1)
		 local descPos2 = ctItemRoom:GetPosByIndex(0,2)
		 
		 local space = Mgr:GetSpace(g_StoreRoomIndex.PlayerBag)
		 assert(space~=nil)
		 local srcGrid = space:GetGrid(srcPos)
		 local descGrid1 = space:GetGrid(descPos1)
		 local descGrid2 = space:GetGrid(descPos2)
		 
		 WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 0)
		 WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 1)
		 
		 WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 2)
		 
		 strRet = WaitEvent(true,nil,Event.Test.ReplaceItem)
		 SetEvent(Event.Test.ReplaceItem,false)
		 
		 strRet = WaitEvent(true,nil,Event.Test.MoveItem)
		 SetEvent(Event.Test.MoveItem,false)
		 
		 
		 assert_equal(0, srcGrid:Size(),"")
		 assert_equal(3, descGrid1:Size(),"")
		 assert_equal(0, descGrid2:Size(),"")
		 
		 Gac2Gas:GM_Execute( g_Conn, "$delitem(1,1,3)" );
		 strRet = WaitEvent(true,nil,Event.Test.DelItem)
		 SetEvent(Event.Test.DelItem,false)
	end
	--]]
	
  --��gm�������ɾ����Ʒ
	function TestTest:TestAddDelItemGM()
		-- print("In the TestAddDelItemGM")
		 --db()
		 BagMgr:AddItem(1,"��Ůͼ",5)
		 -- print("2")
		 local Mgr = g_GameMain.m_BagSpaceMgr
		 local srcPos,descPos = ctItemRoom:GetPosByIndex(0,0),ctItemRoom:GetPosByIndex(0,1)
		 local space = Mgr:GetSpace(g_StoreRoomIndex.PlayerBag)
		 assert(space~=nil)
		 local srcGrid = space:GetGrid(srcPos)
		 local descGrid = space:GetGrid(descPos)
		 assert_equal(3, srcGrid:Size(),"")
		 assert_equal(2, descGrid:Size(),"")
		 --print("1")
		 BagMgr:DelItem(1,"��Ůͼ",5)
		 local srcGrid = space:GetGrid(srcPos)
		 local descGrid = space:GetGrid(descPos)
		 assert_equal(0, srcGrid:Size(),"")
		 assert_equal(0, descGrid:Size(),"")
		 --print("3")
	end
	
	--*************************������������� BEGIN*************************************
	--����Ʒ���ϵ���Ʒͼ���Ϸŵ�������ϣ�Ȼ�󵥻����Ҽ�ʹ��
	--[[
	function TestTest:TestDragItemOnShortcut()
		--���һЩ��Ʒ
		Gac2Gas:GM_Execute( g_Conn, "$additem(1,\"��Ůͼ\",5)" )
		local strRet = WaitEvent(true,nil,Event.Test.AddItem)
		SetEvent(Event.Test.AddItem,false)
		
		for i=1, 10 do
			WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 0)
			local state = g_WndMouse:GetCursorState()
			assert_equal(ECursorState.eCS_PickupItem, state, "")
		
			MasterSkillArea:OnCtrlmsg(MasterSkillArea.m_WndSkill, ITEM_LBUTTONCLICK, i-1, 0)
			state = g_WndMouse:GetCursorState()
			assert_equal(ECursorState.eCS_Normal, state, "")
			local tblShortcutPiece = MasterSkillArea.m_WndSkill:GetTblShortcutPiece()
			local Piece = tblShortcutPiece[i]
			local PieceState = Piece:GetState()
			assert_equal(EShortcutPieceState.eSPS_Item, PieceState, "")
			
			--�����
			MasterSkillArea:OnCtrlmsg(MasterSkillArea.m_WndSkill, ITEM_LBUTTONCLICK, i-1, 0)
			--���Ҽ�
			Piece:OnRButtonClick(0,0,0)
		end
		
	end
	
	--����������ϵ�ͼ���ƶ����������ϣ�Ȼ�󵥻����Ҽ�ʹ��
	function TestTest:TestMoveShortcut()
		for i=1, 10 do
			local tblShortcutPiece1 = MasterSkillArea.m_WndSkill:GetTblShortcutPiece()
			local Piece1 = tblShortcutPiece1[i]
			Piece1:OnDrag(0,0)
			local state = g_WndMouse:GetCursorState()
			assert_equal(ECursorState.eCS_PickupItemShortcut, state, "")
			assert_equal(EShortcutPieceState.eSPS_None, Piece1:GetState(), "")
			
			MainSkillsToolBar:OnCtrlmsg(MainSkillsToolBar.m_WndSkill, ITEM_LBUTTONCLICK, 0, i-1)
			state = g_WndMouse:GetCursorState()
			assert_equal(ECursorState.eCS_Normal, state, "")
			local tblShortcutPiece2 = MainSkillsToolBar.m_WndSkill:GetTblShortcutPiece()
			local Piece2 = tblShortcutPiece2[i]
			assert_equal(EShortcutPieceState.eSPS_Item, Piece2:GetState(), "")
			
			--�����
			MainSkillsToolBar:OnCtrlmsg(MainSkillsToolBar.m_WndSkill, ITEM_LBUTTONCLICK, 0, i-1)
			--���Ҽ�
			Piece2:OnRButtonClick(0,0,0)
		end
	end
	
	--��������ϵ�ͼ�궪��
	function TestTest:TestThrowAwayShortcut()
		for i=1, 10 do
			local tblShortcutPiece2 = MainSkillsToolBar.m_WndSkill:GetTblShortcutPiece()
			local Piece2 = tblShortcutPiece2[i]
			Piece2:OnDrag(0,0)
			local state = g_WndMouse:GetCursorState()
			assert_equal(ECursorState.eCS_PickupItemShortcut, state, "")
			assert_equal(EShortcutPieceState.eSPS_None, Piece2:GetState(), "")
			
			g_GameMain:OnLButtonUp(0,0,0)
			state = g_WndMouse:GetCursorState()
			assert_equal(ECursorState.eCS_Normal, state, "")
		end
	end
	
	--������Ʒͼ��
	function TestTest:TestSwapShortcutIcons()
	
		Gac2Gas:GM_Execute( g_Conn, "$additem(5,\"1�ٽ�\",3)" )
		local strRet = WaitEvent(true,nil,Event.Test.AddItem)
		SetEvent(Event.Test.AddItem,false)
		
	  --�Ϸŵ�1��ͼ��
	  WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 0)
		local state = g_WndMouse:GetCursorState()
		assert_equal(ECursorState.eCS_PickupItem, state, "")
		
		MasterSkillArea:OnCtrlmsg(MasterSkillArea.m_WndSkill, ITEM_LBUTTONCLICK, 0, 0)
		state = g_WndMouse:GetCursorState()
		assert_equal(ECursorState.eCS_Normal, state, "")
		local tblShortcutPiece = MasterSkillArea.m_WndSkill:GetTblShortcutPiece()
		local Piece = tblShortcutPiece[1]
		local PieceState = Piece:GetState()
		assert_equal(EShortcutPieceState.eSPS_Item, PieceState, "")
		local uBigID1, uIndex1, uGlobalID1, num1 = Piece:GetItemContext()
		
		--�Ϸŵ�2��ͼ��
		WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 1)
		state = g_WndMouse:GetCursorState()
		assert_equal(ECursorState.eCS_PickupItem, state, "")
		
		MasterSkillArea:OnCtrlmsg(MasterSkillArea.m_WndSkill, ITEM_LBUTTONCLICK, 1, 0)
		state = g_WndMouse:GetCursorState()
		assert_equal(ECursorState.eCS_Normal, state, "")
		Piece = tblShortcutPiece[2]
		PieceState = Piece:GetState()
		assert_equal(EShortcutPieceState.eSPS_Item, PieceState, "")
		local uBigID2, uIndex2, uGlobalID2, num2 = Piece:GetItemContext()
		
		--��1��ͼ��͵�2��ͼ�꽻��
		Piece:OnDrag(0,0) --�����2��ͼ��
		MasterSkillArea:OnCtrlmsg(MasterSkillArea.m_WndSkill, ITEM_LBUTTONCLICK, 0, 0) --�����1������
		MasterSkillArea:OnCtrlmsg(MasterSkillArea.m_WndSkill, ITEM_LBUTTONCLICK, 1, 0) --�����2������
		state = g_WndMouse:GetCursorState()
		assert_equal(ECursorState.eCS_Normal, state, "")
		
		Piece = tblShortcutPiece[1]
		local uBigID1new, uIndex1new, uGlobalID1new, num1new = Piece:GetItemContext()
		Piece = tblShortcutPiece[2]
		local uBigID2new, uIndex2new, uGlobalID2new, num2new = Piece:GetItemContext()
		
		assert_equal(uBigID1, uBigID2new, "")
		assert_equal(uIndex1, uIndex2new, "")
		assert_equal(uGlobalID1, uGlobalID2new, "")
		assert_equal(num1, num2new, "")
		
		assert_equal(uBigID2, uBigID1new, "")
		assert_equal(uIndex2, uIndex1new, "")
		assert_equal(uGlobalID2, uGlobalID1new, "")
		assert_equal(num2, num1new, "")
		
		--�ٴ���Ʒ�����϶�һ��ͼ��
		WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 0)
		local state, context = g_WndMouse:GetCursorState()
		
		local uBigIDCursor, uIndexCursor, uGlobalIDCursor = g_WndMouse:GetItemBigSmallGlobalID(context[1], context[2], context[3])
		local numCursor = g_GameMain.m_BagSpaceMgr:GetItemCountByType(uBigIDCursor, uIndexCursor)
		
		assert_equal(ECursorState.eCS_PickupItem, state, "")
		
		--�������ϵĵ�1��ͼ�꽻��
		MasterSkillArea:OnCtrlmsg(MasterSkillArea.m_WndSkill, ITEM_LBUTTONCLICK, 0, 0) --�����1������
		Piece = tblShortcutPiece[1]
		local uBigID1newnew, uIndex1newnew, uGlobalID1newnew, num1newnew = Piece:GetItemContext()
		assert_equal(uBigIDCursor, uBigID1newnew, "")
		assert_equal(uIndexCursor, uIndex1newnew, "")
		assert_equal(uGlobalIDCursor, uGlobalID1newnew, "")
		assert_equal(numCursor, num1newnew, "")
		
		state, context = g_WndMouse:GetCursorState()
		assert_equal(uBigID1new, context[1], "")
		assert_equal(uIndex1new, context[2], "")
		assert_equal(uGlobalID1new, context[3], "")
		assert_equal(num1new, context[4], "")
		
		--������ϵ�ͼ�궪��
		g_GameMain:OnLButtonUp(0,0,0)
		
		--ɾ����Ʒ
		Gac2Gas:GM_Execute( g_Conn, "$delitem(1,\"��Ůͼ\",5)" );
		strRet = WaitEvent(true,nil,Event.Test.DelItem)
		SetEvent(Event.Test.DelItem,false)
		
		Gac2Gas:GM_Execute( g_Conn, "$delitem(5,\"1�ٽ�\",3)" );
		strRet = WaitEvent(true,nil,Event.Test.DelItem)
		SetEvent(Event.Test.DelItem,false)
	end
	
	--*************************������������� END***************************************
	--]]
	--�ƶ���Ʒ
	function TestTest:TestMoveToEmpty()
	-- print("In the TestMoveToEmpty")
		 Gac2Gas:GM_Execute( g_Conn, "$additem(1,\"��Ůͼ\",5)" );
		 local strRet = WaitEvent(true,nil,Event.Test.AddItem)
		 SetEvent(Event.Test.AddItem,false)
		 
		 WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 0)
		 WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 2, 2)
		 strRet = WaitEvent(true,nil,Event.Test.ReplaceItem)
		 SetEvent(Event.Test.ReplaceItem,false)
		 
		 
		 local Mgr = g_GameMain.m_BagSpaceMgr
		 local srcPos,descPos = ctItemRoom:GetPosByIndex(0,0),ctItemRoom:GetPosByIndex(2,2)
		 local space = Mgr:GetSpace(g_StoreRoomIndex.PlayerBag)
		 assert(space~=nil)
		 local srcGrid = space:GetGrid(srcPos)
		 local descGrid = space:GetGrid(descPos)
		 assert_equal(0, srcGrid:Size(),"")
		 assert_equal(3, descGrid:Size(),"")
		
		 Gac2Gas:GM_Execute( g_Conn, "$delitem(1,\"��Ůͼ\",5)" );
		 strRet = WaitEvent(true,nil,Event.Test.DelItem)
		 SetEvent(Event.Test.DelItem,false)
	end
	
	--�ϲ���Ʒ
	function TestTest:TestMoveItem()
	--print("In the TestMoveItem")
		 Gac2Gas:GM_Execute( g_Conn, "$additem(1,\"��Ůͼ\",5)" );
		 local strRet = WaitEvent(true,nil,Event.Test.AddItem)
		 SetEvent(Event.Test.AddItem,false)
		 
		 local Mgr = g_GameMain.m_BagSpaceMgr
		 local srcPos,descPos = ctItemRoom:GetPosByIndex(0,0),ctItemRoom:GetPosByIndex(0,1)
		 local space = Mgr:GetSpace(g_StoreRoomIndex.PlayerBag)
		 assert(space~=nil)
		 local srcGrid = space:GetGrid(srcPos)
		 local descGrid = space:GetGrid(descPos)
		 assert_equal(3, srcGrid:Size(),"")
		 assert_equal(2, descGrid:Size(),"")
		 
		 WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 0)
		 WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 1)
		 strRet = WaitEvent(true,nil,Event.Test.MoveItem)
		 SetEvent(Event.Test.MoveItem,false)
		 
		 assert_equal(2, srcGrid:Size(),"")
		 assert_equal(3, descGrid:Size(),"")
		
		 Gac2Gas:GM_Execute( g_Conn, "$delitem(1,\"��Ůͼ\",5)" );
		 strRet = WaitEvent(true,nil,Event.Test.DelItem)
		 SetEvent(Event.Test.DelItem,false)
	end
	
	--������Ʒ
	function TestTest:TestReplaceItem()
	--print("In the TestReplaceItem")
	 	 Gac2Gas:GM_Execute( g_Conn, "$additem(1,\"��Ůͼ\",3)" );
		 local strRet = WaitEvent(true,nil,Event.Test.AddItem)
		 SetEvent(Event.Test.AddItem,false)
		 
		 Gac2Gas:GM_Execute( g_Conn, "$additem(1,\"Сѩ��\",1)" );
		 local strRet = WaitEvent(true,nil,Event.Test.AddItem)
		 SetEvent(Event.Test.AddItem,false)
		 
		 local Mgr = g_GameMain.m_BagSpaceMgr
		 local srcPos,descPos = ctItemRoom:GetPosByIndex(0,0),ctItemRoom:GetPosByIndex(0,1)
		 local space = Mgr:GetSpace(g_StoreRoomIndex.PlayerBag)
		 assert(space~=nil)
		 local srcGrid = space:GetGrid(srcPos)
		 local descGrid = space:GetGrid(descPos)
		 assert_equal(3, srcGrid:Size(),"")
		 assert_equal(1, descGrid:Size(),"")
		 WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 0)
		 WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 1)
		 strRet = WaitEvent(true,nil,Event.Test.ReplaceItem)
		 SetEvent(Event.Test.ReplaceItem,false)
		 
		 --��������������ݣ�Ҫ���»�ȡһ��
		 srcGrid = space:GetGrid(srcPos)
		 descGrid = space:GetGrid(descPos)
		 assert_equal(1, srcGrid:Size(),"")
		 assert_equal(3, descGrid:Size(),"")
		
		 Gac2Gas:GM_Execute( g_Conn, "$delitem(1,\"Сѩ��\",1)" );
		 strRet = WaitEvent(true,nil,Event.Test.DelItem)
		 SetEvent(Event.Test.DelItem,false)
		 
		 Gac2Gas:GM_Execute( g_Conn, "$delitem(1,\"��Ůͼ\",3)" );
		 strRet = WaitEvent(true,nil,Event.Test.DelItem)
		 SetEvent(Event.Test.DelItem,false)
	end

	--�𵽿յ�λ��
	function TestTest:TestSplite2EmptyItem()
	--print("In the TestSplite2EmptyItem")
		 Gac2Gas:GM_Execute( g_Conn, "$additem(1,\"��Ůͼ\",5)" );
		 local strRet = WaitEvent(true,nil,Event.Test.AddItem)
		 SetEvent(Event.Test.AddItem,false)
		 
		 	
		 WndMainBag:OnCtrlmsg(WndMainBag.m_btnSplit,BUTTON_LCLICK, 0, 0)
		 WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 0)
		 WndMainBag.m_WndSplit:OnCtrlmsg(WndMainBag.m_WndSplit.m_BtnOK,BUTTON_LCLICK,0,0)
		 WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 2, 2)
		 strRet = WaitEvent(true,nil,Event.Test.SplitItem)
		 SetEvent(Event.Test.SplitItem,false)
		 
		 
		 local Mgr = g_GameMain.m_BagSpaceMgr
		 local srcPos,descPos = ctItemRoom:GetPosByIndex(0,0),ctItemRoom:GetPosByIndex(2,2)
		 local space = Mgr:GetSpace(g_StoreRoomIndex.PlayerBag)
		 assert(space~=nil)
		 local srcGrid = space:GetGrid(srcPos)
		 local descGrid = space:GetGrid(descPos)
		 assert_equal(2, srcGrid:Size(),"")
		 assert_equal(1, descGrid:Size(),"")
		
		 Gac2Gas:GM_Execute( g_Conn, "$delitem(1,\"��Ůͼ\",5)" );
		 strRet = WaitEvent(true,nil,Event.Test.DelItem)
		 SetEvent(Event.Test.DelItem,false)
	end
	
	--��δ����λ��
	function TestTest:TestSplite2NotFullItem()
	--print("In the TestSplite2NotFullItem")
		 Gac2Gas:GM_Execute( g_Conn, "$additem(1,\"��Ůͼ\",5)" );
		 local strRet = WaitEvent(true,nil,Event.Test.AddItem)
		 SetEvent(Event.Test.AddItem,false)
		 
		 	
		 WndMainBag:OnCtrlmsg(WndMainBag.m_btnSplit,BUTTON_LCLICK, 0, 0)
		 WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 0)
		 WndMainBag.m_WndSplit:OnCtrlmsg(WndMainBag.m_WndSplit.m_BtnOK,BUTTON_LCLICK,0,0)
		 WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 1)
		 strRet = WaitEvent(true,nil,Event.Test.SplitItem)
		 SetEvent(Event.Test.SplitItem,false)
		 
		 
		 local Mgr = g_GameMain.m_BagSpaceMgr
		 local srcPos,descPos = ctItemRoom:GetPosByIndex(0,0),ctItemRoom:GetPosByIndex(0,1)
		 local space = Mgr:GetSpace(g_StoreRoomIndex.PlayerBag)
		 assert(space~=nil)
		 local srcGrid = space:GetGrid(srcPos)
		 local descGrid = space:GetGrid(descPos)
		 assert_equal(2, srcGrid:Size(),"")
		 assert_equal(3, descGrid:Size(),"")
		
		 Gac2Gas:GM_Execute( g_Conn, "$delitem(1,\"��Ůͼ\",5)" );
		 strRet = WaitEvent(true,nil,Event.Test.DelItem)
		 SetEvent(Event.Test.DelItem,false)
	end
	
	--������λ�ã����������ش���client����
	function TestTest:TestSplite2FullItem()
	--print("In the TestSplite2FullItem")
		 Gac2Gas:GM_Execute( g_Conn, "$additem(1,\"��Ůͼ\",5)" );
		 local strRet = WaitEvent(true,nil,Event.Test.AddItem)
		 SetEvent(Event.Test.AddItem,false)
		 
		 	
		 WndMainBag:OnCtrlmsg(WndMainBag.m_btnSplit,BUTTON_LCLICK, 0, 0)
		 WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 1)
		 WndMainBag.m_WndSplit:OnCtrlmsg(WndMainBag.m_WndSplit.m_BtnOK,BUTTON_LCLICK,0,0)
		 WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 0)
		 strRet = WaitEvent(true,nil,Event.Test.SplitItem)
		 SetEvent(Event.Test.SplitItem,false)
		 
		 
		 local Mgr = g_GameMain.m_BagSpaceMgr
		 local srcPos,descPos = ctItemRoom:GetPosByIndex(0,0),ctItemRoom:GetPosByIndex(0,1)
		 local space = Mgr:GetSpace(g_StoreRoomIndex.PlayerBag)
		 assert(space~=nil)
		 local srcGrid = space:GetGrid(srcPos)
		 local descGrid = space:GetGrid(descPos)
		 assert_equal(3, srcGrid:Size(),"")
		 assert_equal(2, descGrid:Size(),"")
		
		 Gac2Gas:GM_Execute( g_Conn, "$delitem(1,\"��Ůͼ\",5)" );
		 strRet = WaitEvent(true,nil,Event.Test.DelItem)
		 SetEvent(Event.Test.DelItem,false)
	end
	
	--�𵽲�ͬ����Ʒ�����������ش���client������
	function TestTest:TestSplite2OtherItem()
	-- print("In the TestSplite2OtherItem")
		 Gac2Gas:GM_Execute( g_Conn, "$additem(1,\"��Ůͼ\",3)" );
		 local strRet = WaitEvent(true,nil,Event.Test.AddItem)
		 SetEvent(Event.Test.AddItem,false)
		 
		 Gac2Gas:GM_Execute( g_Conn, "$additem(1,\"Сѩ��\",1)" );
		 local strRet = WaitEvent(true,nil,Event.Test.AddItem)
		 SetEvent(Event.Test.AddItem,false)
		 
		 local Mgr = g_GameMain.m_BagSpaceMgr
		 local srcPos,descPos = ctItemRoom:GetPosByIndex(0,0),ctItemRoom:GetPosByIndex(0,1)
		 local space = Mgr:GetSpace(g_StoreRoomIndex.PlayerBag)
		 assert(space~=nil)
		 local srcGrid = space:GetGrid(srcPos)
		 local descGrid = space:GetGrid(descPos)
		 assert_equal(3, srcGrid:Size(),"")
		 assert_equal(1, descGrid:Size(),"")
		 
		 --�����ְ�ť��ѡ����Ŀ�꣬ȷ�ϲ����Ŀ�����ò����Ʒ
		 WndMainBag:OnCtrlmsg(WndMainBag.m_btnSplit,BUTTON_LCLICK, 0, 0)
		 WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 0)
		 WndMainBag.m_WndSplit:OnCtrlmsg(WndMainBag.m_WndSplit.m_BtnOK,BUTTON_LCLICK,0,0)
		 WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 1)
		 strRet = WaitEvent(true,nil,Event.Test.SplitItem)
		 SetEvent(Event.Test.SplitItem,false)
		 
		 

		 assert_equal(3, srcGrid:Size(),"")
		 assert_equal(1, descGrid:Size(),"")
		
		 Gac2Gas:GM_Execute( g_Conn, "$delitem(1,\"Сѩ��\",1)" );
		 strRet = WaitEvent(true,nil,Event.Test.DelItem)
		 SetEvent(Event.Test.DelItem,false)
		 
		 Gac2Gas:GM_Execute( g_Conn, "$delitem(1,\"��Ůͼ\",3)" );
		 strRet = WaitEvent(true,nil,Event.Test.DelItem)
		 SetEvent(Event.Test.DelItem,false)
	end
	
	--��TestPlaceBag��TestFetchBag��������˳���ǲ��ܵ�����
	--������Ʒ�ķ��ã�TestFetchBag���һ��ɾ����ȫ���ı���
	function TestTest:TestPlaceBag()
	--print("In the TestPlaceBag")
		Gac2Gas:GM_Execute( g_Conn, "$additem(2,\"�󱳰�\",1)" );
	 	local strRet = WaitEvent(true,nil,Event.Test.AddItem)
	 	SetEvent(Event.Test.AddItem,false)
	 	WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 0)
	 	g_GameMain.m_WndBagSlots:OnCtrlmsg(m_lcAddBagSlotsWnd, ITEM_LBUTTONCLICK, 0, 0)
	 	
	 	strRet = WaitEvent(true,nil,Event.Test.PlaceBag)
		SetEvent(Event.Test.PlaceBag,false)
	
		local Mgr = g_GameMain.m_BagSpaceMgr
		local spaceMainBag = Mgr:GetSpace(g_StoreRoomIndex.PlayerBag)
		local spaceMainAddSlots = Mgr:GetSpace(g_AddRoomIndexClient.PlayerExpandBag)
		
		assert(nil~=spaceMainBag, "spaceMainBag Ϊnil")
		assert(nil~=spaceMainAddSlots, "spaceMainAddSlots Ϊnil")
		
		local srcGrid = Mgr:GetGridByRoomPos(g_StoreRoomIndex.PlayerBag, 1)
		local descGrid = Mgr:GetGridByRoomPos(g_AddRoomIndexClient.PlayerExpandBag, 1)

		assert_equal(0, srcGrid:Size(),"����û�д���������������")
		assert_equal(1, descGrid:Size(),"����û�зŵ���������")
	end
	
	function TestTest:TestMoveBagInSlot()
		--print("In the TestMoveBagInSlot")
		g_GameMain.m_WndBagSlots:OnCtrlmsg(m_lcAddBagSlotsWnd, BUTTON_DRAG, 0, 0)
		g_GameMain.m_WndBagSlots:OnCtrlmsg(m_lcAddBagSlotsWnd, ITEM_LBUTTONCLICK , 0, 1)
		
		strRet = WaitEvent(true,nil, Event.Test.Change2Bag)
		SetEvent( Event.Test.Change2Bag,false)
	
		g_GameMain.m_WndBagSlots:OnCtrlmsg(m_lcAddBagSlotsWnd, BUTTON_DRAG, 0, 1)
		g_GameMain.m_WndBagSlots:OnCtrlmsg(m_lcAddBagSlotsWnd, ITEM_LBUTTONCLICK, 0, 2)
		
		strRet = WaitEvent(true,nil,Event.Test.Change2Bag)
		SetEvent(Event.Test.Change2Bag,false)
		
		g_GameMain.m_WndBagSlots:OnCtrlmsg(m_lcAddBagSlotsWnd, BUTTON_DRAG, 0, 2)
		g_GameMain.m_WndBagSlots:OnCtrlmsg(m_lcAddBagSlotsWnd, ITEM_LBUTTONCLICK, 0, 3)
		
		strRet = WaitEvent(true,nil,Event.Test.Change2Bag)
		SetEvent(Event.Test.Change2Bag,false)
		
		g_GameMain.m_WndBagSlots:OnCtrlmsg(m_lcAddBagSlotsWnd, BUTTON_DRAG, 0, 3)
		g_GameMain.m_WndBagSlots:OnCtrlmsg(m_lcAddBagSlotsWnd, ITEM_LBUTTONCLICK, 0, 0)
		
		strRet = WaitEvent(true,nil,Event.Test.Change2Bag)
		SetEvent(Event.Test.Change2Bag,false)
	end
 
	function TestTest:TestChange2Bag()
		--print("In the TestChange2Bag")
		Gac2Gas:GM_Execute( g_Conn, "$additem(2,\"�󱳰�\",1)" );
		local strRet = WaitEvent(true,nil,Event.Test.AddItem)
	 	SetEvent(Event.Test.AddItem,false)
	 	--print("test")	
		Gac2Gas:GM_Execute( g_Conn, "$additem(2,\"�󱳰�\",1)" );
		local strRet = WaitEvent(true,nil,Event.Test.AddItem)
	 	SetEvent(Event.Test.AddItem,false)
	 	
	 	WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 0)
	 	g_GameMain.m_WndBagSlots:OnCtrlmsg(m_lcAddBagSlotsWnd, ITEM_LBUTTONCLICK, 0, 1)
	 	
	 	strRet = WaitEvent(true,nil,Event.Test.PlaceBag)
		SetEvent(Event.Test.PlaceBag,false)
		
		WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 1)
	 	g_GameMain.m_WndBagSlots:OnCtrlmsg(m_lcAddBagSlotsWnd, ITEM_LBUTTONCLICK, 0, 3)
	 	
	 	strRet = WaitEvent(true,nil,Event.Test.PlaceBag)
		SetEvent(Event.Test.PlaceBag,false)

		-- ������ϵ�һ��Bag
		g_GameMain.m_WndBagSlots:OnCtrlmsg(m_lcAddBagSlotsWnd, BUTTON_DRAG, 0, 0)
		g_GameMain.m_WndBagSlots:OnCtrlmsg(m_lcAddBagSlotsWnd, ITEM_LBUTTONCLICK, 0, 3)
		
		strRet = WaitEvent(true,nil,Event.Test.Change2Bag)
		SetEvent(Event.Test.Change2Bag,false)
		
		local Mgr = g_GameMain.m_BagSpaceMgr
		local spaceMainBag = Mgr:GetSpace(g_StoreRoomIndex.PlayerBag)
		local spaceMainAddSlots = Mgr:GetSpace(g_AddRoomIndexClient.PlayerExpandBag)
		
		assert(nil~=spaceMainBag, "spaceMainBag Ϊnil")
		assert(nil~=spaceMainAddSlots, "spaceMainAddSlots Ϊnil")
		
		
		local descGrid1 = Mgr:GetGridByRoomPos(g_AddRoomIndexClient.PlayerExpandBag, 1)
		local descGrid2 = Mgr:GetGridByRoomPos(g_AddRoomIndexClient.PlayerExpandBag, 2)
		local descGrid3 = Mgr:GetGridByRoomPos(g_AddRoomIndexClient.PlayerExpandBag, 3)
		local descGrid4 = Mgr:GetGridByRoomPos(g_AddRoomIndexClient.PlayerExpandBag, 4)

		assert_equal(1, descGrid1:Size(),"")
		assert_equal(1, descGrid2:Size(),"")
		assert_equal(0, descGrid3:Size(),"������������λ��")
		assert_equal(1, descGrid4:Size(),"")
	end

	function TestTest:TestFetchBag()
		-- ������ϵ�һ��Bag
		--print("In the TestFetchBag")
		g_GameMain.m_WndBagSlots:OnCtrlmsg(m_lcAddBagSlotsWnd, BUTTON_DRAG, 0, 0)
		WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 0)
		strRet = WaitEvent(true,nil,Event.Test.FetchBag)
		SetEvent(Event.Test.FetchBag,false)
		
		g_GameMain.m_WndBagSlots:OnCtrlmsg(m_lcAddBagSlotsWnd, BUTTON_DRAG, 0, 1)
		WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 1)
		strRet = WaitEvent(true,nil,Event.Test.FetchBag)
		SetEvent(Event.Test.FetchBag,false)
		
		g_GameMain.m_WndBagSlots:OnCtrlmsg(m_lcAddBagSlotsWnd, BUTTON_DRAG, 0, 3)
		WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 3)
		strRet = WaitEvent(true,nil,Event.Test.FetchBag)
		SetEvent(Event.Test.FetchBag,false)
		
		local Mgr = g_GameMain.m_BagSpaceMgr
		local descGrid1 = Mgr:GetGridByRoomPos(g_AddRoomIndexClient.PlayerExpandBag, 1)
		local descGrid2 = Mgr:GetGridByRoomPos(g_AddRoomIndexClient.PlayerExpandBag, 2)
		local descGrid3 = Mgr:GetGridByRoomPos(g_AddRoomIndexClient.PlayerExpandBag, 3)
		local descGrid4 = Mgr:GetGridByRoomPos(g_AddRoomIndexClient.PlayerExpandBag, 4)

		assert_equal(0, descGrid1:Size(),"�������ڸ�����")
		assert_equal(0, descGrid2:Size(),"�������ڸ�����")
		assert_equal(0, descGrid3:Size(),"���ﲻӦ���б�����")
		assert_equal(0, descGrid4:Size(),"�������ڸ�����")
		
		Gac2Gas:GM_Execute( g_Conn, "$delitem(2,\"�󱳰�\",3)" );
		strRet = WaitEvent(true,nil,Event.Test.DelItem)
		SetEvent(Event.Test.DelItem,false)
		
	end
	--[[
	--�ڲֿ������������и����ƶ�
	function TestTest:TestMoveByDepotAndMain()
	  --print("In the TestMoveByDepotAndMain")
		Gac2Gas:GM_Execute( g_Conn, "$additem(1,\"��Ůͼ\",5)" );
		local strRet = WaitEvent(true,nil,Event.Test.AddItem)
		SetEvent(Event.Test.AddItem,false)
		--�����ƶ����ֿ�

		WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_RBUTTONCLICK, 0, 0)
		local strRet = WaitEvent(true,nil,Event.Test.QuickMove)
		SetEvent(Event.Test.QuickMove,false)
		WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_RBUTTONCLICK, 0, 1)
		strRet = WaitEvent(true,nil,Event.Test.QuickMove)
		SetEvent(Event.Test.QuickMove,false)
		
		local Mgr = g_GameMain.m_BagSpaceMgr
		local fBagGrid = Mgr:GetGridByRoomPos(g_StoreRoomIndex.PlayerBag, 1)
		local sBagGrid = Mgr:GetGridByRoomPos(g_StoreRoomIndex.PlayerBag, 2)
		assert_equal(0, fBagGrid:Size(),"")
		assert_equal(0, sBagGrid:Size(),"")
		
		local fBagGrid = Mgr:GetGridByRoomPos(g_StoreRoomIndex.PlayerDepot, 1)
		local sBagGrid = Mgr:GetGridByRoomPos(g_StoreRoomIndex.PlayerDepot, 2)
		assert_equal(3, fBagGrid:Size(),"")
		assert_equal(2, sBagGrid:Size(),"")
		
		--����ƶ���������
		WndMainDepot:OnCtrlmsg(WndMainDepot.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 0)
		WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 0)
		strRet = WaitEvent(true,nil,Event.Test.ReplaceItem)
		SetEvent(Event.Test.ReplaceItem,false)
		 
		fBagGrid = Mgr:GetGridByRoomPos(g_StoreRoomIndex.PlayerBag, 1)
		assert_equal(3, fBagGrid:Size(),"")
		
		--��ֵ�������
		WndMainBag:OnCtrlmsg(WndMainBag.m_btnSplit,BUTTON_LCLICK, 0, 0)
		WndMainDepot:OnCtrlmsg(WndMainDepot.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 1)
		WndMainDepot.m_WndSplit:OnCtrlmsg(WndMainDepot.m_WndSplit.m_BtnOK,BUTTON_LCLICK,0,0)
		WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 1)
		strRet = WaitEvent(true,nil,Event.Test.SplitItem)
		SetEvent(Event.Test.SplitItem,false)
		sBagGrid = Mgr:GetGridByRoomPos(g_StoreRoomIndex.PlayerBag, 2)
		assert_equal(1, sBagGrid:Size(),"")
		
		--�����ƶ���������
		WndMainDepot:OnCtrlmsg(WndMainDepot.m_ctItemRoom, ITEM_RBUTTONCLICK, 0, 1)
		strRet = WaitEvent(true,nil,Event.Test.QuickMove)
		SetEvent(Event.Test.QuickMove,false)
		sBagGrid = Mgr:GetGridByRoomPos(g_StoreRoomIndex.PlayerBag, 2)
		assert_equal(2, sBagGrid:Size(),"")
		
		Gac2Gas:GM_Execute( g_Conn, "$delitem(1,\"��Ůͼ\",5)" );
		strRet = WaitEvent(true,nil,Event.Test.DelItem)
		SetEvent(Event.Test.DelItem,false)
	end
	--]]
----------------------------------------------------
   --��������С����֮��
	function TestTest:TestMoveInAllBag()
		--����һ���±������������ŵ���һ��������
		--print("In the TestMoveInAllBag")
		BagMgr:AddItem(2,'�󱳰�',1)
		BagMgr:PlaceBag2MainBag(0,0,0,0)
		BagMgr:AddItem(1,'��Ůͼ',5)
	 
	  local Mgr = g_GameMain.m_BagSpaceMgr
	  local lcMainBag	= Mgr:GetSpaceRelateLc(g_StoreRoomIndex.PlayerBag)
		--ԭ�ȵİ��������ǿ��Է���Ʒ�ģ����ڲ����ԣ������ⲿ�ֵĲ��Ը�Ϊ����Ʒ����İ����Ͱ�������İ�������
	  --SmallBag:��������ĳ��������Ӧ�Ĵ��ڣ���Ϊ������Ʒ��������ĸ��ӣ���
	  --lcSmallBag:��Ʒ�����ڣ�lcAddBagSlots:����������
		local SmallBag,lcSmallBag,nSmallRoomIndex = BagMgr:GetSmallBagLcAndRoomIndex(g_AddRoomIndexClient.PlayerExpandBag,1)

    BagMgr:ReplaceItem(WndMainBag,lcMainBag,0,0,SmallBag,lcSmallBag,2,4)
		
		local fBagGrid = Mgr:GetGridByRoomPos(g_StoreRoomIndex.PlayerBag, 1)
		local sBagGrid = Mgr:GetGridByRoomPos(g_StoreRoomIndex.PlayerBag, 2)
		local fExpandBagGrid = Mgr:GetGridByRoomPos(nSmallRoomIndex, 1)
		assert_equal(0, fBagGrid:Size(),"")
		assert_equal(2, sBagGrid:Size(),"")
		assert_equal(3, fExpandBagGrid:Size(),"")
		
		--�ƶ�������0��1��
		BagMgr:MoveItem(SmallBag,lcSmallBag,2,4,WndMainBag,lcMainBag,0,1)

		--���ƶ�������0��0��
		BagMgr:ReplaceItem(SmallBag,lcSmallBag,2,4,WndMainBag,lcMainBag,0,0)
		
		fBagGrid = Mgr:GetGridByRoomPos(g_StoreRoomIndex.PlayerBag, 1)
		sBagGrid = Mgr:GetGridByRoomPos(g_StoreRoomIndex.PlayerBag, 2)
		assert_equal(2, fBagGrid:Size(),"")
		assert_equal(3, sBagGrid:Size(),"")
		--ȡ�¿հ�
		BagMgr:FetchBagFromMainBag(0,0)
		
		BagMgr:DelItem(1,'��Ůͼ',5)
		BagMgr:DelItem(2,'�󱳰�',1)
	end
	
	--ɾ����Ʒ
	function TestTest:TestDelItem()
		--���һЩ��Ʒ
		--print("In the TestDelItem")
		Gac2Gas:GM_Execute( g_Conn, "$additem(1,\"Сѩ��\",5)" );
		local strRet = WaitEvent(true,nil,Event.Test.AddItem)
		SetEvent(Event.Test.AddItem,false)
		local Mgr = g_GameMain.m_BagSpaceMgr
	 	local fBagGrid = Mgr:GetGridByRoomPos(g_StoreRoomIndex.PlayerBag, 1)
	 	assert_equal(5, fBagGrid:Size(),"")
	 
	  --ɾ����Ʒ
	  local lcMainBag	= Mgr:GetSpaceRelateLc(g_StoreRoomIndex.PlayerBag)
	  WndMainBag:OnCtrlmsg(lcMainBag, ITEM_LBUTTONCLICK, 0, 0)
	 	g_GameMain:OnLButtonUp( 0, 0, 0 )
	 	
	 	local wnd = lcMainBag.m_MsgBox:GetDlgChild("BtnOK")
		wnd:SendMsg( WM_LBUTTONDOWN, 0, 0 )
		wnd:SendMsg( WM_LBUTTONUP, 0, 0 )

		local strRet = WaitEvent(true,nil,Event.Test.DelItem)
		SetEvent(Event.Test.DelItem,false)
		fBagGrid = Mgr:GetGridByRoomPos(g_StoreRoomIndex.PlayerBag, 1)
		assert_equal(0, fBagGrid:Size(),"")
	end
	
		--[[
	--ɾ���ձ���
	function TestTest:TestDelBagAndItem()
		--����һ���±������������ŵ���һ��������
		--print("In the TestDelBagAndItem")
		Gac2Gas:GM_Execute( g_Conn, "$additem(2,\"�󱳰�\",1)" );
	 	local strRet = WaitEvent(true,nil,Event.Test.AddItem)
	 	SetEvent(Event.Test.AddItem,false)
	 	
	 	WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 0)
	 	g_GameMain.m_WndBagSlots:OnCtrlmsg(m_lcAddBagSlotsWnd, ITEM_LBUTTONCLICK, 0, 0)
	 	
	 	strRet = WaitEvent(true,nil,Event.Test.PlaceBag)
		SetEvent(Event.Test.PlaceBag,false)
		
		--���һЩ��Ʒ
		Gac2Gas:GM_Execute( g_Conn, "$additem(1,\"Сѩ��\",5)" );
		local strRet = WaitEvent(true,nil,Event.Test.AddItem)
		SetEvent(Event.Test.AddItem,false)
		
		--�����Ʒ����
		local Mgr = g_GameMain.m_BagSpaceMgr
		local fExpandGrid = Mgr:GetGridByRoomPos(g_AddRoomIndexClient.PlayerExpandBag, 1)
		local Item = fExpandGrid:GetItem()
		local ExpandBagInfo = Item:GetContext()
		
		
		local lcAddBagSlots = g_GameMain.m_WndBagSlots.m_lcAddBagSlots
		local lcMainBag	= Mgr:GetSpaceRelateLc(g_StoreRoomIndex.PlayerBag)
		local lcSmallBag =  Mgr:GetSpaceRelateLc(ExpandBagInfo.RoomIndex)
	
		--��ʾ��������
		local Slot = lcAddBagSlots:GetSubItem(0,0)
		--Slot:SetCheck(true)
		g_GameMain.m_WndBagSlots:OnCtrlmsg(lcAddBagSlots, ITEM_LBUTTONCLICK, 0, 0)
		--����ƶ���������������Ʒ���������Ŀռ�ĵ�һ��λ��
		WndMainBag:OnCtrlmsg(lcMainBag, ITEM_LBUTTONCLICK, 0, 0)
		WndMainBag:OnCtrlmsg(lcMainBag, ITEM_LBUTTONCLICK, 2, 4)
		strRet = WaitEvent(true,nil,Event.Test.ReplaceItem)
		SetEvent(Event.Test.ReplaceItem,false)
		
	 	local fBagGrid = Mgr:GetGridByRoomPos(ExpandBagInfo.RoomIndex, 1)
	 	assert_equal(5, fBagGrid:Size(),"")
	 
	  --ɾ����������
		g_GameMain.m_WndBagSlots:OnCtrlmsg(m_lcAddBagSlotsWnd, BUTTON_DRAG, 0, 0)
	 	g_GameMain:OnLButtonUp( 0, 0, 0 )
	 	local wnd = lcAddBagSlots.m_MsgBox:GetDlgChild("BtnOK")
		wnd:SendMsg( WM_LBUTTONDOWN, 0, 0 )
		wnd:SendMsg( WM_LBUTTONUP, 0, 0 )
	
		--ɾ��ʧ�ܣ���Ϊ����Ʒ
		local strRet = WaitEvent(true,nil,Event.Test.DelBag)
		SetEvent(Event.Test.DelBag,false)
		fBagGrid = Mgr:GetGridByRoomPos(g_AddRoomIndexClient.PlayerExpandBag, 1)
		assert_equal(1, fBagGrid:Size(),"")

		--ɾ����Ʒ
	  WndMainBag:OnCtrlmsg(lcMainBag, ITEM_LBUTTONCLICK, 2, 4)
	 	g_GameMain:OnLButtonUp( 0, 0, 0 )
	 	local wnd = lcMainBag.m_MsgBox:GetDlgChild("BtnOK")
		wnd:SendMsg( WM_LBUTTONDOWN, 0, 0 )
		wnd:SendMsg( WM_LBUTTONUP, 0, 0 )
		local strRet = WaitEvent(true,nil,Event.Test.DelItem)
		SetEvent(Event.Test.DelItem,false)
		
		fBagGrid = Mgr:GetGridByRoomPos(g_StoreRoomIndex.PlayerBag, 1)
		assert_equal(0, fBagGrid:Size(),"")
			 
		--��ɾ������
		g_GameMain.m_WndBagSlots:OnCtrlmsg(m_lcAddBagSlotsWnd, BUTTON_DRAG, 0, 0)
	 	g_GameMain:OnLButtonUp( 0, 0, 0 )
	 	local wnd = lcAddBagSlots.m_MsgBox:GetDlgChild("BtnOK")
		wnd:SendMsg( WM_LBUTTONDOWN, 0, 0 )
		wnd:SendMsg( WM_LBUTTONUP, 0, 0 )
		
		--ɾ���ɹ�
		local strRet = WaitEvent(true,nil,Event.Test.DelBag)
		SetEvent(Event.Test.DelBag,false)
		fBagGrid = Mgr:GetGridByRoomPos(g_AddRoomIndexClient.PlayerExpandBag, 1)
		assert_equal(0, fBagGrid:Size(),"ɾ������ʧ��")
	end

	--�ֿⳲ��������
	function TestTest:TestOpenDepotSlot()
		--���һ�����������ŵ��ֿ�ĳ���
		--print("lastTest")
		Gac2Gas:GM_Execute( g_Conn, "$additem(2,\"�󱳰�\",1)" );
	 	local strRet = WaitEvent(true,nil,Event.Test.AddItem)
	 	SetEvent(Event.Test.AddItem,false)
	 	WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 0)
	 	WndMainDepot:OnCtrlmsg(WndMainDepot.m_lcAddBagSlots, ITEM_LBUTTONCLICK, 0, 0)
	 	strRet = WaitEvent(true,nil,Event.Test.PlaceBag)
		SetEvent(Event.Test.PlaceBag,false)
		assert_equal("ReplaceItemSuccess", strRet[2][1], "OpenSlot Success!")

		--�����Ʒ����
		local Mgr = g_GameMain.m_BagSpaceMgr
		local lcAddBagSlots = g_GameMain.m_WndBagSlots.m_lcAddBagSlots
		local lcMainBag	= Mgr:GetSpaceRelateLc(g_StoreRoomIndex.PlayerBag)	
				
		--������ȫ���ĳ�
		for i = 1,6 do
			WndMainDepot:OnCtrlmsg(WndMainDepot.m_BtnStartup, BUTTON_LCLICK, 0, 0)
		 	assert_equal("OpenDepotSlotSuccess", strRet[2][1], "OpenSlot Failed!")
		 	local wnd = WndMainDepot.m_MsgBox:GetDlgChild("BtnOK")
			wnd:SendMsg( WM_LBUTTONDOWN, 0, 0 )
			wnd:SendMsg( WM_LBUTTONUP, 0, 0 )
		end
	
		--�ڰѱ�������ȥ
		WndMainBag:OnCtrlmsg(WndMainBag.m_ctItemRoom, ITEM_LBUTTONCLICK, 0, 0)
	 	WndMainDepot:OnCtrlmsg(WndMainDepot.m_lcAddBagSlots, ITEM_LBUTTONCLICK, 0, 0)
	 	strRet = WaitEvent(true,nil,Event.Test.PlaceBag)
		SetEvent(Event.Test.PlaceBag,false)
		
		local fExpandGrid = Mgr:GetGridByRoomPos(g_AddRoomIndexClient.PlayerExpandDepot, 1)
		local Item = fExpandGrid:GetItem()
		local ExpandBagInfo = Item:GetContext()
		fBagGrid = Mgr:GetGridByRoomPos(g_AddRoomIndexClient.PlayerExpandDepot, 1)
		assert_equal(1, fBagGrid:Size(),"")
		
		--�ڿ����Żش���,�Ѿ�������
		WndMainDepot:OnCtrlmsg(WndMainDepot.m_BtnStartup, BUTTON_LCLICK, 0, 0)
	 	assert_equal("OpenDepotSlotError", strRet[2][1], "OpenSlot Success!")
	 	local wnd = WndMainDepot.m_MsgBox:GetDlgChild("BtnOK")
		wnd:SendMsg( WM_LBUTTONDOWN, 0, 0 )
		wnd:SendMsg( WM_LBUTTONUP, 0, 0 )
		
		--ȡ�±�������ɾ��
		g_GameMain.m_WndBagSlots:OnCtrlmsg(m_lcAddBagSlotsWnd, BUTTON_DRAG, 0, 0)
		WndMainBag:OnCtrlmsg(lcMainBag, ITEM_LBUTTONCLICK, 0, 5)
		strRet = WaitEvent(true,nil,Event.Test.FetchBag)
		SetEvent(Event.Test.FetchBag,false)
		
		Gac2Gas:GM_Execute( g_Conn, "$delitem(2,\"�󱳰�\",1)" );
		strRet = WaitEvent(true,nil,Event.Test.DelItem)
		SetEvent(Event.Test.DelItem,false)
	end--]]
	
	--�˳�����
	function TestTest:TestEnd()
		WndItemBag:OnCtrlmsg( WndItemBag.m_BtnMainBag,BUTTON_LCLICK,0,0 )
		controler:LoginOutFromGame()
	end
	
	function TestTest:teardown()
	end
end
