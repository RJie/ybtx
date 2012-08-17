create table tbl_user_trust
(	
	us_uId					int	unsigned	not	null,
	ut_sPassword		varchar(32)		not 	null,			#�й�����
	ut_dtTrustTime	datetime not null,						#�й���ʼʱ��
	ut_uTrustLength	int	unsigned not null,				#�йܳ���ʱ��
	foreign key(us_uId) references tbl_user_static(us_uId) on update cascade on delete cascade
)engine = innodb;
