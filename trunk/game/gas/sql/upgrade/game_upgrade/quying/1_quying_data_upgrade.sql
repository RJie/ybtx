#��tbl_tong_draw_forage_temp���ݵ���tbl_tong_draw_forage

insert into tbl_tong_draw_forage select * from tbl_tong_draw_forage_temp;

#ɾ��tbl_tong_draw_forage_temp�е�����

delete from tbl_tong_draw_forage_temp;

#��ʼ��20������û�����ݵ����

insert into tbl_tong_draw_forage select cs_uId,50 
from (select cs.cs_uId from tbl_char_static cs ,tbl_char_basic cb where cs.cs_uId= cb.cs_uId
and cb_uLevel >=20) as result left join tbl_tong_draw_forage tdf on result.cs_uId = tdf.tdf_uId
where tdf.tdf_uId is null;

