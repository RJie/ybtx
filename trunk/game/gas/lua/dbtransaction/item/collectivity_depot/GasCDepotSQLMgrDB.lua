gac_gas_require "item/item_info_mgr/ItemInfoMgr"

local g_ItemInfoMgr = CItemInfoMgr:new()
local StmtOperater = {}	
local CDepotSqlMgrBox = CreateDbBox(...)

--���Ӳֿ⾲̬��Ϣ�����еĲֿ�id�����������
local StmtDef=
{
    "_CreateCDepot",
    [[
    	insert into tbl_collectivity_depot(cds_dtCreateTime) values(now())
    ]]
}
DefineSql(StmtDef,StmtOperater)

--�������ֿ⾲̬��Ϣ�����ز����Ĳֿ�id��
function CDepotSqlMgrBox.CreateCDepot()
	StmtOperater._CreateCDepot:ExecSql('')
	if not (g_DbChannelMgr:LastAffectedRowNum() == 1)  then
  	CancelTran()
  	return 0
  end
  return g_DbChannelMgr:LastInsertId()
end

--���ֿ���Ʒ�������Ʒ��Ϣ
local StmtDef=
{
    "_AddCDepotItemInfo",
    [[
    	insert into tbl_item_collectivity_depot(cds_uId, is_uId, icd_uPageIndex, icd_uPos) values( ?, ?, ?, ? )
    ]]
}
DefineSql(StmtDef,StmtOperater)
--����Ӽ���ֿ���Ʒ��
function CDepotSqlMgrBox.AddCDepotItem(nDepotID, nItemID, nPageIndex, nPos)
	StmtOperater._AddCDepotItemInfo:ExecSql('', nDepotID, nItemID, nPageIndex, nPos)
	if not (g_DbChannelMgr:LastAffectedRowNum() == 1)  then
  	CancelTran()
  	return false
  end
  return true
end

local StmtDef=
{
    "_GetDepotSoulNumByPos",
    [[
    	select ip_uSoulNum from tbl_item_pearl as tip,tbl_item_collectivity_depot as icd 
    	where tip.is_uId = icd.is_uId and cds_uId = ? and icd_uPageIndex = ? and icd_uPos = ?
    	limit 1;
    ]]
}
DefineSql(StmtDef,StmtOperater)
--���õ��ֿ�ĳ���ӻ����ֵ��
function CDepotSqlMgrBox.GetDepotSoulNumByPos(nDepotID,nPageIndex, nPos)
	local tbl_res = StmtOperater._GetDepotSoulNumByPos:ExecStat(nDepotID,nPageIndex, nPos)
	return tbl_res:GetRowNum() == 0 and 0 or tbl_res(1,1)
end


--����ĳ�ֿ�������Ʒ��Ϣ(��Ʒ���ͣ����ƣ�ҳ�������ŵĸ���λ�ã�����λ���ϴ���Ʒ�ĸ���)
local StmtDef=
{
    "_GetCDepotItemByPage",
    [[
    	select  item.is_uType, item.is_sName, depot.icd_uPos, item.is_uId, ifnull(binding.isb_bIsbind,0)
    	from 	tbl_item_collectivity_depot as depot, tbl_item_static as item
    	left join tbl_item_is_binding as binding
    	on	(item.is_uId = binding.is_uId)
    	where 	depot.is_uId = item.is_uId
    	and		depot.cds_uId = ?
    	and		depot.icd_uPageIndex = ?
    ]]
}
DefineSql(StmtDef,StmtOperater)

local StmtDef=
{
    "_GetCDepotSoulPearl",
    [[
    	select  soulp.is_uId, soulp.ip_uSoulNum
    	from 	tbl_item_collectivity_depot as depot,tbl_item_pearl as soulp
    	where 	depot.is_uId = soulp.is_uId
    	and		depot.cds_uId = ?
    	and		depot.icd_uPageIndex = ?
    ]]
}
DefineSql(StmtDef,StmtOperater)
--�����ݲֿ�id�õ��òֿ�ÿ��λ���ϵ���Ʒ��Ϣ����������Ҫ������ʾ��
function CDepotSqlMgrBox.GetCDepotItemByPage(nCharID,nDepotID,nPage)
	local query_result = StmtOperater._GetCDepotItemByPage:ExecStat(nDepotID,nPage)
	local row = query_result:GetRowNum()
	local res = {}
	local EquipMgrDB = RequireDbBox("EquipMgrDB")
	local tbl_id = {}
	for i = 1, row do
		table.insert(res,{query_result(i,1),query_result(i,2),query_result(i,3),query_result(i,4),query_result(i,5)})
		table.insert(tbl_id,query_result(i,4))
		local item_type = query_result:GetNumber(i-1,0)
		if g_ItemInfoMgr:IsStaticEquip(item_type) then		
			local equipRet = EquipMgrDB.GetEquipAllInfo( query_result:GetNumber(i-1,3))
			res[i][6] = equipRet
		end
	end
	query_result:Release()
	local SoulpearlInfo =  StmtOperater._GetCDepotSoulPearl:ExecStat(nDepotID,nPage)
	res.SoulpearlInfo = SoulpearlInfo
	
	if #tbl_id > 0 then
		local ItemMakerMgrDB = RequireDbBox("ItemMakerMgrDB")
		ItemMakerMgrDB.SendItemMakerByTblIDs(nCharID,tbl_id)
	end
	return res
end

local StmtDef=
{
    "_GetAllCDepotItemInfo",
    [[
    	select  item.is_uType, item.is_sName, depot.icd_uPageIndex, depot.icd_uPos, depot.is_uId
    	from 	tbl_item_collectivity_depot as depot, tbl_item_static as item
    	where 	depot.is_uId = item.is_uId
    	and		depot.cds_uId = ?
    ]]
}
DefineSql(StmtDef,StmtOperater)
--�����ݲֿ�id�õ��òֿ����е���Ʒ��Ϣ��id����Ҫ�������������
function CDepotSqlMgrBox.GetAllCDepotItemInfo(nDepotID)
	local query_result = StmtOperater._GetAllCDepotItemInfo:ExecStat(nDepotID)
	
	return query_result
end

--��һ���ֿ��ĳ��λ���ƶ���Ʒ����һ���ռ��ĳλ��
local StmtDef=
{
    "_UpdateCDepotItemPos",
    [[
    	update 	tbl_item_collectivity_depot set cds_uId = ?,icd_uPageIndex = ?,icd_uPos = ?
    	where 	cds_uId = ?
    	and		icd_uPageIndex = ?
    	and		icd_uPos = ?
    ]]
}
DefineSql(StmtDef,StmtOperater)
--���޸�ĳ��Ʒ�Ŀռ��λ�á�
function CDepotSqlMgrBox.UpdateCDepotItemPos(nFromDepotID,nFromPage,nFromPos, nToDepotID,nToPage,nToPos)
	StmtOperater._UpdateCDepotItemPos:ExecSql('',nToDepotID,nToPage,nToPos, nFromDepotID,nFromPage,nFromPos)
end

--��һ���ֿ��ĳ��λ���ƶ�һ����������Ʒ����һ���ռ��ĳλ��
local StmtDef=
{
    "_UpdateNumCDepotItemPos",
    [[
    	update 	tbl_item_collectivity_depot set cds_uId = ?,icd_uPageIndex = ?,icd_uPos = ?
    	where 	cds_uId = ? and icd_uPageIndex = ? and icd_uPos = ?
    	limit  ?
    ]]
}
DefineSql(StmtDef,StmtOperater)
--���޸�һ��������ĳ��Ʒ�Ŀռ��λ�á�
function CDepotSqlMgrBox.UpdateNumCDepotItemPos(nFromDepotID,nFromPage,nFromPos, nToDepotID,nToPage,nToPos,nCount)
	StmtOperater._UpdateNumCDepotItemPos:ExecSql('',nToDepotID,nToPage,nToPos, nFromDepotID,nFromPage,nFromPos,nCount)
end

--����id�޸�ĳһ����Ʒ��λ��
local StmtDef=
{
    "_UpdateCDepotItemPosByID",
    [[
    	update 	tbl_item_collectivity_depot set	cds_uId = ?,icd_uPageIndex = ?,icd_uPos = ?
    	where 	is_uId = ?
    ]]
}
DefineSql(StmtDef,StmtOperater)
--������id�޸���Ʒ�ڲֿ��е�λ�á�
function CDepotSqlMgrBox.UpdateCDepotItemPosByID(nToDepotID,nToPage,nToPos,nItemID)
	StmtOperater._UpdateCDepotItemPosByID:ExecSql('',nToDepotID,nToPage,nToPos,nItemID)
end


--����idɾ���ֿ���Ʒ
local StmtDef=
{
    "_DelCDepotItemByID",
    [[
    	delete	from  tbl_item_collectivity_depot  where  is_uId = ?
    ]]
}
DefineSql(StmtDef,StmtOperater)
function CDepotSqlMgrBox.DelCDepotItemByID(nItemID)
	StmtOperater._DelCDepotItemByID:ExecSql('',nItemID)
end

local StmtDef=
{
    "_GetPosCountByType",
    [[ 
     select
     		TDepot.icd_uPageIndex,TDepot.icd_uPos,count(TDepot.icd_uPageIndex) 
     from
     	 	tbl_item_static as item 
     join tbl_item_collectivity_depot as TDepot 
     			on TDepot.is_uId = item.is_uId
     where
     		TDepot.cds_uId = ? 
     		and item.is_uType = ?
     		and item.is_sName = ? 
     group by TDepot.icd_uPageIndex,TDepot.icd_uPos 
    ]]
}
DefineSql(StmtDef,StmtOperater)
function CDepotSqlMgrBox.GetPosCountByType(nDepotID,nBigID,nIndex)
	local query_result = StmtOperater._GetPosCountByType:ExecStat(nDepotID,nBigID,nIndex)
	
	return query_result
end


--�õ�ĳλ���ϵ���Ʒ���ͣ����ƣ�����
local StmtDef=
{
    "_GetDepotItemTypeNameAndCountByPos",
    [[
    	select  item.is_uType, item.is_sName,count(*)
    	from 	tbl_item_collectivity_depot as depot, tbl_item_static as item
    	where 	depot.is_uId = item.is_uId
    	and		depot.cds_uId = ?
    	and		depot.icd_uPageIndex = ?
    	and		depot.icd_uPos = ?
    	group by 
    			depot.icd_uPageIndex,
    			depot.icd_uPos
    ]]
}
DefineSql(StmtDef,StmtOperater)
--�����ĳ�ֿ�ĳλ���ϵ���Ʒ���ͣ����ƣ�������
function CDepotSqlMgrBox.GetDepotItemTypeNameAndCountByPos(nDepotID, nPage, nPos)
	local query_list = StmtOperater._GetDepotItemTypeNameAndCountByPos:ExecStat(nDepotID, nPage, nPos)
	if query_list:GetRowNum() == 0 then
		return nil,nil,0
	else
		local type = query_list:GetData(0,0)
		local name = query_list:GetData(0,1)
		local count = query_list:GetData(0,2)
		return type,name,count
	end
end

--�õ�ĳλ����������Ʒ��id
local StmtDef=
{
    "_GetDepotItemIDByPos",
    [[
    	select  is_uId
    	from 	tbl_item_collectivity_depot
    	where 	cds_uId = ?
    	and		icd_uPageIndex = ?
    	and		icd_uPos = ?
    ]]
}
DefineSql(StmtDef,StmtOperater)
--�����ĳ�ֿ�ĳλ���ϵ�������Ʒid��
function CDepotSqlMgrBox.GetDepotItemIDByPos(nDepotID, nPage, nPos)
	local query_result = StmtOperater._GetDepotItemIDByPos:ExecStat(nDepotID, nPage, nPos)
	
	return query_result
end

--������Ʒ���ƣ����ͣ��ֿ�id�õ��òֿ������и���Ʒ��û�дﵽ�������޵���Ʒ��ҳ�������ӡ�����λ���ϵ�����
local StmtDef=
{
    "_GetPosCountByNameAndType",
    [[ 
     select
     		depot.icd_uPageIndex,depot.icd_uPos,count(depot.icd_uPageIndex) 
     from
     	 	tbl_item_static as item 
     join 	tbl_item_collectivity_depot as depot 
     	on 	depot.is_uId = item.is_uId
     where
     		depot.cds_uId = ? 
     		and item.is_uType = ?
     		and item.is_sName = ? 
     group by  depot.icd_uPageIndex,depot.icd_uPos
     		having count(depot.icd_uPageIndex)< ?;
    ]]
}
DefineSql(StmtDef,StmtOperater)
function CDepotSqlMgrBox.GetPosCountByNameAndType(nDepotID, sItemType, sItemName,nFoldLimit)
	local query_result = StmtOperater._GetPosCountByNameAndType:ExecSql('nnn', nDepotID, sItemType, sItemName,nFoldLimit)
	
	return query_result
end

local StmtDef=
{
    "_GetPosCountByPage",
    [[ 
     select
     		depot.icd_uPageIndex,depot.icd_uPos,count(depot.icd_uPageIndex) 
     from
     	 	tbl_item_static as item 
     join 	tbl_item_collectivity_depot as depot 
     	on 	depot.is_uId = item.is_uId
     where
     		depot.cds_uId = ? 
     		and depot.icd_uPageIndex = ?
     		and item.is_uType = ?
     		and item.is_sName = ? 
     group by  depot.icd_uPageIndex,depot.icd_uPos
     		having count(depot.icd_uPageIndex)< ?;
    ]]
}
DefineSql(StmtDef,StmtOperater)

function CDepotSqlMgrBox.GetPosCountByPage(nDepotID, sItemType, sItemName,nFoldLimit,nPage)
	local query_result = StmtOperater._GetPosCountByPage:ExecSql('nnn', nDepotID,nPage, sItemType, sItemName,nFoldLimit)
	
	return query_result
end

--�õ�ĳ�ֿ���������Ʒ��λ��
local StmtDef=
{
    "_SelectPosWhichHaveItem",
    [[
    	select
     		icd_uPageIndex, icd_uPos
     	from
     	 	tbl_item_collectivity_depot
     	where
     		cds_uId = ? 
     	group by  
     		icd_uPageIndex,
     		icd_uPos
     		
    ]]
}
DefineSql(StmtDef,StmtOperater)
--�����ݲֿ�id�õ��òֿ���������Ʒ��λ����Ϣ��
function CDepotSqlMgrBox.GetPosWhichHaveItem(nDepotID)
	local query_result = StmtOperater._SelectPosWhichHaveItem:ExecStat(nDepotID)
	
	return query_result
end
local StmtDef=
{
    "_GetPosWhichHaveItemByPage",
    [[
    	select
     		icd_uPageIndex, icd_uPos
     	from
     	 	tbl_item_collectivity_depot
     	where
     		cds_uId = ? 
     		and icd_uPageIndex = ?
     	group by  
     		icd_uPageIndex,
     		icd_uPos
     		
    ]]
}
DefineSql(StmtDef,StmtOperater)
function CDepotSqlMgrBox.GetPosWhichHaveItemByPage(nDepotID,nPage)
	local query_result = StmtOperater._GetPosWhichHaveItemByPage:ExecSql("nn",nDepotID,nPage)
	
	return query_result
end

--���ݽ�ɫid��ȡ���ֿ�id
local StmtDef=
{
    "_GetTongDepotIDByCharID",
    [[
    	select t_uDepotID from tbl_member_tong as memb,tbl_tong as tong
     where memb.t_uId = tong.t_uId  
     and memb.cs_uId = ?
    ]]
}
DefineSql(StmtDef,StmtOperater)

function CDepotSqlMgrBox.GetTongDepotIdByCharID(nCharID)
	local tblTongDepotID = StmtOperater._GetTongDepotIDByCharID:ExecSql('n',nCharID)
	if tblTongDepotID:GetRowNum() == 0 then
		return 0
	end
	return tblTongDepotID:GetData(0,0)
end

--���ݰ�����ƻ�ȡ���ֿ�id
local StmtDef=
{
    "_GetTongDepotIDByTongName",
    [[
    	select t_uDepotID from tbl_tong
     where t_sName = ?
    ]]
}
DefineSql(StmtDef,StmtOperater)

function CDepotSqlMgrBox.GetTongDepotIDByTongName(tong_name)
	local tblTongDepotID = StmtOperater._GetTongDepotIDByTongName:ExecSql('n',tong_name)
	if tblTongDepotID:GetRowNum() == 0 then
		return 0
	end
	return tblTongDepotID:GetData(0,0)
end

---------------------------------------------
return CDepotSqlMgrBox
