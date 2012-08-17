gac_require "item/boxitem/BoxItemInc"

--�Ҽ���������еĺ�����Ʒ���ӷ���˷��غ�������Ʒ�Ŀ�ʼ
function Gas2Gac:RetGetBoxitemInfoBegin(Conn)
	g_GameMain.m_BoxitemPickupWnd.m_PickupItemInfoTbl	=	{}	--��ʼ�����ڼ�¼������Ʒ����Ϣ��
end

--�Ҽ���������еĺ�����Ʒ���ӷ���˷��غ�������Ʒ��Ϣ
--ÿ��ֻ����һҳ�е���Ʒ��ϢitemIndexΪ�������Ʒ�����ݱ����ˮ��
function Gas2Gac:RetGetBoxitemInfo(Conn, itemIndex, itemType, itemName, itemCount)
	local node		=	{}
	node.ItemIndex	=	itemIndex
	node.ItemType	=	tonumber(itemType)					--��Ʒ����
	node.ItemName	=	itemName					--��Ʒ����
	node.ItemCount	=	itemCount					--��Ʒ����
	
	table.insert(g_GameMain.m_BoxitemPickupWnd.m_PickupItemInfoTbl, node)
end

function Gas2Gac:RetGetBoxitemInfoEnd(Conn, totalPageNo, curPageNo, boxitemID)
	g_GameMain.m_BoxitemPickupWnd.m_CurPageNo	=	curPageNo		--������Ʒ��ҳ��
	g_GameMain.m_BoxitemPickupWnd.m_TotalPageNo	=	totalPageNo		--��ǰ������Ʒ��ʾ�ĵڼ�ҳ
	g_GameMain.m_BoxitemPickupWnd.m_BoxitemID	=	boxitemID
	g_GameMain.m_BoxitemPickupWnd:ShowWnd(true)
	g_GameMain.m_BoxitemPickupWnd:ShowBoxitemDetails()				--��ʾ���ӵ�ǰ��ʾ����Ʒ��Ϣ
	--�������д洢������Ʒ��λ����Ϊ���ɵ��
	g_GameMain.m_BoxitemPickupWnd:EnableBoxItemRelatedGrid(false)
end

function Gas2Gac:RetTakeAllBoxitemDrop(Conn, boxitemID)
--	if g_GameMain.m_BoxitemPickupWnd.m_FinishAnswer ~= nil then
--		if g_GameMain.m_BoxitemPickupWnd.m_FinishAnswer[boxitemID] ~= nil then
--			g_GameMain.m_BoxitemPickupWnd.m_FinishAnswer[boxitemID] = nil 
--		end
--	end
	g_GameMain.m_BoxitemPickupWnd:ShowWnd(false)
	g_GameMain.m_BoxitemPickupWnd:EnableBoxItemRelatedGrid(true)
end

---------------------------------------------------------------------------------

--����������Ʒʰȡ����
function CreateBoxitemPickupWnd(Parent)
	local wnd	=	CBoxitemPickupWnd:new()
	wnd:CreateFromRes("WndCollObj",Parent)

	wnd:InitBoxitemPickupWndChild()
	g_ExcludeWndMgr:InitExcludeWnd(wnd, "�ǻ���")

	return wnd
end

--�ó�Ա�������������Ʒʰȡ�����еĿؼ�
function CBoxitemPickupWnd:InitBoxitemPickupWndChild()
	self.m_Close		=	self:GetDlgChild("WndClose")		--�رհ�ť
	self.m_LastPage		=	self:GetDlgChild("LastPage")		--��һҳ��ť
	self.m_NextPage		=	self:GetDlgChild("NextPage")		--��һҳ��ť
	self.m_WndGetAllItem=	self:GetDlgChild("WndGetAllItem")	--��ȡȫ����Ʒ��ť
	self.m_ItemName1	=	self:GetDlgChild("ItemName1")		--��1����Ʒ������ʾ����
	self.m_ItemName2	=	self:GetDlgChild("ItemName2")		--��2����Ʒ������ʾ����
	self.m_ItemName3	=	self:GetDlgChild("ItemName3")		--��3����Ʒ������ʾ����
	self.m_ItemName4	=	self:GetDlgChild("ItemName4")		--��4����Ʒ������ʾ����
	
	self.m_GetItemBtn1	=	self:GetDlgChild("GetItemBtn1")		--��1����Ʒ��btn
	local PicWnd1 = CBoxitemGridCut:new()  --���ڽ����ƷͼƬ�����е�����
	PicWnd1:CreateFromRes("CommonGridCut", self.m_GetItemBtn1)
	PicWnd1:ShowWnd( true )
	self.m_GetItemBtn1.m_PicWnd = PicWnd1
	
	self.m_GetItemBtn2	=	self:GetDlgChild("GetItemBtn2")		--��2����Ʒ��btn
	local PicWnd2 = CBoxitemGridCut:new()  --���ڽ����ƷͼƬ�����е�����
	PicWnd2:CreateFromRes("CommonGridCut", self.m_GetItemBtn2)
	PicWnd2:ShowWnd( true )
	self.m_GetItemBtn2.m_PicWnd = PicWnd2
	
	self.m_GetItemBtn3	=	self:GetDlgChild("GetItemBtn3")		--��3����Ʒ��btn
	local PicWnd3 = CBoxitemGridCut:new()  --���ڽ����ƷͼƬ�����е�����
	PicWnd3:CreateFromRes("CommonGridCut", self.m_GetItemBtn3)
	PicWnd3:ShowWnd( true )
	self.m_GetItemBtn3.m_PicWnd = PicWnd3
	
	self.m_GetItemBtn4	=	self:GetDlgChild("GetItemBtn4")		--��4����Ʒ��btn
	local PicWnd4 = CBoxitemGridCut:new()  --���ڽ����ƷͼƬ�����е�����
	PicWnd4:CreateFromRes("CommonGridCut", self.m_GetItemBtn4)
	PicWnd4:ShowWnd( true )
	self.m_GetItemBtn4.m_PicWnd = PicWnd4
end

function CBoxitemPickupWnd:VirtualExcludeWndClosed()
    self:EnableBoxItemRelatedGrid(true)
end

--������Ʒʰȡ�����¼���Ӧ����
function CBoxitemPickupWnd:OnCtrlmsg(Child, uMsgID, uParam1, uParam2)
	if uMsgID == BUTTON_LCLICK then
		if self.m_Close == Child then
			self:ShowWnd(false)
			self:EnableBoxItemRelatedGrid(true)
		
		elseif self.m_LastPage == Child then
			self.m_CurPageNo	=	self.m_CurPageNo - 1
			Gac2Gas:GetOnePageDropItem(g_Conn, self.m_BoxitemID, self.m_CurPageNo, self.m_TotalPageNo)
			
		elseif self.m_NextPage == Child then
			self.m_CurPageNo	=	self.m_CurPageNo + 1
			Gac2Gas:GetOnePageDropItem(g_Conn, self.m_BoxitemID, self.m_CurPageNo, self.m_TotalPageNo)
		
		elseif self.m_WndGetAllItem == Child then			--��ȡ�����е�������Ʒ
			Gac2Gas:TakeAllBoxitemDrop(g_Conn, self.m_BoxitemID)
			
		elseif self.m_GetItemBtn1 == Child then
			Gac2Gas:TakeOneDropItemByIndex(g_Conn, self.m_CurPageNo, self.m_PickupItemInfoTbl[1].ItemIndex, self.m_BoxitemID)
		
		elseif self.m_GetItemBtn2 == Child then
			
			Gac2Gas:TakeOneDropItemByIndex(g_Conn, self.m_CurPageNo, self.m_PickupItemInfoTbl[2].ItemIndex, self.m_BoxitemID )
	
		elseif self.m_GetItemBtn3 == Child then
			Gac2Gas:TakeOneDropItemByIndex(g_Conn, self.m_CurPageNo, self.m_PickupItemInfoTbl[3].ItemIndex, self.m_BoxitemID)
	
		elseif self.m_GetItemBtn4 == Child then
			Gac2Gas:TakeOneDropItemByIndex(g_Conn, self.m_CurPageNo, self.m_PickupItemInfoTbl[4].ItemIndex, self.m_BoxitemID)
			
		end	
	end
end

--��ʾ���ӵ�ǰ��ʾ����Ʒ��Ϣ
function CBoxitemPickupWnd:ShowBoxitemDetails()
	local boxitemTbl	=	self.m_PickupItemInfoTbl
	local boxitemTblLen	=	# boxitemTbl
	for i =1, boxitemTblLen do
		local ItemType,ItemName = boxitemTbl[i].ItemType, boxitemTbl[i].ItemName
		local SmallIcon		= g_ItemInfoMgr:GetItemInfo(ItemType,ItemName,"SmallIcon")
		local DisplayName	= g_ItemInfoMgr:GetItemLanInfo(ItemType,ItemName,"DisplayName")
		local iconWnd, nameWnd = self:GetAcurateItem(i)
		local PicWnd = iconWnd.m_PicWnd
		g_DelWndImage(PicWnd, 1, IP_ENABLE, IP_ENABLE)
		g_LoadIconFromRes(SmallIcon, PicWnd, -1, IP_ENABLE, IP_ENABLE)
		PicWnd:SetWndText(boxitemTbl[i].ItemCount)
		nameWnd:SetWndText(DisplayName)
		iconWnd:ShowWnd(true)
		nameWnd:ShowWnd(true)
	end
	for i=boxitemTblLen+1, 4 do				--������Ʒʰȡ���������ʾ4����Ʒ����Ϣ
		local iconWnd, nameWnd = self:GetAcurateItem(i)
		iconWnd:ShowWnd(false)
		nameWnd:ShowWnd(false)
	end
	
	----������Ʒ��ǰ������ʾҳ��ҳ�����������·�ҳ��ť�Ƿ�ɵ�
	if self.m_CurPageNo	== 1  then
		self.m_LastPage:EnableWnd(false)
	else
		self.m_LastPage:EnableWnd(true)
	end
	
	if self.m_CurPageNo < self.m_TotalPageNo then
		self.m_NextPage:EnableWnd(true)
	else
		self.m_NextPage:EnableWnd(false)
	end
end

--������Ʒʰȡ����е�1-4����Ʒ��ʾ�ؼ��о����ĳ��
--����������1-4�е�ĳ��ֵ��ȷ���ǵڼ����ؼ�
--����ֵ:��ʾ�ؼ���itemIconWnd, itemNameWnd
function CBoxitemPickupWnd:GetAcurateItem(wndIndex)
	if wndIndex == 1 then
		return self.m_GetItemBtn1, self.m_ItemName1
	
	elseif wndIndex == 2 then
		return self.m_GetItemBtn2, self.m_ItemName2

	elseif wndIndex == 3 then
		return self.m_GetItemBtn3, self.m_ItemName3
	
	elseif wndIndex == 4 then
		return self.m_GetItemBtn4, self.m_ItemName4
	end
end

--���ݴ����βΣ�����������Ʒ�ڰ����и��ӿɵ��״̬
function CBoxitemPickupWnd:EnableBoxItemRelatedGrid( bEnable )
	local clickBagGrid  = g_GameMain.m_BoxitemPickupWnd.m_ClickBagGrid
	local roomIndex, pos = clickBagGrid[1], clickBagGrid[2]
	local SrcCt = g_GameMain.m_BagSpaceMgr:GetSpaceRelateLc( g_StoreRoomIndex.PlayerBag )
	local cols = g_PlayerMainBag.columns
	local y,x = SrcCt:GetIndexByPos(pos, roomIndex)
	local item = SrcCt:GetSubItem(x, y)
	item:EnableWnd( bEnable )
end
