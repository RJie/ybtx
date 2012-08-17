--���ͼ����
gac_require( "information/world_map/WorldMapWndInc" )

function CreateWorldMapBG(Parent)
	local Wnd = CWorldMapBG:new()
	Wnd:CreateFromRes( "WorldMapPicture", Parent )	
	for Index, SceneName in pairs(WorldMapInfo["World"]) do
		if not Wnd["m_SceneBtn"..Index] then
			Wnd["m_SceneBtn"..Index] = Wnd:GetDlgChild("SceneBtn"..Index)
			Wnd["m_SceneName"..Index] = SceneName
			--Wnd["m_SceneBtn"..Index]:SetWndText(SceneName)	
		end
	end

	Parent["m_WorldMap"] = Wnd
end

function OpenWorldMapWnd()
	if not g_GameMain.m_AreaInfoWnd:IsShow() then		
		g_GameMain.m_AreaInfoWnd.UseNkey = true
		g_GameMain.m_AreaInfoWnd:InitWorldMap()
		g_GameMain.m_AreaInfoWnd:ShowWnd(true)
	else
		-- ����Ѿ���M�����������
		if g_GameMain.m_AreaInfoWnd.UseMkey then
			-- �����M��������壬�����ص������ͼ����ʱӦ�ùص��������
			if g_GameMain.m_AreaInfoWnd.m_MapState == "World" then
				g_GameMain.m_AreaInfoWnd.UseMkey = false
				g_GameMain.m_AreaInfoWnd.UseNkey = false
				g_GameMain.m_AreaInfoWnd:CloseAreaInfoWnd()	
			else
				g_GameMain.m_AreaInfoWnd:InitWorldMap()
				g_GameMain.m_AreaInfoWnd.UseMkey = false
				g_GameMain.m_AreaInfoWnd.UseNkey = true	
			end
		else 
			g_GameMain.m_AreaInfoWnd.UseNkey = false
			g_GameMain.m_AreaInfoWnd:CloseAreaInfoWnd()
		end
	end
end

--�Ӵ�����Ϣ
function CWorldMapBG:OnCtrlmsg( Child, uMsgID, uParam1, uParam2 )
	if uMsgID == BUTTON_LCLICK then
		
		local MiddleMap
		if  Child == self.m_SceneBtn1 then
			MiddleMap = "Camp1"
		elseif Child == self.m_SceneBtn2 then
			MiddleMap = "Camp2"
		elseif Child == self.m_SceneBtn3 then
			MiddleMap = "Camp3"	
		elseif Child == self.m_SceneBtn4 then
			MiddleMap = "WarArea"		
		end

		g_GameMain.m_AreaInfoWnd:InitMiddleMap(MiddleMap)
	end
end
