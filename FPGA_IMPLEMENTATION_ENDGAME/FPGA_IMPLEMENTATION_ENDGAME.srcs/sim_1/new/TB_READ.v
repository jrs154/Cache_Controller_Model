`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.10.2019 05:13:39
// Design Name: 
// Module Name: TB_READ
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
//////////////////////////////////////////////////////////////////////////////////


module TB_READ();

reg [10:0] address;
reg [3:0] data;
reg mode, clk;
wire [3:0] output_data;
wire hit1, hit2;
wire Wait;
wire clk2;

CACHE_CONTROLLER inst(
	.address(address),
	.data(data),
	.mode(mode),
	.clk(clk),
	.output_data(output_data),
	.hit1(hit1),
	.hit2(hit2),
	.Wait(Wait),
	.clk2(clk2)
);

initial
begin
	clk = 1'b1;
	/******************************/
//	address = 32'b00000000000000000000000000000000;	 //0 blk
//	data =    8'b10110000;	 
//	mode = 1'b0; //read
	
	address = 11'b00000111100;	 //0 blk
	data =    4'b1100;	 
	mode = 1'b0; //read	

    #50
	address = 11'b00000000010;	 //0 blk
	data =    4'b0001;	 
	mode = 1'b0; //read	

    #50
	address = 11'b00000010000;	 //0 blk
	data =    4'b0010;	 
	mode = 1'b0; //read	
	
    #50
	address = 11'b00000010001;	 //0 blk
	data =    4'b0001;	 
	mode = 1'b0; //read	

    #50
	address = 11'b00000100001;	 //0 blk
	data =    4'b0100;	 
	mode = 1'b0; //read	

    #50
	address = 11'b00000100010;	 //0 blk
	data =    4'b0101;	 
	mode = 1'b0; //read		

    #50
	address = 11'b00000000001;	 //0 blk
	data =    4'b1110;	 
	mode = 1'b0; //read	
		
	#50
	address = 11'b01000000010;	 //128 blk
	data =    4'b1011;	 
	mode = 1'b0; //read
	
	#50
	address = 11'b10000000010;	//256 blk
	data =    4'b1011;	 
	mode = 1'b0; //read
	
	#50
	address = 11'b11000000010;	 //384 blk
	data =    4'b1011;	 
	mode = 1'b0; //read
	
	#50
	address = 11'b10000000010;	 //512 blk
	data =    4'b1011;	 
	mode = 1'b0; //read
	
	#50
	address = 11'b00000000010;	 //0 blk
	data =    4'b1011;	 
	mode = 1'b0; //read
	
	#50
	address = 11'b11000000010;	 //384 blk
	data =    4'b1011;
	mode = 1'b0; //read    */
	/******************************/
	
	/******************************/
	#50
	address = 11'b00010000001;	 
	data =    4'b1011;	 
	mode = 1'b0; //read
	
	#50
	address = 11'b00001111110;	 
	data =    4'b1111;	 
	mode = 1'b1; //read
	
	//
	#50
	address = 11'b00001111110;	 
	data =    4'b1011;	 
	mode = 1'b0; //read
	//
	#50
	address = 11'b00000100000;	 
	data =    4'b1110;	 
	mode = 1'b1; //read
	//
	#50
	address = 11'b00000100000;	 
	data =    4'b1011;	 
	mode = 1'b0; //read
	
	#50
	address = 11'b00100000011;	 
	data =    4'b1011;	 
	mode = 1'b0; //read
	
	#50
	address = 11'b00000000010;	 
	data =    4'b1011;	 
	mode = 1'b0; //read    
	
	/***************************/
	
	/***************************/
/*	#50
	address = 32'b00000000000000001111111010110011;	 
	data =    8'b11110110;	 
	mode = 1'b1; //read
	
	#50
	address = 32'b00000000000000001111111010110011;	 
	data =    8'b11000110;	 
	mode = 1'b0; //read   */
	
	/***************************/
	
/*	#50
	address = 32'b00000000000000000000111100000001;	 
	data =    8'b10110000;	 
	mode = 1'b0; //read
	
	#50
	address = 32'b00000000000000000000111100000010;	
	data =    8'b10110000;	 
	mode = 1'b0; //read
	
	#50
	address = 32'b00000000000000000000111100000011;	 
	data =    8'b10110000;	 
	mode = 1'b0; //read
	
	//3 Main memory genertaing valid address
	#50
	address = 32'b00000000000000000000000000000110;	 
	data =    8'b11000101;	 
	mode = 1'b1; //write
	
	#50
	address = 32'b00000000000000000000000000000110;	 
	data =    8'b11000101;	 
	mode = 1'b0; //write
	
//	#50
//	address = 32'b00000000000000000100000000001110;	 
//	data =    8'b11011111;	 
//	mode = 1'b1; //write
	
	#50
	address = 32'b00000000000000000000000000001110;	 
	data =    8'b11011100;	 
	mode = 1'b0; //read
	
	
	//4 Cache eviction
	#50
	address = 32'b00000000000000000000000000000010;	 
	data =    8'b11001100;	 
	mode = 1'b0; //read
	
	#50
	address = 32'b00000000000000000000000100000001;	 
	data =    8'b11011111;	 
	mode = 1'b0; //read
	
	#50
	address = 32'b00000000000000000000000000000010;	 
	data =    8'b11001100;	 
	mode = 1'b0; //read     */
	
end

//initial
//$monitor("address = %d data = %d mode = %d out = %d", address % 4096, data, mode, out);

always #25 clk = ~clk;
endmodule