// CGameSet.cpp : implementation file
//

#include "stdafx.h"
#include "Ybtx.h"
#include "GameSet.h"

#include "StringProcess.h"

using namespace std;


//#ifdef _DEBUG
//#define  TRUNK_TO_BIN      "/bin/Debug"
//#else
#define  TRUNK_TO_BIN      L"/bin/Release"
//#endif

#define  GRAPHIC_SECTION   L"Graphic"
#define  RELATIVE_DIR_INI  L"/var/gac/setting.ini"

#define  BIN_DIFF_TRUNK_LEVEL  2
#define  SET_LEN  256
#define  PATH_LEN 4096




// CGameSet dialog

IMPLEMENT_DYNAMIC(CGameSet, CDialog)

CGameSet::CGameSet(CWnd* pParent /*=NULL*/)
	: CDialog(CGameSet::IDD, pParent)
{
}

CGameSet::~CGameSet()
{
}

void CGameSet::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);

	// ȡ�������ļ�·��
	wchar_t szCurDir[PATH_LEN];
	wchar_t szIniFileDir[PATH_LEN];
	memset(szCurDir, 0, sizeof(szCurDir));
	memset(szIniFileDir, 0, sizeof(szIniFileDir));
	GetCurrentDirectoryW(PATH_LEN, szCurDir);

	EX_ReplaceChar(szCurDir, L'\\', L'/');
	EX_GetSubDir(szCurDir, szIniFileDir, BIN_DIFF_TRUNK_LEVEL); // ȡ��trunkĿ¼
	wcscat_s(szIniFileDir, RELATIVE_DIR_INI);

	m_strIniFileDir = wstring(szIniFileDir);

	// ���ÿؼ���ֵ
	int ScreenWidth = GetPrivateProfileInt(GRAPHIC_SECTION, L"ScreenWidth", 800, m_strIniFileDir.c_str());
	int ColorDepth  = GetPrivateProfileInt(GRAPHIC_SECTION, L"ColorDepth", 32, m_strIniFileDir.c_str());
	int FullScreen  = GetPrivateProfileInt(GRAPHIC_SECTION, L"FullScreen", 0, m_strIniFileDir.c_str());

	m_ResolveComb = (CComboBox*)GetDlgItem(IDC_COMBO_RESOLVE);
	m_ColorBitComb = (CComboBox*)GetDlgItem(IDC_COMBO_COLORBIT);
	m_ShowModeComb = (CComboBox*)GetDlgItem(IDC_COMBO_SHOWMODE);

	m_ResolveComb->AddString(L"800��500");
	m_ResolveComb->AddString(L"1024��640");
	m_ResolveComb->AddString(L"1280��800");
	if(ScreenWidth == 1024)
		m_ResolveComb->SetCurSel(1);
	else if(ScreenWidth == 1280)
		m_ResolveComb->SetCurSel(2);
	else
		m_ResolveComb->SetCurSel(0);

	m_ColorBitComb->AddString(L"16λ");
	m_ColorBitComb->AddString(L"32λ");
	if(ColorDepth == 16)
		m_ColorBitComb->SetCurSel(0);
	else
		m_ColorBitComb->SetCurSel(1);

	m_ShowModeComb->AddString(L"����ģʽ");
	m_ShowModeComb->AddString(L"ȫ��ģʽ60Hz");
	m_ShowModeComb->AddString(L"ȫ��ģʽ75Hz");
	if(FullScreen == 60)
		m_ShowModeComb->SetCurSel(1);
	if(FullScreen == 75)
		m_ShowModeComb->SetCurSel(2);
	else
		m_ShowModeComb->SetCurSel(0);
}


BEGIN_MESSAGE_MAP(CGameSet, CDialog)
	ON_BN_CLICKED(IDOK, &CGameSet::OnBnClickedOk)
END_MESSAGE_MAP()


// CGameSet message handlers

void CGameSet::OnBnClickedOk()
{	
	// ��ȡ�����ļ�
	wchar_t SelectedText[SET_LEN];
	wstring strSelected;
	size_t nPos;

	// �ֱ���
	m_ResolveComb->GetLBText(m_ResolveComb->GetCurSel(), SelectedText);
	strSelected = wstring(SelectedText);
	nPos = strSelected.find(L"��");

	WritePrivateProfileString(GRAPHIC_SECTION, L"ScreenWidth", strSelected.substr(0,nPos).c_str(), m_strIniFileDir.c_str());
	WritePrivateProfileString(GRAPHIC_SECTION, L"ScreenHeight", strSelected.substr(nPos+2).c_str(), m_strIniFileDir.c_str());

	// ��ɫ���
	m_ColorBitComb->GetLBText(m_ColorBitComb->GetCurSel(), SelectedText);
	strSelected = wstring(SelectedText);

	WritePrivateProfileString(GRAPHIC_SECTION, L"ColorDepth", strSelected.substr(0, strSelected.length()-2).c_str(), m_strIniFileDir.c_str());

	// ˢ����
	m_ShowModeComb->GetLBText(m_ShowModeComb->GetCurSel(), SelectedText);
	strSelected = wstring(SelectedText);
	if(strSelected.find(L"60") != -1)
		WritePrivateProfileString(GRAPHIC_SECTION, L"FullScreen", L"60", m_strIniFileDir.c_str());
	else if(strSelected.find(L"75") != -1)
		WritePrivateProfileString(GRAPHIC_SECTION, L"FullScreen", L"75", m_strIniFileDir.c_str());
	else
		WritePrivateProfileString(GRAPHIC_SECTION, L"FullScreen", L"0", m_strIniFileDir.c_str());

	OnOK();
}
