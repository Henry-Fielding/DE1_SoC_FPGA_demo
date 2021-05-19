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
	
	output		[9:0]	LEDs,
	output reg  [6:0] display0,
	output reg  [6:0] display1,
	output reg  [6:0] display2,
	output reg  [6:0] display3,
	output reg  [6:0] display4,
	output reg  [6:0] display5

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

reg updateSprite;
wire [3:0] spriteId;
wire [7:0] xSprite;
wire [8:0] ySprite;


reg updateCollision;

reg  [8:0] yFloor = 9'd100;
reg [3:0] layer = 4'b0;
reg refreshScreen = 1'b0;
reg clockhold = 1'b0;

reg [7:0] count = 8'd0;



//reg [3:0] speed = 4'd8;

wire collision;
reg collisionHold;

reg [1:0] lives = 3;

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
	.update		(updateSprite),	// timing ports
	.reset		(reset		),		// TEST (maybe remove)
	.keys			(keys			),		// general ports
	
	.xSprite		(xSprite 	),
	.ySprite		(ySprite		),
	.spriteId	(spriteId	)
);

reg obstacleUpdate;
reg [3:0] randomSeed;
wire [ 7:0] xObstacle;
wire [ 8:0]	yObstacle;
wire passed;
wire [ 3:0] obstacleId;

UpdateObstacle Obstacle (
	//define port connections
	.update		(obstacleUpdate),	// timing ports
	.reset		(reset		),		// TEST (maybe remove)
	.speed		(speed		),
	.randomSeed	(randomSeed ),
	
	.xSprite		(xObstacle 	),
	.ySprite		(yObstacle	),
	.obstacleId	(obstacleId	),					// unused
	.passed		(passed		)
);

CheckCollisions #(
	// define parameters
	.X1_BITWIDTH	(8		),
	.Y1_BITWIDTH	(9		),
	.X2_BITWIDTH	(8		),
	.Y2_BITWIDTH	(9		)
) Collisions (
	// declare ports
	.update		(updateCollision	),	// timing ports
	.reset		(reset				),
	.x1			(xSprite				),
	.y1			(ySprite				),
	.x2			(xObstacle			),
	.y2			(yObstacle			),
	.spriteId	(spriteId			),

	.collision	(collision)
);

reg updateScore;
wire readyScore;
wire [23:0] display;

UpdateScore #(
	.SCORE_DIGITS (3)
) Score (
	// declare ports
	.clock	(clock),// timing ports
	.reset	(reset),
	.enable 	(updateScore),
	
	.ready 	(readyScore ),
	.display (display) // not connecting porperly for some reason
);


reg updateLives;
wire readyLives;
wire gameOver;

UpdateLives #(
	.MAX_LIVES (3)
) Lives (
	// declare ports
	.clock	(clock),// timing ports
	.reset	(reset),
	.enable 	(updateLives),

	.ready 	(readyLives ),
	.gameOver(gameOver	),
	.LEDs		(LEDs			)
);

//
//	state machine top level
//

//reg [3:0] stateTopLevel;
reg [4:0] loop;


//
// stateGameLoop machine registers
//

reg	[3:0]	stateGameLoop;
localparam	IDLE_STATE					= 4'd0;
localparam	UPDATE_SPRITES_STATE		= 4'd1;
localparam	CHECK_COLLISIONS_STATE	= 4'd2;
localparam	UPDATE_LIVES_STATE		= 4'd3;
localparam	UPDATE_SCORE_STATE		= 4'd4;
localparam	DRAW_BACKGROUND_STATE	= 4'd5;
localparam	DRAW_FLOOR_STATE			= 4'd6;
localparam	DRAW_SPRITE_STATE			= 4'd7;
localparam	DRAW_OBSTACLE_STATE		= 4'd8;
localparam	GAME_OVER_STATE			= 4'd9;
localparam	TEST_STATE					= 4'd10;

always @ (posedge clock) begin
	//LEDs[9:7] <= stateGameLoop;
	
	//LEDs[2:0] <= (3'b1 << (lives - 1));
	
	display0 <= ~display[6:0];
	display1 <= ~display[14:8];
	display2 <= ~display[22:16];
	display3 <= ~7'b1010000;
	display4 <= ~7'b1011000;
	display5 <= ~7'b1101101;
end

always @ (posedge clock or posedge reset) begin // add reset condition
	if (reset) begin
		clockhold <= clock10hz;
		updateSprite <= 1'd0;
		updateScore <= 1'd0;
		updateLives <= 1'd0;
		draw <= 1'd0;
		collisionHold <= 1'd0;
		count <= 8'd0;
		lives <= 1'd0;
		// add all importat game regs
		stateGameLoop <= IDLE_STATE;
	
	end else begin
		case (stateGameLoop)
			// start game loop at the posedge of the 10hz clock
			IDLE_STATE : begin
				if (clock10hz && (clock10hz != clockhold)) begin
					stateGameLoop <= UPDATE_SPRITES_STATE;
					count <= 8'd0;
				end
				clockhold <= clock10hz;
			end
			
			
//			TEST_STATE : begin
//				xOrigin <= 64;
//				yOrigin <= 100;
//				ROMId <= 4'd0;
//				draw <= 1'd1;
//				count <= count + 8'd1;
//				if(count > 8'd20 && ready) begin
//					draw <= 1'd0;
//					count <= 8'd0;
//					stateGameLoop <= IDLE_STATE;
//				end
//			end
			
			// update player and obstacle sprites
			UPDATE_SPRITES_STATE : begin
				updateSprite <= 1'd1;		// signal modules to update
				obstacleUpdate <= 1'd1;
				
				count <= count + 8'd1;		// wait 20 clock cycles for modules to update
				if (count > 8'd20) begin
					count <= 8'd0;
					
					updateSprite <= 1'd0;	//	turn off update signals
					obstacleUpdate <= 1'd0;
					
					if (passed) begin
						stateGameLoop <= UPDATE_SCORE_STATE;
					end else begin
						stateGameLoop <= CHECK_COLLISIONS_STATE;
					end
				end
			end
			
			// check for collision between player sprite and obstacle sprite
			CHECK_COLLISIONS_STATE : begin
				updateCollision <= 1'd1;		// signal module to update
				
				count <= count + 8'd1;			// wait 20 clock cycles for modules to update
				if (count > 8'd20) begin
					count <= 8'd0;
					
					updateCollision <= 1'd0;	//	turn off update signals
					
					if (collision && !collisionHold) begin
						collisionHold <= 1;
						stateGameLoop <= UPDATE_LIVES_STATE;
					end else begin
						stateGameLoop <= DRAW_BACKGROUND_STATE;
					end
				end
			end
			
			// update players lives and check for gameover
			UPDATE_LIVES_STATE : begin
				updateLives <= 1'd1;
				
				count <= count + 8'd1;						// wait 20 clock cycles for modules to update
				if (count > 8'd20 && readyLives) begin
					count <= 8'd0;
					
					updateLives <= 1'd0;
					
					if (gameOver) begin
						stateGameLoop <= GAME_OVER_STATE;
					end else begin
						stateGameLoop <= DRAW_BACKGROUND_STATE;
					end
				end
			end
			
			// update the players score 
			UPDATE_SCORE_STATE : begin
				if (!collisionHold) begin
					updateScore <= 1'd1;
					
					count <= count + 8'd1;
					if (count > 8'd20 && readyLives) begin
						count <= 8'd0;
						
						updateScore <= 1'd0;
						stateGameLoop <= DRAW_BACKGROUND_STATE;
					end
					
				end else begin
					collisionHold <= 1'd0;
					stateGameLoop <= DRAW_BACKGROUND_STATE;
				end
			end
			
			DRAW_BACKGROUND_STATE : begin
//				stateGameLoop <= DRAW_FLOOR_STATE;
//				loop <= 0;
//			
				xOrigin <= 239;
				yOrigin <= 100;
				ROMId <= 4'd11;
				draw <= 1'd1;
				count <= count + 8'd1;
				if(count > 8'd20 && ready) begin
					draw <= 1'd0;
					count <= 8'd0;
					stateGameLoop <= DRAW_FLOOR_STATE;
				end
			end
			
			DRAW_FLOOR_STATE : begin
				
				if (loop < 11) begin
					xOrigin <= 8'd31;
					yOrigin <= yFloor + (32 * loop);
					ROMId <= 4'd5;
					draw <= 1'd1;
					count <= count + 8'd1;
					if(count > 8'd20 && ready) begin
						count <= 8'd0;
					
						draw <= 1'd0;
						loop <= loop + 1;
						stateGameLoop <= DRAW_FLOOR_STATE;
					end
				end else begin
					loop <= 0;
					yFloor <= yFloor - speed;
					if(yFloor <= 68 + speed) begin
						yFloor <= 100;
					end
					stateGameLoop <= DRAW_SPRITE_STATE;
				end 
			
			
//				xOrigin <= 8'd31;
//				yOrigin <= yFloor + (32 * loop);
//				ROMId <= 4'd5;
//				draw <= 1'd1;
//				count <= count + 8'd1;
//				if(count > 8'd20 && ready) begin
//					draw <= 1'd0;
//					yFloor <= yFloor - speed;
//					if(yFloor <= 68 + speed) begin
//						yFloor <= 100;
//					end
//					
//					
//					
//					stateGameLoop <= DRAW_SPRITE_STATE;
//					count <= 8'd0;
//				end
//			
			end
			
			DRAW_SPRITE_STATE : begin
				xOrigin <= xSprite;
				yOrigin <= ySprite;
				ROMId <= spriteId;
				draw <= 1'd1;
				count <= count + 8'd1;
				if(count > 8'd20 && ready) begin
					draw <= 1'd0;
					count <= 8'd0;
					stateGameLoop <= DRAW_OBSTACLE_STATE;
				end
			end
			
			DRAW_OBSTACLE_STATE : begin
				xOrigin <= xObstacle;
				yOrigin <= yObstacle;
				ROMId <= obstacleId;
				draw <= 1'd1;
				count <= count + 8'd1;
				if(count > 8'd20 && ready) begin
					draw <= 1'd0;
					count <= 8'd0;
					stateGameLoop <= IDLE_STATE;
				end
			end
			
			GAME_OVER_STATE : begin
//				xOrigin <= 239;
//				yOrigin <= 0;
//				ROMId <= 4'd10;
//				draw <= 1'd1;
//				count <= count + 8'd1;
//				if(count > 8'd20 && ready) begin
//					draw <= 1'd0;
//					count <= 8'd0;
//				end
//				
//				xOrigin <= 119;
//				yOrigin <= 0;
//				ROMId <= 4'd11;
//				draw <= 1'd1;
//				count <= count + 8'd1;
//				if(count > 8'd20 && ready) begin
//					draw <= 1'd0;
//					count <= 8'd0;
//				end
			end
			
		endcase
	end
end








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