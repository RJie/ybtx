gac_gas_require "framework/text_filter_mgr/TextFilterMgrInc"
engine_require "common/Loader/loader"
lan_load "message/Lan_NameFilter_Common"
lan_load "message/Lan_MsgFilter_Common"
gac_gas_require "framework/common/CMoney"
lan_load "tong/Lan_TongResPos_Common"
lan_load "tong/Lan_TongFightTech_Common"
lan_load "skill/Lan_BuffName"

local string_find = StringFindBaseOnUTF8	
--�ж�����������,��Щ���Ʋ�����ʹ��(��ΰ������:ë��)
function CTextFilterMgr:IsValidName(sName)
--	if( self:FindFirstSBCOnUTF8(sName) >= 0 ) then
--		return false
--	end
	local Keys = Lan_NameFilter_Common:GetKeys()
	for i,p in pairs (Keys) do
		if(string_find(sName, Lan_NameFilter_Common(p,"Filter"),  0) ~= -1) then
			return false
		end
	end
	return true
end
--�ж���Ϣ������,���β��Ϸ���Ϣ(���໰)
function CTextFilterMgr:IsValidMsg(sMsg)
	local Keys = Lan_MsgFilter_Common:GetKeys()
	for i,p in pairs (Keys) do
		if(string_find(sMsg, Lan_MsgFilter_Common(p,"Filter"), 0) ~= -1) then
			return false
		end
	end
	return true
end

--ȥ���ַ����е�ǰ��ո�[��һ�ַ���]
function CTextFilterMgr:RemoveTab1(sMsg)
	local message = ""
	--ȥ���ַ���ǰ��Ŀո��Ʊ���ͻس���
	for i=1, string.len(sMsg) do
		local chari = string.sub(sMsg,i,i)
		if( chari ~= " " and chari ~= "\n" and chari ~= "\t" ) then
			message = string.sub(sMsg,i,-1)
			break
		end
		--��������һ�����ǿգ��򷵻ؿ��ַ���
		if i == string.len(sMsg) then
			return message
		end
	end
	--ȥ���ַ�������Ŀո��Ʊ���ͻس���
	for i=1, string.len(message) do
		local chari = string.sub(message, string.len(message) - i +1, string.len(message) - i +1)
		if( chari ~= " " and chari ~= "\n" and chari ~= "\t" ) then
			message = string.sub(message,1, string.len(message) - i +1)
			break
		end
	end
	return message
end

--ȥ���ַ����е�ǰ��ո�[�ڶ��ַ���]
function CTextFilterMgr:RemoveTab2(sMsg)
	--ȥ��ǰ��Ŀ�ֵ
	local trim_begin = string.gsub(sMsg, "^%s+", "")
	--ȥ������Ŀո�
	local trim_end = string.gsub(sMsg, "%s+$", "")
	--ȥ��ǰ�����еĿո�
	return string.gsub(trim_end,"^%s+", "")
end


--���ַ����еĲ��Ϸ��ַ��滻�ɡ�****��
function CTextFilterMgr:ReplaceInvalidChar(sMsg)
	local message = sMsg
	--һ�α����������滻���ַ��������в��Ϸ����ַ�
	local Keys = Lan_MsgFilter_Common:GetKeys()
	for i ,p in pairs(Keys) do
		if(string_find(sMsg,Lan_MsgFilter_Common(p,"Filter"), 0) ~= -1) then
			message = string.gsub(message, Lan_MsgFilter_Common(p,"Filter"),"*")
		end
	end
	return message
end

function CTextFilterMgr:FindFirstSBCOnUTF8(str)
	return find_sbc_on_utf8(str)
end


--������ɫʱ����ɫ���ؼ���ɸѡ����
function CTextFilterMgr:CheckRoleName(strRoleName)
	local textFilter = CTextFilterMgr:new()
	if not IsString(strRoleName) then
		return false,28    --�Ƿ���ɫ��
	end
	
	if string.find(strRoleName, "[#\\/' \"]") then
		return false, 32   --��ɫ��ֻ�ܺ������ġ�Ӣ�ĺ�����
	end
	
	if string.find(strRoleName, "", 1, true) then
		return false, 32
	end
	
	if GetCharCount(strRoleName) < 6 or GetCharCount(strRoleName) >16 then
        return false, 24 
	end 

	return true
end

function CTextFilterMgr:GetStringByMsg(sStr)
	local sMsg = ""
		local nIndex = string.find(sStr,"_")
		if IsNumber(nIndex) and nIndex > 0 then
			local MsgID = tonumber(string.sub(sStr, 1,nIndex-1))
			local len = string.len(sStr)
			local str_tbl = string.sub(sStr, nIndex + 1,len)
			if str_tbl then
				local str = loadstring("return {" .. str_tbl .. "}")()
				sMsg = GetLogClient(MsgID,unpack(str))
			end
		else
			sStr = tonumber(sStr)
			if IsNumber(sStr) then
				sMsg = GetLogClient(sStr)
			end
		end
		return sMsg
end

--����˴����ͻ��˵�messageid���ͻ��˶�����Ӧ����Ϣ��ʾ
function CTextFilterMgr:GetRealStringByMessageID(sStr,strType)
	if strType == 0 then
		return self:GetStringByMsg(sStr)
	end
	local sMsg = ""
	local nIndex = string.find(sStr,"_")
	if nIndex and nIndex > 0 then
		local MsgID = tonumber(string.sub(sStr, 1,nIndex-1))
		local len = string.len(sStr)
		local str_tbl = string.sub(sStr, nIndex + 1,len)
		local tbl_msg = {}
		if str_tbl then
			SplitString(str_tbl, "%,", tbl_msg)
			for i =1,#tbl_msg do
				local msgi = tbl_msg[i]
				if string.find(msgi,"item:") then
					local item_type = tonumber(string.sub(msgi,string.find(msgi,":")+1,string.find(msgi,"|")-1))
					local item_name = string.sub(msgi,string.find(msgi,"|")+1,string.len(msgi))
					local display_name = g_ItemInfoMgr:GetItemLanInfo(item_type,item_name,"DisplayName")
					tbl_msg[i] = display_name
				elseif string.find(msgi,"money:") then
					local money_type = tonumber(string.sub(msgi,string.find(msgi,":")+1,string.find(msgi,"|")-1))
					local money_count = tonumber(string.sub(msgi,string.find(msgi,"|")+1,string.len(msgi)))
					local g_MoneyMgr = CMoney:new()
					if money_type == 1 then
						tbl_msg[i] = g_MoneyMgr:ChangeMoneyToString(money_count,EGoldType.GoldCoin)
					else
						tbl_msg[i] = g_MoneyMgr:ChangeMoneyToString(money_count,EGoldType.GoldBar)
					end
				elseif string.find(msgi,"msgid:") then
					local msgid = tonumber(string.sub(msgi,string.find(msgi,":")+1,string.len(msgi)))
					tbl_msg[i] = GetLogClient(msgid)
				elseif string.find(msgi,"objname:") then
					local obj_name = string.sub(msgi,string.find(msgi,":")+1,string.len(msgi))
					tbl_msg[i] = Lan_TongResPos_Common(MemH64(obj_name), "ShowName")
				elseif string.find(msgi,"techname:") then
					local tech_name = string.sub(msgi,string.find(msgi,":")+1,string.len(msgi))
					tbl_msg[i] = Lan_TongFightTech_Common(MemH64(tech_name), "DisplayName")
				elseif string.find(msgi,"fuli:") then
					local buffName = string.sub(msgi,string.find(msgi,":")+1,string.len(msgi))
					tbl_msg[i] = Lan_BuffName(MemH64(buffName),"DisplayName")
				end
			end
			sMsg = GetLogClient(MsgID,unpack(tbl_msg))
		end
	else
		sMsg = tonumber(sStr) and GetLogClient(tonumber(sStr)) or sStr
	end
	return sMsg
end