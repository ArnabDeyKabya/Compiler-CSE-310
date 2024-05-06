#include <iostream>
#include <string>
#include "symbol_node.cpp"
#include <fstream>
ifstream ifile;
ofstream ofile;
using namespace std;
unsigned long long SDBMHash(string str)
{
    unsigned long long len = str.length();
    unsigned long long i = 0;
    unsigned long long hash = 0;
    for (i = 0; i < len; i++)
    {
        hash = (str[i]) + (hash << 6) + (hash << 16) - hash;
    }
    return hash;
}

class scope_table
{
public:
    symbol_info **table;
    int buckets;
    int scope_table_no;
    scope_table *parent_scope;

    string id;
    int scope_count;
    scope_table(int n, int no, scope_table *parent = NULL)
    {
        scope_count = 0;
        buckets = n;
        scope_table_no = no;
        parent_scope = parent;
        table = new symbol_info *[buckets];
        for (int i = 0; i < buckets; i++)
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
        ofile << "\tScopeTable# " << id << " created" << endl;
    }
    ~scope_table()
    {
        ofile << "\tScopeTable# " << id << " deleted" << endl;
        delete[] table;
    }
    string getId()
    {
        return id;
    }

    int hash_value(string name)
    {
        return SDBMHash(name) % buckets;
    }
    symbol_info *lookup(string name)
    {
        int index = hash_value(name);
        int count = 1;
        symbol_info *temp = table[index];
        while (temp != NULL)
        {
            if (temp->get_symbol_name() == name)
            {
                ofile << "\t'" << name << "' found at position <" << index + 1 << ", " << count << "> "
                      << "of ScopeTable# " << id << endl;
                return temp;
            }
            temp = temp->next;
            count++;
        }
        if (temp == NULL)
        {

            return NULL;
        }
    }

    bool insert(string name, string type)
    {
        int index = hash_value(name);
        int count = 1;
        symbol_info *a = new symbol_info(name, type);
        symbol_info *temp = table[index];
        if (temp != NULL)
        {

            while (temp->next != NULL && temp->get_symbol_name() != name)
            {
                temp = temp->next;
                count++;
            }
            if (temp->get_symbol_name() != name)
            {
                temp->next = a;
                count++;
            }
            else
            {
                ofile << "\t'" << name << "'"
                      << " already exists in the current ScopeTable# " << id << endl;
                return 0;
            }
        }
        else
            table[index] = a;
        ofile << "\tInserted  at position "
              << "<" << index + 1 << ", " << count << "> of ScopeTable# " << id << endl;
        return 1;
    }
    bool Delete(string name)
    {
        int index = hash_value(name);
        symbol_info *temp = table[index];
        symbol_info *prev = NULL;
        int count = 1;
        while (temp != NULL)
        {
            if (temp->get_symbol_name() == name)
            {
                if (prev == NULL)
                {
                    table[index] = temp->next;
                }
                else
                {
                    prev->next = temp->next;
                }
                ofile << "\tDeleted '" << name << "' from position "
                      << "<" << index + 1 << ", " << count << "> "
                      << "of ScopeTable# " << id << endl;
                delete temp;
                return true;
            }
            prev = temp;
            temp = temp->next;
            count++;
        }
        if (temp == NULL)
        {
            ofile << "\tNot found in the current ScopeTable# " << id << endl;
            return false;
        }
    }
    int getScopeTableNo()
    {
        return scope_table_no;
    }

    void print()
    {
        ofile << "\tScopeTable# " << id << endl;
        for (int i = 0; i < buckets; i++)
        {
            ofile << "\t" << i + 1;
            symbol_info *temp = table[i];
            while (temp != NULL)
            {
                ofile << " --> (" << temp->get_symbol_name() << "," << temp->get_symbol_type() << ")";
                temp = temp->next;
            }
            ofile << endl;
        }
    }
};