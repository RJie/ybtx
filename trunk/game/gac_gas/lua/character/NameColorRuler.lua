gac_gas_require "character/NameColorDef"
gac_gas_require "character/NameColorRulerInc"

--[[
	ECharNameColor.eCNC_Blue			= 1
	ECharNameColor.eCNC_Red			= 2
	ECharNameColor.eCNC_Purple		= 3
	ECharNameColor.eCNC_Green		= 4
]]

-- AChar �� SeeByThisChar ��������ʲô��ɫ
function CNameColorRuler:GetColorSeeBy( AChar, SeeByThisChar )

-- PK �����ɫ
	if( AChar.IsRedName and AChar:IsRedName()  ) then
		return ECharNameColor.eCNC_Red 
	end
	
-- PVP �����ɫ
--[[
	if ( g_PVPMgr:IsInPVPCase( AChar ) ) then
		-- �Ƿ�ͬ��Ӫ
		if( g_PVPMgr:SameRegime( AChar,  SeeByThisChar ) ) then
			return ECharNameColor.eCNC_Green
		else
			return ECharNameColor.eCNC_Purple
		end	
	end
]]	

-- Default: ���������: Ĭ��ֵ ��ɫ
	return ECharNameColor.eCNC_Blue
end