interface zif_organizational_model
  public .

  methods:
    get_subunits_of_org_unit
      returning
        value(rt_sub_units) type crmt_orgman_swhactor_tab,

    get_assigned_pos_of_org_unit
      importing
        ip_get_upper_levels type abap_bool optional
      returning
        value(rt_positions) type zorg_model_tt_positions.

endinterface.
