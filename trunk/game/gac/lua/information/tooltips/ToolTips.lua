gac_require "information/tooltips/ToolTipsInc"
gac_require "framework/texture_mgr/TextureMgr"
gac_require "information/tooltips/SkillsToolTips"
gac_require "information/tooltips/EquipToolTips"
gac_require "information/tooltips/TongToolTips"
gac_require "information/tooltips/SmashToolTips"
gac_gas_require "framework/common/CMoney"
gac_gas_require "item/SoulpearlCommonFunc"
cfg_load "item/Exp_Soul_Bottle_Common"

EToolTipsPayType = {}
EToolTipsPayType.Buy	= false		--����
EToolTipsPayType.Sale  	= true 		--���� 

EGoldType = {}
EGoldType.GoldBar 	= false 	--��
EGoldType.GoldCoin 	= true   	--���(RMB)


local c_money = CMoney:new()

local ColorTbl = {
			["ʣ��ʱ��"] = g_ColorMgr:GetColor("ʣ��ʱ��"),
			["�ѵ�����"] = g_ColorMgr:GetColor("�ѵ�����"),
			["���ۼ۸�"] = g_ColorMgr:GetColor("���ۼ۸�"),
			["ʹ�õȼ�"] = g_ColorMgr:GetColor("ʹ�õȼ�"),
			["�ȼ�����"] = g_ColorMgr:GetColor("�ȼ�����"),
			["����"] = g_ColorMgr:GetColor("����"),
			["��������"] = g_ColorMgr:GetColor("��������"),
			["ʹ��"] = g_ColorMgr:GetColor("ʹ��"),
			["�Ҽ����"] = g_ColorMgr:GetColor("�Ҽ����"),
			["����������"] = g_ColorMgr:GetColor("����������"),
			["��ʯʹ������"] = g_ColorMgr:GetColor("��ʯʹ������"),
			["�����ֵ"] = g_ColorMgr:GetColor("�����ֵ"),
			["����Ƭ��ǰ�ȼ�"] = g_ColorMgr:GetColor("����Ƭ��ǰ�ȼ�"),
			["�Ѱ�"] = g_ColorMgr:GetColor("��"),
			["ʹ�ð�"] = g_ColorMgr:GetColor("ʹ�ð�"),
			["Ψһ"] = g_ColorMgr:GetColor("������ɫ"),
			["��ʯ����"] = g_ColorMgr:GetColor("��ʯ����"),
			["������ͼ"] = g_ColorMgr:GetColor("������ͼ"),
			["����ʯ����"] = g_ColorMgr:GetColor("��ʯ����"),
			["�ж���Ӫ"] = g_ColorMgr:GetColor("�ж���Ӫ"),
			["�ŵȼ�����"] = g_ColorMgr:GetColor("��������ɫ"),
			["��������ɫ"] = g_ColorMgr:GetColor("��������ɫ"),
			["�;úͲ�λ"] = g_ColorMgr:GetColor("�;úͲ�λ"),
			["����״̬"] = g_ColorMgr:GetColor("����״̬"),
			["�洢״̬"] = g_ColorMgr:GetColor("�洢״̬"),
		}

-- ��ͼͼ���� 128 x 128 һ��
-- �� ID + .tex Ϊ�ļ���
function CTooltips:LoadIconFromRes(Wnd, ID)
	assert(Wnd and ID)
	-- ÿ������Ϊ		256 x 256
	-- ÿ��ͼ��Ϊ		32 x 32
	-- ÿ��ͼ����Ϊ	8 x 8  = 64
	local dir = g_ImageMgr:GetImagePath(10001)
	local ResFile = dir .. math.floor(ID/64) .. ".tex"
	local ImageIndex = ID % 64

	local rect = g_GetTexRectByIndex(ImageIndex, 256, 256, 32, 32)

	local pos = CFPos:new()
	local image = WND_IMAGE_LIST:new()

	image:AddImageWin(Wnd:GetGraphic(),-1, ResFile, rect, pos, 4294967295, 0)
	Wnd:SetMouseOverRichTextImageForAllWnd(ID, image)
end

function CTooltips:GetBindingStyle(nBindingType,nItemID)
	local sStyle = ""
	if 1 == nBindingType then
		sStyle = ColorTbl["ʹ�ð�"] .. ToolTipsText(206)
	elseif 2 == nBindingType then
		if 0 ~= nItemID then
			sStyle = ColorTbl["�Ѱ�"] .. ToolTipsText(207) .. "#n#r"
		else
			sStyle = ColorTbl["�Ѱ�"] .. ToolTipsText(200) .. "#n#r"
		end
	elseif 3 == nBindingType then
		sStyle = ColorTbl["�Ѱ�"] .. ToolTipsText(296) .. "#n#r"
	end
	return sStyle
end

function CTooltips:InsertBindingType(nItemID, nBindingStyle, tbl, nNum)
	local nBindingType = nBindingStyle
	local nLeftTime = 0
	if 0 ~= nItemID then
		local item = g_DynItemInfoMgr:GetDynItemInfo(nItemID)
		if item then
			nBindingType	= item.BindingType
			nLeftTime		= item.m_nLifeTime
		end
	end
	local sStyle = self:GetBindingStyle(nBindingType,nItemID)
	tbl[nNum] = {}
	table.insert( tbl[nNum], sStyle )
	return nLeftTime
end

function CTooltips:ItemNumLimit( item_type,item_name, tbl, nNum)
	local nOnly = g_ItemInfoMgr:GetItemInfo(item_type,item_name,"Only")
	if nOnly and nOnly > 0 then
		local str = ""
		if nOnly == 1 then
			str = ToolTipsText(208) .. "#n#r"
		else
			str = ToolTipsText(209,nOnly)
		end
		tbl[nNum] = {}
		table.insert( tbl[nNum], ColorTbl["Ψһ"] .. str )
	end
end

function CTooltips:ItemTongPurview( item_type,item_name, tbl, nNum)
	local nOnly = g_ItemInfoMgr:GetItemInfo(item_type,item_name,"NeedPurview")
	local uTongPos = g_GameMain.m_TongBase.m_TongPos
	local flag = uTongPos == g_TongMgr.m_tblPosInfo["�ų�"] or uTongPos == g_TongMgr.m_tblPosInfo["���ų�"] 
	if nOnly == 1 then
		str = ToolTipsText(1230) .. "#n#r"
	end
	tbl[nNum] = {}
	table.insert( tbl[nNum],  str )
end

function CTooltips:InsertBaseLevel( nBaseLevel, tbl, nNum )
	local player_level = g_GameMain.m_PlayerInfoTbl.m_PlayerLevel
	local color = ColorTbl["ʹ�õȼ�"]
	if player_level < nBaseLevel then
		color = ColorTbl["�ȼ�����"]
	end
	tbl[nNum] = {}
	table.insert( tbl[nNum], color .. ToolTipsText(201, nBaseLevel) )
end

function CTooltips:InsertUseEffect( nBigID, nIndex, tbl, nNum )
	local sUseEffect = g_ItemInfoMgr:GetItemLanInfo(nBigID, nIndex,"UseEffect")
	if sUseEffect ~= "" then
		tbl[nNum] = {}
		table.insert( tbl[nNum], ColorTbl["ʹ��"] .. ToolTipsText(202, sUseEffect) )
	end
end

function CTooltips:InsertLeftTime( nLeftTime, tbl, nNum )
	if nLeftTime and nLeftTime > 0 then
		tbl[nNum] = {}
		table.insert( tbl[nNum], ColorTbl["ʣ��ʱ��"] .. ToolTipsText(203, g_CTimeTransMgr:FormatTime(nLeftTime) ) )
	end
end

function CTooltips:InsertDescription( nBigID, nIndex, tbl, nNum )
	local sDescription = g_ItemInfoMgr:GetItemLanInfo(nBigID, nIndex,"Description")
	if sDescription ~= "" then
		tbl[nNum] = {}
		table.insert( tbl[nNum], ColorTbl["����"] .. sDescription .. "#n" .. "#r" )
	end
end

function CTooltips:InsertUseLevelLimit( nBigID, nIndex, tbl ,nNum)
	local uBaseLevel = g_ItemInfoMgr:GetItemInfo(nBigID, nIndex,"BaseLevel")
	local uTopLevel = g_ItemInfoMgr:GetItemInfo(nBigID, nIndex,"TopLevel")
	tbl[nNum] = {}
	table.insert( tbl[nNum],ToolTipsText(109,uBaseLevel,uTopLevel))
end

function CTooltips:InsertFoldLimit( nFoldLimit, tbl, nNum )
	if nFoldLimit and 1 < nFoldLimit then
		tbl[nNum] = {}
		table.insert( tbl[nNum], ColorTbl["�ѵ�����"] .. ToolTipsText(204, nFoldLimit) )
	end
end


function CTooltips:GetItemNeedTongLevelStr(itemType, itemName, tongLevel, tongPlaceLevel)
    local suc, needTongLevel, needTongPlaceLevel =  CheckNpcShopItemTongLevel(itemType, itemName, tongLevel, tongPlaceLevel)
    local str = ""
    if suc then
        str = ColorTbl["���ۼ۸�"] .. ToolTipsText(400, needTongLevel, needTongPlaceLevel)
    else
        if needTongLevel ~= 0 or needTongPlaceLevel ~= 0 then
            str = ColorTbl["�ŵȼ�����"] .. ToolTipsText(400, needTongLevel, needTongPlaceLevel)
        end        
    end
    return str
end


local TongNpcShop = 10--�Ź��̵꣬������������������̵�
function CTooltips:GetSellItemTongInfo(item_type, item_name, bOriginalPrice,GoldType)
    if g_GameMain.m_NPCShopSell.m_ShopOpenFlag 
		and g_GameMain.m_NPCShopSell.m_PayType == TongNpcShop  then
		local needTongLevel = g_GameMain.m_NPCShopSell.m_TongLevel or 0
		local needTongPlaceLevel = g_GameMain.m_NPCShopSell.m_TongPlaceLevel or 0
        local needTongStr = self:GetItemNeedTongLevelStr(item_type, item_name, needTongLevel, needTongPlaceLevel)
        if needTongStr ~= "" then
            return needTongStr .. "#n#r"
        end
    end
    return ""
end

function CTooltips:GetSellItemTongPrice(item_type, item_name, bOriginalPrice,GoldType)
    if  g_GameMain.m_NPCShopSell.m_ShopOpenFlag 
		and g_GameMain.m_NPCShopSell.m_PayType == TongNpcShop  then  
        local price = GetItemPriceInTongShop(item_type, item_name, nCount, soulCount)
        local priceDesc = c_money:ChangeMoneyToString(price,GoldType)
        if price > 0 then
            if bOriginalPrice == true then  --��ʾ�̵�����Ʒ����۸�
                return ColorTbl["���ۼ۸�"] .. ToolTipsText(280, priceDesc) .. "#n#r" 
            else
                return ColorTbl["���ۼ۸�"] .. ToolTipsText(205, priceDesc) .. "#n#r" 
        	end
        end
    end
    return ""
end

function CTooltips:InsertSellPrice( InfoTbl, tbl, nNum)
	item_type,item_name,bOriginalPrice,GoldType = unpack(InfoTbl)
	tbl[nNum] = {}
	local needTongStr = self:GetSellItemTongInfo(item_type, item_name, bOriginalPrice,GoldType)
	table.insert( tbl[nNum], needTongStr  )
	
	local needMoneyStr = self:GetSellItemTongPrice(item_type, item_name, bOriginalPrice,GoldType)
	table.insert( tbl[nNum], needMoneyStr )
	
   	if bOriginalPrice == true then  --��ʾ�̵�����Ʒ����۸�
	    local money = self:GetItemPriceByPayType(item_type,item_name, bOriginalPrice,GoldType)
        table.insert( tbl[nNum], ColorTbl["���ۼ۸�"] .. ToolTipsText(280, money) .. "#R#n#r" )
    else
        local money = self:GetItemPriceByPayType(item_type,item_name, false,GoldType)
        table.insert( tbl[nNum], ColorTbl["���ۼ۸�"] .. ToolTipsText(205, money) .. "#R#n#r" )
	end
end

function CTooltips:InsertActivationInfo(nItemID, Tips, nNum,nIndex)
	local itemDynInfo = g_DynItemInfoMgr:GetDynItemInfo(nItemID)
	Tips[nNum] = {}
	
	if itemDynInfo.uState == 1 then
		table.insert(Tips[nNum],ColorTbl["����״̬"] .. ToolTipsText(401) .. "#n#r")
	else
		table.insert(Tips[nNum],ColorTbl["����״̬"] .. ToolTipsText(403) .. "#n#r")
	end
	
	local total_num = Exp_Soul_Bottle_Common(nIndex,"StorageNum")
	local cur_num = 0
	if itemDynInfo.uStorageNum then
		cur_num = itemDynInfo.uStorageNum
	end
	Tips[nNum+1] = {}
	table.insert(Tips[nNum],ColorTbl["�洢״̬"] .. ToolTipsText(402, cur_num,total_num) .. "#n#r")

end

--���ToolTips ��������ֵ
function CTooltips:Completed(Tips)
	assert(Tips)

	local strTips = ""
	for i=0, table.maxn(Tips) do
		if Tips[i] ~= nil then
			for v=1, table.maxn(Tips[i]) do
				strTips = strTips .. Tips[i][v]
			end
		end
	end

	--	--print("Tooltips = ", strTips)
	return strTips
end

--����ToolTips����
function CTooltips:GetItemToolTips(nBigID, nIndex, nItemID, foldCount, bOriginalPrice,GoldType,BindingStyle)
	assert(IsNumber(nBigID))
	assert(1<=nBigID and nBigID <= table.maxn(self._m_Func))
	assert(IsNumber(nItemID))
	-- �������ǰ��
	local Tips = {}
	if self:GetVerb() == true then
		Tips[0] = {}
		local Str = string.format("#V����id:%d,#rС��id:%s,#rȫ��id:%d#r",nBigID, nIndex, nItemID)
		table.insert(Tips[0], Str)
	end
	
	if nItemID ~= 0 then
		local item = g_DynItemInfoMgr:GetDynItemInfo(nItemID)
		if( item and 0 == item.m_nLifeTime ) then --���ڵļ�ʱ��Ʒ
			local _, sTimeOutName = g_ItemInfoMgr:GetItemLifeInfo(nBigID, nIndex)
			if( sTimeOutName ) then
				self:GetLifeItemCommonTooltips(Tips, nBigID, nIndex, sTimeOutName)
			else
				self:GetItemCommonTooltips(Tips, nBigID, nIndex)
			end
		else
			self:GetItemCommonTooltips(Tips, nBigID, nIndex)
		end
	else
		self:GetItemCommonTooltips(Tips, nBigID, nIndex)
	end

	-- ���￪ʼ������������װ
	if nBigID >= 1 then
		if nBigID >= 5 and nBigID <= 9 then
			--self._m_Func[nBigID](self, nBigID, nIndex, nItemID, Tips, bOriginalPrice,GoldType)
		else
			self._m_Func[nBigID](self, Tips, nBigID, nIndex, nItemID, foldCount, bOriginalPrice,GoldType,BindingStyle)
		end
	end

	return self:Completed(Tips)
end

--[[
#n ������ǰ��Ⱦ״̬
#r ����
#W ��ɫ
--]]

function CTooltips:GetQualityColor(nBigID, nIndex)
	local quality = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"Quality")
	--��ɫ,��ɫ,��ɫ,��ɫ,��ɫ,��ɫ
	local colorTbl = {[0] = g_ColorMgr:GetColor("ϡ0"),
	 					g_ColorMgr:GetColor("ϡ1"), 
	 					g_ColorMgr:GetColor("ϡ2"), 
						g_ColorMgr:GetColor("ϡ3"),
						g_ColorMgr:GetColor("ϡ4"), 
						g_ColorMgr:GetColor("ϡ5"),
						g_ColorMgr:GetColor("ϡ6"),
						g_ColorMgr:GetColor("ϡ7")
					}
	return colorTbl[quality]
end


function GetJiFenTypeStr(type)
	JiFenTypeStr = {}
	JiFenTypeStr[1] = ToolTipsText(251) --��Ȼ����
	JiFenTypeStr[2] = ToolTipsText(252) --���ڻ���
	JiFenTypeStr[3] = ToolTipsText(253) --�ƻ�����
	JiFenTypeStr[4] = ToolTipsText(254) --�Ƕ�������
	JiFenTypeStr[5] = ToolTipsText(255) --����������
	JiFenTypeStr[6] = ToolTipsText(256) --���׻���
	JiFenTypeStr[6] = ToolTipsText(256) --���׻���
	JiFenTypeStr[7] = ToolTipsText(298) --��ɱ����
	JiFenTypeStr[8] = ToolTipsText(299) --Ⱥ������
	JiFenTypeStr[9] = ToolTipsText(300) --Ⱥ������
	JiFenTypeStr[10] = ToolTipsText(1200) --�Ź�����
	return JiFenTypeStr[type]
end

--�õ���ƷӦ����ʾ�ļ۸���Ϣ����
function CTooltips:GetItemPriceByPayType(nBigID, nIndex, originPriceFlag,eGoldType)
    local priceRate = 1
    if originPriceFlag ~= EToolTipsPayType.Sale then
        priceRate = 1/4
    end
    
    if g_GameMain.m_NPCShopSell.m_ShopOpenFlag 
		and g_GameMain.m_NPCShopSell.m_PayType ~= 0  then
        local jiFenType = g_GameMain.m_NPCShopSell.m_PayType
        local jiFenPrice = GetItemJiFenPrice(nBigID, nIndex, priceRate, jiFenType)
        local jiFenPriceDesc = jiFenPrice .. GetJiFenTypeStr(jiFenType)
        return jiFenPriceDesc
    else
        local price = math.ceil(g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"Price") * priceRate)
        local priceDesc = c_money:ChangeMoneyToString(price,eGoldType)
        return priceDesc
    end
end

-- ���е���Ʒ�Ķ��е���ʾ���Բ���
function CTooltips:GetItemCommonTooltips(Tips, nBigID, nIndex)
	--ÿ�������Լ���ɺ����һ������
	assert(Tips and nBigID and nIndex)
	if nBigID >= 5 and nBigID <= 9 then	 --��Ϊװ������ɫ���Ʋ�ͬ��������Ʒ
		return
	end
	if nBigID == 19 and string.find(nIndex, ":") ~= nil then    --����ǻ���
		nIndex ,_ =  g_ItemInfoMgr:GetSoulpearlInfo(nIndex)
	end
	-- ��װ��һ����
	Tips[1] = {}
	local color = self:GetQualityColor(nBigID, nIndex)
	local DisplayName = g_ItemInfoMgr:GetItemLanInfo(nBigID, nIndex,"DisplayName")
	local str = color .. DisplayName .. "#n" .. "#r"
	table.insert(Tips[1], str)
end

--���ڵļ�ʱ��Ʒ������
function CTooltips:GetLifeItemCommonTooltips(Tips, nBigID, nIndex, sName)
	assert(Tips and nBigID and nIndex)
	-- ��װ��һ����
	Tips[1] = {}
	local color = self:GetQualityColor(nBigID, nIndex)
	local str = color .. sName .. "#n" .. "#r"
	table.insert(Tips[1], str)
end

--��ͨ��Ʒtooltips(����:1)
function CTooltips:GetMatrialCommonTips(Tips, nBigID, nIndex, nItemID, foldCount, bOriginalPrice,GoldType,BindingStyle)
	assert( Tips and nBigID and nIndex)
	assert( IsNumber(nBigID) )
	local BindingStyle = BindingStyle or g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BindingStyle")
	local FoldLimit = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"FoldLimit")
	local nLeftTime = self:InsertBindingType( nItemID,BindingStyle, Tips, 2 )
	self:ItemNumLimit( nBigID, nIndex,Tips, 3 )
	self:InsertLeftTime( nLeftTime, Tips, 4 )
	self:InsertDescription( nBigID, nIndex, Tips, 5 )
	self:InsertFoldLimit(FoldLimit, Tips, 6 )
	self:InsertSellPrice( {nBigID, nIndex, bOriginalPrice,GoldType},Tips, 7 )
end

--��ͨ����tooltips(����:2)
function CTooltips:GetPlayerBagCommonTips(Tips, nBigID, nIndex, nItemID, foldCount, bOriginalPrice,GoldType,BindingStyle)
	assert( Tips and nBigID and nIndex)
	assert( IsNumber(nBigID) )
	local BindingStyle = BindingStyle or g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BindingStyle")
	local BaseLevel = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BaseLevel")
	local BagRoom = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BagRoom")
	local nLeftTime = self:InsertBindingType( nItemID,BindingStyle, Tips, 2 )
	self:ItemNumLimit( nBigID, nIndex, Tips, 3 )
	self:InsertBaseLevel( BaseLevel, Tips, 4 )
	Tips[5] = {}
	table.insert( Tips[5], ColorTbl["��������"] .. ToolTipsText(210,BagRoom) )
	self:InsertLeftTime( nLeftTime, Tips, 6 )
	self:InsertDescription( nBigID, nIndex, Tips, 7 )
	self:InsertSellPrice( {nBigID, nIndex, bOriginalPrice, GoldType},Tips, 8 )
end

-- ��ͨҩƷ��Tooltips(����:3)
function CTooltips:GetSkillItemsCommonTips(Tips, nBigID, nIndex, nItemID, foldCount, bOriginalPrice,GoldType,BindingStyle)
	assert(Tips and nBigID and nIndex)
	local BindingStyle = BindingStyle or g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BindingStyle")
	local BaseLevel = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BaseLevel")
	local FoldLimit = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"FoldLimit")
	local nLeftTime = self:InsertBindingType( nItemID,BindingStyle, Tips, 2 )
	self:ItemNumLimit( nBigID, nIndex, Tips, 3 )
	self:InsertBaseLevel(BaseLevel, Tips, 4 )
	self:InsertLeftTime( nLeftTime, Tips, 5 )
	self:InsertDescription( nBigID, nIndex, Tips, 6 )
	self:InsertUseEffect( nBigID, nIndex, Tips, 7 )
	self:InsertFoldLimit( FoldLimit, Tips, 8 )
	self:InsertSellPrice( {nBigID, nIndex, bOriginalPrice, GoldType},Tips, 9 )
end

local function GetFoldBoxItemOpenedFlag(nItemID)
    local itemDynInfo = g_DynItemInfoMgr:GetDynItemInfo(nItemID)
    
    local nRoomIndex, nPos = g_GameMain.m_BagSpaceMgr:FindItemRoomAndPosByItemID(nItemID)

    if nRoomIndex == nil or nPos == nil then
        return false
    end
  
    local Space = g_GameMain.m_BagSpaceMgr:GetSpace(nRoomIndex)
    local Grid = Space:GetGrid(nPos)


    for v, i in Grid.m_Room:enum(Grid.m_Room:head(), Grid.m_Room:tail()) do
    	local id = v:GetItemID()
    	if(nItemID ~= id) then
    		local dynInfo = g_DynItemInfoMgr:GetDynItemInfo(id)
            if dynInfo.OpenedFlag then
                return true 
            end
	    end
	end
	return false
end  

function CTooltips:InsertOpendFlag(nItemID,  Tips, Num)
    local str = ""
    if nItemID == 0 then
        str = GetStaticTextClient(1231)
    else
        local dynInfo = g_DynItemInfoMgr:GetDynItemInfo(nItemID)
        local foldBoxitemOpenedFlag = GetFoldBoxItemOpenedFlag(nItemID)
        if dynInfo.OpenedFlag or foldBoxitemOpenedFlag  then
            str = GetStaticTextClient(1230)
        else
            str = GetStaticTextClient(1231)
        end
        
    end
    Tips[Num] = {}
    table.insert( Tips[Num], str .. "#n#r")
end  

--������Ʒtooltips(����:24)
function CTooltips:GetBoxItemCommonTips( Tips, nBigID, nIndex, nItemID, foldCount, bOriginalPrice,GoldType,BindingStyle)
	assert( Tips and nBigID and nIndex)
	assert( IsNumber(nBigID) )
	local BindingStyle = BindingStyle or g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BindingStyle")
	local BaseLevel = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BaseLevel")
	local nLeftTime = self:InsertBindingType( nItemID, BindingStyle, Tips, 2 )
	local FoldLimit = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"FoldLimit")
	self:InsertOpendFlag(nItemID,  Tips, 3 )
	self:ItemNumLimit( nBigID, nIndex, Tips, 4 )
	self:InsertBaseLevel(BaseLevel, Tips,5 )
	self:InsertLeftTime( nLeftTime, Tips, 6 )
	self:InsertDescription( nBigID, nIndex, Tips, 7 )
	Tips[8] = {}
	table.insert( Tips[8], ColorTbl["�Ҽ����"] .. ToolTipsText(281) .. "#n" .. "#r" )
	self:InsertFoldLimit( FoldLimit, Tips, 9 )
	self:InsertSellPrice( {nBigID, nIndex, bOriginalPrice, GoldType},Tips, 10 )
end

--���������Ʒtooltips(����:23)
function CTooltips:GetTongSmeltItemCommonTips( Tips, nBigID, nIndex, nItemID, foldCount, bOriginalPrice,GoldType,BindingStyle)
	assert( Tips and nBigID and nIndex)
	assert( IsNumber(nBigID) )
	local BindingStyle = BindingStyle or g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BindingStyle")
	local BaseLevel = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BaseLevel")
	local FoldLimit = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"FoldLimit")
	local nLeftTime = self:InsertBindingType( nItemID, BindingStyle, Tips, 2 )
	self:ItemNumLimit( nBigID, nIndex, Tips, 3 )
	self:InsertBaseLevel(BaseLevel, Tips, 4 )
	self:InsertLeftTime( nLeftTime, Tips, 5 )
	self:InsertDescription( nBigID, nIndex, Tips, 6 )
	self:InsertFoldLimit( FoldLimit, Tips, 7 )
	self:InsertSellPrice( {nBigID, nIndex, bOriginalPrice,GoldType },Tips, 8 )
end

--��ʯ��ǶTooTips(����:14)
function CTooltips:GetStoneCommonTips(Tips, nBigID, nIndex, nItemID, foldCount, bOriginalPrice,GoldType,BindingStyle)
	assert(Tips and nBigID and nIndex)
	local BindingStyle = BindingStyle or g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BindingStyle")
	local BaseLevel = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BaseLevel")
	local FoldLimit = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"FoldLimit")
	local AttrValue = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"AttrValue")
	
	local nLeftTime = self:InsertBindingType( nItemID,BindingStyle, Tips, 2 )
	Tips[3] = {}
	table.insert( Tips[3], ColorTbl["��ʯ����"] .. g_ItemInfoMgr:GetItemLanInfo(nBigID, nIndex,"ShowStoneType") .. "#n#r" )
	self:InsertBaseLevel( BaseLevel, Tips, 4 )
	Tips[5] = {}
	table.insert( Tips[5], ColorTbl["��ʯ����"] .. g_ItemInfoMgr:GetItemLanInfo(nBigID, nIndex,"ShowAttrType") .. "+" .. AttrValue .. "#n#r")
	self:InsertLeftTime( nLeftTime, Tips, 6 )
	self:InsertDescription( nBigID, nIndex, Tips, 7 )
	self:InsertFoldLimit( FoldLimit, Tips, 8 )
	self:InsertSellPrice( {nBigID, nIndex, bOriginalPrice,GoldType}, Tips, 9 )
end

--��ײ���tooltips(����:15)
function CTooltips:GetHoleMaterialCommonTips(Tips, nBigID, nIndex, nItemID, foldCount, bOriginalPrice,GoldType,BindingStyle)
	assert(Tips and nBigID and nIndex)
	local BindingStyle = BindingStyle or g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BindingStyle")
	local FoldLimit = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"FoldLimit")
	local nLeftTime = self:InsertBindingType( nItemID,BindingStyle, Tips, 2 )
	Tips[3] = {}
	table.insert( Tips[3], ColorTbl["ʹ�õȼ�"] .. ToolTipsText(211) )
	self:InsertLeftTime( nLeftTime, Tips, 4 )
	self:InsertDescription( nBigID, nIndex, Tips, 5 )
	self:InsertFoldLimit( FoldLimit, Tips, 6 )
	self:InsertSellPrice( {nBigID, nIndex, bOriginalPrice, GoldType},Tips, 7 )
end

--������Ʒtooltips(����:16)
function CTooltips:GetQuestVarCommonTips(Tips, nBigID, nIndex, nItemID, foldCount, bOriginalPrice,GoldType,BindingStyle)
	assert(Tips and nBigID and nIndex)
	local BindingStyle = BindingStyle or g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BindingStyle")
	local FoldLimit = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"FoldLimit")
	Tips[2] = {}
	table.insert(Tips[2], ColorTbl["����"] .. ToolTipsText(212))
	local nLeftTime = self:InsertBindingType( nItemID,BindingStyle, Tips, 3 )
	self:ItemNumLimit( nBigID, nIndex, Tips, 4 )
	self:InsertUseEffect( nBigID, nIndex, Tips, 5 )
	self:InsertLeftTime( nLeftTime, Tips, 6 )
	self:InsertDescription( nBigID, nIndex, Tips, 7 )
	self:InsertFoldLimit( FoldLimit, Tips, 8 )
end

--�ʼ�������Ʒtooltips
function CTooltips:GetMailCommonTips(Tips, nBigID, nIndex, nItemID, foldCount, bOriginalPrice,GoldType,BindingStyle)
	assert(Tips and nBigID and nIndex)
	local BindingStyle = BindingStyle or g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BindingStyle")
	local color = self:GetQualityColor(nBigID,nIndex)

	Tips[1] = {}
	local str = ToolTipsText(221)
	local sender_name = ""
	local nBindingType = BindingStyle
	local nLeftTime = 0
	if 0 ~= nItemID then
		local mailInfo = g_DynItemInfoMgr:GetDynItemInfo(nItemID)
		if mailInfo then
			nBindingType = mailInfo.BindingType
			nLeftTime = mailInfo.m_nLifeTime
			if mailInfo.sMailTitle then
				str = mailInfo.sMailTitle
			end
			if mailInfo.sSenderName then
				sender_name = mailInfo.sSenderName
			end
		end
	end
	table.insert( Tips[1], color .. str .. "#n#r")

	Tips[2] = {}
	table.insert( Tips[2],  self:GetBindingStyle(nBindingType,nItemID) )
	Tips[3] = {}
	table.insert( Tips[3], ColorTbl["����������"] .. ToolTipsText(222, sender_name) )
	self:InsertLeftTime( nLeftTime, Tips, 4 )
	Tips[5] = {}
	table.insert( Tips[5], ColorTbl["�Ҽ����"] .. ToolTipsText(223))
end

--�ױ�ʯtooltips(����:18)
function CTooltips:GetWhiteStoneCommonTips(Tips, nBigID, nIndex, nItemID, foldCount, bOriginalPrice,GoldType,BindingStyle)
	assert(Tips and nBigID and nIndex)
	local BindingStyle = BindingStyle or g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BindingStyle")

	local nLeftTime = self:InsertBindingType( nItemID,BindingStyle, Tips, 2 )
	self:InsertLeftTime( nLeftTime, Tips, 3 )
	Tips[4] = {}
	table.insert(Tips[4], ColorTbl["��ʯʹ������"] .. ToolTipsText(213) )
	Tips[5] = {}
	table.insert(Tips[5], ColorTbl["�Ҽ����"] .. ToolTipsText(214) )
end

--����
function CTooltips:GetSoulPearlCommonTips(Tips, nBigID, nIndex, nItemID, foldCount, bOriginalPrice,GoldType,BindingStyle)
	assert(Tips and nBigID and nIndex)
	nIndex, soulpearlCount = g_ItemInfoMgr:GetSoulpearlInfo(nIndex)

	Tips[2] = {}
	local nBindingType = BindingStyle or 1
	local nSoulNum = 0
	local nLeftTime = 0
	if 0 ~= nItemID then
		local item = g_DynItemInfoMgr:GetDynItemInfo(nItemID)
		if item then
			nBindingType = item.BindingType
			nLeftTime = item.m_nLifeTime
			nSoulNum = item.nSoulNum
		end
	else
	    nSoulNum = soulpearlCount
	end
	table.insert( Tips[2], self:GetBindingStyle(nBindingType,nItemID) )
	
	local sSoulNum = ToolTipsText(219, nSoulNum)
	local sClick = ToolTipsText(220)
	local SoulType = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"SoulType")
	if SoulType == 2 then --������
		sSoulNum = ToolTipsText(294, nSoulNum)
		sClick = ToolTipsText(295)
	elseif SoulType == 3 then --������
		local AreaFbPointType	= g_ItemInfoMgr:GetItemInfo(nBigID, nIndex, "AreaFbPointType")
		local sDisplayName		= g_DisplayCommon.m_tblAreaFbPoinDisplay[AreaFbPointType]
		sSoulNum = ToolTipsText(320, sDisplayName, nSoulNum)
		sClick = ToolTipsText(321, sDisplayName)
	end
	Tips[3] = {}
	table.insert( Tips[3], ColorTbl["�����ֵ"] .. sSoulNum )
	self:InsertLeftTime( nLeftTime, Tips, 4 )
	local BaseLevel = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BaseLevel")
	self:InsertBaseLevel( BaseLevel, Tips, 5 )
	self:InsertDescription( nBigID, nIndex, Tips, 6 )
	Tips[7] = {}
	table.insert( Tips[7], ColorTbl["�Ҽ����"] .. sClick )
	Tips[8] = {}
	
	local soulpearlPrice = GetSoulpearlPriceInfo(nIndex,nSoulNum, nil, 1/4, GoldType)
	table.insert(Tips[8], ColorTbl["���ۼ۸�"] .. ToolTipsText(205, soulpearlPrice) )
end

--�ı�����Ʒtooltips(����:25)
function CTooltips:GetTextItemCommonTips(Tips, nBigID, nIndex, nItemID, foldCount, bOriginalPrice,GoldType,BindingStyle)
	assert(Tips and nBigID and nIndex)
	local BindingStyle = BindingStyle or g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BindingStyle")
	local BaseLevel = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BaseLevel")
	local nLeftTime = self:InsertBindingType( nItemID,BindingStyle, Tips, 2 )
	self:ItemNumLimit( nBigID, nIndex, Tips, 3 )
	self:InsertBaseLevel( BaseLevel, Tips, 4 )
	self:InsertLeftTime( nLeftTime, Tips, 5 )
	self:InsertDescription( nBigID, nIndex, Tips, 6 )
	Tips[7] = {}
	table.insert( Tips[7], ColorTbl["�Ҽ����"] .. ToolTipsText(215) )
	self:InsertSellPrice( {nBigID, nIndex, bOriginalPrice, GoldType},Tips, 8 )
end

--װ����������tooltips(����:31)
function CTooltips:GetEquipIdentifyScrollCommonTips(Tips, nBigID, nIndex, nItemID, foldCount, bOriginalPrice,GoldType,BindingStyle)
	assert(Tips and nBigID and nIndex)
	local BindingStyle = BindingStyle or g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BindingStyle")
	local BaseLevel = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BaseLevel")
	local nLeftTime = self:InsertBindingType( nItemID,BindingStyle, Tips, 2 )
	self:ItemNumLimit( nBigID, nIndex, Tips, 3 )
	self:InsertBaseLevel(BaseLevel, Tips, 4 )
	self:InsertDescription( nBigID, nIndex, Tips, 5 )
	self:InsertSellPrice( {nBigID, nIndex, bOriginalPrice,GoldType}, Tips, 6 )
end

--����Ƭtooltips(����:34)
function CTooltips:GetArmorPieceCommonTips(Tips, nBigID, nIndex, nItemID, foldCount, bOriginalPrice,GoldType,BindingStyle)
	assert(Tips and nBigID and nIndex)
	local BindingStyle = BindingStyle or g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BindingStyle")
	local BaseLevel = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BaseLevel")
	local nLeftTime = self:InsertBindingType( nItemID, BindingStyle, Tips, 2 )
	self:ItemNumLimit( nBigID, nIndex, Tips, 3 )
	self:InsertUseLevelLimit( nBigID, nIndex, Tips ,4)
	self:InsertDescription( nBigID, nIndex, Tips, 5 )
	self:InsertSellPrice( {nBigID, nIndex, bOriginalPrice,GoldType}, Tips, 6 )
end

--װ�����������tooltips(����:36)
function CTooltips:GetEquipSmeltSoulScrollCommonTips(Tips, nBigID, nIndex, nItemID, foldCount, bOriginalPrice,GoldType,BindingStyle)
	assert(Tips and nBigID and nIndex)
	local BindingStyle = BindingStyle or g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BindingStyle")
	local BaseLevel = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BaseLevel")
	local nLeftTime = self:InsertBindingType( nItemID,BindingStyle, Tips, 2 )
	self:ItemNumLimit( nBigID, nIndex, Tips, 3 )
	self:InsertBaseLevel( BaseLevel, Tips, 4 )
	self:InsertDescription( nBigID, nIndex, Tips, 5 )
	self:InsertSellPrice( {nBigID, nIndex, bOriginalPrice,GoldType}, Tips, 6 )
end

--���޵�tooltips(����:41)
function CTooltips:GetPetEggCommonTips(Tips, nBigID, nIndex, nItemID,payType,GoldType,BindingStyle)
	assert(Tips and nBigID and nIndex)
	local BindingStyle = BindingStyle or g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BindingStyle")
	local nLeftTime = self:InsertBindingType( nItemID,BindingStyle, Tips, 2 )
	self:ItemNumLimit( nBigID, nIndex, Tips, 3 )
	self:InsertDescription( nBigID, nIndex, Tips, 4 )
	self:InsertSellPrice( {nBigID, nIndex, payType,GoldType}, Tips,5)
end

--������ʯtooltips(����:42)
function CTooltips:GetPetSkillStoneCommonTips(Tips, nBigID, nIndex, nItemID,payType,GoldType,BindingStyle)
	assert(Tips and nBigID and nIndex)
	local BindingStyle = BindingStyle or g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BindingStyle")
	local nLeftTime = self:InsertBindingType( nItemID,BindingStyle, Tips, 2 )
	self:ItemNumLimit( nBigID, nIndex, Tips, 3 )
	self:InsertDescription( nBigID, nIndex, Tips, 4 )
	self:InsertSellPrice( {nBigID, nIndex, payType,GoldType}, Tips,5)
end

--����ƿ����ƿtooltips(����:48)
function CTooltips:GetExpAndSoulBottleCommonTips(Tips, nBigID, nIndex, nItemID, foldCount, bOriginalPrice,GoldType,BindingStyle)
	assert(Tips and nBigID and nIndex)
	local BindingStyle = BindingStyle or g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BindingStyle")
	local BaseLevel = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BaseLevel")
	local nLeftTime = self:InsertBindingType( nItemID,BindingStyle, Tips, 2 )
	self:ItemNumLimit( nBigID, nIndex, Tips, 3 )
	self:InsertBaseLevel(BaseLevel, Tips, 4 )
	self:InsertDescription( nBigID, nIndex, Tips, 5 )
	self:InsertActivationInfo(nItemID, Tips, 6,nIndex)
	self:InsertSellPrice( {nBigID, nIndex, bOriginalPrice,GoldType}, Tips, 8 )
end

--vip����tooltips(����:51)
function CTooltips:GetVIPItemCommonTips(Tips, nBigID, nIndex, nItemID, foldCount, bOriginalPrice,GoldType,BindingStyle)
	assert(Tips and nBigID and nIndex)
	local BindingStyle = BindingStyle or g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BindingStyle")
	local nLeftTime = self:InsertBindingType( nItemID,BindingStyle, Tips, 2 )
	self:ItemNumLimit( nBigID, nIndex, Tips, 3 )
	self:InsertDescription( nBigID, nIndex, Tips, 4 )
	self:InsertSellPrice( {nBigID, nIndex, payType,GoldType}, Tips,5)
end

--С�ӵ���tooltips(����:52)
function CTooltips:GetTongItemCommonTips(Tips, nBigID, nIndex, nItemID, foldCount, bOriginalPrice,GoldType,BindingStyle)
	assert(Tips and nBigID and nIndex)
	local BindingStyle = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BindingStyle")
	self:ItemTongPurview( nBigID, nIndex, Tips, 2 )
	self:InsertDescription( nBigID, nIndex, Tips, 3 )
end

--����tooltips(����:26)
function CTooltips:GetBattleArrayBooksCommonTips(Tips, nBigID, nIndex, nItemID, foldCount, bOriginalPrice,GoldType)
	assert(Tips and nBigID and nIndex)
	local BindingStyle = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BindingStyle")
	local BaseLevel = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BaseLevel")
	local nLeftTime = self:InsertBindingType( nItemID, BindingStyle, Tips, 2 )
	self:ItemNumLimit( nBigID, nIndex, Tips, 3 )
	self:InsertBaseLevel( BaseLevel, Tips, 4 )
	self:InsertLeftTime( nLeftTime, Tips, 5 )
	self:InsertDescription( nBigID, nIndex, Tips, 6 )

	Tips[7] = {}
	local str = ""
	if 0 ~= nItemID then
		local bookInfo = g_DynItemInfoMgr:GetDynItemInfo(nItemID)
		str = bookInfo.pos1 and ToolTipsText(216) or ToolTipsText(217)
	end
	table.insert(Tips[7], ColorTbl["����"] .. str)

	Tips[8] = {}
	table.insert( Tips[8], ColorTbl["�Ҽ����"] .. ToolTipsText(218) )
	self:InsertSellPrice( {nBigID, nIndex, bOriginalPrice,GoldType}, Tips, 9 )
end

--�������̥����tooltips(����:27)
function CTooltips:GetEmbryoItemCommonTips(Tips, nBigID, nIndex, nItemID, foldCount, bOriginalPrice,GoldType,BindingStyle)
	assert(Tips and nBigID and nIndex)
	local BindingStyle = BindingStyle or g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BindingStyle")
	local FoldLimit = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"FoldLimit")
	local nLeftTime = self:InsertBindingType( nItemID,BindingStyle, Tips, 2 )
	self:ItemNumLimit( nBigID, nIndex, Tips, 3 )
	self:InsertFoldLimit( FoldLimit, Tips, 4 )
	self:InsertLeftTime( nLeftTime, Tips, 5 )
	self:InsertDescription( nBigID, nIndex, Tips, 6 )
	self:InsertSellPrice( {nBigID, nIndex, bOriginalPrice,GoldType}, Tips, 7 )
end

--�����Ʒ�ʲ���tooltips(����:28)
function CTooltips:GetQualityMaterialItemCommonTips(Tips, nBigID, nIndex, nItemID, foldCount, bOriginalPrice,GoldType,BindingStyle)
	assert(Tips and nBigID and nIndex)
	local BindingStyle = BindingStyle or g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BindingStyle")
	local FoldLimit = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"FoldLimit")
	local nLeftTime = self:InsertBindingType( nItemID, BindingStyle, Tips, 2 )
	self:ItemNumLimit( nBigID, nIndex, Tips, 3 )
	self:InsertLeftTime( nLeftTime, Tips, 4 )
	self:InsertDescription( nBigID, nIndex, Tips, 5 )
	self:InsertFoldLimit( FoldLimit, Tips, 6 )
	self:InsertSellPrice( {nBigID, nIndex, bOriginalPrice,GoldType}, Tips, 7 )
end

--���ͼtooltips(����:30)
function CTooltips:GetOreMapCommonTips(Tips, nBigID, nIndex, nItemID, foldCount, bOriginalPrice,GoldType,BindingStyle)
	assert( Tips and nBigID and nIndex)
	assert( IsNumber(nBigID) )
	local BindingStyle = BindingStyle or g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BindingStyle")
	local FoldLimit = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"FoldLimit")
	local ImmeEnter = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"ImmeEnter")
	if 0 ~= nItemID then
		if ImmeEnter == 0 then
			local item = g_DynItemInfoMgr:GetDynItemInfo(nItemID)
			if item then
				local sceneName = item.sceneName
				if sceneName ~= nil and sceneName ~= "" then
					local CampTbl = {[1] = 2501, [2] = 2502, [3] = 2503}
					local camp = Scene_Common[sceneName].Camp
					local str = ""
					if camp ~= g_GameMain.m_PlayerInfoTbl.m_PlayerBirthCamp and CampTbl[camp] then
						str = ToolTipsText(293)
					end
					Tips[3] = {}
					table.insert(Tips[3], ColorTbl["������ͼ"] .. ToolTipsText(270, GetSceneDispalyName(sceneName)) .. ColorTbl["�ж���Ӫ"] .. str )
				end
			end
		end
	end
	local nLeftTime = self:InsertBindingType( nItemID, BindingStyle, Tips, 2 )
	local BaseLevel = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BaseLevel")
	self:InsertBaseLevel( BaseLevel, Tips, 4 )
	local tbl = g_GameMain.m_LiveSkillMainWnd:GetSkillInfoByName("�ɿ�")
	local player_skill_level = 1
	if tbl then
		player_skill_level = tbl[2]
	end
	local nSkillLevel = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"SkillLevel")
	local color = ColorTbl["ʹ�õȼ�"]
	if player_skill_level < nSkillLevel then
		color = ColorTbl["�ȼ�����"]
	end
	Tips[5] = {}
	table.insert(Tips[5], color .. ToolTipsText(404, nSkillLevel))
	
	self:ItemNumLimit( nBigID, nIndex,Tips, 6 )
	self:InsertLeftTime( nLeftTime, Tips, 7 )
	self:InsertDescription( nBigID, nIndex, Tips, 8 )
	self:InsertFoldLimit( FoldLimit, Tips, 9 )
	self:InsertSellPrice( {nBigID, nIndex, bOriginalPrice,GoldType}, Tips, 10 )
end

--�ɿ󹤾�tooltips(����:45)
function CTooltips:GetPickOreCommonTips(Tips, nBigID, nIndex, nItemID, foldCount, bOriginalPrice,GoldType,BindingStyle)
	assert( Tips and nBigID and nIndex)
	assert( IsNumber(nBigID) )
	local BindingStyle = BindingStyle or g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BindingStyle")
	local FoldLimit = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"FoldLimit")
	local DescType = g_ItemInfoMgr:GetItemLanInfo(nBigID,nIndex,"DescType")
	local MaxDura = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"MaxDurabilityValue")
	local CurDura = MaxDura
	if 0 ~= nItemID then
		local item = g_DynItemInfoMgr:GetDynItemInfo(nItemID)
		if item and IsNumber(item.MaxDura) then
			MaxDura = item.MaxDura
			CurDura = item.CurDura
		end
	end
	local duraInfo = DescType .. "#R" .. ToolTipsText(306)
	if CurDura == 0 then 
		duraInfo = ColorTbl["��������ɫ"] .. duraInfo
	else
		duraInfo = ColorTbl["�;úͲ�λ"] .. duraInfo
	end
	duraInfo = duraInfo .. CurDura .. "/" .. MaxDura
	Tips[3] = {}
	table.insert(Tips[3], duraInfo .. "#r")
	local nLeftTime = self:InsertBindingType( nItemID, BindingStyle, Tips, 2 )
	self:ItemNumLimit( nBigID, nIndex,Tips, 4 )
	self:InsertLeftTime( nLeftTime, Tips, 5 )
	self:InsertDescription( nBigID, nIndex, Tips, 6 )
	self:InsertFoldLimit( FoldLimit, Tips, 7 )
	self:InsertSellPrice( {nBigID, nIndex, bOriginalPrice,GoldType}, Tips, 8 )
end

function CTooltips:GetFlowerCommonTips(Tips, nBigID, nIndex, nItemID, foldCount, bOriginalPrice,GoldType,BindingStyle)
	assert( Tips and nBigID and nIndex)
	assert( IsNumber(nBigID) )
	local BindingStyle = BindingStyle or g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BindingStyle")
	local FoldLimit = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"FoldLimit")
	Tips[3] = {}
	table.insert( Tips[3], ColorTbl["ʹ�õȼ�"] .. ToolTipsText(600, g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"SkillLevel")) )
	local nLeftTime = self:InsertBindingType( nItemID, BindingStyle, Tips, 2 )
	self:ItemNumLimit( nBigID, nIndex,Tips, 4 )
	self:InsertLeftTime( nLeftTime, Tips, 5 )
	self:InsertDescription( nBigID, nIndex, Tips, 6 )
	self:InsertFoldLimit(FoldLimit, Tips, 7 )
	self:InsertSellPrice( {nBigID, nIndex, bOriginalPrice,GoldType}, Tips, 8 )
end

function CTooltips:GetCofcTruckItemCommonTips(Tips, nBigID, nIndex, nItemID)
end

function CTooltips:GetCreateNpcItemTips(Tips, nBigID, nIndex, nItemID,bOriginalPrice,GoldType,BindingStyle)
	assert( Tips and nBigID and nIndex)
	assert( IsNumber(nBigID) )
	local BindingStyle = BindingStyle or g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BindingStyle")
	local FoldLimit = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"FoldLimit")
	local BaseLevel = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BaseLevel")
	local nLeftTime = self:InsertBindingType( nItemID,BindingStyle, Tips, 2 )
	self:InsertBaseLevel( BaseLevel, Tips, 3 )
	self:ItemNumLimit( nBigID, nIndex,Tips, 4 )
	self:InsertLeftTime( nLeftTime, Tips, 5 )
	self:InsertDescription( nBigID, nIndex, Tips, 6 )
	self:InsertFoldLimit( FoldLimit, Tips, 7 )
	self:InsertSellPrice( {nBigID, nIndex, bOriginalPrice,GoldType}, Tips, 8 )
end

--����ʯ
function CTooltips:GetAdvanceStoneCommonTips(Tips,nBigID,nIndex,nItemID, foldCount, bOriginalPrice,GoldType,BindingStyle)
	assert(Tips and nBigID and nIndex)
	local BindingStyle = BindingStyle or g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BindingStyle")
	local FoldLimit = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"FoldLimit")
	local AdaptedEquipLevelScale = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"AdaptedEquipLevelScale")
	local AddSucProbability = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"AddSucProbability")
	local nLeftTime = self:InsertBindingType( nItemID,BindingStyle, Tips, 2 )
	--�Ƿ�Ψһ
	self:ItemNumLimit(nBigID, nIndex,Tips,3)

	self:InsertLeftTime( nLeftTime, Tips, 4 )

	--����װ���ȼ�����
	Tips[5] = {}
	local LevelScaleDesc = AdaptedEquipLevelScale .. ToolTipsText(274) .. "#r"
	table.insert( Tips[5],  LevelScaleDesc )

	--����ʯ�������׸���
	if AddSucProbability ~= "" and tonumber(AddSucProbability) > 0 then
		Tips[6] = {}
		local AddSucProbabilityDesc = ToolTipsText(275) .. (AddSucProbability *100).. "%#r"
		table.insert( Tips[6],  AddSucProbabilityDesc )
	end
	 
    self:InsertDescription( nBigID, nIndex, Tips, 7 )
	self:InsertFoldLimit( FoldLimit, Tips, 8 )
	self:InsertSellPrice( {nBigID, nIndex, bOriginalPrice,GoldType}, Tips, 9 )
end

--����ʯtooltips
function CTooltips:GetEquipRefineItemCommonTips(Tips,nBigID,nIndex,nItemID, foldCount, bOriginalPrice,GoldType,BindingStyle)
    assert(Tips and nBigID and nIndex)
	local BindingStyle = BindingStyle or g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BindingStyle")
	local FoldLimit = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"FoldLimit")
	local nLeftTime = self:InsertBindingType( nItemID,BindingStyle, Tips, 2 )
	--�Ƿ�Ψһ
	self:ItemNumLimit(nBigID, nIndex,Tips,3)

	self:InsertLeftTime( nLeftTime, Tips, 4 )
	 
    self:InsertDescription( nBigID, nIndex, Tips, 5 )
	self:InsertFoldLimit( FoldLimit, Tips, 6)
	self:InsertSellPrice( {nBigID, nIndex, bOriginalPrice,GoldType}, Tips, 7 )
end

function CTooltips:GetEquipSuperaddItemCommonTips(Tips,nBigID,nIndex,nItemID, foldCount, bOriginalPrice,GoldType,BindingStyle)
    assert(Tips and nBigID and nIndex)
	local BindingStyle = BindingStyle or g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"BindingStyle")
	local FoldLimit = g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"FoldLimit")
	local nLeftTime = self:InsertBindingType( nItemID,BindingStyle, Tips, 2 )
	--�Ƿ�Ψһ
	self:ItemNumLimit(nBigID, nIndex,Tips,3)

	self:InsertLeftTime( nLeftTime, Tips, 4 )
	 
    self:InsertDescription( nBigID, nIndex, Tips, 5 )
	self:InsertFoldLimit( FoldLimit, Tips, 6)
	self:InsertSellPrice( {nBigID, nIndex, bOriginalPrice,GoldType}, Tips, 7 )
end

--������ƷnBigID��������tooltips����ʾ
function CTooltips:init()
	self._m_Func = {}
	self._m_Func[1] = self.GetMatrialCommonTips       --��ͨ��Ʒ
	self._m_Func[2] = self.GetPlayerBagCommonTips     --��ͨ����
	self._m_Func[3] = self.GetSkillItemsCommonTips         --��ͨҩƷ

	self._m_Func[5] = self.GetWeaponTips  ---???GetWeaponTips �������⣿��
	self._m_Func[6] = self.GetOtherEquipTips
	self._m_Func[7] = self.GetShieldTips
	self._m_Func[8] = self.GetRingTips
	self._m_Func[9] = self.GetOtherEquipTips  ---???Ӧ������Ʒ�ѣ�
	self._m_Func[10] = self.GetTongProdItemTips                --���������Ʒ

	self._m_Func[14] = self.GetStoneCommonTips                 --��ʯ
	self._m_Func[15] = self.GetHoleMaterialCommonTips          --��ײ���
	self._m_Func[16] = self.GetQuestVarCommonTips              --������Ʒ
	self._m_Func[17] = self.GetMailCommonTips                  --�ʼ�����
	self._m_Func[18] = self.GetWhiteStoneCommonTips            --�ױ�ʯ
	self._m_Func[19] = self.GetSoulPearlCommonTips             --����
	self._m_Func[23] = self.GetTongSmeltItemCommonTips         --���������Ʒ
	self._m_Func[24] = self.GetBoxItemCommonTips               --������Ʒ
	self._m_Func[25] = self.GetTextItemCommonTips              --�ı���Ʒ
	self._m_Func[26] = self.GetBattleArrayBooksCommonTips      --����
	self._m_Func[27] = self.GetEmbryoItemCommonTips            --�������Ʒ������
	self._m_Func[28] = self.GetQualityMaterialItemCommonTips   --�������ƷƷ�ʲ���
	self._m_Func[29] = self.GetCofcTruckItemCommonTips         --�̻����䳵��Ʒ(����)
	self._m_Func[30] = self.GetOreMapCommonTips                --���ͼ
	self._m_Func[31] = self.GetEquipIdentifyScrollCommonTips   --װ����������
	self._m_Func[32] = self.GetFlowerCommonTips               --����� �ֻ�
	
	self._m_Func[34] = self.GetArmorPieceCommonTips            --����Ƭ
	self._m_Func[36] = self.GetEquipSmeltSoulScrollCommonTips  --װ�����������
	self._m_Func[37] = self.GetMatrialCommonTips               --����������
	self._m_Func[38] = self.GetAdvanceStoneCommonTips          --����ʯ
	self._m_Func[39] = self.GetTongChallengeItemTips					 --�����ս��Ʒ
	self._m_Func[40] = self.GetCreateNpcItemTips							 --�ٻ�NPC��Ʒ
	self._m_Func[41] = self.GetPetEggCommonTips  							--���޵�
	self._m_Func[42] = self.GetPetSkillStoneCommonTips  				--������ʯ
	self._m_Func[43] = self.GetMatrialCommonTips            --������ʯ
	self._m_Func[45] = self.GetPickOreCommonTips            --�ɿ󹤾�
	self._m_Func[46] = self.GetMatrialCommonTips            --�̳ǵ���
	self._m_Func[47] = self.GetBoxItemCommonTips            --�̳ǵ��߱���
	self._m_Func[48] = self.GetExpAndSoulBottleCommonTips  --����ƿ����ƿ
	self._m_Func[49] = self.GetEquipRefineItemCommonTips            --�̳ǵ��߱���
	self._m_Func[50] = self.GetEquipSuperaddItemCommonTips            --�̳ǵ��߱���
	self._m_Func[51] = self.GetVIPItemCommonTips					--VIP����
	self._m_Func[52] = self.GetTongItemCommonTips					--Ӷ��С����Ʒ
end

function CTooltips:SetVerb(bVerb)
	assert(IsBoolean(bVerb))
	self.m_bVerb = bVerb
end

function CTooltips:GetVerb()
	return self.m_bVerb
end

function CTooltips:Ctor()
	self:init()
	self.m_bVerb = false
end

local EquipPartTbl = {}
	EquipPartTbl["Ь��"] = EEquipPart.eShoe
	EquipPartTbl["����"] = EEquipPart.eHand
	EquipPartTbl["�粿"] = EEquipPart.eShoulder
	EquipPartTbl["�·�"] = EEquipPart.eWear
	EquipPartTbl["ͷ��"] = EEquipPart.eHead
	EquipPartTbl["����"] = EEquipPart.eSash
	EquipPartTbl["����"] = EEquipPart.eNecklace
	EquipPartTbl["����"] = EEquipPart.eAccouterment
	EquipPartTbl["����"] = EEquipPart.eBack

function EquipPartStrToNum(EquipPartStr)
	return EquipPartTbl[EquipPartStr]
end

function CTooltips:GetEquipItemAllTips(nBigID,nIndex,GlobalID,num, bOriginalPrice,eGoldType,BindingStyle)
	if g_ItemInfoMgr:IsEquip(nBigID) then
		local RoleStatusWnd = g_GameMain.m_RoleStatus 
		local EquipType	= g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"EquipType")
		local EquipPart	= g_ItemInfoMgr:GetItemInfo(nBigID,nIndex,"EquipPart")
		local ParentToolTip = {nBigID,nIndex,GlobalID,bOriginalPrice,eGoldType,BindingStyle}
		local ChildToolTip1,ChildToolTip2 = nil,nil
		if g_ItemInfoMgr:IsWeapon(nBigID) then --����
			local HandType = GetEquipHandType(EquipType)
			if HandType == "��" or HandType == "˫" then
				ChildToolTip1 = RoleStatusWnd:GetEquipPartToolTips(EEquipPart.eAssociateWeapon)
				ChildToolTip2 = RoleStatusWnd:GetEquipPartToolTips(EEquipPart.eWeapon)
			elseif HandType == "��" then
				ChildToolTip1 = RoleStatusWnd:GetEquipPartToolTips(EEquipPart.eWeapon)
			elseif HandType == "��" then 
				ChildToolTip1 = RoleStatusWnd:GetEquipPartToolTips(EEquipPart.eAssociateWeapon)
			end
		elseif g_ItemInfoMgr:IsArmor(nBigID) -- ����
			or g_ItemInfoMgr:IsJewelry(nBigID) then -- ��Ʒ
			ChildToolTip1 = RoleStatusWnd:GetEquipPartToolTips(EquipPartStrToNum(EquipPart))
		elseif g_ItemInfoMgr:IsRing(nBigID) then -- ��ָ 
			ChildToolTip1 = RoleStatusWnd:GetEquipPartToolTips(EEquipPart.eRingLeft)
			ChildToolTip2 = RoleStatusWnd:GetEquipPartToolTips(EEquipPart.eRingRight)
		elseif g_ItemInfoMgr:IsAssociateWeapon(nBigID) then -- ���ƻ���
			ChildToolTip1 = RoleStatusWnd:GetEquipPartToolTips(EEquipPart.eAssociateWeapon)
		end
		
		
		if ChildToolTip1 ~= nil then
			ChildToolTip1 =ChildToolTip1
		end
		if ChildToolTip2 ~= nil then
			ChildToolTip2 = ChildToolTip2
		end
		return ParentToolTip,ChildToolTip1,ChildToolTip2
	end
	
end
----------------------------------------------------------------------------
g_MultiTipHandler = CMultiToolTipHandler:new()

function CMultiToolTipHandler:OnToolTipShow( Tip )
	local TipWnd = Tip:GetParentWnd()
	if TipWnd.m_TipsInfo then			
		g_Tooltips:CreateEquipTipWnd(Tip,TipWnd.m_TipsInfo)
		local nBigID = TipWnd.m_TipsInfo.m_BigID
		local nIndex = TipWnd.m_TipsInfo.m_Index
		local nItemID = TipWnd.m_TipsInfo.m_ItemID 
		local _,ChildToolTip1,ChildToolTip2 = g_Tooltips:GetEquipItemAllTips(nBigID,nIndex,nItemID)
		local TempToolTip1 = ChildToolTip1 and ChildToolTip1 or ChildToolTip2
		
		local TipChild1 = nil 
		if TempToolTip1 then
			TipChild1 = Tip:GetChildToolTip()
			if TipChild1 == nil then
				Tip:AddChildToolTip()
				TipChild1 = Tip:GetChildToolTip()
			end
			local InfoTbl = {}
			InfoTbl.m_BigID = TempToolTip1[1]
			InfoTbl.m_Index = TempToolTip1[2]
			InfoTbl.m_ItemID = TempToolTip1[3]
			g_Tooltips:CreateEquipTipWnd(TipChild1,InfoTbl,true)
		else
			Tip:ClearChildToolTip()
		end
		if ChildToolTip1 and ChildToolTip2 then
			local TipChild2 = TipChild1:GetChildToolTip()
			if TipChild2 == nil then
				TipChild1:AddChildToolTip()
				TipChild2 = TipChild1:GetChildToolTip()
			end
			local InfoTbl = {}
			InfoTbl.m_BigID = ChildToolTip2[1]
			InfoTbl.m_Index = ChildToolTip2[2]
			InfoTbl.m_ItemID = ChildToolTip2[3]
			g_Tooltips:CreateEquipTipWnd(TipChild2,InfoTbl,true)			
		elseif TipChild1 then
			TipChild1:ClearChildToolTip()
		end
	end
end

local function SetMultiMouseOverDesc(Wnd,ParentToolTipDesc ,...)
	local arg = {...}
	local nBigID,nIndex,nItemID,bOriginalPrice,GoldType,BindingStyle  = unpack(ParentToolTipDesc)
	Wnd.m_TipsInfo = {}
	Wnd.m_TipsInfo.m_BigID = nBigID
	Wnd.m_TipsInfo.m_Index = nIndex
	Wnd.m_TipsInfo.m_ItemID = nItemID
	Wnd.m_TipsInfo.m_PayType = bOriginalPrice
	Wnd.m_TipsInfo.m_GoldType = GoldType
	Wnd.m_TipsInfo.m_BindingStyle = BindingStyle
	Wnd.m_TipsInfo.m_IsAimStatus = Wnd.m_IsAimStatus --�ж��Ƿ�Ŀ����������ϵ�Tooltips
	local ParentTip = Wnd:SetNewRichToolTip()
	ParentTip:SetTipHandler(g_MultiTipHandler)	
	local count = select("#", ...)
	for i = 1 , count do
		if arg[i] then
			ParentTip:AddChildToolTip()
			local ChildToolTip = ParentTip:GetChildToolTip()
			ParentTip = ChildToolTip
		end
	end
end

function g_SetWndMultiToolTips(Wnd,nBigID,nIndex,GlobalID,num, bOriginalPrice,GoldType,BindingStyle) --bOriginalPrice���������������Ƿ���ʾ����۸�
	if g_ItemInfoMgr:IsEquip(nBigID) then
		local ParentToolTip,ChildToolTip1,ChildToolTip2 = g_Tooltips:GetEquipItemAllTips(nBigID,nIndex,GlobalID,num,bOriginalPrice,GoldType,BindingStyle)
		SetMultiMouseOverDesc(Wnd,ParentToolTip,ChildToolTip1,ChildToolTip2)
	else
		g_SetItemRichToolTips(Wnd,nBigID,nIndex,GlobalID,num, bOriginalPrice,GoldType,BindingStyle)
	end
end
-------------------------------------------------------------------------------

EToolTipsType = {}
EToolTipsType.eEquip = 1 --װ��
EToolTipsType.eSkill = 2 --����
 
function CToolTipHandler:OnToolTipShow( Tip )
	local TipWnd = Tip:GetParentWnd()
	if TipWnd.m_TipsInfo and TipWnd.m_TipsInfo.m_eTipsType then
		local TipType = TipWnd.m_TipsInfo.m_eTipsType
		if TipType == EToolTipsType.eEquip then
			g_Tooltips:CreateEquipTipWnd(Tip,TipWnd.m_TipsInfo)
		elseif TipType == EToolTipsType.eSkill then
			
		end
	end
end

g_TipHandler = CToolTipHandler:new()

function g_SetItemRichToolTips(Wnd,nBigID, nIndex, nItemID, foldCount, payType,GoldType,BindingStyle)
	if g_ItemInfoMgr:IsEquip(nBigID) then
		Wnd.m_TipsInfo = {}
		Wnd.m_TipsInfo.m_eTipsType = EToolTipsType.eEquip
		Wnd.m_TipsInfo.m_BigID = nBigID
		Wnd.m_TipsInfo.m_Index = nIndex
		Wnd.m_TipsInfo.m_ItemID = nItemID
		Wnd.m_TipsInfo.FoldCount = foldCount
		Wnd.m_TipsInfo.m_PayType = payType
		Wnd.m_TipsInfo.m_GoldType = GoldType
		Wnd.m_TipsInfo.m_BindingStyle = BindingStyle
		local tip = Wnd:SetNewRichToolTip()
		tip:SetTipHandler(g_TipHandler)
	else
		Wnd:SetMouseOverDescAfter(g_Tooltips:GetItemToolTips(nBigID, nIndex, nItemID, foldCount, payType,GoldType,BindingStyle))
	end
end
-----------------------------------------------------------------------------------------------------
--���Tooltips��Ϣ
local OldSetMouseOverDescAfter = SQRWnd.SetMouseOverDescAfter
function SQRWnd:NewMouseOverDescAfter( str )
	if self.m_TipsInfo then
		self.m_TipsInfo = nil
	end 
	OldSetMouseOverDescAfter(self,str)
end
SQRWnd.SetMouseOverDescAfter = SQRWnd.NewMouseOverDescAfter
