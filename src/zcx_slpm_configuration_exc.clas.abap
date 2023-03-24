class ZCX_SLPM_CONFIGURATION_EXC definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

public section.

  interfaces IF_T100_MESSAGE .

  constants:
    begin of parameter_not_found,
        msgid type symsgid value 'ZSLPM_CONFIGURATION',
        msgno type symsgno value '001',
        attr1 type scx_attrname value 'MV_PARAMETER',
        attr2 type scx_attrname value '',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of parameter_not_found .
  constants:
    begin of ACTIVE_PROFILE_NOT_SET,
      msgid type symsgid value 'ZSLPM_CONFIGURATION',
      msgno type symsgno value '002',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ACTIVE_PROFILE_NOT_SET .
  data MV_PARAMETER type CHAR50 .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !IP_PARAMETER type CHAR50 optional .
  protected section.
  private section.
ENDCLASS.



CLASS ZCX_SLPM_CONFIGURATION_EXC IMPLEMENTATION.


  method constructor ##ADT_SUPPRESS_GENERATION.
    call method super->constructor
      exporting
        previous = previous.
    me->mv_parameter = ip_parameter .
    clear me->textid.
    if textid is initial.
      if_t100_message~t100key = if_t100_message=>default_textid.
    else.
      if_t100_message~t100key = textid.
    endif.
  endmethod.
ENDCLASS.
