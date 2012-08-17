gac_gas_require "activity/quest/QuestMgrInc"
gac_gas_require "activity/quest/QuestionStore"

DropItemProtectTime = 20

--local m_QuestTypeTbl = {Mercenary = 1,Dare = 2,Action = 3}
--QuestTypeEnum = {Hide = 0,Normal = 1,Action = 2}

local ConfigDataMgr = {}

local QuestTblNameStrTbl = {}
local QuestTblPosTbl = {}
local function LoadAllQuestCfg()---��סҪtable.insert��QuestTblNameStrTbl
	local Time1 = GetProcessTime()
	for i=1, 3 do
		table.insert(QuestTblPosTbl, "quest/master_quest/pos_QuestAll_CommonA"..i)
		table.insert(QuestTblNameStrTbl, "quest/master_quest/QuestAll_CommonA"..i)
		
		table.insert(QuestTblPosTbl, "quest/master_quest/pos_QuestAll_CommonB"..i)
		table.insert(QuestTblNameStrTbl, "quest/master_quest/QuestAll_CommonB"..i)
		
		table.insert(QuestTblPosTbl, "quest/master_quest/pos_QuestAll_CommonC"..i)
		table.insert(QuestTblNameStrTbl, "quest/master_quest/QuestAll_CommonC"..i)
	end
	
	--------------------------------------------
	table.insert(QuestTblPosTbl, "quest/pos_CallBack_Quest_Common")
	table.insert(QuestTblPosTbl, "quest/master_quest/pos_ZhiYin_Quest_Common")
	table.insert(QuestTblNameStrTbl, "quest/CallBack_Quest_Common")
	table.insert(QuestTblNameStrTbl, "quest/master_quest/ZhiYin_Quest_Common")
	
	table.insert(QuestTblPosTbl, "quest/master_quest/pos_Hide_Quest_Common")
	table.insert(QuestTblPosTbl, "quest/master_quest/pos_TreeBar_Quest_Common")
	table.insert(QuestTblPosTbl, "quest/master_quest/pos_HeYangDaCaoYuan_Quest_Common")
	table.insert(QuestTblPosTbl, "quest/master_quest/pos_ShengXueShan_Quest_Common")
	table.insert(QuestTblPosTbl, "quest/master_quest/pos_ShiZiHeGu_Quest_Common")
	table.insert(QuestTblPosTbl, "quest/master_quest/pos_XiLinDao_Quest_Common")
	table.insert(QuestTblNameStrTbl, "quest/master_quest/Hide_Quest_Common")
	table.insert(QuestTblNameStrTbl, "quest/master_quest/TreeBar_Quest_Common")
	table.insert(QuestTblNameStrTbl, "quest/master_quest/HeYangDaCaoYuan_Quest_Common")
	table.insert(QuestTblNameStrTbl, "quest/master_quest/ShengXueShan_Quest_Common")
	table.insert(QuestTblNameStrTbl, "quest/master_quest/ShiZiHeGu_Quest_Common")
	table.insert(QuestTblNameStrTbl, "quest/master_quest/XiLinDao_Quest_Common")
	--------------------------------------------
	
	table.insert(QuestTblPosTbl, "quest/mercenary_quest/pos_MercenaryQuest_Direct_Common")
	table.insert(QuestTblPosTbl, "quest/mercenary_quest/pos_MercenaryQuest_XiLinDao_CommonA")
	table.insert(QuestTblPosTbl, "quest/mercenary_quest/pos_MercenaryQuest_XiLinDao_CommonB")
	table.insert(QuestTblPosTbl, "quest/mercenary_quest/pos_MercenaryQuest_XiLinDao_CommonC")
	table.insert(QuestTblNameStrTbl, "quest/mercenary_quest/MercenaryQuest_Direct_Common")
	table.insert(QuestTblNameStrTbl, "quest/mercenary_quest/MercenaryQuest_XiLinDao_CommonA")
	table.insert(QuestTblNameStrTbl, "quest/mercenary_quest/MercenaryQuest_XiLinDao_CommonB")
	table.insert(QuestTblNameStrTbl, "quest/mercenary_quest/MercenaryQuest_XiLinDao_CommonC")
	
	--����Ӷ���������ñ�
	for i=1, 5 do
		table.insert(QuestTblPosTbl, "quest/mercenary_quest/pos_MercenaryQuest_CommonA"..i)
		table.insert(QuestTblNameStrTbl, "quest/mercenary_quest/MercenaryQuest_CommonA"..i)
		
		table.insert(QuestTblPosTbl, "quest/mercenary_quest/pos_MercenaryQuest_CommonB"..i)
		table.insert(QuestTblNameStrTbl, "quest/mercenary_quest/MercenaryQuest_CommonB"..i)
		
		table.insert(QuestTblPosTbl, "quest/mercenary_quest/pos_MercenaryQuest_CommonC"..i)
		table.insert(QuestTblNameStrTbl, "quest/mercenary_quest/MercenaryQuest_CommonC"..i)
	end
	
	--������ս�������ñ�
	for i=1, 3 do
		table.insert(QuestTblPosTbl, "quest/dare_quest/pos_DareQuest_Common"..i)
		table.insert(QuestTblNameStrTbl, "quest/dare_quest/DareQuest_Common"..i)
	end
	
	--�����淨�������ñ�
	for i=1, 3 do
		table.insert(QuestTblPosTbl, "quest/action_quest/pos_ActionQuest_Common"..i)
		table.insert(QuestTblNameStrTbl, "quest/action_quest/ActionQuest_Common"..i)
		table.insert(QuestTblPosTbl, "quest/action_quest/pos_LoopQuest_Common"..i)
		table.insert(QuestTblNameStrTbl, "quest/action_quest/LoopQuest_Common"..i)
	end
	
	cfg_load_list("QuestPos_Common", unpack(QuestTblPosTbl))
	cfg_load_list("Quest_Common", unpack(QuestTblNameStrTbl))
	--print("cfg_load_list�������ñ���ʱ��"..(GetProcessTime()-Time1).."����")
end

LoadAllQuestCfg()

--bMakeTable����loadstringʱ�Ƿ�Ӵ����ţ�bool��
--CfgName�����ñ�����֮���Ǹ���������string or number��
--����GetCfgTransformValue(true, "QuestAll_Common", "����Ĳ���", "��Ʒ����", 1, "Arg")
--ע�����ݡ����б���ĳ�г����м�����֮��ֻ��һ�����ݻ���û�У�ͨ���м�������ֱ���ܹ����ʵ����ݡ�
--����GetCfgTransformValue(true, "QuestAll_Common", "��֮�е�ί��", "Ӷ�����ƽ���")
function GetCfgTransformValue(bMakeTable, CfgName, ...)
	local function deepcopy(ori_tbl)
		local new_tbl = {}
		for i, v in pairs(ori_tbl) do
			if type(v) == "table" then
				new_tbl[i] = deepcopy(v)
			else
				new_tbl[i] = v;
			end
		end
		return new_tbl
	end
	
	local res = nil
	local n = select("#", ...)
	local arg = {...}
	local index = CfgName .. table.concat({...})
	
	res = ConfigDataMgr[index]
	if res then
		return res	--(type(res)=="string" and res) or deepcopy(res)
	end
	
	res = _G[CfgName]
	for i=1, n do
		res = res(arg[i])
		if not res then
			return
		end
		if i==n and (type(res) == "string" or type(res) == "number") then
			break
		end
	end
	
	if type(res) ~= "string" then
		if type(res) == "number" then
			error("����GetCfgTransformValue��ȡ���ñ�".. CfgName .."���쳣��Ŀ��������number���ͣ���Ҫ���������������ֱ�������ñ��")
		else
			error("����GetCfgTransformValue��ȡ���ñ�".. CfgName .."���쳣���������������������δ�ܵõ�ָ������")
		end
	end
	
	if bMakeTable then
		res = assert( loadstring("return {"..res.."}") )()
		ConfigDataMgr[index] = res
	else
		if res ~= "" then
			res = assert( loadstring("return "..res) )()
			ConfigDataMgr[index] = res
		end
	end
	
	return res	--(type(res)=="string" and res) or deepcopy(res)
end

local function CreateMercenaryQuestTable(CampType,MapName,MerceQuestType,QuestName)
	if not g_MercenaryQuestMgr[CampType] then
		g_MercenaryQuestMgr[CampType] = {}
		g_MercenaryQuestMgr[CampType][MapName] = {}
		g_MercenaryQuestMgr[CampType][MapName][MerceQuestType] = {}
	elseif not g_MercenaryQuestMgr[CampType][MapName] then
		g_MercenaryQuestMgr[CampType][MapName] = {}
		g_MercenaryQuestMgr[CampType][MapName][MerceQuestType] = {}
	elseif not g_MercenaryQuestMgr[CampType][MapName][MerceQuestType] then
		g_MercenaryQuestMgr[CampType][MapName][MerceQuestType] = {}
	end
	table.insert(g_MercenaryQuestMgr[CampType][MapName][MerceQuestType],QuestName)
end

--�������ñ��ת��
local function CreateQuestTable()
	g_WhereGiveQuestMgr["Goods"] = {}
	g_WhereGiveQuestMgr["Npc"] = {}
	g_WhereGiveQuestMgr["Obj"] = {}
	g_WhereFinishQuestMgr["Npc"] = {}
	g_WhereFinishQuestMgr["Obj"] = {}
	
	local questnum = 0
	local time1 = GetProcessTime()
	local QuestNameKeys = Quest_Common:GetKeys()
	for i=1, #QuestNameKeys do
		local QuestName = QuestNameKeys[i]
		local QuestNode = Quest_Common(QuestName)
		local CfgName = GetModuleName(QuestNode:GetFileName())
		questnum = questnum+1
		
		if QuestNode("��������") ~= 9 then		--��������9Ϊ��������
			g_SortQuestVarMgr[QuestName] = {}
			
			if QuestNode("��������") == 0 then
				g_HideQuestMgr[QuestName] = {}
			end
			if QuestNode("�ܷ��ظ�") == 1 then
				g_RepeatQuestMgr[QuestName] = true
			end
			if QuestNode("������") then
				local Keys = QuestNode:GetKeys("������")
				for k=1, table.getn(Keys) do
					local Index = QuestNode("������", Keys[k], "HyperLink")
					local NpcName = QuestPos_Common(Index, "Mark")
					if NpcName and NpcName ~= "" then
						if not g_QuestShowNpcNameMgr[NpcName] then
							g_QuestShowNpcNameMgr[NpcName] = {}
						end
						g_QuestShowNpcNameMgr[NpcName][QuestName] = true
					end
				end
			end
			
			if string.find(CfgName, "Mercenary") then
				g_AllMercenaryQuestMgr[QuestName] = true
				local CampType = QuestNode("��Ӫ����")
				local MerceQuestType = QuestNode("Ӷ����������")
				local MapKeys = QuestNode:GetKeys("������ͼ")
				for k=1, #MapKeys do
					local MapName = QuestNode("������ͼ", MapKeys[k])
					if CampType and CampType > 0 then
						CreateMercenaryQuestTable(CampType, MapName, MerceQuestType, QuestName)
					else
						for iCamp=1, 3 do
							CreateMercenaryQuestTable(iCamp, MapName, MerceQuestType, QuestName)
						end
					end
					if not g_MapQuestMgr[MapName] then
						g_MapQuestMgr[MapName] = {}
					end
					table.insert(g_MapQuestMgr[MapName],QuestName)
				end
				if MerceQuestType == 1 then--�ճ�Ӷ������
					g_GeneralMercenaryQuestMgr[QuestName] = {}
					g_GeneralMercenaryQuestMgr[QuestName].m_QuestLevel = QuestNode("����ȼ�")
					g_GeneralMercenaryQuestMgr[QuestName].m_QuestIsRepeat = QuestNode("�ܷ��ظ�")
					g_GeneralMercenaryQuestMgr[QuestName].m_CampType = CampType
					g_GeneralMercenaryQuestMgr[QuestName].m_MercLev = QuestNode("��������СӶ���ȼ�")
				elseif MerceQuestType == 5 then--���ټ���Ӷ������
					if not g_FewMercenaryQuestMgr[CampType] then
						g_FewMercenaryQuestMgr[CampType] = {}
					end
					table.insert(g_FewMercenaryQuestMgr[CampType], QuestName)
				elseif MerceQuestType == 6 or MerceQuestType == 7 then--Ӷ����С������
					g_TeamMercenaryQuestMgr[QuestName] = {}
					g_TeamMercenaryQuestMgr[QuestName].m_QuestLevel = QuestNode("����ȼ�")
					g_TeamMercenaryQuestMgr[QuestName].m_QuestIsRepeat = QuestNode("�ܷ��ظ�")
					g_TeamMercenaryQuestMgr[QuestName].m_CampType = CampType
					g_TeamMercenaryQuestMgr[QuestName].m_QuestType = MerceQuestType
					g_TeamMercenaryQuestMgr[QuestName].m_MercLev = QuestNode("��������СӶ���ȼ�")
				elseif MerceQuestType == 8 then
					g_AreaMercenaryQuestMgr[QuestName] = {}
					g_AreaMercenaryQuestMgr[QuestName].m_QuestLevel = QuestNode("����ȼ�")
					g_AreaMercenaryQuestMgr[QuestName].m_CampType = CampType
				else--Ŀǰ2,3,4,����������սӶ��������
					g_DareMercenaryQuestMgr[QuestName] = true
				end
			elseif string.find(CfgName, "Dare") then
				g_DareQuestMgr[QuestName] = true--��ս����
			elseif string.find(CfgName, "Action") or string.find(CfgName, "Loop") then
				g_ActionQuestMgr[QuestName] = true--�淨����
			elseif not string.find(CfgName, "CallBack") then
				g_MasterStrokeQuestMgr[QuestName] = true--��������
			end
			
			local ObjName = QuestNode("��������ʽ", "Arg")
			local sType = QuestNode("��������ʽ", "Subject")
			if ObjName ~= "" then
				if not g_WhereGiveQuestMgr then
					LogErr("Quest_Common����", "g_WhereGiveQuestMgrΪnil��" .. CfgName .. "��" .. QuestName .. " " .. sType)
				end
				if type(sType) ~= "string" then
					LogErr("Quest_Common����", "sTypeΪ" .. type(sType) .. "��" .. CfgName .. "��" .. QuestName .. " ")
				end
				if not g_WhereGiveQuestMgr[sType] then
					LogErr("Quest_Common����", "g_WhereGiveQuestMgr[sType]Ϊnil��" .. CfgName .. "��" .. QuestName .. " " .. sType)
				end
				if g_WhereGiveQuestMgr[sType][ObjName] == nil then
					g_WhereGiveQuestMgr[sType][ObjName]={}
				end
				table.insert(g_WhereGiveQuestMgr[sType][ObjName], QuestName)
			end
			
			ObjName = QuestNode("��������ʽ", "Arg")
			sType = QuestNode("��������ʽ", "Subject")
			if ObjName ~= "" then
				if g_WhereFinishQuestMgr[sType][ObjName]==nil then
					g_WhereFinishQuestMgr[sType][ObjName]={}
				end
				table.insert(g_WhereFinishQuestMgr[sType][ObjName], QuestName)
			end
			
			--g_QuestAwardMgr[QuestName]={}--��ʽΪg_QuestAwardMgr[������].Must(����Select,ֵΪ{{Itemtype,ItemName,Num},{...},...}
			--MustΪ��ѡ������Ʒ��SelectΪ��ѡ������Ʒ)
			local FieldKeys = QuestNode:GetKeys()
			for k=1, #FieldKeys do
				local Field = FieldKeys[k]
				g_SortQuestVarMgr[QuestName][Field] = {}
				if Field == "��������" then
					local Keys = QuestNode:GetKeys(Field)
					for n=1, #Keys do
						local varname = QuestNode(Field, Keys[n], "Subject")--�������������
						local Arg = GetCfgTransformValue(true, "Quest_Common", QuestName, Field, Keys[n], "Arg")
						if varname ~= "" and Arg[1] then
							if g_QuestDropItemMgr[varname] == nil then
								g_QuestDropItemMgr[varname] = {}
							end
							if g_QuestDropItemMgr[varname][QuestName] == nil then
								g_QuestDropItemMgr[varname][QuestName] = {}
							end
							local tbl = {}
							tbl.Type = Arg[1] --�������Ʒ����
							tbl.Object = Arg[2]--�������Ʒ��
							tbl.Rate = Arg[3]--�������Ʒ����
							table.insert(g_QuestDropItemMgr[varname][QuestName], tbl)
							if not g_QuestShowNpcNameMgr[varname] then
								g_QuestShowNpcNameMgr[varname] = {}
							end
							g_QuestShowNpcNameMgr[varname][QuestName] = true
						end
					end
					
				elseif Field == "�����Ʒ" then
					local Keys = QuestNode:GetKeys(Field)
					for n=1, #Keys do
						local tbl = GetCfgTransformValue(true, "Quest_Common", QuestName, Field, Keys[n])
						if tbl[1] then
							local itemtype = tbl[1]
							local itemname = tbl[2]
							g_QuestPropMgr[itemname] = {itemtype, QuestName}
						end
					end
					
				elseif Field == "��������" then
					local Keys = QuestNode:GetKeys(Field)
					for n=1, #Keys do
						local AreaName = QuestNode(Field, Keys[n], "Subject")
						if AreaName ~= "" then
							if g_AreaQuestMgr[AreaName] == nil then
								g_AreaQuestMgr[AreaName] = {}
							end
							table.insert(g_AreaQuestMgr[AreaName], QuestName)
						end
					end
				
				elseif Field == "������" and QuestNode("��������") == 10 then
					local Keys = QuestNode:GetKeys(Field)
					for n=1, #Keys do
						local tbl = GetCfgTransformValue(true, "Quest_Common", QuestName, Field, Keys[n])
						if tbl[1] then
							local loopname, minlev, maxlev, loopnum = unpack(tbl)
							if not g_LoopQuestMgr[loopname] then
								g_LoopQuestMgr[loopname] = {}
							end
							if not g_LoopQuestMgr[loopname][loopnum] then
								g_LoopQuestMgr[loopname][loopnum] = {}
							end
							table.insert( g_LoopQuestMgr[loopname][loopnum], {["QuestName"] = QuestName, ["MinLevel"] = minlev, ["MaxLevel"] = maxlev} )
						end
					end
				
				elseif (string.find(Field, "����")) then
					if Field == "������״̬����" then
						local Keys = QuestNode:GetKeys(Field)
						for n=1, #Keys do
							local tbl = GetCfgTransformValue(true, "Quest_Common", QuestName, Field, Keys[n], "Function")
							local varname = tbl[1]
							if g_BuffQuestMgr[QuestName] == nil then
								g_BuffQuestMgr[QuestName] = {}
							end
							g_BuffQuestMgr[QuestName][varname] = {}
							g_BuffQuestMgr[QuestName][varname].TrackInfo = QuestName..Field..QuestNode(Field, Keys[n], "IndexKey")
							g_BuffQuestMgr[QuestName][varname].Num = QuestNode(Field, Keys[n], "Arg")
							table.insert(g_SortQuestVarMgr[QuestName][Field], varname)
						end
					else
						if g_QuestNeedMgr[QuestName] == nil then
							g_QuestNeedMgr[QuestName] = {}
						end
						if Field == "��Ʒ����"  then
							local Keys = QuestNode:GetKeys(Field)
							for n=1, #Keys do
								local tbl = GetCfgTransformValue(true, "Quest_Common", QuestName, Field, Keys[n], "Arg")
								local itemname = tbl[2]
								g_QuestNeedMgr[QuestName][itemname] = {}
								g_QuestNeedMgr[QuestName][itemname].TrackInfo = QuestName..Field..QuestNode(Field, Keys[n], "IndexKey")
								g_QuestNeedMgr[QuestName][itemname].Num = tbl[3]
								g_QuestNeedMgr[QuestName][itemname].NeedType = Field
								if g_ItemQuestMgr[itemname] == nil then
									g_ItemQuestMgr[itemname] = {}
								end
								local itemtype = tbl[1]
								table.insert(g_ItemQuestMgr[itemname], {itemtype, QuestName})
								table.insert(g_SortQuestVarMgr[QuestName][Field], itemname)
							end
						elseif Field == "��Ʒʹ������" then
							local Keys = QuestNode:GetKeys(Field)
							for n=1, #Keys do
								local tbl = GetCfgTransformValue(true, "Quest_Common", QuestName, Field, Keys[n], "Function")
								local itemname = tbl[1]
								local varname = "ʹ��Item"..itemname
								g_QuestNeedMgr[QuestName][varname] = {}
								g_QuestNeedMgr[QuestName][varname].TrackInfo = QuestName..Field..QuestNode(Field, Keys[n], "IndexKey")
								g_QuestNeedMgr[QuestName][varname].bNotShare = tbl[2]
								g_QuestNeedMgr[QuestName][varname].Num = QuestNode(Field, Keys[n], "Arg")
								g_QuestNeedMgr[QuestName][varname].NeedType = Field
								if g_VarQuestMgr[varname] == nil then
									g_VarQuestMgr[varname] = {}
								end
								table.insert(g_VarQuestMgr[varname], QuestName)
								table.insert(g_SortQuestVarMgr[QuestName][Field], varname)
							end
						elseif Field == "��������ʹ������" then
							local Keys = QuestNode:GetKeys(Field)
							for n=1, #Keys do
								local tbl = GetCfgTransformValue(true, "Quest_Common", QuestName, Field, Keys[n], "Function")
								local objname = tbl[1]
								local varname = "ʹ��Obj"..objname
								g_QuestNeedMgr[QuestName][varname]={}
								g_QuestNeedMgr[QuestName][varname].TrackInfo = QuestName..Field..QuestNode(Field, Keys[n], "IndexKey")
								g_QuestNeedMgr[QuestName][varname].bNotShare = tbl[2]
								g_QuestNeedMgr[QuestName][varname].Num = QuestNode(Field, Keys[n], "Arg")
								g_QuestNeedMgr[QuestName][varname].NeedType = Field
								if g_VarQuestMgr[varname] == nil then
									g_VarQuestMgr[varname] = {}
								end
								table.insert(g_VarQuestMgr[varname], QuestName)
								table.insert(g_SortQuestVarMgr[QuestName][Field], varname)
							end
						elseif Field == "��������" then
							local Keys = QuestNode:GetKeys(Field)
							for n=1, #Keys do
								local tbl = GetCfgTransformValue(true, "Quest_Common", QuestName, Field, Keys[n], "Function")
								local actionname = tbl[1]
								local targetname = tbl[2] 
								local varname = "��"..targetname..actionname
								g_QuestNeedMgr[QuestName][varname]={}
								g_QuestNeedMgr[QuestName][varname].TrackInfo = QuestName..Field..QuestNode(Field, Keys[n], "IndexKey")
								g_QuestNeedMgr[QuestName][varname].bNotShare = tbl[3]
								g_QuestNeedMgr[QuestName][varname].Num = QuestNode(Field, Keys[n], "Arg")
								g_QuestNeedMgr[QuestName][varname].NeedType = Field
								if g_VarQuestMgr[varname] == nil then
									g_VarQuestMgr[varname] = {}
								end
								table.insert(g_VarQuestMgr[varname], QuestName)
								table.insert(g_SortQuestVarMgr[QuestName][Field], varname)
							end
						elseif Field == "ɱ������" then
							local Keys = QuestNode:GetKeys(Field)
							for n=1, #Keys do
								local tbl = GetCfgTransformValue(true, "Quest_Common", QuestName, Field, Keys[n], "Function")
								local npcname = tbl[1]
								local skillname = tbl[2] or "��ͨ����"
								local varname = skillname.."ɱ"..npcname
								g_QuestNeedMgr[QuestName][varname]={}
								g_QuestNeedMgr[QuestName][varname].TrackInfo = QuestName..Field..QuestNode(Field, Keys[n], "IndexKey")
								g_QuestNeedMgr[QuestName][varname].Num = QuestNode(Field, Keys[n], "Arg")
								g_QuestNeedMgr[QuestName][varname].NeedType = Field
								if g_KillNpcQuestMgr[npcname] == nil then
									g_KillNpcQuestMgr[npcname] = {}
									g_KillNpcQuestMgr[npcname][skillname] = {}
								elseif g_KillNpcQuestMgr[npcname][skillname] == nil then
									g_KillNpcQuestMgr[npcname][skillname] = {}
								end
								table.insert(g_KillNpcQuestMgr[npcname][skillname], QuestName)
								if not g_QuestToNpcMgr[QuestName] then
									g_QuestToNpcMgr[QuestName] = {}
								end
								table.insert(g_QuestToNpcMgr[QuestName], npcname)
								table.insert(g_SortQuestVarMgr[QuestName][Field], varname)
								if not g_QuestShowNpcNameMgr[npcname] then
									g_QuestShowNpcNameMgr[npcname] = {}
								end
								g_QuestShowNpcNameMgr[npcname][QuestName] = true
							end
						elseif Field == "�¼�����" then
							local Keys = QuestNode:GetKeys(Field)
							for n=1, #Keys do
								local tbl = GetCfgTransformValue(true, "Quest_Common", QuestName, Field, Keys[n], "Function")
								local eventname = tbl[1]
								local varname = "���"..eventname
								g_QuestNeedMgr[QuestName][varname]={}
								g_QuestNeedMgr[QuestName][varname].TrackInfo = QuestName..Field..QuestNode(Field, Keys[n], "IndexKey")
								g_QuestNeedMgr[QuestName][varname].bNotShare = tbl[2]
								g_QuestNeedMgr[QuestName][varname].Num = QuestNode(Field, Keys[n], "Arg")
								g_QuestNeedMgr[QuestName][varname].NeedType = Field
								if g_VarQuestMgr[varname] == nil then
									g_VarQuestMgr[varname] = {}
								end
								table.insert(g_VarQuestMgr[varname], QuestName)
								table.insert(g_SortQuestVarMgr[QuestName][Field], varname)
							end
						elseif Field == "�ȼ�����" then
							local tbl = GetCfgTransformValue(true, "Quest_Common", QuestName, Field, "Function")
							local level = tbl[1]
							local varname = "�ȼ�"..level
							g_QuestNeedMgr[QuestName][varname]={}
							g_QuestNeedMgr[QuestName][varname].TrackInfo = QuestName..Field..QuestNode(Field, "IndexKey")
							g_QuestNeedMgr[QuestName][varname].bNotShare = tbl[2]
							g_QuestNeedMgr[QuestName][varname].Num = QuestNode(Field, "Arg")
							g_QuestNeedMgr[QuestName][varname].NeedType = Field
							g_QuestNeedMgr[QuestName][varname].NeedLevel = tonumber(level)
							if g_VarQuestMgr[varname] == nil then
								g_VarQuestMgr[varname] = {}
							end
							table.insert(g_VarQuestMgr[varname], QuestName)
							table.insert(g_SortQuestVarMgr[QuestName][Field], varname)
						elseif Field == "��������" then
							local Keys = QuestNode:GetKeys(Field)
							for n=1, #Keys do
								local tbl = GetCfgTransformValue(true, "Quest_Common", QuestName, Field, Keys[n], "Function")
								local varname = tbl[1]..tbl[2]
								g_QuestNeedMgr[QuestName][varname]={}
								g_QuestNeedMgr[QuestName][varname].TrackInfo = QuestName..Field..QuestNode(Field, Keys[n], "IndexKey")
								g_QuestNeedMgr[QuestName][varname].SkillName = tbl[1]
								g_QuestNeedMgr[QuestName][varname].SkillLevel = tbl[2]
								g_QuestNeedMgr[QuestName][varname].Num = QuestNode(Field, Keys[n], "Arg")
								g_QuestNeedMgr[QuestName][varname].NeedType = Field
								if g_VarQuestMgr[varname] == nil then
									g_VarQuestMgr[varname] = {}
								end
								table.insert(g_VarQuestMgr[varname], QuestName)
								table.insert(g_SortQuestVarMgr[QuestName][Field],varname)
								if g_LearnSkillMgr[tbl[1]] == nil then
									g_LearnSkillMgr[tbl[1]] = {}
								end
								if g_LearnSkillMgr[tbl[1]][tbl[2]] == nil then
									 g_LearnSkillMgr[tbl[1]][tbl[2]] = {}
								end
								table.insert(g_LearnSkillMgr[tbl[1]][tbl[2]], QuestName)
							end
						else
							local Keys = QuestNode:GetKeys(Field)
							for n=1, #Keys do
								local tbl = GetCfgTransformValue(true, "Quest_Common", QuestName, Field, Keys[n], "Function")
								local varname = tbl[1]
								g_QuestNeedMgr[QuestName][varname]={}
								g_QuestNeedMgr[QuestName][varname].TrackInfo = QuestName..Field..QuestNode(Field, Keys[n], "IndexKey")
								g_QuestNeedMgr[QuestName][varname].bNotShare = tbl[2]
								g_QuestNeedMgr[QuestName][varname].Num = QuestNode(Field, Keys[n], "Arg")
								g_QuestNeedMgr[QuestName][varname].NeedType = Field
								if g_VarQuestMgr[varname] == nil then
									g_VarQuestMgr[varname] = {}
								end
								table.insert(g_VarQuestMgr[varname], QuestName)
								table.insert(g_SortQuestVarMgr[QuestName][Field], varname)
							end
						end
					end
				end
			end
		
		end
	end
	print("�������ñ�ת���������,�����������ǣ�"..questnum.."  ����ʱ�� "..(GetProcessTime()-time1).."����")
end

CreateQuestTable()

--for k, name in pairs(QuestTblNameStrTbl) do
--	UnloadCfgTbl(name)
--end

AddCheckLeakFilterObj(ConfigDataMgr)
collectgarbage("collect")
