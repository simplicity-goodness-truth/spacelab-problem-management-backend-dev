interface zif_slpm_product
  public .
  interfaces zif_crm_product.

  methods get_priority
    returning
      value(rp_priority) type int1.

endinterface.
