engine_require "common/Misc/TypeCheck"

gac_gas_require "framework/text_filter_mgr/TextFilterMgr"

-- ȷ���û����Ƿ�Ϸ�
function CheckUserName(sUserName)
		local textFilter = CTextFilterMgr:new()
		local strUserName = textFilter:RemoveTab1(sUserName)
		if not IsString(strUserName) then
			return false,29   --"�Ƿ��ַ���"
		end
		if(string.len(sUserName)<6 or string.len(sUserName)>31) then
			return false,30   --"�û����ĳ��ȱ�����6~31֮��"
		end			
		if string.find(sUserName, "[ ]") then
           return false, 31 --"�û����������пո�" 
        end
		if(string.find(sUserName, "[^%w.@_-]")) then
			return false,32  --"�û���ֻ�ܰ�����ĸ�����֣�����»��ߣ�"
		end
		if(string.find(sUserName, "^[%d%a]") == nil ) then
			return false,33 -- "�û�����������ĸ�������ֿ�ͷ"
		end
		return true
end