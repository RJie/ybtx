
local g_GetDistance = g_GetDistance
local EFighterCtrlState = EFighterCtrlState
local EDoSkillCtrlState = EDoSkillCtrlState
local TargetDoBehavior = CActiveBehavior.TargetDoBehavior
local EActionState = EActionState
local MsgToConn = MsgToConn

local g_GetPlayerInfo = g_GetPlayerInfo
local Entry  = CreateSandBox(...)

function Entry.Exec(Conn,Obj, ObjName, EntityID)
	if g_GetDistance(Conn.m_Player,Obj)>6 then --�жϾ���
		return
	end
	if not Conn.m_Player:CppIsLive() then
		return
	end
	if Conn.m_Player:CppGetDoSkillCtrlState( EDoSkillCtrlState.eDSCS_InDoingSkill) or Conn.m_Player:CppGetCtrlState(EFighterCtrlState.eFCS_OnMission) then
		--MsgToConn(Conn,3290)--"���ܽ����ֲ�����")
		return
	end
	if Conn.m_Player:CppGetCtrlState(EFighterCtrlState.eFCS_InNormalHorse) or Conn.m_Player:CppGetCtrlState(EFighterCtrlState.eFCS_InBattleHorse) then--���
		--MsgToConn(Conn,3291,"����״̬��������ʰȡ���߱���")
		--return
		Conn.m_Player:PlayerDoFightSkillWithoutLevel("����")
	end
	
	--Conn.m_Player:IsFirstTimeAndSendMsg("��", 2001, sMsg)
	Conn.m_Player:CancelNormalAttack()
	TargetDoBehavior(Conn.m_Player, EntityID)
end

return Entry
