cfg_load "image_res/TeamMarkImage_Common"

CTeamMarkSign    = class (CRenderDialog)
CTeamMarkSignMgr = class ()

------���Ŀ���ͷ����Ϣ������------
function CreateTeamMarkSign(Character, heigth)
	local Wnd = CTeamMarkSign:new()
	Wnd:CreateFromRes( "WndHeadSign", g_GameMain )
	Wnd:ShowWnd(true)
	Character:GetRenderObject():AddChild( Wnd, eLinkType.LT_SKELETAL, "Bip01 Spine" )
	Wnd.m_Heigth = heigth
	Wnd:SetRenderWndHeight(heigth)
	return Wnd
end

------���±��Ŀ���ͷ����Ϣ------
function CTeamMarkSign:UpdateTeamMarkWnd(TeamMarkType)
	self:ShowWnd( not (0 == TeamMarkType) )
	if(0 == TeamMarkType) then return end
	local Flag = IMAGE_PARAM:new()
	Flag.CtrlMask = SM_BS_BK
	Flag.StateMask = IP_ENABLE
	local DefaultImage = WND_IMAGE_LIST:new()
	local sPath = TeamMarkImage_Common(TeamMarkType, "ImagePathEnable")
	DefaultImage:AddImage( self:GetGraphic(), -1, sPath, nil, CFPos:new(), "0xffffffff", 0 )
	self:SetWndBkImage( Flag, DefaultImage )
end

--����ͷ����Ϣ�ĸ���
function CTeamMarkSignMgr:PlayerHeadTeamMarkInit()
	if(not g_MainPlayer.m_TeamMarkWnd or not IsCppBound(g_MainPlayer.m_TeamMarkWnd)) then
		g_MainPlayer.m_TeamMarkWnd = CreateTeamMarkSign(g_MainPlayer, 260)
	end
	self:UpdatePic(g_MainPlayer)
end

function CTeamMarkSignMgr:PlayerHeadTeamMarkShowFalse()
	if(g_MainPlayer.m_TeamMarkWnd) then
		g_MainPlayer.m_TeamMarkWnd:ShowWnd(false)
	end
end

--�ж�Characterͷ����ʾ�Ķ�����ͼƬ��Ϣ(����ͼƬ����)
function CTeamMarkSignMgr:TeamMarkPicInfo(ID, nCharType)
	local tbl = g_GameMain.m_TeamBase.m_tblTeamMark --{.uMarkType, .uTargetType, .uTargetID}}
	for i = 1, #tbl do
		if(nCharType == tbl[i].uTargetType and ID == tbl[i].uTargetID) then
			return tbl[i].uMarkType
		end
	end
	return 0
end

--��Character���������Ұʱ���øú���
function CTeamMarkSignMgr:CharacterInView(Character)
	--if(Character:IsBattleHorse()) then return end
	self:UpdatePic(Character)
end

--��Character�뿪�����Ұʱ���øú���
function CTeamMarkSignMgr:CharacterOutView(Character)
	if(Character.m_TeamMarkWnd) then
		Character.m_TeamMarkWnd:ShowWnd(false)
		Character.m_TeamMarkWnd:DestroyWnd()
	end
end

--������Ӧ��RenderWnd��ͼƬ
function CTeamMarkSignMgr:UpdatePic(Character)
	local nCharType	= Character.m_Properties:GetType()
	local ID		= (ECharacterType.Player == nCharType) and Character.m_Properties:GetCharID() or Character:GetEntityID()
	local pic		= self:TeamMarkPicInfo(ID, nCharType)
	if(not Character.m_TeamMarkWnd or not IsCppBound(Character.m_TeamMarkWnd)) then
		if(0 == pic) then return end
		Character.m_TeamMarkWnd = CreateTeamMarkSign(Character, 260)
	end
	if g_GameMain.m_SceneStateForClient == 1 then
		pic = 0
	end
	Character.m_TeamMarkWnd:UpdateTeamMarkWnd(pic)
end

function CTeamMarkSignMgr:DestroySelfTeamMark()
	if( IsCppBound(g_MainPlayer) and g_MainPlayer.m_TeamMarkWnd and IsCppBound(g_MainPlayer.m_TeamMarkWnd) ) then
		g_MainPlayer.m_TeamMarkWnd:ShowWnd(false)
		g_MainPlayer:GetRenderObject():DelChild(g_MainPlayer.m_TeamMarkWnd)
		g_MainPlayer.m_TeamMarkWnd:DestroyWnd()
		g_MainPlayer.m_TeamMarkWnd = nil
	end
end

--����ID����ĳ������
function CTeamMarkSignMgr:UpdateOneCharacterByIDAndType(ID, uTargetType)
	if( uTargetType == ECharacterType.Player and ID == g_MainPlayer.m_Properties:GetCharID() ) then
		self:UpdatePic(g_MainPlayer)
	else
		for i, p in pairs(g_GameMain.m_CharacterInSyncMgr.m_tblCharacter) do
			local nSearchType	= p.m_Properties:GetType()
			local nSearchID		= (type == ECharacterType.Player) and p.m_Properties:GetCharID() or p:GetEntityID()
			if(nSearchType == uTargetType and nSearchID == ID) then
				self:UpdatePic(p)
			end
		end
	end
end

--���������Ұ�����е�����NPC��OBJ��ͷ����Ϣ״̬
function CTeamMarkSignMgr:UpdateCharacterInView()
	if(g_MainPlayer) then
		self:UpdatePic(g_MainPlayer)
	end
	for i, p in pairs(g_GameMain.m_CharacterInSyncMgr.m_tblCharacter) do
		self:UpdatePic(p)
	end
end
