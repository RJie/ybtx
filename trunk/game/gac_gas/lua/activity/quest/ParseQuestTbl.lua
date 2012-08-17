cfg_load "quest/QuestHandBookDescription_Client"
---- ����Quest��
g_QuestHandBookTbl = {}
local function LoadQuestHandBook()
	for _ , i in pairs(QuestHandBookDescription_Client:GetKeys()) do
		local Info = QuestHandBookDescription_Client(i)
		g_QuestHandBookTbl[i] = {}
		if Info ~= nil then
			local tbl = {}
			if Info("AcceptFace") ~= "" then
				tbl.AcceptFace = loadstring("return {" .. Info("AcceptFace") .. "}")()
				tbl.AcceptFaceTime = tonumber(Info("AcceptFaceTime"))
			end
			if Info("FinishFace") ~= "" then
				tbl.FinishFace = loadstring("return {" .. Info("FinishFace") .. "}")()
				tbl.FinishFaceTime = tonumber(Info("FinishFaceTime"))
			end	
			g_QuestHandBookTbl[i] = tbl
		end		
	end
end
LoadQuestHandBook()

AddCheckLeakFilterObj(g_QuestHandBookTbl)
