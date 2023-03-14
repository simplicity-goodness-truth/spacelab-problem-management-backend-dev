class zcl_custom_crm_order_api_proxy definition
  public
  create public .

  public section.

    interfaces zif_custom_crm_order_create .
    interfaces zif_custom_crm_order_init .
    interfaces zif_custom_crm_order_read .
    interfaces zif_custom_crm_order_update .
    methods constructor
      raising
        zcx_crm_order_api_exc.

  protected section.
  private section.

    class-data: mv_user_authorized_for_init   type abap_bool,
                mv_user_authorized_for_read   type abap_bool,
                mv_user_authorized_for_create type abap_bool,
                mv_user_authorized_for_update type abap_bool,
                mo_custom_crm_order_init      type ref to zif_custom_crm_order_init,
                mo_custom_crm_order_read      type ref to zif_custom_crm_order_read,
                mo_custom_crm_order_create    type ref to zif_custom_crm_order_create,
                mo_custom_crm_order_update    type ref to zif_custom_crm_order_update.

    methods: is_user_authorized_to_read
      raising zcx_crm_order_api_exc.

    methods: is_user_authorized_to_create
      raising zcx_crm_order_api_exc.

    methods: is_user_authorized_to_update
      raising zcx_crm_order_api_exc.

    methods: is_user_authorized_to_init
      raising zcx_crm_order_api_exc.


endclass.

class zcl_custom_crm_order_api_proxy implementation.

  method constructor.

    me->is_user_authorized_to_init(  ).
    me->is_user_authorized_to_read(  ).

    if ( mv_user_authorized_for_init eq abap_true ).

      create object mo_custom_crm_order_init type zcl_custom_crm_order_api.

      " If user is authorized for read operation, we create additional reference for create and update
      " Create and update authorizations will be checked in corresponding methods

      if ( mv_user_authorized_for_read eq abap_true ).

        mo_custom_crm_order_read ?= mo_custom_crm_order_init.
        mo_custom_crm_order_create ?= mo_custom_crm_order_init.
        mo_custom_crm_order_update ?= mo_custom_crm_order_init.

      endif. "  if ( mv_user_authorized_for_read eq abap_true )


    endif. " if ( mv_user_authorized_for_init eq abap_true )

  endmethod.

  method is_user_authorized_to_create.

    mv_user_authorized_for_create = abap_true.

    if ( mv_user_authorized_for_create eq abap_false ).

      " User has no authorizations to create process type

      raise exception type zcx_crm_order_api_exc
        exporting
          textid  = zcx_crm_order_api_exc=>not_authorized_for_create
          ip_user = sy-uname.

    endif.

  endmethod.

  method is_user_authorized_to_update.

    mv_user_authorized_for_update = abap_true.

    if ( mv_user_authorized_for_update eq abap_false ).

      " User has no authorizations to update process type

      raise exception type zcx_crm_order_api_exc
        exporting
          textid  = zcx_crm_order_api_exc=>not_authorized_for_update
          ip_user = sy-uname.

    endif.


  endmethod.


  method is_user_authorized_to_init.

    mv_user_authorized_for_init = abap_true.

    if ( mv_user_authorized_for_init eq abap_false ).

      " User has no authorizations to initialize process type

      raise exception type zcx_crm_order_api_exc
        exporting
          textid  = zcx_crm_order_api_exc=>not_authorized_for_init
          ip_user = sy-uname.

    endif.


  endmethod.

  method is_user_authorized_to_read.

    mv_user_authorized_for_read = abap_true.

    if ( mv_user_authorized_for_read eq abap_false ).

      " User has no authorizations to read process type

      raise exception type zcx_crm_order_api_exc
        exporting
          textid  = zcx_crm_order_api_exc=>not_authorized_for_read
          ip_user = sy-uname.

    endif.

  endmethod.

  method zif_custom_crm_order_create~create_with_std_and_cust_flds.

    me->is_user_authorized_to_create(  ).

    if ( mv_user_authorized_for_create eq abap_true ) and ( mo_custom_crm_order_create is bound ).

      mo_custom_crm_order_create->create_with_std_and_cust_flds(
       exporting
        ir_entity = ir_entity
       importing
        ep_guid = ep_guid ).

    endif.

  endmethod.

  method zif_custom_crm_order_init~set_status_profile.

    if ( mo_custom_crm_order_init is bound ).

      mo_custom_crm_order_init->set_status_profile( ip_status_profile ).

    endif.

  endmethod.

  method zif_custom_crm_order_init~set_db_struct_fields_map.

    if ( mo_custom_crm_order_init is bound ).

      mo_custom_crm_order_init->set_db_struct_fields_map( it_db_struct_fields_map ).

    endif.

  endmethod.

  method zif_custom_crm_order_init~set_custom_fields_db_table.

    if ( mo_custom_crm_order_init is bound ).

      mo_custom_crm_order_init->set_custom_fields_db_table(  ip_custom_fields_db_table ).

    endif.

  endmethod.

  method zif_custom_crm_order_init~set_process_type.

    if ( mo_custom_crm_order_init is bound ).

      mo_custom_crm_order_init->set_process_type( ip_process_type ).

    endif.

  endmethod.

  method zif_custom_crm_order_init~set_structure_name.

    if ( mo_custom_crm_order_init is bound ).

      mo_custom_crm_order_init->set_structure_name( ip_structure_name ).

    endif.

  endmethod.

  method zif_custom_crm_order_init~set_sold_to_party.

    if ( mo_custom_crm_order_init is bound ).

      mo_custom_crm_order_init->set_sold_to_party( ip_sold_to_party ).

    endif.

  endmethod.

  method zif_custom_crm_order_init~set_crm_category1.

    if ( mo_custom_crm_order_init is bound ).

      mo_custom_crm_order_init->set_crm_category1( ip_crm_category1 ).

    endif.

  endmethod.

  method zif_custom_crm_order_init~set_crm_category2.

    if ( mo_custom_crm_order_init is bound ).

      mo_custom_crm_order_init->set_crm_category2( ip_crm_category2 ).
    endif.

  endmethod.

  method zif_custom_crm_order_init~set_crm_category3.

    if ( mo_custom_crm_order_init is bound ).

      mo_custom_crm_order_init->set_crm_category3( ip_crm_category3 ).

    endif.

  endmethod.

  method zif_custom_crm_order_init~set_crm_category4.

    if ( mo_custom_crm_order_init is bound ).

      mo_custom_crm_order_init->set_crm_category4( ip_crm_category4 ).

    endif.

  endmethod.

  method zif_custom_crm_order_init~set_crm_cat_schema.

    if ( mo_custom_crm_order_init is bound ).

      mo_custom_crm_order_init->set_crm_cat_schema(  ip_crm_cat_schema ).

    endif.

  endmethod.

  method zif_custom_crm_order_read~get_guids_list.

    if ( mo_custom_crm_order_read is bound ).

      et_result = mo_custom_crm_order_read->get_guids_list(  ).

    endif.

  endmethod.

  method zif_custom_crm_order_read~get_all_statuses_list.

  endmethod.

  method zif_custom_crm_order_read~get_all_priorities_list.

  endmethod.

  method zif_custom_crm_order_read~get_standard_fields_by_guid.

    if ( mo_custom_crm_order_read is bound ).

      es_result = mo_custom_crm_order_read->get_standard_fields_by_guid( ip_guid ).

    endif.

  endmethod.

  method zif_custom_crm_order_read~get_custom_fields_by_guid.

    if ( mo_custom_crm_order_read is bound ).

      call method mo_custom_crm_order_read->get_custom_fields_by_guid
        exporting
          ip_guid   = ip_guid
        importing
          es_result = es_result.

    endif.

  endmethod.

  method zif_custom_crm_order_read~get_attachments_list_by_guid.

    if ( mo_custom_crm_order_read is bound ).

      mo_custom_crm_order_read->get_attachments_list_by_guid(
        exporting
            ip_guid = ip_guid
        importing
            et_attachments_list_short = et_attachments_list_short
            et_attachments_list = et_attachments_list ).

    endif.

  endmethod.

  method zif_custom_crm_order_update~update_order.


    me->is_user_authorized_to_update(  ).

  endmethod.

  method zif_custom_crm_order_read~get_all_texts.

    mo_custom_crm_order_read->get_all_texts(
    exporting ip_guid = ip_guid
    importing et_texts = et_texts ).

  endmethod.

  method zif_custom_crm_order_read~get_attachment_by_keys.

    if ( mo_custom_crm_order_read is bound ).

      er_attachment = mo_custom_crm_order_read->get_attachment_by_keys(
          exporting
              ip_guid = ip_guid
              ip_loio = ip_loio
              ip_phio = ip_phio ).

    endif.

  endmethod.

  method zif_custom_crm_order_read~get_attachment_content_by_keys.

    if ( mo_custom_crm_order_read is bound ).
      mo_custom_crm_order_read->get_attachment_content_by_keys(
        exporting
        ip_guid = ip_guid
        ip_loio = ip_loio
        ip_phio = ip_phio
        importing
        er_attachment = er_attachment
        er_stream = er_stream ).

    endif.

  endmethod.

  method zif_custom_crm_order_create~create_attachment.

    if ( mo_custom_crm_order_create is bound ).

      mo_custom_crm_order_create->create_attachment(
        exporting
            ip_content = ip_content
            ip_file_name = ip_file_name
            ip_guid = ip_guid
            ip_mime_type = ip_mime_type ).

    endif.

  endmethod.


  method zif_custom_crm_order_update~delete_attachment.

    if ( mo_custom_crm_order_update is bound ).

      mo_custom_crm_order_update->delete_attachment(
        exporting
             ip_guid = ip_guid
             ip_loio = ip_loio
             ip_phio = ip_phio ).

    endif.

  endmethod.

  method zif_custom_crm_order_create~create_text.

    if ( mo_custom_crm_order_create is bound ).

      mo_custom_crm_order_create->create_text(
        exporting
            ip_guid = ip_guid
            ip_tdid = ip_tdid
            ip_text = ip_text ).

    endif.

  endmethod.



  method zif_custom_crm_order_read~get_last_text.

    if ( mo_custom_crm_order_read is bound ).

      es_text = mo_custom_crm_order_read->get_last_text( exporting ip_guid = ip_guid ).

    endif.

  endmethod.


endclass.
