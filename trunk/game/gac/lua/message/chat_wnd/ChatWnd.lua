gac_require "message/chat_wnd/ChatWndInc"
gac_require "framework/common_wnd_ctrl/CommonCtrlInc"
gac_gas_require "player/PlayerMgr"
gac_require "message/chat_wnd/LinkInfo"
cfg_load "chat/ChannelTable_Client"
lan_load "chat/Lan_ChannelTable_Client"
cfg_load "chat/SysRollMsg_Client"
lan_load "npc/Lan_NpcTheater_Server"
lan_load "chat/Lan_SysRollMsg_Client"
gac_gas_require "framework/text_filter_mgr/TextFilterMgr"


local CampNameTbl = {
								[1] = GetStaticTextClient(2504), --"����"
								[2] = GetStaticTextClient(2505), --"��ʥ"
								[3] = GetStaticTextClient(2506), --"��˹"
								}
ChannelNameTbl = {}
ChannelNameTbl[1] = GacMenuText(1109)--"ϵͳ"
ChannelNameTbl[2] = GacMenuText(1101)--"����"
ChannelNameTbl[3] = GacMenuText(1104)--"��Ӫ"
ChannelNameTbl[4] = GacMenuText(1102)--"��ͼ"
ChannelNameTbl[5] = GacMenuText(1103)--"����"
ChannelNameTbl[6] = GacMenuText(1107)--"����"
ChannelNameTbl[7] = GacMenuText(1105)--"Ӷ��С��"
ChannelNameTbl[8] = GacMenuText(1108)--"Ӷ����"
ChannelNameTbl[9] = GacMenuText(1110)--"NPC"
ChannelNameTbl[10] = GacMenuText(1111)--"����"

ChannelNameMapIDTbl = {}
ChannelNameMapIDTbl[GacMenuText(1109)] = 1 --"ϵͳ"
ChannelNameMapIDTbl[GacMenuText(1101)] = 2--"����"
ChannelNameMapIDTbl[GacMenuText(1104)] = 3--"��Ӫ"
ChannelNameMapIDTbl[GacMenuText(1102)] = 4--"��ͼ"
ChannelNameMapIDTbl[GacMenuText(1103)] = 5--"����"
ChannelNameMapIDTbl[GacMenuText(1107)] = 6--"����"
ChannelNameMapIDTbl[GacMenuText(1105)] = 7--"Ӷ��С��"
ChannelNameMapIDTbl[GacMenuText(1108)] = 8--"Ӷ����"
ChannelNameMapIDTbl[GacMenuText(1110)] = 9--"NPC"
ChannelNameMapIDTbl[GacMenuText(1111)] = 10--"����"

--������ڱ��������¼��
local g_MessageNumber = 150 *4
--����������ʾ��������
local g_WndCBTnAmount = 0
--�����
local g_WndCBTnSelectID = 1	
--Ƶ�����
local g_ChannelId = 5
local lasttime = {0,0,0,0,0,0,0,0,0}

--��������¼����
local chatRecordNumber = 10

local ChannelColorTbl = {}
ChannelColorTbl[1] = g_ColorMgr:GetColor("ϵͳ")
ChannelColorTbl[2] = g_ColorMgr:GetColor("����")
ChannelColorTbl[3] = g_ColorMgr:GetColor("��Ӫ")
ChannelColorTbl[4] = g_ColorMgr:GetColor("��ͼ")
ChannelColorTbl[5] = g_ColorMgr:GetColor("����")
ChannelColorTbl[6] = g_ColorMgr:GetColor("����")
ChannelColorTbl[7] = g_ColorMgr:GetColor("Ӷ��С��")
ChannelColorTbl[8] = g_ColorMgr:GetColor("Ӷ����")
ChannelColorTbl[9] = g_ColorMgr:GetColor("����")
local FontSize = 14

--�Ƿ���������
local IsAddNewWnd = false
--[[
		Ƶ����Ϣ�Ķ���Ϊ1
		Ƶ����Ϣ��δ����Ϊ0
--]]


--�������������ʾ���ư�ť��Դ
local function CreateChatWndShow()
	local Wnd = CChatWndShow:new()
	Wnd:CreateFromRes("ChatWndShow",g_GameMain)
	Wnd.m_ChatWndShowBTn = Wnd:GetDlgChild("ChatWndShowBTn")

	g_GameMain.m_ChatWndShow = Wnd
end

function CChatWndShow:OnCtrlmsg(Child, uMsgID, uParam1, uParam2 )
	if(Child == self.m_ChatWndShowBTn and uMsgID == BUTTON_LCLICK) then
		self:ShowWnd(false)
		g_GameMain.m_CreateChatWnd.m_CChatWnd:ShowWnd(true)
	end
end

--����Ƶ���������
local function CreateChatFilter()
	g_GameMain.m_ChatFilter = {}
	for j = 1, 5 do
		local Wnd = CChatFilter:new()
		Wnd:CreateFromRes("ChatFilter",g_GameMain)
		Wnd.CheckTbl = {}
		for i = 1,9 do
			Wnd.CheckTbl[i] = Wnd:GetDlgChild("Check" .. i)
		end
	
		Wnd.m_ChatFilterCBTnYes = Wnd:GetDlgChild("ChatFilterCBTnYes")
		Wnd.m_ChatFilterCBTnNo = Wnd:GetDlgChild("ChatFilterCBTnNo")
		
		Wnd.CheckArray = {}
		for i = 1,#(Wnd.CheckTbl) do
			Wnd.CheckArray[i] = Wnd.CheckTbl[i]
		end
		g_GameMain.m_ChatFilter[j] = Wnd
	end
end


--��������������
function CreateChatWnd(Parent)
	
	local Wnd = CChatWndAll:new();
	--�������췢����
	Wnd.m_ChatSendArea = CChatSendArea:new()
	--��������ϵͳ��Ϣ��
	Wnd.m_CSysRollArea = CSysRollArea:new();
	
	--ÿ��Сʱ��50���ӵ�ʱ�򲥷�ϵͳ��Ϣ
	Wnd.m_CSysRollArea.m_ChatWndTick = RegisterTick("CheckTime", CheckTime , 1000*60)
	
	--����������ʾ��
	Wnd.m_CChatWnd = CChatWnd:new();
	--������Ҫ��Ϣ��ʾ��
	Wnd.m_ImportMsg = CImportMsg:new()
	
	--�������췢������Դ
	Wnd.m_ChatSendArea:CreateFromRes("ChatSendArea", Parent)
	Wnd.m_ChatSendArea.m_CBTnChannelChose = Wnd.m_ChatSendArea:GetDlgChild("CBTnChannelChose")
	Wnd.m_ChatSendArea.m_CBTnChannelChose:SetWndText(ChannelNameTbl[g_ChannelId])
	Wnd.m_ChatSendArea.m_CBTnFace = Wnd.m_ChatSendArea:GetDlgChild("CBTnFace")
	Wnd.m_ChatSendArea.m_CBTnFace:EnableWnd(false)
	Wnd.m_ChatSendArea.m_CBTMessageSend = Wnd.m_ChatSendArea:GetDlgChild("CBTnMessageSend")
	Wnd.m_ChatSendArea.m_CEditMessage = Wnd.m_ChatSendArea:GetDlgChild("CEditMessage")
	Wnd.m_ChatSendArea.m_CEditMessage:SetMaxTextLenght(50)
	Wnd.m_ChatSendArea.m_CBTnAction = Wnd.m_ChatSendArea:GetDlgChild("CBTnAction")
	Wnd.m_ChatSendArea.m_CBTnAction:EnableWnd(false)
	Wnd.m_ChatSendArea.ItemTable = {} 
	
	--���ع���ϵͳ��Ϣ����Դ
	Wnd.m_CSysRollArea:CreateFromRes("SysRollArea", Parent)
	Wnd.m_CSysRollArea:SetIsBottom(true)
	Wnd.m_CSysRollArea.m_SysRollAreaWord  = Wnd.m_CSysRollArea:GetDlgChild("SysRollAreaWord")
	Wnd.m_CSysRollArea:ShowWnd(true)
	--����������ʾ����Դ
	Wnd.m_CChatWnd:CreateFromRes("ChatWnd",Parent)
	Wnd.m_CChatWnd:ShowWnd( true )
	Wnd.m_CChatWnd:SetIsBottom(true)
	Wnd.m_CChatWnd.m_CBTnMin = Wnd.m_CChatWnd:GetDlgChild("CBTnMin")
	Wnd.m_CChatWnd.m_CBTnClose = Wnd.m_CChatWnd:GetDlgChild("CBTnClose")
	--��ɫ����
	local Flag = IMAGE_PARAM:new(SM_RW_BK, IP_ENABLE)
	
	Wnd.m_CChatWnd.m_ChatWndArea = Wnd.m_CChatWnd:GetDlgChild("ChatWndArea")
	Wnd.m_CChatWnd.m_ChatWndArea:SetToAutoFormat( false )
	Wnd.m_CChatWnd.m_ChatWndArea:SetDepth(0)
	Wnd.m_CChatWnd.m_ChatWndArea:SetWndTextColor(Flag,4294901760 )
	Wnd.m_CChatWnd.m_ChatFilterCBTn = Wnd.m_CChatWnd:GetDlgChild("ChatFilterCBTn")
	Wnd.m_CChatWnd.m_ChatSociality = Wnd.m_CChatWnd:GetDlgChild("ChatSociality")
	Wnd.m_CChatWnd.m_ChatSociality:ShowWnd(false)
	Wnd.m_CChatWnd.m_CBTnLug = Wnd.m_CChatWnd:GetDlgChild("CBTnLug")
	Wnd.m_CChatWnd.m_CBTnLug:ShowWnd(true)
	--������Ҫ��Ϣ��ʾ����Դ
	Wnd.m_ImportMsg:CreateFromRes("ImportMsg",Parent)
	Wnd.m_ImportMsg:ShowWnd( true )
	Wnd.m_ImportMsg.m_ImportMsgText1 = Wnd.m_ImportMsg:GetDlgChild("ImportMsgText1")
	Wnd.m_ImportMsg.m_ImportMsgText2 = Wnd.m_ImportMsg:GetDlgChild("ImportMsgText2")
	Wnd.m_ImportMsg.m_ImportMsgText3 = Wnd.m_ImportMsg:GetDlgChild("ImportMsgText3")
	Wnd.m_ImportMsg.m_ImportMsgText4 = Wnd.m_ImportMsg:GetDlgChild("ImportMsgText4")
	Wnd.m_ImportMsg.m_ImportMsgText5 = Wnd.m_ImportMsg:GetDlgChild("ImportMsgText5")
	Wnd.m_ImportMsg.m_ImportMsgText1:ShowWnd(false)
	Wnd.m_ImportMsg.m_ImportMsgText2:ShowWnd(false)
	Wnd.m_ImportMsg.m_ImportMsgText3:ShowWnd(false)
	Wnd.m_ImportMsg.m_ImportMsgText4:ShowWnd(false)
	Wnd.m_ImportMsg.m_ImportMsgText5:ShowWnd(false)
	--�������������ʾ���ư�ť
	CreateChatWndShow()
	--��������Ƶ�����˴���
	CreateChatFilter()
	--��ʼ�����
	Wnd.m_CChatWnd:ReadDefaultSet()
	Wnd.m_CChatWnd:ReadFontSet()
	g_WndCBTnSelectID = 1	
	Wnd.m_MsgShowWnd = CMsgShow:new()
	Wnd.m_MsgShowWnd:CreateFromRes("MsgShowWnd",Parent)
	Wnd.m_MsgShowWnd.m_CancleBtn = Wnd.m_MsgShowWnd:GetDlgChild("CancleBtn")
	Wnd.m_MsgShowWnd.m_OkBtn = Wnd.m_MsgShowWnd:GetDlgChild("OkBtn")
	Wnd.m_MsgShowWnd.m_CheckBtn = Wnd.m_MsgShowWnd:GetDlgChild("CheckBtn")
	Wnd.m_MsgShowWnd.m_MsgShowText = Wnd.m_MsgShowWnd:GetDlgChild("ShowMsgText")
	Wnd.m_MsgShowWnd.m_CloseBtn = Wnd.m_MsgShowWnd:GetDlgChild("CloseBtn")
	
	Wnd.m_CHItemMsgShowWnd = CCHItemMsgShow:new()
	Wnd.m_CHItemMsgShowWnd:CreateFromRes("ChuanShengMsgShowWnd1",Parent)
	Wnd.m_CHItemMsgShowWnd.m_CancleBtn = Wnd.m_CHItemMsgShowWnd:GetDlgChild("CancleBtn")
	Wnd.m_CHItemMsgShowWnd.m_OkBtn = Wnd.m_CHItemMsgShowWnd:GetDlgChild("OkBtn")
	Wnd.m_CHItemMsgShowWnd.m_CheckBtn = Wnd.m_CHItemMsgShowWnd:GetDlgChild("CheckBtn")
	Wnd.m_CHItemMsgShowWnd.m_CloseBtn = Wnd.m_CHItemMsgShowWnd:GetDlgChild("CloseBtn")
	
	Wnd.m_CCHMsgWnd = CCHMsgWnd:new()
	Wnd.m_CCHMsgWnd:CreateFromRes("CHMsgWnd",Parent)
	Wnd.m_CCHMsgWnd.m_TextWnd = Wnd.m_CCHMsgWnd:GetDlgChild("TextWnd")
	
	Wnd.m_CHMoneyMsgShowWnd = CCHMoneyMsgShow:new()
	Wnd.m_CHMoneyMsgShowWnd:CreateFromRes("ChuanShengMsgShowWnd2",Parent)
	Wnd.m_CHMoneyMsgShowWnd.m_CancleBtn = Wnd.m_CHMoneyMsgShowWnd:GetDlgChild("CancleBtn")
	Wnd.m_CHMoneyMsgShowWnd.m_OkBtn = Wnd.m_CHMoneyMsgShowWnd:GetDlgChild("OkBtn")
	Wnd.m_CHMoneyMsgShowWnd.m_CheckBtn = Wnd.m_CHMoneyMsgShowWnd:GetDlgChild("CheckBtn")
	Wnd.m_CHMoneyMsgShowWnd.m_CloseBtn = Wnd.m_CHMoneyMsgShowWnd:GetDlgChild("CloseBtn")
	
	return Wnd
end

function CChatWnd:OnChildCreated()
	self.CBtnTbl = {}
	for i = 1,5 do
		self.CBtnTbl[i] = self:GetDlgChild("CBTn" .. i)
	end
	self.CBtnTbl[1]:SetCheck(true)
end

function CChatWnd:CheckInputActive( Wnd, Msg, wParam, lParam )
	g_GameMain.m_CreateChatWnd.m_ChatSendArea:CheckChatSendAreaActive()
end

function CChatSendArea:Ctor()
	self.ChatMnueArray = {}
	self.ArrayCount = 1
	self.m_AllChatContentArray = {}
	self.m_CurrentSelectID = 0
	self.m_IsFirstSelect = true
	self.bIsShow = false
end

--��סshift���������������Ƶ�����淢��һ�����������(posx��posy)�����ĳ����ӣ������ҿ��Ե���Զ�Ѱ·��������
local function AttoLinkToPlayer(position)
	assert(IsString(position))
	if position ~= "" then
		local b = string.find(position,"%(")
		local c = string.find(position,"%)")
		local d = string.find(position,"%,")
		if b == nil or c == nil or d == nil then
			return 
		end
		local posx = string.sub(position,b+1,d -1)
		local posy = string.sub(position,d+1,c-1)
		local sceneName = string.sub(position,2,b-1)
		PlayerAutoTrack("",sceneName,tonumber(posx),tonumber(posy))
	end
end

function CMsgShow:OnCtrlmsg(Child, uMsgID, uParam1, uParam2)
	if( uMsgID == BUTTON_LCLICK ) then
		if ( Child == self.m_CloseBtn or Child == self.m_CancleBtn ) then
			self:ShowWnd(false)
		elseif (Child == self.m_OkBtn) then
			self:ShowWnd(false)
			g_GameMain.m_CreateChatWnd.m_ChatSendArea:MessageSend()
			if self.m_CheckBtn:GetCheck() then
				Gac2Gas:SaveNotShowMsgWnd(g_Conn,"����Ƶ������")
			end
		elseif (Child == self.m_CheckBtn) then
			self.m_CheckBtn:SetCheck(true)
		end
	end
end

function CCHItemMsgShow:OnCtrlmsg(Child, uMsgID, uParam1, uParam2)
	if( uMsgID == BUTTON_LCLICK ) then
		if ( Child == self.m_CloseBtn or Child == self.m_CancleBtn ) then
			self:ShowWnd(false)
		elseif (Child == self.m_OkBtn) then
			self:ShowWnd(false)
			g_GameMain.m_CreateChatWnd.m_ChatSendArea:MessageSend()
			if self.m_CheckBtn:GetCheck() then
				Gac2Gas:SaveNotShowMsgWnd(g_Conn,"����Ƶ������Ϣ������Ʒ")
			end
		elseif (Child == self.m_CheckBtn) then
			self.m_CheckBtn:SetCheck(true)
		end
	end
end

function CCHMoneyMsgShow:OnCtrlmsg(Child, uMsgID, uParam1, uParam2)
	if( uMsgID == BUTTON_LCLICK ) then
		if ( Child == self.m_CloseBtn or Child == self.m_CancleBtn ) then
			self:ShowWnd(false)
		elseif (Child == self.m_OkBtn) then
			self:ShowWnd(false)
			g_GameMain.m_CreateChatWnd.m_ChatSendArea:MessageSend()
			if self.m_CheckBtn:GetCheck() then
				Gac2Gas:SaveNotShowMsgWnd(g_Conn,"����Ƶ������Ϣ��Ǯ")
			end
		elseif (Child == self.m_CheckBtn) then
			self.m_CheckBtn:SetCheck(true)
		end
	end
end

--���Ƶ������ʱ�ص�����
local function SetChannelId(ChannelName)
	local Wnd = g_GameMain.m_CreateChatWnd.m_ChatSendArea
	g_ChannelId = ChannelNameMapIDTbl[ChannelName]
	Wnd.m_CBTnChannelChose:SetWndText(ChannelName)
	Wnd:ShowWnd(true)
end

local function AttoLinkFun(wnd)
	local value = wnd:GetChooseStr()
	local StrAttr = wnd:GetChooseStrAttr()
	if StrAttr == "" then
		if g_MainPlayer ~= nil then
			local CharName = g_MainPlayer.m_Properties:GetCharName()
			if CharName == value then
				return
			end
		end
		local Wnd = g_GameMain.m_CreateChatWnd.m_ChatSendArea
		if(Wnd:GetTransparent() < 0.5 or Wnd:IsShow() == false  ) then
			Wnd:ShowWnd(true)
			Wnd.m_CEditMessage:ShowWnd(true)
			Wnd:SetTransparent(0.1)
			Wnd:SetTransparentObj(200,false)
		end
		value = "/" .. value .. " "
		Wnd.bIsShow = true
		local strLen = string.len(value)	
		Wnd.m_CEditMessage:SetWndText(value)	
		Wnd.m_CEditMessage:setCaratIndex(strLen)
		Wnd.m_CEditMessage:SetFocus()			
	else
		local index = string.find(StrAttr,"&")
		local temp_char = string.find(StrAttr,"*")
		if index then
			SetChannelId(value)
		elseif temp_char then
			AttoLinkToPlayer(StrAttr)
		else
			Gac2Gas:GetInfoByID(g_Conn,StrAttr)
		end
	end			
end


local function AddMenFun(wnd,uParam1,uParam2)
	local value = wnd:GetChooseStr()	
	local playerName = g_MainPlayer.m_Properties:GetCharName()
	if value == playerName then
		return
	end
	local StrAttr = wnd:GetChooseStrAttr()
	g_GameMain.m_CreateChatWnd.m_CChatWnd.SelectValue = value
	if StrAttr == "" then
		local Menu = CreateChatMenu()
		Menu:SetPos(uParam1, uParam2)
		wnd.m_Menu = Menu 
	end
end

function CCHMsgWnd:OnCtrlmsg(Child, uMsgID, uParam1, uParam2)
	if(uMsgID == RICH_RCLICK and Child == self.m_TextWnd) then
		AddMenFun(self.m_TextWnd,uParam1,uParam2)
	elseif (uMsgID  == RICH_CLICK and Child == self.m_TextWnd) then
		AttoLinkFun(self.m_TextWnd)
	end
end

function CChatSendArea:OnEscMsg()
	self.m_CEditMessage:SetWndText("")
	self.m_CEditMessage:ShowWnd(false)
	self:SetTransparentObj(200, true) 
	self:ShowWnd(false)
	self.bIsShow = false
	if g_GameMain.m_CreateChatWnd.m_MsgShowWnd:IsShow() then
		g_GameMain.m_CreateChatWnd.m_MsgShowWnd:ShowWnd(false)
	end
	if g_GameMain.m_CreateChatWnd.m_CHItemMsgShowWnd:IsShow() then
		g_GameMain.m_CreateChatWnd.m_CHItemMsgShowWnd:ShowWnd(false)
	end
	if g_GameMain.m_CreateChatWnd.m_CHMoneyMsgShowWnd:IsShow() then
		g_GameMain.m_CreateChatWnd.m_CHMoneyMsgShowWnd:ShowWnd(false)
	end
end

--����ģ����Ϣ��Ӧ
function CChatSendArea:OnCtrlmsg( Child, uMsgID, uParam1, uParam2 )
	if( uMsgID == BUTTON_LCLICK ) then
		if ( Child == self.m_CBTnChannelChose ) then
			local Menu = CreateChannel()
			if self.m_Menu then
				self.m_Menu:Destroy()
				self.m_Menu = nil
			end
			Menu:ShowWnd(true)
			local Rect = CFRect:new()
			self.m_CBTnChannelChose:GetLogicRect(Rect)
			Menu:SetPos(Rect.left, Rect.top)
			self.m_Menu = Menu
		elseif( Child == self.m_CBTnFace ) then
			CreateChatCBTnFace()    
		elseif Child == self.m_CBTnAction then
			local wnd = g_GameMain.m_WndAction
			wnd:ShowWnd(not wnd:IsShow())
		elseif( Child == self.m_CBTMessageSend ) then
			self:CheckChatSendAreaActive()
		end

		
	elseif uMsgID == WND_NOTIFY then		
		if (uParam1 == WM_CHAR) then
			if( Child == self.m_CEditMessage ) then			
				if uParam2 == 9 then
					self:OnTabRespond()
					self.m_CEditMessage:SetFocus()
					return
				end
				
				local value = self.m_CEditMessage:GetWndText()
				local temp = string.find(value," ")
				if( value == "/") then
					if( self.ArrayCount ~= 1 ) then
						
						if nil ~= self.m_ChatMenu then
							self.m_ChatMenu:Destroy()
							self.m_ChatMenu = nil
						end 
						local Menu = self:CreateAddChatMnue()
						local Rect = CFRect:new()
						self.m_CEditMessage:GetLogicRect(Rect)
						Menu:SetPos(Rect.left, Rect.top-90)
						self.m_CEditMessage:SetWndText("/")
						self.m_CEditMessage:SetFocus()
						self.m_ChatMenu = Menu
						self.m_ChatMenu:OnActive(true)
					end	
				end
				if(temp ~= nil ) then
					if(temp > 2)then
						if( self.m_ChatMenu ~= nil ) then
							self.m_ChatMenu:OnActive(false)
						end
					end
				end
			end		
		end
	end
	local Wnd = g_GameMain.m_CreateChatWnd.m_ChatSendArea
	if uMsgID == EDIT_RETURN   and Child == self.m_CEditMessage then
		Wnd:CheckChatSendAreaActive()
	elseif uMsgID == VK_ESCAPE then
		self:OnEscMsg()
	elseif uMsgID == VK_UP then
		if( Wnd.m_CEditMessage:IsFocus()) then
			if(Wnd.m_ChatMenu ~= nil ) then
				if( Wnd.m_ChatMenu:notShow() ) then
					Wnd.m_ChatMenu:OnKeyDown(uMsgID,lParam)
					return
				end
			end

			if( Wnd.m_AllChatContentArray ~= nil and #(Wnd.m_AllChatContentArray) > 0) then
				if Wnd.m_CurrentSelectID > 0 then
					if  self.m_IsFirstSelect then
						self.m_IsFirstSelect = false
					else
						Wnd.m_CurrentSelectID = Wnd.m_CurrentSelectID - 1
						if Wnd.m_CurrentSelectID <= 0 then
							Wnd.m_CurrentSelectID = 1 
						end
					end
				end
				
				if Wnd.m_AllChatContentArray[Wnd.m_CurrentSelectID] ~= nil then
					Wnd.m_CEditMessage:SetWndText(Wnd.m_AllChatContentArray[Wnd.m_CurrentSelectID])
					local strLen = string.len(Wnd.m_AllChatContentArray[Wnd.m_CurrentSelectID])
					Wnd.m_CEditMessage:setCaratIndex(strLen)
				end
			end
		end
	elseif uMsgID == VK_DOWN then
		if( Wnd.m_CEditMessage:IsFocus()) then
			if(Wnd.m_ChatMenu ~= nil ) then
				if( Wnd.m_ChatMenu:notShow() ) then
					Wnd.m_ChatMenu:OnKeyDown(uMsgID,lParam)
				end
				return
			end

			if( Wnd.m_AllChatContentArray ~= nil and #(Wnd.m_AllChatContentArray) > 0 ) then
				if Wnd.m_CurrentSelectID > 0 then
					if  Wnd.m_AllChatContentArray[Wnd.m_CurrentSelectID + 1]  then
						self.m_IsFirstSelect = false
						Wnd.m_CurrentSelectID = Wnd.m_CurrentSelectID + 1
						if Wnd.m_CurrentSelectID > chatRecordNumber then
							Wnd.m_CurrentSelectID = chatRecordNumber 
						end
					else
						return
					end
				end
				if Wnd.m_AllChatContentArray[Wnd.m_CurrentSelectID] ~= nil then
					Wnd.m_CEditMessage:SetWndText(Wnd.m_AllChatContentArray[Wnd.m_CurrentSelectID])
					local strLen = string.len(Wnd.m_AllChatContentArray[Wnd.m_CurrentSelectID])
					Wnd.m_CEditMessage:setCaratIndex(strLen)
				end
			end
		end
	end
end

--��tab������ӦƵ���л�
function CChatSendArea:OnTabRespond()
	local Menu = CreateChannel()
  local MenuContentTbl = {}
	local CurrentID = 1					
	for i=0,#Menu.m_Items do
		MenuContentTbl[i] = Menu.m_Items[i].Context[1]
	end
	Menu:Destroy()	
	for i,v in pairs(MenuContentTbl) do
		if v == self.m_CBTnChannelChose:GetWndText() then
			CurrentID = i
		end
	end
	if CurrentID + 1 <= #MenuContentTbl then 
		self.m_CBTnChannelChose:SetWndText(MenuContentTbl[CurrentID + 1])
	else
		self.m_CBTnChannelChose:SetWndText(MenuContentTbl[0])
	end	 
	for k,v in pairs(ChannelNameTbl) do
		if v == self.m_CBTnChannelChose:GetWndText() then
			g_ChannelId = k
		end
	end	
end

--ȥ��#�ַ���
local function ReplaceForbidChar(Msg)
	local tempMsg = string.gsub(Msg, "#","") 
	return tempMsg
end

function CChatSendArea:CheckMsgIsSend()
	local Msg = self.m_CEditMessage:GetWndText()
	if g_ChannelId == 2 and Msg ~= "" then
		if g_MainPlayer.m_ItemBagLock then
			MsgClient(160030)
			return
		end
			
		if g_MainPlayer.m_nMoney < 2000 then
			MsgClient(305)
			return
		end
		local wnd = g_GameMain.m_CreateChatWnd.m_MsgShowWnd
		if not wnd.m_CheckBtn:GetCheck() then
			wnd.m_MsgShowText:SetWndText(GetStaticTextClient(1509,20))
			wnd:ShowWnd(true)
			return 
		end
	elseif g_ChannelId == 10 and Msg ~= "" then
		if g_MainPlayer.m_ItemBagLock then
			MsgClient(160029)
			return
		end
		local item_count = g_GameMain.m_BagSpaceMgr:GetItemCountBySpace( g_StoreRoomIndex.PlayerBag, 1, "����ʯ" )
		if item_count == 0 then
			if g_MainPlayer.m_nMoney < 50000 then
				MsgClient(210)
				return
			else
				local wnd = g_GameMain.m_CreateChatWnd.m_CHMoneyMsgShowWnd
				if not wnd.m_CheckBtn:GetCheck() then
					wnd:ShowWnd(true)
					return 
				end
			end
		else
			local wnd = g_GameMain.m_CreateChatWnd.m_CHItemMsgShowWnd
			if not wnd.m_CheckBtn:GetCheck() then
				wnd:ShowWnd(true)
				return 
			end
		end
	end
	self:MessageSend()
end

function CChatSendArea:MessageSend()
	self.m_IsFirstSelect = true
	local Msg = self.m_CEditMessage:GetWndText()
	if(Msg~="") then
		Msg = string.gsub(Msg, "/&", "&")
		local index = string.find(Msg, "/")
		local temp = string.find(Msg," ")
		if( temp ~= nil and index ~= nil) then
			if( index == 1 and temp ~= 2 ) then
				local content = string.sub(Msg,temp+1,-1)
				content = ReplaceForbidChar(content)
				local _, amount = string.gsub(content, "%S", "")
				if( amount ~= 0 ) then
					local name  = string.sub(Msg,2,temp-1)
					local all = string.sub(Msg, 2, -1)
					if name ~= g_MainPlayer.m_Properties:GetCharName() then
						g_GameMain.m_AssociationWnd:StartChatByName(name, content) --˽��
					end
					self.m_CEditMessage:SetWndText("")
				else
					self.m_CEditMessage:SetWndText("")
					if( self.m_ChatMenu ~= nil ) then
						self.m_ChatMenu:OnActive(false)
					end
				end
				self:CreateAllChatContent(Msg)
			else
				if(ChannelSentCheck()) then
					self:CreateAllChatContent(Msg)
					Msg = ReplaceForbidChar(Msg)
					Msg = AddItemName(Msg)
					Gac2Gas:TalkToChannel(g_Conn, Msg, g_ChannelId)
				end
				self.m_CEditMessage:SetWndText("")
			end
		else
			if(ChannelSentCheck()) then
				self:CreateAllChatContent(Msg)
				Msg = ReplaceForbidChar(Msg)
				Msg = AddItemName(Msg)
				Gac2Gas:TalkToChannel(g_Conn, Msg, g_ChannelId)
			end
			self.m_CEditMessage:SetWndText("")
		end		
	end
	if self.m_ChatMenu then
		if self.m_ChatMenu:notShow() then
			self.m_ChatMenu:ShowWnd(false)
		end
	end
	self.bIsShow = false
	self:SetTransparentObj(200,true)
	self.m_CEditMessage:ShowWnd(false)
	if self.m_Menu then
		self.m_Menu:ShowWnd(false)
	end
end

--���ؼ�����Ϣ
function CChatSendArea:CheckChatSendAreaActive()
	if(1 == g_GameMain.m_SceneStateForClient) then
		MsgClient(3311)
		return
	end
	local toLoginBox,ExitGameBox = g_GameMain.m_ToLoginMsgBox,g_GameMain.m_ExitGameMsgBox
	if (toLoginBox ~=nil and toLoginBox.m_CountDownTick ~= nil) or (ExitGameBox ~= nil and nil ~= ExitGameBox.m_CountDownTick) then
		--˵����Ϸ����ʱ�����ܷ�������Ϣ
		return
	end
	local wnd = g_GameMain.m_CreateChatWnd.m_CChatWnd
	if nil ~= wnd.m_Menu then
		wnd.m_Menu:Destroy()
		wnd.m_Menu = nil
	end
	if(not self.bIsShow ) then
		self.bIsShow = true
		self:ShowWnd(true)
		self:SetTransparent(0.1)
		self:SetTransparentObj(200,false)
		self.m_CEditMessage:ShowWnd(true)
		self.m_CEditMessage:SetFocus()
	else
		self:CheckMsgIsSend()
	end
	if g_MainPlayer and g_MainPlayer.m_Properties:GetTeamID() == 0 then
		if self.m_CBTnChannelChose:GetWndText() == ChannelNameTbl[6] then
			self.m_CBTnChannelChose:SetWndText(ChannelNameTbl[5])
			g_ChannelId =  ChannelIdTbl["����"]
		end
	end
end


--����Ƶ���������
local function ShowChatFilter(IsAddNewWnd)
	local index = 1
	if IsAddNewWnd then
		index = g_WndCBTnAmount + 1
	else
		index = g_WndCBTnSelectID
	end
	local Wnd = g_GameMain.m_ChatFilter[index]
	for i = 1, #(Wnd.CheckArray) do 
		if (g_GameMain.m_CreateChatWnd.m_CChatWnd.CBTnArray[index][i].IsSubscribe == 1) then	
			Wnd.CheckArray[i]:SetCheck(true)
		else
			Wnd.CheckArray[i]:SetCheck(false)
		end
	end
	Wnd.m_WndCBTnSelectID = index
	Wnd:ShowWnd(true)
end

--��Ӧ��������´��ڲ˵�
local function CreateAddNewWnd()
	local Wnd = CAddNewWnd:new()
	Wnd:CreateFromRes("AddNewWnd",g_GameMain)
	Wnd:ShowWnd( true )
	Wnd.m_AddNewWndEdit = Wnd:GetDlgChild("AddNewWndEdit")
	Wnd.m_AddCBTnYes = Wnd:GetDlgChild("AddCBTnYes")
	Wnd.m_AddCBTnNo  = Wnd:GetDlgChild("AddCBTnNo")
	g_GameMain.m_AddNewWnd = Wnd
end

--��Ӧ����Ƴ����ڲ˵�
local function CreateDeleteWnd()
	local Wnd = CDeleteWnd:new()
	Wnd:CreateFromRes("DeleteWnd",g_GameMain)
	Wnd:ShowWnd( true )
	Wnd.m_DeleteCBTnYes = Wnd:GetDlgChild("DeleteCBTnYes")
	Wnd.m_DeleteCBTnNo  = Wnd:GetDlgChild("DeleteCBTnNo")
	Wnd.m_WndCBTnSelectID = g_WndCBTnSelectID
	g_GameMain.m_DeleteWnd = Wnd
end

--����������
local function CreateRenameWnd()
	local Wnd = CRenameWnd:new()
	Wnd:CreateFromRes("RenameWnd",g_GameMain)
	Wnd:ShowWnd( true )
	Wnd.m_RenameCBTnYes = Wnd:GetDlgChild("RenameCBTnYes")
	Wnd.m_RenameCBTnNo = Wnd:GetDlgChild("RenameCBTnNo")
	Wnd.m_RenameWndEdit = Wnd:GetDlgChild("RenameWndEdit")
	Wnd.m_WndCBTnSelectID = g_WndCBTnSelectID
	g_GameMain.m_RenameWnd = Wnd
end

--��Ӧ����������촰�ڲ˵�
local function CreateChatWndAfreshSet()
	local Wnd = CChatWndAfreshSet:new()
	Wnd:CreateFromRes("ChatWndAfreshSet",g_GameMain)
	Wnd:ShowWnd( true )
	Wnd.m_AfreshSetYes = Wnd:GetDlgChild("AfreshSetYes")
	Wnd.m_AfreshSetNo = Wnd:GetDlgChild("AfreshSetNo")
end

--���������С
local function CreateSetFontSize()
	local Menu = g_GameMain.m_ChildMenu
	local Wnd = g_GameMain.m_CreateChatWnd.m_CChatWnd
	local MenuName = Menu:GetItemName()
	if MenuName == GacMenuText(901) then
		Wnd.m_ChatWndArea:SetFontSize(FontSize-2)
	elseif MenuName == GacMenuText(902) then
		Wnd.m_ChatWndArea:SetFontSize(FontSize)
	elseif MenuName == GacMenuText(903) then
		Wnd.m_ChatWndArea:SetFontSize(FontSize+2)
	end
	
	Wnd.m_ChatWndArea:SetWndText(Wnd.m_ChatWndArea:GetWndText())
	Wnd.m_Menu:Destroy()
	local strFileName = g_RootPath .. "var/gac/ChatSetting.txt"
	local f = CLuaIO_Open(strFileName, "w")
	if f ~= nil then
		local fontSize = Wnd.m_ChatWndArea:GetFontSize() 
		f:WriteNum(fontSize)
		f:Close()
	end
end

--�����������崰��
local function CraetFontChildMenu()
	local Wnd = g_GameMain.m_CreateChatWnd.m_CChatWnd
	local fontsize = Wnd.m_ChatWndArea:GetFontSize()
	local Menu = CMenu:new("TargetMenu",Wnd.m_Menu)
	if fontsize == FontSize then
		Menu:InsertItem(GacMenuText(901),CreateSetFontSize,nil,true,false,nil)--С
		Menu:InsertItem(GacMenuText(903),CreateSetFontSize,nil,true,false,nil)--��
	elseif fontsize > FontSize then
		Menu:InsertItem(GacMenuText(901),CreateSetFontSize,nil,true,false,nil)--С
		Menu:InsertItem(GacMenuText(902),CreateSetFontSize,nil,true,false,nil)--��
	elseif fontsize < FontSize then
		Menu:InsertItem(GacMenuText(902),CreateSetFontSize,nil,true,false,nil)--��
		Menu:InsertItem(GacMenuText(903),CreateSetFontSize,nil,true,false,nil)--��
	end
	local rect = Wnd.m_Menu:GetItemRect(Wnd.m_Menu:GetMaxSize())
	Menu:SetPos(rect.right, rect.top)	
	g_GameMain.m_ChildMenu =  Menu	
end

--�����Ҽ��˵�����
local function CreateRMenu ()
	local Menu = CMenu:new("TargetMenu",g_GameMain)
	if g_WndCBTnSelectID ~= 3 then
		Menu:InsertItem(GacMenuText(1001),ShowChatFilter,nil,false,false,nil)	--���ڹ�����
	end
	Menu:InsertItem(GacMenuText(1002),CreateAddNewWnd,nil,false,false,nil)			--�����´���
	if g_WndCBTnSelectID ~= 1 and g_WndCBTnSelectID ~= 2 and g_WndCBTnSelectID ~= 3 then
		Menu:InsertItem(GacMenuText(1003),CreateDeleteWnd,nil,false,false,nil)		--�Ƴ�����
		Menu:InsertItem(GacMenuText(1004),CreateRenameWnd,nil,false,false,nil)		--������
	end
	Menu:InsertItem(GacMenuText(1005),CreateChatWndAfreshSet,nil,false,false,nil)	--�������촰��
	Menu:InsertItem(GacMenuText(1006),nil,nil,false,true,CraetFontChildMenu,self)	--�����С >>
	Menu:SetUpwards(true)
	return Menu
end

--������Ϣ��ʾ�����Ӧ
function CChatWnd:OnCtrlmsg(Child, uMsgID, uParam1, uParam2 )
	if( Child == self.m_CBTnClose and uMsgID == BUTTON_LCLICK) then
		self:ShowWnd(false)
		local rt	= CFRect:new()
		self.m_CBTnClose:GetWndRect( rt )
		g_GameMain.m_ChatWndShow:SetWndRect( rt )
		g_GameMain.m_ChatWndShow:ShowWnd(true)
	end
	
	if( Child == self.m_CBTnLug and uMsgID == BUTTON_DRAG ) then

		local CurPointX	= int16( LOWORD( uParam2 ) ) -- rt.right
		local CurPointY	= int16( HIWORD( uParam2 ) ) -- rt.top
		
		local HeldPointX = int16( LOWORD( uParam1 ) ) 
		local HeldPointY = int16( HIWORD( uParam1 ) ) 
		
		local zoomsize = self:GetRootZoomSize()
		local xDel = (CurPointX - HeldPointX)/zoomsize
		local yDel = (CurPointY - HeldPointY)/zoomsize
		
		local OldRt	= CFRect:new() 
		self.m_ChatWndArea:GetLogicRect( OldRt )
		local NewRt = CFRect:new() 
		NewRt.left = OldRt.left 
		NewRt.bottom = OldRt.bottom
		NewRt.top = OldRt.top + yDel 
		NewRt.right = OldRt.right + xDel
		self.m_ChatWndArea:SetLogicRect( NewRt )
		
		local OrgWidth = self.m_ChatWndArea:GetWndOrgWidth()
		local OrgHeight = self.m_ChatWndArea:GetWndOrgHeight()	
		
		if 	not(OrgWidth > 200 and  OrgWidth < 800) and not(OrgHeight > 90 and OrgHeight < 450) then
			self.m_ChatWndArea:SetLogicRect( OldRt )
			return
		elseif not(OrgWidth > 200 and  OrgWidth < 800) and (OrgHeight > 90 and OrgHeight < 450) then  
			NewRt.right = OldRt.right
			xDel = 0
			self.m_ChatWndArea:SetLogicRect(NewRt)
		elseif (OrgWidth > 200 and  OrgWidth < 800) and not(OrgHeight > 90 and OrgHeight < 450) then	
			NewRt.top = OldRt.top
			yDel = 0
			self.m_ChatWndArea:SetLogicRect(NewRt)
		end
				
		local rt	= CFRect:new()
		self.m_CBTnLug:GetLogicRect( rt )
		rt.left		= rt.left   + xDel
		rt.top		= rt.top    + yDel
		rt.right	= rt.right  + xDel
		rt.bottom	= rt.bottom + yDel								
		self.m_CBTnLug:SetLogicRect( rt )
		
--		g_GameMain.m_CreateChatWnd.m_CChatWnd:GetLogicRect( rt )
--		rt.top		= rt.top   + yDel
--		rt.right	= rt.right + xDel
--		g_GameMain.m_CreateChatWnd.m_CChatWnd:SetLogicRect( rt )
	end
	
	local y = 0
	if( uMsgID == BUTTON_LCLICK ) then
		
		if( Child == self.m_ChatFilterCBTn ) then
			if nil ~= self.m_Menu then
				self.m_Menu:Destroy()
				self.m_Menu = nil
			end
			local Menu = CreateRMenu()
			local Rect = CFRect:new()
			self.m_ChatFilterCBTn:GetLogicRect(Rect)
			Menu:SetPos(Rect.left, Rect.top)
			self.m_Menu = Menu 
		elseif (Child == self.m_ChatSociality) then
			OpenAssociationWnd()--��Ⱥ
		else
			for i = 1,#(self.CBtnTbl) do
				if (Child == self.CBtnTbl[i]) then
					self.CBtnTbl[i]:SetCheck(true)
					g_WndCBTnSelectID = i
					if i == 3 then
						CFightInfoWnd.GetWnd():OnFightInfoShow(true)
					else
						CFightInfoWnd.GetWnd():OnFightInfoShow(false)
					end
				end
			end
		end
		g_GameMain.m_CreateChatWnd.m_CChatWnd:ChatInfoShow()
	end
	if (uMsgID  == RICH_CLICK and Child == self.m_ChatWndArea) then
		AttoLinkFun(self.m_ChatWndArea)
	elseif(uMsgID == RICH_RCLICK and Child == self.m_ChatWndArea) then
		AddMenFun(self.m_ChatWndArea,uParam1,uParam2)
	elseif(uMsgID == RICHWND_LCLICKUP and Child == self.m_ChatWndArea) then
		g_GameMain:OnLButtonUp( uMsgID, uParam1, uParam2 )
	elseif(uMsgID == RICHWND_LCLICKDOWN and Child == self.m_ChatWndArea) then
		g_GameMain:OnLButtonDown( uMsgID, uParam1, uParam2 )
	elseif(uMsgID == RICHWND_RCLICKUP and Child == self.m_ChatWndArea) then
		g_GameMain:OnRButtonClick( uMsgID, uParam1, uParam2 )
	elseif(uMsgID == RICHWND_RCLICKDOWN and Child == self.m_ChatWndArea) then
		g_GameMain:OnRButtonDown( uMsgID, uParam1, uParam2 )
	end
	
	if( uMsgID == BUTTON_RIGHTCLICKDOWN ) then
		if nil ~= self.m_Menu then
			self.m_Menu:Destroy()
			self.m_Menu = nil
		end
		local tbl = {unpack(self.CBtnTbl)}
		for i = 1, #tbl do
			if(Child == tbl[i]) then
				g_WndCBTnSelectID = i
				local Menu = CreateRMenu()
				local Rect = CFRect:new()
				tbl[i]:GetLogicRect(Rect)
				Menu:SetPos(Rect.left, Rect.top-y)
				self.m_Menu = Menu
			end
		end
	end
end

--�����ʾ����
function CChatWnd:BCBTnShowCount( BCBTnname, PanelShow, PanelPosition )
	local panelshow = false
	if( PanelShow == 1 ) then
		panelshow = true
	elseif( PanelShow == 0 ) then 
		panelshow = false
	end
	self.CBtnTbl[PanelPosition]:ShowWnd(panelshow)
	self.CBtnTbl[PanelPosition]:SetWndText(BCBTnname)
	if panelshow then
		g_WndCBTnAmount = math.max(g_WndCBTnAmount,PanelPosition)
	end
end

--���Ƶ����Ϣ����
function CChatWnd:CheckBCBTnChannelSet(ChannelID, IsSelect, PanelPosition)
	for i = 1,5 do
		if PanelPosition == i then
			self.CBTnArray[i][ChannelID].IsSubscribe = IsSelect
		end
	end
end

--�����ʾ����������
function CChatWnd:CheckBCBTnShowCount()
	for i = 1,#(self.CBtnTbl) do
		if self.CBtnTbl[i]:IsShow() then
			g_WndCBTnAmount  = i
		end
	end
end

--��ȡĬ��������� 
function CChatWnd:ReadDefaultSet()
	g_WndCBTnAmount = 3
	for i = 1,3 do
		self.CBtnTbl[i]:ShowWnd(true)
		self.CBtnTbl[i]:SetWndText(Lan_ChannelTable_Client(i,"Name"))
	end
	for i = 4,5 do
		self.CBtnTbl[i]:ShowWnd(false)
	end
	
	self.CBTnArray = {}
	for i = 1 ,5 do
		self.CBTnArray[i] = {}
	end
	for i = 1 ,5 do 
		self.CBTnArray[i][1] = {IsSubscribe = ChannelTable_Client(i,"GM")}
		self.CBTnArray[i][2] = {IsSubscribe = ChannelTable_Client(i,"World")}
		self.CBTnArray[i][3] = {IsSubscribe = ChannelTable_Client(i,"Camp")}	
		self.CBTnArray[i][4] = {IsSubscribe = ChannelTable_Client(i,"Map")}
		self.CBTnArray[i][5] = {IsSubscribe = ChannelTable_Client(i,"Region")}
		self.CBTnArray[i][6] = {IsSubscribe = ChannelTable_Client(i,"Team")}
		self.CBTnArray[i][7] = {IsSubscribe = ChannelTable_Client(i,"Party")}
		self.CBTnArray[i][8] = {IsSubscribe = ChannelTable_Client(i,"Troop")}
		self.CBTnArray[i][9] = {IsSubscribe = ChannelTable_Client(i,"NPC")}
	end
end

function CChatWnd:ReadFontSet()
	local strFileName = g_RootPath .. "var/gac/ChatSetting.txt"
	local f = CLuaIO_Open(strFileName, "r")
	local text = ""
	if(f ~= nil) then
		text = f:ReadAll()
		f:Close()
	end
	if(text ~= "" and tonumber(text)) then
		self.m_ChatWndArea:SetFontSize(text)
	else
		self.m_ChatWndArea:SetFontSize(FontSize)
	end
end
--������Ϣ���ú���
function CChatWnd:Ctor()
	self.ChatInfoTbl = {{},{},{},{},{}}
end

--�����������ص����ֽ���ת��
function ModeConversion(Msg,ChannelColor)
	--�滻��Ʒ����
	ChannelColor = ChannelColor and ChannelColor or "#W"
	local Flag = true
	local StartId = 1
	while Flag do
		--print(select(6, string.find(Msg,"((%x%x%x%x%x%x%x)%[%((.-)%)(%w+)%])",StartId)))
		local ID = 	select(6, string.find(Msg,"((%x%x%x%x%x%x%x)%[%((.-)%)(%w+)%])",StartId))	
		StartId = select(2, string.find(Msg,"((%x%x%x%x%x%x%x)%[%((.-)%)(%w+)%])",StartId))
		if ID then
			ID = MemH64(ID)			
			Msg = string.gsub(Msg,"((%x%x%x%x%x%x%x)%[%((.-)%)(%w+)%])","#%2[#u#l%3#i%[" .. ID.. "]#l#u]" .. ChannelColor,1)
		else
			Flag = false
			break
		end
	end
	
	--�滻�ص�����
	Flag = true
	StartId = 1	
	while Flag do
		--print(string.find(Msg,"((%[%P%S[^%[]-%(%d+,?%d+%)%])%[(%S-%(%d+,?%d+%))%])",StartId))
		local pos = select(5, string.find(Msg,"((%[%P%S[^%[]-%(%d+,?%d+%)%])%[(%S-%(%d+,?%d+%))%])",StartId))	
		StartId = select(2, string.find(Msg,"((%[%P%S[^%[]-%(%d+,?%d+%)%])%[(%S-%(%d+,?%d+%))%])",StartId))
		if pos then
			pos = MemH64(pos)	
			Msg = string.gsub(Msg,"((%[%P%S[^%[]-%(%d+,?%d+%)%])%[(%S-%(%d+,?%d+%))%])","#cffff33#l%2#i%[" .. pos .. "%]#l" .. ChannelColor,1)
		else
			Flag = false
			break
		end
	end
	return Msg
end

--������Ϣ���κ���
local function ModifyMsg( Id, CharName,uCamp ) 
	--CharName = ChannelColorTbl[Id] .. "(" .. os.date("%H") .. ":" .. os.date("%M") .. ":" .. os.date("%S") .. ")" .. "[#l" .. ChannelNameTbl[Id] .. "#i[&]#l]" .. "[#l" .. CharName .. "#l]" 
	if Id == ChannelIdTbl["ϵͳ"] then --ϵͳƵ��
		CharName = ChannelColorTbl[Id] .. "[" .. ChannelNameTbl[Id] .. "]"
	elseif Id == ChannelIdTbl["����"] then --����Ƶ��
		CharName = ChannelColorTbl[Id] .. "[#l" .. ChannelNameTbl[Id] .. "#i[" .. MemH64("&") .. "]#l]" .. "[" .. CampNameTbl[uCamp] .. "]".. "[#l" .. CharName .. "#l]" 
	elseif Id == ChannelIdTbl["����"] then --����Ƶ��
		CharName = "[" .. CampNameTbl[uCamp] .. "]".. "[#l" .. CharName .. "#l]" 
	else
		CharName = ChannelColorTbl[Id] .. "[#l" .. ChannelNameTbl[Id] .. "#i[" .. MemH64("&") .. "]#l]" .. "[#l" .. CharName .. "#l]" 
	end
	return CharName
end

local function ModifyNpcMsg(Id,CharName)
	CharName = ChannelColorTbl[Id] .. "[#l" .. ChannelNameTbl[Id] .. "#i[" .. MemH64("&") .. "]#l]" .. "[" .. CharName .. "]" 
	return CharName	
end

local function InsertMsgToTbl(Tbl,Name,Msg)
	table.insert(Tbl,Name)
	table.insert(Tbl,":")
	table.insert(Tbl,Msg)
	table.insert(Tbl,"#r")
end

local function CheckHaveMsgTickFun()
	local wnd = g_GameMain.m_CreateChatWnd.m_CCHMsgWnd
	if wnd.m_CheckHaveMsgTick then
		UnRegisterTick(wnd.m_CheckHaveMsgTick)
		wnd.m_CheckHaveMsgTick = nil
	end
	wnd:ShowWnd(false)
end

--���շ�ϵͳ��Ϣ
function CChatWnd:ChatInfoSet(Character_Id, playerCharName, uChannel_Id, sMsg,uCamp)
	--�������Ϣ������ں�������,����ʾ�κ���Ϣ
	if g_GameMain.m_AssociationBase:IsInBlackList(Character_Id) then
		return
	end
	sMsg = ModeConversion(sMsg,ChannelColorTbl[uChannel_Id])	
	playerCharName = ModifyMsg( uChannel_Id, playerCharName,uCamp)
	if uChannel_Id == 10 then
		local wnd = g_GameMain.m_CreateChatWnd.m_CCHMsgWnd
		if wnd.m_CheckHaveMsgTick then
			UnRegisterTick(wnd.m_CheckHaveMsgTick)
			wnd.m_CheckHaveMsgTick = nil
		end
		local Msg = playerCharName .. ":" .. sMsg .. "#r"
		wnd.m_TextWnd:SetWndText("#b005#9e3f15#2000" .. Msg .. "#b" )
		wnd:ShowWnd(true)
		wnd.m_CheckHaveMsgTick = RegisterTick("CheckHaveMsgTickFuc", CheckHaveMsgTickFun, 90*1000)
		return 
	end
	if(self.CBTnArray[1][uChannel_Id].IsSubscribe == 1)then
		InsertMsgToTbl(self.ChatInfoTbl[1],playerCharName,sMsg)
	end  	
	if(self.CBTnArray[2][uChannel_Id].IsSubscribe == 1 and self.CBtnTbl[2]:IsShow()) then 
		InsertMsgToTbl(self.ChatInfoTbl[2],playerCharName,sMsg)
	end
	
	if(self.CBTnArray[4][uChannel_Id].IsSubscribe == 1 and self.CBtnTbl[4]:IsShow() ) then 
		InsertMsgToTbl(self.ChatInfoTbl[4],playerCharName,sMsg)
	end
	if(self.CBTnArray[5][uChannel_Id].IsSubscribe == 1 and self.CBtnTbl[5]:IsShow()) then 
		InsertMsgToTbl(self.ChatInfoTbl[5],playerCharName,sMsg)
	end

	if( uChannel_Id == ChannelIdTbl["����"] )then
		local player = g_GetPlayerInfo(Character_Id)
		if player == nil then
			return
		end
		if player.m_NpcHeadUpDialog == nil then
			local bIsCreate = NpcHeadUpDialog(player)
			if not bIsCreate then
				return
			end			
		end
		local Wnd = player.m_NpcHeadUpDialog
		Wnd.m_NpcHeadUpDialogWnd:SetAutoWidth(90, 120)
		Wnd.m_NpcHeadUpDialogWnd:SetMinHeight(35)
		NpcHeadUpDialogShow(Wnd,sMsg)
	end
	g_GameMain.m_CreateChatWnd.m_CChatWnd:ChatInfoShow()
	
end

--����ϵͳ��Ϣ
function CChatWnd:SystemInfoSet(uChannel_Id,sMsg,playerCharName)
	--local SysContent = ChannelColorTbl[uChannel_Id] .. "(" .. os.date("%H") .. ":" .. os.date("%M") .. ":" .. os.date("%S") .. ")" .. "[" .. ChannelNameTbl[uChannel_Id]  .. "]" 
	local SysContent = ChannelColorTbl[uChannel_Id] .. "[" .. ChannelNameTbl[uChannel_Id]  .. "]" 
	
	if(self.CBTnArray[1][uChannel_Id].IsSubscribe == 1)then
		InsertMsgToTbl(self.ChatInfoTbl[1],SysContent,sMsg)
	end  	
	if(self.CBTnArray[2][uChannel_Id].IsSubscribe == 1 and self.CBtnTbl[2]:IsShow()) then 
		InsertMsgToTbl(self.ChatInfoTbl[2],SysContent,sMsg)
	end
	if(self.CBTnArray[4][uChannel_Id].IsSubscribe == 1 and self.CBtnTbl[4]:IsShow() ) then 
		InsertMsgToTbl(self.ChatInfoTbl[4],SysContent,sMsg)
	end
	if(self.CBTnArray[5][uChannel_Id].IsSubscribe == 1 and self.CBtnTbl[5]:IsShow()) then 
		InsertMsgToTbl(self.ChatInfoTbl[5],SysContent,sMsg)
	end
	g_GameMain.m_CreateChatWnd.m_CChatWnd:ChatInfoShow()
end


--�ж��Ƿ���Ը���Ƶ��������Ϣ
function ChannelSentCheck()
	if not g_MainPlayer then
		local nLoading = g_App.m_Loading:IsShow() and 1 or 0
		local str = string.format("�Ƿ�Loading:%d,��Ϸ״̬:%d", nLoading, g_App.m_re)
		LogErr("�߼���:g_MainPlay������(����ϵͳ)", str)
		return
	end
	
	local time = GetProcessTime()/1000
	if( g_ChannelId == ChannelIdTbl["����"]) then --����
		if (g_MainPlayer:CppGetLevel() >= 10 ) then 
			return true
		else
			MsgClient(204)
		end
	elseif( g_ChannelId == ChannelIdTbl["����"]) then --����
		if(g_MainPlayer:CppGetLevel() >= 10 ) then
			if (time - lasttime[g_ChannelId]) >= ChannelTimeLimitTbl[g_ChannelId] then
				lasttime[g_ChannelId] = time 
				return true
			else
				MsgClient(203)
			end
		else
			MsgClient(204)
		end
	elseif( g_ChannelId == ChannelIdTbl["����"]) then --����
		if (time - lasttime[g_ChannelId]) >= ChannelTimeLimitTbl[g_ChannelId] then
			lasttime[g_ChannelId] = time 
			return true
		else
			MsgClient(203)
		end
	elseif( g_ChannelId == ChannelIdTbl["����"]) then --����
		if( g_MainPlayer.m_Properties:GetTeamID() ~= 0  ) then
--			if (time - lasttime[g_ChannelId]) >= 1 then
--				lasttime[g_ChannelId] = time 
--				return true
--			else
--				MsgClient(203)
--			end
			return true
		end
	elseif( g_ChannelId == ChannelIdTbl["Ӷ��С��"]) then  
		if g_MainPlayer.m_Properties:GetTongID() ~= 0 then 
			return true
		end
	elseif( g_ChannelId == ChannelIdTbl["Ӷ����"]) then 
		if g_MainPlayer.m_Properties:GetArmyCorpsName() ~= "" then 
			return true
		end				
	elseif( g_ChannelId == ChannelIdTbl["��Ӫ"]) then --��Ӫ
		if(g_MainPlayer:CppGetLevel() >= 10 ) then
			if (time - lasttime[g_ChannelId]) >= ChannelTimeLimitTbl[g_ChannelId] then
				lasttime[g_ChannelId] = time 
				return true
			else
				MsgClient(203)
			end
		else
			MsgClient(204)
		end	
	elseif(g_ChannelId == ChannelIdTbl["��ͼ"]) then --��ͼ
		if(g_MainPlayer:CppGetLevel() >= 10 ) then
			if (time - lasttime[g_ChannelId]) >= ChannelTimeLimitTbl[g_ChannelId] then
				lasttime[g_ChannelId] = time 
				return true
			else
				MsgClient(203)
			end
		else
			MsgClient(204)
		end	
	end
end

local function GetTableString(Tbl)
	local tblString = table.concat(Tbl,"")
	return tblString
end

local function RemoveTableString(Tbl)
	if #(Tbl) >= g_MessageNumber then
--		local strFileName = g_RootPath .. "var/gac/" .. os.date("%Y") .. os.date("%m") .. os.date("%d") .. ".txt"
--		local f = CLuaIO_Open(strFileName, "a")
--		if f ~= nil then
--			local chatString =  Tbl[1]
--			f:WriteString(chatString)
--			f:Close()
--		end
		local ReMoveNumber = 50 * 4
		for j = 1, ReMoveNumber do		
			table.remove(Tbl,1)
		end
	end
end

--������Ϣ��ʾ����
function CChatWnd:ChatInfoShow()
	if g_WndCBTnSelectID >= 1 and g_WndCBTnSelectID <= 5 then
		g_GameMain.m_CreateChatWnd.m_CChatWnd.m_ChatWndArea:SetWndText(GetTableString(self.ChatInfoTbl[g_WndCBTnSelectID]))
	end
	for i = 1,5 do
		RemoveTableString(self.ChatInfoTbl[i])
	end
end

--������������
function CreateChatCBTnFace()
	local Wnd = CChatCBTnFace:new()
	Wnd:CreateFromRes("ChatCBTnFace",g_GameMain	)
	Wnd:ShowWnd( true )
	Wnd.m_FaceBTn1 = Wnd:GetDlgChild("FaceBTn1")
	local Rect = CFRect:new() 
	g_GameMain.m_CreateChatWnd.m_ChatSendArea:GetWndRect(Rect)
	Rect.left = Rect.left + 600
	Rect.top  = Rect.top - 100
	Wnd:SetWndRect(Rect)
	g_GameMain.m_ChatCBTnFace = Wnd
end

function CChatCBTnFace:OnCtrlmsg(Child, uMsgID, uParam1, uParam2 )
	local Wnd = g_GameMain.m_CreateChatWnd.m_ChatSendArea.m_CEditMessage
	local temp = Wnd:GetWndText()
	if( Child  == self.m_FaceBTn1 and uMsgID == BUTTON_LCLICK ) then
		temp = temp .. "#1"
		self:ShowWnd(false)
	end
	Wnd:SetWndText( temp )
	Wnd:SetFocus()
end

--ɾ��������Ϣ��Ӧ
function CDeleteWnd:OnCtrlmsg(Child, uMsgID, uParam1, uParam2 )
	if( uMsgID == BUTTON_LCLICK and Child == self.m_DeleteCBTnNo ) then 
		self:ShowWnd(false)
	end  
	if( uMsgID == BUTTON_LCLICK and Child == self.m_DeleteCBTnYes ) then
		g_GameMain.m_CreateChatWnd.m_CChatWnd:CheckBCBTnShowCount()
		if(g_WndCBTnAmount == 1 ) then
			CreateDeleteCueWnd()
		else
			local CBTnTable = g_GameMain.m_CreateChatWnd.m_CChatWnd.CBtnTbl
			Gac2Gas:DeletePanel(g_Conn, CBTnTable[g_WndCBTnAmount]:GetWndText(), g_WndCBTnAmount)
		end
		self:ShowWnd(false)	
	end
end

local function ChannelSelect(index)
	local CBTnChannelChose = g_GameMain.m_CreateChatWnd.m_ChatSendArea.m_CBTnChannelChose
	
	for i = 1, #(ChannelNameTbl) do 
		if( index == ChannelNameTbl[i]) then
			g_ChannelId = i
			CBTnChannelChose:SetWndText(ChannelNameTbl[i])
		end
	end		
	if g_ChannelId ~= 2 and g_GameMain.m_CreateChatWnd.m_MsgShowWnd:IsShow() then
		g_GameMain.m_CreateChatWnd.m_MsgShowWnd:ShowWnd(false)
	end
	g_GameMain.m_CreateChatWnd.m_ChatSendArea.m_CEditMessage:SetFocus()
end

--���� ->1||���� ->2||���� ->3||���� ��>4||���� ��>5||ͬ�� ��>6
--���� ��>7||���� ��>8||ϵͳ ��>9||Ͷ�� ��> 10||ͬ�� ��>11||�Ŷ� ��>12
--��Ӫ ->13
--����Ƶ���˵�
function CreateChannel()
	local Menu = CMenu:new("TargetMenu",g_GameMain.m_CreateChatWnd.m_ChatSendArea,30) 
	if(g_MainPlayer:CppGetLevel() >= 10 ) then
		Menu:InsertItem(GacMenuText(1113),ChannelSelect,nil,false,false,nil,GacMenuText(1111))	--����
		Menu:InsertItem(GacMenuText(1112),ChannelSelect,nil,false,false,nil,GacMenuText(1101))	--����
		Menu:InsertItem(GacMenuText(1104),ChannelSelect,nil,false,false,nil,GacMenuText(1104))	--��Ӫ
		Menu:InsertItem(GacMenuText(1102),ChannelSelect,nil,false,false,nil,GacMenuText(1102))	--��ͼ
	end
	Menu:InsertItem(GacMenuText(1103),ChannelSelect,nil,false,false,nil,GacMenuText(1103))		--����

	if g_MainPlayer.m_Properties:GetArmyCorpsName() ~= "" then
		Menu:InsertItem(GacMenuText(1108),ChannelSelect,nil,false,false,nil,GacMenuText(1108))	--Ӷ����
	end 
	if g_MainPlayer.m_Properties:GetTongID() ~= 0 then 
		Menu:InsertItem(GacMenuText(1105),ChannelSelect,nil,false,false,nil,GacMenuText(1105))	--Ӷ��С��
	end
	if g_MainPlayer.m_Properties:GetTeamID() ~= 0 then
		Menu:InsertItem(GacMenuText(1107),ChannelSelect,nil,false,false,nil,GacMenuText(1107))	--����
	end 
	Menu:SetUpwards(true)
	return Menu
end

--��Ӻ���
local function OnAddFriend()
	local tblInfo	= {}
	tblInfo.name	= g_GameMain.m_CreateChatWnd.m_CChatWnd.SelectValue
	g_GameMain.m_AssociationWnd:CreateAddToClassWnd(tblInfo, false)
end


local function OnTongInvite()
	local name = g_GameMain.m_CreateChatWnd.m_CChatWnd.SelectValue
	Gac2Gas:InviteJoinTongByName(g_Conn, name)
end

local function OnTongApp()
	local name = g_GameMain.m_CreateChatWnd.m_CChatWnd.SelectValue
	Gac2Gas:RequestJoinTongByName(g_Conn, name)
end

--��Ϊ˽��
local function OnWhisper()
	local name = g_GameMain.m_CreateChatWnd.m_CChatWnd.SelectValue
	g_GameMain.m_AssociationWnd:StartChatByName(name, "") --˽��
end

--��ֵ����
local function OnCopyName()
--����Ŀ�������
	local Target = g_GameMain.m_CreateChatWnd.m_CChatWnd.SelectValue
end

--�������
local function OnInviteTeam()
	local Name = g_GameMain.m_CreateChatWnd.m_CChatWnd.SelectValue
	Gac2Gas:InviteMakeTeamByName(g_Conn, Name)
end

--�������Ӷ����
local function OnInviteArmyCorps()
	local Name = g_GameMain.m_CreateChatWnd.m_CChatWnd.SelectValue
	Gac2Gas:InviteJoinArmyCorpsByName(g_Conn, Name)
end

--��������
local function OnInviteTrade()
	if g_MainPlayer.m_ItemBagLock then
		MsgClient(160015)
		return
	end
	local Value = g_GameMain.m_CreateChatWnd.m_CChatWnd.SelectValue
	if Value == g_MainPlayer.m_Properties:GetCharName() then
		MsgClient(6012)
		return
	end
	Gac2Gas:SenTradeInvitationByPlayerName(g_Conn, Value)
end

--����
local function OnShield()
	local Value = g_GameMain.m_CreateChatWnd.m_CChatWnd.SelectValue
	if Value == g_MainPlayer.m_Properties:GetCharName() then
		return
	end
	g_GameMain.m_AssociationBase:AddBlackListByName(Value)
end

--����RichWnd�˵�
function CreateChatMenu()
	local TeamID		= g_MainPlayer.m_Properties:GetTeamID()
	local bCaptain		= g_GameMain.m_TeamBase.m_bCaptain
	local tongID		= g_MainPlayer.m_Properties:GetTongID()
	local canInviteTeam	= (0 == TeamID) or (bCaptain and g_GameMain.m_TeamBase.m_TeamSize < 5)
	
	local Menu = CMenu:new("TargetMenu",g_GameMain)
	Menu:InsertItem(GacMenuText(103),OnAddFriend,nil,false,false,nil)			--��Ϊ����
	Menu:InsertItem(GacMenuText(105),OnWhisper,nil,false,false,nil) 			--˽��
	Menu:InsertItem(GacMenuText(104),OnInviteTrade,nil,false,false,nil)			--����
	if( canInviteTeam ) then
		Menu:InsertItem(GacMenuText(1204),OnInviteTeam,nil,false,false,nil)		--�������
	end
	
	--Menu:InsertItem(GacMenuText(1202),nil,nil,false,false,nil)				--�鿴���� --Todo
	--Menu:InsertItem(GacMenuText(1205),OnCopyName,nil,false,false,nil)			--�������� --Todo
	Menu:InsertItem(GacMenuText(1206),OnShield,nil,false,false,nil)				--���������
	if CArmyCorpsPanel.GetWnd():CanInviteArmyCorps() then
		Menu:InsertItem(GacMenuText(108),OnInviteArmyCorps,nil,false,false,nil)				--���������
	end
	
	--�������Ӷ����/�������Ӷ����
	if( 0 ~= g_MainPlayer.m_Properties:GetTongID() and
		0 ~= g_TongPurviewMgr:GetInviteMemberValue(g_GameMain.m_TongBase.m_TongPos) ) then
		Menu:InsertItem(GacMenuText(612), OnTongInvite, nil, false, false, nil)
	end
	if( 0 == g_MainPlayer.m_Properties:GetTongID()) then
		Menu:InsertItem(GacMenuText(613), OnTongApp, nil, false, false, nil)
	end
		
	Menu.upwards = true
	return Menu
end

--������˽������
function CChatSendArea:CreateAddChatMnueArray(name)
	function selectname()
		local ArrayCount = self.ArrayCount-1
		for i = 1, ArrayCount do
			if (self.ChatMnueArray[i] == name) then
				return false
			end
		end
		return true
	end
	if(selectname() ) then
		if( self.ArrayCount < 6 ) then
			self.ChatMnueArray[self.ArrayCount] = name
			self.ArrayCount = self.ArrayCount + 1
		else
			if(selectname())then
				for i = 1, 4 do 
					self.ChatMnueArray[i] = self.ChatMnueArray[i+1]
				end 
				self.ChatMnueArray[5] = name
			end
		end
	end
	
end

--��¼��������¼
function CChatSendArea:CreateAllChatContent(Content)
	local Cout = #(self.m_AllChatContentArray)
	function selectContent() --�жϷ��͵������Ƿ��¼���һ���������
		if Cout > 0 then
			if self.m_AllChatContentArray[Cout] == Content then
				return false
			end
		end
		return true
	end

	if(selectContent()) then --��������¼
		if( Cout < chatRecordNumber ) then
			self.m_AllChatContentArray[Cout + 1] = Content 
			if self.m_CurrentSelectID and self.m_AllChatContentArray[self.m_CurrentSelectID] == Content then
				self.m_CurrentSelectID = self.m_CurrentSelectID
			else
				self.m_CurrentSelectID = Cout + 1	
			end			
		else
			table.remove(self.m_AllChatContentArray,1)
			self.m_AllChatContentArray[chatRecordNumber] = Content
			if self.m_CurrentSelectID and self.m_AllChatContentArray[self.m_CurrentSelectID - 1] == Content then
				if self.m_CurrentSelectID < chatRecordNumber then --���������IDΪ10����ѡ��ID����
					self.m_CurrentSelectID = self.m_CurrentSelectID - 1
				end
					
				if self.m_CurrentSelectID <= 0 then -- �������ʱIDΪ1,��ѡ��ID��Ϊ10
					self.m_CurrentSelectID = chatRecordNumber
				end	
			else
				self.m_CurrentSelectID = chatRecordNumber	
			end	
		end
	end
end

--�������������ʾ�˵�
function CChatSendArea:CreateAddChatMnue()
		local Menu = CMenu:new("TargetMenu",g_GameMain)
		local ArrayCount = self.ArrayCount - 1
		for i = 1, ArrayCount do 	
			function SetSentAreaText()
				local name = "/" .. self.ChatMnueArray[i] .. " "
				self.m_CEditMessage:SetWndText(name)
				self.m_CEditMessage:SetFocus()
				Menu:ShowWnd(true)		
			end
			Menu:InsertItem(self.ChatMnueArray[i],SetSentAreaText,SetSentAreaText,false,false,nil)
		end
		return Menu
end

--����Ĭ������Ƶ��
function CChatSendArea:SetDefaultChannel(ChannelName)
	if self.m_CBTnChannelChose:GetWndText() == ChannelName then
		self.m_CBTnChannelChose:SetWndText(ChannelNameTbl[5])
		g_ChannelId =  ChannelIdTbl["����"]
	end
end

--����Ƶ��������Ϣ
function CChatFilter:OnCtrlmsg(Child, uMsgID, uParam1, uParam2 )
	if uMsgID== BUTTON_LCLICK then
		for i = 1,#(ChannelNameTbl) do 
			if self.CheckArray[i] == Child then 
				self.CheckArray[i]:SetCheck( not self.CheckArray[i]:GetCheck())
			end
		end 		
	end
	if( uMsgID == BUTTON_LCLICK and Child == self.m_ChatFilterCBTnYes) then 
		self.CBTnTable = {}
		for i = 1,5 do
			self.CBTnTable[i] = g_GameMain.m_CreateChatWnd.m_CChatWnd.CBtnTbl[i]
		end
		if ( IsAddNewWnd ) then
			g_GameMain.m_CreateChatWnd.m_CChatWnd:CheckBCBTnShowCount()
			g_WndCBTnAmount = g_WndCBTnAmount + 1
			local Wnd_text = g_GameMain.m_AddNewWnd.m_AddNewWndEdit:GetWndText()
			
			Gac2Gas:AddPanel(g_Conn, Wnd_text, g_WndCBTnAmount)
			IsAddNewWnd = false
			for i = 1 ,#(ChannelNameTbl) - 1 do 	
				local uFlag = 0
				if self.CheckArray[i]:GetCheck() then
					uFlag = 1
				end
				if(uFlag ~= g_GameMain.m_CreateChatWnd.m_CChatWnd.CBTnArray[g_WndCBTnAmount][i].IsSubscribe ) then  
					Gac2Gas:SetChannelPanel(g_Conn, i, uFlag, g_WndCBTnAmount)
					g_GameMain.m_CreateChatWnd.m_CChatWnd.CBTnArray[g_WndCBTnAmount][i].IsSubscribe = uFlag
				end
			end
		else --�������Ϣд����������
			Gac2Gas:SetPanel(g_Conn, self.CBTnTable[self.m_WndCBTnSelectID]:GetWndText() , self.m_WndCBTnSelectID)
			for i = 1 ,#(ChannelNameTbl) -1 do 
				local uFlag = 0
				if self.CheckArray[i]:GetCheck() then
					uFlag = 1
				end
				if(	uFlag ~= g_GameMain.m_CreateChatWnd.m_CChatWnd.CBTnArray[g_WndCBTnSelectID][i].IsSubscribe) then 
					Gac2Gas:SetChannelPanel(g_Conn, i, uFlag, self.m_WndCBTnSelectID)
					g_GameMain.m_CreateChatWnd.m_CChatWnd.CBTnArray[self.m_WndCBTnSelectID][i].IsSubscribe = uFlag
				end
			end
		end
		Gac2Gas:SetChannelPanelEnd(g_Conn)
		self:ShowWnd(false)
	end
	if(uMsgID == BUTTON_LCLICK and Child == self.m_ChatFilterCBTnNo) then 
		self:ShowWnd(false)
	end
end

--����´�����Ϣ��Ӧ
function CAddNewWnd:OnCtrlmsg(Child, uMsgID, uParam1, uParam2 )
	if(uMsgID == BUTTON_LCLICK and Child == self.m_AddCBTnNo) then
		self:ShowWnd(false)
	end
	if(uMsgID == BUTTON_LCLICK and Child == self.m_AddCBTnYes) then
		if(self.m_AddNewWndEdit:GetWndText() ~="") then
			if(  g_WndCBTnAmount < 5) then 
				local textFilter = CTextFilterMgr:new()
				local name = self.m_AddNewWndEdit:GetWndText()
				if (string.len(name) > 12) then
					MsgClient(206)
				elseif( not textFilter:IsValidName(name) ) then
					MsgClient(207)
				else
					IsAddNewWnd = true
					ShowChatFilter(true)
				end
			else
				g_WndCBTnAmount = 5
				CreateAddCueWnd()
			end
		else
			CreateAddEmptyCueWnd()
		end
		self:ShowWnd(false) 
	end
end

--������
function CRenameWnd:OnCtrlmsg(Child, uMsgID, uParam1, uParam2 )
	if (uMsgID == BUTTON_LCLICK and Child == self.m_RenameCBTnYes ) then
		local Wnd_text = g_GameMain.m_RenameWnd.m_RenameWndEdit:GetWndText()
		local textFilter = CTextFilterMgr:new()
		if (string.len (Wnd_text) > 12) then
			MsgClient(206)
		elseif (not textFilter:IsValidName(Wnd_text)) then
			MsgClient(207)
		else
			Gac2Gas:RenamePanel(g_Conn, Wnd_text,self.m_WndCBTnSelectID)
		end
		self:ShowWnd(false)
	end
	
	if (uMsgID == BUTTON_LCLICK and Child == self.m_RenameCBTnNo) then
		self:ShowWnd(false)
	end
end

--�������
function CChatWndAfreshSet:OnCtrlmsg(Child, uMsgID, uParam1, uParam2 )
	if(uMsgID == BUTTON_LCLICK and Child == self.m_AfreshSetYes ) then
		Gac2Gas:SetDefaultChannelPanel(g_Conn)
		self:ShowWnd(false)
	elseif(uMsgID == BUTTON_LCLICK and Child == self.m_AfreshSetNo ) then
		self:ShowWnd(false)
	end
end

--��������ʾ����
function CreateAddCueWnd()
	local Wnd = CAddCueWnd:new()
	Wnd:CreateFromRes("AddCueWnd", g_GameMain)
	Wnd:ShowWnd( true )
	Wnd.m_AddCueWndYes = Wnd:GetDlgChild("AddCueWndYes")
end

function CAddCueWnd:OnCtrlmsg(Child, uMsgID, uParam1, uParam2 )
	if(Child == self.m_AddCueWndYes and uMsgID == BUTTON_LCLICK ) then
		self:ShowWnd(false)
	end
end

--���ɾ����ʾ����
function CreateDeleteCueWnd()
	local Wnd = CDeleteCueWnd:new()
	Wnd:CreateFromRes("DeleteCueWnd",g_GameMain)
	Wnd:ShowWnd( true )
	Wnd.m_DeleteCueWndYes = Wnd:GetDlgChild("DeleteCueWndYes")
end

function CDeleteCueWnd:OnCtrlmsg(Child, uMsgID, uParam1, uParam2 )
	if(Child == self.m_DeleteCueWndYes and uMsgID == BUTTON_LCLICK ) then
		self:ShowWnd(false)
	end
end

--�����ӱ������ʾ����
function CreateAddEmptyCueWnd()
	local Wnd = CAddEmptyCueWnd:new()
	Wnd:CreateFromRes("AddEmptyCueWnd",g_GameMain)
	Wnd:ShowWnd( true )
	Wnd.m_AddEmptyCueWndYes = Wnd:GetDlgChild("AddEmptyCueWndYes")
end

function CAddEmptyCueWnd:OnCtrlmsg(Child, uMsgID, uParam1, uParam2 )
	if(Child == self.m_AddEmptyCueWndYes and uMsgID == BUTTON_LCLICK ) then
		self:ShowWnd(false)
	end
end

local rollmsgtbl = {}
local function CheckHaveMsgRollTickFun()
	local Wnd = g_GameMain.m_CreateChatWnd.m_CSysRollArea 
	if Wnd.m_SysRollAreaWord:GetWndText() == "" and #rollmsgtbl > 0 then
		Wnd.m_SysRollAreaWord:SetWndText(rollmsgtbl[1])
		Wnd.m_SysRollAreaWord:SetStep(3, 1)
		table.remove(rollmsgtbl,1)
		if #rollmsgtbl == 0 then
			UnRegisterTick(Wnd.m_CheckHaveMsgRollTick)
			Wnd.m_CheckHaveMsgRollTick = nil
		end
	end
end

--������ˢboss�������ӿ���ϵͳ������������ʾ
function SysRollAreaMsg(msg)
	if g_GameMain == nil then
		return
	end
	if msg then
		table.insert(rollmsgtbl,msg)
	end
	if #rollmsgtbl > 0 then
		local Wnd = g_GameMain.m_CreateChatWnd.m_CSysRollArea 
		if Wnd.m_SysRollAreaWord:GetWndText() == "" then
			Wnd.m_SysRollAreaWord:SetWndText(rollmsgtbl[1])
			table.remove(rollmsgtbl,1)
			Wnd.m_SysRollAreaWord:SetStep(3, 1)
		else
			if not Wnd.m_CheckHaveMsgRollTick then
				Wnd.m_CheckHaveMsgRollTick = RegisterTick("CheckHaveMsgRollTickFun", CheckHaveMsgRollTickFun, 200)
			end
		end
	end
end

--ÿСʱ50���Ӳ����ñ����������
function CheckTimeSysRollAreaMsg()
	if g_GameMain == nil then
		return
	end
	local sum = 0
	local keys = SysRollMsg_Client:GetKeys()
	for i ,p in pairs(keys) do
		sum = sum + SysRollMsg_Client(p,"Weight")
	end
	local random = math.random(sum)
	local s = 0 
	for i ,p in pairs(keys) do
		s = s + SysRollMsg_Client(p,"Weight")
		if (random <= s )  then
			local Wnd = g_GameMain.m_CreateChatWnd.m_CSysRollArea 
			table.insert(rollmsgtbl,Lan_SysRollMsg_Client(p,"Msg"))
			if Wnd.m_SysRollAreaWord:GetWndText() == "" then
				Wnd.m_SysRollAreaWord:SetWndText(rollmsgtbl[1])
				table.remove(rollmsgtbl,1)
				Wnd.m_SysRollAreaWord:SetStep(3, 1)
			else
				if not Wnd.m_CheckHaveMsgRollTick then
					Wnd.m_CheckHaveMsgRollTick = RegisterTick("CheckHaveMsgRollTickFun", CheckHaveMsgRollTickFun, 200)
				end
			end
		end
	end
end
----------------------------------------------------------
local function CreateDialog()
	local Wnd = CRenderDialog:new()
	Wnd:CreateFromRes("NpcHeadUpDialog",g_GameMain)
	Wnd.m_NpcHeadUpDialogWnd = Wnd:GetDlgChild("NpcHeadUpDialogWnd")
	Wnd.m_NpcHeadUpDialogWnd:SetToAutoFormat( false )
	return Wnd
end

local function GetNpcHeadUpDialog()
	local number = #(g_GameMain.m_NpcHeadUpDialogTbl)
	if number >= 1 then
		local HeadUpWnd = g_GameMain.m_NpcHeadUpDialogTbl[number]
		table.remove(g_GameMain.m_NpcHeadUpDialogTbl,number)
		return HeadUpWnd
	end

	local Wnd =  CreateDialog()
	return Wnd
end

function SaveNpcHeadUpDialog()
	local tbl = {}
	local num = 20
	for i = 1,num do
		local Wnd =  CreateDialog()
		table.insert(tbl,Wnd)
	end
	return tbl
end 

--Npcͷ����ʾ������Դ
function NpcHeadUpDialog(player)
	if	player~=nil and IsCppBound(player) and player:GetRenderObject() ~= nil then
		local Wnd = GetNpcHeadUpDialog()
		player:GetRenderObject():AddChild( Wnd, eLinkType.LT_SKELETAL, "Bip01 Head" )
		Wnd:SetRenderWndHeight(100)
		player.m_NpcHeadUpDialog = Wnd
		player.m_NpcHeadUpDialog:ShowWnd(false)
		return true	
	else
		return false
	end
end

function PopNpcHeadUpDialog(Character)
	if Character and Character.m_NpcHeadUpDialog then
		Character.m_NpcHeadUpDialog:ShowWnd(false)
		if Character.m_NpcHeadUpDialog.WndIsShowTick then
			UnRegisterTick(Character.m_NpcHeadUpDialog.WndIsShowTick)
			Character.m_NpcHeadUpDialog.WndIsShowTick = nil
		end
		table.insert(g_GameMain.m_NpcHeadUpDialogTbl,Character.m_NpcHeadUpDialog)
		Character:GetRenderObject():DelChild(Character.m_NpcHeadUpDialog)
		Character.m_NpcHeadUpDialog = nil 		
	end	
end

function NpcHeadUpDialogShow(Wnd,sMsg)
	Wnd:SetOff(-150,150)
	function WndNoShow()
		Wnd:ShowWnd(false)
		UnRegisterTick(Wnd.WndIsShowTick)
		Wnd.WndIsShowTick = nil 
	end
		
	if(Wnd:IsShow())then
		Wnd.m_NpcHeadUpDialogWnd:SetWndText(sMsg)
	else
		Wnd.m_NpcHeadUpDialogWnd:SetWndText(sMsg)
		Wnd:ShowWnd(true)
	end
	if  Wnd.WndIsShowTick ~= nil then
		UnRegisterTick(Wnd.WndIsShowTick)
		Wnd.WndIsShowTick = nil
		Wnd.WndIsShowTick = RegisterTick("WndIsShowTick", WndNoShow,5000)
	else
		Wnd.WndIsShowTick = RegisterTick("WndIsShowTick", WndNoShow,5000)
	end
end
-------------------------------------------------------------------------------------------
--�������������Ϣ �ӷ������˽�������������������
function Gas2Gac:RetGetPanelInfo(g_Conn, BCBTnname, PanelPosition, PanelShow)
	g_GameMain.m_CreateChatWnd.m_CChatWnd:BCBTnShowCount(BCBTnname, PanelShow, PanelPosition )
end

--�������Ƶ��������Ϣ
function Gas2Gac:RetGetChannelPanelInfo(g_Conn, ChannelID, IsSelect, PanelPosition)
	g_GameMain.m_CreateChatWnd.m_CChatWnd:CheckBCBTnChannelSet(ChannelID, IsSelect, PanelPosition)
end

--�����������ΪĬ�������Ϣ
function Gas2Gac:RetSetDefaultChannelPanel(g_Conn, bool)
	if( bool ) then
		g_GameMain.m_CreateChatWnd.m_CChatWnd:ReadDefaultSet()
	end	
	g_GameMain.m_CreateChatWnd.m_CChatWnd.m_ChatWndArea:SetFontSize(FontSize)
end

--���������������Ϣ
function Gas2Gac:RetRenamePanel(g_Conn, bool)
	CBTnSelect = {}
	for i = 1,5 do
		CBTnSelect[i] = g_GameMain.m_CreateChatWnd.m_CChatWnd.CBtnTbl[i]
	end
	local WndCBTnSelectID = g_GameMain.m_RenameWnd.m_WndCBTnSelectID
	if( bool ) then
		CBTnSelect[WndCBTnSelectID]:SetWndText(g_GameMain.m_RenameWnd.m_RenameWndEdit:GetWndText())
	end
end

--�������ɾ����Ϣ
function Gas2Gac:RetDeletePanel(g_Conn, bool )
	local Wnd = g_GameMain.m_CreateChatWnd.m_CChatWnd
	local count = g_WndCBTnAmount
	local WndCBTnSelectID = g_GameMain.m_DeleteWnd.m_WndCBTnSelectID
	local function ExchangeInfo(LeftHandTbl,RightHandTbl)
		for i = 1,#(RightHandTbl) do
			LeftHandTbl[i].IsSubscribe = RightHandTbl[i].IsSubscribe
		end	
	end
	
	
	if( bool ) then
		if( WndCBTnSelectID == 1 ) then	
			for i = 1, count - 1  do
				Wnd.CBtnTbl[i]:SetWndText(Wnd.CBtnTbl[i+1]:GetWndText())
				Wnd.ChatInfoTbl[i] = Wnd.ChatInfoTbl[i+1]	
				ExchangeInfo(Wnd.CBTnArray[i], Wnd.CBTnArray[i+1])
				Gac2Gas:MovePosB2PosA(g_Conn, i, i+1)	
			end	
		elseif ( WndCBTnSelectID == 2) then
			for i = 2, count - 1  do 
				Wnd.CBtnTbl[i]:SetWndText(Wnd.CBtnTbl[i+1]:GetWndText())
				Wnd.ChatInfoTbl[i] = Wnd.ChatInfoTbl[i+1]
				ExchangeInfo(Wnd.CBTnArray[i], Wnd.CBTnArray[i+1])
				Gac2Gas:MovePosB2PosA(g_Conn, i, i+1)
			end 
		elseif ( WndCBTnSelectID == 3) then
			for i = 3, count - 1  do 
				Wnd.CBtnTbl[i]:SetWndText(Wnd.CBtnTbl[i+1]:GetWndText())
				Wnd.ChatInfoTbl[i] = Wnd.ChatInfoTbl[i+1]
				ExchangeInfo(Wnd.CBTnArray[i], Wnd.CBTnArray[i+1])
				Gac2Gas:MovePosB2PosA(g_Conn, i, i+1)
			end
		elseif ( WndCBTnSelectID == 4) then
			for i = 4, count - 1  do 
				Wnd.CBtnTbl[i]:SetWndText(Wnd.CBtnTbl[i+1]:GetWndText())
				Wnd.ChatInfoTbl[i] = Wnd.ChatInfoTbl[i+1]
				ExchangeInfo(Wnd.CBTnArray[i], Wnd.CBTnArray[i+1])
				Gac2Gas:MovePosB2PosA(g_Conn, i, i+1)
			end
			if g_WndCBTnAmount == 5 then
				g_WndCBTnSelectID = 4
			elseif g_WndCBTnAmount == 4 then
				g_WndCBTnSelectID = 3
			end
		elseif( WndCBTnSelectID == 5) then
			g_WndCBTnSelectID = 4
		end
		
		g_GameMain.m_CreateChatWnd.m_CChatWnd.CBtnTbl[g_WndCBTnSelectID]:SetCheck(true)
		Wnd.CBtnTbl[g_WndCBTnAmount]:ShowWnd(false)
		local ChatInfoArray = {Wnd.ChatInfoTbl[1],Wnd.ChatInfoTbl[2],Wnd.ChatInfoTbl[3],Wnd.ChatInfoTbl[4],Wnd.ChatInfoTbl[5]}
		for i = g_WndCBTnAmount, 5 do 
			ChatInfoArray[i] = {}
			Wnd.CBTnArray[i][1] = {IsSubscribe = ChannelTable_Client(i,"GM")}
			Wnd.CBTnArray[i][2] = {IsSubscribe = ChannelTable_Client(i,"World")}
			Wnd.CBTnArray[i][3] = {IsSubscribe = ChannelTable_Client(i,"Camp")}	
			Wnd.CBTnArray[i][4] = {IsSubscribe = ChannelTable_Client(i,"Map")}
			Wnd.CBTnArray[i][5] = {IsSubscribe = ChannelTable_Client(i,"Region")}
			Wnd.CBTnArray[i][6] = {IsSubscribe = ChannelTable_Client(i,"Team")}
			Wnd.CBTnArray[i][7] = {IsSubscribe = ChannelTable_Client(i,"Party")}
			Wnd.CBTnArray[i][8] = {IsSubscribe = ChannelTable_Client(i,"Troop")}
			Wnd.CBTnArray[i][9] = {IsSubscribe = ChannelTable_Client(i,"NPC")}		
		end
		for i = 1,5 do
			Wnd.ChatInfoTbl[i]  = ChatInfoArray[i]
		end

		g_GameMain.m_CreateChatWnd.m_CChatWnd:ChatInfoShow()
		g_WndCBTnAmount = g_WndCBTnAmount - 1
	end
end

--����������Ϣ����
function Gas2Gac:ChannelMessage(g_Conn, Character_Id, playerCharName, uChannel_Id, sMsg,uCamp)
	if nil == g_GameMain then
		return
	end
	local textFltMgr = CTextFilterMgr:new()
	--ȥ��ǰ��ո�
  	sMsg = textFltMgr:RemoveTab1(sMsg)
	--�á�**���滻���в��Ϸ��ַ�
  	sMsg = textFltMgr:ReplaceInvalidChar(sMsg)
  	if string.len(sMsg) == 0 then
  		return
  	end	
	g_GameMain.m_CreateChatWnd.m_CChatWnd:ChatInfoSet(Character_Id, playerCharName, uChannel_Id, sMsg,uCamp)
end

--����������Ϣ����(��������������Ϣ�������)_
function Gas2Gac:NowChannelMessage(g_Conn, Npc_Id, NpcName, sMsg)
	g_GameMain.m_CreateChatWnd.m_CChatWnd.m_ChatWndArea:SetWndText(NpcName..":"..sMsg.."#r")
end

function Gas2Gac:ReturnSaveChatInWorldShow(Conn)
	g_GameMain.m_CreateChatWnd.m_MsgShowWnd.m_CheckBtn:SetCheck(true)
end


function Gas2Gac:ReturnSaveChatInCHItemShow(Conn)
	g_GameMain.m_CreateChatWnd.m_CHItemMsgShowWnd.m_CheckBtn:SetCheck(true)
end

function Gas2Gac:ReturnSaveChatInCHMoneyShow(Conn)
	g_GameMain.m_CreateChatWnd.m_CHMoneyMsgShowWnd.m_CheckBtn:SetCheck(true)
end

--����ӳ�书��
function StartChat()
	g_GameMain.m_CreateChatWnd.m_CChatWnd:CheckInputActive(Wnd, Msg, wParam, lParam)
end

--��Ʒ���͹��˺���
function AddItemName(Msg)
	local words = {}
	local word
	--��ȡƥ���ַ�
	for word in string.gfind(Msg, "(%[%d+%])") do
		for i ,p in pairs(words) do
			if p == word then
				table.remove(words,i)
				break
			end
		end
		table.insert(words, word)
	end
	
	--�滻�����ַ�Ϊ�̶���ʽ
	for i ,p in pairs(words) do
		local nItemID = tonumber(string.sub(p,2,-2))
		local Name = GetItemViewName(nItemID)
		if Name ~= nil and Name ~= "" then
			local DynInfo = g_DynItemInfoMgr:GetDynItemInfo(nItemID)	
			local ColorStr = g_Tooltips:GetSuitNameColor(DynInfo,DynInfo.m_nBigID,DynInfo.m_nIndex)
			ColorStr = string.gsub(ColorStr,"#","")
			local temp = ColorStr .. "[" .. "(" .. Name .. ")" .. nItemID .. "]" 
			Msg = string.gsub(Msg, "%[" .. nItemID .. "%]", temp)
		end
	end	
	
	--��סshift������淢���Լ�����ĳ����ӵ��ַ���ƥ��
	local tempStr = ""
	local scenename = g_GameMain.m_SceneName or ""
	local pos = CPos:new()
	g_MainPlayer:GetGridPos(pos)
	Msg = string.gsub(Msg,"%[[^%p]%S-%(%d+%p?%d+%)%]","%1[" .. "*" .. scenename .. "("  .. pos.x .. "," .. pos.y .. ")]")
	return Msg
end

--������Ʒ��ID�õ���Ʒ������
function GetItemViewName(nItemID)
	local DynInfo = g_DynItemInfoMgr:GetDynItemInfo(nItemID)
	local ItemTable = g_GameMain.m_CreateChatWnd.m_ChatSendArea.ItemTable
	if DynInfo ~= nil then
		if DynInfo.ViewName ~= nil and DynInfo.ViewName ~= "" then
			return DynInfo.ViewName
		else
			if ItemTable[tonumber(nItemID)] ~= nil then
				return ItemTable[tonumber(nItemID)].Index
			end
		end
	end
end

function Gas2Gac:SendNpcRpcMessageByMessageID(Conn, NpcInfo, Channel_Id, MsgID)
	local sMsg = GetStaticTextClient(MsgID)
	Gas2Gac:SendNpcRpcMessage(Conn, NpcInfo, Channel_Id,sMsg)
end
--npc˵��
function Gas2Gac:SendNpcRpcMessage(Conn, NpcInfo, Channel_Id,sMsg)
	if g_GameMain == nil then
		return
	end
	if( Channel_Id == ChannelIdTbl["NPC"] and tonumber(NpcInfo) )then
		local NpcObj = CCharacterFollower_GetCharacterByID(NpcInfo)
		if NpcObj ~= nil then  
			local NpcName = NpcObj.m_Properties:GetCharName()
			if NpcObj.m_NpcHeadUpDialog == nil  then
				local bIsCreate = NpcHeadUpDialog(NpcObj)
				if not bIsCreate then
					return
				end
			end
			local wnd = NpcObj.m_NpcHeadUpDialog
			wnd.m_NpcHeadUpDialogWnd:SetAutoWidth(90, 120)
			wnd.m_NpcHeadUpDialogWnd:SetMinHeight(35)
			NpcHeadUpDialogShow(wnd,sMsg)
			NpcInfo = NpcName
		else
			return
		end
	end	
	
	--local NpcName = GetNpcTitleName(NpcInfo)
	local NpcName = GetNpcDisplayName(NpcInfo)
	sMsg = ModeConversion(sMsg,ChannelColorTbl[Channel_Id])
	assert(NpcName,"NpcInfo��ֵΪ:" .. NpcInfo .. "Ƶ��IDΪ:" ..  Channel_Id)  
	NpcName = ModifyNpcMsg( Channel_Id, NpcName)
	local Wnd = g_GameMain.m_CreateChatWnd.m_CChatWnd
	if(Wnd.CBTnArray[1][Channel_Id].IsSubscribe == 1)then
		InsertMsgToTbl(Wnd.ChatInfoTbl[1],NpcName,sMsg)
	end  	
	if(Wnd.CBTnArray[2][Channel_Id].IsSubscribe == 1 and Wnd.CBtnTbl[2]:IsShow()) then 
		InsertMsgToTbl(Wnd.ChatInfoTbl[2],NpcName,sMsg)
	end
	if(Wnd.CBTnArray[4][Channel_Id].IsSubscribe == 1 and Wnd.CBtnTbl[4]:IsShow() ) then 
		InsertMsgToTbl(Wnd.ChatInfoTbl[4],NpcName,sMsg)
	end
	if(Wnd.CBTnArray[5][Channel_Id].IsSubscribe == 1 and Wnd.CBtnTbl[5]:IsShow()) then 
		InsertMsgToTbl(Wnd.ChatInfoTbl[5],NpcName,sMsg)
	end	
	Wnd:ChatInfoShow()
end

local TypeNum2TypeStrTbl = 
{
	[1] = "����",
	[2] = "����",
	[3] = "����ս��",
	[4] = "����ս��",
	[5] = "ս����",
	[6] = "�ͷż���",
}

local function GetTxt(TxtNumber, NpcName, TypeNum)
	local ContentTbl = {}
	local TriggerType = TypeNum2TypeStrTbl[TypeNum]
	local NpcContent = g_NpcShowContentCfg[NpcName][TriggerType]
	if NpcContent then
		ContentTbl = NpcContent["ContentTbl"]
	end
	return ContentTbl[TxtNumber][1],ContentTbl[TxtNumber][2]
end

function Gas2Gac:RetShowTextNpc(Conn, NpcId, NpcName, Channel_Id, TxtNumber, TypeNum)
	local sMsg, music = GetTxt(TxtNumber, NpcName, TypeNum)
	NpcShowContext(NpcId, NpcName, sMsg, Channel_Id, music)
end	

local function GetDoSkillTxt(TxtNumber, NpcName, SkillName, Operation)
	local ContentTbl = {}
	local NpcContent = g_NpcShowContentCfg[NpcName][Operation][SkillName]
	if NpcContent then
		ContentTbl = NpcContent["ContentTbl"]
	end
	return ContentTbl[TxtNumber][1],ContentTbl[TxtNumber][2]
end

function Gas2Gac:NpcDoSkillTalk(Conn, NpcId, NpcName, Channel_Id, TxtNumber, SkillName)
	local sMsg, music = GetDoSkillTxt(TxtNumber, NpcName, SkillName, "�ͷż���")
	NpcShowContext(NpcId, NpcName, sMsg, Channel_Id, music)
end	

function Gas2Gac:NpcDoSkillAdvise(Conn, NpcName, TxtNumber, SkillName)
	local sMsg = GetDoSkillTxt(TxtNumber, NpcName, SkillName, "���ܾ�����ʾ")
	MsgClient(140001, sMsg)
end	

function Gas2Gac:NpcDoSkillAdviseRepl(Conn, NpcName, TxtNumber, SkillName, replaceStr, Str)
	local sMsg = GetDoSkillTxt(TxtNumber, NpcName, SkillName, "���ܾ�����ʾ")
	sMsg = string.gsub(sMsg, replaceStr, Str)
	MsgClient(140001, sMsg)
end	

local function GetTheaterTxt(SayNumber, RandomNum)
	local index = MemH64(SayNumber)
	if Lan_NpcTheater_Server(index) then
		local Sentence = Lan_NpcTheater_Server(index, "Sentence")
		if RandomNum == -1 then
			return Sentence
		else
			local Tbl = loadstring("return {" .. Sentence.. "}")()
			if RandomNum == 0 then
				Sentence = Tbl[math.random(table.maxn(Tbl))][1]
			else
				Sentence = Tbl[RandomNum][1]
			end
			return Sentence
		end
	end
end

function Gas2Gac:ShowTheaterNpcTalk(Conn, NpcId, NpcName, ChannelId, SayNumber, RandomNum)
	local sMsg = GetTheaterTxt(SayNumber, RandomNum)
	NpcShowContext(NpcId, NpcName, sMsg, ChannelId)
end

local function GetAndReplaceTheaterTxt(SayNumber, replaceStr, Str)
	local index = MemH64(SayNumber)
	if Lan_NpcTheater_Server(index) then
		local Sentence = Lan_NpcTheater_Server(index, "Sentence")
		Sentence = string.gsub(Sentence, replaceStr, Str)
		return Sentence
	end
end

function Gas2Gac:ShowTheaterNpcDoTalk(Conn, NpcId, NpcName, ChannelId, SayNumber, replaceStr, Str)
	local sMsg = GetAndReplaceTheaterTxt(SayNumber, replaceStr, Str)
	NpcShowContext(NpcId, NpcName, sMsg, ChannelId)
end

function NpcShowContext(NpcId, NpcName, sMsg, Channel_Id, Music)
	if sMsg == nil or sMsg == "" then
		return
	end
	--NpcName = GetNpcTitleName(NpcName)
	NpcName = GetNpcDisplayName(NpcName)
	sMsg = ModeConversion(sMsg,ChannelColorTbl[Channel_Id])	
	NpcName = ModifyNpcMsg( Channel_Id, NpcName)
	local Wnd = g_GameMain.m_CreateChatWnd.m_CChatWnd
	if(Wnd.CBTnArray[1][Channel_Id].IsSubscribe == 1)then
		InsertMsgToTbl(Wnd.ChatInfoTbl[1],NpcName,sMsg)
	end  	
	if(Wnd.CBTnArray[2][Channel_Id].IsSubscribe == 1 and Wnd.CBtnTbl[2]:IsShow()) then 
		InsertMsgToTbl(Wnd.ChatInfoTbl[2],NpcName,sMsg)
	end
	if(Wnd.CBTnArray[4][Channel_Id].IsSubscribe == 1 and Wnd.CBtnTbl[4]:IsShow() ) then 
		InsertMsgToTbl(Wnd.ChatInfoTbl[4],NpcName,sMsg)
	end
	if(Wnd.CBTnArray[5][Channel_Id].IsSubscribe == 1 and Wnd.CBtnTbl[5]:IsShow()) then 
		InsertMsgToTbl(Wnd.ChatInfoTbl[5],NpcName,sMsg)
	end	
	if( Channel_Id == ChannelIdTbl["����"] or Channel_Id == ChannelIdTbl["NPC"] )then
		local NpcObj = CCharacterFollower_GetCharacterByID(NpcId)
		if NpcObj ~= nil then  
			if NpcObj.m_NpcHeadUpDialog == nil  then
				local bIsCreate = NpcHeadUpDialog(NpcObj)
				if not bIsCreate then
					return
				end
			end
			local wnd = NpcObj.m_NpcHeadUpDialog
			wnd.m_NpcHeadUpDialogWnd:SetAutoWidth(90, 120)
			wnd.m_NpcHeadUpDialogWnd:SetMinHeight(35)
			NpcHeadUpDialogShow(wnd,sMsg)
		end
	end
	Wnd:ChatInfoShow()
	if Music and Music ~= "" then
	  if g_MainPlayer.m_MusicFlag and CueIsStop(g_MainPlayer.m_MusicFlag) then
	  	StopCue(g_MainPlayer.m_MusicFlag)
	  end
		g_MainPlayer.m_MusicFlag = Music
		PlayCue(Music)
	end
end

------------------------------ϵͳ��Ϣ��----------------------------------------
local AllTime = 1000

local function ImportMsgOnTick(Tick, Wnd)
	if Wnd.TickRunTime >= 7 then
		UnRegisterTick(Wnd.m_ImportMsgOnTick)
		Wnd.m_ImportMsgOnTick = nil
		Wnd.TickRuned = true
		Wnd.TickRunTime = nil		
		Wnd:SetTransparentObj(AllTime,true)
		return
	end
	
	Wnd.TickRuned = false
	Wnd.TickRunTime = Wnd.TickRunTime + 1
end

function DataExchange(Msg,Wnd ,TransparentValue,TickRunTime,TickRuned)
	local NextTransparentValue = Wnd:GetTransparent()
	local NextText = Wnd:GetWndText()
	local NextTickTime = Wnd.TickRunTime and Wnd.TickRunTime or 0
	local NextTickRuned = Wnd.TickRuned and Wnd.TickRuned or false
	
	Wnd:ShowWnd(true)
	Wnd.TickRunTime = TickRunTime
	Wnd:SetTransparent(TransparentValue)
	Wnd:SetWndText(Msg)
	if TickRuned then
		Wnd:SetTransparentObj(AllTime*TransparentValue,true)
	else
		Wnd:EndTransparent(false)
		if Wnd.m_ImportMsgOnTick ~= nil then
			if Wnd.TickRunTime == 0 then
				NextTickRuned = false
			end
			UnRegisterTick(Wnd.m_ImportMsgOnTick)
			Wnd.m_ImportMsgOnTick = nil
		end
		Wnd.m_ImportMsgOnTick = RegisterTick("ImportMsgOnTick", ImportMsgOnTick,500,Wnd)
	end
	return NextText,NextTransparentValue,NextTickTime,NextTickRuned
end

function CImportMsg:AddMsg(Msg)
	Msg = "#cFF0000" .. Msg
	
	if Msg == self.m_ImportMsgText1:GetWndText() and self.m_ImportMsgText1:IsShow() then
		return
	end
	
	if self.m_ImportMsgText5:IsShow() then
		local Text1,TransparentValue1,TickTime1,TickRuned1 =	DataExchange(Msg,self.m_ImportMsgText1,1,0,false)
		local Text2,TransparentValue2,TickTime2,TickRuned2 =	DataExchange(Text1,self.m_ImportMsgText2,TransparentValue1,TickTime1,TickRuned1)
		local Text3,TransparentValue3,TickTime3,TickRuned3 =	DataExchange(Text2,self.m_ImportMsgText3,TransparentValue2,TickTime2,TickRuned2)	
		local Text4,TransparentValue4,TickTime4,TickRuned4 =	DataExchange(Text3,self.m_ImportMsgText4,TransparentValue3,TickTime3,TickRuned3)		
		DataExchange(Text4,self.m_ImportMsgText5,TransparentValue4,TickTime4,TickRuned4)
	elseif self.m_ImportMsgText4:IsShow() then
		local Text1,TransparentValue1,TickTime1,TickRuned1 =	DataExchange(Msg,self.m_ImportMsgText1,1,0,false)
		local Text2,TransparentValue2,TickTime2,TickRuned2 =	DataExchange(Text1,self.m_ImportMsgText2,TransparentValue1,TickTime1,TickRuned1)
		local Text3,TransparentValue3,TickTime3,TickRuned3 =	DataExchange(Text2,self.m_ImportMsgText3,TransparentValue2,TickTime2,TickRuned2)	
		local Text4,TransparentValue4,TickTime4,TickRuned4 =	DataExchange(Text3,self.m_ImportMsgText4,TransparentValue3,TickTime3,TickRuned3)		
		DataExchange(Text4,self.m_ImportMsgText5,TransparentValue4,TickTime4,TickRuned4)
	elseif self.m_ImportMsgText3:IsShow() then
		local Text1,TransparentValue1,TickTime1,TickRuned1 =	DataExchange(Msg,self.m_ImportMsgText1,1,0,false)
		local Text2,TransparentValue2,TickTime2,TickRuned2 =	DataExchange(Text1,self.m_ImportMsgText2,TransparentValue1,TickTime1,TickRuned1)
		local Text3,TransparentValue3,TickTime3,TickRuned3 =	DataExchange(Text2,self.m_ImportMsgText3,TransparentValue2,TickTime2,TickRuned2)	
		DataExchange(Text3,self.m_ImportMsgText4,TransparentValue3,TickTime3,TickRuned3)	
	elseif self.m_ImportMsgText2:IsShow() then
		local Text1,TransparentValue1,TickTime1,TickRuned1 =	DataExchange(Msg,self.m_ImportMsgText1,1,0,false)
		local Text2,TransparentValue2,TickTime2,TickRuned2 =	DataExchange(Text1,self.m_ImportMsgText2,TransparentValue1,TickTime1,TickRuned1)
		DataExchange(Text2,self.m_ImportMsgText3,TransparentValue2,TickTime2,TickRuned2)
	elseif self.m_ImportMsgText1:IsShow() then
		local Text1,TransparentValue1,TickTime1,TickRuned1 =	DataExchange(Msg,self.m_ImportMsgText1,1,0,false)
		DataExchange(Text1,self.m_ImportMsgText2,TransparentValue1,TickTime1,TickRuned1)
	else
		DataExchange(Msg,self.m_ImportMsgText1,1,0,false)
	end
end

function CImportMsg:UnRegisterImportMsg()
	local tbl = {}
	tbl[1] = self.m_ImportMsgText1
	tbl[2] = self.m_ImportMsgText2
	tbl[3] = self.m_ImportMsgText3
	tbl[4] = self.m_ImportMsgText4
	tbl[5] = self.m_ImportMsgText5

	for i = 1 , 5 do 
		if tbl[i].m_ImportMsgOnTick ~= nil then
			UnRegisterTick(tbl[i].m_ImportMsgOnTick)
			tbl[i]:SetWndText("")
			tbl[i].m_ImportMsgOnTick = nil			
		end
	end
end

--ϵͳ�����
function Gas2Gac:SysMovementNotifyToClient(Conn,message)
	if message and message ~="" then
		SysRollAreaMsg(message)
	end
end

--ÿ��1���Ӽ�⵱ǰʱ���ǲ���ÿ��Сʱ��50����
function CheckTime()
	local currentMinute = tonumber(os.date("%M"))
	if currentMinute == 50 then
		CheckTimeSysRollAreaMsg()
		local Wnd =  g_GameMain.m_CreateChatWnd.m_CSysRollArea
		if Wnd.m_ChatWndTick then
			UnRegisterTick(Wnd.m_ChatWndTick)
		end
		Wnd.m_ChatWndTick = RegisterTick("CheckTime", CheckTime , 1000*60*60)
	end
end

--��CTRL+���ּ���0��ʾ/�������촰
function OpenChatWnd()
	g_GameMain.m_CreateChatWnd.m_CChatWnd:ShowWnd(not g_GameMain.m_CreateChatWnd.m_CChatWnd:IsShow())
end

--@brief ��CTRL+���ּ���1���촰�л����ۺ�Ƶ��
--@param index:Ƶ����ǩҳ(1-�ۺ�Ƶ����2-����Ƶ����3-ս��Ƶ����4-�Զ���1Ƶ����5-�Զ���2Ƶ��)
function ChangeChatToChannel(index)
	local Wnd = g_GameMain.m_CreateChatWnd
	if index >= 1 and index <= 5 then
		Wnd.m_CChatWnd.CBtnTbl[index]:SetCheck(true)
		g_WndCBTnSelectID = index
		Wnd.m_CChatWnd:ChatInfoShow()
	end
end

function UnRegisterSetPageUpTick()
	if SetPageUpTick then
		UnRegisterTick(SetPageUpTick)
		b_IsSetPageUp = false
	end
end

local function SetPageUpTickFuc()
	g_GameMain.m_CreateChatWnd.m_CChatWnd.m_ChatWndArea:SetPageUp()
end


--���촰���Ϸ�ҳ��
function SetPageUp()
	if not b_IsSetPageUp then
		SetPageUpTickFuc()
		UnRegisterSetPageDownTick()
		SetPageUpTick = RegisterTick("SetPageUp", SetPageUpTickFuc, 100)
		b_IsSetPageUp = true
	else
		UnRegisterTick(SetPageUpTick)
		b_IsSetPageUp = false
	end
end 

function UnRegisterSetPageDownTick()
	if SetPageDownTick then
		UnRegisterTick(SetPageDownTick)
		b_IsSetPageDown = false
	end
end

local function SetPageDownTickFuc()
	g_GameMain.m_CreateChatWnd.m_CChatWnd.m_ChatWndArea:SetPageDown()
end

--���촰���·�ҳ��
function SetPageDown()
	if not b_IsSetPageDown then
		SetPageDownTickFuc()
		UnRegisterSetPageUpTick()
		SetPageDownTick = RegisterTick("SetPageDown", SetPageDownTickFuc, 100)
		b_IsSetPageDown = true
	else
		UnRegisterTick(SetPageDownTick)
		b_IsSetPageDown = false
	end
end

--���촰�ڷ��õײ�
function SetPageBottom()
	g_GameMain.m_CreateChatWnd.m_CChatWnd.m_ChatWndArea:SetPageBottom()
end 

function Gas2Gac:SendPlayerBossMsg(Conn, MessageId, PlayerName, SceneName, AreaName)
	local message = GetStaticTextClient(MessageId, PlayerName, GetSceneDispalyName(SceneName), GetAreaDispalyName(AreaName))
	SysRollAreaMsg(message)
end
