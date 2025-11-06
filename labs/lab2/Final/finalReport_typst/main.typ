#set page(
  paper: "a4",
  margin: (x: 2cm, y: 2cm),
  numbering: "1",
)

#set text(
  lang: "pl", 
  font: "New Computer Modern", 
  size: 11pt
)

#set par(
  justify: true,
  leading: 0.65em,
)

#set heading(numbering: "1.")

#let current_date = datetime.today().display("[day].[month].[year]")

// Nagłówek
#set page(
  header: [
    #set text(9pt)
    #grid(
      columns: (1fr, 1fr),
      align: (left, right),
      [Algorytmy Geometryczne],
      [Wermiński Gabriel],
    )
    #line(length: 100%, stroke: 0.5pt)
  ],
)

// Strona tytułowa
#align(center)[

  #text(size: 16pt)[*Algorytmy Geometryczne - Laboratorium 2*]
  
    #text(size: 18pt)[*Otoczka wypukła*]
  
]

#grid(
  columns: (1fr, 1fr),
  align(left)[
    *Imię i nazwisko:* Wermiński Gabriel
    
    *Grupa:* 6

  ],
  align(right)[
    *Data wykonania:* #current_date
  ],
)
= Środowisko obliczeniowe

Eksperymenty zostały przeprowadzone w następującej konfiguracji:
- *Procesor:* CPU 12th Gen Intel(R) Core(TM) i5-1235U, 1.30 GHz
- *Pamięć RAM:* 16.0 GB, 3200 MT/s
- *System operacyjny:* Microsoft Windows 11 Home
- *Środowisko programistyczne:* Jupyter Notebook, Pycharm
- *Język programowania:* Python 3.13.5
- *Biblioteki:* numpy, pandas, matplotlib

= Cel ćwiczenia

Głównym zadaniem przeprowadzonego ćwiczenia było opracowanie dwóch algorytmów służących do wyznaczania otoczki wypukłej: Grahama oraz Jarvisa. W ramach projektu porównano ich efektywność obliczeniową, analizując zależność czasu wykonania od liczby punktów w zbiorze danych. Dodatkowo, dla każdego przypadku przeprowadzono wizualizację działania obu algorytmów oraz zestawiono uzyskane wyniki w celu oceny różnic w złożoności czasowej i jakości wyznaczonych otoczek.

= Wstęp teoretyczny

== Definicja otoczki wypukłej

#grid(
  columns: (1fr, 0.6fr),
  align(horizon + left)[
    Otoczka wypukła zbioru punktów _S_, oznaczana jako _CH(S)_, to najmniejszy zbiór wypukły zawierający wszystkie punkty należące do _S_.  
    Innymi słowy, jest to figura, której każdy punkt znajduje się na zewnątrz lub wewnątrz względem wszystkich elementów zbioru, a żaden punkt spoza niej nie należy do otoczki.

    W przypadku przestrzeni dwuwymiarowej, otoczka ma postać wielokąta wypukłego o minimalnym obwodzie obejmującego dany układ punktów.  
    Wierzchołki tego wielokąta zapisuje się kolejno w kierunku przeciwnym do ruchu wskazówek zegara, co odpowiada konwencji układu prawoskrętnego.
  ],
  align(right + horizon)[
    #figure(
      image("Imgs/Otoczka_wyklad.png", width: 60%),
      caption: [Ilustracja przykładowej otoczki wypukłej $cal(L) = (p_3, p_4, p_8, p_6, p_1, p_5)$ utworzonej ze zbioru punktów ${p_1, p_2, ..., p_8}$.]
    )
  ]
)

W sytuacji, gdy część punktów zbioru leży na jednej prostej, do otoczki włączane są jedynie te, które stanowią punkty skrajne na danym odcinku. Pozostałe punkty współliniowe nie wpływają na kształt otoczki i są pomijane w końcowym zbiorze wierzchołków.


== Algorytmy znajdowania otoczki wypukłej
=== Algorytm Grahama
Działanie algorytmu Grahama opiera się na systematycznym eliminowaniu wierzchołków tworzących wklęsłości. Mechanizm ten wykorzystuje stos przechowujący kandydatów do otoczki oraz przegląd punktów uporządkowanych kątowo.

+ Ze zbioru $Q$ wyznaczamy punkt startowy $p_0$ o najmniejszej wartości współrzędnej $y$. Gdy istnieje wiele punktów o tej samej współrzędnej $y$, spośród nich wybieramy punkt o minimalnej współrzędnej $x$.

+ Punkty pozostałe porządkujemy względem kąta, jaki tworzy wektor $(p_0, p)$ z dodatnim kierunkiem osi $O X$. Do wyznaczenia kąta stosujemy funkcję `arctan2(vy, vx)`, gdzie `vx` oraz `vy` reprezentują składowe wektora łączącego $p_0$ z punktem $p$. W sytuacji, gdy różne punkty wyznaczają ten sam kąt (z tolerancją `eps`), w ciągu pozostawiamy wyłącznie punkt najdalszy od $p_0$, eliminując pozostałe, co daje uporządkowaną sekwencję ${p_1, p_2, dots, p_m}$.

+ Inicjalizujemy stos $S$ poprzez umieszczenie na nim punktów $p_0$ oraz $p_1$. Indeks $i$ ustawiamy na wartość 2.

+ Iterujemy, póki $i < m$, badając położenie punktu $p_i$ względem linii prostej wyznaczonej przez dwa wierzchołki ze szczytu stosu. Sprawdzenie wykonujemy poprzez obliczenie wyznacznika macierzy 3×3 (funkcja `mat_det_3x3`). Gdy wyznacznik przekracza `eps`, punkt znajduje się po lewej stronie – wówczas umieszczamy $p_i$ na stosie i inkrementujemy $i$. W przeciwnym wypadku zdejmujemy element ze stosu i kontynuujemy weryfikację dla niezmienionego $p_i$.


Złożoność obliczeniowa algorytmu Grahama wynika z operacji wyszukiwania ekstremum, uporządkowania punktów, eliminacji współkątowych oraz konstrukcji otoczki stosując stos. Ponieważ każdy punkt podlega analizie maksymalnie jednokrotnie w fazie budowy stosu, kluczowym czynnikiem determinującym złożoność jest etap sortowania. Rezultatem jest złożoność rzędu $O(n log n)$, gdzie $n$ oznacza liczbę elementów zbioru wejściowego.

=== Algorytm Jarvisa
Mechanizm algorytmu Jarvisa polega na sekwencyjnym podejmowaniu optymalnych decyzji lokalnych poprzez wskazywanie punktu wyznaczającego najmniejszy kąt z bieżącą krawędzią, ignorując konsekwencje dla kolejnych kroków. Takie podejście prowadzi ostatecznie do uzyskania globalnie optymalnego wyniku w postaci prawidłowej otoczki wypukłej.

+ Wyznaczamy w zbiorze $Q$ punkt $p_0$ charakteryzujący się najmniejszą wartością współrzędnej $y$, a w przypadku równości – najmniejszą współrzędną $x$. Punkt ten włączamy do otoczki $H$ i traktujemy jako punkt bieżący.

+ Dla kolejnych elementów zbioru $Q$ poszukujemy punktu następnego, który zajmuje najbardziej lewostronną pozycję w stosunku do kierunku wyznaczonego przez punkt bieżący i obecnego kandydata. Weryfikację przeprowadzamy wykorzystując wyznacznik macierzy 3×3 (funkcja `mat_det_3x3`):
  - Gdy wyznacznik przyjmuje wartość ujemną (poniżej `-eps`), punkt kandydujący lokalizuje się bardziej na lewo niż punkt następny, więc aktualizujemy punkt następny na punkt kandydujący.
  - Gdy wyznacznik oscyluje wokół zera (w zakresie $[-"eps", "eps"]$), punkty leżą na jednej prostej. Wówczas preferencję otrzymuje punkt bardziej oddalony od punktu bieżącego, co ustalamy poprzez porównanie kwadratów odległości.

+ Po analizie wszystkich kandydatów, wybrany punkt następny staje się kolejnym elementem otoczki i zostaje dołączony do $H$. Punkt bieżący przyjmuje wartość punktu następnego.

+ Cykl kontynuujemy aż do osiągnięcia punktu $p_0$ (warunek: punkt bieżący jest identyczny z punktem startowym).


Algorytm Jarvisa charakteryzuje się złożonością $O(n h)$, gdzie $h$ oznacza liczbę wierzchołków otoczki, natomiast $n$ reprezentuje moc zbioru wejściowego. Dla każdego z $h$ elementów otoczki wykonujemy przegląd wszystkich $n$ punktów początkowych. W szczególnych konfiguracjach danych, jak punkty rozmieszczone wzdłuż obwodu prostokąta, wartość $h$ utrzymuje się na poziomie $O(1)$, co skutkuje liniową zależnością czasową algorytmu od liczebności zbioru wejściowego.

= Realizacja ćwiczenia


Punkt wyjścia stanowiła generacja czterech różnorodnych zbiorów punktów (reprezentowanych typem double) w przestrzeni euklidesowej $bb(R)^2$. Proces tworzenia danych oparto na funkcjach biblioteki _numpy_ (```py numpy.random.uniform()```).

#grid(
  columns: (1fr, 1fr),
  align(bottom + left)[
    #figure(
    image("Imgs/A.png", width: 80%),
    caption: [
      Zbiór A: 100 losowo\ wygenerowanych punktów o współrzędnych\ z przedziału $[-100, 100]$
    ],
  )
  ],
  align(bottom + right)[
    #figure(
    image("Imgs/B.png", width: 80%),
    caption: [
      Zbiór B: 100 losowo\ wygenerowanych punktów leżących na\ okręgu o środku $(0,0)$ i promieniu $R = 10$
    ],
  )
    ],
)

#grid(
  columns: (1fr, 1fr),
  align(top + left)[
    #figure(
    image("Imgs/C.png", width: 80%),
    caption: [
      Zbiór C: 100 losowo\ wygenerowanych punktów leżących na bokach prostokąta o wierzchołkach 
      $(-10, 10), (-10,-10), (10,-10), (10,10)$
    ],
  )
  ],
  align(top + right)[
    #figure(
    image("Imgs/D.png", width: 78%),
    caption: [
      Zbiór D: wierzchołki kwadratu\ (0, 0), (10, 0), (10, 10), (0, 10) oraz punkty
wygenerowane losowo: po 25 punktów na dwóch bokach
kwadratu leżących na osiach i po 20 punktów na przekątnych kwadratu
    ],
  )
    ],
)


Kolejnym krokiem było opracowanie implementacji algorytmów z wykorzystaniem autorskiej funkcji obliczającej wyznacznik macierzy $3 times 3$ (```py mat_det_3x3```), która pozwala określić orientację trójki punktów w płaszczyźnie.

W zastosowanej implementacji algorytmu Grahama proces rozpoczyna się od identyfikacji punktu bazowego o minimalnej współrzędnej $y$ (przy równości wybierany jest punkt o najmniejszej współrzędnej $x$). Następnie pozostałe punkty sortowane są według dwóch kryteriów: kąta obliczanego funkcją ```py arctan2()``` oraz odległości od punktu bazowego. Sortowanie realizowane jest poprzez utworzenie słownika ```py Q_angles```, który dla każdego punktu przechowuje parę (kąt, odległość kwadratowa). Punkty są najpierw sortowane według tej pary wartości przy użyciu funkcji ```py sorted()``` z odpowiednim kluczem. W kolejnym etapie przeprowadzana jest filtracja - iteracyjnie przeglądane są punkty i usuwane te, które mają identyczny kąt (z dokładnością do `eps`) jak poprzedni punkt, zachowując jedynie najbardziej odległy. Proces budowy otoczki wykorzystuje stos $S$ inicjalizowany dwoma pierwszymi punktami z posortowanej listy. Dla każdego kolejnego punktu sprawdzana jest jego pozycja względem linii tworzonej przez dwa ostatnie punkty na stosie - jeśli wyznacznik jest niedodatni (punkt nie leży na lewo), element ze stosu jest usuwany.

Realizacja algorytmu Jarvisa rozpoczyna się od wyznaczenia tego samego punktu startowego co w algorytmie Grahama. Algorytm utrzymuje listę $H$ punktów otoczki oraz zmienną `current` wskazującą aktualnie rozpatrywany punkt. W pętli głównej dla każdego kandydata ze zbioru wejściowego obliczany jest wyznacznik macierzy $3 times 3$ dla trójki: punkt aktualny, punkt następny (dotychczas najlepszy kandydat), punkt kandydujący. Gdy wyznacznik jest ujemny (mniejszy od `-eps`), oznacza to, że kandydat leży bardziej na lewo od aktualnie rozpatrywanego punktu następnego - w takiej sytuacji następuje aktualizacja. Dla przypadku współliniowości (wyznacznik w przedziale $[-"eps", "eps"]$) porównywane są kwadraty odległości od punktu aktualnego, wybierany jest punkt bardziej oddalony. Pętla kończy się po powrocie do punktu startowego.

Parametr tolerancji numerycznej został ustalony na $bold(epsilon = 10^(-24))$. Eksperymentalnie stwierdzono, że wartości większe powodowały niepoprawne traktowanie punktów współliniowych.

Przeprowadzono kompletną walidację obu algorytmów na wszystkich czterech zbiorach testowych, dokumentując graficznie zarówno proces iteracyjny, jak i końcowe rezultaty. Kolejnym etapem była modyfikacja zbiorów w celu systematycznych testów wydajnościowych. Zgromadzone dane empiryczne poddano analizie i wizualizacji wykresowej.


// --------------------------------------------------



= Analiza wyników

== Zbiory oryginalne

W prezentowanych wizualizacjach zastosowano następującą konwencję kolorystyczną:
- elementy zbioru wejściowego oznaczono #text(fill: red)[*kolorem czerwonym*],
- wierzchołki oraz krawędzie otoczki wypukłej zaznaczono #text(fill: black)[*kolorem czarnym*].

Kompletne sekwencje wierzchołków wyznaczonych otoczek wraz ze szczegółową dokumentacją iteracyjną obu algorytmów znajdują się w notebooku _Jupyter_ zawierającym również kod źródłowy implementacji.



#grid(
  columns: (1fr, 1fr),
  align(bottom + left)[
    #figure(
    image("Imgs/A_graham_Graph.png", width: 80%),
    caption: [Wizualizacja otoczki wypukłej dla zbioru A],
  )<otoczkaA>
  ],
  align(bottom + right)[
    #figure(
    image("Imgs/B_graham_Graph.png", width: 80%),
    caption: [Wizualizacja otoczki wypukłej dla zbioru B],
  )<otoczkaB>
    ],
)

#grid(
  columns: (1fr, 1fr),
  align(top + left)[
    #figure(
    image("Imgs/C_graham_Graph.png", width: 80%),
    caption: [Wizualizacja otoczki wypukłej dla zbioru C],
  )<otoczkaC>
  ],
  align(top + right)[
    #figure(
    image("Imgs/D_graham_Graph.png", width: 78%),
    caption: [Wizualizacja otoczki wypukłej dla zbioru D],
  )<otoczkaD>
    ],
)

#v(1em)
#align(center)[
  #figure(
    table(
      align: center + horizon,
      columns: (auto, auto, auto),
      rows: (auto, auto, auto, auto),
      [*Zbiór*], [*Algorytm \  Grahama*], [*Algorytm \ Jarvisa*],
      [A], [12], [12],
      [B], [100], [100],
      [C], [8], [8],
      [D], [4], [4],
  ),
  caption: [ Liczba punktów należąca do otoczki wypukłej dla oryginalnych zbiorów]
  )<wynikioryg>
]




Dane zawarte w #ref(<wynikioryg>, supplement: "Tabeli") wraz z pełnymi ciągami punktów dostępnymi w notebooku _Jupyter_ jednoznacznie potwierdzają zgodność wyników obu algorytmów. Identyczność zarówno liczności, jak i składu wierzchołkowego otoczek stanowi weryfikację poprawności implementacji dla wszystkich konfiguracji testowych.

Analiza zbioru A na podstawie #ref(<otoczkaA>, supplement: "Rysunku") potwierdza geometryczną poprawność otoczki – wszystkie punkty wejściowe znajdują się wewnątrz lub na brzegu wielokąta wypukłego. Rezultat dla zbioru B (#ref(<otoczkaB>, supplement: "Rysunku")) wykazuje włączenie absolutnie wszystkich punktów do otoczki, co stanowi konsekwencję ich rozmieszczenia na okręgu. Zbiory C (#ref(<otoczkaC>, supplement: "Rysunku")) oraz D (#ref(<otoczkaD>, supplement: "Rysunku")) stanowiły potencjalnie problematyczne przypadki testowe ze względu na obecność struktur współliniowych, jednak zastosowane implementacje poprawnie obsłużyły te scenariusze poprzez właściwą strategię eliminacji punktów wewnętrznych. Szczególnie interesujący jest przypadek zbioru C, którego otoczka liczy 8 wierzchołków (#ref(<wynikioryg>, supplement: "Tabeli")) — jest to wartość maksymalna dla losowej konfiguracji na prostokącie. Jak uwidacznia #ref(<otoczkaC>, supplement: "Rysunku"), generacja nie wytworzyła żadnego punktu pokrywającego się z wierzchołkami prostokąta (prawdopodobieństwo takiego zdarzenia jest minimalne), co implikuje konieczność włączenia do otoczki dwóch punktów ekstremalnych z każdego boku. Zbiór D prezentuje odmienny scenariusz — jak demonstruje #ref(<otoczkaD>, supplement: "Rysunku"), obecność czterech wierzchołków kwadratu determinuje kształt otoczki wypukłej, która redukuje się do samej figury bazowej.



== Zbiory zmodyfikowane
=== Modyfikacja zbiorów testowych

Dla potrzeb eksperymentu opracowano rozszerzone wersje bazowych zbiorów punktów o różnej liczebności.

Podczas pomiarów nie generowano dodatkowych plików z punktami otoczek, aby uniknąć wpływu operacji dyskowych na czas wykonania. Weryfikacja wyników obejmowała również porównanie liczby punktów w otoczce pomiędzy algorytmami, co pozwalało potwierdzić poprawność implementacji.

#pagebreak()
=== Wyniki testów dla zmodyfikowanego zbioru A

#align(center)[
  #figure(
    table(
      align: center + horizon,
      inset: (x: 5pt, y: 5pt),
      columns: 5,
      [*Wszystkie \ punkty*], [*Otoczka \ Graham*], [*Algorytm \ Grahama*], [*Otoczka \ Jarvis*], [*Algorytm \ Jarvisa*],
      ..csv("Reports/A.csv").flatten(),
  ),
  caption: [Wyniki pomiaru czasu wykonania dla zmodyfikowanego zbioru A przy różnych licznościach]
  )<speedtestA>
]

#align(center)[
  #figure(
    image("Imgs/TimeA.png", width: 65%),
    caption: [Porównanie graficzne czasu wyznaczania otoczki wypukłej przez algorytmy dla zmodyfikowanego zbioru A]
  )<wykrestestA>
]



Dane przedstawione w #ref(<speedtestA>, supplement: "Tabeli") i #ref(<wykrestestA>, supplement: "Rysunku") wskazują, że dla losowego rozkładu punktów algorytm Grahama utrzymuje stabilny i stosunkowo niski czas działania. Dla niewielkich zbiorów różnice są minimalne, jednak wraz ze wzrostem liczności Jarvis staje się wyraźnie wolniejszy. Przy liczbie punktów powyżej 60 000 obserwuje się wzrost tempa przyrostu czasu obliczeń dla obu metod, co można przypisać rosnącemu wpływowi pamięci podręcznej i zarządzania strukturami danych.



=== Wyniki testów dla zmodyfikowanego zbioru B

#align(center)[
  #figure(
    table(
      align: center + horizon,
      inset: (x: 5pt, y: 5pt),
      columns: 5,
      [*Wszystkie \  punkty*], [*Otoczka \ Graham*], [*Algorytm \ Grahama*], [*Otoczka \ Jarvis*], [*Algorytm \ Jarvisa*],
      ..csv("Reports/B.csv").flatten(),
  ),
  caption: [Wyniki pomiaru czasu wykonania dla zmodyfikowanego zbioru B przy różnych licznościach]
  )<speedtestB>
]

#align(center)[
  #figure(
    image("Imgs/TimeB.png", width: 65%),
    caption: [Porównanie graficzne czasu wyznaczania otoczki wypukłej przez algorytmy dla zmodyfikowanego zbioru B]
  )<wykrestestB>
]

#v(2em)

W przypadku zbioru B, którego punkty leżą na obwodzie figury, liczba wierzchołków otoczki jest równa liczbie wszystkich punktów. Oznacza to, że dla algorytmu Jarvisa złożoność czasowa praktycznie osiąga poziom kwadratowy. Na #ref(<wykrestestB>, supplement: "Rysunku") zauważalny jest gwałtowny wzrost czasu wykonania — już przy 10 000 punktach przekracza on kilkadziesiąt sekund, a dla 40 000 punktów osiąga wartości rzędu kilku tysięcy. W tym kontekście algorytm Grahama zachowuje przewidywalną, niską złożoność, co czyni go znacznie bardziej efektywnym.

#pagebreak()

=== Wyniki testów dla zmodyfikowanego zbioru C

#align(center)[
  #figure(
    table(
      align: center + horizon,
      inset: (x: 5pt, y: 5pt),
      columns: 5,
      [*Wszystkie \ punkty*], [*Otoczka \ Graham*], [*Algorytm  \ Grahama*], [*Otoczka  \ Jarvis*], [*Algorytm  \ Jarvisa*],
      ..csv("Reports/C.csv").flatten(),
  ),
  caption: [Wyniki pomiaru czasu wykonania dla zmodyfikowanego zbioru C przy różnych licznościach]
  )<speedtestC>
]

#align(center)[
  #figure(
    image("Imgs/TimeC.png", width: 65%),
    caption: [Porównanie graficzne czasu wyznaczania otoczki wypukłej przez algorytmy dla zmodyfikowanego zbioru C]
  )<wykrestestC>
]

#v(2em)

Analiza #ref(<speedtestC>, supplement: "Tabeli") ujawnia, że oba algorytmy zachowują bardzo podobny charakter wzrostu czasu. Liczba wierzchołków otoczki pozostaje stała, co ogranicza różnice w zachowaniu między metodami. Dla większych wartości $n$ obie implementacje wykazują niemal liniowy wzrost czasu obliczeń. Można więc stwierdzić, że w przypadku zbiorów o silnej regularności przestrzennej efektywność Grahama i Jarvisa jest porównywalna.

#pagebreak()

=== Wyniki testów dla zmodyfikowanego zbioru D

#align(center)[
  #figure(
    table(
      align: center + horizon,
      inset: (x: 5pt, y: 5pt),
      columns: 6,
      [*Punkty \  (krawędzie)*], [*Punkty  \ (przekątne)*], [*Otoczka  \ Graham*], [*Algorytm \  Grahama*], [*Otoczka  \ Jarvis*], [*Algorytm  \ Jarvisa*],
      ..csv("Reports/D.csv").flatten(),
  ),
  caption: [Wyniki pomiaru czasu wykonania dla zmodyfikowanego zbioru D przy różnych licznościach]
  )<speedtestD>
]

#align(center)[
  #figure(
    image("Imgs/TimeD.png", width: 67%),
    caption: [Porównanie graficzne czasu wyznaczania otoczki wypukłej przez algorytmy dla zmodyfikowanego zbioru D]
  )<wykrestestD>
]

#v(2em)

Zbiór D składa się z punktów rozmieszczonych w sposób regularny – na krawędziach i przekątnych kwadratu. Jak wynika z #ref(<speedtestD>, supplement: "Tabeli"), liczba punktów otoczki pozostaje stała ($k = 4$), natomiast czas obliczeń obu algorytmów rośnie proporcjonalnie do liczby punktów wejściowych.  
W przeciwieństwie do pozostałych zestawów danych, w tym przypadku *algorytm Jarvisa* osiąga nieco lepsze wyniki czasowe. Różnica jest szczególnie widoczna dla większych zbiorów – przy 100 000 punktach Graham potrzebuje około 3.4 s, podczas gdy Jarvis ok. 1.8 s.  
Na #ref(<wykrestestD>, supplement: "Rysunku") widoczny jest zbliżony rozkład punktów, co sugeruje podobną złożoność obliczeniową, jednak implementacja Jarvisa okazuje się wydajniejsza w kontekście tego typu uporządkowanych danych.


= Wnioski

Podsumowując przeprowadzone doświadczenia oraz analizę wyników, można stwierdzić, że oba badane algorytmy – Grahama i Jarvisa – prawidłowo realizują zadanie wyznaczania otoczki wypukłej, niezależnie od struktury danych wejściowych. Ich zgodność wyników dla wszystkich testowych zbiorów stanowi potwierdzenie poprawności implementacji oraz stabilności działania.

W kontekście wydajności można zauważyć wyraźne różnice między metodami.  
Algorytm Grahama, którego kluczowym etapem jest sortowanie punktów według kąta, zachowuje wysoką efektywność w przypadku danych o losowym rozkładzie. Jego złożoność obliczeniowa rzędu $O(n log n)$ sprawia, że nawet przy dużej liczbie punktów czas przetwarzania rośnie w sposób umiarkowany. W praktyce oznacza to, że jest to metoda preferowana w sytuacjach, gdy nie znamy struktury geometrycznej danych lub gdy liczba punktów jest znaczna.

Z kolei algorytm Jarvisa, oparty na stopniowym „owijaniu” zbioru, okazał się bardziej korzystny przy danych o uporządkowanej lub powtarzalnej strukturze. Dla przypadków, w których liczba punktów należących do otoczki jest niewielka (np. w zbiorach C i D), jego czas działania jest niemal liniowy względem rozmiaru wejścia, co stanowi dużą zaletę w kontekście takich danych. Warto jednak zauważyć, że w sytuacji, gdy większość punktów tworzy otoczkę (jak w zbiorze B), jego efektywność gwałtownie spada – złożoność wzrasta do $O(n^2)$, co przekłada się na bardzo długi czas wykonania.

Przeprowadzone testy wskazują, że:
- algorytm Grahama lepiej sprawdza się w warunkach losowych i dla dużych zbiorów punktów,
- algorytm Jarvisa zyskuje przewagę w przypadkach, gdy liczba punktów otoczki $k$ jest ograniczona lub dane mają regularny układ geometryczny.

Dodatkowo zauważono, że wzrost liczby punktów wejściowych wpływa na obie metody w sposób zbliżony — czasy obliczeń rosną proporcjonalnie do rozmiaru danych, przy czym różnice w tempie wzrostu zależą od konkretnej konfiguracji przestrzennej punktów. Efektywność algorytmów była również częściowo zależna od czynników implementacyjnych, takich jak zarządzanie pamięcią czy dokładność obliczeń zmiennoprzecinkowych.

Ostatecznie można stwierdzić, że wybór algorytmu powinien być uzależniony od natury problemu:
- dla zbiorów o dużej losowości lub nieznanym układzie – optymalny będzie *algorytm Grahama*,  
- dla zbiorów o silnej regularności lub niewielkiej liczbie punktów brzegowych – bardziej efektywny okaże się *algorytm Jarvisa*.  

Wnioskiem końcowym jest więc to, że oba podejścia stanowią wartościowe narzędzia analizy geometrycznej, a ich praktyczne zastosowanie powinno być dobierane kontekstowo – w zależności od charakteru danych, wymagań czasowych oraz oczekiwanej precyzji obliczeń.

