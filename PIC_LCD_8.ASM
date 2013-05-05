;===============================================================================================
;
; PROG : Пример отображения данных для знакосинтезирующего ЖКИ по 8 битной шине
; OWNER: burnout84@rambler.ru
; PROC : PIC16F84A
; FREQ : 4 MHZ
; DATE : 24.02.2010
;
; WEB  : https://github.com/burnout84
;
;
; Если RS = 0, то адресуется регистр команд (IR)
;      RS = 1, регистр данных (DR)
;
;
;===============================================================================================
LIST P=16F84A               ;
__CONFIG    03FF1H          ; Бит защиты выключен, WDT выключен, стандартный XT - генератор


TMR0                equ 01h ; Регистр TMR0. 
OPTIONR             equ 01h ; Регистр Option - банк 1. 
INTCON              equ 0Bh ; Регистр IntCon. 
INDF                equ 0   ;
PORTA               equ 5   ;
PORTB               equ 6   ;
TRISA               equ 85h ;
TRISB               equ 86h ;
OPTREG              equ 81h ;
STATUS              equ 3   ;
CARRY               equ 0   ;
GIE                 equ 7   ;
MSB                 equ 3   ; 
FSR                 equ 4h  ;
W                   equ 0   ; Результат направить в аккумулятор
F                   equ 1   ; Результат направить в регистр
RP0                 equ 5   ; Бит выбора банка
Z                   equ 2   ; Флаг нулевого результата
С                   equ 0   ; Флаг переноса-заема

RS                  equ 0   ;
RW                  equ 1   ;
E                   equ 2   ;
TEMP_LCD            equ 10h ;
COUNT0              equ 11h ;
COUNT1              equ 12h ;

;===============================================================================================
;                              НАЧАЛО ПРОГРАММЫ
;===============================================================================================
ORG  0                      ; 
GOTO START                  ; 
START                       ; Точка старта программы

CLRF  PORTA                 ; Очищаем порты
CLRF  PORTB                 ;
BSF STATUS,RP0              ; Переход в 1-й банк. 
MOVLW 0x00                  ; Все выводы порта А работают на выход
MOVWF TRISA                 ;
MOVLW 0x00                  ; Все выводы PORTB - выход
MOVWF TRISB                 ;
BCF STATUS,RP0              ; Установка банка 0

CALL INIT_LCD               ;
CALL PRINT_TEXT             ;

LOOP GOTO LOOP              ;

;===============================================================================================
;                              ИНИЦИАЛИЗАЦИЯ LCD
;===============================================================================================
INIT_LCD                    ;
CALL DEL_15MS	            ;
BCF PORTA,RS                ; RS=0
BCF PORTA,RW                ; RW=0
BCF PORTA,E                 ; E=0
MOVLW h'30'                 ; Настройка
MOVWF PORTB                 ;
BSF	PORTA,E                 ; контроллера
BCF	PORTA,E                 ; LCD модуля
CALL DEL_4MS		        ;
BSF	PORTA,E	                ;
BCF	PORTA,E	                ;
CALL DEL_100MKS             ;
BSF	PORTA,E	                ;
BCF	PORTA,E        	        ;
CALL BUSY		            ; ЖДЕМ ГОТОВНОСТИ LCD
MOVLW h'38'		            ; ИНИЦИАЛИЗАЦИЯ LCD ШИНА 8 БИТ, 2 СТРОКИ, МАТРИЦА 5х8
CALL WRC	                ;
MOVLW h'0C'	    	        ; ОТОБРАЖЕНИЕ БЕЗ КУРСОРА
CALL WRC	                ;
MOVLW h'06'		            ; АВТОМАТИЧЕСКОЕ ПЕРЕМЕЩЕНИЕ КУРСОРА СЛЕВА НАПРАВО
CALL WRC	                ;
MOVLW h'01'		            ; ОЧИСТИТЬ ДИСПЛЕЙ
CALL WRC	                ;
RETURN                      ;
;===============================================================================================
;                              ЗАПИСЬ КОДА КОМАНД LCD
;===============================================================================================
WRC                         ;
BCF PORTA,RS                ; RS = 0
BCF PORTA,RW                ; RW = 0
MOVWF PORTB                 ; ОТПРАВЛЯЕМ К LCD ДАННЫЕ 
BSF PORTA,E                 ; E = 1
BCF PORTA,E                 ; E = 0
CALL BUSY                   ; ЖДЕМ ГОТОВНОСТИ
RETURN                      ;
;===============================================================================================
;                             ЗАПИСЬ КОДА ДАННЫХ LCD
;===============================================================================================
WRD                         ;
BSF PORTA,RS                ;
BCF PORTA,RW                ;
MOVWF PORTB                 ;
BSF PORTA,E                 ;
BCF PORTA,E                 ;
CALL BUSY                   ;
RETURN                      ;
;===============================================================================================
;                             ЧТЕНИЯ КОДА КОМАНД LCD
;===============================================================================================
C_READ                      ;
CLRF TEMP_LCD               ;
BCF PORTA,RS                ; RS = 0
BSF PORTA,RW                ; RW = 1
BSF PORTA,E                 ; E = 1
MOVF PORTB,W                ; ЧИТАЕМ ДАННЫЕ ИЗ ПОРТА
MOVWF TEMP_LCD              ; И ЗАНОСИМ ИХ В TEMP_LCD
BCF PORTA,E                 ; E = 0
BCF PORTA,RW                ; RW = 0
RETURN                      ;
;===============================================================================================
;                      ПРОВЕРКА ГОТОВНОСТИ LCD
;===============================================================================================
BUSY                        ;
BSF STATUS,RP0 	            ; ПЕРЕХОДИМ В БАНК 1
MOVLW B'11111111'           ; ЧТО БЫ УСТАНОВИТЬ ВСЕ ВЫВОДЫ PORTB
MOVWF TRISB                 ; НА ВХОД
BCF	STATUS,RP0              ; ВОЗВРАЩАЕМСЯ В БАНК 0
CALL C_READ                 ; ЧИТАЕМ ПОРТ
BTFSC TEMP_LCD,7            ; Если сигнала готовности нет,
GOTO BUSY                   ; то проверяем снова
BSF STATUS,RP0              ; ПЕРЕВОДИМ ВЫВОДЫ PORTB НА ВЫХОД
MOVLW B'00000000'           ;
MOVWF TRISB                 ;
BCF	STATUS,RP0              ; 
RETURN                      ;
;===============================================================================================
;                      ЗАДЕРЖКА 15 МС
;===============================================================================================
DEL_15MS                    ;
CLRF COUNT0                 ;
MOVLW .20                   ;
MOVWF COUNT1                ;
DECFSZ COUNT0               ;
GOTO $-1                    ;
DECFSZ COUNT1               ;
GOTO $-3                    ;
RETURN                      ;
;===============================================================================================
;                      ЗАДЕРЖКА 4 МС
;===============================================================================================
DEL_4MS                     ;
CLRF COUNT0                 ;
MOVLW .6                    ;
MOVWF COUNT1                ;
DECFSZ COUNT0               ;
GOTO $-1                    ;
DECFSZ COUNT1               ;
GOTO $-3                    ;
RETURN                      ;
;===============================================================================================
;                      ЗАДЕРЖКА 100 МКС
;===============================================================================================
DEL_100MKS                  ;
MOVLW .34                   ;
MOVWF COUNT0                ;
DECFSZ COUNT0               ;
GOTO $-1                    ;
RETURN                      ;
;===============================================================================================
;                      ЗАГРУЗКА СТРОК
;===============================================================================================
PRINT_TEXT                  ;

MOVLW 0x80                  ; ПЕРВАЯ СТРОКА
CALL WRC                    ;
MOVLW 0x57                  ; W
CALL WRD                    ;
MOVLW 0x57                  ; W
CALL WRD                    ;
MOVLW 0x57                  ; W
CALL WRD                    ;
MOVLW 0x2E                  ; .
CALL WRD                    ;
MOVLW 0x50                  ; P
CALL WRD                    ;
MOVLW 0x48                  ; H
CALL WRD                    ;
MOVLW 0x52                  ; R
CALL WRD                    ; 
MOVLW 0x45                  ; E
CALL WRD                    ;
MOVLW 0x41                  ; A
CALL WRD                    ; 
MOVLW 0x4B                  ; K
CALL WRD                    ;
MOVLW 0x45                  ; E
CALL WRD                    ;
MOVLW 0x52                  ; R
CALL WRD                    ;
MOVLW 0x53                  ; S
CALL WRD                    ;
MOVLW 0x2E                  ; .
CALL WRD                    ;
MOVLW 0x55                  ; U
CALL WRD                    ;
MOVLW 0x53                  ; S
CALL WRD                    ;

MOVLW 0xC0                  ; ВТОРАЯ СТРОКА
CALL WRC                    ;
MOVLW 0x48                  ; H
CALL WRD                    ;
MOVLW 0x4F                  ; O
CALL WRD                    ;
MOVLW 0x50                  ; P
CALL WRD                    ;
MOVLW 0x3A                  ; :
CALL WRD                    ;
MOVLW 0x20                  ; пробел
CALL WRD                    ;
MOVLW 0x45                  ; E
CALL WRD                    ;
MOVLW 0x46                  ; F
CALL WRD                    ;
MOVLW 0x39                  ; 9
CALL WRD                    ;
MOVLW 0x42                  ; B
CALL WRD                    ;
MOVLW 0x45                  ; E
CALL WRD                    ;
MOVLW 0x45                  ; E
CALL WRD                    ;
MOVLW 0x30                  ; 0
CALL WRD                    ;
MOVLW 0x32                  ; 2
CALL WRD                    ;
MOVLW 0x2E                  ; .
CALL WRD                    ;
MOVLW 0x2E                  ; .
CALL WRD                    ;
MOVLW 0x2E                  ; .
CALL WRD                    ;

RETURN

END