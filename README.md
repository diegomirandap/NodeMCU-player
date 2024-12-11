2 NodeMCU devices used together to play any musical track.

First step: Pairing the devices
Each one of the files go to the device which will represent either the Accesss Point, the Node responsible for enabling the Wi-Fi connection, in which hte Station device will connect ain by this be paired.

Second step: Calculate the latency between devices
Upon connection, the Station device will open an UDP port, used for the comunication between devices and send a message containing the clock of the system, at the time before sending the message, that will be promptly returned by the AP. After recieving the same message, the Station will measure the clock again, to obtain the time difference. This process will be repeated for another 2 times, in order to obtain an avarege time, which will be used for guaranteing both devices will play the sounds in sync.

Third step: Reproduce the soundtrack
After taking a delay, the Station will send a special message to the AP indicating to start playing. The Station will wait the average message delay, in order to in sync reproduction, while the AP will start at the time of recieving the special message.
