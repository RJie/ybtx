#include "stdafx.h"
#include "CMagicEffServer.h"
#include "LoadSkillCommon.h"
//#include "CCfgCalc.inl"
#include "CTxtTableFile.h"
#include "CGenericTarget.h"
#include "CCfgColChecker.inl"
#include "CCfgRelationDeal.h"
#include "MagicOpPoss_Function.h"
#include "MagicOps_ChangeValue.h"
#include "MagicOps_Damage.h"
#include "MagicOps_Function.h"
#include "MagicConds_TestValue.inl"
#include "MagicConds_Function.h"
#include "CFilterOpServer.h"
#include "BaseHelper.h"
#include "TSqrAllocator.inl"
#include "TFighterCtrlInfo.inl"
#include "CMagicCfgServer.h"
#include "CSkillCfg.h"

#if _WIN32
#pragma warning(disable:4996)
#endif

CMagicEffServer::MapMagicEffServerById		CMagicEffServer::ms_mapMagicEffServerById;
uint32										CMagicEffServer::ms_uMaxLineNum = 0;

CSkillCfg::MapObjFilterType					CSkillCfg::ms_mapObjFilterType;

CMagicOpTreeServer::MapMagicOp				CMagicOpTreeServer::ms_mapMagicOp;
CMagicOpTreeServer::MapMOPResultType		CMagicOpTreeServer::ms_mapMOPResultType;
CMagicOpTreeServer::MapFxType				CMagicOpTreeServer::ms_mapFxType;
CMagicEffServerSharedPtr					CMagicEffServer::ms_NULL;

CMagicEffServer::CMagicEffServer(void)
:m_pRoot(NULL)
{
}

CMagicEffServer::~CMagicEffServer(void)
{
	CBaseMagicOpServer::Release();
	delete m_pRoot;
}

//class CMagicEffServerTest
//{
//public:
//	CMagicEffServerTest(uint32 u):m_uNum(u) { cout << "ctor" << m_uNum << endl; }
//	~CMagicEffServerTest(){ cout << "dtor" << m_uNum << endl; }
//
//	uint32 m_uNum;
//};
//
//class CMagicEffServerTestSharedPtr : public boost::shared_ptr<CMagicEffServerTest>
//{
//	typedef boost::shared_ptr<CMagicEffServerTest> Parent_t;
//public:
//	CMagicEffServerTestSharedPtr(CMagicEffServerTest* pTest):Parent_t(pTest){}
//};

bool CMagicEffServer::LoadMagicEff(const string& fileName,  bool bReload, bool bFirstFile)
{
	//CMagicEffServerTest* pTest1 = new CMagicEffServerTest(1);
	//CMagicEffServerTest* pTest2 = new CMagicEffServerTest(2);
	//CMagicEffServerTestSharedPtr sharedPtr1(pTest1);
	//CMagicEffServerTestSharedPtr sharedPtr2(pTest2);
	//if(sharedPtr1)
	//{
	//	sharedPtr1.reset();
	//}
	//if(!sharedPtr1)
	//{
	//	sharedPtr1.reset();
	//}
	//cout << sharedPtr1.get() << endl;
	//sharedPtr1 = sharedPtr2;
	//sharedPtr1.reset();
	//sharedPtr2.reset();

	using namespace CfgChk;
	stringstream ExpStr;
	if (!bReload && bFirstFile)
	{	
		CSkillCfg::BuildObjFilterMap();
		CMagicOpTreeServer::BuildMOPMap();
		CMagicOpTreeServer::BuildMOPResultMap();
		CMagicOpTreeServer::BuildFxTypeMap();
	}
	else if (bReload)
	{
		ms_mapMagicEffServerById.clear();
	}
	CTxtTableFile MagicEffFile;
	SetTabFile(MagicEffFile, "ħ��Ч��");
	if(!MagicEffFile.Load(L"cfg", fileName.c_str()))
		return false;

	bool bNewSec = true;
	uint32 uCount = 1;
	CMagicOpTreeServer* pLastNode = NULL;
	CMagicOpTreeServer* pCurNode = NULL;
	CMagicEffServer* pMagicEffCfg=NULL;
	CMagicEffServerSharedPtr* pMagicEffCfgSharedPtr = NULL;
	vector<CMagicOpTreeServer*> vecMagicOpTmp;

	for( uint32 i = ms_uMaxLineNum+1; i < MagicEffFile.GetHeight()+ms_uMaxLineNum; ++i )
	{
		uint32 uLineNum = i-ms_uMaxLineNum;
		SetLineNo(uLineNum);
		string strName;
		ReadItem(strName, szMagicEff_Name,	CANEMPTY);
		if( strName.empty() )
		{
			bNewSec = true;
			continue;
		}
		if (bNewSec)
		{
			bNewSec = false;
			pMagicEffCfg = new CMagicEffServer;
			pMagicEffCfg->m_uId = i;
			pMagicEffCfg->m_strName	= strName;
			uCount=1;
			pMagicEffCfgSharedPtr = new CMagicEffServerSharedPtr(pMagicEffCfg);
			if(!InsertUint32SharedPtrMap(ms_mapMagicEffServerById, pMagicEffCfgSharedPtr))
			{
				SafeDelete(pMagicEffCfgSharedPtr);
				continue;
			}

			if (bReload)
			{
				CMagicEffServerSharedPtr* pMagicEffCfgSharedPtrBak = NULL; 
				MapMagicEffServerByName::iterator it = GetStringKeyMap().find(strName);
				if(it != GetStringKeyMap().end())
				{
					pMagicEffCfgSharedPtrBak = it->second;
					GetStringKeyMap().erase(it);
				}
				InsertStringSharedPtrMap(GetStringKeyMap(), pMagicEffCfgSharedPtr);
				if (pMagicEffCfgSharedPtrBak)
				{
					pMagicEffCfgSharedPtrBak->get()->NotifyRefer();
					delete pMagicEffCfgSharedPtrBak;
				}
			}
			else
			{
				InsertStringSharedPtrMap(GetStringKeyMap(), pMagicEffCfgSharedPtr);
			}
		}

		string strExecCond= MagicEffFile.GetString(uLineNum, szMagicEff_MOPExecCond);
		trimend(strExecCond);
		if(strExecCond.compare("#") == 0)
			break;
		TCHAR* token;
		string whole = strExecCond;
		token = strtok( const_cast<char*>(whole.c_str()), "(),\"" );
		if(token == NULL)
		{
			if(pMagicEffCfgSharedPtr->get()->m_pRoot == NULL)
			{
				pMagicEffCfgSharedPtr->get()->m_pRoot = new CMagicOpTreeServer(MagicEffFile,uCount, i);
				pLastNode = pMagicEffCfgSharedPtr->get()->m_pRoot;
			}
			else
			{
				pCurNode = new CMagicOpTreeServer(MagicEffFile,uCount, i);
				pCurNode->m_pParent = pLastNode;
				pLastNode->AddChild(pCurNode);
				pLastNode = pCurNode;
			}	
			++uCount;
			pMagicEffCfgSharedPtr->get()->m_uCount=uCount-1;
			continue;
		}
		pCurNode = new CMagicOpTreeServer(MagicEffFile,uCount, i);
		int32 index = 1;//��ʶ����������ϵ�е������±ꡣ�����±�����ֱ�ʾ�ڵ�ţ�ż���±�����ֱ�ʾMOPִ�з��ؽ��
		int32 iNum = 0;
		int32 iRet = 0;
		while( token != NULL )	//��ʼ����ǰ�ڵ������������ϵ
		{
			if((index % 2) == 1)
			{
				for (uint32 j=1;j<uCount;++j)
				{
					if (strcmp(token, pMagicEffCfgSharedPtr->get()->m_pRoot->FindNode(j)->m_strMOPType.c_str()) == 0)
					{
						iNum=pMagicEffCfgSharedPtr->get()->m_pRoot->FindNode(j)->m_uIndex;
					}		
				}			
			}
			else
			{
				iRet =CMagicOpTreeServer::ms_mapMOPResultType[string(token)];
				if(pCurNode->m_mapCond.insert(make_pair(iNum, iRet)).second != true)
				{
					ExpStr << "pCurNode->m_mapCond.insert(make_pair(iNum, iRet)).second != true";
					GenErr(ExpStr.str());
				}
			}
			++index;
			// Get next token: 
			token = strtok( NULL, "(),\"" );
		}
		CMagicOpTreeServer::MapCond::iterator it = pCurNode->m_mapCond.end();
		--it;//�ҵ����һ��Ԫ��
		if(it->first < uCount)
		{
			CMagicOpTreeServer* pParent = pMagicEffCfgSharedPtr->get()->m_pRoot->FindNode(it->first);
			if(pParent == NULL)//�������Ľڵ㻹δ���뵽����
			{
				GenErr("CMagicOpTreeServer::LoadMagicEff���ý�����δ��������Ӧ��delete pCurNode");
				vecMagicOpTmp.push_back(pCurNode);
				pLastNode = pCurNode;
				++uCount;
				continue;
			}
			pParent->AddChild(pCurNode);
			pCurNode->m_pParent = pParent;
			//��Ϊ�����˽ڵ㣬���¼��vecMagicOpTmp
			vector<CMagicOpTreeServer*>::iterator it_vec = vecMagicOpTmp.begin();
			for(; it_vec != vecMagicOpTmp.end(); )
			{
				CMagicOpTreeServer::MapCond* pMapCond = &(class_cast<CMagicOpTreeServer*>(*it_vec)->m_mapCond);
				CMagicOpTreeServer::MapCond::iterator it_map = pMapCond->end();
				--it_map;
				if(it_map->first == uCount)
				{
					pCurNode->AddChild(*it_vec);
					class_cast<CMagicOpTreeServer*>(*it_vec)->m_pParent = pCurNode;
					vecMagicOpTmp.erase(it_vec);
					it_vec = vecMagicOpTmp.begin();

					continue;
				}
				++it_vec;
			}
		}
		else//����������Ľڵ㻹δ��ʼ��
		{
			vecMagicOpTmp.push_back(pCurNode);
		}
		pLastNode = pCurNode;
		++uCount;
		if(!vecMagicOpTmp.empty())//���ڲ��ܱ������������ϵ������
		{

			ExpStr << "���ڲ��ܱ������������ϵ";
			GenErr(ExpStr.str());
		}
		pMagicEffCfgSharedPtr->get()->m_uCount=uCount-1;
	}
	ms_uMaxLineNum = ms_uMaxLineNum + MagicEffFile.GetHeight();
	return true;
}

void CMagicEffServer::UnloadMagicEff()
{
	ClearMap(GetStringKeyMap());
	ClearMap(CMagicOpTreeServer::ms_mapMagicOp);
	ms_mapMagicEffServerById.clear();
}

CMagicEffServer::MapMagicEffServerByName& CMagicEffServer::GetStringKeyMap()
{
	return ParentType::GetImpClassMap();
}

CMagicEffServerSharedPtr& CMagicEffServer::GetMagicEff(const string& name)
{
	if (name == "")
	{
		return ms_NULL;
	}
	MapMagicEffServerByName::iterator it = GetStringKeyMap().find(name);

	if(it != GetStringKeyMap().end())
	{
		return *(it->second);
	}

	CfgChk::GenExpInfo("ħ��Ч��������", name);
	return ms_NULL;
}

CMagicEffServerSharedPtr& CMagicEffServer::GetMagicEff(uint32 id)
{
	MapMagicEffServerById::iterator it = ms_mapMagicEffServerById.find(id);

	if(it == ms_mapMagicEffServerById.end())
	{
		stringstream str;
		str << "û��ħ��Ч��: " << id;
		CfgChk::GenExpInfo("û��ħ��Ч��", str.str().c_str());
	}

	return *(it->second);
}

CMagicOpTreeServer::CMagicOpTreeServer(CTxtTableFile& MagicEffFile,uint32 uNum, uint32 uLineNum)
:m_pParent(NULL)
,m_uIndex(uNum)
,m_uId(uLineNum)
,m_MagicOpArg(NULL)
{
	using namespace CfgChk;
	ReadItem(m_strMagicOpName,		szMagicEff_MagicOp);
	ReadItem(m_pMagicOp,			szMagicEff_MagicOp,			ms_mapMagicOp);
	m_strMagicOpArg = MagicEffFile.GetString(g_iLine, szMagicEff_MOPParam);
	ReadItem(m_strMOPType,			szMagicEff_MOPType);

	// �ع�ɸѡ�ܵ�
	stringstream ExpStr;
	string strFilterPipe;
	ReadItem(strFilterPipe,			szMagicEff_FilterPipe,		CANEMPTY);
	trimend(strFilterPipe);
	if (!strFilterPipe.empty())
	{
		vector<string> vecFilter = CMagicCfgServer::Split(strFilterPipe, "|");
		vector<string>::iterator it_Filter = vecFilter.begin();
		for(; it_Filter != vecFilter.end(); ++it_Filter)
		{
			vector<string> vecFilterMultiObj = CMagicCfgServer::Split(*it_Filter, ",");
			vector<string>::iterator it_FilterMultiObj = vecFilterMultiObj.begin();
			MagicEffFilter* pMagicEffFilter = new MagicEffFilter;
			pMagicEffFilter->m_eObjectFilter = CSkillCfg::ms_mapObjFilterType[*it_FilterMultiObj];

			if (vecFilterMultiObj.size() == 2)
			{
				++it_FilterMultiObj;
				pMagicEffFilter->m_FilterPara = new CCfgCalc;
				pMagicEffFilter->m_FilterPara->InputString(*it_FilterMultiObj);
			}
			else
			{
				if (vecFilterMultiObj.size() != 1)
				{
					SafeDelete(pMagicEffFilter);
					ExpStr << m_strMagicOpName << endl;
					GenErr("ħ��Ч����ɸѡ�ܵ�������������!", ExpStr.str());
				}
			}
			m_vecFilterPipe.push_back(pMagicEffFilter);
		}
	}
	else
	{
		ExpStr << m_strMagicOpName << endl;
		GenErr("ħ��Ч����ɸѡ�ܵ�����Ϊ�� ", ExpStr.str());
	}

	string strExecCond;
	ReadItem(strExecCond,			szMagicEff_MOPExecCond,		CANEMPTY);
	vector<MagicEffFilter*>::iterator it = m_vecFilterPipe.begin();
	if ( m_strMOPType.find("����") != -1 && strExecCond.compare("") == 0 && (*it)->m_eObjectFilter == eOF_Self)
	{
		CCfgRelationDeal::AddMopTreeForSync(this);
	}
	ReadItem(m_strFX,				szMagicEff_FXName,			CANEMPTY);
	ReadItem(m_eFxType,				szMagicEff_FxType,			CANEMPTY,	eFT_None,ms_mapFxType);
}

CMagicOpTreeServer::~CMagicOpTreeServer(void)
{
	SafeDelete(m_MagicOpArg);
	ListChild::iterator it = m_listChild.begin();
	for(; it != m_listChild.end(); ++it)
	{
	delete *it;
	}
	m_listChild.clear();
	vector<MagicEffFilter*>::iterator it_Filter = m_vecFilterPipe.begin();
	for (; it_Filter != m_vecFilterPipe.end(); ++it_Filter)
	{
		SafeDelete(*it_Filter);
	}
	m_vecFilterPipe.clear();
}
void CMagicOpTreeServer::BuildFxTypeMap()					
{
	ms_mapFxType[""]	= eFT_None;
	ms_mapFxType["����"]		= eFT_Leading;
	ms_mapFxType["�ܻ�"]		= eFT_Suffer;
	ms_mapFxType["����"]		= eFT_Local;
}

void CMagicOpTreeServer::BuildMOPMap()
{	
	ms_mapMagicOp["���Ƽ���"]					= new CCureMop;
	ms_mapMagicOp["�����������˺�����"]		= new CCalculateMainHandPhysicsHurtMop;
	ms_mapMagicOp["�����������˺�����"]		= new CCalculateAssistantPhyicsHurtMop;
	ms_mapMagicOp["��Ȼϵ���������˺�����"]		= new CCalNatureMagHurtMop;
	ms_mapMagicOp["�ƻ�ϵ���������˺�����"]		= new CCalDestructionMagHurtMop;
	ms_mapMagicOp["����ϵ���������˺�����"]		= new CCalEvilMagHurtMop;
	ms_mapMagicOp["DOT�˺�����"]				= new CCalDOTHurtMop;
	ms_mapMagicOp["�������˺�����"]				= new CCalNonTypeHurtMop;

	ms_mapMagicOp["���������������˺�����"]		= new CCalculateMainHandPhysicsStrikeMop;
	ms_mapMagicOp["�����������ޱ����˺�����"]		= new CCalculateMainHandPhysicsNoStrikeHurtMop;
	ms_mapMagicOp["����������ֻ���б����˺�����"]	= new CCalculateMainHandPhysicsOnlyHitAndStrikeHurtMop;
	ms_mapMagicOp["��Ȼϵ���������ޱ����˺�����"]	= new CCalNatureMagNoStrikeHurtMop;
	ms_mapMagicOp["�ƻ�ϵ���������ޱ����˺�����"]	= new CCalDestructionMagNoStrikeHurtMop;
	ms_mapMagicOp["����ϵ���������ޱ����˺�����"]	= new CCalEvilMagNoStrikeHurtMop;
	ms_mapMagicOp["�ƻ�ϵ�����������ӿ����˺�����"]	= new CCalDestructionMagNoResistHurtMop;
	ms_mapMagicOp["DOT�ޱ����˺�����"]				= new CCalDOTNoStrikeHurtMop;
	//ms_mapMagicOp["�ٻ��������˺�����"]			= new CCalPetPhysicHurtMop;
	//ms_mapMagicOp["�ٻ��޷����˺�����"]			= new CCalPetMagicHurtMop;
	//�������˺�������������δʹ�ã����Ժ�ʹ�������������жϡ�
	ms_mapMagicOp["��������ս���˺�"]			= new CTaskNonBattleHurtMOP;
	ms_mapMagicOp["�������ը���˺�"]			= new CTaskBombHurtMOP;
	ms_mapMagicOp["������������˺�"]			= new CTaskSpecialHurtMOP;
	ms_mapMagicOp["��ɷǹ�ս�����˺�"]			= new CTaskNonNationBattleBuildHurtMOP;

	ms_mapMagicOp["������Ѫ��"]					= new CFillHPMPMOP;
	ms_mapMagicOp["�ı�����ֵ"]					= new CChangeHPMOP;
	ms_mapMagicOp["����ħ��ֵ"]					= new CAbsorbManaPointMOP;
	ms_mapMagicOp["�ı�ħ��ֵ"]					= new CChangeManaPointMOP;
	ms_mapMagicOp["�ı�ŭ��ֵ"]					= new CChangeRagePointMOP;
	ms_mapMagicOp["����ŭ��ֵ"]					= new CAbsorbRagePointMOP;
	ms_mapMagicOp["�ı�����ֵ"]					= new CChangeEnergyPointMOP;
	ms_mapMagicOp["�ı�������"]					= new CChangeComboPointMOP;
	ms_mapMagicOp["Ŀ��ı�����ֵ"]				= new CTargetChangeHPMOP;
	ms_mapMagicOp["��Ѫ"]						= new CSuckBloodMOP;
	ms_mapMagicOp["��������ֵ"]					= new CNoEventChangeHPMOP;	
	ms_mapMagicOp["�츳�ı�ħ��ֵ"]				= new CTalentChangeManaPointMOP;
	ms_mapMagicOp["ҩƷ�ı�����ֵ"]				= new CDrugChangeHPMOP;
	ms_mapMagicOp["�������߸ı�����ֵ"]			= new CIgnoreImmuneChangeHPMOP;
	
	ms_mapMagicOp["�ı�����ֵ����"]				= new CChangeMaxHealthPointAdderMOP;
	ms_mapMagicOp["�ı�����ֵ���ްٷֱ�"]		= new CChangeMaxHealthPointMultiplierMOP;
	ms_mapMagicOp["�ı�ħ��ֵ����"]				= new CChangeMaxManaPointAdderMOP;
	ms_mapMagicOp["�ı�ħ��ֵ���ްٷֱ�"]		= new CChangeMaxManaPointMultiplierMOP;

	ms_mapMagicOp["�ı�����ֵ�ָ��ٷֱ�"]		= new CChangeHPUpdateRateMultiplierMOP;
	ms_mapMagicOp["�ı�ħ��ֵ�ָ��ٷֱ�"]		= new CChangeMPUpdateRateMultiplierMOP;
	ms_mapMagicOp["�ı�ŭ��ֵ˥���ٶ�"]			= new CChangeRPUpdateValueAdderMOP;
	ms_mapMagicOp["�ı�ŭ��ֵ˥���ٷֱ�"]		= new CChangeRPUpdateValueMultiplierMOP;
	ms_mapMagicOp["�ı�����ֵ�ָ��ٶ�"]			= new CChangeEPUpdateValueAdderMOP;
	ms_mapMagicOp["�ı�����ֵ�ָ��ٷֱ�"]		= new CChangeEPUpdateValueMultiplierMOP;
	ms_mapMagicOp["�ı�ħ������ϵ��"]			= new CChangeMPConsumeRateMultiplierMOP;
	ms_mapMagicOp["�ı�ŭ������ϵ��"]			= new CChangeRPConsumeRateMultiplierMOP;
	ms_mapMagicOp["�ı���������ϵ��"]			= new CChangeEPConsumeRateMultiplierMOP;
	ms_mapMagicOp["�ı���Ȼϵħ������ϵ��"]		= new CChangeNatureMPConsumeRateMultiplierMOP;
	ms_mapMagicOp["�ı��ƻ�ϵħ������ϵ��"]		= new CChangeDestructionMPConsumeRateMultiplierMOP;
	ms_mapMagicOp["�ı�ڰ�ϵħ������ϵ��"]		= new CChangeEvilMPConsumeRateMultiplierMOP;
	ms_mapMagicOp["�ı��츳�������ŭ������"]	= new CChangeRPProduceRateMultiplierMOP;

	ms_mapMagicOp["�ı令��ֵ"]					= new CChangeDefenceAdderMOP;
	ms_mapMagicOp["�ı令��ֵ�ٷֱ�"]			= new CChangeDefenceMultiplierMOP;
	ms_mapMagicOp["�ı乥����"]					= new CChangePhysicalDPSAdderMOP;
	ms_mapMagicOp["�ı乥�����ٷֱ�"]			= new CChangePhysicalDPSMultiplierMOP;
	ms_mapMagicOp["�ı�����ֵ"]					= new CChangeResilienceValueAdderMOP;
	ms_mapMagicOp["�ı�����ֵ�ٷֱ�"]			= new CChangeResilienceValueMultiplierMOP;
	ms_mapMagicOp["�ı��Ⱪֵ"]					= new CChangeStrikeResistanceValueAdderMOP;
	ms_mapMagicOp["�ı��Ⱪֵ�ٷֱ�"]			= new CChangeStrikeResistanceValueMultiplierMOP;
	ms_mapMagicOp["�ı侫׼ֵ"]					= new CChangeAccuratenessValueAdderMOP;
	ms_mapMagicOp["�ı侫׼ֵ�ٷֱ�"]			= new CChangeAccuratenessValueMultiplierMOP;
	ms_mapMagicOp["�ı䱬��ֵ"]					= new CChangeStrikeValueAdderMOP;
	ms_mapMagicOp["�ı䱬��ֵ�ٷֱ�"]			= new CChangeStrikeValueMultiplierMOP;
	ms_mapMagicOp["�ı䱬������ֵ"]				= new CChangeStrikeMultiValueAdderMOP;
	ms_mapMagicOp["�ı䱬������ֵ�ٷֱ�"]		= new CChangeStrikeMultiValueMultiplierMOP;
	ms_mapMagicOp["�ı���ʰٷֱ�"]			= new CChangeBlockRateMultiplierMOP;
	ms_mapMagicOp["�ı�񵲼���ֵ"]				= new CChangeBlockDamageAdderMOP;
	ms_mapMagicOp["�ı�񵲼���ֵ�ٷֱ�"]		= new CChangeBlockDamageMultiplierMOP;
	ms_mapMagicOp["�ı�������ֵ"]				= new CChangePhysicalDodgeValueAdderMOP;
	ms_mapMagicOp["�ı�������ֵ�ٷֱ�"]		= new CChangePhysicalDodgeValueMultiplierMOP;
	ms_mapMagicOp["�ı��м�ֵ"]					= new CChangeParryValueAdderMOP;
	ms_mapMagicOp["�ı��м�ֵ�ٷֱ�"]			= new CChangeParryValueMultiplierMOP;
	ms_mapMagicOp["�ı䷨�����ֵ"]				= new CChangeMagicDodgeValueAdderMOP;
	ms_mapMagicOp["�ı䷨�����ֵ�ٷֱ�"]		= new CChangeMagicDodgeValueMultiplierMOP;
	ms_mapMagicOp["�ı䷨������ֵ"]				= new CChangeMagicHitValueAdderMOP;
	ms_mapMagicOp["�ı䷨������ֵ�ٷֱ�"]		= new CChangeMagicHitValueMultiplierMOP;

	ms_mapMagicOp["�ı��ƶ��ٶȰٷֱ�"]			= new CChangePercentMoveSpeedMOP;
	ms_mapMagicOp["�ı䲽���ٶȰٷֱ�"]			= new CChangePercentWalkSpeedMOP;
	ms_mapMagicOp["�ı���ͨ�����ٶȰٷֱ�"]		= new CChangePercentNormalAttackSpeedMOP;

	ms_mapMagicOp["�ı丽�Ӵ����˺�ֵ"]			= new CChangePunctureDamageAdderMOP;
	ms_mapMagicOp["�ı丽�Ӵ����˺�ֵ�ٷֱ�"]	= new CChangePunctureDamageMultiplierMOP;
	ms_mapMagicOp["�ı丽�ӿ���˺�ֵ"]			= new CChangeChopDamageAdderMOP;
	ms_mapMagicOp["�ı丽�ӿ���˺�ֵ�ٷֱ�"]	= new CChangeChopDamageMultiplierMOP;
	ms_mapMagicOp["�ı丽�Ӷۻ��˺�ֵ"]			= new CChangeBluntDamageAdderMOP;
	ms_mapMagicOp["�ı丽�Ӷۻ��˺�ֵ�ٷֱ�"]	= new CChangeBluntDamageMultiplierMOP;
	ms_mapMagicOp["�ı丽�ӷ����˺�ֵ"]			= new CChangeMagicDamageValueAdderMOP;
	ms_mapMagicOp["�ı丽�ӷ����˺�ֵ�ٷֱ�"]	= new CChangeMagicDamageValueMultiplierMOP;
	ms_mapMagicOp["�ı丽����Ȼϵ�˺�ֵ"]		= new CChangeNatureDamageValueAdderMOP;
	ms_mapMagicOp["�ı丽����Ȼϵ�˺�ֵ�ٷֱ�"]	= new CChangeNatureDamageValueMultiplierMOP;
	ms_mapMagicOp["�ı丽���ƻ�ϵ�˺�ֵ"]		= new CChangeDestructionDamageValueAdderMOP;
	ms_mapMagicOp["�ı丽���ƻ�ϵ�˺�ֵ�ٷֱ�"]	= new CChangeDestructionDamageValueMultiplierMOP;
	ms_mapMagicOp["�ı丽�Ӱ���ϵ�˺�ֵ"]		= new CChangeEvilDamageValueAdderMOP;
	ms_mapMagicOp["�ı丽�Ӱ���ϵ�˺�ֵ�ٷֱ�"]	= new CChangeEvilDamageValueMultiplierMOP;

	ms_mapMagicOp["�ı���Ȼϵ����ֵ"]			= new CChangeNatureResistanceValueAdderMOP;
	ms_mapMagicOp["�ı���Ȼϵ����ֵ�ٷֱ�"]		= new CChangeNatureResistanceValueMultiplierMOP;
	ms_mapMagicOp["�ı䰵��ϵ����ֵ"]			= new CChangeEvilResistanceValueAdderMOP;
	ms_mapMagicOp["�ı䰵��ϵ����ֵ�ٷֱ�"]		= new CChangeEvilResistanceValueMultiplierMOP;
	ms_mapMagicOp["�ı��ƻ�ϵ����ֵ"]			= new CChangeDestructionResistanceValueAdderMOP;
	ms_mapMagicOp["�ı��ƻ�ϵ����ֵ�ٷֱ�"]		= new CChangeDestructionResistanceValueMultiplierMOP;

	ms_mapMagicOp["�ı似�ܸ��������˺�"]			= new CChangePhysicalDamageAdderMOP;
	ms_mapMagicOp["�ı似�ܸ��������˺��ٷֱ�"]		= new CChangePhysicalDamageMultiplierMOP;
	ms_mapMagicOp["�ı似�ܸ��Ӹ��������˺�"]		= new CChangeAssistPhysicalDamageAdderMOP;
	ms_mapMagicOp["�ı似�ܸ��Ӹ��������˺��ٷֱ�"]	= new CChangeAssistPhysicalDamageMultiplierMOP;
	ms_mapMagicOp["�ı似�ܸ��ӷ����˺�"]			= new CChangeMagicDamageAdderMOP;
	ms_mapMagicOp["�ı������ܸ��ӷ����˺�"]		= new CChangeSelfMagicDamageAdderMOP;
	ms_mapMagicOp["�ı似�ܸ��ӷ����˺��ٷֱ�"]		= new CChangeMagicDamageMultiplierMOP;
	ms_mapMagicOp["�ı似�ܸ���DOT�˺�"]			= new CChangeDOTDamageAdderMOP;
	ms_mapMagicOp["�ı似�ܸ���DOT�˺��ٷֱ�"]		= new CChangeDOTDamageMultiplierMOP;

	ms_mapMagicOp["�ı�ʩ�����̿��ж���"]			= new CChangeResistCastingInterruptionRateMultiplierMOP;
	ms_mapMagicOp["�ı䴩͸ֵ"]						= new CChangePenetrationValueAdderMOP;
	ms_mapMagicOp["�ı䴩͸ֵ�ٷֱ�"]				= new CChangePenetrationValueMultiplierMOP;
	ms_mapMagicOp["�ı����ֵ"]						= new CChangeProtectionValueAdderMOP;
	ms_mapMagicOp["�ı����ֵ�ٷֱ�"]				= new CChangeProtectionValueMultiplierMOP;

	ms_mapMagicOp["�������߰�װħ��״̬"]	= new CIgnoreImmuneSetupSpecialStateMOP;
	ms_mapMagicOp["������װħ��״̬"]		= new CPassiveSetupMagicStateMOP;
	ms_mapMagicOp["��װħ��״̬"]			= new CSetupMagicStateMOP;
	ms_mapMagicOp["��װ������״̬"]			= new CSetupTriggerStateMOP;
	ms_mapMagicOp["��װ�˺����״̬"]		= new CSetupDamageChangeStateMOP;
	ms_mapMagicOp["��װ���۴���״̬"]		= new CSetupCumuliTriggerStateMOP;
	ms_mapMagicOp["��װ����״̬"]			= new CSetupSpecialStateMOP;
	ms_mapMagicOp["ֻ��װ������ħ��״̬"]	= new CSetupUncancellableMagicStateMOP;
	ms_mapMagicOp["����߼��ܵȼ���װħ��״̬"] = new CSetupMagicStateByMaxSkillLevelMOP;
	ms_mapMagicOp["����ħ��״̬���Ӳ���"]	= new CCancelMagicStateCascadeMOP;
	ms_mapMagicOp["��Ч������ħ��״̬���Ӳ���"]	= new CCancelMagicStateCascadeByEffectMOP;
	ms_mapMagicOp["����������״̬"]			= new CTriggerStateMessageEventMOP; 
	ms_mapMagicOp["ˢ��ħ��״̬ʱ��"]		= new CResetMagicStateTimeMOP;
	ms_mapMagicOp["����ħ��״̬ʱ��"]		= new CAddMagicStateTimeMOP;
	ms_mapMagicOp["�����˺����״̬�ۻ�ֵ"] = new CSetDamageChangeStateAccumulateMOP;
	ms_mapMagicOp["���û��۴���״̬�ۻ�ֵ"] = new CSetCumuliTriggerStateAccumulateMOP;
	ms_mapMagicOp["��װ�������̬"]			= new CSetupOrEraseAureMagicMOP;
	ms_mapMagicOp["��װ��̬"]				= new CSetupAureMagicMOP;
	ms_mapMagicOp["�л���̬"]				= new CChangeAureMagicMOP;
	ms_mapMagicOp["�����̬"]				= new CEraseAureMagicMOP;
	ms_mapMagicOp["����ʱ�����̬"]			= new CEraseAureMagicOnCancellingMOP;
	ms_mapMagicOp["ʩ��λ��ħ��"]			= new CRelMoveMagicMOP;
	ms_mapMagicOp["ʩ�ſɳ���λ��ħ��"]		= new CCancelableRelMoveMagicMOP;
	ms_mapMagicOp["ʩ�ŵص�λ��ħ��"]		= new CRelPosMoveMagicMOP;
	ms_mapMagicOp["ʩ�ſɴ���ħ��"]			= new CRelTransferMagicMOP;
	ms_mapMagicOp["ʩ���ӵ�ħ��"]			= new CRelBulletMagicMOP;
	ms_mapMagicOp["ʩ����ʱ�ӵ�ħ��"]		= new CDelayRelBulletMagicMOP;
	ms_mapMagicOp["ʩ�ŵص��ӵ�ħ��"]		= new CRelPosBulletMagicMOP;
	ms_mapMagicOp["ʩ�ų����ħ��"]			= new CRelShockWaveMagicMOP;
	ms_mapMagicOp["ʩ����ʱ�����ħ��"]		= new CDelayRelShockWaveMagicMOP;
	ms_mapMagicOp["ʩ����ʱ�ص�ħ��"]		= new CDelayRelPositionMagicMOP;
	ms_mapMagicOp["ʩ�ŵص�ħ��"]			= new CRelPositionMagicMOP;
	ms_mapMagicOp["����ʼ����;���ʩ�ŵص�ħ��"]	= new CRelPositionMagicByDirAndDistanceMOP;
	ms_mapMagicOp["��Ŀ��λ��ʩ�ŵص�ħ��"]	= new CRelPositionMagicAtTargetPosMOP;
	ms_mapMagicOp["��Ŀ��λ��ʩ�ų����ħ��"]	= new CRelShockWaveMagicAtTargetPosMOP;
	ms_mapMagicOp["��Χ������ͷŵص�ħ��"]	= new CRelPositionMagicRandomInAreaMOP;
	ms_mapMagicOp["�������Ŀ�ĵ�ʩ��λ��ħ��"]	= new CRelMoveMagicAtShockwaveMagicPosMOP;
	ms_mapMagicOp["ʩ����ʱħ��Ч��"]		= new CRelTickMOP;
	ms_mapMagicOp["ʩ��ͼ��ħ��"]			= new CCreateTotemMOP;
	ms_mapMagicOp["����ʼ����;���ʩ��ͼ��ħ��"]	= new CCreateTotemByDirAndDistanceMOP;
	ms_mapMagicOp["����ͼ��ħ��"]			= new CDestroyServantMOP;
	ms_mapMagicOp["ʩ����ħ��"]			= new CRelBattleArrayMagicMOP;
	ms_mapMagicOp["��������"]				= new CCreateServantMOP;
	ms_mapMagicOp["�������ﲢ����Ŀ��"]		= new CCreateServantWithTargetLevelFollowMasterMOP;
	ms_mapMagicOp["���ù��￨���ܵȼ�Ϊ���˼��ܵȼ�"]		= new CSetMonsterCardSkillLevelByMasterSkillLevelMOP;
	ms_mapMagicOp["���ٳ���"]				= new CDestroyServantMOP;
	ms_mapMagicOp["���Ƴ���"]				= new CControlServantMOP;
	ms_mapMagicOp["����ʱ���ٳ���"]			= new CDestroyServantOnCancellingMOP;
	ms_mapMagicOp["��������"]				= new CCreateShadowMOP;
	ms_mapMagicOp["�������ΪĿ��ľ���"]	= new CBecomeTargetShadowMOP;
	ms_mapMagicOp["���ó�������ʱ��"]		= new CSetServantLeftTimeMOP;
	//ms_mapMagicOp["ʹ��ħ��Ч��"]			= new CUseMagaicEff;
	//ms_mapMagicOp["����ʱ����ħ��Ч��"]		= new CCancelMagicEff;
	ms_mapMagicOp["����ٻ��޳��"]			= new CRemoveServantEnemyMOP;
	ms_mapMagicOp["�ص���Ч"]				= new CPostionPlayFXMOP;

	ms_mapMagicOp["ʹ����ͨ����"]			= new CUseNormalHorseMOP;
	ms_mapMagicOp["ʹ��ս������"]			= new CUseBattleHorseMOP;
	ms_mapMagicOp["�ٻ�ս������"]			= new CCallBattleHorseMOP;
	ms_mapMagicOp["�ջ��������"]			= new CTakeBackRidingHorseMOP;

	ms_mapMagicOp["�����ٻ���Ŀ��"]			= new CSetServantTargetMOP;
	ms_mapMagicOp["ʹ�ٻ��޹���Ŀ��"]		= new CLetServantAttackTargetMOP;
	ms_mapMagicOp["����ٻ��޶�Ŀ��ĳ��"] = new CRemoveEnemyFromServantEnmityListMOP;
	ms_mapMagicOp["����NPC"]				= new CCreateNPCMOP;	
	ms_mapMagicOp["ɾ��NPC"]				= new CDestoryNPCMOP;
	ms_mapMagicOp["��������NPC"]			= new CCreatePassiveNPCMOP;	
	ms_mapMagicOp["�ص㴴��NPC"]			= new CPosCreateNPCMOP;
	ms_mapMagicOp["�ص㴴��NPC�ȼ�������"]	= new CPosCreateNPCLevelSameMOP;
	ms_mapMagicOp["ָ���ص㴴��NPC"]		= new CTargetPosCreateNPCMOP;
	ms_mapMagicOp["ָ���ص㴴��NPC�ȼ�������"] = new CTargetPosCreateNPCLevelSameMOP;
	ms_mapMagicOp["Ŀ��λ�ô���NPC"]		= new CCreateNPCOnTargetPosMOP;
	ms_mapMagicOp["ָ���ص���ʱ����NPC"]	= new CPosDelayCreateNPCMOP;
	ms_mapMagicOp["�ص㴴��ʬ��"]			= new CPosCreateDeadNPCMOP;	
	ms_mapMagicOp["��װ�����������״̬"]	= new CSetupOrEraseTriggerStateMOP;
	ms_mapMagicOp["��װ�����ħ��״̬"]		= new CSetupOrEraseMagicStateMOP;
	ms_mapMagicOp["��װ���ħ��״̬"]		= new CSetupMultiMagicStateMOP;
	ms_mapMagicOp["ֹͣ�����¼�"]			= new CDisTriggerEventMOP;
	ms_mapMagicOp["������ͬĿ��"]			= new CSetSameTargetMOP;
	ms_mapMagicOp["����Ŀ��Ϊ����"]			= new CSetTargetSelfMOP;
	ms_mapMagicOp["���Ŀ��"]				= new CSetTargetNULLMOP;
	ms_mapMagicOp["�滻����"]				= new CReplaceSkillMOP;
	ms_mapMagicOp["ָ���ص㴴��Npc����������"]	= new CPosCreateNpcWithMasterMOP;

	// CLEAN UP START
	// Ŀ�깲��
	ms_mapMagicOp["����ȫ����"]			= new CDoAllBodyActionMOP;
	ms_mapMagicOp["Ŀ������ս��״̬"]		= new CTargetLeftBattleStateMOP;
	ms_mapMagicOp["Ŀ���ֹ�ƶ�"]			= new CTargetForbitMoveMOP;
	ms_mapMagicOp["Ŀ���ֹת��"]			= new CTargetForbitTurnAroundMOP;
	ms_mapMagicOp["Ŀ�곷���չ�"]			= new CTargetCancelNAMOP;
	ms_mapMagicOp["Ŀ����ͣ�չ�"]			= new CTargetSuspendNAMOP;
	ms_mapMagicOp["Ŀ���ֹ��ͨ����"]		= new CTargetForbitNormalAttackMOP;
	ms_mapMagicOp["Ŀ���ֹʩ�ż���"]		= new CTargetForbitUseSkillMOP;
	ms_mapMagicOp["Ŀ���ֹʩ����Ȼϵ����"]	= new CTargetForbitUseNatureSkillMOP;
	ms_mapMagicOp["Ŀ���ֹʩ���ƻ�ϵ����"]	= new CTargetForbitUseDestructionSkillMOP;
	ms_mapMagicOp["Ŀ���ֹʩ�Ű���ϵ����"]	= new CTargetForbitUseEvilSkillMOP;
	ms_mapMagicOp["Ŀ���ֹ�ͻ��˲���"]		= new CTargetForbitClientOperateMOP;
	ms_mapMagicOp["Ŀ���ֹʩ��ְҵ����"]	= new CTargetForbitUseClassSkillMOP;
	ms_mapMagicOp["Ŀ���ֹʩ��ҩƷ����"]	= new CTargetForbitUseDrugItemSkillMOP;
	ms_mapMagicOp["Ŀ���ֹʩ�ŷ�ս������"]	= new CTargetForbitUseNotFightSkillMOP;
	ms_mapMagicOp["Ŀ���ֹʩ���淨��Ʒ����"]	= new CTargetForbitUseMissionItemSkillMOP;

	// Ŀ������
	ms_mapMagicOp["����"]					= new CFeignDeathMOP;
	ms_mapMagicOp["����"]					= new CTauntMOP;
	ms_mapMagicOp["��������"]				= new CRenascenceMOP;
	ms_mapMagicOp["ԭ������"]				= new CRebornWhereYouBeMOP;
	ms_mapMagicOp["������"]				= new CPermitRebornMOP;
	ms_mapMagicOp["��������"]				= new CContinueAddMPMOP;
	ms_mapMagicOp["ֹͣ�˶�"]				= new CStopMoveMOP;
	ms_mapMagicOp["����"]					= new CBreakOutMOP;
	ms_mapMagicOp["�������"]				= new CSoulLinkMOP;
	ms_mapMagicOp["���ʩ�ű�������"]		= new CRelPassiveSkillMOP;
	ms_mapMagicOp["NPCʩ�ż���"]			= new CRelNPCSkillMOP;
	ms_mapMagicOp["NPCʩ�ŷ�����"]		= new CRelNPCDirSkillMOP;
	ms_mapMagicOp["��е"]					= new CForbitUseWeaponMOP;
	ms_mapMagicOp["�չ�����ŭ��"]			= new CNormalAttackProduceRagePoint;
	ms_mapMagicOp["���˺�����ŭ��"]			= new CBeDamagePreduceRagePoint;
	ms_mapMagicOp["����λ��"]				= new CSwapPositionMOP;
	ms_mapMagicOp["Ŀ���Լ���װħ��״̬"]	= new CTargetSetupMagicStateToSelfMOP;
	ms_mapMagicOp["����"]					= new CTargetSetHiddenMOP;
	ms_mapMagicOp["�ӹ����䳵"]				= new CTakeOverTRuckMop;
	ms_mapMagicOp["�����ƶ���Ŀ��λ��"]		= new CMoveSelfToTargetPosMop;
	ms_mapMagicOp["��ɱʽ��ը"]				= new CSelfMurderBlastMOP;
	ms_mapMagicOp["�Ծ���ӵ���߽�����"]		= new CBurstSoulPrizeToExpOwnerMOP;
	ms_mapMagicOp["�Ծ���ӵ���߽����긽��"]	= new CCBurstSoulExtraPrizeToExpOwnerMOP;
	ms_mapMagicOp["���ӱ�������ֵ"]			= new CAddBurstSoulTimesMOP;
	ms_mapMagicOp["���ӱ���������"]			= new CAddContinuousBurstTimesMOP;

	// �ص�����
	ms_mapMagicOp["��ɱ"]					= new CPursueKillMOP;
	ms_mapMagicOp["ʩ���ϰ�"]				= new CSetupDynamicBarrierMOP;
	ms_mapMagicOp["ʹ��ʬ��"]				= new CUseDeadBobyMOP;
	// CLEAN UP END

	ms_mapMagicOp["ʩ�����缼��"]		= new CDoWorldSkillMOP;
	ms_mapMagicOp["ʩ����Ӫ����"]				= new CDoCampSkillMOP;
	ms_mapMagicOp["ʩ��Ӷ���ż���"]				= new CDoArmyCorpsSkillMOP;
	ms_mapMagicOp["ʩ��Ӷ��С�Ӽ���"]				= new CDoTongSkillMOP;


	ms_mapMagicOp["�ı��չ���������"]		= new CChangeNAActionRhythmMOP;
	ms_mapMagicOp["��Ч����"]				= new COnlyPlayFX;
	ms_mapMagicOp["������Ч����"]				= new CDisplayMsgMOP;

	ms_mapMagicOp["���λ��ħ��"]			= new CEraseMoveMagicMOP;
	ms_mapMagicOp["����жԵص�ħ��"]		= new CEraseEnemyPositionMagicMOP;
	ms_mapMagicOp["����ص�ħ��"]			= new CErasePositionMagicMOP;
	ms_mapMagicOp["������еص�ħ��"]		= new CEraseAllPositionMagicMOP;
	ms_mapMagicOp["�滻�ص�ħ��"]			= new CReplacePositionMagicMOP;
	ms_mapMagicOp["�������״̬"]			= new CEraseAllBufferMOP;
	ms_mapMagicOp["������и���״̬"]		= new CEraseAllDecreaseStateMOP;
	ms_mapMagicOp["����ƶ����Ƹ���״̬"]	= new CEraseMoveDecreaseStateMOP;
	ms_mapMagicOp["������ٸ���״̬"]		= new CEraseSpeedDecreaseStateMOP;
	ms_mapMagicOp["�������״̬"]			= new CEraseIncreaseStateMOP;
	ms_mapMagicOp["�������״̬"]			= new CEraseStateByDecreaseTypeMOP;
	ms_mapMagicOp["������һ������״̬"]	= new CRandEraseAllDecreaseStateMOP;
	ms_mapMagicOp["������һ������״̬"]	= new CRandEraseIncreaseStateMOP;
	ms_mapMagicOp["�������״̬"]			= new CEraseRidingStateMOP;
	ms_mapMagicOp["���״̬"]				= new CEraseStateMOP;
	ms_mapMagicOp["��������״̬"]			= new CEraseSelfStateMOP;
	ms_mapMagicOp["����ʱ���״̬"]			= new CEraseStateOnCancellingMOP;
	ms_mapMagicOp["�ֿ�����״̬"]			= new CResistControlMOP;
	ms_mapMagicOp["�ֿ�����״̬"]			= new CResistPauseMOP;
	ms_mapMagicOp["�ֿ�����״̬"]			= new CResistCripplingMOP;
	ms_mapMagicOp["�ֿ�DOT״̬"]			= new CResistDOTMOP;
	ms_mapMagicOp["���为��״̬"]			= new CReflectStateByDecreaseTypeMOP;
	ms_mapMagicOp["���õ�����ȴʱ��"]		= new CResetSingleCoolDownTimeMOP;
	ms_mapMagicOp["���м�����ȴ����"]		= new CAllSkillReadyMOP;
	ms_mapMagicOp["����ս��������ȴ����"]	= new CAllFightSkillReadyMOP;
	ms_mapMagicOp["�¸�����������ʱ��"]		= new CSetNoSingTimeAboutNextSkill;
	ms_mapMagicOp["���ȫ����������ʱ��"]	= new CSetNoSingTimeForever;
	ms_mapMagicOp["�����ױ�ֵ"]				= new CLockAgileValueMOP;
	ms_mapMagicOp["�ı�Ŀ��Ϊ�ϰ�"]			= new CChangeTargetToBarrierMOP;

	ms_mapMagicOp["ִ���ֲ�����"]			= new CHandActionMOP;
	ms_mapMagicOp["ִ�нŲ�����"]			= new CFootActionMOP;

	ms_mapMagicOp["Ŀ��ʩ���ӵ�ħ��"]		= new CTargetRelBulletMagicMOP;
	ms_mapMagicOp["������Ч"]				= new CTargetBurstSoulFXMOP;
	ms_mapMagicOp["Ŀ�걬����Ч"]			= new CBurstSoulFXMOP;
	ms_mapMagicOp["���굯����Ч"]			= new CBurstSoulBallFXMOP;
	ms_mapMagicOp["���ȼ����ı�������ֵ"]	= new CConsumeBurstSoulTimesMOP;
	ms_mapMagicOp["����"]					= new CReturnBattleArrayMOP;
	ms_mapMagicOp["�ı���Ӫ"]				= new CChangeCampMOP;

	//�������
	ms_mapMagicOp["��ս����Ϊ����"]			= new CNonCombatBehaviorMOP;
	ms_mapMagicOp["��ս����Ϊ״̬����"]		= new CNonCombatStateMagicOp;
	ms_mapMagicOp["�ı����վ������"]		= new CChangeExpRateMOP;
	ms_mapMagicOp["�ı丱���������"]		= new CChangeExpRateInFBMOP;
	ms_mapMagicOp["�ı����ջ�ֵ����"]		= new CChangeFetchRateMOP;
	ms_mapMagicOp["�س�"]					= new CChangeSceneMOP;
	ms_mapMagicOp["�ı�����ֵ"]				= new CChangeStealthMOP;
	ms_mapMagicOp["��������ֵ�޸�"]			= new CDisableStealthMOP;
	ms_mapMagicOp["�ı�����ֵ"]				= new CChangeKeennessMOP;
	ms_mapMagicOp["��������ֵ�޸�"]			= new CDisableKeennessMOP;
	//End

	ms_mapMagicOp["�ı���Ȼ��ѹֵ"]				= new CChangeNatureSmashValueAdderMOP;
	ms_mapMagicOp["�ı���Ȼ��ѹֵ�ٷֱ�"]		= new CChangeNatureSmashValueMultiplierMOP;
	ms_mapMagicOp["�ı��ƻ���ѹֵ"]				= new CChangeDestructionSmashValueAdderMOP;
	ms_mapMagicOp["�ı��ƻ���ѹֵ�ٷֱ�"]		= new CChangeDestructionSmashValueAdderMOP;
	ms_mapMagicOp["�ı䰵����ѹֵ"]				= new CChangeEvilSmashValueAdderMOP;
	ms_mapMagicOp["�ı䰵����ѹֵ�ٷֱ�"]		= new CChangeEvilSmashValueMultiplierMOP;
	ms_mapMagicOp["�ı令����ѹֵ"]				= new CChangeDefenceSmashValueAdderMOP;
	ms_mapMagicOp["�ı令����ѹֵ�ٷֱ�"]		= new CChangeDefenceSmashValueMultiplierMOP;
	
	ms_mapMagicOp["�ı����ո���DOT�˺��ӳɰٷֱ�"]		= new CChangeExtraDOTDamageRateMultiplierMOP;
	ms_mapMagicOp["�ı����ո��Ӵ����˺��ӳɰٷֱ�"]		= new CChangeExtraPunctureDamageRateMultiplierMOP;
	ms_mapMagicOp["�ı����ո��ӿ���˺��ӳɰٷֱ�"]		= new CChangeExtraChopDamageRateMultiplierMOP;
	ms_mapMagicOp["�ı����ո��Ӷۻ��˺��ӳɰٷֱ�"]		= new CChangeExtraBluntDamageRateMultiplierMOP;
	ms_mapMagicOp["�ı����ո�����Ȼ�˺��ӳɰٷֱ�"]		= new CChangeExtraNatureDamageRateMultiplierMOP;
	ms_mapMagicOp["�ı����ո��Ӱ����˺��ӳɰٷֱ�"]		= new CChangeExtraEvilDamageRateMultiplierMOP;
	ms_mapMagicOp["�ı����ո����ƻ��˺��ӳɰٷֱ�"]		= new CChangeExtraDestructionDamageRateMultiplierMOP;
	ms_mapMagicOp["�ı����ո��ӹ������˺��ӳɰٷֱ�"]	= new CChangeExtraBowDamageRateMultiplierMOP;
	ms_mapMagicOp["�ı����ո����������˺��ӳɰٷֱ�"]	= new CChangeExtraCrossBowDamageRateMultiplierMOP;
	ms_mapMagicOp["�ı����ո���˫�������˺��ӳɰٷֱ�"] = new CChangeExtraTwohandWeaponDamageRateMultiplierMOP;
	ms_mapMagicOp["�ı����ո��ӳ��������˺��ӳɰٷֱ�"] = new CChangeExtraPolearmDamageRateMultiplierMOP;
	ms_mapMagicOp["�ı����ո�����ʿ�����˺��ӳɰٷֱ�"] = new CChangeExtraPaladinWeaponDamageRateMultiplierMOP;
	ms_mapMagicOp["�ı����ո��Ӹ��������˺��ӳɰٷֱ�"] = new CChangeExtraAssistWeaponDamageRateMultiplierMOP;
	ms_mapMagicOp["�ı����ո���Զ�������˺��ӳɰٷֱ�"] = new CChangeExtraLongDistDamageRateMultiplierMOP;
	ms_mapMagicOp["�ı����ո��ӽ��������˺��ӳɰٷֱ�"] = new CChangeExtraShortDistDamageRateMultiplierMOP;
	ms_mapMagicOp["�ı�Զ�����������˺����������ٷֱ�"] = new CChangeLongDistWeaponDamageRateMultiplierMOP;
	ms_mapMagicOp["�ı������˺�����ٷֱ�"]				= new CChangeDamageDecsRateMultiplierMOP;
	ms_mapMagicOp["�ı���������ֵ�ӳɰٷֱ�"]			= new CChangeExtraCureValueRateMultiplierMOP;
	ms_mapMagicOp["�ı����ձ�����ֵ�ӳɰٷֱ�"]			= new CChangeExtraBeCuredValueRateMultiplierMOP;
	ms_mapMagicOp["�ı����״̬�ֿ��ʰٷֱ�"]			= new CChangeControlDecreaseResistRateMultiplierMOP;
	ms_mapMagicOp["�ı䶨��״̬�ֿ��ʰٷֱ�"]			= new CChangePauseDecreaseResistRateMultiplierMOP;
	ms_mapMagicOp["�ı����״̬�ֿ��ʰٷֱ�"]			= new CChangeCripplingDecreaseResistRateMultiplierMOP;
	ms_mapMagicOp["�ı�Debuff״̬�ֿ��ʰٷֱ�"]			= new CChangeDebuffDecreaseResistRateMultiplierMOP;
	ms_mapMagicOp["�ı�DOT״̬�ֿ��ʰٷֱ�"]			= new CChangeDOTDecreaseResistRateMultiplierMOP;
	ms_mapMagicOp["�ı�����״̬�ֿ��ʰٷֱ�"]			= new CChangeSpecialDecreaseResistRateMultiplierMOP;
	ms_mapMagicOp["�ı����ʱ��ٷֱ�"]					= new CChangeControlDecreaseTimeRateMultiplierMOP;
	ms_mapMagicOp["�ı䶨��ʱ��ٷֱ�"]					= new CChangePauseDecreaseTimeRateMultiplierMOP;
	ms_mapMagicOp["�ı����ʱ��ٷֱ�"]					= new CChangeCripplingDecreaseTimeRateMultiplierMOP;
	ms_mapMagicOp["�ı�����ʱ��ٷֱ�"]					= new CChangeSpecialDecreaseTimeRateMultiplierMOP;
	ms_mapMagicOp["�ı�������������ʼӳɰٷֱ�"]		= new CChangeExtraPhysicDefenceRateMultiplierMOP;
	ms_mapMagicOp["�ı������������ʼӳɰٷֱ�"]		= new CChangeExtraPhysicDodgeRateMultiplierMOP;
	ms_mapMagicOp["�ı������м��ʼӳɰٷֱ�"]			= new CChangeExtraParryRateMultiplierMOP;
	ms_mapMagicOp["�ı����ձ����ʼӳɰٷֱ�"]			= new CChangeExtraStrikeRateMultiplierMOP;
	ms_mapMagicOp["�ı����շ�����ܼӳɰٷֱ�"]			= new CChangeExtraMagicDodgeRateMultiplierMOP;
	ms_mapMagicOp["�ı����շ����ֿ��ʼӳɰٷֱ�"]		= new CChangeExtraMagicResistanceRateMultiplierMOP;
	ms_mapMagicOp["�ı�������Ȼ�ֿ��ʼӳɰٷֱ�"]		= new CChangeExtraNatureResistanceRateMultiplierMOP;
	ms_mapMagicOp["�ı������ƻ��ֿ��ʼӳɰٷֱ�"]		= new CChangeExtraDestructionResistanceRateMultiplierMOP;
	ms_mapMagicOp["�ı����հ��ڵֿ��ʼӳɰٷֱ�"]		= new CChangeExtraEvilResistanceRateMultiplierMOP;
	ms_mapMagicOp["�ı�������ȫ�ֿ��ʼӳɰٷֱ�"] 		= new CChangeExtraCompleteResistanceRateMultiplierMOP;
	ms_mapMagicOp["�ı�δ���аٷֱ�"]					= new CChangeMissRateMultiplierMOP;

	ms_mapMagicOp["�ı�ʩ��ʱ��ٷֱ�"]					= new CChangeCastingProcessTimeRatioMultiplierMOP;

	ms_mapMagicOp["�ı�NPC������Χ��"]					= new CChangeNpcAttackScopeToMOP;

	ms_mapMagicOp["�ı������ʰٷֱ�"]					= new CChangeImmuneRateMultiplierMOP;
	ms_mapMagicOp["���ߴ����˺�"]						= new CImmunePunctureDamageMOP;
	ms_mapMagicOp["���߿���˺�"]						= new CImmuneChopDamageMOP;
	ms_mapMagicOp["���߶ۻ��˺�"]						= new CImmuneBluntDamageMOP;
	ms_mapMagicOp["������Ȼ�˺�"]						= new CImmuneNatureDamageMOP;
	ms_mapMagicOp["�����ƻ��˺�"]						= new CImmuneDestructionDamageMOP;
	ms_mapMagicOp["���߰����˺�"]						= new CImmuneEvilDamageMOP;
	ms_mapMagicOp["���߿���״̬"]						= new CImmuneControlDecreaseMOP;
	ms_mapMagicOp["���߶���״̬"]						= new CImmunePauseDecreaseMOP;
	ms_mapMagicOp["���߼���״̬"]						= new CImmuneCripplingDecreaseMOP;
	ms_mapMagicOp["���߸���״̬"]						= new CImmuneDebuffDecreaseMOP;
	ms_mapMagicOp["�����˺�״̬"]						= new CImmuneDOTDecreaseMOP;
	ms_mapMagicOp["��������״̬"]						= new CImmuneSpecialDecreaseMOP;
	ms_mapMagicOp["�������������˺�"]					= new CImmuneTaskTypeDamageMOP;
	ms_mapMagicOp["��������"]							= new CImmuneCureMOP;
	ms_mapMagicOp["����λ��ħ��"]						= new CImmuneMoveMagicMOP;
	ms_mapMagicOp["���������������˺�"]					= new CImmuneNonTypePhysicsDamageMOP;
	ms_mapMagicOp["�����������˺�"]						= new CImmuneNonTypeDamageMOP;
	ms_mapMagicOp["��������������"]						= new CImmuneNonTypeCureMOP;
	ms_mapMagicOp["���ߴ��"]							= new CImmuneInterruptCastingProcessMOP;
	ms_mapMagicOp["�ر��˺���ʾ"]						= new CClosePrintInfoMOP;
	ms_mapMagicOp["���ʩ��"]							= new CInterruptCastingProcessMagicMOP;
	ms_mapMagicOp["ǿ������DOT�˺�"]					= new CForceSetDOTDamageMOP;
	ms_mapMagicOp["��Ŀ���������"]					= new CBindTargetObjToSelfMOP;

	ms_mapMagicOp["����ֵС��"]				= new CHealthPointLesserMCOND;
	ms_mapMagicOp["����ֵ���ڵ���"]			= new CHealthPointGreaterOrEqualMCOND;
	ms_mapMagicOp["ħ��ֵС��"]				= new CManaPointLesserMCOND;
	ms_mapMagicOp["ħ��ֵ���ڵ���"]			= new CManaPointGreaterOrEqualMCOND;
	ms_mapMagicOp["ħ��ֵ���ֵ���ڵ���"]	= new CMaxManaPointGreaterOrEqualMCOND;
	ms_mapMagicOp["����ֵ���ڵ���"]			= new CEnergyPointGreaterOrEqualMCOND;
	ms_mapMagicOp["ŭ��ֵ���ڵ���"]			= new CRagePointGreaterOrEqualMCOND;
	ms_mapMagicOp["��������ڵ���"]			= new CComboPointGreaterOrEqualMCOND;

	ms_mapMagicOp["����ֵС��"]				= new CDefenceLesserMCOND;
	ms_mapMagicOp["����ֵ���ڵ���"]			= new CDefenceGreaterOrEqualMCOND;
	ms_mapMagicOp["��Ȼ��ֵС��"]			= new CNatureResistanceValueLesserMCOND;
	ms_mapMagicOp["��Ȼ��ֵ���ڵ���"]		= new CNatureResistanceValueGreaterOrEqualMCOND;
	ms_mapMagicOp["�ƻ���ֵС��"]			= new CDestructionResistanceValueLesserMCOND;
	ms_mapMagicOp["�ƻ���ֵ���ڵ���"]		= new CDestructionResistanceValueGreaterOrEqualMCOND;
	ms_mapMagicOp["���ڿ�ֵС��"]			= new CEvilResistanceValueLesserMCOND;
	ms_mapMagicOp["���ڿ�ֵ���ڵ���"]		= new CEvilResistanceValueGreaterOrEqualMCOND;

	ms_mapMagicOp["����С��"]						= new CProbabilityLesserCond;
	ms_mapMagicOp["ʩ������Ŀ�����С��"]			= new CDistOfAttackerAndTargetLesserCond;
	ms_mapMagicOp["ʩ������Ŀ�������ڵ���"]		= new CDistOfAttackerAndTargetGreaterOrEqualCond;
	ms_mapMagicOp["ħ����Ŀ�����С��"]				= new CDistOfMagicAndTargetLesserCond;
	ms_mapMagicOp["ħ����Ŀ�������ڵ���"]			= new CDistOfMagicAndTargetGreaterOrEqualCond;

	ms_mapMagicOp["����ħ��״̬"]			= new CTestMagicStateMCOND;
	ms_mapMagicOp["��[����ħ��״̬�����������츳]"]			= new CNotTestMagicStateAndSelfExistTalentMCOND;
	ms_mapMagicOp["������ħ��״̬"]			= new CTestNotInMagicStateMCOND;
	ms_mapMagicOp["�����ڲ����ظ�ħ��״̬"]	= new CTestNotInRepeatedMagicStateMCOND;
	ms_mapMagicOp["�������˺����״̬"]		= new CTestNotInDamageChangeStateMCOND;
	ms_mapMagicOp["���������ħ��״̬"]		= new CTestSelfMagicStateMCOND;
	ms_mapMagicOp["���ڴ�����״̬"]			= new CTestTriggerStateMCOND;
	ms_mapMagicOp["��������Ĵ�����״̬"]	= new CTestSelfTriggerStateMCOND;
	ms_mapMagicOp["�����˺����״̬"]		= new CTestDamageChangeStateMCOND;
	ms_mapMagicOp["����������˺����״̬"] = new CTestSelfDamageChangeStateMCOND;
	ms_mapMagicOp["��������״̬"]			= new CTestSpecialStateMCOND;
	ms_mapMagicOp["����������״̬"]			= new CTestNotInSpecialStateMCOND;
	ms_mapMagicOp["�������������״̬"]		= new CTestSelfSpecialStateMCOND;
	ms_mapMagicOp["�����ڸ���״̬"]			= new CTestNotInStateByDecreaseTypeMCOND;
	ms_mapMagicOp["��[���ڸ���״̬�����������츳]"]			= new CNotTestInStateByDecreaseTypeAndSelfExistTalentMCOND;
	ms_mapMagicOp["ħ��״̬���Ӳ������ڵ���"] =	new CTestMagicStateCascadeGreaterOrEqualMCOND;
	ms_mapMagicOp["������̬����"]			= new CTestAureMagicMCOND;
	ms_mapMagicOp["װ���˶���"]				= new CTestShieldEquipMCOND;
	ms_mapMagicOp["����װ����"]				= new CTestMainHandEquipMCOND;
	ms_mapMagicOp["����װ��������"]			= new CTestAssistHandEquipMCOND;
	ms_mapMagicOp["�������"]				= new CTestIsExistPetMCOND;
	ms_mapMagicOp["�����ڳ���"]				= new CTestIsNotExistPetMCOND;
	ms_mapMagicOp["ͼ�ڴ���"]				= new CTestIsExistTotemMCOND;
	ms_mapMagicOp["�������"]				= new CTestIsExistHorseMCOND;
	ms_mapMagicOp["���ﲻ����"]				= new CTestIsNotExistHorseMCOND;
	ms_mapMagicOp["Ŀ���Ƿ�ɱ�����"]		= new CTestTargetCanBeControlledMCOND;
	ms_mapMagicOp["Ŀ���Ƿ�ɱ���ʳ"]		= new CTestTargetCanBeRavinMCOND;
	ms_mapMagicOp["Ŀ���Ƿ�Ϊ���"]			= new CTestTargetIsPlayerMCOND;
	ms_mapMagicOp["Ŀ��Ϊ�ѷ�"]				= new CTestTargetIsFriendMCOND;
	ms_mapMagicOp["Ŀ��Ϊ�ѷ�����"]			= new CTestTargetIsFriendsServantMCOND;
	ms_mapMagicOp["Ŀ��Ϊ�з�"]				= new CTestTargetIsEnemyMCOND;
	ms_mapMagicOp["Ŀ��ְҵ"]				= new CTestTargetClassMCOND;
	ms_mapMagicOp["Ŀ���Ƿ�ΪNPC"]			= new CTestTargetIsNPCMCOND;
	ms_mapMagicOp["Ŀ���Ƿ�Ϊ�ٻ���"]		= new CTestTargetIsSummonMCOND;
	ms_mapMagicOp["Ŀ��ȼ�С�ڵ�������ȼ�"]= new CTestTargetLevelLesserOrEqualMCOND;
	ms_mapMagicOp["Ŀ���Ƿ�Ϊ����"]			= new CTestTargetIsSelfCOND;
	ms_mapMagicOp["������ս��״̬"]			= new CTestNotInBattleMCOND;
	ms_mapMagicOp["�������淨״̬"]			= new CTestNotOnMissionMCOND;
	ms_mapMagicOp["�ǻ�������״̬"]			= new CTestNotBattleHorseStateMCOND;
	ms_mapMagicOp["��������������"]			= new CTestWeaponTypeMCOND;
	ms_mapMagicOp["���״̬���"]			= new CTestRidingMCOND;
	ms_mapMagicOp["�����̬���"]			= new CTestRidingAureMagicMCOND;
	ms_mapMagicOp["����·�����Ƿ����ϰ�"]	= new CTestTrianglePathMCOND;
	ms_mapMagicOp["�Ƿ�Ϊ����ʬ��"]			= new CTestIsAvailableDeadBobyMCOND;
	ms_mapMagicOp["Ŀ��ȼ��Ƿ���"]		= new CTestTargetLevelIsInScopeMCOND;
	ms_mapMagicOp["Ŀ�����������С��"]		= new CTestTargetDistIsLesserThanMCOND;
	ms_mapMagicOp["Ŀ���Ƿ��������"]		= new CTestTargetIsVestInSelfMCOND;
	ms_mapMagicOp["Ŀ���Ƿ����Ŷӳ�Ա"]		= new CTestTargetIsRaidmatesMCOND;
	ms_mapMagicOp["Ŀ�괦��ĳϵ����"]		= new CTestTargetInCastingProcess;
	ms_mapMagicOp["Ŀ���Ƿ����ƶ�"]		= new CTestTargetIsMoving;
	ms_mapMagicOp["Ŀ���Ƿ���λ��ħ��"]	= new CTestTargetIsMoveMagic;
	ms_mapMagicOp["Ŀ���Ƿ񲻴���λ��ħ��"]	= new CTestTargetNotIsMoveMagic;
	ms_mapMagicOp["Ŀ����Ӫ��"]				= new CTestTargetIsCamp;
	ms_mapMagicOp["���������ȼ����ڵ���"]	= new CTestBurstSoulTimesGreaterOrEqualMCOND;
	ms_mapMagicOp["��������������"]			= new CTestContinuousBurstSoulTimesEqualMCOND;
	ms_mapMagicOp["Ŀ��ӵ�еص�ħ��"]		= new CTestTargetHavePositionMagic;
	ms_mapMagicOp["Ŀ�꾭������������ڴ�����״̬"]	= new CTestExpIsVestInSelfAndTriggerStateMCOND;
	ms_mapMagicOp["Ŀ��ѧ�Ἴ��"]			= new CTestTargetLearnSkillMCOND;
	ms_mapMagicOp["Ŀ��ȼ�С�ڵ��ھ���ӵ���ߵȼ�"] = new CTestTargetLevelLesserOrEqualToExpOwnerMCOND;	
	ms_mapMagicOp["Ŀ�꼼���Ƿ�������ȴ"]	= new CTestTargetSkillIsCoolDownMCOND;	
	ms_mapMagicOp["Ŀ�겻���ڳ���"]			= new CTestTargetInScene;	
	ms_mapMagicOp["Ŀ�꽵���"]				= new CDebaseEnmityMOP;
}

void CMagicOpTreeServer::BuildMOPResultMap()
{
	ms_mapMOPResultType["ʧ��"]		= eHR_Fail;
	ms_mapMOPResultType["�ɹ�"]		= eHR_Success;
	ms_mapMOPResultType["����"]		= eHR_Hit;
	ms_mapMOPResultType["δ����"]	= eHR_Miss;
	ms_mapMOPResultType["����"]		= eHR_Strike;
	ms_mapMOPResultType["��������"]	= eHR_PhyDodge;
	ms_mapMOPResultType["ħ������"]	= eHR_MagDodge;
	ms_mapMOPResultType["�ֿ�"]		= eHR_Resist;
	ms_mapMOPResultType["��ȫ�ֿ�"] = eHR_ComResist;
	ms_mapMOPResultType["�м�"]		= eHR_Parry;
	ms_mapMOPResultType["��"]		= eHR_Block;
	ms_mapMOPResultType["����"]		= eHR_Immune;
}

void CMagicOpTreeServer::AddChild(CMagicOpTreeServer* pChild)
{
	m_listChild.push_back(pChild);
}

bool CMagicOpTreeServer::HasChild()
{
	return !m_listChild.empty();
}

CMagicOpTreeServer* CMagicOpTreeServer::FindNode(uint32 uNum)
{
	if(uNum == m_uIndex)
	{
		return this;
	}

	if(!HasChild())
	{
		return NULL;
	}

	CMagicOpTreeServer* tmp = NULL;

	ListChild::iterator it = m_listChild.begin();
	for(; it != m_listChild.end(); ++it)
	{
		tmp = class_cast<CMagicOpTreeServer*>(*it)->FindNode(uNum);
		if(tmp != NULL)
		{
			break;
		}
	}
	return tmp;
}

void CMagicOpTreeServer::InitMagicOpArg()
{
	if (m_pMagicOp)
	{
		m_MagicOpArg = m_pMagicOp->InitArg(m_strMagicOpArg);
	}
	else
	{
		stringstream ExpStr;
		ExpStr << "��" << m_uId << "�е�ħ������[" << m_strMagicOpName << "]������,ȷ���¼��û����,�����ñ�ʹ���汾��һ��!" << endl;
		GenErr(ExpStr.str());
	}
	ListChild::iterator it = m_listChild.begin();
	for(; it != m_listChild.end(); ++it)
	{
		CMagicOpTreeServer* pNode = class_cast<CMagicOpTreeServer*>(*it);
		pNode->InitMagicOpArg();
	}
}

void CMagicEffServer::InitMagicOpArg()
{
	MapMagicEffServerById::iterator itBegin		= ms_mapMagicEffServerById.begin();
	MapMagicEffServerById::iterator itEnd	 = ms_mapMagicEffServerById.end();
	for(; itBegin!=itEnd; itBegin++)
	{
		itBegin->second->get()->m_pRoot->InitMagicOpArg();
	}
}
