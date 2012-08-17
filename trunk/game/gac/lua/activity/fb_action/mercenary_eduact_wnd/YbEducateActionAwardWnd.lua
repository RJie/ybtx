CYbEducateActionAwardWnd = class(SQRDialog)
local m_FbName = "Ӷ��ѵ���"

function CYbEducateActionAwardWnd:Ctor()
	self:CreateFromRes("Fb_ActionInfoEndWnd", g_GameMain) 
	self.m_ListInfo = self:GetDlgChild("ItemList")
	self.m_OkBtn = self:GetDlgChild("OkBtn")
end

--���������Ľ�����Ϣͳ��==================================
local function GetWndWidth(ChildWnd)
	local rt = CFRect:new()
	ChildWnd:GetLogicRect(rt)
	local width = rt.right-rt.left
	return width
end

function CYbEducateActionAwardWnd:InitListInfo()
	local Width = GetWndWidth(self.m_ListInfo)
	self.m_ListInfo:DeleteAllItem()
	self.m_ListInfo:InsertColumn(0,Width*0.5)
	self.m_ListInfo:InsertColumn(1,Width*0.5)
end

function CYbEducateActionAwardWnd:InsertListInfo(ItemName, ItemNum)
	if ItemName and ItemNum then
		local ItemCount = self.m_ListInfo:GetItemCount()
		self.m_ListInfo:InsertItem(ItemCount, 30)
		local Item1 = self.m_ListInfo:GetSubItem(ItemCount, 0)
		--local itemWnd = self:CreateListItem(Item)
		--local Flag = IMAGE_PARAM:new(SM_BS_BK, IP_ENABLE)
		--itemWnd:SetWndTextColor(Flag,TextColor)
		if ItemName == "�ܾ���" then
			ItemName = GetStaticTextClient(8812)
		elseif ItemName == "�ܽ�Ǯ" then
			ItemName = GetStaticTextClient(8813)
		elseif ItemName == "�ܻ�ֵ" then
			ItemName = GetStaticTextClient(8814)
		elseif ItemName == "���⾭��" then
			ItemName = GetStaticTextClient(8815)
		end
		
		Item1:SetWndText(ItemName)
		local Item2 = self.m_ListInfo:GetSubItem(ItemCount, 1)
		Item2:SetWndText(ItemNum)
	end
end

function CYbEducateActionAwardWnd:OnCtrlmsg(Child, uMsgID, uParam1, uParam2 )
	if uMsgID == BUTTON_LCLICK then
		if Child == self.m_OkBtn then
			Gac2Gas:NotJoinFbAction(g_Conn,m_FbName)
			--�رմ���
			self:CloseWnd()
		end
	end
end

function CYbEducateActionAwardWnd:CloseWnd()
	UnRegisterTick(self.m_DownTick)
	self.m_DownTick = nil
	--�رմ���
	self:ShowWnd(false)
end

function CYbEducateActionAwardWnd:InfoWnd(DownTime)
	local BtnName = GetStaticTextClient(1117)--��ʼ
	local function DownTimeFun()
		DownTime = DownTime - 1
		if DownTime <= 0 then
			--�رմ���
			self:CloseWnd()
		else
			self.m_OkBtn:SetWndText(BtnName.."("..DownTime..")")
		end
	end
	self.m_OkBtn:SetWndText(BtnName.."("..DownTime..")")
	if self.m_DownTick then
		UnRegisterTick(self.m_DownTick)
	end
	self.m_DownTick = RegisterTick("YbActionAwardWnd",DownTimeFun,1000)
	self:ShowWnd(true)
end