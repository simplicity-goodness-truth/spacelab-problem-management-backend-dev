interface zif_custom_crm_order_sla_escal
  public .

  methods:

    process_escalations
      raising
        zcx_crm_order_api_exc
        zcx_assistant_utilities_exc.

endinterface.
