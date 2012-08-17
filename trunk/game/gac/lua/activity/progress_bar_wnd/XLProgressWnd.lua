CXLProgressWnd = class(SQRDialog)

local XLTick = nil
local PointAt = 1--1��ʾ����,-1��ʾ�½�
local LockIntObjID = nil

function CXLProgressWnd:Ctor()
	self:CreateFromRes("StorageForce_loading",g_GameMain)
	self.m_Progress = self:GetDlgChild( "Progress" )
	self:SetStyle(0x60000000)--���������ڲ����ƶ�
	self.m_Progress:SetStyle(0x60000000)--���ó��Ӵ���
	self.m_Progress:SetProgressMode(3)
	self.m_Progress:SetRange(1000)
	self.m_Pos = 0
	
	---------------------
	self.m_Scale = {}
	for i=1,3 do
		self.m_Scale[i] = SQRDialog:new()
		self.m_Scale[i]:CreateFromRes("SmallGame_Scale", self.m_Progress)
		self.m_Scale[i]:ShowWnd( true )
		self.m_Scale[i]:SetStyle(0x60000000)--���ó��Ӵ���
	end
	---------------------
end

local function SetWndPos(PartenWnd,ChildWnd,Pos)
	local Rect = CFRect:new()
	ChildWnd:GetWndRect(Rect)
	Rect.left 	= Rect.left
	Rect.top  	= Rect.top
	Rect.right	= Rect.right
	Rect.bottom	= Rect.bottom
	
	local uHeight = Rect.bottom - Rect.top
	local ParentRect = CFRect:new()
	PartenWnd:GetWndRect(ParentRect)
	Rect.left 	= ParentRect.left
	Rect.top  	= ParentRect.bottom - (ParentRect.bottom - ParentRect.top)*((25*Pos)/100) - 1
	Rect.right	= ParentRect.right
	Rect.bottom	= Rect.top + 2
	ChildWnd:SetWndRect(Rect)
end

function CXLProgressWnd:SetPos( nNum )
	if self.m_Progress.SetPos then
		self.m_Progress:SetPos(nNum)
	end
end

function CXLProgressWnd:GetPos()
	return self.m_Progress:GetPos()
end

function CXLProgressWnd:BeginXLToProgress()
	if XLTick then
		UnRegisterTick( XLTick )
	end
	--����һ��������ʼ
	Gac2Gas:BeginKickBehavior(g_Conn)
	
	g_GameMain.m_XLProgressWnd.m_IsShowWnd = nil
	g_GameMain.m_XLProgressWnd.m_IsButtonDown = true
	self:SetPos(0)
	self.m_Pos=0
	PointAt = 1
	local Loading = function()
		self.m_Pos = self.m_Pos + PointAt*2--���˵�����Ϊ������ٶ�
		if self.m_Pos > 1000 then
			self.m_Pos = 1000
			PointAt = -1
			-------��ͷֱ�ӷ���----------
			self:SetPos( 1 )
			self:SendXLNum()
			------------------
		elseif self.m_Pos < 0 then
			self.m_Pos = 0
			PointAt = 1
		else
			self:SetPos( self.m_Pos )
		end
	end
	local time = 1000--����ʱ��
	XLTick = RegisterTick( "BeginXL_Loading", Loading , time/1000)  --ע��ʱ��
end

local function HideXLProgress(Wnd, IsDelay)
	if XLTick then
		UnRegisterTick( XLTick )
		XLTick = nil
	end
	LockIntObjID = nil
	Wnd.m_IsShowWnd = nil
	Wnd.m_IsButtonDown = nil
	
	local function callback()
		Wnd:ShowWnd(false)
		Wnd:SetPos( 0 )
	end
	if IsDelay then
		RegisterOnceTick(g_GameMain, "HideXLProgress", callback, 500)
	else
		callback()
	end
end

function CXLProgressWnd:StopXLFromProgress()
	--����һ��ʧ��
	HideXLProgress(self)
	Gac2Gas:CancelKickBehavior(g_Conn)
end

function CXLProgressWnd:SendXLNum()
	if XLTick then
		UnRegisterTick( XLTick )
		XLTick = nil
	end
	local CurrPos = self:GetPos()
	--����һ���ɹ�
	Gac2Gas:EndKickBehavior(g_Conn,LockIntObjID,CurrPos)
	HideXLProgress(self, true)
end

function CXLProgressWnd.OpenXLProgressWnd(Conn,IntObjID)
	g_GameMain.m_XLProgressWnd:SetPos(0)
	g_GameMain.m_XLProgressWnd.m_Pos=0
	g_GameMain.m_XLProgressWnd.m_IsShowWnd = true
	LockIntObjID = IntObjID
	
	------------------
	for i=1,3 do
		SetWndPos(g_GameMain.m_XLProgressWnd.m_Progress,g_GameMain.m_XLProgressWnd.m_Scale[i],i)
	end
	------------------
	
	g_GameMain.m_XLProgressWnd:ShowWnd(true)
end

function CXLProgressWnd.CloseXLProgressWnd(Conn)
	if g_GameMain.m_XLProgressWnd.m_IsShowWnd then
		g_GameMain.m_XLProgressWnd:ShowWnd(false)
		LockIntObjID = nil
		g_GameMain.m_XLProgressWnd.m_IsShowWnd = nil
		g_GameMain.m_XLProgressWnd.m_IsButtonDown = nil
	elseif g_GameMain.m_XLProgressWnd.m_IsButtonDown then
		HideXLProgress(g_GameMain.m_XLProgressWnd)
	end
end
