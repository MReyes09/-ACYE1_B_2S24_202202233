.global _start

    .extern encabezado
    .extern menu
 
    
    .text

_start:
    bl encabezado       // Llamar a la función mi_funcion
    bl menu 


    mov x0, 0
    mov x8, 93          // Syscall para salir
    svc 0
