class zcl_slpm_problem_history_store definition
  public
  final
  create public .

  public section.

    interfaces:

      zif_slpm_problem_history_store,

      zif_slpm_problem_observer.

    methods:
      constructor
        importing
          ip_guid type crmt_object_guid
        raising
          zcx_slpm_configuration_exc
          zcx_crm_order_api_exc
          zcx_system_user_exc
          zcx_slpm_data_manager_exc.

  protected section.
  private section.

    types: begin of ty_field_to_supplement,

             field               type char50,
             supplementary_field type char50,
             method              type string,
             method_input_param  type abap_parmname,
             method_return_param type abap_parmname,

           end of ty_field_to_supplement.

    types: tt_fields_to_supplement type table of ty_field_to_supplement.

    data:
      mv_guid                      type crmt_object_guid,
      mv_event                     type char1,
      ms_zslpm_pr_his_hdr          type zslpm_pr_his_hdr,
      ms_problem                   type zcrm_order_ts_sl_problem,
      mv_file_name                 type string,
      mv_change_guid               type sysuuid_x16,
      mo_password                  type string value 'veYlJeW&C6',
      mt_fields_to_skip_on_display type table of abap_compname,
      mt_translation_table         type table of zslpm_pr_fld_trs,
      mt_fields_to_supplement      type tt_fields_to_supplement,
      mo_slpm_data_provider        type ref to zif_slpm_data_manager,
      mt_priorities                type zcrm_order_tt_priorities,
      mt_statuses                  type zcrm_order_tt_statuses.


    methods:


      add_creation_event_record
        importing
          is_problem type zcrm_order_ts_sl_problem
        raising
          zcx_assistant_utilities_exc,

      add_update_event_record
        importing
          is_problem type zcrm_order_ts_sl_problem
        raising
          zcx_assistant_utilities_exc,

      add_event_record
        importing
          is_problem type zcrm_order_ts_sl_problem
        raising
          zcx_assistant_utilities_exc,

      add_hist_header_record_to_db,

      set_hist_header_record,

      add_hist_detail_record_to_db
        raising
          zcx_assistant_utilities_exc,

      set_problem_record
        importing
          is_problem type zcrm_order_ts_sl_problem,

      add_att_upload_event_record
        importing
          ip_file_name type string,

      add_att_remove_event_record
        importing
          ip_file_name type string,

      add_att_event_record
        importing
          ip_file_name type string,

      set_file_name
        importing
          ip_file_name type string,

      add_hist_att_record_to_db,

      fill_fields_to_skip_on_display,

      translate_field_name
        importing
          ip_field_name         type char50
        returning
          value(rp_translation) type char50,

      set_translation_table,

      fill_fields_to_supplement,

      get_statustext
        importing
          ip_status            type string
        returning
          value(rs_statustext) type string
        raising
          zcx_crm_order_api_exc
          zcx_system_user_exc,

      get_processorname
        importing
          ip_bp                   type string
        returning
          value(rs_processorname) type string,

      get_prioritytext
        importing
          ip_priority            type string
        returning
          value(rs_prioritytext) type string
        raising
          zcx_crm_order_api_exc
          zcx_system_user_exc,

      set_slpm_data_provider
        raising
          zcx_slpm_configuration_exc
          zcx_crm_order_api_exc
          zcx_system_user_exc
          zcx_slpm_data_manager_exc.

endclass.


class zcl_slpm_problem_history_store implementation.

  method add_event_record.


    me->set_problem_record( is_problem ).

    me->set_hist_header_record(  ).

    me->add_hist_header_record_to_db(  ).

    me->add_hist_detail_record_to_db(  ).

  endmethod.


  method add_hist_detail_record_to_db.

    data:
      wa_zslpm_pr_his_rec    type zslpm_pr_his_rec,
      lt_problem             type table of zcrm_order_ts_sl_problem,
      lo_descr               type ref to cl_abap_tabledescr,
      lo_type                type ref to cl_abap_datadescr,
      lo_struct              type ref to cl_abap_structdescr,
      lt_components          type  abap_compdescr_tab,
      lo_descr_ref           type ref to cl_abap_typedescr,
      lv_adapted_field_value type string.

    field-symbols : <lv_value> type any.

    append ms_problem to lt_problem.

    lo_descr ?= cl_abap_typedescr=>describe_by_data( lt_problem ).
    lo_type = lo_descr->get_table_line_type( ).
    lo_struct ?= cl_abap_typedescr=>describe_by_name( lo_type->absolute_name ).

    " The approach below is used, as it
    " also picks all structure includes up

    lt_components =  lo_struct->components.

    loop at lt_components assigning field-symbol(<ls_component>).

      clear lv_adapted_field_value.

      if <lv_value> is assigned.
        unassign <lv_value>.
      endif.

      if <ls_component>-name is not initial.

        assign component <ls_component>-name of structure ms_problem to <lv_value>.

        if sy-subrc = 0.

          if ( <lv_value> is assigned ) and ( <lv_value> is not initial ).

            lo_descr_ref = cl_abap_typedescr=>describe_by_data( <lv_value> ).

            if ( lo_descr_ref->absolute_name eq '\TYPE=COMT_CREATED_AT_USR' ) or
                ( lo_descr_ref->absolute_name eq '\TYPE=CRMT_DATE_TIMESTAMP_FROM' ) .

              lv_adapted_field_value = zcl_assistant_utilities=>format_timestamp( <lv_value> ).

            else.

              lv_adapted_field_value = <lv_value>.

            endif.

            clear wa_zslpm_pr_his_rec.

            wa_zslpm_pr_his_rec-change_guid = mv_change_guid.
            wa_zslpm_pr_his_rec-field = <ls_component>-name.
            wa_zslpm_pr_his_rec-value = lv_adapted_field_value.

            insert zslpm_pr_his_rec from wa_zslpm_pr_his_rec.

          endif.

        endif.

      endif.

    endloop.

  endmethod.


  method add_hist_header_record_to_db.

    insert  zslpm_pr_his_hdr from ms_zslpm_pr_his_hdr.

  endmethod.


  method constructor.

    mv_guid = ip_guid.

    me->fill_fields_to_skip_on_display( ).

    me->fill_fields_to_supplement( ).

    me->set_slpm_data_provider( ).

  endmethod.


  method set_hist_header_record.

    mv_change_guid = zcl_assistant_utilities=>generate_x16_guid(  ).

    ms_zslpm_pr_his_hdr-guid = mv_guid.
    ms_zslpm_pr_his_hdr-username = sy-uname.
    ms_zslpm_pr_his_hdr-change_date = sy-datum.
    ms_zslpm_pr_his_hdr-change_time = sy-uzeit.
    ms_zslpm_pr_his_hdr-event = mv_event.
    ms_zslpm_pr_his_hdr-change_guid = mv_change_guid.

  endmethod.


  method set_problem_record.

    ms_problem = is_problem.

  endmethod.


  method add_creation_event_record.

    mv_event = 'C'.

    if is_problem is not initial.

      me->add_event_record( is_problem ).

    endif.

  endmethod.


  method add_update_event_record.

    mv_event = 'U'.

    if is_problem is not initial.

      me->add_event_record( is_problem ).

    endif.

  endmethod.


  method zif_slpm_problem_history_store~get_problem_history_headers.

    select
         change_guid
         guid
         username
         change_date
         change_time
         event
      into corresponding fields of table rt_zslpm_pr_his_hdr
         from zslpm_pr_his_hdr
         where guid = mv_guid.


  endmethod.


  method zif_slpm_problem_history_store~get_problem_history_hierarchy.

    data: lt_zslpm_pr_his_hdr type zslpm_tt_pr_his_hdr,
          lt_zslpm_pr_his_rec type zslpm_tt_pr_his_rec,
          ls_zslpm_pr_his_hry type zslpm_ts_pr_his_hry,
          lv_nodeid_counter   type int4 value 1,
          lv_parent_nodeid    type int4,
          lt_method_params    type abap_parmbind_tab,
          lv_method           type string.

    if mt_translation_table is initial.

      me->set_translation_table( ).

    endif.

    select
       change_guid
       guid
       username
       change_date
       change_time
       event
    into corresponding fields of table lt_zslpm_pr_his_hdr
       from zslpm_pr_his_hdr
       where guid = mv_guid.


    loop at lt_zslpm_pr_his_hdr assigning field-symbol(<ls_zslpm_pr_his_hdr>).

      clear ls_zslpm_pr_his_hry.

      ls_zslpm_pr_his_hry-nodeid = lv_nodeid_counter.
      ls_zslpm_pr_his_hry-hierarchylevel = 0.
      ls_zslpm_pr_his_hry-description = 'asd'.
      ls_zslpm_pr_his_hry-drillstate = 'expanded'.

      ls_zslpm_pr_his_hry-guid = <ls_zslpm_pr_his_hdr>-guid.
      ls_zslpm_pr_his_hry-username = <ls_zslpm_pr_his_hdr>-username.
      ls_zslpm_pr_his_hry-change_date = <ls_zslpm_pr_his_hdr>-change_date.
      ls_zslpm_pr_his_hry-change_time = <ls_zslpm_pr_his_hdr>-change_time.
      ls_zslpm_pr_his_hry-event = <ls_zslpm_pr_his_hdr>-event.
      ls_zslpm_pr_his_hry-change_guid = <ls_zslpm_pr_his_hdr>-change_guid.

      append ls_zslpm_pr_his_hry to rt_zslpm_pr_his_hry.

      lv_parent_nodeid = lv_nodeid_counter.

      lv_nodeid_counter = lv_nodeid_counter + 1.

      clear lt_zslpm_pr_his_rec.

      select
        change_guid
        field
        value
     into corresponding fields of table lt_zslpm_pr_his_rec
        from zslpm_pr_his_rec
        where change_guid = <ls_zslpm_pr_his_hdr>-change_guid.

      loop at lt_zslpm_pr_his_rec assigning field-symbol(<ls_zslpm_pr_his_rec>).

*        if line_exists(  mt_fields_to_skip_on_display[ table_line = <ls_zslpm_pr_his_rec>-field ] ).
*
*          continue.
*
*        endif.

        ls_zslpm_pr_his_hry-nodeid = lv_nodeid_counter.
        ls_zslpm_pr_his_hry-hierarchylevel = 1.
        ls_zslpm_pr_his_hry-description = 'asd'.
        ls_zslpm_pr_his_hry-parentnodeid = lv_parent_nodeid.
        ls_zslpm_pr_his_hry-drillstate = 'leaf'.

        ls_zslpm_pr_his_hry-field = translate_field_name( <ls_zslpm_pr_his_rec>-field ).

        ls_zslpm_pr_his_hry-value = <ls_zslpm_pr_his_rec>-value.

        if not line_exists(  mt_fields_to_skip_on_display[ table_line = <ls_zslpm_pr_his_rec>-field ] ).

          append ls_zslpm_pr_his_hry to rt_zslpm_pr_his_hry.

        endif.

        lv_nodeid_counter = lv_nodeid_counter + 1.

        " Adding a complimentary field for update related records

        if  ( <ls_zslpm_pr_his_hdr>-event eq 'U' ) and
            ( line_exists( mt_fields_to_supplement[ field = <ls_zslpm_pr_his_rec>-field ] ) ).

          "clear ls_zslpm_pr_his_hry.

          ls_zslpm_pr_his_hry-nodeid = lv_nodeid_counter.
          ls_zslpm_pr_his_hry-hierarchylevel = 1.
          ls_zslpm_pr_his_hry-description = 'asd'.
          ls_zslpm_pr_his_hry-parentnodeid = lv_parent_nodeid.
          ls_zslpm_pr_his_hry-drillstate = 'leaf'.

          ls_zslpm_pr_his_hry-field = translate_field_name( mt_fields_to_supplement[ field = <ls_zslpm_pr_his_rec>-field ]-supplementary_field ).

          try.

              lv_method = mt_fields_to_supplement[ field = <ls_zslpm_pr_his_rec>-field ]-method.

              lt_method_params = value #(
                 ( name = mt_fields_to_supplement[ field = <ls_zslpm_pr_his_rec>-field ]-method_input_param
                    value = ref #( <ls_zslpm_pr_his_rec>-value )
                        kind = cl_abap_objectdescr=>exporting )

                 ( name = mt_fields_to_supplement[ field = <ls_zslpm_pr_his_rec>-field ]-method_return_param
                    value = ref #( ls_zslpm_pr_his_hry-value )
                        kind = cl_abap_objectdescr=>returning )

              ).

              call method me->(lv_method)
                parameter-table
                lt_method_params.

            catch cx_sy_dyn_call_error into  data(lcx_process_exception).
              data(lv_error) = lcx_process_exception->get_text(  ) .
          endtry.

          append ls_zslpm_pr_his_hry to rt_zslpm_pr_his_hry.

          lv_nodeid_counter = lv_nodeid_counter + 1.

        endif.

      endloop.

    endloop.


  endmethod.


  method zif_slpm_problem_history_store~get_problem_history_records.

    data: lt_zslpm_pr_his_hdr type zslpm_tt_pr_his_hdr,
          lt_zslpm_pr_his_rec type zslpm_tt_pr_his_rec.

    select
       change_guid
       guid
       username
       change_date
       change_time
       event
    into corresponding fields of table lt_zslpm_pr_his_hdr
       from zslpm_pr_his_hdr
       where guid = mv_guid.

    loop at lt_zslpm_pr_his_hdr assigning field-symbol(<ls_zslpm_pr_his_hdr>).

      clear lt_zslpm_pr_his_rec.

      select
        change_guid
        field
        value
     into corresponding fields of table lt_zslpm_pr_his_rec
        from zslpm_pr_his_rec
        where change_guid = <ls_zslpm_pr_his_hdr>-change_guid.

      append lines of lt_zslpm_pr_his_rec to rt_zslpm_pr_his_rec.


    endloop.

  endmethod.

  method zif_slpm_problem_observer~problem_created.

    add_creation_event_record( is_problem ).

  endmethod.

  method zif_slpm_problem_observer~problem_updated.

    add_update_event_record( is_problem ).

  endmethod.

  method zif_slpm_problem_observer~attachment_uploaded.

    add_att_upload_event_record( ip_file_name ).

  endmethod.

  method zif_slpm_problem_observer~attachment_removed.

    add_att_remove_event_record( ip_file_name ).

  endmethod.

  method add_att_upload_event_record.

    " Attachment upload event

    mv_event = 'A'.

    me->add_att_event_record( ip_file_name ).

  endmethod.

  method add_att_remove_event_record.

    " Attachment removal event

    mv_event = 'R'.

    me->add_att_event_record( ip_file_name ).

  endmethod.

  method add_att_event_record.

    me->set_file_name( ip_file_name ).

    me->set_hist_header_record(  ).

    me->add_hist_header_record_to_db(  ).

    me->add_hist_att_record_to_db(  ).

  endmethod.

  method set_file_name.

    mv_file_name = ip_file_name.

  endmethod.

  method add_hist_att_record_to_db.

    data:
      wa_zslpm_pr_his_rec type zslpm_pr_his_rec.

    wa_zslpm_pr_his_rec-change_guid = mv_change_guid.
    wa_zslpm_pr_his_rec-field = 'FILENAME'.
    wa_zslpm_pr_his_rec-value = mv_file_name.

    insert zslpm_pr_his_rec from wa_zslpm_pr_his_rec.

  endmethod.

  method zif_slpm_problem_history_store~arch_orphaned_history_records.

    data:
      lo_system_user          type ref to zif_system_user,
      lo_slpm_user            type ref to zif_slpm_user,
      lo_active_configuration type ref to zif_slpm_configuration,
      lo_slpm_problem_api     type ref to zcl_slpm_problem_api,
      lt_problems_guids       type zcrm_order_tt_guids,
      lt_orphaned_guids       type table of crmt_object_guid,
      lt_history_store        type table of zslpm_pr_his_hdr.


    lo_slpm_user = new zcl_slpm_user( sy-uname ).

    lo_system_user ?= lo_slpm_user.

    if lo_slpm_user->is_auth_to_read_problems(  ) eq abap_true.

      lo_active_configuration = new zcl_slpm_configuration(  ).

      lo_slpm_problem_api = new zcl_slpm_problem_api( lo_active_configuration ).

      lt_problems_guids      = lo_slpm_problem_api->zif_custom_crm_order_read~get_guids_list(  ).

      select
        mandt change_guid guid
        username change_date change_time
        event archived
            into table lt_history_store
                from zslpm_pr_his_hdr
                    where archived is null
                    or archived eq ''.

      loop at lt_history_store assigning field-symbol(<ls_history_rec>).

        if not line_exists( lt_problems_guids[ guid = <ls_history_rec>-guid ] ).

          update zslpm_pr_his_hdr set archived = 'X'
              where guid = <ls_history_rec>-guid.

        endif.

      endloop.


    else.

      " User has no authorizations to read problems

      raise exception type zcx_slpm_data_manager_exc
        exporting
          textid         = zcx_slpm_data_manager_exc=>not_authorized_for_read
          ip_system_user = sy-uname.

    endif.

  endmethod.

  method zif_slpm_problem_history_store~delete_arch_history_records.

    data lt_archived_his_records type table of sysuuid_x16.

    select
     change_guid
        into table lt_archived_his_records
            from zslpm_pr_his_hdr
                where archived eq 'X'.

    if ip_password eq mo_password. " Just a safety protection for db records deletion

      loop at lt_archived_his_records assigning field-symbol(<ls_archived_his_record>).

        delete from zslpm_pr_his_rec where change_guid eq <ls_archived_his_record>.

        delete from zslpm_pr_his_hdr where change_guid eq <ls_archived_his_record>.

      endloop.

    endif.

  endmethod.

  method fill_fields_to_skip_on_display.

    mt_fields_to_skip_on_display = value #(

        ( 'IRT_TIMESTAMP_UTC' )
        ( 'MPT_TIMESTAMP_UTC' )
        ( 'TOT_DURA_UNIT' )
        ( 'WORK_DURA_UNIT' )
        ( 'REQUESTERUPDATEENABLED' )
        ( 'REQUESTERWITHDRAWENABLED' )
        ( 'PROCESSORTAKEOVERENABLED' )
        ( 'IRT_ICON_BSP' )
        ( 'ITEM_GUID' )
        ( 'MPT_ICON_BSP' )
        ( 'MPT_ICON_BSP' )
        ( 'NOTE' )
        ( 'STATUS' )
        ( 'PROCESSORBUSINESSPARTNER')
        ( 'PRIORITY')
        ( 'REQUESTORBUSINESSPARTNER')
        ( 'COMPANYBUSINESSPARTNER')
        ( 'DEFAULTPROCESSINGORGUNIT' )
        ( 'PRODUCTGUID' )
    ).

  endmethod.

  method translate_field_name.

    try.

        rp_translation = mt_translation_table[ field_name = ip_field_name ]-translation.

      catch cx_sy_itab_line_not_found.

        rp_translation = ip_field_name.

    endtry.


  endmethod.

  method set_translation_table.

    select mandt field_name spras translation into table mt_translation_table
        from zslpm_pr_fld_trs
        where spras = sy-langu.

  endmethod.

  method fill_fields_to_supplement.

    mt_fields_to_supplement = value #(

      ( field = 'STATUS' supplementary_field = 'STATUSTEXT' method = 'GET_STATUSTEXT' method_input_param = 'IP_STATUS' method_return_param = 'RS_STATUSTEXT')
      ( field = 'PROCESSORBUSINESSPARTNER' supplementary_field = 'PROCESSORNAME' method = 'GET_PROCESSORNAME' method_input_param = 'IP_BP' method_return_param = 'RS_PROCESSORNAME')
      ( field = 'PRIORITY' supplementary_field = 'PRIORITYTEXT' method = 'GET_PRIORITYTEXT' method_input_param = 'IP_PRIORITY' method_return_param = 'RS_PRIORITYTEXT')

    ).

  endmethod.

  method get_statustext.

    if mt_statuses is initial.

      mt_statuses = mo_slpm_data_provider->get_all_statuses(  ).

    endif.

    try.

        rs_statustext = mt_statuses[ code = ip_status ]-text.

      catch cx_sy_itab_line_not_found.

    endtry.

  endmethod.

  method get_processorname.

    data lv_bp type bu_partner.

    lv_bp = ip_bp.

    rs_processorname = new zcl_bp_master_data( lv_bp )->zif_contacts_book~get_full_name(  ).

  endmethod.

  method get_prioritytext.

    if mt_priorities is initial.
      mt_priorities = mo_slpm_data_provider->get_all_priorities(  ).
    endif.

    try.

        rs_prioritytext = mt_priorities[ code = ip_priority ]-description.

      catch cx_sy_itab_line_not_found.

    endtry.
  endmethod.

  method set_slpm_data_provider.

    mo_slpm_data_provider = new zcl_slpm_data_manager_proxy(  ).

  endmethod.

endclass.
