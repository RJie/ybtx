gac_require "relation/cofc/CofCStockKMapInc"

function Gas2Gac:RetGetCofCStockKMapBegin(Conn)
	g_GameMain.m_CofCStockKMapWnd.m_CofCStockKMapInfoTbl	=	{}
end

--��Ʊ���׼�¼��Ϣ������ʱ�䡢�������������ۼ��ܶ�
function Gas2Gac:RetGetCofCStockKMap(Conn, tradeTime, tradeCount, tradeMoney)
	local node		=	{}
	node.TradeTime	=	tradeTime -- ���ֶ�����Ϊ unix_timestamp
	node.TradeCount	=	tradeCount
	node.TradeMoney	=	tradeMoney
	if tradeMoney ~= 0 then
		node.TradePrice =	tradeMoney/tradeCount
	else
		node.TradePrice	=	0
	end
	
	table.insert(g_GameMain.m_CofCStockKMapWnd.m_CofCStockKMapInfoTbl,node)
end

--��Ʊ����k��ͼ���ִ������ݽ������ڿͻ�����ʾk��ͼ
function Gas2Gac:RetGetCofCStockKMapEnd(Conn, time_begin, time_end)
	g_GameMain.m_CofCStockKMapWnd:ShowCofCStockKMap(time_begin, time_end) 
end

----------------------------------------------RPC-----------------------------------------

--�����̻��ƱK��ͼ����
function CreateCofCStockKMapWnd(Parent)
	local wnd	=	CCofCStockKMapWnd:new()
	wnd:CreateFromRes("CofCKeyMap",Parent)
	wnd:ShowWnd( true )
	g_ExcludeWndMgr:InitExcludeWnd(wnd, 1)
	wnd:InitKMapInterval()
	wnd:InitCofCStockKMapChild()
	
	return wnd	
end	

--�ó�Ա���������̻��Ʊk��ͼ�����еĿؼ�
function CCofCStockKMapWnd:InitCofCStockKMapChild()
	self.m_Close			=	self:GetDlgChild("Close")
	self.m_KMap				=	self:GetDlgChild("KMap")
	self.m_DayBtn			=	self:GetDlgChild("DayBtn")
	self.m_WeekBtn			=	self:GetDlgChild("WeekBtn")
	self.m_MonthBtn			=	self:GetDlgChild("MonthBtn")
	
	local spanX = 20
	
	self.m_GraphicRectItem	=	      ClassCast(CChartHistogram, self.m_KMap:AppendGraphicItem(1))
	self.m_GraphicLineItem	= 	      ClassCast(CChartLineGraph, self.m_KMap:AppendGraphicItem(0))
end

--��ʼ���̻��Ʊk��ͼ��ʱ�����ʹ�������˵Ĳ鿴k��ͼ��ʱ�䷶Χ
function CCofCStockKMapWnd:InitKMapInterval()
	self.m_DayTimePeriod		=	-24*60				--��ʱ���
	self.m_WeekTimePeriod		=	-7*24*60			--��ʱ���
	self.m_MonthTimePeriod		=	-30*24*60			--��ʱ���
	self.m_DayTimeInterval		=	15					--��ʱ��̶�
	self.m_WeekTimeInterval		=	2*60				--��ʱ��̶�
	self.m_MonthTimeInterval	=	8*60				--��ʱ��̶�
	self.m_CurKMapType			=	1
end

--�̻��Ʊk��ͼ�����¼���Ӧ����
function CCofCStockKMapWnd:OnCtrlmsg( Child, uMsgID, uParam1, uParam2 )
	if (uMsgID == BUTTON_LCLICK) then
		if Child == self.m_Close then
			self:ShowWnd(false)
			g_GameMain.m_CofCStockOrderListWnd:ShowWnd(false)
		
		elseif Child == self.m_DayBtn then
			self.m_CurKMapType	=	1
			self:GetCofCStockKMapInfo()
		
		elseif Child == self.m_WeekBtn then
			self.m_CurKMapType	=	2
			self:GetCofCStockKMapInfo()
			
		elseif Child == self.m_MonthBtn then
			self.m_CurKMapType	=	3
			self:GetCofCStockKMapInfo()
		end	
	end
end

--����̻��Ʊk��ͼ����ͼ������ͼ������ͼ
function CCofCStockKMapWnd:GetCofCStockKMapInfo()
	if self.m_CurKMapType == 1 then						--�鿴����ͼ��Ϣ
		Gac2Gas:GetCofCStockKMap(g_Conn, g_GameMain.m_CofCStockOrderListWnd.m_CurStockId, self.m_DayTimePeriod, self.m_DayTimeInterval)
	
	elseif self.m_CurKMapType == 2 then					--�鿴����ͼ��Ϣ
		Gac2Gas:GetCofCStockKMap(g_Conn, g_GameMain.m_CofCStockOrderListWnd.m_CurStockId, self.m_WeekTimePeriod, self.m_WeekTimeInterval)

	elseif self.m_CurKMapType == 3 then					--�鿴����ͼ��Ϣ
		Gac2Gas:GetCofCStockKMap(g_Conn, g_GameMain.m_CofCStockOrderListWnd.m_CurStockId, self.m_MonthTimePeriod, self.m_MonthTimeInterval)
	end
end
--- @brief ��ȫ�����еĿյ�
function CCofCStockKMapWnd:InsertEmptyPoint(time_begin, time_end)
	local data = self.m_CofCStockKMapInfoTbl
	if #data > 0 then
		local delta = self:GetCofCStockKMapTimeDelta() * 60
		-- �м��ȱ������
		local nextTime = data[1].TradeTime
		local i = 1
		while true do
			if i > #data then
				break
			end
			local thisTime = data[i].TradeTime
			local j = i
			while nextTime < thisTime do
				table.insert(data, j, {TradeTime = nextTime, TradeCount = 0, TradeMoney = 0, TradePrice = 0})
				nextTime = nextTime + delta
				j = j + 1
			end
			nextTime = thisTime + delta
			i = i + 1
		end
		-- ���ȱʧ������
		if data[1].TradeTime > time_begin then
			table.insert(data, 1, {TradeTime = time_begin, TradeCount = 0, TradeMoney = 0, TradePrice = 0})
		end
		i = 1
		while data[i].TradeTime + delta < data[i + 1].TradeTime do
			table.insert(data, i + 1, {TradeTime = data[i].TradeTime + delta, TradeCount = 0, TradeMoney = 0, TradePrice = 0})
			i = i + 1
		end
		-- �յ�ȱʧ������
		while data[#data].TradeTime < time_end do
			table.insert(data, {TradeTime = data[#data].TradeTime + delta, TradeCount = 0, TradeMoney = 0, TradePrice = 0})
		end
	end
end

-- @brief ��ͼ��0ֵ���Բ�ֵ
function CCofCStockKMapWnd:LineGraphInterpolation()
	local data = self.m_CofCStockKMapInfoTbl
	
	-- ǰ׺0�����
	local i = 1
	while i <= #data do
		if data[i].TradePrice ~= 0 then
			for j = 1, i - 1 do
				data[j].TradePrice = data[i].TradePrice
			end
			break
		else
			i = i + 1
		end
	end
	-- �м�0�����Բ�ֵ
	local nonZeroIndex = nil
	while i <= #data do
		if data[i].TradePrice ~= 0 then
			if nonZeroIndex ~= nil and i - nonZeroIndex > 1 then
				local d = (data[i].TradePrice - data[nonZeroIndex].TradePrice) / (i - nonZeroIndex)
				for j = nonZeroIndex + 1, i - 1 do
					data[j].TradePrice = data[nonZeroIndex].TradePrice + (j - nonZeroIndex) * d
				end
			end
			nonZeroIndex = i
		end
		i = i + 1
	end
	-- ��׺0������
	if nonZeroIndex ~= nil then
		i = nonZeroIndex + 1
		while i <= #data do
			data[i].TradePrice = data[nonZeroIndex].TradePrice
			i = i + 1
		end
	end
end

--�ڿͻ�����ʾk��ͼ���ߺ���״ͼ
function CCofCStockKMapWnd:ShowCofCStockKMap(time_begin, time_end)
	local kMapInfoTbl		=	self.m_CofCStockKMapInfoTbl
	local kMapInfoTblLen	=	# kMapInfoTbl
	local timeSpan = self:GetCofCStockKMapTimeDelta() * 60
	
	
	-- �����ʷ����
	self.m_GraphicRectItem:Clear()
	self.m_GraphicLineItem:Clear()
	
	if kMapInfoTblLen > 0 then
		self.m_GraphicLineItem:SetColor(0xffff0000)
		-- ��ȱ��Ĳ���
		self:InsertEmptyPoint(time_begin, time_end)
		
		-- ��ͼ��0ֵ���Բ�ֵ
		self:LineGraphInterpolation()
		
		-- ���Ե������ű����ļ�����
		local line_min = 0
		local line_max = 0
		local rect_min = 0
		local rect_max = 0

		local color = nil
		
		for	i=1, # self.m_CofCStockKMapInfoTbl	do
			if i % 2 ==	0 then
				color =	0xff00ff00
			else
				color =	0xffffff00
			end
			
			-- ��״ͼ���ݲ���
			self.m_GraphicRectItem:AppendData(kMapInfoTbl[i].TradeCount, color)		--������״ͼ����
			if kMapInfoTbl[i].TradeCount > rect_max	then rect_max =	kMapInfoTbl[i].TradeCount end
			if kMapInfoTbl[i].TradeCount < rect_min	then rect_min =	kMapInfoTbl[i].TradeCount end
			
			-- ��ͼ���ݵĲ���
			self.m_GraphicLineItem:AppendData(kMapInfoTbl[i].TradePrice)
			if kMapInfoTbl[i].TradePrice > line_max	then line_max =	kMapInfoTbl[i].TradePrice end
			if kMapInfoTbl[i].TradePrice < line_min	then line_min =	kMapInfoTbl[i].TradePrice end
		end
		
		-- ����k��ͼ�����ű���
		if rect_max - rect_min == 0 then
			self.m_GraphicRectItem:SetZoomY(1)
		else
			self.m_GraphicRectItem:SetZoomY(self.m_KMap:GetWndHeight() * 0.8 / (rect_max - rect_min))
		end
		if line_max - line_min == 0 then
			self.m_GraphicLineItem:SetZoomY(1)
		else
			self.m_GraphicLineItem:SetZoomY(self.m_KMap:GetWndHeight() * 0.8 / (line_max - line_min))
		end
		self.m_GraphicLineItem:SetDeltaY(self.m_KMap:GetWndHeight() * 0.1)
		-- ����k��ͼˮƽ���
		local spanX = self.m_KMap:GetWndWidth() / #self.m_CofCStockKMapInfoTbl
		self.m_GraphicRectItem:SetSpanX(spanX)
		self.m_GraphicRectItem:SetItemWidth(self.m_GraphicRectItem:GetSpanX() - 1)
		self.m_GraphicLineItem:SetSpanX(spanX)
		self.m_GraphicLineItem:SetDeltaX(spanX / 2)
	end
end

--����k��ͼ�����ͣ�����ͼ����ʱ���Ϊ15���ӣ�����ͼ����ʱ���Ϊ2*60���ӣ�����ͼ���ص�ʱ���Ϊ8*60����
function CCofCStockKMapWnd:GetCofCStockKMapTimeDelta()
	if self.m_CurKMapType == 1 then						--�õ�����ͼʱ���
		return 15
	
	elseif self.m_CurKMapType == 2 then					--�õ�����ͼʱ���
		return 2*60

	elseif self.m_CurKMapType == 3 then					--�õ�����ͼʱ���
		return 8*60
	end
end
