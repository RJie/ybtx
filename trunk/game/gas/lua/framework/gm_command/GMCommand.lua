gas_require "framework/gm_command/GMCommandInc"
gas_require "framework/gm_command/GMCommandList"

local TextFilterMgr = CTextFilterMgr:new()

-- ͨ�� Command ���ظ������ ����������ִ���� �� ��������
function GMCommand:_GetVarsDefFromCommand( strCommand )
	strCommand = ( strCommand or "___" )
	if ( GMCommand.GMCommandList[ strCommand ] ~= nil ) then
		return unpack( GMCommand.GMCommandList[ strCommand ] )
	end
	return nil
end

function GMCommand:_Available(strCmd)

	if("" == strCmd) then
		return false, "Wrong GM Command"
	end
	
	local tbl = {}
	SplitString(strCmd, "%(", tbl)
	
	if( 2 > #tbl ) then
		return false, "Wrong GM command"
	end
	
	local strCommand = string.lower( TextFilterMgr:RemoveTab1(tbl[1]) )
	strCmd = string.gsub(tbl[2], "%)", "")
	local strVarDefs, funcExecutor = GMCommand:_GetVarsDefFromCommand(strCommand)
	
	if(not strVarDefs) then
		return false, "This GM Command isn`t be registered"
	end
	
	local tVarTable = {}
	SplitString(strCmd, ",", tVarTable)
	for i = 1, string.len(strVarDefs) do
		if(not tVarTable[i]) then
			return false, "Can`t get parameter " .. i
		end
		tVarTable[i] = TextFilterMgr:RemoveTab1(tVarTable[i])
		if( "i" == string.sub(strVarDefs, i, i) ) then
			tVarTable[i] = tonumber(tVarTable[i])
			if(not tVarTable[i]) then 
				return false, "The type of parameter " .. i .. " is wrong"
			end
		elseif( "s" == string.sub(strVarDefs, i, i) ) then
			tVarTable[i] = string.gsub(tVarTable[i], "\"", "")
		else
			return false, "A wrong registration of parameter"
		end
	end
	return true, strErrorMsg, strCommand, tVarTable, funcExecutor
end

-- ���鵱ǰ�û�(Connection)�Ƿ���Ȩ��ʹ�ø� "ָ���ı���" ָ���� GMָ��
function GMCommand:_Validate( Connection, strCommand,nUseLevel )
	-- ���� ��Connection�ĵ�ǰCommand �Ƿ�Ϸ� : �����֤
	if "runscript" == strCommand then
		return true
	end
	local _, _,nCommendLevel = GMCommand:_GetVarsDefFromCommand( strCommand )
	if GasConfig.GMValidate == 1 then
		if nUseLevel == nil then
			return false
		end
		if nUseLevel < (nCommendLevel or 1) then
			return false
		end
	end
	return true
end

-- �ô� "ָ���ı���" �л�õĲ������ø�GMָ���ִ����
function GMCommand:_Execute( Pipe, funcExecutor, tVarTable )
	local rte, ret = pcall( funcExecutor, Pipe, unpack( tVarTable ) )
	if ( rte ) then
		if( ret and type ( ret ) == "string" ) then
			return ret.."^^T"
		else
			return "Done^^T"
		end
	else
		if( ret and type ( ret ) == "string" ) then
			return "e^^"..ret
		else
			return "e^^Running-time error"
		end
	end
end

function GMCommand:_RunScript( Pipe, strScript )
	if( Remote and Remote._RunScript ) then
		local strRet =  Remote._RunScript( Pipe, strScript )
		return strRet
	else
		return "e^^server isn`t open the RunScript function"
	end
end

function GMCommand:print( Pipe, strReturnString )
	local strRS;
	if( strReturnString == nil ) then 
		strRS = "Done with no return value"
	else 
		strRS = tostring( strReturnString )
	end
	
	if( Pipe) then
		Gas2Gac:Remote_ReceiveResult( Pipe, strRS.."^^T" )
	end
end