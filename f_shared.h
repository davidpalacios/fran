
extern int yylineno;

typedef enum {
	t_void,
	t_int,
	t_double,
	t_string,
	t_boolean
} F_Types;

typedef enum {
	o_circle, 
	o_gloop,
	o_gstrip,
	o_line,
	o_point,
	o_polygon,
	o_label
} F_Objects;