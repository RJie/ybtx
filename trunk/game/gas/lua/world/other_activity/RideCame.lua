gas_require "world/other_activity/RideCameInc"

function CRideCame:Ctor(uPlayerId)
	self.m_uPlayerId = uPlayerId
end


local function PSOnTick(Connection, Player, StateName)
	if not Player:IsMoving() then
		Player.m_PSPos = Player.m_PSPos + 20
	else
		Player.m_PSPos = Player.m_PSPos + Player.m_PhysicalStrenghAdder
	end
	if Player.m_PSPos > 1000 then
		Player.m_PSPos = 1000
		UnRegisterTickPSTick()
	elseif Player.m_PSPos < 0 then
		Player.m_PhysicalStrenghAdder = 10
		Player.m_PSPos = 0
		Player:ClearState(StateName)
	end
	Gas2Gac:RetPhysicalStrengh(Connection,Player.m_PSPos)
end

function UnRegisterTickPSTick()--  ������ɣ� ע��Tick
	if PhysicalStrengh_Tick then
		UnRegisterTick(PhysicalStrengh_Tick)
		PhysicalStrengh_Tick = nil
	end
end

function Gac2Gas:CheckCamelState(Connection, StateName)
	local Player = Connection.m_Player
	if not IsCppBound(Player) then
		return
	end
	
	local data = {Connection,Player,StateName}
	local questname = "��Ǹ"
	if not Player:ExistState("������") then
		UnRegisterTickPSTick()
		Gas2Gac:RetPhysicalState( Connection, false)
		Gas2Gac:ClearCompassHeadDir(Connection)
		return
	elseif StateName == "������" then
		Gas2Gac:RetPhysicalState( Connection, true)
		GetArrowHeadFromItem(Connection,"Npc","Ф��",-1)
	end
	
	local PlayerId = Player.m_uID
	local function CallBack(result)
		if result and IsCppBound(Player) then
			--TODO   ����StateName,�����ﵽ״̬����   	�������
			Gas2Gac:RetAddQuestVar(Player.m_Conn, questname, StateName, 1)
		end
	end

	if Connection.m_Player:ExistState(StateName) then
		if g_QuestNeedMgr[questname] and g_QuestNeedMgr[questname][StateName] then
			local params = {
			["sQuestName"] = questname,
			["sVarName"] = StateName,
			["iNum"] = 1,
			["char_id"] = PlayerId
			}
			--local RoleQuestDB = (g_DBTransDef["RoleQuestDB"])
			CallAccountManualTrans(Connection.m_Account, "RoleQuestDB", "AddQuestVarNum",CallBack,params)
		end
	end	
end

function AddPhysicalStrenghToFull(Player) --������
	Player.m_PSPos = 1000
	Gas2Gac:RetPhysicalStrengh(Player.m_Conn,1000)
end
