.global _start

.extern encabezado
.extern excel

.text

_start:
    bl encabezado       // Llamar a la función mi_funcion
    bl excel

    mov x0, 0
    mov x8, 93          // Syscall para salir
    svc 0
