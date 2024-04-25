# Distributed Object Detection

## sketching out the outline

### Services Functional Requirements
Each service on each machine runs independently, encapsulating its own
domain logic.

#### Image Capture Service
* purpose: capture and steam images from a camera
* input
  * camera image from HW (not network/channel)
  * camera config, if needed
* output (channel: `image/stream`)
  * RGB image
  * meta data:
    * timestamp
    * camera ID (if needed)
* operational requirement
  * Start/Stop Capability
  * Logging: diagnostics
  * capture trigger (for synchronous capture): NONE
* performance/functional requirement
  * frame rate: ANY
  * resolution: ANY
  * latency: ANY
  * reliability: ANY
* security requirements:
  * authentication: NONE
  * encryption: NONE
* dependencies
  * camera driver
  * messaging lib
* maintenance and monitoring
  * Health Checks: Should expose an endpoint or a method for health checking to facilitate monitoring and alerting on service status.?
  * Monitoring: Implements monitoring of the throughput to ensure it meets performance requirements.

Question: what does in mean to expose an endpoint or a method for health check?
Question: what does it mean to implement a monitoring system? how would it look like?

#### Object Detection Service
* purpose: processes images, object detection
* input:
  * RGB image + timestamp
* output (channel: `detection/results`)
  * object detection: list of detected objects per image, each object with a bounding box (coordinates), type (e.g., car, person), and confidence score.
  * metadata:
    * timestamp of the image to correlate results with the specific frame.
    * camera ID of the image to correlate results with the specific frame.
* operational requirement
  * start/Stop Capability
  * configuration (e.g. object detection parameters)
  * logging: diagnostics
* performance/functional requirement
  * processing time: should process each image and publish results in less than the `1/frequency` of the "Image Capture Service"
  * accuracy/precision: any
  * reliability
    * service should not crash in presence of a backlog in channel
    * service should not crash if input image is corrupt
* security requirements:
  * authentication: none
  * encryption: None
* dependencies
  * object detection library
  * object detection model/weights
  * messaging lib
  * GPU and drivers
* maintenance and monitoring
  * Health Checks: Should expose an endpoint or a method for health checking to facilitate monitoring and alerting on service status.?
  * Monitoring: Implements monitoring of the processing latency and throughput to ensure it meets performance requirements.



TODO:
* there are two questions higher up about monitoring and health check, find the answer and update above sections
* complete Visualization Service functional requirements
* Move on to Communication protocol selection and so forth




#### Visualization Service
  * purpose: visualizes the images and detected objects
  * IN: subscribes to image channel `I`
  * IN: subscribes object detection channel `D`
  * performance: frame rendering faster than the frequency of the channel `I`
  * dependencies: Channel `I` and `D`
  * constraints: None

#### More services for later
* Logging - Data
* Logging - Diagnostics
* PTP
* Control Signal for Mobile platform

### Communication protocol
Services communicate through a message-brokering system using a
publish/subscribe model. This involves setting up topics (or
channels) for different types of data (images, detection results,
control signals, etc.).

Q: Help me choose Communication protocol
Not ROS, I don't want heavy dependency over such framework
Requirement: fast/efficient, and preferrably not too complicated

### Data Model and serialization Protocols:  
Q: Help me choose Data Model 
Definitly not JSON
Requirement: fast/efficient, and preferrably not too complicated
How about protobuf or LCM? are they different or are they used together?

### Implement Topic/Channel Design
Define topics in a way that aligns with how data flows between
services. For example, separate topics for raw images, processed data,
and control messages.

* topic names are descriptive and structured, following a naming
  convention

Question: what does it mean to implement the topics/channels?

### Interface Design
Design interfaces for each service focusing only on what data they need to expose or consume.
This helps in decoupling the system.
Use interface definition languages (IDL) if using gRPC or similar; otherwise, document your APIs thoroughly.

Question: how?
say for an image with given height-width-3channel
Or a python dict of object detection


### Service Discovery
TODO:  
How services find the message broker? something like Kubernetes' DNS
service, or a static configuration or a service discovery mechanism.

### Fault Tolerance and Reliability
TODO:  
Handling failure of a service. Health checks, retries, and perhaps a
dead-letter queue.

### Security
TODO: though proably don't really care at this stage  
The services should authenticate and authorized to publish or
subscribe to topics.

### practical matters
* Camera calibration
* Do we need a manager to spin up each service? Kubernetes?
  docker-compose? :(
* timestamping of data similarly supportted for each channel.
* naming conventions
* maintaining similar env (formatting/linting/naming_conv) over multiple repos
* Do I want multiple repos? Or should I keep all in one and just lunch
  different services depending on the machine? probably all in one is
  better.
* Do I need a build system? e.g. for maintaining the lib dependency
  and packaging as separating services? and building service images?
* how to distinguish/identify different services that publish similar
  channels? e.g. multiple image streams from different cameras?
* Network load monitoring. Wireshark?
* need plenty of mocking to be able to test services in isolation.
