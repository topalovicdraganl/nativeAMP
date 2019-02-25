`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/01/2013 11:47:10 AM
// Design Name: 
// Module Name: system_wrapper_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 


/*


//Reset the PL
zynq_sys.zynq_platform_i.processing_system7_0.inst.fpga_soft_reset(32'h1);
zynq_sys.zynq_platform_i.processing_system7_0.inst.fpga_soft_reset(32'h0);


Single Read/writes:
zynq_sys.zynq_platform_i.processing_system7_0.inst.write_data([31:0] addr,[7:0] wr_size, [1023:0] wr_data, RESPONSE);
zynq_sys.zynq_platform_i.processing_system7_0.inst.read_data(32'h80000000,[7:0] rd_size,read_data,RESPONSE);

Burst read/writes: 
zynq_sys.zynq_platform_i.processing_system7_0.inst.write_burst(ADDR,Burst Length,Burst Size, Burst Type, Lock Type, Cache Type, Protection Type, Data to send,DATASIZEinbytes,RESPONSE);
zynq_sys.zynq_platform_i.processing_system7_0.inst.read_burst(ADDR,Burst Length,Burst Size, Burst Type, Lock Type, Cache Type, Protection Type, Data,RESPONSE);

Concurrent Burst Read/Writes:
zynq_sys.zynq_platform_i.processing_system7_0.inst.write_burst_concurrent(ADDR,Burst Length,Burst Size, Burst Type, Lock Type, Cache Type, Protection Type, Data to send,DATASIZEinbytes,RESPONSE);
zynq_sys.zynq_platform_i.processing_system7_0.inst.read_burst_concurrent(ADDR,Burst Length,Burst Size, Burst Type, Lock Type, Cache Type, Protection Type, Data,RESPONSE);

Register Reads:
zynq_sys.zynq_platform_i.processing_system7_0.inst.read_register(ADDR,Data);
zynq_sys.zynq_platform_i.processing_system7_0.inst.read_register_map(ADDR,size,Data);

Preload Data Functions.
zynq_sys.zynq_platform_i.processing_system7_0.inst.pre_load_mem_from_file([1023:0] file_name,[31:0] start_addr,no_of_bytes);
zynq_sys.zynq_platform_i.processing_system7_0.inst.pre_load_mem([1:0] data_type,[31:0] start_addr,,no_of_bytes); //00-Random , 01- Zeros, 10 - Ones.

Interrupt:
zynq_sys.zynq_platform_i.processing_system7_0.inst.wait_interrupt([3:0] irq_status);


Memory functions 
zynq_sys.zynq_platform_i.processing_system7_0.inst.wait_mem_update( [31:0] addr; [31:0] data_i,[31:0] data_o);

RESPONSE: The slave write response from the following: [OKAY, EXOKAY, SLVERR, DECERR]

*/

//////////////////////////////////////////////////////////////////////////////////


`timescale 1 ps / 1 ps
// lib IP_Integrator_Lib

`define INIT_DELAY   400
`define INT_DELAY   40

//user slave defines
`define REG_BASE_ADDR  32'h40000000
`define BUF_BASE_ADDR  32'h40010000
`define FIFO_BASE_ADDR  32'h40020000
`define C_SLV_AWIDTH     32
`define C_SLV_DWIDTH     32

//ETHERNET PAcket field 
`define SRC_ADDR  48'h0A0B0C0D0E0F
`define DST_ADDR  48'h0A0B0C0D0EFF
`define IPV4      16'h0008
`define ARP       16'h0608
`define IPV6      16'hDD86
`define VLAN      16'h0081

//Response type defines
`define RESPONSE_OKAY   2'b00

//AMBA 4 defines
`define RESP_BUS_WIDTH   2
`define MAX_BURST_LENGTH 8'b1111_1111
`define SINGLE_BURST_LENGTH 8'b0000_0000

// Burst Size Defines
`define BURST_SIZE_1_BYTE    3'b000
`define BURST_SIZE_2_BYTES   3'b001
`define BURST_SIZE_4_BYTES   3'b010
`define BURST_SIZE_8_BYTES   3'b011
`define BURST_SIZE_16_BYTES  3'b100
`define BURST_SIZE_32_BYTES  3'b101
`define BURST_SIZE_64_BYTES  3'b110
`define BURST_SIZE_128_BYTES 3'b111

// Lock Type Defines
`define LOCK_TYPE_NORMAL    1'b0

// Burst Type Defines
`define BURST_TYPE_INCR  2'b01

`uselib lib=unisims_ver

//RESPONSE: The slave write response from the following: [OKAY, EXOKAY, SLVERR, DECERR]   

module system_wrapper_tb;

parameter RUSER_BUS_WIDTH  = 1;
  parameter WUSER_BUS_WIDTH  = 1;
  parameter ETH_MEM_SIZE   = 400;
  parameter BUF_MEM_SIZE   = 256;
  parameter FIFO_MEM_SIZE   = 8;
  
    //additional signals
  reg        [(`C_SLV_DWIDTH*(`MAX_BURST_LENGTH+1))-1 : 0] rd_data;
  reg        [8-1 : 0] rd_size;
  reg        [127 : 0]test_data[0:69] ;
  reg        [31 : 0]base_addr[0:1] ;
  reg        [`RESP_BUS_WIDTH-1 : 0]        response;
  reg        [(`RESP_BUS_WIDTH*(`MAX_BURST_LENGTH+1))-1 : 0] vresponse;
  reg        [`C_SLV_AWIDTH-1 : 0]          mtestADDR;
  reg        [`C_SLV_AWIDTH-1 : 0]          test_address;
  reg        [(RUSER_BUS_WIDTH*(`MAX_BURST_LENGTH+1))-1 : 0] v_ruser;
  reg        [(WUSER_BUS_WIDTH*(`MAX_BURST_LENGTH+1))-1 : 0] v_wuser;

  reg                                       interrupt_in;
  reg                                       interrupt_out;
  reg                                       set_bit;
  
  //Integers
  integer                                   mtestID;
  integer                                   mtestBurstLength;
  integer                                   mtestLockType;
  integer                                   mtestBurstSize;
  integer                                   mtestCacheType;
  integer                                   mtestdatasize;
  integer                                   mtestProtectionType;
  integer                                   mtestRegion;
  integer                                   mtestQOS;
  integer                                   mtestBUSER;
  integer                                   mtestAWUSER;
  integer                                   mtestARUSER;
  integer                                   i;
  integer                                   j;
  integer                                    k;
  integer                                   l;
  integer                                  init_size;
  integer                                   number_of_bytes_in_full_burst;
  integer                                   no_of_bursts; 


reg [0:0]PS_CLK;
reg  [0:0]tb_ARESETn;  
wire PS_CLK1;
wire tb1_ARESETn;

reg[3:0] irq_status1,irq_status2;

system_wrapper zynq_sys
       (.DDR_addr(),
        .DDR_ba(),
        .DDR_cas_n(),
        .DDR_ck_n(),
        .DDR_ck_p(),
        .DDR_cke(),
        .DDR_cs_n(),
        .DDR_dm(),
        .DDR_dq(),
        .DDR_dqs_n(),
        .DDR_dqs_p(),
        .DDR_odt(),
        .DDR_ras_n(),
        .DDR_reset_n(),
        .DDR_we_n(),
        .FIXED_IO_ddr_vrn(),
        .FIXED_IO_ddr_vrp(),
        .FIXED_IO_mio(),
        .FIXED_IO_ps_clk(PS_CLK1),
        .FIXED_IO_ps_porb(tb1_ARESETn),
        .FIXED_IO_ps_srstb(tb1_ARESETn),
        .dip_switches_4bits_tri_i(4'b0),
        .gpio_sws_3bits_tri_i(3'b0),
        .led_4bits_tri_o()
        
        //.interrupt_in(interrupt_in)
        );     

        
        
    //------------------------------------------------------------------------
    // Simple Clock Generator
    //------------------------------------------------------------------------
    initial begin
      PS_CLK = 1'b0;
      forever #10 PS_CLK = !PS_CLK;          
    end   
      
 assign PS_CLK1 =PS_CLK;
 
  
//    initial begin
//      tb_ARESETn = 1'b0;
//      // Release the reset on the posedge of the clk.
//      repeat(1000)@(posedge PS_CLK);
//      tb_ARESETn = 1'b1;
//      @(posedge PS_CLK);
//    end
         
assign tb1_ARESETn = tb_ARESETn ;  

initial begin

  tb_ARESETn = 1'b0;
  // Release the reset on the posedge of the clk.
  repeat(1000)@(posedge PS_CLK);
  tb_ARESETn = 1'b1;
  @(posedge PS_CLK);
  
  zynq_sys.system_i.processing_system7_0.inst.fpga_soft_reset(32'h1);
  zynq_sys.system_i.processing_system7_0.inst.fpga_soft_reset(32'h0);
  zynq_sys.system_i.processing_system7_0.inst.read_data(32'h80000000,rd_size,rd_data,response);
   
  //----------------------------------------------------------------------------
  // Select the correct burst size ot match the data bus widths
  //----------------------------------------------------------------------------

    //case (`C_SLV_DWIDTH)
    //    8  : mtestBurstSize = `BURST_SIZE_1_BYTE;
    //    16 : mtestBurstSize = `BURST_SIZE_2_BYTES;
    //    32 : mtestBurstSize = `BURST_SIZE_4_BYTES;
    //    64 : mtestBurstSize = `BURST_SIZE_8_BYTES;
    //    128 : mtestBurstSize = `BURST_SIZE_16_BYTES;
    //    256 : mtestBurstSize = `BURST_SIZE_32_BYTES;
    //    512 : mtestBurstSize = `BURST_SIZE_64_BYTES;
    //    1024 : mtestBurstSize = `BURST_SIZE_128_BYTES;
    //    default : begin
    //                $display("-----------------------------------------------------");
    //                $display("EXAMPLE TEST : FAILED -- Invalid C_SLV_DWIDTH");
    //                $display("-----------------------------------------------------");
    //              end
    //endcase
    ////-------------------------------------------------------------------------------------
    //
    //interrupt_in = 1'b0;
    //// --------------------------------------------
    ////-----------Step 1-------------------------
    ////--------------------------------------------
    //$display("Setting up Number of BDs");
    //zynq_sys.zynq_platform_i.processing_system7_0.inst.write_data(32'h40000004,4, 32'h00000020, response);
    ////$display("TEST 1 : Burst %0d,WRITE DATA = 0x%h, response = 0x%h",i,test_data,response);
    //CHECK_RESPONSE_OKAY(response);
    //
    // //--------------------------------------------
    // //-----------Step 2-------------------------
    // //--------------------------------------------   
    //$display("Starting the Engine");
    //zynq_sys.zynq_platform_i.processing_system7_0.inst.write_data(32'h40000000,4, 32'h00000001, response);
    ////$display("TEST 1 : Burst %0d,WRITE DATA = 0x%h, response = 0x%h",i,test_data,response);
    //CHECK_RESPONSE_OKAY(response);
    //
    ////--------------------------------------------
    ////-----------Step 3-------------------------
    ////--------------------------------------------   
    //$display("Intializing the Buffer Addresses in the PPU");
    //test_address = 32'h00000000;
    //
    //for (i = 0; i < 32 ; i = i+1) begin
    //    mtestADDR = i * 8 + 32'h40010000;
    //    test_address = test_address + 32'h00010000;
    //    zynq_sys.zynq_platform_i.processing_system7_0.inst.write_data(mtestADDR,4,test_address,response);
    //     //$display("TEST 1 : Burst %0d,WRITE DATA = 0x%h, response = 0x%h",i,test_data,response);
    //    CHECK_RESPONSE_OKAY(response);
    //end
    //
    //    
    ////--------------------------------------------
    ////-----------Step 4-------------------------
    ////--------------------------------------------   
    //$display("Preparing Test Pattern");    
    //mtestBurstLength = 8'b0000_0011; 
    //number_of_bytes_in_full_burst = 16;	
    //
    //// adjunstement made in order not to exceed 4KB Boundary
    //if (number_of_bytes_in_full_burst > 4*256) begin
    //  number_of_bytes_in_full_burst = 4*256;
    //  mtestBurstLength = ((4*256)/(`C_SLV_DWIDTH/8))-1;
    //end
    //
    // //transmit packet 
    //$display("---------------------------------------------------------");
    //$display("Transmitting ethernet packets ");
    //$display("---------------------------------------------------------");
    //for (k = 2; k < 70 ; k = k+1) begin 
    //    for (l = 0; l < number_of_bytes_in_full_burst; l=l+1) begin
    //    test_data[k][l*8 +: 8] = l+ (k * number_of_bytes_in_full_burst)  ;
    //  end
    //end	
    //
    //base_addr[0] = 32'h80000000;
    //base_addr[1] = 32'h80010000;
    //
    //set_bit = 1'b0;
    //
    //// Transmit IPV4 Packet
    //$display("---------------------------------------------------------");
    //$display("Transmitting IPV4 Packets");
    //$display("---------------------------------------------------------");
    //
    //for (j = 0; j < 5 ; j = j+1) begin 
    //    $display("Packet %d", j);
    //    
    //    test_data[0]   = {16'h0045,`IPV4,`SRC_ADDR,`DST_ADDR};         
    //    test_data[1]   = {112'h232221201f1e1d1c1b1a1918,16'hEA03};  
    //    init_size = 1016 ;
    //    
    //    if (( init_size % number_of_bytes_in_full_burst) == 0) begin
    //        no_of_bursts = (init_size /number_of_bytes_in_full_burst);
    //    end else begin
    //        no_of_bursts = (init_size /number_of_bytes_in_full_burst) + 1;
    //    end
    //	
    //	for (i = 0; i < no_of_bursts; i = i+1) begin   
    //		
    //		if (init_size > number_of_bytes_in_full_burst) begin
    //		 	mtestdatasize = number_of_bytes_in_full_burst;
    //			mtestBurstLength = 8'b0000_0011;			
    //		end else begin
    //		   mtestdatasize =  init_size;
    //			if ((mtestdatasize >= 1) && (mtestdatasize < 5)) begin 	mtestBurstLength = 8'b0000_0000; 
    //			end else if ((mtestdatasize >= 5) && (mtestdatasize < 9)) begin mtestBurstLength = 8'b0000_0001; 
    //			end else if ((mtestdatasize >= 9) && (mtestdatasize < 13)) begin mtestBurstLength = 8'b0000_0010;
    //			end else if ((mtestdatasize >= 13) && (mtestdatasize < 17)) begin mtestBurstLength = 8'b0000_0011; 
    //			end else begin mtestBurstLength = 8'b0000_0011; end			
    //		 end
    //   
    //    // Make the test vector
    //
    //        mtestADDR = i * number_of_bytes_in_full_burst + base_addr[set_bit];
    //        zynq_sys.zynq_platform_i.processing_system7_0.inst.write_burst(mtestADDR,mtestBurstLength,`BURST_SIZE_4_BYTES,
    //                                                                       `BURST_TYPE_INCR,`LOCK_TYPE_NORMAL,0,0,test_data[i],mtestdatasize,
    //                                                                       response);
    //        
    //        init_size = init_size - number_of_bytes_in_full_burst; 
    //        CHECK_RESPONSE_OKAY(response); 
    //    end  
    //	  
    //    interrupt_in = 1'b1;
    //    #`INT_DELAY interrupt_in = 1'b0;	
    //    #10;
    //    
    //
    //    
    //    set_bit = ~ set_bit;
    //    $display("---------------------------------------------------------");
    //    $display("IPV4 Packet %d  Done", j);
    //    $display("---------------------------------------------------------");
    //    #10;	 
    //end  
    //
    //// Transmit IPV4 Packet
    //$display("---------------------------------------------------------");
    //$display("Transmitting ARP Packets");
    //$display("---------------------------------------------------------");
    //
    //for (j = 0; j < 5 ; j = j+1) begin 
    //    $display("Packet %d", j);
    //    
    //    test_data[0]   = {16'h0045,`ARP,`SRC_ADDR,`DST_ADDR};         
    //    test_data[1]   = {112'h0A050A060A070A080B010B02FFFF,16'hE803};  
    //    init_size = 60 ;
    //    
    //    if (( init_size % number_of_bytes_in_full_burst) == 0) begin
    //        no_of_bursts = (init_size /number_of_bytes_in_full_burst);
    //    end else begin
    //        no_of_bursts = (init_size /number_of_bytes_in_full_burst) + 1;
    //    end
    //    
    //    for (i = 0; i < no_of_bursts; i = i+1) begin   
    //        
    //        if (init_size > number_of_bytes_in_full_burst) begin
    //            mtestdatasize = number_of_bytes_in_full_burst;
    //            mtestBurstLength = 8'b0000_0011;			
    //        end else begin
    //           mtestdatasize =  init_size;
    //            if ((mtestdatasize >= 1) && (mtestdatasize < 5)) begin 	mtestBurstLength = 8'b0000_0000; 
    //            end else if ((mtestdatasize >= 5) && (mtestdatasize < 9)) begin mtestBurstLength = 8'b0000_0001; 
    //            end else if ((mtestdatasize >= 9) && (mtestdatasize < 13)) begin mtestBurstLength = 8'b0000_0010;
    //            end else if ((mtestdatasize >= 13) && (mtestdatasize < 17)) begin mtestBurstLength = 8'b0000_0011; 
    //            end else begin mtestBurstLength = 8'b0000_0011; end			
    //         end
    //   
    //    // Make the test vector
    //
    //        mtestADDR = i * number_of_bytes_in_full_burst + base_addr[set_bit];
    //        zynq_sys.zynq_platform_i.processing_system7_0.inst.write_burst(mtestADDR,mtestBurstLength,`BURST_SIZE_4_BYTES,
    //                                                                       `BURST_TYPE_INCR,`LOCK_TYPE_NORMAL,0,0,test_data[i],mtestdatasize,
    //                                                                       response);
    //        
    //        init_size = init_size - number_of_bytes_in_full_burst; 
    //        CHECK_RESPONSE_OKAY(response); 
    //    end  
    //      
    //    interrupt_in = 1'b1;
    //    #`INT_DELAY interrupt_in = 1'b0;	
    //    #10;
    //    set_bit = ~ set_bit;
    //    $display("---------------------------------------------------------");
    //    $display("ARP Packet %d  Done", j);
    //    $display("---------------------------------------------------------");
    //    #10;	 
    //end      
    //
    //
    //// Transmit IPV4 Packet
    //$display("---------------------------------------------------------");
    //$display("Transmitting ETH LEGACY Packets");
    //$display("---------------------------------------------------------");
    //
    //for (j = 0; j < 5 ; j = j+1) begin 
    //    $display("Packet %d", j);
    //    
    //    
    //    test_data[0]   = {16'h0045,16'hE803,`SRC_ADDR,`DST_ADDR};         
    //    test_data[1]   = {112'h0A050A060A070A080B010B02FFFF,16'hE803};  
    //    init_size = 1014 ;
    //    
    //    if (( init_size % number_of_bytes_in_full_burst) == 0) begin
    //        no_of_bursts = (init_size /number_of_bytes_in_full_burst);
    //    end else begin
    //        no_of_bursts = (init_size /number_of_bytes_in_full_burst) + 1;
    //    end
    //    
    //    for (i = 0; i < no_of_bursts; i = i+1) begin   
    //        
    //        if (init_size > number_of_bytes_in_full_burst) begin
    //            mtestdatasize = number_of_bytes_in_full_burst;
    //            mtestBurstLength = 8'b0000_0011;			
    //        end else begin
    //           mtestdatasize =  init_size;
    //            if ((mtestdatasize >= 1) && (mtestdatasize < 5)) begin 	mtestBurstLength = 8'b0000_0000; 
    //            end else if ((mtestdatasize >= 5) && (mtestdatasize < 9)) begin mtestBurstLength = 8'b0000_0001; 
    //            end else if ((mtestdatasize >= 9) && (mtestdatasize < 13)) begin mtestBurstLength = 8'b0000_0010;
    //            end else if ((mtestdatasize >= 13) && (mtestdatasize < 17)) begin mtestBurstLength = 8'b0000_0011; 
    //            end else begin mtestBurstLength = 8'b0000_0011; end			
    //         end
    //   
    //    // Make the test vector
    //
    //        mtestADDR = i * number_of_bytes_in_full_burst + base_addr[set_bit];
    //        zynq_sys.zynq_platform_i.processing_system7_0.inst.write_burst(mtestADDR,mtestBurstLength,`BURST_SIZE_4_BYTES,
    //                                                                       `BURST_TYPE_INCR,`LOCK_TYPE_NORMAL,0,0,test_data[i],mtestdatasize,
    //                                                                       response);
    //        
    //        init_size = init_size - number_of_bytes_in_full_burst; 
    //        CHECK_RESPONSE_OKAY(response); 
    //    end  
    //      
    //    interrupt_in = 1'b1;
    //    #`INT_DELAY interrupt_in = 1'b0;	
    //    #10;
    //    set_bit = ~ set_bit;
    //    $display("---------------------------------------------------------");
    //    $display("ETH LEGACY Packet %d  Done", j);
    //    $display("---------------------------------------------------------");
    //    #10;	 
    //end  
$finish;       
end


   
//----------------------------------------------------------------------------
  //   TEST LEVEL API: CHECK_RESPONSE_OKAY(response)
  //----------------------------------------------------------------------------

  //Description: This task check if the return response is equal to OKAY
  //----------------------------------------------------------------------
  //task automatic CHECK_RESPONSE_OKAY;
  //  input [`RESP_BUS_WIDTH-1:0] response;
  //   begin
  //    if (response !== `RESPONSE_OKAY) begin
  //      $display("TESTBENCH FAILED! Response is not OKAY",
  //        "\n expected = 0x%h",`RESPONSE_OKAY,
  //        "\n actual = 0x%h", response);
  //      $stop;
  //    end
  //  end
  //endtask
  //----------------------------------------------------------------------------
  //   TEST LEVEL API: COMPARE_DATA(expected,actual)
  //----------------------------------------------------------------------------

  //Description: This task checks if the actual data is equal to the expected data
  //----------------------------------------------------------------------
  //task automatic COMPARE_DATA;
  //  input [(`C_SLV_DWIDTH*(`MAX_BURST_LENGTH+1))-1:0] expected;
  //  input [(`C_SLV_DWIDTH*(`MAX_BURST_LENGTH+1))-1:0] actual;
  //  begin
  //    if (expected === 'hx || actual === 'hx) begin
  //      $display("TESTBENCH FAILED! COMPARE_DATA cannot be performed with an expected or actual vector that is all 'x'!");
  //      $stop;
  //    end
  //    if (actual !== expected) begin
  //      $display("TESTBENCH FAILED! Data expected is not equal to actual.","\n expected = 0x%h",expected,
  //      "\n actual   = 0x%h",actual);
  //      $stop;
  //    end
  //  end
  //  endtask
  //----------------------------------------------------------------------------
  //   TEST LEVEL API: CHECK_RESPONE_VECTOR_OKAY(response,burst_length)
  //----------------------------------------------------------------------------

//Description: This task checks if the response vectorreturned from the READ_BURST
//-------------------------------------------------
  //task automatic CHECK_RESPONSE_VECTOR_OKAY;
  //  input [(`RESP_BUS_WIDTH*(`MAX_BURST_LENGTH+1))-1:0] response;
  //  input integer                                       burst_length;
  //  integer                                             i;
  //  begin
  //    for (i = 0; i < burst_length+1; i = i+1) begin
  //      CHECK_RESPONSE_OKAY(response[i*`RESP_BUS_WIDTH +: `RESP_BUS_WIDTH]);
  //    end
  //  end
  //endtask

  //----------------------------------------------------------------------------
  //   TEST LEVEL API: COMPARE_RUSER(expected, actual)
  //----------------------------------------------------------------------------

// Description:This task checks if the actual wuser data is equal to the expected data.
//------------------------------------------------------------------------
  //task automatic COMPARE_RUSER;
  //  input [(RUSER_BUS_WIDTH*(`MAX_BURST_LENGTH+1))-1:0] expected;
  //  input [(RUSER_BUS_WIDTH*(`MAX_BURST_LENGTH+1))-1:0] actual;
  //  begin
  //    if (expected === 'hx || actual === 'hx) begin
  //      $display("TESTBENCH FAILED! COMPARE_RUSER cannotbe performed with an expected or actual vector that is all 'x'!");
  //      $stop;
  //    end
  //    if (actual != expected) begin
  //      $display("TESTBENCH FAILED! RUSER data expected is not equal to actual.",
  //        "\n expected = 0x%h",expected,
  //        "\n actual   = 0x%h",actual);
  //      $stop;
  //    end
  //  end
  //endtask 

        
        
endmodule
