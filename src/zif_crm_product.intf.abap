interface zif_crm_product
  public .

  methods
    get_id
      returning
        value(ep_id) type comt_product_id.

  methods
    get_name
      returning
        value(ep_name) type comt_prshtextx.

endinterface.
