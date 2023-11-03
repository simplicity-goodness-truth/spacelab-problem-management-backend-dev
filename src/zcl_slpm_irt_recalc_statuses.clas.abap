class zcl_slpm_irt_recalc_statuses definition
  public
    inheriting from zcl_slpm_status_pairs
  final
  create public .

  public section.

    methods:
      constructor.

  protected section.

  private section.

endclass.

class zcl_slpm_irt_recalc_statuses implementation.

  method constructor.

    super->constructor(
        value #(
            ( statusin = 'E0017' statusout = 'E0016' )
        )
    ).

  endmethod.

endclass.
