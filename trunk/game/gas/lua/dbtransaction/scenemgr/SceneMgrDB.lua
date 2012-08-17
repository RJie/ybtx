gac_gas_require "scene_mgr/SceneCfg"
cfg_load "fb_game/FbActionDirect_Common"
cfg_load "fb_game/MercenaryMonsterFbCountLimit_Server"
gac_gas_require "activity/scene/AreaFbSceneMgr"
cfg_load "fb_game/FbActionCheckItem_Server"

local FbActionCheckItem_Server = FbActionCheckItem_Server
gas_require "world/tong_area/TongFbMgr"
local g_TongFbMgr = g_TongFbMgr

gac_gas_require "framework/common/CMoney"


local MainSceneTbl = nil
local IsGasStart = false

local ShowErrorMsgAndExit = ShowErrorMsgAndExit
local MercenaryMonsterFbCountLimit_Server = MercenaryMonsterFbCountLimit_Server
local Scene_Common = Scene_Common
local FbActionDirect_Common = FbActionDirect_Common
local AreaFb_Common = AreaFb_Common
local g_AreaFbSceneMgr = g_AreaFbSceneMgr
local g_AreaFbLev = g_AreaFbLev
local SceneMgr = class()
local g_MoneyMgr = CMoney:new()
local event_type_tbl = event_type_tbl
--local g_SceneMgr = CSceneMgr:new()
local SceneMgrSql = CreateDbBox(...)

--local g_GetPlayerInfo = g_GetPlayerInfo

local StmtDef=
{
 "CreateNewWarZone",
 "insert into tbl_war_zone(sc_uId, wz_uId, wz_dtCreateTime) values(?,?,now())"
}
DefineSql(StmtDef,SceneMgr)

local StmtDef =
{
	"SqlGetMetaId",
	"select sc_uId, sc_uServerId, unix_timestamp(sc_dtCreationDateTime) from tbl_scene where sc_sSceneName = ?"
}
DefineSql(StmtDef,SceneMgr)

local StmtDef =
{
	"GetAllServerScene",
	"select distinct sc_sSceneName, sc_uType from tbl_scene"
}
DefineSql(StmtDef,SceneMgr)

local StmtDef =
{
	"SqlGetMainScene",
	"select sc_uId,sc_sSceneName,sc_uProcess, sc_uServerId from tbl_scene where sc_uType = 1 or sc_uType = 7"
}
DefineSql(StmtDef,SceneMgr)

local StmtDef =
{
	"GetSceneServerId",
	"select sc_uServerId from tbl_scene where sc_uType = 7"
}
DefineSql(StmtDef,SceneMgr)

local StmtDef =
{
	"SqlGetSceneName",
	"select sc_sSceneName from tbl_scene where sc_uId = ?"
}
DefineSql(StmtDef,SceneMgr)

local StmtDef =
{
	"SqlGetSceneInfo",
	"select sc_sSceneName, sc_uType, sc_uProcess, sc_uServerId from tbl_scene where sc_uId = ?"
}
DefineSql(StmtDef,SceneMgr)

local StmtDef =
{
	"SqlGetSceneType",
	"select sc_uType from tbl_scene where sc_uId = ?"
}
DefineSql(StmtDef,SceneMgr)

local StmtDef =
{
	"SqlInsertScene",
	"insert into tbl_scene ( sc_dtCreationDateTime, sc_dtLastActiveDateTime, sc_sSceneName, sc_uProcess, sc_uServerId, sc_uType) values( now(), now(), ?, ?,?,?)"
}
DefineSql(StmtDef,SceneMgr)

local StmtDef =
{
	"SqlDeleteScene",
	"delete from tbl_scene where sc_uId = ?"
}
DefineSql(StmtDef,SceneMgr)

local StmtDef =
{
	"DeleteAllSceneByName",
	"delete from tbl_scene where sc_sSceneName = ?"
}
DefineSql(StmtDef,SceneMgr)

local StmtDef =
{
	"DeleteAllFbScene",
	"delete from tbl_scene where sc_uType <> 1 and sc_uType<> 6 and sc_uType <> 7 and sc_uServerId = ?"
}
DefineSql(StmtDef,SceneMgr)

local StmtDef =
{
	"ClearAllTongSceneByServerId",
	"update tbl_scene set sc_uServerId = 0 where sc_uType = 6 and sc_uServerId = ?"
}
DefineSql(StmtDef,SceneMgr)

local StmtDef =
{
	"SetSceneServer",
	"update tbl_scene set sc_uServerId = ? where sc_uId = ?"
}
DefineSql(StmtDef,SceneMgr)

local StmtDef = 
{
	"GetTongSceneId",
	"select sc_uId,sc_uServerId from tbl_scene where sc_uType = 6 and sc_uProcess  = ?"
}
DefineSql(StmtDef, SceneMgr)

local StmtDef = 
{
	"GetSceneServerPos",
	"select sc_uServerId from tbl_scene where sc_uId = ?"
}
DefineSql(StmtDef, SceneMgr)

local StmtDef = 
{
	"GetMainSceneList",
	[[
		select
			sc_uId, sc_sSceneName
		from
			tbl_scene
		where
			(sc_sSceneName = ? or sc_sSceneName = ? or sc_sSceneName = ?) and sc_uType = 1
	]]
}
DefineSql(StmtDef,SceneMgr)

local StmtDef = 
{
	"DelTongSceneId",
	"delete  from tbl_scene where sc_uType = 6 and sc_uProcess  = ?"
}
DefineSql(StmtDef, SceneMgr)

local StmtDef = 
{
	"MovePlayerPosition",
	[[
	update 
		tbl_char_position as cp, tbl_char_static as cs, tbl_scene as s
	set
		cp.sc_uId = ?,
		cp.cp_uPosX = ?,
		cp.cp_uPosY = ?
	where
		s.sc_sSceneName = ? and
		cp.sc_uId = s.sc_uId and
		cp.cs_uId = cs.cs_uId and
		cs.cs_uCamp = ? 
	]]
}
DefineSql(StmtDef,SceneMgr)


local StmtDef = 
{
	"IsEnteredScene",
	"select count(*) from tbl_char_entered_scene where cs_uId = ? and sc_uId = ?"
}
DefineSql(StmtDef,SceneMgr)

local StmtDef = 
{
	"SaveEnterScenePlayer",
	"insert ignore into tbl_char_entered_scene(cs_uId, sc_uId) values(?, ?)"
}
DefineSql(StmtDef,SceneMgr)

local StmtDef = 
{
	"DelEnterScenePlayer",
	"delete from tbl_char_entered_scene where cs_uId = ?"
}
DefineSql(StmtDef,SceneMgr)

local StmtDef=
{
	"GetSceneOtherArg",
	"select sa_sArgName, sa_sArgValue, sa_nArgValue from tbl_scene_arg where sc_uId = ?"
}
DefineSql(StmtDef,SceneMgr)

local StmtDef=
{
	"InsertSceneStringArg",
	"insert into tbl_scene_arg(sc_uId, sa_sArgName, sa_sArgValue) values(?,?,?)"
}
DefineSql(StmtDef,SceneMgr)

local StmtDef=
{
	"InsertSceneNumberArg",
	"insert into tbl_scene_arg(sc_uId, sa_sArgName, sa_nArgValue) values(?,?,?)"
}
DefineSql(StmtDef,SceneMgr)


local StmtDef=
{
	"GetCharChangeToScene",
	"select sc_uId from tbl_char_change_position where cs_uId = ?"
}
DefineSql(StmtDef,SceneMgr)

local StmtDef=
{
	"GetCharFbScene",
	"select sc_uId from tbl_char_fb_position where cs_uId = ?"
}
DefineSql(StmtDef,SceneMgr)

local StmtDef=
{
	"GetCharMainScene",
	"select sc_uId from tbl_char_position where cs_uId = ?"
}
DefineSql(StmtDef,SceneMgr)

local StmtDef = 
{
	"GetLeastPlayerFbScene",
	[[
		select 
			tbl_scene.sc_uId, tbl_scene.sc_uServerId, count(fp.cs_uId) as playerNum
		from 
			tbl_scene left join tbl_char_fb_position as fp on(tbl_scene.sc_uId = fp.sc_uId)
		where tbl_scene.sc_sSceneName = ?
			group by tbl_scene.sc_uId
	]]
}
DefineSql(StmtDef, SceneMgr)

local StmtDef = 
{
	"GetLeastPlayerChangeScene",
	[[
		select 
			tbl_scene.sc_uId, tbl_scene.sc_uServerId, count(fp.cs_uId) as playerNum
		from 
			tbl_scene left join tbl_char_change_position as fp on(tbl_scene.sc_uId = fp.sc_uId)
		where tbl_scene.sc_sSceneName = ?
			group by tbl_scene.sc_uId
	]]
}
DefineSql(StmtDef, SceneMgr)

local StmtDef = 
{
	"UpdateTongSceneServerId",
	[[
		update tbl_scene set sc_uServerId = ?
		where sc_uId = ?
		and sc_uType = 6
	]]
}
DefineSql(StmtDef, SceneMgr)

local StmtDef =
{
	"SqlDeleteSceneByType",
	"delete from tbl_scene where sc_uType = 26"
}
DefineSql(StmtDef,SceneMgr)

local StmtDef =
{
	"SqlSceneId",
	"select sc_uId from tbl_scene where sc_uType = 26"
}
DefineSql(StmtDef,SceneMgr)

local StmtDef = 
{
	"GetSceneCfgServerId",
	"select sc_uServerId from tbl_scene_distribute where sc_sSceneName = ?"
}
DefineSql(StmtDef,SceneMgr)

local StmtDef = 
{
	"GetSceneInfoByName",
	"select sc_uId, sc_uServerId from tbl_scene where sc_sSceneName = ?"
}
DefineSql(StmtDef,SceneMgr)

local MapInfo = {
		{"ʷ������",272,375},
		{"��³��",90,129},
		{"������",127,141},
		}
		

local DefaultServerId = -1
local function GetDefaultServerId()
	if DefaultServerId ~= -1 then
		return DefaultServerId
	end
	local GasMainDB = RequireDbBox("GasMainDB")
	local ServerAttribute = GasMainDB.GetServerAttribute()
	local serverList = GasMainDB.GetServerList()
	
	for i, serverId in pairs(serverList) do
		if not (ServerAttribute[serverId] and ServerAttribute[serverId].IsNoMainScene) then
			if serverId > DefaultServerId then
				DefaultServerId = serverId
			end
		end
	end
	assert(DefaultServerId ~= -1)
	return DefaultServerId
end
		
local function GetSceneCfgServerId(sceneName)
	local result = SceneMgr.GetSceneCfgServerId:ExecStat(sceneName)
	if result:GetRowNum() > 0 then
		return result:GetData(0,0)
	else
		return GetDefaultServerId()
	end
end
		
local function DeleteSceneByType()
	local res = SceneMgr.SqlSceneId:ExecSql()
	local tbl = {}
	local num = res:GetRowNum()
	if num > 0 then
		for i = 0, num - 1 do
			table.insert(tbl, res:GetData(i,0))
		end
	end
	SceneMgr.SqlDeleteSceneByType:ExecSql()
	return tbl
end
		
local function MovePlayerToMainScene(MapInfo ,sceneName)
	for camp = 1, 3 do
		SceneMgr.MovePlayerPosition:ExecSql('',MapInfo[MapInfo[camp][1]], MapInfo[camp][2], MapInfo[camp][3], sceneName, camp)
	end
end

function SceneMgrSql.CheckScene()
	local allScene = SceneMgr.GetAllServerScene:ExecSql("s[32]n")
	if allScene:GetRowNum() == 0 then
		return
	end
	
	local mainScene = SceneMgr.GetMainSceneList:ExecSql("ns[32]",MapInfo[1][1],MapInfo[2][1],MapInfo[3][1])
	local mainSceneCount = 0
	for i = 0, mainScene:GetRowNum()-1 do
		local sceneID = mainScene:GetData(i, 0)
		local sceneName = mainScene:GetData(i, 1)
		MapInfo[sceneName] = sceneID
		mainSceneCount = mainSceneCount + 1
	end
	assert(mainSceneCount == 3, "ȱ��3����Ӫ������")
	
	for i = 0, allScene:GetRowNum() -1 do
		local sceneName = allScene:GetData(i, 0)
		local sceneType = allScene:GetData(i, 1)
		if not Scene_Common[sceneName] then--������ɾ��
			print("���� [" .. sceneName .. "] ��ɾ��")
			if sceneType == 1 or sceneType == 7 then
				print("����֮ǰΪ������, ��ԭ���ڴ˳���������Ƶ�����Ӫ���� ")
				MovePlayerToMainScene(MapInfo, sceneName)
			end
			SceneMgr.DeleteAllSceneByName:ExecSql( "", sceneName)
		else
			local cfgType = Scene_Common[sceneName].SceneType
			if sceneType ~= cfgType then --���ͱ���
				if sceneType == 1 or sceneType == 7 then
					print("���� [" .. sceneName .. "] ����������ɸ���, ��ԭ���ڴ˳���������Ƶ�����Ӫ���� ")
					MovePlayerToMainScene(MapInfo, sceneName)
					SceneMgr.DeleteAllSceneByName:ExecSql( "", sceneName)
				elseif cfgType == 1 or cfgType == 7 then
					print("���� [" .. sceneName .. "] �ɸ������������")
					SceneMgr.DeleteAllSceneByName:ExecSql( "", sceneName)
				end
			end
		end
	end
end

function SceneMgrSql.SetStartMark(mark)
	IsGasStart = mark
end

--�������з����� ����ǰ������������
function SceneMgrSql._ClearAllFbScene(serverId)
	SceneMgr.ClearAllTongSceneByServerId:ExecSql( "", serverId) --��ḱ������ɾ��,��Ҫ������Ϊδ���������״̬
	SceneMgr.DeleteAllFbScene:ExecSql( "",serverId)

	SceneMgrSql.CheckScene()
	
	local GasMainDB = RequireDbBox("GasMainDB")
	local ServerAttribute = GasMainDB.GetServerAttribute()

	for sceneName, Arg in pairs(Scene_Common)do
		if Arg.SceneType == 1 then  --��ͨ���������ǣ�Ԥ�������ݿⴴ��
			--��Ϊ�п��ܲ߻���ʱ�����ñ��������ͨ����������ÿ�η���������ʱ���һ��
			--��������ݿ��в������򴴽�
			local dbSceneId, dbServerId  = SceneMgrSql._GetNormalSceneIdByName( sceneName )
			local cfgServerId = GetSceneCfgServerId(sceneName)
			if ServerAttribute[cfgServerId] and ServerAttribute[cfgServerId].IsNoMainScene then  --�˷�����
				ShowErrorMsgAndExit( cfgServerId .. " �ŷ���������������������")
			end
			if dbSceneId == nil then
				local data =
				{
					["SceneName"] = sceneName,
					["ServerId"] = cfgServerId,
					["Proc"] = 0
				}
				SceneMgrSql._CreateScene( data )
			elseif dbServerId ~= cfgServerId then
				print("���� [" .. sceneName .. "] ����ķ������� " .. dbServerId  .. "��� " .. cfgServerId)
				SceneMgr.SetSceneServer:ExecSql('', cfgServerId, dbSceneId)
			end
		end
	end
	
	--����ս��
	local id = 1
	local baseName = "����ƽԭ"
	while true do
		local sceneName = baseName ..  id
		if Scene_Common[sceneName] then
			local dbSceneId, dbServerId  = SceneMgrSql._GetNormalSceneIdByName( sceneName )
			local cfgServerId = GetSceneCfgServerId(sceneName)
			if dbSceneId == nil then
				local data =
				{
					["SceneName"] = sceneName,
					["ServerId"] = GetSceneCfgServerId(sceneName),
					["Proc"] = id
				}
				local sceneId = SceneMgrSql._CreateScene( data )
				SceneMgr.CreateNewWarZone:ExecSql('', sceneId, id)
				print ("�����ս��" .. id)
			elseif dbServerId ~= cfgServerId then
				SceneMgr.SetSceneServer:ExecSql('', cfgServerId, dbSceneId)
			end
		else
			break
		end
		id = id + 1
	end
end

function SceneMgrSql.GetSceneServerId(data)
	local sceneId = data["sceneId"]
	local result = SceneMgr.SqlGetSceneType:ExecSql('', sceneId)
	if result:GetRowNum() == 0 then
		return
	end
	local SceneType = result:GetData(0,0)
	local serverIdTbl = {}
	if SceneType == 7 then
		local ret = SceneMgr.GetSceneServerId:ExecSql()
		local rowNum = ret:GetRowNum()
		if rowNum > 0 then
			for i=0, rowNum-1 do
				serverIdTbl[i] = ret:GetData(i,0)
			end
		end
	end
	for i=0,#serverIdTbl do
		for k=i+1,#serverIdTbl do
			if serverIdTbl[i] == serverIdTbl[k] then
				serverIdTbl[i] = nil
			end
		end
	end
	return serverIdTbl
end

function SceneMgrSql.GetSceneServerPos(sceneId)
	local result = SceneMgr.GetSceneServerPos:ExecSql('n', sceneId)
	if result:GetRowNum() == 0 then
		return
	end
	local serverId = result:GetData(0,0)
	result:Release()
	return serverId
end

function SceneMgrSql.SetSceneServer(sceneId, serverId)
	SceneMgr.SetSceneServer:ExecSql('', serverId, sceneId)
end

function SceneMgrSql.SetSceneServerRpc(data)
	SceneMgr.SetSceneServer:ExecSql('', data["ServerId"], data["SceneId"])
end

function SceneMgrSql._GetMainScene()
	local ret = SceneMgr.SqlGetMainScene:ExecSql( "ns[32]nn" )
	return ret:ToTable(true)
end

function SceneMgrSql._DeleteScene( data )
	SceneMgr.SqlDeleteScene:ExecSql( "", data[1] )
end

function SceneMgrSql._GetSceneNameById( uSceneId )
	local res = SceneMgr.SqlGetSceneName:ExecSql( "s[32]", uSceneId )
	local ret = res:GetData(0,0)
	res:Release()
	return ret
end

local function GetMainSceneFromDbByName(sSceneName)
	local res = SceneMgr.SqlGetMetaId:ExecSql( "nn", sSceneName )
	local num = res:GetRowNum()
	local sceneId, serverId
	if num > 0 then
		assert(num == 1, "GetMainSceneFromDbByName ֻ��ѯ������Ψһ�ĳ��� ��[" .. sSceneName .. "] ���ڶ��")
		sceneId, serverId = res:GetData(0,0), res:GetData(0,1)
	end
	res:Release()
	return sceneId, serverId
end

function SceneMgrSql._GetNormalSceneIdByName( sSceneName )
	if IsGasStart then --������ֱ�Ӳ�ѯ���ݿ�����, ��Ϊ�����ᴴ���µ�������,  
		                 ---������Ϻ�(������������) ��һ�ε��øú��������ݿ�,Ȼ�󱣴浽�ֲ�,֮��Ͳ������ݿ���
		return GetMainSceneFromDbByName(sSceneName)
	end
	if not MainSceneTbl then
		local ret = SceneMgr.SqlGetMainScene:ExecStat()
		MainSceneTbl = {}
		for i = 0, ret:GetRowNum() -1 do
			MainSceneTbl[ret:GetData(i,1)] = ret:GetRowSet(i+1)
		end
	end
	local  tbl = MainSceneTbl[sSceneName]
	assert(tbl, "�����ڵ�������: " .. sSceneName)
	return tbl(1), tbl(4)
end

-- function SceneMgrSql:GetSceneFromDbByName(sSceneName)
function SceneMgrSql.GetSceneFromDbByName(sSceneName)
	local res = SceneMgr.SqlGetMetaId:ExecStat( sSceneName )
	local tbl = {}
	if res and res:GetRowNum()>0 then
		for i=0, res:GetRowNum()-1 do
			table.insert(tbl, {res:GetData(i,0), res:GetData(i,1), res:GetData(i,2)})
		end
	end
	return tbl
end

function SceneMgrSql._GetLastInsertID()
	return g_DbChannelMgr:LastInsertId()
end

function SceneMgrSql._CreateScene( data )
	local sceneName = data["SceneName"]
	assert(Scene_Common[sceneName], "��ͼ����һ������ Scene_Common �ڵĳ���  " .. sceneName)
	local type = Scene_Common[sceneName].SceneType
	local serverId = data["ServerId"]
	if type == 1 or type == 7 then
		local dbSceneId, dbServerId = SceneMgrSql._GetNormalSceneIdByName( sceneName )
		if dbSceneId then
			return dbSceneId, dbServerId
		end
		assert(serverId and serverId == GetSceneCfgServerId(sceneName), "������������ս���������봫ָ��������")
	end
	
	if not serverId then --û�����ѯһ�����ʷ�����
		local MultiServerDB = RequireDbBox("MultiServerDB")
		serverId = MultiServerDB.GetIdleServer()
	end
	
	SceneMgr.SqlInsertScene:ExecSql("", sceneName, data["Proc"] or 0 ,serverId, type)
	if g_DbChannelMgr:LastAffectedRowNum() > 0 then
		local g_LogMgr = RequireDbBox("LogMgrDB")
		local sceneId = SceneMgrSql._GetLastInsertID()
		if data["OtherArg"] then
			SceneMgrSql.SaveSceneOtherArg(sceneId, data["OtherArg"])
		end
		g_LogMgr.CreateScene(sceneId, sceneName)
		return sceneId, serverId
	end
end


function SceneMgrSql.GetPlayerCurScene(charId)
	local sceneId
	local changeToScene = SceneMgr.GetCharChangeToScene:ExecSql("n", charId)
	if changeToScene:GetRowNum() > 0 then
		sceneId = changeToScene:GetData(0,0)
		changeToScene:Release()
		return sceneId
	end
	
	changeToScene:Release()
	local fbScene = SceneMgr.GetCharFbScene:ExecSql("n",charId)
	if fbScene:GetRowNum() > 0 then
		sceneId = fbScene:GetData(0,0)
		fbScene:Release()
		return sceneId
	end
	fbScene:Release()
	
	local mainScene = SceneMgr.GetCharMainScene:ExecSql("n",charId)
	sceneId = mainScene:GetData(0,0)
	mainScene:Release()
	return sceneId
end

function SceneMgrSql.DaDuoBaoChangeScene(data)
	local PlayerId = data["charId"]
	--����Ǯ
	local MoneyNum = data["MoneyNum"] * (-1)
	local MoneyManagerDB =	RequireDbBox("MoneyMgrDB")
	local fun_info = g_MoneyMgr:GetFuncInfo("fuben")
	local bFlag,uMsgID = MoneyManagerDB.AddMoney(fun_info["FunName"],fun_info["Daduobao"],PlayerId, MoneyNum,nil,event_type_tbl["��ᱦ��Ǯ"])
	if not bFlag then
		CancelTran()
		if IsNumber(uMsgID) then
			return bFlag,uMsgID
		else
			return false,3501
		end
	end
	local SceneId, ServerId = SceneMgrSql._CreateScene( data )
	if not SceneId then
		return false
	end
	return true, SceneId, ServerId
end

function SceneMgrSql.GetOrCreateTongScene(tongId, isSetServerId)
	local TongBasicDB = RequireDbBox("GasTongBasicDB")
	if TongBasicDB.CountTongByID(tongId) == 0 then --����Ѿ�������
		return
	end
	
	local Camp = TongBasicDB.GetTongCampByID(tongId)
	if Camp == 0 then
		return
	end
	
	local res = SceneMgr.GetTongSceneId:ExecSql( "nn", tongId)
	local num = res:GetRowNum()
	if num == 0 then
		res:Release()
		local data = {}
		data["SceneName"] = g_TongFbMgr.m_TongSceneName[Camp]
		data["Proc"] = tongId
		local otherArg = {}
		otherArg["m_Process"] = tongId	
		data["OtherArg"] = otherArg
		if not isSetServerId then
			data["ServerId"] = 0
		end
		return SceneMgrSql._CreateScene(data)
	end
	local sceneId, serverId = res:GetData(0,0), res:GetData(0,1)
	res:Release()
	if serverId == 0 and isSetServerId then
		local MultiServerDB = RequireDbBox("MultiServerDB")
		serverId = MultiServerDB.GetIdleServer()
		SceneMgr.SetSceneServer:ExecSql('', serverId, sceneId)
	end
	return sceneId,  serverId
end

function SceneMgrSql.SaveSceneOtherArg(sceneId, OtherArg)
	for argName, value in pairs(OtherArg) do
		if IsNumber(value) then
			SceneMgr.InsertSceneNumberArg:ExecSql("", sceneId, argName, value)
		else--if IsString(value) then
			SceneMgr.InsertSceneStringArg:ExecSql("", sceneId, argName, value)
		end
	end
end

function SceneMgrSql.GetSceneOtherArg(sceneId, process)
	local data = {}
	data["m_Process"] = process
	local result = SceneMgr.GetSceneOtherArg:ExecSql("ssn", sceneId)
	for i = 0, result:GetRowNum() -1 do
		--print("SceneOtherArg" , result:GetData(i,1) , result:GetData(i,2))
		data[result:GetData(i,0)] = result:GetData(i,1) or result:GetData(i,2)
	end
	result:Release()
	return data
end

function SceneMgrSql.IsSceneExistent(data)
	local sceneId = data["sceneId"]
	local serverId = data["serverId"]
	local result = SceneMgr.SqlGetSceneInfo:ExecSql('snnn', sceneId)
	if result:GetRowNum() > 0 then
		local sceneName, type, process, dbServerId  = result:GetData(0,0), result:GetData(0,1), result:GetData(0,2), result:GetData(0,3)
		if type == 6 then --����ǰ�ḱ������
			SceneMgr.UpdateTongSceneServerId:ExecStat(serverId, sceneId)
			dbServerId = serverId
		end
		assert(dbServerId == serverId, "�г��� serverId �����ݿⲻһ�� ������" .. tostring(sceneName) .. "  ���ݿ�:" .. tostring(dbServerId) .. " �ڴ�:" .. tostring(serverId))
		result:Release()
		local otherArg = SceneMgrSql.GetSceneOtherArg(sceneId, process)
		return true, sceneName, otherArg
	else
		result:Release()
		return false
	end
end

--�Ƿ�����������ø���
function SceneMgrSql.IsEnteredScene(charId, sceneId)
	local result = SceneMgr.IsEnteredScene:ExecSql("n", charId, sceneId)
	local count = result:GetData(0,0)
	result:Release()
	return count ~= 0
end
 
--������ɾ����Ʊ����.(������ñ���û������,��ֱ�ӿɽ�)
function SceneMgrSql.DeleteItemFromInScene(charId, sceneName, IsCheck)
	local g_RoomMgr = RequireDbBox("GasRoomMgrDB")
	local CheckCfg = FbActionCheckItem_Server(sceneName)
	if CheckCfg then
		local ExChanger = RequireDbBox("Exchanger")
		local name = ExChanger.getPlayerNameById(charId)
			
		local TongLevel = CheckCfg("TongLevel")
		if IsNumber(TongLevel) and TongLevel > 0 then
			local TongBasicBoxDB = RequireDbBox("GasTongBasicDB")
			
			local TongID = TongBasicBoxDB.GetTongID(charId)
			if TongID ~= 0 then
				local tongLev = TongBasicBoxDB.GetTongLevel(TongID)
				if tongLev < TongLevel then
					return false, {191041, name}
				end
			else
				return false, {191042, name}
			end
		end
		
		local ItemInfo = loadstring("return {" .. CheckCfg("Item") .."}")()
		if ItemInfo then
			
			local droptype = ItemInfo[1]
			local dropname = ItemInfo[2]		--�������Ʒ��
			local havenum = g_RoomMgr.GetItemCount(charId,droptype,dropname)
			if havenum > 0 then
				if not IsCheck then
					local res = g_RoomMgr.DelItem(charId, droptype,dropname,1,nil,event_type_tbl["����Ʒ���ߵ�����Ʒɾ��"])
					if IsNumber(res) then
						CancelTran()
						return false, {3089} --"������Ʒɾ��ʧ��"
					end
					
				--	Db2CallBack("OnDeleteActionItem", charId, {droptype,dropname,1,res})
				end
				return true
			else
				return false, {38, name, dropname}--û����ص���Ʒ
			end
			
		end
	end
	return true
end

local function ChangeTongSceneCheck(charId, sceneId, sceneName, sceneProc) 
	return true
end

local function ChangeAreaFbSceneCheck(charId, sceneId, sceneName, sceneProc)
	if SceneMgrSql.IsEnteredScene(charId, sceneId) then  --������Ͳ��ü����
		return true
	end
	
	local ActivityCountDB = RequireDbBox("ActivityCountDB")

--	local GasTeamDB =  RequireDbBox("GasTeamDB")
--	local teamId = GasTeamDB.GetTeamID(charId)
--	
--	if teamId ~= 0 then
--		local data = {}
--		data["PlayerTbl"] = {}
--		local tblMembers = GasTeamDB.GetTeamOnlineMembersId(teamId)
--		-- ֻ�жӳ����ܱ���
--		local captain = GasTeamDB.GetCaptain(teamId)
--		if charId ~= captain then
--			return false, {4}
--		end
--			
--		for i = 1, #(tblMembers) do
--			local MemberID = tblMembers[i]
--			data.PlayerTbl[MemberID] = true
--			local CharacterMediatorDB =  RequireDbBox("CharacterMediatorDB")
--			if g_AreaFbLev[sceneName] > CharacterMediatorDB.GetPlayerLevel(MemberID) then
--				local ex = RequireDbBox("Exchanger")
--				local MemberName = ex.getPlayerNameById(MemberID)
--				-- ��ԱXXX�ĵȼ�������С�ӱ���ʧ�ܡ�
--				--print("��Ա"..MemberName.."�ĵȼ�������С�ӱ���ʧ�ܡ�")
--				return false, {5, MemberID}
--			end	
--		end
--		
--		data["ActivityName"] = AreaFb_Common(sceneName, "LimitType")
--		local result, MemberID = ActivityCountDB.CheckMultiPlayerActivityCount(data)
--		if not result then
--			local ex = RequireDbBox("Exchanger")
--			local MemberName = ex.getPlayerNameById(MemberID)
--			-- ��ԱXXX�Ѿ������˸õ��³ǵĽ����޴Σ�С�ӱ���ʧ�ܡ�
--			--print("��Ա "..MemberName.." �Ѿ�������"..GetSceneDispalyName(sceneName).."�Ľ����޴Σ�С�ӱ���ʧ�ܡ�")
--			return false, {6, MemberID}
--		end
--	
--	end
		
	-- �ȼ���������͵ĸ���
	local ResetMode = g_AreaFbSceneMgr.ResetMode[sceneName]
	if ResetMode[1] == 1 then
		local isCan, Maxcount = ActivityCountDB.CheckAreaFbCount(charId, sceneName)
		if not isCan then
			return false, {2}
		end
	elseif ResetMode[1] == 2 then
		local isCan = ActivityCountDB.CheckCoolDownAreaFbCount(charId, sceneName)
		if not isCan then
			return false, {3}
		end		
	end
	
	--local LimitType = AreaFb_Common(sceneName, "LimitType")
	local ActionName = AreaFb_Common(sceneName, "ActionName")
	--local LimitType = FbActionDirect_Common(ActionName, "MaxTimes")
	--local isCan, Maxcount = ActivityCountDB.CheckFbActionCount(charId, "���³�̽��")
	local isCan, Maxcount = ActivityCountDB.CheckFbActionCount(charId, ActionName)
	if not isCan then
		return isCan, {1}
	else
		return isCan
	end
end

local function ChangeMatchGameCheck(charId, sceneId, sceneName, sceneProc)
	return SceneMgrSql.DeleteItemFromInScene(charId, sceneName)
end

local function ChangeMercenaryMonsterFbSceneCheck(charId, sceneId, sceneName, sceneProc, count, IsCheck)
	if SceneMgrSql.IsEnteredScene(charId, sceneId) then  --������Ͳ��ü����
		return true
	end
	local ActionName = "Ӷ����ˢ�ֱ�"
	if IsCheck then
		local ActivityCountDB = RequireDbBox("ActivityCountDB")
		local IsSucc,Times = ActivityCountDB.CheckFbActionCount(charId, ActionName, count)
		if not IsSucc then
			local msgId = 191019
			local limitType = FbActionDirect_Common(sceneName, "MaxTimes")
			if JoinCountLimit_Server(limitType, "Cycle") == "week" then
				msgId = 191020
			end
			return false, {msgId, "", ActionName}
		end
	end
	
	return SceneMgrSql.DeleteItemFromInScene(charId, sceneName, IsCheck)
end

--�������Բ�ͬ���ͳ��� �������ʱ�ļ��,ɾ��Ʒ,��Ǯ����ز���, 
--����ֵ(isSucceed, msgId),  ����(charId, sceneId, sceneName, sceneProc) 
local ChangeSceneDoFun = 
{
	--[SceneType] = CheckAndDoSomethingFun,
	[5] = ChangeAreaFbSceneCheck,
	[6] = ChangeTongSceneCheck,
	[13] = ChangeMatchGameCheck,
	[21] = ChangeMercenaryMonsterFbSceneCheck,
}
 

function SceneMgrSql.ChangeScene(data)
	local sceneId = data["scene_id"]
	local result = SceneMgr.SqlGetSceneInfo:ExecSql('s[32]nnn', sceneId)
	if result:GetRowNum() <= 0 then
		result:Release()
		return nil
	end
	local sceneName, sceneType, sceneProc, sceneServerId = unpack(result:GetRow(0))
	
	if ChangeSceneDoFun[sceneType] then
		local isSucceed, errArg  = ChangeSceneDoFun[sceneType](data["char_id"], sceneId, sceneName, sceneProc) 
		if not isSucceed then
			CancelTran()
			return nil, errArg
		end
	end
	
	local CharacterMediatorDB = RequireDbBox("CharacterMediatorDB")
	
	local returnData = {} 
	returnData["serverId"] = sceneServerId
	if not data["isSameServer"] then
		if not CharacterMediatorDB.SetChangeToPos(data) then
			CancelTran()
			return nil
		end
	end
	return sceneName, returnData
end

-- ������
local function ChangeYbActFbCheck(charId, PlayerLevel)	
	local ActivityCountDB = RequireDbBox("ActivityCountDB")
	local isCan = nil
	local Maxcount = nil
	local errMsg = nil
	if PlayerLevel < 15 then	-- С��20��ÿ��ֻ�ܲμ�һ��������
		isCan, Maxcount = ActivityCountDB.CheckFbActionCount(charId, "Ӷ��ѵ���", 1)
		errMsg = 2
	else
		isCan, Maxcount = ActivityCountDB.CheckFbActionCount(charId, "Ӷ��ѵ���")
		errMsg = 1
	end
	return isCan, errMsg
end

function SceneMgrSql.GetYbActFbScene(data)
	-- ����Ƿ���Խ���������
	local charId = data["charId"]
	local JoinActionDB = RequireDbBox("JoinActionDB")
	if not JoinActionDB.CheckWarnValue(charId) then
		return false
	end
	
	local PlayerLevel = data["PlayerLevel"]
	local isSucceed, errMsg = ChangeYbActFbCheck(charId, PlayerLevel)
	
	if data["OtherArg"]["m_IsCheckTimes"] == 0 then
		isSucceed = true
	end
	if isSucceed then
		local sceneId, serverId = SceneMgrSql._CreateScene(data)
		return true, nil, sceneId, serverId
	else
		return false, errMsg
	end
end

function SceneMgrSql.GetLeastPlayerScene(sceneName)
	local PlayerNumInSceneID = {}
	local SceneIDServer = {}
	-- SceneID, ServerID, PlayerNum
	local resultFb = SceneMgr.GetLeastPlayerFbScene:ExecSql('nnn', sceneName)
	local resultChange = SceneMgr.GetLeastPlayerChangeScene:ExecSql('nnn', sceneName)

	local temp = resultFb:GetRowNum()
--	print("resultFb - "..temp)
	if resultFb:GetRowNum() > 0 then
		local sceneId ,serverId, playerNum = 0, 1, 0
		for i=1, resultFb:GetRowNum() do
			sceneId, serverId, playerNum = resultFb:GetData(i-1, 0), resultFb:GetData(i-1, 1), resultFb:GetData(i-1, 2)
			if not PlayerNumInSceneID[sceneId] then
				PlayerNumInSceneID[sceneId] = 0
			end
			PlayerNumInSceneID[sceneId] = PlayerNumInSceneID[sceneId] + playerNum		
			
			if not SceneIDServer[sceneId] then
				SceneIDServer[sceneId] = serverId
			end
		end
	end
	
	local temp = resultChange:GetRowNum()
--	print("resultChange - "..temp)
	if resultChange:GetRowNum() > 0 then
		local sceneID ,serverId, playerNum = 0, 1, 0
		for i=1, resultChange:GetRowNum() do
			--sceneId, serverId, playerNum = resultChange:GetData(i-1, 0), resultChange:GetData(i-1, 1), resultChange:GetData(i-1, 2)
			playerNum = resultChange:GetData(i-1, 2)
			if playerNum ~= 0 then
				sceneId = resultChange:GetData(i-1, 0)
				serverId = resultChange:GetData(i-1, 1) 
			end
			
			if sceneId then
				if not PlayerNumInSceneID[sceneId] then
					PlayerNumInSceneID[sceneId] = 0
				end
				PlayerNumInSceneID[sceneId] = PlayerNumInSceneID[sceneId] + playerNum
				
				if not SceneIDServer[sceneId] then
					SceneIDServer[sceneId] = serverId
				end
			end
		end
	end
	resultFb:Release()
	resultChange:Release()
	
	local MixSceneID, MixNum = nil, 10000
	for SceneID, PlayerNum in pairs(PlayerNumInSceneID)do
		if PlayerNum < MixNum then
			MixNum = PlayerNum
			MixSceneID = SceneID
		end
	end
	local MixServerID = SceneIDServer[MixSceneID]
	
	-- ����������ˣ��򶼷���nil
	if MixNum >= Scene_Common[sceneName].MaxPlayerNum then
		MixSceneID = nil
		MixServerID = nil
	end
	
	return MixSceneID, MixServerID
end

-- �������򸱱�
function SceneMgrSql.GetPubliFbScene(data)
	local sceneName = data["SceneName"]
	local teamId = data["TeamID"]
	local sceneArg
	-- ����Ƿ��ж�Ա��Ҫȥ�ĳ�����
	local TeamSceneMgrDB = RequireDbBox("TeamSceneMgrDB")
	if teamId then
		sceneArg = TeamSceneMgrDB.CheckPlayerInFbBySceneName(data)
	end
	local sceneId , serverId

	if sceneArg and IsNumber(sceneArg) then
		sceneId = sceneArg
	elseif not sceneArg or IsString(sceneArg) then
		-- Ѱ�������ٵķ���
		sceneId, serverId = SceneMgrSql.GetLeastPlayerScene(sceneName)
		if not sceneId then
			-- ��������
			local param = {}
			param["SceneName"] = sceneName
			
			--�ñ�������,ȥ�����ö��
			param["ServerId"] = data["ServerId"]
			sceneId, serverId = SceneMgrSql._CreateScene(param)
			if not sceneId then --����ʧ��
				return
			end
		end
	end
	
	if not serverId then
		-- ��ȡserverId
		local result = SceneMgr.SqlGetSceneInfo:ExecSql('snnn', sceneId)
		if result:GetRowNum() > 0 then
			serverId  = result:GetData(0,3)
		end	
		result:Release()
	end
	return true, sceneId, serverId
end


local function ChangeAreaFbSceneCheckMates(charId, sceneName, teamId)
	local data = {}
	data["PlayerTbl"] = {}
	local GasTeamDB =  RequireDbBox("GasTeamDB")
	local tblMembers = GasTeamDB.GetTeamOnlineMembersId(teamId)
	-- ֻ�жӳ����ܱ���
	local captain = GasTeamDB.GetCaptain(teamId)
	if charId ~= captain then
		return false, {4}
	end
	
	for i = 1, #(tblMembers) do
		local MemberID = tblMembers[i]
		local JoinActionDB = RequireDbBox("JoinActionDB")
		if MemberID ~= charId and not JoinActionDB.CheckWarnValue(MemberID, charId) then
			return false
		end
		
		data.PlayerTbl[MemberID] = true
		local CharacterMediatorDB =  RequireDbBox("CharacterMediatorDB")
		if g_AreaFbLev[sceneName] > CharacterMediatorDB.GetPlayerLevel(MemberID) then
			local ex = RequireDbBox("Exchanger")
			local MemberName = ex.getPlayerNameById(MemberID)
			-- ��ԱXXX�ĵȼ�������С�ӱ���ʧ�ܡ�
			--print("��Ա"..MemberName.."�ĵȼ�������С�ӱ���ʧ�ܡ�")
			return false, {5, MemberID}
		end	
	end
	
	--data["ActivityName"] = AreaFb_Common(sceneName, "LimitType")
	local ActionName = AreaFb_Common(sceneName, "ActionName")
	data["ActivityName"] = FbActionDirect_Common(ActionName, "MaxTimes")
	
	local ActivityCountDB = RequireDbBox("ActivityCountDB")
	local result, MemberID = ActivityCountDB.CheckMultiPlayerActivityCount(data)
	if not result then
		local ex = RequireDbBox("Exchanger")
		local MemberName = ex.getPlayerNameById(MemberID)
		-- ��ԱXXX�Ѿ������˸õ��³ǵĽ����޴Σ�С�ӱ���ʧ�ܡ�
		--print("��Ա "..MemberName.." �Ѿ�������"..GetSceneDispalyName(sceneName).."�Ľ����޴Σ�С�ӱ���ʧ�ܡ�")
		return false, {6, MemberID}
	end
	return true
end

--����ֵ isSucceed, errMsgId, sceneId, serverId
function SceneMgrSql.GetAreaFbScene(data)
	local charId = data["charId"]
	local JoinActionDB = RequireDbBox("JoinActionDB")
	if not JoinActionDB.CheckWarnValue(charId) then
		return false
	end
	
	local sceneName = data["SceneName"]
	local GasTeamDB =  RequireDbBox("GasTeamDB")
	local teamId = GasTeamDB.GetTeamID(charId)
	if data["teamId"] ~= teamId then  --�ڴ�����ݿ��teamId��һ��,�ڴ��������ӳ�,ȡ�����β���(��ΪCallDbTrans��TeamId�ļ�������, ����ִ�л���bug)
		return
	end
	
	local otherArg = {}
	otherArg["m_KilledBossNum"] = 0	--BOSS��ɱ����,��ʼΪ0
	data["Proc"] = 0
	data["OtherArg"] = otherArg
	local TeamSceneMgrDB = RequireDbBox("TeamSceneMgrDB")
	local sceneId, serverId = TeamSceneMgrDB.GetScene(data)
	local isNewScene = false
	if not sceneId then
		local GasTeamDB =  RequireDbBox("GasTeamDB")
		local teamId = GasTeamDB.GetTeamID(charId)
		if teamId ~= 0 then
			local result, errArg = ChangeAreaFbSceneCheckMates(charId, sceneName, teamId)
			if not result then
				return result, errArg
			end
		end
			
		sceneId, serverId = SceneMgrSql._CreateScene(data)
		if not sceneId then --����ʧ��
			return
		end
		isNewScene = true
		TeamSceneMgrDB.OnCreateScene(sceneId, teamId)
	end
	
	--����Ƿ���Խ��븱��
	local isSucceed, errArg = ChangeAreaFbSceneCheck(charId, sceneId, sceneName, data["Proc"])
	if not isSucceed then
		CancelTran()
		return false , errArg
	end

	local res = {}

	res.sceneId = sceneId
	res.serverId = serverId
	
	return true, nil, res
end

function SceneMgrSql.GetAreaFbCharInfo(data)
	local teamId = data.TeamID
	local sceneId = data.SceneID
	local charId = data.charId
	local inviteTbl = {}
	local inviteServerTbl = {}

	if teamId ~= 0 then
		local GasTeamDB =  RequireDbBox("GasTeamDB")
		local captain = GasTeamDB.GetCaptain(teamId)
		if captain == charId then
			local onlineMember = GasTeamDB.GetTeamOnlineMembersId(teamId)
			for _, id in pairs(onlineMember) do
				local MemberScenID = SceneMgrSql.GetPlayerCurScene(id)
				if MemberScenID ~= sceneId then
					
					-- ��ȡserverId
					local serverId
					local result = SceneMgr.SqlGetSceneInfo:ExecStat(MemberScenID)
					if result:GetRowNum() > 0 then
						serverId  = result:GetData(0,3)
					end	
					result:Release()
					
					table.insert(inviteTbl, id)
					inviteServerTbl[serverId] = true
				end
			end
		end
	else
		table.insert(inviteTbl, charId)
	end
	
	local res = {}
	if next(inviteTbl) then
		res["PlayerInfo"] = {}
		local CharacterMediatorDB = RequireDbBox("CharacterMediatorDB")
		res["PlayerInfo"]["Res"] = CharacterMediatorDB.GetCharInfoByID(inviteTbl)
	end
	res.inviteTbl = inviteTbl
	res.inviteServerTbl = inviteServerTbl
	
	return res
end

function SceneMgrSql.OnReleaseTeam(team_id)
	Db2CallBack("OnReleaseTeamCancelAreaFb", team_id)
end

function SceneMgrSql.OnLeaveTeam(player_id, team_id)
	Db2CallBack("OnLeaveTeamCancelAreaFb", team_id, player_id)
end

function SceneMgrSql.EnterAreaFbScene(data)
	SceneMgrSql.DelEnterScenePlayer(data["PlayerId"])
	SceneMgr.SaveEnterScenePlayer:ExecSql('', data["PlayerId"], data["SceneId"])
end

function SceneMgrSql.DelEnterScenePlayer(char_id)
	SceneMgr.DelEnterScenePlayer:ExecStat(char_id)
end

local function GetTeamMinLevel(PlayerId, TeamID)
	local CharacterMediatorDB =  RequireDbBox("CharacterMediatorDB")
	local MinLevel = CharacterMediatorDB.GetPlayerLevel(PlayerId)
	
	if TeamID and TeamID > 0 then --�޶���
		local teammgr = RequireDbBox("GasTeamDB")
		local tblMembers = teammgr.GetTeamOnlineMembersId(TeamID)
		local MemberNum = #(tblMembers)
		for i=1, MemberNum do
			
			local id = tblMembers[i]--�õ���ɫ��ID
			if id ~= PlayerId then
				local Level = CharacterMediatorDB.GetPlayerLevel(id)
				--MinLevel = MinLevel + Level
				if MinLevel > Level then
					MinLevel = Level
				end
			end
			
		end
	--	MinLevel = math.floor(MinLevel/MemberNum)
	end
	
	return MinLevel
end

--��ս���񸱱�
function SceneMgrSql.GetDareQuestFbScene(data)
	local charId = data["charId"]
	local sceneName = data["SceneName"]
	local QuestName = data["QuestName"]
	local GasTeamDB =  RequireDbBox("GasTeamDB")
	local teamId = GasTeamDB.GetTeamID(charId)
	if data["teamId"] ~= teamId then  --�ڴ�����ݿ��teamId��һ��,�ڴ��������ӳ�,ȡ�����β���(��ΪCallDbTrans��TeamId�ļ�������, ����ִ�л���bug)
		return false
	end
	
	local MinLevel = GetTeamMinLevel(charId, teamId)
	local otherArg = {}
	otherArg["m_QuestName"] = QuestName
	otherArg["m_SceneBaseLv"] = MinLevel - 10
	data["Proc"] = 0
	data["OtherArg"] = otherArg
	
	local TeamSceneMgrDB = RequireDbBox("TeamSceneMgrDB")
	local sceneId, serverId = TeamSceneMgrDB.GetScene(data)
	local isNewScene = false
	if not sceneId then
		sceneId, serverId = SceneMgrSql._CreateScene(data)
		if not sceneId then --����ʧ��
			return false
		end
		isNewScene = true
		TeamSceneMgrDB.OnCreateScene(sceneId, teamId)
	end
	
	local inviteTbl = {}
	if data["InviteTeammate"] and teamId ~= 0 then
		
		local onlineMember = GasTeamDB.GetTeamOnlineMembersId(teamId)
		for _, id in pairs(onlineMember) do
			if id ~= charId and (isNewScene or SceneMgrSql.GetPlayerCurScene(id) ~= sceneId) then
				table.insert(inviteTbl, id)
			end
		end
		
	end
	return true, sceneId, serverId, inviteTbl
end

local function CheckLingYuFbTimes(PlayerId, SceneType)
	if SceneType == 23 then
		local mercParam = {}
		mercParam["PlayerId"] = PlayerId
		mercParam["ActivityName"] = "�����޴�"
		
		local ActivityCountDbBox = RequireDbBox("ActivityCountDB")
		local ExChanger = RequireDbBox("Exchanger")
		local Name = ExChanger.getPlayerNameById(PlayerId)
		local IsAllow, FinishTimes = ActivityCountDbBox.CheckSinglePlayerActivityCount(mercParam)
		if not IsAllow then
			return false, 3514, Name
		end
	end
	return true
end

--����
function SceneMgrSql.GetLingYuFbScene(data)
	local charId = data["charId"]
	local sceneName = data["SceneName"]
	local SceneType = data["SceneType"]
	
	local GasTeamDB =  RequireDbBox("GasTeamDB")
	local teamId = GasTeamDB.GetTeamID(charId)
	if data["teamId"] ~= teamId then  --�ڴ�����ݿ��teamId��һ��,�ڴ��������ӳ�,ȡ�����β���(��ΪCallDbTrans��TeamId�ļ�������, ����ִ�л���bug)
		return false
	end
	
	local isSucc,MsgID,MsgInfo = CheckLingYuFbTimes(charId, SceneType)
	if not isSucc then
		return false, MsgID, MsgInfo
	end
	
	local sceneId, serverId
	
	if SceneType == 23 then
		local MinLevel = GetTeamMinLevel(charId)
		local otherArg = {}
		otherArg["m_SceneBaseLv"] = MinLevel - 10
		data["Proc"] = 0
		data["OtherArg"] = otherArg
		
		sceneId, serverId = SceneMgrSql._CreateScene(data)
		if not sceneId then --����ʧ��
			return false
		end
		data["InviteTeammate"] = false
	else
		local MinLevel = GetTeamMinLevel(charId, teamId)
		local otherArg = {}
		otherArg["m_SceneBaseLv"] = MinLevel - 10
		data["Proc"] = 0
		data["OtherArg"] = otherArg
		
		local TeamSceneMgrDB = RequireDbBox("TeamSceneMgrDB")
		sceneId, serverId = TeamSceneMgrDB.GetScene(data)
		local isNewScene = false
		if not sceneId then
			sceneId, serverId = SceneMgrSql._CreateScene(data)
			if not sceneId then --����ʧ��
				return false
			end
			isNewScene = true
			TeamSceneMgrDB.OnCreateScene(sceneId, teamId)
		end
	end
	
	local inviteTbl = {}
	if data["InviteTeammate"] and teamId ~= 0 then
		
		local onlineMember = GasTeamDB.GetTeamOnlineMembersId(teamId)
		for _, id in pairs(onlineMember) do
			if id ~= charId and (isNewScene or SceneMgrSql.GetPlayerCurScene(id) ~= sceneId) then
				table.insert(inviteTbl, id)
			end
		end
		
	end
	return true, sceneId, serverId, inviteTbl
end

function SceneMgrSql.EnterDareQuestFbScene(data)
	local ActivityCountDbBox = RequireDbBox("ActivityCountDB")
	local IsAllow, FinishTimes = ActivityCountDbBox.CheckSinglePlayerActivityCount(data)
	if IsAllow then
		if data["ActionName"] then
			local JoinActionDB = RequireDbBox("JoinActionDB")
			JoinActionDB.SetInRoomByActionName(data["PlayerId"], data["ActionName"])
		end
		ActivityCountDbBox.AddActivityCount(data)
	end
	return IsAllow, data["ActivityName"], data["Type"], FinishTimes
end

function SceneMgrSql.GetMercenaryMonsterFbScene(data)
	local charId = data["PlayerId"]
	local sceneName = data["SceneName"]
	local GasTeamDB = RequireDbBox("GasTeamDB")
	local TongBox = RequireDbBox("GasTongBasicDB")
	local tongLev = TongBox.GetTongLevel(data["tongId"])
	local count = MercenaryMonsterFbCountLimit_Server(tongLev, "Count")
	local teamId = GasTeamDB.GetTeamID(charId)
	if data["teamId"] ~= teamId then  --�ڴ�����ݿ��teamId��һ��,�ڴ��������ӳ�,ȡ�����β���(��ΪCallDbTrans��TeamId�ļ�������, ����ִ�л���bug)
		return false, 0
	end
	if tongLev < 5 then
		return false, -1
	end
	
	local onlineMemberTbl = {}
	local maxLevel = data["charLevel"]
	if data["InviteTeammate"] and teamId ~= 0 then
		local captain =  GasTeamDB.GetCaptain(teamId)
		if captain == charId then
			onlineMemberTbl = GasTeamDB.GetTeamOnlineMembersId(teamId)	
			local CharacterMediatorBox = RequireDbBox("CharacterMediatorDB")
			for _, id in pairs(onlineMemberTbl) do
				local level = CharacterMediatorBox.GetPlayerLevel(id)
				if maxLevel < level then
					maxLevel = level
				end
			end
		end
	end

	local otherArg = {}
	otherArg["m_SceneBaseLv"] = maxLevel - 10
	data["OtherArg"] = otherArg
	local TeamSceneMgrDB = RequireDbBox("TeamSceneMgrDB")
	local sceneId, serverId = TeamSceneMgrDB.GetScene(data)
	local isNewScene = false
	if not sceneId then
		sceneId, serverId = SceneMgrSql._CreateScene(data)
		if not sceneId then --����ʧ��
			return false, 0
		end
		isNewScene = true
		TeamSceneMgrDB.OnCreateScene(sceneId, teamId)
	end
	
	--����Ƿ���Խ��븱��
	local isSucceed, errArg = ChangeMercenaryMonsterFbSceneCheck(charId, sceneId, sceneName, data["Proc"], count, true)
	if not isSucceed then
		CancelTran()
		return false, errArg
	end
	
	local inviteTbl = {}
	if onlineMemberTbl and onlineMemberTbl ~= {} then
		for _, id in pairs(onlineMemberTbl) do
			if id ~= charId and (isNewScene or SceneMgrSql.GetPlayerCurScene(id) ~= sceneId) then
				table.insert(inviteTbl, id)
			end
		end
	end

	return true, 0, sceneId, serverId, inviteTbl
end

function SceneMgrSql.EnterMercenaryMonsterFbScene(data)
	SceneMgr.SaveEnterScenePlayer:ExecSql('', data["PlayerId"], data["SceneId"])
	local ActivityCountDB = RequireDbBox("ActivityCountDB")
	ActivityCountDB.AddActivityCount(data)
end

function SceneMgrSql.GetKillYFScene(data)
	local charId = data["charId"]
	local sceneName = data["SceneName"]
	local GasTeamDB =  RequireDbBox("GasTeamDB")
	local teamId = GasTeamDB.GetTeamID(charId)
	if data["teamId"] ~= teamId then  --�ڴ�����ݿ��teamId��һ��,�ڴ��������ӳ�,ȡ�����β���(��ΪCallDbTrans��TeamId�ļ�������, ����ִ�л���bug)
		return
	end
	
	data["Proc"] = 0
	local TeamSceneMgrDB = RequireDbBox("TeamSceneMgrDB")
	local sceneId, serverId = TeamSceneMgrDB.GetScene(data)
	if not sceneId then
		sceneId, serverId = SceneMgrSql._CreateScene(data)
		if not sceneId then --����ʧ��
			return
		end
		TeamSceneMgrDB.OnCreateScene(sceneId, teamId)
	end
	
	return true, sceneId, serverId
end


function SceneMgrSql.DeleteTongScene(tongId)
	SceneMgr.DelTongSceneId:ExecSql( "", tongId)
	return g_DbChannelMgr:LastAffectedRowNum() > 0
end

local StmtDef=
{
	"_GetSceneNameAndQuestName",
	[[
	select
		ts.sc_sSceneName, tsa.sa_sArgValue
	from
		tbl_scene as ts,tbl_scene_arg as tsa
	where
		ts.sc_uType = 16 and tsa.sa_sArgName = "m_QuestName" and ts.sc_uId = ?
	]]
}
DefineSql(StmtDef,SceneMgr)
function SceneMgrSql.GetQuestListFromScene(data)
	local charId = data["charId"]
	
	local GasTeamDB =  RequireDbBox("GasTeamDB")
	local TeamSceneMgrDB = RequireDbBox("TeamSceneMgrDB")
	
	local teamId = GasTeamDB.GetTeamID(charId)
	if teamId and teamId ~= 0 then
		local SceneQuestTbl = {}
		local onlineMember = GasTeamDB.GetTeamOnlineMembersId(teamId)
		for i=1,#(onlineMember) do
			local id = onlineMember[i]
			if id ~= charId then
				local SceneId =  TeamSceneMgrDB.GetPlayerCurTeamScene(id)
				if SceneId then
					local result = SceneMgr._GetSceneNameAndQuestName:ExecStat(SceneId)
					if result:GetRowNum() > 0 then
						table.insert(SceneQuestTbl, {["SceneName"]=result:GetData(0,0),["QuestName"]=result:GetData(0,1)})
					end
				end
			end
		end
		
		return SceneQuestTbl
	end
end

local StmtDef=
{
	"_GetTempScenePlayerId",
	[[
	select
		tcs.cs_uId,tcs.cs_uCamp
	from
		tbl_char_change_position as tccp,tbl_char_static as tcs
	where
		tccp.cs_uId = tcs.cs_uId and tccp.sc_uId = ?
	]]
}
DefineSql(StmtDef,SceneMgr)

local StmtDef=
{
	"_GetFbScenePlayerId",
	[[
	select
		tcs.cs_uId,tcs.cs_uCamp
	from
		tbl_char_fb_position as tcfp,tbl_char_static as tcs
	where
		tcfp.cs_uId = tcs.cs_uId and tcfp.sc_uId = ?
	]]
}
DefineSql(StmtDef,SceneMgr)

function SceneMgrSql.IsEnterScopesFb(data)
	local uCharId = data["uCharId"]
	local PlayerCamp = data["PlayerCamp"]
	local TrapCamp = data["TrapCamp"]
	local SceneId = data["SceneId"]
	
	local PlayerTbl = {}
	local res1 = SceneMgr._GetFbScenePlayerId:ExecStat(SceneId)
	if res1:GetRowNum() > 0 then
		for i=1, res1:GetRowNum() do
			PlayerTbl[res1:GetData(i-1,0)] = res1:GetData(i-1,1)
		end
	end
	
	local res2 = SceneMgr._GetTempScenePlayerId:ExecStat(SceneId)
	if res2:GetRowNum() > 0 then
		for i=1, res2:GetRowNum() do
			PlayerTbl[res2:GetData(i-1,0)] = res2:GetData(i-1,1)
		end
	end
	
	local PlayerNum = {0,0}
	for id,camp in pairs(PlayerTbl) do
		if TrapCamp == camp then
			PlayerNum[1] = PlayerNum[1] + 1
		else
			PlayerNum[2] = PlayerNum[2] + 1
		end
	end
	
	if PlayerCamp == TrapCamp then
		if PlayerNum[1] < 5 then
			return true
		end
	else
		if PlayerNum[2] < 5 then
			return true
		end
	end
end

function SceneMgrSql.DeleteSceneByType()
	local res = DeleteSceneByType()
	return res
end

function SceneMgrSql.GetSceneInfoByName(data)
	local SceneName = data["SceneName"]
	local res = SceneMgr.GetSceneInfoByName:ExecStat(SceneName)
	local num = res:GetRowNum()
	local tbl = {}
	for i = 0, num - 1 do
		table.insert(tbl, {res:GetData(i,0), res:GetData(i,1)})
	end
	return tbl
end

function SceneMgrSql.IsCharInMainScene(CharId)
	local res1 = SceneMgr.GetCharFbScene:ExecStat(CharId)
	local res2 = SceneMgr.GetCharChangeToScene:ExecStat(CharId)
	return res1:GetRowNum()==0 and res2:GetRowNum()==0
end

SetDbLocalFuncType(SceneMgrSql.EnterAreaFbScene)
SetDbLocalFuncType(SceneMgrSql.DaDuoBaoChangeScene)
SetDbLocalFuncType(SceneMgrSql.GetQuestListFromScene)
return SceneMgrSql
