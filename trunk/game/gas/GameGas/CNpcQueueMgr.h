#pragma once
#include "CNpcAIMallocObject.h"
#include "TNpcAIAllocator.h"

/************************************************************************/
/*					Npc���й���������Npc������֮������λ��
*/
/************************************************************************/

class CNpcQueueMember;

class CNpcQueueMgr 
	: public CNpcAIMallocObject
{
public:
	CNpcQueueMgr();
	~CNpcQueueMgr();
public:
	int32 AddMemberAndGetAngle(uint32 uEntityID);
	void RemoveMember(uint32 uEntityID);
private:
	typedef list<CNpcQueueMember*, TNpcAIAllocator<CNpcQueueMember*> > CNpcQueue;
	CNpcQueue m_lNpcQueue;
};
