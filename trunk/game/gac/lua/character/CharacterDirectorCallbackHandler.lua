gac_gas_require "character/NameColorDef"
gac_gas_require "activity/Trigger/NpcTrigger"
gac_require "smallgames/HeadGames/HeadFishing"
cfg_load "scene/Trap_Common"
cfg_load "sound/SkillFailSound_Client"

CCharacterDirectorCallbackHandler = class( CCharacterClientCallbackHandler, ICharacterDirectorCallbackHandler )

function CCharacterDirectorCallbackHandler:GroundSelector_GetPosX()
	--print("CharacterDirectorCallbackHandler:GroundSelector_GetPosX")
	return GroundSelector.m_vecPos.x
end

function CCharacterDirectorCallbackHandler:GroundSelector_GetPosY()
	--print("CharacterDirectorCallbackHandler:GroundSelector_GetPosY")
	return GroundSelector.m_vecPos.z
end

function CCharacterDirectorCallbackHandler:GroundSelector_IsActive()
	--print("CharacterDirectorCallbackHandler:GroundSelector_IsActive")
	return GroundSelector:IsActive()
end

function CCharacterDirectorCallbackHandler:GroundSelector_CancelSelectGround()
	--print("CharacterDirectorCallbackHandler:GroundSelector_CancelSelectGround")
	GroundSelector:CancelSelectGround()
end

function CCharacterDirectorCallbackHandler:BeginSelectGround(uSelectType, SkillName, SkillLevel, Pos, PositionArea, MaxRange)
	--print("CharacterDirectorCallbackHandler:GroundSelector_BeginSelectGround")
	GroundSelector:CancelSelectGround()
	GroundSelector:SetSkill( SkillName,SkillLevel, Pos, uSelectType)
	if ESelectGroundType.eSGT_GroundSelector == uSelectType and PositionArea >0 then
		GroundSelector:BeginSelectGround(PositionArea, MaxRange)
	elseif ESelectGroundType.eSGT_TargetSelector == uSelectType then
		GroundSelector:BeginSelectTargetSelector(MaxRange)
	elseif ESelectGroundType.eSGT_MouseSelector == uSelectType or PositionArea == 0 then
		GroundSelector:BeginSelectMouseSelector()
	end
end

function CCharacterDirectorCallbackHandler:OnCoolDownBegin(SkillName, eCoolDownType, LeftTime)
	if eCoolDownType == ESkillCoolDownType.eSCDT_DrugItemSkill or eCoolDownType == ESkillCoolDownType.eSCDT_OtherItemSkill 
		or eCoolDownType == ESkillCoolDownType.eSCDT_SpecialItemSkill then
		g_GameMain.m_WndMainBag.m_ctItemRoom:SetCoolTimeBtn(SkillName, eCoolDownType, LeftTime)
	end
	
	if PosSkillNameTbl[SkillName] then	
		if g_GameMain.m_MainSkillsToolBar.m_CurrentPage ~= PosSkillNameTbl[SkillName] then
			g_GameMain.m_BeastPoseWnd.m_BgBtnTbl[g_GameMain.m_MainSkillsToolBar.m_CurrentPage]:DelFlashAttention()
			g_GameMain.m_MainSkillsToolBar.m_CurrentPage = PosSkillNameTbl[SkillName]
			g_GameMain.m_BeastPoseWnd.m_BgBtnTbl[PosSkillNameTbl[SkillName]]:AddFlashInfoByName("OrangeEquip")
			g_GameMain.m_BeastPoseWnd:UpdateBeastPosToolBar()
		end
	end	
	g_GameMain.m_MainSkillsToolBar:setCoolTimerBtn(SkillName,eCoolDownType,LeftTime)	
	--��ʱ��ˢcd
	g_GameMain.m_TempSkill:SetSkillCdDisplay(SkillName,LeftTime)
	--�Ⱦ����
	if g_GameMain.m_ShootProgressWnd.m_Tick and SkillName == g_GameMain.m_ShootProgressWnd.m_DrinkSkill then
		g_GameMain.m_ShootProgressWnd:DoDrink()
	end
end

function CCharacterDirectorCallbackHandler:OnCoolDownEnd(SkillName)
	--print("CharacterDirectorCallbackHandler:OnCoolDownEnd")
	g_GameMain.m_MainSkillsToolBar:ResetCoolTimerBtn(SkillName)
end

function CCharacterDirectorCallbackHandler:OnAllCoolDownEnd()
	--print("CharacterDirectorCallbackHandler:OnAllCoolDownEnd")
	g_GameMain.m_MainSkillsToolBar.m_WndSkill:setZeroCoolTimer()
	g_GameMain.m_MasterSkillArea.m_WndSkill:setZeroCoolTimer()
	g_GameMain.m_AddMasterSkillArea.m_WndSkill:setZeroCoolTimer()
	--g_GameMain.m_WndMainBag.m_ctItemRoom:ResetCD()
end

function CCharacterDirectorCallbackHandler:OnClearCommonCD()
	g_GameMain.m_MainSkillsToolBar:OnClearCommonCD()
	g_GameMain.m_MasterSkillArea:OnClearCommonCD()
	g_GameMain.m_AddMasterSkillArea:OnClearCommonCD()
end

function CCharacterDirectorCallbackHandler:OnStanceSkill()
	--print("CharacterDirectorCallbackHandler:OnStanceSkill")
	g_GameMain.m_PlayerInfo:UpdateHeadInfo()
end

function CCharacterDirectorCallbackHandler:OnCreated(Character, IsBattleHorse)

	assert(Character)
	g_MainPlayer = Character;		
--	print("�ҵ�IDΪ", g_MainPlayer:GetEntityID())

	Character.m_CallbackHandler = CCharacterDirectorCallbackHandler:new()
	Character:SetCallbackHandler(Character.m_CallbackHandler)
	Character:SetCanBeSelected( false )
	Character.m_Properties = CPlayerProperties:new()
	Character.m_Properties:Init(Character)
	Character.m_Properties:InitSync()
	Character:SetIsPlayer(true)
	Character:SetActionFxFile("fx/setting/wf/"..GetRaceSexTypeString(Character:CppGetClass(), Character.m_Properties:GetSex()) .. "/")
	--������ʱҲ��Ҫ������ͨ�������ñ����
	local Class = Character:CppGetClass()
	local RenderObj = Character:GetRenderObject()
	InitPlayerBaseAni(RenderObj, Character:CppGetClass(), Character.m_Properties:GetSex(), nil)
	local ArpFileName =  MakeAniFileName(Character:CppGetClass(),Character.m_Properties:GetSex(),nil)
	Character:SetSpliceName(ArpFileName.."_skill/")
	Character:SetSkillFxFile("fx/setting/skill/"..ArpFileName.."_skill/")
	if Class == EClass.eCL_Warrior then
		Character:SetMHNACfg("��ʿ��ͨ����",2,"","")
	elseif Class == EClass.eCL_MagicWarrior then
		Character:SetMHNACfg("ħ��ʿ��ͨ����",2,"","")
	elseif Class == EClass.eCL_Paladin then
		Character:SetMHNACfg("������ʿ��ͨ����",2,"", "")
	elseif Class == EClass.eCL_NatureElf then
		Character:SetMHNACfg("��ʦ��ͨ����",2,"", "")
	elseif Class == EClass.eCL_EvilElf then
		Character:SetMHNACfg("аħ��ͨ����",2,"", "")
	elseif Class == EClass.eCL_Priest then
		Character:SetMHNACfg("��ʦ��ͨ����",2,"", "")
	elseif Class == EClass.eCL_ElfHunter then
		Character:SetMHNACfg("���鹭������ͨ����",2,"", "")
	elseif Class == EClass.eCL_DwarfPaladin then
		Character:SetMHNACfg("������ʿ��ͨ����",2,"", "")
	elseif Class == EClass.eCL_OrcWarrior then
		Character:SetMHNACfg("����սʿ��ͨ����",2,"", "")
	end	
	
	Character.m_NpcInVisionTbl = {}             --�����ȼ��Զ�ʰȡ������Ʒ 
	Character.m_IntObjInVisionTbl = {}         --���ڸ��½����������״̬�������ʾ
	Character.m_LockCenter							= {}		-- ����������ϵ�в���
	Character.m_LockCenter.m_LockingObj	= nil					-- ��ǰ��������
	Character.m_LockCenter.m_EffectId	 = nil					-- ������Ȧ����ЧMask
	Character.m_LockCenter.m_TouchAttack	 = false			-- Touch ���Ƿ񹥻�
	Character.m_LockCenter.m_TouchAttack_SkillId	= 0			-- ������,����ʱ��SkillId
	Character.m_LockCenter.m_TouchCallBack	= false				-- Touch ���Ƿ���Ҫ�ص�
	Character.m_LockCenter.m_StopDistance		= 1				-- ׷��ֹͣ���� ��:��
	Character.m_LockCenter.m_TargetPosition		= {}			-- �����ص�
	Character.m_LockCenter.m_TargetPosition.x	= 0				-- ����
	Character.m_LockCenter.m_TargetPosition.y	= 0
	Character.m_LockCenter.m_TargetPosition.z	= 0
	Character.m_AttackInfo							= {}		-- ����ʩ�������Ϣ
	Character.m_AttackInfo.LockObj			= nil				--	����Ŀ��		
	Character.m_NameColor = ECharNameColor.eCNC_Blue			-- ������ɫ
	Character.m_SkillReplaceTbl = {}										--�����滻��Ϣ
	g_GameMain.m_NavigationMap:UpdatePlayerPosInSmallMap()
	--���ý�ɫ�ĳ�ʼ����
	
	Character.m_StaticPerfomer = {}								-- ��̬�����߶����б�
	
	SetEvent( Event.Test.ObjectCreated , true )
	g_GameMain.m_SmallMapBG.m_Static:SetMainPlayer(g_MainPlayer:GetEntityID())
	Character:GetHorseRenderObj():SetDirection( CDir:new( 160 ) )
	g_MainPlayer:AddHeadBloodRendler(g_MainPlayer, g_GameMain.m_BloodRenderDialogPool, g_GameMain, g_GameMain.BloodRenderWndIsShow)
	g_GameMain.m_CharacterInSyncMgr:SetHeadBloodTransparentFun(g_MainPlayer,false)
	g_MainPlayer:SetAgileValueBeCare(true)
	g_GameMain.m_PlayerInfo:Show(true)
	g_GameMain.m_PlayerInfo:InitHeadInfo()
	g_GameMain.m_PlayerInfoTbl = {}
	g_GameMain.m_PlayerInfoTbl.m_PlayerLevel = g_MainPlayer:CppGetLevel()
	g_GameMain.m_PlayerInfoTbl.m_PlayerBirthCamp = g_MainPlayer:CppGetBirthCamp()
	g_GameMain.m_PlayerInfoTbl.m_PlayerCharName = g_MainPlayer.m_Properties:GetCharName()
	g_GameMain.m_PlayerInfoTbl.m_PlayerCharID = g_MainPlayer.m_Properties:GetCharID()
	g_GameMain.m_PlayerInfoTbl.m_PlayerClassID = g_MainPlayer:CppGetClass()
	g_GameMain.m_PlayerInfoTbl.m_PlayerSex = g_MainPlayer.m_Properties:GetSex()
	g_GameMain.m_PlayerInfoTbl.m_PlayerMoney = g_MainPlayer:GetMoney()
	g_MainPlayer.m_uMercenaryLevel = 0
	g_GameMain.m_BeastPoseWnd = CBeastPoseWnd:new(g_GameMain)
	g_GameMain.m_BeastPoseWnd:InitPosSkillIcon(Class)
end

function CCharacterDirectorCallbackHandler:OnCreatedEnd(Character)
	--����������ʾ��������
	if Character == g_MainPlayer then
		SetHintMsgWndText()
	end
end

function CCharacterDirectorCallbackHandler:OnDestroy(Character)
--	print("CCharacterDirectorCallbackHandler:OnDestroy", Character:GetEntityID())
	if g_GameMain.m_Buff then
		g_GameMain.m_Buff:ClearAllBuffState() --��ɫ��buff�������
	end
	g_GameMain.m_skillProgress_Load:UnRegisterTick()
	
	Character.m_Properties:OutOfSync()
	g_GameMain.m_SmallMapBG.m_Static:SetMainPlayer(0)
	
	PopNpcHeadUpDialog(g_MainPlayer)
	
	g_GameMain.m_CharacterInSyncMgr:DestroyPlayerHeadInfo()
	g_GameMain.m_TeamMarkSignMgr:DestroySelfTeamMark()
	--g_GameMain:ClearFrameBeginTransfer()
	
	if Character ~= nil then
		Character:Unit()
	end
	--ע���������Tick
	if g_GameMain.m_MainSkillsToolBar ~= nil then
		g_GameMain.m_MainSkillsToolBar.m_WndSkill:UnRegisterToolBar()
	end
	if g_GameMain.m_MasterSkillArea ~= nil then
		g_GameMain.m_MasterSkillArea.m_WndSkill:UnRegisterToolBar()
	end
	if g_GameMain.m_AddMasterSkillArea ~= nil then
		g_GameMain.m_AddMasterSkillArea.m_WndSkill:UnRegisterToolBar()
	end
	if g_GameMain.m_CreateChatWnd.m_ImportMsg ~= nil then
		g_GameMain.m_CreateChatWnd.m_ImportMsg:UnRegisterImportMsg()
	end	
	
	Character = nil
	g_MainPlayer = nil
	
end

function CCharacterDirectorCallbackHandler:OnTransfered(Character)
	--print("CCharacterDirectorCallbackHandler:OnTransfered", Character:GetEntityID())
	local nFromSceneType = g_GameMain.m_SceneType
	local SceneName = g_GameMain.TargetSceneName
	local SceneType = Scene_Common[SceneName].SceneType
	if SceneType == 25 then
		g_GameMain.m_SceneName = Scene_Common[SceneName].BasicName
	else
		g_GameMain.m_SceneName = SceneName
	end
	
	g_GameMain.m_SceneType = SceneType
	g_GameMain.TargetSceneName = nil
	g_MainPlayer.m_Properties = nil
	g_MainPlayer:SetCanBeSelected( false )
	g_MainPlayer.m_Properties = CPlayerProperties:new()
	g_MainPlayer.m_Properties:Init(g_MainPlayer)
	g_MainPlayer.m_Properties:InitSync()
	local RenderObj = g_MainPlayer:GetRenderObject()
	InitPlayerBaseAni(RenderObj, g_MainPlayer:CppGetClass(), g_MainPlayer.m_Properties:GetSex(), nil)
	UpdateModel(g_MainPlayer)
	UpdateFollowerCoreInfo(g_MainPlayer)
	g_GameMain.m_MainSkillsToolBar.m_WndSkill:LoadShortcutPieces()
	g_GameMain.m_MasterSkillArea.m_WndSkill:LoadShortcutPieces()
	g_GameMain.m_AddMasterSkillArea.m_WndSkill:LoadShortcutPieces()
	g_GameMain.m_GuideBtn:OnTransfered(nFromSceneType, SceneType)
	if g_GameMain.m_IsTransfer then
		g_GameMain:EndTransfer()
		local RenderScene = g_CoreScene:GetRenderScene()
		RenderScene:InitSceneRes()
	end
end

function CCharacterDirectorCallbackHandler:OnBeginTransfer(Character,SceneName)
	--print("CCharacterDirectorCallbackHandler:OnBeginTransfer", Character:GetEntityID())
	g_GameMain.m_IsTransfer = true
	g_GameMain.TargetSceneName = SceneName
	if g_GameMain.m_MainSkillsToolBar ~= nil then
		g_GameMain.m_MainSkillsToolBar.m_WndSkill:UnRegisterToolBar()
	end
	if g_GameMain.m_MasterSkillArea ~= nil then
		g_GameMain.m_MasterSkillArea.m_WndSkill:UnRegisterToolBar()
	end
	if g_GameMain.m_AddMasterSkillArea ~= nil then
		g_GameMain.m_AddMasterSkillArea.m_WndSkill:UnRegisterToolBar()
	end
	if g_GameMain.m_skillProgress_Load then
		g_GameMain.m_skillProgress_Load:UnRegisterTick()	--��������Tick
	end
	if g_GameMain.m_TargetInfo then
		g_GameMain.m_TargetInfo:UnRegisterTick()			--Ŀ��ͷ������Tick
	end
	if g_GameMain.m_TargetOfTargetInfo then
		g_GameMain.m_TargetOfTargetInfo:UnRegisterTick()	--Ŀ���Ŀ��ͷ������Tick
	end
end

function CCharacterDirectorCallbackHandler:OnMagicCondFail(uMessageID,sSkillName)
	--print("CCharacterDirectorCallbackHandler:OnMagicCondFail", uMessageID)
	
	--������ʾ
	--local voiceOpen = CRenderSystemClient_Inst():GetVoiceSwitch()
	local voiceOpen = false
	if voiceOpen then
		local curSkillFailVoice = g_MainPlayer.m_CurSkillFailVoice
		local readyPlay = false
		if CueIsStop(curSkillFailVoice) or curSkillFailVoice == nil then
			readyPlay = true
		end	
		if readyPlay then
			local voice = SkillFailSound_Client(uMessageID, "Voice")
			if voice and voice ~= "" then
				local tail = CPlaySoundOfWarning.GetVoiceSourceFileSuffix()
				voice = voice .. tail
				PlayCue(voice)
				g_MainPlayer.m_CurSkillFailVoice = voice
			end
		end	
	end
	
	CSoundCDTimeMgr_PlaySound("skillerorr", 1200)
	MsgClient(uMessageID)
	if g_GameMain and g_GameMain.m_MainSkillsToolBar then
		g_GameMain.m_MainSkillsToolBar:ResetCoolTimerBtn(sSkillName,true)
	end
end

function CCharacterDirectorCallbackHandler:OnLostTarget()
	g_MainPlayer:UnLockObj()
end

function CCharacterDirectorCallbackHandler:OnGridPosChange()
	--print("CCharacterDirectorCallbackHandler:OnGridPosChange")
	PlayerMoveChangeAreaInfo()
  g_GameMain.m_NavigationMap:UpdatePlayerPosInSmallMap()
	g_GameMain.m_ChallengeCompass:SmallArrowHeadDir()
	CGamePromptWnd:ShowPromptwnd()
	local playerPos = CFPos:new()
	g_MainPlayer:GetPixelPos(playerPos)
	local trapPos = CFPos:new()
	local lv = g_MainPlayer:CppGetLevel()
	for trap, transInfo in pairs(g_GameMain.m_TransportTrap) do
		trap:GetPixelPos(trapPos)
		local trapName = trap.m_Properties:GetCharName()
		local range = Trap_Common(trapName, "AoiRange") * EUnits.eGridSpanForObj
		local dx = trapPos.x - playerPos.x
		local dy = trapPos.y - playerPos.y
		if dx * dx + dy * dy <  range * range  then
			
--			local questName = Trap_Common(trapName, "CorrelationQstName")
			local ConditionTbl = GetTriggerCondition("Trap", trapName, "��", "��������")
			local QuestNameTbl = ConditionTbl and ConditionTbl.Arg
			local questName = QuestNameTbl and QuestNameTbl[1]
			for _, type in pairs(transInfo:GetKeys()) do
				for _, i in pairs(transInfo(type):GetKeys()) do
					if (questName == nil or questName == "" or g_GameMain.m_QuestRecordWnd.m_DoingQuestInfo[questName] )
						and (transInfo(type, i.."", "LeastLev") == "" or lv >= transInfo(type, i.."", "LeastLev"))
						and (transInfo(type, i.."", "MaxLev") == "" or lv <= transInfo(type, i.."", "MaxLev")) then
						PrepareChangeScene()
						break
					end
				end
			end
		end
	end
end

function CCharacterDirectorCallbackHandler:OnLevelUp(nLevelChanged)
	local uDesLevel = g_MainPlayer:CppGetLevel()
	local nClass = g_MainPlayer:CppGetClass()
	local uCurMaxHP=CStaticAttribMgr_CalcBasicMaxHealthPoint(nClass,uDesLevel - nLevelChanged)
	local uCurMaxMP=CStaticAttribMgr_CalcBasicMaxManaPoint(nClass,uDesLevel - nLevelChanged)
	local uDesMaxHP=CStaticAttribMgr_CalcBasicMaxHealthPoint(nClass,uDesLevel )
	local uDesMaxMP=CStaticAttribMgr_CalcBasicMaxManaPoint(nClass,uDesLevel )
	
	g_GameMain.m_PlayerInfoTbl.m_PlayerLevel = uDesLevel
	
	local Wnd = g_GameMain.m_RoleStatus
	if Wnd:IsShow() then
		local viewinfoMgr = CFighterViewInfoMgr.GetWnd()
		local viewInfo = viewinfoMgr:GetFightViewInfoByID(g_MainPlayer:GetEntityID())
		viewInfo:CppInit(g_MainPlayer:GetEntityID())
		Wnd:UpdateAllRoleInfo()
	end
	
	--ˢ�°���tooltips
	g_GameMain.m_WndMainBag.m_ctItemRoom:UpdateBagTips()
	
	--ˢ�¿����tooltips
	if g_GameMain.m_MasterSkillArea then
		g_GameMain.m_MasterSkillArea.m_WndSkill:UpdateTips()
	end
	if g_GameMain.m_AddMasterSkillArea then
		g_GameMain.m_AddMasterSkillArea.m_WndSkill:UpdateTips()
	end	
	if g_GameMain.m_MainSkillsToolBar then
		g_GameMain.m_MainSkillsToolBar.m_WndSkill:UpdateTips()
	end	
	
	if g_GameMain.m_BeastPoseWnd:IsShow() then
		g_GameMain.m_BeastPoseWnd:UpdateSkillBtnPicture(uDesLevel)
	end
	
	if g_GameMain.m_SelectSeriesWnd then
		g_GameMain.m_SelectSeriesWnd:SetTalentNumber()
	end
	if g_GameMain.m_stone then
		g_GameMain.m_stone:OnPlayerLevelUp()
	end
	
	local DamageSkillTbl={}
	local LearnSkillTbl ={}
	if  g_GameMain.m_LearnSkillTbl then
		local CurLevel = g_MainPlayer:CppGetLevel()
		local nClass = g_MainPlayer:CppGetClass()
		local Keys = SkillPart_Common:GetKeys()	
		for i ,p in pairs(Keys) do
			if nClass == SkillPart_Common(p,"ClassLimit") and SkillPart_Common(p,"SkillLearnType") == 4 
				and SkillPart_Common(p,"NeedLevel") <= CurLevel then
				local IsLearnSkill = false
				for j = 1,#(g_GameMain.m_LearnSkillTbl) do
					if g_GameMain.m_LearnSkillTbl[j][1] == p then
						IsLearnSkill = true
						if SkillPart_Common(p,"SkillDesArg3") ~= -1 then
							table.insert(DamageSkillTbl,p)
						end
						break
					end
				end
				if not IsLearnSkill then
					table.insert(LearnSkillTbl,p)
				end
			elseif nClass == SkillPart_Common(p,"ClassLimit") and SkillPart_Common(p,"SkillLearnType") == 1 then
				for j = 1,#(g_GameMain.m_LearnSkillTbl) do
					if g_GameMain.m_LearnSkillTbl[j][1] == p then
						if SkillPart_Common(p,"SkillDesArg3") ~= -1 then
							table.insert(DamageSkillTbl,p)
						end
						break
					end
				end
			end
		end		
	end
	
	if g_GameMain.m_SelectSeriesWnd then
		g_GameMain.m_SelectSeriesWnd:UpdateMainSeriesWnd()
	end

	if nLevelChanged ~= 0 then
--		Gac2Gas:UpdatePlayerDirect(g_Conn)
		if g_GameMain.m_LeadLeanSkillWnd then
			g_GameMain.m_LeadLeanSkillWnd:InitData()
		end
		--�������������ʾ��ʾ��Ϣ
		if g_GameMain.m_RoleLevelAttentionWnd then
			g_GameMain.m_RoleLevelAttentionWnd:UpdateLevelPanel({nLevelChanged,uDesMaxHP,uCurMaxHP,uDesMaxMP,uCurMaxMP})
		else
			g_GameMain.m_RoleLevelAttentionWnd = CRoleLevelUp:new(g_GameMain,{nLevelChanged,uDesMaxHP,uCurMaxHP,uDesMaxMP,uCurMaxMP})
		end
		g_GameMain.m_ToolsMallWnd:UpdatePlayerLevel()
		local RenderObj = g_MainPlayer:GetRenderObject()
		RenderObj:AddEffect("fx/setting/other/other/brith/create.efx","brith/create",0,nil)
		g_GameMain.m_NpcHeadSignMgr:UpdateNpcAndObjInView()
		g_GameMain.m_QuestTraceBack:ReFreshQuestList()
		
		-- ���ʾ���
		local PlayerLevel = g_MainPlayer:CppGetLevel()
		if PlayerLevel == 15 
			or PlayerLevel == 20
			or PlayerLevel == 25
			or PlayerLevel == 30
			or PlayerLevel == 40 then
			g_GameMain.m_FbActionPanel:PopupActionPanel("LevelUp")
		end
		
		-- �е�ͼ�ı�˵�ѡ��
--		if PlayerLevel == 20 then
--			g_GameMain.m_AreaInfoWnd:SelectAllMiddleMapMenu()
--		end
		
		g_GameMain.m_GuideBtn:BeAlertLevelUp() --����
		g_GameMain.m_GuideData:CheckConditionBeDone() --����
	end
end

function CCharacterDirectorCallbackHandler:OnArrayValueChange(sName,uTotalValue,uCurValue,uSpeed)
	--print("OnArrayValueChange", sName,uTotalValue,uCurValue,uSpeed)
	if uTotalValue <=0 and uCurValue <=0 then
		g_GameMain.m_skillProgress_Load:OnDesLoading()
		return
	end
	if uSpeed == 0 then
		g_GameMain.m_skillProgress_Load:OnPause()
		return
	end
	local RemainTime=uTotalValue/uSpeed
	local FinishPercent=(uTotalValue-uCurValue)/uTotalValue
	g_GameMain.m_skillProgress_Load:OnSelfCastBegin(g_MainPlayer, sName, 1, RemainTime, RemainTime* FinishPercent)
end

function CCharacterDirectorCallbackHandler:OnPrintFightInfo(pFightInfoData)
	-- ��ʱ����ս����Ϣ��ӡ	
	if g_MainPlayer ~= nil then
		local FightInfoWnd = CFightInfoWnd.GetWnd()
		
		if pFightInfoData:GetObj1ID() == g_MainPlayer:GetEntityID() and FightInfoWnd:IsHPChangeRelated(pFightInfoData:GetInfoIndex()) then
			g_MainPlayer.m_iHPLatestChange = 0
			--g_MainPlayer.m_iHPLatestChange = pFightInfoData:GetHPChanged()
		end 
		FightInfoWnd:OnPrintFightInfo(pFightInfoData)
		local StatisticFightWnd = CStatisticFightInfoWnd.GetWnd()
		StatisticFightWnd:JointStatisticFightInfo(pFightInfoData)
	end
end

function CCharacterDirectorCallbackHandler:OnSetAutoNormalAttack(bAutoNA)
	g_GameMain.m_MainSkillsToolBar.m_WndSkill:UpdateCommonlySkill(bAutoNA)
	g_GameMain.m_MasterSkillArea.m_WndSkill:UpdateCommonlySkill(bAutoNA)
	g_GameMain.m_AddMasterSkillArea.m_WndSkill:UpdateCommonlySkill(bAutoNA)
end

function CCharacterDirectorCallbackHandler:OnMagicCondFailOnTick(szSkillName, bSucc) --���ܿ����趨
	g_GameMain.m_MainSkillsToolBar:SetShortCutSkillState(szSkillName,not bSucc)
end

function CCharacterDirectorCallbackHandler:OnMoveSuccessed()
	--print("CCharacterDirectorCallbackHandler:OnMoveSuccessed")
	g_GameMain.m_LastMoveToPos = nil
	if g_GameMain.m_PrepareChangeTick then
		g_MainPlayer:GetRenderObject():DoAni("huifu01",true,-1.0)
	end
--	if g_MainPlayer.m_tblOweAStarOptiPathFinding then
--		local pixelPos = CFPos:new()
--		pixelPos.x = g_MainPlayer.m_tblOweAStarOptiPathFinding[1]
--		pixelPos.y = g_MainPlayer.m_tblOweAStarOptiPathFinding[2]
--		IntAutoTrackToPosByHypoAStarOpti(g_GameMain.m_SceneName,pixelPos)
--		return
--	end
	
	if g_SpanSceneAutoTrackMgr.m_AutoTrackToPointName then
		AutoTrackToFuncNpc(g_SpanSceneAutoTrackMgr.m_AutoTrackToPointName)
	end
	if g_SpanSceneAutoTrackMgr.m_AutoTrackToGridPoint then
		MoveEndCheckAutoTrackState()
	end

	-- ���߻���
	if g_MainPlayer:IsMovingByKeyboard() then
		g_MainPlayer:MoveByGlide()
	else
		g_MainPlayer:MoveByGlide_UnRegisterTick()
	end

	if g_MainPlayer.m_HeadGameName then
		BeginHeadGame()
	end
end

function CCharacterDirectorCallbackHandler:OnMoveStopped()
	--print("CCharacterDirectorCallbackHandler:OnMoveStopped ")
	g_GameMain.m_LastMoveToPos = nil
	if g_GameMain.m_PrepareChangeTick then
		g_MainPlayer:GetRenderObject():DoAni("huifu01",true,-1.0)
	end
end

function CCharacterDirectorCallbackHandler:OnDead(uEntityID)
	--print("CCharacterDirectorCallbackHandler:OnDead ", uEntityID)
	g_MainPlayer:UnLockTarget()
	g_GameMain.m_PlayerInfo.m_PlayHPFxFlag = false
	g_App:GetRootWnd():DelScreenFx("hpguodi/create")
	StopCue("heartbeat") 
	--CCharacterFollowerCallbackHandler:OnDead(uEntityID)
	if g_GameMain.m_QihunjiZhiyinWnd:IsShow() then
		g_GameMain.m_QihunjiZhiyinWnd:RetShowQihunjiZhiyinWnd(false)
	end
end

function CCharacterDirectorCallbackHandler:OnReborn(uEntityID)
	--print("CCharacterDirectorCallbackHandler:OnReborn ", uEntityID)
	--local level = g_MainPlayer:CppGetLevel()
	--if level <= 5 then
	--	g_GameMain.m_HeadHelpWnd:ShowHeadHelpWnd("5��ǰ��ʳ��ʾ")
	--end
	if g_MainPlayer:GetEntityID() == uEntityID then
		local RenderObj = g_MainPlayer:GetRenderObject()
		RenderObj:AddEffect("fx/setting/other/other/brith/create.efx","brith/create",0,nil)
	end
end

local function UpdateToolBarInfo()
	g_GameMain.m_MainSkillsToolBar.m_WndSkill:LoadShortcutPieces()
	g_GameMain.m_MasterSkillArea.m_WndSkill:LoadShortcutPieces()
	g_GameMain.m_AddMasterSkillArea.m_WndSkill:LoadShortcutPieces()
end

function CCharacterDirectorCallbackHandler:OnReplaceSkill(szSkillName, szReplaceSkillName, bReplace)
	if bReplace then
		g_MainPlayer.m_SkillReplaceTbl[szSkillName] = szReplaceSkillName
	elseif g_MainPlayer.m_SkillReplaceTbl[szSkillName] == szReplaceSkillName then
		g_MainPlayer.m_SkillReplaceTbl[szSkillName] = nil
	end
	UpdateToolBarInfo()
end

function CCharacterDirectorCallbackHandler:OnBurstSoulTimesChanged(uBurstSoulTimes)
	g_GameMain.m_BurstSoulWnd:UpdateInfo(uBurstSoulTimes)
end

function CCharacterDirectorCallbackHandler:ChangeServant(eType, uMasterID, uServantID, uCreate)
	local Character = CCharacterFollower_GetCharacterByID(uMasterID)
	local Servant = CCharacterFollower_GetCharacterByID(uServantID)
	if Servant and Servant:IsBattleHorse() then
		g_MainPlayer:AddCharacterFollowerToSet(Servant)
	end
	if( Character:GetType()== EClientObjectType.eCOT_Director) then
		local tblWnd = {	[ENpcType.ENpcType_Summon]			= CServantInfo.GetWnd(),
							[ENpcType.ENpcType_BattleHorse]		= CBattleHorseInfo.GetWnd(),
							[ENpcType.ENpcType_Truck]			= CTruckInfo.GetWnd(),
							[ENpcType.ENpcType_OrdnanceMonster]	= COrdnanceMonsterInfo.GetWnd(),
							[ENpcType.ENpcType_Cannon]			= CCannonInfo.GetWnd()	}
		local wnd = tblWnd[eType]
		if ( wnd ) then
			if ( uCreate ) then
				wnd:OnServantCreated()
			else
				wnd:OnServantDestoryed()
			end
		end
	end
	
	if Servant and Servant:GetMaster() == g_MainPlayer then
		Servant:SetAgileValueBeCare(true)
		Servant:GetRenderObject():SetAlphaValue(255)
		Servant:GetRenderObject():Update()
		local NpcName = Servant.m_Properties:GetCharName()
		if Npc_Common(NpcName, "ShowBloodType") ~= 1 and Npc_Common(NpcName, "ShowBloodType") ~= 2 then
			Servant:SetCanBeSelected(true)
		end
		
		g_MainPlayer:ChangeCharacterFollowerList(Servant)
		g_MainPlayer:ChangeHideModeOnRelationChanged(Servant)
	end
end
