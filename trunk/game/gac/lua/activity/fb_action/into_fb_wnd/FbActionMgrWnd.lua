gac_require "activity/fb_action/into_fb_wnd/FbActionMgrWndInc"

gac_require "activity/fb_action/into_fb_wnd/jifensai_wnd/ScoreInfoWnd"
gac_require "activity/fb_action/into_fb_wnd/dataosha_wnd/ScoreInfoWnd"
gac_require "relation/tong/RobResourceWnd/ScoreInfoWnd"
gac_require "activity/fb_action/into_fb_wnd/jifensai_wnd/CountScoreWnd"
gac_require "activity/fb_action/into_fb_wnd/dataosha_wnd/CountScoreWnd"
--gac_require "activity/fb_action/mercenary_eduact_wnd/ScoreInfoWnd"
cfg_load "tong/TongStartTime_Common"

local StartSignTime = GetCfgTransformValue(false,"TongStartTime_Common", "������Դ�㱨��ʱ��", "OpenTime")	--��ҿ��Կ�ʼ������ʱ��(��)
local GameLength = TongStartTime_Common("������Դ����Ϸʱ��", "OpenTime")
local WaitJointTime = TongStartTime_Common("������Դ�㱨��ʱ��", "OpenTime") 
local WaitEnterSceneTime = TongStartTime_Common("������Դ�����ʱ��", "OpenTime")	
local m_FbName1 = "������"--GetStaticTextClient(9401)--������
local m_FbName2 = "�Ƕ���"--GetStaticTextClient(9400)--�Ƕ���
local m_FbName3 = "Ӷ��ѵ���"--GetStaticTextClient(9402)--Ӷ��ѵ���
local m_FbName4 = "������Դ��"

local function SetWndRect(ParentWnd,ChildWnd)
	local rt = CFRect:new()
	ParentWnd:GetLogicRect(rt)
	
	local rt_1 = CFRect:new()
	ChildWnd:GetLogicRect(rt_1)
	local width = rt_1.right-rt_1.left
	local height = rt_1.bottom-rt_1.top
	
	rt_1.right = rt.right - 10
	rt_1.left = rt_1.right - width
	ChildWnd:SetLogicRect(rt_1)
end

function CreateFbActionMgrWnd(parent)
	local Wnd = CFbActionMgrWnd:new()
	Wnd:CreateFromRes("FbActionWnd",parent)
	Wnd.m_TitleWnd = Wnd:GetDlgChild("Title")
	Wnd.m_ShowInfoBtn = Wnd:GetDlgChild("ShowWndBtn")
	Wnd.m_ShowInfoBtn:SetCheck(true)
	--SetWndRect(parent,Wnd)

	----------------------------------------------
	Wnd.m_FbActionFun = {
			[m_FbName1] = CreateJFSScoreInfoWnd(Wnd),--��ʼ����������Ϣ���
			[m_FbName2] = CreateDTSScoreInfoWnd(Wnd),--��ʼ������ɱ��Ϣ���
			[m_FbName3] = CYbEduActScoreInfoWnd:new(Wnd),--��ʼ��Ӷ�������Ϣ���
			[m_FbName4] = CreateRobResScoreInfoWnd(Wnd),
			}
	---------------------------------------------

	return Wnd
end

function CFbActionMgrWnd:GetListGameTime(SecondNum)
	local Hour = 0
	local Min = 0
	local Sec = 0
	Hour = math.floor(SecondNum / 3600)
	Min = math.floor((SecondNum-(Hour*3600)) / 60)
	Sec = SecondNum - Hour*3600 - Min * 60
	local GameTime = Hour..GetStaticTextClient(1121)..Min..GetStaticTextClient(1120)..Sec..GetStaticTextClient(1119)
	return GameTime
end

function CFbActionMgrWnd:GetOffsetSecond(strTime)
	local index1 = string.find(strTime, ":")
	local index2 = string.find(strTime, ":", index1 + 1) or 0
	local hour = tonumber(string.sub(strTime, 1, index1 - 1))
	local min = tonumber(string.sub(strTime, index1 + 1, index2 -1))
	local sec = 0
	if index2 ~= 0 then
		sec = tonumber(string.sub(strTime, index2 + 1, -1))
	end
	assert(hour and min and sec, "ʱ���ʽ����")
	return (hour * 60 + min) * 60  + sec
end

function CFbActionMgrWnd:GetTime()
	local nowtime = os.time()
	local nowdate = os.date("*t")
	local nowhour = nowdate.hour
	local nowmin = nowdate.min
	local nowsec = nowdate.sec
	local time = (nowhour * 60 + nowmin) * 60 + nowsec
	local startTime = self:GetOffsetSecond(StartSignTime.time[1])
	local backTime = time - startTime - WaitJointTime * 60 - WaitEnterSceneTime
	return backTime
end

function CFbActionMgrWnd:ShowDownTime(FbName,ResidualTime)
	if ResidualTime <= 0 then
		if self then
			if FbName == "������Դ��" then
				local gameTime = GameLength * 60 + ResidualTime
				if gameTime <= 0 then
					LogErr("��Դ��ʱ�������ʾ����۲�Log", "��Ϸʱ��:"..gameTime.."***:"..ResidualTime)
					return 
				end
				local function RobResourceDownTime()
					gameTime = gameTime - 1
					local tempStr = GetStaticTextClient(190007, self:GetListGameTime(gameTime))
					if self.m_TitleWnd then
						self.m_TitleWnd:SetWndText(tempStr)
						self.m_ShowInfoBtn:ShowWnd(false)
					else
						LogErr("��Դ��ʱ�������ʾ�������۲�Log", "��Ϸʱ��:"..gameTime.."***:"..ResidualTime)
					end
					if gameTime <= 0 then
						UnRegisterTick(self.m_RobResourceDownTime)
						self.m_RobResourceDownTime = nil
					end
				end

				if self.m_RobResourceDownTime then
					UnRegisterTick(self.m_RobResourceDownTime)
					self.m_RobResourceDownTime = nil
				end 
				self.m_RobResourceDownTime = RegisterTick("RobResourceWndTick",RobResourceDownTime,1000)
			else
				self.m_FbActionFun[FbName]:SetTime()
				self.m_TitleWnd:SetWndText("")
			end
		end
		return 
	end
	
	local nowTime = ResidualTime
	local function DownTime()
		nowTime = nowTime - 1
		local StrInfo = GetStaticTextClient(8811, nowTime)
		if FbName == "������Դ��" then
			self.m_ShowInfoBtn:ShowWnd(false)
		end
		if nowTime <= 0 then
			if self.m_DownTimeTick then
				UnRegisterTick(self.m_DownTimeTick)
				self.m_DownTimeTick = nil
			end
			
			if FbName ~= "������Դ��" then
				self.m_FbActionFun[FbName]:SetTime()
				StrInfo = GetStaticTextClient(9414, g_GetFbActionNameLanStr(FbName))
			else
				local gameTime = GameLength * 60
				local function RobResDownTime()
					gameTime = gameTime - 1
					local tempStr = GetStaticTextClient(190007, self:GetListGameTime(gameTime))
					if self.m_TitleWnd then
						self.m_TitleWnd:SetWndText(tempStr)
					end
					if gameTime <= 0 then
						UnRegisterTick(self.m_RobResDownTimeTick)
						self.m_RobResDownTimeTick = nil
					end
				end
				if self.m_DownTimeTick then
					UnRegisterTick(self.m_DownTimeTick)
					self.m_DownTimeTick = nil
				end
				if self.m_RobResDownTimeTick then
					UnRegisterTick(self.m_RobResDownTimeTick)
					self.m_RobResDownTimeTick = nil
				end 
				self.m_RobResDownTimeTick = RegisterTick("RobResWndTick",RobResDownTime,1000)
			end
		elseif nowTime <= 5 then
			MsgClient(3351,FbName,nowTime)
		end
		self.m_TitleWnd:SetWndText(StrInfo)
	end
	
	if self.m_DownTimeTick then
		UnRegisterTick(self.m_DownTimeTick)
		self.m_DownTimeTick = nil
	end
	
	self.m_DownTimeTick = RegisterTick("FbActionMgrWndTick",DownTime,1000)
	
end

function CFbActionMgrWnd:InitInfoWnd(FbActionType,ResidualTime)
	self:ShowDownTime(FbActionType,ResidualTime)
	if self.m_ListInfoWnd then
		self.m_ListInfoWnd:ShowWnd(false)
	end
	self.m_ListInfoWnd = self.m_FbActionFun[FbActionType]
	
	self.m_WndType = FbActionType
	
	if FbActionType ~= "������Դ��" then
		self.m_ListInfoWnd:InitInfoWnd(FbActionType)
	end
	if FbActionType == "Ӷ��ѵ���" then
		self.m_FbActionFun[m_FbName3].m_XiuXingTaInfoWnd:ShowWnd(true)
	else
		self.m_FbActionFun[m_FbName3].m_XiuXingTaInfoWnd:ShowWnd(false)
	end
	self:ShowWnd(true)
end

function CFbActionMgrWnd:OnCtrlmsg(Child, uMsgID, uParam1, uParam2 )
	if uMsgID == BUTTON_LCLICK then
		if Child == self.m_ShowInfoBtn then
			if self.m_ListInfoWnd then
				if self.m_ListInfoWnd:IsShow() then
					self.m_ShowInfoBtn:SetCheck(false)
					self.m_ListInfoWnd:ShowWnd(false)
				else
					self.m_ShowInfoBtn:SetCheck(true)
					self.m_ListInfoWnd:ShowWnd(true)
				end
			end
		end
	end
end


--�򿪸����Ƿְ�
function Gas2Gac:RetOpenFbActionWnd(Conn,FbName,ResidualTime)
	g_GameMain.m_FbActionMgrWnd:InitInfoWnd(FbName,ResidualTime)
	g_GameMain.m_FbGameTime = os.time()
	--print("RetOpenFbActionWnd",FbName)
end

--���յ��رյ���Ϣ
function Gas2Gac:RetCloseFbActionWnd(Conn,FbName)
	--print("RetCloseFbActionWnd",FbName)
	local Wnd = g_GameMain.m_FbActionMgrWnd
	if Wnd.m_WndType == FbName then
		if g_GameMain.m_FbActionScoreTick then
			UnRegisterTick(g_GameMain.m_FbActionScoreTick)
			g_GameMain.m_FbActionScoreTick = nil
		end
		if Wnd.m_DownTimeTick then
			UnRegisterTick(Wnd.m_DownTimeTick)
			Wnd.m_DownTimeTick = nil
		end
		if Wnd.m_RobResDownTimeTick then
			UnRegisterTick(Wnd.m_RobResDownTimeTick)
			Wnd.m_RobResDownTimeTick = nil
		end
		if Wnd.m_RobResourceDownTime then
			UnRegisterTick(Wnd.m_RobResourceDownTime)
			Wnd.m_RobResourceDownTime = nil
		end
		Wnd:ShowWnd(false)
		if FbName ~= "������Դ��" then
			Wnd.m_ListInfoWnd:ShowWnd(false)
		end
	end
	--�˳�ʱ,ɾ���Ŷ�����ϵ���Ϣ
	--local Wnd = CFbActionQueueWnd.GetWnd()
	--Wnd:DeleteListItem(FbName)
end

----------------------------------------
--�ڸ����н�����,�����Ĵ���
--���ִܷ���
function CreateFbActionScoreWnd(Parent)
	----------------------------------------------
	Parent.m_FbActionCountScoreWnd = {
			[m_FbName1] = CreateJFSCountScoreWnd(Parent),--��ʼ��������
			[m_FbName2] = CreateDTSCountScoreWnd(Parent),--��ʼ������ɱ
			}
end

function Gas2Gac:RetOpenCountScoreWnd(Conn,FbName,SpareTimes,StrInfoTbl)
	local Wnd = g_GameMain.m_FbActionCountScoreWnd[FbName]
	if Wnd then
		local BeginTime = g_GameMain.m_FbGameTime
		local SecondNum = 0
		if BeginTime then
			SecondNum = os.time() - BeginTime
		end
		Wnd:InitWnd(SecondNum,SpareTimes,StrInfoTbl)
	end
end

--�ر��ִܷ���
function Gas2Gac:RetCloseCountScoreWnd(Conn,FbName)
	local Wnd = g_GameMain.m_FbActionCountScoreWnd[FbName]
	if Wnd then
		Wnd:ShowWnd(false)
	end
end
-----------------------------------------
