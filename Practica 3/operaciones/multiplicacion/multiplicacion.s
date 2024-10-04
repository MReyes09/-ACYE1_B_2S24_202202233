.global multiplicacion

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
    .ascii " || La multiplicacion es: "
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

multiplicacion:
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
    beq multiplicacionComa
    cmp w0, '2'
    beq multiplicarUnoPorUno

    // Si la entrada no es válida, repetir menú
    b suma

multiplicacionComa:
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

    // multiplicar los dos números
    mul w7, w5, w6

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

    b reiniciar_variables

multiplicarUnoPorUno:
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

    // multiplicar los dos números
    mul w7, w5, w6

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

    b reiniciar_variables

reiniciar_variables:
    // Limpiar input1
    ldr x0, =input1
    mov w1, #0          // Poner 0 (nulo)
    mov w2, #10         // Limitar a 10 bytes
    reset_input1:
        strb w1, [x0], #1   // Escribir 0 en cada byte del buffer
        subs w2, w2, #1
        b.ne reset_input1   // Si aún no hemos escrito en todos los bytes, repetir

        // Limpiar input2
        ldr x0, =input2
        mov w2, #10
    reset_input2:
        strb w1, [x0], #1
        subs w2, w2, #1
        b.ne reset_input2

        // Limpiar result
        ldr x0, =result
        mov w2, #12
    reset_result:
        strb w1, [x0], #1
        subs w2, w2, #1
        b.ne reset_result

        // Limpiar opcion (aunque no es necesario aquí, lo hago por consistencia)
        ldr x0, =inputOperacion
        mov w2, #5
    reset_opcion:
        strb w1, [x0], #1
        subs w2, w2, #1
        b.ne reset_opcion

    b menu
    
// Funciones auxiliares: atoi, itoa, parse_operacion
atoi:
    MOV w1, 0                // Inicializar el acumulador
    MOV w8, 0                // Inicializar w8

    LDRB w2, [x0], 1         // Cargar el byte y mover el puntero
    CMP w2, '-'              // Verificar si es un signo negativo
    BNE ver_negativo          // Si no es negativo, continuar
    MOV w8, 1                // Guardar el signo como negativo
    LDRB w2, [x0], 1         // Cargar el siguiente byte y mover el puntero

ver_negativo:
    SUB w2, w2, '0'          // Convertir el carácter a número
    CMP w2, 9                // Verificar si es un número (0-9)
    BHI atoi_end             // Si no es un número, saltar al final

atoi_loop:
    MOV w3, 10               // Multiplicador (base 10)
    MUL w1, w1, w3           // Multiplicar el resultado por 10
    ADD w1, w1, w2           // Sumar el dígito actual al acumulador
    LDRB w2, [x0], 1         // Cargar el siguiente byte y mover el puntero
    SUB w2, w2, '0'          // Convertir el carácter a número
    CMP w2, 9                // Verificar si es un número (0-9)
    BLS atoi_loop            // Si es un número, repetir el ciclo

atoi_end:
    CMP w8, 1                // Verificar si es negativo
    BNE atoi_pos             // Si no es negativo, continuar
    NEG w1, w1               // Si es negativo, convertir el resultado a negativo

atoi_pos:
    MOV w0, w1               // Guardar el resultado en w0
    RET                      // Retornar

// Función ITOA - para convertir números enteros a caracteres ASCII
itoa:
    CMP w0, #0              // Verificar si el número es negativo
    BGE cargar_positivo      // Si es positivo, se obvia la carga del signo

    NEG w0, w0              // Convertir el número a positivo
    MOV w9, '-'             // Cargar el carácter '-'
    STRB w9, [x1]           // Escribir el signo en la primera posición
    ADD x1, x1, 1           // Avanzar el puntero de la cadena

cargar_positivo:
    MOV w2, 10              // Cargar el divisor (base 10)
    ADD x1, x1, 11          // Avanzar el puntero de la cadena
    STRB wzr, [x1]          // Agregar un byte nulo al final de la cadena

itoa_loop:
    UDIV w3, w0, w2         // Dividir w0 entre w2, el resultado en w3 (decenas)
    MSUB w4, w3, w2, w0     // w4 = w0 - (w3 * w2), calcular el resto (unidades)
    ADD w4, w4, '0'         // Convertir el dígito de las decenas a ASCII
    SUB x1, x1, 1           // Retroceder el puntero de la cadena
    STRB w4, [x1]           // Almacenar el dígito en la cadena
    MOV w0, w3              // Cargar el resultado de la división
    CBNZ w0, itoa_loop      // Si w0 no es cero, repetir el ciclo

    RET                     // Retornar
parse_operacion:
    mov w1, 0          // Primer número
    mov w2, 0          // Segundo número
    mov w3, 0          // Indica si ya se pasó la coma (0 = primer número, 1 = segundo número)
    mov w7, 0          // Indicador de signo del primer número (0 = positivo, 1 = negativo)
    mov w8, 0          // Indicador de signo del segundo número (0 = positivo, 1 = negativo)

parse_loop:
    ldrb w4, [x0], 1   // Cargar el siguiente byte del string
    cmp w4, ','        // Comparar con la coma
    beq parse_after_comma
    cmp w4, 0          // Comparar con el fin de cadena (NULL)
    beq parse_end

    // Verificar si es un signo negativo antes de un número
    cmp w4, '-'
    bne check_digit    // Si no es '-', saltar para verificar si es un dígito
    cmp w3, 0          // Si aún estamos en el primer número
    bne set_negative_second
    mov w7, 1          // El primer número es negativo
    b parse_loop       // Continuar el ciclo

set_negative_second:
    mov w8, 1          // El segundo número es negativo
    b parse_loop       // Continuar el ciclo

check_digit:
    cmp w3, 0
    bne parse_second_number
    sub w4, w4, '0'    // Convertir carácter a dígito
    cmp w4, 9          // Verificar si es un dígito válido
    bhi parse_loop     // Si es mayor que 9, saltar
    mov w5, 10
    mul w1, w1, w5
    add w1, w1, w4     // Acumular el primer número
    b parse_loop

parse_after_comma:
    mov w3, 1          // Indicar que estamos en el segundo número
    b parse_loop

parse_second_number:
    sub w4, w4, '0'    // Convertir carácter a dígito
    cmp w4, 9          // Verificar si es un dígito válido
    bhi parse_loop
    mov w5, 10
    mul w2, w2, w5
    add w2, w2, w4     // Acumular el segundo número
    b parse_loop

parse_end:
    cmp w7, 0          // Verificar si el primer número es negativo
    beq skip_neg1
    neg w1, w1         // Hacer el primer número negativo
skip_neg1:
    cmp w8, 0          // Verificar si el segundo número es negativo
    beq skip_neg2
    neg w2, w2         // Hacer el segundo número negativo
skip_neg2:
    mov w5, w1         // Mover el primer número al registro de salida
    mov w6, w2         // Mover el segundo número al registro de salida
    ret
    