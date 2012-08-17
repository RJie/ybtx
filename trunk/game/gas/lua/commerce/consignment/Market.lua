gas_require "commerce/consignment/MarketInc"
gas_require "framework/main_frame/GetTableFromExecuteSql"
gac_gas_require "framework/common/CMoney"

local Panel = {}
Panel.SellOrder = 1
Panel.BuyOrder = 2
Panel.CharSellOrder = 3
Panel.CharBuyOrder = 4

local ConsignmentDB = "ConsignmentDB"

--���Ƿ���ò�ѯ
function CMarket:SelectByIsOrNotCanUse(Conn, query_result)
	local player_level = Conn.m_Player:GetLevel()
	local items = {}
	for i= 1,#query_result do
		local item_type = tonumber(query_result[i][3])
		local item_level = g_ItemInfoMgr:GetItemInfo(item_type, query_result[i][4],"BaseLevel")
		if (item_level ~= nil and player_level >= item_level)  then
			table.insert(items, query_result[i])
		end
	end
	return items 
end

---------------------------------RPC FUNCTION-------------------------------

function CSMOrderTimeTests()
	local data = {}

	CallDbTrans(ConsignmentDB, "OrderTimeTest", CallBack, data,"Consignment" )
end

--���orderlist�ϵĵȼ��Ȱ�ť����ѯ�����б�
function Gac2Gas:CSMSearchSellOrder(Conn,  sName, uBeginLevel, uEndLevel, OrderBy, Page,flag,advanceSoul, maxAdvancePhase, intenSoul,maxIntenPhase, quality, campFlag)
	--�ж��Ƿ��ڶ�Ӧ��npc�Ա�
	if not DistanceJudgeBetweenNpcAndPlayer(Conn,"���۽�����")	then
	    Gas2Gac:RetCloseCSMWnd(Conn)
		return
	end
    local charID = Conn.m_Player.m_uID
	local data = {["CharID"] =charID, ["Name"]=sName,
					["BeginLevel"]=uBeginLevel, ["EndLevel"]=uEndLevel, 
					["OrderBy"]=OrderBy, ["Page"]=Page,["flag"] = flag,["AdvanceSoul"] = advanceSoul,["MaxAdvancePhase"] = maxAdvancePhase,
					["IntenSoul"] = intenSoul, ["MaxIntenPhase"]=maxIntenPhase, ["Quality"] = quality, ["CampFlag"] = campFlag}	
	local function CallBack(suc, result)
		if suc then
			local count	= result["Count"]
			local ret	= result["Ret"]
			local itemInfoTbl = result["ItemInfoTbl"]
		    local orderItemIDTbl = result["OrderItemIDTbl"]
			Gas2Gac:RetCSMTotalNo(Conn, Panel.SellOrder, count)
            local retOrderCount =  50
            local retLen = ret:GetRowNum()
            if retLen < 50 then
                retOrderCount = retLen
            end
			for i = 1, retOrderCount do
			    local nItemID = orderItemIDTbl[i]
			    if nItemID ~= 0 then
    				local nBigID, nIndex = ret(i,3), ret(i,4)
     				if flag == 2 then
    					Gas2Gac:RetCSMOrderList(Conn, Panel.SellOrder, ret(i,1),ret(i,2),ret(i,3),ret(i,9) .. "*" .. ret(i,4),ret(i,5),ret(i,6),ret(i,7),orderItemIDTbl[i])
    				else
    					Gas2Gac:RetCSMOrderList(Conn, Panel.SellOrder, ret(i,1),ret(i,2),ret(i,3),ret(i,4),ret(i,5),ret(i,6),ret(i,7),orderItemIDTbl[i])
    				end
    	        end
			end
			Gas2Gac:RetCSMOrderListEnd(Conn, Panel.SellOrder)
		end
	end
	
	--local entry = (g_DBTransDef["ConsignmentDB"])
	CallAccountManualTrans(Conn.m_Account, ConsignmentDB, "CSMSearchSellOrder", CallBack, data, "Consignment")
end

--��ѯĳ����ҵĳ��۶���
local function search_char_sell_order(Conn, result, charID )
	local count	=	result["Count"]
	local ret	=	result["Ret"]
    local orderItemIDTbl = result["orderItemIDTbl"]
	Gas2Gac:RetCSMTotalNo(Conn, Panel.CharSellOrder, count)
	local retLen = ret:GetRowNum()
	for i = 1, retLen do
	    local nItemID = orderItemIDTbl[i]
	    if nItemID ~= 0 then
    		local nBigID, nIndex = ret(i,3), ret(i,4)
     		Gas2Gac:RetCSMOrderList(Conn, Panel.CharSellOrder, ret(i,1),ret(i,2),ret(i,3),ret(i,4),ret(i,5),ret(i,6),ret(i,7),nItemID)
	    end
	end
	Gas2Gac:RetCSMOrderListEnd(Conn, Panel.CharSellOrder)	
end

function Gac2Gas:CSMSearchCharSellOrder(Conn, OrderBy, Page)
	--�ж��Ƿ��ڶ�Ӧ��npc�Ա�
	if not DistanceJudgeBetweenNpcAndPlayer(Conn,"���۽�����")	then
	    Gas2Gac:RetCloseCSMWnd(Conn)
		return
	end
	local charID = Conn.m_Player.m_uID
	local data = { ["CharId"]=charID, ["OrderBy"]= OrderBy, ["Page"]=Page } 
	local function CallBack(suc, result)
		if suc then
			search_char_sell_order(Conn, result, charID)
		end
	end
	--local entry = (g_DBTransDef["ConsignmentDB"])
	CallAccountManualTrans(Conn.m_Account, ConsignmentDB, "CSMSearchCharSellOrder", CallBack, data, "Consignment")
end

--��ӳ��۶���
local function AddSellOrder(Conn, uCount, uPrice)
	if uCount <= 0 then
		--,"������Ʒ�������Ϸ�"
		MsgToConn(Conn, 8004)
		return	false 
	end
	if uPrice < 0 then
		--,"����۸񲻺Ϸ�"
		MsgToConn(Conn,  8005)
		return	false
	end
	if uCount > 60000000000000000 then
		--,"������Ʒ��������"
		MsgToConn(Conn, 8006)
		return	false
	end
	if uPrice > 10000000000 then
		--,"���ۼ۸����"
		MsgToConn(Conn, 8007)
		return	false
	end
	return true
end

function Gac2Gas:CSMAddSellOrder(Conn, nRoomIndex, nPos, uCount, uPrice, uTime, bRememberPriceState)
	--�ж��Ƿ��ڶ�Ӧ��npc�Ա�
	if not DistanceJudgeBetweenNpcAndPlayer(Conn,"���۽�����")	then
	    Gas2Gac:RetCloseCSMWnd(Conn)
		return
	end
    if Conn.m_Player.m_ItemBagLock then
        MsgClient(160046)
        return
    end
	local ret = AddSellOrder(Conn, uCount, uPrice)
	if ret == false then
		return
	end
    local moneyObj = CMoney:new()
	local needFee = moneyObj:CalculateTotalFee(uPrice , 1, 0.01, uTime/24)
	local function CallBack(suc, result, errorMsg, bindMoneyCount, moneyCount)
		if suc then
		else
			local errorMsgId = result
			MsgToConn(Conn, errorMsgId)
			if errorMsg then
			    local itemType = errorMsg
			    local itemName = bindMoneyCount
			    local avgPrice = moneyCount
			    Gas2Gac:RetCSMAddSellOrderOverAvgPrice(Conn, itemType, itemName, avgPrice)
			end
		end
		Gas2Gac:RetCSMAddOrderSuc(Conn, Panel.CharSellOrder, suc)
	end
	
	local data = { ["CharID"]=Conn.m_Player.m_uID, ["RoomIndex"]=nRoomIndex,
					["Pos"]=nPos, ["ItemCount"] =uCount, ["RememberPriceState"]=bRememberPriceState,
					["Price"] =uPrice, ["Time"]=uTime, ["NeedFee" ] = needFee}
					
	--local entry = (g_DBTransDef["ConsignmentDB"])
	local ret = CallAccountManualTrans(Conn.m_Account, ConsignmentDB, "CSMAddSellOrder", CallBack, data,  "Consignment")
	if ret == 1 then
	    Gas2Gac:RetCSMAddOrderSuc(Conn, Panel.CharSellOrder, false)
	end
end

--ȡ����������
function Gac2Gas:CSMCancelSellOrder(Conn, uOrderId)
	--�ж��Ƿ��ڶ�Ӧ��npc�Ա�
	if not DistanceJudgeBetweenNpcAndPlayer(Conn,"���۽�����")	then
	    Gas2Gac:RetCloseCSMWnd(Conn)
		return
	end
	
	local data = { ["CharID"]=Conn.m_Player.m_uID, ["OrderID"]=uOrderId }
	
	local function CallBack(suc, result, errorMsg)
		if 	suc then
			Gas2Gac:RetCSMCancelOrderSucc(Conn, Panel.CharSellOrder, suc)
		else
			local errorMsgId = result
			if IsNumber(errorMsgId) then
				if errorMsg ~= nil then
					MsgToConn(Conn, errorMsgId,errorMsg)
				else
				    if errorMsgId == 1 then
				        errorMsgId = 8034
				    end
					MsgToConn(Conn, errorMsgId)
				end
                Gas2Gac:RetCSMCancelOrderSucc(Conn, Panel.CharSellOrder, true)
			end
		end
		
	end
	
	--local entry = (g_DBTransDef["ConsignmentDB"])
	CallAccountManualTrans(Conn.m_Account, ConsignmentDB, "CSMCancelSellOrder", CallBack, data, "Consignment")
end

--��ȡ��Ʒ
function Gac2Gas:CSMTakeAttachment(Conn, order_id)
	--�ж��Ƿ��ڶ�Ӧ��npc�Ա�
	if not DistanceJudgeBetweenNpcAndPlayer(Conn,"���۽�����")	then
	    Gas2Gac:RetCloseCSMWnd(Conn)
		return
	end
	
	local function CallBack(suc, result, errorMsg)
		if suc then
			--, "��Ʒ��ȡ�ɹ�"
			MsgToConn(Conn, 8011)
		else
			local errorMsgId = result
			if IsNumber(errorMsgId) then
				if errorMsg ~= nil then
					MsgToConn(Conn, errorMsgId, errorMsg)
				else
					MsgToConn(Conn, errorMsgId)
				end
			end
		end
		Gas2Gac:RetCSMTakeAttachmentError(Conn, suc)
	end
	
	local data = {["CharID"]=Conn.m_Player.m_uID, ["OrderID"]=order_id}
	--local entry = (g_DBTransDef["ConsignmentDB"])
	CallAccountManualTrans(Conn.m_Account, ConsignmentDB, "CSMTakeAttachment", CallBack, data)
end

--���򶩵�
--1��ʾ����ɹ���
--2��ʾmoeny����
--3��ʾ��Ʒ�Ѿ��۳�
function Gac2Gas:CSMBuyOrder(Conn, uOrderId)
	--�ж��Ƿ��ڶ�Ӧ��npc�Ա�
	if not DistanceJudgeBetweenNpcAndPlayer(Conn,"���۽�����")	then
	    Gas2Gac:RetCloseCSMWnd(Conn)
		return
	end
	
    if Conn.m_Player.m_ItemBagLock then
        MsgClient(160047)
        return
    end
	
	if Conn.m_Player.m_ItemBagLock then
		MsgToConn(Conn,160018)
		return 
	end
	
	local data = {["CharID"] =Conn.m_Player.m_uID, ["OrderID"]=uOrderId }
	local function CallBack(suc, result, errorType)
		if suc then
			local playerID = result["PlayerID"]
			local costMoney = result["CostMoney"]
			Gas2Gac:RetCSMBuyOrderError(Conn, 1)   			 --����ɹ�
		else
			MsgToConn(Conn, result)
			Gas2Gac:RetCSMBuyOrderError(Conn, errorType)     --�ж���Ʒ�Ƿ��۳�
		end
		if suc == nil then 
			Gas2Gac:RetCSMBuyOrderError(Conn, 1)   			 --�ö����Ѿ������ڣ����߿ͻ�����ˢ�����
		end
	end	

	--local entry = (g_DBTransDef["ConsignmentDB"])
	CallAccountManualTrans(Conn.m_Account, ConsignmentDB, "CSMBuyOrder", CallBack, data,  "Consignment")
end

--����������ס�ļ۸�
function Gac2Gas:GetCSMRememberPrice(Conn, pannelNo, itemType, itemName)
	--�ж��Ƿ��ڶ�Ӧ��npc�Ա�
	if not DistanceJudgeBetweenNpcAndPlayer(Conn,"���۽�����")	then
	    Gas2Gac:RetCloseCSMWnd(Conn)
		return
	end
	
	local data = {["CharId"]=Conn.m_Player.m_uID, ["PannelNo"]=pannelNo, 
					["ItemType"]=itemType, ["ItemName"]= itemName}
	local function CallBack(suc, result, errorMsgId)
		if suc then
			local price = result
			Gas2Gac:RetGetCSMRememberPrice(Conn, pannelNo, price)
		end
	end
	
	--local entry = (g_DBTransDef["ConsignmentDB"])
	CallAccountManualTrans(Conn.m_Account, ConsignmentDB, "GetCSMRememberPrice", CallBack, data)
end

--------------------------------------������οؼ���������-----------------------------------------------------

local function CSMGetOrderByItemType(Conn, pannelNo, result, flag, charID)
	local count = result["Count"]
	local ret = result["Ret"]
	local itemInfoTbl = result["ItemInfoTbl"]
	local orderItemIDTbl = result["OrderItemIDTbl"]
	Gas2Gac:RetCSMTotalNo(Conn, pannelNo, count)
	local retLen = ret:GetRowNum()
    local retOrderCount = 50
    if retLen < 50 then
       retOrderCount = retLen 
    end
	for i = 1, retOrderCount do
		local nItemID

		if pannelNo == Panel.SellOrder then
            nItemID = orderItemIDTbl[i]
		elseif pannelNo == Panel.BuyOrder then
			nItemID = ret[i][8]
		end
		if nItemID ~= 0 then
    		local nBigID, nIndex = ret(i,3), ret(i,4) 
    		if pannelNo == Panel.SellOrder then
    			if flag == 2 then
    				Gas2Gac:RetCSMOrderList(Conn, pannelNo, ret(i,1),ret(i,2),ret(i,3),ret(i,9) .. "*" .. ret(i,4),ret(i,5),ret(i,6),ret(i,7),orderItemIDTbl[i])
    			else
    				Gas2Gac:RetCSMOrderList(Conn, pannelNo,  ret(i,1),ret(i,2),ret(i,3),ret(i,4),ret(i,5),ret(i,6),ret(i,7),orderItemIDTbl[i])
    			end
    		elseif pannelNo == Panel.BuyOrder then
    			if flag == 2 then
    				Gas2Gac:RetCSMOrderList(Conn, pannelNo, ret(i,1),ret(i,2),ret(i,3),ret(i,9) .. "*" .. ret(i,4),ret(i,5),ret(i,6),ret(i,7),orderItemIDTbl[i])
    			else
    				Gas2Gac:RetCSMOrderList(Conn, pannelNo, ret(i,1),ret(i,2),ret(i,3),ret(i,4),ret(i,5),ret(i,6),ret(i,7),orderItemIDTbl[i])
    			end
    		end
        end
	end
	Gas2Gac:RetCSMOrderListEnd(Conn, pannelNo)
end
	
--�����Ʒ��������order
function Gac2Gas:CSMGetOrderByItemType(Conn, pannelNo, uType, sName, uBeginLevel, uEndLevel, OrderBy, Page,flag,advanceSoul,maxAdvancePhase,intenSoul, maxIntenPhase,  quality, campFlag)
	--�ж��Ƿ��ڶ�Ӧ��npc�Ա�
	if not DistanceJudgeBetweenNpcAndPlayer(Conn,"���۽�����")	then
	    Gas2Gac:RetCloseCSMWnd(Conn)
		return
	end
	
	local charID = Conn.m_Player.m_uID
	local data = {["CharID"] =charID, ["PannelNo"] =pannelNo, ["Type"]=uType, ["Name"]=sName,
					["BeginLevel"]=uBeginLevel, ["EndLevel"]=uEndLevel,
					["OrderBy"]=OrderBy, ["Page"]=Page,["flag"] = flag,["AdvanceSoul"] = advanceSoul,["MaxAdvancePhase"] = maxAdvancePhase,
					["IntenSoul"] = intenSoul, ["MaxIntenPhase"]=maxIntenPhase, ["Quality"] = quality, ["CampFlag"] = campFlag}
	local function CallBack(suc, result, errorMsg)
		if suc then
			CSMGetOrderByItemType(Conn, pannelNo, result, flag, charID)
		else
			local errorMsgId = result
			MsgToConn(Conn, errorMsgId, errorMsg )
		end
	end
	--local entry = (g_DBTransDef["ConsignmentDB"])
	CallAccountManualTrans(Conn.m_Account, ConsignmentDB, "CSMGetOrderByItemType", CallBack, data, "Consignment")
end


--��ѯĳ�����ͷ���ĳ���������е���Ʒ
function Gac2Gas:CSMGetOrderByItemAttr(Conn, pannelNo, uType, sParentAttrColName, sParentNodeText, sAttrColName,  sCurNodeText, sName, uBeginLevel, uEndLevel, OrderBy, Page,flag,advanceSoul,maxAdvancePhase, intenSoul, maxIntenPhase, quality, campFlag)
	--�ж��Ƿ��ڶ�Ӧ��npc�Ա�
	if not DistanceJudgeBetweenNpcAndPlayer(Conn,"���۽�����")	then
	    Gas2Gac:RetCloseCSMWnd(Conn)
		return
	end
    local charID = Conn.m_Player.m_uID
	local data = {["CharID"] =charID, ["PannelNo"] =pannelNo, ["Type"]=uType, 
					["ParentAttrColName"]=sParentAttrColName, ["ParentNodeText"]=sParentNodeText, 
					["AttrColName"] = sAttrColName, ["CurNodeText"]=sCurNodeText, ["Name"]=sName,
					["BeginLevel"]=uBeginLevel, ["EndLevel"]=uEndLevel, 
					["OrderBy"]=OrderBy, ["Page"]=Page,["flag"] = flag,["AdvanceSoul"] = advanceSoul,["MaxAdvancePhase"] = maxAdvancePhase,
					["IntenSoul"] = intenSoul, ["MaxIntenPhase"] = maxIntenPhase, ["Quality"] = quality, ["CampFlag"] = campFlag}
	local function CallBack(suc, result, errorMsg)
		if suc then
			 CSMGetOrderByItemType(Conn, pannelNo, result, flag, charID)
		else
			local errorMsgId = result
			MsgToConn(Conn, errorMsgId, errorMsg )
		end
	end
	--local entry = (g_DBTransDef["ConsignmentDB"])
	CallAccountManualTrans(Conn.m_Account, ConsignmentDB, "CSMGetOrderByItemAttr", CallBack, data, "Consignment")
end

--��ѯ��ĳ���������е�һ����Ʒ
function Gac2Gas:CSMGetOrderBySomeItemType(Conn, pannelNo, uType, sName, uBeginLevel, uEndLevel, OrderBy, Page,flag,advanceSoul,maxAdvancePhase, intenSoul, maxIntenPhase, quality, campFlag)
	--�ж��Ƿ��ڶ�Ӧ��npc�Ա�
	if not DistanceJudgeBetweenNpcAndPlayer(Conn,"���۽�����")	then
	    Gas2Gac:RetCloseCSMWnd(Conn)
		return
	end
	
	local charID = Conn.m_Player.m_uID
	local data = {["CharID"] =charID, ["PannelNo"] =pannelNo, ["Type"]=uType, ["Name"]=sName,
					["BeginLevel"]=uBeginLevel, ["EndLevel"]=uEndLevel,
					["OrderBy"]=OrderBy, ["Page"]=Page,["flag"] = flag,["AdvanceSoul"] = advanceSoul,["MaxAdvancePhase"] = maxAdvancePhase,
					["IntenSoul"] = intenSoul, ["MaxIntenPhase"]=maxIntenPhase, ["Quality"] = quality, ["CampFlag"] = campFlag}
	local function CallBack(suc, result, errorMsg)
		if suc then
			CSMGetOrderByItemType(Conn, pannelNo, result, flag, charID)
		else
			local errorMsgId = result
			MsgToConn(Conn, errorMsgId, errorMsg )
		end
	end
	
	--local entry = (g_DBTransDef["ConsignmentDB"])
	CallAccountManualTrans(Conn.m_Account, ConsignmentDB, "CSMGetOrderBySomeItemType", CallBack, data, "Consignment")
end

--��ѯ��ĳ����Ʒ�з���ĳ��������Ҫ�����Ʒ(���ñ��е�ĳ��������)
function Gac2Gas:CSMGetOrderByExactItemAttr(Conn, pannelNo, uType, sAttrIndex, sName, uBeginLevel, uEndLevel, OrderBy, Page,flag,advanceSoul,maxAdvancePhase, intenSoul, maxIntenPhase, quality, campFlag)
	--�ж��Ƿ��ڶ�Ӧ��npc�Ա�
	if not DistanceJudgeBetweenNpcAndPlayer(Conn,"���۽�����")	then
	    Gas2Gac:RetCloseCSMWnd(Conn)
		return
	end
    local charID = Conn.m_Player.m_uID
	
	local function CallBack(suc, result, errorMsg)
		if suc then
			CSMGetOrderByItemType(Conn, pannelNo, result, flag, charID)
		else
			local errorMsgId = result
			MsgToConn(Conn, errorMsgId, errorMsg )
		end
	end
	local data = {["CharID"] =charID, ["PannelNo"] =pannelNo, ["Type"]=uType,
					["AttrIndex"]=sAttrIndex, ["Name"]=sName,
					["BeginLevel"]=uBeginLevel, ["EndLevel"]=uEndLevel, 
					["OrderBy"]=OrderBy, ["Page"]=Page,["flag"] = flag,["AdvanceSoul"] = advanceSoul,["MaxAdvancePhase"] = maxAdvancePhase,
					["IntenSoul"] = intenSoul, ["MaxIntenPhase"]=maxIntenPhase, ["Quality"] =quality, ["CampFlag"] =campFlag}
					
	--local entry = (g_DBTransDef["ConsignmentDB"])
	CallAccountManualTrans(Conn.m_Account, ConsignmentDB, "CSMGetOrderByExactItemAttr", CallBack, data, "Consignment")
end


function Gac2Gas:OpenCSMWnd(Conn)
    if not IsCppBound(Conn.m_Player) then
       return 
    end
   	--�����Ʒʹ�ö���
	if Conn.m_Player.m_UseItemLoadingTick then
		StopItemProgressTick(Conn.m_Player)
	end 
	
	if Conn.m_Player.m_CommLoadProTick then
		CommStopLoadProgress(Conn.m_Player, EProgressBreak.ePB_OpenCSM)
	end
end

function Gac2Gas:CSMGetOrderBySeveralSortItem(Conn, PannelOrder, itemTypeTblIndex, attrTblIndex, sName, uBeginLevel, uEndLevel, OrderBy, Page,flag,advanceSoul,maxAdvancePhase, intenSoul, maxIntenPhase, quality, campFlag)
    --�ж��Ƿ��ڶ�Ӧ��npc�Ա�
	if not DistanceJudgeBetweenNpcAndPlayer(Conn,"���۽�����")	then
	    Gas2Gac:RetCloseCSMWnd(Conn)
		return
	end
	local charID = Conn.m_Player.m_uID
    local function CallBack(suc, result, errorMsg)
		if suc then
			CSMGetOrderByItemType(Conn, PannelOrder, result, flag, charID)
		else
			local errorMsgId = result
			MsgToConn(Conn, errorMsgId, errorMsg )
		end
	end
	
    local data = {["CharID"] =charID, ["PannelNo"] =PannelOrder, ["ItemTypeTblIndex"]=itemTypeTblIndex,
					["AttrTblIndex"]=attrTblIndex,["Name"]=sName,
					["BeginLevel"]=uBeginLevel, ["EndLevel"]=uEndLevel,
					["OrderBy"]=OrderBy, ["Page"]=Page,["flag"] = flag,["AdvanceSoul"] = advanceSoul,["MaxAdvancePhase"] = maxAdvancePhase,
					["IntenSoul"] = intenSoul, ["MaxIntenPhase"]=maxIntenPhase, ["Quality"] = quality, ["CampFlag"] = campFlag}
    CallAccountManualTrans(Conn.m_Account, ConsignmentDB, "CSMGetOrderBySeveralSortItem", CallBack, data, "Consignment")        
end
