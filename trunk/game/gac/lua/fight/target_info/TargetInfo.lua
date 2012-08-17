gac_require "fight/target_info/TargetInfoInc"
gac_require "framework/common_wnd_ctrl/CommonCtrlInc"
gac_require "framework/common_wnd_ctrl/CommonCtrl"
gac_require "fight/player_info/PlayerInfo"
gac_require "fight/skill_loading/BaseSkillLoading"
gac_gas_require "fight/target_info/SmashMgr"
gac_gas_require "relation/tong/TongPurviewMgr"
gac_require "framework/texture_mgr/DynImageMgr"
lan_load "image_res/Lan_TeamMarkImage_Common"

---------------------------------------------------------------------------------------
--��������
function CreateTargetCoreInfo( Parent )
	local Wnd = CTargetCoreInfo:new()
	Wnd:CreateFromRes( "AimHeadCore", Parent )
	Wnd:SetIsBottom(true)
	return Wnd
end

function CTargetCoreInfo:OnChildCreated()
	self.m_PortraitDlg	= CRenderSystemClient_Inst():CreateObjectDialog()
	local param		= WndCreateParam:new()
	param.uStyle	= 0x60000000
	param.x			= 0
	param.y			= 0
	param.width		= self:GetWndOrgWidth()
	param.height	= self:GetWndOrgHeight()
	param:SetParentWnd(self)
	self.m_PortraitDlg:Create(param)
	self.m_PortraitDlg:SetUseSceneDepth( true )
	self.m_PortraitDlg:SetViewPortrait( true, g_ImageMgr:GetImagePath(20000), g_ImageMgr:GetImagePath(20001) )
	self.m_RenderObj = self.m_PortraitDlg:CreateRenderObject()
end

--ע������C++����
function CTargetCoreInfo:OnDestroy()
	self.m_PortraitDlg:DestroyRenderObject(self.m_RenderObj)
	CRenderSystemClient_Inst():DestroyObjectDialog(self.m_PortraitDlg)
end
---------------------------------------------------------------------------------------

function CreateTargetInfo( Parent )
	local Wnd = CTargetInfo:new()
	Wnd:CreateFromResEx("AimHead", Parent, false, false)
	Wnd:SetIsBottom(true)
	--ͬ����Ϣ
	Wnd.pViewInfo = CFighterViewInfo:new()
	Wnd.m_TargetEntityID = 0
	Wnd.m_SmashImageMgr = CSmashInfoMgr:new()
	return Wnd
end

--��ʼ��Ŀ������еĿؼ�
function CTargetInfo:OnChildCreated()
	self.m_WndHP				= self:GetDlgChild("WndHP")
	self.m_WndName				= self:GetDlgChild("WndName")
	self.m_WndLevel				= self:GetDlgChild("WndLevel")
	self.m_WndMP				= self:GetDlgChild("WndMP")
	self.m_WndCastingProcess	= self:GetDlgChild("WndCastingProcess")
	self.m_SmashIcon			= self:GetDlgChild("SmashIcon")
	self.m_WndCastingIcon = self:GetDlgChild("WndCastingIcon")
	
	self.m_SmashIcon:ShowWnd(false)
	self.m_WndHP:SetProgressMode(0)
	self.m_WndMP:SetProgressMode(0)
	self:InitSkillLoading(self.m_WndCastingProcess)
	self.m_WndCastingProcess:ShowWnd(false)
	if self.m_WndCastingIcon then
		self.m_WndCastingIcon:ShowWnd(false)
	end
	self.m_tblHeadMark = {[0] = GacMenuText(209)}--�Ŷӱ������{����,ȦȦ,שʯ,����,����,����,ʮ��,ͷ­,��}
	for i, v in ipairs( Lan_TeamMarkImage_Common:GetKeys() ) do
		self.m_tblHeadMark[i] = Lan_TeamMarkImage_Common(v, "DisplayName")
	end
	self.m_bPlayer = false --���������Ŷӱ��Item�ģ���¼�Ҽ��������NPCͷ�������ͷ����ȷ���Ŷӱ���Ӳ˵��Ļ���λ��
	self.m_WndClass = self:GetDlgChild("ClassWnd")
end

--�л�Ŀ��
function CTargetInfo:ShowAndUpdate()
	local Target=g_MainPlayer.m_LockCenter.m_LockingObj
	if(not Target) then return end
	self.m_WndHP:EndChangeDiff()
	self:SetTargetInfo(Target)
	self:UpdatePortrait(Target)--����ͷ��
	self:Update()
	
	--���䳵
	if(self.m_TargetType == ECharacterType.Npc and Target:GetNpcType() == ENpcType.ENpcType_Truck) then
		self.m_nMaxMP = g_TongMgr.m_tblTruckMaxLoad[Target.m_Properties:GetCharName()]
		local MaterialNum = Target:GetCurMaterialNum()
		if MaterialNum > self.m_nMaxMP then
			self.m_nMaxMP = MaterialNum
		end
		self:SetMPValue(MaterialNum, self.m_nMaxMP)
	end
	
	self:ShowWnd(true)
	g_GameMain.m_TargetCore:ShowWnd(true)
end

function CTargetInfo:UpdateIntObj()
	local Target=g_MainPlayer.m_LockCenter.m_LockingIntObj
	if(Target == nil)then
		self:ShowWnd( false )
		return
	end
	self.m_TargetType = Target.m_Properties:GetType()
	self:ShowWnd( true )
	g_GameMain.m_TargetCore:ShowWnd(true)
	self.m_SmashIcon:ShowWnd(false)
	local ShowName = GetIntObjDispalyName(Target.m_Properties:GetCharName())
	self.m_WndName:SetWndText(ShowName)
	self.m_WndLevel:SetWndText("")
	self.m_WndHP:SetWndText(100 .. "/" .. 100)
	self.m_WndHP:SetRange( 100 )	
	self.m_WndHP:SetPos( 100 )
	self.m_WndMP:SetRange( 100 )
	self.m_WndMP:SetPos( 100 )
	self.m_WndMP:SetWndText( 100 .. "/" .. 100 )
	self:SetMPPic(Target)
	--��������Ͳ�Ҫͷ���˰�?
	g_GameMain.m_TargetCore.m_RenderObj:RemovePiece("face")
	g_GameMain.m_TargetCore.m_RenderObj:RemovePiece("hair")
	g_GameMain.m_TargetCore.m_RenderObj:RemovePiece("armet")
	g_GameMain.m_TargetCore.m_RenderObj:RemovePiece("head")
	g_GameMain.m_TargetCore.m_RenderObj:RemovePiece("body")
end

function CTargetInfo:Update()
	local Target=g_MainPlayer.m_LockCenter.m_LockingObj
	if(not Target) then return end
	self.m_TargetType     = Target.m_Properties:GetType()
	self.m_TargetEntityID = Target:GetEntityID()
	self.m_TargetCamp     = Target:CppGetCamp()
	self.pViewInfo:CppInit(self.m_TargetEntityID)
	local isShowSmash = (self.m_TargetType == ECharacterType.Npc and self.m_TargetCamp == ECamp.eCamp_Monster and g_MainPlayer:CppGetCamp() ~= self.m_TargetCamp)
	self.m_SmashIcon:ShowWnd(isShowSmash)
	
	--�ȼ�
	self.m_TargetLevel = Target:CppGetLevel()
	self.m_WndLevel:SetWndText(self.m_TargetLevel)
	
	--******Ѫ**********************************************************************
	local nCurHP	= Target:CppGetCtrlState(EFighterCtrlState.eFCS_FeignDeath) and 0 or Target:CppGetPropertyValueByName("HealthPointAgile")
	local nUpperHP	= Target:CppGetPropertyValueByName("HealthPoint")
	self.m_WndHP:SetRange(nUpperHP)
	self.m_WndHP:SetWndText( string.format("%d/%d", nCurHP, nUpperHP) )
	self.m_WndHP:SetPos(nCurHP)
	
	g_GameMain.m_CharacterInSyncMgr:ChangeHPByMe(self.m_WndHP)
	
	--******ħ**********************************************************************
	if( self.m_TargetType == ECharacterType.Player and (self.m_TargetClass == EClass.eCL_Warrior or self.m_TargetClass == EClass.eCL_OrcWarrior) ) then
		self:SetMPValue(Target:CppGetPropertyValueByName("RagePointAgile"), 100)
	elseif( self.m_TargetType == ECharacterType.Player and self.m_TargetClass == EClass.eCL_DwarfPaladin ) then
		self:SetMPValue(Target:CppGetPropertyValueByName("EnergyPointAgile"), 100)
	elseif(self.m_TargetType == ECharacterType.Npc and Target:GetNpcType() == ENpcType.ENpcType_Truck) then
		return
	else
		self:SetMPValue(Target:CppGetPropertyValueByName("ManaPointAgile"), Target:CppGetPropertyValueByName("ManaPoint"))
	end
end

function CTargetInfo:SetMPValue(cur, max)
	self.m_WndMP:SetRange(max)
	self.m_WndMP:SetPos(cur)
	self.m_WndMP:SetWndText(cur .. "/" .. max)
end

--�ر����
function CTargetInfo:ClosePanel()
	self.m_TargetEntityID = 0
	self:ShowWnd(false)
	self:DestroyMenu()
	g_GameMain.m_TargetCore:ShowWnd(false)
end

--��ѹֵ�仯
function CTargetInfo:SmashValueChanged(bTargetIsDead, uAttackType, uSmashValue, fSmashRate)
	if bTargetIsDead then
		self.m_SmashIcon:ShowWnd(false)
		return
	end
	self:SetSmashPic(uAttackType, uSmashValue, fSmashRate)
end

--�趨Ŀ�������Ϣ
function CTargetInfo:SetTargetInfo(Target)
	self.m_TargetEntityID	= Target:GetEntityID()
	self.m_TargetType		= Target.m_Properties:GetType()
	self.m_TargetCamp		= Target:CppGetCamp()
	self.m_TargetClass		= Target:CppGetClass()
	self.m_TargetName		= Target:GetRealName()
	self.m_TongID			= 0
	
	if(self.m_TargetName == "") then
		self.m_TargetName = Target.m_Properties:GetCharName()
	end

	if(self.m_TargetType == ECharacterType.Player) then
		if(Target:IsBattleHorse()) then
			self.m_TargetID = 0
			self.m_TargetName = GetNpcDisplayName(self.m_TargetName)
		else
			self.m_TargetID	= Target.m_Properties:GetCharID()
			self.m_TongID	= Target.m_Properties:GetTongID()
		end
	elseif(self.m_TargetType == ECharacterType.Npc and Target:GetRealName() == "") then
		self.m_TargetName = GetNpcDisplayName(self.m_TargetName)
	else
		self.m_TargetID = 0
	end
	------------------------------------
	if(1 == g_GameMain.m_SceneStateForClient) then
		if self.m_TargetType == ECharacterType.Npc then
			local Master = Target:GetMaster()
			if not Master or Master ~= g_MainPlayer then
				self.m_TargetName = GetStaticTextClient(1113)--������
			end
		else
			self.m_TargetName = GetStaticTextClient(1113)--������
		end
	end
	------------------------------------
	self:SetClassPic(Target)
	self:SetMPPic(Target)
	self.m_WndName:SetWndText(self.m_TargetName)
end

function CTargetInfo:SetMPPic(Target)
	if(self.m_TargetType == ECharacterType.Player) then
		if(self.m_TargetClass == EClass.eCL_Warrior or self.m_TargetClass == EClass.eCL_OrcWarrior or self.m_TargetClass == EClass.eCL_DwarfPaladin) then
			local strTex = g_ImageMgr:GetImagePath(1353)
			g_DynImageMgr:AddImageByIP(self.m_WndMP, strTex, IP_FILL)
			return
		end
	elseif(self.m_TargetType == ECharacterType.Npc) then
		if(Target:GetNpcType() == ENpcType.ENpcType_Truck) then
			local strTex = g_ImageMgr:GetImagePath(1354)
			g_DynImageMgr:AddImageByIP(self.m_WndMP, strTex, IP_FILL)
			return
		end
	end
	local strTex = g_ImageMgr:GetImagePath(1355)
	g_DynImageMgr:AddImageByIP(self.m_WndMP, strTex, IP_FILL)
end

function CTargetInfo:SetClassPic(Target)
	if self.m_TargetType == ECharacterType.Player then
		local nClass	= Target:CppGetClass()
		local nCamp		= Target:CppGetBirthCamp()
		local sEnableImg, sDisableImg, sCamp, sClass	= g_DynImageMgr:GetClassPic(nCamp, nClass)
		g_DynImageMgr:AddImageByIP(self.m_WndClass, sEnableImg, IP_ENABLE)
		self.m_WndClass:SetMouseOverDescAfter(sCamp .. "#r" ..sClass)
		self.m_WndClass:ShowWnd(true)
	else
		self.m_WndClass:ShowWnd(false)
	end
end

function CTargetInfo:SetSmashPic(uAttackType, uSmashValue, fSmashRate)
	local smashImage, smashType = self.m_SmashImageMgr:GetSmashImage(uAttackType, fSmashRate)
	g_DynImageMgr:AddImageByIP(self.m_SmashIcon, smashImage, IP_ENABLE)
	self.m_SmashIcon:SetMouseOverDescAfter( g_Tooltips:GetSmashTips(smashType, uAttackType, uSmashValue, fSmashRate) )
end

function CTargetInfo:ChooseSelf()
--ѡ�����Լ�
end

--�۲�Ŀ��
function CTargetInfo:OnSee()
	local Target = g_MainPlayer.m_LockCenter.m_LockingObj
	if(not Target) or Target == g_MainPlayer then 
		return 
	end
	local Type = Target.m_Properties:GetType()
	if Type ~= ECharacterType.Player then
		return
	end	
	
	local Wnd = g_GameMain.m_AimStatusWnd
	Wnd:ClearAllInfo()
	if Wnd.m_Target ~= Target then
		if Wnd.m_Target then
			Wnd:OnClosePanel()
		end
		Wnd.m_PlayerName:SetWndText(Target.m_Properties:GetCharName())
		local uTargetID = Target:GetEntityID()
		local viewinfoMgr = CFighterViewInfoMgr.GetWnd()
		viewinfoMgr:AddViewInfoByID(uTargetID)
		Wnd.m_Target = Target
	end
	Gac2Gas:RequestAimInfo(g_Conn,Target.m_uID)
	Gac2Gas:GetAimPlayerSoulNum(g_Conn,Target.m_uID)
end

--��Ŀ�귢�����Ļ�
function CTargetInfo:OnWhisper()
	g_GameMain.m_AssociationWnd:CreateAssociationPriChatWnd(self.m_TargetID, self.m_TargetName) --˽��
end

function CTargetInfo:OnFollow()
	g_MainPlayer.m_LockCenter.m_Speed = g_MainPlayer:GetMaxSpeed()
	g_MainPlayer:MoveToLockObj()
end

function CTargetInfo:OnAddFriend()
	if(0 == self.m_TargetID) then return end
	
	local tblInfo	= {}
	tblInfo.id		= self.m_TargetID
	tblInfo.name 	= self.m_TargetName
	g_GameMain.m_AssociationWnd:CreateAddToClassWnd(tblInfo, false)
end

--��ʼ�����״��ڣ����ͽ�������
function CTargetInfo:OnInviteTrade()
	if g_MainPlayer.m_ItemBagLock then
		MsgClient(160015)
		return 
	end
	local Target = g_MainPlayer.m_LockCenter.m_LockingObj
	if(not Target) or Target == g_MainPlayer then 
		return 
	end
	if g_GameMain.m_PlayersTradeWnd:IsShow() == false then
		Gac2Gas:SendTradeInvitation( g_Conn, Target.m_uID )
	end
end

function CTargetInfo:OnInviteTeam()
	if(0 == self.m_TargetID) then return end
	Gac2Gas:InviteMakeTeam(g_Conn, self.m_TargetID)
end

function CTargetInfo:TongInvite()
	if(0 == self.m_TargetID) then return end
	Gac2Gas:InviteJoinTong(g_Conn, self.m_TargetID)
end

function CTargetInfo:TongApp(nTongID)
	if(0 == self.m_TargetID) then return end
	Gac2Gas:RequestJoinTong(g_Conn, nTongID)
end

function CTargetInfo:OnInviteArmyCorps()
	if(0 == self.m_TargetID) then return end
	Gac2Gas:InviteJoinArmyCorps(g_Conn, self.m_TargetID)
end

function CTargetInfo:OnMenuMsg(func)
	if(func) then func(self) end
	self:DestroyMenu()
end

function CTargetInfo:DestroyMenu()
	if(self.m_Menu) then
		self.m_Menu:Destroy()
		self.m_Menu = nil
	end
end

function CTargetInfo:OnRButtonClick( wParam, x, y )
	self:DestroyMenu()
	if(3 == self.m_TargetType or 0 == self.m_TargetID) then return end --���������Ʒ
		
	local Menu		= nil
	local bCaptain	= g_GameMain.m_TeamBase.m_bCaptain
	self.m_bPlayer	= false
	
	if( ECharacterType.Player == self.m_TargetType ) then
		Menu = CMenu:new("TargetMenu", g_GameMain)
		if(self.m_TargetID ~= g_MainPlayer.m_uID) then
			if(1 ~= g_GameMain.m_SceneStateForClient) then --���ڴ���ɱ������
				local TeamID		= g_MainPlayer.m_Properties:GetTeamID()
				local tongID		= g_MainPlayer.m_Properties:GetTongID()
				local canInviteTeam	= (0 == TeamID) or (bCaptain and g_GameMain.m_TeamBase.m_TeamSize < 5)
				Menu:InsertItem(GacMenuText(101),self.OnMenuMsg, nil, false, false, nil, self, self.OnFollow )					--����
				Menu:InsertItem(GacMenuText(102),self.OnMenuMsg, nil, false, false, nil, self, self.OnSee )						--�鿴
				Menu:InsertItem(GacMenuText(103),self.OnMenuMsg, nil, false, false, nil, self, self.OnAddFriend )				--��Ϊ����
				Menu:InsertItem(GacMenuText(104),self.OnMenuMsg, nil, false, false, nil, self, self.OnInviteTrade)				--����
				Menu:InsertItem(GacMenuText(105),self.OnMenuMsg, nil, false, false, nil, self, self.OnWhisper)					--˽��
				if(canInviteTeam) then
					Menu:InsertItem(GacMenuText(106),self.OnMenuMsg, nil, false, false, nil, self, self.OnInviteTeam)			--�������
				end
				if(bCaptain) then
					Menu:InsertItem(GacMenuText(109),self.OnMenuMsg, nil, false, true, self.OpenHeadMark, self)					--��� >>
				end
				if CArmyCorpsPanel.GetWnd():CanInviteArmyCorps() then
					Menu:InsertItem(GacMenuText(108),self.OnMenuMsg, nil, false, false, nil, self, self.OnInviteArmyCorps)--��������
				end
				
				--�������Ӷ����/�������Ӷ����
				if( 0 ~= tongID and 0 == self.m_TongID ) then
					if( 0 ~= g_TongPurviewMgr:GetInviteMemberValue(g_GameMain.m_TongBase.m_TongPos) ) then
						Menu:InsertItem(GacMenuText(612), self.OnMenuMsg, nil, false, false, nil, self, self.TongInvite)
					end
				elseif( 0 == tongID and 0 ~= self.m_TongID ) then
					Menu:InsertItem(GacMenuText(613), self.TongApp, nil, false, false, nil, self, self.m_TongID)
					self:DestroyMenu()
				end
				
				self.m_bPlayer = true
			end
		else
			if(bCaptain) then
				Menu:InsertItem(GacMenuText(109),self.OnMenuMsg, nil, false, true, self.OpenHeadMark, self)						--��� >>
			else
				Menu:InsertItem(GacMenuText(111),self.OnMenuMsg, nil, false, false, nil, self, self.ChooseSelf )				--ѡ�����Լ�
			end
		end
	elseif( ECharacterType.Npc == self.m_TargetType ) then
		if(bCaptain) then
			Menu = CMenu:new("TargetMenu", g_GameMain)
			Menu:InsertItem(GacMenuText(109),self.OnMenuMsg, nil, false, true, self.OpenHeadMark, self)		--��� >>
		end
	else
		self:DestroyMenu()
	end
	
	local Rect=CFRect:new()
	self:GetLogicRect(Rect)
	if(Menu) then
		Menu:SetPos( Rect.left+5, Rect.top+60 )
	end
	self.m_Menu=Menu
end

------������ǲ˵�------
function CTargetInfo:OpenHeadMark()
	g_GameMain.m_ChildMenu = CMenu:new("TargetMenu", self.m_Menu)
	local childMenu = g_GameMain.m_ChildMenu
	for i = 0, #(self.m_tblHeadMark) do
		childMenu:InsertItem(self.m_tblHeadMark[i], self.OnMark, nil, true, false, nil, self, i)
	end
	local rect = self.m_Menu:GetItemRect(self.m_bPlayer and 5 or 0)
	childMenu:SetPos(rect.right, rect.top)
end

------��Ŀ����б��------
function CTargetInfo:OnMark(type) --type��ֵ��self.m_tblHeadMark�������ֵ��Ӧ
	self:DestroyMenu()
	local ID = (ECharacterType.Player == self.m_TargetType) and self.m_TargetID or self.m_TargetEntityID
	Gac2Gas:UpdateTeamMark(g_Conn, type, self.m_TargetType, ID)
end

--����ͷ��
function CTargetInfo:UpdatePortrait(follower)
	--����µ�
	if not follower.m_Properties.m_StaticSyncRootVariant then
		return
	end
	local type = follower.m_Properties:GetType()
	local bShadow = false
	if type == ECharacterType.Npc then
		bShadow = follower.m_Properties:GetIsShadow()
	end
	if type == ECharacterType.Player or bShadow then		--���

		local tblCustomResID = {
				follower.m_Properties:GetFaceResID(),
				follower.m_Properties:GetHairResID(),
		}
		local uClass = nil
		local uSex 	= nil
		local tblResID = {}
		if bShadow then
			tblResID = {
				follower.m_Properties:GetBodyResID(),
				follower.m_Properties:GetHeadResID(),
				}
			uClass = follower.m_Properties:GetMasterClass()
			uSex	 = follower.m_Properties:GetMasterSex()
		else
			tblResID = {
				g_GetResIDByEquipPart(EEquipPart.eWear,follower),
				g_GetResIDByEquipPart(EEquipPart.eHead,follower),
				}
			uClass = follower:CppGetClass()
			uSex 	 = follower.m_Properties:GetSex()
		end
		local RenderObject 	= g_GameMain.m_TargetCore.m_RenderObj
		RenderObject:RemoveAllPiece()
		RenderObject:Delframework()
		InitPlayerCommonAni(RenderObject, uClass, uSex, nil)
		InitCustomCharPortrait(RenderObject, tblCustomResID, uClass, uSex)
		InitCharPortrait(RenderObject, tblResID, uClass, uSex)
		RenderObject:SetPortraitPiece("body")
		RenderObject:DoAni( "stand01_w", true, -1.0 )
	elseif type == ECharacterType.Npc then		--NPC
		if follower:GetNpcType() == ENpcType.ENpcType_BattleHorse then
			local NpcName = follower.m_Properties:GetCharName()
			local Sex = follower.m_Properties:GetSex()
			InitBattleHorsePortrait(g_GameMain.m_TargetCore.m_RenderObj, NpcName, Sex)	
		else
			local NpcName = follower.m_Properties:GetCharName()
			local Sex = follower.m_Properties:GetSex()
			InitNpcPortrait(g_GameMain.m_TargetCore.m_RenderObj, NpcName, Sex)
		end
	end
	g_GameMain.m_TargetCore.m_PortraitDlg:AddChild(g_GameMain.m_TargetCore.m_RenderObj, eLinkType.LT_UNKNOW, "")
end

--�����뿪��Ұ�������Ұ��Ŀ��
function CTargetInfo:ReLockObj(target)
	if(self.m_TargetEntityID == target:GetEntityID()) then
		g_MainPlayer:LockObj(target)
	end
end

function CTargetInfo:OnTaregtCastBegin( FolObj, skillname, flag ,time ,runedtime)
	self.m_WndCastingProcess:ShowWnd(true)
	local DisplayName = self:GetSkillDisPlayName(skillname)
	self.m_WndCastingProcess:SetWndText(DisplayName)
	if self.m_WndCastingIcon then
		local SmallIcon = self:GetSkillDisIcon(skillname)
		if SmallIcon then
			g_LoadIconFromRes(SmallIcon, self.m_WndCastingIcon,-1,IP_ENABLE, IP_ENABLE)
			self.m_WndCastingIcon:SetWndZoom(0.75)
			self.m_WndCastingIcon:ShowWnd(true)
		end
	end
	self:OnCastBegin( FolObj, skillname, flag ,time ,runedtime)
end

function CTargetInfo:ShowWndFalse()
	self.m_WndCastingProcess:SetPos(0)
	self.m_WndCastingProcess:ShowWnd(false)
	if self.m_WndCastingIcon then
		self.m_WndCastingIcon:ShowWnd(false)
	end
end

function CTargetInfo:SetLockObjRanderStyle(Target, bLock)
	if( Target == g_MainPlayer) then return end
		
	local type = Target.m_Properties:GetType()
	if( type == ECharacterType.Player and not Target:IsBattleHorse() ) then
		local bTeamMember = g_GameMain.m_TeamBase:IsTeamMember(Target:GetEntityID())
		if( bTeamMember ) then
			return
		end
	end
	Target:GetRenderObject():SetRenderStyle( bLock and 0x08A or 0x00A )
end

--��סF1ѡ���Լ�
function LockSelfObject()
	g_MainPlayer:LockObj(g_MainPlayer)
end

--��סSHIFT + F1ѡ���Լ����ٻ���
function LockSelfServant()
	local servant = g_MainPlayer:GetServant(ENpcType.ENpcType_Summon)
	if servant then
		g_MainPlayer:LockObj(servant)
	end
end

--@brief ��סF2-5���ֱ�ѡ�ж����е�1-4��ŵĶ���
--@param index�����ѵı��
function LockTeamMember(index)
	local tbl = g_GameMain.m_TeamBase.m_tblTeamMemberInfo
	if tbl[index] then
		local player = CCharacterFollower_GetCharacterByID(tbl[index][4])
		if player then
			g_MainPlayer:LockObj(player)
		end
	end
end

--@brief ͬʱ����shift��+F2-5ѡ�б����1-4�Ķ��ѵ��ٻ���
--@param index:���ѵı��
function LockTeamMemberServant(index)
	local tbl = g_GameMain.m_TeamBase.m_tblTeamMemberInfo
	if (tbl[index]) then
		local player = CCharacterFollower_GetCharacterByID(tbl[index][4])
		if player then
			local member_servant = player:GetServant(ENpcType.ENpcType_Summon)
			if member_servant then
				g_MainPlayer:LockObj(member_servant)
			end
		end
	end
end

--��SHIFT+F����Ŀ�����
function FollowLockObj()
	g_GameMain.m_TargetInfo:OnFollow()
end

--��SHIFT+B��Ŀ�������������
function InviteTradeLockObj()
	g_GameMain.m_TargetInfo:OnInviteTrade()
end

--��SHIFT+C�鿴Ŀ���������
function SeeLockObjInfo()
	g_GameMain.m_TargetInfo:OnSee()
end

function OnInviteArmyCorps()
	g_GameMain.m_TargetInfo:OnInviteArmyCorps()
end

--��SHIFT+Y��Ŀ��Ϊ����
function AddLockObjFriend()
	local Target = g_MainPlayer.m_LockCenter.m_LockingObj
	if not Target or (Target.m_Properties:GetType() ~= ECharacterType.Player) then
		return
	end
	TargetID = Target.m_Properties:GetCharID()
	if(0 == TargetID) then return end
		
	local tblInfo	= {}
	tblInfo.id		= TargetID
	tblInfo.name 	= Target.m_Properties:GetCharName()
	g_GameMain.m_AssociationWnd:CreateAddToClassWnd(tblInfo, false)
end

--��SHIFT+T����Ŀ��������
function InviteLockObjTeam()
	local Target = g_MainPlayer.m_LockCenter.m_LockingObj
	if not Target or (Target.m_Properties:GetType() ~= ECharacterType.Player) then
		return
	end
	TargetID = Target.m_Properties:GetCharID()
	if(0 == TargetID) then return end
	Gac2Gas:InviteMakeTeam(g_Conn, TargetID)
end

--��SHIFT+R��Ŀ�꿪��˽��
function OnWhisperWithLockObj()
	local Target = g_MainPlayer.m_LockCenter.m_LockingObj
	if not Target or (Target.m_Properties:GetType() ~= ECharacterType.Player) then
		return
	end
	TargetID = Target.m_Properties:GetCharID()
	TargetName = Target:GetRealName()
	local wnd = g_GameMain.m_AssociationWnd:CreateAssociationPriChatWnd(TargetID, TargetName)
	if(wnd) then
		wnd.m_InputText:SetIsOnCommand(true)
	end
end

--@brief ��CTRL+F1-F8ΪĿ��ָ�����1-8��F12���Ŀ����
--@param index�����ݴ������Ĳ�����Ŀ�������Ӧ�ı��
function MarkLockObj(index)
	local bCaptain      = g_GameMain.m_TeamBase.m_bCaptain
	if not bCaptain then
		return 
	end
	local Target = g_MainPlayer.m_LockCenter.m_LockingObj
	if not Target then
		return
	end
	targetType = Target.m_Properties:GetType()
	targetEntityID = Target:GetEntityID()
	Gac2Gas:UpdateTeamMark(g_Conn, index, targetType, targetEntityID)
end
