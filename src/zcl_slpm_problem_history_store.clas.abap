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
          ip_guid type crmt_object_guid.

  protected section.
  private section.
    data:
      mv_guid             type crmt_object_guid,
      mv_event            type char1,
      ms_zslpm_pr_his_hdr type zslpm_pr_his_hdr,
      ms_problem          type zcrm_order_ts_sl_problem,
      mv_file_name        type string,
      mv_change_guid      type sysuuid_x16.

    methods:


      add_creation_event_record
        importing
          is_problem type zcrm_order_ts_sl_problem,

      add_update_event_record
        importing
          is_problem type zcrm_order_ts_sl_problem,

      add_event_record
        importing
          is_problem type zcrm_order_ts_sl_problem,

      add_hist_header_record_to_db,

      set_hist_header_record,

      add_hist_detail_record_to_db,

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

      add_hist_att_record_to_db.

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
      wa_zslpm_pr_his_rec type zslpm_pr_his_rec,
      lt_problem          type table of zcrm_order_ts_sl_problem,
      lo_descr            type ref to cl_abap_tabledescr,
      lo_type             type ref to cl_abap_datadescr,
      lo_struct           type ref to cl_abap_structdescr,
      lt_components       type  abap_compdescr_tab.

    field-symbols : <lv_value> type any.

    append ms_problem to lt_problem.

    lo_descr ?= cl_abap_typedescr=>describe_by_data( lt_problem ).
    lo_type = lo_descr->get_table_line_type( ).
    lo_struct ?= cl_abap_typedescr=>describe_by_name( lo_type->absolute_name ).

    " The approach below is used, as it
    " also picks all structure includes up

    lt_components =  lo_struct->components.

    loop at lt_components assigning field-symbol(<ls_component>).

      if <lv_value> is assigned.
        unassign <lv_value>.
      endif.

      if <ls_component>-name is not initial.

        assign component <ls_component>-name of structure ms_problem to <lv_value>.

        if sy-subrc = 0.

          if ( <lv_value> is assigned ) and ( <lv_value> is not initial ).

            clear wa_zslpm_pr_his_rec.

            wa_zslpm_pr_his_rec-change_guid = mv_change_guid.
            wa_zslpm_pr_his_rec-field = <ls_component>-name.
            wa_zslpm_pr_his_rec-value = <lv_value>.

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
          lv_parent_nodeid    type int4.

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

        ls_zslpm_pr_his_hry-nodeid = lv_nodeid_counter.
        ls_zslpm_pr_his_hry-hierarchylevel = 1.
        ls_zslpm_pr_his_hry-description = 'asd'.
        ls_zslpm_pr_his_hry-parentnodeid = lv_parent_nodeid.
        ls_zslpm_pr_his_hry-drillstate = 'leaf'.


        ls_zslpm_pr_his_hry-field = <ls_zslpm_pr_his_rec>-field.
        ls_zslpm_pr_his_hry-value = <ls_zslpm_pr_his_rec>-value.

        append ls_zslpm_pr_his_hry to rt_zslpm_pr_his_hry.

        lv_nodeid_counter = lv_nodeid_counter + 1.

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

endclass.
