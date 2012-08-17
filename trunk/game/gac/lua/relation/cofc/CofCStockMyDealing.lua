gac_require "relation/cofc/CofCStockMyDealingInc"

function Gas2Gac:RetGetCofcMyHaveInfo(Conn,myHave,costs)
	g_GameMain.m_CofCStockMyDealing:ShowUpdataMyDealingInfo(myHave,costs)
end


-------------------------------------RPC--------------------------------------------

--�����ҵĽ��״���
function CreateCofCMyDealingWnd(Parent)
	local wnd = CofCStockMyDealingWnd:new()
	wnd:CreateFromRes("CofCStockDealing", Parent)
	wnd:ShowWnd( true )
	g_ExcludeWndMgr:InitExcludeWnd(wnd, 1)
	wnd:InitCofCStockMyDealingChild()
	wnd:SetStyle(0x40040000)
	return wnd
end

--��ʼ���̻��Ʊ���ҵĽ��״����е��ӿؼ�
function CofCStockMyDealingWnd:InitCofCStockMyDealingChild()
	self.m_CloseBtn			=	self:GetDlgChild("Close")
	self.m_NameText			=	self:GetDlgChild("NameText")					--��Ʊ����
	self.m_NoText			=	self:GetDlgChild("NoText")						--��Ʊ����
	self.m_BuyStock 		=	self:GetDlgChild("BuyStock")					--�����Ʊ
	self.m_SellStock		=	self:GetDlgChild("SellStock")					--�۳���Ʊ
	self.m_CurStockCount	=	self:GetDlgChild("CurStockCount")				--��ǰ������
	self.m_CurSellPrice		=	self:GetDlgChild("CurSellPrice")				--��ǰ��ͳ��ۼ�
	self.m_Text				=	self:GetDlgChild("Text")						--Ŀǰ�깺���������ϸ��Ϣ
	self.m_MyHave			=	self:GetDlgChild("HaveText")					--ִ�й���
	self.m_CostsText		=	self:GetDlgChild("CostsText")					--�ɱ�
	self.m_OkBtn			=	self:GetDlgChild("Ok")							--ȷ����ť
	self.m_UpdateBtn		=	self:GetDlgChild("Update")						--ˢ�°�ť
	self.m_Cancel			=	self:GetDlgChild("Cancel")						--ȡ����ť
	self.m_InputCountText	=	self:GetDlgChild("InputCountText")				--����Ҫ���׵�����
	self.m_InputPriceText	=	self:GetDlgChild("InputPriceText")				--����Ҫ���׵ļ۸�	
end

--�ҵĽ��״����¼���Ӧ����
function CofCStockMyDealingWnd:OnCtrlmsg(Child, uMsgID, uParam1, uParam2 )
	if (uMsgID == BUTTON_LCLICK) then
	  	if(Child == self.m_CloseBtn or Child == self.m_Cancel) then 				--�رհ�ť
	  		self:ShowWnd(false)
	  		g_GameMain.m_CofCStockOrderListWnd:ShowWnd(false)
	  		g_GameMain.m_CofCStockOrderListWnd.UpdateCofCStockMyDealingInfoCallBack = nil	--���жϵȴ�ˢ���ҵĽ������Ĵ��ں�����Ϊnil����Ϊһ���ر��ҵĽ�����崰�ڣ���������Ͳ���Ҫ��
	  	
	  	elseif(Child == self.m_BuyStock)    	then 			--�����Ʊ��ť����ʾ��������Ʊ��Ϣ
			if self.m_CurDealingType  == 1 then
				return
			end
			self.m_CurDealingType 	=	1
			local wnd = g_GameMain.m_CofCStockOrderListWnd
			if table.getn(wnd.m_SellOrderlistTbl) > 0 then
				self:ShowBestOrderlistInfoWnd(true)
				self:ShowCofCStockDealingInfo(wnd.m_TotalSellCount,wnd.m_SellOrderlistTbl[1].Price,wnd.m_SellOrderlistTbl[1].Count)
			else
				self:ShowBestOrderlistInfoWnd(false)
			end
		
	  	elseif(Child == self.m_SellStock)      	then			--������Ʊ��ť����ʾ���������Ʊ��Ϣ
			if self.m_CurDealingType  == 2 then					--����Ѿ��ڵ�ǰҳ�棬����˸ð�ťû����Ӧ
				return
			end
			self.m_CurDealingType 	=	2
			local wnd = g_GameMain.m_CofCStockOrderListWnd
			if table.getn(wnd.m_BuyOrderlistTbl) > 0 then		--�йҵ���ʱ����ʾ�ҵ�������ʵĹ�Ʊ�۸����Ŀ
				self:ShowBestOrderlistInfoWnd(true)
				self:ShowCofCStockDealingInfo(wnd.m_TotalBuyCount,wnd.m_BuyOrderlistTbl[1].Price,wnd.m_BuyOrderlistTbl[1].Count)
			else												--û���κιҵ�������£��ҵ����������ʾ�Ĺɼۺ���Ŀ�ǹ�Ʊ�����
				self:ShowBestOrderlistInfoWnd(false)
			end
			
	  	elseif(Child == self.m_OkBtn)       	then			--ȷ����ť
	  		local stockCount = self.m_InputCountText:GetWndText()
	  		if stockCount == nil or stockCount == "" then
	  			self.m_MsgBox = MessageBox(self, MsgBoxMsg(16006), MB_BtnOK )
	  			return 
	  		end
	  		local stockPrice = self.m_InputPriceText:GetWndText()
	  		if stockPrice == nil or stockPrice == "" then
	  			self.m_MsgBox = MessageBox(self, MsgBoxMsg(16007), MB_BtnOK)
	  			return
	  		end
	  		self:ShowWnd(false)
	  		g_GameMain.m_CofCStockOrderListWnd:ShowWnd(false)
	  		g_GameMain.m_CofCStockOrderListWnd.UpdateCofCStockMyDealingInfoCallBack = nil
	  		
	  		if self.m_CurDealingType == 1 then
	  			Gac2Gas:CofcStockBuy(g_Conn, g_GameMain.m_CofCStockOrderListWnd.m_CurStockId, tonumber(stockCount), tonumber(stockPrice))	
	  		elseif self.m_CurDealingType == 2 then
	  			Gac2Gas:CofcStockSell(g_Conn, g_GameMain.m_CofCStockOrderListWnd.m_CurStockId, tonumber(stockCount), tonumber(stockPrice))	
	  		end
	  	
	  	elseif(Child == self.m_UpdateBtn)       then		--ˢ�°�ť
	  		Gac2Gas:GetCofcMyHaveInfo(g_Conn, g_GameMain.m_CofCStockOrderListWnd.m_CurStockId)
	  		Gac2Gas:GetCofCStockOrderList(g_Conn, g_GameMain.m_CofCStockOrderListWnd.m_CurStockId)
		end				
	
	elseif (uMsgID == WND_NOTIFY ) then							--�����������������Ƿ����ֵĶ�����ֱ�����
		if (WM_IME_CHAR == uParam1 or WM_CHAR == uParam1) then
			local count = self.m_InputCountText:GetWndText()
			local price = self.m_InputPriceText:GetWndText()
			if Child == self.m_InputCountText  then
				if count ~= nil and IsNumber(tonumber(count)) == false then
					self.m_InputCountText:SetWndText("")
					return 
				end
			end	
			if Child == self.m_InputPriceText  then				--������׼۸�������Ƿ����ֵĶ�����ֱ�����
				if price ~= nil and IsNumber(tonumber(price)) == false then
					self.m_InputPriceText:SetWndText("")
					return
				end
			end
			if count ~= nil and count ~= "" and price ~= nil and price ~= "" then			--������Ľ��׹�Ʊ��������Ŀ����Ϊ��ʱ������ʾ������ʾ��Ϣ
				self:ShowDetailInfo()
			end
		end	
	end
end

--��ʾ��Ʊ��ǰ������Ϣ
function CofCStockMyDealingWnd:ShowCofCStockDealingInfo(stockCount,price,priceStockCount)
	self.m_InputCountText:SetWndText("")
	self.m_InputPriceText:SetWndText("")
	self.m_Text:SetWndText("")
	--���û�й�Ʊ��Ϣ����Ĭ�ϳ�ʼΪ0
	if stockCount == nil then
		stockCount = 0
	end
	if price == nil then
		price = 0 
	end
	if priceStockCount == nil then
		priceStockCount = 0
	end
	if self.m_CurDealingType == 1 then
		self.m_CurStockCount:SetWndText("��ǰ��������" .. stockCount .. "��")
		self.m_CurSellPrice:SetWndText("��ǰ��ͳ��ۼۣ�"  .. price .. "ͭ/" .. priceStockCount .. "��")
	elseif self.m_CurDealingType == 2 then
		self.m_CurStockCount:SetWndText("��ǰ���򵥣�" .. stockCount .. "��")
		self.m_CurSellPrice:SetWndText("��ǰ��߳��ۼۣ�"  .. price .. "ͭ/" .. priceStockCount .. "��")
	end
	local tblIndex = g_GameMain.m_CofCMainStockWnd:GetShowIndexByStockId( g_GameMain.m_CofCStockOrderListWnd.m_CurStockId,g_GameMain.m_CofCMainStockWnd.m_MyStockInfoTbl)	
	if tblIndex ~= nil then
		local myHave, costs = g_GameMain.m_CofCMainStockWnd.m_MyStockInfoTbl[tblIndex].HaveCount,g_GameMain.m_CofCMainStockWnd.m_MyStockInfoTbl[tblIndex].Costs
		self:ShowUpdataMyDealingInfo(myHave,costs)
	end
end

--������Ĺ�Ʊ�������������ͼ۸񶼲�Ϊ��ʱ����ʾ��ص�������Ϣ
function CofCStockMyDealingWnd:ShowDetailInfo()
	if self.m_CurDealingType == 1 then
		self.m_Text:SetWndText("����ǰ�깺" .. self.m_InputCountText:GetWndText() .. "��".. "������չ���Ϊ" .. self.m_InputPriceText:GetWndText() .. "ʱ������ֱ�ӹ��������ҵ���")
	elseif self.m_CurDealingType == 2 then
		self.m_Text:SetWndText("����ǰ����" .. self.m_InputCountText:GetWndText() .. "��".. "����ͳ��ۼ�Ϊ" .. self.m_InputPriceText:GetWndText() .. "ʱ������ֱ�ӳ��۶�����ҵ���")
	end
end

function CofCStockMyDealingWnd:ShowUpdataMyDealingInfo(myHave,costs)
	self.m_MyHave:SetWndText(myHave .. "��")
	self.m_CostsText:SetWndText(costs)
end

--���Ҫ�����������Ʊ�����ǹ�����û�и�ֻ��Ʊ���������򵥣����ҵĹ�Ʊ���״����е�����ʼ�Ǯ����Ŀ���ڲ���ʾ
function CofCStockMyDealingWnd:ShowBestOrderlistInfoWnd(showOrNot)
	self.m_CurStockCount:ShowWnd(showOrNot)
	self.m_CurSellPrice:ShowWnd(showOrNot)
end