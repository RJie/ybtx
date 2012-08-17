
Event =
{
	-- ��������ʹ�õ�Event
	Test =
	{
		LoginBegan			= CQueue:new(),
		LoginEnded			= CQueue:new(),
		RCPBegan			= CQueue:new(),
		RCPRecv				= CQueue:new(),
		RCPEnded			= CQueue:new(),
		QuestReceived         = CQueue:new(),
		CharListReceived	= CQueue:new(),
		DelCharListReceived  = CQueue:new(),
		CreateCharEnded		= CQueue:new(),
		DeleteCharEnded		= CQueue:new(),
		GasCreatePlayerEnded= CQueue:new(),
		
		EnterGame			= CQueue:new(),
		Game2LoginEnded 	= CQueue:new(),
		
		ShopOpened 			= CQueue:new(),
		ShopClosed 			= CQueue:new(),
		
		BankOpened 			= CQueue:new(),
		BankClosed 			= CQueue:new(),
		SetLevel				= CQueue:new(),
		
		--GM related
		GMRunScriptDone	=	CQueue:new(),
		
		--��Ʒ����
		AddItem 			= CQueue:new(),
		DelItem  			= CQueue:new(),
		AddSoul				= CQueue:new(),
		ReplaceItem 		= CQueue:new(), 
		MoveItem  			= CQueue:new(),
		SplitItem  			= CQueue:new(),
		PlaceBag  			= CQueue:new(),
		Change2Bag  		= CQueue:new(),
		FetchBag	 		= CQueue:new(),
		QuickMove  			= CQueue:new(),
		DelBag  			= CQueue:new(),
		UseItem 			= CQueue:new(),
		SetAddCount =  CQueue:new(),
		--װ������
		FetchEquip 		= CQueue:new(),
		ReplaceRing   = CQueue:new(),
		Switch2Ring   = CQueue:new(),
		--��Ǯ����
		AddMoneyGM  		= CQueue:new(),
		AddTicketGM  		= CQueue:new(),
		AddBindingMoneyGM = CQueue:new(),
		AddBindingTicketGM = CQueue:new(),
		
		--������ͨ
		OpenChangeMoneyWnd = CQueue:new(),
		
		-- Message
		MsgToClient  		= CQueue:new(),
		
		-- Object
		ObjectCreated		= CQueue:new(),
		ObjectDestroied = CQueue:new(),
		TrapCreated			=	CQueue:new(),
		CollObjCreated	= CQueue:new(),
		
		-- Player
		PlayerCreated 		= CQueue:new(),	
		PlayerDestroied		=	 CQueue:new(),
		PlayerMoveEnded  	= CQueue:new(),
		PlayerSkillEnded  	= CQueue:new(),
		NpcEnterAoi			= CQueue:new(),
		PlayerInfo			= CQueue:new(),
		PlayerSetLevel      = CQueue:new(),
		
		-- Scene
		SceneCreated		=	CQueue:new(),
		SceneDestroied	=	CQueue:new(),
		
		-- Npc
		NpcSkillEnded = CQueue:new(),
		NpcDead				= CQueue:new(),
		NpcPosChanged = CQueue:new(),
		
		--NPC�̵�
		OpenNpcSellWnd = CQueue:new(),
		ChangedMoneyCount = CQueue:new(),
		RetPlayerSoldGoodsEnd  = CQueue:new(),
		
		--Bullet
		BulletHit			= CQueue:new(),
		
		--�ʼ���ϵͳ
		OpenEmailWnd =  CQueue:new(),
		SendEmailEnded = CQueue:new(),
		GetEmailEnded = CQueue:new(), 
		GetEmailListEnded = CQueue:new(),
		DeleteMailEnded = CQueue:new(),
--  TakeAttchmentEnded = CQueue:new(),
		--����Ƕ��ʯ
		OpenHole = CQueue:new(),
		InlayStone = CQueue:new(),
		RemovalStone = CQueue:new(),
		SendAllHoleInfoEnd = CQueue:new(),
		ReturnSynthesisItemEnd = CQueue:new(),
		RetStoneAppraise = CQueue:new(),
		RetTakeAppraisedStone = CQueue:new(),
		
		--�����츳���
		AddTalent= CQueue:new(),
		--�����װ�� 
		SoulInEquip= CQueue:new(),
		--װ��������
		--AddSoul = CQueue:new(),

		--����ӳ��
		SetKeyMapEnd = CQueue:new(),
		SendAllKeyMapsEnd = CQueue:new(),
		
		--��Ʒʰȡ
		SetPickupItem = CQueue:new(),
		ShowPickupItem = CQueue:new(),
		
		--��½
		FinishedLoading = CQueue:new(),
		AfterMoveCameraTick = CQueue:new(),--������ɫʱ��ѡ��ĳ��ְҵģ�ͺ��ƶ�camera
		BackToLoginFinished = CQueue:new(),
		SelectRoleState = CQueue:new(),
	},

}
