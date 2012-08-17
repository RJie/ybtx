#���顢���Ȼظ���Ϣ��֤��
#���ڽ��ձ���������Ϣ����֤
create table tbl_revert_validate
(
	cs_uInviter		bigint unsigned	not	null,	#������
	cs_uInvitee		bigint unsigned not null, #��������
	rv_uFun				tinyint unsigned not null, #��������
	unique key(cs_uInviter,cs_uInvitee,rv_uFun),
	foreign	key(cs_uInviter)	references tbl_char_static(cs_uId) on	update cascade on delete cascade,
	foreign	key(cs_uinvitee)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

#�ñ���ܻ����ڹ�������Ƶ��(��������)
create table tbl_blackname
(
	cs_uId bigint unsigned not null,			#owner
	cs_uBlockCharId bigint unsigned not null,		#blocked role
	primary key (`cs_uId`, `cs_uBlockCharId`),
	foreign key (`cs_uId`) references `tbl_char_static` (`cs_uId`) on update cascade on delete cascade,
	foreign key (`cs_uBlockCharId`) references `tbl_char_static` (`cs_uId`) on update cascade on delete cascade
)ENGINE=InnoDB default CHARSET=latin1;

#������ϵ��
create table tbl_marriage
(
	cs_uHusbandId		bigint unsigned	not	null,	#husband identifier
	cs_uWifeId			bigint unsigned not null, #wife identifier
	
	foreign	key(cs_uHusbandId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade,
	foreign	key(cs_uWifeId)	references tbl_char_static(cs_uId) on	update cascade on delete cascade
)engine=innodb;

