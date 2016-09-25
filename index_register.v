//store the index of the 256 registers file
module index_register (
  input CLK,
  input RESET,
  input RESET_INsig,
  input DTMBsig,
  
  input [7:0] input_index,
  output reg [7:0] output_index
  );
  
  always @ (negedge CLK)
    begin
      if(RESET_INsig == 1)
        begin
          output_index <= 1'b0;
        end
      else if(RESET == 1 && DTMBsig == 0)
        begin
          output_index <= 1'b0;
        end
      else 
        begin
          output_index <= input_index;
        end
    end
endmodule 