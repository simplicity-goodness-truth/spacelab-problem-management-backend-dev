class zcl_email_messenger definition
  public
  final
  create public .

  public section.
    interfaces zif_messenger .
    methods constructor.
  protected section.
  private section.
    methods prepare_email_body
      importing
        ip_message_body_text type string.

    data: mo_email_client  type ref to cl_bcs,
                mt_email_body    type bcsy_text,
                mv_email_subject type so_obj_des,
                mo_email         type ref to cl_document_bcs.

endclass.

class zcl_email_messenger implementation.

  method zif_messenger~set_message_body.

    me->prepare_email_body( ip_message_body_text ).

    if mt_email_body is not initial.

      try.
          mo_email = cl_document_bcs=>create_document(
                            i_type = cond so_obj_tp( when ip_message_body_type ne '' then ip_message_body_type
                                                        else 'RAW' )
                            i_text = mt_email_body
                            i_subject = mv_email_subject ).

          mo_email_client->set_document( mo_email ).

        catch cx_document_bcs into data(lx_doc_bcs).
          "Error handling
        catch cx_send_req_bcs into data(lx_req_bsc).
          "Error handling
      endtry.

    endif.

  endmethod.

  method zif_messenger~set_message_attachments.

    try.

        loop at it_message_attachments assigning field-symbol(<ls_attachment>).

          mo_email->add_attachment(
            i_attachment_type    = <ls_attachment>-type
            i_attachment_size    = conv #( xstrlen( <ls_attachment>-media ) )
            i_attachment_subject = <ls_attachment>-subject
            i_attachment_header  = value #( ( line = <ls_attachment>-name ) )
            i_att_content_hex    = cl_bcs_convert=>xstring_to_solix( <ls_attachment>-media )
         ).

        endloop.

      catch cx_document_bcs into data(lx_doc_bcs).
        "Error handling
    endtry.

  endmethod.

  method zif_messenger~set_message_sender.

    data lv_sender_address type so_recname.

    try.

        lv_sender_address = ip_message_sender.

        mo_email_client->set_sender(
          cl_cam_address_bcs=>create_internet_address(
            i_address_string = conv #( lv_sender_address )
          )
        ).

      catch cx_send_req_bcs into data(lx_req_bsc).
        "Error handling
      catch cx_document_bcs into data(lx_doc_bcs).
        "Error handling
      catch cx_address_bcs  into data(lx_add_bcs).
        "Error handling

    endtry.


  endmethod.

  method zif_messenger~set_message_recepients.

    data lv_recepient_address type so_recname.

    try.

        loop at it_message_recepients assigning field-symbol(<ls_recepient_address>).

          lv_recepient_address = <ls_recepient_address>.


          mo_email_client->add_recipient(
            i_recipient = cl_cam_address_bcs=>create_internet_address(
                            i_address_string = conv #( lv_recepient_address )
                          )
            i_express   = abap_true ).

        endloop.

      catch cx_send_req_bcs into data(lx_req_bsc).
        "Error handling
      catch cx_document_bcs into data(lx_doc_bcs).
        "Error handling
      catch cx_address_bcs  into data(lx_add_bcs).
        "Error handling

    endtry.

  endmethod.

  method zif_messenger~send_message.

    try.

        data(lv_sent_to_all) = mo_email_client->send( ).
        commit work.

      catch cx_send_req_bcs into data(lx_req_bsc).

        write lx_req_bsc->get_text(  ).
        "Error handling

    endtry.

  endmethod.

  method constructor.

    try.
        mo_email_client = cl_bcs=>create_persistent(  ).
      catch cx_send_req_bcs into data(lx_req_bsc).
    endtry.

  endmethod.

  method prepare_email_body.

    call function 'SO_STRING_TO_TAB'
      exporting
        content_str = ip_message_body_text
      tables
        content_tab = me->mt_email_body.

  endmethod.

  method zif_messenger~set_message_subject.

    mv_email_subject = ip_message_subject_text.

  endmethod.

endclass.
