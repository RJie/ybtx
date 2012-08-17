gac_require "framework/main_frame/PropRes"
gac_require "framework/main_frame/GameState"
gac_gas_require "activity/scene/LoadPositionCfg"
gac_require "framework/display_common/DisplayCommon"
gac_require "fight/player_info/PlayerInfo"
gac_require "fight/role_status/StateCommon"
gac_require "information/head_info/HeadInfo"
gac_require "framework/gm_console/GMConsole"
gac_require "framework/mouse_hook/MouseHook" 
gac_require "framework/ground_selector/GroundSelector"
gac_require "message/message_box/MsgBoxMsg"
gac_require "toolbar/main_skills_toolbar/MainSkillsToolBar"
gac_require "toolbar/master_skill_area/MasterSkillArea"
gac_require "toolbar/panel_menu/PanelMenu"
gac_require "relation/team/TeamClient"
gac_gas_require "player/PlayerMgr"
gac_require "message/chat_wnd/ChatWnd"
gac_require "activity/npc_dialog_box/NpcDialogBox"
gac_require "activity/npc_dialog_box/NpcDialogBoxCopy"
gac_require "world/npc/NpcBornPointMgr"
gac_gas_require "areamgr/AreaMgr"

gac_require "activity/quest/QuestGas2GacFunc"
gac_require "activity/quest/NpcHeadSign"
gac_require "activity/quest/TeamMarkSign"
gac_require "activity/quest/QuestRecordWnd"
gac_gas_require "activity/npc/CheckNpcTriggerAction"
gac_gas_require "activity/Trigger/NpcTrigger"
gac_require "activity/quest/Quest"
gac_require "activity/playerautotrack/PlayerAutoTrackMgr"
gac_require "activity/quest/QuestTraceBack"
gac_require "activity/direct/DirectWnd"

gac_require "message/text_item_wnd/TextItemWnd"
gac_require "message/message_list/MsgListWnd"

gac_require "fight/turn_table/Turntable"
gac_require "fight/skill_loading/SkillLoadiNg" 
gac_require "fight/exp_bar/ExpBarWnd"
gac_require "activity/talkwith_npc_wnd/TalkWithNpcWnd"
--gac_require "activity/npc_dialog_box/SpecialNpcWnd"

gac_require "fight/burst_soul/BurstSoul"

gac_require "relation/team/TeamClient"
gac_require "relation/tong/TongBase"                  --��Ӷ���ŵ���ǰ��require
gac_require "relation/tong/tong_building/TongProductionBase"
gac_require "relation/tong/TongChallengeStatisticsWnd"
--gac_require "relation/tong/TongRobResourceWnd"
--gac_require "relation/tong/TongRobResExitWnd"
--gac_require "relation/tong/TongSignQueryWnd"
--gac_require "relation/tong/TongRobOverExit"

gac_require "activity/direct/DirectWnd"
gac_require "activity/direct/DirectShowWnd"

gac_require "relation/association/AssociationBase"
gac_require "relation/association/Association"
gac_require "relation/association/AssociationFind"

gac_require "setting/function_area/ExcludeWnd"

gac_require "activity/fb_action/FbAction_Mgr"

gac_require "activity/MercenaryMonsterFbWnd/MercenaryMonsterFbWnd"
gac_require "fight/pet/GacPetInfo"

gac_require "resource/productive_profession/LiveSkillExpertNPC"
gac_require "resource/productive_profession/LiveSkillProdMain"

gac_require "smallgames/ProgressWnd/CProgressWnd"
gac_require "smallgames/SmallGameMgr"

gac_require "activity/quest/PickupItem"
gac_require "world/player/PlayerActionWnd"
gac_require "smallgames/ClickPicClient/ClickPicWnd/CClickPicWnd"
gac_require "smallgames/GetHorseMedicine/CGetHorseMedicineWnd"
gac_require "smallgames/smallgame_msgwnd/SmallGameMsgWnd"
gac_require "activity/ride_camel/RideCamelWnd"
gac_require "toolbar/temp_skill_area/temp_skill"
--gac_require "activity/essayquestionwnd/EssayQuestionWnd"
gac_require "world/item/UseItemPlayEffect"
gac_gas_require "activity/scene/AreaFbSceneMgr"
gac_require "activity/tong_war_wnd/WarZoneSelWnd"
--gac_require "character/pk_switch/PkSwitchWnd"
gac_require "fight/target_info/TargetOfTargetInfo"
gac_require "toolbar/servant_skill_area/servant_skill"
gac_require "information/select_obj_tooltips/SelectObjTooltips"
gac_require "world/area/AreaIntroductionWnd"
gac_require "fight/role_status/PlayerFightInfo"
gac_require "message/system_msg/SystemMsgWnd"
gac_require "toolbar/hide_player/HidePlayer"
gac_gas_require "framework/message/message"

gac_gas_require "framework/common/OnceTickMgr"
gac_require "smallgames/HeadGames/HeadGameProgressWnd"
gac_require "smallgames/HeadGames/HeadFishing"
gac_require "smallgames/HeadGames/HeadHunt"
gac_require "relation/tong/TongBattlePersonalCountWnd"
gac_require "relation/tong/TongWarBattleCountWnd"
gac_require "relation/tong/TongChallengeBattleCountWnd"
gac_require "relation/tong/TongMonsAttackCountWnd"
gac_require "relation/tong/TongDownTimeWnd"
--gac_require "relation/tong/TongShowRulesWnd"
gac_require "message/bag_shapeeffect_wnd/BagShapeEffectWnd"
gac_require "activity/MercenaryLevelWnd/MercenaryLevelTrace"
gac_require "fight/target_info/TargetInfo"

g_LoginFlowStepId = 0

function SaveLoginFlow(stepName)   ---��ʱ�鿨 5% bug �ӵĺ���
	if g_MyCharIdTemp == 100574 then
		LogErr("�ͻ��˵�¼����",  g_LoginFlowStepId .. "  " .. stepName)
		g_LoginFlowStepId = g_LoginFlowStepId + 1
	end
end

function CGameAccelerator:OnAccelerator( Msg, wParam, lParam )
	if( g_MainPlayer == nil ) then
		return false
	end
	if Msg == WM_MOUSEWHEEL then
		local MouseDelta=math.floor(wParam/65536)
				
		if MouseDelta > 32768 then
			MouseDelta = MouseDelta - 65536
		end
		
		RenderScene=g_CoreScene:GetRenderScene()
		
		local CamOffset = RenderScene:GetCameraOffset()
		
--		print("�z��C���x:"..tostring(CamOffset/EUnits.eGridSpan).."��")
		
		CamOffset = CamOffset - MouseDelta / 1.5
		
		RenderScene:SetCameraOffset( CamOffset )	
		
		return
	elseif Msg == WM_MOUSEMOVE then
		g_GameMain:OnTurnRunCamera(wParam, lParam)
	end
	if(Msg == WM_ACTIVATE) then
		g_GameMain.m_SysSetting.m_KPmap:ClearAllKeyTbl()
		g_GameMain.m_SysSetting.m_KPmap:MoveEndStep()
		UnShowAllName()
		g_GameMain:OnTurnRunCameraEnd()
		if g_MainPlayer and IsCppBound(g_MainPlayer) then
			g_MainPlayer:MoveOnTime_UnRegisterTick()
		end
	end
	if(Msg == WM_KEYDOWN or Msg == WM_SYSKEYDOWN) then
		g_GameMain.m_SysSetting.m_KPmap:AllKeySet(Msg,wParam)
	end
	if(Msg == WM_KEYUP or Msg == WM_SYSKEYUP) then
		g_GameMain.m_SysSetting.m_KPmap:AllKeySet(Msg,wParam)
	end

	return true
end

function CGameAccelerator:OnAcceleratorIsModule(Msg, wParam, lParam) --ģ̬���ڻص�
	g_GameMain.m_SysSetting.m_KPmap:ClearAllKeyTbl()
	g_GameMain.m_SysSetting.m_KPmap:MoveEndStep()
	--�����������
	if(GetFunctionNameByChar(wParam) == "StartChat()" and Msg == WM_KEYDOWN) then
		g_GameMain.m_SysSetting.m_KPmap:AllKeySet(Msg,wParam)
	end	
end

function CGameAccelerator:OnAcceleratorInEdit() --�����뽹��ʱ�Ļص�
	g_GameMain.m_SysSetting.m_KPmap:ClearAllKeyTbl()
	g_GameMain.m_SysSetting.m_KPmap:MoveEndStep()
end

function CGameMain:ReSetUIOnTransfered()
	if g_MainPlayer then
		--���°�
		if g_MainPlayer.m_NpcHeadUpDialog then
			g_MainPlayer:GetRenderObject():AddChild( g_MainPlayer.m_NpcHeadUpDialog, eLinkType.LT_SKELETAL, "Bip01 Head" )
		end
		g_GameMain.m_CharacterInSyncMgr:PlayerHeadInfoInit()	--����ͷ����Ϣ
		g_GameMain.m_TeamMarkSignMgr:PlayerHeadTeamMarkInit()	--���Ƕ�����
		g_MainPlayer:AddHeadBloodRendler(g_MainPlayer, g_GameMain.m_BloodRenderDialogPool, g_GameMain, g_GameMain.BloodRenderWndIsShow)
		g_GameMain.m_CharacterInSyncMgr:SetHeadBloodTransparentFun(g_MainPlayer,false)
		
		local bSet = g_MainPlayer:CppGetCtrlState(EFighterCtrlState.eFCS_InBattle)
		g_GameMain.m_PlayerInfo:FlashShow(bSet)
	end
	self:GameMainRegisterAccelerator()
end

function CGameMain:IsWndOpenState(Wnd)
	if Wnd and IsFunction(Wnd.IsShow)	and Wnd:IsShow() then
		return true
	else
		return false
	end
end

function CGameMain:ClearFrameBeginTransfer()--�����������,���½�ɫ���´���,Ҫ��տͻ���UI����
	g_WndMouse:ClearCursorSpecialState()
	self.m_skillProgress_Load:ShowWnd(false)
	if self.m_Buff then
		self.m_Buff:ClearAllBuffState() --��ɫ��buff�������
	end
	if self.m_TargetBuff then
		self.m_TargetBuff:ClearAllBuffState()
	end
	if self.m_TargetOfTargetBuff then
		self.m_TargetOfTargetBuff:ClearAllBuffState()
	end
	if self.m_ServantBuffWnd then
		self.m_ServantBuffWnd:ClearAllBuffState()
	end
	if self.m_BattleHorseBuffWnd then
		self.m_BattleHorseBuffWnd:ClearAllBuffState()
	end
	if self.m_Servant then
		self.m_Servant:ShowWnd(false)
	end
	if self.m_OrdnanceMonsterInfo then
		self.m_OrdnanceMonsterInfo:ShowWnd(false)
	end
	if self.m_CannonInfo then
		self.m_CannonInfo:ShowWnd(false)
	end
	if self.m_FbConfirmSecWnd then
		self.m_FbConfirmSecWnd:ShowWnd(false)
	end
	if self.m_FbConfirmWnd then
		self.m_FbConfirmWnd:ShowWnd(false)
	end
	if self.m_ConfirmWnd then
		self.m_ConfirmWnd:ShowWnd(false)
	end
	if self.m_GameDownTimeWnd then
		self.m_GameDownTimeWnd:ShowWnd(false)
	end
	self.m_SysSetting.m_KPmap:ClearAllKeyTbl()
	self.m_SysSetting.m_KPmap:MoveEndStep()
	--self.m_RoleStatus:ShowWnd(false)
	local PromptWnd = g_GameMain.m_GamePromptWnd
	if PromptWnd:IsShow() then
		PromptWnd:ShowWnd(false)
	end
	local StoneWnd = CStone.GetWnd()
	StoneWnd.StonePartUsing:Close()
	local FbGameStatisticsWnd = CFbGameStatisticsWnd.GetWnd()
	FbGameStatisticsWnd:Close()
	local JiFenSaiInfoWnd = CJiFenSaiInfoWnd.GetWnd()
	JiFenSaiInfoWnd:ShowWnd(false)
	if self.m_RobResourceWnd then
		self.m_RobResourceWnd:ShowWnd(false)
	end
	if self.m_SignQueryWnd then
		self.m_SignQueryWnd:ShowWnd(false)
	end
	if self.m_SpecialNpcWnd then 
		self.m_SpecialNpcWnd:ShowWnd(false)
	end
	if self.m_TongRobResExitWnd then
		self.m_TongRobResExitWnd:ShowWnd(false)
	end
	if self.m_TongRobResOverExit then
		self.m_TongRobResOverExit:ShowWnd(false)
	end
	if self.m_RobResCountDown then
		self.m_RobResCountDown:ShowWnd(false)
	end
	
	self.m_FbActionMgrWnd:ShowWnd(false)
	if self.m_WarTransportWnd then
		self.m_WarTransportWnd:ShowWnd(false)
	end
	if self:IsWndOpenState(self.m_MsgBox) then
		self.m_MsgBox:ShowWnd(false)
		self.m_MsgBox = nil
	end
	
	if self.m_PlayerManageWnd and self.m_PlayerManageWnd:IsShow() then
		self.m_PlayerManageWnd:ShowWnd(false)
	end
	--������ͷ�ϵı�����Ϣ
	self.m_NpcHeadSignMgr:ClearPlayerFace()
	
	--�г�����,�ر����д��ŵ����Զ��رչ��ܵĴ���
	CAutoCloseWnd.TransferCloseAutoCloseWnd()
	----------------------
	local DpsWnd = CDpsOutPutWnd.GetWnd()
	DpsWnd:ShowWnd(false)
	
	local StoneWnd = CStone.GetWnd()
	StoneWnd.StonePartUsing:Close()
	
	if self.m_ChangeOutMsgBox then
		self.m_ChangeOutMsgBox:Close()
		self.m_ChangeOutMsgBox = nil
	end
	
	if self:IsWndOpenState(self.m_AreaFbDeadMsgBox) then
		self.m_AreaFbDeadMsgBox:HideWnd()
	end
	
	if self:IsWndOpenState(self.m_RobResDeadMsgBox) then
		self.m_RobResDeadMsgBox:HideWnd()
	end
	
	
	if self:IsWndOpenState(self.m_WarDeadMsgBox) then
		self.m_WarDeadMsgBox:HideWnd()
	end
	
	if self:IsWndOpenState(self.m_ChallengeDeadMsgBox) then
		self.m_ChallengeDeadMsgBox:HideWnd()
	end
	
	if self:IsWndOpenState(self.m_FBDeadMsgBox) then
		self.m_FBDeadMsgBox:HideWnd()
	end
	
	if self:IsWndOpenState(self.m_TeamPVPFBDeadMsgBox) then
		self.m_TeamPVPFBDeadMsgBox:HideWnd()
	end
	
	if self:IsWndOpenState(self.m_OldWarDeadWnd) then
		self.m_OldWarDeadWnd:HideWnd()
	end
	
	if self.m_AreaInfoWnd then
		self.m_AreaInfoWnd.m_IsGetWarZoneState = false
		self.m_AreaInfoWnd.m_WarZoneState = nil
		if IsFunction(self.m_AreaInfoWnd.IsShow) and self.m_AreaInfoWnd:IsShow() then
			self.m_AreaInfoWnd:CloseAreaInfoWnd()
		end
	end
	
	if IsCppBound(g_MainPlayer) then
		g_MainPlayer:DelHeadBloodRendler(g_GameMain.m_BloodRenderDialogPool)
		PopNpcHeadUpDialog(g_MainPlayer)
		--�г�����ر�ѡ���ŵĶ���
		g_MainPlayer:UnLockTarget()
	end
	
	--�ر��������
	if self:IsWndOpenState(self.m_AreaInfoWnd) then
		self.m_AreaInfoWnd:CloseAreaInfoWnd()
	end

	if g_MainPlayer and g_MainPlayer.HeadFishingTick then
		EndHeadFishing()
	end
	if g_MainPlayer and g_MainPlayer.HeadHuntTick then
		EndHeadHunt()
	end
	
	if g_GameMain.m_ShootProgressWnd.m_Tick then
		g_GameMain.m_ShootProgressWnd:EndShoot()
	end
	
	g_GameMain.m_PlayersTradeWnd:CloseTradeInvitationWnd()
	g_GameMain.m_PlayersTradeRequestWndInGameMain:ShowWnd(false)
end

function CGameMain:EndTransfer()
	if g_GameMain.m_PrepareChangeTick then
		UnRegisterTick(self.m_PrepareChangeTick)
		g_GameMain.m_PrepareChangeTick = nil
	end
	self:ReSetUIOnTransfered()
	self.m_NavigationMap:UpdatePlayerPosInSmallMap()
	if not g_App.m_Loading:IsShow() then
		IsSpanSceneAutoTrackState()
	end
	self.m_IsTransfer = false
	g_MainPlayer:MoveOnTime_UnRegisterTick()
	NotifyChangeScene()
end

function CGameMain:GameMainRegisterAccelerator()
	if self.m_KeyAccelerator.GMain == nil then
		SQRWnd_RegisterAccelerator( self.m_KeyAccelerator, WM_SYSKEYDOWN )
		SQRWnd_RegisterAccelerator( self.m_KeyAccelerator, WM_SYSKEYUP )
		SQRWnd_RegisterAccelerator( self.m_KeyAccelerator, WM_ACTIVATE )
		SQRWnd_RegisterAccelerator( self.m_KeyAccelerator, WM_KEYDOWN )
		SQRWnd_RegisterAccelerator( self.m_KeyAccelerator, WM_KEYUP )
		SQRWnd_RegisterAccelerator( self.m_KeyAccelerator, WM_MOUSEWHEEL )
		SQRWnd_RegisterAccelerator( self.m_KeyAccelerator, WM_MOUSEMOVE )
		self.m_KeyAccelerator.GMain	= self
	else
--		print("�ظ�RegisterAccelerator������")
	end
end

function CGameMain:GameMainUnRegisterAccelerator()
	SQRWnd_UnRegisterAccelerator( self.m_KeyAccelerator )
	self.m_KeyAccelerator.GMain = nil
end

local ShowInitWndTrueTotalTime = 1500 --��λΪ����
local InitWndTransparentScale = 0.1
local function ShowInitWndSlowly()
	local wnd = g_GameMain
	wnd.m_MainSkillsToolBar:SetTransparent(InitWndTransparentScale)	--���ܿ����
	wnd.m_SmallMapBG:SetTransparent(InitWndTransparentScale)
	wnd.m_NavigationMap:SetTransparent(InitWndTransparentScale)
	wnd.m_PlayerInfo:SetTransparent(InitWndTransparentScale)
	wnd.m_ExpBar:SetTransparent(InitWndTransparentScale)
	wnd.m_CreateChatWnd.m_CChatWnd:SetTransparent(InitWndTransparentScale)
	wnd.m_QuestTraceBack:SetTransparent(InitWndTransparentScale)
	wnd.m_MainSkillsToolBar:SetTransparentObj(ShowInitWndTrueTotalTime,false)	--���ܿ����
	wnd.m_SmallMapBG:SetTransparentObj(ShowInitWndTrueTotalTime,false)
	wnd.m_NavigationMap:SetTransparentObj(ShowInitWndTrueTotalTime,false)
	wnd.m_PlayerInfo:SetTransparentObj(ShowInitWndTrueTotalTime,false)
	wnd.m_ExpBar:SetTransparentObj(ShowInitWndTrueTotalTime,false)
	wnd.m_CreateChatWnd.m_CChatWnd:SetTransparentObj(ShowInitWndTrueTotalTime,false)
	wnd.m_QuestTraceBack:SetTransparentObj(ShowInitWndTrueTotalTime,false)
end

--�Ƿ����½���ɫ������Ϸ�������������촰�ڡ�ս����Ϣ���ڡ�С��ͼ���Ƿ���ʾ
--Ϊ�˷�ֹ������Ϸ�����⼸��������ʾ���أ����Բ��ʹ���ĺ���������ShowWndIgnTex
function CGameMain:ShowInitWndOrNot( showOrNot)
	self.m_MainSkillsToolBar:ShowWndIgnTex(showOrNot)	--���ܿ����
	self.m_SmallMapBG:ShowWndIgnTex(showOrNot)
	self.m_NavigationMap:ShowWndIgnTex(showOrNot)
	self.m_PlayerInfo:ShowWndIgnTex(showOrNot)
	self.m_ExpBar:ShowWndIgnTex(showOrNot)
	self.m_CreateChatWnd.m_CChatWnd:ShowWndIgnTex(showOrNot)
	self.m_QuestTraceBack:ShowWndIgnTex(showOrNot)
	if showOrNot == true then	
		ShowInitWndSlowly()
	end
end

function CGameMain:OnInit()
	CppGameClientInit()
	-- ��ʼ��Entity Manager Handler
	g_GameEntityMgrHandler = CEntityClientMgrHandler:new()
	CEntityClientManager_GetInst():SetHandler(g_GameEntityMgrHandler)

	local nWidth = g_App:GetRootWnd():GetWndWidth()
	local nHeight = g_App:GetRootWnd():GetWndHeight()
	
	local param = WndCreateParam:new()
	param.uStyle = 0x40000000
	param.width = 1024
	param.height = 768
	param:SetParentWnd(g_App:GetRootWnd())
	param.font_size = 12
	self:Create( param )--"I'm GameMain"
	self:SetLockFlag( BitOr( LOCK_LEFT, LOCK_RIGHT, LOCK_TOP, LOCK_BOTTOM ) )
	local Image = WND_IMAGE_LIST:new()
	local Flag = IMAGE_PARAM:new()
	Flag.CtrlMask = SM_BS_BK
	Flag.StateMask = IP_ENABLE
	self:SetWndBkImage( Flag, Image )
	self:ShowWnd( false )
	--***************************************************
	self.m_DisplayCommonObj = CDisplayCommon:new()
	_,self.m_SelectObjTooltips = apcall(CreateSelectObjTooltips,self) --����ToopTips
	
	apcall(self.InitTaskWnd,self)
	--***************************************************
	--һ��������ö�Ų������(����ͷ��Ŀ��ͷ���ٻ���ͷ��С��ͷ��С��ͼ�����ܿ����������򡢾����������ܲ˵���)
	_,self.m_MainSkillsToolBar		= apcall(CreateMainSkillsToolBar,self)				--���ܿ����
	_,self.m_MasterSkillArea		= apcall(CreateMasterSkillArea, self, 2)			--���������
	_,self.m_AddMasterSkillArea		= apcall(CreateMasterSkillArea, self, 3)			--���������
	_,self.m_PlayerCore				= apcall(CreatePlayerCoreInfo,self)					--����ͷ������
	_,self.m_PlayerInfo				= apcall(CreatePlayerInfo,self)						--����ͷ��
	_,self.m_TargetCore				= apcall(CreateTargetCoreInfo,self)					--Ŀ��ͷ������
	_,self.m_TargetInfo				= apcall(CreateTargetInfo,self)						--Ŀ��ͷ��
	_,self.m_TargetOfTargetInfo		= apcall(CreateTargetOfTargetInfo,self)				--Ŀ���Ŀ��ͷ��
	_,self.m_CreateChatWnd			= apcall(CreateChatWnd,self)						--����ϵͳ
	self.m_SmallMapBG				= CSmallMapBG:new(self)								--С��ͼ�߿�
	self.m_NavigationMap			= CSmallMapWnd:new(self)							--С��ͼ��ʾ
	_,self.m_BurstSoulWnd			= apcall(CreatBurstSoulWnd,self.m_MainSkillsToolBar)--������
	_,self.m_ExpBar					= apcall(CreateExpBar,self.m_MainSkillsToolBar)		--������
	_,self.m_GuideBtn				= apcall(CGuideBtn.new, CGuideBtn, self)
	------------------------------------------------------
	--׼һ������
	_,self.m_PanelMenu				= apcall(CreatePanelMenu, self)
	apcall(self.InitTeam, self)			--��ʼ��С��
	--***************************************************

	self.m_KeyAccelerator 	= CGameAccelerator:new()
	
	--Npc�Ի��򴰿�
	_,self.m_NpcDlg = apcall(CreateNpcDlg,self)
	_,self.m_NpcDlgCopy = apcall(CreateNpcDlgCopy,self)
	
	--Npc�����Ի�����
	_, self.m_NpcTalkWnd = apcall( CNpcTalkWnd.new, CNpcTalkWnd )
	_, self.m_AreaFbSelWndNew = apcall( CAreaFbSelWndNew.new, CAreaFbSelWndNew )
	--����Npc����
	--self.m_SpecialNpcWnd = CreateSpecialNpcWnd(self)
	
	--����ϵͳ���
	--_,self.m_AreaInfoWnd    	= apcall(CreateAreaInfoWnd,self)
	_, self.m_AreaInfoWnd = apcall(CAreaInfoWnd.new, CAreaInfoWnd)
	_, self.m_GamePromptWnd = apcall(CGamePromptWnd.new, CGamePromptWnd)
	
	--��һ�ν�������ʱ����������������
	_,self.m_AreaIntroductionWnd = apcall(CreateAreaIntroductionWnd,self)
	
	--���а񴰿�
	_,self.m_SortListWnd 	= apcall(CSortList.new, CSortList)
	
	self:InitEmail()	--�ʼ�
	self:InitCommerce()	--��ҵ��ϵͳ
	
	--��Ʒʰȡ����
	_,self.m_PickupItemWnd = apcall(CreatePickupItemWnd,self)
	
	--��ұ�bug����
	gac_require "message/UserAdvice/UserAdvice"
	_,self.m_UserAdviceWnd = apcall(CUserAdviceWnd.CreateUserAdviceWnd,self)
	
	--��Ʒʰȡ������ģʽ����
	self.m_AcutionAssignTbls = {}
	--������䷽ʽ�Ĵ��ڿɵ������
	self.m_NeedAssignTbls = {}
	
	--����������������ʾ
	_,self.m_skillProgress_Load = apcall(CreateSkillLoading,self)
	
	--����ͷ��ð�ݴ��ڳ�
	_,self.m_NpcHeadUpDialogTbl = apcall(SaveNpcHeadUpDialog)	
	
	--��ɫ��Ϣ
	_,self.m_PlayerManageWnd 		= apcall(CPlayerManageWnd.new,CPlayerManageWnd)
	_,self.m_AimPlayerManageWnd 	= apcall(CAimPlayerManageWnd.new,CAimPlayerManageWnd)
	_,self.m_AimStatusWnd			= apcall(CAimStatus.new,CAimStatus)
	_,self.m_RoleStatus				= apcall(CPlayerStatus.new,CPlayerStatus)
	_,self.m_PlayerFightInfoWnd 	= apcall(CreatePlayerFightInfoWnd,self )
	self.m_FightingEvaluationWnd 	= CFightingEvaluation:new()
	_,self.m_JiFenDetailWnd	 		= apcall(CJiFenWnd.new,CJiFenWnd)
	self.m_AimFightingEvaluationWnd = CAimFightingEvaluation:new()
	self.FollowerTbl = {}
	
	
	--���̽���
	_,self.m_turntable = apcall(turntableCreate,self ) 
		
	--װ��������ǿ��
	_,self.m_EquipUpIntensifyWnd = apcall(CEquipUpIntensify.new,CEquipUpIntensify)
	
	
	--��ʼ��������ʾ���
	apcall(self.InitComboHitsWnd,self)
	
	--����ϵͳ
	_,self.m_SelectSeriesWnd = apcall(CSelectSeriesWnd.new,CSelectSeriesWnd)
	_,self.m_NpcSkillLearnWnd = apcall(CNpcSkillLearnWnd.new,CNpcSkillLearnWnd)
	_,self.m_CommonSkillWnd = apcall(CCommonSkillWnd.new,CCommonSkillWnd)
	_,self.m_SkillJingLingWnd = apcall(CSkillJingLingWnd.new,CSkillJingLingWnd)
	_,self.m_CreateTalentSkillPartWnd = apcall(CTalentSkillPartWnd.new,CTalentSkillPartWnd)
	_,self.m_LearnCommonSkillWnd = apcall(CLearnCommonSkillWnd.new,CLearnCommonSkillWnd)
	_,self.m_LeadLeanSkillWnd = apcall(CLeadLeanSkillWnd.new,CLeadLeanSkillWnd)
	_,self.m_LeadLeanSkillShowWnd = apcall(CLeadLeanSkillShowWnd.new,CLeadLeanSkillShowWnd)
	
	_,self.m_ShowSkillDescWnd = apcall(CTalentSkillDescWnd.new,CTalentSkillDescWnd)
	
	--��ʱ����
	_,self.m_TempSkill = apcall(CreateTempSkill,self)
	
	apcall(self.InitTong,self)			--��ʼ�����
	apcall(self.InitAssociation,self)	--��ʼ����Ⱥ
	apcall(self.InitLiveSkill,self)		--��ʼ�������
	
	InitShowWndFun()
	--ͷ����Ϣ
	self.m_CharacterInViewMgr = CCharacterInViewMgr:new()
	self.m_CharacterInSyncMgr = CCharacterInSyncMgr:new()
	--������
	self.m_TeamMarkSignMgr = CTeamMarkSignMgr:new()
	
	--����Npc��Obj ͷ����־��Ϣ 
	_,self.m_NpcHeadSignMgr = apcall(CreateNpcHeadSignWndTbl,self)
	--���Խ��вɼ���Obj����ʾ����
	_,self.m_CollObjWnd = apcall(CCollObjShowWnd.new, CCollObjShowWnd)
	--��������ϵͳ�õĽ�����
	_,self.m_ProgressBarWnd = apcall(CProgressBarWnd.new, CProgressBarWnd)
	_,self.m_NormalProgressBarWnd = apcall(CNormalProgressBarWnd.new, CNormalProgressBarWnd)
	_,self.m_ResourceProgressWnd = apcall(CNormalProgressBarWnd.new, CNormalProgressBarWnd)
	_,self.m_UseItemProgressWnd = apcall(CUseItemProgressWnd.new, CUseItemProgressWnd) 
	_,self.m_SandGlassWnd = apcall(CSandGlassWnd.new, CSandGlassWnd) 
	
	--Pk����
	
	self.m_PkSwitchWnd = CPkSwitch:new(g_GameMain)
	--_,self.m_PkSwitchWnd = apcall(CreatePkSwitch,self)

	--���ս��ش���
	_,self.m_WarZoneSelWnd = apcall(CreateWarZoneSelWnd,self)
	
	--�������
	_,self.m_WndAction = apcall(CreatePlayerActionWnd,self)
	
	_,self.m_TextItemWnd = apcall(CreateTextItemWnd,self) --�ı���Ʒ�Ķ�����
	
	--���ⴰ��
	--_,self.m_EssayQuestionWnd = apcall(CreateEssayQuestionWnd,self)
	
	_,self.m_DirectShowWnd = apcall(CreateDirectShowWnd,self)
	
	--С�����Ƿ���Ϣ��ʾ��
	_,self.m_MatchGameWnd = apcall(CMatchGameCountWnd.new, CMatchGameCountWnd)
	_,self.m_MatchGameSelWnd = apcall(CMatchGameSelWnd.new, CMatchGameSelWnd)
	--ָ�������
	_,self.m_ChallengeCompass = apcall(CChallengeCompass.new, CChallengeCompass)
	--��ս����Ϊ������
	_,self.m_XLProgressWnd = apcall(CXLProgressWnd.new, CXLProgressWnd)
	_,self.m_AuctionBasePriceWnd = apcall(CChangeAuctionBasePrice.new, CChangeAuctionBasePrice)
		
	--װ���趨������������ʾ����
	_,self.m_EquipEnactmentAttrWnd = apcall(CArmorPieceEnactment.new,CArmorPieceEnactment)
	
	self.m_BloodRenderDialogPool = CBloodRenderDialogPool:new()
	self.m_BloodRenderDialogPool:CreatePool(self)
	
	apcall(self.InitSmallGamesWnd,self)		--��ʼ��С��Ϸ
	apcall(self.InitFbActionWnd,self)		--��ʼ�������淨
	apcall(self.InitPlayerBag,self)			--��ʼ������
	apcall(self.PlayerDead,self)			--��ʼ���������
	apcall(self.InitMercenaryWnd,self)		--��ʼӶ����Ϣ����
	
	_,self.m_NonFightSkillWnd = apcall(CNonFightSkill.new,CNonFightSkill) 		--��ʼ����ս���������
	_,self.m_NetworkDelayTimeWnd = apcall(CreateNetworkDelayTimeWnd,self)		--��ʼ����ʾ����״̬���
	self.m_NetworkDelayTimeTick = RegisterTick("GetDelayTime", GetDelayTime , 15000)	-- C++����15�����һ����ʱ��û��Ҫ��ô��ʱ����ˢ
	
	_,self.m_SystemMsgInfo = apcall(CreateSystemMsgInfo,self)
	_,self.m_SystemMsgWnd = apcall(CreateSystemMsgWnd,self)
	
	_,self.m_AppellationAndMoralWnd = apcall(CAppellationAndMoralWnd.new,CAppellationAndMoralWnd)

	_,self.m_HidePlayerWnd = apcall(CreateHidePlayerWnd,self)
	_,self.m_HidePlayerExceptTeammateWnd = apcall(CreateHidePlayerExceptTeammateWnd,self)
	
	_,self.m_GMConsole	= apcall(CreateGMConsole,self)			--GM���
	_,self.m_SysSetting	= apcall(CSystemSettingParent.new,CSystemSettingParent)	--ϵͳ����
	_,self.m_ExitGame		= apcall(CExitGame.new, CExitGame)			--�˳���Ϸ
	
	self.m_EquipDuraWnd = CEquipDuraWnd:new() --װ���;ô���
--	self.m_FixEquipWnd = CFixEquipWnd:new()
	self.m_NewFixEquipWnd = CNewFixEquipWnd:new()
	_,self.m_CEquipInRoleWnd = apcall(CEquipInRoleWnd.new,CEquipInRoleWnd)
	_,self.m_CEquipInBagWnd = apcall(CEquipInBagWnd.new,CEquipInBagWnd)
	_,self.m_FlashMsgWnd = apcall(CFlashMsgWnd.new, CFlashMsgWnd)
	_,self.m_BagShapeEffectWnd = apcall(CreateBagShapeEffectWnd, self)
	_,self.m_FlashSkillMsgWnd = apcall(CFlashSkillMsgWnd.new, CFlashSkillMsgWnd)
	_,self.m_ToolsMallWnd = apcall(CToolsMallMainWnd.new, CToolsMallMainWnd)
	_,self.m_ToolsMallBuyWnd = apcall(CToolsMallBuyWnd.new, CToolsMallBuyWnd)
	_,self.m_ToolsMallGiveItemWnd = apcall(CToolsMallGiveItemWnd.new, CToolsMallGiveItemWnd)
	_,self.m_MessageShapeEffectWnd = apcall(CMessageShapeEffectWnd.new,CMessageShapeEffectWnd)
	_,self.m_MessageShapeEffectSecondWnd =  apcall(CMessageShapeEffectSecondWnd.new,CMessageShapeEffectSecondWnd)
	_,self.m_MessageMiniTextWnd = apcall(CMessageMiniTextWnd.new,CMessageMiniTextWnd)
	
	_,self.m_DirectWnd			= apcall(CreateDirectWnd, self)
	_,self.m_PetInfoWnd			= apcall(CreatePetInfoWnd, self)
	
	self:InitTeamList()
	self.m_HideFollowerMgr = CHideFollowerMgr:new()
	
	self.m_TransportTrap = {} --�渽���ɴ��͵�trap
	
	
	_, self.m_EquipSuperaddWnd = apcall(CEquipSuperaddWnd.new, CEquipSuperaddWnd)

	_,self.m_ContractManufactureMarketWnd  = apcall(CContractManufactureMarketWnd.new, CContractManufactureMarketWnd)
	
	_,self.m_IdentityAffirmWnd = apcall(CIdentityAffirmWnd.new,CIdentityAffirmWnd)
	
	_,self.m_ItemBagLockWnd = apcall(CItemBagLockWnd.new,CItemBagLockWnd)
	
	_,self.m_ItemBagTimeLockWnd = apcall(CItemBagTimeLockWnd.new,CItemBagTimeLockWnd)
	self:InitGuide()
	self:InitMessageWnd()				--��ʼ����ʾ�����
	
----------------------------------------------------------------------------------------
	if g_App.m_re ~= EGameState.eToNewRoleGameMain then 	--�Ǵ����½�ɫʱ
		self:GameMainRegisterAccelerator()
	else
		self:ShowInitWndOrNot(false)
	end
	
	--�����ת���������
	self.FreedomCameraCtrl = false
	self.m_NetDelayImageFlag = 0	--������ʱ��ͼ��ʶ
	
	
----------------------------------------------------------------------------------------
	g_App.m_Loading:SetPos(5)
	
	SaveLoginFlow("GameMain:OnInit")
end

function CGameMain:InitGuide()
	_,self.m_GuideData	= apcall(CGuideData.new, CGuideData)
	_,self.m_GuideWnd	= apcall(CGuide.new, CGuide)
end

--��ʾ��Ϣ����嶼�ŵ�����
function CGameMain:InitMessageWnd()
	_,self.m_MsgListParentWnd	= apcall(CreateMsgListParentWnd, self)
	_,self.m_SystemFriendMsgBox	= apcall(CSystemFriendMsgBox.new, CSystemFriendMsgBox)
	_,self.m_CenterMsg			= apcall(CCenterMsg.new, CCenterMsg)
end

--�ʼ�
function CGameMain:InitEmail()
	_,self.m_EmailBox		= apcall(CEmailBoxWnd.new,CEmailBoxWnd)	--�ʼ�ϵͳ����
	_,self.m_SendBox		= apcall(CSendEmailWnd.new,CSendEmailWnd)	--�����䴰��
	_,self.m_ReceiveBox		= apcall(CGetEmailWnd.new,CGetEmailWnd)	--�ռ��䴰��
end

--��ҵ�ര��
function CGameMain:InitCommerce()
	--���Ҷһ�����
	_,self.m_Agiotage = apcall(CAgiotage.new,CAgiotage)
	--NPC�̵깺�ش���
	
	--gm��������
	_,self.m_GmActivity = apcall(CGMActivityWnd.new,CGMActivityWnd)
	_,self.m_GmCompensateItemWnd = apcall(CGMCompensateWnd.new,CGMCompensateWnd)
	
	_,self.m_NPCShopPlayerSold 	= apcall(CNPCShopPlayerSoldWnd.new,CNPCShopPlayerSoldWnd)
	--NPC�̵깺�򴰿�
	
	_,self.m_NPCShopSell = apcall(CNPCShopSellWnd.new,CNPCShopSellWnd)
	self.m_NPCShopSell.m_NPCShopGoodsList = {}
	--��ҽ��״���
	
	_,self.m_PlayersTradeWnd = apcall(CPlayersTradeWnd.new,CPlayersTradeWnd)
	--��ҽ�������btn
	_,self.m_PlayersTradeRequestWndInGameMain = apcall(CTradeRequestTipsWnd.new, CTradeRequestTipsWnd)
	--���۽���������
	
	_,self.m_CSMSellOrderWnd = apcall(CConsignmentSellListWnd.new,CConsignmentSellListWnd)

	_,self.m_CSMSellOrderWnd.TreeListMap = apcall(CConsignmentTreeListMap.CreateCSMTreeListMap)
	self.m_CSMSellOrderWnd:CheckCSMTreeListInfoValidate(self.m_CSMSellOrderWnd.m_TreeDataInPro)
	
	_,self.m_BuyCouponsWnd = apcall(CBuyCouponsWnd.new, CBuyCouponsWnd)
end

--Ѱ�����
function CGameMain:InitTeamList()
	gac_require "relation/team/TeamClientList"
	gac_require "relation/team/TeamClientListOneItem"
	_,self.m_TeamAppUnderList	= apcall(CreateTeamListUnderWnd, self)
	_,self.m_TeamAppActList		= apcall(CreateTeamListActWnd, self)
	_,self.m_TeamAppTaskList	= apcall(CreateTeamListTaskWnd, self)
	_,self.m_TeamListOneItem	= apcall(CreatTeamListOneItemWnd, self)  
	_,self.m_TeamApplicationListMini = apcall(CreateTeamListMiniWnd, self)
	
end

--Ӷ��ָ�����ܴ���
function CGameMain:InitMercenaryWnd()
	_, self.m_MercenaryLevelTrace = apcall( CMercenaryLevelTrace.new, CMercenaryLevelTrace )
	--_, self.m_MercenaryLevelAward = apcall( CMercenaryLevelAward.new, CMercenaryLevelAward )
	--_, self.m_MercenaryAssess = apcall( CYbAssessWnd.new, CYbAssessWnd )
	--Ӷ��ָ������־����
	_, self.m_InformationWnd = apcall( CInformationWnd.new, CInformationWnd )
	_, self.m_MercenaryDirWnd = apcall( CYBDirTempFxWnd.new, CYBDirTempFxWnd )
end

--С��Ϸ
function CGameMain:InitSmallGamesWnd()
	--С��Ϸʹ��
	self.m_ProgressWnd = CreateProgressWnd(self)
	--�Ե粨С��Ϸ
	self.m_HeadProgressWnd = CreateHeadProgressWnd(self)
	--�����Ʒ���ҩ(ˮ��)С��Ϸ
	self.m_GetHorseMedicine = CreateGetMedicineWnd(self)
	--�͵�³������̸̸С��Ϸ
	self.m_ClickPicWnd = CreateClickPicWnd(self)
	--�������������������
	self.m_CRideCamelWnd = CreateRideCamelWnd(self)
	
	--С��Ϸ������
	self.m_SmallGemeMsgWnd = CreateSmallGameMsgWnd(self)
	self.m_SGMgr = CreatSmallGame()
	self.m_SmallGame = nil    --m_SmallGame = nil ������״̬    m_SmallGame = "��Ϸ��" ��С��Ϸ״̬
end

--�����淨
function CGameMain:InitFbActionWnd()
	if not self.m_FbActionTick then
		self.m_FbActionTick = {}
	end
	if not self.m_FbActionMsgWnd then
		self.m_FbActionMsgWnd = {}
	end
	if not self.m_AreaFbMsgWnd then
		self.m_AreaFbMsgWnd = {}
	end
	
	--�ư���Ϸ����
	self.m_DrinkWnd = CreateDrinkWnd(self)
	
	--�����սͳ�ƴ���
	self.m_TongChallengeStatisticsWnd = CreateTongChallengeStatisticsWnd(self)
	self.m_TongBattlePersonalCountWnd = CreateTongBattlePersonalCountWnd(self)
	self.m_TongWarExitBtnWnd = CreateTongWarExitBtnWnd(self)
	self.m_TongWarBattleCountWnd = CreateTongWarBattleCountWnd(self)
	self.m_TongChallengeExitBtnWnd = CreateTongChallengeExitBtnWnd(self)
	self.m_TongChallengeBattleCountWnd = CreateTongChallengeBattleCountWnd(self)
	self.m_TongMonsAttackCountWnd = CreateTongMonsAttackCountWnd(self)
	self.m_TongMonsAttackExitBtnWnd = CreateTongMonsAttackExitBtnWnd(self)
	self.m_TongDownTimeWnd = CreateTongDownTimeWnd(self)
	--Ӷ��ѵ���
	_, self.m_YbEducateActionWnd = apcall(CYbEducateActionWnd.new, CYbEducateActionWnd)
	_, self.m_YbEducateActInfoWnd = apcall(CYbEducateActionInfoWnd.new, CYbEducateActionInfoWnd)
	_, self.m_YbEducateActAwardWnd = apcall(CYbEducateActionAwardWnd.new, CYbEducateActionAwardWnd)

	_, self.m_YbMercCardBagWnd = apcall(CMercCardBagWnd.new, CMercCardBagWnd) --CMercCardBagWnd:new()
	
	--Ӷ����ˢ�ֱ�
	self.m_MercenaryMonsterFbWnd = CreateMercenaryMonsterFbWnd(self)
	
	--Boss����ս
	_, self.m_BossBattleWnd = apcall(CBossBattleWnd.new, CBossBattleWnd)
	
	--��Ѩ�����
	_, self.m_DragonCaveWnd = apcall( CDragonCaveWnd.new, CDragonCaveWnd)
	
	--�Ⱦ��������
	_, self.m_ShootProgressWnd = apcall(CShootProgressWnd.new, CShootProgressWnd)
	
	--�����в�����ʾ�Ĵ���
	CreateFbActionScoreWnd(self)
	--�����е���Ϣ���
	self.m_FbActionMgrWnd = CreateFbActionMgrWnd(self)
	_,self.m_EquipRefineWnd = apcall(CEquipRefine.new, CEquipRefine)
	
	--����ʱ����
	_, self.m_DownTimeWnd = apcall(CDownTimeWnd.new, CDownTimeWnd)
	_, self.m_GameDownTimeWnd = apcall(CCountdown.new, CCountdown)
	
end

--����
function CGameMain:InitTaskWnd()
	_, self.m_FbActionPanel = apcall(CFbActionPanelWnd.new, CFbActionPanelWnd) --���Ϣ����
	
	_, self.m_takeTask = apcall( CTakeTaskWnd.new, CTakeTaskWnd )	--�����ȡ����
	_, self.m_finishTask = apcall( CFinishTaskWnd.new, CFinishTaskWnd )	--���񽻸�����
	self.m_QuestTraceBack = CreateQuestTraceBack(self) --����׷�ٴ���
	self.m_QuestTraceBack:ShowWnd(true)
	self.m_QuestRecordWnd = CreateQuestRecordWnd(self) --�����¼���
	self.m_HandBookWnd = CHandBookWnd:new() --Ӷ���ֲ�
	_, self.m_QihunjiZhiyinWnd = apcall( CQihunjiZhiyinWnd.new, CQihunjiZhiyinWnd )	--�����ָ������
	_, self.m_HeadHelpWnd = apcall( CHeadHelpWnd.new, CHeadHelpWnd )	--���ְ�������
end

--����
function CGameMain:InitPlayerBag()
	--��ʼ�������������������ֿ������
	self.m_MainItemBag = CWndItemMainBag:new()
	self.m_MainItemBag:InitBagRoom( self )
	--��ʼ�������������������еĸ���
	self.m_MainItemBag:InitBagGrids()
	_, self.m_Depot = apcall(CDepot.new, CDepot)
end

--�����
function CGameMain:InitLiveSkill()
	self.m_LiveSkillExpertNPC	= CreateLiveSkillExpertNPCWnd(self)	--ѧϰ����ר����NPC���
	gac_require "resource/LiveSkillMain"
	self.m_LiveSkillMainWnd		= CreateLiveSkillMainWnd(self)
	self.m_LiveSkillProdMain	= CreateLiveSkillProdMainWnd(self)	--����������(���д�����2�������)
	_,self.m_LiveSkillFlower	= apcall(CFlowerWnd.new, CFlowerWnd)
	_,self.m_FlowerMiniWnd		= apcall(CFlowerMiniWnd.new, CFlowerMiniWnd)
end

--С��
function CGameMain:InitTeam()
	local firstX	= 180
	local dis		= 60
	self.m_TeamBase			= CreateTeamBase(self)
	self.m_tblTeamMsgBtn	= {}
	self.m_tblTeamIcons		= {}
	
	for i = 1, 4 do
		self.m_tblTeamMsgBtn[i]				= CreateTeamMsgBtn(self)
		self.m_tblTeamIcons[i]				= CreateTeamIcon(self.m_tblTeamMsgBtn[i])
		self.m_tblTeamIcons[i].m_BuffWnd	= CTeammateBuff:new(self.m_tblTeamIcons[i])
		self.m_tblTeamMsgBtn[i].m_TeamIcon	= self.m_tblTeamIcons[i]
		self.m_tblTeamMsgBtn[i]:SetPos(nil, (firstX + i*dis))
	end
end

--Ӷ����
function CGameMain:InitTong()
	self.m_TongBase		= CreateTongBase(self)			--Ӷ��С�ӻ���
	self.m_TongMainPan	= CTongMainPanWnd:new()			--Ӷ��С�������
	self.m_TongDepot	= CTongDepotWnd:new()			--Ӷ��С�Ӳֿ�
	self.m_TongScience	= CTongScienceWnd:new()			--Ӷ��С�ӿƼ�
	self.m_TongLearnScience = CTongLearnScience:new()	--Ӷ��С�ӿƼ�����ѧϰ
	
--	self.m_TongRobResourceWnd = CreateRobResourceWnd(self)  
--	self.m_TongSignQueryWnd = CreateSignQueryWnd(self)
--	self.m_TongRobResExitWnd = CreateTongRobResExitWnd(self)
--	self.m_TongRobResOverExit = CreateTongRobResOverExit(self)
end

--��Ⱥ
function CGameMain:InitAssociation()
	self.m_AssociationBase			= CreateAssociationBase()
	self.m_AssociationWnd			= CreateAssociationWnd(self)
	self.m_AssociationFindWnd		= CreateAssociationFindWnd(self)
	self.m_tblAssociationPriChat	= {}
	self.m_tblAssociationPubChat	= {}
	self.m_tblPerInfoShowWnd		= {}
	self.m_tblAddToClassCB			= {}
end

--��ʼ��������ʾ���
function CGameMain:InitComboHitsWnd()
	self.m_ComboHitsWndTbl = {}
	self.ComboHitsInfo = {}
	self.ComboHitsInfo.m_IsCrazyState = false
	for i = 1, 3 do 	
		table.insert(self.m_ComboHitsWndTbl,CComboHitsWnd:new())
	end
	_,self.m_ComboHitsRectWnd = apcall(CComboHitsWnd.new,CComboHitsWnd)
end

--�������
function CGameMain:PlayerDead()
	self.m_ToDeadMsgBox = CWndDeadMsg:new()
	self.m_AreaFbDeadMsgBox = CAreaFbDeadMsgWnd:new()
	self.m_FBDeadMsgBox = CFBDeadMsgWnd:new()
	self.m_TeamPVPFBDeadMsgBox = CTeamPVPFBDeadMsgWnd:new()
	self.m_WarDeadMsgBox = CWarDeadMsgWnd:new()
	self.m_ChallengeDeadMsgBox = CChallengeDeadMsgWnd:new()
	self.m_RobResDeadMsgBox = CRobResDeadMsgWnd:new()
end
--**********************************************************************************************

function CGameMain:RemoveFile()
	--self.m_AssociationBase:RemoveChatRecord()
end

function CGameMain:OnExit()
	-- ע��Character Manager Handler
	CEntityClientManager_GetInst():SetHandler(nil)
	g_GameEntityMgrHandler = nil
	-- ע��Intobj Manager Handler
--	CIntObjClientManager_Get():SetHandler(nil)
--	g_IntObjMgrHandler = nil

	self:UnRegisterTickOnDestroyGameMain() --ע��Tick
	self.m_CharacterInSyncMgr:CloseFollowerHeadInfoWnd()
	g_WndMouse:ClearCursorSpecialState()
	
	self:DestroyWnd()
	self:RemoveFile()
	g_ExcludeWndMgr:Clear()
	
	self.m_MainSkillsToolBar		= nil
	self.m_MasterSkillArea			= nil
	self.m_AddMasterSkillArea		= nil
	self.m_PlayerCore				= nil
	self.m_PlayerInfo				= nil
	self.m_TargetCore				= nil
	self.m_TargetInfo				= nil
	self.m_TargetOfTargetInfo		= nil
	self.m_CreateChatWnd			= nil
	self.m_SmallMapBG				= nil
	self.m_NavigationMap			= nil
	self.m_BurstSoulWnd				= nil
	------------------------------------------------------
	--׼һ������
	self.m_PanelMenu				= nil

	self.m_KeyAccelerator			= nil

	--����ϵͳ���
	self.m_AreaInfoWnd				= nil
	--��һ�ν�������ʱ����������������
	self.m_AreaIntroductionWnd		= nil

	--�ٻ���,ս������,������е
	self.m_Servant					= nil
	self.m_BattleHorseWnd 			= nil
	self.m_TruckWnd					= nil
	self.m_OrdnanceMonsterInfo		= nil
	self.m_CannonInfo		 		= nil
	self.m_ServantBuffWnd 			= nil
	self.m_BattleHorseBuffWnd		= nil
	self.m_OrdnanceMonsterBuffWnd	= nil
	self.m_CannonBuffWnd			= nil
	
	--���а񴰿�
	self.m_SortListWnd 	= nil
	
	--�ʼ�
	self.m_EmailBox		= nil
	self.m_SendBox		= nil
	self.m_ReceiveBox	= nil

	--NPC�̵깺�ش���
	self.m_NPCShopPlayerSold 	= nil

	--NPC�̵깺�򴰿�
	self.m_NPCShopSell = nil

	--��ҽ��״���
	self.m_PlayersTradeWnd = nil
	--��ҽ�������btn
	self.m_PlayersTradeRequestWndInGameMain = nil

	--���۽���������
	self.m_CSMSellOrderWnd 	= nil
	--��Ʒʰȡ����
	self.m_PickupItemWnd 		= nil
	--��Ʒʰȡ������ģʽ����
	self.m_AcutionAssignTbls = {}
	--������䷽ʽ�Ĵ��ڿɵ������
	self.m_NeedAssignTbls = nil
	
	--��ʯ,��ײ��Ϻϳɽ���
	self.m_stone = nil
	self.m_stonecompound = nil
	--�ױ�ʯ����
	self.m_whitestone = nil
	--����������������ʾ
	self.m_skillProgress_Load = nil
	
	--����ͷ��ð�ݴ��ڳ�
	self.m_NpcHeadUpDialogTbl = nil
	
	--��ɫ��Ϣ
	self.m_AimStatusWnd	= nil
	self.m_RoleStatus	= nil
	self.m_PlayerFightInfoWnd = nil
	self.FollowerTbl = nil
	
	--���̽���
	self.m_turntable = nil
	
	--װ��������ǿ��
	self.m_EquipUpIntensifyWnd = nil
	
	--������ʾ���
	self.m_FightInfoWnd = nil
	
	--����ϵͳ
	self.m_SkillJingLingWnd = nil
	
	--��ʱ����
	self.m_TempSkill = nil
	--Buff Debuff
	self.m_Buff = nil
	self.m_TargetBuff = nil
	self.m_TargetOfTargetBuff = nil

	--װ������ȡ�� ���(��Ҫ�����Ӧ��NPC)
	self.m_EquipToSoul = nil
	--������
	self.m_ExpBar = nil

	--���Ҷһ�����
	self.m_Agiotage = nil
	--ͷ����Ϣ
	self.m_CharacterInViewMgr = nil
	self.m_CharacterInSyncMgr = nil
	--������
	self.m_TeamMarkSignMgr = nil
	--����Npc��Obj ͷ����־��Ϣ 
	_,self.m_NpcHeadSignMgr = nil
	--Npc�Ի��򴰿�
	self.m_NpcDlg = nil
	self.m_NpcDlgCopy = nil
	self.m_SpecialNpcWnd = nil
	--���ģ�·�Ƶ�����Obj������ʾ����
	self.m_ShowContentWnd = nil
	--���Խ��вɼ���Obj����ʾ����
	self.m_CollObjWnd = nil
	--��������ϵͳ�õĽ�����
	self.m_ProgressBarWnd = nil
	self.m_NormalProgressBarWnd = nil
	self.m_ResourceProgressWnd = nil
	self.m_UseItemProgressWnd = nil
	self.m_SandGlassWnd = nil
	--Pk����
	self.m_PkSwitchWnd = nil

	--���򸱱���������
	self.m_AreaFbInfoWnd = nil
	self.m_AreaFbSelWnd = nil
	self.m_DareFbListWnd = nil
	
	--���ս��ش���
	self.m_WarZoneSelWnd = nil
	
	--�ٻ����ܵĵ���ʾ����
	self.m_TransportHintWnd = nil
	--�������
	self.m_WndAction = nil
	
	self.m_TextItemWnd = nil
	
	--���ⴰ��
	self.m_EssayQuestionWnd = nil
	
	--С�����Ƿ���Ϣ��ʾ��
	self.m_MatchGameWnd = nil
	self.m_MatchGameSelWnd = nil
	self.m_FbGameStatisticsWnd = nil
	
	--ָ�������
	self.m_ChallengeCompass = nil
	--��ս����Ϊ������
	self.m_XLProgressWnd = nil
	--Ӷ������ش���
	self.m_MercenaryQuestPoolWnd = nil
	--װ���趨������������ʾ����
	self.m_EquipEnactmentAttrWnd = nil
	
	self.m_NonFightSkillWnd = nil
	self.m_NetworkDelayTimeWnd = nil
	self.m_SystemMsgInfo = nil
	self.m_SystemMsgWnd = nil
	self.m_AppellationAndMoralWnd = nil

	self.m_HidePlayerWnd = nil
	self.m_HidePlayerExceptTeammateWnd = nil
	
	self.m_GMConsole	= nil
	self.m_SysSetting	= nil
	self.m_ExitGame		= nil
	
	self.m_BloodRenderDialogPool:Release()
	
	self.m_TransportTrap = nil
	self.m_FightingEvaluationWnd = nil
	self.m_RoleLevelAttentionWnd = nil
	self.m_AimFightingEvaluationWnd = nil
	self.m_HideFollowerMgr = nil
	self.m_IdentityAffirmWnd = nil
	self.m_ItemBagLockWnd = nil
	self.m_ItemBagTimeLockWnd = nil
end

function CGameMain:UnRegisterTickOnDestroyGameMain()
	UnRegisterObjOnceTick(g_GameMain)  	 		--ע��ȫ���������ڵ�һ����tick
		
	--ע��Buffͼ���Tick
	if self.m_Buff then
		self.m_Buff:ClearAllBuffState() --��ɫ��buff�������
	end
	if self.m_TargetBuff then
		self.m_TargetBuff:ClearAllBuffState()
	end
	if self.m_TargetOfTargetBuff then
		self.m_TargetOfTargetBuff:ClearAllBuffState()
	end
	if self.m_ServantBuffWnd then
		self.m_ServantBuffWnd:ClearAllBuffState()
	end
	if self.m_BattleHorseBuffWnd then
		self.m_BattleHorseBuffWnd:ClearAllBuffState()
	end
	if self.m_OrdnanceMonsterBuffWnd then
		self.m_OrdnanceMonsterBuffWnd:ClearAllBuffState()
	end
	if self.m_CannonBuffWnd then
		self.m_CannonBuffWnd:ClearAllBuffState()
	end
	if self.m_FbActionTick then
		for FbType,_ in pairs(self.m_FbActionTick) do
			UnRegisterTick(self.m_FbActionTick[FbType])
		end
	end
	self.m_skillProgress_Load:UnRegisterTick()	--��������Tick
	self.m_TargetInfo:UnRegisterTick()			--Ŀ��ͷ������Tick
	self.m_TargetOfTargetInfo:UnRegisterTick()	--Ŀ���Ŀ��ͷ������Tick
	
	g_GameMain.m_SysSetting.m_KPmap:UnRegisterAccelKeyKey()
	UnRegisterTick( self.m_ProgressBarWnd.m_LoadTime )
	UnRegisterTick( self.m_NormalProgressBarWnd.m_LoadTime )
	UnRegisterTick( self.m_ResourceProgressWnd.m_LoadTime )
	
	
	CTongRobResExitWnd.UnRegisterRobResExitTick()
	CTongRobOverExit.UnRegisterRobResOverExitTick()
	CTongItemUseTrans.UnRegisterItemUsetTick()
	CConfirmWnd.UnRegisterUseItemTick()
	CTongChangeByPos.UnRegisterChangeByPosTick()
	
	CRobResCountDown.UnRegisterRobResDownTick()
	CCountdown.UnRegisterGameDownTimeTick()
	UnRegisterTick( self.m_UseItemProgressWnd.m_LoadTime )
	UnRegisterTick( self.m_SandGlassWnd.m_LoadTime )
	if self.m_FbActionScoreTick then
		UnRegisterTick(self.m_FbActionScoreTick)
	end
	
	self:GameMainUnRegisterAccelerator()
	if self.m_whitestone then
		UnRegisterTick( self.m_whitestone.ontimer )
		UnRegisterTick( self.m_whitestone.AnthorTimer )
	end
	--ע����ʱ����Tick
	self.m_TempSkill:UnRegisterTempSkill()
	
	--ע��ǿ��������Tick
	if self.m_EquipUpIntensifyWnd ~= nil then
		self.m_EquipUpIntensifyWnd:UnRegisterSelfTick()
	end
	
	--����ѧϰ������Tick
	if self.m_LearnCommonSkillWnd.m_CommonSkillItemTbl then
		for i = 1,#(self.m_LearnCommonSkillWnd.m_CommonSkillItemTbl) do
			local CommonSkillItem =  self.m_LearnCommonSkillWnd.m_CommonSkillItemTbl[i]
			if CommonSkillItem and CommonSkillItem.m_EventBtn.m_UpdateSkillTick then
				UnRegisterTick(CommonSkillItem.m_EventBtn.m_UpdateSkillTick)
				CommonSkillItem.m_EventBtn.m_UpdateSkillTick = nil
			end
		end
	end
	
	--�ɵ�ָ�����е�Tick
	g_GameMain.m_ChallengeCompass:CancelCompassState()
	--С��Ϸ�ж������ڵ�Tick
	if self.m_SGMgr.m_ShowEffectTick then
		UnRegisterTick(self.m_SGMgr.m_ShowEffectTick)
		self.m_SGMgr.m_ShowEffectTick = nil
	end
	if self.m_DownTimeTick then
		UnRegisterTick(self.m_DownTimeTick)
		self.m_DownTimeTick = nil
	end

	--�Ե粨С��ϷTick
	if self.HeadFishingTick then
		UnRegisterTick(self.HeadFishingTick)
		self.HeadFishingTick = nil
	end
	if self.HeadHuntTick then
		UnRegisterTick(self.HeadHuntTick)
		self.HeadHuntTick = nil
	end
	
	--���˳�����ʱTick
	if self.m_IsExitSceneMsgBox and self.m_IsExitSceneMsgBox.m_CountDownTick then
		UnRegisterTick(self.m_IsExitSceneMsgBox.m_CountDownTick)
		self.m_IsExitSceneMsgBox = nil
	end
	
	if self.m_MatchGameWnd.m_ShowTimeTick then
		UnRegisterTick(self.m_MatchGameWnd.m_ShowTimeTick)
		self.m_MatchGameWnd.m_ShowTimeTick = nil
	end
	if self.m_FbActionMgrWnd.m_DownTimeTick then
		UnRegisterTick(self.m_FbActionMgrWnd.m_DownTimeTick)
		self.m_FbActionMgrWnd.m_DownTimeTick = nil
	end
	
	if self.m_EssayQuestionWnd and self.m_EssayQuestionWnd.m_AnswerWndTick then
		UnRegisterTick(self.m_EssayQuestionWnd.m_AnswerWndTick)
		self.m_EssayQuestionWnd.m_AnswerWndTick = nil 
	end
	
	self.m_YbEducateActionWnd:ClearAllTick()
	
	self.m_NpcHeadSignMgr:ClearNpcShowQuestFaceTick()
	
	--����ʱ����
	CCountdownWnd.ClearAllCountdownWndTick()
	
	--����ʱ����Ĵ���
	UnRegisterAllQuestTick()
	
	--ע����ʱ��������Tick
	g_AlarmClock:ClearTick()
	--ע�������ճ��淨�֪ͨ��Tick
	ClearEndActionNotifyTick()
	
	--ע���ͻ����Զ��رմ��ڵ�Tick
	CAutoCloseWnd.ClearAutoCloseWndTick()
	
	--ע����ʱ�ر������������Tick
	if self.m_AreaIntroductionWnd.m_CloseWndTick then
		UnRegisterTick(self.m_AreaIntroductionWnd.m_CloseWndTick)
		self.m_AreaIntroductionWnd.m_CloseWndTick = nil
	end
	
	if self.m_StopBackgroundMusicTick then
		UnRegisterTick(self.m_StopBackgroundMusicTick)
		self.m_StopBackgroundMusicTick = nil
	end
	
	if self.m_PlayBackgroundMusicTick then
		UnRegisterTick(self.m_PlayBackgroundMusicTick)
		self.m_PlayBackgroundMusicTick = nil
	end
	
	for _, musicCDTick in pairs(g_MusicCDTbl) do
		UnRegisterTick(musicCDTick)
	end
	
	--ע������ϵͳ��Tick
	if self.m_CreateChatWnd.m_CSysRollArea.m_ChatWndTick then
		UnRegisterTick(self.m_CreateChatWnd.m_CSysRollArea.m_ChatWndTick)
	end
	
	--ע����˸��ʾ���tick
	if self.m_FlashMsgWnd then
		if self.m_FlashMsgWnd.m_ShowFlashMsgWndTick then
			UnRegisterTick(self.m_FlashMsgWnd.m_ShowFlashMsgWndTick)	
			self.m_FlashMsgWnd.m_ShowFlashMsgWndTick = nil			
		end
		if self.m_FlashMsgWnd.m_StartTransTick then
			UnRegisterTick(self.m_FlashMsgWnd.m_StartTransTick)	
			self.m_FlashMsgWnd.m_StartTransTick = nil			
		end		
	end
	
	--ע��������˸��ʾ���tick
	if self.m_FlashSkillMsgWnd then
		if self.m_FlashSkillMsgWnd.m_StartTransTick then
			UnRegisterTick(self.m_FlashSkillMsgWnd.m_StartTransTick)	
			self.m_FlashSkillMsgWnd.m_StartTransTick = nil			
		end		
	end
	
	if self.m_BagShapeEffectWnd then
		if self.m_BagShapeEffectWnd.m_StartbagShapeTick then
			UnRegisterTick(self.m_BagShapeEffectWnd.m_StartbagShapeTick)
			self.m_BagShapeEffectWnd.m_StartbagShapeTick = nil	
		end
	end
	
	if self.m_MessageShapeEffectWnd 
		and self.m_MessageShapeEffectWnd.m_StartMessageShapeTick then
			UnRegisterTick(self.m_MessageShapeEffectWnd.m_StartMessageShapeTick)
			self.m_MessageShapeEffectWnd.m_StartMessageShapeTick = nil
			self.m_MessageShapeEffectWnd.m_RichText:SetWndText("")
	end
	
	if self.m_MessageMiniTextWnd 
		and self.m_MessageMiniTextWnd.m_StartMessageShapeTick then
			UnRegisterTick(self.m_MessageMiniTextWnd.m_StartMessageShapeTick)
			self.m_MessageMiniTextWnd.m_StartMessageShapeTick = nil
			self.m_MessageMiniTextWnd.m_RichText:SetWndText("")
	end
	
	if self.m_MessageShapeEffectSecondWnd 
		and self.m_MessageShapeEffectSecondWnd.m_StartMessageShapeTick then
			UnRegisterTick(self.m_MessageShapeEffectSecondWnd.m_StartMessageShapeTick)
			self.m_MessageShapeEffectSecondWnd.m_StartMessageShapeTick = nil
			self.m_MessageShapeEffectSecondWnd.m_RichText:SetWndText("")
	end	
	
	if self.m_CreateChatWnd.m_CSysRollArea.m_CheckHaveMsgRollTick  then
		UnRegisterTick(self.m_CreateChatWnd.m_CSysRollArea.m_CheckHaveMsgRollTick )
		self.m_CreateChatWnd.m_CSysRollArea.m_CheckHaveMsgRollTick  = nil
	end
	
	if self.m_ShowSkillDescWnd and self.m_ShowSkillDescWnd.m_CloseSkillDescWndTick then
		UnRegisterTick( self.m_ShowSkillDescWnd.m_CloseSkillDescWndTick )
		self.m_ShowSkillDescWnd.m_CloseSkillDescWndTick = nil
	end
	
	--��Ӷ��ָ����־��tick
	if self.m_ShowMercDirTick then
		UnRegisterTick(self.m_ShowMercDirTick)
		self.m_ShowMercDirTick = nil
	end
	
	CShareQuestWnd.UnRegisterShareQuestTick()
	
	--ע������ʱ�˳���Ϸ��tick
	if ( self.m_ExitGameMsgBox and self.m_ExitGameMsgBox.m_CountDownTick ) then
		UnRegisterTick(self.m_ExitGameMsgBox.m_CountDownTick)
		self.m_ExitGameMsgBox.m_CountDownTick = nil
	end
	
	--ע�����ص�½�����tick
	if ( self.m_ToLoginMsgBox and self.m_ToLoginMsgBox.m_CountDownTick ) then
		UnRegisterTick(self.m_ToLoginMsgBox.m_CountDownTick)
		self.m_ToLoginMsgBox.m_CountDownTick = nil
	end
	
	--ע����ɫ��������tick
	if g_GameMain.m_ToDeadMsgBox ~= nil  then
		if g_GameMain.m_ToDeadMsgBox.m_CountDownTick ~= nil then
			UnRegisterTick(g_GameMain.m_ToDeadMsgBox.m_CountDownTick)
			g_GameMain.m_ToDeadMsgBox.m_CountDownTick = nil
		end
		if g_GameMain.m_ToDeadMsgBox.m_BeforeCountDownTick ~= nil then
			UnRegisterTick(g_GameMain.m_ToDeadMsgBox.m_BeforeCountDownTick)
			g_GameMain.m_ToDeadMsgBox.m_BeforeCountDownTick = nil
		end
	end
	
	if self.m_AreaFbDeadMsgBox then
		if self.m_AreaFbDeadMsgBox.m_CountDownTick then
			UnRegisterTick(self.m_AreaFbDeadMsgBox.m_CountDownTick)
			self.m_AreaFbDeadMsgBox.m_CountDownTick = nil
		end
		self.m_AreaFbDeadMsgBox = nil
	end
	
	if self.m_RobResDeadMsgBox then
		if self.m_RobResDeadMsgBox.m_CountDownTick then
			UnRegisterTick(self.m_RobResDeadMsgBox.m_CountDownTick)
			self.m_RobResDeadMsgBox.m_CountDownTick = nil
		end
		self.m_RobResDeadMsgBox = nil
	end
	
	if g_GameMain.m_FbActionMgrWnd.m_RobResDownTimeTick then
		UnRegisterTick(g_GameMain.m_FbActionMgrWnd.m_RobResDownTimeTick)
		g_GameMain.m_FbActionMgrWnd.m_RobResDownTimeTick = nil
	end
	
	if g_GameMain.m_FbActionMgrWnd.m_RobResourceDownTime then
		UnRegisterTick(g_GameMain.m_FbActionMgrWnd.m_RobResourceDownTime)
		g_GameMain.m_FbActionMgrWnd.m_RobResourceDownTime = nil
	end
	
	if g_GameMain.m_QihunjiZhiyinWnd.m_CloseTick then
		UnRegisterTick(g_GameMain.m_QihunjiZhiyinWnd.m_CloseTick)
		g_GameMain.m_QihunjiZhiyinWnd.m_CloseTick = nil
	end
	
	
	if self.m_FBDeadMsgBox then
		if self.m_FBDeadMsgBox.m_CountDownTick then
			UnRegisterTick(self.m_FBDeadMsgBox.m_CountDownTick)
			self.m_FBDeadMsgBox.m_CountDownTick = nil
		end
		self.m_FBDeadMsgBox = nil
	end
	
	if self.m_TeamPVPFBDeadMsgBox then
		if self.m_TeamPVPFBDeadMsgBox.m_CountDownTick then
			UnRegisterTick(self.m_TeamPVPFBDeadMsgBox.m_CountDownTick)
			self.m_TeamPVPFBDeadMsgBox.m_CountDownTick = nil
		end
		self.m_TeamPVPFBDeadMsgBox = nil
	end
	
	if self.m_WarDeadMsgBox then
		if self.m_WarDeadMsgBox.m_CountDownTick then
			UnRegisterTick(self.m_WarDeadMsgBox.m_CountDownTick)
			self.m_WarDeadMsgBox.m_CountDownTick = nil
		end
		self.m_WarDeadMsgBox = nil
	end
	if self.m_NewRole then
		self.m_NewRole:UnRegisterNewRoleTick() 
	end
	
	if self.m_CameraMoveTick then
		UnRegisterTick(self.m_CameraMoveTick)
		self.m_CameraMoveTick = nil
	end
	
	--ע�������е���Ʒʣ��ʱ��tick
	UnRegisterTick(g_GameMain.m_MainItemBag.m_UpdateItemLeftTimeInBagTick)
	g_GameMain.m_MainItemBag.m_UpdateItemLeftTimeInBagTick = nil 
	
	if g_GameMain.m_ExitTick ~= nil then
		UnRegisterTick(g_GameMain.m_ExitTick)
		g_GameMain.m_ExitTick = nil 
	end
	
	--ע��selectObjTooltipsʣ��ʱ���tick
	if( self.m_SelectObjTooltips.m_SelectObjTooltipsTick ) then
		UnRegisterTick( self.m_SelectObjTooltips.m_SelectObjTooltipsTick )
		self.m_SelectObjTooltips.m_SelectObjTooltipsTick = nil
	end
	
	if (MoveCameraTick) then
		UnRegisterTick(MoveCameraTick)
		MoveCameraTick = nil
	end
	
	if (SetPageUpTick) then
		UnRegisterTick(SetPageUpTick)
		SetPageUpTick = nil
	end
	
	if (SetPageDownTick) then
		UnRegisterTick(SetPageDownTick)
		SetPageDownTick = nil
	end
	
	if g_GameMain.m_TurnLeftCameraTick then
		UnRegisterTick(g_GameMain.m_TurnLeftCameraTick)
		g_GameMain.m_TurnLeftCameraTick = nil
	end
	if g_GameMain.m_TurnRightCameraTick then
		UnRegisterTick(g_GameMain.m_TurnRightCameraTick)
		g_GameMain.m_TurnRightCameraTick = nil
	end
	
	--ע��Ѱ�����tick
	if g_GameMain.m_TeamApplicationListMini.m_FreshAppListTick then
		UnRegisterTick(g_GameMain.m_TeamApplicationListMini.m_FreshAppListTick)
		g_GameMain.m_TeamApplicationListMini.m_FreshAppListTick = nil
	end
	 if g_GameMain.m_TeamApplicationListMini.m_ShowUgTimeTick then 
	 	UnRegisterTick(g_GameMain.m_TeamApplicationListMini.m_ShowUgTimeTick)
	 	g_GameMain.m_TeamApplicationListMini.m_ShowUgTimeTick = nil
	end
	if g_GameMain.m_TeamApplicationListMini.m_ShowActTimeTick then
		UnRegisterTick(g_GameMain.m_TeamApplicationListMini.m_ShowActTimeTick)
		g_GameMain.m_TeamApplicationListMini.m_ShowActTimeTick = nil
	end
	if g_GameMain.m_TeamApplicationListMini.m_ShowTaskTimeTick then
		UnRegisterTick(g_GameMain.m_TeamApplicationListMini.m_ShowTaskTimeTick)
		g_GameMain.m_TeamApplicationListMini.m_ShowTaskTimeTick = nil
	end
	
	
	
	 
	self:UnRegisterLiveSkillTick()	--ע�������tick
	self:UnRegisterTongTick()		--ע��Ӷ����tick
	
	if self.m_NetworkDelayTimeTick then
		UnRegisterTick( self.m_NetworkDelayTimeTick )
		self.m_NetworkDelayTimeTick = nil
	end

	if self.m_NeedAssignTbls then
		for i , v in pairs(self.m_NeedAssignTbls) do
			UnRegisterTick(v.m_CountDownTick)
		end
	end
	if self.m_AcutionAssignTbls then
		for i , v in pairs(self.m_AcutionAssignTbls) do
			UnRegisterTick(v.m_CountDownTick)
		end
	end
	
	if g_GameMain.m_JoinChallengeTick then
		UnRegisterTick(g_GameMain.m_JoinChallengeTick)
		g_GameMain.m_JoinChallengeTick = nil
	end
	
	--��Ⱥ
	local assoWnd = self.m_AssociationWnd
	if(assoWnd and assoWnd.m_AssociationListWnd and assoWnd.m_AssociationListWnd.UpdateOnlineFriendTick) then
		UnRegisterTick(assoWnd.m_AssociationListWnd.UpdateOnlineFriendTick)
		assoWnd.m_AssociationListWnd.UpdateOnlineFriendTick = nil
	end
	
	--����
	self.m_FbActionPanel:VirtualExcludeWndClosed()
	
	-- ����������Ǯ
	if self.m_XiuXingTaAddMoneyTick then
		UnRegisterTick(self.m_XiuXingTaAddMoneyTick)
		self.m_XiuXingTaAddMoneyTick = nil
	end
	-- ������������ֵ
	if self.m_XiuXingTaAddSoulTick then
		UnRegisterTick(self.m_XiuXingTaAddSoulTick)
		self.m_XiuXingTaAddSoulTick = nil
	end
	
	UnRegisterTurnLeftCameraTick()
	UnRegisterTurnRightCameraTick()
	UnRegisterTurnTopCameraTick()
	UnRegisterTurnBottomCameraTick()
	UnRegisterMoveCameraNearTick()
	UnRegisterMoveCameraFarTick()
	if self.m_PrepareChangeTick then
		UnRegisterTick(self.m_PrepareChangeTick)
		self.m_PrepareChangeTick = nil
	end
	if self.m_PrepareChangeCDTick then
		UnRegisterTick(self.m_PrepareChangeCDTick)
		self.m_PrepareChangeCDTick = nil
	end
	self:OnTurnRunCameraEnd()
	
	if g_GameMain.m_StatisticFightInfoWnd and g_GameMain.m_StatisticFightInfoWnd.m_pStatisticTick then
		UnRegisterTick(g_GameMain.m_StatisticFightInfoWnd.m_pStatisticTick)
	end
	if self.m_FightInfoWnd then
		self.m_FightInfoWnd:UnRegisterFightInfoTick()
	end
	
	if self.m_CreateChatWnd.m_CCHMsgWnd.m_CheckHaveMsgTick  then
		UnRegisterTick(self.m_CreateChatWnd.m_CCHMsgWnd.m_CheckHaveMsgTick)
		self.m_CreateChatWnd.m_CCHMsgWnd.m_CheckHaveMsgTick  = nil
	end
	
	if self.m_ItemBagTimeLockWnd.m_ShowTimeTick then
		UnRegisterTick(self.m_ItemBagTimeLockWnd.m_ShowTimeTick)
		self.m_ItemBagTimeLockWnd.m_ShowTimeTick = nil
	end
	
	if self.m_TongNeedFireActivityItemWnd then
		if self.m_TongNeedFireActivityItemWnd.m_CoolDownTick then
			UnRegisterTick(self.m_TongNeedFireActivityItemWnd.m_CoolDownTick)
			self.m_TongNeedFireActivityItemWnd.m_CoolDownTick = nil
		end
	end
	
	ClearDb2GacTimeOutTick()
end

--ע�������tick
function CGameMain:UnRegisterLiveSkillTick()
	--�ֻ�Tick
	if self.m_FlowerCooldownTick then
		UnRegisterTick(self.m_FlowerCooldownTick)
		self.m_FlowerCooldownTick = nil
	end
--	--���졢����
--	if(self.m_LiveSkillProdMain.m_LiveSkillProduction and self.m_LiveSkillProdMain.m_LiveSkillProduction.ProdTickFun) then
--		UnRegisterTick(self.m_LiveSkillProdMain.m_LiveSkillProduction.ProdTickFun)
--		self.m_LiveSkillProdMain.m_LiveSkillProduction.ProdTickFun = nil
--	end
--	--����
--	if(self.m_LiveSkillProdMain.m_LiveSkillProdRefine and self.m_LiveSkillProdMain.m_LiveSkillProdRefine.RefineTickFun) then
--		UnRegisterTick(self.m_LiveSkillProdMain.m_LiveSkillProdRefine.RefineTickFun)
--		self.m_LiveSkillProdMain.m_LiveSkillProdRefine.RefineTickFun = nil
--	end
	if self.m_RoleLevelAttentionWnd then
		if self.m_RoleLevelAttentionWnd.m_MoveLevelUpWndTick then
			UnRegisterTick( self.m_RoleLevelAttentionWnd.m_MoveLevelUpWndTick )
			self.m_RoleLevelAttentionWnd.m_MoveLevelUpWndTick = nil
		end
	end
end

--ע��Ӷ����tick
function CGameMain:UnRegisterTongTick()
	if self.m_TongDownTimeWnd.m_DownTimeTick then
		UnRegisterTick(self.m_TongDownTimeWnd.m_DownTimeTick)
		self.m_TongDownTimeWnd.m_DownTimeTick = nil
	end
	if self.m_TongDownTimeWnd.m_ShowTimeTick then
		UnRegisterTick(self.m_TongDownTimeWnd.m_ShowTimeTick)
		self.m_TongDownTimeWnd.m_ShowTimeTick = nil
	end
	if self.m_TongBattlePersonalCountWnd.m_ShowTimeTick then
		UnRegisterTick(self.m_TongBattlePersonalCountWnd.m_ShowTimeTick)
		self.m_TongBattlePersonalCountWnd.m_ShowTimeTick = nil
	end
	if self.m_TongBattlePersonalCountWnd.m_DownTimeTick then
		UnRegisterTick(self.m_TongBattlePersonalCountWnd.m_DownTimeTick)
		self.m_TongBattlePersonalCountWnd.m_DownTimeTick = nil
	end
	if self.m_TongMonsAttackCountWnd.m_InfoUpdateTick then
		UnRegisterTick(self.m_TongMonsAttackCountWnd.m_InfoUpdateTick)
		self.m_TongMonsAttackCountWnd.m_InfoUpdateTick = nil
	end
	if self.m_TongWarBattleCountWnd.m_InfoUpdateTick then
		UnRegisterTick(self.m_TongWarBattleCountWnd.m_InfoUpdateTick)
		self.m_TongWarBattleCountWnd.m_InfoUpdateTick = nil
	end
	if self.m_TongChallengeBattleCountWnd.m_InfoUpdateTick then
		UnRegisterTick(self.m_TongChallengeBattleCountWnd.m_InfoUpdateTick)
		self.m_TongChallengeBattleCountWnd.m_InfoUpdateTick = nil
	end
	if(self.m_TongBuildingItemCreate and self.m_TongBuildingItemCreate.CreatingBuildingItemTick) then
		UnRegisterTick(self.m_TongBuildingItemCreate.CreatingBuildingItemTick)
		self.m_TongBuildingItemCreate.CreatingBuildingItemTick = nil
	end
	
	if(self.m_TongProductionCenter and self.m_TongProductionCenter.CreatingBuildingItemTick) then
		UnRegisterTick(self.m_TongProductionCenter.CreatingBuildingItemTick)
		self.m_TongProductionCenter.CreatingBuildingItemTick = nil
	end
	

	if(self.m_TongScience and self.m_TongScience.CreatingBuildingItemTick) then
		UnRegisterTick(self.m_TongScience.CreatingBuildingItemTick)
		self.m_TongScience.CreatingBuildingItemTick = nil
	end

	--ע��������ʾTick
	CComboHitsWnd.HideComboHitsWnd()
	
	--����
	self.m_FbActionPanel:VirtualExcludeWndClosed()

	
	--����
	self.m_FbActionPanel:VirtualExcludeWndClosed()
	
	-- �е�ͼ
	if self.m_AreaInfoWnd then
		self.m_AreaInfoWnd:ClearAllTick()
	end
  
	self:OnTurnRunCameraEnd()
	
end

function CGameMain:OnCommand( wParam, lParam )--ע��RegisterAccelKeyCommand����Ӧ����
	g_GameMain.m_SysSetting.m_KPmap:OnCommand( wParam, lParam )
end

--����Ϸ״̬�˳�������״̬����¼����ɫѡ��ȣ���Ҫֱ��ʹ��coroutine.resume��Ӧ�����������
function CGameMain:ExitToState( eGameState )
	CEffectLoader_Inst():Clear()
	if ( eGameState == EGameState.eExitGame ) then
		
		if(g_Conn.ShutDown) then
			g_Conn:ShutDown()
		end
		
	end
	
	if (g_CoreScene ~= nil) then
		g_CoreSceneMgr:DestroyMainScene()
	end
		

	local function ExitTickFun()
		if( g_CoreScene == nil ) then
			UnRegisterTick( self.m_ExitTick )
			g_App:GetRootWnd():DelScreenFx("hpguodi/create")
			StopCue("heartbeat") 
			coroutine.resume( g_App.MainRoutine, eGameState )
		end
	end

	--ע���˳���Tick
	if self.m_ExitTick == nil then
	    self.m_ExitTick = RegisterTick( "ExitTickFun", ExitTickFun, 100)
    end
end
	
function CGameMain:main()
	--self:OnInit()
	local re = self:WaitMessage() 
	self:OnExit()
	return re	
end

function CGameMain:OnMouseLeave()
	if g_MainPlayer and IsCppBound(g_MainPlayer) then
		g_MainPlayer:MoveOnTime_UnRegisterTick()
		g_MainPlayer:RunToMouse_UnRegisterTick()
	end
	if g_GameMain and g_GameMain.m_MousePosX and g_GameMain.m_MousePosY and 
		g_GameMain.FreedomCameraCtrl and g_GameMain.bMouseLastActionIsButtonDown == false then
		g_App:GetRootWnd():SetSysCursorPos(g_GameMain.m_MousePosX,g_GameMain.m_MousePosY)
	end
end

function CGameMain:OnMLButtonUpAnyCase()
	if g_MainPlayer and IsCppBound(g_MainPlayer) and g_GameMain.m_SysSetting.m_MouseSettingWnd.m_MoveLeftFlag then
		g_MainPlayer:MoveOnTime_UnRegisterTick()
	end
end

function CGameMain:OnMRButtonUpAnyCase()
	if g_MainPlayer and IsCppBound(g_MainPlayer) and not g_GameMain.m_SysSetting.m_MouseSettingWnd.m_MoveLeftFlag then
		g_MainPlayer:MoveOnTime_UnRegisterTick()
	end
	self:OnTurnRunCameraEnd()
end

function CGameMain:OnLButtonDown( nFlags, x, y )
	if not IsCppBound(g_MainPlayer) or self.m_IsTransfer then --�����ǻ�����С��Ϸ״̬
		return
	end
	if self.m_SmallGame ~= nil or self.m_DoSmallGame then   --С��Ϸ״̬
		self.m_SGMgr:RunSmallGameFun(1)
		return 
	end
	if g_GameMain.m_NavigationMap.m_SelectShowWnd:IsShow() then
		g_GameMain.m_NavigationMap.m_SelectShowWnd:ShowWnd(false)
	end
	if g_GameMain.m_ProgressBarWnd.m_IsInPerfectCollState then
		g_GameMain.m_ProgressBarWnd:StopPerfetCollState()
		return
	end
	if( g_MainPlayer and IsCppBound(g_MainPlayer) ) then
		-- �м���״̬�����ȴ�����״̬���������ж��Ƿ������״̬���оͲ����������Ϣ������
		local State, Context = g_WndMouse:GetCursorState()
		if State == ECursorState.eCS_Split then
			return
		elseif State == ECursorState.eCS_PickupItem then
			return
		elseif State == ECursorState.eCS_PickupEquip then
			return
		else
			if( not g_GameMain.m_SysSetting.m_MouseSettingWnd.m_MoveLeftFlag ) then
				g_GameMain:OnTurnRunCameraInit()
			end
			g_MainPlayer:OnLButtonDown()
		end
	end
end

--˫������ģ��
function CGameMain:OnLButtonDblClk(nFlags, x, y )
	g_GameMain:OnLButtonDown( nFlags, x, y )
end

--��סshift�������
function CGameMain:OnShiftLButtonDown( nFlags, posx, posy )
	if not g_MainPlayer then
		return
	end
	if self.m_CreateChatWnd.m_ChatSendArea:IsShow() then
		local EditMessageWnd = self.m_CreateChatWnd.m_ChatSendArea.m_CEditMessage
		local pos = CPos:new()
		g_MainPlayer:GetGridPos(pos)
		local scenename = g_GameMain.m_SceneName or ""
		local str = "[" .. GetSceneDispalyName(scenename) .. "("  .. pos.x .. "," .. pos.y .. ")" .. "]"
		local content = EditMessageWnd:GetWndText()
		--local maxTextLenght = EditMessageWnd:GetMaxTextLenght()*2
		--if string.len(content) < maxTextLenght then
			EditMessageWnd:SetWndText(content .. str)
			EditMessageWnd:SetFocus()
		--end
	else
		self:OnLButtonDown( nFlags, posx, posy )
	end
end

function CGameMain:OnMouseMove( nFlags, posx, posy )
	--self.m_SelectObjTooltips:OnMouseMoveInGameMain()
	self.m_CharacterInSyncMgr:OnMouseMoveInGameMain()
end

function CGameMain:OnLButtonClick( nFlags, x, y )
	self:OnLButtonUp( nFlags, x, y )
end

function CGameMain:OnLButtonUp( nFlags, x, y )
	if not IsCppBound(g_MainPlayer) or self.m_IsTransfer then --�����ǻ�����С��Ϸ״̬
		return
	end
	
	local cssstate, csscontext = g_WndMouse:GetCursorSkillState()
	if( cssstate ~= ECursorSkillState.eCSS_Normal ) then
		g_MainPlayer:OnLButtonUp()
	else
		local State, Context = g_WndMouse:GetCursorState()
		if State == ECursorState.eCS_Split then
			return--�з�״̬���ö�
		elseif State == ECursorState.eCS_PickupEquip then
			local nItemID, eEquipPart, EquipWnd = Context[1], Context[2],Context[3]
			local function DelEquip(EquipWnd, nIndex)
				if nIndex == MB_BtnOK then
					g_WndMouse:ClearCursorAll()
					Gac2Gas:DelEquip(g_Conn,eEquipPart)
				else
					g_WndMouse:ClearCursorAll()
				end
				return true
			end
			if g_MainPlayer:IsInBattleState() then
				g_WndMouse:ClearCursorAll()
				MsgClient(1024)
				return
			end
			EquipWnd.m_MsgBox = MessageBox(g_GameMain,MsgBoxMsg(13008),BitOr(MB_BtnOK,MB_BtnCancel),DelEquip,EquipWnd)
		elseif State == ECursorState.eCS_PickupItem then
			--��������Ʒ(����Ʒ����ʰȡ)
			local fromRoom, fromrow, fromcol, count = Context[1], Context[2],Context[3], Context[4]
			local SrcCt = g_GameMain.m_BagSpaceMgr:GetSpaceRelateLc(fromRoom)
			local SrcPos = SrcCt:GetPosByIndex(fromrow, fromcol, fromRoom)
			local Grid = SrcCt:GetGridByIndex(fromrow, fromcol, fromRoom)
			local Type, index = Grid:GetType()
			
			if(g_Client_IsSlotIndex(fromRoom)) then return end --�������չ���ϵ�4�������е�
				
			--ֻ�в��״̬count����ֵ����ȥ���ǻ�ø����ϵ�ȫ����Ʒ
			if count == nil then
				local SrcGrid = SrcCt:GetGridByIndex(fromrow, fromcol, fromRoom)
				local SrcSize = SrcGrid:Size()
				count = SrcSize
			end
				
			local function DelItem(SrcCt, nIndex)
				if nIndex == MB_BtnOK then
					if g_MainPlayer.m_ItemBagLock then
						MsgClient(160013)
						return
					end		
					g_WndMouse:ClearCursorAll()
					Gac2Gas:OnLButtonUpDelItemByPos(g_Conn,fromRoom,SrcPos,count)
				else
					g_WndMouse:ClearCursorAll()
				end
				return true
			end
			if g_QuestPropMgr[index] then
				local proptype = g_QuestPropMgr[index][1]
				local QuestName = g_QuestPropMgr[index][2]
				if proptype == Type 
					and g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[QuestName] 
					and g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[QuestName].m_State ~= QuestState.finish then
					local DisplayName = g_ItemInfoMgr:GetItemLanInfo(proptype,index,"DisplayName")
					local str=MsgBoxMsg(13009, DisplayName, g_GetLanQuestName(QuestName))
					SrcCt.m_MsgBox = MessageBox(g_GameMain,str, BitOr(MB_BtnOK,MB_BtnCancel),DelItem,SrcCt)
				else
					SrcCt.m_MsgBox = MessageBox(g_GameMain,MsgBoxMsg(13008), BitOr(MB_BtnOK,MB_BtnCancel),DelItem,SrcCt)
				end
			elseif g_WhereGiveQuestMgr["Goods"][index]~=nil and Type == 16 then
				local QuestName=g_WhereGiveQuestMgr["Goods"][index][1]
				if g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[QuestName] 
					and g_GameMain.m_QuestRecordWnd.m_QuestStateTbl[QuestName].m_State ~= QuestState.finish then
					local DisplayName = g_ItemInfoMgr:GetItemLanInfo(Type,index,"DisplayName")
					local str=MsgBoxMsg(13009,DisplayName, g_GetLanQuestName(QuestName))
					SrcCt.m_MsgBox = MessageBox(g_GameMain,str, BitOr(MB_BtnOK,MB_BtnCancel),DelItem,SrcCt)
				else
					SrcCt.m_MsgBox = MessageBox(g_GameMain,MsgBoxMsg(13008), BitOr(MB_BtnOK,MB_BtnCancel),DelItem,SrcCt)
				end
			else
				SrcCt.m_MsgBox = MessageBox(g_GameMain,MsgBoxMsg(13008), BitOr(MB_BtnOK,MB_BtnCancel),DelItem,SrcCt)
			end
		elseif State == ECursorState.eCS_PickupItemShortcut then    --��������Ʒ���ӿ������ʰȡ��
			g_WndMouse:ClearCursorAll()
		elseif State == ECursorState.eCS_PickupSkill then           --�����м���
			g_WndMouse:ClearCursorAll()
		elseif State == ECursorState.eCS_PickupItemFromNPCShop then --���ϵ���Ʒ�Ǵ�NPC�̵��õ�
			g_WndMouse:ClearCursorAll()
			--g_WndMouse:SetCursorState( ECursorState.eCS_Normal )
		elseif State == ECursorState.eCS_PickupBattleArrayIcon then --��������
			g_WndMouse:ClearCursorAll()
			--g_WndMouse:SetCursorState( ECursorState.eCS_Normal )
		else --ȱʡ����
			g_MainPlayer:OnLButtonUp()
		end
	end	

end

function CGameMain:OnRButtonClick( nFlags, x, y )
	if not IsCppBound(g_MainPlayer) or  self.m_IsTransfer then
		return
	end
	if self.m_SmallGame ~= nil or self.m_DoSmallGame then   --С��Ϸ״̬
		return 
	end
	local State, Context = g_WndMouse:GetCursorState()
	if Context ~= nil and Context[1] == g_AddRoomIndexClient.PlayerExpandBag then
		g_WndMouse:ClearCursorAll() 
	elseif( g_MainPlayer and self.bMouseLastActionIsButtonDown == true) then 
		g_MainPlayer:OnRButtonUp()
	elseif State ~= ECursorState.eCS_Normal then
		return
	end
end

function CGameMain:OnRButtonDown( nFlags, x, y )
	if(self.m_Menu) then
		self.m_Menu:Destroy()
		self.m_Menu = nil
	end
	if not IsCppBound(g_MainPlayer) or self.m_IsTransfer then
		return
	end
	if self.m_SmallGame ~= nil or self.m_DoSmallGame then   --С��Ϸ״̬
		self.m_SGMgr:RunSmallGameFun(2)
		return 
	end
	
	
	local SkillState = g_WndMouse:GetCursorSkillState()
	--�ж��Ҽ���������ʱ������״̬�ǲ���װ������״̬���߻���Ƭ�趨״̬���ǵĻ�ȡ����굱ǰ��״̬
	if SkillState == ECursorSkillState.eCSS_EquipIdentify or SkillState == ECursorSkillState.eCSS_ArmorPieceEnactment or SkillState == ECursorSkillState.eCSS_EquipSmeltSoul
	    or SkillState == ECursorSkillState.eCSS_RenewEquip  or SkillState == ECursorSkillState.eCSS_BreakItem or
	     SkillState == ECursorSkillState.eCSS_EquipIntenBack then
		g_WndMouse:ClearCursorSpecialState()
	end
	
	local State, Context = g_WndMouse:GetCursorState()
	if State ~= ECursorState.eCS_Normal then
		g_WndMouse:ClearCursorAll()
		return
	elseif( g_MainPlayer ) then
		if (g_GameMain.m_SysSetting.m_MouseSettingWnd.m_MoveLeftFlag ) then
			g_GameMain:OnTurnRunCameraInit()
		end
		g_MainPlayer:OnRButtonDown()
	end
end

function CGameMain:OnTurnRunCamera(wParam, lParam)
	if g_MainPlayer == nil then
		return
	end
	if self.FreedomCameraCtrl then
		if (BitAnd(wParam,MK_RBUTTON) ~= 0 and g_GameMain.m_SysSetting.m_MouseSettingWnd.m_MoveLeftFlag) or
			(BitAnd(wParam,MK_LBUTTON) ~= 0 and not g_GameMain.m_SysSetting.m_MouseSettingWnd.m_MoveLeftFlag) then
			local posCursor = CFPos:new()
			g_App:GetRootWnd():GetSysCursorPos(posCursor)
			if GacConfig.SetCameraMouseMoveRange then
				if (self.LastActionCursorPos.x - posCursor.x) > GacConfig.SetCameraMouseMoveRange or
					(self.LastActionCursorPos.x - posCursor.x) < (0-GacConfig.SetCameraMouseMoveRange) or
					(self.LastActionCursorPos.y - posCursor.y) > GacConfig.SetCameraMouseMoveRange or 
					(self.LastActionCursorPos.y - posCursor.y) < (0-GacConfig.SetCameraMouseMoveRange) then
					self.PermitInRangeMouseMove = false
				end
			else
				self.PermitInRangeMouseMove = false
			end
			if self.PermitInRangeMouseMove then
				return
			end
			if self.bMouseLastActionIsButtonDown then
				self:OnTurnRunCameraBegin()
				self.bMouseLastActionIsButtonDown = false
				return
			end
			local posCursorChangedY = posCursor.y - self.m_MousePosY
			local posCursorChangedX = posCursor.x - self.m_MousePosX
			if( posCursorChangedX ==0 and posCursorChangedY == 0 ) or (self.mMouseLastPos == lParam) then
				return
			end
			--why self.mMouseLastPos == lParam û������С�����
			self.mMouseLastPos = lParam
			RenderScene=g_CoreScene:GetRenderScene()
			RenderScene:SetCameraXRotate( RenderScene:GetCameraXRotate() + posCursorChangedY*0.003 )
			RenderScene:SetCameraYRotate( RenderScene:GetCameraYRotate() + posCursorChangedX*0.003 )
			g_GameMain.m_SysSetting.m_KPmap:Moving(true)
			g_App:GetRootWnd():SetSysCursorPos(g_GameMain.m_MousePosX,g_GameMain.m_MousePosY)
		else
			g_GameMain:OnTurnRunCameraEnd()
		end
	end
end

function CGameMain:OnTurnRunCameraInit()
	self.bMouseLastActionIsButtonDown = true
	if self.FreedomCameraCtrl == false and not self.bIsForbidFreedomCamera then
		self.FreedomCameraCtrl = true
		local posCursor = CFPos:new()
		g_App:GetRootWnd():GetSysCursorPos(posCursor)
		self.LastActionCursorPos = posCursor
		
		local nWidth = g_App:GetRootWnd():GetWndWidth()
		local nHeight = g_App:GetRootWnd():GetWndHeight()
		local GameWndRect = CIRect:new()
		g_App:GetRootWnd():GetClientRect(GameWndRect)
		self.m_MousePosX = tonumber(string.format("%d", nWidth/2+GameWndRect.left))
		self.m_MousePosY = tonumber(string.format("%d", nHeight/2+GameWndRect.top))
		g_App:GetRootWnd():ClipCursor(GameWndRect)
		self.PermitInRangeMouseMove = true
	end
end

local function IsForbidFreedomCamera()
	local scenename = g_GameMain.m_SceneName or ""
	local areaname = g_MainPlayer.m_AreaName or ""
	local keys1 = Area_CameraRule_Client:GetKeys()
	for i=1,#(keys1) do
		if keys1[i] == scenename then
			local Keys2 = Area_CameraRule_Client:GetKeys(keys1[1])
			for k=1, #(Keys2) do
				if Area_CameraRule_Client(scenename,Keys2[k]) == areaname then
					return true
				end
			end
		end
	end
	return false
end

function CGameMain:ResetCameraRotate()
	--����bIsForbidFreedomCamera
	local bIsForbid = IsForbidFreedomCamera()
	if self.bIsForbidFreedomCamera == bIsForbid then
		return
	end
	self.bIsForbidFreedomCamera = bIsForbid
	if self.bIsForbidFreedomCamera then
		CRenderSystemClient_Inst():SetFreeCameraEnabled(false)
		--MsgClient(198001)
	else
		CRenderSystemClient_Inst():SetFreeCameraEnabled(true)
		--MsgClient(198002)
	end
end

function CGameMain:OnTurnRunCameraBegin()
	g_App:GetRootWnd():ShowCursor(false)
	g_App:GetRootWnd():SetLockCursorMessage(true)
	g_App:GetRootWnd():SetSysCursorPos(self.m_MousePosX,self.m_MousePosY)
	g_App:GetRootWnd():SetCapture()
	CRenderSystemClient_Inst():SetSelectByCursor(false)
	g_MainPlayer:MoveOnTime_UnRegisterTick()
	g_MainPlayer:RunToMouse_UnRegisterTick()
end

function CGameMain:OnTurnRunCameraEnd()
	if self.FreedomCameraCtrl and self.bMouseLastActionIsButtonDown == false then
		g_App:GetRootWnd():SetSysCursorPos(g_GameMain.LastActionCursorPos.x,g_GameMain.LastActionCursorPos.y)
		g_App:GetRootWnd():ShowCursor(true)
		g_App:GetRootWnd():SetLockCursorMessage(false)
		self.LastActionCursorPos = nil
		self.m_MousePosX = nil
		self.m_MousePosY = nil
	end
	self.FreedomCameraCtrl = false
	g_App:GetRootWnd():ClipCursor(nil)
	g_App:GetRootWnd():ReleaseCapture()
	CRenderSystemClient_Inst():SetSelectByCursor(true)
end

local function OnAutoTrackTick()
	IsSpanSceneAutoTrackState()
end

function CGameMain:OnLoading(fPercent)
	if( fPercent >= 100  ) then
		g_App.m_Loading:ShowWnd( false )
		g_App:GetRootWnd():SetLimitedState( true )
		g_GameMain:ShowWnd( true )
		StopCue("music19") 
		StopCue("music20") 
		SetEvent( Event.Test.EnterGame,true )
		RegisterOnceTick(g_App, "WaitingAutoTrack", OnAutoTrackTick, 350)
	else
		if g_App.m_Loading:IsShow() == false then
			g_App.m_Loading:SetRandomText()
		end
		g_App:GetRootWnd():SetLimitedState( false )
		g_App.m_Loading:ShowWnd( true )
		g_GameMain:ShowWnd( false )
		g_App.m_Loading:SetPos( fPercent )
		CRenderSystemClient_Inst():Refresh()
		--����ط�Ҫˢ��������Ļ����ʾ�Ĳ�����ȷ��ֵ
		CRenderSystemClient_Inst():Refresh()
	end
end

function CGameMain:OnDestroyMainScene()
	g_GameMain:GameMainUnRegisterAccelerator()
	g_GameMain:ClearFrameBeginTransfer()
	--UnRegisterNewRoleTick()
end

function CGameMain:OnMainSceneCreated(CoreScene, appGacHandler)
	local pHandler = CGameSceneHandler:new()
	CoreScene:SetHandler(pHandler)
	g_CoreScene = CoreScene
	g_CoreScene.m_MouseMoveTick = RegClassTick( "MouseMoveTick", appGacHandler.OnSelectPosTick, 100, appGacHandler )
	--��ʼ��С��ͼ
	local sSceneName = g_CoreScene:GetMetaScene():GetSceneName()
	local nWidthInPixel = g_CoreScene:GetMetaScene():GetWidthInGrid() * 64 --��������ģ�ÿ������64������
	local nHeightInPixel = g_CoreScene:GetMetaScene():GetHeightInGrid() * 64 --��������ģ�ÿ������64������
	g_GameMain.m_NavigationMap:InitData()
	g_GameMain.m_NavigationMap:SetSceneData(500, 500, nWidthInPixel, nHeightInPixel, 45, sSceneName)
	
	--ֻ�д�����ɫʱ���Ż����������ҽ�ɫ������ϲ��Ҵ����ɫxpos��ypos
	if ( g_App.m_CreateCharSuc ) then
		local newRolePos = CFPos:new(g_GameMain.NewPlayerXPos, g_GameMain.NewPlayerYPos)
		CPositionFX_CppPlayPosFX("fx/setting/other/other/brith/create.efx", "brith/create", newRolePos)
	end
	SetEvent( Event.Test.SceneCreated , true )
	SetEvent( Event.Test.SceneDestroied , false )
end

function CGameMain:OnMainSceneDestroyed()
	--g_GameMain:ClearFrameBeginTransferAfterMainSceneDestroyed()
	UnRegisterTick( g_CoreScene.m_MouseMoveTick )
	--g_CoreScene:SetHandler(nil)
	g_CoreScene = nil
	
	SetEvent( Event.Test.SceneCreated , false )
	SetEvent( Event.Test.SceneDestroied , true )
end


