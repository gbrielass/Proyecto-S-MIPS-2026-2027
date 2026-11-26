# ======================================================================
# TEST 4 - Memoria: sw, lw, lb, lbu, sb
#
# Instrucciones y casos que cubre:
#   - sw y lw (también con desplazamiento negativo)
#   - lbu (bytes 0, 1 y 3, sin signo)
#   - lb (con signo y sin signo: 0x80, 0x70 y 0xf0)
#   - sb (los 4 bytes de una palabra y un solo byte)
#   - Orden little-endian
#   - lui y ori (para armar 0x8070f00d)
#   - syscall (imprimir carácter y terminar)
#
# Qué hace: calcula 10 resultados, los guarda con sw en el arreglo que
# empieza en $gp y al final los imprime en hexadecimal (8 dígitos por
# valor, 5 valores por línea). Si una instrucción falla, cambia el valor
# impreso en su posición.
# Orden de los valores: lw, lbu x3, lb x3, sb en 4 carriles, sb de un solo byte, lw con offset -4.
#
# Salida esperada (2 líneas de 44 caracteres):
#   8070f00d 0000000d 000000f0 00000080 ffffff80
#   00000070 fffffff0 ddccbbaa 8070ff0d 0000f00d
#
# Nota: usa la memoria desde $gp (0x1800) como zona de trabajo
# (resultados en gp+0..gp+39, pruebas de memoria en gp+256 y siguientes).
# ======================================================================
main:   lui  $t0, 0x8070
        ori  $t0, $t0, 0xf00d       # t0 = 0x8070f00d
        sw   $t0, 256($gp)          # guarda la palabra en gp+256
        lw   $t2, 256($gp)          # (1) lw: la palabra completa
        sw   $t2, 0($gp)
        lbu  $t2, 256($gp)          # (2) lbu byte 0 = 0x0d (el menos significativo)
        sw   $t2, 4($gp)
        lbu  $t2, 257($gp)          # (3) lbu byte 1 = 0xf0 (sin signo)
        sw   $t2, 8($gp)
        lbu  $t2, 259($gp)          # (4) lbu byte 3 = 0x80
        sw   $t2, 12($gp)
        lb   $t2, 259($gp)          # (5) lb byte 3 = 0x80 con signo
        sw   $t2, 16($gp)
        lb   $t2, 258($gp)          # (6) lb byte 2 = 0x70 (positivo)
        sw   $t2, 20($gp)
        lb   $t2, 257($gp)          # (7) lb byte 1 = 0xf0 con signo
        sw   $t2, 24($gp)
        sw   $zero, 260($gp)        # limpia la palabra gp+260
        addi $t1, $zero, 0xaa
        sb   $t1, 260($gp)          # sb en el byte 0
        addi $t1, $zero, 0xbb
        sb   $t1, 261($gp)          # sb en el byte 1
        addi $t1, $zero, 0xcc
        sb   $t1, 262($gp)          # sb en el byte 2
        addi $t1, $zero, 0xdd
        sb   $t1, 263($gp)          # sb en el byte 3
        lw   $t2, 260($gp)          # (8) palabra armada byte a byte
        sw   $t2, 28($gp)
        sw   $t0, 264($gp)          # palabra 0x8070f00d en gp+264
        addi $t1, $zero, -1         # 0xffffffff: sb solo escribe el byte bajo
        sb   $t1, 265($gp)          # cambia solo el byte 1 (0xf0 pasa a 0xff)
        lw   $t2, 264($gp)          # (9) lw tras el sb
        sw   $t2, 32($gp)
        addi $t4, $gp, 512          # t4 = gp + 512
        ori  $t5, $zero, 0xf00d
        sw   $t5, -4($t4)           # sw con desplazamiento negativo
        lw   $t2, -4($t4)           # (10) lw con desplazamiento negativo
        sw   $t2, 36($gp)

        # ---- Impresión: 10 palabras del arreglo en $gp, en hex de 8 dígitos,
        # ---- 5 por línea (44 caracteres por línea).
        add  $s0, $gp, $zero        # s0 = puntero al arreglo de resultados
        addi $s1, $zero, 10       # s1 = valores que faltan por imprimir
        addi $s2, $zero, 5          # s2 = valores que faltan en esta línea
pv:     lw   $t0, 0($s0)            # t0 = valor a imprimir
        addi $t1, $zero, 8          # t1 = dígitos hex que faltan
pd:     srl  $t2, $t0, 28           # t2 = dígito más alto (0 a 15)
        slti $t3, $t2, 10           # t3 = 1 si el dígito es 0..9
        addi $a0, $t2, 48           # a0 = '0' + dígito
        bne  $t3, $zero, pcar       # si era 0..9, ya está
        addi $a0, $t2, 87           # si no: 'a' + (dígito - 10)
pcar:   addi $v0, $zero, 11
        syscall                     # imprime el carácter de $a0
        sll  $t0, $t0, 4            # pasa al siguiente dígito
        addi $t1, $t1, -1
        bne  $t1, $zero, pd         # repite 8 veces
        addi $s2, $s2, -1           # un valor menos en la línea
        addi $a0, $zero, 32         # espacio entre valores
        bne  $s2, $zero, sep
        addi $a0, $zero, 10         # tras el 5.o valor: salto de línea
        addi $s2, $zero, 5
sep:    addi $v0, $zero, 11
        syscall
        addi $s0, $s0, 4            # siguiente palabra
        addi $s1, $s1, -1
        bne  $s1, $zero, pv
        addi $v0, $zero, 10         # terminar
        syscall
