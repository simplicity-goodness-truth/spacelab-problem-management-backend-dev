class zcl_slpm_problem_api definition
  public
  inheriting from zcl_custom_crm_order_api_proxy

  create public .

  public section.
    methods constructor
      importing
        io_active_configuration type ref to zif_slpm_configuration optional
      raising
        zcx_crm_order_api_exc
        zcx_system_user_exc
        zcx_slpm_configuration_exc.

  protected section.
  private section.
endclass.

class zcl_slpm_problem_api implementation.

  method constructor.

    data:
      lt_db_struct_fields_map type zcrm_order_tt_cust_fields_map,
      lv_sold_to_party        type crmt_partner_no.

    super->constructor( 'ZSLP' ).

    " Process type

    zif_custom_crm_order_init~set_process_type( 'ZSLP' ).

    " Status profile

    zif_custom_crm_order_init~set_status_profile( 'ZSLP0001' ).


    " Custom fields table

    zif_custom_crm_order_init~set_custom_fields_db_table( 'CRMD_CUSTOMER_H' ).

    " Structure name

    zif_custom_crm_order_init~set_structure_name( 'ZCRM_ORDER_TS_SL_PROBLEM' ).


    " Adding custom fields mapping

    lt_db_struct_fields_map = value zcrm_order_tt_cust_fields_map(
          ( db_field = 'ZZFLD000000' struct_field = 'COMPANYBUSINESSPARTNER' )
          ( db_field = 'ZZFLD000001' struct_field = 'CONTACTEMAIL' )
          ( db_field = 'ZZFLD000002' struct_field = 'NOTIFYBYCONTACTEMAIL' )
          ( db_field = 'ZZFLD000003' struct_field = 'SAPSYSTEMNAME' )
        ).

    zif_custom_crm_order_init~set_db_struct_fields_map( lt_db_struct_fields_map ).

    " Sold-to-party

*    lv_sold_to_party = io_active_configuration->get_parameter_value( 'DEFAULT_SOLD_TO_PARTY' ).
*
*    zif_custom_crm_order_init~set_sold_to_party( lv_sold_to_party ).

  endmethod.


endclass.
