.global division

.data
menu_text:
    .asciz " || ----------------------------- \n"
    .asciz " ||                               \n"
    .asciz " || 1. Separados por Coma         \n"
    .asciz " || 2. Ingresar Numero por numero \n"
    .asciz " || \n"
    .asciz " || ----------------------------- \n"
    .asciz "\n"
    .asciz " || > Ingrese respuesta:  "
    .asciz "\n"

    lenmenu_text = .- menu_text

valoresComa:
    .ascii " || >Ingrese valores separados por coma: "
    lenvaloresComa = .- valoresComa

msg1:
    .ascii " || > Ingrese el primer valor: "
    lenMsg1 = .- msg1
msg2:
    .ascii " || > ngrese el segundo valor: "
    lenMsg2 = .- msg2
resultado:
    .ascii " || La division es: "
    lenResultado = .- resultado
     input_BuffUser: .skip 1

inputOperacion:
    .space 16
input1:
    .space 10
input2:
    .space 10
result:
    .space 12
newline:
    .ascii "\n"

.bss
opcion:
    .space 5

.text
.macro read reg, len
    MOV x0, 0
    LDR x1, =\reg
    MOV x2, \len
    MOV x8, 63
    SVC 0
.endm
            // retornar
division:
    // Mostrar menú
    mov x0, 1
    ldr x1, =menu_text
    mov x2, lenmenu_text
    mov x8, 64
    svc 0

    // Leer selección del usuario
    mov x0, 0
    ldr x1, =input1
    mov x2, 2
    mov x8, 63
    svc 0

    // Comprobar selección
    ldrb w0, [x1]
    cmp w0, '1'
    beq divicionComa
    cmp w0, '2'
    beq dividirUnoPorUno

    // Si la entrada no es válida, repetir menú
    b suma

divicionComa:
    // Mostrar mensaje de solicitud
    mov x0, 1
    ldr x1, =valoresComa
    mov x2, lenvaloresComa
    mov x8, 64
    svc 0

    // Leer la operación completa (5,5, por ejemplo)
    mov x0, 0
    ldr x1, =inputOperacion
    mov x2, 16
    mov x8, 63
    svc 0

    // Parsear la operación
    ldr x0, =inputOperacion
    bl parse_operacion

    // divir los dos números
    sdiv w7, w5, w6

    // Convertir resultado a cadena
    mov w0, w7
    ldr x1, =result
    bl itoa

    // Mostrar resultado
    mov x0, 1
    ldr x1, =resultado
    mov x2, lenResultado
    mov x8, 64
    svc 0

    mov x0, 1
    ldr x1, =result
    mov x2, 12
    mov x8, 64
    svc 0

    mov x0, 1
    ldr x1, =newline
    mov x2, 1
    mov x8, 64
    svc 0

    read opcion, 1

    b menu

dividirUnoPorUno:
    // Mostrar mensaje para el primer valor
    mov x0, 1
    ldr x1, =msg1
    mov x2, lenMsg1
    mov x8, 64
    svc 0

    // Leer primer valor
    mov x0, 0
    ldr x1, =input1
    mov x2, 10
    mov x8, 63
    svc 0

    // Mostrar mensaje para el segundo valor
    mov x0, 1
    ldr x1, =msg2
    mov x2, lenMsg2
    mov x8, 64
    svc 0

    // Leer segundo valor
    mov x0, 0
    ldr x1, =input2
    mov x2, 10
    mov x8, 63
    svc 0

    // Convertir entradas a enteros
    ldr x0, =input1
    bl atoi
    mov w5, w0

    ldr x0, =input2
    bl atoi
    mov w6, w0

    // dividir los dos números
    sdiv w7, w5, w6

    // Convertir resultado a cadena
    mov w0, w7
    ldr x1, =result
    bl itoa

    // Mostrar resultado
    mov x0, 1
    ldr x1, =resultado
    mov x2, lenResultado
    mov x8, 64
    svc 0

    mov x0, 1
    ldr x1, =result
    mov x2, 12
    mov x8, 64
    svc 0

    mov x0, 1
    ldr x1, =newline
    mov x2, 1
    mov x8, 64
    svc 0

    read opcion, 1

    b menu

// Funciones auxiliares: atoi, itoa, parse_operacion
atoi:
    mov w1, 0
atoi_loop:
    ldrb w2, [x0], 1
    sub w2, w2, '0'
    cmp w2, 9
    bhi atoi_end
    mov w3, 10
    mul w1, w1, w3
    add w1, w1, w2
    b atoi_loop
atoi_end:
    mov w0, w1
    ret

itoa:
    mov w2, 10
    add x1, x1, 11
    strb wzr, [x1]
itoa_loop:
    udiv w3, w0, w2
    msub w4, w3, w2, w0
    add w4, w4, '0'
    sub x1, x1, 1
    strb w4, [x1]
    mov w0, w3
    cbnz w0, itoa_loop
    ret

parse_operacion:
    mov w1, 0
    mov w2, 0
    mov w3, 0
parse_loop:
    ldrb w4, [x0], 1
    cmp w4, ','
    beq parse_after_comma
    cmp w4, 0
    beq parse_end
    cmp w3, 0
    bne parse_second_number
    sub w4, w4, '0'
    cmp w4, 9
    bhi parse_loop
    mov w5, 10
    mul w1, w1, w5
    add w1, w1, w4
    b parse_loop
parse_after_comma:
    mov w3, 1
    b parse_loop
parse_second_number:
    sub w4, w4, '0'
    cmp w4, 9
    bhi parse_loop
    mov w5, 10
    mul w2, w2, w5
    add w2, w2, w4
    b parse_loop
parse_end:
    mov w5, w1
    mov w6, w2
    ret
ret

