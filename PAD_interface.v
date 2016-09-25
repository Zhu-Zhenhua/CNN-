module PAD_interface(
	input [7:0] DATA_in,
	input [2:0] RANGEIN,
	input CLK,
	output reg [63:0] DATA_OUT
	);
	always @(posedge CLK)
		begin
			DATA_OUT[RANGEIN*8+7-:8] <= DATA_in;
		end
endmodule