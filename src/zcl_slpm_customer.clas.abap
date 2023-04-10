class zcl_slpm_customer definition
  public
    inheriting from zcl_company
  create public .

  public section.

    interfaces:
      zif_slpm_customer.

  protected section.
  private section.
endclass.

class zcl_slpm_customer implementation.

  method zif_slpm_customer~get_slpm_products_of_customer.

    data: lv_bp_number                type bu_partner,
          ls_slpm_product_of_customer type zslpm_ts_product,
          lt_customer_product_ids     type table of comm_product-product_id.

    lv_bp_number = me->zif_company~get_company_bp_number(  ).

    if lv_bp_number is not initial.

      select productid from zslpm_cust_prod into table lt_customer_product_ids
      where customerbusinesspartner = lv_bp_number.

      loop at lt_customer_product_ids assigning field-symbol(<ls_customer_product_id>).

        select single a~product_guid a~product_id b~short_text
              from (
                  comm_product as a inner join
                  comm_prshtext as b
                  on a~product_guid = b~product_guid )
                  into ls_slpm_product_of_customer
                  where
                  a~product_id = <ls_customer_product_id> and
                  b~langu = sy-langu.

        ls_slpm_product_of_customer-companybusinesspartner = lv_bp_number.

        append ls_slpm_product_of_customer to rt_slpm_products_of_customer.

      endloop.

    endif.

  endmethod.


endclass.
