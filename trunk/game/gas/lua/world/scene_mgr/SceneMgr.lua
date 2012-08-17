-- ��Ϸ�߼��������� CSceneMgr

-- CSceneMgr:Launch ()										���� CSceneMgr
-- CSceneMgr:_GetSceneType ( uId )						���� SceneTypeId ��ȡ SceneDef����Ӧ Description ���� SceneType
-- CSceneMgr:CreateScene ( uId )						����ָ�� ID �� SceneType �� CoreScene ,�ɹ��Ļ� ���ظ� CoreScene ���� CoreSceneId
-- CSceneMgr:DestroyScene ( Scene )				ɾ��ָ��Scene

-- CSceneMgr:GetSceneProcess ( uSceneID )				��� ָ�� ID �� CoreScene �ĸ��ӽ�����Ϣ( bigint(64) unsigned ), ��CoreScene�����ٺ�, ���� -1
-- CSceneMgr:SetSceneProcess ( uSceneID, uProccess )	���� ָ�� ID �� CoreScene �ĸ��ӽ�����Ϣ( bigint(64) unsigned )
-- CSceneMgr:GetSceneType ( uId )			��� ָ�� ID �� SceneType �� SceneType ʵ��
-- CSceneMgr:GetScene( uSceneID )				��� ָ�� ID �� CoreScene �� CoreScene ʵ��
-- CSceneMgr:ShowCoreSceneInfo ( uSceneID )				��ʾָ�� ID �� CoreScene �Ļ�����Ϣ
-- CSceneMgr:ListScene ( )											������г�������Ϣ�����ڸ�gmָ���ӡ��

gas_require "world/scene_mgr/SceneMgrInc"
gas_require "world/scene_mgr/SceneBase"
gas_require "world/npc/LifeOrigin"
gas_require "world/int_obj/IntObjServer"
gac_gas_require "scene_mgr/SceneCfg"
gas_require "world/trap/TrapServer"

gas_require "world/tong_area/DynamicCreateMgr"
gas_require "multiserver/PlayerChangeServer"

gas_require "world/scene_mgr/AreaSceneDataMgr"
gas_require "world/scene_mgr/MainSceneAreaMgr"

--local DestroySceneTickTbl = {}

-- �� �������Ӱ����
function CSceneMgr:InsertTblMetaScene(sName,  SceneAttribute )
	self.m_tbl_MetaScene[sName] = {}
	self.m_tbl_MetaScene[sName].NowSceneNum = 0
	self.m_tbl_MetaScene[sName].Attr = SceneAttribute
end
---------------------------------------------------------------------------------------------------------
--����������ʱ ����CSceneMgr:Launch
function CSceneMgr:Launch(res)
	--print("Launch")
	-- Todo : �����б���س������ñ�
	for i,p in pairs(Scene_Common) do
		local sSceneName = i
		self:InsertTblMetaScene( sSceneName, p )	
		-- ����
		if( GasConfig.PreloadAllScene == 1 ) then
			--CSceneMgr:_GetSceneType( sSceneName )
		end
	end
	--if GasConfig.OpenCfgSwitch == 1 then
		--g_NpcBornMgr:CheckNpcSceneFile()
	--end
	g_NpcBornMgr:SetNpcGroupMemberID()
	--_TheaterDispatcher()
--	print( "---------------- CSceneMgr : SceneType Import Done ----------------" )

	--local num = res:GetRowNum()
	
	for i = 1, table.getn(res) do
		local uSceneId = res[i][1]
		local sSceneName = res[i][2]
		local uProcess = res[i][3]
		local serverId = res[i][4]
		assert(uSceneId ~= 0 and Scene_Common[sSceneName])
		self.m_tbl_MainScene_name[sSceneName] = res[i]
		self.m_tbl_MainScene_Id[uSceneId] = res[i]
		if serverId == g_CurServerId then --ֻ���ر���Ҫ�����ĳ���
			local scenetype = self.m_tbl_MetaScene[sSceneName].Attr.SceneType
			local Scene = InitScene(scenetype, uSceneId, sSceneName, nil)
			--g_ScenePkMgr:DetectArea(Scene)
			--local ScenePkMgr = CScenePkMgr:new()
			CScenePkMgr.DetectArea(Scene)
			Scene.m_Process = uProcess
			self.m_tbl_Scene[ uSceneId ] = Scene
			print( "��� �ָ����� CoreScene ID: "..uSceneId .."   ".. sSceneName)
			if( GasConfig.PreloadAllScene == 1 and (scenetype == 1 or scenetype == 7)) then
				self:_ResumeScene(uSceneId)
			end
		end

	end
	--res:Release()
--	print( "---------------- CSceneMgr : CoreScene Resume Done ----------------" )
	--�����糡
--	print("�����糡...")
--	_TheaterDispatcher()
end

---------------------------------------------------------------------------------------------------------
-- ���� SceneTypeId ��ȡ SceneDef����Ӧ Description ���� SceneType
function CSceneMgr:_GetSceneType( sName )
	if( tostring( sName ) == nil ) then
		local result = "GetSceneType ERROR --> uId "..( tostring(sName) or "").." ����";
		--print( result );
		error( resule )
	end
	
	local SceneType = self.m_tbl_MetaScene[sName]
	if ( not SceneType ) then
		local result = "GetSceneType ERROR --> SceneType "..( tostring(sName) or "").." δע��";
		--print( result );
		return
	end
	if ( SceneType.MetaScene ) then
		local result = "GetSceneType --> SceneType "..( tostring(sName) or "").." ���ڻ�����,ֱ�ӷ���";
		--print( result );
		return SceneType
	end

	local result = "GetSceneType --> SceneType "..( tostring(sName) or "" ).." �״δ���";
	--print( result );
		
	local MetaScene = g_MetaSceneMgr:CreateMetaScene( SceneType.Attr.MapFile )
	if( not MetaScene ) then
		local result = "CreateMetaScene ERROR--> SceneType "..( tostring(sName) or "" ).." ��������г���";
		--print( result );
		return
	end
	SceneType.MetaScene	= MetaScene
	
	return SceneType
end

-- ����ָ�� ID �� SceneType �� CoreScene ,�ɹ��Ļ� ���ظ� CoreScene ���� CoreSceneId
function CSceneMgr:CreateScene( sSceneName, SceneID, OtherData)
	assert( self:GetScene(SceneID) == nil, "�ظ�����ͬId�ĳ���")
--print("CreateScene")
	local SceneType = CSceneMgr:_GetSceneType( sSceneName )  
	if nil == SceneType then
		return
	end
	
	if not SceneID or SceneID == 0 then
		return
	end
	--if (SceneType.Attr.MaxSceneNum~="" and SceneType.NowSceneNum == SceneType.Attr.MaxSceneNum ) then
	--	local result = "CreateScene ERROR--> ���� SceneType "..( tonumber(uId) or "" ).." ��ӵ�е� CoreScene ����";
		--print( result )
	--	return nil
	--end
	
	SceneType.NowSceneNum = SceneType.NowSceneNum + 1
	local DimInfo = CAoiDimFilter_DimensionInfo()
	local CoreScene = g_CoreSceneMgr:CreateCoreScene( SceneType.MetaScene, SceneType.Attr.AoiPic, sSceneName, DimInfo)

	if( CoreScene == nil ) then
		return nil
	end

	local scenetype = SceneType.Attr.SceneType
	local Scene = InitScene(scenetype, SceneID, sSceneName, CoreScene)
	
	--�����ӳ�����Ϣ��Scene��
	if OtherData then
		for i, v in pairs(OtherData) do
			Scene[i] = v
		end
	end
	
	self.m_tbl_Scene[SceneID] = Scene
	local function createElement()
-- NPC����
		Scene.m_TheaterMgr = CTheaterMgr:new(Scene)
		
		g_IntObjServerMgr:CreateSceneIntObj(Scene, SceneType.Attr.NpcSceneFile)
		g_TrapServerMgr:CreateSceneTrap(Scene, SceneType.Attr.NpcSceneFile)
		g_NpcBornMgr:CreateSceneNpc(Scene, SceneType.Attr.NpcSceneFile)
		Scene.m_TheaterMgr:StartServerRunTheater()
		
		self:OnCreateScene(Scene)
	end
	local ret, msg = apcall(createElement)
	if not ret then
		LogErr("������������!!!!", "������: " .. sSceneName .. "  " .. msg)
	end
	return Scene
end


-- ɾ��ָ�� ID �� CoreScene
function CSceneMgr:DestroyScene( Scene )
	assert( Scene )
	if next(Scene.m_tbl_Player) then
		LogErr("ɾ������ʱ�������", "����:" .. Scene.m_SceneName .. " ����:" .. Scene:GetSceneType())
		return
	end
	if Scene.m_FinalDestroy then
		return
	end
	Scene.m_FinalDestroy = true
	UnRegisterObjOnceTick(Scene)
	
	if Scene.m_CloseTick then
		UnRegisterTick(Scene.m_CloseTick)
		Scene.m_CloseTick = nil
	end
	if Scene.m_DestroySceneTick then
		UnRegisterTick(Scene.m_DestroySceneTick)
		Scene.m_DestroySceneTick = nil
	end
	
	if Scene.m_ResourceTick then
		UnRegisterTick(Scene.m_ResourceTick)
		Scene.m_ResourceTick = nil
	end
	
	if self.m_DelayDestroyTick then
		UnRegisterTick(self.m_DelayDestroyTick)
		self.m_DelayDestroyTick = nil
	end
	
	if Scene.m_pkTick then
		for i , v in pairs(Scene.m_pkTick) do 
			UnRegisterTick(v)
		end
		Scene.m_pkTick = nil
	end
	
	--������������tick
	if Scene.m_NpcSortTbl then
		for npcName, v in pairs(Scene.m_NpcSortTbl) do
			if v.CorpseTick then
				UnRegisterTick(v.CorpseTick)
				v.CorpseTick = nil
			end
			if v.RebornTick then
				UnRegisterTick(v.RebornTick)
				v.RebornTick = nil
			end
		end
	end
	
	
	
	if Scene.m_SceneCountDownTick then
		UnRegisterTick(Scene.m_SceneCountDownTick)
		Scene.m_SceneCountDownTick = nil
	end
	Scene:OnDestroy()
	
	local uSceneID = Scene.m_SceneId	
	g_NpcBornMgr:DeleteAllNpc(uSceneID)
	DestroyOneSceneIntObj(uSceneID)
	DestroyOneSceneTrap(uSceneID)
	if Scene.m_TheaterMgr then
		Scene.m_TheaterMgr:DestroySceneTheater(Scene)
	end
--	g_GameCampMgr:CleanGameCamp(Scene)
	if self.m_tbl_Scene[ uSceneID ] == Scene then
		self.m_tbl_Scene[ uSceneID ] = nil
	end
	
	if( Scene.m_CoreScene ) then
		self.m_tbl_CoreSceneIndex[Scene.m_CoreScene] = nil
		g_CoreSceneMgr:DestroyCoreScene( Scene.m_CoreScene )
		local SceneType = self.m_tbl_MetaScene[ Scene.m_SceneName ]
		SceneType.NowSceneNum = SceneType.NowSceneNum - 1

		local result = "CreateScene --> CoreScene "..( tonumber(uSceneID) or "" ).." �ͷųɹ�, ���ݿ�����ɹ�"
		--print( result );		
	else
	
		local result = "CreateScene --> CoreScene "..( tonumber(uSceneID) or "" ).." ��ʵ���ͷ�, ���ݿ�����ɹ�"
		--print( result );
	end
	
	if Scene.m_SceneName == "�����ս��" then
		RemoveChallengeScene(Scene)
	end
end

function DestroyAllScene()
	local SceneTbl = g_SceneMgr.m_tbl_Scene
	for i,v in pairs(SceneTbl) do
		v:DestroyOnCloseServer()
	end
end


-- ��� ָ�� ID �� CoreScene �ĸ��ӽ�����Ϣ
function CSceneMgr:GetSceneProcess( uSceneID )
	if nil == m_tbl_Scene[uSceneID] then
		local result = "CreateScene --> CoreScene "..( tonumber(uSceneID) or "" ).." �����ڣ����ܻ�ȡ������Ϣ"
		--print( result );
		return -1
	else
		local res = self.SqlLoadSceneProcess:ExecSql( "n", uSceneID )
		if (res:GetRowNum()>0) then
			local ret = res:GetData(0,0)
			res:Release()
			return ret
		end
	end
end

-- ���� ָ�� ID �� CoreScene �ĸ��ӽ�����Ϣ
function CSceneMgr:SetSceneProcess( uSceneID, uProccess )
	if nil == m_tbl_Scene[uSceneID] then
		local result = "CreateScene --> CoreScene "..( tonumber(uSceneID) or "" ).." �����ڣ����ܱ��渽����Ϣ"
		--print( result );
		return false
	else
		self.SqlSetSceneProcess:ExecSql( "", uProccess, uSceneID )
		return true
	end
end

function CSceneMgr:_ResumeScene( uSceneID )
--print("_ResumeScene")
	local Scene = self.m_tbl_Scene[uSceneID]
	local sSceneName = self.m_tbl_Scene[uSceneID].m_SceneName

	assert(Scene)

	local SceneType = CSceneMgr:_GetSceneType( sSceneName )
	
--	if (SceneType.Attr.MaxSceneNum~="" and SceneType.NowSceneNum==SceneType.Attr.MaxSceneNum ) then
--		return false
--	end
	
	SceneType.NowSceneNum = SceneType.NowSceneNum + 1	
	
	local DimInfo = CAoiDimFilter_DimensionInfo()
	local CoreScene = g_CoreSceneMgr:CreateCoreScene( SceneType.MetaScene, SceneType.Attr.AoiPic, sSceneName, DimInfo)

	if( CoreScene == nil ) then
		local result = "ResumeScene ERROR--> CoreScene for SceneType "..( tostring(sSceneName) or "" ).." �ָ�ʧ��";
		--print( result );
		return false
	else

	local result = "ResumeScene --> CoreScene for SceneType "..( tostring(sSceneName) or "" ).." �ָ��ɹ� ID Ϊ "..tonumber( uSceneID );
		--print( result );
	end
	
	Scene.m_CoreScene=CoreScene
	
	Scene.m_TheaterMgr = CTheaterMgr:new(Scene)
	g_TrapServerMgr:CreateSceneTrap(Scene, SceneType.Attr.NpcSceneFile)
	g_IntObjServerMgr:CreateSceneIntObj(Scene, SceneType.Attr.NpcSceneFile)
	g_NpcBornMgr:CreateSceneNpc(Scene, SceneType.Attr.NpcSceneFile)
	Scene.m_TheaterMgr:StartServerRunTheater(Scene.m_SceneId)
	self:OnCreateScene(Scene)
	return true
end

-- ���ݳ������ƻ�ó���id �����ڵ� ������id (ֻ����������Ψһ�ĳ������� ����ƽԭ)
function CSceneMgr:GetSceneByName( sSceneName )
	local sceneInfo = self.m_tbl_MainScene_name[sSceneName]
	if sceneInfo then
		return sceneInfo[1], sceneInfo[4]
	end
end

function CSceneMgr:IsMainScene( sceneId )
	return self.m_tbl_MainScene_Id[sceneId]
end

-- ��� ָ�� ID �� CoreScene �� CoreScene ʵ��
function CSceneMgr:GetScene( uSceneID )
	if not uSceneID then
		return nil
	end
	local Scene = self.m_tbl_Scene[uSceneID]

	if ( Scene == nil ) then
		return nil
	end
	
	if ( not Scene.m_CoreScene ) then
		assert(self:_ResumeScene( uSceneID ))
	end
	
	return Scene
end

function CSceneMgr:GetSceneByCoreScene(CoreScene)
	return self.m_tbl_CoreSceneIndex[CoreScene]
end

function CSceneMgr:GetScenePlayerNumber(Scene)
	local num = 0
	for i, p in pairs(Scene.m_tbl_Player) do
		num = num + 1
	end
	return num
end

-- ��ʾָ�� ID �� CoreScene �Ļ�����Ϣ
function CSceneMgr:ShowCoreSceneInfo ( uSceneID )

	local Scene=self.m_tbl_Scene[ uSceneID ]
	if( Scene ) then
	
		local SceneName = Scene.m_SceneName
	else
		local result = "ShowCoreSceneInfo --> CoreScene "..( tonumber(uSceneID) or "" ).." ������"
		--print( result )
	end
end


function CSceneMgr:ListScene()
	result = {}
	for i,v in pairs(self.m_tbl_Scene) do
		table.insert( result , { CoreSceneId=i,MetaSceneName=v.m_SceneName} )
	end
	return result
end

function CSceneMgr:OnCreateScene(Scene)
	self.m_tbl_CoreSceneIndex[Scene.m_CoreScene] = Scene
	Scene:OnCreate()
end

function CSceneMgr:DestroyNpcByName(SceneId, NpcName)
	if(g_NpcBornMgr._m_AllNpc and g_NpcBornMgr._m_AllNpc[SceneId])then 
		for _,Npc in pairs(g_NpcBornMgr._m_AllNpc[SceneId]) do
			if Npc.m_Properties:GetCharName() == NpcName then
				Npc:SetOnDisappear(false)
			end
		end
	end
end

function ChangeSceneById(Conn, SceneId, x, y)
	local Scene = g_SceneMgr:GetScene( SceneId)
	if Scene and Scene:IsCanChangeIn() then
		Gas2Gac:ChangeSceneCancelSelectGround(Conn)
		--local LastSceneId = Conn.m_Player.m_Scene.m_SceneId
		if Conn.m_Player.m_Scene.m_SceneId == Scene.m_SceneId then
			return
		end
		
		if Conn.m_Player.m_IsChangeSceneing then
			return
		else
			Conn.m_Player.m_IsChangeSceneing = true
		end
		
		local fPos = CFPos:new()
		fPos.x = x * EUnits.eGridSpanForObj
		fPos.y = y * EUnits.eGridSpanForObj
		Conn.m_Player:BeginChangeScene(Scene, fPos)
--/**��PK����**/
		--Conn.m_Player:SetZoneType(Scene.m_SceneAttr.PkType)
		
		if Scene.m_SceneAttr.SceneType == 12 then
			MsgToConn(Conn, 10005, Scene.m_SceneRank)
		end
		return Scene
	else
--		print("SceneId������,������תʧ��!!")
		return
	end
end


function NewChangeScene(Conn, SceneName, x , y, SaveX,SaveY)
	local Player = Conn.m_Player
	if not IsCppBound(Player) then
		return
	end
	if Player.m_Scene.m_SceneName == SceneName then
		return
	end
	
	if g_SceneMgr:GetSceneByName(SceneName)then
		ChangeSceneByName(Conn, SceneName, x, y)
		return
	end

	if Player.m_IsChangeSceneing then
		return
	else
		Player.m_IsChangeSceneing = true
	end

	--local tempScene	= CSceneMgr:GetScene( SceneId )
	local SceneArg = JoinScene(Player, SceneName)
	if not SceneArg then
		Player.m_IsChangeSceneing = nil
		return
	end
	Gas2Gac:ChangeSceneCancelSelectGround(Conn)
	
	local scene = nil
	local function CallBack(SceneId)
		if IsNumber(SceneArg) then					--���������Ǹ���id
			scene = g_SceneMgr:GetScene(SceneArg)
		elseif IsString(SceneArg) then			--���������Ǹ�����
			scene =	g_SceneMgr:CreateScene(SceneArg, SceneId)
		end
		if scene ~= nil and scene:IsCanChangeIn() then
			
			if IsCppBound(Conn) and IsCppBound(Player) then
				local fPos = CFPos:new()
				fPos.x = x * EUnits.eGridSpanForObj
				fPos.y = y * EUnits.eGridSpanForObj
				if SaveX and SaveY then
					Player.m_LastSceneSavePos = {SaveX,SaveY}
				end
				Player:BeginChangeScene(scene, fPos)
--/**��PK����**/
				--Player:SetZoneType(scene.m_SceneAttr.PkType)
			else
				if Player then
					Player.m_IsChangeSceneing = nil
				end
			end
			
		else
			if Player then
				Player.m_IsChangeSceneing = nil
			end
--			print("�����ʼ����������~����")
		end
	end
	
--	print("�������Ľ�ɫID��" , ConnID)
	if IsNumber(SceneArg) then					--���������Ǹ���id
		CallBack(SceneArg)
	elseif IsString(SceneArg) then			--���������Ǹ�����
		local parameter = {}
		parameter["SceneName"] = SceneArg
		parameter["ServerId"] = g_CurServerId
		if Conn.m_Account then
			CallAccountAutoTrans(Conn.m_Account, "SceneMgrDB", "_CreateScene", CallBack, parameter)
		end
	end
end

--������Ψһ�����Ĵ���,(����������ƽԭ)
function ChangeSceneByName(Conn, SceneName, x, y)
	local SceneId, ServerId = g_SceneMgr:GetSceneByName(SceneName)
	
	if IsCppBound(Conn.m_Player) and Conn.m_Player.m_CollectResTick then
		TongStopLoadProgress(Conn.m_Player)
	end
	if not (SceneId and ServerId)  then
		LogErr("ChangeSceneByName����ֻ��������Ψһ�ĳ�������", SceneName)
	end
	MultiServerChangeScene(Conn, SceneId, ServerId, x, y)
end

function MultiServerChangeScene(Conn, SceneId, ServerId, x, y)
	Gas2Gac:ChangeSceneCancelSelectGround(Conn)
	local player = Conn.m_Player
	if IsCppBound(player) then
		
		local isCheckCpu = player.m_Scene:IsMainScene() and g_SceneMgr:IsMainScene(SceneId) and ServerId ~= g_CurServerId
		local allUsage = 0
		local maxThreadUsage = 0
		if isCheckCpu then
			allUsage = CCpuUsageMgr_GetSystemCpuUsage(30)
			maxThreadUsage = CThreadCpuUsageMgr_GetTopThreadCpuUsage(30)
		end
		Gas2GasAutoCall:NotifyDestServerChangeScene(GetServerAutoConn(ServerId), player.m_uID, SceneId, x, y, isCheckCpu, allUsage, maxThreadUsage)
		
	end
end

function AddNpcCount(Npc)
	if Npc.m_Scene.m_CountTrigger then
		Npc.m_Scene.m_CountTrigger:AddNpcCount(Npc)
	end
end

function MinusNpcCount(Npc)
	if Npc.m_Scene.m_CountTrigger then
		Npc.m_Scene.m_CountTrigger:MinusNpcCount(Npc)
	end
end

local function LoadSceneFile()
	for _, SceneName in pairs(Scene_Basic_Common_Shell:GetKeys()) do 
--	for _, v in pairs(Scene_Basic_Common_Shell) do
		local npcSceneFile = Scene_Basic_Common_Shell(SceneName, "NpcSceneFile")
		if npcSceneFile ~= "" then
			cfg_require(npcSceneFile)
		end
	end
end

LoadSceneFile()
