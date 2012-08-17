--gac_require "relation/cofc/CofCStockMain"

local function OpenGuideWnd()
	g_GameMain.m_GuideWnd:OpenPanel( not g_GameMain.m_GuideWnd:IsShow() )
end

function InitShowWndFun()
	--��ʼ���ص�����  (�������еĶ��� ����CNpcDialogBox �е���Ϣ��Ӧ)
	linkfun = {}
	linkfun[1] = WhiteStoneWnd				--�ױ�ʯ����      		$openpanel(1)
	linkfun[3] = NPCShopSellWnd				--NPC�����̵�			$openpanel(3)
	linkfun[4] = NPCShopSoldWnd				--NPC�����̵�
	linkfun[5] = EmailWnd					--�ʼ���������
	linkfun[6] = ReceiveWnd					--�ռ��䴰��
	linkfun[7] = EquipUpWnd					--װ������ǿ�� 
	linkfun[9] = EquipToSoulWnd  			--װ��������
	linkfun[10]= AgiotageWnd				--���Ҷһ�
	linkfun[11]= ConsignmentWnd         	--���۽���������
	--linkfun[13]= CofCNpcDialogWnd			--�̻�npc�Ի���
	--linkfun[14]= OpenCofCWnd				--���̻�������
	--linkfun[15]= OpenCofCStockWnd			--���̻��Ʊ������
	linkfun[16]= OpenContractManufactureWnd --�򿪴��������
	linkfun[17] = OpenSuperaddWnd
	linkfun[18] = OpenItemBagLockWnd --�򿪱��������
	linkfun[19] = OpenGuideWnd			--�������
	linkfun[20] = OpenBuyCouponsWnd         --�򿪵�ȯ�����̵�
end

function WhiteStoneWnd()
	local Whitestone = CWhiteStone.GetWnd()
	Whitestone:ShowWnd(not Whitestone:IsShow())
end

function NPCShopSellWnd()
	SetEvent( Event.Test.OpenNpcSellWnd, true, true)
	if (g_GameMain.m_NPCShopSell:IsShow() == false) then
		g_GameMain.m_NPCShopSell:ShowWnd(true)
		g_GameMain.m_WndMainBag:ShowWnd(true)
		if g_GameMain.m_NPCShopSell.m_buyBatchWnd ~= nil and 
			g_GameMain.m_NPCShopSell.m_buyBatchWnd:IsShow() then
			g_GameMain.m_NPCShopSell.m_buyBatchWnd:ShowWnd(false)
		end
		g_GameMain.m_NPCShopSell:InitNPCShop("��ͯ") --NpcShop_Common[npcName].ShopName
		g_GameMain.m_NPCShopSell.npcName = "��ͯ"
		g_GameMain.m_WndMainBag.m_ctItemRoom:UpdateBagTips(false, nil)
	else
		g_GameMain.m_NPCShopSell:ShowWnd(false)
	end
end

function NPCShopSoldWnd()
	if g_GameMain.m_NPCShopPlayerSold:IsShow() == false then
		g_GameMain.m_NPCShopPlayerSold:ShowWnd( true )
		g_GameMain.m_NPCShopPlayerSold:ShowWnd(true)
		g_GameMain.m_WndMainBag:ShowWnd(true)
		g_GameMain.m_NPCShopSell:InitNPCShop("��ͯ") --NpcShop_Common[npcName].ShopName
		g_GameMain.m_NPCShopSell.npcName = "��ͯ"
	else
		g_GameMain.m_NPCShopPlayerSold:ShowWnd( false )
	end
end

function EmailWnd()
	SetEvent( Event.Test.OpenEmailWnd, true, true) 
	if(g_GameMain.m_EmailBox:IsShow() == false) then
		g_GameMain.m_EmailBox.m_MailInfo = {}
		g_GameMain.m_EmailBox:EnableBtnFalse()
		g_GameMain.m_EmailBox:SetFocus()
		g_GameMain.m_EmailBox.m_SysItemCount = -1
		g_GameMain.m_EmailBox.m_CommItemCount = -1
		g_GameMain.m_EmailBox.EmailWndTbl = {}
		g_GameMain.m_EmailBox.NowChooseEmailTbl = {}
		g_GameMain.m_EmailBox.NowEmail = {}
		g_GameMain.m_EmailBox:GetMailsInfoFromGas()
		g_GameMain.m_EmailBox:ShowWnd(true)
	else
		g_ExcludeWndMgr:CloseAllActiveWndExclude()
	end
	local AutoCloseWnd = CAutoCloseWnd:new()
	AutoCloseWnd:AutoCloseWnd(g_GameMain.m_EmailBox)
end

function ReceiveWnd()
	g_GameMain.m_ReceiveBox:ShowWnd(not g_GameMain.m_ReceiveBox:IsShow())
end

function EquipUpWnd()
	if g_GameMain.m_EquipUpIntensifyWnd:IsShow() == false then
		g_GameMain.m_EquipUpIntensifyWnd:ShowWnd(true)
	else
		g_GameMain.m_EquipUpIntensifyWnd:ShowWnd(false)
	end
end

function EquipToSoulWnd()
	if g_GameMain.m_EquipToSoul:IsShow() == false then
		g_GameMain.m_EquipToSoul:ShowWnd(true)
	else
		g_GameMain.m_EquipToSoul:ShowWnd(false)
	end
	g_GameMain.m_EquipToSoul:ClearEquipBtn()
end

function AgiotageWnd()
	g_GameMain.m_Agiotage:ShowWnd(not g_GameMain.m_Agiotage:IsShow())
end


--�յ������������Ĵ򿪻�ر�ĳ�����ڵ���Ϣ
function Gas2Gac:ReturnOpenPanel(Connetion, quickKey)
	local function Callback(g_GameMain,uButton)
		g_GameMain.m_MsgBox = nil
		return true
	end
	if linkfun[quickKey] == nil then
		g_GameMain.m_MsgBox = MessageBox(g_GameMain, MsgBoxMsg(402), MB_BtnOK,Callback,g_GameMain)
		return
	end
	linkfun[quickKey]()
end

--���۽���������
function ConsignmentWnd()
	if g_GameMain.m_CSMSellOrderWnd:IsShow() == false then
		g_GameMain.m_CSMSellOrderWnd:ShowWnd(true)
	else
		g_GameMain.m_CSMSellOrderWnd:ShowWnd(false)
	end
	g_GameMain.m_CSMSellOrderWnd:SendSearchInfo()
end	

function CofCNpcDialogWnd()
	Gac2Gas:OpenCofCNpcDialog(g_Conn,0)
end

function OpenCofCWnd()
	if g_GameMain.m_CofCMainWnd == nil or g_GameMain.m_CofCMainWnd:IsShow()  == false then
		if g_GameMain.m_CofCMainWnd == nil then
			g_GameMain.m_CofCMainWnd = CreateChamberOfCommerce(g_GameMain)
			g_GameMain.m_CofCMainWnd:ShowWnd(true)
		elseif g_GameMain.m_CofCMainWnd:IsShow() == false then
			g_GameMain.m_CofCMainWnd:ShowWnd(true)
		end
		local AutoCloseWnd = CAutoCloseWnd:new()
		AutoCloseWnd:AutoCloseWnd(g_GameMain.m_CofCMainWnd)
		
		local cofc_id	=	g_MainPlayer.m_Properties:GetCofcID()
		Gac2Gas:GetCofcInfo(g_Conn, cofc_id)
	end
end

function OpenCofCStockWnd()
	if g_GameMain.m_CofCMainStockWnd == nil then
		g_GameMain.m_CofCMainStockWnd = CreateStockMainWnd(g_GameMain)
		g_GameMain.m_CofCMainStockWnd:ShowWnd(true)
	elseif g_GameMain.m_CofCMainStockWnd:IsShow() == false then
		g_GameMain.m_CofCMainStockWnd:ShowWnd(true)
	end
	Gac2Gas:GetCofCStockInfo(g_Conn)
end

function OpenContractManufactureWnd()
    CContractManufactureMarketWnd.OpenContractManufMarketWnd()
end

function OpenSuperaddWnd()
    CEquipSuperaddWnd.OpenSuperaddWnd()
end

function OpenItemBagLockWnd()
	if g_MainPlayer.m_ItemBagLock then
		g_GameMain.m_ItemBagTimeLockWnd:ShowWnd(true)
	else
		Gac2Gas:OpenItemBagLockWnd(g_Conn)
	end
end

function OpenBuyCouponsWnd()
    CBuyCouponsWnd.OpenBuyCouponsWnd()
end