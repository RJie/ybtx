AutoTrackerHandlerForNpc = class(IAutoTrackerHandler)

function AutoTrackerHandlerForNpc:OnReached(Attacker, Target)
	--print("AutoTrackerHandlerForNpc:OnReached")
	Attacker:StopMoving()
	
	local Name = Target.m_Properties:GetCharName()
	--g_GameMain.m_SGMgr:BeginSmallGameFun(Name)	--�Ƿ���Խ���С��Ϸ״̬
	OnRClickNpc(Target)
--	Target:DoRespondActionBegin(Attacker)
	Attacker:CancelAutoTracker(false)
end

function AutoTrackerHandlerForNpc:OnCheckStopCond(Attacker, Target)
	--print("AutoTrackerHandlerForNpc:OnCheckStopCond")
	return true
--	if g_GetDistance(Target, Attacker) <=3 then
--		return true
--	end
end
