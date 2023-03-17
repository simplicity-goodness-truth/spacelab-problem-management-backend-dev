class zcl_slpm_data_manager_proxy definition
  public
  final
  create public .
  public section.
    interfaces zif_slpm_data_manager.
    methods constructor
      raising zcx_slpm_data_manager_exc.
  protected section.
  private section.
    data: mo_slpm_data_provider         type ref to zif_slpm_data_manager,
          mv_user_authorized_for_read   type abap_bool,
          mv_user_authorized_for_create type abap_bool,
          mv_user_authorized_for_update type abap_bool.

    methods: is_user_authorized,
      is_user_authorized_to_read.
endclass.


class zcl_slpm_data_manager_proxy implementation.

  method constructor.

    me->is_user_authorized( ).

    if mv_user_authorized_for_read eq abap_true.

      create object mo_slpm_data_provider type zcl_slpm_data_manager.

    else.

      " User has no authorizations to read problems

      raise exception type zcx_slpm_data_manager_exc
        exporting
          textid         = zcx_slpm_data_manager_exc=>not_authorized_for_read
          ip_system_user = sy-uname.

    endif.

  endmethod.

  method is_user_authorized.

    me->is_user_authorized_to_read( ).

  endmethod.


  method is_user_authorized_to_read.

    mv_user_authorized_for_read = abap_true.

  endmethod.


  method zif_slpm_data_manager~create_attachment.

    if mo_slpm_data_provider is bound.

      mo_slpm_data_provider->create_attachment(
      exporting
          ip_content = ip_content
          ip_file_name = ip_file_name
          ip_guid = ip_guid
          ip_mime_type = ip_mime_type ).

    endif.

  endmethod.


  method zif_slpm_data_manager~create_problem.

    if mo_slpm_data_provider is bound.


      " Notification on a problem change

      data: ls_problem_newstate          type zcrm_order_ts,
            lo_slpm_prob_change_notifier type ref to zif_crm_order_change_notifier.

      try.

          rs_result = mo_slpm_data_provider->create_problem( exporting is_problem = is_problem ).

          lo_slpm_prob_change_notifier = new zcl_slpm_prob_change_notifier(
           is_problem_new_state = rs_result
           is_problem_old_state = is_problem ).

          lo_slpm_prob_change_notifier->notify(  ).

        catch  zcx_crm_order_api_exc zcx_assistant_utilities_exc into data(lcx_process_exception).

          raise exception type zcx_slpm_data_manager_exc
            exporting
              textid           = zcx_slpm_data_manager_exc=>internal_error
              ip_error_message = lcx_process_exception->get_text( ).

      endtry.

    endif.

  endmethod.


  method zif_slpm_data_manager~create_text.

    if mo_slpm_data_provider is bound.

      mo_slpm_data_provider->create_text(
             exporting
                 ip_guid = ip_guid
                 ip_tdid = ip_tdid
                 ip_text = ip_text ).


    endif.

  endmethod.


  method zif_slpm_data_manager~delete_attachment.

    mo_slpm_data_provider->delete_attachment(
         exporting
             ip_guid = ip_guid
             ip_loio = ip_loio
             ip_phio = ip_phio ).

  endmethod.


  method zif_slpm_data_manager~get_all_priorities.

    if mo_slpm_data_provider is bound.
      rt_priorities = mo_slpm_data_provider->get_all_priorities(  ).
    endif.

  endmethod.


  method zif_slpm_data_manager~get_attachment.

    if mo_slpm_data_provider is bound.

      er_attachment = mo_slpm_data_provider->get_attachment(
      exporting
      ip_guid = ip_guid
      ip_loio = ip_loio ip_phio = ip_phio ).

    endif.

  endmethod.


  method zif_slpm_data_manager~get_attachments_list.

    mo_slpm_data_provider->get_attachments_list(
      exporting
       ip_guid = ip_guid
      importing
       et_attachments_list = et_attachments_list
       et_attachments_list_short = et_attachments_list_short ).


  endmethod.


  method zif_slpm_data_manager~get_attachment_content.

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


  method zif_slpm_data_manager~get_last_text.

    if mo_slpm_data_provider is bound.

      mo_slpm_data_provider->get_last_text( exporting ip_guid = ip_guid ).

    endif.
  endmethod.


  method zif_slpm_data_manager~get_priorities_of_product.

    if mo_slpm_data_provider is bound.
      rt_priorities = mo_slpm_data_provider->get_priorities_of_product( ip_guid ).
    endif.

  endmethod.


  method zif_slpm_data_manager~get_problem.

    if mo_slpm_data_provider is bound.

      es_result = mo_slpm_data_provider->get_problem( ip_guid ).

    endif.

  endmethod.


  method zif_slpm_data_manager~get_problems_list.

    if mo_slpm_data_provider is bound.

      et_result = mo_slpm_data_provider->get_problems_list(  ).

    endif.


  endmethod.


  method zif_slpm_data_manager~get_texts.

    mo_slpm_data_provider->get_texts(
     exporting ip_guid = ip_guid
     importing et_texts = et_texts ).

  endmethod.
endclass.
