interface zif_slpm_status_codes
  public .

  methods:
    get_all_status_codes
      returning
        value(rt_status_codes) type zcrm_order_tt_status_codes.

endinterface.
