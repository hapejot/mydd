*&---------------------------------------------------------------------*
*& Report YRS_BC_MYDD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT yrs_bc_mydd.
DATA: go_app TYPE REF TO zcl_mydd_application.
DATA current_screen TYPE dynnr VALUE 9999.
DATA: BEGIN OF gd,
        project TYPE zxrm_project,
      END OF gd.
CLASS lcl_screens DEFINITION.
  PUBLIC SECTION.
    INTERFACES zif_screens.
ENDCLASS.

CLASS lcl_screens IMPLEMENTATION.

  METHOD zif_screens~call_screen.
    current_screen = i_screen.
    cl_gui_cfw=>update_view( ).
    ASSIGN COMPONENT i_datasection OF STRUCTURE gd TO FIELD-SYMBOL(<section>).
    MOVE-CORRESPONDING i_data TO <section>.


  ENDMETHOD.

  METHOD zif_screens~pull_values.

    ASSIGN COMPONENT i_datasection OF STRUCTURE gd TO FIELD-SYMBOL(<section>).
    MOVE-CORRESPONDING <section> TO c_data.

  ENDMETHOD.

ENDCLASS.


INITIALIZATION.
  CALL SCREEN 1.

AT SELECTION-SCREEN.
  MESSAGE |UCOMM:{ sy-ucomm }| TYPE 'S'.
*&---------------------------------------------------------------------*
*& Module STATUS OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  SET TITLEBAR 'TITLE'.
  IF go_app IS INITIAL.
    CREATE OBJECT go_app.
    go_app->init_view( NEW lcl_screens(  )  ).
  ENDIF.
  go_app->tree( )->set_status(  ).
ENDMODULE.

MODULE main_pbo OUTPUT.
  go_app->tree( )->process_before_output( ).
ENDMODULE.

MODULE main_pai.
  go_app->tree( )->process_after_input( sy-ucomm ).
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command INPUT.
  CALL METHOD go_app->user_command EXPORTING ucomm = sy-ucomm.
ENDMODULE.
