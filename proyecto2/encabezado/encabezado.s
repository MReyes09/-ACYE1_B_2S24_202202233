.global encabezado

.text

// Macro para imprimir, usando los registros para mensaje y longitud
.macro print reg_msg, reg_len
    MOV x0, 1              // File descriptor (stdout)
    MOV x1, \reg_msg       // Mensaje
    MOV x2, \reg_len       // Longitud del mensaje
    MOV x8, 64             // syscall sys_write
    SVC 0                  // Llamada al sistema
.endm

// Macro para leer, usando registros para destino y longitud
.macro read reg_dest, reg_len
    MOV x0, 0              // File descriptor (stdin)
    MOV x1, \reg_dest      // Dirección de destino
    MOV x2, \reg_len       // Longitud de lectura
    MOV x8, 63             // syscall sys_read
    SVC 0                  // Llamada al sistema
.endm

encabezado:

    // Limpiar la consola
    LDR x10, =clearScreen   // Cargar la dirección de clearScreen en x10
    LDR x11, =lenClear      // Cargar la longitud de clearScreen en x11
    print x10, x11          // Llamar a la macro print

    // Mostrar los datos
    LDR x10, =datos         // Cargar la dirección de datos en x10
    LDR x11, =lenDatos      // Cargar la longitud de datos en x11
    print x10, x11          // Llamar a la macro print

    // Mostrar mensaje para continuar
    LDR x10, =enter         // Cargar la dirección del mensaje "Presiona Enter" en x10
    LDR x11, =lenEnter      // Cargar la longitud de enter en x11
    print x10, x11          // Llamar a la macro print

    // Leer entrada del usuario (limpiar el buffer)
    LDR x10, =buffer        // Cargar la dirección de buffer en x10
    MOV x11, 1              // Leer 1 byte
    read x10, x11           // Llamar a la macro read

    // Limpiar la consola nuevamente
    LDR x10, =clearScreen   // Cargar la dirección de clearScreen en x10
    LDR x11, =lenClear      // Cargar la longitud de clearScreen en x11
    print x10, x11          // Llamar a la macro print

    ret
