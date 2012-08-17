cfg_load "scene/Trap_Common"
gas_require "world/trap/TrapServerInc"
gas_require "world/trap/GameGridServerHandler"

g_AllTrap = {}
g_AllTrapNum = {}

g_TrapServerMgr = CTrapServerMgr:new()
g_TrapServerMgr._m_TrapCreateTbl={}
g_TrapServerMgr._m_OnlyTrap = {}


RegMemCheckTbl("_m_OnlyTrap", g_TrapServerMgr._m_OnlyTrap)
RegMemCheckTbl("g_AllTrap", g_AllTrap)
AddCheckLeakFilterObj(g_TrapServerMgr._m_TrapCreateTbl)

function CTrapServerMgr:AddTrapTbl(key,tbl)
	assert(nil == self._m_TrapCreateTbl[key])
	self._m_TrapCreateTbl[key] = tbl
end

--�õ���ǰ����Ψһ��intobj
function GetOnlyTrap(uSceneId, sTrapName)
	if g_TrapServerMgr._m_OnlyTrap[uSceneId] then
		--assert(g_TrapServerMgr._m_OnlyTrap[uSceneId][sTrapName], sTrapName.."�����ڻ���ΨһObj")
		return g_TrapServerMgr._m_OnlyTrap[uSceneId][sTrapName]
	end
	return
end

function CTrapServerMgr:CreateSceneTrap( Scene , File , isDynamicCreate)
	local srcTbl, indexTbl = g_AreaSceneDataMgr:GetTrapTbl(Scene, File, isDynamicCreate)
	if srcTbl==nil then
		return
	end
	if indexTbl and not next(indexTbl) then
		return
	end
	local forTbl = indexTbl or srcTbl
	for i, v in pairs(forTbl) do
		local p = indexTbl and srcTbl[v] or v
		local pos=CFPos:new()
		pos.x, pos.y = p.GridX, p.GridY
		if Scene.m_DynamicCenterPos then --��̬Trap����ʱ�� ͨ�����λ�ü�������
			pos.x = pos.x + Scene.m_DynamicCenterPos[1]
			pos.y = pos.y + Scene.m_DynamicCenterPos[2]
		end	
		if pos.x==nil or pos.y==nil then
			assert(false ,"����Ϊ��")
		end	
		CreateServerTrap(Scene, pos, p.Name, p.Direction)
	end
end

local function AccountTrapPixelPos(n)
	local param = n % 64
	return n - param + 32
end

local tbl_SeeType = {
						["Player"] 	= ETrapSeeType.ETrapSeeType_Player,
						["Npc"]		= ETrapSeeType.ETrapSeeType_Npc,
						["All"]		= ETrapSeeType.ETrapSeeType_All,
						["None"]	= ETrapSeeType.ETrapSeeType_None,
					}

function CreateServerTrap(Scene,Pos,sTrapName, Direction)

	--��ⳡ��Trap�Ƿ񳬳�����
	local bLimit = GasConfig.SceneObjLimit
	local tbl  = Scene_Common[Scene.m_SceneName]
	local uMaxLimit = Scene_Common[Scene.m_SceneName].TrapLimit
	local uSceneId = Scene.m_SceneId
	if bLimit and g_AllTrapNum[uSceneId] and g_AllTrapNum[uSceneId] > uMaxLimit then
		local errmsg = "������" .. Scene.m_SceneName .. "��ͬʱ���ڵ�Trap��������������ƣ� ��" .. uMaxLimit .. "�������������������"
		LogErr(errmsg, sTrapName)
		return nil
	end
	
	assert(Trap_Common(sTrapName), "Trap_Common���в��Ҳ��� "..sTrapName)
	local TrapEvent = GetCfgTransformValue(true, "Trap_Common", sTrapName, "TrapEvent")
	local TrapArg = GetCfgTransformValue(true, "Trap_Common", sTrapName, "Arg")
	local TriggerTime = Trap_Common(sTrapName, "TriggerTime")
	if TriggerTime == "" or TriggerTime == 0 then
		TriggerTime = nil
	end
	
	local Trap = nil
	local PixelPos = CFPos:new()
	PixelPos.x = AccountTrapPixelPos(Pos.x* EUnits.eGridSpanForObj)
	PixelPos.y = AccountTrapPixelPos(Pos.y* EUnits.eGridSpanForObj)
	
	Trap = CEntityServerCreator_CreateServerIntObject(Scene.m_CoreScene, PixelPos, "IntObj", sTrapName )

	if not Trap then
		LogErr("trap����ʧ��", "������:" .. Scene.m_SceneName .. "  trap��:" ..  sTrapName)
		return
	end
	RegOnceTickLifecycleObj("Trap",Trap)
	
	Trap:SetAndSyncActionDir(Direction)
	local CallbackHandler = CIntObjCallbackHandler:new()
	Trap:SetCallbackHandler(CallbackHandler)
	Trap.m_Scene = Scene
	Trap.m_Pos = Pos
	
	Trap.m_OnTrapCharIDTbl = {}
	Trap.m_CoreScene = Scene.m_CoreScene
	Trap.m_Properties = CServerIntObjProperties:new()
	Trap.m_Properties:InitTrap(Trap)
	Trap.m_Properties:InitTrapStatic(sTrapName, ECharacterType.Trap)
	Trap.m_TrapHandler = CGameGridServerHandler:new()
	Trap.m_TrapHandler:Init(TriggerTime, Trap)
	
	local SeeType = tbl_SeeType[ Trap_Common(sTrapName, "ActionType") ]
	if SeeType == ETrapSeeType.ETrapSeeType_Npc then
		local ActionName = GetCfgTransformValue(true, "Trap_Common", sTrapName, "ActionName")
		if ActionName ~= "" and table.getn(ActionName) ~= 0 then
			for _,v in pairs(ActionName) do
				Trap:InsertNpcSet(v)
			end
		end 
		Trap:OnSetNpcArgEnd()
	end
	
	Trap:SetIntObjSeeType(SeeType)
	Trap:SetEyeSight(0)
	Trap:SetSize( Trap_Common(sTrapName, "AoiRange") )
	Trap:SetStealth(0)
	Trap:SetKeenness(0)
	
	--�尡�壬������Ҫ�ڳ�����1������������п������
	local function SetEyeSight(Trap)
		if IsCppBound(Trap) then --C++�иö�������Ѿ����ɵ���
			local sTrapName = Trap.m_Properties:GetCharName()
			Trap:SetEyeSight( Trap_Common(sTrapName, "AoiRange") )
		end
	end
	RegisterOnceTick(Trap,"TrapServerEyeSightTick", SetEyeSight, 1000, Trap)
	
	for n=1, #TrapEvent do
		local CallBack = {InTrapEvent[TrapEvent[n]], TrapArg[n]}
		assert(TrapArg[n], "���� "..sTrapName.." ��Arg��д����")
		assert(InTrapEvent[TrapEvent[n]], "�����¼�("..TrapEvent[n]..")û��ע�ᵽInTrapEvent��")
		Trap.m_TrapHandler:AddCallback(CallBack)
	end
	local SceneId = Scene.m_SceneId
	if g_AllTrap[SceneId] == nil then
		g_AllTrap[SceneId] = {}
		g_AllTrapNum[SceneId] = 0
	end
	g_AllTrapNum[SceneId] = g_AllTrapNum[SceneId] + 1
	
	g_AllTrap[SceneId][Trap:GetEntityID()] = Trap
	if Trap_Common(sTrapName, "OnlyTrap") == 1 then   --�����ڵ�Ψһ Trap
		if g_TrapServerMgr._m_OnlyTrap[SceneId] == nil then
			g_TrapServerMgr._m_OnlyTrap[SceneId] = {} 
		end
		if g_TrapServerMgr._m_OnlyTrap[SceneId][sTrapName] == nil then
			g_TrapServerMgr._m_OnlyTrap[SceneId][sTrapName] = Trap
		else 
			assert(false, "Obj "..sTrapName.." �����ǳ�����Ψһ��(�����ñ�Trap_Common)")
		end
	end
	
	local ExistTime = Trap_Common(sTrapName, "ExistTime")
	
	if ExistTime ~= "" and ExistTime ~= 0 then
		RegisterOnceTick(Trap,"TrapServerExistTick", DestroyServerTrap, ExistTime, Trap)
	end
	Trap:SetObjName(sTrapName)
	
	--����Trap�����¼�
	g_TriggerMgr:Trigger("����", Trap)
 	return Trap
end

local function ClearTrapData( Trap)
	local PlayerIDTbl = Trap.m_OnTrapCharIDTbl
	if PlayerIDTbl == nil then
		return 
	end
	local TrapName = Trap.m_Properties:GetCharName()
	local TrapID = Trap:GetEntityID()
	for _, ID in pairs( PlayerIDTbl) do 
		local Player = CEntityServerManager_GetEntityByID(ID)
		if Player and Player.m_Properties.m_InTrapTblName then
			if Player.m_Properties.m_InTrapTblName[TrapName] then
				Player.m_Properties.m_InTrapTblName[TrapName][TrapID] = nil
			end
		end
	end
	g_TriggerMgr:Trigger("����", Trap)
end

local function ClearTrapTbl(IntObj)
	if IntObj == nil then
		return
	end
	if IntObj.m_Properties:GetType() == ECharacterType.Trap then
		local TrapName = IntObj.m_Properties:GetCharName()	
		if IntObj.m_TrapHandler == nil then
			return
		end
		--�������������˵�ID(remove)
		local TrapCharIDTbl = IntObj.m_OnTrapCharIDTbl
		for i, v in pairs(TrapCharIDTbl) do 
			local CharacterID = IntObj.m_OnTrapCharIDTbl[i]
			IntObj.m_OnTrapCharIDTbl[i] = nil
			local Character = CCharacterDictator_GetCharacterByID(CharacterID)
			if Character then
				local isLeaveTrap = true
				local TrapTbl = Character.m_Properties.m_InTrapTblName
				if TrapTbl then
					if TrapTbl[TrapName] and TrapTbl[TrapName][ObjEntityID] then
						TrapTbl[TrapName][ObjEntityID] = nil
						IntObj.m_TrapHandler:ClearTriggertblData()
						if next(TrapTbl[TrapName]) then	
							isLeaveTrap = false
						end
					else
						isLeaveTrap = false
					end
				end
				if isLeaveTrap then
					IntObj.m_TrapHandler:OnStepOutByCharacter(Character)
					g_TriggerMgr:Trigger("��", IntObj, Character)
				end
			end
		end
	end
	IntObj.m_hasbenil = 0
end

function DestroyServerTrap(Trap, bReborn)
	if Trap == nil then
		return
	end
	UnRegisterObjOnceTick(Trap)
	ClearTrapData( Trap)
	--CreateServerTrap(Scene,Pos,sTrapName)
	-- yy �õ�TRAP �������Ϣ���ڴ���TRAP
	Trap.m_TrapHandler:OutStepAutoTrip()
	local scene = Trap.m_Scene	--��ͼ
	local pos = CPos:new()			--λ��
	Trap:GetGridPos(pos)	
	local trapName = Trap.m_Properties:GetCharName()	--trap ����
	local TrapRBornTime = 0														--trap ����ʱ�� ����
	if trapName ~= nil then
		TrapRBornTime = Trap_Common(trapName, "RebornTime")
	end
	if TrapRBornTime == "" or TrapRBornTime == nil then
		TrapRBornTime = 0
	end
	
	Trap.m_TrapHandler:RemoveCallback()
	if Trap.m_TrapHandler.m_StateTick~=nil then
		UnRegisterTick(Trap.m_TrapHandler.m_StateTick)
	end
	
	local SceneId = Trap.m_Scene.m_SceneId
--	local TrapName = Trap.m_Properties:GetCharName()
	if g_TrapServerMgr._m_OnlyTrap[SceneId] and g_TrapServerMgr._m_OnlyTrap[SceneId][trapName] then
		g_TrapServerMgr._m_OnlyTrap[SceneId][trapName] = nil
	end
	g_AllTrap[SceneId][Trap:GetEntityID()] = nil
	g_AllTrapNum[SceneId] = g_AllTrapNum[SceneId] - 1
	
	ClearTrapTbl(Trap)
	CEntityServerCreator_DestroyEntity(Trap)
	Trap.m_TrapHandler = nil
	Trap = nil
	
	if TrapRBornTime == 0 or bReborn == false then
		return
	end
	
	--����
	local function ReCTrap()
		CreateServerTrap( scene, pos, trapName)
	end
	RegisterOnceTick(scene,"RebornTickTripgh", ReCTrap, TrapRBornTime)
end

function DestroyOneSceneTrap(uSceneID)
	if g_AllTrap[uSceneID] then
		for _, Trap in pairs(g_AllTrap[uSceneID]) do
			DestroyServerTrap(Trap,false)
		end
		g_TrapServerMgr._m_OnlyTrap[uSceneID] = nil
		g_AllTrap[uSceneID] = nil
		
		g_AllTrapNum[uSceneID] = nil
	end
end	

