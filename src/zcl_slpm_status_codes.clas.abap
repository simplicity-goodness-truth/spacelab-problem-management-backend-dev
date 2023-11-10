class zcl_slpm_status_codes definition
  public
  create public .

  public section.

    interfaces zif_slpm_status_codes .

    methods:
      constructor
        importing
          it_class_status_codes type zcrm_order_tt_status_codes.

  protected section.

    data:
      mt_class_status_codes type zcrm_order_tt_status_codes.

  private section.

    methods set_class_status_codes
      importing
        it_class_status_codes type zcrm_order_tt_status_codes.

endclass.

class zcl_slpm_status_codes implementation.

  method zif_slpm_status_codes~get_all_status_codes.

    rt_status_codes = mt_class_status_codes.

  endmethod.

  method constructor.

    me->set_class_status_codes( it_class_status_codes ).

  endmethod.

  method set_class_status_codes.

    mt_class_status_codes = it_class_status_codes.

  endmethod.

endclass.
