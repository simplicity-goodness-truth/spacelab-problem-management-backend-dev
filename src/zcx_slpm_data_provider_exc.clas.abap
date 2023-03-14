class zcx_slpm_data_provider_exc definition
  public
  inheriting from cx_static_check
  create public .

  public section.

    interfaces if_t100_message .

    constants:
      begin of not_authorized_for_read,
        msgid type symsgid value 'ZSLPM_DATA_PROVIDER',
        msgno type symsgno value '001',
        attr1 type scx_attrname value 'MV_SYSTEM_USER',
        attr2 type scx_attrname value '',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of not_authorized_for_read .
    class-data mv_system_user type xubname .

    methods constructor
      importing
        !textid      like if_t100_message=>t100key optional
        !previous    like previous optional
        !mv_system_user type xubname optional .
  protected section.
  private section.
endclass.



class zcx_slpm_data_provider_exc implementation.


  method constructor ##ADT_SUPPRESS_GENERATION.
    call method super->constructor
      exporting
        previous = previous.
    me->mv_system_user = mv_system_user .
    clear me->textid.
    if textid is initial.
      if_t100_message~t100key = if_t100_message=>default_textid.
    else.
      if_t100_message~t100key = textid.
    endif.
  endmethod.
endclass.
