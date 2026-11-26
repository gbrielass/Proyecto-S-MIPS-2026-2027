# ======================================================================
# TEST 3 - Desplazamientos: sll, srl
#
# Instrucciones y casos que cubre:
#   - sll (4, 31, 16 y 0 bits)
#   - srl (28, 1, 4 y 8 bits; desplazamiento lógico, entra con ceros)
#   - ori (para armar 0xf00d)
#   - syscall (imprimir carácter y terminar)
#
# Qué hace: calcula 10 resultados, los guarda con sw en el arreglo que
# empieza en $gp y al final los imprime en hexadecimal (8 dígitos por
# valor, 5 valores por línea). Si una instrucción falla, cambia el valor
# impreso en su posición.
# Orden de los valores: sll 1<<4, 1<<31, 0xf00d<<4, 0xf00d<<16, <<0; srl -1>>28, -1>>1, 0xf00d>>4, >>8, 1>>1.
#
# Salida esperada (2 líneas de 44 caracteres):
#   00000010 80000000 000f00d0 f00d0000 ffffffff
#   0000000f 7fffffff 00000f00 000000f0 00000000
#
# Nota: usa la memoria desde $gp (0x1800) como zona de trabajo
# (resultados en gp+0..gp+39, pruebas de memoria en gp+256 y siguientes).
# ======================================================================
main:   addi $t0, $zero, 1          # t0 = 1
        addi $t1, $zero, -1         # t1 = 0xffffffff
        ori  $t3, $zero, 0xf00d     # t3 = 0x0000f00d
        sll  $t2, $t0, 4            # (1) 1 << 4
        sw   $t2, 0($gp)
        sll  $t2, $t0, 31           # (2) 1 << 31
        sw   $t2, 4($gp)
        sll  $t2, $t3, 4            # (3) 0xf00d << 4
        sw   $t2, 8($gp)
        sll  $t2, $t3, 16           # (4) 0xf00d << 16
        sw   $t2, 12($gp)
        sll  $t2, $t1, 0            # (5) desplazamiento de 0 bits
        sw   $t2, 16($gp)
        srl  $t2, $t1, 28           # (6) 0xffffffff >> 28
        sw   $t2, 20($gp)
        srl  $t2, $t1, 1            # (7) 0xffffffff >> 1 (lógico: entra un 0)
        sw   $t2, 24($gp)
        srl  $t2, $t3, 4            # (8) 0xf00d >> 4
        sw   $t2, 28($gp)
        srl  $t2, $t3, 8            # (9) 0xf00d >> 8
        sw   $t2, 32($gp)
        srl  $t2, $t0, 1            # (10) 1 >> 1
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
