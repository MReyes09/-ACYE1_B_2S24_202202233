.global findComand
.extern clear_buffer
.extern import_data
.extern guardarCMP
.extern excel
.extern sumaCMP
.extern restaCMP
.extern multiplicacionCMP
.extern divisionCMP
.extern potenciaCMP
.extern Proc_ORLogico
.extern Proc_ANDLogico
.extern Proc_XORLogico

.text

.macro print stdout, reg, len
    MOV x0, \stdout
    MOV x1, \reg
    MOV x2, \len
    MOV x8, 64
    SVC 0
.endm

.macro read stdin, reg, len
    MOV x0, \stdin
    MOV x1, \reg
    MOV x2, \len
    MOV x8, 63
    SVC 0
.endm

findComand:
    LDR x1, =bufferComando
    MOV x0, 0            // Asignamos 0 en x0 para inicializar el registro que guardará el resultado de cmpComand

    // Comp comnado importar
    LDR x0, =cmdimp
    BL cmpComand
    CBNZ x0, stepsImport // Si el comando es igual a cmdimp, saltar a proc_import

    LDR x0, =cmdguardar
    BL cmpComand
    CBNZ x0, stepsGuardar

    LDR x0, =cmdSuma
    BL cmpComand
    CBNZ x0, stepsSuma

    LDR x0, =cmdResta
    BL cmpComand
    CBNZ x0, restaCMP

    LDR x0, =cmdMultiplicacion
    BL cmpComand
    CBNZ x0, multiplicacionCMP

    LDR x0, =cmdDivicion
    BL cmpComand
    CBNZ x0, divisionCMP

    LDR x0, =cmdPotencia
    BL cmpComand
    CBNZ x0, potenciaCMP

    LDR x0, =cmdOrLogico
    BL cmpComand
    CBNZ x0, Proc_ORLogico

    LDR x0, =cmdAndLogico
    BL cmpComand
    CBNZ x0, Proc_ANDLogico

    LDR x0, =cmdOXLogico
    BL cmpComand
    CBNZ x0, Proc_XORLogico

    // Si ningún comando es igual, se imprime un mensaje de error
    LDR x27, =comandoErroneo
    LDR x26, =lenComandoErroneo
    print 1, x27, x26

    LDR x27, =enter
    LDR x26, =lenEnter
    print 1, x27, x26

    LDR x27, =bufferComando
    read 0, x27, 50

    bl excel

// -------------------------- FUNCION CMP_COMAND --------------------------
cmpComand:
    LDR x1, =bufferComando

    imp_loop:
        LDRB w2, [x0], 1
        LDRB w3, [x1], 1

        CBZ w2, cmpSuccess

        CMP w2, w3
        BNE cmpError

        B imp_loop

cmpSuccess:
    MOV x0, 1
    RET

cmpError:
    MOV x0, 0
    RET

// -------------------------- FIN FUNCION CMP_COMAND --------------------------


stepsImport:
    BL proc_import
    BL import_data

    RET

stepsGuardar:
    BL guardarCMP
    BL clear_buffer

    RET

stepsSuma:
    BL sumaCMP
    RET
    