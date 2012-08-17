local GetDistance = g_GetDistance
local MsgToConn = MsgToConn
local g_ObjActionArgTbl = g_ObjActionArgTbl
local IsCppBound = IsCppBound
local Npc_Common = Npc_Common
local CreateServerNpc = g_NpcServerMgr.CreateServerNpc
local CFPos = CFPos
local EUnits = EUnits

local LogErr = LogErr

local m_ClickOrder = {}

local Entry  = CreateSandBox(...)

function Entry.Exec(Conn, Obj, ObjName, ObjID)
	local Player = Conn.m_Player
	local PlayerId = Player.m_uID
	
	if GetDistance(Player,Obj) > 6 then
		return
	end
	
	local UpObjName = g_ObjActionArgTbl[ObjName][1]
	local State = g_ObjActionArgTbl[ObjName][2]
	local DownObjName = g_ObjActionArgTbl[ObjName][3]
	local NpcName = g_ObjActionArgTbl[ObjName][4]--ֻ��ǰ������������,�ɹ�ʱ������õ�
	
	if not m_ClickOrder[PlayerId] then
		m_ClickOrder[PlayerId] = {}
	end
	
	if State == "begin" then
		if not m_ClickOrder[PlayerId].m_NowObjName
			or m_ClickOrder[PlayerId].m_NowObjName ~= DownObjName then
			--���Բ���һ����Ч
			Gas2Gac:UseItemPlayerEffect(Conn,"fx/setting/other/other/xiaoyouxi/create.efx","xiaoyouxi/create")
			Gas2Gac:UseItemTargetEffect(Player:GetIS(0),"fx/setting/other/other/xiaoyouxi/create.efx","xiaoyouxi/create", Player:GetEntityID())
		end
		m_ClickOrder[PlayerId].m_NowObjName = DownObjName
	else
		
		if m_ClickOrder[PlayerId].m_NowObjName
			and m_ClickOrder[PlayerId].m_NowObjName == UpObjName then
			if State == "end" then
				--��������
				Entry.CreateTarget(Player,DownObjName)--������,��������
				m_ClickOrder[PlayerId] = nil
				return
			else
				m_ClickOrder[PlayerId].m_NowObjName = DownObjName
				--���Բ���һ����Ч
				Gas2Gac:UseItemPlayerEffect(Conn,"fx/setting/other/other/xiaoyouxi/create.efx","xiaoyouxi/create")
				Gas2Gac:UseItemTargetEffect(Player:GetIS(0),"fx/setting/other/other/xiaoyouxi/create.efx","xiaoyouxi/create", Player:GetEntityID())
			end
		end
		
	end
	--��������
	Entry.CreateTarget(Player,NpcName)--�����,��������
end

function Entry.CreateTarget(Player,TargetName)
	local Pos = CPos:new()
	local Scene = nil
	if IsCppBound(Player) then
		Player:GetGridPos(Pos)
		Scene = Player.m_Scene
	else
		return
	end
		
	if Npc_Common(TargetName) then
		local fPos = CFPos:new( Pos.x * EUnits.eGridSpan, Pos.y * EUnits.eGridSpan )
		CreateServerNpc(TargetName,0,Scene,fPos)
	--elseif Type == "OBJ" and IntObj_Common(TargetName) then
		--CreateTarget = CreateIntObj(Scene, Pos, TargetName, true, PlayerId)
	end
end

return Entry
