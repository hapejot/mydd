CLASS zcl_mydd_application DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  TYPE-POOLS: icon.
  PUBLIC SECTION.
    METHODS init_view IMPORTING
                        i_screens TYPE REF TO zif_screens.
    METHODS user_command
      IMPORTING
        ucomm TYPE syst-ucomm.
    METHODS tree RETURNING VALUE(tree) TYPE REF TO zif_mydd_dynpro.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA mo_tree_cont TYPE REF TO cl_gui_container.
    DATA m_view TYPE REF TO zcl_mydd_view.
    DATA m_dataset TYPE REF TO zif_mydd_dataset.
ENDCLASS.



CLASS zcl_mydd_application IMPLEMENTATION.

  METHOD init_view.
    mo_tree_cont = NEW cl_gui_docking_container(
        side  = cl_gui_docking_container=>dock_at_left
        extension = 500
    ).
    m_dataset = zcl_mydd_dataset=>create(  ).
    zcl_mydd_cmddefinition=>register(   ucomm = 'SAVE'
                                        obj   = NEW zcl_mydd_cmd_save( i_dataset = m_dataset )   ).
    m_view = zcl_mydd_view=>create( i_cont = mo_tree_cont
                                i_screens = i_screens ).

    m_view->set_data( m_dataset ).
    m_view->init_view(  ).

  ENDMETHOD.


  METHOD user_command.
    RAISE EXCEPTION TYPE zcx_bc_not_implemented.
  ENDMETHOD.


  METHOD tree.
    tree = m_view.
  ENDMETHOD.

ENDCLASS.
