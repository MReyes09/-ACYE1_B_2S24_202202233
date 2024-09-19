

.global resta

.data

msg1:
    .ascii "|| > Ingrese el primer valor: "
    lenMsg1 = .- msg1
msg2:
    .ascii "|| > ngrese el segundo valor: "
    lenMsg2 = .- msg2
resultado:
    .ascii "|| La resta es: "
    lenResultado = .- resultado
     input_BuffUser: .skip 1

input1:
    .space 10
input2:
    .space 10
result:
    .space 12
newline:
    .ascii "\n"

.text
            // retornar
resta:
    // Leer entrada del usuario (esperar Enter)
    mov x0, 0
    ldr x1, =input_BuffUser
    mov x2, 16                // Leer hasta 16 bytes (suficiente para capturar 'Enter')
    mov x8, 63
    svc 0
    // Mostrar mensaje
    mov x0, 1         // stdout
    ldr x1, =msg1      // cargar mensaje
    mov x2, lenMsg1    // tamaño mensaje
    mov x8, 64        // syscall write
    svc 0             // llamada al sistema

    // Leer primer número
    mov x0, 0         // stdin
    ldr x1, =input1   // cargar input1
    mov x2, 10        // tamaño input1
    mov x8, 63        // syscall read
    svc 0             // llamada al sistema

    // Mostrar mensaje
    mov x0, 1         // stdout
    ldr x1, =msg2      // cargar mensaje
    mov x2, lenMsg2    // tamaño mensaje
    mov x8, 64        // syscall write
    svc 0             // llamada al sistema
    // Leer segundo número
    mov x0, 0         // stdin
    ldr x1, =input2   // cargar input2
    mov x2, 10        // tamaño input2
    mov x8, 63        // syscall read
    svc 0             // llamada al sistema

    // Convertir input1 a entero (atoi)
    ldr x0, =input1   // cargar input1
    bl atoi           // llamar a atoi
    mov w5, w0        // guardar resultado en w5

    // Convertir input2 a entero (atoi)
    ldr x0, =input2   // cargar input2
    bl atoi           // llamar a atoi
    mov w6, w0        // guardar resultado en w6

    // Sumar los dos números
    sub w7, w5, w6    // w7 = w5 + w6

    // Convertir resultado a cadena (itoa)
    mov w0, w7        // cargar resultado
    ldr x1, =result   // cargar dirección de resultado
    bl itoa           // llamar a itoa

    // Mostrar mensaje
    mov x0, 1         // stdout
    ldr x1, =resultado      // cargar mensaje
    mov x2, lenResultado    // tamaño mensaje
    mov x8, 64        // syscall write
    svc 0             // llamada al sistema

    // Mostrar resultado
    mov x0, 1         // stdout
    ldr x1, =result   // cargar resultado
    mov x2, 12        // tamaño resultado
    mov x8, 64        // syscall write
    svc 0             // llamada al sistema

    // Mostrar nueva línea
    mov x0, 1         // stdout
    ldr x1, =newline  // cargar nueva línea
    mov x2, 1         // tamaño nueva línea
    mov x8, 64        // syscall write
    svc 0             // llamada al sistema

    // Salir del programa
  //mov x8, 93        // syscall exit
  //svc 0             // llamada al sistema
  b menu  

// Función atoi: convierte cadena a entero
atoi:
    mov w1, 0         // resultado
atoi_loop:
    ldrb w2, [x0], 1  // cargar byte y avanzar
    sub w2, w2, '0'   // convertir a número
    cmp w2, 9         // verificar si es número
    bhi atoi_end      // si no es, salimos
    mov w3, 10        // multiplicador
    mul w1, w1, w3    // multiplicar resultado por 10
    add w1, w1, w2    // sumar dígito
    b atoi_loop       // repetir
atoi_end:
    mov w0, w1        // mover resultado a w0
    ret               // retornar

// Función itoa: convierte entero a cadena
itoa:
    mov w2, 10        // base 10
    add x1, x1, 11    // mover puntero al final
    strb wzr, [x1]    // agregar terminador nulo
itoa_loop:
    udiv w3, w0, w2   // dividir número por 10
    msub w4, w3, w2, w0 // obtener residuo
    add w4, w4, '0'   // convertir a carácter
    sub x1, x1, 1     // retroceder puntero
    strb w4, [x1]     // almacenar carácter
    mov w0, w3        // actualizar número
    cbnz w0, itoa_loop// repetir mientras no sea cero
    ret       
ret
