
--������room index
g_StoreRoomIndex =
{
	PlayerBag = 1,
	PlayerDepot = 2,	--�ֿ�
	PlayerCoffer = 3,	--������
	--MercenaryBag = 4,	--Ӷ��
	PoundBag = 5,			--������
	TongDepot = 6,       --���ֿ�
	
	SlotRoomBegin = 50,		--��չ��
	SlotRoomLast = 54,
	
	DepotSlotRoomBegin = 101,
	DepotSlotRoomLast = 200,
}

AddCheckLeakFilterObj(g_StoreRoomIndex)

--��չ���Ĳ۵ķ�Χ
g_SlotIndex =
{
	FirstBagSlot = 1,
	LastBagSlot = 20,
	
	FirstDepotSlot = 21,
	-- Ŀǰʹ�õ������һ���ֿ�slot id���Ժ������Ҫ�����ֵ����
	-- ���ǲ��ܳ���LastDepotSlot
	UseLastDepotSlot = 26,
	LastDepotSlot = 40,
	
	FirstCofferSlot = 41,
	LastCofferSlot = 60,
	
	FirstTongDepotSlot = 61,
	LastTongDepotSlot = 120,
}

AddCheckLeakFilterObj(g_SlotIndex)

--�򵥿ռ�(��ˢ��ȴ������ʹ��������Ʒ�ȵȵ�����洢�ռ�)
g_SimpleRoomIndex =
{
	g_StoreRoomIndex.PlayerDepot,
}

AddCheckLeakFilterObj(g_SimpleRoomIndex)

--���Ӵ�С
g_GridSize = 42
--����������
g_PlayerMainBag = {}
g_PlayerMainBag.columns = 8
g_PlayerMainBag.size = 32
g_PlayerMainBag.MaxSize = 120

AddCheckLeakFilterObj(g_PlayerMainBag)

--��Ҳֿ�
g_PlayerDepotMain = {}
g_PlayerDepotMain.columns = 10
g_PlayerDepotMain.size = 40

AddCheckLeakFilterObj(g_PlayerDepotMain)

g_PlayerCofferMain = {}
g_PlayerCofferMain.columns = 6
g_PlayerCofferMain.size = 24

AddCheckLeakFilterObj(g_PlayerCofferMain)

--��������������
g_MainBagExpand = {}
g_MainBagExpand.columns = 4
g_MainBagExpand.size = 4

AddCheckLeakFilterObj(g_MainBagExpand)

--�ֿ⸽������
g_MainDepotExpand = {}
g_MainDepotExpand.columns = 6
g_MainDepotExpand.size = 6

AddCheckLeakFilterObj(g_MainDepotExpand)


--���ֿ�����
g_TongDepotMain = {}
g_TongDepotMain.columns = 10
--g_TongDepotMain.addSize = 10
g_TongDepotMain.size    = 40

AddCheckLeakFilterObj(g_TongDepotMain)



function g_IsInStaticRoom( nRoomID )
	if nRoomID ~= g_StoreRoomIndex.PlayerBag and nRoomID ~= g_StoreRoomIndex.PlayerDepot and nRoomID ~= g_StoreRoomIndex.PlayerCoffer and nRoomID ~= g_StoreRoomIndex.TongDepot then
		return false
	end
	return true
end

function g_GetRoomSize( nRoomID )
	if nRoomID == g_StoreRoomIndex.PlayerBag then
		return g_PlayerMainBag.size 
	elseif nRoomID == g_StoreRoomIndex.PlayerDepot then
		return g_PlayerDepotMain.size
	end
end

--����slot �����䷶Χ
function g_IsSlotRight( nSlot )
	if  g_SlotIndex.FirstBagSlot <= nSlot and nSlot <= g_SlotIndex.LastBagSlot then
		return g_SlotIndex.FirstBagSlot,g_SlotIndex.LastBagSlot
	elseif g_SlotIndex.FirstDepotSlot <= nSlot and nSlot <= g_SlotIndex.LastDepotSlot then
		return g_SlotIndex.FirstDepotSlot,g_SlotIndex.LastDepotSlot
	elseif g_SlotIndex.FirstTongDepotSlot <= nSlot and nSlot <= g_SlotIndex.LastTongDepotSlot then
		return g_SlotIndex.FirstTongDepotSlot,g_SlotIndex.LastTongDepotSlot
	end
	return  nil
end

--ͨ�����ռ�����ã������ռ��ϸ����ĳ���Χ
function g_GetSlotRange( nStoreMain )
	if nStoreMain == g_StoreRoomIndex.PlayerBag then
		return g_SlotIndex.FirstBagSlot, g_SlotIndex.LastBagSlot
	elseif  nStoreMain == g_StoreRoomIndex.PlayerDepot then
		return g_SlotIndex.FirstDepotSlot,g_SlotIndex.LastDepotSlot
	elseif  nStoreMain == g_StoreRoomIndex.TongDepot then
		return g_SlotIndex.FirstTongDepotSlot,g_SlotIndex.LastTongDepotSlot
	end
	return nil
end

--ͨ�����ռ�����ã���øÿռ���չ���ķ�Χ
function g_GetRoomRange( nStoreMain )
	if nStoreMain == g_StoreRoomIndex.PlayerBag then
		return g_StoreRoomIndex.SlotRoomBegin, g_StoreRoomIndex.SlotRoomLast
	elseif g_StoreRoomIndex.PlayerDepot == nStoreMain then
		return g_StoreRoomIndex.DepotSlotRoomBegin,g_StoreRoomIndex.DepotSlotRoomLast
	end
	return 0,0
end


--ͨ��slot��������ĸ�������
function g_GetMainRoomIndexBySlot( nSlot )
	if g_SlotIndex.FirstBagSlot <= nSlot and nSlot <= g_SlotIndex.LastBagSlot then
		return g_StoreRoomIndex.PlayerBag
	elseif g_SlotIndex.FirstDepotSlot <= nSlot and nSlot <= g_SlotIndex.LastDepotSlot then
		return g_StoreRoomIndex.PlayerDepot
	elseif g_SlotIndex.FirstTongDepotSlot <= nSlot and nSlot <= g_SlotIndex.LastTongDepotSlot then
		return g_StoreRoomIndex.TongDepot
	end
end

--�ж����ռ�������Ƿ�Ϸ�
function g_IsPosIsRight( nRoom,nPos )
	if nRoom == g_StoreRoomIndex.PlayerBag then
		if nPos >0 and nPos <= g_PlayerMainBag.size then
			return true
		else
			return false
		end
	elseif nRoom == g_StoreRoomIndex.PlayerDepot then
		if nPos >0 and nPos <= g_PlayerDepotMain.size then
			return true
		else
			return false
		end
	elseif nRoom == g_StoreRoomIndex.PlayerCoffer then
		if nPos >0 and nPos <= g_PlayerCofferMain.size then
			return true
		else
			return false
		end
	elseif nRoom == g_StoreRoomIndex.TongDepot then
		if nPos >0 and nPos <= g_TongDepotMain.size then
			return true
		else
			return false
		end
	end
	return false
end

--ͨ�����ռ������ռ��С
function g_GetMainRoomSize( nStoreMain )
	if nStoreMain == g_StoreRoomIndex.PlayerBag then
		return g_PlayerMainBag.size
	elseif  nStoreMain == g_StoreRoomIndex.PlayerDepot then
		return g_PlayerDepotMain.size
	elseif nStoreMain == g_StoreRoomIndex.PlayerCoffer then
		return g_PlayerCofferMain.size
	end
	return nil
end