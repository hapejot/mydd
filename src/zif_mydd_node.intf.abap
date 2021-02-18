interface ZIF_MYDD_NODE
  public .

  methods ITEMS
    returning
      value(LT_ITEMS) type TREEMLITAD .
  methods NAME
    returning
      value(R_RESULT) type TM_NODEKEY .
  methods LEAF
    returning
      value(R_RESULT) type ABAP_BOOL .
  methods CHILDREN
    returning
      value(R_NODES) type ZMYDD_NODES .
  methods ENTER_FORM .
  methods LEAVE_FORM .
endinterface.
