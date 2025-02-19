# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    # Set the input values you want to test
    dut.ui_in.value = 3
    dut.uio_in.value = 2

    # Wait for one clock cycle to see the output values
    await ClockCycles(dut.clk, 12)

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    assert dut.uo_out.value == 6

for _ in range(10):  # Adjust iterations as needed
    print(f"Time={get_sim_time('ns')} ns | ui_in={dut.ui_in.value} | uo_out={dut.uo_out.value} | rst_n={dut.rst_n.value} | clk={dut.clk.value}")
    await Timer(10, units="ns")  # Wait for some time



    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
