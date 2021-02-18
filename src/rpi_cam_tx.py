#!/usr/bin/env python
"""Launch a transmitter for pi camera streaming"""
from __future__ import print_function
import argparse
import io
import socket
import struct
import time
import picamera


# the python2.7 running on rpi doesn't support type hint!
# def transmitter(hostname: str, port: int, video_length: int):
def transmitter(hostname, port, video_length):
    ''''''
    # Connect a client socket to hostname:8000 (change hostname to the
    # hostname of your reciever)
    client_socket = socket.socket()
    client_socket.connect((hostname, port))

    # Make a file-like object out of the connection
    connection = client_socket.makefile('wb')
    print("connection set at {:s} - {:d}".format(hostname, port))

    try:
        camera = picamera.PiCamera()
        camera.resolution = (640, 480)
        # Start a preview and let the camera warm up for 2 seconds
        camera.start_preview()
        time.sleep(2)

        # Note the start time and construct a stream to hold image data
        # temporarily (we could write it directly to connection but in this
        # case we want to find out the size of each capture first to keep
        # our protocol simple)
        start = time.time()
        stream = io.BytesIO()
        print("stream about to begin...")

        for _ in camera.capture_continuous(stream, 'jpeg'):
            # Write the length of the capture to the stream and flush to
            # ensure it actually gets sent
            connection.write(struct.pack('<L', stream.tell()))
            connection.flush()
            # Rewind the stream and send the image data over the wire
            stream.seek(0)
            connection.write(stream.read())

            # If video_length is not None, and we've been capturing
            # for more than video_length seconds, quit
            if video_length and time.time() - start > video_length:
                break
            # Reset the stream for the next capture
            stream.seek(0)
            stream.truncate()
        # Write a length of zero to the stream to signal we're done
        connection.write(struct.pack('<L', 0))

    finally:
        connection.close()
        client_socket.close()


def argument_parser():
    parser = argparse.ArgumentParser(
        description="Launch transmitter",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        '-n', '--hostname',
        type=str,
        default='192.168.86.36',
        help='hostname of the reciever',
    )
    parser.add_argument(
        '-p', '--port',
        type=int,
        default=8000,
        help='port number for the reciever',
    )
    parser.add_argument(
        '-l', '--video-length',
        type=int,
        default=None,
        help='how long to transmit (in seconds)',
    )
    return parser.parse_args()


if __name__ == '__main__':
    args = argument_parser()
    transmitter(args.hostname, args.port, args.video_length)
