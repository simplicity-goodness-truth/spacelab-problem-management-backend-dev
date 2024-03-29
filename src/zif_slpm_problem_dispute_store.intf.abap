interface zif_slpm_problem_dispute_store
  public .

  methods:

    open_problem_dispute,

    close_problem_dispute,

    get_problem_dispute_history
      returning
        value(rt_dispute_history) type zslpm_tt_dispute_hist,

    is_problem_dispute_open
      returning
        value(rp_dispute_active) type abap_bool,

    is_there_problem_dispute_hist
      returning
        value(rp_dispute_hist_exists) type abap_bool.

endinterface.
