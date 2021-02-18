CLASS zcl_mydd_cmddefinition DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_mydd_cmddefinition.
    CLASS-METHODS:
      defintion_for IMPORTING ucomm TYPE syst_ucomm RETURNING VALUE(def) TYPE REF TO zif_mydd_cmddefinition,
      register
        IMPORTING ucomm TYPE syst_ucomm
                  obj   TYPE REF TO zif_mydd_cmddefinition.
    METHODS constructor
      IMPORTING
        ucomm TYPE syst_ucomm.
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES: BEGIN OF ts_config,
             ucomm     TYPE syst_ucomm,
             classname TYPE seoclname,
           END OF ts_config.
    TYPES: BEGIN OF ts_assoc_row,
             ucomm TYPE syst_ucomm,
             def   TYPE REF TO zif_mydd_cmddefinition,
           END OF ts_assoc_row.
    CLASS-DATA m_assoc_table TYPE HASHED TABLE OF ts_assoc_row WITH UNIQUE KEY ucomm.
    CLASS-DATA m_configuration TYPE HASHED TABLE OF ts_config WITH UNIQUE KEY ucomm.
    DATA m_ucomm TYPE syst_ucomm.
ENDCLASS.



CLASS zcl_mydd_cmddefinition IMPLEMENTATION.


  METHOD constructor.

    me->m_ucomm = ucomm.

  ENDMETHOD.


  METHOD defintion_for.
    def = VALUE #( m_assoc_table[ ucomm = ucomm ]-def OPTIONAL ).
    IF def IS INITIAL.
      DATA(clsname) = VALUE #( m_configuration[ ucomm = ucomm ]-classname OPTIONAL ).
      IF clsname IS INITIAL.
        def = NEW zcl_mydd_cmddefinition( ucomm = ucomm  ).
      ELSE.
        CREATE OBJECT def TYPE (clsname).
      ENDIF.
      INSERT VALUE #( ucomm = ucomm def = def ) INTO TABLE m_assoc_table.
    ENDIF.
  ENDMETHOD.


  METHOD register.
    INSERT VALUE #( ucomm = ucomm def = obj ) INTO TABLE m_assoc_table.
  ENDMETHOD.


  METHOD zif_mydd_cmddefinition~code.
    code = m_ucomm.
  ENDMETHOD.

  METHOD zif_mydd_cmddefinition~name.
    name = m_ucomm.
  ENDMETHOD.

ENDCLASS.
