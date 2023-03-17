class zcl_slpm_prob_change_notifier definition
  public
  inheriting from zcl_crm_order_change_notifier
  final
  create public .

  public section.
    methods constructor
      importing
        is_problem_old_state type zcrm_order_ts
        is_problem_new_state type zcrm_order_ts.

    methods: zif_crm_order_change_notifier~notify redefinition.

  protected section.
  private section.
    data:
      ms_slpm_emails_for_statuses type zslpm_stat_email,
      ms_problem_old_state        type zcrm_order_ts,
      ms_problem_new_state        type zcrm_order_ts,
      mt_variables_values         type zst_text_tt_variables_values.

    class-data: mv_sender_email_address type zmessenger_address.

    methods: notify_by_email,
      get_stat_dependant_email_rules,

      dispatch_emails,

      notify_by_process_role
        importing
          ip_email_rule             type char64
          ip_receiver_email_address type zmessenger_address,

      get_email_rule
        importing
          ip_email_rule      type char64
        exporting
          ep_email_subj_text type tdobname
          ep_email_body_text type tdobname,

      get_compiled_text
        importing
          ip_use_tags             type abap_bool optional
          ip_text_name            type tdobname
        returning
          value(rp_compiled_text) type string,

      send_email
        importing
          ip_receiver_email_address type zmessenger_address
          ip_email_body             type string
          ip_email_subject          type so_obj_des,

      fill_variables_values,

      get_email_address
        importing
          ip_process_role         type char64
        returning
          value(rp_email_address) type zmessenger_address,

      fill_problem_details_html
        returning
          value(rp_problem_details) type string.

    class-methods set_sender_email_address
      importing
        ip_sender_email_address type zmessenger_address.

endclass.

class zcl_slpm_prob_change_notifier implementation.

  method constructor.

    super->constructor(
        is_order_new_state = is_problem_new_state
        is_order_old_state = is_problem_old_state ).

    me->ms_problem_new_state = me->get_order_new_state(  ).
    me->ms_problem_old_state = me->get_order_old_state(  ).

    me->fill_variables_values( ).

    me->set_sender_email_address( 'andrew.kusnetsov@mail.ru' ).

  endmethod.

  method zif_crm_order_change_notifier~notify.

    me->notify_by_email(  ).

  endmethod.

  method get_stat_dependant_email_rules.

    " Get a email rule, corresponding to a current status change

    select single
        statusin statusout emailrulereq emailrulesup emailrulepro emailruleobs
            into corresponding fields of ms_slpm_emails_for_statuses
                 from zslpm_stat_email as a
                    where statusin = ms_problem_old_state-status and
                        statusout eq ms_problem_new_state-status.
  endmethod.

  method get_email_rule.

    select single sttextsubj sttextbody
        into ( ep_email_subj_text, ep_email_body_text )
        from zslpm_email_rule
        where rulename = ip_email_rule.

  endmethod.

  method dispatch_emails.

    types: begin of ty_process_roles,
             acronym type char3,
             name    type char64,
           end of ty_process_roles.


    data: lo_structure_ref          type ref to data,
          lr_entity                 type ref to data,
          lt_process_roles          type table of ty_process_roles,
          lv_field_name             type string,
          lv_method_name            type string,
          lv_email_rule             type char64,
          ptab                      type abap_parmbind_tab,
          lv_receiver_email_address type zmessenger_address.

    field-symbols: <fs_structure> type any,
                   <fs_value>     type any.


    " Fill possible roles acronyms table
    " REQ - requester
    " SUP - support team
    " PRO - processor
    " OBS - observer

    lt_process_roles = value #(
        ( acronym = 'REQ' name = 'REQUESTER' )
        ( acronym = 'SUP' name = 'SUPPORT_TEAM' )
        ( acronym = 'PRO' name = 'PROCESSOR' )
        ( acronym = 'OBS' name = 'OBSERVER' ) ).

    get reference of ms_slpm_emails_for_statuses into lr_entity.

    if ( lr_entity is bound ).

      assign lr_entity->* to <fs_structure>.

    endif. " if ( ir_entity is bound )

    loop at lt_process_roles assigning field-symbol(<ls_process_role>).

      lv_field_name = |EMAILRULE| && |{ <ls_process_role>-acronym }|.

      assign component lv_field_name of structure <fs_structure> to <fs_value>.

      if <fs_value> is not initial.

        " Execute corresponding method

        "lv_method_name = |NOTIFY_| && |{ <ls_process_role>-name }|.
        lv_method_name = |NOTIFY_BY_PROCESS_ROLE|.

        lv_email_rule = <fs_value>.

        lv_receiver_email_address = me->get_email_address( <ls_process_role>-name ).

        ptab = value #(
            ( name = 'IP_EMAIL_RULE' value = ref #( lv_email_rule ) kind = cl_abap_objectdescr=>exporting )
            ( name = 'IP_RECEIVER_EMAIL_ADDRESS' value = ref #( lv_receiver_email_address ) kind = cl_abap_objectdescr=>exporting )
        ).

        try.

            call method me->(lv_method_name)
              parameter-table
              ptab.

          catch cx_sy_dyn_call_error into data(lcx_process_exception).
            return.
        endtry.

      endif.

    endloop.

  endmethod.

  method fill_variables_values.

    mt_variables_values = value zst_text_tt_variables_values(
      ( variable = '&REQUESTERNAME' value = ms_problem_new_state-requestorfullname )
      ( variable = '&PROBMLEMID' value = ms_problem_new_state-objectid opentag = '<STRONG>' closetag = '</STRONG>' )
      ( variable = '&PROCESSORNAME' value = ms_problem_new_state-processorfullname )
      ( variable = '&FIELDS' value = me->fill_problem_details_html(  ) )
    ).



  endmethod.

  method notify_by_process_role.

    data: lv_email_subj_text_name type tdobname,
          lv_email_body_text_name type tdobname,
          lv_email_body           type string,
          lv_email_subject        type so_obj_des.

    me->get_email_rule(
       exporting
           ip_email_rule = ip_email_rule
           importing
           ep_email_body_text = lv_email_body_text_name
           ep_email_subj_text = lv_email_subj_text_name ).


    lv_email_subject = me->get_compiled_text(
        exporting
            ip_text_name = lv_email_subj_text_name ).

    lv_email_body = me->get_compiled_text(
        exporting
            ip_use_tags = abap_true
            ip_text_name = lv_email_body_text_name ).

    me->send_email(
        exporting
            ip_receiver_email_address = ip_receiver_email_address
            ip_email_body = lv_email_body
            ip_email_subject = lv_email_subject ).

  endmethod.

  method get_compiled_text.

    data  lo_standard_text  type ref to zif_standard_text.

    lo_standard_text = new zcl_standart_text(
    ip_text_language = 'R'
    ip_text_name = ip_text_name ).

    rp_compiled_text = lo_standard_text->get_compiled_text_by_name(
        exporting
            ip_use_tags = ip_use_tags
            it_variables_values =  mt_variables_values ).

  endmethod.

  method send_email.

    data: lo_email       type ref to zif_messenger,
          lt_recepients  type zmessenger_tt_addresses,
          ls_recepient   like line of lt_recepients,
          lt_attachments type zmessenger_tt_attachments,
          ls_attachment  like line of lt_attachments.

    lo_email = new zcl_email_messenger(  ).

    lo_email->set_message_subject( ip_email_subject ).

    lo_email->set_message_body(
        exporting
            ip_message_body_text = ip_email_body
            ip_message_body_type = 'HTM'
    ).

    ls_recepient = ip_receiver_email_address.
    append ls_recepient to lt_recepients.

    lo_email->set_message_recepients( lt_recepients ).
    lo_email->set_message_sender( mv_sender_email_address ).

    lo_email->send_message(  ).

  endmethod.

  method get_email_address.

    data lo_bp_address_book type ref to zif_contacts_book.

    lo_bp_address_book = new zcl_bp_contacts_book( switch #( ip_process_role

        when 'REQUESTER'    then ms_problem_new_state-requestorbusinesspartner
        when 'PROCESSOR'    then ms_problem_new_state-processorbusinesspartner
        when 'SUPPORTTEAM'  then ms_problem_new_state-supportteambusinesspartner ) ).

    rp_email_address = lo_bp_address_book->get_email_address(  ).

  endmethod.

  method notify_by_email.

    me->get_stat_dependant_email_rules(  ).

    me->dispatch_emails(  ).

  endmethod.

  method set_sender_email_address.

    mv_sender_email_address = ip_sender_email_address.

  endmethod.

  method fill_problem_details_html.

    types: begin of ty_fields_to_fill,
             name        type name_komp,
             translation type char64,
           end of ty_fields_to_fill.


    data: lt_fields_to_fill type table of ty_fields_to_fill,
          lo_structure_ref  type ref to data,
          lr_entity         type ref to data.


    field-symbols: <fs_structure> type any,
                   <fs_value>     type any.

    lt_fields_to_fill = value #(

        ( name = 'DESCRIPTION' translation = 'Название/тема')
        ( name = 'OBJECTID' translation = 'Номер')
        ( name = 'PRIORITYTEXT' translation = 'Приоритет')
        ( name = 'PRODUCTTEXT' translation = 'Тип сервиса')
        ( name = 'REQUESTORCOMPANY' translation = 'Компания')
        ( name = 'REQUESTORFULLNAME' translation = 'Автор')
        ( name = 'STATUSTEXT' translation = 'Статус' )
    ).

    get reference of ms_problem_new_state into lr_entity.

    if ( lr_entity is bound ).

      assign lr_entity->* to <fs_structure>.

    endif. " if ( ir_entity is bound )


    loop at lt_fields_to_fill assigning field-symbol(<ls_field>).

      if <fs_value> is assigned.
        unassign <fs_value>.
      endif.

      assign component <ls_field>-name of structure <fs_structure> to <fs_value>.

      if <fs_value> is not initial.

        rp_problem_details = |{ rp_problem_details }| &&
        |{ <ls_field>-translation }| && |:| && | | && |{ <fs_value> }| &&
        |<br/>|.

      endif.

    endloop.


  endmethod.

endclass.
