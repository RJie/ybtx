gas_require "relation/RevertValidateMgrInc"
function RevertValidateMgr:Ctor()
	self.m_tblRevertFun = 
		{
			["MakeTeam"] = 1, --���
			["RecommendJoinTong"] = 2, --����������
			["InviteJoinTong"] = 3, --���������
			["AddFriend"] = 4, --�����Ϊ����
		}
end

function RevertValidateMgr:GetFunIndexByStr(sFunStr)
	return self.m_tblRevertFun[sFunStr]
end