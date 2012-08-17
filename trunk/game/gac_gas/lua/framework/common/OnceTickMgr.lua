 --�е�RegisterOnceTick ʱ�� LifecycleObj ��Ҫȫ�ֵľ�ʹ��g_App, 
--����ʹ��С������������Ķ��� �� scene, npc, obj, playe ֮���

local function OnOnceTickFun(tick, ...)
	--print("OnOnceTickFun,  tickId Ϊ:",  tick.m_Index)
	tick.m_LifecycleObj.m_OnceTickTbl[tick.m_Index] = nil
	UnRegisterTick(tick)
	tick.m_SourceFun(...)
end

local OnceTickIndex = 1
function RegisterOnceTick(LifecycleObj , TickName, TickFun, TickTime, ...)
	assert(LifecycleObj and LifecycleObj.m_OnceTickTbl, "������󻹲�֧�� ע��oncetick")
	local tick = RegisterTick(TickName, OnOnceTickFun, TickTime, ...)
	tick.m_SourceFun = TickFun
	tick.m_LifecycleObj = LifecycleObj
	tick.m_Index = OnceTickIndex
	LifecycleObj.m_OnceTickTbl[OnceTickIndex] = tick

	OnceTickIndex = OnceTickIndex + 1
end

function RegOnceTickLifecycleObj(name, LifecycleObj)
	assert(LifecycleObj.m_OnceTickTbl == nil, name .. "  �ظ�ע��ΪOncetick�ĳ�����")
	LifecycleObj.m_OnceTickTbl = {}
	--print(" ע��Oncetick�ĳ�����: " .. name)
	--LifecycleObj.m_OnceTickName = name
	--RegMemCheckTbl( name.. ".m_OnceTickTabl", LifecycleObj.m_OnceTickTbl)
end

function UnRegisterObjOnceTick(LifecycleObj)
	--print(LifecycleObj.m_OnceTickName .. " ���������ڵ���, ע����������onceTick")
	for index, tick in pairs(LifecycleObj.m_OnceTickTbl) do
		--print("tick���ҵĶ��������ڽ��� , ע��δ��ɵ�tick   id:", index)
		UnRegisterTick(tick)
		LifecycleObj.m_OnceTickTbl[index] = nil
	end
end