################################################################
#		����ָ����Ϣ
################################################################

#�Ƿ��ǵ�һ��ɱ��
#�Ƿ��ǵ�һ�α�
#�Ƿ��ǵ�һ����
#�Ƿ��ǵ�һ�������ɼ�

create table tbl_novice_direct	#novice guid
(
	cs_uId		bigint	unsigned	not null, 	# role identifier
	nd_sFirstTime	varchar(96) 	not	null,		# first time to finish sth
	
	primary key (cs_uId, nd_sFirstTime),
	foreign key (cs_uId) references tbl_char_static(cs_uId) on update cascade on delete cascade
)engine=innodb;
