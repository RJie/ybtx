cfg_load "commerce/PurchasingAgent_Common"

CPurchasing = class ()

--����������:
local AttrNameMapTbl = {}
AttrNameMapTbl["���ֽ�"] = "���ֽ�"
AttrNameMapTbl["���ִ�"] = "���ִ�"
AttrNameMapTbl["���ָ�"] = "���ָ�"
AttrNameMapTbl["���ֵ�"] = "���ֵ�"
AttrNameMapTbl["������Ȼ��"] = "������"
AttrNameMapTbl["���ְ�����"] = "������"
AttrNameMapTbl["�����ƻ���"] = "������"
AttrNameMapTbl["������"] = "������"
AttrNameMapTbl["˫�ֽ�"] = "˫�ֽ�"
AttrNameMapTbl["˫�ָ�"] = "˫�ָ�"
AttrNameMapTbl["˫�ִ�"] = "˫�ִ�"
AttrNameMapTbl["˫����Ȼ��"] = "����"
AttrNameMapTbl["˫�ְ�����"] = "����"
AttrNameMapTbl["˫���ƻ���"] = "����"
AttrNameMapTbl["˫����"] = "����"

AttrNameMapTbl["����"] = "����"
AttrNameMapTbl["����"] = "����"
AttrNameMapTbl["ͷ��"] = "ͷ��"
AttrNameMapTbl["�·�"] = "�·�"
AttrNameMapTbl["����"] = "����"
AttrNameMapTbl["Ь��"] = "Ь��"
AttrNameMapTbl["�粿"] = "�粿"
AttrNameMapTbl["����"] = "����"
AttrNameMapTbl["����"] = "����"

AttrNameMapTbl["����"] = "����"
AttrNameMapTbl["����"] = "����"

AttrNameMapTbl["������ʯ"] = "������ʯ"
AttrNameMapTbl["���з�ʯ"] = "���з�ʯ"
AttrNameMapTbl["������ʯ"] = "������ʯ"
AttrNameMapTbl["���Է�ʯ"] = "���Է�ʯ"
AttrNameMapTbl["���޷�ʯ"] = "���޷�ʯ"
AttrNameMapTbl["������ʯ"] = "������ʯ"

AttrNameMapTbl["ǿ��ʯ"] = "ǿ��ʯ"

AttrNameMapTbl["ҩˮ"] = "ҩ��"
AttrNameMapTbl["��սҩˮ"] = "ҩ��"
AttrNameMapTbl["ҩ��"] = "ҩ��"
AttrNameMapTbl["ʳ��"] = "ʳƷ"
AttrNameMapTbl["���;���"] = "ħ����Ʒ"
AttrNameMapTbl["�����ٻ���"] = "ħ����Ʒ"
AttrNameMapTbl["����ʯ"] = "ħ����Ʒ"
AttrNameMapTbl["�౶����"] = "ħ����Ʒ"
AttrNameMapTbl["ħ����Ʒ"] = "ħ����Ʒ"

AttrNameMapTbl["�������ײ���"] = "���졢���ײ���"
AttrNameMapTbl["�����ҩ����"] = "��⿡���ҩ����"
AttrNameMapTbl["����"] = "��ͨ��Ʒ"
AttrNameMapTbl["��ͨ��Ʒ"] = "��ͨ��Ʒ"
AttrNameMapTbl["����"] = "����"


local tbl_ItemParentNodeTbl ={}
tbl_ItemParentNodeTbl[1] = {5} --����
tbl_ItemParentNodeTbl[2] = {6,7}	--����
tbl_ItemParentNodeTbl[3] = {8,9}	--��Ʒ
tbl_ItemParentNodeTbl[4] = {14, 15}	--��ʯϵͳ
tbl_ItemParentNodeTbl[5] = {34, 38, 43, 49, 50}	--װ��ǿ��
tbl_ItemParentNodeTbl[6] = {3,46}	--����Ʒ
tbl_ItemParentNodeTbl[7] = {2,24,25,27,28,30,32,37,40}	--����
tbl_ItemParentNodeTbl[8] = {10,17,18,19,23,26,29,31,36,39}	--������Ʒ

tbl_TypeToChildNode = {}
tbl_TypeToChildNode[2] = "����"
tbl_TypeToChildNode[8] = "��ָ"
tbl_TypeToChildNode[15] = "����"
tbl_TypeToChildNode[24] = "����"
tbl_TypeToChildNode[25] = "�鼮"
tbl_TypeToChildNode[27] = "���졢���ײ���"
tbl_TypeToChildNode[28] = "���졢���ײ���"
tbl_TypeToChildNode[30] = "��ͼ"
tbl_TypeToChildNode[32] = "����"
tbl_TypeToChildNode[34] = "�ӳ��ص�"
tbl_TypeToChildNode[37] = "��������չ��"
tbl_TypeToChildNode[38] = "����ʯ"
tbl_TypeToChildNode[40] = "С����"
tbl_TypeToChildNode[43] = "����ʯ"
tbl_TypeToChildNode[46] = "�淨��Ʒ"
tbl_TypeToChildNode[49] = "ǿ��ʯ"
tbl_TypeToChildNode[50] = "׷��ʯ"
	
tbl_BaseItemNode = {}
tbl_BaseItemNode[1] = {}
tbl_BaseItemNode[1]["��⿡���ҩ����"] = 7
tbl_BaseItemNode[1]["���졢���ײ���"] = 7
tbl_BaseItemNode[1]["ǿ��ʯ"] = 5
tbl_BaseItemNode[1]["����"] = 7
tbl_BaseItemNode[1]["��ͨ��Ʒ"] = 7
	
	
local CfgInfo = { [5] = {Equip_Weapon_Common, "EquipType"}, 
							[6] = {Equip_Armor_Common,  "EquipPart"}, 
							[7] = {Equip_Shield_Common, "EquipType"},
							[8] = {Equip_Ring_Common, "EquipType"}, 
							[9] = {Equip_Jewelry_Common,"EquipPart"},
							[g_ItemInfoMgr:GetStoneBigID()] = {Stone_Common, "StoneType"},
							[g_ItemInfoMgr:GetSkillItemBigID()] = {SkillItem_Common, "ItemType"},
							[g_ItemInfoMgr:GetBasicItemBigID()] = {BasicItem_Common, "CSMSortType"},
}







function GetChildNodeByItemType(ItemBigID,ItemName)
	for i=1, # tbl_ItemParentNodeTbl do
		local tbl_Temp = tbl_ItemParentNodeTbl[i]
		for j=1, # tbl_Temp do
			if tbl_Temp[j] == ItemBigID then
				return i
			end
		end
	end
	local TreeList_ChildNode = ""
	local Info = CfgInfo[ItemBigID]
	if Info then
		TreeList_ChildNode = Info[1](ItemName,Info[2])
		TreeList_ChildNode = AttrNameMapTbl[TreeList_ChildNode]
		if tbl_BaseItemNode[ItemBigID] then
			return tbl_BaseItemNode[ItemBigID][TreeList_ChildNode]
		end
	end
end

function GetChildNode(ItemBigID,ItemName)
	local TreeList_ChildNode = ""
	local Info = CfgInfo[ItemBigID]
	if Info then
		TreeList_ChildNode = Info[1](ItemName,Info[2])
		TreeList_ChildNode = AttrNameMapTbl[TreeList_ChildNode]
	elseif tbl_TypeToChildNode[ItemBigID] then
		TreeList_ChildNode = tbl_TypeToChildNode[ItemBigID]
	end
	
--	local keys = Lan_CSMTreeList_Client:GetKeys()
--	for i,v in pairs( keys ) do
--		for k=1, 11 do
--			local ChildNodeStr = string.format("%s%d", "ChildNode", k-1)
--			local ChildNodeName = CSMTreeList_Client(uIndex,ChildNodeStr)
--			if ChildNodeName == TreeList_ChildNode then
--				return TreeList_ChildNode
--			end
--		end
--	end
	return TreeList_ChildNode
end