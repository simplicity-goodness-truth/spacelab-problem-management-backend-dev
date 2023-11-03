interface zif_crm_order_auto_stat_setter
  public .

  methods:

    process_orders_status_setting
      raising
        zcx_crm_order_api_exc
        zcx_assistant_utilities_exc.

endinterface.
