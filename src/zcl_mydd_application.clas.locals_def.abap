CLASS dataset DEFINITION CREATE PRIVATE.
  PUBLIC SECTION.
    TYPES t_projects TYPE STANDARD TABLE OF zxrm_project WITH DEFAULT KEY.
    CLASS-METHODS create
      RETURNING
        VALUE(r_result) TYPE REF TO dataset.
    METHODS:
      read_overview,
      projects
        RETURNING
          VALUE(r_projects) TYPE t_projects,
      project           IMPORTING i_project    TYPE zxrm_project-id
                        RETURNING VALUE(r_row) TYPE zxrm_project.
  PRIVATE SECTION.
    DATA m_projects TYPE STANDARD TABLE OF zxrm_project.
ENDCLASS.
INTERFACE node DEFERRED.
CLASS tree_view DEFINITION DEFERRED.
TYPES: nodes TYPE STANDARD TABLE OF REF TO node WITH EMPTY KEY.
TYPES: BEGIN OF xkey,
         project TYPE zxrm_project-id,
       END OF xkey.
INTERFACE node.
  METHODS:
    items                       RETURNING
                                  VALUE(lt_items) TYPE   treemlitad,
    name                         RETURNING
                                   VALUE(r_result) TYPE tm_nodekey,
    leaf                        RETURNING VALUE(r_result) TYPE abap_bool,
    children                    RETURNING VALUE(r_nodes) TYPE nodes,
    show_details,
    leave_form.
ENDINTERFACE.

CLASS node_base DEFINITION.

  PUBLIC SECTION.
    INTERFACES node.
    ALIASES: items FOR node~items,
             name FOR node~name,
             children FOR node~children,
             show_details FOR node~show_details,
             leaf FOR node~leaf.

  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.

CLASS root_node DEFINITION INHERITING FROM node_base.
  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING
          i_view TYPE REF TO tree_view,
      items REDEFINITION,
      name REDEFINITION,
      leaf REDEFINITION,
      show_details REDEFINITION,
      children REDEFINITION.

  PRIVATE SECTION.
    DATA: m_view TYPE REF TO tree_view.
ENDCLASS.

CLASS project_node DEFINITION INHERITING FROM node_base.
  PUBLIC SECTION.
    METHODS:
      children REDEFINITION,
      items REDEFINITION,
      leaf REDEFINITION,
      show_details REDEFINITION,
      name REDEFINITION.
    METHODS constructor
      IMPORTING
        i_key  TYPE xkey
        i_view TYPE REF TO tree_view.


  PRIVATE SECTION.
    DATA:m_key  TYPE xkey,
         m_view TYPE REF TO tree_view.
    METHODS add_text_item
      IMPORTING
        iv_text  TYPE any
      CHANGING
        ct_items TYPE treemlitad .
    METHODS renumber_item_ids
      CHANGING
        ct_items TYPE treemlitad .
ENDCLASS.

CLASS tree_view DEFINITION CREATE PRIVATE.
  PUBLIC SECTION.
    INTERFACES zif_screens.

    ALIASES call_screen FOR zif_screens~call_screen.
    CLASS-METHODS create        IMPORTING
                                  i_cont          TYPE REF TO cl_gui_container
                                  i_screens       TYPE REF TO zif_screens
                                RETURNING
                                  VALUE(r_result) TYPE REF TO tree_view.
    METHODS project_nodes
      RETURNING
        VALUE(r_result) TYPE nodes.
    METHODS set_data
      IMPORTING
        i_dataset TYPE REF TO dataset.
    METHODS init_view.
    METHODS data
      RETURNING
        VALUE(r_dataset) TYPE REF TO dataset.
  PRIVATE SECTION.
    DATA m_cont TYPE REF TO cl_gui_container.
    DATA m_tree TYPE REF TO cl_list_tree_model .
    DATA m_root TYPE REF TO root_node.
    DATA m_data TYPE REF TO dataset.
    DATA m_screens TYPE REF TO zif_screens.
    DATA: current_node TYPE REF TO node.

    METHODS build_tree      IMPORTING
                              i_below            TYPE tm_nodekey OPTIONAL
                              i_node             TYPE REF TO node
                            RETURNING
                              VALUE(new_nodekey) TYPE tm_nodekey.
    METHODS root_node
      RETURNING
        VALUE(rv_node) TYPE REF TO root_node.
    METHODS set_node
      IMPORTING i_below   TYPE tm_nodekey OPTIONAL
                i_after   TYPE tm_nodekey OPTIONAL
                i_nodekey TYPE tm_nodekey
                i_node    TYPE REF TO node.
    METHODS handle_node_context_menu_req
          FOR EVENT node_context_menu_request OF cl_list_tree_model
      IMPORTING
          !node_key
          !menu .
    METHODS on_double_click
        FOR EVENT node_double_click OF cl_list_tree_model .

    METHODS handle_node_context_menu_sel
          FOR EVENT node_context_menu_select OF cl_list_tree_model
      IMPORTING
          !node_key
          !fcode .

    METHODS on_expand_no_children
          FOR EVENT expand_no_children OF cl_list_tree_model
      IMPORTING
          !node_key
          !sender .
    METHODS on_sel
          FOR EVENT selection_changed OF cl_list_tree_model
      IMPORTING
          !node_key .

ENDCLASS.
