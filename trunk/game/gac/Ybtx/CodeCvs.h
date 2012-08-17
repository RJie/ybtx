/*
* �������õ����ַ���������
*/
#ifndef _CODECVS_H
#define _CODECVS_H

#include <string>
#include <winnls.h>
using namespace std;

// utf16��ʽ���ַ���ת��Ϊutf8��ʽ
string		utf16_to_utf8( const wstring& strSrc );
// utf8��ʽ���ַ���ת��Ϊutf16��ʽ
wstring		utf8_to_utf16( const string& strSrc );
// gbk��ʽ���ַ���ת��Ϊutf16��ʽ
wstring		gbk_to_utf16( const string& strSrc );
// strBig�е�����strSrc�Ӵ���strDst����
void		string_replace( wstring& strBig, const wstring& strSrc, const wstring& strDst );
// ������ñ��ַ�������
wstring		GetSetting( const wchar_t* file, wchar_t* strName, wchar_t* strDefault, wchar_t* dst_path );
// ���õ�ǰĿ¼
void		FixCurrentDir( wchar_t* CurPath );
// ɾ��·��ΪszFilePath���ļ�
bool		TryDeleteFile( const wchar_t* szFilePath, DWORD& dwResult );

#endif
