#!/bin/sh

# ODE library must be compiled with singles as floating point datatype and not with doubles
# otherwise parameter dSINGLE must be changed to dDOUBLE
FLAGS="-frelease -fdata-sections -ffunction-sections -fno-section-anchors -c -O2 -Wall -pipe -fversion=dSINGLE -ffast-math -fversion=BindSDL_Static -fversion=SDL_201 -fversion=SDL_Mixer_202 -I`pwd`/import"

rm import/*.o*
rm import/ode/*.o*
rm import/sdl/*.o*
rm import/bindbc/sdl/*.o*
rm src/abagames/util/*.o*
rm src/abagames/util/bulletml/*.o*
rm src/abagames/util/ode/*.o*
rm src/abagames/util/sdl/*.o*
rm src/abagames/mcd/*.o*

cd import
find . -maxdepth 1 -name "*.d" -type f | xargs -P 16 -I{} gdc $FLAGS {}
cd sdl
find . -maxdepth 1 -name "*.d" -type f | xargs -P 16 -I{} gdc $FLAGS {}
cd ../bindbc/sdl
find . -maxdepth 1 -name "*.d" -type f | xargs -P 16 -I{} gdc $FLAGS {}
cd ../../ode
find . -maxdepth 1 -name "*.d" -type f | xargs -P 16 -I{} gdc $FLAGS -I.. {}
cd ../..

cd src/abagames/util
find . -maxdepth 1 -name "*.d" -type f | xargs -P 16 -I{} gdc $FLAGS -I../.. {}
cd ../../..

cd src/abagames/util/bulletml
find . -maxdepth 1 -name "*.d" -type f | xargs -P 16 -I{} gdc $FLAGS -I../../.. {}
cd ../../../..

cd src/abagames/util/ode
find . -maxdepth 1 -name "*.d" -type f | xargs -P 16 -I{} gdc $FLAGS -I../../.. {}
cd ../../../..

cd src/abagames/util/sdl
find . -maxdepth 1 -name "*.d" -type f | xargs -P 16 -I{} gdc $FLAGS -I../../.. {}
cd ../../../..

cd src/abagames/mcd
find . -maxdepth 1 -name "*.d" -type f | xargs -P 16 -I{} gdc $FLAGS -I../.. {}
cd ../../..

# Changed to use libbulletml.so instead of libbulletml_d.a based on symbol verification
gdc -o Mu-cade -s -Wl,--gc-sections -static-libphobos import/*.o* import/ode/*.o* import/sdl/*.o* import/bindbc/sdl/*.o* src/abagames/util/*.o* src/abagames/util/bulletml/*.o* src/abagames/util/ode/*.o* src/abagames/util/sdl/*.o* src/abagames/mcd/*.o* -lGLU -lGL -lSDL2_mixer -lSDL2 -lbulletml -lode