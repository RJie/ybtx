#pragma once

template <class StateType>
class CBaseStateCfgClient
{

public:
	typedef map<uint32, CBaseStateCfgClient<StateType>*>		MapBaseStateCfgById;

public:
	static bool									LoadConfig(const char* cfgFile);	//�����ñ�
	static void									UnloadConfig();						//ж�����ñ�
	static CBaseStateCfgClient<StateType>*		GetById(uint32 uId);				//��ȡħ��״̬������
	static uint32								GetStateTypeFloor();

private:
	static MapBaseStateCfgById					m_mapCfgById;						//ħ��״̬����ӳ���
public:
	const uint32&	GetId()						{return m_uId;}
	const string&	GetIcon()					{return m_sIcon;}
	const string&	GetModel()					{return m_sModel;}
	const string&	GetFX()						{return m_sFX;}

private:
	uint32			m_uId;						//���
	string			m_sIcon;					//��ӦСͼ��
	string			m_sModel;					//ģ��
	string			m_sFX;						//��Ӧ��Ч

};
	