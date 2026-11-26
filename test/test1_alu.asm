# ======================================================================
# TEST 1 - ALU registro: add, sub, and, or, addu, slt
#
# Instrucciones y casos que cubre:
#   - add (positivos y con un negativo)
#   - sub (resultado positivo y negativo)
#   - and, or
#   - addu (con negativos)
#   - slt (falso, verdadero y comparación con signo: -3 < 5)
#   - syscall (imprimir carácter y terminar)
#
# Qué hace: calcula 10 resultados, los guarda con sw en el arreglo que
# empieza en $gp y al final los imprime en hexadecimal (8 dígitos por
# valor, 5 valores por línea). Si una instrucción falla, cambia el valor
# impreso en su posición.
# Orden de los valores: a=12, b=5, c=-3: a+b, a-b, b-a, a&b, a|b, a+c, c+c (addu), a<b, b<a, c<b.
#
# Salida esperada (2 líneas de 44 caracteres):
#   00000011 00000007 fffffff9 00000004 0000000d
#   00000009 fffffffa 00000000 00000001 00000001
#
# Nota: usa la memoria desde $gp (0x1800) como zona de trabajo
# (resultados en gp+0..gp+39, pruebas de memoria en gp+256 y siguientes).
# ======================================================================
main:   addi $t0, $zero, 12         # t0 = a = 12
        addi $t1, $zero, 5          # t1 = b = 5
        addi $t3, $zero, -3         # t3 = c = -3 (0xfffffffd)
        add  $t2, $t0, $t1          # (1) a + b
        sw   $t2, 0($gp)
        sub  $t2, $t0, $t1          # (2) a - b
        sw   $t2, 4($gp)
        sub  $t2, $t1, $t0          # (3) b - a (negativo)
        sw   $t2, 8($gp)
        and  $t2, $t0, $t1          # (4) 1100 AND 0101
        sw   $t2, 12($gp)
        or   $t2, $t0, $t1          # (5) 1100 OR 0101
        sw   $t2, 16($gp)
        add  $t2, $t0, $t3          # (6) a + c
        sw   $t2, 20($gp)
        addu $t2, $t3, $t3          # (7) c + c (addu con negativos)
        sw   $t2, 24($gp)
        slt  $t2, $t0, $t1          # (8) a < b ? (12 < 5)
        sw   $t2, 28($gp)
        slt  $t2, $t1, $t0          # (9) b < a ? (5 < 12)
        sw   $t2, 32($gp)
        slt  $t2, $t3, $t1          # (10) c < b ? (-3 < 5, con signo)
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
