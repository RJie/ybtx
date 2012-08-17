gac_gas_require "commerce/npc_shop/NPCShopMgrInc"
cfg_load "npc/NpcShop_Common"
cfg_load "commerce/ItemInShopTongLevel_Common"
cfg_load "npc/WithOneNpcShopDisplay_Common"

local TongNpcShop = 10--�Ź��̵꣬������������������̵�
local WithOneCommonShop = 1
local WithOneJiFenShop  = -1
local NotWithOneShop = 0


local function InitNpcShopSellList(npcName, index, itemType, itemName, shopPayType, shopType)
    if NotWithOneShop ~= shopType and shopType ~= WithOneJiFenShop then --�������̵�
        if shopType >= WithOneCommonShop then
            local node = {itemType, itemName}
            table.insert(g_NPCShopMgr[npcName], node)
        end
    else
        if g_NPCShopMgr[npcName][index] == nil then
            g_NPCShopMgr[npcName][index] = {}
            g_NPCShopMgr[npcName][index].ItemType = itemType
            table.insert(g_NPCShopMgr[npcName][index], itemName) 
        else
            if g_NPCShopMgr[npcName][index].ItemType == itemType then
                table.insert(g_NPCShopMgr[npcName][index], itemName)
            else
                index = index + 1
                g_NPCShopMgr[npcName][index] = {}
                g_NPCShopMgr[npcName][index].ItemType = itemType
                table.insert(g_NPCShopMgr[npcName][index], itemName) 
            end
        end 
    end
    return index
end

function CheckNPCShop_Common()
    --ÿһ��ԭ�鶼��һ�����͵���Ʒ��һ�����͵���Ʒ������ܶ����ÿһ����Ʒ����ϢΪ����Ʒ���͡���Ʒ����
   
    local keys = NpcShop_Common:GetKeys()
    g_WithOneJiFenNpcShopMgr = {}
    for i, p in pairs(keys) do
        local npcName = p
        g_NPCShopMgr[npcName] = {}
        local shopName = NpcShop_Common(npcName, "ShopName")
        g_NPCShopMgr[npcName].NPCShopName = shopName
        local index = 1 --�̵�������Ʒ��������Ϣ��Ĭ��Ϊ1
        local shopType = NpcShop_Common(npcName, "ShopType") --0Ϊnpc�̵꣬�����Ϊ������

        for j =1, 120 do
            local itemTypeStr = "ItemType" .. j
        	local itemNameStr = "ItemName" .. j
        	local itemType = tonumber(NpcShop_Common(npcName, itemTypeStr))
        	local itemName = NpcShop_Common(npcName, itemNameStr)
        	if itemType == "" or itemType == nil or  itemType ==0  then
        		break
        	end     
	        index = InitNpcShopSellList(npcName, index, itemType, itemName, shopPayType, shopType)
        end
                
        local shopPayType = WithOneNpcShopDisplay_Common(npcName, "JiFenType")
        
        if shopType == WithOneJiFenShop then --�����̵�
            if g_WithOneJiFenNpcShopMgr[shopPayType] == nil then
                g_WithOneJiFenNpcShopMgr[shopPayType] = {}
            end
            table.insert(g_WithOneJiFenNpcShopMgr[shopPayType], npcName)
        end  	
    end
end

CheckNPCShop_Common()

cfg_load "commerce/ItemJiFenPrice_Common"
cfg_load "commerce/ItemInShopTongLevel_Common"

local function GetCommonJiFenPrice(itemType, payType, itemName)
    if ItemJiFenPrice_Common(tostring(itemType)) == nil then
       return 0 
    end
    local itemInfo = ItemJiFenPrice_Common(tostring(itemType), tostring(payType))
    if itemInfo == nil then
       return 0 
    end
    local jiFenPrice = itemInfo(itemName) 
    if jiFenPrice == nil then
        jiFenPrice = 0 
    end
    return jiFenPrice
end

local function GetTongJiFenPrice(itemType, payType, itemName)
    local itemInfo = ItemInShopTongLevel_Common(tostring(itemType))
    if itemInfo == nil then
       return 0 
    end
    local info = itemInfo(itemName)
    if info == nil then
       return 0 
    end
    local jiFenPrice = info("JiFenPrice") or 0
    return jiFenPrice
end

--������Ʒtype����Ʒ���ơ��۸���ʣ�1����1/4�����̵����ͣ�����1��2��3�ȣ�
function GetItemJiFenPrice(itemType, itemName, priceRate, payType)
    local jiFenPrice = 0
    if payType == TongNpcShop then--�Ź��̵꣬������������������̵�
        jiFenPrice =  GetTongJiFenPrice(itemType, payType, itemName)
    else
        jiFenPrice = GetCommonJiFenPrice(itemType, payType, itemName)
    end
    jiFenPrice = math.ceil(jiFenPrice * priceRate)
    if jiFenPrice < 0 then
       return  0
    end
    return jiFenPrice
end

--�����̵굱ǰ���ͣ��õ���Ʒ�۸�payType��0��ң�֮����ǻ��֣�
function GetItemPriceByPayType(itemType, itemName, payType)
    if payType == 0 or payType == nil then
        local Price = g_ItemInfoMgr:GetItemInfo(itemType, itemName, "Price") or 0
        if Price < 0 then
            return 0
        else
            return Price
        end
    else
        local jiFenPrice = GetItemJiFenPrice(itemType, itemName, 1, payType)
        return jiFenPrice
    end
end

function CheckNpcShopItemTongLevel(itemType, itemName, tongLevel, tongPlaceLevel)
    local needTongLevelInfo = ItemInShopTongLevel_Common(tostring(itemType))
    local needTongLevel, needTongPlaceLevel = 0, 0
    local tongLevelInfo = 0
    if needTongLevelInfo then
        tongLevelInfo = needTongLevelInfo(itemName)
    else
        return false, 0, 0
    end
    
    if tongLevelInfo then
        needTongLevel = tongLevelInfo("TongLevel") or 0
        needTongPlaceLevel = tongLevelInfo("TongPlaceLevel") or 0
    else
        return false, 0, 0
    end
    if tongPlaceLevel == nil then
        tongPlaceLevel = 0
    end
    if tongLevel == nil then
        tongLevel = 0
    end
    if needTongLevel > tongLevel or needTongPlaceLevel > tongPlaceLevel then
        return false, needTongLevel, needTongPlaceLevel
    end
    return true, needTongLevel, needTongPlaceLevel
end

function GetItemPriceInTongShop(itemType, itemName, nCount, soulCount)
    local itemInfo = ItemInShopTongLevel_Common(tostring(itemType))
    if itemInfo == nil then
        return 0 
    end
    local info = itemInfo(itemName)
    if info == nil then
        return 0 
    end
    local price = info("Price") 
    if g_ItemInfoMgr:IsSoulPearl(itemType) then
        local soulpearlPriceMethod = price
        local beginStr = "return function (x) \n local soulPrice = "
        local endStr = "\n  return soulPrice end"
        local funcStr = string.format("%s%s%s", beginStr, soulpearlPriceMethod, endStr)
        local func = loadstring(funcStr)()
        price = func(soulCount)
    end
    price = price or 0
    return price
end