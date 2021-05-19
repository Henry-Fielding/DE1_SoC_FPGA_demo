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
	input 			clock,		// timing ports
	input				reset,
	input	[ 7:0]	xOrigin,		// general ports
	input	[ 8:0]	yOrigin,
	input	[ 3:0]	ROMId,
	input				draw,
	
	output reg			ready,
	output				LT24Wr_n,	// LT24 Interface
	output				LT24Rd_n,
	output				LT24CS_n,
	output				LT24RS,
	output				LT24Reset_n,
	output	[15:0]	LT24Data,
	output				LT24LCDOn,

	
	output reg	[ 9:0]	LEDs,		// TESTING
	output reg	[ 7:0]	imgHeight,
	output reg	[ 8:0]	imgWidth
	
	
);

//
// Declare local registers/wires
//
reg	[ 7:0]	xAddrLCD;		// LCD connections
reg	[ 8:0]	yAddrLCD;
reg	[ 7:0]	xAddrFrame;		// LCD connections
reg	[ 8:0]	yAddrFrame;
reg	[15:0]	pixelData;
wire				pixelReady;
reg				pixelWrite;

reg	[15:0]	ROMAddr;		// ROM connections
wire	[15:0]	ROMOut;

reg	[ 7:0]	counter;		// general purpose

reg [7:0] xplus = 0;
reg [8:0] yplus = 0;
reg [3:0] square = 1;

//
// Instatiate modules
//
// instantiate LCD
localparam LCD_WIDTH  = 240;		// define LCD parameters
localparam LCD_HEIGHT = 320;

LT24Display #(
	// define parameters
	.WIDTH		(LCD_WIDTH	),
	.HEIGHT		(LCD_HEIGHT	),
	.CLOCK_FREQ	(CLOCK_FREQ	)
) Display (
	// define port connections
	.clock			(clock		),	// clock and reset in
	.globalReset	(reset		),
	.resetApp		(				),	// reset for user logic
	.xAddr			(xAddrLCD	),	// pixel interface
	.yAddr			(yAddrLCD	),
	.pixelData		(pixelData	),
	.pixelWrite		(pixelWrite	),
	.pixelReady		(pixelReady	),
	.pixelRawMode	(1'b0			),	// use pixel addressing mode
	.cmdData			(8'b0			),	// unused command interface
	.cmdWrite		(1'b0			),
	.cmdDone			(1'b0			),
	.cmdReady		(				),
	.LT24Wr_n		(LT24Wr_n	), // display connections
	.LT24Rd_n		(LT24Rd_n	),
	.LT24CS_n		(LT24CS_n	),
	.LT24RS			(LT24RS		),
	.LT24Reset_n	(LT24Reset_n),
	.LT24Data		(LT24Data	),
	.LT24LCDOn		(LT24LCDOn	)
);

// instantiate ROM multiplexer
ReadROMs ROMs (
	// declare ports
	.clock		(clock	),		// timing ports
	.reset		(reset	),
	.ROMId		(ROMId	),		// general ports
	.ROMAddr		(ROMAddr	),
	
	.ReadROMOut	(ROMOut	)
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
localparam	SET_OFFSET_STATE		=	4'd5;
localparam	SET_PIXELDATA_STATE	=	4'd6;
localparam	WAIT_STATE				=	4'd7;
localparam	INCREMENT_STATE		=	4'd8;


always @(posedge clock) begin // TESTING 
	LEDs[9] <= pixelReady;
end

always @(posedge clock or posedge reset) begin
	if (reset) begin
		pixelWrite <= 1'd0;
		ready <= 1'd0;
		square <= 4'd1;
		xplus <= 4'd0;
		yplus <= 4'd0;
		state <= IDLE_STATE;
	
	end else begin
		case (state)
			// wait for previous draw signal to end then move to ready state
			IDLE_STATE : begin				
				LEDs[8:0] = 9'd1; 			// TESTING 
				ready <= 1'd1;
				if (!draw) begin
					state <= READY_STATE;
				end
			end
			
			// wait for draw signal then move to drawing states
			READY_STATE : begin 					
				LEDs[8:0] = 9'd2; 				// TESTING
				ready <= 1'd1;
				xAddrFrame <= xOrigin;					// set the initial pixel to the input coordinates
				yAddrFrame <= yOrigin;
			
				if (draw) begin					// move to read state when draw input recieved
					ready <= 1'd0;
					counter <= 8'd0;
					state <= READ_WIDTH_STATE;
				end
			end
			
			// read sprite width from ROM
			READ_WIDTH_STATE : begin
				LEDs[8:0] = 9'd4; 				// TESTING
				ROMAddr <= 8'd0;					// set ROM adress
				counter <= counter + 1;
				
				if (counter > 2) begin			// wait 2 clock cycles for ROM output to update then read ROM
					imgWidth <= ROMOut[8:0];
					counter <= 8'd0;
					state <= READ_HEIGHT_STATE;
				end
			end
			
			// read sprite height from ROM
			READ_HEIGHT_STATE : begin
				LEDs[8:0] = 9'd8; 				// TESTING
				ROMAddr <= 8'd1;					// set ROM adress
				counter <= counter + 1;			
				
				if (counter > 2) begin			// wait 2 clock cycles for ROM output to update then read ROM
					imgHeight <= ROMOut[7:0];
					ROMAddr <= 8'd2;
					counter <= 8'd0;
					state <= READ_PIXEL_STATE;
				end
			end
			
			
			
			// read colour of the current pixel from the ROM
			READ_PIXEL_STATE : begin
				LEDs[8:0] = 9'd16; 					// TESTING
				counter <= counter + 1;
				
				if (counter > 2) begin				// wait 2 clock cycles for ROM output to update then change state
					pixelData <= ROMOut;
					state <= SET_OFFSET_STATE;
					counter <= 8'd0;
				end
			end
			
			// set pixel offset (for increasing image size)
			SET_OFFSET_STATE : begin
				if (square == 1) begin
					yplus <= 0;
					xplus <= 0;
				end else if (square == 2) begin
					yplus <= 1;
					xplus <= 0;
				end else if (square == 3) begin
					yplus <= 0;
					xplus <= 1;
				end else if (square == 4) begin
					yplus <= 1;
					xplus <= 1;
				end
				
				state <= SET_PIXELDATA_STATE;
			end
			
			// write the pixel colour to the LCD
			SET_PIXELDATA_STATE : begin
				LEDs[8:0] = 9'd32; 					// TESTING
				if (ROMOut != 16'd1 && (xAddrFrame >= 0 && xAddrFrame <= 239) && (yAddrFrame >= 100 && yAddrFrame <= 419)) begin			// write pixel data to LCD if not 'empty' (empty cells represented as 1'b1)
					xAddrLCD <= (xAddrFrame - xplus);
					yAddrLCD <= (yAddrFrame + yplus - 100);
					pixelWrite <= 1'd1;				 
					
					if (!pixelReady) begin			
						state <= WAIT_STATE;
					end
				end else begin							// if 'empty' do not write to LCD
					state <= INCREMENT_STATE;
				end
			end
			
			// Wait for the write operation to finish
			WAIT_STATE : begin
				LEDs[8:0] = 9'd64; 					// TESTING
				if (pixelReady) begin				// wait for write operation to end
					pixelWrite <= 1'd0;
					state <= INCREMENT_STATE;
				end
			end
		
			// increment the pixel address
			INCREMENT_STATE : begin
//			LEDs[8:0] = 9'd128; // TESTING

				if (square > 3) begin
					if	(yAddrFrame < (yOrigin + (imgWidth - 1) - 1)) begin 				// if not at end of row increment x
						yAddrFrame <= yAddrFrame + 8'd2;
						ROMAddr <= ROMAddr + 16'd1;
						state <= READ_PIXEL_STATE;
					end else if (xAddrFrame > (xOrigin - (imgHeight - 1) + 1)) begin	// if end of row is reached reset x, increment y
						xAddrFrame <= xAddrFrame - 7'd2;
						yAddrFrame <= yOrigin;
						ROMAddr <= ROMAddr + 16'd1;
						state <= READ_PIXEL_STATE;
					end else begin															// if fully draw, end operation
						state <= IDLE_STATE;
					end
					square <= 1;
					
				end else begin 
					state <= READ_PIXEL_STATE;
					square <= square + 1;
				end
					
				
				
				
			
//				LEDs[8:0] = 9'd128; // TESTING
//				if	(yAddrFrame < (yOrigin + (imgWidth - 1))) begin 				// if not at end of row increment x
//					yAddrFrame <= yAddrFrame + 8'd1;
//					ROMAddr <= ROMAddr + 16'd1;
//					state <= READ_PIXEL_STATE;
//				end else if (xAddrFrame > (xOrigin - (imgHeight - 1))) begin	// if end of row is reached reset x, increment y
//					xAddrFrame <= xAddrFrame - 7'd1;
//					yAddrFrame <= yOrigin;
//					ROMAddr <= ROMAddr + 16'd1;
//					state <= READ_PIXEL_STATE;
//				end else begin															// if fully draw, end operation
//					state <= IDLE_STATE;
//				end
				
			end
		endcase
	end
end

endmodule


