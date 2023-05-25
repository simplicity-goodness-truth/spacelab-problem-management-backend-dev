*---------------------------------------------------------------------*
*    view related FORM routines
*---------------------------------------------------------------------*
*...processing: ZSLPMCUSTPRODVW.................................*
FORM GET_DATA_ZSLPMCUSTPRODVW.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM ZSLPM_CUST_PROD WHERE
(VIM_WHERETAB) .
    CLEAR ZSLPMCUSTPRODVW .
ZSLPMCUSTPRODVW-MANDT =
ZSLPM_CUST_PROD-MANDT .
ZSLPMCUSTPRODVW-CUSTOMERBUSINESSPARTNER =
ZSLPM_CUST_PROD-CUSTOMERBUSINESSPARTNER .
ZSLPMCUSTPRODVW-PRODUCTID =
ZSLPM_CUST_PROD-PRODUCTID .
<VIM_TOTAL_STRUC> = ZSLPMCUSTPRODVW.
    APPEND TOTAL.
  ENDSELECT.
  SORT TOTAL BY <VIM_XTOTAL_KEY>.
  <STATUS>-ALR_SORTED = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF X_HEADER-SELECTION NE SPACE.
    PERFORM CHECK_DYNAMIC_SELECT_OPTIONS.
  ELSEIF X_HEADER-DELMDTFLAG NE SPACE.
    PERFORM BUILD_MAINKEY_TAB.
  ENDIF.
  REFRESH EXTRACT.
ENDFORM.
*---------------------------------------------------------------------*
FORM DB_UPD_ZSLPMCUSTPRODVW .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO ZSLPMCUSTPRODVW.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_ZSLPMCUSTPRODVW-ST_DELETE EQ GELOESCHT.
     READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
     IF SY-SUBRC EQ 0.
       DELETE EXTRACT INDEX SY-TABIX.
     ENDIF.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN GELOESCHT.
  SELECT SINGLE FOR UPDATE * FROM ZSLPM_CUST_PROD WHERE
  CUSTOMERBUSINESSPARTNER = ZSLPMCUSTPRODVW-CUSTOMERBUSINESSPARTNER AND
  PRODUCTID = ZSLPMCUSTPRODVW-PRODUCTID .
    IF SY-SUBRC = 0.
    DELETE ZSLPM_CUST_PROD .
    ENDIF.
    IF STATUS-DELETE EQ GELOESCHT.
      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY> BINARY SEARCH.
      DELETE EXTRACT INDEX SY-TABIX.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN OTHERS.
  SELECT SINGLE FOR UPDATE * FROM ZSLPM_CUST_PROD WHERE
  CUSTOMERBUSINESSPARTNER = ZSLPMCUSTPRODVW-CUSTOMERBUSINESSPARTNER AND
  PRODUCTID = ZSLPMCUSTPRODVW-PRODUCTID .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR ZSLPM_CUST_PROD.
    ENDIF.
ZSLPM_CUST_PROD-MANDT =
ZSLPMCUSTPRODVW-MANDT .
ZSLPM_CUST_PROD-CUSTOMERBUSINESSPARTNER =
ZSLPMCUSTPRODVW-CUSTOMERBUSINESSPARTNER .
ZSLPM_CUST_PROD-PRODUCTID =
ZSLPMCUSTPRODVW-PRODUCTID .
    IF SY-SUBRC = 0.
    UPDATE ZSLPM_CUST_PROD ##WARN_OK.
    ELSE.
    INSERT ZSLPM_CUST_PROD .
    ENDIF.
    READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
    IF SY-SUBRC EQ 0.
      <XACT> = ORIGINAL.
      MODIFY EXTRACT INDEX SY-TABIX.
    ENDIF.
    <ACTION> = ORIGINAL.
    MODIFY TOTAL.
  ENDCASE.
ENDLOOP.
CLEAR: STATUS_ZSLPMCUSTPRODVW-UPD_FLAG,
STATUS_ZSLPMCUSTPRODVW-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_ZSLPMCUSTPRODVW.
  SELECT SINGLE * FROM ZSLPM_CUST_PROD WHERE
CUSTOMERBUSINESSPARTNER = ZSLPMCUSTPRODVW-CUSTOMERBUSINESSPARTNER AND
PRODUCTID = ZSLPMCUSTPRODVW-PRODUCTID .
ZSLPMCUSTPRODVW-MANDT =
ZSLPM_CUST_PROD-MANDT .
ZSLPMCUSTPRODVW-CUSTOMERBUSINESSPARTNER =
ZSLPM_CUST_PROD-CUSTOMERBUSINESSPARTNER .
ZSLPMCUSTPRODVW-PRODUCTID =
ZSLPM_CUST_PROD-PRODUCTID .
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_ZSLPMCUSTPRODVW USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE ZSLPMCUSTPRODVW-CUSTOMERBUSINESSPARTNER TO
ZSLPM_CUST_PROD-CUSTOMERBUSINESSPARTNER .
MOVE ZSLPMCUSTPRODVW-PRODUCTID TO
ZSLPM_CUST_PROD-PRODUCTID .
MOVE ZSLPMCUSTPRODVW-MANDT TO
ZSLPM_CUST_PROD-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = 'ZSLPM_CUST_PROD'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN ZSLPM_CUST_PROD TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING 'ZSLPM_CUST_PROD'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
*...processing: ZSLPMCUSTSYSTVW.................................*
FORM GET_DATA_ZSLPMCUSTSYSTVW.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM ZSLPM_CUST_SYST WHERE
(VIM_WHERETAB) .
    CLEAR ZSLPMCUSTSYSTVW .
ZSLPMCUSTSYSTVW-MANDT =
ZSLPM_CUST_SYST-MANDT .
ZSLPMCUSTSYSTVW-CUSTOMERBUSINESSPARTNER =
ZSLPM_CUST_SYST-CUSTOMERBUSINESSPARTNER .
ZSLPMCUSTSYSTVW-SAPSYSTEMNAME =
ZSLPM_CUST_SYST-SAPSYSTEMNAME .
ZSLPMCUSTSYSTVW-INSTALLATIONNUMBER =
ZSLPM_CUST_SYST-INSTALLATIONNUMBER .
ZSLPMCUSTSYSTVW-SYSTEMNUMBER =
ZSLPM_CUST_SYST-SYSTEMNUMBER .
ZSLPMCUSTSYSTVW-DESCRIPTION =
ZSLPM_CUST_SYST-DESCRIPTION .
ZSLPMCUSTSYSTVW-ROLE =
ZSLPM_CUST_SYST-ROLE .
<VIM_TOTAL_STRUC> = ZSLPMCUSTSYSTVW.
    APPEND TOTAL.
  ENDSELECT.
  SORT TOTAL BY <VIM_XTOTAL_KEY>.
  <STATUS>-ALR_SORTED = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF X_HEADER-SELECTION NE SPACE.
    PERFORM CHECK_DYNAMIC_SELECT_OPTIONS.
  ELSEIF X_HEADER-DELMDTFLAG NE SPACE.
    PERFORM BUILD_MAINKEY_TAB.
  ENDIF.
  REFRESH EXTRACT.
ENDFORM.
*---------------------------------------------------------------------*
FORM DB_UPD_ZSLPMCUSTSYSTVW .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO ZSLPMCUSTSYSTVW.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_ZSLPMCUSTSYSTVW-ST_DELETE EQ GELOESCHT.
     READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
     IF SY-SUBRC EQ 0.
       DELETE EXTRACT INDEX SY-TABIX.
     ENDIF.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN GELOESCHT.
  SELECT SINGLE FOR UPDATE * FROM ZSLPM_CUST_SYST WHERE
  CUSTOMERBUSINESSPARTNER = ZSLPMCUSTSYSTVW-CUSTOMERBUSINESSPARTNER AND
  SAPSYSTEMNAME = ZSLPMCUSTSYSTVW-SAPSYSTEMNAME .
    IF SY-SUBRC = 0.
    DELETE ZSLPM_CUST_SYST .
    ENDIF.
    IF STATUS-DELETE EQ GELOESCHT.
      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY> BINARY SEARCH.
      DELETE EXTRACT INDEX SY-TABIX.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN OTHERS.
  SELECT SINGLE FOR UPDATE * FROM ZSLPM_CUST_SYST WHERE
  CUSTOMERBUSINESSPARTNER = ZSLPMCUSTSYSTVW-CUSTOMERBUSINESSPARTNER AND
  SAPSYSTEMNAME = ZSLPMCUSTSYSTVW-SAPSYSTEMNAME .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR ZSLPM_CUST_SYST.
    ENDIF.
ZSLPM_CUST_SYST-MANDT =
ZSLPMCUSTSYSTVW-MANDT .
ZSLPM_CUST_SYST-CUSTOMERBUSINESSPARTNER =
ZSLPMCUSTSYSTVW-CUSTOMERBUSINESSPARTNER .
ZSLPM_CUST_SYST-SAPSYSTEMNAME =
ZSLPMCUSTSYSTVW-SAPSYSTEMNAME .
ZSLPM_CUST_SYST-INSTALLATIONNUMBER =
ZSLPMCUSTSYSTVW-INSTALLATIONNUMBER .
ZSLPM_CUST_SYST-SYSTEMNUMBER =
ZSLPMCUSTSYSTVW-SYSTEMNUMBER .
ZSLPM_CUST_SYST-DESCRIPTION =
ZSLPMCUSTSYSTVW-DESCRIPTION .
ZSLPM_CUST_SYST-ROLE =
ZSLPMCUSTSYSTVW-ROLE .
    IF SY-SUBRC = 0.
    UPDATE ZSLPM_CUST_SYST ##WARN_OK.
    ELSE.
    INSERT ZSLPM_CUST_SYST .
    ENDIF.
    READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
    IF SY-SUBRC EQ 0.
      <XACT> = ORIGINAL.
      MODIFY EXTRACT INDEX SY-TABIX.
    ENDIF.
    <ACTION> = ORIGINAL.
    MODIFY TOTAL.
  ENDCASE.
ENDLOOP.
CLEAR: STATUS_ZSLPMCUSTSYSTVW-UPD_FLAG,
STATUS_ZSLPMCUSTSYSTVW-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_ZSLPMCUSTSYSTVW.
  SELECT SINGLE * FROM ZSLPM_CUST_SYST WHERE
CUSTOMERBUSINESSPARTNER = ZSLPMCUSTSYSTVW-CUSTOMERBUSINESSPARTNER AND
SAPSYSTEMNAME = ZSLPMCUSTSYSTVW-SAPSYSTEMNAME .
ZSLPMCUSTSYSTVW-MANDT =
ZSLPM_CUST_SYST-MANDT .
ZSLPMCUSTSYSTVW-CUSTOMERBUSINESSPARTNER =
ZSLPM_CUST_SYST-CUSTOMERBUSINESSPARTNER .
ZSLPMCUSTSYSTVW-SAPSYSTEMNAME =
ZSLPM_CUST_SYST-SAPSYSTEMNAME .
ZSLPMCUSTSYSTVW-INSTALLATIONNUMBER =
ZSLPM_CUST_SYST-INSTALLATIONNUMBER .
ZSLPMCUSTSYSTVW-SYSTEMNUMBER =
ZSLPM_CUST_SYST-SYSTEMNUMBER .
ZSLPMCUSTSYSTVW-DESCRIPTION =
ZSLPM_CUST_SYST-DESCRIPTION .
ZSLPMCUSTSYSTVW-ROLE =
ZSLPM_CUST_SYST-ROLE .
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_ZSLPMCUSTSYSTVW USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE ZSLPMCUSTSYSTVW-CUSTOMERBUSINESSPARTNER TO
ZSLPM_CUST_SYST-CUSTOMERBUSINESSPARTNER .
MOVE ZSLPMCUSTSYSTVW-SAPSYSTEMNAME TO
ZSLPM_CUST_SYST-SAPSYSTEMNAME .
MOVE ZSLPMCUSTSYSTVW-MANDT TO
ZSLPM_CUST_SYST-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = 'ZSLPM_CUST_SYST'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN ZSLPM_CUST_SYST TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING 'ZSLPM_CUST_SYST'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
*...processing: ZSLPMEMAILRULEVW................................*
FORM GET_DATA_ZSLPMEMAILRULEVW.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM ZSLPM_EMAIL_RULE WHERE
(VIM_WHERETAB) .
    CLEAR ZSLPMEMAILRULEVW .
ZSLPMEMAILRULEVW-MANDT =
ZSLPM_EMAIL_RULE-MANDT .
ZSLPMEMAILRULEVW-RULENAME =
ZSLPM_EMAIL_RULE-RULENAME .
ZSLPMEMAILRULEVW-INTERNAL =
ZSLPM_EMAIL_RULE-INTERNAL .
ZSLPMEMAILRULEVW-STTEXTSUBJ =
ZSLPM_EMAIL_RULE-STTEXTSUBJ .
ZSLPMEMAILRULEVW-STTEXTBODY =
ZSLPM_EMAIL_RULE-STTEXTBODY .
<VIM_TOTAL_STRUC> = ZSLPMEMAILRULEVW.
    APPEND TOTAL.
  ENDSELECT.
  SORT TOTAL BY <VIM_XTOTAL_KEY>.
  <STATUS>-ALR_SORTED = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF X_HEADER-SELECTION NE SPACE.
    PERFORM CHECK_DYNAMIC_SELECT_OPTIONS.
  ELSEIF X_HEADER-DELMDTFLAG NE SPACE.
    PERFORM BUILD_MAINKEY_TAB.
  ENDIF.
  REFRESH EXTRACT.
ENDFORM.
*---------------------------------------------------------------------*
FORM DB_UPD_ZSLPMEMAILRULEVW .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO ZSLPMEMAILRULEVW.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_ZSLPMEMAILRULEVW-ST_DELETE EQ GELOESCHT.
     READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
     IF SY-SUBRC EQ 0.
       DELETE EXTRACT INDEX SY-TABIX.
     ENDIF.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN GELOESCHT.
  SELECT SINGLE FOR UPDATE * FROM ZSLPM_EMAIL_RULE WHERE
  RULENAME = ZSLPMEMAILRULEVW-RULENAME .
    IF SY-SUBRC = 0.
    DELETE ZSLPM_EMAIL_RULE .
    ENDIF.
    IF STATUS-DELETE EQ GELOESCHT.
      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY> BINARY SEARCH.
      DELETE EXTRACT INDEX SY-TABIX.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN OTHERS.
  SELECT SINGLE FOR UPDATE * FROM ZSLPM_EMAIL_RULE WHERE
  RULENAME = ZSLPMEMAILRULEVW-RULENAME .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR ZSLPM_EMAIL_RULE.
    ENDIF.
ZSLPM_EMAIL_RULE-MANDT =
ZSLPMEMAILRULEVW-MANDT .
ZSLPM_EMAIL_RULE-RULENAME =
ZSLPMEMAILRULEVW-RULENAME .
ZSLPM_EMAIL_RULE-INTERNAL =
ZSLPMEMAILRULEVW-INTERNAL .
ZSLPM_EMAIL_RULE-STTEXTSUBJ =
ZSLPMEMAILRULEVW-STTEXTSUBJ .
ZSLPM_EMAIL_RULE-STTEXTBODY =
ZSLPMEMAILRULEVW-STTEXTBODY .
    IF SY-SUBRC = 0.
    UPDATE ZSLPM_EMAIL_RULE ##WARN_OK.
    ELSE.
    INSERT ZSLPM_EMAIL_RULE .
    ENDIF.
    READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
    IF SY-SUBRC EQ 0.
      <XACT> = ORIGINAL.
      MODIFY EXTRACT INDEX SY-TABIX.
    ENDIF.
    <ACTION> = ORIGINAL.
    MODIFY TOTAL.
  ENDCASE.
ENDLOOP.
CLEAR: STATUS_ZSLPMEMAILRULEVW-UPD_FLAG,
STATUS_ZSLPMEMAILRULEVW-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_ZSLPMEMAILRULEVW.
  SELECT SINGLE * FROM ZSLPM_EMAIL_RULE WHERE
RULENAME = ZSLPMEMAILRULEVW-RULENAME .
ZSLPMEMAILRULEVW-MANDT =
ZSLPM_EMAIL_RULE-MANDT .
ZSLPMEMAILRULEVW-RULENAME =
ZSLPM_EMAIL_RULE-RULENAME .
ZSLPMEMAILRULEVW-INTERNAL =
ZSLPM_EMAIL_RULE-INTERNAL .
ZSLPMEMAILRULEVW-STTEXTSUBJ =
ZSLPM_EMAIL_RULE-STTEXTSUBJ .
ZSLPMEMAILRULEVW-STTEXTBODY =
ZSLPM_EMAIL_RULE-STTEXTBODY .
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_ZSLPMEMAILRULEVW USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE ZSLPMEMAILRULEVW-RULENAME TO
ZSLPM_EMAIL_RULE-RULENAME .
MOVE ZSLPMEMAILRULEVW-MANDT TO
ZSLPM_EMAIL_RULE-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = 'ZSLPM_EMAIL_RULE'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN ZSLPM_EMAIL_RULE TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING 'ZSLPM_EMAIL_RULE'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
*...processing: ZSLPMPRODATTRVW.................................*
FORM GET_DATA_ZSLPMPRODATTRVW.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM ZSLPM_PROD_ATTR WHERE
(VIM_WHERETAB) .
    CLEAR ZSLPMPRODATTRVW .
ZSLPMPRODATTRVW-MANDT =
ZSLPM_PROD_ATTR-MANDT .
ZSLPMPRODATTRVW-ID =
ZSLPM_PROD_ATTR-ID .
ZSLPMPRODATTRVW-DESCRIPTION =
ZSLPM_PROD_ATTR-DESCRIPTION .
ZSLPMPRODATTRVW-SHOWPRIORITIES =
ZSLPM_PROD_ATTR-SHOWPRIORITIES .
<VIM_TOTAL_STRUC> = ZSLPMPRODATTRVW.
    APPEND TOTAL.
  ENDSELECT.
  SORT TOTAL BY <VIM_XTOTAL_KEY>.
  <STATUS>-ALR_SORTED = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF X_HEADER-SELECTION NE SPACE.
    PERFORM CHECK_DYNAMIC_SELECT_OPTIONS.
  ELSEIF X_HEADER-DELMDTFLAG NE SPACE.
    PERFORM BUILD_MAINKEY_TAB.
  ENDIF.
  REFRESH EXTRACT.
ENDFORM.
*---------------------------------------------------------------------*
FORM DB_UPD_ZSLPMPRODATTRVW .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO ZSLPMPRODATTRVW.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_ZSLPMPRODATTRVW-ST_DELETE EQ GELOESCHT.
     READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
     IF SY-SUBRC EQ 0.
       DELETE EXTRACT INDEX SY-TABIX.
     ENDIF.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN GELOESCHT.
  SELECT SINGLE FOR UPDATE * FROM ZSLPM_PROD_ATTR WHERE
  ID = ZSLPMPRODATTRVW-ID .
    IF SY-SUBRC = 0.
    DELETE ZSLPM_PROD_ATTR .
    ENDIF.
    IF STATUS-DELETE EQ GELOESCHT.
      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY> BINARY SEARCH.
      DELETE EXTRACT INDEX SY-TABIX.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN OTHERS.
  SELECT SINGLE FOR UPDATE * FROM ZSLPM_PROD_ATTR WHERE
  ID = ZSLPMPRODATTRVW-ID .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR ZSLPM_PROD_ATTR.
    ENDIF.
ZSLPM_PROD_ATTR-MANDT =
ZSLPMPRODATTRVW-MANDT .
ZSLPM_PROD_ATTR-ID =
ZSLPMPRODATTRVW-ID .
ZSLPM_PROD_ATTR-DESCRIPTION =
ZSLPMPRODATTRVW-DESCRIPTION .
ZSLPM_PROD_ATTR-SHOWPRIORITIES =
ZSLPMPRODATTRVW-SHOWPRIORITIES .
    IF SY-SUBRC = 0.
    UPDATE ZSLPM_PROD_ATTR ##WARN_OK.
    ELSE.
    INSERT ZSLPM_PROD_ATTR .
    ENDIF.
    READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
    IF SY-SUBRC EQ 0.
      <XACT> = ORIGINAL.
      MODIFY EXTRACT INDEX SY-TABIX.
    ENDIF.
    <ACTION> = ORIGINAL.
    MODIFY TOTAL.
  ENDCASE.
ENDLOOP.
CLEAR: STATUS_ZSLPMPRODATTRVW-UPD_FLAG,
STATUS_ZSLPMPRODATTRVW-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_ZSLPMPRODATTRVW.
  SELECT SINGLE * FROM ZSLPM_PROD_ATTR WHERE
ID = ZSLPMPRODATTRVW-ID .
ZSLPMPRODATTRVW-MANDT =
ZSLPM_PROD_ATTR-MANDT .
ZSLPMPRODATTRVW-ID =
ZSLPM_PROD_ATTR-ID .
ZSLPMPRODATTRVW-DESCRIPTION =
ZSLPM_PROD_ATTR-DESCRIPTION .
ZSLPMPRODATTRVW-SHOWPRIORITIES =
ZSLPM_PROD_ATTR-SHOWPRIORITIES .
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_ZSLPMPRODATTRVW USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE ZSLPMPRODATTRVW-ID TO
ZSLPM_PROD_ATTR-ID .
MOVE ZSLPMPRODATTRVW-MANDT TO
ZSLPM_PROD_ATTR-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = 'ZSLPM_PROD_ATTR'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN ZSLPM_PROD_ATTR TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING 'ZSLPM_PROD_ATTR'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
*...processing: ZSLPMSETUPVW....................................*
FORM GET_DATA_ZSLPMSETUPVW.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM ZSLPM_SETUP WHERE
(VIM_WHERETAB) .
    CLEAR ZSLPMSETUPVW .
ZSLPMSETUPVW-MANDT =
ZSLPM_SETUP-MANDT .
ZSLPMSETUPVW-PARAM =
ZSLPM_SETUP-PARAM .
ZSLPMSETUPVW-VALUE =
ZSLPM_SETUP-VALUE .
ZSLPMSETUPVW-DESCRIPTION =
ZSLPM_SETUP-DESCRIPTION .
<VIM_TOTAL_STRUC> = ZSLPMSETUPVW.
    APPEND TOTAL.
  ENDSELECT.
  SORT TOTAL BY <VIM_XTOTAL_KEY>.
  <STATUS>-ALR_SORTED = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF X_HEADER-SELECTION NE SPACE.
    PERFORM CHECK_DYNAMIC_SELECT_OPTIONS.
  ELSEIF X_HEADER-DELMDTFLAG NE SPACE.
    PERFORM BUILD_MAINKEY_TAB.
  ENDIF.
  REFRESH EXTRACT.
ENDFORM.
*---------------------------------------------------------------------*
FORM DB_UPD_ZSLPMSETUPVW .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO ZSLPMSETUPVW.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_ZSLPMSETUPVW-ST_DELETE EQ GELOESCHT.
     READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
     IF SY-SUBRC EQ 0.
       DELETE EXTRACT INDEX SY-TABIX.
     ENDIF.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN GELOESCHT.
  SELECT SINGLE FOR UPDATE * FROM ZSLPM_SETUP WHERE
  PARAM = ZSLPMSETUPVW-PARAM .
    IF SY-SUBRC = 0.
    DELETE ZSLPM_SETUP .
    ENDIF.
    IF STATUS-DELETE EQ GELOESCHT.
      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY> BINARY SEARCH.
      DELETE EXTRACT INDEX SY-TABIX.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN OTHERS.
  SELECT SINGLE FOR UPDATE * FROM ZSLPM_SETUP WHERE
  PARAM = ZSLPMSETUPVW-PARAM .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR ZSLPM_SETUP.
    ENDIF.
ZSLPM_SETUP-MANDT =
ZSLPMSETUPVW-MANDT .
ZSLPM_SETUP-PARAM =
ZSLPMSETUPVW-PARAM .
ZSLPM_SETUP-VALUE =
ZSLPMSETUPVW-VALUE .
ZSLPM_SETUP-DESCRIPTION =
ZSLPMSETUPVW-DESCRIPTION .
    IF SY-SUBRC = 0.
    UPDATE ZSLPM_SETUP ##WARN_OK.
    ELSE.
    INSERT ZSLPM_SETUP .
    ENDIF.
    READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
    IF SY-SUBRC EQ 0.
      <XACT> = ORIGINAL.
      MODIFY EXTRACT INDEX SY-TABIX.
    ENDIF.
    <ACTION> = ORIGINAL.
    MODIFY TOTAL.
  ENDCASE.
ENDLOOP.
CLEAR: STATUS_ZSLPMSETUPVW-UPD_FLAG,
STATUS_ZSLPMSETUPVW-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_ZSLPMSETUPVW.
  SELECT SINGLE * FROM ZSLPM_SETUP WHERE
PARAM = ZSLPMSETUPVW-PARAM .
ZSLPMSETUPVW-MANDT =
ZSLPM_SETUP-MANDT .
ZSLPMSETUPVW-PARAM =
ZSLPM_SETUP-PARAM .
ZSLPMSETUPVW-VALUE =
ZSLPM_SETUP-VALUE .
ZSLPMSETUPVW-DESCRIPTION =
ZSLPM_SETUP-DESCRIPTION .
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_ZSLPMSETUPVW USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE ZSLPMSETUPVW-PARAM TO
ZSLPM_SETUP-PARAM .
MOVE ZSLPMSETUPVW-MANDT TO
ZSLPM_SETUP-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = 'ZSLPM_SETUP'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN ZSLPM_SETUP TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING 'ZSLPM_SETUP'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
*...processing: ZSLPMSTATEMAILVW................................*
FORM GET_DATA_ZSLPMSTATEMAILVW.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM ZSLPM_STAT_EMAIL WHERE
(VIM_WHERETAB) .
    CLEAR ZSLPMSTATEMAILVW .
ZSLPMSTATEMAILVW-MANDT =
ZSLPM_STAT_EMAIL-MANDT .
ZSLPMSTATEMAILVW-RULE_ID =
ZSLPM_STAT_EMAIL-RULE_ID .
ZSLPMSTATEMAILVW-STATUSIN =
ZSLPM_STAT_EMAIL-STATUSIN .
ZSLPMSTATEMAILVW-STATUSOUT =
ZSLPM_STAT_EMAIL-STATUSOUT .
ZSLPMSTATEMAILVW-EMAILRULEREQ =
ZSLPM_STAT_EMAIL-EMAILRULEREQ .
ZSLPMSTATEMAILVW-EMAILRULESUP =
ZSLPM_STAT_EMAIL-EMAILRULESUP .
ZSLPMSTATEMAILVW-EMAILRULEPRO =
ZSLPM_STAT_EMAIL-EMAILRULEPRO .
ZSLPMSTATEMAILVW-EMAILRULEOBS =
ZSLPM_STAT_EMAIL-EMAILRULEOBS .
<VIM_TOTAL_STRUC> = ZSLPMSTATEMAILVW.
    APPEND TOTAL.
  ENDSELECT.
  SORT TOTAL BY <VIM_XTOTAL_KEY>.
  <STATUS>-ALR_SORTED = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF X_HEADER-SELECTION NE SPACE.
    PERFORM CHECK_DYNAMIC_SELECT_OPTIONS.
  ELSEIF X_HEADER-DELMDTFLAG NE SPACE.
    PERFORM BUILD_MAINKEY_TAB.
  ENDIF.
  REFRESH EXTRACT.
ENDFORM.
*---------------------------------------------------------------------*
FORM DB_UPD_ZSLPMSTATEMAILVW .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO ZSLPMSTATEMAILVW.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_ZSLPMSTATEMAILVW-ST_DELETE EQ GELOESCHT.
     READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
     IF SY-SUBRC EQ 0.
       DELETE EXTRACT INDEX SY-TABIX.
     ENDIF.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN GELOESCHT.
  SELECT SINGLE FOR UPDATE * FROM ZSLPM_STAT_EMAIL WHERE
  RULE_ID = ZSLPMSTATEMAILVW-RULE_ID .
    IF SY-SUBRC = 0.
    DELETE ZSLPM_STAT_EMAIL .
    ENDIF.
    IF STATUS-DELETE EQ GELOESCHT.
      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY> BINARY SEARCH.
      DELETE EXTRACT INDEX SY-TABIX.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN OTHERS.
  SELECT SINGLE FOR UPDATE * FROM ZSLPM_STAT_EMAIL WHERE
  RULE_ID = ZSLPMSTATEMAILVW-RULE_ID .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR ZSLPM_STAT_EMAIL.
    ENDIF.
ZSLPM_STAT_EMAIL-MANDT =
ZSLPMSTATEMAILVW-MANDT .
ZSLPM_STAT_EMAIL-RULE_ID =
ZSLPMSTATEMAILVW-RULE_ID .
ZSLPM_STAT_EMAIL-STATUSIN =
ZSLPMSTATEMAILVW-STATUSIN .
ZSLPM_STAT_EMAIL-STATUSOUT =
ZSLPMSTATEMAILVW-STATUSOUT .
ZSLPM_STAT_EMAIL-EMAILRULEREQ =
ZSLPMSTATEMAILVW-EMAILRULEREQ .
ZSLPM_STAT_EMAIL-EMAILRULESUP =
ZSLPMSTATEMAILVW-EMAILRULESUP .
ZSLPM_STAT_EMAIL-EMAILRULEPRO =
ZSLPMSTATEMAILVW-EMAILRULEPRO .
ZSLPM_STAT_EMAIL-EMAILRULEOBS =
ZSLPMSTATEMAILVW-EMAILRULEOBS .
    IF SY-SUBRC = 0.
    UPDATE ZSLPM_STAT_EMAIL ##WARN_OK.
    ELSE.
    INSERT ZSLPM_STAT_EMAIL .
    ENDIF.
    READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
    IF SY-SUBRC EQ 0.
      <XACT> = ORIGINAL.
      MODIFY EXTRACT INDEX SY-TABIX.
    ENDIF.
    <ACTION> = ORIGINAL.
    MODIFY TOTAL.
  ENDCASE.
ENDLOOP.
CLEAR: STATUS_ZSLPMSTATEMAILVW-UPD_FLAG,
STATUS_ZSLPMSTATEMAILVW-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_ZSLPMSTATEMAILVW.
  SELECT SINGLE * FROM ZSLPM_STAT_EMAIL WHERE
RULE_ID = ZSLPMSTATEMAILVW-RULE_ID .
ZSLPMSTATEMAILVW-MANDT =
ZSLPM_STAT_EMAIL-MANDT .
ZSLPMSTATEMAILVW-RULE_ID =
ZSLPM_STAT_EMAIL-RULE_ID .
ZSLPMSTATEMAILVW-STATUSIN =
ZSLPM_STAT_EMAIL-STATUSIN .
ZSLPMSTATEMAILVW-STATUSOUT =
ZSLPM_STAT_EMAIL-STATUSOUT .
ZSLPMSTATEMAILVW-EMAILRULEREQ =
ZSLPM_STAT_EMAIL-EMAILRULEREQ .
ZSLPMSTATEMAILVW-EMAILRULESUP =
ZSLPM_STAT_EMAIL-EMAILRULESUP .
ZSLPMSTATEMAILVW-EMAILRULEPRO =
ZSLPM_STAT_EMAIL-EMAILRULEPRO .
ZSLPMSTATEMAILVW-EMAILRULEOBS =
ZSLPM_STAT_EMAIL-EMAILRULEOBS .
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_ZSLPMSTATEMAILVW USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE ZSLPMSTATEMAILVW-RULE_ID TO
ZSLPM_STAT_EMAIL-RULE_ID .
MOVE ZSLPMSTATEMAILVW-MANDT TO
ZSLPM_STAT_EMAIL-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = 'ZSLPM_STAT_EMAIL'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN ZSLPM_STAT_EMAIL TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING 'ZSLPM_STAT_EMAIL'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
*...processing: ZSLPMSTATFLOWVW.................................*
FORM GET_DATA_ZSLPMSTATFLOWVW.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM ZSLPM_STAT_FLOW WHERE
(VIM_WHERETAB) .
    CLEAR ZSLPMSTATFLOWVW .
ZSLPMSTATFLOWVW-MANDT =
ZSLPM_STAT_FLOW-MANDT .
ZSLPMSTATFLOWVW-STSMA =
ZSLPM_STAT_FLOW-STSMA .
ZSLPMSTATFLOWVW-STATUS =
ZSLPM_STAT_FLOW-STATUS .
ZSLPMSTATFLOWVW-STATUSLIST =
ZSLPM_STAT_FLOW-STATUSLIST .
<VIM_TOTAL_STRUC> = ZSLPMSTATFLOWVW.
    APPEND TOTAL.
  ENDSELECT.
  SORT TOTAL BY <VIM_XTOTAL_KEY>.
  <STATUS>-ALR_SORTED = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF X_HEADER-SELECTION NE SPACE.
    PERFORM CHECK_DYNAMIC_SELECT_OPTIONS.
  ELSEIF X_HEADER-DELMDTFLAG NE SPACE.
    PERFORM BUILD_MAINKEY_TAB.
  ENDIF.
  REFRESH EXTRACT.
ENDFORM.
*---------------------------------------------------------------------*
FORM DB_UPD_ZSLPMSTATFLOWVW .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO ZSLPMSTATFLOWVW.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_ZSLPMSTATFLOWVW-ST_DELETE EQ GELOESCHT.
     READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
     IF SY-SUBRC EQ 0.
       DELETE EXTRACT INDEX SY-TABIX.
     ENDIF.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN GELOESCHT.
  SELECT SINGLE FOR UPDATE * FROM ZSLPM_STAT_FLOW WHERE
  STSMA = ZSLPMSTATFLOWVW-STSMA AND
  STATUS = ZSLPMSTATFLOWVW-STATUS .
    IF SY-SUBRC = 0.
    DELETE ZSLPM_STAT_FLOW .
    ENDIF.
    IF STATUS-DELETE EQ GELOESCHT.
      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY> BINARY SEARCH.
      DELETE EXTRACT INDEX SY-TABIX.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN OTHERS.
  SELECT SINGLE FOR UPDATE * FROM ZSLPM_STAT_FLOW WHERE
  STSMA = ZSLPMSTATFLOWVW-STSMA AND
  STATUS = ZSLPMSTATFLOWVW-STATUS .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR ZSLPM_STAT_FLOW.
    ENDIF.
ZSLPM_STAT_FLOW-MANDT =
ZSLPMSTATFLOWVW-MANDT .
ZSLPM_STAT_FLOW-STSMA =
ZSLPMSTATFLOWVW-STSMA .
ZSLPM_STAT_FLOW-STATUS =
ZSLPMSTATFLOWVW-STATUS .
ZSLPM_STAT_FLOW-STATUSLIST =
ZSLPMSTATFLOWVW-STATUSLIST .
    IF SY-SUBRC = 0.
    UPDATE ZSLPM_STAT_FLOW ##WARN_OK.
    ELSE.
    INSERT ZSLPM_STAT_FLOW .
    ENDIF.
    READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
    IF SY-SUBRC EQ 0.
      <XACT> = ORIGINAL.
      MODIFY EXTRACT INDEX SY-TABIX.
    ENDIF.
    <ACTION> = ORIGINAL.
    MODIFY TOTAL.
  ENDCASE.
ENDLOOP.
CLEAR: STATUS_ZSLPMSTATFLOWVW-UPD_FLAG,
STATUS_ZSLPMSTATFLOWVW-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_ZSLPMSTATFLOWVW.
  SELECT SINGLE * FROM ZSLPM_STAT_FLOW WHERE
STSMA = ZSLPMSTATFLOWVW-STSMA AND
STATUS = ZSLPMSTATFLOWVW-STATUS .
ZSLPMSTATFLOWVW-MANDT =
ZSLPM_STAT_FLOW-MANDT .
ZSLPMSTATFLOWVW-STSMA =
ZSLPM_STAT_FLOW-STSMA .
ZSLPMSTATFLOWVW-STATUS =
ZSLPM_STAT_FLOW-STATUS .
ZSLPMSTATFLOWVW-STATUSLIST =
ZSLPM_STAT_FLOW-STATUSLIST .
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_ZSLPMSTATFLOWVW USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE ZSLPMSTATFLOWVW-STSMA TO
ZSLPM_STAT_FLOW-STSMA .
MOVE ZSLPMSTATFLOWVW-STATUS TO
ZSLPM_STAT_FLOW-STATUS .
MOVE ZSLPMSTATFLOWVW-MANDT TO
ZSLPM_STAT_FLOW-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = 'ZSLPM_STAT_FLOW'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN ZSLPM_STAT_FLOW TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING 'ZSLPM_STAT_FLOW'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
