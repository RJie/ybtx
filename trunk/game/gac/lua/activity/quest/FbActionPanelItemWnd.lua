CFbActionPanelItemWnd = class (SQRDialog)

function CFbActionPanelItemWnd:Ctor(Parent)
	self:CreateFromRes( "FbActionRichTextItemWnd", Parent )
	
	self.m_ActionName = self:GetDlgChild("ActionName")
	self.m_ActionTime = self:GetDlgChild("ActionTime")
	self.m_RequiredLevel = self:GetDlgChild("RequiredLevel")
	self.m_JoinLimit = self:GetDlgChild("JoinLimit")
	self.m_StartPlace = self:GetDlgChild("StartPlace")
	self.m_IsRemindBtn = self:GetDlgChild("IsRemind")
	-- ���ر��
	self.m_IsRemindBtn:ShowWnd(false)
	self.m_PlayType = self:GetDlgChild("PlayType")
	self.m_RewardType = self:GetDlgChild("RewardType")	
	self.m_ActionName:SetAutoWidth(self.m_ActionName:GetWndOrgWidth(), self.m_ActionName:GetWndOrgWidth())
	self.m_ActionTime:SetAutoWidth(self.m_ActionTime:GetWndOrgWidth(), self.m_ActionTime:GetWndOrgWidth())
	self.m_RequiredLevel:SetAutoWidth(self.m_RequiredLevel:GetWndOrgWidth(), self.m_RequiredLevel:GetWndOrgWidth())
	self.m_JoinLimit:SetAutoWidth(self.m_JoinLimit:GetWndOrgWidth(), self.m_JoinLimit:GetWndOrgWidth())
	self.m_StartPlace:SetAutoWidth(self.m_StartPlace:GetWndOrgWidth(), self.m_StartPlace:GetWndOrgWidth())

	self:ShowWnd(true)
	self:SetFocus()	
end

function CFbActionPanelItemWnd:ClickSelectRemindBtn()
	local Flag = IMAGE_PARAM:new()
	Flag.CtrlMask = SM_BS_BK
	Flag.StateMask = IP_ENABLE	
	local DefaultImage = WND_IMAGE_LIST:new()
	
	local RemindAction = self.m_ActionNameStr			-- �����ActionName
	local StartTime = self.m_ActionTime:GetWndText()
	local StartHour = string.sub(StartTime, 1, 2)
	local StartMin  = string.sub(StartTime, 4, 5)
	if not self.m_bSelectIsRemind then			-- ѡ��
	--if not g_GameMain.m_FbActionPanel:IsRemind(RemindAction, StartHour, StartMin) then
		self.m_bSelectIsRemind = true
		self.m_IsRemindBtn:SetCheck(true)
		-- ѡ�еĻ�浽����
		
		if g_GameMain.m_FbActionPanel.m_RemindAction[RemindAction] == nil then
			--print("����  "..RemindAction)
			g_GameMain.m_FbActionPanel.m_RemindAction[RemindAction] = {}
		end
		table.insert(g_GameMain.m_FbActionPanel.m_RemindAction[RemindAction], {StartHour, StartMin})
		-- �л�����
		local strTexture = g_ImageMgr:GetImagePath(1340)
		DefaultImage:AddImage(self:GetGraphic(), -1,  strTexture, nil, CFPos:new(0, 0), "0xffffffff", 0 ) 
		self:SetWndBkImage(Flag, DefaultImage)
		
		local function FreeTimeNotify(Tick, NotifyInfo)
			DisplayMsg(2,NotifyInfo)
			SysRollAreaMsg(NotifyInfo)
			UnRegisterTick(Tick)
			g_GameMain.m_FbActionPanel.m_FreeTimeTick[RemindAction] = nil
		end
		
		-- ����ǲ���ʱ���2Сʱ����ʾ
		if not tonumber(StartHour) then
			local DisplayName = self.m_ActionName:GetWndText()
			local NotifyInfo = GetStaticTextClient(8003, DisplayName)
			g_GameMain.m_FbActionPanel.m_FreeTimeTick[RemindAction] = RegisterTick("FreeTimeTick", FreeTimeNotify, 2*60*60*1000, NotifyInfo)
			--print("2Сʱ����ʾһ�Σ���������")
			
		end
					
	else																		-- ȡ��ѡ��
		self.m_bSelectIsRemind = nil
		self.m_IsRemindBtn:SetCheck(false)
		
		local RemindTbl = g_GameMain.m_FbActionPanel.m_RemindAction[RemindAction]
		if RemindTbl ~= nil then
			for i=1, #(RemindTbl) do
				if RemindTbl[i][1]==StartHour and RemindTbl[i][2]==StartMin then
					--print("ɾ��"..RemindAction.."--"..StartHour..":"..StartMin)
					table.remove(RemindTbl, i)
					break
				end
			end
		end
		
		-- �ı���ɫ
		ItemWndChangeColor(self)
		
		-- ����Tick
		if g_GameMain.m_FbActionPanel.m_FreeTimeTick[RemindAction] then
			UnRegisterTick(g_GameMain.m_FbActionPanel.m_FreeTimeTick[RemindAction])
			g_GameMain.m_FbActionPanel.m_FreeTimeTick[RemindAction] = nil
			--print("����Tick!")
		end
	end
end

-- Item
function CFbActionPanelItemWnd:OnCtrlmsg(Child, uMsgID, uParam1, uParam2 )
	if(uMsgID == RICH_CLICK )	then
  	local value = self.m_StartPlace:GetChooseStrAttr()
		local linktbl = g_GameMain.m_FbActionPanel.m_QuestHypeLink[value]
		if linktbl then
			PlayerAutoTrack(value,linktbl[1],linktbl[2],linktbl[3])   -- Ѱ·
		end
	elseif uMsgID == BUTTON_LCLICK then 	
		if Child == self.m_IsRemindBtn then
			self:ClickSelectRemindBtn()		-- ����
		end
	end
end