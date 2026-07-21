onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /alu_tb/dut/clk
add wave -noupdate /alu_tb/dut/rst
add wave -noupdate -expand -group inputs /alu_tb/dut/a
add wave -noupdate -expand -group inputs /alu_tb/dut/b
add wave -noupdate -expand -group inputs /alu_tb/dut/alu_fun
add wave -noupdate -expand -group inputs /alu_tb/dut/alu_enable
add wave -noupdate -expand -group outputs /alu_tb/dut/alu_out
add wave -noupdate -expand -group outputs /alu_tb/dut/alu_out_comb
add wave -noupdate -expand -group outputs /alu_tb/dut/alu_valid
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {35001 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {79383 ps}
