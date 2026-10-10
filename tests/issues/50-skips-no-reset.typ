
#import "../../codly.typ" as codly

#set page(height: auto, margin: 5pt, width: 450pt)

= Should have a skip
#codly.new(skips: ((9, 9),), ```py
def start_server():
    # Create a socket
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    # Setup address and port
    host = '10.60.10.26'
    port = 12345
    server_socket.bind((host, port))

    # Start waiting for connections
    server_socket.listen(1)
    print(f"Server listening on {host}:{port}...")
```)

= Should not have a skip

#codly.new(```py
def start_server():
    # Create a socket
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    # Setup address and port
    host = '10.60.10.26'
    port = 12345
    server_socket.bind((host, port))

    # Start waiting for connections
    server_socket.listen(1)
    print(f"Server listening on {host}:{port}...")
```)
