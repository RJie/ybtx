gac_require "framework/common_wnd_ctrl/CommonCtrlInc"

  m_ItemName = ""
  
function CMenu:Ctor( ResName ,ParentWnd, AddWidth)

	self:CreateFromRes( "TargetMenu", ParentWnd )
	self:ShowWnd( true )
	self.m_ListCtrl = self:GetDlgChild( "ListCtrl" )
	assert(self.m_ListCtrl)
		
	self.m_ItemIndex = 0
	self.m_Items = {}
	self:SetFocus()
	self.choose = 0
	self.upwards = false
	
	if AddWidth then
		local Rect = CFRect:new()
		self.m_ListCtrl:GetLogicRect(Rect)
		Rect.right = Rect.right + AddWidth
		self.m_ListCtrl:SetLogicRect(Rect)
	else
		AddWidth = 0
	end
	
	self.m_ListCtrl:InsertColumn(0, self.m_ListCtrl:GetWndOrgWidth() + AddWidth - 8 )
end

function CMenu:Destroy()
	self:DestroyWnd()
end


function CMenu:SetPos( x, y )
	
	local Rect=CFRect:new()
	self.m_ListCtrl:GetLogicRect(Rect)
	
	local uWidth = Rect.right - Rect.left
	local uHeight = Rect.bottom - Rect.top
	if self.upwards then 
		Rect.left	= x
		Rect.bottom	= y
		Rect.right	= x + uWidth
		Rect.top	= y - uHeight
	else
		Rect.left 	= x
		Rect.top  	= y
		Rect.right	= x + uWidth
		Rect.bottom	= y + uHeight
	end
	self.m_ListCtrl:SetLogicRect(Rect)
end

function CMenu:SetUpwards(bool)
	self.upwards = bool
end

--[[
���ܣ�����˵���
������name - ����
      func - ���ѡ����Ӧ����
      func2 - �Ҽ�ѡ����Ӧ����
      bIsChild - �Ƿ����Ӳ˵�(����Ϊnil, ��ͬ��false)
      bHasChild - �Ƿ����Ӳ˵�(����Ϊnil, ��ͬ��false)
      MouseMoveFunc - ���Ӳ˵�ʱ����Ƶ�����ʱ����Ӧ�����������Ӳ˵���nil��
      �ɱ���� - �����ģ�func��MouseMoveFunc�������ã�
--]]
function CMenu:InsertItem(name, func1 , func2, bIsChild, bHasChild, MouseMoveFunc, ...)
	assert(IsNil(bHasChild) or IsBoolean(bHasChild))
	assert(IsNil(bIsChild) or IsBoolean(bIsChild))
	
	local Rect=CFRect:new()
	local uItemHeight=20
	
	self.m_ListCtrl:InsertItem(self.m_ItemIndex,uItemHeight )
	self.m_ListCtrl:GetSubItem(self.m_ItemIndex,0) : SetWndText(name)
	
	self:SetItemContext( self.m_ItemIndex, func1 , func2, name, bIsChild, bHasChild, MouseMoveFunc, ... )
	self:GetItemName( self.m_ItemIndex , name )
		
	self.m_ItemIndex = self.m_ItemIndex + 1
	
	self.m_ListCtrl:GetLogicRect(Rect)
	local uTotalHeight = uItemHeight*self.m_ItemIndex --*self.m_ListCtrl:GetRootZoomSize()
	Rect.bottom = uTotalHeight + Rect.top + 8
	self.m_ListCtrl:SetLogicRect(Rect)
end

function CMenu:OnActive( bActive )
	--if( not bActive )then
		self:ShowWnd( bActive )
	--end
end

function CMenu:notShow ()
	return self:IsShow()
end

function CMenu:GetMaxSize()
	return self.m_ItemIndex - 1
end

function CMenu:GetCurSelectedItemIndex()
    return self.m_ListCtrl:GetSelectItem(-1) + 1
end


function CMenu:SetItemContext( nIndex, func1, func2, name, bIsChild, bHasChild, MouseMoveFunc, ... )
	local arg = {...}
	self.m_Items[nIndex]             = {}
	self.m_Items[nIndex].Func1       = func1
	self.m_Items[nIndex].Func2       = func2
	self.m_Items[nIndex].Name        = name
	self.m_Items[nIndex].Context     = arg
	self.m_Items[nIndex].m_bIsChild  = bIsChild
	self.m_Items[nIndex].m_bHasChild = bHasChild
	self.m_Items[nIndex].OnMSMove    = MouseMoveFunc
end

function CMenu:EnableItem( nItemIndex, bEnable )
	self.m_ListCtrl:GetSubItem(nItemIndex,0):EnableWnd(bEnable)
end

function CMenu:GetItemName()
	return m_ItemName
end
function CMenu:GetItemCount()
	return self.m_ItemIndex
end
function CMenu:GetItemRect(nItemIndex)
	local Rect = CFRect:new()
	self.m_ListCtrl:GetSubItem(nItemIndex,0):GetLogicRect(Rect)
	return Rect
end

function CMenu:GetMenuItem(nItemIndex)
	return self.m_ListCtrl:GetSubItem(nItemIndex,0)
end

function CMenu:OnCtrlmsg( Child, uMsgID, uParam1, uParam2 )
	if (uParam1 < 0) then
		self:ShowWnd( false )
		return
	end
	if( Child == self:GetDlgChild( "ListCtrl" ) )then
	
		if( uMsgID == ITEM_LBUTTONCLICK ) then
			m_ItemName = self.m_Items[uParam1].Name
			local Context=self.m_Items[uParam1].Context
			if self.m_Items[uParam1].Func1 ~= nil then
				self.m_Items[uParam1].Func1( unpack( Context )) 	
			end
			self:ShowWnd( false )	
		elseif( uMsgID == ITEM_RBUTTONCLICK  ) then
			if( self.m_Items[uParam1].Func2 ~= nil ) then
				self.m_Items[uParam1].Func2()
			end
			self:ShowWnd( false )
		elseif( uMsgID == ITEM_SELECT_CHANGED ) then
			self:ItemSelectChange(self.m_Items[uParam1])
		end
	end	
end

-------------------------------------------------------------------------------

function CMenu:ItemSelectChange(item)
	--����ϴε��Ӳ˵�
	if(g_GameMain.m_ChildMenu ~= nil and item.m_bIsChild == false) then
		g_GameMain.m_ChildMenu:Destroy()
		g_GameMain.m_ChildMenu = nil
	end
	
	--���Ӳ˵�
	if(item.m_bHasChild) then
		if(not item.Context) then
			item.OnMSMove()
		else
			item.OnMSMove(unpack(item.Context))
		end
	end
end