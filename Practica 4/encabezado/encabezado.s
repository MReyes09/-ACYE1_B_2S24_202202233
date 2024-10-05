.global encabezado
        .data

clearScreen:        
    .asciz "\033[H\033[2J"         // Secuencia de escape ANSI para limpiar la pantalla
lenClear = .- clearScreen

enter:        
    .asciz " || Presiona Enter para continuar...\n"
lenEnter = .- enter

buffer: 
    .space 2                       // Para almacenar la entrada del usuario

datos:
        .asciz " ||                                               \n"
        .asciz " || Universidad De San Carlos De Guatemala        \n"
        .asciz " || Facultad De Ingenieria                        \n"
        .asciz " || Escuela de Ciencias y Sistemas                \n"
        .asciz " || Arquitectura de Computadoras y Ensambladores 1\n"
        .asciz " || Seccion B                                     \n"
        .asciz " || Estudiante: Matthew Emmanuel Reyes Melgar     \n"
        .asciz " || Carnet: 202202233                             \n"
        .asciz " || \n"
lenDatos = .- datos

        .text

encabezado:

    // Limpiar la consola
    mov x0, 1                      // File descriptor (stdout)
    ldr x1, =clearScreen           // Cargar la secuencia de escape para limpiar pantalla
    mov x2, lenClear               // Longitud de la secuencia
    mov x8, 64                     // syscall sys_write
    svc 0                          // Llamada al sistema

    // Mostrar los datos
    mov x0, 1                      // File descriptor (stdout)
    ldr x1, =datos                 // Cargar dirección de los datos
    mov x2, lenDatos               // Longitud de los datos
    mov x8, 64                     // syscall sys_write
    svc 0                          // Llamada al sistema

    // Mostrar mensaje para continuar
    mov x0, 1                      // File descriptor (stdout)
    ldr x1, =enter                 // Cargar dirección del mensaje "Presiona Enter"
    mov x2, lenEnter               // Longitud del mensaje
    mov x8, 64                     // syscall sys_write
    svc 0                          // Llamada al sistema

    // Leer entrada del usuario (limpiar el buffer)
    mov x0, 0                      // File descriptor (stdin)
    ldr x1, =buffer                // Cargar dirección del buffer
    mov x2, 1                      // Leer 1 byte (Enter)
    mov x8, 63                     // syscall sys_read
    svc 0                          // Llamada al sistema

    // Limpiar la consola
    mov x0, 1                      // File descriptor (stdout)
    ldr x1, =clearScreen           // Cargar la secuencia de escape para limpiar pantalla
    mov x2, lenClear               // Longitud de la secuencia
    mov x8, 64                     // syscall sys_write
    svc 0                          // Llamada al sistema

    ret
