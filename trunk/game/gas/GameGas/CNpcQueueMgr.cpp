#include "stdafx.h"
#include "CNpcQueueMgr.h"
#include "CNpcQueueMember.h"
#include "CCharacterDictator.h"
#include "TSqrAllocator.inl"

/************************************************************************/
/* �������ͱ�������ң��������£��������£���������*/
/************************************************************************/
CNpcQueueMgr::CNpcQueueMgr()
{
	m_lNpcQueue.push_front(new CNpcQueueMember(-64, 0));	//��
	m_lNpcQueue.push_back(new CNpcQueueMember(63, 0));		//��
	m_lNpcQueue.push_back(new CNpcQueueMember(0, 0));		//��
	m_lNpcQueue.push_back(new CNpcQueueMember(127, 0));		//��
	m_lNpcQueue.push_back(new CNpcQueueMember(-32, 0));		//����
	m_lNpcQueue.push_back(new CNpcQueueMember(95, 0));		//����
	m_lNpcQueue.push_back(new CNpcQueueMember(31, 0));		//����
	m_lNpcQueue.push_back(new CNpcQueueMember(-96, 0));		//����
}

CNpcQueueMgr::~CNpcQueueMgr()
{
	CNpcQueue::iterator iter = m_lNpcQueue.begin();
	for (;iter != m_lNpcQueue.end();)
	{
		delete (*iter);
		iter++;
	}
	m_lNpcQueue.clear();
}

int32 CNpcQueueMgr::AddMemberAndGetAngle(uint32 uEntityID)
{
	CCharacterDictator* pCharacter = CCharacterDictator::GetCharacterByID(uEntityID);
	if(NULL == pCharacter)
		return -1;
	CNpcQueue::iterator iter = m_lNpcQueue.begin();
	for (; iter != m_lNpcQueue.end();)
	{
		if ((*iter)->GetEntityID() == 0 || (*iter)->GetEntityID() == uEntityID)
		{
			(*iter)->SetEntityID(uEntityID);
			return (*iter)->GetAngle();
		}
		iter++;
	}
	return -1;		//�������ʧ��
}

void CNpcQueueMgr::RemoveMember(uint32 uEntityID)
{
	CCharacterDictator* pCharacter = CCharacterDictator::GetCharacterByID(uEntityID);
	if(NULL == pCharacter)
		return;
	CNpcQueue::iterator iter = m_lNpcQueue.begin();
	for (; iter != m_lNpcQueue.end();)
	{
		if ((*iter)->GetEntityID() == uEntityID)
		{
			(*iter)->SetEntityID(0);
			return;
		}
		iter++;
	}
}
