interface zif_slpm_problem_observer
  public .
  methods:

    problem_created
      importing
        is_problem type zcrm_order_ts_sl_problem,

    problem_updated
      importing
        is_problem type zcrm_order_ts_sl_problem.

endinterface.