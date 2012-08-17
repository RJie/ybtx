#pragma once
#include "CTick.h"
#include "TSingleton.h"

class CFightSkillProf 
	: public CTick
	, public TSingleton<CFightSkillProf>
{
	friend class TSingleton<CFightSkillProf>;
public:
	static CFightSkillProf* GetProf();
	void TurnOnFightSkillProf(uint32 uInterval);	//����Ϊ��λ
	void TurnOffFightSkillProf();

private:
	CFightSkillProf();
	virtual ~CFightSkillProf();
	virtual void OnTick();

	ofstream*		m_fstrmProf;
	vector<uint32>	m_vecLastData;	//�����ϴ�tickʱ�����ݣ��Ա�ͳ�Ƹô�tick�к������õĴ���
};
