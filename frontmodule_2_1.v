//修改1：修改所有RESET 和 RESET_INsig的优先级
//修改2：32*32变64*64
//-----------2.1 update-------------
//加入CNN模式
module frontmodule #(
  parameter COMPUTE=2'b10, //1-!WRITE,0-COMPUTE
  parameter WRITE = 2'b01,
  parameter READ = 2'b11,
  parameter SLEEP = 2'b00,
  parameter ENABLE = 2'b01, //0-CHIP,1-!RESET
  parameter DISABLE = 2'b10 //1-!CHIP, 0-RESET
)(
  //input CLK_PIPELINE,
  //sig输入信号，大写sig芯片外过来的，用于测试，
  //测试
  input TMBsig,
  input DTMBsig,
  input [1:0] XBAR_ADDRsig,
  input [5:0] AXsig,//64bit
  input [5:0] AYsig,//64bit
  input CEBsig,//control使能信号，以下四个信号均是给crossbar的
  input RSTBsig,//reset
  input WEBsig,//write
  input CMEBsig,//compute
  input DINsig,
  input [63:0] CM_WLsig,//计算测试输入
  input SIGM_INsig,//测试用sigmoid阈值输入
  input ID_INsig,//测试用数据包
  input RESET_INsig,
  
  //CNNpart
  input CD_TRANSsig,
  input inputsig_CD_trans,
  input inputsig_flag_kernel,
  input feedbacksig_flag_kernel,
  input [1:0] inputsig_kernel_mode,
  input [1:0] KERNEL_MODEsig,
  //小写加sigCPU过来的
  input [1:0] inputsig_control,
  input [7:0] inputsig_id,
  input [11:0] inputsig_address,//64bit
  input [63:0] inputsig_data_c,
  input [1:0] inputsig_xbar_address,
  input inputsig_data_w,
  input inputsig_flag,
  //aftermodule反馈回来的
  input feedbacksig_flag,
  input [63:0] feedbacksig_data,
  input [3:0] feedbacksig_row,

  input [3:0] inputsig_sigmoid_threshold,
  //外面PAD
  input CLK,
  //CPU
  input RESET,
  //用寄存器，保留
  //input：CPU或前一层过来的，feedback：after过来的
  output reg [7:0] next_id,
  output reg [1:0] next_control,
  output reg next_data_w,
  output reg posxbar_data_w,
  output reg negxbar_data_w,
  output reg [3:0] next_row ,//给after模块
  output reg [11:0] next_address, 
  output reg [11:0] posxbar_address, 
  output reg [11:0] negxbar_address,
  output reg [1:0] posxbar_enable, //enable = {CEB,RSTB}
  output reg [1:0] negxbar_enable,
  output reg [1:0] next_xbar_address ,
  output reg [1:0] posxbar_control, //control = {WEB,CMEB}
  output reg [63:0] posxbar_data_c, 
  output reg [63:0] next_data_c,
  output reg [1:0] negxbar_control,
  output reg [63:0] negxbar_data_c,
  output reg [3:0] next_sigmoid_threshold,
  output reg next_CD_trans,
  output reg [1:0] next_kernel_mode
);
  reg compute_counter_bit;
  reg [6:0] clk_counter;

  //input
  reg [7:0] input_id;
  reg [1:0] input_control;
  reg [11:0] input_address;
  reg [63:0] input_data_c;
  reg input_data_w;
  reg [1:0] input_xbar_address;
  reg [3:0] input_sigmoid_threshold;
  reg input_flag; //1--ready
  //CNN
  reg input_CD_trans;
  reg input_flag_kernel;
  reg feedback_flag_kernel;
  reg [1:0]input_kernel_mode;

  //feedback
  reg feedback_flag; //1--still need to compute 
  reg [63:0] feedback_data;
  reg [3:0] feedback_row;
  
  //注意if树
  //crossbar上升沿读数据，下降沿处理
  
  wire FEEDBACK_FLAG;
  assign FEEDBACK_FLAG = (input_CD_trans == 1)?feedback_flag_kernel:feedback_flag;
  wire INPUT_FLAG;
  assign INPUT_FLAG = (input_CD_trans == 1)?input_flag_kernel:input_flag;
  //修改以下所有部分关于RESET的优先级,if的判断部分有待简化

  always @ (negedge CLK)	//测试数字模块+crossbar
    begin
      if (RESET_INsig == 1)// || RESET == 1)//RESET:CPU,修改优先级，一定要比测试的优先级低：CPU优先级都要低
        begin
          input_control <= SLEEP;
          input_address <= 0;
          input_data_c <= 0;
          input_xbar_address <= 0;
          input_data_w <= 0;
          input_flag <= 0;
          input_sigmoid_threshold <= 0;
          input_id <= 0;
          input_CD_trans <= 0;
          input_kernel_mode <= 0;
        end
      else if (clk_counter == 0)
        begin
          if (DTMBsig == 1)	
            begin
              input_control <= {WEBsig,CMEBsig};   
              input_address <= {AXsig[5:0],AYsig[5:0]};
              input_data_c <= CM_WLsig;
              input_xbar_address <= XBAR_ADDRsig;
              input_data_w <= DINsig;
              input_flag <= 1;	//测试数字模块+crossbar配置完成
              if (SIGM_INsig ==1 )
                begin
                  input_sigmoid_threshold <= 4'b1111;	//1时sigmoid的阈值为-1，补码
                end
              else
                begin
                  input_sigmoid_threshold <= 4'b0000;
                end
              input_id <= {7'b0,ID_INsig};
              input_CD_trans <=	CD_TRANSsig;
              input_kernel_mode <= KERNEL_MODEsig;
            end
          else//系统运行模式，把CPU的信号读进来
            begin
              if(RESET == 1)
                begin
                  input_control <= SLEEP;
                  input_address <= 0;
                  input_data_c <= 0;
                  input_xbar_address <= 0;
                  input_data_w <= 0;
                  input_flag <= 0;
                  input_sigmoid_threshold <= 0;
                  input_id <= 0;
                  input_CD_trans <= 0;
                  input_kernel_mode <= 0;
                end
              else 
                begin
                  input_control <= inputsig_control;
                  input_address <= inputsig_address;
                  input_data_c <= inputsig_data_c;
                  input_xbar_address <= inputsig_xbar_address;
                  input_data_w <= inputsig_data_w;
                  input_flag <= inputsig_flag;
                  input_sigmoid_threshold <= inputsig_sigmoid_threshold;
                  input_id <= inputsig_id;
                  input_CD_trans <= inputsig_CD_trans;
                  input_kernel_mode <= inputsig_kernel_mode;
                end 
            end
        end
      else
        begin
          input_control <= input_control;
          input_address <= input_address;
          input_data_c <= input_data_c;
          input_xbar_address <= input_xbar_address;
          input_data_w <= input_data_w;
          input_flag <= input_flag;
          input_sigmoid_threshold <= input_sigmoid_threshold;
          input_id <= input_id;
          input_CD_trans <= input_CD_trans;
          input_kernel_mode <= input_kernel_mode;
        end
    end
    
  always @ (negedge CLK)	//clk_counter的计数操作
    begin
      if (RESET_INsig == 1)// || RESET == 1)
        begin
          clk_counter <= 0;
        end
      else 
        begin
          if(RESET == 1 && DTMBsig == 0)
            begin
              clk_counter <= 0 ;
            end
          else 
            begin 
              clk_counter <= clk_counter + 1;
            end  
        end
      end
    
  always @ (negedge CLK)	//来自after module的反馈
    begin
      if (RESET_INsig == 1)// || RESET == 1)
        begin
          feedback_flag <= 0;
          feedback_data <= 0;
          feedback_row <= 0;
          input_flag_kernel <= 0;
          feedback_flag_kernel <= 0; 
        end
      else
        begin
          if(RESET == 1 && DTMBsig == 0)
            begin
              feedback_flag <= 0;
              feedback_data <= 0;
              feedback_row <= 0;
              input_flag_kernel <= 0;
              feedback_flag_kernel <= 0; 
            end
          else 
            begin
              feedback_flag <= feedbacksig_flag;
              feedback_data <= feedbacksig_data;
              feedback_row <= feedbacksig_row;
              input_flag_kernel <= inputsig_flag_kernel;
              feedback_flag_kernel <= feedbacksig_flag_kernel; 
            end
        end
    end
  
  always @ (negedge CLK)
    begin
      if (RESET_INsig == 1)// || RESET == 1)
        begin
          compute_counter_bit <=0;
          posxbar_data_w <= 0;
          posxbar_address <= 0;
          negxbar_data_w <= 0;
          negxbar_address <= 0;
          next_id <= 0;
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
          if (TMBsig ==1)	//直接测试crossbar
            begin
              compute_counter_bit <=0;
              next_id <=0;
              next_control <= SLEEP;
              next_data_c <= 0;
              next_row <= 0;
              if (XBAR_ADDRsig == 2'b00)
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
              else if (XBAR_ADDRsig == 2'b01)
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
            begin
              if(RESET == 1 && DTMBsig == 0)
                begin
                  compute_counter_bit <=0;
                  posxbar_data_w <= 0;
                  posxbar_address <= 0;
                  negxbar_data_w <= 0;
                  negxbar_address <= 0;
                  next_id <= 0;
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
                  if (FEEDBACK_FLAG == 1'b0)	//无反馈
                    begin
                      if (INPUT_FLAG == 1'b1)
                        begin
                          next_control <= input_control;
                          next_data_c <= input_data_c;
                          next_row <= 4'b0;
                          negxbar_data_c <= input_data_c;
                          posxbar_data_c <= input_data_c;
                          if (input_control == COMPUTE)
                            begin
                              posxbar_address[5:2] <= 4'b0;	
                              negxbar_address[5:2] <= 4'b0;
                              if (next_id != input_id && compute_counter_bit == 0)//先判断计算八个周期的计数器是否到头，再判断数据包是否相同（来了两个相同的数据包）
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
                              if (input_xbar_address == 2'b00)
                                begin
                                  posxbar_enable <= ENABLE;
                                  negxbar_enable <= DISABLE; 
                                end
                              else if (input_xbar_address == 2'b01)
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
                              if (input_xbar_address == 2'b00)
                                begin
                                  posxbar_control <= input_control; 
                                  negxbar_control <= READ; 
                                  posxbar_enable <= ENABLE;
                                  negxbar_enable <= DISABLE;
                                end
                              else if (input_xbar_address == 2'b01)
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
                              //如果不处理crossbar，需要将其关闭，同时置为读操作（比写操作更可靠）
                              posxbar_control <= READ;
                              negxbar_control <= READ;
                              posxbar_enable <= DISABLE;
                              negxbar_enable <= DISABLE; 
                            end
                        end
                      else //input_flag == 0  input数据包还没准备好
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
                  else //feedback == 1
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
                    end
                end
            end
        end
    end
  
  always @ (negedge CLK)
    begin
      if (RESET_INsig == 1)// || RESET_INsig == 1)
        begin
          next_address <= 0;
          next_data_w <= 0;
          next_xbar_address <= 2'b00;
          next_sigmoid_threshold <= 4'b0000;
          next_CD_trans <= 0;
          next_kernel_mode <= 0;
        end
      else if (RESET == 1 && DTMBsig == 0)
        begin
          next_address <= 0;
          next_data_w <= 0;
          next_xbar_address <= 2'b00;
          next_sigmoid_threshold <= 4'b0000;
          next_CD_trans <= 0;
          next_kernel_mode <= 0;
        end
      else if (INPUT_FLAG == 1)
        begin
          next_address <= input_address;
          next_data_w <= input_data_w;
          next_xbar_address <= input_xbar_address;
          next_sigmoid_threshold <= input_sigmoid_threshold; 
          next_CD_trans <= input_CD_trans;
          next_kernel_mode <= input_kernel_mode;
        end
      else
        begin
          next_address <= next_address;
          next_data_w <= next_data_w;
          next_xbar_address <= next_xbar_address;
          next_sigmoid_threshold <= next_sigmoid_threshold;
          next_CD_trans <= next_CD_trans;
          next_kernel_mode <= next_kernel_mode;
        end
    end

endmodule