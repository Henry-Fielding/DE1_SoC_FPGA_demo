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
	input [3:0]	speed,
	
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
reg	[ 8:0]	yOrigin = 9'd119;
reg	[ 3:0]	ROMId = 4'd1;
//reg	[ 7:0]	width  = 8'd20;
//reg	[ 8:0]	height = 9'd20;
//reg	[15:0]	pixelData = 16'hF800;

wire				ready;

reg spriteUpdate;
wire [3:0] spriteId;
wire [7:0] xSprite;
wire [8:0] ySprite;

reg obstacleUpdate;
wire [ 7:0] xObstacle;
wire [ 8:0]	yObstacle; 

reg collisionUpdate;

reg  [8:0] yFloor = 9'd100;
reg [3:0] layer = 4'b0;
reg refreshScreen = 1'b0;
reg clockhold = 1'b0;

reg [7:0] count = 8'd0;

reg updateScore;
wire readyScore;
wire [23:0] totalScore;
wire score;

//reg [3:0] speed = 4'd8;

wire temp;


//
// Instatiate  modules
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
	.reset		(reset		),		// TEST (maybe remove)
	.keys			(keys			),		// general ports
	
	.xSprite		(xSprite 	),
	.ySprite		(ySprite		),
	.spriteId	(spriteId	)
);

UpdateObstacle Obstacle (
	//define port connections
	.update		(obstacleUpdate),	// timing ports
	.reset		(reset		),		// TEST (maybe remove)
	.speed		(speed		),
	
	.xSprite		(xObstacle 	),
	.ySprite		(yObstacle	),
	.spriteId	(	),					// unused
	.score		(score		)
);

CheckCollisions #(
	// define parameters
	.X1_BITWIDTH	(8		),
	.Y1_BITWIDTH	(9		),
	.X2_BITWIDTH	(8		),
	.Y2_BITWIDTH	(9		),
	.WIDTH_1			(32	),
	.HEIGHT_1		(64	),
	.WIDTH_2			(32	),
	.HEIGHT_2		(64	)
) Collisions (
	// declare ports
	.update		(collisionUpdate	),	// timing ports
	.reset		(reset				),
	.x1			(xSprite				),
	.y1			(ySprite				),
	.x2			(xObstacle			),
	.y2			(yObstacle			),

	.collision	(temp)
);

UpdateScore #(
	.SCORE_BITWIDTH (24)
) Score (
	// declare ports
	.clock	(clock),// timing ports
	.reset	(reset),
	.update (updateScore),
	.score (score),
	
	.ready (readyScore ),
	.totalScoreOutput (totalScore) // not connecting porperly for some reason
);


//
// state machine registers
//

reg	[3:0]	state;
localparam	IDLE_STATE	=	4'd0;
localparam	UPDATE_SPRITE_STATE	=	4'd1;
localparam	UPDATE_OBSTACLE_STATE	=	4'd2;
localparam	UPDATE_COLLISION_STATE	=	4'd3;
localparam	UPDATE_SCORE_STATE	=	4'd4;
localparam	DRAW_BACKGROUND_STATE	=	4'd5;
localparam	DRAW_FLOOR_STATE = 4'd6;
localparam	DRAW_SPRITE_STATE	=	4'd7;
localparam	DRAW_OBSTACLE_STATE	=	4'd8;

always @ (posedge clock) begin
	LEDs[9] <= temp;
	LEDs[8] <= score;
	LEDs[7:0] <= totalScore[7:0];
end

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
//				LEDs[8:0] <= 9'd1;	// testing
				if (clock10hz && (clock10hz != clockhold)) begin
					state <= UPDATE_SPRITE_STATE;
					count <= 8'd0;
				end
				clockhold <= clock10hz;
			end
			
			UPDATE_SPRITE_STATE : begin
//				LEDs[8:0] <= 9'd2;		//testing
				spriteUpdate <= 1'd1;
				count <= count + 8'd1;
				
				if (count > 8'd20) begin // TEST, add ready state instead?
					spriteUpdate <= 1'd0;
					count <= 8'd0;
					state <= UPDATE_OBSTACLE_STATE;
				end
			end
			
			UPDATE_OBSTACLE_STATE : begin
//				LEDs[8:0] <= 9'd3;		//testing
				obstacleUpdate <= 1'd1;
				count <= count + 8'd1;
				
				if (count > 8'd20) begin // TEST, add ready state instead?
					obstacleUpdate <= 1'd0;
					count <= 8'd0;
					state <= UPDATE_COLLISION_STATE;
				end
			
			end
			
			UPDATE_COLLISION_STATE : begin
//				LEDs[8:0] <= 9'd4;		//testing
				collisionUpdate <= 1'd1;
				count <= count + 8'd1;
				
				if (count > 8'd20) begin // TEST, add ready state instead?
					collisionUpdate <= 1'd0;
					count <= 8'd0;
					state <= UPDATE_SCORE_STATE;
				end
			
			end 
			
			UPDATE_SCORE_STATE : begin
//				LEDs[8:0] <= 9'd8;		//testing
				updateScore <= 1'd1;
				count <= count + 8'd1;
				
				if (count > 8'd20 && readyScore) begin // TEST, add ready state instead?
					updateScore <= 1'd0;
					count <= 8'd0;
					state <= DRAW_BACKGROUND_STATE;
				end
			
			end
			
			DRAW_BACKGROUND_STATE : begin
//				LEDs[8:0] <= 9'd16;		//testing
				xOrigin <= 239;
				yOrigin <= 100;
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
//				LEDs[8:0] <= 9'd32;		//testing
				xOrigin <= 8'd31;
				yOrigin <= yFloor;
				ROMId <= 4'd5;
				draw <= 1'd1;
				count <= count + 8'd1;
				if(count > 8'd20 && ready) begin
					draw <= 1'd0;
					yFloor <= yFloor - speed;
					if(yFloor <= 68 + speed) begin
						yFloor <= 100;
					end
					state <= DRAW_SPRITE_STATE;
					count <= 8'd0;
				end
			
			end
			
			DRAW_SPRITE_STATE : begin
//				LEDs[8:0] <= 9'd64;		//testing
				xOrigin <= xSprite;
				yOrigin <= ySprite;
				ROMId <= spriteId;
				draw <= 1'd1;
				count <= count + 8'd1;
				if(count > 8'd20 && ready) begin
					draw <= 1'd0;
					count <= 8'd0;
					state <= DRAW_OBSTACLE_STATE;
				end
			end
			
			DRAW_OBSTACLE_STATE : begin
//				LEDs[8:0] <= 9'd128;		//testing
				xOrigin <= xObstacle;
				yOrigin <= yObstacle;
				ROMId <= 4'd6;
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