--gac_require "relation/tong/TongShowRulesWndInc"
CShowRulesWnd = class(SQRDialog)

local ChallengeTypeTbl = {}
ChallengeTypeTbl["��ս����"] = 160002
ChallengeTypeTbl["��ս����"] = 160003
ChallengeTypeTbl["��Դ��ȡ����"] = 160004
ChallengeTypeTbl["������Դ�����"] = 160005
ChallengeTypeTbl["���﹥�ǽ���"] = 160006
ChallengeTypeTbl["������ȡ����"] = 160007
ChallengeTypeTbl["��ɱ���ֽ���"] = 160008


function CShowRulesWnd:Ctor(parent)
	self:CreateFromRes("DisplayRules",parent)
	self.m_ShowText = self:GetDlgChild("ShowText")
	self.m_CloseBtn = self:GetDlgChild("CloseBtn")
	self.m_CloseWndBtn = self:GetDlgChild("CloseWndBtn")
	self:ShowWnd(false)
end

function CShowRulesWnd:GetWnd(Type)
	if not g_GameMain.m_ChallengeIntroduce then
		g_GameMain.m_ChallengeIntroduce = CShowRulesWnd:new(g_GameMain)
	end
	local wnd = g_GameMain.m_ChallengeIntroduce
	local msg = ChallengeTypeTbl[Type]
	wnd.m_ShowText:SetWndText(GetStaticTextClient(msg)) 
	wnd:ShowWnd(true)
	return wnd	
end

--function CreateTongShowRulesWnd(parent, Type)
--	local Wnd = CShowRulesWnd:new()
--	Wnd:CreateFromRes("DisplayRules",parent)
--	Wnd.m_ShowText = Wnd:GetDlgChild("ShowText")
--	Wnd.m_CloseBtn = Wnd:GetDlgChild("CloseBtn")
--	Wnd.m_CloseWndBtn = Wnd:GetDlgChild("CloseWndBtn")
--	local msgId = ChallengeTypeTbl[Type]
--	Wnd.m_ShowText:SetWndText(GetStaticTextClient(msgId)) 
--	Wnd:ShowWnd(true)
--	
--	return Wnd	
--end

function CShowRulesWnd:OnCtrlmsg(Child, uMsgID, uParam1, uParam2 )
	if uMsgID == BUTTON_LCLICK then
		if(Child == self.m_CloseBtn) then
			self:ShowWnd(false)
		elseif (Child == self.m_CloseWndBtn) then
			self:ShowWnd(false)
		end
	end
end
