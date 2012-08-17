gac_require "information/tooltips/ToolTips"
gac_require "framework/texture_mgr/TextureMgr"

LcStoreRoomPublic = class(CLcStoreRoom)
-------------------------------------------------------------------
------ɾ��������Ʒ------
function LcStoreRoomPublic:DeleteAllGridItem()
	if(self.m_nRow and self.m_nCol) then
		for i = 0, self.m_nRow-1 do
			for j = 0, self.m_nCol-1 do
				local grid = self:GetGridByIndex(i, j, self.m_nRoomIndex)
				local tbl  = grid:GetItemID(grid:Size())
				if(#tbl > 0) then
					for k = 1, #tbl do
						grid:DelUnique(tbl[k])
					end
				end
			end
		end
	end
end

------�Ӹ�����ʰȡ��Ʒ------
function LcStoreRoomPublic:SetPickupItemFromCollectiveBag(nRoomIndex, row, col, num, State, page)
	local grid = self:GetGridByIndex(row, col, nRoomIndex)
	local wnd  = self._m_CDialog[row*self.m_nCol + col + 1]
	local vWnd = self:GetSubItem(row, col)
	vWnd:SetMouseOverDescAfter("")
	g_WndMouse:SetPickupItemFromCollectiveBag(nRoomIndex, row, col, num, wnd.m_BtnCD, State, page)
end

--�Ҽ������Ʒ��
function LcStoreRoomPublic:DoByRClick(nRoomIndex,uParam1,uParam2,WndFarther)
	local state, context = g_WndMouse:GetCursorState()
	local curPos  = self:GetPosByIndex(uParam1,uParam2)
	local page = WndFarther.m_Page
	if(state == ECursorState.eCS_Normal and g_GameMain.m_WndMainBag:IsShow()) then
		Gac2Gas:QuikMoveItemFromCDepotToBag(g_Conn,nRoomIndex, curPos,page,g_StoreRoomIndex.PlayerBag)
	end
end

------��������Ʒ���������Ǵ�(0,0)��ʼ��------
function LcStoreRoomPublic:DoByClickRoom(nRoomIndex, uParam1, uParam2, wndFather)
	local state, context = g_WndMouse:GetCursorState()
	local page = wndFather.m_Page
	local fromRoom, fromRow, fromCol, count, fromPage
	if(nil ~= context and #context > 0) then
		fromRoom, fromRow, fromCol, count, fromPage = context[1], context[2],context[3], context[4], context[5]
	end
	
	local curPos  = self:GetPosByIndex(uParam1,uParam2)
	local curGrid = self:GetGridByIndex(uParam1, uParam2, nRoomIndex)
	local curSize = curGrid:Size()
	if(state == ECursorState.eCS_Normal) then          --�����û�ж���
		if(wndFather == g_GameMain.m_TongDepot) then   --���������ǰ��ֿ�
			if not self:GetClickWndItem(curPos, nRoomIndex)  then
				self:SetPickupItemFromCollectiveBag(nRoomIndex, uParam1, uParam2, _, ECursorState.eCS_PickupItemFromTongDepot, page)
			end
		end
	elseif(state == ECursorState.eCS_PickupItem) then  --������ǴӰ������͵ĵط�ȡ������Ʒ
		if(wndFather == g_GameMain.m_TongDepot) then   --���������ǰ��ֿ�
			local srcCt  = g_GameMain.m_BagSpaceMgr:GetSpaceRelateLc(fromRoom)
			local srcPos = srcCt:GetPosByIndex(fromRow,fromCol)
			if(srcPos > g_PlayerMainBag.size) then     --����ϵ���Ʒ�Ǵӱ�������չ�ռ���ȡ����
				fromRoom,srcPos = g_GameMain.m_WndBagSlots.m_lcAddBagSlots:GetSlotIndex(srcPos)
			end
			
			if g_Client_IsSlotIndex(fromRoom) then --�ǴӸ��Ӱ��������߸��Ӳֿ���ȡ������Ʒ
				--local nSrcPos = srcCt:GetGlobalSlotPos(srcPos)
				--Gac2Gas:CollectiveBagAddItemFromOther(g_Conn, nSrcPos, nRoomIndex, curPos)
			else
				Gac2Gas:CollectiveBagAddItemFromOther(g_Conn, fromRoom, srcPos, nRoomIndex, page ,curPos)
				--g_SetClickedWndState(fromRoom, srcPos, 6, curPos, false)
			end
			g_WndMouse:ClearCursorAll()
		end
	elseif(state == ECursorState.eCS_PickupItemFromTongDepot) then --������ǴӰ��ֿ�ȡ������Ʒ
		if(wndFather == g_GameMain.m_TongDepot) then               --���������ǰ��ֿ�
			local fromPos = self:GetPosByIndex(fromRow, fromCol)
			if(fromRow == uParam1 and fromCol == uParam2 and fromPage == page) then     --���ʰȡλ�ú�Ҫ���õ�λ����ͬ
				self:SetClickedWndState(uParam1, uParam2, nRoomIndex, true)
				g_WndMouse:ClearCursorAll()
			else
				Gac2Gas:CollectiveBagMoveItemSelf(g_Conn, nRoomIndex, fromPage, fromPos, page, curPos)
			end
		end
	elseif(state == ECursorState.eCS_PickupItemFromNPCShop) then   --������Ǵ�NPC�̵��ȡ����Ʒ
	elseif(state == ECursorState.eCS_PickupEquip) then             --�������װ��
	elseif(state == ECursorState.eCS_Split and curSize > 1) then
	end
end

function LcStoreRoomPublic:DoByDragRoom(nRoomIndex, uParam1, uParam2, WndFarther)
	local page				= WndFarther.m_Page
	local state, context	= g_WndMouse:GetCursorState()
	local CurGrid			= self:GetGridByIndex(uParam1, uParam2, nRoomIndex)
	local CurPos			= self:GetPosByIndex(uParam1, uParam2, nRoomIndex)

	local Cursize = CurGrid:Size()
	if 0 == Cursize then
		return
	end
	if state == ECursorState.eCS_Normal then --����û����Ʒ
		if not self:GetClickWndItem(CurPos, nRoomIndex)  then
			self:SetPickupItemFromCollectiveBag(nRoomIndex, uParam1, uParam2, _, ECursorState.eCS_PickupItemFromTongDepot, page)
		end
	end
end

--------------------------------------------------------------------------------------------------------------

------���صõ��������ĳҳ��Ʒ��Ϣ��ʼ-------
function Gas2Gac:ReturnGetCollectiveBagOnePageItemListStart(Conn, type)
	if(type == g_StoreRoomIndex.TongDepot) then --���ֿ�
		g_GameMain.m_TongDepot.m_TongItemRoom:DeleteAllGridItem()
	end
end

------���صõ��������ĳҳ��Ʒ��Ϣ����-------
function Gas2Gac:ReturnGetCollectiveBagOnePageItemListEnd(Conn, type, page)
	if(type == g_StoreRoomIndex.TongDepot) then --���ֿ�
		g_GameMain.m_TongDepot:Draw()
	end
end

------���ؼ�������������ڲ����ƶ�����------
function Gas2Gac:ReturnCollectiveBagMoveItemSelf(Conn, bFlag, type, page)
	if(type == g_StoreRoomIndex.TongDepot) then 
		g_GameMain.m_TongDepot:GetTongDepotOnePageItemList(page)
	end
	if(bFlag) then g_WndMouse:ClearCursorAll() end
end

------���ش�������Դ������������Ʒ------
function Gas2Gac:ReturnCollectiveBagAddItemFromOther(Conn, bFlag, type, page)
	if(type == g_StoreRoomIndex.TongDepot) then 
		g_GameMain.m_TongDepot:GetTongDepotOnePageItemList(page)
	end
	if(bFlag) then g_WndMouse:ClearCursorAll() end
end

------���شӼ�������������������Ʒ------
function Gas2Gac:ReturnBagAddItemFromCollectiveBag(Conn, bFlag, type, page)
	if(type == g_StoreRoomIndex.TongDepot) then 
		g_GameMain.m_TongDepot:GetTongDepotOnePageItemList(page)
	end
	g_WndMouse:ClearCursorAll()
	if(not bFlag) then MsgClient(9164) end
end