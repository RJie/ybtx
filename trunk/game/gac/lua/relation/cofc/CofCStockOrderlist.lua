gac_require "relation/cofc/CofCStockOrderlistInc"
gac_require "relation/cofc/CofCStockMyDealing"
gac_require "relation/cofc/CofCStockFinancial"
gac_require "relation/cofc/CofCStockKMap"

--���عҵ��ɹ��Ļ�������ˢ���ҵĽ����б����ҹر�orderlist����
function Gas2Gac:RetDeleteOrder(Conn, suc)
	if suc then
		Gac2Gas:GetCofCStockMyDealingInfo(g_Conn)
		g_GameMain.m_CofCStockOrderListWnd:ShowWnd(false)
	end
end

--����ĳ֧��Ʊ����ϸ��Ϣ,
function Gas2Gac:RetGetCofCStockOrderListBegin(Conn, stockId)
	g_GameMain.m_CofCStockOrderListWnd.m_SellOrderlistTbl	=	{}			--��¼������Ǯ�͹����ı�
	g_GameMain.m_CofCStockOrderListWnd.m_BuyOrderlistTbl	=	{}			--��¼�򵥼�Ǯ�͹����ı�
	g_GameMain.m_CofCStockOrderListWnd.m_CurStockId			=	stockId		--��¼��ǰ��ʾ�Ĺ�Ʊid
end

--�õ���Ʊ�Ķ����б����������ͣ�0Ϊ�򵥣�1Ϊ�������������š��۸�����
function Gas2Gac:RetGetCofCStockOrderList(Conn, type, orderlistId, price, count)
	local node			=	{}
	node.OrderlistId	=	orderlistId
	node.Price			=	price
	node.Count			=	count
	
	if type == 0 then	
		table.insert(g_GameMain.m_CofCStockOrderListWnd.m_BuyOrderlistTbl,node)
	elseif type == 1 then
		table.insert(g_GameMain.m_CofCStockOrderListWnd.m_SellOrderlistTbl,node)
	end
end

--�����ݽ�������ʼ��ʾ�ڿͻ���
function Gas2Gac:RetGetCofCStockOrderListEnd(Conn, totalBuyCount, totalSellCount)
	local wnd = g_GameMain.m_CofCStockOrderListWnd
	wnd.m_TotalBuyCount = totalBuyCount
	wnd.m_TotalSellCount = totalSellCount
	wnd:ShowStockOrderlistWnd(totalBuyCount, totalSellCount)

	if wnd.UpdateCofCStockMyDealingInfoCallBack ~= nil then
		wnd:UpdateCofCStockMyDealingInfoCallBack()
	end
end

---------------------------------------��Ʊ��ϸ��Ϣ��ʾ������ش���-----------------------------------------------------
--������Ʊ��ϸ��Ϣ��ʾ����
function CreateStockOrderlistWnd(Parent)
	local wnd = CStockOrderlistWnd:new()
	wnd:CreateFromRes("CofCStockDetails",Parent)
	wnd:ShowWnd( true )
	g_ExcludeWndMgr:InitExcludeWnd(wnd, 3, false, {g_GameMain.m_CofCMainStockWnd})
	wnd:InitCofCStockMainDetailChild()
	
	return wnd
end

--��ʼ����Ʊ��ϸ��Ϣ�����е��ӿؼ�
function CStockOrderlistWnd:InitCofCStockMainDetailChild()
	self.m_StockNoAndName	=	self:GetDlgChild("NoName")			--��ʾ��Ʊ���ƺͱ��
	self.m_LastStock		=	self:GetDlgChild("LastStock")		--Ҫ����ʾ��һֻ��Ʊ��ϸ��Ϣ�İ�ť
	self.m_NextStock		=	self:GetDlgChild("NextStock")		--Ҫ����ʾ��һֻ��Ʊ��ϸ��Ϣ�İ�ť
	self.m_SellCount		=	self:GetDlgChild("Sell")			--��ʾ�����ܹ���
	self.m_BuyCount			=	self:GetDlgChild("Buy")				--��ʾ���ܹ���
	self.m_BuyThisStock		=	self:GetDlgChild("BuyThisStock")	--��������֧��Ʊ
	self.m_SellThisStock	=	self:GetDlgChild("SellThisStock")	--������۴�֧��Ʊ
	self.m_CheckKMap		=	self:GetDlgChild("KMap")			--����鿴k��ͼ
	self.m_FianacialInfo	=	self:GetDlgChild("FianacialInfo")	--����鿴��ʷ�Ʊ�
	--self.m_CancelOrder		=	self:GetDlgChild("CancelOrder")		--���ȡ��������ť
end

--��Ʊ��ϸ��Ϣ�����¼���Ӧ����
function CStockOrderlistWnd:OnCtrlmsg( Child, uMsgID, uParam1, uParam2 )
	if (uMsgID == BUTTON_LCLICK) then
	  	if(Child == self.m_LastStock) then 						--Ҫ��鿴��һ֧��Ʊ����Ϣ
	  		self:GetLastStockInfo()
	  	
	  	elseif(Child == self.m_NextStock)    then 				--Ҫ��鿴��һ֧��Ʊ����Ϣ							
			self:GetNextStockInfo()
	  			
	  	elseif(Child == self.m_BuyThisStock)      then			--����ѡ�еĹ�Ʊ															
			self:BuyCurShowStock()
	  	
	  	elseif(Child == self.m_SellThisStock)       then		--����ѡ�еĹ�Ʊ							
			self:SellCurShowStock()	
		
		elseif(Child == self.m_CheckKMap)       then 			--�鿴k��ͼ
			self:CheckKMapChart()
			
		elseif(Child == self.m_FianacialInfo)       then 		--�鿴��ʷ�Ʊ�	
			self:CheckFinancialInfo()
			
		--[[
		elseif(Child == self.m_CancelOrder)       then 			--ȡ��ĳ֧��Ʊ
			for i =1 ,# self.m_BuyOrderlistTbl do
				if self.m_BuyOrderlistTbl[i].OrderlistId == self.m_CurStockId then
					table.remove(self.m_BuyOrderlistTbl, i)
					break
				end
			end
			Gac2Gas:CofcStockDeleteOrder(g_Conn, self.m_CurStockId)
		--]]
		end
	end
end

--���ӷ���˵õ��Ĺ�Ʊ��Ϣ��ʾ�ڹ�Ʊ��ϸ��Ϣ������
function CStockOrderlistWnd:ShowStockOrderlistWnd(totalBuyCount, totalSellCount)
	self = g_GameMain.m_CofCStockOrderListWnd
	local buyTbl  = self.m_BuyOrderlistTbl
	local buyTblLen  = # buyTbl
	local sellTbl = self.m_SellOrderlistTbl
	local sellTblLen = # sellTbl
	
	if self.m_CurStockId == g_GameMain.m_CofCMainStockWnd.m_FirstStockId then		--����Ѿ��ǵ�һ֧��Ʊ�ˣ���"��һ֧"�İ�ť���ɵ�
		self.m_LastStock:EnableWnd(false)
	else 
		self.m_LastStock:EnableWnd(true)
	end

	if self.m_CurStockId == g_GameMain.m_CofCMainStockWnd.m_LastStockId then		--����Ѿ������һ֧��Ʊ�ˣ���"��һ֧"�İ�ť���ɵ�
		self.m_NextStock:EnableWnd(false)
	else 
		self.m_NextStock:EnableWnd(true)
	end
	
	self.m_SellCount:SetWndText("����(��" .. totalSellCount .. "��)")
	self.m_BuyCount:SetWndText("��(��" .. totalBuyCount .. "��)")
	
	--��ʾ����������Ϣ,����5�������Ľ���ʾ�ҵ���Ϣ��button�ؼ�����ʾ
	for i =1, buyTblLen do
		local buyStr = "Buy" .. i
		self:GetDlgChild(buyStr):ShowWnd(true)
		self:GetDlgChild(buyStr):SetWndText(buyTbl[i].Price .. "/" .. buyTbl[i].Count .. "��"  )
	end	
	for i = buyTblLen +1 , 5 do
		local buyStr = "Buy" .. i
		self:GetDlgChild(buyStr):ShowWnd(false)
	end
	
	--��ʾ��������Ϣ������5���򵥵Ľ���ʾ�ҵ���Ϣ��button�ؼ�����ʾ
	for i = 1, sellTblLen do
		local sellStr = "Sell" .. i
		self:GetDlgChild(sellStr):ShowWnd(true) 
		self:GetDlgChild(sellStr):SetWndText(sellTbl[i].Price .. "/" .. sellTbl[i].Count .. "��"  )
	end
	for i = sellTblLen +1 , 5 do
		local sellStr = "Sell" .. i
		self:GetDlgChild(sellStr):ShowWnd(false)
	end
end

--����һ֧����ť�����У��������еĶ���id���ظ�CofCStockMain.lua�еĺ���GetStockIndexById��
--����ɸѡ��Ϣ��������Ҫ����֧��Ʊid��������ˣ�
--��������ǰ��Ʊ��id�������ж����¹�Ʊ����Ϣ
function CStockOrderlistWnd:GetLastStockInfo()
	g_GameMain.m_CofCMainStockWnd:GetStockIndexById(self.m_CurStockId, 0)
end

--����һ֧����ť�����У��������еĶ���id���ظ�CofCStockMain.lua�еĺ���GetStockIndexById��
--����ɸѡ��Ϣ��������Ҫ����֧��Ʊid��������ˣ�
--��������ǰ��Ʊ��id�������ж����¹�Ʊ����Ϣ
function CStockOrderlistWnd:GetNextStockInfo()
	g_GameMain.m_CofCMainStockWnd:GetStockIndexById(self.m_CurStockId, 1)
end

--�鿴��ʷ�Ʊ�����
function CStockOrderlistWnd:CheckFinancialInfo()
	if self.m_FianacialInfo:GetWndText() == "K��ͼ" then
		self:CofcOrderlistFinancialBtnClicked()
	elseif self.m_FianacialInfo:GetWndText() == "��ʷ�Ʊ�" then
		local financialCurWeek = 0
		Gac2Gas:GetCofCFinancialReport(g_Conn,self.m_CurStockId, financialCurWeek)
	end		
end

function CStockOrderlistWnd:GetWhichOrderChoosed()
	local choosedItem = nil 
	choosedItem = g_GameMain.m_CofCMainStockWnd.m_StockList:GetSelectItem( -1 ) + 1
  
	if choosedItem == 0 then
		return nil
	end
	
	local choosedStockNo = g_GameMain.m_CofCMainStockWnd.m_MyDealingInfoTbl[choosedItem].ID		--�ҵ���ˮ��
	return choosedStockNo
end
--���������ùɡ���ť������ҵĽ��״��ڲ������򴴽���������ʾ�ҵĽ��״���
function CStockOrderlistWnd:BuyCurShowStock()
	
	--�Ƿ�ȡ���ҵ��Ļص�����
	local function callback(Context,Button)
		if(Button == MB_BtnOK) then		
			local mydealingId = self:GetWhichOrderChoosed()
			if mydealingId == nil then
				return
			end
			Gac2Gas:CofcStockDeleteOrder(g_Conn,mydealingId)
		end
		return true
	end
	if self.m_BuyThisStock:GetWndText() == "���عҵ�" then
		g_GameMain.m_CofCMainStockWnd:ShowWnd(true)
		self.m_MsgBox = MessageBox( self, MsgBoxMsg(16008), BitOr( MB_BtnOK, MB_BtnCancel),callback)
		return
	end
	self:MyDealingWndOrderlistBuy()
end

function CStockOrderlistWnd:MyDealingWndOrderlistBuy()
	if g_GameMain.m_CofCStockMyDealing == nil then
		g_GameMain.m_CofCStockMyDealing = CreateCofCMyDealingWnd(g_GameMain)
		table.insert( self.TblFatherWnd, g_GameMain.m_CofCStockMyDealing)
		g_GameMain.m_CofCStockMyDealing:ShowWnd(true)
	else 
		g_GameMain.m_CofCStockMyDealing:ShowWnd(true)
	end
	g_GameMain.m_CofCStockMyDealing.m_CurDealingType 	=	1 
	
	self:ShowExtraWndFalse(false)
	local price = ""
	local count = ""
	if # self.m_BuyOrderlistTbl ~= 0 then
		price = self.m_BuyOrderlistTbl[1].Price
		count = self.m_BuyOrderlistTbl[1].Count
	end												
	self:SetCofCMyDealingWndEvent()
	g_GameMain.m_CofCStockMyDealing:ShowCofCStockDealingInfo(self.m_TotalBuyCount,price,count)

end

--������۳��ùɡ���ť������ҵĽ��״��ڲ������򴴽���������ʾ�ҵĽ��״���
function CStockOrderlistWnd:SellCurShowStock()
	if self.m_SellThisStock:GetWndText() == "��������" then
		self:MyDealingWndOrderlistBuy()
		return
	end
	if g_GameMain.m_CofCStockMyDealing == nil then
		g_GameMain.m_CofCStockMyDealing = CreateCofCMyDealingWnd(g_GameMain)
		table.insert( self.TblFatherWnd, g_GameMain.m_CofCStockMyDealing)
		g_GameMain.m_CofCStockMyDealing:ShowWnd(true)
	else
		g_GameMain.m_CofCStockMyDealing:ShowWnd(true)
	end
	g_GameMain.m_CofCStockMyDealing.m_CurDealingType 	=	2
	self:ShowExtraWndFalse(false)
	local price = ""
	local count = ""
	if # self.m_SellOrderlistTbl ~= 0 then
		price = self.m_SellOrderlistTbl[1].Price
		count = self.m_SellOrderlistTbl[1].Count
	end
	self:SetCofCMyDealingWndEvent()
	g_GameMain.m_CofCStockMyDealing:ShowCofCStockDealingInfo(self.m_TotalSellCount,price,count)
end

--�ڴ��̹�Ʊ���ҵĹ�Ʊ���ҵĽ������֮���л�ʱ����Ʊ��Ϣorderlist�����е���һ֧����һ֧�ȴ��ڸ��ݴ����Ĳ���ѡ����ʾ����ʾ
function CStockOrderlistWnd:ShowExtraWndFalse(showOrNotShow)
	self.m_LastStock:ShowWnd(showOrNotShow)
	self.m_NextStock:ShowWnd(showOrNotShow)
	self.m_BuyThisStock:ShowWnd(showOrNotShow)
	self.m_SellThisStock:ShowWnd(showOrNotShow)
	self.m_CheckKMap:ShowWnd(showOrNotShow)
	self.m_FianacialInfo:ShowWnd(showOrNotShow)
end

--�����������־�ҵĽ��״����Ǵ򿪵ģ���ô�����¹�Ʊorderlist����ʱ��Ҳ�����ҵĽ��״����е���Ϣ
function CStockOrderlistWnd:SetCofCMyDealingWndEvent()
	if g_GameMain.m_CofCStockMyDealing.m_CurDealingType == 1 then
		UpdateCofCStockMyDealingInfoCallBack  = self.BuyCurShowStock
	elseif g_GameMain.m_CofCStockMyDealing.m_CurDealingType == 2 then
		UpdateCofCStockMyDealingInfoCallBack  = self.SellCurShowStock
	end
end

--����鿴k��ͼbutton���鿴k��ͼ����������򿪵Ľ�������ʷ�Ʊ����棬��Ӧ�򿪴��̽���
function CStockOrderlistWnd:CheckKMapChart()
	if self.m_CheckKMap:GetWndText() == "��������" then
		self.m_LastStock:ShowWnd(false)
		self.m_NextStock:ShowWnd(false)
		self:ShowWnd(false)
		g_GameMain.m_CofCMainStockWnd:ShowWnd(true)
		g_GameMain.m_CofCMainStockWnd.m_CurStockType = 1
		g_GameMain.m_CofCMainStockWnd:ShowAllStockInfo()
	elseif self.m_CheckKMap:GetWndText() == "K��ͼ" then
		self.m_CheckKMap:SetWndText("��������")
		self.m_FianacialInfo:SetWndText("��ʷ�Ʊ�")
		if g_GameMain.m_CofCStockKMapWnd == nil then
			g_GameMain.m_CofCStockKMapWnd = CreateCofCStockKMapWnd(g_GameMain)
			table.insert( self.TblFatherWnd, g_GameMain.m_CofCStockKMapWnd)
			g_GameMain.m_CofCStockKMapWnd:ShowWnd(true)
		elseif g_GameMain.m_CofCStockKMapWnd:IsShow() == false then
			g_GameMain.m_CofCStockKMapWnd:ShowWnd(true)
		end	
		Gac2Gas:GetCofCStockKMap(g_Conn,self.m_CurStockId,g_GameMain.m_CofCStockKMapWnd.m_DayTimePeriod,g_GameMain.m_CofCStockKMapWnd.m_DayTimeInterval)
	end
end

function CStockOrderlistWnd:CofcOrderlistFinancialBtnClicked()
	if g_GameMain.m_CofCStockKMapWnd == nil then
		g_GameMain.m_CofCStockKMapWnd = CreateCofCStockKMapWnd(g_GameMain)
		g_GameMain.m_CofCStockKMapWnd:ShowWnd(true)
	elseif g_GameMain.m_CofCStockKMapWnd:IsShow() == false then
		g_GameMain.m_CofCStockKMapWnd:ShowWnd(true)
	end	
	self.m_CheckKMap:SetWndText("��������")
	self.m_FianacialInfo:SetWndText("��ʷ�Ʊ�")
	Gac2Gas:GetCofCStockKMap(g_Conn,self.m_CurStockId,g_GameMain.m_CofCStockKMapWnd.m_DayTimePeriod,g_GameMain.m_CofCStockKMapWnd.m_DayTimeInterval)
end