
CTransportMap = class()

--����ͼѰ·�ڵ����,�ͼ���,���Ծͼ�ʵ����PriorityQueue, �㷨��ֵ��ѧϰ��Ч�ʺܵ�,(������С�����������������).

local CPriorityQueue = class() --ר�Ź�ͼѰ·���õ�, ����ʵ���кܶ�������

function CPriorityQueue:Ctor()
	self.count = 0
	self.dataTbl = {}
end

function CPriorityQueue:push(data, sort_key)
	assert(self.dataTbl[data] == nil,"�����ظ�������ͬ��data")
	self.dataTbl[data] = sort_key
	self.count = self.count + 1
end

function CPriorityQueue:pop(data)  --�ȳ���Ķ��˸�����,��Ϊ�����Ч��
	assert(self.dataTbl[data], "�����ڵ�data")
	self.dataTbl[data] = nil
	self.count = self.count - 1
end

function CPriorityQueue:reset_sort_key(data, new_sort_key)  --��ͼѰ·����ӵ�һ������
	self.dataTbl[data] = new_sort_key
end

function CPriorityQueue:get_sort_key(data)
	return self.dataTbl[data]
end

function CPriorityQueue:top()
	local minData = nil
	for data, sort_key in pairs(self.dataTbl) do
		if minData == nil or sort_key < self.dataTbl[minData] then
			minData = data
		end
	end
	return minData
end

function CPriorityQueue:size()
	return self.count
end

function CPriorityQueue:empty()
	return self.count == 0
end

function CPriorityQueue:clear()
	self.count = 0
	self.dataTbl = {}
end


function CTransportMap:Ctor()
	self.m_AreaTbl = {}
end

function CTransportMap:CreateAreaNode(name)
	local node = {}
	node.Name = name
	node.LinkList = {}
	return node
end

function CTransportMap:CreateLinkInfo(transPos, tranToPos, condition, destNode)
	local linkInfo = {}
	linkInfo.Condition = condition
	linkInfo.DestNode = destNode
	linkInfo.TransPos = transPos
	linkInfo.TransToPos = tranToPos
	return linkInfo
end

function CTransportMap:CheckCondition(ConditionTbl)
	local PlayerLev = g_MainPlayer:CppGetLevel()
	local PlayerCamp = g_MainPlayer:CppGetCamp()
	if ConditionTbl then
		local sQuest = ConditionTbl["Quest"]
		local LeastLev = ConditionTbl["Lev"]
		local Camp = ConditionTbl["Camp"]
		if not IsNumber(LeastLev) or LeastLev == 0 then
			LeastLev = 1
		end
		if sQuest and sQuest ~= "" then
			if not g_GameMain.m_QuestRecordWnd.m_DoingQuestInfo[sQuest] then
				return false
			end
		end
		if PlayerLev < LeastLev then
			return false
		end
		if PlayerCamp ~= Camp and Camp ~= 0 then
			return false
		end
	end
	return true
end

function CTransportMap:AddConnected(beginName, endName, beginPos, endPos, condition)
	if not self.m_AreaTbl[beginName] then
		self.m_AreaTbl[beginName] = self:CreateAreaNode(beginName)
	end
	if not self.m_AreaTbl[endName] then
		self.m_AreaTbl[endName] = self:CreateAreaNode(endName)
	end
	local beginNode, endNode = self.m_AreaTbl[beginName], self.m_AreaTbl[endName]
	local linkInfo = self:CreateLinkInfo(beginPos, endPos, condition, endNode)
	table.insert(beginNode.LinkList, linkInfo)
end

function CTransportMap:ClearMark()
	for name, node in pairs(self.m_AreaTbl) do
		node.FrontStepInfo = nil
	end
end

function CTransportMap:FindTrackStepList(beginName, endName, beginPos, endPos)
	if beginName == endName then --ͬ���� һ���Ϳ��Ե����յ�
		return {{beginName, endPos, beginPos}}
	end
	local beginNode = self.m_AreaTbl[beginName]
	local endNode = self.m_AreaTbl[endName]
	if not beginNode or not endNode then --û�п�ͨ�ķ���
		return 
	end
	self:ClearMark()
	
	local openList = CPriorityQueue:new()
	beginNode.StepCount = 0
	openList:push(beginNode, 0)
	local curNode = nil
	local destNode = nil
	while (not openList:empty()) do
		curNode = openList:top()
		if curNode == endNode then --�ҵ����ٲ��赽Ŀ�������·��
			break
		end
		openList:pop(curNode)
		
		for _, linkInfo in pairs(curNode.LinkList) do
			destNode = linkInfo.DestNode
			if self:CheckCondition(linkInfo.Condition) then
				
				if destNode.FrontStepInfo then --˵��destNode������
					if curNode.StepCount + 1 < destNode.StepCount then --���ָ��̵�·��,���ø��ڵ�
						destNode.FrontStepInfo.Node = curNode
						destNode.FrontStepInfo.LinkInfo = linkInfo
						destNode.StepCount = curNode.StepCount + 1
						openList:reset_sort_key(destNode, destNode.StepCount)
					end
				else
					destNode.FrontStepInfo = {}
					destNode.FrontStepInfo.Node = curNode
					destNode.FrontStepInfo.LinkInfo = linkInfo
					destNode.StepCount = curNode.StepCount + 1
					openList:push(destNode, destNode.StepCount)
				end
				
			end
			
		end
		
	end
	
	if curNode == endNode then
		local stepList = {}
		table.insert(stepList, 1, {endName, endPos, "placeholder"})
		local node = endNode
		local stepInfo = nil
		while node ~= beginNode do
			stepInfo = node.FrontStepInfo
			node = stepInfo.Node
			table.insert(stepList, 1, {node.Name, stepInfo.LinkInfo.TransPos, "placeholder"})
			stepList[2][3] = stepInfo.LinkInfo.TransToPos
		end
		stepList[1][3] = beginPos
		return stepList
	end
	
end

g_CTransportMap = CTransportMap:new()