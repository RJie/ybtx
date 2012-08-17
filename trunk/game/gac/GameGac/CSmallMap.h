#pragma once
#include "CCommpressFile.h"
#include "SQRWnd.h"
#include "CCoreObjectFollower.h"
#include "GameDef.h"
#include "SQRButton.h"
#include "CTick.h"
#include "CElementManager.h"

class MAPROLE
{
	map<CCoreObjectFollower*,WND_IMAGE_LIST*>	m_aRoleInfo;
public:
	MAPROLE();

	~MAPROLE();

	const map<CCoreObjectFollower*,WND_IMAGE_LIST*>& GetRoleInfo()const
	{
		return m_aRoleInfo;
	}
	size_t Size()const
	{
		return m_aRoleInfo.size();
	}

	bool PushItem(CCoreObjectFollower* Obj)
	{
		map<CCoreObjectFollower*,WND_IMAGE_LIST*>::iterator it = m_aRoleInfo.find(Obj);
		if(it==m_aRoleInfo.end())
			return m_aRoleInfo.insert( pair<CCoreObjectFollower*,WND_IMAGE_LIST*>(Obj, new WND_IMAGE_LIST) ).second;
		return true;
	}

	bool DelItem(CCoreObjectFollower* Obj);

	WND_IMAGE_LIST& operator[](CCoreObjectFollower* Obj)
	{
		return *m_aRoleInfo[Obj];
	}
};

class MapImageData : public SQRGuiMallocObject
{
public:
	UIString	imageStrInfo;
	int32		imageHeight;
	int32		imageWidth;
	void InitMapImageData(const string& imageStrInfo, int32 imageHeight, int32 imageWidth);
};
//--------------------------------------------------------------------------------------------
class CSmallMapTex : public CElementNode
{
	friend class CSmallMapCoder;
public:
	CSmallMapTex(CElementManager* pParent , URegionID id);
	~CSmallMapTex();
	ITexture*		GetTexture(void);
	uint32			GetXRegion(void);
	uint32			GetYRegion(void);
protected:
	ITexture*	m_MapText;
	uint32		m_uX;
	uint32		m_uY;
};

inline ITexture* CSmallMapTex::GetTexture(void)
{
	return m_MapText;
}

inline 	uint32 CSmallMapTex::GetXRegion(void)
{
	return m_uX;
}

inline  uint32 CSmallMapTex::GetYRegion(void)
{
	return m_uY;
}
class CCharacterFollower;

class CSmallMap : 
	public sqr::SQRWnd, 
	public CTick,
	public CElementManager
{
	DYNAMIC_DECLARE_WND( CSmallMap )
public:
	enum EMapRoleType
	{ 
		eMRT_None = -1,
		eMRT_EnemyNpc, 
		eMRT_FriendNpc , 
		eMRT_TeamMate , 
		eMRT_EnemyPlayer ,	
		eMRT_FriendPlayer ,	
	};

	static const double MapRotateRadian;	///< ��ͼƫת�ĽǶ�
	static const uint32	st_uRegionScale;
	static const uint32 st_uCenterId;
	static const uint32 ms_uImageSize;

public:
	CSmallMap();
	virtual ~CSmallMap(void);
	void SetScale(float fScale);
	void InitData( uint8 uHorBlocks, uint8 uVerBolcks, uint8 uPiecesPerBlock, uint8 uPiecesSize, bool bBigMap = false );
	void DrawWndBackground();
	int32 DestroyWnd();
	void ClearUp();

	/// @brief ��ʼ����ͼ����
	virtual void InitMapData( const TCHAR* szMapFile, uint8 uSceneID );
	virtual	void SetPlayerPos( const CVector3f& pos );
	/// @brief �õ�npc��������ҵ���Ϣ
	void ReceiveRoleData( CCoreObjectFollower* Obj, uint8 nType );
	bool RemoveRoleData( CCoreObjectFollower* Obj );
	void SetSmallMapWnd(SQRWnd * pWnd);
	void SetPlayerTex();
	void ClearAllNpcAndPlayerInfo();
	void ClearNpcOrPlayerInfoByID(uint32 followerID);
	void SetNpcOrOtherPlayerInfo(const CFPos &pos, const string &name, EMapRoleType type, SQRButton* btn, uint32 followerID);//�������Ƿ�Χ�ڵ�npc����ң�����ʾ��С��ͼ��
	/// @brief ���õ�ǰ��������Ϣ
	/// @param �������
	/// @param �����߶�
	/// @param ��ͼ��ʱ����ת�ĽǶȣ�����45��
	/// @param С��ͼ�ļ�������
	/// @param ������ID
	void SetSceneData( uint32 nWidthInGrid, uint32 nHeightInGrid, float fCWRotDeg, const TCHAR* szMapFile, uint8 uSceneID );
	/// @brief ��������
	void DrawMainPlayer();
	void SetPlayerDir(float x, float y);//{ m_MainPlayerDirection = CVector2f(x, y); }
	void SetMainPlayerPixelPos(float x, float y);
	CCommpressFile* GetMapFileData(){ return NULL; }
	//����NPC���������
	void DrawFollower();
	void SetMainPlayer(uint32 uMainPlayerID);
	void AddEntity(uint32 uGameEntityID,const char* szCharName, EMapRoleType eRoleType);
	void ChangeEntityImageType(uint32 uGameEntityID,EMapRoleType eRoleType);
	void RemoveEntity(uint32 uObjID); 
	void AddShowRoleType(uint32 uRoleType);
	void RemoveShowRoleType(uint32 uRoleType);
	void InitNpcAndPlayerImageData();
	void OnTick();
	CElementNode* _CreateNode( URegionID ID );
protected:
	CIRect		m_rcPiece;
	MAPROLE		m_aRoleInfo[eMR_Count];		///< ��ɫ��Ϣ
	SQRWnd		*m_pWnd;
	SQRWnd		*m_pMainPlayerWnd;
	SQRWnd		*m_pCenterBtn;
	//
	CVector2f   m_MainPlayerDirection;		///< ���ǵķ���
	CVector2f	m_MainPlayerPosition;		///< ����λ�ã�����Ϊ��λ��
	//ITexture*	m_MapTexture[3][3];			///< ��ͼ����ͼƬ
	CVector2I	m_Test[3][3];
	float       m_fScale;					///< ��ͼ����ϵ��
	// ������Ϣ
	uint32      m_nWidthInPixel;			///< ������ȣ�����Ϊ��λ��
	uint32      m_nHeightInPixel;			///< �����߶ȣ�����Ϊ��λ��
	float       m_fCWRotRad;				///< ��ͼ��ʱ����ת����

	CRenderTexture*				m_pBackTexture;
	sqr::CElementCoderEx*		m_pCoderEx;
	//�����õı���
 	CFRect		m_wndRect;
 	CVector2f	m_dest[4];
	CVector2f	m_BackTexUV[4];
	uint32		m_XRegion;
	uint32		m_YRegion;
	string		m_SceneName;
	uint32		m_MaxWidth;
	uint32		m_MaxHight;
	CVector2f	m_Rect[3][3][4];
	float		m_fDeltaX;
	float		m_fDeltaY;
	float		m_fCenterX;
	float		m_fCenterY;
	float		m_fBlockWidth;
	float		m_fBlockHeight;
	uint32	m_uDirectorID;
	static UIVector<MapImageData> ms_vecImageType;
	typedef UIMap<uint32, pair< SQRButton*, EMapRoleType> > MapFollowerBtn;
	MapFollowerBtn m_mapFollowerMapBtn;
	UISet<uint32> m_setShowRoleType;
private:
	void SetRoleTex( WND_IMAGE_LIST* pItem, EMapRole eRole );
	void DrawSmallMap();
	void GetMainPlayerBtnPos(int32& xPos, int32& yPos);
	uint32 GetRoleType(CCharacterFollower* pRole);
	bool IsNeedUpdatePlayerPos(SQRButton* pBtn ,const CFPos &Pos);
	SQRButton* CreateBtn(const char* szName);
	void SetBtnImage(SQRButton* pBtn, const char* szImageInfo);
	void SetBtnRect(SQRButton* pBtn, const CFPos Pos,int32 ImageWidth, int32 ImageHeight);
	void GetOtherObjBtnPos(const CFPos pos, int32 &XPos, int32 &YPos);
};