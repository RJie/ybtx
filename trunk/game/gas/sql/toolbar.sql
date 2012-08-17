################################################################
#       �û�������ȡ��Ϣ�����
#       
################################################################
#������Ϣ�����Ϣ
create table tbl_msgpanel	#settings of message panel
(
	cs_uId			bigint unsigned 	not null,   		#role identifier
	panel_name		varchar(36)		not null,		#panel name
	panel_position		tinyint			not null,		#panel position
	action			tinyint			not null,		#set or unset
	primary key (cs_uID, panel_position),
	foreign key(cs_uId) references tbl_char_static(cs_uId) on update cascade on delete cascade
)engine=innodb;

#����б����ƻ��߱�ȡ�����Ƶ�Ƶ��
create table tbl_msgchannel	#channels that be setted or unsetted
(
	cs_uID				bigint unsigned 	not null,   	#role identifier
	panel_position		tinyint				not null,	#panel position
	mc_uChannelId		tinyint unsigned	not null,		#panel name
	mc_sAction			tinyint unsigned	not null,	#action: choose or unchoose
	primary key (cs_uID, panel_position, mc_uChannelId),
	foreign key (cs_uID, panel_position) references tbl_msgpanel (cs_uID, panel_position) on update cascade on delete cascade
)engine=innodb;


################################################################
#		��ɫ������洢��
################################################################

create table tbl_shortcut	#shot cut
(
	cs_uId						bigint 	unsigned		not	null,		#���ID
	sc_uPos						tinyint unsigned  	not null,			#���������λ��
	sc_Type						tinyint	unsigned		not null,		#���ӵ��������ͣ����ܡ���Ʒ��
	sc_Arg1						varchar(96)			not null,			#�������ơ���Ʒ����
	sc_Arg2						bigint	unsigned		not null,		#���ܵȼ�����Ʒ����
	sc_Arg3						bigint	unsigned		not null,		#�����ID
	
	primary	key(cs_uId, sc_uPos, sc_Arg3),
	foreign	key(cs_uId)	references tbl_char_static(cs_uId) on	delete cascade on update cascade
)engine=innodb;
