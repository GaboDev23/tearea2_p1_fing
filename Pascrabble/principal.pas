program principal;

{ Con esta directiva queda incluido el archivo definiciones.pas }
{$INCLUDE definiciones.pas}

{ Con esta directiva queda incluido el archivo tarea2.pas }
{$INCLUDE tarea2.pas}

var
    tab        : Tablero;
    dicc       : Texto;
    pal, pal2  : Palabra;
    hist       : Histograma;
    info       : InfoFichas;
    bolsa      : BolsaFichas;
    i, num, puntaje, opcion, opcionPascrabble, opcionTests  : integer;
    mano       : Atril;
    l          : Letra;
    pos      : Posicion;
    resu       : ResultadoJugada;
    jugadas    : HistorialJugadas;
begin
    repeat
        writeLn;
        writeln('----- MENÚ TAREA2 -----');
        writeln('1. Pascrabble ');
        writeln('2. Probar subprogramas individualmente ');
        writeln('0. Salir');
        writeln('------------------------');
        write('Seleccione una opción: ');
        readln(opcion);
        writeln;

        case opcion of
            1 : begin // Pascrabble
                Randomize;

                inicializarTablero(tab);
                jugadas := NIL;
                puntaje := 0;
                writeln('Bienvenido al PAScrabble');
                writeln;

                leerDiccionario(dicc);
                calcularHistogramaTexto(dicc, hist);
                calcularPuntajes(hist, info);
                llenarBolsaFichas(info, bolsa);
                iniciarAtril(mano);
                // reponerFichas(bolsa, mano);

                mostrarTablero(tab);
                mostrarAtril(mano, info);
                writeln('Puntaje total: ', puntaje:0);
                repeat 
                    writeln;
                    writeln('----- MENÚ PASCRABBLE -----');
                    writeln('1. Mostrar tablero');
                    writeln('2. Mostrar historial de jugadas');
                    writeln('3. Mostrar puntajes de letras');
                    writeln('4. Mostrar atril');
                    writeln('5. Jugar una palabra');
                    writeln('6. Reponer fichas');
                    writeln('7. Consultar palabra');
                    writeln('0. Salir');
                    write('Seleccione una opción: ');
                    readln(opcionPascrabble);

                    writeln;

                    case opcionPascrabble of
                        1: begin
                            mostrarTablero(tab);
                            mostrarAtril(mano, info);
                            writeln('Puntaje total: ', puntaje:0);
                        end;

                        2 : MostrarHistorial(jugadas);

                        3: begin
                            writeln('Puntajes de letras:');
                            mostrarPuntajes(info);
                        end;

                        4: mostrarAtril(mano, info);

                        5: begin
                            ingresarPalabra(pal, pos);
                            intentarArmarPalabra(pal, pos, tab, mano, dicc, info, resu);
                            case resu.tipo of
                                NoEntra: writeln('La palabra no entra en el tablero.');
                                NoFichas: writeln('No hay fichas en el atril y tablero para armar la palabra.');
                                NoExiste: writeln('La palabra no existe en el diccionario.');
                                Valida: begin
                                    registrarJugada(jugadas, pal, pos, resu.puntaje);
                                    puntaje := puntaje + resu.puntaje;
                                    write('Palabra armada "');mostrarPalabra(pal);writeln('" suma ', resu.puntaje:0, ' puntos.');
                                    mostrarTablero(tab);
                                    mostrarAtril(mano, info);
                                end;
                            end;
                        end;

                        6: begin
                            reponerFichas(bolsa, mano);
                            mostrarTablero(tab);
                            mostrarAtril(mano, info);
                            writeln('Puntaje total: ', puntaje:0);
                        end;

                        7: begin
                            writeln('Ingrese la palabra a consultar:');
                            leerPalabra(input, pal);
                            if esPalabraValida(pal, dicc) then
                                writeln('La palabra está en el diccionario.')
                            else
                                writeln('La palabra NO está en el diccionario.');
                        end;

                        0: begin
                            writeln('Saliendo del juego.');
                            liberarTexto(dicc);
                            borrarHistorial(jugadas);
                        end;

                    else
                        writeln('Opción inválida. Intente nuevamente.');
                    end;

                until opcionPascrabble = 0;
            end;
            2: begin // Probar subprogramas individualmente
                    repeat
                    writeln('----- MENÚ PROBAR SUBPROGRAMAS -----');
                    writeln('1. Calcular histograma palabra ');
                    writeln('2. Comparar palabras ');
                    writeln('3. Calcular histograma texto ');
                    writeln('4. Es palabra válida ');
                    writeln('5. Remover letra del atril ');
                    writeln('6. Entra en tablero ');
                    writeln('7. Siguiente posición ');
                    writeln('8. Puede armar palabra ');
                    writeln('9. Armar palabra ');
                    writeln('10. Registrar jugada ');
                    writeln('0. Salir ');
                    writeln('------------------------');
                    write('Seleccione una opción: ');
                    readln(opcionTests);
                    writeln;
                    case opcionTests of
                        1: begin // Calcular histograma palabra
                            writeln('Ingrese la palabra a calcular el histograma:');
                            leerPalabra(input, pal);
                            calcularHistograma(pal, hist);
                            mostrarHistograma(hist);
                        end;
                        2: begin // Comparar palabras
                            writeln('Ingrese la primera palabra a comparar:');
                            leerPalabra(input, pal);
                            writeln('Ingrese la segunda palabra a comparar:');
                            leerPalabra(input, pal2);
                            if iguales(pal, pal2) then
                                writeln('Las palabras son iguales.')
                            else
                                writeln('Las palabras son diferentes.');
                        end;
                        3: begin // Calcular histograma texto
                            leerDiccionario(dicc);
                            calcularHistogramaTexto(dicc, hist);
                            mostrarHistograma(hist);
                            liberarTexto(dicc);
                        end;
                        4: begin // Es palabra válida
                            leerDiccionario(dicc);
                            writeln('Ingrese la palabra a consultar:');
                            leerPalabra(input, pal);
                            if esPalabraValida(pal, dicc) then
                                writeln('La palabra está en el diccionario.')
                            else
                                writeln('La palabra NO está en el diccionario.');
                            liberarTexto(dicc);
                        end;
                        5: begin // Remover letra del atril
                            rellenarAtril(mano);
                            writeln('Ingrese una letra a remover del atril:');
                            readln(l);
                            removerLetraAtril(mano, l);
                            mostrarAtril(mano, info);
                        end;
                        6: begin // Entra en tablero 
                            inicializarTablero(tab);
                            mostrarTablero(tab);
                            ingresarPalabra(pal, pos);
                            if entraEnTablero(pal, pos) then
                                writeln('La palabra entra en el tablero.')
                            else
                                writeln('La palabra NO entra en el tablero.');
                        end;
                        7: begin // Siguiente posición
                            writeln('Ingrese una posición:');
                            leerPosicion(pos);
                            siguientePosicion(pos);
                            writeln('Siguiente posición:');
                            imprimirPosicion(pos);
                            writeln
                        end;
                        8: begin // Puede armar palabra
                            rellenarAtril(mano);
                            inicializarTablero(tab);
                            leerLetrasTablero(tab);
                            mostrarAtril(mano, info);
                            ingresarPalabra(pal, pos);
                            if puedeArmarPalabra(pal, pos, mano, tab) then
                                writeln('Se puede armar la palabra.')
                            else
                                writeln('NO se puede armar la palabra.');
                        end;
                        9: begin // Armar palabra
                            leerDiccionario(dicc);
                            calcularHistogramaTexto(dicc, hist);
                            calcularPuntajes(hist, info);
                            rellenarAtril(mano);
                            inicializarTablero(tab);
                            leerLetrasTablero(tab);
                            mostrarAtril(mano, info);
                            ingresarPalabra(pal, pos);

                            intentarArmarPalabra(pal, pos, tab, mano, dicc, info, resu);
                            write('Se intentó armar la palabra: ');
                            mostrarPalabra(resu.palabra);
                            writeln;
                            write('En la posición: ');
                            imprimirPosicion(resu.pos);
                            writeln;
                            case resu.tipo of
                                NoEntra: writeln('La palabra no entra en el tablero.');
                                NoFichas: writeln('No hay fichas en el atril y tablero para armar la palabra.');
                                NoExiste: writeln('La palabra no existe en el diccionario.');
                                Valida: begin
                                    write('Palabra armada "');mostrarPalabra(pal);writeln('" suma ', resu.puntaje:0, ' puntos.');
                                    mostrarTablero(tab);
                                    mostrarAtril(mano, info);
                                end;
                            end;
                            liberarTexto(dicc);
                        end;
                        10: begin // Registrar jugada
                            writeln('Ingrese la cantidad de jugadas a registrar:');
                            readln(num);
                            jugadas := NIL;
                            for i := 1 to num do
                            begin
                                ingresarPalabra(pal, pos);
                                writeln('Ingrese el puntaje de la jugada:');
                                readln(puntaje);
                                registrarJugada(jugadas, pal, pos, puntaje);
                                writeln;
                            end;
                            MostrarHistorial(jugadas);
                            borrarHistorial(jugadas);
                        end;
                    end;
                until opcionTests = 0;
            end;
        end;
    until opcion = 0;
end.
