gas_require "world/other_activity/CrazyHorseInc"

function CCrazyHorse:Ctor(uPlayerId)
	self.m_uPlayerId = uPlayerId
end

local function PSOnTick(Tick, Connection, Player, StateName, Adder)
	if not Player:IsMoving() then
		return
	else
		Player.m_CHPSPos = Player.m_CHPSPos + Adder
	end
	if Player.m_CHPSPos > 1000 then
		Player.m_CHPSPos = 1000
	elseif Player.m_CHPSPos < 0 then
		Player.m_CHPSPos = 0
		Player:ClearState("�����")
		UnRegisterTickCrazyHorseTick(Player)
	end
	Gas2Gac:RetPhysicalStrengh(Connection,Player.m_CHPSPos)
end

local function CheckCrazyHorseState(data,IsChangeState)
	local Connection,Player,StateName = unpack(data)
	if Player:ExistState(StateName) or IsChangeState then
		Gas2Gac:RetCheckCamelState(Connection, StateName, true)
		if StateName == "�������״̬1" then
			Player.m_CHPhysicalStrenghAdder = 0
		elseif StateName == "�������״̬2" then
			Player.m_CHPhysicalStrenghAdder = -10
		elseif StateName == "�������״̬3" then
			Player.m_CHPhysicalStrenghAdder = -20
		elseif StateName == "�������״̬4" then
			Player.m_CHPhysicalStrenghAdder = -30
		elseif StateName == "�������״̬5" then
			Player.m_CHPhysicalStrenghAdder = -40
		elseif StateName == "�������״̬6" then
			Player.m_CHPhysicalStrenghAdder = -50
		elseif StateName == "�������״̬7" then
			Player.m_CHPhysicalStrenghAdder = -60
		elseif StateName == "�������״̬8" then
			Player.m_CHPhysicalStrenghAdder = -70
		elseif StateName == "�������״̬9" then
			Player.m_CHPhysicalStrenghAdder = -80
		elseif StateName == "�������״̬10" then
			Player.m_CHPhysicalStrenghAdder = -90
		end
		local mail_reciever = CCrazyHorse:new(Connection.m_Player.m_uID)
		if not Player.m_CHPSPos or StateName == "�������״̬1" then --���� 
			Player.m_CHPSPos = 1000
		end
		UnRegisterTickCrazyHorseTick(Player)
		Player.CrazyHorsePhysicalStrengh_Tick=RegisterTick("PSOnTick", PSOnTick, 2000, Connection, Player, StateName, Player.m_CHPhysicalStrenghAdder)
	elseif (not Player:ExistState("�������״̬10")) and (not Player:ExistState("�������״̬9")) and (not Player:ExistState("�������״̬8")) and (not Player:ExistState("�������״̬7")) and (not Player:ExistState("�������״̬6"))
		and (not Player:ExistState("�������״̬5")) and (not Player:ExistState("�������״̬4")) and (not Player:ExistState("�������״̬3")) and (not Player:ExistState("�������״̬2")) and (not Player:ExistState("�������״̬1")) then
			Player.m_CHPSPos = 1000
			Player.m_CHPhysicalStrenghAdder = 0
	end
end

function UnRegisterTickCrazyHorseTick(Player)--  ������ɣ� ע��Tick
	if Player and Player.CrazyHorsePhysicalStrengh_Tick then
		UnRegisterTick(Player.CrazyHorsePhysicalStrengh_Tick)
		Player.CrazyHorsePhysicalStrengh_Tick = nil
	end
end

function Gac2Gas:CheckCrazyHorseState(Connection, StateName)
	local Player = Connection.m_Player
	local data = {Connection,Player,StateName}
	local questname = "��������"
	if not Player:ExistState("�����") then
		UnRegisterTickCrazyHorseTick(Player)
		Gas2Gac:RetPhysicalState( Connection, false)
		Gas2Gac:ClearCompassHeadDir(Connection)
		return
	elseif StateName == "�����" then
		Gas2Gac:RetPhysicalState( Connection, true)
		GetArrowHeadFromItem(Connection,"Npc","��˹����",-1)
	end
	local function CallBack(result)
		if result then
			--TODO   ����StateName,�����ﵽ״̬����   	�������
			if IsCppBound(Player) then
				Gas2Gac:RetQuestVar(Player.m_Conn, questname, StateName, result)
			end
		end
		CheckCrazyHorseState(data,true)
	end
	if Connection.m_Player:ExistState(StateName) then
		CheckCrazyHorseState(data,true)
	else
		CheckCrazyHorseState(data)
	end
end