# Raspberry Pi Camera Streamer
A service for streaming images from raspberry pi camera


## laundry list
- [x] don't run docker in interactive mode on TX side... and RX
- [x] build a single docker images, run multiple container
- [ ] deprecate usage of `cv2` in rx, or find a way to install it
      easily (doesn't play nice with pip)!
- [ ] split visualizer away from rx into two separate processes

- [ ] `pip install picam` issue

- [ ] lancher should not always launch rx on local
      machine. E.g. instead of visualizing on local, maybe need to run
      some computation on Jetson.

- [ ] use ptp for time sync
- [ ] use LCM for streaming
- [ ] use protobuf?

- [ ] can picamera capture on a synced trigger to synch the capture of multiple camera?
- [ ] create a prroper stack: rx/tx, ptp, compute stuff, visualize
