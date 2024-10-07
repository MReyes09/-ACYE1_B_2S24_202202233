

// funciones globales
.global lecturaConsola


// ----------------------- Declaramos las variables -----------------------
.data 

menu_LecturaConsola:
    .asciz " || ------------------------------------------------------ \n"
    .asciz " || Menu de Ingreso de Numeros\n"
    .asciz " || ------------------------------------------------------ \n"
    .asciz " || Ingrese los numeros separados por comas: "
lenMenuLecturaConsola = .-menu_LecturaConsola

msg_success:
    .asciz " || Ingreso exitoso\n"
lenMsgSuccess = .- msg_success

seleccion_text: 
    .asciz " || > Selecciona una opcion: "
lenSeleccion = .- seleccion_text

arrayinicial:
    .asciz " || Arreglo base: "
lenArrayInicial = .- arrayinicial

numeroiteracion:
    .asciz " || No. Paso: "
lenNumeroIteracion = .- numeroiteracion

arrayfinal:
    .asciz " || Arreglo ordenado: "
lenArregloOrdenado = .- arrayfinal

enter:        
    .asciz " || Presiona Enter para continuar...\n"
lenEnter = .- enter

modelo:
    .asciz " || "
    lenModelo = .- modelo

salto:
    .asciz "\n"
    lenSalto = .- salto

espacio:
    .asciz " "
    lenEspacio = .- espacio

clear_screen:   
    .asciz "\033[2J\033[H"  // Código ANSI para limpiar pantalla
    lenClearScreen = .- clear_screen

dospuntos:
    .asciz "-> "
lenDosPuntos = .- dospuntos

// ----------------------- Fin de la declaracion de variables -----------------------

//  ----------------------- Declaracion de variables -----------------------
.bss

numero:
    .space 12

arrayconsola:
    .space 1024

inputEnter:
    .space 2

//------------------------- Fin de declaracion de variables -------------------------

.text 

// ----------------------- Macro print --------------------------------
.macro print stdout, reg, len
    MOV x0, \stdout
    LDR x1, =\reg
    MOV x2, \len
    MOV x8, 64
    SVC 0
.endm

// Macro para leer datos del usuario
.macro read stdin, buffer, len
    MOV x0, \stdin
    LDR x1, =\buffer
    MOV x2, \len
    MOV x8, 63
    SVC 0
.endm

.macro clean_arr arreglo

    LDR x0, =\arreglo
    MOV x1, 256

.endm

// ----------------------- Fin de la macro print -----------------------

// ----------------------- Funcion lecturaConsola -----------------------

lecturaConsola:
    print 1, clear_screen, lenClearScreen

    // Imprimimos el menu de lectura de consola
    print 1, menu_LecturaConsola, lenMenuLecturaConsola

    //solicitamos respuesta
    read 0, arrayconsola, 1024

    LDR x10, =numero            // se carga la direccion de memoria de numero en x10
    LDR x11, =arrayconsola      // se carga la direccion de memoria de arrayconsola en x11
    MOV w3, 0                   // se carga el valor 0 en w3

// ----------------------- Fin de la funcion lecturaConsola -----------------------

// ----------------------- Funcion leer_Consola -----------------------
leer_Consola:

    LDRB w3, [x11], 1          // se carga el valor de la direccion de memoria de x11 en w3 y se incrementa la direccion
    CMP w3, 44                 // se compara si el valor es una coma
    BEQ conver_num_Consola    // si es una coma, se salta a conver_num_Consola

    CBZ w3, conver_num_Consola

    STRB w3, [x10], 1          // se guarda el valor en la direccion de memoria de x10 y se incrementa la direccion
    b leer_Consola

conver_num_Consola:
    
    ldr x5, =numero             // se carga la direccion de memoria de numero en x5
    ldr x8, =numero                // se carga la direccion de memoria de num en x6
    ldr x12, =array             // se carga la direccion de memoria de array en x7

    STP x29, x30, [sp, -16]! // se guarda el valor de x29 y x30 en la pila

    BL atoi // se llama a la funcion atoi para convertir el numero

    LDP x29, x30, [sp], 16 // se recupera el valor de x29 y x30 de la pila

    LDR x12, =numero            // se carga la direccion de memoria de numero en x12
    MOV w13, 0                  // se carga el numero 0 en w13
    MOV x14, 0                  // se carga el numero 0 en x14

limpiar_num:

    strb w13, [x12], 1          // se guarda el valor en la direccion de memoria de x12 y se incrementa la direccion
    add x14, x14, 1             // se incrementa el contador de digitos
    cmp x14, 6                 // se compara si el contador de digitos es igual a 6
    BNE limpiar_num             // si no es igual a 6, se salta a limpiar_num

    ldr x10, =numero            // se carga la direccion de memoria de numero en x10
    cbnz w3, leer_Consola       // si w3 es diferente de 0, se salta a leer_Consola

finalizar:

    mov x3, #1                 // se carga el valor 1 en x3
    ldr x2, =ingreso_array     // se carga la direccion de memoria de ingreso_array en x2
    str x3, [x2]               // se guarda el valor en la direccion de memoria de x2

    print 1, clear_screen, lenClearScreen
    print 1, msg_success, lenMsgSuccess

    // recorrer array y convertir a ascii
    LDR x9, =count
    LDR x9, [x9] // length => cantidad de numeros leidos del csv
    MOV x7, 0
    LDR x15, =array

    // Imprimir el mensaje modelo antes de mostrar los números
    print 1, modelo, lenModelo

    loop_array:
        LDR w0, [x15], 4
        LDR x1, =num
        BL itoa
        
        print 1, num, x10
        print 1, espacio, lenEspacio
    
        ADD x7, x7, 1
        CMP x9, x7
        BNE loop_array
    
    print 1, salto, lenSalto 

    print 1, enter, lenEnter
    read 0, inputEnter, 2

    b menu



// ----------------------- Fin de la funcion leer_Consola -----------------------

atoi:
    // params: x5, x8 => buffer address, x12 => result address
    SUB x5, x5, 1
    a_c_digits:
        LDRB w7, [x8], 1
        CBZ w7, a_c_convert
        CMP w7, 10
        BEQ a_c_convert
        B a_c_digits

    a_c_convert:
        SUB x8, x8, 2
        MOV x4, 1
        MOV x9, 0

        a_c_loop:
            LDRB w7, [x8], -1
            CMP w7, 45
            BEQ a_c_negative

            SUB w7, w7, 48
            MUL w7, w7, w4
            ADD w9, w9, w7

            MOV w6, 10
            MUL w4, w4, w6

            CMP x8, x5
            BNE a_c_loop
            B a_c_end

        a_c_negative:
            NEG w9, w9

        a_c_end:
            LDR x13, =count
            LDR x13, [x13] // saltos
            MOV x14, 4
            MUL x14, x13, x14

            STR w9, [x12, x14] // usando 32 bits

            ADD x13, x13, 1
            LDR x12, =count
            STR x13, [x12]

            RET

itoa:

    MOV x10, 0                 // se carga el valor 0 en x10, se usara para contar los digitos a imprimir
    MOV x12, 0                 // se carga el valor 0 en x12, se usara para saber si es negativo el numero
    MOV w2, 10000              // se carga el valor 10000 en w2, se usara para dividir el numero
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

    CBNZ w10, itoa_addzero // si el contador de digitos es 0, se agrega un 0 al numero
    B itoa_c_ascii

itoa_addzero:

    CBNZ w3, itoa_c_ascii         // si el cociente es diferente de 0, se termina la conversion
    ADD x10, x10, 1               // se incrementa el contador de digitos
    MOV w5, 48                    // se carga el valor 48 en w5, es el ascii del numero 0
    STRB w5, [x1], 1              // se guarda el valor en la direccion de memoria y se incrementa la direccion
    B itoa_c_ascii

itoa_end:

    ADD x10, x10, x12           // se incrementa el contador de digitos si es negativo
    //print 1,numero, x10           // se imprime el numero
    RET

