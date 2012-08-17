gac_gas_require "framework/common/CAlarmClockInc"

--ʵ���������Ϊ�˷��㴦��ϳ��Ĺ̶�ʱ��㶨ʱ������. ��(ÿ�� 3��,  ÿ�� 1, 3, 5 ��8�� �ȵ�֮���ʱ��)
g_AlarmClock = CAlarmClock:new()

g_AlarmClock.m_TaskTbl = {} --��Ҫִ�е������
g_AlarmClock.m_NextTaskTbl = {} -- �´���Ҫִ�е�����
g_AlarmClock.m_NextTime = nil -- �´���Ҫִ�е������ʱ��
g_AlarmClock.m_TaskIndex = 0


local function DiffTime(wday1, time1, wday2, time2)
	if wday1 > wday2 or (wday1 == wday2 and time1 >= time2) then
		wday2 = wday2 + 7
	end
	return (wday2 - wday1) * 24 * 60 * 60 + (time2 - time1)
end


--������ "9:24" ���ַ����л�ȡ��Ե��� 0:00 �㾭��������
local function GetOffsetSecond(strTime)
	if strTime == nil then
		return nil
	end
	local index1 = string.find(strTime, ":")
	assert(index1, "ʱ���ʽ����")
	local index2 = string.find(strTime, ":", index1 + 1) or 0
	local hour = tonumber(string.sub(strTime, 1, index1 - 1))
	local min = tonumber(string.sub(strTime, index1 + 1, index2 -1))
	local sec = 0
	if index2 ~= 0 then
		sec = tonumber(string.sub(strTime, index2 + 1, -1))
	end
	assert(hour and min and sec, "ʱ���ʽ����")
	return (hour * 60 + min) * 60  + sec
end

--��ʱ��ʱ�����
local CTaskDate = class() 

function CTaskDate:NextTime()
end

--�����ظ�ʱ����
local CWeekRepeatDate = class(CTaskDate)

function CWeekRepeatDate:Ctor(date)
	self.wday = {}
	if date.wday and #date.wday ~= 0 then
		for _, w in pairs(date.wday) do
			assert (w >= 1 and w <= 7, "������д����" )
			local wday = (w == 7 and 1 ) or w + 1 -- �����컻�� 1, ����1 ���� 2 ....
			table.insert(self.wday, wday)
		end
	else
		self.wday = {1,2,3,4,5,6,7}    --Ϊ�˴�����֧,ʹ��ͬһ��forѭ��
	end

	self.offset = {}
	for _, s in pairs(date.time) do 
		table.insert(self.offset, GetOffsetSecond(s))
	end 
end

function CWeekRepeatDate:NextTime()
	self.cur_time = self.next_time
	if not self.cur_time then
		self.cur_time = os.time()
	end
	local date = os.date("*t", self.cur_time)
	local curOffset = (date.hour * 60 + date.min) * 60  + date.sec
	local tempDisSec
	local nearTime
	for _ , wday in pairs(self.wday) do
		for _, offset in pairs(self.offset) do
			tempDisSec = DiffTime(date.wday, curOffset, wday, offset)
			if nearTime == nil or tempDisSec < nearTime then
				nearTime = tempDisSec
			end
		end
	end
	self.next_time = self.cur_time + nearTime
	
	--����������Ϊ�� ����ʱ��
	return  self.next_time - os.time()
end


local CTask = class()

function CTask:Ctor(taskName, date, fun, count, arg, argn, index)
	self.name = taskName
	self.fun = fun
	self.count = count
	self.arg = arg
	self.argn = argn
	self.index = index
	if date.type == nil or date.type ==  1 then --Ϊ�˼���ԭ���ĸ�ʽ, ����Ϊnil ��Ĭ����1 ����
		self.task_date = CWeekRepeatDate:new(date)
	else
		assert(false, "Ŀǰ��֧��1���µ� ʱ���ʽ")
	end
end

function CTask:OnTaskTick()
	UnRegisterTick(self.tick)
	self.tick = nil
	self.fun(unpack(self.arg, 1, self.argn))
	
	if self.count then
		self.count = self.count -1
		if self.count <= 0 then
			g_AlarmClock:RemoveTask(self.index)
			return
		end
	end
	
	local time = self.task_date:NextTime()
	self.tick = RegClassTick("AlarmClockTike", self.OnTaskTick, time * 1000, self)
end

function CTask:Start()
	if self.tick then
		return
	end
	local time = self.task_date:NextTime()
	self.tick = RegClassTick("AlarmClockTike", self.OnTaskTick, time * 1000, self)
end

function CTask:Close()
	if self.tick then
		UnRegisterTick(self.tick)
		self.tick = nil
	end
end




--����date��ʽ
--date["time"] = {}  24Сʱ��  ����,����1��  ��ʽ����: {"1:50", "23:00:05"}  hour �� min ������ ����п���
--date["wday"] = {}  ������,�������Ϊnil ��ÿ�� Ҳ�ȼ���{1,2,3,4,5,6,7}  7����������
--date["day"] = {}   Ŀǰû��֧��
--date["month"] = {} Ŀǰû��֧��
function CAlarmClock:AddTask(taskName, date, fun, count, ...)
	local arg = {...}
	local argn = select("#", ...)
	assert(IsFunction(fun) and date and date.time and (not count or count > 0), "CAlarmClock:AddTask ��������")

	local index = self.m_TaskIndex
	self.m_TaskIndex = self.m_TaskIndex + 1
	self.m_TaskTbl[index] = CTask:new(taskName, date, fun, count, arg, argn, index)
	self.m_TaskTbl[index]:Start()
	return index
end


function CAlarmClock:RemoveTask(index)
	self.m_TaskTbl[index]:Close()
	self.m_TaskTbl[index] = nil
end

function CAlarmClock:ClearTick()
	for i, task in pairs(self.m_TaskTbl) do
		task:Close()
		self.m_TaskTbl[i] = nil
	end
end


