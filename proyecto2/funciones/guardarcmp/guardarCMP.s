.global guardarCMP
.extern proc_cls_num, atoi, excel

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

// -------------------------- FUNCION GUARDAR CMP --------------------------
guardarCMP:
    
    // CARGA DE MENSAJES 
    LDR x0, =cmdguardar         // Cargamos el mensaje de GUARDAR en x0
    LDR x1, =bufferComando      // Cargamos el buffer de comando en x1

    //Comparacion de mensaje con comando Guardar

    guardar_Loop:

        LDRB w2, [x0], 1        // Cargamos el caracter de x0 en w2
        LDRB w3, [x1], 1        // Cargamos el caracter de x1 en w3

        CBZ w2, guardarVal      // Si w2 es 0, saltar a guardarVal

        CMP w2, w3              // Comparamos w2 con w3
        BNE impGuardarError         // Si w2 es diferente a w3, saltar a impGuardar

        B guardar_Loop          // Si no se cumple la condicion, repetir el ciclo

        impGuardarError:
            LDR x27, =errorGuardar
            LDR x26, =lenErrorGuardar
            print 1, x27, x26

            LDR x27, =enter
            LDR x26, =lenEnter
            print 1, x27, x26

            // Leer entrada del usuario (limpiar el buffer)
            LDR x27, =buffer        // Cargar la dirección de buffer en x10
            MOV x11, 1              // Leer 1 byte
            read 0, x10, x11           // Llamar a la macro read

            B excel

    guardarVal:

        MOV x27, 0
        MOV x26, 0
        MOV x23, 0
        LDR x5, =colum      // Cargamos la dirección de colum en x5
        LDR x6, =row        // Cargamos la dirección de row en x6

        guardarValLoop:

            LDRB w2, [x1], 1     // Cargamos el caracter de x1 en w2 

            // CASO CON RETORNO
            CMP w2, 42          // Comparamos w2 con 42 Si el comando es GUARDAR * EN CELDA
            BEQ guardarOp1

            CMP w2, 32          // Comparamos w2 con 32 (espacio)   
            BEQ guardarCont

            CMP w2, 65          // Comparamos w2 con 65 (A) Si es una letra
            BGE getColumna

            CMP w2, 48          // Comparamos w2 con 48 (0) Si es un número
            BGE getFila

            CMP w2, 45          // Comparamos w2 con 45 (-) Si es un guion
            BEQ guardarContNeg

            BL generarError

            getColumna:
               
                CMP w2, 75       // Comparamos w2 con 75 (K) Si es una letra
                BGT generarError

                SUB w2, w2, 65   // Restamos 65 a w2 para obtener la columna
                STRB w2, [x5], 1 // Se guardar el valor de la columna en x5
                MOV x27, 1

                B guardarValLoop
            
            getFila:

                CMP w2, 57
                BGT generarError

                STRB w2, [x6], 1    // Se guarda el valor de la fila en x6
                MOV x26, 1          // Se activa la bandera de fila

                B guardarValLoop

            guardarContNeg:

                CBNZ x27, generarError

                STRB w2, [x6], 1    // Se guarda el valor de la fila en x6 

                B guardarValLoop

            guardarOp1:

                MOV x23, 1
                B guardarValLoop
    
    guardarCont:

        CBZ x26, generarError2

        B continuar

        generarError2:
            CBZ x23, generarError
        
        continuar:

            LDR x0, =cmpsepEn   //  Cargamos el mensaje de EN en x0 

        // Verificamos que el comando contenga la palabra EN

        verificarEn:

            LDRB w2, [x0], 1    // Cargamos el caracter de x0 en w2
            LDRB w3, [x1], 1    // Cargamos el caracter de x1 en w3

            CBZ w2, guardarOp2 // Si w2 es 0, saltar a guardarCMPVal

            CMP w2, w3          // Comparamos w2 con w3
            BNE generarError // Si w2 es diferente a w3, saltar a impGuardarError

            B verificarEn      // Si no se cumple la condicion, repetir el ciclo

    //Se busca ahora la celda en la que se guardara el valor
    guardarOp2:

        MOV x25, 0
        MOV x26, 0
        LDR x5, =colum2     // Cargamos la dirección de colum2 en x5
        LDR x6, =row2       // Cargamos la dirección de row2 en x6

        valOp2Loop:

            LDRB w2, [x1], 1    // Cargamos el caracter de x1 en w2

            CMP w2, 32          // Comparamos w2 con 32 (espacio)
            BEQ executeSave

            CMP w2, 10          // Comparamos w2 con 10 (salto de linea)
            BEQ executeSave

            CMP w2, 65         // Comparamos w2 con 65 (A) Si es una letra
            BGE getColumna2

            CMP w2, 48         // Comparamos w2 con 48 (0) Si es un número
            BGE getFila2

            B generarError

            getColumna2:

                CMP w2, 75          // Se compara si el byte es una letra (ASCII 75) => K
                BGT generarError

                SUB w2, w2, 65      // Se convierte la letra a un numero
                STRB w2, [x5], 1    // Se almacena el valor en Columna
                MOV x25, 1          // Se marca que se encontro una columna

                B valOp2Loop
            
            getFila2:

                CMP w2, 57        // Se compara si el byte es un numero (ASCII 57) => 9
                BGT generarError

                STRB w2, [x6], 1  // Se almacena el valor en Fila
                MOV x26, 1        // Se marca que se encontro un valor o celda

                B valOp2Loop

    executeSave:

        LDR x20, =arreglo       // Cargamos la dirección de arreglo en x20

        CBZ x26, generarError

        LDR x5, =row2          // Cargamos la dirección de fila2 en x5
        LDR x5, [x5]            // Cargamos el valor de fila2 en x5
        LDR x6, =num            // Cargamos la dirección de num en x6
        STR x5, [x6]            // Guardamos el valor de fila2 en num

        LDR x5, =num
        LDR x8, =num

        STP x29, x30, [sp, -16]!
        BL atoi
        LDP x29, x30, [sp], 16
        
        LDR x5, =colum2         // Cargamos la dirección de colum2 en x5
        LDRB w16, [x5]          // Cargamos el valor de colum2 en w16

        SUB x9, x9, 1
        MOV x22, 12
        MUL x22, x9, x22
        ADD x22, x16, x22 

        CBNZ x23, getRetorno        // Si x23 es diferente de 0, saltar a getRetorno
        CBZ x27, getContenido       // Si x27 es 0, saltar a getContenido

        LDR x5, =row
        LDR x5, [x5]
        LDR x6, =num
        STR x5, [x6]

        LDR x5, =num
        LDR x8, =num

        STP x29, x30, [sp, -16]!
        BL atoi
        LDP x29, x30, [sp], 16

        LDR x5, =colum
        LDRB w16, [x5]

        SUB x9, x9, 1
        MOV x21, 12
        MUL x21, x9, x21
        ADD x21, x16, x21

        LDR x9, [x20, x21, LSL 3]       // Cargamos el valor de la celda en x9

        B endSave

        getContenido:

            LDR x5, =row
            LDR x5, [x5]
            LDR x6, =num
            STR x5, [x6]

            LDR x5, =num
            LDR x8, =num

            STP x29, x30, [sp, -16]!
            BL atoi
            LDP x29, x30, [sp], 16

            B endSave

        getRetorno:
            LDR x19, =retorno
            LDR x9, [x19]

        endSave:
            STR x9, [x20, x22, LSL 3]      // Guardamos el valor en la celda

            B excel

    generarError:
    
        LDR x27, =errorGuardar
        LDR x26, =lenErrorGuardar
        print 1, x27, x26

        LDR x27, =enter
        LDR x26, =lenEnter
        print 1, x27, x26

        LDR x27, =buffer
        read 0, x27, 1

        B excel
    

                

