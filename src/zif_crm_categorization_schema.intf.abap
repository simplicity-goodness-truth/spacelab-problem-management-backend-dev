interface zif_crm_categorization_schema
  public .

  methods: get_hierarchy
    returning
      value(rt_hierarchy) type zcrm_tt_cat_schema_hierarchy,

    get_asp_label
      returning
        value(rp_label) type crm_erms_cat_ca_desc,

    get_hierarchy_cat_label
      importing
        ip_cat_id       type crm_erms_cat_ca_id
      returning
        value(rp_label) type crm_erms_cat_ca_desc.

endinterface.
