
#��ȯ������Ϣlog��
create table tbl_log_coupons_info(
	le_uId	bigint unsigned		not	null,
	lci_uId          bigint  unsigned		not null,
	lci_sName        varchar(96)  collate utf8_unicode_ci           not null,
	lci_uSmallIcon   int     unsigned        not null,
	lci_uPrice       int(10) unsigned        not null,
	lci_sDesc        text  collate utf8_unicode_ci       not null,
	lci_sUrl         text  collate utf8_unicode_ci        not null,
	
	key (le_uId),
	key (lci_uId)
)engine = innodb;

#��ҹ����ȯlog��Ϣ
create table tbl_log_char_bought_coupons(
	le_uId	bigint unsigned		not	null,
  lcs_uId      bigint unsigned     not null,
  lci_uId      bigint unsigned     not null,
  lcbc_sSequenceId varchar(96)     not null, 
  
  key (le_uId),
  key(lcs_uId, lci_uId)
)engine = innodb;