#pragma once
#include "GameDef.h"
#include "TConfigAllocator.h"
#include "CConfigMallocObject.h"
#include "CStaticObject.h"

enum EModelClassType
{
	eMCT_None,

	eMCT_Male_Warrior,		//��ʿ��
	eMCT_Male_MagicWarrior,	//ħ��ʿ��
	eMCT_Male_Paladin,		//��ʿ��
	eMCT_Male_NatureElf,		//��ʦ��
	eMCT_Male_EvilElf,		//аħ��
	eMCT_Male_Priest,			//��ʦ��

	eMCT_Female_Warrior,		//��ʿŮ
	eMCT_Female_MagicWarrior,	//ħ��ʿŮ
	eMCT_Female_Paladin,		//��ʿŮ
	eMCT_Female_NatureElf,		//��ʦŮ
	eMCT_Female_EvilElf,		//аħŮ
	eMCT_Female_Priest,			//��ʦŮ

	eMCT_Elf,
	eMCT_Dwarf,			
	eMCT_Orc,
	eMCT_Count,

	eMCT_Male_Human,
	eMCT_Female_Human,
};

class CModelInfoClient
	: public CConfigMallocObject
	, public virtual CStaticObject
{
public:
	static	bool						LoadConfig(const string& szFileName);
	static	void						UnloadConfig();
	static					CModelInfoClient* GetModelInfo(const TCHAR* szName,EClass eclas, ECharSex eSex);
	const TCHAR*			GetPieceName()const						{return	m_strPieceName.c_str();}
	const TCHAR*			GetHidePiece()	const					{return	m_strHidePiece.c_str();}
	const TCHAR*			GetModelFileName()const						{return	m_strModelFileName.c_str();}
	const TCHAR*			GetFXFileName()const						{return	m_strFXFileName.c_str();}
	const TCHAR*			GetStyleName()const						{return	m_strStyleName.c_str();}
private:
	typedef map<pair<string,EModelClassType>, CModelInfoClient*, less<pair<string,EModelClassType> >, TConfigAllocator<pair<pair<string,EModelClassType>, CModelInfoClient*>> >		MapModelInfo;

	typedef map<string, EModelClassType, less<string>, TConfigAllocator<pair<string, EModelClassType*> > >		MapModelClassType;
	static MapModelClassType			ms_mapModelClassType;

	typedef map<EModelClassType, string, less<EModelClassType>, TConfigAllocator<pair<EModelClassType, string> > >		MapModelClassString;
	static MapModelClassString ms_mapModelClassString;

	static string	 ms_strFXPath;

	static void	InitMapClassType()	
	{	
		ms_mapModelClassType["��ʿ��"]				= eMCT_Male_Warrior;
		ms_mapModelClassType["ħ��ʿ��"]				= eMCT_Male_MagicWarrior;
		ms_mapModelClassType["������ʿ��"]			= eMCT_Male_Paladin;
		ms_mapModelClassType["��ʦ��"]				= eMCT_Male_NatureElf;
		ms_mapModelClassType["аħ��"]				= eMCT_Male_EvilElf;
		ms_mapModelClassType["��ʦ��"]			= eMCT_Male_Priest;
		ms_mapModelClassType["��ʿŮ"]				= eMCT_Female_Warrior;
		ms_mapModelClassType["ħ��ʿŮ"]				= eMCT_Female_MagicWarrior;
		ms_mapModelClassType["������ʿŮ"]			= eMCT_Female_Paladin;
		ms_mapModelClassType["��ʦŮ"]				= eMCT_Female_NatureElf;
		ms_mapModelClassType["аħŮ"]				= eMCT_Female_EvilElf;
		ms_mapModelClassType["��ʦŮ"]			= eMCT_Female_Priest;

		ms_mapModelClassType["������ʿ"]				= eMCT_Dwarf;
		ms_mapModelClassType["���鹭����"]				= eMCT_Elf;
		ms_mapModelClassType["����սʿ"]			= eMCT_Orc;

		ms_mapModelClassType["������"]			= eMCT_Male_Human;
		ms_mapModelClassType["����Ů"]			= eMCT_Female_Human;
	}


	static void	InitMapClassString()	
	{	
		ms_mapModelClassString[eMCT_Male_Warrior]				= "rlm/dajian/";
		ms_mapModelClassString[eMCT_Male_MagicWarrior]				= "rlm/mojian/";
		ms_mapModelClassString[eMCT_Male_Paladin]			= "";
		ms_mapModelClassString[eMCT_Male_NatureElf]				= "rlm/fashi/";
		ms_mapModelClassString[eMCT_Male_EvilElf]				= "rlm/xiemo/";
		ms_mapModelClassString[eMCT_Male_Priest]			= "rlm/mushi/";
		ms_mapModelClassString[eMCT_Female_Warrior]				= "rlw/dajian/";
		ms_mapModelClassString[eMCT_Female_MagicWarrior]				= "rlw/mojian/";
		ms_mapModelClassString[eMCT_Female_Paladin]			= "";
		ms_mapModelClassString[eMCT_Female_NatureElf]				= "rlw/fashi/";
		ms_mapModelClassString[eMCT_Female_EvilElf]				= "rlw/xiemo/";
		ms_mapModelClassString[eMCT_Female_Priest]			= "rlw/mushi/";

		ms_mapModelClassString[eMCT_Dwarf]				= "";
		ms_mapModelClassString[eMCT_Elf]				= "";
		ms_mapModelClassString[eMCT_Orc]			= "srm/";
	}

	CModelInfoClient(){}
	CModelInfoClient(const CModelInfoClient* pModelInfoClient);
	void MakeFXFile(EModelClassType eClassType);

	static MapModelInfo		ms_mapModelInfo;

	string						m_strName;
	string						m_strPieceName;
	string						m_strHidePiece;
	string						m_strModelFileName;
	string						m_strFXFileName;
	string						m_strStyleName;
};
