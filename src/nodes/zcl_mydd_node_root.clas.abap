CLASS zcl_mydd_node_root DEFINITION
INHERITING FROM zcl_mydd_node_base
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING
          i_view TYPE REF TO zcl_mydd_view,
      ZIF_MYDD_NODE~items REDEFINITION,
      ZIF_MYDD_NODE~name REDEFINITION,
      ZIF_MYDD_NODE~leaf REDEFINITION,
      ZIF_MYDD_NODE~children REDEFINITION.

  PRIVATE SECTION.
    DATA: m_view TYPE REF TO zcl_mydd_view.
ENDCLASS.



CLASS zcl_mydd_node_root IMPLEMENTATION.
  METHOD constructor.
    super->constructor(  ).
    me->m_view = i_view.

  ENDMETHOD.

  METHOD ZIF_MYDD_NODE~items.

    APPEND VALUE #(
        item_name   = '1'
        class       = cl_list_tree_model=>item_class_text " Text Item
        alignment   = cl_list_tree_model=>align_auto
        font        = cl_list_tree_model=>item_font_fixed
        style       = cl_list_tree_model=>style_default
        text        = |Root|
    ) TO lt_items.

  ENDMETHOD.


  METHOD ZIF_MYDD_NODE~name.
    r_result = 'ROOT'.
  ENDMETHOD.


  METHOD ZIF_MYDD_NODE~leaf.
    r_result = abap_false.
  ENDMETHOD.

  METHOD ZIF_MYDD_NODE~children.
    r_nodes = m_view->project_nodes(  ).
  ENDMETHOD.

ENDCLASS.
