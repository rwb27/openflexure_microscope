#First attempt at a makefile for the openflexure microscope
#For now it just compiles all the versions at once.  In the future I'd like
#to use variables or something to compile just the version you're interested in.

.PHONY: all

SOURCE = openscad
OUTPUT = builds
COMMONPARTS := feet gears sample_clips
TOOLS := actuator_assembly_tools condenser_lens_tool tube_lens_tool
body_versions = SS40 SS40-M LS65 LS65-M LS75 LS75-M
BODIES := $(body_versions:%=main_body_%)
illumination_versions = SS40 LS65 LS65_condenser LS75_condenser LS75_condenser_tall
ILLUMINATIONS := $(illumination_versions:%=illumination_and_rear_foot_%)
ALLPARTS := $(COMMONPARTS) $(TOOLS) $(BODIES) $(ILLUMINATIONS)
ALLSTLFILES := $(ALLPARTS:%=$(OUTPUT)/%.stl)
parameters_file := $(SOURCE)/microscope_parameters.scad
utilities_file := $(SOURCE)/utilities.scad
all_deps := $(parameters_file) $(utilities_file) 			#All targets depend on these

all: $(ALLSTLFILES)

cleanstl:
	rm $(STLFILES)

main_body_dep_names := compact_nut_seat dovetail logo
main_body_deps := $(all_deps) $(main_body_dep_names:%=$(SOURCE)/%.scad)

# The main body is different as there's several versions (TODO: automate this)
# It seems you can generate rules automatically, see for example
# https://stackoverflow.com/questions/3745177/multi-wildcard-pattern-rules-of-gnu-make

define VERSIONED_BUID
$(OUTPUT)/$1_$2.stl: $(SOURCE)/$1.scad $3
	openscad -o $$@ $$(4:%=-D %) $$<
endef
define BODY_VERSION
$(OUTPUT)/main_body_$1.stl: $(SOURCE)/main_body.scad $(main_body_deps)
	openscad -o $$@ $$(4:%=-D %) $$<
endef
#$(eval $(call BODY_VERSION, LS65, sample_z=65 big_stage=true motor_lugs=false))
#$(call VERSIONED_BUILD, main_body, LS65-M, $(main_body_deps) sample_z=65 big_stage=true motor_lugs=true)

$(OUTPUT)/main_body_LS65.stl: $(SOURCE)/main_body.scad $(main_body_deps) 
	openscad -o $@ -D sample_z=65 -D big_stage=true -D motor_lugs=false $<
$(OUTPUT)/main_body_LS65-M.stl: $(SOURCE)/main_body.scad $(main_body_deps) 
	openscad -o $@ -D sample_z=65 -D big_stage=true -D motor_lugs=true $<
$(OUTPUT)/main_body_LS75.stl: $(SOURCE)/main_body.scad $(main_body_deps) 
	openscad -o $@ -D sample_z=75 -D big_stage=true -D motor_lugs=false $<
$(OUTPUT)/main_body_LS75-M.stl: $(SOURCE)/main_body.scad $(main_body_deps) 
	openscad -o $@ -D sample_z=75 -D big_stage=true -D motor_lugs=true $<
$(OUTPUT)/main_body_SS40.stl: $(SOURCE)/main_body.scad $(main_body_deps) 
	openscad -o $@ -D sample_z=40 -D big_stage=false -D motor_lugs=false $<
$(OUTPUT)/main_body_SS40-M.stl: $(SOURCE)/main_body.scad $(main_body_deps) 
	openscad -o $@ -D sample_z=40 -D big_stage=false -D motor_lugs=true $<


illumination_dep_names := dovetail optics
illumination_deps := $(all_deps) $(illumination_dep_names:%=$(SOURCE)/%.scad)
$(OUTPUT)/illumination_and_rear_foot_SS40.stl: $(SOURCE)/illumination_and_rear_foot.scad $(illumination_deps) 
	openscad -o $@ -D sample_z=40 -D big_stage=false -D condenser=false $<
$(OUTPUT)/illumination_and_rear_foot_LS65.stl: $(SOURCE)/illumination_and_rear_foot.scad $(illumination_deps) 
	openscad -o $@ -D sample_z=65 -D big_stage=true -D condenser=false $<
$(OUTPUT)/illumination_and_rear_foot_LS65_condenser.stl: $(SOURCE)/illumination_and_rear_foot.scad $(illumination_deps) 
	openscad -o $@ -D sample_z=65 -D big_stage=true -D condenser=true $<
$(OUTPUT)/illumination_and_rear_foot_LS75_condenser.stl: $(SOURCE)/illumination_and_rear_foot.scad $(illumination_deps) 
	openscad -o $@ -D sample_z=75 -D big_stage=true -D condenser=true $<
$(OUTPUT)/illumination_and_rear_foot_LS75_condenser_tall.stl: $(SOURCE)/illumination_and_rear_foot.scad $(illumination_deps) 
	openscad -o $@ -D sample_z=75 -D big_stage=true -D condenser=true -D foot_height=26 $<

$(OUTPUT)/%.stl: $(SOURCE)/%.scad $(all_deps)
	openscad -o $@ $<

    
