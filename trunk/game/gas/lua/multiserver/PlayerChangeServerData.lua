gas_require "multiserver/ReviseLoginData"

local StartDate = {year = 2010, month = 1, day =1}
local DelayDataId = (os.time() - os.time(StartDate)) * 10000

local DelaySaveData = {}  --�ӳٱ��浽���ݿ������

local LastServerData = {} --�з�ǰ������, ��������������ɫ��Ϣ������


function GetPlayerLastServerData(charId)
	local v = LastServerData[charId]
	if v then
		return v.Data, v.ServerId, v.Data["DelayDataId"]
	end
end

function ClearPlayerLastServerData(charId)
	LastServerData[charId] = nil
end

function ReceiveData.LastServerData(serverId, data)
	local charId = data["char_id"]
--	assert(LastServerData[charId] == nil ) -- һ������Ķ���
	
	
	LastServerData[charId] = {}
	LastServerData[charId].ServerId = serverId
	LastServerData[charId].Data = data
	
end

function SaveDelayDataToDB(data, username, AccountID, charId)
	local function callback()
--		print"���� �ӳٴ������ݳɹ�"	
		if charId then
 			DelaySaveData[charId] = nil
 		end
	end
	
	local function err_callback()
		LogErr("���� LogoutDelaySaveData����",  "Ҫ�����ķ�����Ϊ: " .. tostring(data["ChangeToServer"]) )
	end
	if g_SceneMgr:IsMainScene(data["scene_id"]) then
		PCallDbTrans("CharacterMediatorDB", "LogoutDelaySaveData", callback, err_callback, data, username, AccountID)
	else
		PCallDbTrans("CharacterMediatorDB", "LogoutDelaySaveData", callback, err_callback, data, username, AccountID, data["scene_id"])
	end
end


function GetDelayDataId()
	DelayDataId = DelayDataId + 1
	return DelayDataId
end

function SavePlayerLogoutData(data, username, AccountID, dataId)	
	local charId = data["char_id"]
	if DelaySaveData[charId] then
		UnRegisterTick(DelaySaveData[charId].Tick)
		DelaySaveData[charId] = nil
	end
	
	local function OnSaveTick(tick)
		UnRegisterTick(tick)
		assert(DelaySaveData[charId])
		SaveDelayDataToDB(DelaySaveData[charId].Data, username, AccountID, charId)
	end


	DelaySaveData[charId] = {}
	DelaySaveData[charId].Data = GetDelaySaveData(data)
	DelaySaveData[charId].Username = username
	DelaySaveData[charId].AccountID = AccountID
	DelaySaveData[charId].Tick = RegisterTick("DelaySaveDataTick", OnSaveTick, (SecretKeyLifeTime + 20) * 1000)
--	print"ע���ӳٴ���tick"
--	print "��������ȥĿ�������"
	assert(dataId)
	DelaySaveData[charId].Data["DelayDataId"] = dataId
	SendDataToServer(GetServerConn(data["ChangeToServer"]), "LastServerData", DelaySaveData[charId].Data)
end

--�ط�����
function SaveAllDelayLogoutData()
	for charId, v in pairs(DelaySaveData) do
		UnRegisterTick(v.Tick)
		SaveDelayDataToDB(v.Data, v.Username, v.AccountID, charId)
	end
end


function Db2Gas:ForceSaveDelayData(data)
--	print"ǿ�ƴ���"
	local charId = data[1]
	local v = DelaySaveData[charId]
	if v then
--		print ("ǿ�ƴ���		�ɹ� " .. v.Data["DelayDataId"])
		UnRegisterTick(v.Tick)
		SaveDelayDataToDB(v.Data, v.Username, v.AccountID, charId)
	else
--		print"ǿ�ƴ���  	������"
	end
end

function Gas2GasDef:CancelDelaySaveTick(Conn, charId, delayDataId)
--	print "ȡ���ӳٴ���"
	local v = DelaySaveData[charId]
	if v and v.Data["DelayDataId"] == delayDataId then
--		print ("ȡ���ӳٴ���   �ɹ� " .. delayDataId)
		UnRegisterTick(v.Tick)
		DelaySaveData[charId] = nil
	else
--		print "ȡ���ӳٴ���   ������"
	end
end