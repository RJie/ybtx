#pragma once
#include "GameDef.h"
#include "CDynamicObject.h"

class CFighterBaseInfo : public virtual CDynamicObject
{
public:
	EClass	CppGetClass() const;
	uint32	CppGetLevel() const;
	ECamp	CppGetBirthCamp() const;
	ECamp	CppGetCamp() const;
	int32	CppGetGameCamp() const;
	bool	CppGetPKState() const;
	//EPKState	CppGetPKState() const;
	//EZoneType	CppGetZoneType() const;

protected:
	CFighterBaseInfo();
	void SetClass(EClass eClass);
	void SetLevel(uint32 uLevel);
	void SetBirthCamp(ECamp eCamp);
	void SetCamp(ECamp eCamp);
	void SetGameCamp(int32 iGameCamp);
	void SetPKState(bool bPKState);
	//void SetPKState(EPKState ePKState);
	//void SetZoneType(EZoneType eZoneType);

private:
	uint32		m_uLevel;		// �ȼ�
	EClass		m_eClass;		// ְҵ
	ECamp		m_eBirthCamp;	// ������Ӫ(ѡ�ú󲻱�)
	ECamp		m_eCamp;		// ��ǰ��Ӫ
	int32		m_iGameCamp;	// �淨���Ӫ
	bool		m_bPKState;		// PK״̬
	//EPKState	m_ePKState;		// PK״̬
	//EZoneType	m_eZoneType;	// �����������ͼ�����
};

