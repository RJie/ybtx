cfg_load "npc/EnmityShareTeam_Server"

local function CreateGroupByMaster(MasterID)
	local Master = CCharacterDictator_GetCharacterByID(MasterID)
	if Master == nil then
		return false
	end
	Master:ClearAllServantByMasterDie()
	local Level = Master:CppGetLevel()
	local Scene = Master.m_Scene
	local Pos = CFPos:new()
	Master:GetPixelPos(Pos)
	local MasterName = Master.m_Properties:GetCharName()
	if EnmityShareTeam_Server(MasterName) == nil then
		return
	end
	local bReBornInBattle = EnmityShareTeam_Server(MasterName,"RebornInBattle")
	local ServantTbl = loadstring("return " .. EnmityShareTeam_Server(MasterName,"Group"))()
	local otherData = {}
	for i, v in pairs(ServantTbl) do
		otherData["m_MemberID"] = i
		local ServantNpc, logMsg = g_NpcServerMgr:CreateServerNpc(v, Level, Scene, Pos , otherData, MasterID, nil, nil, nil , false, nil)
		if not IsServerObjValid(ServantNpc) then
			LogErr("����Npcʧ��", logMsg)
			return
		end
		Master.m_MemberTbl[i] = {
									["ServantName"] 		= v,
									["ServantID"]			= ServantNpc:GetEntityID(),
									["bReBornInBattle"]		= bReBornInBattle
								}
	end
end

--��EnmityShareTeam_Server�����ؽ�һ��NpcȺ��
function CreateServerNpcGroup(Name, Level, Scene, Pos , MasterObjID, AIType, NpcType, ServantRealName , bIsBattleHorse)
	assert(EnmityShareTeam_Server(Name), "EnmityShareTeam_Server���в�����Npc��" .. Name .. "�������ʵ��")
	local Master, logMsg = g_NpcServerMgr:CreateServerNpc(Name, Level, Scene, Pos , nil, MasterObjID, AIType, NpcType, ServantRealName , bIsBattleHorse)
	if not IsServerObjValid(Master) then
		LogErr("����Npcʧ��", logMsg)
		return
	end
	RevertNpcGroup(Master:GetEntityID())
	return Master
end

function RevertNpcGroup(MasterID)
	local Master = CCharacterDictator_GetCharacterByID(MasterID)
	if Master == nil or Master:CppIsLive() == false then
		return
	end
	local MasterName = Master.m_Properties:GetCharName()
	if EnmityShareTeam_Server(MasterName) == nil then 
		return
	end
	if Master.m_MemberTbl == nil then	--��һ�ν��룬��ʼ�����е�С��
		Master.m_MemberTbl = {}
		CreateGroupByMaster(MasterID)
	else								--�Ժ�ÿ�ζ���С�ܲ���
		for i,v in pairs(Master.m_MemberTbl) do
			ServantInfoTbl = v
			if v["ServantID"] == 0 then
				RevertMemberByMaster(MasterID, i, v["ServantName"])
			end
		end
	end
	
end

function RevertMemberByMaster(MasterID, MemberID, ServantName)
	local Master = CCharacterDictator_GetCharacterByID(MasterID)
	if IsServerObjValid(Master) then
		if Master.m_ReBornCortegeTickTBl and Master.m_ReBornCortegeTickTBl[MemberID] then
			UnRegisterTick(Master.m_ReBornCortegeTickTBl[MemberID])
			Master.m_ReBornCortegeTickTBl[MemberID] = nil
		end
		local Level = Master:CppGetLevel()
		local Scene = Master.m_Scene
		local Pos = CFPos:new()
		Master:GetPixelPos(Pos)
		local otherData = {["m_MemberID"]=MemberID}
		local ServantNpc, logMsg = g_NpcServerMgr:CreateServerNpc(ServantName, Level, Scene, Pos , otherData, MasterID, nil, nil, nil , false, nil)
		if not IsServerObjValid(ServantNpc) then
			LogErr("����Npcʧ��", logMsg)
			return
		end
		Master.m_MemberTbl[MemberID]["ServantID"]	= ServantNpc:GetEntityID()
	end

end

function ClearMasterRebornTbl(Master)
	if Master.m_ReBornCortegeTickTBl == nil then
		return
	end
	for i,v in pairs(Master.m_ReBornCortegeTickTBl) do
		if Master.m_ReBornCortegeTickTBl[i] then
			UnRegisterTick(Master.m_ReBornCortegeTickTBl[i])
			Master.m_ReBornCortegeTickTBl[i] = nil
		end
	end
end
