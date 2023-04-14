interface zif_slpm_customer
  public .

  methods:

    get_slpm_products_of_customer
      returning
        value(rt_slpm_products_of_customer) type zslpm_tt_products,

    get_slpm_systems_of_customer
      returning
        value(rt_slpm_systems_of_customer) type zslpm_tt_systems.

endinterface.
