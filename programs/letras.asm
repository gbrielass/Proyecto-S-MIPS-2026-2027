addi $v0, $zero, 11 
addi $a0, $zero, 97
addi $t0, $zero, 123
loop: syscall
addi $a0, $a0, 1
bne $a0, $t0, loop
addi $v0, $zero, 10
syscall

