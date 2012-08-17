gas_require "framework/main_frame/SandBoxDef"

local CheckDistance = CheckDistance
local ServerBeginProgress = ServerBeginProgress
local g_GetPlayerInfo = g_GetPlayerInfo
local Entry = CreateSandBox(...)


local function CheckTeammateResponse(Tick, Teammate, Caller)
	if not Teammate then
		return
	end
	local TeammateId = Teammate.m_uID
	if Caller and Caller.m_WaitingTransportTbl and Caller.m_WaitingTransportTbl[TeammateId] then
		Caller.m_WaitingTransportTbl[TeammateId] = nil 
	end
	UnRegisterTick(Teammate.m_CheckResponseTick)
	Teammate.m_CheckResponseTick = nil
end

function Entry.NotifyTransport(Caller, data)
	local Teammate = data[2]
	if not Teammate then
		return
	end
	if Caller then
		Caller.m_CallTeammateId = nil
		local CallerName = Caller.m_Properties:GetCharName()
		Gas2Gac:NotifyTeammateTransport(Teammate.m_Conn,CallerName)
		local TeammateId = Teammate.m_uID
		if not Caller.m_WaitingTransportTbl then
			Caller.m_WaitingTransportTbl = {}
			Caller.m_WaitingTransportTbl[TeammateId] = true
		else
			Caller.m_WaitingTransportTbl[TeammateId] = true
		end
	end
end

function Entry.StopNotifyTransport(Caller, data)
	local Teammate = data[2]
	Gas2Gac:NotifyStopProgressBar(Caller.m_Conn)
	UnRegisterTick(Teammate.m_CheckResponseTick)
	Teammate.m_CheckResponseTick = nil
end

function Entry.Exec(Conn, CallPlayerObj, ObjName, GlobalID)
	local CallerId = Conn.m_Player.m_uID
	local Caller = g_GetPlayerInfo(CallerId)
	if not CheckDistance(Caller, CallPlayerObj, 5) then --�жϾ���
		return
	end
	local TeammateId = Caller.m_CallTeammateId
	if not IsNumber(TeammateId)  then
		return
	end
	local Teammate = g_GetPlayerInfo(TeammateId)
	if not Teammate then
--		print("���Ѳ�����")
		return
	end
	if Teammate.m_CheckResponseTick then
--		print("�������ڵȴ����˵��ٻ�")
		return
	end
	if CallerId == TeammateId then
--		print("�����ٻ��Լ�")
		return
	end
	local data = {GlobalID,Teammate}
	ServerBeginProgress(5000, false, Conn, Entry.NotifyTransport, Entry.StopNotifyTransport, data)
	--Gas2Gac:NotifyLoadProgressBar(Conn, 5000)
	--Teammate.m_NotifyTransportTick = RegisterTick(NotifyTransport, 5500, Teammate, Caller)
	Teammate.m_CheckResponseTick = RegisterTick("CheckResponseTick", CheckTeammateResponse, 15500, Teammate, Caller)
end

return Entry

