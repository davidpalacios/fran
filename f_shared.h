extern int yylineno;

typedef enum {
	t_void,
	t_int,
	t_double,
	t_string,
	t_boolean,
	t_array_int,
	t_array_double,
	t_array_string,
	t_array_boolean,
	o_circle,
	o_gloop,
	o_gstrip,
	o_line,
	o_point,
	o_polygon,
	o_label,
	o_array_circle,
	o_array_gloop,
	o_array_gstrip,
	o_array_line,
	o_array_point,
	o_array_polygon,
	o_array_label
} F_Types;

typedef enum {
	constant,
	nonconstant
} F_Modifiers;