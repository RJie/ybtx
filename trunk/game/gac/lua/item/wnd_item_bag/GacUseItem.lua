gac_gas_require "activity/item/ItemUseInfoMgr"
cfg_load "item/CanUseItem_Common"

local BindingStyle1 = 1
--�Ҽ�����ʼ��ı��������鿴�ʼ�����
--������ParentWnd, nBigID, nSmallID, nRoomIndex, nPos, Item,eEquipPart
local function OpenMailText( ParentWnd, nBigID, nSmallID, nRoomIndex, nPos )
	if g_ItemInfoMgr:IsMailTextAttachment(nBigID) then
		g_WndMouse:ClearCursorAll()
		Gac2Gas:CheckMailTextAttachment(g_Conn,nRoomIndex,nPos)
		return
	end
end

--�����󷨺�ɾ������
local function DelBattleArrayBook( ParentWnd, nBigID, nSmallID, nRoomIndex, nPos, Item )
	local itemId = Item:GetItemID()
	g_GameMain.m_CreateBattleArrayWnd:GetBattleArrayBookInfo(itemId)
	g_GameMain.m_CreateBattleArrayWnd:OpenAndReEdit(nSmallID, 0, itemId) --0�Ӱ�����
	g_GameMain.m_CreateBattleArrayWnd.m_tblTmpBattleArrayBook = {g_StoreRoomIndex.PlayerBag, nPos	}
end

--ʹ�ð�Ὠ�����ᴴ������
local function UseTongBuildingItem( ParentWnd, nBigID, nSmallID, nRoomIndex, nPos, Item )
--	Gac2Gas:CreateBuilding(g_Conn, nSmallID, nRoomIndex, nPos)
	Gac2Gas:ClickItem(g_Conn, nBigID, nSmallID, nRoomIndex, nPos)
end

--������
--local function AnswerResult( QuestionTypeName)
--
--
--	return true
--end
local BoxParameter = nil
local function OpenBoxitem( ParentWnd, nBigID, nSmallID, nRoomIndex, nPos, Item, eEquipPart, srcPos )
		if g_GameMain.m_BoxitemPickupWnd == nil then
			g_GameMain.m_BoxitemPickupWnd = CreateBoxitemPickupWnd(g_GameMain)
		end
		g_GameMain.m_BoxitemPickupWnd.m_CurPageNo = 1
		g_GameMain.m_BoxitemPickupWnd.m_ClickBagGrid = {nRoomIndex, srcPos}		--����Ʒ���е�λ��
		g_WndMouse:ClearCursorAll()
		Gac2Gas:GetBoxitemInfo(g_Conn, nRoomIndex, nPos , nBigID, nSmallID)
end
--�������
function Gas2Gac:ShowBoxItemWnd(Conn, Result)

	local ParentWnd, nBigID, nSmallID, nRoomIndex, nPos, Item, eEquipPart, srcPos, QuestionTypeName
	if BoxParameter == nil then
		return
	end
	ParentWnd = BoxParameter["ParentWnd"]
	nBigID = BoxParameter["nBigID"]
	nSmallID = BoxParameter["nSmallID"]
	nRoomIndex = BoxParameter["nRoomIndex"]
	nPos = BoxParameter["nPos"]
	Item = BoxParameter["Item"]
	eEquipPart = BoxParameter["eEquipPart"]
	srcPos = BoxParameter["srcPos"]
	QuestionTypeName = BoxParameter["QuestionTypeName"]
	BoxParameter = nil

	if Result == true then
		OpenBoxitem( ParentWnd, nBigID, nSmallID, nRoomIndex, nPos, Item, eEquipPart, srcPos )
	else
		--print( "ɾ��" .. Item:GetItemID() .. "����")
		--ɾ�����򿪵ĺ���
		Gac2Gas:OnUseDelItemByPos(Conn, nRoomIndex, nPos, 1)
	end
end

function Gas2Gac:InitBoxItemWnd(Conn,Result)
	local ParentWnd, nBigID, nSmallID, nRoomIndex, nPos, Item, eEquipPart, srcPos, QuestionTypeName
	QuestionTypeName = BoxParameter["QuestionTypeName"]
	if not Result then
		Gas2Gac:RetShowEssayQuestionWnd( g_Conn, QuestionTypeName, "", 1)
		return
	end
	if BoxParameter == nil then
		return
	end
	ParentWnd = BoxParameter["ParentWnd"]
	nBigID = BoxParameter["nBigID"]
	nSmallID = BoxParameter["nSmallID"]
	nRoomIndex = BoxParameter["nRoomIndex"]
	nPos = BoxParameter["nPos"]
	Item = BoxParameter["Item"]
	eEquipPart = BoxParameter["eEquipPart"]
	srcPos = BoxParameter["srcPos"]

	BoxParameter = nil
	OpenBoxitem( ParentWnd, nBigID, nSmallID, nRoomIndex, nPos, Item, eEquipPart, srcPos )
end
--�Ҽ����������Ʒ������Ʒʰȡ���
local function OpenBoxitemDropWnd( ParentWnd, nBigID, nSmallID, nRoomIndex, nPos, Item, eEquipPart, srcPos )
	if g_ItemInfoMgr:IsBoxitem(nBigID) then
		--�������� �Ƿ�Ҫ�����   �Ƿ� �����Ŀ
--		print( "ParentWnd = ", ParentWnd, "nBigID = ", nBigID, "nSmallID = ", nSmallID,"nRoomIndex = ", nRoomIndex, "nPos = ", nPos,"Item = ", Item, "eEquipPart = ", eEquipPart,"srcPos = ", srcPos)
		local QuestionTypeName = BoxItem_Common(nSmallID,"QuestionTypeName")
--		BoxParameter =
--		{
--			["ParentWnd"] 	= ParentWnd,
--			["nBigID"]    	= nBigID,
--			["nSmallID"]  	= nSmallID,
--			["nRoomIndex"]	= nRoomIndex,
--			["nPos"]      	= nPos,
--			["Item"]      	= Item,
--			["eEquipPart"]	= eEquipPart,
--			["srcPos"]    	= srcPos,
--			["QuestionTypeName"] = QuestionTypeName
--		}
		if QuestionTypeName ~= nil and QuestionTypeName ~= "" then
			local param = QuestionControl_Common(QuestionTypeName)
			if tonumber(param.QuestionMode) == 2 then
				BoxParameter =
				{
					["ParentWnd"] 	= ParentWnd,
					["nBigID"]    	= nBigID,
					["nSmallID"]  	= nSmallID,
					["nRoomIndex"]	= nRoomIndex,
					["nPos"]      	= nPos,
					["Item"]      	= Item,
					["eEquipPart"]	= eEquipPart,
					["srcPos"]    	= srcPos,
					["QuestionTypeName"] = QuestionTypeName
				}
				Gac2Gas:SelectBoxState(g_Conn, nRoomIndex, nPos )
			else
				--print("���ñ�QuestionControl_Common ".. QuestionTypeName .." �� ��QuestionMode ��д���� Ӧ��дΪ 2")
			end
		else
			OpenBoxitem( ParentWnd, nBigID, nSmallID, nRoomIndex, nPos, Item, eEquipPart, srcPos )
		end
		return
	end
	if g_ItemInfoMgr:IsTurntableItem(nBigID) then
		OpenBoxitem( ParentWnd, nBigID, nSmallID, nRoomIndex, nPos, Item, eEquipPart, srcPos )
		return
	end
end

--���ı�
local function OpenTextItem(ParentWnd, nBigID, nSmallID, nRoomIndex, nPos, Item, eEquipPart, srcPos)
	local DisplayName	= g_ItemInfoMgr:GetItemLanInfo(nBigID, nSmallID,"DisplayName")
	local Content	= g_ItemInfoMgr:GetItemLanInfo(nBigID, nSmallID,"Content")
	local wnd = g_GameMain.m_TextItemWnd
	wnd:ShowWnd(true)
	wnd:SetWndText(DisplayName)
	wnd.m_Text:SetWndText(Content)
end


local function UseItem(context, nIndex)
	if nIndex == MB_BtnOK then
		local nRoomIndex = context[1]
		local nPos = context[2]
		local nBigID =  context[3]
		local nIndex = context[4]
		local eEquipPart = context[5]
		if eEquipPart == nil then
			eEquipPart = 0
		end
		Gac2Gas:UseItem(g_Conn,nRoomIndex,nPos,nBigID,nIndex,eEquipPart)
	end
	g_WndMouse:ClearCursorAll()
	return true
end

--ʹ��װ������
local function UseWeapon(ParentWnd, nBigID, nIndex, nRoomIndex, nPos, Item,eEquipPart)
	local DynInfo
	if g_ItemInfoMgr:IsStaticWeapon(nBigID) or  g_ItemInfoMgr:IsAssociateWeapon(nBigID) then
		DynInfo = g_DynItemInfoMgr:GetDynItemInfo(Item:GetItemID())
	else
		MsgClient(1001)
		return
	end
	if not DynInfo then	
		local ItemId = Item:GetItemID() or 0
		LogErr("��Ʒ��̬��Ϣ����" .. "sBigID:" .. nBigID .. "sIndex:" .. nIndex  .. "ID:" .. ItemId)
	end
	local WeaponItem = g_GameMain.m_RoleStatus.Part[12].m_Info
	local AssociateWeaponItem = g_GameMain.m_RoleStatus.Part[6].m_Info
	local WeaponInfo,AssociateWeaponInfo
	if WeaponItem ~= nil then
		WeaponInfo = {WeaponItem:GetBigID(),WeaponItem:GetIndex(),WeaponItem:GetItemID()}
	end
	if AssociateWeaponItem ~= nil then
		AssociateWeaponInfo = {AssociateWeaponItem:GetBigID(),AssociateWeaponItem:GetIndex(),AssociateWeaponItem:GetItemID()}
	end
	--װ����λΪnil����Ѳ�λID����Ϊ50�����������������жϡ�
	if eEquipPart == nil then
		eEquipPart = 50
	end
	
	local PlayerInfo = {["Id"] = g_MainPlayer.m_uID
						,["Class"] = g_MainPlayer:CppGetClass()
						,["Level"] = g_MainPlayer:CppGetLevel()
						,["Sex"] = g_MainPlayer.m_Properties:GetSex()
						,["Camp"] = g_MainPlayer:CppGetBirthCamp()
						,["IsInBattleState"] = g_MainPlayer:IsInBattleState()
						,["IsInForbitUseWeaponState"] = g_MainPlayer:IsInForbitUseWeaponState()}
	local weaponUseLevel = DynInfo and DynInfo.BaseLevel or g_ItemInfoMgr:GetItemInfo(nBigID, nIndex,"BaseLevel")
	local Ruslut , HandType = g_ItemInfoMgr:WeaponCanUse(PlayerInfo,nBigID,nIndex,weaponUseLevel,WeaponInfo,AssociateWeaponInfo,eEquipPart)
	if Ruslut then
		local context = {nRoomIndex, nPos,nBigID, nIndex,eEquipPart}
		if ParentWnd ~= nil and tonumber(DynInfo.BindingType) == BindingStyle1 then
			ParentWnd.m_MsgBox = MessageBox(ParentWnd, MsgBoxMsg(13002), BitOr(MB_BtnOK,MB_BtnCancel),UseItem,context)
		else
			Gac2Gas:UseItem(g_Conn,nRoomIndex,nPos,nBigID, nIndex,eEquipPart)
		end
	else
		MsgClient(HandType)
	end
end

--ʹ�÷��ߺ��� ���߲���Ҫ����װ����λ��
local function UseArmor(ParentWnd, nBigID, nIndex, nRoomIndex, nPos, Item,eEquipPart)
	local DynInfo
	if g_ItemInfoMgr:IsStaticArmor(nBigID) then
		DynInfo = g_DynItemInfoMgr:GetDynItemInfo(Item:GetItemID())
	else
		MsgClient(1001)
		return
	end

	local PlayerInfo = {["Id"] = g_MainPlayer.m_uID
						,["Class"] = g_MainPlayer:CppGetClass()
						,["Level"] = g_MainPlayer:CppGetLevel()
						,["Sex"] = g_MainPlayer.m_Properties:GetSex()
						,["Camp"] = g_MainPlayer:CppGetBirthCamp()
						,["IsInBattleState"] = g_MainPlayer:IsInBattleState()
						,["IsInForbitUseWeaponState"] = g_MainPlayer:IsInForbitUseWeaponState()}
    local armorUseLevel = DynInfo and DynInfo.BaseLevel or g_ItemInfoMgr:GetItemInfo(nBigID, nIndex,"BaseLevel")
	local result ,errnum = g_ItemInfoMgr:ArmorCanUse(PlayerInfo,nBigID,nIndex,armorUseLevel)
	if result then
		local context = {nRoomIndex, nPos,nBigID, nIndex,eEquipPart}
		if ParentWnd ~= nil and tonumber(DynInfo.BindingType) == BindingStyle1 then
			ParentWnd.m_MsgBox = MessageBox(ParentWnd, MsgBoxMsg(13002), BitOr(MB_BtnOK,MB_BtnCancel),UseItem,context)
		else
			Gac2Gas:UseItem(g_Conn,nRoomIndex,nPos,nBigID, nIndex,eEquipPart)
		end
	else
		MsgClient(errnum)
	end
end

--ʹ����Ʒ����
local function UseJewelry(ParentWnd, nBigID, nIndex, nRoomIndex, nPos ,Item,eEquipPart)
	local DynInfo
	if g_ItemInfoMgr:IsJewelry(nBigID) or g_ItemInfoMgr:IsRing(nBigID) then
		DynInfo = g_DynItemInfoMgr:GetDynItemInfo(Item:GetItemID())
	else
		MsgClient(1001)
		return
	end
	local PlayerInfo = {["Id"] = g_MainPlayer.m_uID
						,["Class"] = g_MainPlayer:CppGetClass()
						,["Level"] = g_MainPlayer:CppGetLevel()
						,["Sex"] = g_MainPlayer.m_Properties:GetSex()
						,["Camp"] = g_MainPlayer:CppGetBirthCamp()
						,["IsInBattleState"] = g_MainPlayer:IsInBattleState()
						,["IsInForbitUseWeaponState"] = g_MainPlayer:IsInForbitUseWeaponState()}

	if g_ItemInfoMgr:IsJewelry(nBigID) or g_ItemInfoMgr:IsRing(nBigID) then
	    local ewelryCanUseLevel = DynInfo and DynInfo.BaseLevel or g_ItemInfoMgr:GetItemInfo(nBigID, nIndex,"BaseLevel")
		local result,errnum = g_ItemInfoMgr:JewelryCanUse(PlayerInfo,nBigID,nIndex,ewelryCanUseLevel)
		if result then
			local context = {nRoomIndex, nPos,nBigID, nIndex,eEquipPart}
			if ParentWnd ~= nil and tonumber(DynInfo.BindingType) == BindingStyle1 then
				ParentWnd.m_MsgBox = MessageBox(ParentWnd, MsgBoxMsg(13002), BitOr(MB_BtnOK,MB_BtnCancel),UseItem,context)
			else
				Gac2Gas:UseItem(g_Conn,nRoomIndex,nPos,nBigID, nIndex,eEquipPart)
			end
		else
			MsgClient(errnum)
		end
	end
end

--ʹ��ҩƷ
local function UseSkillItems(ParentWnd, nBigID, nSmallID, nRoomIndex, nPos, Item, eEquipPart)
	--print(nBigID, nSmallID, nRoomIndex, nPos, Item, eEquipPart)
	if g_ItemInfoMgr:IsItemBurstSkill(nBigID) then
		local BaseLevel = g_ItemInfoMgr:GetItemInfo(nBigID,nSmallID,"BaseLevel")
		local SkillName = g_ItemInfoMgr:GetItemInfo(nBigID,nSmallID,"SkillName")
		if g_MainPlayer:CppGetLevel() >= BaseLevel then
			if SkillName ==nil or SkillName == "" then
				--3����Ʒ��û�����Ʒ�� ����ʹ�ô���Ʒ����
				return
			end
			g_MainPlayer:StopMovingBeforeDoCastingSkill(SkillName)
			Gac2Gas:UseItem(g_Conn,nRoomIndex,nPos,nBigID, nSmallID,eEquipPart)
		else
			-- ��ʾ�ȼ�����
			MsgClient(1003)
		end
	end
end

local function UseQuestSkillItem(ParentWnd, nBigID, nSmallID, nRoomIndex, nPos, Item, eEquipPart)
	local SkillName = g_ItemInfoMgr:GetItemInfo(nBigID,nSmallID,"SkillName")
	if SkillName ~= "" then
		--g_MainPlayer:FightSkill(PropTable.SkillName, 1)
		--Gac2Gas:ClickItem(g_Conn, nSmallID) --�Ѿ���g_GacUseItem ʹ����
		g_WndMouse:ClearCursorAll()
	end
	local ItemInfo = g_ItemUseInfoMgr:GetItemUseInfo(nSmallID)
	if ItemInfo ~= nil then
		local castType = ItemInfo.CastType[1]
		local effect = ItemInfo.effect
--		if castType ~= "������" then
--			g_SetItemGridWndState(nRoomIndex,nPos,false)
--		end
		if effect ~= nil and
			(effect == "�������ͷż���" or effect == "��Ŀ���ͷż���" or effect == "�Եص��ͷż���") then
			g_MainPlayer:StopMovingBeforeDoCastingSkill(ItemInfo.Arg[1][1])
--			g_MainPlayer:TurnAroundByNonFightSkill(arg[1])
		end
	end
	GroundSelector:CancelSelectGround()
	if g_ItemInfoMgr:IsPickOreItem(nBigID) then
		local item = g_DynItemInfoMgr:GetDynItemInfo(Item:GetItemID())
		if item and IsNumber(item.CurDura) and item.CurDura == 0 then
			MsgClient(9626)
			return
		end
	end
	Gac2Gas:ClickItem(g_Conn, nBigID, nSmallID, nRoomIndex, nPos)
	--OnRClickQuestItem(nBigID, nSmallID)
end

--�Ҽ����װ����������
local function UseEquipIdentifyScroll(ParentWnd, nBigID, nSmallID, nRoomIndex, nPos, Item)
	local context = {ParentWnd, nBigID, nSmallID, nRoomIndex, nPos, Item}
	g_WndMouse:SetPreIdentifyEquip(context)
end

--�Ҽ��������Ƭ
local function ArmorPieceEnactment(ParentWnd, nBigID, nSmallID, nRoomIndex, nPos, Item)
	local context = {ParentWnd, nBigID, nSmallID, nRoomIndex, nPos, Item}
	g_WndMouse:SetPreArmorPieceEnactment(context)
end

--�Ҽ�ʹ��װ�����������
local function UseEquipSmeltSoulScroll(ParentWnd, nBigID, nSmallID, nRoomIndex, nPos, Item)
	local context = {ParentWnd, nBigID, nSmallID, nRoomIndex, nPos, Item}
	g_WndMouse:SetPreEquipSmeltSoul(context)
end

--�Ҽ�������齫�京�еĻ�ֵƽ�����䵽װ����
local function AverageSoulCountToEquip(ParentWnd, nBigID, nSmallID, nRoomIndex, nPos, Item)
	local function CallBack(g_GameMain, index)
		if index == MB_BtnOK then
			Gac2Gas:AvargeSoulCountToEquip(g_Conn, nRoomIndex, nPos)
		end
		g_WndMouse:ClearCursorAll()
		g_GameMain.m_MsgBox = nil
		return true
	end
	if g_ItemInfoMgr:IsSoulPearl(nBigID) then
		local SoulType = g_ItemInfoMgr:GetItemInfo(nBigID, nSmallID, "SoulType")
		local sMsg = ""
		local DisplayName = g_ItemInfoMgr:GetItemLanInfo(nBigID, nSmallID, "DisplayName")
		if(1 == SoulType) then --����
			sMsg = MsgBoxMsg(14001)
		elseif(2 == SoulType) then --������
			sMsg = MsgBoxMsg(14006,DisplayName)
		elseif(3 == SoulType) then --����
			local AreaFbPointType = g_ItemInfoMgr:GetItemInfo(nBigID, nSmallID, "AreaFbPointType")
			sMsg = MsgBoxMsg( 14007, DisplayName, g_DisplayCommon.m_tblAreaFbPoinDisplay[AreaFbPointType] )
		end

		g_GameMain.m_MsgBox = MessageBox(g_GameMain,sMsg ,  BitOr(MB_BtnOK,MB_BtnCancel), CallBack, g_GameMain)
	end
end

--����顢��ƿ
local function OpenExpOrSoulBottle(ParentWnd, nBigID, nSmallID, nRoomIndex, nPos, Item)
	local base_level = Exp_Soul_Bottle_Common(Item.m_Grid.m_sName,"BaseLevel")
	if g_MainPlayer:CppGetLevel() < base_level then
		MsgClient(801)
		return 
	end
	Gac2Gas:OpenExpOrSoulBottle(g_Conn,nRoomIndex, nPos)
end

--�Ҽ��������޵�
local function UsePetEgg(ParentWnd, nBigID, nSmallID, nRoomIndex, nPos, Item)
	local function CallBack(g_GameMain, index)
		if index == MB_BtnOK then
			Gac2Gas:IncubatePetEgg(g_Conn,nSmallID,nRoomIndex, nPos)
		end
		g_WndMouse:ClearCursorAll()
		g_GameMain.m_MsgBox = nil
		return true
	end
	if g_ItemInfoMgr:IsPetEgg(nBigID) then
		g_GameMain.m_MsgBox = MessageBox(g_GameMain, MsgBoxMsg(14002),  BitOr(MB_BtnOK,MB_BtnCancel), CallBack, g_GameMain)
	end
end

--�Ҽ�ʹ�û�����ʯ
local function UsePetSkillStone(ParentWnd, nBigID, nSmallID, nRoomIndex, nPos, Item)
	local function CallBack(g_GameMain, index)
		if index == MB_BtnOK then
			if g_GameMain.m_PetInfoWnd.m_uChoosedIndex == -1 then
				MsgClient(194114)
			else
				Gac2Gas:UsePetSkillStone(g_Conn,nSmallID,nRoomIndex, nPos)
			end
		end
		g_WndMouse:ClearCursorAll()
		g_GameMain.m_MsgBox = nil
		return true
	end
	if g_ItemInfoMgr:IsPetSkillStone(nBigID) then
		if not g_GameMain.m_PetInfoWnd:IsShow() then
			if not g_GameMain.m_PetInfoWnd.m_IsFirstOpenPetWnd then
				Gac2Gas:InitPetWndInfo(g_Conn)
			end
			g_GameMain.m_PetInfoWnd:ShowWnd(true)
		end
		g_GameMain.m_PetInfoWnd:InitWnd()
		g_GameMain.m_MsgBox = MessageBox(g_GameMain, MsgBoxMsg(14005),  BitOr(MB_BtnOK,MB_BtnCancel), CallBack, g_GameMain)
	end
end

local function UseStone( ParentWnd, nBigID, nSmallID, nRoomIndex, nPos )
	local StoneWnd = CStone.GetWnd()
	local StoneCompoundWnd = CStoneCompound.GetWnd()
	if StoneWnd.StonePartUsing:IsShow() then
		StoneWnd.StonePartUsing:UseStone(nBigID, nSmallID, nRoomIndex, nPos )
	elseif StoneCompoundWnd:IsShow() then
		StoneCompoundWnd:UseMaterial(nRoomIndex, nPos )
	end
end

local function UseHoleMaterial( ParentWnd, nBigID, nSmallID, nRoomIndex, nPos )
	local StoneWnd = CStone.GetWnd()
	local StoneCompoundWnd = CStoneCompound.GetWnd()
	if StoneWnd.StonePartUsing:IsShow() then
		StoneWnd.StonePartUsing:UseHoleMaterial(nBigID, nSmallID, nRoomIndex, nPos )
	elseif StoneCompoundWnd:IsShow() then
		StoneCompoundWnd:UseMaterial(nRoomIndex, nPos )
	end
end

local function UseWhiteStone(ParentWnd, nBigID, nSmallID, nRoomIndex, nPos, Item, eEquipPart)
	if g_ItemInfoMgr:IsWhiteStone(nBigID) then
		local Whitestone = CWhiteStone.GetWnd()
		Whitestone:UseWhiteStone(nBigID, nSmallID, nRoomIndex, nPos, eEquipPart )
	end
end

local function UseTongTruckItem(ParentWnd, nBigID, nSmallID, nRoomIndex, nPos)
	GroundSelector:CancelSelectGround()
	Gac2Gas:ClickItem(g_Conn, nBigID, nSmallID, nRoomIndex, nPos)
end

--local function UseTongItem(ParentWnd, nBigID, nSmallID, nRoomIndex, nPos)
--	GroundSelector:CancelSelectGround()
--	Gac2Gas:ClickItem(g_Conn, nBigID, nSmallID, nRoomIndex, nPos)
--end

local function UseVIPItem(ParentWnd, nBigID, nSmallID, nRoomIndex, nPos)
	GroundSelector:CancelSelectGround()
	Gac2Gas:UseVIPItem(g_Conn,nSmallID, nRoomIndex, nPos)
end

local function UseEquipIntensifyBackItem(ParentWnd, nBigID, nSmallID, nRoomIndex, nPos, Item, eEquipPart, srcPos)
    local useType = g_ItemInfoMgr:GetItemInfo(nBigID, Item.m_Grid.m_sName, "UseType")
    if useType == 2 then
        return 
    end
    local context = {ParentWnd, nBigID, nSmallID, nRoomIndex, nPos, Item}
    g_WndMouse:SetUseEquipIntenBackItem(context)
end

local GacUseItem =
{
	[1] = UseQuestSkillItem,			 --����������Ʒ�ű�
	[2] = nil,
	[3] = UseSkillItems,
	[5] = UseWeapon,
	[6] = UseArmor,
	[7] = UseWeapon,
	[8] = UseJewelry,
	[9] = UseJewelry,
	[10] = UseQuestSkillItem,
	--[11] = nil,
	--[12] = nil,
	--[13] = nil,
	[14] = UseStone,
	[15] = UseHoleMaterial,
	[16] = UseQuestSkillItem,			--������Ʒ
	[17] = OpenMailText,				--�Ҽ����ʼ��ı�����
	[18] = UseWhiteStone,				--�Ҽ�ʹ�ðױ�ʯ
	[19] = AverageSoulCountToEquip,		--�Ҽ�������飬�������ϵĻ�ֵ������ע����ɫ����
	[24] = OpenBoxitemDropWnd,			--�Ҽ��򿪺�����Ʒ������Ʒ���
	[25] = OpenTextItem,				--�ʼ����ı���Ʒ
	[26] = DelBattleArrayBook,			--�õ�����
	[30] = UseQuestSkillItem,			--���ͼ ����������Ʒ��������Ʒ�ű�
	[31] = UseEquipIdentifyScroll,		--ʹ��װ����������
	[32] = UseQuestSkillItem,			--ʹ�������ֻ�
	[33] = UseTongBuildingItem,			--ʹ�ð�Ὠ�����ᴴ������
	[34] = ArmorPieceEnactment,			--�Ҽ�ʹ�û���Ƭ�趨
	[35] = UseTongTruckItem,			--�Ҽ�ʹ�ð�����䳵����
	[36] = UseEquipSmeltSoulScroll,		--�Ҽ�ʹ��װ�����������
	[37] = UseQuestSkillItem,			--�Ҽ�ʹ������������
	[39] = UseQuestSkillItem,			--�Ҽ�ʹ�ô��������ս����
	[40] = UseQuestSkillItem,			--�Ҽ�ʹ�ô���NPC
	[41] = UsePetEgg,					--�Ҽ���������
	[42] = UsePetSkillStone,			--�Ҽ�ʹ�û�����ʯ
	[43] = UseEquipIntensifyBackItem,	--�Ҽ�ʹ�ô�����ʯ
	[45] = UseQuestSkillItem,			--�Ҽ�ʹ�òɿ󹤾�
	[46] = UseQuestSkillItem,			--�Ҽ�ʹ���̳ǵ���
	[47] = OpenBoxitemDropWnd,			--�Ҽ��򿪺�����Ʒ������Ʒ���
	[48] = OpenExpOrSoulBottle,			--�Ҽ������ƿ���߻�ƿ
	[51] = UseVIPItem,					--�Ҽ�ʹ��vip����
	--[52] = UseTongItem,					--�Ҽ�ʹ��С�ӵ���
}


function g_GacUseItem(ParentWnd, nBigID, nSmallID, nRoomIndex, nPos,eEquipPart)
	--��ɫ��Ϣ�����ڵ������ʹ����Ʒֱ�ӷ���
	if g_MainPlayer == nil then
		return
	end
	--ParentWnd ����Ϊnil����ʾ����Ҫȷ��ֱ��ʹ�ã��ڽ���װ����ʱ����Ҫ
	
	if not g_MainPlayer:CppIsAlive() then
		MsgClient(828)
		return
	end
	if (g_MainPlayer:CppGetDoSkillCtrlState(EDoSkillCtrlState.eDSCS_ForbitUseSkill)) then
		local tbl = CanUseItem_Common(nSmallID)
		if not tbl or tbl("BigID") ~= nBigID then
			MsgClient(829)
			return
		end
	elseif (g_MainPlayer:CppGetDoSkillCtrlState(EDoSkillCtrlState.eDSCS_ForbitUseMissionItemSkill)) then
		if nBigID == 16 or nBigID == 1 then 
			MsgClient(829)
			return
		end
	end
	
	local func = GacUseItem[nBigID]
	if func ~= nil then
		local srcPos = nPos --����Ʒ���е�λ�ã�δת�����ģ����ڸ������������������У�
		local Mgr = g_GameMain.m_BagSpaceMgr
		local Space = Mgr:GetSpace(nRoomIndex)
		assert(Space~=nil)
		local Grid = Space:GetGrid(nPos)
		
		if( not Grid:GetEnable() ) then --��������Ʒ��������״̬
			MsgClient(835)
			return
		end
		
		local Item = Grid:GetItem()
		assert(Item ~= nil)
		local ItemInfo = g_DynItemInfoMgr:GetDynItemInfo(Item:GetItemID())
		if ItemInfo then
			if 0 == ItemInfo.m_nLifeTime then
				MsgClient(13)
				return
			end
		end
		if g_GameMain.m_BoxitemPickupWnd ~= nil and
			 g_GameMain.m_BoxitemPickupWnd:IsShow() then
			g_GameMain.m_BoxitemPickupWnd:ShowWnd(false)
			g_GameMain.m_BoxitemPickupWnd:EnableBoxItemRelatedGrid(true)
		end
		if g_MainPlayer.m_ItemBagLock and nBigID ~= 16 then
			MsgClient(160009)
			return
		end
		func(ParentWnd, nBigID, nSmallID, nRoomIndex, nPos, Item, eEquipPart, srcPos)
	else
		g_WndMouse:ClearCursorAll()
	end
	
end

function g_GacUseItemFromShortcut(ParentWnd,nBigID, nIndex)
	local Mgr = g_GameMain.m_BagSpaceMgr
	local nRoomIndex, nPos = Mgr:FindItemBySpace(g_StoreRoomIndex.PlayerBag, nBigID,nIndex)
	if nRoomIndex then
		local Space = Mgr:GetSpace(nRoomIndex)
		assert(Space~=nil)
		local Grid = Space:GetGrid(nPos)
		local Item = Grid:GetItem()
		assert(Item ~= nil)
		if g_GameMain.m_WndMainBag and (not g_GameMain.m_WndMainBag:GetMainItemBagState()) then
			MsgClient(160001)
			return
		end
		g_GacUseItem(ParentWnd, nBigID, nIndex, nRoomIndex, nPos, Item)
	end
end

