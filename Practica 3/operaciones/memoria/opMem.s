.global opMem

.data
valorSecuencia:
    .ascii "\n"
    lenvalorSecuencia = .- valorSecuencia

resultado:
    .ascii " || >El resultado es:\n"
    lenResultado = .- resultado

inputOperacion:
    .space 100         
result:
    .space 12         
newline:
    .ascii "\n"

exit_string:
    .ascii "202202233-exit"

.text 
.macro reset_var var, value

    ldr x1, =\var    // Cargar la dirección de la variable
    mov w0, \value    // Cargar el valor a almacenar
    str w0, [x1]      // Almacenar el valor en la variable
.endm

opMem:
    // Mostrar mensaje de solicitud
    mov x0, 1                 
    ldr x1, =valorSecuencia      
    mov x2, lenvalorSecuencia    
    mov x8, 64                 
    svc 0                      

    // Leer la operacion completa
    mov x0, 0                 
    ldr x1, =inputOperacion    
    mov x2, 100                
    mov x8, 63                
    svc 0                      
  
    ldr x0, =inputOperacion    
    bl check_exit              

    // Parsear y evaluar la operacion
    ldr x0, =inputOperacion    
    bl evaluar_expresion

    // Resetear el buffer result antes de usarlo
    adr x1, result             // Cargar dirección de result
    mov w2, 12                  // Longitud del buffer
    
    bl clear_buffer             // Llamar a la función para limpiar el buffer

    // Convertir resultado a cadena (itoa)
    mov w0, w7                 
    ldr x1, =result            
    bl itoa                    

    // Mostrar mensaje del resultado
    mov x0, 1                  
    ldr x1, =resultado         
    mov x2, lenResultado       
    mov x8, 64                 
    svc 0                      

    // Mostrar el resultado de la operacion
    mov x0, 1                  
    ldr x1, =result           
    mov x2, 12                 
    mov x8, 64                 
    svc 0                      
    // Mostrar nueva linea
    mov x0, 1                  
    ldr x1, =newline           
    mov x2, 1                  
    mov x8, 64                 
    svc 0                      


    // Resetear la variable result a cero
    reset_var result, 0         // Llama a la macro para resetear 'result'

    // Bucle para reiniciar o detener el programa
    b opMem                   

// Función para limpiar el buffer
clear_buffer:
    mov w3, 0                   // Valor para llenar el buffer (cero)

clear_loop:
    strb w3, [x1], 1            // Escribir cero en el buffer
    subs w2, w2, 1              // Decrementar contador
    cbnz w2, clear_loop         // Repetir hasta que el buffer esté lleno
    ret

// Función para comprobar si la entrada es '202202233-exit'
check_exit:
    ldr x1, =inputOperacion     
    mov x2, 12                  
    ldr x3, =exit_string        

check_loop:
    ldrb w4, [x1], 1            
    ldrb w5, [x3], 1            
    cmp w4, w5                  
    bne check_end               

    subs x2, x2, 1             
    cbnz x2, check_loop         

    b menu

// Función para evaluar la expresion
evaluar_expresion:
    // Inicializar acumulador y punteros
    mov w1, 0                 
    mov w2, 0
    mov w3, '+'                
    mov x4, x0                

eval_loop:
    ldrb w5, [x4], 1           
    cmp w5, 0                  
    beq eval_end               

    // Si es un numero, procesarlo
    sub w6, w5, '0'            
    cmp w6, 9                  
    bhi eval_operator  
    mov w7, 10        
    mul w2, w2, w7             
    add w2, w2, w6             
    b eval_loop               

eval_operator:
    // Procesar el operador anterior
    cmp w3, '+'                
    bne check_minus
    add w1, w1, w2             
    b store_operator

check_minus:
    cmp w3, '-'               
    bne check_mul
    sub w1, w1, w2            
    b store_operator

check_mul:
    cmp w3, '*'               
    bne check_div
    mul w1, w1, w2             
    b store_operator

check_div:
    cmp w3, '/'                
    bne eval_loop
    udiv w1, w1, w2            
    b store_operator

store_operator:
    mov w2, 0                  
    mov w3, w5                 
    b eval_loop                

eval_end:
    // Procesar el ultimo numero
    cmp w3, '+'                
    bne final_check_minus
    add w1, w1, w2             
    b done

final_check_minus:
    cmp w3, '-'                
    bne final_check_mul
    sub w1, w1, w2             
    b done

final_check_mul:
    cmp w3, '*'                
    bne final_check_div
    mul w1, w1, w2             
    b done

final_check_div:
    cmp w3, '/'                
    bne done
    udiv w1, w1, w2           

done:
    mov w7, w1                 
    ret

// Funciones auxiliares: atoi, itoa, parse_operacion
atoi:
    MOV w1, 0                // Inicializar el acumulador
    MOV w8, 0                // Inicializar w8

    LDRB w2, [x0], 1         // Cargar el byte y mover el puntero
    CMP w2, '-'              // Verificar si es un signo negativo
    BNE ver_negativo          // Si no es negativo, continuar
    MOV w8, 1                // Guardar el signo como negativo
    LDRB w2, [x0], 1         // Cargar el siguiente byte y mover el puntero

ver_negativo:
    SUB w2, w2, '0'          // Convertir el carácter a número
    CMP w2, 9                // Verificar si es un número (0-9)
    BHI atoi_end             // Si no es un número, saltar al final

atoi_loop:
    MOV w3, 10               // Multiplicador (base 10)
    MUL w1, w1, w3           // Multiplicar el resultado por 10
    ADD w1, w1, w2           // Sumar el dígito actual al acumulador
    LDRB w2, [x0], 1         // Cargar el siguiente byte y mover el puntero
    SUB w2, w2, '0'          // Convertir el carácter a número
    CMP w2, 9                // Verificar si es un número (0-9)
    BLS atoi_loop            // Si es un número, repetir el ciclo

atoi_end:
    CMP w8, 1                // Verificar si es negativo
    BNE atoi_pos             // Si no es negativo, continuar
    NEG w1, w1               // Si es negativo, convertir el resultado a negativo

atoi_pos:
    MOV w0, w1               // Guardar el resultado en w0
    RET                      // Retornar

// Función ITOA - para convertir números enteros a caracteres ASCII
itoa:
    CMP w0, #0              // Verificar si el número es negativo
    BGE cargar_positivo      // Si es positivo, se obvia la carga del signo

    NEG w0, w0              // Convertir el número a positivo
    MOV w9, '-'             // Cargar el carácter '-'
    STRB w9, [x1]           // Escribir el signo en la primera posición
    ADD x1, x1, 1           // Avanzar el puntero de la cadena

cargar_positivo:
    MOV w2, 10              // Cargar el divisor (base 10)
    ADD x1, x1, 11          // Avanzar el puntero de la cadena
    STRB wzr, [x1]          // Agregar un byte nulo al final de la cadena

itoa_loop:
    UDIV w3, w0, w2         // Dividir w0 entre w2, el resultado en w3 (decenas)
    MSUB w4, w3, w2, w0     // w4 = w0 - (w3 * w2), calcular el resto (unidades)
    ADD w4, w4, '0'         // Convertir el dígito de las decenas a ASCII
    SUB x1, x1, 1           // Retroceder el puntero de la cadena
    STRB w4, [x1]           // Almacenar el dígito en la cadena
    MOV w0, w3              // Cargar el resultado de la división
    CBNZ w0, itoa_loop      // Si w0 no es cero, repetir el ciclo

    RET                     // Retornar


check_end:
    ret
    