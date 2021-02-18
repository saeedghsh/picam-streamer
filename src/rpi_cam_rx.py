#!/usr/bin/env python
"""Launch a reciever for pi camera streaming"""

from __future__ import print_function
import argparse
import io
import socket
import struct
from PIL import Image
import numpy as np
import cv2


def reciever(port: int):
    ''''''
    # Start a socket listening for connections on 0.0.0.0:8000
    # (0.0.0.0 means all interfaces)
    server_socket = socket.socket()
    server_socket.bind(('0.0.0.0', port))
    print("listening for connection on port {:d}".format(port))
    server_socket.listen(0)

    # Accept a single connection and make a file-like object out of it
    connection = server_socket.accept()[0].makefile('rb')

    try:
        while True:
            # Read the length of the image as a 32-bit unsigned
            # int. If the length is zero, quit the loop
            image_len = struct.unpack(
                '<L', connection.read(struct.calcsize('<L')))[0]
            if not image_len or (cv2.waitKey(1) & 0xFF == ord('q')):
                break

            # Construct a stream to hold the image data and read the
            # image data from the connection
            image_stream = io.BytesIO()
            image_stream.write(connection.read(image_len))
            # Rewind the stream, open it as an image with PIL and do
            # some processing on it
            image_stream.seek(0)
            image = Image.open(image_stream)

            gray = cv2.cvtColor(np.array(image), cv2.COLOR_BGR2GRAY)
            cv2.imshow(str(port), gray)

    finally:
        connection.close()
        server_socket.close()
        cv2.destroyAllWindows()


def argument_parser():
    parser = argparse.ArgumentParser(
        description="Launch Reciever",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        '-p', '--port',
        type=int,
        default=8000,
        help='port number for the reciever',
    )
    return parser.parse_args()


if __name__ == '__main__':
    args = argument_parser()
    reciever(args.port)
