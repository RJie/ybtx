gac_require "fight/battle_array/BattleArrayMemPosInc"

function CreateBattleArrayMemPosWnd(Parent)
	local Wnd = CBattleArrayMemPosWnd:new()
	Wnd:Init(Parent)
	return Wnd
end

function CBattleArrayMemPosWnd:Init(Parent)
	self.m_MemNum				= 0
	self.m_bMemChanged			= true
	self.m_tblThisArrayPosInfo	= {}
	self.m_tblMemberInfo		= {}
	self.m_tblMemPosInfoTemp	= {{0,"",-1},{0,"",-1},{0,"",-1},{0,"",-1},{0,"",-1}}
	self.m_sArrayName			= ""
	self.m_tblGridWnd			= {}
	self:CreateFromRes("BattleArrayMemPos", Parent)
	self:ReDrawList()
end

function CBattleArrayMemPosWnd:OnChildCreated()
	self.m_XBtn				= self:GetDlgChild("XBtn")
	self.m_ArrayList		= self:GetDlgChild("ArrayList")
	self.m_OkBtn			= self:GetDlgChild("OkBtn")
	self.m_ResetBtn			= self:GetDlgChild("ResetBtn")
	self.m_CancelBtn		= self:GetDlgChild("CancelBtn")
	self.m_ArrayDes			= self:GetDlgChild("ArrayDes")
	self.m_PosByOrderBtn	= self:GetDlgChild("PosByOrderBtn")
	self.m_tblMemBtn		= {}
	self.m_tblNameLabel		= {}
	for i = 1, 5 do
		self.m_tblNameLabel[i]	= self:GetDlgChild("NameLabel" .. i)
		self.m_tblMemBtn[i]		= self:GetDlgChild("Mem" .. i)
		self.m_tblNameLabel[i]:ShowWnd(false)
		self.m_tblMemBtn[i]:ShowWnd(false)
	end
end

--��Ϣ
function CBattleArrayMemPosWnd:OnCtrlmsg(Child, uMsgID, uParam1, uParam2)
	if(uMsgID == BUTTON_LCLICK) then
		if(Child == self.m_XBtn or Child == self.m_CancelBtn) then
			local cursorState = g_WndMouse:GetCursorState()
			if(cursorState == ECursorState.eCS_PickupBattleArrayMember) then
				self:ClearCursor()
			end
			self:ShowWnd(false)
		elseif(Child == self.m_ResetBtn) then
			self:Reset()
		elseif(Child == self.m_OkBtn) then --��������
			self:SaveBattleArrayMemPos()
		elseif(Child == self.m_PosByOrderBtn) then --˳������
			self:Reset()
			self:PosByOrder()
		else
			self:StartDragBtn(Child)
		end
	elseif(uMsgID == BUTTON_RCLICK) then
		self:ClearCursor()
	elseif(uMsgID == BUTTON_DRAG) then
		self:StartDragBtn(Child)
	elseif(uMsgID == ITEM_LBUTTONCLICK) then
		if(Child == self.m_ArrayList) then
			local item = self.m_ArrayList:GetSubItem(uParam1, uParam2)
			local pos = uParam1*10 + uParam2
			self:LClickUpItem(item, pos)
		end
	end
end

--�ػ�list
function CBattleArrayMemPosWnd:ReDrawList()
	self.m_ArrayList:DeleteAllItem()
	for i = 0, 9 do self.m_ArrayList:InsertColumn(i, 32) end
	for i = 0, 9 do self.m_ArrayList:InsertItem(i, 32)   end
	self:DrawBG()
	self:DrawArrayListItem()
	for i = 0, 9 do
		for j = 0, 9 do
			local item = self.m_ArrayList:GetSubItem(i, j)
			item:EnableWnd(false)
		end
	end
end

--�򿪱����
function CBattleArrayMemPosWnd:OpenWnd(arrayName)
	if(not g_GameMain.m_TeamBase.m_bCaptain) then return end
	self.m_sArrayName = arrayName
	self:SetWndText(arrayName)
	self:FreshGridBtn()
	local base					= g_GameMain.m_BattleArrayBase
	local tblPos				= base.m_tblBattleArrayPos --������Ϣ��
	local tblMemPos				= base.m_tblBattleArrayMem --������Ϣ��
	local nameIndex				= base:GetArrayNameIndex(arrayName)
	local tblThisArrayPos		= tblPos[nameIndex]    --��ǰ��������Ϣ
	local tblThisArrayMemPos	= tblMemPos[nameIndex] --��ǰ��������Ϣ
	local memberInfo			= self.m_tblMemberInfo
	local tblBtnBeShow			= {}
	self.m_tblThisArrayPosInfo	= tblPos[nameIndex]
	self.m_tblMemPosInfoTemp	= {{0,"",-1},{0,"",-1},{0,"",-1},{0,"",-1},{0,"",-1}}
	if(tblThisArrayMemPos) then --�����������Ϣ
		for i = 1, 5 do
			for j = 1, 5 do
				if(0 ~= tblThisArrayMemPos[2][i] and tblThisArrayMemPos[2][i] == memberInfo[j][1]) then --��Id�����ң��øõ���Ա��Ϣ
--					local id	= tblThisArrayMemPos[2][i]
--					local name	= memberInfo[j][2]
--					local pos	= tblThisArrayPos[2][i]
--					self.m_tblMemPosInfoTemp[i] = {id, name, pos} --��ʼ��������ĳ�Ա��Ϣ
					tblBtnBeShow[j] = true
				end
			end
		end
	end
	self.m_MemNum = 0
	for i = 1, 5 do
		if(tblThisArrayPos) then --�����������Ϣ
			local item = self.m_ArrayList:GetSubItem(tblThisArrayPos[2][i]/10, tblThisArrayPos[2][i]%10)
			item:SetWndText(i)
			item:EnableWnd(true)
		end
		local isOn = false
		if(tblThisArrayMemPos) then --�����������Ϣ
			local id = tblThisArrayMemPos[2][i]
			if(0 ~= id) then		--���iλ������
				local isLeaveNow = true
				for j = 1, #(memberInfo) do
					if(id == memberInfo[j][1]) then --�жϴ����Ƿ��ڶ�����
						isLeaveNow = false
						g_WndMouse:SetPickupBattleArrayMember(i, 1, memberInfo[j][1], memberInfo[j][2], self.m_tblMemBtn[j])
						break
					end
				end
				local nPos = tblThisArrayPos[2][i]
				if(isLeaveNow) then
					tblThisArrayMemPos[2][i] = 0 --����뿪�Ķ�Ա������Ϣ
				else
					self:PutMemOn(nPos)
				end
				self.m_tblGridWnd[nPos]:ShowWnd(not isLeaveNow)	--itemWnd�Ƿ�ɼ�
			end
		end
		
		--��С�ӳ�Ա��ť�Ŀ���
		local bFlag = (0 ~= memberInfo[i][1])
		self.m_tblNameLabel[i]:ShowWnd(bFlag)
		self.m_tblNameLabel[i]:SetWndText(memberInfo[i][2])
		if(bFlag) then 
			self.m_MemNum = self.m_MemNum + 1
		end
		if(tblBtnBeShow[i]) then bFlag = false end
		self.m_tblMemBtn[i]:ShowWnd(bFlag)
	end
	self.m_ArrayDes:SetWndText(base:GetArraySkillDes(arrayName))
	self.m_OkBtn:EnableWnd(self:IsCanSave())
	self:ShowWnd(true)
end

--����С�ӳ�Ա��Ϣ
function CBattleArrayMemPosWnd:SetMemInfo(tblInfo)
	local name	= g_MainPlayer.m_Properties:GetCharName()
	local id	= g_MainPlayer.m_Properties:GetCharID()
	if(not next(tblInfo)) then
		self.m_tblMemberInfo = {}
		return
	end
	self:SetIsMemChange(tblInfo)
	self.m_tblMemberInfo = {{id, name, true}, unpack(tblInfo)} -- id name bOnline
end

--��Ա�Ƿ��б仯
function CBattleArrayMemPosWnd:SetIsMemChange(tblInfo)
	local tbl = self.m_tblMemberInfo
	if(#(tblInfo) > #(tbl)-1) then --��Ա����,��Ҫ��������
		self.m_bMemChanged = true
		return
	end

---------����ע�͵��Ĵ�����С����Ա�б仯��������˳�򣩾�Ҫ��������
--	if(#(tblInfo) ~= #(tbl)-1) then
--		self.m_bMemChanged = true
--		return
--	end
--	for i = 1, #(tblInfo) do
--		if(tblInfo[i][1] ~= tbl[i+1][1]) then
--			self.m_bMemChanged = true
--			return
--		end
--	end

	self.m_bMemChanged = false
end


--��ʼ��קBtn
function CBattleArrayMemPosWnd:StartDragBtn(Child)
	local tbl = self.m_tblMemberInfo
	local cursorState = g_WndMouse:GetCursorState()
	for i = 1, 5 do
		if(Child == self.m_tblMemBtn[i] and cursorState == ECursorState.eCS_Normal) then
			g_WndMouse:SetPickupBattleArrayMember(i, 1, tbl[i][1], tbl[i][2], Child) --1�ǴӰ�ť����ģ�2�Ǵ�Item�����
			Child:ShowWnd(false)
			return
		end
	end
end

--������
function CBattleArrayMemPosWnd:ClearCursor()
	local cursorState, context = g_WndMouse:GetCursorState()
	if(cursorState == ECursorState.eCS_PickupBattleArrayIndex) then
		if(1 == context[2]) then
			self.m_tblMemBtn[context[1]]:ShowWnd(true)
		end
		g_WndMouse:ClearCursorAll()
	end
end

--�ж��Ƿ��ѽ����г�Ա����
function CBattleArrayMemPosWnd:IsCanSave()
	for i = 1, 5 do
		if(self.m_tblMemBtn[i]:IsShow()) then return false end
	end
	return true
end


function CBattleArrayMemPosWnd:PutMemOn(pos)
	local tblMemPos	= self.m_tblMemPosInfoTemp
	local tbl		= self.m_tblThisArrayPosInfo
	local cursorState, context = g_WndMouse:GetCursorState()
	if(not context) then return end
	self.m_tblGridWnd[pos]:ShowWnd(true)
	g_WndMouse:CopySkillIconToWnd(self.m_tblGridWnd[pos])
	g_WndMouse:ClearCursorAll()
	for i = 1, 5 do
		if(tbl[2][i] == pos) then 
			tblMemPos[i] = {context[3], context[4], pos} --id, name, pos
		end
	end
end

--���Itme�¼�
function CBattleArrayMemPosWnd:LClickUpItem(item, pos)
	local tblMemPos	= self.m_tblMemPosInfoTemp
	local tbl		= self.m_tblThisArrayPosInfo
	local cursorState, context = g_WndMouse:GetCursorState()
	if(cursorState == ECursorState.eCS_PickupBattleArrayMember) then
		for i, v in pairs(tblMemPos) do
			if(v[3] == pos) then return end --�����λ���Ѿ�����,��ֱ�ӷ���(Ϊ�жϷ������İ�ȫ��,��ע�͵�)
		end
		if(2 == context[2]) then
			local lastPos = tbl[2][context[1]]
			self.m_tblGridWnd[lastPos]:ShowWnd(false)
			tblMemPos[context[1]] = {0,"",-1}
		end
		self:PutMemOn(pos)
		self.m_OkBtn:EnableWnd(self:IsCanSave())
	elseif(cursorState == ECursorState.eCS_Normal) then
		for i, v in pairs(tblMemPos) do
			if(v[3] == pos) then
				g_WndMouse:SetPickupBattleArrayMember(i, 2, tblMemPos[i][1], tblMemPos[i][2], self.m_tblGridWnd[pos])
				break
			end
		end
	end
end

--����
function CBattleArrayMemPosWnd:Reset()
	g_WndMouse:ClearCursorAll()
	local tbl = self.m_tblGridWnd
	for i = 1, 5 do
		local bFlag = (0 ~= self.m_tblMemberInfo[i][1])
		local index = self.m_tblMemPosInfoTemp[i][3]
		self.m_tblMemBtn[i]:ShowWnd(bFlag)--��С�ӳ�Ա��ť�Ŀ���
		if(-1 ~= index) then tbl[index]:ShowWnd(false) end
	end
	self.m_tblMemPosInfoTemp = {{0,"",-1},{0,"",-1},{0,"",-1},{0,"",-1},{0,"",-1}}
	self.m_OkBtn:EnableWnd(self:IsCanSave())
end

--˳������
function CBattleArrayMemPosWnd:PosByOrder()
	local base				= g_GameMain.m_BattleArrayBase
	local tblPos			= base.m_tblBattleArrayPos --������Ϣ��
	local nameIndex			= base:GetArrayNameIndex(self.m_sArrayName)
	local tblThisArrayPos	= tblPos[nameIndex]
	local tblMemPos			= self.m_tblMemPosInfoTemp
	local tbl				= self.m_tblMemberInfo
	for i = 1, self.m_MemNum do
		local pos = tblThisArrayPos[2][i]
		self.m_tblMemBtn[i]:ShowWnd(false)
		self.m_tblGridWnd[pos]:ShowWnd(true)
		g_WndMouse:SetPickupBattleArrayMember(i, 1, tbl[i][1], tbl[i][2], self.m_tblMemBtn[i])
		self:PutMemOn(pos)
	end
	g_WndMouse:ClearCursorAll()
	self.m_OkBtn:EnableWnd(self:IsCanSave())
end

function CBattleArrayMemPosWnd:SaveBattleArrayMemPos()
	local tblPos	= g_GameMain.m_BattleArrayBase.m_tblBattleArrayPos --������Ϣ��
	local arrayId	= 0
	local nameIndex	= g_GameMain.m_BattleArrayBase:GetArrayNameIndex(self.m_sArrayName)
	local arrayId	= tblPos[nameIndex][1][1]
	local tblMemPos	= self.m_tblMemPosInfoTemp
	Gac2Gas:SaveBattleArrayMemPos(g_Conn,arrayId,self.m_sArrayName,tblMemPos[1][1],tblMemPos[2][1],tblMemPos[3][1],tblMemPos[4][1],tblMemPos[5][1])
end

--���Ʊ�����
function CBattleArrayMemPosWnd:DrawBG()
	local bk = SQRDialog:new()
	bk:CreateFromResEx( "BagGridBackground",self,true,true )
	bk:ShowWnd( true )
	local SIZE = bk:GetWndWidth()
	local Flag = IMAGE_PARAM:new(SM_BS_BK, IP_ENABLE)
	local SrcImage    = bk:GetWndBkImage(Flag)
	local FlagDisable = IMAGE_PARAM:new(SM_BS_BK, IP_DISABLE)
	local SrcImageDisable = bk:GetWndBkImage(FlagDisable)

	for i=1, 100 do
		local x, y = self:ParsePos(i, 10)
		local pos  = CPos:new(SIZE*x,SIZE*y)
		local item = self.m_ArrayList:GetSubItem(y, x)
		local DescImage			= item:GetWndBkImage(Flag)
		local DescImageDisable	= item:GetWndBkImage(FlagDisable)
		local ImageBk = IMAGE:new()
		SrcImage:GetImage(SrcImage:GetImageCount()-1, ImageBk)
		SrcImageDisable:GetImage(SrcImageDisable:GetImageCount()-1, ImageBk)
		ImageBk:SetPosWndX(pos.x)
		ImageBk:SetPosWndY(pos.y)
		DescImage:AddImageFromImageList(SrcImage,0,-1)
		DescImageDisable:AddImageFromImageList(SrcImageDisable,0,-1)
	end
	bk:DestroyWnd()
end

function CBattleArrayMemPosWnd:ParsePos(Pos, cols)
	Pos = Pos - 1
	local y = math.floor(Pos / cols)
	local x = Pos - y*cols
	return x, y
end

--������е�ItemWnd
function CBattleArrayMemPosWnd:FreshGridBtn()
	for i = 0, 99 do
		self.m_tblGridWnd[i]:ShowWnd(false)
		local item = self.m_ArrayList:GetSubItem(i/10, i%10)
		item:SetWndText("")
		item:EnableWnd(false)
	end
end

function CBattleArrayMemPosWnd:DrawArrayListItem()
	for i = 0, 99 do
		local item = self.m_ArrayList:GetSubItem(i/10, i%10)
		local gridItem = self:CreateItemWnd(item)
		self.m_tblGridWnd[i] = gridItem
	end
end

function CBattleArrayMemPosWnd:CreateItemWnd(parent)
	local wnd = CArrayMemPosGridWnd:new()
	wnd:CreateFromRes("CommonGrid", parent)
	return wnd
end