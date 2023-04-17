program zsourcecode_namespace_changer.

************************************************************************
*  This program demonstrates how to create and use the TextEdit Control.
*   It shows how to put and retrieve text via internal tables to the
*   control.
*   The rudimentary error handling brings up popups. Replace this in
*   your application with something more usefull to your context.
************************************************************************

start-of-selection.
  call screen 100.

  constants: c_line_length type i value 512.

  types: begin of mytable_line,
           line(c_line_length) type c,
         end of mytable_line.

  types: begin of ty_replacement_line,
           before type string,
           after  type string,
         end of ty_replacement_line.

  types: tt_replacement_line type table of ty_replacement_line.

  data:
    g_editor               type ref to cl_gui_textedit,
    g_editor_container     type ref to cl_gui_custom_container,
    g_ok_code              like sy-ucomm,         " return code from screen
    g_repid                like sy-repid,
    g_mytable              type table of mytable_line,
    gt_initial_state       type table of mytable_line,
    gt_replacement_storage type tt_replacement_line.

* necessary to flush the automation queue
  class cl_gui_cfw definition load.

************************************************************************
*   P B O
************************************************************************
module pbo output.
  if g_editor is initial.

*   set status
    set pf-status 'MAIN100'.

*   initilize local variable with sy-repid, since sy-repid doesn't work
*    as parameter directly.
    g_repid = sy-repid.

*   create control container
    create object g_editor_container
      exporting
        container_name              = 'TEXTEDITOR1'
      exceptions
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.
    if sy-subrc ne 0.
*      add your handling
    endif.


*   create calls constructor, which initializes, creats and links
*    a TextEdit Control
    create object g_editor
      exporting
        parent                     = g_editor_container
        wordwrap_mode              = cl_gui_textedit=>wordwrap_at_fixed_position
        wordwrap_to_linebreak_mode = cl_gui_textedit=>true
      exceptions
        others                     = 1.
    if sy-subrc ne 0.
      call function 'POPUP_TO_INFORM'
        exporting
          titel = g_repid
          txt2  = space
          txt1  = text-001.
    endif.

  endif.                               " Editor is initial

* remember: there is an automatic flush at the end of PBO!

  " Filling of a replacements array

  gt_replacement_storage = value #(
      ( before = 'zcl_' after = 'ycl_' )
      ( before = 'ZCL_' after = 'YCL_' )
      ( before = 'zif_' after = 'yif_' )
      ( before = 'ZIF_' after = 'YIF_' )
      ( before = 'zslpm_' after = 'yslpm_' )
      ( before = 'ZSLPM_' after = 'YSLPM_' )
      ( before = 'zcrm_' after = 'ycrm_' )
      ( before = 'ZCRM_' after = 'YCRM_' )
      ( before = 'zmessenger_' after = 'ymessenger_' )
      ( before = 'ZMESSENGER_' after = 'ZMESSENGER_' )
      ( before = 'zuser_' after = 'yuser_' )
      ( before = 'ZUSER_' after = 'YUSER_' )
      ( before = 'zorg_model_' after = 'yorg_model_' )
      ( before = 'ZORG_ MODEL_' after = 'YORG_ MODEL_' )
      ( before = 'zst_text_' after = 'yst_text_' )
      ( before = 'ZST_TEXT_' after = 'YST_TEXT_' )
      ( before = 'zcx_' after = 'ycx_' )
      ( before = 'ZCX_' after = 'YCX_' )
      ( before = 'zsl_slpm_srv' after = 'ysl_slpm_srv' )
      ( before = 'ZSL_SLPM_SRV' after = 'YSL_SLPM_SRV' )
      ( before = 'zzfld' after = 'yyfld' )
      ( before = 'ZZFLD' after = 'YYFLD' )
      ( before = 'zslp0001' after = 'yslp0001' )
      ( before = 'ZSLP0001' after = 'YSLP0001' )
      ( before = 'zslp' after = 'yslp' )
      ( before = 'ZSLP' after = 'YSLP' )
  ).

endmodule.                             " PBO





************************************************************************
*   P A I
************************************************************************
module pai input.

  case g_ok_code.

    when 'PROCESS'.
      perform process_source_code.

    when 'EXIT'.
      perform exit_program.

    when 'RESTORE'.
      perform restore_to_initial_case.

  endcase.

  clear g_ok_code.
endmodule.                             " PAI


************************************************************************
*  F O R M S
************************************************************************


*&---------------------------------------------------------------------*
*&      Form  EXIT_PROGRAM
*&---------------------------------------------------------------------*

form restore_to_initial_case.

  if gt_initial_state is not initial.

    call method g_editor->set_text_as_r3table
      exporting
        table  = gt_initial_state
      exceptions
        others = 1.

  endif.

endform.

form process_source_code.

  data: lt_changed_table like g_mytable,
        ls_changed_table like line of lt_changed_table.

  call method g_editor->get_text_as_r3table
    importing
      table  = g_mytable
    exceptions
      others = 1.

  if sy-subrc ne 0.
    call function 'POPUP_TO_INFORM'
      exporting
        titel = g_repid
        txt2  = space
        txt1  = text-003.
  endif.

  gt_initial_state = g_mytable.

  loop at g_mytable assigning field-symbol(<ls_table_line>).

    ls_changed_table = <ls_table_line>.

    loop at gt_replacement_storage assigning field-symbol(<ls_replacement_pair>).

      replace all occurrences of  <ls_replacement_pair>-before in ls_changed_table with <ls_replacement_pair>-after .

    endloop.

    append ls_changed_table to lt_changed_table.

  endloop.

  if lt_changed_table is not initial.

    call method g_editor->set_text_as_r3table
      exporting
        table  = lt_changed_table
      exceptions
        others = 1.

  endif.


endform.


*&---------------------------------------------------------------------*
*&      Form  EXIT_PROGRAM
*&---------------------------------------------------------------------*
form exit_program.
* Destroy Control.
  if not g_editor is initial.
    call method g_editor->free
      exceptions
        others = 1.
    if sy-subrc ne 0.
      call function 'POPUP_TO_INFORM'
        exporting
          titel = g_repid
          txt2  = space
          txt1  = text-005.
    endif.
*   free ABAP object also
    free g_editor.
  endif.


* destroy container
  if not g_editor_container is initial.
    call method g_editor_container->free
      exceptions
        others = 1.
    if sy-subrc <> 0.
*         MESSAGE E002 WITH F_RETURN.
    endif.
*   free ABAP object also
    free g_editor_container.
  endif.


* finally flush
  call method cl_gui_cfw=>flush
    exceptions
      others = 1.
  if sy-subrc ne 0.
    call function 'POPUP_TO_INFORM'
      exporting
        titel = g_repid
        txt2  = space
        txt1  = text-002.
  endif.

  leave program.

endform.                               " EXIT_PROGRAM
