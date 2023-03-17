class zcl_standart_text definition
  public
  create public .

  public section.

    interfaces zif_standard_text .

    methods constructor
      importing
        ip_text_name     type tdobname
        ip_text_language type spras.

  protected section.

  private section.
    data: mt_text_lines type table of tline.

endclass.

class zcl_standart_text implementation.

  method zif_standard_text~get_compiled_text_by_name.

    data: lv_text_for_processing type string,
          lv_text_token          type string.

    lv_text_for_processing = me->zif_standard_text~get_raw_text_by_name(  ).

    loop at it_variables_values assigning field-symbol(<is_variable_value>).

      lv_text_token = <is_variable_value>-value.

      if ( ip_use_tags eq abap_true ).

        if <is_variable_value>-opentag is not initial.

          lv_text_token = |{ <is_variable_value>-opentag }| && |{ lv_text_token }|.

        endif.

        if <is_variable_value>-closetag is not initial.

          lv_text_token = |{ lv_text_token }| && |{ <is_variable_value>-closetag }|.

        endif.

      endif.

      replace <is_variable_value>-variable in lv_text_for_processing with lv_text_token.

    endloop.

    rp_compiled_text = lv_text_for_processing.

  endmethod.

  method zif_standard_text~get_raw_text_by_name.

    if mt_text_lines is not initial.

      data ls_text_line type char255.

      loop at mt_text_lines into ls_text_line.

        rp_raw_text  = rp_raw_text && | | && |{ ls_text_line+2 }|.

      endloop. "loop at lt_line into ls_line

    endif.

  endmethod.

  method constructor.

    call function 'READ_TEXT'
      exporting
        client                  = sy-mandt
        id                      = 'ST'
        language                = ip_text_language
        name                    = ip_text_name
        object                  = 'TEXT'
      tables
        lines                   = mt_text_lines
      exceptions
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        others                  = 8.

    if sy-subrc ne 0.

      " Process error

    endif.

  endmethod.

endclass.
