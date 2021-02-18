interface ZIF_MYDD_COMMAND
  public .


  methods EXEC
    returning
      value(DONE) type ABAP_BOOL .
  methods UCOMM
    importing
      !I_UCOMM type SYST_UCOMM optional
    returning
      value(RESULT) type SYST_UCOMM .
  methods DEF
    importing
      !I_DEF type ref to ZIF_MYDD_CMDDEFINITION optional
    returning
      value(RESULT) type ref to ZIF_MYDD_CMDDEFINITION .
endinterface.
