gac_gas_require "activity/npc/CheckNpcTalk"
lan_load "npc/Lan_NpcTalk_Common"

CNpcTalkWnd = class(SQRDialog)

function CNpcTalkWnd:Ctor()
	self:CreateFromRes("NpcTalkWnd", g_GameMain)
	self.m_OKBtn = self:GetDlgChild("OKBtn")
	self.m_CancelBtn = self:GetDlgChild("CancelBtn")
	self.m_Text = self:GetDlgChild("Text")
	self.m_Title = self:GetDlgChild("Title")
	self.m_TalkName = ""
	self.m_TextNum = 0
	self.m_MaxNum = 0
	self.m_TempParams = {}
	g_ExcludeWndMgr:InitExcludeWnd(self, "�ǻ���")
end

function CNpcTalkWnd:OnCtrlmsg(Child, uMsgID, uParam1, uParam2)
	if uMsgID == BUTTON_LCLICK then
		self:ShowWnd(false)
		if Child == self.m_OKBtn then
			Gac2Gas:AddFinishNpcTalk(g_Conn, self.m_TalkName, self.m_TempParams[1], self.m_TempParams[3])
		end
	elseif uMsgID == RICHWND_LCLICKUP then
		if self.m_TextNum <= self.m_MaxNum then
			self:ShowNextText()
		end
	end
end
--��дVirtualExcludeWndOnClose����CloseExcludeWndʱ�����
function CNpcTalkWnd:VirtualExcludeWndOnClose()
	local RenderScene = g_CoreScene:GetRenderScene()
	RenderScene:SetCameraOffset( 2000 )
	--��ʾȫ��gui
	if g_App.m_IsGUIHide then
		OnGUIAlphaKey()	
	end
end

function CNpcTalkWnd:ShowNextText(NpcShowName)
	if NpcShowName then
		self.NpcShowName = NpcShowName	
	end
	
	if self.m_TextNum > self.m_MaxNum then
		return
	end
	local tbl = g_NpcTalkTbl[self.m_TalkName][self.m_TextNum]
	local text = Lan_NpcTalk_Common(MemH64(tbl.Index), "Describe")
	local title = Lan_NpcTalk_Common(MemH64(tbl.Index), "Title")
	local name = g_MainPlayer.m_Properties:GetCharName()
	local class = g_GameMain.m_DisplayCommonObj:GetPlayerClassForShow(g_MainPlayer:CppGetClass())
	text = string.gsub(text, "#Name#", name)
	text = string.gsub(text, "#Class#", class)
	
	self.m_Text:SetWndText(text)
	self.m_Title:SetWndText(self.NpcShowName)
	if self.m_TextNum ~= self.m_MaxNum then
		self.m_OKBtn:ShowWnd(false)
		self.m_CancelBtn:ShowWnd(false)
	else
		local t1 = Lan_NpcTalk_Common( MemH64(g_NpcTalkTbl[self.m_TalkName]["ȷ��"].Index), "Describe")
		local t2 = Lan_NpcTalk_Common( MemH64(g_NpcTalkTbl[self.m_TalkName]["ȡ��"].Index), "Describe")
		self.m_OKBtn:SetWndText(t1)
		self.m_OKBtn:ShowWnd(true)
		self.m_CancelBtn:SetWndText(t2)
		self.m_CancelBtn:ShowWnd(true)
	end
	self.m_TextNum = self.m_TextNum + 1
end

function CNpcTalkWnd:ShowNpcTalkWnd(TalkName, uEntityID, uBuildingTongID, IsUseTrigger)
	if not (IsCppBound(g_Conn) and g_MainPlayer) then
		return
	end
	

	
	-- �Ի����Ѿ���ʾ�˾ͷ���
	local Wnd = g_GameMain.m_NpcTalkWnd
	if Wnd:IsShow() then
		return
	end
	
	if TalkName == "" then
		RetShowFuncNpcOrObjTalkWnd(uEntityID, uBuildingTongID)
		return
	end
	
	local NpcObj = CCharacterFollower_GetCharacterByID(uEntityID)
	if NpcObj then 
		NpcObj:DoRespondActionBegin(g_MainPlayer)	--Npcת�����
	end
	
	--����ȫ��gui
	if not g_App.m_IsGUIHide then
		OnGUIAlphaKey()	
	end
	
	if IsUseTrigger then
		local RenderScene=g_CoreScene:GetRenderScene()
		RenderScene:SetCameraOffset(750)	--���������
	end
	local i = 1
	while g_NpcTalkTbl[TalkName][i] do
		i = i+1
	end
	
	Wnd.m_TalkName = TalkName
	Wnd.m_TextNum = 1
	Wnd.m_MaxNum = i-1
	Wnd.m_TempParams = {uEntityID, uBuildingTongID, IsUseTrigger}
	Wnd:ShowWnd(true)
	
	--local NpcName = NpcObj.m_Properties:GetCharName()
	local Camp = g_MainPlayer:CppGetCamp()
	local NpcName = g_NpcTalkTbl[TalkName]["����Npc"].Param1[Camp]
	local NpcShowName = GetNpcDisplayName(NpcName)
	Wnd:ShowNextText(NpcShowName)
end

function CNpcTalkWnd:RetShowFuncNpcOrObjTalkWnd()
	RetShowFuncNpcOrObjTalkWnd(self.m_TempParams[1], self.m_TempParams[2])
end
