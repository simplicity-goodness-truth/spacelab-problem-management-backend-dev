interface zif_slpm_user
  public .

  methods: get_slpm_products_of_user
    returning
      value(rt_slpm_products_of_user) type zcrm_tt_products.

endinterface.
