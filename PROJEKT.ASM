	org 100h	; PRZESUNIECIE

	;PROJEKT NA ZALICZENIE PRZEDMIOTU ARCHITEKTURA KOMPUTEROW 2020/2021
	;AUTOR: MICHAL PAMIETA, NUMER ALBUMU: 196099
	;TEMAT PROJEKTU - NUMER 5
	;Napisac program, ktory pobiera dwa lancuchy znakowe z wejscia i wypisuje na wyjsciu
	;jeden lancuch zlozony z co drugiego znaku z kazdego lancucha wejsciowego (na przyklad
	;dwa lancuchy "ABC" i "abc" powinny dac wynik "AaBbCc"). Program powinien moc wielokrotnie
	;powtarzac operacje z roznymi ciagami znakow oraz zakonczyc prace po nacisnieciu przez
	;uzytkownika klawisza SPACJA. Wykorzystac procedury i stos. Przewidziec sytuacje wyjatkowe.

	PUSHA
	PUSHF

	CALL	czysc
powitaj:
	;komunikat z przywitaniem uzytkownika wyswietlam tylko raz, podczas pierwszego uruchomienia programu
	MOV	DX,witaj
	CALL	pisz
start:
	;zakladam, ze progam musi wykonac sie przynajmniej raz zanim bedzie mozna
	;przerwac jego dzialanie klawiszem SPACJA, dlatego:
	;1. wyswietlam komunikaty i pobieram oba ciagi znakow
	CALL	pobLan
	;2. wykonuje laczenie pobranych ciagow w jeden lancuch znakow i wyswietlam wynik
	CALL polacz
	;3. pytam czy kontynuowac prace / przerwac dzialanie programu
	JMP	restart
	;przypadki testowe (wszystkie mozliwe kombinacje):
	;a) oba ciagi jednakowej dlugosci
	;b) dwa puste ciagi
	;c) dwa ciagi max dlugosci
	;d) pierwszy ciag pusty, drugi ciag "normalny" i odwrotnie
	;e) pierwszy ciag krotszy, drugi - dluzszy i odwrotnie
	;*jezeli ciagi sa roznej dlugosci to dopoki nie skonczy sie krotszy ciag, dopoty lacze oba ciagi,
	;jak skonczy sie krotki, to reszte dluzszego ciagu dopisuje na koncu lancucha wyjsciowego
koniec:
	;pozegnanie uzytkownika
	CALL	ent
	MOV	DX,fin
	CALL	pisz
	
	POPA
	POPF
	MOV	AX,4C00H	; KONIEC PROGRAMU
	INT	21H
	
c	TIMES	25	db	10
	db	36
;(OPCJONALNIE) mozna zwiekszyc limit
ciagA	db	26
		db	0
		TIMES	27	db	0
ciagB	db	26
		db	0
		TIMES	27	db	0
ciagW	TIMES	51	db	0
		db	36
	
witaj db "Witaj w programie laczacym dwa ciagi w jeden lancuch znakowy.",36
kom1 db	"Podaj pierwszy ciag znakow",36
kom2 db	"Podaj drugi ciag znakow",36
komW	db	"Wynik laczenia dwoch ciagow to nastepujacy lancuch znakowy:",36
komP1	db	"Czy chcesz polaczyc inne ciagi w jeden lancuch znakowy?",36
komP2	db	"Jesli tak - kliknij dowolny klawisz, jesli nie - wcisnij klawisz SPACJA.",36
blad	db	"Oba wprowadzone ciagi sa puste!",36
fin	db	"Dziekuje za skorzystanie z programu!",36

czysc:
	MOV	AH,9
	MOV	DX,c
	INT	21H
RET

ent:
	MOV	AH,2
	MOV	DL,10
	INT	21H
	MOV	DL,13
	INT	21H
RET

pisz:
	MOV	AH,9
	INT	21H
	CALL	ent
RET

pobLan:
	;wyswietlanie komunikatow i pobieranie dwoch lancuchow
	CALL	ciag1
	CALL	ent
	CALL	ciag2
	CALL	ent
RET

ciag1:
	;ciag A - komunikat
	CALL	ent
	MOV	DX,kom1
	CALL	pisz
	;pobieranie pierwszego ciagu znakow
	MOV	AH,10
	MOV	DX,ciagA
	INT	21H
RET

ciag2:
	;ciag B - komunikat
	CALL	ent
	MOV	DX,kom2
	CALL	pisz
	;pobieranie drugiego ciagu znakow
	MOV	AH,10
	MOV	DX,ciagB
	INT	21H
RET

;zasada dzialania laczenia dwoch ciagow w jeden lancuch znakowy: 
;di definiuje indeks w ciagach, si - w lancuchu. ustawiam ograniczenie w cl na dlugosc dluzszego ciagu.
;jezeli ustalona dlugosc jest rowna 0, wyswietlam komunikat i skacze do restartu programu
;potem w petli przechodze po indeksach di (najpierw czytam znak z ciagA i wpisuje do ciagW, poznej robie
;to samo dla ciagB); dla wszystkich di postepuje analogicznie jw z pozostalymi znakami w ciagA oraz ciagB
;jezeli brak znaku (wpisane 0), to nie dopisuje i przechodze do nastepnego kroku
polacz:
	CALL	ent
	;ustawiam indeksy poczatkowe
	MOV	DI,1	;dla pobranych ciagow
	XOR	SI,SI	;dla lancucha wynikowego
licz:
	;obliczam/wyznaczam licznik dla petli
	;sprawdzam ktory ciag jest dluzszy -> ustawiam ile razy wykona sie petla z laczeniem ciagow
	;jezeli podane ciagi sa puste -> wyswietlam komunikat i przechodze do konca/restartu programu
	MOV	CL,[ciagA+DI]
	CMP	CL,[ciagB+DI]
	JG	petla
	MOV	CL,[ciagB+DI]
	CMP	CL,0
	JNE petla
	MOV	DX,blad
	CALL	pisz
	JMP	restart
petla:
	INC DI
	;wstawiam znak z pierwszego ciagu do lancucha wynikowego
	;jezeli 13 lub 0 to przechodze do drugiego ciagu
	lan1:
	MOV	AL,[ciagA+DI]
	CMP	AL,13
	JE	lan2
	CMP	AL,0
	JE	lan2
	CALL	dopisz
	;wstawiam znak z drugiego ciagu do lancucha wynikowego
	;jezeli 13 lub 0 to przechodze do konca petli
	lan2:
	MOV	AL,[ciagB+DI]
	CMP	AL,13
	JE	kp
	CMP	AL,0
	JE	kp
	CALL	dopisz
kp:
loop petla
kon:
	;wyswietlanie komunikatu
	MOV	DX,komW
	CALL pisz
	;wypisanie lancucha wyjsciowego - wynikowego
	XOR	DI,DI
	MOV	CL,[ciagA+1]
	ADD	CL,[ciagB+1]
wys:
	MOV	AH,2
	MOV	DL,[ciagW+DI]
	INT	21H
	INC	DI
loop wys
RET

;procedura wstawiajaca znak z ciagA lub ciagB do ciagW
dopisz:
	;dopisuje litere z ciagu do lancucha i zwiekszam "indeks" si
	MOV	[ciagW+SI],AL
	INC	SI
RET

restart:
	CALL	ent
	;komunikaty (czy koniec programu)
	MOV	DX,komP1
	CALL	pisz
	MOV	DX,komP2
	CALL	pisz
	;pobranie znaku, sprawdzanie czy spacja
	MOV	AH,1
	INT 21H
	CMP	AL,32
	JE	koniec	;koncze dzialanie programu
	CALL	res	;resetuje ciagi
	JMP	start	;uruchamiam ponownie program
res:
	;zerowanie kolejnych lancuchow
	XOR	BX,BX
	MOV	DI,1
	;pierwszy
	MOV	CL,[ciagA+DI]
	CMP	CL,BL
	JNE	pa
	;drugi
	MOV	CL,[ciagB+DI]
	CMP	CL,BL
	JNE	pb
	;wynikowy
	MOV	CL,[ciagW+DI]
	CMP	CL,BL
	JNE	pw
	JE	ko
pa:
	MOV	AL,[ciagA+DI]
	CMP	AL,BL
	JE	res
	MOV	[ciagA+DI],BL
	INC	DI
	JMP	pa
pb:
	MOV	AL,[ciagB+DI]
	CMP	AL,BL
	JE	res
	MOV	[ciagB+DI],BL
	INC	DI
	JMP	pb
pw:
	MOV	AL,[ciagW+DI]
	CMP	AL,BL
	JE	res
	MOV	[ciagW+DI],BL
	INC	DI
	JMP	pw
ko:
RET