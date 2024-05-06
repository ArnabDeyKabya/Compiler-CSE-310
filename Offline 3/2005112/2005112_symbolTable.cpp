// #include "symbolInfo.h"
#include "2005112_symbolTable.h"
#include "2005112_functionInfo.h"
#include <fstream>
using namespace std;
ifstream ifile;
ofstream ofile;
int num_buckets = 11;
unsigned long long SDBMHash(string str)
{
    unsigned long long hash = 0;
    unsigned long long i = 0;
    unsigned long long len = str.length();

    for (i = 0; i < len; i++)
    {
        hash = (str[i]) + (hash << 6) + (hash << 16) - hash;
    }

    return hash;
}

ScopeTable::ScopeTable(int num_buckets, int scope_table_no, ScopeTable *parent_scope)
    : num_buckets(num_buckets), scope_table_no(scope_table_no)
{
    this-> parent_scope = parent_scope;
    table = new SymbolInfo *[num_buckets];
    for (int i = 0; i < num_buckets; i++)
    {
        table[i] = NULL;
    }
    if (parent_scope != NULL)
    {
        parent_scope->scope_count++;
        id = parent_scope->id + "." + to_string(parent_scope->scope_count);
    }
    else
    {
        id = "1";
    }
    ofile << "\tScopeTable# " << scope_table_no << " created" << endl;
}
ScopeTable::~ScopeTable()
{
    ofile << "\tScopeTable# " << scope_table_no << " removed" << endl;
    for (int i = 0; i < num_buckets; i++)
    {
        SymbolInfo *temp = table[i];
        SymbolInfo *del = temp;
        while (temp != NULL)
        {
            del = temp;
            temp = temp->next;
            delete del;
        }
    }
    delete table;
}
SymbolInfo *ScopeTable::lookUp(string name)
{
    int index = SDBMHash(name) % num_buckets;
    int count = 1;
    SymbolInfo *temp = table[index];
    while (temp != NULL && temp->getName() != name)
    {
        temp = temp->next;
        count++;
    }
    if (temp != NULL)
    {
        ofile << "\t'" << name << "'"
              << " found in ScopeTable# " << id << " at position " << index + 1 << ", " << count << endl;
        return temp;
    }
    else
    {
        return NULL;
    }
}
bool ScopeTable::insert(string name, string type, int line)
{

    int index = SDBMHash(name) % num_buckets;
    int count = 1;
    SymbolInfo *a = new SymbolInfo(name, type, line);
    SymbolInfo *temp = table[index];
    if (temp != NULL)
    {

        while (temp->next != NULL && temp->getName() != name)
        {
            temp = temp->next;
            count++;
        }
        if (temp->getName() != name)
        {
            temp->next = a;
            count++;
        }
        else
        {
            // ofile<<"\t'"<<name<<"'"<<" already exists in the current ScopeTable"<<endl;
            return false;
        }
    }
    else
        table[index] = a;
    // ofile<<"\tInserted in ScopeTable# "<<scope_table_no<<" at position "<<i+1<<", "<<count<<endl;
    return true;
}

bool ScopeTable::insert(SymbolInfo *a)
{
    int index = SDBMHash(a->getName()) % num_buckets;
    int count = 1;
    SymbolInfo *temp = table[index];
    if (temp != NULL)
    {

        while (temp->next != NULL && temp->getName() != a->getName())
        {
            temp = temp->next;
            count++;
        }
        if (temp->getName() != a->getName())
        {
            temp->next = a;
            count++;
        }
        else
        {
            // ofile<<"\t'"<<name<<"'"<<" already exists in the current ScopeTable"<<endl;
            return false;
        }
    }
    else
        table[index] = a;
    // ofile<<"\tInserted in ScopeTable# "<<scope_table_no<<" at position "<<i+1<<", "<<count<<endl;
    return true;
}

bool ScopeTable::Delete(string name)
{
    int index = SDBMHash(name) % num_buckets;
    SymbolInfo *temp = table[index];
    SymbolInfo *prev = temp;
    int cnt = 1;
    while (temp != NULL && temp->getName() != name)
    {
        prev = temp;
        temp = temp->next;
        cnt++;
    }
    if (temp != NULL)
    {
        if (prev == temp)
            table[index] = NULL;
        else
            prev->next = temp->next;
        // cout<<"hello";
        ofile << "\tDeleted '" << name << "' from ScopeTable# " << id << " at position " << index + 1 << ", " << cnt << endl;
        return 1;
    }
    else
    {
        ofile << "\tNot found in the current ScopeTable" << endl;
        return 0;
    }
}

string ScopeTable::print()
{
    string str = "\tScopeTable# " + id + "\n";
    for (int i = 0; i < num_buckets; i++)
    {
        if (table[i] != NULL)
        {
            int j = i + 1;
            str += "\t" + to_string(j) + "--> ";
            SymbolInfo *temp = table[i];
            while (temp != NULL)
            {
                if (temp->getType() == "ID")
                {
                    VarInfo *v = (VarInfo *)temp;
                    str += "<" + v->getName() + ", " + v->getDataType() + "> ";
                }
                else
                {
                    FunctionInfo *f = (FunctionInfo *)temp;
                    str += "<" + f->getName() + ", " + f->getType() + ", " + f->getReturnType() + "> ";
                }

                temp = temp->next;
            }
            str += "\n";
        }
    }
    return str;
}

int ScopeTable::getScopeTableNo()
{
    return scope_table_no;
}

SymbolTable::SymbolTable()
{
    current_scope = NULL;
    scope_table_no = 0;
    enterScope();
}
SymbolTable::~SymbolTable()
{
    ScopeTable *temp = current_scope;
    ScopeTable *del = temp;
    while (temp != NULL)
    {
        del = temp;
        temp = temp->parent_scope;
        delete del;
    }
}
void SymbolTable::enterScope()
{
    ScopeTable *s = new ScopeTable(num_buckets, ++scope_table_no, current_scope);
    if (current_scope != NULL)
        s->parent_scope = current_scope;
    current_scope = s;
}
void SymbolTable::exitScope()
{
    ScopeTable *temp = current_scope;
    if (current_scope->parent_scope == NULL)
    {
        ofile << "\tScopeTable# " << current_scope->getScopeTableNo() << " cannot be removed" << endl;
        return;
    }
    current_scope = current_scope->parent_scope;
    delete temp;
}
bool SymbolTable::insert(string name, string type, int line)
{
    return current_scope->insert(name, type, line);
}
bool SymbolTable::insert(SymbolInfo *s)
{
    return current_scope->insert(s);
}
bool SymbolTable::remove(string name)
{
    return current_scope->Delete(name);
}
SymbolInfo *SymbolTable::lookUp(string name)
{
    ScopeTable *temp = current_scope;
    SymbolInfo *sym = NULL;
    while (temp != NULL)
    {
        sym = temp->lookUp(name);
        if (sym != NULL)
            break;
        temp = temp->parent_scope;
    }
    if (sym == NULL)
        ofile << "\t'" << name << "'"
              << " not found in any of the ScopeTables" << endl;
    return sym;
}
SymbolInfo *SymbolTable::lookUpCurrent(string name)
{
    return current_scope->lookUp(name);
}
void SymbolTable::printCurrentScope()
{
    current_scope->print();
}
string SymbolTable::printAllScope()
{
    string str = "";
    ScopeTable *temp = current_scope;
    while (temp != NULL)
    {
        str.append(temp->print());
        temp = temp->parent_scope;
    }
    return str;
}
