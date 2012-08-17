cfg_load "player/CreateRoleGuide_Client"
lan_load "player/Lan_CreateRoleGuide_Client"

CNewRoleWnd     = class ( SQRDialog ) --��ϸ�Ĵ�����ɫ����
CMouseOverDescWnd = class(SQRDialog)
CAniHandler = class ( IModelHandler )

local MaxCameraDisInGameMain = 1408 --��Ϸ�е����������
local MinCameraDisInGameMain = 576
local MaxCameraDis = SceneMapDifCamp_Common(1, "MaxDist")*64		--��ɫ���������е����������
local MinCameraDis = SceneMapDifCamp_Common(1, "MinDist")*64
local InitCameraX = SceneMapDifCamp_Common(1, "InitCameraX") * 64	--���ֵ�Ǹ���SelectChar��g_App:GetCoreSceneMgr():RefreshCameraDest(speed, xpos, ypos)����
local InitCameraY = SceneMapDifCamp_Common(1, "InitCameraY") * 64
local TickRunTimes = 150		--tick�ܵĴ���
local TransparentTime = TickRunTimes * 10 --�������ֵ�ʱ��
local OffDistance = (MaxCameraDis - MinCameraDis)/TickRunTimes	--z��ÿ�μ���ƶ�����
local OffDistanceInGameMain = (MaxCameraDisInGameMain - MinCameraDisInGameMain)/TickRunTimes	--z��ÿ�μ���ƶ�����
local PerformerShowTime = TransparentTime * 2/3
local NewRoleInfoWndShowTime = TransparentTime * 1/3

local CreateRoleGuideModel = 12

--��ͷ�����Ĺ��̣�����ģ�ͣ���ʾ����
local function ShowPerformerFalseShowWndTrue(choosedPerformer, choosedPerformerNo)
	local wnd = g_NewRole.m_NewRoleWnd
	if wnd.m_FallCameraTickTimes <= TickRunTimes * 1/3 then
	    wnd:ShowPerformerFalseSlowly(choosedPerformer)
	end
	if wnd.m_FallCameraTickTimes == TickRunTimes * 2/3 then
	    wnd.m_BackToSelectCamp:SetTransparentObj(PerformerShowTime,true)
	end
	if wnd.m_ShowNewRoleInfoWnd ~= true then
		if wnd.m_FallCameraTickTimes >= TickRunTimes * 2/3 then
		    if wnd.m_nClass == CreateRoleGuideModel then
                g_NewRole.m_NewRoleGuidWnd = CNewRoleGuideWnd:new()
	            g_NewRole.m_NewRoleGuidWnd:ShowWnd(true)
	        else
    			wnd:ShowChild(true, true)
    			wnd.m_editName:SetWndText("")
    			wnd.m_editName:SetFocus()
    			wnd.m_ShowNewRoleInfoWnd = true
    	    end
		end
	end
end

local function MoveCamera(times, xpos, ypos, backOrNot, xyDirectioMove, enterGame)
    local CurMaxCameraDis = nil
    local CurOffDistance = nil
    if enterGame == true then
        CurMaxCameraDis = MaxCameraDisInGameMain
        CurOffDistance = OffDistanceInGameMain
    else
        CurMaxCameraDis = MaxCameraDis
        CurOffDistance = OffDistance 
    end
    local RenderScene
    if g_CoreScene ~= nil and IsCppBound (g_CoreScene) then
        RenderScene=g_CoreScene:GetRenderScene() 
	elseif g_GameMain.m_CoreScene and IsCppBound(g_GameMain.m_CoreScene) then
	    RenderScene=g_GameMain.m_CoreScene:GetRenderScene() 
    else
	    return
	end
	local CamOffset = nil
	local x = nil
	local y = nil

	if backOrNot == false then --����ͷ����
		CamOffset = CurMaxCameraDis - times * CurOffDistance
		x = (InitCameraX - xpos)/TickRunTimes * (TickRunTimes - times) + xpos
		y = (InitCameraY - ypos)/TickRunTimes * (TickRunTimes - times) + ypos
	else
		x = (InitCameraX - xpos)/TickRunTimes * times + xpos
		y = (InitCameraY - ypos)/TickRunTimes * times + ypos
		CamOffset = CurMaxCameraDis - (TickRunTimes - times) * CurOffDistance
	end
	--print("CamOffset" .. CamOffset)
	RenderScene:SetCameraOffset( CamOffset )
	if xyDirectioMove ~= true then
		RenderScene:SetCameraDest(  x, y )
	end
end

local function ShowPerformerTrueShowWndFalse()
	local wnd = g_NewRole.m_NewRoleWnd
	if wnd.m_ShowPerformerTrue ~= true and 
		wnd.m_RaiseCameraTickTimes < TickRunTimes * 1/3 then --ģ���Ѿ���ȫ��ʧ��������ʾģ��
		wnd:ShowChild(false, true)
		wnd.m_ShowPerformerTrue = true
	end
	if wnd.m_RaiseCameraTickTimes == TickRunTimes * 1/3 then 
		wnd.m_BackToSelectCamp:ShowWnd(true)
	    wnd.m_BackToSelectCamp:SetTransparent(0.1)
	    wnd.m_BackToSelectCamp:SetTransparentObj(PerformerShowTime, false)
	end
    wnd:ShowPerformerTrueSlowly()
end

function CAniHandler:OnAnimationEnd(actionName)
	 	self.renderObj:DoAni( "stand01_2", true, -1.0 )
end

function CAniHandler:BeSelected()
		RenderScene=g_CoreScene:GetRenderScene() 
		RenderScene:SetSelectedObj(self.renderObj)
end
	
function CNewRoleWnd:ChoosedClass(choosedClassNo)
    self.m_nClass = NewRoleClassModle_Client(choosedClassNo,"Class")
    if self.m_nClass == 3 then
        MessageBox(self, MsgBoxMsg(10001), MB_BtnOK)
        return  
    end
    if self.m_nClass ==10 or self.m_nClass == 11  then  --ѡ�е����ǻ��߾ư��ϰ���߻�����ʿ��������Ӧ
        return  
    end
    self.m_ChoosedPerformerNo = choosedClassNo
	self.m_ChoosedPerformer = self.m_PerformersTbl[choosedClassNo]
    if self.m_nClass == CreateRoleGuideModel then --���ɣ�ְҵ�ʴ�
	    --self:ShowNewRoleDescWnd()
	    return
    end
	self.m_nSex = NewRoleClassModle_Client(choosedClassNo,"Sex")
	local faceStr = "Face" .. g_Conn.m_NewRoleCampInfo
    local hairStr = "Hair" .. g_Conn.m_NewRoleCampInfo
	self.m_nFace = g_ParseCustomTblServer[NewRoleClassModle_Client(choosedClassNo,faceStr)]
	self.m_nHair = g_ParseCustomTblServer[NewRoleClassModle_Client(choosedClassNo,hairStr)]
	
	self:ShowNewRoleDescWnd()	
	local FxFileName= GetNewRoleFxName(self.m_nClass,self.m_nSex)
	
	local renderObj = self.m_ChoosedPerformer:GetRenderObject()
	SetDirection(renderObj, 160, false)
	renderObj:DoAni( "respond01", false, -1.0 )
	--ͬ����Чһ��Ҫ�ŵ��������沥��
	renderObj.m_EffectID =  renderObj:AddEffect(FxFileName,"respond01/create",0,nil)
	self:SetSelectClassRoleModelInfo()
	
	g_NewRole.m_ClassIntroVideo:LoadAndPause(self.m_nClass)
end

function CNewRoleWnd:IsSelectRenderObj()
	local rtRootWnd = CFRect:new()
	local posCursor = CFPos:new()
	g_App:GetRootWnd():GetCursorPos (posCursor)
	g_App:GetRootWnd():GetWndRect( rtRootWnd )
	local x = posCursor.x/rtRootWnd:Width()
	local y = posCursor.y/rtRootWnd:Height()
	if self.m_IsFallingCamera ~= true then	--���ѡ����ĳ��ְҵ�������ƽ�����ͷ������ְҵģ����Ч
		for i, v in pairs(self.m_PerformersTbl) do
			local renderObj = v:GetRenderObject()
			if g_CoreScene:GetRenderScene():IsSelectRenderObj(x, y, renderObj) == true then
				self:ChoosedClass(i)
				break
			end		
		end
	end
end

function CNewRoleWnd:IsDBLClickRenderObj()
	local rtRootWnd = CFRect:new()
	local posCursor = CFPos:new()
	g_App:GetRootWnd():GetCursorPos (posCursor)
	g_App:GetRootWnd():GetWndRect( rtRootWnd )
	local x = posCursor.x/rtRootWnd:Width()
	local y = posCursor.y/rtRootWnd:Height()
	if self.m_ChoosedPerformer == nil then
		return
	end
	local renderObj = self.m_ChoosedPerformer:GetRenderObject()
	if g_CoreScene:GetRenderScene():IsSelectRenderObj(x, y, renderObj) == true then
		self:OnOk()
	end
end

function CNewRoleWnd:ShowMouseOverDescWnd(mouseOverXPos, mouseOverYPos, choosedClassModleNo)	
	if self.m_MouseOverDescWnd == nil then
		self.m_MouseOverDescWnd= CMouseOverDescWnd:new()
		self.m_MouseOverDescWnd:CreateFromRes("ClassDescWnd", self)
		self.m_MouseOverDescWnd:ShowWnd( true )
		self.m_MouseOverDescChild = self.m_MouseOverDescWnd:GetDlgChild("ClassDesc")
	else
		self.m_MouseOverDescWnd:ShowWnd(true)
	end
	self.m_MouseOverDescWnd:ShowWnd(true)
	self.m_MouseOverDescWnd:SetTransparent(1)
	self.m_MouseOverDescWnd:SetTransparentObj(TransparentTime,false)
	local rect = CFRect:new()

	self.m_MouseOverDescChild:GetWndRect(rect)
	local rectWidth = rect.right - rect.left
	local rectHight = rect.bottom - rect.top
	rect.left = mouseOverXPos 
	rect.right= rect.left +	rectWidth
	rect.top = mouseOverYPos 
	rect.bottom = rect.top + rectHight
	
	
	local rtRootWnd = CFRect:new()
	g_App:GetRootWnd():GetWndRect( rtRootWnd )
	local rootWndBottom = rtRootWnd.bottom
	local rootWndRight = rtRootWnd.right
	
	if rect.bottom > rootWndBottom  then
		rect.bottom  = rootWndBottom
		rect.top = rect.bottom - rectHight
	end
	
	if rect.right > rootWndRight then
        rect.right = rootWndRight
        rect.left =  rect.right - rectWidth
	end
	local classDesc = Lan_NewRoleClassModle_Client(choosedClassModleNo, "ClassDesc")
	self.m_MouseOverDescChild:SetWndText(classDesc)
	self.m_MouseOverDescWnd:SetWndRect(rect)
	self.m_MouseOverDescChild:SetWndRect(rect)
end

function CNewRoleWnd:IsMouseMoveOnRenderObj()
	local rtRootWnd = CFRect:new()
	local posCursor = CFPos:new()
	g_App:GetRootWnd():GetCursorPos(posCursor)
	g_App:GetRootWnd():GetWndRect( rtRootWnd )
	
	local x = posCursor.x/rtRootWnd:Width()
	local y = posCursor.y/rtRootWnd:Height()

	local mouseOverRenderObj = false
	if self.m_IsFallingCamera == true or
	    self.m_IsRaisingCamera == true then
	    return 
	end
	for i, v in pairs(self.m_PerformersTbl) do
		local renderObj = v:GetRenderObject()
		if g_CoreScene:GetRenderScene():IsSelectRenderObj(x, y, renderObj) == true and 
		    renderObj:GetAlphaValue() > 0 and self.m_BackToSelectClass:IsShow() == false then
			self:ShowMouseOverDescWnd(posCursor.x, posCursor.y, i)
			mouseOverRenderObj = true
			break
		end		
	end
	if self.m_MouseOverDescWnd ~= nil and mouseOverRenderObj == false then
		self.m_MouseOverDescWnd:ShowWnd(false)
	end
end

function CNewRoleWnd:OnOk()
	self.m_HaveSendCreateRoleMsgToServer  = true
	local strRoleName = self.m_editName:GetWndText()
	local textFilter = CTextFilterMgr:new()
	local bType,strRet = textFilter:CheckRoleName(strRoleName)
	if bType == false then
		self.m_HaveSendCreateRoleMsgToServer = false
		MessageBox( self, MsgBoxMsg(strRet), MB_BtnOK )
	else
		local campInfo = g_Conn.m_NewRoleCampInfo
		Gac2Gas:CreateRole( g_Conn, strRoleName, self.m_nHair, self.m_nHairColor,
			self.m_nFace, self.m_nScale, self.m_nSex, self.m_nClass, campInfo,
			self.m_xPos, self.m_yPos )
	end
end

function CNewRoleWnd:RaiseCameraTickFunc()
	ShowPerformerTrueShowWndFalse()
	MoveCamera(self.m_RaiseCameraTickTimes, self.m_xPos*64, self.m_yPos*64, true)
	if self.m_RaiseCameraTickTimes == TickRunTimes then
		self.m_RaiseCameraTickTimes = nil
		self.m_IsRaisingCamera = false
		UnRegisterTick(self.m_RaiseCameraTick)
		self.m_RaiseCameraTick = nil
		return 
	end
	self.m_RaiseCameraTickTimes = self.m_RaiseCameraTickTimes + 1
end

--�Ҽ����ߵ������ְҵѡ��ťʱ�����³�ʼ�����ĵ�ְҵģ��
function CNewRoleWnd:ResetChoosedRenderObj()
    --self:SetRenderModelInfo(1,1,1,1)
	local faceStr = "Face" .. g_Conn.m_NewRoleCampInfo
	local hairStr = "Hair" .. g_Conn.m_NewRoleCampInfo
	local face = g_ParseCustomTblServer[NewRoleClassModle_Client(self.m_ChoosedPerformerNo,faceStr)]
	local hair = g_ParseCustomTblServer[NewRoleClassModle_Client(self.m_ChoosedPerformerNo,hairStr)]
	local renderObj = self.m_ChoosedPerformer:GetRenderObject()
	if renderObj.m_EffectID ~= nil then
		renderObj:DelEffect(renderObj.m_EffectID)
	end
	renderObj:SetAsynLoadPieceSwitch(false)
	self:OnSelectModel({face, hair}, performer,  self.m_nClass, self.m_nSex)
end

--����Ӫѡ��
function CNewRoleWnd:OnBackToSelectClass()
	g_NewRole.m_ClassIntroVideo:Pause()
	SQRWnd_UnRegisterHook( self.m_KeyHook )
	for i,v  in pairs (self.m_ClassBtnTbl) do
        local classBtn = v
        classBtn:ShowWnd(true)
        classBtn:SetTransparent(0.1)
        classBtn:SetTransparentObj(NewRoleInfoWndShowTime, false)
    end
	self:UnRegisterFallCameraTick()
	self:UnRegisterRaiseCameraTick()
	if self.m_nClass ~= CreateRoleGuideModel then
    	self:ResetChoosedRenderObj()
        local renderObj  = self.m_ChoosedPerformer:GetRenderObject()
    	local direction = NewRoleClassModle_Client(self.m_ChoosedPerformerNo,"Direction")
    	SetDirection(renderObj, direction, false)
    	renderObj:DoAni( "stand01", true, -1.0 )
    	renderObj:CheckEffect("fx/setting/other/other/brith/create.efx", "brith/create")
    end
	self.m_RaiseCameraTickTimes = 1
	if self.m_FallCameraTickTimes ~= nil and   --��ѡĳ��ְҵģ�ͺ󣬾�ͷ�����Ĺ����У��Ҽ�����ְҵѡ�񣬽���ͷ����
		self.m_FallCameraTickTimes > 1 then
        self.m_RaiseCameraTickTimes = TickRunTimes - self.m_FallCameraTickTimes
	end
	self.m_ShowPerformerTrue = false
	self.m_IsRaisingCamera = true
	self.m_RaiseCameraTick = RegClassTick("RaiseCameraTick", self.RaiseCameraTickFunc, 10, self)
end

--��ְҵѡ��
function CNewRoleWnd:OnBackToSelectCamp()
	if g_App.m_CurMusicName and g_App.m_CurMusicName ~= "" then
		StopCue(g_App.m_CurMusicName)
	end
    PlayCue("music24")
    g_App.m_CurMusicName = "music24"   
	self:UnRegisterFallCameraTick()
	self:UnRegisterRaiseCameraTick()     
	self:DestroyClassPerformer()
	SQRWnd_UnRegisterHook( self.m_KeyHook )
	g_CoreSceneMgr:DestroyMainScene() 
	coroutine.resume( g_App.MainRoutine, EGameState.eToSelectChar )
	CEffectLoader_Inst():Clear()
end

function CNewRoleWnd:OnCtrlmsg( Child, uMsgID, uParam1, uParam2 )
	if self.m_HaveSendCreateRoleMsgToServer  or self.m_IsFallingCamera or self.m_IsRaisingCamera or
	   g_App.m_CreateCharSuc  or  g_CoreScene == nil then
		return 
	end
	if( uMsgID == BUTTON_LCLICK ) then
		if( self.m_BackToSelectClass == Child ) then
		    if self.m_IsRaisingCamera ~= true then
			  	self:OnBackToSelectClass()
			end
		
		elseif( self.m_BackToSelectCamp == Child ) then
		    self.m_BackToSelectCamp:EnableWnd(false)
		    Gac2Gas:GetCampInfoByNum(g_Conn, 1)
		elseif( self.m_EnterGameInNewRole == Child ) then
			self:OnOk()
			
		elseif( self.m_btnStyleLeft == Child ) then
		    if self.m_wndSelectHairStyle:GetWndText() == self.m_DefaultText then
		        self.m_nHairStyleSelIdx = {1, 1}
		    end
			self:OnSelectHairStyle(1)
			
		elseif( self.m_btnStyleRight == Child ) then
            if self.m_wndSelectHairStyle:GetWndText() == self.m_DefaultText then
		        self.m_nHairStyleSelIdx = {1, 1}
		    end
			self:OnSelectHairStyle(2)
		
		elseif( self.m_btnColorLeft == Child ) then
            if self.m_wndSelectHairColor:GetWndText() == self.m_DefaultText then
		        self.m_nHairColorSelIdx = {1,1}
		    end
			self:OnSelectHairColor(1)
		
		elseif( self.m_btnColorRight == Child ) then
            if self.m_wndSelectHairColor:GetWndText() == self.m_DefaultText then
		        self.m_nHairColorSelIdx = {1, 1}
		    end
			self:OnSelectHairColor(2)
		
		elseif( self.m_btnFaceLeft == Child ) then
            if self.m_wndSelectFace:GetWndText() == self.m_DefaultText then
		        self.m_nFaceSelIdx = {1, 1}
		    end
			self:OnSelectFace(1)
		
		elseif( self.m_btnFaceRight == Child ) then
            if self.m_wndSelectFace:GetWndText() == self.m_DefaultText then
		        self.m_nFaceSelIdx = {1, 1}
		    end
			self:OnSelectFace(2)
	    else
	        self:OnClassChoosed(Child)			
        end 
    end
end

function CNewRoleWnd:OnClassChoosed(Child)	
	if ( g_CoreScene and 
	    g_NewRoleEnterGame.m_CurState ==  CNewRoleEnterGame.NewRoleEnterGameStateTbl["NewRole"] ) then 
		if ( self.m_BackToSelectCamp:IsShow() and
		     self.m_IsFallingCamera ~= true and
		     self.m_IsRaisingCamera ~= true ) then
            for i, v in pairs(self.m_ClassBtnTbl) do
                if v == Child then
                    local classNo = i
                    self:ChoosedClass(classNo)
                    break 
                end
            end
        end
    end
end

--�����������ǽ�����Ϸʱ����ɫ��Ϣ���ڽ�����ʧ����ʱ��
function CNewRoleWnd:ShowChild( showOrNot, drawStepByStep, showFalseTime)
	if ( drawStepByStep == true  and showOrNot == true) or drawStepByStep ~= true then
		self.m_BackToSelectClass:ShowWnd(showOrNot)
		self.m_EnterGameInNewRole:ShowWnd(showOrNot)
	
		self.m_editName:ShowWnd(showOrNot)

		self.m_btnColorLeft:ShowWnd(showOrNot)
		self.m_btnColorRight:ShowWnd(showOrNot)
		self.m_wndSelectHairColor:ShowWnd(showOrNot)
	
		self.m_btnFaceLeft:ShowWnd(showOrNot)
		self.m_btnFaceRight:ShowWnd(showOrNot)
		self.m_wndSelectFace:ShowWnd(showOrNot)

		self.m_wndRoleName:ShowWnd(showOrNot)
		
		self.m_wndHairColor:ShowWnd(showOrNot)
		self.m_wndFace:ShowWnd(showOrNot)
		self.m_RoleInfoDesc:ShowWnd(showOrNot)
		self.m_A001:ShowWnd(showOrNot)
		
		g_NewRole.m_ClassIntroVideo:ShowWnd(showOrNot)
		
		if self.m_nClass ~= 9 then --���������
            self.m_wndHairStyle:ShowWnd(showOrNot) 
            self.m_btnStyleLeft:ShowWnd(showOrNot)
		    self.m_btnStyleRight:ShowWnd(showOrNot) 
		    self.m_wndSelectHairStyle:ShowWnd(showOrNot)
		end
	end
	if drawStepByStep == true then
		local notShowWnd = not showOrNot
		if notShowWnd == false then
			self.m_BackToSelectClass:SetTransparent(0.1)
			self.m_EnterGameInNewRole:SetTransparent(0.1)
			self.m_editName:SetTransparent(0.1)
			self.m_btnColorLeft:SetTransparent(0.1)
			self.m_btnColorRight:SetTransparent(0.1)
			self.m_wndSelectHairColor:SetTransparent(0.1)
			self.m_btnFaceLeft:SetTransparent(0.1)	
			self.m_btnFaceRight:SetTransparent(0.1)
			self.m_wndSelectFace:SetTransparent(0.1)
			self.m_wndHairColor:SetTransparent(0.1)
			self.m_wndRoleName:SetTransparent(0.1)
			self.m_wndFace:SetTransparent(0.1)
			self.m_RoleInfoDesc:SetTransparent(0.1)
			self.m_A001:SetTransparent(0.1)
			
			g_NewRole.m_ClassIntroVideo:SetTransparent(0.1)
			
            if self.m_nClass ~= 9 then --���������
                self.m_wndHairStyle:SetTransparent(0.1)
                self.m_btnStyleLeft:SetTransparent(0.1)
    		    self.m_btnStyleRight:SetTransparent(0.1)
    		    self.m_wndSelectHairStyle:SetTransparent(0.1)
		    end
		end
		if showFalseTime ~= nil then
			showTime = showFalseTime
		else
			showTime = TransparentTime
		end
		self.m_BackToSelectClass:SetTransparentObj(showTime,notShowWnd)
		self.m_EnterGameInNewRole:SetTransparentObj(showTime,notShowWnd)
		self.m_editName:SetTransparentObj(showTime,notShowWnd)
		self.m_btnColorLeft:SetTransparentObj(showTime,notShowWnd)
		self.m_btnColorRight:SetTransparentObj(showTime,notShowWnd)
		self.m_wndSelectHairColor:SetTransparentObj(showTime,notShowWnd)
		self.m_btnFaceLeft:SetTransparentObj(showTime,notShowWnd)
		self.m_btnFaceRight:SetTransparentObj(showTime,notShowWnd)
		self.m_wndSelectFace:SetTransparentObj(showTime,notShowWnd)
		self.m_wndHairColor:SetTransparentObj(showTime,notShowWnd)
		self.m_wndRoleName:SetTransparentObj(showTime,notShowWnd)
		self.m_wndFace:SetTransparentObj(showTime,notShowWnd)
		self.m_RoleInfoDesc:SetTransparentObj(showTime,notShowWnd)
		self.m_A001:SetTransparentObj(showTime,notShowWnd)
		
		g_NewRole.m_ClassIntroVideo:SetTransparentObj(showTime,notShowWnd)
		
	    if self.m_nClass ~= 9 then --���������
            self.m_wndHairStyle:SetTransparentObj(showTime,notShowWnd)
            self.m_btnStyleLeft:SetTransparentObj(showTime,notShowWnd)
		    self.m_btnStyleRight:SetTransparentObj(showTime,notShowWnd)
		    self.m_wndSelectHairStyle:SetTransparentObj(showTime,notShowWnd)
	    end
	end
end

--����
function CNewRoleWnd:SetRenderModelText()
    local x = Lan_NewRoleProperty_Common(5, "DisplayName")
    self.m_wndSelectHairStyle:SetWndText(Lan_NewRoleProperty_Common(5, "DisplayName"))
	if(self.m_nSex == ECharSex.eCS_Male) then
		self.m_wndSelectHairColor:SetWndText(Lan_NewRoleProperty_Common(5, "DisplayName"))
	else
		self.m_wndSelectHairColor:SetWndText(Lan_NewRoleProperty_Common(5, "DisplayName"))
	end
	self.m_wndSelectFace:SetWndText(Lan_NewRoleProperty_Common(5 ,"DisplayName"))
end

--����ְҵģ�͵����͡����͡���ɫ����
function CNewRoleWnd:SetRenderModelInfo(hairStyleIndex1, hairStyleIndex2, faceIndex1, faceIndex2)
	self.m_nHairStyleSelIdx = {hairStyleIndex1, hairStyleIndex2}
	self.m_nHairColorSelIdx = {1, 1}	
	self.m_nFaceSelIdx = {faceIndex1, faceIndex2}
	self:SetRenderModelText()		
end

function CNewRoleWnd:InitChild()
	self.m_BackToSelectClass = self:GetDlgChild("Btn_Back")
	self.m_EnterGameInNewRole = self:GetDlgChild("Btn_OK")
	self.m_BackToSelectCamp = self:GetDlgChild("BackToSelectCamp")
	
	self.m_editName = self:GetDlgChild( "Edit_Name" )
	
	self.m_btnStyleLeft = self:GetDlgChild( "Btn_StyleLeft" ) 
	self.m_btnStyleRight = self:GetDlgChild( "Btn_StyleRight" ) 
	self.m_wndSelectHairStyle = self:GetDlgChild( "Wnd_SelectHairStyle" ) 
	
	self.m_btnColorLeft = self:GetDlgChild( "Btn_ColorLeft" )
	self.m_btnColorRight = self:GetDlgChild( "Btn_ColorRight" ) 
	self.m_wndSelectHairColor = self:GetDlgChild( "Wnd_SelectHairColor" ) 
	
	self.m_btnFaceLeft = self:GetDlgChild( "Btn_FaceLeft" ) 
	self.m_btnFaceRight = self:GetDlgChild( "Btn_FaceRight" ) 
	self.m_wndSelectFace = self:GetDlgChild( "Wnd_SelectFace" ) 
		
	self.m_wndRoleName = self:GetDlgChild( "Wnd_RoleName" ) 
	self.m_wndHairStyle = self:GetDlgChild( "Wnd_HairStyle" ) 
	self.m_wndHairColor = self:GetDlgChild( "Wnd_HairColor" ) 
	self.m_wndFace = self:GetDlgChild( "Wnd_Face" ) 
	self.m_RoleInfoDesc = self:GetDlgChild("RoleInfoDesc")
	self.m_A001 =   self:GetDlgChild("A001")
	
	--1 ��ʿ�� ��2 ħ��ʿ�� ��3 ������ʿ�С�4 ��ʦ�С�5 аħ�С�6 ��ʦ�С�7 ��ʿŮ��
	--8 ħ��ʿŮ��9 ������ʿŮ\10 ��ʦŮ��11 аħŮ ��12 ��ʦŮ��13����սʿ
	self.m_ClassBtnTbl = {}
	for i=1, 13 do
	    if i ~= 3 and i ~= 9 then --������ʿĿǰ��δ����
    	    local childStr = string.format("%s%d", "ClassBtn", i)
    	    local child = self:GetDlgChild(childStr) 
    	    self.m_ClassBtnTbl[i] = child
    	end
    end
	
	--self.m_HairStyle = {"ͷ��01", "ͷ��02", "ͷ��03", "ͷ��04", "ͷ��05", "ͷ��06", "ͷ��07", "ͷ��08", "ͷ��09", "ͷ��10"}
	self.m_HairStyle = {[1] = 21,[2] = 22,[3] = 23,[4] = 24,[5] = 25,[6] = 26,[7] = 27,[8] = 28}
	--self.m_ManHairColor = {"��ʿ��ɫ1", "��ʿ��ɫ2", "��ʿ��ɫ3", "��ʿ��ɫ4"}
	self.m_ManHairColor = {[1] = 51,[2] = 52,[3] = 53,[4] = 54,[5] = 55,[6] = 56}
	--self.m_WomanHairColor = {"Ůʿ��ɫ1", "Ůʿ��ɫ2", "Ůʿ��ɫ3", "Ůʿ��ɫ4"}
	self.m_WomanHairColor = {[1] = 71,[2] = 72,[3] = 73,[4] = 74,[5] = 75,[6] = 76}
	--self.m_Face = {"����01", "����02", "����03", "����04", "����05", "����06", "����07", "����08", "����09", "����10"}
	self.m_Face = {[1] = 91,[2] = 92,[3] = 93,[4] = 94,[5] = 95,[6] = 96,[7] = 97,[8] = 98}
	self.m_Body = {"��ı���1", "��ı���2", "��ı���3", "��ı���4"}
	self.m_BodyScale = {["��ı���1"]=50, ["��ı���2"]=100,["��ı���3"]=150, ["��ı���4"]=200}
    self:SetRenderModelInfo(1,1,1,1)

		--��ҽ�ɫ������
	self.m_nSex = ECharSex.eCS_Male --Ĭ��Ϊ����
	self.m_nHair = g_ParseCustomTblServer["ͷ��01"]
	self.m_nHairColor = 1 
	self.m_nFace = g_ParseCustomTblServer["����01"] 
	self.m_nScale = 100 
	self.m_nClass = EClass.eCL_Warrior --ְҵ
	self.m_nCamp = ECamp.eCamp_AmyEmpire --����
	self.m_nInherence = 1 --�츳
    
    self.m_wndHairStyle:ShowWnd(false) 
    self.m_btnStyleLeft:ShowWnd(false)
    self.m_btnStyleRight:ShowWnd(false) 
    self.m_wndSelectHairStyle:ShowWnd(false)
    
    self.m_DefaultText = Lan_NewRoleProperty_Common(5, "DisplayName")
end

local MaxPerformerNum = 16              --�ܹ�ģ�͸���
local NeedReactingPerformerNum = 13     --ǰ15��ģ����ְҵģ�ͣ������Ҫ��Ӧ�¼����������Ǿư��ϰ�ͻ�����ʿ���ǣ�����Ҫ��Ӧ�¼�

function CNewRoleWnd:CreateClassPerformer()
	local pos = CFPos:new()
 	self.m_PerformersTbl = {}
 	local ratio = EUnits.eGridSpanForObj
	for i=1, MaxPerformerNum do
		local campInfo = g_Conn.m_NewRoleCampInfo
		local xposStr = "XPos" .. campInfo
		local yposStr = "YPos" .. campInfo
		local faceStr = "Face" .. campInfo
		local hairStr = "Hair" .. campInfo
	    local class = NewRoleClassModle_Client(i,"Class")
 		pos.x = NewRoleClassModle_Client(i,xposStr)*ratio
 		pos.y = NewRoleClassModle_Client(i,yposStr)*ratio	
		local performer = g_CoreScene:CreateObjectPerformer(pos, nil)
		table.insert(self.m_PerformersTbl, performer)	
		local renderObj = performer:GetRenderObject()
		local direction = NewRoleClassModle_Client(i,"Direction")
        renderObj:SetDirection(CDir:new(direction))
        renderObj:SetRenderStyle(0x00A)
		if i > NeedReactingPerformerNum then
		    local modelName = NewRoleClassModle_Client(i,"Face1")
		    local aniName = NewRoleClassModle_Client(i,"Hair1")
		    InitRenderNpc(renderObj, modelName, 1 )
		    renderObj:DoAni( aniName, true, -1.0 )
		else			
        	local uSex = NewRoleClassModle_Client(i,"Sex")
        	local face = g_ParseCustomTblServer[NewRoleClassModle_Client(i,faceStr)]
        	local hair = g_ParseCustomTblServer[NewRoleClassModle_Client(i,hairStr)]
        	renderObj:SetAsynLoadPieceSwitch(false)
        	self:OnSelectModel({face, hair}, performer, class, uSex)
        	renderObj:DoAni( "stand01", true, -1.0 )
            local effName = GetNewRoleFxName(class,uSex)
            CEffectLoader_Inst():AddEftGroup(effName)
            local aniHandler = CAniHandler:new()
			aniHandler.renderObj = renderObj
			renderObj:SetModelHandler( aniHandler )
        end
	end
    for i,v  in pairs (self.m_ClassBtnTbl) do
        local classBtn = v
        classBtn:ShowWnd(true)
    end
end

--���ĳ��ְҵģ�ͺ����ٴ���ְҵ��ģ��,������Ǹ�ģ�Ͳ�����
function CNewRoleWnd:DestroyClassPerformer()
--����ģ��
    if not IsCppBound(g_CoreScene) then
        return
    end
	for i, v in pairs(self.m_PerformersTbl) do 
		local performer = v 
		local renderObj = performer:GetRenderObject()
		renderObj:SetModelHandler( nil )
	    g_CoreScene:DestroyObjectPerformer(performer)
	end
	self.m_PerformersTbl = {}
end

function  CNewRoleWnd:FallCameraTickFunc(Tick, choosedPerformer, choosedPerformerNo, xpos, ypos)
	ShowPerformerFalseShowWndTrue(choosedPerformer, choosedPerformerNo)
	MoveCamera(self.m_FallCameraTickTimes, xpos, ypos, false)
	if self.m_FallCameraTickTimes == TickRunTimes then
		UnRegisterTick(self.m_FallCameraTick)
		self.m_FallCameraTick = nil
		self.m_IsFallingCamera = false
		self.m_FallCameraTickTimes = nil
		SetEvent(Event.Test.AfterMoveCameraTick, true)
		self.m_KeyHook = CEnterGameInNewRoleHook:new()
		SQRWnd_RegisterHook( self.m_KeyHook, WM_KEYDOWN )
		return 
	end
	self.m_FallCameraTickTimes = self.m_FallCameraTickTimes + 1
end

--���ְҵģ�ͺ���ʾ�޸Ľ�ɫ���ʹ���
function CNewRoleWnd:ShowNewRoleDescWnd()
    self:UnRegisterRaiseCameraTick()
	self.m_IsFallingCamera = true
	self.m_FallCameraTickTimes = 1
	if self.m_RaiseCameraTickTimes ~= nil and
        self.m_RaiseCameraTickTimes > 1 then --�ھ�ͷ��Զ��ʱ���ֵ���ĳ��ģ������
		self.m_FallCameraTickTimes = TickRunTimes - self.m_RaiseCameraTickTimes
	end
	local campInfo = g_Conn.m_NewRoleCampInfo
	local xposStr = "XPos" .. campInfo
	local yposStr = "YPos" .. campInfo
	self.m_xPos  = NewRoleClassModle_Client(self.m_ChoosedPerformerNo, xposStr)
	self.m_yPos  = NewRoleClassModle_Client(self.m_ChoosedPerformerNo, yposStr)
	self.m_ShowNewRoleInfoWnd  = false
	--self:OnSelectHairColor(2)
	if self.m_MouseOverDescWnd ~= nil and 
  	self.m_MouseOverDescWnd:IsShow() == true then
		self.m_MouseOverDescWnd:SetTransparentObj(PerformerShowTime,true)
 	end
 	local roleInfoDesc = Lan_NewRoleClassModle_Client(self.m_ChoosedPerformerNo,"RoleInfoDesc")
 	self.m_RoleInfoDesc:SetWndText(roleInfoDesc)
    for i,v  in pairs (self.m_ClassBtnTbl) do
        local classBtn = v
        classBtn:SetTransparentObj(NewRoleInfoWndShowTime, true)
    end
	self.m_FallCameraTick = RegClassTick("FallCamera", self.FallCameraTickFunc, 10, self, self.m_ChoosedPerformer, self.m_ChoosedPerformerNo, self.m_xPos*64, self.m_yPos*64)
end

function CNewRoleWnd:SetSelectClassRoleModelInfo()
	local faceStr = "Face" .. g_Conn.m_NewRoleCampInfo
    local hairStr = "Hair" .. g_Conn.m_NewRoleCampInfo
	local choosedFace = NewRoleClassModle_Client(self.m_ChoosedPerformerNo,faceStr)
	local choosedHair = NewRoleClassModle_Client(self.m_ChoosedPerformerNo,hairStr)
    local hairStyleIndex =1
    for i, v in pairs (self.m_HairStyle) do
        local hairName = NewRoleProperty_Common(v, "Name")
        if string.find(choosedHair, hairName, 1, true) ~= nil then
            hairStyleIndex = i
            break
        end
    end
    local faceIndex =1
    for i, v in pairs (self.m_Face) do
        local faceName = NewRoleProperty_Common(v,"Name")
        if string.find(choosedFace, faceName, 1, true) ~= nil then
            faceIndex = i
            break
        end
    end
    self:SetRenderModelInfo(hairStyleIndex,hairStyleIndex,faceIndex,faceIndex)
end

---------------------------------������ɫ���棬�Խ�ɫ����ĸı䣺�����͡����͡���ɫ��-------------------------------------------
function CNewRoleWnd:OnSelectHairStyle(direction)
	local item
	if(direction == 1) then
		self.m_nHairStyleSelIdx[1] = self.m_nHairStyleSelIdx[1]-1	
	end
	if(direction == 2) then
		self.m_nHairStyleSelIdx[1] = self.m_nHairStyleSelIdx[1]+1
	end		

	item, self.m_nHairStyleSelIdx[1] = self:GetTableItem(self.m_HairStyle, self.m_nHairStyleSelIdx[1])
    
    local tbl = self.m_WomanHairColor 
    if self.m_nSex == ECharSex.eCS_Male then
       tbl = self.m_ManHairColor 
    end
	local hairColorStr = NewRoleProperty_Common(tbl[self.m_nHairColorSelIdx[1]],"Name")
	local newHairInfo =  item .. hairColorStr
    self.m_nHair = g_ParseCustomTblServer[newHairInfo]
    
	--self.m_nHair=g_ParseCustomTblServer[item]
	self:OnSelectModel({self.m_nHair}, nil, self.m_nClass, self.m_nSex)
	self.m_wndSelectHairStyle:SetWndText(Lan_NewRoleProperty_Common(self.m_HairStyle[self.m_nHairStyleSelIdx[1]],"DisplayName"))
end

function CNewRoleWnd:OnSelectHairColor(direction)
	local item
	if(self.m_nSex == ECharSex.eCS_Male) then
		if(direction == 1) then
			self.m_nHairColorSelIdx[1] = self.m_nHairColorSelIdx[1]-1	
		end
		if(direction == 2) then
			self.m_nHairColorSelIdx[1] = self.m_nHairColorSelIdx[1]+1
		end		
		item, self.m_nHairColorSelIdx[1] = self:GetTableItem(self.m_ManHairColor, self.m_nHairColorSelIdx[1])
		self.m_nHairColor = self.m_nHairColorSelIdx[1]
		self.m_wndSelectHairColor:SetWndText(Lan_NewRoleProperty_Common(self.m_ManHairColor[self.m_nHairColorSelIdx[1]], "DisplayName"))
	else
		if(direction == 1) then
			self.m_nHairColorSelIdx[2] = self.m_nHairColorSelIdx[2]-1	
		end
		if(direction == 2) then
			self.m_nHairColorSelIdx[2] = self.m_nHairColorSelIdx[2]+1
		end
		item, self.m_nHairColorSelIdx[2] = self:GetTableItem(self.m_WomanHairColor, self.m_nHairColorSelIdx[2])
		self.m_nHairColor = self.m_nHairColorSelIdx[2]
		self.m_wndSelectHairColor:SetWndText(Lan_NewRoleProperty_Common(self.m_WomanHairColor[self.m_nHairColorSelIdx[2]], "DisplayName"))
	end
    if self.m_nClass == 9 then --����
        local hairStyleIndex = self.m_Face[self.m_nFaceSelIdx[1]] 
    	local hairStyleStr = NewRoleProperty_Common(hairStyleIndex,"Name")
    	local newHairInfo =  "����" .. hairStyleStr .. item
    	
        local newHairInfoIdexInCfg = g_ParseCustomTblServer[newHairInfo]
        self.m_nHair = newHairInfoIdexInCfg 
    else
    	local hairStyleIndex = self.m_HairStyle[self.m_nHairStyleSelIdx[1]] 
    	local hairStyleStr = NewRoleProperty_Common(hairStyleIndex,"Name")
    	local newHairInfo =  hairStyleStr .. item
    	
        local newHairInfoIdexInCfg = g_ParseCustomTblServer[newHairInfo]
        self.m_nHair = newHairInfoIdexInCfg
    end
	self:OnSelectModel({self.m_nHair}, nil, self.m_nClass, self.m_nSex)--���ڸ�����ɫ�Ĵ���
end

function CNewRoleWnd:OnSelectFace(direction)
	local item
	if(direction == 1) then
		self.m_nFaceSelIdx[1] = self.m_nFaceSelIdx[1]-1	
	end
	if(direction == 2) then
		self.m_nFaceSelIdx[1] = self.m_nFaceSelIdx[1]+1
	end		
	item, self.m_nFaceSelIdx[1] = self:GetTableItem(self.m_Face, self.m_nFaceSelIdx[1])
	self.m_nFace=g_ParseCustomTblServer[item]
    if self.m_nClass == 9 then --����
        local hairStyleIndex = self.m_Face[self.m_nFaceSelIdx[1]] 
    	local hairStyleStr = NewRoleProperty_Common(hairStyleIndex,"Name")
    	local color  =  self:GetTableItem(self.m_ManHairColor, self.m_nHairColorSelIdx[1])
    	local newHairInfo =  "����" .. hairStyleStr .. color
        local newHairInfoIdexInCfg = g_ParseCustomTblServer[newHairInfo]
        self.m_nHair = newHairInfoIdexInCfg 
        
    end
	self:OnSelectModel({self.m_nFace}, nil, self.m_nClass, self.m_nSex)
	self.m_wndSelectFace:SetWndText(Lan_NewRoleProperty_Common(self.m_Face[self.m_nFaceSelIdx[1]],"DisplayName"))
end

function CNewRoleWnd:OnSelectModel(Model, performer, class, sex)
	local renderObj = nil
	if performer ~= nil then 
		renderObj = performer:GetRenderObject()
	else
		renderObj = self.m_ChoosedPerformer:GetRenderObject()
	end
	if renderObj.m_EffectID ~= nil then
		renderObj:DelEffect(renderObj.m_EffectID)
	end

	InitCreatePlayerAni(renderObj, class, sex, nil)	
	InitPlayerCustomRes(renderObj, Model, class, sex)
	
	local tblRes = g_GetNewRoleRes(class)

	InitPlayerModel(
		renderObj,
		{		
			tblRes["ArmetResID"],
			tblRes["BodyResID"],
			tblRes["ArmResID"],
			tblRes["ShoeResID"],
			tblRes["ShoulderResID"],
		},
		class, sex
	)
	
	InitWeaponRender(renderObj, tblRes["WeaponResID"], class, sex)
	InitWeaponRender(renderObj, tblRes["OffWeaponResID"], class, sex)	
	renderObj:DoAni( "stand01_2", true, -1.0 )
end

function CNewRoleWnd:GetTableItem(tbl, index)
	local num = table.getn(tbl)
	if(index > num) then
		index = 1
		return NewRoleProperty_Common(tbl[1],"Name"), 1
	end
	if(index < 1) then
		index = num
		return NewRoleProperty_Common(tbl[num], "Name"), num
	end
	return NewRoleProperty_Common(tbl[index], "Name"), index
end

--------------------------------------------------------------
function CNewRoleWnd:RaiseCameraEnterGameTickFunc()
	MoveCamera(self.m_RaiseCameraInGameTickTimes, self.m_xPos*64, self.m_yPos*64, true, true, true)
	if self.m_RaiseCameraInGameTickTimes == TickRunTimes then
		UnRegisterTick(self.m_RaiseCameraInGameTick)
		self.m_RaiseCameraInGameTick = nil
		self.m_IsFallingCamera = false
		g_GameMain.m_CoreScene = nil
	    if g_NewRole.m_HaveDestroyedNewRoleMainScene then  --newRoleʱ�����ĳ����Ѿ�������
	        g_NewRole:OnExit()
	    end
		return 
	end
	self.m_RaiseCameraInGameTickTimes = self.m_RaiseCameraInGameTickTimes + 1
end

function CNewRoleWnd:UnRegisterTick()
    self:UnRegisterFallCameraTick()
    self:UnRegisterRaiseCameraTick()
    SQRWnd_UnRegisterHook( self.m_KeyHook )
	self:ShowChild(false, true, 1000)
end

function CNewRoleWnd:EnterGameFromNewRoleState()
    g_NewRoleEnterGame.m_CurState = CNewRoleEnterGame.NewRoleEnterGameStateTbl["GameMain"]
    g_GameMain:ShowWnd(true)
	g_GameMain.NewPlayerXPos = self.m_xPos*64
	g_GameMain.NewPlayerYPos =  self.m_yPos*64
	g_GameMain:ShowInitWndOrNot(true)

	if self.m_MouseOverDescWnd ~= nil and self.m_MouseOverDescWnd:IsShow() then
	    self.m_MouseOverDescWnd:SetTransparentObj(TransparentTime,true)
	end
	self:DestroyClassPerformer()
	g_GameMain.m_CoreScene = g_CoreScene
	self.m_RaiseCameraInGameTickTimes = 1
	self:UnRegisterTick()
	self.m_RaiseCameraInGameTick = RegClassTick("RaiseCameraEnterGame", self.RaiseCameraEnterGameTickFunc, 10, self)
end

function CNewRoleWnd:UnRegisterFallCameraTick()
    if  self.m_FallCameraTick ~= nil then
		UnRegisterTick(self.m_FallCameraTick)
		self.m_FallCameraTick = nil
		self.m_FallCameraTickTimes = nil
		self.m_IsFallingCamera = nil
	end
end

function CNewRoleWnd:UnRegisterRaiseCameraTick()
    if self.m_RaiseCameraTick ~= nil then
		UnRegisterTick(self.m_RaiseCameraTick)
		self.m_RaiseCameraTick = nil
	    self.m_RaiseCameraTickTimes = nil
		self.m_IsRaisingCamera = nil
	end
end

function CNewRoleWnd:UnRegisterEnterGameCameraTick()
    if self.m_RaiseCameraInGameTick ~= nil then
		UnRegisterTick(self.m_RaiseCameraInGameTick)
		self.m_RaiseCameraInGameTick = nil 
	end
end

function CNewRoleWnd:UnRegisterNewRoleTick()
	self:UnRegisterFallCameraTick()
	self:UnRegisterRaiseCameraTick()
	self:UnRegisterEnterGameCameraTick()
	
	SQRWnd_UnRegisterHook( self.m_KeyHook )
end

function CNewRoleWnd:ShowPerformerTrueSlowly()
    if IsCppBound(g_CoreScene) then    
        for i, v in pairs(self.m_PerformersTbl) do
        	--255����ʾ,0������
        	local showScale = 255/TickRunTimes * self.m_RaiseCameraTickTimes
        	v:GetRenderObject():SetAlphaValue(showScale)
        end
	end
end

function CNewRoleWnd:ShowPerformerFalseSlowly(choosedPerformer)
	local performer = choosedPerformer
	if IsCppBound(g_CoreScene) then
    	for i, v in pairs(self.m_PerformersTbl) do
    		if v ~= performer then --255����ʾ,0������
    			local showScale = 255 -  255 /(TickRunTimes * 1/3) * self.m_FallCameraTickTimes
    			v:GetRenderObject():SetAlphaValue(showScale)
    		end
    	end
    end
end






