#include "stdafx.h"
#include "CppGameClient.h"
#include "LoadVariantCfgCommon.h"
#include "CScriptAppClient.h"
#include "CCoreObjectFollower.h"

bool CppGameClientInit()
{
	LoadVariantCfgCommon(CCoreObjectFollower::GetVarDefCfg(), "game/gac_gas/xml/");
	
	return true;
}

bool CppGameClientClear()
{
	return true;
}

#define MAX_CLIENT_NUM 8
int GetRandomOneStepLoginIndex()
{
#ifndef _WIN32
	return -1;
#endif
	string MutexName = "OneStepLoginMutexIndex";
	for (int i = 1; i < MAX_CLIENT_NUM; ++i){
		TCHAR ch_idx = '0' + i;
		std::string tmpMutexName = MutexName + ch_idx;
		HANDLE hMutex = CreateMutex(NULL, FALSE, tmpMutexName.c_str());
		if (NULL == hMutex)
		{
			return -1;
		}
		DWORD dw = WaitForSingleObject(hMutex, 0);
		if (WAIT_FAILED == dw)
		{
			CloseHandle(hMutex); // �ͷž������ָ��ͬһϵͳ��������о���ͷź󣬸ö��󽫱�ɾ����
			return -1;
		}
		else if (WAIT_TIMEOUT == dw)
		{
			// ����һ��ʵ����������
			CloseHandle(hMutex);
			continue;
		}
		return i;
	}
	return 0;
}

