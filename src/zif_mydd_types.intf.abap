INTERFACE zif_mydd_types
  PUBLIC .
  TYPES kind(8) TYPE c.
  TYPES: BEGIN OF reference,
           kind TYPE kind,
           id   TYPE zrowid,
         END OF reference.
  TYPES references TYPE STANDARD TABLE OF reference WITH KEY kind id.
  TYPES entity TYPE zxrm_entity.
  TYPES entities TYPE STANDARD TABLE OF entity WITH KEY id.
  TYPES attribute TYPE zxrm_attribute.
  TYPES attributes TYPE STANDARD TABLE OF attribute WITH KEY id.
  TYPES relation TYPE zxrm_relation.
  TYPES relations TYPE STANDARD TABLE OF relation WITH KEY id.
ENDINTERFACE.
