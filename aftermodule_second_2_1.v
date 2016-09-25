//-----------2.1 update-------------
//修改crossbar的输出模式
module aftermodule_second #(
  parameter COMPUTE=2'b10, //1-!WRITE,0-COMPUTE
  parameter WRITE = 2'b01,
  parameter READ = 2'b11,
  parameter SLEEP = 2'b00,
  parameter ENABLE = 2'b01, //0-CHIP,1-!RESET
  parameter DISABLE = 2'b10 //1-!CHIP, 0-RESET
)(
  input RESET_INsig,
  input DTMBsig,
  input [1:0] fwdsig_control,
  input [11:0] fwdsig_address,
  input [7:0] fwdsig_id,
  input [63:0] fwdsig_data_c,
  input [1:0] fwdsig_xbar_address,
  input fwdsig_data_w,
  input fwdsig_data_r,
  input [3:0] posxbarsig_result_c, negxbarsig_result_c,
  input posxbarsig_result_r, negxbarsig_result_r,
  input [3:0] fwdsig_row,
  input [3:0]fwdsig_sigmoid_threshold,
  input CLK,
  input RESET,


  output reg [63:0] pre_data_c, output_data_c,
  output reg [3:0] pre_row,
  output reg [1:0] output_control,
  output reg [11:0] output_address,
  output reg [7:0] output_id,
  output reg [1:0] output_xbar_address,
  output reg output_data_w,
  output reg output_data_r,
  output reg output_flag,// output_flag_w,
  output reg pre_flag,
  output reg [3:0] output_sigmoid_threshold
);
  reg [3:0] now_row;
  reg [1:0] compute_result_bit;
  reg [3:0] sigmoid_threshold;
  reg [1:0] fwd_control;
  reg [11:0] fwd_address;
  reg [7:0] fwd_id;
  reg [63:0] fwd_data_c;
  reg [1:0] fwd_xbar_address;
  reg fwd_data_w;
  reg fwd_data_r;
  //reg fwd_flag_w;
  reg [11:0] posxbar_result_c, negxbar_result_c;
  reg posxbar_result_r, negxbar_result_r;
  //reg posxbar_result_w, negxbar_result_w;
  reg [3:0] fwd_row;
  reg [1:0] input_count;

  wire [3:0] subtraction_result0;
  wire [3:0] subtraction_result1;
  wire [3:0] subtraction_result2;
  wire [3:0] subtraction_result3;

  assign subtraction_result0 = {1'b0,posxbar_result_c[2:0]} - {1'b0,negxbar_result_c[2:0]};
  assign subtraction_result1 = {1'b0,posxbar_result_c[5:3]} - {1'b0,negxbar_result_c[5:3]};
  assign subtraction_result2 = {1'b0,posxbar_result_c[8:6]} - {1'b0,negxbar_result_c[8:6]};
  assign subtraction_result3 = {1'b0,posxbar_result_c[11:9]} - {1'b0,negxbar_result_c[11:9]};

  always @ (negedge CLK )//or posedge reset)
    begin
      if (RESET_INsig == 1)// || RESET == 1)
        begin
          fwd_id <= 0;
          fwd_control <= SLEEP;
          fwd_address <= 0;
          fwd_data_c <= 0;
          fwd_xbar_address <= 0;
          fwd_data_w <= 0;
          fwd_data_r <= 0;
          fwd_row <= 0;
          posxbar_result_r <= 0;
          negxbar_result_r <= 0;
          sigmoid_threshold <= 0;
        end
      else
        begin
          if(RESET == 1 && DTMBsig == 0)
            begin
              fwd_id <= 0;
              fwd_control <= SLEEP;
              fwd_address <= 0;
              fwd_data_c <= 0;
              fwd_xbar_address <= 0;
              fwd_data_w <= 0;
              fwd_data_r <= 0;
              fwd_row <= 0;
              posxbar_result_r <= 0;
              negxbar_result_r <= 0;
              sigmoid_threshold <= 0;
            end
          else 
            begin
              fwd_id <= fwdsig_id;
              fwd_control <= fwdsig_control;
              fwd_address <= fwdsig_address;
              fwd_data_c <= fwdsig_data_c;
              fwd_xbar_address <= fwdsig_xbar_address;
              fwd_data_w <= fwdsig_data_w;
              fwd_data_r <= fwdsig_data_r;
              fwd_row <= fwdsig_row;
              posxbar_result_r <= posxbarsig_result_r;
              negxbar_result_r <= negxbarsig_result_r;
              sigmoid_threshold <= fwdsig_sigmoid_threshold;
            end
        end
    end
  always @ (negedge CLK)
    begin
      if(RESET_INsig == 1)
        begin
          input_count <= 0;
          posxbar_result_c <= 0;
          negxbar_result_c <= 0;
        end
      else if(RESET == 1 && DTMBsig == 0)
        begin
          input_count <= 0;
          posxbar_result_c <= 0;
          negxbar_result_c <= 0;
        end
      else 
        begin
          input_count <= input_count + 1;
          case(input_count)
            2'b00:
              begin
                posxbar_result_c[0] <= posxbarsig_result_c[0];
                posxbar_result_c[3] <= posxbarsig_result_c[1];
                posxbar_result_c[6] <= posxbarsig_result_c[2];
                posxbar_result_c[9] <= posxbarsig_result_c[3];
                negxbar_result_c[0] <= negxbarsig_result_c[0];
                negxbar_result_c[3] <= negxbarsig_result_c[1];
                negxbar_result_c[6] <= negxbarsig_result_c[2];
                negxbar_result_c[9] <= negxbarsig_result_c[3];
                input_count <= 2'b01;
              end
            2'b01:
              begin
                posxbar_result_c[1] <= posxbarsig_result_c[0];
                posxbar_result_c[4] <= posxbarsig_result_c[1];
                posxbar_result_c[7] <= posxbarsig_result_c[2];
                posxbar_result_c[10] <= posxbarsig_result_c[3];
                negxbar_result_c[1] <= negxbarsig_result_c[0];
                negxbar_result_c[4] <= negxbarsig_result_c[1];
                negxbar_result_c[7] <= negxbarsig_result_c[2];
                negxbar_result_c[10] <= negxbarsig_result_c[3];
                input_count <= 2'b10;
              end
            2'b10:
              begin
                posxbar_result_c[2] <= posxbarsig_result_c[0];
                posxbar_result_c[5] <= posxbarsig_result_c[1];
                posxbar_result_c[8] <= posxbarsig_result_c[2];
                posxbar_result_c[11] <= posxbarsig_result_c[3];
                negxbar_result_c[2] <= negxbarsig_result_c[0];
                negxbar_result_c[5] <= negxbarsig_result_c[1];
                negxbar_result_c[8] <= negxbarsig_result_c[2];
                negxbar_result_c[11] <= negxbarsig_result_c[3];
                input_count <= 2'b00;
              end
            2'b11:
              begin
                posxbar_result_c <= posxbar_result_c;
                negxbar_result_c <= negxbar_result_c;
                input_count <= 2'b00;
              end
          endcase
        end
    end  
  always @ (negedge CLK) //pre_flag; pre_row; output_flag;
    begin
      if (RESET_INsig == 1)// || RESET == 1)
        begin
          now_row <= 0;
          pre_flag <=0;
          pre_row <= 4'b0;
          output_flag <=0;
        end
      else if (RESET == 1 && DTMBsig == 0)
        begin
          now_row <= 0;
          pre_flag <=0;
          pre_row <= 4'b0;
          output_flag <=0;
        end
      else if (fwd_control == COMPUTE)
        begin
          if (output_id == fwd_id && fwd_row == 0 && output_flag == 1) // already computed
            begin
              now_row <= 0;
              pre_flag <= 1'b0;
              pre_row <= 4'b0;
              output_flag <= 1'b1;
            end
          else if ((fwd_row != now_row && now_row !=4'b1111)|| output_id != fwd_id) //calculate a new row
            begin
              now_row <= fwd_row;
              pre_row<= fwd_row;
              pre_flag <= 1;
              output_flag <= 0;
            end
          else if (compute_result_bit == 2'b01)
            begin
              output_flag <= 0;
              pre_flag <= 1;
              now_row <= fwd_row;
              pre_row <= fwd_row;
            end
          else if (compute_result_bit == 2'b11)
            begin
              output_flag <= output_flag;
              pre_flag <= pre_flag;
              now_row <= now_row;
              pre_row <= pre_row;
            end
          else if (fwd_row == 4'b1111 && compute_result_bit == 2'b00)
            begin
              now_row <= fwd_row;
              output_flag <= 1'b1;
              pre_flag <= 1'b0;
              pre_row <= 4'b0;
            end
          else if (fwd_row != 4'b1111 && compute_result_bit == 2'b00)
            begin
              now_row <= fwd_row;
              output_flag <= 1'b0;
              pre_flag <= 1'b1;
              pre_row <= fwd_row+1;
            end
        end
      else
        begin 
          pre_flag <=0;
          pre_row <= 4'b0;
          if (fwd_control == READ || fwd_control == WRITE)
            begin
              output_flag <=1;
            end
          else
            begin          
              output_flag <=output_flag;
            end
        end
    end
  
  always @ (negedge CLK)
    begin
      if (RESET_INsig == 1)// || RESET == 1)
        begin
          output_id <=0;
          output_address <= 0;
          output_data_w <= 0;
          output_xbar_address <= 0;
          output_control <= SLEEP;
          output_sigmoid_threshold <= 0;
          pre_data_c <= 0;  
          output_data_c <= 0;          
          output_data_r <= 0;
        end
      else if(RESET == 1 && DTMBsig == 0)
        begin
          output_id <=0;
          output_address <= 0;
          output_data_w <= 0;
          output_xbar_address <= 0;
          output_control <= SLEEP;
          output_sigmoid_threshold <= 0;
          pre_data_c <= 0;  
          output_data_c <= 0;          
          output_data_r <= 0;
        end
      else
        begin
          output_id <= fwd_id;
          output_address <= fwd_address;
          output_data_w <= fwd_data_w;
          output_xbar_address <= fwd_xbar_address;
          output_control <= fwd_control;
          output_sigmoid_threshold <= sigmoid_threshold;
          pre_data_c <= fwd_data_c;  
    
          if (fwd_control == COMPUTE)
            begin
              if (output_id == fwd_id && fwd_row == 0 && output_flag == 1) // already computed
                begin
                  output_data_r <= output_data_r;
                  output_data_c <= output_data_c;             
                end
              else
                begin
                  output_data_r <= output_data_r;
                  if (((fwd_row != now_row && now_row !=4'b1111) || output_id != fwd_id) && input_count == 2'b10) //calculate a new row
                    begin
                  //     compute_result_bit<=2'b01;                 
                  //     output_data_c <= output_data_c; 
                  //   end
                  // else if (compute_result_bit == 2'b01)
                  //   begin
                  //     compute_result_bit<= 2'b00;
                  //     output_data_c <= output_data_c;
                  //   end
                  // else if (compute_result_bit == 2'b00)
                  //   begin
                  //    compute_result_bit <= 2'b11;
                      case ({subtraction_result0[3],sigmoid_threshold[3]})
                            2'b00:
                                output_data_c[fwd_row*4] <= (subtraction_result0[2:0]>=sigmoid_threshold[2:0]);
                            2'b01:
                                output_data_c[fwd_row*4] <= 1;
                            2'b11:
                                output_data_c[fwd_row*4] <= (subtraction_result0[2:0]<sigmoid_threshold[2:0]);
                            2'b10:
                                output_data_c[fwd_row*4] <= 0;
                          endcase
                          case ({subtraction_result1[3],sigmoid_threshold[3]})
                            2'b00:
                                output_data_c[fwd_row*4+1] <= (subtraction_result1[2:0]>=sigmoid_threshold[2:0]);
                            2'b01:
                                output_data_c[fwd_row*4+1] <= 1;
                            2'b11:
                                output_data_c[fwd_row*4+1] <= (subtraction_result1[2:0]<sigmoid_threshold[2:0]);
                            2'b10:
                                output_data_c[fwd_row*4+1] <= 0;
                          endcase                                                                
                          case ({subtraction_result2[3],sigmoid_threshold[3]})
                            2'b00:
                                output_data_c[fwd_row*4+2] <= (subtraction_result2[2:0]>=sigmoid_threshold[2:0]);
                            2'b01:
                                output_data_c[fwd_row*4+2] <= 1;
                            2'b11:
                                output_data_c[fwd_row*4+2] <= (subtraction_result2[2:0]<sigmoid_threshold[2:0]);
                            2'b10:
                                output_data_c[fwd_row*4+2] <= 0;
                          endcase
                          case ({subtraction_result3[3],sigmoid_threshold[3]})
                            2'b00:
                                output_data_c[fwd_row*4+3] <= (subtraction_result3[2:0]>=sigmoid_threshold[2:0]);
                            2'b01:
                                output_data_c[fwd_row*4+3] <= 1;
                            2'b11:
                                output_data_c[fwd_row*4+3] <= (subtraction_result3[2:0]<sigmoid_threshold[2:0]);
                            2'b10:
                                output_data_c[fwd_row*4+3] <= 0;
                          endcase
                    end
                  else
                    begin
                      compute_result_bit<= compute_result_bit;
                      output_data_c <= output_data_c; 
                    end
                  end
              end              
          else if (fwd_control == WRITE)
            begin
              output_data_r <= output_data_r;
              output_data_c <= output_data_c;
            end
          else if (fwd_control == READ)
            begin
              output_data_c <= output_data_c;
              if (fwd_xbar_address == 2'b10)
                begin
                  output_data_r <= posxbar_result_r;
                end
              else if (fwd_xbar_address == 2'b11)
                begin
                  output_data_r <= negxbar_result_r;             
                end
              else
                begin
                  output_data_r <= fwd_data_r;
                end
            end
          else //remain
            begin
              output_data_c <= output_data_c;
              output_data_r <= output_data_r;
            end
        end
    end
endmodule

