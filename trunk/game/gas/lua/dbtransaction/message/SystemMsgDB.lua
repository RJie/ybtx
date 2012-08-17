local SystemMsgSql = class()

local SystemMsgDB = CreateDbBox(...)
--------------------------------------------------------------------------------------------------------
local StmtDef = {
		"Insert_System_Message",
		[[insert into tbl_system_message (cs_uId,sm_uMsgId) values (?,?) ]]
}
DefineSql( StmtDef, SystemMsgSql )

--@brief ������Ҳ����ߵ�ϵͳ��Ϣ
--@param uCharId:���Id
--@param content��ϵͳ��Ϣ����
function SystemMsgDB.SaveSystemMsg(data)
	local uCharId = data["uCharId"]
	local messageId = data["messageId"]
	if uCharId == 0 or messageId == 0 then
		return
	end
	SystemMsgSql.Insert_System_Message:ExecSql('',uCharId,messageId)
end

--------------------------------------------------------------------------------------------------------
local StmtDef = {
	"Select_System_Message",
	[[ select sm_uMsgId from tbl_system_message where cs_uId = ?]] 
}
DefineSql(StmtDef, SystemMsgSql)

local StmtDef = {
	"Delete_System_Message",
	[[ delete from tbl_system_message where cs_uId = ?]] 
}
DefineSql(StmtDef, SystemMsgSql)

--@brief ������ͻ��˷���ϵͳ��Ϣ
function SystemMsgDB.SendSystemMsg(uCharID)
	--�������id��ѯϵͳ��Ϣ
	local system_msg_set = SystemMsgSql.Select_System_Message:ExecStat(uCharID)
	--��ѯ����Ϣ��ɾ���Ѿ��鿴����ϵͳ��Ϣ
	SystemMsgSql.Delete_System_Message:ExecStat(uCharID)
	return system_msg_set
end

return SystemMsgDB






