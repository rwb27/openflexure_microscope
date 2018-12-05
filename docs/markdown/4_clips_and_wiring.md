# Sample mounting and wiring

# Requirements
## Parts
*   1 Microscope body, with 3 assembled actuators, an optics module, and the illumination attached.
*   2 [M3x8mm screws](./parts/m3x8mm_screws)
*   2 [Sample clips](./parts/sample_clips)
*   1 [Raspberry Pi](./parts/raspberry_pi)


# Assembly Instructions
## Step 1
Plug the LED cable into the GPIO connector on the Raspberry Pi, to the 0v and 5v lines.  These are the second and third pins from the top of the connector, on the outside edge - pins number 4 and 6.

Plug in the camera to the camera connector as described in the [Raspberry Pi learning materials](https://projects.raspberrypi.org/en/projects/getting-started-with-picamera) (the connector is next to the Ethernet port, and the contacts on the cable face the port, i.e. they face away from the tab on the plug).
![Raspberry Pi GPIO pins](./images/pi_gpio.jpg)

## Step 2
If you are using a tall optics module, e.g. if you are using a Plan corrected objective, you may need to fit a sample riser between the microscope body and the microscope slide.

## Step 3
After this, there are only the sample clips to go – exactly where you place these will depend on the samples you intend to use, but in any case you simply push the M3 screws into the clips, then screw down into the holes on the stage.
![](./images/sample_clip_3.jpg)
![](./images/sample_clip_0.jpg)
![](./images/sample_clip_1.jpg)
![](./images/sample_clip_2.jpg)
![](./images/sample_clip_3.jpg)
![](./images/sample_clip_4.jpg)
![](./images/sample_clip_5.jpg)
![](./images/sample_clip_6.jpg)

## Step 4
Your microscope is now complete – happy observing!
You might want to consult the [camera module documentation](http://www.raspberrypi.org/documentation/usage/camera/) or [raspicam documentation](http://www.raspberrypi.org/documentation/usage/camera/raspicam/README.md) if you need a hand setting up the camera.
![](./images/microscope_complete_1.jpg)
![](./images/microscope_complete_2.jpg)
![](./images/microscope_complete_3.jpg)
![](./images/microscope_complete_4.jpg)
