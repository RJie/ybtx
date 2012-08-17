
-----------------------------------

local StmtOperater = {}		--������sql����table
--�հ���ʼ
local SettingBox = CreateDbBox(...)

-------------------------------------------------------
--���������Ϣ
local StmtDef = {
	"_AddGameSettingInfo",
	[[
		replace into tbl_game_setting(cs_uId,gs_uTeamSetting,gs_uTransSetting,gs_uGroupSetting,gs_uFriendSetting,gs_uTroopSetting,gs_uAutoMakeTeam,gs_uSelectQuestSort) 
	 	values(?,?,?,?,?,?,?,?)
	 ]]
}
DefineSql( StmtDef, StmtOperater )

--��ѯĳ��ҵ�������Ϣ
local StmtDef = {
	"_GetGameSettingInfo",
	[[
		select gs_uTeamSetting,gs_uTransSetting,gs_uGroupSetting,gs_uFriendSetting,gs_uTroopSetting,gs_uAutoMakeTeam,gs_uSelectQuestSort
	 	from tbl_game_setting 
	 	where	cs_uId = ?
	 ]]
}
DefineSql( StmtDef, StmtOperater )


--��Ϸ��������
function SettingBox.GameSettingDB(parameters)
	local uPlayerID = parameters["uPlayerID"]
	local team_setting = parameters["team_setting"]
	local trans_setting = parameters["trans_setting"]
	local group_setting = parameters["group_setting"]
	local friend_setting = parameters["friend_setting"]
	local troop_setting = parameters["troop_setting"]
	local autoMakeTeam_setting = parameters["autoMakeTeam_setting"]
	local selectQuestSort_setting = parameters["selectQuestSort_setting"]
	
	StmtOperater._AddGameSettingInfo:ExecSql('',uPlayerID,team_setting,trans_setting,group_setting,friend_setting,troop_setting,autoMakeTeam_setting,selectQuestSort_setting)
	if not (g_DbChannelMgr:LastAffectedRowNum()>0)  then
  		CancelTran()
  		return false
  end
  return true
end

--�õ�ĳ��ҵ���Ϸ������Ϣ
function SettingBox.GetGameSettingInfo(uPlayerID)
	local query_result = StmtOperater._GetGameSettingInfo:ExecSql('nnnnnnn',uPlayerID)
	if query_result:GetRowNum() == 0 then
		return 1,1,1,1,1,1,3
	end
	return query_result:GetNumber(0,0),query_result:GetNumber(0,1),query_result:GetNumber(0,2),query_result:GetNumber(0,3),query_result:GetNumber(0,4),query_result:GetNumber(0,5),query_result:GetNumber(0,6)
end

--�ж�ĳ�����Ƿ�����Ϊ���������״̬
--1\2\3\4\5\6\7�ֱ�����Ƿ������ӡ��Ƿ���Խ��ס��Ƿ���Լ���Ⱥ���Ƿ���Խ��ѡ��Ƿ�������š��Ƿ�����Զ���ӡ�׷��������������ʽ
function SettingBox.GetOneSettingInfo(uPlayerID,nIndex)
	local uTeamSet,uTransSet,uGroupSet,uFriendSet,uTroopSet,uAutoMakeTeamSet,uSelectQuestSortSet = SettingBox.GetGameSettingInfo(uPlayerID)
	if nIndex == 1 then
		return uTeamSet
	elseif nIndex == 2 then
		return uTransSet
	elseif nIndex == 3 then
		return uGroupSet
	elseif nIndex == 4 then
		return uFriendSet
	elseif nIndex == 5 then
		return uTroopSet
	elseif nIndex == 6 then
		return uAutoMakeTeamSet
	elseif nIndex == 7 then
		return uSelectQuestSortSet
	end
end

--�õ���Ϸ������Ϣ
function SettingBox.GetGameSettingInfoDB(parameters)
	local uPlayerID = parameters["uPlayerID"]
	local uTeamSet,uTransSet,uGroupSet,uFriendSet,uTroopSet,uAutoMakeTeamSet,uSelectQuestSortSet = SettingBox.GetGameSettingInfo(uPlayerID)
	return {uTeamSet,uTransSet,uGroupSet,uFriendSet,uTroopSet,uAutoMakeTeamSet,uSelectQuestSortSet}
end


-------------------------------------------------------

SetDbLocalFuncType(SettingBox.GetGameSettingInfoDB)
SetDbLocalFuncType(SettingBox.GameSettingDB)
return SettingBox