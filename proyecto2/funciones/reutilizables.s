
.global clear_buffer, proc_cls_num
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

clear_buffer:
    LDR x0, =bufferComando  // Cargar dirección de bufferComando en x0
    MOV x1, 50              // Tamaño del buffer en x1
    MOV x2, 0               // Valor de limpieza (cero) en x2
    MOV x3, 0               // Índice del buffer en x3

    clear_loop:
        STRB w2, [x0, x3]       // Escribir 0 en la posición actual del buffer
        ADD x3, x3, 1           // Incrementar índice
        CMP x3, x1              // Comparar índice con tamaño del buffer
        BNE clear_loop          // Repetir hasta limpiar todas las posiciones

        RET                     // Regresar de la función

// -------------------------- FUNCION CLEAR NUMBERS --------------------------
proc_cls_num:
    LDR x0, =num
    MOV x1, 1

    loop_cls:
        STRH wzr, [x0], 1
        ADD x1, x1, 1
        CMP x1, 8
        BNE loop_cls

        RET




    


