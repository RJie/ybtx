
--����дRequierFile�������������ļ���Ȼ���жϸ��ļ��Ƿ���й��ȸ��£����У������ȸ��´��롣
local _RequireFile = RequireFile
function RequireFile(...)
	local arg = {...}
	local filename = arg[2]
	local tbl_required_file = package["loaded"]
	
	--��������ļ�ǰ�жϸ��ļ��Ƿ��Ѿ�����
	local InTable = 0   --0:���ļ�δ�����; 1:���ļ��Ѿ�����
	if tbl_required_file[filename] ~= nil then
		InTable = 1
	end
	local result = _RequireFile(arg[1], arg[2])
	
	--δ���룬���ȸ��±��в��Ҽ�¼���и���
	if InTable == 0 then
		CheckFileFromTable(filename)
	end
	return result
end

tbl_update_code = {} --��¼gas/db/gac�ȸ��µ��ļ���Ӧ�Ĵ��룬{ ["filename1"] = {code1, code2, ...}, ......}
tbl_gac_update = {}  --��¼����gac���ȸ��¼�¼,{1={file,code}, 2={file,code}...}
gas_id = 0
gac_id = 0
db_id = 0
function CheckFileFromTable(filename)
	--�ж�filename�Ƿ���tbl�У��ǵĻ�����filename����Ӧ��code������ʲô������

	if tbl_update_code[filename] ~= nil then
		--print("����" .. filename  .. "ʱ�����и���")
		for _, code in pairs(tbl_update_code[filename]) do
			LoadCode(filename, code)
		end
		tbl_update_code[filename] = nil
	end
end

function LoadCode(filename, code)
	assert(type(code) == "string")	
	local loadfun = loadstring( code )
	local result
	if pcall(loadfun) then
			result = "�ɹ���"
	else
			result = "ʧ�ܣ���鿴�ȸ��´��룡"
	end
	
	local MD5Digester = CMd5Digester:new()
	MD5Digester:Begin()
	MD5Digester:Append(code, string.len(code))
	local CODE_MD5 = CreateCBufAcr( CreateCBuf(33) )
	MD5Digester:GetMD5Base16Str(CODE_MD5)
	local code_md5 = CODE_MD5:ToString()
	
	local data = {}
	data["filename"] = filename
	data["code"] = code_md5
	data["result"] = result
	local function gas()
		data["type"] = 1
		CallDbTrans("GMToolsDbActionDB", "AddHotUpdateResult", nil, data)
	end
	local function db()
		local GMWebToolsDB = RequireDbBox("GMToolsDbActionDB")
		data["type"] = 2
		GMWebToolsDB.AddHotUpdateResult(data)
	end
	local function gac()
		local type = 3
		Gac2Gas:SendHotUpdateMsg(g_Conn, type, filename, code_md5, result)
	end
	if pcall(gas) then
		print("���Ƿ���˵ĸ���")
	elseif pcall(db) then
		print("���ǵ����߼��ĸ���")
	elseif pcall(gac) then
		print("���ǿͻ��˵ĸ���")
	end
	
end	

