CSceneMgr = class()

-- m_tbl_MetaScenes �������Ѿ������� MetaScene(��̬����), �� SceneName ����    
CSceneMgr.m_tbl_MetaScene= {}    --�洢��������,��������
CSceneMgr.m_tbl_AreaMetaScene = {} --�洢���򳡾� ����

-- m_tbl_CoreScenes �������Ѿ������� CoreScene(��̬����), �� ID ����
CSceneMgr.m_tbl_Scene = {}
CSceneMgr.m_tbl_CoreSceneIndex = {}

--������������������ݿ�Id, �Ķ������Ȼһ��������ֻ���ز�ͬ�Ĳ���������
--������������id�����ڷ�����id�ǹ̶���,����Ϊ�˷���ÿ��������������һ��������������id(���а�������ƽԭ)
CSceneMgr.m_tbl_MainScene_name = {}   --[1]id [2]name [3]Process [4]serverId
CSceneMgr.m_tbl_MainScene_Id = {} 

