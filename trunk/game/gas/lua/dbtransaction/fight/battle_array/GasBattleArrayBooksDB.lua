gac_gas_require "item/item_info_mgr/ItemInfoMgr"

local CGasBattleArrayBooks = class()
local g_ItemInfoMgr = CItemInfoMgr:new()
local event_type_tbl = event_type_tbl

local BattleArrayBooksSql = CreateDbBox(...)
local StmtDef = {
			"_SaveBattleShape",
			--����������Ϣ
			[[ 
				replace into tbl_battle_shape(cs_uId,bs_sName,bs_uPos1,bs_uPos2,bs_uPos3,bs_uPos4,bs_uPos5,bs_uFlag) values(?,?,?,?,?,?,?,?)
			]]
}
DefineSql (StmtDef,CGasBattleArrayBooks)

local StmtDef = {
			"_UpdateBattleShape",
			--����������Ϣ(�������ID��������)
			[[
				update tbl_battle_shape set bs_uPos1=? , bs_uPos2=? , bs_uPos3=? , bs_uPos4=? , bs_uPos5=?,bs_uFlag = 1 where cs_uId=? and bs_sName=?
			]]
}
DefineSql (StmtDef,CGasBattleArrayBooks)


local StmtDef = {
			"_QueryBattleShape",
			--��ѯ������Ϣ(�������ID��������)
			[[ 
					select bs_uId,bs_uPos1, bs_uPos2,bs_uPos3, bs_uPos4,bs_uPos5 ,bs_uFlag  from tbl_battle_shape where cs_uId=? and bs_sName=? 
			]]
}
DefineSql (StmtDef,CGasBattleArrayBooks)

local StmtDef = {
			"_SaveArrayBattle",
			--����������Ϣ
			[[ 
				insert into	tbl_battle_array(bs_uId,t_uId,ba_uLoc1,ba_uLoc2,ba_uLoc3,ba_uLoc4,ba_uLoc5) values(?,?,?,?,?,?,?)
			]]
}
DefineSql (StmtDef,CGasBattleArrayBooks)

local StmtDef = {
			"_UpdateArrayBattle",
			--����������Ϣ(������ˮ�ź�С��ID)
			[[ 
				update tbl_battle_array set ba_uLoc1=? , ba_uLoc2=? , ba_uLoc3=? , ba_uLoc4=? ,ba_uLoc5=?  where bs_uId=? and t_uId=?
			]]
}
DefineSql (StmtDef,CGasBattleArrayBooks)

local StmtDef = {
			"_QueryArrayBattle",
			--��ѯ������Ϣ(������ˮ�ź�С��ID)
			[[ 
				select ba_uLoc1,ba_uLoc2,ba_uLoc3,ba_uLoc4,ba_uLoc5 from	tbl_battle_array where bs_uId=? and t_uId=?
			]]
}
DefineSql (StmtDef,CGasBattleArrayBooks)

local StmtDef = {
			"_QueryBattleName",
			--��ѯ��������(������ˮ��)
			[[ 
				select bs_sName from tbl_battle_shape where bs_uId=?
			]]
}
DefineSql (StmtDef,CGasBattleArrayBooks)

local StmtDef = {
			"_DeleteArrayBattle",
			--ɾ��������Ϣ(������ˮ�ź�С��ID)
			[[ 
				delete from	tbl_battle_array where bs_uId = ? and t_uId = ?
			]]
}
DefineSql (StmtDef,CGasBattleArrayBooks)

local StmtDef = {
			"_UpdateBattleShapeFlag",
			--���ñ�־����(����С��ID��������)
			[[ 
				update tbl_battle_shape set bs_uFlag = ? where cs_uId=? and bs_sName= ?
			]]
}
DefineSql (StmtDef,CGasBattleArrayBooks)


local StmtDef = {
			"_UpdateBattleBook",
			--��������(��������ID)
			[[ 
				update tbl_item_battlebook set ib_uPos1 = ?,ib_uPos2 = ?,ib_uPos3 = ?,ib_uPos4 = ?,ib_uPos5=? where is_uId = ?
			]]
}
DefineSql (StmtDef,CGasBattleArrayBooks)

local StmtDef = {
			"_DeleteBattleBook",
			--ɾ��������Ϣ(������ƷIDɾ����Ʒ��̬��)
			[[ 
				delete from	tbl_item_battlebook where is_uId = ?
			]]
}
DefineSql (StmtDef,CGasBattleArrayBooks)

local StmtDef = {
			"_SelectArrayBook",
			--��ѯ����Ķ�̬��Ϣ
			[[ 
				select is_uId,ib_uPos1,ib_uPos2,ib_uPos3,ib_uPos4,ib_uPos5 from tbl_item_battlebook where is_uId = ?
			]]
}
DefineSql (StmtDef,CGasBattleArrayBooks)

local StmtDef = {
			"_SaveSkillBattle",
			--�����¼���
			[[
				replace into tbl_battle_skill_icon values(?,?,?)
			]]
}
DefineSql (StmtDef,CGasBattleArrayBooks)

local StmtDef = {
			"_DeleteSkillBattle",
			--���¼���
			[[ 
				delete from tbl_battle_skill_icon where cs_uId = ? and bsi_uPos = ?
			]]
}
DefineSql (StmtDef,CGasBattleArrayBooks)

------------------------------------------------------------------------
-- @brief ���漼��
function BattleArrayBooksSql.SaveSkillBattle(data)
	local b_name = data["b_name"]
	local b_pos = data["b_pos"]
	local playerId = data["playerId"]
	if b_pos >= 1 and b_pos <= 8 then
		if b_name == "" then
			CGasBattleArrayBooks._DeleteSkillBattle:ExecSql("",playerId,b_pos)
			return g_DbChannelMgr:LastAffectedRowNum() > 0
		else
			CGasBattleArrayBooks._SaveSkillBattle:ExecSql("",playerId,b_pos,b_name)
			return g_DbChannelMgr:LastAffectedRowNum() > 0
		end
	else
		return 110017
	end
end
-------------------------------------------------------------------------
--ͨ����ƷID��ѯ��Ʒ��̬��(������ƷID)
function BattleArrayBooksSql.SelectBattleBookByID(ItemId)
	local res = CGasBattleArrayBooks._SelectArrayBook:ExecStat(ItemId)
	local tbl = {}
	if res:GetRowNum()>0 then
		tbl[1] = res:GetData(0,0)
		tbl[2] = res:GetData(0,1)
		tbl[3] = res:GetData(0,2)
		tbl[4] = res:GetData(0,3)
		tbl[5] = res:GetData(0,4)
		tbl[6] = res:GetData(0,5)
	end
	return tbl
end
--------------------------------------------------------------------------
--��ѯ������Ϣ����ʵ��(�������ID��������)
function BattleArrayBooksSql.SelectBattleShape(data)
	local PlayerId = tonumber(data["PlayerId"])
	local b_sName = tostring(data["b_sName"])
	local tbl = {}
	
	if PlayerId ~= nil and PlayerId > 0 and assert(IsString(b_sName)) then
		local res = CGasBattleArrayBooks._QueryBattleShape:ExecSql("nnnnnnn",PlayerId,b_sName)
		if nil ~= res and res:GetRowNum()>0 then   
			tbl[1] = res:GetData(0,0)
			tbl[2] = res:GetData(0,1)
			tbl[3] = res:GetData(0,2)
			tbl[4] = res:GetData(0,3)
			tbl[5] = res:GetData(0,4)
			tbl[6] = res:GetData(0,5)
			tbl[7] = res:GetData(0,6)
		end
	end
	return tbl
end
--------------------------------------------------------------------------
--��ѯ������Ϣ(��������ˮ�ź�С��ID)
function BattleArrayBooksSql.SelectArrayBattleInfo(data)
	local PlayerId = tonumber(data["PlayerId"])
	local b_sName = tostring(data["b_sName"])
	local b_uId = data["b_uId"]
	
	local queryData = {
										["PlayerId"] = PlayerId,
										["b_sName"] = b_sName
										}
	
	local team = RequireDbBox("GasTeamDB")
  local teamId = team.GetTeamID(PlayerId)	
  
	--��ѯ������Ϣ(�������ID��������)
	local battleshaperesult = BattleArrayBooksSql.SelectBattleShape(queryData)
	--��������ʹ����ٲ�ѯ������Ͷ�Ӧ��������Ϣ
	
	local ret
	if #battleshaperesult > 0 then
		b_uId = battleshaperesult[1]
		ret = CGasBattleArrayBooks._QueryArrayBattle:ExecSql("nnnnn",b_uId,teamId)
	end
	local ret_row = {}
	if ret:GetRowNum() ~= 0 then
		ret_row[1] = ret:GetData(0,0)
		ret_row[2] = ret:GetData(0,1)
		ret_row[3] = ret:GetData(0,2)
		ret_row[4] = ret:GetData(0,3)
		ret_row[5] = ret:GetData(0,4)
	end
	local team_box = RequireDbBox("GasTeamDB")
	local uCapatinID =  team_box.GetCaptain(teamId)
	return battleshaperesult,ret_row,uCapatinID
end
--------------------------------------------------------------------------
--ɾ��������Ϣ(��������ˮ�ź�С��ID)
function BattleArrayBooksSql.DeleteArrayBattleInfo(data)
	local b_uId = tonumber(data["b_uId"])
	local teamId = tonumber(data["teamId"])
	if assert(IsNumber(b_uId)) and assert(IsNumber(teamId)) then
		CGasBattleArrayBooks._DeleteArrayBattle:ExecSql("",b_uId,teamId)
		return g_DbChannelMgr:LastAffectedRowNum() > 0
	end
	return false
end
--------------------------------------------------------------------------
--�����󷨵ı�ʶ����
function BattleArrayBooksSql.UpdateBattleShapeFlag(data)
	local PlayerId = tonumber(data["PlayerId"])
	local b_sName = tostring(data["b_sName"])
	if assert(IsNumber(PlayerId)) and assert(IsString(b_sName)) then
		CGasBattleArrayBooks._UpdateBattleShapeFlag:ExecSql("",0,PlayerId,b_sName)
		return g_DbChannelMgr:LastAffectedRowNum() > 0
	end
	return false
end
--------------------------------------------------------------------------
--��������Ķ�̬��Ϣ
function BattleArrayBooksSql.UpdateBattleBook(data)
	local ItemId = tonumber(data["ItemId"])
	local PlayerId = tonumber(data["PlayerId"])
	local b_sName = tostring(data["b_sName"])
	
	local querydata = {
								["PlayerId"] = PlayerId,
								["b_sName"] = b_sName
								}
	local tbl = BattleArrayBooksSql.SelectBattleShape(querydata)
	if #tbl > 0 and assert(IsNumber(ItemId)) then
		CGasBattleArrayBooks._UpdateBattleBook:ExecSql("",tbl[2],tbl[3],tbl[4],tbl[5],tbl[6],ItemId)
		return g_DbChannelMgr:LastAffectedRowNum() > 0
	end
	return false
end
--------------------------------------------------------------------------
--��������Ϣ
function BattleArrayBooksSql.UpdateBattleShape(data)
	local PlayerId = data["PlayerId"]
	local b_sName = data["b_sName"]
	local b_uPos1 = data["b_uPos1"]
	local b_uPos2 = data["b_uPos2"]
	local b_uPos3 = data["b_uPos3"]
	local b_uPos4 = data["b_uPos4"]
	local b_uPos5 = data["b_uPos5"]

	CGasBattleArrayBooks._UpdateBattleShape:ExecSql("",b_uPos1,b_uPos2,b_uPos3,b_uPos4,b_uPos5,PlayerId,b_sName)
	
	return g_DbChannelMgr:LastAffectedRowNum() > 0
end
--------------------------------------------------------------------------
local StmtDef = {
			"_QueryBattleBookByItemId",
			--��Ұ��������Ƿ�������(������ƷID)
			[[ 
					select is_uId from tbl_item_in_grid as iip,tbl_grid_in_room as igp
					where iip.gir_uGridID = igp.gir_uGridID and cs_uId=? and gir_uRoomIndex=? and gir_uPos=?
			]]
}
DefineSql (StmtDef,CGasBattleArrayBooks)


--����������Ϣ
function BattleArrayBooksSql.SaveBattleShape(data)
	local PlayerId = data["PlayerId"]
	local b_sName = data["b_sName"]
	local b_uPos1 = data["b_uPos1"]
	local b_uPos2 = data["b_uPos2"]
	local b_uPos3 = data["b_uPos3"]
	local b_uPos4 = data["b_uPos4"]
	local b_uPos5 = data["b_uPos5"]
	local nRoomIndex = data["nRoomIndex"]
	local nPos = data["nPos"]
	local queryData = {
											["PlayerId"] = PlayerId,
											["b_sName"] = b_sName
										}
	local updateData = {
											["PlayerId"] = PlayerId,
											["b_sName"] = b_sName,
											["b_uPos1"] = b_uPos1,
											["b_uPos2"] = b_uPos2,
											["b_uPos3"] = b_uPos3,
											["b_uPos4"] = b_uPos4,
											["b_uPos5"] = b_uPos5
											}
	local bookInfo = CGasBattleArrayBooks._QueryBattleBookByItemId:ExecSql("n",PlayerId,nRoomIndex,nPos)
	--�����ﲻ���ڸ�����
	if bookInfo and bookInfo:GetRowNum() == 0 then
		return false
	end
	--����ˮ��
	local a = 0 
	local res = nil
	--��ѯ���Ϳ�������û�б����������
	local tbl = BattleArrayBooksSql.SelectBattleShape(queryData)
	--������͸��¸�����
	if #tbl > 0 and tbl[7] == 0 then
		BattleArrayBooksSql.UpdateBattleShape(updateData)
		a = tbl[1]
	elseif (#tbl == 0) then
		--û����������²����¼�¼
		CGasBattleArrayBooks._SaveBattleShape:ExecSql("",PlayerId,b_sName,b_uPos1,b_uPos2,b_uPos3,b_uPos4,b_uPos5,1)
		a = g_DbChannelMgr:LastInsertId()
	end
	
	local g_RoomMgr = RequireDbBox("GasRoomMgrDB")
	if (nRoomIndex ~= -1 and nPos ~= -1) then 
		local ItemsType,ItemName,ItemCount = g_RoomMgr.GetTypeCountByPosition(PlayerId,nRoomIndex,nPos)
		if ( tonumber(ItemsType) == 26 and ItemName == b_sName) then
			res = g_RoomMgr.DelItemByPos(PlayerId,nRoomIndex,nPos,1,event_type_tbl["��Ʒʹ��"])
			if IsNumber(res) then
				return false
			end
		end
	end
	return a,res
end
--------------------------------------------------------------------------
--��ѯ��������
function BattleArrayBooksSql.SelectBattleName(data)
	local b_uId = data["b_uId"]
	local ret = nil
	if assert(IsNumber(b_uId)) then
		local tbl = CGasBattleArrayBooks._QueryBattleName:ExecSql("s[32]",b_uId)
		if (tbl:GetRowNum() > 0)then
			ret = tbl:Data(0,0)
		end
	end
	return ret
end
--------------------------------------------------------------------------
--����������Ϣ
function BattleArrayBooksSql.SaveBattleArray(data)
	local b_uId = data["b_uId"]
	local b_sName = data["b_sName"]
	local PlayerId = data["PlayerId"]
	local ab_uLoc1 = BattleArrayBooksSql.CheckBattleArrayLoc(data["ab_uLoc1"])
	local ab_uLoc2 = BattleArrayBooksSql.CheckBattleArrayLoc(data["ab_uLoc2"])
	local ab_uLoc3 = BattleArrayBooksSql.CheckBattleArrayLoc(data["ab_uLoc3"])
	local ab_uLoc4 = BattleArrayBooksSql.CheckBattleArrayLoc(data["ab_uLoc4"])
	local ab_uLoc5 = BattleArrayBooksSql.CheckBattleArrayLoc(data["ab_uLoc5"])
	
	local team = RequireDbBox("GasTeamDB")
  local teamId = team.GetTeamID(PlayerId)			
  
	local PlayerIdTbl = {}
	local tbl = {ab_uLoc1, ab_uLoc2, ab_uLoc3, ab_uLoc4, ab_uLoc5}
	for i, p in pairs(tbl) do
		table.insert(PlayerIdTbl, p)
	end
	table.sort(PlayerIdTbl, function(a, b) return a < b end)
	--���С�����������ID
	local team_box = RequireDbBox("GasTeamDB")
	local tblMembers = team_box.GetTeamMembers(teamId)
	table.sort(tblMembers, function(a, b) return a[1] < b[1] end)
	
	if(#PlayerIdTbl ~= #tblMembers) then 
		return false
	end

	for i=1, #tblMembers do
		if(PlayerIdTbl[i] ~= tblMembers[i][1])then 
			return false 
		end
	end

	local queryNameData = {
										["b_uId"] = b_uId
										}
	local queryInfoData = {
										["b_uId"] = b_uId,
										["teamId"] = teamId,
										["b_sName"] = b_sName,
										["PlayerId"] = PlayerId 
										}
	local updateInfoData = {
										["ab_uLoc1"] = ab_uLoc1,
										["ab_uLoc2"] = ab_uLoc2,
										["ab_uLoc3"] = ab_uLoc3,
										["ab_uLoc4"] = ab_uLoc4,
										["ab_uLoc5"] = ab_uLoc5,
										["b_uId"] = b_uId,
										["teamId"] = teamId
										}
	local ret = false
	--��������ˮ�Ų�ѯ������
	local result = BattleArrayBooksSql.SelectBattleName(queryNameData)
	
	if( not result or result ~= b_sName) then
		return ret
	end
	
	--��ѯ������Ϣ
	local _,query_list = BattleArrayBooksSql.SelectArrayBattleInfo(queryInfoData)
	if #query_list > 0 then
		BattleArrayBooksSql.UpdateArrayBattle(updateInfoData)
		return g_DbChannelMgr:LastAffectedRowNum() > 0
	else
		CGasBattleArrayBooks._SaveArrayBattle:ExecSql("",b_uId,teamId,ab_uLoc1,ab_uLoc2,ab_uLoc3,ab_uLoc4,ab_uLoc5)
		return g_DbChannelMgr:LastAffectedRowNum() > 0	
	end
end
--------------------------------------------------------------------------
--����������Ϣ
function BattleArrayBooksSql.UpdateArrayBattle(data)
	local ab_uLoc1 = data["ab_uLoc1"]
	local ab_uLoc2 = data["ab_uLoc2"]
	local ab_uLoc3 = data["ab_uLoc3"]
	local ab_uLoc4 = data["ab_uLoc4"]
	local ab_uLoc5 = data["ab_uLoc5"]
	local b_uId = data["b_uId"]
	local teamId = data["teamId"]
	CGasBattleArrayBooks._UpdateArrayBattle:ExecSql("",ab_uLoc1,ab_uLoc2,ab_uLoc3,ab_uLoc4,ab_uLoc5,b_uId,teamId)
	return g_DbChannelMgr:LastAffectedRowNum() > 0
end
--------------------------------------------------------------------------
--�жϿͻ��˴������Ĳ����ǲ���Ϊ0��Ϊ0���ǿձ��
function BattleArrayBooksSql.CheckBattleArrayLoc(ab_uLoc)
	if ab_uLoc == 0 then
		return nil
	end
		return ab_uLoc
end
--------------------------------------------------------------------------
----�󷨻�ԭ������
function BattleArrayBooksSql.RevertToBattleArrayBook(data)
	local PlayerId = tonumber(data["PlayerId"])
	local b_sName = tostring(data["b_sName"])
	local b_uId = data["b_uId"]
	local arraybattledata = {
													["b_uId"] = b_uId,
													["teamId"] = teamId,
													["PlayerId"] = PlayerId,
													["b_sName"] = b_sName
													}
	local battleshapedata = {
													["PlayerId"] = PlayerId,
													["b_sName"] = b_sName
													}			
	local team = RequireDbBox("GasTeamDB")
  local teamId = team.GetTeamID(PlayerId)																		
	--��ѯ������Ϣ
	local _,arraybattleInfo = BattleArrayBooksSql.SelectArrayBattleInfo(arraybattledata)
	
	--��������Ϣ��ɾ����ע�⣺��Ϊ��������Ϣ�����и�������Ϣ����ֶΣ������������������һ������ɾ������Ϣ����ɾ������Ϣ��
	if #arraybattleInfo > 0 then
		BattleArrayBooksSql.DeleteArrayBattleInfo(arraybattledata)	
	end
	
	--��ѯ����Ƿ�ӵ�и���
	local queryData = {
										["PlayerId"] = PlayerId,
										["b_sName"] = b_sName
										}
	--��ѯ������Ϣ(�������ID��������)
	local battleshaperesult = BattleArrayBooksSql.SelectBattleShape(queryData)
	if nil == battleshaperesult then
		return 
	end
	
	if #battleshaperesult == 0 or battleshaperesult[7] == 0 then
		return
	end

	--�����󷨵ı�ʶ����
	BattleArrayBooksSql.UpdateBattleShapeFlag(battleshapedata)
	--����������Ҫת��������
	local g_RoomMgr = RequireDbBox("GasRoomMgrDB")
	local nBigID = g_ItemInfoMgr:GetBattleArrayBooksBigID()
	local params= {}
	params.m_nType = nBigID
	params.m_sName =b_sName
	params.m_nBindingType = g_ItemInfoMgr:GetItemInfo( nBigID,b_sName,"BindingStyle" ) or 0
	params.m_nCharID =PlayerId
	params.m_sCreateType = event_type_tbl["�󷨻�ԭ������"]
	local item_id = g_RoomMgr.CreateItem(params)

	local updatebattlebook = {
													["PlayerId"] = PlayerId,
													["b_sName"] = b_sName,
													["ItemId"] = item_id
													}
	local param = {}
	param.m_nCharID = PlayerId
	param.m_nItemType = 26
	param.m_sItemName = b_sName
	param.m_tblItemID = {{item_id}}
	local putitemtobag = RequireDbBox("CPutItemToBagDB")
	local succ,info = putitemtobag.AddCountItem(param)
	--��������Ķ�̬��Ϣ
	BattleArrayBooksSql.UpdateBattleBook(updatebattlebook)
  return succ,info 
end
--------------------------------------------------------------------------------

SetDbLocalFuncType(BattleArrayBooksSql.SaveBattleShape)
SetDbLocalFuncType(BattleArrayBooksSql.SaveBattleArray)
SetDbLocalFuncType(BattleArrayBooksSql.SelectArrayBattleInfo)
SetDbLocalFuncType(BattleArrayBooksSql.RevertToBattleArrayBook)
SetDbLocalFuncType(BattleArrayBooksSql.SaveSkillBattle)
return BattleArrayBooksSql
