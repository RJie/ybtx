--�˽ű���Ϊ����ĳЩ���������������ʱ���ñ��޷����õ���Ϊ��������
QuestGiveUpTbl = {}
QuestGiveUpScript = class()

function QuestGiveUpScript:Ctor()
	self.m_GiveUpDlg = CDelegate:new()
end

function QuestGiveUpScript:OnGiveUpQuest(QuestName,player)
	self.m_GiveUpDlg(QuestName,player)
end

function QuestGiveUpScript:RegistQuestGiveUpOnScript(QuestGiveUpFunc)
	self.m_GiveUpDlg:Add(QuestGiveUpFunc)
end

g_QuestGiveUpScript = QuestGiveUpScript:new()