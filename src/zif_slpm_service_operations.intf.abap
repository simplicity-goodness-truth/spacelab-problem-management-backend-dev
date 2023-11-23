interface zif_slpm_service_operations
  public .

  methods:

    clear_attachments_trash_bin,

    clear_problems_history
      importing ip_password type string
      raising
                zcx_crm_order_api_exc
                zcx_assistant_utilities_exc
                zcx_slpm_configuration_exc
                zcx_system_user_exc
                zcx_slpm_data_manager_exc,

    clear_attachments_vsblty_table,

    clear_escalation_log,

    archive_irt_history
      raising
        zcx_slpm_data_manager_exc
        zcx_crm_order_api_exc
        zcx_assistant_utilities_exc
        zcx_slpm_configuration_exc
        zcx_system_user_exc,

    clear_irt_history
      importing
        ip_password type string,

    archive_mpt_history
      raising
        zcx_slpm_data_manager_exc
        zcx_crm_order_api_exc
        zcx_assistant_utilities_exc
        zcx_slpm_configuration_exc
        zcx_system_user_exc,

    clear_mpt_history
      importing
        ip_password type string,

    archive_dispute_history
      raising
        zcx_slpm_data_manager_exc
        zcx_crm_order_api_exc
        zcx_assistant_utilities_exc
        zcx_slpm_configuration_exc
        zcx_system_user_exc,

    clear_dispute_history
      importing
        ip_password type string.

endinterface.
