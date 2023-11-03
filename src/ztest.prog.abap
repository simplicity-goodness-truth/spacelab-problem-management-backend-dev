*&---------------------------------------------------------------------*
*& Report  ZTEST
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
report ztest.

types: begin of ty_ms_but000,
         partner    type but000-partner,
         type       type but000-type,
         name_org2  type but000-name_org2,
         name_last  type but000-name_last,
         name_first type but000-name_first,
         name1_text type but000-name1_text,
         persnumber type but000-persnumber,
         mc_name1   type but000-mc_name1,
         addrcomm   type but000-addrcomm,
       end of ty_ms_but000.

data: ms_but000 type ty_ms_but000,
      t11       type i,
      t12       type i,
      toff1     type p decimals 2,
      t21       type i,
      t22       type i,
      toff2     type p decimals 2.


data ls_but000 type but000.

data lt_but000 type table of ty_ms_but000.

do 10 times.

  get run time field t11.


  select single partner type name_org2 name_last
         name_first name1_text persnumber mc_name1 addrcomm
             into ms_but000 from but000
             where partner eq '0000000012'.

  get run time field t12.

  toff1 = t12 - t11.


  get run time field t21.



  select single partner type name_org2 name_last

             into ms_but000 from but000
             where partner eq '0000000012'.

  get run time field t22.

  toff2 = t22 - t21.

  write: toff1 , toff2 .

  new-line.

enddo.
