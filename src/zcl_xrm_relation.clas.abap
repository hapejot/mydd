CLASS zcl_xrm_relation DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        i_ds TYPE REF TO zcl_mydd_dataset
        i_row TYPE REF TO zif_mydd_types=>relation.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA m_ds TYPE REF TO zcl_mydd_dataset.
    DATA m_row TYPE REF TO zif_mydd_types=>relation.
ENDCLASS.



CLASS zcl_xrm_relation IMPLEMENTATION.

  METHOD constructor.

    me->m_ds = i_ds.
    me->m_row = i_row.

  ENDMETHOD.
ENDCLASS.
