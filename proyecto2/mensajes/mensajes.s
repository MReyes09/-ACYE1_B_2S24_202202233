
//Declaracion de mensajes
.global clearScreen, enter, datos, salto, espacio, espacio2, dpuntos, cols, rows, cmdimp, cmdsep, errorImport, errorOpenFile, getIndexMsg, readSuccess
.global separador, mensajeComandos, comandoErroneo, cmpsepEn, cmdguardar, errorGuardar, separadorComandoError, cmdResta, errorResta

//Declaracion de len
.global lenClear, lenEnter, lenDatos, lenSalto, lenEspacio, lenEspacio2, lenDpuntos, lenError, lenGetIndexMsg, lenReadSuccess
.global lenSeparador, lenMensajeComandos, lenComandoErroneo, lenErrorOpenFile, lenErrorGuardar, lenSeparadorComandoError
.global cmdSuma, cmdsepY, errorSuma, lenErrorSuma, lenErrorResta, errorMultiplicacion, cmdMultiplicacion, lenErrorMultiplicacion
.global cmdDivicion, errorDivicion, lenErrorDivicion, divicionCero, lenDivicionCero, cmdsepEntre
.global cmdPotencia, errorPotencia, lenErrorPotencia, cmdsepALa, errorPotenciaNegativa, lenErrorPotenciaNegativa
.global cmdOrLogico, cmdAndLogico, cmdOXLogico
// DECLARACION DE VARIABLES QUE GUARDAN LOS MENSAJES A MOSTRAR EN PANTALLA
.data 

clearScreen:        
    .asciz "\033[H\033[2J"         // Secuencia de escape ANSI para limpiar la pantalla
lenClear = .- clearScreen

enter:        
    .asciz " || Presiona Enter para continuar...\n"
lenEnter = .- enter

datos:
        .asciz " ||                                               \n"
        .asciz " || Universidad De San Carlos De Guatemala        \n"
        .asciz " || Facultad De Ingenieria                        \n"
        .asciz " || Escuela de Ciencias y Sistemas                \n"
        .asciz " || Arquitectura de Computadoras y Ensambladores 1\n"
        .asciz " || Seccion B                                     \n"
        .asciz " || Estudiante: Matthew Emmanuel Reyes Melgar     \n"
        .asciz " || Carnet: 202202233                             \n"
        .asciz " || \n"
lenDatos = .- datos

salto:
    .asciz "\n"
    lenSalto = .- salto

espacio:
    .asciz "\t"
    lenEspacio = .- espacio

espacio2:
    .asciz " "
    lenEspacio2 = .- espacio2

dpuntos:
    .asciz ":"
    lenDpuntos = .- dpuntos

cols:
    .asciz " ABCDEFGHIJK"
// PARTE DE UN MISMO COMANDO
cmdimp:
    .asciz "IMPORTAR"

cmdsep:
    .asciz "SEPARADO POR TABULADOR"
// FIN COMANDO IMPORTAR

// COMANDO GUARDAR
cmdguardar:
    .asciz "GUARDAR"

// SEPARADOR EN
cmpsepEn:
    .asciz "EN"

cmdSuma:
    .asciz "SUMA"

cmdsepY:
    .asciz "Y"

cmdsepEntre:
    .asciz "ENTRE"

cmdResta:
    .asciz "RESTA"

cmdMultiplicacion:
    .asciz "MULTIPLICACION"

cmdDivicion:
    .asciz "DIVIDIR"

cmdPotencia:
    .asciz "POTENCIAR"

cmdAndLogico:
    .asciz "YLOGICO"

cmdOXLogico:
    .asciz "OXLOGICO"

errorPotencia:
    .asciz " || Error En El Comando De Potencia\n"
    lenErrorPotencia = .- errorPotencia

errorPotenciaNegativa:
    .asciz " || Error: No se puede elevar a una potencia negativa\n"
    lenErrorPotenciaNegativa = .- errorPotenciaNegativa

cmdsepALa:
    .asciz "A LA"

cmdOrLogico:
    .asciz "OLOGICO"

errorImport:
    .asciz " || Error En El Comando De Importación\n"
    lenError = .- errorImport

errorGuardar:
    .asciz " || Error En El Comando De Guardar\n"
    lenErrorGuardar = .- errorGuardar

errorSuma:
    .asciz " || Error En El Comando De Suma\n"
    lenErrorSuma = .- errorSuma

errorResta:
    .asciz " || Error En El Comando De Resta\n"
    lenErrorResta = .- errorResta

errorMultiplicacion:
    .asciz " || Error En El Comando De Multiplicacion\n"
    lenErrorMultiplicacion = .- errorMultiplicacion

errorDivicion:
    .asciz " || Error En El Comando De Divicion\n"
    lenErrorDivicion = .- errorDivicion

divicionCero:
    .asciz " || Error: Divicion Entre Cero\n"
    lenDivicionCero = .- divicionCero

errorOpenFile:
    .asciz " || Error al abrir el archivo\n"
    lenErrorOpenFile = .- errorOpenFile

getIndexMsg:
    .asciz " || -> Ingrese la columna para el encabezado "
    lenGetIndexMsg = .- getIndexMsg

readSuccess:
    .asciz " || El Archivo Se Ha Leido Correctamente "
    lenReadSuccess = .- readSuccess

separador:
    .asciz " ___________________________________ TABLERO DE DATOS ___________________________________ \n"
    .asciz " \n"
    lenSeparador = .- separador

mensajeComandos:
    .asciz " || Ingresa el comando: "
    lenMensajeComandos = .- mensajeComandos

comandoErroneo:
    .asciz " || Comando no reconocido\n"
    lenComandoErroneo = .- comandoErroneo

separadorComandoError:
    .asciz " || Separador invalido para el comando utilizado\n"
    lenSeparadorComandoError = .- separadorComandoError


