CConsignmentSellItemWnd = class ( CConsignmentCommon )

local Panel = {}
Panel.SellOrder = 1
Panel.CharSellOrder = 3

-------------------------------����ΪRpc����-------------------------------------------------
--�������۽�����������Ʒ����
local function CreateConsignmentSellItemWnd( Wnd )
	Wnd:CreateFromRes( "CSMSellItemWnd", g_GameMain )
	Wnd:ShowWnd( true )

	g_ExcludeWndMgr:InitExcludeWnd(Wnd, 1)
	Wnd:InitCSMSellItemWndChild()
	Wnd:InitSellOrderWndInfo()
	Wnd:SetStyle(0x00040000)
    Wnd.m_bRememberPrice = true
	return Wnd
end

function CConsignmentSellItemWnd:Ctor()
    CreateConsignmentSellItemWnd(self)
end


--��ʼ�����۴����еĿؼ����ó�Ա�������洰���ӿؼ�
function CConsignmentSellItemWnd:InitCSMSellItemWndChild()
	self.m_CloseBtn			=	self:GetDlgChild("CloseBtn")
	self.m_ConsignmentList	=	self:GetDlgChild("ListCtrlWnd")
	self.m_PrePageBtn		=	self:GetDlgChild("PageUpBtn")		
	self.m_NextPageBtn		=	self:GetDlgChild("PageDownBtn")
	self.m_ResetOrderListBtnTbl = {}
	for i=1, 4 do
	    local btnStr = "ListName" .. i
	    local btnChild = self:GetDlgChild(btnStr)
	    table.insert(self.m_ResetOrderListBtnTbl, btnChild)
	end
	self.m_PageNo			=	self:GetDlgChild("PageNum")
	
	self.m_Jin					=	self:GetDlgChild("GoldCount")
	self.m_Yin					=	self:GetDlgChild("YinCount")
	self.m_Tong					=	self:GetDlgChild("TongCount")
	self.m_ItemName				=	self:GetDlgChild("ItemName")	
	self.m_Sell					=	self:GetDlgChild("Sell")
	self.m_IconWnd				=	self:GetDlgChild("IconWnd")
	self.m_RememberPriceBtn		=	self:GetDlgChild("RememberPriceChkBtn")
    self.m_FeeJinCount          =   self:GetDlgChild("SysFeeGoldCount")
	self.m_FeeYinCount          =   self:GetDlgChild("SysFeeYinCount")
	self.m_FeeTongCount         =   self:GetDlgChild("SysFeeTongCount")
	self.m_FeeJinText           =   self:GetDlgChild("SysFeeGoldImage")
	self.m_FeeYinText           =   self:GetDlgChild("SysFeeYinImage")
	self.m_FeeTongText          =   self:GetDlgChild("SysFeeTongImage")
    
    --self:SetMouseWheel(true)
    self.m_ConsignmentList:SetMouseWheel(true)
    self.m_TimeChkBtn1          =   self:GetDlgChild("TimeChkBtn1")
    self.m_TimeChkBtn2          =   self:GetDlgChild("TimeChkBtn2")
	self.m_Jin:SetIsSendMsgToParent(true)
	self.m_Yin:SetIsSendMsgToParent(true)
	self.m_Tong:SetIsSendMsgToParent(true)
end

--�����������ڲ�ѯ����ʱ���ͻ��˵���ʾ��Ϣ����
function CConsignmentSellItemWnd:CreateCSMTipsWnd(parentWnd)
    local wnd = SQRDialog:new()
    wnd:CreateFromRes("CSMCharOrderTipsWnd", parentWnd)
    wnd:SetStyle(0xc5400000)
    return wnd
end

--��ʼ�����۽�����������Ϣ
function CConsignmentSellItemWnd:InitSellOrderWndInfo()
    self:ClearWndInfo()
	self.m_CSMOrderInfoTbl = {}
	self.m_CSMOrderItemWndTbl = {}
	self.SelectGridTable = {}
	self.m_ChoosedTimeLimit = 24
	self.m_TimeChkBtn1:SetCheck(true)
	self.m_ConsignmentList:DeleteAllItem()
	self.m_Jin:SetFocus()
end

--��ʾ��Ʒ�б���Ϣ,��������Ʒ�б��е�ĳ����Ʒ����Ҫ������ʾ��Ʒ�б�
--������wndObject������壬��ǰҳ����λ����Ʒ��ID
function CConsignmentSellItemWnd:ShowSellList()
	g_GameMain.m_CSMSellCharOrderWnd.m_CSMTipsWnd:ShowWnd(false)
	local ItemListWnd = self.m_ConsignmentList
	local tbl = self.m_CSMOrderInfoTbl

	for i=1, table.maxn( tbl) do
		if ( i == 1 ) then
			ItemListWnd:InsertColumn( 0, 450 )
		end
		ItemListWnd:InsertItem( i-1, 40 )
	    local itemWnd = CConsignmentSellItemItemWnd:new()
		local item = ItemListWnd:GetSubItem( i-1, 0)
		itemWnd:CreateFromRes( "CSMSellCharOderItem", item )
		itemWnd:SetMouseWheel(true)
		itemWnd:ShowWnd( true )
		local iconWnd = itemWnd:GetDlgChild( "ItemIcon" )
		itemWnd.DelOrderBtn = itemWnd:GetDlgChild( "DelOrderBtn" )
		--local itemBtn = itemWnd:GetDlgChild("ItemBtn")
		local index = string.find(tbl[i].itemName, "*", 1, true)
		local itemName = tbl[i].itemName
		if index ~= nil then
			itemName = string.sub(tbl[i].itemName, index + 1)
		end
		local itemType = tonumber(tbl[i].itemType)
		local SmallIcon = g_ItemInfoMgr:GetItemInfo( itemType, itemName,"SmallIcon" )
		g_LoadIconFromRes(SmallIcon, iconWnd, -1, IP_ENABLE, IP_CLICKDOWN)
		
		if tbl[i].itemCount > 1 then
			iconWnd:SetWndText( "   " .. tbl[i].itemCount )
		end
		local displayName = g_ItemInfoMgr:GetItemLanInfo(itemType, itemName,"DisplayName")
		g_SetWndMultiToolTips(iconWnd,itemType,itemName,tbl[i].itemID,tbl[i].itemCount)    
		local nameShowColor = self:GetItemShowColorInCSM(itemType, itemName, tbl[i].itemID) 
		local leftTimeStr = tbl[i].leftTime .. GetStaticTextClient(1121)
		if tonumber(tbl[i].leftTime) == nil  then
		    leftTimeStr = tbl[i].leftTime
		end
	    local dynInfo =  g_DynItemInfoMgr:GetDynItemInfo(tbl[i].itemID)
	    if g_ItemInfoMgr:IsBoxitem(itemType) and dynInfo.OpenedFlag then
	        displayName =  displayName .. g_ColorMgr:GetColor("��������ɫ") .. "(" .. GetStaticTextClient(1230) .. ")"
	    end
		local BaseLevel = g_ItemInfoMgr:GetItemInfo( itemType, itemName,"BaseLevel" )
		local ItemData = {nameShowColor .. displayName,tbl[i].sellPrice,BaseLevel,leftTimeStr}
--		if type(tbl[i].leftTime) == "string" then
--		    itemBtn:EnableWnd(false)
--		end
		
		--g_SetWndMultiToolTips(itemWnd,itemType,itemName,tbl[i].itemID,tbl[i].itemCount)     
		self:SetStrInItem(itemWnd, ItemData)
		itemWnd.DelOrderBtn.Index = i
		itemWnd.IconWnd = iconWnd
		itemWnd.ItemBtn = itemWnd
		table.insert( self.m_CSMOrderItemWndTbl, itemWnd )
	end
end

-----------------------------------------�¼���Ӧ����---------------------------------------------
--ѡ��ĳ����Ʒ�󣬸���Ʒ�ĸ���ԭ������Ϊ���ɵ��״̬���˺��������ͷ�ԭ�������ĸ���
function CConsignmentSellItemWnd:VirtualExcludeWndClosed()
	local SrcCt = g_GameMain.m_BagSpaceMgr:GetSpaceRelateLc( g_StoreRoomIndex.PlayerBag )
	if self.SelectGridTable ~= nil and table.maxn( self.SelectGridTable ) > 0 then
		local x, y, roomIndex = unpack(self.SelectGridTable[1])
		SrcCt:SetClickedWndState(x, y, roomIndex, true)
		self.SelectGridTable = {}
	end
	if self.m_CSMTipsWnd then
	    self.m_CSMTipsWnd:ShowWnd(false)
	end        
end

function CConsignmentSellItemWnd:OnLButtonClick( nFlags,  uParam1, uParam2 )
	self:OnLButtonUp( nFlags,  uParam1, uParam2 )
end

--���������۽��״��ڣ���������Ʒֱ������
function CConsignmentSellItemWnd:OnLButtonUp( nFlags,  uParam1, uParam2 )
	local state, context = g_WndMouse:GetCursorState()
	if state == ECursorState.eCS_PickupItem then --��������
		self:ClearWndInfo()
		self:CSMSellItem( context )
	end
end

--���۽�����������Ʒ�����¼���Ӧ����
function CConsignmentSellItemWnd:OnCtrlmsg( Child, uMsgID, uParam1, uParam2 )
	local state, context = g_WndMouse:GetCursorState()
	if uMsgID == BUTTON_LCLICK then
		if Child == self.m_CloseBtn then
			self:ShowWnd(false)
			self:VirtualExcludeWndClosed()
			g_GameMain.m_WndMainBag:ShowWnd(false)
			g_GameMain.m_CSMSellOrderWnd :ShowWnd(true)
			g_GameMain.m_CSMSellOrderWnd:SetCurMoneyStr()
			g_GameMain.m_CSMSellOrderWnd.m_BuyItemBtn:EnableWnd(false)
			g_GameMain.m_CSMSellOrderWnd:InitSCMTipsInfo()
			if g_GameMain.m_CSMSellOrderWnd.m_PreChoosedItemChkBtn~= nil then
		        g_GameMain.m_CSMSellOrderWnd.m_PreChoosedItemChkBtn:SetCheck(false)
			    g_GameMain.m_CSMSellOrderWnd.m_PreChoosedItemChkBtn = nil
			end
			local AutoCloseWnd = CAutoCloseWnd:new()
			AutoCloseWnd:AutoCloseWnd(g_GameMain.m_CSMSellOrderWnd)

		elseif Child == self.m_PrePageBtn then
			self.CurPage = self.CurPage - 1
			self:SendSearchInfo()
		elseif Child == self.m_NextPageBtn then	  
			self.CurPage = self.CurPage + 1
			self:SendSearchInfo()
			
        elseif state == ECursorState.eCS_PickupItem then
			self:ClearWndInfo()
			self:CSMSellItem( context )  

		elseif Child == self.m_RememberPriceBtn then
			self.m_SellPriceState = not ( self.m_SellPriceState )
			self:SetCSMRememberPrice(self.m_SellPriceState)

		elseif Child == self.m_Sell then
            if g_MainPlayer.m_ItemBagLock then
                MsgClient(160046)
                return
            end
			local price = self:GetInputPrice()
			local totalFee = self:GetSysFee()
			local suc, msgID = g_MoneyMgr:CheckPayingSysFeeEnough(totalFee)
			if suc == false then
                self.m_MsgBox = MessageBox(self, MsgBoxMsg(msgID), MB_BtnOK)
            else
                if msgID ~= nil then
                    local function callBack(Context,Button) --���ѡ��ȷ����ť����֧����ʽ��Ϊ��һ������
    		            if(Button == MB_BtnOK) then 
                            Gac2Gas:CSMAddSellOrder( g_Conn, self.nRoomIndex, self.pos, self.CSMItemCount, tonumber(price), self.m_ChoosedTimeLimit, self.m_SellPriceState )
                            self.m_CSMTipsWnd:ShowWnd(true)
                            self.m_CSMTipsWnd:SetWndText(GetStaticTextClient(1161))
                        end    
                        return true 
                    end
                    self.m_MsgBox = MessageBox(self, MsgBoxMsg(msgID), BitOr(MB_BtnOK, MB_BtnCancel), callBack)                    
                else
                    Gac2Gas:CSMAddSellOrder( g_Conn, self.nRoomIndex, self.pos, self.CSMItemCount, tonumber(price), self.m_ChoosedTimeLimit, self.m_SellPriceState )
                    self.m_CSMTipsWnd:ShowWnd(true)
                    self.m_CSMTipsWnd:SetWndText(GetStaticTextClient(1161))
                end
            end

		elseif Child == self.m_TimeChkBtn1 then
		    self.m_ChoosedTimeLimit = 24
		    self.m_TimeChkBtn1:SetCheck(true)
		    self:SetSysFee()
		    
		elseif Child == self.m_TimeChkBtn2 then
		    self.m_ChoosedTimeLimit = 48
		    self.m_TimeChkBtn2:SetCheck(true)
            self:SetSysFee()
		else
		    self:SearhOrderInfoByClickedOrderType(Child)  
		end
	elseif (uMsgID == WND_NOTIFY ) then
		if (WM_IME_CHAR == uParam1 or WM_CHAR == uParam1) then
			self:AllInfoInput( Child ) 
		end  
	
	elseif uMsgID == BUTTON_RIGHTCLICKDOWN then		--�Ҽ����ȡ����Ʒ
		if Child == self.m_IconWnd then
			if self.m_ItemName:GetWndText()  ~=  ""  then
				g_ItemInfoMgr:PlayItemSound(self.m_ItemName.m_BigID,self.m_ItemName.m_Index)
				self:ClearWndInfo()
			end	
		end
	end
end

function CConsignmentSellItemWnd:SearhOrderInfoByClickedOrderType(clickedChild)
    for i=1, 4 do
        if self.m_ResetOrderListBtnTbl[i] == clickedChild then
			self.OrderType = i 
			self:SendSearchInfo()    
			break
		end 
    end
end

function CConsignmentSellItemWnd:SendSearchInfo()
	self:VirtualExcludeWndClosed()
    self:InitSellOrderWndInfo()
	if  self.CurPage == 0 or self.CurPage == nil then
		Gac2Gas:CSMSearchCharSellOrder(g_Conn, self.OrderType, 1 )
	else
		Gac2Gas:CSMSearchCharSellOrder(g_Conn, self.OrderType, self.CurPage  )
	end
    self.m_CSMTipsWnd:ShowWnd(true)
    self.m_CSMTipsWnd:SetWndText(GetStaticTextClient(1161))
end

function CConsignmentSellItemWnd:CSMSellItem( context )
	local function Callback(g_GameMain,uButton)
		g_GameMain.m_MsgBox = nil
		return true
	end
	local fromRoom, fromRow, fromCol = context[1], context[2], context[3]
	if fromRoom == g_AddRoomIndexClient.PlayerExpandBag then --����Ǵӱ������ó��İ���
		g_WndMouse:ClearCursorAll()
		return
	end
	local SrcCt = g_GameMain.m_BagSpaceMgr:GetSpaceRelateLc( fromRoom )
	local srcPos = SrcCt:GetPosByIndex( fromRow, fromCol, fromRoom )
	local grid = g_GameMain.m_BagSpaceMgr:GetGridByRoomPos(fromRoom, srcPos)
	local count = grid:Size()
	local itemType, itemName, bindingType = grid:GetType() 
	local nItemID = grid:GetItem():GetItemID()
	if g_ItemInfoMgr:IsQuestItem(itemType) then		--���ܳ���������Ʒ
		g_WndMouse:ClearCursorAll()
		g_GameMain.m_MsgBox = MessageBox(g_GameMain, MsgBoxMsg(152), MB_BtnOK, Callback, g_GameMain)
		return
	end
	local dynInfo =  g_DynItemInfoMgr:GetDynItemInfo(nItemID)
    if dynInfo and dynInfo.BindingType == 2 or dynInfo.BindingType == 3 then --��Ʒ������Ϊ����
		g_WndMouse:ClearCursorAll()
		g_GameMain.m_MsgBox = MessageBox(g_GameMain, MsgBoxMsg(153), MB_BtnOK, Callback, g_GameMain)
		return
	end

	local iconWnd = self.m_IconWnd
	local itemWnd = self.m_ItemName
	local cols = g_PlayerMainBag.columns
	local sellPirceValueType = type(self.m_SellPriceState)
	local temp = self.m_bRememberPrice
	if sellPirceValueType == "string" then
		temp = tostring(temp)
	end
	
	if self.m_SellPriceState == temp then
		Gac2Gas:GetCSMRememberPrice(g_Conn, Panel.CharSellOrder, itemType, itemName)
	end
	--����Ʒ����Ʒ����Ӧ�ĸ�����Ϊ���ɵ��״̬
	if self.SelectGridTable ~= nil and table.maxn(self.SelectGridTable) > 0 then 
		local x, y, roomIndex = unpack(self.SelectGridTable[1])
		SrcCt:SetClickedWndState(x, y, roomIndex, true)
	end
	local y, x = SrcCt:GetIndexByPos(srcPos, fromRoom)
	self.SelectGridTable[1] = {x, y, fromRoom}
	SrcCt:SetClickedWndState(x, y, fromRoom, false)

	local SmallIcon = g_ItemInfoMgr:GetItemInfo( itemType, itemName,"SmallIcon" )
	g_LoadIconFromRes(SmallIcon, iconWnd, -1, IP_ENABLE, IP_CLICKDOWN)
	g_SetWndMultiToolTips(iconWnd,itemType,itemName,nItemID,count)     
	iconWnd:SetWndText( "   " .. count )
	
	local DisplayName = g_ItemInfoMgr:GetItemLanInfo(itemType, itemName,"DisplayName")
	itemWnd:SetWndText("  " .. DisplayName)

	self.nRoomIndex = fromRoom
	self.pos = srcPos
	self.CSMItemCount = count
	self.m_ItemName.m_BigID = itemType
	self.m_ItemName.m_Index = itemName
	g_ItemInfoMgr:PlayItemSound(itemType, itemName)
	g_WndMouse:ClearCursorAll()
end


-----------------------------------------------------------------------------------------

--�жϼ��۽�����������Ʒ���ڣ�������Ʒ��������Ϣ�Ƿ�����
function CConsignmentSellItemWnd:AllInfoInput( clickedWnd )
	local inputValidate = false
	local money = CMoney:new()
	--���Ҫ���������ԵĶ���������������Ƿ�Ϸ�
	if clickedWnd == self.m_Yin or  
		clickedWnd == self.m_Tong then
		money:CheckInputMoneyValidate(clickedWnd, 2)
		
	elseif clickedWnd == self.m_Jin 	then
		money:CheckInputMoneyValidate(clickedWnd, 1)
	end
	if self.m_Jin:GetWndText() ~= "" or 
		self.m_Yin:GetWndText() ~= "" or 
		self.m_Tong:GetWndText() ~= "" then
		inputValidate = true
	end
	local itemNameWnd = self.m_ItemName
	if (self.m_Jin:GetWndText() ~= "" or self.m_Yin:GetWndText() ~= "" or self.m_Tong:GetWndText() ~= "")
		and inputValidate 
		and itemNameWnd:GetWndText() ~= ""  then
		self.m_Sell:EnableWnd( true )
	else 
		self.m_Sell:EnableWnd( false )
	end  	 
	self:SetSysFee()
end

function CConsignmentSellItemWnd:GetInputPrice()
	local goldCount = tonumber( self.m_Jin:GetWndText() )
	local silverCount = tonumber( self.m_Yin:GetWndText() )
	local tongCount = tonumber( self.m_Tong:GetWndText() )
	
	gac_gas_require "framework/common/CMoney"
	local money = CMoney:new()
	local moneyCount = money:ChangeGoldAndArgentToMoney(goldCount, silverCount, tongCount)

	return moneyCount
end

--���sellItem���ڲ��ֵ���Ϣ
function CConsignmentSellItemWnd:ClearWndInfo()
	g_DelWndImage(self.m_IconWnd, 1, IP_ENABLE, IP_CLICKDOWN)
	self:VirtualExcludeWndClosed()
	self.m_IconWnd:SetWndText("")
	self.m_IconWnd:SetMouseOverDescAfter("")
	self.m_ItemName:SetWndText("")
	self.m_Jin:SetWndText("")
	self.m_Yin:SetWndText("")
	self.m_Tong:SetWndText("")
	self.m_FeeJinCount:SetWndText("")
	self.m_FeeYinCount:SetWndText("")
	self.m_FeeTongCount:SetWndText("")
	self.m_Sell:EnableWnd( false )
end

function CConsignmentSellItemWnd:OpenMainBagWnd()
	if g_GameMain.m_WndMainBag:IsShow() == false then
		g_GameMain.m_WndMainBag:ShowWnd(true)
	end
end
-----------------------------------��ס�۸�-------------------------------------------
--��ȡ�����ļ�RememberPrice.txt,�õ���ǰ���ڳ��ۺ��չ��۸��Ƿ��м�¼
--����:1��ʾ���ۣ�2��ʾ�չ�
--����ֵ���õ�����ס�۸񡱵�ǰ��״̬���ǻ��
function CConsignmentSellItemWnd:GetCSMRememberPriceState()
	local rememberPriceState  = false		
	local filePath = g_RootPath .. "var/gac/RememberPrice.txt"
	local file=CLuaIO_Open(filePath,"r")
	if file ~= nil then
        local text = file:ReadLine()
        rememberPriceState = text
        file:Close()
        if rememberPriceState == "false" then
        	return false
        elseif rememberPriceState == "true" then
        	return true
    	end
    end
end

--��Ҹ����˳��ۡ��չ�����ס�۸�������ܵ�״̬����¼�������ļ�RememberPrice.txt�У����ı仺���еı���״̬
--������1��2��1��ʾ���ۣ�2��ʾ�չ�������ס�۸��ܵ�״̬��true��ʾ���false��ʾȡ�����
function CConsignmentSellItemWnd:SetCSMRememberPrice( rememberPricestate )
	local filePath = g_RootPath .. "var/gac/RememberPrice.txt"
    local newFileState = rememberPricestate

    local writefile = CLuaIO_Open(filePath,"w")
    if writefile ~= nil then
        writefile:WriteString(tostring(newFileState))
        writefile:Close()
    end
end

--------------------------------------------------------------------------------------------

--ϵͳ�շѸ�����Ӷ�������Ʒ�ۼۺͶ���ʱ�ޱ仯
function CConsignmentSellItemWnd:SetSysFee()
    local curOderTime = self.m_ChoosedTimeLimit
    local itemCount = g_GameMain.m_CSMSellCharOrderWnd.CSMItemCount
    local itemPrice = self:GetInputPrice()
    if itemCount == nil or itemPrice == 0  then
       self.m_FeeJinCount:SetWndText("")
       self.m_FeeYinCount:SetWndText("")
       self.m_FeeTongCount:SetWndText("")
       return 
    end
    local money = CMoney:new()
    local totalFee = money:CalculateTotalFee(itemPrice, 1, 0.01, curOderTime/24)
    local wndTbl = {self.m_FeeJinCount, self.m_FeeYinCount, self.m_FeeTongCount}
    money:ShowMoneyInfoWithoutShowingWndFalse(totalFee,wndTbl)
end

function CConsignmentSellItemWnd:GetSysFee()
    local money = CMoney:new()
    local feeJinCount =  self.m_FeeJinCount:GetWndText()
    local feeYinCount =  self.m_FeeYinCount:GetWndText()
    local feeTongCount = self.m_FeeTongCount:GetWndText()
    local totalFee = money:ChangeGoldAndArgentToMoney(feeJinCount, feeYinCount, feeTongCount)
    return totalFee
end