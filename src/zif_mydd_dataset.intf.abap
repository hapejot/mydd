interface ZIF_MYDD_DATASET
  public .


  types:
    t_projects TYPE STANDARD TABLE OF zxrm_project WITH DEFAULT KEY .

  methods load_projects .
  methods PROJECTS
    returning
      value(R_PROJECTS) type T_PROJECTS .
  methods PROJECT
    importing
      !I_PROJECT type ZXRM_PROJECT-ID
    returning
      value(R_ROW) type ZXRM_PROJECT .
  methods SET_PROJECT
    importing
      !I_ROW type ZXRM_PROJECT .
  methods SAVE .
  methods CREATE_ENTITY .
  methods ENTITY .
  methods ENTITIES .
  methods CREATE_ATTRIBUTE .
  methods ATTRIBUTES .
  methods ATTRIBUTE .
endinterface.
