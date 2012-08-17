local function _ReloadFile(file_name,func)
	local szLowerFile = string.lower( file_name )
	local i,j = string.find( szLowerFile,"%w*inc$" )
	if i ~= nil then
		print("Reload file include \"inc\". ")
		return false
	end
	
	package.loaded[file_name] = nil
		
	local ret, msg = pcall(func, file_name)
	if not ret then
		print(msg)
	end
	return ret
end

function ReloadFile(file_name)
	local ext_pos = string.find(file_name, ".lua", 1, true)
	if not ext_pos then
		print(file_name .. "����lua�ļ�����������")
		return
	end

	local name = string.sub(file_name, 1, ext_pos - 1)

	--�������һ��lua�ļ�����Ϊ������Щlua����һ��������ģ����Բ�������
	--����������Ҫ���ж��Ƿ������vm���汻������
	local loaded = package.loaded
	for k, v in pairs(loaded) do
		local pos = string.find(name, k)
		if pos then
			local sub_name = string.sub(name, pos)
			if sub_name == k then
					_ReloadFile(sub_name, require)
					return
			end
		end
	end
	
	
	--����������ڣ���ô���ǲ���Ҫ��������ļ�����Ϊ����ļ���������һ��lua�������
end
