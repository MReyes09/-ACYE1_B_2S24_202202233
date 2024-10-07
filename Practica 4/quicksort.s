/*
// Funcion para ordenar los numeros por medio del quicksort
quicksort:
    print arrayinicial, lenArrayInicial
    BL imprimir_array // se llama a la funcion para imprimir el array
    LDR x19, =arrayordenado // se carga la direccion de memoria de arrayordenado en x19
    LDR x20, =length // se carga la direccion de memoria de length en x20
    LDR x20, [x20]// se carga el valor de length en x20
    LDR x16, =formaordenamiento // se carga la direccion de memoria de formaordenamiento en x16
    LDR w16, [x16]// se carga el valor de formaordenamiento en w16
    LDR x12, =stepbystep         // se carga la direccion de memoria de stepbystep en x12
    LDR w8, [x12]                // se carga el valor de stepbystep en w8
    MOV x17, 0 // se usara como contadora de iteraciones
    MOV x3, #0 // se carga el valor 0 en x3, se usara como el indice menor (low index)
    SUB x4, x20, #1 // se resta la longitud en 1, se usara como el indice mayor (high index)
    BL quicksort_loop
    print arrayfinal, lenArregloOrdenado
    BL imprimir_array // se llama a la funcion para imprimir el array
    B cont
quicksort_loop:
    CMP x3, x4 // se compara si el indice menor es menor que el indice mayor
    BGE quicksort_end // si no es menor, se termina el ciclo
    LDR w5, [x19, x3, LSL2]// se carga el valor de array[low] en w5
    MOV x13, x3 // se carga el valor de low en x13
    MOV x14, x4 // se carga el valor de high en x14
partition_left:
    LDR w7, [x19, x13, LSL2]    // se carga el valor de array[low] en w7 (x13 = x3)
    CMP w7, w5                  // se compara si array[low] es menor que array[low]
    BLT next_left               // si es menor, se envia a next_left
    B partition_right // si no es menor, se envia a partition_right
next_left:
    ADD x13, x13, 1             // se incrementa low
    CMP x13, x4                 // se compara si low es mayor o igual a high
    BLT partition_left          // si no es mayor o igual, se repite el ciclo
partition_right:
    LDR w9, [x19, x14, LSL2]    // se carga el valor de array[high] en w9 (x14 = x4)
    CMP w9, w5                  // se compara si array[high] es mayor que array[low]
    BGT next_right              // si es mayor, se envia a next_right
    B swap_quicksort // si no es mayor, se envia a swap_quicksort
next_right:
    SUB x14, x14, 1             // se decrementa high
    CMP x14, x3                 // se compara si high es menor o igual a low
    BGE partition_right         // si no es menor o igual, se repite el ciclo
swap_quicksort:
    CMP x13, x14 // se compara si low es mayor o igual a high
    BGT swap_end // si no es mayor o igual, se termina
    LDR w5, [x19, x13, LSL2]    // se carga el valor de array[low] en w5
    LDR w9, [x19, x14, LSL2]    // se carga el valor de array[high] en w9
    STR w9, [x19, x13, LSL2]    // se guarda el valor de array[high] en array[low]
    STR w5, [x19, x14, LSL2]    // se guarda el valor de array[low] en array[high]
    ADD x13, x13, 1             // se incrementa low
    SUB x14, x14, 1             // se decrementa high
    B partition_left // se envia a partition_left
swap_end:
    STP x29, x30, [sp, -16]! // se guarda el valor de x29 y x30 en la pila
    MOV x29, sp
    MOV x4, x14 // se carga el valor de high en x4
    BL quicksort_loop
    ADD x3, x13, #1 // se incrementa low
    BL quicksort_loop
    LDP x29, x30, [sp], 16 // se recupera el valor de x29 y x30 de la pila
quicksort_end:
    RET
*/