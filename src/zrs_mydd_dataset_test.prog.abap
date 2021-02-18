
REPORT zrs_mydd_dataset_test LINE-SIZE 1000.

DATA dsi TYPE REF TO zif_mydd_dataset.
DATA ds TYPE REF TO zcl_mydd_dataset.
DATA elements TYPE zif_mydd_types=>references.
CREATE OBJECT ds.
dsi ?= ds.

dsi->load_projects( ).

LOOP AT dsi->projects(  ) INTO DATA(ls_prj).
  IF  ls_prj-name = 'ITSC'.
    ds->load_project( ls_prj-id ).

    ls_prj = dsi->project( ls_prj-id  ).
    ls_prj-description = |Anwendung für ITSC um { sy-uzeit TIME = USER }|.

    ds->project_update( ls_prj ).

  ENDIF.

ENDLOOP.

*ds->project_create( VALUE zxrm_project(
*                    responsible = sy-uname
*                    name = |Peter { sy-uzeit TIME = USER }| )  ).

DATA entities TYPE STANDARD TABLE OF zxrm_entity WITH DEFAULT KEY.
DATA q TYPE REF TO zcl_bc_query.
CREATE OBJECT q.

q->add(
  EXPORTING
    i_tablename = 'zxrm_entity'
    i_fieldname = 'name'
    i_low       = 'Entity'
).
entities = ds->entity_retrieve_multi( q ).
LOOP AT entities INTO DATA(entity).
  WRITE:/ 'Entity', entity-name, entity-id.
ENDLOOP.

FREE q.
CREATE OBJECT q.
DATA id(45) TYPE c.
*id = entities[ 1 ]-id.
*q->add(
*  EXPORTING
*    i_tablename = 'zxrm_attribute'
*    i_fieldname = 'entityid'
*    i_low       = id
*).
*DATA(attributes) = ds->attribute_retrieve_multiple( q ).


DATA(e) = ds->declare_entity( 'entity' ).
e->declare_attribute(
  EXPORTING
    i_fldname = 'ID_DTEL'
    i_type    = 'ROLLNAME'
).
e->declare_attribute(
  EXPORTING
    i_fldname = 'NAME_DTEL'
    i_type    = 'ROLLNAME'
).

e->generate(  ).
e->activate(  ).

DATA(a) = ds->declare_entity( 'attribute' ).
a->declare_lookup( i_fldname = 'entityid'
                    i_entname = 'entity'
                    i_relname = 'entity_attribute' ).
a->generate(  ).
a->activate(  ).
DATA(r) = ds->declare_entity( 'relation' ).
r->declare_attribute( i_type = 'DDASSKIND' ).
r->declare_lookup( i_fldname = 'entity1id'
                   i_entname = 'entity'
                   i_relname = 'entity1_attribute' ).
r->declare_lookup( i_fldname = 'entity2id'
                   i_entname = 'entity'
                   i_relname = 'entity2_attribute' ).
r->generate(  ).
r->activate(  ).

LOOP AT r->attributes(  ) INTO DATA(attribute).
  WRITE: / |ATTR { attribute-id } Entity: { attribute-entityid } {  attribute-name } T| .
ENDLOOP.


dsi->save( ).
