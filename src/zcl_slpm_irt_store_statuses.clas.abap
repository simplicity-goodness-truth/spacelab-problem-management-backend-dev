class zcl_slpm_irt_store_statuses definition
  public
    inheriting from zcl_slpm_status_pairs
  final
  create public .

  public section.

    methods:
      constructor.

  protected section.

  private section.

ENDCLASS.



CLASS ZCL_SLPM_IRT_STORE_STATUSES IMPLEMENTATION.


  method constructor.

    super->constructor(
        value #(
            ( statusin = 'E0016' statusout = 'E0017' )
        )
    ).

  endmethod.
ENDCLASS.
