import logging
import serial
from contextlib import closing
from typing import BinaryIO
import time
from itertools import tee, islice


def send_byte(ser: serial.Serial, byte_data: int) -> None:
    """Send a single byte of data over serial."""
    ser.write(byte_data.to_bytes(1, 'little'))

def bootloader_ib(ser: serial.Serial, hex_file: BinaryIO, target_memory: int) -> None:
    """
    Bootloader function to write data from a hex file to memory according to the new protocol.

    Args:
        ser (serial.Serial): The serial port object.
        hex_file (BinaryIO): The binary file containing the hex data.
        target_memory (int): The target memory to write to (0 for instruction memory, 1 for data memory, 2 for image buffer).
    """
    
    # Ensure target_memory is either 0, 1, or 2
    if target_memory not in (0, 1, 2):
        raise ValueError("Invalid target memory specified. Use 0 for instruction memory, 1 for data memory, and 2 for image buffer.")

    addr_count = 0x0


    for idx, line in enumerate(hex_file):
        hex_line = line.strip()  # Remove newline characters
        if not hex_line:  # Skip empty lines
            continue

        # Send destination
        send_byte(ser, int("001", 2))
        # time.sleep(wait_time)


        # Send addr
        print(addr_count)
        send_byte(ser, addr_count & 0xFF)
        send_byte(ser, (addr_count >> 8) & 0xFF)
        addr_count += 1

        
        # Send data high and low bytes
        NUM_ITERATIONS = 384

        data = int(hex_line, 16)  # Converts hex string to an integer

        for i in range(NUM_ITERATIONS):
            send_byte(ser, (data) & 0xFF)
            data >>= 8

    logging.info('Bootloading to image buffer is completed')


    

def bootloader_dm(ser: serial.Serial, hex_file: BinaryIO, target_memory: int) -> None:
    """
    Bootloader function to write data from a hex file to memory according to the new protocol.

    Args:
        ser (serial.Serial): The serial port object.
        hex_file (BinaryIO): The binary file containing the hex data.
        target_memory (int): The target memory to write to (0 for instruction memory, 1 for data memory).
    """
    # Ensure target_memory is either 0 or 1 or 2
    if target_memory not in (0, 1, 2):
        raise ValueError("Invalid target memory specified.")

    NUM_ITERATIONS = 4

    it = iter(hex_file)
    while True:
        lines = list(islice(it, 2))  # Get a list of the next 2 lines

        if not lines:
            break

        address_line, data_line = lines

        address_line = address_line.strip()
        data_line = data_line.strip()

        address = int(address_line[0:8], 16)  # Convert address to int
        data = int(data_line[0:8], 16)  # Convert data to int


        send_byte(ser, int("010", 2))
        
        # Send address high and low bytes (lower two bytes)
        send_byte(ser, address & 0xFF)
        send_byte(ser, (address >> 8) & 0xFF)

        # Send data high and low bytes
        for i in range(NUM_ITERATIONS):
            send_byte(ser, (data) & 0xFF)
            data >>= 8

    logging.info('Bootloading to data memory is completed')

def bootloader_im(ser: serial.Serial, hex_file: BinaryIO, target_memory: int) -> None:
    """
    Bootloader function to write data from a hex file to memory according to the new protocol.

    Args:
        ser (serial.Serial): The serial port object.
        hex_file (BinaryIO): The binary file containing the hex data.
        target_memory (int): The target memory to write to (0 for instruction memory, 1 for data memory).
    """
    # Ensure target_memory is either 0 or 1 or 2
    if target_memory not in (0, 1, 2):
        raise ValueError("Invalid target memory specified.")

    address = 0x0 #int(0, 16)
    NUM_ITERATIONS = 4


    # Read hex file lines, converting each line to binary data
    for line in hex_file:
        hex_line = line.strip()  # Remove newline characters
        if not hex_line:  # Skip empty lines
            continue

        send_byte(ser, int("100", 2))

        data = int(hex_line[0:8], 16)

        # Send address high and low byte1qs
        send_byte(ser, address & 0xFF)
        send_byte(ser, (address >> 8) & 0xFF)
        address += 1

        # Send data high and low bytes
        for i in range(NUM_ITERATIONS):
            send_byte(ser, (data) & 0xFF)
            data >>= 8

    logging.info('Bootloading to instruction memory is completed')

if __name__ == '__main__':
    import sys

    logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')
    
    uart_port = 'COM4' # if len(sys.argv) < 3 else sys.argv[2]  # default COM3

    try:
        ser = serial.Serial(port=uart_port)
    except:
        uart_port_is_open = False
        print(uart_port + ' is not avaiable')
    else:
        print(uart_port + ' is avaiable')

    ser.close()

    target_memory = int(sys.argv[1])  # Expect the user to specify the target memory as the first argument
    logging.info(f'Using UART port: {uart_port}. Target memory: {"Instruction" if target_memory == 0 else "Data" if target_memory == 1 else "Image Buffer"}')

    with closing(serial.Serial(port=uart_port, baudrate=57600, bytesize=serial.EIGHTBITS,
                               stopbits=serial.STOPBITS_ONE, parity=serial.PARITY_NONE,
                               xonxoff=0, rtscts=0, timeout=2)) as ser:
        with open(sys.argv[2], 'rb') as hex_file:
            if(target_memory == 0):
                bootloader_im(ser, hex_file, target_memory)
            elif(target_memory == 1):
                bootloader_dm(ser, hex_file, target_memory)
            elif(target_memory == 2):
                bootloader_ib(ser, hex_file, target_memory)
            else:
                raise ValueError("Invalid target memory specified. Use 0 for instruction memory, 1 for data memory, and 2 for image buffer.")
