#set page(
  paper: "a4",
  margin: (x: 2.5cm, y: 2.5cm),
  numbering: "1",
  background: place(
    top + right,
    dx: -1cm,
    dy: 1cm,
    rotate(45deg, text(100pt, fill: rgb(240, 240, 240))[])
  )
)

#set text(
  lang: "pl", 
  font: "New Computer Modern", 
  size: 11pt
)

#set par(
  justify: true,
  leading: 0.7em,
  first-line-indent: 1em,
)

#show heading.where(level: 1): it => {
  
  
  block(
    fill: rgb(230, 240, 255),
    inset: 12pt,
    radius: 4pt,
    width: 100%,
    text(size: 14pt, weight: "bold")[
      #counter(heading).display() #it.body
    ]
  )
  v(0.8em)
}

#show heading.where(level: 2): it => {
  v(0.5em)
  block(
    inset: (left: 8pt),
    stroke: (left: 3pt + rgb(100, 150, 255)),
    text(size: 12pt, weight: "bold")[
      #counter(heading).display() #it.body
    ]
  )
  v(0.3em)
}

#set heading(numbering: "1.1")

#let current_date = datetime.today().display("[day].[month].[year]")

// Stopka zamiast nagłówka
#set page(
  footer: [
    #set text(8pt, fill: gray)
    #line(length: 100%, stroke: 0.5pt + gray)
    #v(0.2em)
    #grid(
      columns: (1fr, auto, 1fr),
      align: (left, center, right),
      [Wermiński Gabriel],
      [Algorytmy Geometryczne -  Triangulacja wielokątów \ monotonicznych],
      context counter(page).display("1 / 1", both: true)
    )
  ],
)

// Strona tytułowa
#align(center + horizon)[
  #v(2cm)
  
  #block(
    fill: rgb(240, 245, 255),
    inset: 20pt,
    radius: 8pt,
    width: 90%,
  )[
    #text(size: 13pt, weight: "bold")[Algorytmy Geometryczne]
    #v(0.3em)
    #text(size: 12pt)[Laboratorium 3]
  ]
  
  #v(1.5cm)
  
  #text(size: 34pt, weight: "bold", fill: rgb(50, 100, 200))[
    Triangulacja wielokątów \ monotonicznych
  ]
  
  #v(2cm)
  
  #block(
    width: 80%,
    inset: 15pt,
  )[
    #grid(
      columns: (auto, 1fr),
      row-gutter: 0.8em,
      column-gutter: 1em,
      align: (right, left),
      
      [*Imię i Nazwisko:*], [Wermiński Gabriel],
      [*Grupa:*], [6],
      [*Data wykonania:*], [#current_date],
    )
  ]
  
  #v(1fr)
]



#block(
  fill: rgb(245, 245, 250),
  inset: 15pt,
  radius: 4pt,
  width: 100%,
)[
  = Środowisko obliczeniowe

  Eksperymenty zostały przeprowadzone w następującej konfiguracji:
  
  #v(0.5em)
  
  #grid(
    columns: (auto, 1fr),
    row-gutter: 0.5em,
    column-gutter: 1em,
    
    [*Procesor:*], [CPU 12th Gen Intel(R) Core(TM) i5-1235U, 1.30 GHz],
    [*Pamięć RAM:*], [16.0 GB, 3200 MT/s],
    [*System operacyjny:*], [Microsoft Windows 11 Home],
    [*Środowisko programistyczne:*], [Jupyter Notebook, Pycharm],
    [*Język programowania:*], [Python 3.13.5],
    [*Biblioteki:*], [numpy, pandas, matplotlib, os],
  )
]
#pagebreak()
= Cel ćwiczenia

Zapoznanie się z zagadnieniami dotyczącymi monotoniczności wielokątów oraz implementacja algorytmów sprawdzania _y_-monotoniczności wielokąta, klasyfikacji wierzchołków w dowolnym wielokącie oraz triangulacji wielokąta _y-_monotonicznego. Celem było także wykonanie poszczególnych wizualizacji oraz analiza danych.

= Wstęp teoretyczny

== Monotoniczność wielokąta

#grid(
  columns: (1.2fr, 0.8fr),
  column-gutter: 1em,
  align(horizon + left)[
    Wielokąt prosty jest ściśle monotoniczny względem prostej _l_ (wyznaczającej kierunek monotoniczności), kiedy jego brzeg można przedstawić w postaci dwóch spójnych łańcuchów, z których każdy przecina się z dowolną prostą $l'$ prostopadłą do $l$ w nie więcej niż jednym punkcie.
    
    Przecięcie wielokąta z $l'$ jest spójne, co oznacza że jest ono odcinkiem, punktem lub jest puste.

    Wielokątem _y-_monotonicznym (#ref(<1>)) nazywamy wielokąt, który jest monotoniczny względem osi _y_, czyli w przypadku przejścia z najwyższego wierzchołka do najniższego, wzdłuż prawego lub lewego łańcucha, zawsze poruszamy się w dół lub poziomo.
  ],
  align(right + horizon)[
    #figure(
      image("Imgs/Example.png", width: 100%),
      caption: [wielokąt\ _y-_monotoniczny]
    )<1>
  ]
)

== Klasyfikacja wierzchołków wielokąta<klas>

#grid(
  columns: (1.2fr, 0.8fr),
  column-gutter: 1em,
  align(horizon + left)[
    Wierzchołki zostały podzielone na 5 rodzajów:
    
    - #text(fill: green)[*początkowy*], gdy obaj jego sąsiedzi leżą poniżej i kąt wewnętrzny < $pi$,
    - #text(fill: red)[*końcowy*], gdy obaj jego sąsiedzi leżą powyżej i kąt wewnętrzny < $pi$,
    - #text(fill: blue)[*łączący*], gdy obaj jego sąsiedzi leżą powyżej i kąt wewnętrzny > $pi$,
    - #text(fill: rgb(0, 221, 255))[*dzielący*], gdy obaj jego sąsiedzi leżą poniżej i kąt wewnętrzny > $pi$,
    - #text(fill: rgb(65, 42, 18))[*prawidłowy*], w pozostałych przypadkach (ma jednego sąsiada powyżej, drugiego – poniżej).
  ],
  align(right + horizon)[
    #figure(
      image("Imgs/Example_tri.png", width: 100%),
      caption: [wielokąt \ niemonotoniczny z wierzchołkami\ pokolorowanymi zgodnie z ich \ klasyfikacją]
    )
  ]
)

== Triangulacja wielokąta <zalez>

#grid(
  columns: (1.2fr, 0.8fr),
  column-gutter: 1em,
  align(horizon + left)[
    Triangulacja wielokąta to podział wielokąta na rozłączne trójkąty poprzez dodanie nieprzecinających się przekątnych łączących jego wierzchołki. W procesie triangulacji wszystkie dodawane przekątne muszą leżeć wewnątrz wielokąta, a ich końce muszą być jego wierzchołkami. Dla wielokąta o $n$ wierzchołkach triangulacja zawsze składa się z $n-2$ trójkątów połączonych \ $n-3$ przekątnymi. Przykład takiej triangulacji można zauważyć na #ref(<2>, supplement: "Rysunku").
  ],
  align(right + horizon)[
    #figure(
      image("Imgs/C.png", width: 90%),
      caption: [Przykładowa triangulacja wielokąta\ _y-_monotonicznego]
    )<2>
  ]
)

= Realizacja ćwiczenia

== Szczegóły implementacyjne

=== Opis Algorytmu Weryfikacji Monotoniczności Względem Osi y<ymono>

Metoda ma na celu sprawdzenie, czy wielokąt, którego wierzchołki zadane są w kolejności przeciwnej do ruchu wskazówek zegara (CCW), jest y-monotoniczny. Wielokąt spełnia ten warunek, jeśli jego obwód dzieli się na dwa łańcuchy monotoniczne względem osi y: Lewy(nierosnący) i Prawy(niemalejący).
  
+ *Identyfikacja Ekstremów* - Wyznaczane są indeksy wierzchołków : *$P_"max"$*(punkt najwyższy) i *$P_"min"$*(punkt najniższy). Te punkty stanowią granice podziału obwodu na dwa łańcuchy.

+ *Weryfikacja Łańcuchów Monotonicznych.* 

 - Łańcuch Lewy ( CCW od *$P_"max"$​* do *$P_"min"$* ) - Wartości y muszą być nierosnące $(y_"poprzedni"​ ≥ y_"obecny")$​. Jeśli y wzrośnie, wielokąt nie jest monotoniczny.
 
 - Łańcuch Prawy ( CCW od *$P_"min"$​* do *$P_"max"$* ) - Wartości y muszą być niemalejące $(y_"poprzedni"​ ≥ y_"obecny")$​. Jeśli y zmaleje, wielokąt nie jest monotoniczny.

+ *Wynik* - Jeśli jakikolwiek warunek monotoniczności zostanie naruszony podczas przechodzenia któregokolwiek łańcucha, funkcja natychmiast zwraca False. W przeciwnym razie zwracana jest wartość True.

=== Funkcja obliczająca wartość wyznacznika

W rozważanych algorytmach kluczową rolę odgrywa funkcja do obliczania wyznacznika macierzy 3×3. Ta funkcja, operująca na współrzędnych trzech punktów płaszczyzny a, b i c, jest zdefiniowana jako:
$ det(a, b, c) = mat(delim: "|", a_x, a_y, 1;
                        b_x, b_y, 1;
                        c_x, c_y, 1)  = (b_x - a_x)(c_y - b_y) - (b_y - a_y)(c_x - b_x) $

W przyjętej implementacji, próg precyzji ustalono na: $bold(epsilon = 10^(-24))$.

=== Algorytm klasyfikacji wierzchołków wielokąta

Algorytm przydziela każdemu wierzchołkowi $P_i$​ jedną z pięciu kategorii (0-4), zgodnie z warunkami szczegółowo opisanymi w #ref(<klas>, supplement: "Sekcji") . Proces ten bazuje na cyklicznej analizie wierzchołków wielokąta zdefiniowanego w porządku CCW.

+ Dla każdego wierzchołka $P_i$​ następuje dwuetapowa weryfikacja:
  
  - Analiza Pionowa (y): Porównanie współrzędnej y wierzchołka $P_i$​ z poprzednikiem $P_"i−1"$​ i następnikiem $P_"i+1"$​. Określa to, czy wierzchołek leży na łuku wznoszącym, czy opadającym, co zawęża potencjalne typy (Początkowy/Dzielący vs. Końcowy/Łączący).

  - Analiza Kąta (Wyznacznik): Obliczenie wartości det($P_"i−1"$​,$P_i​$,$P_"i+1"$​) ustala charakter kąta w $P_i$​ jako wypukły, wklęsły lub współliniowy.

+ Klasyfikacja i Przypisanie Kodu :

  - Kombinacja wyników tych analiz determinuje finalną kategorię, zgodnie z którą kod (0, 1, 2, 3 lub 4) zostaje przypisany do wierzchołka. Wierzchołki, które są współliniowe lub leżą wewnątrz pojedynczego monotonicznego łuku, są klasyfikowane jako Prawidłowe.
#v(0.5em)
=== Implementacja algorytmu triangulacji wielokąta monotonicznego

#v(0.5em)
+ *Identyfikacja punktów ekstremalnych* - Algorytm rozpoczyna od zlokalizowania wierzchołków o maksymalnej i minimalnej współrzędnej _y_, które stanowią naturalne granice podziału wielokąta.

+ *Klasyfikacja wierzchołków na ścieżki* - Punkty są przypisywane do lewej lub prawej ścieżki poprzez dwukierunkowe przejście: od najwyższego do najniższego punktu (tworząc lewą ścieżkę) oraz w kierunku przeciwnym (prawą ścieżkę). Punkty ekstremalne otrzymują osobną etykietę.

+ *Scalanie i sortowanie* - Obie ścieżki są łączone w jedną sekwencję uporządkowaną malejąco względem współrzędnej _y_ przy użyciu procedury merge, z punktami ekstremalnymi na pozycjach brzegowych.

+ *Inicjalizacja stosu* - Dwa pierwsze elementy z posortowanej sekwencji są umieszczane na stosie jako kandydaci do tworzenia przekątnych.

+ *Obsługa różnych ścieżek* - Gdy aktualny wierzchołek należy do innej ścieżki niż szczyt stosu, tworzone są przekątne z wszystkimi elementami stosu (pomijając pierwszy). Specjalny warunek dla najniższego punktu zapobiega duplikacji ostatniej krawędzi wielokąta. Stos jest resetowany do ostatniego elementu plus aktualny punkt.

+ *Obsługa tej samej ścieżki* - Gdy punkty należą do jednej ścieżki, algorytm iteracyjnie sprawdza możliwość utworzenia przekątnych ze zdejmowanymi ze stosu wierzchołkami, zachowując minimum dwa elementy na stosie.

+ *Weryfikacja orientacji* - Poprawność triangulacji sprawdzana jest przez wyznacznik macierzy $3 times 3$ - dla lewej ścieżki wymagana jest orientacja lewoskrętna ($det > epsilon$), dla prawej - prawoskrętna ($det < -epsilon$).

+ *Tolerancja numeryczna* - Użycie epsilon w porównaniach wyznaczników eliminuje problemy z błędami zaokrągleń arytmetyki zmiennoprzecinkowej.

+ *Normalizacja wyników* - Każda para indeksów przekątnej jest sortowana, co ułatwia późniejszą eliminację potencjalnych duplikatów i standaryzuje reprezentację.

+ *Gwarancja złożoności liniowej* - Każdy wierzchołek jest dodawany na stos dokładnie raz i może być usunięty maksymalnie raz, co zapewnia złożoność $O(n)$.

== Zestawy danych testowych

Zbiór wielokątów geometrycznych został stworzony interaktywnie za pomocą narzędzia wykorzystującego bibliotekę *matplotlib*. Ta graficzna aplikacja umożliwiła precyzyjne definiowanie wierzchołków na płaszczyźnie, co stanowiło bazę dla dalszych obliczeń algorytmicznych. Przykłady utworzonych wielokątów oraz rezultaty ich triangulacji zostaną zaprezentowane w dalszej części pracy.

= Analiza wyników

== Rezultaty Weryfikacji Monotoniczności

Przeprowadzona analiza geometryczna, bazująca na zaimplementowanym algorytmie sprawdzania y-monotoniczności, potwierdziła przewidywane charakterystyki figur.

Konkretnie, testy wykazały, że:

- Wielokąty A, B, C oraz E spełniają warunek y-monotoniczności.

- Wielokąt D nie spełnia warunku y-monotoniczności.

Uzyskane wyniki są w pełni zgodne z wstępną hipotezą dotyczącą wybranych figur testowych.

== Algorytm klasyfikacji wierzchołków wielokątów

Wyniki kategoryzacji, zgodnie z konwencją barwną z Sekcji #ref(<klas>, supplement: "Sekcji"), wyraźnie ilustrują związek między typem wierzchołków a właściwością y-monotoniczności:

Wielokąty y-Monotoniczne: Figury te (A, B, C, E, F) konsekwentnie wykazują obecność tylko jednego wierzchołka początkowego (start) i jednego końcowego. Wszystkie pozostałe wierzchołki są poprawnie identyfikowane jako prawidłowe. Stanowi to bezpośrednie potwierdzenie twierdzenia, że wielokąty y-monotoniczne są wolne od wierzchołków łączących i dzielących.

Wielokąt Nie-y-Monotoniczny: Z kolei w figurach nie-y-monotonicznych, figura(D) obserwuje się występowanie wierzchołków łączących lub dzielących, które są geometrycznym powodem utraty monotoniczności.

Na poniższych rysunkach zamieszczone zostały wizualizacje wielokątów testowych zwrócone przez algorytm, wraz z wierzchołkami pokolorowanymi zgodnie z przyjętą w #ref(<klas>, supplement: "Sekcji") konwencją.

#grid(
  columns: (1fr, 1fr),
  align(top + left)[
    #figure(
    image("Imgs/colors_A.png", width: 75%),
    caption: [
      Klasyfikacji figury A
    ],
  )<Aklas>
  ],
  align(top + right)[
    #figure(
    image("Imgs/colors_B.png", width: 75%),
    caption: [
      Klasyfikacji figury B
    ],
  )<Bklas>
    ],
)

#grid(
  columns: (1fr, 1fr),
  align(top + left)[
    #figure(
    image("Imgs/colors_C.png", width: 75%),
    caption: [
Klasyfikacji figury C    ],
  )<Cklas>
  ],
  align(top + right)[
    #figure(
    image("Imgs/colors_D.png", width: 75%),
    caption: [
      Klasyfikacji figury D
    ],
  )<Dklas>
    ],
)

#grid(
  columns: (1fr, 1fr),
  align(top + left)[
    #figure(
    image("Imgs/colors_E.png", width: 79%),
    caption: [
      Klasyfikacji figury E
    ],
  )<Eklas>
  ],
  align(top + right)[
    #figure(
    image("Imgs/colors_F.png", width: 79%),
    caption: [
      Klasyfikacji figury F
    ],
  )<Fklas>
    ],
)

Dane wizualne, zgodnie z oczekiwaniami, demonstrują, że zaimplementowany algorytm z sukcesem identyfikuje i kategoryzuje wierzchołki w kluczowych punktach geometrycznych, co stanowi niezbędny etap do dalszych procesów, takich jak triangulacja.

== Algorytm triangulacji wielokątów _y-_monotonicznych

W ramach eksperymentów uruchomiono zaimplementowany algorytm triangulacji dla przygotowanych wcześniej zestawów danych testowych. Przeprowadzono również testy na wielokątach niespełniających warunku _y-_monotoniczności, aby zademonstrować, że algorytm nie działa poprawnie bez zachowania tego wymagania. Zastosowanie go w takich sytuacjach wymagałoby wcześniejszej dekompozycji wielokątów na części spełniające warunek _y-_monotoniczności.

W przedstawionych wizualizacjach zastosowano następującą konwencję kolorystyczną: krawędzie stanowiące brzeg wielokąta oznaczono kolorem czarnym, #text(fill: blue)[niebieskim] kolorem wyróżniono wierzchołki ekstremalne ($P_"max"$, $P_"min"$), #text(fill: green)[zielony] kolor przypisano pozostałym wierzchołkom, natomiast #text(fill: red)[kolorem czerwonym] oznaczono przekątne wprowadzone w procesie triangulacji.

#grid(
  columns: (1fr, 1fr),
  align(top + left)[
    #figure(
    image("Imgs/A.png", width: 79%),
    caption: [
      Triangulacja figury A
    ],
  )<Atriang>
  ],
  align(top + right)[
    #figure(
    image("Imgs/B.png", width: 79%),
    caption: [
      Triangulacja figury B
    ],
  )<Btriang>
    ],
)

#grid(
  columns: (1fr, 1fr),
  align(top + left)[
    #figure(
    image("Imgs/C.png", width: 79%),
    caption: [
      Triangulacja figury C
    ],
  )<Ctriang>
  ],
  align(top + right)[
    #figure(
    image("Imgs/D.png", width: 79%),
    caption: [
      Triangulacja figury D
    ],
  )<Dtriang>
    ],
)

#grid(
  columns: (1fr, 1fr),
  align(top + left)[
    #figure(
    image("Imgs/E.png", width: 79%),
    caption: [
      Triangulacja figury E
    ],
  )<Etriang>
  ],
  align(top + right)[
    #figure(
    image("Imgs/F.png", width: 79%),
    caption: [
      Triangulacja figury F
    ],
  )<Ftriang>
    ],
)

Zgodnie z przewidywaniami, zastosowanie przedstawionego algorytmu do wielokątów niespełniających warunku _y-_monotoniczności nie przynosi oczekiwanych rezultatów. Na wizualizacjach wyraźnie widać, że dla przypadku D wprowadzone przekątne nie tylko generują trójkąty leżące poza obszarem figury, ale także przecinają jej krawędzie brzegowe. Przyczyna tkwi w niewłaściwym działaniu mechanizmu rozdzielającego wierzchołki na oba łańcuchy w sytuacji braku monotoniczności, co następnie powoduje błędy w procedurze scalającej. Sam algorytm triangulacji również nie jest przystosowany do obsługi takich struktur – konieczna byłaby uprzednia dekompozycja na komponenty _y-_monotoniczne.

*Wielokąt A* stanowi przykład figury wypukłej, w której punkty rozłożone są "symetrycznie" wzdłuż obu łańcuchów. Podczas wykonywania triangulacji, każdy kolejno analizowany wierzchołek przynależy do łańcucha przeciwnego względem dwóch elementów przechowywanych na szczycie stosu. Taka konfiguracja eliminuje ryzyko tworzenia trójkątów zewnętrznych. Rezultat triangulacji zaprezentowano na #ref(<Atriang>, supplement: "Rysunku").

*Wielokąt B* zawiera pojedynczy kąt wklęsły umieszczony na lewym łańcuchu. Test ten weryfikuje, czy mechanizm triangulacji prawidłowo identyfikuje sytuacje, w których krawędź brzegowa figury nie powinna być błędnie dodawana do zbioru przekątnych.

*Wielokąt C* został zaprojektowany w celu weryfikacji zachowania algorytmu w obecności wielu kątów wklęsłych skoncentrowanych na jednym łańcuchu, przy jednoczesnej wypukłości pozostałych fragmentów. Przypadek ten bada efektywność zarządzania stosem oraz poprawność wykrywania trójkątów wykraczających poza granice wielokąta lub odcinków współliniowych z jego bokami.

*Wielokąt D* – jak wspomniano wcześniej – reprezentuje przypadek niemonotoniczny, dla którego algorytm nie funkcjonuje poprawnie zgodnie z przewidywaniami teoretycznymi.

*Wielokąt E* ma kształt elipsy z wieloma wierzchołkami rozłożonymi równomiernie wzdłuż obwodu. Przypadek ten testuje sytuację, w której punkty należące do obu łańcuchów występują naprzemiennie. Triangulacja weryfikuje zdolność algorytmu do prawidłowego łączenia wierzchołków z przeciwległych łańcuchów, gdy struktura wielokąta jest wypukła i symetryczna.

*Wielokąt F* w którym niemal wszystkie wierzchołki (z wyjątkiem kilku skrajnych) są zgrupowane wzdłuż prawego łańcucha i tworzą charakterystyczny układ przypominający "grzebień". Ten scenariusz sprawdza, jak algorytm radzi sobie z sytuacją, gdy jeden z łańcuchów jest zdominowany przez liczne punkty, podczas gdy drugi jest minimalny. W procesie triangulacji wszystkie wierzchołki z prawego łańcucha są systematycznie łączone przekątnymi, tworząc strukturę trójkątów rozpiętych między gęsto rozmieszczonymi punktami a prostą krawędzią lewego łańcucha.

#v(1em)

#align(center + top)[
  #figure(
    block(
      fill: rgb(250, 250, 255),
      inset: 10pt,
      radius: 4pt,
      table(
        align: center + horizon,
        columns: (auto, auto, auto, auto, auto, auto, auto),
        rows: (auto, auto),
        stroke: (x, y) => if y == 0 { (bottom: 1pt) } else { none },
        fill: (x, y) => if y == 0 { rgb(230, 240, 255) },
        [*Figura*],[*A*], [*B*], [*C*], [*D*], [*E*], [*F*],
        [*Liczba wierzchołków*],        [18], [10], [10], [26], [15], [15],
        [*Liczba dodanych przekątnych*], [15], [7], [7], [23], [12], [12]
      )
    ),
    caption: [Zestawienie liczby wierzchołków i przekątnych dla badanych wielokątów]
  )<porow>
]

Z przedstawionej tabeli wynika, że ilość wprowadzonych przekątnych jest zgodna z zależnością zaprezentowaną w #ref(<zalez>, supplement: "Sekcji") i odpowiada wartości $n - 3$, przy czym $n$ oznacza liczbę wierzchołków danego wielokąta. Dla wymienionych figur algorytm wygenerował prawidłowe triangulacje.

= Wnioski

Przeprowadzone eksperymenty pozwoliły na weryfikację poprawności zaimplementowanych algorytmów oraz potwierdzenie ich zgodności z założeniami teoretycznymi dotyczącymi monotoniczności wielokątów i ich triangulacji.

Algorytm weryfikacji _y-_monotoniczności wielokąta wykazał pełną zgodność z przewidywaniami teoretycznymi. Poprawnie zidentyfikowano wielokąty spełniające warunek monotoniczności (A, B, C, E, F) oraz wielokąt niemonotoniczny (D). Metoda oparta na analizie dwóch łańcuchów monotoniczności okazała się skuteczna i efektywna obliczeniowo. Kluczowym elementem implementacji było precyzyjne wyznaczenie punktów ekstremalnych ($P_"max"$ i $P_"min"$) oraz weryfikacja nierosnącego charakteru łańcucha lewego i niemalejącego charakteru łańcucha prawego.

Algorytm klasyfikacji wierzchołków wielokąta prawidłowo przypisał każdy wierzchołek do odpowiedniej kategorii (początkowy, końcowy, łączący, dzielący, prawidłowy). Wizualizacje potwierdziły fundamentalną właściwość wielokątów _y-_monotonicznych: obecność dokładnie jednego wierzchołka początkowego i jednego końcowego, przy braku wierzchołków łączących i dzielących. W przypadku wielokąta niemonotonicznego (D) algorytm poprawnie wykrył wierzchołki łączące lub dzielące, które stanowią geometryczną przyczynę utraty monotoniczności. Zastosowanie funkcji wyznacznika macierzy 3×3 z progiem precyzji $epsilon = 10^(-24)$ okazało się wystarczające do rozróżnienia kątów wypukłych od wklęsłych, unikając problemów numerycznych związanych z arytmetyką zmiennoprzecinkową.

Algorytm triangulacji wielokątów _y-_monotonicznych zrealizował poprawną dekompozycję wszystkich wielokątów monotoniczych na trójkąty nieprzecinające się. Dla każdego wielokąta o $n$ wierzchołkach wygenerowano dokładnie $n-3$ przekątnych, co potwierdza teoretyczną zależność. Mechanizm stosowy zapewnił liniową złożoność czasową $O(n)$ algorytmu, a weryfikacja orientacji przez wyznacznik skutecznie eliminowała próby utworzenia przekątnych wykraczających poza obszar wielokąta lub przecinających jego brzeg. Test na wielokącie niemonotoniczny (D) zademonstrował krytyczne znaczenie spełnienia warunku _y-_monotoniczności – bez niego algorytm generuje nieprawidłowe przekątne przecinające się z krawędziami brzegowymi oraz trójkąty leżące poza obszarem wielokąta.

Różnorodność testowanych przypadków (wielokąty wypukłe, wklęsłe, symetryczne, asymetryczne, typu "grzebień") pozwoliła na kompleksową walidację implementacji. Szczególnie istotne okazały się testy graniczne: wielokąt B z pojedynczym kątem wklęsłym weryfikował poprawność wykrywania krawędzi brzegowych, wielokąt C z wieloma kątami wklęsłymi testował efektywność zarządzania stosem, wielokąt E o kształcie elipsy sprawdzał naprzemienne łączenie wierzchołków z obu łańcuchów, a wielokąt F typu "grzebień" badał zachowanie algorytmu przy silnej asymetrii rozkładu punktów między łańcuchami.
