gac_gas_require "relation/tong/TongMgrInc"
cfg_load "tong/TongPurview_Common"
cfg_load "tong/TongLevelAndHonor_Common"
cfg_load "tong/TongFightTechToPlayer_Common"

function CTongMgr:Ctor()
	self:Init()
end

function CTongMgr:Init()
	self.m_nRegistLevel = 20		--ע������Ҫ�ȼ�
	self.m_nJoinInLevel = 10		--��������Ҫ�ĵȼ�
	self.m_nRegistMoney = 10000		--��ᴴ����Ҫ�ʽ�20��
	self.m_nDefaultResource = 0		--��ʼ��Դ
	self.m_nUpperResource = 18000	--��Դ����
	self.m_nDepotContent = 20000	--ÿ�����ݲ���Դ��������
	self.m_nDefaultMoney = 0
	self.m_nDefaultHonor = 0		--��ʼ����
	self.m_nBuildWaitNum = 6		--���콨��ģ��ʱ�������ĵȴ���
	self.m_nAddProfferByContributeMoney = 10		--���׽�Ǯ�����İﹱ
	self.m_nInitMember  = 40 --Ӷ���ų�ʼ��������
	self.m_nEveryLevelMember = 8 --ÿ������������
	self.m_nInitBuildNum = 8 --��ʼ��������
	self.m_nEveryLevelBuild = 1 --ÿ��������������
	self.m_nRequstTimeLimit = 86400  --������ʱ������ 24*60*60
	self.m_nMaxRequestNum = 50 --������������	
	self.m_nUpTongMoney = 10000	--����С��������Ҫ�Ľ��
	self.m_nUpTongExploit = 10000 --����Ϊ��Ӣս��С����Ҫ������
	
	self.m_tblBuildingState = 
		{	
			["�ȴ�����"] 	= 1,
			["����"] 			= 2,
 			["ģ��"] 			= 3,
 			["����"] 	= 4,
		}
		
	self.m_tblLogType =
		{	
			["��ͨ"] 	= 0,
			["��Ա"] 	= 1,
 			["����"] 	= 2,
 			["ս��"] 	= 3,
 			["�Ƽ�"] 	= 4,
 			["����"] 	= 5,
 			["�ֿ�"] 	= 6,
		}
		--�ֿ�ʹ�õȼ�
		--�ַ�����ӦTongPurview_Common����ֶ�����
		--���ֶ�Ӧ�ڼ����ֿ�
	self.m_tblDepotType =
		{	
			[5] 	= "UseTZDepot",		--�ų�
 			[4] 	= "UseFTZdepot",	--���ų�
 			[3] 	= "UseYZdepot",		--Ӫ��
 			[2] 	= "UseDZdepot",		--�ӳ�
 			[1] 	= "UseTYdepot",		--��Ա
		}
		
		--ְλ�����Զ�Ӧ��messageID
		self.m_tblPosLevel2MsgID =
		{	
			[5] 	= 2001,		--�ų�
 			[4] 	= 2002,		--���ų�
 			[3] 	= 2003,		--Ӫ��
 			[2] 	= 2004,		--�ӳ�
 			[1] 	= 2005,		--��Ա
		}
	self.m_tblChallengeState =
		{
			["��ս"]	= 0,
			["��ս"]	= 1,
			["ս��"]	= 2,
		}
	self.m_tblPosInfo =
		{
			["�ų�"]	= 5,
			["���ų�"]	= 4,
			["Ӫ��"]	= 3,
			["�ӳ�"]	= 2,
			["��Ա"]	= 1,
		}
	self.m_tblTruckMaxLoad =
	{
		["С�����䳵"] = 5,
		["�������䳵"] = 10,
		["�������䳵"] = 50,
	}
	self.m_tblTongType = 
	{
		["��ͨ"] = 0,
		["ս��"] = 1,
		["����"] = 2,
		["��Ӣս��"] = 3,
		["��Ӣ����"] = 4,
	}
end

function CTongMgr:GetDepotContent()
	return self.m_nDepotContent
end

function CTongMgr:GetTongTotalMem(nLevel)
	return self.m_nInitMember + self.m_nEveryLevelMember *(nLevel-1)
end

function CTongMgr:GetDepotStrByPage(nPage)
	return self.m_tblDepotType[nPage]
end

function CTongMgr:GetProfferByContribtMoney()
	return self.m_nAddProfferByContributeMoney
end

function CTongMgr:GetLogType(sTypeName)
	return self.m_tblLogType[sTypeName]
end
function CTongMgr:GetBuildingState(sTate)
	return self.m_tblBuildingState[sTate]
end
function CTongMgr:GetBuildWaitNum()
	return self.m_nBuildWaitNum
end

function CTongMgr:GetPosIndexByName(sPosName)
	return self.m_tblPosInfo[sPosName]
end


function CTongMgr:GetPosUpperTotal(nPosIndex)
	local tblInfo = TongPurview_Common("UpperNumber")
	local tblPos = {tblInfo("Level1"), tblInfo("Level2"), tblInfo("Level3"), tblInfo("Level4"), tblInfo("Level5")}
	return tblPos[nPosIndex]
end

function CTongMgr:GetRegistMoney()
	return self.m_nRegistMoney 
end

function CTongMgr:GetRegistLevel()
	return self.m_nRegistLevel 
end

function CTongMgr:GetJoinInLevel()
	return self.m_nJoinInLevel
end

function CTongMgr:GetDefaultResource()
	return self.m_nDefaultResource
end

function CTongMgr:GetUpperResource()
	return self.m_nUpperResource
end

function CTongMgr:GetDefaultMoney()
	return self.m_nDefaultMoney
end

function CTongMgr:GetDefaultHonor()
	return self.m_nDefaultHonor
end

function CTongMgr:GetUpTongMoney()
	return self.m_nUpTongMoney
end

function CTongMgr:GetUpTongExploit()
	return self.m_nUpTongExploit
end

function CTongMgr:GetLevelByHonor(nHonor)
	local tbl = {}
	local keys = TongLevelAndHonor_Common:GetKeys()
	for i,key in pairs(keys) do
		local p = TongLevelAndHonor_Common(key)
		local nIndex = p("nIndex")
		local nHonor = p("nHonor")
		if (not nHonor) or ("" == nHonor) then
			nHonor = 0 
		end
   	table.insert(tbl,{nIndex,tonumber(nHonor)})
  end
  if #tbl == 0 then return 1 end
	table.sort(tbl, function (a, b)
			if (a[1] < b[1]) then
				return a[1] < b[1]
			elseif(a[1] == b[1]) then
				return a[2] < b[2]
			end
		end)
	if nHonor < tbl[1][2] then
		return 1
	end
	for j=2,#tbl do
		if nHonor >= tbl[j-1][2] and nHonor < tbl[j][2] then
			return tbl[j-1][1]
		end
		if j == #tbl then
			return tbl[#tbl][1]
		end
	end
end

function CTongMgr:LevelN2S(nLevel)
	return TongLevelAndHonor_Common(nLevel, "sLevel")
end

function CTongMgr:GetUpperHonor(nCurLevel)
	local nUpperLevel = TongLevelAndHonor_Common(nCurLevel + 1, "nHonor")
	return nUpperLevel or TongLevelAndHonor_Common(nCurLevel, "nHonor")
end

function CTongMgr:GetTongTypeByName(sTypeName)
	return self.m_tblTongType[sTypeName]
end


g_TongMgr = g_TongMgr or CTongMgr:new()


local function GetTongFightTechToPlayerTbl()
	local tbl = {}
	local keys = TongFightTechToPlayer_Common:GetKeys()
	for i,v in pairs (keys) do
		tbl[v] = {}
		local LevelKeys = TongFightTechToPlayer_Common(v):GetKeys()
		for j,m in pairs (LevelKeys) do
			tbl[v][tonumber(m)] = {
													ConsumeSoul 	= TongFightTechToPlayer_Common(v,m,"ConsumeSoul"),
													ConsumeMoney 	= TongFightTechToPlayer_Common(v,m,"ConsumeMoney"),
													Proffer 		= TongFightTechToPlayer_Common(v,m,"Proffer"),
													ConsumeItemTbl 	= loadstring(" return " .. TongFightTechToPlayer_Common(v,m,"ConsumeItem"))(),
													TeamProffer 	= TongFightTechToPlayer_Common(v,m,"TeamProffer"),
												}
		end
	end
	return tbl
end

g_TongFightTechToPlayerTbl = GetTongFightTechToPlayerTbl()