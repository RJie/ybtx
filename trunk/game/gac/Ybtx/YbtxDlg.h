#pragma once

#include <string>
#include <vector>
#include <map>
#include <hash_map>

#include "WebBrowser.h"
#include "RegionManage.h"
#include "ImageManage.h"
#include "ImageButton.h"
#include "ImageProgress.h"
#include "ImageLabel.h"
#include "StaticText.h"
#include "afxcmn.h"
#include "FileTreeWalk.h"
#include "StaticText.h"
#include "SelectServerDlg.h"
#include "afxcmn.h"

using namespace std;
using namespace stdext;

class CImageButton;
class CImageProgress;
struct IHTMLDocument2;
class CStarterUpdateHandler;

namespace sqr
{
	class CAsyncUpdater;
	class VersionManager;
	class IAsyncUpdateHandler;
}

class CDownloadHandler;
class CNewHTTPDownloader;

enum DownType
{
	eDT_CheckVersion,
	eDT_VersionList,
	eDT_PatchFile,
	eDT_ServerList,
};

enum DownMode
{
	eDM_NONE,
	eDM_BT,
	eDM_HTTP,
};

struct PatchArgs
{
	sqr::IAsyncUpdateHandler* handler;
	std::wstring              PatchFile;
	std::wstring			  strMsg1;
	std::wstring			  strMsg2;
};

typedef int (* PFN_UPDATAYYVOICE)( const char*, void*, void*, void* ) ;
struct VerifyArgs
{
	sqr::IAsyncUpdateHandler* handler;
	std::wstring              strDirectory;
	std::wstring			  strCheckCodeFileName;
};
class CYbtxDlg : public CDialog
{
public:
	CYbtxDlg(CWnd* pParent = NULL);	
	~CYbtxDlg();
	void	UpdateSelectedServer();
	void	ChangeServer(); 
	wstring GetImagePath( const char* szImageFileName );
	void	ShowSelectServerBtn();

private:
	virtual void DoDataExchange(CDataExchange* pDX);
	virtual BOOL OnInitDialog();

	void ProcessList();
	void ApplyPatch();
	void StartupUpdater();
	void StartupStarter();
	void InitData();
	bool ProcessEntry(const char* szNewTarget);
	void AnalysisServerList();
	void ReadCrcCodeToMap();
	void Crc32Check();
	void DoCrc32Check( const string& strFile );
	void DownloadServerListFile();

	void VerifyFiles();
	static unsigned int __stdcall StartVerifyFiles(void* pClass);// MD5У���߳� 

	static unsigned int __stdcall StartPatch(void* pClass);
	void InitLangPath();
	void InitYY();
	void YYChangeNormalState();
	void ChangeNormalState();
	void CreateInPatchFlag();

public:
	DECLARE_EVENTSINK_MAP()
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();

	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg LRESULT ShowMessage(WPARAM wparam, LPARAM lparam);
	afx_msg LRESULT ChangeDownState(WPARAM wparam, LPARAM lparam);
	afx_msg LRESULT ChangeSetupState(WPARAM wparam, LPARAM lparam);
	afx_msg LRESULT RestartProcess(WPARAM wparam, LPARAM lparam);
	afx_msg LRESULT DownloadFinish(WPARAM wparam, LPARAM lparam);
	afx_msg LRESULT AlertExit(WPARAM wparam, LPARAM lparam);
	afx_msg LRESULT PatchContinue(WPARAM wparam, LPARAM lparam);
	afx_msg	LRESULT DownloadYYFinish(WPARAM wparam, LPARAM lparam);
	afx_msg LRESULT VerifyFilesFinish(WPARAM wparam, LPARAM lparam);
	afx_msg void OnBnClickedButtonSet();
	afx_msg void OnBnClickedButtonQuit();
	afx_msg void OnBnClickedButtonStart();
	afx_msg void OnBnClickedButtonServer();
	afx_msg void OnBnClickedButtonBBS();
	afx_msg void OnBnClickedButtonCharge();
	afx_msg void OnBnClickedButtonRegist();
	afx_msg void OnBnClickedButtonSelectServer();
	afx_msg void OnBnClickedButtonOpenServerItem();
	afx_msg void OnBnClickedButtonManualUpdate();
	afx_msg void OnBnClickedButtonMin();
	afx_msg void OnBnClickedButtonLookChar();
	afx_msg void OnBnClickedButtonOpenDuoWan();
	DECLARE_MESSAGE_MAP()

private:
	enum { IDD = IDD_YBTX_DIALOG };
	HICON m_hIcon;
	CImageLabel   m_LocalVersion;
	CImageLabel   m_OfficialVersion;
	CImageLabel   m_WebBrowser;
	CImageLabel	  m_SelectedServerName;

	CImageButton  m_SetBtn;
	CImageButton  m_QuitBtn;
	CImageButton  m_MinBtn;
	CImageButton  m_StartBtn;
	CImageButton  m_ServerBtn;
	CImageButton  m_bbsBtn;
	CImageButton  m_ChargeBtn;
	CImageButton  m_RegistBtn;
	CImageButton  m_OpenServerItemBtn; 
	CImageButton  m_ManualUpdateBtn;
	CImageButton  m_SelectServerBtn;
	CImageButton  m_LookCharBtn;
	CImageButton  m_OpenDuoWanBtn;

	CImageProgress  m_DownProgress;
	CImageProgress  m_SetupProgress;

	CWebBrowser     m_WebNews;

	CSelectServerDlg m_SelectedServerDlg;

	CRegionManage    m_RegionManage; // ���ι�����
	CImageManage     m_BGImage;      // ͼ�������

	CStarterUpdateHandler*  m_pUpdater;      // ������ʾ�ص������ж��̹߳���
	CDownloadHandler*       m_pDownHandle;   // ���ػص���������ж��̹߳���
	CNewHTTPDownloader*     m_pDownloader;   // http������
	sqr::VersionManager*    m_pVersion;      // �汾������
	PatchArgs*              m_PatchArgs;     // Ϊ���̺߳���������װ��struct

	wstring                 m_strServerInfo; // ��web��õ����ӷ�������Ϣ
	wstring                 m_PatchListFile; // patch�б����غ�ı��ؾ���·��
	wstring                 m_PatchUrl;      // patch���ط�����url
	wstring					m_PatchListUrl;  // patch�б����ط�����url
	wstring                 m_PatchFile;     // patch�ļ���
	wstring                 m_DownloadDir;   // patch���ر��ش��·��
	wstring                 m_StarterFile;   // ������Ybtx.exe����·��
	wstring                 m_UpdaterFile;   // ������Updater.exe����·��
	wstring                 m_StarterPath;   // �����������������Ŀ¼·��
	string                  m_TargetVersion; // ��Ӧ��������Ҫ�İ汾
	DownMode                m_eDownMode;     // ���ز����ķ�ʽ��http, bt��
	wstring                 m_ServerListFile; // �������б��ļ����غ󱾵�·��

	wstring                 m_ServerListUrl; // �������汾�б�����
	wstring                 m_NewsUrl;       // ����ҳ������
	wstring					m_wstrUrlPath;	 // ��IntUrl.ini����ʱ��ȡURL_INI_FILE������ȡINT_URL_INI_FILE

	DownType                m_DownType;      // ��ǰ�����ļ�����
	bool                    m_InUpdate;      // ������...���
	bool                    m_InPatch;       // �ϲ�����...���
	bool                    m_bNeedReload;	//�״��������ñ��
	bool                    m_bChangeTarget; // �Ƿ���;�ı���Ŀ��汾
	hash_map<string, string> m_hmapCrcCode;	 // crc32�ļ�У����
	IHTMLDocument2*			m_pIHTMLDOC;
	CStaticText*			m_pStaticText;
	string					m_strLangResPath;
	string					m_strStaticTxtPath;
	string					m_strOriLangResPath;
	string					m_strOriStaticTxtPath;
	bool					m_InYYUpdate;
	bool					m_InYbtxUpdate;
	
	WCHAR m_szYYFilePath[MAX_PATH]; 
	PFN_UPDATAYYVOICE pfnYYUpdate;
	VerifyArgs*				m_pVerifyArgs;
	bool					m_bNeedMd5Verify;
public:
	virtual BOOL PreTranslateMessage(MSG* pMsg);
};

