CLASS zcl_mydd_cmd_save DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_mydd_cmddefinition .
    METHODS constructor
      IMPORTING
        i_dataset TYPE REF TO zif_mydd_dataset.


  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA dataset TYPE REF TO zif_mydd_dataset .
ENDCLASS.



CLASS zcl_mydd_cmd_save IMPLEMENTATION.


  METHOD constructor.
    ASSERT i_dataset IS BOUND.
    me->dataset = i_dataset.

  ENDMETHOD.


  METHOD zif_mydd_cmddefinition~exec.

    MESSAGE 'Save Data' TYPE 'S'.

    dataset->save( ).

  ENDMETHOD.
ENDCLASS.
