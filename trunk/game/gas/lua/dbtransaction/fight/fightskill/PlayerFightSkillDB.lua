gac_gas_require "shortcut/ShortcutCommon"
gac_gas_require "skill/SkillCommon"
cfg_load "skill/NonFightSkill_Common"
cfg_load "skill/SkillPart_Common"
lan_load "appellation/Lan_AppellationText_Common"

local NonFightSkill_Common = NonFightSkill_Common
local SkillPart_Common = SkillPart_Common
local Lan_AppellationText_Common = Lan_AppellationText_Common
local FightSkillKind = FightSkillKind
local loadGeniusfile = loadGeniusfile
local GetNodeName = GetNodeName
local ESkillTreeNode = ESkillTreeNode
local loadstring = loadstring
local g_PlayerLevelToSkillLevelTbl = g_PlayerLevelToSkillLevelTbl
local g_MoneyMgr = CMoney:new()
local MemH64 = MemH64
local GetLearnSkillConsume = GetLearnSkillConsume
local GetUpSkillConsume = GetUpSkillConsume
local EShortcutPieceState = EShortcutPieceState
local g_QuestNeedMgr = g_QuestNeedMgr
local g_LearnSkillMgr = g_LearnSkillMgr
local event_type_tbl = event_type_tbl
local GetClearTalentConsumeItem = GetClearTalentConsumeItem
local g_ItemInfoMgr = g_ItemInfoMgr
local FightSkill = CreateDbBox(...)
local FightSkillSql = {}
local QuestState = {
	init	= 1,
	failure	= 2,
	finish	= 3
}

local SkillNode = 
 	 { 
 	 		[1] = 1,  --���������㣬ֵ��Ӧ�㣬��7����㣬4��
 	 		[2] = 2,
 	 		[3] = 3,
 	 		[4] = 3,
 	 		[5] = 4,
 	 		[6] = 4,
 	 		[7] = 4
 	 }
 	 
local SkillLayer = 
 	 { 
 	 		[1] = {1},  --ÿ���Ӧ�Ľ��
 	 		[2] = {2},
 	 		[3] = {3,4},
 	 		[4] = {5,6,7},
 	 }
local LayerLimitTbl =
	{
		[2] = 2,
		[3] = 4,
		[4] = 7,
		[5] = 4,
		[6] = 2,
		[7] = 4,
		[8] = 2,
	}

--�õ���ҵĵȼ�
local StmtDef =
{
	"_GetPlayerLevel",
	"select cb_uLevel from tbl_char_basic where cs_uId = ? "
}
DefineSql( StmtDef , FightSkillSql )

--���ݽ�ɫID��ѯ��ѧ�츳����
local StmtDef = 
{
	"Dbs_SelectTalentCount",
	[[
		select count(*) from tbl_fight_skill
		where cs_uId = ? and fs_uKind = ?
	]]
}
DefineSql(StmtDef,FightSkillSql)

function FightSkill.CheckTalentPoint(PlayerId)
	local level_result = FightSkillSql._GetPlayerLevel:ExecStat(PlayerId)
	level_result = level_result:GetData(0,0)
	local allTalentNumber = 0
	if level_result < 10 then
		return false
	elseif level_result >= 10 then
		allTalentNumber= math.floor((level_result-10)/5)+1
	end
	
	local talentCount = FightSkillSql.Dbs_SelectTalentCount:ExecStat(PlayerId,FightSkillKind.Talent)
	talentCount = talentCount:GetData(0,0)
	local result = (allTalentNumber - talentCount) > 0 and true or false
	return result
end

local StmtDef=
{ 
	"Dbs_SaveFightSkill",
	"replace into tbl_fight_skill( cs_uId, fs_sName, fs_uKind ) values(?,?,?);"
}
DefineSql(StmtDef,FightSkillSql)

function FightSkill.Dbs_SaveFightSkill(PlayerId, name, fs_kind)
	FightSkillSql.Dbs_SaveFightSkill:ExecSql( "", PlayerId, name, fs_kind )
end

local StmtDef=
{ 
	"_AddSkillLayer",
	"replace into tbl_skill_layer( cs_uId, fs_sName, sl_uLayer ) values(?,?,?);"
}
DefineSql(StmtDef,FightSkillSql)

function FightSkill.AddSkillLayer(nCharID, sSkillName, nLayer)
	FightSkillSql._AddSkillLayer:ExecSql( "", nCharID, sSkillName, nLayer )
end

local StmtDef=
{ 
	"Dbs_SelectPlayerClass",
	"select cs_uClass from tbl_char_static where cs_uId = ?;"
}
DefineSql(StmtDef,FightSkillSql)

function FightSkill.Dbs_SelectPlayerClass(PlayerId)
	local ret = FightSkillSql.Dbs_SelectPlayerClass:ExecSql("n",PlayerId)
	return ret:GetData(0,0)
end

local StmtDef = 
{
	"Dbs_UpgradeFightSkill",
	[[
		update tbl_fight_skill 
		set fs_uLevel = ?
		where cs_uId = ? and fs_sName = ? and fs_uKind = ?
	]]
}
DefineSql(StmtDef,FightSkillSql)

function FightSkill.Dbs_UpgradeFightSkill(current_level, PlayerId, name, fs_kind)
	FightSkillSql.Dbs_UpgradeFightSkill:ExecSql("", current_level, PlayerId, name, fs_kind)
end

--�ж�����
local StmtDef = 
{
	"Dbs_SelectFightSkill",
	[[
		select fs_uLevel from tbl_fight_skill
		where cs_uId = ? and fs_sName = ? and fs_uKind = ?
	]]
}
DefineSql(StmtDef,FightSkillSql)

local StmtDef = 
{
	"Dbs_InsertFightSkill",
	[[
		insert into tbl_fight_skill(cs_uId,fs_sName,fs_uLevel,fs_uKind) values (?,?,?,?)
	]]
}
DefineSql(StmtDef,FightSkillSql)

--�洢�츳����
function FightSkill.Dbs_SaveTalentSkill(PlayerId,TalentName,Level)
	local res = FightSkillSql.Dbs_SelectFightSkill:ExecStat(PlayerId, TalentName, FightSkillKind.TalentSkill)
	if res:GetRowNum() == 0 then
		FightSkillSql.Dbs_InsertFightSkill:ExecStat(PlayerId, TalentName,Level,FightSkillKind.TalentSkill)
		if g_DbChannelMgr:LastAffectedRowNum() <= 0 then
			CancelTran()
			return false
		end
		return true,Level
	else
		return true	,res:GetData(0,0)
	end
end

--��������:�����ݿ��в�ѯָ�����ָ�����ܵĵȼ�
--����:data:���ID,���������������ͣ����ؽ�����������Ƿ�>0,�͵ȼ�(��ʼΪ0)
function FightSkill.Lua_SelectFightSkill(data)
	local PlayerId = data["PlayerId"]
	local SkillName = data["SkillName"]
	local fs_kind = data["fs_kind"]
	local res = FightSkillSql.Dbs_SelectFightSkill:ExecStat(PlayerId, SkillName, fs_kind)
	--Renton:���ؼ��ܵĵȼ�
	local skilllevel_tbl={}
	local skilllevel = -1
	if res:GetRowNum() > 0 then
		table.insert(skilllevel_tbl,res:GetData(0,0))
		skilllevel = skilllevel_tbl[1]
		--print("skilllevel"..skilllevel)
	end
	return res:GetRowNum() > 0,skilllevel
end

--ѧϰ��ս������
function FightSkill.LuaDB_AddNonFightSkill(data)
	local SkillName = data["SkillName"]
	local PlayerId = data["PlayerId"]
	local sceneName = data["sceneName"]
	
	local skill = NonFightSkill_Common(SkillName)
	if skill == nil then
		return false,2038
	end
	
	local res = FightSkillSql.Dbs_SelectFightSkill:ExecStat(PlayerId, SkillName, FightSkillKind.NonFightSkill)
	if res:GetRowNum() ~= 0 then
		return false,2037
	end	
	
	FightSkill.Dbs_SaveFightSkill(PlayerId, SkillName, FightSkillKind.NonFightSkill )	--DBS
	if g_DbChannelMgr:LastAffectedRowNum() <= 0 then
		CancelTran()
		return false,2038
	end
	
	FightSkill.Dbs_UpgradeFightSkill(1, PlayerId, SkillName, FightSkillKind.NonFightSkill)
	if g_DbChannelMgr:LastAffectedRowNum() <= 0 then
		CancelTran()
		return false,2038
	end
	
	local IsSaveShortCut = false
	if SkillName == "�����" then --ѧ�������ʱ�� ����� �Զ��ŵ������ �ո�λ��
		local ShortCutDB = RequireDbBox("ShortcutDB")
		ShortCutDB.Player_SaveShortcut(PlayerId, 10, EShortcutPieceState.eSPS_Skill, "�����", 1, 1)
		IsSaveShortCut = true
	end
	
	--���������
	local QuestTbl = nil
	local QuestInfo = data["QuestInfo"]
	if QuestInfo then
		local param = {}
		param["iNum"] = 1
		param["sQuestName"] = QuestInfo[1]
		param["sVarName"] = QuestInfo[2]
		param["char_id"] = PlayerId
		local RoleQuestDB = RequireDbBox("RoleQuestDB")
		local IsTrue = RoleQuestDB.AddQuestVarNum(param)
		if IsTrue then
			QuestTbl = param
		else
			CancelTran()
			return false,0
		end
	end
	
	--���ټ�Ӷ���ȼ�ָ������
	--local MercenaryLevelDB = RequireDbBox("MercenaryLevelDB")
	--local MLRes = MercenaryLevelDB.SlowAddMercenaryLevelCount(PlayerId, "�����")
	--Ӷ���ȼ���Ȩ����
	--local MLPower = nil
	--if SkillName == "�������ݾư�" or SkillName == "����" then
	--	MLPower = MercenaryLevelDB.SlowSetMercenaryLevelAward(PlayerId, SkillName)
	--	if MLPower == nil then
	--		CancelTran()
	--		return false,0
	--	end
	--end
	
	local g_LogMgr = RequireDbBox("LogMgrDB")
	g_LogMgr.SavePlayerSkillInfo( PlayerId,SkillName,1,0,1)
			
	local tbl = 
	{
		["SkillName"] = SkillName,
		["QuestInfo"] = QuestTbl,
		--["MLRes"] = MLRes,
		--["MLPower"] = MLPower,
		["IsSaveShortCut"] = IsSaveShortCut
	}
	return true,tbl
end

--ֻ����GMָ��ʹ��,��Ҫ�Ż�
function FightSkill.Lua_AddFightSkill(data)
	local name = data["name"]
	local level = data["level"]
	local fs_kind = data["kind"]
	local PlayerId = data["PlayerId"]
	local Class = data["Class"]
	local PlayerLevel = data["PlayerLevel"]
	local IsGMcmd = data["IsGMcmd"]
	local layer  = data["layer"]
	local sceneName = data["sceneName"]
	local g_LogMgr = RequireDbBox("LogMgrDB")
	 
	--�жϸü����Ƿ���ѧϰ
	if not IsGMcmd then 
		local res = FightSkillSql.Dbs_SelectFightSkill:ExecSql("n", PlayerId, name, fs_kind)
		if res:GetRowNum() ~= 0 then
			return false,2037
		end
	end

	local current_level = 0
	if fs_kind == FightSkillKind.Talent then
		--ѧϰ�츳�ж�
		local TalentTbl =  loadGeniusfile(Class)
		if not TalentTbl(name) then
			return false,2037
		end
		if SkillPart_Common(name) then
			local LevelTbl  = g_PlayerLevelToSkillLevelTbl[name]
			if #(LevelTbl) > 1 then
				current_level = LevelTbl[1][3]
			else
				current_level = PlayerLevel
			end
			 
		else
			current_level =  level + 10
		end
		
		--�츳���ж� Todo
		if not FightSkill.CheckTalentPoint(PlayerId) then
			return false,2035 
		end	
		
		if layer > 0 then
			local tblLayerCount = FightSkillSql._GetTalentNameByLayer:ExecStat(PlayerId,layer)
			if tblLayerCount:GetNumber(0,0) < LayerLimitTbl[layer] then
				--��һ�׶�ѧϰ������������������ѧϰ�ý׶�
				return false,1606
			end		
			--��ӽ׶���Ϣ
			--layerΪ0˵���ǹ������ܣ����ô�
			FightSkill.AddSkillLayer(PlayerId, name, layer )	
			if g_DbChannelMgr:LastAffectedRowNum() <= 0 then
				CancelTran()
				return false,1600
			end
		end
	elseif fs_kind == FightSkillKind.Skill then
		--ѧϰ�����ж�
		local skill = SkillPart_Common(name)
		if skill == nil then
			return false,2037
		end
		if skill("ClassLimit") ~= Class then
			return false,2036
		end	
			
		current_level = level + 1
	end
	
	FightSkill.Dbs_SaveFightSkill(PlayerId, name, fs_kind )	--DBS
	if g_DbChannelMgr:LastAffectedRowNum() <= 0 then
		CancelTran()
		return false,2038
	end
	
	FightSkill.Dbs_UpgradeFightSkill(current_level, PlayerId, name, fs_kind)
	if g_DbChannelMgr:LastAffectedRowNum() <= 0 then
		CancelTran()
		return false,2038
	end

	if fs_kind == FightSkillKind.Talent then --1����ѧϰ 2ϴ�츳 
		g_LogMgr.SavePlayerTelentInfo( PlayerId,name,1 ) 
	elseif fs_kind == FightSkillKind.Skill then --1����ѧϰ��2��������
		g_LogMgr.SavePlayerSkillInfo( PlayerId,name,current_level,0,0)
	end
	
	local tbl = 
	{
		["kind"] = fs_kind,
		["current_level"] = current_level,
		["IsGMcmd"] = IsGMcmd,
		["name"] = name,
		["QuestInfo"] = QuestTbl,
	}
	return true,tbl
end

function FightSkill.LuaDB_AddTalentSkill(data)
	local TalentName = data["TalentName"]
	local PlayerId = data["PlayerId"]
	local PlayerLevel = data["PlayerLevel"]
	local Class = data["Class"]
	local Layer  = data["TreeNode"]
	local SceneName = data["SceneName"]
	
	--�жϸ��츳�Ƿ�ѧϰ
	local res = FightSkillSql.Dbs_SelectFightSkill:ExecStat(PlayerId, TalentName, FightSkillKind.Talent)
	if res:GetRowNum() ~= 0 then
		return false,2037
	end

	local TalentTbl =  loadGeniusfile(Class)
	if not TalentTbl(TalentName) then
		return false,2037
	end
	
	--�츳���ж�
	if not FightSkill.CheckTalentPoint(PlayerId) then
		return false,2035 
	end	
	
	if Layer >= 2 then
		--�ж�ѧϰ�ý׶��츳�������Ƿ���ȷ
		local nTalentCount = 0
		if Layer == ESkillTreeNode.eSTN_MainFirst or Layer == ESkillTreeNode.eSTN_MainSecond
			 or Layer == ESkillTreeNode.eSTN_MainThird or Layer == ESkillTreeNode.eSTN_MainFourth 
			 or Layer == ESkillTreeNode.eSTN_LeftFirst or Layer == ESkillTreeNode.eSTN_RightFirst then
			nTalentCount = FightSkillSql._CountMainTalentNameByLayer:ExecStat(PlayerId,Layer)
		elseif Layer == ESkillTreeNode.eSTN_LeftSecond or Layer == ESkillTreeNode.eSTN_RightSecond then
			nTalentCount = FightSkillSql._CountTalentNameByLayer:ExecStat(PlayerId,Layer-1)
		else
			return false,1606
		end

		if nTalentCount:GetData(0,0) < LayerLimitTbl[Layer] then
			return false,1606
		end
	elseif Layer ~= 1 then
		return false,1600
	end
	
		--��ӽ׶���Ϣ
	FightSkill.AddSkillLayer(PlayerId, TalentName, Layer )	
	if g_DbChannelMgr:LastAffectedRowNum() <= 0 then
		CancelTran()
		return false,1600
	end	
	--�ж��Ƿ�Ϊ�츳����
	local current_level = 0
	if SkillPart_Common(TalentName) and tonumber(SkillPart_Common(TalentName,"ClassLimit")) == Class then 
		local LevelTbl  = g_PlayerLevelToSkillLevelTbl[TalentName]
		if #(LevelTbl) > 1 then
			current_level = LevelTbl[1][3]
		else
			current_level = PlayerLevel 
		end
		local result,level = FightSkill.Dbs_SaveTalentSkill(PlayerId,TalentName,current_level)
		if result then
			current_level = level
		else
			return false,2038
		end			
	else
		current_level =  10
	end	
	
	FightSkill.Dbs_SaveFightSkill(PlayerId, TalentName, FightSkillKind.Talent )
	if g_DbChannelMgr:LastAffectedRowNum() <= 0 then
		CancelTran()
		return false,2038
	end
	
	FightSkill.Dbs_UpgradeFightSkill(10, PlayerId, TalentName, FightSkillKind.Talent)
	if g_DbChannelMgr:LastAffectedRowNum() <= 0 then
		CancelTran()
		return false,2038
	end

	local g_LogMgr = RequireDbBox("LogMgrDB")
	g_LogMgr.SavePlayerTelentInfo( PlayerId,TalentName,1 ) --1����ѧϰ 2ϴ�츳 
	local tbl = 
	{
		["current_level"] = current_level,
		["name"] = TalentName,
		["kind"] = FightSkillKind.Talent
	}
	return true,tbl	
end

function FightSkill.Lua_UpdateFightSkill(data)
	local name = data["name"]
	local type = data["ActionType"] --typeΪ0����ѧϰ��1��������
	local PlayerId = data["PlayerId"]
	local Class = data["Class"]
	local PlayerLevel = data["PlayerLevel"]
	local SkillLevel = data["SkillLevel"]
	local g_LogMgr = RequireDbBox("LogMgrDB")
	local sceneName = data["sceneName"]
	local fs_kind = 0
	if SkillPart_Common(name) and SkillPart_Common(name,"SkillLearnType") and SkillPart_Common(name,"ClassLimit") ~= 0 then
		if tonumber(SkillPart_Common(name,"SkillLearnType")) == 4 then
			fs_kind = FightSkillKind.Skill
		elseif tonumber(SkillPart_Common(name,"SkillLearnType")) == 1 then
			fs_kind = FightSkillKind.TalentSkill
		end
	else 
		return false,2038
	end	

	--�жϸü����Ƿ���ѧϰ
	local res = FightSkillSql.Dbs_SelectFightSkill:ExecSql("n", PlayerId, name,fs_kind)
	if type == 1 and res:GetRowNum() == 0 then
		return false,2037
	end

	local next_level,need_Level = 0,0
	local LevelTbl  = g_PlayerLevelToSkillLevelTbl[name]
	if type == 0 then --ѧϰ��������
		if SkillPart_Common(name,"SkillLearnType") == 4 then
			if PlayerLevel < SkillPart_Common(name,"NeedLevel") then
				return false,2038 --"��ĵȼ�������"
			end
		end		
		if (#(LevelTbl) == 1 and tostring(LevelTbl[1][3]) == "l") then
			next_level = PlayerLevel
		else
			next_level = LevelTbl[1][3]
		end
		need_Level = SkillPart_Common(name,"NeedLevel")
	elseif type == 1 and #(LevelTbl) > 1 then --�����������ܺ��츳����
		local current_level = res:GetData(0,0)
		for i = 1 ,#(LevelTbl) do
			if LevelTbl[i][3] == current_level then
				if LevelTbl[i+1] == nil then --�ﵽ��ߵȼ�
					return false,2038
				end
				if PlayerLevel >= LevelTbl[i+1][1] then
					next_level = LevelTbl[i+1][3]
					need_Level = LevelTbl[i+1][1]
				else
					return false,2038 --"��ĵȼ�������"
				end
				break
			elseif  LevelTbl[i][3] > current_level then
				next_level = LevelTbl[i][3]
				need_Level = LevelTbl[i][1]
				break
			end
		end	
	end	
	
	if need_Level > 80 then
		return false,2038
	end
	
--	if need_Level >= 10 then
--		local tblSysCount = FightSkillSql._CountSys:ExecSql('n',PlayerId)
--		if tblSysCount:GetData(0,0) == 0 then
--			if type == 0 then
--				return false,2034
--			else
--				return false,2033
--			end
--		end	
--	end
	
	local money_count,soul_count = 0,0
	if type == 0 then
		local ConsumeTbl = GetLearnSkillConsume(name)
		soul_count = ConsumeTbl.SoulNumber
		money_count = ConsumeTbl.MoneyNumber
	elseif type == 1 then
		local  ConsumeTbl = GetUpSkillConsume(name,need_Level)
		soul_count = ConsumeTbl.SoulNumber
		money_count = ConsumeTbl.MoneyNumber
	end	
    local fun_info = g_MoneyMgr:GetFuncInfo("LearnSkill")
    g_LogMgr.SavePlayerSkillInfo( PlayerId,name,next_level,type,0)
    local MoneyManagerDB=	RequireDbBox("MoneyMgrDB")
	local suc, msgID, moneyCount = MoneyManagerDB.SubtractMoneyBySysFee(money_count, PlayerId, fun_info,fun_info["LearnSkill"],event_type_tbl["����ѧϰ�����"])
	local add_Money = moneyCount
	local add_bMoney = msgID
	if suc == false then
        return false, msgID
	end
	    
	local tblSoul = {}
	tblSoul["PlayerId"]  = PlayerId
	tblSoul["addSoulType"]  = event_type_tbl["����ѧϰ���Ļ�"]
	tblSoul["soulCount"] = -soul_count
	local g_EquipMgr= RequireDbBox("EquipMgrDB")
	local Flag,SoulRet = g_EquipMgr.ModifyPlayerSoul(tblSoul)
	if not Flag then
		CancelTran()
		return false,2038
	end
	
	if type == 0 then
		FightSkill.Dbs_SaveFightSkill(PlayerId, name, fs_kind )	--DBS
		if g_DbChannelMgr:LastAffectedRowNum() <= 0 then
			CancelTran()
			return false,2038
		end
	end
	--Renton,�õ��ü��ܿ��ܶ�Ӧ������,���ܵȼ��û���
	--��ע�����ű��TABLEûת
	local skillname = data["name"]
	--���ܵȼ�1
	local now_skill_level = 0
	local temptbl = loadstring("return "..SkillPart_Common(skillname,"PlayerLevelToSkillLevel"))()
	for i,v in ipairs(temptbl) do
		if v[3] == SkillLevel then
			now_skill_level = i
		end
	end
	--���ܵȼ�2
	local next_skill_level = now_skill_level + 1
	--��ֵ�ȼ�2
	local next_skill_level_value = -1
	if temptbl[next_skill_level] then
		next_skill_level_value = temptbl[next_skill_level][3]
	end
	local RoleQuestDB = RequireDbBox("RoleQuestDB")
	local datatbl = {}
	datatbl[1] = PlayerId
	local restbl = nil
	local varname = ""
	local skillQuestTbl = {}
	--�ж��Ƿ������񲢼Ӽ���
	--���ع����п����Ժ��ж�������ͬһ�����ܵ�ͬһ�ȼ�����������Ҫ�ѽ������һ��table�����ز���ʾ�ͻ���
	if g_LearnSkillMgr[skillname] ~= nil then
		if g_LearnSkillMgr[skillname][next_skill_level] ~= nil then
			for _,v in ipairs(g_LearnSkillMgr[skillname][next_skill_level]) do
				datatbl[2] = v
				restbl = RoleQuestDB.GetQuestState(datatbl)
				if restbl == QuestState.init then
					local addnum_tbl= {}
					addnum_tbl["iNum"] = 1
					addnum_tbl["char_id"] = PlayerId
					addnum_tbl["sQuestName"] = datatbl[2]
					varname = skillname..next_skill_level
					addnum_tbl["sVarName"] = varname
					local IsTrue = RoleQuestDB.AddQuestVarNum(addnum_tbl)
		
					if IsTrue then
						table.insert(skillQuestTbl,addnum_tbl)
					else
						CancelTran()
						return false,0
					end
				end
			end
		end
	end
------------------------------------------------------------------------------------	
	FightSkill.Dbs_UpgradeFightSkill(next_level, PlayerId, name,fs_kind)
	if g_DbChannelMgr:LastAffectedRowNum() <= 0 then
		CancelTran()
		return false,2038
	end
	
	local ShortcutInfo
	if type == 0 then
		local ShortCutDB = RequireDbBox("ShortcutDB")
		ShortcutInfo = ShortCutDB.InitSkillState(PlayerId,name,Class)
	end
	
	local tbl = 
	{
		["current_level"] = next_level,
		["name"] = name,
		["money_count"] = add_Money,
		["bmoney_count"] = add_bMoney,
		["SoulRet"] = SoulRet,
		["ShortcutInfo"] = ShortcutInfo
	}
	return true,tbl,skillQuestTbl
end

-------------------------------����ϵ���ڵ㡢�׶�-------------------------------
local StmtDef =
{
	"_CountSys",
	"select count(*) from tbl_skill_Series where cs_uId = ?;"
}
DefineSql(StmtDef,FightSkillSql)

local StmtDef =
{
	"_AddSys",
	"replace into tbl_skill_Series(cs_uId,ss_uSeries) values(?,?);"
}
DefineSql(StmtDef,FightSkillSql)

local StmtDef =
{
	"_AddNode",
	"replace into tbl_skill_node(cs_uId,sn_uNode) values(?,?);"
}
DefineSql(StmtDef,FightSkillSql)

function FightSkill.IsSeries(nCharID)
	local tblSysCount = FightSkillSql._CountSys:ExecStat(nCharID)
	if tblSysCount:GetData(0,0) > 0 then
		return true
	else
		return false
	end 
end

local CampIDToQuestNameTbl = {
								[1] = "СӶ����תְ֮·�����ף�",
								[2] = "СӶ����תְ֮·����ʥ��",
								[3] = "СӶ����תְ֮·����˹��"
							}

local QuestStateTbl = {
	init	= 1, 
	failure	= 2,
	finish	= 3
}

--ѡ������ϵ
function FightSkill.SetSeriesDB(data)
	local nSys = data["nSys"]
	local nCharID = data["nCharID"]
	local classId = data["ClassID"]
	local CampID = data["CampID"]
	
--	local RoleQuestDB = RequireDbBox("RoleQuestDB")
--	local QuestName = CampIDToQuestNameTbl[CampID]
--	local QuestState = RoleQuestDB.GetQuestState({nCharID,QuestName})
--	if QuestState ~= QuestStateTbl.init and QuestState ~= QuestStateTbl.finish then
--		return false,1608
--	end

	--�Ѿ��޹�
	local tblSysCount = FightSkillSql._CountSys:ExecSql('n',nCharID)
	if tblSysCount:GetData(0,0) > 0 then
		return false
	end
	
	FightSkillSql._AddSys:ExecSql('',nCharID,nSys)
	if g_DbChannelMgr:LastAffectedRowNum() <= 0 then
		CancelTran()
		return false
	end
	
	FightSkillSql._AddNode:ExecSql('',nCharID,1)
	if g_DbChannelMgr:LastAffectedRowNum() <= 0 then
		CancelTran()
		return false
	end
	
	local FirstTimeName = "���תְ"
	local NoviceDirectDB = RequireDbBox("NoviceDirectDB")
	local TimeCount = NoviceDirectDB.GetPlayerFirstTimeCount(nCharID,FirstTimeName)
	local TalentSkillTbl = {}
	if TimeCount < 1 then --��һ��תְʱ����ѧϰ��һ���츳
		NoviceDirectDB.InsertPlayerFirstFinishInfo({["PlayerId"] = nCharID,["FirstTimeName"] = "���תְ"})
		if g_DbChannelMgr:LastAffectedRowNum() <= 0 then
			CancelTran()
			return false,2038
		end	
		
		local current_level = 0
		local TalentName = ""
		local TalentTbl =  loadGeniusfile(classId)
		local KeysTbl = TalentTbl:GetKeys()
		for i ,p in pairs(KeysTbl) do 
			if TalentTbl(p,"GiftSkillSeries") == nSys and TalentTbl(p,"ViewPosition") == 1 then
				TalentName = p
				FightSkill.AddSkillLayer(nCharID,TalentName,1)	
				if g_DbChannelMgr:LastAffectedRowNum() <= 0 then
					CancelTran()
					return false,2038
				end	
						
				FightSkill.Dbs_SaveFightSkill(nCharID, TalentName, FightSkillKind.Talent )	--DBS
				if g_DbChannelMgr:LastAffectedRowNum() <= 0 then
					CancelTran()
					return false,2038
				end
	
				if SkillPart_Common(TalentName) and tonumber(SkillPart_Common(TalentName,"ClassLimit")) == classId then 
					local LevelTbl  = g_PlayerLevelToSkillLevelTbl[TalentName]
					if #(LevelTbl) > 1 then
						current_level = LevelTbl[1][3]
					else
						current_level = 10 
					end
					local result,level = FightSkill.Dbs_SaveTalentSkill(nCharID,TalentName,current_level)
					if result then
						current_level = level
					else
						return false,2038
					end			
				else
					current_level =  10
				end	
	
				FightSkill.Dbs_UpgradeFightSkill(current_level, nCharID, TalentName, FightSkillKind.Talent)
				if g_DbChannelMgr:LastAffectedRowNum() <= 0 then
					CancelTran()
					return false,2038
				end
				TalentSkillTbl = {
									["name"] = TalentName,
									["kind"] = FightSkillKind.Talent,
									["current_level"] = current_level
								}
				break
			end
		end
	end
	
	--�����¼�����Ӽ���
	local param = {}
	param["char_id"] = nCharID
	param["sVarName"] = "���תְ"
	param["iNum"] = 1
	param["CanShareTeamMateTbl"] = {}
	local RoleQuestDB = RequireDbBox("RoleQuestDB")
	local QuestVarTbl = RoleQuestDB.AddVarNumForTeamQuests(param)
	if QuestVarTbl and QuestVarTbl[1] and QuestVarTbl[1][nCharID][1][3] == false then
		CancelTran()
		return false
	end
	
	--���ټ�Ӷ���ȼ�ָ������
	--local MercenaryLevelDB = RequireDbBox("MercenaryLevelDB")
	--local MLRes = MercenaryLevelDB.SlowAddMercenaryLevelCount(nCharID, "תְ")
	local tbl = {
					--["MLRes"] = MLRes,
					["QuestVarTbl"] = QuestVarTbl,
					["TalentSkillTbl"] = TalentSkillTbl,
				}
	return true,tbl
end

local StmtDef =
{
	"_GetSys",
	"select ss_uSeries from tbl_skill_Series where cs_uId = ?;"
}
DefineSql(StmtDef,FightSkillSql)
local StmtDef =
{
	"_GetNodes",
	"select distinct(sl_uLayer) from tbl_skill_layer where cs_uId = ?;"
}
DefineSql(StmtDef,FightSkillSql)

--�������ϵ�����ܣ������Ϣ
function FightSkill.GetSeriesDB(data)
	local nCharID = data["nCharID"]
	--����ϵ
	local tblSeries = FightSkillSql._GetSys:ExecSql('n',nCharID)
	local series = 0
	if tblSeries:GetRowNum() ~= 0 then
		series = tblSeries:GetNumber(0,0)
	end
	
	--����
	local SkillRet = FightSkill.Dbs_LoadFightSkill(nCharID,true)
	
	--���
	local tblNodes = FightSkillSql._GetNodes:ExecSql('n',nCharID)
	local row = tblNodes:GetRowNum()
	local Nodes = {}
	for i=1,row do
		table.insert(Nodes,tblNodes:GetNumber(i-1,0))
	end	
	
	return series,SkillRet,Nodes
end

--�������ϵ
function FightSkill.NpcGetSeriesDB(data)
	local nCharID = data["nCharID"]
	
	--����ϵ
	local tblSeries = FightSkillSql._GetSys:ExecSql('n',nCharID)
	local series = 0
	if tblSeries:GetRowNum() ~= 0 then
		series = tblSeries:GetNumber(0,0)
	end
	return series
end

local StmtDef =
{
	"_CountMainTalentNameByLayer",
	"select  count(*) from tbl_skill_layer where cs_uId = ? and sl_uLayer < ?;"
}
DefineSql(StmtDef,FightSkillSql)

local StmtDef =
{
	"_CountTalentNameByLayer",
	"select  count(*) from tbl_skill_layer where cs_uId = ? and sl_uLayer = ?;"
}
DefineSql(StmtDef,FightSkillSql)

local StmtDef =
{
	"_GetUpperNode",
	"select sn_uNode from tbl_skill_node where cs_uId = ? order by sn_uNode desc limit 1;"
}
DefineSql(StmtDef,FightSkillSql)

--�жϸò��Ƿ��Ѿ�ѧϰ��
function FightSkill.IsStudyALayer(nCharID,layer)
		local str = "select count(*) from tbl_skill_node  where cs_uId = " .. nCharID .. " and sn_uNode in("
		local list_str = ""
		local nodes = SkillLayer[layer]
		for i =1, #nodes-1 do
			list_str = list_str .. nodes[i] .. ", "
		end
		list_str = list_str .. nodes[#nodes] .. ")"
		local query_string = str .. list_str
		local _,result = g_DbChannelMgr:TextExecute(query_string)
		return result:GetNumber(0,0) > 0 
end
----------------------------------------ϴ�츳---------------------------------------
--��ѯ���е��츳��Ϣ
local StmtDef =
{
	"_GetAllGenius",
	"select fs_sName from tbl_fight_skill where cs_uId = ? and fs_uKind = 2 ;"
}
DefineSql(StmtDef,FightSkillSql)

--ɾ�����е��츳
local StmtDef =
{
	"Dbs_ClearAllGenius",
	"delete from tbl_fight_skill where cs_uId = ? and fs_uKind = 2 ;"
}
DefineSql(StmtDef,FightSkillSql)

--ɾ�������츳��Ӧ�Ľڵ�
local StmtDef =
{
	"Dbs_ClearAllSkillNode",
	"delete from tbl_skill_node where cs_uId = ?;"
}
DefineSql(StmtDef,FightSkillSql)

--ɾ������Ҷ�Ӧ������ϵ
local StmtDef =
{
	"Dbs_ClearSkillSeries",
	"delete from tbl_skill_Series where cs_uId = ?;"
}
DefineSql(StmtDef,FightSkillSql)

--ɾ�����м��������׶�
local StmtDef =
{
	"Dbs_ClearSkillLayer",
	"delete from tbl_skill_layer where cs_uId = ?;"
}
DefineSql(StmtDef,FightSkillSql)

----------------------------------������м�����Ϣ-------------------------------------------
local StmtDef=
{ 
	"Dbs_LoadFightSkill",
	[[
		select tfs2.fs_sName, tfs2.fs_uLevel, tfs2.fs_uKind from tbl_fight_skill as tfs1 , tbl_fight_skill as tfs2 
		where tfs1.fs_sName = tfs2.fs_sName and tfs1.fs_uKind = 2 and tfs2.fs_uKind = 5 and tfs1.cs_uId = tfs2.cs_uId and tfs1.cs_uId = ? 
		union 
		select fs_sName, fs_uLevel, fs_uKind from tbl_fight_skill where cs_uId = ? and fs_uKind != 5;
	]]
}
DefineSql(StmtDef,FightSkillSql)

local StmtDef=
{ 
	"Dbs_LoadFightSkillMerge",
	[[ 
		select tfs1.fs_sName, ifnull( tfs2.fs_uLevel,tfs1.fs_uLevel), tfs1.fs_uKind from tbl_fight_skill as tfs1 
		left join tbl_fight_skill as tfs2 
		on
		(tfs1.fs_sName = tfs2.fs_sName and  tfs1.cs_uId = tfs2.cs_uId and tfs2.fs_uKind = 5 ) where tfs1.fs_uKind = 2 and tfs1.cs_uId = ? 
		union 
		select fs_sName, fs_uLevel, fs_uKind from tbl_fight_skill where fs_uKind not in (2,5) and cs_uId = ?; 
	]]
}
DefineSql(StmtDef,FightSkillSql)

function FightSkill.Lua_ClearAllGenius(data)
	local PlayerId 		= data["PlayerId"]
	local PlayerLevel 	= data["PlayerLevel"]
	local ConsumeItemName = ""
	local ConsumeBigID = g_ItemInfoMgr:GetBasicItemBigID()
	local ConsumeItemNumber = 0	
	
	local ConsumeItemTbl = GetClearTalentConsumeItem(PlayerLevel)
	local g_RoomMgr = RequireDbBox("GasRoomMgrDB")	
	for i , ItemTbl in pairs (ConsumeItemTbl["ConsumeItem"]) do
		local ItemNum =  g_RoomMgr.GetItemNum({["nCharId"] = PlayerId,["ItemType"] = ConsumeBigID, ["ItemName"] = ItemTbl[1]})
		if ItemNum >= ItemTbl[2] then
			ConsumeItemName = ItemTbl[1]
			ConsumeItemNumber = ItemTbl[2]
			break
		end
	end
	
	--תְ������Ʒ
	local DelItemResult = nil
	if ConsumeItemNumber and ConsumeItemNumber >= 0 and ConsumeItemName and ConsumeItemName ~= "" then
		DelItemResult = g_RoomMgr.DelItem(PlayerId,ConsumeBigID,ConsumeItemName,ConsumeItemNumber,nil,event_type_tbl["���תְ"])
		if IsNumber(DelItemResult) and ConsumeItemNumber > 0 then
			CancelTran()
			return false,2039
		end
		
	else
		return false,2039
	end
	
	--תְ��Ǯ
	local MoneyManagerDB = RequireDbBox("MoneyMgrDB")
	local FunInfo = g_MoneyMgr:GetFuncInfo("ClearTalent")
	local Suc, BindingMoney, Money = MoneyManagerDB.SubtractMoneyBySysFee(ConsumeItemTbl["ConsumeMoney"], PlayerId, FunInfo,FunInfo["ClearTalent"], event_type_tbl["���תְ"])
	if not Suc then
        return false, BindingMoney
	end		
	
	--תְ�ۻ�
	local SoulTbl = {}
	SoulTbl["PlayerId"]  	= PlayerId
	SoulTbl["addSoulType"]  = event_type_tbl["���תְ"]		
	SoulTbl["soulCount"] 	= -ConsumeItemTbl["ConsumeSoul"]
	local EquipMgr 		= RequireDbBox("EquipMgrDB")
	local Suc,SoulRet 	= EquipMgr.ModifyPlayerSoul(SoulTbl)	
	if not Suc then
		CancelTran()
		return false,2039
	end
		
	local skills = FightSkill.Dbs_LoadFightSkill(PlayerId)
	local tblSeries = FightSkillSql._GetSys:ExecSql('n',PlayerId)
	if tblSeries:GetRowNum() == 0 then
		return false,2039
	end
	
	local nSys = tblSeries:GetData(0,0)
	FightSkillSql.Dbs_ClearSkillSeries:ExecSql("",PlayerId )
	if g_DbChannelMgr:LastAffectedRowNum() <= 0 then
		CancelTran()
		return false,2039
	end
	local AllGenius =  FightSkillSql._GetAllGenius:ExecStat(PlayerId)
	if AllGenius:GetRowNum() > 0 then
		local g_LogMgr = RequireDbBox("LogMgrDB")
		for i =1,AllGenius:GetRowNum() do
			g_LogMgr.SavePlayerTelentInfo( PlayerId,AllGenius(i,1),2 )
		end
	end
	FightSkillSql.Dbs_ClearAllGenius:ExecSql("",PlayerId )
	FightSkillSql.Dbs_ClearAllSkillNode:ExecSql("",PlayerId )
	FightSkillSql.Dbs_ClearSkillLayer:ExecSql("",PlayerId )
	local ResultTbl = 
					{
						["Skills"] 			= skills,
						["DelItemResult"] 	= DelItemResult,
						["BindingMoney"] 	= BindingMoney,
						["Money"]			= Money,
						["SoulRet"]			= SoulRet,
					}
	return true,ResultTbl
end

function FightSkill.Dbs_LoadFightSkill(PlayerId,IsMergeTalent)
	local SkillRet
	if IsMergeTalent then
		SkillRet = FightSkillSql.Dbs_LoadFightSkillMerge:ExecStat( PlayerId,PlayerId )
	else		
		SkillRet = FightSkillSql.Dbs_LoadFightSkill:ExecStat( PlayerId,PlayerId )
	end
	local row = SkillRet:GetRowNum()
	local SkillRetTbl = {}
	for i=1,row do
		local name = SkillRet:GetData(i-1,0)
		local level = SkillRet:GetData(i-1,1)
		local kind 	= SkillRet:GetData(i-1,2)
		table.insert(SkillRetTbl,{name,level,kind})
	end	
	return SkillRetTbl
end


------------------------------�չ�����----------------------------------------
--�õ��չ�����
local StmtDef=
{ 
	"Dbs_LoadCommonlyFightSkill",
	"select fs_sName, fs_uLevel, fs_uKind from tbl_fight_skill where cs_uId = ? and fs_uKind = ?;"
}
DefineSql(StmtDef,FightSkillSql)

function FightSkill.Dbs_LoadCommonlyFightSkill(PlayerId)
	local SkillRet = FightSkillSql.Dbs_LoadCommonlyFightSkill:ExecSql( "s[32]nn", PlayerId,FightSkillKind.NormSkill )
	return SkillRet
end

------------------------------------�ٻ������--------------------------------------
--�޸��ٻ��޵�����RealName
local StmtDef=
{ 
	"Dbs_SetServantName",
	"replace into tbl_char_servant_name( cs_uId, csn_sServantResName, csn_sServantRealName ) values(?,?,?);"
}
DefineSql(StmtDef,FightSkillSql)

function FightSkill.Dbs_SetServantName(data)
	local PlayerId 				= data["PlayerId"]
	local ServantResName 		= data["ServantResName"]
	local ServantRealNameName 	= data["ServantRealNameName"]
	FightSkillSql.Dbs_SetServantName:ExecSql("", PlayerId, ServantResName, ServantRealNameName)
	if g_DbChannelMgr:LastAffectedRowNum() <= 0 then
		CancelTran()
		return false
	end
	return true
end

--�õ��ٻ��޵�����RealName
local StmtDef=
{ 
	"Dbs_SelectServantName",
	"select csn_sServantRealName from tbl_char_servant_name where cs_uId = ? and csn_sServantResName = ?;"
}
DefineSql(StmtDef,FightSkillSql)

function FightSkill.Dbs_SelectServantName(data)
	local PlayerId 			= data["PlayerId"]
	local ServantResName 	= data["ServantResName"]
	local NameRet = FightSkillSql.Dbs_SelectServantName:ExecSql("s[32]", PlayerId, ServantResName)
	return NameRet
end

--�õ��ٻ��޵�����RealName
local StmtDef=
{ 
	"Dbs_SelectAllServantName",
	"select csn_sServantResName,csn_sServantRealName from tbl_char_servant_name where cs_uId = ?;"
}
DefineSql(StmtDef,FightSkillSql)

function FightSkill.Dbs_SelectAllServantName(PlayerId)
	local NameRet = FightSkillSql.Dbs_SelectAllServantName:ExecSql("s[32]s[32]", PlayerId)
	return NameRet
end


SetDbLocalFuncType(FightSkill.LuaDB_AddNonFightSkill)
SetDbLocalFuncType(FightSkill.Lua_SelectFightSkill) 
SetDbLocalFuncType(FightSkill.Lua_UpdateFightSkill)
SetDbLocalFuncType(FightSkill.SetSeriesDB)
SetDbLocalFuncType(FightSkill.GetSeriesDB)
SetDbLocalFuncType(FightSkill.Lua_ClearAllGenius)
SetDbLocalFuncType(FightSkill.Dbs_SetServantName)
SetDbLocalFuncType(FightSkill.LuaDB_AddTalentSkill)
return FightSkill
