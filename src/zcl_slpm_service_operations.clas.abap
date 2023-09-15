class zcl_slpm_service_operations definition
  public
  final
  create public .

  public section.

    interfaces zif_slpm_service_operations .

  protected section.
  private section.

endclass.

class zcl_slpm_service_operations implementation.

  method zif_slpm_service_operations~clear_attachments_trash_bin.

    data lo_custom_crm_order_att_trash type ref to zif_custom_crm_order_att_trash.

    lo_custom_crm_order_att_trash = new zcl_custom_crm_order_att_trash(  ).

    lo_custom_crm_order_att_trash->empty_trash_bin( ).

  endmethod.

  method zif_slpm_service_operations~clear_problems_history.

    data lo_slpm_problem_history_store type ref to zif_slpm_problem_history_store.

    lo_slpm_problem_history_store = new zcl_slpm_problem_history_store( '00000000000000000000000000000000' ).

    lo_slpm_problem_history_store->arch_orphaned_history_records( ).

    lo_slpm_problem_history_store->delete_arch_history_records( ip_password ).

  endmethod.

  method zif_slpm_service_operations~clear_attachments_vsblty_table.

    delete from zslpm_att_vsbl.

  endmethod.

  method zif_slpm_service_operations~clear_escalation_log.

    data lo_custom_crm_order_sla_escal type ref to zcl_custom_crm_order_sla_escal.

    lo_custom_crm_order_sla_escal = new zcl_custom_crm_order_sla_escal(  ).

    lo_custom_crm_order_sla_escal->zif_custom_crm_order_sla_escal~clear_escal_log( 'ZSLP' ).

  endmethod.

endclass.
