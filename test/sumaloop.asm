loop
andi $s0, $v0, 1

addi $s4, $zero, 1
beq $v0, $s4, end
beq $s0, $zero, if
sll $s1, $v0, 1
add $s2, $s1, $v0
addi $v0, $s2, 1
addi $t0, $t0, 1
j loop

 if
 srl $v0, $v0, 1
 addi $t0, $t0, 1
 j loop
 
 end
 