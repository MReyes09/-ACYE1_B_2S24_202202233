.global menu
.extern suma
.extern resta
.extern multiplicacion
.extern division

.data
enter:        
    .asciz "|| Presiona Enter para continuar...\n"
lenEnter = .- enter

buffer: 
    .space 2       // Para almacenar la entrada del usuario
        
menu_text:
    .asciz "|| ---------------------------\n"
    .asciz "||                           \n"
    .asciz "|| 1. Suma                   \n"
    .asciz "|| 2. Resta                  \n"
    .asciz "|| 3. Multiplicacion         \n"
    .asciz "|| 4. Division               \n"
    .asciz "|| 5. Calculo con memoria    \n"
    .asciz "|| 6. Finalizar calculadora  \n"
    .asciz "||                           \n"
    .asciz "\n"
lenMenu = .- menu_text

seleccion_text: 
    .asciz "|| > Selecciona una opcion: "
lenSeleccion = .- seleccion_text

resultado: 
    .byte 0

.text
menu:
    // Mostrar mensaje para continuar
    mov x0, 1                    
    ldr x1, =enter              
    mov x2, lenEnter           
    mov x8, 64                   
    svc 0
    
    // Limpiar buffer
    mov x0, 0                    
    ldr x1, =buffer              
    mov x2, 1                   
    mov x8, 63                   
    svc 0    

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
    cmp w1, '1'                  // Opción 1: Suma
    beq opcion_suma              
    cmp w1, '2'                  // Opción 2: Resta
    beq opcion_resta             
    cmp w1, '3'                  // Opción 3: Multiplicación
    beq opcion_multiplicacion    
    cmp w1, '4'                  // Opción 4: División
    beq opcion_division          
    cmp w1, '5'                  // Opción 5: Calculo con memoria
    beq opcion_memoria           
    cmp w1, '6'                  // Opción 6: Finalizar
    beq finalizar                

    // Si la opción no es válida, volver a mostrar el menú
    b menu

opcion_suma:
    beq suma                      // Llamar a la función suma
    b menu                       // Regresar al menú después de la suma

opcion_resta:
    beq resta
    b menu

opcion_multiplicacion:
    beq multiplicacion
    b menu

opcion_division:
    beq division
    b menu

opcion_memoria:
     b menu

finalizar:
    mov x0, 0                    // Llamar a la salida del programa
    mov x8, 93                   
    svc 0
