interface zif_custom_crm_order_read
  public .

  methods: get_guids_list
    returning
      value(et_result) type zcrm_order_tt_guids,

    get_all_statuses_list
      returning
        value(et_statuses) type zcrm_order_tt_statuses,

    get_all_priorities_list
      returning
        value(et_result) type zcrm_order_tt_priorities
      raising
        zcx_crm_order_api_exc,

    get_standard_fields_by_guid
      importing
        ip_guid          type crmt_object_guid
      returning
        value(es_result) type zcrm_order_ts
      raising
        zcx_crm_order_api_exc
        zcx_assistant_utilities_exc,

    get_custom_fields_by_guid
      importing
        ip_guid   type crmt_object_guid
      exporting
        es_result type ref to data
      raising
        cx_sy_dynamic_osql_semantics
        zcx_crm_order_api_exc,

    get_attachments_list_by_guid
      importing
        ip_guid                          type crmt_object_guid
      exporting
        value(et_attachments_list_short) type ict_crm_documents
        value(et_attachments_list)       type cl_ai_crm_gw_mymessage_mpc=>tt_attachment
      raising
        zcx_assistant_utilities_exc,

    get_attachment_by_keys
      importing
        ip_guid              type crmt_object_guid
        ip_loio              type string
        ip_phio              type string
      returning
        value(er_attachment) type aic_s_attachment_incdnt_odata
      raising
        zcx_crm_order_api_exc,

    get_attachment_content_by_keys
      importing
        ip_guid              type crmt_object_guid
        ip_loio              type string
        ip_phio              type string
      exporting
        value(er_stream)     type /iwbep/if_mgw_appl_types=>ty_s_media_resource
        value(er_attachment) type aic_s_attachment_incdnt_odata
      raising
        zcx_crm_order_api_exc,

    get_all_texts
      importing
        ip_guid  type crmt_object_guid
      exporting
        et_texts type cl_ai_crm_gw_mymessage_mpc=>tt_text
      raising
        zcx_crm_order_api_exc,

    get_last_text
      importing
        ip_guid        type crmt_object_guid
      returning
        value(es_text) type cl_ai_crm_gw_mymessage_mpc=>ts_text
      raising
        zcx_crm_order_api_exc,

    get_all_appointments_by_guid
      importing
        ip_guid                type crmt_object_guid
      returning
        value(rt_appointments) type crmt_appointment_wrkt,

    get_sla_status_by_guid
      importing
        ip_guid              type crmt_object_guid
      returning
        value(rs_sla_status) type ais_sla_status
      raising
        zcx_crm_order_api_exc.


endinterface.
