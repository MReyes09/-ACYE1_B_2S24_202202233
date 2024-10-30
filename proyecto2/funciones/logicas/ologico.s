.global Proc_ORLogico
.extern excel
.extern atoi
.extern itoa

.data

    salto:
        .asciz "\n"
        lenSalto = .- salto

    tabulador:
        .asciz "\t"
        lenTabulador = .- tabulador

    comandoY:
        .asciz "Y"
        lenComandoY = .- comandoY
    
    mensajeOR:
        .asciz " || Operacion OR realizada con exito\n"
        lenMensajeOR = .- mensajeOR
    
    errorOR:
        .asciz " || Error en el OR\n"
        lenErrorOR = .- errorOR

    enter2:        
    .asciz " || Presiona Enter para continuar...\n"
    lenEnter2 = .- enter2

.text

.macro print reg, len

    MOV x0, 1
    LDR x1, =\reg
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

Proc_ORLogico:

    STP x29, x30, [sp, -16]!    // Se guarda el puntero de pila

    LDR x0, =cmdOrLogico
    LDR x1, =bufferComando

    //Comparacion de mensaje con comando Suma

    oLoop:
        LDRB w2, [x0], 1        // Cargamos el caracter de x0 en w2
        LDRB w3, [x1], 1        // Cargamos el caracter de x1 en w3

        CBZ w2, ORguardar_first_val      // Si w2 es 0, saltar a guardarSumaVal

        CMP w2, w3              // Comparamos w2 con w3
        BNE or_error          // Si no son iguales, saltar a or_error

        B oLoop          // Si no se cumple la condicion, repetir el ciclo

    // Se obtiene el primer valor de la suma
    ORguardar_first_val:

        MOV x23, 0              // Se usa como flag para saber si se encontro una columna | 0 = No se encontro, 1 = Se encontro

        MOV x24, 0              // Se usa como flag para saber si se encontro un valor o celda | 0 = No se encontro, 1 = Se encontro

        LDR x5, =colum        // Se carga la direccion de memoria de la variable colum en x5
        LDR x6, =row           // Se carga la direccion de memoria de la variable row en x6

        or_first_Loop:

            LDRB w2, [x1], 1    // Se carga el primer byte del comando del usuario en w2

            CMP w2, 32          // Se compara si el byte es un espacio
            BEQ or_confirmar

            CMP w2, 65          // Se compara si el byte es una A
            BGE or_first_column

            CMP w2, 48          // Se compara si el byte es un 0
            BGE or_first_value

            CMP w2, 45          // Se compara si el byte es un guion
            BEQ or_conf_neg

            B or_error

            or_first_column:

                CMP w2, 75      // Se compara si el byte es una K
                BGT or_error

                SUB w2, w2, 65      // Se convierte la letra a un numero
                STRB w2, [x5], 1    // Se guarda el valor en la variable colum
                MOV x23, 1          // Se activa el flag para saber que se encontro una columna

                B or_first_Loop
            
            or_conf_neg:

                CBNZ x23, or_error    // Si ya se encontro una columna entonces no puede haber un valor negativo

                STRB w2, [x6], 1    // Se guarda el valor en la variable row

                B or_first_Loop
            
            or_first_value:

                CMP w2, 57      // Se compara si el byte es un 9
                BGT or_error

                STRB w2, [x6], 1    // Se guarda el valor en la variable row
                MOV x24, 1          // Se activa el flag para saber que se encontro un valor o celda

                B or_first_Loop
    
    // Se confirma si el comando esta completo
    or_confirmar:

        CBZ x24, or_error     // si no encontro ningun valor (ya sea fila o valor inmediato) entonces se supone que columna tampoco y tira error

        LDR x0, =comandoY       // Se carga la direccion de memoria del comando "Y" en x0

        or_conf_Loop:

            LDRB w2, [x0], 1    // Se carga el primer byte del comando del usuario en w2
            LDRB w3, [x1], 1    // Se carga el primer byte del comando "Y" en w3

            CBZ w2, ORguardar_second_val    // Si el byte del comando del usuario es 0 entonces se sale del loop

            CMP w2, w3           // Se compara si los bytes son iguales
            BNE or_error      // Si no son iguales, se pasa con el siguiente procedimiento

            B or_conf_Loop
    
    // Se guarda el segundo valor de la suma
    ORguardar_second_val:

        MOV x25, 0              // Se usa como flag para saber si se encontro una columna | 0 = No se encontro, 1 = Se encontro
        MOV x24, 0              // Se usa como flag para saber si se encontro un valor o celda | 0 = No se encontro, 1 = Se encontro

        LDR x5, =colum2       // Se carga la direccion de memoria de la variable colum2 en x5
        LDR x6, =row2          // Se carga la direccion de memoria de la variable row2 en x6

        or_second_Loop:

            LDRB w2, [x1], 1    // Se carga el primer byte del comando del usuario en w2

            CMP w2, 32          // Se compara si el byte es un espacio
            BEQ OR_Ejecutar

            CMP w2, 10          // Se compara si el byte es un salto de linea
            BEQ OR_Ejecutar

            CMP w2, 65          // Se compara si el byte es una A
            BGE or_second_column

            CMP w2, 48          // Se compara si el byte es un 0
            BGE or_second_value

            CMP w2, 45          // Se compara si el byte es un guion
            BEQ or_conf_neg2

            B or_error

            or_second_column:

                CMP w2, 75      // Se compara si el byte es una K
                BGT or_error

                SUB w2, w2, 65      // Se convierte la letra a un numero
                STRB w2, [x5], 1    // Se guarda el valor en la variable colum2
                MOV x25, 1          // Se activa el flag para saber que se encontro una columna

                B or_second_Loop

            or_conf_neg2:

                CBNZ x25, or_error    // Si ya se encontro una columna entonces no puede haber un valor negativo

                STRB w2, [x6], 1    // Se guarda el valor en la variable row

                B or_second_Loop
            
            or_second_value:

                CMP w2, 57      // Se compara si el byte es un 9
                BGT or_error

                STRB w2, [x6], 1    // Se guarda el valor en la variable row2
                MOV x24, 1          // Se activa el flag para saber que se encontro un valor o celda

                B or_second_Loop
    
    // Se ejecuta la suma
    OR_Ejecutar:

        LDR x20, =arreglo        // Se carga la direccion de memoria de la arreglo en x20

        // Parametros: x23 = flag columna1, x25 = flag columna2, x24 = flag valor1 y valor2

        CBZ x24, or_error     // Si no encontro ningun valor (ya sea fila o valor inmediato) entonces se supone que columna tampoco y tira error

        // ------------------------------- COMPARACIONES PARA EL PRIMER VALOR ------------------------------- 

        CBZ x23, val1_inmediato_or    // Si no se encontro una columna entonces se asume que es un valor inmediato

        // ------------------------ ACCESO A CELDA 1 ------------------------

        LDR x5, =row          // Se carga la direccion de memoria de la variable row en x5
        LDR x8, =row          // Se carga la direccion de memoria de la variable row en x8

        STP x29, x30, [sp, -16]! // Se guarda la direccion de memoria de la arreglo y la fila en la pila
        BL atoi
        LDP x29, x30, [sp], 16   // Se recupera la direccion de memoria de la arreglo y la fila de la pila

        LDR x5, =colum       // Se carga la direccion de memoria de la variable colum2 en x5
        LDRB w16, [x5]         // Se carga el valor de la variable colum en w16

        SUB x9, x9, 1
        MOV x22, 12             // NUMERO DE COLUMNAS = 12
        MUL x22, x9, x22        // (FILA A ACCEDER)(NUMERO DE COLUMNAS)
        ADD x22, x16, x22       // (FILA A ACCEDER)(NUMERO DE COLUMNAS) + COLUMNA A ACCEDER -> INDEX POR ROW MAJOR

        LDR x21, [x20, x22, LSL 3]  // Se carga el valor de la celda en x21

        LDR x19, =retorno           // Se carga la direccion de memoria de la variable retorno en x19
        STR x21, [x19]              // Se guarda el valor de la celda en la variable retorno

        B or_operador2

        val1_inmediato_or:

            LDR x5, =row       // Se carga la direccion de memoria de la variable row en x5
            LDR x8, =row       // Se carga la direccion de memoria de la variable row en x8

            STP x29, x30, [sp, -16]!
            BL atoi
            LDP x29, x30, [sp], 16

            LDR x19, =retorno    // Se carga la direccion de memoria de la variable retorno en x19
            STR x9, [x19]        // Se guarda el valor de la variable row en la variable retorno
        
        or_operador2:

            // ------------------------------- COMPARACIONES PARA EL SEGUNDO VALOR -------------------------------

            CBZ x25, val2_inmediato_or    // Si no se encontro una columna entonces se asume que es un valor inmediato

            // ------------------------ ACCESO A CELDA 2 ------------------------

            LDR x5, =row2          // Se carga la direccion de memoria de la variable row2 en x5
            LDR x8, =row2          // Se carga la direccion de memoria de la variable row2 en x8

            STP x29, x30, [sp, -16]! // Se guarda la direccion de memoria de la arreglo y la fila en la pila
            BL atoi
            LDP x29, x30, [sp], 16   // Se recupera la direccion de memoria de la arreglo y la fila de la pila

            LDR x5, =colum2       // Se carga la direccion de memoria de la variable colum2 en x5
            LDRB w16, [x5]          // Se carga el valor de la variable colum en w16

            SUB x9, x9, 1
            MOV x22, 12             // NUMERO DE COLUMNAS = 12
            MUL x22, x9, x22        // (FILA A ACCEDER)(NUMERO DE COLUMNAS)
            ADD x22, x16, x22       // (FILA A ACCEDER)(NUMERO DE COLUMNAS) + COLUMNA A ACCEDER -> INDEX POR ROW MAJOR

            LDR x21, [x20, x22, LSL 3]  // Se carga el valor de la celda en x21

            B or_End

            val2_inmediato_or:

                LDR x5, =row2       // Se carga la direccion de memoria de la variable row2 en x5
                LDR x8, =row2       // Se carga la direccion de memoria de la variable row2 en x8

                STP x29, x30, [sp, -16]!
                BL atoi
                LDP x29, x30, [sp], 16

                MOV x21, x9
        
        or_End:

            LDR x19, =retorno
            LDR x18, [x19]

            ORR x21, x18, x21       // Se nultiplican los valores de las celdas o inmediatos

            STR x21, [x19]          // Se guarda el resultado en la variable retorno

            print mensajeOR, lenMensajeOR

            print enter2, lenEnter2

            LDR x27, =buffer
            read 0, x27, 4

            LDP x29, x30, [sp], 16  // Se recupera el puntero de pila

            Bl excel
    
    or_error:

        print errorOR, lenErrorOR
        print enter2, lenEnter2

        LDR x27, =buffer
        read 0, x27, 4

        LDP x29, x30, [sp], 16  // Se recupera el puntero de pila

        BL excel

