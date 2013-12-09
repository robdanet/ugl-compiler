#ifndef	SYMBOL_H
#define	SYMBOL_H
/* $Id: symbol.h,v 0.1 Antonio Molinaro Exp $
* 
* Symbol table management for ugl-compiler.
*/
extern int symbol_insert(char* name,int type);
extern void symbol_declare(int i);

extern int symbol_find(char* name);
extern char* symbol_name(int i);
extern int symbol_type(int i);
extern int symbol_declared(int i);
extern void symbol_setValue(int val, char *name);/* mio */ 
extern int symbol_getValue(char* name);/* mio */ 
#endif
