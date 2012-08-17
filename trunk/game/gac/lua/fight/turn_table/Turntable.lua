gac_require "fight/turn_table/TurntableInc"
gac_require "fight/turn_table/TurntableHelp"
gac_gas_require "item/Equip/EquipCommonFunc"

function turntableCreate( Parent )
	local Wnd=turntableWnd:new()
	Wnd:CreateFromRes( "Wndturntable", Parent )
	Wnd.BtnBegin = Wnd:GetDlgChild( "CtrlButton" )
	Wnd.BtnOk      = Wnd:GetDlgChild( "BtnOk" )
	Wnd.help         = Wnd:GetDlgChild( "BtnHelp" )
	Wnd.pointer    = Wnd:GetDlgChild( "pointer" )
	Wnd.result1    = Wnd:GetDlgChild("result1")
	Wnd.result2    = Wnd:GetDlgChild("result2")
	Wnd.max = {}
	Wnd.min = {}
	Wnd.helpWnd = nil
	local name
	local value = 0
	for i = 1, 10 do
		value = 0
		name = "max"..i
		value = Wnd:GetDlgChild( name )
		table.insert(Wnd.max, value)
		name = "min"..i
		value = 0
		value = Wnd:GetDlgChild( name )
		Wnd:GetDlgChild( name ):ShowWnd(false)
		table.insert(Wnd.min, value)			
	end
	
	--�ҵ�ontimer����
	Wnd.ontimer = nil
	
	--��ת�˶��ٴ�
	Wnd.RotationNum  = 0
	
	--��ת�Ķ���
	Wnd.RotationAngle = 0
	
	--���ٴμ�һ���̶�
	Wnd.RotationStep = 5
	--ǿ���Ĵ���
	Wnd.IntensifyNumber = 1
	--��������ת�������⻷
	Wnd.IntensifyAttr = true
	
	Wnd.SetDisEnable = 0
	Wnd.BtnOk:EnableWnd(false)

	return Wnd
end 

--���û�������ʱ10���Զ�ֹͣ
local function Rotation()
	local Wnd = g_GameMain.m_turntable
	if( Wnd.RotationNum >=  10008) then		
			UnRegisterTick( Wnd.ontimer )
			Wnd.ontimer = nil
			Wnd.RotationStep = 20
			Wnd.BtnBegin:EnableWnd(false)
			return 
	end
	Wnd.RotationAngle = Wnd.RotationAngle + 1
	Wnd.pointer:SetRotation( Wnd.RotationAngle*3.1415926/180 )
end

--���û�����ֹͣ��ťʱ
local function OtherRotation()
	local Wnd = g_GameMain.m_turntable
	if(Wnd.RotationAngle >= Wnd.StopRotation) then
		--------------------���Դ���--------------------
		--local CircleNumber = math.floor(Wnd.RotationAngle/360)
		--local CurrNumber  = Wnd.RotationAngle - CircleNumber*360
		local CurrNumber = Wnd.RotationAngle % 360
--		print("����һȦ�Ķ���" .. CurrNumber)
--		print("�����ڵؼ�����������" .. math.floor((CurrNumber + 18) / 36))
--		print("Ӧ��ͣ��ʲô�ط�" .. (Wnd.StopRotation  % 360))
		-------------------------------------------
		UnRegisterTick( Wnd.AnthorTimer )
		Wnd.AnthorTimer = nil 
		if Wnd.IntensifyNumber == 1 then
			if Wnd.IntensifyAttr == false then
				Wnd.BtnBegin:SetWndText(GetStaticTextClient(1068))
				Wnd.IntensifyAttr = true
				Wnd.BtnBegin:EnableWnd(false)
			else
				Wnd.BtnBegin:SetWndText(GetStaticTextClient(1068))
				Wnd.BtnBegin:EnableWnd(true)
				Wnd.IntensifyAttr = false
			end
			return 
		elseif Wnd.IntensifyNumber == 2 then
			if Wnd.IntensifyAttr == false then
				Wnd.BtnBegin:EnableWnd(false)
			else
				Wnd.BtnBegin:SetWndText(GetStaticTextClient(1068))
				Wnd.BtnBegin:EnableWnd(true)
				Wnd.IntensifyAttr = false			
			end	
			return	
		end
	end
	Wnd.BtnBegin:EnableWnd(false)
	Wnd.RotationAngle = Wnd.RotationAngle + 1
	Wnd.pointer:SetRotation( Wnd.RotationAngle*3.1415926/180 )	
end

--����ֹͣ��ť�ȴ�һ����
local function SetDisEnable()
	local Wnd = g_GameMain.m_turntable
--	print(Wnd.SetDisEnable)
	Wnd.SetDisEnable = Wnd.SetDisEnable + 500
	if Wnd.SetDisEnable == 1000 then
		UnRegisterTick( Wnd.SetDisEnableTimer )
		Wnd.AnthorTimer = nil 
		Wnd.SetDisEnable = 0
		Wnd.BtnBegin:EnableWnd(true)	 			
	end
end

--��Ӧ����¼�
function turntableWnd:OnCtrlmsg( Child, uMsgID, uParam1, uParam2 )
	if( uMsgID == BUTTON_LCLICK ) then
		if( Child == self.help ) then
			if( nil == self.helpWnd ) then
				self.helpWnd = turntableWnd:new()
				self.helpWnd = createturntableHelpWnd( self )
				self.helpWnd:ShowWnd( true )
				local rt     = CFRect:new() 
				local rtEx = CFRect:new() 
				self:GetWndRect( rt )
				self.helpWnd:GetWndRect( rtEx )

				local width  = rtEx.right - rtEx.left
				local height = rtEx.bottom - rtEx.top
			
				rtEx.top        = rt.top
				rtEx.bottom = rtEx.top + height
				rtEx.left         = rt.right
				rtEx.right       = rtEx.left + width		  
				self.helpWnd:SetWndRect( rtEx )
			else
				self.helpWnd:ShowWnd( false )
				self.helpWnd = nil 
			end
		elseif( Child == self.BtnBegin ) then
			if( nil == self.ontimer ) then
				if self.AnthorTimer == nil then
					if self.IntensifyNumber == 1 or self.IntensifyNumber then
						self.BtnBegin:EnableWnd(false)
						self.SetDisEnableTimer = RegisterTick("SetDisEnable", SetDisEnable, 500 )
						self.ontimer = RegisterTick("Rotation", Rotation, 1 ) 
						self.BtnBegin:SetWndText(GetStaticTextClient(1069))
					end
				end
			else 
				--��һ��ת����
				if self.IntensifyNumber == 1 then
					if self.IntensifyAttr == true then
						local AttrID = self.AttrID
						self:ClickStopButton(AttrID)
--						print("��һ�εĵ�һȦ")
						self:InitInnerData()
						
					else
						local AttrNumber = self.AttrNumber
						self:ClickStopButton(AttrNumber)
--						print("��һ�εĵڶ�Ȧ")
						self.BtnOk:EnableWnd(true)
					end
				--�ڶ���ת����
				elseif self.IntensifyNumber == 2 then
					if self.IntensifyAttr == true then
						local AttrID = self.AttrID 
						self:ClickStopButton(AttrID)
--						print("�ڶ��εĵ�һȦ")
						self:InitInnerData()
					else
						local AttrNumber = self.AttrNumber
						self:ClickStopButton(AttrNumber)
--						print("�ڶ��εĵڶ�Ȧ")
						self.BtnOk:EnableWnd(true)		
					end
				end

			end	
		elseif( Child == self.BtnOk ) then	
			if self.IntensifyNumber == 1 then
				self.pointer:SetRotation( 0 )
				self.BtnBegin:EnableWnd(true)
				self.BtnBegin:SetWndText(GetStaticTextClient(1068))
				self.IntensifyNumber = 2
				for i = 1,10 do
					self.min[i]:ShowWnd(false)	
				end
				self.BtnOk:EnableWnd(false)
			elseif self.IntensifyNumber == 2 then
				--ǿ����������� �������������Ϊ��ʼ�����
				local Wnd = g_GameMain.m_EquipUpIntensifyWnd
				local DynInfo = g_DynItemInfoMgr:GetDynItemInfo(self.ItemId)
				local AllNumber = GetIntensifyNeededSoul(DynInfo.BaseLevel)		
				Wnd.m_EquipIntensifyPro:SetRange( AllNumber )
				Wnd.m_EquipIntensifyPro:SetPos( 0 )
				Wnd.m_EquipIntensifyPro:SetWndText( DynInfo.ItensifySoul .. "/" .. AllNumber )				
				Wnd.immit_intensify = 0
				Wnd.m_EquipIntensifyBtn:EnableWnd( true )
				Wnd.m_EquipJookPanel:SetWndText(self.result1:GetWndText())
				Wnd.m_EquipHitPanel:SetWndText(self.result2:GetWndText())
				self:ShowWnd(false)
				self.pointer:SetRotation( 0 )
				self.BtnBegin:SetWndText(GetStaticTextClient(1068))
				self.BtnBegin:EnableWnd(true)
				for i = 1,10 do			
					self.min[i]:ShowWnd(false)
				end	
				self.ontimer = nil
				self.RotationNum  = 0
				self.RotationAngle = 0	
				self.IntensifyNumber = 1
				self.SetDisEnable = 0
				self.BtnOk:EnableWnd(false)	
				self.result2:SetWndText("")
				self.result1:SetWndText("")
				self.IntensifyAttr = true
				local nBigID,nIndex,nItemID = self.BTn.m_Info:GetBigID(),self.BTn.m_Info:GetIndex(),self.BTn.m_Info:GetItemID() 	
				g_SetItemRichToolTips(self.BTn.iconbtn,nBigID,nIndex,nItemID)
			end
		end
	end
end

--��ʼ����Ȧ����
function turntableWnd:InitInnerData()
end

--��ʼ����Ȧ�������ݺ���
function turntableWnd:InitData()
end

--���������ֹͣ��λ��
function turntableWnd:ClickStopButton( ID )
	local stop_index = ID - 1
--	print("Ӧ�����ĸ���������ֹͣ" .. stop_index)
	UnRegisterTick( self.ontimer )
	self.ontimer = nil
	---ID�Ǵ�0 ��ʼ�� 9 ����
	local index
	--�õ�ת��Բ��Ȧ��
	local CircleNumber = math.floor(self.RotationAngle/360)
	--�õ���������ڻ���
	local CurrNumber  = self.RotationAngle - CircleNumber*360
	--print(CurrNumber)
	--�õ���ǰ��index
	if ( CurrNumber >342 or CurrNumber < 18 ) then
		index = 0
	else
		index = math.floor((CurrNumber + 18 )/36)
		--index = index + 1							
	end
	--�õ���Ҫת���Ŀ̶�
	if index < stop_index then
		local RotationAngle = (stop_index - index)*36
		self.StopRotation = self.RotationAngle + RotationAngle
		self.StopRotation = (math.floor((self.StopRotation + 18) / 36) )* 36
		self.AnthorTimer = RegisterTick("OtherRotation", OtherRotation, 1 )
	elseif index > stop_index then			
		local RotationAngle = 360 - (index - stop_index)*36
		self.StopRotation = self.RotationAngle + RotationAngle
		self.StopRotation = (math.floor((self.StopRotation + 18) / 36) )* 36
		self.AnthorTimer = RegisterTick("OtherRotation", OtherRotation, 1 )
	end

end