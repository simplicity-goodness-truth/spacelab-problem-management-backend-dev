class zcl_slpm_data_manager_proxy definition
  public
  final
  create public .
  public section.

    interfaces zif_slpm_data_manager.

    methods constructor
      raising zcx_slpm_data_manager_exc
              zcx_slpm_configuration_exc
              zcx_system_user_exc
              zcx_crm_order_api_exc.

  protected section.
  private section.

    types: begin of ty_text_vulnerabilities_list,
             expression  type string,
             replacement type string,
           end of ty_text_vulnerabilities_list.

*    types: begin of ty_statuses_for_sla_shift,
*             statusin  type j_estat,
*             statusout type j_estat,
*           end of ty_statuses_for_sla_shift.

    data:
      mo_slpm_data_provider        type ref to zif_slpm_data_manager,
      mo_active_configuration      type ref to zif_slpm_configuration,
      mo_system_user               type ref to zif_system_user,
      mo_slpm_user                 type ref to zif_slpm_user,
      mo_log                       type ref to zcl_logger_to_app_log,
      mv_app_log_object            type balobj_d,
      mv_app_log_subobject         type balsubobj,
      mt_text_vulnerabilities_list type table of ty_text_vulnerabilities_list,
      mt_problem_observers         type standard table of ref to zif_slpm_problem_observer,
      mo_slpm_cache_controller     type ref to zif_slpm_problem_cache,
      mt_statuses_for_irt_recalc   type zslpm_tt_status_pairs,
      mt_statuses_for_irt_store    type zslpm_tt_status_pairs,
      mt_statuses_for_mpt_recalc   type zslpm_tt_status_pairs,
      mt_statuses_for_mpt_store    type zslpm_tt_status_pairs,
      mo_slpm_sla_irt_hist         type ref to zif_slpm_sla_hist,
      mo_slpm_sla_mpt_hist         type ref to zif_slpm_sla_hist.

    methods:

      get_srv_rfirst_appt_guid
        importing
          ip_guid             type crmt_object_guid
        returning
          value(rp_appt_guid) type sc_aptguid
        raising
          zcx_slpm_configuration_exc
          zcx_crm_order_api_exc
          zcx_system_user_exc,

      attach_observer
        importing
          io_observer type ref to zif_slpm_problem_observer,

      notify_observers_on_create
        importing
          is_problem type zcrm_order_ts_sl_problem,

      notify_observers_on_update
        importing
          is_problem type zcrm_order_ts_sl_problem,

      set_app_logger
        raising
          zcx_slpm_configuration_exc,

      post_update_external_actions
        importing
          is_problem_old_state type zcrm_order_ts_sl_problem
          is_problem_new_state type zcrm_order_ts_sl_problem
          is_payload           type zcrm_order_ts_sl_problem optional
        raising
          zcx_slpm_configuration_exc
          zcx_crm_order_api_exc
          zcx_system_user_exc,

      store_irt_sla
        importing
          ip_guid         type crmt_object_guid
          ip_irt_perc     type int4
          ip_statusin     type char5
          ip_statusout    type char5
          ip_priorityin   type crmt_priority
          ip_priorityout  type crmt_priority
          ip_manualchange type abap_bool optional
        raising
          zcx_slpm_configuration_exc
          zcx_crm_order_api_exc
          zcx_system_user_exc,

      store_mpt_sla
        importing
          ip_guid        type crmt_object_guid
          ip_mpt_perc    type int4
          ip_statusin    type char5
          ip_statusout   type char5
          ip_priorityin  type crmt_priority
          ip_priorityout type crmt_priority
        raising
          zcx_slpm_configuration_exc
          zcx_crm_order_api_exc
          zcx_system_user_exc,

      recalc_irt_sla
        importing
          ip_guid               type crmt_object_guid
          ip_avail_profile_name type srv_serwi
          ip_statusin           type char5
          ip_statusout          type char5
          ip_priorityin         type crmt_priority
          ip_priorityout        type crmt_priority
          ip_created_at         type  comt_created_at_usr
        raising
          zcx_slpm_configuration_exc
          zcx_crm_order_api_exc,

      adjust_scapptseg_irt
        importing
          ip_guid type crmt_object_guid,

      fill_vulnerabilities_list,

      clear_text_vulnerabilities
        changing
          cp_text type string,

      invalidate_problem_in_cache
        importing
          ip_guid type crmt_object_guid,

      get_problem_from_cache
        importing
          ip_guid           type crmt_object_guid
        returning
          value(rs_problem) type zcrm_order_ts_sl_problem
        raising
          zcx_slpm_configuration_exc,

      add_problem_to_cache
        importing
          is_problem type zcrm_order_ts_sl_problem
        raising
          zcx_slpm_configuration_exc,

      set_slpm_cache_controller
        raising
          zcx_slpm_configuration_exc,

      get_problem_through_cache
        importing
          ip_guid          type crmt_object_guid
        returning
          value(es_result) type zcrm_order_ts_sl_problem
        raising
          zcx_crm_order_api_exc
          zcx_assistant_utilities_exc
          zcx_slpm_configuration_exc
          zcx_system_user_exc,

      decode_problem
        importing
          ir_problem        type ref to data
          ip_table_name     type strukname
        returning
          value(rs_problem) type zcrm_order_ts_sl_problem,

      notify_observers_on_att_upload
        importing
          ip_file_name type string,

      notify_observers_on_att_remove
        importing
          ip_file_name type string,

      put_att_to_trash_bin
        importing
          ip_guid      type crmt_object_guid
          ip_content   type xstring
          ip_file_name type sdok_filnm
          ip_mime_type type w3conttype,

      adjust_product_in_new_problem
        importing
          is_problem_creation_payload type zcrm_order_ts_sl_problem
          is_problem_resulting_data   type zcrm_order_ts_sl_problem
        returning
          value(rs_problem)           type zcrm_order_ts_sl_problem,

      adjust_sla_in_new_problem
        changing
          cs_problem type zcrm_order_ts_sl_problem,

      recalc_mpt_sla
        importing
          ip_guid               type crmt_object_guid
          ip_avail_profile_name type srv_serwi
          ip_statusin           type char5
          ip_statusout          type char5
          ip_priorityin         type crmt_priority
          ip_priorityout        type crmt_priority
          ip_created_at         type  comt_created_at_usr
        raising
          zcx_slpm_configuration_exc
          zcx_crm_order_api_exc,

      adjust_scapptseg_mpt
        importing
          ip_guid type crmt_object_guid,

      fill_extra_fields_for_update
        changing
          cs_problem type zcrm_order_ts_sl_problem
        raising
          zcx_slpm_configuration_exc,

      set_statuses_for_mpt_recalc,

      set_statuses_for_irt_recalc,

      set_statuses_for_mpt_store,

      set_statuses_for_irt_store,

      set_slpm_sla_irt_hist
        importing
          ip_guid type crmt_object_guid,

      set_slpm_sla_mpt_hist
        importing
          ip_guid type crmt_object_guid,

      is_irt_overdue_before_store
        importing
          is_problem_old_state      type zcrm_order_ts_sl_problem
          is_problem_new_state      type zcrm_order_ts_sl_problem
        returning
          value(rp_sla_irt_overdue) type abap_bool,

      is_mpt_overdue_before_store
        importing
          is_problem_old_state      type zcrm_order_ts_sl_problem
          is_problem_new_state      type zcrm_order_ts_sl_problem
        returning
          value(rp_sla_mpt_overdue) type abap_bool.

endclass.



class zcl_slpm_data_manager_proxy implementation.


  method add_problem_to_cache.

    " ------Use approach below if a general cache interface ZIF_CACHE is used

*    data lr_problem type ref to data.
*
*    get reference of is_problem into lr_problem.
*
*    mo_slpm_cache_controller->add_record( lr_problem ).

    " ------Use approach below if a dedicated problem cache interface ZIF_SLPM_PROBLEM_CACHE is used

    mo_slpm_cache_controller->add_record( is_problem ).

  endmethod.


  method adjust_product_in_new_problem.

    " For some reason sometimes when a new problem is created
    " CL_AGS_CRM_1O_API method GET_SERVICE_PRODUCTS returns a default
    " product data instead of a custom one. That is why we need to force
    " an adjustment


    data lo_crm_product type ref to zif_crm_product.


    if ( is_problem_creation_payload-productguid ne is_problem_resulting_data-productguid ).

      move-corresponding is_problem_resulting_data to rs_problem.

      rs_problem-productguid = is_problem_creation_payload-productguid.
      rs_problem-productname = is_problem_creation_payload-productname.

      lo_crm_product = new zcl_crm_product( is_problem_creation_payload-productguid ).

      rs_problem-producttext = lo_crm_product->get_name(  ).

    endif.

  endmethod.


  method adjust_scapptseg_irt.

    data:
      lv_irt_update_timestamp    type timestamp,
      lv_irt_update_timezone     type timezone,
      lv_stored_irt_timestamp    type timestamp,
      lv_stored_irt_timezone     type timezone,
      lv_appt_guid               type sc_aptguid,
      lv_scapptseg_irt_timestamp type timestamp,
      lv_scapptseg_irt_timezone  type timezone.

    " Taking last stored IRT SLA

    select update_timestamp update_timezone irttimestamp irttimezone apptguid
      from zslpm_irt_hist
      into (lv_irt_update_timestamp, lv_irt_update_timezone, lv_stored_irt_timestamp, lv_stored_irt_timezone, lv_appt_guid)
      up to 1 rows
      where problemguid = ip_guid order by update_timestamp descending.

      if sy-subrc eq 0.

        select single tst_from zone_from into ( lv_scapptseg_irt_timestamp, lv_scapptseg_irt_timezone )
            from scapptseg
            where appt_guid = lv_appt_guid.

        if lv_stored_irt_timestamp > lv_scapptseg_irt_timestamp.

          update scapptseg set
              tst_from =  lv_stored_irt_timestamp
              tst_to = lv_stored_irt_timestamp
          where
              appt_guid = lv_appt_guid.

          commit work.

        endif.

      endif.

    endselect.

  endmethod.


  method adjust_scapptseg_mpt.

    data:
      lv_mpt_update_timestamp    type timestamp,
      lv_mpt_update_timezone     type timezone,
      lv_stored_mpt_timestamp    type timestamp,
      lv_stored_mpt_timezone     type timezone,
      lv_appt_guid               type sc_aptguid,
      lv_scapptseg_mpt_timestamp type timestamp,
      lv_scapptseg_mpt_timezone  type timezone.

    " Taking last stored IRT SLA

    select update_timestamp update_timezone mpttimestamp mpttimezone apptguid
      from zslpm_mpt_hist
      into (lv_mpt_update_timestamp, lv_mpt_update_timezone, lv_stored_mpt_timestamp, lv_stored_mpt_timezone, lv_appt_guid)
      up to 1 rows
      where problemguid = ip_guid order by update_timestamp descending.

      if sy-subrc eq 0.

        select single tst_from zone_from into ( lv_scapptseg_mpt_timestamp, lv_scapptseg_mpt_timezone )
            from scapptseg
            where appt_guid = lv_appt_guid.

        if lv_stored_mpt_timestamp > lv_scapptseg_mpt_timestamp.

          update scapptseg set
              tst_from =  lv_stored_mpt_timestamp
              tst_to = lv_stored_mpt_timestamp
          where
              appt_guid = lv_appt_guid.

        endif.

      endif.

    endselect.

  endmethod.


  method adjust_sla_in_new_problem.

    data:

      lo_slpm_product           type ref to zif_crm_service_product,
      lt_response_profile_table type crmt_escal_recno_tab,
      lv_srv_rf_dura            type timedura,
      lv_srv_rf_unit            type timeunitdu,
      lv_srv_rr_dura            type timedura,
      lv_srv_rr_unit            type timeunitdu,
      lv_srv_rf_dura_sec        type int4,
      lv_srv_rr_dura_sec        type int4,
      lv_srv_rf_dura_time_unit  type int4,
      lv_srv_rr_dura_time_unit  type int4,
      lv_avail_profile_name     type char258,
      lo_serv_profile           type ref to zif_serv_profile,
      lv_time                   type sy-uzeit,
      lv_date                   type sy-datum,
      lv_creation_time          type sy-uzeit,
      lv_creation_date          type sy-datum,
      lv_system_timezone        type timezone,
      lv_new_irt_timestamp      type timestamp,
      lv_new_mpt_timestamp      type timestamp,
      lv_new_irt_timestamp_utc  type timestamp,
      lv_new_mpt_timestamp_utc  type timestamp.


    lo_slpm_product           = new zcl_crm_service_product( cs_problem-productguid ).

    lv_avail_profile_name = lo_slpm_product->get_availability_profile_name(  ).

    lt_response_profile_table = lo_slpm_product->get_resp_profile_table( ).

    try.

        lv_srv_rf_dura = lt_response_profile_table[ srv_priority = cs_problem-priority srv_duraname = 'SRV_RF_DURA' ]-srv_dura.
        lv_srv_rr_dura = lt_response_profile_table[ srv_priority = cs_problem-priority srv_duraname = 'SRV_RR_DURA' ]-srv_dura.
        lv_srv_rf_unit = lt_response_profile_table[ srv_priority = cs_problem-priority srv_duraname = 'SRV_RF_DURA' ]-srv_unit.
        lv_srv_rr_unit = lt_response_profile_table[ srv_priority = cs_problem-priority srv_duraname = 'SRV_RR_DURA' ]-srv_unit.

        lv_srv_rf_dura_time_unit  = lv_srv_rf_dura.

        lv_srv_rf_dura_sec = zcl_assistant_utilities=>convert_time_to_seconds(
            exporting
                ip_amount_in_input_time_unit = lv_srv_rf_dura_time_unit
                ip_input_time_unit = lv_srv_rf_unit
        ).

        lv_srv_rr_dura_time_unit  = lv_srv_rr_dura.

        lv_srv_rr_dura_sec = zcl_assistant_utilities=>convert_time_to_seconds(
            exporting
                ip_amount_in_input_time_unit = lv_srv_rr_dura_time_unit
                ip_input_time_unit = lv_srv_rr_unit
        ).


        lv_system_timezone =  zcl_assistant_utilities=>get_system_timezone(  ).


        zcl_assistant_utilities=>get_date_time_from_timestamp(
                  exporting
                      ip_timestamp = cs_problem-created_at
                  importing
                      ep_date = lv_creation_date
                      ep_time = lv_creation_time ).

        lo_serv_profile = new zcl_serv_profile( lv_avail_profile_name  ).

        if lv_srv_rf_dura_sec is not initial.

          lo_serv_profile->add_seconds_to_date(
            exporting
                ip_added_seconds_total = lv_srv_rf_dura_sec
                ip_date_from = lv_creation_date
                ip_time_from = lv_creation_time
            importing
                ep_sla_date = lv_date
                ep_sla_time = lv_time ).

          convert date lv_date time lv_time into time stamp lv_new_irt_timestamp time zone lv_system_timezone.

          cs_problem-irt_timestamp = lv_new_irt_timestamp.
          cs_problem-irt_timestamp_utc = zcl_assistant_utilities=>convert_timestamp_to_timezone(
            exporting
                ip_timestamp = lv_new_irt_timestamp
                ip_timezone = 'UTC' ).

          cs_problem-irt_duration = lv_srv_rf_dura.
          cs_problem-irt_dura_unit = lv_srv_rf_unit.

          clear:  lv_time, lv_date.

        endif.


        if lv_srv_rr_dura_sec is not initial.

          lo_serv_profile->add_seconds_to_date(
                    exporting
                      ip_added_seconds_total = lv_srv_rr_dura_sec
                      ip_date_from = lv_creation_date
                      ip_time_from = lv_creation_time
                  importing
                      ep_sla_date = lv_date
                      ep_sla_time = lv_time ).

          convert date lv_date time lv_time into time stamp lv_new_mpt_timestamp time zone lv_system_timezone.

          cs_problem-mpt_timestamp = lv_new_mpt_timestamp.
          cs_problem-mpt_timestamp_utc = zcl_assistant_utilities=>convert_timestamp_to_timezone(
            exporting
                ip_timestamp = lv_new_mpt_timestamp
                ip_timezone = 'UTC' ).

          cs_problem-mpt_duration = lv_srv_rr_dura.
          cs_problem-mpt_dura_unit = lv_srv_rr_unit.

          clear:  lv_time, lv_date.

        endif.

      catch cx_sy_itab_line_not_found.

    endtry.

  endmethod.


  method attach_observer.

    append io_observer to mt_problem_observers.

  endmethod.


  method clear_text_vulnerabilities.

    loop at mt_text_vulnerabilities_list assigning field-symbol(<ls_text_vulnerability>).

      replace all occurrences of <ls_text_vulnerability>-expression in cp_text
        with <ls_text_vulnerability>-replacement.

    endloop.

  endmethod.


  method constructor.

    mo_slpm_user = new zcl_slpm_user( sy-uname ).

    mo_system_user ?= mo_slpm_user.

    if mo_slpm_user->is_auth_to_read_problems(  ) eq abap_true.

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

    me->fill_vulnerabilities_list(  ).

    me->set_slpm_cache_controller(  ).

    me->set_statuses_for_irt_recalc(  ).

    me->set_statuses_for_mpt_recalc(  ).

    me->set_statuses_for_irt_store(  ).

    me->set_statuses_for_mpt_store(  ).


  endmethod.


  method decode_problem.

    data:
       lr_table_wa type ref to data.

    field-symbols:
      <fs_problem> type any.

    create data lr_table_wa type (ip_table_name).

    assign lr_table_wa->* to <fs_problem>.

    if ( ir_problem is bound ).

      assign ir_problem->* to <fs_problem>.

      rs_problem =  <fs_problem>.


    endif.


  endmethod.


  method fill_extra_fields_for_update.

    data:
             lo_problem_processor type ref to zif_slpm_problem_processor.

    if ( cs_problem-processorbusinesspartner eq '0000000000').

      cs_problem-supportteambusinesspartner = '0000000000'.

    endif.

    " Setting Support Team

    if ( cs_problem-processorbusinesspartner is not initial ) and
        ( cs_problem-processorbusinesspartner ne '0000000000').

      lo_problem_processor = new zcl_slpm_problem_processor( cs_problem-processorbusinesspartner ).

      cs_problem-supportteambusinesspartner = lo_problem_processor->get_support_team_bp( ).

    endif.

  endmethod.


  method fill_vulnerabilities_list.

    mt_text_vulnerabilities_list = value #(
          ( expression = '<script' replacement = '-script-open-tag-')
          ( expression = '</script' replacement = '-script-close-tag-' )
          ( expression = '<' replacement = '-<-' )
          ( expression = '>' replacement = '->-' )
    ).

  endmethod.


  method get_problem_from_cache.

    " ------Use approach below if a general cache interface ZIF_CACHE is used

*    data: lr_guid    type ref to data,
*          lr_problem type ref to data.
*
*    get reference of ip_guid into lr_guid.
*
*    lr_problem = mo_slpm_cache_controller->get_record( lr_guid ).
*
*    rs_problem = decode_problem(
*     exporting
*          ip_table_name = 'ZCRM_ORDER_TS_SL_PROBLEM'
*          ir_problem = lr_problem ).

    " ------Use approach below if a dedicated problem cache interface ZIF_SLPM_PROBLEM_CACHE is used

    rs_problem = mo_slpm_cache_controller->get_record( ip_guid ).

  endmethod.


  method get_problem_through_cache.


    es_result = me->get_problem_from_cache( ip_guid ).

    if es_result is initial.

      es_result = mo_slpm_data_provider->get_problem( ip_guid ).

      add_problem_to_cache( es_result ).

    else.

      mo_slpm_data_provider->fill_cached_prb_calc_flds(

        exporting
            ip_guid = ip_guid
        changing
            cs_problem = es_result ).

    endif.


  endmethod.


  method get_srv_rfirst_appt_guid.

    data:
      lo_slmp_problem_api       type ref to zcl_slpm_problem_api,
      lt_appointments           type crmt_appointment_wrkt,
      ls_srv_rfirst_appointment type crmt_appointment_wrk.

    lo_slmp_problem_api       = new zcl_slpm_problem_api( mo_active_configuration ).

    lt_appointments = lo_slmp_problem_api->zif_custom_crm_order_read~get_all_appointments_by_guid( ip_guid ).

    try.

        ls_srv_rfirst_appointment = lt_appointments[ appt_type = 'SRV_RFIRST' ].

        rp_appt_guid = ls_srv_rfirst_appointment-appt_guid.

      catch cx_sy_itab_line_not_found.

    endtry.


  endmethod.


  method invalidate_problem_in_cache.

    mo_slpm_cache_controller->invalidate_record( ip_guid ).

  endmethod.


  method is_irt_overdue_before_store.

    data:
      lv_timestamp_irt type sc_tstfro,
      lv_timestamp_now type sc_tstfro,
      lv_timezone_irt  type sc_zonefro,
      lv_timezone_now  type sc_zonefro.

    " We must consent, that this method can only be called, if we are in a status, which requires IRT SLA store!
    " Basically the check for the proper status must happen in POST_UPDATE_EXTERNAL_ACTIONS before calling of this method
    " In addition this method must only be called when IRT SLA is paused


    " Getting current time stamp (now)

    get time stamp field lv_timestamp_now.
    lv_timezone_now = zcl_assistant_utilities=>get_system_timezone(  ).

    " Getting data from SLA history: if there were any recalculations, then
    " we should have a not empty history, and finally SLA timestamp from history should
    " be equal to the one in standard implementation

    mo_slpm_sla_irt_hist->get_last_sla_timestamp(
        importing
            ep_timestamp = lv_timestamp_irt
            ep_timezone = lv_timezone_irt ).

    if ( lv_timestamp_irt is initial ) and ( lv_timezone_irt is initial ).

      lv_timestamp_irt = is_problem_new_state-irt_timestamp_utc.

    endif.

    if lv_timestamp_now ge lv_timestamp_irt.

      rp_sla_irt_overdue = abap_true.

    endif.

  endmethod.


  method is_mpt_overdue_before_store.

    data:
      lv_timestamp_mpt type sc_tstfro,
      lv_timestamp_now type sc_tstfro,
      lv_timezone_mpt  type sc_zonefro,
      lv_timezone_now  type sc_zonefro.

    " We must consent, that this method can only be called, if we are in a status, which requires MPT SLA store!
    " Basically the check for the proper status must happen in POST_UPDATE_EXTERNAL_ACTIONS before calling of this method
    " In addition this method must only be called when MPT SLA is paused


    " Getting current time stamp (now)

    get time stamp field lv_timestamp_now.
    lv_timezone_now = zcl_assistant_utilities=>get_system_timezone(  ).

    " Getting data from SLA history: if there were any recalculations, then
    " we should have a not empty history, and finally SLA timestamp from history should
    " be equal to the one in standard implementation

    mo_slpm_sla_mpt_hist->get_last_sla_timestamp(
        importing
            ep_timestamp = lv_timestamp_mpt
            ep_timezone = lv_timezone_mpt ).

    if ( lv_timestamp_mpt is initial ) and ( lv_timezone_mpt is initial ).

      lv_timestamp_mpt = is_problem_new_state-mpt_timestamp_utc.

    endif.

    if lv_timestamp_now ge lv_timestamp_mpt.

      rp_sla_mpt_overdue = abap_true.

    endif.


  endmethod.


  method notify_observers_on_att_remove.

    loop at mt_problem_observers assigning field-symbol(<ms_observer>).

      <ms_observer>->attachment_removed( ip_file_name = ip_file_name ).

    endloop.

  endmethod.


  method notify_observers_on_att_upload.

    loop at mt_problem_observers assigning field-symbol(<ms_observer>).

      <ms_observer>->attachment_uploaded( ip_file_name = ip_file_name ).

    endloop.


  endmethod.


  method notify_observers_on_create.

    loop at mt_problem_observers assigning field-symbol(<ms_observer>).

      <ms_observer>->problem_created( is_problem ).

    endloop.

  endmethod.


  method notify_observers_on_update.

    loop at mt_problem_observers assigning field-symbol(<ms_observer>).

      <ms_observer>->problem_updated( is_problem ).

    endloop.

  endmethod.


  method post_update_external_actions.

    types: begin of ty_methods_list,
             method_name type string,
             parameters  type abap_parmbind_tab,
           end of ty_methods_list.

    data: lv_method_name                type string,
          lv_log_record_text            type string,
          lt_method_params              type abap_parmbind_tab,
          lt_common_params              type abap_parmbind_tab,
          lt_specific_params            type abap_parmbind_tab,
          lo_slpm_product               type ref to zif_crm_service_product,
          lv_avail_profile              type srv_serwi,
          lt_methods_list               type table of  ty_methods_list,
          ls_method                     type  ty_methods_list,
          lv_system_timezone            type timezone,
          lv_new_irt_timestamp          type timestamp,
          lv_appt_guid                  type sc_aptguid,
          lv_shift_irt_on_customer_stat type abap_bool,
          lv_shift_mpt_on_customer_stat type abap_bool,
          lv_shift_irt_only_not_due     type abap_bool,
          lv_shift_mpt_only_not_due     type abap_bool.


    " Getting SLA shifting parameters

    lv_shift_irt_on_customer_stat = mo_active_configuration->get_parameter_value( 'SHIFT_IRT_ON_INFORMATION_REQUESTED_STAT' ).
    lv_shift_mpt_on_customer_stat = mo_active_configuration->get_parameter_value( 'SHIFT_MPT_ON_INFORMATION_REQUESTED_STAT' ).
    lv_shift_irt_only_not_due = mo_active_configuration->get_parameter_value( 'SHIFT_ONLY_NOT_DUE_IRT' ).
    lv_shift_mpt_only_not_due = mo_active_configuration->get_parameter_value( 'SHIFT_ONLY_NOT_DUE_MPT' ).

    lt_common_params = value #(
                 ( name = 'IP_GUID' value = ref #( is_problem_new_state-guid ) kind = cl_abap_objectdescr=>exporting )
                 ( name = 'IP_STATUSIN' value = ref #( is_problem_old_state-status ) kind = cl_abap_objectdescr=>exporting )
                 ( name = 'IP_STATUSOUT' value = ref #( is_problem_new_state-status ) kind = cl_abap_objectdescr=>exporting )
                 ( name = 'IP_PRIORITYIN' value = ref #( is_problem_old_state-priority ) kind = cl_abap_objectdescr=>exporting )
                 ( name = 'IP_PRIORITYOUT' value = ref #( is_problem_new_state-priority ) kind = cl_abap_objectdescr=>exporting )
             ).


    " Initializing SLA history classes

    me->set_slpm_sla_irt_hist( is_problem_new_state-guid ).
    me->set_slpm_sla_mpt_hist( is_problem_new_state-guid ).

*    if  is_problem_old_state-status ne is_problem_new_state-status.
*
*      me->adjust_scapptseg_irt( is_problem_new_state-guid ).
*      me->adjust_scapptseg_mpt( is_problem_new_state-guid ).
*
*    endif.

    " Storing SLA if priority has been changed

    if ( is_problem_old_state-priority ne is_problem_new_state-priority ).

      lv_method_name = |STORE_IRT_SLA|.

      ls_method-method_name = lv_method_name.

      clear lt_method_params.
      lt_method_params = corresponding #( lt_common_params ).
      lt_specific_params = value #(

            ( name = 'IP_IRT_PERC' value = ref #( is_problem_new_state-irt_perc ) kind = cl_abap_objectdescr=>exporting )
        ).

      insert lines of lt_specific_params into table lt_method_params.

      ls_method-parameters = lt_method_params.

      append ls_method to lt_methods_list.

    endif.

    " Storing MPT and IRT SLAs for specific statuses

    if line_exists( mt_statuses_for_irt_store[ statusin = is_problem_old_state-status statusout = is_problem_new_state-status ] ).

      if ( lv_shift_irt_on_customer_stat eq 'X').

        if ( lv_shift_irt_only_not_due ne 'X' ) or
        ( ( lv_shift_irt_only_not_due eq 'X' ) and
            ( is_irt_overdue_before_store( is_problem_new_state = is_problem_new_state is_problem_old_state = is_problem_old_state )
                eq abap_false ) ).

          lv_method_name = |STORE_IRT_SLA|.
          ls_method-method_name = lv_method_name.

          clear lt_method_params.
          lt_method_params = corresponding #( lt_common_params ).

          lt_specific_params = value #(
                     ( name = 'IP_IRT_PERC' value = ref #( is_problem_old_state-irt_perc ) kind = cl_abap_objectdescr=>exporting )
                 ).

          insert lines of lt_specific_params into table lt_method_params.

          ls_method-parameters = lt_method_params.
          append ls_method to lt_methods_list.

        endif.

      endif.

    endif.

    if line_exists( mt_statuses_for_mpt_store[ statusin = is_problem_old_state-status statusout = is_problem_new_state-status ] ).

      if ( lv_shift_mpt_on_customer_stat eq 'X').

        if ( lv_shift_mpt_only_not_due ne 'X' ) or
               ( ( lv_shift_mpt_only_not_due eq 'X' ) and
                   ( is_mpt_overdue_before_store( is_problem_new_state = is_problem_new_state is_problem_old_state = is_problem_old_state )
                       eq abap_false ) ).

          lv_method_name = |STORE_MPT_SLA|.
          ls_method-method_name = lv_method_name.

          clear lt_method_params.
          lt_method_params = corresponding #( lt_common_params ).

          lt_specific_params = value #(
                     ( name = 'IP_MPT_PERC' value = ref #( is_problem_old_state-mpt_perc ) kind = cl_abap_objectdescr=>exporting )
                 ).

          insert lines of lt_specific_params into table lt_method_params.

          ls_method-parameters = lt_method_params.
          append ls_method to lt_methods_list.

        endif.

      endif.

    endif.

    " Recalculations for IRT and MPT SLAs

    if line_exists( mt_statuses_for_irt_recalc[ statusin = is_problem_old_state-status statusout = is_problem_new_state-status ] ).

      " Recalculation should be always done, if we are in a sequence of corresponding statuses change
      " and there was a previously stored record in IRT history, which means that we already awaiting
      " a shift of SLA, as we saved IRT data previously

      if ( lv_shift_irt_on_customer_stat eq 'X') and
        ( mo_slpm_sla_irt_hist->is_there_pending_shift( is_problem_old_state-status ) eq abap_true ).


        lv_method_name = |RECALC_IRT_SLA|.

        ls_method-method_name = lv_method_name.

        " Getting a name of an availability profile

        lo_slpm_product = new zcl_crm_service_product( is_problem_new_state-productguid ).

        lv_avail_profile = lo_slpm_product->get_availability_profile_name(  ).

        clear lt_method_params.
        lt_method_params = corresponding #( lt_common_params ).

        lt_specific_params = value #(
             ( name = 'IP_AVAIL_PROFILE_NAME' value = ref #( lv_avail_profile ) kind = cl_abap_objectdescr=>exporting )
             ( name = 'IP_CREATED_AT' value = ref #( is_problem_new_state-created_at ) kind = cl_abap_objectdescr=>exporting )
           ).

        insert lines of lt_specific_params into table lt_method_params.

        ls_method-parameters = lt_method_params.

        append ls_method to lt_methods_list.

      endif.

    endif.

    if line_exists( mt_statuses_for_mpt_recalc[ statusin = is_problem_old_state-status statusout = is_problem_new_state-status ] ).

      " Recalculation should be always done, if we are in a sequence of corresponding statuses change
      " and there was a previously stored record in MPT history, which means that we already awaiting
      " a shift of SLA, as we saved IRT data previously

      if ( lv_shift_mpt_on_customer_stat eq 'X') and
        ( mo_slpm_sla_mpt_hist->is_there_pending_shift( is_problem_old_state-status ) eq abap_true ).

        lv_method_name = |RECALC_MPT_SLA|.

        ls_method-method_name = lv_method_name.

        " Getting a name of an availability profile

        lo_slpm_product = new zcl_crm_service_product( is_problem_new_state-productguid ).

        lv_avail_profile = lo_slpm_product->get_availability_profile_name(  ).

        clear lt_method_params.
        lt_method_params = corresponding #( lt_common_params ).

        lt_specific_params = value #(
             ( name = 'IP_AVAIL_PROFILE_NAME' value = ref #( lv_avail_profile ) kind = cl_abap_objectdescr=>exporting )
             ( name = 'IP_CREATED_AT' value = ref #( is_problem_new_state-created_at ) kind = cl_abap_objectdescr=>exporting )
           ).

        insert lines of lt_specific_params into table lt_method_params.

        ls_method-parameters = lt_method_params.

        append ls_method to lt_methods_list.

      endif.

    endif.

    " Direct manual SLA update from frontend ( initial time goes in UTC)

    if ( is_payload-inputtimestamp is not initial ).

      " SLA IRT manual change

      if is_payload-irt_status eq 'MANCH'.

        " Storing old SLA

        lv_method_name = |STORE_IRT_SLA|.

        ls_method-method_name = lv_method_name.

        clear lt_method_params.
        lt_method_params = corresponding #( lt_common_params ).
        lt_specific_params = value #(

              ( name = 'IP_IRT_PERC' value = ref #( is_problem_new_state-irt_perc ) kind = cl_abap_objectdescr=>exporting )
              ( name = 'IP_MANUALCHANGE' value = ref #( 'X' ) kind = cl_abap_objectdescr=>exporting )
          ).

        insert lines of lt_specific_params into table lt_method_params.

        ls_method-parameters = lt_method_params.

        append ls_method to lt_methods_list.

      endif.

      lv_appt_guid = me->get_srv_rfirst_appt_guid( is_problem_new_state-guid ).

      update scapptseg set
        tst_from =  is_payload-inputtimestamp
        tst_to = is_payload-inputtimestamp
        where
            appt_guid = lv_appt_guid.


    endif.


    loop at lt_methods_list assigning field-symbol(<ls_method>).

      try.

          call method me->(<ls_method>-method_name)
            parameter-table
            <ls_method>-parameters.

        catch cx_sy_dyn_call_error into data(lcx_process_exception).

          lv_log_record_text = lcx_process_exception->get_text(  ) .
          mo_log->zif_logger~err( lv_log_record_text  ).

      endtry.

    endloop.

    if  is_problem_old_state-status ne is_problem_new_state-status.

      me->adjust_scapptseg_irt( is_problem_new_state-guid ).
      me->adjust_scapptseg_mpt( is_problem_new_state-guid ).

    endif.

  endmethod.


  method put_att_to_trash_bin.

    data lo_custom_crm_order_trash_bin type ref to zif_custom_crm_order_att_trash.

    lo_custom_crm_order_trash_bin = new zcl_custom_crm_order_att_trash(
        ip_guid = ip_guid
        ip_process_type = 'ZSLP'
        ).

    lo_custom_crm_order_trash_bin->put_att_to_trash_bin(
        ip_content = ip_content
        ip_file_name = ip_file_name
        ip_mime_type = ip_mime_type ).

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
         lv_appt_guid                  type sc_aptguid,
         lo_serv_profile_date_calc     type ref to zif_serv_profile,
         lv_avail_profile_name         type char258,
         lv_time                       type sy-uzeit,
         lv_date                       type sy-datum,
         lv_system_timezone            type timezone,
         ls_zslpm_irt_hist             type zslpm_irt_hist,
         lv_created_at_user_tzone      type comt_created_at_usr,
         lv_seconds_total_in_proc      type integer,
         lv_seconds_for_irt            type integer,
         lv_new_irt_perc               type int4,
         lv_current_timestamp          type timestamp.


    " Funny thing!!!
    " In our code we have to update scapptseg table to write shifted SLAs,
    " because we cannot set appointments through CRM order API (it just doesn't save it :-( )
    " However later somehow after each switch from 'In process' to 'Customer Action' OR from
    " 'On approval' to 'Information requested' all changed records in scapptseg table
    " ARE REVERTED BACK again to initial state!!! Don't know how and why it happens somewhere
    " deep in CRM ITSM...
    "
    " Finally after each save we have to compare recent scapptseg table SLA value and
    " those, which we stored in our custom tables. If scapptseg records were reverted,
    " then we have to re-write it once again....

    me->adjust_scapptseg_irt( ip_guid ).
    me->adjust_scapptseg_mpt( ip_guid ).

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

      lv_avail_profile_name = ip_avail_profile_name.

      lo_serv_profile_date_calc = new zcl_serv_profile( lv_avail_profile_name  ).

      zcl_assistant_utilities=>get_date_time_from_timestamp(
        exporting
            ip_timestamp = lv_old_irt_timestamp
            importing
            ep_date = lv_date
            ep_time = lv_time ).

      lo_serv_profile_date_calc->add_seconds_to_date(
        exporting
            ip_added_seconds_total = lv_difference_in_seconds
            ip_date_from = lv_date
            ip_time_from = lv_time
        importing
            ep_sla_date = lv_date
            ep_sla_time = lv_time ).

      lv_system_timezone =  zcl_assistant_utilities=>get_system_timezone(  ).

      convert date lv_date time lv_time into time stamp lv_new_irt_timestamp time zone lv_system_timezone.

      update scapptseg set
          tst_from =  lv_new_irt_timestamp
          tst_to = lv_new_irt_timestamp
      where
          appt_guid = lv_appt_guid.


      " Preparing new SLA IRT percentage calculation for history

      convert date sy-datum time sy-uzeit into time stamp lv_current_timestamp time zone 'UTC'.

      lv_created_at_user_tzone = zcl_assistant_utilities=>convert_timestamp_to_timezone(
        ip_timestamp = ip_created_at
        ip_timezone = sy-zonlo ).

      lv_seconds_total_in_proc = zcl_assistant_utilities=>calc_duration_btw_timestamps(
        exporting
            ip_timestamp_1 = lv_created_at_user_tzone
            ip_timestamp_2 = lv_current_timestamp ).

      lv_seconds_for_irt = zcl_assistant_utilities=>calc_duration_btw_timestamps(
      exporting
          ip_timestamp_1 = ip_created_at
          ip_timestamp_2 = lv_new_irt_timestamp ).

      lv_new_irt_perc = ( lv_seconds_total_in_proc * 100 ) div lv_seconds_for_irt.

      " Storing for further internal usage

      ls_zslpm_irt_hist-irttimestamp = lv_new_irt_timestamp.
      ls_zslpm_irt_hist-irttimezone = lv_system_timezone.
      ls_zslpm_irt_hist-guid = zcl_assistant_utilities=>generate_x16_guid(  ).
      ls_zslpm_irt_hist-apptguid = lv_appt_guid.
      ls_zslpm_irt_hist-problemguid = ip_guid.
      get time stamp field ls_zslpm_irt_hist-update_timestamp.
      ls_zslpm_irt_hist-irtperc = lv_new_irt_perc.
      ls_zslpm_irt_hist-update_timezone = zcl_assistant_utilities=>get_system_timezone( ).
      ls_zslpm_irt_hist-statusin = ip_statusin.
      ls_zslpm_irt_hist-statusout = ip_statusout.
      ls_zslpm_irt_hist-priorityin = ip_priorityin.
      ls_zslpm_irt_hist-priorityout = ip_priorityout.
      ls_zslpm_irt_hist-username = sy-uname.

      insert zslpm_irt_hist from ls_zslpm_irt_hist.

    endif.

  endmethod.


  method recalc_mpt_sla.

    data:lv_difference_in_seconds      type integer,
         lv_timestamp_of_status_switch type timestamp,
         lv_mpt_update_timestamp       type timestamp,
         lv_mpt_update_timezone        type timezone,
         lv_old_mpt_timestamp          type timestamp,
         lv_old_mpt_timezone           type timezone,
         lv_new_mpt_timestamp          type timestamp,
         lv_new_mpt_timezone           type timezone,
         lv_appt_guid                  type sc_aptguid,
         lo_serv_profile_date_calc     type ref to zif_serv_profile,
         lv_avail_profile_name         type char258,
         lv_time                       type sy-uzeit,
         lv_date                       type sy-datum,
         lv_system_timezone            type timezone,
         ls_zslpm_mpt_hist             type zslpm_mpt_hist,
         lv_created_at_user_tzone      type comt_created_at_usr,
         lv_seconds_total_in_proc      type integer,
         lv_seconds_for_mpt            type integer,
         lv_new_mpt_perc               type int4,
         lv_current_timestamp          type timestamp.


    " Funny thing!!!
    " In our code we have to update scapptseg table to write shifted SLAs,
    " because we cannot set appointments through CRM order API (it just doesn't save it :-( )
    " However later somehow after each switch from 'In process' to 'Customer Action' OR from
    " 'On approval' to 'Information requested' all changed records in scapptseg table
    " ARE REVERTED BACK again to initial state!!! Don't know how and why it happens somewhere
    " deep in CRM ITSM...
    "
    " Finally after each save we have to compare recent scapptseg table SLA value and
    " those, which we stored in our custom tables. If scapptseg records were reverted,
    " then we have to re-write it once again....

    me->adjust_scapptseg_irt( ip_guid ).
    me->adjust_scapptseg_mpt( ip_guid ).


    " Taking a timestamp when we switched back from 'Information Requested

    get time stamp field lv_timestamp_of_status_switch.

    " Taking last stored MPT SLA

    select  update_timestamp update_timezone mpttimestamp mpttimezone apptguid
        from zslpm_mpt_hist
        into (lv_mpt_update_timestamp, lv_mpt_update_timezone, lv_old_mpt_timestamp, lv_old_mpt_timezone, lv_appt_guid)
       up to 1 rows
         where problemguid = ip_guid order by update_timestamp descending.

    endselect.

    if sy-subrc eq 0.

      " Calculating difference between movement from 'On Approval' to 'Information Requested' and backwards

      lv_difference_in_seconds = zcl_assistant_utilities=>calc_duration_btw_timestamps(
       exporting
           ip_timestamp_1 = lv_mpt_update_timestamp
           ip_timestamp_2 = lv_timestamp_of_status_switch ).

      " Calculating new value for IRT and storing it

      lv_avail_profile_name = ip_avail_profile_name.

      lo_serv_profile_date_calc = new zcl_serv_profile( lv_avail_profile_name  ).

      zcl_assistant_utilities=>get_date_time_from_timestamp(
        exporting
            ip_timestamp = lv_old_mpt_timestamp
            importing
            ep_date = lv_date
            ep_time = lv_time ).

      lo_serv_profile_date_calc->add_seconds_to_date(
        exporting
            ip_added_seconds_total = lv_difference_in_seconds
            ip_date_from = lv_date
            ip_time_from = lv_time
        importing
            ep_sla_date = lv_date
            ep_sla_time = lv_time ).

      lv_system_timezone =  zcl_assistant_utilities=>get_system_timezone(  ).

      convert date lv_date time lv_time into time stamp lv_new_mpt_timestamp time zone lv_system_timezone.

      update scapptseg set
          tst_from =  lv_new_mpt_timestamp
          tst_to = lv_new_mpt_timestamp
      where
          appt_guid = lv_appt_guid.

      " Preparing new SLA MPT percentage calculation for history

      convert date sy-datum time sy-uzeit into time stamp lv_current_timestamp time zone 'UTC'.

      lv_created_at_user_tzone = zcl_assistant_utilities=>convert_timestamp_to_timezone(
        ip_timestamp = ip_created_at
        ip_timezone = sy-zonlo ).

      lv_seconds_total_in_proc = zcl_assistant_utilities=>calc_duration_btw_timestamps(
        exporting
            ip_timestamp_1 = lv_created_at_user_tzone
            ip_timestamp_2 = lv_current_timestamp ).

      lv_seconds_for_mpt = zcl_assistant_utilities=>calc_duration_btw_timestamps(
      exporting
          ip_timestamp_1 = ip_created_at
          ip_timestamp_2 = lv_new_mpt_timestamp ).

      lv_new_mpt_perc = ( lv_seconds_total_in_proc * 100 ) div lv_seconds_for_mpt.

      " Storing for further internal usage

      ls_zslpm_mpt_hist-mpttimestamp = lv_new_mpt_timestamp.
      ls_zslpm_mpt_hist-mpttimezone = lv_system_timezone.
      ls_zslpm_mpt_hist-guid = zcl_assistant_utilities=>generate_x16_guid(  ).
      ls_zslpm_mpt_hist-apptguid = lv_appt_guid.
      ls_zslpm_mpt_hist-problemguid = ip_guid.
      get time stamp field ls_zslpm_mpt_hist-update_timestamp.
      ls_zslpm_mpt_hist-mptperc = lv_new_mpt_perc.
      ls_zslpm_mpt_hist-update_timezone = zcl_assistant_utilities=>get_system_timezone( ).
      ls_zslpm_mpt_hist-statusin = ip_statusin.
      ls_zslpm_mpt_hist-statusout = ip_statusout.
      ls_zslpm_mpt_hist-priorityin = ip_priorityin.
      ls_zslpm_mpt_hist-priorityout = ip_priorityout.
      ls_zslpm_mpt_hist-username = sy-uname.

      insert zslpm_mpt_hist from ls_zslpm_mpt_hist.

    endif.

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


  method set_slpm_cache_controller.

    if  mo_slpm_cache_controller is not bound.

      mo_slpm_cache_controller = new zcl_slpm_problem_snlru_cache( mo_active_configuration ).

    endif.


  endmethod.


  method set_slpm_sla_irt_hist.

    mo_slpm_sla_irt_hist = new zcl_slpm_sla_irt_hist( ip_guid ).

  endmethod.


  method set_slpm_sla_mpt_hist.

    mo_slpm_sla_mpt_hist = new zcl_slpm_sla_mpt_hist( ip_guid ).

  endmethod.


  method set_statuses_for_irt_recalc.

*    mt_statuses_for_irt_recalc = value #(
*
*    ( statusin = 'E0017' statusout = 'E0016' )
*
*    ).

    mt_statuses_for_irt_recalc = new zcl_slpm_irt_recalc_statuses( )->zif_slpm_status_pairs~get_all_status_pairs( ).

  endmethod.


  method set_statuses_for_irt_store.

*    mt_statuses_for_irt_store = value #(
*
*    ( statusin = 'E0016' statusout = 'E0017' )
*
*    ).


    mt_statuses_for_irt_store = new zcl_slpm_irt_store_statuses( )->zif_slpm_status_pairs~get_all_status_pairs( ).

  endmethod.


  method set_statuses_for_mpt_recalc.

*    mt_statuses_for_mpt_recalc = value #(
*
*    ( statusin = 'E0017' statusout = 'E0016' )
*    ( statusin = 'E0003' statusout = 'E0002' )
*    ( statusin = 'E0005' statusout = 'E0002' )
*
*    ).

    mt_statuses_for_mpt_recalc = new zcl_slpm_mpt_recalc_statuses( )->zif_slpm_status_pairs~get_all_status_pairs( ).


  endmethod.


  method set_statuses_for_mpt_store.

*    mt_statuses_for_mpt_store = value #(
*
*    ( statusin = 'E0016' statusout = 'E0017' )
*    ( statusin = 'E0002' statusout = 'E0003' )
*    ( statusin = 'E0002' statusout = 'E0005' )
*
*    ).

    mt_statuses_for_mpt_store = new zcl_slpm_mpt_store_statuses( )->zif_slpm_status_pairs~get_all_status_pairs( ).


  endmethod.


  method store_irt_sla.


    data:
      lv_appt_guid      type sc_aptguid,
      ls_zslpm_irt_hist type zslpm_irt_hist.

    " Funny thing!!!
    " In our code we have to update scapptseg table to write shifted SLAs,
    " because we cannot set appointments through CRM order API (it just doesn't save it :-( )
    " However later somehow after each switch from 'In process' to 'Customer Action' OR from
    " 'On approval' to 'Information requested' all changed records in scapptseg table
    " ARE REVERTED BACK again to initial state!!! Don't know how and why it happens somewhere
    " deep in CRM ITSM...
    "
    " Finally after each save we have to compare recent scapptseg table SLA value and
    " those, which we stored in our custom tables. If scapptseg records were reverted,
    " then we have to re-write it once again....

    me->adjust_scapptseg_irt( ip_guid ).
    me->adjust_scapptseg_mpt( ip_guid ).


    lv_appt_guid = me->get_srv_rfirst_appt_guid( ip_guid ).

    " Storing old IRT SLA

    select single tst_from zone_from into ( ls_zslpm_irt_hist-irttimestamp, ls_zslpm_irt_hist-irttimezone )
     from scapptseg
     where appt_guid = lv_appt_guid.

    if sy-subrc eq 0.

      ls_zslpm_irt_hist-guid = zcl_assistant_utilities=>generate_x16_guid(  ).
      ls_zslpm_irt_hist-apptguid = lv_appt_guid.
      ls_zslpm_irt_hist-problemguid = ip_guid.
      get time stamp field ls_zslpm_irt_hist-update_timestamp.
      ls_zslpm_irt_hist-irtperc = ip_irt_perc.
      ls_zslpm_irt_hist-update_timezone = zcl_assistant_utilities=>get_system_timezone( ).
      ls_zslpm_irt_hist-statusin = ip_statusin.
      ls_zslpm_irt_hist-statusout = ip_statusout.
      ls_zslpm_irt_hist-priorityin = ip_priorityin.
      ls_zslpm_irt_hist-priorityout = ip_priorityout.
      ls_zslpm_irt_hist-manualchange = ip_manualchange.
      ls_zslpm_irt_hist-username = sy-uname.


      insert zslpm_irt_hist from ls_zslpm_irt_hist.

    endif.

  endmethod.


  method store_mpt_sla.


    data:
      lo_slmp_problem_api       type ref to zcl_slpm_problem_api,
      lt_appointments           type crmt_appointment_wrkt,
      ls_srv_rready_appointment type crmt_appointment_wrk,
      ls_zslpm_mpt_hist         type zslpm_mpt_hist.

    " Funny thing!!!
    " In our code we have to update scapptseg table to write shifted SLAs,
    " because we cannot set appointments through CRM order API (it just doesn't save it :-( )
    " However later somehow after each switch from 'In process' to 'Customer Action' OR from
    " 'On approval' to 'Information requested' all changed records in scapptseg table
    " ARE REVERTED BACK again to initial state!!! Don't know how and why it happens somewhere
    " deep in CRM ITSM...
    "
    " Finally after each save we have to compare recent scapptseg table SLA value and
    " those, which we stored in our custom tables. If scapptseg records were reverted,
    " then we have to re-write it once again....

    me->adjust_scapptseg_irt( ip_guid ).
    me->adjust_scapptseg_mpt( ip_guid ).

    lo_slmp_problem_api       = new zcl_slpm_problem_api( mo_active_configuration ).

    lt_appointments = lo_slmp_problem_api->zif_custom_crm_order_read~get_all_appointments_by_guid( ip_guid ).

    try.

        ls_srv_rready_appointment = lt_appointments[ appt_type = 'SRV_RREADY' ].

      catch cx_sy_itab_line_not_found.

    endtry.

    " Storing old MPT SLA

    select single tst_from zone_from into ( ls_zslpm_mpt_hist-mpttimestamp, ls_zslpm_mpt_hist-mpttimezone )
     from scapptseg
     where appt_guid = ls_srv_rready_appointment-appt_guid.

    if sy-subrc eq 0.

      ls_zslpm_mpt_hist-guid = zcl_assistant_utilities=>generate_x16_guid(  ).
      ls_zslpm_mpt_hist-apptguid = ls_srv_rready_appointment-appt_guid.
      ls_zslpm_mpt_hist-problemguid = ip_guid.
      get time stamp field ls_zslpm_mpt_hist-update_timestamp.
      ls_zslpm_mpt_hist-mptperc = ip_mpt_perc.
      ls_zslpm_mpt_hist-update_timezone = zcl_assistant_utilities=>get_system_timezone( ).
      ls_zslpm_mpt_hist-statusin = ip_statusin.
      ls_zslpm_mpt_hist-statusout = ip_statusout.
      ls_zslpm_mpt_hist-priorityin = ip_priorityin.
      ls_zslpm_mpt_hist-priorityout = ip_priorityout.
      ls_zslpm_mpt_hist-username = sy-uname.

      insert zslpm_mpt_hist from ls_zslpm_mpt_hist.

    endif.

  endmethod.


  method zif_slpm_data_manager~calc_non_stand_sla_status.

    if mo_slpm_data_provider is bound.

      mo_slpm_data_provider->calc_non_stand_sla_status(
        exporting
            ip_seconds_in_processing = ip_seconds_in_processing
            ip_created_at_user_tzone = ip_created_at_user_tzone
        changing
            cs_problem = cs_problem ).

    endif.


  endmethod.


  method zif_slpm_data_manager~create_attachment.

    if mo_slpm_data_provider is bound.

      mo_slpm_data_provider->create_attachment(
      exporting
          ip_content = ip_content
          ip_file_name = ip_file_name
          ip_guid = ip_guid
          ip_mime_type = ip_mime_type
          ip_visibility = ip_visibility ).

      " Adding a history store observer

      me->attach_observer( new zcl_slpm_problem_history_store( ip_guid ) ).

      " Informing all observers on an attachment uploading

      notify_observers_on_att_upload( ip_file_name ).

    endif.

  endmethod.


  method zif_slpm_data_manager~create_problem.


    data: ls_problem_newstate           type zcrm_order_ts_sl_problem,
          lo_slpm_prob_change_notifier  type ref to zif_crm_order_change_notifier,
          lo_slpm_user                  type ref to zif_slpm_user,
          lv_log_record_text            type string,
          lv_product_id                 type comt_product_id,
          lo_slpm_problem_history_store type ref to zif_slpm_problem_history_store.


    " User has no authorizations to create problems

    if mo_slpm_user->is_auth_to_create_problems(  ) eq abap_false.

      raise exception type zcx_slpm_data_manager_exc
        exporting
          textid         = zcx_slpm_data_manager_exc=>not_authorized_for_create
          ip_system_user = sy-uname.

    endif.


    if mo_slpm_data_provider is bound.

      " Check authorizations of a user to create a problem against a company

      "lo_slpm_user = new zcl_slpm_user( sy-uname ).

      if ( mo_slpm_user->is_auth_to_crea_company( is_problem-companybusinesspartner ) eq abap_false ).

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

      if ( mo_slpm_user->is_auth_to_crea_product( lv_product_id ) eq abap_false ).

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

*          me->notify_on_problem_change(
*              exporting
*              is_problem_new_state = rs_result
*              is_problem_old_state = is_problem ).

        catch  zcx_crm_order_api_exc zcx_assistant_utilities_exc into data(lcx_process_exception).

          raise exception type zcx_slpm_data_manager_exc
            exporting
              textid           = zcx_slpm_data_manager_exc=>internal_error
              ip_error_message = lcx_process_exception->get_text( ).

      endtry.

      " Due to a some reason after we force an update of CRMD_ORDERADM_I to set a new product during a
      " creation sequence in CRM order API the same API does not return a proper new product and corresponding
      " SLA recalculations, and correct values appear only after we do a next call from DPC_EXT class
      " (commit work or any other tricks do not help). To keep a correct product and SLA information in
      " all observers, we need to perform an adjustment below.
      " All above is related to a creation sequence only, for updates everything is fine.

      " Adjusting product in a new problem

      rs_result =  me->adjust_product_in_new_problem(
         exporting
         is_problem_creation_payload = is_problem
         is_problem_resulting_data = rs_result
         ).

      " Adjusting SLAs in new problem

      me->adjust_sla_in_new_problem(
         changing
         cs_problem = rs_result ).

      " Adding a change notifier observer for created problem

      me->attach_observer( new zcl_slpm_prob_change_notifier(
           io_active_configuration = mo_active_configuration
           is_problem_new_state = rs_result
           is_problem_old_state = is_problem ) ).

      " Adding a history store observer for created problem

      me->attach_observer( new zcl_slpm_problem_history_store( rs_result-guid ) ).

      " Executing notification on create

      notify_observers_on_create( rs_result ).


      " Add new problem guid to a table of cached guids

      if ( mo_active_configuration->get_parameter_value( 'USE_SNLRU_CACHE_FOR_PROBLEM_GUIDS_LIST' ) eq 'X').

        mo_slpm_cache_controller->add_guid_to_cached_prob_guids( rs_result-guid ).

      endif.


    endif.

  endmethod.


  method zif_slpm_data_manager~create_text.

    if mo_slpm_data_provider is bound.

      data lv_text type string.

      lv_text = ip_text.

      clear_text_vulnerabilities( changing cp_text = lv_text ).

      mo_slpm_data_provider->create_text(
             exporting
                 ip_guid = ip_guid
                 ip_tdid = ip_tdid
                 ip_text = lv_text ).

    endif.

  endmethod.


  method zif_slpm_data_manager~delete_attachment.

    data: lt_attachments_list type cl_ai_crm_gw_mymessage_mpc=>tt_attachment,
          ls_attachment       type cl_ai_crm_gw_mymessage_mpc=>ts_attachment,
          lv_file_name        type string.

    if mo_slpm_data_provider is bound.

      " Put a deleted attachment to a recycle bin for potential further restore
      " if a parameter USE_TRASH_BIN_FOR_DELETED_ATTACHMENTS is set

      if ( mo_active_configuration->get_parameter_value( 'USE_TRASH_BIN_FOR_DELETED_ATTACHMENTS' ) eq 'X').

        " Getting an attachment with it contents

        ls_attachment = me->zif_slpm_data_manager~get_attachment( ip_guid = ip_guid ip_loio = ip_loio ip_phio = ip_phio ).


        me->put_att_to_trash_bin(
            ip_guid = ip_guid
            ip_content = ls_attachment-document
            ip_file_name = ls_attachment-name
            ip_mime_type = ls_attachment-mimetype ).


      else.

        " Getting a file name from an attachments list to display file name in history
        " We use list of attachments, as it does not take a document contents

        me->zif_slpm_data_manager~get_attachments_list( exporting
            ip_guid = ip_guid
            importing
            et_attachments_list = lt_attachments_list ).

        try.

            ls_attachment = lt_attachments_list[ guid = ip_guid loio_id = ip_loio phio_id = ip_phio ].

          catch cx_sy_itab_line_not_found.

        endtry.

      endif.

      " Adding a history store observer

      me->attach_observer( new zcl_slpm_problem_history_store( ip_guid ) ).

      " Informing all observers on an attachment removal

      lv_file_name = ls_attachment-name.

      notify_observers_on_att_remove( lv_file_name ).

      mo_slpm_data_provider->delete_attachment(
           exporting
               ip_guid = ip_guid
               ip_loio = ip_loio
               ip_phio = ip_phio ).

    endif.

  endmethod.


  method zif_slpm_data_manager~fill_cached_prb_calc_flds.

    if mo_slpm_data_provider is bound.

      mo_slpm_data_provider->fill_cached_prb_calc_flds(
        exporting
            ip_guid = ip_guid
        changing
            cs_problem = cs_problem ).

    endif.

  endmethod.


  method zif_slpm_data_manager~get_active_configuration.

    if mo_slpm_data_provider is bound.

      ro_active_configuration = mo_slpm_data_provider->get_active_configuration( ).

    endif.


  endmethod.


  method zif_slpm_data_manager~get_all_priorities.

    if mo_slpm_data_provider is bound.
      rt_priorities = mo_slpm_data_provider->get_all_priorities(  ).
    endif.

  endmethod.


  method zif_slpm_data_manager~get_all_statuses.

    if mo_slpm_data_provider is bound.

      rt_statuses = mo_slpm_data_provider->get_all_statuses(  ).

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


  method zif_slpm_data_manager~get_final_status_codes.


    if mo_slpm_data_provider is bound.

      rt_final_status_codes = mo_slpm_data_provider->get_final_status_codes( ).

    endif.

  endmethod.


  method zif_slpm_data_manager~get_frontend_configuration.

    if mo_slpm_data_provider is bound.

      rt_frontend_configuration = mo_slpm_data_provider->get_frontend_configuration( ip_application ).

    endif.


  endmethod.


  method zif_slpm_data_manager~get_frontend_constants.

    if mo_slpm_data_provider is bound.

      rt_constants = mo_slpm_data_provider->get_frontend_constants( ).

    endif.

  endmethod.


  method zif_slpm_data_manager~get_last_text.

    if mo_slpm_data_provider is bound.

      mo_slpm_data_provider->get_last_text( exporting ip_guid = ip_guid ).

    endif.
  endmethod.


  method zif_slpm_data_manager~get_list_of_companies.

    if mo_slpm_data_provider is bound.

      rt_companies = mo_slpm_data_provider->get_list_of_companies(  ).

    endif.

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


  method zif_slpm_data_manager~get_list_of_support_teams.

    if mo_slpm_data_provider is bound.

      rt_support_teams = mo_slpm_data_provider->get_list_of_support_teams(  ).

    endif.

  endmethod.


  method zif_slpm_data_manager~get_priorities_of_product.

    if mo_slpm_data_provider is bound.
      rt_priorities = mo_slpm_data_provider->get_priorities_of_product( ip_guid ).
    endif.

  endmethod.


  method zif_slpm_data_manager~get_problem.

    if mo_slpm_data_provider is bound.

      if ( mo_active_configuration->get_parameter_value( 'USE_SNLRU_CACHE' ) eq 'X').

        es_result = me->get_problem_through_cache( ip_guid ).

      else.

        es_result = mo_slpm_data_provider->get_problem( ip_guid ).

      endif.

    endif.

  endmethod.


  method zif_slpm_data_manager~get_problems_list.

    if mo_slpm_data_provider is bound.

      et_result = mo_slpm_data_provider->get_problems_list(
      exporting
        it_filters = it_filters
        it_order = it_order
        ip_exclude_exp_fields = ip_exclude_exp_fields
        ip_search_string = ip_search_string ).

    endif.

  endmethod.


  method zif_slpm_data_manager~get_problem_sla_irt_history.

    if mo_slpm_data_provider is bound.

      rt_sla_irt_history = mo_slpm_data_provider->get_problem_sla_irt_history( ip_guid ).

    endif.

  endmethod.


  method zif_slpm_data_manager~get_problem_sla_mpt_history.

    if mo_slpm_data_provider is bound.

      rt_sla_mpt_history = mo_slpm_data_provider->get_problem_sla_mpt_history( ip_guid ).

    endif.

  endmethod.


  method zif_slpm_data_manager~get_texts.

    mo_slpm_data_provider->get_texts(
     exporting ip_guid = ip_guid
     importing et_texts = et_texts ).

  endmethod.


  method zif_slpm_data_manager~is_problem_dispute_open.

    if mo_slpm_data_provider is bound.

      rp_dispute_active = mo_slpm_data_provider->is_problem_dispute_open( ip_guid ).

    endif.


  endmethod.


  method zif_slpm_data_manager~is_status_a_customer_action.

    if mo_slpm_data_provider is bound.

      rp_customer_action = mo_slpm_data_provider->is_status_a_customer_action( ip_status ).

    endif.

  endmethod.


  method zif_slpm_data_manager~is_status_a_final_status.

    if mo_slpm_data_provider is bound.

      rp_final_status = mo_slpm_data_provider->is_status_a_final_status( ip_status ).

    endif.


  endmethod.


  method zif_slpm_data_manager~open_problem_dispute.

    data:
      ls_problem_old_state type zcrm_order_ts_sl_problem,
      lv_product_id        type comt_product_id,
      lv_log_record_text   type string.

    " User has no authorizations to update problems

    if mo_slpm_user->is_auth_to_update_problems(  ) eq abap_false.

      raise exception type zcx_slpm_data_manager_exc
        exporting
          textid         = zcx_slpm_data_manager_exc=>not_authorized_for_update
          ip_system_user = sy-uname.

    endif.

    if mo_slpm_data_provider is bound.

      ls_problem_old_state = mo_slpm_data_provider->get_problem(
                  exporting
                    ip_guid = ip_guid ).

      " Check authorizations of a user to update a problem against a company

      if ( mo_slpm_user->is_auth_to_update_company( ls_problem_old_state-companybusinesspartner ) eq abap_false ).

        message e009(zslpm_data_manager) with sy-uname ls_problem_old_state-companybusinesspartner into lv_log_record_text.

        mo_log->zif_logger~err( lv_log_record_text ).

        raise exception type zcx_slpm_data_manager_exc
          exporting
            textid         = zcx_slpm_data_manager_exc=>no_auth_for_update_for_company
            ip_system_user = sy-uname
            ip_company_bp  = ls_problem_old_state-companybusinesspartner.

      endif.

      " Check authorizations of a user to update a problem against a product

      lv_product_id = ls_problem_old_state-productname.

      if ( mo_slpm_user->is_auth_to_update_product( lv_product_id ) eq abap_false ).

        message e010(zslpm_data_manager) with sy-uname lv_product_id into lv_log_record_text.

        mo_log->zif_logger~err( lv_log_record_text ).

        raise exception type zcx_slpm_data_manager_exc
          exporting
            textid         = zcx_slpm_data_manager_exc=>no_auth_for_update_for_prod
            ip_system_user = sy-uname
            ip_product_id  = lv_product_id.

      endif.






      mo_slpm_data_provider->open_problem_dispute( ip_guid ).

    endif.

  endmethod.


  method zif_slpm_data_manager~update_problem.

    data: ls_problem_old_state          type zcrm_order_ts_sl_problem,
          lv_log_record_text            type string,
          lv_product_id                 type comt_product_id,
          lo_slpm_problem_history_store type ref to zif_slpm_problem_history_store,
          ls_problem                    type zcrm_order_ts_sl_problem.

    " User has no authorizations to update problems

    if mo_slpm_user->is_auth_to_update_problems(  ) eq abap_false.

      raise exception type zcx_slpm_data_manager_exc
        exporting
          textid         = zcx_slpm_data_manager_exc=>not_authorized_for_update
          ip_system_user = sy-uname.

    endif.

    if mo_slpm_data_provider is bound.

      try.

          ls_problem_old_state = mo_slpm_data_provider->get_problem(
              exporting
                ip_guid = ip_guid ).

          " Check authorizations of a user to update a problem against a company

          if ( mo_slpm_user->is_auth_to_update_company( ls_problem_old_state-companybusinesspartner ) eq abap_false ).

            message e009(zslpm_data_manager) with sy-uname ls_problem_old_state-companybusinesspartner into lv_log_record_text.

            mo_log->zif_logger~err( lv_log_record_text ).

            raise exception type zcx_slpm_data_manager_exc
              exporting
                textid         = zcx_slpm_data_manager_exc=>no_auth_for_update_for_company
                ip_system_user = sy-uname
                ip_company_bp  = ls_problem_old_state-companybusinesspartner.

          endif.

          " Check authorizations of a user to update a problem against a product

          lv_product_id = ls_problem_old_state-productname.

          if ( mo_slpm_user->is_auth_to_update_product( lv_product_id ) eq abap_false ).

            message e010(zslpm_data_manager) with sy-uname lv_product_id into lv_log_record_text.

            mo_log->zif_logger~err( lv_log_record_text ).

            raise exception type zcx_slpm_data_manager_exc
              exporting
                textid         = zcx_slpm_data_manager_exc=>no_auth_for_update_for_prod
                ip_system_user = sy-uname
                ip_product_id  = lv_product_id.

          endif.


          " Filling extra fields before update

          ls_problem = is_problem.

          me->fill_extra_fields_for_update( changing cs_problem = ls_problem ).

          rs_result = mo_slpm_data_provider->update_problem(
            exporting
                ip_guid = ip_guid
                is_problem = ls_problem
                ip_tdid = ip_tdid
                ip_text = ip_text ).

          me->post_update_external_actions(
               exporting
               is_problem_new_state = rs_result
               is_problem_old_state = ls_problem_old_state
               is_payload = ls_problem ).


          " Adding a change notifier observer for updated problem

          me->attach_observer( new zcl_slpm_prob_change_notifier(
                     io_active_configuration = mo_active_configuration
                     is_problem_new_state = rs_result
                     is_problem_old_state = ls_problem_old_state ) ).

          " Adding an observer for update problem

          me->attach_observer( new zcl_slpm_problem_history_store( rs_result-guid ) ).

          " Executing notification on update

          notify_observers_on_update( ls_problem ).

          " Invalidating record in cache

          if ( mo_active_configuration->get_parameter_value( 'USE_SNLRU_CACHE' ) eq 'X').

            invalidate_problem_in_cache( rs_result-guid ).

          endif.

        catch zcx_crm_order_api_exc into data(lcx_process_exception).

          raise exception type zcx_slpm_data_manager_exc
            exporting
              textid           = zcx_slpm_data_manager_exc=>internal_error
              ip_error_message = lcx_process_exception->get_text( ).
      endtry.

    endif.

  endmethod.

  method zif_slpm_data_manager~close_problem_dispute.

    data:
      ls_problem_old_state type zcrm_order_ts_sl_problem,
      lv_product_id        type comt_product_id,
      lv_log_record_text   type string.

    " User has no authorizations to update problems

    if mo_slpm_user->is_auth_to_update_problems(  ) eq abap_false.

      raise exception type zcx_slpm_data_manager_exc
        exporting
          textid         = zcx_slpm_data_manager_exc=>not_authorized_for_update
          ip_system_user = sy-uname.

    endif.

    if mo_slpm_data_provider is bound.

      ls_problem_old_state = mo_slpm_data_provider->get_problem(
            exporting
              ip_guid = ip_guid ).

      " Check authorizations of a user to update a problem against a company

      if ( mo_slpm_user->is_auth_to_update_company( ls_problem_old_state-companybusinesspartner ) eq abap_false ).

        message e009(zslpm_data_manager) with sy-uname ls_problem_old_state-companybusinesspartner into lv_log_record_text.

        mo_log->zif_logger~err( lv_log_record_text ).

        raise exception type zcx_slpm_data_manager_exc
          exporting
            textid         = zcx_slpm_data_manager_exc=>no_auth_for_update_for_company
            ip_system_user = sy-uname
            ip_company_bp  = ls_problem_old_state-companybusinesspartner.

      endif.

      " Check authorizations of a user to update a problem against a product

      lv_product_id = ls_problem_old_state-productname.

      if ( mo_slpm_user->is_auth_to_update_product( lv_product_id ) eq abap_false ).

        message e010(zslpm_data_manager) with sy-uname lv_product_id into lv_log_record_text.

        mo_log->zif_logger~err( lv_log_record_text ).

        raise exception type zcx_slpm_data_manager_exc
          exporting
            textid         = zcx_slpm_data_manager_exc=>no_auth_for_update_for_prod
            ip_system_user = sy-uname
            ip_product_id  = lv_product_id.

      endif.

      mo_slpm_data_provider->close_problem_dispute( ip_guid ).

    endif.

  endmethod.

  method zif_slpm_data_manager~get_problem_dispute_history.

    if mo_slpm_data_provider is bound.

      rt_dispute_history = mo_slpm_data_provider->get_problem_dispute_history( ip_guid ).

    endif.

  endmethod.

  method zif_slpm_data_manager~is_there_problem_dispute_hist.

    if mo_slpm_data_provider is bound.

      rp_dispute_hist_exists = mo_slpm_data_provider->is_problem_dispute_open( ip_guid ).

    endif.

  endmethod.

endclass.
