gac_gas_require "framework/text_filter_mgr/TextFilterMgr"

function InitGasTextFilterMgrTest()
	local TestTest=TestCase("test/testcase/GasTextFilterMgrTest")
	function TestTest:setup()
	end
	
	function TestTest:TestFilterName()
		local textFltMgr = CTextFilterMgr:new()
		assert_equal(false,textFltMgr:IsValidName("ë��"),"")
		assert_equal(false,textFltMgr:IsValidName("��Сƽ"),"")		
		assert_equal(false,textFltMgr:IsValidName("������"),"")
		assert_equal(false,textFltMgr:IsValidName("������"),"")
		assert_equal(false,textFltMgr:IsValidName("GM001"),"")
		assert_equal(false,textFltMgr:IsValidName("GM0012"),"")
		assert_equal(false,textFltMgr:IsValidName("���־"),"")
		assert_equal(false,textFltMgr:IsValidName("��ˮ��"),"")
		
		assert_equal(true,textFltMgr:IsValidName("�⿡"),"")
	end
	
	function TestTest:TestFilterMsg()
		local textFltMgr = CTextFilterMgr:new()
		assert_equal(false,textFltMgr:IsValidMsg("��"),"")
		assert_equal(false,textFltMgr:IsValidMsg("����"),"")		
		assert_equal(false,textFltMgr:IsValidMsg("�Ҳ�����"),"")
		assert_equal(false,textFltMgr:IsValidMsg("�����̵�"),"")
		assert_equal(false,textFltMgr:IsValidMsg("�Ұ�������"),"")
		assert_equal(false,textFltMgr:IsValidMsg("�Ұ�������"),"")
		assert_equal(false,textFltMgr:IsValidMsg("�Ұ��¼ұ�"),"")
		assert_equal(false,textFltMgr:IsValidMsg("ȡ�޷��ֹ�"),"")
		assert_equal(false,textFltMgr:IsValidMsg("���������꣡"),"")
		assert_equal(false,textFltMgr:IsValidMsg("����̨��"),"")
		
		assert_equal(true,textFltMgr:IsValidMsg("���۹�����"),"")
	end
	
	function TestTest:teardown()
	end
	
end