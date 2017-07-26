#First attempt at a makefile for the openflexure microscope
#For now it just compiles all the versions at once.  In the future I'd like
#to use variables or something to compile just the version you're interested in.

.PHONY: all

SOURCE = openscad
OUTPUT = builds
COMMONPARTS := feet gears sample_clips
TOOLS := actuator_assembly_tools condenser_lens_tool tube_lens_tool
PARTS := $(COMMONPARTS) $(TOOLS) main_body_LS65 main_body_LS65-M
STLFILES := $(PARTS:%=$(OUTPUT)/%.stl)
parameters_file := $(SOURCE)/microscope_parameters.scad
utilities_file := $(SOURCE)/utilities.scad
all_deps := $(parameters_file) $(utilities_file) 			#All targets depend on these

all: $(STLFILES)

cleanstl:
	rm $(STLFILES)

main_body_dep_names := compact_nut_seat dovetail logo
main_body_deps := $(all_deps) $(main_body_dep_names:%=$(SOURCE)/%.scad)

# The main body is different as there's several versions (TODO: automate this)
# It seems you can generate rules automatically, see for example
# https://stackoverflow.com/questions/3745177/multi-wildcard-pattern-rules-of-gnu-make
$(OUTPUT)/main_body_LS65.stl: $(SOURCE)/main_body.scad $(main_body_deps) 
	openscad -o $@ -D sample_z=65 -D big_stage=true -D motor_lugs=false $<
$(OUTPUT)/main_body_LS65-M.stl: $(SOURCE)/main_body.scad $(main_body_deps) 
	openscad -o $@ -D sample_z=65 -D big_stage=true -D motor_lugs=true $<

$(OUTPUT)/%.stl: $(SOURCE)/%.scad $(all_deps)
	openscad -o $@ $<

    
