--��ռ��ս�����
gas_require "framework/main_frame/SandBoxDef"
local MsgToConn = MsgToConn
local IsCppBound = IsCppBound
local IsServerObjValid = IsServerObjValid
local IntObj_Common = IntObj_Common
local g_IntObjServerMgr = g_IntObjServerMgr
local CreateIntObj = CreateIntObj
local ProTime = 10000
local ChlgObjName = "����������"
local TgtObjName = "�ط�������"

local function OccupyRebornPoint(Conn, IntObj, ObjName, GlobalID)
	local Player = Conn.m_Player
	local Scene = Player.m_Scene
	local uTongId = Player.m_Properties:GetTongID()
	local curPos = CPos:new()
	IntObj:GetGridPos(curPos)
	
	if uTongId == 0 then
		MsgToConn(Conn, 9401)
		return
	end
	if IntObj.m_Occupyer and uTongId == IntObj.m_Occupyer then
		MsgToConn(Conn, 9431)
		return
	end
	
	if g_ChallengeCurrentState ~= 3 then --û����ս��ʼ״̬������ռ�츴���
		MsgToConn(Conn, 9437)
		return
	end
	
	local function OccupySucc()
		if not (IsCppBound(Conn) and IsServerObjValid(Conn.m_Player)) and Conn.m_Player:CppIsLive() then
			MsgToConn(Conn, 9438)
			return
		end
		if not (IntObj and IsServerObjValid(IntObj)) then
			return
		end
		local ObjIndex = IntObj.m_ObjIndex
		g_IntObjServerMgr:Destroy(IntObj, false)
		Scene.m_IntObjTbl[ObjIndex] = nil
		
		if uTongId == Scene.m_ChlgerTongId then
			assert(IntObj_Common(ChlgObjName), ChlgObjName .. "�ڡ�IntObj_Common���в�����")
			local fPos = CFPos:new(curPos.x, curPos.y)
			local ChlgIntObj = CreateIntObj(Scene, fPos, ChlgObjName, nil, nil)
			ChlgIntObj.m_Occupyer = uTongId
			ChlgIntObj.m_ObjIndex = ObjIndex
			Scene.m_IntObjTbl[ObjIndex] = ChlgIntObj
		elseif uTongId == Scene.m_TgtTongId then
			assert(IntObj_Common(TgtObjName), TgtObjName .. "�ڡ�IntObj_Common���в�����")
			local fPos = CFPos:new(curPos.x, curPos.y)
			local TgtIntObj = CreateIntObj(Scene, fPos, TgtObjName, nil, nil)
			TgtIntObj.m_Occupyer = uTongId
			TgtIntObj.m_ObjIndex = ObjIndex
			Scene.m_IntObjTbl[ObjIndex] = TgtIntObj
		end
		MsgToConn(Conn, 9432)
	end
	
	local function OccupyFail()
		MsgToConn(Conn, 9433)
	end
	
	TongLoadProgress(Player, ProTime, OccupySucc, OccupyFail, {})
end

--��ռ��ս�����
local g_GetPlayerInfo = g_GetPlayerInfo
local Entry = CreateSandBox(...)
function Entry.Exec(Conn, IntObj, ObjName, GlobalID)
	if IsCppBound(Conn) and IsServerObjValid(Conn.m_Player) and Conn.m_Player:CppIsLive() then
		OccupyRebornPoint(Conn, IntObj, ObjName, GlobalID)
	end
end

return Entry
