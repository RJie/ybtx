gac_gas_require "item/store_room_cfg/StoreRoomCfg"
local g_TongDepotMain = g_TongDepotMain 				--�������ӷ�Χ
local g_ItemInfoMgr = CItemInfoMgr:new()
local g_CDepotSQLMgr = RequireDbBox("GasCDepotSQLMgrDB")
local CDepotMgrBox = CreateDbBox(...)


--���ֿ����ƶ���Ʒ��
function CDepotMgrBox.GetNcountItemFromA2B(nFromDepotID,nFromPage,nFromPos,nToDepotID,nToPage,nToPos,nCount)
	local nFromType,nFromName,nFromCount = g_CDepotSQLMgr.GetDepotItemTypeNameAndCountByPos(nFromDepotID,nFromPage,nFromPos)
	local nToType,nToName,nToCount = g_CDepotSQLMgr.GetDepotItemTypeNameAndCountByPos(nToDepotID,nToPage,nToPos)
	if nCount <= 0 then
		return 	0
	end
	if (nFromDepotID == nToDepotID and nFromPage == nToPage and nFromPos == nToPos) then
		--��ʼλ�ú�Ŀ��λ����ͬ�����ƶ�������
		return 0
	end
	
	if (nFromCount == nil or nFromCount == 0) then
		--��ʼ��Ʒû����Ʒ������
		return 0
	end
	if nCount > nFromCount then
		--ȡ�ߵ���Ŀ������Ʒ��ʵ����Ŀ������
		return 0
	end
	local FoldLimit = g_ItemInfoMgr:GetItemInfo( nFromType,nFromName,"FoldLimit" ) or 1

	if (nToCount == nil or nToCount == 0) then  
		--Ŀ�����û����Ʒ
		--������������
		if nCount > FoldLimit then
			return -1
		end
	else 
		--�ڶ�����������Ʒ���ж���������Ʒ���������Ƿ���ͬ
		--�ж��Ƿ񳬹���������
		if (nFromType ~= nToType or nFromName ~= nToName) then
			return 1
		else
			if nToCount + nCount > FoldLimit then
				return 2
			end
		end
	end
	--�ı����Ʒλ��
	g_CDepotSQLMgr.UpdateNumCDepotItemPos(nFromDepotID,nFromPage,nFromPos,nToDepotID,nToPage,nToPos,nCount)
	return 3
end

--����Ʒ����ʼλ���ƶ���Ŀ��λ�ã���ʵ�൱����ʼ��Ŀ����Ʒ����λ�ã������õ������˼·��
function CDepotMgrBox.ChangeItemPos(nFromDepotID,nFromPage,nFromPos,nToDepotID,nToPage,nToPos)
	local nFromType,nFromName,nFromCount = g_CDepotSQLMgr.GetDepotItemTypeNameAndCountByPos(nFromDepotID,nFromPage,nFromPos)
	local nToType,nToName,nToCount = g_CDepotSQLMgr.GetDepotItemTypeNameAndCountByPos(nToDepotID,nToPage,nToPos)
	if ((nFromCount == nil or nFromCount == 0) and (nToCount == nil or nToCount == 0)) then
		--���Ŀ��λ�ú���ʼλ�ö�Ϊ�գ��򷵻�һ���յ�table
		return 0
	elseif (nToCount == nil or nToCount == 0) then
		--���Ŀ�����û����Ʒ�������ʼ����������Ʒ���ƶ���Ŀ�����
		g_CDepotSQLMgr.UpdateCDepotItemPos(nFromDepotID,nFromPage,nFromPos,nToDepotID,nToPage,nToPos)
	elseif (nFromCount == nil or nFromCount == 0) then
		--�����ʼ����û����Ʒ�����Ŀ����ӵ��ƶ�����ʼ����
		g_CDepotSQLMgr.UpdateCDepotItemPos(nToDepotID,nToPage,nToPos,nFromDepotID,nFromPage,nFromPos)
	else
		--Ŀ�����ʼ���Ӷ�����Ʒ������������Ʒ����λ��
		--���Ŀ��λ�õ�������Ʒid
		local tblToItem = g_CDepotSQLMgr.GetDepotItemIDByPos(nToDepotID,nToPage,nToPos)
		g_CDepotSQLMgr.UpdateCDepotItemPos(nFromDepotID,nFromPage,nFromPos,nToDepotID,nToPage,nToPos)
		for i=1,tblToItem:GetRowNum() do
			g_CDepotSQLMgr.UpdateCDepotItemPosByID(nFromDepotID,nFromPage,nFromPos,tblToItem(i,1))
		end
	end
end


function CDepotMgrBox.MoveItem(nFromDepotID,nFromPage,nFromPos,nToDepotID,nToPage,nToPos)
	if (nFromDepotID == nToDepotID and nFromPage == nToPage and nFromPos == nToPos) then
		return 
	end
	local FromSoulNum = g_CDepotSQLMgr.GetDepotSoulNumByPos(nFromDepotID,nFromPage,nFromPos)
	local ToSoulNum = g_CDepotSQLMgr.GetDepotSoulNumByPos(nToDepotID,nToPage,nToPos)
	
	if ToSoulNum > 0 and FromSoulNum ~= ToSoulNum then
		return 63
	end
	
	local nFromType,nFromName,nFromCount = g_CDepotSQLMgr.GetDepotItemTypeNameAndCountByPos(nFromDepotID,nFromPage,nFromPos)
	if (nFromCount == nil or nFromCount <= 0) then
		return 
	end
	local nToType,nToName,nToCount = g_CDepotSQLMgr.GetDepotItemTypeNameAndCountByPos(nToDepotID,nToPage,nToPos)
	
	if (nToCount == nil or nToCount == 0) then
		--Ŀ��λ��û����Ʒ��ֱ�Ӱ���Ʒ����ʼλ���ƶ���Ŀ��λ��
		CDepotMgrBox.ChangeItemPos(nFromDepotID,nFromPage,nFromPos,nToDepotID,nToPage,nToPos)
		return {},"Replace"
	else
		local FoldLimit = g_ItemInfoMgr:GetItemInfo( nFromType,nFromName,"FoldLimit" ) or 1
		if (nFromType == nToType and nFromName == nToName) then
			--Ŀ��λ�ú���ʼλ������ͬ��Ʒ
			local nMoveCount = 0
			if nToCount == FoldLimit then
				--Ŀ�������Ʒ����������ޣ�����ʼλ�ú�Ŀ��λ����Ʒֱ�ӽ���
				CDepotMgrBox.ChangeItemPos(nFromDepotID,nFromPage,nFromPos,nToDepotID,nToPage,nToPos)
				return {},"Replace"
			elseif nFromCount + nToCount >  FoldLimit then
				--��ʼλ�ú�Ŀ��λ����Ʒ�����ʹ��ڴ���Ʒ�������ޣ���Ŀ��λ�û��ܵ��Ӷ��ٸ����ƶ����ٸ���Ŀ��λ�ã�ʣ�µ���Ȼ����ԭ����λ�ã�
				nMoveCount = FoldLimit - nToCount
			else
				--��ʼλ�ú�Ŀ��λ�õ���Ʒ������û�дﵽ�������ޣ������ʼλ����Ʒ���ƶ���Ŀ��λ��
				nMoveCount = nFromCount
			end
			CDepotMgrBox.GetNcountItemFromA2B(nFromDepotID,nFromPage,nFromPos,nToDepotID,nToPage,nToPos,nMoveCount)
			return {},"Move"
		else
			--��ͬ�࣬����λ����Ʒ����
			CDepotMgrBox.ChangeItemPos(nFromDepotID,nFromPage,nFromPos,nToDepotID,nToPage,nToPos)
			return {},"Replace"
		end
	end
end

--��ɾ��ĳ�ֿ�ĳλ���ϵ�������Ʒ��
function CDepotMgrBox.DeleteItemByPos(nDepotID,nPage,nPos)
	--�õ���λ��������Ʒid
	local tblItemInfo = g_CDepotSQLMgr.GetDepotItemIDByPos(nDepotID,nPage,nPos)
	
	--ɾ����λ���ϵ�������Ʒ
	--Ϊ�˱�����ɾ���Ĺ���������Ʒ�ѱ�ɾ�����͸���id��ɾ�������Ǹ���λ����ɾ��
	local nCount = tblItemInfo:GetRowNum()
	local tblItem = {}
	for i=1, nCount do
		g_CDepotSQLMgr.DelCDepotItemByID(tblItemInfo(i,1))
		if (g_DbChannelMgr:LastAffectedRowNum() > 0)  then
			--���g_DbChannelMgr:LastAffectedRowNum() == 0��˵���Ѿ�������ɾ��
  			table.insert(tblItem, tblItemInfo(i,1))
  		end
	end
	--�������б�ɾ����Ʒid
	return tblItem
end

function CDepotMgrBox.DelItem(nDepotID,nBigID,nIndex,nCount)	
	if nCount <= 0 then
		return 	1
	end

	if not g_ItemInfoMgr:CheckType( nBigID,nIndex ) then
		return 2
	end
	
	local FoldLimit = g_ItemInfoMgr:GetItemInfo( nBigID,nIndex,"FoldLimit" ) or 1
	local RoomPosCount = g_CDepotSQLMgr.GetPosCountByType(nDepotID,nBigID,nIndex)
	local nSum = 0
	local AllItem,DelRet = {},{}
	
	--�����ж��ٸ�����Ʒ
	if RoomPosCount:GetRowNum() > 0 then
		for n=1, RoomPosCount:GetRowNum() do
			nSum = RoomPosCount(n,3) + nSum
		end
	end
	
	if nSum < nCount then
		return 3
	end
	
  nSum = nCount
	for n=1, RoomPosCount:GetRowNum() do
		local nRoom,nPos,nFoldCount = RoomPosCount(n,1),RoomPosCount(n,2),RoomPosCount(n,3)
		if nSum <= 0 then
			break
		elseif nSum - nFoldCount >= 0 then
			nSum = nSum - nFoldCount
			DelRet = CDepotMgrBox.DeleteItemByPos(nDepotID,nRoom,nPos,nFoldCount)
		else
			DelRet = CDepotMgrBox.DeleteItemByPos(nDepotID,nRoom,nPos,nSum)
			nFoldCount = nSum
			nSum = 0
		end
		if IsNumber(DelRet) then
			return DelRet
		end
	end
	
	--���ر�ɾ������Ʒ��Ϣ
	return AllItem
end
--�����ĳ������ĳ��Ʒ��ĳ�ֿ��ĳλ��,��Ҫ���ڴӸ��˰�������Ʒ���ֿ�ĳλ�á�
function CDepotMgrBox.AddCDepotItemByPos(nDepotID, ItemType,ItemName,nPage,nPos,tbl_ItemIDs)
	if g_ItemInfoMgr:IsSoulPearl(ItemType) then
		ItemName = g_ItemInfoMgr:GetSoulpearlInfo(ItemName)
	end
	local nCount=table.getn(tbl_ItemIDs)
	if nCount <= 0 then
		return 40
	end
	if not g_ItemInfoMgr:CheckType( ItemType,ItemName ) then
		return 44
	end
	
	local FoldLimit = g_ItemInfoMgr:GetItemInfo( ItemType,ItemName,"FoldLimit" ) or 1
	local nToType, nToName, nToCount = g_CDepotSQLMgr.GetDepotItemTypeNameAndCountByPos(nDepotID,nPage,nPos)
	
	--�жϻ᲻�ᳬ����������
	if nToCount + nCount > FoldLimit then
		return 42
	end
	
	-- ���Ŀ��λ������Ʒ��Ҫ�ж������Ƿ���ͬ
	if nToCount ~= 0 then
		if (nToName ~= ItemName or tonumber(nToType) ~= tonumber(ItemType)) then
			return 60
		end
	end
	
	local AllItem = {}
	local g_RoomMgr = RequireDbBox("GasRoomMgrDB")
	local SoulNum = g_CDepotSQLMgr.GetDepotSoulNumByPos(nDepotID,nPage, nPos)
	for n=1, nCount do
		local item_id = tbl_ItemIDs[n]
		if SoulNum > 0 and SoulNum ~= g_RoomMgr.GetSoulPearlInfoByID(item_id) then
			return 63
		end
		if not g_CDepotSQLMgr.AddCDepotItem(nDepotID, item_id, nPage, nPos) then
			CancelTran()
			return 57
		end
		table.insert(AllItem,tbl_ItemIDs[n])
	end
	return AllItem
end

function CDepotMgrBox.HaveEnoughRoomPos(nDepotID,ItemType,ItemName,nPage,nCount)
	if g_ItemInfoMgr:IsSoulPearl(ItemType) then
		ItemName = g_ItemInfoMgr:GetSoulpearlInfo(ItemName)
	end
	local FoldLimit = g_ItemInfoMgr:GetItemInfo( ItemType,ItemName,"FoldLimit" ) or 1
	
	--��ѯ�òֿ������и���Ʒ��û�дﵽ�������޵���Ʒ����ҳ�������ڸ��ӡ���λ���ϵ�����
	local HaveItemPosInfo
	if nPage then
		HaveItemPosInfo = g_CDepotSQLMgr.GetPosCountByPage(nDepotID, ItemType, ItemName, FoldLimit,nPage)
	else
	 HaveItemPosInfo = g_CDepotSQLMgr.GetPosCountByNameAndType(nDepotID, ItemType, ItemName, FoldLimit)
	end
	
	local nSum,OtherNeedGrid= 0,0
	
	--������Ҫ�յĸ�����
	if HaveItemPosInfo:GetRowNum() == 0 then
		--˵���ÿռ仹û��δ�ﵽ�������޵���Ʒ
		OtherNeedGrid = math.ceil(nCount / FoldLimit)
	else
		for n=1, HaveItemPosInfo:GetRowNum() do
			--�����Ѿ��и���Ʒ��λ�û��ܵ��Ŷ��ٸ���Ʒ
			nSum = FoldLimit - HaveItemPosInfo(n,3) + nSum
		end
		if nSum - nCount < 0 then
			--���ܵ��ŵ���Ʒ����С��Ҫ���ŵ���Ʒ����
			OtherNeedGrid = math.ceil((nCount - nSum) / FoldLimit)
		else
			OtherNeedGrid = 0
		end
	end
	
	nSum = nCount
	local tblRoomPos,tblBagGridNum,UseEmptyRoom = {},{},{}

	--OtherNeedGrid ��Ϊ0˵������Ҫ�յĸ���������Ʒ
	if OtherNeedGrid ~= 0 then
		--���ݲֿ�id��ѯ�òֿ��Ѿ�����Ʒ�ĸ�����Ϣ
		local HaveItemRoomCount
		if nPage then
			HaveItemRoomCount = g_CDepotSQLMgr.GetPosWhichHaveItemByPage(nDepotID,nPage)
		else
			HaveItemRoomCount = g_CDepotSQLMgr.GetPosWhichHaveItem(nDepotID)
		end
		--�������Ѿ�����Ʒ�ĵĸ�����Ϣ�ŵ�һ����ά����
		--��һά��ҳ����
		--�ڶ�ά��λ�ã�
		--����άӦ���Ǹ�λ���ϵ�������Ʒ��Ϣ��
		for n=1, HaveItemRoomCount:GetRowNum() do
			if tblRoomPos[HaveItemRoomCount(n,1)] == nil then
				tblRoomPos[HaveItemRoomCount(n,1)] = {}
			end	
			tblRoomPos[HaveItemRoomCount(n,1)][HaveItemRoomCount(n,2)] = {}
		end
		
		--��øòֿ������ҳ���͸�����
		-- �����ݶ�
		local nPageIndexNum = 5
		local nGridIndexNum = g_TongDepotMain.size
		
		--�Ӹòֿ�ĵ�һҳ�ĵ�һ�����ӿ�ʼ���ң����Ϊnil��˵���ø���û�б�ռ�ù���
		--���û�б�ռ�ù�����Ѹø�����Ϣ�ŵ�UseEmptyRoom���ű��
		--��UseEmptyRoom���ű��ȴ�����Ҫ�Ŀո�����ʱ��˵���ո����Ѿ��ҹ�����break�˳�ѭ����
		if nPage then
			for j=1, nGridIndexNum do
				--���������Ʒ�Ľ�������Ҳ�����˵���������û��ʹ�ù�
				if tblRoomPos[nPage] == nil or tblRoomPos[nPage][j] == nil then 
					--������õĿյĸ���λ��
					table.insert(UseEmptyRoom,{nPage,j}) 
					--�ҵ��㹻�Ŀո��ӣ�����
					if #UseEmptyRoom >= OtherNeedGrid then 
						break
					end
				end
			end
		else
			for i=1, nPageIndexNum do
				if #UseEmptyRoom >= OtherNeedGrid then 
					break
				end
				for j=1, nGridIndexNum do
					--���������Ʒ�Ľ�������Ҳ�����˵���������û��ʹ�ù�
					if tblRoomPos[i] == nil or tblRoomPos[i][j] == nil then 
						--������õĿյĸ���λ��
						table.insert(UseEmptyRoom,{i,j}) 
						--�ҵ��㹻�Ŀո��ӣ�����
						if #UseEmptyRoom >= OtherNeedGrid then 
							break
						end
					end
				end
			end
		end
	end
	
	return #UseEmptyRoom == OtherNeedGrid
end

--���Զ������Ʒ��ĳ�ֿ⡿
--�Զ������Ʒ
--nPage����Ϊnil��Ϊnil˵���Զ���ӵ��ֿ���ĳһҳ��ĳ������
--���ж��п��Ե��ӵ�λ��
--�ټ��㻹��Ҫ���ٿյĸ�������
function CDepotMgrBox.AutoAddItems(nDepotID,ItemType,ItemName,itemids,nPage)
	local nCount=table.getn(itemids)
	if nCount <= 0 then
		return 1
	end
	local soul_count = 0
	if g_ItemInfoMgr:IsSoulPearl(ItemType) then
		ItemName,soul_count = g_ItemInfoMgr:GetSoulpearlInfo(ItemName)
	end
	if not g_ItemInfoMgr:CheckType( ItemType,ItemName ) then
		return 2
	end

	local FoldLimit = g_ItemInfoMgr:GetItemInfo( ItemType,ItemName,"FoldLimit" ) or 1
	
	local HaveItemPosInfo
	if nPage then
		HaveItemPosInfo = g_CDepotSQLMgr.GetPosCountByPage(nDepotID, ItemType, ItemName, FoldLimit,nPage)
	else
	 HaveItemPosInfo = g_CDepotSQLMgr.GetPosCountByNameAndType(nDepotID, ItemType, ItemName, FoldLimit)
	end
	
	local nSum,OtherNeedGrid= 0,0
	--������Ҫ�յĸ�����
	if HaveItemPosInfo:GetRowNum() == 0 then
		--˵���ÿռ仹û��δ�ﵽ�������޵���Ʒ
		OtherNeedGrid = math.ceil(nCount / FoldLimit)
	else
		for n=1, HaveItemPosInfo:GetRowNum() do
			--�����Ѿ��и���Ʒ��λ�û��ܵ��Ŷ��ٸ���Ʒ
			if soul_count == g_CDepotSQLMgr.GetDepotSoulNumByPos(nDepotID,HaveItemPosInfo(n,1), HaveItemPosInfo(n,2)) then
				--���ǻ��飬���ǻ����һ�ֵ��ͬ
				nSum = FoldLimit - HaveItemPosInfo(n,3) + nSum
			end
		end
		if nSum - nCount < 0 then
			--���ܵ��ŵ���Ʒ����С��Ҫ���ŵ���Ʒ����
			OtherNeedGrid = math.ceil((nCount - nSum) / FoldLimit)
		else
			OtherNeedGrid = 0
		end
	end
	
	nSum = nCount
	local tblRoomPos,tblBagGridNum,UseEmptyRoom = {},{},{}

	--OtherNeedGrid ��Ϊ0˵������Ҫ�յĸ���������Ʒ
	if OtherNeedGrid ~= 0 then
		local HaveItemRoomCount
		if nPage then
			HaveItemRoomCount = g_CDepotSQLMgr.GetPosWhichHaveItemByPage(nDepotID,nPage)
		else
			HaveItemRoomCount = g_CDepotSQLMgr.GetPosWhichHaveItem(nDepotID)
		end
		for n=1, HaveItemRoomCount:GetRowNum() do
			if tblRoomPos[HaveItemRoomCount(n,1)] == nil then
				tblRoomPos[HaveItemRoomCount(n,1)] = {}
			end	
			tblRoomPos[HaveItemRoomCount(n,1)][HaveItemRoomCount(n,2)] = {}
		end
		
		local nPageIndexNum = 5
		local nGridIndexNum = g_TongDepotMain.size
		if nPage then
			for j=1, nGridIndexNum do
				if tblRoomPos[nPage] == nil or tblRoomPos[nPage][j] == nil then 
					table.insert(UseEmptyRoom,{nPage,j}) 
					if #UseEmptyRoom >= OtherNeedGrid then 
						break
					end
				end
			end
		else
			for i=1, nPageIndexNum do
				if #UseEmptyRoom >= OtherNeedGrid then 
					break
				end
				for j=1, nGridIndexNum do
					if tblRoomPos[i] == nil or tblRoomPos[i][j] == nil then 
						table.insert(UseEmptyRoom,{i,j}) 
						if #UseEmptyRoom >= OtherNeedGrid then 
							break
						end
					end
				end
			end
		end
	end
	
	if #UseEmptyRoom ~= OtherNeedGrid then
		--û���㹻�Ŀռ䣬����
		return 3 
	end
	local start_index=1
	local AllItem,SetResult={},{}
	--�����Ʒ������ͬ����Ʒ�ĸ�������ӣ����������˾�ֱ�ӷ���
	for n=1, HaveItemPosInfo:GetRowNum() do
		local nPage,nPos,nFoldCount = HaveItemPosInfo(n,1),HaveItemPosInfo(n,2),HaveItemPosInfo(n,3)
		if soul_count == g_CDepotSQLMgr.GetDepotSoulNumByPos(nDepotID,nPage,nPos) then
				if nSum <= 0 then
					return AllItem
				elseif nSum - (FoldLimit - nFoldCount) >= 0 then
					nSum = nSum - (FoldLimit - nFoldCount)
					local tbl_items={}
					for i=start_index,start_index+FoldLimit - nFoldCount-1 do
						table.insert(tbl_items,itemids[i])
					end
					start_index=start_index+FoldLimit - nFoldCount
					if table.getn(tbl_items)>0 then
						SetResult=CDepotMgrBox.AddCDepotItemByPos(nDepotID, ItemType,ItemName,nPage,nPos,tbl_items)
					end
					nFoldCount = FoldLimit - nFoldCount
				else
					local tbl_items={}
					for i=start_index,start_index+nSum-1 do
						table.insert(tbl_items,itemids[i])
					end
					if table.getn(tbl_items)>0 then
						SetResult=CDepotMgrBox.AddCDepotItemByPos(nDepotID, ItemType,ItemName,nPage,nPos,tbl_items)
					end
					nFoldCount = nSum
					nSum = 0
				end
				if IsNumber(SetResult) then
					--SetResultΪ����˵�����ʧ��
					CancelTran()
					return SetResult
				end
		end
	end
	--�ڿյĸ��������
	for n=1, OtherNeedGrid do
		local nPage,nPos,nFoldCount = UseEmptyRoom[n][1],UseEmptyRoom[n][2],0
		if nSum <= 0 then
			return AllItem
		elseif nSum - FoldLimit  >= 0 then
			nSum = nSum - FoldLimit
			local tbl_items={}
			for i=start_index,start_index+FoldLimit-1  do
				table.insert(tbl_items,itemids[i])
			end
			start_index=start_index+FoldLimit - nFoldCount
			SetResult=CDepotMgrBox.AddCDepotItemByPos(nDepotID, ItemType,ItemName,nPage,nPos,tbl_items)
			nFoldCount = FoldLimit
		else
			local tbl_items={}
			for i=start_index,start_index+nSum-1 do
				table.insert(tbl_items,itemids[i])
			end
			if table.getn(tbl_items)>0 then
				SetResult=CDepotMgrBox.AddCDepotItemByPos(nDepotID, ItemType,ItemName,nPage,nPos,tbl_items)
			end
			nFoldCount = nSum
			nSum = 0
		end
		if IsNumber(SetResult) then
			--SetResultΪ����˵�����ʧ��
			CancelTran()
			return SetResult
		end
	end
	return SetResult
end

--������ֿ���Ʒ��
function CDepotMgrBox.ResetCDepotItem(nDepotID)
	local res = g_CDepotSQLMgr.GetAllCDepotItemInfo(nDepotID)
	if res:GetRowNum() == 0 then
		return
	end
	local tbl_res = {}
	for i =1, #res do
		--�ֱ����͡�ҳ����λ�á���Ʒid�����Ƶ�˳����뵽tbl_res����
		table.insert(tbl_res,{res(i,1),res(i,3),res(i,4),res(i,5),res(i,2)}) --��pos����Ϊ1000 ,������������ô��,ֻ��Ϊ����������ʱ�Ƚ�
	end
	--�����ʹ�С�����������������ͬ���ٰ�������
	table.sort(tbl_res, function (a, b)
			if (a[1] < b[1]) then
				return a[1] < b[1]
			elseif(a[1] == b[1]) then
				return string.lower(a[5]) < string.lower(b[5])
			end
		end)
	local pos = 1
	local PageSize  = g_TongDepotMain.size  --���������ݶ�50
	local PageIndex = 1		--�ӵ�һҳ��ʼ
	for j = 1, #(tbl_res) do
		--�õ��òֿ��λ������Ʒ������
		local sType, sName, nHaveCount = g_CDepotSQLMgr.GetDepotItemTypeNameAndCountByPos(nDepotID,PageIndex,pos)
		local FoldLimit = g_ItemInfoMgr:GetItemInfo( sType, sName,"FoldLimit" ) or 1
		if nHaveCount >= FoldLimit then
			--�ﵽ�������ޣ�����һ��λ�ÿ�ʼ��
			pos = pos + 1
		elseif (0 < nHaveCount) then
			--����Ʒ��û�дﵽ��������ʱ
			--nHaveCountΪ0��˵����λ�û�û����Ʒ�����Էţ�pos���ü�1
			if( sName ~= tbl_res[j][5] or sType ~= tbl_res[j][1])then
				--�˸����ϵ���Ʒ��Ҫ�ŵ���Ʒ��ͬ
				pos = pos + 1
			end
		end
		if(pos > PageSize)then
			--pos�Ѿ��ﵽ��ҳ�������ޣ�ת����һҳ�ĵ�һ�����ӿ�ʼ���
			PageIndex = PageIndex + 1
			pos = 1
		end
		--�õ�����ƷӦ�÷ŵ�λ�ú��޸����ݿ�
		g_CDepotSQLMgr.UpdateCDepotItemPosByID(PageIndex,pos,tbl_res[j][4])
	end
end


---------------------------
return CDepotMgrBox