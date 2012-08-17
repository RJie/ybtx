CItemInfoMgr = class()
local CItemTable = CItemTableXml:new()
local ItemNumber = CItemTable:GetItemXmlNumber()
for i=0,ItemNumber-1 do
	cfg_load("item/"..CItemTable:GetItemXmlAppName(i))
	lan_load("item/"..CItemTable:GetItemXmlLanName(i))
end

cfg_load "equip/InitEquip_Common"
cfg_load "item/ItemLife_Common"
cfg_load "item/ItemMaterial_Common"
lan_load "item/Lan_ItemLife_Common"

--[[
	TODO: THIS FUNCTION TO BE REMOVED
--]]

function str_or_num_to_num(str)
	if type(str) == "string" then
		return tonumber(str)
	end
	return str
end

--�������Ĵ����޸��ˣ�Ҫ�޸�GacBagSpace.lua ��Ӧ�Ĵ���
--ҲҪ�޸ļ��۽�����CSMTreeListMap.lua,�Ǹ��ļ����й�����Ʒ����id�ľֲ�ӳ���
local BigId2FileTable = {}
local ItemTblNameStr = {}
local BigId2LanFileTable = {}
local tblItemTypeOrder = {}
for i=0,ItemNumber-1 do
	local index = CItemTable:GetItemXmlBigId(i)
	BigId2FileTable[index]=_G[CItemTable:GetItemXmlAppName(i)]
	ItemTblNameStr[index]=CItemTable:GetItemXmlAppName(i)
	BigId2LanFileTable[index]=_G[CItemTable:GetItemXmlLanName(i)]
	table.insert(tblItemTypeOrder,CItemTable:GetItemXmlBigId(i))
end
CItemTable = nil
--����Ĳ߻����ñ��Ƿ���Ʒʹ�õģ�Ҳ����û�д���id
local NotBigIdTable =
{
	[5] = InitEquip_Common,					--5 ��ʼ��װ��
}
--��������ʱ��Ʒ��������˳��
--������µĴ�����Ʒ��ʱ��ǵü������

--������"SkillItem_Common"���SkillCoolDownType��, �߻����ͳ�����ö�ٶ�Ӧ
ESkillCDType = 
{
	DrugItemCD	= "ҩƷCD",
	SpecailItemCD	= "����CD",
	OtherItemCD	= "����CD"
}

function CItemInfoMgr:GetItemTypeOrder()
	return tblItemTypeOrder
end

function CItemInfoMgr:Ctor(tblId2,tblNoBigId)
	--��Ϊ�ձ�ʾ���������Լ���������ݣ����Բ�����ʽ������Ӱ��
	if tblId2 ~= nil then
		self.m_tblId2Table = tblId2
	else
		self.m_tblId2Table = BigId2FileTable
		self.m_tblId2LanTable = BigId2LanFileTable
	end

	if tblNoBigId ~= nil then
		self.m_tblNoBigId = tblNoBigId
	else
		self.m_tblNoBigId = NotBigIdTable
	end
end

--�Ƿ�Ϊ��̬װ��
function CItemInfoMgr:IsStaticEquip(itemType)
	local nBigID = str_or_num_to_num(itemType)
	if nBigID == nil then
		return false
	end
	return nBigID >= 5 and nBigID <= 9
end

--�ж��Ƿ��ǻ���
function CItemInfoMgr:IsSoulPearl(nBigID)
	return 19 == str_or_num_to_num(nBigID)
end


--�ж��Ƿ��Ǿ���ƿ/��ƿ
function CItemInfoMgr:IsExpOrSoulBottle(nBigID)
	return 48 == str_or_num_to_num(nBigID)
end
--************************************************************************
function CItemInfoMgr:HaveItem(ItemType,ItemName)
	local ItemType = str_or_num_to_num(ItemType)
	if self:IsSoulPearl(ItemType) then
		ItemName = self:GetSoulpearlInfo(ItemName)
	end
	if not (self.m_tblId2Table[ItemType]) then return end
	return self.m_tblId2Table[ItemType](ItemName) and true or false
end

function CItemInfoMgr:GetItemInfo(ItemType,ItemName,ColumnName)
	local ItemType = str_or_num_to_num(ItemType)
	if self:IsSoulPearl(ItemType) then
		ItemName = self:GetSoulpearlInfo(ItemName)
	end
	if(not self.m_tblId2Table[ItemType]) then
		LogErr("�����ڸ���Ʒ����", "ItemType:" .. ItemType)
		return
	end
	assert(IsString(ItemName) or IsNumber(ItemName))
	local ItemInfo = self.m_tblId2Table[ItemType](ItemName)
	if(not ItemInfo) then
		LogErr("��Ʒ������", "Type:" .. ItemType .. "Name:" .. ItemName)
		return
	end
	
	return self.m_tblId2Table[ItemType](ItemName,ColumnName)
end

function CItemInfoMgr:GetItemFunInfo(ItemType,ItemName)
	local ItemType = str_or_num_to_num(ItemType)
	if self:IsSoulPearl(ItemType) then
		ItemName = self:GetSoulpearlInfo(ItemName)
	end
	assert(self.m_tblId2Table[ItemType],"ItemType<" .. ItemType .. ">�����ڣ����ʵ" )
	assert(IsString(ItemName) or IsNumber(ItemName))
	return self.m_tblId2Table[ItemType](ItemName)
end

function CItemInfoMgr:GetItemSoundName(ItemType,ItemName)
	local ItemType = str_or_num_to_num(ItemType)
	if self:IsSoulPearl(ItemType) then
		ItemName = self:GetSoulpearlInfo(ItemName)
	end
	local Material = self:GetItemInfo(ItemType,ItemName,"Material")
	if Material and ItemMaterial_Common(Material) then
		return ItemMaterial_Common(Material,"SoundName")
	end
	return ""
end

function CItemInfoMgr:PlayItemSound(ItemType,ItemName)
	local SoundName = self:GetItemSoundName(ItemType,ItemName)
	if SoundName ~= "" then PlayCue(SoundName) end
end

function CItemInfoMgr:GetItemInfoByDisplayName(DisplayName)
	local tblType = self:GetItemTypeOrder()
	local tblItemName = {}
	for i,v in pairs(tblType) do
		local ItemType = v
		local BigTbl = self.m_tblId2Table[ItemType]
		local tblNames = BigTbl:GetKeys()
		for j,k in pairs(tblNames) do
			local ItemName = k
			local disName = self:GetItemLanInfo(ItemType,ItemName,"DisplayName")
			if disName == DisplayName then
				table.insert(tblItemName,{ItemType,ItemName})
			end
		end
	end
	return tblItemName
end

function CItemInfoMgr:GetItemInfoByIndex(ItemName)
	local tblType = self:GetItemTypeOrder()
	for i,v in pairs(tblType) do
		local ItemType = v
		local BigTbl = self.m_tblId2Table[ItemType]
		if BigTbl(ItemName) then
				return {ItemType,ItemName}
		end
	end
end

---------------------------------------------------------------------------------------------------

--ģ��ƥ��
function g_GetItemNameMatch(str_match)   
        local tbl_name_match = {} 
	for i,v in pairs(BigId2FileTable) do
		local keys = v:GetKeys()
		for k,p in pairs(keys) do
			if string.find(p, str_match, 1, true) then
				tbl_name_match[i] = tbl_name_match[i] or {}
				table.insert(tbl_name_match[i],p)
			end
		end
	end
	return tbl_name_match
end

