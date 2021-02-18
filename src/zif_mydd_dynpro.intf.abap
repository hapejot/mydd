interface ZIF_MYDD_DYNPRO
  public .


  methods SET_STATUS .
  methods PROCESS_AFTER_INPUT
    importing
      !UCOMM type SYST_UCOMM .
  methods PROCESS_BEFORE_OUTPUT .
endinterface.
