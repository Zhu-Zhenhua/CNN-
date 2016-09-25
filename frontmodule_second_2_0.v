module frontmodule_second #(
  parameter COMPUTE=2'b10, //1-!WRITE,0-COMPUTE
  parameter WRITE = 2'b01,
  parameter READ = 2'b11,
  parameter SLEEP = 2'b00,
  parameter ENABLE = 2'b01, //0-CHIP,1-!RESET
  parameter DISABLE = 2'b10 //1-!CHIP, 0-RESET
)(

  input TMBsig,
  input DTMBsig,
  input [1:0] XBAR_ADDRsig,
  input [5:0] AXsig,
  input [5:0] AYsig,
  input CEBsig,
  input RSTBsig,
  input WEBsig,
  input CMEBsig,
  input DINsig,
  input [63:0] CM_WLsig,
  
  input SIGM_INsig, //1:111;0:0000
  input ID_INsig,
  input RESET_INsig, //1:reset
  input LAYERsig, //0:firstlayer
  input DTWHOLEsig,//1:whole

  input [1:0] inputsig_control,
  input [11:0] inputsig_address,
  input [7:0] inputsig_id,
  input [63:0] inputsig_data_c,
  input [1:0] inputsig_xbar_address,
  input inputsig_data_w,
  input inputsig_data_r,
  input inputsig_flag,// inputsig_flag_w,
  input feedbacksig_flag,
  input [63:0] feedbacksig_data,
  input [3:0] feedbacksig_row,
  input [3:0] inputsig_sigmoid_threshold,
//  input CLK_PIPELINE,
  input CLK,
  input RESET,

  output reg next_data_r,
  //output reg next_flag_w,
  output reg [1:0] next_control,
  output reg next_data_w,
  output reg posxbar_data_w,
  output reg negxbar_data_w,
  output reg [3:0] next_row ,
  output reg [11:0] next_address, 
  output reg [7:0] next_id,
  output reg [11:0] posxbar_address, 
  output reg [11:0] negxbar_address,
  output reg [1:0] next_xbar_address ,
  output reg [1:0] posxbar_control,
  output reg [1:0] posxbar_enable,  //enable = {CEB,RSTB}
  output reg [63:0] posxbar_data_c, 
  output reg [63:0] next_data_c,
  //output reg [2:0] posxbar_row,
  output reg [1:0] negxbar_control,  //control = {WEB,CMEB}
  output reg [1:0] negxbar_enable,
  output reg [63:0] negxbar_data_c,
  //output reg [2:0] negxbar_row,
  output reg [3:0] next_sigmoid_threshold
);
  reg compute_counter_bit;
  reg [6:0] clk_counter;
  reg input_data_r;
  //reg input_flag_w; //1--write success
  reg [1:0] input_control;
  reg [11:0] input_address;
  reg [7:0] input_id;
  reg [63:0] input_data_c;
  reg input_data_w;
  reg [1:0] input_xbar_address;
  reg [3:0] input_sigmoid_threshold;
  reg input_flag; //1--ready
  reg feedback_flag; //1--still need to compute 
  reg [63:0] feedback_data;
  reg [3:0] feedback_row;


  always @ (negedge CLK)
    begin
      if (RESET_INsig == 1)// || RESET == 1)
        begin
          input_id <= 0;
          input_data_r <= 0;
          input_control <= SLEEP;
          input_address <= 0;
          input_data_c <= 0;
          input_xbar_address <= 0;
          input_data_w <= 0;
          input_flag <= 0;
          input_sigmoid_threshold <= 0;
        end
      else if(RESET == 1 && DTMBsig == 0)
        begin
          input_id <= 0;
          input_data_r <= 0;
          input_control <= SLEEP;
          input_address <= 0;
          input_data_c <= 0;
          input_xbar_address <= 0;
          input_data_w <= 0;
          input_flag <= 0;
          input_sigmoid_threshold <= 0;
        end
      else if (clk_counter == 0)
        begin
          if (DTMBsig == 1 && DTWHOLEsig ==0 && LAYERsig == 1)
            begin
              input_control <= {WEBsig,CMEBsig};
              input_address <= {AXsig[5:0],AYsig[5:0]};
              input_data_c <= CM_WLsig;
              input_data_r <= input_data_r;
              input_xbar_address <= XBAR_ADDRsig;
              input_data_w <= DINsig;
              input_flag <= 1;
              if (SIGM_INsig ==1 )
                input_sigmoid_threshold <= 4'b1111;
              else
                input_sigmoid_threshold <= 4'b0000;
              input_id <= {7'b0,ID_INsig};
            end
          else
            begin
              input_control <= inputsig_control;
              input_address <= inputsig_address;
              input_data_c <= inputsig_data_c;
              input_data_r <= inputsig_data_r;
              input_xbar_address <= inputsig_xbar_address;
              input_data_w <= inputsig_data_w;
              input_flag <= inputsig_flag;
              input_sigmoid_threshold <= inputsig_sigmoid_threshold;
              input_id <= inputsig_id;
            end
        end
      else
        begin
          input_id <= input_id;
          input_data_r <= input_data_r;
          input_control <= input_control;
          input_address <= input_address;
          input_data_c <= input_data_c;
          input_xbar_address <= input_xbar_address;
          input_data_w <= input_data_w;
          input_flag <= input_flag;
          input_sigmoid_threshold <= input_sigmoid_threshold;
        end
    end
    
    always @ (negedge CLK)
    begin
      if (RESET_INsig == 1)// || RESET == 1)
        begin
          clk_counter <= 0;
        end
      else 
        begin
          if(RESET == 1 && DTMBsig == 0)
            begin
              clk_counter <= 0;
            end
          else
            begin
              clk_counter <= clk_counter + 1;
            end
        end
      end
  
  always @ (negedge CLK)
    begin
      if (RESET_INsig == 1)// || RESET == 1)
        begin
          feedback_flag <= 0;
          feedback_data <= 0;
          feedback_row <= 0;
        end
      else
        begin
          if(RESET == 1 && DTMBsig == 0)
            begin
              feedback_flag <= 0;
              feedback_data <= 0;
              feedback_row <= 0;
            end
          else 
            begin
              feedback_flag <= feedbacksig_flag;
              feedback_data <= feedbacksig_data;
              feedback_row <= feedbacksig_row;
            end
        end
    end
  
  
  always @ (negedge CLK)
    begin
      if(RESET_INsig == 1)// || RESET == 1)
        begin
          compute_counter_bit <=0;
          next_id <=0;
          
          posxbar_data_w <= 0;
          posxbar_address <= 0;
          negxbar_data_w <= 0;
          negxbar_address <= 0;
          posxbar_enable <= DISABLE;
          negxbar_enable <= DISABLE;
          next_control <= SLEEP;
          next_data_c <= 0;
          next_row <= 0;
          posxbar_control <= READ;
          posxbar_data_c <= 0;
          negxbar_control <= READ;
          negxbar_data_c <= 0;
        end
      else
        begin
          if (TMBsig ==1)
            begin
              compute_counter_bit <=0;
              next_id <=0;
              next_control <= SLEEP;
              next_data_c <= 0;
              next_row <= 0;
              if (XBAR_ADDRsig == 2'b10)
                begin
                  posxbar_data_w <= DINsig;
                  posxbar_address <= {AXsig[5:0],AYsig[5:0]};
                  posxbar_enable <= {CEBsig,RSTBsig};
                  posxbar_control <= {WEBsig,CMEBsig};
                  posxbar_data_c <= CM_WLsig;
                  
                  negxbar_data_w <= 0;
                  negxbar_address <= 0;
                  negxbar_enable <= DISABLE;
                  negxbar_control <= READ;
                  negxbar_data_c <= 0;
                end
              else if (XBAR_ADDRsig == 2'b11)
                begin
                  posxbar_data_w <= 0;
                  posxbar_address <= 0;
                  posxbar_control <= READ;
                  posxbar_data_c <= 0;
                  posxbar_enable <= DISABLE;
                  
                  negxbar_data_w <= DINsig;
                  negxbar_address <= {AXsig[5:0],AYsig[5:0]};
                  negxbar_enable <= {CEBsig,RSTBsig};
                  negxbar_control <= {WEBsig,CMEBsig};
                  negxbar_data_c <= CM_WLsig;
                end
              else
                begin
                  posxbar_data_w <= 0;
                  posxbar_address <= 0;
                  negxbar_data_w <= 0;
                  negxbar_address <= 0;
                  posxbar_enable <= DISABLE;
                  negxbar_enable <= DISABLE;
                  posxbar_control <= READ;
                  posxbar_data_c <= 0;
                  negxbar_control <= READ;
                  negxbar_data_c <= 0;
                end              
            end
          else
            if(RESET == 1 && DTMBsig == 0)
              begin
                compute_counter_bit <=0;
                next_id <=0;
                posxbar_data_w <= 0;
                posxbar_address <= 0;
                negxbar_data_w <= 0;
                negxbar_address <= 0;
                posxbar_enable <= DISABLE;
                negxbar_enable <= DISABLE;
                next_control <= SLEEP;
                next_data_c <= 0;
                next_row <= 0;
                posxbar_control <= READ;
                posxbar_data_c <= 0;
                negxbar_control <= READ;
                negxbar_data_c <= 0;
              end
            else
              begin
                posxbar_data_w <= input_data_w;
                negxbar_data_w <= input_data_w;
                if (feedback_flag == 1'b0)
                  begin
                    if (input_flag == 1'b1)
                      begin
                        next_control <= input_control;
                        next_data_c <= input_data_c;
                        next_row <= 4'b0;
                        negxbar_data_c <= input_data_c;
                        posxbar_data_c <= input_data_c;
                        if (input_control == COMPUTE)
                          begin
                            negxbar_address[5:2] <= 4'b0;
                            posxbar_address[5:2] <= 4'b0;
                            if (next_id != input_id && compute_counter_bit == 0)
                              begin
                                compute_counter_bit <= 1;
                                next_id <= next_id;
                                posxbar_enable <= DISABLE;
                                negxbar_enable <= DISABLE;
                                posxbar_control <= READ;
                                negxbar_control <= READ;
                              end
                            else if (next_id != input_id && compute_counter_bit == 1)
                              begin
                                compute_counter_bit <= 0;
                                next_id <= input_id;
                                posxbar_enable <= ENABLE;
                                negxbar_enable <= ENABLE;
                                posxbar_control <= input_control;
                                negxbar_control <= input_control;    
                              end 
                            else
                              begin
                                compute_counter_bit <= 0;
                                next_id <= next_id;
                                posxbar_enable <= posxbar_enable;
                                negxbar_enable <= negxbar_enable;
                                posxbar_control <= posxbar_control;
                                negxbar_control <= negxbar_control;
                              end
                          end
                        else if (input_control == READ)
                          begin
                            posxbar_address <= input_address;
                            negxbar_address <= input_address;
                            next_id <= input_id;
                            posxbar_control <= READ;
                            negxbar_control <= READ;  
                            if (input_xbar_address == 2'b10)
                              begin
                                posxbar_enable <= ENABLE;
                                negxbar_enable <= DISABLE; 
                              end
                            else if (input_xbar_address == 2'b11)
                              begin
                                posxbar_enable <= DISABLE;
                                negxbar_enable <= ENABLE;            
                              end
                            else
                              begin
                                posxbar_enable <= DISABLE;
                                negxbar_enable <= DISABLE;            
                              end    
                          end
                        else if (input_control == WRITE)
                          begin
                            next_id <= input_id;
                            posxbar_address <= input_address;
                            negxbar_address <= input_address;
                            if (input_xbar_address == 2'b10)
                              begin
                                posxbar_control <= input_control; 
                                negxbar_control <= READ; 
                                posxbar_enable <= ENABLE;
                                negxbar_enable <= DISABLE;
                              end
                            else if (input_xbar_address == 2'b11)
                              begin
                                posxbar_control <= READ;
                                negxbar_control <= input_control;  
                                posxbar_enable <= DISABLE;
                                negxbar_enable <= ENABLE;           
                              end
                            else
                              begin
                                posxbar_control <= READ;
                                negxbar_control <= READ; 
                                posxbar_enable <= DISABLE;
                                negxbar_enable <= DISABLE;             
                              end
                          end
                        else
                          begin
                            next_id <= next_id;
                            posxbar_control <= READ;
                            negxbar_control <= READ;
                            posxbar_enable <= DISABLE;
                            negxbar_enable <= DISABLE;
                          end
                      end
                    else //input_flag == 0
                      begin
                        posxbar_address <= input_address;
                        negxbar_address <= input_address;
                        next_id <= next_id;
                        next_control <= SLEEP;//no operation
                        next_data_c <= next_data_c;
                        next_row <= 4'b0;
                        posxbar_enable <= DISABLE;
                        negxbar_enable <= DISABLE;
                        posxbar_control <= READ;
                        posxbar_data_c <= input_data_c;
                        negxbar_control <= READ;
                        negxbar_data_c <= input_data_c;
                      end
                  end
                else//feedback == 1
                  begin
                    next_id <= next_id;
                    next_control <= COMPUTE;
                    next_data_c <= feedback_data;
                    posxbar_control <= COMPUTE;
                    posxbar_address[5:2] <= feedback_row;
                    posxbar_data_c <= feedback_data;
                    negxbar_control <= COMPUTE;
                    negxbar_address[5:2] <= feedback_row;
                    negxbar_data_c <= feedback_data;
                
                    if (compute_counter_bit == 1)
                      begin
                        posxbar_enable <= ENABLE;
                        negxbar_enable <= ENABLE;              
                        next_row <= feedback_row;
                        compute_counter_bit <= 0;
                      end
                    else if (next_row != feedback_row)// && feedback_row != 3'b000) //change to a new row
                      begin
                        posxbar_enable <= DISABLE;
                        negxbar_enable <= DISABLE;
                        next_row <= next_row;
                        compute_counter_bit <= 1;
                      end
                    else
                      begin
                        posxbar_enable <= ENABLE;
                        negxbar_enable <= ENABLE;
                        next_row <= next_row;
                        compute_counter_bit <= 0;
                      end
                  end//feedback
            end//!testmode
        end//!reset
    end//always
    
    
always @ (negedge CLK)
  begin
    if (RESET_INsig == 1)// || RESET == 1)
      begin
        next_address <= 0;
        next_data_w <= 0;
        next_xbar_address <= 0;
        next_sigmoid_threshold <= 0;
        next_data_r <= 0;
      end
    else if(RESET == 1 && DTMBsig == 0)
      begin
        next_address <= 0;
        next_data_w <= 0;
        next_xbar_address <= 0;
        next_sigmoid_threshold <= 0;
        next_data_r <= 0;
      end  
    else if (input_flag ==1)
      begin
        next_address <= input_address;
        next_data_w <= input_data_w;
        next_xbar_address <= input_xbar_address;
        next_sigmoid_threshold <= input_sigmoid_threshold;
        next_data_r <= input_data_r;
      end  
    else
      begin
        next_address <= next_address;
        next_data_w <= next_data_w;
        next_xbar_address <= next_xbar_address;
        next_sigmoid_threshold <= next_sigmoid_threshold;
        next_data_r <= next_data_r;
      end
  end
endmodule
