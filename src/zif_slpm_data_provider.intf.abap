interface zif_slpm_data_provider
  public .
  methods get_problems_list
    returning
      value(et_result) type zcrm_order_tt_sl_problems
    raising
      zcx_crm_order_api_exc.


  methods get_problem
    importing
      ip_guid             type crmt_object_guid
      io_slmp_problem_api type ref to zcl_slpm_problem_api optional
    returning
      value(es_result)    type zcrm_order_ts_sl_problem
    raising
      zcx_crm_order_api_exc.

  methods get_texts
    importing
      ip_guid  type crmt_object_guid
    exporting
      et_texts type cl_ai_crm_gw_mymessage_mpc=>tt_text
    raising
      zcx_crm_order_api_exc.

  methods get_attachments_list
    importing
      ip_guid                          type crmt_object_guid
    exporting
      value(et_attachments_list_short) type ict_crm_documents
      value(et_attachments_list)       type cl_ai_crm_gw_mymessage_mpc=>tt_attachment
    raising
      zcx_crm_order_api_exc
      zcx_assistant_utilities_exc.

  methods get_attachment
    importing
      ip_guid              type crmt_object_guid
      ip_loio              type string
      ip_phio              type string
    returning
      value(er_attachment) type aic_s_attachment_incdnt_odata
    raising
      zcx_crm_order_api_exc.

  methods get_attachment_content
    importing
      ip_guid              type crmt_object_guid
      ip_loio              type string
      ip_phio              type string
    exporting
      value(er_stream)     type /iwbep/if_mgw_appl_types=>ty_s_media_resource
      value(er_attachment) type aic_s_attachment_incdnt_odata
    raising
      zcx_crm_order_api_exc.

  methods create_attachment
    importing
      ip_guid      type crmt_object_guid
      ip_file_name type string
      ip_mime_type type string
      ip_content   type xstring
    raising
      zcx_crm_order_api_exc.

  methods delete_attachment
    importing
      ip_guid type crmt_object_guid
      ip_loio type string
      ip_phio type string
    raising
      zcx_crm_order_api_exc.

  methods create_text
    importing
      ip_guid type crmt_object_guid
      ip_text type string
      ip_tdid type tdid
    raising
      zcx_crm_order_api_exc.

  methods get_last_text
    importing
      ip_guid        type crmt_object_guid
    returning
      value(es_text) type cl_ai_crm_gw_mymessage_mpc=>ts_text
    raising
      zcx_crm_order_api_exc.

  methods create_problem
    importing
      is_problem     type zcrm_order_ts_sl_problem
    returning
      value(rp_guid) type crmt_object_guid
    raising
      zcx_crm_order_api_exc..

endinterface.
