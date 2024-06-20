
# RISC-V Microprocessor & DSP Element

Welcome to the RISC-V Microprocessor & DSP Element project repository! This project showcases the design and implementation of a microprocessor based on the RISC-V instruction set architecture (ISA) with an integrated digital signal processing (DSP) coprocessor. This README provides an overview of the project, key features, and instructions on how to get started.

## Table of Contents
1. [Project Overview](#project-overview)
2. [RISC-V CPU](#risc-v-cpu)
   - [Overview](#overview)
   - [Pipeline Architecture](#pipeline-architecture)
   - [Memory-Mapped I/O Architecture](#memory-mapped-io-architecture)
   - [Dedicated LWCP Instruction](#dedicated-lwcp-instruction)
   - [Verification & Validation](#verification-validation)
3. [DSP Accelerator](#dsp-accelerator)
   - [Overview](#overview-1)
   - [Image Buffer](#image-buffer)
   - [Direct Memory Access (DMA) Convention](#direct-memory-access-dma-convention)
   - [Processing Element](#processing-element)
   - [Video Driver & Video Memory](#video-driver-video-memory)
   - [Verification & Validation](#verification-validation-1)
4. [UART Bootloader](#uart-bootloader)
   - [Bootloader Protocol & Architecture](#bootloader-protocol-architecture)
   - [Verification & Validation](#verification-validation-2)
5. [Synthesis Report](#synthesis-report)
6. [Implementation & Application Software](#implementation-application-software)
7. [Project Final Demo](#project-final-demo)
8. [Discussion](#discussion)
   - [Performance Results](#performance-results)
   - [Challenges](#challenges)
   - [Societal Implications](#societal-implications)
   - [Engineering Standards Employed](#engineering-standards-employed)
9. [Future Improvements](#future-improvements)
10. [Getting Started](#getting-started)
11. [Contributing](#contributing)
12. [License](#license)

## Project Overview

This project details the design and implementation of a microprocessor based on the RISC-V instruction set architecture along with an integrated DSP coprocessor. The processor features a Harvard architecture for efficient single-cycle data access. It includes memory-mapped I/O for interfacing with peripherals and the DSP coprocessor, which performs efficient image processing tasks. The project demonstrates the strengths of a hardware-focused design in multimedia applications that involve processing and displaying images.

## RISC-V CPU

### Overview

The CPU is a single-core pipelined RISC-V Base 32-I architecture with a Harvard-style memory model. It features a 32x32b Register File, byte-addressable data memory, and a memory-mapped I/O interface.

### Pipeline Architecture

The pipelined architecture includes data and control hazard solutions, enabling efficient processing and reduced stall cycles.

### Memory-Mapped I/O Architecture

The memory-mapped I/O architecture allows for seamless interfacing with various peripherals.

### Dedicated LWCP Instruction

The LWCP instruction behaves like a load word (LW) instruction but stalls upstream stages until the coprocessor returns a DONE response, ensuring efficient synchronization between the CPU and the coprocessor.

### Verification & Validation

Comprehensive verification and validation were conducted using a RISC-V toolchain environment to ensure the reliability and correctness of the CPU design.

## DSP Accelerator

### Overview

The DSP accelerator is designed to handle common image-processing tasks, interfacing with a VGA driver to display images on a monitor.

### Image Buffer

The image buffer allows for fast dual-port access, maximizing FPGA memory utilization.

### Direct Memory Access (DMA) Convention

DMA is used for efficient data transfer between the image buffer and processing elements.

### Processing Element

The primary processing element performs RGB to grayscale conversion, convolution, and basic compute operations with single-cycle compute capabilities.

### Video Driver & Video Memory

The video driver and memory enable efficient storage, access, and visualization of images.

### Verification & Validation

The DSP accelerator was verified by comparing expected outputs generated in Python with actual accelerator outputs.

## UART Bootloader

### Bootloader Protocol & Architecture

The UART bootloader allows for reprogramming of device memories, avoiding frequent recompilation.

### Verification & Validation

The bootloader's functionality was validated through extensive testing.

## Synthesis Report

Details about the synthesis process, including resource utilization and timing analysis, are provided in the synthesis report.

## Implementation & Application Software

Application software and automation scripts were developed to support device operation, with implementations deployed on an Altera DE-1 FPGA.

## Project Final Demo

The final demonstration showcases the integrated CPU and DSP accelerator's capabilities in multimedia applications.

## Discussion

### Performance Results

The coprocessor implementation resulted in significant speedup and reduced application code.

### Challenges

Various challenges encountered during the project are discussed, along with the solutions implemented.

### Societal Implications

The project's potential societal impact is analyzed.

### Engineering Standards Employed

The project adheres to relevant engineering standards to ensure quality and reliability.

## Future Improvements

Future improvements include hardware-based image compression and programmable convolutional arrays for advanced neural network inferencing.

## Getting Started

### Prerequisites

- Altera DE-1 FPGA board
- Quartus II software
- RISC-V toolchain

### Installation

1. Clone the repository.
2. Follow the setup instructions in the documentation.

## Contributing

We welcome contributions! Please read our [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to contribute to this project.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

For more detailed information, please refer to the [Final Report](path-to-ECE554_Final_Report.docx) and [Capstone Poster](path-to-CapstonePoster.pdf).
