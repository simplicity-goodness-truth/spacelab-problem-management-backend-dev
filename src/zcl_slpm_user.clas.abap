class zcl_slpm_user definition
  public
  inheriting from zcl_system_user
  create public .

  public section.

    interfaces:
      zif_slpm_user.

  protected section.
  private section.
    data: mo_log                  type ref to zcl_logger_to_app_log,
          mv_app_log_object       type balobj_d,
          mv_app_log_subobject    type balsubobj,
          mo_active_configuration type ref to zif_slpm_configuration.

    methods:

      get_slpm_products_of_cust_user
        returning
          value(rt_slpm_products_of_user) type zslpm_tt_products
        raising
          zcx_slpm_configuration_exc,

      get_slpm_products_of_intr_user
        returning
          value(rt_slpm_products_of_user) type zslpm_tt_products,

      set_app_logger
        raising
          zcx_slpm_configuration_exc,

      set_slpm_config_and_logger
        raising
          zcx_slpm_configuration_exc.


endclass.



class zcl_slpm_user implementation.


  method get_slpm_products_of_cust_user.

    data: lt_companies_bp              type crmt_bu_partner_t,
          lt_slpm_products_of_customer type zslpm_tt_products,
          ls_slpm_products_of_user     type zslpm_ts_product,
          lo_slpm_customer             type ref to zif_slpm_customer,
          lv_log_record_text           type string.

    lt_companies_bp = me->zif_slpm_user~get_slpm_companies_bp_of_user(  ).

    loop at lt_companies_bp assigning field-symbol(<ls_company_bp>).

      lo_slpm_customer = new zcl_slpm_customer( <ls_company_bp> ).

      clear lt_slpm_products_of_customer.

      lt_slpm_products_of_customer = lo_slpm_customer->get_slpm_products_of_customer(  ).

      loop at lt_slpm_products_of_customer assigning field-symbol(<ls_slpm_products_of_customer>).

        " Checking authorizations for a specific product

        if ( me->zif_slpm_user~is_auth_to_view_product( <ls_slpm_products_of_customer>-id ) eq abap_false ).

          me->set_slpm_config_and_logger(  ).

          message e005(zslpm_data_manager) with sy-uname <ls_slpm_products_of_customer>-id into lv_log_record_text.

          mo_log->zif_logger~warn( lv_log_record_text  ).

          continue.

        endif.

        move-corresponding <ls_slpm_products_of_customer> to ls_slpm_products_of_user.

        append ls_slpm_products_of_user to rt_slpm_products_of_user.

      endloop.

    endloop.

  endmethod.


  method get_slpm_products_of_intr_user.

    data lo_slpm_products_storage type ref to zif_slpm_products_storage.

    lo_slpm_products_storage = new zcl_slpm_products_storage(  ).

    rt_slpm_products_of_user = lo_slpm_products_storage->get_all_slpm_products(  ).

  endmethod.


  method set_app_logger.

    mv_app_log_object = mo_active_configuration->get_parameter_value( 'APP_LOG_OBJECT' ).
    mv_app_log_subobject = 'ZDATAMANAGER'.

    mo_log = zcl_logger_to_app_log=>get_instance( ).
    mo_log->set_object_and_subobject(
          exporting
            ip_object    =   mv_app_log_object
            ip_subobject =   mv_app_log_subobject ).

  endmethod.


  method set_slpm_config_and_logger.

    if mo_active_configuration is not bound.

      mo_active_configuration = new zcl_slpm_configuration(  ).

    endif.

    if mo_log is not bound.

      me->set_app_logger(  ).

    endif.

  endmethod.


  method zif_slpm_user~get_slpm_companies_bp_of_user.

    data lo_bp_master_data type ref to zif_bp_master_data.

    lo_bp_master_data = new zcl_bp_master_data( me->zif_system_user~get_businesspartner( ) ).

    rt_companies_bp = lo_bp_master_data->is_contact_person_of(  ).


  endmethod.


  method zif_slpm_user~get_slpm_prime_company_of_user.

    data: lt_companies_bp type crmt_bu_partner_t,
          lo_company      type ref to zif_company.

    lt_companies_bp = me->zif_slpm_user~get_slpm_companies_bp_of_user(  ).

    " We can take only one company of a user
    " For now the first one is a prime one

    try.
        rs_company-companybusinesspartner = lt_companies_bp[ 1 ].

        " Adding company name

        lo_company = new zcl_company( rs_company-companybusinesspartner ).

        rs_company-companyname = lo_company->get_company_name(  ).

      catch cx_sy_itab_line_not_found.

    endtry.

  endmethod.


  method zif_slpm_user~get_slpm_products_of_user.

    data: lo_active_configuration  type ref to zif_slpm_configuration,
          lt_slpm_products_of_user type zslpm_tt_products,
          lv_log_record_text       type string.

    if me->zif_slpm_user~is_auth_to_create_on_behalf(  ).

      lt_slpm_products_of_user = me->get_slpm_products_of_intr_user(  ).

      loop at lt_slpm_products_of_user assigning field-symbol(<ls_slpm_product_of_user>).

        " Checking authorizations for a specific product

        if ( me->zif_slpm_user~is_auth_to_view_product( <ls_slpm_product_of_user>-id ) eq abap_false ).

          me->set_slpm_config_and_logger(  ).

          message e005(zslpm_data_manager) with sy-uname <ls_slpm_product_of_user>-id into lv_log_record_text.

          mo_log->zif_logger~warn( lv_log_record_text  ).

          continue.

        endif.

        append <ls_slpm_product_of_user> to rt_slpm_products_of_user.

      endloop.


    else.

      rt_slpm_products_of_user = me->get_slpm_products_of_cust_user(  ).


    endif.

  endmethod.


  method zif_slpm_user~is_auth_to_create_on_behalf.

    authority-check object 'ZPRCRONBEH'
        id 'ALLOWED' field 'X'.
    if sy-subrc = 0.
      rb_authorized = abap_true.
    endif.


  endmethod.


  method zif_slpm_user~is_auth_to_create_problems.

    authority-check object 'ZSLPMBASEC'
           id 'ALLOWED' field 'X'.

    if sy-subrc = 0.
      rb_authorized = abap_true.
    endif.

  endmethod.


  method zif_slpm_user~is_auth_to_crea_company.

    authority-check object 'ZPRCRCOMP'
    id 'BU_PARTNER' field ip_company_bp.

    if sy-subrc = 0.

      rb_authorized = abap_true.

    endif.


  endmethod.


  method zif_slpm_user~is_auth_to_crea_product.

    authority-check object 'ZPRCRPROD'
      id 'ZPROD_ID' field ip_product_id.

    if sy-subrc = 0.

      rb_authorized = abap_true.

    endif.

  endmethod.


  method zif_slpm_user~is_auth_to_read_problems.

    authority-check object 'ZSLPMBASER'
           id 'ALLOWED' field 'X'.

    if sy-subrc = 0.
      rb_authorized = abap_true.
    endif.

  endmethod.


  method zif_slpm_user~is_auth_to_update_problems.

    authority-check object 'ZSLPMBASEU'
           id 'ALLOWED' field 'X'.

    if sy-subrc = 0.
      rb_authorized = abap_true.
    endif.

  endmethod.


  method zif_slpm_user~is_auth_to_view_company.

    authority-check object 'ZPRVWCOMP'
     id 'BU_PARTNER' field ip_company_bp.

    if sy-subrc = 0.

      rb_authorized = abap_true.

    endif.

  endmethod.


  method zif_slpm_user~is_auth_to_view_product.

    authority-check object 'ZPRVWPROD'
        id 'ZPROD_ID' field ip_product_id.

    if sy-subrc = 0.

      rb_authorized = abap_true.

    endif.

  endmethod.
  method zif_slpm_user~is_auth_to_update_product.

    authority-check object 'ZPRUPPROD'
      id 'ZPROD_ID' field ip_product_id.

    if sy-subrc = 0.

      rb_authorized = abap_true.

    endif.

  endmethod.

  method zif_slpm_user~is_auth_to_update_company.

    authority-check object 'ZPRUPCOMP'
      id 'BU_PARTNER' field ip_company_bp.

    if sy-subrc = 0.

      rb_authorized = abap_true.

    endif.

  endmethod.

  method zif_slpm_user~is_auth_for_internal_att.

    authority-check object 'ZSLPMATTVS'
        id 'ZVSBLTY' field 'I'.

    if sy-subrc = 0.

      rb_authorized = abap_true.

    endif.


  endmethod.

  method zif_slpm_user~is_auth_to_open_dispute_as_pro.

    authority-check object 'ZPRDISOPE'
       id 'ALLOWED' field 'X'.

    if sy-subrc = 0.

      rb_authorized = abap_true.

    endif.

  endmethod.

  method zif_slpm_user~is_auth_to_clos_dispute_as_pro.

    authority-check object 'ZPRDISCLO'
       id 'ALLOWED' field 'X'.

    if sy-subrc = 0.

      rb_authorized = abap_true.

    endif.

  endmethod.

  method zif_slpm_user~is_auth_to_open_dispute_as_req.

    authority-check object 'ZPRDISOPE'
     id 'ALLOWED' field 'X'.

    if sy-subrc = 0.

      rb_authorized = abap_true.

    endif.

  endmethod.

  method zif_slpm_user~is_auth_to_clos_dispute_as_req.


  endmethod.

  method zif_slpm_user~is_auth_to_view_dispute.

    authority-check object 'ZPRDISVIE'
      id 'ALLOWED' field 'X'.

    if sy-subrc = 0.

      rb_authorized = abap_true.

    endif.


  endmethod.

endclass.
