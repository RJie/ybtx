local NpcAndPlayerType = 
{
	["��ͨNPC"]				= -1,
	["��ȡ����"]			= 5,	--��Ϊc++�зǹ���npc�����������ϸ�����֣���0~4�����Թ���npc��5��ʼ����
	["�������"] 			= 6,
	["���������"]          = -1
}

function GetFuncTypeByNpcName(NpcName)
	local npcType, TexSrc = CQuest.GetFuncNameByNpcName(NpcName)
	
	if npcType == nil then
		return NpcAndPlayerType["��ͨNPC"]
	end
	if IsNumber(npcType) then
		if npcType == 0 then
				return NpcAndPlayerType["��ͨNPC"]--2������c++��ֵ��enemyNpc or friendNpc��
		else
			return npcType, TexSrc
		end
	else
		return NpcAndPlayerType[npcType]
	end
end