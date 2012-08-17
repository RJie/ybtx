##         ==**Ӷ����**==

##Ӷ���Ż������� �ȼ������飬С���������ʽ�����
create table tbl_army_corps
(
  ac_uId							bigint unsigned	not null	auto_increment,				#armycorps idntifier
  ac_sName						varchar(100) collate utf8_unicode_ci not null,	#armycorps name
  ac_uLevel						tinyint	not null,								#armycorps level
  ac_uExp							bigint unsigned		not null,			#armycorps exp
	ac_uMoney						bigint unsigned		not null,			#armycorps money
	ac_sPurpose    			varchar(3072)			not null,     #armycorps purpose
	
  primary key(ac_uId),
  unique key(ac_sName)
)engine=innodb;

##Ӷ�������
create table tbl_army_corps_member
(
	t_uId			bigint unsigned	not null,				#tongId
  ac_uId		bigint unsigned	not null,				#army_corpsId
  primary key(t_uId),
  foreign	key(t_uId)	references tbl_tong(t_uId) 	on	update cascade on	delete cascade,
  foreign	key(ac_uId)	references tbl_army_corps(ac_uId) 	on	update cascade on	delete cascade
)engine=innodb;

##����Ա
create table tbl_army_corps_admin
(
	cs_uId				bigint unsigned	  not null,       	#role id
	ac_uId		bigint unsigned	not null,								#army_corpsId
	aca_uPurview	tinyint not null,										#
	primary key(cs_uId),
  foreign	key(cs_uId)	  references tbl_char_static(cs_uId) 	on	update cascade on	delete cascade,
	foreign	key(ac_uId)	references tbl_army_corps(ac_uId) 	on	update cascade on	delete cascade
)engine=innodb;

##��Ա�˳�Ӷ������Ϣ��
create table tbl_leave_army_corps		#messages that members leave army_corps
(
	t_uId				      			bigint unsigned	    not null,       #tong id
	lac_dtQuitTime          datetime            not null,     	#time that event happened
	primary key(t_uId),
	foreign	key(t_uId)	references tbl_tong(t_uId) 	on	update cascade on	delete cascade
)engine=innodb;
