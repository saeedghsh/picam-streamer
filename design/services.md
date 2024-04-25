### Functional Requirements
Each service on each machine runs independently, encapsulating its own domain logic.

#### Image Capture Service
* purpose: capture and steam images from a camera
* input
  * camera image from HW (not network/channel)
  * camera config, if needed
* output (channel: `image/stream`)
  * RGB image
  * meta data:
    * `timestamp`
    * `camera_id` (if needed)
* operational requirement
  * Start/Stop Capability
  * Logging: diagnostics
  * capture trigger (for synchronous capture): `none`
* performance/functional requirement
  * frame rate: `any`
  * resolution: `any`
  * latency: `any`
  * reliability: `any`
* security requirements:
  * authentication: `none`
  * encryption: `none`
* dependencies
  * camera driver
  * messaging system lib
* maintenance and monitoring
  * Health Checks: expose an endpoint (or a method) for health checking
  * Monitoring: monitoring of the throughput to ensure it meets performance requirements.
  * Service Recovery: mechanisms to recover from failures

#### Object Detection Service
* purpose: processes images, object detection
* input:
  * RGB image + timestamp
* output (channel: `detection/results`)
  * object detection: list of detected objects per image, each object with a bounding box (coordinates), type (e.g., car, person), and confidence score.
  * metadata:
    * `timestamp` of the image to correlate results with the specific frame.
    * `camera_id` of the image to correlate results with the specific frame.
* operational requirement
  * start/Stop Capability
  * configuration (e.g. object detection parameters)
  * logging: diagnostics
* performance/functional requirement
  * processing time: should process each image and publish results in less than $\frac{1}{f_c}$, where $f_c$ is the frequency of the image capture service. If a single object detection service is responsible for processing channels of multiple image capture services, the processing time per image should be less than $\frac{1}{f_c}\times n_c$ where $n_c$ is the number of cameras streaming images. For real-time operation purposes, regardless of the number of image capture services, the total processing time of all incoming streams together should not exceed 200 ms.
  * accuracy/precision: `any`
  * reliability
    * service should not crash in presence of a backlog in channel
    * service should not crash if input image is corrupt
* security requirements:
  * authentication: `none`
  * encryption: `none`
* dependencies
  * object detection library
  * object detection model/weights
  * messaging system lib
  * GPU and drivers
  * Health Checks: expose an endpoint (or a method) for health checking
  * Monitoring: monitoring of the throughput to ensure it meets performance requirements.
  * Service Recovery: mechanisms to recover from failures, such as automatic reconnection to message brokers upon disconnection.

#### Visualization Service
* purpose: visualizes the images and detected objects
* input:
  * RGB image + timestamp
  * object detections + timestamp
* output 
  * images overlaid with detection results for display in on a user interface.
  * images also published to channel in case of data logging feature
* operational requirement
  * configuration
  * user interaction
  * logging: diagnostics
  * multi-stream: toggle between different image steams or feature a multi-display
* performance/functional requirement
  * processing time: less than 200 ms for real-time operation purpose.
  * synchronization: associate image to corresponding object detection result based on timestamps
  * association: 
  * reliability
    * service should not crash in presence of a backlog in channel
    * service should not crash if input image is corrupt
* security requirements:
  * authentication: `none`
  * encryption: `none`
* dependencies
  * GUI lib
  * messaging system lib
* maintenance and monitoring
  * Health Checks: expose an endpoint (or a method) for health checking
  * Monitoring: monitoring of the throughput to ensure it meets performance requirements.
  * Service Recovery: mechanisms to recover from failures, such as automatic reconnection to message brokers upon disconnection.

#### More services and features for later
* Data Logger (that subscribes to channels and store data, not the loggers of the services)
* Monitoring and health check service
* PTP
* multi sensor integration
* Control Signal, if a mobile robot platform is introduced
* Video compression, if the number of sensors increase too much