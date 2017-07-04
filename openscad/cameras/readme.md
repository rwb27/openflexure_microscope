OpenFlexure Microscope: Camera Mounts
=====================================

Curently, the OpenFlexure microscope will work with:
* Raspberry Pi camera module v2
* Raspberry Pi camera module v1
* Logitech C270 webcam (you need to dissassemble it and remove the microphone)
* USB camera with standard M12 lens (WaterScope source these from China)

The way this is done is that ``optics.scad`` includes one of the files in this folder, which defines the important functions/modules for interfacing with the camera.  These are then used to make the optics module accordingly.  Those functions are:

* ``camera_mount_height()``: a function that returns the height of the mount (above this height, we will make the optics module - this is the distance below the ground plane of the microscope body that the camera PCB will sit).
* ``camera_sensor_height()``: the distance above the PCB that the camera sensor sits - it's used in the optics module to calculate the position of the lens.
* ``camera_mount()``: a module that builds a mount for the camera.  If you print this on its own, it should create a flat(ish) structure, ``camera_mount_height()`` high, that fits onto the camera, with the sensor centred on the origin.

There are 5 options:
* picam_push_fit: mount for Raspberry Pi camera v1 (deprecated)
* picam2_push_fit: mount for Raspberry Pi camera v2 (deprecated)
* picam2_screw_in: mount for Raspberry Pi camera v2, using screws rather than push-fit (much less likely to damage the camera module)
* C270_mount: for Logitech C270 webcam
* usbcam_push_fit: this replaces the M12 lens holder on our USB camera.  The name is not right, while there was originally a push-fit mount, we now use the screws as it's much more reliable.

The ``picam2_screw_in.scad`` file also defines the cover for the bottom of the camera PCB.  There's no cover for the Logitech PCB, I often use a bit of extra-large heatshrink (it's thinner than a printed cover would be, which is helpful).  There's also a slide-on cover for the Pi camera module if you're using the older push-fit mounts, however I tend to avoid that; it's very easy to damage the delicate flex that connects the sensor to the PCB.  Use the screw on mount instead.  This probably works fine with the Pi camera module v1 as well.