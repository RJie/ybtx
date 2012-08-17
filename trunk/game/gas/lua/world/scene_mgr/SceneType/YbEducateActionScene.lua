gas_require "world/scene_mgr/SceneType/YbEducateActionSceneInc"
--ѵ��������

--�ж��Ƿ��˳��ø�����ɾ��������ʱ��
function CYbEducateActionScene:LeaveScene()
	-- 10���Ӻ�ɾ������	
	local function CloseScene(Tick)
		if self.m_CloseYbActionTick then
			UnRegisterTick(self.m_CloseYbActionTick)
			self.m_CloseYbActionTick = nil
		end
		self:Destroy()
	end
		
	if self.m_MercenaryActionInfo.PlayerOffLine then   								-- 10���Ӻ�ɾ��
		if self.m_CloseYbActionTick then
			UnRegisterTick(self.m_CloseYbActionTick)
			self.m_CloseYbActionTick = nil
		end
		self.m_MercenaryActionInfo.PlayerOffLine = nil
		self.m_CloseYbActionTick = RegisterTick("CloseYBActionTick", CloseScene, 10*60*1000)	
	else																						-- ֱ��ɾ��
		CloseScene(nil, self)
	end
end


function CYbEducateActionScene:OnDestroy()
	CMercenaryRoomCreate.ClearAllTick(self)
	
	if self.m_CloseYbActionTick then
		UnRegisterTick(self.m_CloseYbActionTick)
		self.m_CloseYbActionTick = nil
	end
end

function CYbEducateActionScene:OnPlayerDeadInScene(Attacker, BeAttacker)
	CMercenaryRoomCreate.PlayerDeadInYbActFb(Attacker, BeAttacker)
end

function CYbEducateActionScene:OnPlayerChangeOut(Player)
	CMercenaryEducateAct.ChangeSceneYbActFb(Player, self.m_SceneId)
end

function CYbEducateActionScene:OnPlayerChangeIn(Player)
--	if IsCppBound(Player) then
		CMercenaryEducateAct.IntoYbActFbScene(Player)
		--������������������������¼����󣬼�Ӷ���������
		CScenePkMgr.ChangePkState(Player)
		AddVarNumForTeamQuest(Player, "���������", 1)
		--AddMercenaryLevelCount(Player.m_Conn, "������")
--	end
end

function CYbEducateActionScene:OnPlayerLogIn(Player)
	--����������ж�,����Ϊ������ж��������ʱ
	--�������ʧ�ܵĻ�,������û���������,˵����һ�û�н�������
	--���������,����ִ�н���Ľӿ�,�����ǵ�¼�Ľӿ�
	CScenePkMgr.ChangePkState(Player)
	if self.m_MercenaryActionInfo then
		CMercenaryEducateAct.PlayerLoginYbEducationAction(Player)
	else
		self:OnPlayerChangeIn(Player)
	end
end

function CYbEducateActionScene:OnPlayerLogOut(Player)
	CMercenaryEducateAct.PlayerOffLineYbActFb(Player)
end
