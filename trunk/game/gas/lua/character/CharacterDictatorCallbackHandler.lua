gas_require "activity/direct/direct"
gas_require "world/npc/ServerNpc"
gas_require "world/facial_action/FacialAction"
gas_require "world/npc/NpcNature"
gas_require "world/npc/NpcBossServer"
gas_require "fb_game/KillMonsCreateBoss"

--cfg_load "fb_game/DrinkShoot_Common"
cfg_load "npc/QiHunJiZhiYinNpc_Server"

CCharacterDictatorCallbackHandler = class( CCharacterServerCallbackHandler, ICharacterDictatorCallbackHandler )

local QiHunJiZhiYinNpcTbl = {}
for _, NpcName in pairs(QiHunJiZhiYinNpc_Server:GetKeys()) do
	QiHunJiZhiYinNpcTbl[NpcName] = true
end

local function UnRegisterDeathTick(Npc)
	if Npc.DeathTick ~= nil then 
		UnRegisterTick( Npc.DeathTick )
		Npc.DeathTick = nil
	end
end

function NotifyTheater(Npc)
	--���NPC�������߱�ɾ�������Ѵ�NPC��ͣ�ľ糡�����Դ�NPCִ����糡
	local NpcAIType = Npc:GetAITypeID()
	if NpcAIType ~= ENpcAIType.ENpcAIType_Task then		--����ȷ��ֻ������Npc�Ž��о糡
		return
	end
	local NpcName = Npc.m_Properties:GetCharName()
	local Scene = Npc.m_Scene
	local TheaterName = Scene.m_TheaterMgr.m_NpcTheaterMap[NpcName]
	if TheaterName then
		local Theater = Scene.m_TheaterMgr.m_TheaterTbl[TheaterName]
		if Theater and Theater.m_MoveSleep then
			if Theater.m_Co then
				coroutine.resume(Theater.m_Co)
			end
		end
	end
end

function CCharacterDictatorCallbackHandler:OnDisappear(Npc, bReborn)
	if IsServerObjValid(Npc) then
		if Npc.DeathTick ~= nil then 
			UnRegisterTick( Npc.DeathTick )
			Npc.DeathTick = nil
		end
		g_NpcServerMgr:DestroyServerNpcNow(Npc, bReborn)
	--	if Npc.m_DlgOnDestroyed then
	--		Npc.m_DlgOnDestroyed:Add(UnRegisterDeathTick)
	--	end
	end
end

--�����ص�
function CCharacterDictatorCallbackHandler:OnNPCDead(Npc, ExpOwnerId, KillerID, bNormalDead)

	if not IsServerObjValid(Npc) then
		return
	end
	
	local NpcName = Npc.m_Properties:GetCharName()
	local ExpOwner = CEntityServerManager_GetEntityByID(ExpOwnerId)
	local Master = ExpOwner
	local Scene = Npc.m_Scene
	local SceneType = Scene.m_SceneAttr.SceneType
--	local PkType = Scene.m_SceneAttr.PkType
	Npc.m_KillerID = KillerID
	
	--��¼ɱ����
	if nil ~= ExpOwner then
		local eType = ExpOwner.m_Properties:GetType()
		if eType == ECharacterType.Player then
			ExpOwner.m_KillNpcCount = ExpOwner.m_KillNpcCount + 1
--/**��PK����**/
--			ExpOwner:MinusPkValue(PkType, Npc:CppGetLevel())
--			AddJiFenSaiPoint(ExpOwner, Npc, PkType)
		elseif eType == ECharacterType.Npc then
			Master = ExpOwner:GetMaster()
			if nil ~= Master then
				if Master.m_Properties:GetType() == ECharacterType.Player then
					Master.m_KillNpcCount = Master.m_KillNpcCount + 1
				end
--/**��PK����**/
--				Master:MinusPkValue(PkType, Npc:CppGetLevel())
--				AddJiFenSaiPoint(Master, Npc, PkType)
				ExpOwnerId = Master.m_uID
			end
		end
	end
	

	if NpcInfoMgr_BeServantType(Npc:GetNpcType()) == false then
		if SceneType == 12 then			--�󶴸���
			CheckOreMonster(Npc)
		end
	

		if SceneType == 5 then			--���򸱱�
			CAreaFbServer.IsAreaFbBossDead(Scene, NpcName)
			--��ʱȥ������
--			if ExpOwner ~= nil then 
--				AreaFbKillNpcPlusPoint(ExpOwnerId, Scene, NpcName)
--			end
		end

	
	end
	
	--ˢ�ֱ� ���� npc �����¼� 
	g_MatchGameMgr:AllTeamAddCount(Scene, 6, NpcName)
	
	CScenarioExploration.OutPutDPS(Scene, NpcName)
	
	local SceneId = Scene.m_SceneId
--	NpcShowContent("����", Npc) --Npc�Ի�  ����
--	if Npc.m_DlgOnDead then
--		if Master then
--			Npc.m_DlgOnDead(Npc, Master.m_Conn, Npc.m_EventArg["����"])
--		else
--			Npc.m_DlgOnDead(Npc, nil, Npc.m_EventArg["����"])
--		end
--	end
--	RandomGameTrigger("����", Npc, Master)
	g_TriggerMgr:Trigger("����", Npc, Master)
	--++--++--++--++--++--++--++--++--++--++--++--++--
--	CTong_Build:BldgDestroy( Npc)  --����NPC����
	if bNormalDead then
		TruckDestroy(Npc)--���䳵����	
	end
	--++--++--++--++--++--++--++--++--++--++--++--++--
	
	if Npc.DeathTick ~= nil then 
		UnRegisterTick( Npc.DeathTick )
		Npc.DeathTick = nil
	end
	NotifyTheater(Npc)
	
	local function TickCallBack()
		g_NpcServerMgr:DestroyServerNpcNow(Npc, true)
	end


	if Npc.m_DynamicRebornData and Npc.m_DynamicRebornData.AllCount > 4 and bNormalDead and Npc.m_RebornTime ~= 0 then
		if not Npc.IsQueueReborn then
			Npc.IsQueueReborn = true  --��Ǵ�npcʹ�ö��й�������
			--print "��Ҫ���� ��̬���������ٶ�"
			local data = {}
			data.Npc = Npc
			data.DeadTime = os.time() * 1000
			Npc.m_DynamicRebornData.RebornQueue:push(data)
			UpdateRebornQueue(Npc.m_DynamicRebornData)
		else
			LogErr("ͬһnpc������2�� OnNPCDead �ص�")
		end
	else
		local CorpseTime = Npc.m_BaseData("CorpseTime")
		if bNormalDead == false or CorpseTime == 0 then
			g_NpcServerMgr:DestroyServerNpcNow(Npc, true)
		else
			Npc.DeathTick = RegisterTick( "Npc.DeathTick", TickCallBack, CorpseTime)
		end
	end
--	if Npc.m_DlgOnDestroyed then
--		Npc.m_DlgOnDestroyed:Add(UnRegisterDeathTick)
--	end
	
	--Ӷ��ѵ��Ӫ������ɱ���ֺ����
	if SceneType == 14 then
		if ExpOwner then
			local Owner = nil
			local eType = ExpOwner.m_Properties:GetType()
			if eType == ECharacterType.Player then
				Owner = ExpOwner
			elseif eType == ECharacterType.Npc then
				Owner = ExpOwner:GetMaster()
			end
			if Owner then
				--print("NpcName",NpcName)
				CMercenaryRoomCreate.KillTargetAddNum(Owner.m_Scene, NpcName)
			end
			
			-- �����
			if Npc.RandomCubeNpcNum then
				local CreatorEntityID = Npc.m_CreatorEntityID
				local Creator = CEntityServerManager_GetEntityByID(CreatorEntityID)
				if not IsServerObjValid(Creator) then
					--print "g_RandomCreateTick(CreatorEntityID)  һ�������ڵ�Creator!!!!"
					return
				end	
				local num = Npc.RandomCubeNpcNum
				table.insert(Creator.NpcList, num)		
			end
		elseif Npc.m_SaverInMercenary then
			CMercenaryRoomCreate.KillTargetAddNum(Npc.m_Scene, NpcName)
			
		end
	end
	
	--Boss����ս
	local SceneName = Scene:GetLogicSceneName()
	local BossBattleMgr = g_BossBattleMgr[SceneName]
	if BossBattleMgr and (NpcName == BossBattleMgr.BossName or BossBattleMgr.NpcTbl[NpcName]) then
		UpdateBossBattle(SceneName, NpcName, KillerID)
	end
	
	if ExpOwner and QiHunJiZhiYinNpcTbl[NpcName] then
		Gas2Gac:RetShowQihunjiZhiyinWnd(ExpOwner.m_Conn, false)
	end
	
	--�Ⱦƴ���
	--if NpcName == DrinkShoot_Common("�Ⱦ����", "NpcName") and g_DrinkShootMgr then
	--	g_DrinkShootMgr:NextRound(KillerID)
	--end
	
	--�ۼ�ɱ��ˢBoss
	g_KillMonsCreateBoss:KillMonsterAddNum(Npc)
	
	--���ս�����Npc����
	if Npc.m_WarZoneId then
		g_WarZoneMgr:OnNpcDead(Npc)
	end
	
	--Ӷ���Ŵ�Ӫ����
	if Npc.m_TongID and (NpcName == g_WarZoneMgr.m_StationBaseCampTbl[1] or NpcName == g_WarZoneMgr.m_StationBaseCampTbl[2] or NpcName == g_WarZoneMgr.m_StationBaseCampTbl[3]) then
		g_WarZoneMgr:RetreatStation(KillerID, Npc.m_TongID)
	end
	
	--�����ս��������
	if NpcName == g_WarZoneMgr.m_ChallengeBaseCamp[1] or
		 NpcName == g_WarZoneMgr.m_ChallengeBaseCamp[2] or
		 NpcName == g_WarZoneMgr.m_ChallengeBaseCamp[3] or
		 NpcName == g_WarZoneMgr.m_ChallengeDefender[1] or
		 NpcName == g_WarZoneMgr.m_ChallengeDefender[2] or
		 NpcName == g_WarZoneMgr.m_ChallengeDefender[3]	then
		AddKillChallengeBuildNum(KillerID)
	elseif NpcName == g_WarZoneMgr.m_StationSoldierTbl[1] or
		 NpcName == g_WarZoneMgr.m_StationSoldierTbl[2] or
		 NpcName == g_WarZoneMgr.m_StationSoldierTbl[3] then
		AddKillChallengePersonNum(KillerID)
		if SceneType == 8 then
			g_TongBattleCountMgr:KillPersonCallBack(KillerID)
		end
	end
	
	if Npc.m_AttackWarZoneId and Npc.m_MonsStationIndex then
		g_TongMonsAttackStationMgr:AddKillMonsCount(KillerID, Npc.m_AttackWarZoneId, Npc.m_MonsStationIndex)
	end
	
--	-- �ڹ��ļ�ˢ�������е�ͼ����ʾ��NPC
--	local NpcEnetityID = Npc:GetEntityID()
--	if Scene.NpcOnMiddleMap then
--		if Scene.NpcOnMiddleMap[NpcEnetityID] then
--			Scene.NpcOnMiddleMap[NpcEnetityID] = nil
--		end
--	end
end

local function KillNpcAddExp(Player,AddExpNumTbl)
	if AddExpNumTbl["type"] == 2 then
		Player.m_KillNpcExp = AddExpNumTbl["KillNpcExp"]
	end
	CRoleQuest.AddPlayerExp_DB_Ret(Player,AddExpNumTbl)
end

local function GetExpModulus(Player)
	local expModulus = 1
	local SceneType = Player.m_Scene.m_SceneAttr.SceneType
	
	if Player.m_FbActionExpModulus then
		expModulus = Player.m_FbActionExpModulus * Player.m_ExpModulusInFB
		if expModulus < 0 then
			expModulus = 0
		end
		if IsCppBound(Player) and Player:ExistState("���������buff") then 
			expModulus = expModulus * Player.m_ExpModulusByItem 
		end
		if IsCppBound(Player) and Player:ExistState("��װ����һ������״̬") then 
			expModulus = expModulus * Player.m_ExpModulusByItem 
			if expModulus < 0 then
				expModulus = 0
			end
		end
		if IsCppBound(Player) and Player:ExistState("��װ���һ��״̬") then 
			expModulus = expModulus * Player.m_ExpModulusByFifthItem 
			if expModulus < 0 then
				expModulus = 0
			end
		end
	elseif SceneType == 23 or SceneType == 24 then
		--������,�и�3���������
		expModulus = Player.m_ExpModulusInFB * Player.m_ExpModulus
	elseif SceneType == 18 or SceneType == 19 then
		return expModulus
	else
		expModulus = Player.m_ExpModulus + (g_ServerExpModulus-1)
	end
	
	return expModulus
end

local function GetTeamLevelCount(PlayerLevel,tblMembers)
	local MemberNum = #(tblMembers)
	if MemberNum > 0 then
		
		local TeamMemberNum = MemberNum+1
		local LevelCount = 0
		local MaxLevel = PlayerLevel
		for i=1, MemberNum do
			
			local TeamMember = tblMembers[i]
			local Level = TeamMember:CppGetLevel()
			if MaxLevel < Level then
				MaxLevel = Level
			end
			LevelCount = LevelCount + Level
			
		end
		
		return TeamMemberNum,LevelCount+PlayerLevel,MaxLevel
	end
	return 1,0,PlayerLevel
end

--���㾭��ֵ
local function CalculateSingleExp(MonsterLevel,CharacterLevel)
	local uLevelDiff = MonsterLevel - CharacterLevel
	local Exp=0

	if uLevelDiff <= -20 then
		return Exp
	end

	if uLevelDiff > 5 then
		uLevelDiff = 5
	end

	Exp = ((CharacterLevel*3)+50) * (1 + uLevelDiff*4 / (CharacterLevel+60))
	return Exp
end

local function AddPlayerExp(PlayerLevel,AddExpNum,DBExp)
	local LevelExp = DBExp + AddExpNum
	local nCurlevel = PlayerLevel
	local LimitLevel = g_TestRevisionMaxLevel
	if nCurlevel == LimitLevel then
		return nil
	end
	if nCurlevel == LevelExp_Common.GetHeight() then
		return nil
	end
	
	while LevelExp >= LevelExp_Common(nCurlevel, "ExpOfCurLevelUp") do
		--���������������ǰ����Ϊ0
		if LevelExp_Common(nCurlevel, "ExpOfCurLevelUp") == 0 then
			LevelExp = 0
			break
		end
		--��ȥ�������飬��������һ��
		LevelExp = LevelExp - LevelExp_Common(nCurlevel, "ExpOfCurLevelUp")

		nCurlevel = nCurlevel + 1
		if nCurlevel >= LimitLevel then
			LevelExp = 0
			break
		end
		if nCurlevel >= LevelExp_Common.GetHeight() then
			LevelExp = 0
			break
		end
	end
	return nCurlevel,LevelExp
end

local function GetPlayerExp1(Player, TeamMember, data)
	local DBLevel = Player:CppGetLevel()
	local DBExp = Player.m_uLevelExp
	
	local AddExp = 0
	local ExpCofe = 0
	if #(TeamMember) == 4 then--��������е�������ʱ,�Ͷ��1.2������
		ExpCofe = 0.2
	end
	
	local memberNum,levelCount,maxLevel = GetTeamLevelCount(DBLevel, TeamMember)
	if #(TeamMember) > 0 then
		AddExp = CalculateSingleExp(data["MonsterLevel"],DBLevel)*((0.5+0.5*(levelCount/maxLevel))/memberNum+ExpCofe)
	else
		AddExp = CalculateSingleExp(data["MonsterLevel"],DBLevel)
	end
	AddExp = math.floor(AddExp*data["NpcExpModulus"])
	
	AddExp = AddExp*(GetExpModulus(Player) or 1)
	
	return AddExp, ExpCofe, memberNum,levelCount,maxLevel
end

local function GetPlayerExp2(Player, TeamMember, data)
	local DBLevel = Player:CppGetLevel()
	local ExpCofe = {1,0.7,0.66,0.625,0.8}
	
	local memberNum,levelCount,maxLevel = GetTeamLevelCount(DBLevel, TeamMember)
	local AddExp = ((DBLevel*3)+50)*(0.6+0.4*(data["MonsterLevel"]/DBLevel))
	AddExp = math.floor(AddExp*data["NpcExpModulus"])
	
	AddExp = AddExp*(GetExpModulus(Player) or 1) * (ExpCofe[#(TeamMember)+1])
	
	return AddExp, 0, memberNum,levelCount,maxLevel
end

local function AddTeamExp(Player, TeamMember, data)
	local InDBMembers = {}
	local tblTeamExpAdd = { 1, 1.05, 1.15, 1.25, 1.35 }
	
	for i=#(TeamMember), 1, -1 do
		local AreaName1 = Player.m_AreaName
		local AreaName2 = TeamMember[i].m_AreaName
		if AreaName1 == "" or AreaName1 ~= AreaName2 then
			table.remove(TeamMember,i)
		end
	end
	
	local DBLevel = Player:CppGetLevel()
	local DBExp = Player.m_uLevelExp
	
	local NpcCfg = Npc_Common(data["NpcName"])
	local ExpType = NpcCfg("ExpType")
	
	local AddExp, ExpCofe, memberNum,levelCount,maxLevel
	if ExpType == "" or ExpType ~= 1 then
		AddExp, ExpCofe, memberNum,levelCount,maxLevel = GetPlayerExp1(Player, TeamMember, data)
	else
		AddExp, ExpCofe, memberNum,levelCount,maxLevel = GetPlayerExp2(Player, TeamMember, data)
	end
	
	local CurLevel,LevelExp = AddPlayerExp(DBLevel,AddExp,DBExp)
	if CurLevel then
		Player.m_KillNpcExp = AddExp+Player.m_KillNpcExp
		local IsWriteDB = false
		if not Player.m_KillNpcTime 
			or (os.time() - Player.m_KillNpcTime)>2*60 then
			Player.m_KillNpcTime = os.time()
			IsWriteDB = true
		end
		if CurLevel > DBLevel or IsWriteDB then
			table.insert(InDBMembers, Player)
		end
		local AddExpNumTbl = {}
		AddExpNumTbl["Level"]=CurLevel
		AddExpNumTbl["Exp"]=LevelExp
		if #(TeamMember) > 0 then
			AddExpNumTbl["TeamAwardExp"]=AddExp*((0.5*(levelCount/maxLevel)-0.5)/memberNum+ExpCofe)
		end
		AddExpNumTbl["AddExp"]=AddExp
		AddExpNumTbl["uInspirationExp"]=0
		
		CRoleQuest.AddPlayerExp_DB_Ret(Player,AddExpNumTbl)
	end
	
	for i=1, table.getn(TeamMember) do
		local Member = TeamMember[i]
		local DBLevel = Member:CppGetLevel()
		local DBExp = Member.m_uLevelExp
		
		local AddExp, ExpCofe, memberNum,levelCount,maxLevel
		if ExpType == "" or ExpType ~= 1 then
			AddExp, ExpCofe, memberNum,levelCount,maxLevel = GetPlayerExp1(Member, TeamMember, data)
		else
			AddExp, ExpCofe, memberNum,levelCount,maxLevel = GetPlayerExp2(Member, TeamMember, data)
		end
		
		local CurLevel,LevelExp = AddPlayerExp(DBLevel,AddExp,DBExp)
		if CurLevel then
			Member.m_KillNpcExp = AddExp+Member.m_KillNpcExp
			local IsWriteDB = false
			if not Member.m_KillNpcTime 
				or (os.time() - Member.m_KillNpcTime)>2*60 then
				Member.m_KillNpcTime = os.time()
				IsWriteDB = true
			end
			if CurLevel > DBLevel or IsWriteDB then
				table.insert(InDBMembers, Member)
			end
			local AddExpNumTbl = {}
			AddExpNumTbl["Level"]=CurLevel
			AddExpNumTbl["Exp"]=LevelExp
			if #(TeamMember) > 0 then
				AddExpNumTbl["TeamAwardExp"]=AddExp*((0.5*(levelCount/maxLevel)-0.5)/memberNum+ExpCofe)
			end
			AddExpNumTbl["AddExp"]=AddExp
			AddExpNumTbl["uInspirationExp"]=0
			CRoleQuest.AddPlayerExp_DB_Ret(Member,AddExpNumTbl)
		end
	end
	
	return InDBMembers
end

--ɱ�ֵ�OBJ
local function AddPlayerKillNumAndExpObj(Monster,szSkillName,KillerId,ExpOwnerId)
--print("AddPlayerKillNumAndExpObj",szSkillName)
	local TempExpOwner = CEntityServerManager_GetEntityByID(ExpOwnerId) or CEntityServerManager_GetEntityByID(KillerId)
	if TempExpOwner == nil then
		return
	end
	--print(TempExpOwner.m_Properties:GetCharName())
	local Type = TempExpOwner.m_Properties:GetType()
	local FinalExpOwner = nil
	if Type == ECharacterType.Player then
		FinalExpOwner = TempExpOwner
	elseif TempExpOwner.m_OwnerId then
		FinalExpOwner = g_GetPlayerInfo(TempExpOwner.m_OwnerId)
	end
	
	if FinalExpOwner == nil then
		return
	end
	
	local NpcName = Monster.m_Properties:GetCharName()
	local NpcCfg = Npc_Common(NpcName)
	local ShowName = NpcCfg("Title")
--	Monster.m_ExpOwnerId = FinalExpOwner:GetEntityID()
	 --��Npc�Ǳ���ͨ����ɱ��ʱ����������szSkillName��ֵΪ��ĳĳְҵ��ͨ������
	local realskill = szSkillName or ""
	
	--��¼Npc����ʱ�����з�������ɱ�ּ���������״̬
	--���ܷŵ����ݲ����ĺ��������⣬��Ϊ���ݿ����������ʱ����ʱNpc��״̬�����Ѿ����
	local deadstatetbl = {}
	local KillNpcQuestTbl = {}
	KillNpcQuestTbl[1] = g_KillNpcQuestMgr[NpcName]
	KillNpcQuestTbl[2] = g_KillNpcQuestMgr[ShowName]
	for i=1, 2 do
		if KillNpcQuestTbl[i] then
			deadstatetbl[i] = {}
			for killmethod, questtbl in pairs(KillNpcQuestTbl[i]) do
				if killmethod == "��ͨ����" then
					table.insert(deadstatetbl[i],killmethod)
				elseif string.find(killmethod,"ħ��״̬") then
					local magicstate = string.gsub(killmethod,"ħ��״̬","")
					if Monster:ExistState(magicstate) then
						table.insert(deadstatetbl[i],killmethod)
					end
				elseif killmethod == "����"..realskill then
					table.insert(deadstatetbl[i],killmethod)
				end
			end
		end
	end
	
	local DeadPos = CPos:new()
	Monster:GetGridPos(DeadPos)
	local DeadSceneId = Monster.m_Scene.m_SceneId
	--print("���"..FinalExpOwner.m_uID.."ʹ�ü��� "..szSkillName.." ɱ����Npc "..Monster:GetEntityID())
	
	local PlayerId = FinalExpOwner.m_uID
	local EntityID = Monster:GetEntityID()
	local TeamID = FinalExpOwner.m_Properties:GetTeamID()
	g_MatchGameMgr:AddMatchGameCount(FinalExpOwner, 1, NpcName)
	
	local function CallBack(result)
		local AddQuestResTbl,AddItemResTbl,DropItemTbl,DropObjTbl = result[1],result[2],result[3],result[4]
		--local QuestNote = CQuestNotepad:new(PlayerId)
		if #(AddQuestResTbl) > 0 then
			KillNpcAddQuestVar(AddQuestResTbl)  --֪ͨ�����ɱ�ּ���
		end
		
		SaveNpcDropTbl(PlayerId,Monster,EntityID,DeadSceneId,DeadPos,DropItemTbl,DropObjTbl) --�ڴ��б������
		
		for i=1,table.getn(AddItemResTbl) do   --֪ͨ����Ʒ
			local restbl = AddItemResTbl[i]
			local res1 = restbl[1]
			--local res2 = restbl[2]
			local Player = g_GetPlayerInfo(restbl["PlayerId"])
			if IsNumber(res1) then
				if Player and res1 == 3 then
					MsgToConn(Player.m_Conn, GetQuestAddItemErrorMsgID(res1))
				end
			else
				CRoleQuest.add_item_DB_Ret_By_Id(restbl["PlayerId"],restbl["ItemType"],restbl["ItemName"],restbl["ItemNum"],res1)
			end
		end
	end
	
	local data = {}
	data["char_id"] 		= PlayerId
	data["MonsterLevel"] = Monster:CppGetLevel()
	data["NpcName"] = NpcName
	data["ShowName"] = ShowName
	data["TeamID"] = TeamID
	data["DeadStateTbl"] = deadstatetbl  --�е�ɱ����������NpcNpc����ĳЩ����״̬
	data["NpcExpModulus"] = NpcCfg("ExpModulus")
	data["sceneName"] = FinalExpOwner.m_Scene.m_SceneName
	data["PlayerLevel"] = FinalExpOwner:CppGetLevel()
	data["IsBoss"] = Monster:BeBossType()
	data["QuestNpc"] = {}
	data["QuestNpc"][PlayerId] = CRoleQuest.NpcFromQuest_Get(FinalExpOwner)
	data["TeamMemberID"] = {}
	data["TempTeamMemberID"] = {}
	table.insert(data["TempTeamMemberID"], PlayerId)
	
	local Member = {}
	local ChannelIDList = {}
	table.insert(ChannelIDList, FinalExpOwner.m_AccountID)
	if TeamID and TeamID ~= 0 then
		local tblMembers = g_TeamMgr:GetMembers(TeamID)
		local MemberNum = #(tblMembers)
		for i = 1, MemberNum do
			local MemberId = tblMembers[i]
			if MemberId ~= PlayerId then
				local playerTemp = g_GetPlayerInfo(MemberId)
				if playerTemp and playerTemp.m_Scene 
					and DeadSceneId == playerTemp.m_Scene.m_SceneId 
					and FinalExpOwner.m_AreaName ~= "" and FinalExpOwner.m_AreaName == playerTemp.m_AreaName then
					--print("���Ѿ���ϵ��", playerTemp.m_FbActionExpModulus)
					table.insert(ChannelIDList, playerTemp.m_AccountID)
					table.insert(data["TeamMemberID"],MemberId)
					table.insert(data["TempTeamMemberID"], MemberId)
					data["QuestNpc"][MemberId] = CRoleQuest.NpcFromQuest_Get(playerTemp)
					table.insert(Member, playerTemp)
				end
			end
		end
	end
	
	local InDBMember = AddTeamExp(FinalExpOwner, Member, data)
	if next(InDBMember) then
		OnSavePlayerExpFunc(InDBMember)
	end
	
	CallDbTrans("RoleQuestDB", "KillNpcAddQuestDropObj", CallBack, data, unpack(ChannelIDList))
end

function CCharacterDictatorCallbackHandler:OnDeadToQuest(Npc,szSkillName,KillerId,ExpOwnerId)
	--print("OnDeadToQuest", szSkillName, KillerId, ExpOwnerId)
	if not IsServerObjValid(Npc) then
		return
	end
	
	local Scene = Npc.m_Scene
	local SceneType = Scene.m_SceneAttr.SceneType
	if SceneType == 13 then
		local killer = CEntityServerManager_GetEntityByID(KillerId)
		if killer then
			local eType = killer.m_Properties:GetType()
			if eType == ECharacterType.Player then
				g_MatchGameMgr:AddMatchGameCount(killer, 7, Npc.m_Properties:GetCharName())
			elseif eType == ECharacterType.Npc then
				g_MatchGameMgr:AllTeamAddCount(Scene, 8, Npc.m_Properties:GetCharName())
			end
		end
	end
	
	AddPlayerKillNumAndExpObj(Npc,szSkillName,KillerId,ExpOwnerId)
end

function CCharacterDictatorCallbackHandler:OnReaction2Facial(NpcID, ActionName, PlayerID)
	--local npc = CCharacterDictator_GetCharacterByID(NpcID)
	--print("�Ѿ����ص���������Npc��������" .. npc.m_Properties:GetCharName() .. "��������" .. ActionName)
--	return g_FacialAction:DoNpcCallbackReaction(NpcID, ActionName, PlayerID)
end

function CCharacterDictatorCallbackHandler:DoFacialReaction(NpcID, ActionName, PlayerID)
--	return g_FacialAction:DoRealReaction(PlayerID, NpcID)
end

function CCharacterDictatorCallbackHandler:HaveNature(NpcID)
	local npc = CCharacterDictator_GetCharacterByID(NpcID)
	if IsServerObjValid(npc) then
		return g_NpcNature:HaveNature(npc.m_Properties:GetCharName())
	end
end

function CCharacterDictatorCallbackHandler:InitNatureData(NpcID)
	g_NpcNature:InitNature(NpcID)
end
--����(�����ڽ���)
function CCharacterDictatorCallbackHandler:OnDeadByTick(Npc)
	g_TriggerMgr:Trigger("�����ڽ���", Npc, nil)
end


--����ս��״̬
function CCharacterDictatorCallbackHandler:OnEnterBattleState(Npc)
	if IsServerObjValid(Npc) then
		g_TriggerMgr:Trigger("����ս��", Npc, nil)
	end

	if Npc.m_WarZoneId then
		g_WarZoneMgr:OnEnterBattle(Npc)
	end
	
	local Scene = Npc.m_Scene
	local SceneType = Scene.m_SceneAttr.SceneType
	--���³���
	if SceneType == 5 then
		local NpcName = Npc.m_Properties:GetCharName()	
		CAreaFbServer.BossEnterBattleState(Scene, NpcName)
	end
end

--����ս��״̬
function CCharacterDictatorCallbackHandler:OnLeaveBattleState(Npc)
	if IsServerObjValid(Npc) then
		g_TriggerMgr:Trigger("����ս��", Npc, nil)
	end
	
	if Npc.m_WarZoneId then
		g_WarZoneMgr:OnLeaveBattle(Npc)
	end
	
	local Scene = Npc.m_Scene
	local SceneType = Scene.m_SceneAttr.SceneType
	--���³���
	if SceneType == 5 then
		local NpcName = Npc.m_Properties:GetCharName()	
		CAreaFbServer.BossLeaveBattleState(Scene, NpcName)
	end
end

--���º�������ע����糡�õĻص�����
function CCharacterDictatorCallbackHandler:SendNpcRpcMessage(CharId, NpcId, uMessageId)
	--print("CCharacterServerCallbackHandler:SendNpcRpcMessage")
	local Character = CCharacterDictator_GetCharacterByID(CharId)
	if IsServerObjValid(Character) then
		local Type = Character.m_Properties:GetType()
		if Type == ECharacterType.Player then
			Gas2Gac:SendNpcRpcMessageByMessageID(Character:GetConnection(), NpcId,ChannelIdTbl["����"], uMessageId)
		elseif Type == ECharacterType.Npc then
			Gas2Gac:SendNpcRpcMessageByMessageID(Character:GetIS(0), NpcId,ChannelIdTbl["����"], uMessageId)
		end
	end
end

function CCharacterDictatorCallbackHandler:MoveEndMessage(NpcObj)
	--print("CCharacterDictatorCallbackHandler:MoveEndMessage")
	--local NpcObj = CCharacterDictator_GetCharacterByID(NpcId)
	if not IsServerObjValid(NpcObj) then
		return
	end
	local NpcName = NpcObj.m_Properties:GetCharName()
	local Scene = NpcObj.m_Scene
	
	local TheaterName = Scene.m_TheaterMgr.m_NpcTheaterMap[NpcName]
	if TheaterName then
		local Theater = Scene.m_TheaterMgr.m_TheaterTbl[TheaterName]
		if Theater and Theater.m_MoveSleep then
			if Theater.m_Co then
				coroutine.resume(Theater.m_Co)
			end
		end
	end
end

function CCharacterDictatorCallbackHandler:ChangeDir(NpcId, uX, uY)
	local NpcObj = CCharacterDictator_GetCharacterByID(NpcId)
	if not IsServerObjValid(NpcObj) then
		return
	end
	local PlayerID = NpcObj.m_OwnerId
	local Player = nil
	if PlayerID ~= nil then
		Player = CEntityServerManager_GetEntityByID(PlayerID)
	end
--	if Player ~= nil then
--		db()
--	end
	local Dir = CDir:new()
	local vecDir = CVector2f:new() 
	local NpcPos = CPos:new()
	NpcObj:GetGridPos( NpcPos )
	vecDir.x = uX - NpcPos.x 
	vecDir.y = uY - NpcPos.y 
--	if uX == 0 or uY == 0 then
--		if NpcObj.m_Properties:GetCharName() == "�������๷" then
--			db()
--		end
--	end
	Dir:Set( vecDir )
	NpcObj:SetAndSyncActionDir(Dir.uDir)
end

function CCharacterDictatorCallbackHandler:DoNatureAction(NpcId, ActionName)
	if NpcId and ActionName ~= "" then
		local NpcObj = CCharacterDictator_GetCharacterByID(NpcId)
		if IsServerObjValid(NpcObj) then
			local ActionState = CActorCfg_GetEnumByString(ActionName)	
			NpcObj:SetAndSyncActionState(ActionState)
		end
	end
end

function CCharacterDictatorCallbackHandler:SetDrivePig(ObjId, NpcId)
	local Obj = CEntityServerManager_GetEntityByID(ObjId)
	local Npc = CEntityServerManager_GetEntityByID(NpcId)
	if IsServerObjValid(Obj) and IsServerObjValid(Npc) then

		if Npc.m_Properties:GetCharName() then--Ϊ�ܺ������һ����־

			if Obj.m_OwnerId then
				Npc.m_OwnerId = Obj.m_OwnerId
			end
		
		end
	end
end

function CCharacterDictatorCallbackHandler:DestoryObj(ObjId)
	local IntObj = CIntObjServer_GetIntObjServerByID(ObjId)
	if not IsServerObjValid(IntObj) then
		--print("�������󲻴���")
		return
	end

	g_IntObjServerMgr:Destroy(IntObj,false)
	--print("ɾ����������")
end

function CCharacterDictatorCallbackHandler:ReplaceNpc(pServant, pMaster, sAIName, sNpcType, sServantRealName, eCamp)
--print("CCharacterDictatorCallbackHandler:ReCreateNpcAI")
	if not IsServerObjValid(pServant) then
		return
	end
	g_NpcServerMgr:ReplaceNpc(pServant, pMaster, sAIName, sNpcType, sServantRealName, eCamp)
end

function CCharacterDictatorCallbackHandler:SetNpcAlphaValue(EntityID, value)
	local Character = CCharacterDictator_GetCharacterByID(EntityID)
	if IsServerObjValid(Character) then
		Gas2Gac:SetNpcAlphaValue(Character:GetIS(0), EntityID, value)
	end
end

function CCharacterDictatorCallbackHandler:SetNpcCanBeTakeOver(EntityID, eNpcAIType, eNpcType, eCamp)
	--print("CCharacterDictatorCallbackHandler:SetNpcCanBeTakeOver")
	local Npc = CCharacterDictator_GetCharacterByID(EntityID)
	if IsServerObjValid(Npc) then
		Npc.m_CanBeTakeOver =   {
									["NpcAIType"]	= eNpcAIType,
									["NpcType"]		= eNpcType,
									["NpcCamp"]		= eCamp
								}
		Npc:SynToFollowCanBeTakeOver()
	end
end

function CCharacterDictatorCallbackHandler:CreateServantSkillToMaster(pMaster, sServantName)
	if not IsServerObjValid(pMaster) or sServantName == nil then
		return
	end
	local Conn = pMaster.m_Conn
	if Conn == nil then
		return
	end
	Gas2Gac:CreateServantSkill(Conn, sServantName)
end

function CCharacterDictatorCallbackHandler:DelServantSkillFromMaster(pMaster, sServantName)
	if not IsServerObjValid(pMaster) or sServantName == nil then
		return
	end
	local Conn = pMaster.m_Conn
	if Conn == nil then
		return
	end
	Gas2Gac:DelServantSkill(Conn, sServantName)
end


--Npc��Boss��غ���
function CCharacterDictatorCallbackHandler:MasterReBornCortege(MasterID, CortegeID)
	--print("CCharacterDictatorCallbackHandler:MasterReBornCortege")
	local Master = CCharacterDictator_GetCharacterByID(MasterID)
	local Cortege = CCharacterDictator_GetCharacterByID(CortegeID)
	if not IsServerObjValid(Master) or not IsServerObjValid(Cortege) or Master.m_MemberTbl == nil  then
		return
	end
	local Scene = Master.m_Scene    --������������򲻴���
	local CoreScene = Scene.m_CoreScene
		local IsDestory = CoreScene:Destroying()
		if IsDestory then
			return
		end 
	local MemberID = Cortege.m_MemberID
	Master.m_MemberTbl[MemberID]["ServantID"] = 0
	local bReBornInBattle = Master.m_MemberTbl[MemberID]["bReBornInBattle"]
	
	local function TickCallBack(Tick, data)
		local MasterID, MemberID, CortegeName = data[1],data[2],data[3]
		RevertMemberByMaster(MasterID, MemberID, CortegeName)
	end
	
	if bReBornInBattle == 1 then
		local CortegeReBornTime = Cortege.m_BaseData("RebornTime")
		local CortegeName = Master.m_MemberTbl[MemberID]["ServantName"]
		local data = {MasterID, MemberID, CortegeName}
		Master.m_ReBornCortegeTickTBl[MemberID] = RegisterTick("Master.m_ReBornCortegeTickTBl", TickCallBack, CortegeReBornTime, data)
	end
end

function CCharacterDictatorCallbackHandler:MasterRevertNpcGroup(MasterID)
	--print("CCharacterDictatorCallbackHandler:MasterRevertNpcGroup")
	local Master = CCharacterDictator_GetCharacterByID(MasterID)
	if not IsServerObjValid(Master) then
		return
	end
	local MasterName = Master.m_Properties:GetCharName()
	if EnmityShareTeam_Server(MasterName) == nil then
		return
	end
	RevertNpcGroup(MasterID)
end

function CCharacterDictatorCallbackHandler:NpcShowContentBySkill(Npc, SkillName, uTargetID)
	--print("CCharacterDictatorCallbackHandler:NpcShowContentBySkill")
	if not IsServerObjValid(Npc) or Npc:CppIsLive() == false then
		return
	end
	NpcShowContent( "�ͷż���", Npc, SkillName, uTargetID)
	local NpcName = Npc.m_Properties:GetCharName()
	if (SkillName == "����" or SkillName == "��ͨ����" ) and QiHunJiZhiYinNpcTbl[NpcName] then
		local Id = Npc:GetExpOwnerID()
		local Player = CCharacterDictator_GetCharacterByID(Id)
		if IsCppBound(Player) and IsCppBound(Player.m_Conn) and Player:IsSkillActive("�����") then
			Gas2Gac:RetShowQihunjiZhiyinWnd(Player.m_Conn, true)
		end
	end
end

function CCharacterDictatorCallbackHandler:BecomeTargetShadow(Shadow, TargetPlayer)
	if IsServerObjValid(Shadow) and TargetPlayer then
		TargetPlayer:SetShadowProperties(Shadow)
	end
end

function CCharacterDictatorCallbackHandler:TakeOverTruckByNewMaster(NewMaster, Truck)
	if IsServerObjValid(Truck) and IsServerObjValid(NewMaster) then
		InitTruckInfo(Truck)
	end
end

function CCharacterDictatorCallbackHandler:ClearNpcAlertEffect(AlertNpc)
	if IsServerObjValid(AlertNpc) then
		Gas2Gac:ClearNpcAlertEffect(AlertNpc:GetIS(0), AlertNpc:GetEntityID())
	end
end

function CCharacterDictatorCallbackHandler:ReplaceTruck(OldTruck, NewTruck)
	if IsServerObjValid(OldTruck) and IsServerObjValid(NewTruck) then
		TruckDestroy(OldTruck)
		InitTruckInfo(NewTruck)
	end
end
