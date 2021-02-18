CLASS zcl_mydd_view DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_screens .
    INTERFACES zif_mydd_dynpro .
    INTERFACES zif_mydd_active_component .

    ALIASES call_screen
      FOR zif_screens~call_screen .
    ALIASES pai
      FOR zif_mydd_dynpro~process_after_input .
    ALIASES pbo
      FOR zif_mydd_dynpro~process_before_output .
    ALIASES pull_values
      FOR zif_screens~pull_values .
    ALIASES set_status
      FOR zif_mydd_dynpro~set_status .

    CLASS-METHODS create
      IMPORTING
        !i_cont         TYPE REF TO cl_gui_container
        !i_screens      TYPE REF TO zif_screens
      RETURNING
        VALUE(r_result) TYPE REF TO zcl_mydd_view .
    METHODS constructor .
    METHODS data
      RETURNING
        VALUE(r_dataset) TYPE REF TO zif_mydd_dataset .
    METHODS init_view .
    METHODS project_nodes
      RETURNING
        VALUE(r_result) TYPE zmydd_nodes .
    METHODS responds_to
      IMPORTING
        !ucomm          TYPE syst_ucomm
      RETURNING
        VALUE(r_result) TYPE abap_bool .
    METHODS set_data
      IMPORTING
        !i_dataset TYPE REF TO zif_mydd_dataset .
  PRIVATE SECTION.

    ALIASES available_cmds
      FOR zif_mydd_active_component~available_cmds .
    ALIASES process_cmd
      FOR zif_mydd_active_component~process_cmd .
    ALIASES respondes_to
      FOR zif_mydd_active_component~respondes_to .

    DATA current_node TYPE REF TO zif_mydd_node .
    DATA current_node_key TYPE tm_nodekey .
    DATA m_cont TYPE REF TO cl_gui_container .
    DATA m_control TYPE REF TO cl_gui_control .
    DATA m_data TYPE REF TO zif_mydd_dataset .
    DATA m_dd_id TYPE i .
    DATA m_root TYPE REF TO zif_mydd_node .
    DATA m_screens TYPE REF TO zif_screens .
    DATA m_tree TYPE REF TO cl_list_tree_model .

    METHODS build_tree
      IMPORTING
        !i_below           TYPE tm_nodekey OPTIONAL
        !i_node            TYPE REF TO zif_mydd_node
      RETURNING
        VALUE(new_nodekey) TYPE tm_nodekey .
    METHODS handle_node_context_menu_req
          FOR EVENT node_context_menu_request OF cl_list_tree_model
      IMPORTING
          !node_key
          !menu .
    METHODS handle_node_context_menu_sel
          FOR EVENT node_context_menu_select OF cl_list_tree_model
      IMPORTING
          !node_key
          !fcode .
    METHODS node_for_key
      IMPORTING
        !i_key      TYPE tm_nodekey
      EXPORTING
        !e_node     TYPE REF TO zif_mydd_node
      RETURNING
        VALUE(r_ok) TYPE abap_bool .
    METHODS on_double_click
        FOR EVENT node_double_click OF cl_list_tree_model .
    METHODS on_drag
          FOR EVENT drag OF cl_list_tree_model
      IMPORTING
          !node_key
          !item_name
          !drag_drop_object .
    METHODS on_drop
          FOR EVENT drop OF cl_list_tree_model
      IMPORTING
          !node_key
          !drag_drop_object .
    METHODS on_drop_complete
        FOR EVENT drop_complete OF cl_list_tree_model .
    METHODS on_expand_no_children
          FOR EVENT expand_no_children OF cl_list_tree_model
      IMPORTING
          !node_key
          !sender .
    METHODS on_sel
          FOR EVENT selection_changed OF cl_list_tree_model
      IMPORTING
          !node_key .
    METHODS root_node
      RETURNING
        VALUE(rv_node) TYPE REF TO zcl_mydd_node_root .
    METHODS set_node
      IMPORTING
        !i_below   TYPE tm_nodekey OPTIONAL
        !i_after   TYPE tm_nodekey OPTIONAL
        !i_nodekey TYPE tm_nodekey
        !i_node    TYPE REF TO zif_mydd_node .
    METHODS update_node
      IMPORTING
        !i_nodekey TYPE tm_nodekey .
    METHODS update_nodes .

    DATA m_cmds TYPE REF TO zcl_mydd_app_commands.
ENDCLASS.



CLASS zcl_mydd_view IMPLEMENTATION.


  METHOD build_tree.

    new_nodekey = |{ i_below }/{ i_node->name( ) }|.
    set_node(   i_below = i_below
                i_nodekey = new_nodekey
                i_node = i_node ).
    LOOP AT i_node->children(  ) INTO DATA(child).
      build_tree( i_below = new_nodekey
                  i_node = child ).
    ENDLOOP.

  ENDMETHOD.


  METHOD call_screen.
    m_screens->call_screen(
      EXPORTING
        i_datasection = i_datasection
        i_data        = i_data
        i_screen      = i_screen
    ).
  ENDMETHOD.


  METHOD constructor.
    m_cmds = zcl_mydd_app_commands=>instance(  ).
  ENDMETHOD.


  METHOD create.

    CREATE OBJECT r_result.

    r_result->m_cont = i_cont.
    r_result->m_screens = i_screens.

  ENDMETHOD.


  METHOD data.
    r_dataset = m_data.
  ENDMETHOD.


  METHOD handle_node_context_menu_req.
    DATA l_comp TYPE REF TO zif_mydd_active_component.
    DATA l_node TYPE REF TO zif_mydd_node.
    DATA l_ok TYPE abap_bool.
    DATA l_cmds TYPE zif_mydd_active_component=>tt_cmd_defs.
    DATA l_cmd TYPE REF TO zif_mydd_cmddefinition.
    TRY.
        CALL METHOD node_for_key
          EXPORTING
            i_key  = node_key
          IMPORTING
            e_node = l_node
          RECEIVING
            r_ok   = l_ok.
        l_comp ?= l_node.
        l_cmds = l_comp->available_cmds( ).

        LOOP AT l_cmds INTO l_cmd.
          menu->add_function( fcode =  l_cmd->code( )
                              text  =  |{ l_cmd->name( ) }|  ).

        ENDLOOP.
      CATCH cx_sy_move_cast_error.
    ENDTRY.
  ENDMETHOD.


  METHOD handle_node_context_menu_sel.
    DATA l_comp TYPE REF TO zif_mydd_active_component.
    DATA l_node TYPE REF TO zif_mydd_node.
    DATA l_ok TYPE abap_bool.
    DATA l_cmds TYPE zif_mydd_active_component=>tt_cmd_defs.
    DATA l_cmd TYPE REF TO zif_mydd_cmddefinition.
    TRY.
        CALL METHOD node_for_key
          EXPORTING
            i_key  = node_key
          IMPORTING
            e_node = l_node
          RECEIVING
            r_ok   = l_ok.
        l_comp ?= l_node.

        l_comp->process_cmd( cmd = m_cmds->command( fcode ) ).
      CATCH cx_sy_move_cast_error.
    ENDTRY.
  ENDMETHOD.


  METHOD init_view.
    DATA: lt_events TYPE cntl_simple_events.
    CREATE OBJECT m_tree
      EXPORTING
        node_selection_mode         = cl_list_tree_model=>node_sel_mode_single   " Nodes: Single or Multiple Selection
        item_selection              = abap_false    " Can Individual Items be Selected?
        with_headers                = abap_false   " 'X': With Headers
      EXCEPTIONS
        illegal_node_selection_mode = 1
        OTHERS                      = 2.

    CALL METHOD m_tree->create_tree_control
      EXPORTING
        parent  = m_cont
      IMPORTING
        control = m_control
      EXCEPTIONS
        OTHERS  = 6.

    DATA dd_behaviour TYPE REF TO cl_dragdrop.
    CREATE OBJECT dd_behaviour.
    CALL METHOD dd_behaviour->add
      EXPORTING
        flavor          = 'MOVE'    " Name of Class/Type
        dragsrc         = abap_true    " ? DragSource
        droptarget      = abap_true    " ? DropTarget
        effect          = cl_dragdrop=>move    " ? Move/Copy
*       effect_in_ctrl  = USEDEFAULTEFFECT    " ? Default Behavior for Drag and Drop Within a Control
      EXCEPTIONS
        already_defined = 1
        obj_invalid     = 2
        OTHERS          = 3.
    IF sy-subrc <> 0.
      MESSAGE |drag drop not initialized| TYPE 'I'.
    ENDIF.
    CALL METHOD dd_behaviour->get_handle
      IMPORTING
        handle      = m_dd_id   " Behavior Handle
      EXCEPTIONS
        obj_invalid = 1
        OTHERS      = 2.
    IF sy-subrc <> 0.
      MESSAGE |drag drop handle not initialized| TYPE 'I'.
    ENDIF.



    m_data->load_projects( ).
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

    SET HANDLER on_drag FOR m_tree.
    SET HANDLER on_drop FOR m_tree.
    SET HANDLER on_drop_complete FOR m_tree.

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


  METHOD node_for_key.
    DATA: node TYPE REF TO object.
    m_tree->node_get_user_object(
      EXPORTING
        node_key       = i_key    " Node key
      IMPORTING
        user_object    = node    " User Object
      EXCEPTIONS
        OTHERS         = 2
    ).
    IF sy-subrc = 0.
      e_node ?= node.
      r_ok = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD on_double_click.

  ENDMETHOD.


  METHOD on_drag.
    DATA: lo_obj TYPE REF TO zif_mydd_node.
    IF node_for_key(     EXPORTING
                           i_key  = node_key
                         IMPORTING
                           e_node = lo_obj ).
      drag_drop_object->object = lo_obj.
    ENDIF.
  ENDMETHOD.


  METHOD on_drop.

  ENDMETHOD.


  METHOD on_drop_complete.

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
        update_node( current_node_key ).
      ENDIF.
      current_node = CAST zif_mydd_node( user_object ).
      current_node->enter_form( ).
      current_node_key = node_key.
    ENDIF.
  ENDMETHOD.


  METHOD project_nodes.

    LOOP AT m_data->projects( ) INTO DATA(project).
      APPEND NEW zcl_mydd_node_project( i_key = project-id  i_view = me ) TO  r_result.
    ENDLOOP.

  ENDMETHOD.


  METHOD responds_to.

  ENDMETHOD.


  METHOD root_node.
    rv_node = NEW zcl_mydd_node_root( me ).
  ENDMETHOD.


  METHOD set_data.
    m_data = i_dataset.
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
          drag_drop_id      = m_dd_id
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


  METHOD set_status.
    DATA: lt_flist TYPE STANDARD TABLE OF rsmpe_funl,
          lt_excl  TYPE STANDARD TABLE OF char30.
    CALL FUNCTION 'RS_CUA_GET_FUNCTIONS'
      EXPORTING
        program       = sy-cprog   " Program Name
      TABLES
        function_list = lt_flist
      EXCEPTIONS
        OTHERS        = 3.

    LOOP AT lt_flist INTO DATA(ls_func).
      DATA(cmddef) = zcl_mydd_cmddefinition=>defintion_for( CONV #( ls_func-fcode ) ).
      DATA actor TYPE REF TO zif_mydd_active_component.
      actor = me.
      IF NOT actor->respondes_to( cmddef ).
        APPEND ls_func-fcode TO lt_excl.
      ENDIF.
    ENDLOOP.
    SET PF-STATUS 'STATUS' OF PROGRAM sy-cprog EXCLUDING lt_excl.

  ENDMETHOD.


  METHOD update_node.

    DATA obj TYPE REF TO object.

    CALL METHOD m_tree->node_get_user_object(
      EXPORTING
        node_key    = i_nodekey    " Node key
      IMPORTING
        user_object = obj    " User Object
      EXCEPTIONS
        OTHERS      = 2
                      ).
    IF sy-subrc = 0.
      DATA(node) = CAST zif_mydd_node( obj ).
      DATA(items) = node->items( ).
      MODIFY items FROM VALUE #( node_key = i_nodekey u_all = abap_true ) TRANSPORTING node_key u_all WHERE node_key IS INITIAL.
      CALL METHOD m_tree->update_items
        EXPORTING
          item_table          = items    " Items of Node
        EXCEPTIONS
          error_in_item_table = 1
          OTHERS              = 2.
    ENDIF.


  ENDMETHOD.


  METHOD update_nodes.
    DATA: obj TYPE REF TO object.
    CALL METHOD m_tree->get_all_node_keys
      IMPORTING
        node_key_table = DATA(tnodes).    " Table With Node Keys

    LOOP AT tnodes INTO DATA(nodekey).
      update_node( nodekey ).
    ENDLOOP.
  ENDMETHOD.


  METHOD zif_mydd_active_component~available_cmds.
  ENDMETHOD.


  METHOD process_cmd.
    CASE cmd->code( ).
      WHEN 'BACK'. SET SCREEN 0.

    ENDCASE.
  ENDMETHOD.


  METHOD zif_mydd_active_component~respondes_to.
    result = abap_true.
  ENDMETHOD.


  METHOD pai.
    IF ucomm IS NOT INITIAL.
      IF NOT process_cmd( cmd = m_cmds->command( ucomm ) ).
        CALL METHOD cl_gui_cfw=>dispatch.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD pbo.



  ENDMETHOD.


  METHOD pull_values.
    m_screens->pull_values(
      EXPORTING
        i_datasection = i_datasection
      CHANGING
        c_data        = c_data  ).
  ENDMETHOD.
ENDCLASS.
