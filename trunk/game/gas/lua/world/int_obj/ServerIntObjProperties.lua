cfg_load "int_obj/IntObj_Common"

CServerIntObjProperties = class( CIntObjProperties )

local SVSetNumber = CSyncVariantServerHolder.SetNumber
local SVSetUInt32 = CSyncVariantServerHolder.SetUInt32
local SVSetUInt8 = CSyncVariantServerHolder.SetUInt8
local SVSetString = CSyncVariantServerHolder.SetString

function CServerIntObjProperties:Init( IntObj )
	CIntObjProperties.Init(self, IntObj)
end

function CServerIntObjProperties:InitTrap(IntObj)
	CIntObjProperties.Init(self, IntObj)
end

function CServerIntObjProperties:InitIntObjStatic(sName,uType,OwnerId,OwnerTeamID,DropTime)
	self:SetCharName(sName)
	self:SetType(uType)
	--local ModelName = IntObj_Common(sName, "ModelName")
	--self:SetModel(ModelName)
	local DefaultState = IntObj_Common(sName, "DefaultState")
	self:SetCanUseState(DefaultState)
	self:SetActionNum(1)
	self:SetBornAction(1)
	self:SetDropOwnerId(OwnerId or 0)
	self:SetDropTime(DropTime or 0)
	self:SetBelongToTeam(OwnerTeamID or 0)
	self:SetResourceCount(0)
	self:SetDuelWinCount("")
end

function CServerIntObjProperties:InitTrapStatic(sName,uType)
	self:SetCharName(sName)
	self:SetType(uType)
	--local ModelName = Trap_Common(sName, "ModelName")
 	--self:SetModel(ModelName)
 	--local DefaultState = Trap_Common(sName, "DefaultState")
 	--self:SetCanUseState(DefaultState)
	--self:SetActionNum(1)
end

function CServerIntObjProperties:SetCharName(sName)
	SVSetString(self.m_StaticViewRootVariant,"Attribute/CharName",sName)
end

function CServerIntObjProperties:SetType(uType)
	SVSetUInt8(self.m_StaticViewRootVariant,"Attribute/Type",uType)
end

function CServerIntObjProperties:SetCanUseState(DefaultState)
	SVSetUInt32(self.m_StaticViewRootVariant,"Attribute/CanUseState",DefaultState)
end

function CServerIntObjProperties:SetModel(sModelName)
	SVSetString(self.m_StaticViewRootVariant,"Attribute/ModelName",sModelName)
end

function CServerIntObjProperties:SetActionNum(sActionNum)
	SVSetUInt32(self.m_StaticViewRootVariant,"Attribute/ActionNum",sActionNum)
end

function CServerIntObjProperties:SetDropOwnerId(OwnerId)  --��Obj��̬����ʱ�п���Ҫָ��DropOwnerId
	SVSetNumber(self.m_StaticViewRootVariant,"Attribute/DropOwnerId",OwnerId)
end

---��Objָ��Owner�����������Ȩʹ���򲻱�ָ��DropTime
function CServerIntObjProperties:SetDropTime(DropTime)  --��Obj��̬����ʱ�п���Ҫָ��DropTime
	SVSetNumber(self.m_StaticViewRootVariant,"Attribute/DropTime",DropTime)
end

function CServerIntObjProperties:SetBelongToTeam(TeamID)  --����Ӵ�ֵ����Obj����Ҫָ��TeamID
	SVSetUInt32(self.m_StaticViewRootVariant,"Attribute/BelongToTeam",TeamID)
end

function CServerIntObjProperties:SetResourceCount(Num)  
	SVSetUInt32(self.m_StaticViewRootVariant,"Attribute/ResourceCount",Num)
end

function CServerIntObjProperties:SetDuelWinCount(str)
	SVSetString(self.m_StaticViewRootVariant,"Attribute/DuelWinCount",str)
end

function CServerIntObjProperties:SetCreatorName(CreatorName)
	SVSetString(self.m_StaticViewRootVariant,"Attribute/CreatorName",CreatorName)
end

function CServerIntObjProperties:SetBornAction(BornAction)--�Ƿ��г����Ķ���Ҫ��(2,��;�����Ķ�����)
	SVSetUInt32(self.m_StaticViewRootVariant,"Attribute/BornAction",BornAction)
end
