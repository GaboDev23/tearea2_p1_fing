// PASCRABBLE
{ --------------------------------------------------- }
{ Definiciones de tipos y subprogramas para el juego de Scrabble }
{ --------------------------------------------------- }

{ constantes }
{ --------------------------------------------------- }
const
   { Auxiliares para el juego }
   MAXATRIL = 7; { máxima cantidad de fichas del atril}
   MAXFILAS = 'I';   { cota de filas }
   MAXCOLUMNAS = 9; { cota de columnas }
   MAXPAL  = 30;      { cota de la palabra }

   TOTALFICHAS = 100; { total de fichas en el juego }
   MAXPUNTAJE = 10; { puntaje máximo de una letra }
   RANDSEEDC = 42; { semilla para el generador de números aleatorios }
{ tipos }
{ --------------------------------------------------- }

type

   { Arreglo con tope de letras, que representa a una palabra }
   Letra        = 'a' .. 'z';
   Palabra	= record
      cadena : array [1 .. MAXPAL] of Letra;
      tope   : 0 .. MAXPAL
   end;

   Histograma =  array [Letra] of integer;

   InfoFicha = record
      puntaje : integer;
      cantidad : integer;
   end;

   InfoFichas = array[Letra] of InfoFicha;

   TipoBonus = (Ninguno, DobleLetra, TriplePalabra, Trampa);
   { tipo de los bonos }

   Casillero = record
      bonus : TipoBonus;
      case ocupada : boolean of
         true : (ficha : Letra);
         false : (); { si no está ocupada, no hay letra }
   end;

   Tablero = array['A'..MAXFILAS, 1..MAXCOLUMNAS] of Casillero;

   TipoDireccion = (Horizontal, Vertical);
   { Posicion de la palabra }
   Posicion = record
      direccion : TipoDireccion;
      fila : 'A'..MAXFILAS;
      col  : 1..MAXCOLUMNAS;
   end;

   { tipo de la bolsa de fichas }

   BolsaFichas = record
      letras : array[1..TOTALFICHAS] of Letra;
      tope : 0 .. TOTALFICHAS;
      { cantidad de letras en la bolsa }
   end;

   Atril = record
      letras : array[1..MAXATRIL] of Letra;
      tope : 0 .. MAXATRIL;
      { cantidad de letras en la mano }
   end;

   { lista de palabras, que representa a un texto }
   Texto	= ^NodoPal; 
   NodoPal	= record  
      info : Palabra;
      sig  : Texto
   end;

   TipoResultado = (Valida, NoEntra, NoFichas, NoExiste);

   ResultadoJugada = record
      palabra : Palabra;
      pos : Posicion;
      case tipo : TipoResultado of
         Valida : (puntaje : integer);
         NoEntra : ();
         NoFichas : ();
         NoExiste  : ();
   end;

   HistorialJugadas = ^NodoJugada;
   NodoJugada = record
      palabra : Palabra;
      pos : Posicion;
      puntaje : integer;
      sig : HistorialJugadas
   end;


{ subprogramas }
{ --------------------------------------------------- }
procedure randomize;
begin
    randseed:=RANDSEEDC; 
end;

procedure mostrarTablero(t: Tablero);
var
   f: char;
   c: integer;
begin
   // // Encabezado de columnas
   // write('   ');
   // for c := 1 to MAXCOLUMNAS do
   //    write(' ', c:2,' ');
   writeln;
   // Separador superior
   write('   ');
   for c := 1 to MAXCOLUMNAS do
      write('+---');
   writeln('+');

   for f := 'A' to MAXFILAS do
   begin
      write(' ', f, ' ');  // letra de la fila
      for c := 1 to MAXCOLUMNAS do
      begin
         write('|');
         if t[f,c].ocupada then
            write(' ', upcase(t[f,c].ficha),' ')
         else
            case t[f,c].bonus of
               TriplePalabra: write(' * ');
               DobleLetra   : write(' + ');
               Trampa       : write(' - ');
               else           write('   ');
            end;
      end;
      writeln('|');

      // Línea separadora entre filas
      write('   ');
      for c := 1 to MAXCOLUMNAS do
         write('+---');
      writeln('+');
   end;
   // Encabezado de columnas
   write('   ');
   for c := 1 to MAXCOLUMNAS do
      write(' ', c:2,' ');
   writeln;
end;

procedure inicializarTablero(var t: Tablero);
var
   f: char;
   c: integer;

   filaCentro: char;
   colCentro: integer;
begin
   filaCentro := chr(ord('A') + (ord(MAXFILAS) - ord('A')) div 2);
   colCentro := (MAXCOLUMNAS div 2) + 1;

   for f := 'A' to MAXFILAS do
      for c := 1 to MAXCOLUMNAS do
      begin
         t[f,c].ocupada := false;
         if ((f = 'A') and ((c = 1) or (c = MAXCOLUMNAS))) or 
            ((f = MAXFILAS) and ((c = 1) or (c = MAXCOLUMNAS))) or 
            ((ord(f) - ord('A') = (ord(MAXFILAS) - ord('A')) div 2) and ((c = 1) or (c = MAXCOLUMNAS))) or
            ((c = (MAXCOLUMNAS div 2 + 1)) and ((f = 'A') or (f = MAXFILAS)) ) then
            t[f,c].bonus := TriplePalabra
         else if ((ord(f) - ord('A') + 1) = c) or ((ord(f) - ord('A') ) = MAXCOLUMNAS - c) then
            t[f,c].bonus := DobleLetra
         else if (abs(ord(f) - ord(filaCentro)) = c - 1) or (abs(ord(f) - ord('A')) = abs(c - colCentro)) or 
                 (abs(ord(f) - ord(filaCentro)) = abs(MAXCOLUMNAS - c)) then
            t[f,c].bonus := Trampa
         else
            t[f,c].bonus := Ninguno;
      end;
   t[filaCentro, colCentro].bonus := Ninguno;
end;

function totalLetras(hist : Histograma)  : integer;
{ Calcula la cantidad total de letras en el histograma }
var c : Letra;
      totalLetrasaux : integer;
begin
   totalLetrasaux := 0;
   for c := 'a' to 'z' do
      totalLetrasaux := totalLetrasaux + hist[c];
   totalLetras := totalLetrasaux;
end;

procedure calcularPuntajes(hist : Histograma; var ifichas : InfoFichas);
{ Calcula la puntuación de cada letra }
var
   c : char;
   totalLet: integer;
   cantidadFichas  : integer;
   acumulado: real;
   target: real;
   encontrada: boolean;
begin
   totalLet := totalLetras(hist);
   cantidadFichas := 0;

   // Asignar 1 ficha base a cada letra
   for c := 'a' to 'z' do
   begin
      ifichas[c].cantidad := 1;
      cantidadFichas := cantidadFichas + 1;
   end;

  // Distribuir el resto según frecuencia
   randomize;  // inicializa el generador aleatorio

   while cantidadFichas < TOTALFICHAS do
   begin
      target := random;
      acumulado := 0.0;
      c := 'a';
      encontrada := false;

      while (c <= 'z') and (not encontrada) do
      begin
         acumulado := acumulado + (hist[c] / totalLet);
         if acumulado >= target then
         begin
            ifichas[c].cantidad := ifichas[c].cantidad + 1;
            cantidadFichas := cantidadFichas + 1;
            encontrada := true;
         end
         else
            c := succ(c);
      end;
   end;

   for c := 'a' to 'z' do
   begin
      // write(c, '(', ifichas[c].cantidad:0,')  ');  
      if MAXPUNTAJE - ifichas[c].cantidad <= 0 then
         ifichas[c].puntaje := 1
      else
         ifichas[c].puntaje := MAXPUNTAJE - ifichas[c].cantidad
   end;
   writeln

end;

procedure mostrarBolsaFichas(bolsa : BolsaFichas);
{ Muestra la bolsa de fichas }
var i : integer;
begin
   writeln('Bolsa de fichas:');
   for i := 1 to bolsa.tope do
      write(bolsa.letras[i], ' ');
   writeln;
end;

procedure mostrarPuntajes(iFichas : InfoFichas);
{ Muestra los puntajes de cada letra }
var
   c: Letra;
begin
   writeln('Puntajes de cada letra:');
   write('  ');
   for c:= 'a' to 'z' do
      write(c, '  ');
   writeln;
   for c := 'a' to 'z' do
      write( iFichas[c].puntaje:3);
   writeln;
end;

procedure leerMinuscula(var f : text; var c: char);
{ Lee un caracter de la entrada, y lo transforma en minúscula de ser necesario }
{ El argumento f indica o un archivo o la entrada estándar desde el teclado }
begin
   read(f, c);
   if c in ['A'..'Z'] then c := chr (ord ('a') - ord ('A') + ord(c))   
end;

procedure leerMayuscula(var f : text; var c: char);
{ Lee un caracter de la entrada, y lo transforma en mayúscula de ser necesario }
{ El argumento f indica o un archivo o la entrada estándar desde el teclado }
begin
   read(f, c);
   if c in ['a'..'z'] then c := chr (ord ('A') - ord ('a') + ord(c))   
end;

procedure leerPalabra (var f : text; var p :Palabra );
{ Lee una palabra usando un autómata con tres estados }
type TEstado =  (START, s, STOP);
const carValidos =  ['a'..'z'];   { Caracteres válidos para una palabra }
var c	 : char;                  
   estado : TEstado;              
begin
   with p do
   begin
      { Inicialización de la palabra y del estado }
      tope := 0;
      estado := START;
      { Se itera hasta que se llega al estado final STOP }
      while estado <> STOP do
	 case estado of { Análisis del estado en que me encuentro }
	   { Estado START: consumo saltos de línea y caracteres que no son
	   aceptables para una palabra, y eventualmente el primer caracter
	   de una palabra }
	   START : if eof (f) then estado := STOP
		      { Cuando se acaba el archivo (eof) paso al estado final }
		   else if eoln (f) then readln (f)
		      { Cuando encuentro un salto de línea (eoln) lo consumo }
		   else
		   begin
		      { Leo un caracter }
		      leerMinuscula (f, c);
		      if c in carValidos then
			 { Guardo el primer caracter en p,
			 y paso al estado S para consumir
			 el resto de la palabra }
		      begin tope := 1; cadena[1] := c; estado := s end
		   end;
	   { Estado S: lee el resto de la palabra y la guarda en p }
	   s     : if eof (f) or eoln (f) then estado := STOP
		      { Cuando se acaba el archivo o se encuentra un salto de
		      línea, paso al estado final }
		   else
		   begin
		      { Leo un caracter }
		      leerMinuscula (f, c);
		      if c in carValidos then
			 { Guardo un nuevo caracter en p }
		      begin tope := 1 + tope; cadena[tope] := c end
		      else
			 { El caracter leído no es válido; la palabra ha sido
			 leída y paso al estado final }
			 estado := STOP
		   end
	 end;
   end
end;

procedure mostrarPalabra (p : Palabra);
{ Muestra la palabra p }
var k : 1..MAXPAL;
begin
   with p do
      for k := 1 to tope do write (cadena[k])
end;

// procedure mostrarTexto(txt : Texto);
// var iter : Texto;
// begin
//    iter := txt;
//    while iter <> nil do
//    begin
//       mostrarPalabra(iter^.info);
//       write(' ');
//       iter := iter^.sig;
//    end;
// end;

function leerTexto (fn : ansistring): Texto;
   procedure nuevoNodo(p : Palabra; var nodo: Texto);
   begin
      new(nodo);
      nodo^.info  := p
   end;
var l, it: Texto; p: Palabra; f:text;
begin
   assign (f, fn);     { Vincula el archivo físico fn con el archivo lógico f }
   reset (f);          { Abre el archivo f para leer }
   leerPalabra (f, p); { Lee una palabra de f        }
   if p.tope = 0
      then l := nil { Si el archivo es vacío devuelve la lista vacía }
   else
   begin
      { p es la palabra a guardar en la lista }
      nuevoNodo (p, l); it := l;   { guarda p en la lista }
      leerPalabra (f, p);          { lee la palabra p }
      while p.tope <> 0 do         { mientras puede leer palabras (no vacías) } 
      begin
	 nuevoNodo (p, it^.sig); it := it^.sig;  { guarda p en la lista }
	 leerPalabra (f, p)            { lee la palabra p }
      end;
      it^.sig := nil               { termina la lista }
   end;
   close (f);
   leerTexto := l
end;

procedure liberarTexto( var txt : Texto );
{ libera la memoria reservada para un texto }
var p : Texto;
begin
   while txt <> NIL do
   begin
      p := txt;
      txt := txt^.sig;
      dispose (p)
   end
end;

procedure mostrarHistograma (hist : Histograma );
{ Muestra el histograma hist }
var c : Letra;
    i : integer;
begin
   {El histograma es un arreglo de 26 enteros, que representan la cantidad de veces que aparece cada letra}
   for c := 'a' to 'z' do
   begin
      write(c,':');
      if hist[c] < 100 then
         for i := 1 to hist[c] do
            write('|');
      if hist[c] = 0 then
         writeln
      else
         writeln(' (',hist[c]:0,')')
   end
end;

function obtenerIndiceNuevaFicha(bolsa : BolsaFichas) : integer;
var 
   i : integer;
begin
   repeat
      i := random(bolsa.tope + 1)
   until i <> 0; { Asegura que el índice no sea cero y mantiene los resultados anteriores }
   obtenerIndiceNuevaFicha := i
   // obtenerIndiceNuevaFicha := random(bolsa.tope) + 1
end;

procedure mostrarAtril(mano : Atril; iFichas : InfoFichas);
{ Muestra el atril }
var i : integer;
begin
   if mano.tope = 0 then
      writeln('El atril está vacío.')
   else
   begin
      writeln('Atril:');
      for i := 1 to mano.tope do
         write('+---+ ');
      writeln;
      for i := 1 to mano.tope do
         write('| ', upcase(mano.letras[i]), ' | ');
      writeln;
      for i := 1 to mano.tope do
         write('| ', iFichas[mano.letras[i]].puntaje:0,' | ');
      writeln;
      for i := 1 to mano.tope do
         write('+---+ ');
      writeln;
   end
end;

procedure leerPosicion(var pos : Posicion);
{ Lee la posición}
var
   caux : char;
   cf : char;
   cc : integer;
begin
      writeln('Ingrese las coordenadas iniciales de la palabra (fila, columna). Ejemplo fila = A y col = 3, ingresar A3:');
      leerMayuscula(input, cf);
      readln(cc);
      writeln('Ingrese la direccion de la palabra, H (horizonal) o V (vertical):');
      leerMayuscula(input,caux);
      pos.fila := cf;
      pos.col := cc;
      if caux = 'H' then
         pos.direccion := Horizontal
      else if caux = 'V' then
         pos.direccion := Vertical;
end;

procedure ingresarPalabra(var p : Palabra; var pos : Posicion);
{ Ingresa una palabra indicando su posición (coordenadas y dirección) }
begin
   writeln('Ingrese la palabra:');
   leerPalabra(input, p);
   readln;
   leerPosicion(pos);
   writeln;
end;

procedure iniciarAtril(var mano : Atril);
{}
begin
   mano.tope := 0;
end;

procedure MostrarHistorial(jugadas : HistorialJugadas);
{ Muestra el historial de jugadas }
var
   i : integer;
begin
   if jugadas = nil then
      writeln('No hay jugadas en registradas.')
   else
   begin
      writeln('Historial de jugadas:');
      writeln('Palabra        Coordenadas        Dirección        Puntaje');
      writeln('----------------------------------------------------------');
      while jugadas <> nil do
      begin
         mostrarPalabra(jugadas^.palabra);
         for i := 1 to MAXCOLUMNAS - jugadas^.palabra.tope do
            write(' ');
         write('           ');
         write(jugadas^.pos.fila, jugadas^.pos.col:0);
         write('            ');
         if jugadas^.pos.direccion = Horizontal then
            write('Horizonal')
         else
            write('Vertical ');
         write('          ');
         write(jugadas^.puntaje:0);
         writeln;
         jugadas := jugadas^.sig
      end
   end;
   writeln
end;

procedure rellenarAtril(var mano : Atril);
{ Permite ingresar letras en el atril }
{ Se asume que el atril está vacío y se ingresan las letras sin espacios }
{ El usuario debe ingresar la cantidad de letras y luego las letras }
var num, i : integer;
    l : Letra;
begin
    writeln('Ingrese la cantidad de letras en el atril:');
    readln(num);
    mano.tope := num;
    writeln('Ingrese las letras del atril (sin espacios):');
    for i := 1 to num do
    begin
        read(l);
        mano.letras[i] := l
    end;
    readln
end;

procedure imprimirPosicion(pos : Posicion);
{ Imprime la posición de una palabra }
begin
   with pos do
   begin
      write(fila, col:0);
      case direccion of
         Horizontal: write(' Horizontal ');
         Vertical: write(' Vertical ')
      end
   end
end;

procedure leerLetrasTablero(var t: Tablero);
{ Permite ingresar letras en el tablero }
var num, i : integer;
    fila : 'A'..MAXFILAS;
    columna : 1..MAXCOLUMNAS;
    l : Letra;
begin
   mostrarTablero(t);
   writeln('Ingrese la cantidad de letras a colocar en el tablero:');
   readln(num);
   writeln('Ingrese uno por linea las coordenadas y la letra (sin espacios, ejemplo: B3j para ingesar la letra j en la coordenada B3):');
   for i := 1 to num do
   begin
      leerMayuscula(input, fila);
      read(columna);
      leerMinuscula(input, l);
      readln;
      t[fila,columna].ocupada := true;
      t[fila,columna].ficha := l
   end;
   mostrarTablero(t)
end;

procedure borrarHistorial(jugadas : HistorialJugadas);
{ Libera la memoria reservada para el historial de jugadas }
var aux : HistorialJugadas;
begin
    while jugadas <> nil do
    begin
    aux := jugadas;
    jugadas := jugadas^.sig;
    dispose(aux)
    end
end;

procedure leerDiccionario(var dicc : Texto);
{ Lee un diccionario desde un archivo de texto }
{ El archivo debe contener las palabras separadas por espacio }
{ Se asume que el archivo existe y es válido }
var fn : ansistring;
begin
   writeln('Ingrese el nombre del archivo de texto a tomar como diccionario:');
   readln(fn); 
   dicc := leerTexto(fn)
end;

procedure sacarFicha(indiceFicha : integer; var bolsa : BolsaFichas; var nuevaLetra : char);
{ Dada la bolsa de fichas y un índice de ficha, devuelve la letra de la ficha y actualiza la bolsa }
{ Se asume que el índice es válido }
begin
   nuevaLetra := bolsa.letras[indiceFicha];
   bolsa.letras[indiceFicha] := bolsa.letras[bolsa.tope];
   bolsa.tope := bolsa.tope - 1;
end;

procedure reponerFichas(var bolsa : BolsaFichas; var mano : Atril);
{ Dada la bolsa de fichas y un atril, llena el atril con fichas de la bolsa}
var i : integer;
begin
   for i := 1 to MAXATRIL - mano.tope do
   begin
      mano.tope := mano.tope + 1;
      sacarFicha(obtenerIndiceNuevaFicha(bolsa),bolsa,mano.letras[mano.tope])
   end
end;

procedure llenarBolsaFichas(info : InfoFichas; var bolsa : BolsaFichas);
{ Dada la distribución de fichas en info, llena la bolsa de fichas }
var c : char;
    i : integer;
begin
   bolsa.tope := 0;
   for c := 'a' to 'z' do
      for i := 1 to info[c].cantidad do
      begin
         bolsa.tope := bolsa.tope + 1;
         bolsa.letras[bolsa.tope] := c
      end
end;

{ --------------------------------------------------- }
{ Fin de definiciones.pas }
{ --------------------------------------------------- }