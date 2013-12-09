#!/bin/sh
#
#       $Id: uglyc.sh,v 1.4 2009/02/04 10:00:58 dvermeir Exp $
#
#	Usage:	uglyc basename.ug
#
#	e.g. "uglyc tst.ug"  to compile tst.ug, resulting in 
#
#	tst.s	assembler source code
#	tst.o	object file
#	tst	executable file
#
# determine basename
base=`basename $1 .ug`
# this checks whether $1 has .ug suffix
[ ${base} = $1 ] && { echo "Usage: uglyc basename.ug"; exit 1; }
# make sure source file exists
[ -f "$1" ] || { echo "Cannot open \"$1\""; exit 1; }
# compile to assembly code
./ugly <$1 >${base}.s || { echo "Errors in compilation of $1"; exit 1; }
# assemble to object file: the --gdwarf2 option generates info for gdb
as --gdwarf2 ${base}.s -o ${base}.o  || { echo "Errors assembling $1.s"; exit 1; }
# link
ld --dynamic-linker /lib/ld-linux.so.2 ${base}.o -lc -o ${base} || { echo "Errors linking $1.o"; exit 1; }
