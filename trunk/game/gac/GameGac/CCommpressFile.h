#pragma once
#include "IGraphic.h"
#include "CStaticObject.h"

using namespace std;

/*
//  ÿ��Block�������ε�
*/
struct tagACFHeader
{
	uint32  dwFlag;            //�ļ���־
	uint32  dwSize;            //�ļ�ͷ��С
	uint32  dwFormat;          //�ļ���ʽ
	uint32  dwWidth;           //ͼƬ���
	uint32  dwHeight;          //ͼƬ�߶�
	uint32  dwLineOffsetCount; //��ƫ������,ÿ��һ��ƫ��
	uint8   byRev[40];         //����
};

struct MapUnit
{
	CPos		Pos;
	ITexture*	pTexture;

	CPos        PosName;
	std::string strName;
};
typedef vector< MapUnit > MapUnits;

class CCommpressFile : public virtual CStaticObject
{
	int32				m_nWidth;
	int32				m_nHeight;
	vector<TCHAR>		m_CommpressData;
public:
	~CCommpressFile()	{ CleanData(); }
	bool				ReadFile( const TCHAR* szInFile, uint8 uSceneID, IGraphic* pGraphic  );
	const vector<TCHAR>&	GetMapData()const{ return m_CommpressData; };
	void				CleanData();
	int32				GetWidth()const{ return m_nWidth; }
	int32				GetHeight()const{ return m_nHeight; }
};