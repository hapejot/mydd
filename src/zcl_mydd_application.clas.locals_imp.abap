CLASS tree_view IMPLEMENTATION.

  METHOD create.

    CREATE OBJECT r_result.

    r_result->m_cont = i_cont.
    r_result->m_screens = i_screens.

  ENDMETHOD.


  METHOD init_view.
    DATA: lt_events TYPE cntl_simple_events,
          m_control TYPE REF TO cl_gui_control.
    CREATE OBJECT m_tree
      EXPORTING
        node_selection_mode         = cl_list_tree_model=>node_sel_mode_single   " Nodes: Single or Multiple Selection
        item_selection              = abap_false    " Can Individual Items be Selected?
        with_headers                = abap_false   " 'X': With Headers
      EXCEPTIONS
        illegal_node_selection_mode = 1
        OTHERS                      = 2.
    m_tree->create_tree_control(
      EXPORTING
        parent                       = m_cont
      IMPORTING
        control                      = m_control
      EXCEPTIONS
        OTHERS                       = 6
    ).

    m_data->read_overview( ).
    DATA(root_key) = build_tree( i_node = root_node(  ) ).

    lt_events = VALUE #(
            ( eventid = cl_list_tree_model=>eventid_selection_changed       appl_event = 'X' )
*            ( eventid = cl_list_tree_model=>eventid_item_context_menu_req   appl_event = 'X' )
            ( eventid = cl_list_tree_model=>eventid_node_context_menu_req   appl_event = 'X' )
*            ( eventid = cl_list_tree_model=>eventid_item_double_click       appl_event = 'X' )
*            ( eventid = cl_list_tree_model=>eventid_node_double_click       appl_event = 'X' )
        ).
    CALL METHOD m_tree->set_registered_events
      EXPORTING
        events                    = lt_events
      EXCEPTIONS
        illegal_event_combination = 1
        unknown_event             = 2.
    IF sy-subrc <> 0.
      MESSAGE 'error during event registration' TYPE 'I'.
    ENDIF.
    SET HANDLER handle_node_context_menu_req    FOR m_tree.
    SET HANDLER handle_node_context_menu_sel    FOR m_tree.
    SET HANDLER on_expand_no_children           FOR m_tree.
    SET HANDLER on_sel                          FOR m_tree.
    SET HANDLER on_double_click                 FOR m_tree.

    m_tree->expand_node(
      EXPORTING
        node_key            = root_key
      EXCEPTIONS
        node_not_found      = 1
        OTHERS              = 2
    ).
    IF sy-subrc <> 0.
*     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDMETHOD.

  METHOD build_tree.

    new_nodekey = |{ i_below }/{ i_node->name( ) }|.
    set_node(   i_below = i_below
                i_nodekey = new_nodekey
                i_node = i_node ).
    LOOP AT i_node->children(  ) INTO DATA(child).
      build_tree( i_below = new_nodekey  i_node = child ).
    ENDLOOP.

  ENDMETHOD.

  METHOD set_node.

    IF m_tree->node_key_in_tree( node_key = i_nodekey ).
      CALL METHOD m_tree->update_items
        EXPORTING
          item_table = i_node->items( )    " Items of Node
        EXCEPTIONS
          OTHERS     = 2.
    ELSE.
      CALL METHOD m_tree->add_node
        EXPORTING
          node_key          = i_nodekey    " Node key
          relative_node_key = i_below
          relationship      = cl_tree_model=>relat_last_child
          isfolder          = boolc( NOT i_node->leaf( ) )  " "
          item_table        = CORRESPONDING #( i_node->items( ) )    " Items of Node
        EXCEPTIONS
          OTHERS            = 6.
    ENDIF.

    m_tree->node_set_user_object(
      EXPORTING
        node_key       = i_nodekey
        user_object    = i_node
      EXCEPTIONS
        node_not_found = 1
        OTHERS         = 2
    ).
    IF sy-subrc <> 0.
*     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDMETHOD.

  METHOD handle_node_context_menu_req.

    menu->add_function(
      EXPORTING
        fcode             = 'A'    " Function code
        text              =  CONV #( node_key )   " Function text
    ).

  ENDMETHOD.

  METHOD handle_node_context_menu_sel.

  ENDMETHOD.

  METHOD on_double_click.

  ENDMETHOD.

  METHOD on_expand_no_children.

  ENDMETHOD.

  METHOD on_sel.
    DATA: user_object TYPE REF TO object.
    MESSAGE node_key TYPE 'S'.

    m_tree->node_get_user_object(
      EXPORTING
        node_key       = node_key
      IMPORTING
        user_object    =  user_object
      EXCEPTIONS
        node_not_found = 1
        OTHERS         = 2
    ).
    IF sy-subrc = 0.
      IF current_node IS BOUND.
        current_node->leave_form(  ).
        CLEAR current_node.
      ENDIF.
      current_node = CAST node( user_object ).
      current_node->show_details( ).
    ENDIF.
  ENDMETHOD.

  METHOD root_node.
    rv_node = NEW root_node( me ).
  ENDMETHOD.


  METHOD project_nodes.

    LOOP AT m_data->projects( ) INTO DATA(project).
      APPEND NEW project_node( i_key = VALUE #( project = project-id  )  i_view = me ) TO  r_result.
    ENDLOOP.

  ENDMETHOD.


  METHOD set_data.
    m_data = i_dataset.
  ENDMETHOD.


  METHOD data.
    r_dataset = m_data.
  ENDMETHOD.


  METHOD call_screen.
    m_screens->call_screen(
      EXPORTING
        i_datasection = i_datasection
        i_data        = i_data
        i_screen      = i_screen
    ).
  ENDMETHOD.

  METHOD zif_screens~pull_values.


  ENDMETHOD.

ENDCLASS.

CLASS dataset IMPLEMENTATION.

  METHOD create.

    CREATE OBJECT r_result.

  ENDMETHOD.

  METHOD projects.
    r_projects = m_projects.
  ENDMETHOD.

  METHOD read_overview.
    SELECT * FROM zxrm_project
            INTO TABLE @m_projects.
  ENDMETHOD.

  METHOD project.
    r_row = m_projects[ id = i_project ].
  ENDMETHOD.

ENDCLASS.

CLASS root_node IMPLEMENTATION.

  METHOD constructor.
    super->constructor(  ).
    me->m_view = i_view.

  ENDMETHOD.

  METHOD items.

    APPEND VALUE #(
        item_name   = '1'
        class       = cl_list_tree_model=>item_class_text " Text Item
        alignment   = cl_list_tree_model=>align_auto
        font        = cl_list_tree_model=>item_font_fixed
        style       = cl_list_tree_model=>style_default
        text        = |Root|
    ) TO lt_items.

  ENDMETHOD.


  METHOD name.
    r_result = 'ROOT'.
  ENDMETHOD.


  METHOD leaf.
    r_result = abap_false.
  ENDMETHOD.

  METHOD children.
    r_nodes = m_view->project_nodes(  ).
  ENDMETHOD.

  METHOD show_details.

  ENDMETHOD.

ENDCLASS.

CLASS project_node IMPLEMENTATION.

  METHOD constructor.
    super->constructor( ).
    me->m_key = i_key.
    me->m_view = i_view.

  ENDMETHOD.

  METHOD children.

  ENDMETHOD.

  METHOD items.
    DATA(project) = m_view->data(  )->project( m_key-project ).
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

  METHOD name.
    r_result = |{ m_key-project }|.
  ENDMETHOD.

  METHOD leaf.
    r_result = abap_false.
  ENDMETHOD.
  METHOD add_text_item.

    DATA(lo_type) = CAST cl_abap_elemdescr( cl_abap_typedescr=>describe_by_data( p_data = iv_text ) ).

    APPEND VALUE #( item_name  = VALUE #(  )
                    class      = cl_item_tree_model=>item_class_text
                    font        = cl_item_tree_model=>item_font_prop
                    text       = iv_text
                    length     = lo_type->output_length ) TO ct_items.


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


  METHOD show_details.
    m_view->call_screen(
      EXPORTING
        i_datasection = 'PROJECT'
        i_data        = m_view->data(  )->project( m_key-project )
        i_screen      = '0001'
    ).
  ENDMETHOD.

ENDCLASS.

CLASS node_base IMPLEMENTATION.

  METHOD node~children.

  ENDMETHOD.

  METHOD node~items.

  ENDMETHOD.

  METHOD node~name.

  ENDMETHOD.

  METHOD node~leaf.

  ENDMETHOD.

  METHOD node~show_details.

  ENDMETHOD.

  METHOD node~leave_form.

  ENDMETHOD.

ENDCLASS.
