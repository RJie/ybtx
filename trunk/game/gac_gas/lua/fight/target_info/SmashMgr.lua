gac_gas_require "fight/target_info/SmashMgrInc"
cfg_load "image_res/SmashImage_Common"

function CSmashInfoMgr:Ctor()
	self.m_tblAttackTypeString = {
		[EAttackType.eATT_Puncture]		= "����",
		[EAttackType.eATT_Chop]			= "����",
		[EAttackType.eATT_BluntTrauma]	= "����",
		[EAttackType.eATT_Nature]		= "��Ȼ��",
		[EAttackType.eATT_Destroy]		= "�ƻ���",
		[EAttackType.eATT_Evil]			= "���ڿ�"	} --������ַ���Ҫ��SmashImage_Common������ͬ
end

function CSmashInfoMgr:GetSmashImage(uAttackType, fSmashRate)
	local sAttackType = self.m_tblAttackTypeString[uAttackType]
	local tblAttackType = SmashImage_Common(sAttackType)
	for i, v in ipairs( tblAttackType:GetKeys() ) do
		if(fSmashRate > tblAttackType(v, "LowerLimit") and fSmashRate <= tblAttackType(v, "UpperLimit")) then
			return tblAttackType(v, "ImagePathEnable"), v
		end
	end
end

