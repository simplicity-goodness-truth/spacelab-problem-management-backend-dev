interface zif_slpm_odata_request
  public .

  methods:
    is_client_secure
      returning
        value(rp_secure) type abap_bool
      raising
        zcx_slpm_configuration_exc
        zcx_slpm_data_manager_exc.

endinterface.
