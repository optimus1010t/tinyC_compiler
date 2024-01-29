%{
    #include <iostream>
    #include "tinyC_translator.h"
    using namespace std;

    extern int yylex();         
    void yyerror(string s);     
    extern char* yytext;        
    extern int yylineno;        
    extern int nextInstr;                   // Used for keeping track of the next instruction
    extern quadArray qArr;              // List of all quads
    extern symbolTable globalST;            // Global symbol table
    extern symbolTable* ST;                 // Pointer to the current symbol table
    extern vector<string> stringConsts;     // List of all string constants
    int strCount = 0;                       // Counter for string constants    
%}

%union {
    int integral_value;                 // for integer val
    float floating_value;               // for float val
    char character_value;               // for char val
    void *ptr;                          // for pointer
    string *str;                        // for string
    symbolType* symType;                // for symbol type
    symbol* symp;                       // for symbol
    DataType types;                     // for type of expression
    opcode opc;                         // for opcode
    expression* expr;                   // for expression
    declaration* dec;                   // for declaration
    vector<declaration*> *decList;      // for declaration list
    param *prm;                         // for parameter
    vector<param*> *prmList;            // for parameter list
}

// tokens
%token AUTO BREAK CASE CHAR CONST CONTINUE DEFAULT DO DOUBLE ELSE ENUM EXTERN FLOAT FOR GOTO_ IF INLINE INT LONG REGISTER RESTRICT RETURN_ SHORT SIGNED SIZEOF STATIC STRUCT SWITCH TYPEDEF UNION UNSIGNED VOID VOLATILE WHILE _BOOL _COMPLEX _IMAGINARY
%token LEFT_SQUARE_BRACKET RIGHT_SQUARE_BRACKET LEFT_PARENTHESES RIGHT_PARENTHESES LEFT_CURLY_BRACKET RIGHT_CURLY_BRACKET INCREMENT DECREMENT DOT
%token COMMA
%token BITWISE_AND BITWISE_NOT EXCLAMATION MINUS PLUS ASTERISK
%token MODULO SLASH
%token LEFT_SHIFT RIGHT_SHIFT
%token LESS_THAN GREATER_THAN LESS_EQUAL_THAN GREATER_EQUAL_THAN
%token EQUALS NOT_EQUALS BITWISE_OR BITWISE_XOR LOGICAL_AND LOGICAL_OR
%token QUESTION_MARK COLON
%token ASSIGNMENT ASTERISK_ASSIGNMENT SLASH_ASSIGNMENT MODULO_ASSIGNMENT PLUS_ASSIGNMENT MINUS_ASSIGNMENT LEFT_SHIFT_ASSIGNMENT RIGHT_SHIFT_ASSIGNMENT BITWISE_AND_ASSIGNMENT BITWISE_OR_ASSIGNMENT BITWISE_XOR_ASSIGNMENT
%token ARROW SEMI_COLON ELLIPSIS HASH INVALID_TOKEN

%token <str> IDENTIFIER

%token <integral_value> INTEGER_CONSTANT

%token <floating_value> FLOATING_CONSTANT

%token <character_value> CHARACTER_CONSTANT

%token <str> STRING_LITERAL

// Non-terminals of type expr (denoting expressions)
%type <expr> 
        expression
        primary_expression 
        multiplicative_expression
        additive_expression
        shift_expression
        relational_expression
        equality_expression
        AND_expression
        exclusive_OR_expression
        inclusive_OR_expression
        logical_AND_expression
        logical_OR_expression
        conditional_expression
        assignment_expression
        postfix_expression
        unary_expression
        cast_expression
        expression_statement
        statement
        compound_statement
        selection_statement
        iteration_statement
        labeled_statement 
        jump_statement
        block_item
        block_item_list
        initializer
        M
        N

// Non-terminals of type charval (unary operator)
%type <character_value> unary_operator

// The pointer non-terminal is treated with type intval
%type <integral_value> pointer

// Non-terminals of type DataType (denoting types)
%type <types> type_specifier declaration_specifiers

// Non-terminals of type declaration
%type <dec> direct_declarator initializer_list init_declarator declarator function_prototype

// Non-terminals of type decList
%type <decList> init_declarator_list

// Non-terminals of type param
%type <prm> parameter_declaration

// Non-terminals of type prmList
%type <prmList> parameter_list parameter_type_list parameter_type_list_opt argument_expression_list

// to remove the dangling else problem
%expect 1
%nonassoc ELSE

// The start symbol is translation_unit
%start translation_unit

%%

primary_expression: 
        IDENTIFIER
        {
            $$ = new expression();
            string s = *($1);
            ST->lookup(s);              // store entry in symbol table
            $$->loc = s;                // store pointer to string identifier name
        }
        |
        INTEGER_CONSTANT
        {
            $$ = new expression();
            $$->loc = ST->gentemp(TYPE_INT);   // Create a new temporary, and store the value in that temporary
            emit($$->loc, $1, ASSIGN);
            symbolValue* val = new symbolValue();
            val->setInitVal($1);
            ST->lookup($$->loc)->initVal = val;
        }
        | FLOATING_CONSTANT
        {
            $$ = new expression();
            $$->loc = ST->gentemp(TYPE_FLOAT); // Create a new temporary, and store the value in that temporary
            emit($$->loc, $1, ASSIGN);
            symbolValue* val = new symbolValue();
            val->setInitVal($1);
            ST->lookup($$->loc)->initVal = val;
        }
        | CHARACTER_CONSTANT
        {
            $$ = new expression();
            $$->loc = ST->gentemp(TYPE_CHAR);  // Create a new temporary, and store the value in that temporary
            emit($$->loc, $1, ASSIGN);
            symbolValue* val = new symbolValue();
            val->setInitVal($1);
            ST->lookup($$->loc)->initVal = val;
        }
        | STRING_LITERAL
        {
            $$ = new expression();  
            $$->loc = ".LC" + to_string(strCount++);   
            stringConsts.push_back(*($1));             // Store the string in the list of string constants
        }
        | LEFT_PARENTHESES expression RIGHT_PARENTHESES
        {
            $$ = $2;    
        }
        ;


postfix_expression: 
        primary_expression
        {
            
        }
        | postfix_expression LEFT_SQUARE_BRACKET expression RIGHT_SQUARE_BRACKET
        {
            symbolType to = ST->lookup($1->loc)->type;      // get the type of the expression
            string f="";
            if(!($1->fold))
            {
                f=ST->gentemp(TYPE_INT);                    // generate a new temporary variable
                emit(f, 0 , ASSIGN);
                $1->folder = new string(f);
            }
            string tmp = ST->gentemp(TYPE_INT);

            emit(tmp, $3->loc, "", ASSIGN);
            emit(tmp, tmp, "4", MULT);
            emit(f, tmp, "", ASSIGN);
            $$ = $1;
        }
        | postfix_expression LEFT_PARENTHESES RIGHT_PARENTHESES
        {   
            // corresponds to calling a function with the function name with zero arguments
            symbolTable* funcTable = globalST.lookup($1->loc)->nestedTable;
            emit($1->loc, "0", "", CALL);
        }
        | postfix_expression LEFT_PARENTHESES argument_expression_list RIGHT_PARENTHESES
        {   
            // corresponds to calling a function with the function name and the appropriate number of parameters
            symbolTable* funcTable = globalST.lookup($1->loc)->nestedTable;
            vector<param*> parameters = *($3);                          // list of parameters
            vector<symbol*> paramsList = funcTable->symbols;

            for(int i = 0; i < (int)parameters.size(); i++) {
                emit(parameters[i]->name, "", "", PARAM);               // emit the parameters
            }

            DataType returnType = funcTable->lookup("RETVAL")->type.type;  // add an entry in the symbol table for the return value
            if(returnType == TYPE_VOID)                                         // if the function returns void
                emit($1->loc, (int)parameters.size(), CALL);
            else {                                                      // if the function returns a value
                string returnVal = ST->gentemp(returnType);
                emit($1->loc, to_string(parameters.size()), returnVal, CALL);
                $$ = new expression();
                $$->loc = returnVal;
            }
        }
        | postfix_expression DOT IDENTIFIER
        {/* ignored */}
        | postfix_expression ARROW IDENTIFIER
        {/* ignored */}
        | postfix_expression INCREMENT
        {   
            $$ = new expression();
            symbolType t = ST->lookup($1->loc)->type;                       // get type of the expression and generate a temporary variable
            if(t.type == TYPE_ARR) {
                $$->loc = ST->gentemp(ST->lookup($1->loc)->type.nextType);
                emit($$->loc, $1->loc, *($1->folder), ARR_IDX_ARG);
                string tmp = ST->gentemp(t.nextType);
                emit(tmp, $1->loc, *($1->folder), ARR_IDX_ARG);
                emit(tmp, tmp, "1", ADD);
                emit($1->loc, tmp, *($1->folder), ARR_IDX_RES);
            }
            else {
                $$->loc = ST->gentemp(ST->lookup($1->loc)->type.type);
                emit($$->loc, $1->loc, "", ASSIGN);                         // assign old value 
                emit($1->loc, $1->loc, "1", ADD);                           // increment the value
            }
        }
        | postfix_expression DECREMENT
        {
            $$ = new expression();
            $$->loc = ST->gentemp(ST->lookup($1->loc)->type.type);          // generate a temporary variable
            symbolType t = ST->lookup($1->loc)->type;
            if(t.type == TYPE_ARR) {
                $$->loc = ST->gentemp(ST->lookup($1->loc)->type.nextType);
                string tmp = ST->gentemp(t.nextType);
                emit(tmp, $1->loc, *($1->folder), ARR_IDX_ARG);
                emit($$->loc, tmp, "", ASSIGN);
                emit(tmp, tmp, "1", SUB);
                emit($1->loc, tmp, *($1->folder), ARR_IDX_RES);
            }
            else {
                $$->loc = ST->gentemp(ST->lookup($1->loc)->type.type);
                emit($$->loc, $1->loc, "", ASSIGN);                         // assign old value
                emit($1->loc, $1->loc, "1", SUB);                           // decrement the value
            }
        }
        | LEFT_PARENTHESES type_name RIGHT_PARENTHESES LEFT_CURLY_BRACKET initializer_list RIGHT_CURLY_BRACKET
        {/* ignored */}
        | LEFT_PARENTHESES type_name RIGHT_PARENTHESES LEFT_CURLY_BRACKET initializer_list COMMA RIGHT_CURLY_BRACKET
        {/* ignored */}
        ;

argument_expression_list: 
        assignment_expression
        {
            param* first = new param();
            first->name = $1->loc;
            first->type = ST->lookup($1->loc)->type;
            $$ = new vector<param*>;
            $$->push_back(first);                       // add the new parameter to the list
        }
        | argument_expression_list COMMA assignment_expression
        {
            param* next = new param();
            next->name = $3->loc;
            next->type = ST->lookup(next->name)->type;
            $$ = $1;
            $$->push_back(next);                        // add the new parameter to the list
        }
        ;

unary_expression: 
        postfix_expression
        {/* ignored */}
        | INCREMENT unary_expression
        {
            $$ = new expression();
            symbolType type = ST->lookup($2->loc)->type;
            if(type.type == TYPE_ARR) {
                string t = ST->gentemp(type.nextType);
                emit(t, $2->loc, *($2->folder), ARR_IDX_ARG);
                emit(t, t, "1", ADD);
                emit($2->loc, t, *($2->folder), ARR_IDX_RES);
                $$->loc = ST->gentemp(ST->lookup($2->loc)->type.nextType);
            }
            else {
                emit($2->loc, $2->loc, "1", ADD);                       // increment the value
                $$->loc = ST->gentemp(ST->lookup($2->loc)->type.type);
            }
            $$->loc = ST->gentemp(ST->lookup($2->loc)->type.type);
            emit($$->loc, $2->loc, "", ASSIGN);                         // assign the value
        }
        | DECREMENT unary_expression
        {
            $$ = new expression();
            symbolType type = ST->lookup($2->loc)->type;
            if(type.type == TYPE_ARR) {
                string t = ST->gentemp(type.nextType);
                emit(t, $2->loc, *($2->folder), ARR_IDX_ARG);
                emit(t, t, "1", SUB);
                emit($2->loc, t, *($2->folder), ARR_IDX_RES);
                $$->loc = ST->gentemp(ST->lookup($2->loc)->type.nextType);
            }
            else {
                emit($2->loc, $2->loc, "1", SUB);                       // decrement the value
                $$->loc = ST->gentemp(ST->lookup($2->loc)->type.type);
            }
            emit($$->loc, $2->loc, "", ASSIGN);                         // assign the value
        }
        | unary_operator cast_expression
        {
            // Case of unary operator
            switch($1) {
                case '&':   // Address
                    $$ = new expression();
                    $$->loc = ST->gentemp(TYPE_PTR);                 // Generate temporary of the same base type
                    emit($$->loc, $2->loc, "", REF);          // emit the quad
                    break;
                case '*':   // De-referencing
                    $$ = new expression();
                    $$->loc = ST->gentemp(TYPE_INT);                     // Generate temporary of the same base type
                    $$->fold = 1;
                    $$->folder = new string($2->loc);
                    emit($$->loc, $2->loc, "", DEREF);        // emit the quad
                    break;
                case '-':   // Unary minus
                    $$ = new expression();
                    $$->loc = ST->gentemp();                        // Generate temporary of the same base type
                    emit($$->loc, $2->loc, "", U_MINUS);            // emit the quad
                    break;
                case '!':   // Logical not 
                    $$ = new expression();
                    $$->loc = ST->gentemp(TYPE_INT);                     // Generate temporary of the same base type
                    int temp = nextInstr + 2;
                    emit(to_string(temp), $2->loc, "0", GOTO_EQ);   // emit the quads
                    temp = nextInstr + 3;
                    emit(to_string(temp), "", "", GOTO);
                    emit($$->loc, "1", "", ASSIGN);
                    temp = nextInstr + 2;
                    emit(to_string(temp), "", "", GOTO);
                    emit($$->loc, "0", "", ASSIGN);
                    break;
            }
        }
        | SIZEOF unary_expression
        {/* ignored */}
        | SIZEOF LEFT_PARENTHESES type_name RIGHT_PARENTHESES
        {/* ignored */}
        ;

unary_operator:
        BITWISE_AND
        {
            $$ = '&';
        }
        | ASTERISK
        {
            $$ = '*';
        }
        | PLUS
        {
            $$ = '+';
        }
        | MINUS
        {
            $$ = '-';
        }
        | BITWISE_NOT
        {
            $$ = '~';
        }
        | EXCLAMATION
        {
            $$ = '!';
        }
        ;

cast_expression: 
        unary_expression
        {/* ignored */}
        | LEFT_PARENTHESES type_name RIGHT_PARENTHESES cast_expression
        {/* ignored */}
        ;

multiplicative_expression: 
        cast_expression
        {
            $$ = new expression();                                  // generate new expression
            symbolType tp = ST->lookup($1->loc)->type;
            if(tp.type == TYPE_ARR) {                                  // if the type is an array
                string t = ST->gentemp(tp.nextType);                // generate a temporary
                if($1->folder != NULL) {
                    emit(t, $1->loc, *($1->folder), ARR_IDX_ARG);   // emit the necessary quad
                    $1->loc = t;
                    $1->type = tp.nextType;
                    $$ = $1;
                }
                else
                    $$ = $1;        
            }
            else
                $$ = $1;            
        }
        | multiplicative_expression ASTERISK cast_expression
        {   
            // multiplication
            $$ = new expression();
            symbol* one = ST->lookup($1->loc);                  // get the first operand from the symbol table
            symbol* two = ST->lookup($3->loc);                  // get the second operand from the symbol table
            if(two->type.type == TYPE_ARR) {                       // if the second operand is an array, perform necessary operations
                string t = ST->gentemp(two->type.nextType);
                emit(t, $3->loc, *($3->folder), ARR_IDX_ARG);
                $3->loc = t;
                $3->type = two->type.nextType;
            }
            if(one->type.type == TYPE_ARR) {                       // if the first operand is an array, perform necessary operations
                string t = ST->gentemp(one->type.nextType);
                emit(t, $1->loc, *($1->folder), ARR_IDX_ARG);
                $1->loc = t;
                $1->type = one->type.nextType;
            }

            // assign the result of the multiplication to the higher data type
            DataType final = ((one->type.type > two->type.type) ? (one->type.type) : (two->type.type));
            $$->loc = ST->gentemp(final);                       // store the final result in a temporary
            emit($$->loc, $1->loc, $3->loc, MULT);
        }
        | multiplicative_expression SLASH cast_expression
        {
            // division
            $$ = new expression();
            symbol* one = ST->lookup($1->loc);                  // get the first operand from the symbol table
            symbol* two = ST->lookup($3->loc);                  // get the second operand from the symbol table
            if(two->type.type == TYPE_ARR) {                       // if the second operand is an array, perform necessary operations
                string t = ST->gentemp(two->type.nextType);
                emit(t, $3->loc, *($3->folder), ARR_IDX_ARG);
                $3->loc = t;
                $3->type = two->type.nextType;
            }
            if(one->type.type == TYPE_ARR) {                       // if the first operand is an array, perform necessary operations
                string t = ST->gentemp(one->type.nextType);
                emit(t, $1->loc, *($1->folder), ARR_IDX_ARG);
                $1->loc = t;
                $1->type = one->type.nextType;
            }

            // assign the result of the division to the higher data type
            DataType final = ((one->type.type > two->type.type) ? (one->type.type) : (two->type.type));
            $$->loc = ST->gentemp(final);                       // store the final result in a temporary
            emit($$->loc, $1->loc, $3->loc, DIV);
        }
        | multiplicative_expression MODULO cast_expression
        {
            // modulo
            $$ = new expression();
            symbol* one = ST->lookup($1->loc);                  // get the first operand from the symbol table
            symbol* two = ST->lookup($3->loc);                  // get the second operand from the symbol table
            if(two->type.type == TYPE_ARR) {                       // if the second operand is an array, perform necessary operations
                string t = ST->gentemp(two->type.nextType);
                emit(t, $3->loc, *($3->folder), ARR_IDX_ARG);
                $3->loc = t;
                $3->type = two->type.nextType;
            }
            if(one->type.type == TYPE_ARR) {                       // if the first operand is an array, perform necessary operations
                string t = ST->gentemp(one->type.nextType);
                emit(t, $1->loc, *($1->folder), ARR_IDX_ARG);
                $1->loc = t;
                $1->type = one->type.nextType;
            }

            // assign the result of the modulo to the higher data type
            DataType final = ((one->type.type > two->type.type) ? (one->type.type) : (two->type.type));
            $$->loc = ST->gentemp(final);                       // store the final result in a temporary
            emit($$->loc, $1->loc, $3->loc, MOD);
        }
        ;

additive_expression: 
        multiplicative_expression
        {/* ignored */}
        | additive_expression PLUS multiplicative_expression
        {   
            // addition
            $$ = new expression();
            symbol* one = ST->lookup($1->loc);                  // get the first operand from the symbol table
            symbol* two = ST->lookup($3->loc);                  // get the second operand from the symbol table
            if(two->type.type == TYPE_ARR) {                       // if the second operand is an array, perform necessary operations
                string t = ST->gentemp(two->type.nextType);
                emit(t, $3->loc, *($3->folder), ARR_IDX_ARG);
                $3->loc = t;
                $3->type = two->type.nextType;
            }
            if(one->type.type == TYPE_ARR) {                       // if the first operand is an array, perform necessary operations
                string t = ST->gentemp(one->type.nextType);
                emit(t, $1->loc, *($1->folder), ARR_IDX_ARG);
                $1->loc = t;
                $1->type = one->type.nextType;
            }

            // assign the result of the addition to the higher data type
            DataType final = ((one->type.type > two->type.type) ? (one->type.type) : (two->type.type));
            $$->loc = ST->gentemp(final);                       // store the final result in a temporary
            emit($$->loc, $1->loc, $3->loc, ADD);
        }
        | additive_expression MINUS multiplicative_expression
        {
            // subtraction
            $$ = new expression();
            symbol* one = ST->lookup($1->loc);                  // get the first operand from the symbol table
            symbol* two = ST->lookup($3->loc);                  // get the second operand from the symbol table
            if(two->type.type == TYPE_ARR) {                       // if the second operand is an array, perform necessary operations
                string t = ST->gentemp(two->type.nextType);
                emit(t, $3->loc, *($3->folder), ARR_IDX_ARG);
                $3->loc = t;
                $3->type = two->type.nextType;
            }
            if(one->type.type == TYPE_ARR) {                       // if the first operand is an array, perform necessary operations
                string t = ST->gentemp(one->type.nextType);
                emit(t, $1->loc, *($1->folder), ARR_IDX_ARG);
                $1->loc = t;
                $1->type = one->type.nextType;
            }

            // assign the result of the subtraction to the higher data type
            DataType final = ((one->type.type > two->type.type) ? (one->type.type) : (two->type.type));
            $$->loc = ST->gentemp(final);                       // store the final result in a temporary
            emit($$->loc, $1->loc, $3->loc, SUB);
        }
        ;

shift_expression: 
        additive_expression
        {/* ignored */}
        | shift_expression LEFT_SHIFT additive_expression
        {
            // left shift
            $$ = new expression();
            symbol* one = ST->lookup($1->loc);                  // get the first operand from the symbol table
            symbol* two = ST->lookup($3->loc);                  // get the second operand from the symbol table
            if(two->type.type == TYPE_ARR) {                       // if the second operand is an array, perform necessary operations
                string t = ST->gentemp(two->type.nextType);
                emit(t, $3->loc, *($3->folder), ARR_IDX_ARG);
                $3->loc = t;
                $3->type = two->type.nextType;
            }
            if(one->type.type == TYPE_ARR) {                       // if the first operand is an array, perform necessary operations
                string t = ST->gentemp(one->type.nextType);
                emit(t, $1->loc, *($1->folder), ARR_IDX_ARG);
                $1->loc = t;
                $1->type = one->type.nextType;
            }
            $$->loc = ST->gentemp(one->type.type);              // assign the result of the left shift to the data type of the left operand
            emit($$->loc, $1->loc, $3->loc, SL);
        }
        | shift_expression RIGHT_SHIFT additive_expression
        {
            // right shift
            $$ = new expression();
            symbol* one = ST->lookup($1->loc);                  // get the first operand from the symbol table
            symbol* two = ST->lookup($3->loc);                  // get the second operand from the symbol table
            if(two->type.type == TYPE_ARR) {                       // if the second operand is an array, perform necessary operations
                string t = ST->gentemp(two->type.nextType);
                emit(t, $3->loc, *($3->folder), ARR_IDX_ARG);
                $3->loc = t;
                $3->type = two->type.nextType;
            }
            if(one->type.type == TYPE_ARR) {                       // if the first operand is an array, perform necessary operations
                string t = ST->gentemp(one->type.nextType);
                emit(t, $1->loc, *($1->folder), ARR_IDX_ARG);
                $1->loc = t;
                $1->type = one->type.nextType;
            }
            $$->loc = ST->gentemp(one->type.type);              // assign the result of the right shift to the data type of the left operand
            emit($$->loc, $1->loc, $3->loc, SR);
        }
        ;

relational_expression: 
        shift_expression
        {/* ignored */}
        | relational_expression LESS_THAN shift_expression
        {
            $$ = new expression();
            symbol* one = ST->lookup($1->loc);                  // get the first operand from the symbol table
            symbol* two = ST->lookup($3->loc);                  // get the second operand from the symbol table
            if(two->type.type == TYPE_ARR) {                       // if the second operand is an array, perform necessary operations
                string t = ST->gentemp(two->type.nextType);
                emit(t, $3->loc, *($3->folder), ARR_IDX_ARG);
                $3->loc = t;
                $3->type = two->type.nextType;
            }
            if(one->type.type == TYPE_ARR) {                       // if the first operand is an array, perform necessary operations
                string t = ST->gentemp(one->type.nextType);
                emit(t, $1->loc, *($1->folder), ARR_IDX_ARG);
                $1->loc = t;
                $1->type = one->type.nextType;
            }
            $$ = new expression();
            $$->loc = ST->gentemp();
            $$->type = TYPE_BOOL;                                    // assign the result of the relational expression to a boolean
            emit($$->loc, "1", "", ASSIGN);
            $$->trueList = makelist(nextInstr);                 // set the trueList to the next instruction
            emit("", $1->loc, $3->loc, GOTO_LT);                // emit "if x < y goto ..."
            emit($$->loc, "0", "", ASSIGN);
            $$->falseList = makelist(nextInstr);                // set the falseList to the next instruction
            emit("", "", "", GOTO);                             // emit "goto ..."
        }
        | relational_expression GREATER_THAN shift_expression
        {
            $$ = new expression();
            symbol* one = ST->lookup($1->loc);                  // get the first operand from the symbol table
            symbol* two = ST->lookup($3->loc);                  // get the second operand from the symbol table
            if(two->type.type == TYPE_ARR) {                       // if the second operand is an array, perform necessary operations
                string t = ST->gentemp(two->type.nextType);
                emit(t, $3->loc, *($3->folder), ARR_IDX_ARG);
                $3->loc = t;
                $3->type = two->type.nextType;
            }
            if(one->type.type == TYPE_ARR) {                       // if the first operand is an array, perform necessary operations
                string t = ST->gentemp(one->type.nextType);
                emit(t, $1->loc, *($1->folder), ARR_IDX_ARG);
                $1->loc = t;
                $1->type = one->type.nextType;
            }
            $$ = new expression();
            $$->loc = ST->gentemp();
            $$->type = TYPE_BOOL;                                    // assign the result of the relational expression to a boolean
            emit($$->loc, "1", "", ASSIGN);
            $$->trueList = makelist(nextInstr);                 // set the trueList to the next instruction
            emit("", $1->loc, $3->loc, GOTO_GT);                // emit "if x > y goto ..."
            emit($$->loc, "0", "", ASSIGN);
            $$->falseList = makelist(nextInstr);                // set the falseList to the next instruction
            emit("", "", "", GOTO);                             // emit "goto ..."
        }
        | relational_expression LESS_EQUAL_THAN shift_expression
        {
            $$ = new expression();
            symbol* one = ST->lookup($1->loc);                  // get the first operand from the symbol table
            symbol* two = ST->lookup($3->loc);                  // get the second operand from the symbol table
            if(two->type.type == TYPE_ARR) {                       // if the second operand is an array, perform necessary operations
                string t = ST->gentemp(two->type.nextType);
                emit(t, $3->loc, *($3->folder), ARR_IDX_ARG);
                $3->loc = t;
                $3->type = two->type.nextType;
            }
            if(one->type.type == TYPE_ARR) {                       // if the first operand is an array, perform necessary operations
                string t = ST->gentemp(one->type.nextType);
                emit(t, $1->loc, *($1->folder), ARR_IDX_ARG);
                $1->loc = t;
                $1->type = one->type.nextType;
            }
            $$ = new expression();
            $$->loc = ST->gentemp();
            $$->type = TYPE_BOOL;                                    // assign the result of the relational expression to a boolean
            emit($$->loc, "1", "", ASSIGN);
            $$->trueList = makelist(nextInstr);                 // set the trueList to the next instruction
            emit("", $1->loc, $3->loc, GOTO_LTE);               // emit "if x <= y goto ..."
            emit($$->loc, "0", "", ASSIGN);
            $$->falseList = makelist(nextInstr);                // set the falseList to the next instruction
            emit("", "", "", GOTO);                             // emit "goto ..."
        }
        | relational_expression GREATER_EQUAL_THAN shift_expression
        {
            $$ = new expression();
            symbol* one = ST->lookup($1->loc);                  // get the first operand from the symbol table
            symbol* two = ST->lookup($3->loc);                  // get the second operand from the symbol table
            if(two->type.type == TYPE_ARR) {                       // if the second operand is an array, perform necessary operations
                string t = ST->gentemp(two->type.nextType);
                emit(t, $3->loc, *($3->folder), ARR_IDX_ARG);
                $3->loc = t;
                $3->type = two->type.nextType;
            }
            if(one->type.type == TYPE_ARR) {                       // if the first operand is an array, perform necessary operations
                string t = ST->gentemp(one->type.nextType);
                emit(t, $1->loc, *($1->folder), ARR_IDX_ARG);
                $1->loc = t;
                $1->type = one->type.nextType;
            }
            $$ = new expression();
            $$->loc = ST->gentemp();
            $$->type = TYPE_BOOL;                                    // assign the result of the relational expression to a boolean
            emit($$->loc, "1", "", ASSIGN);
            $$->trueList = makelist(nextInstr);                 // set the trueList to the next instruction
            emit("", $1->loc, $3->loc, GOTO_GTE);               // emit "if x >= y goto ..."
            emit($$->loc, "0", "", ASSIGN);
            $$->falseList = makelist(nextInstr);                // set the falseList to the next instruction
            emit("", "", "", GOTO);                             // emit "goto ..."
        }
        ;

equality_expression: 
        relational_expression
        {
            $$ = new expression();
            $$ = $1;    
        }
        | equality_expression EQUALS relational_expression
        {
            $$ = new expression();
            symbol* one = ST->lookup($1->loc);                  // get the first operand from the symbol table
            symbol* two = ST->lookup($3->loc);                  // get the second operand from the symbol table
            if(two->type.type == TYPE_ARR) {                       // if the second operand is an array, perform necessary operations
                string t = ST->gentemp(two->type.nextType);
                emit(t, $3->loc, *($3->folder), ARR_IDX_ARG);
                $3->loc = t;
                $3->type = two->type.nextType;
            }
            if(one->type.type == TYPE_ARR) {                       // if the first operand is an array, perform necessary operations
                string t = ST->gentemp(one->type.nextType);
                emit(t, $1->loc, *($1->folder), ARR_IDX_ARG);
                $1->loc = t;
                $1->type = one->type.nextType;
            }
            $$ = new expression();
            $$->loc = ST->gentemp();
            $$->type = TYPE_BOOL;                                    // assign the result of the relational expression to a boolean
            emit($$->loc, "1", "", ASSIGN);
            $$->trueList = makelist(nextInstr);                 // set the trueList to the next instruction
            emit("", $1->loc, $3->loc, GOTO_EQ);                // emit "if x == y goto ..."
            emit($$->loc, "0", "", ASSIGN);
            $$->falseList = makelist(nextInstr);                // set the falseList to the next instruction
            emit("", "", "", GOTO);                             // emit "goto ..."
        }
        | equality_expression NOT_EQUALS relational_expression
        {
            $$ = new expression();
            symbol* one = ST->lookup($1->loc);                  // get the first operand from the symbol table
            symbol* two = ST->lookup($3->loc);                  // get the second operand from the symbol table
            if(two->type.type == TYPE_ARR) {                       // if the second operand is an array, perform necessary operations
                string t = ST->gentemp(two->type.nextType);
                emit(t, $3->loc, *($3->folder), ARR_IDX_ARG);
                $3->loc = t;
                $3->type = two->type.nextType;
            }
            if(one->type.type == TYPE_ARR) {                       // if the first operand is an array, perform necessary operations
                string t = ST->gentemp(one->type.nextType);
                emit(t, $1->loc, *($1->folder), ARR_IDX_ARG);
                $1->loc = t;
                $1->type = one->type.nextType;
            }
            $$ = new expression();
            $$->loc = ST->gentemp();
            $$->type = TYPE_BOOL;                                    // assign the result of the relational expression to a boolean
            emit($$->loc, "1", "", ASSIGN);
            $$->trueList = makelist(nextInstr);                 // set the trueList to the next instruction
            emit("", $1->loc, $3->loc, GOTO_NEQ);               // emit "if x != y goto ..."
            emit($$->loc, "0", "", ASSIGN);
            $$->falseList = makelist(nextInstr);                // set the falseList to the next instruction
            emit("", "", "", GOTO);                             // emit "goto ..."
        }
        ;

AND_expression: 
        equality_expression
        {/* ignored */}
        | AND_expression BITWISE_AND equality_expression
        {
            $$ = new expression();
            symbol* one = ST->lookup($1->loc);                  // get the first operand from the symbol table
            symbol* two = ST->lookup($3->loc);                  // get the second operand from the symbol table
            if(two->type.type == TYPE_ARR) {                       // if the second operand is an array, perform necessary operations
                string t = ST->gentemp(two->type.nextType);
                emit(t, $3->loc, *($3->folder), ARR_IDX_ARG);
                $3->loc = t;
                $3->type = two->type.nextType;
            }
            if(one->type.type == TYPE_ARR) {                       // if the first operand is an array, perform necessary operations
                string t = ST->gentemp(one->type.nextType);
                emit(t, $1->loc, *($1->folder), ARR_IDX_ARG);
                $1->loc = t;
                $1->type = one->type.nextType;
            }
            $$ = new expression();
            $$->loc = ST->gentemp();                            // create a temporary variable to store the result
            emit($$->loc, $1->loc, $3->loc, BIT_AND);            // emit the quad
        }
        ;

exclusive_OR_expression: 
        AND_expression
        {
            $$ = $1;    
        }
        | exclusive_OR_expression BITWISE_XOR AND_expression
        {
            $$ = new expression();
            symbol* one = ST->lookup($1->loc);                  // get the first operand from the symbol table
            symbol* two = ST->lookup($3->loc);                  // get the second operand from the symbol table
            if(two->type.type == TYPE_ARR) {                       // if the second operand is an array, perform necessary operations
                string t = ST->gentemp(two->type.nextType);
                emit(t, $3->loc, *($3->folder), ARR_IDX_ARG);
                $3->loc = t;
                $3->type = two->type.nextType;
            }
            if(one->type.type == TYPE_ARR) {                       // if the first operand is an array, perform necessary operations
                string t = ST->gentemp(one->type.nextType);
                emit(t, $1->loc, *($1->folder), ARR_IDX_ARG);
                $1->loc = t;
                $1->type = one->type.nextType;
            }
            $$ = new expression();
            $$->loc = ST->gentemp();                            // create a temporary variable to store the result
            emit($$->loc, $1->loc, $3->loc, BIT_XOR);            // emit the quad
        }
        ;

inclusive_OR_expression: 
        exclusive_OR_expression
        {
            $$ = new expression();
            $$ = $1;    
        }
        | inclusive_OR_expression BITWISE_OR exclusive_OR_expression
        {
            $$ = new expression();
            symbol* one = ST->lookup($1->loc);                  // get the first operand from the symbol table
            symbol* two = ST->lookup($3->loc);                  // get the second operand from the symbol table
            if(two->type.type == TYPE_ARR) {                       // if the second operand is an array, perform necessary operations
                string t = ST->gentemp(two->type.nextType);
                emit(t, $3->loc, *($3->folder), ARR_IDX_ARG);
                $3->loc = t;
                $3->type = two->type.nextType;
            }
            if(one->type.type == TYPE_ARR) {                       // if the first operand is an array, perform necessary operations
                string t = ST->gentemp(one->type.nextType);
                emit(t, $1->loc, *($1->folder), ARR_IDX_ARG);
                $1->loc = t;
                $1->type = one->type.nextType;
            }
            $$ = new expression();
            $$->loc = ST->gentemp();                            // create a temporary variable to store the result
            emit($$->loc, $1->loc, $3->loc, BIT_OR);             // emit the quad
        }
        ;

logical_AND_expression: 
        inclusive_OR_expression
        {/* ignored */}
        | logical_AND_expression LOGICAL_AND M inclusive_OR_expression
        {
            // Here, we have augmented the grammar with the non-terminal M to facilitate backpatching
            backpatch($1->trueList, $3->instr);                     // Backpatching
            $$->falseList = merge($1->falseList, $4->falseList);    // Generate falseList by merging the falselists of $1 and $4
            $$->trueList = $4->trueList;                            // Generate trueList from trueList of $4
            $$->type = TYPE_BOOL;                                        // Set the type of the expression to boolean
        }
        ;

logical_OR_expression: 
        logical_AND_expression
        {/* ignored */}
        | logical_OR_expression LOGICAL_OR M logical_AND_expression
        {
            backpatch($1->falseList, $3->instr);                    // Backpatching
            $$->trueList = merge($1->trueList, $4->trueList);       // Generate falseList by merging the falselists of $1 and $4
            $$->falseList = $4->falseList;                          // Generate trueList from trueList of $4
            $$->type = TYPE_BOOL;                                        // Set the type of the expression to boolean
        }
        ;

conditional_expression: 
        logical_OR_expression
        {
            $$ = $1;    
        }
        | logical_OR_expression N QUESTION_MARK M expression N COLON M conditional_expression
        {   
            // Note the augmented grammar with the non-terminals M and N
            symbol* one = ST->lookup($5->loc);
            $$->loc = ST->gentemp(one->type.type);      // Create a temporary for the expression
            $$->type = one->type.type;
            emit($$->loc, $9->loc, "", ASSIGN);         // Assign the conditional expression
            list<int> temp = makelist(nextInstr);
            emit("", "", "", GOTO);                     // Prevent fall-through
            backpatch($6->nextList, nextInstr);         // Backpatch with nextInstr
            emit($$->loc, $5->loc, "", ASSIGN);
            temp = merge(temp, makelist(nextInstr));
            emit("", "", "", GOTO);                     // Prevent fall-through
            backpatch($2->nextList, nextInstr);         // Backpatch with nextInstr
            convertIntToBool($1);                       // Convert the expression to boolean
            backpatch($1->trueList, $4->instr);         // When $1 is true, control goes to $4 (expression)
            backpatch($1->falseList, $8->instr);        // When $1 is false, control goes to $8 (conditional_expression)
            backpatch($2->nextList, nextInstr);         // Backpatch with nextInstr
        }
        ;

M: %empty
        {   
            // stores next instruction number, to be backpatched later
            $$ = new expression();
            $$->instr = nextInstr;
        }
        ;

N: %empty
        {
            // helps in control flow
            $$ = new expression();
            $$->nextList = makelist(nextInstr);
            emit("", "", "", GOTO);
        }
        ;

assignment_expression: 
        conditional_expression
        {/* ignored */}
        | unary_expression assignment_operator assignment_expression
        {
            symbol* sym1 = ST->lookup($1->loc);         // get the first operand from the symbol table
            symbol* sym2 = ST->lookup($3->loc);         // get the second operand from the symbol table
            if($1->fold == 0) {
                if(sym1->type.type != TYPE_ARR)
                    emit($1->loc, $3->loc, "", ASSIGN);
                else
                    emit($1->loc, $3->loc, *($1->folder), ARR_IDX_RES);
            }
            else
                emit(*($1->folder), $3->loc, "", L_DEREF);
            $$ = $1;        // assignment
        }
        ;

assignment_operator: 
        ASSIGNMENT
        {/* ignored */}
        | ASTERISK_ASSIGNMENT
        {/* ignored */}
        | SLASH_ASSIGNMENT
        {/* ignored */}
        | MODULO_ASSIGNMENT
        {/* ignored */}
        | PLUS_ASSIGNMENT
        {/* ignored */}
        | MINUS_ASSIGNMENT
        {/* ignored */}
        | LEFT_SHIFT_ASSIGNMENT
        {/* ignored */}
        | RIGHT_SHIFT_ASSIGNMENT
        {/* ignored */}
        | BITWISE_AND_ASSIGNMENT
        {/* ignored */}
        | BITWISE_XOR_ASSIGNMENT
        {/* ignored */}
        | BITWISE_OR_ASSIGNMENT
        {/* ignored */}
        ;

expression: 
        assignment_expression
        {
            $$ = $1;
        }
        | expression COMMA assignment_expression
        {/* ignored */}
        ;

constant_expression: 
        conditional_expression
        {/* ignored */}
        ;

// Declarations

declaration: 
        declaration_specifiers SEMI_COLON
        {/* ignored */}
        | declaration_specifiers init_declarator_list SEMI_COLON
        {DataType currType = $1;
            int currSize = -1;
            // Assign correct size for the data type
            if(currType == TYPE_INT)
                currSize = size_of_int;
            else if(currType == TYPE_CHAR)
                currSize = size_of_char;
            else if(currType == TYPE_FLOAT)
                currSize = size_of_float;
            vector<declaration*> decs = *($2);
            for(vector<declaration*>::iterator it = decs.begin(); it != decs.end(); it++) {
                declaration* currDec = *it;
                if(currDec->type == TYPE_FUNC) {
                    ST = &globalST;
                    emit(currDec->name, "", "", FUNC_END);
                    symbol* one = ST->lookup(currDec->name);        // Create an entry for the function
                    symbol* two = one->nestedTable->lookup("RETVAL", currType, currDec->pointers);
                    one->size = 0;
                    one->initVal = NULL;
                    continue;
                }

                symbol* three = ST->lookup(currDec->name, currType);        // Create an entry for the variable in the symbol table
                three->nestedTable = NULL;
                if(currDec->li == vector<int>() && currDec->pointers == 0) {
                    three->type.type = currType;
                    three->size = currSize;
                    if(currDec->initVal != NULL) {
                        string rval = currDec->initVal->loc;
                        emit(three->name, rval, "", ASSIGN);
                        three->initVal = ST->lookup(rval)->initVal;
                    }
                    else
                        three->initVal = NULL;
                }
                else if(currDec->li != vector<int>()) {         // Handle array types
                    three->type.type = TYPE_ARR;
                    three->type.nextType = currType;
                    three->type.dims = currDec->li;
                    vector<int> temp = three->type.dims;
                    int sz = currSize;
                    for(int i = 0; i < (int)temp.size(); i++)
                        sz *= temp[i];
                    ST->offset += sz;
                    three->size = sz;
                    ST->offset -= 4;
                }
                else if(currDec->pointers != 0) {               // Handle pointer types
                    three->type.type = TYPE_PTR;
                    three->type.nextType = currType;
                    three->type.pointers = currDec->pointers;
                    ST->offset += (size_of_ptr - currSize);
                    three->size = size_of_ptr;
                }
            }}
        ;

declaration_specifiers: 
        storage_class_specifier declaration_specifiers
        {}
        |storage_class_specifier
        {}
        | type_specifier declaration_specifiers
        {}
        | type_specifier
        {}
        | type_qualifier declaration_specifiers
        {}
        | type_qualifier
        {}
        | function_specifier declaration_specifiers
        {}
        | function_specifier
        {}
        ;

init_declarator_list: 
        init_declarator
        {
            $$ = new vector<declaration*>;      // create a vector of declarations and add $1 to it
            $$->push_back($1);
        }
        | init_declarator_list COMMA init_declarator
        {
            $1->push_back($3);                  // add $3 to the vector of declarations
            $$ = $1;
        }
        ;

init_declarator: 
        declarator
        {
            $$ = $1;
            $$->initVal = NULL;         // initialize the initVal to NULL as no initialization is done
        }
        | declarator ASSIGNMENT initializer
        {   
             $$ = $1;
            $$->initVal = $3;           // initialize the initVal to the value provided
        }
        ;

storage_class_specifier: 
        EXTERN
        {/* ignored */}
        | STATIC
        {/* ignored */}
        | AUTO
        {/* ignored */}
        | REGISTER
        {/* ignored */}
        ;

type_specifier: 
        VOID
        {
            $$ = TYPE_VOID;
        }
        | CHAR
        {
            $$ = TYPE_CHAR;
        }
        | SHORT
        {/* ignored */}
        | INT
        {
            $$ = TYPE_INT;
        }
        | LONG
        {/* ignored */}
        | FLOAT
        {
            $$ = TYPE_FLOAT;
        }
        | DOUBLE
        {/* ignored */}
        | SIGNED
        {/* ignored */}
        | UNSIGNED
        {/* ignored */}
        | _BOOL
        {/* ignored */}
        | _COMPLEX
        {/* ignored */}
        | _IMAGINARY
        {/* ignored */}
        | enum_specifier
        {/* ignored */}
        ;

specifier_qualifier_list: 
        type_specifier specifier_qualifier_list_opt
        {/* ignored */}
        | type_qualifier specifier_qualifier_list_opt
        {/* ignored */}
        ;

specifier_qualifier_list_opt: 
        specifier_qualifier_list
        {/* ignored */}
        | %empty
        {/* ignored */}
        ;

enum_specifier: 
        ENUM identifier_opt LEFT_CURLY_BRACKET enumerator_list RIGHT_CURLY_BRACKET
        {/* ignored */}
        | ENUM identifier_opt LEFT_CURLY_BRACKET enumerator_list COMMA RIGHT_CURLY_BRACKET
        {/* ignored */}
        | ENUM IDENTIFIER
        {/* ignored */}
        ;

identifier_opt: 
        IDENTIFIER
        {/* ignored */}
        | %empty
        {/* ignored */}
        ;

enumerator_list: 
        enumerator
        {/* ignored */}
        | enumerator_list COMMA enumerator
        {/* ignored */}
        ;

enumerator: 
        IDENTIFIER
        {/* ignored */}
        | IDENTIFIER ASSIGNMENT constant_expression
        {/* ignored */}
        ;

type_qualifier: 
        CONST
        {/* ignored */}
        | RESTRICT
        {/* ignored */}
        | VOLATILE
        {/* ignored */}
        ;

function_specifier: 
        INLINE
        {/* ignored */}
        ;

declarator: 
        pointer direct_declarator
        {
            $$ = $2;
            $$->pointers = $1;
        }
        | direct_declarator
        {
            $$ = $1;
            $$->pointers = 0;
        }
        ;

direct_declarator: 
        IDENTIFIER
        {
            $$ = new declaration();
            $$->name = *($1);
        }
        | LEFT_PARENTHESES declarator RIGHT_PARENTHESES
        {/* ignored */}
        | direct_declarator LEFT_SQUARE_BRACKET type_qualifier_list_opt RIGHT_SQUARE_BRACKET
        {
            $1->type = TYPE_ARR;       // Array type
            $1->nextType = TYPE_INT;     // Array of ints
            $$ = $1;
            $$->li.push_back(0);
        }
        | direct_declarator LEFT_SQUARE_BRACKET type_qualifier_list_opt assignment_expression RIGHT_SQUARE_BRACKET
        {
            $1->type = TYPE_ARR;       // Array type
            $1->nextType = TYPE_INT;     // Array of ints
            $$ = $1;
            int index = ST->lookup($4->loc)->initVal->i;
            $$->li.push_back(index);
        }
        | direct_declarator LEFT_SQUARE_BRACKET STATIC type_qualifier_list assignment_expression RIGHT_SQUARE_BRACKET
        {/* ignored */}
        | direct_declarator LEFT_SQUARE_BRACKET type_qualifier_list STATIC assignment_expression RIGHT_SQUARE_BRACKET
        {/* ignored */}
        | direct_declarator LEFT_SQUARE_BRACKET type_qualifier_list_opt ASTERISK RIGHT_SQUARE_BRACKET
        {
            $1->type = TYPE_PTR;     // Pointer type
            $1->nextType = TYPE_INT;
            $$ = $1;
        }
        | direct_declarator LEFT_PARENTHESES parameter_type_list_opt RIGHT_PARENTHESES
        {
            $$ = $1;
            $$->type = TYPE_FUNC;    // Function type
            symbol* funcData = ST->lookup($$->name, $$->type);
            symbolTable* funcTable = new symbolTable();
            funcData->nestedTable = funcTable;
            vector<param*> paramList = *($3);   // Get the parameter list
            for(int i = 0; i < (int)paramList.size(); i++) {
                param* curParam = paramList[i];
                if(curParam->type.type == TYPE_ARR) {          // If the parameter is an array
                    funcTable->lookup(curParam->name, curParam->type.type);
                    funcTable->lookup(curParam->name)->type.nextType = TYPE_INT;
                    funcTable->lookup(curParam->name)->type.dims.push_back(0);
                }
                else if(curParam->type.type == TYPE_PTR) {   // If the parameter is a pointer
                    funcTable->lookup(curParam->name, curParam->type.type);
                    funcTable->lookup(curParam->name)->type.nextType = TYPE_INT;
                    funcTable->lookup(curParam->name)->type.dims.push_back(0);
                }
                else                                        // If the parameter is a anything other than an array or a pointer
                    funcTable->lookup(curParam->name, curParam->type.type);
            }
            ST = funcTable;         // Set the pointer to the symbol table to the function's symbol table
            emit($$->name, "", "", FUNC_BEG);
        }
        | direct_declarator LEFT_PARENTHESES identifier_list RIGHT_PARENTHESES
        {/* ignored */}
        ;

parameter_type_list_opt:
        parameter_type_list
        {/* ignored */}
        | %empty
        {
            $$ = new vector<param*>;
        }
        ;

type_qualifier_list_opt: 
        type_qualifier_list
        {/* ignored */}
        | %empty
        {/* ignored */}
        ;

pointer: 
        ASTERISK type_qualifier_list
        {/* ignored */}
        | ASTERISK
        {
            $$ = 1;
        }
        | ASTERISK type_qualifier_list pointer
        {/* ignored */}
        | ASTERISK pointer
        {
            $$ = $2 + 1;
        }
        ;

type_qualifier_list: 
        type_qualifier
        {/* ignored */}
        | type_qualifier_list type_qualifier
        {/* ignored */}
        ;

parameter_type_list: 
        parameter_list
        {/* ignored */}
        | parameter_list COMMA ELLIPSIS
        {/* ignored */}
        ;

parameter_list: 
        parameter_declaration
        {
            $$ = new vector<param*>;         // Create a new vector of parameters
            $$->push_back($1); 
        }
        | parameter_list COMMA parameter_declaration
        {
            $1->push_back($3);              // Add the parameter to the vector
            $$ = $1;
        }
        ;

parameter_declaration: 
        declaration_specifiers declarator
        {
            $$ = new param();
            $$->name = $2->name;
            if($2->type == TYPE_ARR) {
                $$->type.type = TYPE_ARR;
                $$->type.nextType = $1;
            }
            else if($2->pc != 0) {
                $$->type.type = TYPE_PTR;
                $$->type.nextType = $1;
            }
            else
                $$->type.type = $1;
        }
        | declaration_specifiers
        {/* ignored */}
        ;

identifier_list: 
        IDENTIFIER
        {/* ignored */}
        | identifier_list COMMA IDENTIFIER
        {/* ignored */}
        ;

type_name: 
        specifier_qualifier_list
        {/* ignored */}
        ;

initializer: 
        assignment_expression
        {
            $$ = $1;   
        }
        | LEFT_CURLY_BRACKET initializer_list RIGHT_CURLY_BRACKET
        {/* ignored */}
        | LEFT_CURLY_BRACKET initializer_list COMMA RIGHT_CURLY_BRACKET
        {/* ignored */}
        ;

initializer_list: 
        designation_opt initializer
        {/* ignored */}
        | initializer_list COMMA designation_opt initializer
        {/* ignored */}
        ;

designation_opt: 
        designation
        {/* ignored */}
        | %empty
        {/* ignored */}
        ;

designation: 
        designator_list ASSIGNMENT
        {/* ignored */}
        ;

designator_list: 
        designator
        {/* ignored */}
        | designator_list designator
        {/* ignored */}
        ;

designator: 
        LEFT_SQUARE_BRACKET constant_expression RIGHT_SQUARE_BRACKET
        {/* ignored */}
        | DOT IDENTIFIER
        {/* ignored */}
        ;

// Statements

statement: 
        labeled_statement
        {/* ignored */}
        | compound_statement
        | expression_statement
        | selection_statement
        | iteration_statement
        | jump_statement
        ;

labeled_statement: 
        IDENTIFIER COLON statement
        {/* ignored */}
        | CASE constant_expression COLON statement
        {/* ignored */}
        | DEFAULT COLON statement
        {/* ignored */}
        ;

compound_statement: 
        LEFT_CURLY_BRACKET RIGHT_CURLY_BRACKET
        {/* ignored */}
        | LEFT_CURLY_BRACKET block_item_list RIGHT_CURLY_BRACKET
        {
            $$ = $2;
        }
        ;

block_item_list: 
        block_item
        {
            $$ = $1;
            backpatch($1->nextList,nextInstr);
        }
        | block_item_list M block_item
        {   
            // production rule augmented with the non-terminal M
            $$ = new expression();
            backpatch($1->nextList, $2->instr);    // After $1, move to block_item via $2
            $$->nextList = $3->nextList;
        }
        ;

block_item: 
        declaration
        {
            $$ = new expression();   
        }
        | statement
        ;

expression_statement: 
        expression SEMI_COLON
        {/* ignored */}
        | SEMI_COLON
        {
            $$ = new expression();  
        }
        ;

selection_statement: 
        IF LEFT_PARENTHESES expression N RIGHT_PARENTHESES M statement N
        {
            // production rule augmented for control flow
            backpatch($4->nextList, nextInstr);         // nextList of N now has nextInstr
            convertIntToBool($3);                       // Convert expression to bool
            backpatch($3->trueList, $6->instr);         // Backpatching - if expression is true, go to M
            $$ = new expression();                      // Create new expression
            // Merge falseList of expression, nextList of statement and nextList of the last N
            $7->nextList = merge($8->nextList, $7->nextList);
            $$->nextList = merge($3->falseList, $7->nextList);
        }
        | IF LEFT_PARENTHESES expression N RIGHT_PARENTHESES M statement N ELSE M statement N
        {
            // production rule augmented for control flow
           backpatch($4->nextList, nextInstr);         // nextList of N now has nextInstr
            convertIntToBool($3);                       // Convert expression to bool
            backpatch($3->trueList, $6->instr);         // Backpatching - if expression is true, go to first M, else go to second M
            backpatch($3->falseList, $10->instr);
            $$ = new expression();                      // Create new expression
            // Merge nextList of statement, nextList of N and nextList of the last statement
            $$->nextList = merge($7->nextList, $8->nextList);
            $$->nextList = merge($$->nextList, $11->nextList);
            $$->nextList = merge($$->nextList, $12->nextList);
        }
        | SWITCH LEFT_PARENTHESES expression RIGHT_PARENTHESES statement
        {/* ignored */}
        ;

iteration_statement: 
        WHILE M LEFT_PARENTHESES expression N RIGHT_PARENTHESES M statement
        {   
            /*
                production rule augmented with non-terminals like M and N to handle the control flow and backpatching
            */
            $$ = new expression();                   // Create a new expression
            emit("", "", "", GOTO);
            backpatch(makelist(nextInstr - 1), $2->instr);
            backpatch($5->nextList, nextInstr);
            convertIntToBool($4);                   // Convert expression to bool
            $$->nextList = $4->falseList;           // Exit loop if expression is false
            backpatch($4->trueList, $7->instr);     // Backpatching - if expression is true, go to M
            backpatch($8->nextList, $2->instr);     // Backpatching - go to the beginning of the loop
        }
        | DO M statement M WHILE LEFT_PARENTHESES expression N RIGHT_PARENTHESES SEMI_COLON
        {
            /*
                production rule augmented with non-terminals like M and N to handle the control flow and backpatching
            */
            $$ = new expression();                  // Create a new expression  
            backpatch($8->nextList, nextInstr);     // Backpatching 
            convertIntToBool($7);                   // Convert expression to bool
            backpatch($7->trueList, $2->instr);     // Backpatching - if expression is true, go to M
            backpatch($3->nextList, $4->instr);     // Backpatching - go to the beginning of the loop
            $$->nextList = $7->falseList;
        }
        | FOR LEFT_PARENTHESES expression_statement M expression_statement N M expression N RIGHT_PARENTHESES M statement
        {
            /*
                production rule augmented with non-terminals like M and N to handle the control flow and backpatching
            */
            $$ = new expression();                   // Create a new expression
            emit("", "", "", GOTO);
            $12->nextList = merge($12->nextList, makelist(nextInstr - 1));
            backpatch($12->nextList, $7->instr);    // Backpatching - go to the beginning of the loop
            backpatch($9->nextList, $4->instr);     
            backpatch($6->nextList, nextInstr);     
            convertIntToBool($5);                   // Convert expression to bool
            backpatch($5->trueList, $11->instr);    // Backpatching - if expression is true, go to M
            $$->nextList = $5->falseList;           // Exit loop if expression is false
        }
        ;

jump_statement: 
        GOTO_ IDENTIFIER SEMI_COLON
        {/* ignored */}
        | CONTINUE SEMI_COLON
        {/* ignored */}
        | BREAK SEMI_COLON
        {/* ignored */}
        | RETURN_ expression SEMI_COLON
        {
            if(ST->lookup("RETVAL")->type.type == ST->lookup($2->loc)->type.type) {
                emit($2->loc, "", "", RETURN);      // Emit the quad when return type is not void
            }
            $$ = new expression();
        }
        | RETURN_ SEMI_COLON
        {
            if(ST->lookup("RETVAL")->type.type == TYPE_VOID) {
                emit("", "", "", RETURN);           // Emit the quad when return type is void
            }
            $$ = new expression();
        }
        ;

// External definitions

translation_unit: 
        external_declaration
        {/* ignored */}
        | translation_unit external_declaration
        {/* ignored */}
        ;

external_declaration: 
        function_definition
        {/* ignored */}
        | declaration
        {/* ignored */}
        ;

function_definition: 
        declaration_specifiers declarator declaration_list compound_statement
        {}
        | function_prototype compound_statement
        {
            ST = &globalST;                     // Reset the symbol table to global symbol table
            emit($1->name, "", "", FUNC_END);
        }
        ;

function_prototype:
        declaration_specifiers declarator
        {
            DataType currType = $1;
            int currSize = -1;
            if(currType == TYPE_CHAR)
                currSize = size_of_char;
            if(currType == TYPE_INT)
                currSize = size_of_int;
            if(currType == TYPE_FLOAT)
                currSize = size_of_float;
            declaration* currDec = $2;
            symbol* sym = globalST.lookup(currDec->name);
            if(currDec->type == TYPE_FUNC) {
                symbol* retval = sym->nestedTable->lookup("RETVAL", currType, currDec->pointers);   // Create entry for return value
                sym->size = 0;
                sym->initVal = NULL;
            }
            $$ = $2;
        }
        ;

declaration_list: 
        declaration
        {/* ignored */}
        | declaration_list declaration
        {/* ignored */}
        ;

%%

void yyerror(string s) {
    // This function prints any error encountered while parsing
    cout << "Error occurred: " << s << endl;
    cout << "Line no.: " << yylineno << endl;
    cout << "Unable to parse: " << yytext << endl; 
}
