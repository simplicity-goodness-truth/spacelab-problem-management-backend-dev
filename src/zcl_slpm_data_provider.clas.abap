class zcl_slpm_data_provider definition
  public
  final
  create public .
  public section.
    interfaces zif_slpm_data_provider.
  protected section.
  private section.
endclass.


class zcl_slpm_data_provider implementation.

  method zif_slpm_data_provider~get_problems_list.

    data: lo_slpm_problem_api type ref to zcl_slpm_problem_api,
          lt_crm_guids        type zcrm_order_tt_guids,
          ls_crm_order_ts     type  zcrm_order_ts,
          ls_result           like line of et_result.

    create object lo_slpm_problem_api.

    lt_crm_guids = lo_slpm_problem_api->zif_custom_crm_order_read~get_guids_list(  ).

    loop at lt_crm_guids assigning field-symbol(<ls_crm_guid>).

      ls_result = me->zif_slpm_data_provider~get_problem(
               exporting
                 ip_guid = <ls_crm_guid>-guid
                 io_slmp_problem_api = lo_slpm_problem_api ).


      append ls_result to et_result.

    endloop.


  endmethod.

  method zif_slpm_data_provider~get_problem.

    data:
      lo_slmp_problem_api            type ref to zcl_slpm_problem_api,
      ls_sl_problem_standard_package type zcrm_order_ts,
      ls_sl_problem_custom_package   type zcrm_order_ts_sl_problem,
      lo_custom_fields               type ref to data,
      lt_sl_problem_custom_package   type standard table of zcrm_order_ts_sl_problem.

    field-symbols <ls_custom_fields> type any table.

    if io_slmp_problem_api is bound.

      lo_slmp_problem_api = io_slmp_problem_api.

    else.

      create object lo_slmp_problem_api.

    endif.

    ls_sl_problem_standard_package = lo_slmp_problem_api->zif_custom_crm_order_read~get_standard_fields_by_guid( ip_guid ).

    " Getting additional fields package

    call method lo_slmp_problem_api->zif_custom_crm_order_read~get_custom_fields_by_guid
      exporting
        ip_guid   = ip_guid
      importing
        es_result = lo_custom_fields.

    if ( lo_custom_fields is bound ).

      assign lo_custom_fields->* to <ls_custom_fields>.

      lt_sl_problem_custom_package = <ls_custom_fields>.

      read table  lt_sl_problem_custom_package into ls_sl_problem_custom_package index 1.

    endif.

    " Filling output structure

    move-corresponding ls_sl_problem_custom_package to es_result.

    move-corresponding ls_sl_problem_standard_package to es_result.

  endmethod.

  method zif_slpm_data_provider~get_texts.

    data:
        lo_slmp_problem_api  type ref to zcl_slpm_problem_api.

    create object lo_slmp_problem_api.

    lo_slmp_problem_api->zif_custom_crm_order_read~get_all_texts(
     exporting ip_guid = ip_guid
     importing et_texts = et_texts ).

  endmethod.

  method zif_slpm_data_provider~get_attachments_list.

    data:
      lo_slmp_problem_api  type ref to zcl_slpm_problem_api.

    create object lo_slmp_problem_api.

    lo_slmp_problem_api->zif_custom_crm_order_read~get_attachments_list_by_guid(
    exporting
     ip_guid = ip_guid
    importing
     et_attachments_list = et_attachments_list
     et_attachments_list_short = et_attachments_list_short ).

  endmethod.

  method zif_slpm_data_provider~get_attachment.

    data:
        lo_slmp_problem_api type ref to zcl_slpm_problem_api.

    create object lo_slmp_problem_api.

    er_attachment = lo_slmp_problem_api->zif_custom_crm_order_read~get_attachment_by_keys(
        exporting
            ip_guid = ip_guid
            ip_loio = ip_loio
            ip_phio = ip_phio ).

  endmethod.

  method zif_slpm_data_provider~get_attachment_content.

    data:
      lo_slmp_problem_api type ref to zcl_slpm_problem_api.

    create object lo_slmp_problem_api.

    lo_slmp_problem_api->zif_custom_crm_order_read~get_attachment_content_by_keys(
      exporting
          ip_guid = ip_guid
          ip_loio = ip_loio
          ip_phio = ip_phio
          importing
          er_attachment = er_attachment
          er_stream = er_stream ).

  endmethod.

  method zif_slpm_data_provider~create_attachment.

    data:
      lo_slmp_problem_api type ref to zcl_slpm_problem_api.

    create object lo_slmp_problem_api.

    lo_slmp_problem_api->zif_custom_crm_order_create~create_attachment(
      exporting
          ip_content = ip_content
          ip_file_name = ip_file_name
          ip_guid = ip_guid
          ip_mime_type = ip_mime_type ).


  endmethod.

  method zif_slpm_data_provider~delete_attachment.

    data:
      lo_slmp_problem_api type ref to zcl_slpm_problem_api.

    create object lo_slmp_problem_api.

    lo_slmp_problem_api->zif_custom_crm_order_update~delete_attachment(
     exporting
            ip_guid = ip_guid
            ip_loio = ip_loio
            ip_phio = ip_phio ).

  endmethod.

  method zif_slpm_data_provider~create_text.

    data:
        lo_slmp_problem_api type ref to zcl_slpm_problem_api.

    create object lo_slmp_problem_api.

    lo_slmp_problem_api->zif_custom_crm_order_create~create_text(
        exporting
            ip_guid = ip_guid
            ip_tdid = ip_tdid
            ip_text = ip_text ).
  endmethod.

  method zif_slpm_data_provider~get_last_text.

    data:
        lo_slmp_problem_api type ref to zcl_slpm_problem_api.

    create object lo_slmp_problem_api.

    lo_slmp_problem_api->zif_custom_crm_order_read~get_last_text( exporting ip_guid = ip_guid ).

  endmethod.

  method zif_slpm_data_provider~create_problem.

    data:
      lo_slmp_problem_api type ref to zcl_slpm_problem_api,
      lr_problem          type ref to data,
      lv_guid             type crmt_object_guid.

    create object lo_slmp_problem_api.


    get reference of is_problem into lr_problem.

    lo_slmp_problem_api->zif_custom_crm_order_create~create_with_std_and_cust_flds(
        exporting ir_entity = lr_problem
        importing
        ep_guid = rp_guid ).

  endmethod.

endclass.
