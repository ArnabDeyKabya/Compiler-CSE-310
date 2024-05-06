#include "2005112_symbolInfo.h"
#include "2005112_functionInfo.h"
using namespace std;

VarInfo::VarInfo(string name, string type, int line, string dataType)
    : SymbolInfo(name, type, line), dataType(dataType)
{
    //
}
void VarInfo::setDataType(string dataType)
{
    this->dataType = dataType;
}
string VarInfo::getDataType()
{
    return dataType;
}

FunctionInfo::FunctionInfo(string name, string type, int line, string returnType)
    : SymbolInfo(name, type, line), returnType(returnType)
{
    defined = false;
}
void FunctionInfo::addParameter(VarInfo *varInfo)
{
    parameterList.push_back(varInfo);
}
string FunctionInfo::getReturnType()
{
    return returnType;
}
bool FunctionInfo::isDefined()
{
    return defined;
}
void FunctionInfo::setDefined(bool defined)
{
    this->defined = defined;
}
