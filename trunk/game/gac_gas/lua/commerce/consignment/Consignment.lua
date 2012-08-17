lan_load "commerce/Lan_CSMEquipSoul_Common"
cfg_load "commerce/CSMEquipSoul_Common"

CConsignment = class ()

--����������:
CConsignment.AttrNameMapIndexTbl = {}
CConsignment.AttrNameMapIndexTbl["���ֽ�"] = 1
CConsignment.AttrNameMapIndexTbl["���ִ�"] = 2
CConsignment.AttrNameMapIndexTbl["���ָ�"] = 3
CConsignment.AttrNameMapIndexTbl["���ֵ�"] = 4
CConsignment.AttrNameMapIndexTbl["������Ȼ��"] = 5
CConsignment.AttrNameMapIndexTbl["���ְ�����"] = 5
CConsignment.AttrNameMapIndexTbl["�����ƻ���"] = 5
CConsignment.AttrNameMapIndexTbl["������"] = 5
CConsignment.AttrNameMapIndexTbl["˫�ֽ�"] = 6
CConsignment.AttrNameMapIndexTbl["˫�ָ�"] = 7
CConsignment.AttrNameMapIndexTbl["˫�ִ�"] = 8
CConsignment.AttrNameMapIndexTbl["˫����Ȼ��"] = 9
CConsignment.AttrNameMapIndexTbl["˫�ְ�����"] = 9
CConsignment.AttrNameMapIndexTbl["˫���ƻ���"] = 9
CConsignment.AttrNameMapIndexTbl["˫����"] = 9

CConsignment.AttrNameMapIndexTbl["����"] = 10
CConsignment.AttrNameMapIndexTbl["����"] = 11
CConsignment.AttrNameMapIndexTbl["ͷ��"] = 12
CConsignment.AttrNameMapIndexTbl["�·�"] = 13
CConsignment.AttrNameMapIndexTbl["����"] = 14
CConsignment.AttrNameMapIndexTbl["Ь��"] = 15
CConsignment.AttrNameMapIndexTbl["�粿"] = 16
CConsignment.AttrNameMapIndexTbl["����"] = 17
CConsignment.AttrNameMapIndexTbl["����"] = 18

CConsignment.AttrNameMapIndexTbl["����"] = 19
CConsignment.AttrNameMapIndexTbl["����"] = 20

CConsignment.AttrNameMapIndexTbl["������ʯ"] = 21
CConsignment.AttrNameMapIndexTbl["���з�ʯ"] = 22
CConsignment.AttrNameMapIndexTbl["������ʯ"] = 23
CConsignment.AttrNameMapIndexTbl["���Է�ʯ"] = 24
CConsignment.AttrNameMapIndexTbl["���޷�ʯ"] = 25
CConsignment.AttrNameMapIndexTbl["������ʯ"] = 26

CConsignment.AttrNameMapIndexTbl["ǿ��ʯ"] = 27

CConsignment.AttrNameMapIndexTbl["ҩˮ"] = 29
CConsignment.AttrNameMapIndexTbl["��սҩˮ"] = 29
CConsignment.AttrNameMapIndexTbl["ҩ��"] = 29
CConsignment.AttrNameMapIndexTbl["ʳ��"] = 30
CConsignment.AttrNameMapIndexTbl["���;���"] = 31
CConsignment.AttrNameMapIndexTbl["�����ٻ���"] = 31
CConsignment.AttrNameMapIndexTbl["����ʯ"] = 31
CConsignment.AttrNameMapIndexTbl["�౶����"] = 31
CConsignment.AttrNameMapIndexTbl["ħ����Ʒ"] = 31

CConsignment.AttrNameMapIndexTbl["�����ҩ����"] = 32
CConsignment.AttrNameMapIndexTbl["����"] = 33 
CConsignment.AttrNameMapIndexTbl["����"] = 34    

AddCheckLeakFilterObj(CConsignment.AttrNameMapIndexTbl)

local EquipQualityTbl = {}
EquipQualityTbl["��װ"] = 3
EquipQualityTbl["��װ"] = 4
EquipQualityTbl["��װ"] = 5

function CConsignment.GetEquipQuality(IntensifyPhase, DynInfo, ItemInfo)
	local quality = 0
	local suitName = DynInfo.SuitName
	if IntensifyPhase ~= nil  then
	    if IntensifyPhase >= 3 then
			if suitName == "" then
				quality = EquipQualityTbl["��װ"]
			else
			    local equipPart = GetIntenEquipPart(DynInfo.m_nBigID, ItemInfo)
				local number = CheckSuitCount(ItemInfo("SoulRoot"),DynInfo.SuitName, equipPart)
				if number == 6 or number == 2  then
					quality = EquipQualityTbl["��װ"]
				elseif number == 4 or number == 3 or number == 8 then
					quality = EquipQualityTbl["��װ"]
				end
			end
		elseif IntensifyPhase >= 1 then
			quality = EquipQualityTbl["��װ"]
		else
			quality =  ItemInfo("Quality")
		end
	else
		quality =  ItemInfo("Quality")
	end 
	return quality
end


local EquipSoulRootType = {}
local EquipAdvanceSoulRootType = {}

g_AdvancedSoul2DisplayRootTbl = {}
g_Index2DisplayRootTbl = {}


local AdvanceSoulCount = 0

local function ReadCSMEquipSoulInfo()
    local advanceSoulIndex = 1
    local intenSoulIndex = 1
    local keys = Lan_CSMEquipSoul_Common:GetKeys()
    for i, v in pairs (keys) do
        local key = v
        local soulName = Lan_CSMEquipSoul_Common(key, "SoulRoot")
        local soulRoot = CSMEquipSoul_Common(i,"SoulRoot")
        if CSMEquipSoul_Common(i,"SoulType") == 1 then
            EquipAdvanceSoulRootType[soulName] = advanceSoulIndex
            advanceSoulIndex = advanceSoulIndex + 1
            AdvanceSoulCount = AdvanceSoulCount + 1
        elseif CSMEquipSoul_Common(i,"SoulType") == 2 then
            EquipSoulRootType[soulName] = intenSoulIndex
            intenSoulIndex = intenSoulIndex + 1      
        end
        g_AdvancedSoul2DisplayRootTbl[soulRoot] =  soulName
        g_Index2DisplayRootTbl[v] =  soulName

    end
end
ReadCSMEquipSoulInfo()

function CConsignment.GetEquipAdvanceSoulTbl()
    return EquipAdvanceSoulRootType
end

function CConsignment.GetEquipIntenSoulTbl()
    return EquipSoulRootType
end

function CConsignment.GetEquipAdvanceSoul(advanceSoulName) 
    return EquipAdvanceSoulRootType[advanceSoulName] or 0
end

function CConsignment.GetEquipIntenSoul(intenSoulName)
    return EquipSoulRootType[intenSoulName] or 0
end

function CConsignment.GetAdvanceSoulCount()
    return AdvanceSoulCount
end