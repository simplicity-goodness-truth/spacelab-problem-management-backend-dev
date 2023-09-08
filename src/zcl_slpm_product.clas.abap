class zcl_slpm_product definition
  public
  inheriting from zcl_crm_service_product
  final
  create public .

  public section.

    interfaces zif_slpm_product .

    methods constructor
      importing
        ip_guid type comt_product_guid.

  protected section.
  private section.

    data ms_product_attrs type zslpm_prod_attr.

    methods: set_product_attrs.

endclass.

class zcl_slpm_product implementation.


  method zif_slpm_product~is_show_priority_set.

    rt_show_priority_set = ms_product_attrs-showpriorities.
*    data lv_product_id type comt_product_id.
*
*    lv_product_id = me->zif_crm_product~get_id( ).
*
*    select single showpriorities into rt_show_priority_set from zslpm_prod_attr
*        where id = lv_product_id.

  endmethod.

  method zif_slpm_product~get_org_unit_for_updates.

    rp_org_unit = ms_product_attrs-statusupdatesorgunit.

  endmethod.

  method set_product_attrs.

    data lv_product_id type comt_product_id.

    if ms_product_attrs is initial.

      lv_product_id = me->zif_crm_product~get_id( ).

      select single
          mandt id description
          showpriorities processingorgunit statusupdatesorgunit statusupdatessignature
          into ms_product_attrs from zslpm_prod_attr
        where id = lv_product_id.

    endif.

  endmethod.

  method constructor.

    super->constructor( ip_guid = ip_guid ).

    me->set_product_attrs( ).

  endmethod.

  method zif_slpm_product~get_signature_for_updates.

    rp_signature = ms_product_attrs-statusupdatessignature.

  endmethod.

  method zif_slpm_product~get_processing_org_unit.

    rp_org_unit = ms_product_attrs-processingorgunit.

  endmethod.

endclass.
