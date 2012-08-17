gas_require "world/trap/trap_event/AllTrapEvent"

InTrapEvent = 
{
	["���ü���"] = CCommonTrap,
	["���ò��������"] = CNonCleanTrap,								--���ü��ܳ����岻���״̬
	["����ʱ����"] = CAddTemporarySkill,			--����ʱ���ܵ���ʱ������
	["���õص㼼��"] = CDoSkillOnPos,			--�Եص��ͷż���
	["�ı�����״̬"] = CChangeBoxStateTrap,
	["����"] = CTransportTrap,
	--�ר�ô��͵�------------
	["����ɱ����"] = CDaTaoShaTransportTrap,
	["��ᱦ����"] = CDaDuoBaoTransportTrap,
	["Ӷ��ѵ������"] = CYbEducateActionTrap,
	["Ӷ��ѵ����Ӽ���"] = CYbEducateActionAddNum,
	-------------------------------
	["����������"] = CSpecilAreaTrap,--������
	["��Trapȡ��״̬"] = CInTrapCancelBuf,
	["��Ҳ�Trap���������"] = CPlayerInTrapAddVar,
	["Npc����ȻTrap���������"] = CNpcInExistTrapAddVar,
	["Npc�Ȱڷ�Trap���������"] = CNpcInPutTrapAddVar,
	["��Ҳ�Trap������Ʒ"] =  CPlayerInTrapAddRes,
	["��Ҳ�Trap��Ǯ"] =  CPlayerAddMoney,
	["��Ҳ�Trap������"] =  CPlayerAddExper,
	["��Ҳ�Trap���͵�ָ��λ��"] =  CPlayerTransport,
	["Npc����ȻTrap������Ʒ"] =  CNpcInExistTrapAddRes,
	["Npc�Ȱڷ�Trap������Ʒ"] =  CNpcInPutTrapAddRes,
	----------------------------------------
	--��������û���õ�����Ҫ�Ǻϲ���ǰ�����õ�
	["��Trap���������"] = CInPutTrapAddVar,
	["��Trap������Ʒ"] = CInPutTrapAddItem,
	------------------------------------------
	["������ɾ��"] = CDestroyMySelf,
	["�����糡"] = CTriggerTheater,
	["Npc����Trapɾ��Npc"] = CNpcInTrapDeleteNpc,
	["Player����TrapˢNpcOrObj"] = CPlayerInTrapAddNpcOrObj,
	["С�����Ӽ���"] = CSmallEctypeAddCount,
	["�����õ�ͼ����Ϣ"] = CInTrapSendMsg,
	--------------------------------------------
	["ָ��ˢ��"] = CCreateNpcOnPos,
	["�滻"] = CReplaceNpc,
	["������"] = CAddHp,
	["ָ���������Trap��ɾ��"] = CNamedObjInPutTrapDelete,
	["Npc����Trap��ɾ��"] = CNpcIntoTrapDeleted,
	["��ռҰ�⸴���"] = CRapRebornPoint,
	["ָ���������Trap��ɾ��"] = CNamedObjInPutTrapDelete,
	["MatchGame�Ӽ���"] = CMatchGameAddCount,
	["Npc�뿪Trap��ɾ��"] = CNpcOutTrapDeleteNpc,
	["�涴�����ܳ�����"] = CBugRunOut,
	["Ӷ��ѵ����ͬNpc�Ӳ�ͬ����"]  = CAddDifferentCount,
	["Ӷ��ѵ����ͬ״̬�Ӳ�ͬ����"] = CAddDifferentStateCount,
	["��ͬNpc�Ӽ���"] = CAddSameNpcCount,
	["Ӷ��ѵ���Npc�Ӽ���"] = CYbActionNpcAddNum,
	["���³Ǵ���"] = CAreaFbTransportTrap,
	["������פ��"] = CChangeTongSceneByTrap,
	["��buff��Trap�ӻ����"] = CTakeBuffAddCount,
}
