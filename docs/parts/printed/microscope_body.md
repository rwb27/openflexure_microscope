# Microscope Body
Microscope Body

## Details
*   **Material used:** 0.1
*   **Material units:** KG

## Media
*   ![](./stl/main_body_SS.stl)
*   ![](./stl/main_body_SS-M.stl)
*   ![](./stl/main_body_LS65.stl)
*   ![](./stl/main_body_LS65-M.stl)

# Manufacturing Instructions
## Step
This should be printed without support material.  On smaller/less well calibrated machines, I print this part on its own and then print the rest of the parts in a second print.  Which version of the body you need depends on two things: firstly, whether you want to use a large optics module (versions with LS65 in the name) or a small one (versions with SS), and secondly whether you want attachment lugs for motors (files with -M in the name).  All the files start with `body_`.You need the SS version if you're using a Raspberry Pi camera or a Logitech C270 camera, together with the lens that came on the camera.  If you're using a microscope objective, or the USB camera with M12 lens, you need the LS65 version.  The microscope body takes around 8 hours on a RepRapPro Ormerod (and many other low-end printers) or about 5 hours on Ultimaker, MakerBot, and the like. 
### Media
*   ![](./images/main_body.jpg)

## Step
After printing, you should run a 3mm drill bit through the 3mm holes in each actuator, to ensure the screws can rotate freely.  If you don't have a drill, an M3 screw should do...
### Media
*   ![](./images/main_body_drill.jpg)

## Step
If the bottom layer has oozed out too much, or if you used a brim (not reccommended) you might need to clean up the bottom so it looks like this - it's important that the moving parts aren't stuck to the body with a thin layer of plastic (this most often happens around the struts connecting the objective clip to the rest of the microscope).
### Media
*   ![](./images/main_body_bottom.jpg)

## Step
You may need to use needle-nose pliers to pull strings of plastic from the underside of the microscope stage or the underside of the caps of the actuator columns.  If your printer is correctly calibrated there shouldn't be much, and I often get away without any - but some printers (particularly if using ABS) are prone to a bit of "spaghetti" under the stage.



