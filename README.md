# group4-hw-ID-DrumTeam
Homework #3 <br>Hollow Hearts

Group composition:
<br>Brusca Alfredo 10936149
<br>Marazzi Alice 10625416
<br>Pomarico Riccardo 10661306

<img width="1462" alt="intro" src="https://github.com/polimi-cmls-23/group4-hw-ID-DrumTeam/assets/79704727/0b7883cf-2a76-41be-b62e-6265a66342fc">

Hollow Hearts is an interactive horror experience generator. The application reads your heartbeat and generates ambient music accordingly. The heartbeat is read through the DFRobot Heart Rate Sensor with Gravity Interface, and it is sent to Arduino UNO. Through the Arduino IDE we upload the script that reads the heartbeat, flashes the Gravity Digital RED LED Light Module and sends signals through serial communication.

The application has three possible scenarios: Haunted House, Scary Forest and Abandoned Church. Each scenario has some characterizing sounds that are played on a tempo based on the heartbeat.

<img width="1462" alt="haunted house" src="https://github.com/polimi-cmls-23/group4-hw-ID-DrumTeam/assets/79704727/9b14b545-ab14-47d9-b929-342ef0939a2d">

The GUI is characterized by some buttons that allow the user to choose the scenario and a “Run Away” button to go back to the intro scene. In each scenario there also three volume sliders that allow to change the volume of the characterizing sounds.

This application can be used to enhance the experience in several different fields, from horror games with immersive tools such as VR to movies and audio books.
<br>As our heartbeat tends to match what we are experiencing as we are experiencing it, adapting an ambient sound to the heartbeat itself is an interesting feature that can be studied and explored.
