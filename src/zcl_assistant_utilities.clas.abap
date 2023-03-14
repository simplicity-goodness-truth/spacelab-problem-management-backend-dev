class zcl_assistant_utilities definition
  public
  create public .

  public section.

    class-methods convert_timestamp_to_timezone
      importing
        ip_timestamp                   type timestamp
        ip_timezone                    type timezone
      returning
        value(rp_timestamp_in_timezone) type timestamp .
    class-methods get_date_from_timestamp
      importing
        ip_timestamp  type timestamp
      returning
        value(rp_date) type dats .

    class-methods get_time_from_timestamp
      importing
        ip_timestamp  type timestamp
      returning
        value(rp_time) type uzeit .


    class-methods get_date_time_from_timestamp
      importing
        ip_timestamp  type timestamp
      exporting
        value(ep_date) type dats
        value(ep_time) type uzeit .


    class-methods get_system_timezone
      returning
        value(rp_system_timezone) type timezone .
    class-methods get_user_timezone
      importing
        ip_username       type xubname
      returning
        value(rp_timezone) type timezone
      raising
        resumable(zcx_assistant_utilities_exc) .
    class-methods get_all_users_of_org_unit
      importing
        ip_org_unit    type pd_objid_r
      returning
        value(rt_users) type zusers_tt
      raising
        zcx_assistant_utilities_exc .
    class-methods get_pos_and_users_of_org_unit
      importing
        ip_org_unit                  type pd_objid_r
      returning
        value(rt_positions_and_users) type crmt_orgman_swhactor_tab .
    class-methods get_subunits_of_org_unit
      importing
        ip_org_unit        type pd_objid_r
      returning
        value(rt_sub_units) type crmt_orgman_swhactor_tab .
    class-methods get_bp_of_org_unit
      importing
        ip_org_unit type pd_objid_r
      returning
        value(ep_bp) type bu_partner
      raising
        zcx_assistant_utilities_exc .
    class-methods get_emails_by_user_name
      importing
        ip_user_name             type xubname
      returning
        value(et_email_addresses) type addrt_email_address
      raising
        zcx_assistant_utilities_exc .
    class-methods get_http_param_value
      importing
        ip_header       type tihttpnvp
        ip_param_name   type char100
      returning
        value(ep_result) type string
      raising
        zcx_assistant_utilities_exc .
    class-methods get_org_bp_name
      importing
        ip_bp         type bu_partner
      returning
        value(ep_name) type bu_nameor2
      raising
        zcx_assistant_utilities_exc .
    class-methods get_user_bp_names
      importing
        ip_bp         type bu_partner
      returning
        value(ep_name) type bu_name1tx
      raising
        zcx_crm_order_api_exc
        zcx_assistant_utilities_exc .
    class-methods convert_char32_guid_to_raw16
      importing
        ip_guid_char32      type ags_sd_api_if_ws_obj_guid
      returning
        value(ep_guid_raw16) type sysuuid_x16
      raising
        zcx_assistant_utilities_exc .
    class-methods convert_char36_guid_to_raw16
      importing
        ip_guid_char36      type char_36
      returning
        value(ep_guid_raw16) type sysuuid_x16
      raising
        zcx_assistant_utilities_exc .
    class-methods format_date
      importing
        ip_format               type string
        ip_date                 type dats
      returning
        value(ep_formatted_date) type string
      raising
        zcx_assistant_utilities_exc .
    class-methods format_time
      importing
        ip_time                 type tims
      returning
        value(ep_formatted_time) type string .
    class-methods get_user_names_by_uname
      importing
        ip_uname      type xubname
      exporting
        ep_last_name  type ad_namelas
        ep_first_name type ad_namefir
      raising
        zcx_assistant_utilities_exc .

    class-methods format_timestamp
      importing
        ip_timestamp                 type timestamp
      returning
        value(rp_formatted_timestamp) type string
      raising
        zcx_assistant_utilities_exc.

  protected section.
  private section.
endclass.



class zcl_assistant_utilities implementation.


  method convert_char32_guid_to_raw16.

    data:
      lv_guid_char_32 type char32.

    if ( strlen( ip_guid_char32 ) eq 32 ).

      lv_guid_char_32 = ip_guid_char32.

      translate lv_guid_char_32 to upper case.

      ep_guid_raw16 = lv_guid_char_32.

    else.

      raise exception type zcx_assistant_utilities_exc
        exporting
          textid = zcx_assistant_utilities_exc=>incorrect_guid_format.

    endif. " if ( sy-subrc eq 0 ) and ( strlen( ip_guid_char36 ) eq 36 )

  endmethod.

  method convert_char36_guid_to_raw16.

    data:
      lv_guid_char_36 type char_36,
      lv_guid_char_32 type char32.

    search ip_guid_char36 for '-'.

    if ( sy-subrc eq 0 ) and ( strlen( ip_guid_char36 ) eq 36 ).

      lv_guid_char_36 = ip_guid_char36.

      replace all occurrences of '-' in lv_guid_char_36 with ' '.

      lv_guid_char_32 = lv_guid_char_36.

      translate lv_guid_char_32 to upper case.

      ep_guid_raw16 = lv_guid_char_32.

    else.

      raise exception type zcx_assistant_utilities_exc
        exporting
          textid = zcx_assistant_utilities_exc=>incorrect_guid_format.

    endif. " if ( sy-subrc eq 0 ) and ( strlen( ip_guid_char36 ) eq 36 )

  endmethod.


  method convert_timestamp_to_timezone.
    data:
      lv_date type sy-datum,
      lv_time type sy-uzeit.

    convert time stamp ip_timestamp time zone ip_timezone
        into date lv_date time lv_time.

    rp_timestamp_in_timezone = |{ lv_date }| && |{ lv_time }|.

  endmethod.


  method format_date.

    data: lv_year  type char4,
          lv_month type char2,
          lv_day   type char2.

    case ip_format.

      when 'DD.MM.YYYY'.

        lv_year = ip_date+0(4).
        lv_month = ip_date+4(2).
        lv_day  = ip_date+6(2).

        ep_formatted_date = |{ lv_day }| && |.| && |{ lv_month }| && |.| && |{ lv_year }|.

      when others.

        raise exception type zcx_assistant_utilities_exc
          exporting
            textid = zcx_assistant_utilities_exc=>unknown_conversion_format.

    endcase.

  endmethod.


  method format_time.

    data: lv_hour   type char2,
          lv_minute type char2,
          lv_second type char2.

    lv_hour = ip_time+0(2).
    lv_minute = ip_time+2(2).
    lv_second  = ip_time+4(2).

    ep_formatted_time = |{ lv_hour }| && |:| && |{ lv_minute }| && |:| && |{ lv_second  }|.

  endmethod.


  method get_all_users_of_org_unit.

    data: lt_positions_and_users type crmt_orgman_swhactor_tab,
          ls_user                type zuser_ts,
          lv_bp                  type bu_partner,
          lv_org_unit            type pd_objid_r.

    call method get_pos_and_users_of_org_unit
      exporting
        ip_org_unit            = ip_org_unit
      receiving
        rt_positions_and_users = lt_positions_and_users.


    loop at lt_positions_and_users assigning field-symbol(<ls_user_bp>) where otype eq 'CP'.

      clear: lv_bp, lv_org_unit.

      lv_org_unit = <ls_user_bp>-objid.

      call method get_bp_of_org_unit
        exporting
          ip_org_unit = lv_org_unit
        receiving
          ep_bp       = lv_bp.

      if lv_bp is not initial.

        call function 'CRM_ERMS_FIND_USER_FOR_BP'
          exporting
            ev_bupa_no = lv_bp
          importing
            ev_user_id = ls_user-uname.

        if ls_user-uname is not initial.

          append ls_user to rt_users.

        endif.

      endif. " if lv_bp is not initial

    endloop.

  endmethod.

  method get_bp_of_org_unit.

    select single sobid into ep_bp
      from hrp1001
       where objid = ip_org_unit and
         sclas = 'BP'.

    if sy-subrc <> 0.

      raise exception type zcx_assistant_utilities_exc
        exporting
          textid = zcx_assistant_utilities_exc=>org_unit_bp_not_found.

    endif.

  endmethod.


  method get_date_from_timestamp.

    data:
      lv_date type sy-datum,
      lv_time type sy-uzeit.

    convert time stamp ip_timestamp time zone 'UTC'
        into date lv_date time lv_time.

    rp_date = lv_date.

  endmethod.

  method get_time_from_timestamp.

    data:
      lv_date type sy-datum,
      lv_time type sy-uzeit.

    convert time stamp ip_timestamp time zone 'UTC'
        into date lv_date time lv_time.

    rp_time = lv_time.

  endmethod.


  method get_emails_by_user_name.

    data: lv_addrnumber type ad_addrnum,
          lv_persnumber type ad_persnum.

    select single persnumber addrnumber into (lv_persnumber, lv_addrnumber)
          from usr21 where bname eq ip_user_name.

    select smtp_addr from adr6 into corresponding fields of table et_email_addresses
      where addrnumber = lv_addrnumber and persnumber = lv_persnumber.

    if sy-subrc <> 0.



      raise exception type zcx_assistant_utilities_exc
        exporting
          textid  = zcx_assistant_utilities_exc=>user_emails_not_found
          ip_user = ip_user_name.

    endif.

  endmethod.


  method get_http_param_value.

    data: lv_substring_to_search  type string.

    field-symbols: <fs_header> type /iwbep/s_mgw_name_value_pair.

    lv_substring_to_search = |{ ip_param_name }| && |=|.

    " Getting full URL

    read table ip_header assigning <fs_header> with key name = '~request_uri'.

    " Searching for a parameter

    search <fs_header>-value for ip_param_name.


    if ( sy-fdpos > 0 ).

      ep_result = substring_after( val = <fs_header>-value sub = lv_substring_to_search ).

      search ep_result for '&'.

      if ( sy-fdpos > 0 ).

        ep_result = substring_before( val = ep_result sub = '&' ).

      endif.

    else.

      raise exception type zcx_assistant_utilities_exc
        exporting
          textid       = zcx_assistant_utilities_exc=>cant_get_http_parameter_value
          ip_parameter = ip_param_name.


    endif. "  if ( sy-fdpos > 0 )

  endmethod.


  method get_org_bp_name.

    data: lv_name_last  type bu_namep_l,
          lv_name_first type bu_namep_f,
          lv_name1_text type bu_name1tx.

    if ( ip_bp is not initial ) and ( ip_bp ne '0000000000' ) .

      select single name_org2 into ep_name
        from but000
          where partner eq ip_bp.

      if sy-subrc <> 0.



        raise exception type zcx_assistant_utilities_exc
          exporting
            textid = zcx_assistant_utilities_exc=>cant_get_bp_name
            ip_bp  = ip_bp.

      endif. " if sy-subrc <> 0

    endif. " if ip_bp is not initial

  endmethod.



  method get_pos_and_users_of_org_unit.

    call function 'RH_STRUC_GET'
      exporting
        act_otype      = 'O'
        act_objid      = ip_org_unit
        act_wegid      = 'SAP_SORG'
      tables
        result_tab     = rt_positions_and_users
      exceptions
        no_plvar_found = 1
        no_entry_found = 2
        others         = 3.

  endmethod.



  method get_subunits_of_org_unit.

    call function 'RH_STRUC_GET'
      exporting
        act_otype      = 'O'
        act_objid      = ip_org_unit
        act_wegid      = 'B002'
      tables
        result_tab     = rt_sub_units
      exceptions
        no_plvar_found = 1
        no_entry_found = 2
        others         = 3.

  endmethod.



  method get_system_timezone.

    call function 'GET_SYSTEM_TIMEZONE'
      importing
        timezone = rp_system_timezone.

  endmethod.


  method get_user_bp_names.

    data: lv_name_last  type bu_namep_l,
          lv_name_first type bu_namep_f,
          lv_name1_text type bu_name1tx.


    if ( ip_bp is not initial ) and ( ip_bp ne '0000000000' ) .

      select single name_last name_first name1_text into (lv_name_last, lv_name_first, lv_name1_text)
        from but000
          where partner eq ip_bp.

      if ( sy-subrc eq 0 ).

        ep_name = cond #(
          when lv_name1_text is not initial then lv_name1_text
          else |{ lv_name_first }| && |{ lv_name_last }|
        ).

      else.


        raise exception type zcx_assistant_utilities_exc
          exporting
            textid = zcx_assistant_utilities_exc=>cant_get_bp_name
            ip_bp  = ip_bp.

      endif.

    endif. " if ip_bp is not initial

  endmethod.


  method get_user_names_by_uname.

    select single name_last name_first into ( ep_last_name, ep_first_name )
      from user_addr
        where bname eq ip_uname.

    if sy-subrc ne 0.


      raise exception type zcx_assistant_utilities_exc
        exporting
          textid  = zcx_assistant_utilities_exc=>not_valid_user
          ip_user = ip_uname.

    endif.

  endmethod.


  method get_user_timezone.

    data: lv_timezone type timezone.

    " First look into usr02

    select single tzone from usr02 into lv_timezone
      where bname = ip_username.

    " Look into customizing table TTZCU

    if sy-subrc <> 0.

      raise exception type zcx_assistant_utilities_exc
        exporting
          textid = zcx_assistant_utilities_exc=>not_valid_user.

    endif.

    if lv_timezone is initial.

      select single tzonedef from ttzcu into lv_timezone.

      if sy-subrc <> 0 or lv_timezone is initial.

        raise exception type zcx_assistant_utilities_exc
          exporting
            textid = zcx_assistant_utilities_exc=>no_timezone_customizing.

      endif. " if sy-subrc <> 0 or lv_timezone is initial

    endif. " if lv_timezone is initial

    rp_timezone = lv_timezone.

  endmethod.

  method format_timestamp.

    data: lv_date           type dats,
          lv_time           type uzeit,
          lv_date_formatted type string,
          lv_time_formatted type string.

    get_date_time_from_timestamp(
        exporting ip_timestamp = ip_timestamp
        importing ep_date = lv_date ep_time = lv_time ).


    lv_date_formatted = format_date(
        exporting ip_format = 'DD.MM.YYYY'
        ip_date = lv_date ).

    lv_time_formatted = format_time( lv_time ).

    rp_formatted_timestamp = |{ lv_date_formatted }| && | | && |{ lv_time_formatted }|.


  endmethod.

  method get_date_time_from_timestamp.

    data:
      lv_date type sy-datum,
      lv_time type sy-uzeit.

    convert time stamp ip_timestamp time zone 'UTC'
        into date lv_date time lv_time.

    ep_date = lv_date.
    ep_time = lv_time.


  endmethod.

endclass.
