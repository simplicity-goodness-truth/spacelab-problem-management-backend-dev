class zcl_slpm_problem_api definition
  public
  inheriting from zcl_custom_crm_order_api_proxy

  create public .

  public section.
    methods constructor
      raising
        zcx_crm_order_api_exc.

  protected section.
  private section.
endclass.

class zcl_slpm_problem_api implementation.

  method constructor.
    types:
      begin of ty_db_struct_fields_map,
        db_field     type name_feld,
        struct_field type name_komp,
        value        type ref to data,
      end of ty_db_struct_fields_map,

      tt_db_struct_fields_map type standard table of ty_db_struct_fields_map with empty key.


    super->constructor( ).

    " Process type

    zif_custom_crm_order_init~set_process_type( 'ZSLP' ).

    " Status profile

    zif_custom_crm_order_init~set_status_profile( 'ZSLP0001' ).


    " Custom fields table

    zif_custom_crm_order_init~set_custom_fields_db_table( 'CRMD_CUSTOMER_H' ).

    " Structure name

    zif_custom_crm_order_init~set_structure_name( 'ZCRM_ORDER_TS_SL_PROBLEM' ).


    " Adding custom fields mapping

*    zif_custom_crm_order_api~mt_db_struct_fields_map = value tt_db_struct_fields_map(
*      ( db_field = 'ZZFLD00000Z' struct_field = 'IMPACT' )
*      ( db_field = 'ZZFLD000010' struct_field = 'CHANGETYPE' )
*      ( db_field = 'ZZFLD000011' struct_field = 'COMPANYCODE' )
*      ( db_field = 'ZZFLD000015' struct_field = 'REQUESTERCOMPANYCODE' )
*      ( db_field = 'ZZFLD000012' struct_field = 'RISC' )
*      ( db_field = 'ZZFLD000013' struct_field = 'FLOWSTAGE' )
*      ( db_field = 'ZZFLD000018' struct_field = 'RESOURCE' )
*      ( db_field = 'ZZFLD000019' struct_field = 'USERID' )
*      ( db_field = 'ZZFLD00001D' struct_field = 'DEPARTMENT' )
*      ( db_field = 'ZZFLD00001E' struct_field = 'LASTLEVELAPPROVER' )
*    ).
*
    " Sold-to-party

    zif_custom_crm_order_init~set_sold_to_party('0000000002').

*
*    " Categories setting
*
*    me->mv_crm_category1 = me->get_crm_mand_cat_x_param( '1' ).
*    me->mv_crm_category2 = me->get_crm_mand_cat_x_param( '2' ).
*    me->mv_crm_category3 = me->get_crm_mand_cat_x_param( '3' ).
*    me->mv_crm_category4 = me->get_crm_mand_cat_x_param( '4' ).
*
*    " Categorization schema
*
*    me->mv_crm_cat_schema = me->get_crm_mand_cat_schema_param( ).

  endmethod.




endclass.
