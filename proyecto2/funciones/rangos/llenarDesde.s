.global Proc_LlenarDesde
.extern excel, atoi

.data

    comandohasta:
        .asciz "HASTA"
        lenComandoHasta = .- comandohasta
    
    mensajeLlenar:
        .asciz " || Operacion LLENAR realizada con exito\n"
        lenMensajeLlenar = .- mensajeLlenar
    
    mensajevalor:
        .asciz "VALOR PARA "
        lenMensajeValor = .- mensajevalor
    
    errorLlenar:
        .asciz " || Error en el LLENAR\n"
        lenErrorLlenar = .- errorLlenar
    
    valorincorrecto:
        .asciz " || Valor incorrecto\n"
        lenValorIncorrecto = .- valorincorrecto

    enter2:        
    .asciz " || Presiona Enter para continuar...\n"
    lenEnter2 = .- enter2

    dospuntos:
        .asciz ":"
        lenDospuntos = .- dospuntos
    
.bss
    
    celda:
        .space 2
    
    valor:
        .zero 50
    
    rowPrint:
        .space 4
    
    rowLen:
        .space 4

    opcion:
        .space 8

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

Proc_LlenarDesde:

    STP x29, x30, [sp, -16]!    // Guardar el link register y el frame pointer en la pila

    LDR x0, =cmdLLenarDesde
    LDR x1, =bufferComando

    //Comparacion de mensaje con comando Suma

    llenarLoop:
        LDRB w2, [x0], 1        // Cargamos el caracter de x0 en w2
        LDRB w3, [x1], 1        // Cargamos el caracter de x1 en w3

        CBZ w2, llenar_first_cell      // Si w2 es 0, saltar a guardarSumaVal

        CMP w2, w3              // Comparamos w2 con w3
        BNE fill_error          // Si no son iguales, saltar a errorSuma

        B llenarLoop          // Si no se cumple la condicion, repetir el ciclo

    //Se obtiene la celda de inicio
    llenar_first_cell:

        MOV x23, 0              // Se usa como flag para saber si se encontro una columna | 0 = No se encontro, 1 = Se encontro

        MOV x24, 0              // Se usa como flag para saber si se encontro la fila | 0 = No se encontro, 1 = Se encontro

        LDR x5, =colum        // Se carga la direccion de memoria de la variable colum en x5
        LDR x6, =row           // Se carga la direccion de memoria de la variable row en x6

        fill_first_Loop:

            LDRB w2, [x1], 1    // Se carga el primer byte del comando del usuario en w2

            CMP w2, 32          // Se compara si el byte es un espacio
            BEQ fill_continue   // Si es un espacio se continua con el resto del comando

            CMP w2, 65                  // Se compara si el byte es una A
            BGE fill_first_column       // Si es mayor o igual a A se asume que es una columna

            CMP w2, 48                  // Se compara si el byte es un 0
            BGE fill_first_row          // Si es mayor o igual a 0 se asume que es una fila

            CMP w2, 45                  // Se compara si el byte es un -
            BEQ fill_error              // Si es un - se asume que es un error

            B fill_error                // Si no es ninguno de los anteriores se asume que es un error

            fill_first_column:

                CMP w2, 75              // Se compara si el byte es una K
                BGT fill_error          // Si es mayor a K se asume que es un error

                SUB w2, w2, 65          // Se le resta 65 al valor de w2 para obtener el numero de columna
                STRB w2, [x5], 1        // Se guarda el valor de la columna en la variable colum
                MOV x23, 1              // Se cambia el flag de columna a 1

                B fill_first_Loop
            
            fill_first_row:

                CMP w2, 57              // Se compara si el byte es un 9
                BGT fill_error          // Si es mayor a 9 se asume que es un error

                STRB w2, [x6], 1        // Se guarda el valor de la fila en la variable row
                MOV x24, 1              // Se cambia el flag de fila a 1

                B fill_first_Loop
    
    // Se confirma si el comando esta completo
    fill_continue:

        CBZ x23, fill_error         // Si no se encontro la columna se asume que es un error
        CBZ x24, fill_error         // Si no se encontro la fila se asume que es un error

        LDR x0, =comandohasta       // Se carga la direccion de memoria de la variable comandohasta en x0

        fill_cont_Loop:

            LDRB w2, [x0], 1        // Se carga el primer byte del comando HASTA en w2
            LDRB w3, [x1], 1        // Se carga el primer byte del comando del usuario en w3

            CBZ w2, llenar_second_cell  // Si se llega al final del comando HASTA se continua con la siguiente celda

            CMP w2, w3              // Se compara si los bytes son iguales
            BNE fill_error          // Si no son iguales se asume que es un error

            B fill_cont_Loop
    
    // Se obtiene la celda de fin
    llenar_second_cell:

        MOV x23, 0              // Se usa como flag para saber si se encontro una columna | 0 = No se encontro, 1 = Se encontro

        MOV x24, 0              // Se usa como flag para saber si se encontro la fila | 0 = No se encontro, 1 = Se encontro

        LDR x5, =colum2       // Se carga la direccion de memoria de la variable colum2 en x5
        LDR x6, =row2          // Se carga la direccion de memoria de la variable row2 en x6

        fill_second_Loop:

            LDRB w2, [x1], 1    // Se carga el primer byte del comando del usuario en w2

            CMP w2, 32          // Se compara si el byte es un espacio
            BEQ Fill_Ejecutar   // Si es un espacio se continua con el resto del comando

            CMP w2, 10          // Se compara si el byte es un salto de linea
            BEQ Fill_Ejecutar   // Si es un salto de linea se continua con el resto del comando

            CMP w2, 65                  // Se compara si el byte es una A
            BGE fill_second_column      // Si es mayor o igual a A se asume que es una columna

            CMP w2, 48                  // Se compara si el byte es un 0
            BGE fill_second_row         // Si es mayor o igual a 0 se asume que es una fila

            CMP w2, 45                  // Se compara si el byte es un -
            BEQ fill_error              // Si es un - se asume que es un error

            B fill_error                // Si no es ninguno de los anteriores se asume que es un error

            fill_second_column:

                CMP w2, 75              // Se compara si el byte es una K
                BGT fill_error          // Si es mayor a K se asume que es un error

                SUB w2, w2, 65          // Se le resta 65 al valor de w2 para obtener el numero de columna
                STRB w2, [x5], 1        // Se guarda el valor de la columna en la variable colum2
                MOV x23, 1              // Se cambia el flag de columna a 1

                B fill_second_Loop
            
            fill_second_row:

                CMP w2, 57              // Se compara si el byte es un 9
                BGT fill_error          // Si es mayor a 9 se asume que es un error

                STRB w2, [x6], 1        // Se guarda el valor de la fila en la variable row2
                MOV x24, 1              // Se cambia el flag de fila a 1

                B fill_second_Loop
    
    // Se ejecuta la funcion de llenar
    Fill_Ejecutar:

        LDR x20, =arreglo        // Se carga la direccion de memoria de la arreglo en x20

        CBZ x23, fill_error     // Si no se encontro la columna se asume que es un error
        CBZ x24, fill_error     // Si no se encontro la fila se asume que es un error

        // Se compara si el Llenar es en la misma fila o en la misma columna

        LDR x5, =colum        // Se carga la direccion de memoria de la variable colum en x5
        LDR x6, =colum2       // Se carga la direccion de memoria de la variable colum2 en x6

        LDRB w2, [x5]           // Se carga el valor de la columna en w2
        LDRB w3, [x6]           // Se carga el valor de la columna2 en w3

        CMP w2, w3              // Se compara si las columnas son iguales
        BNE compare_row         // Si no son iguales se asume que es en la misma fila

        B same_column

        compare_row:

            LDR x5, =row               // Se carga la direccion de memoria de la variable row en x5
            LDR x8, =row               // Se carga la direccion de memoria de la variable row en x8

            STP x29, x30, [sp, -16]!    // Se guarda la direccion de memoria de la arreglo y la fila en la pila
            BL atoi
            LDP x29, x30, [sp], 16      // Se recupera la direccion de memoria de la arreglo y la fila de la pila

            MOV x21, x9                 // Se guarda el valor de la fila en x21

            LDR x5, =row2              // Se carga la direccion de memoria de la variable row2 en x5
            LDR x8, =row2              // Se carga la direccion de memoria de la variable row2 en x8

            STP x29, x30, [sp, -16]!    // Se guarda la direccion de memoria de la arreglo y la fila en la pila
            BL atoi
            LDP x29, x30, [sp], 16      // Se recupera la direccion de memoria de la arreglo y la fila de la pila

            CMP w21, w9                 // Se compara si las filas son iguales
            BNE fill_error              // Si no son iguales, entonces es asume que es un error

            B same_row
        
        // ---------------------------- SE LLENA LA MISMA COLUMNA | EJEMPLO = LLENAR DESDE A1 HASTA A16 ----------------------------
        same_column:

            LDR x5, =row               // Se carga la direccion de memoria de la variable row en x5
            LDR x8, =row              // Se carga la direccion de memoria de la variable row2 en x8

            STP x29, x30, [sp, -16]!    // Se guarda la direccion de memoria de la arreglo y la fila en la pila
            BL atoi
            LDP x29, x30, [sp], 16      // Se recupera la direccion de memoria de la arreglo y la fila de la pila

            MOV x21, x9                 // Se guarda el valor de la fila en x21

            LDR x5, =row2              // Se carga la direccion de memoria de la variable row2 en x5
            LDR x8, =row2              // Se carga la direccion de memoria de la variable row2 en x8

            STP x29, x30, [sp, -16]!    // Se guarda la direccion de memoria de la arreglo y la fila en la pila
            BL atoi
            LDP x29, x30, [sp], 16      // Se recupera la direccion de memoria de la arreglo y la fila de la pila

            CMP w21, w9                 // Se comparan las filas
            BGT fill_error              // Si la fila de inicio es mayor a la fila de fin se asume que es un error

            MOV x12, #23                // Se carga el valor de la columna en x12

            CMP w9, w12                 // Se compara si la fila de fin es mayor a 23
            BGT fill_error              // Si la fila de fin es mayor a 23 se asume que es un error

            same_column_pre:
                
                LDR x5, =colum        // Se carga la direccion de memoria de la variable colum en x5
                LDR x6, =celda          // Se carga la direccion de memoria de la variable celda en x6
                LDR w5, [x5]            // Se carga el valor de la columna en w5
                MOV x7, x9              // Se guarda la direccion de memoria de la fila final en x7

                ADD w5, w5, 65          // Se le suma 65 al valor de w5 para obtener el valor ASCII de la columna
                STRB w5, [x6]        // Se guarda el valor ASCII de la columna en la variable celda

                same_column_Loop:

                    // x21 = row de inicio | x7 = row de fin

                    print mensajevalor, lenMensajeValor
                    print celda, 1

                    MOV x0, x21
                    LDR x1, =num

                    STP x29, x30, [sp, -16]!    // Se guarda la direccion de memoria de la arreglo y la fila en la pila
                    BL itoa
                    LDP x29, x30, [sp], 16      // Se recupera la direccion de memoria de la arreglo y la fila de la pila

                    print dospuntos, lenDospuntos

                    LDR x27, =valor
                    read 0, x27, 50

                    LDR x5, =valor          // Se carga la direccion de memoria de la variable valor en x5

                    // se confirma si el valor es correcto
                    column_conf_val:

                        LDRB w2, [x5], 1        // Se carga el primer byte del valor en w2

                        CMP w2, 10              // Se compara si el byte es un salto de linea
                        BEQ column_insert_val   // Si es un salto de linea se inserta el valor

                        CMP w2, 32              // Se compara si el byte es un espacio
                        BEQ column_insert_val   // Si es un espacio se inserta el valor

                        CMP w2, 48              // Se compara si el byte es un 0
                        BGE c_conf_valor     // Si es mayor o igual a 0 se continua con el valor

                        CMP w2, 45              // Se compara si el byte es un -
                        BEQ column_conf_val     // Si es un - se continua con el valor

                        B column_error            // Si no es ninguno de los anteriores se asume que es un error

                        c_conf_valor:

                            CMP w2, 57              // Se compara si el byte es un 9
                            BGT column_error          // Si es mayor a 9 se asume que es un error

                            B column_conf_val
                        
                        column_error:

                            print valorincorrecto, lenValorIncorrecto

                            print enter2, lenEnter2

                            LDR x27, =buffer
                            read 0, x27, 2

                            B same_column_Loop
                    
                    // Se inserta el valor en la arreglo
                    column_insert_val:

                        // x21 = row de inicio | x7 = row de fin

                        LDR x5, =valor
                        LDR x8, =valor

                        STP x29, x30, [sp, -16]!    // Se guarda la direccion de memoria de la arreglo y la fila en la pila
                        BL atoi
                        LDP x29, x30, [sp], 16      // Se recupera la direccion de memoria de la arreglo y la fila de la pila

                        LDR x5, =colum        // Se carga la direccion de memoria de la variable colum en x5
                        LDRB w16, [x5]          // Se carga el valor de la columna en w16

                        SUB x24, x21, 1         // Se resta 1 a la fila de inicio
                        MOV x25, 12             // Se multiplica la fila de inicio por 12
                        MUL x25, x25, x24
                        ADD x25, x25, x16       // Se suma el valor de la columna

                        STR x9, [x20, x25, LSL 3]   // Se guarda el valor en la arreglo

                        CMP x21, x7             // Se compara si la fila de inicio es igual a la fila de fin
                        BEQ same_column_end     // Si son iguales se termina el llenado

                        ADD x21, x21, 1         // Se suma 1 a la fila de inicio

                        LDR x12, =valor
                        MOV x14, 0

                        clear_VAL_c:

                            STRB WZR, [x12], 1
                            ADD x14, x14, 1
                            CMP x14, 8
                            BNE clear_VAL_c

                        B same_column_Loop
            
            same_column_end:
                
                LDP x29, x30, [sp], 16      // Se recupera el link register y el frame pointer de la pila

                BL excel

        // ---------------------------- SE LLENA LA MISMA FILA | EJEMPLO = LLENAR DESDE A1 HASTA G1 ----------------------------
        same_row:

            LDR x5, =colum        // Se carga la direccion de memoria de la variable colum en x5
            LDRB w5, [x5]           // Se carga el valor de la columna en w5

            LDR x6, =colum2       // Se carga la direccion de memoria de la variable colum2 en x6
            LDRB w6, [x6]           // Se carga el valor de la columna2 en w6

            CMP w5, w6              // Se compara si la columna 1 es mayor a la columna 2
            BGT fill_error          // Si la columna 1 es mayor a la columna 2 se asume que es un error

            same_row_pre:

                MOV x21, x5              // Se guarda el valor de la columna en x21
                MOV x7, x6               // Se guarda el valor de la columna2 en x7

                LDR x6, =celda          // Se carga la direccion de memoria de la variable celda en x6

                LDR x5, =row           // Se carga la direccion de memoria de la variable row en x5
                LDR x8, =row           // Se carga la direccion de memoria de la variable row en x8

                STP x29, x30, [sp, -16]!    // Se guarda la direccion de memoria de la arreglo y la fila en la pila
                BL atoi
                LDP x29, x30, [sp], 16      // Se recupera la direccion de memoria de la arreglo y la fila de la pila

                MOV x26, x9             // Se guarda el valor de la fila en x26

                same_row_Loop:

                    // x21 = colum de inicio | x7 = colum de fin | x26 = row

                    ADD w4, w21, 65         // Se le suma 65 al valor de w6 para obtener el valor ASCII de la columna
                    STRB w4, [x6]           // Se guarda el valor ASCII de la columna en la variable celda
                    
                    print mensajevalor, lenMensajeValor
                    print celda, 1
                    print row, 4
                    print dospuntos, lenDospuntos
                    LDR x27, =valor
                    read 0,x27, 50

                    LDR x5, =valor          // Se carga la direccion de memoria de la variable valor en x5

                    // se confirma si el valor es correcto
                    row_conf_val:

                        LDRB w2, [x5], 1        // Se carga el primer byte del valor en w2

                        CMP w2, 10              // Se compara si el byte es un salto de linea
                        BEQ row_insert_val   // Si es un salto de linea se inserta el valor

                        CMP w2, 32              // Se compara si el byte es un espacio
                        BEQ row_insert_val   // Si es un espacio se inserta el valor

                        CMP w2, 48              // Se compara si el byte es un 0
                        BGE r_conf_valor     // Si es mayor o igual a 0 se continua con el valor

                        CMP w2, 45              // Se compara si el byte es un -
                        BEQ row_conf_val     // Si es un - se continua con el valor

                        B row_error            // Si no es ninguno de los anteriores se asume que es un error

                        r_conf_valor:

                            CMP w2, 57                  // Se compara si el byte es un 9
                            BGT row_error            // Si es mayor a 9 se asume que es un error

                            B row_conf_val
                        
                        row_error:

                            print valorincorrecto, lenValorIncorrecto
                            print enter2, lenEnter2
                            LDR x27, =buffer
                            read 0, x27, 2
                            B same_row_Loop
                    
                    // Se inserta el valor en la arreglo
                    row_insert_val:

                        // x21 = colum de inicio | x7 = colum de fin | x26 = row

                        LDR x5, =valor
                        LDR x8, =valor

                        STP x29, x30, [sp, -16]!    // Se guarda la direccion de memoria de la arreglo y la fila en la pila
                        BL atoi
                        LDP x29, x30, [sp], 16      // Se recupera la direccion de memoria de la arreglo y la fila de la pila

                        SUB x24, x26, 1             // Se resta 1 a la columna de inicio
                        MOV x17, 12                 // Se multiplica la columna de inicio por 12
                        MUL x17, x17, x24           // Se multiplica la columna de inicio por 12
                        ADD x17, x17, x21           // Se suma el valor de la columna

                        STR x9, [x20, x17, LSL 3]   // Se guarda el valor en la arreglo

                        CMP x21, x7                 // Se compara si la columna de inicio es igual a la columna de fin
                        BEQ same_row_end            // Si son iguales se termina el llenado

                        ADD x21, x21, 1             // Se suma 1 a la columna de inicio

                        LDR x12, =valor
                        MOV x14, 0

                        clear_VAL_r:

                            STRB WZR, [x12], 1
                            ADD x14, x14, 1
                            CMP x14, 8
                            BNE clear_VAL_r
                        
                        LDR x6, =celda          // Se carga la direccion de memoria de la variable celda en x6
                        B same_row_Loop
            
            same_row_end:

                LDP x29, x30, [sp], 16      // Se recupera el link register y el frame pointer de la pila

                BL excel

    fill_error:

        print errorLlenar, lenErrorLlenar
        read 0, opcion, 4

        LDP x29, x30, [sp], 16      // Se recupera el link register y el frame pointer de la pila

        BL excel

