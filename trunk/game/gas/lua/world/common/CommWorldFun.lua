--��Ϊ����Player,Npc��obj��trap����lua�����ɾ���������߼����붼����Ϊ�ö����Ѿ������ڣ�
--������C++����ö�����Ȼû�б�ɾ������������lua�����ж϶����Ƿ�Ϸ����õ�������ĺ��������ж�
--�ú���ֻ��ʹ���ڷ���˶������ϣ���Ϊ�ͻ��˶�����ͬ��ɾ����

function IsServerObjValid(Obj)
	if Obj and IsCppBound(Obj) and Obj:GetObjValidState() then
		return true
	end
	return false
end

--�����������Ƿ����ٻ�������
function IsServantType(NpcTypeName)
	local eNpcType = NpcInfoMgr_GetTypeByTypeName(NpcTypeName)
	return NpcInfoMgr_BeServantType(eNpcType)
end