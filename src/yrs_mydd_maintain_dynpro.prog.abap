*&---------------------------------------------------------------------*
*& Report yrs_mydd_maintain_dynpro
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT yrs_mydd_maintain_dynpro.

CLASS app DEFINITION.
  PUBLIC SECTION.
    METHODS read
      RETURNING
        VALUE(r_ok) TYPE abap_bool.
    METHODS main.
  PRIVATE SECTION.
    CONSTANTS abap_true TYPE string VALUE 'X' ##NO_TEXT.
    DATA: m_progname           TYPE d020s-prog VALUE 'YRS_BC_MYDD',
          m_dynnr              TYPE d020s-dnum VALUE '0002',
          header               TYPE rpy_dyhead,
          containers           TYPE dycatt_tab,
          fields_to_containers TYPE dyfatc_tab,
          flow_logic           TYPE STANDARD TABLE OF rpy_dyflow,
          params               TYPE STANDARD TABLE OF rpy_dypara,
          fields_list          TYPE STANDARD TABLE OF d021s.
    METHODS write
      RETURNING
        VALUE(r_ok) TYPE abap_bool.



ENDCLASS.

CLASS app IMPLEMENTATION.

  METHOD write.
    header-program = m_progname.
    header-screen = '0002'.
    CALL FUNCTION 'RPY_DYNPRO_INSERT'
      EXPORTING
*       suppress_corr_checks   = ' '
*       corrnum                = SPACE    " Correction Number
        suppress_exist_checks  = abap_true
*       suppress_generate      = ' '
*       suppress_dict_support  = ' '
*       suppress_extended_checks = ' '
        header                 = header
*       use_corrnum_immediatedly = ' '
*       suppress_commit_work   = ' '
      TABLES
        containers             = containers    " Screen: Container Attributes (External Representation)
        fields_to_containers   = fields_to_containers    " Screen: Single fields for a container (external represent.)
        flow_logic             = flow_logic
*       params                 =
      EXCEPTIONS
        cancelled              = 1
        already_exists         = 2
        program_not_exists     = 3
        not_executed           = 4
        missing_required_field = 5
        illegal_field_value    = 6
        field_not_allowed      = 7
        not_generated          = 8
        illegal_field_position = 9
        OTHERS                 = 10.
    IF sy-subrc = 0.
      r_ok = abap_true.
    ENDIF.
    WRITE: / 'write rc', sy-subrc.
  ENDMETHOD.

  METHOD read.

    CALL FUNCTION 'RPY_DYNPRO_READ'
      EXPORTING
        progname             = m_progname    " Program name of screen
        dynnr                = m_dynnr    " Screen number
      IMPORTING
        header               = header
      TABLES
        containers           = containers
        fields_to_containers = fields_to_containers    " Single object in screen (incl. cont. assignment)
        flow_logic           = flow_logic
        params               = params    " Screen: Parameter Information for Screen
        fields_list          = fields_list
      EXCEPTIONS
        cancelled            = 1
        not_found            = 2
        permission_error     = 3
        OTHERS               = 4.

    IF sy-subrc = 0.
      r_ok = abap_true.
    ENDIF.

  ENDMETHOD.
  METHOD main.
    IF read( ).
      WRITE / 'READ OK'.
      DATA(struct) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_name( p_name = 'ZXRM_PROJECT' ) ).
      LOOP AT struct->components INTO DATA(ls_comp).
        DATA(lv_row) = sy-tabix.
        IF ls_comp-length > 300.
          CONTINUE.
        ENDIF.
        IF ls_comp-name = 'MANDT'.
          CONTINUE.
        ENDIF.
        WRITE: / ls_comp-name, ls_comp-length, ls_comp-type_kind.
        DATA(name1) = |GD-PROJECT-{ ls_comp-name }|.
        DATA(name2) = |ZXRM_PROJECT-{ ls_comp-name }|.
        DATA(label) = REF #( fields_to_containers[ name = name2  type = 'TEXT'     ] OPTIONAL ).
        IF label IS NOT BOUND.
          label = REF #( fields_to_containers[ name = name1  type = 'TEXT'     ] OPTIONAL ).
        ENDIF.

        DATA(edit)  = REF #( fields_to_containers[ name = name2  type = 'TEMPLATE' ] OPTIONAL ).
        IF edit IS NOT BOUND.
          edit =  REF #( fields_to_containers[ name = name1  type = 'TEMPLATE' ] OPTIONAL ).
        ENDIF.
        IF edit IS NOT BOUND.
          edit  = REF #( fields_to_containers[ name = |ZXRM_PROJECT-{ ls_comp-name }|  type = 'CHECK' ] OPTIONAL ).
        ENDIF.
        IF label IS BOUND.
          WRITE: / ls_comp-name, 'label exists', label->length.
        ELSE.
          APPEND INITIAL LINE TO fields_to_containers REFERENCE INTO label.
          label->cont_type = 'SCREEN'.
          label->cont_name = 'SCREEN '.
          label->type = 'TEXT'.
          label->name = |GD-PROJECT-{ ls_comp-name }|.
          label->text = ls_comp-name.
          label->line = lv_row.
          label->column = '001'.
          label->length = strlen(  ls_comp-name  ).
          label->vislength = strlen( ls_comp-name ).
          label->height = '001'.
          label->format = 'CHAR'.
          label->from_dict = ' '.
          label->modific = ' '.
          label->requ_entry = 'N'.
          label->labelleft = abap_true.
        ENDIF.

        IF edit IS BOUND.
          WRITE: / ls_comp-name, 'edit exits', edit->length.
        ELSE.
          APPEND INITIAL LINE TO fields_to_containers REFERENCE INTO edit.
          edit->cont_type = 'SCREEN'.
          edit->cont_name = 'SCREEN'.
          edit->type = 'TEMPLATE'.
          edit->name = |GD-PROJECT-{ ls_comp-name }|.
*          edit->text = '________________________________'.
          edit->line = lv_row.
          edit->column = '017'.
          edit->length = ls_comp-length / 2.
          edit->vislength = edit->length.
          edit->height = '001'.
          edit->format = 'CHAR'.
          edit->from_dict = abap_false.
          edit->foreignkey = abap_false.
          edit->input_fld = abap_true.
          edit->output_fld = abap_true.
          edit->up_lower = abap_true.
        ENDIF.
      ENDLOOP.




      SORT fields_to_containers BY line column.
      IF write(  ).
        WRITE / 'WRITE OK'.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.


INITIALIZATION.
  NEW app(  )->main(  ).
