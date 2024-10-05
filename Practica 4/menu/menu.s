.global menu
.global array
.global count
.global num
.extern lectura
.extern menuBubble

.data

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

enter:        
    .asciz " || Presiona Enter para continuar...\n"
lenEnter = .- enter

menu_text:
    .asciz "\n"
    .asciz " || --------------------------------\n"
    .asciz " || Menu Principal                  \n"
    .asciz " || 1. Ingreso de lista de números  \n"
    .asciz " || 2. Bubble Sort                  \n"
    .asciz " || 3. Quick Sort                   \n"
    .asciz " || 4. Insertion Sort               \n"
    .asciz " || 5. Merge Sort                   \n"
    .asciz " || 6. Salir del programa           \n"
    .asciz " || --------------------------------\n"
lenMenu = .- menu_text

seleccion_text: 
    .asciz " || > Selecciona una opcion: "
lenSeleccion = .- seleccion_text

clear_screen:   
    .asciz "\033[2J\033[H"  // Código ANSI para limpiar pantalla

.bss
//-------------------------------------------------------------------------
//Declaracion de variables
buffer: 
    .space 2       // Para almacenar la entrada del usuario

//variables globales
count:
    .zero 8

array: 
    .space 1024 // array de 100 enteros de 4 bytes cada uno

num:
    .space 12

numero:
    .space 12
//-------------------------------------------------------------------------

.text

// Macro para imprimir strings
.macro print stdout, reg, len
    MOV x0, \stdout
    LDR x1, =\reg
    MOV x2, \len
    MOV x8, 64
    SVC 0
.endm

//-------------------------------------------------------------------------
//Funcion de impresion
//
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
//-------------------------------------------------------------------------


menu:
    // Limpiar la consola
    MOV X0, #1                      // File descriptor (stdout)
    LDR X1, =clear_screen           // Limpiar la pantalla
    MOV X2, #7                      // Longitud del comando ANSI
    MOV X8, #64                     // sys_write syscall
    SVC #0                          // Llamada al sistema

    // Mostrar menú
    mov x0, 1                    
    ldr x1, =menu_text          
    mov x2, lenMenu              
    mov x8, 64                   
    svc 0

    // Pedir opción al usuario
    mov x0, 1                    
    ldr x1, =seleccion_text      
    mov x2, lenSeleccion         
    mov x8, 64                   
    svc 0

    // Leer entrada del usuario
    mov x0, 0                    
    ldr x1, =buffer             
    mov x2, 1                    
    mov x8, 63                   
    svc 0

    ldrb w1, [x1]                // Cargar entrada del buffer
    //if (w1 == '1') {
    cmp w1, '1'                  // Opcion Submenu ingresar array
    beq opcion_lectura              
    //else if (w1 == '2') {
    cmp w1, '2'                  // Opción 2: 
    beq opcion_BubbleSort             
    //else if (w1 == '3') {
    cmp w1, '3'                  // Opción 3: 
    beq opcion_QuickSort    
    //else if (w1 == '4') {
    cmp w1, '4'                  // Opción 4: 
    beq opcion_InsertionSort        
    //else if (w1 == '5') {
    cmp w1, '5'                  // Opción 5: 
    beq opcion_MergeSort           
    //else if (w1 == '6') { finaliza el programa
    cmp w1, '6'                  // Opción 6:
    beq finalizar                

    // Si la opción no es válida, volver a mostrar el menú
    b menu

finalizar:
    mov x0, 0                    // Llamar a la salida del programa
    mov x8, 93                   
    svc 0

opcion_lectura:
    // Limpiar buffer antes de llamar a la función suma
    mov x0, 0                    // stdin
    ldr x1, =buffer              // dirección del buffer
    mov x2, 2                    // leer 2 bytes para incluir el '\n'
    mov x8, 63                   // syscall para leer
    svc 0

    beq lectura                      // Llamar a la función suma
    
    b menu                        // Regresar al menú después de la suma

opcion_BubbleSort:
    // Limpiar buffer antes de llamar a la función resta
    mov x0, 0                    // stdin
    ldr x1, =buffer              // dirección del buffer
    mov x2, 2                    // leer 2 bytes para incluir el '\n'
    mov x8, 63                   // syscall para leer
    svc 0

    beq menuBubble       // Llamar a la función menuBubble

    b menu


opcion_QuickSort:
    // Limpiar buffer antes de llamar a la función multiplicación
    mov x0, 0                    // stdin
    ldr x1, =buffer              // dirección del buffer
    mov x2, 2                    // leer 2 bytes para incluir el '\n'
    mov x8, 63                   // syscall para leer
    svc 0

    // Llamar a la función multiplicación
    b menu

opcion_InsertionSort:
    // Limpiar buffer antes de llamar a la función división
    mov x0, 0                    // stdin
    ldr x1, =buffer              // dirección del buffer
    mov x2, 2                    // leer 2 bytes para incluir el '\n'
    mov x8, 63                   // syscall para leer
    svc 0

    // Llamar a la función división
    b menu

opcion_MergeSort:
    // Limpiar buffer antes de llamar a la función modulo
    mov x0, 0                    // stdin
    ldr x1, =buffer              // dirección del buffer
    mov x2, 2                    // leer 2 bytes para incluir el '\n'
    mov x8, 63                   // syscall para leer
    svc 0

    // Llamar a la función modulo
    b menu

