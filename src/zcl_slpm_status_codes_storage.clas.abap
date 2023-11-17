class zcl_slpm_status_codes_storage definition
  public
  final
  create public .

  public section.

    interfaces
      zif_slpm_status_codes_storage.

  protected section.

  private section.

endclass.


class zcl_slpm_status_codes_storage implementation.


  method zif_slpm_status_codes_storage~get_status_codes_record.

    data:
      lt_class_status_codes type zcrm_order_tt_status_codes.

    case ip_status_codes_record_id.

      when 'FINAL'.

        lt_class_status_codes = value #(
              ( code = 'E0010' )
              ( code = 'E0018' )
          ).

      when 'CUSTOMER_ACTION'.

        lt_class_status_codes = value #(
            ( code = 'E0017' )
            ( code = 'E0003' )
            ( code = 'E0005' )
        ).

      when 'HOLD_IRT_SLA'.

        lt_class_status_codes = value #(
            ( code = 'E0017' )
        ).

      when 'HOLD_MPT_SLA'.

        lt_class_status_codes = value #(
            ( code = 'E0017' )
            ( code = 'E0003' )
            ( code = 'E0005' )
        ).

      when 'PROCESSOR_EDIT_MODE_ENABLED'.

        lt_class_status_codes = value #(

            ( code = 'E0001' )
            ( code = 'E0002' )
            ( code = 'E0003' )
            ( code = 'E0015' )
            ( code = 'E0016' )
            ( code = 'E0005' )
        ).

      when 'PROCESSOR_PRIORITY_CHANGE_ENABLED'.

        lt_class_status_codes = value #(
            ( code = 'E0001' )
            ( code = 'E0016' )
        ).

      when 'PROCESSOR_RETURN_FROM_WITHDRAWAL_ENABLED'.

        lt_class_status_codes = value #(
            ( code = 'E0010' )
        ).

      when 'REQUESTOR_CONFIRM_ENABLED'.

        lt_class_status_codes = value #(
            ( code = 'E0005' )
        ).

      when 'REQUESTOR_REPLY_ENABLED'.

        lt_class_status_codes = value #(
            ( code = 'E0003' )
            ( code = 'E0005' )
            ( code = 'E0017' )
        ).

      when 'REQUESTOR_UPDATE_ENABLED'.

        lt_class_status_codes = value #(
            ( code = 'E0001' )
            ( code = 'E0002' )
            ( code = 'E0016' )
        ).

      when 'REQUESTOR_WITHDRAW_ENABLED'.

        lt_class_status_codes = value #(
            ( code = 'E0001' )
            ( code = 'E0002' )
        ).

      when 'DISPUTE_OPEN'.

        lt_class_status_codes = value #(
            ( code = 'E0005' )

        ).

      when others.

    endcase.

    if lt_class_status_codes is not initial.

      ro_status_codes_record = new zcl_slpm_status_codes( lt_class_status_codes ).

    endif.


  endmethod.

endclass.
