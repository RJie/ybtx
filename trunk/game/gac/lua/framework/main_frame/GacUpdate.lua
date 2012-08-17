gac_require "e_protocol/HttpDownload"


--�ͻ��˽��յ��������˴������ȸ��´��롢�ļ���
function Gas2Gac:SendMsgToGac(Conn, gacId, filename, code)

	gac_id = gacId
	local tbl_gac_required_file = package["loaded"]
	if tbl_gac_required_file[filename] ~= nil then
		LoadCode(filename, code)
	else
		if tbl_update_code[filename] ~= nil then
			table.insert(tbl_update_code[filename], code)
		else
			tbl_update_code[filename] = {}
			table.insert(tbl_update_code[filename], code)
		end
	end
	
end

--�ͻ����յ���������������Ϣ���ͷ���gac_id������ˣ�����ѯ����gac_id���ȸ��¼�¼
function Gas2Gac:NotifyGacReply(Conn)
	Gac2Gas:SendIdToGas(g_Conn, gac_id)
end

--[[�����������ȸ���patch�����ļ����£���ʱ����
--�����ȸ���patch
function GacUpdatePatch()
	local filename = "patchlist.log"

	local http = HttpDownload:new()
	host = "10.10.43.191"
	port = "80"
	url = "http://10.10.43.191/patch_list.php"
	params = {}
	
	local function callback(msg)
		tbl_patch_list = GetPatchList()
		DownAllPatch(tbl_patch_list)	
		
	end
	http:SendData(host, port, url, params, callback, filename)
end

function DownAllPatch(tbl_patch_list)
	co = coroutine.create(
	function()
		for k,v in pairs(tbl_patch_list) do
			DownPatch(v)
			coroutine.yield()
			if k == table.getn(tbl_patch_list) then
				dealpackage()
			end
		end
	end)
	coroutine.resume(co)
end

function DownPatch(version)
	print("download " .. version .. "...")
	local filename = "../../download/" .. version .. ".pkg"
	
	local http = HttpDownload:new()
	host = "10.10.43.191"
	port = "80"
	url = "http://10.10.43.191/patchs/" .. version .. ".pkg" 
	params = {}
	
	local function callback(ret)
		msg = "Down " .. version .. ".pkg over"
		print(msg)
		coroutine.resume(co)
	end
	http:SendData(host, port, url, params, callback, filename)
end



--��ȡ�������汾�ţ��ݶ���svn�汾��
function GetPatchList()
	local tbl_patch_list = {}
	--���ļ�
	local filename = g_RootPath .. "var/gac/patchlist.log"
	local fp = CLuaIO_Open(filename, "r")
	if fp ~= nil then
		local line = fp:ReadLine()
		while line do
			local b,e = string.find(line, "%w+\.pkg")
			if b then
				local patch = string.sub(line, b, b+5)
				table.insert(tbl_patch_list, 1, patch)
			end
			line = fp:ReadLine()
		end
		fp:Close()
	end

	local version_client = GetVersion()
	local version_patch
	local flag = 0
	for k,v in pairs(tbl_patch_list) do
		version_patch = tonumber(v)
		if version_patch <= version_client then
			flag = k
		end
	end
	
	for i=1,flag do
		table.remove(tbl_patch_list, 1)
	end
	
	for k,v in pairs(tbl_patch_list) do
		print(k,v)
	end
	
	return tbl_patch_list
end

--����pkg�ļ�
function dealpackage()
	print("down all over and begin unpack")
	do_file("666666", "a.lua")
end

--�����pkg�µ�file�ļ�������dofile������ļ�
function do_file(pkg, file)
	local b,e = string.find(g_RootPath, ":")
	if b then
		local disk = string.sub(g_RootPath, b-1, b)
		local path = string.sub(g_RootPath, e+2)
		local cd_disk = disk .. "&& cd\\\ "  --������Ϸ�����̵ĸ�Ŀ¼
		local cd_path = "&& cd " .. path .. "download && "  --����downloadĿ¼
		local extractpkg = g_RootPath .. "bin/Release/ExtractPackage.exe " .. pkg .."/" .. file
		local cmd = cd_disk .. cd_path .. extractpkg
		print(cmd)
		os.execute(cd_disk .. cd_path .. extractpkg)	
		dofile(g_RootPath .. "download/" .. file)
	end
end

--�ͻ�������ʱ���и���
function UpdateWhenGacStart()
	--print("�ͻ�������ʱ�Զ�ȥ�����µĲ�����")
	GacUpdatePatch()
end

--��ȡ��ǰ�ͻ��˰汾
function GetVersion()
	--��ǰ��svn�汾��
	--return GetCurrentRevision()
	return 555555
	
	--�������ţ���0.4.22.2��
	--return 0.4.22.2 
end
--]]

