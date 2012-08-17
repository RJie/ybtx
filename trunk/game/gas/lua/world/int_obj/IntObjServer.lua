gas_require "framework/main_frame/SandBoxDef"
gas_require "world/int_obj/IntObjServerInc"
gas_require "world/int_obj/IntObjCallbackHandlerServer"
gas_require "world/trigger_action/RandomCreate"
gas_require "world/trigger_action/obj/ActionLoadProgress"
cfg_load"int_obj/ObjAction_Server"
cfg_load "scene/Trap_Common"

g_AllIntObj = { }
RegMemCheckTbl("g_AllIntObj", g_AllIntObj)
g_AllIntObjNum = {}
local LogDataTemp  --- Ϊ����obj��λ bug

local function RequireOnClickedObjScript(Obj,strOnClicked)
	local scriptFileName = g_AllObjScript[strOnClicked]
--------------------------------------------------
	if scriptFileName ~= nil then
		local entry = RequireSandBox(scriptFileName)
		if entry ~= nil then
			if strOnClicked == "�ɼ�����" then
				Obj.m_IsLode = true
			end
			Obj.m_DlgOnClicked:Add(entry.Exec)
		end
	end
end

g_IntObjServerMgr = CIntObjServerMgr:new()
g_IntObjServerMgr._m_IntObjCreateTbl={}
g_IntObjServerMgr._m_OnlyObj = {}
g_IntObjServerMgr.m_Barrier = {}

RegMemCheckTbl("g_IntObjServerMgr._m_OnlyObj", g_IntObjServerMgr._m_OnlyObj)
RegMemCheckTbl("g_IntObjServerMgr.m_Barrier", g_IntObjServerMgr.m_Barrier)
AddCheckLeakFilterObj(g_IntObjServerMgr._m_IntObjCreateTbl)

function CIntObjServerMgr:AddIntObjTbl(key,tbl)
	assert(nil == self._m_IntObjCreateTbl[key])
	self._m_IntObjCreateTbl[key] = tbl
end
function CIntObjServerMgr:Ctor()
end

--�õ���ǰ����Ψһ��intobj
function GetOnlyIntObj(uSceneId, sObjName)
	if g_IntObjServerMgr._m_OnlyObj[uSceneId] then
		return g_IntObjServerMgr._m_OnlyObj[uSceneId][sObjName]
	end
	return
end

local function CreateSingleServerObj(IntObjCommon,Scene,Pos,ObjName,OwnerId,OwnerTeamID,DropTime)
	
	--��ⳡ��Trap�Ƿ񳬳�����
	local bLimit = GasConfig.SceneObjLimit
	local uMaxLimit = Scene_Common[Scene.m_SceneName].ObjLimit
	local uSceneId = Scene.m_SceneId
	if bLimit and g_AllIntObjNum[uSceneId] and g_AllIntObjNum[uSceneId] > uMaxLimit then
		local errmsg = "������" .. Scene.m_SceneName .. "��ͬʱ���ڵ�IntObj��������������ƣ� ��" .. uMaxLimit .. "�������������������"
		LogErr(errmsg, ObjName)
		return nil
	end
	
	local IntObj = nil
	local PixelFPos = CFPos:new()
	PixelFPos.x = Pos.x * EUnits.eGridSpanForObj
	PixelFPos.y = Pos.y * EUnits.eGridSpanForObj
	
	IntObj = CEntityServerCreator_CreateServerIntObject(Scene.m_CoreScene, PixelFPos, "IntObj", ObjName )
	
	if LogDataTemp then
		local curPos = CFPos:new()
		IntObj:GetPixelPos(curPos)
		if math.abs(LogDataTemp.GridX * 64 - curPos.x) > 32 or math.abs(LogDataTemp.GridY * 64 - curPos.y) > 32 then
			local sourcePos = "ԭʼ����:[" .. LogDataTemp.GridX .. "," .. LogDataTemp.GridY .. "]"
			local argPos = "��������:[" .. PixelFPos.x .. "," .. PixelFPos.y .. "]"
			local strCurPos = "������ɺ�����:[" .. curPos.x .. "," .. curPos.y.."]"
			LogErr("Obj������λ" , "[" .. ObjName .. "] " .. sourcePos .. argPos .. strCurPos)
		end
	end

	IntObj.m_Scene = Scene
	IntObj.m_Pos = Pos -- �����������

	--IntObj�������κζ���
	IntObj:SetIntObjSeeType(ETrapSeeType.ETrapSeeType_None)
	
	IntObj:SetStealth(0)
	IntObj:SetKeenness(0)
	IntObj.m_Properties = CServerIntObjProperties:new()
	IntObj.m_Properties:Init(IntObj)
	IntObj.m_Properties:InitIntObjStatic(ObjName, ECharacterType.IntObj,OwnerId,OwnerTeamID,DropTime)
	if g_NatureArg2ObjTbl[ObjName] then
		IntObj:SetSizeType(EAoiItemSizeType.eAIST_InterestingIntObj)
	end
	IntObj.m_DlgOnClicked = CDelegate:new()
	return IntObj
end

--[[
	Scene										���ڳ���
	x,y											����
]]
function CIntObjServerMgr:CreateSceneIntObj( Scene , File, isDynamicCreate)
	local srcTbl, indexTbl = g_AreaSceneDataMgr:GetObjTbl(Scene, File, isDynamicCreate)
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
		if Scene.m_DynamicCenterPos then --��̬Obj����ʱ�� ͨ�����λ�ü�������
			pos.x = pos.x + Scene.m_DynamicCenterPos[1]
			pos.y = pos.y + Scene.m_DynamicCenterPos[2]
		end	
		if pos.x==nil or pos.y==nil then
			assert(false ,"����Ϊ��")
			return
		end
		if Scene.m_SceneName == "��С��ѡ����" then
			LogDataTemp = {}
			LogDataTemp.GridX = p.GridX
			LogDataTemp.GridY = p.GridY
		end
		CreateIntObj(Scene, pos, p.Name,false, nil, nil, nil, p.Direction)
		LogDataTemp = nil
	end
end

--����
--�����ڳ�����
--	���꣬
--	ObjName��
--	OBJ�Ƿ�����
--	Obj�����ߣ���ֵ�������ߣ���
--	�����������Ӵ�ֵ��䣩��
--	����ʱ�䣨�����˹����ߺ�����Team���⣬�����Ҳ���Թ���ʱ��Ҫ��DropTime����
--	����
function CreateIntObj(Scene, Pos, ObjName, IsDestroyObj, OwnerId, OwnerTeamID, DropTime,Direction)
	local IntObjCommon = IntObj_Common(ObjName)
	if IntObjCommon==nil then
		assert(false, ObjName.." û����IntObj_Common����")
		return
	end
	
	--��һ���ж�,���������Ϸ�в�����OBJ,Ҫ���ж�Ψһ
	if IsDestroyObj then
		if IntObjCommon("OnlyObj") == 1 then
			if g_IntObjServerMgr._m_OnlyObj[Scene.m_SceneId] then
				if g_IntObjServerMgr._m_OnlyObj[Scene.m_SceneId][ObjName] then
					local lObj = g_IntObjServerMgr._m_OnlyObj[Scene.m_SceneId][ObjName]
					g_IntObjServerMgr:Destroy(lObj,false)
				end
			end
		end
	end
	
	local IntObj = CreateSingleServerObj(IntObjCommon,Scene,Pos,ObjName,OwnerId,OwnerTeamID,DropTime)
	if not IntObj then
		LogErr("Obj����ʧ��", "������:" .. Scene.m_SceneName .. "  Obj��:" .. ObjName)
		return
	end	
	RegOnceTickLifecycleObj("IntObj", IntObj)
	IntObj:SetAndSyncActionDir(Direction)
	IntObj.m_Direction = Direction
	
	local ObjEntityID = IntObj:GetEntityID()
	local TriggerType = IntObjCommon("TriggerType")
	local TriggerAction = IntObjCommon("TriggerAction")
	
	local RandomCreateCommon = RandomCreate_Server(ObjName)
	if RandomCreateCommon ~= nil then
		local fistTime = RandomCreateCommon("FirstTime")
		local intervalTime = RandomCreateCommon("IntervalTime") * 1000
		local time = 0;
		if fistTime == nil or fistTime == "" then
			time = intervalTime
		else
			time = fistTime ~= 0 and fistTime * 1000 or 10
			IntObj.m_isNewRandomCreateTick = true
		end
		local function TickCallBack()
			g_RandomCreateTick(ObjEntityID)
		end
		IntObj.m_RandomCreateTick =  RegisterTick("ObjRandomCreateTick", TickCallBack, time)
	end

	local ObjAction = ObjAction_Server(ObjName)
	if ObjAction ~= nil then
		IntObj.m_Properties:SetBornAction(2)
		IntObj.m_IsBornAction = true
	end
	
	IntObj.m_CallbackHandler = CIntObjCallbackHandler:new()
	IntObj:SetCallbackHandler(IntObj.m_CallbackHandler)
	
	RequireOnClickedObjScript(IntObj,TriggerAction)
	
	local SceneId = Scene.m_SceneId
	if g_AllIntObj[SceneId] == nil then
		g_AllIntObj[SceneId] = {}
		g_AllIntObjNum[SceneId] = 0
	end
	g_AllIntObjNum[SceneId] = g_AllIntObjNum[SceneId] + 1
	
	g_AllIntObj[SceneId][ObjEntityID] = IntObj
	if IntObjCommon("OnlyObj") == 1 then   --�����ڵ�Ψһ Obj
		if g_IntObjServerMgr._m_OnlyObj[SceneId] == nil then
			g_IntObjServerMgr._m_OnlyObj[SceneId] = {} 
		end
		if g_IntObjServerMgr._m_OnlyObj[SceneId][ObjName] == nil then
			g_IntObjServerMgr._m_OnlyObj[SceneId][ObjName] = IntObj
		else 
			assert(false, "Obj "..ObjName.." �����ǳ�����Ψһ��(�����ñ�IntObj_Common)")
		end
	end
	
	IntObj:SetSize(IntObjCommon("size"))
	IntObj:SetBottomSize(IntObjCommon("size"))
	--IntObj:SetBarrierSize(IntObjCommon("size"))
	
	local BarrierType =  IntObjCommon("IsBarrier")
	if BarrierType >= 1 then   --�ϰ� Obj
		local PixelFPos = CFPos:new()
		IntObj:GetPixelPos(PixelFPos)
		
		IntObj.m_IsBarrier = BarrierType
		if g_IntObjServerMgr.m_Barrier[SceneId] == nil then
			g_IntObjServerMgr.m_Barrier[SceneId] = {} 
		end
		if g_IntObjServerMgr.m_Barrier[SceneId][ObjName] == nil then
			g_IntObjServerMgr.m_Barrier[SceneId][ObjName] = BarrierType
		end
		if BarrierType == 1 then
			IntObj:SetDynamicBarrier(EBarrierType.eBT_LowBarrier)
		elseif BarrierType == 2 then
			IntObj:SetDynamicBarrier(EBarrierType.eBT_MidBarrier)
		elseif BarrierType == 3 then
			IntObj:SetDynamicBarrier(EBarrierType.eBT_HighBarrier)
		else
			assert(false, "Obj "..ObjName.." ���ӵ��ϰ�������������(�����ñ�IntObj_Common)")
		end
		
		if LogDataTemp then
			local curPos = CFPos:new()
			IntObj:GetPixelPos(curPos)
			if math.abs(LogDataTemp.GridX * 64 - curPos.x) > 32 or math.abs(LogDataTemp.GridY * 64 - curPos.y) > 32 then
				local sourcePos = "ԭʼ����:[" .. LogDataTemp.GridX .. "," .. LogDataTemp.GridY .. "]"
				local argPos = "���ö�̬�ϰ�ǰ:[" .. PixelFPos.x .. "," .. PixelFPos.y .. "]"
				local strCurPos = "���ö�̬�ϰ���:[" .. curPos.x .. "," .. curPos.y.."]"
				LogErr("Obj���ö�̬�ϰ����λ", "[" .. ObjName .. "] " .. sourcePos .. argPos .. strCurPos)
			end
		end
		
	end
	
	local function TickDestroyObj(data)
		local Target,IsReborn = data[1],data[2]
		g_TriggerMgr:Trigger("�����ڽ���", Target)
		CIntObjServerMgr:Destroy(Target,IsReborn)
	end
	local ExistTime = IntObjCommon("ExistTime")
	if not IsDestroyObj then
		if ExistTime ~= "" and IsNumber(ExistTime) and ExistTime > 0 then
			local data = {IntObj,true}
			RegisterOnceTick(IntObj,"ObjExistTick", TickDestroyObj, ExistTime*1000, data)
		end
	else
		if ExistTime == "" or not IsNumber(ExistTime) or ExistTime <= 0 then
			ExistTime = 30
		end
		local data = {IntObj,false}
		RegisterOnceTick(IntObj,"ObjExistTick", TickDestroyObj, ExistTime*1000, data)
	end
	
	if g_NatureArg2NpcTbl[ObjName] then
		IntObj:SetSizeType(EAoiItemSizeType.eAIST_InterestingIntObj)
	end
	IntObj:SetObjName(ObjName)
	g_TriggerMgr:Trigger("����", IntObj)
	return IntObj
end

local function ClearDropObjTbl(DropObjTblID, ObjID)
	if NpcDropObjTbl[DropObjTblID] and NpcDropObjTbl[DropObjTblID].m_CreateObjTbl then
		
		if IsTable(NpcDropObjTbl[DropObjTblID].m_CreateObjTbl) then
			if NpcDropObjTbl[DropObjTblID].m_CreateObjTbl[ObjID] then
				NpcDropObjTbl[DropObjTblID].m_CreateObjTbl[ObjID] = nil
			end
			if not next(NpcDropObjTbl[DropObjTblID].m_CreateObjTbl) then
				NpcDropObjTbl[DropObjTblID].m_CreateObjTbl = nil
				NpcDropObjTbl[DropObjTblID].m_Objs_List = nil
				NpcDropObjTbl[DropObjTblID] = nil
			end
		end
		
	end
end

----------------------------------
local function IsRebornObj(Obj,IsReborn)
	if not IsReborn then
		return
	end
	local ObjName = Obj.m_Properties:GetCharName()
	--print("��������,�Զ�ɾ����OBJ����:",ObjName)
	local IntObjCommon = IntObj_Common(ObjName)
	if not IntObjCommon then
		return
	end
	local IsOrNot = IntObjCommon("IsReborn")
	if IsOrNot == 0 or IsOrNot == "" or not IsNumber(IsOrNot) then
		return
	end
	--print("ObjName create..........")
	local RebornTime = IntObjCommon("RefreshTime")
	if RebornTime == "" or not IsNumber(RebornTime) or RebornTime <= 0 then
		RefreshTime = 30
	end
	
	local function ObjReborn(data)
		CreateIntObj(data.m_ObjScene, data.m_ObjPos, data.m_ObjName,false, nil,nil,nil,data.m_Direction)
	end

	local data = {}
	local Pos = CPos:new()
	Obj:GetGridPos(Pos)
	data.m_ObjName = ObjName
	data.m_ObjScene = Obj.m_Scene
	data.m_ObjPos = Obj.m_Pos
	data.m_SceneId = Obj.m_Scene.m_SceneId
	data.m_Direction = Obj.m_Direction
	
	RegisterOnceTick(Obj.m_Scene, "ChildbirthTick", ObjReborn, RebornTime*1000, data)
end
-----------------------------------

-- ��Obj ɾ����ʱ�� ����������������ObjID
local function ClearObjTrapData(Obj)
	for TrapName, IDTbl in pairs( Obj.m_Properties.m_InTrapTblName) do
		for _, TrapID in pairs(IDTbl) do 
			local Trap = CIntObjServer_GetIntObjServerByID(TrapID)
			if Trap then
				if Trap.m_OnTrapCharIDTbl[Obj:GetEntityID()] then
					CIntObjCallbackHandler:OnObjLeaveTrapViewAoi(TrapID, Obj)
					Trap.m_OnTrapCharIDTbl[Obj:GetEntityID()] = nil
				end
--				local TrapCharIDTbl = Trap.m_TrapHandler.m_OnTrapCharIDTbl
--				for i=1, #(TrapCharIDTbl) do
--					if TrapCharIDTbl[i] == Obj:GetEntityID() then
--						CIntObjCallbackHandler:OnObjLeaveTrapViewAoi(TrapID, Obj)
--						--ObjLeaveTrap(Obj, Trap)
--						table.remove(Trap.m_TrapHandler.m_OnTrapCharIDTbl, i)
--					end
--				end
			end
		end
	end	
end

function CIntObjServerMgr:Destroy(IntObj,IsReborn,IsDestroyScene)
	if not IsServerObjValid(IntObj) then
		return
	end
	UnRegisterObjOnceTick(IntObj)
	
--	ClearObjTrapData(IntObj)
	
	if IntObj.m_RandomCreateTick ~= nil then
		UnRegisterTick(IntObj.m_RandomCreateTick)
		IntObj.m_RandomCreateTick = nil
	end
	if IntObj.m_QuanTick then
		UnRegisterTick(IntObj.m_QuanTick)
		IntObj.m_QuanTick = nil	
	end
	if IntObj.m_AssignTick then
		UnRegisterTick(IntObj.m_AssignTick)
		IntObj.m_AssignTick = nil	
	end
	
	if IntObj.m_ItemWndCloseTick then
		UnRegisterTick(IntObj.m_ItemWndCloseTick)
		IntObj.m_ItemWndCloseTick = nil	
	end
	
	if IntObj.m_SmallGameTick then
		UnRegisterTick(IntObj.m_SmallGameTick)
		IntObj.m_SmallGameTick = nil
	end
	--------------------------
	--OBJ�Ƿ�����
	IsRebornObj(IntObj,IsReborn)
	--------------------------
	if not IsDestroyScene then
		g_TriggerMgr:Trigger("����", IntObj)
	end
	
	local ObjEntityID = IntObj:GetEntityID()
	if IntObj.m_BelongToNpc then--����Ǵ�ֵ���OBJ,ÿɾ��һ��,��Ҫ�ж���table
		ClearDropObjTbl(IntObj.m_BelongToNpc, ObjEntityID)
	end
	
	if IntObj.m_Openner then
		if IsTable(IntObj.m_Openner) then
			for ID, v in pairs(IntObj.m_Openner) do
				local Player = g_GetPlayerInfo(ID)
				if Player and Player.m_ResourceObjID == ObjEntityID then
					TongStopLoadProgress(Player)
				end
			end
		else
			local Player = g_GetPlayerInfo(IntObj.m_Openner)
			if Player then
				if Player.m_CollIntObjID == ObjEntityID then
					BreakPlayerCollItem(Player)
				elseif Player.m_ProcessingObjID == ObjEntityID then
					BreakPlayerActionLoading(Player)
				elseif Player.m_ResourceObjID == ObjEntityID then
					TongStopLoadProgress(Player)
				end
			end
		end
	end
	if IntObj.m_AssignPlayer then
		RemoveObjAllAssignTbl(IntObj)
	end
	if IntObj.m_AcutionParam then
		local function CallBack(PlayerID, Money)
			if PlayerID then
				MsgToConnById(PlayerID, 3992, Money)
			end
		end
		if IntObj.m_AcutionParam[2] > 0 then
			local data = {["CharID"] = IntObj.m_AcutionParam[1], ["ObjID"] = IntObj:GetEntityID(), ["EventId"] = IntObj.m_AcutionEventId}
			local Player = g_GetPlayerInfo(IntObj.m_AcutionParam[1])
			if IsCppBound(Player) and IsCppBound(Player.m_Conn) then
				CallAccountManualTrans(Player.m_Conn.m_Account, "AuctionAssignDB", "ReturnAuctionMoney", CallBack, data)
			else
				CallDbTrans("AuctionAssignDB", "ReturnAuctionMoney", CallBack, data, IntObj.m_AcutionParam[1])
			end
		end
	end
	--ɾ�������ս��Obj
	if IntObj.m_ObjIndex then
		ReMoveChallengeObj(IntObj)
	end
	local SceneId = IntObj.m_Scene.m_SceneId
	local SceneType = IntObj.m_Scene.m_SceneAttr.SceneType
	local ObjName = IntObj.m_Properties:GetCharName()
	if g_IntObjServerMgr._m_OnlyObj[SceneId] and g_IntObjServerMgr._m_OnlyObj[SceneId][ObjName] then
		g_IntObjServerMgr._m_OnlyObj[SceneId][ObjName] = nil
	end
	if g_IntObjServerMgr.m_Barrier[SceneId] and g_IntObjServerMgr.m_Barrier[SceneId][ObjName] then
		g_IntObjServerMgr.m_Barrier[SceneId][ObjName] = nil
	end
	if not g_AllIntObjNum[SceneId] then
		local Scene = g_SceneMgr:GetScene(SceneId)
		local flag = "true"
		if not Scene then
			flag = "false"
		end
		LogErr("����obj������","����Id:"..SceneId..",�����Ƿ����"..flag..",��������:"..SceneType)
	end
	g_AllIntObjNum[SceneId] = g_AllIntObjNum[SceneId] - 1
	g_AllIntObj[SceneId][ObjEntityID] = nil
	CEntityServerCreator_DestroyEntity(IntObj)
	IntObj = nil
end

function DestroyOneSceneIntObj(uSceneID)
	if g_AllIntObj[uSceneID] then
		for _, IntObj in pairs(g_AllIntObj[uSceneID]) do
			g_IntObjServerMgr:Destroy(IntObj,false,true)
		end
		g_IntObjServerMgr.m_Barrier[uSceneID] = nil
		g_IntObjServerMgr._m_OnlyObj[uSceneID] = nil
		g_AllIntObj[uSceneID] = nil
		
		g_AllIntObjNum[uSceneID] = nil
	end
end

--����OBJ�����ʱ��ɾ����OBJ  �����ڻص����޷����� ���ڴ˽������trap�ڵ�OBJ������  ������.
--local function ObjLeaveTrap(Obj, Trap)
--	local TrapName = Trap.m_Properties:GetCharName()
--	if not Trap_Common(TrapName) then
--		return 
--	end
--	local TrapArg = GetCfgTransformValue(true, "Trap_Common", TrapName, "Arg")
--	if not (TrapArg and TrapArg[1]) then
--		return 
--	end
--	local SceneId = Obj.m_Scene.m_SceneId
--	local IntObj = GetOnlyIntObj(SceneId, TrapArg[1])
--	if IntObj == nil then
--		return
--	end
----	print("OBJ �뿪���� ObjLeaveTrap(Obj, Trap)")
--	if #(pTrapHandler.m_OnTrapCharIDTbl) == 0 then
--		g_IntObjServerMgr:IntObjChangeState(IntObj, 0)
--	else 
--		g_IntObjServerMgr:IntObjChangeState(IntObj, 1)
--	end	
--	CIntObjCallbackHandler:OnObjLeaveTrapViewAoi(ObjEntityID, IntObj)
--end

function CIntObjServerMgr:IntObjChangeModel(IntObj, ModelName)
--print("IntObjChangeModel")
	local OldModelName = IntObj.m_Properties:GetModelName()
	local EntityID = IntObj:GetEntityID()
	IntObj.m_Properties:SetModel(ModelName)
	IntObj.m_Properties:SetActionNum(1)
	Gas2Gac:IntObjChangeModel(IntObj:GetIS(0), EntityID, ModelName, OldModelName)
end

function CIntObjServerMgr:IntObjDoAction(IntObj, RespondAction, NextActionNum)
--print("IntObjDoAction")
	local EntityID = IntObj:GetEntityID()
--	local ObjName = IntObj.m_Properties:GetCharName()
--	if ObjChangeModel_Server[ObjName] ~= nil
--		and ObjChangeModel_Server[ObjName][RespondAction] ~= nil 
--		and ObjChangeModel_Server[ObjName][RespondAction] ~= "" then
--		local ModelName = ObjChangeModel_Server[ObjName][RespondAction]
--		Gas2Gac:NotifyIntObjDoAction(IntObj:GetIS(0), EntityID, RespondAction, "")
--		local function Func(Tick, IntObj)
--			g_IntObjServerMgr:IntObjChangeModel(IntObj, ModelName)
--			UnRegisterTick(IntObj.m_ChangeModelTick)
--			IntObj.m_ChangeModelTick = nil
--		end
--		IntObj.m_ChangeModelTick = RegisterTick("ChangeModelTick", Func,300,IntObj)
--	else
		Gas2Gac:NotifyIntObjDoAction(IntObj:GetIS(0), EntityID, RespondAction, NextActionNum)
		if NextActionNum then
			IntObj.m_Properties:SetActionNum(NextActionNum)
		end
--	end
end

function CIntObjServerMgr:IntObjChangeState(IntObj, State)
--print("IntObjChangeState")
	IntObj.m_Properties:SetCanUseState(State)
	local EntityID = IntObj:GetEntityID()
	Gas2Gac:IntObjChangeState(IntObj:GetIS(0), EntityID, State)
end



function CIntObjServerMgr:RefreshObjState( IntObj)
	local intObjname = IntObj.m_Properties:GetCharName()
	local refreshtime = IntObj_Common(intObjname, "RefreshTime")
	if refreshtime == "" or refreshtime == 0 or refreshtime == nil then
		refreshtime = 10	
	end
	local function RefreshObjStateTick()
		CIntObjServerMgr:IntObjChangeState(IntObj, 1)
	end
	RegisterOnceTick(IntObj,"ReflreshObjState", RefreshObjStateTick, refreshtime*1000)
end
