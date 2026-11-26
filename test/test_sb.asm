.data
n: .byte 1

.text
la $t0, n
li $t1, 0
sb $t1, 0($t0)
lb $t2, 0($t0)
bne $t2, $zero, fail
li $v0, 10
syscall
fail:
j fail