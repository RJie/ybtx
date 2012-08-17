#pragma once
#include <vector>
#include <hash_map>

using namespace std;
using namespace stdext;

struct TABLEFILE_HANDLE
{
	vector<char>				m_vecBuf;
	vector<vector<size_t> >		m_nOffsetByIndex;
	hash_map<string, size_t>	m_nOffsetByName;
};

TABLEFILE_HANDLE& GetTableFileHandle( void* hIniFile );
	
class CTxtTableFile
{
public:
	CTxtTableFile();
	~CTxtTableFile();
	// �����Ʊ���ָ���txt�ļ�
	bool		Load( const char* szFileName );
	// ���
	void		Clear();
	// �õ�����
	int			GetHeight();
	// �õ�����
	int			GetWidth();
	// �����кŵõ�ĳ��ĳ��
	const char* GetString( int nRow, int nColumn );
	// ���������õ�ĳ��ĳ��
	const char* GetString( int nRow, const char* szColumnName );

private:
	void* m_hFileHandle;

};
