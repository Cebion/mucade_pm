#!/bin/sh

# ODE library must be compiled with singles as floating point datatype and not with doubles
# otherwise parameter dSINGLE must be changed to dDOUBLE
FLAGS="-frelease -fversion=dSINGLE -fversion=USE_SIMD -c -O2 -Wall -pipe -mfpmath=sse -ffast-math"
CFLAGS="-c -O2 -Wall -pipe -mfpmath=sse -ffast-math"

rm import/*.o*
rm import/ode/*.o*
rm src/abagames/util/*.o*
rm src/abagames/util/bulletml/*.o*
rm src/abagames/util/ode/*.o*
rm src/abagames/util/sdl/*.o*
rm src/abagames/mcd/*.o*

cd import
gdc $FLAGS *.d
cd ..

cd import/ode
gdc $FLAGS -I.. *.d
cd ../..

cd src/abagames/util
gdc $FLAGS -I../../../import -I../.. *.d
cd ../../..

cd src/abagames/util/bulletml
gdc $FLAGS -I../../../../import -I../../.. *.d
cd ../../../..

cd src/abagames/util/ode
gdc $FLAGS -I../../../../import -I../../.. *.d
cd ../../../..

cd src/abagames/util/sdl
gdc $FLAGS -I../../../../import -I../../.. *.d
cd ../../../..

cd src/abagames/mcd
gdc $FLAGS -I../../../import -I../.. *.d
gcc $CFLAGS shape-simd.c
cd ../../..

gdc -o Mu-cade -s -lGLU -lGL -lSDL_mixer -lSDL -lstdc++ import/*.o* import/ode/*.o* src/abagames/util/*.o* src/abagames/util/bulletml/*.o* src/abagames/util/ode/*.o* src/abagames/util/sdl/*.o* src/abagames/mcd/*.o* lib/x64/libbulletml_d.a lib/x64/libode.a
