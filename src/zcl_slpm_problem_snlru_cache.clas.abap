class zcl_slpm_problem_snlru_cache definition
  public
  final
  create public .

  public section.

    interfaces:

      zif_cache,

      zif_slpm_problem_cache.

    methods constructor
      importing
        io_active_configuration type ref to zif_slpm_configuration
      raising
        zcx_slpm_configuration_exc.

  protected section.
  private section.
    methods:

      decode_problem
        importing
          ip_table_name type strukname,

      set_problem_ref
        importing
          ir_problem type ref to data,

      set_shma_active_configuration
        raising
          zcx_slpm_configuration_exc,

      rebuild_segments
        importing
          is_problem     type zcrm_order_ts_sl_problem
          ip_hit_segment type char1.


    data:
      mr_problem              type ref to data,
      ms_problem              type zcrm_order_ts_sl_problem,
      mo_active_configuration type ref to zif_slpm_configuration.

endclass.



class zcl_slpm_problem_snlru_cache implementation.

  method constructor.

    data lt_shma_instance_infos type shm_inst_infos.

    try.

        lt_shma_instance_infos = zcl_slpm_area=>get_instance_infos(  ).

        if lt_shma_instance_infos is initial.

          mo_active_configuration = io_active_configuration.

          me->set_shma_active_configuration(  ).

          zcl_slpm_area=>build( ).


        endif.

      catch cx_shm_build_failed.
        return.
    endtry.



  endmethod.


  method set_problem_ref.

    mr_problem = ir_problem.

  endmethod.


  method zif_cache~add_record.

    data:
      lo_area type ref to zcl_slpm_area,
      lo_root type ref to zcl_slpm_shma.


    me->set_problem_ref( ir_record ).

    me->decode_problem( 'ZCRM_ORDER_TS_SL_PROBLEM' ).

    try.
        lo_area = zcl_slpm_area=>attach_for_update( ).


      catch cx_shm_pending_lock_removed cx_shm_change_lock_active cx_shm_version_limit_exceeded
        cx_shm_exclusive_lock_active cx_shm_inconsistent cx_shm_no_active_version cx_shm_build_failed.

        return.

    endtry.

    lo_root ?= lo_area->get_root( ).

    if lo_root is  initial.

      create object lo_root area handle lo_area.

    endif.

    call method lo_root->add_problem_to_cache
      exporting
        is_problem = ms_problem.

    lo_area->set_root( lo_root ).

    lo_area->detach_commit( ).

  endmethod.


  method zif_cache~get_record.

    data:lo_area        type ref to zcl_slpm_area,
         ls_problem     type zcrm_order_ts_sl_problem,
         lr_problem     type ref to data,
         lv_hit_segment type char1.

    field-symbols: <fs_guid>    type any,
                   <fs_problem> type any.

    if ( ir_guid is bound ).

      assign ir_guid->* to <fs_guid>.


      if <fs_guid> is assigned.
        try.

            lo_area = zcl_slpm_area=>attach_for_read( ).

          catch cx_shm_pending_lock_removed cx_shm_change_lock_active cx_shm_version_limit_exceeded
         cx_shm_exclusive_lock_active cx_shm_inconsistent cx_shm_no_active_version cx_shm_read_lock_active.

            return.

        endtry.

        lo_area->root->get_problem_from_cache(
           exporting
               ip_guid = <fs_guid>
           importing
               rp_hit_segment = lv_hit_segment
               rs_problem = ls_problem ).

        create data lr_problem type zcrm_order_ts_sl_problem.

        assign lr_problem->* to <fs_problem>.

        <fs_problem> = ls_problem.

        get reference of <fs_problem> into rs_record.

        lo_area->detach( ).

      endif.

    endif.

  endmethod.


  method zif_cache~invalidate_record.

  endmethod.

  method decode_problem.

    data:
      lr_table_wa type ref to data.

    field-symbols:
      <fs_problem> type any.

    create data lr_table_wa type (ip_table_name).

    assign lr_table_wa->* to <fs_problem>.

    if ( mr_problem is bound ).

      assign mr_problem->* to <fs_problem>.

      ms_problem =  <fs_problem>.


    endif.


  endmethod.

  method zif_slpm_problem_cache~add_record.

    data:
      lo_area type ref to zcl_slpm_area,
      lo_root type ref to zcl_slpm_shma.

    try.
        lo_area = zcl_slpm_area=>attach_for_update( ).

      catch cx_shm_pending_lock_removed cx_shm_change_lock_active cx_shm_version_limit_exceeded
        cx_shm_exclusive_lock_active cx_shm_inconsistent cx_shm_no_active_version cx_shm_build_failed.

        return.

    endtry.

    lo_root ?= lo_area->get_root( ).

    if lo_root is  initial.
      create object lo_root area handle lo_area.
    endif.

    call method lo_root->add_problem_to_cache
      exporting
        is_problem = is_record.

    lo_area->set_root( lo_root ).

    lo_area->detach_commit( ).

  endmethod.

  method zif_slpm_problem_cache~get_record.

    data:lo_area        type ref to zcl_slpm_area,
         lv_hit_segment type char1.

    try.

        lo_area = zcl_slpm_area=>attach_for_read( ).

        " lo_area = zcl_slpm_area=>attach_for_update(  ).

      catch cx_shm_pending_lock_removed cx_shm_change_lock_active cx_shm_version_limit_exceeded
     cx_shm_exclusive_lock_active cx_shm_inconsistent cx_shm_no_active_version cx_shm_read_lock_active.

        return.

    endtry.

    lo_area->root->get_problem_from_cache(
        exporting
            ip_guid = ip_guid
        importing
            rs_problem = rs_record
            rp_hit_segment = lv_hit_segment ).

    lo_area->detach( ).


    rebuild_segments(
      exporting
        ip_hit_segment = lv_hit_segment
        is_problem     = rs_record ).


  endmethod.

  method zif_slpm_problem_cache~invalidate_record.

    data:
      lo_area type ref to zcl_slpm_area,
      lo_root type ref to zcl_slpm_shma.

    try.
        lo_area = zcl_slpm_area=>attach_for_update( ).

      catch cx_shm_pending_lock_removed cx_shm_change_lock_active cx_shm_version_limit_exceeded
        cx_shm_exclusive_lock_active cx_shm_inconsistent cx_shm_no_active_version cx_shm_build_failed.

        return.

    endtry.

    lo_root ?= lo_area->get_root( ).

    if lo_root is  initial.
      create object lo_root area handle lo_area.
    endif.

    call method lo_root->invalidate_problem_in_cache
      exporting
        ip_guid = ip_guid.

    lo_area->set_root( lo_root ).

    lo_area->detach_commit( ).



  endmethod.

  method zif_cache~get_all_records.

  endmethod.

  method zif_slpm_problem_cache~get_all_records.

  endmethod.

  method set_shma_active_configuration.

    zcl_slpm_shma=>set_active_configuration( mo_active_configuration ).

  endmethod.

  method rebuild_segments.

    data:
      lo_area type ref to zcl_slpm_area,
      lo_root type ref to zcl_slpm_shma.

    try.
        lo_area = zcl_slpm_area=>attach_for_update( ).

      catch cx_shm_pending_lock_removed cx_shm_change_lock_active cx_shm_version_limit_exceeded
        cx_shm_exclusive_lock_active cx_shm_inconsistent cx_shm_no_active_version cx_shm_build_failed.

        return.

    endtry.

    lo_root ?= lo_area->get_root( ).

    if lo_root is  initial.
      create object lo_root area handle lo_area.
    endif.

    call method lo_root->rebuild_segments(
      exporting
        ip_hit_segment = ip_hit_segment
        is_problem     = is_problem ).

    lo_area->set_root( lo_root ).

    lo_area->detach_commit( ).



  endmethod.

endclass.
