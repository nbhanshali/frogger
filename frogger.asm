#####################################################################
#
# CSC258H5S Winter 2022 Assembly Final Project
# University of Toronto, St. George
#
# Student: Nimit Amitkumar Bhanshali, 1006905994
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 5 
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. Display the number of lives remaining
# 2. After final player death, display game over/retry screen. Restart the game if the “retry” option is chosen.
# 3. Have objects in different rows move at different speeds.
# 4. Randomize the size and/or appearance of the logs and cars in the scene.
# 5. Add sound effects for movement, losing lives, collisions, and reaching the goal.
# 6. Displaying a pause screen or image when the ‘p’ key is pressed, and returning to the game when ‘p’ is pressed again.
# 7. Add a time limit to the game.
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################
.data
displayAddress:	.word 0x10008000
green: 		.word 0x0000ff00
mediumBlue:	.word 0x006365ff	 
khaki:		.word 0x00fbd864
darkGray:	.word 0x00444444
magenta:	.word 0x00ff00ff
chocolate:	.word 0x00c46700
red:		.word 0x00ff0000
X: 		.word 14
Y: 		.word 28
vehiclesRow1:	.space 512
vehiclesRow2:	.space 512
logsRow1:	.space 512
logsRow2:	.space 512
goal1:		.word 0
goal2:		.word 0
goal3:		.word 0
goal4:		.word 0



.text
main:
lw $t0, displayAddress 		# $t0 stores the base address for display
add $t8, $zero, $zero
sw $t8, goal1
sw $t8, goal2
sw $t8, goal3
sw $t8, goal4



jal choose_color

input_check:

# Check for keyboard input
lw $t8, 0xffff0000
beq $t8, 1, keyboard_input
j end_check

keyboard_input:
lw $t2, 0xffff0004
li $v0, 31
li $a0, 61
li $a1, 1000
li $a2, 120
li $a3, 127
syscall
beq $t2, 0x61, respond_to_A
beq $t2, 0x77, respond_to_W
beq $t2, 0x73, respond_to_S
beq $t2, 0x64, respond_to_D
beq $t2, 0x71, respond_to_Q
beq $t2, 0x70, respond_to_P
j end_check

respond_to_A:
lw $t3, X
addi $t3, $t3, -4
sw $t3, X
j end_check

respond_to_W:
lw $t3, Y
addi $t3, $t3, -4
sw $t3, Y
j end_check

respond_to_S:
lw $t3, Y
addi $t3, $t3, 4
sw $t3, Y
j end_check

respond_to_D:
lw $t3, X
addi $t3, $t3, 4
sw $t3, X
j end_check

respond_to_Q:
addi $t3, $zero, 14
sw $t3, X
addi $t3, $zero, 28
sw $t3, Y
add $s1, $zero, $zero
add $s3, $zero, $zero
j main

respond_to_P:
lw $t0, displayAddress 		# $t0 stores the base address for display
addi $a2, $zero, 32		# $a2 stores the height of the region
addi $a1, $zero, 32		# $a1 stores the width of the region
lw $t1, darkGray		# $t1 stores the color of the region
jal draw_rect			# call the draw_rect function
 
lw $t0, displayAddress 		# $t0 stores the base address for display
addi $t0, $t0, 1712
addi $a2, $zero, 6		# $a2 stores the height of the region
addi $a1, $zero, 3		# $a1 stores the width of the region
lw $t1, red			# $t1 stores the color of the region
jal draw_rect			# call the draw_rect function

lw $t0, displayAddress 		# $t0 stores the base address for display
addi $t0, $t0, 1728
addi $a2, $zero, 6		# $a2 stores the height of the region
addi $a1, $zero, 3		# $a1 stores the width of the region
lw $t1, red			# $t1 stores the color of the region
jal draw_rect			# call the draw_rect function

check_pause:
lw $t8, 0xffff0000
beq $t8, 1, pause_input
j no_pause

pause_input:
lw $t2, 0xffff0004
beq $t2, 0x70, respond_to_unpause
j no_pause

respond_to_unpause:
j input_check

no_pause:
li $v0, 32
li $a0, 1000
syscall
j check_pause


end_check:

# Check for collision events
collision_check:
lw $t2, X
lw $t3, Y
lw $t0, displayAddress 		# $t0 stores the base address for display
addi $t4, $zero, 128		# $t4 stores the width of the screen (in pixels)
addi $t5, $zero, 4		# $t5 stores the width of a pixel
mult $t3, $t4			# multiply the Y location of the frog to the width of the screen (in pixels)
mflo $t4			# $t4 moves to the row where the top left corner of the frog is
mult $t2, $t5			# multiply the X location of the frog to the width of a pixel
mflo $t5			# $t5 moves to the column where the top left corner of the frog is
add $t0, $t0, $t4		# $t0 moves to the row where the top left corner of the frog is
add $t0, $t0, $t5		# $t0 moves to the top left corner of the frog
addi $t0, $t0, 4		# $t0 moves to the pixel next to the top left corner of the frog

jal collision_loop

addi $t0, $t0, 4		# $t0 moves to the top left corner of the frog
jal collision_loop

addi $t0, $t0, 248		# $t0 moves to the top left corner of the frog
jal collision_loop 

addi $t0, $t0, 12		# $t0 moves to the top left corner of the frog
jal collision_loop
  
j end_check2

collision_loop:
lw $t6, 0($t0)
lw $t1, red
beq $t1, $t6, reset

lw $t1, mediumBlue
beq $t1, $t6, reset

j no_reset

reset:
li $v0, 31
li $a0, 61
li $a1, 1000
li $a2, 121
li $a3, 127
syscall
addi $t3, $zero, 14
sw $t3, X
addi $t3, $zero, 28
sw $t3, Y
addi $s1, $s1, 1
add $s3, $zero, $zero
j end_check2
 
no_reset:
jr $ra

end_check2:

# Move frog with log
lw $t2, X
lw $t3, Y
lw $t0, displayAddress 		# $t0 stores the base address for display
addi $t4, $zero, 128		# $t4 stores the width of the screen (in pixels)
addi $t5, $zero, 4		# $t5 stores the width of a pixel
mult $t3, $t4			# multiply the Y location of the frog to the width of the screen (in pixels)
mflo $t4			# $t4 moves to the row where the top left corner of the frog is
mult $t2, $t5			# multiply the X location of the frog to the width of a pixel
mflo $t5			# $t5 moves to the column where the top left corner of the frog is
add $t0, $t0, $t4		# $t0 moves to the row where the top left corner of the frog is
add $t0, $t0, $t5		# $t0 moves to the top left corner of the frog
addi $t0, $t0, 4		# $t0 moves to the pixel next to the top left corner of the frog

jal move_frog_loop

addi $t0, $t0, 4		# $t0 moves to the top left corner of the frog
jal move_frog_loop

addi $t0, $t0, 248		# $t0 moves to the top left corner of the frog
jal move_frog_loop

addi $t0, $t0, 12		# $t0 moves to the top left corner of the frog
jal move_frog_loop

j move_frog_end

move_frog_loop:
lw $t6, 0($t0)
lw $t1, chocolate
beq $t1, $t6, move_frog_with_log
jr $ra

move_frog_with_log:
lw $t3, X
blt $t0, 0x10008600, row2

addi $t3, $t3, -1
add $t4, $zero, 0
ble $t3, $t4, reset
sw $t3, X

j move_frog_end

row2: 
addi $t3, $t3, -2
add $t4, $zero, 0
ble $t3, $t4, reset
sw $t3, X

move_frog_end:



j update_location

update_location:
# Filling vehiclesRow1
la $t7, vehiclesRow1		# $t7 stores the address of vehiclesRow1


add $t2, $zero, $zero 		# set $t2 = 0
addi $t3, $zero, 4		# set $t3 = 4
 
filling_loop:
add $t4, $zero, $zero		# set $t4 = 0
addi $t9, $t7, 128		# $t9 stores the width limit for the given row of vehicles
add $t8, $t7, $s0		# $t8 stores the shifted value of the pixels in vehiclesRow1
# add $t8, $t8, $s0		# $t8 stores the shifted value of the pixels in vehiclesRow1



bge  $t2, $t3, filling_loop_end	# branch if $t2 >= $t3
# addi $t5, $zero, 16		# set $t5 = 16
lw $t1, darkGray			# $t1 stores the color of the pixels
add $t5, $zero, $s7
jal vehicle_loop		# jump to obstacle_loop

# addi $t5, $t5, 32		# set $t5 = 32
add $t5, $t5, $s7
lw $t1, red		# $t1 stores the color of the pixels
# jal choose_color
jal vehicle_loop		# jump to obstacle_loop

# addi $t5, $t5, 32		# set $t5 = 32
add $t5, $t5, $s7
lw $t1, darkGray			# $t1 stores the color of the pixels
# jal choose_color
jal vehicle_loop		# jump to obstacle_loop

# addi $t5, $t5, 32		# set $t5 = 32
add $t5, $t5, $s7
lw $t1, red		# $t1 stores the color of the pixels
# jal choose_color
jal vehicle_loop		# jump to obstacle_loop

# addi $s5, $s7, 96
addi $s6, $zero, 128
sub $s5, $s6, $t5
add $t5, $t5, $s5		# set $t5 = 32
# addi $t5, $t5, 16		# set $t5 = 16
lw $t1, darkGray			# $t1 stores the color of the pixels
# jal choose_color
jal vehicle_loop		# jump to obstacle_loop

addi $t2, $t2, 1		# increment value of $t2 by 1
addi $t7, $t7, 128		# increment value of $t7 by 128
j filling_loop

filling_loop_end:

# Filling vehiclesRow2
la $t7, vehiclesRow2		# $t7 stores the address of vehiclesRow1

add $t2, $zero, $zero 		# set $t2 = 0
addi $t3, $zero, 4		# set $t3 = 4

filling_loop2:
add $t4, $zero, $zero		# set $t4 = 0
addi $t9, $t7, 128		# $t9 stores the width limit for the given row of vehicles
add $t8, $t7, $s4		# $t8 stores the shifted value of the pixels in vehiclesRow1
 
bge $t2, $t3, filling_loop2_end	# branch if $t2 >= $t3
# addi $t5, $zero, 32		# set $t5 = 16
add $t5, $zero, $s7
lw $t1, red			# $t1 stores the color of the pixels
jal vehicle_loop		# jump to obstacle_loop

#addi $t5, $t5, 32		# set $t5 = 32
add $t5, $t5, $s7
lw $t1, darkGray		# $t1 stores the color of the pixels
jal vehicle_loop		# jump to obstacle_loop

#addi $t5, $t5, 32		# set $t5 = 32
add $t5, $t5, $s7
lw $t1, red			# $t1 stores the color of the pixels
jal vehicle_loop		# jump to obstacle_loop

addi $s6, $zero, 128
sub $s5, $s6, $t5
add $t5, $t5, $s5		# set $t5 = 32
#addi $t5, $t5, 32		# set $t5 = 32
lw $t1, darkGray		# $t1 stores the color of the pixels
jal vehicle_loop		# jump to obstacle_loop

addi $t2, $t2, 1		# increment value of $t2 by 1
addi $t7, $t7, 128		# increment value of $t7 by 128
j filling_loop2

filling_loop2_end:

# Filling logsRow1
la $t7, logsRow1		# $t7 stores the address of vehiclesRow1

add $t2, $zero, $zero 		# set $t2 = 0
addi $t3, $zero, 4		# set $t3 = 4

filling_loop3:
add $t4, $zero, $zero		# set $t4 = 0
add $t9, $t7, $zero		# $t9 stores the width limit for the given row of vehicles
# sub $t8, $t7, $s4		# $t8 stores the shifted value of the pixels in vehiclesRow1
sub $t8, $t7, $s0		# $t8 stores the shifted value of the pixels in vehiclesRow1

bge $t2, $t3, filling_loop3_end	# branch if $t2 >= $t3
# addi $t5, $zero, 32		# set $t5 = 16
add $t5, $zero, $s7
lw $t1, mediumBlue			# $t1 stores the color of the pixels
jal log_loop			# jump to obstacle_loop

# addi $t5, $t5, 32		# set $t5 = 32
add $t5, $t5, $s7
lw $t1, chocolate		# $t1 stores the color of the pixels
jal log_loop			# jump to obstacle_loop

# addi $t5, $t5, 32		# set $t5 = 32
add $t5, $t5, $s7
lw $t1, mediumBlue			# $t1 stores the color of the pixels
jal log_loop			# jump to obstacle_loop

# addi $t5, $t5, 32		# set $t5 = 32
addi $s6, $zero, 128
sub $s5, $s6, $t5
add $t5, $t5, $s5		# set $t5 = 32
lw $t1, chocolate		# $t1 stores the color of the pixels
jal log_loop			# jump to obstacle_loop

addi $t2, $t2, 1		# increment value of $t2 by 1
addi $t7, $t7, 128		# increment value of $t7 by 128
j filling_loop3

filling_loop3_end:

# Filling logsRow2
la $t7, logsRow2		# $t7 stores the address of vehiclesRow1

add $t2, $zero, $zero 		# set $t2 = 0
addi $t3, $zero, 4		# set $t3 = 4

filling_loop4:
add $t4, $zero, $zero		# set $t4 = 0
add $t9, $t7, $zero		# $t9 stores the width limit for the given row of vehicles
# sub $t8, $t7, $s0		# $t8 stores the shifted value of the pixels in vehiclesRow1
sub $t8, $t7, $s4		# $t8 stores the shifted value of the pixels in vehiclesRow1

bge $t2, $t3, filling_loop4_end	# branch if $t2 >= $t3
add $t5, $zero, $s7
# addi $t5, $zero, 16		# set $t5 = 16
lw $t1, chocolate		# $t1 stores the color of the pixels
jal log_loop			# jump to obstacle_loop

# addi $t5, $t5, 32		# set $t5 = 32
add $t5, $t5, $s7
lw $t1, mediumBlue		# $t1 stores the color of the pixels
jal log_loop			# jump to obstacle_loop
	
# addi $t5, $t5, 32		# set $t5 = 32
add $t5, $t5, $s7
lw $t1, chocolate		# $t1 stores the color of the pixels
jal log_loop			# jump to obstacle_loop

addi $t5, $t5, 32		# set $t5 = 32
# add $t5, $t5, $s7
lw $t1, mediumBlue		# $t1 stores the color of the pixels
jal log_loop			# jump to obstacle_loop
	
# addi $t5, $t5, 16		# set $t5 = 16
addi $s6, $zero, 128
sub $s5, $s6, $t5
add $t5, $t5, $s5		# set $t5 = 32
lw $t1, chocolate		# $t1 stores the color of the pixels
jal log_loop			# jump to obstacle_loop

addi $t2, $t2, 1		# increment value of $t2 by 1
addi $t7, $t7, 128		# increment value of $t7 by 128
j filling_loop4

filling_loop4_end:

# Check for goal region
lw $t2, X
lw $t3, Y
lw $t0, displayAddress 		# $t0 stores the base address for display
addi $t4, $zero, 128		# $t4 stores the width of the screen (in pixels)
addi $t5, $zero, 4		# $t5 stores the width of a pixel
mult $t3, $t4			# multiply the Y location of the frog to the width of the screen (in pixels)
mflo $t4			# $t4 moves to the row where the top left corner of the frog is
mult $t2, $t5			# multiply the X location of the frog to the width of a pixel
mflo $t5			# $t5 moves to the column where the top left corner of the frog is
add $t0, $t0, $t4		# $t0 moves to the row where the top left corner of the frog is
add $t0, $t0, $t5		# $t0 moves to the top left corner of the frog

lw $t9, displayAddress 		# $t0 stores the base address for display
sub $t9, $t0, $t9

addi $t6, $zero, 32		
blt $t9, $t6, goal_region1

addi $t6, $zero, 64		
blt $t9, $t6, goal_region2

addi $t6, $zero, 96		
blt $t9, $t6, goal_region3

addi $t6, $zero, 128		
blt $t9, $t6, goal_region4

j end_check3

goal_region1:
li $v0, 31
li $a0, 61
li $a1, 1000
li $a2, 122
li $a3, 127
syscall
addi $t8, $zero, 1
sw $t8, goal1 
addi $t3, $zero, 14
sw $t3, X
addi $t3, $zero, 28
sw $t3, Y
add $s3, $zero, $zero
j end_check3

goal_region2:
li $v0, 31
li $a0, 61
li $a1, 1000
li $a2, 122
li $a3, 127
syscall
addi $t8, $zero, 1
sw $t8, goal2 
addi $t3, $zero, 14
sw $t3, X
addi $t3, $zero, 28
sw $t3, Y
add $s3, $zero, $zero
j end_check3

goal_region3:
li $v0, 31
li $a0, 61
li $a1, 1000
li $a2, 122
li $a3, 127
syscall
addi $t8, $zero, 1
sw $t8, goal3 
addi $t3, $zero, 14
sw $t3, X
addi $t3, $zero, 28
sw $t3, Y
add $s3, $zero, $zero
j end_check3

goal_region4:
li $v0, 31
li $a0, 61
li $a1, 1000
li $a2, 122
li $a3, 127
syscall
addi $t8, $zero, 1
sw $t8, goal4 
addi $t3, $zero, 14
sw $t3, X
addi $t3, $zero, 28
sw $t3, Y
add $s3, $zero, $zero
j end_check3


end_check3:

j draw

draw:

# Draw the upper goal region
lw $t0, displayAddress 		# $t0 stores the base address for display
addi $a2, $zero, 4 		# $a2 stores the height of the region
addi $a1, $zero, 32		# $a1 stores the width of the region
lw $t1, green			# $t1 stores the color of the region
jal draw_rect			# call the draw_rect function

goalcheck1:
lw $t8, goal1
beq $t8, 1, draw_goal1

goalcheck2:
lw $t8, goal2
beq $t8, 1, draw_goal2

goalcheck3:
lw $t8, goal3
beq $t8, 1, draw_goal3

goalcheck4:
lw $t8, goal4
beq $t8, 1, draw_goal4

j end_draw_goal

draw_goal1:
lw $t0, displayAddress 		# $t0 stores the base address for display
addi $a2, $zero, 4		# $a2 stores the height of the region
addi $a1, $zero, 8		# $a1 stores the width of the region
lw $t1, magenta			# $t1 stores the color of the region
jal draw_rect			# call the draw_rect function
j goalcheck2

draw_goal2:
lw $t0, displayAddress 		# $t0 stores the base address for display
addi $t0, $t0, 32
addi $a2, $zero, 4		# $a2 stores the height of the region
addi $a1, $zero, 8		# $a1 stores the width of the region
lw $t1, magenta			# $t1 stores the color of the region
jal draw_rect			# call the draw_rect function
j goalcheck3

draw_goal3:
lw $t0, displayAddress 		# $t0 stores the base address for display
addi $t0, $t0, 64
addi $a2, $zero, 4		# $a2 stores the height of the region
addi $a1, $zero, 8		# $a1 stores the width of the region
lw $t1, magenta			# $t1 stores the color of the region
jal draw_rect			# call the draw_rect function
j goalcheck4

draw_goal4:
lw $t0, displayAddress 		# $t0 stores the base address for display
addi $t0, $t0, 96
addi $a2, $zero, 4		# $a2 stores the height of the region
addi $a1, $zero, 8		# $a1 stores the width of the region
lw $t1, magenta			# $t1 stores the color of the region
jal draw_rect			# call the draw_rect function

end_draw_goal:
# Draw the lower goal region
lw $t0, displayAddress 		# $t0 stores the base address for display
addi $t0, $t0, 512
addi $a2, $zero, 4 		# $a2 stores the height of the region
addi $a1, $zero, 32		# $a1 stores the width of the region
lw $t1, green			# $t1 stores the color of the region
jal draw_rect			# call the draw_rect function

# Draw the safe region 
lw $t0, displayAddress 		# $t0 stores the base address for display
addi $t0, $t0, 2048
addi $a2, $zero, 4		# $a2 stores the height of the region
addi $a1, $zero, 32		# $a1 stores the width of the region
lw $t1, khaki			# $t1 stores the color of the region
jal draw_rect			# call the draw_rect function

# Draw the starting region
lw $t0, displayAddress 		# $t0 stores the base address for display
addi $t0, $t0, 3584
addi $a2, $zero, 4		# $a2 stores the height of the region
addi $a1, $zero, 32		# $a1 stores the width of the region
lw $t1, green			# $t1 stores the color of the region
jal draw_rect			# call the draw_rect function
lw $t0, displayAddress 		# $t0 stores the base address for display
addi $t0, $t0, 3968
beq $s1, 0, three_lives
beq $s1, 1, two_lives
beq $s1, 2, one_life
j draw_obstacles

three_lives:
lw $t1, magenta			# $t1 stores the color of the region
sw $t1, 4($t0)
sw $t1, 12($t0)
sw $t1, 20($t0)
j draw_obstacles

two_lives:
lw $t1, magenta			# $t1 stores the color of the region
sw $t1, 4($t0)
sw $t1, 12($t0)
j draw_obstacles

one_life:
lw $t1, magenta			# $t1 stores the color of the region
sw $t1, 4($t0)


# Drawing obstacles
draw_obstacles:
add $t4, $zero, $zero		# $t4 holds 4*i; initially 0
addi $t5, $zero, 128		# $t5 hold 32*sizeof(int) 

lw $t0, displayAddress 		# $t0 stores the base address for display
addi $t0, $t0, 3072		# Increment value in $t0 by 3072
la $t8, vehiclesRow1		# $t8 holds address of vehiclesRow1[1]
jal draw_obstacle

add $t4, $zero, $zero		# $t4 holds 4*i; initially 0
addi $t5, $zero, 128		# $t5 hold 32*sizeof(int) 

lw $t0, displayAddress 		# $t0 stores the base address for display
addi $t0, $t0, 2560		# Increment value in $t0 by 3072
la $t8, vehiclesRow2		# $t8 holds address of vehiclesRow1[1]
jal draw_obstacle

add $t4, $zero, $zero		# $t4 holds 4*i; initially 0
addi $t5, $zero, 128		# $t5 hold 32*sizeof(int) 

lw $t0, displayAddress 		# $t0 stores the base address for display
addi $t0, $t0, 1536		# Increment value in $t0 by 3072
la $t8, logsRow1		# $t8 holds address of vehiclesRow1[1]
jal draw_obstacle

add $t4, $zero, $zero		# $t4 holds 4*i; initially 0
addi $t5, $zero, 128		# $t5 hold 32*sizeof(int) 

lw $t0, displayAddress 		# $t0 stores the base address for display
addi $t0, $t0, 1024		# Increment value in $t0 by 3072
la $t8, logsRow2		# $t8 holds address of vehiclesRow1[1]
jal draw_obstacle

# Draw the frog 
lw $t0, displayAddress 		# $t0 stores the base address for display
lw $t1, magenta			# $t1 stores the color of the frog
lw $t2, X			# $t2 stores the X location of the frog
lw $t3, Y			# $t3 stores the Y location of the frog
jal draw_frog			# jump to draw_frog




# Draw the frog
lw $t0, displayAddress 		# $t0 stores the base address for display
lw $t1, magenta			# $t1 stores the color of the frog
lw $t2, X			# $t2 stores the X location of the frog
lw $t3, Y			# $t3 stores the Y location of the frog
jal draw_frog			# jump to draw_frog


j sleep

# Sleep operation
sleep: 
li $v0, 32
li $a0, 100
syscall

lw $t8, goal1
bne $t8, 1, next
lw $t8, goal2
bne $t8, 1, next
lw $t8, goal3
bne $t8, 1, next
lw $t8, goal4
bne $t8, 1, next
j Exit

next:
beq $s3, 180, time_up 
addi $s3, $s3, 1

addi $t9, $zero, 3
beq $s1, $t9, retry_screen

addi $s2, $zero, 128
beq $s0, $s2, reset_shift
addi $s0, $s0, 4

vehicle_size:
beq $s0, 64, change_size
j shift2

change_size:
jal choose_color

shift2:
beq $s4, $s2, reset_shift2
addi $s4, $s4, 8

j jump

time_up:
j reset

reset_shift:
add $s0, $zero, $zero

j vehicle_size


reset_shift2:
add $s4, $zero, $zero


jump:
j input_check

# Retry Screen
retry_screen:
add $s1, $zero, $zero
lw $t0, displayAddress 		# $t0 stores the base address for display
addi $a2, $zero, 32		# $a2 stores the height of the region
addi $a1, $zero, 32		# $a1 stores the width of the region
lw $t1, darkGray			# $t1 stores the color of the region
jal draw_rect			# call the draw_rect function

lw $t0, displayAddress 		# $t0 stores the base address for display
addi $t0, $t0, 912
lw $t1, red			# $t1 stores the color of the region
sw $t1, 0($t0)
sw $t1, 4($t0)
sw $t1, 8($t0)
sw $t1, 128($t0)
sw $t1, 136($t0)
sw $t1, 256($t0)
sw $t1, 260($t0)
sw $t1, 264($t0)
sw $t1, 384($t0)
sw $t1, 388($t0)
sw $t1, 512($t0)
sw $t1, 520($t0)

addi $t0, $t0, 16
sw $t1, 0($t0)
sw $t1, 4($t0)
sw $t1, 8($t0)
sw $t1, 128($t0)
sw $t1, 256($t0)
sw $t1, 260($t0)
sw $t1, 264($t0)
sw $t1, 384($t0)
sw $t1, 512($t0)
sw $t1, 516($t0)
sw $t1, 520($t0)

addi $t0, $t0, 16
sw $t1, 0($t0)
sw $t1, 4($t0)
sw $t1, 8($t0)
sw $t1, 132($t0)
sw $t1, 260($t0)
sw $t1, 388($t0)
sw $t1, 516($t0)

addi $t0, $t0, 16
sw $t1, 0($t0)
sw $t1, 4($t0)
sw $t1, 8($t0)
sw $t1, 128($t0)
sw $t1, 136($t0)
sw $t1, 256($t0)
sw $t1, 260($t0)
sw $t1, 264($t0)
sw $t1, 384($t0)
sw $t1, 388($t0)
sw $t1, 512($t0)
sw $t1, 520($t0)

addi $t0, $t0, 16
sw $t1, 0($t0)
sw $t1, 8($t0)
sw $t1, 128($t0)
sw $t1, 136($t0)
sw $t1, 256($t0)
sw $t1, 260($t0)
sw $t1, 264($t0)
sw $t1, 388($t0)
sw $t1, 516($t0)

addi $t0, $t0, 16
sw $t1, 0($t0)
sw $t1, 4($t0)
sw $t1, 8($t0)
sw $t1, 128($t0)
sw $t1, 136($t0)
sw $t1, 260($t0)
sw $t1, 264($t0)
sw $t1, 516($t0)

lw $t0, displayAddress 		# $t0 stores the base address for display
addi $t0, $t0, 1680
lw $t1, red			# $t1 stores the color of the region
sw $t1, 0($t0)
sw $t1, 4($t0)
sw $t1, 8($t0)
sw $t1, 128($t0)
sw $t1, 136($t0)
sw $t1, 256($t0)
sw $t1, 260($t0)
sw $t1, 264($t0)
sw $t1, 384($t0)
sw $t1, 512($t0)

addi $t0, $t0, 16
sw $t1, 0($t0)
sw $t1, 4($t0)
sw $t1, 8($t0)
sw $t1, 128($t0)
sw $t1, 136($t0)
sw $t1, 256($t0)
sw $t1, 260($t0)
sw $t1, 264($t0)
sw $t1, 384($t0)
sw $t1, 388($t0)
sw $t1, 512($t0)
sw $t1, 520($t0)

addi $t0, $t0, 16
sw $t1, 0($t0)
sw $t1, 4($t0)
sw $t1, 8($t0)
sw $t1, 128($t0)
sw $t1, 256($t0)
sw $t1, 260($t0)
sw $t1, 264($t0)
sw $t1, 384($t0)
sw $t1, 512($t0)
sw $t1, 516($t0)
sw $t1, 520($t0)

addi $t0, $t0, 16
sw $t1, 0($t0)
sw $t1, 4($t0)
sw $t1, 8($t0)
sw $t1, 128($t0)
sw $t1, 256($t0)
sw $t1, 260($t0)
sw $t1, 264($t0)
sw $t1, 392($t0)
sw $t1, 512($t0)
sw $t1, 516($t0)
sw $t1, 520($t0)

addi $t0, $t0, 16
sw $t1, 0($t0)
sw $t1, 4($t0)
sw $t1, 8($t0)
sw $t1, 128($t0)
sw $t1, 256($t0)
sw $t1, 260($t0)
sw $t1, 264($t0)
sw $t1, 392($t0)
sw $t1, 512($t0)
sw $t1, 516($t0)
sw $t1, 520($t0)

lw $t1, green	

addi $t0, $t0, 16
sw $t1, 0($t0)
sw $t1, 4($t0)
sw $t1, 8($t0)
sw $t1, 128($t0)
sw $t1, 136($t0)
sw $t1, 256($t0)
sw $t1, 260($t0)
sw $t1, 264($t0)
sw $t1, 384($t0)
sw $t1, 388($t0)
sw $t1, 512($t0)
sw $t1, 520($t0)

# Check for keyboard input
check_retry:
lw $t8, 0xffff0000
beq $t8, 1, retry_input
j check_retry

retry_input:
lw $t2, 0xffff0004
beq $t2, 0x72, respond_to_R
j no_input

respond_to_R:
j main

no_input:
j Exit

# Draw a rectangle
draw_rect:
add $t6, $zero, $zero		# Set current index $t6 to 0
draw_rect_start:
beq $t6, $a2, draw_rect_end	# while $t6 != $a2 (height of rectangle)

# Draw a line
add $t5, $zero, $zero		# Set current index $t5 to 0
draw_line_start:
beq $t5, $a1, draw_line_end	# while $t5 != $a1 (width of rectangle)
sw $t1, 0($t0)			# Draw a pixel at memory location $t0
addi $t0, $t0, 4		# Increment value in $t0 by 4
addi $t5, $t5, 1		# Increment $t5 by 1
j draw_line_start		# jump to beginning of loop to draw line
draw_line_end:

addi $t7, $zero, 4		# $t7 stores the width of a pixel
mult $t7, $a1			# multiplying the width of a pixel to width of rectangle
mflo $t7			# $t7 stores the column in which the last pixel was drawn
sub $t0, $t0, $t7		# $t0 stores memory location with a certain and first column
addi $t0, $t0, 128		# Increment value in $t0 by 128
addi $t6, $t6, 1		# Increment $t6 by 1
j draw_rect_start		# jump to beginning of loop to draw rectangle

draw_rect_end:
jr $ra				# jump back to return address

# Draw a frog
draw_frog:
addi $sp, $sp, -4		# move stack pointer a word
sw $ra, 0($sp)			# push a word onto the stack

addi $t4, $zero, 128		# $t4 stores the width of the screen (in pixels)
addi $t5, $zero, 4		# $t5 stores the width of a pixel
mult $t3, $t4			# multiply the Y location of the frog to the width of the screen (in pixels)
mflo $t4			# $t4 moves to the row where the top left corner of the frog is
mult $t2, $t5			# multiply the X location of the frog to the width of a pixel
mflo $t5			# $t5 moves to the column where the top left corner of the frog is
add $t0, $t0, $t4		# $t0 moves to the row where the top left corner of the frog is
add $t0, $t0, $t5		# $t0 moves to the top left corner of the frog

sw $t1, 0($t0)			# Draw a pixel at memory location $t0
addi $t0, $t0, 12		# Increment value in $t0 by 12
sw $t1, 0($t0)			# Draw a pixel at memory location $t0
addi $t0, $t0, 116		# Increment value in $t0 by 116

addi $a2, $zero, 1 		# $a2 stores the height of the region
addi $a1, $zero, 4		# $a1 stores the width of the region
jal draw_rect			# call the draw_rect function
addi $t0, $t0, 4		# Increment value in $t0 by 120

addi $a2, $zero, 1 		# $a2 stores the height of the region
addi $a1, $zero, 2		# $a1 stores the width of the region
jal draw_rect			# call the draw_rect function
addi $t0, $t0, -4		# Increment value in $t0 by 120

addi $a2, $zero, 1 		# $a2 stores the height of the region
addi $a1, $zero, 4		# $a1 stores the width of the region
jal draw_rect			# call the draw_rect function

draw_frog_end:
lw $ra, 0($sp)			# pop a word off the stack
addi $sp, $sp, 4		# move stack pointer a word
jr $ra


# Fill the vehicle space
vehicle_loop:
bge $t4, $t5, vehicle_loop_end	# branch if $t4 >= $t5
add $t6, $t8, $t4		# $t6 holds addr(vehiclesRow1[i])
bge $t6, $t9, wrap_vehicle	# branch if $t6 >= $t9	
sw $t1, 0($t6)			# value of vehiclesRow1[i] is set to $t1
j update_vehicle			# jump to update

wrap_vehicle:
addi $t6, $t6, -128 		# subtract 128 to wrap the shifted pixels to the start of the row
sw $t1, 0($t6)			# value of vehiclesRow1[i] is set to $t1

update_vehicle:
addi $t4, $t4, 4		# update offset in $t4
j vehicle_loop			# jump to start of loop, obstacle_loop
	
vehicle_loop_end:
jr $ra				# jump back to return address of function call

# Fill the log space
log_loop:
bge $t4, $t5, log_loop_end	# branch if $t4 >= $t5
add $t6, $t8, $t4		# $t6 holds addr(vehiclesRow1[i])
blt $t6, $t9, wrap_log 		# branch if $t6 >= $t9	
sw $t1, 0($t6)			# value of vehiclesRow1[i] is set to $t1
j update_log			# jump to update

wrap_log:
addi $t6, $t6, 128 		# subtract 128 to wrap the shifted pixels to the start of the row
sw $t1, 0($t6)			# value of vehiclesRow1[i] is set to $t1

update_log:
addi $t4, $t4, 4		# update offset in $t4
j log_loop			# jump to start of loop, obstacle_loop
	
log_loop_end:
jr $ra				# jump back to return address of function call

# Draw the obstacles
draw_obstacle:
bge $t4, $t5, draw_obstacle_end	# branch if $t4 >= 128
add $t6, $t8, $t4		# $t6 holds addr(vehiclesRow1[i])
lw $t7, 0($t6)			# $t7 holds the value of vehiclesRow1[i]
sw $t7, 0($t0)			# $t0 = vehiclesRow1[i]
lw $t7, 128($t6)		# $t7 holds the value of vehiclesRow1[i]
sw $t7, 128($t0)		# $t0 = vehiclesRow1[i]
lw $t7, 256($t6)		# $t7 holds the value of vehiclesRow1[i]
sw $t7, 256($t0)		# $t0 = vehiclesRow1[i]
lw $t7, 384($t6)		# $t7 holds the value of vehiclesRow1[i]
sw $t7, 384($t0)		# $t0 = vehiclesRow1[i]
addi $t4, $t4, 4		# update offset in $t4 by 4
add $t0, $t0, 4 		# Increment value in $t0 by $t4
j draw_obstacle			# jump to start of loop, draw_obstacle

draw_obstacle_end:
jr $ra	

# Choose the color
choose_color:
li $v0, 42
li $a0, 0
li $a1, 5
syscall

addi $s7, $a0, 4 
sll $s7, $s7, 2
 
end_choice:
jr $ra

Exit:
add $s1, $zero, $zero
li $v0, 10 			# terminate the program gracefully
syscall
