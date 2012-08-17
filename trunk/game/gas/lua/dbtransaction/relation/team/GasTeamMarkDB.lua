

local StmtOperater = {}		--������sql����table
--�հ���ʼ
local TeamMarkBox = CreateDbBox(...)

--------------------------------------SQL���--------------------------------------------

--�����ĳС�ӵ����б����Ϣ��
local StmtDef = {
    	"_GetAllTeamMarkInfoByTeamID",
    	[[ 
    		select 	mt_uMarkType, mt_uTargetType, mt_uTargetID 	from 	tbl_mark_team 	where 	t_uId = ? 
    	]]
}    
DefineSql ( StmtDef, StmtOperater )

--��ͳ��ͬһ��С�ӵ�ͬһ���ʹ��������
--������С��id���������
local StmtDef = {
    	"_CountByMarkType",
    	[[ 
    		select count(*) from tbl_mark_team where t_uId = ? and mt_uMarkType = ?
    	]]
}    
DefineSql ( StmtDef, StmtOperater )

--������С��id�ͱ�ǵ������޸ı����Ϣ��
local StmtDef = {
    	"_UpdateMarkInfoByMarkType",
    	[[ 
    		update 	tbl_mark_team 
    		set 		mt_uTargetType = ?, mt_uTargetID = ?
    		where 	t_uId = ? and mt_uMarkType = ?
    	]]
}    
DefineSql ( StmtDef, StmtOperater )

--��ͳ��ͬһ��С�Ӹ�ĳ�����ǵĴ�����
local StmtDef = {
    	"_CountByTarget",
    	[[ 
    		select count(*) from tbl_mark_team where t_uId = ? and mt_uTargetType = ? and mt_uTargetID = ?
    	]]
}    
DefineSql ( StmtDef, StmtOperater )

--������С��id�ͱ�ǵ������޸ı����Ϣ��
local StmtDef = {
    	"_UpdateMarkInfoByTargetInfo",
    	[[ 
    		update 	tbl_mark_team 
    		set 		mt_uMarkType = ?
    		where 	t_uId = ? and  mt_uTargetType = ? and mt_uTargetID = ?
    	]]
}    
DefineSql ( StmtDef, StmtOperater )

--����ӱ����Ϣ��
local StmtDef = {
    	"_AddMarkInfo",
    	[[ 
    		replace into  tbl_mark_team(t_uId, mt_uMarkType, mt_uTargetType, mt_uTargetID) values(?, ?, ?, ?)
    	]]
}    
DefineSql ( StmtDef, StmtOperater )

--��ɾ�������Ϣ��
local StmtDef = {
    	"_DelMarkInfoByChar",
    	[[ 
    		delete from tbl_mark_team where mt_uTargetID = ? and mt_uTargetType = ? and t_uId = ?
    	]]
}    
DefineSql ( StmtDef, StmtOperater )
--------------------------------------���ݿ�������----------------------------------------------------

--�����ĳС�ӵ����б����Ϣ��
function TeamMarkBox.GetAllMarkInfo(uTeamID)
	local query_list = StmtOperater._GetAllTeamMarkInfoByTeamID:ExecStat(uTeamID)
	
	return query_list
end

--����ӱ����Ϣ��
function TeamMarkBox.UpdateMarkInfo(uTeamID, uMarkType, uTargetType, uTargetID)
	if 0 == uMarkType then
		StmtOperater._DelMarkInfoByChar:ExecStat(uTargetID,uTargetType,uTeamID)
		return true
	end
	local tblMarkCount = StmtOperater._CountByMarkType:ExecStat(uTeamID, uMarkType)
	local tblTargetCount = StmtOperater._CountByTarget:ExecStat(uTeamID, uTargetType, uTargetID)
	
	if tblMarkCount:GetNumber(0,0) > 0 then
		--˵����С�ӵĴ˱���Ѿ�����
		if tblTargetCount:GetNumber(0,0) == 0 then
			--˵����С�ӻ�û���ڸö������������
			StmtOperater._UpdateMarkInfoByMarkType:ExecStat(uTargetType, uTargetID, uTeamID, uMarkType)
		end
	elseif tblTargetCount:GetNumber(0,0) > 0 then
		--˵����С���Ѿ����˶������˱�ǣ�ֱ���޸Ĵ˶���ı������
		StmtOperater._UpdateMarkInfoByTargetInfo:ExecStat(uMarkType, uTeamID, uTargetType, uTargetID)
	else
		--��С��û���ù��˱���Ҵ�С��û���ڸö����ϱ�ǹ�ʱ��ֱ��add�����Ϣ
		StmtOperater._AddMarkInfo:ExecStat( uTeamID, uMarkType, uTargetType, uTargetID)
	end
	return true
end

--------------------------------RPC���------------------------------------------------------

--��С�ӱ�ǡ�
function TeamMarkBox.UpdateTeamMark(parameters)
	local uPlayerID = parameters.uPlayerID
	local uMarkType = parameters.uMarkType
	local uTargetType = parameters.uTargetType
	local uTargetID = parameters.uTargetID
	
	local team_box = RequireDbBox("GasTeamDB")
	local uTeamID = team_box.GetTeamID(uPlayerID)
	
	if team_box.GetCaptain(uTeamID) ~= uPlayerID then
		--˵�����Ƕӳ� ��û��Ȩ��
		return 
	end
	
	--��ӱ����Ϣ
	if not TeamMarkBox.UpdateMarkInfo(uTeamID, uMarkType, uTargetType, uTargetID) then
		return 
	end
	--�������С�ӳ�Ա
	local members = team_box.GetTeamMembers(uTeamID)
	
	return members
	
end

--���رհ�
return TeamMarkBox

