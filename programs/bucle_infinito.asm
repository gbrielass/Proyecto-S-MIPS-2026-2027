addi $v0, $zero, 11 
addi $a0, $zero, 97
loop: syscall
addi $a0, $a0, 1
j loop 