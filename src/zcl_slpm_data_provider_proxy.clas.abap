class zcl_slpm_data_provider_proxy definition
  public
  final
  create public .
  public section.
    interfaces zif_slpm_data_provider.
    methods constructor
      raising zcx_slpm_data_provider_exc.
  protected section.
  private section.
    class-data: mo_slpm_data_provider         type ref to zif_slpm_data_provider,
                mv_user_authorized_for_read   type abap_bool,
                mv_user_authorized_for_create type abap_bool,
                mv_user_authorized_for_update type abap_bool.

    methods: is_user_authorized,
      is_user_authorized_to_read.
endclass.



class zcl_slpm_data_provider_proxy implementation.


  method constructor.

    me->is_user_authorized( ).

    if mv_user_authorized_for_read eq abap_true.

      create object mo_slpm_data_provider type zcl_slpm_data_provider.

    else.

      " User has no authorizations to read problems

      raise exception type zcx_slpm_data_provider_exc
        exporting
          textid         = zcx_slpm_data_provider_exc=>not_authorized_for_read
          mv_system_user = sy-uname.

    endif.

  endmethod.


  method is_user_authorized.

    me->is_user_authorized_to_read( ).

  endmethod.


  method is_user_authorized_to_read.

    mv_user_authorized_for_read = abap_true.

  endmethod.


  method zif_slpm_data_provider~get_problem.

    if mo_slpm_data_provider is bound.

      es_result = mo_slpm_data_provider->get_problem( ip_guid ).

    endif.

  endmethod.


  method zif_slpm_data_provider~get_problems_list.

    if mo_slpm_data_provider is bound.

      et_result = mo_slpm_data_provider->get_problems_list(  ).

    endif.


  endmethod.

  method zif_slpm_data_provider~get_texts.

    mo_slpm_data_provider->get_texts(
     exporting ip_guid = ip_guid
     importing et_texts = et_texts ).

  endmethod.

  method zif_slpm_data_provider~get_attachments_list.

    mo_slpm_data_provider->get_attachments_list(
      exporting
       ip_guid = ip_guid
      importing
       et_attachments_list = et_attachments_list
       et_attachments_list_short = et_attachments_list_short ).


  endmethod.

  method zif_slpm_data_provider~get_attachment.

    if mo_slpm_data_provider is bound.

      er_attachment = mo_slpm_data_provider->get_attachment(
      exporting
      ip_guid = ip_guid
      ip_loio = ip_loio ip_phio = ip_phio ).

    endif.

  endmethod.

  method zif_slpm_data_provider~get_attachment_content.

    if mo_slpm_data_provider is bound.

      mo_slpm_data_provider->get_attachment_content(
       exporting
           ip_guid = ip_guid
           ip_loio = ip_loio
           ip_phio = ip_phio
         importing
         er_attachment = er_attachment
         er_stream = er_stream ).

    endif.

  endmethod.

  method zif_slpm_data_provider~create_attachment.

    if mo_slpm_data_provider is bound.

      mo_slpm_data_provider->create_attachment(
      exporting
          ip_content = ip_content
          ip_file_name = ip_file_name
          ip_guid = ip_guid
          ip_mime_type = ip_mime_type ).

    endif.

  endmethod.

  method zif_slpm_data_provider~delete_attachment.

    mo_slpm_data_provider->delete_attachment(
         exporting
             ip_guid = ip_guid
             ip_loio = ip_loio
             ip_phio = ip_phio ).

  endmethod.

  method zif_slpm_data_provider~create_text.

    if mo_slpm_data_provider is bound.

      mo_slpm_data_provider->create_text(
             exporting
                 ip_guid = ip_guid
                 ip_tdid = ip_tdid
                 ip_text = ip_text ).


    endif.

  endmethod.

  method zif_slpm_data_provider~get_last_text.

    if mo_slpm_data_provider is bound.

      mo_slpm_data_provider->get_last_text( exporting ip_guid = ip_guid ).

    endif.
  endmethod.



  method zif_slpm_data_provider~create_problem.

    if mo_slpm_data_provider is bound.

      rp_guid = mo_slpm_data_provider->create_problem( exporting is_problem = is_problem ).

    endif.

  endmethod.
endclass.
