gac_gas_require "framework/text_filter_mgr/TextFilterMgr"

local CTextFilterMgr = CTextFilterMgr

local CTongBasicBox = CreateDbBox(...)
---------------------------------------------------------------------------------------------------------
--Ӷ����Ⱥ��
function CTongBasicBox.GroupChatRequest(data)
	local playerId = data["playerId"]
	local message = data["text"]
	local tong_box = RequireDbBox("GasTongBasicDB")
	local tong_id = tong_box.GetTongID(playerId)	 
	if tong_id == 0 then
		return 
	end
	
	local textFltMgr = CTextFilterMgr:new()
	--ȥ��ǰ��ո�
	message = textFltMgr:RemoveTab1(message)
	--�á�**���滻���в��Ϸ��ַ�
	message = textFltMgr:ReplaceInvalidChar(message)
	if string.len(message) == 0 then
		return
	end
	
	local tong_box = RequireDbBox("GasTongBasicDB")
	local members = tong_box.GetTongMemberInfo(tong_id)
	return members
end
---------------------------------------------------------------------------------------------------------
return CTongBasicBox