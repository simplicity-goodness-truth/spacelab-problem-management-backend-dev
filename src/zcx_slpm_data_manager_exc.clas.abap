class zcx_slpm_data_manager_exc definition
  public
  inheriting from cx_static_check
  create public .

  public section.

    interfaces if_t100_message .

    constants:
      begin of not_authorized_for_read,
        msgid type symsgid value 'ZSLPM_DATA_MANAGER',
        msgno type symsgno value '001',
        attr1 type scx_attrname value 'MV_SYSTEM_USER',
        attr2 type scx_attrname value '',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of not_authorized_for_read .
    constants:
      begin of internal_error,
        msgid type symsgid value 'ZSLPM_DATA_MANAGER',
        msgno type symsgno value '002',
        attr1 type scx_attrname value 'MV_ERROR_MESSAGE',
        attr2 type scx_attrname value '',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of internal_error .
    class-data mv_system_user type xubname .
    class-data mv_error_message type string .

    methods constructor
      importing
        textid           like if_t100_message=>t100key optional
        previous         like previous optional
        ip_system_user   type xubname optional
        ip_error_message type string optional.
  protected section.
  private section.
ENDCLASS.



CLASS ZCX_SLPM_DATA_MANAGER_EXC IMPLEMENTATION.


  method constructor ##ADT_SUPPRESS_GENERATION.
    call method super->constructor
      exporting
        previous = previous.
    me->mv_system_user = ip_system_user .
    me->mv_error_message = ip_error_message.
    clear me->textid.
    if textid is initial.
      if_t100_message~t100key = if_t100_message=>default_textid.
    else.
      if_t100_message~t100key = textid.
    endif.
  endmethod.
ENDCLASS.
