gas_require "world/npc/LifeOriginInc"
gas_require "world/trigger_action/RandomCreate"
gas_require "world/npc/NpcBossServer"

cfg_load "npc/Npc_Common"
cfg_load "scene/Trap_Common"
cfg_load "npc/NoDynamicRebornNpc_Server"

g_NpcBornMgr = LifeOrigin:new()

g_NpcBornMgr._m_SinglePointBornTbl = {}
AddCheckLeakFilterObj(g_NpcBornMgr._m_SinglePointBornTbl)

g_NpcBornMgr._m_AllNpc = {}
g_NpcBornMgr._m_OnlyNpc = {}
g_NpcBornMgr._m_Colony	= {}
g_NpcBornMgr._m_GlobalColonyId = 0  --�Ŷ�id��������
g_NpcBornMgr._m_TempColonyIdIndex = {} --��ʱ�Ŷ�id ��Ӧ��, �� CreateSceneNpc ������
g_NpcBornMgr.AllNpcNum = {}

RegMemCheckTbl("g_NpcBornMgr._m_AllNpc", g_NpcBornMgr._m_AllNpc)
RegMemCheckTbl("g_NpcBornMgr._m_OnlyNpc", g_NpcBornMgr._m_OnlyNpc)
RegMemCheckTbl("g_NpcBornMgr._m_Colony", g_NpcBornMgr._m_Colony)


-- ��ӵ���ˢ�� NPC ��
function LifeOrigin:AddSinglePointBornTbl(key, tbl)
	assert(nil == self._m_SinglePointBornTbl[key])
	self._m_SinglePointBornTbl[key] = tbl
end



function LifeOrigin:DeleteAllNpc(uSceneID)
	if(self._m_AllNpc and self._m_AllNpc[uSceneID])then 
		for _,Npc in pairs(self._m_AllNpc[uSceneID]) do
			g_NpcServerMgr:ShutDownOrDestroySceneDeleteNpc(Npc, false)	
		end
		self._m_OnlyNpc[uSceneID] = nil
		self._m_Colony[uSceneID] = nil
		self._m_AllNpc[uSceneID] = nil
		
		self.AllNpcNum[uSceneID] = nil
	end
end

function LifeOrigin:DeleteAllNpcExceptServant(uSceneID)	--ɾ���������ٻ��������е�Npc
	if(g_NpcBornMgr._m_AllNpc and g_NpcBornMgr._m_AllNpc[uSceneID])then 
		for _,Npc in pairs(g_NpcBornMgr._m_AllNpc[uSceneID]) do
			if not NpcInfoMgr_BeServantType(Npc:GetNpcType()) then
				g_NpcServerMgr:ShutDownOrDestroySceneDeleteNpc(Npc, false)	
			end
		end
	end
end

function LifeOrigin:CheckNpcSceneFile()
	local errornum = 0
	--���Npc�ڹ���Ϣ
	local havechecknametbl = {}
	for file, npctbl in pairs(self._m_SinglePointBornTbl) do
		--print("���ڹ��ļ� " .. file)
		local group = {}
		havechecknametbl[file] = {}
		for i = 1, table.maxn(npctbl) do
			if npctbl[i] then
				if not npctbl[i].GridX or not IsNumber(npctbl[i].GridX)  then
					print("�ڹ��ļ�"..file.."�еĵڡ�"..i.."����Npc�ġ�X���꡿����ȷ")
					errornum = errornum+1
				end
				if not npctbl[i].GridY or not IsNumber(npctbl[i].GridY) then
					print("�ڹ��ļ�"..file.."�еĵڡ�"..i.."����Npc�ġ�Y���꡿����ȷ")
					errornum = errornum+1
				end
				local NpcName = npctbl[i].Name
				if not havechecknametbl[file][NpcName] then
					if Npc_Common(NpcName) == nil then
						print("�ڹ��ļ�"..file.."��Npc��"..NpcName.."����npc_common���в�����")
						errornum = errornum+1
					elseif Npc_Common(NpcName,"OnlyNpc") == 1 then
						for j = 1, table.maxn(npctbl) do
							if j ~= i and npctbl[j] and npctbl[j].Name == NpcName then
								print("�ڹ��ļ���"..file.."����Npc��"..NpcName.."����npc_common���б�ʶΪΨһNpc�����Ǹ�Npc�ڹ���������һ��")
								errornum = errornum+1
								break
							end
						end
					end
					havechecknametbl[file][NpcName] = true
				end
			end
		end
	end
	--���Obj
	havechecknametbl = {}
	for file, objtbl in pairs(g_IntObjServerMgr._m_IntObjCreateTbl) do
		havechecknametbl[file] = {}
		for i = 1, table.maxn(objtbl) do
			if objtbl[i] then
				if not objtbl[i].GridX or not IsNumber(objtbl[i].GridX) then
					print("�ڹ��ļ�"..file.."�еĵڡ�"..i.."����Obj�ġ�X���꡿����ȷ")
					errornum = errornum+1
				end
				if not objtbl[i].GridY or not IsNumber(objtbl[i].GridY)  then
					print("�ڹ��ļ�"..file.."�еĵڡ�"..i.."����Obj�ġ�Y���꡿����ȷ")
					errornum = errornum+1
				end
				local ObjName= objtbl[i].Name
				if not havechecknametbl[file][ObjName] then
					if IntObj_Common(ObjName) == nil then
						print("�ڹ��ļ�"..file.."��Obj��"..ObjName.."����IntObj_Common���в�����")
						errornum = errornum+1
					elseif IntObj_Common(ObjName, "OnlyObj") == 1 then
						for j = 1, table.maxn(objtbl) do
							if j ~= i and objtbl[j] and objtbl[j].Name == ObjName then
								print("�ڹ��ļ���"..file.."����Obj��"..ObjName.."����IntObj_Common���б�ʶΪΨһObj�����Ǹ�Obj�ڹ���������һ��")
								errornum = errornum+1
								break
							end
						end
					end
					havechecknametbl[file][ObjName] = true
				end
			end
		end
	end
	--���Trap
	havechecknametbl = {}
	for file, traptbl in pairs(g_TrapServerMgr._m_TrapCreateTbl) do
		havechecknametbl[file] = {}
		for i = 1, table.maxn(traptbl) do
			if traptbl[i] then
				if not traptbl[i].GridX or not IsNumber(traptbl[i].GridX)  then
					print("�ڹ��ļ�"..file.."�еĵڡ�"..i.."����Trap�ġ�X���꡿����ȷ")
					errornum = errornum+1
				end
				if not traptbl[i].GridY or not IsNumber(traptbl[i].GridY)  then
					print("�ڹ��ļ�"..file.."�еĵڡ�"..i.."����Trap�ġ�Y���꡿����ȷ")
					errornum = errornum+1
				end
				local TrapName= traptbl[i].Name
				if not havechecknametbl[file][TrapName] then
					if not Trap_Common(TrapName) then
						print("�ڹ��ļ�"..file.."��Trap��"..TrapName.."����Trap_Common���в�����")
						errornum = errornum+1
					elseif Trap_Common(TrapName, "OnlyTrap") == 1 then
						for j = 1, table.maxn(traptbl) do
							if j ~= i and traptbl[j] and traptbl[j].Name == TrapName then
								print("�ڹ��ļ���"..file.."��Trap��"..TrapName.."����Trap_Common���б�ʶΪΨһTrap�����Ǹ�Trap�ڹ���������һ��")
								errornum = errornum+1
								break
							end
						end
					end
					havechecknametbl[file][TrapName] = true
				end
			end
		end
	end
	
	print("�ڹ��ļ������ϣ�")
	if errornum > 0 then
		assert(false, "���ڹ��ļ����ִ�������.")
	end
end

-- NPC ����
function LifeOrigin:CreateSceneNpc(Scene, file, isDynamicCreate)
	self._m_IsNpcBeginBorn = true 
	self._m_TempColonyIdIndex = {}
	local NpcCountTbl = nil
	if (Scene:GetSceneType() == 1 or Scene:GetSceneType() == 25) and not isDynamicCreate then
		assert(Scene.m_NpcSortTbl == nil)
		assert(Scene.m_PrimordialNpc == nil)
		Scene.m_PrimordialNpc = {} --����ԭʼnpc
		Scene.m_NpcSortTbl = {}
	end
	local NpcTbl = {}
	
	local srcTbl, indexTbl = g_AreaSceneDataMgr:GetNpcTbl(Scene, file, isDynamicCreate)
	if srcTbl==nil then
		return
	end
	if indexTbl and not next(indexTbl) then
		return
	end
	
	--SinglePointBorn=tbl[][]
	local forTbl = indexTbl or srcTbl
	for i, v in pairs(forTbl) do
		local index, npcData
		if indexTbl then
			index = v
			npcData = srcTbl[index]
		else
			index = i
			npcData = v
		end
		local npc = self:CreateSinglePointBornNpc(Scene, file, index, npcData)
		if not isDynamicCreate and npc then
			local npcName = npcData.Name
			if Scene.m_NpcSortTbl and not NoDynamicRebornNpc_Server(npcName) then
				if not Scene.m_NpcSortTbl[npcName] then
					Scene.m_NpcSortTbl[npcName] = {}
					Scene.m_NpcSortTbl[npcName].AllCount = 0
					Scene.m_NpcSortTbl[npcName].NpcName = npcName
					Scene.m_NpcSortTbl[npcName].RebornQueue = CQueue:new()
				end
				Scene.m_NpcSortTbl[npcName].AllCount = Scene.m_NpcSortTbl[npcName].AllCount + 1
				npc.m_DynamicRebornData = Scene.m_NpcSortTbl[npcName]
			end
			if Scene.m_PrimordialNpc then
				Scene.m_PrimordialNpc[index] = npc
				npc.m_IsPrimordialNpc = true
			end
		end

		NpcTbl[i] = npc
	end
	self:CreatNpcRelation(Scene.m_SceneId)
	self.m_IsNpcBeginBorn = nil
	return NpcTbl
end

--���е�npc������֮�� �������е����͹�ϵ
function LifeOrigin:CreatNpcRelation(SceneId)
	local NpcTbl = self._m_AllNpc[SceneId]
	if NpcTbl == nil then
		return
	end
	for NpcId, Npc in pairs(NpcTbl)	do
		if Npc.m_ColonyType == ENpcColonyType.eNCT_Servant then
			if not self._m_Colony[Npc.m_ColonyID] then
				local cfgColonyId = self._m_SinglePointBornTbl[Npc.m_SettingFileName][Npc.m_SettingFileIndex].ColonyID
				assert(false, Npc.m_Scene.m_SceneName  .."��Ⱥ��IDΪ" .. cfgColonyId .. " ��Ⱥ��û������NPC")
			end
			Npc:SetGroupLeader(self._m_Colony[Npc.m_ColonyID])
			self._m_Colony[Npc.m_ColonyID]:AddGroupMember(Npc)
		end
	end
	for NpcId, Npc in pairs(NpcTbl)	do
		if Npc.m_ColonyType == ENpcColonyType.eNCT_Boss then
			Npc:MoveToPathPoint(1)
		end
	end
end

function LifeOrigin:AddNpcToGroup(Npc)
	if Npc.m_ColonyID ~= nil and 	Npc.m_ColonyType  == ENpcColonyType.eNCT_Servant then
		if self._m_Colony[Npc.m_ColonyID] ~= nil then
			local leaderNpc = self._m_Colony[Npc.m_ColonyID]
			if not IsCppBound(leaderNpc) then
				assert(false,Npc.m_Scene.m_SceneName .. Npc.m_Scene.m_SceneId .."Ⱥ��IDΪ" .. Npc.m_ColonyID .. "������NPC�Ѿ���Ч!!!!,������AddNpcToGroup(Npc)ʱ������,���Բ������")
			end
			Npc:SetGroupLeader(self._m_Colony[Npc.m_ColonyID])
			self._m_Colony[Npc.m_ColonyID]:AddGroupMember(Npc)
			self:AddNpcToWarZone(Npc)
		end	
	end	
end

--���ս��Ѳ��npc���
function LifeOrigin:AddNpcToWarZone(Npc)
	local Scene = Npc.m_Scene
	local WarZone = Scene.m_CoreWarZone
	if WarZone then
		local PatrolIndex = WarZone.m_ColonyIDToSentryIndexTbl[Npc.m_ColonyID]
		local warZoneSentryPatrol = WarZone.m_SentryPatrolTbl[PatrolIndex]
		for k, index in pairs(warZoneSentryPatrol.m_NpcDeadTbl) do
			Npc.m_WarZoneId = WarZone.m_WarZoneId
			Npc.m_PatrolIndex = PatrolIndex
			Npc.m_Index = index
			warZoneSentryPatrol.m_NpcTbl[index] = Npc
			warZoneSentryPatrol.m_NpcDeadTbl[k] = nil
			break
		end
	end
end


-- �õ� NPC �ĳ����ȼ�������С���ȼ������
function LifeOrigin:GetNpcBornLevel(NpcName)
	local Setting = Npc_Common(NpcName)

	--print(NpcName)
	assert(Setting,"�ڹֱ༭���е� "..NpcName.."��Npc_Common�в��Ҳ���") -- ˵�� NPC �������NPC �ܱ�����û����� NPC

	local min, max = Setting("MinLevel"), Setting("MaxLevel")

	assert(min <= max)  -- ˵���ȼ���Χ��ֵ�����

	if min == max then	-- �ȼ��޷�Χֱ�ӷ��ȼ�
		return min
	end

	return math.random(min,max)
end

function LifeOrigin:SetNpcMovePath(Npc, Setting, centerPos)

	--Speed=2 Npc��
	--Speed=3 Npc��
	--һ��Npc��ʼ����·����2��ֻ����Ϊ3ʱ�����ã�PS:Ϊɶ��2��3������0��1�أ��壩
	if Setting.Speed ~= nil then
		if (Setting.Speed == 3) then		
			Npc:SetDefaultWalkState(false)
		end
	end
	if Setting.MoveType == nil or Setting.MoveType == ENpcMoveType.ENpcMove_None then		--���ƶ�
		Npc:SetMoveType(ENpcMoveType.ENpcMove_None)
	elseif Setting.MoveType == ENpcMoveType.ENpcMove_Random then								--Npc����ƶ�
		Npc:SetMoveType(ENpcMoveType.ENpcMove_Random)
		if Setting.MoveRange ~= nil and Setting.MoveRange ~= 0 then
			Npc:SetMoveRange(Setting.MoveRange)
		end 
		Npc:OnBeginRandomMove()	
	elseif Setting.MoveType == ENpcMoveType.ENpcMove_Cycle 
		or Setting.MoveType == ENpcMoveType.ENpcMove_Trip 
		or Setting.MoveType == ENpcMoveType.ENpcMove_MoveInPath then
		local path = Setting.Path
		if path ~= nil and path[2] then --Ѳ��·��������2����
			for i,p in pairs(path) do
				Npc:SetMovePath(i, p[1] + centerPos[1], p[2] + centerPos[2])	--����Ѳ��·��
			end
			Npc:SetMoveType(Setting.MoveType)
			if Setting.MoveType == ENpcMoveType.ENpcMove_MoveInPath then
				Npc:NpcMoveInPath()
			elseif Setting.ColonyType == nil or Setting.ColonyType == 0 then
				Npc:MoveToPathPoint(1)		
			end
		else
			local strErr = "Npc: " .. Npc.m_Name .. " ���ڳ����� " .. Npc.m_Scene.m_SceneName .. " Ѳ�����ͣ� " .. MapMoveType2Name[Setting.MoveType] .. " �ڹ�·���������ٵ�������·���㣡����ز߻�������ñ�"
			CfgLogErr(strErr)
		end
	elseif 	Setting.MoveType == ENpcMoveType.ENpcMove_SingleLine 
			or Setting.MoveType == ENpcMoveType.ENpcMove_Single2Random then
		local path = Setting.Path
		if path ~= nil and path[1] then --����Ѳ����������һ����
			for i,p in pairs(path) do
				Npc:SetMovePath(i, p[1] + centerPos[1], p[2] + centerPos[2])	--����Ѳ��·��
			end
			Npc:SetMoveType(Setting.MoveType)
			Npc:MoveToPathPoint(1)		
		else
			local strErr = "Npc: " .. Npc.m_Name .. " ���ڳ����� " .. Npc.m_Scene.m_SceneName .. " Ѳ�����ͣ� " .. MapMoveType2Name[Setting.MoveType] .. " ����Ѳ�����ٵ���һ��Ѳ�ߵ㣡����ز߻�������ñ�"
			CfgLogErr(strErr)
		end
	end	
end

-- ��������NPC ��������Ϣ, 
--�¼Ӳ���RebornData  ����npc��������ʱ�򴫴˲���, ����ʱ��Ϊnil
function LifeOrigin:CreateNpcSetInfo(Scene, File, Index, Setting, x,y,RebornData)
	local centerPosX = 0
	local centerPosY = 0
	if Scene.m_DynamicCenterPos then --��̬npc����ʱ�� ͨ�����λ�ü�������
		centerPosX = Scene.m_DynamicCenterPos[1]
		centerPosY = Scene.m_DynamicCenterPos[2]
	end
	local Pos = CFPos:new(x + centerPosX, y + centerPosY)
	local Name = Setting.Name
	local Config = Npc_Common(Name)
	local Level = self:GetNpcBornLevel(Name)	
	local ClickStr = Setting.OnClicked
	local AIType = Config("AIType")
	local NpcType = Config("Type")
	local Npc = nil
	local logMsg = nil
	local fPos = CFPos:new( Pos.x * EUnits.eGridSpan, Pos.y * EUnits.eGridSpan )
	--Npc��ʼ������
	local IdleType = nil
	if Setting.IdleType ~= nil then	
		if Setting.IdleType == 2 then
			IdleType = EActionState.eAS_Still_3
		elseif Setting.IdleType == 1 then
			IdleType = EActionState.eAS_Still_2
		elseif Setting.IdleType == 3 then
			IdleType = EActionState.eAS_Birth
		else 
			IdleType = EActionState.eAS_Still_1
		end
	else
		IdleType = EActionState.eAS_Still_1
	end

	if EnmityShareTeam_Server(Name) == nil then
		Npc, logMsg = g_NpcServerMgr:CreateServerNpc(Name, Level, Scene, fPos, nil, nil , AIType, NpcType, nil, nil, Setting.Direction, Setting.IsIgnoreClog)
	else
		Npc, logMsg = CreateServerNpcGroup(Name, Level, Scene, fPos, nil , AIType, NpcType, nil, nil)
	end

	if not IsServerObjValid(Npc) then
		LogErr("����Npcʧ��", logMsg)
		return
	end
	Npc.m_RebornTime = Config("RebornTime")
	Npc.m_RebornPos = Pos
	Npc.m_SettingFileName = File
	Npc.m_SettingFileIndex = Index
	Npc.m_Direction = Setting.Direction
	Npc:SetNpcBirthDir(Setting.Direction)

	if Setting.ColonyType ~= nil and Setting.ColonyType ~= 0 then 
		if Config("Type") ~= "����Npc" and Config("Type") ~=  "�Ŷӳ�Ա" then
			assert(false, Scene.m_SceneName .." ����������Ϊ " .. Name .. " ��NPC��AI���Ͳ�����Ⱥ�����ͣ�ȴ������ΪȺ��֣�����")
		end
	end

	if Setting.ColonyType ~= nil and Setting.ColonyType ~= 0 then
		local colonyID
		if RebornData then
			assert(RebornData.ColonyID)
			assert(self._m_Colony[RebornData.ColonyID])
			colonyID = RebornData.ColonyID
		else
			assert(self._m_IsNpcBeginBorn)
			if self._m_TempColonyIdIndex[Setting.ColonyID] == nil then
				self._m_TempColonyIdIndex[Setting.ColonyID] = self._m_GlobalColonyId
				colonyID = self._m_GlobalColonyId
				self._m_GlobalColonyId = self._m_GlobalColonyId + 1
			else
				colonyID = self._m_TempColonyIdIndex[Setting.ColonyID]
			end
		end

		Npc.m_ColonyID = colonyID
		Npc.m_ColonyType = Setting.ColonyType
	end

	if	Setting.ColonyType ~= nil and Setting.ColonyType == ENpcColonyType.eNCT_Boss then
		assert(self._m_Colony[Npc.m_ColonyID] == nil,Scene.m_SceneName .. Scene.m_SceneId .. "Ⱥ��IDΪ" ..  Setting.ColonyID .. "��Ⱥ������쳣" .. "һ������Ⱥ����������boss")
		self._m_Colony[Npc.m_ColonyID] = Npc
	end

	if Setting.ColonySelfID ~= nil then
		Npc:SetGroupMemberID(Setting.ColonySelfID)
	end

	local centerPos = {centerPosX, centerPosY}
	self:SetNpcMovePath(Npc, Setting, centerPos)
	
	Npc:CheckPlayInNpcSleepDim()
	--print("Npc����������ϣ���������������������������������������������������������������������������������������")
	Npc.m_DynamicCenterPos = Scene.m_DynamicCenterPos
	return Npc
end
-- ��������ˢ�� NPC
function LifeOrigin:CreateSinglePointBornNpc(Scene, file, Index, Setting)
	local npc = self:CreateNpcSetInfo(Scene, file, Index, Setting, Setting.GridX, Setting.GridY)
	return npc
end


-- NPC ��������
function LifeOrigin:WhoDead(Who)
	if Who.m_SettingFileName == nil or Who.m_SettingFileIndex == nil or Who.IsQueueReborn then
		return
	end
		--��� borntimeΪ0���� RebornInfo.file�����ڣ�˵�����ǰڹ�Npc��������
	if Who.m_RebornTime == 0 or Who.m_RebornTime == nil or Who.m_SettingFileName == nil then
		return
	end
	
	local RebornInfo = {}
	RebornInfo.Scene = Who.m_Scene
	RebornInfo.file  = Who.m_SettingFileName			
	RebornInfo.Index = Who.m_SettingFileIndex
	RebornInfo.ColonyID = Who.m_ColonyID
	RebornInfo.m_DynamicCenterPos = Who.m_DynamicCenterPos
	RebornInfo.m_DynamicRebornData = Who.m_DynamicRebornData
	RebornInfo.m_IsPrimordialNpc = Who.m_IsPrimordialNpc
	
	RegisterOnceTick(Who.m_Scene,"ChildbirthTick", LifeOrigin.NpcReborn, Who.m_RebornTime, self, RebornInfo)
end


-- NPC ��������ˢ�£�������
function LifeOrigin:NpcReborn(data)
	local Npc
	local setting = self._m_SinglePointBornTbl[data.file][data.Index]
	local scene = data.Scene
	scene.m_DynamicCenterPos = data.m_DynamicCenterPos
	
	local function Init()
				--���������Ŷ�NPC������
		if data.m_IsPrimordialNpc and scene.m_PrimordialNpc[data.Index] then
			LogErr("�ڹ��ļ���npc �ظ�����!!   �Ѿ���ֹ,�뿼���п��ܵ����ظ��������߼�",  setting.Name)
			return
		end
		
		local rebornPos = CFPos:new()
		if data.ColonyID ~= nil and data.ColonyID ~= 0  and setting.ColonyType ~= ENpcColonyType.eNCT_Boss then
			local selfColonyID = setting.ColonySelfID
			local leaderNpc = self._m_Colony[data.ColonyID]
			if not IsCppBound(leaderNpc) then
				assert(false,scene.m_SceneName .. scene.m_SceneId .."Ⱥ��IDΪ" .. setting.ColonyID .. "������NPC�Ѿ���Ч!!!!,���ǲ������,�����ڴ���NPC����Ϊ" .. setting.Name .. "�����������λ��ʱ������")
			end
			if not leaderNpc:IsInitMemberPathPoint(selfColonyID) then
				assert(false,scene.m_SceneName .. scene.m_SceneId .."Ⱥ��IDΪ" .. setting.ColonyID .." selfColonyIDΪ " ..selfColonyID.. " ���Ŷӳ�ԱNPCû�г�ʼ��·��������������!!!!,���ǲ������,�����ڴ���NPC����Ϊ" .. setting.Name .. "ʱ������")
			end
			leaderNpc:GetGroupMemberRebornPosition(selfColonyID,rebornPos)
			local gridX = rebornPos.x / EUnits.eGridSpanForObj
			local gridY = rebornPos.y / EUnits.eGridSpanForObj
			Npc = self:CreateNpcSetInfo(scene, data.file, data.Index, setting, gridX, gridY, data)
		elseif  setting.ColonyType == ENpcColonyType.eNCT_Boss then
			assert(false,scene.m_SceneName .. setting.ColonyID .."����NPC�����Ǿ��Բ���������,���ڳ�����!!!!!!!")
		else
			Npc = self:CreateNpcSetInfo(scene, data.file, data.Index, setting, setting.GridX, setting.GridY, data)	
		end
		self:AddNpcToGroup(Npc)
		Npc.m_DynamicRebornData = data.m_DynamicRebornData
		Npc.m_IsPrimordialNpc = data.m_IsPrimordialNpc
		if data.m_IsPrimordialNpc then
			scene.m_PrimordialNpc[data.Index] = Npc
		end
	end
	
	apcall(Init)
		--���ó��������
	scene.m_DynamicCenterPos = nil
end



function LifeOrigin:SetNpcGroupMemberID()
	for file, npctbl in pairs(self._m_SinglePointBornTbl) do
		local group = {}
		for i = 1, table.maxn(npctbl) do
			--����Ŷ��ڲ����
			if npctbl[i] then
				if npctbl[i].ColonyID ~= 0 then
					if group[npctbl[i].ColonyID] == nil then
						group[npctbl[i].ColonyID] = 0
					end
					if npctbl[i].ColonyType == ENpcColonyType.eNCT_Servant then
						group[npctbl[i].ColonyID] = group[npctbl[i].ColonyID] + 1
						npctbl[i].ColonySelfID = group[npctbl[i].ColonyID] 
					end
				end
			end
		end
	end
end

function LifeOrigin:CleanColony(Npc)
	if self._m_Colony[Npc.m_ColonyID] ~= nil and self._m_Colony[Npc.m_ColonyID] == Npc then
		self._m_Colony[Npc.m_ColonyID] = nil
	end
end

function UpdateCorpseTick(tick, DynamicRebornData)
	if DynamicRebornData.CorpseTick then
		UnRegisterTick(DynamicRebornData.CorpseTick)
		DynamicRebornData.CorpseTick = nil
	end
	local nowTime = os.time() * 1000
	local corpseTime = Npc_Common(DynamicRebornData.NpcName, "CorpseTime")
	local corpseCount = DynamicRebornData.RebornQueue:size()
	--print("corpseTime:",corpseTime, " corpseCount:",corpseCount )
	local iter = DynamicRebornData.RebornQueue._begin
	while iter do
		local data = iter._value
		local npc = data.Npc
		if npc then  --˵������ʬ��״̬
			local curCorpseTime = corpseTime * (1 - corpseCount/DynamicRebornData.AllCount)
			if nowTime - data.DeadTime  >= curCorpseTime - 1500 then
				local RebornInfo = {}
				RebornInfo.Scene = npc.m_Scene
				RebornInfo.file  = npc.m_SettingFileName			
				RebornInfo.Index = npc.m_SettingFileIndex
				RebornInfo.ColonyID = npc.m_ColonyID
				RebornInfo.m_DynamicCenterPos = npc.m_DynamicCenterPos
				RebornInfo.m_DynamicRebornData = npc.m_DynamicRebornData
				RebornInfo.m_IsPrimordialNpc = npc.m_IsPrimordialNpc
				apcall(g_NpcServerMgr.DestroyServerNpcNow,g_NpcServerMgr,npc, true)
				data.Npc = nil
				data.DeadTime = nil
				data.RebornInfo = RebornInfo
				data.DisappearTime = nowTime
				--print("ʬ����ʧ", corpseCount)
			else
				DynamicRebornData.CorpseTick = RegisterTick("DynamicCorpseTick", UpdateCorpseTick, curCorpseTime - (nowTime - data.DeadTime), DynamicRebornData)
				--print("ע��ʬ����ʧtick", curCorpseTime - (nowTime - data.DeadTime),  "  ��ǰʬ��ʱ��", curCorpseTime, corpseCount)
				break
			end
		end
		corpseCount = corpseCount - 1
		iter = iter._next
	end
	
	UpdateRebornTick(nil, DynamicRebornData)
end

function UpdateRebornTick(tick, DynamicRebornData)
	if DynamicRebornData.RebornTick then
		UnRegisterTick(DynamicRebornData.RebornTick)
		DynamicRebornData.RebornTick = nil
	end
	local nowTime = os.time() * 1000
	local rebornTime = Npc_Common(DynamicRebornData.NpcName, "RebornTime")
	local liveCount = DynamicRebornData.AllCount - DynamicRebornData.RebornQueue:size()
	local iter = DynamicRebornData.RebornQueue._begin
	while iter do
		local data = iter._value
		if not data.Npc then
			local curRebornTime =  rebornTime -- rebornTime * (1 - corpseCount/DynamicRebornData.AllCount)
			if nowTime - data.DisappearTime  >= curRebornTime - 1500 then
				DynamicRebornData.RebornQueue:pop()
				apcall(LifeOrigin.NpcReborn, g_NpcBornMgr, data.RebornInfo)
				iter = DynamicRebornData.RebornQueue._begin
				--print("ֱ������!!!!", liveCount)
			else
				DynamicRebornData.RebornTick = RegisterTick("DynamicRebornTick", UpdateRebornTick, curRebornTime - (nowTime - data.DisappearTime), DynamicRebornData)
				--print("ע������tick ", curRebornTime - (nowTime - data.DisappearTime),    "   ��ǰ����ʱ��", curRebornTime, liveCount)
				break
			end
		else
			break
		end
		liveCount = liveCount + 1
	end
end

function UpdateRebornQueue(DynamicRebornData)
	local rebornQueue = DynamicRebornData.RebornQueue
	local deadCount = rebornQueue:size()
	if deadCount > DynamicRebornData.AllCount then
		LogErr("Npc��������Ȼ���ڰڹ���!!", DynamicRebornData.NpcName)
	end
	UpdateCorpseTick(nil, DynamicRebornData)
end
