CLASS zcl_mydd_cmd_ctx_command DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_mydd_command .

    METHODS constructor
      IMPORTING
        !i_ucomm   TYPE syst_ucomm
        !i_context TYPE REF TO object .
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA m_ucomm TYPE syst_ucomm.
    DATA m_ctx TYPE REF TO object.
    DATA m_def TYPE REF TO zif_mydd_cmddefinition.
ENDCLASS.



CLASS ZCL_MYDD_CMD_CTX_COMMAND IMPLEMENTATION.


  METHOD constructor.

    m_ucomm = i_ucomm.
    m_ctx = i_context.

  ENDMETHOD.


  METHOD zif_mydd_command~def.
    IF i_def IS SUPPLIED.
      m_def = i_def.
    ELSE.
      result = m_def.
    ENDIF.
  ENDMETHOD.


  METHOD zif_mydd_command~exec.
    m_def->exec( cmd = me ).
  ENDMETHOD.


  METHOD zif_mydd_command~ucomm.
    IF i_ucomm IS SUPPLIED.
      m_ucomm = i_ucomm.
    ENDIF.
    result = m_ucomm.
  ENDMETHOD.
ENDCLASS.
