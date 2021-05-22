//
// Mini-project Top level
// ------------------------
// By: Henry Fielding
// For: University of Leeds
// Date: 11th May 2021
//
// Short Description
// -----------------
// This module is designed to designed to demonstrate the FPGA skills
// developed throughout this module. Using a combination of statemachines and 
// modules programmes a game.
 
module MiniProjectTopLevel (
	input				clock,
	input				resetHardware,
	input	[ 3:0]	keys,
	input	[ 3:0]	switches,
	
	output	[ 9:0]	LEDs,
	output	[ 6:0]	display0,
	output	[ 6:0]	display1,
	output	[ 6:0]	display2,
	output	[ 6:0]	display3,
	output	[ 6:0]	display4,
	output	[ 6:0]	display5,
	output				LT24Wr_n,	// lcd module
	output				LT24Rd_n,
	output				LT24CS_n,
	output				LT24RS,
	output				LT24Reset_n,
	output	[15:0]	LT24Data,
	output				LT24LCDOn
);

//
// declare local registers/wires
//
reg	clock10hz;						// 10hz clock
reg	[31:0] clockcounter;
reg	clockhold;

reg				updateLCD;			// LCD connections
reg	[ 7:0]	xOrigin;
reg	[ 8:0]	yOrigin;
reg	[ 3:0]	ROMId;
wire				readyLCD;

reg 			updateSprite;			// updates sprite connections
wire [ 7:0]	xSprite;
wire [ 8:0]	ySprite;
wire [ 3:0]	spriteId;

reg				obstacleUpdate;	// update obstacles connections
wire	[ 7:0]	xObstacle;
wire	[ 8:0]	yObstacle;
wire	[ 3:0]	obstacleId;
wire				passed;

reg	updateCollision;				// check collisions connections
wire	collision;
reg	collisionHold;

reg	updateScore;					// update score connections
wire	readyScore;
wire	[23:0] display;
wire	gameOver;

reg	updateLives;					// update lives connections
wire	readyLives;

wire	reset;							// general purpose module variables
reg	resetSoftware;
reg	[ 7:0]	count;
reg	[ 3:0]	randomSeed;
wire	[ 7:0]	gameSpeed; 
reg	[ 8:0]	yFloor;
reg	[ 3:0]	loop;
reg	key0hold;


//
// Instatiate  modules
//
// draw mifs module - this module draws the chosen sprite to the LCD 
// based on the x and y positions and the ROMId
DrawMif #(
	// declare parameters
	.CLOCK_FREQ (50000000 	)
) LCDInterface (
	// define port connections
	.clock		(clock		),
	.reset		(reset		),
	.draw			(updateLCD	),
	.xOrigin		(xOrigin		),
	.yOrigin		(yOrigin		),
	.ROMId		(ROMId		),
	
	.ready		(readyLCD	),
	.LT24Wr_n	(LT24Wr_n	),
	.LT24Rd_n	(LT24Rd_n	),
	.LT24CS_n	(LT24CS_n	),
	.LT24RS		(LT24RS		),
	.LT24Reset_n(LT24Reset_n),
	.LT24Data	(LT24Data	),
	.LT24LCDOn	(LT24LCDOn	)
);

// update sprite - this module updates the position and 
// animation of the players sprite based on the current user inputs
UpdateSprite Sprite (
	//define port connections
	.update		(updateSprite	),
	.reset		(reset			),
	.keys			(keys				),
	
	.xSprite		(xSprite 	),
	.ySprite		(ySprite		),
	.IdSprite	(spriteId	)
);

// update obstacle - this module updates the position and animation
// of the obstacle based on the game progress. passed goes high when the 
// obstacle has passed the player sprite.
UpdateObstacle Obstacle (
	//define port connections
	.update		(obstacleUpdate),
	.reset		(reset			),
	.gameSpeed	(gameSpeed		),
	.randomSeed	(randomSeed 	),
	
	.xObstacle	(xObstacle 	),
	.yObstacle	(yObstacle	),
	.IdObstacle	(obstacleId	),
	.passed		(passed		)
);

// check collisions - this module uses the current player sprite position
// and the current obstacle sprite position to determine if sprites overlap
// collisions goes high if collision occurs.
CheckCollisions #(
	// define parameters
	.X_BITWIDTH	(8	),
	.Y_BITWIDTH	(9	)
) Collisions (
	// define port connections
	.update		(updateCollision	),
	.reset		(reset				),
	.xSprite		(xSprite				),
	.ySprite		(ySprite				),
	.IdSprite	(spriteId			),
	.xObstacle	(xObstacle			),
	.yObstacle	(yObstacle			),
	.IdObstacle	(obstacleId			),

	.collision	(collision	)
);

// update scores - this module increments the score on the posedge of the
// enable bit and returns the score for display on the 7 seg LCD displays.
// ready bit goes high when operation is completed
UpdateScoreNDigit #(
	// define parameters
	.SCORE_DIGITS	(3	)
) Score (
	// define port connections
	.clock	(clock		),
	.reset	(reset		),
	.enable	(updateScore),
	
	.ready	(readyScore	),
	.display	(display		)
);

// update lives - this module decrements the player lives on the posedge of 
// the enable bit and returns the new lives value for display on the LEDs, 
// gameover goes high when lives = 0 and ready goes high when the operation
// is completed.
UpdateLivesNLives #(
	//define parameters
	.MAX_LIVES	(3	)
) Lives (
	// define port connections
	.clock	(clock		),
	.reset	(reset		),
	.enable	(updateLives),

	.ready	(readyLives ),
	.gameOver(gameOver	),
	.LEDs		(LEDs			)
);

//
// define basic module logic
//
assign reset		= resetSoftware || resetHardware;
assign gameSpeed	= 8'd8 + {{(4){1'd0}},switches[3:0]};
assign display0	= ~display[6:0];
assign display1	= ~display[14:8];
assign display2	= ~display[22:16];
assign display3	= ~7'b1010000;
assign display4	= ~7'b1011000;
assign display5	= ~7'b1101101;

//
// declare statemachine registers and statenames
//
// top level statemachine
reg	[3:0] stateTopLevel		= 4'd0;	
localparam WAIT_TOPLEVEL		= 4'd0;
localparam INTRO_TOPLEVEL		= 4'd1;
localparam GAMELOOP_TOPLEVEL	= 4'd2;
localparam GAMEOVER_TOPLEVEL	= 4'd3;
localparam RESET_TOPLEVEL		= 4'd4;

// game intro statemachine
reg [3:0] stateIntro					= 4'd0;
localparam DRAW_BACKGROUND_INTRO	= 4'd0;
localparam DRAW_FLOOR_INTRO		= 4'd1;
localparam DRAW_TITLE_INTRO		= 4'd2;
localparam WAIT_INTRO				= 4'd3;
localparam START_GAME_INTRO		= 4'd4;

// main gameplay loop statemachine
reg	[3:0]	stateGameLoop					= 4'd0;
localparam	IDLE_GAMELOOP					= 4'd0;
localparam	UPDATE_SPRITES_GAMELOOP		= 4'd1;
localparam	CHECK_COLLISIONS_GAMELOOP	= 4'd2;
localparam	UPDATE_LIVES_GAMELOOP		= 4'd3;
localparam	UPDATE_SCORE_GAMELOOP		= 4'd4;
localparam	DRAW_BACKGROUND_GAMELOOP	= 4'd5;
localparam	DRAW_FLOOR_GAMELOOP			= 4'd6;
localparam	DRAW_SPRITE_GAMELOOP			= 4'd7;
localparam	DRAW_OBSTACLE_GAMELOOP		= 4'd8;
localparam	GAMEOVER_GAMELOOP				= 4'd9;

//
// define toplevel statemachine behaviour
//
always @ (posedge clock or posedge resetHardware) begin
	if (resetHardware) begin
		clockhold <= clock10hz;
		key0hold <= keys[0];
		updateSprite	<= 1'd0;
		updateScore		<= 1'd0;
		updateLives		<= 1'd0;
		updateLCD		<= 1'd0;
		collisionHold	<= 1'd0;
		count				<= 8'd0;
		
		stateTopLevel <= WAIT_TOPLEVEL;
		stateGameLoop <= IDLE_GAMELOOP;
		stateIntro <= DRAW_BACKGROUND_INTRO;
	end else begin
		case (stateTopLevel)
			// wait for all modules to be ready
			WAIT_TOPLEVEL : begin
				if (readyLCD && readyScore && readyLives) begin
					stateTopLevel <= INTRO_TOPLEVEL;
				end
			end
			
			// run intro statemachine
			INTRO_TOPLEVEL : begin
				intro_substatemachine();
				if (stateIntro == START_GAME_INTRO) begin
					stateTopLevel <= GAMELOOP_TOPLEVEL;
				end
			end
			
			// run gameloop statemachine
			GAMELOOP_TOPLEVEL : begin
				gameloop_substatemachine();
				if (stateGameLoop == GAMEOVER_GAMELOOP) begin
					count <= 8'd0;
					stateTopLevel <= GAMEOVER_TOPLEVEL;
				end
			end
			
			// display gameover screen
			GAMEOVER_TOPLEVEL : begin
				draw_image(8'd147, 9'd119, 4'd10, finishedDraw);
				if (finishedDraw) begin
					if (!key0hold && keys[0]) begin
						stateTopLevel <= RESET_TOPLEVEL;
					end
					key0hold <= keys[0];
				end
			end
			
			// reset the game and return to gameloop
			RESET_TOPLEVEL : begin
				resetSoftware 	<= 1'd1;
				clockhold		<= clock10hz;
				key0hold			<= keys[0];
				updateSprite	<= 1'd0;
				updateScore		<= 1'd0;
				updateLives		<= 1'd0;
				updateLCD		<= 1'd0;
				collisionHold	<= 1'd0;
				
				count <= count + 8'd1;		// wait 20 clock cycles for modules to update
				if(count > 8'd20) begin
					count <= 8'd0;
					
					resetSoftware <= 1'd0;
					stateTopLevel <= GAMELOOP_TOPLEVEL;
				end
			end
			
			default : stateTopLevel <= WAIT_TOPLEVEL;
		endcase
	end
end

//
// define intro substatemachine behaviour
//
task intro_substatemachine () ;
	case (stateIntro)
		// draw background sprite
		DRAW_BACKGROUND_INTRO : begin
			draw_image(8'd239, 9'd100, 4'd11, finishedDraw);	// draw background sprite
			if (finishedDraw) begin									// wait for finishedDraw
				stateIntro <= DRAW_FLOOR_INTRO;
			end
		end
		
		// draw floor tiles
		DRAW_FLOOR_INTRO : begin
			// if end of screen not reached draw a floor tile
			if (loop < 11) begin
				draw_image(8'd31, (8'd100 + (32 * loop)), 4'd5, finishedDraw);	// draw floor sprite
				if (finishedDraw) begin														// wait for finishedDraw
					loop <= loop + 4'd1;
				end
				
			// if end of screen reached move to next state
			end else begin
				loop <= 4'd0;
				stateIntro <= DRAW_TITLE_INTRO;
			end
		end
		
		// draw title screen sprite
		DRAW_TITLE_INTRO : begin
			draw_image(8'd161, 9'd119, 4'd9, finishedDraw);	// draw intro sprite
			if (finishedDraw) begin									// wait for finishedDraw
				stateIntro <= WAIT_INTRO;
			end
		end
		
		// wait for user key press
		WAIT_INTRO : begin
			// wait for key0 to be pressed then released
			if (!key0hold && keys[0]) begin
				stateIntro <= START_GAME_INTRO;
			end
			key0hold <= keys[0];
		end
		
		// prompt top level state machine to move to gameloop
		START_GAME_INTRO : begin
			stateIntro <= DRAW_BACKGROUND_INTRO;
		end
	endcase
endtask

//
// define gameloop substatemachine behaviour
//
task gameloop_substatemachine () ;
	case (stateGameLoop)
		// start game loop at the posedge of the 10hz clock
		IDLE_GAMELOOP : begin
			if (clock10hz && (clock10hz != clockhold)) begin
				stateGameLoop <= UPDATE_SPRITES_GAMELOOP;
				count <= 8'd0;
			end
			clockhold <= clock10hz;
		end
		
		// update player and obstacle sprites
		UPDATE_SPRITES_GAMELOOP : begin
			updateSprite <= 1'd1;		// signal modules to update
			obstacleUpdate <= 1'd1;
			
			count <= count + 8'd1;		// wait 20 clock cycles for modules to update
			if (count > 8'd20) begin
				count <= 8'd0;
				
				updateSprite <= 1'd0;	//	turn off update signals
				obstacleUpdate <= 1'd0;
				// update score if obstacle passed
				if (passed) begin
					stateGameLoop <= UPDATE_SCORE_GAMELOOP;
				end else begin
					stateGameLoop <= CHECK_COLLISIONS_GAMELOOP;
				end
			end
		end
		
		// check for collision between player sprite and obstacle sprite
		CHECK_COLLISIONS_GAMELOOP : begin
			updateCollision <= 1'd1;		// signal module to update
			
			count <= count + 8'd1;			// wait 20 clock cycles for modules to update
			if (count > 8'd20) begin
				count <= 8'd0;
				
				updateCollision <= 1'd0;	//	turn off update signals
				// update lives if collision
				if (collision && !collisionHold) begin
					collisionHold <= 1;
					stateGameLoop <= UPDATE_LIVES_GAMELOOP;
				end else begin
					stateGameLoop <= DRAW_BACKGROUND_GAMELOOP;
				end
			end
		end
		
		// update players lives and check for gameover
		UPDATE_LIVES_GAMELOOP : begin
			updateLives <= 1'd1;
			
			count <= count + 8'd1;						// wait 20 clock cycles for modules to update
			if (count > 8'd1 && readyLives) begin
				count <= 8'd0;
				
				updateLives <= 1'd0;
				stateGameLoop <= DRAW_BACKGROUND_GAMELOOP;
			end
		end
		
		// update the players score 
		UPDATE_SCORE_GAMELOOP : begin
			// increment score if player did not collide with obstacle
			if (!collisionHold) begin
				updateScore <= 1'd1;
				
				count <= count + 8'd1;						// wait 20 clock cycles for modules to update
				if (count > 8'd1 && readyLives) begin
					count <= 8'd0;
					
					updateScore <= 1'd0;
					stateGameLoop <= DRAW_BACKGROUND_GAMELOOP;
				end
			
			// do not update score if player did collide
			end else begin
				collisionHold <= 1'd0;
				stateGameLoop <= DRAW_BACKGROUND_GAMELOOP;
			end
		end
		
		// draw background sprite
		DRAW_BACKGROUND_GAMELOOP : begin
			draw_image(8'd239, 9'd100, 4'd11, finishedDraw);	// draw background sprite
			if (finishedDraw) begin									// wait for finishedDraw
				stateGameLoop <= DRAW_SPRITE_GAMELOOP;
			end
		end
		
		// draw player sprite
		DRAW_SPRITE_GAMELOOP : begin
			draw_image(xSprite, ySprite, spriteId, finishedDraw);	// draw player sprite
			if (finishedDraw) begin											// wait for finishedDraw
				stateGameLoop <= DRAW_OBSTACLE_GAMELOOP;
			end
		end
		
		// draw obstacle sprite
		DRAW_OBSTACLE_GAMELOOP : begin
			draw_image(xObstacle, yObstacle, obstacleId, finishedDraw);	// draw obstacle sprite
			if (finishedDraw) begin													// wait for finishedDraw
				stateGameLoop <= DRAW_FLOOR_GAMELOOP;
			end
		end
		
		// draw floor sprites
		DRAW_FLOOR_GAMELOOP : begin
			// if end of screen not reached draw a floor tile
			if (loop < 11) begin
				draw_image(8'd31, (yFloor + (32 * loop)), 4'd5, finishedDraw);	// draw floor sprite
				if (finishedDraw) begin														// wait for finishedDraw
					loop <= loop + 4'd1;
				end
				
			// if end of screen reached move to next state
			end else begin
				loop <= 4'd0;
				yFloor <= yFloor - gameSpeed;			// update floor position for next loop
				if(yFloor <= 68 + gameSpeed) begin
					yFloor <= 100;
				end
				
				if (gameOver) begin
					stateGameLoop <= GAMEOVER_GAMELOOP;
				end else begin
					stateGameLoop <= IDLE_GAMELOOP;
				end
			end
		end
		
		// prompt top level state machine to move to game over state
		GAMEOVER_GAMELOOP : begin
			stateGameLoop <= IDLE_GAMELOOP;
		end
		
	endcase
endtask

//
// define statemachine tasks
//
// draw chosen sprite to the LCD at selected coordinations
// finishedDraw goes high when task complete 
reg finishedDraw;
task draw_image (input [7:0] x, input [8:0] y, input [3:0] id, output finishedDraw);
			finishedDraw	= 0;		
			xOrigin			<= x;		// set draw data
			yOrigin			<= y;
			ROMId				<= id;
			updateLCD		<= 1'd1;
			
			count <= count + 8'd1;				// wait for LCD to be ready
			if(count > 8'd20 && readyLCD) begin
				count <= 8'd0;
				
				updateLCD		<= 1'd0;
				finishedDraw	= 1;
			end
endtask

//
// derive 10hz clock
//
// clock divider 
always @ (posedge clock) begin
		randomSeed	<= randomSeed + 1;
		clockcounter <= clockcounter + 32'd1;
		if (clockcounter >= 32'd2500000) begin
			clock10hz <= !clock10hz;
			clockcounter <= 32'd0;
		end
end
endmodule 