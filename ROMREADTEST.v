
module ROMREADTEST (
	input clock,
	input [7:0] addr,
	input ready,
	output [15:0] read
);


ROM	ROM_inst (
	.address ( addr ),
	.clock ( clock ),
	.rden ( ready ),
	.q ( read )
	);

endmodule
