#First attempt at a makefile for the openflexure microscope
#For now it just compiles all the versions at once.  In the future I'd like
#to use variables or something to compile just the version you're interested in.

.PHONY: all

SOURCE = openscad
OUTPUT = builds
PARTS := feet gears
STLFILES := $(PARTS:%=$(OUTPUT)/%.stl)

all: $(STLFILES)

cleanstl:
	rm $(STLFILES)

$(OUTPUT)/%.stl: $(SOURCE)/%.scad
	openscad -o $@ $<

    
