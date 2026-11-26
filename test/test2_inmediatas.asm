# ======================================================================
# TEST 2 - Inmediatas: addi, addiu, slti, andi, ori, lui
#
# Instrucciones y casos que cubre:
#   - addi (positivo y negativo)
#   - addiu (con inmediato negativo)
#   - slti (verdadero, falso y con signo)
#   - andi y ori (extensión a cero del inmediato)
#   - lui (bit 31 en 1)
#   - syscall (imprimir carácter y terminar)
#
# Qué hace: calcula 10 resultados, los guarda con sw en el arreglo que
# empieza en $gp y al final los imprime en hexadecimal (8 dígitos por
# valor, 5 valores por línea). Si una instrucción falla, cambia el valor
# impreso en su posición.
# Orden de los valores: addi 100, addi -1, addiu 12-2, slti 12<13, 12<12, -1<0, andi, ori, andi con 0xff00, lui 0x8070.
#
# Salida esperada (2 líneas de 44 caracteres):
#   00000064 ffffffff 0000000a 00000001 00000000
#   00000001 00000008 0000f0fc 0000ff00 80700000
#
# Nota: usa la memoria desde $gp (0x1800) como zona de trabajo
# (resultados en gp+0..gp+39, pruebas de memoria en gp+256 y siguientes).
# ======================================================================
main:   addi $t0, $zero, 12         # t0 = 12
        addi $t3, $zero, -1         # t3 = -1 (0xffffffff)
        addi $t2, $zero, 100        # (1) addi positivo
        sw   $t2, 0($gp)
        addi $t2, $zero, -1         # (2) addi negativo
        sw   $t2, 4($gp)
        addiu $t2, $t0, -2          # (3) addiu: 12 + (-2)
        sw   $t2, 8($gp)
        slti $t2, $t0, 13           # (4) 12 < 13 ? (verdadero)
        sw   $t2, 12($gp)
        slti $t2, $t0, 12           # (5) 12 < 12 ? (falso)
        sw   $t2, 16($gp)
        slti $t2, $t3, 0            # (6) -1 < 0 ? (con signo, verdadero)
        sw   $t2, 20($gp)
        andi $t2, $t0, 10           # (7) 1100 AND 1010
        sw   $t2, 24($gp)
        ori  $t2, $t0, 0xf0f0       # (8) ori: el inmediato se extiende con ceros
        sw   $t2, 28($gp)
        andi $t2, $t3, 0xff00       # (9) andi: 0xffffffff AND 0x0000ff00
        sw   $t2, 32($gp)
        lui  $t2, 0x8070            # (10) lui: 0x80700000
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
