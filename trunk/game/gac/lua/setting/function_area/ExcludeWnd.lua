CShowOpendWnd = class()
------���廥��------

--��Ҵ򿪴������ĳ�ʼ�����ຯ������Ҫ���뻥��ϵͳ�Ĵ��壬Ҫ�ڳ�ʼ��ʱ���ô˺�����
--���������ڶ�����������Ƿ�ͣ�����������
--wndObject��Ҫע��Ĵ��ڶ���
--typeNo���������ͣ���ͬ���ͻ��⣬��˼���ǲ���ͬʱ���֡���ͬ���͵���尴����������ֵ�ľ���ֵ��С������������������
--bDepend���������ͣ��Ƿ�ͣ����
--TblFatherWnd�������ڶ����(һ��Ҫ����ṹ��)������������رգ��Ӵ��ڽ���֮�رա����û�и����壬�Ͳ��Ӵ˲�����
--functionalGroup������ϵͳ���磺���ϵͳ���Ϊ1�������Ŀǰ������ͬʱ�ر�ĳ��ϵͳ�򿪵��������ģ�����Ҫ��������ľͲ�Ҫ���ˣ�
--ps��typeNoΪ0�Ĵ���������Ӵ���֮��������κ����ʹ��廥�⣬���Ӵ����typeNoԼ��Ϊ��ֵ

local function SetXPos(wnd, x, y)
	local GameMainRect = CFRect:new()
	g_GameMain:GetLogicRect(GameMainRect)
	
	local Rect=CFRect:new()
	wnd:GetLogicRect(Rect)
	
	local uWidth  = Rect.right - Rect.left
	Rect.left	= x
	Rect.right	= x+uWidth
	
	wnd:SetLogicRect(Rect)
	
	if(Rect.right > GameMainRect.right) then
		SetXPos(wnd, GameMainRect.right - uWidth)
	end
end

function CShowOpendWnd:Ctor()
	self:Clear()
end

function CShowOpendWnd:Clear()
	self.m_OpenWndRecordTbl = {}
	self.m_OpenWndRecordTblUnExclude = {}
end

function CShowOpendWnd:InitExcludeWnd(wndObject, typeNo, bDepend, tblFatherWnd, functionalGroup)
	if(tblFatherWnd) then
		assert(IsTable(tblFatherWnd), "�˲���Ӧ�ô�table")
	end
	
	local bFlag = false
	if( wndObject:IsShow() ) then
		wndObject:ShowWnd(false)
		bFlag = true
	end
	
	wndObject.TYPE		= typeNo
	wndObject.BDEPEND	= bDepend
	wndObject.TBLFATHER	= tblFatherWnd
	wndObject.FUNCGROUP	= functionalGroup
	
	if(bFlag) then
		wndObject:ShowWnd(true)
	end
end

function CShowOpendWnd:InitExcludeWndEx(wndObject, typeNo, bDepend, tblFatherWnd, functionalGroup)
	wndObject:ShowWndIgnTex( wndObject:IsShow() )
	self:InitExcludeWnd(wndObject, typeNo, bDepend, tblFatherWnd, functionalGroup)
end

function CShowOpendWnd:ShowWnd(func, wndObject, bShow, bFlag)
	if(bShow) then
		self:OpenExcludeWnd(func, wndObject)
	else
		self:CloseExcludeWnd(func, wndObject, bFlag)
	end
end

--�ı��¼���ڴ򿪵Ĵ��ڶ����tbl���ڴ򿪴���ʱ���ShowWnd(true)��������Ҫ�򿪵Ĵ��ڶ���
function CShowOpendWnd:OpenExcludeWnd(func, wndObject)
	assert(wndObject.TYPE, "δ������廥��ϵͳ�͵��û���ϵͳ�ķ�����")
	assert(func, "��ֱֹ�ӵ���OpenExcludeWnd") 
------------------------------------------------------------------------------------------------------------
	if("�ǻ���" == wndObject.TYPE) then --�ǻ������
		if( wndObject:IsShow() and self.m_OpenWndRecordTblUnExclude[wndObject] ) then
			return
		end
		func(wndObject, true) --��ʾ�����
		self.m_OpenWndRecordTblUnExclude[wndObject] = true
		
------------------------------------------------------------------------------------------------------------
	else
		if( wndObject:IsShow() and self.m_OpenWndRecordTbl[wndObject.TYPE] == wndObject) then
			return
		end
		func(wndObject, true) --��ʾ�����
		if(not next(self.m_OpenWndRecordTbl)) then --�����������Ϊ��
			self.m_OpenWndRecordTbl[wndObject.TYPE] = wndObject
		else
			self:BeAddWnd(wndObject) --�ر��以����壬����Ӵ��Ӵ��嵽��������
		end
		--self:ShowWndCorrectly() --����尴�����ʹ�С����
	end
end

--������ڹرգ�������򿪴��ڼ�¼����Ķ����ڹرմ���ʱ���ShowWnd(false)��
function CShowOpendWnd:CloseExcludeWnd(func, wndObject, bFlag)
	if(not wndObject) then return end
	assert(func, "��ֱֹ�ӵ���CloseExcludeWnd") 
	assert(wndObject.TYPE, "δ������廥��ϵͳ�͵��û���ϵͳ�ķ�����")
	
	if(wndObject.VirtualSpecialWndOnClose) then
		wndObject:VirtualSpecialWndOnClose()
		wndObject.VirtualSpecialWndOnClose = nil
		return
	end
--------------------------------------------------------------------------------------------------------
	if("�ǻ���" == wndObject.TYPE) then --�ǻ������
		if(self.m_OpenWndRecordTblUnExclude[wndObject]) then
			self.m_OpenWndRecordTblUnExclude[wndObject] = nil
		end
		self:OnCloseWnd(wndObject, bFlag)
		func(wndObject, false)
		self:ClosedWnd(wndObject, bFlag)
--------------------------------------------------------------------------------------------------------
	else
		self:OnCloseWnd(wndObject, bFlag)
		func(wndObject, false)
		if self.m_OpenWndRecordTbl[wndObject.TYPE] == wndObject then
			self:ClosedWnd(wndObject, bFlag)
			self.m_OpenWndRecordTbl[wndObject.TYPE] = nil
			self:CloseChild(wndObject)
		end
		
		if wndObject.m_CheckIsAutoCloseWndTick then
			UnRegisterTick(wndObject.m_CheckIsAutoCloseWndTick)
			wndObject.m_CheckIsAutoCloseWndTick = nil
		end
		
		--self:ShowWndCorrectly()
	end
end

------��ͬ���͵Ĵ���λ�ÿ���------
function CShowOpendWnd:ShowWndCorrectly()
	local tbl = self.m_OpenWndRecordTbl
	local tblOrder = {}
	for i, v in pairs(tbl) do
		table.insert(tblOrder, i)
	end
	table.sort(tblOrder, function(a, b) return math.abs(a) < math.abs(b) end)
	
	local Rect = CFRect:new()
	for i, v in ipairs(tblOrder) do
		if(tbl[v].BDEPEND) then
			local left = 1 
			if(v>1 and tbl[v].BDEPEND) then
				tbl[v-1]:GetLogicRect(Rect)
				left = Rect.right + 1
			end
			SetXPos(tbl[v], left)
		end
	end
end

--�ر�������ӵ������������
function CShowOpendWnd:CloseAllActiveWndExclude()
	for i, v in pairs(self.m_OpenWndRecordTbl) do
		v:ShowWnd(false)
	end
end

--�ر�������ӵ��ǻ����������
function CShowOpendWnd:CloseAllActiveWndUnExclude()
	for k, v in pairs(self.m_OpenWndRecordTblUnExclude) do
		k:ShowWnd(false)
	end
end

function CShowOpendWnd:FindInTbl(tbl, target)
	for i = 1, #tbl do
		if(target == tbl[i]) then return true end
	end
	return false
end

------�ر��Ӵ���------
function CShowOpendWnd:CloseChild(beCloseWnd, beOpenWnd) --�����������رյ���壬�����򿪵����
	for i, v in pairs(self.m_OpenWndRecordTbl) do 
		local tbl = v.TBLFATHER
		if( tbl and next(tbl) ) then --�и��������
			local beOpenWndChild  = self:FindInTbl(tbl, beOpenWnd)
			local beCloseWndChild = self:FindInTbl(tbl, beCloseWnd)
			if((not beOpenWndChild) and beCloseWndChild) then
				v:ShowWnd(false)
			end
		end
	end
end

------�Ƿ�����´���------
function CShowOpendWnd:BeAddWnd(wndObject)
	if(self.m_OpenWndRecordTbl[wndObject.TYPE]) then --����кͼ����򿪵���廥������
		self.m_OpenWndRecordTbl[wndObject.TYPE]:ShowWnd(false)
	end
	self.m_OpenWndRecordTbl[wndObject.TYPE] = wndObject
end

------�ر�ĳһ����ϵͳ�����д򿪵����------
function CShowOpendWnd:RemoveOneFuncGroupPan(functionalGroup)--functionalGroup: 1Ϊ���ϵͳ���
	for i, v in pairs(self.m_OpenWndRecordTbl) do
		if(functionalGroup == v.FUNCGROUP) then
			v:ShowWnd(false)
		end
	end
end

------�����������ʵ�ֵ�VirtualExcludeWndClosed�����, �ڹر�����ʱ�����------
function CShowOpendWnd:ClosedWnd(wnd, bFlag)
	if(wnd.VirtualExcludeWndClosed) then
		wnd:VirtualExcludeWndClosed(bFlag)
	end
end

function CShowOpendWnd:OnCloseWnd(wnd, bFlag)
	if(wnd.VirtualExcludeWndOnClose) then
		wnd:VirtualExcludeWndOnClose(bFlag)
	end
end
