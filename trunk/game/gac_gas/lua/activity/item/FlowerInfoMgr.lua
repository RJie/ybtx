gac_gas_require "activity/item/LiveSkillParamsInc"
lan_load "liveskill/Lan_CultivateFlowers_Common"
gac_gas_require "activity/item/FlowerInfoMgrInc"

function CFlowerInfoMgr:Init()

	local function FlowerGetitemTbl(str)
		local GetTbl = loadstring("return {"..str.."}")()
		for i, tbl in pairs(GetTbl) do
			if tbl ~= nil and tbl[5] ~= nil and tbl[5] ~= "" then
				local funStr = "local function GetProbability(Rate, Level, Lucky)  return (" .. tbl[5] .. ") end return GetProbability"
				tbl[5] = loadstring(funStr)()
			end
		end
		return GetTbl
	end
	self.m_FlowerInfo = {}
	AddCheckLeakFilterObj(self.m_FlowerInfo)
	
	local FlowerKeys = CultivateFlowers_Common:GetKeys()
	for _, FlowerName in pairs(FlowerKeys) do
		local FlowerInfo = {}
		local ScriptKeys = CultivateFlowers_Common:GetKeys(FlowerName)
		for _, ScriptName in pairs(ScriptKeys) do
			FlowerInfo[ScriptName] = {}
			if ScriptName == "�������" or ScriptName == "�������" then
				for rank = 1, 10 do
					local Arg = CultivateFlowers_Common(FlowerName, ScriptName, "Rank"..rank)
					FlowerInfo[ScriptName][rank] = FlowerGetitemTbl(Arg)
				end
			elseif ScriptName == "��ή�ջ�" then
				local Arg = CultivateFlowers_Common(FlowerName, ScriptName, "Rank1")
				FlowerInfo[ScriptName] = FlowerGetitemTbl(Arg)
			elseif ScriptName == "����ʱ��" then
				local PerishTime = 0
				for rank = 1, 10 do
					local Arg = CultivateFlowers_Common(FlowerName, ScriptName, "Rank"..rank)
					FlowerInfo[ScriptName][rank] = Arg
					PerishTime = PerishTime + Arg
				end
				FlowerInfo["������ʱ��"] = PerishTime
			elseif ScriptName == "������Ч" then
				for rank = 1, 10 do
					local Arg = CultivateFlowers_Common(FlowerName, ScriptName, "Rank"..rank)
					FlowerInfo[ScriptName][rank] = loadstring("return" .. Arg)()
				end
			elseif ScriptName == "�ջ����" or ScriptName == "�¼�ʱ��" then
				FlowerInfo[ScriptName] = CultivateFlowers_Common(FlowerName, ScriptName, "Rank1")
			elseif ScriptName == "��ʾͼ��" then
				for rank = 1, 10 do
					FlowerInfo[ScriptName][rank] = CultivateFlowers_Common(FlowerName, ScriptName, "Rank"..rank)
				end
			end
		end
		self.m_FlowerInfo[FlowerName] = FlowerInfo
	end
end

g_FlowerInfoMgr = CFlowerInfoMgr:new()
g_FlowerInfoMgr:Init()

function GetFlowerDispalyName(name)
	return Lan_CultivateFlowers_Common(MemH64(name),"DisplayName")
end

function CFlowerInfoMgr:GetFlowerInfo(FlowerName, ScriptName, rank)
	if ScriptName then
		if rank then
			return self.m_FlowerInfo[FlowerName][ScriptName][rank]
		end
		return self.m_FlowerInfo[FlowerName][ScriptName]
	end
	return self.m_FlowerInfo[FlowerName]
end