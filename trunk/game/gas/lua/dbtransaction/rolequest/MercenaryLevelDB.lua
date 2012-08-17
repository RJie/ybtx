gac_gas_require "activity/quest/MercenaryLevelCfg"
gac_gas_require "liveskill/LiveSkillMgr"

local g_MercenaryLevelTbl = g_MercenaryLevelTbl
local event_type_tbl = event_type_tbl
local LiveSkillMgr = CLiveSkillMgr:new()

local StmtContainer = class()

local StmtDef = 
{
	"_AddNewMercenaryLevel",
	[[
		insert into tbl_mercenary_level
			(cs_uId)
		values
			(?)
	]]
}
DefineSql(StmtDef, StmtContainer)

local StmtDef = 
{
	"_AddMercenaryLevelCount",
	[[
		update tbl_mercenary_level
		set
			ml_uCount1 = ml_uCount1 + ?,
			ml_uCount2 = ml_uCount2 + ?,
			ml_uCount3 = ml_uCount3 + ?,
			ml_uCallenge = ml_uCallenge + ?
		where
			cs_uId = ?
	]]
}
DefineSql(StmtDef, StmtContainer)

local StmtDef = 
{
	"_AddMercenaryLevelStatus",
	[[
		update tbl_mercenary_level
		set
			ml_uStatus = ml_uStatus + ?
		where
			cs_uId = ?
	]]
}
DefineSql(StmtDef, StmtContainer)

local StmtDef = 
{
	"_MercenaryLevelUpInit",
	[[
		update tbl_mercenary_level
		set
			ml_uStatus = 1,
			ml_sSubject1 = ?,
			ml_sSubject2 = ?,
			ml_sSubject3 = ?,
			ml_uCount1 = 0,
			ml_uCount2 = 0,
			ml_uCount3 = 0,
			ml_uCallenge = 0
		where
			cs_uId = ?
	]]
}
DefineSql(StmtDef, StmtContainer)

local StmtDef = 
{
	"_MercenaryLevelUp",
	[[
		update tbl_char_basic
		set
			cb_uMercenaryLevel = cb_uMercenaryLevel + ?
		where
			cs_uId = ?
	]]
}
DefineSql(StmtDef, StmtContainer)

local StmtDef = 
{
	"_GetMercenaryLevelInfo",
	[[
		select
			ml_uStatus, ml_sSubject1, ml_sSubject2, ml_sSubject3, ml_uCount1, ml_uCount2, ml_uCount3, ml_uCallenge
		from
			tbl_mercenary_level
		where
			cs_uId = ?
	]]
}
DefineSql(StmtDef, StmtContainer)

local StmtDef = 
{
	"_GetPlayerLevel",
	[[
		select 
			cb_uLevel, cb_uMercenaryLevel
		from
			tbl_char_basic
		where
			cs_uId = ?
	]]
}
DefineSql(StmtDef, StmtContainer)

local StmtDef = 
{
	"_GetMercenaryIntegral",
	[[
		select 
			cs_uLevelIntegral
		from
			tbl_char_integral
		where
			cs_uId = ?
	]]
}
DefineSql(StmtDef, StmtContainer)

local StmtDef = 
{
	"_AddMercenaryLevelAward",
	[[
		insert into tbl_mercenary_level_award
			(cs_uId, mla_sAward)
		values
			(?,?)
	]]
}
DefineSql(StmtDef, StmtContainer)

local StmtDef = 
{
	"_GetMercenaryLevelAward",
	[[
		select
			mla_sAward
		from
			tbl_mercenary_level_award
		where
			cs_uId = ?
	]]
}
DefineSql(StmtDef, StmtContainer)

local StmtDef = 
{
	"_DeleteAllMercenaryLevelAward",
	[[
		delete from
			tbl_mercenary_level_award
		where
			cs_uId = ?
	]]
}
DefineSql(StmtDef, StmtContainer)

local MercenaryLevelDB = CreateDbBox(...)

------------------------------------------------------------------------
local func = function(Subject, LevelTbl, Status)
	if Status == 1 and LevelTbl["�������"][Subject] then
		return true, LevelTbl["�������"][Subject].Arg
	end
end

local CheckSubjects = {
	--["����"]
	["��ս����"] = function(Param, LevelTbl, Status)
		if Status == 2 and LevelTbl["��ս����"].Arg then
			local QuestNames = LevelTbl["��ս����"].Arg
			if Param == QuestNames[1] or Param == QuestNames[2] or Param == QuestNames[3] then
				return true, 1
			end
		end
	end,
	
	["�����"] = function(Param, LevelTbl, Status)
		if Status == 1 and LevelTbl["�������"]["�����"] and Param == "�����" then
			return true, LevelTbl["�������"]["�����"].Arg
		end
	end,
	
	["����ֵ"] = function(Param, LevelTbl, Status)
		if Status == 1 and LevelTbl["�������"]["����ֵ"] then
			if Param > LevelTbl["�������"]["����ֵ"].Arg then
				Param = LevelTbl["�������"]["����ֵ"].Arg
			end
			return Param, LevelTbl["�������"]["����ֵ"].Arg
		end
	end,
	
	["Ӷ������"] = function(Param, LevelTbl, Status)
		if Status == 1 then
			if (Param == "����ػ�������" or Param == "����ػ�������") and LevelTbl["�������"]["����"] then
				return true, LevelTbl["�������"]["����"].Arg
			elseif LevelTbl["�������"]["Ӷ������"] then
				return true, LevelTbl["�������"]["Ӷ������"].Arg
			end
		end
	end,
	
	["��װ"] = function(Param, LevelTbl, Status)
		if Status == 2 and Subject == LevelTbl["��ս����"].Subject then
			return true, LevelTbl["��ս����"].Arg
		end
	end,
	
	["תְ"]		= func,
	["������"]	= func,
	["Ӷ������"]= func,
	["�����"]= func,
}

local func2 = function(LevelTbl, data)
	local Award = data["Award"]
	if LevelTbl[Award] then
		return true
	end
end

local CheckAwards = {
	["����"] = function(LevelTbl, data)
		local Award = data["Award"]
		if LevelTbl[Award] then
			return true
		end
	end,
	
	["��Ʒ"] = function(LevelTbl, data)
		local Award = data["Award"]
		local Arg = LevelTbl[Award].Arg
		if LevelTbl[Award] then
			local param = {}
			param["nType"]			= Arg[1]
			param["sName"] 			= Arg[2]
			param["nCount"]			= Arg[3]
			param["char_id"] 		= data["CharId"]
			param["createType"]	= event_type_tbl["��������"]
			local CharacterMediatorDB = RequireDbBox("CharacterMediatorDB")
			local res = CharacterMediatorDB.AddItem(param)
			if IsNumber(res) then
				CancelTran()
				return
			else
				return {Arg[1],Arg[2],Arg[3],res}
			end
		end
	end,
	
	["�ƺ�"] = function(LevelTbl, data)
		local Award = data["Award"]
		if LevelTbl[Award] and LevelTbl[Award].Arg then
			return true
		end
	end,
	
	["��������"] = func2,
	["�б���"] = func2,
	["���ŵȼ�"] = func2,
	--["����"] = func2,
	["��Ϊ"] = func2,
	
	["ȥ��CD"] = func2,
	["����"] = func2,
}

------------------------------------------------------------------------

local function GetMercenaryLevelAward(data)
	local res = StmtContainer._GetMercenaryLevelAward:ExecSql("s", data["CharId"])
	local n = res:GetRowNum()
	local tbl = {}
	if res and n>0 then
		for i=1,n do
			local award = res:GetData(i-1,0)
			tbl[award] = true
		end
	end
	return tbl
end

local function GetMercenaryLevelInfo(data)
	local CharId = data["CharId"]
	local res = StmtContainer._GetMercenaryLevelInfo:ExecSql("nsssnnnn", CharId)
	if res and res:GetRowNum()>0 then
		local tbl = {}
		local Status = res:GetData(0,0)
		tbl.Subject1 = res:GetData(0,1)
		tbl.Subject2 = res:GetData(0,2)
		tbl.Subject3 = res:GetData(0,3)
		tbl.Count1 = res:GetData(0,4)
		tbl.Count2 = res:GetData(0,5)
		tbl.Count3 = res:GetData(0,6)
		local Challenge = res:GetData(0,7)
		res = StmtContainer._GetMercenaryIntegral:ExecSql("n", CharId)
		local Integral = res:GetData(0,0)
		res = StmtContainer._GetPlayerLevel:ExecSql("n", CharId)
		local Level = res:GetData(0,0)
		local MercenaryLevel = res:GetData(0,1)
		return MercenaryLevel, Status, tbl, Challenge, Integral, Level
	end
	return false
end

function MercenaryLevelDB.GetMercenaryLevelInfo(data)
	return GetMercenaryLevelInfo(data)
end

local function CheckMercenaryLevel(data)
	local MercenaryLevel, Status, CountTbl, Challenge, Integral, Level = GetMercenaryLevelInfo(data)
	if not MercenaryLevel then
		return
	end
	
	local IsReach = true
	if MercenaryLevel ~= g_MercenaryLevelTbl.MaxLevel then
		local LevelTbl = g_MercenaryLevelTbl[MercenaryLevel]
		if Status == 1 then
			if (LevelTbl["�������"]["Ӷ������"] and Integral < LevelTbl["�������"]["Ӷ������"].Arg)
				or (LevelTbl["�������"]["����ȼ�"] and Level < LevelTbl["�������"]["����ȼ�"].Arg)
				or (CountTbl.Subject1 ~= "" and CountTbl.Count1 < LevelTbl["�������"][CountTbl.Subject1].Arg)
				or (CountTbl.Subject2 ~= "" and CountTbl.Count2 < LevelTbl["�������"][CountTbl.Subject2].Arg)
				or (CountTbl.Subject3 ~= "" and CountTbl.Count3 < LevelTbl["�������"][CountTbl.Subject3].Arg)
				then
					IsReach = false
			end
		elseif Status == 2 then
			local Subject = LevelTbl["��ս����"].Subject
			if Subject == "��ս����" then
				if Challenge < 1 then
					IsReach = false
				end
			elseif Subject == "����" then
				local pos = 0----------------------------------------------�������
				if pos > LevelTbl["��ս����"].Arg then
					IsReach = false
				end
			else
				if Challenge < LevelTbl["��ս����"].Arg then
					IsReach = false
				end
			end
		else
			IsReach = false
		end
		if Status < 3 and IsReach then
			StmtContainer._AddMercenaryLevelStatus:ExecSql("", 1, data["CharId"])
			Status = Status + 1
		end
		
	else
		IsReach = false
	end
	return {MercenaryLevel, Status, CountTbl, Challenge, Integral, Level}
end

function MercenaryLevelDB.CheckMercenaryLevel(data)
	return CheckMercenaryLevel(data)
end

local function GetCount(Subject, Result, Count)
	if Subject == "����ֵ" then
		local def = Result - Count
		return (def<0 and 0) or def
	else
		return 1
	end
end

local function AddMercenaryLevelCount(data)
	local CharId = data["CharId"]
	local Subject = data["Subject"]
	local Param = data["Param"]
	local MercenaryLevel, Status, CountTbl, Challenge, _, _ = GetMercenaryLevelInfo(data)
	if not MercenaryLevel or MercenaryLevel==g_MercenaryLevelTbl.MaxLevel then
		return
	end
	local LevelTbl = g_MercenaryLevelTbl[MercenaryLevel]
	
	Param = Param or Subject
	local result, max = CheckSubjects[Subject](Param, LevelTbl, Status)
	
	if result then
		local count1, count2, count3, chg = 0, 0, 0, 0
		if Status == 1 then
			if Subject == CountTbl.Subject1 and CountTbl.Count1<max then
				count1 = GetCount(Subject, result, CountTbl.Count1)
			elseif Subject == CountTbl.Subject2 and CountTbl.Count2<max then
				count2 = GetCount(Subject, result, CountTbl.Count2)
			elseif Subject == CountTbl.Subject3 and CountTbl.Count3<max then
				count3 = GetCount(Subject, result, CountTbl.Count3)
			end
		elseif Status == 2 then
			if Subject~="����" and Challenge<max then
				chg = 1
			elseif Subject=="����" and Challenge>max then
				--��������
			end
		end
		if not (count1==0 and count2==0 and count3==0 and chg==0) then
			StmtContainer._AddMercenaryLevelCount:ExecSql("", count1, count2, count3, chg, CharId)
			return CheckMercenaryLevel(data)
		end
	end
end

function MercenaryLevelDB.AddMercenaryLevelCount(data) 
	return AddMercenaryLevelCount(data)
end

function MercenaryLevelDB.SlowAddMercenaryLevelCount(CharId, Subject, Param)
	local data = {}
	data["CharId"] = CharId
	data["Subject"] = Subject
	data["Param"] = Param
	return AddMercenaryLevelCount(data)
end

local function DoMercenaryLevelUp(CharId, NewLevel, AddLevel, Defence)
	StmtContainer._MercenaryLevelUp:ExecSql("", AddLevel, CharId)
	StmtContainer._DeleteAllMercenaryLevelAward:ExecSql("", CharId)
	local ActivityCountDB = RequireDbBox("ActivityCountDB")
	ActivityCountDB.ClearCurCycJoinCount(CharId, "Ӷ���ճ�����")	--��Ӷ������ÿ������
	ActivityCountDB.ClearCurCycJoinCount(CharId, "Ӷ��ѵ���")	--��������ÿ������
	
	if NewLevel == g_MercenaryLevelTbl.MaxLevel then
		StmtContainer._MercenaryLevelUpInit:ExecSql("", "", "", "", CharId)
	else
		local Subject = {}
		local i = 1
		local j,k,l = 0,0,0
		for sub, _ in pairs(g_MercenaryLevelTbl[NewLevel]["�������"]) do
			if sub ~= "Ӷ������" and sub ~= "����ȼ�" then
				if sub=="������" then	j=i end
				if sub=="����ֵ" and Defence then	k=i	end
				if sub=="�����" then l=i	end
				Subject[i] = sub
				i = i+1
			end
		end
		StmtContainer._MercenaryLevelUpInit:ExecSql("", Subject[1] or "", Subject[2] or "", Subject[3] or "", CharId)
		
		local v = {0,0,0,0}
		local SpacialCount = ActivityCountDB.GetActivityHistoryTimes(CharId, "Ӷ��ѵ���")
		local LiveSkillBaseDB = RequireDbBox("LiveSkillBaseDB")
		local DefaultSkills = LiveSkillMgr:GetDefaultLearnedSkillInfo()
		local CountOfLiveskill = LiveSkillBaseDB.CountLiveskillHaveLearned(CharId)
		v[j] = SpacialCount	--���������⴦��
		v[k] = Defence or 0	--����ֵ���⴦��
		v[l] = ((CountOfLiveskill - #DefaultSkills)>0 and 1) or 0	--��������⴦��
		--v[4] = --��������
		StmtContainer._AddMercenaryLevelCount:ExecSql("", v[1],v[2],v[3],v[4], CharId)
	end
	return CheckMercenaryLevel( {["CharId"]=CharId} )
end

function MercenaryLevelDB.AddNewMercenaryLevel(data)
	local CharId = data["CharId"]
	local res = GetMercenaryLevelInfo(data)
	if not res then
		StmtContainer._AddNewMercenaryLevel:ExecSql("", CharId)
		return DoMercenaryLevelUp(CharId, 0, 0)
	end
end

function MercenaryLevelDB.MercenaryLevelUp(data)
	local CharId = data["CharId"]
	local MercenaryLevel, Status = GetMercenaryLevelInfo(data)
	if Status ~= 4 or MercenaryLevel == g_MercenaryLevelTbl.MaxLevel then
		return
	end
	
	local FinishAwards = GetMercenaryLevelAward(data)
	for award,_ in pairs(g_MercenaryLevelTbl[MercenaryLevel]["��Ȩ"]) do
		if not FinishAwards[award] then
			return
		end
	end
	return DoMercenaryLevelUp(CharId, MercenaryLevel+1, 1, data["Defence"])
end

function MercenaryLevelDB.GMAddMercenaryLevelUp(data)
	local CharId = data["CharId"]
	local ResultMercLev = data["ResultMercLev"]
	local MercenaryLevel = GetMercenaryLevelInfo(data)
	if not MercenaryLevel then
		return
	end
	local AddLevel = ResultMercLev - MercenaryLevel
	if AddLevel == 0 then
		return
	end
	return DoMercenaryLevelUp(CharId, ResultMercLev, AddLevel)
end

function MercenaryLevelDB.MercenaryLevelAppraise(data)
	local MercenaryLevel, Status = GetMercenaryLevelInfo(data)
	if MercenaryLevel == g_MercenaryLevelTbl.MaxLevel then
		return
	end
	if Status == 3 then
		StmtContainer._AddMercenaryLevelStatus:ExecSql("", 1, data["CharId"])
		return CheckMercenaryLevel(data)
	elseif Status == 4 then
		return -1
	end
end

function MercenaryLevelDB.GetMercenaryLevelAward(data)
	local MercenaryLevel, Status = GetMercenaryLevelInfo(data)
	if MercenaryLevel == g_MercenaryLevelTbl.MaxLevel then
		return {}
	end
	if data["Type"] then
		if Status == 4 then
			return GetMercenaryLevelAward(data)
		end
	else
		return GetMercenaryLevelAward(data)
	end
end

local function SetMercenaryLevelAward(data)
	local MercenaryLevel, Status = GetMercenaryLevelInfo(data)
	if (not MercenaryLevel) or Status~=4 or MercenaryLevel==g_MercenaryLevelTbl.MaxLevel then
		return
	end
	
	--ѧϰ�سǼ������⴦��
	if data["SkillName"]=="�������ݾư�" or data["SkillName"]=="����" then
		for sub,t in pairs(g_MercenaryLevelTbl[MercenaryLevel]["��Ȩ"]) do
			if data["SkillName"] == t.Arg then
				data["Award"] = sub
				break
			end
		end
	end
	if not data["Award"] then
		return false
	end
	
	local CharId = data["CharId"]
	local Award = data["Award"]
	local result = nil
	if string.sub(Award, 1, 4)=="����" or string.sub(Award, 1, 4)=="��Ʒ" or string.sub(Award, 1, 4)=="��Ϊ" then
		local MultiAward = string.sub(Award, 1, 4)
		result = CheckAwards[MultiAward](g_MercenaryLevelTbl[MercenaryLevel]["��Ȩ"], data)
	else
		result = CheckAwards[Award](g_MercenaryLevelTbl[MercenaryLevel]["��Ȩ"], data)
	end
	if result then
		local tbl = GetMercenaryLevelAward(data)
		if not tbl[Award] then
			StmtContainer._AddMercenaryLevelAward:ExecSql("", CharId, Award)
			if data["SkillName"]=="�������ݾư�" or data["SkillName"]=="����" then
				result = Award
			end
			return result
		end
	end
end

function MercenaryLevelDB.SetMercenaryLevelAward(data)
	return SetMercenaryLevelAward(data)
end

function MercenaryLevelDB.SlowSetMercenaryLevelAward(CharId, SkillName)
	local data = {}
	data["CharId"] = CharId
	data["SkillName"] = SkillName
	return SetMercenaryLevelAward(data)
end

function MercenaryLevelDB.InitMercenaryLevel(CharId)
	local data = {}
	data["CharId"] = CharId
	local MLRes = CheckMercenaryLevel(data)
	local Awards = GetMercenaryLevelAward(data)
	return MLRes, Awards
end

return MercenaryLevelDB
