gac_require "test/common/CTstLoginControlerInc"
cfg_load "player/NewRoleClassModle_Client"

local assert = _G.assert

CTstLoginControler.s_WaitTime = nil

function CTstLoginControler:SetWaitTime( time )
	assert( type(time) == "number"  )
	CTstLoginControler.s_WaitTime = time
end

function CTstLoginControler.__WaitEvent( b, time, queue )
	local t = time or CTstLoginControler.s_WaitTime
	local r = WaitEvent( true, t, queue )
	SetEvent(queue,false)
	return r
end

--------------------------------	��½���ʺź��������룩		------------------------------
function CTstLoginControler:Login( Account, Password )

	local slp = CSleep:new()
	slp:Sleep(1,"lst")
		
	local login_state = g_Login
	--������뿪ʼ���¼�
	SetEvent(Event.Test.LoginBegan,false)

	
	assert( g_App.m_re == EGameState.eToLogin )
	
	local Wnd_Account = login_state.m_LoginAccounts:GetDlgChild( "Edit_UserName" ) 
	Wnd_Account:SetWndText( Account )
		
	local Wnd_Password = SQREdit, login_state.m_LoginAccounts:GetDlgChild( "Edit_Password" )
	Wnd_Password:SetWndText(Password)
	login_state.m_LoginAccounts.m_editPassword:SetWndText(Password)
	login_state.m_LoginAccounts:OnCtrlmsg(login_state.m_LoginAccounts:GetDlgChild( "Btn_OK" ),BUTTON_LCLICK,0,0)
	
	local r_tbl = CTstLoginControler.__WaitEvent( true, nil, Event.Test.LoginEnded)
	assert( r_tbl[1] == EEventState.Success )
  	if( g_App.m_re == EGameState.eToAgreement ) then
	   	g_UserAgreement.m_UserAgreementWnd:OnCtrlmsg(g_UserAgreement.m_UserAgreementWnd:GetDlgChild( "Btn_Agree" ),BUTTON_LCLICK,0,0)	
	  end
		
	local r_tbl = CTstLoginControler.__WaitEvent( true, nil, Event.Test.CharListReceived )
	assert( r_tbl[1] == EEventState.Success )
	assert( g_App.m_re == EGameState.eToSelectChar )
end

--------------------------------	��ɫѡ��ͽ�ɫ����		------------------------------
function CTstLoginControler:Back2Login()
	assert( g_App.m_re == EGameState.eToSelectChar )

	local wnd_sc = g_SelectChar.m_SelectCharWnd
	assert( wnd_sc )
	wnd_sc:OnCtrlmsg(wnd_sc:GetDlgChild( "Btn_Back" ),BUTTON_LCLICK,0,0)
	
	local r_tbl = CTstLoginControler.__WaitEvent( true, nil, Event.Test.LoginBegan )
	
	assert( r_tbl[1] == EEventState.Success )
	assert( g_App.m_re == EGameState.eToLogin )
end

function CTstLoginControler:GotoCreateCharacter()
	assert( g_App.m_re == EGameState.eToSelectChar )

	local wnd_select = g_SelectChar.m_SelectCharWnd
	wnd_select:OnCtrlmsg( wnd_select:GetDlgChild( "AiMiNewRole" ), BUTTON_LCLICK, 0, 0 )
	assert( EGameState.eToNewRoleGameMain == g_App.m_re )
end

function CTstLoginControler:GoToInputNewRoleInfo()
	self:GotoCreateCharacter()
	local r_tbl2 = CTstLoginControler.__WaitEvent( true, nil, Event.Test.FinishedLoading )
	assert( r_tbl2[1] == EEventState.Success )
	SetEvent(Event.Test.FinishedLoading, false)
	
	local wnd_cr = g_GameMain.m_NewRole
	assert( # wnd_cr.performersTbl ~= 0 )	--����ְҵģ�͵ı�Ϊ��
	local xpos = NewRoleClassModle_Client(tostring(1),"XPos")
	local ypos = NewRoleClassModle_Client(tostring(1),"YPos")	--ģ���ڳ����е�λ��
	wnd_cr:ShowNewRoleDescWnd(wnd_cr.performersTbl[1], 1)		--ģ��ѡ�г����е�һ��������ְҵģ��	

	local r_tbl_create = CTstLoginControler.__WaitEvent( true, nil, Event.Test.AfterMoveCameraTick )
	assert( r_tbl_create[1] == EEventState.Success )
	SetEvent(Event.Test.AfterMoveCameraTick, false)
end

--������������ɫ�������׶Σ�selelctClass��inputNewRoleInfo��ֵ�ֱ�Ϊ1��2��
function CTstLoginControler:CC2SC_Cancel(newRoleStep)
	assert( g_App.m_re == EGameState.eToNewRoleGameMain )
	
	local wnd_cr = g_GameMain.m_NewRole
	if newRoleStep == 1 then
		wnd_cr:OnCtrlmsg( wnd_cr:GetDlgChild( "BackToSelectCamp" ), BUTTON_LCLICK, 0, 0 )
	elseif newRoleStep == 2 then
		wnd_cr:OnCtrlmsg( wnd_cr:GetDlgChild( "Btn_Back" ), BUTTON_LCLICK, 0, 0 )
		wnd_cr:OnCtrlmsg( wnd_cr:GetDlgChild( "BackToSelectCamp" ), BUTTON_LCLICK, 0, 0 )
	end
	local r_tbl = CTstLoginControler.__WaitEvent( true, nil, Event.Test.CharListReceived )
	assert( r_tbl[1] == EEventState.Success )
	assert( g_App.m_re == EGameState.eToSelectChar )
end

function CTstLoginControler:EnterGame()
	assert( g_App.m_re == EGameState.eToSelectChar )
	
	SetEvent(Event.Test.GasCreatePlayerEnded,false)
	SetEvent(Event.Test.EnterGame,false)
	
	local wnd_select = g_SelectChar.m_SelectCharWnd
	local btn_enter_game = wnd_select:GetDlgChild( "Btn_EnterGame" )
	
	assert( self:GetCharacterNum() ~= 0 )
	wnd_select:OnCtrlmsg(wnd_select:GetDlgChild( "Btn_EnterGame" ),BUTTON_LCLICK,0,0 )
	
	local r_tbl_enter_game = 
		CTstLoginControler.__WaitEvent( true, nil, Event.Test.EnterGame )
	assert( r_tbl_enter_game[1] == EEventState.Success )
	assert( g_App.m_re == EGameState.eToGameMain )
	
	local r_load = CTstLoginControler.__WaitEvent( true, nil, Event.Test.GasCreatePlayerEnded )
	assert( r_load[1] == EEventState.Success )
end

--�ӵ������ֱ�ӽ�����Ϸ
function CTstLoginControler:OneStepLogin()
	local strName = "test_cd23"
	self:Login( "test_cd", "134" )
	if( self:HasCharacter(strName) ) then
			self:DelCharacter( strName )
	end
	self:CreateCharacter( strName)
end

function CTstLoginControler:OneStepLoginEx( account, char_name )
	self:Login( account, "134" )
	if( self:HasCharacter(char_name) ) then
			self:DelCharacter( char_name )
	end
	self:CreateCharacter( char_name)
end


function CTstLoginControler:OneStepReLoginEx( account, char_name )
	self:Login( account, "134" )
	if( not self:HasCharacter(char_name) ) then
		self:CreateCharacter( char_name)
	end
end

--����Ϸ��ֱ�ӵǳ�
function CTstLoginControler:LoginOutFromGame()
	assert( g_App.m_re == EGameState.eToGameMain or  g_App.m_re == EGameState.eToNewRoleGameMain)

	local wnd_eg = g_GameMain.m_ExitGame
	
	wnd_eg:OnCtrlmsg(wnd_eg:GetDlgChild( "ReturnLogin" ),BUTTON_LCLICK,0,0)
	
	local r_tbl = CTstLoginControler.__WaitEvent( true, nil, Event.Test.LoginBegan )
	
	assert( r_tbl[1] == EEventState.Success )
	assert( g_App.m_re == EGameState.eToLogin )
end

--����Ϸ�з��ص���ɫѡ�����
function CTstLoginControler:BackToSelectRole()
	local wnd_eg = g_GameMain.m_ExitGame
	SetEvent(Event.Test.SelectRoleState, false)
	wnd_eg:OnCtrlmsg(wnd_eg:GetDlgChild( "ReturnSelRole" ),BUTTON_LCLICK,0,0)
	
	local r_tbl = CTstLoginControler.__WaitEvent( true, nil, Event.Test.SelectRoleState )
	SetEvent(Event.Test.SelectRoleState, false)
	assert( r_tbl[1] == EEventState.Success )
	assert( g_App.m_re == EGameState.eToSelectChar )
end

--ʧ�ܵĻ�����arg(...)Ϊ��������errhander
function CTstLoginControler:CreateCharacter( name )
	assert( type(name) == "string" )
		
	assert( g_App.m_re == EGameState.eToSelectChar )
	
	self:GotoCreateCharacter()
	local r_tbl2 = CTstLoginControler.__WaitEvent( true, nil, Event.Test.FinishedLoading )
	assert( r_tbl2[1] == EEventState.Success )
	SetEvent(Event.Test.FinishedLoading, false)

	--create character
	local wnd_cr = g_GameMain.m_NewRole
	SetEvent(Event.Test.AfterMoveCameraTick, false)
	
	assert( # wnd_cr.performersTbl ~= 0 )	--����ְҵģ�͵ı�Ϊ��
	local xpos = SceneMapDifCamp_Common(g_Conn.m_NewRoleCampInfo, "InitCameraX") * 64 
	local ypos = SceneMapDifCamp_Common(g_Conn.m_NewRoleCampInfo, "InitCameraY") * 64	--ģ���ڳ����е�λ��
	wnd_cr:ShowNewRoleDescWnd(wnd_cr.performersTbl[1], 1)		--ģ��ѡ�г����е�һ��������ְҵģ��
	
	
	local r_tbl_create = CTstLoginControler.__WaitEvent( true, nil, Event.Test.AfterMoveCameraTick )
	assert( r_tbl_create[1] == EEventState.Success )
	SetEvent(Event.Test.AfterMoveCameraTick, false)
	
	wnd_cr:GetDlgChild( "Edit_Name" ):SetWndText( name )
	wnd_cr:OnCtrlmsg( wnd_cr:GetDlgChild( "Btn_OK" ), BUTTON_LCLICK, 0, 0 )
	
	local r_tbl_create = CTstLoginControler.__WaitEvent( true, nil, Event.Test.CreateCharEnded )
	assert( r_tbl_create[1] == EEventState.Success )
	assert( r_tbl_create[2][1] == "Success" )
	SetEvent(Event.Test.CreateCharEnded, false)
	
	local r_tbl_create = CTstLoginControler.__WaitEvent( true, nil, Event.Test.ObjectCreated )
	assert( r_tbl_create[1] == EEventState.Success )
	SetEvent(Event.Test.ObjectCreated, false)
end

function CTstLoginControler:CreateManyRoles(name)
	self:CreateCharacter(name)
	self:BackToSelectRole()
end

--index �� 1 ��ʼ
function CTstLoginControler:__SelCharByNum( index )
	--assert( type(index) == "number" )
	assert( g_App.m_re == EGameState.eToSelectChar )
	local wnd_select = g_SelectChar.m_SelectCharWnd
	local str = "AiMiPlayer_"
	local wnd_roles_info = wnd_select:GetDlgChild( str .. index )
	
	wnd_select:OnCtrlmsg(wnd_roles_info, BUTTON_LCLICK, 0, 0)
end

function CTstLoginControler:__SelCharByName( name )
	--assert( type(name) == "string" )
	--assert( g_App.m_re == EGameState.eToSelectChar )
	
	for i, v in ipairs(g_SelectChar.m_tblRolesInfo.m_tblPlayerListGroupByActive) do
		local roles = v
		assert( roles )

		local index
		for i=1, #roles do
			if name == roles[i].m_name then
				index = i
				break
			end
		end
	end
		
	assert( index ~= -1 )
	self:__SelCharByNum( index )
end

--param: name or index( begin at 1, not 0)
function CTstLoginControler:SelectCharacter( param )
	if( type(param) == "string" ) then
		self:__SelCharByName( param )
	elseif( type(param) == "number" )then
		self:__SelCharByNum( param )
	end
end

--param: name or index( begin at 1, not 0)
function CTstLoginControler:DelCharacter( param )
	self:SelectCharacter( param )
		
	local wnd_select = g_SelectChar.m_SelectCharWnd

	wnd_select:OnCtrlmsg( wnd_select:GetDlgChild( "Btn_DelRole" ), BUTTON_LCLICK, 0, 0 )
		
	local wnd_del = g_SelectChar.m_SelectCharWnd.m_wndDelRole
	
	--������ȷ����֤���
  wnd_del:GetDlgChild("Input_VarifyWord"):SetWndText("yes")
	wnd_del:OnCtrlmsg( wnd_del:GetDlgChild( "Btn_Ok" ), BUTTON_LCLICK, 0, 0 )

	
	local r_tbl = CTstLoginControler.__WaitEvent( true, nil, Event.Test.DeleteCharEnded )

	assert( r_tbl[1] == EEventState.Success )
	
     
	local r_tbl2 = CTstLoginControler.__WaitEvent( true, nil, Event.Test.CharListReceived )
	assert( r_tbl2[1] == EEventState.Success )
end

--���Իָ���ɫʱ,���ܳ���ɾ��
function CTstLoginControler:DelGetBackCharacter( param )
	self:SelectCharacter( param )
	Gac2Gas:DelChar( g_SelectChar.GetConnetion(), g_SelectChar.m_tblRolesInfo.m_tblPlayerListGroupByActive[param].m_id )
	
	local r_tbl = CTstLoginControler.__WaitEvent( true, nil, Event.Test.DeleteCharEnded )
	assert( r_tbl[1] == EEventState.Success )
end

function CTstLoginControler:GetCharacterNum()
	assert( g_App.m_re == EGameState.eToSelectChar )
	
	local ret = 0
	for i, v in ipairs(g_SelectChar.m_tblRolesInfo.m_tblPlayerListGroupByActive) do
		local roles = v
		assert( roles )
		assert( type(roles) == "table" )
		ret = ret + #roles
	end
	
	return ret
end

function CTstLoginControler:HasCharacter( name )
	assert( type(name) == "string" )
	assert( g_App.m_re == EGameState.eToSelectChar )
	
	for i, w in ipairs(g_SelectChar.m_tblRolesInfo.m_tblPlayerListGroupByActive) do
		for _,v in pairs( w ) do
			if name == v.m_name then
				return true
			end
		end
	end
		
	return false
end

function CTstLoginControler:CheckHasNamAfterCreateRole( account, password, name )
	self:LoginOutFromGame()
	self:Login(account, password)
	assert( type(name) == "string" )
	assert( g_App.m_re == EGameState.eToSelectChar )
	
	for i, w in ipairs(g_SelectChar.m_tblRolesInfo.m_tblPlayerListGroupByActive) do
		for _,v in pairs( w ) do
			if name == v.m_name then
				return true
			end
		end
	end
		
	return false
end

function CTstLoginControler:DisConnect()
	SetEvent( Event.Test.LoginBegan, false )		--clear event
	g_Conn:ShutDown()
	
	local slp = CSleep:new()
	slp:Sleep(1, "ldst")
	
	--IScriptConnMgrClientHandler.OnDisconnect( nil, nil, nil )
	
	local r_tbl = CTstLoginControler.__WaitEvent( true, nil, Event.Test.LoginBegan )
	assert( r_tbl[1] == EEventState.Success )
	assert( g_App.m_re == EGameState.eToLogin )
	
	assert( g_App.m_MsgBox )
	local wnd = g_App.m_MsgBox:GetDlgChild("BtnOK")
	assert( wnd )
	
	assert( getmetatable(wnd) ~= nil )
	wnd:SendMsg( WM_LBUTTONDOWN, 0, 0 )
	wnd:SendMsg( WM_LBUTTONUP, 0, 0 )

	assert( getmetatable(wnd) == nil )
end


