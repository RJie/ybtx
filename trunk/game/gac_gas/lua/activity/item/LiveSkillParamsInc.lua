
--���ܼ��ܳ���
CultivateFlowerParams = {

	--�����¼�ʱ�� (��Сʱ��~���ʱ��)֮�����
	["TriggerTimeMin"] = 15,
	["TriggerTimeMax"] = 15,
	--�¼�����ʱ��
	["EventTime"] = 10,
	--������ȴʱ��
	["SkillCooldownTime"] = 2,
	--�ջ���ȴʱ��
	["GetItemCooldownTime"] = 3,
	--���ܳ�ʼ������
	["HealthPoint"] = 100,
	--����ֵÿ����X��,��һ�ο��ջ����
	["HealthPointStep"] = 30,
}

--���ܼӽ���ֵ
--1.��ˮ 2.���� 3.ɹ̫��
FlowerSkillAddHealthPoint = {
	[1] = 0,
	[2] = 50,
	[3] = 50,
}

--�������쳣״̬ʱ��ȥ�Ľ���ֵ
--2.�溦ʱ 3.ή��ʱ
FlowerSkillMinusHealthPoint = {
	[1] = 30,
	[2] = -20,
	[3] = -20,
}

--����״̬��Ч
--1.���� 2.�溦 3.ή��
CultivateFlowerStateEfx = {
	[1] = {"",""},
	[2] = {"fx/setting/obj/shjn_chonghai.efx","chonghai/create"},
	[3] = {"fx/setting/obj/shjn_weimi.efx","weimi/create"},
}

--���״̬����Ч
--0.������Ч 1.��ˮ 2.���� 3.ɹ̫��
CultivateFlowerCleanStateEfx = {
	[0] = {"fx/setting/obj/shjn_shengzhang.efx","shengzhang/create"},
	[1] = {"fx/setting/obj/shjn_jiaoshui.efx","jiaoshui/create"},
	[2] = {"fx/setting/obj/shjn_chuchong.efx","chuchong/create"},
	[3] = {"fx/setting/obj/shjn_shaitaiyang.efx","shaitaiyang/create"},
}
