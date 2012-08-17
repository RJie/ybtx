cfg_load "npc/Npc_Common"


local ErrorNum = 0					--yy ���� ��������Ϣ
local function error_print(flags, str)
	if not flags then
		print( str)
		ErrorNum = ErrorNum + 1
	end 
end 

local function BeinActionTbl(ActionName)
	local ActionState = CActorCfg_GetEnumByString(ActionName)
	if ActionState ~= EActionState.eAS_Error then
		return true
	else
		return false
	end
end

local ConditionTbl = {
					 	["����"] = 1,
					 	["�ȼ�"] = 2,
					 	["��ͨ"] = 3,
					 }

--function CheckNpcFacialResponse()
--	ErrorNum = 0
--	for i, v in pairs(NpcFacialResponse_Server) do
--		if BeinActionTbl(v["Action"]) then
--			if ConditionTbl[v["Condition"]] then
--				if v["Condition"] == "����" then
--					if v["ConditionArg"] == "" then
--						local err_msg = "���ñ�NpcFacialResponse_Server.xml���� ��" .. v["NPCName"] .. "�� �� ��"  .. v["Condition"] .. "�� �ġ�ConditionArg������������������"
--						error_print( false, err_msg)
--					end
--				elseif v["Condition"] == "�ȼ�" then
--					if tonumber(v["ConditionArg"]) == nil then
--						local err_msg = "���ñ�NpcFacialResponse_Server.xml���� ��" .. v["NPCName"] .. "�� �� ��"  .. v["Condition"] .. "�� �ġ�ConditionArg��������Ǵ���0�����֣�����Ϊ�գ����ʵ��"
--						error_print( false, err_msg)
--					end 
--				end 
--				
--				for i = 1, 4 do
--					local Reaction = "Reaction" .. i
--					local ReactionArg = "ReactionArg" .. i
--					if v[Reaction] == "˵��" then
--						if tostring(v[ReactionArg]) == nil or tostring(v[ReactionArg]) == "" then
--							local err_msg = "���ñ�NpcFacialResponse_Server.xml���� ��" .. v["NPCName"] .. "�� �� ��"  .. ReactionArg .. "�� �����ݲ���Ϊ�գ�"
--							error_print( false, err_msg)
--						end	
--					elseif v[Reaction] == "����" then
--						if BeinActionTbl(v[ReactionArg]) == false then
--							local err_msg = "���ñ�NpcFacialResponse_Server.xml���� ��" .. v["NPCName"] .. "�� �� ��"  .. v[ReactionArg] .. "�� ��������NPC�������ñ��У����ʵ��"
--							error_print( false, err_msg)
--						end
--					elseif v[Reaction] == "����Ӫ" then
--						local info = loadstring("return " .. v["ReactionArg" .. tostring(i)])()
--						if type(info) ~= "table" then
--							local err_msg = "���ñ�NpcFacialResponse_Server.xml���� ��" .. v["NPCName"] .. "�� �� ��"  .. ReactionArg .. "�� ��������д�������ʵ��"
--							error_print( false, err_msg)
--						end
--					elseif v[Reaction] == "����" then
--						local Arg = assert(loadstring("return " .. v[ReactionArg]))()
--						if Npc_Common(Arg[1]) == nil then
--							local err_msg = "���ñ�NpcFacialResponse_Server.xml���� ��" .. v["NPCName"] .. "�� �� ��"  .. ReactionArg .. "�� ������NPC���١�Npc_Common�����ñ��У����ʵ��"
--							error_print( false, err_msg)
--						end
--					elseif v[Reaction] == "������Ʒ" then
--					elseif v[Reaction] == "��������" then
--					elseif v[Reaction] == "�����Ѻö�" then
--					elseif v[Reaction] == "��������" then				
--					end
--				end
--				
--			else
--				local err_msg = "���ñ�NpcFacialResponse_Server.xml���� ��" .. v["NPCName"] .. "�� �� ��" .. v["Condition"] .. "�� ��д�������ʵ��"	
--				error_print( false, err_msg)
--			end
--		else
--			local err_msg = "���ñ�NpcFacialResponse_Server.xml���� ��" .. v["NPCName"] .. "�� �ġ�" .. v["Action"] .. "�� ����������Ұ����Ķ��������ʵ��"	
--			error_print( false, err_msg)
--		end
--	end
--	if ErrorNum ~= 0 then
--		error("NPC�������ñ����������")
--	end 
--	print("NPC���鶯�����ñ�����ϣ�")
--end