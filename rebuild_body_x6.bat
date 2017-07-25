rem "This batch file recompiles the four standard versions of the microscope."

"C:\Program Files\OpenSCAD\openscad.com" -o builds/body_SS.stl -D motor_lugs=false -D big_stage=false OpenSCAD/main_body.scad
"C:\Program Files\OpenSCAD\openscad.com" -o builds/body_SS-M.stl -D motor_lugs=true -D big_stage=false OpenSCAD/main_body.scad
"C:\Program Files\OpenSCAD\openscad.com" -o builds/body_LS65.stl -D motor_lugs=false -D big_stage=true -D sample_z=65 OpenSCAD/main_body.scad
"C:\Program Files\OpenSCAD\openscad.com" -o builds/body_LS65-M.stl -D motor_lugs=true -D big_stage=true -D sample_z=65 OpenSCAD/main_body.scad
"C:\Program Files\OpenSCAD\openscad.com" -o builds/body_LS75.stl -D motor_lugs=false -D big_stage=true -D sample_z=75 OpenSCAD/main_body.scad
"C:\Program Files\OpenSCAD\openscad.com" -o builds/body_LS75-M.stl -D motor_lugs=true -D big_stage=true -D sample_z=75 OpenSCAD/main_body.scad

rebuild_illumination.bat
rebuild_accessories.bat

