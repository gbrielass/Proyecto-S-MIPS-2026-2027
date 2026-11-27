loop:
beq $s1, $zero, endloop
add $s2, $s0, $s2
add $s1, $s1, -1
j loop
endloop:
