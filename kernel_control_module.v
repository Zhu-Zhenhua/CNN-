//choose the kernel mode
module kernel_control (
  input CLK,
  input RESET,
  input RESET_INsig,
  input DTMBsig,
  //kernel0 out_size = 8, kernel_num = 4 7period
  //kernel1 out_size = 4, kernel_num = 16 28period
  //kernel2 out_size = 2, kernel_num = 64 112period

  input [1:0] kernel_mode,
  input [1:0] KERNEL_MODEsig,

  //output reg [3:0] out_size,
  //output reg [6:0] kernel_num,
  output reg input_flag_kernel,
  output reg feedback_flag_kernel);
  
  reg [6:0] clk_counter;
  always @ (negedge CLK)
    begin
      if(RESET_INsig == 1)
        clk_counter <= 0;
      else if(RESET == 1 && DTMBsig == 0)
        clk_counter <= 0;
      else if(DTMBsig == 1)
        begin
          if(KERNEL_MODEsig == 2'b00 && clk_counter == 7'd8)
            clk_counter <= 0;
          else if(KERNEL_MODEsig == 2'b01 && clk_counter == 7'd32)
            clk_counter <= 0;
          else if(KERNEL_MODEsig == 2'b10 && clk_counter == 7'd127)
            clk_counter <= 0;
          else if(KERNEL_MODEsig == 2'b11)
            clk_counter <= 1;
          else 
            clk_counter <= clk_counter + 1;
        end
      else
        begin
          if(kernel_mode == 2'b00 && clk_counter == 7'd8)
            clk_counter <= 0;
          else if(kernel_mode == 2'b01 && clk_counter == 7'd32)
            clk_counter <= 0;
          else if(kernel_mode == 2'b10 && clk_counter == 7'd127)
            clk_counter <= 0;
          else if(kernel_mode == 2'b11)
            clk_counter <= 1;
          else 
            clk_counter <= clk_counter + 1;
        end
    end

  always @ (negedge CLK)
    begin
      if(RESET_INsig == 1)
        begin
          input_flag_kernel <= 1'b0;
          feedback_flag_kernel <= 1'b0;
        end
      else if(RESET == 1 && DTMBsig == 0)
        begin
          input_flag_kernel <= 1'b0;
          feedback_flag_kernel <= 1'b0;
        end
      else 
        begin
          if(clk_counter == 0)
            begin
              input_flag_kernel <= 1'b1;
              feedback_flag_kernel <= 1'b0;
            end
          else 
            begin
              input_flag_kernel <= 1'b0;
              feedback_flag_kernel <= 1'b1;  
            end
        end
    end
endmodule 