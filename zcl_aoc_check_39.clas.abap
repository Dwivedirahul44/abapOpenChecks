class ZCL_AOC_CHECK_39 definition
  public
  inheriting from ZCL_AOC_SUPER_ROOT
  create public .

public section.
*"* public components of class ZCL_AOC_CHECK_39
*"* do not include other source files here!!!

  methods CONSTRUCTOR .

  methods GET_ATTRIBUTES
    redefinition .
  methods GET_MESSAGE_TEXT
    redefinition .
  methods IF_CI_TEST~QUERY_ATTRIBUTES
    redefinition .
  methods PUT_ATTRIBUTES
    redefinition .
  methods RUN
    redefinition .
protected section.
*"* protected components of class ZCL_AOC_CHECK_39
*"* do not include other source files here!!!

  data MS_SETTINGS type SCI_S_NAMING_CONVENTIONS_SETUP .

  methods CHECK_NAME
    importing
      !IV_NAME type TDSFVNAME
      !IV_PREFIX type SCI_E_TYPE_PREFIX
      !IT_REGULAR type SCI_T_REGULAR_EXPRESSIONS .
  methods DETERMINE_PREFIX
    importing
      !IS_SSFGDATA type SSFGDATA
    returning
      value(RV_PREFIX) type SCI_E_TYPE_PREFIX .
  methods SET_DEFAULTS .
private section.
ENDCLASS.



CLASS ZCL_AOC_CHECK_39 IMPLEMENTATION.


METHOD check_name.

  DATA: lv_regular LIKE LINE OF it_regular.


  LOOP AT it_regular INTO lv_regular.
    REPLACE ALL OCCURRENCES OF '[:type:]' IN lv_regular WITH iv_prefix.

    FIND REGEX lv_regular IN iv_name.
    IF sy-subrc = 0.
      RETURN.
    ENDIF.

  ENDLOOP.

  inform( p_sub_obj_type = object_type
          p_sub_obj_name = object_name
          p_test         = myname
          p_kind         = mv_errty
          p_code         = '001'
          p_param_1      = iv_name ).

ENDMETHOD.


METHOD constructor.

  super->constructor( ).

  description    = 'Smartforms global definitions naming conventions'. "#EC NOTEXT
  category       = 'ZCL_AOC_CATEGORY'.
  version        = '002'.
  position       = '039'.

  has_documentation = c_true.
  has_attributes = abap_true.
  attributes_ok  = abap_true.

  mv_errty = c_error.

  add_obj_type( 'SSFO' ).

set_defaults( ).

ENDMETHOD.                    "CONSTRUCTOR


METHOD determine_prefix.

  DATA: lo_type    TYPE REF TO cl_abap_typedescr,
        lv_clstype TYPE seoclass-clsname.


  CASE is_ssfgdata-typing.
    WHEN 'TYPE'.
      cl_abap_typedescr=>describe_by_name(
        EXPORTING
          p_name         = is_ssfgdata-typename
        RECEIVING
          p_descr_ref    = lo_type
        EXCEPTIONS
          type_not_found = 1
          OTHERS         = 2 ).
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.

      CASE lo_type->kind.
        WHEN cl_abap_typedescr=>kind_elem.
          rv_prefix = ms_settings-prefix_elementary.
        WHEN cl_abap_typedescr=>kind_struct.
          rv_prefix = ms_settings-prefix_structure.
        WHEN cl_abap_typedescr=>kind_table.
          rv_prefix = ms_settings-prefix_table_any.
      ENDCASE.

    WHEN 'TYPE REF TO'.
      SELECT SINGLE clstype FROM seoclass
        INTO lv_clstype
        WHERE clsname = is_ssfgdata-typename.
      IF sy-subrc = 0.
        CASE lv_clstype.
          WHEN '0'.
            rv_prefix = ms_settings-prefix_ref_class.
          WHEN '1'.
            rv_prefix = ms_settings-prefix_ref_interface.
        ENDCASE.
      ENDIF.
  ENDCASE.

ENDMETHOD.


METHOD get_attributes.

  EXPORT
    mv_errty = mv_errty
    ms_settings = ms_settings
    TO DATA BUFFER p_attributes.

ENDMETHOD.


METHOD get_message_text.

  CLEAR p_text.

  CASE p_code.
    WHEN '001'.
      p_text = 'Wrong naming, &1'.                          "#EC NOTEXT
    WHEN OTHERS.
      ASSERT 0 = 1.
  ENDCASE.

ENDMETHOD.


METHOD if_ci_test~query_attributes.

  zzaoc_top.

  zzaoc_fill_att mv_errty 'Error Type' ''.                  "#EC NOTEXT

  zzaoc_fill_att ms_settings-prefix_elementary
    'Elementary Type' ''.                                   "#EC NOTEXT
  zzaoc_fill_att ms_settings-prefix_structure
    'Structure' ''.                                         "#EC NOTEXT
  zzaoc_fill_att ms_settings-prefix_table_any
    'Table' ''.                                             "#EC NOTEXT
  zzaoc_fill_att ms_settings-prefix_ref_class
    'Reference to Class' ''.                                "#EC NOTEXT
  zzaoc_fill_att ms_settings-prefix_ref_interface
    'Reference to Interface' ''.                            "#EC NOTEXT

  zzaoc_fill_att ms_settings-patterns_prog_data_global
    'Global Data' ''.                                       "#EC NOTEXT
  zzaoc_fill_att ms_settings-patterns_prog_field_symbol_glb
    'Field Symbols' ''.                                     "#EC NOTEXT

  zzaoc_popup.

ENDMETHOD.


METHOD put_attributes.

  IMPORT
    mv_errty = mv_errty
    ms_settings = ms_settings
    FROM DATA BUFFER p_attributes.                   "#EC CI_USE_WANTED
  ASSERT sy-subrc = 0.

ENDMETHOD.


METHOD run.

* abapOpenChecks
* https://github.com/larshp/abapOpenChecks
* MIT License

  DATA: lv_name   TYPE tdsfname,
        lv_prefix TYPE sci_e_type_prefix,
        lo_sf     TYPE REF TO cl_ssf_fb_smart_form.

  FIELD-SYMBOLS: <ls_data> LIKE LINE OF lo_sf->fsymbols.


  IF object_type <> 'SSFO'.
    RETURN.
  ENDIF.

  CREATE OBJECT lo_sf.
  lv_name = object_name.
  lo_sf->load( lv_name ).


  LOOP AT lo_sf->fsymbols ASSIGNING <ls_data>.
    lv_prefix = determine_prefix( <ls_data> ).
    check_name( iv_name    = <ls_data>-name
                iv_prefix  = lv_prefix
                it_regular = ms_settings-patterns_prog_field_symbol_glb ).
  ENDLOOP.

  LOOP AT lo_sf->gdata ASSIGNING <ls_data>.
    lv_prefix = determine_prefix( <ls_data> ).
    check_name( iv_name    = <ls_data>-name
                iv_prefix  = lv_prefix
                it_regular = ms_settings-patterns_prog_data_global ).
  ENDLOOP.

ENDMETHOD.


METHOD set_defaults.

  CLEAR ms_settings.

  ms_settings-prefix_elementary    = 'V'.
  ms_settings-prefix_structure     = 'S'.
  ms_settings-prefix_table_any     = 'T'.
  ms_settings-prefix_ref_class     = 'O'.
  ms_settings-prefix_ref_interface = 'I'.

  APPEND '(/.*/)?G[:type:]_' TO ms_settings-patterns_prog_data_global.
  APPEND '<G[:type:]_' TO ms_settings-patterns_prog_field_symbol_glb.

ENDMETHOD.
ENDCLASS.