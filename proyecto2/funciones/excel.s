// El registro x27 sera exclusivo para almacenar direccion de memoria de los mensajes
// El registro x26 sera exclusovo para almacenar direccion de memoria del tamaño de los mensajes

.global excel, itoa
.extern findComand, clear_buffer

.text

.macro print stdout, reg, len
    MOV x0, \stdout
    MOV x1, \reg
    MOV x2, \len
    MOV x8, 64
    SVC 0
.endm

.macro read stdin, reg, len
    MOV x0, \stdin
    MOV x1, \reg
    MOV x2, \len
    MOV x8, 63
    SVC 0
.endm

excel:

    Bl Clean_var

    LDR x27, =clearScreen
    LDR x26, =lenClear

    print 1, x27, x26

    BL clear_buffer

    STP x29, x30, [sp, -16]!

    BL print_matrix

    LDP x29, x30, [sp], 16

    ldr x27, =mensajeComandos
    ldr x26, =lenMensajeComandos
    print 1, x27, x26

    LDR x27, =bufferComando
    LDR x26, =50
    read 0, x27, x26

    STP x29, x30, [SP, -16]!
    bl findComand
    LDP x29, x30, [SP], 16

    bl excel

// -------------------------- FUNCION PRINT_MATRIX --------------------------
print_matrix:

    STP x29, x30, [sp, -16]!
    LDR x4, =arreglo    // cargar dirección de la matriz
    MOV x9, 0  // index de slots
    MOV x7, 0 // Contador de filas
    LDR x18, =cols
    LDR x19, =val
    
    LDR x27, =separador
    LDR x26, =lenSeparador

    print 1, x27, x26

    printCols:
        LDRB w20, [x18], 1
        STRB w20, [x19]

        LDR x27, =val
        print 1, x27, 1

        LDR x27, =espacio
        LDR x26, =lenEspacio
        print 1, x27, x26

        ADD x7, x7, 1
        CMP x7, 12
        BNE printCols
        LDR x27, =salto
        LDR x26, =lenSalto
        print 1, x27, x26
    
    MOV x7, 0               // Inicializar el contador de filas
    mov x11, 0            // Dirección base para almacenar el valor ASCII

    loop1:                // Loop para recorrer las filas
        
        ADD x11, x11, 1
        MOV x0, x11
        LDR x1, =num
        BL itoa

        LDR x27, =espacio
        LDR x26, =lenEspacio
        print 1, x27, x26  // Imprimir un espacio antes del número de fila

        MOV x13, 0           // Inicializar el contador de columnas

        loop2:          // Loop para recorrer las columnas

            MOV x15, 0
            LDR x15, [x4, x9, LSL 3]  // Cargar el valor de la matriz

            MOV x0, x15
            LDR x1, =num
            BL itoa
            LDR x27, =espacio
            LDR x26, =lenEspacio
            print 1, x27, x26  // Imprimir un espacio antes del número de fila

            ADD x9, x9, 1
            ADD x13, x13, 1
            CMP x13, 11
            BNE loop2
        
        LDR x27, =salto
        LDR x26, =lenSalto
        print 1, x27, x26  // Imprimir un salto de línea

        ADD x9, x9, 1
        ADD x7, x7, 1
        CMP x7, 23
        BNE loop1
        LDP x29, x30, [sp], 16
        RET

// -------------------------- FUN FUNCIÓN PRINT_MATRIX --------------------------

// -------------------------- FUN FUNCIÓN ITOA --------------------------
itoa:
    STP x0, x1, [sp, -16]!    // se guarda el valor de x0 y x1 en la pila
    STP x2, x3, [sp, -16]!    // se guarda el valor de x2 y x3 en la pila
    STP x4, x5, [sp, -16]!    // se guarda el valor de x4 y x5 en la pila
    STP x6, x7, [sp, -16]!    // se guarda el valor de x6 y x7 en la pila
    STP x8, x9, [sp, -16]!    // se guarda el valor de x8 y x9 en la pila
    STP x10, x11, [sp, -16]!  // se guarda el valor de x10 y x11 en la pila
    STP x12, x13, [sp, -16]!  // se guarda el valor de x12 y x13 en la pila

    MOV x10, 0                 // se carga el valor 0 en x10, se usara para contar los digitos a imprimir
    MOV x11, 0                 // se carga el valor 0 en x11, se usara como flag para saber si es de 6 cifras o mas
    MOV x12, 0                 // se carga el valor 0 en x12, se usara para saber si es negativo el numero
    MOV w2, 10000              // se carga el valor 100000 en w2, se usara para dividir el numero
    CMP w0, 0                  // se compara si el numero es 0
    BGT itoa_c_ascii           // si es mayor a 0, se convierte a ASCII
    CBZ w0, itoa_zero          // si es menor a 0, se envia a itoa zero

    B itoa_negativo

    itoa_zero:

        ADD x10, x10, #1            // se incrementa el contador de digitos
        MOV w5, 48                  // se carga el valor 48 en w5, es el ascii del numero 0
        STRB w5, [x1], 1            // se guarda el valor en la direccion de memoria y se incrementa la direccion
        B itoa_end

    itoa_negativo:

        MOV x12, #1                 // se carga el valor 1 en x12, para indicar que es negativo
        MOV w5, 45                  // se carga el valor 45 en w5, es el ascii del negativo
        STRB w5, [x1], 1            // se guarda el valor en la direccion de memoria y se incrementa la direccion
        NEG w0, w0                  // se convierte el numero a positivo

    itoa_c_ascii:

        CBZ w2, itoa_end            // si el divisor es 0, se termina la conversion
        UDIV w3, w0, w2             // se divide el numero entre el divisor (w3 = w0/w2)
        CBZ w3, itoa_reducebase     // si el cociente es 0, se reduce la base

        CMP w3, 10                  // se compara si el cociente es mayor o igual a 10
        BGE itoa_reducenum         // si es mayor o igual a 10, se reduce la base

        MOV w5, w3                  // se carga el cociente en w5
        ADD w5, w5, 48              // se convierte el cociente a ASCII
        STRB w5, [x1], 1            // se guarda el valor en la direccion de memoria y se incrementa la direccion
        ADD x10, x10, #1            // se incrementa el contador de digitos

        MUL w3, w3, w2              // se multiplica el cociente por el divisor
        SUB w0, w0, w3              // se resta el cociente al numero, para eliminar el caracter eliminado

        CMP w2, 1                   // se compara si el divisor es 1
        BLE itoa_end                // si es menor o igual a 1, se termina la conversion

        itoa_reducebase:

            MOV w6, 10                  // se carga el valor 10 en w6
            UDIV w2, w2, w6             // se divide el divisor entre 10, para reducir la base

            CBNZ w10, itoa_addzero      // si el contador de digitos es 0, se agrega un 0 al numero
            B itoa_c_ascii
        
        itoa_reducenum:

            MOV w6, 10                  // se carga el valor 10 en w6
            UDIV w0, w0, w6             // se divide el numero entre 10, para reducir el numero

            MOV x11, 1                  // se carga el valor 1 en x11, para indicar que es de 6 cifras o mas
            B itoa_c_ascii

        itoa_addzero:

            CBNZ w3, itoa_c_ascii         // si el cociente es diferente de 0, se termina la conversion
            ADD x10, x10, 1               // se incrementa el contador de digitos
            MOV w5, 48                    // se carga el valor 48 en w5, es el ascii del numero 0
            STRB w5, [x1], 1              // se guarda el valor en la direccion de memoria y se incrementa la direccion
            B itoa_c_ascii

    itoa_end:

        CBZ x11, print_num

        MOV w5, 33                  // se carga el valor 33 en w5, es el ascii del signo de exclamacion
        STRB w5, [x1], 1            // se guarda el valor en la direccion de memoria y se incrementa la direccion
        ADD x10, x10, 1             // se incrementa el contador de digitos

        print_num:

            ADD x10, x10, x12
            LDR x27, =num
            print 1, x27, x10

            LDR x12, =num
            MOV w13, 0
            MOV x14, 0

            clean_itoa_number:

                STRB w13, [x12], 1
                ADD x14, x14, 1
                CMP x14, 8
                BNE clean_itoa_number

    LDP x12, x13, [sp], 16    // se recupera el valor de x12 y x13 de la pila
    LDP x10, x11, [sp], 16    // se recupera el valor de x10 y x11 de la pila
    LDP x8, x9, [sp], 16      // se recupera el valor de x8 y x9 de la pila
    LDP x6, x7, [sp], 16      // se recupera el valor de x6 y x7 de la pila
    LDP x4, x5, [sp], 16      // se recupera el valor de x4 y x5 de la pila
    LDP x2, x3, [sp], 16      // se recupera el valor de x0 y x1 de la pila
    LDP x0, x1, [sp], 16      // se recupera el valor de x0 y x1 de la pila

    RET

// -------------------------- FUN FUNCIÓN ITOA --------------------------

Clean_var:

    STP x29, x30, [sp, -16]!

    LDR x0, =colum
    LDR x2, =colum2
    MOV x1, 0

    clean_byte:

        STRB WZR, [x0], 1
        STRB WZR, [x2], 1
        ADD x1, x1, 1
        CMP x1, 2
        BNE clean_byte
    
    LDR x0, =row
    LDR x2, =row2
    MOV x1, 0
    
    clean_byte2:

        STRB WZR, [x0], 1
        STRB WZR, [x2], 1
        ADD x1, x1, 1
        CMP x1, 20
        BNE clean_byte2

    LDP x29, x30, [sp], 16

    RET
