#pragma once

#include "CEnmityMgr.h"

class CCharacterDictator;
class CNpcAI;

/*
* =====================================================================================
*        Class:  CNpcEnmityMgr
*  Description:  Npc��޹�����
* =====================================================================================
*/
class CNpcEnmityMgr 
	: public CEnmityMgr
{
public:

	CNpcEnmityMgr(CNpcAI* pOwner);                /* constructor */
	~CNpcEnmityMgr();                             /* constructor */
	virtual bool JudgeIsEnemy(CCharacterDictator* pTarget);
	virtual void ClearAllEnmity();
}; 
