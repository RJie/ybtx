QuestState = {
	init	= 1,
	failure	= 2,
	finish	= 3
}

-----�ж������Ƿ�ɽ�     begin
--�ж������Ƿ������������Ӫ���� ������������Ӫ,������
function IfAcceptQuestCamp(Player, questname)
	local camp = Player:CppGetCamp()
	local camplimit = Quest_Common(questname, "��Ӫ����")
	if camplimit and camplimit~=0	and camplimit~=camp then
		return false
	end
	return true
end

function IfAcceptQuestClass(Player, questname)
	local classTab = {
		
		["��ְҵ"] = EClass.eCL_NoneClass,
		["��ʿ"] = EClass.eCL_Warrior,
		["ħ��ʿ"] = EClass.eCL_MagicWarrior,
		["��ʿ"] = EClass.eCL_Paladin,
		["��ʦ"] = EClass.eCL_NatureElf,
		["аħ"] = EClass.eCL_EvilElf,
		["��˾"] = EClass.eCL_Priest,
		["������ʿ"] = EClass.eCL_DwarfPaladin,
		["���鹭����"] = EClass.eCL_ElfHunter,
		["����սʿ"] = EClass.eCL_OrcWarrior
	}
	
	local class = Player:CppGetClass()
	local subject = GetCfgTransformValue(true, "Quest_Common", questname, "ְҵ����")
	if subject then
		for i = 1, table.maxn(subject) do 
			for j = 1, table.maxn(subject[i]) do
				local sub = subject[i][j]
				if class == classTab[sub] then
					return true
				end
			end
		end
	else
		return true
	end
end

--�ж������Ƿ�������������С�ȼ� ����������ȼ�,������
function IfAcceptQuestMinLev(Player, questname)
	local lev = Player:CppGetLevel()
	local minlevel = Quest_Common(questname, "��������С�ȼ�")
	if (minlevel and minlevel ~= 0 and lev < minlevel) then
		return
	end
	return true
end

function IfAcceptQuestMaxLev(Player, questname)
	local lev = Player:CppGetLevel()
	local maxlevel = Quest_Common(questname, "��������ߵȼ�")
	if (maxlevel and maxlevel ~= 0 and lev > maxlevel) then
		return
	end
	return true
end


--�жϽ�����ʱ��ҵ�ǰ���ڵ�ͼ�Ƿ���ȷ
function IfAcceptQuestMap(scenename, questname)
--	if Quest_Common(questname, "��������ʽ", "HyperLink") ~= scenename then
--		return false
--	end
	return true
end
--�жϽ�����ʱ��ҵ�ǰ���ڵ�ͼ�Ƿ���ȷ
function IfFinishQuestMap(scenename, questname)
--	if Quest_Common(questname, "��������ʽ", "HyperLink") ~= scenename then
--		return false
--	end
	return true
end
--�ж��������������Ƿ��������������� ���������ﵱǰλ��,npcλ��
function IfAcceptQuestArea(Player, Pos)

	if not IsCppBound(Player) then
		return false
	end
	local pos1 = CPos:new()
	local pos2 = Pos
	Player:GetGridPos( pos1 )
	return math.max( math.abs( pos1.x - pos2.x ), math.abs( pos1.y - pos2.y ) )<=5
end
-----�ж������Ƿ�ɽ�     end

-----�ж������Ƿ���ύ     begin
--�жϽ�ɫ����λ���Ƿ�����ύ����
function IfCanFinishArea(Player, Pos)
	local pos1 = CPos:new()
	local pos2 = Pos
	Player:GetGridPos( pos1 )
	return math.max( math.abs( pos1.x - pos2.x ), math.abs( pos1.y - pos2.y ) )<=5
end

function IsPasserbyCamp(Camp, PlayerCamp, GameCamp, PlayerGameCamp)
	if PlayerGameCamp == 0 or GameCamp == 0 then  --һ��Ϊ��ʵ��Ӫ,�Ƚ���ʵ��Ӫ
		if Camp == ECamp.eCamp_Passerby or Camp == ECamp.eCamp_Specail or Camp == PlayerCamp then
			return true
		end
		return false
	else
		if GameCamp == PlayerGameCamp then
			return true
		end
		return false
	end
end
