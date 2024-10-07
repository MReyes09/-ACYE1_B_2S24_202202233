.global lectura
.extern menu_LecturaArchivo
.extern lecturaConsola

.section .data
menu_msg:       
    .asciz  "\n || ------------------------------------------------------  \n"
    .asciz  " || Como desea ingresar los numeros?                        \n"
    .asciz  " || 1. De forma manual (numero a numero separado por comas) \n"
    .asciz  " || 2. Archivo CSV                                          \n"
    .asciz  " || 3. Regresar                                             \n"
    .asciz  " || ------------------------------------------------------  \n"
    .asciz  " || Ingrese el numero: "
menu_msg_len = . - menu_msg

invalid_option: 
    .asciz " || Opcion no valida, intente de nuevo\n"
invalid_option_len = . - invalid_option

manual_msg:     
    .asciz " || Opcion seleccionada: Ingreso manual\n"
manual_msg_len = . - manual_msg

clear_screen:   
    .asciz "\033[2J\033[H"  // Código ANSI para limpiar pantalla

.section .bss
.lcomm buffer, 2  // Buffer para entrada del usuario

.section .text
lectura:
    // Mostrar el menú en un bucle    
    
    MOV X0, #1                      // File descriptor (stdout)
    LDR X1, =clear_screen           // Limpiar la pantalla
    MOV X2, #7                      // Longitud del comando ANSI
    MOV X8, #64                     // sys_write syscall
    SVC #0                          // Llamada al sistema

menu_lectura_loop:                    // Llamada al sistema

    // Reiniciamos el tamaño del array
    Mov x3, #0
    LDR X2, =count
    STR x3, [x2]

    Mov x3, #0
    LDR X2, =num
    STR x3, [x2]

    MOV X0, #1                      // File descriptor (stdout)
    LDR X1, =menu_msg               // Mostrar el mensaje del menú
    MOV X2, #menu_msg_len           // Longitud del mensaje
    MOV X8, #64                     // sys_write syscall
    SVC #0                          // Llamada al sistema

    // Leer la opción del usuario
    MOV X0, #0                      // File descriptor (stdin)
    LDR X1, =buffer                 // Dirección del buffer de entrada
    MOV X2, #2                      // Longitud del buffer (1 char + '\n')
    MOV X8, #63                     // sys_read syscall
    SVC #0                          // Llamada al sistema

    LDRB W1, [X1]                   // Cargar el valor ingresado

    // Comparar la entrada con las opciones
    CMP W1, #'1'                    // Comparar con '1'
    BEQ opcion_manual               // Si es '1', ir a "opcion_manual"
    CMP W1, #'2'                    // Comparar con '2'
    BEQ opcion_csv                  // Si es '2', ir a "opcion_csv"
    CMP W1, #'3'                    // Comparar con '3'
    b menu                   // Si es '3', volver al menú

    // Opción inválida
    MOV X0, #1
    LDR X1, =invalid_option         // Mostrar mensaje de opción inválida
    MOV X2, #invalid_option_len
    MOV X8, #64
    SVC #0

    B menu_lectura_loop                     // Volver al menú

opcion_manual:

    BEQ lecturaConsola                     // Volver al menú

opcion_csv:
    MOV X0, #1                      // File descriptor (stdout)
    LDR X1, =clear_screen           // Limpiar la pantalla
    MOV X2, #7                      // Longitud del comando ANSI
    MOV X8, #64                     // sys_write syscall
    SVC #0                          // Llamada al sistema
    // Mensaje de opción CSV seleccionada

    BEQ menu_LecturaArchivo            // llamar a la función de lectura de archivo

RET
