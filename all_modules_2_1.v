
module all_modules
  (
 // input CLK_PIPELINE,
  input TMBsig,
  input DTMBsig,
  input LAYERsig,
  input DTWHOLEsig,
  input RESET_INsig,
  input SIGM_INsig,
  input ID_INsig,
  input [1:0] XBAR_ADDRsig,
  input [5:0] AXsig,
  input [5:0] AYsig,
  input CEBsig,
  input RSTBsig,
  input WEBsig,
  input CMEBsig,
  input DINsig,
  input [63:0] CM_WLsig,
  //CNNadd
  input CD_TRANSsig,
  input [1:0] KERNEL_MODEsig,


  input [1:0] inputsig_control,
  input [11:0] inputsig_address,
  input [7:0] inputsig_id,
  input [63:0] inputsig_data_c,
  input [1:0] inputsig_xbar_address,
  input inputsig_data_w,
  input inputsig_flag,
  input [3:0] inputsig_sigmoid_threshold,
  
  //CNN add
  input [1:0] inputsig_kernel_mode, 
  input inputsig_CD_trans,

  input CLK,
  input RESET,
  
  //以下变量不知道用不用改
  input SENsel,
  input SAENin,
  input SA_TM,
  input [3:0] VREF,
  input REF_TW,
  input [6:0] REF_EXT,
  input [1:0] WLP_TM,
  input [1:0] DIS_TM,
  input EXT_DIS,
  input EXT_WLP,
  input BL_EXT_EN,
  input VD_EXT,
  input WL_EXT_EN,
  input VWL_EXT,
  input VRST,
  input VSET,
  input VCLP,
  input VWL_READ,
  input VWL_RST,
  input VWL_SET,
  input WL_DU,
  
  output reg [11:0] DO_CMpo,
  output reg DO_Rpo,
  
  ///////for 1st-level simulation/////
  output [7:0] output_id_2,
  output [63:0] output_data_c_2,
  output [1:0] output_control_2,
  output [11:0] output_address_2,
  output [1:0] output_xbar_address_2,
  output output_data_w_2,
  output output_data_r_2,
  output output_flag_2,// output_flag_w,
  output [3:0] output_sigmoid_threshold_2
  

);
  //kernelmodule
  wire inputsig_flag_kernel;
  wire feedbacksig_flag_kernel;
//1st level frontmodule
  wire [1:0] next_control_1;
  wire next_data_w_1,posxbar_data_w_1,negxbar_data_w_1;
  wire [3:0] next_row_1 ;
  wire [11:0] next_address_1, posxbar_address_1, negxbar_address_1;
  wire [7:0] next_id_1;
  wire [1:0] next_xbar_address_1 ;
  wire [1:0] posxbar_control_1;
  wire [63:0] posxbar_data_c_1, next_data_c_1;
  //wire [2:0] posxbar_row_1;
  wire [1:0] negxbar_control_1;
  wire [63:0] negxbar_data_c_1;
  //wire [2:0] negxbar_row_1;
  wire [3:0] next_sigmoid_threshold_1;
  wire [1:0] posxbar_enable_1;
  wire [1:0] negxbar_enable_1;
  wire next_CD_trans_1;
  wire [1:0] next_kernel_mode_1;
  
//1st level postive xbar  
  wire [11:0] xbar_result_c_pos_1;
  wire xbar_result_r_pos_1;
//1st level negtive xbar  
  wire [11:0] xbar_result_c_neg_1;
  wire xbar_result_r_neg_1;

//1st level aftermodule
  wire [63:0] pre_data_c_1; 
  wire [3:0] pre_row_1;
  wire pre_flag_1;
  wire [63:0] output_data_c_1;
  wire [1:0] output_control_1;
  wire [11:0] output_address_1;
  wire [7:0] output_id_1;
  wire [1:0] output_xbar_address_1;
  wire output_data_w_1;
  wire output_data_r_1;
  wire output_flag_1;  
  wire [3:0] output_sigmoid_threshold_1;
  
 
//2nd level frontmodule 
  wire next_data_r_2;
  //wire next_flag_w_2;
  wire [1:0] next_control_2;
  wire next_data_w_2;
  wire posxbar_data_w_2;
  wire negxbar_data_w_2;
  wire [3:0] next_row_2 ;
  wire [11:0] next_address_2;
  wire [7:0] next_id_2;
  wire [11:0] posxbar_address_2;
  wire [11:0] negxbar_address_2;
  wire [1:0] next_xbar_address_2;
  wire [1:0] posxbar_control_2;
  wire [63:0] posxbar_data_c_2;
  wire [63:0] next_data_c_2;
  wire [1:0] negxbar_control_2;
  wire [63:0] negxbar_data_c_2;
  wire [3:0] next_sigmoid_threshold_2;
  wire [1:0] posxbar_enable_2;
  wire [1:0] negxbar_enable_2;
  
  wire [11:0] xbar_result_c_pos_2;
  wire xbar_result_r_pos_2;
  //wire xbar_result_w_pos_2;
  
  wire [11:0] xbar_result_c_neg_2;
  wire xbar_result_r_neg_2;
  //wire xbar_result_w_neg_2;
  
//2nd level aftermodule
  wire pre_flag_2;
  wire [3:0] pre_row_2;
  wire [63:0] pre_data_c_2;
/*  
  wire [31:0] output_data_c_2;
  wire [1:0] output_control_2;
  wire [9:0] output_address_2;
  wire [7:0] output_id_2;
  wire [1:0] output_xbar_address_2;
  wire output_data_w_2;
  wire output_data_r_2;
  wire output_flag_2;// output_flag_w_2;
  wire [3:0] output_sigmoid_threshold_2;
 */
  kernel_control
    ker_con(
      .CLK (CLK),
      .RESET (RESET),
      .RESET_INsig (RESET_INsig),
      .DTMBsig (DTMBsig),
      .kernel_mode(inputsig_kernel_mode),
      .KERNEL_MODEsig(KERNEL_MODEsig),
      .input_flag_kernel(inputsig_flag_kernel),
      .feedback_flag_kernel(feedbacksig_flag_kernel),
      );
   frontmodule 
   // .PE_NUM (4)
    front1(
    //.CLK_PIPELINE (CLK_PIPELINE),
    .CLK        (CLK),
    .RESET      (RESET),
    .RESET_INsig (RESET_INsig),
    
    .SIGM_INsig (SIGM_INsig),
    .ID_INsig (ID_INsig),
    .TMBsig (TMBsig),
    .DTMBsig (DTMBsig),
    .XBAR_ADDRsig (XBAR_ADDRsig),
    .AXsig (AXsig),
    .AYsig (AYsig),
    .CEBsig (CEBsig),
    .RSTBsig (RSTBsig),
    .WEBsig (WEBsig),
    .CMEBsig (CMEBsig),
    .DINsig (DINsig),
    .CM_WLsig (CM_WLsig),
    
    .CD_TRANSsig(CD_TRANSsig),
    .inputsig_CD_trans(inputsig_CD_trans),
    .inputsig_flag_kernel(inputsig_flag_kernel),
    .feedbacksig_flag_kernel(feedbacksig_flag_kernel),
    .inputsig_kernel_mode(inputsig_kernel_mode),
    .KERNEL_MODEsig(KERNEL_MODEsig),
////////////////////////////////
    .inputsig_id(inputsig_id),
    .inputsig_control(inputsig_control),
    .inputsig_address(inputsig_address),
    .inputsig_data_c(inputsig_data_c),
    .inputsig_xbar_address(inputsig_xbar_address),
    .inputsig_data_w(inputsig_data_w),
    .inputsig_flag(inputsig_flag),
    .inputsig_sigmoid_threshold(inputsig_sigmoid_threshold),
    .feedbacksig_flag(pre_flag_1),
    .feedbacksig_data(pre_data_c_1),
    .feedbacksig_row(pre_row_1),

    
    .next_control(next_control_1),
    .next_data_w(next_data_w_1),
    .posxbar_data_w(posxbar_data_w_1),
    .negxbar_data_w(negxbar_data_w_1),
    .next_row (next_row_1),
    .next_address(next_address_1), 
    .posxbar_address(posxbar_address_1), 
    .negxbar_address(negxbar_address_1),
    .next_xbar_address(next_xbar_address_1) ,
    .posxbar_control(posxbar_control_1),
    .posxbar_data_c(posxbar_data_c_1), 
    .next_data_c(next_data_c_1),
    .posxbar_enable(posxbar_enable_1),
    //.posxbar_row(posxbar_row_1),
    .negxbar_control(negxbar_control_1),
    .negxbar_data_c(negxbar_data_c_1),
    .negxbar_enable(negxbar_enable_1),
    .next_sigmoid_threshold (next_sigmoid_threshold_1),
    //.negxbar_row(negxbar_row_1),
    .next_id (next_id_1),
    .next_CD_trans (next_CD_trans_1),
    .next_kernel_mode(next_kernel_mode_1)
    
    );
    
    
    crossbar
     // #(
     // .XBAR_ADDR (0)
      posxbar1 (
      .CLK (CLK),
      .DIN(posxbar_data_w_1),
      .AX(posxbar_address_1[11:6]),
      .AY(posxbar_address_1[5:0]), 
      .WEB(posxbar_control_1[1]),
      .CMEB(posxbar_control_1[0]),
      .WL_CM(posxbar_data_c_1),
      .CEB(posxbar_enable_1[1]),
      .RSTB(posxbar_enable_1[0]),
      //.xbar_row(posxbar_row_1),
      
      .SENsel (SENsel),
      .SAENin (SAENin),
      .SA_TM (SA_TM),
      .Vref (VREF),
      .REF_TM (REF_TW),
      .REF_EXT (REF_EXT),
      .WLP_TM (WLP_TM),
      .DIS_TM (DIS_TM),
      .EXT_DIS (EXT_DIS),
      .EXT_WLP (EXT_WLP),
      .BL_EXT_EN (BL_EXT_EN),
      .VD_EXT (VD_EXT),
      .WL_EXT_EN (WL_EXT_EN),
      .VWL_EXT (VWL_EXT),
      .VRST (VRST),
      .VSET (VSET),
      .VCLP (VCLP),
      .VWL_READ (VWL_READ),
      .VWL_RST (VWL_RST),
      .VWL_SET (VWL_SET),
      .WL_DU (WL_DU),
      

      .DO_CM(xbar_result_c_pos_1),
      .DO_R(xbar_result_r_pos_1)
      //.xbar_result_w(xbar_result_w_pos_1)
      );
    
    crossbar
      // #(
      //.XBAR_ADDR (2'b01)
      negxbar1(
      .CLK (CLK),
      .DIN(negxbar_data_w_1),
      .AX(negxbar_address_1[11:6]),
      .AY(negxbar_address_1[5:0]), 
      .WEB(negxbar_control_1[1]),
      .CMEB(negxbar_control_1[0]),
      .WL_CM(negxbar_data_c_1),
      .CEB(negxbar_enable_1[1]),
      .RSTB(negxbar_enable_1[0]),
      //.xbar_row(negxbar_row_1),
      
      .SENsel (SENsel),
      .SAENin (SAENin),
      .SA_TM (SA_TM),
      .Vref (VREF),
      .REF_TM (REF_TW),
      .REF_EXT (REF_EXT),
      .WLP_TM (WLP_TM),
      .DIS_TM (DIS_TM),
      .EXT_DIS (EXT_DIS),
      .EXT_WLP (EXT_WLP),
      .BL_EXT_EN (BL_EXT_EN),
      .VD_EXT (VD_EXT),
      .WL_EXT_EN (WL_EXT_EN),
      .VWL_EXT (VWL_EXT),
      .VRST (VRST),
      .VSET (VSET),
      .VCLP (VCLP),
      .VWL_READ (VWL_READ),
      .VWL_RST (VWL_RST),
      .VWL_SET (VWL_SET),
      .WL_DU (WL_DU),

      .DO_CM(xbar_result_c_neg_1),
      .DO_R(xbar_result_r_neg_1)
      //.xbar_result_w(xbar_result_w_neg_1)
      );
    
    aftermodule 
   // .PE_NUM (4)
    after1(
    .CLK        (CLK),
    .DTMBsig    (DTMBsig),
    .RESET      (RESET),
    .RESET_INsig (RESET_INsig),
    .fwdsig_control   (next_control_1),
    .fwdsig_address   (next_address_1),
    .fwdsig_data_c    (next_data_c_1),
    .fwdsig_xbar_address    (next_xbar_address_1),
    .fwdsig_data_w    (next_data_w_1),
    .posxbarsig_result_c    (xbar_result_c_pos_1),
    .negxbarsig_result_c    (xbar_result_c_neg_1),
    .posxbarsig_result_r    (xbar_result_r_pos_1),
    .negxbarsig_result_r    (xbar_result_r_neg_1),
    //.posxbarsig_result_w    (xbar_result_w_pos_1),
    //.negxbarsig_result_w    (xbar_result_w_neg_1),
    .fwdsig_row   (next_row_1),
    .fwdsig_sigmoid_threshold (next_sigmoid_threshold_1),
    .fwdsig_id (next_id_1),
    
    .output_id (output_id_1),
    .pre_data_c   (pre_data_c_1),
    .output_data_c    (output_data_c_1),
    .pre_row    (pre_row_1),
    .output_control   (output_control_1),
    .output_address   (output_address_1),
    .output_xbar_address    (output_xbar_address_1),
    .output_data_w    (output_data_w_1),
    .output_data_r    (output_data_r_1),
    .output_flag      (output_flag_1),
    //.output_flag_w    (output_flag_w_1),
    .output_sigmoid_threshold (output_sigmoid_threshold_1),
    .pre_flag     (pre_flag_1)
    
    );
    
    
    
    //***************end of 1st level**************
    
     
    frontmodule_second 
   // .PE_NUM (4)
    front2nd1(
    //.CLK_PIPELINE (CLK_PIPELINE),
    .CLK        (CLK),
    .RESET      (RESET),
    .RESET_INsig (RESET_INsig),
    
    .SIGM_INsig (SIGM_INsig),
    .ID_INsig (ID_INsig),
    .TMBsig (TMBsig),
    .DTMBsig (DTMBsig),
    .XBAR_ADDRsig (XBAR_ADDRsig),
    .AXsig (AXsig),
    .AYsig (AYsig),
    .CEBsig (CEBsig),
    .RSTBsig (RSTBsig),
    .WEBsig (WEBsig),
    .CMEBsig (CMEBsig),
    .DINsig (DINsig),
    .CM_WLsig (CM_WLsig),
    .LAYERsig (LAYERsig),
    .DTWHOLEsig (DTWHOLEsig),
    
    .inputsig_id (output_id_1),
    .inputsig_control(output_control_1),
    .inputsig_address(output_address_1),
    .inputsig_data_c(output_data_c_1),
    .inputsig_xbar_address(output_xbar_address_1),
    .inputsig_data_w(output_data_w_1),
    .inputsig_flag(output_flag_1),
    .inputsig_sigmoid_threshold(output_sigmoid_threshold_1),
    .feedbacksig_flag(pre_flag_2),
    .feedbacksig_data(pre_data_c_2),
    .feedbacksig_row(pre_row_2),
    .inputsig_data_r(output_data_r_1),
    //.inputsig_flag_w(output_flag_w_1),

    .next_id (next_id_2),
    .next_data_r (next_data_r_2),
    //.next_flag_w (next_flag_w_2),
    .next_control(next_control_2),
    .next_data_w(next_data_w_2),
    .posxbar_data_w(posxbar_data_w_2),
    .negxbar_data_w(negxbar_data_w_2),
    .next_row (next_row_2),
    .next_address(next_address_2), 
    .posxbar_address(posxbar_address_2), 
    .negxbar_address(negxbar_address_2),
    .next_xbar_address(next_xbar_address_2) ,
    .posxbar_control(posxbar_control_2),
    .posxbar_enable (posxbar_enable_2),
    .posxbar_data_c(posxbar_data_c_2), 
    .next_data_c(next_data_c_2),
    //.posxbar_row(posxbar_row_2),
    .negxbar_control(negxbar_control_2),
    .negxbar_enable(negxbar_enable_2),
    .negxbar_data_c(negxbar_data_c_2),
    .next_sigmoid_threshold (next_sigmoid_threshold_2)
    //.negxbar_row(negxbar_row_2)
    
    );
    
    
    crossbar
      // #(
      //.XBAR_ADDR (2'b10)
      posxbar2(
      .CLK (CLK),
      .DIN(posxbar_data_w_2),
      .AX(posxbar_address_2[11:6]),
      .AY(posxbar_address_2[5:0]), 
      .WEB(posxbar_control_2[1]),
      .CMEB(posxbar_control_2[0]),
      .WL_CM(posxbar_data_c_2),
      .CEB(posxbar_enable_2[1]),
      .RSTB(posxbar_enable_2[0]),
      //.xbar_row(posxbar_row_2),
      
      .SENsel (SENsel),
      .SAENin (SAENin),
      .SA_TM (SA_TM),
      .Vref (VREF),
      .REF_TM (REF_TW),
      .REF_EXT (REF_EXT),
      .WLP_TM (WLP_TM),
      .DIS_TM (DIS_TM),
      .EXT_DIS (EXT_DIS),
      .EXT_WLP (EXT_WLP),
      .BL_EXT_EN (BL_EXT_EN),
      .VD_EXT (VD_EXT),
      .WL_EXT_EN (WL_EXT_EN),
      .VWL_EXT (VWL_EXT),
      .VRST (VRST),
      .VSET (VSET),
      .VCLP (VCLP),
      .VWL_READ (VWL_READ),
      .VWL_RST (VWL_RST),
      .VWL_SET (VWL_SET),
      .WL_DU (WL_DU),

      .DO_CM(xbar_result_c_pos_2),
      .DO_R(xbar_result_r_pos_2)
      //.xbar_result_w(xbar_result_w_pos_2)
      );
    
    crossbar
    //   #(
    //  .XBAR_ADDR (2'b11)
    //  )
      negxbar2(
      .CLK (CLK),
      .DIN(negxbar_data_w_2),
      .AX(negxbar_address_2[11:6]),
      .AY(negxbar_address_2[5:0]), 
      .WEB(negxbar_control_2[1]),
      .CMEB(negxbar_control_2[0]),
      .WL_CM(negxbar_data_c_2),
      .CEB(negxbar_enable_2[1]),
      .RSTB(negxbar_enable_2[0]),
      //.xbar_row(negxbar_row_2),
      
      .SENsel (SENsel),
      .SAENin (SAENin),
      .SA_TM (SA_TM),
      .Vref (VREF),
      .REF_TM (REF_TW),
      .REF_EXT (REF_EXT),
      .WLP_TM (WLP_TM),
      .DIS_TM (DIS_TM),
      .EXT_DIS (EXT_DIS),
      .EXT_WLP (EXT_WLP),
      .BL_EXT_EN (BL_EXT_EN),
      .VD_EXT (VD_EXT),
      .WL_EXT_EN (WL_EXT_EN),
      .VWL_EXT (VWL_EXT),
      .VRST (VRST),
      .VSET (VSET),
      .VCLP (VCLP),
      .VWL_READ (VWL_READ),
      .VWL_RST (VWL_RST),
      .VWL_SET (VWL_SET),
      .WL_DU (WL_DU),

      .DO_CM(xbar_result_c_neg_2),
      .DO_R(xbar_result_r_neg_2)
      //.xbar_result_w(xbar_result_w_neg_2)
      );   
    
    aftermodule_second
   // .PE_NUM (4)
    after2nd1(
    .CLK        (CLK),
    .DTMBsig    (DTMBsig),
    .RESET      (RESET),
    .RESET_INsig (RESET_INsig),
    .fwdsig_id (next_id_2),
    .fwdsig_control   (next_control_2),
    .fwdsig_address   (next_address_2),
    .fwdsig_data_c    (next_data_c_2),
    .fwdsig_xbar_address    (next_xbar_address_2),
    .fwdsig_data_w    (next_data_w_2),
    .posxbarsig_result_c    (xbar_result_c_pos_2),
    .negxbarsig_result_c    (xbar_result_c_neg_2),
    .posxbarsig_result_r    (xbar_result_r_pos_2),
    .negxbarsig_result_r    (xbar_result_r_neg_2),
    //.posxbarsig_result_w    (xbar_result_w_pos_2),
    //.negxbarsig_result_w    (xbar_result_w_neg_2),
    .fwdsig_row   (next_row_2),
    .fwdsig_sigmoid_threshold (next_sigmoid_threshold_2),
    .fwdsig_data_r (next_data_r_2),
    //.fwdsig_flag_w (next_flag_w_2),
    
    .output_id (output_id_2),
    .pre_data_c   (pre_data_c_2),
    .output_data_c    (output_data_c_2),
    .pre_row    (pre_row_2),
    .output_control   (output_control_2),
    .output_address   (output_address_2),
    .output_xbar_address    (output_xbar_address_2),
    .output_data_w    (output_data_w_2),
    .output_data_r    (output_data_r_2),
    .output_flag      (output_flag_2),
    //.output_flag_w    (output_flag_w_2),
    .output_sigmoid_threshold (output_sigmoid_threshold_2),
    .pre_flag     (pre_flag_2)
    
    );
/*
     output_driver
   // .PE_NUM (4)
    out_driver1(
    .CLK        (CLK),
    .RESET      (RESET),
    .output_data_c (output_data_c_2),
    .output_control (output_control_2),
    .output_address (output_address_2),
    .output_id (output_id_2),
  .output_xbar_address (output_xbar_address_2),
  .output_data_w (output_data_w_2),
  .output_data_r (output_data_r_2),
  .output_flag (output_flag_2),
  //.output_flag_w (output_flag_w_2),
  .output_sigmoid_threshold (output_sigmoid_threshold_2),
  
  .outputs_flagsig (outputs_flagsig),
  .outputs_addrsig (outputs_addrsig),
  .outputs_datasig (outputs_datasig)
    
    );
    */
    always @ (negedge CLK)
  begin
    if (TMBsig == 1 )
      begin
        if (XBAR_ADDRsig == 2'b00)
          begin
            DO_Rpo <= xbar_result_r_pos_1;
            DO_CMpo <= xbar_result_c_pos_1;
          end
        else if (XBAR_ADDRsig == 2'b01)
          begin
            DO_Rpo <= xbar_result_r_neg_1;
            DO_CMpo <= xbar_result_c_neg_1;
          end
        else if (XBAR_ADDRsig == 2'b10)
          begin
            DO_Rpo <= xbar_result_r_pos_2;
            DO_CMpo <= xbar_result_c_pos_2;
          end
        else if (XBAR_ADDRsig == 2'b11)
          begin
            DO_Rpo <= xbar_result_r_neg_2;
            DO_CMpo <= xbar_result_c_neg_2;
          end
      end
    else if(DTMBsig ==1 && LAYERsig == 0 && DTWHOLEsig == 0)
      begin
        DO_Rpo <= output_data_r_1;
        DO_CMpo <= {output_id_1[0],output_data_c_1[10:0]};
      end      
    else if(DTMBsig ==1 && DTWHOLEsig == 1)
      begin
        DO_Rpo <= output_data_r_2;
        DO_CMpo <= {output_id_2[0],output_data_c_2[10:0]};
      end  
    else if(DTMBsig ==1 && LAYERsig == 1 && DTWHOLEsig == 0)
      begin
        DO_Rpo <= output_data_r_2;
        DO_CMpo <= {output_id_2[0],output_data_c_2[10:0]};
      end     
  end

endmodule
  
  