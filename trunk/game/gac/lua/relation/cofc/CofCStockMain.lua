gac_require "relation/cofc/CofCStockMainInc"
gac_require "relation/cofc/CofCStockOrderlist"

--׼����ʼ����Ʊ��Ϣ����ʼ���������
function Gas2Gac:RetGetCofCStockInfoBegin(Conn)
	g_GameMain.m_CofCMainStockWnd.m_AllStockInfoTbl 	=	{}		--������¼���й�Ʊ��Ϣ�������еĹ�Ʊ��Ϣ����table
	g_GameMain.m_CofCMainStockWnd.m_MyStockInfoTbl		=	{}		--������¼��ִ�еĹ�Ʊ��Ϣ��table
	g_GameMain.m_CofCMainStockWnd.m_StockListWndTbl		=	{}		--�����洢��ʾ��Ʊ��Ϣ��listctrl�е�item
	g_GameMain.m_CofCMainStockWnd.m_CurStockType		=	1		--������ǰ��ʾ���Ǵ��̹�Ʊ��Ϣ��2�����Ǹ��˹�Ʊ��Ϣ,3�������ҵĽ�����Ϣ
	g_GameMain.m_CofCStockOrderListWnd:ShowWnd(false)
end

--��ʼ����Ʊ�����Ϣ,��������Ʊ���ţ����ƣ�ִ�������ɱ����Ƿ����������������ۣ���������͵ģ�������ۣ���������ߵģ�����߼ۣ���ͼ�
function Gas2Gac:RetGetCofCStockInfo(Conn, no, name, haveCount, costs, range, dealingCount, sellPrice, buyPrice, highestPrice, lowestPrice)
	local node			=	{}
	node.No				=	no
	node.Name			=	name
	node.HaveCount		=	haveCount
	node.Costs			=	costs
	node.Range			=	range
	node.DealingCount	=	dealingCount
	node.SellPrice		=	sellPrice
	node.BuyPrice		=	buyPrice
	node.HighestPrice	=	highestPrice
	node.LowestPrice	=	lowestPrice
	
	table.insert(g_GameMain.m_CofCMainStockWnd.m_AllStockInfoTbl, node)		
	
	if haveCount > 0 then				--�������������0���������Լ���Ʊ��������¼��һ�������������ʾ
		table.insert(g_GameMain.m_CofCMainStockWnd.m_MyStockInfoTbl, node)	
	end
end

--��Ʊ��Ϣ���������������ʾ�ڿͻ���
function Gas2Gac:RetGetCofCStockInfoEnd(Conn)
	g_GameMain.m_CofCMainStockWnd:ShowAllStockInfo()
	local AutoCloseWnd = CAutoCloseWnd:new()
	AutoCloseWnd:AutoCloseWnd(g_GameMain.m_CofCMainStockWnd)
end

--׼����ʼ���ҵĽ�������е������Ϣ����ʼ���������
function Gas2Gac:RetGetCofCStockMyDealingInfoBegin(Conn)
	g_GameMain.m_CofCMainStockWnd.m_MyDealingInfoTbl	=	{}			--��¼�ҵĽ��������Ϣ
end

--���ҵĽ�������е������Ϣ����������Ʊ��ˮ�ţ���Ʊ���ţ����ƣ��ҵ����������ͣ��ҵ��۸��Ƿ��������ۣ���������͵ģ�������ۣ���������ߵģ���ִ�У��ɱ�
function Gas2Gac:RetGetCofCStockMyDealingInfo(Conn, stockId, no, name, count, type, price, range, sellPrice, buyPrice, haveCount, costs)
	local node			=	{}
	node.ID				=	stockId
	node.No				=	no
	node.Name			=	name
	node.Count			=	count
	if type == 0 then
		node.Type 		=	"��"
	elseif type == 1 then
		node.Type 		=	"����"
	end
	node.Price			=	price
	node.Range			=	range
	node.SellPrice		=	sellPrice
	node.BuyPrice		=	buyPrice
	node.HaveCount		=	haveCount
	node.Costs			=	costs
	
	table.insert(g_GameMain.m_CofCMainStockWnd.m_MyDealingInfoTbl,node)
end

function Gas2Gac:RetGetCofCStockMyDealingInfoEnd(Conn)
	g_GameMain.m_CofCMainStockWnd:ShowMyDealingInfo()
end

------------------------------------������Rcp�������ӷ���˵ķ���-----------------------------------------------------------

--�����̻��Ʊ���̵Ĵ��ڣ��ҵĹ�Ʊ���ںʹ��̴���һģһ�������Թ�����Դ�ʹ��룩
function CreateStockMainWnd(Parent)
	local wnd	=	CCofCStockMainWnd:new()
	wnd:CreateFromRes("CofCStockMain",Parent)
	wnd:ShowWnd( true )
	g_ExcludeWndMgr:InitExcludeWnd(wnd, 1)
	wnd:InitStockMainChild()
	
	return wnd
end

--��ʼ����Ʊ���̴����ϵ��ӿؼ�
function CCofCStockMainWnd:InitStockMainChild()
	self.m_CloseBtn		=	self:GetDlgChild("Close")				--�رհ�ť
	self.m_AllStock		=	self:GetDlgChild("MainStock")			--�л������̹�Ʊ�Ĵ��ڵİ�ť
	self.m_MyStock		=	self:GetDlgChild("MyStock")				--�л����ҵĹ�Ʊ���ڵİ�ť
	self.m_MyDeal		=	self:GetDlgChild("MyDeal")				--�л����ҵĽ��״��ڵİ�ť
	self.m_StockList	=	self:GetDlgChild("StockList")			--��ʾ��Ʊ��Ϣ�Ĵ���listctrl
	self.m_Title		=	self:GetDlgChild("Title")				--��ʾ�����е�title��Ϣ
end

--��Ʊ���̴����¼���Ӧ����
function CCofCStockMainWnd:OnCtrlmsg( Child, uMsgID, uParam1, uParam2 )
	if (uMsgID == BUTTON_LCLICK) then
	  	if(Child == self.m_CloseBtn) then 				--�رհ�ť
	  		--self:CloseStockOrderlitstWnd()	
	  		self:ShowWnd(false)
	  	
	  	elseif(Child == self.m_AllStock)    then 		--��ʾ���й�Ʊ��Ϣ	
	  		self.m_CurStockType	= 1			
	  		--self:CloseStockOrderlitstWnd()	
	  		g_GameMain.m_CofCStockOrderListWnd:ShowWnd(false)
			self:ShowAllStockInfo()
	  	
	  	elseif(Child == self.m_MyStock)      then		--��ʾ��ִ�еĹ�Ʊ��Ϣ
	  		self.m_CurStockType	= 2	
	  		--self:CloseStockOrderlitstWnd()																
			g_GameMain.m_CofCStockOrderListWnd:ShowWnd(false)
			self:ShowMyStockInfo()
	  	
	  	elseif(Child == self.m_MyDeal)       then		--��ʾ�ҵĹ�Ʊ�Ĺҵ����
	  		self.m_CurStockType	= 3		
	  		--self:CloseStockOrderlitstWnd()					
			g_GameMain.m_CofCStockOrderListWnd:ShowWnd(false)
			self:SetMyStockWndInfo()	
		end
		
	elseif ( uMsgID == ITEM_LBUTTONCLICK ) then
		self:CheckWhichStock(self)
								
	end
end

--�жϵ�������֪��Ʊ��ѡ�У�����ϸ��Ϣ��
--����ֵ����ѡ�еĹ�Ʊ��id
function CCofCStockMainWnd:GetWhichStockChoosed()
	local choosedItem = nil 
	choosedItem = self.m_StockList:GetSelectItem( -1 ) + 1
  
	if choosedItem == 0 then
		return nil
	end
	
	local stockInfoTbl,wndIndex= self:GetCurShowWndTbl()
	
  	local choosedStockNo = stockInfoTbl[choosedItem].No
	return choosedStockNo,wndIndex
end

--���̹�Ʊ���ҵĹ�Ʊ���ҵĽ�����幫�ú�����ɸѡ��Ϣ��������֧��Ʊ��ѡ�в鿴
--�������������𵽵����ĸ����ڶ���
function CCofCStockMainWnd:CheckWhichStock(wndObject)
	local choosedStockNo,wndIndex = self:GetWhichStockChoosed()
	if choosedStockNo == nil then
		return 
	end
	if g_GameMain.m_CofCStockOrderListWnd == nil then
		g_GameMain.m_CofCStockOrderListWnd = CreateStockOrderlistWnd(g_GameMain)
		g_GameMain.m_CofCStockOrderListWnd:ShowWnd(true)
	elseif g_GameMain.m_CofCStockOrderListWnd:IsShow() == false then
		g_GameMain.m_CofCStockOrderListWnd:ShowWnd(true)
	end
	if wndIndex == 2 then
		g_GameMain.m_CofCStockOrderListWnd.m_BuyThisStock:SetWndText("���عҵ�")
		g_GameMain.m_CofCStockOrderListWnd.m_SellThisStock:SetWndText("��������")
	else
		g_GameMain.m_CofCStockOrderListWnd.m_BuyThisStock:SetWndText("�����ù�")
		g_GameMain.m_CofCStockOrderListWnd.m_SellThisStock:SetWndText("�۳��ù�")		
	end
	g_GameMain.m_CofCStockOrderListWnd.m_FianacialInfo:SetWndText("��ʷ�Ʊ�")
	g_GameMain.m_CofCStockOrderListWnd.m_CheckKMap:SetWndText("K��ͼ")
	g_GameMain.m_CofCStockOrderListWnd:ShowExtraWndFalse(true)
	
	Gac2Gas:GetCofCStockOrderList(g_Conn,choosedStockNo)
end

--��ʾ��Ʊ��Ϣ��ͨ�ú�������Ϊ���й�Ʊ�͸��˹�Ʊ����Ϣ������ʾ��ʽһģһ�������������������������ͨ������������
function CCofCStockMainWnd:ShowStockInfoCommon(PersonnalOrAll)
	local stockTbl = {}
	local type  = 0
	if PersonnalOrAll == self.m_AllStockInfoTbl then			--��������й�Ʊ��Ϣ
		stockTbl = self.m_AllStockInfoTbl
		type = 1
	elseif PersonnalOrAll == self.m_MyStockInfoTbl then			--����Ǹ��˹�Ʊ��Ϣ
		stockTbl = self.m_MyStockInfoTbl
		type = 1
	elseif PersonnalOrAll == self.m_MyDealingInfoTbl then		--����Ǹ��˽�����Ϣ
		stockTbl = self.m_MyDealingInfoTbl
		type = 2
	end
	local stockTblLen	= 	# stockTbl
	if stockTblLen >= 1 then
		self.m_FirstStockId = 	stockTbl[1].No						--��¼��һ֧��Ʊid
		self.m_LastStockId	=	stockTbl[stockTblLen].No			--��¼���һ֧��Ʊid
	end
	self.m_StockList:DeleteAllItem()
	for i=1, stockTblLen do
		if ( i == 1 ) then
		  self.m_StockList:InsertColumn( 0, self.m_StockList:GetWndWidth())
		end
		self.m_StockList:InsertItem( i-1, 25 )
		
		local stockItemWnd = SQRDialog:new()
		local item = self.m_StockList:GetSubItem( i-1, 0)
		stockItemWnd:CreateFromRes( "CofCMainStockItem", item )
		stockItemWnd:ShowWnd( true )
		stockItemWnd:SetStyle( 0x60000000 )
		--��ʾ��Ʊ�ľ�����Ϣ
		stockItemWnd:GetDlgChild("No"):SetWndText(stockTbl[i].No)
		stockItemWnd:GetDlgChild("Name"):SetWndText(stockTbl[i].Name)
		stockItemWnd:GetDlgChild("SellPrice"):SetWndText(stockTbl[i].SellPrice)
		stockItemWnd:GetDlgChild("BuyPrice"):SetWndText(stockTbl[i].BuyPrice)

		self:SetStockInfoInStockWnd(stockItemWnd,type,stockTbl,i)
		
		table.insert(self.m_StockListWndTbl, stockItemWnd)
	end

end

--���֣����̡��ҵĹ�Ʊ���ͣ��ҵĽ��ף������ߣ�Ȼ�������������Ϣ����˳����ȷ��ʾ
function CCofCStockMainWnd:SetStockInfoInStockWnd(stockItemWnd,type,stockTbl,index)
	if type == 1 then					--���մ��̡���Ʊ����Ϣ����˳����ʾ��Ϣ
		stockItemWnd:GetDlgChild("HaveNo"):SetWndText(stockTbl[index].HaveCount)
		stockItemWnd:GetDlgChild("Costs"):SetWndText(stockTbl[index].Costs)
		stockItemWnd:GetDlgChild("Range"):SetWndText(stockTbl[index].Range .. "%")
		stockItemWnd:GetDlgChild("DealingCount"):SetWndText(stockTbl[index].DealingCount)
		stockItemWnd:GetDlgChild("HighestPrice"):SetWndText(stockTbl[index].HighestPrice)
		stockItemWnd:GetDlgChild("LowestPrice"):SetWndText(stockTbl[index].LowestPrice)
	elseif type == 2 then
		stockItemWnd:GetDlgChild("HaveNo"):SetWndText(stockTbl[index].Count)
		stockItemWnd:GetDlgChild("Costs"):SetWndText(stockTbl[index].Type)
		stockItemWnd:GetDlgChild("Range"):SetWndText(stockTbl[index].Price)
		stockItemWnd:GetDlgChild("DealingCount"):SetWndText(stockTbl[index].Range .. "%")
		stockItemWnd:GetDlgChild("HighestPrice"):SetWndText(stockTbl[index].HaveCount)
		stockItemWnd:GetDlgChild("LowestPrice"):SetWndText(stockTbl[index].Costs)
	end	
end

--��ʾ���й�Ʊ��Ϣ
function CCofCStockMainWnd:ShowAllStockInfo()	
	self.m_Title:SetWndText("  ����    ����    ִ��     �ɱ�    �Ƿ�   ������    ����     ����   ���    ���")
	self:ShowStockInfoCommon(self.m_AllStockInfoTbl)
end

--��ʾ������ִ�еĹ�Ʊ��Ϣ
function CCofCStockMainWnd:ShowMyStockInfo()
	self.m_Title:SetWndText("  ����    ����    ִ��     �ɱ�    �Ƿ�   ������    ����     ����   ���    ���")
	self:ShowStockInfoCommon(self.m_MyStockInfoTbl)
end

--��ʾ�����ҵĽ�����Ϣ
function CCofCStockMainWnd:ShowMyDealingInfo()
	self:ShowStockInfoCommon(self.m_MyDealingInfoTbl)
end

--��Ϊ���̹�Ʊ���ҵĹ�Ʊ���ҵĽ������������빫��һ�����ڣ����ǽ�����ʾ�����ݲ�̫һ��
--����ͨ���˺�������һЩ��ʾ��Ϣ
function CCofCStockMainWnd:SetMyStockWndInfo()
	self.m_Title:SetWndText(" ����    ����   �ҵ�����   ����  �ҵ��۸�   �Ƿ�    ����     ����   ִ��    �ɱ�")
	Gac2Gas:GetCofCStockMyDealingInfo(g_Conn)
end


--���̹�Ʊ���ҵĹ�Ʊ���ҵĽ������������໥�л�ʱ���ر�ԭ�ȴ򿪵Ĳ鿴ĳ֧��Ʊ�Ĵ���
function CCofCStockMainWnd:CloseStockOrderlitstWnd()
	if g_GameMain.m_CofCStockOrderListWnd ~= nil and 
		g_GameMain.m_CofCStockOrderListWnd:IsShow() then
			g_GameMain.m_CofCStockOrderListWnd:ShowWnd(false)
	end
end

--�õ���ǰ�򿪴��ڶ�Ӧ�Ĺ�Ʊ��Ϣ�����
function CCofCStockMainWnd:GetCurShowWndTbl()
	local stockInfoTbl = {}
	local wndIndex = 1
	if self.m_CurStockType	== 1 then
		stockInfoTbl = self.m_AllStockInfoTbl
	elseif self.m_CurStockType	== 2 then
		stockInfoTbl = self.m_MyStockInfoTbl
	elseif self.m_CurStockType == 3 then
		stockInfoTbl = self.m_MyDealingInfoTbl
		wndIndex = 2
	end
	return stockInfoTbl,wndIndex
end

--ͨ����Ʊ��id�õ��ù�Ʊ��listctrl�е���ʾλ��
--��������ǰ��ʾ��StockOrderlist���ڵĹ�Ʊ��Ϣ��Ӧ�Ĺ�Ʊid�� ��һ֧����һ֧��Ʊ��0������һ֧��1������һ֧��
function CCofCStockMainWnd:GetStockIndexById(stockId, lastOrNext)
	local stockInfoTbl = self:GetCurShowWndTbl()

	local index = self:GetShowIndexByStockId(stockId)
	
	local choosedStockNo = 0				
	if lastOrNext == 0 then						  	--�������Ҫ�õ���һ֧��Ʊ����Ϣ����õ���һ֧��Ʊ��id
		if index == 1 then 
			return
		end
		choosedStockNo = stockInfoTbl[index-1].No	--�������Ҫ�õ���һ֧��Ʊ����Ϣ����õ���һ֧��Ʊ��id
	elseif lastOrNext == 1 then
		local stockInfoTblLen = # stockInfoTbl
		if index == stockInfoTblLen then
			return 
		end
		choosedStockNo = stockInfoTbl[index+1].No
	end
	
	Gac2Gas:GetCofCStockOrderList(g_Conn,choosedStockNo)
end

--ͨ����Ʊid�õ���Ʊ�ڴ����ж�Ӧ����ʾ��index
function CCofCStockMainWnd:GetShowIndexByStockId(stockId,wndInfo)
	local stockInfoTbl = {}
	if wndInfo == nil then
		stockInfoTbl = self:GetCurShowWndTbl()
	else
		stockInfoTbl = wndInfo
	end
	local stockInfoTblLen = # stockInfoTbl
	
	local index = 0
	
	--ͨ��id�õ�index
	for i =1, stockInfoTblLen do
		if stockInfoTbl[i].No == stockId then
			index = i
			return index
		end
	end
end

