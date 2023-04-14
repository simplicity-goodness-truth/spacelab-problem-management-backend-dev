interface zif_crm_service_product
  public .
  interfaces zif_crm_product.


  methods: get_resp_profile_table
    returning
      value(rt_response_profile_table) type crmt_escal_recno_tab,

    get_resp_profile_prio_count
      returning
        value(rp_prio_count) type int1,

    get_resp_profile_prio
      returning
        value(rt_priorities) type zcrm_order_tt_priorities,

    get_availability_profile_name
      returning
        value(rp_profile_name) type srv_serwi.

endinterface.
