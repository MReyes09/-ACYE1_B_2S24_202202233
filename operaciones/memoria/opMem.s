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

// Funcion atoi
atoi:
    mov w1, 0
atoi_loop:
    ldrb w2, [x0], 1
    sub w2, w2, '0'
    cmp w2, 9
    bhi atoi_end
    mov w7, 10
    mul w1, w1, w7
    add w1, w1, w2
    b atoi_loop
atoi_end:
    mov w0, w1
    ret

// Funcion itoa
itoa:
    mov w2, 10                 
    add x1, x1, 11             
    strb wzr, [x1]             

itoa_loop:
    udiv w3, w0, w2            
    msub w4, w3, w2, w0        
    add w4, w4, '0'            
    sub x1, x1, 1              
    strb w4, [x1]              
    mov w0, w3                 
    cbnz w0, itoa_loop         
    ret


check_end:
    ret
    