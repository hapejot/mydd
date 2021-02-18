INTERFACE zif_mydd_active_component
  PUBLIC .


  TYPES:
    tt_cmd_defs TYPE STANDARD TABLE OF REF TO zif_mydd_cmddefinition WITH EMPTY KEY .

  METHODS respondes_to
    IMPORTING
      !cmddef       TYPE REF TO zif_mydd_cmddefinition
    RETURNING
      VALUE(result) TYPE abap_bool .
  METHODS process_cmd
    IMPORTING
      !cmd        TYPE REF TO zif_mydd_cmddefinition
    RETURNING
      VALUE(done) TYPE abap_bool .
  METHODS available_cmds
    RETURNING
      VALUE(cmds) TYPE tt_cmd_defs .
ENDINTERFACE.
