class zcl_slpm_shma definition
  public
  final
  create public
  shared memory enabled.

  public section.

    interfaces:
      if_shm_build_instance.

    methods:

      add_problem_to_cache
        importing
          is_problem type zcrm_order_ts_sl_problem,

      get_problem_from_cache
        importing
          ip_guid        type crmt_object_guid
        exporting
          rs_problem     type zcrm_order_ts_sl_problem
          rp_hit_segment type char1,

      invalidate_problem_in_cache
        importing
          ip_guid type crmt_object_guid,

      rebuild_segments
        importing
          is_problem     type zcrm_order_ts_sl_problem
          ip_hit_segment type char1.

    class-methods:

      set_active_configuration
        importing
          io_active_configuration type ref to zif_slpm_configuration
        raising
          zcx_slpm_configuration_exc.

  protected section.
  private section.


    methods:



      shift_segment
        importing
          ip_segment_to_shift type char1.

    data:

      "mt_cached_problems_hot     type sorted table of zcrm_order_ts_sl_problem with unique key guid,

      mt_cached_problems_hot     type table of zcrm_order_ts_sl_problem with key primary_key components guid,

      "mt_cached_problems_warm    type sorted table of zcrm_order_ts_sl_problem with unique key guid,

      mt_cached_problems_warm    type table of zcrm_order_ts_sl_problem with key primary_key components guid,

      "mt_cached_problems_cold    type sorted table of zcrm_order_ts_sl_problem with unique key guid,

      mt_cached_problems_cold    type table of zcrm_order_ts_sl_problem with key primary_key components guid,

      mv_problem_cache_size_hot  type integer,
      mv_problem_cache_size_warm type integer,
      mv_problem_cache_size_cold type integer.

    class-data:

      mo_active_configuration_st    type ref to zif_slpm_configuration,
      mv_problem_cache_size_hot_st  type integer,
      mv_problem_cache_size_warm_st type integer,
      mv_problem_cache_size_cold_st type integer.

endclass.

class zcl_slpm_shma implementation.

  method if_shm_build_instance~build.

    data:lo_area  type ref to zcl_slpm_area,
         lo_root  type ref to zcl_slpm_shma,
         lo_excep type ref to cx_root.

    try.
        lo_area = zcl_slpm_area=>attach_for_write( ).

      catch cx_shm_error into lo_excep.
        raise exception type cx_shm_build_failed
          exporting
            previous = lo_excep.
    endtry.

    create object lo_root area handle lo_area.


    " We have to use static middleware properties here, as
    " there is no any other way to pass configuration to this class.
    " Before standard interface method BUILD is called we set
    " these static properties, then assign its values to instance properties
    " and finally instance properties are written to Shared Memory.
    " With this approach our configuration is stored in a Shared Memory as well
    " as an instance with cached problems.

    lo_root->mv_problem_cache_size_hot = mv_problem_cache_size_hot_st.
    lo_root->mv_problem_cache_size_warm = mv_problem_cache_size_warm_st.
    lo_root->mv_problem_cache_size_cold = mv_problem_cache_size_cold_st.

    lo_area->set_root( lo_root ).

    lo_area->detach_commit( ).


  endmethod.

  method add_problem_to_cache.

    " New problem is added into HEAD of a COLD segment

    "append is_problem to mt_cached_problems_cold.

    insert is_problem into mt_cached_problems_cold index 1.

    shift_segment( 'C' ).

  endmethod.

  method get_problem_from_cache.

    try.

        " First step: we search in HOT segment

        rs_problem = mt_cached_problems_hot[ key primary_key components guid = ip_guid ].

        rp_hit_segment = 'H'.

*        rebuild_segments(
*            exporting
*                ip_hit_segment = 'H'
*                is_problem = rs_problem ).

      catch cx_sy_itab_line_not_found.

        " Second step: we search in WARM segment

        try.
            rs_problem = mt_cached_problems_warm[ key primary_key components guid = ip_guid ].

            rp_hit_segment = 'W'.

*            rebuild_segments(
*                exporting
*                    ip_hit_segment = 'W'
*                    is_problem = rs_problem ).

          catch cx_sy_itab_line_not_found.

            " Third step: we search in COLD segment

            try.
                rs_problem = mt_cached_problems_cold[ key primary_key components guid = ip_guid ].

                rp_hit_segment = 'C'.

*                rebuild_segments(
*                    exporting
*                     ip_hit_segment = 'C'
*                     is_problem = rs_problem ).

              catch cx_sy_itab_line_not_found.

                " Forth step: we search in COLD segment

                return.

            endtry.

        endtry.

    endtry.

  endmethod.

  method set_active_configuration.

    " We have to use static middleware properties here, as
    " there is no any other way to pass configuration to this class.
    " Before standard interface method BUILD is called we set
    " these static properties, then assign its values to instance properties
    " and finally instance properties are written to Shared Memory.
    " With this approach our configuration is stored in a Shared Memory as well
    " as an instance with cached problems.

    mo_active_configuration_st = io_active_configuration.
    mv_problem_cache_size_hot_st  =  mo_active_configuration_st->get_parameter_value( 'PROBLEM_CACHE_HOT_SEGMENT_SIZE' ).
    mv_problem_cache_size_warm_st  =  mo_active_configuration_st->get_parameter_value( 'PROBLEM_CACHE_WARM_SEGMENT_SIZE' ).
    mv_problem_cache_size_cold_st  =  mo_active_configuration_st->get_parameter_value( 'PROBLEM_CACHE_COLD_SEGMENT_SIZE' ).

  endmethod.

  method rebuild_segments.

    case ip_hit_segment.

      when 'H'.

        " Problem found in HOT segment:
        " 1. Move problem to a HEAD of HOT segment

*        delete mt_cached_problems_hot index
*           line_index( mt_cached_problems_hot[  guid = is_problem-guid ] ).

        delete table mt_cached_problems_hot with table key
            primary_key components guid = is_problem-guid.

        insert is_problem into mt_cached_problems_hot index 1.




      when 'W'.

        " Problem found in WARM segment:
        " 1. Move problem to a HEAD of HOT segment
        " 2. Shift HOT one step further

*        delete mt_cached_problems_warm index
*            line_index( mt_cached_problems_warm[ guid = is_problem-guid ] ).

        delete table mt_cached_problems_warm with table key
            primary_key components guid = is_problem-guid.

        insert is_problem into mt_cached_problems_hot index 1.

        shift_segment( 'H' ).

      when 'C'.

        " Problem found in COLD segment:
        " 1. Move problem to a HEAD of WARM segment
        " 2. Shift WARM one step further

*        delete mt_cached_problems_cold index
*            line_index( mt_cached_problems_cold[ guid = is_problem-guid ] ).

        delete table mt_cached_problems_cold with table key
           primary_key components guid = is_problem-guid.

        insert is_problem into mt_cached_problems_warm index 1.

        shift_segment( 'W' ).

    endcase.

  endmethod.

  method shift_segment.

    data ls_problem_to_move type zcrm_order_ts_sl_problem.

    case ip_segment_to_shift.

      when 'H'.

        " Shifting HOT segment:
        " If amount of records in HOT segment is greater than configured, then
        " 1. Move the record to HEAD of WARM segment
        " 2. Shift WARM segment

        if lines( mt_cached_problems_hot ) > mv_problem_cache_size_hot.

          " Take last record in HOT segment and move it to HEAD of WARM segment

          ls_problem_to_move = mt_cached_problems_hot[ lines( mt_cached_problems_hot ) ].

          insert ls_problem_to_move into mt_cached_problems_warm index 1.

          delete mt_cached_problems_hot index lines( mt_cached_problems_hot ).

          shift_segment( 'W' ).

        endif.

      when 'W'.

        " Shifting WARM segment:
        " If amount of records in WARM segment is greater than configured, then
        " 1. Move the record to HEAD of COLD segment
        " 2. Shift COLD segment

        if lines( mt_cached_problems_warm ) > mv_problem_cache_size_warm.

          " Take last record in WARM segment and move it to HEAD of COLD segment

          ls_problem_to_move = mt_cached_problems_warm[ lines( mt_cached_problems_warm ) ].

          insert ls_problem_to_move into mt_cached_problems_cold index 1.

          delete mt_cached_problems_warm index lines( mt_cached_problems_warm ).

          shift_segment( 'C' ).

        endif.


      when 'C'.

        " Shifting COLD segment:
        " If amount of records in COLD segment is greater than configured, then
        " 1. Delete a record in a TAIL of COLD segment

        if lines( mt_cached_problems_cold ) > mv_problem_cache_size_cold.

          delete mt_cached_problems_cold index lines( mt_cached_problems_cold ).

        endif.

    endcase.

  endmethod.

  method invalidate_problem_in_cache.

    " First we are trying to delete from HOT, if not found, then from WARM, if not found, then from COLD

    delete table mt_cached_problems_hot with table key
      primary_key components guid = ip_guid.

    if sy-subrc ne 0.

      delete table mt_cached_problems_warm with table key
           primary_key components guid = ip_guid.

      if sy-subrc ne 0.

        delete table mt_cached_problems_cold with table key
             primary_key components guid = ip_guid.

      endif.

    endif.


  endmethod.

endclass.