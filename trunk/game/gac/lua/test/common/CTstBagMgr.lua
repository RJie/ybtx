gac_require "test/common/CTstBagMgrInc"

function CTstBagMgr:AddItem(nBigID,nIndex,nCount)
	local str = string.format("$additem(%d,\"%s\",%d)", nBigID,nIndex,nCount)
	Gac2Gas:GM_Execute( g_Conn, str );
	SetEvent(Event.Test.AddItem,false)
	local strRet = WaitEvent(true,nil,Event.Test.AddItem)
	SetEvent(Event.Test.AddItem,false)
end


function CTstBagMgr:DelItem(nBigID,nIndex,nCount)
	local str = string.format("$delitem(%d,\"%s\",%d)", nBigID,nIndex,nCount)
	Gac2Gas:GM_Execute( g_Conn, str );
	SetEvent(Event.Test.DelItem,false)
	local strRet = WaitEvent(true,nil,Event.Test.DelItem)
	SetEvent(Event.Test.DelItem,false)
end

function CTstBagMgr:AddSoul(nCount)
	local str = string.format("$addsoulpearl(\"%s\",%d,%d)", nCount)
	Gac2Gas:GM_Execute( g_Conn, str );
	SetEvent(Event.Test.AddSoul,false)
	local strRet = WaitEvent(true,nil,Event.Test.AddSoul)
	SetEvent(Event.Test.AddSoul,false)
end

function CTstBagMgr:UseItemInMainBag(nFirst,nSecond)
	local WndMainBag = self.m_WndMainBag
	WndMainBag.m_MsgBox = nil
	WndMainBag:OnCtrlmsg(self.m_lcMainBag, ITEM_RBUTTONCLICK, nFirst, nSecond)
	if self.m_lcMainBag.m_MsgBox ~= nil then
		local wnd = self.m_lcMainBag.m_MsgBox:GetDlgChild("BtnOK")
		wnd:SendMsg( WM_LBUTTONDOWN, nFirst, nSecond )
		wnd:SendMsg( WM_LBUTTONUP, nFirst, nSecond )
		local strRet = WaitEvent(true,nil,Event.Test.UseItem)
		SetEvent(Event.Test.UseItem,false)
	end
end

--���������з�С����������ұ���
function CTstBagMgr:PlaceBag2MainBag(nRoomX,nRoomY,nSlotX,nSlotY)
	local lcAddBagSlots = g_GameMain.m_WndBagSlots.m_lcAddBagSlots

 	self.m_WndMainBag:OnCtrlmsg(self.m_lcMainBag, ITEM_LBUTTONCLICK, nRoomX, nRoomY)
 	g_GameMain.m_WndBagSlots:OnCtrlmsg(lcAddBagSlots, ITEM_LBUTTONCLICK, nSlotX, nSlotY)
 	local strRet = WaitEvent(true,nil,Event.Test.PlaceBag)
	SetEvent(Event.Test.PlaceBag,false)
	
	--�򿪸�������

	local Slot = lcAddBagSlots:GetSubItem(nSlotX,nSlotY)
	--Slot:SetCheck(true)
	g_GameMain.m_WndBagSlots:OnCtrlmsg(lcAddBagSlots, ITEM_LBUTTONCLICK, nSlotX,nSlotY)
end

--��Ҫ��֤�����ǿյ�
function CTstBagMgr:FetchBagFromMainBag(nSlotX,nSlotY)
	--ȡ�±���
	local lcAddBagSlots = g_GameMain.m_WndBagSlots.m_lcAddBagSlots
	local slotPos = nSlotX + nSlotY
	g_GameMain.m_WndBagSlots:OnCtrlmsg(lcAddBagSlots, BUTTON_DRAG, 0, slotPos)
	self.m_WndMainBag:OnCtrlmsg(self.m_lcMainBag, ITEM_LBUTTONCLICK, 0,3)
	local strRet = WaitEvent(true,nil,Event.Test.FetchBag)
	SetEvent(Event.Test.FetchBag,false)

end

function CTstBagMgr:GetSmallBagLcAndRoomIndex(nRoomIndex,nPos)

	local Mgr = self.m_MainMgr
	local fExpandGrid = Mgr:GetGridByRoomPos(nRoomIndex,nPos)
	local Item = fExpandGrid:GetItem()
	local ExpandBagInfo = Item:GetContext()
	
	local lcAddBagSlots = g_GameMain.m_WndBagSlots.m_lcAddBagSlots
	local lcSmallBag = g_GameMain.m_WndMainBag.m_ctItemRoom
	--local lcSmallBag =  Mgr:GetSpaceRelateLc(ExpandBagInfo.RoomIndex)
	--local SmallBag = lcAddBagSlots.m_BagAddBackpacks[nPos]
	local SmallBag = g_GameMain.m_WndMainBag
	return SmallBag,lcSmallBag,ExpandBagInfo.RoomIndex
	--SmallBag:��������ĳ��������Ӧ�Ĵ��ڣ���Ϊ������Ʒ��������ĸ��ӣ���
	--lcSmallBag:��Ʒ�����ڣ�lcAddBagSlots:����������
end
	
function CTstBagMgr:MoveItem(SrcBag,SrcLc,SrcX,SrcY,DesBag,DesLc,DesX,DesY)
	--������Ʒ
	SrcBag:OnCtrlmsg(SrcLc, ITEM_LBUTTONCLICK, SrcX,SrcY)
	DesBag:OnCtrlmsg(DesLc, ITEM_LBUTTONCLICK, DesX,DesY)
	local strRet = WaitEvent(true,nil,Event.Test.MoveItem)
	SetEvent(Event.Test.MoveItem,false)
end

function CTstBagMgr:ReplaceItem(SrcBag,SrcLc,SrcX,SrcY,DesBag,DesLc,DesX,DesY)
	--������Ʒ
	SrcBag:OnCtrlmsg(SrcLc, ITEM_LBUTTONCLICK, SrcX,SrcY)
	DesBag:OnCtrlmsg(DesLc, ITEM_LBUTTONCLICK, DesX,DesY)
	local strRet = WaitEvent(true,nil,Event.Test.ReplaceItem)
	SetEvent(Event.Test.ReplaceItem,false)
end

function CTstBagMgr:MainBagClicked(SrcX,SrcY)
	--������Ʒ
	self.m_WndMainBag:OnCtrlmsg(self.m_lcMainBag, ITEM_LBUTTONCLICK, SrcX,SrcY)
end

function CTstBagMgr:Ctor(WndMainBag)
	self.m_WndMainBag = WndMainBag
	self.m_MainMgr = g_GameMain.m_BagSpaceMgr
	self.m_lcMainBag = self.m_MainMgr:GetSpaceRelateLc(g_StoreRoomIndex.PlayerBag)
end