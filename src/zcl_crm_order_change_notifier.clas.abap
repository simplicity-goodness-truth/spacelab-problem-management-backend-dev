class zcl_crm_order_change_notifier definition
  public
  create public .

  public section.
    interfaces zif_crm_order_change_notifier .
    methods: get_order_new_state
      returning
        value(rs_order_new_state) type zcrm_order_ts,
      get_order_old_state
        returning
          value(rs_order_old_state) type zcrm_order_ts,
      constructor
        importing
          is_order_old_state type zcrm_order_ts
          is_order_new_state type zcrm_order_ts.
  protected section.
  private section.
    data: ms_order_old_state type zcrm_order_ts,
          ms_order_new_state type zcrm_order_ts.

endclass.

class zcl_crm_order_change_notifier implementation.

  method constructor.

    ms_order_new_state = is_order_new_state.
    ms_order_old_state = is_order_old_state.

  endmethod.

  method get_order_new_state.
    rs_order_new_state = me->ms_order_new_state.
  endmethod.

  method get_order_old_state.
    rs_order_old_state = me->ms_order_old_state.
  endmethod.

  method zif_crm_order_change_notifier~notify.
  endmethod.


endclass.
