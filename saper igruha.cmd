@echo off
REM Author: Makhambetkhan Medet
REM Git hub: https://github.com/medetmyrza
REM E-Mail: makhambetkhanmedet@gmail.com
REM Instagram: https://www.instagram.com/aqadiluly.medet/reels/


REM BETA-TEST!!!
REM Update №3
goto :init

:init
REM А мы такие замкнутые... cmd.exe -> setlocal /?
setlocal>nul
REM Меняем цвет. Честно, это не нужно, но оставил для приличия.
color 07 >nul
REM Устанавливаем заголовок
title Minesweeper by Makhambetkhan Medet
REM Очищаем экран. Да, в конце игры вам будет предложено сыграть заново. Ну не оставлять же это безобразие?
cls
REM Создаем поле. Максимальное кол-во бомб (maxbombs) - 20. Устанавливаем кол-во бомб в 0, кол-во проставленных флагов в 0.
call :logo
echo Generation field. Please, wait...
set maxbombs=17
set bombs=0
set flags=0
REM Не собираемся ни выходить, ни умирать не выиграывать в начале игры. Хотя, мы даже игру не стартанули
set die=0
set win=0
set quit=0
set started=0
set step=0
REM Собсно сам процес создания полей. mfield - поле, выводимое на экран; rfield - реальное поле
for /L %%x in (1,1,9) do for /L %%y in (1,1,9) do set mfield%%x%%y=?
for /L %%x in (1,1,9) do for /L %%y in (1,1,9) do set rfield%%x%%y=?
call :genbomb
call :genrfield
REM Переходим к игре.
goto :gamecycle
REM goto:eof - это что-то типа return или end в функции/процедуре.
goto:eof

:gamecycle
REM Так как это... батник глючит из-за особенностей cmd.exe и нежелания читать разработчиков (как и MS, так и меня) доку, то делаем финт ушами:
REM Если переменная quit не равна 0, то выходим из игры.
if not "%quit%"=="0" (
	endlocal>nul
	goto:eof
	)
REM Очистка экрана.
cls
REM Вывод поля и дополнительной информации.
set line0=:yx  1  2  3  4  5  6  7  8  9  yx:
for /L %%y in (1,1,9) do call set line%%y=:%%y:  %%mfield%%y1%%  %%mfield%%y2%%  %%mfield%%y3%%  %%mfield%%y4%%  %%mfield%%y5%%  %%mfield%%y6%%  %%mfield%%y7%%  %%mfield%%y8%%  %%mfield%%y9%%  :%%y:
REM Изменяем внешний вид: все нули меняем на ноль, а все воспросительные знаки (?) на точки (.).
for /L %%y in (1,1,9) do call set line%%y=%%line%%y:0= %%
for /L %%y in (1,1,9) do call set line%%y=%%line%%y:?=.%%
if %flags% GTR %maxbombs% (
	set line1=%line1%  !!! F
	) else (
	set line1=%line1%      F
	)
REM Печатаем кол-во флагов.
set line1=%line1%lags: %flags%
set line3=%line3%      Step: %step%
REM Выписываем справку
if not "%die%"=="1" if not "%win%"=="1" (
	set line4=%line4%      Avaibled commands:
	set line5=%line5%      h      - Output this help.
	set line6=%line6%      o [yx] - Open point yx
	set line7=%line7%      f [yx] - Create flag on point yx
	set line8=%line8%      n      - Start new game
	set line9=%line9%      q      - Exit to Windows or console
	)
REM Считаем время. Странно, но если вызывать :checkstart отсюда, а не как правильно, то все работает правильно. Очень странно.
call :checkstart
if not "%started%"=="0" (
	call :endtime
	set line2=%line2%      Time: %gametime%
	) else (
	set line2=%line2%  !!! Game not started yet.
	)
if "%die%"=="1" set line4=%line4%      BOMB!!! U died.
if "%win%"=="1" set line4=%line4%      WIN!!! WIN!!! WIN!!! WIN!!! WIN!!!
echo %line0%      Bombs: %bombs%
echo :---------------------------------:
for /L %%y in (1,1,8) do call :echofield line%%y
echo %line9%
echo :---------------------------------:
echo %line0%
echo.
REM Проверяем, выиграл ли пользователь.
if not "%die%"=="1" if not "%win%"=="1" call :wincheck
REM Некоторые идиотские проверочки: если мы умерли или выиграли, то выводим запрос на создание новой игры.
if "%die%"=="1" (
	goto:bombdie
	) else if "%win%"=="1" (
		goto:dowin 
		) else (
			REM Считываем и обрабатываем данные с клавиатуры.
			goto inputcycle
		)
goto:eof

:inputcycle
REM См. первый комент в :gamecycle.
if not "%quit%"=="0" (
	endlocal>nul
	goto:eof
	)
REM Заносим в input магическую строку. Так как переменная input может и не создатся (пользователь нажал Enter), то вводим в неё изначально такой бред. 
REM Так легче, чем использовать IF DEFINED, который, кстати, не всегда работает.
set input=0 00
set /p "input=Input: "
set input=%input: =%
REM Первая буква - необходимое действие.
set action=%input:~0,1%
REM Уходим отсюда.
if "%action%"=="q" (
	set quit=1
	echo Good Bye.
	goto:eof
	)
REM Выводим справку.
if "%action%"=="h" (
	cls
	call :help
	goto:gamecycle
	)
REM Выводим список выигранных игр.
if "%action%"=="r" if EXIST records.log (
	cls
	type records.log
	pause>nul
	goto:gamecycle
	) else (
	call:errorIO2
	)
if "%action%"=="n" (
	endlocal>nul
	goto init
	)
REM См. первый комент в :gamecycle.
if not "%quit%"=="0" (
	endlocal>nul
	goto:eof
	)
REM Издеваемся над координатами.
REM Честно, мне лень переписывать.
set ix=0
set iy=0
for /L %%a in (1,1,9) do if "%%a"=="%input:~0,1%" set ix=%%a
if %ix%==0 (
	for /L %%a in (1,1,9) do if "%%a"=="%input:~1,1%" set ix=%%a
	for /L %%a in (1,1,9) do if "%%a"=="%input:~2,1%" set iy=%%a
	) else (
	for /L %%a in (1,1,9) do if "%%a"=="%input:~1,1%" set iy=%%a
	REM Координаты можно ввести без "o" в начале
	set action=o
	)
REM Выводим сообщение, что пользователь - дурак.
if not "%action%"=="q" if not "%action%"=="h" if not "%action%"=="o" if not "%action%"=="f" if not "%action%"=="n" if not "%action%"=="r" call:errorIO2
REM Выводим еще одно сообщение, что пользователь - дурак.
if "%ix%"=="0" (
	call :errorIO1
	goto:gamecycle
	)
if "%iy%"=="0" (
	call :errorIO1
	goto:gamecycle
	)
REM Открываем точки, ставим флаги.
call :checkstart
if "%action%"=="o" (
		call :openpoint %ix% %iy% %%rfield%ix%%iy%%% %%mfield%ix%%iy%%%
		goto:gamecycle
	)
if "%action%"=="f" (
		call :flagpoint %ix% %iy% %%mfield%ix%%iy%%%
		goto:gamecycle
	)
goto:eof

REM Вспомогательные процедуры.
REM Выводим наш опознавательный знак.
:logo
echo                                  ~
echo                                  :77~ ~=~I~
echo                          ~       :? I~?:=7=      ~?~
echo                           I7=~ ~I~+7+?:~?7++?=~=?7=
echo                           :=7 7II77III??,+==~~~=I=~
echo                           ~:=I?~7?+7II??++~=?+~:~~
echo                            I777:=I7I??I??++??=~:::~
echo                           I777 :~+I7III??++?+~~~::~=
echo                      ~?IIII?777   777II??++=~~~~::=777II=
echo                       ~~=?I?77777777II???+?==~~:::~7I+~~
echo                         ~,+?IIII7IIII???++??+~~:::~~:
echo                         ~???~??IIII???++~::,~::::~=++~
echo                       ~~~+~I   ??:~+??++=~,:::::~~=?+++~
echo                      ~:,,I===~~++,=?+====~~~:::~+=+I::::~
echo                           =+=======:::=~~~~:::I  +??
echo                            ==~=======~~~~::::~:~+ ?
echo                             ~=====~~~~~::::~~=,~?=:~
echo                            :+?==~~~~:+  +~~==+I+~==~         MINESWEEPER
echo                            =+~:~~==~,~ 7~=+?I?  ~,~=            BY MAKHAMBETKHAN MEDET
echo                           =:      ~:=: ++?~~:       ~
echo                                    ,  7  , ~~
echo                                    ~      ~~
echo.
goto:eof

REM Пользователь дурак.
:errorIO1
cls
echo Error I/O: Unknown coordinates
call:help
goto:gamecycle
REM Пользователь дважды дурак.
:errorIO2
cls
echo Error I/O: Unknown command
call:help
goto:gamecycle
REM Выписываем пользователю справку.
:help
echo Avaibled commands:
echo   h      - Output this help.
echo   o [yx] - Open point yx
echo   f [yx] - Create flag on point yx
echo   n      - Start new game
IF EXIST records.log echo   r      - Output all records
echo   q      - Exit to Windows or console
echo.
echo Example: o 12     - open point with coordinates y=1, x=2
echo          f 34     - create flag on point y=3, x=4
echo          n        - start new game
echo          new game - start new game
echo.
pause>nul
goto:eof

REM Генерируем бомбы.
:genbomb
set nx=%1
set ny=%2
set r1=%random:~-2%
set r2=%random:~-2%
set r1=%r1:0= %
set r2=%r2:0= %
set r1=%r1: =%
set r2=%r2: =%
set r1=%r1:~0,1%
set r2=%r2:~0,1%
if "%r1%"==0 goto :genbomb %nx% %ny%
if "%r2%"==0 goto :genbomb %nx% %ny%
if "%r1%"=="%nx%" goto :genbomb %nx% %ny%
if "%r2%"=="%ny%" goto :genbomb %nx% %ny%
REM Фокус с call - это преобразование имени переменной в её значение. В принципе, можно сделать "call echo %%rfield%%x%%y%%" и будет выведено содержание текущей клетки.
REM Но вот if там нельзя использовать, поэтому мы делаем вызов процедуры с передачей значения переменной и её имени.
call :newbomb %%rfield%r1%%r2%%% rfield%r1%%r2%
REM Делаем бомбы пока их количество не будет равно максимальному.
if "%bombs%" == "%maxbombs%" goto:eof
goto genbomb

REM Создаем бомбы, если её нету. Вызывается из :genbomb.
:newbomb
if not "%1"=="X" (
	set %2=X
	set /a bombs=%bombs%+1
	)
goto:eof

REM В сапере обычно используются числа для обозначения кол-ва стоящих рядом бомб. Перебираем все клетки и вносим туда необходимые числа. Опять же, используем фокус с call
:genrfield
for /L %%x in (1,1,9) do for /L %%y in (1,1,9) do call :dosumfield %%x %%y %%rfield%%x%%y%% rfield%%x%%y
goto:eof

REM А эта процедура записывает необходимые числа в необходимые клеточки.
:dosumfield
REM %1, %2 - координаты (x, y), %3 - содержание клеточки, %4 - имя переменной.
REM Если клеточка заполнена, то выходим из процедуры.
if not "%3"=="?" goto:eof
REM Устанавливаем координаты ближайших клеточек.
set /a x1=%1 - 1 
set /a y1=%2 + 1

set /a x2=%1 
set /a y2=%2 + 1 

set /a x3=%1 + 1 
set /a y3=%2 + 1

set /a x4=%1 - 1 
set /a y4=%2 

set /a x5=%1 + 1 
set /a y5=%2

set /a x6=%1 - 1 
set /a y6=%2 - 1

set /a x7=%1 
set /a y7=%2 - 1 

set /a x8=%1 + 1 
set /a y8=%2 - 1

REM sum - количество бомб рядом, обнуляем.
set sum=0
REM Проверяем координаты: GTR больше, LSS меньше. "Массив" у нас задан координатами [1..9,1..9], а в результате предыдущих действий координаты выходили за пределы массива.
if %1 GTR 1 if %2 LSS 9 call :newsum %%rfield%x1%%y1%%%
			if %2 LSS 9 call :newsum %%rfield%x2%%y2%%% 
if %1 LSS 9 if %2 LSS 9 call :newsum %%rfield%x3%%y3%%%
if %1 GTR 1 			call :newsum %%rfield%x4%%y4%%%
if %1 LSS 9 			call :newsum %%rfield%x5%%y5%%%
if %1 GTR 1 if %2 GTR 1 call :newsum %%rfield%x6%%y6%%%
			if %2 GTR 1 call :newsum %%rfield%x7%%y7%%%
if %1 LSS 9 if %2 GTR 1 call :newsum %%rfield%x8%%y8%%%
set %4=%sum%
goto:eof

REM Так как call не воспринимает if, то используем отдельную процедуру.
:newsum
if "%1"=="X" set /a sum+=1
goto:eof

REM Удаляем числа
:delrfield
for /L %%x in (1,1,9) do for /L %%y in (1,1,9) do call :delsumfield %%x %%y %%rfield%%x%%y%% rfield%%x%%y
goto:eof

:delsumfield
if "%3"=="?" goto:eof
if "%3"=="X" goto:eof
set %4=?
goto:eof


REM Эта процедура относится к выводу поля. Я не знаю как еще в for-цикле использовать две и более команды, кроме как использовать отдельную процедуру. 
:echofield
REM Выводим поле. И пустую строчку.
call echo %%%1%%
echo :-:                             :-:
goto:eof

REM Открываем клеточку
:openpoint
rem %1, %2 - x, y; %3 - значение клетки реального поля; %4 - значение клетки видимого поля.
set /a step+=1
REM Если клетка не пуста - рассказываем пользователю много интересного, если в клетке бомба - уже поздно что-либо рассказывать.
if not "%4"=="?" (
	echo Point x=%1 y=%2 already opened
	pause>nul
	goto:eof
	)
if "%3"=="X" if not "%step%"=="1" (
	set die=1
	for /L %%x in (1,1,9) do for /L %%y in (1,1,9) do call set mfield%%x%%y=%%rfield%%x%%y%%
	goto:eof
	)
if "%step%"=="1" if "%3"=="X" (
	set rfield%1%2=?
	set /a bombs-=1
	call :delrfield
	call :genbomb %1 %2
	call :genrfield
	rem call set mfield%1%2=%%rfield%1%2%%
	call :oaf %1 %2 %%rfield%1%2%% %%mfield%1%2%%
	)
REM А если ни то, ни другое, то пытаемся открыть эту и ближние клетки.
call :oaf %1 %2 %3 %4
goto:eof 

:oaf
rem %1, %2 - x, y; %3 - значение клетки реального поля; %4 - значение клетки видимого поля.
REM Если клетка пуста (выход за пределы поля) или в ней бомба - уходим отсюда.
if "%3"=="" goto:eof
if "%3"=="X" goto:eof

REM Открываем данную клетку
call set mfield%1%2=%%rfield%1%2%%

REM Если в данной клетке 0 бомб, то пытаемся открыть все ближние клетки.
if not "%3" == "0" goto:eof

REM xn, yn - координаты следующей клетки. Диагональ не проверяется.
set /a xn=%1
set /a yn=%2 + 1
REM Проверка, открыта ли эта клетка на видимом поле.
set dooaf=0
call :checkoaf %%mfield%xn%%yn%%%
REM Если нет - пытаемся открыть.
if %dooaf%==1 call :oaf %xn% %yn% %%rfield%xn%%yn%%% %%mfield%xn%%yn%%%

set /a xn=%1
set /a yn=%2 - 1
set dooaf=0
call :checkoaf %%mfield%xn%%yn%%%
if %dooaf%==1 call :oaf %xn% %yn% %%rfield%xn%%yn%%% %%mfield%xn%%yn%%%


set /a xn=%1 - 1
set /a yn=%2
set dooaf=0
call :checkoaf %%mfield%xn%%yn%%%
if %dooaf%==1 call :oaf %xn% %yn% %%rfield%xn%%yn%%% %%mfield%xn%%yn%%%

set /a xn=%1 + 1
set /a yn=%2
set dooaf=0
call :checkoaf %%mfield%xn%%yn%%%
if %dooaf%==1 call :oaf %xn% %yn%	%%rfield%xn%%yn%%% %%mfield%xn%%yn%%%

REM Диагональ.
set /a xn=%1 + 1
set /a yn=%2 + 1
set dooaf=0
call :checkoaf %%mfield%xn%%yn%%% %%rfield%xn%%yn%%%
if %dooaf%==1 call :oaf %xn% %yn%	%%rfield%xn%%yn%%% %%mfield%xn%%yn%%%

set /a xn=%1 + 1
set /a yn=%2 - 1
set dooaf=0
call :checkoaf %%mfield%xn%%yn%%% %%rfield%xn%%yn%%%
if %dooaf%==1 call :oaf %xn% %yn%	%%rfield%xn%%yn%%% %%mfield%xn%%yn%%%

set /a xn=%1 - 1
set /a yn=%2 + 1
set dooaf=0
call :checkoaf %%mfield%xn%%yn%%% %%rfield%xn%%yn%%%
if %dooaf%==1 call :oaf %xn% %yn%	%%rfield%xn%%yn%%% %%mfield%xn%%yn%%%

set /a xn=%1 - 1
set /a yn=%2 - 1
set dooaf=0
call :checkoaf %%mfield%xn%%yn%%% %%rfield%xn%%yn%%%
if %dooaf%==1 call :oaf %xn% %yn%	%%rfield%xn%%yn%%% %%mfield%xn%%yn%%%

goto:eof

REM Проверка, открыта ли клетка на видимом поле.
:checkoaf
if "%1"=="?" set dooaf=1
goto:eof

REM Устанавливаем флаг
:flagpoint
REM %1, %2 - x, y; %3 - значение клетки видимого поля
REM Если в клетке уже что-то есть - рассказываем пользователю что-то интересное
if not "%3"=="?" if not "%3"=="!" (
	echo Point %2 %1 already opened
	pause>nul
	goto:eof
	)
REM Если нету флага - ставим, если есть флаг - убираем. Так же изменяем счетчик.
if not "%3"=="!" (
	set /a flags+=1
	call set mfield%%1%%2=^!
	) else (
	set /a flags-=1
	call set mfield%%1%%2=?
	)
goto:eof 

REM Бабах... Мы все умрем... А вот пользователь уже подорвался на какой-то бомбе. Неудачливый из него сапер.
:bombdie
REM :bombdie требует вывода поля (заново), поэтому используется дополнительная переменная для обозначения первого запуска :bombdie и одновременно смерти игры.
if not "%die%"=="1" (
	set die=1
	goto :gamecycle
	)
REM Считываем, хочет ли пользователь еще раз сыграть игру.
pause>nul
echo Want to start new game? Example: yes
set sgame=yes
set /p sgame=
set sgame=%sgame:~0,1%
if "%sgame%"=="y" (
	endlocal>nul
	goto :init
	)
if "%sgame%"=="Y" (
	endlocal>nul
	goto :init
	)
set quit=1
goto:eof

REM Проверяем, выиграл ли пользователь.
:wincheck
REM Если флагов больше кол-ва бомб, то пользователь ошибся!
if %flags% GTR %maxbombs% goto:eof
REM Если пользователь решил схитрить... то выходим.
if %step%==0 goto:eof
REM Считаем кол-во правильно поставленных флагов и не открытых клеточек.
set nopoints=0
set rflags=0
for /L %%x in (1,1,9) do for /L %%y in (1,1,9) do call :checkfo %%mfield%%x%%y%% %%rfield%%x%%y%%
REM Если количество правильно поставленных флагов равно кол-ву бомб, то юзер выиграл
if %rflags%==%maxbombs% call :dowin
REM Еще один вариант победы человека над машиной: если все флаги проставлены правильно, но стоят не везде; сумма поставленных флагов и неоткрытых клеточек равна кол-ву бомб.
set /a sumpoints=%nopoints% + %rflags%
if %rflags%==%flags% if %sumpoints%==%maxbombs% call :dowin
goto:eof

REM Изменяем счетчики.
:checkfo
if "%1"=="?" set /a nopoints+=1
if "%1"=="!" if "%2"=="X" set /a rflags+=1
goto:eof

REM Мы выиграли!
:dowin
if not "%win%"=="1" (
	set win=1
	for /L %%x in (1,1,9) do for /L %%y in (1,1,9) do call set mfield%%x%%y=%%rfield%%x%%y%%
	goto :gamecycle
	)
pause>nul
set name=%USERNAME%
set /p name="Your name: "
set name=%name%:%USERNAME%@%USERDOMAIN%
set name=%name:|=%
IF not EXIST records.log echo ----- Minesweeper' records ----- >records.log
echo Name: %name% ^| Steps: %step% ^| GameTime: %gametime% ^| Flags: %rflags% ^| Not opened: %nopoints% ^| Date-Time: %date% %time% >>records.log 2>nul 
echo Want to start new game? Example: yes
set sgame=yes
set /p sgame=
set sgame=%sgame:~0,1%
if "%sgame%"=="y" (
	endlocal>nul
	goto :init
	)
if "%sgame%"=="Y" (
	endlocal>nul
	goto :init
	)
set quit=1
goto:eof

REM Первая процедура для подсчета времени
:checkstart
if not "%started%"=="0" goto:eof
set stime=%time%
set sdate=%date:~0,2%
set started=1
call :endtime
goto:eof

REM Вторая (она же основная) процедура для подсчета времени
:endtime
REM Издеваемся над временем.
set rtime=%time%
set stime=%stime::= %
set stime= %stime:,= %
set stime=%stime: 0= %
set rdate=%date:~0,2%
set rtime=%rtime::= %
set rtime= %rtime:,= %
set rtime=%rtime: 0= %
REM В %stime% и %rtime% прописано четыре числа (разделители - пробелы): часы, минуты, секунды, миллисекунды
set counter=4
for /L %%a in (1,1,%counter%) do set s%counter%=
for /L %%a in (1,1,%counter%) do set r%counter%=
REM Начинаем обрабатывать строки stime и rtime с конца.
:looptime
for /F "tokens=%counter%" %%a in ("%stime%") do set s%counter%=%%a
for /F "tokens=%counter%" %%a in ("%rtime%") do set r%counter%=%%a
set /a counter-=1
If %counter% GTR 0 goto looptime
REM Выражаем время одним числом
set /a s=%s4% + %s3%*100 + %s2%*6000 + %s1%*360000
set /a r=%r4% + %r3%*100 + %r2%*6000 + %r1%*360000
REM Учитываем разницу в днях.
if %rdate% GTR %sdate% set /a r+=8640000*(%rdate%-%sdate%)
REM Считаем разницу во времени.
set /a d=%r% - %s%
set /a d1=%d% / 360000
set /a td2=%d% %% 360000
set /a d2=%td2% / 6000
set /a td3=%td2% %% 6000
set /a d3=%td3% / 100
set /a td4=%td3% %% 100
set /a d4=%td4%
if %d1% LSS 10 set d1=0%d1%
if %d2% LSS 10 set d2=0%d2%
if %d3% LSS 10 set d3=0%d3%
if %d4% LSS 10 set d4=0%d4%
REM Устанавливаем прошедшее время.
set gametime=%d1%:%d2%:%d3%.%d4%
endlocal >nul