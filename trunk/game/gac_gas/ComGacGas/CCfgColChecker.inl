#include "CCfgColChecker.h"
#include "CCfgCalc.inl"
#include <stdarg.h>
#include <iostream>
#include "StringHelper.h"
#include "ErrLogHelper.h"

namespace CfgChk
{

template<class ReaderType>
void GenExpInfo(const string& sExp, const ReaderType& tValue)
{
	g_bExistError = true;
	stringstream ExpStr;
	if(g_bIsCheckingCfg)
	{
		ExpStr << "���ñ�[" << g_sTabName << "]��" << (g_iLine + 1) << "��[" << g_sTitle << "]�е�ֵ["
			<< tValue << "]" << sExp << endl;
	}
	else
	{
		ExpStr << "[" << tValue << "]" << sExp << endl;
	}
//#if _DEBUG
	//cout << ExpStr.str();
//#endif
	if(g_bIsCheckingCfg)
	{
		cout << ExpStr.str();
		if(ExpAtOnce())
			CfgLogErr(ExpStr.str().c_str());
	}
	else
	{
		CfgLogErr(ExpStr.str().c_str());
	}
}

template<class EnumType>
void CreateMap(map<string, EnumType, less<string>, 
			   TConfigAllocator<pair<string, EnumType > > > &mapEnum, uint32 uCount, ...)
{
	va_list argList;

	va_start(argList, uCount);
	for(uint32 i = 0; i < uCount; i++)
	{
		mapEnum[va_arg(argList, TCHAR*)] = (EnumType) i;
	}
	va_end(argList);
};

template<class NodeType>
void CreateVector(vector<NodeType, TConfigAllocator<uint32> > &vecNode, uint32 uCount, ...)
{
	va_list argList;
	vecNode.resize(uCount);

	va_start(argList, uCount);
	for(uint32 i = 0; i < uCount; i++)
	{
		vecNode[i] = va_arg(argList, TCHAR*);
	}
	va_end(argList);
};


//CheckEmpty()
//CheckEmpty()
template<class DefaultType>
void CheckEmpty(CCfgCalc*& tReader, const string& sValue, bool bCanEmpty,
				const DefaultType& tDefault)
{
	//Check
	if(bCanEmpty)
	{
		if(sValue.empty())
		{
			tReader = new CCfgCalc(tDefault);
			return;
		}
	}
	else
	{
		if(sValue.empty())
		{
#ifdef CHECKCFG
			if(g_bCheckInReading)
			{
				GenExpInfo("Υ����Լ��������Ϊ��", sValue);
			//return false;
			}
#endif
			tReader = new CCfgCalc(0);
			return;
		}
	}
	//return true;
}

template<class ReaderType>
void CheckEmpty(ReaderType& tReader, const string& sValue, bool bCanEmpty,
								const ReaderType& tDefault)
{
	//Check
	if(bCanEmpty)
	{
		if(sValue.empty())
		{
			tReader = tDefault;
			return;
		}
	}
	else
	{
#ifdef CHECKCFG
		if(g_bCheckInReading)
		{
			if(sValue.empty())
			{
				GenExpInfo("Υ����Լ��������Ϊ��", sValue);
				//return false;
				return;
			}
		}
#endif
	}
	//return true;
}

//template<class ReaderType>
//void CheckType(int32 iLine, ReaderType& tReader, const sValue)
//{
//
//}


//SetValue()
template<class EnumType>
void SetValue(EnumType& tReader, const string& sValue,
			  map<string, EnumType, less<string>, 
			  TConfigAllocator<pair<string, EnumType > > >& pFieldMap)
{
	//tReader = pFieldMap[sValue];
	typename map<string, EnumType, less<string>, 
		TConfigAllocator<pair<string, EnumType > > >::iterator itr = pFieldMap.find(sValue);
	if(itr != pFieldMap.end())
	{
		tReader = itr->second;
	}
	else
	{
		tReader = EnumType(NULL);
	}
}


//CheckField()
template<class ReaderType>
void CheckField(ReaderType& tReader, FIELD_CHECKER pFunFieldChecker,
								ReaderType fFieldCheckerParam)
{
#ifdef CHECKCFG
	if(g_bCheckInReading)
	{
		if(!pFunFieldChecker) return;
		if(!pFunFieldChecker((float)tReader, (float)fFieldCheckerParam))
		{
			GenExpInfo("Υ����Լ������ֵ����ȡֵ��Χ", tReader);
		}
	}
#endif
}

template<class EnumType>
bool InField(string& sValue, map<string, EnumType, less<string>, 
			 TConfigAllocator<pair<string, EnumType > > >& pFieldMap)
{
	return pFieldMap.find(sValue) != pFieldMap.end();
}

template<class EnumType>
void CheckField(string& sValue, map<string, EnumType, less<string>, 
				TConfigAllocator<pair<string, EnumType > > >& pFieldMap)
{
#ifdef CHECKCFG
	if(g_bCheckInReading)
	{
		if(pFieldMap.find(sValue) == pFieldMap.end())
		{
			GenExpInfo("Υ����Լ����ֵ��������map��", sValue);
		}
	}
#endif
}


//ReadItem()
template<class ReaderType>
void ReadItem(ReaderType& tReader, const TCHAR* sTitle,
			  FIELD_CHECKER pFunFieldChecker, ReaderType fFieldCheckerParam)
{
	ReadItem(tReader, sTitle, false, ReaderType(0), pFunFieldChecker, fFieldCheckerParam);
}

template<class ReaderType>
void ReadItem(ReaderType& tReader, const TCHAR* sTitle, bool bCanEmpty, 
							  ReaderType tDefault, FIELD_CHECKER pFunFieldChecker, ReaderType fFieldCheckerParam)
{
	SetItemTitle(sTitle);
	string sValue = g_pTabFile->GetString(g_iLine, sTitle);
	trimend(sValue);
	CheckEmpty(tReader, sValue, bCanEmpty, tDefault);
	if(!sValue.empty())
	{
		SetValue(tReader, sValue);
	}
	CheckField(tReader, pFunFieldChecker, fFieldCheckerParam);
}



template<class EnumType>
void ReadItem(EnumType& tReader, const TCHAR* sTitle, map<string, EnumType, less<string>, 
			  TConfigAllocator<pair<string, EnumType > > >& pFieldMap)
{
	ReadItem(tReader, sTitle, false, EnumType(0), pFieldMap);
}

template<class EnumType>
void ReadItem(EnumType& tReader, const TCHAR* sTitle, bool bCanEmpty,
			  EnumType tDefault, map<string, EnumType, less<string>, 
			  TConfigAllocator<pair<string, EnumType > > >& pFieldMap)
{
	SetItemTitle(sTitle);
	string sValue = g_pTabFile->GetString(g_iLine, sTitle);
	trimend(sValue);
	CheckEmpty(tReader, sValue, bCanEmpty, tDefault);
	if(!sValue.empty())
	{
		CheckField(sValue, pFieldMap);
		SetValue(tReader, sValue, pFieldMap);
	}
}

template<class EnumType1, class EnumType2>
uint32 ReadItem(EnumType1& tReader1, EnumType2& tReader2, const TCHAR* sTitle,
				map<string, EnumType1, less<string>, TConfigAllocator<pair<string, EnumType1 > > >& pFieldMap1, 
				map<string, EnumType2, less<string>, TConfigAllocator<pair<string, EnumType2 > > >& pFieldMap2)
{
	return ReadItem(tReader1, tReader2, sTitle, false, pFieldMap1, pFieldMap2);
}

template<class EnumType1, class EnumType2>
uint32 ReadItem(EnumType1& tReader1, EnumType2& tReader2, const TCHAR* sTitle, bool bCanEmpty, 
				map<string, EnumType1, less<string>, TConfigAllocator<pair<string, EnumType1 > > >& pFieldMap1, 
				map<string, EnumType2, less<string>, TConfigAllocator<pair<string, EnumType2 > > >& pFieldMap2)
{
	SetItemTitle(sTitle);
	string sValue = g_pTabFile->GetString(g_iLine, sTitle);
	trimend(sValue);
	CheckEmpty(tReader1, sValue, bCanEmpty, EnumType1(0));
	if(!sValue.empty())
	{
		if(!InField(sValue, pFieldMap1))
		{
			CheckField(sValue, pFieldMap2);
			SetValue(tReader2, sValue, pFieldMap2);
			return 2;
		}
		else
		{
			SetValue(tReader1, sValue, pFieldMap1);
			return 1;
		}
	}
	return 0;
}

template<typename ReaderType, typename HolderType>
void ReadItem(HolderType* pHolder, ReaderType& tReader, const TCHAR* sTitle, bool bCanEmpty)
{
	SetItemTitle(sTitle);
	string sValue = g_pTabFile->GetString(g_iLine, sTitle);
	trimend(sValue);
	CheckEmpty(tReader, sValue, bCanEmpty, ReaderType(pHolder));
	if(!sValue.empty())
	{
		tReader.SetStringKey(sValue);
	}
}

//InsertMap()
template<class MapType, class CfgNodeType>
bool InsertStringSharedPtrMap(MapType& mapCfg, CfgNodeType* pCfgNode)
{
	pair<typename MapType::iterator, bool> pr = mapCfg.insert(make_pair(pCfgNode->get()->GetName(), pCfgNode));
	if(!pr.second)
	{
		stringstream ExpStr;
		ExpStr << "���ñ�[" << g_sTabName << "]��" << (g_iLine + 1) << "�е�[" << pCfgNode->get()->GetName() << "]�����ظ�";
		GenExpInfo(ExpStr.str());
		//GenErr(ExpStr.str());
		return false;
	}
	return true;
}

template<class MapType, class CfgNodeType>
bool InsertUint32SharedPtrMap(MapType& mapCfg, CfgNodeType* pCfgNode)
{
	pair<typename MapType::iterator, bool> pr = mapCfg.insert(make_pair(pCfgNode->get()->GetId(), pCfgNode));
	if(!pr.second)
	{
		stringstream ExpStr;
		ExpStr << "���ñ�[" << g_sTabName << "��" << g_iLine << "�е�[" << pCfgNode->get()->GetId() << "]ID�ظ�";
		GenExpInfo(ExpStr.str());
		//GenErr(ExpStr.str());
		return false;
	}
	return true;
}

template<class VectorType, class CfgNodeType>
bool InsertSharedPtrVector(VectorType& vecCfg, CfgNodeType* pCfgNode)
{
	uint32 uID = (*pCfgNode)->GetId();
	--uID;
	if(uID < vecCfg.size())
	{
		if(vecCfg[uID])
		{
			stringstream ExpStr;
			ExpStr << "���ñ�[" << g_sTabName << "��" << g_iLine << "�е�[" << uID << "]ID�ظ�";
			GenExpInfo(ExpStr.str());
			return false;
		}
		else
		{
			vecCfg[uID] = pCfgNode;
		}
	}
	else if(uID == vecCfg.size())
	{
		vecCfg.push_back(pCfgNode);
	}
	else
	{
		vecCfg.resize(uID + 1, NULL);
		vecCfg[uID] = pCfgNode;
	}
	
	return true;
}

template<class CfgNodeType>
bool InsertMap(map<string, CfgNodeType*, less<string>, 
			   TConfigAllocator<pair<string, CfgNodeType* > > >& mapCfg, CfgNodeType* pCfgNode)
{
	pair<typename map<string, CfgNodeType*, less<string>, 
		TConfigAllocator<pair<string, CfgNodeType* > > >::iterator, bool> pr = mapCfg.insert(make_pair(pCfgNode->GetName(), pCfgNode));
	if(!pr.second)
	{
		stringstream ExpStr;
		ExpStr << "���ñ�[" << g_sTabName << "]��" << (g_iLine + 1) << "�е�[" << pCfgNode->GetName() << "]�����ظ�";
		GenExpInfo(ExpStr.str());
		//GenErr(ExpStr.str());
		return false;
	}
	return true;
}

template<class CfgNodeType>
bool InsertMap(map<uint32, CfgNodeType*, less<uint32>, 
			   TConfigAllocator<pair<uint32, CfgNodeType* > > >& mapCfg, CfgNodeType* pCfgNode)
{
	pair<typename map<uint32, CfgNodeType*, less<uint32>, 
		TConfigAllocator<pair<uint32, CfgNodeType* > > >::iterator, bool> pr = mapCfg.insert(make_pair(pCfgNode->GetId(), pCfgNode));
	if(!pr.second)
	{
		stringstream ExpStr;
		ExpStr << "���ñ�[" << g_sTabName << "��" << g_iLine << "�е�[" << pCfgNode->GetId() << "]ID�ظ�";
		GenExpInfo(ExpStr.str());
		//GenErr(ExpStr.str());
		return false;
	}
	return true;
}

}//end namespace CfgChk
