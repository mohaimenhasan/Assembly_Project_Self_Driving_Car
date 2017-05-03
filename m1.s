.equ ADDR_JP1, 0xFF200060   # Address GPIO JP1
.equ TIMER, 0xFF202000 		# Timer Address
.equ DELAY_TIME, 150000     # Delay time. 
.equ KEY_BOARD, 0xFF200100  # Address GPIO JP1
.equ SWITCH, 0xFF200040     # Slider Switches
#----------------------------------------------MILESTONE 1---------------------------------------------------#
# Authors: Mohaimen Khan, Shrey Parikh
# Student No.: 1002392662
# Course: ECE243 - Computer Organization
#------------------------------------------------------------------------------------------------------------#


#set up ISR for echoing
.section  .exceptions, "ax"

ISR:

	# rdctl et, ctl4  #check the pending value
	# andi et, et, 0x080
	# beq et, r0, int_exit 

	movia r18, ADDR_JP1
	
	#Read from keyboard 
	movia r7, KEY_BOARD
	ldwio r21, 0(r7)

	#Check if valid
	#copy r8 to r11
	mov r11, r21
	srli r11, r11, 15
	andi r11, r11, 0x01
	movi r20, 0x01
	beq r11, r0, int_exit
	beq r11, r20, read_keyboard

read_keyboard: 

	#r21 is the valid data, unchanged
	andi r11, r21, 0x0ff
	#bits 0, 7 unchanged
	#Check which key is pressed, first 8 bits only
	#stahp
	movi r20, 0x1B
	beq r11, r20, turn_both_off_int
	#up 
	movi r20, 0x75
	beq r11, r20, turn_both_on_int
	#down
	movi r20, 0x72
	beq r11, r20, turn_both_on_rev_int
	#left
	movi r20, 0x6B
	beq r11, r20, turn_motor_zero_on_int
	#right
	movi r20, 0x74
	beq r11, r20, turn_motor_one_on_int

turn_both_off_int:

	ldwio r9, 0(r18)
	movia r15, 0x0000000f
	or r9, r9, r15
	stwio r9, 0(r18)
	br int_exit

turn_both_on_int:
	
	# call DELAY

	ldwio r9, 0(r18)
	movia r15, 0x0000000f
	or r9, r9, r15
	stwio r9, 0(r18)

	# call DELAY

	ldwio r9, 0(r18)
	movia r15, 0xfffffff0
	and r9, r9, r15
	stwio r9, 0(r18)
	br int_exit

	
turn_both_on_rev_int:
	
	# call DELAY

	ldwio r9, 0(r18)
	movia r15, 0x0000000f
	or r9, r9, r15
	stwio r9, 0(r18)

	# call DELAY

	ldwio r9, 0(r18)
	movia r15, 0xfffffffa
	and r9, r9, r15
	stwio r9, 0(r18)
	br int_exit
	

turn_motor_zero_on_int:	
	

	# ldwio r9, 0(r18)
	# movia r15, 0x0000000f
	# or r9, r9, r15
	# stwio r9, 0(r18)

	ldwio r9, 0(r18)
	movia r15, 0xfffffff8
	and r9, r9, r15
	stwio r9, 0(r18)
	br int_exit

turn_motor_one_on_int:	
	
	# ldwio r9, 0(r18)
	# movia r15, 0x0000000f
	# or r9, r9, r15
	# stwio r9, 0(r18)

	ldwio r9, 0(r18)
	movia r15, 0xfffffff2
	and r9, r9, r15
	stwio r9, 0(r18)
	br int_exit
	
int_exit:

	subi ea, ea, 4
	eret

#-------------------------------DATA  SECTION----------------------------------------------------------------#
# fill this up once everything is set up
# r15 = buffer aka it will be used over and over again
# r9 = buffer aka it will be used over and over 
# r8 = ADDR_JP1 - Address of the JP1 
#------------------------------------------------------------------------------------------------------------#

# subroutine for the timer
DELAY:
	
	movia r7, TIMER                   # r7 contains the base address for the timer 
	mov r2, r4 							   # get the lower 16 bits from r4 and put it in r2
	stwio r2, 8(r7)                        # Set the period to be 262150 clock cycles 
	mov r2, r5 							   # get the higher 16 bits off of r5 and put it in r5
	stwio r2, 12(r7)
	stwio r0, 0(r7)
	movui r2, 4
	stwio r2, 4(r7)                        # Start the timer without continuing or interrupts 

	count:
		ldwio r20, 0(r7)
		andi r20, r20, 0x1
		beq r20, r0, count 				   # check this please 

	stwio r0, (r7)
	ret


	

	
# contains every subroutine calls
# contains all interrupt calls

.global _start


_start:	 
	

	# Set up timer by moving delay times 
	# into r4 and r5
	movui  r4, %lo(DELAY_TIME)
  	movui  r5, %hi(DELAY_TIME)

	# Set up the direction registers
	# Move 0x07f557ff in an offset of 4
	# from the base address
	 movia r8, ADDR_JP1	
	 movia r9, 0x07f557ff
	 stwio r9, 4(r8)
	 
	# State Mode for sensors are used
	# First the sensors are enabled individually 
	# and loaded with threshold value 

	# cycle 1 = enabling sensor 0 for loading
	# confirmed 
	movia r9, 0xffbffbff
	stwio r9, 0(r8)

	# cycle 2 = loading threshold value and writing it
	# threshold == 9
	# confirmed 
	movia r15, 0xfcffffff
	and r9, r9, r15
	stwio r9, 0(r8)

	# cycle 3 - disable sensor 0 for loading
	# confirmed
	movia r9, 0xffffffff
	stwio r9, 0(r8)


	# cycle 1 = enabling sensor 1 for loading
	# confirmed 
	movia r9, 0xffbfefff
	stwio r9, 0(r8)

	# cycle 2 = loading threshold value and writing it
	# threshold == 9 
	# confirmed
	movia r15, 0xfcffffff
	and r9, r9, r15
	stwio r9, 0(r8)

	# cycle 3 - disable sensor 1 for loading
	# confirmed 
	movia r9, 0xffffffff
	stwio r9, 0(r8)

	# change into state mode
	# confirmed 
	ldwio r9, 0(r8)
	movia r15, 0xffdfffff
	and r9, r9, r15
	stwio r9, 0(r8)

	 # check both sensors
	 # 1 , 1 -> disable both motors
	 # 1 , 0 -> turn motor 1 on 
	 # 0 , 1 -> turn motor 0 on
	 # 0 , 0 -> turn 1 and 0 o
     #everything below confirmed 
	 
decide_keyboard_sensor:
	 movia r17, SWITCH
	 # moved the value of switches into r18
	 ldwio r18, 0(r17)
	 andi r18, r18, 0x01
	 # if switches are off then turn the motor off 
	 # keep on looping till the value of the switch == 1
	 beq r18, r0, turn_both_off
	 ldwio r18, 0(r17)
	 andi r18, r18, 0x03
	 movi r25, 0x03
	 beq r18, r25, keyboard_function
	 br check_sensors

keyboard_function:
	
	# read from KEY_BOARD
	# confirmed
	movia r17, KEY_BOARD
	
	# Enable read interrupts
	movi  r9, 0x1
	stwio r9, 4(r17)
	
	# writing into ctl3
	movi r9, 0x080
	wrctl ienable, r9
	
	# setting PIE = 1
	movi r9, 0b1
	wrctl ctl0, r9
	
	br decide_keyboard_sensor
	
check_sensors:
	# move by 27 bits

	 ldwio r9, 0(r8)
	 srli r9, r9, 27
	 andi r9, r9, 0b11 
	 movi r15, 0b11
	 beq r9, r15, turn_both_off
	 beq r9, r0, turn_both_on
	 movi r15, 0b10
	 beq r9, r15, turn_motor_zero_on
	 movi r15, 0b01
	 beq r9, r15, turn_motor_one_on
	 
	 br decide_keyboard_sensor


turn_both_on:
	
	call DELAY

	ldwio r9, 0(r8)
	movia r15, 0x0000000f
	or r9, r9, r15
	stwio r9, 0(r8)

	call DELAY

	ldwio r9, 0(r8)
	movia r15, 0xfffffff0
	and r9, r9, r15
	stwio r9, 0(r8)
	br decide_keyboard_sensor

turn_both_off:
	ldwio r9, 0(r8)
	movia r15, 0x0000000f
	or r9, r9, r15
	stwio r9, 0(r8)
	br decide_keyboard_sensor
	
turn_both_on_rev:
	
	call DELAY

	ldwio r9, 0(r8)
	movia r15, 0x0000000f
	or r9, r9, r15
	stwio r9, 0(r8)

	call DELAY

	ldwio r9, 0(r8)
	movia r15, 0xfffffffa
	and r9, r9, r15
	stwio r9, 0(r8)
	br decide_keyboard_sensor
	

turn_motor_zero_on:	
	



	ldwio r9, 0(r8)
	movia r15, 0xfffffff8
	and r9, r9, r15
	stwio r9, 0(r8)
	br decide_keyboard_sensor

turn_motor_one_on:	
	


	ldwio r9, 0(r8)
	movia r15, 0xfffffff2
	and r9, r9, r15
	stwio r9, 0(r8)
	br decide_keyboard_sensor


_exit: br _exit