# Lab5: Millis_counter 
# Saad Ouassil Allak
# Mtr-Num: 2945765 
main:			
	add $8,$0,$0	
	lui $8, 0xbf80
loop:
	lw $9, 0x34($8) # read value of counter
	j loop
	
	
infiniteloop:
	j infiniteloop		# wait forever
