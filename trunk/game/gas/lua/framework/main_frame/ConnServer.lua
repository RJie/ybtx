
--��connection�ṩ����account��user name�ĺ���
local _SetConnValue = CConnServer.SetValue
local _GetConnValue = CConnServer.GetValue

function CConnServer:SetRoleName(roleName)
	_SetConnValue(self, "RoleName", roleName)
end

function CConnServer:GetRoleName()
	return _GetConnValue(self, "RoleName");
end

function CConnServer:SetUserName(userName)
	_SetConnValue(self, "UserName", userName)
end

function CConnServer:GetUserName()
	return _GetConnValue(self, "UserName")
end
