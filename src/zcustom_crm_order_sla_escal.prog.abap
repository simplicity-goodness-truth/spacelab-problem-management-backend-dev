*&---------------------------------------------------------------------*
*& Report  zcustom_crm_order_sla_escal
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
report zcustom_crm_order_sla_escal.

data lo_custom_crm_order_sla_escal type ref to zif_custom_crm_order_sla_escal.

lo_custom_crm_order_sla_escal = new zcl_custom_crm_order_sla_escal(  ).

lo_custom_crm_order_sla_escal->process_escalations(  ).
