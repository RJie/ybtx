
gac_gas_require "framework/common/CMoney"
gac_gas_require "item/SoulpearlCommonFunc"

CNPCShopPlayerSoldWnd = class ( SQRDialog )
local NotWithOneCommonShop = 0--�������̵�
---------------------------------------------------------------------------------------------RPC-----------------------------------------------------------------------------------------------
--����npc�̵깺����Ʒ����
local function CreateNPCShopPlayerSold(Wnd)
	Wnd:CreateFromRes("NpcShopBuyBack",g_GameMain)

	g_ExcludeWndMgr:InitExcludeWnd(Wnd, 1)
	Wnd:InitNPCShopPlayerSoldWndChild()
	return Wnd
end

function CNPCShopPlayerSoldWnd:Ctor()
    CreateNPCShopPlayerSold(self)
end

--��ʼ��npc�̵깺�ؽ��洰���е��ӿؼ�
function CNPCShopPlayerSoldWnd:InitNPCShopPlayerSoldWndChild()
	self.m_Sell				= self:GetDlgChild("Buy")
	self.m_Close			= self:GetDlgChild("Close")
	self.m_ReBuyAllBtn		= self:GetDlgChild("BuyBackAll")
	self.m_BindJin			= self:GetDlgChild("JinCount")
	self.m_BindYin			= self:GetDlgChild("YinCount")
	self.m_BindTong			= self:GetDlgChild("TongCount")
	self.m_LiuTongJin		= self:GetDlgChild("GoldCount")
	self.m_LiuTongYin		= self:GetDlgChild("SliverCount")
	self.m_LiuTongTong		= self:GetDlgChild("CopperCount")
	self.m_BindJinBtn		= self:GetDlgChild("Jin")
	self.m_BindYinBtn		= self:GetDlgChild("Yin")
	self.m_BindTongBtn		= self:GetDlgChild("Tong")
	self.m_LiuTongJinBtn	= self:GetDlgChild("Gold")
	self.m_LiuTongYinBtn	= self:GetDlgChild("Sliver")
	self.m_LiuTongTongBtn	= self:GetDlgChild("Copper")
	
	self.m_tblGoodsWnd			= {}
	self.m_tblGoodsNameDisWnd	= {}
	self.m_tblGoodsPriceWnd		= {}
	for i = 1, 12 do
		local strGoodsRes				= string.format("Goods_%02d", i)
		local strGoodsNameDisRes		= string.format("GoodsNameDis_%02d", i)
		local strGoodsPriceRes			= string.format("GoodsPrice_%02d", i)
		self.m_tblGoodsWnd[i]			= self:GetDlgChild(strGoodsRes)
		self.m_tblGoodsNameDisWnd[i]	= self:GetDlgChild(strGoodsNameDisRes)
		self.m_tblGoodsPriceWnd[i]		= self:GetDlgChild(strGoodsPriceRes)
	end
	--self:SetMouseWheel(true)
end
--�ӷ�����������ҽ�ɫ����������Ʒ��������ʾ�ڹ��򴰿�
function CNPCShopPlayerSoldWnd:ShowNPCShopPlayerSoldWnd(GoodsType,GoodsName,GoodsCount,nViewIndex,GoodsID,GoodsPosIndex)
	local SmallIcon		= g_ItemInfoMgr:GetItemInfo(GoodsType,GoodsName,"SmallIcon")
	local goodsPrice	= string.format("GoodsPrice_%02d", nViewIndex)
	local iconWnd		= self.m_tblGoodsWnd[nViewIndex]
	self.m_tblGoodsWnd[nViewIndex].GoodsPosIndex = GoodsPosIndex
	g_LoadIconFromRes(SmallIcon, iconWnd, -1, IP_ENABLE, IP_CLICKDOWN)
	g_SetWndMultiToolTips(iconWnd,GoodsType,GoodsName,GoodsID,GoodsCount)
	if GoodsCount > 1 then 
		iconWnd:SetWndText(" " .. GoodsCount)
	end
	local c_money = CMoney:new()
	local moneyStr = ""

	if g_ItemInfoMgr:IsSoulPearl(GoodsType) then
	    local item = g_DynItemInfoMgr:GetDynItemInfo(GoodsID)
	    local soulCount = item.nSoulNum
	    moneyStr = GetSoulpearlPriceInfo(GoodsName,soulCount, g_GameMain.m_NPCShopSell.m_PayType, 1/4)
	else
	    moneyStr = g_Tooltips:GetItemPriceByPayType(GoodsType, GoodsName, false)
    end
	local DisplayName = g_ItemInfoMgr:GetItemLanInfo(GoodsType,GoodsName,"DisplayName")
	self.m_tblGoodsNameDisWnd[nViewIndex]:SetWndText(DisplayName)
	self.m_tblGoodsPriceWnd[nViewIndex]:SetWndText(moneyStr)
end

function CNPCShopPlayerSoldWnd:VirtualExcludeWndClosed()
	if g_GameMain.m_NPCShopSell:IsShow() == false then
	    g_GameMain.m_NPCShopSell.m_ShopOpenFlag =false
		g_GameMain.m_WndMainBag.m_ctItemRoom:UpdateBagTips(false, nil)
		g_GameMain.m_RoleStatus:UpdataEquipTips()
	end
end

function CNPCShopPlayerSoldWnd:OnLButtonClick( nFlags,  uParam1, uParam2 )
	self:OnLButtonUp( nFlags,  uParam1, uParam2 )
end

--������NPC�̵꣬��������Ʒֱ������
function CNPCShopPlayerSoldWnd:OnLButtonUp( nFlags,  uParam1, uParam2 )
	local state, context = g_WndMouse:GetCursorState()
	if state == ECursorState.eCS_PickupItem then --��������Ʒ
		g_GameMain.m_NPCShopSell:SellItem( context )
	end
end

--NPC�̵깺�򴰿��¼���Ӧ
function CNPCShopPlayerSoldWnd:OnCtrlmsg(Child, uMsgID, uParam1, uParam2)
	local state, context = g_WndMouse:GetCursorState()
	
	if uMsgID == BUTTON_LCLICK then 
		if Child == g_GameMain.m_NPCShopPlayerSold.m_Sell then
			local wnd = g_GameMain.m_NPCShopSell
			wnd:ShowWnd(true)
			if NpcShop_Common(wnd.npcName, "ShopType") == NotWithOneCommonShop then
			    local AutoCloseWnd = CAutoCloseWnd:new()
			    AutoCloseWnd:AutoCloseWnd(wnd)
			end
			g_GameMain.m_NPCShopPlayerSold:ShowWnd(false)
			if wnd.m_PayType ~= 0  then
				wnd:ShowJiFenCountInShopOrNot(true)
				wnd.m_JiFenChkBtnTbl[wnd.m_PayType]:SetCheck(true)
				wnd.m_JiFenChkBtnTbl[wnd.m_PayType]:EnableWnd(true)
			end
			
		elseif Child == g_GameMain.m_NPCShopPlayerSold.m_Close then
			g_GameMain.m_NPCShopPlayerSold:ShowWnd(false)

		elseif Child == g_GameMain.m_NPCShopPlayerSold.m_ReBuyAllBtn then
			local npcName = g_GameMain.m_NPCShopSell.npcName
			if g_MainPlayer.m_ItemBagLock then
				MsgClient(160018)
				return 
			end
			Gac2Gas:BuyBackAllItem( g_Conn, npcName )

		elseif state == ECursorState.eCS_PickupItem then --��������Ʒ
			g_GameMain.m_NPCShopSell:SellItem( context )
		end
	elseif uMsgID == BUTTON_RIGHTCLICKDOWN then --����û����Ʒ,--�Ҽ�����۳�����Ʒ��ֱ��ȡ��
		if  state ~= ECursorState.eCS_Normal then --��������Ʒ 
			g_WndMouse:ClearCursorAll()
		else
			g_GameMain.m_NPCShopPlayerSold:GetClickWndItem(Child)
		end
	end
end

function CNPCShopPlayerSoldWnd:GetClickWndItem(itemWnd)
	local itemWndChoosed = 0
	for i = 1, #(self.m_tblGoodsWnd) do
		if(itemWnd == self.m_tblGoodsWnd[i]) then
			itemWndChoosed = i
		end
	end
	local tbl = g_GameMain.m_PlayerSoldGoodsList
	local tblLength = table.maxn(tbl)
	if itemWndChoosed > 0 and itemWndChoosed <= tblLength then
		local npcName = g_GameMain.m_NPCShopSell.npcName
		if g_MainPlayer.m_ItemBagLock then
			MsgClient(160018)
			return 
		end 
		Gac2Gas:BuyBackItem( g_Conn, npcName, self.m_tblGoodsWnd[itemWndChoosed].GoodsPosIndex )
	end
end

--���ͼ��
function CNPCShopPlayerSoldWnd:ClearWndInfo()
	for i = 1, 12 do
		local goodsWnd = self.m_tblGoodsWnd[i]
		self.m_tblGoodsNameDisWnd[i]:SetWndText("")
		self.m_tblGoodsPriceWnd[i]:SetWndText("")
		goodsWnd:SetWndText("")
		goodsWnd:SetMouseOverDescAfter("")
		g_DelWndImage(goodsWnd, 1, IP_ENABLE, IP_CLICKDOWN)
		g_WndMouse:SetWndCursorSkillState(goodsWnd, ECursorSkillState.eCSS_Normal)
	end
end

------------------------�Ѵ�װ��ʱ������Ʒtooltip���и��£���֤װ����tooltip�Ƚ���Ϣ��ȷ---------
function CNPCShopPlayerSoldWnd:UpdateNpcSoldItemTooltip()
    local soldListTbl = g_GameMain.m_PlayerSoldGoodsList
    for i =1, g_GameMain.NPCShopPlayerSoldCount do
        local iconWnd = self.m_tblGoodsWnd[i]
        local GoodsType = soldListTbl[i].GoodsType
        local GoodsName = soldListTbl[i].GoodsName
        local GoodsCount = soldListTbl[i].GoodsCount
        local GoodsID = soldListTbl[i].GoodsID
        g_SetWndMultiToolTips(iconWnd,GoodsType,GoodsName,GoodsID,GoodsCount)     
    end
end