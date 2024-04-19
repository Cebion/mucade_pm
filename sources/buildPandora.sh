#!/bin/sh

# ODE library must be compiled with singles as floating point datatype and not with doubles
# otherwise parameter dSINGLE must be changed to dDOUBLE
FLAGS="-frelease -fversion=dSINGLE -fversion=USE_SIMD -fversion=PANDORA -fno-section-anchors -c -O2 -Wall -pipe -mfpu=neon -ffast-math"
CFLAGS="-c -O2 -Wall -pipe -DPANDORA -mfpu=neon -ffast-math"

rm import/*.o*
rm import/ode/*.o*
rm src/abagames/util/*.o*
rm src/abagames/util/bulletml/*.o*
rm src/abagames/util/ode/*.o*
rm src/abagames/util/sdl/*.o*
rm src/abagames/mcd/*.o*

cd import
$PNDSDK/bin/pandora-gdc $FLAGS *.d
cd ..

cd import/ode
$PNDSDK/bin/pandora-gdc $FLAGS -I.. *.d
cd ../..

cd src/abagames/util
$PNDSDK/bin/pandora-gdc $FLAGS -I../../../import -I../.. *.d
cd ../../..

cd src/abagames/util/bulletml
$PNDSDK/bin/pandora-gdc $FLAGS -I../../../../import -I../../.. *.d
cd ../../../..

cd src/abagames/util/ode
$PNDSDK/bin/pandora-gdc $FLAGS -I../../../../import -I../../.. *.d
cd ../../../..

cd src/abagames/util/sdl
$PNDSDK/bin/pandora-gdc $FLAGS -I../../../../import -I../../.. *.d
cd ../../../../..

cd src/abagames/mcd
$PNDSDK/bin/pandora-gdc $FLAGS -I../../../import -I../.. *.d
$PNDSDK/bin/pandora-gcc $CFLAGS -I$PNDSDK/usr/include shape-simd.c
cd ../../../..

$PNDSDK/bin/pandora-gdc -o Mu-cade -s -Wl,-rpath-link,$PNDSDK/usr/lib -L$PNDSDK/usr/lib -lGLU -lGL -lSDL_mixer -lmad -lSDL -lts -lbulletml_d -lode -L./lib/arm import/*.o* import/ode/*.o* src/abagames/util/*.o* src/abagames/util/bulletml/*.o* src/abagames/util/ode/*.o* src/abagames/util/sdl/*.o* src/abagames/mcd/*.o*
