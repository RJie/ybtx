engine_require "common/Misc/TypeCheck"
gas_require "framework/main_frame/GlobalChannel"
gas_require "entrance/logout/GasLogoutInc"
gas_require "framework/main_frame/GetTableFromExecuteSql"

--[[
��Ҫ����˵����
1.�û��˳���Ϸʱд�������Ϣ�����ݿ�: SaveLogout(nUserID)
2.��GBS�����˳���¼: BeginSendQuit2GBS()
3.�Թ̶�Ƶ�ʱ��浱ǰʱ�䣬�������û������ۼ�����ʱ�䣺SaveAndUpTime2DB(nUserID)
4.ֹͣ�����û������ۼ�����ʱ�䣺StopUpdateOnlineTime(UpOLTimeTick)
5.����������ʱ��������ϴ�û����GBS���˳���¼���������ڵ�������
  �����򿽱����ݵ������ͱ���: CopyUnSentRecord()
--]]

local LogoutServerDB = "LogoutServerDB"


function SaveLogout(nUserID)
	if not nUserID then
		LogErr("������˳�ʱ,�洢���ݿ���Ϣ����","��ҵ�IDΪ��")
	end
	--local logout_db = (g_DBTransDef["LogoutServerDB"])
	local data = { ["nUserID"] = nUserID }
	
	CallDbTrans(LogoutServerDB, "SaveLogoutInfo", nil, data, nUserID)
	--print("------------------>>> In SaveLogout()")
end


function DbCallBack:RegisterLogoutTick(userName,game_id)
	local function OnTick()
		local data = {}
		data["userName"] = userName
		data["game_id"] = game_id
		CallDbTrans("LoginQueueDB", "DelLogoutUserInfo", nil, data, userName)
	end
	RegisterOnceTick(g_App, "UserLogoutTick", OnTick, GasConfig.LogoutTime)
end

function DbCallBack:EProtocolLogOut(data, username)
	local function remote_callback(flag, msg)
		if not flag then
			LogErr("ERating Logout Fail", "user: " .. username .. ", msg: " .. msg)
		end
	end
	if g_EProtocol and g_EProtocol.m_bConnected == true then
		g_EProtocol:UserLogout(data, remote_callback)
	end
end

--------------------------------------------------------------------------------------
--��GBS�����˳���¼
--------------------------------------------------------------------------------------

--[[
����ֵ��0-�������Է��ͼ�¼
        1-�����Է��ͼ�¼
        2-���һ��ʱ�����Է��ͼ�¼
--]]


--�����˳���¼��GBS
--���ݿ�coroutine func
function SendQuitRecord()
	local function Callback(result)
	
		local num = result:GetRowNum()
		for i = 1, num do
			local data = {result(i,1),result(i,2),result(i,3),result(i,4),result(i,5),result(i,6),result(i,7)}
			local function remote_callback(flag, msg)
				if not flag then
					return
				end
			end
			
			if next(data) and g_EProtocol.m_bConnected == true then
				g_EProtocol:UserLogout(data, remote_callback)
			end
		end
	end
	CallDbTrans(LogoutServerDB, "SendQuitRecord", Callback, {["CurServerId"] = g_CurServerId}, GlobalChannel.server_var)
end

function CSaveAndUpTime:new(nUserID)
	local sut	= CSaveAndUpTime:__new()
	sut.m_nUserID = nUserID
	sut.m_bStopUpOLTime = false
	return sut
end

--���ʱ��һ�����ʹ������ݿ�coroutine���浱ǰʱ�䣬���Ҹ����û������ۼ�����ʱ��
function CSaveAndUpTime:OnTick()
	--print("------->>>CSaveAndUpTime:OnTick()")
	local data = {['user']=self.m_nUserID, ['time'] = self.m_bStopUpOLTime }
	--local logout_db = (g_DBTransDef["LogoutServerDB"])
	CallDbTrans(LogoutServerDB, "SaveAndUpTime", nil, data, self.m_nUserID)
end

function SaveAndUpTime2DB(nUserID)
	--print("------------>>>In SaveAndUpTime2DB()")
	local sut = CSaveAndUpTime:new(nUserID)
	g_App:RegisterTick(sut,5*60*1000)
	sut:SetTickName("CSaveAndUpTime")
	return sut
end

function StopUpdateOnlineTime(UpOLTimeTick)
	--print("------------>>>In StopUpdateOnlineTime()")
	UnRegisterTick(UpOLTimeTick)
end

--------------------------------------------------------------------------------------
--����������ʱ��������ϴ�û����GBS���˳���¼���������ڵ�����
--------------------------------------------------------------------------------------
-- ����������ʱ����tbl_user_online���ϴ�û�������͵��˳���¼���Ƶ���tbl_auth_logout���Է��͵�GBS
function CopyUnSentRecord()
	--print("------------>>>In CopyUnSentRecord()")
	--ȡ��ʱ��

	--local logout_db = (g_DBTransDef['LogoutServerDB'])
	CallDbTrans(LogoutServerDB, "CopyUnSentRecord", nil, {["CurServerId"] = g_CurServerId}, GlobalChannel.server_var)
end
