rem "This batch file recompiles the four standard versions of the microscope."

"C:\Program Files\OpenSCAD\openscad.com" -o builds/body_SS.stl -D motor_lugs=false -D big_stage=false OpenSCAD/main_body.scad
"C:\Program Files\OpenSCAD\openscad.com" -o builds/body_SS-M.stl -D motor_lugs=true -D big_stage=false OpenSCAD/main_body.scad
"C:\Program Files\OpenSCAD\openscad.com" -o builds/body_LS65.stl -D motor_lugs=false -D big_stage=true -D sample_z=65 OpenSCAD/main_body.scad
"C:\Program Files\OpenSCAD\openscad.com" -o builds/body_LS65-M.stl -D motor_lugs=true -D big_stage=true -D sample_z=65 OpenSCAD/main_body.scad
"C:\Program Files\OpenSCAD\openscad.com" -o builds/body_LS75.stl -D motor_lugs=false -D big_stage=true -D sample_z=75 OpenSCAD/main_body.scad
"C:\Program Files\OpenSCAD\openscad.com" -o builds/body_LS75-M.stl -D motor_lugs=true -D big_stage=true -D sample_z=75 OpenSCAD/main_body.scad

rem "We now also generate illumination modules"

"C:\Program Files\OpenSCAD\openscad.com" -o builds/illumination_and_back_foot_adj_SS.stl -D condenser=false -D big_stage=false OpenSCAD/illumination_and_rear_foot.scad
"C:\Program Files\OpenSCAD\openscad.com" -o builds/illumination_and_back_foot_adj_LS65.stl -D condenser=false -D big_stage=true -D sample_z=65 OpenSCAD/illumination_and_rear_foot.scad
"C:\Program Files\OpenSCAD\openscad.com" -o builds/illumination_and_back_foot_condenser_LS65.stl -D condenser=true -D big_stage=true -D sample_z=65 OpenSCAD/illumination_and_rear_foot.scad
"C:\Program Files\OpenSCAD\openscad.com" -o builds/illumination_and_back_foot_condenser_LS75.stl -D condenser=true -D big_stage=true -D sample_z=75 OpenSCAD/illumination_and_rear_foot.scad
