engine_require "server/thread/ThreadCoreQuit"	
engine_require "server/thread/ThreadCoreReload"

gac_gas_require "reload/Reload"
	
CScriptThreadHandler=class (IScriptThreadHandler)


--Script�̵߳Ĺر����������ڲ�����ģ��������������ر��̵߳��ź�
--����˴�������Quit�������ǲ���ǿ�йر��̵߳�
function CScriptThreadHandler:OnEndThread()
	g_ThreadApp:Quit()
end

local ReloadFileTbl = {}

function CScriptThreadHandler:OnFileChanged(data)
	local num = data:GetCount()

	for i = 1, num do
		ReloadFileTbl[#ReloadFileTbl + 1] = data:GetFileName(i - 1)
	end
	
	if g_ThreadApp:ReloadFileBegan() then
		print("����reload file�������ٴ�reload")
		return
	end
	
	local function _ReloadFile()
		--�����Ƿ��ܹ�reload��������ɹ���yield
		g_ThreadApp:TryReloadFile()
		
		local num = #ReloadFileTbl
		for i = 1, num do
			local name = ReloadFileTbl[i]
			apcall(ReloadFile, name)
		end
		
		ReloadFileTbl = {}
		
		g_ThreadApp:EndReloadFile()
	end
	
	coroutine.resume(coroutine.create(_ReloadFile))
end
