-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
-- Date        : Mon Aug  3 15:31:18 2026
-- Host        : DESKTOP-DEP9CPL running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               d:/Vivado_Projects/Assignment/Assignment.srcs/sources_1/bd/nand_zynq_sys/ip/nand_zynq_sys_and_gate_0_0/nand_zynq_sys_and_gate_0_0_stub.vhdl
-- Design      : nand_zynq_sys_and_gate_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg484-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity nand_zynq_sys_and_gate_0_0 is
  Port ( 
    a : in STD_LOGIC;
    b : in STD_LOGIC;
    c : out STD_LOGIC
  );

end nand_zynq_sys_and_gate_0_0;

architecture stub of nand_zynq_sys_and_gate_0_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "a,b,c";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "and_gate,Vivado 2018.2";
begin
end;
