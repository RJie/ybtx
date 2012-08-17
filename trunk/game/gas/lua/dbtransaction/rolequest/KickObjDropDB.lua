gac_gas_require "activity/int_obj/LoadIntObjActionArg"
cfg_load "int_obj/ObjDropItemTeam_Server"
cfg_load "int_obj/ObjRandomDropItem_Server"
gac_gas_require "activity/quest/QuestMgrInc"

local os = os
local QuestState = {
	init	= 1,
	failure	= 2,
	finish	= 3
}
local g_ObjDropNum = g_ObjDropNum
local g_ObjTeamNum = g_ObjTeamNum
local g_ItemInfoMgr = CItemInfoMgr:new()
local ObjRandomDropItem_Server = ObjRandomDropItem_Server
local ObjDropItemTeam_Server = ObjDropItemTeam_Server
local g_QuestDropItemMgr = g_QuestDropItemMgr
local EClass = EClass
local ECamp = ECamp
local GetCfgTransformValue = GetCfgTransformValue

local KickObjDropDB = CreateDbBox(...)

local function GetDropObjTbl(PlayerId,TeamIndex)
	local AllRateSum=0
	local ClassNameTbl = {
		[EClass.eCL_Warrior]				= "��",
		[EClass.eCL_MagicWarrior]		= "ħ��",
		[EClass.eCL_Paladin]				= "��ʿ",
		[EClass.eCL_NatureElf]			= "��ʦ",
		[EClass.eCL_EvilElf]				= "аħ",
		[EClass.eCL_Priest]					= "��ʦ",
		[EClass.eCL_DwarfPaladin]		= "����",
		[EClass.eCL_ElfHunter]			= "���鹭",
		[EClass.eCL_OrcWarrior]			= "��ս",
	}
	local CampNameTbl = {
		[ECamp.eCamp_AmyEmpire]			= "����",
		[ECamp.eCamp_WestEmpire]		= "��ʥ",
		[ECamp.eCamp_DevilIsland]		= "��˹",
	}
	if string.find(TeamIndex, "#class#") then	
		local FightSkillDB = RequireDbBox("FightSkillDB")
		local ClassID = FightSkillDB.Dbs_SelectPlayerClass(PlayerId)
		TeamIndex = string.gsub(TeamIndex, "#class#", ClassNameTbl[ClassID])
	end
	if string.find(TeamIndex, "#camp#") then
		local CharacterMediatorDB = RequireDbBox("CharacterMediatorDB")
		local Camp = CharacterMediatorDB.GetCamp(PlayerId)
		TeamIndex = string.gsub(TeamIndex, "#camp#", CampNameTbl[Camp])
	end
	local ObjDropItemTeam=ObjDropItemTeam_Server(TeamIndex)
	if ObjDropItemTeam==nil then
		return false
	end
	for i=1,g_ObjTeamNum do
		local DropRate="Rate"..i
		local Rate = ObjDropItemTeam(DropRate)
		if Rate == "" or Rate == nil then
			Rate = 0
		else
			Rate = tonumber(Rate)
		end
		AllRateSum = AllRateSum + Rate
	end
	local RandomItemRate=math.random(0,AllRateSum)
	local RateIndex=0
	
	local droprate1=ObjDropItemTeam("Rate1")
	if droprate1 == "" or droprate1 == nil then
		droprate1 = 0
	else
		droprate1 = tonumber(droprate1)
	end
	if RandomItemRate>=0 and RandomItemRate<=droprate1 then
		RateIndex=1
	else
		local droprate1 = 0
		local droprate2 = ObjDropItemTeam("Rate1")
		if droprate2 == nil or droprate2 == "" then
			droprate2 = 0 
		else
			droprate2 = tonumber(droprate2)
		end
		for i=2,g_ObjTeamNum do	
			
			local AddRate2=ObjDropItemTeam("Rate"..i)
			if AddRate2 == nil or AddRate2 == "" then
				AddRate2 = 0 
			else
				AddRate2 = tonumber(AddRate2)
			end
			
			local AddRate1=ObjDropItemTeam("Rate"..(i-1))
			if AddRate1 == nil or AddRate1 == "" then
				AddRate1 = 0 
			else
				AddRate1 = tonumber(AddRate1)
			end
			
			droprate2 = AddRate2 + droprate2
			droprate1 = AddRate1 + droprate1
			
			if RandomItemRate>droprate1 and RandomItemRate<=droprate2 then
				RateIndex=i
				break
			end
		end
	end
	
	if RateIndex>0 and RateIndex<=g_ObjTeamNum then
		local DropType=ObjDropItemTeam("ItemType"..RateIndex)
		local DropIndex="ItemName"..RateIndex
		local DropName=ObjDropItemTeam(DropIndex)
		local DropNum=math.random(ObjDropItemTeam("MinNum"),ObjDropItemTeam("MaxNum"))
		if DropType == "Obj" then
			local param = {}
			param["DropName"] = DropName
			param["DropNum"] = DropNum
			return param
		end
	end
	return false
end

local function KickObjDrop(data)
	local PlayerId = data["nCharId"]
	local ObjName = data["ObjName"]
	local MultipleNum = data["MultipleNum"]
	--����������Ʒ
	local DropObjTbl = {}
	
	if g_QuestDropItemMgr[ObjName] then
		for questname , p in pairs(g_QuestDropItemMgr[ObjName]) do
			for i = 1, table.getn(p) do
				local droptype = p[i].Type
				local dropname = p[i].Object
				local DropRate = p[i].Rate
				local randomrate = math.random(0,10000)
				local RoleQuestDB = RequireDbBox("RoleQuestDB")
				local state = RoleQuestDB.GetQuestState({PlayerId, questname})
				if state == QuestState.init and (DropRate*10000) >= randomrate then
					local checkres = RoleQuestDB.CheckNeedItemNum(PlayerId, droptype, dropname, true)
					if checkres[1] then
						local NeedNum = checkres[2]
						if NeedNum ~= 0 and NeedNum < MultipleNum then
							table.insert(DropObjTbl,{["DropName"] = dropname,["DropNum"] = NeedNum,["QuestDrop"] = true})
						else
							table.insert(DropObjTbl,{["DropName"] = dropname,["DropNum"] = MultipleNum,["QuestDrop"] = true})
						end
					end
				end
			end
		end
	end
	
	local DropObjInfo = ObjRandomDropItem_Server(ObjName)
	local CharacterMediatorDB = RequireDbBox("CharacterMediatorDB")
	local PlayerLevel = CharacterMediatorDB.GetPlayerLevel(PlayerId)
	if DropObjInfo then
		for i=1,g_ObjDropNum do --ѭ����С�����߻���
			--local dropLevel = DropObjInfo("DropTeamLevel"..i)
			local dropLevel = GetCfgTransformValue(false, "ObjRandomDropItem_Server", ObjName, "DropTeamLevel"..i)
			if dropLevel == nil or dropLevel == "" or (dropLevel[1] <= PlayerLevel and dropLevel[2] >= PlayerLevel) then
				local TeamRate="TeamRate"..i  --TeamRate1��ֵ��ʾObjRandomDropItem_Server���в���������Ʒ�ļ���
				local GetItemTeam="GetItemTeam"..i  --GetItemTeam1��ֵ��ʾ���Index����ӦObjDropItemTeam_Server��Index
				local Rate=DropObjInfo(TeamRate)
				if Rate~="" and Rate~=0 and Rate ~= nil then
					if math.random(0,10000)<=(Rate*10000) then
						local TeamIndex=DropObjInfo(GetItemTeam) --TeamIndex��ӦObjDropItemTeam_Server��Index
						if TeamIndex~="" and TeamIndex~=0 then
							local result = GetDropObjTbl(PlayerId,TeamIndex)
							if result ~= false then
								table.insert(DropObjTbl,result)
							end
						end
					end
				end
			end
		end
	end
	return DropObjTbl
end

function KickObjDropDB.KickObjDrop(data)
	return KickObjDrop(data)
end

return KickObjDropDB