interface ZIF_SCREENS
  public .


  methods CALL_SCREEN
    importing
      !I_DATASECTION type STRING
      !I_DATA type ANY
      !I_SCREEN type DYNNR .
  methods PULL_VALUES
    importing
      !I_DATASECTION type STRING
    changing
      !C_DATA type ZXRM_PROJECT .
endinterface.
