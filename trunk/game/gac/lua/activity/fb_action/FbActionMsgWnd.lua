CFbActionMsgWnd = class(SQRDialog)

local function CreateFbActionMsgWnd(parent)
	local Wnd = CFbActionMsgWnd:new()
	Wnd:CreateFromRes("FbActionMsgWnd",parent) 
	Wnd.m_BtnOk = Wnd:GetDlgChild("BtnOk")
	Wnd.m_BtnCancel = Wnd:GetDlgChild("BtnCancel")
	Wnd.m_BtnHide = Wnd:GetDlgChild("BtnHide")
	Wnd.m_InfoText = Wnd:GetDlgChild("Info")

	return Wnd
end

function CFbActionMsgWnd:DeleteTick(FbName)
	if g_GameMain.m_FbActionTick[FbName] then
		UnRegisterTick(g_GameMain.m_FbActionTick[FbName])
		g_GameMain.m_FbActionTick[FbName] = nil
		self:SetShowWnd(false)
		self:DestroyWnd()
		self = nil
	end
end

function CFbActionMsgWnd:SetShowWnd(IsShow)
	if not IsShow then
		self.m_IsHideWnd = true
	end
	self:ShowWnd(IsShow)
end

function CFbActionMsgWnd:OnCtrlmsg(Child, uMsgID, uParam1, uParam2 )
	if uMsgID == BUTTON_LCLICK then
		if Child == self.m_BtnOk then
			--self:DeleteTick(self.m_FbName)
			self.m_CallBack(true,self.m_FbName)
			--self.m_SuccFun()
		elseif Child == self.m_BtnCancel then
			
			local function IsGiveUpGame(Wnd,uButton)
				if uButton == MB_BtnOK then
					--ɾ����Ϣȷ�ϴ���
					Wnd:DeleteTick(Wnd.m_FbName)
					Wnd.m_CallBack(false,Wnd.m_FbName)
				end
				g_GameMain.m_MsgBox = nil
				return true
			end
			local ShowInfo = MsgBoxMsg(5004)
			g_GameMain.m_MsgBox = MessageBox(g_GameMain, ShowInfo, BitOr( MB_BtnOK, MB_BtnCancel), IsGiveUpGame, self)
			
			--self.m_CancelFun()
		elseif Child == self.m_BtnHide then
			self:SetShowWnd(false)
		end
	end
end

function CFbActionMsgWnd:ShowMsgInfo()
	local FbActionQueueWnd = CFbActionQueueWnd.GetWnd()
	if not IsCppBound(g_MainPlayer) and not g_GameMain.m_IsTransfer then
		self:DeleteTick(self.m_FbName)
		--FbActionQueueWnd:DeleteListItem(self.m_FbName)
		return
	end
	
	--self:IsShowJoinBtn()--��Ť�Ƿ����
	
	if self.m_FbInfoShowTime == 0 then
		self:DeleteTick(self.m_FbName)
		self.m_CallBack(true,self.m_FbName)
		FbActionQueueWnd:SetInfoBtnText(self.m_FbName, GetStaticTextClient(9454))
		return
	end
	
	-----------------
	--�ı�һ���Ŷ�����ϵĽ��빦��
	local strQueueText = ""
	if self.m_WaitOtherTeammate then
		 strQueueText = GetStaticTextClient(8816, self.m_FbInfoShowTime)
	else
		strQueueText = GetStaticTextClient(8808, self.m_FbInfoShowTime)
	end
	FbActionQueueWnd:SetInfoBtnText(self.m_FbName,strQueueText)
	-----------------
	
	if not self.m_IsHideWnd then
		local strInfo = GetStaticTextClient(8809, g_GetFbActionNameLanStr(self.m_FbName), self.m_CountTime, self.m_FbInfoShowTime)
		self.m_InfoText:SetWndText(strInfo)
	end
	
	--��ʾһ����ʾ��������Ϣ
	if self.m_FbInfoShowTime == 10 or self.m_FbInfoShowTime == 5 then
		MsgClient(3352,self.m_FbInfoShowTime, self.m_FbName)
	end
	
	self.m_FbInfoShowTime = self.m_FbInfoShowTime - 1
end

function CFbActionMsgWnd:IsShowJoinBtn()
	if g_MainPlayer and IsCppBound(g_MainPlayer) then
			--�ı�һ���Ŷ�����ϵĽ��빦��
			local FbActionQueueWnd = CFbActionQueueWnd.GetWnd()
			FbActionQueueWnd:SetJoinInBtn(self.m_FbName,true)
			-----------------
			self.m_BtnOk:EnableWnd(true)
	end
end

function CFbActionMsgWnd:InitWndInfo(FbName, TimeNum, CallBack)
	self.m_CountTime = TimeNum
	self.m_FbInfoShowTime = TimeNum
	self.m_IsHideWnd = nil
	self.m_FbName = FbName

	self:ShowMsgInfo()
	self.m_CallBack = CallBack
	
	-----------------
	--�ı�һ���Ŷ�����ϵ��˳�����
	local FbActionQueueWnd = CFbActionQueueWnd.GetWnd()
	FbActionQueueWnd:SetExitBtn(FbName,GetStaticTextClient(8810))
	-----------------
	g_GameMain.m_FbActionTick[FbName] = RegClassTick( "FbActionTick", self.ShowMsgInfo, 1000, self)
	
	local TeamType = MatchGame_Common(FbName, "TeamType")
	if TeamType then
		if string.sub(TeamType,-4,-4) == "1"  then
			FbActionQueueWnd:EnableExitBtn(FbName, false)
			self.m_BtnCancel:EnableWnd(false)
		else
			FbActionQueueWnd:EnableExitBtn(FbName, true)
			self.m_BtnCancel:EnableWnd(true)
		end
	end
	
	FbActionQueueWnd:SetJoinInBtn(FbName,true)
	self:SetShowWnd(true)
end

--1������,  2�ȴ�����ʱ��
--3�����Ѷȵȼ���4����ȼ�
function CFbActionMsgWnd.ShowFbActionMsgWnd(FbName,FbTime,FbDifficulty,NpcLevel)
	local function CallBack(IsOk,FbName)
		if IsOk then
			Gac2Gas:AgreeJoinFbAction(g_Conn,FbName)
		else
			Gac2Gas:NotJoinFbAction(g_Conn,FbName)
		end
	end
	
	--������Ϣȷ�ϴ���
	if g_GameMain.m_FbActionMsgWnd[FbName] then
		g_GameMain.m_FbActionMsgWnd[FbName]:DeleteTick(FbName)
	end
	g_GameMain.m_FbActionMsgWnd[FbName] = CreateFbActionMsgWnd(g_GameMain)
	if NpcLevel ~= 0 then
		g_GameMain.m_FbActionMsgWnd[FbName].m_EquipAssessWnd = CEquipAssessWnd:new(g_GameMain.m_FbActionMsgWnd[FbName],FbDifficulty,NpcLevel)
	end
	g_GameMain.m_FbActionMsgWnd[FbName]:InitWndInfo(FbName, FbTime, CallBack)
end
