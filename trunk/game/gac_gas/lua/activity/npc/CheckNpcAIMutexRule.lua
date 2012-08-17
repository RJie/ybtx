cfg_load "npc/NpcNature_Server"

--��NPC���Ա��л�����о�����˯���Ե�NPC
local function GetSleepNpcTbl()
	local tbl = {}
	for _, i in pairs(NpcNature_Server:GetKeys()) do
		if NpcNature_Server(i, "��˯") then
			tbl[i] = tbl[i] or true
		end
	end
	return tbl
end

local m_SleepNpc = GetSleepNpcTbl()

--������˯���Ե�NPC����Ѳ��
local function CheckPatrol(tbl)
	local NpcName = tbl["Name"]
	if tbl["Path"] and m_SleepNpc[NpcName] then
		local err_msg = " Npc:��" .. NpcName .. "�� ��Ѳ��״̬����˯�������ͻ�����ʵ��" 
		error(err_msg)
	end
end

function CheckNpcAIMutexRule(tbl)
	CheckPatrol(tbl)
end