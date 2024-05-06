#include <iostream>
#include <string>
#include <sstream>
#include "2005112_scope_table.cpp"
using namespace std;
int buckets=10;
int tokenizer(string &s1, string s[])
{
    istringstream ss(s1);
    int i = 0;

    while (i < 5 && ss >> s[i])
    {
        ++i;
    }

    return i;
}
class symbol_table
{
public:
    scope_table *current_scope;
    int scope_table_no;
    symbol_table()
    {
        current_scope = NULL;
        scope_table_no = 0;
        enter_scope();
    }
    ~symbol_table()
    {
        scope_table *temp = current_scope;
        scope_table *deleted = NULL;
        while (temp != NULL)
        {
            deleted = temp;
            temp = temp->parent_scope;
            delete deleted;
        }
    }
    void enter_scope()
    {
        scope_table_no++;
        scope_table *new_scope = new scope_table(buckets, scope_table_no, current_scope);
        if (current_scope != NULL)
            new_scope->parent_scope = current_scope;
        current_scope = new_scope;
    }
    void exit_scope()
    {
        scope_table *temp = current_scope;
        if (current_scope->parent_scope == NULL)
        {
            ofile << "\tScopeTable# " << current_scope->getScopeTableNo() << " cannot be deleted" << endl;
            return;
        }
        current_scope = current_scope->parent_scope;
        delete temp;
    }
    bool Insert(string name, string type)
    {
        return current_scope->insert(name, type);
    }
    bool Remove(string name)
    {
        return current_scope->Delete(name);
    }
    symbol_info *LookUp(string name)
    {
        scope_table *temp = current_scope;
        while (temp != NULL)
        {
            symbol_info *temp2 = temp->lookup(name);
            if (temp2 != NULL)
            {
                return temp2;
            }
            temp = temp->parent_scope;
        }
        ofile << "\t'" << name << "'"
              << " not found in any of the ScopeTables" << endl;
        return NULL;
    }
    void print_current_scope()
    {
        current_scope->print();
    }
    string print_all_scope()
    {
        string str = "";
        scope_table *temp = current_scope;
        while (temp != NULL)
        {
            str += temp->print();
            temp = temp->parent_scope;
        }
        return str;
    }
};
/*
int main()
{
    ifile.open("input.txt");
    ofile.open("output.txt");

    if (!ifile.is_open() || !ofile.is_open())
    {
        cerr << "Error opening files." << endl;
        return 1;
    }
    ifile >> buckets;
    ifile.ignore(); // consume the newline after reading buckets

    symbol_table table;
    string command;
    bool flag = false;

    int count = 1;
    while (getline(ifile, command))
    {
        ofile << "Cmd " << count++ << ":";

        string str[5];
        int total = tokenizer(command, str);
        string com = str[0];

        if (com == "I" && total == 3)
        {
            ofile << " I " << str[1] << " " << str[2] << endl;
            table.Insert(str[1], str[2]);
        }
        else if (com == "L" && total == 2)
        {
            ofile << " L " << str[1] << endl;
            table.LookUp(str[1]);
        }
        else if (com == "D" && total == 2)
        {
            ofile << " D " << str[1] << endl;
            table.Remove(str[1]);
        }
        else if (com == "P" && total == 2)
        {
            if (str[1] == "C")
            {
                ofile << " P " << str[1] << endl;
                table.print_current_scope();
            }
            else if (str[1] == "A")
            {
                ofile << " P " << str[1] << endl;
                table.print_all_scope();
            }
            else
            {
                flag = true;
            }
        }
        else if (com == "S" && total == 1)
        {
            ofile << " S" << endl;
            table.enter_scope();
        }
        else if (com == "E" && total == 1)
        {
            ofile << " E" << endl;
            table.exit_scope();
        }
        else if (com == "Q")
        {
            ofile << " Q" << endl;
            break;
        }
        else
        {
            flag = true;
        }

        if (flag)
        {
            ofile << " " << command << endl;
            if (com == "P")
            {
                ofile << "\tInvalid argument for the command P" << endl;
            }
            else
            {
                ofile << "\tWrong number of arugments for the command " << com << endl;
            }
        }
        flag = false;
    }

    return 0;
}
*/