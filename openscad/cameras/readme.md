OpenFlexure Microscope: Camera Mounts
=====================================

Curently, the OpenFlexure microscope will work with:
* Raspberry Pi camera module v2 (v1 is possible but deprecated, as it's discontinued)
* Logitech C270 webcam (you need to dissassemble it and remove the microphone)
* USB camera with standard M12 lens (WaterScope source these from China)

The way this is done is that ``optics.scad`` includes ``camera.scad``, which defines the important functions/modules for interfacing with the camera.  These are then used to make the optics module accordingly.  The variable ``camera`` (defined in  Those functions are:

* ``camera_mount_height()``: a function that returns the height of the mount (above this height, we will make the optics module - this is the distance below the ground plane of the microscope body that the camera PCB will sit).
* ``camera_sensor_height()``: the distance above the PCB that the camera sensor sits - it's used in the optics module to calculate the position of the lens.
* ``camera_mount()``: a module that builds a mount for the camera.  If you print this on its own, it should create a flat(ish) structure, ``camera_mount_height()`` high, that fits onto the camera, with the sensor centred on the origin.

There are 5 options:
* picamera_2: mount for Raspberry Pi camera v2, using screws rather than push-fit (much less likely to damage the camera module)
* logitech_c270: for Logitech C270 webcam
* m12: this replaces the M12 lens holder on our USB camera.  It should work with most cameras that have an M12 lens held onto the board by two screws.

The ``picamera_2.scad`` file also defines the cover for the bottom of the camera PCB.  There's no cover for the Logitech PCB, I often use a bit of extra-large heatshrink (it's thinner than a printed cover would be, which is helpful).

Previous versions of the microscope had push-fit mounts for the Pi camera v1 and v2, but it was very easy to break the delicate flex on the camera module when fitting these, so they are now removed.  See previous versions if you need those.