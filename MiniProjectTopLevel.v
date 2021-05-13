/*
 * Mini-project Top level
 * ------------------------
 * By: Henry Fielding
 * For: University of Leeds
 * Date: 11th May 2021
 *
 * Short Description
 * -----------------
 * This module is designed to designed to demonstrate the FPGA skills
 * developed throughout this module.
 *
 */
 
module MiniProjectTopLevel (
	input clock,
	input reset,
	
	input [3:0] keys,
	
	output				LT24Wr_n,
	output				LT24Rd_n,
	output				LT24CS_n,
	output				LT24RS,
	output				LT24Reset_n,
	output	[15:0]	LT24Data,
	output				LT24LCDOn,
	
	output reg	[9:0]	LEDs

);

//
// Local Variables
//
reg				draw = 1'b0;
reg	[ 7:0]	xOrigin = 8'd100;
reg	[ 8:0]	yOrigin = 9'd20;
reg	[ 3:0]	ROMId = 8'd1;
//reg	[ 7:0]	width  = 8'd20;
//reg	[ 8:0]	height = 9'd20;
//reg	[15:0]	pixelData = 16'hF800;

wire				ready;
wire [3:0] spriteId;
wire [7:0] xSprite;
wire [8:0] ySprite;
reg  [8:0] yFloor = 9'd0;
reg [3:0] layer = 4'b0;
reg refreshScreen = 1'b0;
reg clockhold = 1'b0;

reg [7:0] count = 8'd0;

reg spriteUpdate;

//
// Instatiate  module
//
DrawMif #(
	// declare parameters
	.CLOCK_FREQ (50000000 	)//fix
) Square1 (
	// declare ports
	.clock		(clock		),
	.reset		(reset		),
	.draw			(draw			),
	.xOrigin		(xOrigin		),
	.yOrigin		(yOrigin		),
	.ROMId		(ROMId),
	
	.ready		(ready		),
	
	.LEDs			(	),
	
	// LT24 Interface
	.LT24Wr_n	(LT24Wr_n	),
	.LT24Rd_n	(LT24Rd_n	),
	.LT24CS_n	(LT24CS_n	),
	.LT24RS		(LT24RS		),
	.LT24Reset_n(LT24Reset_n),
	.LT24Data	(LT24Data	),
	.LT24LCDOn	(LT24LCDOn	)
);

UpdateSprite Sprite (
	//define port connections
	.update		(spriteUpdate),	// timing ports
	.reset		(reset		),	//TEST (maybe remove)
	.keys			(keys			),	// general ports
	
	.xSprite		(xSprite 	),
	.ySprite		(ySprite		),
	.spriteId	(spriteId	)
);

//
// state machine registers
//

reg	[3:0]	state;
localparam	IDLE_STATE	=	4'd0;
localparam	UPDATE_SPRITE_STATE	=	4'd1;
localparam	DRAW_BACKGROUND_STATE	=	4'd2;
localparam	DRAW_FLOOR_STATE = 4'd3;
localparam	DRAW_SPRITE_STATE	=	4'd4;



always @ (posedge clock or posedge reset) begin // add reset condition
	if (reset) begin
		clockhold <= clock10hz;
		spriteUpdate <= 1'd0;
		draw <= 1'd0;
		count <= 8'd0;
		state <= IDLE_STATE;
	
	end else begin
		case (state)
			IDLE_STATE : begin
				LEDs <= 10'd1;	// testing
				if (clock10hz && (clock10hz != clockhold)) begin
					state <= UPDATE_SPRITE_STATE;
					count <= 8'd0;
				end
				clockhold <= clock10hz;
			end
			
			UPDATE_SPRITE_STATE : begin
				LEDs <= 10'd2;	//testing
				spriteUpdate <= 1'd1;
				count <= count + 8'd1;
				
				if (count > 8'd20) begin // TEST, add ready state instead?
					spriteUpdate <= 1'd0;
					count <= 8'd0;
					state <= DRAW_BACKGROUND_STATE;
				end
			end
			
			DRAW_BACKGROUND_STATE : begin
				LEDs <= 10'd4;	//testing
				xOrigin <= xSprite;
				yOrigin <= ySprite;
				ROMId <= 4'd15;
				draw <= 1'd1;
				count <= count + 8'd1;
				if(count > 8'd20 && ready) begin
					draw <= 1'd0;
					count <= 8'd0;
					state <= DRAW_FLOOR_STATE;
				end
				
			end
			
			DRAW_FLOOR_STATE : begin
				LEDs <= 10'd8;	//testing
				xOrigin <= 8'd63;
				yOrigin <= yFloor;
				ROMId <= 4'd5;
				draw <= 1'd1;
				count <= count + 8'd1;
				if(count > 8'd20 && ready) begin
					draw <= 1'd0;
					count <= 8'd0;
					if (yFloor > 9'd320) begin
						yFloor <= 9'd0;
						state <= DRAW_SPRITE_STATE;
					end else begin
						yFloor <= yFloor + 9'd32;
						state <= DRAW_FLOOR_STATE;
					end
				end
			
			end
			
			DRAW_SPRITE_STATE : begin
				LEDs <= 10'd16;	//testing
				xOrigin <= xSprite;
				yOrigin <= ySprite;
				ROMId <= spriteId;
				draw <= 1'd1;
				count <= count + 8'd1;
				if(count > 8'd20 && ready) begin
					draw <= 1'd0;
					count <= 8'd0;
					state <= IDLE_STATE;
				end
			end
		endcase
	end
end


//always @ (posedge clock) begin
//	if (clock10hz && (clock10hz != clockhold)) begin
//		refreshScreen <= 1'b1;
//	end
//	clockhold <= clock10hz;
//	
//	if (draw) begin
//		draw <= 1'b0;
//	end else if (refreshScreen) begin
//		if ((layer == 0) && ready) begin				// draw
//			// draw background
//			ROMId = 4'd3;
//			draw = 1'b1;
//			
//			layer <= layer + 1'b1;
//		end else if ((layer == 1) && ready) begin
//			// draw player sprite
//			ROMId = spriteId;
//			draw = 1'b1;
//			
//			
//			layer <= layer + 1'b1;
//		end else if (layer > 1) begin
//			refreshScreen <= 1'b0;
//			layer <= 4'b0;
//		end
//		
//	end 
//end


// update position

//always @ (posedge clock10hz) begin
//	if (spriteId < 2) begin
//		spriteId <= spriteId + 1;
//	end else begin
//		spriteId <= 0;
//	end
//end

reg clock10hz = 0;
reg [31:0] clockcounter = 0;

// clock divider 
always @ (posedge clock) begin
		clockcounter <= clockcounter + 32'd1;
		if (clockcounter >= 32'd2500000) begin
			clock10hz <= !clock10hz;
			clockcounter <= 32'd0;
		end
end



endmodule 