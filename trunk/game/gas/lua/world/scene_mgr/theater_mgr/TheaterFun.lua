gac_gas_require "shortcut/ShortcutCommon"
cfg_load "npc/NpcTheater_Server"
lan_load "npc/Lan_NpcTheater_Server"
gas_require "world/npc/LifeOrigin"
gas_require "world/npc/ServerNpc"

CTheaterFun = class()

function CTheaterFun:Ctor(TheaterName, StepTbl, SceneId, StarterId, RandomN)
	self.m_TheaterName = TheaterName
	self.m_SceneId = SceneId
	self.m_StarterId = StarterId
	self.m_RandomN = RandomN
	self.m_StepTbl = StepTbl
	self.m_IsReturn = false
	self.m_IsClosed = false
	self.m_Co = false
	self.m_MoveSleep = false
	self.m_Sleep = CSleep:new()
	if StepTbl[table.getn(StepTbl)].Action == "Return" then
		self.m_IsReturn = true
	end
end

function CTheaterFun:DestoryTheater()
	self.m_TheaterName = nil
	self.m_SceneId = nil
	self.m_StarterId = nil
	self.m_RandomN = nil
	for i, v in pairs(self.m_StepTbl) do
		self.m_StepTbl[i] = nil
	end
	self.m_StepTbl = nil
	self.m_IsReturn = nil
	self.m_IsClosed = nil
	self.m_Sleep = nil
	self.m_MoveSleep = nil
	self.m_Co = nil
	self = nil
end

function CTheaterFun:GetTheaterTxt(SayNumber)
	local index = MemH64(SayNumber)
	if Lan_NpcTheater_Server(index) then
		local Sentence = Lan_NpcTheater_Server(index, "Sentence")
		if self.m_RandomN ~= nil then
			local Tbl =  assert(loadstring("return " .. Sentence))()
			if type(self.m_RandomN) == "number" then
				Sentence = Tbl[self.m_RandomN]
			else
				Sentence = Tbl[math.random(table.maxn(Tbl))]
			end
		end
		return Sentence
	end
end

--��õ�ǰ���鷢��������һ��ΨһNPC
function CTheaterFun:GetOnlyNpcId(NpcName)
	local SceneId = self.m_SceneId
	if SceneId then
		if g_NpcBornMgr._m_OnlyNpc[SceneId] then
			local Npc = g_NpcBornMgr._m_OnlyNpc[SceneId][NpcName]
			if not IsServerObjValid(Npc) then
				return
			end
			return Npc:GetEntityID()
		end
	end
	return nil
end

function CTheaterFun:GetOnlyObj(ObjName)
	local SceneId = self.m_SceneId
	if g_IntObjServerMgr._m_OnlyObj[SceneId] then
		if g_IntObjServerMgr._m_OnlyObj[SceneId][ObjName] then
			return g_IntObjServerMgr._m_OnlyObj[SceneId][ObjName]
		end
	end
	return nil
end

local ClassNameTbl = {
	["eCL_Warrior"]				= "��ʿ",
	["eCL_MagicWarrior"]	= "ħ��ʿ",
	["eCL_Paladin"]				= "��ʿ",
	["eCL_NatureElf"]			= "��ʦ",
	["eCL_EvilElf"]				= "аħ",
	["eCL_Priest"]				= "��ʦ",
	["eCL_DwarfPaladin"]	= "������ʿ",
	["eCL_ElfHunter"]			= "���鹭����",
	["eCL_OrcWarrior"]		= "����սʿ",
	["eCL_Npc"]						= "NPC",
	["eCL_Wizard"]				= "��ʦ",
	["eCL_Assassin"]			= "�̿�",
	["eCL_Warlock"]				= "а��ʦ",
	["eCL_WarPriest"]			= "ս��",
	["eCL_Archer"]				= "������",
	["eCL_Soldier"]				= "��սʿ",
	["eCL_Summoner"]			= "�ٻ�ʦ",
	["eCL_Beast"]					= "Ұ��",
	["eCL_Summon"]				= "�ٻ�����",
	["eCL_Lancer"]				= "������ʿ",
	["eCL_Knight"]				= "������ʿ",
	["eCL_NatureElement"] = "��ȻԪ��",
	["eCL_EvilElement"]		= "����Ԫ��",
	["eCL_DestructionElement"] = "�ƻ�Ԫ��",
}

function CTheaterFun:GetClassName(ClassID)
	for name, id in pairs(EClass) do
		if ClassID == id then
			return ClassNameTbl[name]
		end
	end
end

function CTheaterFun:GetSexStrById(SexId)
	if SexId == ECharSex.eCS_NoSex then
		return ""
	elseif SexId == ECharSex.eCS_Male then
		return "����"
	elseif SexId == ECharSex.eCS_Female then
		return "Ůʿ"
	end
	return ""
end

--��ȡ������Ϣ
function CTheaterFun:GetTargetName(Target)
	if Target then
		return Target.m_Properties:GetCharName()
	end
	return ""
end

function CTheaterFun:GetTargetClass(Target)
	if Target then
		local ClassId = Target:CppGetClass()
		return self:GetClassName(ClassId)
	end
	return ""
end

function CTheaterFun:GetTargetSexStr(Target)
	if Target then
		local Type = Target.m_Properties:GetType()
		local SexId = nil
		if Type == ECharacterType.Player then
			SexId = Target.m_Properties:GetSex()
		end
		if Type == ECharacterType.Npc then
			SexId = Target.m_BaseData["Sex"]
		end
		return self:GetSexStrById(SexId)
	end
	return ""
end

function CTheaterFun:GetTargetPos(Target)
	if Target then
		local Pos = CPos:new()
		Target:GetGridPos( Pos )
		return "(" .. Pos.x .. "," .. Pos.y .. ")"
	end
	return ""
end

function CTheaterFun:GetTargetLevel(Target)
	if Target then
		return Target:CppGetLevel()..""
	end
	return ""
end

function CTheaterFun:GetTargetInfoTbl(Target)
	local tbl ={	
					["#name#"]	= self:GetTargetName(Target),
					["#class#"]	= self:GetTargetClass(Target),
					["#sex#"]		= self:GetTargetSexStr(Target),
					["#level#"]	= self:GetTargetLevel(Target),
					["#pos#"]		= self:GetTargetPos(Target)
				}
	return tbl
end

--ִ�����¼�����˳�򲥷ŵľ糡
function CTheaterFun:RunTheater()
	local Scene = g_SceneMgr:GetScene(self.m_SceneId)
	local StepNum = table.getn(self.m_StepTbl)
	self.m_Co = coroutine.create(function()
		local i = 1
		if self.m_IsReturn then
			while self.m_IsClosed == false do
				self:DoAction(self.m_StepTbl[i])
				i = (i+1>StepNum and 1) or i+1
			end
		else
			while self.m_IsClosed == false and i <= StepNum do
				self:DoAction(self.m_StepTbl[i])
				i = i+1
			end
		end
		Scene.m_TheaterMgr.m_TheaterTbl[self.m_TheaterName] = nil
		self:DestoryTheater()
	end)
	coroutine.resume(self.m_Co)
end

--����²����¾�����������������
function CTheaterFun:DoAction(StepTbl)
--	local msg = nil
--	local s, e = pcall(self["aa"]())
--	if not s then msg = "wrong to call aa" end
--	local err_msg = "��ͼ ��" .. SceneName .. "�� �Ѵ���NPC ��" .. NpcName .. "�� ���糡 ��" .. TheaterName .. "�� ����NPC ��" .. NpcName .. "�� ʧ�ܣ� ���ʵ��" 
--	CfgLogErr("�糡���ų��ִ���!",err_msg)
--	print(a, e, msg)

	if StepTbl.Action ~= "Return" then
		self[StepTbl.Action](self, StepTbl)
	end
end


----------------------���ñ��еĸ���Action�ĺ�������----------------------------------

function CTheaterFun:Start(StepTbl, RandomN)
	local TargetTheaterName = StepTbl.Parameter1
	local TargetSceneName = StepTbl.Parameter2
	if TargetTheaterName == nil or TargetTheaterName == "" or TargetSceneName == nil or TargetSceneName == ""  then
		return
	end
	if Scene_Common[TargetSceneName] == nil then
--		print("CTheaterFun:Start::"..SceneName.."����Scene_Common��")
		return
	end
	local SceneId = g_SceneMgr:GetSceneByName(TargetSceneName)
	if SceneId == nil or SceneId == "" then
		--CfgLogErr("�糡���ų��ִ���!",SceneName.." ��ͼ��δ������,�޷����о糡��"..TheaterName.."��")
		return
	end
	
	if SceneId == self.m_SceneId then
		local Scene = g_SceneMgr:GetScene(self.m_SceneId)
		Scene.m_TheaterMgr:RunTriggerTheater(TargetTheaterName, nil, RandomN)
	end
end

function CTheaterFun:RandomStart(StepTbl)
	self:Start(StepTbl, true)
end

function CTheaterFun:Open(StepTbl)
	local TargetTheaterName = StepTbl.Parameter1
	local Scene = g_SceneMgr:GetScene(self.m_SceneId)
	Scene.m_TheaterMgr:RunTriggerTheater(TargetTheaterName, nil)
end

function CTheaterFun:Close(StepTbl)
	local TargetTheaterName = StepTbl.Parameter1
	local Scene = g_SceneMgr:GetScene(self.m_SceneId)
	local Theater = Scene.m_TheaterMgr.m_TheaterTbl[TargetTheaterName]
	if Theater then
		Scene.m_TheaterMgr.m_TheaterTbl[TargetTheaterName].m_IsClosed = true
	end
end

function CTheaterFun:Wait(StepTbl, Time)
	local Time = StepTbl.Parameter1
	self.m_Sleep:Sleep(tonumber(Time), "TheaterWaitSleep")
end

function CTheaterFun:Depict(StepTbl)
	local Sentence = self:GetTheaterTxt(StepTbl.StepName)
	local NpcId = self:GetOnlyNpcId(StepTbl.NpcName)
	if NpcId then
		local Npc = CCharacterDictator_GetCharacterByID(NpcId)
		MsgToConn(Npc:GetIS(0), 8003, Sentence)
	end
end

function CTheaterFun:Say(StepTbl)
	local NpcName = StepTbl.NpcName
	local StepName = StepTbl.StepName
	local Channel = StepTbl.Parameter1
	local ChannelId = ChannelIdTbl[Channel] or ChannelIdTbl["NPC"]
	local NpcId = self:GetOnlyNpcId(NpcName)
	if NpcId then
		local NpcObj = CCharacterDictator_GetCharacterByID(NpcId)
		if NpcObj then
			if self.m_RandomN then
				local RandomNum = 0
				if IsNumber(self.m_RandomN) then
					RandomNum = self.m_RandomN
				end
				Gas2Gac:ShowTheaterNpcTalk(NpcObj:GetIS(0), NpcId, NpcName, ChannelId, StepName, RandomNum)
			else
				Gas2Gac:ShowTheaterNpcTalk(NpcObj:GetIS(0), NpcId, NpcName, ChannelId, StepName, -1)
			end
		end
	elseif NpcName == "#mytarget#" then
		local player = CEntityServerManager_GetEntityByID(self.m_StarterId)
		if player then
			local Sentence = self:GetTheaterTxt(StepName)
			CChatChannelMgr.SendMsg(Sentence, player.m_uID, ChannelIdTbl["����"])
		end
	end
end

function CTheaterFun:DoSay(StepTbl)
	local NpcName = StepTbl.NpcName
	local StepName = StepTbl.StepName
	local param = StepTbl.Parameter1
	local NpcId = self:GetOnlyNpcId(NpcName)
	local TargetId = self.m_StarterId
	local NpcObj = CCharacterDictator_GetCharacterByID(NpcId)
	local Char = CCharacterDictator_GetCharacterByID(TargetId)
	if NpcObj and Char then
		local InfoTbl = self:GetTargetInfoTbl(Char)
		if InfoTbl then
			if IsString(InfoTbl[param]) then
				Gas2Gac:ShowTheaterNpcDoTalk(NpcObj:GetIS(0), NpcId, NpcName, ChannelIdTbl["NPC"], StepName, param, InfoTbl[param])
			end
		end
	end
end

function CTheaterFun:Move(StepTbl)
	self:DoMove(StepTbl, true)
end

function CTheaterFun:Run(StepTbl)
	self:DoMove(StepTbl, false)
end

function CTheaterFun:DoMove(StepTbl, MoveType)
	local PosID = StepTbl.Parameter1
	local NpcId = self:GetOnlyNpcId(StepTbl.NpcName)
	if NpcId then
		local NpcObj = CCharacterDictator_GetCharacterByID(NpcId)
		if not NpcObj then
			return
		end
		local Scene = NpcObj.m_Scene
		local pos = CPos:new()
		pos.x, pos.y = GetScenePosition(tonumber(PosID), Scene)
		NpcObj:SetDefaultWalkState(MoveType)
		NpcObj:TheaterMoveToGird(pos, MoveType)
		self.m_MoveSleep = true
		coroutine.yield()

		while IsServerObjValid(NpcObj) do	
			local NpcPos = CPos:new()
			NpcObj:GetGridPos( NpcPos )
			if NpcPos then
				self.m_MoveSleep = nil
				break
			end
		end
	end
end

--ʹ�ü���
function CTheaterFun:PlaySkill(StepTbl)
	local NpcName = StepTbl.NpcName
	local SkillArgs = StepTbl.Parameter1
	local Target = StepTbl.Parameter2
	local SkillInfo = assert(loadstring("return " .. SkillArgs))()
	local SkillName = SkillInfo[1]
	local SkillLevel = SkillInfo[2]
	local TargetName = Target
	if TargetName == nil then
		TargetName = NpcName
	end
	local NpcId = self:GetOnlyNpcId(NpcName)
	local TargetId = self:GetOnlyNpcId(TargetName)
	if NpcId and TargetId then
		local NpcObj = CCharacterDictator_GetCharacterByID(NpcId)
		local TargetObj = CCharacterDictator_GetCharacterByID(TargetId)
		if NpcObj and TargetObj then
			NpcObj:ServerDoNoRuleSkill(SkillName, TargetObj)
		end
	end
end

function CTheaterFun:Act(StepTbl)
	local ActName = StepTbl.Parameter1
	local Target = StepTbl.Parameter2
	local NpcId = self:GetOnlyNpcId(StepTbl.NpcName)
	local ActionState = CActorCfg_GetEnumByString(ActName)	
	if ActionState ~= EActionState.eAS_Error and NpcId then
		local NpcObj = CCharacterDictator_GetCharacterByID(NpcId)
		if not NpcObj then
			return
		end
		if Target == "#mytarget#" and self.m_StarterId then
			local TargetObj = CCharacterDictator_GetCharacterByID(self.m_StarterId)
			if TargetObj then
				local TargetName = TargetObj.m_Properties:GetCharName()
				self:Turn2Obj(StepTbl.NpcName, TargetName)
			end
		end
		NpcObj:SetAndSyncActionState(ActionState)
	end
end

function CTheaterFun:DoTurn(NpcId, TargetPos)
	if NpcId then
		local NpcObj = CCharacterDictator_GetCharacterByID(NpcId)
		if NpcObj then
			local Dir = CDir:new()
			local vecDir = CVector2f:new() 
			local NpcPos = CPos:new()
			NpcObj:GetGridPos( NpcPos )
			vecDir.x = TargetPos.x - NpcPos.x 
			vecDir.y = TargetPos.y - NpcPos.y 
			Dir:Set( vecDir )
			NpcObj:SetAndSyncActionDir(Dir.uDir)
		end
	end
end

function CTheaterFun:Turn(StepTbl)
	local PosID = StepTbl.Parameter1
	local NpcId = self:GetOnlyNpcId(StepTbl.NpcName)
	if NpcId then
		local NpcObj = CCharacterDictator_GetCharacterByID(NpcId)
		if NpcObj then
			local TargetPos = CPos:new()
			TargetPos.x,TargetPos.y = GetScenePosition(tonumber(PosID), NpcObj.m_Scene)
			self:DoTurn(NpcId, TargetPos)
		end
	end
end

--��Ϊ������������Ϊ���������Զ�������ΨһNPC
function CTheaterFun:Turn2Obj(StepTbl)
	local ObjName = StepTbl.Parameter1
	local NpcId = self:GetOnlyNpcId(StepTbl.NpcName)
	if NpcId then
		local NpcObjId = self:GetOnlyNpcId(ObjName)
		local NpcObj = CCharacterDictator_GetCharacterByID(NpcObjId)
		if NpcObj then
			local TargetPos = CPos:new()
			NpcObj:GetGridPos(TargetPos)
			self:DoTurn(NpcId, TargetPos)
		end
	end
end

--�糡����Npc�������ִ�����������ΨһNPC
function CTheaterFun:CreateNpc(StepTbl)
	local NpcName = StepTbl.NpcName
	local PosID = StepTbl.Parameter1
	local NpcId = self:GetOnlyNpcId(NpcName)
	local Scene = g_SceneMgr:GetScene(self.m_SceneId)
	--��ΨһNPC���벻����
	if not NpcId then
		local Pos = CPos:new()
		Pos.x,Pos.y = GetScenePosition(tonumber(PosID), Scene)
		local fPos = CFPos:new( Pos.x * EUnits.eGridSpan, Pos.y * EUnits.eGridSpan )
		local otherData = {["m_CreatorEntityID"] = self.m_StarterId}
		local TheaterNpc, logMsg = g_NpcServerMgr:CreateServerNpc(NpcName, nil, Scene, fPos, otherData)
		if not IsServerObjValid(TheaterNpc) then
			LogErr("����Npcʧ��", logMsg)
			return
		end
		TheaterNpc:SetSizeType(EAoiItemSizeType.eAIST_Monster)
		TheaterNpc:SetSize(1)
		TheaterNpc:SetBottomSize(1)
		--TheaterNpc:SetBarrierSize(1)
	else
		local err_msg = "��ͼ ��" .. Scene.m_SceneName .. "�� �Ѵ���NPC ��" .. NpcName .. "�� ���糡 ��" .. self.m_TheaterName .. "�� ����NPC ��" .. NpcName .. "�� ʧ�ܣ� ���ʵ��" 
		CfgLogErr("�糡���ų��ִ���!",err_msg)
	end	
end

function CTheaterFun:DestoryNpc(StepTbl)
	local NpcId = self:GetOnlyNpcId(StepTbl.NpcName)
	if NpcId then
		local NpcObj = CCharacterDictator_GetCharacterByID(NpcId)
		if NpcObj then
			local Scene = NpcObj.m_Scene
			if self.m_MoveSleep then
				self.m_MoveSleep = nil
				if self.m_Co then
					coroutine.resume(self.m_Co)
				end
			end
			g_NpcServerMgr:DestroyServerNpcNow(NpcObj, true)
		end
	end
end

--���ض�NPC���й���
function CTheaterFun:Attack(StepTbl)
	local NpcName = StepTbl.NpcName
	local TargetName = StepTbl.Parameter1
	local NpcId, TargetId = nil, nil
	if NpcName == "#mytarget#" and self.m_StarterId then		
		NpcId = self.m_StarterId
		TargetId = self:GetOnlyNpcId(TargetName)
	elseif TargetName == "#mytarget#" and self.m_StarterId then
		NpcId = self:GetOnlyNpcId(NpcName)
		TargetId = self.m_StarterId
	else
		NpcId = self:GetOnlyNpcId(NpcName)
		TargetId = self:GetOnlyNpcId(TargetName)		
	end
	local NpcObj = CCharacterDictator_GetCharacterByID(NpcId)
	local TargetObj = CCharacterDictator_GetCharacterByID(TargetId)
	if NpcObj and TargetObj then
		NpcObj:OnBeAttacked(TargetId)
		--print("������ͨ�����ɹ�������")
	end
end

function CTheaterFun:ReplaceNpc(StepTbl)
	local TargetName = StepTbl.Parameter1
	local NpcId = self:GetOnlyNpcId(StepTbl.NpcName)
	if NpcId then
		local NpcObj = CCharacterDictator_GetCharacterByID(NpcId)
		if NpcObj then
			local scene = NpcObj.m_Scene
			local pos = CFPos:new()
			local level = NpcObj:CppGetLevel()
			local dir = NpcObj:GetActionDir()
			NpcObj:GetPixelPos(pos)
			g_NpcServerMgr:DestroyServerNpcNow(NpcObj, false)
			local reNpc, logMsg = g_NpcServerMgr:CreateServerNpc(TargetName, level, NpcObj.m_Scene, pos)
			if not IsServerObjValid(reNpc) then
				LogErr("����Npcʧ��", logMsg)
				return
			end
			reNpc:SetAndSyncActionDir(dir)
		end
	end
end

function CTheaterFun:ChangeCamp(StepTbl)
	local Camp = StepTbl.Parameter1
	local NpcId = self:GetOnlyNpcId(StepTbl.NpcName)
	if NpcId then
		local NpcObj = CCharacterDictator_GetCharacterByID(NpcId)
		if NpcObj then
			NpcObj:CppSetCamp(tonumber(Camp))
			Gas2Gac:UpdateNpcHeadSign(NpcObj:GetIS(0))
		end
	end
end

function CTheaterFun:CreateObj(StepTbl)
	local NpcId = self:GetOnlyNpcId(StepTbl.NpcName)
	if NpcId then
		local NpcObj = CCharacterDictator_GetCharacterByID(NpcId)
		if NpcObj then
			local Scene = NpcObj.m_Scene
			local ObjInfo = assert(loadstring("return " .. StepTbl.Parameter1))()
			if ObjInfo then
				local ObjName = ObjInfo[1]
				local Pos = CPos:new()
				Pos.x = ObjInfo[2]
				Pos.y = ObjInfo[3]
				CreateIntObj(Scene, Pos, ObjName, true, nil, nil)
			end
		end
	end
end

function CTheaterFun:DestoryObj(StepTbl)
	local ObjName = StepTbl.NpcName
	local OnlyObj = self:GetOnlyObj(ObjName)
	if OnlyObj then
		g_IntObjServerMgr:Destroy(OnlyObj,false)
	end
end

function CTheaterFun:DoTask(StepTbl)
	local Args = StepTbl.Parameter1
	local PosID = StepTbl.Parameter2
	local TaskInfo = assert(loadstring("return " .. Args))()
	if TaskInfo then
		local TheaterName = TaskInfo[1]
		local Radius = TaskInfo[2]
		local Pos = CPos:new()
		Pos.x, Pos.y = GetScenePosition(tonumber(PosID))
		local SceneId = self.m_SceneId
		AddQuestTheaterVar(TheaterName, SceneId, Pos, Radius)
	end
end

function CTheaterFun:Lock(StepTbl)
	local Scene = g_SceneMgr:GetScene(self.m_SceneId)
	Scene.m_TheaterMgr:LockTheater(StepTbl.Parameter1)
end

function CTheaterFun:UnLock(StepTbl)
	local Scene = g_SceneMgr:GetScene(self.m_SceneId)
	Scene.m_TheaterMgr:UnLockTheater(StepTbl.Parameter1)
end

function CTheaterFun:HideQuest(StepTbl)
	local Player = CCharacterDictator_GetCharacterByID(self.m_StarterId)
	TriggerHideQuest(Player, StepTbl.Parameter1)
end
