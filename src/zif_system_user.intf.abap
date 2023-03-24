interface zif_system_user
  public .

  methods: get_businesspartner
    returning
      value(rp_businesspartner) type bu_partner,

    get_fullname
      returning
        value(rp_fullname) type ad_namecpl
      raising
        zcx_system_user_exc.

endinterface.
