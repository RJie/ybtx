cfg_load "npc/NpcNature_Server"

g_NatureArg2NpcTbl = {}		--��¼�����в�����עNPC������NPC����
g_NatureArg2ObjTbl = {}		--��¼�����в�����עOBJ������OBJ����

function _GetNatureInfo()
	for _, i in pairs(NpcNature_Server:GetKeys()) do
		for _, j in pairs(NpcNature_Server:GetKeys(i)) do
			local info = NpcNature_Server(i, j)
			if j == "���" or j == "��ų" then
				if g_NatureArg2NpcTbl[info("NatureArg")] == nil then
					g_NatureArg2NpcTbl[info("NatureArg")] = 1
				end
			elseif j == "ϲ��" or j == "���" or j == "����" then
				if g_NatureArg2ObjTbl[info("NatureArg")] == nil then
					g_NatureArg2ObjTbl[info("NatureArg")] = 1
				end
			end
		end
	end
end

_GetNatureInfo()