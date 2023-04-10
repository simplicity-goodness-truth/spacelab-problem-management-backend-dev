interface zif_slpm_products_storage
  public .

  methods: get_all_slpm_products
    returning
      value(rt_all_slpm_products) type zslpm_tt_products.

endinterface.
