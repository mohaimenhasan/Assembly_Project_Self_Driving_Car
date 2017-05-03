# Assembly_Project_Self_Driving_Car
Self Drving Car using Assembly and Nios 2 Processor controlled by De1Soc. 
Have mulitple modes. Uses Lego Controllers
Can be conrtolled by a keyboard as well.


# Technical Description
The project will consist of a physical interface between the user and the program. 
The user will have special (white) tape on their hand. This distinct colour will be monitored continuously by sensors.
The sensors will be fastened on the car. Using the GP I/O interface, the sensors will relay information to the program. 
Depending on the movement of the hand, a Lego robot car will mirror that movement. 
For example, if the user moves their hand away from the sensor, the car will move forwards. 
If the user moves their hand towards the sensor, the car will move backwards. 
The car can also move side to side depending on the hand gestures as well, this can be implemented as an added feature. 
The movement of the Lego car will be through the Lego controller. 
The motors can be controlled through this interface. 
3 sensors will be placed in on the car so that sensor-read information can be confirmed by multiple sensors. 
When a sensor reads a change, it can interrupt the program and implement a change in motor settings. 
An added feature can be to use a ps2 keyboard interface to control the car. 
Depending on the arrow keys pressed, the motors can move the car in a certain direction. 
A pressed key, once again, can interrupt the motor and induce a desired motion. 
Finally, the car can be started with a push button with an interrupt.
