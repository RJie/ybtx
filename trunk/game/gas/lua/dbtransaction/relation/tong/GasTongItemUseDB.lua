local event_type_tbl = event_type_tbl
local StmtOperater = {}

local CTongItemUse = CreateDbBox(...)


----------------------------------------sql���---------------------------------------------------------------------
--�����Ӿ���,��Դ����������Ϣ��
local StmtDef = 
{
	"_GetOnlineTongMember",
	
	[[select mt.cs_uId
		from tbl_member_tong as mt, tbl_char_online as co, tbl_char_basic as cb
		where t_uId = ? and mt.cs_uId = co.cs_uId and co.cs_uId = cb.cs_uId and
		mt.cs_uId <> ? order by cb.cb_uLevel desc 
		limit ?]]
}
DefineSql(StmtDef, StmtOperater)


function CTongItemUse.GetOnlineTongMember(data)
	local g_RoomMgr = RequireDbBox("GasRoomMgrDB")  
	local sceneMgr = RequireDbBox("SceneMgrDB")
	local info = data["info"]
	local tongId = data["tongId"]
	local charId = data["charId"]
	local sceneId = data["sceneId"]
	local num = data["num"]
	local haveCount = g_RoomMgr.GetCountByPosition(charId, info[1]["nRoomIndex"], info[1]["nPos"])
	if haveCount < 0 then
		return false
	end
	local DelRet = g_RoomMgr.DelItemByPos(charId, info[1]["nRoomIndex"], info[1]["nPos"],1,event_type_tbl["��Ʒʹ��"])
	if IsNumber(DelRet) then
		return false
	end
	local result = StmtOperater._GetOnlineTongMember:ExecStat(tongId, charId, num)
	local serverId = sceneMgr.GetSceneServerPos(sceneId)
	return result, serverId
end

return CTongItemUse