class zcl_slpm_product definition
  public
  inheriting from zcl_crm_product
  final
  create public .

  public section.
    interfaces zif_slpm_product.

  protected section.
  private section.
endclass.

class zcl_slpm_product implementation.

  method zif_slpm_product~get_priority.

    rp_priority = 0.

  endmethod.

endclass.
