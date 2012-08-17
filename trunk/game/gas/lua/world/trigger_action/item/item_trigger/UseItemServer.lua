gas_require "framework/main_frame/SandBoxDef"
gas_require "world/trigger_action/item/item_trigger/UseItemStateCheck"

local ItemNumCheck = ItemNumCheck
local EDoSkillCtrlState = EDoSkillCtrlState
local MsgToConn = MsgToConn
local g_GetPlayerInfo = g_GetPlayerInfo
local Entry = CreateSandBox(...)

function Entry.Exec(Conn, ItemName, ItemInfo, RoomIndex, Pos)
	local Player = Conn.m_Player
	if Player.m_UseItemLoadingTick or 
		Player.m_ActionLoadingTick or 
		Player.m_CollectResTick then
		return
	end
	if Player:CppGetDoSkillCtrlState(EDoSkillCtrlState.eDSCS_ForbitUseMissionItemSkill) then
		MsgToConn(Conn,829)
		return
	end
	--����Player�ϵĶ���̫����
	--����Ʒʹ����ض��ҵ�Conn.m_Player.UseItemParam[ItemName]��
	if Conn.m_Player.UseItemParam == nil then
		Conn.m_Player.UseItemParam = {}
	end
	
--	Conn.m_Player.UseItemParam.CreateTbl											= nil		--������Npcˢ����
	if Player.UseItemParam[ItemName] == nil then
		Player.UseItemParam[ItemName] = {}
	else
		return
	end
	Conn.m_Player.UseItemParam[ItemName].RoomIndex = RoomIndex
	Conn.m_Player.UseItemParam[ItemName].RoomPos = Pos
	
--	Conn.m_Player.UseItemParam[ItemName].IsDoAction						= nil		--�Ƿ񲥷Ŷ�������Ч ���ü��ܵĲ�����
--	Conn.m_Player.UseItemParam[ItemName].IsOnTarget						= nil		--��Ŀ��ʹ��
--	Conn.m_Player.UseItemParam[ItemName].IsOnPos							= nil		--�Եص�ʹ��
--	Conn.m_Player.UseItemParam[ItemName].OnPosEffectVector3f  = nil		--�Եص�ʹ�õ�����x,y,z
	ItemNumCheck(Conn, ItemInfo, RoomIndex, Pos)
--	print("Conn.m_Player.UseItemParam[ItemName] = {}")
end

return Entry