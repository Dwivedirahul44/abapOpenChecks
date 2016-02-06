class ZCL_AOC_CHECK_20 definition
  public
  inheriting from ZCL_AOC_SUPER
  create public .

public section.
*"* public components of class ZCL_AOC_CHECK_20
*"* do not include other source files here!!!

  methods CONSTRUCTOR .

  methods CHECK
    redefinition .
  methods GET_ATTRIBUTES
    redefinition .
  methods GET_MESSAGE_TEXT
    redefinition .
  methods PUT_ATTRIBUTES
    redefinition .
  methods IF_CI_TEST~QUERY_ATTRIBUTES
    redefinition .
protected section.
*"* protected components of class ZCL_AOC_CHECK_20
*"* do not include other source files here!!!

  data MV_NEST_OFFSET type INT4 .
  data MV_OFFSET type INT4 .
private section.
ENDCLASS.



CLASS ZCL_AOC_CHECK_20 IMPLEMENTATION.


METHOD check.

* abapOpenChecks
* https://github.com/larshp/abapOpenChecks
* MIT License

  DATA: lv_col TYPE i,
        lv_row TYPE i,
        lv_offset LIKE mv_offset.

  FIELD-SYMBOLS: <ls_statement> LIKE LINE OF it_statements,
                 <ls_token>     LIKE LINE OF it_tokens.


  LOOP AT it_statements ASSIGNING <ls_statement>
      WHERE type <> scan_stmnt_type-comment
      AND type <> scan_stmnt_type-comment_in_stmnt
      AND type <> scan_stmnt_type-empty
      AND type <> scan_stmnt_type-pragma
      AND type <> scan_stmnt_type-macro_definition.

    READ TABLE it_tokens ASSIGNING <ls_token> INDEX <ls_statement>-from.
    IF sy-subrc = 0.
      lv_col = <ls_token>-col.
      lv_row = <ls_token>-row.
    ELSE.
      CONTINUE. " current loop
    ENDIF.

    IF <ls_token>-col MOD 2 <> 0.
      inform( p_sub_obj_type = c_type_include
              p_sub_obj_name = get_include( p_level = <ls_statement>-level )
              p_line         = <ls_token>-row
              p_kind         = mv_errty
              p_test         = myname
              p_code         = '002' ).
    ENDIF.

    CASE <ls_token>-str.
      WHEN 'IF'
          OR 'LOOP'
          OR 'ELSEIF'
          OR 'CATCH'
          OR 'DO'
          OR 'WHILE'.
        lv_offset = mv_nest_offset.
      WHEN OTHERS.
        lv_offset = mv_offset.
    ENDCASE.

    LOOP AT it_tokens ASSIGNING <ls_token>
        FROM <ls_statement>-from + 1 TO <ls_statement>-to.
      IF <ls_token>-row = lv_row.
        CONTINUE.
      ENDIF.
      IF <ls_token>-col < lv_col + lv_offset.
        inform( p_sub_obj_type = c_type_include
                p_sub_obj_name = get_include( p_level = <ls_statement>-level )
                p_line         = <ls_token>-row
                p_kind         = mv_errty
                p_test         = myname
                p_code         = '001' ).
        EXIT. " current loop
      ENDIF.
    ENDLOOP.

  ENDLOOP.

ENDMETHOD.


METHOD constructor.

  super->constructor( ).

  description    = 'Bad indentation'.                       "#EC NOTEXT
  category       = 'ZCL_AOC_CATEGORY'.
  version        = '001'.
  position       = '020'.

  has_attributes = abap_true.
  attributes_ok  = abap_true.

  mv_errty       = c_error.
  mv_offset      = 2.
  mv_nest_offset = 4.

ENDMETHOD.                    "CONSTRUCTOR


METHOD get_attributes.

  EXPORT
    mv_errty = mv_errty
    mv_offset = mv_offset
    mv_nest_offset = mv_nest_offset
    TO DATA BUFFER p_attributes.

ENDMETHOD.


METHOD get_message_text.

  CLEAR p_text.

  CASE p_code.
    WHEN '001'.
      p_text = 'Bad indentation'.                           "#EC NOTEXT
    WHEN '002'.
      p_text = 'Begin statement at tab position'.           "#EC NOTEXT
    WHEN OTHERS.
      ASSERT 0 = 1.
  ENDCASE.

ENDMETHOD.                    "GET_MESSAGE_TEXT


METHOD if_ci_test~query_attributes.

  zzaoc_top.

  zzaoc_fill_att mv_errty 'Error Type' ''.                  "#EC NOTEXT
  zzaoc_fill_att mv_offset 'Next line offset(spaces)' ''.   "#EC NOTEXT
  zzaoc_fill_att mv_nest_offset 'Statement increasing nesting' ''. "#EC NOTEXT

  zzaoc_popup.

ENDMETHOD.


METHOD put_attributes.

  IMPORT
    mv_errty  = mv_errty
    mv_offset = mv_offset
    mv_nest_offset = mv_nest_offset
    FROM DATA BUFFER p_attributes.                   "#EC CI_USE_WANTED
  ASSERT sy-subrc = 0.

ENDMETHOD.
ENDCLASS.