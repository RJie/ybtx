CServantQueryCallback = class(IServantQueryCallback)

function CServantQueryCallback:Ctor()
	self.m_ServantTbl = {}
end

function CServantQueryCallback:QueryServant(Obj)
	--���QueryServant, m_ServantTbl��û���,���ۼ�,���ܻ�����bug
	self:QueryServantJob(Obj)
	return self.m_ServantTbl
end

function CServantQueryCallback:Exec(uEntityId, Servant)
	self.m_ServantTbl[uEntityId] = Servant
end
