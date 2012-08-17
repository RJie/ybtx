#include "stdafx.h"
#include "CTestHurtResult.h"
#include "MagicOps_Damage.h"
#include "CScriptAppServer.h"
#include "CTxtTableFile.h"
#include "CodeCvs.h"

namespace sqr
{
	extern const wstring PATH_ALIAS_CFG;
}

void CTestHurtResult::CalPhysicsProbability()
{
	string path  = utf8_to_gbk(CScriptAppServer::Inst()->GetCfgFilePath(""));
	string fileName = path + "/skill/Calculate/CalPhysicsProbability.txt";
	CTxtTableFile TabFile;
	if (!TabFile.Load(PATH_ALIAS_CFG.c_str(), fileName.c_str()))
		return;
	for( int32 i = 1; i < TabFile.GetHeight(); ++i )
	{
		PropertyOfPhysicsCal pro;
		string strExampleName		= TabFile.GetString(i, "ʵ����");
		pro.m_ePhysicalAttackType	= (EPhysicalAttackType)TabFile.GetInteger(i, "�չ�����", 0);
		pro.m_uAttackerLevel		= TabFile.GetInteger(i, "�����ߵȼ�", 0);
		pro.m_fMissRate				= TabFile.GetFloat(i, "δ������", 0.0f);
		pro.m_uAccuratenessValue	= TabFile.GetInteger(i, "��׼ֵ", 0);
		pro.m_uStrikeValue			= TabFile.GetInteger(i, "����ֵ", 0);
		pro.m_fExtraStrikeRate		= TabFile.GetFloat(i, "���ӱ�����", 0.0f);

		pro.m_uTargetLevel			= TabFile.GetInteger(i, "Ŀ��ȼ�", 0);
		pro.m_uPhysicalDodgeValue	= TabFile.GetInteger(i, "����ֵ", 0);
		pro.m_fExtraPhysicDodgeRate	= TabFile.GetFloat(i, "����������", 0.0f);
		pro.m_uParryValue			= TabFile.GetInteger(i, "�м�ֵ", 0);
		pro.m_fExtraParryRate		= TabFile.GetFloat(i, "�����м���", 0.0f);
		pro.m_fBlockRate			= TabFile.GetFloat(i, "����", 0.0f);

		EHurtResult eResult;
		uint32 uMissCnt(0), uPhydodgeCnt(0), uParryCnt(0), uBlockCnt(0), uStrikeCnt(0), uHitCnt(0);

		for (int32 i = 0; i < 1000; ++i)
		{
			eResult = CCalculatePhysicsHurtMop::CalProbability(pro);
			switch (eResult)
			{
			case eHR_Miss:		++uMissCnt;		break;
			case eHR_PhyDodge:	++uPhydodgeCnt; break;
			case eHR_Parry:		++uParryCnt;	break;
			case eHR_Block:		++uBlockCnt;	break;
			case eHR_Strike:	++uStrikeCnt;	break;
			case eHR_Hit:		++uHitCnt;		break;
			default: 
				break;
			}
		}

		//cout << "�������� : " << strExampleName << endl;
		//cout << "�����ߵȼ�: " << pro.m_uAttackerLevel << "\t �չ�����: " << pro.m_ePhysicalAttackType << "\t δ������: " << pro.m_fMissRate
		//	 << "\t ��׼ֵ: " << pro.m_uAccuratenessValue << "\t ����ֵ: " << pro.m_uStrikeValue << "\t ���ӱ�����: " << pro.m_fExtraStrikeRate << endl;
		//cout << "�������ߵȼ�: " << pro.m_uTargetLevel << "\t ����ֵ: " << pro.m_uPhysicalDodgeValue << "\t ����������: " << pro.m_fExtraPhysicDodgeRate
		//	<< "\t �м�ֵ: " << pro.m_uParryValue << "\t �����м���: " << pro.m_fExtraParryRate << "\t ����: " << pro.m_fBlockRate << endl;
		//printf("������ 1000 �ν��Ϊ:\n");
		//printf("[δ����]: %4d ��, Լռ %5.2f%%\n", uMissCnt, (float)uMissCnt*100/(float)1000);
		//printf("[��  ��]: %4d ��, Լռ %5.2f%%\n", uPhydodgeCnt, (float)uPhydodgeCnt*100/(float)1000);
		//printf("[��  ��]: %4d ��, Լռ %5.2f%%\n", uParryCnt, (float)uParryCnt*100/(float)1000);
		//printf("[��  ��]: %4d ��, Լռ %5.2f%%\n", uBlockCnt, (float)uBlockCnt*100/(float)1000);
		//printf("[��  ��]: %4d ��, Լռ %5.2f%%\n", uStrikeCnt, (float)uStrikeCnt*100/(float)1000);
		//printf("[��  ��]: %4d ��, Լռ %5.2f%%\n", uHitCnt, (float)uHitCnt*100/(float)1000);
	}
}

void CTestHurtResult::CalMagicProbability()
{
	string path  = utf8_to_gbk(CScriptAppServer::Inst()->GetCfgFilePath(""));
	string fileName = path + "/skill/Calculate/CalMagicProbability.txt";
	CTxtTableFile TabFile;
	if (!TabFile.Load(PATH_ALIAS_CFG.c_str(), fileName.c_str()))
		return;
	for( int32 i = 1; i < TabFile.GetHeight(); ++i )
	{
		PropertyOfMagicCal pro;
		string strExampleName		= TabFile.GetString(i, "ʵ����");

		pro.m_uAttackerLevel		= TabFile.GetInteger(i, "�����ߵȼ�", 0);
		pro.m_uMagicHitValue		= TabFile.GetInteger(i, "��������ֵ", 0);
		pro.m_uStrikeValue			= TabFile.GetInteger(i, "����ֵ", 0);
		pro.m_fExtraStrikeRate		= TabFile.GetFloat(i, "���ӱ�����", 0.0f);

		pro.m_uTargetLevel						= TabFile.GetInteger(i, "Ŀ��ȼ�", 0);;
		pro.m_uMagicDodgeValue					= TabFile.GetInteger(i, "��������ֵ", 0);;
		pro.m_fExtraMagicDodgeRate				= TabFile.GetFloat(i, "����������", 0.0f);
		pro.m_uNatureResistanceValue			= TabFile.GetInteger(i, "��Ȼ����ֵ", 0);;
		pro.m_fExtraNatureResistanceRate		= TabFile.GetFloat(i, "������Ȼ����", 0.0f);
		pro.m_uDestructionResistanceValue		= TabFile.GetInteger(i, "�ƻ�����ֵ", 0);;
		pro.m_fExtraDestructionResistanceRate	= TabFile.GetFloat(i, "�����ƻ�����", 0.0f);
		pro.m_uEvilResistanceValue				= TabFile.GetInteger(i, "���ڿ���ֵ", 0);;
		pro.m_fExtraEvilResistanceRate			= TabFile.GetFloat(i, "���Ӱ��ڿ���", 0.0f);
		pro.m_fExtraMagicResistanceRate			= TabFile.GetFloat(i, "���ӷ�������", 0.0f);
		pro.m_fExtraCompleteResistanceRate		= TabFile.GetFloat(i, "������ȫ����", 0.0f);

		EHurtResult eResult;
		uint32 uMagDodgeCnt(0), uComResistCnt(0), uResistCnt(0), uStrikeCnt(0), uHitCnt(0);

		for (int32 i = 0; i < 1000; ++i)
		{
			eResult = CCalculateMagicHurtMop::CalProbability(pro);
			switch (eResult)
			{
			case eHR_MagDodge:		++uMagDodgeCnt;		break;
			case eHR_ComResist:		++uComResistCnt;	break;
			case eHR_Resist:		++uResistCnt;		break;
			case eHR_Strike:		++uStrikeCnt;		break;
			case eHR_Hit:			++uHitCnt;			break;
			default: break;
			}
		}

		//cout << "�������� : " << strExampleName << endl;
		//cout << "�����ߵȼ�: " << pro.m_uAttackerLevel << "\t ��������ֵ: " << pro.m_uMagicHitValue <<  "\t ����ֵ: " << pro.m_uStrikeValue << "\t ���ӱ�����: " << pro.m_fExtraStrikeRate << endl;
		//cout << "�������ߵȼ�: " << pro.m_uTargetLevel << "\t ��������ֵ: " << pro.m_uMagicDodgeValue << "\t ���ӷ���������: " << pro.m_fExtraMagicDodgeRate
		//	<< "\t ��Ȼ����ֵ: " << pro.m_uNatureResistanceValue << "\t ������Ȼ����: " << pro.m_fExtraNatureResistanceRate 
		//	<< "\t �ƻ�����ֵ: " << pro.m_uDestructionResistanceValue << "\t �����ƻ�����: " << pro.m_fExtraDestructionResistanceRate 
		//	<< "\t ���ڿ���ֵ: " << pro.m_uEvilResistanceValue << "\t ���Ӱ��ڿ���: " << pro.m_fExtraEvilResistanceRate 
		//	<< "\t ���ڿ���ֵ: " << pro.m_fExtraMagicResistanceRate << "\t ���Ӱ��ڿ���: " << pro.m_fExtraCompleteResistanceRate << endl;
		//printf("�������� 1000 �ν��Ϊ:\n");
		//printf("[��������]: %4d ��, Լռ %5.2f%%\n", uMagDodgeCnt, (float)uMagDodgeCnt*100/(float)1000);
		//printf("[��ȫ�ֿ�]: %4d ��, Լռ %5.2f%%\n", uComResistCnt, (float)uComResistCnt*100/(float)1000);
		//printf("[��  ��  ]: %4d ��, Լռ %5.2f%%\n", uResistCnt, (float)uResistCnt*100/(float)1000);
		//printf("[��  ��  ]: %4d ��, Լռ %5.2f%%\n", uStrikeCnt, (float)uStrikeCnt*100/(float)1000);
		//printf("[��  ��  ]: %4d ��, Լռ %5.2f%%\n", uHitCnt, (float)uHitCnt*100/(float)1000);
	}
}
