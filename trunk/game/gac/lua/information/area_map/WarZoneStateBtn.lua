cfg_load "tong/TongStationPos_Common"

CWarZoneStateBtn = class(SQRDialog)

function CWarZoneStateBtn:Ctor(Parent, wzsId, uWzsCamp, TongName)
	local Tips = ""
	if uWzsCamp ~= 0 then
		if uWzsCamp == 1 then
			self:CreateFromRes("WarZoneState_1", Parent)
			Tips = GetStaticTextClient(2501)	-- ����
		elseif uWzsCamp == 2 then
			self:CreateFromRes("WarZoneState_2", Parent)
			Tips = GetStaticTextClient(2502)	-- ��ʥ
		elseif uWzsCamp == 3 then
			self:CreateFromRes("WarZoneState_3", Parent)
			Tips = GetStaticTextClient(2503)	--��˹
		end
		
		if TongName and TongName ~= "Npcפ��" then
			Tips = Tips..TongName..GetStaticTextClient(7007) -- Ӷ����
		end
	 
		Tips = Tips..GetStaticTextClient(19023) -- ռ��
	elseif uWzsCamp == 0 then
		self:CreateFromRes("WarZoneState_0", Parent)
		Tips = GetStaticTextClient(19024)	-- ��פ��δ��ռ��
	end
	
	self.m_StateBtn = self:GetDlgChild("StateBtn")
	self.m_StateBtn:SetMouseOverDescAfter(Tips) -- ռ��
	local Pos = GetCfgTransformValue(false, "TongStationPos_Common", wzsId, "Pos")
	local WndHeight = self:GetWndOrgHeight()
	local WndWidth = self:GetWndOrgWidth()
	
	local rt_1 = CFRect:new()
	rt_1.top = Pos[1]
	rt_1.left = Pos[2]
	rt_1.bottom = Pos[1] + WndHeight
	rt_1.right = Pos[2] + WndWidth
	self:SetLogicRect(rt_1)
	
	g_GameMain.m_AreaInfoWnd:CalculateCharWndPos(self, g_GameMain.m_AreaInfoWnd.m_SceneName, Parent, Pos[1], Pos[2])
	
	self:ShowWnd(true)
end

function CWarZoneStateBtn:OnCtrlmsg(Child, uMsgID, uParam1, uParam2)
	if uMsgID == BUTTON_LCLICK  then
		if Child == self.m_StateBtn then
			g_GameMain.m_AreaInfoWnd:ClickMapAutoTrack()
			g_GameMain.m_AreaInfoWnd:SetTrackWndFocus()
		end
	end	
end

-- ���� Ȼ�� ��¼
