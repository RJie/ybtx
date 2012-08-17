#pragma once
//--------------------------------------------------
// ��Щ����C++д�Ĵ���Ϸ�߼�����Ĵ���
// ���Խ� ��Ϸ�߼� �� ���������ϲ�����
// EndDuke 09/8/14 -> ���Ĳ�����û�о�������
// ������תͷ��Ϊ����
// ϣ���⼸�����Ժ���Գ�Ϊ ������ϵͳ���ĵĻ����ṹ
//--------------------------------------------------
namespace sqr
{
	class CRenderObject;
}

class CCharacterFollower;


// �������IK���� -> ��Ȥ��ת�������
class CCharacterController 
{
	friend class CCharPartCtrl;
	friend class CHeadController;
	//friend class CSternumController;
	//friend class CCoxalController;
public:
	CCharacterController(CCharacterFollower* pCharacter);
	~CCharacterController();

	void	SetInterestedObj(CCharacterFollower* pTargetObj);	//������Ȥ����
	bool	GetInterestedPos( CVector3f& outVec );			//�����Ȥ��
	void	ClearInterested(bool Imme);							//�����Ȥ
	void	SetCtrlAll(bool isCtrl ) { m_isCtrlAll = isCtrl; };
	bool	IsCtrlAll(void);
	bool	IsHasInterested(void);

protected:
	CCharacterFollower* m_pCharacter;
	CCharPartCtrl*	m_pHeadCtrl;		//ͷ��������
	CCharPartCtrl*	m_pSternumCtrl;		//�ز�������
	CCharPartCtrl*	m_pCoxalCtrl;		//����������

	CVector3f		m_vecInterestedPos;				//��Ȥ��
	bool			m_isHasInterested;				//�Ƿ������Ȥ��
	bool			m_isCtrlAll;	

	uint32 m_uTargetID;

private: //��̬����
	static string st_HeadBoneName;		//ͷ
	static string st_SternumBoneName;	//��
	static string st_CoxalBoneName;		//��
	static string st_TargetBoneName;

	static const float	st_MaxDegree;
	static const float	st_MaxLookDegree;
};

inline bool CCharacterController::IsCtrlAll(void)
{
	return m_isCtrlAll;
}

inline bool CCharacterController::IsHasInterested(void)
{
	return m_isHasInterested;
}