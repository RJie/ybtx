gac_gas_require "activity/npc/LifeOriginCommonInc"

g_LifeOrigin = CLifeOriginCommon:new()

function CLifeOriginCommon:AddSinglePointBornTbl(key, tbl)
	g_NpcBornMgr:AddSinglePointBornTbl(key, tbl)
end

---- ���� NPC ��̬���ã������༭�����ɵ�lua�ļ��� 
--function CLifeOriginCommon:LoadNpcDynamicSetting(file)
--	if file == "" then
--		print("�ø���û������NPC")
--	else
--		 
--	end
--end