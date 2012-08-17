cfg_load "equip/upgrade/EquipUpgrade_Common"
cfg_load "item/EquipSmeltSoulScroll_Common"
cfg_load "equip/EquipSmeltSoulValue_Common"

local loadstring = loadstring
local g_ItemInfoMgr = g_ItemInfoMgr
local EquipUpgrade_Common = EquipUpgrade_Common
local EquipSmeltSoulScroll_Common = EquipSmeltSoulScroll_Common
local EquipSmeltSoulScrollSql = class()
local event_type_tbl = event_type_tbl
local g_ItemInfoMgr = g_ItemInfoMgr
local EquipSmeltSoulValue_Common = EquipSmeltSoulValue_Common

local GasEquipSmeltSoulScrollDB = CreateDbBox(...)
local FromPlace ={}
FromPlace.Bag =1			--�Ӱ�����ȡ�õ�
FromPlace.StatusWnd =2		--�������������ȡ�õ�
local EquipSmeltSoulScrollTbl = {}
------------------------------------------------------------------------------------------------------	
function GasEquipSmeltSoulScrollDB.InitEquipSmeltSoulScrollTbl()
	local keys = EquipSmeltSoulScroll_Common:GetKeys()
	for i=1,#keys do
		local key = keys[i]
		EquipSmeltSoulScrollTbl[key] = {}
		local EquipSmeltSoulScrollStr = EquipSmeltSoulScroll_Common(key,"EquipPart") --����Ƭ�Ĳ�λ
		local EquipScrollTbl = loadstring( "return " .. EquipSmeltSoulScrollStr)()
		for j = 1,#EquipScrollTbl do
			EquipSmeltSoulScrollTbl[key][EquipScrollTbl[j]] = true
		end
	end
end
--require�ļ�ʱ�������ñ���Ҫloadstring�����ݴ洢�����У�������loadstring
GasEquipSmeltSoulScrollDB.InitEquipSmeltSoulScrollTbl()
------------------------------------------------------------------------------------------------------
--��֤�ӿͻ��˴�������װ��ID�Ƿ�����ȷ
local StmtDef = {
	"_GetEquipPartByEquipId",
	[[ select ce_uEquipPart from tbl_item_equip where is_uId = ? and cs_uId =? ]]
}
DefineSql(StmtDef, EquipSmeltSoulScrollSql)

local StmtDef = {
	"_GetEquipIntensifyPhase",
	[[ select ifnull(iei_uIntensifyPhase,0) from tbl_item_equip_intensify where is_uId = ? ]]
}
DefineSql(StmtDef, EquipSmeltSoulScrollSql)

--@brief װ��������
--@param �����Ķ���װ��1:����,2�����������
--�ܻ�ֵ = ���ȼ�����ɫ�����ֵ*(1+�Ѿ���ǰ�׶�*0.4)+EquipUpgrade_Common(level,"VanishSoulCount")* intensifyPhase *0.5
local function GetSoulPealFromEquip(data)
	local uEquipFromPlace  	= data["fromPlaceType"]
	local uEquipId			= data["EquipID"]
	local Class    			= data["Class"]
	local uCharId			= data["CharID"] 
	local eEquipPart = data["eEquipPart"]
	local sceneName = data["sceneName"]
	local binding = data["binding"]
	assert(IsNumber(uEquipFromPlace))
	assert(IsNumber(uEquipId))
	assert(IsNumber(uCharId))
	
	local EquipMgrDB = RequireDbBox("EquipMgrDB")
	local itemType, itemName, equipRet = EquipMgrDB.GetEquipBaseInfo( uEquipId )
	if itemType == nil or itemName == nil or equipRet == nil then
		return false, "��Ϣ���Ϸ���"
	end
	local intensifyPhaseRet = EquipSmeltSoulScrollSql._GetEquipIntensifyPhase:ExecStat(uEquipId)
	local intensifyPhase = 0
	if intensifyPhaseRet:GetRowNum() > 0 then
		intensifyPhase = intensifyPhaseRet:GetData(0,0)
	end
	local curLevel = equipRet:GetData(0, 2)
	--����װ�����������ɻ���Ļ�ֵ
	local uQuality = g_ItemInfoMgr:GetItemInfo( itemType, itemName,"Quality" )
	local QualityName = "Quality" .. uQuality

	local uAddCount =	EquipSmeltSoulValue_Common(curLevel,QualityName) 
	if uAddCount == 0 then
		return false,194008
	end
	
	local equipAdvancePhase = EquipMgrDB.GetEquipAdvancePhaseByID(uEquipId)
	local equipAdvanceValue = uAddCount*(1 + equipAdvancePhase * 0.4)
	local soulValues = EquipUpgrade_Common(curLevel,"VanishSoulCount") * intensifyPhase * 0.5
	soulValues = math.floor(soulValues + equipAdvanceValue)
	local soulpearlName = "ͨ�û���:"
	local g_RoomMgr = RequireDbBox("GasRoomMgrDB")
	--�õ������type
	local soulpearlType = g_ItemInfoMgr:GetSoulPearlBigID()
	--�ھ�̬��Ʒ��item_static�в��������Ʒ��Ϣ
	local params= {}
	params.m_nType = soulpearlType
	params.m_sName =  soulpearlName .. soulValues
	binding = 0

	params.m_nBindingType = binding
	params.m_nCharID = uCharId
	params.m_sCreateType = event_type_tbl["װ����������"]
	local create_soulpearl_id = g_RoomMgr.CreateItem(params)
	if create_soulpearl_id == false then
		return false
	end
	local PearlName = "ͨ�û���"
	--���������ıհ�
	local item_bag_box = RequireDbBox("CPutItemToBagDB")
	local nRoomIndex,nPos,bool,equipData
	
	local params = {}
	params.m_nCharID = uCharId
	params.m_nItemType = soulpearlType
	params.m_sItemName = PearlName
	params.m_tblItemID = {{create_soulpearl_id}}
	if uEquipFromPlace == FromPlace.Bag then				--�Ӱ������ݿ����ɾ��װ��
		local posRet = g_RoomMgr.GetRoomIndexAndPosByItemId(uCharId, uEquipId)
		if posRet == nil then
			return false
		end
		nRoomIndex, nPos= posRet(1,1), posRet(1,2)
		if g_RoomMgr.DelItemByID(uCharId, uEquipId,event_type_tbl["װ������"]) == false then  --ɾ�����ݿ��еĺ�����Ʒ
			CancelTran()
			return false
		end
	elseif uEquipFromPlace == FromPlace.StatusWnd then	--��װ�����ݿ����ɾ��װ��
		local delEquipNeedData = {["EquipPart"] = eEquipPart, ["PlayerId"] = uCharId,["Class"] = Class ,["sceneName"] = data["sceneName"]}
		local entry = RequireDbBox("GasUseItemDB")
		bool,equipData = entry.DelEquip(delEquipNeedData)
		if not bool then
			CancelTran()
			return false
		end
	end
	--�������Ļ���Ž�����
	local	bFlag, res = item_bag_box.AddCountItem(params)
	if bFlag == false then
		CancelTran()
		return false
	end
	local result = {["CreatePearlID"]=create_soulpearl_id, ["PearlType"]=soulpearlType, ["PearlName"]= PearlName,["PearlInfo"] = {soulValues, RootType,binding},
					["PearlRoomIndex"] =res[1].m_nRoomIndex, ["PearlPos"]= res[1].m_nPos, ["EquipRoomIndex"] =nRoomIndex, ["EquipPos"] = nPos, ["EquipData"] =equipData}
	
	return true, result
end

--@brief �жϸ�װ���Ƿ��������
local function JudgeEquipCanSmeltSoul(bigID,SmeltSoulScrollName,equipPart)
	local b_ifSmeltSoul,errorId
	--�ж��ǲ��Ƿ���
	if g_ItemInfoMgr:IsArmor(bigID) then
		b_ifSmeltSoul = EquipSmeltSoulScrollTbl[SmeltSoulScrollName]["����"] or EquipSmeltSoulScrollTbl[SmeltSoulScrollName][equipPart]
	--�ж��ǲ�����Ʒ
	elseif g_ItemInfoMgr:IsStaticJewelry(bigID) then
		b_ifSmeltSoul = ( equipPart == "����" or  equipPart == "����" ) and EquipSmeltSoulScrollTbl[SmeltSoulScrollName]["��Ʒ"] 
	--�ж��ǲ�������
	elseif g_ItemInfoMgr:IsWeapon(bigID) then
		b_ifSmeltSoul = EquipSmeltSoulScrollTbl[SmeltSoulScrollName]["����"] or EquipSmeltSoulScrollTbl[SmeltSoulScrollName][equipPart]
	--�ж��Ƿ�Ϊ����
	elseif g_ItemInfoMgr:IsStaticShield(bigID) then
		b_ifSmeltSoul = EquipSmeltSoulScrollTbl[SmeltSoulScrollName]["����"]
	--�ж��ǲ��ǽ�ָ
	elseif g_ItemInfoMgr:IsRing(bigID) then
		b_ifSmeltSoul = EquipSmeltSoulScrollTbl[SmeltSoulScrollName]["��ָ"]
	end
	if not b_ifSmeltSoul then
		errorId = 194003
	end
	return b_ifSmeltSoul,errorId
end

--@brief װ����������趨
function GasEquipSmeltSoulScrollDB.EquipSmeltSoul(data)		
	local SmeltSoulScrollRoomIndex = data["SmeltSoulScrollRoomIndex"]
	local SmeltSoulScrollPos = data["SmeltSoulScrollPos"]
	local equipRoomIndex = data["equipRoomIndex"]
	local equipPos = data["equipPos"]
	local equipitemid = data["equipitemid"]
	local uCharId = data["uCharId"]
	local bigID = data["nBigID"]
	local nIndex = data["nIndex"]
	local itemType = data["itemType"]
	local SmeltSoulScrollName = data["SmeltSoulScrollName"]
	local equip_id = {}
	local equipId = 0
	local equip_part = 0
	local g_RoomMgr = RequireDbBox("GasRoomMgrDB")
	local EquipMgrDB = RequireDbBox("EquipMgrDB")
	local smeltSoulScrollId = 0
	local flag
	local equipPart = g_ItemInfoMgr:GetItemInfo(bigID,nIndex,"EquipPart")
	
	local sItemType, sItemName, count = g_RoomMgr.GetTypeCountByPosition(uCharId, SmeltSoulScrollRoomIndex, SmeltSoulScrollPos)
	if sItemType == nil or sItemName == nil or count == 0 or sItemType ~= 36 then
		return false
	end
		 
	local SmeltSoulScrollSet = g_RoomMgr.GetAllItemFromPosition(uCharId, SmeltSoulScrollRoomIndex, SmeltSoulScrollPos)
	if SmeltSoulScrollSet:GetRowNum() > 0 then
		smeltSoulScrollId = SmeltSoulScrollSet(1,1)
	else
		return false
	end
	local sItemType, sItemName, count,binding
	if equipRoomIndex ~= 0 and equipPos ~= 0 then
		sItemType, sItemName, count = g_RoomMgr.GetTypeCountByPosition(uCharId, equipRoomIndex, equipPos)
		binding	= g_RoomMgr.GetBindingTypeByPos(uCharId, equipRoomIndex, equipPos)
		if count == nil or count == 0 or sItemType < 5 or sItemType > 9 then
			return false
		end 
		equip_id = g_RoomMgr.GetAllItemFromPosition(uCharId, equipRoomIndex, equipPos)
		if equip_id:GetRowNum() > 0 then
			equipId = equip_id(1,1)
		end
	else
		if equipitemid ~= 0 then
			local equipSet = EquipSmeltSoulScrollSql._GetEquipPartByEquipId:ExecSql("n",equipitemid,uCharId)
			if nil ~= equipSet and equipSet:GetRowNum() > 0 then
				equipId = equipitemid
				equip_part = equipSet:GetData(0,0)
				flag = true
			else
				return false
			end
		end
	end
	
	local b_ifSmeltSoul,errorId = JudgeEquipCanSmeltSoul(bigID,SmeltSoulScrollName,equipPart)
	if b_ifSmeltSoul then
		local parameter = {
			["fromPlaceType"] = data["fromPlaceType"],
			["EquipID"] = equipId,
			["Class"] = data["Class"],
			["CharID"] = uCharId,
			["eEquipPart"] = data["eEquipPart"],
			["sceneName"] = data["sceneName"],
			["binding"] = binding
		}
		local b_Flag,result = GetSoulPealFromEquip(parameter)
		if b_Flag then
			local DelRet = g_RoomMgr.DelItemByPos(uCharId,SmeltSoulScrollRoomIndex,SmeltSoulScrollPos,1,event_type_tbl["��Ʒʹ��"])
			if IsNumber(DelRet) then
				CancelTran()
				return false
			end
			local tbl =
				{
					["smeltSoulScrollId"] = smeltSoulScrollId,
					["Flag"] = flag,
					["equipId"] = equipId,
					["equip_part"] = equip_part,
					["b_Flag"] = b_Flag,
					["result"] = result,
				}
			return true,tbl
		else
			return b_Flag,result
		end
	end
	return false,errorId
end


SetDbLocalFuncType(GasEquipSmeltSoulScrollDB.EquipSmeltSoul)
return GasEquipSmeltSoulScrollDB
