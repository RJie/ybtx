gac_require "relation/cofc/CofCStockFinancialInc"

--�鿴��ʷ�Ʊ���Ϣ���أ�--��������Ʊ���ƣ���Ʊ��ţ��ڼ俪ʼʱ�䣻�ڼ����ʱ�䣻
						--	�̻�ȼ����̻����ʽ��ڼ����룻�۳���Ʊ���ڼ佻�������������������ҳ��й������ҵĳ��гɱ���
						--	�̻��������̻��Ծ�ȣ�����Ϊ��һ�������ɶ��Ľ�ɫ���ͳ��й���
function Gas2Gac:RetGetCofCFinancialReport(Conn,name ,no ,startTime, endTime,level,money, income,soldStock,tradeCount,bonus,myHaveStock,myHaveCosts,personCount,activity,shareholders1Name,stockCount1,shareholders2Name,stockCount2,shareholders3Name,stockCount3,shareholders4Name,stockCount4,shareholders5Name, stockCount5)
	if g_GameMain.m_CofCStockFinancialWnd == nil then
			g_GameMain.m_CofCStockFinancialWnd = CreateCofCStockFinancialWnd(g_GameMain)
			g_GameMain.m_CofCStockFinancialWnd.m_CurWeek = 0
			if g_GameMain.m_CofCStockOrderListWnd ~= nil then
				table.insert( g_GameMain.m_CofCStockOrderListWnd.TblFatherWnd, g_GameMain.m_CofCStockFinancialWnd)
			end
			g_GameMain.m_CofCStockFinancialWnd:ShowWnd(true)
	elseif g_GameMain.m_CofCStockFinancialWnd:IsShow() == false then
			if g_GameMain.m_CofCStockOrderListWnd ~= nil then
				table.insert( g_GameMain.m_CofCStockOrderListWnd.TblFatherWnd, g_GameMain.m_CofCStockFinancialWnd)
			end
			g_GameMain.m_CofCStockFinancialWnd:ShowWnd(true)
	end
	if g_GameMain.m_CofCStockOrderListWnd == nil or g_GameMain.m_CofCStockOrderListWnd:IsShow() == false then
		g_GameMain.m_CofCStockFinancialWnd.m_LastWeek:ShowWnd(false)
		g_GameMain.m_CofCStockFinancialWnd.m_ThisWeek:ShowWnd(false)
	elseif  g_GameMain.m_CofCStockOrderListWnd:IsShow() then
		g_GameMain.m_CofCStockFinancialWnd.m_LastWeek:ShowWnd(true)
		g_GameMain.m_CofCStockFinancialWnd.m_ThisWeek:ShowWnd(true)
		g_GameMain.m_CofCStockOrderListWnd.m_CheckKMap:SetWndText("��������")
		g_GameMain.m_CofCStockOrderListWnd.m_FianacialInfo:SetWndText("K��ͼ")
	end
		
	g_GameMain.m_CofCStockFinancialWnd:ShowCofCStockFinancial(name ,no ,startTime, endTime,level,money, income,soldStock,tradeCount,bonus,myHaveStock,myHaveCosts,personCount,activity,shareholders1Name,stockCount1,shareholders2Name,stockCount2,shareholders3Name,stockCount3,shareholders4Name,stockCount4,shareholders5Name, stockCount5)
end

------------------------------------------RPC--------------------------------------------------

--�����̻��Ʊ��ʷ�Ʊ�����
function CreateCofCStockFinancialWnd(Parent)
	local wnd	=	CCofCStockFinancialWnd:new()
	wnd:CreateFromRes("CofCFinancialInfo",Parent)
	wnd:ShowWnd( true )
	wnd:InitCofCStockFinancialChild()
	g_ExcludeWndMgr:InitExcludeWnd(wnd, 1)
	return wnd
end

--��ʼ���̻��Ʊ�Ʊ������е��ӿؼ�
function CCofCStockFinancialWnd:InitCofCStockFinancialChild()
	self.m_CloseBtn			=	self:GetDlgChild("Close")
	self.m_StockNameText	=	self:GetDlgChild("StockNameText")			--��ʾ��Ʊ����
	self.m_StockNoText		=	self:GetDlgChild("StockNoText")				--��ʾ��Ʊ����
	self.m_StockPeriodText	=	self:GetDlgChild("StockPeriodText")			--��ʾ��Ʊ��Ч����
	self.m_LastWeek			=	self:GetDlgChild("LastWeek")				--��ʾ��һ�ܲƱ���ť
	self.m_ThisWeek			=	self:GetDlgChild("ThisWeek")				--��ʾ��һ�ܲƱ���ť
	self.m_Level			=	self:GetDlgChild("Level")					--��ʾ�̻�ȼ�
	self.m_PersonCount		=	self:GetDlgChild("PersonCount")				--��ʾ�̻�����
	self.m_Money			=	self:GetDlgChild("Money")					--��ʾ�̻����ʽ���Ŀ
	self.m_Activity			=	self:GetDlgChild("Activity")				--��ʾ�̻��Ծ��
	self.m_Income			=	self:GetDlgChild("Income")					--��ʾ�̻�����
	self.m_Output			=	self:GetDlgChild("Output")					--��ʾ�̻�ƽ��ÿ�˲���
	self.m_StockSell		=	self:GetDlgChild("StockSell")				--��ʾ�۳���Ʊ�ܹ���
	self.m_TotakDealing		=	self:GetDlgChild("TotakDealing")			--��ʾ�̻��ܽ�����
	self.m_First			=	self:GetDlgChild("First")					--��ʾ�̻��1��ɶ����й�Ʊ��Ϣ
	self.m_Second			=	self:GetDlgChild("Second")					--��ʾ�̻��2��ɶ����й�Ʊ��Ϣ
	self.m_Third			=	self:GetDlgChild("Third")					--��ʾ�̻��3��ɶ����й�Ʊ��Ϣ
	self.m_Forth			=	self:GetDlgChild("Forth")					--��ʾ�̻��4��ɶ����й�Ʊ��Ϣ
	self.m_Fifth			=	self:GetDlgChild("Fifth")					--��ʾ�̻��5��ɶ����й�Ʊ��Ϣ
	self.m_Bonus			=	self:GetDlgChild("Bonus")					--��ʾ�̻ᷢ������������
	self.m_BonusPerStock	=	self:GetDlgChild("BonusPerStock")			--��ʾ�̻�ÿ�ɺ�������Ǯ
	self.m_MyHave			=	self:GetDlgChild("MyHave")					--��ʾ��ִ�й�Ʊ����Ϣ
end


--�̻��Ʊ�Ʊ������¼���Ӧ����
function CCofCStockFinancialWnd:OnCtrlmsg( Child, uMsgID, uParam1, uParam2 )
	if (uMsgID == BUTTON_LCLICK) then
	  	if(Child == self.m_CloseBtn) then 
	  		g_GameMain.m_CofCStockOrderListWnd:ShowWnd(false)
	  		self:ShowWnd(false)
	  	
	  	elseif(Child == self.m_LastWeek)    then 				--Ҫ��鿴��Ʊ��һ�ܲƱ�����Ϣ							
			self.m_CurWeek = self.m_CurWeek - 1
			Gac2Gas:GetCofCFinancialReport(g_Conn,g_GameMain.m_CofCStockOrderListWnd.m_CurStockId,self.m_CurWeek)
	  			
	  	elseif(Child == self.m_ThisWeek)      then				--Ҫ��鿴��Ʊ��һ�ܲƱ�����Ϣ															
			self.m_CurWeek = self.m_CurWeek +1
			Gac2Gas:GetCofCFinancialReport(g_Conn,g_GameMain.m_CofCStockOrderListWnd.m_CurStockId,self.m_CurWeek)
		end
	end	
end
 
--��ʾ���ص��̻�Ʊ���ʷ��Ϣ����ʾ�ڿͻ���;
--��������Ʊ���ƣ���Ʊ��ţ��ڼ俪ʼʱ�䣻�ڼ����ʱ�䣻
						--	�̻�ȼ����̻����ʽ��ڼ����룻�۳���Ʊ���ڼ佻�������������������ҳ��й������ҵĳ��гɱ���
						--	�̻��������̻��Ծ�ȣ�����Ϊ��һ�������ɶ��Ľ�ɫ���ͳ��й���
function CCofCStockFinancialWnd:ShowCofCStockFinancial(name ,no ,startTime, endTime,level,money, income,soldStock,tradeCount,bonus,myHaveStock,myHaveCosts,personCount,activity,shareholders1Name,stockCount1,shareholders2Name,stockCount2,shareholders3Name,stockCount3,shareholders4Name,stockCount4,shareholders5Name, stockCount5)
	self.m_StockNameText:SetWndText(name)
	self.m_StockNoText:SetWndText(no)
	self.m_StockPeriodText:SetWndText(startTime .. "-" .. endTime )
	self.m_Level:SetWndText("�̻�ȼ���" .. level)
	self.m_Money:SetWndText("�̻��⣺" .. money .. "ͭ")
	self.m_Income:SetWndText("�ڼ����룺" .. income .. "ͭ")
	self.m_StockSell:SetWndText("�۳���Ʊ��" .. soldStock .. "ͭ")
	self.m_TotakDealing:SetWndText("�ڼ��ܽ�������" .. tradeCount .. "ͭ")
	self.m_Bonus:SetWndText("����������" .. bonus .. "ͭ")
	self.m_BonusPerStock:SetWndText("ÿ�ɺ�����" .. bonus/soldStock .. "ͭ")
	self.m_MyHave:SetWndText(myHaveStock/myHaveCosts .. "��/ƽ���ɱ�")
	self.m_PersonCount:SetWndText("�̻�������" .. personCount)
	self.m_Activity:SetWndText("�̻��Ծ�ȣ�" .. activity .. "��" )
	self.m_Output:SetWndText("ƽ��ÿ�˲�����" .. money/personCount .. "ͭ")
	self.m_First:SetWndText("��һ��ɶ���" .. shareholders1Name .. "/����" .. stockCount1 .. "��" )
	self.m_Second:SetWndText("�ڶ���ɶ���" .. shareholders2Name .. "/����" .. stockCount2 .. "��" )
	self.m_Third:SetWndText("������ɶ���" .. shareholders3Name .. "/����" .. stockCount3 .. "��" )
	self.m_Forth:SetWndText("���Ĵ�ɶ���" .. shareholders4Name .. "/����" .. stockCount4 .. "��" )
	self.m_Fifth:SetWndText("�����ɶ���" .. shareholders5Name .. "/����" .. stockCount5 .. "��" )
end