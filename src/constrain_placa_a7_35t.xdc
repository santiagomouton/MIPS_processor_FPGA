## This file is a general .xdc for the Arty A7-35 Rev. D and Rev. E
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

## Clock signal
set_property IOSTANDARD LVCMOS33 [get_ports { clk_in }];
set_property PACKAGE_PIN E3 [get_ports { clk_in }]; #IO_L12P_T1_MRCC_35 Sch=gclk[100]
# create_clock -period 10.00 -waveform {0 5} [get_ports { clk_in }]; #CLK100MHZ

## Switches
set_property IOSTANDARD LVCMOS33 [get_ports { reset }];
set_property PACKAGE_PIN A8 [get_ports { reset }]; #IO_L12N_T1_MRCC_16 Sch=sw[0]
#set_property -dict { PACKAGE_PIN C11   IOSTANDARD LVCMOS33 } [get_ports { sw[1] }]; #IO_L13P_T2_MRCC_16 Sch=sw[1]
#set_property -dict { PACKAGE_PIN C10   IOSTANDARD LVCMOS33 } [get_ports { sw[2] }]; #IO_L13N_T2_MRCC_16 Sch=sw[2]
#set_property -dict { PACKAGE_PIN A10   IOSTANDARD LVCMOS33 } [get_ports { sw[3] }]; #IO_L14P_T2_SRCC_16 Sch=sw[3]

## LEDs
set_property IOSTANDARD LVCMOS33 [get_ports { state_Iddle }];
set_property PACKAGE_PIN H5 [get_ports { state_Iddle }]; #IO_L24N_T3_35 Sch=led[4]
set_property IOSTANDARD LVCMOS33 [get_ports { state_Receive_Instruction }];
set_property PACKAGE_PIN J5 [get_ports { state_Receive_Instruction }]; #IO_25_35 Sch=led[5]
set_property IOSTANDARD LVCMOS33 [get_ports { state_Tx_data_to_computer }];
set_property PACKAGE_PIN T9 [get_ports { state_Tx_data_to_computer }]; #IO_L24P_T3_A01_D17_14 Sch=led[6]
set_property IOSTANDARD LVCMOS33 [get_ports { state_Continue }];
set_property PACKAGE_PIN T10 [get_ports { state_Continue }];

## USB-UART Interface
set_property IOSTANDARD LVCMOS33 [get_ports { debug_out }];
set_property PACKAGE_PIN D10 [get_ports { debug_out }]; #IO_L19N_T3_VREF_16 Sch=uart_rxd_out
set_property IOSTANDARD LVCMOS33 [get_ports { receiving }];
set_property PACKAGE_PIN A9 [get_ports { receiving }]; #IO_L14N_T2_SRCC_16 Sch=uart_txd_in

## Power Measurements 
#set_property -dict { PACKAGE_PIN B17   IOSTANDARD LVCMOS33     } [get_ports { vsnsvu_n }]; #IO_L7N_T1_AD2N_15 Sch=ad_n[2]
#set_property -dict { PACKAGE_PIN B16   IOSTANDARD LVCMOS33     } [get_ports { vsnsvu_p }]; #IO_L7P_T1_AD2P_15 Sch=ad_p[2]
#set_property -dict { PACKAGE_PIN B12   IOSTANDARD LVCMOS33     } [get_ports { vsns5v0_n }]; #IO_L3N_T0_DQS_AD1N_15 Sch=ad_n[1]
#set_property -dict { PACKAGE_PIN C12   IOSTANDARD LVCMOS33     } [get_ports { vsns5v0_p }]; #IO_L3P_T0_DQS_AD1P_15 Sch=ad_p[1]
#set_property -dict { PACKAGE_PIN F14   IOSTANDARD LVCMOS33     } [get_ports { isns5v0_n }]; #IO_L5N_T0_AD9N_15 Sch=ad_n[9]
#set_property -dict { PACKAGE_PIN F13   IOSTANDARD LVCMOS33     } [get_ports { isns5v0_p }]; #IO_L5P_T0_AD9P_15 Sch=ad_p[9]
#set_property -dict { PACKAGE_PIN A16   IOSTANDARD LVCMOS33     } [get_ports { isns0v95_n }]; #IO_L8N_T1_AD10N_15 Sch=ad_n[10]
#set_property -dict { PACKAGE_PIN A15   IOSTANDARD LVCMOS33     } [get_ports { isns0v95_p }]; #IO_L8P_T1_AD10P_15 Sch=ad_p[10]  

## Configuration options, can be used for all designs
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

## SPI configuration mode options for QSPI boot, can be used for all designs
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]