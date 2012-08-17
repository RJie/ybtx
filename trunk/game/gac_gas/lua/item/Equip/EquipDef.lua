gac_gas_require "item/Equip/EquipDefInc"
gac_gas_require "item/Equip/EquipChecking"
cfg_load "equip/ArmorProValue_Common"

--ԭ�ȵ�Equip_Armor_Common,StaticJewery_Common���е�EquipPart��������������֣����ڸĳ����ַ���
--���ǳ����кܶ�ط��õ����������ֵģ�����������ֵıȽϣ�����������������tbl��һ��ӳ��
--�ַ��������ֵ�ӳ�� 3:ͷ�� 4:�·� 5:����  7:Ь��  14:�粿 15:���� 16:����	10:���� 11:��Ʒ
EquipPartNameToNum ={}
EquipPartNameToNum["ͷ��"]			= 3
EquipPartNameToNum["�·�"]			= 4
EquipPartNameToNum["����"]			= 5
EquipPartNameToNum["Ь��"]			= 7
EquipPartNameToNum["�粿"]			= 14
EquipPartNameToNum["����"]			= 15
EquipPartNameToNum["����"]			= 16
EquipPartNameToNum["����"]			= 10
EquipPartNameToNum["����"]			= 11

--װ������
EEquipMaterial.eLoricae 			= 1 	--����
EEquipMaterial.eFur 				= 2 	--Ƥ��
EEquipMaterial.eCloth 				= 3 	--����
EEquipMaterial.eShortWeapon 		= 4 	--�̱�
EEquipMaterial.eLongWeapon  		= 5 	--����
EEquipMaterial.eMagicWeapon 		= 6 	--����

--��������
EJewelryType.eNecklace				= 1 	--����
EJewelryType.eAccouterment			= 2 	--��Ʒ
EJewelryType.eRing					= 3 	--��ָ

--װ������
EEquipQuality.eWhite				= 1		--��װ
EEquipQuality.eGreen				= 2		--��װ
EEquipQuality.eBlue					= 3		--��װ
EEquipQuality.ePurple				= 4 	--��װ

--װ��ʹ�ö��ٴε�1���;�
g_EquipUseNumDelOne[EEquipPart.eWeapon] 			= 600
g_EquipUseNumDelOne[EEquipPart.eAssociateWeapon] 	= 0
g_EquipUseNumDelOne[EEquipPart.eHead] 				= 550
g_EquipUseNumDelOne[EEquipPart.eWear] 				= 500
g_EquipUseNumDelOne[EEquipPart.eSash] 				= 650
g_EquipUseNumDelOne[EEquipPart.eShoe] 				= 700

--�����ı�׼�������
g_WeaponSpeed[EClass.eCL_Warrior]    		= 1.9
g_WeaponSpeed[EClass.eCL_MagicWarrior]    	= 1.6
g_WeaponSpeed[EClass.eCL_Paladin]   		= 1.1
g_WeaponSpeed[EClass.eCL_NatureElf]   		= 1.3
g_WeaponSpeed[EClass.eCL_EvilElf]    		= 1.4
g_WeaponSpeed[EClass.eCL_Priest]    		= 1.5
g_WeaponSpeed[EClass.eCL_DwarfPaladin]    	= 1.5
g_WeaponSpeed[EClass.eCL_OrcWarrior]  		= 1.6

-- 0 Ϊ����ͨ��
g_WeaponDrift[0]    						= 10
g_WeaponDrift[EClass.eCL_Warrior]    		= 10
g_WeaponDrift[EClass.eCL_MagicWarrior]    	= 10
g_WeaponDrift[EClass.eCL_Paladin]   		= 10
g_WeaponDrift[EClass.eCL_NatureElf]   		= 10
g_WeaponDrift[EClass.eCL_EvilElf]    		= 10
g_WeaponDrift[EClass.eCL_Priest]    		= 10
g_WeaponDrift[EClass.eCL_DwarfPaladin]    	= 10
g_WeaponDrift[EClass.eCL_OrcWarrior]  		= 10



--ȷ�ϲ�λ�Ƿ���ȷ
function g_CheckPart(nNum)
	if nNum >= EEquipPart.eWeapon and nNum <= EEquipPart.eBack then
		return true
	else 
		return false
	end
end

function g_CheckEquipQuality(nNum)
	return true
end

--ȷ�ϲ����Ƿ���ȷ
function g_CheckMaterial(nPart,nMaterial)
	if nPart == EEquipPart.eWeapon then
		if nMaterial >= EEquipMaterial.eShortWeapon and nMaterial <= EEquipMaterial.eMagicWeapon then
			return true
		else
			return false
		end
	elseif nPart >= EEquipPart.eHead and nPart <= EEquipPart.eShoe then
		if nMaterial >= EEquipMaterial.eLoricae and nMaterial <= EEquipMaterial.eCloth then
			return true
		else
			return false
		end
	end
	return true
end

--��ò��ϵ�����
function g_GetMaterialName(nPart,nMaterial)
	if nPart == EEquipPart.eWeapon or (nPart >= EEquipPart.eHead and nPart <= EEquipPart.eShoe) then
		if nMaterial == EEquipMaterial.eLoricae	then
			return "����"
		elseif nMaterial == EEquipMaterial.eFur then
			return "Ƥ��"
		elseif nMaterial == EEquipMaterial.eCloth	then
			return "����"
		elseif nMaterial == EEquipMaterial.eShortWeapon then
			return "�̱�"
		elseif nMaterial == EEquipMaterial.eLongWeapon	then
			return "����"
		elseif nMaterial == EEquipMaterial.eMagicWeapon then
			return "����"
		end
	end
	return nil
end

--�ж����ɺͲ����Ƿ�ƥ��
function g_CheckMaterialMatchClass(nEquipPart,nMaterial,nClass)
	if nEquipPart >= EEquipPart.eHead and nEquipPart <= EEquipPart.eShoe then
		if nMaterial == EEquipMaterial.eLoricae	then
			if nClass == EClass.eCL_Warrior or nClass == EClass.eCL_MagicWarrior then
				return true
			else
				return false
			end
		elseif nMaterial == EEquipMaterial.eFur	then
			if nClass == EClass.eCL_EvilElf or nClass == EClass.eCL_Paladin or nClass == EClass.eCL_NatureElf then
				return true
			else
				return false
			end
		elseif nMaterial == EEquipMaterial.eCloth	then
			if nClass == EClass.eCL_Priest or nClass == EClass.eCL_DwarfPaladin or nClass == EClass.eCL_ElfHunter then
				return true
			else
				return false
			end
		end
	elseif nEquipPart == EEquipPart.eWeapon then
		return true
	elseif nEquipPart == EEquipPart.eAssociateWeapon then
		return true
	end
	return false
end

--����װ����info�õ���װ����Ӧ�Ĳ�����������
--����������g_ItemInfoMgr:GetItemInfo(nBigID,nIndex)�ó��Ľ��
--����ֵ��װ������ʱ�����������������
function GetEquipOutputAttrName(nBigID,nIndex)
	local tblAttrName = {}
	local armorAttrTempTbl = {"HealthPoint", "Defence", "NatureResistanceValue", "DestructionResistanceValue", "EvilResistanceValue"}
	local EquipType	= g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"EquipType")
	local EquipPart	= g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"EquipPart")
	for i =1, 5 do
		if ArmorProValue_Common(EquipType,EquipPart,armorAttrTempTbl[i]) ~= "" and tonumber(ArmorProValue_Common(EquipType,EquipPart,armorAttrTempTbl[i])) > 0 then
			local attrName = GetAttrName(armorAttrTempTbl[i])
			table.insert( tblAttrName, attrName )
		end
	end
	return tblAttrName
end

