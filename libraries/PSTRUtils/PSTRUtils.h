#ifndef PSTRUtils_h
#define PSTRUtils_h

#include <avr/pgmspace.h>
#include "WProgram.h"

String& pstrAssign(String& str, const prog_char* pstr);
String& pstrAppend(String& str, const prog_char* pstr);
String pstrToString(const prog_char* pstr);

#endif
