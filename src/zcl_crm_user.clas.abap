class zcl_crm_user definition
  public
  inheriting from zcl_system_user
  final
  create public .

  public section.

    interfaces:
      zif_crm_user.


  protected section.
  private section.

endclass.

class zcl_crm_user implementation.

  method zif_crm_user~is_auth_to_read_on_proc_type.

    authority-check object 'ZPRTYR'
        id 'PR_TYPE' field ip_process_type.

    if sy-subrc = 0.

      rb_authorized = abap_true.

    endif.


  endmethod.

  method zif_crm_user~is_auth_to_create_on_proc_type.

      authority-check object 'ZPRTYC'
        id 'PR_TYPE' field ip_process_type.

    if sy-subrc = 0.

      rb_authorized = abap_true.

    endif.

  endmethod.

  method zif_crm_user~is_auth_to_update_on_proc_type.

      authority-check object 'ZPRTYU'
        id 'PR_TYPE' field ip_process_type.

    if sy-subrc = 0.

      rb_authorized = abap_true.

    endif.

  endmethod.

endclass.
