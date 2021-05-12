/*
 * Draw Mif
 * ------------------------
 * By: Henry Fielding
 * For: University of Leeds
 * Date: 11th May 2021
 *
 * Short Description
 * -----------------
 * This module is designed to draw the content of a mif file to the display at the selected cooridnates
 *
 */
 
module DrawMif #(
	// declare parameters
	parameter CLOCK_FREQ = 50000000
)(
	// declare ports
	input 			clock,
	input				reset,
	input	[ 7:0]	xOrigin,
	input	[ 8:0]	yOrigin,
	input	[ 7:0]	mifId,
		input				draw,
	
	output reg		ready,

	output reg	[9:0]	LEDs,
	
	// LT24 Interface
	output			LT24Wr_n,
	output			LT24Rd_n,
	output			LT24CS_n,
	output			LT24RS,
	output			LT24Reset_n,
	output[15:0]	LT24Data,
	output			LT24LCDOn,
	output reg[7:0]	imgWidth,
	output reg[8:0]	imgHeight
);

//
// Local Variables
//
reg	[7:0]	xAddr;
reg	[8:0]	yAddr;
reg	[15:0]	pixelData;
wire				pixelReady;
reg				pixelWrite;

//reg 	[7:0]	imgWidth;
//reg	[8:0]	imgHeight;
reg	[15:0]	imgAddr;

reg [15:0] ROMAddr;
wire [15:0] ROMOut;

reg [7:0] counter;

// local params
localparam LCD_WIDTH  = 240;
localparam LCD_HEIGHT = 320;




//
// Instatiate modules
//
// instantiate LCD
LT24Display #(
	.WIDTH		(LCD_WIDTH	),
	.HEIGHT		(LCD_HEIGHT	),
	.CLOCK_FREQ	(CLOCK_FREQ	)
) Display (
	//Clock and Reset In
	.clock			(clock		),
	.globalReset	(reset),
	//Reset for User Logic
	.resetApp		(	),
	//Pixel Interface
	.xAddr			(xAddr		),
	.yAddr			(yAddr		),
	.pixelData		(pixelData	),
	.pixelWrite		(pixelWrite	),
	.pixelReady		(pixelReady	),
	//Use pixel addressing mode
	.pixelRawMode	(1'b0			),
	//Unused Command Interface
	.cmdData			(8'b0			),
	.cmdWrite		(1'b0			),
	.cmdDone			(1'b0			),
	.cmdReady		(				),
	//Display Connections
	.LT24Wr_n		(LT24Wr_n	),
	.LT24Rd_n		(LT24Rd_n	),
	.LT24CS_n		(LT24CS_n	),
	.LT24RS			(LT24RS		),
	.LT24Reset_n	(LT24Reset_n),
	.LT24Data		(LT24Data	),
	.LT24LCDOn		(LT24LCDOn	)
);

// instantiate ROM
MarioWalk1	ROM_inst (
	.address ( ROMAddr ),
	.clock ( clock ),
	.q ( ROMOut )
	);

//
// Declare statemachine registers and parameters
//
reg	[3:0]	state;
localparam	IDLE_STATE				=	4'd0;
localparam	READY_STATE				=	4'd1;
localparam	READ_WIDTH_STATE		=	4'd2;
localparam	READ_HEIGHT_STATE		=	4'd3;
localparam	READ_PIXEL_STATE		=	4'd4;
localparam	SET_PIXELDATA_STATE	=	4'd5;
localparam	WAIT_STATE				=	4'd6;
localparam	INCREMENT_STATE		=	4'd7;


always @(posedge clock) begin
	LEDs[9] <= pixelReady;
end

always @(posedge clock or posedge reset) begin
	if (reset) begin
		pixelWrite <= 1'd0;
		ready <= 1'd0;
		state <= IDLE_STATE;
	
	end else begin
		case (state)
			IDLE_STATE : begin // wait for last draw signal to end
				LEDs[8:0] = 9'd1;
				if (!draw) begin
					state <= READY_STATE;
				end
			end
			
			READY_STATE : begin // wait for new draw command
				LEDs[8:0] = 9'd2;
				ready <= 1'd1;
				xAddr <= xOrigin;
				yAddr <= yOrigin;
			
				if (draw) begin
					ready <= 1'd0;
					counter <= 8'd0;
					state <= READ_WIDTH_STATE;
				end
			end
			
			READ_WIDTH_STATE : begin
				LEDs[8:0] = 9'd4;
				ROMAddr <= 8'd0;
				counter <= counter + 1;
				
				if (counter > 2) begin
					imgWidth <= ROMOut[7:0];
					counter <= 8'd0;
					state <= READ_HEIGHT_STATE;
				end
			end
			
			READ_HEIGHT_STATE : begin
				LEDs[8:0] = 9'd8;
				ROMAddr <= 8'd1;
				counter <= counter + 1;
				
				if (counter > 2) begin
					imgHeight <= ROMOut[8:0];
					ROMAddr <= 8'd2;
					counter <= 8'd0;
					state <= READ_PIXEL_STATE;
				end
			end
			
			READ_PIXEL_STATE : begin
				LEDs[8:0] = 9'd16;
				counter <= counter + 1;
				
				if (counter > 2) begin
					state <= SET_PIXELDATA_STATE;
					counter <= 8'd0;
				end
			end
			
			SET_PIXELDATA_STATE : begin // set current pixel
				LEDs[8:0] = 9'd32;
				if (ROMOut != 16'd1) begin
					pixelData <= ROMOut;
					pixelWrite <= 1'd1;
					
					if (!pixelReady) begin
						state <= WAIT_STATE;
					end
				end else begin
					state <= INCREMENT_STATE;
				end
			end
			
			WAIT_STATE : begin // wait for lcd to finish writing
				LEDs[8:0] = 9'd64;
				if (pixelReady) begin
					pixelWrite <= 1'd0;
					state <= INCREMENT_STATE;
				end
			end
			
			INCREMENT_STATE : begin // increment pixel
				LEDs[8:0] = 9'd128;
				if	(xAddr < (xOrigin + (imgWidth - 1))) begin 				// if not at end of row increment x
					xAddr <= xAddr + 7'd1;
					ROMAddr <= ROMAddr + 16'd1;
					state <= READ_PIXEL_STATE;
				end else if (yAddr < (yOrigin + (imgHeight - 1))) begin	// if at end of row reset x, increment y
					yAddr <= yAddr + 8'd1;
					xAddr <= xOrigin;
					ROMAddr <= ROMAddr + 16'd1;
					state <= READ_PIXEL_STATE;
				end else begin													// if at end of square move to idle
					state <= IDLE_STATE;
				end
				
			end
		endcase
	end
end


endmodule


