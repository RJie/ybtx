gac_gas_require "relation/cofc/CofcTechnologyMgrInc"
--cfg_load "cofc/CofcTechnology_Common"

--�������ƺ͵ȼ���ÿƼ���Ϣ
function CCofcTechnologyMgr:GetTechnologyInfo(nIndex)
	return CofcTechnology_Common(nIndex)
end

function CCofcTechnologyMgr:GetTechnologyInfoAll()
	return CofcTechnology_Common
end