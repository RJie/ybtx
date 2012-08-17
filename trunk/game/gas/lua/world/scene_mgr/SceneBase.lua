gas_require "world/scene_mgr/SceneBaseInc"
cfg_load "scene/SceneProperty_Server"

--ע�᳡��(����)��
SceneClass = 	{
								[1] = CScene,											--��������          
								[2] = CSingleScene,          --���˸���(����)    
							--[3] = ,                         	--                  
							--[4] = ,                         	--                  
								[5] = CAreaScene,                 --���򸱱�          
								[6] = CTongScene,                 --��ḱ��          
								[7] = CWarZoneScene,              --ս������(����ƽԭ)
								[8] = CTongChallengeScene,        --�����ս����      
							--[9] =  ,                        	--                 
								[10] = CPVPScene,                 --����������  
							--[11] = ,     											--
								[12] = COreAreaScene,            	--�ڿ󸱱�            
								[13] = CGameScene,                --С��Ϸ����       
								[14] = CYbEducateActionScene,     --ѵ��������       
								[15] = CKillYingFengScene,        --ɱ���縱��       
								[16] = CDareQuestScene,           --Ӷ����ս����     
							--[17] = ,                        	--     
								[18] = CScopesExplorationScene,   --���򸱱�(��Ʒ���ᴫ�͵�,�ɶ���)             
								[19] = CSenarioExplorationScene, --���鸱�� 
								[20] = CDaTaoShaScene,            --����ɱ����            
								[21] = CMercenaryMonsterScene,    --Ӷ����ˢ�ֱ�     
								[22] = CDaDuoBaoScene,        		--������ᱦ����   
								[23] = CScopesExplorationScene,   --���򸱱�(����)    
								[24] = CSpecialScopesExplorationScene,   --�������򸱱�     
								[25] = CPublicAreaScene,          --������ͼ����     
								[26] = CRobResScene,           		
								[27] = CBossBattleScene,          --Boss����ս����
								[28] = CDragonCaveScene,         	--��Ѩ�����
							}                                   
                      
function CSceneBase:Init(uSceneId, sSceneName, CoreScene)
	self.m_tbl_Player={}
	self.m_PlayerChangeInTbl = {}
	self.m_SceneId = uSceneId
	self.m_SceneName = sSceneName
	self.m_CoreScene =  CoreScene
	self.m_SceneAttr = g_SceneMgr.m_tbl_MetaScene[sSceneName].Attr
	if self.m_SceneAttr.SceneType == 25 then
		self.m_LogicSceneName = self.m_SceneAttr.BasicName
	else  
		self.m_LogicSceneName = sSceneName
	end   
	self.m_LifeTimeTick = nil
end

--��Ҫ��д�������
function CSceneBase:DestroyOnCloseServer()
	self.m_DestroyOnCloseServer = true
	if not self:IsHavePlayer() then
		g_SceneMgr:DestroyScene(self)
	end
end
        
--�ж��Ƿ��������ø���������(����ֻ�ǻ�������)
function CSceneBase:IfJoinScene(Player)
	--�жϵȼ�����
	local level = Player:CppGetLevel()
	if level < self.m_SceneAttr.LowestLev or level > self.m_SceneAttr.HighestLev then
--		print("���븱���ĵȼ�����������")
		MsgToConn(Player.m_Conn ,10001)
		return false
	end   
	--�ж���Ӫ����
	--[[  
	if self.m_SceneAttr.Camp ~= 0 and Player:CppGetCamp() ~= self.m_SceneAttr.Camp then
--		print("���븱������Ӫ����������")
		MsgToConn(Player.m_Conn ,10001)
		return false
	end
	--]]
	return true
end

function CSceneBase:IsHavePlayer()
	return next(self.m_tbl_Player)
end

--���븱��
function CSceneBase:JoinScene(Player, SceneName)
		--�Ƿ������������
	if not self:IfJoinScene(Player) then
		return nil
	end
	return SceneName
end

function CSceneBase:IsCanDestroy()
	return not self:IsHavePlayer()
end

function CSceneBase:LeaveScene()
	if not self:IsCanDestroy() then
		return
	end
		
	local function DelayDestroy()
		if self.m_DelayDestroyTick then
			UnRegisterTick(self.m_DelayDestroyTick)
			self.m_DelayDestroyTick = nil
		end
		if self:IsCanDestroy() then
			self:Destroy()
		end
	end
	
	local condition = SceneProperty_Server(self:GetSceneType(),"DestroyCondition")
	local delayTime	= SceneProperty_Server(self:GetSceneType(),"DelayDestroyTime")
	if condition == "NoOnlinePlayer" then
		if delayTime == 0 then
			DelayDestroy()
		else
			if self.m_DelayDestroyTick then
				UnRegisterTick(self.m_DelayDestroyTick)
				self.m_DelayDestroyTick = nil
			end
			self.m_DelayDestroyTick = RegisterTick("DelayDestroyScene", DelayDestroy, delayTime * 1000)
			--RegisterOnceTick(self, "DelayDestroyScene", DelayDestroy, delayTime * 1000)
		end
	end
end

function CSceneBase:GetDestroyChannel()
	return self.m_SceneId
end

function CSceneBase:Destroy()
	if not self:IsCanDestroy() then
		return
	end
	
	local function DestroyScene()
		UnRegisterTick(self.m_DestroySceneTick)
		self.m_DestroySceneTick = nil
		if self:IsHavePlayer() or self.m_DestroyNow  then
			return
		end
		self.m_DestroyNow = true
		local SceneId = self.m_SceneId
		local function CallBack()
				g_SceneMgr:DestroyScene(self)
		end
		local destroyContent = SceneProperty_Server(self:GetSceneType(),"DestroyContent")
		if destroyContent == "All" then
			CallDbTrans("SceneMgrDB", "_DeleteScene", CallBack, {SceneId}, self:GetDestroyChannel())
		elseif destroyContent == "Memory" then
			local data = {}
			data["SceneId"] = self.m_SceneId
			data["ServerId"] = 0
			CallDbTrans("SceneMgrDB", "SetSceneServerRpc", CallBack, data, self:GetDestroyChannel())
		end
	end
	
	self.m_Destroying = true                                      
	if next(self.m_PlayerChangeInTbl) then
		if not self.m_DestroySceneTick then
			self.m_DestroySceneTick = RegisterTick("DestroySceneTick", DestroyScene, 25000)
		end
	else
		DestroyScene()
	end
end


function CSceneBase:StopDestroy()
	assert(not self.m_DestroyNow, "����DestroyNow ״̬���޷����� StopDestroy��")
	if self.m_Destroying then
		self.m_Destroying = nil
		if self.m_DestroySceneTick then
			UnRegisterTick(self.m_DestroySceneTick)
			self.m_DestroySceneTick = nil
		end
		self.m_PlayerChangeInTbl = {}
	end
end


function CSceneBase:IsCanChangeIn()
	return not self.m_Destroying
end


function CSceneBase:OnCreate()
	
end

function CSceneBase:OnDestroy()
	
end

function CSceneBase:OnPlayerChangeIn(Player)
	
end

function CSceneBase:OnPlayerChangeOut(Player)
	
end

function CSceneBase:OnPlayerLogIn(Player)
	
end

function CSceneBase:OnPlayerLogOut(Player)
	
end

function CSceneBase:OnPlayerDeadInScene(Attacker, BeAttacker)
end


--��ȡ���Եĺ���
function CSceneBase:GetSceneType()
	return self.m_SceneAttr.SceneType
end

function CSceneBase:GetSceneName()
	return self.m_SceneAttr.SceneName
end

function CSceneBase:GetLogicSceneName()
	return self.m_LogicSceneName
end

function CSceneBase:GetPlayerNum()
	local num = 0
	for i, p in pairs(self.m_tbl_Player) do
		num = num + 1
	end
	return num
end

function CSceneBase:IsMainScene()
	local type = self:GetSceneType()
	return type == 1 or type == 7
end


---------------------����ӿ�----------------------------------------
							
function InitScene(SceneType, uSceneId, sSceneName, CoreScene)
	local scene = SceneClass[SceneType]:new()
	RegOnceTickLifecycleObj("Scene",scene)
	scene:Init(uSceneId, sSceneName, CoreScene)
	return scene
end

--���볡��(����) SceneMgr�е��ô˺���
function JoinScene(Player, SceneName)
	--Player.m_LastSceneId = Player.m_Scene.m_SceneId
	local scenetype = g_SceneMgr.m_tbl_MetaScene[SceneName].Attr.SceneType
	local tempscene = SceneClass[scenetype]:new()
	tempscene:Init(0, SceneName, nil)
	return tempscene:JoinScene(Player, SceneName)
end

--�뿪����(����)  SceneMgr�е��ô˺���
function LeaveScene(Scene, Player)
	apcall(Scene.LeaveScene,Scene,Player)
	if Scene.m_DestroyOnCloseServer and not Scene:IsHavePlayer() then
		g_SceneMgr:DestroyScene(Scene)
	end
end

function GetSceneType( Scene)
	return Scene.m_SceneAttr.SceneType
end




