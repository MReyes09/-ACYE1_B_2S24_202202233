.global menu_LecturaArchivo
.data

//-------------------------------------------------------------------------
//Declaracion de mensajes

modelo:
    .asciz " || "
    lenModelo = .- modelo

salto:
    .asciz "\n"
    lenSalto = .- salto

espacio:
    .asciz " "
    lenEspacio = .- espacio

subMenu_msg:
    .asciz " || ------------------------------------------------------ \n"
    .asciz " || Menu de lectura de archivo CSV\n"            
    .asciz " || ------------------------------------------------------ \n"
lenMenu = . - subMenu_msg

File_msg:
    .asciz " || > Ingrese la ruta del archivo CSV: "
lenFile = . - File_msg

enter:        
    .asciz " || Presiona Enter para continuar...\n"
lenEnter = .- enter

clear_screen:   
    .asciz "\033[2J\033[H"  // Código ANSI para limpiar pantalla

errorOpenFile:
    .asciz " || Error al abrir el archivo\n"
    lenErrOpenFile = .- errorOpenFile

readSuccess:
    .asciz " || El Archivo Se Ha Leido Correctamente\n"
    lenReadSuccess = .- readSuccess

msgProcesando:
    .asciz " || Procesando archivo...\n"
    lenProcesando = .- msgProcesando

//-------------------------------------------------------------------------

//-------------------------------------------------------------------------
//Declaracion de variables
.bss

file_Path:
    .zero 50

buffer_LecturaArchivo: 
    .space 2                       // Para almacenar la entrada del usuario

fileDescriptor:
    .space 8

opcion:
    .space 2

num:
    .space 12

character:
    .byte 0

// -------------------------------------------------------------------------

//Declaracion de funciones
.text


// Macro para imprimir strings
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

getFilename:
    print 1, subMenu_msg, lenMenu   // Mostrar mensaje de subMenu
    print 1, File_msg, lenFile      // Mostrar mensaje de File_msg
    read 0, file_Path, 50           // Recibe la ruta del archivo

    // Agregar caracter nulo al final del nombre del archivo
    LDR x0, =file_Path
    //while (*x0 != '\n') x0++;
    loop:
        LDRB w1, [x0], 1 // carga el caracter en w1 y aumenta x0

        // verifica si es un salto de linea
        // if (w1 == 10)
        CMP w1, 10
        BEQ endLoop // si es un salto de linea termina el loop
        B loop

        endLoop: //agrega un caracter nulo al final del nombre del archivo
            MOV w1, 0
            STRB w1, [x0, -1]!
    
    RET

openFile:
    // param: x1 -> filename
    MOV x0, -100                // O_RDONLY significa que el archivo se abre solo para lectura
    MOV x2, 0                   // Mov x2 = 0 para que el archivo se abra en modo de solo lectura
    MOV x8, 56                  // syscall open
    SVC 0                       // Llamada al sistema    

    CMP x0, 0                       // Verificar si el archivo se abrió correctamente
    BLE op_f_error                  // Si x0 es menor o igual a 0, hubo un error al abrir el archivo
    LDR x9, =fileDescriptor         // Cargar la dirección de fileDescriptor
    // EL fileDescriptor sirve para guardar el descriptor de archivo
    // el descriptor del archivo es un número entero que identifica unívocamente un archivo abierto en un proceso
    
    STR x0, [x9]                    // Guardar el descriptor de archivo en fileDescriptor
    B op_f_end

    op_f_error:
        print 1, errorOpenFile, lenErrOpenFile
        read 0, opcion, 1

    op_f_end:
        RET


closeFile:
    LDR x0, =fileDescriptor
    LDR x0, [x0]
    MOV x8, 57
    SVC 0
    RET

readCSV:
    //Imprimimos el mensaje de procesando archivo
    print 1, msgProcesando, lenProcesando

    // code para leer numero y convertir
    LDR x10, =num                       // Buffer para almacenar el numero
    LDR x11, =fileDescriptor            // Cargar la dirección de fileDescriptor
    LDR x11, [x11]                      // Cargar el descriptor de archivo
    // el comando LDR x11, [x11] carga el valor de fileDescriptor en x11

    rd_num:
        read x11, character, 1          // Leer un caracter del archivo
        LDR x4, =character              // Cargar la dirección de character en x4
        LDRB w3, [x4]                   // Cargar el valor de character en w3
        //if (w3 == ',') goto rd_cv_num
        CMP w3, 44                      // Comparar con el valor ASCII de ','
        BEQ rd_cv_num

        MOV x20, x0                     // Guardar el valor de x0 en x20
        CBZ x0, rd_cv_num               // Si x0 es 0, saltar a rd_cv_num    

        STRB w3, [x10], 1               // Guardar el valor de w3 en num y aumentar la dirección de num en 1 byte, esto sirve para guardar el número en num
        B rd_num                        // Saltar a rd_num

    rd_cv_num:
        LDR x5, =num                        // Cargar la dirección de num en x5
        LDR x8, =num                        // Cargar la dirección de num en x8
        LDR x12, =array                     // Cargar la dirección de array en x12

        STP x29, x30, [SP, -16]!            // Guardar los registros x29 y x30 en la pila

        BL atoi                             // Llamar a la función atoi

        LDP x29, x30, [SP], 16

        LDR x12, =num
        MOV w13, 0
        MOV x14, 0

        cls_num:
            STRB w13, [x12], 1
            ADD x14, x14, 1
            CMP x14, 6
            BNE cls_num
            LDR x10, =num
            CBNZ x20, rd_num

    rd_end:
        print 1, salto, lenSalto
        print 1, readSuccess, lenReadSuccess
        read 0, opcion, 2
        RET

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

// Menu de lectura de archivo
menu_LecturaArchivo:
    
    // Limpiar la consola
    MOV X0, #1                      // File descriptor (stdout)
    LDR X1, =clear_screen           // Limpiar la pantalla
    MOV X2, #7                      // Longitud del comando ANSI
    MOV X8, #64                     // sys_write syscall
    SVC #0                          // Llamada al sistema

    // Redirigir a la subrutina getFilename
    bl getFilename

    // Redirigir a la subrutina openFile
    ldr x1, =file_Path // Cargar la dirección de file_Path
    bl openFile

    // procedimiento para leer los numeros del archivo
    bL readCSV

    // funcion para cerrar el archivo
    BL closeFile 

    // Limpiar el buffer: eliminar el '\n' que queda en el buffer después de la lectura
    ldr x1, =file_Path
    mov x2, 50
    bl clean_newline

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

    // Mostrar mensaje para continuar
    mov x0, 1                      // File descriptor (stdout)
    ldr x1, =enter                 // Cargar dirección del mensaje "Presiona Enter"
    mov x2, lenEnter               // Longitud del mensaje
    mov x8, 64                     // syscall sys_write
    svc 0                          // Llamada al sistema

    // Leer entrada del usuario (esperar "Enter")
    mov x0, 0                      // File descriptor (stdin)
    ldr x1, =buffer_LecturaArchivo  // Cargar dirección del buffer_LecturaArchivo
    mov x2, 2                      // Leer 2 bytes (por el '\n')
    mov x8, 63                     // syscall sys_read
    svc 0                          // Llamada al sistema

    b menu

// Subrutina para limpiar '\n' del buffer
clean_newline:
    // Iterar sobre la cadena y reemplazar el '\n' con un carácter nulo
    mov x3, 0              // Inicializar el índice
    clean_loop:
        ldrb w4, [x1, x3]   // Leer un byte de file_Path
        cmp w4, 10          // Comparar con el valor ASCII de '\n' (10)
        beq found_newline   // Si es '\n', saltar
        add x3, x3, 1       // Incrementar el índice
        cmp x3, x2          // Comparar con el tamaño máximo de lectura (100)
        bne clean_loop      // Si no se ha alcanzado el final, continuar
        b end_clean         // Terminar si se ha recorrido toda la cadena

    found_newline:
        mov w4, 0           // Reemplazar '\n' con '\0' (carácter nulo)
        strb w4, [x1, x3]   // Guardar el carácter nulo en file_Path

    end_clean:
        ret






