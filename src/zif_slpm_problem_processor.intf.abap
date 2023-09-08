interface zif_slpm_problem_processor
  public .
  methods:

    get_support_team_bp
      returning
        value(rp_bp) type bu_partner
      raising
        zcx_slpm_configuration_exc,

    get_support_team_org_unit
      returning
        value(rp_org_unit) type pd_objid_r
      raising
        zcx_slpm_configuration_exc.

endinterface.
