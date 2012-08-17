local StmtOperater = {}
local event_type_tbl = event_type_tbl

local CTongForageBox = CreateDbBox(...)

----------------------------------------sql���---------------------------------------------------------------------
--����������������Ϣ��
local StmtDef = 
{
	"_AddForageNum",
	"insert into tbl_tong_draw_forage(tdf_uId,tdf_uTotal) values(?,?)"
}
DefineSql(StmtDef, StmtOperater)

local StmtDef = 
{
	"_AddForageTempNum",
	"insert into tbl_tong_draw_forage_temp(tdft_uId,tdft_uTotal) values(?,?)"
}
DefineSql(StmtDef, StmtOperater)

local StmtDef = 
{
	"_AddDrawForageTime",
	"insert into tbl_tong_draw_forage_time(tdft_dtTime) values(DATE_FORMAT(now(),'%Y%m%d'))"
}
DefineSql(StmtDef, StmtOperater)

local StmtDef = 
{
	"_GetDrawForagTime",
	"select unix_timestamp(tdft_dtTime) from tbl_tong_draw_forage_time"
}
DefineSql(StmtDef, StmtOperater)

local StmtDef = 
{
	"_UpdateDrawForagTime",
	"update tbl_tong_draw_forage_time set tdft_dtTime = DATE_FORMAT(now(),'%Y%m%d')"
}
DefineSql(StmtDef, StmtOperater)



local StmtDef = 
{
	"_UpdateSpecDrawForagTime",
	"update tbl_tong_draw_forage_time set tdft_dtTime = from_unixtime(?)"
}
DefineSql(StmtDef, StmtOperater)

--���õ���ȡ������Ϣ��
local StmtDef = 
{
	"_GetForageInfo",
	"select tdf_uTotal from tbl_tong_draw_forage where tdf_uId = ?"
}
DefineSql(StmtDef, StmtOperater)


local StmtDef = 
{
	"_GetForageTempInfo",
	"select tdft_uTotal from tbl_tong_draw_forage_temp where tdft_uId = ?"
}
DefineSql(StmtDef, StmtOperater)


--���õ���ȡ������Ϣ��
local StmtDef = 
{
	"_GetAllForageInfo",
	"select tdf_uTotal, tdf_uId from  tbl_tong_draw_forage"
}
DefineSql(StmtDef, StmtOperater)

local StmtDef = 
{
	"_GetAllForageNum",
	"select tdf_uTotal from  tbl_tong_draw_forage"
}
DefineSql(StmtDef, StmtOperater)

--������������Ϣ��
local StmtDef = 
{
	"_UpdateForageInfo",
	"update tbl_tong_draw_forage set	tdf_uTotal	=	?	where	tdf_uId	=	?"
}
DefineSql(StmtDef,StmtOperater)

--������������������Ϣ��
local StmtDef = 
{
	"_UpdateAllForageInfo",
	"update tbl_tong_draw_forage set	tdf_uTotal	=	tdf_uTotal + ?"
}
DefineSql(StmtDef,StmtOperater)

--�����´���350������Ϣ��
local StmtDef = 
{
	"_UpdateAllForageNum",
	"update tbl_tong_draw_forage set tdf_uTotal	=	? where tdf_uTotal >=	350 "
}
DefineSql(StmtDef,StmtOperater)

--��ɾ��������Ϣ��
local StmtDef = 
{
	"_DeleteForageInfo",
	"delete from tbl_tong_draw_forage where tdf_uId	=	?"
}
DefineSql(StmtDef, StmtOperater)

local StmtDef = 
{
	"_DeleteForageTempInfo",
	"delete from tbl_tong_draw_forage_temp where tdft_uId	=	?"
}
DefineSql(StmtDef, StmtOperater)

local StmtDef = 
{
	"_SetForageNumUpLimit",
	"update tbl_tong_draw_forage set	tdf_uTotal =	350  where tdf_uTotal >= 300"
}
DefineSql(StmtDef, StmtOperater)

local StmtDef = 
{
	"_SetForageNumDownLimit",
	"update tbl_tong_draw_forage set	tdf_uTotal =	tdf_uTotal + 50  where tdf_uTotal + 50 <= 350"
}
DefineSql(StmtDef, StmtOperater)



--------------------------------------------���ݿ���ز���--------------------------------------------------------------
local function GetParam(param)
	local FirstDate = 
	{
		year = os.date("%Y", param + 600),
		month = os.date("%m", param + 600),
		day = os.date("%d", param + 600),
		hour = 0,
		min = 0,
		sec = 0
	}
	return FirstDate
end

--��������ȡ���������Ϣ��
function CTongForageBox.AddForageNum(data)
	local charId = data["charId"]
	local CharacterMediatorDB = RequireDbBox("CharacterMediatorDB")
	local result = StmtOperater._GetForageInfo:ExecStat(charId)
	local forage = 0
	if result:GetRowNum() == 0 then
		StmtOperater._AddForageNum:ExecStat(charId, 50)
		forage = 50
	end
	return true, forage
end


--��������ȡ���������Ϣ��
function CTongForageBox.GetDrawForagTime(data)
	local result = StmtOperater._GetDrawForagTime:ExecStat()
	if result:GetRowNum() > 0 then
		local ostime = os.time()
		local StartDate1 = {
			year = os.date("%Y", ostime ),
			month = os.date("%m", ostime ),
			day = os.date("%d", ostime ),
			hour = 0,
			min = 0,
			sec = 0
		}
		
		local tempTime = os.time(StartDate1) - result:GetData(0, 0)
		local MisValue = tempTime/(60*60*24)

		if MisValue > 0 then
			local forageNum = MisValue * 50
			StmtOperater._UpdateAllForageInfo:ExecStat(forageNum)
			StmtOperater._UpdateAllForageNum:ExecStat(350)
			StmtOperater._UpdateDrawForagTime:ExecStat()
			return
		else
			return 
		end
	end
	StmtOperater._AddDrawForageTime:ExecStat()
end


--���޸���ȡ���������Ϣ��
function CTongForageBox.UpdateForageInfo(data)
	local charId = data["charId"]
	local forageNum = data["forageNum"]
	StmtOperater._UpdateForageInfo:ExecStat(forageNum,charId)
	if g_DbChannelMgr:LastAffectedRowNum() <= 0 then
		--CancelTran()
		return false
	end
	return true
end


--���޸���ȡ���������Ϣ��ɾ����Ʒ��
function CTongForageBox.UpdateForageInfoAndDel(data)
	local charId = data["nCharID"]
	local forageNum = 0
	local g_RoomMgr		= RequireDbBox("GasRoomMgrDB")	
	local uHaveCount = g_RoomMgr.GetItemCount(charId, 1,"����ѫ��")
	local res 
	local result = StmtOperater._GetForageInfo:ExecStat(charId)
	if result:GetRowNum() <= 0 then
		return 
	end
	
	forageNum = result:GetData(0,0) + uHaveCount * 10
	if forageNum >= 350 then
		forageNum = 350
		local num = (350 - result:GetData(0,0)) / 10
		if num > 0 then
			res = g_RoomMgr.DelItem(charId, 1, "����ѫ��", num, nil, event_type_tbl["��Ʒʹ��"])
		end
	else
		res = g_RoomMgr.DelItem(charId, 1, "����ѫ��", uHaveCount, nil, event_type_tbl["��Ʒʹ��"])
	end
	StmtOperater._UpdateForageInfo:ExecStat(forageNum,charId)
	return true,res,forageNum
end

--�������ȡ���ݵ������Ϣ��
function CTongForageBox.GetForageInfo(data)
	local charId = data["charId"]
	local result = StmtOperater._GetForageInfo:ExecStat(charId)
	local num = result:GetRowNum()
	local forageNum = 0
	if num > 0 then
		forageNum = result:GetData(0,0)
	end
	return forageNum
end

--�������ȡ���ݵ������Ϣ��
function CTongForageBox.GetRestForageInfo(data)
	local CLogMgrDB = RequireDbBox("LogMgrDB")
	local charId = data["charId"]
	local FetchNum = data["FetchNum"]  
	local resForage = 0
	local result = StmtOperater._GetForageInfo:ExecStat(charId)
	if result:GetRowNum() > 0 then
		local forageNum = result:GetData(0,0)
		if forageNum < FetchNum then
			FetchNum = forageNum
			resForage = 0
		else
			resForage = forageNum - FetchNum
		end
		CLogMgrDB.SavePlayerDrawResourceInfoLog(charId,FetchNum)
		StmtOperater._UpdateForageInfo:ExecStat(resForage,charId)
	end
	return true, FetchNum
end

--��ɾ����ȡ���ݵ������Ϣ��
function CTongForageBox.DeleteForageInfo(data)
	local charId = data["charId"]
	StmtOperater._DeleteForageInfo:ExecStat(charId)
	if g_DbChannelMgr:LastAffectedRowNum() <= 0 then
		CancelTran()
		return false
	end
end

--��ÿ����¿���ȡ������Ϣ��
function CTongForageBox.GetAllForageInfo(data)
	local resTime = StmtOperater._GetDrawForagTime:ExecStat()
	local ostime = os.time() 
	local timeNum = resTime:GetRowNum()
	if timeNum >= 0 then
		if timeNum == 0 then  --û�м�
			StmtOperater._AddDrawForageTime:ExecStat()
		else
			local tempdata = resTime:GetData(0,0)
			local firstDate = GetParam(ostime)
			if os.time(firstDate) == tempdata then
				return 
			end
			local newTime = os.date("%d",ostime + 600)  
			local time = os.date("%d",ostime)
			if newTime ~= time then
				local StartDate1 = GetParam(ostime)
				StmtOperater._UpdateSpecDrawForagTime:ExecStat(os.time(StartDate1))
			else
				StmtOperater._UpdateDrawForagTime:ExecStat()
			end
		end
	end
	StmtOperater._SetForageNumUpLimit:ExecStat()
	StmtOperater._SetForageNumDownLimit:ExecStat()
end

function CTongForageBox.AddForageTempInfo(data)
	local playerId = data["charId"]
	local result = StmtOperater._GetForageInfo:ExecStat(playerId)
	if result:GetRowNum() > 0 then
		local forage = result:GetData(0,0)
		StmtOperater._DeleteForageInfo:ExecStat(playerId)
		StmtOperater._AddForageTempNum:ExecStat(playerId, forage)
		if g_DbChannelMgr:LastAffectedRowNum() < 0 then
			CancelTran()
			return
		end
	end
end

SetDbLocalFuncType(CTongForageBox.GetRestForageInfo)
SetDbLocalFuncType(CTongForageBox.UpdateForageInfo)
SetDbLocalFuncType(CTongForageBox.UpdateForageInfoAndDel)
SetDbLocalFuncType(CTongForageBox.GetForageInfo)

return CTongForageBox

