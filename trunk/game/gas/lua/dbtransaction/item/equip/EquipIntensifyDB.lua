cfg_load  "equip/intensify/EquipSoulAttr_Common"
cfg_load	"equip/intensify/SoulEvolving_Common"
cfg_load	"equip/intensify/EquipZValue_Common"
cfg_load	"equip/suit/ArmyWarSuit_Common"
cfg_load	"equip/suit/MagicActSuit_Common"
cfg_load	"equip/suit/GodWartSuit_Common"
cfg_load	"equip/suit/ArmyActSuit_Common"
cfg_load	"equip/suit/EquipSuit_Common"
cfg_load "item/Equip_Weapon_Common"
cfg_load "equip/intensify/AttrRateValue_Server"
cfg_load "equip/intensify/IntenPhaseMapAttrValue_Server"
cfg_load "equip/intensify/IntensifyStoneMapAddAttr_Common"
cfg_load "equip/intensify/SuitPartMapTalentOrSkill_Common"
cfg_load "equip/StaticWeaponType_Common"
cfg_load "equip/suit/EquipSuitOutScale_Server"
gac_gas_require "item/Equip/EquipCommonFunc"
gac_gas_require "player/PlayerMgr"
cfg_load "item/EquipIntensifyBackItem_Common"

local IsEquipSuitAdaptedClass = IsEquipSuitAdaptedClass
local GetWeaponAdaptedClass = GetWeaponAdaptedClass
local g_GetPlayerClassNameByID = g_GetPlayerClassNameByID
local GetEquipHandType = GetEquipHandType
local GetIntensifyNeededSoul = GetIntensifyNeededSoul
local g_ItemInfoMgr				=	CItemInfoMgr:new()
local EquipMgrDB				=	RequireDbBox("EquipMgrDB")
local EquipSoulAttr_Common		=	EquipSoulAttr_Common
local SoulEvolving_Common		=	SoulEvolving_Common
local EquipZValue_Common		=	EquipZValue_Common
local ArmyWarSuit_Common		=	ArmyWarSuit_Common
local MagicActSuit_Common		=	MagicActSuit_Common
local GodWartSuit_Common		=	GodWartSuit_Common
local ArmyActSuit_Common		=	ArmyActSuit_Common
local EquipSuit_Common			=	EquipSuit_Common
local loadstring				=	loadstring
local Equip_Weapon_Common		=	Equip_Weapon_Common
local IntensifyStoneMapAddAttr_Common          =   IntensifyStoneMapAddAttr_Common
local io						=	io
local os						=	os
local AttrRateValue_Server      =   AttrRateValue_Server
local IntenPhaseMapAttrValue_Server =   IntenPhaseMapAttrValue_Server
local SuitPartMapTalentOrSkill_Common = SuitPartMapTalentOrSkill_Common
local StaticWeaponType_Common = StaticWeaponType_Common
local EquipSuitOutScale_Server = EquipSuitOutScale_Server
local GetEquipLevelType = GetEquipLevelType
local LogErr = LogErr
local event_type_tbl = event_type_tbl
local EquipIntensifyBackItem_Common = EquipIntensifyBackItem_Common
local EquipIntensifyDB 			=	CreateDbBox(...)

local PearlSoulRoot ={}
PearlSoulRoot[1] = "��ս"
PearlSoulRoot[2] = "����"
PearlSoulRoot[3] = "��ħ"
PearlSoulRoot[4] = "ս��"
PearlSoulRoot[5] = "ͨ��"

--����װ������ʱ���ܵ����������Ǵ������ܹ������ѡ������
local OutputAttrProbability = 5 

-----------------------------------------------------------------------
local SoulEvolvingPhase={}
SoulEvolvingPhase[1] = 1
SoulEvolvingPhase[2] = 2
SoulEvolvingPhase[3] = 3
SoulEvolvingPhase[4] = 4
------------------------------------------------------------------------

local Weapon 			= 	{}
local Armor				=	{}
local Shield			=	{}
local Ring				=	{}
local EquipMgr			=	{}
local tblEquipType			=	{
["Weapon"]	=	5,
["Armor"]	=	6,
["Shield"]	=	7,
["Ring"]	=	8,
["Jewelry"]	=	9
}

------------------------------------------------------------------------------------
local StmtDef = {
	"_SelectEquipIntensifyInfo",
	[[ select is_uId,iei_uIntensifySoulNum,iei_uPreAddAttr1,iei_uPreAddAttrValue1,iei_uPreAddAttr2,iei_uPreAddAttrValue2, 
		iei_uAddAttr1,iei_uAddAttrValue1,iei_uAddAttr2,iei_uAddAttrValue2,iei_uIntensifyPhase,iei_uEuqipSuitType,iei_sSuitName,
		iei_uIntensifyBackState,iei_uIntensifyTimes,iei_uIntensifyBackTimes,iei_uIntenTalentIndex
		from tbl_item_equip_intensify where is_uId = ?]] 
}
DefineSql(StmtDef, EquipMgr)

--@brief ��ѯװ��ǿ����Ϣ
function EquipMgrDB.SelectEquipIntensifyInfo(equipId)
	local res = EquipMgr._SelectEquipIntensifyInfo:ExecStat(equipId)
	return res
end
------------------------------------------------------------------------------------
local StmtDef = {
	"_SelectEquipIntensifyAddAttrInfo",
	[[ select is_uId,iei_sAddAttr4,iei_uAddAttr4Value,iei_sAddAttr5,iei_uAddAttr5Value,iei_sAddAttr6, 
		iei_uAddAttr6Value,iei_sAddAttr7,iei_uAddAttr7Value,iei_sAddAttr8,iei_uAddAttr8Value,iei_sAddAttr9,iei_uAddAttr9Value
		from tbl_item_equip_intensifyAddAttr where is_uId = ?]] 
}
DefineSql(StmtDef, EquipMgr)

--@brief ��ѯװ��4-9�׶�ǿ����Ϣ
function EquipMgrDB.SelectEquipIntensifyAddAttrInfo(equipId)
	local res = EquipMgr._SelectEquipIntensifyAddAttrInfo:ExecStat(equipId)
	return res
end
---------------------------װ��ǿ����������ñ�����-----------------------------------------------
--����װ�������ԣ��õ�װ��ǿ��ʱ�ó��ĸ���������Ҫ���ϵı���ֵ
--������װ���ȼ����ͣ�1��ʾ1~40����2��ʾ41~150����
--����ֵ��װ��ǿ��ʱ����������Ҫ���ϵı���ֵ
local function GetSoulEvlovingAttrRate(levelType, equipPart, soulRoot)
	local addAttrRate = nil
	local addAttrName = nil
	local addAttrInfoTbl = {}
	--����EquipSoulAttr_Common���ñ�õ�װ��ǿ��һ�׶εõ���������1����
	local levelTypeStr = tostring(levelType)
	local defaultKeys = EquipSoulAttr_Common:GetKeys(levelTypeStr, soulRoot, equipPart)
	local tblLen = 	 # defaultKeys
	local randomNo = math.random(1, tblLen)
	if tblLen ~= 0 then	
	    local soulAttrRate = EquipSoulAttr_Common(levelTypeStr, soulRoot, equipPart, tostring(randomNo), "SoulAttrRate")
	    local soulAttr = EquipSoulAttr_Common(levelTypeStr, soulRoot, equipPart, tostring(randomNo), "SoulAttr")
		return soulAttrRate, soulAttr
	end
	return nil, nil 
end

--����װ���ȼ��ͻ�����Ľ׶εõ���Ӧ��Zֵ
local function GetEquipZValueByLevel(EquipLevel, EvlovingPhase)
	if EvlovingPhase ==  1 then
		local soulValue =  EquipZValue_Common(EquipLevel, "Z1")
	    return soulValue
	
	elseif EvlovingPhase ==  2 then
		local soulValue = EquipZValue_Common(EquipLevel, "Z2")
		return soulValue
	end
end

--���ظ���װ���ȼ��õ���zֵ�����װ���ĸ�������ֵ
--�������������������װ����������ֵ�Ĺ�ʽ�������ñ��ȡ�ģ�
--����ֵ���������װ���ĸ�������ֵ�ĺ���
local function GetAddAttr1ValuefuncPhase1(str)
	local beginf = "return (function (Z) \n local X \n "
	local endf	 = "\n return X end)"	
	local func = beginf .. " " .. str .. " " .. endf
	return loadstring(func)()
end

--���ظ���װ���ȼ��õ���zֵ�����װ���ĸ�������ֵ
--�������������������װ����������ֵ�Ĺ�ʽ�������ñ��ȡ�ģ�
--����ֵ���������װ���ĸ�������ֵ�ĺ���
local function GetAddAttr1ValuefuncPhase2(str)
	local beginf = "return (function (X, Y)  \n "
	local endf	 = "\n return X,Y end)"	
	local func = beginf .. " " .. str .. " " .. endf
	return loadstring(func)()
end

--��ȡǿ������1��2ֵ�ļ��㹫ʽ���洢�ڱ���
local SoulEvolvingInfoTbl = {}

--װ��ǿ����һ�׶Σ�������һ���������ԣ������Ӧ����ֵ
--������װ����λ��װ���Ļ�����ԡ�װ���ȼ�, �ȼ����ͣ�1��2;1~40����1��41~150����2��
local function IntensifyEuqipPhaseOne(equipPart, soulRoot, equipLevel, levelType)
--�õ�ǿ��װ��ʱ����������Ҫ���ϵı���ֵ��һ�׶θ�����������
	local addAttrRate, addAttrName = GetSoulEvlovingAttrRate(levelType, equipPart, soulRoot)
	local addAttr1Value = GetEquipZValueByLevel(equipLevel, SoulEvolvingPhase[1])
	local levelTypeStr = tostring(levelType)
	local keysTbl = SoulEvolving_Common:GetKeys(levelTypeStr, soulRoot, addAttrName)
	local attr2Name = keysTbl[1]
	local str = SoulEvolving_Common(levelTypeStr, soulRoot, addAttrName, attr2Name,"EvolvingStep1")
	if SoulEvolvingInfoTbl[str] == nil then
	    local  func = GetAddAttr1ValuefuncPhase1(str)
	    SoulEvolvingInfoTbl[str] = func
	end
	local method = SoulEvolvingInfoTbl[str]
	addAttr1Value = tonumber(string.format("%.0f",method(addAttr1Value)))
	addAttr1Value = addAttr1Value * tonumber(addAttrRate)
	return addAttrName, addAttr1Value
end



--װ��ǿ���ڶ��׶Σ��������ڶ����������ԣ��Լ���������һ���������Զ���Ӧ����ֵ
--������ǿ��һ�׶β����ĸ������ԣ�װ���ȼ����ͣ�1��1~40����2��41~150����, װ���ȼ���װ����λ��װ�����
--����ֵ��װ��ǿ�����׶β����ĸ������ԣ���������һ������ֵ���������Զ�������ֵ
local function IntensifyEuqipPhaseTwo( addAttr1Name,  equipLevelType, equipLevel, equipPart, soulRoot )
	local addAttr2InfoTbl = {}
	local levelTypeStr = tostring(equipLevelType)
	local keysTbl = SoulEvolving_Common:GetKeys(levelTypeStr, soulRoot, addAttr1Name)
	if # keysTbl == 0 then  -- ��if��Ĵ�����û�а취�˲żӵ��ݴ��߻�����װ����������
        if  soulRoot == "ս��" then
            keysTbl = SoulEvolving_Common:GetKeys(levelTypeStr, "��ħ", addAttr1Name)
            soulRoot = "��ħ"
	    elseif soulRoot == "��ħ" then
	        keysTbl = SoulEvolving_Common:GetKeys(levelTypeStr, "ս��", addAttr1Name)
	        soulRoot = "ս��"
	    end
	end
	local randomNum = math.random(# keysTbl)
	local addAttr2Name = keysTbl[randomNum]
	
	local addAttrRateArithmetic = SoulEvolving_Common(levelTypeStr, soulRoot, addAttr1Name, addAttr2Name, "EvolvingStep2")
	local z2Value = GetEquipZValueByLevel(equipLevel, SoulEvolvingPhase[2])
	local x2 = math.ceil(z2Value/4 * 3) 
	local y2 = z2Value - x2
	
    if SoulEvolvingInfoTbl[addAttrRateArithmetic] == nil then
	    local  func = GetAddAttr1ValuefuncPhase2(addAttrRateArithmetic)
	    SoulEvolvingInfoTbl[addAttrRateArithmetic] = func
	end
	local  method = SoulEvolvingInfoTbl[addAttrRateArithmetic]
	local addAttrRate = GetSoulEvlovingAttrRate(equipLevelType, equipPart, soulRoot)
	x2, y2  = method(x2, y2)
	if x2 < 1 then
		x2, y2  = method(0, z2Value)
	elseif y2 < 1 then
		x2, y2  = method(z2Value, 0)
	end
	x2, y2  = tonumber(string.format("%.0f", x2))* tonumber(addAttrRate), tonumber(string.format("%.0f",y2))*tonumber(addAttrRate)
	return addAttr2Name, x2, y2
end

------------------װ��ǿ���Ľ׶Σ��������ʺ���װϵ������װ�����������Ϣ---------------

--�ó�װ��ǿ���Ľ׶Σ���װ���ͱ���ֵ��2���ס�3���ס�4���ס�6���ס�8���ס��ޣ�
local function GetScaleForthPhase(suitCfgTbl, equipCurLevel, intensifyAddAttr1, intensifyAddAttr2, equipPartStr, defaultKey, equipAdaptedClass)
	local suitQuotiety, suitType		--��װϵ������װ����
	local randomNo = math.random(1, 100)
	local randomBaseValue = 0
	local suitTypeStr
	local randomScaleKeys = EquipSuitOutScale_Server:GetKeys()
	for i, v in pairs(randomScaleKeys) do
	    suitTypeStr = v
	    local suitScale = EquipSuitOutScale_Server(suitTypeStr, "SuitScale")
	    if randomNo > randomBaseValue and 
			randomNo <= suitScale + randomBaseValue then
				suitQuotiety = EquipSuitOutScale_Server(suitTypeStr, "SuitQuotiety")
				break
		end
		randomBaseValue = randomBaseValue + suitScale
	end
    if suitTypeStr == "None" or suitTypeStr == nil then	--�����������װ���������Ϊ1.5 ����ǲ߻�����
		suitQuotiety =EquipSuitOutScale_Server("None", "SuitQuotiety")
		return suitQuotiety, ""
	end
	
	local suitName = suitCfgTbl(tostring(equipCurLevel), intensifyAddAttr1, intensifyAddAttr2, equipPartStr, tostring(defaultKey), suitTypeStr)

	if suitName == "" or suitName == nil then
        suitQuotiety = EquipSuitOutScale_Server("None","SuitQuotiety")
		return suitQuotiety,  ""
	end
    
    if equipAdaptedClass ~=nil then -- Ҫ�������ְҵ��װ������Լ���ְҵ���
         local needPartsCountKeys = EquipSuit_Common:GetKeys(suitName)
         for i,v in pairs (needPartsCountKeys) do
            local needPartsCount = v
            if tonumber(needPartsCount) == nil then
                if equipAdaptedClass[needPartsCount] == nil then
                    suitQuotiety =EquipSuitOutScale_Server("None", "SuitQuotiety")
                    return suitQuotiety, ""
                end
            end
         end
         if IsEquipSuitAdaptedClass(suitName, equipAdaptedClass) == false then
            suitQuotiety =EquipSuitOutScale_Server("None", "SuitQuotiety")
            return suitQuotiety, ""
         end
    end
	return suitQuotiety, suitName
end

--װ��ǿ�����Ľ׶Σ�������װ��
--������װ���ȼ����ͣ�1��ʾ1~40����2��ʾ41~150������������ԡ�װ����λ����װ���ͣ�0��ʾ��ͨ��װ��1��ʾ��Ʒ��װ��,ǿ�������ĸ�������1��ǿ�������ĸ�������2,װ������
--����ֵ:��װ���� 
local function IntensifyGetSuitName(equipAdaptedClass, equipCurLevel, soulRoot, equipPart, suitType, intensifyAddAttr1, intensifyAddAttr2, equipType ) 
	local suitCfgTbl = {}
	if soulRoot == PearlSoulRoot[1] then 		--����Ǿ�ս��
		suitCfgTbl = ArmyWarSuit_Common
		
	elseif soulRoot == PearlSoulRoot[2] then 	--����Ǿ�����
		suitCfgTbl = ArmyActSuit_Common
		
	elseif soulRoot == PearlSoulRoot[3] then 	--����Ƿ�ħ��
		suitCfgTbl = MagicActSuit_Common
		
	elseif soulRoot == PearlSoulRoot[4] then 	--�����ս���
		suitCfgTbl = GodWartSuit_Common
	end
	
	local equipPartStr  = equipPart
	if suitCfgTbl(tostring(equipCurLevel), intensifyAddAttr1) == nil or 
	    suitCfgTbl(tostring(equipCurLevel), intensifyAddAttr1, intensifyAddAttr2) == nil  then
	    if soulRoot == "ս��" then
            suitCfgTbl  = MagicActSuit_Common
	    elseif soulRoot == "��ħ" then
	        suitCfgTbl = GodWartSuit_Common
	    end
	end
	
    local keys = suitCfgTbl:GetKeys(tostring(equipCurLevel), intensifyAddAttr1, intensifyAddAttr2, equipPartStr)
    local len = # keys
    if len < 1 then
		--assert(false, "û��ƥ�����װ��Ϣ~" .. "BaseLevelType:" ..  ",EquipPart" .. equipPartStr .. ",intensifyAddAttr1" .. intensifyAddAttr1 .. ",intensifyAddAttr2" .. intensifyAddAttr2) 
		--LogErr("û��ƥ�����װ��Ϣ~" .. "BaseLevelType:" .. equipCurLevel ..  ",EquipPart" .. equipPartStr .. ",intensifyAddAttr1" .. intensifyAddAttr1 .. ",intensifyAddAttr2" .. intensifyAddAttr2)
		local suitQuotiety = EquipSuitOutScale_Server("None", "SuitQuotiety")
		return suitQuotiety, ""
	end
    local randomNo = math.random(1, len)

	
	local suitQuotiety,suitName = GetScaleForthPhase(suitCfgTbl, equipCurLevel, intensifyAddAttr1, intensifyAddAttr2, equipPartStr, randomNo, equipAdaptedClass)

	return suitQuotiety, suitName
end

--װ��ǿ���Ľ׶�
local function IntensifyEquipPhaseThree(equipLevelType, equipPart, soulRoot, addAttr1Name, addAttr2Name, addAttr1Value, addAttr2Value, equipType, nEquipType)
	--[[
	if equipPart == "����" then
		local x2 = addAttr1Value * 2.6 --�̶��ı���ֵ
		local y2 = addAttr2Value * 2.6 
		return x2, y2, ""
	end
	--]]
	local equipAdaptedClass = nil
	if nEquipType == tblEquipType["Weapon"] then
	    equipAdaptedClass= GetWeaponAdaptedClass(equipType)
	end
	--local suitInfo = IntensifyGetSuitName(equipLevelType, soulRoot, equipPart, suitType, addAttr1Name, addAttr2Name, equipType ) 
	--local suitQuotiety, suitType, suitName = GetScaleForthPhase(suitInfo, equipAdaptedClass)
    local suitQuotiety, suitName = IntensifyGetSuitName(equipAdaptedClass, equipLevelType, soulRoot, equipPart, suitType, addAttr1Name, addAttr2Name, equipType)

	local x2, y2  = addAttr1Value * suitQuotiety, addAttr2Value * suitQuotiety
	x2, y2  =tonumber( string.format("%.0f", x2)), tonumber( string.format("%.0f", y2)) 

	if suitType == "��" then --���Ʋ�������װ
		return x2, y2, ""
	else
		return x2, y2, suitName
	end
end

---------------------------------װ��ǿ������------------------------------------------
local StmtDef = {
	"_GetSameSuitNameWeaponsName",
	[[
		select	item.is_sName, equipInten.iei_uAddAttr1, equipInten.iei_uAddAttr2	 
			from tbl_item_equip as equip, tbl_item_weapon as weapon ,tbl_item_static as item, tbl_item_equip_intensify as equipInten
		where 
			equip.is_uId = weapon.is_uId and item.is_uId = equip.is_uId and 
			weapon.is_uId = equipInten.is_uId
			and equipInten.iei_sSuitName =? and equip.cs_uId =? 
	]]
}
DefineSql(StmtDef, Weapon)

local StmtDef = {
	"_GetSameSuitNamePartsCountArmor",
	[[
		select count(*)
			from tbl_item_equip as equip, tbl_item_armor as armor , tbl_item_equip_intensify as equipInten
		where 
			equip.is_uId = armor.is_uId  and armor.is_uId = equipInten.is_uId and equipInten.iei_sSuitName =?  and equip.cs_uId =? 
	]]
}
DefineSql(StmtDef, Armor)


local StmtDef = {
	"_GetSameSuitNameShieldsName",
	[[
		select count(*)
			from tbl_item_equip as equip, tbl_item_shield as shield , tbl_item_equip_intensify as equipInten
		where 
			equip.is_uId = shield.is_uId and shield.is_uId = equipInten.is_uId and equipInten.iei_sSuitName =?  and equip.cs_uId =? 
	]]
}
DefineSql(StmtDef, Shield)

local StmtDef = {
	"_GetSameSuitNameRingsName",
	[[
		select item.is_sName, equipInten.iei_uAddAttr1, equipInten.iei_uAddAttr2	 
			from tbl_item_equip as equip, tbl_item_ring as ring ,tbl_item_static as item , tbl_item_equip_intensify as equipInten
		where 
			equip.is_uId = ring.is_uId and item.is_uId = equip.is_uId 
			and ring.is_uId = equipInten.is_uId
			and equipInten.iei_sSuitName =? and equip.cs_uId =? 
	]]
}
DefineSql(StmtDef, Ring)

local function GetSuitAttrTblBySuitName( suitName )
	local suitAttrTbl = {}
	suitAttrTbl["FourCountSuit"] = false 
	local needPartsCountKeys = EquipSuit_Common:GetKeys(suitName)
	for i, v in pairs (needPartsCountKeys) do
        local needPartsCount = v
        local suitAttr =  EquipSuit_Common(suitName, needPartsCount, "SuitAttributeName")
        local needEquipPartsInfo = EquipSuit_Common(suitName, needPartsCount, "NeedEquipParts")
        local includingParts = EquipSuit_Common(suitName, needPartsCount, "IncludingPartsCount")
        suitAttrTbl["NeedEquipParts"] = needEquipPartsInfo
		if includingParts == 4 then
			suitAttrTbl["FourCountSuit"] = true --���ļ�����װ
		end
		table.insert(suitAttrTbl,{needPartsCount, suitAttr} ) 
	end
	local suitAttrTblLen = # suitAttrTbl
	if suitAttrTblLen == 0 then
		assert(false, "EquipSuit_Common���ñ���û�ж�Ӧ����װ��:" .. suitName)
	end
	return suitAttrTbl
end

--�������ݿ��ѯ���Ľ�ɫ���ϴ��ŵ�װ��������Ƿ��Ƿ��ϳ���������װ��
--������װ�����ͣ�"��"��ʾ����������"��"��ʾ��ָ��
--����ֵ�����׵���Чװ������
local function CheckHaveTwoSameEquip(strEquipType, equipPartsRet, allowHaveSameEquip)
	local equip1Name = equipPartsRet:GetDataByName(0, "is_sName")
	local equip2Name = equipPartsRet:GetDataByName(1, "is_sName")	
	local equip1AddAttr1 = equipPartsRet:GetDataByName(0, "iei_uAddAttr1")
	local equip1AddAttr2 = equipPartsRet:GetDataByName(0, "iei_uAddAttr2")
	local equip2AddAttr1 = equipPartsRet:GetDataByName(1, "iei_uAddAttr1")
	local equip2AddAttr2 = equipPartsRet:GetDataByName(1, "iei_uAddAttr2")
	
	if strEquipType == "��" then
		local weapon1Type = string.sub(Equip_Weapon_Common(equip1Name,"EquipType"), 1, 2)
		local weapon2Type = string.sub(Equip_Weapon_Common(equip2Name,"EquipType"), 1, 2)
		if allowHaveSameEquip == nil then
			if equip1AddAttr1 ~= equip2AddAttr1 or
				equip1AddAttr2 ~= equip2AddAttr2 then
				return 2	
			end
		else
		    if weapon1Type == weapon2Type and weapon1Type == "��" and
		        equip1AddAttr1 == equip2AddAttr1 and
				equip1AddAttr2 == equip2AddAttr2 then
				return 2	
			end
		end

	elseif strEquipType == "��" then
		if allowHaveSameEquip == nil then
			if equip1AddAttr1 ~= equip2AddAttr1 or
				equip1AddAttr2 ~= equip2AddAttr2 then
				return 2	
			end
		else
			if equip1AddAttr1 == equip2AddAttr1 and
				equip1AddAttr2 == equip2AddAttr2 then
				return 2	
		 	end
		end
	end
	return 1
end

--������װ����Ӧ����Ҫ��{"��",2}��������Ҫ��
local EquipSuitNeedEquipPartsTbl  ={}

local function ReturnNeedWeaponOrRingCount(suitAttrTbl)
	local needEquipParts = suitAttrTbl["NeedEquipParts"]
	local needEquipPartsStr = "{" .. needEquipParts .. "}"
	if EquipSuitNeedEquipPartsTbl[needEquipPartsStr] == nil then
	    local tbl = loadstring("return" .. needEquipPartsStr)()
	    EquipSuitNeedEquipPartsTbl[needEquipPartsStr] = tbl
    end
	local needEquipPartsTbl = EquipSuitNeedEquipPartsTbl[needEquipPartsStr]
	local	needWeaponCounts = nil	--�������װӵ��һģһ���ĵ�����������Ŀ
	local needRingCounts = nil		--�������װӵ��һģһ���Ľ�ָ����Ŀ
	for i, v in pairs(needEquipPartsTbl) do
		local equipPartInfo = v 
		if equipPartInfo[1] == "��" then
			needWeaponCounts = equipPartInfo[2]
		elseif equipPartInfo[1] == "��" then
			needRingCounts = equipPartInfo[2]
		end
	end    
	return needWeaponCounts, needRingCounts
end

--����ǿ����������װ���Ժͽ�ɫ���ϴ��˸���װ�ļ�����������װ����
--����:��װ�����������ӻ���ɾ��ĳ����װ
--����ֵ�����ӻ�ɾ����װ���ԡ����ݽ�ɫ�����ִ���װ��������ͬһ��װ������װ���Ƶó�����װ���ԡ�
function EquipIntensifyDB.GetSuitAttributeBySuitName(playerId, suitName)
	local suitAttrTbl = GetSuitAttrTblBySuitName( suitName )
	local needWeaponCounts, needRingCounts = ReturnNeedWeaponOrRingCount(suitAttrTbl)

	
	local weaponPartsRet =  Weapon._GetSameSuitNameWeaponsName:ExecSql("s[32]s[16]s[16]", suitName, playerId)
	local armorPartsRet = Armor._GetSameSuitNamePartsCountArmor:ExecSql("n", suitName, playerId)
	local ringPartsRet = Ring._GetSameSuitNameRingsName:ExecSql("s[32]s[16]s[16]", suitName, playerId)
	local shieldPartsRet = Shield._GetSameSuitNameShieldsName:ExecSql("n", suitName, playerId)
	
	local includingPartsCount = 0
	local weaponsRowNum = weaponPartsRet:GetRowNum()
	local haveWeaponCounts = 0 --ӵ�е��ֽ�����Ŀ
	local ringsRowNum = ringPartsRet:GetRowNum()
	local haveRingCounts = 0 
	
	if armorPartsRet:GetRowNum() ~= 0 then
		includingPartsCount = includingPartsCount + armorPartsRet:GetData(0, 0)
	end
	
	if weaponsRowNum == 1 then
		includingPartsCount = includingPartsCount + 1
	elseif weaponsRowNum == 2 then
		local haveValidateWeaponsNum = CheckHaveTwoSameEquip("��", weaponPartsRet, needWeaponCounts)
		includingPartsCount = includingPartsCount + haveValidateWeaponsNum
	end
	
	if ringsRowNum == 1 then
		includingPartsCount = includingPartsCount + 1
	elseif ringsRowNum == 2 then
		local haveValidateRingsNum = CheckHaveTwoSameEquip("��", ringPartsRet, needRingCounts)
		includingPartsCount = includingPartsCount + haveValidateRingsNum
	end	
	
	if shieldPartsRet:GetRowNum() ~= 0 then
		includingPartsCount = includingPartsCount + shieldPartsRet:GetData(0, 0)
	end

	weaponPartsRet:Release()
	armorPartsRet:Release()
	ringPartsRet:Release()
	shieldPartsRet:Release()
	return true, suitAttrTbl, includingPartsCount
end

--�������ϵ�װ������װ����Ϊ�յ�ɸѡ����
local StmtDef = {
	"_WeaponGetSuitAttributeByPlayerID",
	[[
		select equipInten.iei_sSuitName, weapon.iw_uBaseLevel, item.is_sName, equipInten.iei_uAddAttr1, equipInten.iei_uAddAttr2 
			from tbl_item_equip as equip, tbl_item_weapon as weapon, tbl_item_equip_intensify as equipInten,
			    tbl_item_static as item
		where 
			equip.is_uId = weapon.is_uId 
			and equip.cs_uId =? 
			and not equipInten.iei_sSuitName = ""
			and equipInten.is_uId = weapon.is_uId 
			and equip.is_uId = item.is_uId
	]]
}
DefineSql(StmtDef, Weapon)

local StmtDef = {
	"_ArmorGetSuitAttributeByPlayerID",
	[[
	select equipInten.iei_sSuitName, armor.ia_uBaseLevel
		from tbl_item_equip as equip, tbl_item_armor as armor , tbl_item_equip_intensify as equipInten
	where 
		equip.is_uId = armor.is_uId  and equip.cs_uId =? and not iei_sSuitName = "" and equipInten.is_uId = armor.is_uId 
	]]
}
DefineSql(StmtDef, Armor)

local StmtDef = {
	"_RingGetSuitAttributeByPlayerID",
	[[
	select equipInten.iei_sSuitName, ring.ir_uBaseLevel,  item.is_sName, equipInten.iei_uAddAttr1, equipInten.iei_uAddAttr2 
		from tbl_item_equip as equip, tbl_item_ring as ring, tbl_item_equip_intensify as equipInten,
		tbl_item_static as item
	where 
		equip.is_uId = ring.is_uId  and equip.cs_uId =? and not equipInten.iei_sSuitName = "" and equipInten.is_uId = ring.is_uId 
		and equip.is_uId = item.is_uId
	]]
}
DefineSql(StmtDef, Ring)

local StmtDef = {
	"_ShieldGetSuitAttributeByPlayerID",
	[[
	select equipInten.iei_sSuitName, shield.is_uBaseLevel
		from tbl_item_equip as equip, tbl_item_shield as shield , tbl_item_equip_intensify as equipInten
	where 
		equip.is_uId = shield.is_uId  and equip.cs_uId =? and not equipInten.iei_sSuitName = "" and equipInten.is_uId = shield.is_uId 
	]]
}
DefineSql(StmtDef, Shield)

function EquipIntensifyDB.GetSuitAttributeByPlayerID(playerId)
	assert(playerId)
	local suitInfoTbl = {}
	local baseLevelTbl = {}

	local weaponRet = Weapon._WeaponGetSuitAttributeByPlayerID:ExecStat(playerId)
	local armorRet  = Armor._ArmorGetSuitAttributeByPlayerID:ExecSql("s[40]n", playerId)
	local ringRet  = Ring._RingGetSuitAttributeByPlayerID:ExecStat(playerId)
	local shieldRet = Shield._ShieldGetSuitAttributeByPlayerID:ExecSql("s[40]n", playerId)
	local weaponRetNum = weaponRet:GetRowNum()
	local armorRetNum  = armorRet:GetRowNum()
	local ringRetNum   = ringRet:GetRowNum()
	local shieldRetNum = shieldRet:GetRowNum()

	for i=1, weaponRetNum  do
		local suitName = weaponRet:GetData(i-1, 0)
		if suitInfoTbl[suitName] == nil  then
			suitInfoTbl[suitName] = 1
			baseLevelTbl[suitName] = weaponRet:GetDataByName(i-1, "iw_uBaseLevel")
		else
		    local suitAttrTbl = GetSuitAttrTblBySuitName( suitName )
		    local needWeaponCounts, needRingCounts = ReturnNeedWeaponOrRingCount(suitAttrTbl)
		    local weapon1SuitName = weaponRet:GetDataByName(0, "iei_sSuitName")
		    local weapon2SuitName = weaponRet:GetDataByName(1, "iei_sSuitName")
		    if weapon1SuitName == weapon2SuitName then
		        local validCount = CheckHaveTwoSameEquip("��", weaponRet, needWeaponCounts)
		        if validCount == 2 then
			        suitInfoTbl[suitName] = suitInfoTbl[suitName] + 1
			    end
			else
			    suitInfoTbl[suitName] = suitInfoTbl[suitName] + 1
			end
		end
	end 
	
	for i=1, armorRetNum  do
		local suitName = armorRet:GetData(i-1, 0)
		if suitInfoTbl[suitName] == nil then
			suitInfoTbl[suitName] = 1
			baseLevelTbl[suitName] = armorRet:GetDataByName(i-1, "ia_uBaseLevel")
		else
			suitInfoTbl[suitName] = suitInfoTbl[suitName] + 1
		end
	end
	for i=1, ringRetNum  do
		local suitName = ringRet:GetData(i-1, 0)
		if suitInfoTbl[suitName] == nil  then
			suitInfoTbl[suitName] = 1
			baseLevelTbl[suitName] = ringRet:GetDataByName(i-1, "ir_uBaseLevel")
		else
		    if i == 1 then
		        suitInfoTbl[suitName] = suitInfoTbl[suitName] + 1
		    else
		        local suitAttrTbl = GetSuitAttrTblBySuitName( suitName )
    		    local needWeaponCounts, needRingCounts = ReturnNeedWeaponOrRingCount(suitAttrTbl)  		    
    		    local ring1SuitName = ringRet:GetDataByName(0, "iei_sSuitName")
    		    local ring2SuitName = ringRet:GetDataByName(1, "iei_sSuitName")
    		    if (ring1SuitName == ring2SuitName) then
    		        local validCount = CheckHaveTwoSameEquip("��", ringRet, needRingCounts)
        		    if validCount == 2  then
        			    suitInfoTbl[suitName] = suitInfoTbl[suitName] + 1
        			end
        	    else
        	        suitInfoTbl[suitName] = suitInfoTbl[suitName] + 1
        	    end
		    end
		end
	end
	for i=1, shieldRetNum do
	    local suitName = shieldRet:GetData(i-1, 0)
		if suitInfoTbl[suitName] == nil then
			suitInfoTbl[suitName] = 1
			baseLevelTbl[suitName] = shieldRet:GetDataByName(i-1, "is_uBaseLevel")
		else
			suitInfoTbl[suitName] = suitInfoTbl[suitName] + 1
		end
	end
	local suitTbl = {}
	local index = 1
	for i, v in pairs(suitInfoTbl) do
		local suitName = i
		local suit = GetSuitAttrTblBySuitName( suitName )
		local includingPartsCount = v
		table.insert(suitTbl, {["SuitName"] = suitName, ["SuitAttrTbl"] = suit, 
														["IncludingPartsCount"] = includingPartsCount,
														["BaseLevel"]=baseLevelTbl[suitName] })
		index  = index + 1
	end

	return suitTbl
end

function EquipIntensifyDB.GetSuitCountByCharID(charID)    
    local suitInfoTbl = GetSuitAttributeByPlayerID(charID)
    local suitCountTbl = {}
    for i, v in pairs(suitInfoTbl) do
        local suitName = v["SuitName"]
        local suitCount = v["IncludingPartsCount"] 
        local info = EquipSuit_Common:GetKeys(suitName)
        local partsKey = info[1]
        local needParts = EquipSuit_Common(suitName, partsKey, "IncludingPartsCount")
        local count = 0 
        if suitCount >=8 and needParts == 8  then
            count = 8
        elseif suitCount >=6 and suitCount < 8 and needParts == 6 then
            count = 6
        elseif suitCount >= 4 and suitCount < 6 and  needParts == 4 then
            count = 4
        elseif suitCount == 3 and needParts == 3 then
            count = 3
        elseif suitCount == 2 and needParts == 2 then
            count = 2
        end 
        if count >= 2 then
            if  suitCountTbl[count] == nil then
                suitCountTbl[count] = 1
            else
                suitCountTbl[count] = suitCountTbl[count] + 1
            end
        end
    end
    return suitCountTbl
end

---------------------װ��ǿ�������׶Σ�����������츳���ܣ��������ݿ�------------------
function EquipMgrDB.GetAddTalentOrSkillIndex()
    local keys = SuitPartMapTalentOrSkill_Common:GetKeys()
    local totalTalentOrSkillNameNum = # keys
    local randomNum = math.random(1, totalTalentOrSkillNameNum)
    return randomNum
end

--------------------------------����ǿ��--------------------------------
local StmtDef ={
	"_UpdateEquipIntensifyAddAttr",
	[[
		update 
			tbl_item_equip_intensify 
		set 
			iei_uAddAttr1 = ?, iei_uAddAttrValue1 =?, iei_uAddAttr2 = ?,  iei_uAddAttrValue2 =? 
		where 
			is_uId = ?
	]]
}
DefineSql(StmtDef, EquipMgr)

local StmtDef = {
	"_GetEquipAddAttr1Name",
	[[
		select iei_uAddAttr1, iei_uAddAttrValue1 from tbl_item_equip_intensify where is_uId =?
	]]
}
DefineSql(StmtDef, EquipMgr)

local StmtDef ={
	"_UpdateEquipIntensifyAddAttrPhase2",
	[[
		update 
			tbl_item_equip_intensify 
		set 
			iei_uAddAttrValue1 =?, iei_uAddAttr2 = ?,  iei_uAddAttrValue2 =? , iei_uPreAddAttr1=?, iei_uPreAddAttrValue1=?
		where 
			is_uId = ?
	]]
}
DefineSql(StmtDef, EquipMgr)

local StmtDef = {
	"_GetEquipAddAttrValue",
	[[
		select iei_uAddAttrValue1, iei_uAddAttrValue2, iei_uAddAttr1, iei_uAddAttr2 from tbl_item_equip_intensify where is_uId=?
	]]
}
DefineSql(StmtDef, EquipMgr)

local StmtDef ={
	"_UpdateEquipAddAttrValuePhase3",
	[[
		update tbl_item_equip_intensify set iei_uIntensifySoulNum =0, iei_uIntensifyPhase = 3, iei_uIntensifyBackState = 1,iei_uAddAttrValue1 = ?, iei_uAddAttrValue2 = ?, iei_sSuitName=? ,iei_uPreAddAttrValue1=?, iei_uPreAddAttrValue2=?, iei_uPreAddAttr2=?, iei_uIntensifyTimes = iei_uIntensifyTimes + 1, iei_uIntenTalentIndex = ?  where is_uId =?
	]]
}
DefineSql(StmtDef, EquipMgr)

local StmtDef = {
	"_UpdateEquipIntensifyPhase",
	[[
		update tbl_item_equip_intensify set iei_uIntensifyPhase =?, iei_uIntensifySoulNum = 0, iei_uIntensifyBackState= 1, iei_uIntensifyTimes = ifnull(iei_uIntensifyTimes,0) + 1  where is_uId =?
	]]
}
DefineSql(StmtDef, EquipMgr)

local function CheckIntensifyInfo(intensifyRet, uEquipId, baseLevel, intensifyQuality, equipType)
	local intensifySoulNum = 0
	local intensifyPhase = 0
	if intensifyRet ~= nil then
        intensifySoulNum  = intensifyRet:GetDataByName(0,"iei_uIntensifySoulNum") or 0
        intensifyPhase = intensifyRet:GetDataByName(0, "iei_uIntensifyPhase") or 0
	end
	--ȱ�ٶ�ǿ����Ҫ�Ļ���Ŀ���ж�
	if intensifySoulNum < GetIntensifyNeededSoul(baseLevel, equipType) then
		return false, 180005
	end

	if intensifyQuality <=  intensifyPhase then
        return false, 180014
    end
    return true, intensifyPhase
end

local function GetEquipBaseInfoForIntensify(keyStr, tbl_name, equipID)
    local sqlStatement = "select " .. keyStr .. "uCurLevel, " .. keyStr .. "uBaseLevel, " .. keyStr .. "uIntensifyQuality ," .. keyStr .. "sIntenSoul from " .. tbl_name .. " where " ..  "is_uId = " .. equipID
    local _, ret = g_DbChannelMgr:TextExecute(sqlStatement)
    local baseLevel = nil
    local intensifyQuality = nil
    local attrLevel = nil
    local intensifySoul
    if ret:GetRowNum() > 0 then
        attrLevel = ret:GetData(0, 0)
        baseLevel= ret:GetData(0, 1)
        intensifyQuality = ret:GetData(0, 2)
        intensifySoul = ret:GetData(0, 3)
    end
    return attrLevel, baseLevel, intensifyQuality, intensifySoul
end

--ǿ��һ�׶�
function EquipIntensifyDB.EquipIntensifyPhaseOne(equipPart, intenSoul, attrLevel,  curLevelNo, uItemId)
	local addAttr1Name, addAttr1No = IntensifyEuqipPhaseOne(equipPart, intenSoul, attrLevel,  curLevelNo)
	if addAttr1Name == nil or  addAttr1No == nil then
		return false, 180007
	end

	EquipMgr._UpdateEquipIntensifyAddAttr:ExecSql("", addAttr1Name, addAttr1No, "", 0  , uItemId)
	if g_DbChannelMgr:LastAffectedRowNum() < 1 then
		CancelTran()
		return false, 180007
	end    
	return true 
end

--ǿ�����׶�
function EquipIntensifyDB.EquipIntensifyPhaseTwo(uItemId, curLevelNo, attrLevel, equipPart, intenSoul)
	local addAttr1Name = EquipMgr._GetEquipAddAttr1Name:ExecSql("s[16]n", uItemId)
	if addAttr1Name:GetRowNum() == 0 then
		return false, 180008
	end
	local addAttr1NameRet = addAttr1Name:GetDataByName(0, "iei_uAddAttr1")
	local addAttr1ValueRet = addAttr1Name:GetDataByName(0, "iei_uAddAttrValue1")

	local addAttr2Name, addAttr1Value, addAttr2Value = IntensifyEuqipPhaseTwo(addAttr1NameRet, curLevelNo, attrLevel, equipPart, intenSoul)
	if addAttr2Name == nil or addAttr1Value ==nil or addAttr2Value ==nil then
		return false, 180008
	end
	
	EquipMgr._UpdateEquipIntensifyAddAttrPhase2:ExecSql("",  addAttr1Value, addAttr2Name, addAttr2Value, addAttr1NameRet, addAttr1ValueRet, uItemId)
	if g_DbChannelMgr:LastAffectedRowNum() < 1 then
		CancelTran()
		return false, 180008
	end
    return true
end

--ǿ�����׶�
function EquipIntensifyDB.EquipIntensifyPhaseThree(baseLevel, uCharId, uItemId, curLevelNo, equipPart, intenSoul, EquipType, nEquipType)
	local addAttrValueRet = EquipMgr._GetEquipAddAttrValue:ExecSql("nns[16]s[16]", uItemId)
	local addAttr1Value, addAttr2Value, addAttr1, addAttr2 = addAttrValueRet:GetDataByName(0, "iei_uAddAttrValue1"), addAttrValueRet:GetDataByName(0, "iei_uAddAttrValue2"), addAttrValueRet:GetDataByName(0, "iei_uAddAttr1"), addAttrValueRet:GetDataByName(0, "iei_uAddAttr2")
	
	local addAttr1ValueNew, addAttr2ValueNew, suitName = IntensifyEquipPhaseThree(curLevelNo, equipPart, intenSoul, addAttr1, addAttr2, addAttr1Value, addAttr2Value, EquipType, nEquipType)
	local _, _,includingPartsCountPre 
	if suitName ~= "" then
	     _, _,includingPartsCountPre = EquipIntensifyDB.GetSuitAttributeBySuitName(uCharId, suitName)
	end
	--[[
    if isShiled == 1 then		--�Ƕ���
		suitName = ""
	end
	--]]
	local addTalentOrSkillName = EquipMgrDB.GetAddTalentOrSkillIndex()
	EquipMgr._UpdateEquipAddAttrValuePhase3:ExecSql("", addAttr1ValueNew, addAttr2ValueNew, suitName, addAttr1Value, addAttr2Value, addAttr2, addTalentOrSkillName, uItemId) --�ı丽������ֵ
	if g_DbChannelMgr:LastAffectedRowNum() < 1 then
		CancelTran()
		return false, 180009
	end
	local g_LogMgr = RequireDbBox("LogMgrDB")
	local res = EquipMgrDB.SelectEquipIntensifyInfo(uItemId)
	if res:GetRowNum() > 0 then
		g_LogMgr.SaveEquipIntensifyInfo( uCharId, res)
	end
		
	if suitName ~= "" then
		local suc, suitAttrTbl, includingPartsCount = EquipIntensifyDB.GetSuitAttributeBySuitName(uCharId, suitName)
		if includingPartsCountPre == includingPartsCount then
	        suitAttrTbl = {}
	        includingPartsCount = 0
	    end
		local playerAddAttr = {["SuitAttrTbl"] = suitAttrTbl, ["IncludingPartsCount"] = includingPartsCount, ["SuitName"] =suitName, ["BaseLevel"] = baseLevel }
		return true, playerAddAttr
	else
		local playerAddAttr = {["SuitAttrTbl"] = {}, ["IncludingPartsCount"] = 0, ["BaseLevel"] = baseLevel}
		return true, playerAddAttr
	end
end

function EquipIntensifyDB.UpdateEquipIntensifyPhase(intensifyPhaseNo, uItemId, uCharId)
	EquipMgr._UpdateEquipIntensifyPhase:ExecSql("", intensifyPhaseNo+1  , uItemId)
	if g_DbChannelMgr:LastAffectedRowNum() < 1 then
		CancelTran()
		return false, 180011
	end
	
	local g_LogMgr = RequireDbBox("LogMgrDB")
	local res = EquipMgrDB.SelectEquipIntensifyInfo(uItemId)
	if res:GetRowNum() > 0 then
		g_LogMgr.SaveEquipIntensifyInfo( uCharId, res)
	end
end

--����ǿ��
function EquipIntensifyDB.WeaponIntensify(uCharId, uItemId, nEquipType, sEquipName, equipRet,sceneName)
	local EquipType = g_ItemInfoMgr:GetItemInfo(nEquipType, sEquipName,"EquipType")	
	local attrLevel, baseLevel, intensifyQuality, intenSoul = GetEquipBaseInfoForIntensify("iw_", "tbl_item_weapon", uItemId)
	local checkSuc, intensifyPhaseNo = CheckIntensifyInfo(equipRet, uItemId, baseLevel, intensifyQuality, EquipType)
	if checkSuc == false then
       local errorMsgId = intensifyPhaseNo
       return false,  errorMsgId
    end
	
	local curLevelNo =  GetEquipLevelType(baseLevel)
	local equipPart = string.sub(EquipType, 1, 4)

	if  intensifyPhaseNo == 0 then			--����ǿ��һ�׶�
        local sucFlag, strRet = EquipIntensifyDB.EquipIntensifyPhaseOne(equipPart, intenSoul, attrLevel,  curLevelNo, uItemId)
        if sucFlag == false then
            return  false, strRet
        end
		
	elseif  intensifyPhaseNo == 1 then
        local sucFlag, strRet = EquipIntensifyDB.EquipIntensifyPhaseTwo(uItemId, curLevelNo, attrLevel, equipPart, intenSoul)
        if sucFlag == false then
            return  false, strRet
        end
		
	elseif intensifyPhaseNo == 2 then
        local sucFlag, strRet = EquipIntensifyDB.EquipIntensifyPhaseThree(baseLevel, uCharId, uItemId, curLevelNo, equipPart, intenSoul, EquipType, nEquipType)
        
        return  sucFlag, strRet
	end
	local sucFlag, strRet = EquipIntensifyDB.UpdateEquipIntensifyPhase(intensifyPhaseNo, uItemId, uCharId)
    if sucFlag == false then
        return  false, strRet
    end
	return true, {["BaseLevel"] = baseLevel}

end

---------------------------------����ǿ��-------------------------------
--����ǿ��
function EquipIntensifyDB.ArmorIntensify(uCharId, uItemId, uEquipType, sEuqipName, equipRet,sceneName)
	local EquipType = g_ItemInfoMgr:GetItemInfo(uEquipType, sEuqipName,"EquipType")
	local EquipPart = g_ItemInfoMgr:GetItemInfo(uEquipType, sEuqipName,"EquipPart")
	
	local attrLevel, baseLevel, intensifyQuality, intenSoul = GetEquipBaseInfoForIntensify("ia_", "tbl_item_armor", uItemId)
	local checkSuc, intensifyPhaseNo = CheckIntensifyInfo(equipRet, uItemId, baseLevel, intensifyQuality, EquipType)
	
	if checkSuc == false then
       local errorMsgId = intensifyPhaseNo
       return false,  errorMsgId
    end
		
	local curLevelNo =  GetEquipLevelType(baseLevel)
	if  intensifyPhaseNo == 0 then
        local sucFlag, strRet = EquipIntensifyDB.EquipIntensifyPhaseOne(EquipPart, intenSoul, attrLevel, curLevelNo, uItemId)
        if sucFlag == false then
            return  false, strRet
        end
		
	elseif  intensifyPhaseNo == 1 then
        local sucFlag, strRet = EquipIntensifyDB.EquipIntensifyPhaseTwo(uItemId, curLevelNo, attrLevel, EquipPart, intenSoul)
        if sucFlag == false then
            return  false, strRet
        end
	
	elseif intensifyPhaseNo == 2 then
	    local sucFlag, strRet = EquipIntensifyDB.EquipIntensifyPhaseThree(baseLevel,uCharId, uItemId, curLevelNo, EquipPart, intenSoul, EquipType)
        return  sucFlag, strRet
	end
	
    local sucFlag, strRet = EquipIntensifyDB.UpdateEquipIntensifyPhase(intensifyPhaseNo, uItemId, uCharId)
    if sucFlag == false then
        return  false, strRet
    end

	return true, {["BaseLevel"] = baseLevel}
end
-----------------------------------����ǿ��-----------------------------------------
function EquipIntensifyDB.ShieldIntensify(uCharId, uItemId, nEquipType, sEquipName, equipRet,sceneName)
	local ItemInfo = g_ItemInfoMgr:GetItemFunInfo(nEquipType, sEquipName)
	local EquipType = ItemInfo("EquipType")
	local EquipPart = ItemInfo("EquipPart")
	
    local attrLevel, baseLevel, intensifyQuality, intenSoul = GetEquipBaseInfoForIntensify("is_", "tbl_item_shield", uItemId)
	local checkSuc, intensifyPhaseNo = CheckIntensifyInfo(equipRet, uItemId, baseLevel, intensifyQuality, EquipType)
	
	if checkSuc == false then
       local errorMsgId = intensifyPhaseNo
       return false,  errorMsgId
    end

	local curLevelNo =  GetEquipLevelType(baseLevel)
	
	if  intensifyPhaseNo == 0 then			--����ǿ��һ�׶�
        local sucFlag, strRet = EquipIntensifyDB.EquipIntensifyPhaseOne(EquipType, intenSoul, attrLevel,  curLevelNo, uItemId)
        if sucFlag == false then
            return  false, strRet
        end
		
	elseif  intensifyPhaseNo == 1 then
        local sucFlag, strRet = EquipIntensifyDB.EquipIntensifyPhaseTwo(uItemId, curLevelNo, attrLevel, EquipType, intenSoul)
        if sucFlag == false then
            return  false, strRet
        end
		
	elseif intensifyPhaseNo == 2 then
	    --local isShield = ItemInfo("IsShield")
	    local sucFlag, strRet = EquipIntensifyDB.EquipIntensifyPhaseThree(baseLevel, uCharId, uItemId, curLevelNo, EquipType, intenSoul, EquipType)
        return  sucFlag, strRet
	end
	
	local sucFlag, strRet = EquipIntensifyDB.UpdateEquipIntensifyPhase(intensifyPhaseNo, uItemId, uCharId)
    if sucFlag == false then
        return  false, strRet
    end
    
	return true, {["BaseLevel"] = baseLevel}
end
----------------------------------��ָǿ��-----------------------------------------
--��ָǿ��
function EquipIntensifyDB.RingIntensify(uCharId, uItemId, uEquipType, sEuqipName, equipRet,sceneName)
	local EquipType = g_ItemInfoMgr:GetItemInfo(uEquipType, sEuqipName,"EquipType")
	
    local attrLevel, baseLevel, intensifyQuality, intenSoul = GetEquipBaseInfoForIntensify("ir_", "tbl_item_ring", uItemId)
	local checkSuc, intensifyPhaseNo = CheckIntensifyInfo(equipRet, uItemId, baseLevel, intensifyQuality, EquipType)
	
	if checkSuc == false then
       local errorMsgId = intensifyPhaseNo
       return false,  errorMsgId
    end
	
	local curLevelNo =  GetEquipLevelType(baseLevel)
	
	if  intensifyPhaseNo == 0 then
        local sucFlag, strRet = EquipIntensifyDB.EquipIntensifyPhaseOne("��ָ", intenSoul, attrLevel,  curLevelNo, uItemId)
        if sucFlag == false then
            return  false, strRet
        end
		
	elseif  intensifyPhaseNo == 1 then
	    local sucFlag, strRet = EquipIntensifyDB.EquipIntensifyPhaseTwo(uItemId, curLevelNo, attrLevel, "��ָ", intenSoul)
        if sucFlag == false then
            return  false, strRet
        end
	
	elseif intensifyPhaseNo == 2 then
	    local sucFlag, strRet = EquipIntensifyDB.EquipIntensifyPhaseThree(baseLevel, uCharId, uItemId, curLevelNo, "��ָ", intenSoul, EquipType)
        return sucFlag, strRet
	end
	local sucFlag, strRet = EquipIntensifyDB.UpdateEquipIntensifyPhase(intensifyPhaseNo, uItemId, uCharId)
    if sucFlag == false then
        return  false, strRet
    end
    
	return true, {["BaseLevel"] = baseLevel}
end
------------------------------------װ��ǿ����ں���------------------------------
--װ��ǿ����ں���
function EquipIntensifyDB.EquipIntensify(data)	
	local uItemId = data["ItemID"]
	local uCharId = data["CharID"]
	local equipPart = data["EquipPart"]
	local sceneName = data["sceneName"]
	assert(IsNumber(uItemId))
	assert(IsNumber(uCharId))
	local  EquipAdvanceDB = RequireDbBox("EquipAdvanceDB")
	local curAdvancedPhase, advanceQuality = EquipAdvanceDB.GetEquipCurAdvancedPhase(uItemId)
	if curAdvancedPhase == advanceQuality and curAdvancedPhase >= 5 then --�������û�ﵽ�ý׶Σ��򲻿�ǿ��
	   return false, 180016
	end
	local g_RoomMgr     =   RequireDbBox("GasRoomMgrDB")
	local nEquipType, sEquipName 	= 	g_RoomMgr.GetItemType(uItemId)
    
    local part =  EquipMgrDB.GetEquipPartById(uCharId,uItemId)
    if part ~= equipPart then
        return false, 180024 
    end
    
	local  intensifyRet = EquipIntensifyDB.GetEquipIntensifyInfoTbl( uItemId)
	if intensifyRet:GetRowNum() < 1 then
        LogErr("ǿ����Ϣ��δ��ʼ", uItemId) 
	end
	local suc, equipIntensifySuc, newEquipInfoTbl
	if nEquipType == tblEquipType["Weapon"] then			--������
		suc, equipIntensifySuc = EquipIntensifyDB.WeaponIntensify(uCharId, uItemId, nEquipType, sEquipName, intensifyRet,sceneName)
	 	
	elseif nEquipType == tblEquipType["Armor"] or
			nEquipType == tblEquipType["Jewelry"] then		--�Ƿ���
		suc, equipIntensifySuc = EquipIntensifyDB.ArmorIntensify(uCharId, uItemId, nEquipType, sEquipName, intensifyRet,sceneName)
		
	elseif nEquipType == tblEquipType["Shield"] then		--����
		suc, equipIntensifySuc = EquipIntensifyDB.ShieldIntensify(uCharId, uItemId, nEquipType, sEquipName, intensifyRet,sceneName)
		
	elseif nEquipType == tblEquipType["Ring"] then			--��ָ
		suc, equipIntensifySuc = EquipIntensifyDB.RingIntensify(uCharId, uItemId, nEquipType, sEquipName, intensifyRet,sceneName)
	end
	
	if	suc then
        local equipDuraState, curDuraValue, maxDuraValue 
        if equipPart ~= 0 then
            local EquipDurabilityDB = RequireDbBox("EquipDurabilityDB")
            equipDuraState, curDuraValue, maxDuraValue = EquipDurabilityDB.GetEquipUllageState(uItemId)
        end
	    newEquipInfoTbl = EquipIntensifyDB.GetEquipIntensifyInfoTbl(uItemId)
        local EquipSuperaddDB = RequireDbBox("EquipSuperaddDB")
        local equipSuperaddInfo =  EquipSuperaddDB.GetEquipSuperaddInfo(uItemId)
		local upInfo  = {["EquipRet"]= newEquipInfoTbl, ["EquipType"]=nEquipType, ["EquipName"]=sEquipName, ["EquipID"]=uItemId, ["EquipPart"] = equipPart,
		                  ["CurDuraValue"] = curDuraValue, ["MaxDuraValue"] = maxDuraValue,
		                  ["EquipSuperaddInfo"] = equipSuperaddInfo }
		local playerAddAttrInfo = equipIntensifySuc
		return true, intensifyRet , upInfo, playerAddAttrInfo
	else
		local errorMsgNo = equipIntensifySuc
		return false, errorMsgNo 
	end
end

function EquipIntensifyDB.GetSqlKeyInfoByEquipType(equipType)
	local sqlTblName, sqlKeyStr
	if tblEquipType["Weapon"] == equipType then
		sqlTblName = "tbl_item_weapon"
		sqlKeyStr  = "iw_"
		
	elseif tblEquipType["Armor"] == equipType or 
				tblEquipType["Jewelry"] == equipType then
		sqlTblName = "tbl_item_armor"
		sqlKeyStr  = "ia_"
	
	elseif tblEquipType["Shield"] == equipType then
		sqlTblName = "tbl_item_shield"
		sqlKeyStr  = "is_"
		
	elseif tblEquipType["Ring"] == equipType then
		sqlTblName = "tbl_item_ring"
		sqlKeyStr  = "ir_"
	end
	return sqlTblName, sqlKeyStr
end

--ǿ��4~9�׶�ʱ������װ���������ݿ��
function EquipIntensifyDB.GetUpEquipInfoSqlStatement(equipType, equipId)
    local sqlTblName, sqlKeyStr = "tbl_item_equip_intensify", "iei_"
    local sqlStatement = "update " .. sqlTblName .. " set " .. sqlKeyStr .. "uIntensifyPhase = " ..  sqlKeyStr .. "uIntensifyPhase + 1," 
    sqlStatement = sqlStatement ..  sqlKeyStr .. "uIntensifyBackState = 1," ..  sqlKeyStr .. "uIntensifyTimes = " .. sqlKeyStr .. "uIntensifyTimes + 1,"
    sqlStatement = sqlStatement .. sqlKeyStr .. "uIntensifySoulNum = 0 where is_uId = " .. equipId
    return sqlStatement
end

local function GetRandomScaleRate()
    local random = math.random(1, 100)
    local index = 0
    local Keys = AttrRateValue_Server:GetKeys()
    for i=1, #(Keys) do
        local scale = AttrRateValue_Server(Keys[i],"Rate")
        if index < random and random <= index + scale then
            local rate = ( AttrRateValue_Server(Keys[i],"RandomScale") )/ 100
            return rate
        end
        index = index + scale
    end
end

--ͨ��ǿ���׶εõ�ǿ����ĸ�������ֵ
local function GetAddAttrValueAfterPhase4( intensifyPhaseNo, stoneName, curLevel )
    if intensifyPhaseNo < 3 or intensifyPhaseNo > 8 then
       return false,  180011
    end
    local totalAttrValue = IntenPhaseMapAttrValue_Server(intensifyPhaseNo,"TotalAddAttrValue")
    if totalAttrValue == nil then
        return false, 180011
    end
    local rate = GetRandomScaleRate()
    local addAttrScaleRate = IntensifyStoneMapAddAttr_Common(stoneName,"ScaleRate")
    local levelRate = (1500 - (150 - curLevel)*9.176)/1500
    local addAttrValue = math.ceil(totalAttrValue * rate * addAttrScaleRate * levelRate)
    return true, addAttrValue
end

local function GetIntensifyStatement( stoneName, intensifyPhaseNo, rate, equipId, curLevel )
    local addAttrName = IntensifyStoneMapAddAttr_Common(stoneName,"AttrName")
    if addAttrName == nil then
       return false, 180015 
    end
    local suc, addAttrValue = GetAddAttrValueAfterPhase4( intensifyPhaseNo, stoneName, curLevel  )
    if suc == false then 
        local errorMsgId  = addAttrValue
        return false, errorMsgId
    end
    addAttrValue = addAttrValue * rate
    local sqlTableName, sqlKeyStr = "tbl_item_equip_intensifyAddAttr", "iei_"
    local sqlStatement = nil 
    if intensifyPhaseNo ==  3 then
        sqlStatement = "replace into " .. sqlTableName .. " ( is_uId, ".. sqlKeyStr .. "sAddAttr4," .. sqlKeyStr .. "uAddAttr4Value) values (" .. equipId .. ", '" ..  addAttrName .. "'," .. addAttrValue ..")"
    elseif intensifyPhaseNo >= 4 then 
        local index = intensifyPhaseNo + 1
        sqlStatement = "Update " .. sqlTableName .. " set " .. sqlKeyStr .. "sAddAttr" .. index .. " = '" .. addAttrName .. "', "
        sqlStatement = sqlStatement .. sqlKeyStr .. "uAddAttr"  .. index.. "Value" .. " = " .. addAttrValue .. " where is_uId = " .. equipId
    end
    return true, sqlStatement
end 

--ǿ�����Ľ׶������
function EquipIntensifyDB.EquipIntensifyUseStone(data)
    local nRoomIndex    =   data["RoomIndex"]
    local nPos          =   data["Pos"]
    local nItemType     =   data["ItemType"] 
    local sItemName     =   data["ItemName"]
    local uCharID       =   data["CharID"]
    local sceneName     =   data["sceneName"]
    local uEquipId       =   data["ItemID"]
    local equipPart     =   data["EquipPart"]
    local packedData    =   {["ItemID"] = data["ItemID"], ["CharID"] = uCharID, ["sceneName"]=sceneName}
 
    local g_RoomMgr     =   RequireDbBox("GasRoomMgrDB")
    --ǿ��װ��
    local nEquipType, sEquipName = g_RoomMgr.GetItemType(uEquipId)
    local equipRet = EquipIntensifyDB.GetEquipIntensifyInfoTbl(uEquipId)
    
    local part =  EquipMgrDB.GetEquipPartById(uCharID,uEquipId)
    if part ~= equipPart then
        return false, 180024 
    end
    local EquipType = g_ItemInfoMgr:GetItemInfo(nEquipType, sEquipName,"EquipType")
    local sqlTblName, sqlKeyStr = EquipIntensifyDB.GetSqlKeyInfoByEquipType(nEquipType)
    --ǿ���ܷ���е�ǰ���������
    
    local attrLevel, baseLevel, intensifyQuality, intenSoul = GetEquipBaseInfoForIntensify(sqlKeyStr, sqlTblName, uEquipId)
	local checkSuc, intensifyPhaseNo = CheckIntensifyInfo(equipRet, uItemId, baseLevel, intensifyQuality, EquipType)

    if checkSuc == false then
       local errorMsgId = intensifyPhaseNo
       return false,  errorMsgId
    end

    --��ǿ������ĵ��߽������ݿ����
    local sType, sName, count = g_RoomMgr.GetTypeCountByPosition(uCharID, nRoomIndex, nPos)
    local tbl_item_id = g_RoomMgr.GetAllItemFromPosition(uCharID, nRoomIndex, nPos)
    if tbl_item_id:GetRowNum() == 0 then
        CancelTran()
		return false, 180011, uEquipId  
    end
    if g_RoomMgr.DelItemByID( uCharID, tbl_item_id(1,1),event_type_tbl["��Ʒʹ��"]) == false then
		CancelTran()
		return false, 180011, uEquipId
	end

    local stoneID2, nRoomIndex2, nPos2
    local rate = 1
    if nEquipType == 5 and GetEquipHandType(EquipType) == "˫" then
        local stone2InfoTbl = g_RoomMgr.GetNCountItemIdByName(uCharID, sType, sName, 1)
        if stone2InfoTbl:GetRowNum() == 0 then        
            CancelTran()
            return false, 180033, uEquipId
        end

    	stoneID2, nRoomIndex2, nPos2 =stone2InfoTbl(1,1), stone2InfoTbl(1,2), stone2InfoTbl(1,3)
        if g_RoomMgr.DelItemByID( uCharID, stoneID2,event_type_tbl["��Ʒʹ��"]) == false then
    		CancelTran()
    		return false, 180011, uEquipId
    	end
    	rate = 2
    end

	local EquipIntensifyDB				=	RequireDbBox("EquipIntensifyDB")
	local oldEquipAddAttrInfoTbl = EquipIntensifyDB.GetEquipAddAttrInfoTbl(uEquipId)
    --����װ��ǿ������ʯ�õ��������Ժ͸�������ֵ�����������ݿ���Ϣ����
    local suc, sqlStatement = GetIntensifyStatement( sName, intensifyPhaseNo, rate, uEquipId, attrLevel )
    if suc == false then
        CancelTran()
        local errorMsgId =  sqlStatement
        return false, errorMsgId
    end
    g_DbChannelMgr:TextExecute(sqlStatement)
    if g_DbChannelMgr:LastAffectedRowNum() < 1 then
		CancelTran()
		return false, 180011, uEquipId
	end
	
	--����װ���������ݿ���е���Ϣ
	local sqlStatementUpEquip = EquipIntensifyDB.GetUpEquipInfoSqlStatement(nEquipType, uEquipId)
	g_DbChannelMgr:TextExecute(sqlStatementUpEquip)
	if g_DbChannelMgr:LastAffectedRowNum() < 1 then
		CancelTran()
		return false, 180011, uEquipId
	end
    local equipDuraState, curDuraValue, maxDuraValue 
    if equipPart ~= 0 then
        local EquipDurabilityDB = RequireDbBox("EquipDurabilityDB")
        equipDuraState, curDuraValue, maxDuraValue = EquipDurabilityDB.GetEquipUllageState(uEquipId)
    end
    
  local g_LogMgr = RequireDbBox("LogMgrDB")  
  local res1 = EquipMgrDB.SelectEquipIntensifyInfo(uEquipId)
	if res1:GetRowNum() > 0 then
		g_LogMgr.SaveEquipIntensifyInfo( uCharID, res1)
	end
	local res2 = EquipMgrDB.SelectEquipIntensifyAddAttrInfo(uEquipId)
	if res2:GetRowNum() > 0 then
		g_LogMgr.SaveEquipIntensifyInfoAddAttr( uCharID, res2)
	end

    local EquipSuperaddDB = RequireDbBox("EquipSuperaddDB")
    local equipSuperaddInfo =  EquipSuperaddDB.GetEquipSuperaddInfo(uEquipId)
	local newEquipAddAttrInfoTbl = EquipIntensifyDB.GetEquipAddAttrInfoTbl(uEquipId)
    local newIntensifyInfo = EquipIntensifyDB.GetEquipIntensifyInfoTbl(uEquipId)
	local result = {["EquipType"] = nEquipType, ["EquipName"] = sEquipName, 
	                ["OldEquipInfoTbl"]= oldEquipAddAttrInfoTbl, ["NewEquipInfoTbl"] = newEquipAddAttrInfoTbl,
	                ["EquipPart"]= equipPart, ["EquipID"] = uEquipId, ["RoomIndex"]= nRoomIndex, ["Pos"] = nPos,
	                ["NewIntensifyInfo"] = newIntensifyInfo, ["RoomIndex2"]=nRoomIndex2, ["Pos2"]=nPos2, ["StoneID2"]=stoneID2,
	                ["CurDuraValue"] = curDuraValue, ["MaxDuraValue"] = maxDuraValue,
	                ["EquipSuperaddInfo"] = equipSuperaddInfo}
    return true, tbl_item_id(1,1), result
end

--��ʹ�õ�С����ʯ��Ϣ��{���õ�װ���ȼ�������ʯ����}
local EquipIntenBackNeedItemTbl = {}
local function  ReadEquipIntenBackItemInfo()
    local keys = EquipIntensifyBackItem_Common:GetKeys()
    for i,v in pairs(keys) do
        local itemName = v
        local useType =  EquipIntensifyBackItem_Common(itemName, "UseType")
        if useType == 2 then --С����ʯ
            local adaptedEquipLevel = EquipIntensifyBackItem_Common(itemName, "EquipLevel")
            table.insert(EquipIntenBackNeedItemTbl , {adaptedEquipLevel, itemName})
        end
    end
    table.sort(EquipIntenBackNeedItemTbl, function(a, b) return (a[1] < b[1])end)
end
ReadEquipIntenBackItemInfo()

local function GetIntensifyBackStoneInfo(charID, equipBaseLevel)
    local backStoneType = g_ItemInfoMgr:GetEquipIntensifyBackItem()
    local consumeItem
    local g_RoomMgr = RequireDbBox("GasRoomMgrDB")
    for i, v in pairs(EquipIntenBackNeedItemTbl) do
        local adpatedEquipLevel = v[1]
        local backStoneName = v[2]
        if adpatedEquipLevel >= equipBaseLevel then
            local consumeItemType, consumeItemName = backStoneType, backStoneName
            local consumeItem = g_RoomMgr.GetNCountItemIdByName(charID, consumeItemType, consumeItemName, 1)
            if consumeItem:GetRowNum() > 0 then
               return  consumeItem
            end
        end
    end
    return consumeItem
end

local StmtDef = {
    "_SelectEquipIntenInfoForIntenBack",
    [[
        select iei_uIntensifyBackTimes, iei_uIntensifyBackState, iei_uPreAddAttrValue1, iei_uPreAddAttrValue2,
            iei_uPreAddAttr1, iei_uPreAddAttr2, iei_uIntensifyPhase, iei_uIntensifySoulNum, iei_sSuitName
        from tbl_item_equip_intensify
        where is_uId = ?
    ]]
}
DefineSql(StmtDef, EquipMgr)

local StmtDef = {
    "_UpdateEquipIntenForIntenBackBeforePhase4",
    [[
        update tbl_item_equip_intensify set iei_uAddAttr1 = ?, iei_uAddAttrValue1 = ?, iei_uAddAttr2 = ?, iei_uAddAttrValue2 = ?,
        iei_uIntensifyPhase = iei_uIntensifyPhase -1,  iei_uIntensifySoulNum = 0, iei_sSuitName = "", 
        iei_uIntensifyBackState = 0, iei_uIntensifyBackTimes = iei_uIntensifyBackTimes + 1, iei_uIntenTalentIndex = 0
        where is_uId = ?
    ]]
}DefineSql(StmtDef, EquipMgr)

local StmtDef = {
    "_UpdateEquipBaseIntenInfoForInteBackAfterPhase3",
    [[
        update tbl_item_equip_intensify 
        set iei_uIntensifyBackState = 0, iei_uIntensifyPhase = iei_uIntensifyPhase - 1, iei_uIntensifySoulNum = 0, iei_uIntensifyBackTimes = iei_uIntensifyBackTimes + 1
        where is_uId = ?
    ]]
}DefineSql(StmtDef, EquipMgr)

local StmtDef = {
    "_InitIntensifyBackTimes",
    [[
        update tbl_item_equip_intensify set iei_uIntensifyBackTimes = 0 where is_uId = ?
    ]]
}
DefineSql(StmtDef, EquipMgr)

--װ��ǿ��ϴ��---
function EquipIntensifyDB.EquipIntensifyBack(data)
	local equipType = data["EquipType"]
	local equipName = data["EquipName"]
	local equipID	  = data["EquipID"]
	local charID 		= data["CharID"]
	local sceneName = data["sceneName"]
	local equipPart = data["EquipPart"]
	local g_LogMgr = RequireDbBox("LogMgrDB")
	local uEventId = g_LogMgr.SaveEquipIntensifyBackInfo( charID )
	local g_RoomMgr = RequireDbBox("GasRoomMgrDB")
	local itemType, itemName = g_RoomMgr.GetItemType(equipID)
	if itemType == nil or itemName == nil or itemName ~= equipName then
		return false, 180004
	end
	
	local addAttrRet = EquipMgr._SelectEquipIntenInfoForIntenBack:ExecStat(equipID)
    local OldEquipRetTbl = {}
    OldEquipRetTbl["IntensifyInfo"]  = EquipIntensifyDB.GetEquipIntensifyInfoTbl(equipID)
    OldEquipRetTbl["IntensifyAddInfo"] = EquipIntensifyDB.GetEquipAddAttrInfoTbl(equipID)
    if addAttrRet:GetRowNum() < 1 then
        return false, 180003
    end
	local intensifyPhaseNum = addAttrRet:GetDataByName(0,  "iei_uIntensifyPhase") or 0
	local intensifyBackState = addAttrRet:GetDataByName(0, "iei_uIntensifyBackState")
	local intensifySoulNum = addAttrRet:GetDataByName(0, "iei_uIntensifySoulNum")
	local intensifyBackTimes = addAttrRet:GetDataByName(0, "iei_uIntensifyBackTimes")

	if intensifyBackState == 0 then
	    return false, 180003
	end
	
	if intensifyBackTimes == nil then
	    EquipMgr._InitIntensifyBackTimes:ExecStat(equipID)
        if g_DbChannelMgr:LastAffectedRowNum() < 1 then
	        CancelTran()
    		return false, 180001
        end
	end

	local preAddAttr1Name = addAttrRet:GetDataByName(0, "iei_uPreAddAttr1") 
	local preAddAttr1Value = addAttrRet:GetDataByName(0, "iei_uPreAddAttrValue1")
	local preAddAttr2Name = addAttrRet:GetDataByName(0, "iei_uPreAddAttr2")
	local preAddAttr2Value = addAttrRet:GetDataByName(0, "iei_uPreAddAttrValue2")

	local itemSuitName = addAttrRet:GetDataByName(0, "iei_sSuitName")  --��װ����	
    local suc, suitAttrTbl, includingPartsCount
	if itemSuitName ~= "" and intensifyPhaseNum == 3 then   --ֻ����3�׶�����װ��ʱ����ȥ����װ����
	    suc, suitAttrTbl, includingPartsCount = EquipIntensifyDB.GetSuitAttributeBySuitName(charID, itemSuitName)
	end
	
	if intensifyPhaseNum <= 3 then
		EquipMgr._UpdateEquipIntenForIntenBackBeforePhase4:ExecStat(preAddAttr1Name or "", preAddAttr1Value or 0, preAddAttr2Name or "", preAddAttr2Value or 0, equipID)
        if g_DbChannelMgr:LastAffectedRowNum() < 1 then
    		CancelTran()
    		return false, 180001
	    end
	    
	elseif intensifyPhaseNum >= 4 then
	    local upSqlStr = "update  tbl_item_equip_intensifyAddAttr set " 
	    upSqlStr = upSqlStr .. "iei_sAddAttr" .. intensifyPhaseNum .. "= '', " ..  "iei_uAddAttr" .. intensifyPhaseNum .. "Value = 0 where is_uId = "  .. equipID
        g_DbChannelMgr:TextExecute(upSqlStr)
    	if g_DbChannelMgr:LastAffectedRowNum() < 1 then
    		CancelTran()
    		return false, 180001
    	end
    	EquipMgr._UpdateEquipBaseIntenInfoForInteBackAfterPhase3:ExecStat(equipID)
    	if g_DbChannelMgr:LastAffectedRowNum() < 1 then
    		CancelTran()
    		return false, 180001
    	end
    end
	
    local tbl_name, keyStr  = EquipIntensifyDB.GetSqlKeyInfoByEquipType(itemType)
	local attrLevel, equipBaseLevel= GetEquipBaseInfoForIntensify(keyStr, tbl_name, equipID)
	
	local consumeItem = GetIntensifyBackStoneInfo(charID, equipBaseLevel)
	if consumeItem == nil then
	    CancelTran()
		return false, 180002
	end

	local consumeItemID = consumeItem(1,1)
	if consumeItemID == nil then
	    CancelTran()
		return false, 180002
	end
	local ret1 = g_RoomMgr.DelItemByID(charID,consumeItemID,nil,uEventId)
	if (not ret1) then
		CancelTran()
		return false, 180001
	end
	--���½�ɫ���ϵĻ�ֵ
	local param = {["soulCount"] = intensifySoulNum,["PlayerId"] = charID,["eventId"] = uEventId}
	local _,total_soul = EquipMgrDB.ModifyPlayerSoul(param)
	if itemSuitName ~= "" and itemSuitName then
	    local _,_, includingPartsCountAfter = EquipIntensifyDB.GetSuitAttributeBySuitName(charID, itemSuitName)
	    if includingPartsCountAfter == includingPartsCount then
            suitAttrTbl = {}
            includingPartsCount = 0 
	    end
	end
	local newEquipRetTbl = {}
	newEquipRetTbl["IntensifyInfo"]  = EquipIntensifyDB.GetEquipIntensifyInfoTbl(equipID)
    newEquipRetTbl["IntensifyAddInfo"] = EquipIntensifyDB.GetEquipAddAttrInfoTbl(equipID)
    local equipDuraState, curDuraValue, maxDuraValue 
    if equipPart ~= 0 then
        local EquipDurabilityDB = RequireDbBox("EquipDurabilityDB")
        equipDuraState, curDuraValue, maxDuraValue = EquipDurabilityDB.GetEquipUllageState(equipID)
    end
    
  local res = EquipMgrDB.SelectEquipIntensifyInfo(equipID)
	if res:GetRowNum() > 0 then
		g_LogMgr.SaveEquipIntensifyInfo( charID, res,uEventId)
	end
	if intensifyPhaseNum >= 4 then
		local res = EquipMgrDB.SelectEquipIntensifyAddAttrInfo(equipID)
		if res:GetRowNum() > 0 then
			g_LogMgr.SaveEquipIntensifyInfoAddAttr( charID, res,uEventId)
		end
	end
	
    local EquipSuperaddDB = RequireDbBox("EquipSuperaddDB")
    local equipSuperaddInfo =  EquipSuperaddDB.GetEquipSuperaddInfo(equipID)
	local result = {["RoomIndex"] = consumeItem(1,2), ["Pos"] = consumeItem(1,3), ["ItemID"] = consumeItem(1,1), ["EquipRetTbl"] = newEquipRetTbl,
	                ["EquipBaseLevel"]=equipBaseLevel, ["OldEquipRetTbl"]= OldEquipRetTbl, ["SuitName"] =itemSuitName, ["SuitAttrTbl"] =suitAttrTbl , ["IncludingPartsCount"]=includingPartsCount,
	                ["IntensifyPhaseNum"] =intensifyPhaseNum, ["EquipType"] = equipType, ["EquipName"]=equipName , ["EquipPart"]=equipPart,
	                ["EquipID"] =equipID,["CurDuraValue"] = curDuraValue, ["MaxDuraValue"] = maxDuraValue,
	                ["EquipSuperaddInfo"] = equipSuperaddInfo}
	return true, 180000, result,total_soul
end

--��ѯװ��ǿ����Ϣ
local StmtDef = {
	"_GetEquipIntensifyInfo",
	[[ select iei_uIntensifySoulNum, iei_uAddAttr1, iei_uAddAttrValue1, 
	            iei_uAddAttr2, iei_uAddAttrValue2, iei_uIntensifyPhase,
	      iei_sSuitName, iei_uIntensifyTimes, iei_uIntensifyBackTimes, iei_uIntenTalentIndex  from tbl_item_equip_intensify where is_uId = ?]] 
}
DefineSql(StmtDef, EquipMgr)

----��ѯװ��ǿ�������Ϣ
function EquipIntensifyDB.GetEquipIntensifyInfoTbl(equipID)
    local execRet = EquipMgr._GetEquipIntensifyInfo:ExecStat(equipID)
    return execRet
end

local StmtDef ={
    "_GetEquipIntensifyAddInfo",
    [[
        select 
            iei_sAddAttr4, iei_uAddAttr4Value,iei_sAddAttr5, iei_uAddAttr5Value
            ,iei_sAddAttr6, iei_uAddAttr6Value,iei_sAddAttr7, iei_uAddAttr7Value,
            iei_sAddAttr8, iei_uAddAttr8Value, iei_sAddAttr9, iei_uAddAttr9Value
        from tbl_item_equip_intensifyAddAttr
        where is_uId = ?
    ]]
}
DefineSql(StmtDef, EquipMgr)

--�õ�װ���ĸ������������Ϣ��װ��ǿ��4~9�׶β��������ԺͶ�Ӧ��ֵ��
function EquipIntensifyDB.GetEquipAddAttrInfoTbl(uEquipId)  
    local equipAddAttrInfoRet = EquipMgr._GetEquipIntensifyAddInfo:ExecStat(uEquipId)
	return equipAddAttrInfoRet
end

--����װ�����͵õ�װ��
local function GetIntenEquipPart(equipType,item_name)
    if equipType == tblEquipType["Weapon"] then
    	local nEquipType = g_ItemInfoMgr:GetItemInfo(equipType,item_name,"EquipType")
        local part = string.sub(nEquipType, 1, 4)
        return part
    elseif equipType == tblEquipType["Armor"] or 
        equipType == tblEquipType["Jewelry"] then
        local nEquipPart = g_ItemInfoMgr:GetItemInfo(equipType,item_name,"EquipPart")	
        return nEquipPart
    elseif equipType == tblEquipType["Shield"] then
    	local nEquipType = g_ItemInfoMgr:GetItemInfo(equipType,item_name,"EquipType")
        return nEquipType
    elseif equipType == tblEquipType["Ring"] then
        return "��ָ"
    end
end

local function GetAttrValueInntenPhaseTwo(addAttrRateArithmetic, equipLevelType, equipPart, soulRoot, equipLevel)   
    --local addAttrRateArithmetic = involvingInfoTbl["EvolvingStep2"]	--��������1�͸�������2ֵ�ı����㷨
	local z2Value = GetEquipZValueByLevel(equipLevel, SoulEvolvingPhase[2])
	local x2 = math.ceil(z2Value/4 * 3) 
	local y2 = z2Value - x2
	if SoulEvolvingInfoTbl[addAttrRateArithmetic] == nil then
	    local  func = GetAddAttr1ValuefuncPhase2(addAttrRateArithmetic)
	    SoulEvolvingInfoTbl[addAttrRateArithmetic] = func
	end
	local  method = SoulEvolvingInfoTbl[addAttrRateArithmetic]
	local addAttrRate = GetSoulEvlovingAttrRate(equipLevelType, equipPart, soulRoot)
	x2, y2  = method(x2, y2)
	if x2 < 1 then
		x2, y2  = method(0, z2Value)
	elseif y2 < 1 then
		x2, y2  = method(z2Value, 0)
	end
	x2, y2  = tonumber(string.format("%.0f", x2))* tonumber(addAttrRate), tonumber(string.format("%.0f",y2))*tonumber(addAttrRate)
    return x2, y2
end

local function ToolIntensifyEuqipPhaseTwo( addAttr1NameTbl,  equipLevelType, equipLevel, equipPart, soulRoot )
	local addAttr2InfoTbl = {}
	local levelTypeStr = tostring(equipLevelType)
	for j=1, # addAttr1NameTbl do
	    local addAttr1Name = addAttr1NameTbl[j]
	    local addAttr2NameTbl = SoulEvolving_Common:GetKeys(levelTypeStr, soulRoot, addAttr1Name)
        for i=1, # addAttr2NameTbl do
            local addAttr2Name = addAttr2NameTbl[i]
            local methodStr = SoulEvolving_Common(levelTypeStr, soulRoot, addAttr1Name, addAttr2Name, "EvolvingStep2")
            local x2, y2 = GetAttrValueInntenPhaseTwo(methodStr, equipLevelType, equipPart, soulRoot, equipLevel)
		    table.insert(addAttr2InfoTbl, {addAttr1Name, addAttr2Name, x2, y2})
	    end
    end
    
	return addAttr2InfoTbl
end

local function ToolIntensifyGetSuitName(suitCfgTbl, equipCurLevel, equipPart, addAttrInfoTbl)
	local equipPartStr  = equipPart
	local suitTbl = {}
	for j=1, # addAttrInfoTbl do 
	    local addAttr1,addAttr2 = addAttrInfoTbl[j][1], addAttrInfoTbl[j][2]
	    local addAttr1Value,  addAttr2Value= addAttrInfoTbl[j][3], addAttrInfoTbl[j][4]
	    local suitTypeKeys = suitCfgTbl:GetKeys(tostring(equipCurLevel), addAttr1, addAttr2, equipPartStr)    
    	for i, v in pairs(suitTypeKeys) do  
            local suitStr = tostring(v)
            local suitTypeTbl = EquipSuitOutScale_Server:GetKeys()
            for w, j in pairs(suitTypeTbl) do
                local suitTypeName = j
                if suitTypeName ~= "None" then
                    local suitName = suitCfgTbl(tostring(equipCurLevel), addAttr1, addAttr2, equipPartStr, suitStr, suitTypeName) 
                    if suitName ~= "" then
                        local addAttrRate = EquipSuitOutScale_Server(suitTypeName,"SuitQuotiety")
                        local suitInfoTbl = {addAttr1, addAttr2, addAttr1Value*addAttrRate, addAttr2Value*addAttrRate}
                        suitTbl[suitName] = suitInfoTbl
                    end  
                end                          			
			end
    	end
    end
    return suitTbl
end

local StmtDef = 
{
    "_UpdateEquipIntenInfo",
    [[
        insert tbl_item_equip_intensify set iei_uPreAddAttr1=?, iei_uPreAddAttrValue1=?, iei_uPreAddAttr2=?, iei_uPreAddAttrValue2=?,
        iei_uAddAttr1=?, iei_uAddAttrValue1=?, iei_uAddAttr2=?, iei_uAddAttrValue2=?, iei_sSuitName=?,
        iei_uIntensifyPhase = 3, iei_uIntenTalentIndex =?, is_uId = ?
    ]]
}
DefineSql(StmtDef, EquipMgr)

--����װ�����ͺ�װ�����Ʋ���װ���������Ѿ�ǿ��������װ���Ͷ�Ӧ��ǿ������
--���ڲ��Լ����װ��ص���Ϣ
function EquipIntensifyDB.AddIntenEquip(data)
    local charID    =   data["CharID"]
    local equipType =   data["EquipType"]
    local equipName =   data["EquipName"]
    local suitName  =   data["SuitName"]
    local sceneName =   data["SceneName"]
    local index     =   data["Index"]
    
    local result    = {}
    
    if not g_ItemInfoMgr:IsStaticEquip(equipType)  then
        result["MsgID"]  = 180034
        return false, result
    end
    
    local itemInfo = g_ItemInfoMgr:GetItemFunInfo(equipType, equipName)
    if itemInfo == nil then
        result["MsgID"]  = 180034
        return false, result
    end
    
    local IsUpIntensify  = g_ItemInfoMgr:GetItemInfo(equipType, equipName,"IsUpIntensify")
 
    if suitName == "" then
        result["MsgID"] = 180020
        return false, result
    end
    if tonumber(IsUpIntensify) ~= 1 then
		result["MsgID"] = 180021
		return false,result
	end
	local attrLevel = g_ItemInfoMgr:GetItemInfo(equipType, equipName,"AttrLevel")
    local baseLevel = g_ItemInfoMgr:GetItemInfo(equipType, equipName,"BaseLevel")
    local curLevelNo =  GetEquipLevelType(baseLevel)
    local equipPartInInten = GetIntenEquipPart(equipType,equipName)
    --[[  
    if equipPartInInten == "����" then
       result["MsgID"] = 180017
       return false,  result
    end
    --]]
    local SoulRoot = g_ItemInfoMgr:GetItemInfo(equipType, equipName,"SoulRoot")
    local addAttr1NameTbl= {}
    local levelStr = tostring(curLevelNo)
    local defaultKeys = EquipSoulAttr_Common:GetKeys(levelStr, SoulRoot, equipPartInInten) 
    for i, v in pairs( defaultKeys ) do
        local key = v
        local soulAttr = EquipSoulAttr_Common(levelStr, SoulRoot, equipPartInInten, key, "SoulAttr")
    	table.insert(addAttr1NameTbl, soulAttr)		
    end
    
    
    local addAttrInfoTbl = ToolIntensifyEuqipPhaseTwo(addAttr1NameTbl, curLevelNo, attrLevel, equipPartInInten, SoulRoot)
    
    local suitCfgTbl = {}
	if SoulRoot == PearlSoulRoot[1] then 		--����Ǿ�ս��
		suitCfgTbl = ArmyWarSuit_Common
		
	elseif SoulRoot == PearlSoulRoot[2] then 	--����Ǿ�����
		suitCfgTbl = ArmyActSuit_Common
		
	elseif SoulRoot == PearlSoulRoot[3] then 	--����Ƿ�ħ��
		suitCfgTbl = MagicActSuit_Common
		
	elseif SoulRoot == PearlSoulRoot[4] then 	--�����ս���
		suitCfgTbl = GodWartSuit_Common
	end
	local suitInfoTbl = ToolIntensifyGetSuitName(suitCfgTbl, curLevelNo, equipPartInInten, addAttrInfoTbl ) 
	
	if suitInfoTbl[suitName] == nil then
	    result["MsgID"] = 180018
	    return false, result
	end
	
	local params= {}
	params.nCharID = charID
	params.nStoreMain = index
	params.nBigID = equipType
	params.nIndex = equipName
	params.nCount = 1
	params.BindingType = g_ItemInfoMgr:GetItemInfo(equipType, equipName,"BindingStyle")
	params.sceneName = sceneName
	params.createType = event_type_tbl["GM�����Ʒ"]
	params.uEventId = uEventId
	local g_RoomMgr     =   RequireDbBox("GasRoomMgrDB")
	local res = g_RoomMgr.AddItem(params)
	if tonumber(res) then
	   result["MsgID"] = 180023
	   return false, result
	end
	
	local equipID, roomIndex, pos
	
	for j=1,#res[1] do
		local nItemID = res[1][j]
		equipID =nItemID
		roomIndex = res[1].m_nRoomIndex
		pos = res[1].m_nPos		
    end
	local addTalentOrSkillIndex = EquipMgrDB.GetAddTalentOrSkillIndex()
	
	local preAddAttr1, preAddAttr1Value, preAddAttr2, preAddAttr2Value=suitInfoTbl[suitName][1], suitInfoTbl[suitName][3],suitInfoTbl[suitName][2],suitInfoTbl[suitName][4]
	local addAttr1, addAddAttr1Value, addAttr2, addAttr2Value = preAddAttr1, preAddAttr1Value, preAddAttr2, preAddAttr2Value
	EquipMgr._UpdateEquipIntenInfo:ExecStat(preAddAttr1, preAddAttr1Value, preAddAttr2, preAddAttr2Value,addAttr1, addAddAttr1Value, addAttr2, addAttr2Value, suitName, addTalentOrSkillIndex, equipID)
	if g_DbChannelMgr:LastAffectedRowNum() < 1 then
		CancelTran()
		result["MsgID"] = 180019
		return false, result
	end
	local res = EquipMgrDB.SelectEquipIntensifyInfo(uItemId)
	if res:GetRowNum() > 0 then
		local g_LogMgr = RequireDbBox("LogMgrDB")
		g_LogMgr.SaveEquipIntensifyInfo( charID, res)
	end
	local equipInfo =EquipMgrDB.GetEquipAllInfo(equipID)
	result["EquipID"] = equipID
	result["EquipType"] = equipType
	result["EquipName"] = equipName
	result["EquipInfo"] = equipInfo
	result["RoomIndex"] = roomIndex
	result["Pos"]       = pos
	result["BindingType"] = g_ItemInfoMgr:GetItemInfo(equipType, equipName,"BindingStyle")
	return  true, result
end 


local StmtDef = {
    "GetEquipIntensifPhase",
    [[
        select iei_uIntensifyPhase from tbl_item_equip_intensify where is_uId  = ?    
    ]]
}
DefineSql(StmtDef, EquipMgr)


--����ǿ����װ������Ϊδǿ��״̬
local StmtDef = 
{
    "_DeleteEquipIntenInfo",
    [[
        delete from tbl_item_equip_intensify where is_uId = ?  
    ]]
}
DefineSql(StmtDef, EquipMgr)


function EquipIntensifyDB.UseEquipIntenBackItem(data)
    local charID    =   data["CharID"]
    local equipID   =   data["EquipID"]
    local equipPart =   data["EquipPart"]
    local roomIndex =   data["RoomIndex"]
    local pos       =   data["Pos"]
    local backItemType= data["IntenBackItemType"]
    local backItemName= data["IntenBackItemName"]
    local sceneName =   data["SceneName"]
    
    if g_ItemInfoMgr:IsEquipIntenBackItem(backItemType) == false then
        return false, 180025
    end
    local g_RoomMgr     =   RequireDbBox("GasRoomMgrDB")
	local equipType, equipName 	= 	g_RoomMgr.GetItemType(equipID)
    if g_ItemInfoMgr:IsStaticEquip(equipType) == false then
       return  false, 180026
    end    
    local nEquipPart = EquipMgrDB.GetEquipPartById(charID,equipID)
    if equipPart ~= nEquipPart then
        return false, 180027 
    end
    local equipIntenBackItemType, equipIntenBackItemName, count = g_RoomMgr.GetTypeCountByPosition(charID, roomIndex, pos)
    if  equipIntenBackItemType ~= backItemType or equipIntenBackItemName ~= backItemName then
        return false, 180028 
    end
    
    local backItemInfo = g_ItemInfoMgr:GetItemFunInfo(backItemType, backItemName)
    if backItemInfo("UseType") ~= 1 then --�Ҽ���ʹ�õ�����ʯ
        return false, 180025
    end
    
    local tbl_name, keyStr  = EquipIntensifyDB.GetSqlKeyInfoByEquipType(equipType)
	local attrLevel, equipBaseLevel = GetEquipBaseInfoForIntensify(keyStr, tbl_name, equipID)
    
    if backItemInfo("EquipLevel") < equipBaseLevel then
         return false, 180029
    end
    
    local equipIntensifyPhaseRet = EquipMgr.GetEquipIntensifPhase:ExecStat(equipID)
    if equipIntensifyPhaseRet:GetRowNum() < 1 then
        return false, 180030 
    end
    
    local equipIntenPhase = equipIntensifyPhaseRet:GetData(0,0 ) or 0
    if equipIntenPhase == 0 then
        return false, 180030 
    end
    
    local oldEquipRetTbl = {}
	oldEquipRetTbl["IntensifyInfo"]  = EquipIntensifyDB.GetEquipIntensifyInfoTbl(equipID)
    oldEquipRetTbl["IntensifyAddInfo"] = EquipIntensifyDB.GetEquipAddAttrInfoTbl(equipID)
    
    local suitName = oldEquipRetTbl["IntensifyInfo"]:GetDataByName(0, "iei_sSuitName")  --��װ����	
    local suc, suitAttrTbl, includingPartsCount
	if suitName ~= "" and equipIntenPhase >= 3 then   --ֻ����3�׶�����װ��ʱ����ȥ����װ����
	    suc, suitAttrTbl, includingPartsCount = EquipIntensifyDB.GetSuitAttributeBySuitName(charID, suitName)
	end
    
    EquipMgr._DeleteEquipIntenInfo:ExecStat(equipID) --ɾ��ǿ�����Ե�ʱ������ɾ��װ��ǿ����������
    if g_DbChannelMgr:LastAffectedRowNum() < 1 then
        CancelTran()
		return false, 180031
    end
  local g_LogMgr = RequireDbBox("LogMgrDB")
  local uEventId = g_LogMgr.SaveEquipIntensifyBackInfo( charID )
	g_LogMgr.SaveEquipIntensifyInfo( charID, equipID,uEventId)
	g_LogMgr.SaveEquipIntensifyInfoAddAttr( charID,equipID,uEventId)
	
    local equipIntenBackItemID = g_RoomMgr.GetAllItemFromPosition(charID, roomIndex, pos)
    if equipIntenBackItemID:GetRowNum() == 0 then
        CancelTran()
		return false, 180028
    end

    if g_RoomMgr.DelItemByID( charID, equipIntenBackItemID(1,1),event_type_tbl["��Ʒʹ��"]) == false then
		CancelTran()
		return false, 180032
	end
	
    local newEquipRetTbl = {}
	newEquipRetTbl["IntensifyInfo"]  = EquipIntensifyDB.GetEquipIntensifyInfoTbl(equipID)
    newEquipRetTbl["IntensifyAddInfo"] = EquipIntensifyDB.GetEquipAddAttrInfoTbl(equipID)
    
    local equipDuraState, curDuraValue, maxDuraValue 
    if equipPart ~= 0 then
        local EquipDurabilityDB = RequireDbBox("EquipDurabilityDB")
        equipDuraState, curDuraValue, maxDuraValue = EquipDurabilityDB.GetEquipUllageState(equipID)
    end
    local EquipSuperaddDB = RequireDbBox("EquipSuperaddDB")
    local equipSuperaddInfo =  EquipSuperaddDB.GetEquipSuperaddInfo(equipID)
    
    if suitName ~= "" and suitName then
        local _,_, includingPartsCountAfter = EquipIntensifyDB.GetSuitAttributeBySuitName(charID, suitName)
	    if includingPartsCountAfter == includingPartsCount then
            suitAttrTbl = {}
            includingPartsCount = 0 
	    end
	end
    local para ={}
    para["uCharID"] =charID
    local total_soul = EquipMgrDB.GetPlayerSoulNum(para)
    local result = {}
    result["EquipPart"] = equipPart
    result["OldEquipRetTbl"] = oldEquipRetTbl
    result["EquipRetTbl"] = newEquipRetTbl
    result["RoomIndex"] = roomIndex
    result["Pos"] = pos
    result["EquipID"] = equipID
    result["ItemID"] = equipIntenBackItemID(1,1)
	result["EquipBaseLevel"] = equipBaseLevel
	result["SuitName"] = suitName
	result["IntensifyPhaseNum"] =equipIntenPhase
	result["EquipType"] = equipType
	result["EquipName"]= equipName
	result["CurDuraValue"] = curDuraValue
	result["MaxDuraValue"] = maxDuraValue
	result["SuitAttrTbl"] =suitAttrTbl 
	result["IncludingPartsCount"]=includingPartsCount
	result["EquipSuperaddInfo"] = equipSuperaddInfo
	result["IntenBackUseStone"] = true
	return true, result, total_soul
end

SetDbLocalFuncType(EquipIntensifyDB.EquipIntensify)
SetDbLocalFuncType(EquipIntensifyDB.EquipIntensifyBack)
SetDbLocalFuncType(EquipIntensifyDB.EquipIntensifyUseStone)
SetDbLocalFuncType(EquipIntensifyDB.UseEquipIntenBackItem)


return EquipIntensifyDB



