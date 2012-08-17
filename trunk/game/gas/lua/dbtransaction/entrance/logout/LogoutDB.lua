local Loginout = class()
local os = os
local apcall = apcall
local LogoutSql = CreateDbBox(...)
--[[
��Ҫ����˵����
1.�û��˳���Ϸʱд�������Ϣ�����ݿ�: SaveLogout(nUserID)
2.��GBS�����˳���¼: BeginSendQuit2GBS()
3.�Թ̶�Ƶ�ʱ��浱ǰʱ�䣬�������û������ۼ�����ʱ�䣺SaveAndUpTime2DB(nUserID)
4.ֹͣ�����û������ۼ�����ʱ�䣺StopUpdateOnlineTime(UpOLTimeTick)
5.����������ʱ��������ϴ�û����GBS���˳���¼���������ڵ�������
  �����򿽱����ݵ������ͱ���: CopyUnSentRecord()
--]]


-- ȡ���û�����Ϣ
local StmtDef=
{
	"SelectUserOnline",
	"select unix_timestamp(uo_dtLoginTime),uo_uOnlineTimeBegin from tbl_user_online where us_uId = ?"
}
DefineSql(StmtDef,Loginout)

-- �����û����µ��ۼ�����ʱ��
local StmtDef=
{
	"UpdateOnlineTime",
	"update tbl_user_basic set ub_uOnlineTime = ? where us_uId = ?"
}
DefineSql(StmtDef,Loginout)

-- ��ѯȫ����������

local StmtDef=
{
	"SelectAllOnlineNum",
	[[
		select count(*)
		from tbl_user_online
	]]
}
DefineSql(StmtDef,Loginout)

local StmtDef=
{
	"SelectGlobalOnlineNum",
	[[
		select count(*),us_uGameID 
		from tbl_user_online as uo,tbl_user_static as us
		where uo.us_uId = us.us_uId
		group by us_uGameID
	]]
}
DefineSql(StmtDef,Loginout)

local StmtDef=
{
	"_GetUserOnlineSn",
	"select uo_sSN from tbl_user_online where us_uId = ?"
}
DefineSql(StmtDef,Loginout)

-- ɾ���û�������Ϣ
local StmtDef=
{
	"DelUserOnline",
	"delete from tbl_user_online where us_uId = ?"
}
DefineSql(StmtDef,Loginout)

local StmtDef=
{
	"GetLastLoginTime",
	"select unix_timestamp(uo_dtLoginTime) from tbl_user_online where us_uId = ?"
}
DefineSql(StmtDef,Loginout)

-- ȡ���û���Ϣ���������˳���¼
local StmtDef=
{
	"SelectAuthLogout",
	[[
	select
		al_sSN,	us_uId,
		al_sIp,	al_uOnlineTimeBegin,
		al_uRetry, unix_timestamp(al_dtLogoutTime),
		al_uOnlineTimeEnd
	from
		tbl_auth_logout
	]]
}
DefineSql(StmtDef,Loginout)

-- ȡ��ʱ��
local StmtDef=
{
	"GetTime",
	[[
		select
			unix_timestamp(sv_dtDate)
		from
			tbl_var_server
		where
			sv_sVarName = "ServerShutTime"
			and sv_uServerId = ?
	]]
}
DefineSql(StmtDef,Loginout)

-- ����������ʱ����tbl_user_online���ϴ�û�������͵��˳���¼���Ƶ���tbl_auth_logout���Է��͵�GBS
local StmtDef=
{
	"_CopyUnSentRecord",
	[[
	insert into
		tbl_auth_logout
	select
		uo.uo_sSN, uo.us_uId, uo_sIp, uo_dtLoginTime,
		uo_uOnlineTimeBegin, 0,
		from_unixtime(?),ub_uOnlineTime
	from
		tbl_user_online as uo
		join
		tbl_user_basic as ub
		on
		uo.us_uId = ub.us_uId
	where
		uo.uo_uOnServerId = ?
	]]
}
DefineSql(StmtDef,Loginout)

-- ����û�������Ϣ��tbl_user_online
local StmtDef=
{
	"_ClearUserOnline",
	"delete from tbl_user_online where uo_uOnServerId = ?"
}
DefineSql(StmtDef,Loginout)

-- ������߱�
local StmtDef=
{
	"DeleteLogoutInfo",
	"delete from tbl_auth_logout"
}
DefineSql(StmtDef,Loginout)

		
-- ����ʱ��ȡ��ɫ��Ϣ
local StmtDef = 
{
	"_SelectLogOutCharInfo",
	[[
		select 
			cs.us_uId, cs.cs_uId, cs.cs_uClass, cb.cb_uLevel,cm.cm_uMoney, cm.cm_uBindingMoney, ce.cs_uLevelExp,al_sSN
		from 
			tbl_auth_logout al,tbl_char_static as cs,tbl_char_online co, tbl_char_basic as cb, tbl_char_experience ce,tbl_char_money cm
		where
			al.us_uId = cs.us_uId and cs.cs_uId = co.cs_uId and co.cs_uId = cb.cs_uId and cb.cs_uId = ce.cs_uId and ce.cs_uId = cm.cs_uId
	]]
	
}
DefineSql(StmtDef, Loginout)

-- ���������쳣�˳�ʱδ�����������tbl_char_online���������ߵ�������ʱ���ϻ��д���
local StmtDef = 
{
	"UpdateOnLineInfo",
	[[
		delete from tbl_char_online where co_uOnServerId = ?
	]]
}
DefineSql(StmtDef, Loginout)

local StmtDef = 
{
	"DelCharLefttimeInfo",
	[[
		delete tbl_char_onlinetime from tbl_char_onlinetime,tbl_char_online
		where tbl_char_onlinetime.cs_uId = tbl_char_online.cs_uId and co_uOnServerId = ?
	]]
}
DefineSql(StmtDef, Loginout)
--------------------------------------------------------------------------------------
--�û��˳���Ϸʱд�������Ϣ�����ݿ�
--------------------------------------------------------------------------------------
--ȡ���û�����Ϣ
function LogoutSql.GetUserInfo(nUserID)
	local res = Loginout.SelectUserOnline:ExecSql("nn", nUserID)
 	local uLoginTime,uOnlineTimeBegin
 	if(res:GetRowNum()~=0) then
 		uLoginTime = res:GetData(0,0)
 		uOnlineTimeBegin = res:GetData(0,1)
 		
 		local uLogoutTime = os.time()
		local uSpentTime = uLogoutTime - uLoginTime
		local uOnlineTime = uOnlineTimeBegin + uSpentTime

		return uLogoutTime, uOnlineTime
	else
		local uLogoutTime = os.time()
		return uLogoutTime, 0
	end
end

function LogoutSql.SaveAndUpTime(data)
	local nUserID, bStopUpOLTime = data["user"], data["time"]
	
	local uLogoutTime, uOnlineTime = LogoutSql.GetUserInfo(nUserID)
	--print("-->>>uLogoutTime = ",uLogoutTime," uOnlineTime = ",uOnlineTime)
	
	--����ʱ��
	if(bStopUpOLTime == true) then
		return
	end
	
	--����OnlineTime
	Loginout.UpdateOnlineTime:ExecSql("", uOnlineTime, nUserID)
end

--ȡ���û�����
local StmtDef =
{
	"_QueryUserName",
	"select us_sName,us_uGameID from tbl_user_static where us_uId = ? "
}
DefineSql(StmtDef,Loginout)

local StmtDef =
{
	"_QueryUserId",
	"select us_uId from tbl_user_static where us_sName = ? and us_uGameID = ?"
}
DefineSql(StmtDef,Loginout)

--��¼�˺�������Ϣ
local StmtDef =
{
	"_SaveLogoutUserInfo",
	"insert ignore into tbl_user_logout set us_sName = ?,ul_dtLogoutTime = now(),ul_uOnServerId = ?,us_uGameID = ?"
}
DefineSql(StmtDef,Loginout)

--��¼�˺�����ʱ��
local StmtDef =
{
	"_SaveUserLogoutTime",
	"update tbl_user_last_login_logout_time set ulllt_dtLogoutTime = now() where us_uId = ?"
}
DefineSql(StmtDef,Loginout)

local StmtDef =
{
	"GetOnlineCharIdByUserId",
	[[
	select
		co.cs_uId
	from
   	tbl_char_online as co, tbl_char_static as cs
	where
  	co.cs_uId = cs.cs_uId and
  	cs.us_uId = ?
	]]
}
DefineSql(StmtDef,Loginout)

function LogoutSql.GetGlobalUserNum()
	local res_online_num = Loginout.SelectGlobalOnlineNum:ExecStat()
	return res_online_num
end

function LogoutSql.GetOnlineUserNum()
	local res_online_num = Loginout.SelectAllOnlineNum:ExecStat()
	return res_online_num(1,1)
end

function LogoutSql.SaveLogoutInfo(data)
	local nUserID = data["nUserID"]
	--д�ǳ�Log
	local uLogoutTime, uOnlineTime = LogoutSql.GetUserInfo(nUserID)
	-- �����û����µ��ۼ�����ʱ��
	Loginout.UpdateOnlineTime:ExecSql("", uOnlineTime, nUserID)
	local snRes = Loginout._GetUserOnlineSn:ExecStat(nUserID)
	if snRes:GetRowNum() > 0 then
		local g_LogMgr = RequireDbBox("LogMgrDB")
		g_LogMgr.LogLogout(nUserID,snRes:GetData(0,0))	
	end
	-- ɾ���û�������Ϣ
	Loginout.DelUserOnline:ExecSql("", nUserID)
	
	local CharacterMediatorDB = RequireDbBox("CharacterMediatorDB")
	--ɾ���û���ɫ������Ϣ
	local charRes = Loginout.GetOnlineCharIdByUserId:ExecSql("n", nUserID)
	if charRes:GetRowNum() > 0 then
		for i=0,  charRes:GetRowNum()-1 do
			apcall(CharacterMediatorDB.LogLogout,charRes:GetData(0,0))
		end
	end
	charRes:Release()
	
	--����û�����
	local userNameRes = Loginout._QueryUserName:ExecStat(nUserID)
	local userName,game_id
	if userNameRes and userNameRes:GetRowNum() > 0 then
		userName = userNameRes:GetData(0,0)
		game_id = userNameRes:GetData(0,1)
	end
	Loginout._SaveLogoutUserInfo:ExecSql("", userName, g_CurServerId,game_id)
	Db2CallBack("RegisterLogoutTick", userName,game_id)
	Loginout._SaveUserLogoutTime:ExecStat(nUserID)
end

function LogoutSql.ForceLogout(data)
	local useName =  data["UserName"]
	local lastLoginTime = data["LastLoginTime"]
	local game_id = data["game_id"]
	local userIdRes = Loginout._QueryUserId:ExecStat(useName,game_id)
	if not (userIdRes:GetRowNum() >  0) then
		return false
	end
	
	local nUserID = userIdRes:GetData(0,0)
	local lastLoginRes = Loginout.GetLastLoginTime:ExecStat(nUserID)
	if not (lastLoginRes:GetRowNum() >  0)  or lastLoginRes:GetData(0,0) ~= lastLoginTime then
		return false
	end
	
	Loginout.DelUserOnline:ExecStat(nUserID)
	return true
end


function LogoutSql.CopyUnSentRecord(data)
	local serverId = data["CurServerId"]
	Loginout.UpdateOnLineInfo:ExecSql("", serverId)
	Loginout.DelCharLefttimeInfo:ExecSql("", serverId)
	local GasMainDB = RequireDbBox("GasMainDB")
	Db2GasCall("UpdateOnlineInfo",nil,unpack(GasMainDB.GetOtherServerList()))
end

function LogoutSql.SendQuitRecord(data)
	local serverId = data["CurServerId"]
	local res = Loginout.GetTime:ExecStat(serverId)
	if(res:GetRowNum() > 0) then
		local uLogoutTime = res:GetData(0,0)
		--���Ƽ�¼
		Loginout._CopyUnSentRecord:ExecSql("",uLogoutTime, serverId)
		--���tbl_user_online
		Loginout._ClearUserOnline:ExecSql("",serverId)
	end
	
	local LogoutInfo = Loginout._SelectLogOutCharInfo:ExecStat()
	local g_LogMgr = RequireDbBox("LogMgrDB")
	--��¼�ʺ�������Ϣ
	for i=1, LogoutInfo:GetRowNum() do
		local user_id = LogoutInfo:GetData(i-1, 0)
		local sn = LogoutInfo:GetData(i-1,7)
		g_LogMgr.LogLogout(user_id,sn)
	end
	Loginout.DeleteLogoutInfo:ExecSql("")
	return LogoutInfo
end


SetDbLocalFuncType(LogoutSql.ForceLogout)
SetDbLocalFuncType(LogoutSql.SaveAndUpTime)
return LogoutSql
