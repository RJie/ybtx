gac_gas_require "framework/text_filter_mgr/TextFilterMgr"

local os = os
local textFilter = CTextFilterMgr:new()
local LoginServer = class()

----------------------------------------------------------------------------------------------------
-- ȡ���û�ID(ͨ���û���)
local StmtDef=
{
	"SelectUserID",
	"select us_uId from tbl_user_static where us_sName = ? and us_uGameID = ?"
}
DefineSql(StmtDef,LoginServer)

-- ȡ���û�ID(ͨ����ɫ��ID)
local StmtDef=
{
	"GetUserIdOrName",
	[[
		select
			us.us_uId, us.us_sName,us_uGameID
		from
			tbl_user_static as us
		where
			us_uId = (select us_uId from tbl_char_static where cs_uId = ?)
	]]
}
DefineSql(StmtDef,LoginServer)

local StmtDef=
{
	"GetUserID",
	[[
		select
			us.us_uId
		from
			tbl_user_static as us
		where
			us.us_sName = ? and us_uGameID = ?
	]]
}
DefineSql(StmtDef,LoginServer)

-- ȡ����ҵ������ۼ�����ʱ��
local StmtDef=
{
	"SelectUserInfo",
	"select ub_uOnlineTime,ub_uYuanBao,ub_uAgreedVer from tbl_user_basic where us_uId = ?"
}
DefineSql(StmtDef,LoginServer)

-- �������������Ϣ
local StmtDef=
{
	"InsertUserOnline",
	"insert into tbl_user_online set us_uId=?,uo_sIp=?,uo_sSN=?,uo_dtLoginTime=from_unixtime(?),uo_uOnlineTimeBegin=?,uo_uOnServerId=?,uo_uLoginKey=?,uo_sMacAddress = ?"
}
DefineSql(StmtDef,LoginServer)

--��¼�ʺŵ�¼ʱ��
local StmtDef=
{
	"_SaveUserLoginTime",
	"update tbl_user_last_login_logout_time set ulllt_dtLoginTime = now() where us_uId = ?"
}
DefineSql(StmtDef,LoginServer)

-- ��ѯȫ����������
local StmtDef=
{
	"SelectGlobalOnlineNum",
	[[
		select count(*) 
		from tbl_user_online
	]]
}
DefineSql(StmtDef,LoginServer)


-- ������Ҷ�̬����
local StmtDef=
{
	"InsertUserBasic",
	"insert ignore into tbl_user_basic set us_uId=?,ub_uAgreedVer=0"
}
DefineSql(StmtDef,LoginServer)

-- Զ����֤
local StmtDef=
{
	"InsertUserStatic",
	"insert ignore into tbl_user_static set us_uId=?, us_sName=?,us_sPassword = ?,us_uGameID = ?,us_dtCreateTime = now()" 
}
DefineSql(StmtDef,LoginServer)

local StmtDef=
{
	"_InsertUserLoginInfo",
	"insert into tbl_user_last_login_logout_time set us_uId = ?, ulllt_dtLoginTime = now(),ulllt_dtLogoutTime = now()" 
}
DefineSql(StmtDef,LoginServer)


-- �ڱ������ݿ��������ҵ�¼�ʺź�����
local StmtDef=
{
	"InsertUserStaticLocal",
	"insert ignore into tbl_user_static set us_sName=?,us_sPassword = ?,us_uGameID = ?,us_dtCreateTime = now()" 
}
DefineSql(StmtDef,LoginServer)

--�����û�����ѯ���ʺ��Ƿ񶳽�
local StmtDef=
{
	"SelectFreezeAccount",
	"select count(*) from tbl_freeze_account where username = ? and us_uGameID = ?"
}
DefineSql(StmtDef,LoginServer)

--�����˺ź������Ƿ���ȷ
local StmtDef=
{
	"SelectUserPasswdInfo",
	[[
		select 
			us_uId, us_sPassword, us_sMatrixPasswd, us_sMatrixCoord
		from 
			tbl_user_static 
		where 
			us_sName = ? and us_uGameID = ?
	]]
}
DefineSql(StmtDef,LoginServer)

--��������
local StmtDef = 
{
	"UpdateUserPasswd",
	"update tbl_user_static set us_sPassword = ? where us_sName = ? and us_uGameID = ? "
}
DefineSql(StmtDef,LoginServer)

-- ���ݽ�ɫ���õ�user id
local StmtDef =
{
	"SelectUid_cs",
	"select us_uId from tbl_char_deleted cd,tbl_char_static cs where  cd.cs_uId=cs.cs_uId and cd.cd_sName=? "
}
DefineSql(StmtDef,LoginServer)


--����ɾ����cs_uId�õ���ɫ��
local StmtDef =
{
  "SelectCdName",
  "select cd_sName  from tbl_char_deleted where cs_uId=? "
}
DefineSql(StmtDef,LoginServer)


--���ݵ�ǰҪɾ���Ľ�ɫ���õ���ǰ����Ľ�ɫID
--��ûʵ��ֻ��ͬһ�ʺ�us_uId���ж�
local StmtDef=
{
 "SelectIfSame",
 "select c.cs_uId  from tbl_char c, tbl_char_deleted cd where c.c_sName=cd.cd_sName and cd.cs_uId=? "
}
DefineSql(StmtDef,LoginServer)

local StmtDef =
{
	"AgreeUserAgreement",
	"update tbl_user_basic set ub_uAgreedVer=1 where us_uid =?"
}
DefineSql(StmtDef,LoginServer)


--��ɾ�����еĽ�ɫ��Ϣcopy��tbl_char����
local StmtDef=
{
	"Copy2DeletedChar",
	"insert into tbl_char(cs_uId,c_sName) select cs_uId,cd_sName from tbl_char_deleted where cs_uId=?"
}
DefineSql(StmtDef,LoginServer)




--���ݽ�ɫ����tbl_char��ɾ����ǰ�Ľ�ɫ
local StmtDef=
{
	"DelCharName",
	"delete from tbl_char where c_sName = ?"
}
DefineSql(StmtDef,LoginServer)



-- ����user id�õ����е�char id
local StmtDef =
{
	"GetCharStatic",
	[[
	select
		cs.cs_uId,c.c_sName,cs.cs_sHair,cs.cs_sHairColor,cs.cs_sFace,cs.cs_uScale,cs.cs_uSex,cs.cs_uClass, cs.cs_uCamp,
		ifnull(tt.t_sName,""),
		ifnull(tm.mt_sPosition, 0),
		ifnull(ac.ac_sName, ""),
		ifnull((select co_dtLastLoginTime from tbl_char_onlinetime co where co.cs_uId = cs.cs_uId), 0) as logTime
	from
		tbl_char as c
		join tbl_char_static as cs
		join tbl_char_basic as cb
			on c.cs_uId = cs.cs_uId and cs.cs_uId = cb.cs_uId
		left join tbl_member_tong as tm
			on cb.cs_uId = tm.cs_uId 
		left join tbl_tong as tt 
			on tm.t_uId = tt.t_uId
		left join tbl_army_corps_member as acm
			on acm.t_uId = tt.t_uId 
		left join tbl_army_corps as ac
			on ac.ac_uId = acm.ac_uId
	where
		us_uId = ?
	order by
		logTime desc, cb.cb_uLevel desc limit 5
	]]
}
DefineSql(StmtDef,LoginServer)

--��ɫ����ʾ
local StmtDef = 
{
	"RoleNoDisplay",
	"update tbl_char_deleted set cd_uState=2 where cs_uId = ?"
}
DefineSql(StmtDef,LoginServer)

-- ����user id�õ����е� delete_char id
local StmtDef =
{
	"GetDelCharStatic",
	[[
	select cs.cs_uId,cd.cd_sName,cs.cs_sHair,cs.cs_sHairColor,cs.cs_sFace,cs.cs_uScale,cs.cs_uSex,cs.cs_uClass, cs.cs_uCamp, TO_DAYS(now()) - TO_DAYS(cd.cd_dtDelTime) as back_time
	from tbl_char_deleted as cd
	join tbl_char_static as cs join tbl_char_basic as cb on cd.cs_uId=cs.cs_uId and cs.cs_uId = cb.cs_uId
	where us_uId = ? and cd.cd_uState = 1
	order by back_time asc , cb.cb_uLevel desc limit 10
	]]
}
DefineSql(StmtDef,LoginServer)

-- ��ȡ������Ϣ
local StmtDef = 
{
	"GetCharInfoByUserID",
	[[
		select 
			cb.cs_uId, cb.cb_uLevel, cp.sc_uId
		from 
			tbl_char_basic as cb, tbl_char_position as cp, tbl_char_static as cs, tbl_char as c
		where
			cb.cs_uId = cp.cs_uId and cs.cs_uId = cb.cs_uId and c.cs_uId = cs.cs_uId and cs.us_uId = ?
	]]
}
DefineSql(StmtDef, LoginServer)

-- ��ȡ������Ϣ
local StmtDef = 
{
	"GetDeldCharInfoByUserID",
	[[
		select 
			cb.cs_uId, cb.cb_uLevel, cp.sc_uId
		from 
			tbl_char_basic as cb, tbl_char_position as cp, tbl_char_static as cs, tbl_char_deleted as cd
		where
			cb.cs_uId = cp.cs_uId and cs.cs_uId = cb.cs_uId and cd.cs_uId = cs.cs_uId and cs.us_uId = ? 
	]]
}
DefineSql(StmtDef, LoginServer)

-- ����char id �õ� char info
local StmtDef =
{
	"GetCharInfo",
	[[
	select 
		cb.cb_uLevel,cs.cs_uSex,cs.cs_uClass,cs.cs_uCamp
	from tbl_char_basic as cb
		join tbl_char_position as cp on cb.cs_uId=cp.cs_uId
		join tbl_char_static as cs on cp.cs_uId = cs.cs_uId
	where cb.cs_uId = ?
	]]
}
DefineSql(StmtDef,LoginServer)


local StmtDef=
{
	"Copy2CharDeleted",
	"insert ignore into tbl_char_deleted set cs_uId = ?,cd_sName = ? ,cd_dtDelTime = from_unixtime( ? ), cd_uState=1"
}
DefineSql(StmtDef,LoginServer)


--����idɾ���ѻָ��Ľ�ɫ
local StmtDef=
{
	"Del_DelChar",
	"delete from tbl_char_deleted where cs_uId= ?"
}
DefineSql(StmtDef,LoginServer)


--����id ɾ����ɫ
local StmtDef=
{
	"DelChar",
	"delete from tbl_char where cs_uId = ?"
}
DefineSql(StmtDef,LoginServer)


--GM����ɾ����ɫ
local StmtDef = 
{
"DelAllChar",
"delete from tbl_char where cs_uId=? "
}
DefineSql(StmtDef,LoginServer)

--�������tbl_char_onlinetime ��
local StmtDef = 
{
	"InsertOnlineCharInfo",
	"insert ignore  into tbl_char_onlinetime(cs_uId, co_dtLastLoginTime, co_dtLastLogOutTime) values(?, now(),now())"
}
DefineSql(StmtDef,LoginServer)

local StmtDef =
{
	"_GetUserIDByCharID",
	"select us_uId from  tbl_char_static  where cs_uId = ?"
}
DefineSql(StmtDef,LoginServer)

local StmtDef = 
{
	"_GetDeledRoleName",
	"select cd_sName from tbl_char_deleted where cs_uId = ?"
}
DefineSql(StmtDef,LoginServer)

	local StmtDef =
{
	"_UpdateCharName",
	"update tbl_char set c_sName = ?  where cs_uId = ?"
}
DefineSql(StmtDef,LoginServer)
--��ѯ��ɫ������Ϣ
local StmtDef =
{
	"IsPlayerOnLine",
	"select co_uOnServerId from  tbl_char_online  where cs_uId = ?"
}
DefineSql(StmtDef,LoginServer)

--��ѯ���ݿ������õ�����½����
local StmtDef =
{
	"GetMaxLoginNum",
	"select cast(sv_sVarValue as unsigned) as max_login_num from tbl_var_server where sv_sVarName='OnlineLimit'"
}
DefineSql(StmtDef,LoginServer)




-- ��ѯ�Ƿ�����
local StmtDef= 
{
	"SelectCharInfo",
	[[ 
		select 
			(select count(*) from tbl_char where c_sName=?)
				+
			(select count(*) from tbl_char_deleted where cd_sName=?)
	]]
}
DefineSql(StmtDef,LoginServer)


local StmtDef =
{
	"UserTrust",
	"replace into tbl_user_trust(us_uId,ut_sPassword,ut_dtTrustTime,ut_uTrustLength) values(?,?,now(),?)"
}
DefineSql(StmtDef,LoginServer)

local StmtDef =
{
	"CancelUserTrust",
	"delete from tbl_user_trust where us_uId = ?"
}
DefineSql(StmtDef,LoginServer)

local StmtDef =
{
	"FindUserIdByCharName",
	[[select  us.us_uId 
	from tbl_user_static us, tbl_char_static cs, tbl_char c 
	where us.us_uId = cs.us_uId and cs.cs_uId = c.cs_uId and c.c_sName = ?
	]]
}
DefineSql(StmtDef,LoginServer)

local StmtDef =
{
	"GetUserId",
	"select us_uId from tbl_user_static where us_sName = ? and us_uGameID = ?"
}
DefineSql(StmtDef,LoginServer)


local StmtDef =
{
	"GetUserTrustInfo",
	"select ut_sPassword, unix_timestamp(ut_dtTrustTime), ut_uTrustLength from tbl_user_trust where us_uId = ?"
}
DefineSql(StmtDef,LoginServer)


local StmtDef =
{
	"GetUserInfo",
	"select us_sName, us_uGameID from tbl_user_static where us_uId = ?"
}
DefineSql(StmtDef,LoginServer)




local os = os
local LogErr = LogErr
local LoginServerSql = CreateDbBox(...)

-----------------------------------------------------------------------------------
--�����û��Ƿ�����
function LoginServerSql.IsPlayerOnLine(char_id)
	local res = LoginServer.IsPlayerOnLine:ExecSql("n", char_id)
	local serverId = 0
	if res:GetRowNum() > 0 then
		serverId = res:GetData(0,0)
	end
	res:Release()
	return serverId ~= 0  --���ڷ�������Ϊ0������
end
-----------------------------------------------------------------------------------
--ע������޸�����˺�
function LoginServerSql.AuthSuccessAndInsertLocalDB(data)
	local szName = data["UserName"]
	local sPassword = data["Password"]
	local user_id = data['UserID']
	local game_id = data['game_id']
	local g_LogMgr = RequireDbBox("LogMgrDB")
	--�����ǰ�й����ʺţ���ô����Ӱ����
	if type(user_id) == "number" and user_id > 0 then
		LoginServer.InsertUserStatic:ExecStat(user_id, szName, sPassword,game_id) --����û����ڣ���ô��仰û������
	else
		LoginServer.InsertUserStaticLocal:ExecStat(szName, sPassword,game_id)
		user_id = g_DbChannelMgr:LastInsertId()
	end
	if g_DbChannelMgr:LastAffectedRowNum() ~= 1 then
		g_DbChannelMgr:CancelTran()
		return -500
	end
	LoginServer._InsertUserLoginInfo:ExecStat(user_id)
	g_LogMgr.CopyUserInfo(user_id,szName)
	return g_DbChannelMgr:LastAffectedRowNum() > 0
end
-----------------------------------------------------------------------------------
--�ڱ������ݿ���֤�����Ϣ(�ʺ������Ƿ����)
function LoginServerSql.SelectPlayerInfoFromLocalDB(data)
	local UserName = data["UserName"]
	local Password = data["Password"]
	local MatrixPasswd = data["MatrixPasswd"]
	local MatrixCoord = data["MatrixCoord"]
	local game_id = data["game_id"]
	--res�����жϸ��˺��Ƿ񱻶���
	local res1 = LoginServer.SelectFreezeAccount:ExecStat(UserName,game_id)
	--res2�����жϸ��˺������Ƿ����
	local passwd_info = LoginServer.SelectUserPasswdInfo:ExecStat(UserName,game_id)
	--res3�����ж������Ƿ���ȷ
	
	local IsFreeze = 0
	IsFreeze = res1:GetData(0,0)
	res1:Release()
	
	local IsAuthSucc = true
	if passwd_info:GetRowNum() == 0 or Password ~= passwd_info(1,2) or
		MatrixPasswd ~= passwd_info(1,3) or
		MatrixCoord ~= passwd_info(1,4) then
		IsAuthSucc = false
	end
	local usID = nil
	if passwd_info:GetRowNum() > 0 then
		usID = passwd_info(1,1)
	end
	return {IsFreeze, IsAuthSucc,usID}
end
-------------------------------update passwd----------------------------------------------------
function LoginServerSql.UpdatePasswd(data)
	local UserName = data["UserName"]
	local Password = data["PassWord"]
	local game_id = data["game_id"]
	LoginServer.UpdateUserPasswd:ExecStat(Password,UserName,game_id)
	local res1 = LoginServer.SelectFreezeAccount:ExecSql("n", UserName,game_id)
	local IsFreeze = 0
	IsFreeze = res1:GetData(0,0)
	res1:Release()	
	
	return {IsFreeze}
end
-----------------------------------------------------------------------------------
local StmtDef =
{
	"CheckUserIsOnLine",
	[[
		select
			uo_uLoginKey, unix_timestamp(uo_dtLoginTime), uo_uOnServerId
		from
			tbl_user_online
		where
			us_uId=?
	]]
}
DefineSql(StmtDef,LoginServer)

local StmtDef =
{
	"_DelLogoutUserInfo",
	"delete from tbl_user_logout where us_sName = ? and us_uGameID = ?"
}
DefineSql(StmtDef,LoginServer)

local StmtDef =
{
	"_AddActivationCode",
	"replace into tbl_user_activation_code set us_uId = ?,uac_ActCode = ?"
}
DefineSql(StmtDef,LoginServer)
function LoginServerSql.GetAccountInfoFromDB(data)
	local szName, Password, ip = data["name"], data["password"], data["ip"]
	local userid = data["userid"]
	local game_id = data["game_id"]
	local sn = data["Sn"]
	local g_LogMgr = RequireDbBox("LogMgrDB")
	local res = LoginServer.SelectUserID:ExecStat(szName,game_id)
	local nUserID = nil
	if res:GetRowNum() ==0 then
		if type(userid) == "number" and userid > 0 then
			LoginServer.InsertUserStatic:ExecStat(userid, szName, Password,game_id) --����û����ڣ���ô��仰û������
		else
			LoginServer.InsertUserStaticLocal:ExecSql("", szName, Password,game_id)
			userid = g_DbChannelMgr:LastInsertId()
		end
		if g_DbChannelMgr:LastAffectedRowNum() ~= 1 then
			g_DbChannelMgr:CancelTran()
			LogErr("GetAccountInfoFromDB�����ʺų���")
			return false
		end
		nUserID = userid
		g_LogMgr.CopyUserInfo(userid,szName)
		if g_DbChannelMgr:LastAffectedRowNum() ~= 1 then
			g_DbChannelMgr:CancelTran()
			LogErr("GetAccountInfoFromDB�������ݳ���")
			return false
		end
		LoginServer._InsertUserLoginInfo:ExecStat(nUserID)
	else
		nUserID = res:GetData(0,0)
	end
	res:Release()
	local resOnLine = LoginServer.CheckUserIsOnLine:ExecStat(nUserID)
	if resOnLine:GetRowNum() > 0 then
		return false, resOnLine:GetData(0,0), resOnLine:GetData(0,1), resOnLine:GetData(0,2)
	end
	resOnLine:Release()
	
	--������Ҷ�̬����
	--������ʺ��Ѿ����������ݿ��У���������ִ����û���κ�Ч����
	LoginServer._DelLogoutUserInfo:ExecSql("",szName,game_id)
	LoginServer.InsertUserBasic:ExecSql("",nUserID)
	--ȡ���ʺ���Ϣ�����������ۼ�����ʱ�䡢�ϴ�ͬ���û�Э��İ汾��
	local res_info = LoginServer.SelectUserInfo:ExecSql("nnn",nUserID)

	local uOnlineTime,uYuanBao,uAgreedVer =0,0,0
	if(res_info:GetRowNum()~= 0) then
		uOnlineTime = res_info:GetData(0,0)
		uYuanBao	= res_info:GetData(0,1)
		uAgreedVer = res_info:GetData(0,2)
	end
	res_info:Release()
	
	res = LoginServer.InsertUserOnline:ExecSql("",nUserID,ip,sn,os.time(),uOnlineTime,data["CurServerId"],data["LoginKey"],data["sMacAddress"])
	LoginServer._SaveUserLoginTime:ExecStat(nUserID)
	
	if data["activation_code"] and string.len(data["activation_code"]) > 0 then
		LoginServer._AddActivationCode:ExecStat(nUserID,data["activation_code"])
	end
	local GasRecruitSql = RequireDbBox("RecruitPlayerDB")
	local campInfoTbl = GasRecruitSql.GetRecruitCampInfo()
	g_LogMgr.LogLogin(nUserID,ip,sn)
	local AccountInfo = {szName, nUserID, uYuanBao}
	return {AccountInfo, uAgreedVer, campInfoTbl}
end


function LoginServerSql.GetAccountInfoFromName(data)
	local szName = data["UserName"]
	local game_id = data["game_id"]
	local res = LoginServer.GetUserID:ExecStat(szName,game_id)
	local nUserID = res:GetData(0,0)
	res:Release()
	
	local res_info = LoginServer.SelectUserInfo:ExecSql("nnn",nUserID)
	local uOnlineTime,uYuanBao,uAgreedVer =0,0,0
	if(res_info:GetRowNum()~= 0) then
		uOnlineTime = res_info:GetData(0,0)
		uYuanBao	= res_info:GetData(0,1)
		uAgreedVer = res_info:GetData(0,2)
	end
	res_info:Release()
	return {nUserID,szName,uYuanBao,uAgreedVer}
end

function LoginServerSql.GetAccountInfoFromID(data)
	local char_id = data["char_id"]
	local user_info = LoginServer.GetUserIdOrName:ExecStat(char_id)
	local nUserID,szName,game_id = user_info(1,1),user_info(1,2),user_info(1,3)
	
	local res_info = LoginServer.SelectUserInfo:ExecSql("nnn",nUserID)
	local uOnlineTime,uYuanBao,uAgreedVer =0,0,0
	if(res_info:GetRowNum()~= 0) then
		uOnlineTime = res_info:GetData(0,0)
		uYuanBao	= res_info:GetData(0,1)
		uAgreedVer = res_info:GetData(0,2)
	end
	res_info:Release()
	return {nUserID,szName,uYuanBao,uAgreedVer,game_id}
end
----------------------------------------------------------------------------------------------------
local StmtDef = 
{
    "_SelectRushRegiAccount",
    [[
        select sc_sVarValue from tbl_conf_server where sc_sVarName = "RushRegisterAccountFlag";
    
    ]]
}DefineSql(StmtDef, LoginServer)

function LoginServerSql.GetCharList (data)
	local uid = data["uid"]
	local AllChar = LoginServer.GetCharStatic:ExecStat(uid)
	local tblEquipInfo = {}
	local ResTbl = {}
	local PhaseTbl = {}
	local EquipMgrDB = RequireDbBox("EquipMgrDB")
	for y = 1, AllChar:GetRowNum() do
		local uCharID, nClass = AllChar(y,1), AllChar(y,8)
		ResTbl[uCharID],PhaseTbl[uCharID] = EquipMgrDB.GetEquipResID(uCharID,nClass)
	end
	
	local base_res = LoginServer.GetCharInfoByUserID:ExecSql("nnn", uid)
	for n = 1, base_res:GetRowNum() do
		tblEquipInfo[base_res:GetData(n-1,0)] = {base_res:GetData(n-1,0),base_res:GetData(n-1,1),base_res:GetData(n-1,2)}
	end
    
    local GasCreateRoleDB = RequireDbBox("GasCreateRoleDB")
    local rushRegiAccountFlag = GasCreateRoleDB.GetServerRushRegiAccountFlag()
	
	return AllChar,tblEquipInfo,ResTbl,PhaseTbl, rushRegiAccountFlag
end
----------------------------------------------------------------------------------------------------
function LoginServerSql.GetDeletedCharList(data)
	local uid = data["uid"]
	local AllChar = LoginServer.GetDelCharStatic:ExecStat(uid)

	local ResTbl = {}
	local PhaseTbl = {}
	local res = {}
	local EquipMgrDB = RequireDbBox("EquipMgrDB")

	for y = 1, AllChar:GetRowNum() do
		local uCharID, nClass = AllChar(y,1), AllChar(y,8)
		ResTbl[uCharID],PhaseTbl[uCharID] = EquipMgrDB.GetEquipResID(uCharID,nClass)
	end
	
	local equip_res = LoginServer.GetDeldCharInfoByUserID:ExecStat(uid)
	for n = 1, equip_res:GetRowNum() do
		res[equip_res(n,1)] = {equip_res(n,1),equip_res(n,2),equip_res(n,3)}
	end
	return AllChar,res,ResTbl,PhaseTbl
end


--------------------------------------------------------
function LoginServerSql.RoleNoDisplay(data)
	local char_id = data["char_id"]
	LoginServer.RoleNoDisplay:ExecSql("", char_id)
	local FriendGroupDbBox = RequireDbBox("FriendGroupDB")
	FriendGroupDbBox.DelPlayerFromGroupAndClass(char_id,data["msg"])
end
----------------------------------------------------------------------------------------------------
function LoginServerSql.SetUserAgreement(data)
	local uid = data["uid"]
	LoginServer.AgreeUserAgreement:ExecSql("",uid)
end
----------------------------------------------------------------------------------------------------
function LoginServerSql.CompleteDeleteChar(data)
	local CharId = data["CharId"]
	LoginServer.DelAllChar:ExecSql("", CharId)
end

--ɾ����ɫʱ���Ƿ��Ѿ�������С���ŶӰ�����֯���жϺʹ���
function LoginServerSql.DealWithRelationsInfo(nCharID)
	local result = {}
	--��С�ӵĴ���
	local team = RequireDbBox("GasTeamDB")
	local team_info = team.DealWithTeamInfoWhenDelChar(nCharID)
	
	--���
	local tong = RequireDbBox("GasTongBasicDB")
	local uArmyCorpsNewAdminId, uTongNewLeaderId, tong_id = tong.DealWithTongInfoWhenDelChar(nCharID)
	result["ArmyCorps_AdminId"] = uArmyCorpsNewAdminId
	result["Tong_LeaderId"] = uTongNewLeaderId
	result["Tong_Id"] = tong_id
	result["team_info"] = team_info
	
	return result
end
----------------------------------------------------------------------------------------------------
function LoginServerSql.DelChar(data)
	local cs_uId 	= data["cs_uId"]
	local ex = RequireDbBox("Exchanger")
	local playerName = ex.getPlayerNameById(cs_uId)
	
	--ɾ����ɫʱ���Ƿ��Ѿ�������С���ŶӰ�����֯���жϺʹ���
	local result = LoginServerSql.DealWithRelationsInfo(cs_uId)
	result["CharName"] = playerName
	LoginServer.Copy2CharDeleted:ExecSql( "",cs_uId,playerName,os.time())
    if g_DbChannelMgr:LastAffectedRowNum() ~= 1 then
		CancelTran()
		return false, 11012
	end
	LoginServer.DelChar:ExecSql( "", cs_uId )
    if g_DbChannelMgr:LastAffectedRowNum() ~= 1 then
		CancelTran()
		return false, 11013
	end
	local g_LogMgr = RequireDbBox("LogMgrDB")
	g_LogMgr.DelCharList(cs_uId,playerName)
	return true, result
end
----------------------------------------------------------------------------------------------------
--��������ʺŲ�ѯ�����Ľ�ɫ����Ŀ
local StmtDef =
{
	"_SelectCharNum",
	"select count(*) from tbl_char_static where us_uId = ?"
}
DefineSql(StmtDef,LoginServer)

--��һ���ʺŴ�����ɫ��Ŀ�ﵽ���ޣ�ɾ���ȼ�������ֵ��͵��Ǹ���ɫId
local StmtDef =
{
	"_DelLowerLevelChar",
	"delete from tbl_char where cs_uId = (select cs.cs_uId from tbl_char_static cs,tbl_char_basic cb ,tbl_char_experience ce where cs.cs_uId = cb.cs_uId and cb.cs_uId = ce.cs_uId and us_uId = ?  order by cb.cb_uLevel asc,ce.cs_uLevelExp asc limit 1)"
}
DefineSql(StmtDef,LoginServer)

--���ʺŴ����ﵽ���޵�ʱ��ɾ����ɫ���ȼ���͵ģ�
function LoginServerSql.UpperLimitDelChar(data)
	local us_uId 	= data["uid"]
	local char_num
	local char_set = LoginServer._SelectCharNum:ExecStat(cs_uId,us_uId)
	if char_set and char_set:GetRowNum() > 0 then
		char_num = char_set:GetData(0,0)
	end
	if char_num >= 20 then
		LoginServer._DelLowerLevelChar:ExecSql( "", us_uId )
	end
	local AllChar,res,ResTbl
	if g_DbChannelMgr:LastAffectedRowNum() > 0 then
		AllChar,res,ResTbl = LoginServerSql.GetDeletedCharList(data)
	else
		g_DbChannelMgr:CancelTran()
	end
	return AllChar,res,ResTbl
end

----------------------------------------------------------------------------------------------------
local StmtDef = {
    "_GetUserIDAndCampByCharID",
    [[
        select us_uId, cs_uCamp from tbl_char_static where cs_uId = ?
    ]]
}
DefineSql(StmtDef,LoginServer)


function LoginServerSql.GetBackRole(data)
	local cd_Id = data["id"]
	
    local ret = LoginServer._GetUserIDAndCampByCharID:ExecStat(cd_Id)
    local nUserID = ret:GetData(0,0)
    assert(nUserID)
    local nCamp   = ret:GetData(0,1) 
    local GasCreateRoleDB = RequireDbBox("GasCreateRoleDB")
    local suc, msgID = GasCreateRoleDB.CanCreateRoleAtRushRegisterActivity(nUserID, nCamp)
    if suc == false then
        return {false, msgID}
    end

	--���ݽ�ɫ�����ؽ�ɫid���жϸ������Ƿ��Ѿ�����
	--���ݽ�ɫ�����user id
	local cdname=LoginServer.SelectCdName:ExecSql("s[18]",cd_Id)
	local IfSame=LoginServer.SelectIfSame:ExecSql("n",cd_Id)
	local row = IfSame:GetRowNum()
	if 0 == row then
		LoginServer.Copy2DeletedChar:ExecSql("", cd_Id)
		LoginServer.Del_DelChar:ExecSql("", cd_Id)	
 	end
 return {true,row}
end
----------------------------------------------------------------------------------------------------
local StmtDef = {
    "_AddCharLeftTimeInfo",
    [[
       replace into tbl_char_lefttime(cs_uId,cl_dtLeftTime)
       values(?,unix_timestamp(now())+?)
    ]]
}
DefineSql(StmtDef,LoginServer)
function LoginServerSql.SaveCharLefttimeInfo(data)
	local char_id = data["char_id"]
	local left_time = data["left_time"]
	if left_time then
		LoginServer._AddCharLeftTimeInfo:ExecStat(char_id,left_time)
	end
end

local StmtDef = {
    "_GetAllCharLeftTimeInfo",
    [[
       select cs_uId
       from tbl_char_lefttime where unix_timestamp(now()) >= cl_dtLeftTime
    ]]
}
DefineSql(StmtDef,LoginServer)
function LoginServerSql.GetAllCharLeftTimeInfo(data)
		return LoginServer._GetAllCharLeftTimeInfo:ExecStat()
end

local StmtDef = {
    "_GetOneCharLeftTimeInfo",
    [[
       select count(1) 
       from tbl_char_lefttime where unix_timestamp(now()) >= cl_dtLeftTime and cs_uId = ?
    ]]
}
DefineSql(StmtDef,LoginServer)
function LoginServerSql.GetOneCharLeftTimeInfo(data)
		return LoginServer._GetOneCharLeftTimeInfo:ExecStat(data["char_id"])
end
-------------------------------------------------------------------------------------
function LoginServerSql.GetCharInfo(data)
	local CharId = data["char_id"]
	local account_id = data["account_id"]
	--��֤charid��userid�Ƿ��Ӧ
  local res = LoginServer._GetUserIDByCharID:ExecSql("n",CharId)
  if res:GetRowNum() == 0 then return end
  if res:GetData(0,0) ~= account_id then return end
	local ex = RequireDbBox("Exchanger")
	local res = LoginServer.GetCharInfo:ExecStat(CharId)
	LoginServer.InsertOnlineCharInfo:ExecStat(CharId)
	local CharacterMediatorDB = RequireDbBox("CharacterMediatorDB")
	local CharPostion = {}
	CharacterMediatorDB.CopyChangeToPos(data)
	CharPostion["MainSceneInfo"] 	= CharacterMediatorDB.GetMainScenePositionInfo(data)
	CharPostion["FbSceneInfo"] 		= CharacterMediatorDB.GetFbScenePositionInfo(data)	
	
    local GasCreateRoleDB = RequireDbBox("GasCreateRoleDB")
    local rushRegiAccountFlag = GasCreateRoleDB.GetServerRushRegiAccountFlag()
    
	return res, CharPostion, rushRegiAccountFlag
end

function LoginServerSql.PreChangePlayerName(data)
	local CharId = data.CharId
	local account_id = data.account_id
	--��֤charid��userid�Ƿ��Ӧ
  local res = LoginServer._GetUserIDByCharID:ExecSql("n",CharId)
  if res:GetRowNum() == 0 then return end
  if res:GetData(0,0) ~= account_id then return end
	local ex = RequireDbBox("Exchanger")
	local CharName = ex.getPlayerNameById(CharId)
	local nPos = string.find(CharName,"&")
	if nPos then
		--˵���˽�ɫ�ǺϷ�������ɫ
		return false
	end
	return true
end

local StmtDef = 
{
	"CheckIfNameDup",
	"select cs_uId from tbl_char where c_sName = ?"
}
DefineSql(StmtDef,LoginServer)



function LoginServerSql.GetDeledRoleName(data)

	local CharId = data.id
	local res = LoginServer._GetDeledRoleName:ExecSql("s[32]", CharId)
	if res:GetRowNum() == 0 then
		return {false}
	end
	local CharName = res:GetData(0,0)
	local res = LoginServer.CheckIfNameDup:ExecSql("n", CharName)
	if res:GetRowNum() > 0 then
		return {false}
	end
	return {true, CharName}
end

function LoginServerSql.ChangeCharName(data)
	local CharId = data.CharId
	local NewName = data.NewName
	local account_id = data.account_id
	--��֤charid��userid�Ƿ��Ӧ
  local res = LoginServer._GetUserIDByCharID:ExecSql("n",CharId)
  if res:GetRowNum() == 0 then return end
  if res:GetData(0,0) ~= account_id then return end
	local ex = RequireDbBox("Exchanger")
	local CharName = ex.getPlayerNameById(CharId)
	local nPos = string.find(CharName,"&")
	if not nPos then
		return 22
	end
  if string.find(NewName, "[#\\/' \"]") then
     return 23
  end
	
	if(string.len(NewName)<6 or string.len(NewName)>16) then
		return 24
	end
	
  if not (textFilter:IsValidName(NewName) and textFilter:IsValidMsg(NewName)) then
    return 25
  end
	local res = LoginServer.SelectCharInfo:ExecSql("n", NewName,NewName)
	local count = res:GetData(0,0)
	if count > 0 then
		return 27
	end
	LoginServer._UpdateCharName:ExecSql("",NewName,CharId)
	if g_DbChannelMgr:LastAffectedRowNum() == 0 then
		g_DbChannelMgr:CancelTran()
		return 26
	end
	return true
end



function LoginServerSql.IsUserTrust(userId)
	local result = LoginServer.GetUserTrustInfo:ExecStat(userId)
	if result:GetRowNum() > 0 then
		if (os.time() - result:GetData(0,1) ) < result:GetData(0,2)* 60 then
			--print("�й�ʣ��ʱ��" ,result:GetData(0,2) * 60  - (os.time() - result:GetData(0,1) ))
			return true
		else
			LoginServer.CancelUserTrust:ExecStat(userId)
		end
	end
end

function LoginServerSql.GetUserIdByCharName(charName)
	local userIdRet = LoginServer.FindUserIdByCharName:ExecStat(charName)
	if userIdRet:GetRowNum() > 0 then
		return userIdRet:GetData(0,0)
	end
end

function LoginServerSql.GetUserId(userName, gameId)
	local result = LoginServer.GetUserId:ExecStat(userName, gameId)
	if result:GetRowNum() > 0 then
		return result:GetData(0,0)
	end
end

function LoginServerSql.CheckUserTrust(data)
	local userId = LoginServerSql.GetUserId( data["UserName"], data["GameId"])
	if userId then
		return LoginServerSql.IsUserTrust(userId)
	end
end

function LoginServerSql.CheckTrusteeLogin(data)
	local charName = data["CharName"]
	local userId = LoginServerSql.GetUserIdByCharName(charName)
	if not userId then
		return -1 --�˽�ɫδ���й�
	end
	
	local result = LoginServer.GetUserTrustInfo:ExecStat(userId)
	if result:GetRowNum() > 0 and (os.time() - result:GetData(0,1) ) < result:GetData(0,2) * 60 then
		if result:GetData(0,0) ~= data["Password"]  then
			return  -2 --�й��������
		end 
		
		local userInfoRet = LoginServer.GetUserInfo:ExecStat(userId)
		
		return 1, userInfoRet:GetData(0,0), userInfoRet:GetData(0,1)
	else
		return  -1 --�˽�ɫδ���й�
	end
end

function LoginServerSql.UserTrust(data)
	local charName = data["CharName"]
	local userId = LoginServerSql.GetUserIdByCharName(charName)
	if not userId then
		return -1
	end
	local length = data["TrustLength"]
	local password = data["Password"] 
		
	LoginServer.UserTrust:ExecStat(userId, password, length)
	if g_DbChannelMgr:LastAffectedRowNum() > 0 then
		return 1
	else
		return -2
	end
end

function LoginServerSql.CancelUserTrust(data)
	local charName = data["CharName"]
	local userId = LoginServerSql.GetUserIdByCharName(charName)
	if not userId then
		return -1
	end
	LoginServer.CancelUserTrust:ExecStat(userId)
	if g_DbChannelMgr:LastAffectedRowNum() > 0 then
		return 1
	else
		return -2
	end
end


SetDbLocalFuncType(LoginServerSql.UpdatePasswd)
SetDbLocalFuncType(LoginServerSql.SelectPlayerInfoFromLocalDB)
SetDbLocalFuncType(LoginServerSql.GetAccountInfoFromDB)
SetDbLocalFuncType(LoginServerSql.GetAccountInfoFromName)
SetDbLocalFuncType(LoginServerSql.GetCharList)
SetDbLocalFuncType(LoginServerSql.GetDeletedCharList)
SetDbLocalFuncType(LoginServerSql.DelChar)
SetDbLocalFuncType(LoginServerSql.RoleNoDisplay)
SetDbLocalFuncType(LoginServerSql.SetUserAgreement)

return LoginServerSql
