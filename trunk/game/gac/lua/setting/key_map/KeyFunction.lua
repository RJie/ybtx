gac_gas_require "item/store_room_cfg/StoreRoomCfg"

function MoveUp(bForce)
	local pos = CFPos:new()
	g_MainPlayer:GetPixelPos(pos)
	pos.x=pos.x+EUnits.eGridSpanForObj*1.414/2
	pos.y=pos.y+EUnits.eGridSpanForObj*1.414/2
	g_MainPlayer:BeforeMoveToSelectPos(pos, EDirectionWord.Up, bForce)
end

function MoveDown(bForce)
	local pos = CFPos:new()
	g_MainPlayer:GetPixelPos(pos)
	pos.x=pos.x-EUnits.eGridSpanForObj*1.414/2
	pos.y=pos.y-EUnits.eGridSpanForObj*1.414/2
	g_MainPlayer:BeforeMoveToSelectPos(pos, EDirectionWord.Down, bForce)
end

function MoveLeft(bForce)
	local pos = CFPos:new()
	g_MainPlayer:GetPixelPos(pos)
	pos.x=pos.x-EUnits.eGridSpanForObj*1.414/2
	pos.y=pos.y+EUnits.eGridSpanForObj*1.414/2
	g_MainPlayer:BeforeMoveToSelectPos(pos, EDirectionWord.Left, bForce)
end

function MoveRight(bForce)
	local pos = CFPos:new()
	g_MainPlayer:GetPixelPos(pos)
	pos.x=pos.x+EUnits.eGridSpanForObj*1.414/2
	pos.y=pos.y-EUnits.eGridSpanForObj*1.414/2
	g_MainPlayer:BeforeMoveToSelectPos(pos, EDirectionWord.Right, bForce)
end

function MoveLeftUp(bForce)
	local pos = CFPos:new()
	g_MainPlayer:GetPixelPos(pos)
	pos.y=pos.y+EUnits.eGridSpanForObj
	g_MainPlayer:BeforeMoveToSelectPos(pos, EDirectionWord.LeftUp, bForce)
end

function MoveLeftDown(bForce)
	local pos = CFPos:new()
	g_MainPlayer:GetPixelPos(pos)
	pos.x=pos.x-EUnits.eGridSpanForObj
	g_MainPlayer:BeforeMoveToSelectPos(pos, EDirectionWord.LeftDown, bForce)
end

function MoveRightUp(bForce)
	local pos = CFPos:new()
	g_MainPlayer:GetPixelPos(pos)
	pos.x=pos.x+EUnits.eGridSpanForObj
	g_MainPlayer:BeforeMoveToSelectPos(pos, EDirectionWord.RightUp, bForce)
end

function MoveRightDown(bForce)
	local pos = CFPos:new()
	g_MainPlayer:GetPixelPos(pos)
	pos.y=pos.y-EUnits.eGridSpanForObj
	g_MainPlayer:BeforeMoveToSelectPos(pos, EDirectionWord.RightDown, bForce)
end

function SelectAimTarget()
	if g_MainPlayer then
		--����ڽ���С��Ϸ
		if g_GameMain and (g_GameMain.m_SmallGame or g_GameMain.m_DoSmallGame) then
			return
		end
		if g_MainPlayer.m_LockCenter.m_LockingObj == nil or g_MainPlayer.TabAgain then
			g_MainPlayer:SortTargetList()
			g_MainPlayer.TabAgain = false
		end
		local tempTarget = g_MainPlayer.m_LockCenter.m_LockingObj
		g_MainPlayer:SelectAimTarget()
		if tempTarget ~= g_MainPlayer.m_LockCenter.m_LockingObj then
			g_MainPlayer:CancelNormalAttack()
		end
	end
end

function SelectFriendTarget()
	if g_MainPlayer then
		--����ڽ���С��Ϸ
		if g_GameMain and (g_GameMain.m_SmallGame or g_GameMain.m_DoSmallGame) then
			return
		end
		if g_MainPlayer.m_LockCenter.m_LockingObj == nil or g_MainPlayer.TabAgain then
			g_MainPlayer:SortTargetList()
			g_MainPlayer.TabAgain = false
		end
		g_MainPlayer:SelectFriendTarget()
	end
end

function ShowAllBlood()
	if not g_MainPlayer then
		return
	end
	if not g_GameMain.BloodRenderWndIsShow then
		g_GameMain.BloodRenderWndIsShow = true
		g_MainPlayer:ShowHeadBloodDialog(true)
	else
		g_GameMain.BloodRenderWndIsShow = false
		g_MainPlayer:ShowHeadBloodDialog(false)
	end
end

--�����л� Z
function ChangeMoveState()
	if g_MainPlayer then
		if g_MainPlayer:CppGetCtrlState(EFighterCtrlState.eFCS_InWalkState) then
			g_MainPlayer:ChangeMoveMode(false)
		else
			g_MainPlayer:ChangeMoveMode(true)
		end
	end
end

--�հ����� Q
function TakeArm()
	if g_MainPlayer then
		g_MainPlayer:ChangeDrawWeaponMode(false)
	end
end

--�л��˺���Ч��ʾ���
function ChangeShowHurtMOD()
	if g_MainPlayer then
		g_MainPlayer:ChangeShowHurtMOD()
		local Wnd = g_GameMain.m_CreateChatWnd.m_CChatWnd
		if not g_GameMain.m_SysSetting.m_KPmap.IsShowHurt then
			g_GameMain.m_SysSetting.m_KPmap.IsShowHurt = true
			table.insert(Wnd.ChatInfoTbl[3] ,GetStaticTextClient(4501) .. "#r")
			g_GameMain.m_CreateChatWnd.m_CChatWnd:ChatInfoShow()
		else
			g_GameMain.m_SysSetting.m_KPmap.IsShowHurt = false
			table.insert(Wnd.ChatInfoTbl[3] ,GetStaticTextClient(4500) .. "#r")
			g_GameMain.m_CreateChatWnd.m_CChatWnd:ChatInfoShow()
		end
	end
end

--ALT+""��ϼ�����
function TestALT()
--	print("TestALT")
end

function OpenFightInfoWnd()
	local FightInfoWnd = CFightInfoWnd.GetWnd()
	if(FightInfoWnd:IsShow())then
		FightInfoWnd:ShowWnd(false)
	else
		FightInfoWnd:ShowWnd(true)
		FightInfoWnd:FlushFightText()	
	end
end

function ChangeSkillDirection()
	if GroundSelector:IsActive() then
		GroundSelector:ChagneDirection()
	end
end

function OpenShowFPSKey()--��Ϸ�п�����ʾ֡��ģʽ
	CRenderSystemClient_Inst():ShowFpsSwitch()
end

function OpenDebugKey()--��Ϸ�п����赲��ʾģʽ
	CRenderSystemClient_Inst():ShowDebugSwitch()
end

function OnLockAspecKey()--��Ϸ������ģʽ�л�
	CRenderSystemClient_Inst():LockAspectSwitch()
end

function OnGUIAlphaKey()--��Ϸ������GUI
	if not g_App.m_IsGUIHide then
		g_App.m_IsGUIHide = true
	else
		g_App.m_IsGUIHide = false
	end
	CRenderSystemClient_Inst():SwitchHidenMode()
end

function OnObjAlphaKey()--��Ϸ����������NPC
	CRenderSystemClient_Inst():ShowRenderObjSwitch()
end

function OnMainPlayerAlphaKey()--��Ϸ����������
	CRenderSystemClient_Inst():ShowPlayerSwitch()
end
	
function ShowASynLoad()--��Ϸ�п�����ʾ�첽װ�ص�����Ϣ
	CRenderSystemClient_Inst():ShowASynLoadSwitch()
end

function IsRender()--��Ϸ���Ƿ���Ⱦ
	CRenderSystemClient_Inst():SwitchIsRender()
end

function OpenCharInfo()-- ��ʾ�����Ϣ
	g_MainPlayer:OpenCharInfoSwitch()
end

function ShowAllName()
	g_GameMain.m_bShowAllName = true
	g_GameMain.m_CharacterInSyncMgr:PlayerHeadInfoInit()
	g_GameMain.m_CharacterInSyncMgr:UpdateAllPlayerInSync()
end

function UnShowAllName()
	g_GameMain.m_bShowAllName = false
	g_GameMain.m_CharacterInSyncMgr:PlayerHeadInfoInit()
	g_GameMain.m_CharacterInSyncMgr:UpdateAllPlayerInSync()
end

--����CTRL+Z�����ٻ��޹���
function MasterAttackCommand()
	Gac2Gas:MasterAttackCommand(g_Conn, g_MainPlayer:GetEntityID(), ENpcType.ENpcType_Summon)
end

--����CTRL+X�����ٻ��޳���
function MasterRetreatCommand()
	Gac2Gas:MasterRetreatCommand(g_Conn, g_MainPlayer:GetEntityID(), ENpcType.ENpcType_Summon)
end

--����CTRL+C�����ٻ��޽�ɢ
function MasterDisbandCommand()
	Gac2Gas:MasterDisbandCommand(g_Conn, g_MainPlayer:GetEntityID(), ENpcType.ENpcType_Summon)
end

function MasterMoveCommand()
	if g_GameMain.m_Servant then
		g_GameMain.m_Servant:OrderServantMove()
	end
end

--�Ƿ�ѡ���Լ��Ͷ��ѵ��ٻ���
function BeSelectServant()
	g_bSelectServant = not g_bSelectServant 
	g_MainPlayer:OnServantSelectConditionChange()
end

function HideAllPlayerFollower()
	if g_MainPlayer then
		g_GameMain.HideAllPlayerExceptTeammate = flase
		local bHide = not g_GameMain.HidePlayer
		g_GameMain.m_HideFollowerMgr:HideAllPlayerFollowerEx(bHide)
	end
end

function HidePlayerExceptTeammate() --��HideAllPlayerFollower����ͬʱ������
	if g_MainPlayer then
		g_GameMain.HidePlayer = false
		local bHide = not g_GameMain.HideAllPlayerExceptTeammate
		g_GameMain.m_HideFollowerMgr:HidePlayerFollower(false)
		g_GameMain.m_HideFollowerMgr:HidePlayerFollowerExceptTeammate(bHide)
		g_GameMain.m_HidePlayerExceptTeammateWnd:HideOrShowPlayerExceptTeammate()
	end
end

function ShowOrCloseAfflatusWnd()
	CAfflatusValueWnd.OpenAfflatusValueWnd()
end

function ShowOrClosePKText()
	g_GameMain.m_CharacterInSyncMgr.m_bShowPKText = not g_GameMain.m_CharacterInSyncMgr.m_bShowPKText
	g_GameMain.m_CharacterInSyncMgr:PlayerHeadInfoInit()
	g_GameMain.m_CharacterInSyncMgr:UpdateAllPlayerInSync()
end

-----------------------��������ѧϰ-----------------------------
function OpenLearnCommonSkillWnd()
	local Wnd = g_GameMain.m_LearnCommonSkillWnd
	Wnd:LayoutWnd()
	Wnd:ShowWnd(true)
	local AutoCloseWnd = CAutoCloseWnd:new()
	AutoCloseWnd:AutoCloseWnd(Wnd)
end

-----------------------------------------------------------------