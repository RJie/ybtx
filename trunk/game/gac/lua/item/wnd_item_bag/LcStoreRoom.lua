cfg_load "item/SkillItem_Common"
gac_require "information/tooltips/ToolTips"
gac_require "framework/texture_mgr/TextureMgr"
gac_require "item/boxitem/BoxItem"
gac_gas_require "item/item_info_mgr/ItemInfoMgr"

CLcStoreRoom = class(SQRListCtrl)

--�Ҽ�����ʱ�Ƿ��ƶ���Ʒ���ֿ�
local function IsDepotOpenWhenRClick(nRoomIndex, CurPos)
	if( g_GameMain.m_Depot and g_GameMain.m_Depot:IsShow() ) then --����ֿⴰ�ڴ򿪣���ֻ���ƶ���Ʒ
		Gac2Gas:QuickMove(g_Conn, nRoomIndex, CurPos, g_StoreRoomIndex.PlayerDepot)
		return true
	end
	return false
end

local function GacCheckWhichWndIsFoucs( context, nBigID, Index )
	local function Callback(g_GameMain,uButton)
		g_GameMain.m_MsgBox = nil
		return true
	end
	local function MainBagCallback(g_GameMain,uButton)
		g_GameMain.m_WndMainBag.m_ctItemRoom.m_MsgBox = nil
		return true
	end
	local bTradeFlag = g_GameMain.m_PlayersTradeWnd:IsShow()
	local bSendEmailFlag = g_GameMain.m_SendBox:IsShow()
	local bCSMFlag = (g_GameMain.m_CSMSellCharOrderWnd and g_GameMain.m_CSMSellCharOrderWnd:IsShow()) or
		(g_GameMain.m_CSMBuyCharOrderWnd and g_GameMain.m_CSMBuyCharOrderWnd:IsShow() )
	if bTradeFlag or bSendEmailFlag or  bCSMFlag then
		if g_ItemInfoMgr:IsQuestItem(nBigID) then		--���ܳ���������Ʒ
			g_WndMouse:ClearCursorAll()
			g_GameMain.m_WndMainBag.m_ctItemRoom.m_MsgBox = MessageBox(g_GameMain.m_WndMainBag.m_ctItemRoom, MsgBoxMsg(13003), MB_BtnOK, MainBagCallback,g_GameMain)
			return true
		end
		local uParam1, uParam2, nRoomIndex = context[2], context[3], context[1]
		local curGrid = g_GameMain.m_WndMainBag.m_ctItemRoom:GetGridByIndex(uParam1, uParam2, nRoomIndex)
		local itemID = curGrid:GetItem():GetItemID()
		local dynInfo =  g_DynItemInfoMgr:GetDynItemInfo(itemID)
		if dynInfo and dynInfo.BindingType == 2 then --��Ʒ������Ϊ����
			local msgID = nil
			if bTradeFlag then 
				msgID = 13011
			elseif bSendEmailFlag then
				msgID = 13004
			elseif bCSMFlag then
				msgID = 13010
			end
			g_WndMouse:ClearCursorAll()
			local function Callback(g_GameMain,uButton)
				g_GameMain.m_MsgBox = nil
				return true
			end
			g_GameMain.m_MsgBox = MessageBox(g_GameMain, MsgBoxMsg(msgID), MB_BtnOK,Callback,g_GameMain)
			return true
		end
	end
	--�ʼ�ϵͳ
	if g_GameMain.m_SendBox:IsShow() then
		for i =1,4 do
			local GoodIndex = "Goods_0" .. i
			if g_GameMain.m_SendBox:GetDlgChild(GoodIndex):GetWndText() == "" then
				g_GameMain.m_SendBox:ClickGoodsButton(GoodIndex, context)
				break
			end
			if i == 4 then
				g_WndMouse:ClearCursorAll()
				g_GameMain.m_SendBox.m_MsgBox  = MessageBox(g_GameMain.m_SendBox, MsgBoxMsg(13005), MB_BtnOK )
			end
		end
		return true
	end

	--��ҽ���
	if g_GameMain.m_PlayersTradeWnd:IsShow() then
		if g_GameMain.m_PlayersTradeWnd:GetDlgChild( "MeLockBtn" ):IsEnable() == false then
			return true
		end
		local Child = nil 
		for i=1, 16 do
			local itemWnd = g_GameMain.m_PlayersTradeWnd.m_MineTradeItemListWnd.m_ItemBtnListTbl[i]
			if itemWnd:GetWndText() == ""  then
				Child = itemWnd
				break
			end
		end
		if Child ~= nil then
			g_GameMain.m_PlayersTradeWnd:SellItem( context, Child)
		else 
			g_WndMouse:ClearCursorAll()
			g_GameMain.m_PlayersTradeWnd.m_MsgBox  = MessageBox(g_GameMain.m_PlayersTradeWnd, MsgBoxMsg(13006), MB_BtnOK )
		end
		return true
	end
	
	--���۽�����
	if g_GameMain.m_CSMSellCharOrderWnd and g_GameMain.m_CSMSellCharOrderWnd:IsShow() then
		g_GameMain.m_CSMSellCharOrderWnd:ClearWndInfo()
		g_GameMain.m_CSMSellCharOrderWnd:CSMSellItem( context )  
		return true
	end
	
	--NPC�̵�
	if g_GameMain.m_NPCShopPlayerSold:IsShow() or g_GameMain.m_NPCShopSell:IsShow() then
		g_GameMain.m_NPCShopSell:SellItem( context )
		return true
	end
	
	if g_GameMain.m_EquipUpIntensifyWnd:IsShow() then
		if g_ItemInfoMgr:IsAdvanceStone(nBigID) then
			g_GameMain.m_EquipUpIntensifyWnd:AddAdaptedAdvanceStone(context)
	   		return true 
	   	end
	end
	
	--����
	if g_GameMain.m_PurchasingAgentSellWnd and g_GameMain.m_PurchasingAgentSellWnd:IsShow() then
		g_GameMain.m_PurchasingAgentSellWnd:PurchasingAgentSell( context )
		return true
	elseif g_GameMain.m_PurchasingAgentQuickSellWnd and g_GameMain.m_PurchasingAgentQuickSellWnd:IsShow() then
		g_GameMain.m_PurchasingAgentQuickSellWnd:PurchasingAgentSell( context )
		return true
	elseif g_GameMain.m_PurchasingWnd and g_GameMain.m_PurchasingWnd:IsShow() then
		g_GameMain.m_PurchasingWnd:OnChooseItem( context )
		return true
	end
	
	if ( IsDepotOpenWhenRClick(context[1], context[5]) ) then
		return true
	end
	
	return false
end

--�����Ʒ�Ǵ�NPC�̵��򵽵ģ��˺��������ж�Ŀ�ĵ�λ���Ƿ�ɷ�������Ʒ
--������Ŀ�ĵ�λ��
function CLcStoreRoom:CheckDesPosOk( nRoomIndex, pos, itemType)
	local Mgr = g_GameMain.m_BagSpaceMgr
	local grid = Mgr:GetGridByRoomPos(nRoomIndex, pos)
	if grid:Empty() then 
		return true
	else
		local itemtype =  grid:GetType() 
		if itemtype == itemType and grid:Size() < grid:GetFoldLimit() then
			return true
		end
	end

	return false
end

function CLcStoreRoom:GetClickWndItem(pos, nRoomIndex)
	local Mgr = g_GameMain.m_BagSpaceMgr
	local grid = Mgr:GetGridByRoomPos(nRoomIndex, pos)
	return grid:Empty()
end

function CLcStoreRoom:GetClickWndItemByXY(x, y, nRoomIndex)
	local Mgr = g_GameMain.m_BagSpaceMgr
	local grid = self:GetGridByIndex(x, y, nRoomIndex)
	return grid:Empty()
end

function CLcStoreRoom:SetSize(RoomIndex, Size, col)
	local row = math.ceil(Size/col)
	local sub = col*row - Size

	self.m_nRoomIndex	= RoomIndex
	self.m_nRow			= row
	self.m_nCol			= col
	self.m_nSize		= Size

	self:DeleteAllItem()
	for i = 1, col do self:InsertColumn(i-1, g_GridSize) end
	
	local insertRows = math.ceil(g_PlayerMainBag.MaxSize/col)
	self._m_CDialog = {}
	for y = 1, insertRows do
		self:InsertItem(y - 1, g_GridSize)
		for x = 1, col do
			local wnd = self:GetSubItem(y - 1, x - 1)
			wnd:SetFlashInfo(IP_MOUSEOVER, "skillmoveover")
			wnd:SetDetectMouseOverWnd(true)
			wnd:SetDownTooltips(true)
			local ItemWnd = self:CreateBagGrid(wnd)
			table.insert(self._m_CDialog, ItemWnd)
			
			local pos = (y-1)*col+x
			if pos > Size then
				wnd:EnableWnd(false)
				wnd:ShowWnd(false)
				ItemWnd:ShowWnd(false)
			end
		end
	end
	
	self:SetBackgroundAndItemPic(RoomIndex, 1, Size, col)
end

function CLcStoreRoom:CreateBagGrid(parent)
	local wnd = SQRDialog:new()
	wnd:CreateFromResEx("BagGrid", parent, true, true)
	wnd.m_BtnCD		= wnd:GetDlgChild("BtnCD")
	wnd.m_ClockCD	= wnd:GetDlgChild("ClockCD")
	wnd.m_WndNum	= wnd:GetDlgChild("WndNum")
	wnd.m_ClockCD:ShowWnd(false)
	wnd:SetStyle(0x60000000)
	wnd:ShowWnd(true)
	return wnd
end

function CLcStoreRoom:SetBackgroundAndItemPic(RoomIndex, SizeBegin, SizeEnd, col)
	local bk = SQRDialog:new()
	local sRes = "BagGridBackground" .. RoomIndex
	bk:CreateFromResEx(sRes, self, true, true)
	bk:ShowWnd( true )
	local SIZE = bk:GetWndWidth()
	local Flag = IMAGE_PARAM:new()
	Flag.CtrlMask = SM_BS_BK
	
	local tbl = {IP_ENABLE, IP_DISABLE}
	for j = 1, #tbl do
		Flag.StateMask = tbl[j]
		local SrcImage = bk:GetWndBkImage(Flag)
		for i = SizeBegin, SizeEnd do
			-- ���Ʊ�����
			local x, y			= self:ParsePos(i,col) 
			local pos			= CPos:new(SIZE*x,SIZE*y)
			local DescImage		= self._m_CDialog[i]:GetWndBkImage(Flag)

			local ImageBk = IMAGE:new()
			SrcImage:GetImage(SrcImage:GetImageCount()-1, ImageBk)
			ImageBk:SetPosWndX(pos.x)
			ImageBk:SetPosWndY(pos.y)
			DescImage:AddImageFromImageList(SrcImage,0,-1)

			-- ������Ʒ
			self:UpdateWndDisPlay(y, x, RoomIndex)
		end
	end

	bk:DestroyWnd()
end

function CLcStoreRoom:GetWnd(row, col)	--��0��ʼ
	return self._m_CDialog[self:GetBagIndex(col, row)]
end

function CLcStoreRoom:IsInMainBagExpandByAddBag(roomIndex)
	--��������ܼ�4����չ������
	if(not roomIndex) then return false end
	local slotRoomBegin = g_StoreRoomIndex.SlotRoomBegin
	return roomIndex >= slotRoomBegin and roomIndex <= slotRoomBegin + 3
end

--�����������ֿ⡢�����������õ��������ȡpos���������������еĸ����п�������Ӹ���������չ�ģ�������Ҫ������
function CLcStoreRoom:GetPosByIndex(row, col, roomIndex)
	local srcPos = row*self.m_nCol + col +1
	local realPosInExactPos = nil 	--��Ӧÿ����չ�������ڵ�pos
	if self:IsInMainBagExpandByAddBag(roomIndex) then
		 _, realPosInExactPos = g_GameMain.m_WndBagSlots.m_lcAddBagSlots:GetSlotIndex(srcPos)
	else 
		realPosInExactPos = srcPos
	end	
	return realPosInExactPos
end

function CLcStoreRoom:ParsePos(Pos, cols)
	Pos = Pos - 1
	local y = math.floor(Pos / cols)
	local x = Pos - y*cols
	return x, y
end

function CLcStoreRoom:GetIndexByPos(pos, roomIndex)
	if g_GameMain.m_WndMainBag.m_ctItemRoom:IsInMainBagExpandByAddBag(roomIndex) then
		pos  = self:GetDesPos(roomIndex, pos) 
	end
	return self:ParsePos(pos,self.m_nCol)
end

function CLcStoreRoom:ClearPickupItem()
	g_WndMouse:ResetCursorState()
end

function CLcStoreRoom:SetPickupItem(room, row, col, State)
	local wnd	= self:GetWnd(row, col)
	local vWnd	= self:GetSubItem( row, col )
	local Grid	= self:GetGridByIndex(row, col, room)
	
	local count = Grid:Size()
	g_WndMouse:SetPickupItem(room, row, col, count, wnd.m_BtnCD, State, vWnd)
end

--�����Ʒ
function CLcStoreRoom:SetPickupSplitItem(room, row, col, num, State)
	local wnd = self:GetWnd(row, col)
	g_WndMouse:SetPickupSplitItem(room, row, col, num, wnd.m_BtnCD, State)
end

function CLcStoreRoom:GetPickupItem()
	local state, context = g_WndMouse:GetCursorState()
	if state == ECursorState.eCS_PickupItem then
		assert(context~=nil)
		return context
	else
		return nil
	end
end

function CLcStoreRoom:GetGridByIndex(row, col, roomIndex)
	local Mgr = g_GameMain.m_BagSpaceMgr
	local Grid = {}

	local pos = self:GetPosByIndex(row, col, roomIndex)
	Grid = Mgr:GetGridByRoomPos(roomIndex, pos)
	
	return Grid
end

function CLcStoreRoom:UpdateWndDisPlayByPos(Pos, roomIndex)
	local x, y = self:GetIndexByPos(Pos, roomIndex)
	self:UpdateWndDisPlay(y, x, roomIndex)
end

function CLcStoreRoom:UpdateWndDisPlayByItemID(bUpdateSomeItem,nItemID)
	local SpaceMgr = g_GameMain.m_BagSpaceMgr
	local space = SpaceMgr:GetSpace(g_StoreRoomIndex.PlayerBag)
	local BagSize = space:Size()
	for i = 1, BagSize do
		local fromRoom,srcPos 
		if(i > g_PlayerMainBag.size) then  
			fromRoom,srcPos = g_GameMain.m_WndBagSlots.m_lcAddBagSlots:GetSlotIndex(i)
		else
			fromRoom = g_StoreRoomIndex.PlayerBag
			srcPos = i
		end
		local CurGrid = SpaceMgr:GetGridByRoomPos(fromRoom, srcPos)
		local nBigID,nIndex = CurGrid:GetType()
		if (not CurGrid:Empty()) then
			local vWnd     = self._m_CDialog[i]
			local num  = CurGrid:Size()
			local GlobalID = CurGrid:GetItem():GetItemID()
			if bUpdateSomeItem == true  then
				if GlobalID == nItemID then
					self:UpdateWndDisPlayByPos(srcPos, fromRoom)
				end
			end
		end
	end	
end

function CLcStoreRoom:UpdateWndDisPlay(row, col, roomIndex, CoolDownType, CoolDownTime)
	local Grid = self:GetGridByIndex(row, col, roomIndex)
	local Wnd  = self:GetWnd(row, col)
	local vWnd = self:GetSubItem(row, col)
	local num  = Grid:Size()
	
	if(CoolDownTime and CoolDownType) then
		Wnd.m_BtnCD:Init(g_CoolDownMgr, CoolDownType, CoolDownTime)
	end
	
	Wnd.m_WndNum:SetWndText(num > 1 and tostring(num) or "")
	if num == 0 then
		g_WndMouse:ClearIconWnd(Wnd.m_BtnCD)
		vWnd:SetMouseOverDescAfter("")
	else
		local GlobalID = Grid:GetItem():GetItemID()
		local uBigID, uIndex = Grid:GetType()
		local item = g_DynItemInfoMgr:GetDynItemInfo(GlobalID)
		local smallIcon = nil
		
		if(item ~= nil and 0 == item.m_nLifeTime) then
			local itemLifeInfo = g_ItemInfoMgr:GetItemLifeInfo(uBigID, uIndex)
			if itemLifeInfo then
				smallIcon = itemLifeInfo("TimeOutSmallIcon")
			else
				smallIcon = Grid:GetIcon()
			end
		else
			smallIcon = Grid:GetIcon()
		end
		
		g_LoadIconFromRes(smallIcon, Wnd.m_BtnCD, -2, IP_ENABLE, IP_CLICKDOWN)
		g_Tooltips:LoadIconFromRes(vWnd, smallIcon)
		g_SetWndMultiToolTips(vWnd,uBigID,uIndex,GlobalID,num)
	end
	local pos = self:GetPosByIndex(row, col, roomIndex)
	self:CDItemChanged(roomIndex, pos)
	self:SetItemFlashInfo(roomIndex, pos)

	if g_GameMain.m_WndMainBag then
		g_GameMain.m_WndMainBag:UpdateRoomDis()
	end
end

--���room�ռ�Ĵ����ǿ���ͬһ������
--[[
nRoomIndex �ĸ�room�ռ�
uParam1,uParam2 ���ѡ�е�λ��
--]]

function CLcStoreRoom:SetClickedWndState(row, col, roomIndex, state)
	assert(row and col)
	assert("boolean" == type(state))
	local wnd = self:GetSubItem(row,col)
	local Grid = self:GetGridByIndex(row, col, roomIndex)
	Grid:SetEnable(state)
	wnd:EnableWnd(state)
end

function CLcStoreRoom:GetClickedWndState(row, col, roomIndex)
	assert(row and col)
	local wnd = self:GetSubItem(row,col)
	return wnd:IsEnable()
end


--���������Ҫ�ǽ���Ʒ����򸽱������ӵ�λ�õ�Posת��Ϊ������Ʒ�����λ��
--�������ĸ����������������������ȣ����ڶ�Ӧ�����е�λ�ã���Ҫ�ǰ������еģ���1��ʼ��
--����ֵ������Ӧ�����е�ת��Ϊ�������е�
function CLcStoreRoom:GetDesPos(descRoom,descPos)
	local Backpacks = g_GameMain.m_WndBagSlots.m_lcAddBagSlots.m_BagAddBackpacks
	local ExpandSpace = g_GameMain.m_BagSpaceMgr:GetSpace(g_AddRoomIndexClient.PlayerExpandBag)
	assert(ExpandSpace ~= nil)
	local tbl = {}
	local j = 0
	for i=1, ExpandSpace:Size() do
		local Grid = ExpandSpace:GetGrid(i)
		if Grid:Size() ~= 0 then
			local BagIndex = Grid.m_Context["RoomIndex"]
			local BagSize = Grid.m_Context["Size"]
			j = j + 1
			tbl[j] = Backpacks[i]
		end
	end

	for k = 1, j do
		if tbl[k].m_StoreRoomIndex == descRoom then
			local globalDesPos = tbl[k].m_nPosBegin +  descPos
			return globalDesPos
		end
	end 

	return nil
end

--�Ҽ������Ʒ��
function CLcStoreRoom:DoByRClick(nRoomIndex,uParam1,uParam2,WndFarther)
	local CurPos = self:GetPosByIndex(uParam1, uParam2, nRoomIndex)
	local CurGrid = self:GetGridByIndex(uParam1, uParam2, nRoomIndex)
	local state, context = g_WndMouse:GetCursorState()
	--�ж��Ҽ����������ʱ������״̬�ǲ���װ������״̬���߻���Ƭ�趨״̬���ǵĻ�ȡ����굱ǰ��״̬
	if state == ECursorState.eCS_EquipIdentify or state == ECursorState.eCS_ArmorPieceEnactment or state == ECursorState.eCS_EquipSmeltSoul
	    or state == ECursorState.eCS_RenewEquip or state == ECursorState.eCS_BreakItem then
		g_WndMouse:ClearCursorSpecialState()
	end
	local Cursize = CurGrid:Size()
	if 0 == Cursize then return end
	
	if state ~= ECursorState.eCS_Normal then
		g_WndMouse:ClearCursorAll()
		return
	end
	local nBigID,nIndex = CurGrid:GetType()
	if nRoomIndex == g_StoreRoomIndex.PlayerBag or self:IsInMainBagExpandByAddBag(nRoomIndex) then --�Ҽ������Ʒ��
		assert(IsNumber(nBigID))
		assert(IsNumber(nIndex) or IsString(nIndex))
		local context = {nRoomIndex, uParam1, uParam2, Cursize, CurPos}
		if GacCheckWhichWndIsFoucs( context, nBigID, nIndex ) == false then
			g_GacUseItem(self, nBigID, nIndex, nRoomIndex, CurPos)
		end
	elseif nRoomIndex ==  g_StoreRoomIndex.PlayerDepot then
		if g_GameMain.m_WndMainBag and g_GameMain.m_WndMainBag:IsCreated() then
			Gac2Gas:QuickMove(g_Conn,g_StoreRoomIndex.PlayerDepot,CurPos,g_StoreRoomIndex.PlayerBag)
		end
	end
end

--�����ƷMessageBox�ص�����
local function splitItemFun(Context, Index)
	local fromRoom, SrcPos, nRoomIndex, CurPos, context = unpack(Context)
	if(Index == 1) then --ȷ��
		Gac2Gas:SplitItem(g_Conn, fromRoom, SrcPos, nRoomIndex, CurPos, context)
	elseif(Index == 2) then --�ܾ�
	end
	--�ظ�����Ϊ�ɵ�״̬��false�ǲ��ɵ�
	CStoreRoomWndMgr.GetMgr():SetClickedWndState(fromRoom, SrcPos, nRoomIndex, CurPos, true )
	return true
end

local function BreakItemFun(Context, Index)
	local nRoomIndex,CurPos = unpack(Context)
	if(Index == 1) then 
		CStoreRoomWndMgr.GetMgr():SetItemGridWndState(nRoomIndex,CurPos,false)
		Gac2Gas:BreakItem(g_Conn,nRoomIndex,CurPos)
	elseif(Index == 2) then 
	end
	return true
end

function CLcStoreRoom:OnEquipIntenBack(CurGrid,nRoomIndex,CurPos,Context)
	local SrcCt = g_GameMain.m_BagSpaceMgr:GetSpaceRelateLc( nRoomIndex )
	local storeRoom = g_GameMain.m_WndMainBag.m_ctItemRoom
	if SrcCt ~= storeRoom then
		return
	end
	local col, row = storeRoom:GetIndexByPos(CurPos, nRoomIndex)
	local Wnd  = storeRoom:GetWnd(row, col)
	Wnd.m_BtnCD:EnableWnd(true)
	local nBigID,nIndex = CurGrid:GetType()
	local item = CurGrid:GetItem()
	local itemid = 0
	
	if(item) then
		itemid = item:GetItemID()
	else
		return
	end
	
	--�ж��ǲ��Ǿ�̬װ��
	if g_ItemInfoMgr:IsStaticEquip(nBigID) then
		Wnd.m_BtnCD:EnableWnd(false)
		local intenBackItemType, intenBackItemName, roomIndex, nPos = Context[2], Context[3], Context[4], Context[5]
		g_GameMain.m_RoleStatus:UseEquipIntenBackItem(nBigID, nIndex, itemid ,nRoomIndex,CurPos, 0, Context)
		g_WndMouse:ClearCursorSpecialState()
	else
		MsgClient(171010)
	end
end

--��������Ʒ���������Ǵӣ�0��0����ʼ��
function CLcStoreRoom:DoByClickRoom(nRoomIndex,uParam1,uParam2,WndFarther)
	local state, context = g_WndMouse:GetCursorState()
	local CurGrid = self:GetGridByIndex(uParam1, uParam2, nRoomIndex)
	local CurPos = self:GetPosByIndex(uParam1, uParam2, nRoomIndex)
	local Cursize = CurGrid:Size()
	
	if state == ECursorState.eCS_Split and Cursize > 1 then -- ��ǰ������и���Ʒ״̬ PS���и�����츳���м���
		WndFarther.m_WndSplit = CWndSplit:new()
		WndFarther.m_WndSplit:CreateFromRes("SplitObj", g_GameMain.m_WndMainBag)
		g_ExcludeWndMgr:InitExcludeWnd(WndFarther.m_WndSplit, "�ǻ���")
		WndFarther.m_WndSplit:ShowWnd(true)
		WndFarther.m_WndSplit:SetWorkingWnd(self, uParam1, uParam2)
		WndFarther.m_WndSplit:SetSplitItemInfo(0, Cursize, nRoomIndex, uParam1, uParam2)
	elseif state == ECursorState.eCS_BreakItem then --�ֽ�
		local itemType, itemName = CurGrid:GetType()
		if itemType and itemName then
			local Quality = g_ItemInfoMgr:GetItemInfo(itemType, itemName,"Quality")
				if Quality >= 2 then --ϡ�жȴ��ڵ���2�ļ�ȷ����ʾ��
					MessageBox(g_GameMain, MsgBoxMsg(13012), BitOr(MB_BtnOK,MB_BtnCancel), BreakItemFun, {nRoomIndex,CurPos})
				else
					CStoreRoomWndMgr.GetMgr():SetItemGridWndState(nRoomIndex,CurPos,false)
					Gac2Gas:BreakItem(g_Conn,nRoomIndex,CurPos)
				end
		end
	elseif state == ECursorState.eCS_PickupItem then --��������Ʒ
		self:DoByClickRoomInPickupItemType(nRoomIndex, uParam1, uParam2, context, CurGrid, CurPos)
	elseif  state == ECursorState.eCS_PickupSplitItem then
		local fromRoom, fromrow, fromcol, count = context[1], context[2],context[3], context[4]
		local SrcCt = g_GameMain.m_BagSpaceMgr:GetSpaceRelateLc(fromRoom)
		local SrcPos = SrcCt:GetPosByIndex(fromrow, fromcol, fromRoom)
		if fromRoom == nRoomIndex and SrcPos == CurPos then
			Gac2Gas:MoveItem(g_Conn, fromRoom, SrcPos, nRoomIndex, CurPos)
		else
			if g_MainPlayer.m_ItemBagLock then
				MsgClient(160011)
				g_WndMouse:ClearCursorAll()
				return
			end
			local SrcPos = SrcCt:GetPosByIndex(fromrow, fromcol, fromRoom)
			local from_grid = g_GameMain.m_BagSpaceMgr:GetGridByRoomPos(fromRoom, SrcPos)
			local itemType1, itemName1,nBindingType1 = from_grid:GetType() 
			if itemType1 and itemName1 and nBindingType1 then
				--��������жϣ���Ϊ�п����ڲ�ֵ�ʱ���from_grid�ϵ���Ʒ�����������ӣ�from_grid��û����Ʒ
				local itemType2, itemName2,nBindingType2 = CurGrid:GetType()
				local FoldLimit = g_ItemInfoMgr:GetItemInfo(itemType1, itemName1,"FoldLimit") or 1
				if (itemType1 == itemType2 and itemName1 == itemName2 and nBindingType1 ~= nBindingType2) and FoldLimit >1 then
					CStoreRoomWndMgr.GetMgr():SetClickedWndState(fromRoom, SrcPos, nRoomIndex, CurPos, false)
					MessageBox(g_GameMain, MsgBoxMsg(13007), BitOr(MB_BtnOK,MB_BtnCancel), splitItemFun, {fromRoom, SrcPos, nRoomIndex, CurPos, context[4]})
				else
					Gac2Gas:SplitItem(g_Conn, fromRoom, SrcPos, nRoomIndex, CurPos, context[4])
				end
			else
				CStoreRoomWndMgr.GetMgr():SetClickedWndState(fromRoom, SrcPos, nRoomIndex, CurPos, true)
				g_WndMouse:ClearCursorAll()
				return
			end
		end
		CStoreRoomWndMgr.GetMgr():SetClickedWndState(fromRoom, SrcPos, nRoomIndex, CurPos, false)
		g_WndMouse:ClearCursorAll()

	elseif state == ECursorState.eCS_PickupEquip then --������װ��
		local nItemID, eEquipPart, EquipWnd = context[1], context[2],context[3]
		local REquipPart = 0
		if  Cursize ~= 0 then
			local nBigID,nIndex = CurGrid:GetType()
			local EquipPart = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"EquipPart")
			if  g_ItemInfoMgr:IsEquip(nBigID) then
				if g_ItemInfoMgr:IsJewelry(nBigID) then
					if g_ItemInfoMgr:IsRing(nBigID) 
						and (eEquipPart == EEquipPart.eRingLeft or eEquipPart == EEquipPart.eRingRight) then
						REquipPart = eEquipPart
					else
						REquipPart = EquipPartNameToNum[EquipPart]
					end
				elseif g_ItemInfoMgr:IsWeapon(nBigID) 
					and (eEquipPart == EEquipPart.eAssociateWeapon or eEquipPart == EEquipPart.eWeapon)  then
					REquipPart = eEquipPart
				elseif g_ItemInfoMgr:IsAssociateWeapon(nBigID)  then
					REquipPart = EEquipPart.eAssociateWeapon
				elseif g_ItemInfoMgr:IsArmor(nBigID) then
					REquipPart = EquipPartNameToNum[EquipPart]
				end
				if REquipPart == eEquipPart then
					g_GacUseItem(self, nBigID, nIndex, nRoomIndex, CurPos,eEquipPart)
				else
					MsgClient(1013)
				end
				g_WndMouse:ClearCursorAll()
			end
		else
			if g_MainPlayer:IsInBattleState() then
				g_WndMouse:ClearCursorAll()
				MsgClient(1024)
				return
			end			
			Gac2Gas:FetchEquipByPart(g_Conn, eEquipPart, nRoomIndex, CurPos)
			g_WndMouse:ClearCursorAll()
		end

	elseif state == ECursorState.eCS_PickupItemFromNPCShop then --���ϵ���Ʒ�Ǵ�NPC�̵��ȡ��
		--local npcName = g_GameMain.m_NPCShopSell.npcName
		local itemType, itemName, itemCount, npcShopSellContext = context[1], context[2], context[3], context[4]
		--���ŵ�Ŀ�ĵ�λ��Ϊ�գ������ѷŵ���Ʒ�����е���Ʒ��ͬ�࣬����δ�ﵽ��������
		if self:CheckDesPosOk( nRoomIndex, CurPos, itemType ) then 
			if g_ItemInfoMgr:IsSoulPearl(itemType) then
				itemName =  g_ItemInfoMgr:GetSoulpearlInfo(itemName)
			end
			g_GameMain.m_NPCShopSell:CheckMoneyOrJiFenIsEnough(itemType, itemName, npcShopSellContext, nRoomIndex, CurPos)
			--Gac2Gas:BuyItemByPos( g_Conn, npcName, itemType, itemName, itemCount, nRoomIndex, CurPos, payMoneyType)
		else
		    MsgClient(6116)
		end
		g_WndMouse:ClearCursorAll()

	elseif state == ECursorState.eCS_PickupItemFromTongDepot then --���ϵ���Ʒ�ǴӼ��������ȡ��
		local fromRoom, fromRow, fromCol, count, fromPage = context[1], context[2],context[3], context[4], context[5]
		local srcCt  = g_GameMain.m_BagSpaceMgr:GetSpaceRelateLc(fromRoom)
		local fromPos = srcCt:GetPosByIndex(fromRow, fromCol)
		Gac2Gas:BagAddItemFromCollectiveBag(g_Conn, fromRoom, fromPos, fromPage, nRoomIndex, CurPos)
	elseif state == ECursorState.eCS_EquipIdentify  then  --����װ��
		self:OnEquipIdentify(CurGrid,nRoomIndex,CurPos)
	elseif state == ECursorState.eCS_ArmorPieceEnactment  then  --����Ƭ�趨
		self:OnArmorPieceEnactment(CurGrid,nRoomIndex,CurPos)
	elseif state == ECursorState.eCS_EquipSmeltSoul then --װ��������
		self:OnEquipSmeltSoul(CurGrid,nRoomIndex,CurPos)
	elseif state == ECursorState.eCS_EquipIntenBack then--��ϴǿ��װ��	    
        self:OnEquipIntenBack(CurGrid,nRoomIndex,CurPos, context)
	elseif state == ECursorState.eCS_Normal then --����û����Ʒ
		if not self:GetClickWndItem(CurPos, nRoomIndex)  then
			self:SetPickupItem(nRoomIndex, uParam1, uParam2)
		end
	end
end

--����װ��
function CLcStoreRoom:OnEquipIdentify(CurGrid,nRoomIndex,CurPos)
	--�ж��Ƿ���ս��״̬�¡�
	if g_MainPlayer:IsInBattleState() then
		MsgClient(170009)
		return
	end
	--�ж��Ƿ��ڽ�е״̬�¡�
	if g_MainPlayer:IsInForbitUseWeaponState() then
		MsgClient(170010)
		return
	end
	
	local state,context = g_WndMouse:GetCursorState()
	local nBigID,nIndex = CurGrid:GetType()
	local item = CurGrid:GetItem()
	local itemid = 0
	
	if nil == item then
		return
	else
		itemid = item:GetItemID()
	end
	--�ж��ǲ��Ǿ�̬װ��
	if g_ItemInfoMgr:IsStaticEquip(nBigID) then
		local IsStatic = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"IsStatic")
			if IsStatic == 1 then
				MsgClient(170008)
				return
			end
		--�ж��ǲ��Ƿ��߻�����Ʒ
		if g_ItemInfoMgr:IsArmor(nBigID) or g_ItemInfoMgr:IsStaticJewelry(nBigID) then 
			GacEquipIdentify.ArmorOrJewelryIdentify(nBigID,nIndex,itemid,context,nRoomIndex,CurPos)
		elseif g_ItemInfoMgr:IsWeapon(nBigID) then --�ж��ǲ�������
			GacEquipIdentify.WeaponIdentify(nBigID,nIndex,itemid,context,nRoomIndex,CurPos,0)
		else
			MsgClient(170000)
		end
	end
	g_WndMouse:ClearCursorSpecialState()
end

--����Ƭ�趨
function CLcStoreRoom:OnArmorPieceEnactment(CurGrid,nRoomIndex,CurPos)
	--�ж��Ƿ���ս��״̬�¡�
	if g_MainPlayer:IsInBattleState() then
		MsgClient(171007)
		return
	end
	--�ж��Ƿ��ڽ�е״̬�¡�
	if g_MainPlayer:IsInForbitUseWeaponState() then
		MsgClient(171008)
		return
	end
	
	local state,context = g_WndMouse:GetCursorState()
	local nBigID,nIndex = CurGrid:GetType()
	local item = CurGrid:GetItem()
	local itemid = 0
	if nil ~= item then
		itemid = item:GetItemID()
	end
	--�ж��ǲ��Ǿ�̬װ��
	if g_ItemInfoMgr:IsStaticEquip(nBigID) then
		local tbl = {nBigID,nIndex,itemid,context,nRoomIndex,CurPos}
		g_WndMouse:SetCursorState(ECursorState.eCS_ArmorPieceEnactment,tbl)
		g_GameMain.m_EquipEnactmentAttrWnd:ArmorPieceEnactment()
		g_WndMouse:ClearCursorSpecialState()
	else
		MsgClient(171010)
	end
end

--װ��������
function CLcStoreRoom:OnEquipSmeltSoul(CurGrid,nRoomIndex,CurPos)
	--�ж��Ƿ���ս��״̬�¡�
	if g_MainPlayer:IsInBattleState() then
		MsgClient(194004)
		return
	end
	--�ж��Ƿ��ڽ�е״̬�¡�
	if g_MainPlayer:IsInForbitUseWeaponState() then
		MsgClient(194005)
		return
	end
	
	local state,context = g_WndMouse:GetCursorState()
	local nBigID,nIndex = CurGrid:GetType()
	local item = CurGrid:GetItem()
	local itemid = 0
	if nil ~= item then
		itemid = item:GetItemID()
	end
	--�ж��ǲ��Ǿ�̬װ��
	if g_ItemInfoMgr:IsStaticEquip(nBigID) then
		local DynInfo = g_DynItemInfoMgr:GetDynItemInfo(itemid)
		local DisplayName	= g_ItemInfoMgr:GetItemLanInfo(nBigID, nIndex,"DisplayName")
		local equipName = g_Tooltips:GetEquipShowName(DynInfo,DisplayName,"*")
		equipName = string.format("[%s]", equipName)
		local function CallBack(g_GameMain,uButton)
			if uButton == MB_BtnOK then
				local tbl = {nBigID,nIndex,itemid,context,nRoomIndex,CurPos}
				g_WndMouse:SetCursorState(ECursorState.eCS_EquipSmeltSoul,tbl)
				CEquipSmeltSoulScroll.EquipSmeltSoul(1) 
			end
			g_GameMain.m_EquipSmeltSoul = nil
			g_WndMouse:ClearCursorSpecialState()
			return true
		end
		if g_GameMain.m_EquipSmeltSoul then
			g_WndMouse:ClearCursorSpecialState()
			return
		end
		g_GameMain.m_EquipSmeltSoul = MessageBox(g_GameMain, MsgBoxMsg(17010,equipName),  BitOr(MB_BtnOK,MB_BtnCancel), CallBack, g_GameMain)
	end
end

--�ڰ������ﰴסSHIFT+���
function CLcStoreRoom:DoShiftDownRoom(nRoomIndex,uParam1,uParam2,WndFarther)
	local Wnd = g_GameMain.m_CreateChatWnd.m_ChatSendArea
	local CurGrid = self:GetGridByIndex(uParam1, uParam2, nRoomIndex) 
	local Cursize = CurGrid:Size()
	if Wnd:IsShow() then
		if not CurGrid:Empty() then
			local BigId, Index = CurGrid:GetType()
			local DisplayName	= g_ItemInfoMgr:GetItemLanInfo(BigId, Index,"DisplayName")
			Index = DisplayName and DisplayName or  Index
			local GlobalID = CurGrid:GetItem():GetItemID()
			Wnd.m_CEditMessage:InsertStr("[" .. GlobalID .. "]")
			local ItemTable = g_GameMain.m_CreateChatWnd.m_ChatSendArea.ItemTable
			local Item = {GlobalID = GlobalID,Index = Index, BigId = BigId}
			ItemTable[GlobalID] = Item
			Wnd.m_CEditMessage:SetFocus()
		end
	end
end

--�ڰ��������水סCtrl+���
function CLcStoreRoom:DoCtrlDownRoom(nRoomIndex,uParam1,uParam2,WndFarther)
	local state, context = g_WndMouse:GetCursorState()
	local CurGrid	= self:GetGridByIndex(uParam1, uParam2, nRoomIndex)
	local Cursize	= CurGrid:Size()	
	if(state == ECursorState.eCS_Normal and not CurGrid:Empty()) then
		WndFarther.m_WndSplit = CWndSplit:new()
		WndFarther.m_WndSplit:CreateFromRes("SplitObj", g_GameMain.m_WndMainBag)
		g_ExcludeWndMgr:InitExcludeWnd(WndFarther.m_WndSplit, "�ǻ���")
		WndFarther.m_WndSplit:ShowWnd(true)
		WndFarther.m_WndSplit:SetWorkingWnd(self, uParam1, uParam2)
		WndFarther.m_WndSplit:SetSplitItemInfo(0, Cursize, nRoomIndex, uParam1, uParam2)
	end
end

--����϶�����
function CLcStoreRoom:DoByDragRoom(nRoomIndex,uParam1,uParam2,WndFarther)
	local state, context = g_WndMouse:GetCursorState()
	local CurGrid = self:GetGridByIndex(uParam1, uParam2, nRoomIndex)
	local CurPos = self:GetPosByIndex(uParam1, uParam2, nRoomIndex)

	local Cursize = CurGrid:Size()
	if 0 == Cursize then
		return
	end
	if state == ECursorState.eCS_Normal then --����û����Ʒ
		if not self:GetClickWndItem(CurPos, nRoomIndex)  then
			self:SetPickupItem(nRoomIndex, uParam1,uParam2)
		end
	end
end

--��������������Ʒ��ʱ��������ͨ��Ʒ
function CLcStoreRoom:DoByClickRoomInPickupItemType(nRoomIndex, uParam1, uParam2, context, CurGrid, CurPos)
	local fromRoom, fromrow, fromcol, count = context[1], context[2],context[3], context[4]
	local SrcCt = g_GameMain.m_BagSpaceMgr:GetSpaceRelateLc(fromRoom)
	local SrcPos = SrcCt:GetPosByIndex(fromrow, fromcol, fromRoom)
	if fromRoom == nRoomIndex and fromrow == uParam1 and fromcol == uParam2 then --�����Ʒ�ƶ�����ʼλ��һ��
		self:SetClickedWndState(uParam1, uParam2, fromRoom, true)
		g_WndMouse:ClearCursorAll()
	else --�ǴӰ��������ֿ߲���ȡ������Ʒ
		if g_Client_IsSlotIndex(fromRoom) then
			local nSrcPos = SrcCt:GetGlobalSlotPos(SrcPos)
			g_GameMain.m_WndMainBag:SetMainItemBagState(false)
			if g_MainPlayer.m_ItemBagLock then
				MsgClient(160026)
				return
			end
			Gac2Gas:FetchBag(g_Conn, nSrcPos, nRoomIndex, CurPos)
		else
			local canPutDown = self:IfBagCanBePutdown(fromRoom, SrcPos, nRoomIndex, CurPos)
			if canPutDown then
				local from_grid = g_GameMain.m_BagSpaceMgr:GetGridByRoomPos(fromRoom, SrcPos)
				local itemType1, itemName1,nBindingType1 = from_grid:GetType() 
				local itemType2, itemName2,nBindingType2 = CurGrid:GetType()
				if itemType1 and itemName1 and nBindingType1 then
					local FoldLimit = g_ItemInfoMgr:GetItemInfo(itemType1, itemName1,"FoldLimit") or 1
					if (itemType1 == itemType2 and itemName1 == itemName2 and nBindingType1 ~= nBindingType2) and FoldLimit > 1 then
					
						function moveItemFun(self, Index)
							if(Index == 1) then --ȷ��
								Gac2Gas:MoveItem(g_Conn, fromRoom, SrcPos, nRoomIndex, CurPos)
							end
							CStoreRoomWndMgr.GetMgr():SetClickedWndState(fromRoom, SrcPos, nRoomIndex, CurPos, true) --�ظ�����Ϊ�ɵ�״̬��false�ǲ��ɵ�
							return true
						end
					
						CStoreRoomWndMgr.GetMgr():SetClickedWndState(fromRoom, SrcPos, nRoomIndex, CurPos, false)
						g_GameMain.m_MsgBox = MessageBox(g_GameMain, MsgBoxMsg(13007), BitOr(MB_BtnOK,MB_BtnCancel), moveItemFun, g_GameMain)
					else
						CStoreRoomWndMgr.GetMgr():SetClickedWndState(fromRoom, SrcPos, nRoomIndex, CurPos, false)
						Gac2Gas:MoveItem(g_Conn, fromRoom, SrcPos, nRoomIndex, CurPos)
					end
				end
			end
		end
		g_WndMouse:ClearCursorAll()
	end
end


--�ж��ƶ���������Ʒ��ʱ���Ƿ���Է��õ�Ŀ��λ�ã�������Է���:true;���򷵻�:false
function CLcStoreRoom:IfBagCanBePutdown(fromRoomIndex,fromPos,desRoomIndex,desPos)
	local SpaceMgr = g_GameMain.m_BagSpaceMgr
	local spaceSrc = SpaceMgr:GetSpace(fromRoomIndex)  
	local spaceDes = SpaceMgr:GetSpace(desRoomIndex)
	local Backpacks = g_GameMain.m_WndBagSlots.m_lcAddBagSlots.m_BagAddBackpacks

	if fromRoomIndex == g_AddRoomIndexClient.PlayerExpandBag then --�Ƿ��ǽ������ƶ�
		if Backpacks[fromRoomIndex].m_StoreRoomIndex == desRoomIndex then --�ƶ��İ���Ҫ���õ�λ���Ƿ����Լ�������
			return false
		elseif spaceSrc:GetItemCount() ~= 0 then --Ҫ�ƶ��İ������Ƿ�����Ʒ
			return false
		elseif spaceSrc:GetItemCount() == 0 and spaceDes:GetItemCount() < Backpacks[desPos].m_StoreRoomSize then --�ƶ��İ���������Ʒ������Ҫ���õ�λ�ö�Ӧ�İ������пռ�
			return true
		end
	end

	return true
end

------�������ϵ���Ʒ������������ָ��ɾ������Ʒ���ڸ��ӣ���ô��������-----------
function CLcStoreRoom:ClearCursorAllAfterDelete(nRoomIndex, nPos)
	local state, context = g_WndMouse:GetCursorState()
	if(state == ECursorState.eCS_PickupItem) then
		local fromRoom, fromRow, fromCol = context[1], context[2],context[3]
		if(fromRoom == nRoomIndex) then
			local x , y = g_GameMain.m_WndMainBag.m_ctItemRoom:GetIndexByPos(nPos, nRoomIndex)
			if(fromRow == y and fromCol == x) then
				g_WndMouse:ClearCursorAll()
			end
		end
	end
end

--**********************************************************************************************
--��ȴ��ʾ
--**********************************************************************************************

--������Ʒʣ����ȴʱ���Ƿ�С��1��
function CLcStoreRoom:IsLeftTimeShorterThanOneSec(skillName)
	local leftCoolDownTime = g_MainPlayer:GetSkillLeftCoolDownTime(skillName)
	return leftCoolDownTime <= 1000
end

function CLcStoreRoom:JudgeReCoolFromOneSec(skillName, wnd)
	if(self:IsLeftTimeShorterThanOneSec(skillName))then
		self:SetCommonCDTime(wnd)
	end
end

function CLcStoreRoom:SetCoolTimeBtn(skillName, eCoolDownType, leftTime)
	
	local function CoolDown(pos, bagIndex)
		local x, y = self:GetIndexByPos(pos, bagIndex)
		local grid = self:GetGridByIndex(y, x, bagIndex)
		local itemType, itemName = grid:GetType()
		if(3 == itemType) then
			local sSkillName = SkillItem_Common(itemName,"SkillName")
			local wnd      = self._m_CDialog[self:GetBagIndex(x, y)]
			local isEmpty  = self:GetClickWndItem(pos, bagIndex)
			
			if(not isEmpty) then
				local coolDownTime = g_MainPlayer:GetCoolDownTime(skillName, 1) * 1000
				local skillCDType  = SkillItem_Common(itemName,"SkillCoolDownType")
				if(eCoolDownType == ESkillCoolDownType.eSCDT_DrugItemSkill) then
					if skillCDType == ESkillCDType.DrugItemCD then
						self:SetCDTime(wnd, coolDownTime, leftTime)
					elseif skillCDType == ESkillCDType.SpecailItemCD then
						self:JudgeReCoolFromOneSec(sSkillName, wnd)
--					elseif skillCDType == ESkillCDType.OtherItemCD then
--						self:SetCommonCDTime(wnd)
					end
				elseif(eCoolDownType == ESkillCoolDownType.eSCDT_SpecialItemSkill) then
					if skillCDType == ESkillCDType.DrugItemCD then
						self:JudgeReCoolFromOneSec(sSkillName, wnd)
					elseif skillCDType == ESkillCDType.SpecailItemCD then
						if(skillName == sSkillName) then
							self:SetCDTime(wnd, coolDownTime, leftTime)
						else
							self:JudgeReCoolFromOneSec(sSkillName, wnd)
						end
					end
				elseif(eCoolDownType == ESkillCoolDownType.eSCDT_OtherItemSkill) then
					if skillCDType == ESkillCDType.OtherItemCD then
						if sSkillName == skillName then
							self:SetCommonCDTime(wnd)
						end
					end
				end
			end
		end
	end
	
	local SpaceMgr           = g_GameMain.m_BagSpaceMgr
	local space              = SpaceMgr:GetSpace(g_StoreRoomIndex.PlayerBag)
	local BagSize            = space:Size() --������չ�����ĸ�������
	local ExpandSpace        = g_GameMain.m_BagSpaceMgr:GetSpace(g_AddRoomIndexClient.PlayerExpandBag) --��ȡ����չ��������
	local ExpandSpaceBagSize = 0 --��չ����������
	
	for i=1, ExpandSpace:Size() do
		local Grid = ExpandSpace:GetGrid(i)
		if Grid:Size() ~= 0 then--���������������б���Ϊ1
			local index = Grid.m_Context["RoomIndex"]--��չ������index
			local size = Grid.m_Context["Size"]--�����Ĵ�С
			ExpandSpaceBagSize = ExpandSpaceBagSize + size
			for i = 1, size do
				CoolDown(i, index)--��ʼ��ȴʱ��
			end
		end
	end
	for i = 1, (BagSize - ExpandSpaceBagSize) do--��������ʼ��ȴʱ��
		CoolDown(i, 1)
	end
end

function CLcStoreRoom:BeginCoolDown(sItemName,coolDownTime,coolDownType,nRoomIndex,nPos)
	
	local function CoolDown(pos, bagIndex)
		local x, y = self:GetIndexByPos(pos, bagIndex)
		local grid = self:GetGridByIndex(y, x, bagIndex)
		local itemType, itemName = grid:GetType()
		if( sItemName == itemName) then
			if nRoomIndex == bagIndex and nPos == pos then
				if grid:Size() <= coolDownType then	return end 
			end
			local wnd     = self._m_CDialog[self:GetBagIndex(x, y)]
			local isEmpty = self:GetClickWndItem(pos, bagIndex)
			if(not isEmpty) then
				self:SetCDTime(wnd, coolDownTime, coolDownTime)
			end
		end
	end
	
	if g_MainPlayer.CoolDownTime == nil then g_MainPlayer.CoolDownTime = {} end
	if g_MainPlayer.CoolDownBeginTime == nil then g_MainPlayer.CoolDownBeginTime = {} end
	g_MainPlayer.CoolDownTime[sItemName] = coolDownTime
	g_MainPlayer.CoolDownBeginTime[sItemName] = os.time()

	local SpaceMgr = g_GameMain.m_BagSpaceMgr
	local space = SpaceMgr:GetSpace(g_StoreRoomIndex.PlayerBag)
	local BagSize = space:Size()--������չ�����ĸ�������
	local ExpandSpace = g_GameMain.m_BagSpaceMgr:GetSpace(g_AddRoomIndexClient.PlayerExpandBag)	--��ȡ����չ��������
	local ExpandSpaceBagSize = 0--��չ����������
	
	for i=1, ExpandSpace:Size() do
		local Grid = ExpandSpace:GetGrid(i)
		if Grid:Size() ~= 0 then--���������������б���Ϊ1
			local index = Grid.m_Context["RoomIndex"]--��չ������index
			local size = Grid.m_Context["Size"]--�����Ĵ�С
			ExpandSpaceBagSize = ExpandSpaceBagSize + size
			for i = 1, size do
				CoolDown(i, index)--��ʼ��ȴʱ��
			end
		end
	end
	for i = 1, (BagSize - ExpandSpaceBagSize) do--��������ʼ��ȴʱ��
		CoolDown(i, 1)
	end
	--g_GameMain.m_MainSkillsToolBar:setCoolTimerBtn(sItemName,sItemName,coolDownTime)
end

--�������CD��ʾ
function CLcStoreRoom:ResetCD()
	local function CoolDown(pos, bagIndex)
		local x, y    = self:GetIndexByPos(pos, bagIndex)
		local grid    = self:GetGridByIndex(y, x, bagIndex)
		local wnd     = self._m_CDialog[self:GetBagIndex(x, y)]
		local isEmpty = self:GetClickWndItem(pos, bagIndex)
		if(not isEmpty) then
			self:SetCDTime(wnd, 1000, 0)
		end
	end
		
	local SpaceMgr = g_GameMain.m_BagSpaceMgr
	local space = SpaceMgr:GetSpace(g_StoreRoomIndex.PlayerBag)
	local BagSize = space:Size()--������չ�����ĸ�������
	local ExpandSpace = g_GameMain.m_BagSpaceMgr:GetSpace(g_AddRoomIndexClient.PlayerExpandBag)	--��ȡ����չ��������
	local ExpandSpaceBagSize = 0--��չ����������
	
	for i=1, ExpandSpace:Size() do
		local Grid = ExpandSpace:GetGrid(i)
		if Grid:Size() ~= 0 then--���������������б���Ϊ1
			local index = Grid.m_Context["RoomIndex"]--��չ������index
			local size = Grid.m_Context["Size"]--�����Ĵ�С
			ExpandSpaceBagSize = ExpandSpaceBagSize + size
			for i = 1, size do
				CoolDown(i, index)--��ʼ��ȴʱ��
			end
		end
	end
	for i = 1, (BagSize - ExpandSpaceBagSize) do--��������ʼ��ȴʱ��
		CoolDown(i, 1)
	end
end

--[[
--��������ȷ�ģ�ֻ���������ֻ���������ƶ�֮ǰ����
--�ֿ���û����ȴ�������ڲֿ�Ͱ���������Ʒ��ʱ�򣬵��������������
--����Ժ�ֿ������ȴ����δ�����Լ���ʹ��

--�ƶ���������Ʒͬʱ�ƶ�ˢCDʱ�����
function CLcStoreRoom:MoveCDItem(nFromRoom, fromPos, nDesRoom, toPos)
	local fromGridValues = self:getCoolDownValues(nFromRoom, fromPos)
	local toGridValues = self:getCoolDownValues(nDesRoom, toPos)
	fromGridValues[1],toGridValues[1] = toGridValues[1],fromGridValues[1]
	local tbl = {fromGridValues, toGridValues}
	for i,v in pairs(tbl) do
		local pos, coolDownTime, leftCoolDownTime = v[1],v[2],v[3]
		local wnd = self._m_CDialog[pos]
		self:SetCDTime(wnd, coolDownTime, leftCoolDownTime)
	end
end
--]]

--���õ�ǰ���ӵ�CDʱ��
function CLcStoreRoom:CDItemChanged(nRoomIndex, nPos)
	local tblSimpleRoomIndex = g_SimpleRoomIndex
	for i, v in ipairs(tblSimpleRoomIndex) do
		if(v == nRoomIndex) then return end
	end
	local toGridValues = self:getCoolDownValues(nRoomIndex, nPos)
	local pos, coolDownTime, leftCoolDownTime = toGridValues[1], toGridValues[2], toGridValues[3]
	local wnd = self._m_CDialog[pos]
	if coolDownTime < 0 or leftCoolDownTime < 0 then
		return
	end
	self:SetCDTime(wnd, coolDownTime, leftCoolDownTime)
end

function CLcStoreRoom:ResetOneCD(nRoomIndex, nPos)
	local toGridValues = self:getCoolDownValues(nRoomIndex, nPos)
	local pos = toGridValues[1]
	local wnd = self._m_CDialog[pos]
	self:SetCDTime(wnd, 1000, 0)
end


function CLcStoreRoom:getCoolDownValues(roomIndex, pos)
	local x, y = self:GetIndexByPos(pos, roomIndex)
	local grid = self:GetGridByIndex(y, x, roomIndex)
	local itemType, itemName = grid:GetType()
	local coolDownTime, leftCoolDownTime = self:getCoolDownTimeByItemInfo(itemType, itemName)
	if g_GameMain.m_WndMainBag.m_ctItemRoom:IsInMainBagExpandByAddBag(roomIndex) then
		pos = self:GetDesPos(roomIndex,pos)
	end
	
	return {pos, coolDownTime, leftCoolDownTime}
end

function CLcStoreRoom:getCoolDownTimeByItemInfo(itemType, itemName)

	local function GetLeftCoolDownTime(coolDownBeginTime, coolDownTime)
		local time = coolDownTime - (os.time()-coolDownBeginTime)*1000
		return time > 0 and time or 0
	end
	
	if itemType == 3 then
		local skillName			= g_ItemInfoMgr:GetItemInfo(itemType, itemName,"SkillName")
		if skillName == nil or skillName == "" then
			return 0, 0
		end
		local coolDownTime     = g_MainPlayer:GetCoolDownTime(skillName, 1) * 1000
		local leftCoolDownTime = g_MainPlayer:GetSkillLeftCoolDownTime(skillName)
		return coolDownTime, leftCoolDownTime
	elseif itemType == 16 or itemType == 1 or itemType == 10 then
		if g_MainPlayer.CoolDownTime == nil then g_MainPlayer.CoolDownTime = {} end
		if g_MainPlayer.CoolDownBeginTime == nil then g_MainPlayer.CoolDownBeginTime = {} end
		local coolDownTime = g_MainPlayer.CoolDownTime[itemName] or 0
		local coolDownBeginTime = g_MainPlayer.CoolDownBeginTime[itemName] or 0
		local leftCoolDownTime  = GetLeftCoolDownTime(coolDownBeginTime, coolDownTime)
		return coolDownTime, leftCoolDownTime
	end
	return 0, 0
end

function CLcStoreRoom:SetCDTime(wnd, coolDownTime, leftCoolDownTime)
	wnd.m_ClockCD:SetBackImageColor(0x9900BF00)
	wnd.m_ClockCD:setTime(coolDownTime)
	wnd.m_ClockCD:setRunedTime(coolDownTime - leftCoolDownTime)
end

function CLcStoreRoom:SetCommonCDTime(wnd)
	self:SetCDTime(wnd,1000,1000)
end

function CLcStoreRoom:GetBagIndex(x, y)
	return y * self.m_nCol + x + 1
end

--**********************************************************************************************
--��ȴ��ʾ
--**********************************************************************************************

--���°�����װ����ToolTips, ��bUpdateSomeItemΪtrue���������Ʒidˢ��tooltips,����������Ʒtooltipsˢ��
function CLcStoreRoom:UpdateBagTips(bUpdateSomeItem, nItemID, bOriginalPrice)
	local SpaceMgr = g_GameMain.m_BagSpaceMgr
	local space = SpaceMgr:GetSpace(g_StoreRoomIndex.PlayerBag)
	local BagSize = space:Size()
	for i = 1, BagSize do
		local fromRoom,srcPos 
		if(i > g_PlayerMainBag.size) then  
			fromRoom,srcPos = g_GameMain.m_WndBagSlots.m_lcAddBagSlots:GetSlotIndex(i)
		else
			fromRoom = g_StoreRoomIndex.PlayerBag
			srcPos = i
		end
		local CurGrid = SpaceMgr:GetGridByRoomPos(fromRoom, srcPos)
		local nBigID,nIndex = CurGrid:GetType()
		if (not CurGrid:Empty()) then
			local vWnd     = self._m_CDialog[i]
			local num  = CurGrid:Size()
			local GlobalID = CurGrid:GetItem():GetItemID()
			if bUpdateSomeItem == true  then
				if GlobalID == nItemID then
					g_SetWndMultiToolTips(vWnd:GetParent(),nBigID,nIndex,GlobalID,num,bOriginalPrice)
				end
			else
				g_SetWndMultiToolTips(vWnd:GetParent(),nBigID,nIndex,GlobalID,num,bOriginalPrice)
			end
		end
	end	
end

function CLcStoreRoom:UpdateRoomTipsAll(nRoom)
	local SpaceMgr	= g_GameMain.m_BagSpaceMgr
	local space		= SpaceMgr:GetSpace(nRoom)
	local BagSize	= space:Size()
	for i = 1, BagSize do
		local nRoom, srcPos = nRoom, i
		local CurGrid = SpaceMgr:GetGridByRoomPos(nRoom, srcPos)
		local nBigID, nIndex = CurGrid:GetType()
		if (not CurGrid:Empty()) then
			local vWnd     = self._m_CDialog[i]
			local num  = CurGrid:Size()
			local GlobalID = CurGrid:GetItem():GetItemID()
			g_SetWndMultiToolTips(vWnd:GetParent(), nBigID, nIndex, GlobalID, num)
		end
	end
end

function CLcStoreRoom:GetMoneyToFixDemagedEquipInBag()
    local SpaceMgr	= g_GameMain.m_BagSpaceMgr
	local space		= SpaceMgr:GetSpace(g_StoreRoomIndex.PlayerBag)
	local BagSize	= space:Size()
	local moneyneedToFixEquip = 0
	local needLockedPos = {}
	for i = 1, BagSize do
		local nRoom, srcPos 
		if(i > g_PlayerMainBag.size) then  
			nRoom, srcPos = g_GameMain.m_WndBagSlots.m_lcAddBagSlots:GetSlotIndex(i)
		else
			nRoom = g_StoreRoomIndex.PlayerBag
			srcPos = i
		end
		local CurGrid = SpaceMgr:GetGridByRoomPos(nRoom, srcPos)
		local nBigID, nIndex = CurGrid:GetType()
		if (not CurGrid:Empty()) then
		    if tonumber(nBigID) >= 5 and tonumber(nBigID) <= 9  then
    			local GlobalID = CurGrid:GetItem():GetItemID()
    			local DynInfo = g_DynItemInfoMgr:GetDynItemInfo(GlobalID)
    			if not DynInfo then	
						local ItemId = GlobalID or 0
						LogErr("��Ʒ��̬��Ϣ����" .. "sBigID:" .. nBigID .. "sIndex:" .. nIndex  .. "ID:" .. ItemId)
						return
					end
    			if tonumber(DynInfo.CurDuraValue) < tonumber(DynInfo.MaxDuraValue) then
    			    table.insert(needLockedPos, {nRoom, srcPos})
    			    local needMoney = MoneyConsumedFixingEquip_Common(DynInfo.BaseLevel,"MoneyConsumed")
    			    moneyneedToFixEquip = moneyneedToFixEquip + needMoney
    			end
    	  end
		end
	end
	return moneyneedToFixEquip, needLockedPos
end


local QualityIconInfo = {} --�洢װ��ϡ�жȶ�Ӧ��Ч��ͼ����
QualityIconInfo[2] = "GreenEquip"
QualityIconInfo[3] = "BlueEquip"
QualityIconInfo[4] = "PurpleEquip"
QualityIconInfo[5] = "OrangeEquip"
QualityIconInfo[6] = "SpecialYellow"
QualityIconInfo[7] = "SpecialGreen"

--����װ��ϡ�жȣ�����װ��ͼ����ʾЧ��
function CLcStoreRoom:SetItemFlashInfo(roomIndex, pos)
	local SrcCt = g_GameMain.m_BagSpaceMgr:GetSpaceRelateLc( roomIndex )
	local storeRoom = g_GameMain.m_WndMainBag.m_ctItemRoom
	if SrcCt ~= storeRoom then
		return
	end
	local col, row = storeRoom:GetIndexByPos(pos, roomIndex)
	local Wnd  = storeRoom:GetWnd(row, col)
	local grid = g_GameMain.m_BagSpaceMgr:GetGridByRoomPos(roomIndex, pos)
	Wnd.m_BtnCD:DelFlashAttention()
	if grid:Empty() then
		return
	end
	local itemID = grid:GetItem():GetItemID()
	self:SetQualityFlashInfo(Wnd.m_BtnCD, itemID)
	self:SetPurchasingAgentFlashInfo(Wnd.m_BtnCD, itemID)
end

function CLcStoreRoom:DelItemFlashInfo(roomIndex, pos)
	local storeRoom = g_GameMain.m_WndMainBag.m_ctItemRoom
	local col, row = storeRoom:GetIndexByPos(pos, roomIndex)
	local Wnd  = storeRoom:GetWnd(row, col)
	Wnd.m_BtnCD:DelFlashAttention()
end

function CLcStoreRoom:SetQualityFlashInfo(iconWnd, itemID)
    local dynInfo = g_DynItemInfoMgr:GetDynItemInfo(itemID)
    local itemType, itemName = dynInfo.m_nBigID, dynInfo.m_nIndex
    if g_ItemInfoMgr:IsStaticEquip(itemType) == false then
       return 
    end
    local itemInfo = g_ItemInfoMgr:GetItemInfo(itemType, itemName)
    local intensifyPhase = dynInfo.IntensifyPhase
    local suitName = dynInfo.SuitName
    local _, quality =  g_Tooltips:GetSuitNameColor(dynInfo, itemType, itemName)
    local quality = CConsignment.GetEquipQuality(intensifyPhase, dynInfo, itemInfo)
    local iconInfo = QualityIconInfo[quality]
    iconWnd:DelFlashAttention()
    if iconInfo == nil then
        return 
    end
    iconWnd:AddFlashInfoByName(iconInfo)
end

function CLcStoreRoom:SetPurchasingAgentFlashInfo(iconWnd, itemID)
	local dynInfo = g_DynItemInfoMgr:GetDynItemInfo(itemID)
	local itemType, itemName, bindingType = dynInfo.m_nBigID, dynInfo.m_nIndex, dynInfo.BindingType
	--iconWnd:DelFlashAttention()
	if dynInfo.OpenedFlag then
		return
	end
	if CPurchasingAgentMainWnd.GetWnd():IsCanSellPurchasingItem(itemName, bindingType) == false then
		return 
	end
	iconWnd:AddFlashInfoByNameImp("ItemForSell")
end


--������Ʒ��𣬵õ�����������ͬ�����Ʒ����Ϣ
function CLcStoreRoom:GetAdaptedItemList(itemType)
	local itemList = {}
	local SpaceMgr = g_GameMain.m_BagSpaceMgr
	local space = SpaceMgr:GetSpace(g_StoreRoomIndex.PlayerBag)
	local BagSize = space:Size()
	for i = 1, BagSize do
		local fromRoom,srcPos 
		if(i > g_PlayerMainBag.size) then  
			fromRoom,srcPos = g_GameMain.m_WndBagSlots.m_lcAddBagSlots:GetSlotIndex(i)
		else
			fromRoom = g_StoreRoomIndex.PlayerBag
			srcPos = i
		end
		local CurGrid = SpaceMgr:GetGridByRoomPos(fromRoom, srcPos)
		local type, name = CurGrid:GetType()
        local itemCount = CurGrid:Size()
        local item = CurGrid:GetItem()
        if item ~= nil then
            local GlobalID = item:GetItemID()
            if itemType == type then
                if itemList[name] == nil then
                    itemList[name] = {}
                    itemList[name].Count = itemCount
                    itemList[name].RoomIndex = fromRoom
                    itemList[name].Pos =  srcPos
                    itemList[name].ID =  GlobalID
                else
                    itemList[name].Count = itemList[name].Count + itemCount
                end
            end
        end
	end
 
	return itemList
end