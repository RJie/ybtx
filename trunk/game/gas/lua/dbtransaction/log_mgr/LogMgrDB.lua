
local os = os
local _WriteShellLog = WriteShellLog
local tbl_cat = table.concat
local LogErr 	= LogErr
local event_type_tbl = event_type_tbl
local LogDBName = DeployConfig.MySqlDatabase .. "_log"

local function WriteLog(...)
	local arg = {...}
	
	_WriteShellLog(tbl_cat(arg, "\t"))
end

local CLogMgrDB = CreateDbBox(...)

local function LogStmtCall(Stmt,...)
	Stmt:ExecSql( "", ... )
end
------------------------------------------------------------------------------------
local StmtContainer = {}
local StmtDef=
{
	"_InsertEventStmt",
	"insert into "..  LogDBName .. ".tbl_log_event set le_dtDateTime=from_unixtime(?)"
}
DefineSql(StmtDef,StmtContainer)

--@brief �����¼�Id
function CLogMgrDB._InsertEvent()
	LogStmtCall(StmtContainer._InsertEventStmt, os.time())
	return g_DbChannelMgr:LastInsertId()
end
------------------------------------------------------------------------------------
--�����˺���Ϣ
function CLogMgrDB.CopyUserInfo(userId,userName)
	if userId then
		WriteLog("tbl_log_user_static",userId,userName,os.date("%y-%m-%d %H:%M:%S"))
	end
end
----------------------------------------------------------------------------------
--���ݽ�ɫ�б�
function CLogMgrDB.CopyCharList(charId,charName)
	WriteLog("tbl_log_char",charId,charName)
end
----------------------------------------------------------------------------------
--ɾ����ɫ�б�
function CLogMgrDB.DelCharList(charId,charName)
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_char_deleted",uEventId,charId,charName)
end
----------------------------------------------------------------------------------
--���ݽ�ɫ��Ϣ
function CLogMgrDB.CopyCharInfo(charId,userId,hair,hairColor,face,scale,gender,class,camp,inherence)
	if IsNumber(charId) then
		WriteLog("tbl_log_char_static",charId,userId,hair,hairColor,face,scale,gender,class,camp,os.date("%y-%m-%d %H:%M:%S"))
	end
end
----------------------------------------------------------------------------------
--������Ʒ��Ϣ
function CLogMgrDB.CopyItemInfo(itemId,itemType,ItemName,charId,code)
	WriteLog("tbl_log_item_static",itemId,itemType , ItemName,charId,code)
end
-------------------------------------------------[[��¼�ǳ����]]--------------------------------------------
--@brief ��¼
--@param uUserId:�ʺ�Id
function CLogMgrDB.LogLogin(uUserId,ip,sn)
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_user",uEventId , uUserId)
	WriteLog("tbl_log_login",uEventId,ip,sn)
end
-----------------------------------------------------------------
--@brief �ǳ�
--@param uUserId:�ʺ�Id
function CLogMgrDB.LogLogout(uUserId,sn)
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_user",uEventId , uUserId)
	WriteLog("tbl_log_logout",uEventId, sn)
end
-----------------------------------------------------------------
--@brief ��ɫ��¼
function CLogMgrDB.LogCharLogin(uCharId,uLevel)
	local uEventId = CLogMgrDB._InsertEvent()
	
	WriteLog("tbl_log_char_login",uEventId,uCharId,uLevel)
end
------------------------------------------- [[�Ӿ���������Ϣ]]------------------------------------
--@brief ������¼�����Ϣ
--@param uCharID:��ɫId
--@param CurLevel:��ɫ������ĵȼ�
function CLogMgrDB.PlayerLevelUpLog( uCharID, CurLevel)
	local uEventId = CLogMgrDB._InsertEvent() 
	WriteLog("tbl_log_player",uEventId , uCharID)
	WriteLog("tbl_log_level",uEventId , CurLevel)
	WriteLog("tbl_log_event_type",uEventId , event_type_tbl["��ɫ����"])		
end
--------------------------------------------------------------


local StmtDef=
{
	"_SelectExpCode",
	"select se_sCode from " .. LogDBName .. ".tbl_serial_experience where lcs_uId = ?"

}
DefineSql(StmtDef,StmtContainer)

local StmtDef=
{
	"_SaveExpCode",

	"replace into " .. LogDBName .. ".tbl_serial_experience set lcs_uId = ?, se_sCode = md5(?)"

}
DefineSql(StmtDef,StmtContainer)

--@brief �Ӿ����¼�����Ϣ
--@param uCharID:��ɫId
--@param CurLevel:��ɫ������ĵȼ�
--@param nAddExp:��ɫ���Ӿ���ֵ
function CLogMgrDB.LogPlayerAttribute( uCharID, CurLevel, nAddExp,addExpType,totalExp,eventId )
	if addExpType == nil and eventId == nil then
		LogErr("�޸ľ���û�м�¼log����")
	end
	local uEventId = eventId
	if not uEventId then
		uEventId = CLogMgrDB._InsertEvent() 
		WriteLog("tbl_log_player_taker",uEventId , uCharID)
		WriteLog("tbl_log_event_type",uEventId ,addExpType)
	end
	WriteLog("tbl_log_level",uEventId , CurLevel)
	local code_res = StmtContainer._SelectExpCode:ExecStat(uCharID)
	local code
	if code_res and code_res:GetRowNum() > 0 then
		code = code_res:GetData(0,0)
	else
		code = "tbl_log_experience"
	end
	
	WriteLog("tbl_log_experience",uEventId ,uCharID, nAddExp,totalExp,code)
  	LogStmtCall( StmtContainer._SaveExpCode, uCharID ,code)
	return g_DbChannelMgr:LastAffectedRowNum() > 0
end
---------------------------------------[[��Ʒ����]]-----------------------------------
--@brief ��Ʒ�Ĳ���
--@param uCharId����ɫId
--@param uItemId����ƷId
--@param sSceneName:�����ĳ�������
function CLogMgrDB.LogCreateItem(uCharId,uItemId,createType,eventId)
	if createType == nil and eventId == nil then
		LogErr("��Ʒ����û�м�¼log����")
	end
	
	local uEventId = eventId
	if not uEventId then
		uEventId = CLogMgrDB._InsertEvent()
		WriteLog("tbl_log_player_taker",uEventId , uCharId)
		WriteLog("tbl_log_event_type",uEventId , createType)
	end
	WriteLog("tbl_log_item_taker",uEventId , uItemId)
end
----------------------------------------------------------------------------------------
--@brief ��Ʒ��
--@param uCharId����ɫId
--@param uItemId����ƷId
--@param uBindType:������
function CLogMgrDB.LogItemBindInfo(uCharId,uItemId,uBindType)
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_player",uEventId , uCharId)
	WriteLog("tbl_log_item_binding",uEventId , uItemId,uBindType)
end
----------------------------------------------------------------------------------------
local StmtDef=
{
	"_SelectDelItemCode",

	"select sid_sCode from " .. LogDBName .. ".tbl_serial_item_del where lcs_uId = ?"

}
DefineSql(StmtDef,StmtContainer)

local StmtDef=
{
	"_SaveDelItemCode",

	"replace into " .. LogDBName .. ".tbl_serial_item_del set lcs_uId = ?, sid_sCode = md5(?)"

}
DefineSql(StmtDef,StmtContainer)

--@brief ��Ʒ��ɾ��(���Ļ���)
--@param uCharId����ɫId
--@param uItemId����ƷId
--@param delType��ɾ�������� 9--ʹ�� 10--����
function CLogMgrDB.LogDelAndUseItem(eventId,uCharId,uItemId,delType,item_type,item_name)
	local uEventId = eventId
	if not uEventId then
		uEventId = CLogMgrDB._InsertEvent()
		WriteLog("tbl_log_player_giver",uEventId , uCharId)
		WriteLog("tbl_log_event_type",uEventId , delType)
	end
	local code_res = StmtContainer._SelectDelItemCode:ExecStat(uCharId)
	local code
	if code_res:GetRowNum() > 0 then
		code = code_res:GetData(0,0)
	else
		code = "tbl_log_item_del"
	end
	CLogMgrDB.CopyItemInfo(uItemId,item_type,item_name,uCharId,"")
	WriteLog("tbl_log_item_del",uEventId , uItemId,code)
	LogStmtCall( StmtContainer._SaveDelItemCode, uCharId , code)
	return g_DbChannelMgr:LastAffectedRowNum() > 0,uEventId
end
----------------------------------------[[GMָ�����]]-----------------------------------
function CLogMgrDB.SaveGMLog(account, ip, content)
	WriteLog("tbl_log_gmcommand",account, ip,os.date("%y-%m-%d %H:%M:%S"), content)
end
--------------------------------------------[[��Ǯ����]]--------------------------------
local StmtDef=
{
	"_SelectMoneyCode",

	"select sm_sCode from " .. LogDBName .. ".tbl_serial_money where lcs_uId = ?"

}
DefineSql(StmtDef,StmtContainer)

local StmtDef=
{
	"_SaveMoneyCode",

	"replace into " .. LogDBName .. ".tbl_serial_money set lcs_uId = ?, sm_sCode = md5(?)"

}
DefineSql(StmtDef,StmtContainer)

--@brief ����Ǯ�ı仯,ͨ��Ǯ���������Ŀ���жϵ���Ӧ�ü�¼�����ű���
--@param uEventId:��ν�Ǯ���¼�Id
--@param MoneyType:��Ǯ����
--@param MoneyCount:��Ǯ������
function CLogMgrDB.PlayerMoneyModify( eventId, MoneyType, MoneyCount,uCharId,totalMoney,addType ,curlevel)
	if eventId == nil and addType == nil then
		LogErr("��ɫ��Ǯ�޸�û�м�log����!")
	end
	local uEventId
	if not eventId and addType > 1000 then
		uEventId = addType
	else
		uEventId = eventId
	end
	
	if not uEventId then
		uEventId = CLogMgrDB._InsertEvent()
		if MoneyCount >= 0 then
			WriteLog("tbl_log_player_taker",uEventId , uCharId)
		else
			WriteLog("tbl_log_player_giver",uEventId , uCharId)
		end
		WriteLog("tbl_log_event_type",uEventId ,addType)
	end

	local code_res = StmtContainer._SelectMoneyCode:ExecStat(uCharId)
	local code
	if code_res:GetRowNum() > 0 then
		code = code_res:GetData(0,0)
	else
		code = "tbl_log_money"		
	end
	WriteLog("tbl_log_level",uEventId , curlevel)
	WriteLog("tbl_log_money",uEventId,uCharId, MoneyCount,MoneyType,totalMoney,code)
	LogStmtCall(StmtContainer._SaveMoneyCode,uCharId,code)
	return g_DbChannelMgr:LastAffectedRowNum() > 0,uEventId
end
---------------------------------------------------------------------------------------
--@brief ��¼˰��log
function CLogMgrDB.SaveTaxLog(uMoneyCount,uCharId,addType)
	if addType == nil then
		LogErr("��¼˰��û�м�log����!")
	end
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_event_type",uEventId ,addType)
	local code_res = StmtContainer._SelectMoneyCode:ExecStat(uCharId)
	local code
	if code_res:GetRowNum() > 0 then
		code = code_res:GetData(0,0)
	else
		code = "tbl_log_money"		
	end
	local MoneyManagerDB = RequireDbBox("MoneyMgrDB")
	local totalMoney = MoneyManagerDB.GetMoneyByType(uCharId,1)
	WriteLog("tbl_log_money",uEventId,uCharId, -uMoneyCount,1,totalMoney,code)
end
---------------------------------------------------------------------------------------
--@brief ����װ����ǿ������
function CLogMgrDB.SetupEquipIntensifyLevelLog()
	local uEventId = CLogMgrDB._InsertEvent()
	
	WriteLog("tbl_log_equip_intensify_level_up",uEventId) 
	WriteLog("tbl_log_event_type",uEventId , event_type_tbl["����װ����ǿ������"])
	return uEventId
end
---------------------------------------------------------------------------------------
local StmtDef=
{
	"_SelectDepotMoneyCode",

	"select sdm_sCode from " .. LogDBName .. ".tbl_serial_depot_money where lcs_uId = ?"

}
DefineSql(StmtDef,StmtContainer)

local StmtDef=
{
	"_SaveDepotMoneyCode",

	"replace into " .. LogDBName .. ".tbl_serial_depot_money set lcs_uId = ?, sdm_sCode = md5(?)"

}
DefineSql(StmtDef,StmtContainer)

--@brief ��¼�ֿ���Ǯ����ͨ���
function CLogMgrDB.SaveMoneyChangedFromDepot(eventId,uMoneyCount,uCharId,uTotalMoney)
	if eventId == nil then
		LogErr("�޸Ĳֿ��Ǯû�м�¼log����")
	end
	local uEventId = eventId
	local code_res = StmtContainer._SelectDepotMoneyCode:ExecStat(uCharId)
	local code
	if code_res and code_res:GetRowNum() > 0 then
		code = code_res:GetData(0,0)
	else
		code = "tbl_log_depot_money"
	end
	WriteLog("tbl_log_depot_money",uEventId , uMoneyCount,uTotalMoney,code)
	LogStmtCall(StmtContainer._SaveDepotMoneyCode, uCharId,code)
	return g_DbChannelMgr:LastAffectedRowNum() > 0
end 
---------------------------------------------------------------------------------------
--@brief ������Ʒ��Ϣ
--@param tblItemData����ƷId��table
function CLogMgrDB.SaveItemInfoToLog(uEventId, tblItemData,table_name)
	if not tblItemData or #tblItemData == 0 then
		return
	end
	local item_list_len = #tblItemData
	for i = 1, item_list_len do
		WriteLog(table_name,uEventId, tblItemData[i])
	end	
end
-----------------------------------------[[�������]]--------------------------------
--@brief ������ɼ�¼
--@param PlayerId����ɫId
--@param sQuestName����������
function CLogMgrDB.FinishQuest(PlayerId, sQuestName)
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_quest_finish",uEventId, sQuestName)
	WriteLog("tbl_log_player_taker",uEventId, PlayerId)
	--WriteLog("tbl_log_npc_giver",uEventId , "����npc")
	WriteLog("tbl_log_event_type",uEventId , event_type_tbl["������"])
	return uEventId
end
-------------------------------------------------------------------------------------
--@brief ��������¼
--@param uEventId���¼�Id
--@param exp_info����������
function CLogMgrDB.AddHonorByEventId(uEventId,honor_count)
	if honor_count and honor_count > 0 then
		WriteLog("tbl_log_reputation",uEventId, honor_count)
	end
end
-------------------------------------------------------------------------------------
local StmtDef=
{
	"_SelectSoulCode",

	"select ss_sCode from " .. LogDBName .. ".tbl_serial_soul where lcs_uId = ?"

}
DefineSql(StmtDef,StmtContainer)

local StmtDef=
{
	"_SaveSoulCode",

	"replace into " .. LogDBName .. ".tbl_serial_soul set lcs_uId = ?, ss_sCode = md5(?)"

}
DefineSql(StmtDef,StmtContainer)


--@brief �ӻ��¼
--@param uEventId���¼�Id
--@param SoulRet���꽱��
function CLogMgrDB.AddSoulByEventId(eventId,SoulRet,addSoulType,char_id,totalSoul)
	if eventId == nil and addSoulType == nil then
		LogErr("�޸Ļ�û�м�¼log����")
	end
	local uEventId = eventId
	local soulValue = tonumber(SoulRet)
	if not uEventId then
		uEventId = CLogMgrDB._InsertEvent()
		if soulValue < 0 then --���Ļ�ֵ
			WriteLog("tbl_log_player_giver", uEventId , char_id)
		else 		-- ���ӻ�ֵ
			WriteLog("tbl_log_player_taker",uEventId , char_id)
		end
		WriteLog("tbl_log_event_type",uEventId , addSoulType)
	end
	local code_res = StmtContainer._SelectSoulCode:ExecStat(char_id)
	local code
	if code_res and code_res:GetRowNum() > 0 then
		code = code_res:GetData(0,0)
	else
		code = "tbl_log_soul"
	end
	WriteLog("tbl_log_soul",uEventId,char_id, soulValue,totalSoul,code)
	LogStmtCall( StmtContainer._SaveSoulCode, char_id , code)
	return g_DbChannelMgr:LastAffectedRowNum() > 0
end
------------------------------------------------------------------------------
--@brief ����ʧ�ܼ�¼
--@param uCharId����ɫId
--@param sQuestName����������
function CLogMgrDB.QuestFail(uCharId,sQuestName)
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_quest_failure",uEventId, uCharId, sQuestName)
end
------------------------------------------------------------------------------
--@brief ���������¼
--@param uCharId����ɫId
--@param sQuestName����������
function CLogMgrDB.GiveUpQuest(uCharId,sQuestName)
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_quest_giveup",uEventId, uCharId, sQuestName)
end
---------------------------------------------------------------------------------------------
--��ҷ����ʼ��¼�
--�ʼ�ϵͳ�����䣬�����ʼ��ļ�¼
--��¼�����ݰ��������������ʷ��ã�������Ʒ����ʱ���ӵ����ʣ����͵Ľ�Ǯ�Լ���Ʒ
--���������ʼ�ϵͳ�У���������Ϊ10��ÿ����һ��������������1
function CLogMgrDB.PlayerSendEmail( uSenderId, reciever_id,ItemData,eventId,uSendMoney)
	local uEventId = eventId
	if not uEventId then
		uEventId = CLogMgrDB._InsertEvent()
		WriteLog("tbl_log_event_type",uEventId , event_type_tbl["�ʼ�"])
		WriteLog("tbl_log_player_giver",uEventId , uSenderId )
	end
	WriteLog("tbl_log_player_taker",uEventId , reciever_id )
	
	if #ItemData > 0 then
		for i = 1,#ItemData do
			WriteLog("tbl_log_item",uEventId , ItemData[i] )
		end
	end
	if uSendMoney and uSendMoney ~= 0 then
		local code_res = StmtContainer._SelectMoneyCode:ExecStat(reciever_id)
		local code
		if code_res:GetRowNum() > 0 then
			code = code_res:GetData(0,0)
		else
			code = "tbl_log_money"		
		end
		local MoneyManagerDB = RequireDbBox("MoneyMgrDB")
		local totalMoney = MoneyManagerDB.GetMoneyByType(reciever_id,1)
		WriteLog("tbl_log_money",uEventId,reciever_id, uSendMoney,1,totalMoney,code)
	end
end
-----------------------------------------------------------------------------
--@brief ���ʼ���ȡ��Ʒдlog
--@param uCharId����ɫId
--@param ItemData����ȡ����Ʒ
--@param logType����Ʒ��Դ
function CLogMgrDB.TakerItemFromMailLog( uCharId,ItemData,logType)
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_player_taker",uEventId , uCharId )
	WriteLog("tbl_log_event_type",uEventId , logType)
	CLogMgrDB.SaveItemInfoToLog(uEventId, ItemData,"tbl_log_item_taker")
end
-------------------------------����������ء�----------------------------------
--@brief ���۽�����������Ʒ�б�
--@param uCharId����ɫId
--@param ItemData�����۵���ƷId table
--@param MoneyType����Ǯ����
--@param order_id������Id
--@param itemcount����Ʒ����
--@param price����Ʒ����
function CLogMgrDB.LogConsignmentBuyItem( uCharId,ItemData,order_id)
	local uEventId = CLogMgrDB._InsertEvent()
	--WriteLog("tbl_log_npc_giver",uEventId , "���۽�����������Ʒ�б���")
	WriteLog("tbl_log_player_taker",uEventId , uCharId )
	WriteLog("tbl_log_event_type",uEventId , event_type_tbl["���۽���������"])
	WriteLog("tbl_log_market_item",uEventId ,order_id)
	CLogMgrDB.SaveItemInfoToLog(uEventId, ItemData,"tbl_log_item_taker")
	return uEventId
end
------------------------------------------------------------------
--@brief ��ӳ��۶���
--@param uCharId����ɫId
--@param ItemData�����۵���ƷId table
--@param order_id������Id
--@param itemcount����Ʒ����
--@param price����Ʒ����
--@param needFee��������
function CLogMgrDB.LogConsignmentAddSellOrder( uCharId,ItemData,order_id,itemcount,price,uLevel )
	local uEventId = CLogMgrDB._InsertEvent()
	--WriteLog("tbl_log_npc_taker",uEventId , "���۽�����������Ʒ����")
	WriteLog("tbl_log_player_giver",uEventId , uCharId)
	WriteLog("tbl_log_event_type",uEventId , event_type_tbl["��ӳ��۶���"])
	WriteLog("tbl_log_market",uEventId ,order_id,itemcount,price)
	WriteLog("tbl_log_level",uEventId , uLevel)
	CLogMgrDB.SaveItemInfoToLog(uEventId, ItemData,"tbl_log_item_giver")
end
------------------------------------------------------------------
--@brief ȡ�����۶���
--@param uCharId����ɫId
--@param ItemData�����۵���ƷId table
--@param order_id������Id
--@param itemcount����Ʒ����
--@param price����Ʒ����
function CLogMgrDB.LogConsignmentCancelSellOrder( uCharId,ItemData,order_id,delOrderType)
	local uEventId = CLogMgrDB._InsertEvent()
	--WriteLog("tbl_log_npc_giver",uEventId , "���۽�����������Ʒ����")
	WriteLog("tbl_log_player_taker",uEventId , uCharId)
	WriteLog("tbl_log_event_type",uEventId , delOrderType)
	WriteLog("tbl_log_market_item",uEventId ,order_id)
	CLogMgrDB.SaveItemInfoToLog(uEventId, ItemData,"tbl_log_item_taker")
end
------------------------------------------------------------------
--@brief ����󹺶���
--@param uCharId����ɫId
--@param order_id������Id
--@param sItemName���󹺵���Ʒ����
--@param itemcount����Ʒ����
--@param price����Ʒ����
function CLogMgrDB.LogConsignmentAddBuyOrder( uCharId,order_id,sItemName,itemcount,price)
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_player_giver",uEventId , uCharId)
	WriteLog("tbl_log_event_type",uEventId , event_type_tbl["����󹺶���"])
	WriteLog("tbl_log_market_buy_order_static",uEventId ,order_id,sItemName,itemcount,price)
	local levelRet = StmtContainer._GetCharLevel:ExecStat(uCharId)
	WriteLog("tbl_log_level",uEventId , levelRet(1,1))
	return uEventId
end
------------------------------------------------------------------
--@brief ɾ���󹺶���
--@param uCharId����ɫId
--@param order_id������Id
--@param delOrderType:ɾ����ʽ(��ʱϵͳɾ���������ֶ�ȡ���������󹺶����ɹ�)
--@param ItemData:�󹺵�����Ʒ
function CLogMgrDB.LogConsignmentCancelBuyOrder( uCharId,order_id,delOrderType,ItemData)
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_player_taker",uEventId , uCharId)
	WriteLog("tbl_log_event_type",uEventId , delOrderType)
	WriteLog("tbl_log_market_item",uEventId ,order_id)
	CLogMgrDB.SaveItemInfoToLog(uEventId, ItemData,"tbl_log_item_taker")
	return uEventId
end
-----------------------------------------------------------------
--@brief �����չ�������Ʒ
--@param uCharId����ɫId
--@param ItemData�����۵���ƷId table
--@param order_id������Id
function CLogMgrDB.LogConsignmentSellBuyOrderItem( uCharId,ItemData,order_id)
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_player_giver",uEventId , uCharId )
	WriteLog("tbl_log_event_type",uEventId , event_type_tbl["�����չ�����"])
	WriteLog("tbl_log_market_item",uEventId ,order_id)
	CLogMgrDB.SaveItemInfoToLog(uEventId, ItemData,"tbl_log_item_giver")
	return uEventId
end
--------------------------------��������ء�---------------------------------
--@brief ������������
--@param uCharId����ɫId
--@param order_id������Id
function CLogMgrDB.LogMakeContractManuOrder( uCharId,ItemData,order_id)
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_player",uEventId , uCharId )
	WriteLog("tbl_log_event_type",uEventId , event_type_tbl["������������"])
	WriteLog("tbl_log_contract_manufacture_order",uEventId ,order_id)
	CLogMgrDB.SaveItemInfoToLog(uEventId, ItemData,"tbl_log_item")
	return uEventId
end
------------------------------------------------------------------
--@brief ��Ӵ�������
--@param uCharId����ɫId
--@param order_id������Id
function CLogMgrDB.LogAddContractManuOrder( uCharId,ItemData,order_id,sSkillName,sDirection,sPrescripName,uCMMoney)
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_player_giver",uEventId , uCharId)
	WriteLog("tbl_log_event_type",uEventId , event_type_tbl["��Ӵ�������"])
	WriteLog("tbl_log_contract_manufacture_order_static",uEventId ,order_id,sSkillName,sDirection,sPrescripName,uCMMoney)
	CLogMgrDB.SaveItemInfoToLog(uEventId, ItemData,"tbl_log_item_giver")
	return uEventId
end
------------------------------------------------------------------
--@brief ȡ����������
--@param uCharId����ɫId
--@param ItemData�����۵���ƷId table
--@param order_id������Id
--@param delOrderType��ȡ��������
function CLogMgrDB.LogCancelContractManuOrder( uCharId,ItemData,order_id,delOrderType)
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_player_taker",uEventId , uCharId)
	WriteLog("tbl_log_event_type",uEventId , delOrderType)
	WriteLog("tbl_log_contract_manufacture_order",uEventId ,order_id)
	CLogMgrDB.SaveItemInfoToLog(uEventId, ItemData,"tbl_log_item_taker")
end
------------------------------------[[�빦��NPC�����¼�]]-------------------------------------
--@brief ��Ҵ��̵�Npc����ȡ��Ʒ
--@param uCharId����ɫId
--@param npcName����Ӧ����npc����
--@param Money���漰����Ǯ
function CLogMgrDB.LogPlayerTakerFromNpc(uCharId, npcName,ItemData,event_type )
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_npc_giver",uEventId , npcName)
	WriteLog("tbl_log_player_taker", uEventId , uCharId)
	WriteLog("tbl_log_event_type",  uEventId , event_type)
	CLogMgrDB.SaveItemInfoToLog(uEventId, ItemData,"tbl_log_item_taker")
	return uEventId
end
--------------------------------------------------------------------------
--@brief ������̵�Npc��������Ʒ
--@param uCharId����ɫId
--@param npcName����Ӧ����npc����
--@param ItemData���漰������ƷId Table
--@param Money���漰����Ǯ
function CLogMgrDB.LogPlayerGiverToNpc(uCharId, npcName, ItemData, event_type)
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_npc_taker",  uEventId , npcName)
	WriteLog("tbl_log_player_giver",  uEventId , uCharId)
	WriteLog("tbl_log_event_type",  uEventId , event_type)
	CLogMgrDB.SaveItemInfoToLog(uEventId, ItemData,"tbl_log_item_giver")
	return uEventId
end
----------------------------------------------[[��ҽ����¼�]]---------------------------------------
--@brief ��ҽ����¼�
--@param TakerCharId: ���׵Ľ��շ�
--@param GiverCharId�����׵ĸ��跽
--@param ItemData�������׵���ƷId table
--@param Money�������õ���Ǯ
function CLogMgrDB.LogPlayerTrade(invitorId,inviteeId, oItemData_R2S, oR2S_Money,eItemData_S2R, eS2R_Money)
	local uEventId = CLogMgrDB._InsertEvent()
	if #eItemData_S2R == 0 and oR2S_Money ~= 0 then
		WriteLog("tbl_log_player_trade",uEventId , invitorId,inviteeId,1, oR2S_Money,0)
	else
		local item_list_len = #eItemData_S2R
		for i = 1, item_list_len do
			WriteLog("tbl_log_player_trade",uEventId , invitorId,inviteeId,1, oR2S_Money,eItemData_S2R[i])
		end	
	end
	
	if #oItemData_R2S == 0 and eS2R_Money ~= 0 then
		WriteLog("tbl_log_player_trade",uEventId ,inviteeId,invitorId,1, eS2R_Money,0)
	else
		local item_list_len = #oItemData_R2S
		for i = 1, item_list_len do
			WriteLog("tbl_log_player_trade",uEventId ,inviteeId,invitorId,1, eS2R_Money,oItemData_R2S[i])
		end	
	end
end
-------------------------------[[װ�����]]----------------------------
--@brief װ���;���Ϣ
--@param charId:��ɫId
--@param equipId:װ��Id
--@param uMaxDuraValue:�;�����ֵ
--@param uCurDuraValue:��ǰ�;�ֵ
function CLogMgrDB.SaveEquipDuraInfo( charId, equipId,uMaxDuraValue,uCurDuraValue )
	local uEventId = CLogMgrDB._InsertEvent()
	--����װ���;���Ϣ
	WriteLog("tbl_log_item_equip_durability",  uEventId, equipId,uMaxDuraValue or 0,uCurDuraValue or 0)
	--�����ɫId
	WriteLog("tbl_log_player",  uEventId , charId)
end
---------------------------------------------------------------------
--@brief װ����ǿ����Ϣ
--@param charId:��ɫId
--@param res:װ��ǿ����Ϣ
--#װ��ǿ��	ʱ��+��ɫID+װ��ID+ǿ����װ����Ϣ+����ID
function CLogMgrDB.SaveEquipIntensifyInfo( charId, res,eventId)
	local uEventId = eventId
	if not uEventId then
		uEventId = CLogMgrDB._InsertEvent()
		--�����ɫId
		WriteLog("tbl_log_player",  uEventId , charId)
	end
	if not IsNumber(res) then
		WriteLog("tbl_log_item_equip_intensify",  uEventId, res(1,1),res(1,2) or 0 ,res(1,3) or "",res(1,4) or 0 ,res(1,5) or "",res(1,6) or 0,res(1,7) or "",res(1,8) or 0,res(1,9) or "",res(1,10) or 0,res(1,11) or 0,res(1,12) or 0,res(1,13) or "",res(1,14) or 0,res(1,15) or 0,res(1,16) or 0,res(1,17) or 0)
	else
		WriteLog("tbl_log_item_equip_intensify",  uEventId, res)
	end
end
---------------------------------------------------------------------
--@brief װ����ǿ��4-9�׶�������Ϣ
--@param charId:��ɫId
--@param res:װ��ǿ����Ϣ
--#װ��ǿ��	ʱ��+��ɫID+װ��ID+ǿ����װ����Ϣ+����ID
function CLogMgrDB.SaveEquipIntensifyInfoAddAttr( charId, res,eventId)
	local uEventId = eventId
	if not uEventId then
		uEventId = CLogMgrDB._InsertEvent()
		--�����ɫId
		WriteLog("tbl_log_player",  uEventId , charId)
	end
	if not IsNumber(res) then
		WriteLog("tbl_log_item_equip_intensifyAddAttr",  uEventId, res(1,1),res(1,2) or "",res(1,3) or 0,res(1,4) or "",res(1,5) or 0,res(1,6) or "",res(1,7) or 0,res(1,8) or "",res(1,9) or 0,res(1,10) or "",res(1,11) or 0,res(1,12) or "",res(1,13) or 0)
	else
		WriteLog("tbl_log_item_equip_intensifyAddAttr",  uEventId, res)
	end
end
---------------------------------------------------------------------
--@brief װ����������Ϣ
--@param charId:��ɫId
--@param equipId:װ��Id
--@param sceneName:��������
--#װ������	ʱ��+��ɫID+װ��ID+������װ����Ϣ+����ID
function CLogMgrDB.SaveEquipUpgradeInfo( charId, equipId,sceneName,uAfterLevel )
	local uEventId = CLogMgrDB._InsertEvent()
	--����װ��Id
	WriteLog("tbl_log_item",  uEventId , equipId)
	--����װ��������Ϣ
	WriteLog("tbl_log_equip_upgrade",   uEventId, uAfterLevel)
	--�����ɫId
	WriteLog("tbl_log_player",   uEventId , charId)
end
---------------------------------------------------------------------
--@brief װ����ϴ����Ϣ
--@param charId:��ɫId
--#װ��ϴ��	ʱ��+��ɫID+װ��ID+ϴ�׺�װ����Ϣ+����ID
function CLogMgrDB.SaveEquipIntensifyBackInfo( charId )
	local uEventId = CLogMgrDB._InsertEvent()
	--����װ��ϴ����Ϣ
	WriteLog("tbl_log_equip_intensifyback",   uEventId)
	--�����ɫId
	WriteLog("tbl_log_player",    uEventId , charId)
	WriteLog("tbl_log_event_type", uEventId ,event_type_tbl["װ��ϴ��"] )	
	return uEventId
end
---------------------------------------------------------------------
--@brief ��װ��
--@param charId:��ɫId
--@param equipId:װ��Id
--@param sceneName:��������
function CLogMgrDB.SaveEquipPutOnInfo( charId, equipId,equipPart )
	local uEventId = CLogMgrDB._InsertEvent()
	--����װ��Id
	WriteLog("tbl_log_item",    uEventId , equipId)
	--���洩װ����Ϣ
	WriteLog("tbl_log_equip_puton",    uEventId,equipPart)
	--�����ɫId
	WriteLog("tbl_log_player",    uEventId, charId)
	return uEventId
end
---------------------------------------------------------------------
--@brief ժ��װ��
--@param charId:��ɫId
--@param equipId:װ��Id
--@param sceneName:��������
function CLogMgrDB.SaveEquipPutOffInfo( charId, equipId,sceneName)
	local uEventId = CLogMgrDB._InsertEvent()
	--����װ��Id
	WriteLog("tbl_log_item",    uEventId , equipId)
	--����ժ��װ����Ϣ
	WriteLog("tbl_log_equip_putoff",    uEventId)
	--�����ɫId
	WriteLog("tbl_log_player",   uEventId, charId)
	return uEventId
end
---------------------------------------------------------------------
--@brief װ������
--@param charId:��ɫId
--@param equipId:װ��Id
--@param newAdvanceInfoTbl:���µ�װ��������Ϣ
function CLogMgrDB.SaveEquipAdvanceInfo( charId,equipId,newAdvanceInfoRet)
	local uEventId = CLogMgrDB._InsertEvent()
	--����װ��������Ϣ
	WriteLog("tbl_log_item_equip_advance",   uEventId,equipId, 
	                            newAdvanceInfoRet(1,1),newAdvanceInfoRet(1,2) or 0,newAdvanceInfoRet(1,3) or 0,
                                newAdvanceInfoRet(1,4) or 0,newAdvanceInfoRet(1,5) or 0,newAdvanceInfoRet(1,6) or 0,
                                newAdvanceInfoRet(1,7)  or 0,newAdvanceInfoRet(1,8) or "",newAdvanceInfoRet(1,9) or 0,
                                newAdvanceInfoRet(1,10) or 0,newAdvanceInfoRet(1,11) or 0,newAdvanceInfoRet(1,12) or 0,
                                newAdvanceInfoRet(1,13) or 0,newAdvanceInfoRet(1,14) or 0,newAdvanceInfoRet(1,15) or "",
                                newAdvanceInfoRet(1,16) or "",newAdvanceInfoRet(1,17) or "",newAdvanceInfoRet(1,18) or "",
                                newAdvanceInfoRet(1,19) or "")
	--�����ɫId
	WriteLog("tbl_log_player",   uEventId, charId)
end
---------------------------------------------------------------------
--@brief װ�����ܼ���
--@param charId:��ɫId
--@param equipId:װ��Id
--@param sceneName:��������
function CLogMgrDB.SaveEquipAdvancedActiveSkill( charId,index)
	local uEventId = CLogMgrDB._InsertEvent()
	--����װ�����ܼ�����Ϣ
	WriteLog("tbl_log_equip_advancedActiveSkill", uEventId,charId,index or 0)
end
---------------------------------------------------------------------
--@brief ��¼������Ϣ
--@param charId:��ɫId
--@param equipId:װ��Id
function CLogMgrDB.SaveEquipArmorInfo( charId,equipId,uBaseLevel,uCurLevel,uUpgradeAtrrValue1,uUpgradeAtrrValue2,uUpgradeAtrrValue3,uStaticProValue,uIntensifyQuality,sIntenSoul)
	local uEventId = CLogMgrDB._InsertEvent()
	--���������Ϣ
	WriteLog("tbl_log_item_armor", uEventId,equipId,uBaseLevel,uCurLevel,uUpgradeAtrrValue1,uUpgradeAtrrValue2,uUpgradeAtrrValue3,uStaticProValue,uIntensifyQuality,sIntenSoul)
	WriteLog("tbl_log_player",   uEventId, charId)
end
---------------------------------------------------------------------
--@brief ��¼������Ϣ
--@param charId:��ɫId
--@param equipId:װ��Id
function CLogMgrDB.SaveEquipWeaponInfo( charId,equipId,uBaseLevel,uCurLevel,uDPS,uAttackSpeed,uDPSFloorRate,uIntensifyQuality,sIntenSoul)
	local uEventId = CLogMgrDB._InsertEvent()
	--����������Ϣ
	WriteLog("tbl_log_item_weapon", uEventId,equipId,uBaseLevel,uCurLevel,uDPS,uAttackSpeed,uDPSFloorRate,uIntensifyQuality,sIntenSoul)
	WriteLog("tbl_log_player",   uEventId, charId)
end
---------------------------------------------------------------------
--@brief ��¼��ָ��Ϣ
--@param charId:��ɫId
--@param equipId:װ��Id
function CLogMgrDB.SaveEquipRingInfo( charId,equipId,uBaseLevel,uCurLevel,uDPS,uStaticProValue,uIntensifyQuality,sIntenSoul)
	local uEventId = CLogMgrDB._InsertEvent()
	--�����ָ��Ϣ
	WriteLog("tbl_log_item_ring", uEventId,equipId,uBaseLevel,uCurLevel,uDPS,uStaticProValue,uIntensifyQuality,sIntenSoul)
	WriteLog("tbl_log_player",   uEventId, charId)
end
---------------------------------------------------------------------
--@brief ��¼���ƻ��߷���������Ϣ
--@param charId:��ɫId
--@param equipId:װ��Id
function CLogMgrDB.SaveEquipShieldInfo( charId,equipId,uBaseLevel,uCurLevel,uIntensifyQuality,sIntenSoul)
	local uEventId = CLogMgrDB._InsertEvent()
	--���������Ϣ
	WriteLog("tbl_log_item_shield", uEventId,equipId,uBaseLevel,uCurLevel,uIntensifyQuality,sIntenSoul)
	WriteLog("tbl_log_player",   uEventId, charId)
end
---------------------------------------------------------------------
--@brief ��¼������Ϣ
--@param charId:��ɫId
--@param equipId:װ��Id
function CLogMgrDB.SaveShieldInfo( charId,equipId,uAttrValue1,uAttrValue2,uAttrValue3,uAttrValue4)
	local uEventId = CLogMgrDB._InsertEvent()
	--���������Ϣ
	WriteLog("tbl_log_item_shield_Attr", uEventId,equipId,uAttrValue1 or 0,uAttrValue2 or 0,uAttrValue3 or 0,uAttrValue4 or 0)
	WriteLog("tbl_log_player",   uEventId, charId)
end
---------------------------------------------------------------------
--@brief ��¼װ��������Ϣ
--@param charId:��ɫId
--@param equipId:װ��Id
function CLogMgrDB.SaveArmorIncrustationInfo( charId,equipId,sAttr,uAddTimes,uIndex)
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_item_equip_armor", uEventId,equipId,sAttr,uAddTimes,uIndex)
	WriteLog("tbl_log_player",   uEventId, charId)
end
---------------------------------------------------------------------
--@brief ��¼װ��׷����Ϣ
--@param charId:��ɫId
--@param equipId:װ��Id
function CLogMgrDB.SaveEquipSuperAddationInfo( charId,equipId,uCurSuperaddPhase)
	local uEventId = CLogMgrDB._InsertEvent()
	
	WriteLog("tbl_log_item_equip_superaddation", uEventId,equipId,uCurSuperaddPhase)
	WriteLog("tbl_log_player",   uEventId, charId)
end
---------------------------------------------------------------------
--@brief ��¼װ����������Ϣ
--@param uMakerId:������Id
--@param equipId:װ��Id
function CLogMgrDB.SaveEquipMakerInfo(equipId,uMakerId)
	local uEventId = CLogMgrDB._InsertEvent()
	
	WriteLog("tbl_log_item_maker", uEventId,equipId,uMakerId)
end
-------------------------------------------[[�����¼����]]--------------------------------
--@brief �����ɫս����Ϣ
--@param AttackerId:��ɱ�߽�ɫId
--@param BeAttackerId:����ɱ��Id
--@param sceneName:��������
function CLogMgrDB.SavePlayerFightInfo( AttackerId, BeAttackerId,SceneName,attackerLevel,beAttackerLevel)
	local uEventId = CLogMgrDB._InsertEvent()
	--�����ɱ��
	WriteLog("tbl_log_player_kill",  uEventId, AttackerId, attackerLevel)
	--���汻��ɱ��
	WriteLog("tbl_log_player_dead", uEventId , BeAttackerId,beAttackerLevel)
	--�����ɫ�������ڳ���
	WriteLog("tbl_log_scene", uEventId , SceneName)
end
---------------------------------------------------------------------
local StmtDef = {
    	"_GetTheSameSceneRole",
    	[[ 
    		select cfp.cs_uId,ifnull(t_uId,0) from tbl_char_fb_position cfp left join tbl_member_tong mt on  cfp.cs_uId = mt.cs_uId
    		where sc_uId = (select sc_uId from tbl_char_fb_position where cs_uId = ?)
    	]]
}    
DefineSql ( StmtDef, StmtContainer )


--@brief �������������Ϣ
--@param AttackerId:��ɱ�߽�ɫId
--@param NpcName:Npc����
--@param sceneName:��������
function CLogMgrDB.SaveNpcDeadInfo( AttackerId, NpcName,uCharLevel)
	local uEventId = CLogMgrDB._InsertEvent()
	--�����ɱ��
	WriteLog("tbl_log_player_kill", uEventId, AttackerId,uCharLevel)
	--����Npc��Ϣ
	WriteLog("tbl_log_npc_name", uEventId , NpcName)
	local theSameSceneRole = StmtContainer._GetTheSameSceneRole:ExecStat(AttackerId)
	for i = 1,theSameSceneRole:GetRowNum() do
		WriteLog("tbl_log_join_activity", uEventId, theSameSceneRole(i,1) ,theSameSceneRole(i,2))
	end
end
---------------------------------------------------------------------
--@brief �����ɫ������ɱ���¼���Ϣ
--@param NpcName:npc����
--@param uCharId:������ɫId
--@param SceneName:��������
function CLogMgrDB.SavePlayerKilledByNpc(NpcName, uCharId, SceneName,uCharLevel)
	local uEventId = CLogMgrDB._InsertEvent()
	--����NPC
	WriteLog("tbl_log_npc_name", uEventId, NpcName)
	--���汻��ɱ��
	WriteLog("tbl_log_player_dead", uEventId , uCharId,uCharLevel)
	--�����ɫ�������ڳ���
	WriteLog("tbl_log_scene", uEventId , SceneName)
end
---------------------------------------��ս����Ϣ��ء�---------------------------------------
local StmtDef=
{
	"_GetCharLevel",
	[[
		select cb_uLevel from tbl_char_basic where cs_uId = ? 
	]]
}
DefineSql(StmtDef,StmtContainer)

local StmtDef=
{
	"_GetCharSeries",
	[[
		select ss_uSeries from tbl_skill_Series where cs_uId = ? 
	]]
}
DefineSql(StmtDef,StmtContainer)
	
local StmtDef=
{
	"_GetCharFightPoint",
	[[
		select cfe_uPoint from tbl_char_fighting_evaluation where cs_uId = ? 
	]]
}
DefineSql(StmtDef,StmtContainer)

--@brief �������id���дlog��Ҫ�ĵȼ����츳ϵ��ս��������
function CLogMgrDB.GetCharSaveLogInfo(charId)
	local levelRet = StmtContainer._GetCharLevel:ExecStat(charId)
	local charSeries = StmtContainer._GetCharSeries:ExecStat(charId)
	local fightPoint = StmtContainer._GetCharFightPoint:ExecStat(charId)
	local uSeries = 0
	if charSeries:GetRowNum() > 0 then
		uSeries = charSeries(1,1)
	end
	return {levelRet(1,1),uSeries,fightPoint(1,1)}
end
---------------------------------------------------------------------
--@brief ��¼��ɫpk�¼�
--@param uFlagId:����id
--@param uResponsesId:������id
--@param uChallengeId:��ս��id
--@param uCostTime��ս��ʱ��
--@param uIsSucc��PK�Ƿ�ɹ� 0-ʧ�ܣ�1-�ɹ�
function CLogMgrDB.SaveCharPKInfoLog(uFlagId,uResponsesId,uChallengeId,uCostTime,uIsSucc,fightInfoTbl1,fightInfoTbl2)
	local uEventId = CLogMgrDB._InsertEvent()
	
	WriteLog("tbl_log_char_pk",uEventId, uFlagId,uResponsesId,uChallengeId,uCostTime,uIsSucc)
	WriteLog("tbl_log_char_fight_info",uEventId, unpack(fightInfoTbl1))
	WriteLog("tbl_log_char_fight_info",uEventId, unpack(fightInfoTbl2))
end
---------------------------------------------------------------------
--@brief ��¼3V3����\�Ƕ���\��Ѫ������\���鱾\���³ǵȶ��������Ϣ
--@param uSuccTeamId���ɹ�����id
--@param uFailTeamId:ʧ�ܶ���id
--@param uCostTime:��������ܺ�ʱ
--@param uActivityType:����� 1-3V3����\2-�Ƕ���\3-��Ѫ������\4-���鱾\5-���³�....
function CLogMgrDB.SaveTeamActivityLogInfo(uSuccTeamId,uFailTeamId,uCostTime,uActivityType)
	local uEventId = CLogMgrDB._InsertEvent()
	
	WriteLog("tbl_log_team_activity",uEventId,uSuccTeamId,uFailTeamId,uCostTime,uActivityType)
end
-----------------------------------------[[�츳���]]---------------------------------
--@brief �����츳ѧϰ��Ϣ
--@param charId:���id
--@param talentName:�츳����
--@param uType:1-ѧ�츳��2ϴ�츳
function CLogMgrDB.SavePlayerTelentInfo( charId,talentName,uType )
	local uEventId = CLogMgrDB._InsertEvent()
	--�����츳ѧϰ��ɫId
	WriteLog("tbl_log_player", uEventId, charId )
	--����Npc��Ϣ
	WriteLog("tbl_log_talent", uEventId , talentName,uType)
end
-----------------------------------------[[�������]]---------------------------------
--@brief ����ѧϰ��������Ϣ
--@param uType:0����ѧϰ��1�������� 
--@IsNonSkill:0 ������ս������ ��1 �����ս������
function CLogMgrDB.SavePlayerSkillInfo( charId,skillName,skillLevel,uType,uIsNonSkill)
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_player_giver", uEventId, charId )
	WriteLog("tbl_log_skill",uEventId , skillName,skillLevel,uType,uIsNonSkill )
	return uEventId
end
------------------------------------------[�����]----------------------------------------
--@brief �������Ϣ��¼
--@param charId:���Id
--@param skillName:��������
--@param uSkillLevel:���ܵȼ�
--@param uExperience:���ܾ���
--@param uUpdateType:��������
function CLogMgrDB.SaveLiveskillInfo(charId,skillName,uSkillLevel,uExperience,uUpdateType)
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_event_type", uEventId ,uUpdateType )
	WriteLog("tbl_log_commerce_skill", uEventId, charId,skillName,uSkillLevel,uExperience)
	return uEventId
end
----------------------------------------------------------------------------------
--@brief ������������Ϣ��¼
--@param charId:���Id
--@param skillType:��������
--@param uType:��������������
--@param uSpecialize:�����ȴ�С
--@param uUpdateType:��������
function CLogMgrDB.SaveLiveskillPractice(charId,skillType,uType,uSpecialize,uUpdateType,uEventId)
	local uEventId = uEventId or CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_event_type", uEventId ,uUpdateType )
	WriteLog("tbl_log_specialize_smithing", uEventId, charId,skillType,uType,uSpecialize)
	return uEventId
end
----------------------------------------------------------------------------------
--@brief ����ר����Ϣ��¼
--@param charId:���Id
--@param skillType:��������
--@param uType:����ר������
--@param uLevel:ר���ȼ�
--@param uUpdateType:��������
function CLogMgrDB.SaveLiveskillExpert(charId,nSkillType,sExpertType,uLevel,uUpdateType)
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_event_type", uEventId ,uUpdateType )
	WriteLog("tbl_log_expert_smithing",uEventId, charId,nSkillType,sExpertType,uLevel)
	return uEventId
end
--------------------------------------[[����]]------------------------------------
--@brief ����
--@param ��ؽ�ɫ
--@param ���ʽ��1,����ʯ����; 2,���ָ���; 3,�ظ���㸴��;4,����۲�ģʽ; 5,�ڸ����Ľ���㸴��; 6,��������;
function CLogMgrDB.LogReBorn(data)
	local charId = data["PlayerId"]
	local uRebornMethod = data["RebornMethod"]
	local sceneName = data["sceneName"]
	local res = data["res"]
	
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_player", uEventId, charId)
	WriteLog("tbl_log_reborn_info", uEventId , uRebornMethod )
end
--------------------------------------[[�ϳ�]]----------------------------------------
--@brief �ϳ�
--@brief ��ؽ�ɫ
--@param ����Ʒ����
function CLogMgrDB.LogCompose(charId)
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_player", uEventId, charId)
	WriteLog("tbl_log_compose_info", uEventId )
	WriteLog("tbl_log_event_type",uEventId , event_type_tbl["�ϳ�"])
	return uEventId
end
-----------------------------------[[�������]]-------------------------------------
local SceneTypeTbl = {
			[5] = true,
			[8] = true,
			[10] = true,
			[13] = true,
			[14] = true,
			[15] = true,
			[16] = true,
			[18] = true,
			[19] = true,
			[20] = true,
			[21] = true,
			[22] = true,
			[23] = true,
			[24] = true,
			[26] = true,
			[27] = true,
			}
			
function CLogMgrDB.EnterScene(data)
	local charId = data["PlayerId"]
	local SceneName = data["SceneName"]
	local curlevel = data["curlevel"]
	local SceneType = data["SceneType"]
	local SceneID = data["SceneID"]
	local uEventId = CLogMgrDB._InsertEvent()

	if SceneTypeTbl[SceneType] then
		local ActionName = SceneName
		if SceneType == 13 then
			ActionName = data["MatchGameName"]
		end
		CLogMgrDB.EnterActivity(uEventId,SceneID, ActionName)  --��ҲμӸ����
	end
	WriteLog("tbl_log_enter_scene",uEventId)
	WriteLog("tbl_log_level",uEventId , curlevel)
	WriteLog("tbl_log_scene",uEventId , SceneName)
	WriteLog("tbl_log_player",uEventId, charId)
end

--�˳������¼�
function CLogMgrDB.LeaveScene(data)
	local PlayerId = data["PlayerId"]
	local SceneName = data["SceneName"]
	local SceneType = data["SceneType"]
	local uEventId = CLogMgrDB._InsertEvent()
	if SceneTypeTbl[SceneType] then
		local sActivityName = SceneName
		if SceneType == 13 then
			sActivityName = data["MatchGameName"]
		end
		CLogMgrDB.LeaveActivity(uEventId,data["SceneID"], sActivityName)
	end
	WriteLog("tbl_log_leave_scene",uEventId)
	WriteLog("tbl_log_scene",uEventId , SceneName)
	WriteLog("tbl_log_player",uEventId, PlayerId)
end

function CLogMgrDB.CreateScene(SceneId, SceneName)
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_create_scene", uEventId, SceneId)
	WriteLog("tbl_log_scene", uEventId, SceneName)
end

-----------------------------------[[matchgame���]]-----------------------------------
function CLogMgrDB.SaveMatchGameServerLog(data)
	local RoomId = data["RoomId"]
	local ActionName = data["ActionName"]
	local SceneId = data["SceneId"]
	local LogStr = data["LogStr"]
	local lenth = string.len(LogStr)
	
	if lenth <= 1024 then
		WriteLog("tbl_log_matchgame_server", RoomId, ActionName, SceneId, 1, os.date("%y-%m-%d %H:%M:%S"), LogStr)
	else	--��Ϣ��������ֳɶ�������
		local index = 1
		for i=1, lenth, 1024 do
			local str = string.sub(LogStr, i, i+1023)
			WriteLog("tbl_log_matchgame_server", RoomId, ActionName, SceneId, index, os.date("%y-%m-%d %H:%M:%S"), str)
			index = index + 1
		end
	end
end

function CLogMgrDB.SaveMatchGameRoomLog(ActionName, RoomId, SceneId, ServerId)
	WriteLog("tbl_log_matchgame_room", RoomId, ActionName, SceneId, ServerId, os.date("%y-%m-%d %H:%M:%S"))
end

function CLogMgrDB.SaveMatchGameMemberLog(CharId, ActionName, TeamId, RoomId, FuncName, State)
	WriteLog("tbl_log_matchgame_member", CharId, ActionName, TeamId, RoomId, FuncName, State, os.date("%y-%m-%d %H:%M:%S"))
end

function CLogMgrDB.SaveXianxieLog(data)
	local uEventId = CLogMgrDB._InsertEvent()
	for id, v in pairs(data) do
		local isWin, score, killNum, deadNum = unpack(v)
		WriteLog("tbl_log_xianxie", uEventId, id, isWin and 1 or 0, score, killNum, deadNum)
	end
end

-----------------------------------[[���������]]-----------------------------------
--@brief ��¼��ҽ���������log
--@param uCharId����ɫid
--@param uLevelNum������������ 
--@param uGateId���ؿ�id
--@param uSceneId������id
--@param uSucceedFlag���ɹ����ı�ʶ  1--�ɹ���2--ʧ�ܣ�3--ʱ�䵽�� 4--������5--���ͳ�ȥ
--@param uSpendTimes:ÿһ�������ѵ�ʱ��
		
function CLogMgrDB.SaveXiuXingTaLogInfo(data)
	local uCharId = data.PlayerID
	local uLevelNum = data.LevelNum
	local uGateId = data.GameID
	local uSceneId = data.SceneID
	local uSucceedFlag = data.uSucceedFlag
	local uSpendTimes = data.uSpendTimes
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_xiuxingta",uEventId,uGateId,uSceneId,uSucceedFlag,uSpendTimes,tostring(uLevelNum))
	WriteLog("tbl_log_player_taker", uEventId , uCharId)
end
--------------------------------[[������]]-----------------------------------------
function CLogMgrDB.EnterTeam(charId, uTeamId,CurLevel)
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_player",uEventId, charId)
	WriteLog("tbl_log_enter_team",uEventId , uTeamId)
	WriteLog("tbl_log_level",uEventId , CurLevel)
end
----------------------------------------------------------------
function CLogMgrDB.LeaveTeam(charId, uTeamId)
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_player",uEventId, charId)
	WriteLog("tbl_log_leave_team",uEventId , uTeamId)
end
-------------------------------����������--------------------------------
function CLogMgrDB.EnterActivity(uEventId, sActivityID, sActivityName)
	WriteLog("tbl_log_enter_activity",uEventId, sActivityID, sActivityName)
end

function CLogMgrDB.LeaveActivity(uEventId,sActivityID, sActivityName)
	WriteLog("tbl_log_leave_activity",uEventId,sActivityID, sActivityName)
end
----------------------------------------[[����ϵ�¼�]]--------------------------------------
--@brief ��Ӻ����¼���¼
--@param uCharId:��ɫId
--@param CurLevel����ɫ�Լ��ĵ�ǰ�ȼ�
--@param friendId������Id
function CLogMgrDB.AddFriend(uCharId,CurLevel,friendId)
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_level",uEventId , CurLevel)
	WriteLog("tbl_log_player",uEventId, uCharId)
	WriteLog("tbl_log_add_friend",uEventId, friendId)
end
---------------------------------------------------------------------------------------------
--@brief ɾ�������¼���¼
--@param uCharId:��ɫId
--@param friendId������Id
function CLogMgrDB.DeleteFriend(uCharId,friendId)
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_player",uEventId, uCharId)
	WriteLog("tbl_log_delete_friend",uEventId, friendId)
end

----------------------------------------[[������Ϣ]]----------------------------------------
local StmtDef=
{
	"_SelectJiFenCode",

	"select sj_sCode from " .. LogDBName .. ".tbl_serial_jifen where lcs_uId = ?"

}
DefineSql(StmtDef,StmtContainer)

local StmtDef=
{
	"_SaveJiFenCode",

	"replace into " .. LogDBName .. ".tbl_serial_jifen set lcs_uId = ?, sj_sCode = md5(?)"

}
DefineSql(StmtDef,StmtContainer)

--@brief ��¼������Ϣ
--@param charId����ɫid
--@param uPoint��������
--@param uType����������
--@param sSceneName����������
function CLogMgrDB.SaveJiFenPointInfo(charId,uPoint,uType,sSceneName,uTotalPoint,eventId,modifyType,uLevel)
	if eventId == nil and modifyType == nil then
		LogErr("�޸Ļ���û�м�¼log����")
	end
	local uEventId = eventId
	if not uEventId then
		uEventId = CLogMgrDB._InsertEvent()
		if uPoint > 0 then
			WriteLog("tbl_log_player_taker",uEventId, charId )
		else
			WriteLog("tbl_log_player_giver",uEventId, charId )
		end
		WriteLog("tbl_log_event_type",uEventId , modifyType)
	end
	WriteLog("tbl_log_level",uEventId , uLevel)
	local code_res = StmtContainer._SelectJiFenCode:ExecStat(charId)
	local code
	if code_res:GetRowNum() > 0 then
		code = code_res:GetData(0,0)
	else
		code = "tbl_log_jifenpoint"		
	end
	WriteLog("tbl_log_jifenpoint",uEventId ,charId, uPoint,uType,uTotalPoint,code)
	LogStmtCall(StmtContainer._SaveJiFenCode, charId,code)
	return g_DbChannelMgr:LastAffectedRowNum() > 0
end
------------------------------------------------------------------------------------
--@brief ��¼����ɱ������Ϣ
--@param charId����ɫid
--@param uPoint��������
function CLogMgrDB.SaveDaTaoShaPointInfo(charId,uPoint)
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_player_taker",uEventId, charId )
	WriteLog("tbl_log_event_type",uEventId ,event_type_tbl["����ɱ�ӻ���"])
	WriteLog("tbl_log_dataosha_point",uEventId, uPoint)
	return uEventId
end
-----------------------------------------------------------------------------------------------
local StmtDef = 
{
	"_GetALLServerOnlineUserInfo",
	[[
		select 
			tbl_server.s_uId, count(uo.us_uId) as userNum
		from 
			tbl_server left join tbl_user_online as uo on(tbl_server.s_uId = uo.uo_uOnServerId)
			group by tbl_server.s_uId 
	]]
}
DefineSql(StmtDef, StmtContainer)

local StmtDef = 
{
	"_GetALLSceneOnlineUserInfo",
	[[
		select 
			s.sc_uServerId,count(*) ,s.sc_sSceneName,s.sc_uType
		from 
			tbl_char_fb_position cfp,tbl_scene s,tbl_char_online co
		where 
			cfp.sc_uId = s.sc_uId  and cfp.cs_uId = co.cs_uId 
			group by cfp.sc_uId,s.sc_uServerId
		union
		select 
			s.sc_uServerId,count(*),s.sc_sSceneName,s.sc_uType
		from 
			tbl_char_position cp,tbl_scene s,tbl_char_online co
		where 
			cp.cs_uId not in (select cs_uId from tbl_char_fb_position) 
			and cp.sc_uId = s.sc_uId  and cp.cs_uId = co.cs_uId
			group by cp.sc_uId,s.sc_uServerId
	]]
}
DefineSql(StmtDef, StmtContainer)

--@brief ÿ������Ӽ�¼�����������������
function CLogMgrDB.SaveServiceOnlineUserInfo()
	local uEventId = CLogMgrDB._InsertEvent()
	local res1 = StmtContainer._GetALLServerOnlineUserInfo:ExecStat()
	if res1:GetRowNum() > 0 then
		for i = 1,res1:GetRowNum() do
			WriteLog("tbl_log_service_online_num",uEventId,res1:GetData(i-1,0),res1:GetData(i-1,1) )
		end
	end
	local res2 = StmtContainer._GetALLSceneOnlineUserInfo:ExecStat()
		if res2:GetRowNum() > 0 then
		for i = 1,res2:GetRowNum() do
			WriteLog("tbl_log_service_scene_online_num",uEventId,res2:GetData(i-1,0),res2:GetData(i-1,1),res2:GetData(i-1,2),res2:GetData(i-1,3))
		end
	end
end
------------------------------------------��Ӷ��С����ء�-----------------------------------------
--@brief ��¼Ӷ��С�Ӿ�̬��Ϣ
function CLogMgrDB.SaveTongStaticInfo(tongId,tongName,uCamp,uCharId)
	assert(tongId)
	assert(tongName)
	WriteLog("tbl_log_tong_static",tongId,tongName,os.date("%y-%m-%d %H:%M:%S"),uCamp,uCharId)
end
------------------------------------------------------
--@brief ��¼Ӷ��С��������Ϣ
function CLogMgrDB.SaveTongHonorInfo(tongId,uHonor,event_type)
	assert(event_type,"С�������޸�ûдlog")
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_event_type",  uEventId , event_type)
	if uHonor > 0 then
		WriteLog("tbl_log_tong_taker",uEventId, tongId )
		WriteLog("tbl_log_tong_honor",uEventId, uHonor )
	end
end
------------------------------------------------------
--@brief ��¼Ӷ��С�ӵȼ���Ϣ
function CLogMgrDB.SaveTongLevelInfo(tongId,uLevel, event_type)
	assert(event_type,"С�ӵȼ��޸�ûдlog")
	local uEventId = CLogMgrDB._InsertEvent()
	if uLevel > 0 then
		WriteLog("tbl_log_event_type",  uEventId , event_type)
		WriteLog("tbl_log_tong_taker",uEventId, tongId )
		WriteLog("tbl_log_tong_level",uEventId, uLevel )
	end
end
------------------------------------------------------
--@brief ��¼Ӷ��С���ʽ���Ϣ
function CLogMgrDB.SaveTongMoneyInfo(tongId,uMoney,event_type)
	assert(event_type,"С�ӽ�Ǯ�޸�ûдlog")
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_event_type",  uEventId , event_type)
	if uMoney >= 0 then
		WriteLog("tbl_log_tong_taker",uEventId, tongId )
	else
		WriteLog("tbl_log_tong_giver",uEventId, tongId )
	end
	WriteLog("tbl_log_tong_money",uEventId, uMoney)
end
------------------------------------------------------
--@brief ��¼Ӷ��С����Դ��Ϣ
function CLogMgrDB.SaveTongResourceInfo(tongId,uResource,event_type)
	assert(event_type,"С����Դ�޸�ûдlog")
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_event_type",  uEventId , event_type)
	if uResource >= 0 then
		WriteLog("tbl_log_tong_taker",uEventId, tongId)
	else
		WriteLog("tbl_log_tong_giver",uEventId, tongId)
	end
	WriteLog("tbl_log_tong_resource",uEventId, uResource)
end
------------------------------------------------------
--@brief ��¼Ӷ��С�ӷ�չ����Ϣ
--@param tongId:��չ�ȸı��Ӷ��С��id
--@param uPoint:�ı�ķ�չ��
--@param event_type���ı�����
function CLogMgrDB.SaveTongDevelopDegreeInfo(tongId,uPoint,event_type)
	assert(event_type,"С�ӷ�չ���޸�ûдlog")
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_event_type",  uEventId , event_type)
	if uPoint >= 0 then
		WriteLog("tbl_log_tong_taker",uEventId, tongId)
	else
		WriteLog("tbl_log_tong_giver",uEventId, tongId)
	end
	WriteLog("tbl_log_tong_develop_degree",uEventId, uPoint)
end
------------------------------------------------------
--@brief Ӷ��С�������¼�
--@param tongId:Ӷ��С��id
--@param uEventType:�¼����� 1-����;2-�߳�;3-�˳�;4-����ְλ
--@param uExecutorId:ִ����
--@param uObjectId:��ִ����
--@param uJobType:ְλ
function CLogMgrDB.TongMemberEventLog(tongId,uEventType,uExecutorId,uObjectId,uJobType)
	local uEventId = CLogMgrDB._InsertEvent()

	WriteLog("tbl_log_tong_member_event",  uEventId , tongId,uEventType,uExecutorId,uObjectId,uJobType)
end
------------------------------------------------------
--@brief Ӷ��С�ӿƼ��¼�
--@param tongId:Ӷ��С��id
--@param uEventType:�¼����� 1-��ʼ�з�;2-ֹͣ�з�;3-����з�;4-�Ƽ�����(ѧԺ���򱬻��߲��)��5--�Ƽ�ѧϰ
--@param uExecutorId:ִ����
--@param sName:�Ƽ�����
--@param uLevel:�Ƽ���ǰ�ȼ�
function CLogMgrDB.TongTechnologyEventLog(tongId,uEventType,uExecutorId,sName,uLevel)
	local uEventId = CLogMgrDB._InsertEvent()

	WriteLog("tbl_log_tong_technology_event",  uEventId , tongId,uEventType,uExecutorId,sName,uLevel)
end
------------------------------------------------------
--@brief Ӷ��С�ӽ����¼�
--@param tongId:��������Ӷ��С��id
--@param sName:��������
--@param uLevel:������ǰ�ȼ�
--@param uEventType:�¼����� 1-���ý���;2-����ݻٽ���
--@param uExecutorId:ִ����
--@param uExecutorTongId:ִ����Ӷ��С��id
--@param uBuildingId:����id
--@param uAddParam:���Ӳ���(Ѫ���ٷֱ�/Ŀ��ȼ�/�ݻ�ʱ������Դ)
function CLogMgrDB.TongBuildingEventLog(tongId,sName,uLevel,uEventType,uExecutorId,uExecutorTongId,uBuildingId,uAddParam)
	local uEventId = CLogMgrDB._InsertEvent()

	WriteLog("tbl_log_tong_building_event",  uEventId,tongId,sName,uLevel,uEventType,uExecutorId,uExecutorTongId,uBuildingId,uAddParam)
end
------------------------------------------------------
--@brief Ӷ��С����Ʒ�����¼�
--@param tongId:Ӷ��С��id
--@param sName:��Ʒ����
--@param uEventType:�¼����� 1-��ʼ;2-ȡ�� 3-�������
--@param uExecutorId:ִ����
function CLogMgrDB.TongItemProduceEventLog(tongId,sName,uEventType,uExecutorId)
	local uEventId = CLogMgrDB._InsertEvent()

	WriteLog("tbl_log_tong_item_produce",  uEventId,tongId,sName,uEventType,uExecutorId)
end
------------------------------------------------------
--@brief Ӷ��С��ת�����¼�
--@param tongId:Ӷ��С��id
--@param uNewType:������
--@param uOldType:ԭ����
--@param uExecutorId:ִ����
function CLogMgrDB.TongChangeTypeLog(tongId,uNewType,uOldType,uExecutorId)
	local uEventId = CLogMgrDB._InsertEvent()

	WriteLog("tbl_log_tong_change_type",  uEventId,tongId,uNewType,uOldType,uExecutorId)
end
------------------------------------------------------
--@brief Ӷ��С�Ӳֿ��ȡ�¼�
--@param tongId:Ӷ��С��id
--@param uType:�ֿ���Ʒ�������� 1-��ȡ;2-����
--@param itemId:��Ʒid
--@param uExecutorId:ִ����
--@param uExecutorPosition:ִ����ְλ
function CLogMgrDB.DepotEventLog(tongId,uType,itemId,uDepotId,uExecutorId,uExecutorPosition)
	local uEventId = CLogMgrDB._InsertEvent()

	WriteLog("tbl_log_tong_depot",  uEventId,tongId,uType,itemId,uDepotId,uExecutorId,uExecutorPosition)
end
------------------------------------------------------
--@brief ��¼Ӷ��С�ӽ�ɢ��Ϣ
--@param tongId:Ӷ��С��id
--@param uCharId:ִ����
function CLogMgrDB.BreakTongLog(tongId,uCharId)
	local uEventId = CLogMgrDB._InsertEvent()

	WriteLog("tbl_log_tong_break",  uEventId , tongId,uCharId)
end
------------------------------------------------------
--@brief ��¼Ӷ��С��פ��Ǩ��log��Ϣ
--@param tongId:Ӷ��С��id
--@param uCharId:ִ����
--@param uEventType:Ǩ������(1-��սռ�죬2-��ս��ռ�죬3-��սռ�죬4-��ս��ռ�죬5-�������ˣ�6-����ɢ���ˣ�7-��ս����)
--@param uOldWarzoneId:��ս��id
--@param uOldIndex:��פ��id
--@param uNewWarzoneId:��ս��id
--@param uNewIndex:��פ��id
function CLogMgrDB.TongStationMoveLog(tongId,uCharId,uEventType,uOldWarzoneId,uOldIndex,uNewWarzoneId,uNewIndex)
	local uEventId = CLogMgrDB._InsertEvent()

	WriteLog("tbl_log_tong_station_move",  uEventId , tongId,uCharId,uEventType,uOldWarzoneId,uOldIndex,uNewWarzoneId,uNewIndex)
end
------------------------------------------------------
--@brief ��¼Ӷ��С����ս��ʼLog��Ϣ
--@param uCharId:������ս��id
--@param uChallengeTongId:��սӶ��С��id
--@param uRecoveryTongId:����Ӷ��С��id
--@param uWarzoneId:ս��id
--@param uIndex:פ��id
function CLogMgrDB.TongChallengeStartLog(uCharId,uChallengeTongId,uRecoveryTongId,uWarzoneId,uIndex)
	local uEventId = CLogMgrDB._InsertEvent()

	WriteLog("tbl_log_tong_challenge_start",  uEventId,uCharId,uChallengeTongId,uRecoveryTongId,uWarzoneId,uIndex)
end
------------------------------------------��Ӷ������ء�-----------------------------------------
--@brief ��¼Ӷ���ž�̬Log��Ϣ
--@param uArmyCorpsId:��id
--@param sName:������
--@param uCharId:������id
--@param uCamp:����Ӫ
function CLogMgrDB.ArmyCorpsStaticInfoLog(uArmyCorpsId,sName,uCharId,uCamp)
	WriteLog("tbl_log_army_corps", uArmyCorpsId,sName,uCharId,uCamp,os.date("%y-%m-%d %H:%M:%S"))
end
------------------------------------------------------
--@brief ��¼Ӷ���Ž�ɢlog��Ϣ
--@param uArmyCorpsId:��id
--@param uCharId:�ų�id
function CLogMgrDB.ArmyCorpsBreakInfoLog(uArmyCorpsId,uCharId)
	local uEventId = CLogMgrDB._InsertEvent()
	
	WriteLog("tbl_log_army_corps_break", uEventId,uArmyCorpsId,uCharId,os.date("%y-%m-%d %H:%M:%S"))
end

------------------------------------------------------
--@brief ��¼Ӷ���������¼�
--@param uArmyCorpsId:��id
--@param uEventType:1-����;2-�߳�;3-����
--@param uExecutorId:ִ����id
--@param uObjectId:��ִ����id
--@param uJobType:ְλ
function CLogMgrDB.ArmyCorpsMemberEventLog(uArmyCorpsId,uEventType,uExecutorId,uObjectId,uJobType)
	local uEventId = CLogMgrDB._InsertEvent()
	
	WriteLog("tbl_log_army_corps_member_event", uEventId,uArmyCorpsId,uEventType,uExecutorId,uObjectId,uJobType)
end
------------------------------------------------------
--@brief ��¼����������߳���������(����)
--@param charId����ɫid
--@param sSceneName���������ڳ���
--@param sArgNameName:������������
--@param uPosX,uPosY:���ߵ�����
function CLogMgrDB.SaveCharLogoutPosition(charId,sSceneName,sArgNameName,uPosX,uPosY)
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_player_logout_position",uEventId, charId,sSceneName,sArgNameName,uPosX,uPosY) 
end
----------------------------------------------------
function CLogMgrDB.SetLatencyToDB(data)
	local player_id, latency = data["char_id"], data["latency"]
	WriteLog("tbl_log_player_latency",player_id, latency,os.date("%y-%m-%d %H:%M:%S")) 
end
-----------------------------------------------------
--@brief �ֻ�
function CLogMgrDB.CultivateFlowersLog()
	local uEventId = CLogMgrDB._InsertEvent()
	
	WriteLog("tbl_log_cultivate_flowers",uEventId) 
	WriteLog("tbl_log_event_type",uEventId , event_type_tbl["�ֻ�"])
	return uEventId
end
-----------------------------------------------------
--@brief ������Ʒ��������
function CLogMgrDB.DropItemVendueLog()
	local uEventId = CLogMgrDB._InsertEvent()

	WriteLog("tbl_log_item_vendue",uEventId) 
	WriteLog("tbl_log_event_type",uEventId , event_type_tbl["������Ʒ��������"])
	return uEventId
end
-----------------------------------------------------
--@brief ������Ʒ�������
function CLogMgrDB.DropItemVendueEndLog()
	local uEventId = CLogMgrDB._InsertEvent()

	WriteLog("tbl_log_item_vendue_end",uEventId) 
	WriteLog("tbl_log_event_type",uEventId , event_type_tbl["������Ʒ�������"])
	return uEventId
end
-----------------------------------------------------
--@brief ���߾���һ�
function CLogMgrDB.ExpChangeLog()
	local uEventId = CLogMgrDB._InsertEvent()

	WriteLog("tbl_log_exp_change",uEventId) 
	WriteLog("tbl_log_event_type",uEventId , event_type_tbl["���߾���һ�"])
	return uEventId
end	
-----------------------------------------------------	
--@brief ����ս����������
function CLogMgrDB.SaveFightingEvaluation(uCharId,uPoint,uLevel)
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_char_fighting_evaluation",uEventId,uCharId,uPoint) 
	WriteLog("tbl_log_level",uEventId , uLevel)
end
------------------------------------------------------
--@brief Ӷ��С��������Դ�㱨��
--@param tongId:�μӱ�����С��id
--@param uCharId�������Ķӳ����߸��ӳ�id
--@param uExploit������ʱС�ӵ�����
--@param sObjName����������Դ������
function CLogMgrDB.SaveTongResourceSigUp(tongId,uCharId,uExploit,sObjName)
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_tong_resource_sig_up",uEventId,tongId,uCharId,uExploit,sObjName) 
end
-------------------------------------------------------
--@brief Ӷ��С��������Դ���ʤ
--@param tongId:��ʤС��id
function CLogMgrDB.SaveTongRobResourceSucc(tongId)
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_event_type",  uEventId , event_type_tbl["������Դ���ʤ"])
	WriteLog("tbl_log_tong_taker",uEventId, tongId ) 
end
-------------------------------------------------------
--@brief ��ȯ��Ϣ��¼
--@param couponsId:��ȯid
--@param sName:��ȯ����
--@param uSmallIcon����ȯͼ��
--@param uPrice����Ǯ
--@param sDesc������
function CLogMgrDB.SaveCouponsInfoLog(couponsId,sName,uSmallIcon,uPrice,sDesc,sUrl)
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_coupons_info",  uEventId , couponsId,sName,uSmallIcon,uPrice,sDesc,sUrl)
end
-------------------------------------------------------
--@brief ��¼��ҹ����ȯ��Ϣ
--@param uCharId:���id
--@param couponsId:��ȯid
--@param sSequenceId����ȯ��Ӧ�����к�
function CLogMgrDB.SaveCharBoughtCouponsLog(uEventId,uCharId,couponsId,sSequenceId)
	WriteLog("tbl_log_char_bought_coupons",uEventId, uCharId,couponsId,sSequenceId ) 
end
------------------------------------------------------
--@brief ��¼�����ȡ����log
--@param uCharId:��ȡ���ʵĽ�ɫid
--@param uResource:��ȡ���ʵ�����
function CLogMgrDB.SavePlayerDrawResourceInfoLog(uCharId,uResource)
	local uEventId = CLogMgrDB._InsertEvent()
	WriteLog("tbl_log_event_type",  uEventId , event_type_tbl["��ȡ����"])
	WriteLog("tbl_log_player_taker",uEventId, uCharId)
	WriteLog("tbl_log_tong_resource",uEventId, uResource)
end

SetDbLocalFuncType(CLogMgrDB.LeaveScene)
SetDbLocalFuncType(CLogMgrDB.EnterScene)
SetDbLocalFuncType(CLogMgrDB.LogReBorn)
return CLogMgrDB
