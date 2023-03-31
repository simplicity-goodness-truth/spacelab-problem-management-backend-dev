interface zif_slpm_customer
  public .

  methods:

    get_slpm_products_of_customer
      returning
        value(rt_slpm_products_of_customer) type zcrm_tt_products.

endinterface.
