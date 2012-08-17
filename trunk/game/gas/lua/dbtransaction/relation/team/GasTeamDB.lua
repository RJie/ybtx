
-----------------------------------
gas_require "relation/RevertValidateMgr"
gac_gas_require "team/TeamMgr"
local DefaultTeamMode = EAssignMode.eAM_NeedAssign
local DefaultStandard = EAuctionStandard.eAS_GreenStandard
local DefaultBasePrice = 0
local RevertValidateMgr = RevertValidateMgr:new()
local StmtOperater = {}		
local GasTeamBox = CreateDbBox(...)
------------------------------------------���sql-----------------------------------------------------
local StmtDef = {
    	"_AddTeamStaticInfo",
    	[[ 
    		insert into tbl_team_static values();
    	]]
}    
DefineSql ( StmtDef, StmtOperater )


--���õ�teamid��
--ps�������ǽ�ɫid
local StmtDef = {
    	"_GetTeamId",
    	[[ 
    		select t_uId from tbl_member_team where cs_uId = ?
    	]]
}    
DefineSql ( StmtDef, StmtOperater )

--����ö���������
--ps�������ǽ�ɫid
local StmtDef = {
    	"_CountTeamMems",
    	[[ 
    		select count(*) from tbl_member_team where t_uId = ?
    	]]
}    
DefineSql ( StmtDef, StmtOperater )

--�����Ӷ�Ա��
local StmtDef = {
    	"_AddTeamMember",
    	[[ replace into tbl_member_team(cs_uId, t_uId ) values(?,?) ]]
}    
DefineSql ( StmtDef, StmtOperater )

--��ɾ����Ա��
local StmtDef = {
    	"_DeleteTeamMember",
    	[[ 
    		delete from  tbl_member_team where cs_uId = ? 
    	]]
}    
DefineSql ( StmtDef, StmtOperater )

local StmtDef = {
    	"_DelStaticTeamID",
    	[[ 
    		delete from  tbl_team_static where t_uId = ? 
    	]]
}    
DefineSql ( StmtDef, StmtOperater )

--������С�ӡ�
--ps1��С��id����
--ps2�������Ƕӳ���id
local StmtDef = {
    	"_AddTeam",
    	[[ 
    		insert into tbl_team(t_uId,cs_uId,t_uAssignment)  values(?,?,?)
    	]]
}    
DefineSql ( StmtDef, StmtOperater )

--��ɾ��С�ӡ�
local StmtDef = {
    	"_DeleteTeam",
    	[[ 
    		delete  from  tbl_team where t_uId = ?
    	]]
}    
DefineSql ( StmtDef, StmtOperater )

--��ɾ��С�����г�Ա��
--ps��������С��id
local StmtDef = {
    	"_DeleteAllTeamMembers",
    	[[ 
    		delete  from  tbl_member_team where t_uId = ?
    	]]
}    
DefineSql ( StmtDef, StmtOperater )

--��ɾ��С�����б����Ϣ��
--������С��id
local StmtDef = {
    	"_DeleteAllTeamMarks",
    	[[ 
    		delete  from  tbl_mark_team where t_uId = ?
    	]]
}    
DefineSql ( StmtDef, StmtOperater )

--���޸Ķӳ���
--�������¶ӳ�id��С��id
local StmtDef = {
    	"_UpdateTeamCaptain",
    	[[ 
    		 update  tbl_team set  cs_uId = ?  where t_uId = ?
    	]]
}    

DefineSql ( StmtDef, StmtOperater )

--��ɾ��������Ϣ��
--������С��id
local StmtDef = {
			"_DeleteArrayBattle",
			[[ 
				delete from	tbl_battle_array where t_uId = ? 
			]]
}
DefineSql ( StmtDef, StmtOperater )

--�����÷��䷽ʽ��
local StmtDef = {
			"_UpdateAssignMode",
			[[ 
    		 update  tbl_team set  t_uAssignment = ?  where t_uId = ?
    	]]
}
DefineSql ( StmtDef, StmtOperater )

--�����䷽ʽ������ģʽ������Ʒ���趨�� 
local StmtDef = {
			"_UpdateAuctionStandard",
			[[ 
    		 update  tbl_team set  t_uAuctionStandard = ?  where t_uId = ?
    	]]
}
DefineSql ( StmtDef, StmtOperater )

--�����䷽ʽ������ģʽ�������׼��趨�� 
local StmtDef = {
			"_UpdateAuctionBasePrice",
			[[ 
    		 update  tbl_team set  t_uAuctionBasePrice = ?  where t_uId = ?
    	]]
}
DefineSql ( StmtDef, StmtOperater )


local StmtDef = {
			"_GetTeamAssignAndAuction",
			[[ 
    		 select t_uAssignment,t_uAuctionStandard,t_uAuctionBasePrice from tbl_team where t_uId = ?
    	]]
}
DefineSql ( StmtDef, StmtOperater )

--�����С�ӷ��䷽ʽ��
local StmtDef = {
			"_GetTeamAssignMode",
			[[ 
    		 select t_uAssignment from tbl_team where t_uId = ?
    	]]
}
DefineSql ( StmtDef, StmtOperater )


--�����С�ӷ��䷽ʽ������ģʽ������Ʒ�� ��  
local StmtDef = {
			"_GetTeamAuctionStandard",
			[[ 
    		 select t_uAuctionStandard from tbl_team where t_uId = ?
    	]]
}
DefineSql ( StmtDef, StmtOperater )


--�����С�ӷ��䷽ʽ������ģʽ�������׼� ��  
local StmtDef = {
			"_GetTeamAuctionBasePrice",
			[[ 
    		 select t_uAuctionBasePrice from tbl_team where t_uId = ?
    	]]
}
DefineSql ( StmtDef, StmtOperater )

--���õ�С�ӳ�Ա��Ϣ��
local StmtDef = {
    	"_GetTeamMembers",
    	[[ 
    		select cs_uId  from  tbl_member_team  where t_uId = ?
    	]]
}    
DefineSql ( StmtDef, StmtOperater )

local StmtDef = {
    	"_GetTeamOnlineMembers",
    	[[ 
    		select 
    			mt.cs_uId  
    		from  
    			tbl_member_team as mt, tbl_char_online as co 
    		where 
    			mt.t_uId = ? and co.cs_uId = mt.cs_uId
    	]]
}    
DefineSql ( StmtDef, StmtOperater )

local StmtDef = {
    	"_CountOnlineMembersByServer",
    	[[ 
    		select 
    			count(mt.cs_uId)  
    		from  
    			tbl_member_team as mt, tbl_char_online as co 
    		where 
    			mt.t_uId = ? and co.cs_uId = mt.cs_uId and co.co_uOnServerId = ?
    	]]
}    
DefineSql ( StmtDef, StmtOperater )

--���õ�С�ӳ�Աid�����ơ�
local StmtDef = {
    	"_GetTeamMates",
    	[[ 
    		select		team.cs_uId,chr.c_sName, ifnull(co_uOnServerId,0), cstatic.cs_uClass,cstatic.cs_uSex,cbasic.cb_uLevel
    		from 		tbl_member_team as team,
    					tbl_char as chr,
    					tbl_char_static as cstatic,
    					tbl_char_basic as cbasic
    		left join
    				tbl_char_online as online on online.cs_uId = cbasic.cs_uId
    		where	team.cs_uId = chr.cs_uId
    		and		chr.cs_uId = cstatic.cs_uId
    		and 	cstatic.cs_uId = cbasic.cs_uId
    		and		team.t_uId = ?
    	]]
}    
DefineSql ( StmtDef, StmtOperater )

--����öӳ�id��
local StmtDef = {
    	"_GetCapationByTeam",
    	[[ 
    		select  cs_uId  from  tbl_team where t_uId = ?
    	]]
}    
DefineSql ( StmtDef, StmtOperater )

--����ѯ������Ϣ(����С��ID)��
local StmtDef = {
			"_QueryArrayBattleByTeamID",
			[[ 
				select bs_uId,ba_uLoc1,ba_uLoc2,ba_uLoc3,ba_uLoc4,ba_uLoc5 from	tbl_battle_array where t_uId=?
			]]
}
DefineSql (StmtDef,StmtOperater)

--������������Ϣ(������ˮ�ź�С��ID)��
local StmtDef = {
			"_UpdateArrayBattle",
			[[ 
				update tbl_battle_array set ba_uLoc1=? , ba_uLoc2=? , ba_uLoc3=? , ba_uLoc4=? , ba_uLoc5=?  where bs_uId=? and t_uId=?
			]]
}
DefineSql (StmtDef,StmtOperater)

--���õ�С�����������߳�Ա��
--ps�����ڷ���������ʱ��������С�ӵ���Ϣ
--ps2������С��id�����id�����䷽ʽ������Ʒ��
local StmtDef = {
			"_SelectAllMembersOnline",
			[[ 
				select   member.cs_uId from  tbl_member_team as member,tbl_char_online as online
				where 	member.cs_uId = online.cs_uId
				and 		member.cs_uId != ?
				and			member.t_uId = ?
				limit 1;
			]]
}
DefineSql (StmtDef,StmtOperater)

-------------------------------------------���ݿ������ز���------------------------------------------
function GasTeamBox.GetTeamMembersInfo(uTeamID)
	local query_list = StmtOperater._GetTeamMates:ExecStat(uTeamID)

	return query_list
end

function GasTeamBox.GetSomeMemberOnlineByTeamID(uTeamID,uPlayerID)
 	local query_list =  StmtOperater._SelectAllMembersOnline:ExecSql('n', uPlayerID,uTeamID)
 	if query_list:GetRowNum() == 0 then
 		return uPlayerID
 	else
 		return query_list:GetNumber(0,0)
 	end
end

function GasTeamBox.AddTempTeamlog(data)
 	local team_id = data.team_id
 	local members = data.member_id
 	local CharacterMediatorDB = RequireDbBox("CharacterMediatorDB")
  local g_LogMgr = RequireDbBox("LogMgrDB")
 	for i=1,#members do
 		local member_id = members[i]
 		local member_level = CharacterMediatorDB.GetPlayerLevel(member_id)
 		g_LogMgr.EnterTeam(member_id,team_id,member_level)
	end
end

--[[
		�����ܣ����С��id
			��������ɫid��
--]]
function GasTeamBox.GetTeamID(uPlayerID)
 	local team_id =  StmtOperater._GetTeamId:ExecSql('n', uPlayerID)
 	if team_id:GetRowNum() == 0 then
 	 	team_id:Release()
 	 	return 0
 	end
  local teamID = team_id:GetNumber(0,0)
  team_id:Release()
 	return teamID
end

function GasTeamBox.CountTeamMems(nTeamID)
 	local count =  StmtOperater._CountTeamMems:ExecSql('n', nTeamID)
 	if count:GetRowNum() == 0 then
 	 	count:Release()
 	 	return 0
 	end
  local nCount = count:GetNumber(0,0)
  count:Release()
 	return nCount
end

-----------------------------------------------------------

--�����Ӷ�Ա��
function GasTeamBox.AddMembers(player_id, team_id)
  StmtOperater._AddTeamMember:ExecSql('', player_id, team_id)
  if not (g_DbChannelMgr:LastAffectedRowNum()>0)  then
  	CancelTran()
  	return false  
  end
  
  local TeamSceneMgrDB = RequireDbBox("TeamSceneMgrDB")
  TeamSceneMgrDB.OnAddMember(player_id, team_id)
  
  --���log��Ϣ
 	local CharacterMediatorDB = RequireDbBox("CharacterMediatorDB")
  local g_LogMgr = RequireDbBox("LogMgrDB")
 	local member_level = CharacterMediatorDB.GetPlayerLevel(player_id)
  g_LogMgr.EnterTeam(player_id, team_id,member_level)
  
  return true
end

---------------------------------------------------------------
--�����ݽ�ɫidɾ����Ա��
function GasTeamBox.DeleteMembers(player_id, team_id)
	 --���log��Ϣ
  local g_LogMgr = RequireDbBox("LogMgrDB")
  g_LogMgr.LeaveTeam(player_id, GasTeamBox.GetTeamID(player_id))
  
  --���鸱������������
  local TeamSceneMgrDB = RequireDbBox("TeamSceneMgrDB")
  local JoinActionDB  = RequireDbBox("JoinActionDB")
  local IsLeaveScene = TeamSceneMgrDB.OnLeaveTeam(player_id, team_id)
  JoinActionDB.OnLeaveTeam(player_id, team_id)
  local SceneMgrDB = RequireDbBox("SceneMgrDB")
  SceneMgrDB.OnLeaveTeam(player_id, team_id)
  
  StmtOperater._DeleteTeamMember:ExecSql('', player_id)
  if not (g_DbChannelMgr:LastAffectedRowNum()>0)  then
  	CancelTran()
  	return false  
  end
  return true, IsLeaveScene
end
---------------------------------------------------------------
function GasTeamBox.GetTeamStaticID(data)
	StmtOperater._AddTeamStaticInfo:ExecStat()
	if not (g_DbChannelMgr:LastAffectedRowNum()>0)  then
  		CancelTran()
  		return  0 
  end
	local team_id = g_DbChannelMgr:LastInsertId()
	return team_id,data
end

--������С�ӡ�
function GasTeamBox.AddTeam(uCharID,uTeamMode)
		local team_id = GasTeamBox.GetTeamStaticID()
  	StmtOperater._AddTeam:ExecStat(team_id,uCharID,uTeamMode)
  	if not (g_DbChannelMgr:LastAffectedRowNum()>0)  then
  		CancelTran()
  		return  0 
  	end
  	local TeamSceneMgrDB = RequireDbBox("TeamSceneMgrDB")
  	TeamSceneMgrDB.OnCreateTeam(team_id)
  	
		return team_id
end
--------------------------------------------------------
--��ɾ��С�ӡ�
function GasTeamBox.DeleteTeam(team_id)
  local team_members = GasTeamBox.GetTeamMembers(team_id)
  local g_LogMgr = RequireDbBox("LogMgrDB")
  for i= 1,#team_members do
  	local member_id = team_members[i][1]
  	g_LogMgr.LeaveTeam(member_id, team_id)
  end
  
  --��ɾ������֮ǰ���ö���󶨵ĳ���
 	local TeamSceneMgrDB = RequireDbBox("TeamSceneMgrDB")
 	local JoinActionDB = RequireDbBox("JoinActionDB")
  local LeaveSceneTbl = TeamSceneMgrDB.OnReleaseTeam(team_id)
  JoinActionDB.OnReleaseTeam(team_id)
  local SceneMgrDB = RequireDbBox("SceneMgrDB")
  SceneMgrDB.OnReleaseTeam(team_id)
  
  --ɾ��С�ӳ�Ա
 	StmtOperater._DeleteAllTeamMembers:ExecStat(team_id)
 	--ɾ��������Ϣ
 	StmtOperater._DeleteArrayBattle:ExecStat(team_id)
 	--ɾ��С�����б����Ϣ
 	StmtOperater._DeleteAllTeamMarks:ExecStat(team_id)
 	--ɾ��С����Ϣ
  StmtOperater._DeleteTeam:ExecStat(team_id)
  if not (g_DbChannelMgr:LastAffectedRowNum()>0)  then
  	CancelTran()
  	return
  end
  StmtOperater._DelStaticTeamID:ExecStat(team_id)
  
  return true, LeaveSceneTbl
end

------------------------------------------------------------
--�����öӳ���
function GasTeamBox.SetCaptain(player_id,team_id)
		StmtOperater._DeleteArrayBattle:ExecSql('',team_id)
  	StmtOperater._UpdateTeamCaptain:ExecSql('', player_id, team_id)
  	if not (g_DbChannelMgr:LastAffectedRowNum()>0)  then
  		CancelTran()
  		return
  	end
  	return true
end
--------------------------------------------------------------
--�����÷��䷽ʽ��
function GasTeamBox.SetAssignMode(team_id, eAM)
	StmtOperater._UpdateAssignMode:ExecSql('', eAM, team_id)
  if not (g_DbChannelMgr:LastAffectedRowNum()>0)  then
  	CancelTran()
  	return
  end
  return true
end

--------------------------------------------------------------
--�����÷��䷽ʽ�е�����Ʒ�ʡ�
function GasTeamBox.SetAuctionStandard(team_id, AuctionStandard)
	StmtOperater._UpdateAuctionStandard:ExecStat(AuctionStandard, team_id)
	if not (g_DbChannelMgr:LastAffectedRowNum()>0) then
		CancelTran()
		return
	end
	return true
end
--�����÷��䷽ʽ�е������׼ۡ�
function GasTeamBox.SetAuctionBasePrice(team_id, AuctionBasePrice)
	StmtOperater._UpdateAuctionBasePrice:ExecStat(AuctionBasePrice, team_id)
	if not (g_DbChannelMgr:LastAffectedRowNum()>0) then
		CancelTran()
		return
	end
	return true
end
--------------------------------------------------------------
--�����С�ӷ��䷽ʽ��
function GasTeamBox.GetAssignMode(team_id)
	local ret = StmtOperater._GetTeamAssignMode:ExecSql('n', team_id)
  	if ret:GetRowNum() == 0  then
  		return
  	end
  	return ret:GetData(0,0)
end

function GasTeamBox.GetAssignAndAuction(team_id)
	local ret = StmtOperater._GetTeamAssignAndAuction:ExecStat(team_id)
  	if ret:GetRowNum() == 0  then
  		return 0,0,0
  	end
  	return ret:GetData(0,0),ret:GetData(0,1),ret:GetData(0,2)
end

--------------------------------------------------------------
--���������ģʽ��Ʒ���趨��
function GasTeamBox.GetAuctionStandard(team_id)
	local ret = StmtOperater._GetTeamAuctionStandard:ExecSql('n', team_id)
  if ret:GetRowNum() == 0  then
  	return
  end
  return ret:GetData(0,0)
end

--���������ģʽ�ĵ׼��趨��
function GasTeamBox.GetAuctionBasePrice(team_id)
	local ret = StmtOperater._GetTeamAuctionBasePrice:ExecStat(team_id)
  if ret:GetRowNum() == 0  then
  	return 0
  end
  return ret:GetData(0,0)
end

-------------------------------------------------------------
--�����ĳС�����г�Ա��
--���ض�ά��
function GasTeamBox.GetTeamMembers(team_id)
  local query_list = StmtOperater._GetTeamMembers:ExecStat(team_id)
  local row = query_list:GetRowNum()
	local res = {}
	for i = 1, row do
		table.insert(res,{query_list(i,1)})
	end
	query_list:Release()
	return res
end

--��ȡĳ�����������������߳�Ա
function GasTeamBox.GetOnlineMembersByServer(team_id,server_id)
	local result = StmtOperater._CountOnlineMembersByServer:ExecStat(team_id,server_id)
	return result:GetData(0,0)
end

-------------------------------------------------------------
--��ͨ��С��id���С�Ӷӳ�id��
function GasTeamBox.GetCaptain(team_id)
  	local query_list = StmtOperater._GetCapationByTeam:ExecStat(team_id )
  	if query_list:GetRowNum() == 0 then
  		query_list:Release()
  		return 0
  	end
  	local cap = query_list:GetData(0,0)
  	query_list:Release()
  	return  cap
end

--��ȡ����������߳�Աid
function GasTeamBox.GetTeamOnlineMembersId(team_id)
	local result = StmtOperater._GetTeamOnlineMembers:ExecStat(team_id)
	local row = result:GetRowNum()
	local onlineMember = {}
	for i=1,row do
		table.insert(onlineMember,result(i,1))
	end
	return onlineMember
end

--������뿪С��ʱɾ������ٸ�С���������������Ϣ��
function GasTeamBox.DeletePlayerIDFromBattleArray(LeaverID, teamId)
	local result_list = StmtOperater._QueryArrayBattleByTeamID:ExecSql("nnnnnn",teamId)
	if result_list:GetRowNum() > 0 then
		for i = 0,result_list:GetRowNum()-1 do
			for j = 1,5 do
				if (result_list:GetData(i,j) == LeaverID) then
					if j == 1 then
						StmtOperater._UpdateArrayBattle:ExecSql("",null,result_list:GetData(i,j+1),result_list:GetData(i,j+2),result_list:GetData(i,j+3),result_list:GetData(i,j+4),result_list:GetData(i,0),teamId)
					elseif j == 2 then
						StmtOperater._UpdateArrayBattle:ExecSql("",result_list:GetData(i,j-1),null,result_list:GetData(i,j+1),result_list:GetData(i,j+2),result_list:GetData(i,j+3),result_list:GetData(i,0),teamId)
					elseif j == 3 then
						StmtOperater._UpdateArrayBattle:ExecSql("",result_list:GetData(i,j-2),result_list:GetData(i,j-1),null,result_list:GetData(i,j+1),result_list:GetData(i,j+2),result_list:GetData(i,0),teamId)
					elseif j == 4 then
						StmtOperater._UpdateArrayBattle:ExecSql("",result_list:GetData(i,j-3),result_list:GetData(i,j-2),result_list:GetData(i,j-1),null,result_list:GetData(i,j+1),result_list:GetData(i,0),teamId)
					elseif j == 5 then
						StmtOperater._UpdateArrayBattle:ExecSql("",result_list:GetData(i,j-4),result_list:GetData(i,j-3),result_list:GetData(i,j-2),result_list:GetData(i,j-1),null,result_list:GetData(i,0),teamId)
					end
					break
				end
			end
		end
	end
end
-----------------------------------------------------------------
--��ת�ƶӳ�(�ӳ��뿪����ʱ����
function GasTeamBox.AutoChangeTeamCapatin(team_id,LeaverID)
	local tblMembers = GasTeamBox.GetTeamMembers(team_id) 
		
	local new_cap = LeaverID
	
	--�������ߵ���
	--����������ߣ�ת�Ƹ�û���ߵ�
	local new_cap = GasTeamBox.GetSomeMemberOnlineByTeamID(team_id,LeaverID)
	if new_cap == LeaverID then
		for i=1, #tblMembers  do
			local PlayerID = tblMembers[i][1]
			if(PlayerID ~= LeaverID) then
				new_cap = PlayerID
				break
			end
		end
	end
	GasTeamBox.SetCaptain(new_cap,team_id)
	return new_cap
end

-------------------------------------------------RPC������ز�������---------------------------------------------------------
--��������ӡ�
function GasTeamBox.InviteTeam(parameters)
 	local uCharID = parameters.uCharID
 	local uTargetID = parameters.uTargetID
 
 	local setting_box = RequireDbBox("GameSettingDB")
 	if setting_box.GetOneSettingInfo(uTargetID,1) ~= 1 then
 		--ϵͳ����Ϊ�������״̬
 		return false, 166
 	end
 	local LoginServerSql = RequireDbBox("LoginServerDB")
	if not LoginServerSql.IsPlayerOnLine(uTargetID) then
		--�Է�������
		return false,110
	end
	local CharacterMediatorDB = RequireDbBox("CharacterMediatorDB")
	if CharacterMediatorDB.GetCamp(uTargetID) ~= CharacterMediatorDB.GetCamp(uCharID) then
		--��Ӫ��ͬ
		return false,112
	end
	
	local char_team_id = GasTeamBox.GetTeamID(uCharID)
	local target_team_id = GasTeamBox.GetTeamID(uTargetID)
	local inviterid,inviteeid = uCharID,uTargetID
	local team_cap,TeamMode = uCharID,DefaultTeamMode
	if char_team_id > 0 and target_team_id > 0 then
		--���˶��Ѿ��������
		return false, 111
		
	elseif  char_team_id > 0 then
		--�������Ѿ��ڶ�����
		local char_team_cap = GasTeamBox.GetCaptain(char_team_id)
		if char_team_cap ~= uCharID then
			--�����߲��Ƕӳ�
			return false, 114
		else
			local members = GasTeamBox.GetTeamMembers(char_team_id)
			if #members >= 5 then
					return false,113
			end
			TeamMode = GasTeamBox.GetAssignAndAuction(char_team_id)
		end
	elseif target_team_id > 0 then
		--���������Ѿ�������顢���������൱��������뱻�����ߵĶ���
		local members = GasTeamBox.GetTeamMembers(target_team_id)
		if #members >= 5 then
			return false,116
		end
		team_cap = GasTeamBox.GetCaptain(target_team_id)
		TeamMode = GasTeamBox.GetAssignMode(target_team_id) or 0
		inviteeid = team_cap
	else
		--�����ߺͱ������߶�û�м������,����һ������
	end
	
	local RevertValidateBox = RequireDbBox("RevertValidateDB")
	if not RevertValidateBox.AddValidateInfo(inviterid,inviteeid,RevertValidateMgr:GetFunIndexByStr("MakeTeam")) then
		return
	end
	return true,team_cap,TeamMode 
end

function GasTeamBox.InviteTeamByName(parameters)
 	local uCharID = parameters.uCharID
 	local uTargetName = parameters.uTargetName
 	local ex = RequireDbBox("Exchanger")
	local uTargetID = ex.getPlayerIdByName(uTargetName)
	if 0 == uTargetID then
		return
	end
	local bFlag,team_cap,assign_mode = GasTeamBox.InviteTeam({["uTargetID"] = uTargetID,["uCharID"] = uCharID})
	return bFlag,team_cap,assign_mode,uTargetID
end

--����Ӧ���롿
function GasTeamBox.RespondInvite(parameters)
 	local uCharID = parameters.uCharID
 	local InviterID = parameters.InviterID
 	local InviterName = parameters.InviterName
 	local bAccept = parameters.bAccept
 	
	local RevertValidateBox = RequireDbBox("RevertValidateDB")
	if not RevertValidateBox.DelValidateInfo(InviterID,uCharID,RevertValidateMgr:GetFunIndexByStr("MakeTeam")) then
		return
	end
	
	local ex = RequireDbBox("Exchanger")
	local char_name = ex.getPlayerNameById(uCharID)
 	if bAccept then
 		local LoginServerSql = RequireDbBox("LoginServerDB")
		if not LoginServerSql.IsPlayerOnLine(InviterID) then
			--�Է�������
			return false,106,InviterName
		end
	else
		local ErrRes = {}
		ErrRes.CharName = char_name
		return true,ErrRes
	end
	
	--�Ȼ��С��id
	local self_team_id = GasTeamBox.GetTeamID(uCharID)
	local target_team_id = GasTeamBox.GetTeamID(InviterID)
	
	if self_team_id > 0  then
		return false,133
	end
	
	local RetData 
	local sFlag 
	if target_team_id > 0 then
		local team_cap = GasTeamBox.GetCaptain(target_team_id)  
		if team_cap ~= InviterID then
			return false,141, InviterName
		end
		local param = {}
		param.uTeamID = target_team_id
		param.uTargetID = uCharID
		RetData = GasTeamBox.AddMember(param)
		sFlag = "AddMember"
	else
		local param = {}
		param.uCharID = InviterID 
		param.uTargetID = uCharID
		RetData = GasTeamBox.CreateTeam(param)
		sFlag = "CreateTeam"
	end
	if not IsTable(RetData) then
		return false,RetData
	end
	local mark_box = RequireDbBox("GasTeamMarkDB")
	local MarkInfo = mark_box.GetAllMarkInfo(TeamID)
	
	RetData.CharName = char_name
	RetData.MarkInfo = MarkInfo
	return sFlag,RetData
end

-----------------------------------------------------------
--����Ӧ���롿
function GasTeamBox.RespondApp(parameters)
 	local uCharID = parameters.uCharID
 	local InviterID = parameters.InviterID
 	local InviterName = parameters.InviterName
 	local bAccept = parameters.bAccept
 	
	local RevertValidateBox = RequireDbBox("RevertValidateDB")
	if not RevertValidateBox.DelValidateInfo(InviterID,uCharID,RevertValidateMgr:GetFunIndexByStr("MakeTeam")) then
		return
	end
	
	local ex = RequireDbBox("Exchanger")
	local char_name = ex.getPlayerNameById(uCharID)
 	if bAccept then
 		local LoginServerSql = RequireDbBox("LoginServerDB")
		if not LoginServerSql.IsPlayerOnLine(InviterID) then
			--�Է�������
			return false,135
		end
	else
		local ErrRes = {}
		ErrRes.CharName = char_name
		return true,ErrRes
	end
	
	local TeamID = GasTeamBox.GetTeamID(uCharID)
	if TeamID == 0 then return end
	
	if GasTeamBox.GetTeamID(InviterID) > 0 then
		--�Է��Ѿ������˶���
		return false,134,InviterName
	end
	
	local param = {}
	param.uTeamID = TeamID
	param.uTargetID = InviterID
	local RetData = GasTeamBox.AddMember(param)
	
	if not IsTable(RetData) then
		return false,RetData
	end
	local mark_box = RequireDbBox("GasTeamMarkDB")
	local MarkInfo = mark_box.GetAllMarkInfo(TeamID)
	
	RetData.CharName = char_name
	RetData.MarkInfo = MarkInfo

	return "AddMember",RetData
end
------------------------------------------------------------

--���������顿
function GasTeamBox.CreateTeam(parameters)
	local uCharID = parameters.uCharID
	local uTargetID = parameters.uTargetID
	
	--�жϴ�������������Ƿ������Ѿ������˶���
	if GasTeamBox.GetTeamID(uCharID) ~= 0 or 0 ~= GasTeamBox.GetTeamID(uTargetID) then
		return 
	end
	
	--�����ݿ������һ��С��
	local TeamID = GasTeamBox.AddTeam(uCharID,DefaultTeamMode)
	if TeamID == 0 then return end

	--�����ݿ��еĴ�С����ӳ�Ա
	GasTeamBox.AddMembers(uCharID,TeamID)
	GasTeamBox.AddMembers(uTargetID,TeamID)
	
	GasTeamBox.SetAuctionStandard(TeamID,DefaultStandard)
	
	local data = {}
	data.eAM = DefaultTeamMode
	data.AuctionStandard = DefaultStandard
	data.AuctionBasePrice = DefaultBasePrice
	data.uTeamID = TeamID
	return data
end

------------------------------------------------------------

--����ɢ���顿
function GasTeamBox.BreakTeam(parameters)
	local uCharID = parameters.uCharID
	local uTeamID = GasTeamBox.GetTeamID(uCharID)
	if uTeamID == 0 then return end

	local captain = GasTeamBox.GetCaptain(uTeamID)
  if uCharID ~= captain then return end
 
  local team_members = GasTeamBox.GetTeamMembers(uTeamID)
  --ɾ��С�Ӽ����Ա
  local res, LeaveSceneTbl = GasTeamBox.DeleteTeam(uTeamID)
  if not res then return end
 
  local data = {}
  data.m_TeamCap = captain
  data.m_tblTeamMeb = team_members
  data.m_nTeamID = uTeamID
  data.LeaveSceneTbl = LeaveSceneTbl
  return data
end

----------------------------------------------------------

--�����ӳ�Ա��
function GasTeamBox.AddMember(parameters)
	local uTeamID = parameters.uTeamID
	local uTargetID = parameters.uTargetID
	if uTeamID == 0 then 
		return 
	end
	local team_members = GasTeamBox.GetTeamMembers(uTeamID)
	
	if #team_members == 0 then
		--��С�Ӳ�����
		return 
	elseif #team_members >= 5 then
		--��������
		return 113
	end
	
	local team_id = GasTeamBox.GetTeamID(uTargetID)
	if team_id ~= 0 then return end

	if not GasTeamBox.AddMembers(uTargetID,uTeamID) then
		return 
	end
	
	--���䷽ʽ���
	local eAM,AuctionStandard,AuctionBasePrice = GasTeamBox.GetAssignAndAuction(uTeamID)
	local team_members2 = GasTeamBox.GetTeamMembers(uTeamID)
	
	local team_cap = GasTeamBox.GetCaptain(uTeamID)
	local data = {}
	data.eAM = eAM
	data.AuctionStandard = AuctionStandard
	data.AuctionBasePrice = AuctionBasePrice
	data.team_members = team_members2
	data.team_cap = team_cap
	data.uTeamID = uTeamID
	return data
end

--------------------------------------------------------

--���뿪���顿
function GasTeamBox.LeaveTeam(parameters)
	local LeaverID = parameters.LeaverID
	local team_id = GasTeamBox.GetTeamID(LeaverID)
	if team_id == 0 then return end

	local uNewCap = 0
	--ɾ��������Ϣ
	GasTeamBox.DeletePlayerIDFromBattleArray(LeaverID,team_id)
	
  local LeaveSceneTbl = {}
  local res,IsLeaveScene = GasTeamBox.DeleteMembers(LeaverID,team_id)
  if not res then return end

   --����С��2�Զ���ɢ
  local tblMembers = GasTeamBox.GetTeamMembers(team_id)
  if #tblMembers < 2 then
    	local res, LeaveTbl = GasTeamBox.DeleteTeam(team_id)
		  if not res then return end
		  LeaveSceneTbl = LeaveTbl
  else
  		--�ӳ��뿪
  		local captain = GasTeamBox.GetCaptain(team_id)
  		if LeaverID == captain then
	  		uNewCap = GasTeamBox.AutoChangeTeamCapatin(team_id,LeaverID)
			end
	end
 	
 	if IsLeaveScene then
		table.insert(LeaveSceneTbl,{LeaverID,IsLeaveScene})
	end
	
	local data = {}
	data.m_nNewTeamCap  = uNewCap
	data.m_tblTeamMem = tblMembers
	data.m_nTeamID = team_id
	data.LeaveSceneTbl = LeaveSceneTbl
	return data
end
------------------------------------------------------------
--���޳���Ա��
function GasTeamBox.RemoveTeamMember(parameters)
	local LeaverID = parameters.LeaverID
	local uPlayerID = parameters.uPlayerID
		
	local uTeamID = GasTeamBox.GetTeamID(uPlayerID)
	local captain = GasTeamBox.GetCaptain(uTeamID)
  if uPlayerID ~= captain then return end
 
  if GasTeamBox.GetTeamID(LeaverID) ~= uTeamID then return end
	
	--ɾ��������Ϣ
	GasTeamBox.DeletePlayerIDFromBattleArray(LeaverID,uTeamID)
	
  local LeaveSceneTbl = {}
  local res,IsLeaveScene = GasTeamBox.DeleteMembers(LeaverID, uTeamID)
  if not res then return end
 
   --����С��2 ���Զ���ɢ
  local tblMembers = GasTeamBox.GetTeamMembers(uTeamID)
  if #tblMembers < 2 then
    	local res, LeaveTbl = GasTeamBox.DeleteTeam(uTeamID)
		  if not res then return end
		  LeaveSceneTbl = LeaveTbl
   end
   
	if IsLeaveScene then
		table.insert(LeaveSceneTbl,{LeaverID,IsLeaveScene})
	end
	
  local ex = RequireDbBox("Exchanger")
	local leaver_name = ex.getPlayerNameById(LeaverID)
	local data = {}
	data.m_TeamCap = captain
	data.m_tblTeamMem = tblMembers
	data.m_nTeamID = uTeamID
	data.m_LeaverName = leaver_name
	data.LeaveSceneTbl = LeaveSceneTbl	
  return data
end

------------------------------------------------------

--�����öӳ���
function GasTeamBox.SetCaptainRPC(parameters)
	local uTargetID = parameters.uTargetID
	local uPlayerID = parameters.uPlayerID
	local uTeamID = GasTeamBox.GetTeamID(uPlayerID)
	local team_members = GasTeamBox.GetTeamMembers(uTeamID)
	if GasTeamBox.GetCaptain(uTeamID) ~= uPlayerID then
		--˵�����öӳ�����Ŀǰ���Ƕӳ� ��û��Ȩ��
		return false
	end
	local LoginServerSql = RequireDbBox("LoginServerDB")
	if not LoginServerSql.IsPlayerOnLine(uTargetID) then
		--�Է�������
		return false,110
	end
	
	--���öӳ�
	if not GasTeamBox.SetCaptain(uTargetID,uTeamID) then 
		return 
	end
	local ex = RequireDbBox("Exchanger")
	local cap_name = ex.getPlayerNameById(uTargetID)
	local res = {}
	res.m_tblTeamMem = team_members
	res.m_nTeamCap = cap_name
	res.m_TeamID = uTeamID
	return true,res
end

--------------------------------------------------

--�����÷��䷽ʽ��
function GasTeamBox.SetAssignModeRPC(parameters)
	local eAM = parameters.eAM
	local uPlayerID = parameters.uPlayerID
	local uTeamID = GasTeamBox.GetTeamID(uPlayerID)
	if GasTeamBox.GetCaptain(uTeamID) ~= uPlayerID then
		--˵�����Ƕӳ� ��û��Ȩ��
		return 1
	end
	if not GasTeamBox.SetAssignMode(uTeamID,eAM) then
		return 0
	end
	local team_members = GasTeamBox.GetTeamMembers(uTeamID)
	return 2,team_members,uTeamID
end

--�����С�����г�Ա��
function GasTeamBox.GetTeamMembersByChar(parameters)
	local uPlayerID = parameters.uPlayerID
	local uTeamID = GasTeamBox.GetTeamID(uPlayerID)
	local tblRes = {}
	tblRes.uTeamID = uTeamID
	if uTeamID == 0 then
		return tblRes
	end
	local team_mates = GasTeamBox.GetTeamMembersInfo(uTeamID)
	
	--�ӳ�
	local captain = GasTeamBox.GetCaptain(uTeamID)
	local CharacterMediatorDB = RequireDbBox("CharacterMediatorDB")
	local PlayerLevel = CharacterMediatorDB.GetPlayerLevel(uPlayerID)
	tblRes.team_mates = team_mates
	tblRes.captain = captain
	tblRes.PlayerLevel = PlayerLevel
	return tblRes
end

function GasTeamBox.GetTeamCapAndMem(parameters)
	local TeamID = parameters.TeamID
	local server_id = parameters.server_id
	local Members = GasTeamBox.GetTeamMembers(TeamID)
	local captain = GasTeamBox.GetCaptain(TeamID)
	local online_membs = GasTeamBox.GetOnlineMembersByServer(TeamID,server_id)
	local data = {}
	data.m_AllMembers = Members
	data.m_TeamCap = captain
	data.m_OnlineMem = online_membs
	data.m_TeamID = TeamID
	return data
end

function GasTeamBox.GetPlayerLevelAndTeamID(parameters)
	local uPlayerID  = parameters.m_uPlayerID
	local uTeamID = GasTeamBox.GetTeamID(uPlayerID)
	local CharacterMediatorDB = RequireDbBox("CharacterMediatorDB")
	local PlayerLevel = CharacterMediatorDB.GetPlayerLevel(uPlayerID)
	return PlayerLevel,uTeamID
end
--------------------------------------------------
--�����䷽ʽ������ģʽ������Ʒ���趨��
function GasTeamBox.SetAuctionStandardRPC(parameters)
	local uPlayerID = parameters.uPlayerID
	local AuctionStandard = parameters.AuctionStandard
	
	local uTeamID = GasTeamBox.GetTeamID(uPlayerID)
	if GasTeamBox.GetCaptain(uTeamID) ~= uPlayerID then
		return 
	end
	if not GasTeamBox.SetAuctionStandard(uTeamID,AuctionStandard) then
		return 
	end
	local members = GasTeamBox.GetTeamMembers(uTeamID)
	return members,uTeamID
end

--�����䷽ʽ������ģʽ�������׼��趨��
function GasTeamBox.SetAuctionBasePriceRPC(parameters)
	local uPlayerID = parameters.uPlayerID
	local AuctionBasePrice = parameters.AuctionBasePrice
	
	local uTeamID = GasTeamBox.GetTeamID(uPlayerID)
	if GasTeamBox.GetCaptain(uTeamID) ~= uPlayerID then
		return 
	end
	if not GasTeamBox.SetAuctionBasePrice(uTeamID,AuctionBasePrice) then
		return
	end
	local members = GasTeamBox.GetTeamMembers(uTeamID)
	return members,uTeamID
end

--��ɾ����ɫʱ��С���Ŷ���Ϣ�Ĵ���
function GasTeamBox.DealWithTeamInfoWhenDelChar(uCharID)
	local uTeamID = GasTeamBox.GetTeamID(uCharID)
	if uTeamID == 0 then
		return {}
	end
	local parameters = {}
	parameters.LeaverID	= uCharID
	parameters.uTeamID		= uTeamID
	local LeaveData = GasTeamBox.LeaveTeam(parameters)
	
	local tblRetData = {}
	tblRetData.m_nTeamID = uTeamID
	tblRetData.m_tblTeamMembers = LeaveData.m_tblTeamMem
	return tblRetData
end

SetDbLocalFuncType(GasTeamBox.GetTeamMembersByChar)
SetDbLocalFuncType(GasTeamBox.GetPlayerLevelAndTeamID)
--���رհ�
return GasTeamBox