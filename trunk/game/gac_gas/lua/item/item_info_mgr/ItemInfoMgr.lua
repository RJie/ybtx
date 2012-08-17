cfg_load "equip/HandType_Common"
cfg_load "item/SoulPearlLimitType_Common"
gac_gas_require "item/item_info_mgr/ItemInfoMgrInc"
gac_gas_require "item/Equip/EquipDef"

engine_require "common/Misc/TypeCheck"
gac_gas_require	"framework/common/GlobalRequires"
cfg_load "equip/StaticWeaponType_Common"
lan_load "item/Lan_ItemType_Common"


--����ṹ���˱����������û��ID����ֻ��
local Type2BigID = {
	["Material"]       = 1,
	["PlayerBay"]      = 2,
	["SkillItem"]      = 3,
	["StaticWeapon"]   = 5,
	["StaticArmor"]    = 6,
	["StaticShield"]   = 7,
	["StaticJewelry"]  = 8,
	["FortifiedStone"] = 14,
	["AssistantStone"] = 15,
}

--У����Ʒ�����Ƿ�Ϸ�
function CItemInfoMgr:IsValid(itemType)
	local nBigID = str_or_num_to_num(itemType)
	if(nBigID >= 1 and nBigID <= self.m_tblId2Table[nBigID] ~= nil ) then
		return true
	end
	return false
end

function CItemInfoMgr:CheckType(itemType,nIndex)
	local nBigID = str_or_num_to_num(itemType)
	if self:IsSoulPearl(itemType) then
		nIndex = self:GetSoulpearlInfo(nIndex)
	end
	if self.m_tblId2Table[nBigID] == nil or self.m_tblId2Table[nBigID](nIndex) == nil then
		return false
	end

	return true
end

function CItemInfoMgr:GetBasicItemBigID()
	return 1
end

--��ñ������͵�id
function CItemInfoMgr:GetPlayerBagBigID()
	return 2
end

--��ü�����Ʒ����id
function CItemInfoMgr:GetSkillItemBigID()
	return 3
end

--����������͵�id
function CItemInfoMgr:GetStaticWeaponBigID()
	return 5
end

--��÷������͵�id
function CItemInfoMgr:GetStaticArmorBigID()
	return 6
end

--��ð������͵�id
function CItemInfoMgr:GetStaticShieldBigID()
	return 7
end

--��ý�ָ���͵�id
function CItemInfoMgr:GetStaticRingBigID()
	return 8
end

--�����Ʒ���͵�id
function CItemInfoMgr:GetStaticJewelryBigID()
	return 9
end

function CItemInfoMgr:GetTongItemBigID()
	return 10
end

--��ñ�ʯ����id
function CItemInfoMgr:GetStoneBigID()
	return 14
end

--��ô�ײ�������id
function CItemInfoMgr:GetHoleMaterialBigID()
	return 15
end

--���������Ʒ����id
function CItemInfoMgr:GetQuestItemBigID()
	return 16
end

--����ʼ���������id
function CItemInfoMgr:GetMailBigID()
	return 17
end

--��ðױ�ʯ����id
function CItemInfoMgr:GetWhiteStoneBigID()
	return 18
end

--��û�������id
function CItemInfoMgr:GetSoulPearlBigID()
	return 19
end

--��ð��������Ʒ����id
function CItemInfoMgr:GetTongSmeltItemBigID()
	return 23
end

--��ú�����Ʒ����id
function CItemInfoMgr:GetBoxItemBigID()
	return 24
end


function CItemInfoMgr:GetEmbryoItemBigID()
	return 27
end

function CItemInfoMgr:GetQualityMaterialItemBigID()
	return 28
end

--����ı���Ʒ����id
function CItemInfoMgr:GetTextItemBigID()
	return 25
end

--�����������id
function CItemInfoMgr:GetBattleArrayBooksBigID()
	return 26
end

--��ö�������̥����id
function CItemInfoMgr:GetEmbryoBigID()
	return 27
end

--��ö�����Ʒ�ʲ�������id
function CItemInfoMgr:GetQualityMaterialBigID()
	return 28
end

function CItemInfoMgr:GetOreAreaBigID()
    return 30
end

--���װ����������id
function CItemInfoMgr:GetEquipIdentifyScrollBigID()
	return 31
end

function CItemInfoMgr:GetFlowersBigID()
    return 32
end


--��û���Ƭid
function CItemInfoMgr:GetArmorPieceBigID()
	return 34
end

function CItemInfoMgr:GetMercCardItemBigID()
    return 37
end

--��ý���ʯID
function CItemInfoMgr:GetAdvanceStoneBigID()
	return 38
end

--���С����ID
function CItemInfoMgr:GetCreateNpcItemBigID()
    return 40
end

--��û��޵�id
function CItemInfoMgr:GetPetEggBigID()
	return 41
end
--�Ƿ�Ϊ���޵�
function CItemInfoMgr:IsPetSkillStone(nBigID)
	return 42 == str_or_num_to_num(nBigID)
end

--��û�����ʯid
function CItemInfoMgr:GetPetSkillStoneBigID()
	return 42
end
--�Ƿ�Ϊ������ʯ
function CItemInfoMgr:IsPetEgg(nBigID)
	return 41 == str_or_num_to_num(nBigID)
end


function CItemInfoMgr:GetMathGameItemBigID()
    return 46
end
--�Ƿ�Ϊװ��
function CItemInfoMgr:IsEquip(nBigID)
	return self:IsStaticEquip(nBigID)
end

--�Ƿ�Ϊ��ָ
function CItemInfoMgr:IsEquipNotJewelry(nBigID)
	return self:IsStaticEquipNotJewelry(nBigID)
end

--�Ƿ�̬װ��
function CItemInfoMgr:IsWeapon(nBigID)
	return self:IsStaticWeapon(nBigID)
end

--�ж��Ƿ�Ϊ����
function CItemInfoMgr:IsArmor(nBigID)
	return self:IsStaticArmor(nBigID)
end

function CItemInfoMgr:IsAssociateWeapon(nBigID)
	return self:IsStaticShield(nBigID)
end

--�Ƿ�����Ʒ
function CItemInfoMgr:IsJewelry(nBigID)
	return self:IsStaticJewelry(nBigID)
end

--�Ƿ���װ������ʯ
function CItemInfoMgr:IsEquipRefineItem(nBigID)
    return 49 == str_or_num_to_num(nBigID)
end

function CItemInfoMgr:IsEquipSuperaddItem(nBigID)
    return 50 == str_or_num_to_num(nBigID)
end


--************************************************************************
--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--��̬װ������������Ʒ
function CItemInfoMgr:IsStaticEquipNotJewelry(itemType)
	local nBigID = str_or_num_to_num(itemType)
	return nBigID >= 5 and nBigID <= 7
end

--�Ƿ�����ұ���
function CItemInfoMgr:IsPlayerBag(nBigID)
	return 2 == str_or_num_to_num(nBigID)
end

--�Ƿ�Ϊ��Ʒ��������,��������Ʒid
function CItemInfoMgr:IsItemBurstSkill(nBigID)
	return 3 == str_or_num_to_num(nBigID)
end

--�ж��Ƿ�Ϊ����
function CItemInfoMgr:IsStaticWeapon(nBigID)
	return 5 == str_or_num_to_num(nBigID)
end

--�ж��Ƿ�Ϊ����
function CItemInfoMgr:IsStaticArmor(nBigID)
	return 6 == str_or_num_to_num(nBigID)
end

--�ж��Ƿ�Ϊ����
function CItemInfoMgr:IsStaticShield(nBigID)
	return 7 == str_or_num_to_num(nBigID)
end

--�Ƿ��ǽ�ָ
function CItemInfoMgr:IsRing(nBigID)
	return 8 == str_or_num_to_num(nBigID) 
end

--�ж��Ƿ�Ϊ��Ʒ
function CItemInfoMgr:IsStaticJewelry(nBigID)
	return 9 == str_or_num_to_num(nBigID)
end

--�Ƿ��Ǳ�ʯ
function CItemInfoMgr:IsStone(nBigID)
	return 14 == str_or_num_to_num(nBigID)
end

--�Ƿ�Ϊǿ����ʯ
function CItemInfoMgr:IsFortifiedStone(nBigID)
	return 14 == str_or_num_to_num(nBigID)
end

--�Ƿ�Ϊף����ʯ
function CItemInfoMgr:IsAssistantStone(nBigID)
	return 15 == str_or_num_to_num(nBigID)
end

--�ж��Ƿ���������Ʒ��������Ʒ16
function CItemInfoMgr:IsQuestItem(nBigID)
	return 16 == str_or_num_to_num(nBigID)
end

--�ж��Ƿ�Ϊ�ʼ��ı�����
function CItemInfoMgr:IsMailTextAttachment(nBigID)
	return 17 == str_or_num_to_num(nBigID)
end

--�Ƿ�Ϊ��Ʒ��������,��������Ʒid
function CItemInfoMgr:IsWhiteStone(nBigID)
	return 18 == str_or_num_to_num(nBigID)
end

--�Ƿ���ͨ��additem ��gm����ֱ����ӳ�������Ʒ
function CItemInfoMgr:CanAddByAddItemGM(nBigID)
	return 19 ~= str_or_num_to_num(nBigID)
end

--�ж��Ƿ���������Ʒ
function CItemInfoMgr:IsTongSmeltItem(nBigID)
	return 23 == str_or_num_to_num(nBigID)
end

--�ж��Ƿ��Ǻ�����Ʒ
function CItemInfoMgr:IsBoxitem(nBigID)
	return 24 == str_or_num_to_num(nBigID)
end

--�Ƿ����ı���Ʒ
function CItemInfoMgr:IsTextBook(nBigID)
	return 25 == str_or_num_to_num(nBigID)
end

--�Ƿ�������
function CItemInfoMgr:IsBattleArrayBooks(nBigID)
	return 26 == str_or_num_to_num(nBigID)
end

--�Ƿ��Ƕ�����̥
function CItemInfoMgr:IsEmbryoItem(nBigID)
	return 27 == str_or_num_to_num(nBigID)
end

--�Ƿ���Ʒ�ʲ���
function CItemInfoMgr:IsQualityMaterialItem(nBigID)
	return 28 == str_or_num_to_num(nBigID)
end

--�ж��Ƿ��ǿ��ͼ
function CItemInfoMgr:IsOreAreaMap(nBigId)
	return 30 == str_or_num_to_num(nBigId)
end

--�ж��Ƿ���װ����������
function CItemInfoMgr:IsEquipIdentifyScroll(nBigId)
	return 31 == str_or_num_to_num(nBigId)
end

--�ж��Ƿ��ǻ��ܼ�����Ʒ
function CItemInfoMgr:IsCultivateFlowerItem(nBigId)
	return 32 == str_or_num_to_num(nBigId)
end

--�ж��Ƿ��ǰ�Ὠ������
function CItemInfoMgr:IsTongBuildingItem(nBigId)
	return 33 == str_or_num_to_num(nBigId)
end

--�ж��Ƿ��ǻ���Ƭ
function CItemInfoMgr:IsArmorPiece(nBigId)
	return 34 == str_or_num_to_num(nBigId)
end

--�ж��Ƿ��ǽ���ʯ
function CItemInfoMgr:IsAdvanceStone(nBigId)
	return 38 == str_or_num_to_num(nBigId)
end

--�ж��Ƿ��Ǵ�����ʯ
function CItemInfoMgr:IsEquipIntenBackItem(nBigID)
    return 43 == str_or_num_to_num(nBigID)
end

--�ж��Ƿ��ǲɿ󹤾�
function CItemInfoMgr:IsPickOreItem(nBigID)
    return 45 == str_or_num_to_num(nBigID)
end

--�ж��Ƿ����̳Ǳ���
function CItemInfoMgr:IsTurntableItem(nBigID)
    return 47 == str_or_num_to_num(nBigID)
end

function CItemInfoMgr:IsEquipRefineStone(nBigID)
    return 49 == str_or_num_to_num(nBigID)
end

--|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--************************************************************************

function CItemInfoMgr:GetAppendAttrID()
	return 1
end
function CItemInfoMgr:GetSpecialMagicAttrID()
	return 2
end
function CItemInfoMgr:GetAddCountID()
	return 3
end
function CItemInfoMgr:GetChaseCountID()
	return 4
end
function CItemInfoMgr:GetInitEquipID()
	return 5
end

function CItemInfoMgr:GetInitSkillID()
	return 6
end

function CItemInfoMgr:GetEquipRefineStoneType()
    return 49
end

function CItemInfoMgr:GetEquipIntensifyBackItem()
    return 43
end

function CItemInfoMgr:GetEquipSuperaddItem()
    return 50
end

--���صĵڶ��Ľ���ǹ��ں����ʾ����
function CItemInfoMgr:GetItemLifeInfo(nBigID, nIndex)
	if self:IsSoulPearl(nBigID) then
		nIndex = self:GetSoulpearlInfo(nIndex)
	end
	assert(self:HaveItem(nBigID,nIndex), "�ü�ʱ��Ʒ������.����:" .. nBigID .. "����:" .. nIndex)
	local keys = ItemLife_Common:GetKeys()
	for i, key in pairs(keys) do
		local p = ItemLife_Common(key)
		if (tonumber(nBigID) == tonumber(p("ItemType")) and nIndex == p("ItemName")) then
			return p, Lan_ItemLife_Common(MemH64(nIndex),"TimeOutName")
		end
	end
end

function CItemInfoMgr:GetTableByBigID(itemType)
	local nBigID = str_or_num_to_num(itemType)
	assert(IsNumber(nBigID) and nBigID > 0 and self.m_tblId2Table[nBigID] ~= nil)
	return self.m_tblId2Table[nBigID]
end

function CItemInfoMgr:GetNoBigIdTable(nID,nIndex)
	return self.m_tblNoBigId[nID](nIndex)
end

function CItemInfoMgr:GetItemLanInfo(itemType, sName, sCoulmnName)
	if self:IsSoulPearl(itemType) then
		sName = self:GetSoulpearlInfo(sName)
	end
	local tbl = self.m_tblId2LanTable[itemType]
	assert(tbl, "�޷��ҵ�������Ʒ�Ķ�Ӧ���ʻ����Ա�.��Ʒ����:" .. itemType)
	local info = tbl(MemH64(sName))
	assert(info, "��Ʒ��Ϣ�ڶ�Ӧ���ʻ����Ա����޷��ҵ�.��Ʒ����:" .. itemType .. "��Ʒ����:" .. sName)
	local ColumnInfo = info(sCoulmnName)
	if sCoulmnName == "Description" then
		local sDescType = self:GetItemInfo(itemType, sName, "DescType")
		if sDescType and "" ~= sDescType then
			local SpecialColumnInfo = Lan_ItemType_Common(MemH64(sDescType), "DisplayName")
			ColumnInfo = GetStrAccordWildcard(ColumnInfo,SpecialColumnInfo)
		end
	end
	return ColumnInfo or ""
end

function CItemInfoMgr:GetItemLanFunInfo(itemType, sName)
	if self:IsSoulPearl(itemType) then
		sName = self:GetSoulpearlInfo(sName)
	end
	local tbl = self.m_tblId2LanTable[itemType]
	assert(tbl, "�޷��ҵ�������Ʒ�Ķ�Ӧ���ʻ����Ա�.��Ʒ����:" .. itemType)
	local info = tbl(MemH64(sName))
	assert(info, "��Ʒ��Ϣ�ڶ�Ӧ���ʻ����Ա����޷��ҵ�.��Ʒ����:" .. itemType .. "��Ʒ����:" .. sName)
	return info
end

function CItemInfoMgr:GetItemLanInfoJustByName(sName,ColumnName)
	local SoulPearlName = self:GetSoulpearlInfo(sName)
	local index = MemH64(SoulPearlName)
	local info = self.m_tblId2LanTable[19][index]
	if (info) then
		return info
	end
	
	local index = MemH64(sName)
	for k, v in pairs(self.m_tblId2LanTable) do
		local info = v(index,ColumnName)
		if( info ) then
			return info
		end
	end
	assert(false, "��Ʒ��Ϣ��������Ʒ���ʻ����Ա����޷��ҵ�,��Ʒ����:" .. sName)
end

function CItemInfoMgr:GetItemMH64ByDisplayName(itemType, sDisplayName)
	local tblResult = {}
	local tbl = self.m_tblId2LanTable[itemType]
	assert(tbl, "�޷��ҵ�������Ʒ�Ķ�Ӧ���ʻ����Ա�.��Ʒ����:" .. itemType)
	local tblKeys  = tbl:GetKeys()
	for k, v in ipairs(tblKeys) do
		local DisplayName = tbl(v, "DisplayName")
		if ( sDisplayName == DisplayName) then
			table.insert(tblResult, v)
		end
	end
	return tblResult
end
---------------------------------ĳ����Ʒ�Ƿ���õļ��----------------------------
--ְҵ�Ƿ���ȷ
function CItemInfoMgr:BeEquipClass(nBigID,nIndex,nClass)
	local ClassTbl = loadstring("return {" .. self:GetItemInfo(nBigID,nIndex,"Class") .. "}")()
	if #ClassTbl ~= 0 then
		local Flag = true
		local tempstr = ""
		for i = 1 , #ClassTbl do
			tempstr = tempstr..","..ClassTbl[i]
			if 	tonumber(ClassTbl[i]) == tonumber(nClass) then
				Flag = false
			end
		end
		if Flag then
			return false,1015,tempstr.."�����ñ���Ϣ:"..(self:GetItemInfo(nBigID,nIndex,"Class") or "is nil")
		else
			return true
		end
	else
		return true
	end
end

--�����Ƿ���ȷ
function CItemInfoMgr:BeEquipRace(nBigID,nIndex,nClass)
	local race = ClassToRace(nClass)
	local RaceTbl = loadstring("return {" .. (self:GetItemInfo(nBigID,nIndex,"Race") or "") .. "}")()
	if #RaceTbl ~= 0 then
		local Flag = true
		for i = 1, #RaceTbl do
			if RaceTbl[i] == race then
				Flag = false
			end
		end
		if Flag then
			return false, 1016
		else
			return true
		end
	else
		return true
	end
end

--�Ա���ж�
function CItemInfoMgr:BeEquipSex(nBigID,nIndex,Sex)
	local SexTbl = loadstring("return {" .. self:GetItemInfo(nBigID,nIndex,"Sex") .. "}")()
	if #SexTbl ~= 0 then
		local Flag = true
		for i = 1, #SexTbl do
			if tonumber(SexTbl[i]) == Sex then
				Flag = false
			end
		end
		if Flag then
			return false, 1017
		else
			return true
		end
	else
		return true
	end
end

--��Ӫ���ж�
function CItemInfoMgr:BeEquipCamp(nBigID,nIndex,Camp)
	local CampTbl = loadstring("return {" .. self:GetItemInfo(nBigID,nIndex,"Camp") .. "}")()
	if #CampTbl ~= 0 then
		local Flag = true
		for i = 1, #CampTbl do
			if tonumber(CampTbl[i]) == Camp then
				Flag = false
			end
		end
		if Flag then
			return false, 1018
		else
			return true
		end
	else
		return true
	end
end

--��̬����ʹ��
function CItemInfoMgr:WeaponCanUse(PlayerInfo,nBigID,nIndex,nLevelRequire,WeaponInfo,AssociateWeaponInfo,nEquipPart)
	if PlayerInfo.IsInBattleState then
		return false,1024
	end
	if PlayerInfo.IsInForbitUseWeaponState then
		return false,1028
	end
	if nBigID ~= self:GetStaticWeaponBigID() and nBigID ~= self:GetStaticShieldBigID() then
		return false ,1013
	end
	assert(IsNumber(nLevelRequire))
	--����ȼ��ж�,client ֱ�������ݣ���������Ҫ��ѯ���ݿ�
	if PlayerInfo.Level < nLevelRequire then
		return false, 1014
	end
	
	--ְҵ�Ƿ���ȷ
	local result,errnum = self:BeEquipClass(nBigID,nIndex,PlayerInfo.Class)
	if not result then
		return result,errnum
	end
		
	--�����Ƿ���ȷ
	result,errnum = self:BeEquipRace(nBigID,nIndex,PlayerInfo.Class)
	if not result then
		return result,errnum
	end

	--�Ա���ж�
	result,errnum =  self:BeEquipSex(nBigID,nIndex,PlayerInfo.Sex)
	if not result then
		return result,errnum
	end
	
	--��Ӫ���ж�
	result,errnum = self:BeEquipCamp(nBigID,nIndex,PlayerInfo.Camp)
	if not result then
		return result,errnum
	end	

	local ruslut , HandType = self:EquipTypeCheck(self:GetItemInfo(nBigID,nIndex,"EquipType"),PlayerInfo.Class)
	if not ruslut then
		return false, 1035
	end

	local eEquipPart = self:CheckEquipPart(PlayerInfo.Class,nEquipPart,HandType,WeaponInfo,AssociateWeaponInfo)
	if eEquipPart == EEquipPart.eAssociateWeapon then
		if HandType == "��"  then
			return false, 1019
		elseif HandType == "��" then
			local Class = PlayerInfo.Class
			if Class ~= EClass.eCL_Warrior and Class ~= EClass.eCL_MagicWarrior and Class ~= EClass.eCL_OrcWarrior then
				return false,1020
			end
		end
	elseif eEquipPart == EEquipPart.eWeapon then
		if HandType == "��" then
			return false,1021
		end
	end
	return true , HandType ,eEquipPart
end

--�ж������ǲ����ʺϸ�ְҵװ�� �͸ò�λ
function CItemInfoMgr:EquipTypeCheck(EquipType,Class)
	local Keys = StaticWeaponType_Common:GetKeys()
	for i,p in ipairs (Keys) do
		if tonumber(p) == Class then
			local RowInfo = StaticWeaponType_Common(p)
			tbl = {RowInfo("EquipType1"),RowInfo("EquipType2"),RowInfo("EquipType3"),RowInfo("EquipType4"),
			RowInfo("EquipType5"),RowInfo("EquipType6"),RowInfo("EquipType7"),RowInfo("EquipType8"),RowInfo("EquipType9"),RowInfo("EquipType10")}
			for i = 1, 10 do
				if tbl[i] == EquipType then
					local hand = string.sub(EquipType,1,2)
					if HandType_Common(hand) then
						return true,HandType_Common(hand,"HandType")
					end
				end

			end
		end
	end
	return false, nil
end

--��̬����ʹ��
function CItemInfoMgr:ArmorCanUse(PlayerInfo,nBigID,nIndex,nLevelRequire)
	if PlayerInfo.IsInBattleState then
		return false,1024
	end
	if PlayerInfo.IsInForbitUseWeaponState then
		return false,1028
	end
	if not self:IsArmor(nBigID) then
		return false,1013
	end
	assert(IsNumber(nLevelRequire))
	--����ȼ��ж�
	if PlayerInfo.Level < nLevelRequire then
		return false,1014
	end

	--ְҵ�Ƿ���ȷ
	local result,errnum = self:BeEquipClass(nBigID,nIndex,PlayerInfo.Class)
	if not result then
		return result,errnum
	end

	--�����Ƿ���ȷ
	result,errnum = self:BeEquipRace(nBigID,nIndex,PlayerInfo.Class)
	if not result then
		return result,errnum
	end 
	
	--�Ա���ж�
	result,errnum =  self:BeEquipSex(nBigID,nIndex,PlayerInfo.Sex)
	if not result then
		return result,errnum
	end

	--��Ӫ���ж�
	result,errnum = self:BeEquipCamp(nBigID,nIndex,PlayerInfo.Camp)
	if not result then
		return result,errnum
	end	
	
	return true
end

--��̬����ʹ��
function CItemInfoMgr:AssociateWeaponCanUse(PlayerInfo,nBigID,nIndex,nLevelRequire,WeaponInfo)
	if PlayerInfo.IsInBattleState then
		return false,1024
	end
	if PlayerInfo.IsInForbitUseWeaponState then
		return false,1028
	end
	if not self:IsAssociateWeapon(nBigID) then
		return false,1014
	end
	assert(IsNumber(nLevelRequire))
	--����ȼ��ж�
	if PlayerInfo.Level < nLevelRequire then
		return false,1014
	end

	--ְҵ�Ƿ���ȷ
	local result,errnum = self:BeEquipClass(nBigID,nIndex,PlayerInfo.Class)
	if not result then
		return result,errnum
	end

	--�����Ƿ���ȷ
	result,errnum = self:BeEquipRace(nBigID,nIndex,PlayerInfo.Class)
	if not result then
		return result,errnum
	end

	--�Ա���ж�
	result,errnum =  self:BeEquipSex(nBigID,nIndex,PlayerInfo.Sex)
	if not result then
		return result,errnum
	end

	--��Ӫ���ж�
	result,errnum = self:BeEquipCamp(nBigID,nIndex,PlayerInfo.Camp)
	if not result then
		return result,errnum
	end	

	local ruslut , HandType = self:EquipTypeCheck(self:GetItemInfo(nBigID,nIndex,"EquipType"),PlayerInfo.Class)
	if not ruslut then
		return false,1035
	end
	return true
end

--��̬��Ʒ
function CItemInfoMgr:JewelryCanUse(PlayerInfo,nBigID,nIndex,nLevelRequire)
	if PlayerInfo.IsInBattleState then
		return false,1024
	end
	if PlayerInfo.IsInForbitUseWeaponState then
		return false,1028
	end
	
	if not (self:IsJewelry(nBigID) or self:IsRing(nBigID)) then
		return false,1023
	end
	assert(IsNumber(nLevelRequire),"������Ʒ����:" .. nIndex )
	--����ȼ��ж�
	if PlayerInfo.Level < nLevelRequire then
		return false,1014
	end

	--ְҵ�Ƿ���ȷ
	local result,errnum = self:BeEquipClass(nBigID,nIndex,PlayerInfo.Class)
	if not result then
		return result,errnum
	end

	--�����Ƿ���ȷ
	result,errnum = self:BeEquipRace(nBigID,nIndex,PlayerInfo.Class)
	if not result then
		return result,errnum
	end

	--�Ա���ж�
	result,errnum =  self:BeEquipSex(nBigID,nIndex,PlayerInfo.Sex)
	if not result then
		return result,errnum
	end

	--��Ӫ���ж�
	result,errnum = self:BeEquipCamp(nBigID,nIndex,PlayerInfo.Camp)
	if not result then
		return result,errnum
	end

	return true
end

--�ж��Ƿ�Ϊ��ϵ��װ��
function CItemInfoMgr:IsFaEquip(nBigID,nIndex)
	if not self:IsEquip(nBigID) then
		return false
	end
	local Class = self:GetItemInfo(nBigID,nIndex,"Class")
	if Class == nil then
		return false
	end
	if  Class == EClass.eCL_Priest or Class == EClass.eCL_DwarfPaladin or
		Class == EClass.eCL_ElfHunter then
		return true
	end
	return false
end

--�����ж�Ӧ�÷��ص�װ���Ĳ�λ
function CItemInfoMgr:CheckEquipPart(Class,nEquipPart,HandType,WeaponInfo,AssociateWeaponInfo)
	if nEquipPart == EEquipPart.eWeapon then
		eEquipPart = EEquipPart.eWeapon
	elseif nEquipPart == EEquipPart.eAssociateWeapon then
		if HandType == "˫" then
			eEquipPart = EEquipPart.eWeapon
		else
			eEquipPart = EEquipPart.eAssociateWeapon
		end
	else
		--�����ĵط�
		if HandType == "��" then
			eEquipPart = EEquipPart.eAssociateWeapon
		elseif HandType == "��" then
			eEquipPart = EEquipPart.eWeapon
		elseif WeaponInfo ~= nil and AssociateWeaponInfo == nil then
			local EquipType = g_ItemInfoMgr:GetItemInfo(WeaponInfo[1],WeaponInfo[2],"EquipType")
			local hand = string.sub(EquipType,1,2)
			if hand == "˫" then
				eEquipPart = EEquipPart.eWeapon
			else
				if HandType == "˫" then
					eEquipPart = EEquipPart.eWeapon
				elseif Class ~= EClass.eCL_Warrior and Class ~= EClass.eCL_MagicWarrior and Class ~= EClass.eCL_OrcWarrior then
					eEquipPart = EEquipPart.eWeapon
				else
					eEquipPart = EEquipPart.eAssociateWeapon
				end
			end
		else
			eEquipPart = EEquipPart.eWeapon
		end
	end
	return eEquipPart
end

function CItemInfoMgr:GetMailItemName()
	return "Mail_Appendix"
end

function CItemInfoMgr:GetCommonlySkillByID(Class,nBigID,nIndex)
	return self:GetCommonlySkill(Class,nBigID,nIndex)
end

--
function CItemInfoMgr:GetCommonlySkill(Class,nBigID,nIndex)
	local EquipType = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"EquipType")
	if Class == EClass.eCL_Warrior then
		if EquipType=="���ֽ�" or EquipType=="���ָ�" or EquipType=="���ֽ�" or EquipType=="���ָ�" then--��������
			return "��ʿ����������ͨ����"
		elseif EquipType=="˫�ֽ�" or EquipType=="˫�ָ�" then-- ˫������
			return "��ʿ˫��������ͨ����"
		end
	elseif Class == EClass.eCL_MagicWarrior then
		if EquipType=="���ֽ�" or EquipType=="���ִ�" or EquipType=="���ֽ�" or EquipType=="���ִ�"then
			return "ħ��ʿ����������ͨ����"
		elseif EquipType=="˫�ֽ�" or EquipType=="˫�ִ�" then
			return "ħ��ʿ˫��������ͨ����"
		end
	elseif Class == EClass.eCL_Paladin then
		if EquipType=="��ʿǹ" or EquipType=="���ֽ�" then
			return "������ʿ����������ͨ����"
		elseif EquipType=="������" or EquipType=="����ì" or EquipType=="������" then
			return "������ʿ����������ͨ����"
		elseif EquipType =="��" then
			return "������ʿ��������ͨ����"
		elseif EquipType == "˫�ֹ�" then
			return "������ʿ��������ͨ����"
		end
	elseif Class == EClass.eCL_NatureElf then
		if EquipType=="������Ȼ��" then
			return "��ʦ��Ȼϵ������������ͨ����"
		elseif EquipType=="˫����Ȼ��" then
			return "��ʦ��Ȼϵ˫����������ͨ����"
		elseif EquipType=="���ְ�����" then
			return "��ʦ����ϵ������������ͨ����"
		elseif EquipType=="˫�ְ�����" then
			return "��ʦ����ϵ˫����������ͨ����"
		elseif EquipType=="�����ƻ���" then
			return "��ʦ�ƻ�ϵ������������ͨ����"
		elseif EquipType=="˫���ƻ���" then
			return "��ʦ�ƻ�ϵ˫����������ͨ����"
		end
	elseif Class == EClass.eCL_EvilElf then
		if EquipType=="������Ȼ��" then
			return "аħ��Ȼϵ������������ͨ����"
		elseif EquipType=="˫����Ȼ��" then
			return "аħ��Ȼϵ˫����������ͨ����"
		elseif EquipType=="���ְ�����" then
			return "аħ����ϵ������������ͨ����"
		elseif EquipType=="˫�ְ�����" then
			return "аħ����ϵ˫����������ͨ����"
		elseif EquipType=="�����ƻ���" then
			return "аħ�ƻ�ϵ������������ͨ����"
		elseif EquipType=="˫���ƻ���" then
			return "аħ�ƻ�ϵ˫����������ͨ����"
		end
	elseif Class == EClass.eCL_Priest then
		if EquipType=="������Ȼ��" then
			return "��ʦ��Ȼϵ������������ͨ����"
		elseif EquipType=="˫����Ȼ��" then
			return "��ʦ��Ȼϵ������������ͨ����"
		elseif EquipType=="���ְ�����" then
			return "��ʦ����ϵ������������ͨ����"
		elseif EquipType=="˫�ְ�����" then
			return "��ʦ����ϵ˫����������ͨ����"
		elseif EquipType=="�����ƻ���" then
			return "��ʦ�ƻ�ϵ������������ͨ����"
		elseif EquipType=="˫���ƻ���" then
			return "��ʦ�ƻ�ϵ˫����������ͨ����"
		end
	elseif Class == EClass.eCL_DwarfPaladin then
		if EquipType=="��ʿǹ" or EquipType=="���ֽ�" then
			return "������ʿ����������ͨ����"
		elseif EquipType=="������" or EquipType=="����ì" or EquipType=="������"  then
			return "������ʿ����������ͨ����"
		end
	elseif Class == EClass.eCL_ElfHunter then
		if EquipType=="˫�ֹ�" then
			return "���鹭���ֹ�������ͨ����"
		elseif EquipType=="˫����" then
			return "���鹭������������ͨ����"
		end
	elseif Class == EClass.eCL_OrcWarrior then
		if EquipType== "���ָ�" or EquipType== "���ִ�" or EquipType=="���ֵ�"
				or EquipType=="���ָ�" or EquipType=="���ִ�"  then
			return "����սʿ����������ͨ����"
		elseif EquipType=="˫�ִ�" or EquipType=="˫�ָ�" then
			return "����սʿ˫��������ͨ����"
		end
	else
		print("����������" .. EquipType .. "StaticWeaponType_Common���ñ��в�����")
	end
end

--���������ƼӾ���ֵ���߻�ֵ�����磺ͨ�û���:10000
function CItemInfoMgr:GetSoulpearlInfo(sIndex)
	local soulpearlName = sIndex
	local soulpearlCount = 0
		
	local temp = string.find(sIndex,":") or string.find(sIndex,"��")
	if temp then
		soulpearlCount = tonumber( string.sub(sIndex, temp + 1) )
		if soulpearlCount and soulpearlCount > 0 then
			soulpearlName = string.sub(sIndex, 1, temp - 1)
		end
	end
	return soulpearlName, soulpearlCount
end

function CItemInfoMgr:GetSoulUseLimitInfo(nType)
	return SoulPearlLimitType_Common(nType)
end

--�ж�������Ʒ�Ƿ���ͬһ��Ӫ��
function CItemInfoMgr:PlayerQuestItem(PlayerInfo,nBigID,nIndex)	
	--ְҵ�Ƿ���ȷ
	local result,errnum = self:BeEquipClass(nBigID,nIndex,PlayerInfo.Class)
	if not result then
		return result,errnum
	end	
	
	--�����Ƿ���ȷ
	result,errnum = self:BeEquipRace(nBigID,nIndex,PlayerInfo.Class)
	if not result then
		return result,errnum
	end

	--�Ա���ж�
	result,errnum =  self:BeEquipSex(nBigID,nIndex,PlayerInfo.Sex)
	if not result then
		return result,errnum
	end

	--��Ӫ���ж�
	result,errnum = self:BeEquipCamp(nBigID,nIndex,PlayerInfo.Camp)
	if not result then
		return result,errnum
	end
	
	return true
end

