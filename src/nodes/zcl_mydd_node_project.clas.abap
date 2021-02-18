CLASS zcl_mydd_node_project DEFINITION
  PUBLIC
  INHERITING FROM zcl_mydd_node_base
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_mydd_active_component .
    CLASS-METHODS class_constructor.

    METHODS constructor
      IMPORTING
        !i_key  TYPE zrowid
        !i_view TYPE REF TO zcl_mydd_view .

    METHODS zif_mydd_node~enter_form
        REDEFINITION .
    METHODS zif_mydd_node~items
        REDEFINITION .
    METHODS zif_mydd_node~leaf
        REDEFINITION .
    METHODS zif_mydd_node~leave_form
        REDEFINITION .
    METHODS zif_mydd_node~name
        REDEFINITION .
  PRIVATE SECTION.
    DATA:m_key  TYPE zrowid,
         m_view TYPE REF TO zcl_mydd_view.
    CLASS-DATA m_cmds TYPE zif_mydd_active_component=>tt_cmd_defs.
    METHODS add_text_item
      IMPORTING
        iv_text  TYPE any
      CHANGING
        ct_items TYPE treemlitad .
    METHODS renumber_item_ids
      CHANGING
        ct_items TYPE treemlitad .
ENDCLASS.



CLASS ZCL_MYDD_NODE_PROJECT IMPLEMENTATION.


  METHOD add_text_item.
    DATA(lo_type) = CAST cl_abap_elemdescr( cl_abap_typedescr=>describe_by_data( p_data = iv_text ) ).

    APPEND VALUE #( item_name  = VALUE #(  )
                    class      = cl_item_tree_model=>item_class_text
                    font       = cl_item_tree_model=>item_font_prop
                    text       = iv_text
                    length     = lo_type->output_length ) TO ct_items.
  ENDMETHOD.


  METHOD class_constructor.
    DATA(cmds) = zcl_mydd_app_commands=>instance(  ).
    m_cmds = VALUE #(
                    (  cmds->defintion_for( 'NEW ENTITY' ) )
      ).
  ENDMETHOD.


  METHOD constructor.
    super->constructor( ).
    me->m_key = i_key.
    me->m_view = i_view.

  ENDMETHOD.


  METHOD renumber_item_ids.

    DATA lv_count TYPE i.
    DATA lv_name TYPE tv_itmname.
    LOOP AT ct_items REFERENCE INTO DATA(lr_item).
      IF lr_item->item_name = space.
        ADD 1 TO lv_count.
        lr_item->item_name = |{ lv_count ALIGN = LEFT }|.
      ENDIF.
      lv_count = lr_item->item_name.
    ENDLOOP.

  ENDMETHOD.


  METHOD zif_mydd_active_component~available_cmds.
    cmds = m_cmds.
  ENDMETHOD.


  METHOD zif_mydd_active_component~process_cmd.

    MESSAGE |running command { cmd->code(  ) } on project node.| TYPE 'I'.
    CASE cmd->code( ).
      WHEN 'NEW ENTITY'.
m_view->data( )->entities( ).
    ENDCASE.
  ENDMETHOD.


  METHOD zif_mydd_active_component~respondes_to.
  ENDMETHOD.


  METHOD zif_mydd_node~enter_form.
    m_view->call_screen(
      EXPORTING
        i_datasection = 'PROJECT'
        i_data        = m_view->data(  )->project( m_key )
        i_screen      = '0002'
    ).
  ENDMETHOD.


  METHOD zif_mydd_node~items.
    DATA(project) = m_view->data(  )->project( m_key ).
    CALL METHOD add_text_item
      EXPORTING
        iv_text  = project-name
      CHANGING
        ct_items = lt_items.
    renumber_item_ids(
      CHANGING
        ct_items = lt_items
    ).
  ENDMETHOD.


  METHOD zif_mydd_node~leaf.
    r_result = abap_false.
  ENDMETHOD.


  METHOD zif_mydd_node~leave_form.
    DATA ls_data TYPE zxrm_project.
    m_view->pull_values(    EXPORTING   i_datasection = 'PROJECT'
                            CHANGING    c_data = ls_data  ).
    m_view->data(  )->set_project( ls_data ).
  ENDMETHOD.


  METHOD zif_mydd_node~name.
    r_result = |{ m_key }|.
  ENDMETHOD.
ENDCLASS.
