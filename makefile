CC=gcc
NASM=nasm
CFLAGS=-O2 -fno-stack-protector

all: build/payload build/packed

build/payload: src/payload.c
	    $(CC) $(CFLAGS) -o build/payload src/payload.c

# packer / assembler steps: packer must be implemented incrementally
# build/loader.o: src/loader.S
#     $(CC) -c -o build/loader.o src/loader.S
#
#     # run packer after building payload
build/packed: build/payload pack
	    ./pack build/payload build/packed

pack: src/packer.c
	    $(CC) -o pack src/packer.c
