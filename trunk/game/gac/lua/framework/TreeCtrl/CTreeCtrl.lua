--- @brief ���������ļ���CTreeCtrl������ݽڵ�
--- @param tree_ctrl Ҫ����ڵ��Ŀ����
--- @param cfg �������ݣ���ʽ�μ������˵��
--- @param [parent_node] ���½ڵ���Ϊ�ýڵ���ӽڵ㣬ȱʡΪ���뵽���ĸ���
--- @return ����Ľڵ��
--[[
-- ����Ϊʵ���������õĸ�ʽ��
tree_config_data=
{
	{text="����", sub={
		{text="����"},
		{text="����"},
		{text="Ƥ��", sub={
			{text="����"},
			{text="ͷ��"},
			{text="�粿"},
			{text="�ز�"},
			{text="�ֲ�"},	
			{text="�Ų�"},
		}}
	}},
	{text="ҩ��", head_img=nil, tail_img=nil, data=nil, param=0}},
	{text="��ʯ"},
	{text="����"},
}
]]

CTreeCtrlNode = class ()

function CTreeCtrlNode.g_AddTreeCtrlNode(tree_ctrl, cfg, parent_node)
	if cfg == nil or type(cfg) ~= "table" then
		return nil
	end
	nodelist = {}
	for i=1, #cfg do
		-- make single node
		local curNode = nil
		if cfg[i].text ~= nil or cfg[i].head_img ~= nil or cfg[i].tail_img ~= nil or cfg[i].data ~= nil or cfg[i].param ~= nil then
			curNode = tree_ctrl:InsertNode(parent_node, cfg[i].text, cfg[i].head_img, cfg[i].tail_img, cfg[i].data, cfg[i].param)
		end
		if curNode == nil then
			curNode = parent_node
		end
		-- make sub nodes
		if cfg[i].sub ~= nil then
			CTreeCtrlNode.g_AddTreeCtrlNode(tree_ctrl, cfg[i].sub, curNode)
		end		
		table.insert(nodelist, curNode)
	end
	return nodelist
end

function CTreeCtrlNode.CTreeCtrl_ClearNode(tree_ctrl)
	for i = 1,tree_ctrl:GetChildNodeCount(tree_ctrl) do
		tree_ctrl:DeleteNode(tree_ctrl:GetFirstChildNode(tree_ctrl))
	end
end