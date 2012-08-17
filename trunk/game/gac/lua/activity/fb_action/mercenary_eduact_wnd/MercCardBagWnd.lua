lan_load "fb_game/Lan_MercCardTooltip_Common"
cfg_load "fb_game/MercCardTooltip_Common"

CMercCardBagWnd = class(SQRDialog)

local MercCardLine 			= 5			-- 5��
local MercCardNum 			= 10 		-- ÿ��10��
local MercCardPage 			= 2			-- ҳ��
local MercCardWeightInv = 15 		-- ���
local MercCardHeightInv = 16
local NowPageWnd 				= nil		-- ��ǰҳ�洰��
local NowPageNum				= 1 		-- ��ǰҳ��

local function GetMercCardNum()
	local MercCardNumber = 0
	for _, CardID in pairs(MercCardTooltip_Common:GetKeys()) do
		if CardID < 1000 then
			MercCardNumber = MercCardNumber + 1
		end
	end
	return MercCardNumber
end

function CMercCardBagWnd:Ctor()
--	self.RecordMecCardTbl = {}
	NowPageNum = 1
	self:CreateFromRes("Fb_MercCardBagWnd",g_GameMain) 
	self.m_CloseBtn 				= self:GetDlgChild("CloseBtn")
	self.m_MercCardPageBtn = self:GetDlgChild("MercCardPageBtn")
	self.m_PrePageBtn 			= self:GetDlgChild("PrePageBtn")
	self.m_NextPageBtn 		= self:GetDlgChild("NextPageBtn")
	self.m_PageNumber			= self:GetDlgChild("PageNumber")
	
	self.m_MercCardPageOneWnd = CMercCardPageOneWnd:new(self.m_MercCardPageBtn)
	self.m_MercCardPageTwoWnd = CMercCardPageTwoWnd:new(self.m_MercCardPageBtn)
	NowPageWnd = self.m_MercCardPageOneWnd 		-- ��ʼ�ǵ�һҳ
	
	self.m_MercCards = {}
	local MercCardNumber	= GetMercCardNum()
	for i = 1, MercCardNumber do
		Line = math.floor((i-1) / 10) + 1
		Num = (i-1) % 10 + 1
		local number = (Line-1)*MercCardNum + Num	
		local TempWnd = nil				
		if Line <= MercCardLine then															-- ��һҳ
--			self.m_MercCards[number] = CreateMercCardWnd(self.m_MercCardPageOneWnd, number)	
			self.m_MercCards[number] = CMercCardWnd:new(self.m_MercCardPageOneWnd, number)
			TempWnd = self.m_MercCardPageOneWnd
		elseif Line <= 2 * MercCardLine then											-- �ڶ�ҳ
--			self.m_MercCards[number] = CreateMercCardWnd(self.m_MercCardPageTwoWnd, number)
			self.m_MercCards[number] = CMercCardWnd:new(self.m_MercCardPageTwoWnd, number)
			TempWnd = self.m_MercCardPageTwoWnd
			Line = Line - 5
		end
		
		-- λ��
		local CardWnd = self.m_MercCards[number]
		local number = (Line-1)*MercCardNum + Num
		local MercCardWindth = CardWnd:GetWndOrgWidth()
		local MercCardHeight = CardWnd:GetWndOrgHeight()
		local rt = CFRect:new()
		TempWnd:GetLogicRect(rt)
		local rt_1 	= CFRect:new()
		rt_1.top 		= rt.top + (MercCardHeightInv + MercCardHeight) * (Line - 1)
		rt_1.left 	= rt.left + (MercCardWeightInv + MercCardWindth) * (Num - 1)
		rt_1.bottom = rt_1.top + MercCardHeight
		rt_1.right 	= rt_1.left + MercCardWindth
		CardWnd:SetLogicRect(rt_1)
	end
	
	g_ExcludeWndMgr:InitExcludeWnd(self, 1)
	self:ShowWnd(false)
	--Wnd:ShowWnd(false)
	return Wnd
end

function CMercCardBagWnd:OpenMercCardBag()
	if not self:IsShow() then
		self:ShowWnd(true)
		NowPageWnd:ShowWnd(false)
		NowPageWnd = self.m_MercCardPageOneWnd 		-- ��ʼ�ǵ�һҳ
		self:ShowFirstPage()
		NowPageNum = 1
		self.m_PageNumber:SetWndText(NowPageNum)
		self.m_PrePageBtn:ShowWnd(false)							-- ����ʾ��ǰһҳ��
		self.m_NextPageBtn:ShowWnd(true)							-- ��ʾ����һҳ��
	else
		self:ShowWnd(false)
		NowPageWnd:ShowWnd(false)
	end
end

function CMercCardBagWnd:OnCtrlmsg( Child, uMsgID, uParam1, uParam2 )
	if uMsgID == BUTTON_LCLICK  then
		if Child == self.m_PrePageBtn then
			if NowPageNum > 1 then
				NowPageNum = NowPageNum - 1
				if NowPageNum == 1 then
					NowPageWnd:ShowWnd(false)											-- ����ʾ�ղ���ҳ
					--self.m_MercCardPageOneWnd:ShowWnd(true)				-- ��ʾ��һҳ
					self:ShowFirstPage()
					NowPageWnd = self.m_MercCardPageOneWnd				-- ��ǰ��WND
					self.m_PageNumber:SetWndText(NowPageNum)			-- ��ʾҳ��
					self.m_PrePageBtn:ShowWnd(false)							-- ����ʾ��ǰһҳ��
					self.m_NextPageBtn:ShowWnd(true)							-- ��ʾ����һҳ��
				end	
			end		
		elseif Child == self.m_NextPageBtn then
			if NowPageNum < MercCardPage then
				NowPageNum = NowPageNum + 1
				if NowPageNum == 2 then
					NowPageWnd:ShowWnd(false)
					--self.m_MercCardPageTwoWnd:ShowWnd(true)
					self:ShowSecondPage()
					NowPageWnd = self.m_MercCardPageTwoWnd
					self.m_PageNumber:SetWndText(NowPageNum)
					self.m_NextPageBtn:ShowWnd(false)							-- ����ʾ����һҳ��
					self.m_PrePageBtn:ShowWnd(true)								-- ��ʾ��ǰһҳ��
				end
			end
		elseif Child == self.m_CloseBtn then
			self:ShowWnd(false)
			NowPageWnd:ShowWnd(false)
		end
	end
end

function CMercCardBagWnd:ShowFirstPage()
	self.m_MercCardPageOneWnd:ShowWnd(true)
	for i=1, MercCardLine*MercCardNum do
		if self.RecordMecCardTbl[i] then
			self:ShowMercCard(i)
		end
	end
end

function CMercCardBagWnd:ShowSecondPage()
	self.m_MercCardPageTwoWnd:ShowWnd(true)	
	for i=MercCardLine*MercCardNum + 1, 2*MercCardLine*MercCardNum do
		if self.RecordMecCardTbl[i] then
			self:ShowMercCard(i)
		end	
	end
end

function CMercCardBagWnd:ShowMercCard(ID)
	self.m_MercCards[ID]:ShowWnd(true)
end

function CMercCardBagWnd:InitMercCard(Conn)
	self.RecordMecCardTbl = {}
end

function CMercCardBagWnd:RecordMercCard(Conn,i)
	self.RecordMecCardTbl[i] = true
end