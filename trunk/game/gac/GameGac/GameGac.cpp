// GacLauncher.cpp : Defines the entry point for the application.
//

#include "stdafx.h"
#include "CScriptAppClient.h"
#include "ExpHelper.h"
#include "CScript.h"
#include "CPathMgr.h"
#include "RegistGacShell.h"
#include "TimeHelper.h"
#include "ErrLogHelper.h"
#include "Module.h"
#include "Memory.h"
#include "AntiDebug.h"
#include "CodeCvs.h"
#include "CAppConfigClient.h"
#include "CodeCvs.h"
#include "CGameClientProxyBank.h"


DEFINITION_OF_OPERATOR_NEW


SQRENTRY int SqrMain(int argc, wchar_t* argv[])
{
	SQR_TRY
	{
#ifdef _WIN32
		wchar_t curPath[MAX_PATH];
		_wgetcwd(curPath, _countof(curPath));

		// ��ʱ���vs2005�ļ�ϵͳ��һ��bug
		wstring dummy_file = wstring(curPath) + L"/___file_fix___";
		vector<FILE*>	fileVec(512, 0);
		for ( int i = 0; i<512; ++i )
		{
			fileVec[i] = _wfopen(dummy_file.c_str(), L"wb");
		}
		for ( int j = 0; j<512; ++j )
		{
			if ( fileVec[j] != 0 )
				fclose(fileVec[j]);
		}
		DeleteFileW(dummy_file.c_str());
#endif
		InitGameClientProxyBank();

		{
			CScriptAppClient Runner("etc/gac/GacConfig.xml","etc/gac/GacSceneConfig.xml");

			CScript* pScript = NULL;
#ifndef _DEBUG
			ConfirmNoDebuger();
#endif

			pScript = Runner.GetMainVM();

			//Ϊ��֧�������д����������԰ѵ�һ���������˵���
			//ͨ�������еĻ�������Ҳ���ݹ�������ͨ��CreateProcess�����Ľ��̾Ϳ��Բ����ݵ�һ������

			ostringstream strm;

			if(argc>1)
			{
				strm<<"g_strSelServerInfo=\""<<utf16_to_utf8(argv[1])<<"\"\n";
			}

			strm<<"g_sSettingPath=\""<<Runner.GetCfgFilePath(NULL)<<"\"\n";

			string sResult;

			sResult=pScript->RunString(strm.str().c_str(),NULL);

			if(!sResult.empty())
			{
				MessageBox(NULL,sResult.c_str(),"error",MB_OK|MB_ICONERROR);
				return 0;
			}

			//ע����Ϸ�߼���c++���뵽lua��

			RegistGacShell(*pScript);

			string gac_path = pScript->GetLoadPath("gac");
			string gac_main = gac_path + string("framework/main_frame/GacMain");
			sResult=Runner.Run( gac_main.c_str() );

			SetErrLogEnabled(false);

			if(!sResult.empty())
			{
				MessageBox(NULL,sResult.c_str(),"error",MB_OK|MB_ICONERROR);
				return 0;
			}
		}
		UnitGameClientProxyBank();
	}
	SQR_CATCH(exp)
	{
		// �������������������~
		LogExp(exp);
	}
	SQR_TRY_END;
	return 0;
}


