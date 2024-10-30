.global multiplicacionCMP
.extern excel, atoi

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

multiplicacionCMP:

    STP x29, x30, [sp, -16]!    // Se guarda el puntero de pila

    LDR x0, =cmdMultiplicacion
    LDR x1, =bufferComando

    //Comparacion de mensaje con comando Suma

    mulLoop:
        LDRB w2, [x0], 1        // Cargamos el caracter de x0 en w2
        LDRB w3, [x1], 1        // Cargamos el caracter de x1 en w3

        CBZ w2, guardarMulVal      // Si w2 es 0, saltar a guardarMulVal

        CMP w2, w3              // Comparamos w2 con w3
        BNE mulError         // Si w2 es diferente a w3, saltar a mulError

        B mulLoop          // Si no se cumple la condicion, repetir el ciclo

    // Se obtiene el primer valor de la suma
    guardarMulVal:

        MOV x27, 0              // Se usa como flag para saber si se encontro una columna | 0 = No se encontro, 1 = Se encontro
        MOV x26, 0
        MOV x23, 0              // Se usa como flag para saber si se encontro una columna | 0 = No se encontro, 1 = Se encontro

        MOV x24, 0              // Se usa como flag para saber si se encontro un valor o celda | 0 = No se encontro, 1 = Se encontro

        LDR x5, =colum        // Se carga la direccion de memoria de la variable colum en x5
        LDR x6, =row           // Se carga la direccion de memoria de la variable row en x6

        guardarMulValLoop:

            LDRB w2, [x1], 1    // Se carga el primer byte del comando del usuario en w2

            CMP w2, 32          // Se compara si el byte es un espacio
            BEQ mulConf

            CMP w2, 65          // Se compara si el byte es una A
            BGE mulFirtCol

            CMP w2, 48          // Se compara si el byte es un 0
            BGE mulFirstVal

            CMP w2, 45          // Se compara si el byte es un guion
            BEQ mulConfNeg

            B mulError

            mulFirtCol:

                CMP w2, 75      // Se compara si el byte es una K
                BGT mulError

                SUB w2, w2, 65      // Se convierte la letra a un numero
                STRB w2, [x5], 1    // Se guarda el valor en la variable colum
                MOV x23, 1          // Se activa el flag para saber que se encontro una columna

                B guardarMulValLoop
            
            mulConfNeg:

                CBNZ x23, mulError    // Si ya se encontro una columna entonces no puede haber un valor negativo

                STRB w2, [x6], 1    // Se guarda el valor en la variable row

                B guardarMulValLoop
            
            mulFirstVal:

                CMP w2, 57      // Se compara si el byte es un 9
                BGT mulError

                STRB w2, [x6], 1    // Se guarda el valor en la variable row
                MOV x24, 1          // Se activa el flag para saber que se encontro un valor o celda

                B guardarMulValLoop
    
    // Se confirma si el comando esta completo
    mulConf:

        CBZ x24, mulError     // si no encontro ningun valor (ya sea fila o valor inmediato) entonces se supone que columna tampoco y tira error

        LDR x0, =cmdsepY       // Se carga la direccion de memoria del comando "Y" en x0

        mulConfLoop:

            LDRB w2, [x0], 1    // Se carga el primer byte del comando del usuario en w2
            LDRB w3, [x1], 1    // Se carga el primer byte del comando "Y" en w3

            CBZ w2, guardarMulSecVal    // Si el byte del comando del usuario es 0 entonces se sale del loop

            CMP w2, w3          // Se compara si los bytes son iguales
            BNE mulError      // Si no son iguales, se pasa con el siguiente procedimiento

            B mulConfLoop
    
    // Se guarda el segundo valor de la suma
    guardarMulSecVal:

        MOV x25, 0              // Se usa como flag para saber si se encontro una columna | 0 = No se encontro, 1 = Se encontro
        MOV x24, 0              // Se usa como flag para saber si se encontro un valor o celda | 0 = No se encontro, 1 = Se encontro

        LDR x5, =colum2       // Se carga la direccion de memoria de la variable colum2 en x5
        LDR x6, =row2          // Se carga la direccion de memoria de la variable row2 en x6

        mul_second_Loop:

            LDRB w2, [x1], 1    // Se carga el primer byte del comando del usuario en w2

            CMP w2, 32          // Se compara si el byte es un espacio
            BEQ Mul_Ejecutar

            CMP w2, 10          // Se compara si el byte es un salto de linea
            BEQ Mul_Ejecutar

            CMP w2, 65          // Se compara si el byte es una A
            BGE mul_second_column

            CMP w2, 48          // Se compara si el byte es un 0
            BGE mul_second_value

            CMP w2, 45          // Se compara si el byte es un guion
            BEQ mul_conf_neg2

            B mulError

            mul_second_column:

                CMP w2, 75      // Se compara si el byte es una K
                BGT mulError

                SUB w2, w2, 65      // Se convierte la letra a un numero
                STRB w2, [x5], 1    // Se guarda el valor en la variable colum2
                MOV x25, 1          // Se activa el flag para saber que se encontro una columna

                B mul_second_Loop
            
            mul_conf_neg2:

                CBNZ x25, mulError    // Si ya se encontro una columna entonces no puede haber un valor negativo

                STRB w2, [x6], 1    // Se guarda el valor en la variable row

                B mul_second_Loop
            
            mul_second_value:

                CMP w2, 57      // Se compara si el byte es un 9
                BGT mulError

                STRB w2, [x6], 1    // Se guarda el valor en la variable row2
                MOV x24, 1          // Se activa el flag para saber que se encontro un valor o celda

                B mul_second_Loop
    
    // Se ejecuta la suma
    Mul_Ejecutar:

        LDR x20, =arreglo        // Se carga la direccion de memoria de la arreglo en x20

        // Parametros: x23 = flag columna1, x25 = flag columna2, x24 = flag valor1 y valor2

        CBZ x24, mulError     // Si no encontro ningun valor (ya sea fila o valor inmediato) entonces se supone que columna tampoco y tira error

        // ------------------------------- COMPARACIONES PARA EL PRIMER VALOR ------------------------------- 

        CBZ x23, val_inmediato_mul    // Si no se encontro una columna entonces se asume que es un valor inmediato

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

        B mul_operador2

        val_inmediato_mul:

            LDR x5, =row       // Se carga la direccion de memoria de la variable row en x5
            LDR x8, =row       // Se carga la direccion de memoria de la variable row en x8

            STP x29, x30, [sp, -16]!
            BL atoi
            LDP x29, x30, [sp], 16

            LDR x19, =retorno    // Se carga la direccion de memoria de la variable retorno en x19
            STR x9, [x19]        // Se guarda el valor de la variable row en la variable retorno
        
        mul_operador2:

            // ------------------------------- COMPARACIONES PARA EL SEGUNDO VALOR -------------------------------

            CBZ x25, val_inmediato_mul2    // Si no se encontro una columna entonces se asume que es un valor inmediato

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

            B mul_End

            val_inmediato_mul2:

                LDR x5, =row2       // Se carga la direccion de memoria de la variable row2 en x5
                LDR x8, =row2       // Se carga la direccion de memoria de la variable row2 en x8

                STP x29, x30, [sp, -16]!
                BL atoi
                LDP x29, x30, [sp], 16

                MOV x21, x9
        
        mul_End:

            LDR x19, =retorno
            LDR x18, [x19]

            MUL x21, x18, x21       // Se suma los valores de las celdas o inmediatos

            STR x21, [x19]          // Se guarda el resultado en la variable retorno

            LDP x29, x30, [sp], 16  // Se recupera el puntero de pila

            bl excel
    
    mulError:

        LDR x27, =errorResta
        LDR x26, =lenErrorResta
        print 1, x27, x26

        LDR x27, =enter
        LDR x26, =lenEnter
        print 1, x27, x26

        LDR x27, =bufferComando
        read 0, x27, 50

        LDP x29, x30, [sp], 16  // Se recupera el puntero de pila

        bl excel





