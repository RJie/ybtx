
g_QuestDropItemMgr = {} --g_QuestDropItemMgr[������][�����������Ʒ��].Object(����.Rate)
		                         --Object��ֵΪ�������Ʒ��,Rate��ֵΪ������Ʒ�ĸ���)

g_HideQuestMgr = {} -- ������������Ϊ0(��������)��������� ������Ϊ����

g_RepeatQuestMgr = {} -- �ظ������������� ������Ϊ����

g_QuestNeedMgr = {}--��ʽΪg_QuestNeedMgr[������][������Ҫ����Ʒ��].Num(ֵΪ��Ҫ����Ŀ)

--g_QuestAwardMgr = {}  --��ʽΪg_QuestAwardMgr[������].Must(����Select,ֵΪ{{Itemtype,ItemName,Num},{...},...}
										--MustΪ��ѡ������Ʒ��SelectΪ��ѡ������Ʒ)
g_WhereGiveQuestMgr = {} --��ʽΪg_WhereGiveQuestMgr[������][������]								

g_WhereFinishQuestMgr = {} --��ʽΪg_WhereFinishQuestMgr[������][������]

g_QuestPropMgr = {}

g_AreaQuestMgr = {}

g_MapQuestMgr = {}

g_ItemQuestMgr = {}

g_VarQuestMgr = {}

g_KillNpcQuestMgr = {}

g_QuestToNpcMgr = {}		--ÿ����ɱ�����������,����Ӧ��Ҫɱ��NPC����

g_LearnSkillMgr = {}

g_BuffQuestMgr = {}

g_MercenaryQuestMgr = {}--Ӷ������ķ������(CampType,MapName,MerceQuestType)

g_AllMercenaryQuestMgr = {}--Ӷ������������
g_GeneralMercenaryQuestMgr = {}--�ճ�Ӷ��������� 1��
g_DareMercenaryQuestMgr = {}--��սӶ���������	2,3,4��
g_FewMercenaryQuestMgr = {}--ϡ��Ӷ���������		5��
g_TeamMercenaryQuestMgr = {}--С����Ӷ���������		6,7��
g_AreaMercenaryQuestMgr = {}--����Ӷ���������		8��

g_DareQuestMgr = {}--��ս����

g_ActionQuestMgr = {}--�淨����

g_MasterStrokeQuestMgr = {}--��������

g_QuestShowNpcNameMgr = {} --��ʾ������ص�Npc��

g_LoopQuestMgr = {}	--�ܻ�����

------------------------
--���������Ϊ4����
--1 ��������
--2 Ӷ������
--3 ��ս����
--4 �淨����
-------------------------






--Ϊ����������������Ⱥ�˳����ӵ�����˳��Tbl
g_SortQuestVarMgr = {}

g_GMTimeCountLimit = 1	--GM������ƣ�1���������ʱ���޴ι�����Ч


AddCheckLeakFilterObj(g_QuestDropItemMgr)
AddCheckLeakFilterObj(g_HideQuestMgr)
AddCheckLeakFilterObj(g_RepeatQuestMgr)
AddCheckLeakFilterObj(g_QuestNeedMgr)
AddCheckLeakFilterObj(g_WhereGiveQuestMgr)
AddCheckLeakFilterObj(g_WhereFinishQuestMgr)
AddCheckLeakFilterObj(g_QuestPropMgr)
AddCheckLeakFilterObj(g_AreaQuestMgr)
AddCheckLeakFilterObj(g_MapQuestMgr)
AddCheckLeakFilterObj(g_ItemQuestMgr)
AddCheckLeakFilterObj(g_VarQuestMgr)
AddCheckLeakFilterObj(g_KillNpcQuestMgr)
AddCheckLeakFilterObj(g_QuestToNpcMgr)
AddCheckLeakFilterObj(g_LearnSkillMgr)
AddCheckLeakFilterObj(g_BuffQuestMgr)
AddCheckLeakFilterObj(g_MercenaryQuestMgr)
AddCheckLeakFilterObj(g_AllMercenaryQuestMgr)
AddCheckLeakFilterObj(g_GeneralMercenaryQuestMgr)
AddCheckLeakFilterObj(g_DareMercenaryQuestMgr)
AddCheckLeakFilterObj(g_FewMercenaryQuestMgr)
AddCheckLeakFilterObj(g_TeamMercenaryQuestMgr)
AddCheckLeakFilterObj(g_AreaMercenaryQuestMgr)
AddCheckLeakFilterObj(g_DareQuestMgr)
AddCheckLeakFilterObj(g_ActionQuestMgr)
AddCheckLeakFilterObj(g_MasterStrokeQuestMgr)
AddCheckLeakFilterObj(g_SortQuestVarMgr)
AddCheckLeakFilterObj(g_QuestShowNpcNameMgr)