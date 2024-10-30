
//Declaracion de buffer (entrada del usuario)
.global arreglo
.global val
.global bufferComando
.global filename
.global buffer
.global fileDescriptor
.global listIndex
.global num
.global col_imp
.global character
.global count, op1, op2
.global colum, row, colum2, row2, retorno

.bss

arreglo:
    .rept 276
    .quad 0
    .endr

retorno:
    .space 30

val:
    .space 2

bufferComando:
    .zero 50

filename:
    .space 100

buffer:
    .zero 1024

fileDescriptor:
    .space 8

listIndex:
    .zero 8

num:
    .space 8

col_imp:
    .space 1

character:
    .space 2

count:
    .zero 8

op1:
    .quad 0

op2:
    .quad 0

colum:
    .space 2

row:
    .space 40

colum2:
    .space 2

row2:
    .space 40
