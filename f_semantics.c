#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <glib.h>
#include "f_shared.h"

char *f_modifier_names[] = {
	"const",
	"nonconst"
};

char *f_type_names[] = {
	"void",
	"int",
	"double",
	"string",
	"boolean",
	"array of type int",
	"array of type double",
	"array of type string",
	"array of type boolean",
	"Circle",
	"GLoop",
	"GStrip",
	"Line",
	"Point",
	"Polygon",
	"Label",
	"array of type circle",
	"array of type gloop",
	"array of type gstrip",
	"array of type line",
	"array of type point",
	"array of type polygon",
	"array of type label"
};

static char *error_msgs[] = {
	"Duplicate program",
	"Duplicate function",
	"Unknown Fran error",
	"Duplicate parameter",
	"Duplicate global variable",
	"Duplicate local variable",
	"Variable already declare as parameter"
};

typedef enum {
	duplicate_program,
	duplicate_method,
	fran_error,
	duplicate_parameter,
	duplicate_global_Var,
	duplicate_var,
	duplicate_local_parameter
} Error_Types;


typedef struct {
	char *current_program_name;
	char *current_procedure_name;
	F_Types current_procedure_type;
	F_Types current_var_type;
	F_Types current_var_modifier;
} F_State;

typedef struct {
	GHashTable *program_vars;				// <varID, Variable>
	GHashTable *program_procedures;			// <procedureID, Procedure>
	GHashTable *program_program_procedures; // <programID, Program_Procedures>
} Fran_Program;

typedef struct {
	F_Types proc_type;     
	GHashTable *procedure_params;
	GHashTable *procedure_vars;
} Procedure;

typedef struct {
	F_Types var_type;
	F_Modifiers var_modifier;
} Variable;

/*
 * This encapsulates all the programs that are available in a single compilation
 * call.
 * Only one of these programs must have a main function
 *
 */

int yylineno;

static GHashTable *fran_programs;			// <programID, Fran_Program>


// handle state when in an use or the main program...
F_State *current_state;

void free_program_vars( gpointer key, gpointer value, gpointer user_data ) {
	
	g_slice_free( Variable, (Variable * ) value );

}

void free_program_proc( gpointer key, gpointer value, gpointer user_data ) {
	
	Procedure *proc = (Procedure * ) value;
	g_hash_table_foreach( proc -> procedure_params, (GHFunc) free_program_vars, "" );
	g_hash_table_foreach( proc -> procedure_vars, (GHFunc) free_program_vars, "" );
	g_slice_free( Procedure, (Procedure * ) value );

}

void free_programs( gpointer key, gpointer value, gpointer user_data ) {

	Fran_Program *current_program = (Fran_Program * ) value;
	g_hash_table_foreach( current_program -> program_vars, (GHFunc) free_program_vars, "" );
	g_hash_table_foreach( current_program -> program_procedures, (GHFunc) free_program_proc, "" );
	g_slice_free( Fran_Program, (Fran_Program * ) value );

}

void free_memory() {

	g_hash_table_foreach( fran_programs, (GHFunc) free_programs, "" );

}

void print_error_and_exit( Error_Types type, char *msg ) {

	gchar *error_line = g_strdup_printf( "%i", yylineno );
	gchar *long_msg;

	switch ( type ) {

		case duplicate_global_Var:
		case duplicate_method:

			long_msg = g_strconcat( error_line, ": ", error_msgs[ type ], " '", 
				msg, "' in program '", current_state -> current_program_name, "'", NULL );
			
			break;

		case duplicate_local_parameter:
		case duplicate_parameter:
		case duplicate_var:

			long_msg = g_strconcat( error_line, ": ", error_msgs[ type ], " '", 
				msg, "' in function '", current_state -> current_procedure_name, "'", NULL );
			
			break;

		default: 

			long_msg = g_strconcat( error_line, ": ", error_msgs[ type ], NULL );
			
			break;

	}

	printf( "error:%s \n", long_msg );
	g_free( error_line);
	g_free( long_msg );
	free_memory();
	exit(0);

}

void init_semantics() {

	fran_programs = g_hash_table_new( g_str_hash, g_str_equal );
	current_state = g_slice_new( F_State );

}

void add_program( char *program_name ) {

	if ( g_hash_table_lookup( fran_programs, (gpointer) program_name ) != NULL ) {
		
		print_error_and_exit( duplicate_program, program_name );

	} else {

		Fran_Program *new_program = g_slice_new( Fran_Program );
		new_program -> program_vars = g_hash_table_new( g_str_hash, g_str_equal );
		new_program -> program_procedures = g_hash_table_new( g_str_hash, g_str_equal );
		current_state -> current_program_name = program_name;
		g_hash_table_insert(fran_programs, (gpointer) program_name, (gpointer) new_program );		

	} 

}

void add_procedure_to_current_program( char *proc_name, F_Types proc_type ) {

	Fran_Program *current_program = g_hash_table_lookup( fran_programs, current_state -> current_program_name );

	if ( g_hash_table_lookup( current_program -> program_procedures, (gpointer) proc_name ) != NULL ){

		print_error_and_exit( duplicate_method, proc_name );

	} else {

		Procedure *new_procedure = g_slice_new( Procedure );
		new_procedure -> proc_type = proc_type;
		new_procedure -> procedure_params = g_hash_table_new( g_str_hash, g_str_equal );
		new_procedure -> procedure_vars = g_hash_table_new( g_str_hash, g_str_equal );
		current_state -> current_procedure_name = proc_name;
		current_state -> current_procedure_type = proc_type;

		g_hash_table_insert( current_program -> program_procedures, (gpointer) proc_name, (gpointer) new_procedure); 

	}

}

void add_global_to_current_program( char *var_name, F_Modifiers var_modifier, F_Types var_type ) {

	Fran_Program *current_program = g_hash_table_lookup( fran_programs, current_state -> current_program_name );
	GHashTable *program_vars = current_program -> program_vars;
	Variable *global_to_add = g_hash_table_lookup(program_vars, var_name );

	if ( global_to_add != NULL ) {

		print_error_and_exit( duplicate_global_Var, var_name );

	} else {
		
		global_to_add = g_slice_new( Variable );
		global_to_add -> var_type = var_type;
		global_to_add -> var_modifier = var_modifier;
		g_hash_table_insert( program_vars, (gpointer) var_name, (gpointer) global_to_add ); 

	}

}

void add_param_to_current_procedure( char *var_name, F_Modifiers var_modifier, F_Types var_type ) {

	Fran_Program *current_program = g_hash_table_lookup( fran_programs, current_state -> current_program_name );
	GHashTable *current_hash_procedures = current_program -> program_procedures;
	Procedure *procedure_to_add_param = g_hash_table_lookup(current_hash_procedures, (gpointer) current_state -> current_procedure_name );

	if ( procedure_to_add_param == NULL ) {

		print_error_and_exit( fran_error, " method not found " );

	}

	if ( g_hash_table_lookup( procedure_to_add_param -> procedure_params, (gpointer) var_name ) != NULL ) {

		print_error_and_exit( duplicate_parameter, var_name );

	} else {
		
		Variable *new_param_var = g_slice_new( Variable );
		new_param_var -> var_type = var_type;
		new_param_var -> var_modifier = var_modifier;
		g_hash_table_insert( procedure_to_add_param -> procedure_params, (gpointer) var_name, (gpointer) new_param_var ); 

	}

}

void add_global_var_to_current_program( char *var_name, F_Modifiers var_modifier, F_Types var_type ) {

	Fran_Program *current_program = g_hash_table_lookup( fran_programs, current_state -> current_program_name );
	
	if ( g_hash_table_lookup( current_program -> program_vars, (gpointer) var_name ) != NULL ) {

		print_error_and_exit( duplicate_global_Var, var_name );

	} else {

		Variable *new_param_var = g_slice_new( Variable );
		new_param_var -> var_type = var_type;
		new_param_var -> var_modifier = var_modifier;
		g_hash_table_insert( current_program -> program_vars, (gpointer) var_name, (gpointer) new_param_var );

	}

}

void add_local_to_current_procedure( char *var_name, F_Modifiers var_modifier, F_Types var_type ) {

	Fran_Program *current_program = g_hash_table_lookup( fran_programs, current_state -> current_program_name );
	GHashTable *current_hash_procedures = current_program -> program_procedures;
	Procedure *procedure_to_add_local = g_hash_table_lookup(current_hash_procedures, (gpointer) current_state -> current_procedure_name );

	if ( procedure_to_add_local == NULL ) {

		print_error_and_exit( fran_error, " method not found " );

	}

	if ( g_hash_table_lookup( procedure_to_add_local -> procedure_params, (gpointer) var_name ) != NULL ) {

		print_error_and_exit( duplicate_local_parameter, var_name );

	} else if ( g_hash_table_lookup( procedure_to_add_local -> procedure_vars, (gpointer) var_name ) != NULL ) {

		print_error_and_exit( duplicate_var, var_name );

	} else {
		
		Variable *new_local_var = g_slice_new( Variable );
		new_local_var -> var_type = var_type;
		new_local_var -> var_modifier = var_modifier;
		g_hash_table_insert( procedure_to_add_local -> procedure_vars, (gpointer) var_name, (gpointer) new_local_var ); 

	}

}

// helper functions to know the current status of fran and for debugging purposes

void print_program_vars( gpointer key, gpointer value, gpointer user_data ) {
	
	Variable *var = (Variable * ) value;
	printf (user_data, (char *)key, f_type_names[ var -> var_type ], f_modifier_names[ var -> var_modifier ]);

}

void print_program_proc( gpointer key, gpointer value, gpointer user_data ) {
	
	Procedure *proc = (Procedure * ) value;
	printf (user_data, (char *)key, f_type_names[ proc -> proc_type ] );

	printf( "param vars:\n\n" );
	g_hash_table_foreach( proc -> procedure_params, (GHFunc) print_program_vars, "var: '%s' type: '%s' modifier: '%s'\n" );

	printf( "local vars:\n\n" );
	g_hash_table_foreach( proc -> procedure_vars, (GHFunc) print_program_vars, "var: '%s' type: '%s' modifier: '%s'\n" );

}


void print_programs( gpointer key, gpointer value, gpointer user_data ) {

	printf(user_data, (char *)key);

	Fran_Program *current_program = (Fran_Program * ) value;
	printf( "global vars:\n\n" );
	g_hash_table_foreach( current_program -> program_vars, (GHFunc) print_program_vars, "var: '%s' type: '%s' modifier: '%s'\n" );

	printf( "program functions:\n\n" );
	g_hash_table_foreach( current_program -> program_procedures, (GHFunc) print_program_proc, "proc: '%s' type: '%s'\n" );

}

void print_fran_final_status() {

	printf ( "Compilation succed : final status:\n" );
	g_hash_table_foreach( fran_programs, (GHFunc) print_programs, "Program '%s':\n" );

}