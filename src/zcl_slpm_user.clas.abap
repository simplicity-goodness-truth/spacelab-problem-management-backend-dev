class zcl_slpm_user definition
  public
  inheriting from zcl_system_user
  create public .

  public section.

    interfaces:
      zif_slpm_user.

  protected section.
  private section.

    methods is_contact_person_of
      returning
        value(rt_companies_bp) type crmt_bu_partner_t.

endclass.



class zcl_slpm_user implementation.

  method zif_slpm_user~get_slpm_products_of_user.

    data: lt_companies_bp              type crmt_bu_partner_t,
          lt_slpm_products_of_customer type zcrm_tt_products,
          ls_slpm_products_of_user type zcrm_ts_product,
          lo_slpm_customer             type ref to zif_slpm_customer.

    lt_companies_bp = me->is_contact_person_of(  ).

    loop at lt_companies_bp assigning field-symbol(<ls_company_bp>).

      lo_slpm_customer = new zcl_slpm_customer( <ls_company_bp> ).

      clear lt_slpm_products_of_customer.

      lt_slpm_products_of_customer = lo_slpm_customer->get_slpm_products_of_customer(  ).

      loop at lt_slpm_products_of_customer assigning field-symbol(<ls_slpm_products_of_customer>).

        move-corresponding <ls_slpm_products_of_customer> to ls_slpm_products_of_user.

        append ls_slpm_products_of_user to rt_slpm_products_of_user.

      endloop.

    endloop.

  endmethod.

  method is_contact_person_of.

    data lo_bp_master_data type ref to zif_bp_master_data.

    lo_bp_master_data = new zcl_bp_master_data( me->zif_system_user~get_businesspartner( ) ).

    rt_companies_bp = lo_bp_master_data->is_contact_person_of(  ).

  endmethod.

endclass.
