#include "stdafx.h"
#include <afxinet.h>
#include <iostream>
#include <sstream>
#include <process.h>
#include "Ybtx.h"
#include "CNewHttpDownload.h"

void CNewHTTPDownloader::DownloadFile(const wstring& strHostName, 
									  const wstring& strFileName, 
									  const wstring& strDistPath, 
									  int nPriority /* = THREAD_PRIORITY_IDLE */)
{
	m_strHostname = strHostName;
	m_strFileName = strFileName;
	m_strDistPath = strDistPath;
	m_handleCurThread = (HANDLE)_beginthreadex(NULL, 0, &CNewHTTPDownloader::__uis_DownloadFile, this, 0, &m_uCurThreadId);
}

unsigned int __stdcall CNewHTTPDownloader::__uis_DownloadFile(void* pParam)
{
	locale loc = locale::global(locale("")); //Ҫ�򿪵��ļ�·���������ģ�����ȫ��localeΪ���ػ���
	CNewHTTPDownloader* pThis = (CNewHTTPDownloader*)pParam;
	char *pBuf = NULL;
	int nBufLen = 0;
	CInternetSession Sess;
	Sess.SetOption(INTERNET_OPTION_CONNECT_TIMEOUT, 30*1000);
	Sess.SetOption(INTERNET_OPTION_CONNECT_BACKOFF, 1000);
	Sess.SetOption(INTERNET_OPTION_CONNECT_RETRIES, 5);
	wstring strFileUrl = pThis->m_strHostname + L"/" + pThis->m_strFileName;

	//��ȡ��ǰ�ļ��ĳ���
	int nCurrentLength = 0;
	wstring strOutFile = pThis->m_strDistPath + L"/" + pThis->m_strFileName;
	ifstream inFile(strOutFile.c_str(), std::ios::out|std::ios::binary);
	if (inFile.is_open())
	{
		inFile.seekg(0, std::ios::end);
		nCurrentLength = inFile.tellg();
	}
	inFile.close();

	//����http������
	DWORD dwFlags = INTERNET_FLAG_TRANSFER_BINARY;
	
	CHttpFile* pF;
	
	try
	{
		pF = (CHttpFile*)Sess.OpenURL(strFileUrl.c_str(), 1, dwFlags);
	}
	catch(CInternetException* pInternetExcep)
	{
		wchar_t wszError[100];
		switch(pInternetExcep->m_dwError)
		{
		case 12029:
			wsprintf(wszError, L"�޷����ӵ��������ط���������ȷ�������Ƿ�ͨ��(%d)", pInternetExcep->m_dwError);
			break;
		case 12007:
			wsprintf(wszError, L"�޷���ȡ����ϵ�ڷ�������ip��ַ��(%d)", pInternetExcep->m_dwError);
			break;
		default:
			wsprintf(wszError, L"���ز���ʧ�ܡ�����ţ�%d", pInternetExcep->m_dwError);
			break;
		}
		
		pThis->m_pHander->OnError(strFileUrl, wszError);
		return 1;
	}
	if (!pF)
	{
		pThis->m_pHander->OnError(strFileUrl, L"���ز���ʧ��");
		return 1;
	}

	CString str;
	pF->QueryInfo(HTTP_QUERY_STATUS_CODE, str);

	//�ж�http����������ֵ
	if (str!= L"200")
	{
		pF->Close();
		delete pF;
		pThis->m_pHander->OnError(strFileUrl, wstring(strFileUrl + L"�������ص�ַ�Ҳ������ļ�").c_str());	
		return 1;
	}

	//����ƫ��ֵ����ʼ����
	try
	{
		pF->Seek(nCurrentLength, 0);
	}
	catch (CInternetException* pInternetExcep)
	{
		wchar_t wszError[100];
		wsprintf(wszError, L"���ò�������λ��ʱ���������쳣��%d", pInternetExcep->m_dwError);
		pThis->m_pHander->OnError(strFileUrl, wszError);
		return 1;
	}
	pF->QueryInfo(HTTP_QUERY_CONTENT_LENGTH, str);
	pThis->m_pHander->OnStartDownload(strFileUrl);

	if (_wtoi(str))
	{
		wstring strOutFile = pThis->m_strDistPath + L"/" + pThis->m_strFileName;
		
		HANDLE houtFile = CreateFile(strOutFile.c_str(), GENERIC_WRITE, FILE_SHARE_READ, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
		if (INVALID_HANDLE_VALUE == houtFile)
		{
			if (ERROR_ACCESS_DENIED == GetLastError())
			{
				pThis->m_pHander->OnError(strFileUrl, L"�ļ���ռ��");
			}
			else
			{
				pThis->m_pHander->OnError(strFileUrl, wstring(strFileUrl + L"�ļ�������").c_str());
			}
			return 1;
		}
		if (0xFFFFFFFF  == SetFilePointer(houtFile, 0, NULL, FILE_END))
		{
			pThis->m_pHander->OnError(strFileUrl, L"�ļ��޷���λ��ĩβ");
			CloseHandle(houtFile);
			return 1;
		}

		int nLen = (nBufLen = _wtoi(str));
		nLen -= nCurrentLength;
		MSG msg;
		while(true)
		{
			if (PeekMessage(&msg, NULL, 0, 0, PM_REMOVE))
			{
				if (msg.message == WM_USER_DOWNLOAD_SWITCH)
				{
					CloseHandle(houtFile);
					pThis->m_pHander->OnProcess(strFileUrl, 0, nBufLen);
					return 0;
				}
			}
			char* pBuf = new char[8192];
			int n;
			try
			{
				n = pF->Read(pBuf, (nLen < 8192) ? nLen: 8192);
			}
			catch (CInternetException* pInternetExcep)
			{
				CloseHandle(houtFile);
				wchar_t wszError[100];
				wsprintf(wszError, L"���ز���ʱ���������쳣��%d", pInternetExcep->m_dwError);
				pThis->m_pHander->OnError(strFileUrl, wszError);
				return 1;
			}
			if (n<=0)
				break;
			DWORD NumberOfBytesWritten = 0;
			WriteFile(houtFile, pBuf, n, &NumberOfBytesWritten, NULL);
			nLen -= n;
			delete []pBuf;
			pThis->m_pHander->OnProcess(strFileUrl, nBufLen-nLen, nBufLen);
		}
		CloseHandle(houtFile);
		if (nLen != 0)
		{
			pThis->m_pHander->OnError(strFileUrl, L"�벹�����ط������Ͽ�����");
		}
		else{
			pThis->m_pHander->OnFinished(strOutFile);
		}
	}
	return 0;
}

HANDLE CNewHTTPDownloader::GetCurThreadHandle()
{
	return m_handleCurThread;
}

DWORD CNewHTTPDownloader::GetCurThreadId()
{
	return m_uCurThreadId;
}
