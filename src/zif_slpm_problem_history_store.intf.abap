interface zif_slpm_problem_history_store
  public .

  methods:

    get_problem_history_headers
      returning
        value(rt_zslpm_pr_his_hdr) type zslpm_tt_pr_his_hdr,

    get_problem_history_records
      returning
        value(rt_zslpm_pr_his_rec) type zslpm_tt_pr_his_rec,

    get_problem_history_hierarchy
      returning
        value(rt_zslpm_pr_his_hry) type zslpm_tt_pr_his_hry.

endinterface.
