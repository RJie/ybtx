#pragma once
#include "PatternCOR.h"
#include "CBaseStateServer.h"
#include "CMagicStateCfg.h"
#include "TMagicStateAllocator.h"

class CSkillInstServer;
class CMagicStateMgrServer;
class CMagicStateCategoryServer;
class CFighterDictator;
class CMagicStateServer;
class CMagicStateCascadeDataMgr;
class CAllStateMgrServer;

typedef multimap<const uint32, CMagicStateServer*, less<uint32>,
	TMagicStateAllocator<pair<const uint32, CMagicStateServer*> > >		MultiMapMagicState;
typedef map<CMagicStateCfgServer*, CMagicStateCategoryServer*,
	less<CMagicStateCfgServer*>, TMagicStateAllocator<pair<CMagicStateCfgServer*, CMagicStateCategoryServer*> > >
	MapMagicStateCategory;
typedef map<uint32, CMagicStateServer*, less<uint32>, 
	TMagicStateAllocator<pair<uint32, CMagicStateServer> > >				MapMagicStateByDynamicId;

typedef pair<MultiMapMagicState::const_iterator, MultiMapMagicState::const_iterator> MtMapMagicStatePairItr;
//typedef set<CFighterDictator*>								SetStateTarget;

//ħ��״̬��������ӵ�һ��ħ��״̬
class CMagicStateServer
	: public CBaseStateServer
{
friend class CMagicStateCategoryServer;
friend class CMagicStateMgrServer;
friend class CAllStateMgrServer;

public:
	~CMagicStateServer();
	void							OnTick();								//��ʱ����Ϣ��Ӧ����
	virtual CFighterDictator*		GetOwner();								//��ȡӵ����
	virtual CBaseStateCfgServer*	GetCfg();
	CMagicStateCfgServerSharedPtr&	GetCfgSharedPtr();
	CAllStateMgrServer*				GetAllMgr();

private:

	CMagicStateServer(CSkillInstServer* pSkillInst, CFighterDictator* pInstaller, CMagicStateCategoryServer* pMSCategory);
							//������װ�Ĺ���
	CMagicStateServer(CSkillInstServer* pSkillInst, CMagicStateCascadeDataMgr* pCancelableDataMgr, CMagicStateCascadeDataMgr* pDotDataMgr, CMagicStateCascadeDataMgr* pFinalDataMgr, 
		uint32 uCount, CFighterDictator* pInstaller, CMagicStateCategoryServer* pMSCategory, int32 iTime, int32 iRemainTime);
							//�����ݿ�ָ��Ĺ���
	void					CreateInst(CSkillInstServer* pSkillInst, bool bFromDB = false);
	void					DeleteInst();

	pair<bool, bool>		Cascade(CSkillInstServer* pSkillInst, const uint32& grade, CFighterDictator* pInstaller);			//���Ӳ���
	pair<bool, bool>		Replace(CSkillInstServer* pSkillInst, const uint32& grade, CFighterDictator* pInstaller);			//�滻����
	bool					CascadeFull();							//�����Ƿ񵽶�
	//bool					Start(bool bFromDB = false);			//һ����map��ִ���������
	bool					StartDo();								//����ÿ��ħ��״̬����һ��ʼ��ִ��Ч��
	bool					StartDoFromDB();						//���ڴ����ݿ�ָ�״̬��ִ��Ч��
	bool					EndDo();								//���ڽ���ħ��״̬ʱִ��Ч��
	bool					CancelDo(bool bIgnoreSync = false);		//����ȡ��ħ��״̬��״̬��Ҫ���ɾ����
	bool					CancelDo(uint32 grade);					//���ڰ�����ȡ��ħ��״̬��״̬��ɾ����
	void					StartTime(bool bTimeSet = false);		//��ʼ��ʱ����ʱ
	void					RefreshTime();							//ˢ��ʱ��
	bool					TickLengthStrategy();					//��ʱ�����ǳ��ȷ�ʽ������Ϊ�����ʽ
	bool					TickEnd();								//��ʱ�Ƿ����
	bool					DeleteSelf();							//ɾ���Լ���true��ʾɾ������Category��false��ʾ���������б�Ľ��
	void					PrepareDeleteSelf();					//ɾ���Լ�ǰ�����й���
	void					SetInstaller(CFighterDictator* pInstaller);	//����ʩ���ߣ�����Attach�����ĵ��¼��Ĳ���
	void					ChangeInstaller(CFighterDictator* pInstaller);
	void					DetachInstaller();
	void					CalculateMagicOpArg(CFighterDictator* pInstaller);	//�ڰ�װħ��״̬ʱ�������״̬�е�����Ч���еĸ���ħ�������еĲ���
	pair<bool,bool>			CancelCascade(uint32& count, bool bInCancel);			//ɾ��count��ħ��״̬
	bool					ResetTime();							//����ʱ�䣨��ִ���κ�Ч����
	bool					AddTime(int32 iTime);					//����ʱ��
	int32					GetCalcValue();
	//uint32					GetDynamicId()		{return m_uDynamicId;}

	//uint32					m_uDynamicId;		//ħ��״̬��̬��ţ�������ħ��״̬���ñ����ľ�̬��ţ�
	float					m_fTickCount;		//����ʱ��
	float					m_fTickStep;		//����ʱ��
	uint32					m_uCount;			//ħ��Ч�����Ӵ���������ֵ������
	uint32					m_uShareCount;		//������ӵİ�װ����
	uint32					m_uGrade;			//ħ��״̬��Ӧ���ܵĵȼ�
	MultiMapMagicState::iterator	m_mtmapMSItr;	//�Լ��ڱ�ħ��״̬�����map��λ��
	CMagicStateCategoryServer*	m_pMSCategory;		//������ħ�����࣬����ħ��״̬��ֱ�����������ڻ�ȡm_uGrade

	int32					m_iCascadeMax;		//��������
	CSkillInstServer*				m_pCancelableInst;	//���ڴ洢�ɳ���ħ��Ч���м�����MagicStateInst
	CSkillInstServer*				m_pDotInst;			//���ڴ洢���ħ��Ч���м�����MagicStateInst
	CSkillInstServer*				m_pFinalInst;		//���ڴ洢����ħ��Ч���м�����MagicStateInst
	CMagicStateCascadeDataMgr*		m_pCancelableDataMgr;
	CMagicStateCascadeDataMgr*		m_pDotDataMgr;
	CMagicStateCascadeDataMgr*		m_pFinalDataMgr;
	bool					m_bCancellationDone;		//��ʾ������ִ��
};


