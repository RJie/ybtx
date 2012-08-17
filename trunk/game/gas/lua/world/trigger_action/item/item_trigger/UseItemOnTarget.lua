
function UseItemEffectOnTarget(Conn, ItemInfo, Target)
	local effectName = ItemInfo.effect
	if effectName == "��Ŀ���ͷż���" then
		DoSkillToTarget(Conn,ItemInfo,Target)
	elseif effectName == "�滻" then
		ReplaceTarget(Conn,ItemInfo,Target)
	elseif effectName == "ת��" then
		--print("ת���ű��Ѿ�������")
	elseif effectName == "����" then
		DestryTarget(Conn,ItemInfo,Target)
	elseif effectName == "���ˢ��" then
		local pos = GetCreatePos(Target)
		CreatOnRandomPos(Conn,ItemInfo,pos)
	elseif effectName == "����" then
		local pos = GetCreatePos(Target)	
		CreatOnPos(Conn,ItemInfo,pos)
	elseif effectName == "���ý���" then
		LayBuild(Conn, ItemInfo)	
	elseif effectName == "������ʱ����" then
		LayTempBuild(Conn, ItemInfo)
	elseif effectName == "�Եص��ͷż���" then
		local pos = GetCreatePos(Target)
		DoSkillOnPos(Conn,ItemInfo, pos)
	else
		UseItemEffectOnSelf(Conn, ItemInfo)
	end
end

--��Ŀ���ͷż���
function DoSkillToTarget(Conn,ItemInfo,Target)

	local function SeccessDoSkill(Player,ItemInfo,pos,Target)		--posû���ô� ֻ��Ϊ�˴���Target
		if Target == nil or not IsCppBound(Target) then
			UseItemEnd(Conn,ItemInfo,828)
			return
		end
		local reTarget = Player:GetTarget()
		local TargetName = Target.m_Properties:GetCharName()

		local ArgTbl = ItemInfo.Arg[1]
		local SkillName = ArgTbl[1]
		local SkillLevel = ArgTbl[2] or 1
		
		if not LockItem(Conn,ItemInfo) then			--����Ʒ����
			UseItemEnd(Conn,ItemInfo,802)
			return
		end
		Player:SetTarget(Target)
		local res =	Player:PlayerDoItemSkill(SkillName,SkillLevel)
		Player:SetTarget(reTarget)								--��Ŀ��ʹ���꼼�������ԭ����Ŀ��
		if res == EDoSkillResult.eDSR_Success then
			g_MatchGameMgr:AddMatchGameCount(Player, 3, TargetName)
			UseItemOtherList(Conn,ItemInfo,Target)
		elseif res == EDoSkillResult.eDSR_ToTargetHaveBarrier then
			UseItemEnd(Conn,ItemInfo,825,TargetName,ItemInfo.ItemName)		
		elseif res == EDoSkillResult.eDSR_OutOfDistance then
			UseItemEnd(Conn,ItemInfo,826,TargetName,ItemInfo.ItemName)	
		else
			UseItemEnd(Conn,ItemInfo)					
		end
		--print("The Result of Player:PlayerDoItemSkill(SkillName,1) is "..res)
	end
	
	local function FailDoSkill(Player,ItemInfo)
		UseItemEnd(Conn,ItemInfo)
		--print"����ʹ�ò��ɹ�"
	end
	
	BeginProgress(Conn,ItemInfo,SeccessDoSkill,FailDoSkill,nil,Target)
end

--����
function DestryTarget(Conn,ItemInfo,Target)

	local function SuccessDestry(Player,ItemInfo,pos,Target)
		if Target == nil or not IsCppBound(Target) then
			UseItemEnd(Conn,ItemInfo,828)
			return
		end
		local TargetTbl = ItemInfo.InfluenceTarget
		local TargetType = TargetTbl[1]
		local TargetName = TargetTbl[2]
		
		if TargetType == "Npc" then
			if not LockItem(Conn,ItemInfo) then			--����Ʒ����
				UseItemEnd(Conn,ItemInfo,802)
				return
			end
			Target:SetOnDisappear(true)		
			Target = nil
			UseItemOtherList(Conn,ItemInfo)
		elseif TargetType == "Object" then
			if not LockItem(Conn,ItemInfo) then			--����Ʒ����
				UseItemEnd(Conn,ItemInfo,802)
				return
			end
			g_IntObjServerMgr:Destroy(Target,true)
			UseItemOtherList(Conn,ItemInfo)
		end
	end
	
	local function FailDestry(Player,ItemInfo)
		UseItemEnd(Conn,ItemInfo)
		--print("������Ʒ��npcʧ��")
	end
	BeginProgress(Conn,ItemInfo,SuccessDestry,FailDestry,nil,Target)
end

function ReplaceTarget(Conn,ItemInfo,Target)

	local function SuccessChange(Player,ItemInfo,pos,Target)
		if Target == nil or not IsCppBound(Target) then
			UseItemEnd(Conn,ItemInfo,828)
			return
		end
		local ChangeTbl	= ItemInfo.Arg[1]
		local ChangeType = ChangeTbl[1]
		local ChangeName = ChangeTbl[2]
		local pos = GetCreatePos(Target)
		local dir = Target:GetActionDir()
		if not LockItem(Conn,ItemInfo) then			--����Ʒ����
			UseItemEnd(Conn,ItemInfo,802)
			return
		end
		if ChangeType == "Npc" then
			local npc = UseItemCreateNpc(Conn, ItemInfo.ItemName, ChangeName, pos, dir)
			if npc == nil then
				UseItemEnd(Conn,ItemInfo)
				return
			end
			Target:SetOnDisappear(true)
			UseItemOtherList(Conn,ItemInfo)
		elseif ChangeType == "Object" then
			local Obj = UseItemCreateIntObj(Conn, ChangeName, pos, dir)
			if Obj == nil then
				UseItemEnd(Conn,ItemInfo)
				return
			end
			g_IntObjServerMgr:Destroy(Target,true)
			UseItemOtherList(Conn,ItemInfo)
		end
	end

	local function FailChange(Player,ItemInfo)
		UseItemEnd(Conn,ItemInfo)
		--print"��Ʒ��npc�滻ʧ��"
	end
	BeginProgress(Conn,ItemInfo,SuccessChange,FailChange,nil,Target)
end