gac_gas_require "framework/common/CMoney"
cfg_load "sort/SortList_Common"
lan_load "sort/Lan_SortList_Common"

CSortList = class( SQRDialog ) --������
CSortItem = class( SQRDialog )
------------------------------------------------
--1.Ӷ��С������ (С�ӵȼ����С�С���������С�С�Ӿ������С�С���ʽ�����)

--2.������������
--3.��������(ʤ���������С���ʤ�������С�ɱ����������)
--4.Χ���������(С�ӻ�ɱ�����������С���һ�ɱ������������)
--5.��Դ������(��Դ��ռ��������С�ɱ����������)

local nRowNum = 10

local tblPersonal = {}
	tblPersonal["�ȼ�"]					= GetStaticTextClient(1030)
	tblPersonal["�Ƹ�"]					= GetStaticTextClient(22014)
	tblPersonal["����"]					= GetStaticTextClient(22024)
	tblPersonal["�ۼ�ɱ��"]				= GetStaticTextClient(22025)
	tblPersonal["����ʱ��"]				= GetStaticTextClient(22026)
	tblPersonal["�Ƕ����ܲ�������"]		= GetStaticTextClient(22027)
	tblPersonal["ɱ��"]					= GetStaticTextClient(22029)
	tblPersonal["�Ƕ�����ʤ������"]		= GetStaticTextClient(22028)
	tblPersonal["�Ƕ����ܻ���"]			= GetStaticTextClient(22030)
	tblPersonal["ս����������"]			= GetStaticTextClient(22033)
	
	
local function MoneyTrans(nMoney)
	return g_MoneyMgr:ChangeMoneyToString(nMoney, true)
end

local function TimeTrans(nTime)
	return g_CTimeTransMgr:FormatTimeDH(nTime)
end

local function ClassTrans(nClass)
	return g_GameMain.m_DisplayCommonObj:GetPlayerClassForShow(nClass)
end

local function TongTypeTrans(nType)
	return g_GameMain.m_DisplayCommonObj:GetTongTypeName(nType)
end
	
local fl_tblTransFunc = {}
	fl_tblTransFunc["Ǯ"]		= MoneyTrans
	fl_tblTransFunc["ʱ��"]		= TimeTrans
	fl_tblTransFunc["ְҵ"]		= ClassTrans
	fl_tblTransFunc["С������"]	= TongTypeTrans
	
function CSortList:Ctor()
	self:CreateFromRes( "SortListWnd", g_GameMain )
	self:Init()
	g_ExcludeWndMgr:InitExcludeWnd(self, "�ǻ���")
end

function CSortList:OnChildCreated()
	self.m_close			= self:GetDlgChild("close")
	self.m_Personal			= self:GetDlgChild("Personal")
	self.m_YongbingGroup	= self:GetDlgChild("YongbingGroup")
	self.m_PlayFunc			= self:GetDlgChild("PlayFunc")
	self.m_UpPage			= self:GetDlgChild("UpPage")
	self.m_DownPage			= self:GetDlgChild("DownPage")
	self.m_SortTree			= self:GetDlgChild("SortTree")		--���а�
	self.m_SortList			= self:GetDlgChild("SortList")		--���а��б�
	self.m_Page				= self:GetDlgChild("Page")			--ҳ��
	self.m_ShowSort			= self:GetDlgChild("ShowSort")		--�������ʾ��Ϣ����
	
	self.m_tblRadio 		= {self:GetDlgChild("AmyEmpery"), self:GetDlgChild("FaNuoSi"), self:GetDlgChild("EMoDao"), self:GetDlgChild("All")}
	self.m_tblRadio[4]:SetCheck(true) --��ʼѡ�С�ȫ������ѡ��ť(Ҫ��self.m_nCampType��Ӧ����)
	self.m_Personal:SetCheck(true)
	
	self.m_tblLabel	= {}
	for i = 3, 5 do
		self.m_tblLabel[i] = self:GetDlgChild("Lable" .. i)
	end
end

function CSortList:Init()
	self.m_nCampType		= 4	--4:ȫ��;1:����;2��ŵ˹;3��ħ��
	self.m_SortListTbl		= {}
	self.m_tblSortListItem	= {}
	self:SetPage(1)
	self.m_ShowSort:SetWndText(GetStaticTextClient(1070) .. ": --")
	self.m_ShowSort:ShowWnd(false)
	self:CreateTree("����")
end

function CSortList:BeOpenPanel()
	local bFlag = not self:IsShow()
	if( bFlag ) then
		self:GetSortList()
	end
	self:ShowWnd(bFlag)
end

function CSortList:OnCtrlmsg( Child, uMsgID, uParam1, uParam2 )
	if (uMsgID == BUTTON_LCLICK) then
		if(Child == self.m_close)then
			self:ShowWnd(false)
		elseif(Child == self.m_Personal) then
			self:CreateTree("����")
			self:GetSortList()
		elseif(Child == self.m_YongbingGroup) then
			self:CreateTree("Ӷ��С��")
			self:GetSortList()
		elseif(Child == self.m_PlayFunc) then
			self:CreateTree("�淨")
			self:GetSortList()
		elseif(Child == self.m_UpPage) then--��һҳ
			if(self.m_PageNumber > 1)then
				self:SetPage(self.m_PageNumber - 1)
				self:DrawSortList()--ˢ����һҳ
			end
		elseif(Child == self.m_DownPage) then--��һҳ
			if(self.m_PageNumber < #(self.m_SortListTbl)/nRowNum)then
				self:SetPage(self.m_PageNumber + 1)
				self:DrawSortList()--ˢ����һҳ
			end
		else
			for i = 1, #(self.m_tblRadio) do --ѡ����ʾ��һ����Ӫ
				if(Child == self.m_tblRadio[i]) then
					self.m_nCampType = i
					self:GetSortList()
					break
				end
			end
		end
	elseif(uMsgID == ITEM_LBUTTONCLICK) then
		if(Child == self.m_SortTree) then
			self:GetSortList()
		end
	end
end

function CSortList:DrawSortList()
	self.m_SortList:DeleteAllItem()
	self.m_tblSortListItem = {}
	self.m_SortList:InsertColumn( 0, self.m_SortList:GetWorkAreaOrgWidth() )
	local beforeIndex = (self.m_PageNumber-1)*nRowNum
	local lastPageNum = #self.m_SortListTbl-beforeIndex
	local iEnd  = nRowNum > lastPageNum and lastPageNum or nRowNum
	for i = 1, iEnd do
		self.m_SortList:InsertItem(i-1, 28)
		local item		= self.m_SortList:GetSubItem(i-1, 0)
		local itemWnd	= self:CreateSortItem(item)
		itemWnd:CopyMsg2Wnd(self.m_SortListTbl[i+beforeIndex])
		self.m_tblSortListItem[i] = itemWnd
	end
end

function CSortList:CreateTree(sType)
	self.m_sType = sType
	self:SetPage(1)
	self.m_tblTreeItem = {}
	self.m_SortTree:DeleteAllItem()
	self.m_SortTree:InsertColumn( 0, self.m_SortTree:GetWorkAreaOrgWidth() )
	local subNode = SortList_Common(sType)
	for i, v in ipairs( subNode:GetKeys() ) do
		self.m_SortTree:InsertItem(i-1, 20)
		local item	= self.m_SortTree:GetSubItem(i-1, 0)
		item.m_Name	= v
		item:SetWndText(Lan_SortList_Common(MemH64(sType .. v), "DisplayName"))
		self.m_tblTreeItem[i] = item
	end
end

function CSortList:SetPage(page)
	self.m_PageNumber = page
	self.m_Page:SetWndText(page)
end

function CSortList:GetSortList()
	if not g_MainPlayer then return end
	local itemIndex = self.m_SortTree:GetSelectItem(-1)+1
	if (not itemIndex or 0 == itemIndex) then return end
	self:SetPage(1)
	
	local sName = self.m_tblTreeItem[itemIndex].m_Name
	local lanIndex	= MemH64(self.m_sType .. sName)
	
	for k, v in pairs(self.m_tblLabel) do
		local sLabel = Lan_SortList_Common(lanIndex, "DisLabel" .. k)
		v:SetWndText(sLabel)
	end
	
	self.m_ShowSort:ShowWnd(sName ~= "�������")
	Gac2Gas:GetSortList(g_Conn, self.m_sType, sName, self.m_nCampType)
end

function CSortList:FuncFormat(sType, sName)
	local tbl = self.m_SortListTbl
	if(next(tbl)) then
		if("����" == sType and "�������" == sName) then
			for i, v in ipairs(tbl) do
				if(v[3] == "����ʱ��") then
					v[5] = TimeTrans(v[5])
				elseif(v[3] == "�Ƹ�") then
					v[5] = MoneyTrans(v[5])
				end
				v[3] = tblPersonal[v[3]]
				v[4] = ClassTrans(v[4])
			end
		else
			local sFunc4 = SortList_Common(sType, sName, "Func4")
			local sFunc5 = SortList_Common(sType, sName, "Func5")
			for i = 1, #tbl do
				local func = fl_tblTransFunc[sFunc4]
				tbl[i][4] = func(tbl[i][4])
				if(sFunc5 and "" ~= sFunc5) then
					func = fl_tblTransFunc[sFunc5]
					tbl[i][5] = func(tbl[i][5])
				end
			end
		end
	end
end

function CSortList:RetSortListBegin()
	self.m_SortListTbl = {}
	self.m_ShowSort:SetWndText(GetStaticTextClient(1070) .. ": --")
end

function CSortList:RetSortList(order, up, name, vocation, value)
	local sCharName = g_MainPlayer.m_Properties:GetCharName()
	if name == sCharName then
		self.m_ShowSort:SetWndText(GetStaticTextClient(1070) .. ": " .. order)
	end
	table.insert(self.m_SortListTbl, {order, up, name, vocation, value})
end

function CSortList:RetSortListEnd(sType, sName)
	self:FuncFormat(sType, sName)
	self:DrawSortList()
end
-----------------------------------------------------
function CSortList:CreateSortItem(parent)
	local wnd = CSortItem:new()
	wnd:CreateFromRes("SortItem", parent)
	wnd:ShowWnd( true )
	return wnd
end

function CSortItem:OnChildCreated()
	self.m_tblItem = {}
	for i = 1, 5 do
		self.m_tblItem[i] = self:GetDlgChild("Item" .. i)
	end
end

--����Item����Ϣ
function CSortItem:CopyMsg2Wnd(tbl)
	for i = 1, #tbl do
		self.m_tblItem[i]:SetWndText(tbl[i])
	end
end