.global potenciaCMP
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

potenciaCMP:

    STP x29, x30, [sp, -16]!    // Se guarda el puntero de pila

    LDR x0, =cmdPotencia
    LDR x1, =bufferComando

    //Comparacion de mensaje con comando Suma

    potLoop:
        LDRB w2, [x0], 1        // Cargamos el caracter de x0 en w2
        LDRB w3, [x1], 1        // Cargamos el caracter de x1 en w3

        CBZ w2, guardarPotVal      // Si w2 es 0, saltar a guardarPotVal

        CMP w2, w3              // Comparamos w2 con w3
        BNE potError         // Si w2 es diferente a w3, saltar a potError

        B potLoop          // Si no se cumple la condicion, repetir el ciclo

    // Se obtiene el primer valor de la suma
    guardarPotVal:

        MOV x27, 0              // Se usa como flag para saber si se encontro una columna | 0 = No se encontro, 1 = Se encontro
        MOV x26, 0
        MOV x23, 0              // Se usa como flag para saber si se encontro una columna | 0 = No se encontro, 1 = Se encontro

        MOV x24, 0              // Se usa como flag para saber si se encontro un valor o celda | 0 = No se encontro, 1 = Se encontro

        LDR x5, =colum        // Se carga la direccion de memoria de la variable colum en x5
        LDR x6, =row           // Se carga la direccion de memoria de la variable row en x6

        guardarPotValLoop:

            LDRB w2, [x1], 1    // Se carga el primer byte del comando del usuario en w2

            CMP w2, 32          // Se compara si el byte es un espacio
            BEQ potConf

            CMP w2, 65          // Se compara si el byte es una A
            BGE potFirtCol

            CMP w2, 48          // Se compara si el byte es un 0
            BGE potFirstVal

            CMP w2, 45          // Se compara si el byte es un guion
            BEQ potConfNeg

            B potError

            potFirtCol:

                CMP w2, 75      // Se compara si el byte es una K
                BGT potError

                SUB w2, w2, 65      // Se convierte la letra a un numero
                STRB w2, [x5], 1    // Se guarda el valor en la variable colum
                MOV x23, 1          // Se activa el flag para saber que se encontro una columna

                B guardarPotValLoop
            
            potConfNeg:

                CBNZ x23, potError    // Si ya se encontro una columna entonces no puede haber un valor negativo

                STRB w2, [x6], 1    // Se guarda el valor en la variable row

                B guardarPotValLoop
            
            potFirstVal:

                CMP w2, 57      // Se compara si el byte es un 9
                BGT potError

                STRB w2, [x6], 1    // Se guarda el valor en la variable row
                MOV x24, 1          // Se activa el flag para saber que se encontro un valor o celda

                B guardarPotValLoop
    
    // Se confirma si el comando esta completo
    potConf:

        CBZ x24, potError     // si no encontro ningun valor (ya sea fila o valor inmediato) entonces se supone que columna tampoco y tira error

        LDR x0, =cmdsepALa       // Se carga la direccion de memoria del comando "Y" en x0

        potConfLoop:

            LDRB w2, [x0], 1    // Se carga el primer byte del comando del usuario en w2
            LDRB w3, [x1], 1    // Se carga el primer byte del comando "Y" en w3

            CBZ w2, guardarPotSecVal    // Si el byte del comando del usuario es 0 entonces se sale del loop

            CMP w2, w3          // Se compara si los bytes son iguales
            BNE potError      // Si no son iguales, se pasa con el siguiente procedimiento

            B potConfLoop
    
    // Se guarda el segundo valor de la suma
    guardarPotSecVal:

        MOV x25, 0              // Se usa como flag para saber si se encontro una columna | 0 = No se encontro, 1 = Se encontro
        MOV x24, 0              // Se usa como flag para saber si se encontro un valor o celda | 0 = No se encontro, 1 = Se encontro

        LDR x5, =colum2       // Se carga la direccion de memoria de la variable colum2 en x5
        LDR x6, =row2          // Se carga la direccion de memoria de la variable row2 en x6

        pot_second_Loop:

            LDRB w2, [x1], 1    // Se carga el primer byte del comando del usuario en w2

            CMP w2, 32          // Se compara si el byte es un espacio
            BEQ pot_Ejecutar

            CMP w2, 10          // Se compara si el byte es un salto de linea
            BEQ pot_Ejecutar

            CMP w2, 65          // Se compara si el byte es una A
            BGE pot_second_column

            CMP w2, 48          // Se compara si el byte es un 0
            BGE pot_second_value

            CMP w2, 45          // Se compara si el byte es un guion
            BEQ pot_conf_neg2

            B potError

            pot_second_column:

                CMP w2, 75      // Se compara si el byte es una K
                BGT potError

                SUB w2, w2, 65      // Se convierte la letra a un numero
                STRB w2, [x5], 1    // Se guarda el valor en la variable colum2
                MOV x25, 1          // Se activa el flag para saber que se encontro una columna

                B pot_second_Loop
            
            pot_conf_neg2:

                CBNZ x25, potError    // Si ya se encontro una columna entonces no puede haber un valor negativo

                STRB w2, [x6], 1    // Se guarda el valor en la variable row

                B pot_second_Loop
            
            pot_second_value:

                CMP w2, 57      // Se compara si el byte es un 9
                BGT potError

                STRB w2, [x6], 1    // Se guarda el valor en la variable row2
                MOV x24, 1          // Se activa el flag para saber que se encontro un valor o celda

                B pot_second_Loop
    
    // Se ejecuta la suma
    pot_Ejecutar:

        LDR x20, =arreglo        // Se carga la direccion de memoria de la arreglo en x20

        // Parametros: x23 = flag columna1, x25 = flag columna2, x24 = flag valor1 y valor2

        CBZ x24, potError     // Si no encontro ningun valor (ya sea fila o valor inmediato) entonces se supone que columna tampoco y tira error

        // ------------------------------- COMPARACIONES PARA EL PRIMER VALOR ------------------------------- 

        CBZ x23, val_inmediato_pot    // Si no se encontro una columna entonces se asume que es un valor inmediato

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

        B pot_operador2

        val_inmediato_pot:

            LDR x5, =row       // Se carga la direccion de memoria de la variable row en x5
            LDR x8, =row       // Se carga la direccion de memoria de la variable row en x8

            STP x29, x30, [sp, -16]!
            BL atoi
            LDP x29, x30, [sp], 16

            LDR x19, =retorno    // Se carga la direccion de memoria de la variable retorno en x19
            STR x9, [x19]        // Se guarda el valor de la variable row en la variable retorno
        
        pot_operador2:

            // ------------------------------- COMPARACIONES PARA EL SEGUNDO VALOR -------------------------------

            CBZ x25, val_inmediato_pot2    // Si no se encontro una columna entonces se asume que es un valor inmediato

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

            B pot_End

            val_inmediato_pot2:

                LDR x5, =row2       // Se carga la direccion de memoria de la variable row2 en x5
                LDR x8, =row2       // Se carga la direccion de memoria de la variable row2 en x8

                STP x29, x30, [sp, -16]!
                BL atoi
                LDP x29, x30, [sp], 16

                MOV x21, x9
        
        pot_End:

            LDR x19, =retorno
            LDR x18, [x19]

            CMP w21, 0
            BLT exponente_negativo       // Si el exponente es negativo se tira error

            MOV x22, 1                   // Se usa para guardar el resultado de la potencia

            realizar_potencia:

                CMP x21, 0
                BEQ guardar_resultado

                MUL x22, x22, x18
                SUB x21, x21, 1

                B realizar_potencia

    guardar_resultado:
        STR x22, [x19]
        LDP x29, x30, [sp], 16  // Se recupera el puntero de pila

        BL excel    
    
    potError:

        LDR x27, =errorPotencia
        LDR x26, =lenErrorPotencia
        print 1, x27, x26

        LDR x27, =enter
        LDR x26, =lenEnter
        print 1, x27, x26

        LDR x27, =bufferComando
        read 0, x27, 50

        LDP x29, x30, [sp], 16  // Se recupera el puntero de pila

        bl excel

    exponente_negativo:
            
            LDR x27, =errorPotenciaNegativa
            LDR x26, =lenErrorPotenciaNegativa
            print 1, x27, x26
    
            LDR x27, =enter
            LDR x26, =lenEnter
            print 1, x27, x26
    
            LDR x27, =bufferComando
            read 0, x27, 50
    
            LDP x29, x30, [sp], 16  // Se recupera el puntero de pila
    
            bl excel



