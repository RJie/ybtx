gac_gas_require "relation/tong/TongTechnologyMgrInc"
cfg_load "tong/TongFightTech_Common"
lan_load "tong/Lan_TongFightTech_Common"
function CTongTechnologyMgr:Ctor()
	--�ȴ������еĿƼ�״̬
	self.m_tblTechStat = {
		["Normal"]		= 0,	--����
		["Waiting"]		= 1,	--�Ŷ���
		["Researching"]	= 2,	--�з���
		["Stay"]		= 3		--��ͣ
	}
	
	self.m_nMaxTeachLevel = 160		--�Ƽ���ߵȼ�
end

function CTongTechnologyMgr:GetStateIndex(sState)
	return self.m_tblTechStat[sState]
end

--�ȴ����е��������
function CTongTechnologyMgr:GetMaxOrder(nTongLevel)
	return nTongLevel
end

--��ȡ���ñ�������----------------------------------------------------------------
function CTongTechnologyMgr:HasFightTechInfo(sName, nLevel)
	return TongFightTech_Common:HasNode( sName, tostring(nLevel) )
end

--���������б�
function CTongTechnologyMgr:GetFightTechNames()
	return TongFightTech_Common:GetKeys()
end

--ս���Ƽ�ͼ��
function CTongTechnologyMgr:GetFightTechSmallIcon(sName, nLevel)
	assert( TongFightTech_Common:HasNode(sName, tostring(nLevel)), "TongFightTech_Common��û��Name:" .. sName .. " Level:" .. nLevel)
	return TongFightTech_Common(sName, tostring(nLevel), "SmallIcon")
end

--��Ҫ��Ӷ���ŵȼ�
function CTongTechnologyMgr:GetFightTechNeedTongLevel(sName, nLevel)
	assert( TongFightTech_Common:HasNode(sName, tostring(nLevel)), "TongFightTech_Common��û��Name:" .. sName .. " Level:" .. nLevel)
	return TongFightTech_Common(sName, tostring(nLevel), "NeedTongLevel")
end

--��Ҫ��Ӷ����פ������ս��
function CTongTechnologyMgr:GetFightTechStationLine(sName, nLevel)
	assert( TongFightTech_Common:HasNode(sName, tostring(nLevel)), "TongFightTech_Common��û��Name:" .. sName .. " Level:" .. nLevel)
	return TongFightTech_Common(sName, tostring(nLevel), "StationLine")
end

--��Ҫ��Ӷ�����ʽ�
function CTongTechnologyMgr:GetFightTechNeedTongMoney(sName, nLevel)
	assert( TongFightTech_Common:HasNode(sName, tostring(nLevel)), "TongFightTech_Common��û��Name:" .. sName .. " Level:" .. nLevel)
	return TongFightTech_Common(sName, tostring(nLevel), "NeedTongMoney")
end

--��Ҫ��Ӷ������Դ
function CTongTechnologyMgr:GetFightTechNeedRes(sName, nLevel)
	assert( TongFightTech_Common:HasNode(sName, tostring(nLevel)), "TongFightTech_Common��û��Name:" .. sName .. " Level:" .. nLevel)
	return TongFightTech_Common(sName, tostring(nLevel), "NeedRes")
end

--��Ҫ���ѵ�ʱ��
function CTongTechnologyMgr:GetFightTechNeedTime(sName, nLevel)
	assert( TongFightTech_Common:HasNode(sName, tostring(nLevel)), "TongFightTech_Common��û��Name:" .. sName .. " Level:" .. nLevel)
	return TongFightTech_Common(sName, tostring(nLevel), "NeedTime")
end

--����������Ҫ������
function CTongTechnologyMgr:GetFightTechConsumeDepress(sName, nLevel)
	assert( TongFightTech_Common:HasNode(sName, tostring(nLevel)), "TongFightTech_Common��û��Name:" .. sName .. " Level:" .. nLevel)
	return TongFightTech_Common(sName, tostring(nLevel), "ConsumeDepress")
end

--����������Ҫ��ʱ��
function CTongTechnologyMgr:GetFightTechTimeDepress(sName, nLevel)
	assert( TongFightTech_Common:HasNode(sName, tostring(nLevel)), "TongFightTech_Common��û��Name:" .. sName .. " Level:" .. nLevel)
	return TongFightTech_Common(sName, tostring(nLevel), "TimeDepress")
end

--���ӵ��츳����
function CTongTechnologyMgr:GetFightTechTalentName(sName, nLevel)
	assert( TongFightTech_Common:HasNode(sName, tostring(nLevel)), "TongFightTech_Common��û��Name:" .. sName .. " Level:" .. nLevel)
	return TongFightTech_Common(sName, tostring(nLevel), "TalentName")
end

--���ӵ��츳��
function CTongTechnologyMgr:GetFightTechTanlentPoint(sName, nLevel)
	assert( TongFightTech_Common:HasNode(sName, tostring(nLevel)), "TongFightTech_Common��û��Name:" .. sName .. " Level:" .. nLevel)
	return TongFightTech_Common(sName, tostring(nLevel), "TanlentPoint")
end

function CTongTechnologyMgr:GetTechMH64ByDisplayName(sDisplayName)
	local tblMH64 = {}
	local keys = TongFightTech_Common:GetKeys()
	for i, v in pairs(keys) do
		local real_name = v
		local levels = TongFightTech_Common:GetKeys(real_name)
		for j,k in pairs(levels) do
			local level = k
			local lanIndex = MemH64(string.format("%s%s", real_name, level))
			local sMH64Name = MemH64(real_name)
			local displaySuitName = tostring(Lan_TongFightTech_Common(lanIndex, "DisplayName"))
			if displaySuitName == sDisplayName then
				if( next(tblMH64) ) then
					local bFlag = true
					for i, w in ipairs(tblMH64) do
						if(w == sMH64Name) then bFlag = false break end
					end
					if(bFlag) then
						table.insert(tblMH64, sMH64Name)
					end
				else
					table.insert(tblMH64, sMH64Name)
				end
			end
		end
	end
	return tblMH64
end
--------------------------------------------------------------------------------

g_TongTechMgr = g_TongTechMgr or CTongTechnologyMgr:new()