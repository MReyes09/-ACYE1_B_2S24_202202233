.text
.global insertion_sort_major

insertion_sort_major:
    // X0: dirección base del array (puntero a int[])
    // X1: tamaño del array
    // X2: valor de i (iterador)
    // X3: valor de j (iterador)
    // X4: valor de la clave (elemento temporal)

    MOV X2, #1                  // i = 1

loop_i:
    CMP X2, X1                  // Comparar i con el tamaño del array
    BGE end_sort                // Si i >= tamaño, salir del bucle

    LSL X3, X2, #2              // j = i - 1 (desplazamiento de 4 bytes por enteros de 32 bits)
    LDR W4, [X0, X2, LSL #2]    // clave = array[i]

    SUB X3, X2, #1              // j = i - 1
loop_j:
    CMP X3, #0                  // Comparar j con 0
    BLT insert_key              // Si j < 0, insertar clave

    LSL X5, X3, #2              // Dirección de array[j]
    LDR W6, [X0, X5]            // Cargar array[j]

    CMP W6, W4                  // Comparar array[j] con clave
    BLE insert_key              // Si array[j] <= clave, insertar clave

    ADD X5, X3, #1              // Dirección de array[j+1]
    STR W6, [X0, X5, LSL #2]    // Mover array[j] a array[j+1]
    SUB X3, X3, #1              // j--

    B loop_j                    // Repetir bucle para j

insert_key:
    ADD X5, X3, #1              // Dirección de array[j+1]
    STR W4, [X0, X5, LSL #2]    // Insertar clave en array[j+1]

    ADD X2, X2, #1              // i++
    B loop_i                    // Repetir bucle para i

end_sort:
    RET                         // Terminar función
