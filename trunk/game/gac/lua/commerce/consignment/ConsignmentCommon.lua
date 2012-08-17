CConsignmentCommon = class (SQRDialog)


local Panel = {}
Panel.SellOrder = 1
Panel.CharSellOrder = 3

--������Ʒ�����Ӷ����ɹ�����ն�Ӧ������Ϣ
function CConsignmentCommon.RetCSMAddOrderSuc( wndNo, IsSuc )
	if wndNo == Panel.CharSellOrder then
		
		if IsSuc == true then
		    g_GameMain.m_CSMSellCharOrderWnd:InitSellOrderWndInfo()
		    g_GameMain.m_CSMSellCharOrderWnd:VirtualExcludeWndClosed()
			local wnd = g_GameMain.m_CSMSellCharOrderWnd
			if wnd.OrderType == nil then
				wnd.OrderType = 0 
			end
			local page = 0 
			
			if wnd.CurPage == 0 then
				page = 1
				Gac2Gas:CSMSearchCharSellOrder(g_Conn, wnd.OrderType, page)
			else
				Gac2Gas:CSMSearchCharSellOrder(g_Conn, wnd.OrderType, wnd.CurPage)
			end  		 
		else
            g_GameMain.m_CSMSellCharOrderWnd.m_CSMTipsWnd:ShowWnd(false)
		end 
	end	
end

--ȡ�������ɹ�����ն�Ӧ������Ϣ
function CConsignmentCommon.RetCSMCancelOrderSucc( wndNo, IsSuc )
	if wndNo == Panel.CharSellOrder then
		if IsSuc == true then
			local wnd = g_GameMain.m_CSMSellCharOrderWnd   		
			if # wnd.m_CSMOrderInfoTbl == 1 then
				wnd.CurPage = wnd.CurPage - 1
			end
			wnd:InitSellOrderWndInfo()
			local page = 0 
			if wnd.CurPage == 0 then
				page = 1
				Gac2Gas:CSMSearchCharSellOrder(g_Conn, wnd.OrderType, page)
			else
				Gac2Gas:CSMSearchCharSellOrder(g_Conn, wnd.OrderType, wnd.CurPage)
			end  		 
		end
	end	
end

--�ӷ���˵õ����ۻ��չ������һ�μ۸�
function CConsignmentCommon.RetGetCSMRememberPrice(pannelNo, price)
	gac_gas_require "framework/common/CMoney"
	local money = CMoney:new()
	local jinCount, yinCount, tongCount = money:ChangeMoneyToGoldAndArgent(price)
	if pannelNo == Panel.CharSellOrder then
		g_GameMain.m_CSMSellCharOrderWnd.m_Jin:SetWndText(jinCount)
		g_GameMain.m_CSMSellCharOrderWnd.m_Yin:SetWndText(yinCount)
		g_GameMain.m_CSMSellCharOrderWnd.m_Tong:SetWndText(tongCount)
        g_GameMain.m_CSMSellCharOrderWnd:SetSysFee()
		g_GameMain.m_CSMSellCharOrderWnd.m_Sell:EnableWnd(true)
	end
end

function CConsignmentCommon.RetCloseCSMWnd()
	g_GameMain.m_CSMSellOrderWnd:ShowWnd(false)
	if g_GameMain.m_CSMSellCharOrderWnd then
	    g_GameMain.m_CSMSellCharOrderWnd:ShowWnd(false)
	end
end

--���۽����������б�ѡ�����б��е�ĳ����Ʒ
--������1��ʾ����ɹ���2��ʾ���ڳ��н�Ǯ����������ʧ�ܣ�3��ʾ������������Ѿ������˴���Ʒ������ʧ��
function CConsignmentCommon.RetCSMBuyOrderError( IsSuc )
	--������ʾ��ѡ������Ʒ��ǰҳ����Ʒ�б���Ϣ
	if IsSuc == 1 then
    	if # g_GameMain.m_CSMSellOrderWnd.m_CSMOrderInfoTbl == 1 then
			g_GameMain.m_CSMSellOrderWnd.CurPage = g_GameMain.m_CSMSellOrderWnd.CurPage - 1
		end
		g_GameMain.m_WndBagSlots.m_lcAddBagSlots:UpdateBagSlotsPos()
        g_GameMain.m_CSMSellOrderWnd:SearchAddTreeListInfo(1161)
	elseif IsSuc == 2 then
		g_GameMain.m_CSMSellOrderWnd.m_MsgBox  = MessageBox( g_GameMain.m_CSMSellOrderWnd, MsgBoxMsg(150), MB_BtnOK )

	elseif IsSuc == 3 then                                                                  
		g_GameMain.m_CSMSellOrderWnd.m_MsgBox  = MessageBox( g_GameMain.m_CSMSellOrderWnd, MsgBoxMsg(151), MB_BtnOK )
	end 
end

--����������Ҫ��ʾ����Ʒ�б������������ʾ�ڼ��۽��������Ӧ�Ľ���
function CConsignmentCommon.RetCSMOrderListEnd( wndNo )
	local wnd = nil
	if wndNo == Panel.SellOrder then 
		wnd = g_GameMain.m_CSMSellOrderWnd
	elseif wndNo == Panel.CharSellOrder then
		wnd = g_GameMain.m_CSMSellCharOrderWnd
	end  
	wnd:ShowConsignmentItemList()
end

--�õ�������Ʒ�б�
function CConsignmentCommon.RetCSMOrderList( wndNo, orderID, playerName, itemType, itemName, itemPrice, itemCount,  leftTime, itemID )
	local showLeftTime = math.ceil(leftTime)
	if showLeftTime <= 0 then
	   showLeftTime = GetStaticTextClient(1287)
	end
	local wnd = nil
	if wndNo == Panel.SellOrder then 
		wnd = g_GameMain.m_CSMSellOrderWnd
	elseif wndNo == Panel.CharSellOrder then
		wnd = g_GameMain.m_CSMSellCharOrderWnd
	end	
	wnd:SetCSMOrderInfoTbl( orderID, itemType, itemName, itemCount, playerName, itemPrice, showLeftTime, itemID )
end

local function SetCurPage(wndObj, itemTotalNo)
	wndObj.MaxPageNo = math.ceil( itemTotalNo/50 )
	if wndObj.MaxPageNo >  0  and
		wndObj.CurPage == 0  then
		wndObj.CurPage = 1    
	end
	if wndObj.MaxPageNo == 0 then
        wndObj.CurPage = 0
	end
	if wndObj.CurPage > wndObj.MaxPageNo then
        wndObj.CurPage = 1
	end
end

--�õ�Ҫ��ʾ�ĸ�����Ʒ������Ŀ
function CConsignmentCommon.RetCSMTotalNo( wndNo, itemTotalNo )
    local wnd = nil 
	if wndNo == Panel.SellOrder then 
		wnd = g_GameMain.m_CSMSellOrderWnd

	elseif wndNo == Panel.CharSellOrder then
		wnd = g_GameMain.m_CSMSellCharOrderWnd
	end	
	wnd:InitSellOrderWndInfo()
	SetCurPage(wnd, itemTotalNo)
end

--��ʼ����Ʒ�б�
function CConsignmentCommon:SetCSMOrderInfoTbl( orderID, itemType, itemName, itemCount, playerID, itemPrice, leftTime, itemID )
	local node = {}
	node.orderID = orderID
	node.itemType = itemType
	node.itemName = itemName
	node.itemCount = itemCount
	node.seller = playerID
	node.sellPrice = itemPrice 
	node.leftTime = leftTime
	node.itemID		=	itemID

	table.insert( self.m_CSMOrderInfoTbl, node )
end

function CConsignmentCommon.RetCSMAddSellOrderOverAvgPrice(itemType, itemName, avgPrice)
    local displayName = g_ItemInfoMgr:GetItemLanInfo(itemType, itemName,"DisplayName")
    local str =g_MoneyMgr:ChangeMoneyToString(avgPrice * 2, EGoldType.GoldCoin )
    MsgClient(8037, displayName, str)
end 

function CConsignmentCommon:ShowConsignmentItemList()
	if self.CurPage <= 1 then
		self.m_PrePageBtn:EnableWnd(false)
    else
		self.m_PrePageBtn:EnableWnd( true )
	end

	if self.CurPage == self.MaxPageNo or self.MaxPageNo <= 1  then
		self.m_NextPageBtn:EnableWnd(false)
	end
	if self.CurPage < self.MaxPageNo and self.MaxPageNo > 1 then
		self.m_NextPageBtn:EnableWnd( true )
	end 

	self.m_PageNo:SetWndText(string.format("%d/%d", self.CurPage, self.MaxPageNo ))
	self:ShowSellList()  
end

--�����б�����ʾ�����������
function CConsignmentCommon:SetStrInItem(item, ItemData)
	for i = 1, # ItemData do
		if i == 2 then	 --�������ʾ��Ǯ�Ļ���������ʾ����ͭ
			local itemPrice = ItemData[i]
			gac_gas_require "framework/common/CMoney"
			local money = CMoney:new()
--			local tblWnd = {item:GetDlgChild("GoldCount"),item:GetDlgChild("GoldImage"),item:GetDlgChild("YinCount"),item:GetDlgChild("YinImage"),item:GetDlgChild("TongCount"),item:GetDlgChild("TongImage")}
--			money:ShowMoneyInfo(itemPrice,tblWnd)
			local gold, yin, tong = money:ChangeMoneyToGoldAndArgent(itemPrice)
			item:GetDlgChild("GoldCount"):SetWndText(gold)
			item:GetDlgChild("YinCount"):SetWndText(yin)
			item:GetDlgChild("TongCount"):SetWndText(tong)
		else
			local itemStr = "Item" .. i
			item:GetDlgChild(itemStr):SetWndText(ItemData[i])
		end
	end
end

--------�Ѵ�װ��ʱ������Ʒtooltip���и��£���֤װ����tooltip�Ƚ���Ϣ��ȷ---------
function CConsignmentCommon:UpdateCSMSellListTooltip()
    for i=1, # self.m_CSMOrderInfoTbl do
        local iconWnd = self.m_CSMOrderItemWndTbl[i].IconWnd 
        local itemBtn = self.m_CSMOrderItemWndTbl[i].ItemBtn 
        local itemType = tonumber(self.m_CSMOrderInfoTbl[i].itemType)
        local itemName = self.m_CSMOrderInfoTbl[i].itemName
        local index = string.find(itemName, "*", 1, true)
		if index ~= nil then
			itemName = string.sub(itemName, index + 1)
		end
        local itemCount =self.m_CSMOrderInfoTbl[i].itemCount
        local itemID =  self.m_CSMOrderInfoTbl[i].itemID
        g_SetWndMultiToolTips(iconWnd,itemType,itemName,itemID,itemCount)     
        g_SetWndMultiToolTips(itemBtn,itemType,itemName,itemID,itemCount)     
    end
end

--��Ʒ���͡���Ʒ���ơ���ƷID
function CConsignmentCommon:GetItemShowColorInCSM(nItemType, sItemName, nItemID)
    local colorStr = ""
    if nItemType >= 5 and nItemType <= 9 then   --��ȡװ��������ʾ��ɫ
    		local itemDynInfo = g_DynItemInfoMgr:GetDynItemInfo(nItemID)
        colorStr = g_Tooltips:GetSuitNameColor(itemDynInfo,nItemType, sItemName)
    else    --��ͨ��Ʒ��ʾ��ɫ
        colorStr = g_Tooltips:GetQualityColor(nItemType, sItemName)      
    end
    return colorStr
end

-----------------------���۽�����������Ʒ�б� ��Ʒ���� ------------------------
function CConsignmentCommon:GetCSMTreeListTbl()
    self.m_TreeDataInLan = {}   --��ȡ������Ա��й��ڼ��۽����������б�����ݣ�������ʾ�ڽ�����
    self.m_TreeDataInPro = {}   --��ȡ������еļ��۽����������б�����, ���ڳ�����
    self.tree_config_data= {}
    local tbl = self.m_TreeDataInLan    
    local keys = Lan_CSMTreeList_Client:GetKeys()
    for i,v in pairs( keys ) do
        local sortTypeIndex = 1 --��ķ����µ�С������Ŀ  
        local Node = {}
        self.m_TreeDataInPro[i] = {}
        for k=1, 12 do
            local nodeStr
            local lanNodeStr 
            if k ~= 1 then
                nodeStr = string.format("%s%d", "ChildNode", k-1)
                lanNodeStr = string.format("%s%d", "DisChildNode", k-1)
            else
                lanNodeStr = "DisParentTreeNode"
                nodeStr = "ParentTreeNode"
            end
            local nodeInLan =   Lan_CSMTreeList_Client(i,lanNodeStr)
            local nodeInPro =   CSMTreeList_Client(i,nodeStr)
            if IsNumber(nodeInLan) ~= true then
                if nodeInLan == "" or nodeInLan == nil  then           
                    break
                else
                    local subNode = {i, sortTypeIndex}
                    tbl[nodeInLan] = subNode
                    self.m_TreeDataInPro[i][sortTypeIndex] = nodeInPro
                    if sortTypeIndex == 1 then
                        Node.text =  nodeInLan
                        Node.sub = {}
                    else
                        table.insert(Node.sub, {text = nodeInLan})
                    end
                    sortTypeIndex = sortTypeIndex + 1
                end
            end
        end
        table.insert(self.tree_config_data, Node)
    end    
end