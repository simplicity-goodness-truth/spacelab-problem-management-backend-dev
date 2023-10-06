interface zif_http_request
  public .

  methods:
    is_header_aligned_to_filter
      importing
        it_filter         type zhttp_tt_request_header_filter
      returning
        value(rp_aligned) type abap_bool.



endinterface.
