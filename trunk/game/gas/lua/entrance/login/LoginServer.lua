gas_require "world/player/CreateServerPlayer"
gac_gas_require "character/Character"
gac_gas_require "entrance/LoginCommFunc"
gac_gas_require "framework/common/StringSplit"

local LoginServerDB = "LoginServerDB"

local function GetCharList (pConn,tblAllCharInfo,tblEquipInfo,ResTbl,PhaseTbl, rushRegiAccountFlag)
	Gas2Gac:ReturnCharListBegin(pConn, rushRegiAccountFlag)
	local AllChar = {}
	local CharCountInCampTbl = {0, 0, 0}    --������Ӫ�ĳ�ʼ��ɫ��ĿΪ0
	local row = tblAllCharInfo:GetRowNum()
	if  row > 0 then
		for y=1, row do
			local tblChar = {}
			local v = tblAllCharInfo(y)
			tblChar[1]	= v(1)
			tblChar[2]	= v(2)
			tblChar[3]	= g_ParseCustomTblServer[v(3)]
			tblChar[4]	= g_ParseCustomTblServer[v(4)]
			tblChar[5]	= g_ParseCustomTblServer[v(5)]
			tblChar[6]	= v(6)
			tblChar[7]	= v(7)
			tblChar[8]	= v(8)
			tblChar[9]	= v(9)
			tblChar[10] = v(10)
			tblChar[11] = v(11)
			tblChar[12] = v(12)
			if CharCountInCampTbl[tblChar[9]] < 5 then   
				CharCountInCampTbl[tblChar[9]] = CharCountInCampTbl[tblChar[9]] + 1
				table.insert(AllChar,tblChar)
			end
		end
	end

	for n = 1, table.maxn(AllChar) do
		local uCharID = AllChar[n][1]
		local uArmetResID, uBodyResID, uBackResID,uShoulderResID, uArmResID, uShoeResID, uWeaponID,uOffWeaponID = unpack(ResTbl[uCharID])
		AllChar[n][13]	= tblEquipInfo[uCharID][2]
		AllChar[n][14]	= tblEquipInfo[uCharID][3]
		AllChar[n][15]	= uArmetResID
		AllChar[n][16]	= uBodyResID
		AllChar[n][17]	= uBackResID
		AllChar[n][18]	= uShoulderResID
		AllChar[n][19]	= uArmResID
		AllChar[n][20]	= uShoeResID
		AllChar[n][21]	= uWeaponID
		AllChar[n][22]	= uOffWeaponID
		AllChar[n][23]	= PhaseTbl[uCharID]["HeadFxPhase"]
		AllChar[n][24]	= PhaseTbl[uCharID]["WearFxPhase"]
		AllChar[n][25]	= PhaseTbl[uCharID]["HandFxPhase"]
		AllChar[n][26]	= PhaseTbl[uCharID]["ShoeFxPhase"]
		AllChar[n][27]	= PhaseTbl[uCharID]["ShoulderFxPhase"]
		AllChar[n][28]	= PhaseTbl[uCharID]["WeaponFxPhase"]
		AllChar[n][29]	= PhaseTbl[uCharID]["OffWeaponFxPhase"]
		Gas2Gac:ReturnCharList(pConn,unpack(AllChar[n]))
	end
	Gas2Gac:ReturnCharListEnd(pConn)
end

local function GetDeletedCharList(pConn,user_id, res_obj,res,ResTbl,PhaseTbl)
	local AllChar={}
	local DelCharCountInCampTbl = {0, 0, 0}    --������Ӫ�ĳ�ʼ��ɫ��ĿΪ0
	local row = res_obj:GetRowNum()
	if row > 0 then
		for y=1, row do
			local v = res_obj(y)
			local tblChar = {}
			tblChar[1] = v(1)
			tblChar[2] = v(2)
			tblChar[3] =g_ParseCustomTblServer[v(3)]
			tblChar[4] =g_ParseCustomTblServer[v(4)]
			tblChar[5] =g_ParseCustomTblServer[v(5)]
			tblChar[6]	= v(6)
			tblChar[7]	= v(7)
			tblChar[8]	= v(8)
			tblChar[9]	= v(9)
			tblChar[10]	= v(10)
			if DelCharCountInCampTbl[tblChar[9]] < 10 then   
			    DelCharCountInCampTbl[tblChar[9]] = DelCharCountInCampTbl[tblChar[9]] + 1
			    table.insert(AllChar,tblChar)
			end
		end
	end
    
 	for n = 1, table.maxn(AllChar) do
		local uCharID = AllChar[n][1]
		local uArmetResID, uBodyResID, uBackResID,uShoulderResID, uArmResID, uShoeResID, uWeaponID,uOffWeaponID ,uWeaponType= unpack(ResTbl[uCharID])
		if AllChar[n][10] > GetDelCharSavedTimeByLevel(res[uCharID][2]) then
				local data = {["char_id"] = uCharID,["msg"] = GetStaticTextServer(2008)}
				CallAccountLoginTrans(pConn.m_Account,LoginServerDB, "RoleNoDisplay", nil, data)
		else
			AllChar[n][11]	= res[uCharID][2]
			AllChar[n][12]	= res[uCharID][3]
			AllChar[n][13]	= uArmetResID
			AllChar[n][14]	= uBodyResID
			AllChar[n][15]	= uBackResID
			AllChar[n][16]	= uShoulderResID
			AllChar[n][17]	= uArmResID
			AllChar[n][18]	= uShoeResID
			AllChar[n][19]	= uWeaponID
			AllChar[n][20]	= uOffWeaponID
			AllChar[n][21]	= PhaseTbl[uCharID]["HeadFxPhase"]
			AllChar[n][22]	= PhaseTbl[uCharID]["WearFxPhase"]
			AllChar[n][23]	= PhaseTbl[uCharID]["HandFxPhase"]
			AllChar[n][24]	= PhaseTbl[uCharID]["ShoeFxPhase"]
			AllChar[n][25]	= PhaseTbl[uCharID]["ShoulderFxPhase"]
			AllChar[n][26]	= PhaseTbl[uCharID]["WeaponFxPhase"]
			AllChar[n][27]	= PhaseTbl[uCharID]["OffWeaponFxPhase"]
			Gas2Gac:ReturnDelCharList(pConn,unpack(AllChar[n]))
		end
	end
	Gas2Gac:ReturnDelCharListEnd(pConn)
end

function Gac2Gas:SetUserAgreement( Connection)
	local uid = Connection.m_Account:GetID()
	local data = {
							["uid"] = uid
							}
	--local LoginServerSql = (g_DBTransDef["LoginServerDB"])
	CallAccountLoginTrans(Connection.m_Account,LoginServerDB, "SetUserAgreement", callback, data)
end

function Gac2Gas:Get_Char_List( Connection )
	local data = {
					["uid"] = Connection.m_Account:GetID()
					}
	
	local function callback(res_obj1,res_obj2,ResTbl,PhaseTbl, rushRegiAccountFlag)
		GetCharList(Connection,res_obj1,res_obj2,ResTbl,PhaseTbl, rushRegiAccountFlag)
	end
	--local LoginServerSql = (g_DBTransDef["LoginServerDB"])
	CallAccountLoginTrans(Connection.m_Account,LoginServerDB, "GetCharList", callback, data)
end


function Gac2Gas:Get_DeletedChar_List(Connection)
	local uid = Connection.m_Account:GetID()
	local data = {
		["uid"] = uid
	}
	local function callback(res_obj,res,ResTbl,PhaseTbl)
		GetDeletedCharList(Connection,uid, res_obj,res,ResTbl,PhaseTbl)
	end
	--local LoginServerSql = (g_DBTransDef["LoginServerDB"])
	CallAccountLoginTrans(Connection.m_Account,LoginServerDB, "GetDeletedCharList", callback, data)
end

function Gac2Gas:GetDelayTime( Conn )
	Gas2Gac:RetGetDelayTime( Conn )
end


--[[
	���裺
		���Ȱѽ�ɫcopy��tbl_char_deleted������
		Ȼ��ѽ�ɫ��tbl_char����ɾ����
--]]
local function DelChar(Connection)
	Gas2Gac:DelCharEnd( Connection )
end

--ɾ����ɫ�Լ������֯��Ϣ�Ĵ���
local function DealWithReleationsWhenDelChar(nCharID,result)
	local sCharName = result["CharName"]
	local team_info = result["team_info"]
	--С���Ŷ�
	CGasTeam.DealWithTeamInfoWhenDelChar(nCharID,sCharName,team_info)
	CArmyCorpsBase.DealArmyCorpsPosWhenDelChar(result["ArmyCorps_AdminId"],result["Tong_LeaderId"],result["Tong_Id"])
end

function Gac2Gas:DelChar( Connection, cs_uId )
	local new_name = 'deleted_' .. cs_uId
	local data = { 
		["cs_uId"] = cs_uId
	}
	local function callback(suc, result)
	        if suc then
    			--ɾ����ɫ�Լ������֯��Ϣ�Ĵ���
    			DealWithReleationsWhenDelChar(cs_uId,result)
    			DelChar(Connection)
    	    else
                MsgToConn(Connection, result) 
    	    end
	end
	local http = HttpClient:new()
	local host = CISConfig.CISHost
	local port = CISConfig.CISPort
	local url  = CISConfig.CISRoleRename_url
	local params = { 
		['userid'] = Connection.m_Account:GetID(),
		['newname'] = new_name,
		['roleid'] = cs_uId,
		['serv_id'] = tonumber(ERatingConfig["AGIP_Gateway_id"])*100+g_CurServerId,
	}

	local function cis_changename_callback(ret)
		if tonumber(ret) == 200 then
			CallAccountLoginTrans(Connection.m_Account,LoginServerDB, "DelChar", callback, data)
		else
			Gas2Gac:DelCharErr(Connection, 11010)
		end
	end

	local function erating_rename_callback(flag, msg)
		if flag then
			http:SendData(host, port, url, params, cis_changename_callback) 
			local url = CISConfig.CISDelRole_url
			
			http:SendData(host, port, url, params) 
			return
		else
			Gas2Gac:DelCharErr(Connection, 11011)
		end
		--TODO
	end
	
	g_EProtocol:RenameRole(params, erating_rename_callback)
	--DelChar Ϊָ�����������жϵ�����
end

local function GetPlayerLoginInfo(Connection, charId, ChangeType, result)
	local mainSceneInfo, fbSceneInfo = result["MainSceneInfo"], result["FbSceneInfo"]
	--���fb
	SaveCharLoginFuncFlow(charId,"GetPlayerLoginInfo")
	if fbSceneInfo then
		if fbSceneInfo[6] == g_CurServerId then
			local scene = g_SceneMgr:GetScene(fbSceneInfo[1])
			local sceneType = Scene_Common[fbSceneInfo[2]].SceneType
			if scene and scene:IsCanChangeIn() then
				if sceneType == 13 then -- ��������Ҫ����Ƿ��ָܻ�����
					local room = scene:GetGameRoom()
					if room then
						if ChangeType == 0 and room:IsCanResumeGame(charId)  then
							return fbSceneInfo
						elseif ChangeType == 1 and room:IsCanEnterScene(charId)  then
							return fbSceneInfo
						end
					end
				elseif sceneType == 19 then
					if ChangeType == 0 then
						return fbSceneInfo
					elseif ChangeType == 1 and CScenarioExploration.CheckIsInScene(scene, charId)  then
						return fbSceneInfo
					end
				elseif sceneType == 20 then
					if ChangeType == 1 and IsCanEnterDaTaShaScene(scene, charId) then
						return fbSceneInfo
					end
				elseif sceneType == 10 then
					if ChangeType == 1 and IsCanEnterJiFenSaiScene(scene, charId) then
						return fbSceneInfo
					end
				elseif sceneType == 26 then
					local state = CTongRobResMgr.IsCanEnterRobResScene(scene, charId, g_CurServerId)
					if ChangeType == 0 and state then
						return fbSceneInfo
					elseif ChangeType == 1 and state then
						return fbSceneInfo
					end
					
				elseif sceneType == 8 then
					if ChangeType == 0 and IsCanReSumeTongChallenge(scene, charId) or ChangeType == 1 then
						return fbSceneInfo
					end
				elseif sceneType == 24 then
					local ScopesExploration = CScopesExploration:new()
					if ChangeType == 1 and ScopesExploration:IsCanEnterSpecilExplorationScene(scene, charId, result["CharInfo"](1,9)) then
						return fbSceneInfo
					end
				else
					return fbSceneInfo
				end
			elseif sceneType == 6 then --������ḱ��
				if scene and scene.m_Destroying and not scene.m_DestroyNow then
					scene:StopDestroy()
				else
					if scene then
						g_SceneMgr:DestroyScene(scene)
					end
					local otherData = {["m_Process"] = fbSceneInfo[3]}
					scene = g_SceneMgr:CreateScene(fbSceneInfo[2], fbSceneInfo[1], otherData)
				end
				return fbSceneInfo
			end
			
		else--�������ڱ���,ȥĿ�����¼
			return fbSceneInfo
		end
		
		--�ߵ�������˵��������������
		--print"�������ɽ�,ɾ����ҵĸ���������Ϣ"
		CallAccountLoginTrans(Connection.m_Account,"CharacterMediatorDB", "DelFbPosition", nil, {["char_id"] = charId}, fbSceneInfo[1])
	end
	
	return mainSceneInfo
end

function UnRegisterCharLoginFuncFlowTick(char_id)
	if g_CharLoginFuncFlow[char_id] then
		UnRegisterTick( g_CharLoginFuncFlow[char_id].m_LoginGameTimeTick )
		g_CharLoginFuncFlow[char_id].m_LoginGameTimeTick = nil
		g_CharLoginFuncFlow[char_id] = nil
	end
end

function LogInChangeServer(Connection, uid, char_id, serverId, ChangeType, lastMsgIdStr)
	SaveCharLoginFuncFlow(char_id,"LogInChangeServer")
	local Ip, Port = GetServerIporPort(serverId)
	local function CreateKeyCallback(sKey)
		if sKey then
			Connection.m_LogoutSetting = "Immediately"
			Connection.m_ChangeToServer = serverId
			Gas2Gac:RetEnterOtherServer(Connection,Ip, Port,  ChangeType, sKey, lastMsgIdStr or "")
			SaveCharLoginFuncFlow(char_id,"CreateKeyCallback_1")
		else
			Connection.m_LogoutSetting = "Immediately"
			Connection:OldShutDown("[��ɫ��¼����] ��ɫ������¼����")
			SaveCharLoginFuncFlow(char_id,"CreateKeyCallback_2")
		end
		UnRegisterCharLoginFuncFlowTick(char_id)
	end
	local function CreateSecretTimeOut()
		SaveCharLoginFuncFlow(char_id,"CreateSecretTimeOut")
		LogErr("[��ɫ��¼����] ��ɫ������¼������Կ��ʱ, �����Ƿ����������ӶϿ�", "charId:" .. char_id)
		Connection.m_LogoutSetting = "Immediately"
		Connection:OldShutDown("[��ɫ��¼����] ��ɫ������¼������Կ��ʱ")
		UnRegisterCharLoginFuncFlowTick(char_id)
	end

	CallGas(GetServerConn(serverId), "CreateSecretKey", CreateKeyCallback, CreateSecretTimeOut, 20, Connection.m_UserName, char_id, uid)
end

local function CreatePlayerEnterGame(Connection, ChangeType, data, lastMsgIdStr)
	--print("ChangeType: ",ChangeType)
	if not IsCppBound(Connection) then
		--LogErr("������ϷʱConn�Ͽ�","char_id" .. data["char_id"])
		return
	end
	local char_id = data["char_id"]
	local uid = data["account_id"]
	local player = g_GetPlayerInfo(char_id)
	local isPrepareReuse = false
	SaveCharLoginFuncFlow(char_id,"CreatePlayerEnterGame")
	if player then
		if player.m_PrepareReuse then
			LogErr("[��ɫ��¼����] ��ɫ����׼��������ʹ�õ�״̬û�����","char_id" .. data["char_id"])
		end
		if player.m_LeaveTick then	--�ӳ�����tick ��������ͣ, ԭ���߼�������ᵼ�½�ɫ��¼����Ȼִ���������ݿ�������½�ɫ״̬����
			UnRegisterTick(player.m_LeaveTick)
			player.m_LeaveTick = nil
		end
			
		if IsCppBound(player) then --
			if IsCppBound(player.m_Conn) then
				LogErr("[��ɫ��¼����] �µ�����׼����¼һ�� �������ӵĽ�ɫ, �������û����Ŵ��� �� ��ɫ��֤������","char_id" .. data["char_id"])
			end
			player.m_PrepareReuse = true
			isPrepareReuse = true
		end
	end
	
	local lastServerData, srcServerId, dataId = GetPlayerLastServerData(char_id)
	ClearPlayerLastServerData(char_id)
	
	if ChangeType == 1 then --�г���������
		if lastServerData then  --���������������������Ľ�ɫ����, Ҫ����������ݵ���Ч��
			data["SrcServerId"] = srcServerId
			data["DelayDataId"] = dataId
		end
	end
		
	
	local function callback(state, result)
		SaveCharLoginFuncFlow(char_id,"callback")
		if player then
			player.m_PrepareReuse  = nil
		end
		if not IsCppBound(Connection) then
			if isPrepareReuse then --���ӶϿ��޷� �ӹ� ��leaveGame
				LeaveGame(player, uid, Connection.m_UserName)
			end
			return
		end

		if state == "ForceSave" then --��Ҫ����������ǿ�ƴ���
			Connection.m_LogoutSetting = "Immediately"
			Connection:OldShutDown("�����ϴε���Ǯ��δ���̵�������Ҫ����,Ҫǿ��ShutDown")
			--LogErr("��Ҫ����������ǿ�ƴ���","char_id" .. data["char_id"])
			return
		end
		
		if state ~= "DisabledData" and lastServerData then
			SaveCharLoginFuncFlow(char_id,"ReviseCharInfo")
			apcall(ReviseCharInfo,result, lastServerData) -- ���������������������Ľ�ɫ����(���µ�,��δ���̵�) �޸����ݿ�õ�������
		end
		--�ӹܽ�ɫ��֧
		if isPrepareReuse and IsCppBound(player) then
			local curSceneId = player.m_Scene.m_SceneId
			if curSceneId == result["MainSceneInfo"][1] or (result["FbSceneInfo"] and  curSceneId == result["FbSceneInfo"][1]) then
				player.m_bDisabled = false
				g_AllDisabledPlayer[uid] = nil
				local ret, msg = apcall( ReuseServerPlayer, Connection, player, result, lastMsgIdStr)
				if not ret then
					LogErr("[��ɫ��¼����] ReuseServerPlayer�����쳣", "charId:" .. char_id .. "  " .. msg)
					Connection.m_LogoutSetting = "Immediately"
					Connection:OldShutDown("[��ɫ��¼����] ReuseServerPlayer�����쳣")
					return
				end
				
				--�ӹܳɹ�
				if state ~= "DisabledData" and lastServerData then
					Gas2GasCall:CancelDelaySaveTick(GetServerConn(srcServerId), char_id, dataId)
				end
			else
				LogErr("[��ɫ��¼����] Ҫ�ӹܵĽ�ɫ�����ݿ��λ�ò�һ��,������ԭ����ɫ����.  ��鿴�����������log", "charId:" .. char_id)
				LeaveGame(player, uid, Connection.m_UserName)
				Connection.m_LogoutSetting = "Immediately"
				Connection:OldShutDown("[��ɫ��¼����] Ҫ�ӹܵĽ�ɫ�����ݿ��λ�ò�һ��,������ԭ����ɫ����")
				return
			end
		else
			SaveCharLoginFuncFlow(char_id,"GetPlayerLoginInfo")
			local ret, msg = apcall(GetPlayerLoginInfo, Connection,char_id, ChangeType, result)
			local sceneInfo = nil
			if not ret then
				sceneInfo = result["MainSceneInfo"]
				if result["FbSceneInfo"] then
					CallAccountLoginTrans(Connection.m_Account,"CharacterMediatorDB", "DelFbPosition", nil, {["char_id"] = char_id}, result["FbSceneInfo"][1])
				end
				LogErr("[��ɫ��¼����] GetPlayerLoginInfo�����쳣, ֱ��ʹ��ҵ�¼������", "charId:" .. char_id .. "  " .. msg)
			else
				sceneInfo = msg
			end
			
			
			if sceneInfo[6] == g_CurServerId then
				local ret, msg  = apcall(CreateServerPlayer, Connection, ChangeType, char_id, result, sceneInfo, lastMsgIdStr)
				if not ret then
					LogErr("[��ɫ��¼����] CreateServerPlayer�����쳣", "charId:" .. char_id .. "  " .. msg)
					Connection.m_LogoutSetting = "Immediately"
					Connection:OldShutDown("[��ɫ��¼����] CreateServerPlayer�����쳣")
					return
				end
				--�����ɹ�
				if state ~= "DisabledData" and lastServerData then
					SaveCharLoginFuncFlow(char_id,"Gas2GasCall:CancelDelaySaveTick")
					Gas2GasCall:CancelDelaySaveTick(GetServerConn(srcServerId), char_id, dataId)
				end
			else--֪ͨ��ɫ������¼
				LogInChangeServer(Connection, uid, char_id, sceneInfo[6], ChangeType, lastMsgIdStr)
				return
			end
		end
		g_AllPlayerSender:AddPlayer(g_GetPlayerInfo(char_id))
		CampPlayerSenderTbl[result["CharInfo"](1,9)]:AddPlayer(g_GetPlayerInfo(char_id))
		--Connection:LogOnOffLineMsg("user:" .. uid .. "\tlua�����½��")
		Connection:SetRoleName(result["CharInfo"](1,1))
	end
	
	local function errCallBack()
		SaveCharLoginFuncFlow(char_id,"errCallBack")
		if isPrepareReuse then --���player׼��������ʹ�õ�״̬, ��ʹ���߱��жϵ����߲���
			player.m_PrepareReuse = nil
			LeaveGame(player, uid, Connection.m_UserName)
		end
		LogErr("[��ɫ��¼����] CharacterMediatorDB.CreateServerPlayer����", tostring(char_id), Connection)
	end
	
	if ChangeType ~= 1 then
		Gas2Gac:ClearDb2GacMsg(Connection)
	end
	data["ChangeType"] = ChangeType
	PCallAccountLoginTrans(Connection.m_Account,"CharacterMediatorDB", "CreateServerPlayer", callback, errCallBack, data)
	
end

function Gac2Gas:ChangePlayerName( Connection,char_id,NewName)
	local uid = Connection.m_Account:GetID()
	local data = {}
	data.CharId = char_id
	data.account_id = uid
	data.NewName = NewName
	local function callback(result)
		if not result then
			return
		end
		if IsNumber(result) then
			Gas2Gac:ReturnChangePlayerName(Connection, false, result)
			return
		end
		Gas2Gac:ReturnChangePlayerName(Connection, true, 0)
	end
	CallAccountLoginTrans(Connection.m_Account,LoginServerDB, "ChangeCharName", callback, data)
end


function Gac2Gas:PreChangePlayerName( Connection,char_id)
	local uid = Connection.m_Account:GetID()
	local data = {}
	data.CharId = char_id
	data.account_id = uid
	local function callback(result)
		if not result then
			Gas2Gac:ReturnPreChangePlayerName(Connection, false)
			return
		end
		Gas2Gac:ReturnPreChangePlayerName(Connection, true)
	end
	CallAccountLoginTrans(Connection.m_Account,LoginServerDB, "PreChangePlayerName", callback, data)
end

function SaveCharLoginFuncFlow(uCharId,sFuncName)
	if uCharId == 100574 then
		LogErr("�ҵĵ�¼����,Ϊ�˰��������5%bug ",  sFuncName)
	end
	if g_CharLoginFuncFlow[uCharId] then
		table.insert(g_CharLoginFuncFlow[uCharId],sFuncName)
	end
end

function SaveCharLoginFuncTick(tick,char_id,Conn)
	if g_CharLoginFuncFlow[char_id] then
		UnRegisterTick( g_CharLoginFuncFlow[char_id].m_LoginGameTimeTick )
		g_CharLoginFuncFlow[char_id].m_LoginGameTimeTick = nil
		local sMsg = ""
		for i,v in ipairs(g_CharLoginFuncFlow[char_id]) do
			sMsg = sMsg .. v .. ","
		end
		LogErr("�ʺŵ�¼����" .. g_CharLoginFuncFlow[char_id][#g_CharLoginFuncFlow[char_id]],"���id��" .. char_id .. "," .. sMsg,Conn)
		g_CharLoginFuncFlow[char_id] = nil
	end
end

function Gac2Gas:CharEnterGame( Connection, ChangeType, char_id)
	local uid = Connection.m_Account:GetID()
	local nIp = Connection.m_nIP
	local nPort = Connection.m_nPort
	local data = {}
	data["char_id"] = char_id
	data["account_id"] = uid
	data["CurServerId"] = g_CurServerId
	data["ChangeType"] = ChangeType
	
	local CharPosition = nil	
	if g_CharLoginFuncFlow[char_id] then
		UnRegisterTick( g_CharLoginFuncFlow[char_id].m_LoginGameTimeTick )
		g_CharLoginFuncFlow[char_id].m_LoginGameTimeTick = nil
	end
	g_CharLoginFuncFlow[char_id] = {}
	g_CharLoginFuncFlow[char_id].m_LoginGameTimeTick = RegisterTick("LoginGameTimeTick",SaveCharLoginFuncTick,120*1000,char_id,Connection)

	
	local function LocalCharEnterGame(tbl_balance_info)
		SaveCharLoginFuncFlow(char_id,"LocalCharEnterGame(tbl_balance_info)")
		local sceneInfo = nil
		local ret, msg = apcall(GetPlayerLoginInfo,Connection, char_id, ChangeType, CharPosition)
		if not ret then
			sceneInfo = CharPosition["MainSceneInfo"]
			if CharPosition["FbSceneInfo"] then
				SaveCharLoginFuncFlow(char_id,"DelFbPosition")
				CallAccountLoginTrans(Connection.m_Account,"CharacterMediatorDB", "DelFbPosition", nil, {["char_id"] = char_id}, CharPosition["FbSceneInfo"][1])
			end
			LogErr("[��ɫ��¼����] GetPlayerLoginInfo�����쳣, ֱ��ʹ��ҵ�¼������", "charId:" .. char_id .. "  " .. msg)
		else
			sceneInfo = msg
		end
		if sceneInfo[6] == g_CurServerId then
			CreatePlayerEnterGame(Connection, ChangeType, data)
		else
			--print"��¼��ɫ���ڱ���ֱ�ӻ���!!!!!!!!!!!!!!"
			LogInChangeServer(Connection, uid, char_id, sceneInfo[6], ChangeType)
		end
		if tbl_balance_info and tbl_balance_info[100] and IsCppBound(Connection.m_Account) then
			local params = {}
			params["char_id"] = char_id
			params["left_time"] =  tbl_balance_info[100]
			CallAccountLoginTrans(Connection.m_Account, LoginServerDB, "SaveCharLefttimeInfo", nil,params)
			SaveCharLoginFuncFlow(char_id,"SaveCharLefttimeInfo")
		end
	end
	
	local function AGIPEnterGameError(code)
		if code == "time out" then
			--��ʱû�յ�erating���ص���Ϣ��ֱ�ӱ�����֤
			LocalCharEnterGame()
		end
		LogErr("[��ɫ��¼����] CharEnterGame with err_code:" .. code, tostring(char_id), Connection)
	end
	
	local function remote_callback(result, position, rushRegiAccountFlag)
	  if rushRegiAccountFlag == 1 then
        MsgToConn(Connection, 370001)
        return  
	  end
		if not result then		--����ķ��������߼���Χ�ڵ� ����UserId �� CharId ��ƥ��
			LogErr("[��ɫ��¼�ο���Ϣ]  ����GetCharInfo �޷��õ���ȷ���, ���UserId �� CharId ��ƥ�����log�������" , "UserId:" .. uid .. "  CharId:" .. char_id, Connection)
			return
		end
		CharPosition = position
		if GasConfig.SkipGBSAuth == 1 or g_EProtocol.m_bConnected == false then 
			SaveCharLoginFuncFlow(char_id,"LocalCharEnterGame()")
			LocalCharEnterGame()
			return
		end
		SaveCharLoginFuncFlow(char_id,"g_EProtocol:UserEnterGame")
		g_EProtocol:UserEnterGame({data["account_id"], data["char_id"], result(1,1),nPort,nIp,result(1,2),result(1,3),result(1,4)}, {LocalCharEnterGame, AGIPEnterGameError})
	end
	
	local function errCallBack()
		SaveCharLoginFuncFlow(char_id,"errCallBack")
		LogErr("[��ɫ��¼����] ����LoginServerDB.GetCharInfo ����", tostring(char_id), Connection)
	end

	PCallAccountLoginTrans(Connection.m_Account,LoginServerDB, "GetCharInfo", remote_callback,errCallBack, data)
end
--=============================�з������ĵ���===================================
local function InitConnectionData(Connection, UserName,GameID,char_id)
	SaveCharLoginFuncFlow(char_id,"InitConnectionData")
	local addr = CAddress:new()
	Connection:GetRemoteAddress(addr)
	local ip = addr:GetAddress()
	local port = addr:GetPort()
	local ip_info = {}

	SplitString(ip, "%.", ip_info)
	Connection.m_nIP = tonumber(string.format("0x%02x%02x%02x%02x", tonumber(ip_info[1]), tonumber(ip_info[2]), tonumber(ip_info[3]), tonumber(ip_info[4])))
	Connection.m_nPort = tonumber(port)

	local context = CContext:new(Connection, g_App)
	local id = g_ContextMgr:AddContext(context, 300000)
	assert(Connection.m_strIP == nil)
	Connection.m_strIP = ip
	Connection.m_nID = id
	Connection.m_UserName = UserName
	Connection.m_nGameID = GameID
end

function Gac2Gas:CharEnterOtherServer( Connection, ChangeType, sKey, lastMsgIdStr)
	local userName, char_id = UseSecretKey(sKey)
	if not userName then --��Կ��֤ʧ��
		Connection.m_LogoutSetting = "Immediately"
		Connection:OldShutDown("��Կ��֤ʧ��")
		LogErr("�ʺſ�5%��--��Կ��֤ʧ�ܵ��µ�",  "��Կ: " .. sKey)
		return
	end
	
	if g_CharLoginFuncFlow[char_id] then
		UnRegisterTick( g_CharLoginFuncFlow[char_id].m_LoginGameTimeTick )
		g_CharLoginFuncFlow[char_id].m_LoginGameTimeTick = nil
	end

	g_CharLoginFuncFlow[char_id] = {}
	g_CharLoginFuncFlow[char_id].m_LoginGameTimeTick = RegisterTick("LoginGameTimeTick",SaveCharLoginFuncTick,120*1000,char_id,Connection)
	
	local function getaccount_callback(result)
		SaveCharLoginFuncFlow(char_id,"getaccount_callback")
		local nUserID,szName,uYuanBao,uAgreedVer,game_id = unpack(result)
		if not IsCppBound(Connection)  then
			SaveLogout(nUserID)
			--LogErr("�ʺſ�5%��--conn������","�ʺţ�" .. userName .. ",��ɫid��" .. char_id)
			return
		end
		
		InitConnectionData(Connection, szName,game_id,char_id)
		
		Connection.LoginAccountInfo = {
				[1] = Connection.m_nID,
				[2] = uAgreedVer,
				[3] = szName,
				[4] = nUserID,
				[5] = uYuanBao,
				}
		--Gac2Gas:CreateAccount(Connection, "")
		local data = {}
		data["CurServerId"] = g_CurServerId
		data["account_id"] = nUserID
		data["char_id"] = char_id
		
		local function CreatePlayerFun()
			CreatePlayerEnterGame(Connection, ChangeType, data, lastMsgIdStr)
		end
		
		MultiServerCreateAccount(Connection, CreatePlayerFun)
		
	end
	local data = {}
	data["char_id"] = char_id
	CallDbTrans("LoginServerDB", "GetAccountInfoFromID", getaccount_callback, data, userName)
end
--=========================================================================================


------------------------------------�ж��Ƿ��ָܻ���ɫ------------------------------------
local function GetBackRole(Connection,result)
    local suc = result[1]
--���裺���Ȱѽ�ɫ��tbl_char_deleted copy��tbl_char������,Ȼ��ѽ�ɫ��tbl_char_deleted����ɾ����
	if suc == true then
	    local IfSame = result[2]
    	if IfSame > 0 then
    			Gas2Gac:ReturnNameDiff(Connection,false) --��ǰ��ɫ�������ָ��Ľ�ɫ��һ�������ָܻ�
    			return
    	else
    			Gas2Gac:GetBackRoleEnd(Connection) 
    	end
    else
        local msgID =result[2]
        Gas2Gac:GetBackRoleFail(Connection, msgID)
    end
end

function Gac2Gas:GetBackRole(Connection,id )
	local user_id = Connection.m_Account:GetID()
	local data = {
							["id"] = id
							}
	local function callback(result)
		GetBackRole(Connection,result)
	end

	local function get_rolename_callback(result)
		if not result[1] then
			callback({true,1})
			return
		end
		local new_name = result[2]
		local http = HttpClient:new()
		local host = CISConfig.CISHost
		local port = CISConfig.CISPort
		local url  = CISConfig.CISRoleRename_url
		local params = { 
			['userid'] = user_id,
			['newname'] = new_name,
			['roleid'] = id,
			['serv_id'] = tonumber(ERatingConfig["AGIP_Gateway_id"])*100+g_CurServerId,
		}

		local function cis_changename_callback(ret)
			if tonumber(ret) == 200 then
				CallDbTrans(LoginServerDB, "GetBackRole", callback, data,user_id)		
			end
		end

		local function erating_rename_callback(flag, msg)
			if flag then
				http:SendData(host, port, url, params, cis_changename_callback) 
				local url = CISConfig.CISReuseRole_url
				
				http:SendData(host, port, url, params) 
				return
			end
			callback({true,1})
			--TODO
		end
		
		g_EProtocol:RenameRole(params, erating_rename_callback)
	end
	CallAccountLoginTrans(Connection.m_Account, LoginServerDB, "GetDeledRoleName", get_rolename_callback, {['id'] = id})
end

local function CompleteDeleteChar(Connection)	
	Gas2Gac:CompleteDelCharEnd(Connection)
end

function Gac2Gas:CompleteDeleteChar( Connection,CharId )
	local data = {
								["CharId"] = CharId
								}
	local function callback()
		CompleteDeleteChar(Connection)
	end
	--local LoginServerSql = (g_DBTransDef["LoginServerDB"])
	CallAccountLoginTrans(Connection.m_Account,LoginServerDB, "CompleteDeleteChar", callback,data)
end

function g_cmdKickRole(arg1, arg2, arg3)
	local char_id = tonumber(arg1)
	if not char_id then
		return
	end
	local player = g_GetPlayerInfo(char_id)
	if player and player.m_Conn and player.m_Conn.ShutDown then
		local function callback()
			player.m_Conn:ShutDown("g_cmdKickRole")
		end
		LeaveGame(player, player.m_Conn.m_Account:GetID(), player.m_Conn.m_UserName, callback)
	end
end

------------------------------------------------------------------------------------------
--���ʺŴ����ﵽ���޵�ʱ��ɾ����ɫ���ȼ���͵ģ�
function Gac2Gas:UpperLimitDelChar(Connection,us_uId)
local data = {
							["uid"] = us_uId
							}
	local function callback(AllChar,res,ResTbl)
		GetDeletedCharList(Connection,us_uId, AllChar,res,ResTbl)
	end
	
	--local LoginServerSql = (g_DBTransDef["LoginServerDB"])
	CallAccountLoginTrans(Connection.m_Account,LoginServerDB, "UpperLimitDelChar", callback,data)
end

-----------------------------------------------------------------------------
function UserAdultCheckTick()
	local function AdultCheckTick()
		if GasConfig.SkipAdultCheck == 1 then return end
		local function callback(result)
			for i=1,result:GetRowNum() do
				LogoutForAdultCheck(result(i,1))
			end
		end
		CallDbTrans("LoginServerDB", "GetAllCharLeftTimeInfo", callback,{})
	end
	if not g_UserAdultCheckTick then
		g_UserAdultCheckTick = RegisterTick("g_UserAdultCheckTick", AdultCheckTick,10*60*1000)
	end
end
