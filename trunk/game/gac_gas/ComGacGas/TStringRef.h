#pragma once
#include <string>
#include <map>
#include <list>

using namespace std;

/*
	TStringRefer��TStringRefee.�߱���string��Ϊ��������refee,����refee�������޸�ʱ֪ͨ��Ӧreferͨ��string��Ϊ����������refeeָ��Ĺ���.
	@referɾ��ʱ��Ҫ֪ͨrefee������refer�б�
	@refeeɾ����ı�ʱ��Ҫ֪ͨrefer����refee

	TStringRefee����Ӧ�������ö����shared_ptr,��ΪTStringRefer��TStringRefee���ڱ����໥����,��Ҫ��������
*/

class IBaseStringRefer
{
public:
	IBaseStringRefer(){}
	virtual ~IBaseStringRefer(){}

	virtual void OnRefeeChanged()const=0;
};

template<typename ImpClass, typename ImpClassSharedPtr>
class TStringRefee
{
public:
	typedef ImpClassSharedPtr					SharedPtrType;
	typedef list<IBaseStringRefer*>				ListStringRefer;
	typedef map<string, ImpClassSharedPtr*>		MapImpClass;

	static MapImpClass& GetImpClassMap();

	const string& GetName()const;
	ListStringRefer::iterator Attach(IBaseStringRefer* pRefer);
	void Detach(ListStringRefer::iterator& it);

	void NotifyRefer()const;

protected:
	TStringRefee();
	~TStringRefee();

private:
	ListStringRefer	m_listRefer;

};

template<typename HolderType, typename RefeeType>
class TStringRefer
	: public IBaseStringRefer
	, public CConfigMallocObject
{
	typedef typename RefeeType::ListStringRefer ListRefer;
	typedef typename RefeeType::SharedPtrType	RefeeSharedPtrType;
public:
	TStringRefer(HolderType* pHolder);
	TStringRefer(HolderType* pHolder, const string& strKey);
	~TStringRefer();
	
	virtual void OnRefeeChanged()const;
	void SetStringKey(const string& strKey);
	void GetStringKey(string& strKey)const;

	const RefeeSharedPtrType& Get()const;
private:
	void ResetRefee();	//���Refeeָ��

	HolderType*						m_pHolder;
	RefeeSharedPtrType				m_spRefee;	//����ֱ�ӱ���Refee��ָ��,��Ҫ����refee��shared_ptr
	typename ListRefer::iterator	m_itReferList;

};
