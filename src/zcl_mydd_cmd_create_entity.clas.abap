class ZCL_MYDD_CMD_CREATE_ENTITY definition
  public
  final
  create public .

public section.

  interfaces ZIF_MYDD_CMDDEFINITION .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MYDD_CMD_CREATE_ENTITY IMPLEMENTATION.


  METHOD ZIF_MYDD_CMDDEFINITION~CODE.
    code = 'CR_ENTITY'.
  ENDMETHOD.


  METHOD ZIF_MYDD_CMDDEFINITION~EXEC.

  ENDMETHOD.


  METHOD ZIF_MYDD_CMDDEFINITION~NAME.
    name = 'Entity'(001).
  ENDMETHOD.
ENDCLASS.
