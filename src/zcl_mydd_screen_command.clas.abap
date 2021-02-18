CLASS zcl_mydd_screen_command DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_mydd_command.
    ALIASES: ucomm FOR zif_mydd_command~ucomm.
    METHODS constructor
      IMPORTING
        i_ucomm TYPE syst_ucomm.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA m_ucomm TYPE syst_ucomm.
    DATA m_def TYPE REF TO zif_mydd_cmddefinition.
ENDCLASS.



CLASS zcl_mydd_screen_command IMPLEMENTATION.


  METHOD constructor.

    me->m_ucomm = i_ucomm.

  ENDMETHOD.


  METHOD zif_mydd_command~ucomm.
    IF i_ucomm IS SUPPLIED.
      m_ucomm = i_ucomm.
    ENDIF.
    result = m_ucomm.
  ENDMETHOD.

  METHOD zif_mydd_command~def.
    IF i_def IS SUPPLIED.
      m_def = i_def.
    ELSE.
      result = m_def.
    ENDIF.
  ENDMETHOD.

  METHOD zif_mydd_command~exec.
  ENDMETHOD.

ENDCLASS.
