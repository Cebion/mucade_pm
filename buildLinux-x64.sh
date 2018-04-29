#!/bin/sh

# ODE library must be compiled with singles as floating point datatype and not with doubles
# otherwise parameter dSINGLE must be changed to dDOUBLE
FLAGS="-frelease -fversion=dSINGLE -fversion=USE_SIMD -c -O2 -pipe -mfpmath=sse -ffast-math"
CFLAGS="-c -O2 -pipe -mfpmath=sse -ffast-math"

rm sources/import/*.o*
rm sources/import/ode/*.o*
rm sources/src/abagames/util/*.o*
rm sources/src/abagames/util/bulletml/*.o*
rm sources/src/abagames/util/ode/*.o*
rm sources/src/abagames/util/sdl/*.o*
rm sources/src/abagames/mcd/*.o*

cd sources/import
gdc $FLAGS *.d
cd ../..

cd sources/import/ode
gdc $FLAGS -I.. *.d
cd ../../..

cd sources/src/abagames/util
gdc $FLAGS -I../../../import -I../.. *.d
cd ../../../..

cd sources/src/abagames/util/bulletml
gdc $FLAGS -I../../../../import -I../../.. *.d
cd ../../../../..

cd sources/src/abagames/util/ode
gdc $FLAGS -I../../../../import -I../../.. *.d
cd ../../../../..

cd sources/src/abagames/util/sdl
gdc $FLAGS -I../../../../import -I../../.. *.d
cd ../../../../..

cd sources/src/abagames/mcd
gdc $FLAGS -I../../../import -I../.. *.d
gcc $CFLAGS shape-simd.c
cd ../../../..

gdc -o Mu-cade -s -lGLU -lGL -lSDL_mixer -lSDL -lstdc++ sources/import/*.o* sources/import/ode/*.o* sources/src/abagames/util/*.o* sources/src/abagames/util/bulletml/*.o* sources/src/abagames/util/ode/*.o* sources/src/abagames/util/sdl/*.o* sources/src/abagames/mcd/*.o* lib/x64/libbulletml_d.a lib/x64/libode.a
