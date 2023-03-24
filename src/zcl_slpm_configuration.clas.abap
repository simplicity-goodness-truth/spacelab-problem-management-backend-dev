class zcl_slpm_configuration definition
  public
  final
  create public .

  public section.

    interfaces zif_slpm_configuration .

    methods constructor
      raising
        zcx_slpm_configuration_exc.

  protected section.
  private section.

    data: mv_active_profile       type char50,
          mt_active_configuration type table of zslpm_setup.

    methods: set_active_profile
      raising
        zcx_slpm_configuration_exc,

      get_value_from_db
        importing
          ip_param_name   type char50
        returning
          value(ep_value) type text200
        raising
          zcx_slpm_configuration_exc,

      set_active_configuration
        raising
          zcx_slpm_configuration_exc,

      check_active_profile
        raising
          zcx_slpm_configuration_exc,

      get_value_from_active_config
        importing
          ip_param_name   type char50
        returning
          value(ep_value) type text200
        raising
          zcx_slpm_configuration_exc.

endclass.

class zcl_slpm_configuration implementation.


  method zif_slpm_configuration~get_parameter_value.

    data: lv_param_name   type char50.

    lv_param_name = |{ mv_active_profile }| && |.| && |{ ip_param_name }|.

    rp_value = me->get_value_from_active_config( lv_param_name ).

  endmethod.

  method set_active_profile.

    mv_active_profile = me->get_value_from_db( 'ACTIVE_PROFILE' ).

  endmethod.

  method get_value_from_db.

    select single value from zslpm_setup
     into ep_value
       where param eq ip_param_name.

    if sy-subrc ne 0.

      raise exception type zcx_slpm_configuration_exc
        exporting
          textid       = zcx_slpm_configuration_exc=>parameter_not_found
          ip_parameter = ip_param_name.

    endif.

  endmethod.

  method constructor.

    me->set_active_profile(  ).
    me->set_active_configuration(  ).

  endmethod.

  method set_active_configuration.

    data lv_parameter_mask type char50.

    me->check_active_profile(  ).

    lv_parameter_mask = |{ mv_active_profile }| && |.| && |%|.

    select param value from zslpm_setup
        into corresponding fields of table mt_active_configuration
        where param like lv_parameter_mask.

  endmethod.

  method check_active_profile.

    if mv_active_profile is initial.

      raise exception type zcx_slpm_configuration_exc
        exporting
          textid = zcx_slpm_configuration_exc=>active_profile_not_set.

    endif.

  endmethod.

  method get_value_from_active_config.

    data: ls_parameter_line type zslpm_setup,
          lv_param          type char50.

    try.
        lv_param = ip_param_name.

        translate lv_param to upper case.

        ls_parameter_line = mt_active_configuration[ param = lv_param ].

        ep_value = ls_parameter_line-value.

      catch cx_sy_itab_line_not_found.
        raise exception type zcx_slpm_configuration_exc
          exporting
            textid       = zcx_slpm_configuration_exc=>parameter_not_found
            ip_parameter = ip_param_name.

    endtry.

  endmethod.

endclass.
