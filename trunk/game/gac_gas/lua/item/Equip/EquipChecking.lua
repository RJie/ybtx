cfg_load "item/Equip_JewelrySProperty_Common"
cfg_load "item/Equip_ArmorSProperty_Common"
cfg_load "item/Equip_ShieldSProperty_Common"

--ԭ�ȵ�Equip_Armor_Common,StaticJewery_Common���е�EquipPart��������������֣����ڸĳ����ַ���
--���ǳ����кܶ�ط��õ����������ֵģ�����������ֵıȽϣ�����������������tbl��һ��ӳ��
--�ַ��������ֵ�ӳ�� 3:ͷ�� 4:�·� 5:����  7:Ь��  14:�粿 15:���� 16:����	10:���� 11:��Ʒ
EEquipPart = {}

EEquipPart.eWeapon					= 1		--����
EEquipPart.eAssociateWeapon			= 2		--����
EEquipPart.eHead					= 3		--ͷ��
EEquipPart.eWear					= 4		--�·�
EEquipPart.eSash					= 5		--����
	--EEquipPart.eCuff					= 6		--����
EEquipPart.eShoe					= 7		--Ь��
EEquipPart.eRingLeft				= 8		--��ָ��
EEquipPart.eRingRight				= 9		--��ָ��
EEquipPart.eNecklace				= 10	--����
EEquipPart.eAccouterment			= 11	--����
	--EEquipPart.eManteau				= 12    --����
	--EEquipPart.eCoat					= 13	--����
EEquipPart.eShoulder				= 14	--�粿
EEquipPart.eHand					= 15	--����
EEquipPart.eBack					= 16    --����

----------------------------------------------------------------------------------
--�õ����ߡ���Ʒ�����Ƶľ�̬�������ƺ���ֵ
function GetStaticPropertyName(nBigId,sIndex)
	local PropertyNameTbl = {"HealthPoint","Defence","NatureResistanceValue",
							"DestructionResistanceValue","EvilResistanceValue",
							"StrikeValue","StrikeMultiValue","AccuratenessValue",
							"MagicHitValue","ManaPoint"}
	local NameAndValueTbl = {}
	local Info 
	if g_ItemInfoMgr:IsArmor(nBigId) then
		Info = Equip_ArmorSProperty_Common(sIndex)
	elseif g_ItemInfoMgr:IsJewelry(nBigId) then
		Info = Equip_JewelrySProperty_Common(sIndex)
	elseif g_ItemInfoMgr:IsStaticShield(nBigId) then
		Info = Equip_ShieldSProperty_Common(sIndex)
	else
		assert(false,nBigId .. "�����BigID")
	end
	
	for i = 1, #(PropertyNameTbl) do
		if Info(PropertyNameTbl[i]) and Info(PropertyNameTbl[i]) ~= "" then
			table.insert(NameAndValueTbl,{PropertyNameTbl[i],Info(PropertyNameTbl[i])})
		end
	end
	return NameAndValueTbl
end
