.data
n:.word 0xaabb6100
.text
la $t0, n
lb $a0, 1($t0)
li $v0, 11
syscall
li $v0, 10
syscall
