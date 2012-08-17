local StmtContainer = class()
local event_type_tbl = event_type_tbl
local AreaFbPointDB = CreateDbBox(...)

local TongProfferPoint = 10 --�Ź�����

-- �������򸱱�������Ϣ
local StmtDef=
{
	"_InsertCharAreaFBPoint",
	[[
		insert into tbl_area_fb_point (cs_uId,afp_uPointType) values (?,?)
	]]
}
DefineSql(StmtDef, StmtContainer)

local StmtDef=
{
	"_AddFBPointByType",
	[[
		update tbl_area_fb_point set afp_uPoint = afp_uPoint + ? where cs_uId = ? and afp_uPointType = ? and afp_uPoint + ? >= 0
	]]
}
DefineSql(StmtDef, StmtContainer)

local StmtDef=
{
	"_CountPointLimit",
	[[
		select  count(*) from tbl_jifen_use_limit where jul_uType = ?
	]]
}
DefineSql(StmtDef, StmtContainer)

function AreaFbPointDB.InsertPoint(uCharId)
	if uCharId then
		for i = 1, 9 do
			StmtContainer._InsertCharAreaFBPoint:ExecStat(uCharId,i)
		end
	end
end

function AreaFbPointDB.InsertPointByType(uCharId, Type)
	StmtContainer._InsertCharAreaFBPoint:ExecStat(uCharId,Type)
end

function AreaFbPointDB.CountPointLimit(PointType)
	local res = StmtContainer._CountPointLimit:ExecSql("n",PointType)
	return res:GetNumber(0,0)
end
-------------------------------------------------------------------------------------
local StmtDef = {
	"_SelectFbPoint",
	[[ select afp_uPoint from tbl_area_fb_point where cs_uId = ? and afp_uPointType = ? ]]
}
DefineSql(StmtDef, StmtContainer)
-------------------------------------------------------------------------------------
local StmtDef = {
	"_GetPlayerCurLevel",
	[[
		select cb_uLevel from tbl_char_basic where cs_uId = ?
	]]
}
DefineSql(StmtDef,StmtContainer)

--@brief �������id�ͻ��������޸���һ���
function AreaFbPointDB.AddAreaFbPointByType(uCharId,Point,PointType,SceneName,uEventId,modifyType)
	assert(uCharId) 
	assert(Point)
	assert(PointType)
	local logPoint = 0
	if Point < 0 then
		if not (PointType == 7 and modifyType == event_type_tbl["Pk״̬��ɱ��������"]) then
			local ItemBagLockDB = RequireDbBox("ItemBagLockDB")
			--����ʻ��Ƿ�����
			if ItemBagLockDB.HaveItemBagLock(uCharId) then
				return false,160028
			end
		end
	end
  
	if AreaFbPointDB.CountPointLimit(PointType) > 0 then
		return false,20
	end
	
	if PointType == TongProfferPoint then
	    local CTongBasicBox  = RequireDbBox("GasTongBasicDB")
        local para = {["uPlayerID"] = uCharId, ["nAddProffer"] = Point}
        
	    local suc = CTongBasicBox.AddProffer(para)
	    if suc ~= true then
            error("�Ź������޸�ʧ��,�޸��Ź�����ʧ��,���id��".. uCharId .. ",�޸ĵĻ���ֵ��" .. Point)
      end	 
      if Point < 0 then
      	--npc�̵����Ķ����Ź����Ӷ�������
      	local tong_id = CTongBasicBox.GetTongID(uCharId)
      	if tong_id > 0 then
      		local bFlag,uMsgID = CTongBasicBox.UpdateHonor({["uTongID"] = tong_id,["uHonor"] = -Point, ["nEventType"] = event_type_tbl["�����̵깺����Ʒ"]})   
					if not bFlag then
						return bFlag,uMsgID
					end
				end
			end
	else
		logPoint = AreaFbPointDB.GetPointStatement(uCharId,PointType)
		StmtContainer._AddFBPointByType:ExecStat(Point,uCharId,PointType,Point)
		if g_DbChannelMgr:LastAffectedRowNum() <= 0 then
			error("�޸Ļ���ʧ��,���id��" .. uCharId .. ",Ҫ�޸ĵĻ������ͣ�" .. PointType .. ",�޸ĵ�ֵ�ǣ�"  .. Point..",ԭ�л���ֵ:"..logPoint)
		end
	end
	local uTotalPoint = AreaFbPointDB.GetPointStatement(uCharId,PointType)
	local level_res = StmtContainer._GetPlayerCurLevel:ExecStat(uCharId)
	local LogMgr = RequireDbBox("LogMgrDB")
	local succ = LogMgr.SaveJiFenPointInfo(uCharId,Point,PointType,SceneName,uTotalPoint,uEventId,modifyType,level_res:GetData(0,0))
	if not succ then
		error("��¼�޸Ļ���logʧ��")
	end
	return true
end

--@brief �������id�ͻ������Ͳ����
function AreaFbPointDB.GetPointStatement(uCharId,PointType)
	local all_point = 0
	if TongProfferPoint == PointType then --�Ź�����
        local CTongBasicBox  = RequireDbBox("GasTongBasicDB")
        local para = {["uPlayerID"] = uCharId}
        all_point = CTongBasicBox.GetProffer(para) 
    else
        local result = StmtContainer._SelectFbPoint:ExecStat(uCharId, PointType)
    	if result:GetRowNum() > 0 then
    		all_point = result:GetData(0,0)
    	end
	end
	return all_point
end

return AreaFbPointDB