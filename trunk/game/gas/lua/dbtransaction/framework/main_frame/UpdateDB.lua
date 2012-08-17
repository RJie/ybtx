
local loadstring = loadstring
local pcall = pcall
local tostring = tostring
local GetCurrentRevision = GetCurrentRevision

function GetGlobalId()
	return db_id
end
local GetGlobalId = GetGlobalId

function UpdateForDb(tbl_db, dbId)
	--�ֲ�tbl_db���Ҫ�ȸ��µ�filename��code��������ļ������룬��������룬Ȼ��ӱ���ɾ����ʣ�µļ�Ϊ��û������ļ����ȸ�������
	db_id = dbId
	local tbl_db_required_file = package["loaded"]

	for k,v in pairs(tbl_db) do
		if tbl_db_required_file[k] ~= nil then
			for _,code in pairs(v) do
				LoadCode(k, code)
			end
			tbl_db[k] = nil
		end
	end

	--����δ������ȸ������ݼ���ȫ�ֱ�tbl_update_code��������RequireFile��ʱ����бȽϺͲ鿴
	for k,v in pairs(tbl_db) do
		if tbl_update_code[k] ~= nil then
			for _,code in pairs(v) do
				table.insert(tbl_update_code[k], code)
			end
		else
			tbl_update_code[k] = tbl_db[k]
		end
	end
		
end
local UpdateForDb = UpdateForDb

local UpdateDB = CreateDbBox(...)
local StmtOperater = {}	


local StmtDef = {
    "_GetHotUpdateGas",
    [[
        select hug_id, hug_filename, hug_code from tbl_hot_update_gas where hug_revision=? and hug_id > ? order by hug_id asc; 
    ]]
}   
DefineSql(StmtDef,StmtOperater)

local StmtDef = {
    "_GetHotUpdateGac",
    [[
        select hug_id, hug_filename, hug_code from tbl_hot_update_gac where hug_revision=? and hug_id > ? order by hug_id asc; 
    ]]
}   
DefineSql(StmtDef,StmtOperater)

local StmtDef = {
    "_GetHotUpdateDb",
    [[
        select hud_id, hud_filename, hud_code from tbl_hot_update_db where hud_revision=? and hud_id > ? order by hud_id asc; 
    ]]
}   
DefineSql(StmtDef,StmtOperater)

--��ѯ���ݿ��е�db�ȸ���
function UpdateDB.GetHotUpdateDb(data)

	local revision = GetCurrentRevision()
	local dbId = GetGlobalId()
	local tbl_db  = StmtOperater._GetHotUpdateDb:ExecSql("", revision, dbId)
	local tbl_file_code_db = {}
	
	local row = tbl_db:GetRowNum()
	if row > 0 then
		dbId = tbl_db:GetData(row-1, 0)
	end
	for i=0,row-1 do
		local filename = tbl_db:GetData(i, 1)
		local code     = tbl_db:GetData(i, 2)
		if tbl_file_code_db[filename] ~= nil then
			table.insert(tbl_file_code_db[filename], code)
		else
			tbl_file_code_db[filename] = {}
			table.insert(tbl_file_code_db[filename], code)
		end
	end
		
	--��db�߳��ȸ���
	UpdateForDb(tbl_file_code_db, dbId)	

end

--��ѯ���ݿ��е�gas/gac�ȸ���
function UpdateDB.GetHotUpdateGasGac(data)
	local revision = GetCurrentRevision()
	local gasId = data["gas_id"]
	local gacId = data["gac_id"]
 	local tbl_gas = StmtOperater._GetHotUpdateGas:ExecSql("", revision, gasId)
 	local tbl_gac = StmtOperater._GetHotUpdateGac:ExecSql("", revision, gacId)
	local tbl_file_code_gas = {}
	local tbl_file_code_gac = {}

	local row = tbl_gas:GetRowNum()
	if row > 0 then
		gasId = tbl_gas:GetData(row-1, 0)
	end
	for i=0,row-1 do
		local filename = tbl_gas:GetData(i, 1)
		local code     = tbl_gas:GetData(i, 2)

		if tbl_file_code_gas[filename] ~= nil then
			table.insert(tbl_file_code_gas[filename], code)
		else
			tbl_file_code_gas[filename] = {}
			table.insert(tbl_file_code_gas[filename], code)
		end
	end

	local row = tbl_gac:GetRowNum()
	if row > 0 then
		gacId = tbl_gac:GetData(row-1, 0)
	end

	for i=0,row-1 do
		local id       = tbl_gac:GetData(i, 0)
		local filename = tbl_gac:GetData(i, 1)
		local code     = tbl_gac:GetData(i, 2)

		tbl_file_code_gac[id] = {filename, code}
		--tbl_file_code_gac = {1={filename1,code1}, 2={filename2,code2}...}
	end
	

	return tbl_file_code_gas, tbl_file_code_gac, gasId, gacId
end


return UpdateDB
