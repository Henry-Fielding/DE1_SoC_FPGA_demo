//
// Draw Mif
// ------------------------
// By: Henry Fielding
// For: University of Leeds
// Date: 11th May 2021
//
// Short Description
// -----------------
// This module is designed to draw the content of a ROM file to the display 
// starting at the origin coordinates. pixel data for each sprite is stored sequentially in memory 
// reading left to right then top to bottom. Each address in ROM stores the data for 4 pixels
// in order to minimise the memory footprint of the sprites.
 
module DrawMif #(
	// declare parameters
	parameter CLOCK_FREQ	= 50000000
)(
	// declare ports
	input 			clock,
	input				reset,
	input	[ 7:0]	xOrigin,
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
	output				LT24LCDOn
);

//
// Declare local registers/wires
//
reg	[ 7:0]	xAddrFrame;	// general module variables
reg	[ 8:0]	yAddrFrame;
reg	[ 7:0]	imgHeight;
reg	[ 8:0]	imgWidth;
reg	[ 7:0]	xplus;
reg	[ 8:0]	yplus;
reg	[ 3:0]	square;
reg	[ 7:0]	counter;

reg	[ 7:0]	xAddrLCD;	// LCD connections
reg	[ 8:0]	yAddrLCD;
reg	[15:0]	pixelData;
reg				pixelWrite;
wire				pixelReady;

reg	[15:0]	ROMAddr;		// ROM connections
wire	[15:0]	ROMOut;

//
// Instatiate modules
//
// instantiate LCD
LT24Display #(
	// define parameters
	.WIDTH		(240			),
	.HEIGHT		(320			),
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
// declare statemachine registers and parameters
//
reg	[3:0]	state						= 4'd0;
localparam	IDLE_STATE				= 4'd0;
localparam	READY_STATE				= 4'd1;
localparam 	READ_ROM_STATE			= 4'd2;
localparam	SET_OFFSET_STATE		= 4'd3;
localparam	WRITE_TO_LCD_STATE	= 4'd4;
localparam	INCREMENT_STATE		= 4'd5;

//
// define statemachine behaviour
//
always @(posedge clock or posedge reset) begin
	if (reset) begin
		pixelWrite	<= 1'd0;
		ready			<= 1'd0;
		state			<= IDLE_STATE;
	
	end else begin
		case (state)
			// wait for previous draw signal to end
			IDLE_STATE : begin
				ready	<= 1'd1;
				
				if (!draw) begin
					state	<= READY_STATE;
				end
			end
			
			// set origin coordinates then wait for draw input
			READY_STATE : begin
				ready			<= 1'd1;
				xAddrFrame	<= xOrigin;		// set the initial pixel to the input coordinates
				yAddrFrame	<= yOrigin;
				
				if (draw) begin				// move to read state when draw input recieved
					ready		<= 1'd0;
					ROMAddr	<= 16'd0;
					counter	<= 8'd0;
					state		<= READ_ROM_STATE;
				end
			end
			
			// read colour of the current pixel from the ROM
			READ_ROM_STATE : begin
				counter	<= counter + 1;				// wait for ROM output to update
				if (counter > 1) begin
					counter <= 8'd0;
					
					if (ROMAddr == 0) begin				// read width
						imgWidth		<= ROMOut[8:0];
						ROMAddr		<= 16'd1;
					end else if (ROMAddr == 1) begin // read height
						imgHeight	<= ROMOut[7:0];
						ROMAddr		<= 16'd2;
					end else begin							// read pixel data
						pixelData	<= ROMOut;
						square		<= 4'd1;
						state			<= SET_OFFSET_STATE;
					end
				end
			end
			
			
			// set pixel offset (for doubling image size stored on ROM)
			SET_OFFSET_STATE : begin
				if (square == 1) begin
					yplus	<= 0;
					xplus	<= 0;
				end else if (square == 2) begin
					yplus	<= 1;
					xplus	<= 0;
				end else if (square == 3) begin
					yplus	<= 0;
					xplus	<= 1;
				end else if (square == 4) begin
					yplus	<= 1;
					xplus	<= 1;
				end
				
				state <= WRITE_TO_LCD_STATE;
			end
			
			// write the pixel colour to the LCD
			WRITE_TO_LCD_STATE : begin
				// write pixel data to LCD if not 'empty' (empty cells represented as 16'b1 in ROM)
				if (ROMOut != 16'd1 && (xAddrFrame >= 0 && xAddrFrame <= 239) && (yAddrFrame >= 100 && yAddrFrame <= 419)) begin
					xAddrLCD		<= (xAddrFrame - xplus);			// convert to LCD coordinate frame and add offset pixels
					yAddrLCD		<= (yAddrFrame + yplus - 100);
					pixelWrite	<= 1'd1;
					
					counter <= counter + 1'd1;						// wait for write operation to finish
					if (counter > 1 && pixelReady) begin
						counter <= 8'd0;
						
						pixelWrite	<= 1'd0;
						state			<= INCREMENT_STATE;
					end
					
				// if 'empty' do not write to LCD
				end else begin
					state <= INCREMENT_STATE;
				end
			end
		
			// increment the pixel address
			INCREMENT_STATE : begin
				// if all current 2x2 block is finsihed increment to next
				if (square >= 4) begin
					ROMAddr	<= ROMAddr + 16'd1;
					
					// increment in y if less than width of image
					if	(yAddrFrame < (yOrigin + (imgWidth - 1) - 1)) begin
						yAddrFrame	<= yAddrFrame + 8'd2;
						state			<= READ_ROM_STATE;
					
					// increment x if end of row
					end else if (xAddrFrame > (xOrigin - (imgHeight - 1) + 1)) begin
						xAddrFrame	<= xAddrFrame - 7'd2;
						yAddrFrame	<= yOrigin;
						state			<= READ_ROM_STATE;
					
					// end operation if finished
					end else begin
						state <= IDLE_STATE;
					end
				
				// move to next pixel of current colour if not finished current 2x2 block
				end else begin 
					square	<= square + 4'd1;
					state		<= SET_OFFSET_STATE;
				end
			end
		endcase
	end
end

endmodule


