interface zif_custom_crm_order_sla_escal
  public .

  methods:

    process_escalations
      raising
        zcx_crm_order_api_exc
        zcx_assistant_utilities_exc,

    clear_escal_log
      importing
        ip_process_type type crmt_process_type.

endinterface.
