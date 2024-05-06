#include <iostream>
#include <string>
using namespace std;

class symbol_info
{
public:
    string symbol_type;
    string symbol_name;
    symbol_info *next;
    symbol_info(string name, string type)
    {
        symbol_name = name;
        symbol_type = type;
        next = NULL;
    }
    string get_symbol_name()
    {
        return symbol_name;
    }
    string get_symbol_type()
    {
        return symbol_type;
    }
    void set_symbol_name(string name)
    {
        symbol_name = name;
    }
    void set_symbol_type(string type)
    {
        symbol_type = type;
    }
    bool operator!=(symbol_info a)
    {
        return symbol_name != a.get_symbol_name();
    }
};