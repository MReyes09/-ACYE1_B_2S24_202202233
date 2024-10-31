.global Proc_Maximo
.extern excel
.extern atoi

.data

    comandohasta:
        .asciz "HASTA"
        lenComandoHasta = .- comandohasta
    
    mensajeMaximo:
        .asciz " || Operacion MAXIMO realizada con exito\n"
        lenMensajeMaximo = .- mensajeMaximo
    
    errorMaximo:
        .asciz " || Error en el MAXIMO\n"
        lenErrorMaximo = .- errorMaximo

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

Proc_Maximo:

    STP x29, x30, [sp, -16]!    // Guardar el link register y el frame pointer en la pila

    LDR x0, =cmdMaximo
    LDR x1, =bufferComando

    //Comparacion de mensaje con comando Suma

    maximoLoop:
        LDRB w2, [x0], 1        // Cargamos el caracter de x0 en w2
        LDRB w3, [x1], 1        // Cargamos el caracter de x1 en w3

        CBZ w2, maximo_first_cell      // Si w2 es 0, saltar a guardarSumaVal

        CMP w2, w3              // Comparamos w2 con w3
        BNE maximo_error          // Si no son iguales, saltar a errorSuma

        B maximoLoop          // Si no se cumple la condicion, repetir el ciclo

    //Se obtiene la celda de inicio
    maximo_first_cell:

        MOV x23, 0              // Se usa como flag para saber si se encontro una columna | 0 = No se encontro, 1 = Se encontro

        MOV x24, 0              // Se usa como flag para saber si se encontro la fila | 0 = No se encontro, 1 = Se encontro

        LDR x5, =colum        // Se carga la direccion de memoria de la variable colum en x5
        LDR x6, =row           // Se carga la direccion de memoria de la variable row en x6

        maximo_first_Loop:

            LDRB w2, [x1], 1    // Se carga el primer byte del comando del usuario en w2

            CMP w2, 32          // Se compara si el byte es un espacio
            BEQ maximo_continue   // Si es un espacio se continua con el resto del comando

            CMP w2, 65                  // Se compara si el byte es una A
            BGE maximo_first_column       // Si es mayor o igual a A se asume que es una columna

            CMP w2, 48                  // Se compara si el byte es un 0
            BGE maximo_first_row          // Si es mayor o igual a 0 se asume que es una fila

            CMP w2, 45                  // Se compara si el byte es un -
            BEQ maximo_error              // Si es un - se asume que es un error

            B maximo_error                // Si no es ninguno de los anteriores se asume que es un error

            maximo_first_column:

                CMP w2, 75              // Se compara si el byte es una K
                BGT maximo_error          // Si es mayor a K se asume que es un error

                SUB w2, w2, 65          // Se le resta 65 al valor de w2 para obtener el numero de columna
                STRB w2, [x5], 1        // Se guarda el valor de la columna en la variable colum
                MOV x23, 1              // Se cambia el flag de columna a 1

                B maximo_first_Loop
            
            maximo_first_row:

                CMP w2, 57              // Se compara si el byte es un 9
                BGT maximo_error          // Si es mayor a 9 se asume que es un error

                STRB w2, [x6], 1        // Se guarda el valor de la fila en la variable row
                MOV x24, 1              // Se cambia el flag de fila a 1

                B maximo_first_Loop
    
    // Se confirma si el comando esta completo
    maximo_continue:

        CBZ x23, maximo_error         // Si no se encontro la columna se asume que es un error
        CBZ x24, maximo_error         // Si no se encontro la fila se asume que es un error

        LDR x0, =comandohasta       // Se carga la direccion de memoria de la variable comandohasta en x0

        maximo_cont_Loop:

            LDRB w2, [x0], 1        // Se carga el primer byte del comando HASTA en w2
            LDRB w3, [x1], 1        // Se carga el primer byte del comando del usuario en w3

            CBZ w2, maximo_second_cell  // Si se llega al final del comando HASTA se continua con la siguiente celda

            CMP w2, w3              // Se compara si los bytes son iguales
            BNE maximo_error          // Si no son iguales se asume que es un error

            B maximo_cont_Loop
    
    // Se obtiene la celda de fin
    maximo_second_cell:

        MOV x23, 0              // Se usa como flag para saber si se encontro una columna | 0 = No se encontro, 1 = Se encontro

        MOV x24, 0              // Se usa como flag para saber si se encontro la fila | 0 = No se encontro, 1 = Se encontro

        LDR x5, =colum2       // Se carga la direccion de memoria de la variable colum2 en x5
        LDR x6, =row2          // Se carga la direccion de memoria de la variable row2 en x6

        maximo_second_Loop:

            LDRB w2, [x1], 1    // Se carga el primer byte del comando del usuario en w2

            CMP w2, 32          // Se compara si el byte es un espacio
            BEQ Maximo_Ejecutar   // Si es un espacio se continua con el resto del comando

            CMP w2, 10          // Se compara si el byte es un salto de linea
            BEQ Maximo_Ejecutar   // Si es un salto de linea se continua con el resto del comando

            CMP w2, 65                  // Se compara si el byte es una A
            BGE maximo_second_column      // Si es mayor o igual a A se asume que es una columna

            CMP w2, 48                  // Se compara si el byte es un 0
            BGE maximo_second_row         // Si es mayor o igual a 0 se asume que es una fila

            CMP w2, 45                  // Se compara si el byte es un -
            BEQ maximo_error              // Si es un - se asume que es un error

            B maximo_error                // Si no es ninguno de los anteriores se asume que es un error

            maximo_second_column:

                CMP w2, 75              // Se compara si el byte es una K
                BGT maximo_error          // Si es mayor a K se asume que es un error

                SUB w2, w2, 65          // Se le resta 65 al valor de w2 para obtener el numero de columna
                STRB w2, [x5], 1        // Se guarda el valor de la columna en la variable colum2
                MOV x23, 1              // Se cambia el flag de columna a 1

                B maximo_second_Loop
            
            maximo_second_row:

                CMP w2, 57              // Se compara si el byte es un 9
                BGT maximo_error          // Si es mayor a 9 se asume que es un error

                STRB w2, [x6], 1        // Se guarda el valor de la fila en la variable row2
                MOV x24, 1              // Se cambia el flag de fila a 1

                B maximo_second_Loop
    
    // Se ejecuta la funcion de llenar
    Maximo_Ejecutar:

        LDR x20, =arreglo        // Se carga la direccion de memoria de la arreglo en x20

        CBZ x23, maximo_error     // Si no se encontro la columna se asume que es un error
        CBZ x24, maximo_error     // Si no se encontro la fila se asume que es un error

        // Se compara si el Llenar es en la misma fila o en la misma columna

        LDR x5, =colum        // Se carga la direccion de memoria de la variable colum en x5
        LDR x6, =colum2       // Se carga la direccion de memoria de la variable colum2 en x6

        LDRB w2, [x5]           // Se carga el valor de la columna en w2
        LDRB w3, [x6]           // Se carga el valor de la columna2 en w3

        CMP w2, w3              // Se compara si las columnas son iguales
        BNE compare_row_max         // Si no son iguales se asume que es en la misma fila

        B same_column_max

        compare_row_max:

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

            CMP w21, w9                     // Se compara si las filas son iguales
            BNE maximo_error              // Si no son iguales, entonces es asume que es un error

            B same_row_max
        
        // ---------------------------- SE ANALIZA LA MISMA COLUMNA | EJEMPLO = MAXIMO DESDE A1 HASTA A16 ----------------------------
        same_column_max:

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
            BGT maximo_error              // Si la fila de inicio es mayor a la fila de fin se asume que es un error

            MOV x12, #23                // Se carga el valor de la columna en x12

            CMP w9, w12                 // Se compara si la fila de fin es mayor a 23
            BGT maximo_error              // Si la fila de fin es mayor a 23 se asume que es un error

            same_column_pre_min:

                MOV x0, 0              // Se inicializa x0 con 0
                LDR x1, =retorno       // Se carga la direccion de memoria de la variable retorno en x1
                STR x0, [x1]           // Se limpia la variable retorno
                MOV x7, x9              // Se guarda la direccion de memoria de la fila final en x7
                MOV x18, 0              // Se inicializa x18 con 0

                MAX_same_column_Loop:

                    // x21 = row de inicio | x7 = row de fin

                    LDR x5, =colum        // Se carga la direccion de memoria de la variable colum en x5
                    LDRB w16, [x5]          // Se carga el valor de la columna en w16

                    SUB x24, x21, 1         // Se resta 1 a la fila de inicio
                    MOV x25, 12             // Se multiplica la fila de inicio por 12
                    MUL x25, x25, x24
                    ADD x25, x25, x16       // Se suma el valor de la columna

                    LDR x9, [x20, x25, LSL 3]   // Se carga el valor de la posicion en la arreglo en x9

                    LDR x6, =retorno       // Se carga la direccion de memoria de la variable retorno en x5
                    LDR x5, [x6]           // Se carga el valor de retorno en x5

                    CBNZ w18, MAX_column_non_first_value  // Si no es la primera vez que entra al ciclo, que continue

                    MOV x18, 1              // Se cambia el flag de primera vez a 1

                    STR x9, [x6]           // Se guarda el valor en la variable retorno

                    B MAX_col_continue_Loop

                    MAX_column_non_first_value:
                        
                        CMP w9, w5             // Se compara si el valor de retorno, es mayor al valor de la arreglo
                        BLE MAX_col_continue_Loop      // Si es mayor se continua con el loop

                        STR x9, [x6]           // Se guarda el valor en la variable retorno

                    MAX_col_continue_Loop:

                        CMP x21, x7             // Se compara si la fila de inicio es igual a la fila de fin
                        BEQ MAX_same_column_end     // Si son iguales se termina el llenado

                        ADD x21, x21, 1         // Se suma 1 a la fila de inicio

                    B MAX_same_column_Loop
            
            MAX_same_column_end:
                
                LDP x29, x30, [sp], 16      // Se recupera el link register y el frame pointer de la pila

                BL excel

        // ---------------------------- SE ANALIZA LA MISMA FILA | EJEMPLO = MAXIMO DESDE A1 HASTA G1 ----------------------------
        same_row_max:

            LDR x5, =colum        // Se carga la direccion de memoria de la variable colum en x5
            LDRB w5, [x5]           // Se carga el valor de la columna en w5

            LDR x6, =colum2       // Se carga la direccion de memoria de la variable colum2 en x6
            LDRB w6, [x6]           // Se carga el valor de la columna2 en w6

            CMP w5, w6              // Se compara si la columna 1 es mayor a la columna 2
            BGT maximo_error          // Si la columna 1 es mayor a la columna 2 se asume que es un error

            MAX_same_row_pre:

                MOV x0, 0              // Se inicializa x0 con 0
                LDR x1, =retorno       // Se carga la direccion de memoria de la variable retorno en x1
                STR x0, [x1]           // Se limpia la variable retorno
                MOV x21, x5              // Se guarda el valor de la columna en x21
                MOV x7, x6               // Se guarda el valor de la columna2 en x7
                MOV x18, 0              // Se inicializa x18 con 0

                LDR x5, =row           // Se carga la direccion de memoria de la variable row en x5
                LDR x8, =row           // Se carga la direccion de memoria de la variable row en x8

                STP x29, x30, [sp, -16]!    // Se guarda la direccion de memoria de la arreglo y la fila en la pila
                BL atoi
                LDP x29, x30, [sp], 16      // Se recupera la direccion de memoria de la arreglo y la fila de la pila

                MOV x26, x9             // Se guarda el valor de la fila en x26

                MAX_same_row_Loop:

                    // x21 = colum de inicio | x7 = colum de fin | x26 = row

                    SUB x24, x26, 1             // Se resta 1 a la columna de inicio
                    MOV x17, 12                 // Se multiplica la columna de inicio por 12
                    MUL x17, x17, x24           // Se multiplica la columna de inicio por 12
                    ADD x17, x17, x21           // Se suma el valor de la columna

                    LDR x9, [x20, x17, LSL 3]   // Se guarda el valor en la arreglo

                    LDR x6, =retorno       // Se carga la direccion de memoria de la variable retorno en x5
                    LDR x5, [x6]           // Se carga el valor de retorno en x5

                    CBNZ w18, MAX_row_non_first_value  // Si no es la primera vez que entra al ciclo, que continue

                    MOV x18, 1              // Se cambia el flag de primera vez a 1

                    STR x9, [x6]           // Se guarda el valor en la variable retorno

                    B MAX_row_continue_Loop

                    MAX_row_non_first_value:

                        CMP w9, w5             // Se compara si el valor de retorno, es mayor al valor de la arreglo
                        BLE MAX_row_continue_Loop      // Si es mayor se continua con el loop

                        STR x9, [x6]           // Se guarda el valor en la variable retorno
                    
                    MAX_row_continue_Loop:

                        CMP x21, x7                 // Se compara si la columna de inicio es igual a la columna de fin
                        BEQ MAX_same_row_end          // Si son iguales se termina el llenado

                        ADD x21, x21, 1             // Se suma 1 a la columna de inicio

                    B MAX_same_row_Loop
            
            MAX_same_row_end:

                LDP x29, x30, [sp], 16      // Se recupera el link register y el frame pointer de la pila

                BL excel

    maximo_error:

        print errorMaximo, lenErrorMaximo
        print enter2, lenEnter2
        
        LDR x27, =buffer
        read 0, x27, 2

        LDP x29, x30, [sp], 16      // Se recupera el link register y el frame pointer de la pila

        BL excel

