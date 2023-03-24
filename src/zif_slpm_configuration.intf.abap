interface zif_slpm_configuration
  public .

  methods get_parameter_value
    importing
      ip_param_name   type char50
    returning
      value(rp_value) type text200
    raising
      zcx_slpm_configuration_exc.

endinterface.
