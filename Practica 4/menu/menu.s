.global menu
//.extern suma
//.extern resta
//.extern multiplicacion
//.extern division
//.extern opMem

.data
enter:        
    .asciz "|| Presiona Enter para continuar...\n"
lenEnter = .- enter

buffer: 
    .space 2       // Para almacenar la entrada del usuario
        
menu_text:
    .asciz " || --------------------------------\n"
    .asciz " || Menu Principal                  \n"
    .asciz " || 1. Ingreso de lista de números  \n"
    .asciz " || 2. Bubble Sort                  \n"
    .asciz " || 3. Quick Sort                   \n"
    .asciz " || 4. Insertion Sort               \n"
    .asciz " || 5. Merge Sort                   \n"
    .asciz " || 6. Salir del programa           \n"
    .asciz " ||                                 \n"
    .asciz "\n"
lenMenu = .- menu_text

seleccion_text: 
    .asciz " || > Selecciona una opcion: "
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
    cmp w1, '1'                  // Opción 1: 
    //beq opcion_suma              
    cmp w1, '2'                  // Opción 2: 
    //beq opcion_resta             
    cmp w1, '3'                  // Opción 3: 
    //beq opcion_multiplicacion    
    cmp w1, '4'                  // Opción 4: 
    //beq opcion_division          
    cmp w1, '5'                  // Opción 5: 
    //beq opMem           
    cmp w1, '6'                  // Opción 6: 
    beq finalizar                

    // Si la opción no es válida, volver a mostrar el menú
    b menu

finalizar:
    mov x0, 0                    // Llamar a la salida del programa
    mov x8, 93                   
    svc 0
