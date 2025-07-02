{ Calcula la potencia de un número entero. 
  Devuelve base elevado al exponente, es decir: base^exponente. 
  Ejemplo: potencia(2, 3) devuelve 8. }
function potencia(base, exponente: Integer): Integer;
var
    i, resultado: Integer;
begin
    resultado := 1;
    for i := 1 to exponente do
        resultado := resultado * base;
    potencia := resultado;
end;

procedure calcularHistograma(pal : Palabra; var hist : Histograma);
{ Retorna en `hist` el histograma de `pal`, es decir la cantidad
 de ocurrencias de cada letra en esa palabra.
No se puede asumir el estado inicial de histograma. }
var
    i: Integer;
    c: Letra;
begin
    {Inicializa el histograma}
    for c := 'a' to 'z' do
        hist[c] := 0;
    { Recorre la palabra y actualiza el histograma con las ocurrencias de cada letra }
    for i := 1 to pal.tope do
        hist[pal.cadena[i]] := hist[pal.cadena[i]] + 1;
end;

function iguales(pal1, pal2 : Palabra) : boolean;
{ Dadas dos palabras, `pal1` y `pal2`, verifica si son iguales. }
var
    i: Integer;
    sonIguales: boolean;
begin
    if pal1.tope <> pal2.tope then
        iguales := False
    else
    begin
        sonIguales := True;
        for i := 1 to pal1.tope do
            if pal1.cadena[i] <> pal2.cadena[i] then
                sonIguales := False;
        iguales := sonIguales;
    end;
end;


procedure calcularHistogramaTexto(tex : Texto; var hist : Histograma);
{ Retorna en `hist` la cantidad de ocurrencias de cada letra en el texto `tex`.
No se puede asumir el estado inicial de `hist`. }
var
    c: Letra;
    histPal: Histograma; { Histograma temporal para cada palabra }
begin
    {Incializa el histograma}
    for c := 'a' to 'z' do
        hist[c] := 0;

    { Recorre cada nodo (palabra) del texto }
    while tex <> nil do
    begin
        { Inicializa el histograma temporal para la palabra actual }
        for c := 'a' to 'z' do
            histPal[c] := 0;
        
        { Calcula el histograma de la palabra actual y lo guarda en histPal }
        calcularHistograma(tex^.info, histPal);

        { Acumula los conteos de histPal en hist para formar el histograma total }
        for c := 'a' to 'z' do
            hist[c] := hist[c] + histPal[c];
        
        { Avanza al siguiente nodo del texto }
        tex := tex^.sig;
    end;
end;


function esPalabraValida(pal : Palabra; dicc : Texto) : boolean;
{ Dada una palabra `pal` y un diccionario `dicc`, verifica si la palabra
está en el texto dicc. }
var
    encontrada: boolean;
begin
    encontrada := False;

    { Recorre el diccionario hasta encontrar la palabra o llegar al final }
    while (dicc <> nil) and (not encontrada) do
    begin
        if iguales(pal, dicc^.info) then
            encontrada := True
        else
            dicc := dicc^.sig;
    end;

    esPalabraValida := encontrada;
end;


procedure removerLetraAtril(var mano : Atril; let : char);
{ Dada una letra `let`, elimina la primera aparición de esta
 del atril y deja a su lugar la última letra del atril.
Se asume que la letra está en el atril. }
var i: Integer;
begin
    i := 1;
    { Busca la primera posición donde aparece la letra `let` }
    while (i <= mano.tope) and (mano.letras[i] <> let) do
        i := i + 1;

    { Si se encontró la letra, reemplaza esa posición con la última letra }
    if i <= mano.tope then
    begin
        mano.letras[i] := mano.letras[mano.tope];
        mano.tope := mano.tope - 1;
    end;
end;

function entraEnTablero(pal : Palabra; pos : Posicion) : boolean;
{ Verifica si la palabra `pal` puede colocarse en el tablero
  comenzando desde la posición `pos` sin salirse del límite del tablero. }
var
  filaFin: char;
  colFin: integer;
  ok: boolean;
begin
  ok := true;

  if pos.direccion = Horizontal then
  begin
    colFin := pos.col + pal.tope - 1; { Calcula la columna final si la palabra es horizontal }

    { Si la columna final excede el máximo permitido, no entra }
    if (colFin > MAXCOLUMNAS) then
      ok := false;
  end
  else  { Vertical }
  begin
    { Calcula la fila final si la palabra es vertical }
    filaFin := chr(ord(pos.fila) + pal.tope - 1);

    { Si la fila final excede la máxima fila permitida, no entra }
    if (filaFin > MAXFILAS) then
      ok := false;
  end;

  entraEnTablero := ok;
end;

procedure siguientePosicion(var pos : Posicion);
{ Actualiza la posición `pos`, devuelve en la misma variable la posición del 
 siguiente casillero en la dirección indicada en `pos`. 
 Se asume que `pos` no corresponde a la última fila si la dirección es vertical, 
 ni a la última columna si la dirección es horizontal. }
begin
    { Avanza una columna hacia la derecha, hasta el máximo permitido }
    if pos.direccion = Horizontal then
    begin
        if pos.col < MAXCOLUMNAS then
            pos.col := pos.col + 1
        else
            pos.col := MAXCOLUMNAS; { En caso de límite, se mantiene en la última columna }
    end
    else
    begin
        { Avanza una fila hacia abajo, incrementando el carácter de la fila }
        if pos.fila < MAXFILAS then
            pos.fila := Chr(Ord(pos.fila) + 1)
        else
            pos.fila := MAXFILAS; { En caso de límite, se mantiene en la última fila }
    end;
end;

function puedeArmarPalabra(pal: Palabra; pos: Posicion; mano: Atril; tab: Tablero): boolean;
var
    i, j: Integer;
    fila: Char;
    col: Integer;
    encontrada: Boolean;
    manoTemp: Atril;
    ok: Boolean;
begin
    manoTemp := mano;
    fila := pos.fila;
    col := pos.col;
    ok := True;
    i := 1;

    while (i <= pal.tope) and ok do
    begin
        with tab[fila, col] do
        begin
            if ocupada then
            begin
                if ficha <> pal.cadena[i] then
                    ok := False;
            end
            else
            begin
                encontrada := False;
                for j := 1 to manoTemp.tope do
                begin
                    if manoTemp.letras[j] = pal.cadena[i] then
                    begin
                        manoTemp.letras[j] := manoTemp.letras[manoTemp.tope];
                        manoTemp.tope := manoTemp.tope - 1;
                        encontrada := True;
                        break;
                    end;
                end;
                if not encontrada then
                    ok := False;
            end;
        end;

        if ok then
        begin
            if pos.direccion = Horizontal then
                col := col + 1
            else
                fila := Chr(Ord(fila) + 1);
            i := i + 1;
        end;
    end;

    puedeArmarPalabra := ok;
end;



procedure intentarArmarPalabra(pal : Palabra; pos : Posicion; 
                              var tab : Tablero; var mano : Atril; 
                              dicc : Texto; info : InfoFichas; 
                              var resu : ResultadoJugada);
{ Dada una palabra, posición, tablero, atril, diccionario, info y un resultado.}
{ En primer lugar, se verifica que la palabra entre en el tablero dada la posición. }
{ Luego que se pueda armar la palabra en el tablero con las fichas disponibles }
{ y por último que la palabra exista en el diccionario. }
{ Si es posible armar la palabra, esta se agrega en el tablero, actualiza `resu.tipo` y 
almacena el puntaje en `resu.puntaje`.
Para calcular el puntaje, se suman los puntos de las letras **agregadas**, utilizando 
la información de `info` y la bonificación del casillero. Tanto para el puntaje calculado
como para las bonificaciones **NO** suman las letras ya existentes en el tablero que conforman la palabra. 
Si no se puede armar la palabra, devuelve el resultado correspondiente en `resu.tipo`. }
var
    posActual: Posicion;         { Posición que se va actualizando para cada letra }
    i: Integer;                  { Índice para recorrer letras de la palabra }
    c: Letra;                    { Letra actual de la palabra }
    puntajeLetra: Integer;       { Puntaje de la letra actual considerando bonos }
    contadorTriples: Integer;    { Cuenta cuántas casillas triple palabra se usan }
begin
    { Inicializa resultados básicos }
    resu.puntaje := 0;
    resu.palabra := pal;
    resu.pos := pos;

    { 1. Verifica que la palabra entre en el tablero }
    if not entraEnTablero(pal, pos) then
        resu.tipo := NoEntra
    else if not puedeArmarPalabra(pal, pos, mano, tab) then { 2. Verifica que la palabra se pueda armar con las letras del atril y tablero }
        resu.tipo := NoFichas
    else if not esPalabraValida(pal, dicc) then{ 3. Verifica que la palabra exista en el diccionario }
        resu.tipo := NoExiste
    else
    begin
         { Palabra válida, comienza a armarla y calcular puntaje }
    resu.tipo := Valida;
    resu.puntaje := 0;
    contadorTriples := 0;
    posActual := pos;

    { Recorre cada letra de la palabra }
    for i := 1 to pal.tope do
    begin
        c := pal.cadena[i];

        { Valida que la letra sea una minúscula válida }
        if (c < 'a') or (c > 'z') then
        begin
            resu.tipo := NoExiste;
        end;

        with tab[posActual.fila, posActual.col] do
        begin
            { Si la casilla está libre, se coloca la ficha y se calcula puntaje con bono }
            if not ocupada then
            begin
                ocupada := True;
                ficha := c;

                case bonus of
                    Ninguno: 
                        puntajeLetra := info[c].puntaje;
                    DobleLetra: 
                        puntajeLetra := info[c].puntaje * 2;
                    Trampa: 
                        puntajeLetra := -info[c].puntaje;  { Resta puntaje por casilla trampa }
                    TriplePalabra:
                    begin
                        puntajeLetra := info[c].puntaje;
                        contadorTriples := contadorTriples + 1;  { Marca que hay un triple palabra }
                    end;
                else
                    puntajeLetra := info[c].puntaje; { Por defecto }
                end;

                { Suma el puntaje parcial de la letra }
                resu.puntaje := resu.puntaje + puntajeLetra;

                { Elimina la letra del atril }
                removerLetraAtril(mano, c);
            end;
            { Si la casilla ya estaba ocupada, no suma ni modifica puntaje }
        end;

        { Avanza a la siguiente posición según la dirección }
        siguientePosicion(posActual);
    end;

    { Aplica multiplicador triple palabra según las casillas que se hayan usado }
    if contadorTriples > 0 then
        resu.puntaje := resu.puntaje * potencia(3, contadorTriples);
    end;
end;

procedure registrarJugada(var jugadas : HistorialJugadas; pal : Palabra; pos : Posicion; puntaje : integer);
{ Dada una lista de jugadas, una palabra, Posicion y puntaje, agrega la jugada al final de la lista }
var
    nuevoNodo, actual: HistorialJugadas;
begin
    New(nuevoNodo); { Se reserva memoria para el nuevo nodo }

    { Se copian los datos de la jugada al nuevo nodo }
    nuevoNodo^.palabra := pal;
    nuevoNodo^.pos := pos;
    nuevoNodo^.puntaje := puntaje;
    nuevoNodo^.sig := nil; { El nuevo nodo será el último, así que apunta a nil }

    if jugadas = nil then
        jugadas := nuevoNodo  { Si la lista está vacía, el nuevo nodo es el primero }
    else
    begin
        actual := jugadas; { Se empieza a recorrer la lista desde el principio }

        while actual^.sig <> nil do
            actual := actual^.sig; { Se avanza hasta llegar al último nodo }

        actual^.sig := nuevoNodo; { Se agrega el nuevo nodo al final de la lista }
    end;
end;
