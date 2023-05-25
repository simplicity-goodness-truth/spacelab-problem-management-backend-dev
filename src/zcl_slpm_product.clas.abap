class zcl_slpm_product definition
  public
  inheriting from zcl_crm_service_product
  final
  create public .

  public section.

    interfaces zif_slpm_product .
  protected section.
  private section.
endclass.

class zcl_slpm_product implementation.

  method zif_slpm_product~is_show_priority_set.

    data lv_product_id type comt_product_id.

    lv_product_id = me->zif_crm_product~get_id( ).

    select single showpriorities into rt_show_priority_set from zslpm_prod_attr
        where id = lv_product_id.

  endmethod.

endclass.
