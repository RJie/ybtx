gac_require "test/common/CTstPlayerInfoMgrInc"

--����
function CTstPlayerInfoMgr:GetPoisonDefence()
	return g_PlayerInfos[g_MainPlayer:GetEntityID()].m_PoisonDefence - self.m_DefaultInfo.m_PoisonDefence
end
--����
function CTstPlayerInfoMgr:GetFireDefence()
	return g_PlayerInfos[g_MainPlayer:GetEntityID()].m_FireDefence - self.m_DefaultInfo.m_FireDefence
end
--����
function CTstPlayerInfoMgr:GetIceDefence()
	return g_PlayerInfos[g_MainPlayer:GetEntityID()].m_IceDefence - self.m_DefaultInfo.m_IceDefence
end
--�׿�
function CTstPlayerInfoMgr:GetThunderDefence()
	return g_PlayerInfos[g_MainPlayer:GetEntityID()].m_ThunderDefence - self.m_DefaultInfo.m_ThunderDefence
end

--����	
function CTstPlayerInfoMgr:GetAddAgility()
	return g_PlayerInfos[g_MainPlayer:GetEntityID()].m_Agility - self.m_DefaultInfo.m_Agility
end
--����
function CTstPlayerInfoMgr:GetAddIntellect()
	return g_PlayerInfos[g_MainPlayer:GetEntityID()].m_Intellect - self.m_DefaultInfo.m_Intellect
end
--����
function CTstPlayerInfoMgr:GetAddSpirit()
	return g_PlayerInfos[g_MainPlayer:GetEntityID()].m_Spirit - self.m_DefaultInfo.m_Spirit
end
--����
function CTstPlayerInfoMgr:GetAddStamina()
	return g_PlayerInfos[g_MainPlayer:GetEntityID()].m_Stamina - self.m_DefaultInfo.m_Stamina
end
--����
function CTstPlayerInfoMgr:GetAddStrength()
	return g_PlayerInfos[g_MainPlayer:GetEntityID()].m_Strength - self.m_DefaultInfo.m_Strength
end
--����
function CTstPlayerInfoMgr:GetAddShield()
	return g_PlayerInfos[g_MainPlayer:GetEntityID()].m_Shield - self.m_DefaultInfo.m_Shield
end

function CTstPlayerInfoMgr:GetNewInfo()
	return g_PlayerInfos[g_MainPlayer:GetEntityID()]
end

function CTstPlayerInfoMgr:GetDefaultInfo()
	return self.m_DefaultInfo
end
--��������˱Ƚ϶��ĵ���ƣ���Ϊ��Ҫ�ж����������ߺ�����������Ƿ���ȷ
--�����µ����ݶ�ͨ��ʵʱ��g_MainPlayer:GetEntityID()����ã���
--�ϴε�¼������id����ε�����id��һ�������ɵ�����һֱ������self.m_DefaultInfo��
--ͨ����ֵ���ж��������������Ϊ����Ļ������Կ��ܲ߻���һֱ������ͨ��װ����õ�����
--��ֻ���ò�ֵ�ķ�ʽ��
function CTstPlayerInfoMgr:Ctor()
	self.m_DefaultInfo = g_PlayerInfos[g_MainPlayer:GetEntityID()]
end