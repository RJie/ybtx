--С��ͼ����
gac_require( "information/small_map/SmallMapWndInc" )
gac_require( "information/world_map/WorldMapWnd" )

function CSmallMapWnd:Ctor(parentWnd)
	self:CreateFromRes( "SmallMap", parentWnd )
	self:ShowWnd( true )
	self:SetIsBottom(true)
    self.m_nScale = 1
end

--- @brief ��ʼ��
function CSmallMapWnd:InitData()
	self.u_BtnZoomIn = self:GetDlgChild("BtnZoomIn")
	self.u_BtnUserAdvice = self:GetDlgChild("BtnUserAdvice")
	self.u_BtnZoomOut = self:GetDlgChild("BtnZoomOut")
	--self.u_WndMapBg = self:GetDlgChild("WndMapBg")
	self.u_BtnSearch = self:GetDlgChild("BtnSearch")
	self.u_WndCoordinate = self:GetDlgChild("WndCoordinate")
	--self.u_WndMap = self:GetDlgChild("WndMap")
	self.u_WndPlayer = self:GetDlgChild("WndPlayer")
	self.u_BtnBang = self:GetDlgChild("BtnBang")
	self.u_SceneNameAndAreaName = self:GetDlgChild("SceneNameAndAreaName")
	self.u_WndMoule = self:GetDlgChild("WndModle")
	self.u_WndActionPanel = self:GetDlgChild("BtnActionPanel")
	
	self.u_WndPlayer:ShowWnd(false)
	--g_GameMain.m_SmallMapBG.m_Static:SetSmallMapWnd(self)
	
	self.m_SelectShowWnd = CSmallMapSelectShowWnd:new(self)
	self.m_LockWndBtn 		= self:GetDlgChild("LockWndBtn")
end

function CSmallMapWnd:UpdatePlayerPosInSmallMap()
	--�����ڳ����е�����λ��
	local posInSceneInGrid = CPos:new()
	g_MainPlayer:GetGridPos(posInSceneInGrid)
	
	local sCoordinate = posInSceneInGrid.x .. ", " .. posInSceneInGrid.y
	
	-- ������������λ����ʾ
	g_GameMain.m_NavigationMap.u_WndCoordinate:SetWndText(sCoordinate)
end

--- @brief ���ܣ����ó�������
--- @param nWidthInGrid - ��ͼ��ȣ���������
--- @param nHeightInGrid - ��ͼ�߶ȣ���������
--- @param fCWRotDeg - ��ͼ˳ʱ����ת�Ƕ�
--- @param sMapFile - С��ͼ�ļ���
--- @param sTitle - ��ͼ����
function CSmallMapWnd:SetSceneData(x, y, nWidthInGrid, nHeightInGrid, fCWRotDeg, sMapFile)
	--g_GameMain.m_SmallMapBG.m_Static:SetCurPos(x,y)
	g_GameMain.m_SmallMapBG.m_Static:SetSceneData(nWidthInGrid, nHeightInGrid, fCWRotDeg, sMapFile, 23)
	g_GameMain.m_SmallMapBG.m_Static:SetPlayerTex()
end

--�Ӵ�����Ϣ
function CSmallMapWnd:OnCtrlmsg( Child, uMsgID, uParam1, uParam2 )
	if uMsgID == BUTTON_LCLICK  then
		if Child == self.u_BtnZoomOut then
			self.m_nScale = self.m_nScale - 0.1*self.m_nScale
			if(self.m_nScale < 0.4) then
				self.m_nScale = 0.4
			end
			g_GameMain.m_SmallMapBG.m_Static:SetScale(self.m_nScale)
		elseif Child == self.u_BtnZoomIn then
			self.m_nScale = self.m_nScale + 0.1*self.m_nScale
			if(self.m_nScale > 0.6) then
				self.m_nScale = 0.6
			end
			g_GameMain.m_SmallMapBG.m_Static:SetScale(self.m_nScale)
		elseif Child == self.u_BtnBang then
			g_GameMain.m_SortListWnd:BeOpenPanel()
		elseif Child == self.u_BtnUserAdvice then
			g_GameMain.m_UserAdviceWnd:OpenWnd()
		elseif Child == self.u_BtnSearch then
			local bFlag = self.m_SelectShowWnd:IsShow()
			self.m_SelectShowWnd:ShowWnd(not bFlag)
			if not bFlag then
			    self.m_SelectShowWnd:SetFocus()
			end
		elseif Child == self.u_WndActionPanel then
			g_GameMain.m_FbActionPanel:OpenPanel()
		elseif Child == self.m_LockWndBtn then
			if g_MainPlayer.m_ItemBagLock then
				if not g_GameMain.m_ItemBagTimeLockWnd:IsShow() then
					g_GameMain.m_ItemBagTimeLockWnd:ShowWnd(true)
				end
			elseif g_GameID ~= 8 then
				if not g_GameMain.m_ItemBagLockWnd:IsShow() then
					g_GameMain.m_ItemBagLockWnd:ShowWnd(true)
				end
			elseif g_GameMain.m_ItemBagLockWnd:IsShow() then
				return
			else
				Gac2Gas:OpenItemBagLockWnd(g_Conn)
			end
		end	
	end
end

function CSmallMapWnd:RecRoleData(Obj, Type)
	g_GameMain.m_SmallMapBG.m_Static:ReceiveRoleData(Obj, Type)
end

function CSmallMapWnd:DelRoleData(Obj)
	return g_GameMain.m_SmallMapBG.m_Static:RemoveRoleData(Obj)
end

--��ʾ��������������ͳ�����
function CSmallMapWnd:ShowSceneNameAndAreaName(sceneName,areaName)
	local str = ""
	if areaName then
		str = areaName
	else
		if sceneName then
			str = sceneName
		end
	end
	self.u_SceneNameAndAreaName:SetWndText(str)
end

