gac_gas_require "relation/army_corps/ArmyCorpsMgrInc"

function CArmyCorpsMgr:Ctor()
	self:Init()
end

function CArmyCorpsMgr:Init()
	self.m_nRegistLevel = 40			--ע��Ӷ������Ҫ�ȼ�
	self.m_nRegistMoney = 200000	--Ӷ���Ŵ�����Ҫ�ʽ�
	self.m_uAssistantColonelCountLimit = 8 --Ӷ���Ÿ��ų���������
	self.m_uInitTeamCountLimit = 8	--Ӷ����С�ӳ�ʼ��������
	
	self.m_tblPosInfo =
		{
			["�ų�"]		= 1,
			["���ų�"]	= 2,
			["��Ա"]		=	3,
		}
end

function CArmyCorpsMgr:GetRegistLevel()
	return self.m_nRegistLevel 
end

function CArmyCorpsMgr:GetRegistMoney()
	return self.m_nRegistMoney 
end

function CArmyCorpsMgr:GetAssistantColonelCountLimit()
	return self.m_uAssistantColonelCountLimit
end

function CArmyCorpsMgr:GetTongCountLimit(uLevel)
	return self.m_uInitTeamCountLimit
end

function CArmyCorpsMgr:GetPosIndexByName(sPosName)
	return self.m_tblPosInfo[sPosName]
end

function CArmyCorpsMgr:JudgePurview(pos_index,purview_name)
	if purview_name == "UpdatePurpose" or purview_name == "InviteJoin" or purview_name == "KickOut" then
		return pos_index == 1 or pos_index == 2
	end
	if purview_name == "ChangePosition" or purview_name =="UpdateArmyCorpsName" then
		return pos_index == 1
	end
	return false
end


g_ArmyCorpsMgr = g_ArmyCorpsMgr or CArmyCorpsMgr:new()
----------------------
