
.global encabezado
        .data
        

datos:
        .asciz "||                                               \n"
        .asciz "|| Universidad De San Carlos De Guatemala        \n"
        .asciz "|| Facultad De Ingenieria                        \n"
        .asciz "|| Escuela de Ciencias y Sistemas                \n"
        .asciz "|| Arquitectura de Computadoras y Ensambladores 1\n"
        .asciz "|| Seccion B                                     \n"
        .asciz "|| Estudiante: Matthew Emmanuel Reyes Melgar     \n"
        .asciz "|| Carnet: 202202233                             \n"
        .asciz "||                                               \n"
        .asciz "\n"
        
lenDatos = .- datos

        .text

encabezado:

    mov x0, 1
    ldr x1, =datos
    mov x2, lenDatos  
    mov x8, 64
    svc 0

    ret
    