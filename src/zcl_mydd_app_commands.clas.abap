CLASS zcl_mydd_app_commands DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.
    CLASS-METHODS instance
      RETURNING
        VALUE(r_result) TYPE REF TO zcl_mydd_app_commands.
    METHODS command
      IMPORTING
        i_ucomm    TYPE syst_ucomm
      RETURNING
        VALUE(cmd) TYPE REF TO zif_mydd_cmddefinition.
    METHODS constructor.
    METHODS defintion_for
      IMPORTING
        ucomm      TYPE syst_ucomm
      RETURNING
        VALUE(def) TYPE REF TO zif_mydd_cmddefinition.
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
    DATA m_cmds TYPE HASHED TABLE OF ts_assoc_row WITH UNIQUE KEY ucomm.

    CLASS-DATA m_instance TYPE REF TO zcl_mydd_app_commands.
ENDCLASS.



CLASS zcl_mydd_app_commands IMPLEMENTATION.
  METHOD constructor.
    defintion_for( 'SAVE' ).
    defintion_for( 'BACK' ).
    defintion_for( 'RETURN' ).
  ENDMETHOD.

  METHOD defintion_for.
    def = VALUE #( m_cmds[ ucomm = ucomm ]-def OPTIONAL ).
    IF def IS INITIAL.
*      DATA(clsname) = VALUE #( m_configuration[ ucomm = ucomm ]-classname OPTIONAL ).
*      IF clsname IS INITIAL.
      def = NEW zcl_mydd_cmddefinition( ucomm = ucomm  ).
*      ELSE.
*        CREATE OBJECT def TYPE (clsname).
*      ENDIF.
      INSERT VALUE #( ucomm = ucomm def = def ) INTO TABLE m_cmds.
    ENDIF.
  ENDMETHOD.


  METHOD command.
    cmd = defintion_for( i_ucomm ).
  ENDMETHOD.

  METHOD instance.
    IF m_instance IS INITIAL.
      CREATE OBJECT m_instance.
    ENDIF.
    r_result = m_instance.
  ENDMETHOD.

ENDCLASS.
