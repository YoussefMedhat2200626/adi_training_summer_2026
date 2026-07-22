-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
-- Date        : Wed Jul 22 15:53:12 2026
-- Host        : Martin running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               c:/Users/johns/Desktop/tasks/ADI/adi_training_summer_2026/fpga_labs/Assignment_2/project_2/project_2.srcs/sources_1/bd/nand_soc/ip/nand_soc_and_gate_0_0/nand_soc_and_gate_0_0_stub.vhdl
-- Design      : nand_soc_and_gate_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg484-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity nand_soc_and_gate_0_0 is
  Port ( 
    a : in STD_LOGIC;
    b : in STD_LOGIC;
    y : out STD_LOGIC
  );

end nand_soc_and_gate_0_0;

architecture stub of nand_soc_and_gate_0_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "a,b,y";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "and_gate,Vivado 2018.2";
begin
end;
