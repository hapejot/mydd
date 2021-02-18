CLASS zcl_mydd_dataset DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_mydd_dataset.

    CLASS-METHODS create
      RETURNING
        VALUE(r_result) TYPE REF TO zif_mydd_dataset.
    METHODS load_project
      IMPORTING
        i_prj_id TYPE zrowid.
    METHODS project_update
      IMPORTING
        i_prj TYPE zxrm_project.
    METHODS project_create
      IMPORTING
        i_prj TYPE zxrm_project.
    METHODS entity_retrieve_multi
      IMPORTING i_query         TYPE REF TO zcl_bc_query
      RETURNING
                VALUE(r_result) TYPE zif_mydd_types=>entities.
    METHODS attribute_retrieve_multiple
      IMPORTING
        i_query         TYPE REF TO zcl_bc_query
      RETURNING
        VALUE(r_result) TYPE zif_mydd_types=>attributes.
    METHODS declare_entity
      IMPORTING
        i_entity        TYPE zname
      RETURNING
        VALUE(r_result) TYPE REF TO zcl_xrm_entity.
    METHODS declare_lookup
      IMPORTING
        i_fldname TYPE string
        i_entname TYPE string
        i_relname TYPE string.

    METHODS attributes
      RETURNING
        VALUE(r_result) TYPE zif_mydd_types=>attributes.
    METHODS entities
      RETURNING
        VALUE(r_result) TYPE zif_mydd_types=>entities.
    METHODS declare_attribute
      IMPORTING
                i_entityid  TYPE zxrm_entity-id
                i_name      TYPE fieldname
      RETURNING VALUE(attr) TYPE REF TO zcl_xrm_attribute.
    METHODS declare_relation
      IMPORTING
        i_name        TYPE zname
        i_ent1        TYPE zrowid
        i_fname1      TYPE fieldname
        i_ent2        TYPE zrowid
      RETURNING
        VALUE(result) TYPE REF TO zcl_xrm_relation.
    METHODS relations
      RETURNING
        VALUE(r_result) TYPE zif_mydd_types=>relations.


  PRIVATE SECTION.
    TYPES: BEGIN OF data_ref,
             kind(8)  TYPE c,
             name(92) TYPE c,
           END OF data_ref.
    DATA m_entities TYPE zif_mydd_types=>entities.
    DATA m_attributes TYPE zif_mydd_types=>attributes.
    DATA m_relations TYPE zif_mydd_types=>relations.

    DATA: projects         TYPE STANDARD TABLE OF zxrm_project,
          new_projects     TYPE STANDARD TABLE OF zxrm_project,
          project_elements TYPE STANDARD TABLE OF zxrm_app_element.
    METHODS new_guid
      RETURNING
        VALUE(r_result) TYPE zrowid.
    METHODS write
      IMPORTING
        i_row     TYPE any
        i_fldname TYPE fieldname.

ENDCLASS.



CLASS zcl_mydd_dataset IMPLEMENTATION.


  METHOD attributes.
    r_result = m_attributes.
  ENDMETHOD.


  METHOD attribute_retrieve_multiple.
    DATA(ws) = i_query->get_where_clause( ).
    DATA(w) = ws[ tablename = 'ZXRM_ATTRIBUTE'  ]-where_tab.
    SELECT * FROM zxrm_attribute
    WHERE (w)
    INTO TABLE @r_result.
  ENDMETHOD.


  METHOD create.
    r_result = NEW zcl_mydd_dataset(  ).
  ENDMETHOD.


  METHOD declare_attribute.
    DATA(name) = to_upper( i_name ).
    DATA(row) = REF #( m_attributes[ entityid = i_entityid name = name ] OPTIONAL ).
    IF row IS INITIAL.
      APPEND VALUE #( id = new_guid(  )  name = name  entityid = i_entityid ) TO m_attributes REFERENCE INTO row.
    ENDIF.
    attr  = NEW zcl_xrm_attribute(
        i_ds  = me
        i_row = row
    ).
  ENDMETHOD.


  METHOD declare_entity.
    DATA(name) = to_upper( i_entity ).
    DATA(row) = REF #( m_entities[ name = name ] OPTIONAL ).
    IF row IS INITIAL.
      APPEND VALUE #( id = new_guid(  ) name = name ) TO m_entities REFERENCE INTO row.
    ENDIF.
    r_result = NEW zcl_xrm_entity(
        i_ds  = me
        i_row = row
    ).
  ENDMETHOD.


  METHOD declare_lookup.

  ENDMETHOD.


  METHOD declare_relation.
    DATA(name) = to_upper( i_name ).
    DATA(row) = REF #( m_relations[ name = name ] OPTIONAL ).
    IF row IS INITIAL.
      APPEND VALUE #( id = new_guid(  )  name = name   ) TO m_relations REFERENCE INTO row.
    ENDIF.
    result  = NEW zcl_xrm_relation(
        i_ds  = me
        i_row = row
    ).
  ENDMETHOD.


  METHOD entities.
    r_result = m_entities.
  ENDMETHOD.


  METHOD entity_retrieve_multi.
    DATA(ws) = i_query->get_where_clause( ).
    DATA(w) = ws[ 1 ]-where_tab.
    SELECT * FROM zxrm_entity
    WHERE (w)
    INTO TABLE @r_result.
  ENDMETHOD.


  METHOD load_project.

    SELECT * FROM zxrm_project WHERE id = @i_prj_id
        APPENDING TABLE @projects.

    SELECT * FROM zxrm_app_element WHERE project_id = @i_prj_id
        APPENDING TABLE @project_elements.


*    SELECT * FROM zxrm_entity
*        INTO TABLE @m_entities.
*
*    SELECT * FROM zxrm_attribute
*            INTO TABLE @m_attributes.

  ENDMETHOD.


  METHOD new_guid.
    TRY.
        r_result = cl_system_uuid=>if_system_uuid_static~create_uuid_x16(  ).
      CATCH cx_uuid_error.    "
    ENDTRY.

  ENDMETHOD.


  METHOD project_create.
    APPEND i_prj TO new_projects REFERENCE INTO DATA(prj).

    IF prj->id IS INITIAL.
      prj->id = me->new_guid( ).
    ENDIF.

  ENDMETHOD.


  METHOD project_update.

    ASSERT i_prj-id IS NOT INITIAL.
    DATA(prj_ref) = REF #( new_projects[ id = i_prj-id ] OPTIONAL ).
    IF prj_ref IS INITIAL.
      APPEND INITIAL LINE TO new_projects REFERENCE INTO prj_ref.
    ENDIF.
    prj_ref->* = i_prj.

  ENDMETHOD.


  METHOD relations.
    r_result = m_relations.
  ENDMETHOD.


  METHOD zif_mydd_dataset~attribute.

  ENDMETHOD.


  METHOD zif_mydd_dataset~attributes.

  ENDMETHOD.


  METHOD zif_mydd_dataset~create_attribute.

  ENDMETHOD.


  METHOD zif_mydd_dataset~create_entity.

  ENDMETHOD.


  METHOD zif_mydd_dataset~entities.

  ENDMETHOD.


  METHOD zif_mydd_dataset~entity.

  ENDMETHOD.


  METHOD zif_mydd_dataset~load_projects.
    DATA:
            project TYPE zxrm_project.

    SELECT * FROM zxrm_project
                INTO TABLE @projects.
    new_projects = projects.

*    SELECT * FROM zxrm_entity
*        INTO TABLE @m_entities.
*
*    SELECT * FROM zxrm_attribute
*        INTO TABLE @m_attributes.
*
*    SELECT * FROM zxrm_relation
*        INTO TABLE @m_relations.


  ENDMETHOD.


  METHOD zif_mydd_dataset~project.
    r_row = new_projects[ id = i_project ].
  ENDMETHOD.


  METHOD zif_mydd_dataset~projects.
    r_projects = new_projects.
  ENDMETHOD.


  METHOD zif_mydd_dataset~save.
    DATA:

      update_cnt TYPE i,
      insert_cnt TYPE i.
    FIELD-SYMBOLS <row> TYPE any.

    DELETE FROM zxrm_relation.
    DELETE FROM zxrm_attribute.
    DELETE FROM zxrm_entity.

    LOOP AT new_projects ASSIGNING <row>.
      MODIFY zxrm_project FROM <row>.
    ENDLOOP.

    MODIFY zxrm_entity FROM TABLE m_entities.
    WRITE: / 'Entitiy RC:', sy-subrc.
    WRITE:/ 'Updates :', sy-dbcnt, '/', lines( m_entities ).

    MODIFY zxrm_attribute FROM TABLE m_attributes.
    WRITE:/ 'Attribute RC:', sy-subrc.
    WRITE:/ 'Updates :', sy-dbcnt, '/', lines( m_attributes ).

    MODIFY zxrm_relation FROM TABLE m_relations.
    WRITE:/ 'Relation RC:', sy-subrc.
    WRITE:/ 'Updates :', sy-dbcnt, '/', lines( m_relations ).


    COMMIT WORK.

  ENDMETHOD.


  METHOD zif_mydd_dataset~set_project.

  ENDMETHOD.

  METHOD write.
    FIELD-SYMBOLS <val> TYPE any.
    ASSIGN COMPONENT i_fldname OF STRUCTURE i_row TO <val>.
    WRITE / |{ i_fldname }: { <val> }|.
  ENDMETHOD.

ENDCLASS.
