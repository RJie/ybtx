local function Script(Arg, Trigger, Player)
	if not IsCppBound(Player) then
		return
	end
	if g_GetDistance(Player,Trigger)>6 then --�жϾ���
		return
	end
	if not Player:CppIsLive() then
		return
	end
	if Player:CppGetDoSkillCtrlState( EDoSkillCtrlState.eDSCS_InDoingSkill) or Player:CppGetCtrlState(EFighterCtrlState.eFCS_OnMission) then
		--MsgToConn(Conn,3290)--"���ܽ����ֲ�����")
		return
	end
	if Player:CppGetCtrlState(EFighterCtrlState.eFCS_InNormalHorse) or Player:CppGetCtrlState(EFighterCtrlState.eFCS_InBattleHorse) then--���
		MsgToConn(Player.m_Conn,3291)--"����״̬��������ʰȡ���߱���")
		return
	end
	
	--Player:IsFirstTimeAndSendMsg("��", 2001, sMsg)
	Player:CancelNormalAttack()
	CActiveBehavior.TargetDoBehavior(Player, Trigger:GetEntityID())
end 

return Script