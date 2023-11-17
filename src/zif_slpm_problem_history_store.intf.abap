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
        value(rt_zslpm_pr_his_hry) type zslpm_tt_pr_his_hry,

    arch_orphaned_history_records
      raising
        zcx_slpm_data_manager_exc
        zcx_crm_order_api_exc
        zcx_assistant_utilities_exc
        zcx_slpm_configuration_exc
        zcx_system_user_exc,

    delete_arch_history_records
      importing
        ip_password type string,

    get_problem_flow_stat
      returning
        value(rt_problem_flow_stat) type zslpm_tt_pr_flow_stat
      raising
        zcx_crm_order_api_exc
        zcx_system_user_exc,

    get_dist_stco_count_by_stco
      importing
        ip_status_code  type j_estat
      returning
        value(rp_count) type int4.

endinterface.
