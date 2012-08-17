gac_require "message/message_box/MsgBoxMsg"

CWhiteStone = class ( SQRDialog )
local uAcceleration = -0.0005
--�ױ�ʯ����
function CWhiteStone:Ctor( Parent )
	self:CreateFromRes( "WhiteStoneTurnTable", Parent )
	self.tbl_New_StoneName = {}
	self.whitestoneBigID = nil
	self.ToStoneID ={} --������ĸ߼���ʯ��ID
	self.m_JiandingBtn = self:GetDlgChild("jianding")
	self.pointer       = self:GetDlgChild( "pointer" )
	self.ToStone	  = self:GetDlgChild("Tostone")
	self.OK		  = self:GetDlgChild( "ok" )
	self.Colse	  = self:GetDlgChild("close")
	self.HighStoneName = self:GetDlgChild("StoneName")
	self.RotationAngle = 0
	self.RotationAcceleration = uAcceleration
	self.NeedRotationCircleNum  = 1
	self.position = 0 
	self.m_JiandingBtn:EnableWnd(false)
	self.ClickNumber = 1
	g_ExcludeWndMgr:InitExcludeWnd(self, 1)
end

function CWhiteStone.GetWnd()
	local Wnd = g_GameMain.m_whitestone
	if not Wnd then
		Wnd = CWhiteStone:new(g_GameMain)
		g_GameMain.m_whitestone = Wnd
	end
	return Wnd
end

--���û�������ʱ10���Զ�ֹͣ
function Rotation()
	local Wnd = CWhiteStone.GetWnd()
	if( Wnd.RotationAngle >=  10008) then		
		Wnd.m_JiandingBtn:EnableWnd(false)
		Wnd:ClickStopButton(Wnd.position)
		Wnd.RotationAngle = 0			
		return 
	end
	Wnd.RotationAngle = Wnd.RotationAngle + 1
	Wnd.pointer:SetRotation( Wnd.RotationAngle*3.1415926/180 )
end

function CWhiteStone:OnCtrlmsg( Child, uMsgID, uParam1, uParam2 )
	if (uMsgID == BUTTON_LCLICK) then
		if( Child == self.m_JiandingBtn) then
			--����
			if self.ClickNumber == 1 then
				if self.ToStoneID == nil or #(self.ToStoneID) == 0 then
					return
				end
				Gac2Gas:RequestStoneAppraiseAgain(g_Conn)
				self.m_JiandingBtn:EnableWnd(false)
				if self.ontimer ~= nil then 
					UnRegisterTick(self.ontimer)
					self.ontimer = nil 
				end
				self.OK:EnableWnd(false)
				self.ontimer = RegisterTick("Rotation", Rotation, 1 )
			elseif self.ClickNumber == 2 then
				self.m_JiandingBtn:EnableWnd(false)
				self.ClickNumber = 1
				if self.AnthorTimer == nil then
					self:ClickStopButton(self.position)	
				end
				self.position = 0
			end
		elseif( Child == self.OK ) then
			--��ȡ�����ı�ʯ
			Gac2Gas:TakeAppraisedStone(g_Conn)
			if #(self.ToStoneID) == 0 then
				SetEvent(Event.Test.RetTakeAppraisedStone,true)
			end
			UnRegisterTick( self.ontimer )
			UnRegisterTick( self.AnthorTimer )
		elseif( Child == self.Colse) then
			--�رջ�ȡ���Զ���ȡ
			self:OnClose()
			self:ShowWnd(false)
		end
	end
end

function CWhiteStone:OnClose()
	Gac2Gas:TakeAppraisedStone(g_Conn)
	UnRegisterTick( self.ontimer )
	UnRegisterTick( self.AnthorTimer )
	self.AnthorTimer = nil
	self.RotationAcceleration = uAcceleration
	self.NeedRotationCircleNum = 1
	self.RotationAngle = 0
	self.OK:EnableWnd(true)
end

function CWhiteStone:VirtualExcludeWndClosed()
	self:OnClose()
end

--���û�����ֹͣ��ťʱ
local function OtherRotation()
	local Wnd = CWhiteStone.GetWnd()
	local Acceleration = 1
	
	if Wnd.NeedRotationCircleNum <= 0 then
		Wnd.RotationAcceleration = Wnd.RotationAcceleration + uAcceleration
		Acceleration = Acceleration + Wnd.RotationAcceleration --ָ��ÿ���ƶ��ľ���
	end
	if(Wnd.RotationAngle >= Wnd.StopRotation) then
		Wnd.NeedRotationCircleNum = Wnd.NeedRotationCircleNum - 1
		if Acceleration > 0.2 then
			Wnd.RotationAngle = Wnd.RotationAngle - 360
		else
			Wnd.RotationAcceleration = uAcceleration
			Wnd.NeedRotationCircleNum = 1
			UnRegisterTick( Wnd.AnthorTimer )
			Wnd.AnthorTimer = nil
			if Wnd.stoneName~= "ʧ��" then
				Wnd:RetWhiteStoneAppraise(Wnd.stoneBigID,Wnd.stoneName,Wnd.stoneID)
			else
				Wnd.ClickNumber = 1
				--Wnd.m_MsgBox  = MessageBox( Wnd, MsgBoxMsg(3014), MB_BtnOK )
			end
			Wnd.OK:EnableWnd(true)
			Wnd.RotationAngle = 0
			SetEvent( Event.Test.RetTakeAppraisedStone,true,flag)
			return
		end
	end
	
	if Acceleration <= 0.2 then
		Acceleration = 0.2
	end
	Wnd.RotationAngle = Wnd.RotationAngle + Acceleration
	Wnd.pointer:SetRotation( Wnd.RotationAngle*3.1415926/180 )
end

--���������ֹͣ��λ��
function CWhiteStone:ClickStopButton( ID )
	self.ClickNumber = 1
	local stop_index = ID 
	UnRegisterTick( self.ontimer )
	self.ontimer = nil
	---ID�Ǵ�0 ��ʼ�� 15 ����
	local index
	--�õ�ת��Բ��Ȧ��
	local CircleNumber = math.floor(self.RotationAngle/360)
	--�õ���������ڻ���
	local CurrNumber  = self.RotationAngle - CircleNumber*360
	--�õ���ǰ��index
	if ( CurrNumber >345 or CurrNumber < 15 ) then
		index = 0
	else
		index = math.floor((CurrNumber + 15 )/30)						
	end
	self.OK:EnableWnd(false)
	--�õ���Ҫת���Ŀ̶�
	if index <= stop_index then
		local RotationAngle = (stop_index - index)*30
		self.StopRotation = self.RotationAngle + RotationAngle
		self.StopRotation = (math.floor((self.StopRotation + 15) / 30) )* 30
		self.AnthorTimer = RegisterTick("OtherRotation", OtherRotation, 2)
	elseif index > stop_index then			
		local RotationAngle = 360 - (index - stop_index)*30
		self.StopRotation = self.RotationAngle + RotationAngle
		self.StopRotation = (math.floor((self.StopRotation + 15) / 30) )* 30
		self.AnthorTimer = RegisterTick("OtherRotation", OtherRotation, 2)
	end

end

function CWhiteStone:UseWhiteStone(nBigID, nSmallID, nRoomIndex, nPos, eEquipPart )
	--���ðױ�ʯ
	if( #(self.ToStoneID) ~= 0 )then
		MessageBox( g_GameMain, MsgBoxMsg(3007), MB_BtnOK )
		return
	end
	self.ClickNumber = 1
	Gac2Gas:UseItem(g_Conn,nRoomIndex,nPos,nBigID, nSmallID,eEquipPart)
	g_WndMouse:ClearCursorAll()
end

--���ݱ�ʯ�����Ƶõ���ʯ��λ��
local function GetPositionByName(stoneName)
	local WhiteStone = CWhiteStone.GetWnd()
	for i=1,# WhiteStone.tbl_New_StoneName do
		if WhiteStone.tbl_New_StoneName[i][2] == stoneName then
			return i - 1
		end
	end
	return 0
end
-- RCP ʵ�ֹ���  --
function CWhiteStone:RetWhiteStoneAppraise(stoneBigID, stoneName, stoneID, nTimes)
	if nTimes == 1 then--��һ�μ�������ֹͣ 
		self.position = GetPositionByName(stoneName)
		if stoneBigID == 0 then
			return
		end
		table.insert(self.ToStoneID,stoneID)
		g_LoadIconFromRes(g_ItemInfoMgr:GetItemInfo( tonumber(stoneBigID) , stoneName,"SmallIcon" ), self.ToStone, -1, IP_ENABLE, IP_ENABLE)
		g_SetItemRichToolTips(self.ToStone,stoneBigID, stoneName, 0)
		self.HighStoneName:SetWndText(stoneName)
		self.stoneBigID = stoneBigID
		self.stoneName = stoneName
		self.stoneID = stoneID
		local RotationAngle = (self.position - 0)*30
		self.StopRotation = self.RotationAngle + RotationAngle
		self.StopRotation = (math.floor((self.StopRotation + 15) / 30) )* 30
		self.pointer:SetRotation( self.StopRotation*3.1415926/180 )
		self.m_JiandingBtn:EnableWnd(true)
		--self:ClickStopButton(self.position)	
	elseif nTimes == 2 then --�ڶ��μ���,�ȴ�10s,��ȴ���Ұ���ֹͣ��ť
		self.ClickNumber = 2 
		self.m_JiandingBtn:EnableWnd(true)
		--self.position = math.random(0,15)
		self.stoneBigID = stoneBigID
		self.stoneName = stoneName
		self.stoneID = stoneID
		self.position = GetPositionByName(stoneName)
		SetEvent( Event.Test.RetTakeAppraisedStone,true,true)
	else -- ����ֹͣ��,�ܿ�ͻ�ͣ
		--self.position = GetPositionByName(stoneName)
		if stoneBigID == 0 then
			return
		end
		self.ToStoneID = {} --�ڶ��μ�����, ��һ�εĽ��Ӧ�����
		table.insert(self.ToStoneID,stoneID)
		g_DelWndImage(self.ToStone, 1, IP_ENABLE, IP_ENABLE)
		self.ToStone:SetMouseOverDescAfter("")
		g_LoadIconFromRes(g_ItemInfoMgr:GetItemInfo( tonumber(stoneBigID) , stoneName,"SmallIcon" ), self.ToStone, -1, IP_ENABLE, IP_ENABLE)
		self.HighStoneName:SetWndText(stoneName)
		g_SetItemRichToolTips(self.ToStone,stoneBigID, stoneName, 0)
	end
	if not self:IsShow() then
		self:ShowWnd(true)
	end
end

function CWhiteStone:DrawAllStoneItem()
	local tbl_new = self.tbl_New_StoneName
	self.tbl_New_StoneName = {}
	for n = 1, 12 do
		local r = math.random(#(tbl_new))
		table.insert(self.tbl_New_StoneName, tbl_new[r])
		table.remove(tbl_new,r)
	end

	local posString = {"1","2","3","4","5","6","7","8","9","10","11","12"}
	for i=1,# (posString) do
		local SmallIcon = g_ItemInfoMgr:GetItemInfo( tonumber(self.tbl_New_StoneName[i][1]) , self.tbl_New_StoneName[i][2],"SmallIcon" )
		g_LoadIconFromRes(SmallIcon, self:GetDlgChild("Child" .. posString[i]), -1, IP_ENABLE, IP_ENABLE)
		g_SetItemRichToolTips(self,tonumber(self.tbl_New_StoneName[i][1]) , self.tbl_New_StoneName[i][2], 0)
	end
end

function CWhiteStone:RetWhiteStoneAppraiseFirstTime(stoneBigID,stoneName)
	table.insert(self.tbl_New_StoneName, {stoneBigID,stoneName})
	if #(self.tbl_New_StoneName) >12 then
--		print("�ױ�ʯ�����������, tbl_New_StoneName��ĳ��û�б����!")
		return
	elseif #(self.tbl_New_StoneName) == 12 then
		self:DrawAllStoneItem()
	end
end

function CWhiteStone:RetTakeAppraisedStone(flag)
	if(flag ==true) then
		self.tbl_New_StoneName = {}
		self.ToStoneID ={}
		g_DelWndImage(self.ToStone, 1, IP_ENABLE, IP_ENABLE)
		self.HighStoneName:SetWndText("")
		self.ToStone:SetMouseOverDescAfter("")
		self.pointer:SetRotation(0)
		local posString = {"1","2","3","4","5","6","7","8","9","10","11","12"}
		for i=1,# (posString) do
			g_DelWndImage(self:GetDlgChild("Child" .. posString[i]), 1, IP_ENABLE, IP_ENABLE)
			self:GetDlgChild("Child" .. posString[i]):SetMouseOverDescAfter("")
		end
		self:ShowWnd(false)
	end
	SetEvent( Event.Test.RetTakeAppraisedStone,true,flag)
end
