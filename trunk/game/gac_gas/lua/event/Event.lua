gac_gas_require "event/EventInc"
engine_require "common/Misc/TypeCheck"


EEventState.TimeOut = 0
EEventState.Success = 1

--[[

	������������ʵ����һ��waitevent���ƣ���engine\lua\common\CoSync���棬���Ե�ʹ���µ�wait���ƣ�
	����Ϊ�˼���ԭ�ȵĲ��Դ��룬�������ǰ�WaitEvent��SetEvent����ʵ�֡�
	����ͬ����������ʹ��CEvent����Ȼ��ǰʹ�õ���query��������ǰ����queryֻ��һ��item��������CEvent�Ϳ��Դ��棬
	����CEvent�ܹ��ܺõ�ʵ��light���á�
--]]


function WaitEvent(bAll,nTimer,tblEvent)
	assert(not IsNil(bAll) and IsBoolean(bAll))
	assert(IsNil(nTimer) or IsNumber(nTimer))
	assert(not IsNil(tblEvent) and IsTable(tblEvent))
	assert(tblEvent:empty())
		
	if tblEvent.bLight ~= true then
		if nTimer == 0 then
			return {EEventState.TimeOut,{}}
		end
		
		local tblNode = CEvent:new(false)
		tblEvent:push(tblNode)
		
		local value = CCoSync.WaitFor(nTimer, bAll, tblNode)
	
		if value == nil then
			tblEvent:pop()
			return { EEventState.TimeOut,{} }
		else
			return { EEventState.Success,tblEvent.tblRet }
		end
		
	else
		return { EEventState.Success,tblEvent.tblRet } --�����������ֱ�ӷ��سɹ�
	end
	
	
end

function SetEvent( tblEvent, bLight, ...)
	assert(not IsNil(tblEvent) and IsTable(tblEvent))

	--���õ��Ƿ���Ҫ�ȼ��
	if bLight == true then 
		tblEvent.bLight = true
		tblEvent.tblRet = { ... }
	else
		tblEvent.bLight = false
		tblEvent.tblRet = {}
		return
	end
	
	if not tblEvent:empty() then
		local tblNode = tblEvent:front()
		tblEvent:pop()
		tblNode:Set(true)
	end
end

