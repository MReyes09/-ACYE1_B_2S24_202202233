.global proc_import, import_data, atoi
.extern excel

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

atoi:

    STP x4, x5, [sp, -16]!   // se guarda el valor de x4 y x5 en la pila
    STP x6, x7, [sp, -16]!   // se guarda el valor de x6 y x7 en la pila
    STR x8, [sp, -8]!   // se guarda el valor de x8 y x9 en la pila

    // PARAMETROS => x5, x8 -> buffer

    SUB x5, x5, 1   // se decrementa la direccion de memoria del numero, para apuntar al primer caracter y no al nulo

    a_c_digits:

        LDRB w7, [x8], 1        // se carga el valor del caracter en w7 y se incrementa la direccion de memoria
        CBZ w7, a_c_convert     // si el valor es 0, significa que termino de leer el numero
        CMP w7, 10              // se compara si el valor es un salto de linea (ASCII 10)
        BEQ a_c_convert         // si es un salto de linea, significa que termino de leer el numero
        B a_c_digits
    
    a_c_convert:

        SUB x8, x8, 2           // se decrementa la direccion de memoria para apuntar al ultimo caracter del numero
        MOV x4, 1               // se carga el valor 1 en x4, se usara para multiplicar cada numero por la base 10 
        MOV x9, 0               // se carga el valor 0 en x9, se usara para guardar el numero convertido

        a_c_loop:

            LDRB w7, [x8], -1   // se carga el valor del caracter en w7 y se decrementa la direccion de memoria
            CMP w7, 45          // se compara si el valor es un guion (ASCII 45) - indica que es negativo
            BEQ a_c_negative

            SUB w7, w7, 48      // se convierte el valor de ASCII a decimal
            MUL w7, w7, w4      // se multiplica el valor por la base 10
            ADD w9, w9, w7      // se suma el valor al numero convertido

            MOV w6, 10          // se carga el valor 10 en w6
            MUL w4, w4, w6      // se multiplica la base 10 por 10 para el siguiente digito

            CMP x8, x5          // se compara si la direccion de memoria es igual a la direccion de memoria del primer caracter
            BNE a_c_loop
            B a_c_end
        
        a_c_negative:

            NEG w9, w9          // se convierte el numero a negativo
        
        a_c_end:

            LDR x8, [sp], 8         // se recupera el valor de x8 y x9 de la pila
            LDP x6, x7, [sp], 16    // se recupera el valor de x6 y x7 de la pila
            LDP x4, x5, [sp], 16    // se recupera el valor de x4 y x5 de la pila

            RET


proc_import:
    LDR x0, =cmdimp
    LDR x1, =bufferComando

    imp_loop:
        LDRB w2, [x0], 1
        LDRB w3, [x1], 1

        CBZ w2, imp_filename

        CMP w2, w3
        BNE imp_error

        B imp_loop

        imp_error:
            LDR x27, =errorImport
            LDR x26, =lenError

            print 1, x27, x26
            B end_proc_import

    imp_filename:
        LDR x0, =filename
        imp_file_loop:
            LDRB w2, [x1], 1

            CMP w2, 32
            BEQ cont_imp_file

            STRB w2, [x0], 1
            B imp_file_loop

        cont_imp_file:
            STRB wzr, [x0]
            LDR x0, =cmdsep
            cont_imp_loop:
                LDRB w2, [x0], 1
                LDRB w3, [x1], 1                

                CBZ w2, end_proc_import
                B cont_imp_loop
                
                CMP w2, w3
                BNE imp_error
    end_proc_import:
        RET

import_data:
    LDR x1, =filename
    STP x29, x30, [SP, -16]!
    BL openFile
    LDP x29, x30, [SP], 16

    LDR x25, =buffer
    MOV x10, 0
    LDR x11, =fileDescriptor
    LDR x11, [x11]
    MOV x17, 0 //contador de columnas
    LDR x15, =listIndex

    read_head:
        LDR x27, =character
        read x11, x27, 1
        
        LDR x4, =character
        LDRB w2, [x4]

        CMP w2, 9
        BEQ getIndex

        CMP w2, 10
        BEQ getIndex

        STRB w2, [x25], 1
        ADD x10, x10, 1
        B read_head

        getIndex:
            LDR x27, =getIndexMsg
            LDR x26, =lenGetIndexMsg
            print 1, x27, x26

            LDR x27, =buffer
            print 0, x27, x10
            
            LDR x27, =dpuntos
            LDR x26, =lenDpuntos
            print 1, x27, x26
            
            LDR x27, =espacio2
            LDR x26, =lenEspacio2
            print 1, x27, x26            

            LDR x4, =character
            LDRB w7, [x4]

            LDR x27, =character
            read 0, x27, 2

            LDR x4, =character
            LDRB w2, [x4]
            SUB w2, w2, 65
            
            STRB w2, [x15], 1
            ADD x17, x17, 1

            CMP w7, 10
            BEQ end_header

            LDR x25, =buffer
            MOV x10, 0
            B read_head

        end_header:
            STP x29, x30, [SP, -16]!
            BL readCSV
            LDP x29, x30, [SP], 16

            RET
            

readCSV:
    LDR x10, =num
    LDR x11,  =fileDescriptor
    LDR x11, [x11]
    MOV x21, 0  // contador de filas
    LDR x15, =listIndex // contador de columnas

    rd_num:
        LDR x27, =character

        read x11, x27, 1
        LDR x4, =character
        LDRB w3, [x4]

        CMP w3, 9
        BEQ rd_cv_num

        CMP w3, 10
        BEQ espacio_Vacio

        CMP w3, 13
        BEQ rd_num

        MOV x25, x0
        CBZ x0, rd_cv_num

        STRB w3, [x10], 1
        B rd_num

    espacio_Vacio:
        STRB WZR, [x10], 1

    rd_cv_num:
        LDR x5, =num
        LDR x8, =num

        STP x29, x30, [SP, -16]!
        BL atoi
        LDP x29, x30, [SP], 16

        LDRB w16, [x15], 1 // obtener la columna

        LDR x20, =arreglo
        MOV x22, 12
        MUL x22, x21, x22
        ADD x22, x16, x22
        STR x9, [x20, x22, LSL 3]

        LDR x12, =num
        MOV w13, 0
        MOV x14, 0
        
        LDR x20, =listIndex
        SUB x20, x15, x20
        CMP x20, x17
        BNE cls_num
        
        LDR x15, =listIndex
        ADD x21, x21, 1

        cls_num:
            STRB WZR, [x12], 1
            ADD x14, x14, 1
            CMP x14, 8
            BNE cls_num
            LDR x10, =num
            CBNZ x25, rd_num

    rd_end:
        LDR x27, =salto
        LDR x26, =lenSalto
        print 1, x27, x26

        LDR x27, =readSuccess
        LDR x26, =lenReadSuccess
        print 1, x27, x26

        LDR x27, =character
        read 0, x27, 2
        bl excel


openFile:
    // param: x1 => filename
    MOV x0, -100
    MOV x2, 0
    MOV x8, 56
    SVC 0

    CMP x0, 0
    BLE op_f_error
    LDR x9, =fileDescriptor
    STR x0, [x9]
    B op_f_end

    op_f_error:
        LDR x27, =errorOpenFile
        LDR x26, =lenErrorOpenFile
        print 1, x27, x26

        LDR x27, =character
        read 0, x27, 2
    
    op_f_end:
        RET

closeFile:
    LDR x0, =fileDescriptor
    LDR x0, [x0]
    MOV x8, 57
    SVC 0
    RET

