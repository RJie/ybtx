
local PurchasingAgentDB = "PurchasingAgentDB"

local function CheckOrder(Conn, uCount, uPrice)
	if uCount <= 0 then
		--,"������Ʒ�������Ϸ�"
		MsgToConn(Conn,8004)
		return false
	end
	if uPrice <= 0 then
		--,"����۸񲻺Ϸ�"
		MsgToConn(Conn,8005)
		return  false
	end
	if uCount > 60000000000000000 then
		--,"������Ʒ��������"
		MsgToConn(Conn,8006)
		return  false
	end
	if uPrice > 60000000000000000 then
		--, "���ۼ۸����"
		MsgToConn(Conn, 8007)
		return false
	end
	return true
end

--����չ�����
function Gac2Gas:CSMAddBuyOrder(Conn, sItemName, uCount, uPrice, uTime)
	--�ж��Ƿ��ڶ�Ӧ��npc�Ա�
	if not DistanceJudgeBetweenNpcAndPlayer(Conn,"���۽�����")	then
	    Gas2Gac:RetCloseCSMWnd(Conn)
		return
	end
	
	local ret = CheckOrder(Conn, uCount, uPrice)
	if ret == false then
		Gas2Gac:RetAddMyPurchasing(Conn, false, 0)
		return	
	end
	local moneyObj = CMoney:new()
	local needFee = moneyObj:CalculateTotalFee(uPrice , uCount, 0.01, uTime/24)
	local function CallBack(suc, result, errorMsg)
		if not suc then	
			local errorMsgId	=	result
			MsgToConn(Conn, errorMsgId)
		end	
		Gas2Gac:RetAddMyPurchasing(Conn, suc, result)
	end
	local data = { 
					["CharID"]=Conn.m_Player.m_uID, 
					["ItemName"]=sItemName, 
					["ItemCount"]=uCount, 
					["ItemPrice"] =uPrice, 
					["Time"]=uTime, 
					["NeedFee"]=needFee }
    CallAccountManualTrans(Conn.m_Account, PurchasingAgentDB, "CSMAddBuyOrder", CallBack, data)
end

--ȡ���չ�����
function Gac2Gas:CSMCancelBuyOrder(Conn, uOrderId)
	--�ж��Ƿ��ڶ�Ӧ��npc�Ա�
	if not DistanceJudgeBetweenNpcAndPlayer(Conn,"���۽�����")	then
	    Gas2Gac:RetCloseCSMWnd(Conn)
		return
	end
	
	local function CallBack(suc, result)
		if suc == false then
			local errorMsgId = result
			MsgToConn(Conn,errorMsgId)
		end
		Gas2Gac:RetCancelMyPurchasing(Conn,suc, uOrderId)
	end
	local data = { ["CharID"]= Conn.m_Player.m_uID, ["OrderID"]=uOrderId }

	CallAccountManualTrans(Conn.m_Account, PurchasingAgentDB, "CSMCancelBuyOrder", CallBack, data)
end

--��ѯĳ����ҵ��չ�����
local function search_char_buy_order(Conn, result)
	for i = 1, #(result) do
		local buyorder = result[i]
		local uOrderId,sItemName, uPrice,uCount,uTime=buyorder["OrderId"], buyorder["ItemName"], buyorder["Price"], buyorder["Count"], buyorder["Time"]
		Gas2Gac:ReturnMyPurchasingInfo(Conn,uOrderId,sItemName, uPrice,uTime,uCount)
	end
end

function Gac2Gas:CSMSearchCharBuyOrder(Conn)
	--�ж��Ƿ��ڶ�Ӧ��npc�Ա�
	if not DistanceJudgeBetweenNpcAndPlayer(Conn,"���۽�����")	then
	    Gas2Gac:RetCloseCSMWnd(Conn)
		return
	end
	
	local data = { 
	["CharId"]=Conn.m_Player.m_uID} 
	local function CallBack(suc, result)
		Gas2Gac:ReturnMyPurchasingInfoBegin(Conn)
		if suc and result then
			search_char_buy_order(Conn, result)
		end
		Gas2Gac:ReturnMyPurchasingInfoEnd(Conn)
	end
	CallAccountManualTrans(Conn.m_Account, PurchasingAgentDB, "CSMSearchCharBuyOrder", CallBack, data)
end

local function search_buy_order(Conn, result)
	for i = 1, #(result) do
		local buyorder = result[i]
		local uOrderId,sItemName,uLevel,uPrice,uCount,uTime,sCharName=buyorder["OrderId"], buyorder["ItemName"],buyorder["Level"] ,buyorder["Price"], buyorder["Count"], buyorder["Time"],buyorder["CharName"]
		Gas2Gac:ReturnPurchasingInfo(Conn,uOrderId,sItemName,uLevel,uCount,uPrice,uTime,sCharName)
	end
end

--���orderlist�ϵĵȼ��Ȱ�ť����ѯ�չ�����
function Gac2Gas:CSMSearchBuyOrder(Conn,uSearchType,uParentArg, uChildArg ,sName, uBeginLevel, uEndLevel, uQuality, OrderBy, Page)
	--�ж��Ƿ��ڶ�Ӧ��npc�Ա�
	if not DistanceJudgeBetweenNpcAndPlayer(Conn,"���۽�����")	then
	    Gas2Gac:RetCloseCSMWnd(Conn)
		return
	end
	
	local data = {
		["SearchType"]=uSearchType, 
		["ParentArg"]=uParentArg,
		["ChildArg"]=uChildArg,
		["Name"]=sName,
		["BeginLevel"]=uBeginLevel, 
		["EndLevel"]=uEndLevel,
		["Quality"] = uQuality,
		["OrderBy"]=OrderBy, 
		["Page"]=Page}
	local function CallBack(suc, result)
		local count = 0
		Gas2Gac:ReturnPurchasingInfoBegin(Conn)
		if suc then
			count	= result["Count"]
			local ret	= result["Ret"]
			search_buy_order(Conn,ret)
		end
		Gas2Gac:ReturnPurchasingInfoEnd(Conn,count)
	end
	
	CallAccountManualTrans(Conn.m_Account, PurchasingAgentDB, "CSMSearchBuyOrder", CallBack, data)
end

--����������˵��չ���������Ʒ
function Gac2Gas:CSMSellGoods2Order(Conn, uOrderId, nRoomIndex, nPos)
	--�ж��Ƿ��ڶ�Ӧ��npc�Ա�
	if not DistanceJudgeBetweenNpcAndPlayer(Conn,"���۽�����")	then
	    Gas2Gac:RetCloseCSMWnd(Conn)
		return
	end
	
	local data = {
		["CharID"]=Conn.m_Player.m_uID, 
		["OrderID"]=uOrderId, 
		["RoomIndex"]=nRoomIndex,
		["Pos"]=nPos }
	
	local function CallBack(suc, result, errorMsg)
		if not suc then
			local errorMsgId = result 
			if IsNumber(errorMsgId) then
				if errorMsg ~= nil then
					MsgToConn(Conn, errorMsgId, errorMsg)
				else
					MsgToConn(Conn, errorMsgId)
				end
			end
		end
		Gas2Gac:ReturnSellGoods(Conn,suc)
	end
	CallAccountManualTrans(Conn.m_Account, PurchasingAgentDB, "CSMSellGoods2Order", CallBack, data)
end

local function search_buy_order_by_item(Conn, result)
	for i = 1, #(result) do
		local buyorder = result[i]
		local sItemName,uRoomIndex,uPos=buyorder["ItemName"],buyorder["RoomIndex"] ,buyorder["Pos"]
		Gas2Gac:ReturnFastSellItemInfo(Conn,sItemName,uRoomIndex,uPos)
	end
end

function Gac2Gas:CSMFastSearchBuyOrderItem(Conn)
	--�ж��Ƿ��ڶ�Ӧ��npc�Ա�
	if not DistanceJudgeBetweenNpcAndPlayer(Conn,"���۽�����")	then
	    Gas2Gac:RetCloseCSMWnd(Conn)
		return
	end
	
	local data = {
		["CharID"]=Conn.m_Player.m_uID}
	
	local function CallBack(suc, result)
		Gas2Gac:ReturnFastSellItemInfoBegin(Conn)
		if suc then
			search_buy_order_by_item(Conn,result)
		end
		Gas2Gac:ReturnFastSellItemInfoEnd(Conn)
	end
	CallAccountManualTrans(Conn.m_Account, PurchasingAgentDB, "CSMFastSearchBuyOrderItem", CallBack, data)
end

function Gac2Gas:CSMGetTopPriceBuyOrderByItemName(Conn,sItemName)
	--�ж��Ƿ��ڶ�Ӧ��npc�Ա�
	if not DistanceJudgeBetweenNpcAndPlayer(Conn,"���۽�����")	then
	    Gas2Gac:RetCloseCSMWnd(Conn)
		return
	end
	
	local data = {
	["CharID"]=Conn.m_Player.m_uID,
	["ItemName"]=sItemName}
	
	local function CallBack(suc, result, errorMsg)
		if suc then
			Gas2Gac:ReturnFastSellItemOrder(Conn,result["OrderId"],result["Count"],result["Price"])
		else
			local errorMsgId = result 
			if IsNumber(errorMsgId) then
				if errorMsg ~= nil then
					MsgToConn(Conn, errorMsgId, errorMsg)
				else
					MsgToConn(Conn, errorMsgId)
				end
			end
			Gas2Gac:ReturnFastSellItemOrderFail(Conn)
		end
	end
	CallAccountManualTrans(Conn.m_Account, PurchasingAgentDB, "CSMGetTopPriceBuyOrderByItemName", CallBack, data)
end

function Gac2Gas:CSMGetAveragePriceByItemName(Conn,sItemName)
	--�ж��Ƿ��ڶ�Ӧ��npc�Ա�
	if not DistanceJudgeBetweenNpcAndPlayer(Conn,"���۽�����")	then
	    Gas2Gac:RetCloseCSMWnd(Conn)
		return
	end
	
	local data = {
	["ItemName"]=sItemName}
	
	local function CallBack(uAverPrice,uCount)
		Gas2Gac:GetAveragePriceByItemName(Conn,uAverPrice,uCount)
	end
	CallAccountManualTrans(Conn.m_Account, PurchasingAgentDB, "CSMGetAveragePriceByItemName", CallBack, data)
end