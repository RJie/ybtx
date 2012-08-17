gas_require "world/trigger_action/item/item_trigger/UseArrowHead"   --ָ����



function UseItemEffectOnSelf(Conn, ItemInfo)
	local effectName = ItemInfo.effect
	if effectName == "ָ��ˢ��" then
--		CreatOnGivenPos(Conn,ItemInfo)
	elseif effectName == "�����糡" then
		StartTheater(Conn,ItemInfo)
	elseif effectName == "������������" then
		StartHideQuest(Conn,ItemInfo)
	elseif effectName == "ָ����" then
		CreatCompass(Conn,ItemInfo)
	elseif effectName == "����" then
		TransportToAreaPos(Conn,ItemInfo)
	elseif effectName == "���籾����" then
		TransportToAreaPos(Conn,ItemInfo,"YinFeng")
	elseif effectName == "������" then
		TransportToAreaPos(Conn,ItemInfo,"LingYu")
	elseif effectName == "��Ч��" then
		NoEffect(Conn,ItemInfo)
	elseif effectName == "�������ͷż���" then
		DoSkillOnSelf(Conn,ItemInfo)
	elseif effectName == "���ˢ��" then
		local pos = GetCreatePos(Conn.m_Player)
		CreatOnRandomPos(Conn,ItemInfo,pos)
	elseif effectName == "����" then
		local pos = GetCreatePos(Conn.m_Player)
		CreatOnPos(Conn,ItemInfo,pos)
	elseif effectName == "�Եص��ͷż���" then
		local pos = GetCreatePos(Conn.m_Player)
		DoSkillOnPos(Conn,ItemInfo, pos)
	elseif effectName == "ʹ�����䳵" then  --�¼�ʹ�����䳵����
		--CreatTruck(Conn, ItemInfo)	
	elseif effectName == "�����ʱ����" then
		AddTempSkillOnSelf(Conn,ItemInfo)
	elseif effectName == "�����������" then
		CreateNpcPet(Conn,ItemInfo)
	elseif effectName == "��ȡ����" then
		TakeQuest(Conn,ItemInfo)
	elseif effectName == "���פ�ش���" then
		ItemChangeTongScene(Conn,ItemInfo)
	elseif effectName == "���͵�ָ��λ��" then
		ChangeToThePos(Conn,ItemInfo)
	end
end

--�����糡
function StartTheater(Conn,ItemInfo)
	local function SuccessStart(Player,ItemInfo)
		local TheaterArgTbl = ItemInfo.Arg[1]
		local TheaterName = TheaterArgTbl[1]
		if not LockItem(Player.m_Conn,ItemInfo) then			--����Ʒ����
			UseItemEnd(Conn,ItemInfo,802)
			return
		end
		local isSuccess = Player.m_Scene.m_TheaterMgr:RunTriggerTheater(TheaterName,Player:GetEntityID())
		if isSuccess then
			UseItemEnd(Player.m_Conn,ItemInfo)
			return
		end
		--print("��������Ϊ:"..TheaterName.."�ľ糡")
		UseItemOtherList(Conn,ItemInfo)
	end
	local function FailedStart(Player,ItemInfo)
		if Player and IsCppBound(Player) then
			UseItemEnd(Player.m_Conn,ItemInfo)
			--print"�����糡ʧ��"
		end
	end
	BeginProgress(Conn,ItemInfo,SuccessStart,FailedStart)
end

--������������
function StartHideQuest(Conn,ItemInfo)
	local function SuccessStart(Player,ItemInfo)
		local TheaterArgTbl = ItemInfo.Arg[1]
		local HideQuestName = TheaterArgTbl[1]
		if not LockItem(Player.m_Conn,ItemInfo) then			--����Ʒ����
			UseItemEnd(Player.m_Conn,ItemInfo,802)
			return
		end
		--print("��������Ϊ:"..HideQuestName.."����������")
		TriggerHideQuest(Player, HideQuestName)
		UseItemOtherList(Conn,ItemInfo)
	end
	local function FailedStart(Player,ItemInfo)
		if Player and IsCppBound(Player) then
			UseItemEnd(Player.m_Conn,ItemInfo)
			--print"������������ʧ��"
		end
	end
	BeginProgress(Conn,ItemInfo,SuccessStart,FailedStart)
end

--��ȡ����
function TakeQuest(Conn,ItemInfo)
	local function SuccessTake(Player,ItemInfo)
		Gas2Gac:OnRClickQuestItem(Conn,ItemInfo.BigID,ItemInfo.ItemName)
		UseItemOtherList(Conn,ItemInfo)
	end
	local function FailedTake(Player,ItemInfo)
		if Player and IsCppBound(Player) then
			UseItemEnd(Player.m_Conn,ItemInfo)
			--print"��ȡ����ʧ��"
		end
	end
	BeginProgress(Conn,ItemInfo,SuccessTake,FailedTake)
end

--��Ч��
function NoEffect(Conn,ItemInfo)
	local function SuccessUse(Player,ItemInfo)
		if not LockItem(Player.m_Conn,ItemInfo) then			--����Ʒ����
			UseItemEnd(Conn,ItemInfo,802)
			return
		end
		UseItemOtherList(Conn,ItemInfo)
	end
	local function FailedUse(Player,ItemInfo)
		if Player and IsCppBound(Player) then
			UseItemEnd(Player.m_Conn,ItemInfo)
			--print("��Ʒʹ��ʧ��")
		end
	end
	BeginProgress(Conn,ItemInfo,SuccessUse,FailedUse)
end

--����
function TransportToAreaPos(Conn,ItemInfo,FbType)
	local ItemName = ItemInfo.ItemName
	local SceneName = Conn.m_Player.m_Scene.m_SceneName
	local info
	
	if Transport_Server(ItemName) then
		for _, i in pairs(Transport_Server:GetKeys(ItemName, "����")) do
			local TransInfo = Transport_Server(ItemName, "����", i.."")
			if (TransInfo("BeginScene") == "" or SceneName == TransInfo("BeginScene") )
				and (TransInfo("Camp") == 0 or TransInfo("Camp") == Conn.m_Player:CppGetBirthCamp()) then
				if Scene_Common[TransInfo("EndScene") ] == nil then
					UseItemEnd(Conn,ItemInfo)
					return
				end
				info = TransInfo
				break;
			end
		end
	end

	local function SuccessTransport(Player,ItemInfo)
		local Pos = CPos:new()
		local SceneName = Player.m_Scene.m_SceneName
--		local tbl = assert(loadstring("return " .. info.TargetPos))()
		Pos.x,Pos.y = info("PosX"), info("PosY")
		if not LockItem(Player.m_Conn,ItemInfo) then			--����Ʒ����
			UseItemEnd(Conn,ItemInfo,802)
			return
		end
		if info("EndScene") == SceneName then
			Player:SetGridPos(Pos)
			UseItemOtherList(Conn,ItemInfo)
		else
			if FbType then
				if FbType == "YinFeng" then
					local KillYinFengServer = CKillYinFengServer:new()
					KillYinFengServer:ChangeSceneFb(Player, info("EndScene"), Pos.x , Pos.y)
				elseif FbType == "LingYu" then
					CScopesExploration.UseItemInScene(Player, info("EndScene"), Pos.x , Pos.y)
				end
			else
				NewChangeScene(Player.m_Conn, info("EndScene"), Pos.x , Pos.y)
			end
			UseItemOtherList(Conn,ItemInfo)
		end
	end
	
	local function FailedTransport(Player,ItemInfo)
		if Player and IsCppBound(Player) then
			UseItemEnd(Player.m_Conn,ItemInfo)
			--print"����ʧ��"
		end
	end
	
	if FbType == "LingYu" then
		local teamId = Conn.m_Player.m_Properties:GetTeamID()
		if teamId == 0 then
			UseItemEnd(Conn,ItemInfo, 191035)
			return
		end
	end
	if info then
		BeginProgress(Conn,ItemInfo,SuccessTransport,FailedTransport)
	else
		UseItemEnd(Conn,ItemInfo,834,ItemName)
	end
end

--ָ����
function CreatCompass(Conn,ItemInfo)

	local function SuccessCreat(Player,ItemInfo)
		local ArgTbl = ItemInfo.Arg[1]
		local NpcType = ArgTbl[1]
		local NpcName = ArgTbl[2]
		local ShowTime = ArgTbl[3]
		--print("����ָ��"..NpcType.."��"..NpcName.."����ָ��.")
		if not LockItem(Player.m_Conn,ItemInfo) then			--����Ʒ����
			UseItemEnd(Conn,ItemInfo,802)
			return
		end
		local re = GetArrowHeadFromItem(Conn,NpcType,NpcName,ShowTime)
		if re then
			--print("�����ɹ�!")
			UseItemOtherList(Conn,ItemInfo)
		else
			UseItemEnd(Player.m_Conn,ItemInfo)
		end
	end
	
	local function FailedCreat(Player,ItemInfo)
		if Player and IsCppBound(Player) then
			UseItemEnd(Player.m_Conn,ItemInfo)
			--print("ָ���봴��ʧ��")
		end
	end
	BeginProgress(Conn,ItemInfo,SuccessCreat,FailedCreat)
end

--�������ͷż���
function DoSkillOnSelf(Conn,ItemInfo)
	local function SeccessCreat(Player,ItemInfo)
		local ArgTbl = ItemInfo.Arg[1]
		local SkillName = ArgTbl[1]
		local SkillLevel = ArgTbl[2] or 1
		if not LockItem(Player.m_Conn,ItemInfo) then			--����Ʒ����
			UseItemEnd(Conn,ItemInfo,802)
			return
		end
		if ItemInfo.ItemName == "�������䳵" and string.find(SkillName,"���䳵") then
			local Truck = Player:GetServantByType(ENpcType.ENpcType_Truck)
			if IsServerObjValid(Truck) then 
				UseItemEnd(Conn,ItemInfo,9212)
				return
			end
			local sceneType = Player.m_Scene.m_SceneAttr.SceneType
			if sceneType == 5 then
				UseItemEnd(Conn,ItemInfo,846)
				return
			end
		end
		
		local res = Player:PlayerDoItemSkill(SkillName,SkillLevel)
		if res == EDoSkillResult.eDSR_Success then
			--print("������ʹ�ü���"..SkillName.."�ɹ�")
			UseItemOtherList(Conn,ItemInfo)
			--print("ʹ��"..ItemInfo.ItemName.."�ɹ�!")
		else
			UseItemEnd(Player.m_Conn,ItemInfo)
		end
		--print("The Result of Player:PlayerDoItemSkill(SkillName,1) is "..res)
	end
	
	local function FailCreat(Player,ItemInfo)
		if Player and IsCppBound(Player) then
			UseItemEnd(Player.m_Conn,ItemInfo)
			--print"�������ͷż���ʧ��"
		end
	end
	BeginProgress(Conn,ItemInfo,SeccessCreat,FailCreat)
end

--�����������ʱ����
function AddTempSkillOnSelf(Conn,ItemInfo)

	local function SeccessAdd(Player,ItemInfo)
		local ArgTbl = ItemInfo.Arg[1]
		local SkillName = ArgTbl[1]
		local SkillLevel = ArgTbl[2]
		if not LockItem(Player.m_Conn,ItemInfo) then			--����Ʒ����
			UseItemEnd(Conn,ItemInfo,802)
			return
		end
		Player:AddTempSkill(SkillName,SkillLevel)
		UseItemOtherList(Conn,ItemInfo)
	end
	
	local function FailAdd(Player,ItemInfo)
		if Player and IsCppBound(Player) then
			UseItemEnd(Player.m_Conn,ItemInfo)
			--print"�����ʱ����ʧ��"
		end
	end
	
	BeginProgress(Conn,ItemInfo,SeccessAdd,FailAdd)
end

--�����������
function CreateNpcPet(Conn,ItemInfo)
	local function SeccessCreate(Player,ItemInfo)
		if not LockItem(Player.m_Conn,ItemInfo) then			--����Ʒ����
			UseItemEnd(Conn,ItemInfo,802)
			return
		end
		local tbl = ItemInfo.Arg[1]
		local NpcName = tbl[1]
		local BigID = ItemInfo.BigID
		local BaseLevel = g_ItemInfoMgr:GetItemInfo(BigID, ItemInfo.ItemName, "BaseLevel")
		
		if NpcName and Npc_Common(NpcName) and IsServerObjValid(Player) then
			local LittlePet = Player:GetServantByType(ENpcType.ENpcType_LittlePet)
			if IsServerObjValid(LittlePet) then
				Player:RemoveServant(LittlePet)
			else
				if Player:CppGetLevel() < BaseLevel then
					MsgToConn(Player.m_Conn, 420001)
					UseItemEnd(Player.m_Conn,ItemInfo)
					return
				end
				local PlayerPos = CFPos:new()
				local PlayerDir = CDir:new()
				local Dir = Player:GetActionDir()
				PlayerDir:SetDir(Dir)
				Player:GetPixelPos(PlayerPos)
				local vector2Dir = CVector2f:new()
				PlayerDir:Get(vector2Dir)
				local fPosX = vector2Dir.x * 3 * EUnits.eGridSpanForObj + PlayerPos.x
				local fPosY = vector2Dir.y * 3 * EUnits.eGridSpanForObj + PlayerPos.y
				local uLevel = Player:CppGetLevel()
				g_NpcServerMgr:CreateLittlePet(Player:GetEntityID(), NpcName, uLevel, fPosX, fPosY)
			end
		end
		UseItemOtherList(Conn,ItemInfo)
	end
	
	local function FailCreate(Player,ItemInfo)
		if Player and IsCppBound(Player) then
			UseItemEnd(Player.m_Conn,ItemInfo)
			--print"�����������ʧ��"
		end
	end
	
	BeginProgress(Conn,ItemInfo,SeccessCreate,FailCreate)
end

--���פ�ش���
function ItemChangeTongScene(Conn,ItemInfo)

	local tongId = Conn.m_Player.m_Properties:GetTongID()
	if tongId == 0 then
		UseItemEnd(Conn,ItemInfo,9450)
		return
	end
	local Truck = Conn.m_Player:GetServantByType(ENpcType.ENpcType_Truck)
	if IsServerObjValid(Truck) then
		UseItemEnd(Conn,ItemInfo,9041)
		return
	end
	
	local function SeccessTran(Player,ItemInfo)
		if not LockItem(Player.m_Conn,ItemInfo) then			--����Ʒ����
			UseItemEnd(Conn,ItemInfo,802)
			return
		end
		local tongId = Player.m_Properties:GetTongID()
		if tongId == 0 then
			UseItemEnd(Conn,ItemInfo,9450)
			return
		end
		local Truck = Player:GetServantByType(ENpcType.ENpcType_Truck)
		if IsServerObjValid(Truck) then
			UseItemEnd(Conn,ItemInfo,9041)
			return
		end
		
		ChangeTongScene(Conn)
		UseItemOtherList(Conn,ItemInfo)
	end
	
	local function FailTran(Player,ItemInfo)
		if Player and IsCppBound(Player) then
			UseItemEnd(Player.m_Conn,ItemInfo)
		end
	end
	
	BeginProgress(Conn,ItemInfo,SeccessTran,FailTran)
end


function ChangeToThePos(Conn,ItemInfo)
	local ItemName = ItemInfo.ItemName
	local SceneName = Conn.m_Player.m_Scene.m_SceneName
	local Player = Conn.m_Player
	if not IsCppBound(Conn) or not IsCppBound(Player) then
		return
	end
	local name = Player.m_Properties:GetCharName()
	local Pos = CPos:new()
	Player:GetGridPos(Pos)
	
	local function SuccessTransport(Player,ItemInfo)
		if not IsCppBound(Conn) or not IsCppBound(Player) then
			return
		end
		if not LockItem(Player.m_Conn,ItemInfo) then			--����Ʒ����
			UseItemEnd(Conn,ItemInfo,802)
			return
		end
		local data = {}
		data["tongId"] = Player.m_Properties:GetTongID()
		data["charId"] = Player.m_uID
		data["num"] = 40
		data["info"] = Player.UseItemParam[ItemInfo.ItemName].ConsumeItemTbl
		data["sceneId"] = Player.m_Scene.m_SceneId
		local function CallBack(result, serverId)
			if not result then
				MsgToConn(Conn, 195001)
				return
			end
			local num = result:GetRowNum()
			if num > 0 then
				for i = 0, num - 1 do
					Gas2GacById:ShowPanelByTongItem(result:GetData(i, 0), SceneName, Pos.x, Pos.y, name, Player.m_Scene.m_SceneId, serverId)
				end
			end
			UseItemEnd(Player.m_Conn,ItemInfo)
		end
		CallAccountManualTrans(Conn.m_Account, "GasTongItemUseDB", "GetOnlineTongMember", CallBack, data)
	end
	
	local function FailedTransport(Player,ItemInfo)
		if Player and IsCppBound(Player) then
			UseItemEnd(Player.m_Conn,ItemInfo)
		end
	end

	BeginProgress(Conn,ItemInfo,SuccessTransport,FailedTransport)
end

--����Npc
function UseItemCreateNpc(Conn, ItemName, name, pos, dir, level)
	level = g_NpcBornMgr:GetNpcBornLevel(name)
	local NpcInfo = Npc_Common(name)
	if dir == nil or type(dir) ~= "number" then
		dir = math.random(0, 255)
	end
	
	local fPos = CFPos:new( pos.x * EUnits.eGridSpan, pos.y * EUnits.eGridSpan )	
	
	local otherData = 	{
							["m_CreatorEntityID"]=Conn.m_Player:GetEntityID(),
							["m_OwnerId"]=Conn.m_Player.m_uID
						}
	local Npc
	if IsServantType(NpcInfo("Type")) then
		Npc = g_NpcServerMgr:CreateServerNpc(name,level,Conn.m_Player.m_Scene,fPos,otherData,Conn.m_Player:GetEntityID())
	else
		Npc = g_NpcServerMgr:CreateServerNpc(name,level,Conn.m_Player.m_Scene,fPos,otherData)
	end
	if not IsServerObjValid(Npc) then
		return Npc
	end
	Npc:SetCanDelInBattle(true)																--NPC��ս���������ڵ���Ҳ�Զ�����
	Npc:SetAndSyncActionDir(dir)
	if not Conn.m_Player.UseItemParam.CreateTbl then
		Conn.m_Player.UseItemParam.CreateTbl = {}
	end
	Conn.m_Player.UseItemParam.CreateTbl[name] = true
	return Npc
end

--����IntObj
function UseItemCreateIntObj(Conn,name,pos,dir)
	if dir == nil or type(dir) ~= "number" then
		dir = math.random(0, 255)
	end
	local Obj = CreateIntObj(Conn.m_Player.m_Scene,pos,name,true,Conn.m_Player.m_uID,nil,os.time(),dir)
	if Obj == nil then
		return Obj
	end
	Obj.m_OwnerId = Conn.m_Player.m_uID
	Obj.m_CreateTime = os.time()
	return Obj
end

--����Trap
function UseItemCreateTrap(Conn, name, pos)
	local trap = CreateServerTrap(Conn.m_Player.m_Scene,pos,name)
	if trap == nil then
		return trap
	end
	trap.m_OwnerId = Conn.m_Player.m_uID
	return trap
end


function CreatTruck(Conn, ItemInfo)
	local Player = Conn.m_Player
	if not Player:CppIsLive() then
		UseItemEnd(Conn,ItemInfo)
		return 
	end
	local Truck = Player:GetServantByType(ENpcType.ENpcType_Truck)
	
	if IsServerObjValid(Truck) then
		UseItemEnd(Conn,ItemInfo, 9205)
		return
	end

	local ObjectTbl = ItemInfo.Arg[1]
	local name = ObjectTbl[1]
	local MaxLoad = ObjectTbl[2]	
	
	local TruckEntity = CTruck:Create(Player, name, MaxLoad) 
	UseItemOtherList(Conn,ItemInfo)
end
