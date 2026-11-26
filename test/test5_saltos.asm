# ======================================================================
# TEST 5 - Saltos: beq, bne, j
#
# Instrucciones y casos que cubre:
#   - beq (tomado, no tomado, con -1 y con bit 31)
#   - bne (tomado, no tomado, diferencia solo en el bit 31)
#   - j (hacia adelante y hacia atrás)
#   - Saltos hacia atrás en bucles (bne y beq+j)
#   - lui (para 0x80000000)
#   - syscall (imprimir carácter y terminar)
#
# Qué hace: calcula 10 resultados, los guarda con sw en el arreglo que
# empieza en $gp y al final los imprime en hexadecimal (8 dígitos por
# valor, 5 valores por línea). Si una instrucción falla, cambia el valor
# impreso en su posición.
# Orden de los valores: 1 = el salto se toma, 0 = no se toma; luego la suma 5+4+3+2+1 y 4 vueltas de +3.
#
# Salida esperada (2 líneas de 44 caracteres):
#   00000001 00000000 00000001 00000000 00000001
#   0000000f 0000000c 00000001 00000001 00000000
#
# Nota: usa la memoria desde $gp (0x1800) como zona de trabajo
# (resultados en gp+0..gp+39, pruebas de memoria en gp+256 y siguientes).
# ======================================================================
main:   addi $t0, $zero, 7
        addi $t1, $zero, 7
        addi $t3, $zero, 9
        # (1) beq 7 == 7: se toma
        addi $t2, $zero, 1
        beq  $t0, $t1, c1
        addi $t2, $zero, 0
c1:     sw   $t2, 0($gp)
        # (2) beq 7 == 9: no se toma
        addi $t2, $zero, 1
        beq  $t0, $t3, c2
        addi $t2, $zero, 0
c2:     sw   $t2, 4($gp)
        # (3) bne 7 != 9: se toma
        addi $t2, $zero, 1
        bne  $t0, $t3, c3
        addi $t2, $zero, 0
c3:     sw   $t2, 8($gp)
        # (4) bne 7 != 7: no se toma
        addi $t2, $zero, 1
        bne  $t0, $t1, c4
        addi $t2, $zero, 0
c4:     sw   $t2, 12($gp)
        # (5) j hacia adelante (salta el addi que pone 0)
        addi $t2, $zero, 1
        j    c5
        addi $t2, $zero, 0
c5:     sw   $t2, 16($gp)
        # (6) bucle con bne hacia atrás: 5+4+3+2+1
        addi $t4, $zero, 0
        addi $t5, $zero, 5
l6:     add  $t4, $t4, $t5
        addi $t5, $t5, -1
        bne  $t5, $zero, l6
        sw   $t4, 20($gp)
        # (7) bucle con beq al inicio y j hacia atrás: 4 vueltas de +3
        addi $t4, $zero, 0
        addi $t5, $zero, 4
l7:     beq  $t5, $zero, e7
        addi $t4, $t4, 3
        addi $t5, $t5, -1
        j    l7
e7:     sw   $t4, 24($gp)
        # (8) beq -1 == -1: se toma
        addi $t6, $zero, -1
        addi $t7, $zero, -1
        addi $t2, $zero, 1
        beq  $t6, $t7, c8
        addi $t2, $zero, 0
c8:     sw   $t2, 28($gp)
        # (9) bne 0x80000000 != 0: se toma (difieren solo en el bit 31)
        lui  $t6, 0x8000
        addi $t2, $zero, 1
        bne  $t6, $zero, c9
        addi $t2, $zero, 0
c9:     sw   $t2, 32($gp)
        # (10) beq 0x80000000 == 0: no se toma
        addi $t2, $zero, 1
        beq  $t6, $zero, c10
        addi $t2, $zero, 0
c10:    sw   $t2, 36($gp)

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
