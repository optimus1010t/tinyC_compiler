#include "ass6_21CS10037_21CS30054_translator.h"
#include <iomanip>
using namespace std;

// global variables
int nextInstr = 0;

// static variables
int symbolTable::tempCount = 0;

quadArray qArr;
symbolTable globalST;
symbolTable* ST;


// symbol

//implementation of constructor for the symbol class
symbol::symbol(): nestedTable(NULL) {}

// symbol value

// implementation of functions for the symbolValue class
void symbolValue::setInitVal(int val) {
    c = f = i = val;
    p = NULL;
}

void symbolValue::setInitVal(char val) {
    c = f = i = val;
    p = NULL;
}

void symbolValue::setInitVal(float val) {
    c = f = i = val;
    p = NULL;
}

// symbol table

// implementation of constructor and functions for the symbolTable class
symbolTable::symbolTable(): offset(0) {}

symbol* symbolTable::lookup(string name, DataType t, int pc)
{
    if(table.count(name)==0)
    {
        symbol* s = new symbol();
        s->name = name;
        s->type.type = t;
        s->initVal = NULL;
        s->offset = offset;

        if(pc==0)
        {
            s->size = getSize(t);
            offset += s->size;
        }
        else
        {
            s->size = size_of_ptr;
            s->type.nextType = t;
            s->type.pointers = pc;
            s->type.type = TYPE_ARR;
        }
        symbols.push_back(s);
        table[name] = s;
    }
    return table[name];
}

symbol* symbolTable::searchGlobal(string name)
{
    return (table.count(name) ? table[name] : NULL);
}

string symbolTable::gentemp(DataType t)
{
    // create name for temporary symbol
    string tname = "t" + to_string(symbolTable::tempCount++);

    // initialise attributes of the symbol
    symbol* s = new symbol();
    s->name = tname;
    s->type.type = t;
    s->offset = offset;
    s->size = getSize(t);
    s->initVal = NULL;

    // add to symbol table
    offset += s->size;
    symbols.push_back(s);
    table[tname] = s;

    return tname;
}

void symbolTable::print(string tableName)
{
    for(int i = 0; i < 120; i++) {
        cout << '-';
    }
    cout << endl;
    cout << "Symbol Table: " << setfill(' ') << left << setw(50) << tableName << endl;
    for(int i = 0; i < 120; i++)
        cout << '-';
    cout << endl;

    // Table Headers
    cout << setfill(' ') << left << setw(25) <<  "Name";
    cout << left << setw(25) << "Type";
    cout << left << setw(20) << "Initial Value";
    cout << left << setw(15) << "Size";
    cout << left << setw(15) << "Offset";
    cout << left << "Nested" << endl;

    for(int i = 0; i < 120; i++)
        cout << '-';
    cout << endl;

    // For storing nested symbol tables
    vector<pair<string, symbolTable*>> tableList;

    // Print the symbols in the symbol table
    for(symbol* sym: symbols)
    {
        cout << left << setw(25) << sym->name;
        cout << left << setw(25) << checkType(sym->type);
        cout << left << setw(20) << getInitVal(sym);
        cout << left << setw(15) << sym->size;
        cout << left << setw(15) << sym->offset;
        cout << left;

        if(sym->nestedTable != NULL) {
            string nestedTableName = tableName + "." + sym->name;
            cout << nestedTableName << endl;
            tableList.push_back({nestedTableName, sym->nestedTable});
        }
        else
            cout << "NULL" << endl;
    }

    for(int i = 0; i < 120; i++)
    {
        cout << '-';
    }
    cout << endl << endl;

    // Recursively call the print function for the nested symbol tables
    for(auto &p: tableList)
    {
        p.second->print(p.first);
    }
}

// implementation of constructor and functions for the quad class
quad::quad(string res, string arg1, string arg2, opcode op): result(res), arg1(arg1), arg2(arg2), op(op) {}

string quad::print()
{
    string out = "";
    if(op >= ADD && op <= BIT_XOR) {                 // Binary operators
        out += (result + " = " + arg1 + " ");
        switch(op) {
            case ADD: out += "+"; break;
            case SUB: out += "-"; break;
            case MULT: out += "*"; break;
            case DIV: out += "/"; break;
            case MOD: out += "%"; break;
            case SL: out += "<<"; break;
            case SR: out += ">>"; break;
            case BIT_AND: out += "&"; break;
            case BIT_OR: out += "|"; break;
            case BIT_XOR: out += "^"; break;
        }
        out += (" " + arg2);
    }
    else if(op >= BIT_U_NOT && op <= U_NEG) {        // Unary operators
        out += (result + " = ");
        switch(op) {
            case BIT_U_NOT: out += "~"; break;
            case U_PLUS: out += "+"; break;
            case U_MINUS: out += "-"; break;
            case REF: out += "&"; break;
            case DEREF: out += "*"; break;
            case U_NEG: out += "!"; break;
        }
        out += arg1;
    }
    else if(op >= GOTO_EQ && op <= IF_FALSE_GOTO) { // Conditional operators
        out += ("if " + arg1 + " ");
        switch(op) {
            case GOTO_EQ: out += "=="; break;
            case GOTO_NEQ: out += "!="; break;
            case GOTO_GT: out += ">"; break;
            case GOTO_GTE: out += ">="; break;
            case GOTO_LT: out += "<"; break;
            case GOTO_LTE: out += "<="; break;
            case IF_GOTO: out += "!= 0"; break;
            case IF_FALSE_GOTO: out += "== 0"; break;
        }
        out += (" " + arg2 + " goto " + result);
    }
    else if(op >= CtoI && op <= CtoF) {             // Type Conversion functions
        out += (result + " = ");
        switch(op) {
            case CtoI: out += "CharToInt"; break;
            case ItoC: out += "IntToChar"; break;
            case FtoI: out += "FloatToInt"; break;
            case ItoF: out += "IntToFloat"; break;
            case FtoC: out += "FloatToChar"; break;
            case CtoF: out += "CharToFloat"; break;
        }
        out += ("(" + arg1 + ")");
    }

    else if(op == ASSIGN)                       // Assignment operator
        out += (result + " = " + arg1);
    else if(op == GOTO)                         // Goto
        out += ("goto " + result);
    else if(op == RETURN)                       // Return from a function
        out += ("return " + result);
    else if(op == PARAM)                        // Parameters for a function
        out += ("param " + result);
    else if(op == CALL) {                       // Call a function
        if(arg2.size() > 0)
            out += (arg2 + " = ");
        out += ("call " + result + ", " + arg1);
    }
    else if(op == ARR_IDX_ARG)                  // Array indexing
        out += (result + " = " + arg1 + "[" + arg2 + "]");
    else if(op == ARR_IDX_RES)                  // Array indexing
        out += (result + "[" + arg2 + "] = " + arg1);
    else if(op == FUNC_BEG)                     // Function begin
        out += (result + ": ");
    else if(op == FUNC_END) {                   // Function end
        out += ("function " + result + " ends");
    }
    else if(op == L_DEREF)                      // Dereference
        out += ("*" + result + " = " + arg1);

    return out;
}

// implementation of functions for the quadArray class
void quadArray::print()
{
    for(int i = 0; i < 120; i++)
    {
        cout << '-';
    }
    cout << endl;
    cout << "THREE ADDRESS CODE (TAC):" << endl;
    for(int i = 0; i < 120; i++)
    {
        cout << '-';
    }
    cout << endl;

    // Print each of the quads one by one
    for(int i = 0; i < (int)arr.size(); i++)
    {
        if(arr[i].op != FUNC_BEG && arr[i].op != FUNC_END)
            cout << left << setw(4) << i << ":    ";
        else if(arr[i].op == FUNC_BEG)
            cout << endl << left << setw(4) << i << ": ";
        else if(arr[i].op == FUNC_END)
            cout << left << setw(4) << i << ": ";
        cout << arr[i].print() << endl;
    }
    cout << endl;
}

// implementations of constructor for the expression class
expression::expression(): fold(0), folder(NULL) {}

// overloaded emit functions
void emit(string res, string arg1, string arg2, opcode op)
{
    quad q(res, arg1, arg2, op);
    qArr.arr.push_back(q);
    nextInstr++;
}

void emit(string res, int constant, opcode op)
{
    quad q(res, to_string(constant), "", op);
    qArr.arr.push_back(q);
    nextInstr++;
}

void emit(string res, char constant, opcode op)
{
    quad q(res, to_string(constant), "", op);
    qArr.arr.push_back(q);
    nextInstr++;
}

void emit(string res, float constant, opcode op)
{
    quad q(res, to_string(constant), "", op);
    qArr.arr.push_back(q);
    nextInstr++;
}

// makelist
list<int> makelist(int i)
{
    list<int> l(1, i);
    return l;
}

// merge
list<int> merge(list<int> l1, list<int> l2)
{
    l1.merge(l2);
    return l1;
}

// backpatch
void backpatch(list<int> l, int address)
{
    string addr=to_string(address);
    for(auto &i: l){
        qArr.arr[i].result = addr;
    }
}

// convert type
void convertType(expression* arg, expression* res, DataType t)
{
     if(res->type == t)
        return;

    if(res->type == TYPE_FLOAT) {
        if(t == TYPE_INT)
            emit(arg->loc, res->loc, "", FtoI);
        else if(t == TYPE_CHAR)
            emit(arg->loc, res->loc, "", FtoC);
    }
    else if(res->type == TYPE_INT) {
        if(t == TYPE_FLOAT)
            emit(arg->loc, res->loc, "", ItoF);
        else if(t == TYPE_CHAR)
            emit(arg->loc, res->loc, "", ItoC);
    }
    else if(res->type == TYPE_CHAR) {
        if(t == TYPE_FLOAT)
            emit(arg->loc, res->loc, "", CtoF);
        else if(t == TYPE_INT)
            emit(arg->loc, res->loc, "", CtoI);
    }
}

void convertToType(string t, DataType to, string f, DataType from)
{
    if(to == from)
        return;
    
    if(from == TYPE_FLOAT) {
        if(to == TYPE_INT)
            emit(t, f, "", FtoI);
        else if(to == TYPE_CHAR)
            emit(t, f, "", FtoC);
    }
    else if(from == TYPE_INT) {
        if(to == TYPE_FLOAT)
            emit(t, f, "", ItoF);
        else if(to == TYPE_CHAR)
            emit(t, f, "", ItoC);
    }
    else if(from == TYPE_CHAR) {
        if(to == TYPE_FLOAT)
            emit(t, f, "", CtoF);
        else if(to == TYPE_INT)
            emit(t, f, "", CtoI);
    }
}

// InttoBool
void convertIntToBool(expression* e)
{
    if(e->type != TYPE_BOOL){
        e->type = TYPE_BOOL;
        e->falseList = makelist(nextInstr);
        emit("",e->loc,"",IF_FALSE_GOTO);
        e->trueList = makelist(nextInstr);
        emit("","","",GOTO);
    }
}

// get size of type
int getSize(DataType t)
{
    if(t == TYPE_VOID)
        return size_of_void;
    else if(t == TYPE_CHAR)
        return size_of_char;
    else if(t == TYPE_INT)
        return size_of_int;
    else if(t == TYPE_FLOAT)
        return size_of_float;
    else if(t == TYPE_PTR)
        return size_of_ptr;
    else if(t == TYPE_FUNC)
        return size_of_func;
    else
        return 0;
}

// returns type
string checkType(symbolType t)
{
    if(t.type == TYPE_VOID)
        return "void";
    else if(t.type == TYPE_CHAR)
        return "char";
    else if(t.type == TYPE_INT)
        return "int";
    else if(t.type == TYPE_FLOAT)
        return "float";
    else if(t.type == TYPE_FUNC)
        return "function";

    else if(t.type == TYPE_PTR) {        // Depending on type of pointer
        string tp = "";
        if(t.nextType == TYPE_CHAR)
            tp += "char";
        else if(t.nextType == TYPE_INT)
            tp += "int";
        else if(t.nextType == TYPE_FLOAT)
            tp += "float";
        tp += string(t.pointers, '*');
        return tp;
    }

    else if(t.type == TYPE_ARR) {          // Depending on type of array
        string tp = "";
        if(t.nextType == TYPE_CHAR)
            tp += "char";
        else if(t.nextType == TYPE_INT)
            tp += "int";
        else if(t.nextType == TYPE_FLOAT)
            tp += "float";
        vector<int> dim = t.dims;
        for(int i = 0; i < (int)dim.size(); i++) {
            if(dim[i])
                tp += "[" + to_string(dim[i]) + "]";
            else
                tp += "[]";
        }
        if((int)dim.size() == 0)
            tp += "[]";
        return tp;
    }

    else
        return "unknown";
}

// Implementation of the getInitVal function
string getInitVal(symbol* s) {
    if(s->initVal != NULL) {
        if(s->type.type == TYPE_INT)
            return to_string(s->initVal->i);
        else if(s->type.type == TYPE_CHAR)
            return to_string(s->initVal->c);
        else if(s->type.type == TYPE_FLOAT)
            return to_string(s->initVal->f);
        else
            return "-";
    }
    else
        return "-";
}