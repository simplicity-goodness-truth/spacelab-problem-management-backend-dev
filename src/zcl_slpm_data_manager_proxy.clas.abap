class zcl_slpm_data_manager_proxy definition
  public
  final
  create public .
  public section.
    interfaces zif_slpm_data_manager.
    methods constructor
      raising zcx_slpm_data_manager_exc
              zcx_slpm_configuration_exc
              zcx_system_user_exc.
  protected section.
  private section.
    data: mo_slpm_data_provider         type ref to zif_slpm_data_manager,
          mv_user_authorized_for_read   type abap_bool,
          mv_user_authorized_for_create type abap_bool,
          mv_user_authorized_for_update type abap_bool,
          mo_active_configuration       type ref to zif_slpm_configuration,
          mo_system_user                type ref to zif_system_user,
          mo_log                        type ref to zcl_logger_to_app_log,
          mv_app_log_object             type balobj_d,
          mv_app_log_subobject          type balsubobj.

    methods:

      is_user_authorized,
      is_user_authorized_to_read,

      notify_on_problem_change
        importing
          is_problem_new_state type zcrm_order_ts_sl_problem
          is_problem_old_state type zcrm_order_ts_sl_problem
        raising
          zcx_assistant_utilities_exc
          zcx_slpm_configuration_exc,

      set_app_logger
        raising
          zcx_slpm_configuration_exc,

      post_update_external_actions
        importing
          is_problem_old_state type zcrm_order_ts_sl_problem
          is_problem_new_state type zcrm_order_ts_sl_problem
        raising
          zcx_slpm_configuration_exc,

      store_irt_sla
        importing
          ip_guid     type crmt_object_guid
          ip_irt_perc type int4
        raising
          zcx_slpm_configuration_exc
          zcx_crm_order_api_exc,

      recalc_irt_sla
        importing
          ip_guid type crmt_object_guid
        raising
          zcx_slpm_configuration_exc
          zcx_crm_order_api_exc.

endclass.

class zcl_slpm_data_manager_proxy implementation.


  method set_app_logger.

    mv_app_log_object = mo_active_configuration->get_parameter_value( 'APP_LOG_OBJECT' ).
    mv_app_log_subobject = 'ZDATAMANAGER'.

    mo_log = zcl_logger_to_app_log=>get_instance( ).
    mo_log->set_object_and_subobject(
          exporting
            ip_object    =   mv_app_log_object
            ip_subobject =   mv_app_log_subobject ).

  endmethod.

  method constructor.

    me->mo_system_user = new zcl_system_user( sy-uname ).

    me->is_user_authorized( ).

    if mv_user_authorized_for_read eq abap_true.

      mo_active_configuration = new zcl_slpm_configuration(  ).

      mo_slpm_data_provider = new zcl_slpm_data_manager(
        io_active_configuration = mo_active_configuration
        io_system_user = me->mo_system_user ).

    else.

      " User has no authorizations to read problems

      raise exception type zcx_slpm_data_manager_exc
        exporting
          textid         = zcx_slpm_data_manager_exc=>not_authorized_for_read
          ip_system_user = sy-uname.

    endif.

    me->set_app_logger(  ).

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




  method notify_on_problem_change.

    data lo_slpm_prob_change_notifier type ref to zif_crm_order_change_notifier.

    lo_slpm_prob_change_notifier = new zcl_slpm_prob_change_notifier(
            io_active_configuration = mo_active_configuration
            is_problem_new_state = is_problem_new_state
            is_problem_old_state = is_problem_old_state ).

    lo_slpm_prob_change_notifier->notify(  ).

  endmethod.


  method zif_slpm_data_manager~create_problem.


    data: ls_problem_newstate          type zcrm_order_ts_sl_problem,
          lo_slpm_prob_change_notifier type ref to zif_crm_order_change_notifier,
          lo_slpm_user                 type ref to zif_slpm_user,
          lv_log_record_text           type string,
          lv_product_id                type comt_product_id.


    if mo_slpm_data_provider is bound.

      " Check authorizations of a user to create a problem against a company

      lo_slpm_user = new zcl_slpm_user( sy-uname ).

      if ( lo_slpm_user->is_auth_to_crea_company( is_problem-companybusinesspartner ) eq abap_false ).

        message e004(zslpm_data_manager) with sy-uname is_problem-companybusinesspartner into lv_log_record_text.

        mo_log->zif_logger~err( lv_log_record_text ).

        raise exception type zcx_slpm_data_manager_exc
          exporting
            textid         = zcx_slpm_data_manager_exc=>no_auth_for_creat_for_company
            ip_system_user = sy-uname
            ip_company_bp  = is_problem-companybusinesspartner.


      endif.

      " Check authorizations of a user to create a problem against a product

      lv_product_id = is_problem-productname.

      if ( lo_slpm_user->is_auth_to_crea_product( lv_product_id ) eq abap_false ).

        message e006(zslpm_data_manager) with sy-uname lv_product_id into lv_log_record_text.

        mo_log->zif_logger~err( lv_log_record_text ).

        raise exception type zcx_slpm_data_manager_exc
          exporting
            textid         = zcx_slpm_data_manager_exc=>no_auth_for_creat_for_prod
            ip_system_user = sy-uname
            ip_product_id  = lv_product_id.

      endif.

      " Notification on a problem change

      try.

          rs_result = mo_slpm_data_provider->create_problem( exporting is_problem = is_problem ).

          me->notify_on_problem_change(
              exporting
              is_problem_new_state = rs_result
              is_problem_old_state = is_problem ).

        catch  zcx_crm_order_api_exc zcx_assistant_utilities_exc into data(lcx_process_exception).

          raise exception type zcx_slpm_data_manager_exc
            exporting
              textid           = zcx_slpm_data_manager_exc=>internal_error
              ip_error_message = lcx_process_exception->get_text( ).

      endtry.

    endif.

  endmethod.




  method zif_slpm_data_manager~update_problem.

    data: ls_problem_old_state type zcrm_order_ts_sl_problem.

    if mo_slpm_data_provider is bound.

      try.

          ls_problem_old_state = mo_slpm_data_provider->get_problem(
              exporting
                ip_guid = ip_guid ).

          rs_result = mo_slpm_data_provider->update_problem(
            exporting
                ip_guid = ip_guid
                is_problem = is_problem ).



          me->post_update_external_actions(
               exporting
               is_problem_new_state = rs_result
               is_problem_old_state = ls_problem_old_state ).


          me->notify_on_problem_change(
                     exporting
                     is_problem_new_state = rs_result
                     is_problem_old_state = ls_problem_old_state ).


        catch zcx_crm_order_api_exc into data(lcx_process_exception).

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

      et_result = mo_slpm_data_provider->get_problems_list(
      exporting
        it_filters = it_filters
        it_order = it_order ).

    endif.

  endmethod.

  method zif_slpm_data_manager~get_texts.

    mo_slpm_data_provider->get_texts(
     exporting ip_guid = ip_guid
     importing et_texts = et_texts ).

  endmethod.

  method zif_slpm_data_manager~get_list_of_possible_statuses.

    if mo_slpm_data_provider is bound.

      rt_statuses = mo_slpm_data_provider->get_list_of_possible_statuses( ip_status ).

    endif.

  endmethod.

  method zif_slpm_data_manager~get_list_of_processors.

    if mo_slpm_data_provider is bound.

      rt_processors = mo_slpm_data_provider->get_list_of_processors(  ).

    endif.

  endmethod.

  method zif_slpm_data_manager~get_list_of_companies.

    if mo_slpm_data_provider is bound.

      rt_companies = mo_slpm_data_provider->get_list_of_companies(  ).

    endif.

  endmethod.

  method zif_slpm_data_manager~get_frontend_configuration.

    if mo_slpm_data_provider is bound.

      rt_frontend_configuration = mo_slpm_data_provider->get_frontend_configuration( ip_application ).

    endif.


  endmethod.



  method recalc_irt_sla.

    data:lv_difference_in_seconds      type integer,
         lv_timestamp_of_status_switch type timestamp,
         lv_irt_update_timestamp       type timestamp,
         lv_irt_update_timezone        type timezone,
         lv_old_irt_timestamp          type timestamp,
         lv_old_irt_timezone           type timezone,
         lv_new_irt_timestamp          type timestamp,
         lv_new_irt_timezone           type timezone,
         lv_appt_guid                  type sc_aptguid.

    " Taking a timestamp when we switched back from 'Information Requested

    get time stamp field lv_timestamp_of_status_switch.

    " Taking last stored IRT SLA

    select  update_timestamp update_timezone irttimestamp irttimezone apptguid
        from zslpm_irt_hist
        into (lv_irt_update_timestamp, lv_irt_update_timezone, lv_old_irt_timestamp, lv_old_irt_timezone, lv_appt_guid)
       up to 1 rows
         where problemguid = ip_guid order by update_timestamp descending.

    endselect.

    if sy-subrc eq 0.

      " Calculating difference between movement from 'On Approval' to 'Information Requested' and backwards

      lv_difference_in_seconds = zcl_assistant_utilities=>calc_duration_btw_timestamps(
       exporting
           ip_timestamp_1 = lv_irt_update_timestamp
           ip_timestamp_2 = lv_timestamp_of_status_switch ).

      " Calculating new value for IRT and storing it

      call function 'TIMESTAMP_DURATION_ADD'
        exporting
          timestamp_in    = lv_old_irt_timestamp
          timezone        = lv_old_irt_timezone
          duration        = lv_difference_in_seconds
          unit            = 'S'
        importing
          timestamp_out   = lv_new_irt_timestamp
        exceptions
          timestamp_error = 1
          others          = 2.

      update scapptseg set
          tst_from =  lv_new_irt_timestamp
          tst_to = lv_new_irt_timestamp
      where
          appt_guid = lv_appt_guid.

    endif.

  endmethod.


  method store_irt_sla.


    data:
      lo_slmp_problem_api       type ref to zcl_slpm_problem_api,
      lt_appointments           type crmt_appointment_wrkt,
      ls_srv_rfirst_appointment type crmt_appointment_wrk,
      ls_zslpm_irt_hist         type zslpm_irt_hist.

    lo_slmp_problem_api       = new zcl_slpm_problem_api(  ).

    lt_appointments = lo_slmp_problem_api->zif_custom_crm_order_read~get_all_appointments_by_guid( ip_guid ).

    try.

        ls_srv_rfirst_appointment = lt_appointments[ appt_type = 'SRV_RFIRST' ].

      catch cx_sy_itab_line_not_found.

    endtry.

    " Storing old IRT SLA

    select single tst_from zone_from into ( ls_zslpm_irt_hist-irttimestamp, ls_zslpm_irt_hist-irttimezone )
     from scapptseg
     where appt_guid = ls_srv_rfirst_appointment-appt_guid.

    if sy-subrc eq 0.

      ls_zslpm_irt_hist-guid = zcl_assistant_utilities=>generate_x16_guid(  ).
      ls_zslpm_irt_hist-apptguid = ls_srv_rfirst_appointment-appt_guid.
      ls_zslpm_irt_hist-problemguid = ip_guid.
      get time stamp field ls_zslpm_irt_hist-update_timestamp.
      ls_zslpm_irt_hist-irtperc = ip_irt_perc.
      ls_zslpm_irt_hist-update_timezone = zcl_assistant_utilities=>get_system_timezone( ).

      insert zslpm_irt_hist from ls_zslpm_irt_hist.

    endif.

  endmethod.

  method post_update_external_actions.

    data: lv_method_name     type string,
          lv_log_record_text type string,
          ptab               type abap_parmbind_tab.

    " When status is changed from 'Information Requested' to 'In approval'
    " we need to store IRT SLA timestamp and recalculate a new one

    if ( mo_active_configuration->get_parameter_value( 'PAUSE_IRT_ON_INFORMATION_REQUESTED_STAT' ) eq 'X').

      if ( is_problem_old_state-status = 'E0016' and is_problem_new_state-status = 'E0017' ).

        lv_method_name = |STORE_IRT_SLA|.

        ptab = value #(
               ( name = 'IP_GUID' value = ref #( is_problem_new_state-guid ) kind = cl_abap_objectdescr=>exporting )
               ( name = 'IP_IRT_PERC' value = ref #( is_problem_new_state-irt_perc ) kind = cl_abap_objectdescr=>exporting )
           ).

      endif.

      if ( is_problem_old_state-status = 'E0017' and is_problem_new_state-status = 'E0016' ).

        lv_method_name = |RECALC_IRT_SLA|.

        ptab = value #(
               ( name = 'IP_GUID' value = ref #( is_problem_new_state-guid ) kind = cl_abap_objectdescr=>exporting )
           ).

      endif.

    endif.

    if lv_method_name is not initial.

      try.

          call method me->(lv_method_name)
            parameter-table
            ptab.

        catch cx_sy_dyn_call_error into data(lcx_process_exception).

          lv_log_record_text = lcx_process_exception->get_text(  ) .
          mo_log->zif_logger~err( lv_log_record_text  ).

      endtry.

    endif.

  endmethod.

endclass.
