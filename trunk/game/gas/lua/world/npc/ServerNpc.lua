gas_require "framework/main_frame/SandBoxDef"
gas_require "world/npc/ServerNpcInc"
gas_require "world/trigger_action/RandomCreate"
gas_require "world/npc/NpcDropItem"
gas_require "world/npc/NpcBossServer"
cfg_load "npc/Npc_Common"
lan_load "npc/Lan_Npc_Common"
cfg_load "npc/EnmityShareTeam_Server"
cfg_load "model_res/NpcRes_Common"
cfg_load "npc/BarrierNpc_Server"
cfg_load "npc/NpcShowOnMiddleMap_Server"

local borntick = nil

g_NpcServerMgr = CNpcServerMgr:new()

local function RegisterOnlyNpc(Npc,NpcCfg,SceneId,Name)
	if NpcCfg("OnlyNpc") == 1 then   --�����ڵ�Ψһ Npc
		if g_NpcBornMgr._m_OnlyNpc[SceneId] == nil then
			g_NpcBornMgr._m_OnlyNpc[SceneId] = {} 
		end
		if g_NpcBornMgr._m_OnlyNpc[SceneId][Name] == nil then
			g_NpcBornMgr._m_OnlyNpc[SceneId][Name] = Npc
		else 
			CfgLogErr("Npc "..Name.." �����ǳ�����Ψһ��(�����ñ�Npc_Common)")
		end
	end
end

function UnRegisterOnlyNpc(Npc)
	local SceneID = Npc.m_Scene.m_SceneId
	local Name = Npc.m_Properties:GetCharName()
	if Npc_Common(Name,"OnlyNpc") == 1 and g_NpcBornMgr._m_OnlyNpc[SceneID] and g_NpcBornMgr._m_OnlyNpc[SceneID][Name] then
		g_NpcBornMgr._m_OnlyNpc[SceneID][Name] = nil
	end
end

function GetOnlyNpc(uSceneId, sNpcName)
	if g_NpcBornMgr._m_OnlyNpc[uSceneId] then
		--assert(g_NpcBornMgr._m_OnlyNpc[uSceneId][sNpcName], sNpcName.."�����ڻ���ΨһNpc")
		return g_NpcBornMgr._m_OnlyNpc[uSceneId][sNpcName]
	end
	return nil
end

--��ʼ��Npcģ����Դ��
function InitNpcResBaseData()
	local BeginTime = GetProcessTime()
	for i, v in ipairs( NpcRes_Common:GetKeys() ) do
		local ResData = NpcRes_Common(v)
		if ResData ~= nil then
			local Data = CNpcResServerData_Create( ResData("NpcName"), ResData("BaseSize"), ResData("FootSize"), ResData("AdhereTerrain"), ResData("AniFileName") )
		end
	end
	local EndTime = GetProcessTime()
	print("��ȡ��������ñ���NpcRes_Common�����ñ���ϣ�    ��ʱ��" .. (EndTime - BeginTime) .. "����!")
end

-- ��ʼ��Npc���ñ�
function InitServerNpcBaseData()
	local success = true
	local BeginTime = GetProcessTime()
	for _ ,NpcName in pairs(Npc_Common:GetKeys()) do

	--for k,v in pairs(Npc_Common) do
			local NpcRes = NpcRes_Common(NpcName)
			if NpcRes == nil then
				print("ģ����Դ��NpcRes_Common����û�����á�Npc_Common�����е�Npc��" .. NpcName .. "����ģ����Դ���벹ȫ��")
			end
			local bCanChangeAI = false	--Ĭ�ϲ���
			local bCanBeRavin = false --�ɱ���ɱ
			if Npc_Common(NpcName, "ControlType") == 0 then
				bCanChangeAI = true
				bCanBeRavin = true
			elseif Npc_Common(NpcName, "ControlType") == 1 then
				bCanChangeAI = true
			elseif Npc_Common(NpcName, "ControlType") == 2 then
				bCanBeRavin = true
			end
			local bSleep = true			--Ĭ������
			if Npc_Common(NpcName, "BeSleep") == 0 then
				bSleep = false
			end
			local bSynToClient = true	--Ĭ��ͬ��
			if Npc_Common(NpcName, "ShowBloodType") == 3 then
				bSynToClient = false
			end
			local bCanBeSelected = false
			
			if Npc_Common(NpcName, "ShowBloodType") == 0 
				or Npc_Common(NpcName, "ShowBloodType") == 4
				or Npc_Common(NpcName, "ShowBloodType") == 5 then
				bCanBeSelected = true
			end
			local min = Npc_Common(NpcName, "MinLevel")
			local max = Npc_Common(NpcName, "MaxLevel")
			if min > max then
				local str = "Npc ��" .. NpcName .. "���ڡ�Npc_Common���ĵȼ���д�������ʵ��"
				error(str)
			end
			local uLevel = math.random(min, max)
			local Data = CNpcServerBaseData_Create(NpcName, Npc_Common(NpcName, "Type"), Npc_Common(NpcName, "AIType"), Npc_Common(NpcName, "AIData"), Npc_Common(NpcName, "Camp"), Npc_Common(NpcName, "Class"), Npc_Common(NpcName, "Sex"), uLevel)
			if Data ~= nil then
				Data:SetCanBeChangeAI(bCanChangeAI)
				Data:SetCanBeRavin(bCanBeRavin)
				Data:SetBeSleep(bSleep)
				Data:SetBeSynToClient(bSynToClient)
				Data:SetCanBeSelected(bCanBeSelected)
			else
				success = false
			end
		end
	--end
	local EndTime = GetProcessTime()
	print("��ȡ��������ñ���Npc_Common�����ñ���ϣ�    ��ʱ��" .. (EndTime - BeginTime) .. "����!")
	return success
end

--�޸�NPC��AI���ͣ�ʹNPC֧�ֶ�̬AI
function CNpcServerMgr:ReplaceNpc(Npc, Master, AIType, NpcType, sServantRealName, eCamp)
	local uNpcName		= Npc.m_Properties:GetCharName()
	local uLevel 		= Npc:CppGetLevel()
	local Scene			= Npc.m_Scene
	local Pos 			= CFPos:new()
	Npc:GetPixelPos(Pos)
	local uCamp 		= eCamp 
	local uServantRealName = sServantRealName
	local uMasterObjID = 0
	if Master ~= nil then
		uMasterObjID	= Master:GetEntityID()
		uCamp			= Master:CppGetCamp()
	end
	local AIType 		= AIType
	local NpcType 		= NpcType
	
	local NewNpc = g_NpcServerMgr:CreateServerNpc(uNpcName, uLevel, Scene, Pos , nil, uMasterObjID, AIType, NpcType)

	--�ɵ�ԭ�ȵ�Npc����������
	Npc:SetOnDisappear(true)

end

function CNpcServerMgr:CreateServerNpc(Name, uLevel, Scene, Pos , OtherData, MasterObjID, AIType, NpcType, ServantRealName , bIsBattleHorse, Direction, IsIgnoreClog)

	--�ȼ��Ϸ���
	local bSuccess, errmsg =  self:CheckNpcValid(Name, Scene, MasterObjID, NpcType, bIsBattleHorse)
	
	if bSuccess then
		--����C++����ͬʱ��ʼ��NpcAI������״̬��
		local Npc = self:CreateServerCppNpcObj(Name, uLevel, Scene, Pos , OtherData, MasterObjID, AIType, NpcType, ServantRealName , bIsBattleHorse, Direction, IsIgnoreClog)
	
		local function InitNpcAttribute()
			--��ʼ��Npc�淨��ز���
			self:InitNpcAttribute(Npc, Name, Scene, Pos, OtherData)
		end
		apcall(InitNpcAttribute)
		
		Npc:CreateEnded()		--����״̬��
		
		return Npc, ""
	end
	return nil, errmsg
end

function CNpcServerMgr:CheckNpcValid(Name, Scene, MasterObjID, NpcType, bIsBattleHorse)
	local NpcCfg = Npc_Common(Name)
	local Master = CCharacterDictator_GetCharacterByID(MasterObjID)
	if NpcCfg == nil then
		return  false, "�ڡ�Npc_Common.dif�����в�����Npc����" .. Name .. "������˶����ñ�";
	end
	if Scene then
		local CoreScene = Scene.m_CoreScene
		if IsCppBound(CoreScene) then
			local IsDestory = CoreScene:Destroying()
			if IsDestory then
				return false, "������" .. Scene.m_SceneName .. "��������������ʱ���ܴ���Npc�� ��" .. Name .. "��������"
			end 
		else
			return false, "������" .. Scene.m_SceneName .. "���Ѿ���������ʱ���ܴ���Npc�� ��" .. Name .. "��������"		
		end
	end
	
	--��ⳡ��Npc�Ƿ񳬳�����
	local bLimit = GasConfig.SceneObjLimit
	local uMaxLimit = Scene_Common[Scene.m_SceneName].NpcLimit
	local uSceneId = Scene.m_SceneId
	if bLimit and g_NpcBornMgr.AllNpcNum[uSceneId] and g_NpcBornMgr.AllNpcNum[uSceneId] > uMaxLimit then
		local errmsg = "������" .. Scene.m_SceneName .. "��ͬʱ���ڵ�Npc��������������ƣ� ��" .. uMaxLimit .. "�������������������"
		LogErr(errmsg, Name)
		return false, errmsg
	end
	
	if bIsBattleHorse and not IsServerObjValid(Master) then
		return false , "����һ�����˲����ڵ�ս�����"
	end
	local RealNpcType = NpcType
	if not RealNpcType then
		RealNpcType = NpcCfg("Type")
	end
	if IsServantType(RealNpcType) and not IsServerObjValid(Master) then
		return false , "�������������˵��ٻ�������Npc�� " .. Name .. " NpcType: " .. RealNpcType
	end
	return true, ""
end

function CNpcServerMgr:CreateServerCppNpcObj(Name, uLevel, Scene, Pos , OtherData, MasterObjID, AIType, NpcType, ServantRealName , bIsBattleHorse, Direction, IsIgnoreClog)
	
	local NpcCfg = Npc_Common(Name)
	local Master = CCharacterDictator_GetCharacterByID(MasterObjID)
	local Npc = nil
	if(bIsBattleHorse) then
		Npc = CEntityServerCreator_CreateCharacterDictatorWithMaster(Master, "Npc", Name)
	else
		if IsIgnoreClog == 1 then
			Npc = CEntityServerCreator_CreateCharacterDictator( Scene.m_CoreScene, Pos, "Npc", Name, true)
		else
			Npc = CEntityServerCreator_CreateCharacterDictator( Scene.m_CoreScene, Pos, "Npc", Name, false)
		end
--/**��PK����**/
--		Npc:CppSetPKState(false)
	end
	if not Npc then
		LogErr("Npc����ʧ��", "������:" .. Scene.m_SceneName .. "  Npc��:" .. Name)
		return
	end
	RegOnceTickLifecycleObj("Npc",Npc)	--ע��npc����Ϊoncetick�ĳ�����
	local NpcEnetityID = Npc:GetEntityID()
	Npc.m_CallbackHandler = CCharacterDictatorCallbackHandler:new()
	Npc:SetCallbackHandler(Npc.m_CallbackHandler)

	Npc.m_Scene = Scene
	Npc.m_BaseData = NpcCfg
	
	----------------------������Ϣ�Ǹ��ı�NPC��AIʱʹ�õ�---------------------------------
	Npc.m_Name = Name
	Npc.m_ReBornCortegeTickTBl = {}			--��Npc��Ҫ����С�ܵ�Tick�б�
	--------------------------------------------------------------------------------------
	Npc.m_Properties = CServerNpcProperties:new()
	Npc.m_Properties:Init(Npc)
	Npc.m_Properties:InitNpcStatic(Name,0,ECharacterType.Npc)
	if IsServerObjValid(Master) then
		local TeamID = Master:GetTeamID()
		local TongID = Master:GetTongID()
		Npc.m_Properties:SetMasterTeamID(TeamID)
		Npc.m_Properties:SetMasterTongID(TongID)
	else
		Npc.m_Properties:SetMasterTeamID(TeamID)
		Npc.m_Properties:SetMasterTongID(TongID)		
	end
	Npc.m_Properties:SetMaterialNum(0)	--��ʼ����ԴΪ0

	----------- ���û��ָ��Npc��AIType��NpcType�Ļ��������ñ��ȡ ---------------
	local sAITpye = nil
	local sNpcType = nil
	if AIType == nil or  NpcType == nil then
		 sAITpye  = NpcCfg("AIType")
		 sNpcType = NpcCfg("Type")
	else
		 sAITpye 	= AIType
		 sNpcType	= NpcType
	end
	local eCamp = NpcCfg("Camp")
	if uLevel == nil or uLevel == 0 then
		uLevel = g_NpcBornMgr:GetNpcBornLevel(Name)
	end
	
	local eClass = NpcCfg("Class")
	CNpcServerCreator_CreateServerNpcAI( Npc, Name, uLevel , sAITpye, sNpcType, eClass, eCamp, ServantRealName, MasterObjID)
	
	local SceneId = Npc.m_Scene.m_SceneId
	if g_NpcBornMgr._m_AllNpc[SceneId] == nil then
		g_NpcBornMgr._m_AllNpc[SceneId] = {}
		g_NpcBornMgr.AllNpcNum[SceneId] = 0
	end
	g_NpcBornMgr.AllNpcNum[SceneId] = g_NpcBornMgr.AllNpcNum[SceneId] + 1
	
	g_NpcBornMgr._m_AllNpc[SceneId][NpcEnetityID] = Npc
	Npc:SetAndSyncActionDir(Direction)
	
	if g_NatureArg2NpcTbl[Name] then
		Npc:SetSizeType(EAoiItemSizeType.eAIST_InterestingMonster)
	end 
	if Npc:ExistBirthAniFrame() and ( OtherData ==nil or not OtherData["m_bChangeSceneCreate"] ) then
		Npc:SetAndSyncActionState(EActionState.eAS_Birth)
	else
		Npc:SetAndSyncActionState(EActionState.eAS_Still_1)		
	end
	
	if IsServerObjValid(Master) then
		Master:AddServant(Npc)
	end
	
	Npc:SetDoSpecialActionProbability(NpcCfg("SpecialActProbability"))
	
	return Npc
end

function CNpcServerMgr:InitNpcAttribute(Npc, Name, Scene, Pos, OtherData)
	local NpcCfg = Npc_Common(Name)
	--����NPC���ϵ���Ϣ
	if OtherData then
		for i, v in pairs(OtherData) do
			Npc[i] = v
		end
	end
	local NpcEnetityID = Npc:GetEntityID()
	
	-- �ж�ˢ������NPC�Ƿ�Ҫ���е�ͼ����ʾ
	if NpcShowOnMiddleMap_Server(Name) then
		-- ��Ҫ���е�ͼ����ʾ��NPC����Scene��
		if not Scene.NpcOnMiddleMap then
			Scene.NpcOnMiddleMap = {}
		end
		local PosX = Pos.x / EUnits.eGridSpan
		local PosY = Pos.y / EUnits.eGridSpan
		
		if not Scene.NpcOnMiddleMap[NpcEnetityID] then
			Scene.NpcOnMiddleMap[NpcEnetityID] = {}
		end
		table.insert(Scene.NpcOnMiddleMap[NpcEnetityID], {Name, PosX, PosY})
	end
	
	local RandomCreateCfg = RandomCreate_Server(Name)
	if RandomCreateCfg ~= nil then
		local fistTime = RandomCreateCfg("FirstTime")
		local intervalTime = RandomCreateCfg("IntervalTime") * 1000
		local time = 0;
		if fistTime == nil or fistTime == "" then
			time = intervalTime
			Npc.m_NowIntervalTime = time
		else
			time = fistTime ~= 0 and fistTime * 1000 or 10
			Npc.m_isNewRandomCreateTick = true
		end
		
		local function TickCallBack()
			g_RandomCreateTick(NpcEnetityID)
		end
		
		Npc.m_RandomCreateTick =  RegisterTick("NpcRandomCreateTick", TickCallBack, time)
	end
	
	local NpcMaster = Npc:GetMaster()
	local npc_type	= Npc:GetNpcType()
	if npc_type == ENpcType.ENpcType_Shadow then--�������⴦��
		if NpcMaster then
			local MasterType = NpcMaster.m_Properties:GetType()
			if MasterType == ECharacterType.Player then
				NpcMaster:SetShadowProperties(Npc)
			end
		end
	end
	
	local eGameCamp = NpcCfg("GameCamp")
	if (not NpcInfoMgr_BeServantType(npc_type)) and (not NpcMaster) then
		Npc:CppSetGameCamp(eGameCamp)
	end
	
	local uLevel = Npc:CppGetLevel()
	if nil ~= NpcMaster then
		local MasterType = NpcMaster.m_Properties:GetType()
		if MasterType ~= ECharacterType.Player then
			if NpcCfg("DynamicLv") == 1 and Scene.m_SceneBaseLv then
				Npc:CppSetLevel(uLevel + Scene.m_SceneBaseLv)
			end
		end
	else
		if NpcCfg("DynamicLv") == 1 and Scene.m_SceneBaseLv then
			Npc:CppSetLevel(uLevel + Scene.m_SceneBaseLv)
		end
	end
	
	AddNpcCount(Npc)
	g_TriggerMgr:Trigger("����", Npc, Master)
	
	local SceneId = Npc.m_Scene.m_SceneId
	RegisterOnlyNpc(Npc,NpcCfg,SceneId,Name)

	--�ǲ����ϰ�NPC
	local BarrierNpcServer = BarrierNpc_Server(Name)
	if BarrierNpcServer then
		--Npc:SetBottomSize(BarrierNpcServer.Size)
		--Npc:SetBarrierSize(BarrierNpcServer.Size)
		Npc:SetDynamicBarrier(EBarrierType.eBT_MidBarrier)
	end
	
	if Scene.m_MercenaryActSaveNpcTbl then
		for i=1,#(Scene.m_MercenaryActSaveNpcTbl) do
			if Npc_Common(Scene.m_MercenaryActSaveNpcTbl[i])
				and Scene.m_MercenaryActSaveNpcTbl[i] == Name then
				Npc.m_SaverInMercenary = Scene.m_tbl_Player
				break
			end
		end
	end
	
	g_MatchGameMgr:AllTeamAddCount(Scene, 9, Name)--npcˢ�ֱ���������
	
	--���GM�Ѿ��رյ��淨������Npc��������
	--IsNpcOfClosedAction(Npc, Name)
end

--�ýӿ���ר�����ڼ���ϵͳ����Npc������ص��淨�Ľӿ�
function CNpcServerMgr:SkillCreateNpcEnd(Npc)
	local SkillCreateNpcFun = {
		[ENpcType.ENpcType_Truck] = InitTruckInfo,
	}
	local fun = SkillCreateNpcFun[Npc:GetNpcType()]
	if IsFunction(fun) then
		fun(Npc)
	end
end

function CNpcServerMgr:CreateLittlePet(uMasterID, szLittlePetName, uLevel, fPosX, fPosY)
	local Character = CCharacterDictator_GetCharacterByID(uMasterID)
	if not IsServerObjValid(Character) then
		return
	end
	local Pos = CFPos:new( fPosX, fPosY )
	local otherData = 	{
							["m_CreatorEntityID"]=uMasterID
						}
	local NpcAIName = NpcInfoMgr_GetAINameByAIType(ENpcAIType.ENpcAIType_LittlePet)
	local NpcType	= NpcInfoMgr_GetTypeNameByType(ENpcType.ENpcType_LittlePet)
	local ServantRealName = ""
	if Character.m_Properties:GetType() == ECharacterType.Player then
		ServantRealName = Character:GetPetName(szLittlePetName)
	end
	local Pet, logMsg = self:CreateServerNpc(szLittlePetName, uLevel ,Character.m_Scene, Pos, otherData, uMasterID,  nil, nil, ServantRealName, nil, EActionState.eAS_Birth)
	if not IsServerObjValid(Pet) then
		LogErr("����Npcʧ��", logMsg)
		return
	end
	Pet:CppSetCamp(ECamp.eCamp_Passerby)
	g_NpcServerMgr:SkillCreateNpcEnd(Pet)
end

local function ClearInTrapNpc(Npc)
	local function Init()
		for TrapName, IDTbl in pairs(Npc.m_Properties.m_InTrapTblName) do
			for _, TrapID in pairs(IDTbl) do 
				local Trap = CIntObjServer_GetIntObjServerByID(TrapID)
				if Trap then
					local TrapCharIDTbl = Trap.m_OnTrapCharIDTbl
					if TrapCharIDTbl[Npc:GetEntityID()] then
						TrapCharIDTbl[Npc:GetEntityID()] = nil
					end
				end
			end
		end
	end
	apcall(Init)
end

function CNpcServerMgr:CleanNpcData(Npc, bReborn)
	if Npc.m_IsPrimordialNpc then
		if Npc.m_Scene.m_PrimordialNpc[Npc.m_SettingFileIndex] ~= Npc then
			LogErr("��¼ԭʼ�ڹ�npc ��table���npc ��׼ȷ!!", "NpcName:" .. Npc.m_Properties:GetCharName() .. " SceneName:" .. Npc.m_Scene.m_SceneName)
		end
		Npc.m_Scene.m_PrimordialNpc[Npc.m_SettingFileIndex] = nil
	end
	ClearInTrapNpc(Npc)
	UnRegisterObjOnceTick(Npc)
	UnRegisterOnlyNpc(Npc)
	ClearMasterRebornTbl(Npc)
	g_NpcBornMgr:CleanColony(Npc)
	if Npc.m_SetTimeTick ~= nil then
		UnRegister(Npc.m_SetTimeTick)
		Npc.m_SetTimeTick = nil 
	end
	if Npc.m_RandomCreateTick ~= nil then
		UnRegisterTick(Npc.m_RandomCreateTick)
		Npc.m_RandomCreateTick = nil
	end
	if Npc.showTick ~= nil then
		UnRegisterTick(Npc.showTick)
		Npc.showTick = nil
	end
	if Npc.DeathTick then
		UnRegisterTick(Npc.DeathTick)
		Npc.DeathTick = nil
	end
	if Npc.m_HpTick then
		UnRegisterTick(Npc.m_HpTick)
		Npc.m_HpTick = nil
	end
	if Npc.m_ReadyTick then
		UnRegisterTick(Npc.m_ReadyTick)
		Npc.m_ReadyTick = nil
	end
	if Npc.m_RebornTime ~= ENpcIsReborn.eNT_NoReborn and bReborn == true then
		g_NpcBornMgr:WhoDead(Npc)
	end
	if Npc.m_CreateAnotherPigTick then
		UnRegisterTick(Npc.m_CreateAnotherPigTick)
		Npc.m_CreateAnotherPigTick = nil
	end
	if Npc.BattlingTick then
		UnRegisterTick(Npc.BattlingTick)
		Npc.BattlingTick = nil
	end
	if Npc.m_SmallGameTick then
		UnRegisterTick(Npc.m_SmallGameTick)
		Npc.m_SmallGameTick = nil
	end
end

--function CNpcServerMgr:RemoveAllEvent( Npc)
--	--����� ���нű�����ȫ�ֱ���,npc���ϵ�ֻ��һ������
--	Npc.m_DlgOnClicked = nil
--	Npc.m_DlgOnDead = nil
--	Npc.m_DlgOnBorn = nil
--	Npc.m_DlgOnDeadByTick = nil
--	Npc.m_LeaveBattleState = nil
--	Npc.m_EnterBattle = nil
--	Npc.m_DlgOnDestroyed = nil
--	Npc.m_AlterCamp = nil
--	Npc.m_Cuddle = nil
--end

function CNpcServerMgr:DestroyServerNpc( Npc , IsDestroyScene)
	if Npc.m_CreatorEntityID then
		local NpcName = Npc.m_Properties:GetCharName()
		local creater = CEntityServerManager_GetEntityByID(Npc.m_CreatorEntityID)
		if creater and creater.UseItemParam and creater.UseItemParam.CreateTbl and creater.UseItemParam.CreateTbl[NpcName] then
			creater.UseItemParam.CreateTbl[NpcName] = nil
		end
	end
	NotifyTheater(Npc)
	g_BuildingMgr:RemoveBuildingNpc(Npc)
	g_WarZoneMgr:RemoveWarZoneNpc(Npc)
	g_TongMonsAttackStationMgr:RemoveAttackNpc(Npc)
	if Npc.m_TimeTrigger then
		Npc.m_TimeTrigger:StopTrigger()
	end
--	if not IsDestroyScene and Npc.m_DlgOnDestroyed then
--		Npc.m_DlgOnDestroyed(Npc, nil, Npc.m_EventArg["����"])
--	end
	if not IsDestroyScene then
		MinusNpcCount(Npc)
		g_TriggerMgr:Trigger("����", Npc, nil)
		-- �ڹ��ļ�ˢ�������е�ͼ����ʾ��NPC
		local NpcEnetityID = Npc:GetEntityID()
		if Npc.m_Scene.NpcOnMiddleMap then
			if Npc.m_Scene.NpcOnMiddleMap[NpcEnetityID] then
				Npc.m_Scene.NpcOnMiddleMap[NpcEnetityID] = nil
			end
		end
	end
	local EntityID = Npc:GetEntityID()
	local SceneID = Npc.m_Scene.m_SceneId
	if g_NpcBornMgr._m_AllNpc[SceneID] and g_NpcBornMgr._m_AllNpc[SceneID][EntityID] then
		g_NpcBornMgr._m_AllNpc[SceneID][EntityID] = nil
	end
	g_NpcBornMgr.AllNpcNum[SceneID] = g_NpcBornMgr.AllNpcNum[SceneID] - 1
	CheckIsDestroyDropTbl(EntityID)
--	self:RemoveAllEvent(	Npc)  --���Npc���Ϲҵ��¼�
	CEntityServerCreator_DestroyEntity(Npc)
	Npc = nil
end

function CNpcServerMgr:ShutDownOrDestroySceneDeleteNpc(Npc)
	if Npc and IsServerObjValid(Npc) then
		self:CleanNpcData(Npc, false)
		self:DestroyServerNpc(Npc,true)
	end
end

-- ��������Npc
function CNpcServerMgr:DestroyServerNpcNow(Npc, bReborn)
	if Npc and IsServerObjValid(Npc) then
		self:CleanNpcData(Npc, bReborn)
		self:DestroyServerNpc(Npc)
	end
end

---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------�����ķָ���------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------

-- ���� NPC �����Լ�
function Gac2Gas:AttackMe( Connection, NpcId, SkillName, SkillLevel )
	local npc = CCharacterDictator_GetCharacterByID(NpcId)

	npc.m_LockingObj = Connection.m_Player
	npc:SetTarget( npc.m_LockingObj )

	npc.DoSkill( npc, SkillName, SkillLevel )
end

-- �ı� NPC λ��
function Gac2Gas:ChangeGridPos(Connection, NpcId, x, y)
	local npc = CCharacterDictator_GetCharacterByID(NpcId)
	local pos = CPos:new()
	pos.x = x
	pos.y = y
	local ret = npc:SetGridPosByTransport(pos)

	if ret == 0 then	
		Gas2Gac:ChangedGridPosEnd(Connection)
	end
end

--����֪ͨ�ٻ�����Npc�������Ŀ��
function Gac2Gas:MasterAttackCommand(Connection, uPlayerId, NpcType)
	local Player = CCharacterDictator_GetCharacterByID(uPlayerId)
	if IsServerObjValid(Player) then
		Player:MasterAttackCommand(NpcType)
	end
end

--����֪ͨ�ٻ�����Npc�˳�ս��
function Gac2Gas:MasterRetreatCommand(Connection, uPlayerId, NpcType, PosX, PosY)
	local Player = CCharacterDictator_GetCharacterByID(uPlayerId)
	if IsServerObjValid(Player) then
		Player:MasterRetreatCommand(NpcType)
	end
end

--����֪ͨ�ٻ�����Npc��ɢ
function Gac2Gas:MasterDisbandCommand(Connection, uPlayerId, NpcType)
	local Player = CCharacterDictator_GetCharacterByID(uPlayerId)
	if IsServerObjValid(Player) then
		Player:MasterDisbandCommand(NpcType)
	end
end

--���������ٻ���չ��
function Gac2Gas:MasterSpreadCommand(Connection, uPlayerId, NpcType)
	local Player = CCharacterDictator_GetCharacterByID(uPlayerId)
	if IsServerObjValid(Player) then
		Player:MasterSpreadCommand(NpcType)
	end
end

--���������ٻ����ƶ�
function Gac2Gas:MasterOrderServantMoveCommand(Connection, uPlayerId, NpcType, Posx, PosY)
	local Player = CCharacterDictator_GetCharacterByID(uPlayerId)
	if IsServerObjValid(Player) then
		Player:MasterOrderServantMoveCommand(NpcType, Posx, PosY)
	end
end

--����NpcΪ�Լ����ٻ���
function Gac2Gas:AgreeTakeOverNpc(Connection, MasterID, NpcID)
	local Master = CCharacterDictator_GetCharacterByID(MasterID)
	local Npc = CCharacterDictator_GetCharacterByID(NpcID)
	if Master == nil or Npc == nil or Npc.m_CanBeTakeOver == nil or type(Npc.m_CanBeTakeOver) ~= "table" then
		return
	end
	local NpcAIType = Npc.m_CanBeTakeOver["NpcAIType"]
	local NpcType	= Npc.m_CanBeTakeOver["NpcType"]
	local NpcCamp	= Npc.m_CanBeTakeOver["NpcCamp"]
	if NpcAIType == nil or NpcType == nil or NpcCamp == nil then
		return
	end
	Npc:ChangeAIType(Master, NpcAIType, NpcType, NpcCamp)
	Npc.m_CanBeTakeOver = nil	--����û���ٽ�����
	Npc:SynToFollowCanNotTakeOver()
end

function Gac2Gas:TruckFollow(Connection, uTruckID)
	local Truck = CCharacterDictator_GetCharacterByID(uTruckID)
	if IsServerObjValid(Connection.m_Player) and IsServerObjValid(Truck) then
		Truck:ChangeTruckState(1)
	end
end

function Gac2Gas:TruckStop(Connection, uTruckID)
	local Truck = CCharacterDictator_GetCharacterByID(uTruckID)
	if IsServerObjValid(Truck) then
		Truck:ChangeTruckState(2)
	end
end

function Gac2Gas:TruckKillSelf(Connection, uTruckID)
	local Truck = CCharacterDictator_GetCharacterByID(uTruckID)
	if IsServerObjValid(Truck) then
		Truck:ChangeTruckState(3)
	end
end
----------------------------------------------------- ��Ϊ���� -----------------------------------------------------

--�õ�����NPC�ĳ�ʼ����
function Gac2Gas:GetNpcDirection(Conn, uEntityID)
	local Npc = CCharacterDictator_GetCharacterByID(uEntityID)
	if IsServerObjValid(Npc) and Npc.m_Direction then
		Gas2Gac:RetSetNpcDirection(Conn, uEntityID, Npc.m_Direction)
	end
end


