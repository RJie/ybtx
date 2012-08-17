
local g_GetDistance = g_GetDistance
local g_GetPlayerInfo = g_GetPlayerInfo
local EFighterCtrlState = EFighterCtrlState
local EDoSkillCtrlState = EDoSkillCtrlState
local EActionState = EActionState
local MsgToConn = MsgToConn
local IntObj_Common = IntObj_Common
local KickSwapBehaviorActualize = CKickBehavior.KickSwapBehaviorActualize
local RegisterOnceTick = RegisterOnceTick
local LogErr = LogErr
local IsCppBound = IsCppBound
local IsServerObjValid = IsServerObjValid

local g_GetPlayerInfo = g_GetPlayerInfo
local Entry  = CreateSandBox(...)

local function DropObj(data)
	local PlayerId, Obj, IsSaveObj = data[1],data[2],data[3]
	
	local Player = g_GetPlayerInfo(PlayerId)
	if IsCppBound(Player) then
		Player.m_IsInToKickTick = nil
		if IsServerObjValid(Obj) then
			KickSwapBehaviorActualize(Player, Obj:GetEntityID(), 1,IsSaveObj)
		end
	else
		if Obj then
			Obj.m_OwnerId = nil
		end
	end
end

function Entry.Exec(Conn,Obj, ObjName, EntityID)
	if g_GetDistance(Conn.m_Player,Obj)>6 then --�жϾ���
		return
	end
	if not Conn.m_Player:CppIsLive() then
		return
	end
	if Conn.m_Player:CppGetCtrlState(EFighterCtrlState.eFCS_OnMission) then
		--MsgToConn(Conn,3290)--"���ܽ��нŲ�����")
		return
	end
	
	local TriggerAction = IntObj_Common(ObjName, "TriggerAction")
	if TriggerAction then
		
		--�������ǲ����Ѿ������˶���
		if Conn.m_Player.m_IsInToKickTick then
			MsgToConn(Conn,3292)--"�Ѿ��߹���.....")
			return
		end
		--���Ŀ���ǲ������ڱ�ʹ��	
		if Obj.m_OwnerId and Obj.m_OwnerId ~= Conn.m_Player.m_uID then
			local Target = g_GetPlayerInfo(Obj.m_OwnerId)
			if IsCppBound(Target) then
				if g_GetDistance(Target,Obj)<=5 then --�жϾ���
					MsgToConn(Conn,3253)--Ŀ�����ڱ�����ʹ����..
					return
				end
			end
		end
		--ֻҪ���겻ɾ��OBJ,Ҫ����ǲ����Ѿ���ʹ�ù���
		if string.find(TriggerAction,"Obj����") and Obj.m_HaveBeKickedTime then
			if (os.time() - Obj.m_HaveBeKickedTime["UseTime"] > Obj.m_HaveBeKickedTime["CoolTime"]) then
				--LogErr("OBJ�Ѿ���������,����ִ�з�ս����Ϊ","״̬ID:"..Obj.m_HaveBeKickedTime["LockState"],Conn)
				Obj.m_HaveBeKickedTime = nil
			else
				MsgToConn(Conn,3292)--"�Ѿ��߹���.....")
				return
			end
		end
		
		Obj.m_OwnerId = Conn.m_Player.m_uID
		
		Conn.m_Player.m_IsInToKickTick = EntityID
		
		if string.find(TriggerAction,"С��") then--С��
			Conn.m_Player:SetAndSyncActionState(EActionState.eAS_Kick)
			
			local data = nil
			if string.find(TriggerAction,"Obj����") then
				data = {Conn.m_Player.m_uID,Obj,true}
			else
				data = {Conn.m_Player.m_uID,Obj,false}
			end
			
			RegisterOnceTick(Obj.m_Scene,"FeetBehavior DropObj",DropObj,500,data)
		else--����
			Conn.m_Player:CppSetCtrlState(EFighterCtrlState.eFCS_OnMission, true)
			Conn.m_Player:CppSetCtrlState(EFighterCtrlState.eFCS_ForbitNormalAttack, true)
			Conn.m_Player:LuaSetDoSkillCtrlState(EDoSkillCtrlState.eDSCS_ForbitUseSkill, true)
		
			if string.find(TriggerAction,"Obj����") then
				Conn.m_Player.m_KickSaveObj = true
			else
				Conn.m_Player.m_KickSaveObj = false
			end
			
			Conn.m_Player.m_KickBehavor = true
			Conn.m_Player:AddListeningWnd()
			Gas2Gac:OpenXLProgressWnd(Conn,EntityID)
		end
	end
end

return Entry
