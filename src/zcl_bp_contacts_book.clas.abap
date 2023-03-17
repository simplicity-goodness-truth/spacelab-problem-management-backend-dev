class zcl_bp_contacts_book definition
  public
  create public .

  public section.
    interfaces zif_contacts_book .
    methods constructor
      importing
        ip_bp_num type bu_partner.

  protected section.
  private section.
    data: mv_bp_num type bu_partner,
          ms_but000 type but000.

    methods: set_but000.

endclass.

class zcl_bp_contacts_book implementation.

  method constructor.

    call function 'CONVERSION_EXIT_ALPHA_INPUT'
      exporting
        input  = ip_bp_num
      importing
        output = mv_bp_num.

  endmethod.

  method set_but000.

    if ( mv_bp_num is not initial ) and ( mv_bp_num ne '0000000000' ).

      select single * into ms_but000 from but000
       where partner eq mv_bp_num.

    endif.

  endmethod.

  method zif_contacts_book~get_full_name.

    if ms_but000 is initial.

      me->set_but000(  ).

    endif.

    rp_full_name = cond #(
          when ms_but000-name1_text is not initial then ms_but000-name1_text
          else |{ ms_but000-name_first }| && | | && |{ ms_but000-name_last }|
        ).

  endmethod.



  method zif_contacts_book~get_email_address.

    if ms_but000 is initial.

      me->set_but000(  ).

    endif.

    " email search depends on a type of a Business Partner

    case ms_but000-type.

      when 1.

        " Business Partner is a Person

        select single smtp_addr into rp_email_address from adr6 where
          persnumber = ms_but000-persnumber.

      when 2.

        " Business Partner is an Organization

        select single smtp_addr into rp_email_address from adr6 where
          addrnumber = ms_but000-addrcomm.

    endcase.

  endmethod.

endclass.
