.global menuBubble

.data

// ------------------------- Declaracion de mensajes -------------------------

menu_TypeOrder:
    .asciz "\n"
    .asciz " || --------------------------------\n"
    .asciz " || Tipo de ordenamiento            \n"
    .asciz " || 1. Ascendente                   \n"
    .asciz " || 2. Descendente                  \n"
    .asciz " || 3. Volver                       \n"
    .asciz " || --------------------------------\n"
lenMenuTypeOrder = .- menu_TypeOrder

subMenu_TypeOrden:
    .asciz " || ------------------------------- \n"
    .asciz " || ¿Cómo desea mostrar el ordenamiento? \n"
    .asciz " || 1. Paso a paso \n"
    .asciz " || 2. Resultado directo \n"
    .asciz " || 3. Volver \n"
    .asciz " || ------------------------------- \n"
    .asciz " || Ingrese el número: "
lenSubMenuTypeOrden = .- subMenu_TypeOrden

seleccion_text: 
    .asciz " || > Selecciona una opcion: "
lenSeleccion = .- seleccion_text

arrayinicial:
    .asciz " || Arreglo base: "
lenArrayInicial = .- arrayinicial

numeroiteracion:
    .asciz " || No. Paso: "
lenNumeroIteracion = .- numeroiteracion

arrayfinal:
    .asciz " || Arreglo ordenado: "
lenArregloOrdenado = .- arrayfinal

enter:        
    .asciz " || Presiona Enter para continuar...\n"
lenEnter = .- enter

modelo:
    .asciz " || "
    lenModelo = .- modelo

salto:
    .asciz "\n"
    lenSalto = .- salto

espacio:
    .asciz " "
    lenEspacio = .- espacio

clear_screen:   
    .asciz "\033[2J\033[H"  // Código ANSI para limpiar pantalla

dospuntos:
    .asciz "-> "
lenDosPuntos = .- dospuntos

// ------------------------- Fin de declaracion de mensajes -------------------------


//  ----------------------- Declaracion de variables -----------------------
.bss

buffer3:
    .space 12       // Para almacenar la entrada del usuario

typeOrder:
    .space 12       // Para almacenar si es ascendente o descendente

typeStepOrden:
    .space 12       // Para almacenar si se hace paso a paso o no

arrayordenado:
    .space 1024 // array de 100 enteros de 4 bytes cada uno

numero:
    .space 12

//------------------------- Fin de declaracion de variables -------------------------

// ------------------------- Declaracion de funciones -------------------------

.text

// Macro para imprimir strings
.macro print stdout, reg, len
    MOV x0, \stdout
    LDR x1, =\reg
    MOV x2, \len
    MOV x8, 64
    SVC 0
.endm

//------------------------- MENU BubbleSort -------------------------
// Aqui comienza la logica de la funcion menuBubble
menuBubble:   //este es el principal menu

    BL copy_array
    // Limpiar la consola
    MOV X0, #1                      // File descriptor (stdout)
    LDR X1, =clear_screen           // Limpiar la pantalla
    MOV X2, #7                      // Longitud del comando ANSI
    MOV X8, #64                     // sys_write syscall
    SVC #0                          // Llamada al sistema

    print 1, menu_TypeOrder, lenMenuTypeOrder
    print 1, seleccion_text, lenSeleccion
    
    // Leer entrada del usuario
    mov x0, 0                    
    ldr x1, =buffer3             
    mov x2, 1                    
    mov x8, 63                   
    svc 0

    ldrb w1, [x1]                // Cargar entrada del buffer3
    //if (w1 == '1') {
    cmp w1, '1'                  // Opcion Submenu ingresar ordenamiento ascendente
    //asignar a la variable typeOrder el valor de 1 si es ascendente
    beq typeOrdenAscendente            
    //else if (w1 == '2') {      
    cmp w1, '2'                  // opcion Submenu ingresar ordenamiento descendente
    //asignar a la variable typeOrder el valor de 0 si es descendente
    beq typeOrdenDescendente

    //else if(w1 == '3') {
    cmp w1, '3'                  // opcion Submenu ingresar ordenamiento descendente
    b menu            
    // else {
    b menuBubble
    // }

// ------------------------ FIN MENU BubbleSort ------------------------

//typeOrdenAscendente:
typeOrdenAscendente:

    MOV x3, #1                              // se carga el valor 1 en x3, se usara para saber si es ascendente o descendente
    LDR x2, =typeOrder                      // se carga la direccion de memoria de formaordenamiento en x2
    STR x3, [x2]                            // se carga el valor de la opcion en formaordenamiento

    b subMenu_TypeOrdenPrint

//typeOrdenDescendente:
typeOrdenDescendente:

    MOV x3, #0                              // se carga el valor 1 en x3, se usara para saber si es ascendente o descendente
    LDR x2, =typeOrder                      // se carga la direccion de memoria de formaordenamiento en x2
    STR x3, [x2]                            // se carga el valor de la opcion en formaordenamiento

    b subMenu_TypeOrdenPrint

// ------------------------- SubMenu BubbleSort -------------------------

subMenu_TypeOrdenPrint:
    // Limpiar la consola
    MOV X0, #1                      // File descriptor (stdout)
    LDR X1, =clear_screen           // Limpiar la pantalla
    MOV X2, #7                      // Longitud del comando ANSI
    MOV X8, #64                     // sys_write syscall
    SVC #0                          // Llamada al sistema

    // Limpiar buffer3 antes de llamar a la función suma
    mov x0, 0                    // stdin
    ldr x1, =buffer3              // dirección del buffer3
    mov x2, 2                    // leer 2 bytes para incluir el '\n'
    mov x8, 63                   // syscall para leer
    svc 0

    print 1, subMenu_TypeOrden, lenSubMenuTypeOrden
    
    // Leer entrada del usuario
    mov x0, 0                    
    ldr x1, =buffer3             
    mov x2, 1                    
    mov x8, 63                   
    svc 0

    ldrb w1, [x1]                // Cargar entrada del buffer3

    //if (w1 == '1') {
    cmp w1, '1'                  // Opcion Submenu mostrar paso a paso
    beq typeStepOrdenPasoAPaso        
    //else if (w1 == '2') {      
    cmp w1, '2'                  // opcion Submenu mostrar resultado directo
    beq typeStepOrdenResultadoDirecto
    //else if (w1 == '3') {      
    cmp w1, '3'                  // opcion para volver al menu
    beq menuBubble

    b subMenu_TypeOrdenPrint

//typeStepOrdenPasoAPaso:
typeStepOrdenPasoAPaso:

    MOV x3, #1                              // se carga el valor 1 en x3, se usara para saber si es paso a paso o no
    LDR x2, =typeStepOrden                 // se carga la direccion de memoria de stepbystep en x2
    STR x3, [x2]                           // se carga el valor de la opcion en stepbystep

    b bubblesort

//typeStepOrdenResultadoDirecto:
typeStepOrdenResultadoDirecto:

    MOV x3, #0                              // se carga el valor 0 en x3, se usara para saber si es paso a paso o no
    LDR x2, =typeStepOrden                 // se carga la direccion de memoria de stepbystep en x2
    STR x3, [x2]                           // se carga el valor de la opcion en stepbystep

    bl bubblesort    

// Funcion para copiar el arreglo ingresado a un nuevo arreglo
copy_array:

    LDR x0, =array            // se carga la direccion de memoria de array en x0
    LDR x1, =arrayordenado    // se carga la direccion de memoria de arrayordenado en x1

    LDR x2, =count             // se carga la direccion de memoria de length en x4
    LDR x2, [x2]                // se carga el valor de length en x4
    MOV x7, 0                   // se carga el valor 0 en x7, se usara como contador

copy_loop:

    LDR w3, [x0], 4           // se carga el valor de array en w3 y se incrementa la direccion de memoria
    STR w3, [x1], 4           // se guarda el valor en la direccion de memoria de arrayordenado y se incrementa la direccion de memoria
    SUB x2, x2, 1             // se decrementa el contador
    CBNZ x2, copy_loop        // si el contador es 0, se termina

    RET

// ------------------------ Funciones de BubbleSort ------------------------
bubblesort:

    print 1, arrayinicial, lenArrayInicial

    BL imprimir_array // se llama a la funcion para imprimir el array

    LDR x20, =count // se carga la direccion de memoria de length en x20
    LDR x20, [x20]// se carga el valor de length en x20

    MOV x21, 0 // se carga el valor 0 en x21, se usara como i
    SUB x20, x20, 1 // se decrementa la longitud en 1

    LDR x16, =typeOrder              // se carga la direccion de memoria de typeOrder en x16
    LDR w16, [x16]                   // se carga el valor de formaordenamiento en w16

    LDR x12, =typeStepOrden          // se carga la direccion de memoria de typeStepOrden en x12
    LDR w8, [x12]                    // se carga el valor de stepbystep en w12

    MOV x17, 0 // se usara como contadora de iteraciones

    B bubblesort_loop

bubblesort_loop:

    MOV x9, 0 // se carga el valor 0 en x9, se usara como j
    SUB x19, x20, x21 // se resta la longitud con i (length - 1 - i)

    bubblesort_innerloop:

        LDR x3, =arrayordenado      // se carga la direccion de memoria de arrayordenado en x3
        LDR w4, [x3, x9, LSL2]      // se carga el valor de array[j] en w4
        ADD x9, x9, 1               // se incrementa j
        LDR w5, [x3, x9, LSL2]      // se carga el valor de array[j + 1] en w5

        // orden ascendente
        CBNZ w16, bubblesort_ascendente // se compara si es 1, para ordenar de forma ascendente

        // orden descendente
        CMP w4, w5 // se compara si array[j] es mayor que array[j + 1]
        BGT bubblesort_cmp // si es menor, se envia a comparar para continuar con el ciclo

        B bubblesort_intercambio

    bubblesort_ascendente:
        // imprime el enter para continuar

        CMP w4, w5                // se compara si array[j] es menor que array[j + 1]
        BLT bubblesort_cmp        // si es mayor, se envia a comparar para continuar con el ciclo

    bubblesort_intercambio:

        STR w4, [x3, x9, LSL2]      // se guarda el valor de array[j] en array[j + 1]
        SUB x9, x9, 1               // se decrementa j
        STR w5, [x3, x9, LSL2]      // se guarda el valor de array[j + 1] en array[j]
        ADD x9, x9, 1               // se incrementa j

        CBZ w8, bubblesort_cmp // si es 0, se envia a comparar para continuar con el ciclo

        print 1, numeroiteracion, lenNumeroIteracion

        ADD x17, x17, 1 // se incrementa la contadora de iteraciones

        print 1, numero, x17 // se imprime el numero
        
        MOV w0, w17 // se carga el valor de la contadora de iteraciones en w0
        LDR x1, =numero // se carga la direccion de memoria de numero en x1

        BL itoa // se llama a la funcion itoa para convertir el numero a ASCII

        print 1, dospuntos, lenDosPuntos

        BL imprimir_array_Ordenado // se llama a la funcion para imprimir el array

        B bubblesort_cmp

    bubblesort_cmp:

        CMP x9, x19 // se compara si j es igual a i
        BNE bubblesort_innerloop // si no es igual, se repite el ciclo

        ADD x21, x21, 1 // se incrementa i
        CMP x21, x20 // se compara si i es igual a length - 1
        BNE bubblesort_loop // si no es igual, se repite el ciclo

        print 1, arrayfinal, lenArregloOrdenado

        BL imprimir_array_Ordenado // se llama a la funcion para imprimir el array
        
        // Mostrar mensaje para continuar
        print 1, enter, lenEnter

        // Limpiar buffer antes de llamar a la función suma
        mov x0, 0                    // stdin
        ldr x1, =buffer3              // dirección del buffer
        mov x2, 2                    // leer 2 bytes para incluir el '\n'
        mov x8, 63                   // syscall para leer
        svc 0

        //pide al usuario que presione enter para continuar
        mov x0, 0                    // stdin
        ldr x1, =buffer3              // dirección del buffer3
        mov x2, 1                    // leer 1 byte (Enter)
        mov x8, 63                   // syscall para leer
        svc 0

        B menuBubble

    

// ------------------------ Fin de funciones de BubbleSort ------------------------

// ------------------------ Funciones Impresion de Arreglo ------------------------

imprimir_array:

    // recorrer array y convertir a ascii
    LDR x9, =count
    LDR x9, [x9] // length => cantidad de numeros leidos del csv
    MOV x7, 0
    LDR x15, =array

    loop_array:
        LDR w0, [x15], 4
        LDR x1, =num

        STP x29, x30, [sp, -16]! // se guarda el valor de x29 y x30 en la pila

        BL itoa

        LDP x29, x30, [sp], 16 // se recupera el valor de x29 y x30 de la pila
        
        print 1, num, x10
        print 1, espacio, lenEspacio
    
        ADD x7, x7, 1
        CMP x9, x7
        BNE loop_array
    
    print 1, salto, lenSalto 

    RET

imprimir_array_Ordenado:
    
        // recorrer array y convertir a ascii
        LDR x4, =count
        LDR x4, [x4] // length => cantidad de numeros leidos del csv
        MOV x7, 0
        LDR x15, =arrayordenado
    
        loop_arrayD:
            LDR w0, [x15], 4
            LDR x1, =num
    
            STP x29, x30, [sp, -16]! // se guarda el valor de x29 y x30 en la pila
    
            BL itoa
    
            LDP x29, x30, [sp], 16 // se recupera el valor de x29 y x30 de la pila
            
            CMP x7, x4
            BNE separadores
        
        print 1, salto, lenSalto 
    
        RET

separadores:
    ADD x7, x7, 1
    print 1, num, x10
    print 1, espacio, lenEspacio
    b loop_arrayD

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
//------------------------- Fin de declaracion de funciones -------------------------

