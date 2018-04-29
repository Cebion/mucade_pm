#!/bin/sh

# ODE library must be compiled with singles as floating point datatype and not with doubles
# otherwise parameter dSINGLE must be changed to dDOUBLE
FLAGS="-frelease -fversion=dSINGLE -fversion=USE_SIMD -fversion=PANDORA -fno-section-anchors -c -O2 -pipe -mfpu=neon -ffast-math"
CFLAGS="-c -O2 -pipe -DPANDORA -mfpu=neon -ffast-math"

rm sources/import/*.o*
rm sources/import/ode/*.o*
rm sources/src/abagames/util/*.o*
rm sources/src/abagames/util/bulletml/*.o*
rm sources/src/abagames/util/ode/*.o*
rm sources/src/abagames/util/sdl/*.o*
rm sources/src/abagames/mcd/*.o*

cd sources/import
$PNDSDK/bin/pandora-gdc $FLAGS *.d
cd ../..

cd sources/import/ode
$PNDSDK/bin/pandora-gdc $FLAGS -I.. *.d
cd ../../..

cd sources/src/abagames/util
$PNDSDK/bin/pandora-gdc $FLAGS -I../../../import -I../.. *.d
cd ../../../..

cd sources/src/abagames/util/bulletml
$PNDSDK/bin/pandora-gdc $FLAGS -I../../../../import -I../../.. *.d
cd ../../../../..

cd sources/src/abagames/util/ode
$PNDSDK/bin/pandora-gdc $FLAGS -I../../../../import -I../../.. *.d
cd ../../../../..

cd sources/src/abagames/util/sdl
$PNDSDK/bin/pandora-gdc $FLAGS -I../../../../import -I../../.. *.d
cd ../../../../..

cd sources/src/abagames/mcd
$PNDSDK/bin/pandora-gdc $FLAGS -I../../../import -I../.. *.d
$PNDSDK/bin/pandora-gcc $CFLAGS -I$PNDSDK/usr/include shape-simd.c
cd ../../../..

$PNDSDK/bin/pandora-gdc -o Mu-cade -s -Wl,-rpath-link,$PNDSDK/usr/lib -L$PNDSDK/usr/lib -lGLU -lGL -lSDL_mixer -lmad -lSDL -lts -lbulletml_d -lode -L./lib/arm sources/import/*.o* sources/import/ode/*.o* sources/src/abagames/util/*.o* sources/src/abagames/util/bulletml/*.o* sources/src/abagames/util/ode/*.o* sources/src/abagames/util/sdl/*.o* sources/src/abagames/mcd/*.o*
