-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
-- Date        : Wed Jul 22 15:53:12 2026
-- Host        : Martin running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim
--               c:/Users/johns/Desktop/tasks/ADI/adi_training_summer_2026/fpga_labs/Assignment_2/project_2/project_2.srcs/sources_1/bd/nand_soc/ip/nand_soc_and_gate_0_0/nand_soc_and_gate_0_0_sim_netlist.vhdl
-- Design      : nand_soc_and_gate_0_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7z020clg484-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity nand_soc_and_gate_0_0 is
  port (
    a : in STD_LOGIC;
    b : in STD_LOGIC;
    y : out STD_LOGIC
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of nand_soc_and_gate_0_0 : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of nand_soc_and_gate_0_0 : entity is "nand_soc_and_gate_0_0,and_gate,{}";
  attribute DowngradeIPIdentifiedWarnings : string;
  attribute DowngradeIPIdentifiedWarnings of nand_soc_and_gate_0_0 : entity is "yes";
  attribute IP_DEFINITION_SOURCE : string;
  attribute IP_DEFINITION_SOURCE of nand_soc_and_gate_0_0 : entity is "module_ref";
  attribute X_CORE_INFO : string;
  attribute X_CORE_INFO of nand_soc_and_gate_0_0 : entity is "and_gate,Vivado 2018.2";
end nand_soc_and_gate_0_0;

architecture STRUCTURE of nand_soc_and_gate_0_0 is
begin
y_INST_0: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => a,
      I1 => b,
      O => y
    );
end STRUCTURE;
