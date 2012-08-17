CFbActionQueueWnd = class(SQRDialog)
local CFbActionQueueBtnWnd = class(SQRDialog)

cfg_load "fb_game/MatchGame_Common"
cfg_load "fb_game/JuQingTransmit_Common"

--�Ŷ�����ϵ�����Ϣ start===========================================
local CQueueRowColWnd = class(SQRDialog)

local function SetWndRect(ParentWnd,Wnd,Height)
	local rt = CFRect:new()
	ParentWnd:GetLogicRect(rt)
	rt.bottom = rt.top + Height
	Wnd:SetLogicRect(rt)
end

local function CreateQueueRowColWnd(parent,FbName,Height)
	local Wnd = CQueueRowColWnd:new()
	Wnd:CreateFromRes("FbActionRowColWnd",parent) 
	Wnd.m_Name = Wnd:GetDlgChild("FbName")
	Wnd.m_Type = Wnd:GetDlgChild("FbType")
	Wnd.m_Info = Wnd:GetDlgChild("FbInfo")
	Wnd.m_JoinInBtn = Wnd:GetDlgChild("JoinInFb")
	Wnd.m_ExitBtn = Wnd:GetDlgChild("ExitFb")
	Wnd.m_ItemType = FbName
	
	Wnd.m_ExitBtnType = nil	--����ָ����������,�����������
	
	if FbName then
		SetWndRect(parent,Wnd,Height)
	end
	
	Wnd:ShowWnd(true)
	return Wnd
end

function CQueueRowColWnd:OnCtrlmsg(Child, uMsgID, uParam1, uParam2 )
	if uMsgID == BUTTON_LCLICK then
		if Child == self.m_JoinInBtn then
			--ɾ����Ϣȷ�ϴ���
			--self:DeleteMsgWnd(self.m_ItemType)
			self:SendSuccJoinInEventFun(self.m_ItemType)
		elseif Child == self.m_ExitBtn then
			if not self.m_ExitBtnType then
				self:SendCancelJoinEventFun(self.m_ItemType)
			else
				local function IsGiveUpGame(Wnd,uButton)
					if uButton == MB_BtnOK then
						--ɾ����Ϣȷ�ϴ���
						Wnd:DeleteMsgWnd(Wnd.m_ItemType)
						Wnd:SendCancelJoinEventFun(Wnd.m_ItemType)
					end
					g_GameMain.m_MsgBox = nil
					return true
				end
				local ShowInfo = MsgBoxMsg(5004)
				g_GameMain.m_MsgBox = MessageBox(g_GameMain, ShowInfo, BitOr( MB_BtnOK, MB_BtnCancel), IsGiveUpGame, self)
			end
		end
	end
end

function CQueueRowColWnd:SetAllChildWndText(InfoTextTbl)
	self.m_Name:SetWndText(g_GetFbActionNameLanStr(InfoTextTbl[1]))
	self.m_Type:SetWndText(InfoTextTbl[2])
	self.m_Info:SetWndText(InfoTextTbl[3])
	self.m_JoinInBtn:SetWndText(InfoTextTbl[4])
	self.m_ExitBtn:SetWndText(InfoTextTbl[5])
	self.m_JoinInBtn:EnableWnd(InfoTextTbl[6])--false)
	self.m_ExitBtn:EnableWnd(InfoTextTbl[7])--true)
	self.m_ExitBtnType = InfoTextTbl[8]
end

function CQueueRowColWnd:SetInfoBtnText(sText)
	self.m_Info:SetWndText(sText)
end

function CQueueRowColWnd:SetJoinInBtn(IsEnable)
	self.m_JoinInBtn:EnableWnd(IsEnable)
end

function CQueueRowColWnd:SetJoinInBtnText(sText)
	self.m_JoinInBtn:SetWndText(sText)
end

function CQueueRowColWnd:SetExitBtn(sText)
	self.m_ExitBtnType = true
	self.m_ExitBtn:SetWndText(sText)
end

function CQueueRowColWnd:DeleteMsgWnd(FbName)
	if g_GameMain.m_FbActionMsgWnd[FbName] then
		g_GameMain.m_FbActionMsgWnd[FbName]:DeleteTick(FbName)
	end
end

--������Ϣ��,ͬ�����
function CQueueRowColWnd:SendSuccJoinInEventFun(FbName)
	Gac2Gas:AgreeJoinFbAction(g_Conn,FbName)
end

--�������ں�,ȡ������
function CQueueRowColWnd:SendCancelJoinEventFun(FbName)
	Gac2Gas:NotJoinFbAction(g_Conn,FbName)
end
--�Ŷ�����ϵ�����Ϣ end===========================================





--=============================================
--���Ŷ����İ�Ť
function CFbActionQueueBtnWnd:Ctor(parent)
	self:CreateFromRes("FbActionQueueBtnWnd",parent) 
	self.m_ShowBtn = self:GetDlgChild("ShowBtn")
end

function CFbActionQueueBtnWnd:GetWnd()
	local Wnd = g_GameMain.m_FbActionQueueBtnWnd
	if not Wnd then
		Wnd = CFbActionQueueBtnWnd:new(g_GameMain)
		g_GameMain.m_FbActionQueueBtnWnd = Wnd
	end
	return Wnd
end

function CFbActionQueueBtnWnd:OnCtrlmsg(Child, uMsgID, uParam1, uParam2 )
	if uMsgID == BUTTON_LCLICK then
		if Child == self.m_ShowBtn then
			local FbActionQueueWnd = CFbActionQueueWnd.GetWnd()
			FbActionQueueWnd:ShowWindow()
		end
	end
end
--=============================================


function CFbActionQueueWnd:Ctor(parent)
	self:CreateFromRes("FbActionQueueWnd",parent) 
	self.m_Title = self:GetDlgChild("Title")
	self.m_CloseBtn = self:GetDlgChild("CloseBtn")
	self.m_InfoList = self:GetDlgChild("ListCtrl")
	
	self:InitWindow()
	
	g_ExcludeWndMgr:InitExcludeWnd(self, 1)
	self:ShowWnd(false)
end

function CFbActionQueueWnd:GetWnd()
	local Wnd = g_GameMain.m_FbActionQueueWnd
	if not Wnd then
		Wnd = CFbActionQueueWnd:new(g_GameMain)
		g_GameMain.m_FbActionQueueWnd = Wnd
	end
	return Wnd
end

function CFbActionQueueWnd:OnCtrlmsg(Child, uMsgID, uParam1, uParam2 )
	if uMsgID == BUTTON_LCLICK then
		if Child == self.m_CloseBtn then
			--�رմ���
			self:ShowWnd(false)
			--self:ShowWnd(false)
		end
	end
end

function CFbActionQueueWnd:ShowWindow()
	local ItemCount = self.m_InfoList:GetItemCount()
	if ItemCount > 0 then
		if self:IsShow() then
			self:ShowWnd(false)
			--self:ShowWnd(false)
		else
			self:ShowWnd(true)
			--self:ShowWnd(true)
		end
	end
end

function CFbActionQueueWnd:InitWindow()
	self.m_Title:SetWndText(GetStaticTextClient(1011))
	self.m_InfoList:DeleteAllItem()
	
	--��������,ÿһ�еĿ��
	local Wnd = CreateQueueRowColWnd(self)
	local ChildWndRect = CFRect:new()
	Wnd:GetLogicRect(ChildWndRect)
	Wnd:DestroyWnd()
	
	self.m_ListWidth = ChildWndRect.right - ChildWndRect.left
	self.m_ItemHeight = ChildWndRect.bottom - ChildWndRect.top
	
	--self.m_InfoList:SetWndWidth(self.m_ListWidth)
	
	self:InitListWnd()
end

function CFbActionQueueWnd:InitListWnd()

	self.m_InfoList.m_ItemTbl = {}--��¼�е���Ϣ
	self.m_InfoList:InsertColumn(0,self.m_ListWidth)
end

function CFbActionQueueWnd:InsertListItem(FbTypeID, RowInfoTbl)
	self:DeleteListItem(FbTypeID)
	local ItemCount = self.m_InfoList:GetItemCount()
	self.m_InfoList:InsertItem(ItemCount, self.m_ItemHeight)
	local Item = self.m_InfoList:GetSubItem(ItemCount, 0)
	
	self.m_InfoList.m_ItemTbl[ItemCount+1] = CreateQueueRowColWnd(Item,FbTypeID,self.m_ItemHeight)
	self.m_InfoList.m_ItemTbl[ItemCount+1].m_FbTypeID = FbTypeID
	self.m_InfoList.m_ItemTbl[ItemCount+1].m_RowInfoTbl = RowInfoTbl
	self.m_InfoList.m_ItemTbl[ItemCount+1]:SetAllChildWndText(RowInfoTbl)
	
	local Wnd = CFbActionQueueBtnWnd.GetWnd()
	Wnd:ShowWnd(true)
end

function CFbActionQueueWnd:DeleteListItem(FbTypeID)
	local ItemTbl = {}
	ItemTbl = self.m_InfoList.m_ItemTbl
	self.m_InfoList:DeleteAllItem()
	for ItemNum,_ in pairs(ItemTbl) do
		self.m_InfoList.m_ItemTbl[ItemNum]:DestroyWnd()
	end
	
	self:InitListWnd()
	
	for ItemNum,_ in pairs(ItemTbl) do
		if ItemTbl[ItemNum].m_FbTypeID == FbTypeID then
			ItemTbl[ItemNum] = nil
		else
			self:InsertListItem(ItemTbl[ItemNum].m_FbTypeID, ItemTbl[ItemNum].m_RowInfoTbl)
		end
	end
	
	local ItemCount = self.m_InfoList:GetItemCount()
	if ItemCount == 0 then
		self:ShowWnd(false)
		--self:ShowWnd(false)
		local Wnd = CFbActionQueueBtnWnd.GetWnd()
		Wnd:ShowWnd(false)
	end
end

function CFbActionQueueWnd:SetInfoBtnText(FbTypeID,sText)
	local ItemTbl = self.m_InfoList.m_ItemTbl
	for ItemNum,_ in pairs(ItemTbl) do
		if ItemTbl[ItemNum].m_FbTypeID == FbTypeID then
			ItemTbl[ItemNum].m_RowInfoTbl[3] = sText
			ItemTbl[ItemNum]:SetInfoBtnText(sText)
			break
		end
	end
end

function CFbActionQueueWnd:SetJoinInBtn(FbTypeID,IsEnable)
	local ItemTbl = self.m_InfoList.m_ItemTbl
	for ItemNum,_ in pairs(ItemTbl) do
		if ItemTbl[ItemNum].m_FbTypeID == FbTypeID then
			ItemTbl[ItemNum].m_RowInfoTbl[6] = IsEnable
			ItemTbl[ItemNum]:SetJoinInBtn(IsEnable)
			break
		end
	end
end

function CFbActionQueueWnd:SetJoinInBtnText(FbTypeID,sText)
	local ItemTbl = self.m_InfoList.m_ItemTbl
	for ItemNum,_ in pairs(ItemTbl) do
		if ItemTbl[ItemNum].m_FbTypeID == FbTypeID then
			ItemTbl[ItemNum].m_RowInfoTbl[6] = sText
			ItemTbl[ItemNum]:SetJoinInBtnText(sText)
			break
		end
	end
end

function CFbActionQueueWnd:SetExitBtn(FbTypeID,sText)
	local ItemTbl = self.m_InfoList.m_ItemTbl
	for ItemNum,_ in pairs(ItemTbl) do
		if ItemTbl[ItemNum].m_FbTypeID == FbTypeID then
			ItemTbl[ItemNum].m_RowInfoTbl[5] = sText
			ItemTbl[ItemNum].m_RowInfoTbl[8] = true
			ItemTbl[ItemNum]:SetExitBtn(sText)
			break
		end
	end
end

function CFbActionQueueWnd:EnableExitBtn(FbTypeID, isEnable)
	
	local ItemTbl = self.m_InfoList.m_ItemTbl
	for ItemNum,_ in pairs(ItemTbl) do
		if ItemTbl[ItemNum].m_FbTypeID == FbTypeID then
			ItemTbl[ItemNum].m_RowInfoTbl[7] = isEnable
			ItemTbl[ItemNum].m_ExitBtn:EnableWnd(isEnable)
			break
		end
	end
end

function CFbActionQueueWnd:FindAciont(FbTypeID)
	local ItemTbl = self.m_InfoList.m_ItemTbl
	for ItemNum,_ in pairs(ItemTbl) do
		if ItemTbl[ItemNum].m_FbTypeID == FbTypeID then
			return true
		end
	end
	return false
end



----------------�Ŷ������Ϣ----------------
local function RetFbQueueWndInfo(FbName, IsTeam, sManNum)
	
	local Show1 = GetStaticTextClient(9407)
	local Show2 = GetStaticTextClient(9408)
	local Show3 = GetStaticTextClient(9409)
	local Show4 = GetStaticTextClient(9410)
	local Show5 = GetStaticTextClient(9411)
	local Show6 = GetStaticTextClient(9412)
	local Show7 = GetStaticTextClient(9439)
	local Show8 = GetStaticTextClient(9440)
	local Show9 = GetStaticTextClient(9441)
	local Show10 = GetStaticTextClient(9447)
	local Show11 = GetStaticTextClient(9448)
	
	local FbQueueWndTbl = {FbName,Show1,Show3,Show4,Show5,false,true,nil}
	
	if IsTeam == 2 then
		FbQueueWndTbl[2] = Show2
	elseif IsTeam == 3 then
		FbQueueWndTbl[2] = Show7
		FbQueueWndTbl[3] = Show9
	elseif IsTeam == 4 then
		FbQueueWndTbl[2] = Show2
		FbQueueWndTbl[3] = Show10
	elseif IsTeam == 5 then
		FbQueueWndTbl[2] = Show2
		FbQueueWndTbl[3] = Show11
	else
		if sManNum and IsNumber(sManNum) then
			FbQueueWndTbl[3] = Show6 .. sManNum
		end
	end
	return FbQueueWndTbl
end

--���� Type{{1,����},{2,����},{3,���}}
function CFbActionQueueWnd:RetInsertFbActionToQueue(FbName,IsTeam,PeopleNum)
	if FbName == "������" then
		IsTeam = 2
	elseif JuQingTransmit_Common(FbName) then
		IsTeam = 4
	elseif MatchGame_Common(FbName) then
		if MatchGame_Common(FbName,"AutoTeamPlayerNumber") ~= "" then
			if MatchGame_Common(FbName,"MaxTeams") == 1 then
				IsTeam = 4
			else
				IsTeam = 5
			end
		end
--	elseif FbName == "������Դ��" then
--		IsTeam = 3
	end
	local strTbl = RetFbQueueWndInfo(FbName, IsTeam, PeopleNum)
	if strTbl then
		self:InsertListItem(FbName,strTbl)
	end
	local FbActionQueueWnd = CFbActionQueueWnd.GetWnd()
	FbActionQueueWnd:ShowWindow()
end

--ɾ��
function CFbActionQueueWnd:RetDelQueueFbAction(FbName, DoDeleteList)
	if DoDeleteList then
		self:DeleteListItem(FbName)
	else
		self:SetJoinInBtn(FbName, false)
		self:SetInfoBtnText(FbName, GetStaticTextClient(9447))
		self:SetExitBtn(FbName, GetStaticTextClient(9411))
	end
	if g_GameMain.m_FbActionMsgWnd[FbName] then
		g_GameMain.m_FbActionMsgWnd[FbName]:DeleteTick(FbName)
	end
end

function CFbActionQueueWnd:RetSetJoinBtnEnable(FbName)
	if g_GameMain.m_FbActionMsgWnd[FbName] then
		g_GameMain.m_FbActionMsgWnd[FbName]:DeleteTick(FbName)
	end
	
	local ShowInfo = GetStaticTextClient(9405)
	self:SetExitBtn(FbName, ShowInfo)
	self:SetJoinInBtn(FbName,false)
	self:EnableExitBtn(FbName, true)
	ShowInfo = GetStaticTextClient(9406)
	self:SetInfoBtnText(FbName, ShowInfo)
	self:ShowWnd(false)
	--self:ShowWnd(false)
end

--����ɱ�еȴ�������
function CFbActionQueueWnd:RetInFbActionPeopleNum(FbName,PeopleNum)
	local ShowInfo = GetStaticTextClient(9412)
	local sManNum = ShowInfo .. PeopleNum
	self:SetInfoBtnText(FbName,sManNum)
end

function CFbActionQueueWnd:WaitOtherTeammate(actionName)
	MsgClient(191013, actionName)
	if g_GameMain.m_FbActionMsgWnd[actionName] then
		g_GameMain.m_FbActionMsgWnd[actionName]:SetShowWnd(false)
	end
	g_GameMain.m_FbActionMsgWnd[actionName].m_WaitOtherTeammate = true
	
	local ShowInfo = GetStaticTextClient(9442)
	self:SetInfoBtnText(actionName, ShowInfo)
	self:SetJoinInBtn(actionName,false)
	ShowInfo = GetStaticTextClient(9441)
	self:SetJoinInBtnText(actionName,ShowInfo)
end

function CFbActionQueueWnd:ChangeActionWarModel()
	g_MainPlayer:ChangeWarModel()
end
