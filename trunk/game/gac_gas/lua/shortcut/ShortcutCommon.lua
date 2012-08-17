gac_gas_require "framework/message/message"

EShortcutPieceState =
{
	eSPS_None  = 0,
	eSPS_Item  = 1,
	eSPS_Skill = 2,
	eSPS_Equip = 3,
	eSPS_Array = 4,
}


-----------------------------����Ƶ��--------------------


ChannelIdTbl = {}
ChannelIdTbl["ϵͳ"] = 1 --"ϵͳ"
ChannelIdTbl["����"] = 2 --"����"
ChannelIdTbl["��Ӫ"] = 3 --"��Ӫ" 
ChannelIdTbl["��ͼ"] = 4 --"��ͼ"
ChannelIdTbl["����"] = 5 --"����"
ChannelIdTbl["����"] = 6 --"����"
ChannelIdTbl["Ӷ��С��"] = 7 --"Ӷ����"
ChannelIdTbl["Ӷ����"] = 8 --"�Ŷ�"
ChannelIdTbl["NPC"] = 9 --"NPC"
ChannelIdTbl["����"] = 10 --"����"


ChannelTimeLimitTbl = {}
ChannelTimeLimitTbl[ChannelIdTbl["ϵͳ"]]	= 0 
ChannelTimeLimitTbl[ChannelIdTbl["����"]]	= 5
ChannelTimeLimitTbl[ChannelIdTbl["��Ӫ"]]	= 8
ChannelTimeLimitTbl[ChannelIdTbl["��ͼ"]]	= 3
ChannelTimeLimitTbl[ChannelIdTbl["����"]]	= 1
ChannelTimeLimitTbl[ChannelIdTbl["����"]]	= 0
ChannelTimeLimitTbl[ChannelIdTbl["Ӷ����"]]	= 0
ChannelTimeLimitTbl[ChannelIdTbl["Ӷ��С��"]]	= 0
ChannelTimeLimitTbl[ChannelIdTbl["NPC"]]	= 0
ChannelTimeLimitTbl[ChannelIdTbl["����"]]	= 0

---------------------------------
function g_CheckShortcutData(Type, Arg1, Arg2, Arg3)
	--[[
	if(Type == EShortcutPieceState.eSPS_Item) then
		local uBigID = Arg1
		assert(g_ItemInfoMgr:IsValid(uBigID) == true)
	elseif(Type == EShortcutPieceState.eSPS_Skill) then
		local SkillConfigMgr = GetSkillConfigMgr()
		local skill_name = Arg1
		local level = Arg2		
		assert(SkillConfigMgr:RawgetElement( MakeFightSkillID( skill_name, level ) ) ~= nil)
	elseif(Type == EShortcutPieceState.eSPS_Equip) then
		if not IsNumber(Arg1) then
			Arg1 = tonumber(Arg1)
		end
		local EquipPart = Arg1
		assert(g_CheckPart(EquipPart) == true)
	end
	--]]
	if(Type == EShortcutPieceState.eSPS_Skill) then
		if not (SkillPart_Common(Arg1) or NonFightSkill_Common(Arg1) or string.find(Arg1, "��ͨ����")) then
			return false
		end
	end
	return true
end
-----------------------------------------------
PosSkillNameTbl = {
							["�ڱ���̬"] = 1,
							["������̬"] = 2,
							["��ʨ��̬"] = 3,
							["��������"] = 1,
							["��������"] = 2,
							["��˪����"] = 3,
							}
							