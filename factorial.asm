; bu ornek kullanicidan numarayi alir,
; ve bunun icin faktoriyelini hesaplar.
; 0'dan 8'e kadar desteklenen giris!



; bu makro AL'de bir karakter yazdirir ve ilerler
; gecerli imlec konumu:
puts    macro   char
        push    ax
        mov     al, char
        mov     ah, 0eh
        int     10h     
        pop     ax
endm





jmp basla


result dw ?
     


basla:

; ilk sayiyi al:

	mov al, 1
	mov bh, 0
	mov bl, 0000_1011b
	mov cx, msg1end - offset msg1 ; mesaj boyutunu hesapla. 
	mov dl, 0
	mov dh, 0
	push cs
	pop es
	mov bp, offset msg1
	mov ah, 13h
	int 10h
jmp n1
msg1 db 0Dh,0Ah, 'Say',141,'y',141,' giriniz: '
msg1end:
n1:

call    scan_num


; 0! = 1:
mov     ax, 1
cmp     cx, 0
je      print_result

; sayiyi bx' tasiyin:
; cx sayac olacaktir:

mov     bx, cx

mov     ax, 1
mov     bx, 1

calc_it:
mul     bx
cmp     dx, 0
jne     overflow
inc     bx
loop    calc_it

mov result, ax


print_result:

; sonucu ax'de yazdir:
	mov al, 1
	mov bh, 0
	mov bl, 0000_1011b
	mov cx, msg2end - offset msg2 ; mesaj boyutunu hesapla. 
	mov dl, 2
	mov dh, 2
	push cs
	pop es
	mov bp, offset msg2
	mov ah, 13h
	int 10h
jmp n2
msg2 db 0Dh,0Ah, 'fakt',148,'riyel: '
msg2end:
n2:


mov     ax, result
call    print_num_uns
jmp     exitf


overflow:
	mov al, 1
	mov bh, 0
	mov bl, 0000_1011b
	mov cx, msg3end - offset msg3 ; mesaj boyutunu hesapla. 
	mov dl, 2
	mov dh, 2
	push cs
	pop es
	mov bp, offset msg3
	mov ah, 13h
	int 10h
jmp n3
msg3 db 0Dh,0Ah, 'sonu',135,' ',135,'ok b',154,'y',154,'k!', 0Dh,0Ah, '0 ile 8 aras',141,'ndaki de',167,'erleri kullan',141,'n.'
msg3end:
n3:
jmp     start

exitf:

;herhangi bir tusa basilmasini bekleyin:
mov ah, 0
int 16h

ret








;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; these functions are copied from emu8086.inc ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; klavyeden cok basamakli girilmis sayiyi alir,
; ve sonucu cx register'ýnda saklar:
SCAN_NUM        PROC    NEAR
        PUSH    DX
        PUSH    AX
        PUSH    SI
        
        MOV     CX, 0

        ; bayragi sifirla:
        MOV     CS:make_minus, 0

next_digit:

        ; klavyeden karakter al
        ; AL'ye:
        MOV     AH, 00h
        INT     16h
        ; ve yazdir:
        MOV     AH, 0Eh
        INT     10h

        ; eksiyi kontrol et:
        CMP     AL, '-'
        JE      set_minus

        ; ENTER tusunu kontrol edin :
        CMP     AL, 0Dh  ; satirbasi?
        JNE     not_cr
        JMP     stop_input
not_cr:


        CMP     AL, 8                   ; 'geri al'a basildi mi?
        JNE     backspace_checked
        MOV     DX, 0                   ; son rakami kaldir
        MOV     AX, CX                  ; bolume gore:
        DIV     CS:ten                  ; AX = DX:AX / 10 (DX-rem).
        MOV     CX, AX
        PUTs    ' '                     ; net pozisyon.
        PUTs    8                       ; tekrar geri al.
        JMP     next_digit
backspace_checked:


        ; yalnizca rakamlar izin ver:
        CMP     AL, '0'
        JAE     ok_AE_0
        JMP     remove_not_digit
ok_AE_0:        
        CMP     AL, '9'
        JBE     ok_digit
remove_not_digit:       
        PUTs    8       ; geri al.
        PUTs    ' '     ; 
        PUTs    8       ; tekrar geri al.        
        JMP     next_digit ; sonraki girisi bekle.       
ok_digit:


        PUSH    AX
        MOV     AX, CX
        MUL     CS:ten                  ; DX:AX = AX*10
        MOV     CX, AX
        POP     AX

        ; sayinin buyuk olup olmadigini kontrol etme
        CMP     DX, 0
        JNE     too_big

        ; ASCII koduna donusturme:
        SUB     AL, 30h

        ; CX'e al ekle:
        MOV     AH, 0
        MOV     DX, CX      ; sonuc cok buyukse yedekleme.
        ADD     CX, AX
        JC      too_big2    ; sayi cok buyukse atla.

        JMP     next_digit

set_minus:
        MOV     CS:make_minus, 1
        JMP     next_digit

too_big2:
        MOV     CX, DX      ; eklemeden once yedeklenen degeri geri yukle
        MOV     DX, 0       ; yedeklemeden once DX sifirdi!
too_big:
        MOV     AX, CX
        DIV     CS:ten  ; 
        MOV     CX, AX
        PUTs    8       ; geri al.
        PUTs    ' '     
        PUTs    8               
        JMP     next_digit ; Enter/Backspace icin bekle.
        
        
stop_input:
        ; kontrol flag:
        CMP     CS:make_minus, 0
        JE      not_minus
        NEG     CX
not_minus:

        POP     SI
        POP     AX
        POP     DX
        RET
make_minus      DB      ?       ; bir flag kullan.
SCAN_NUM        ENDP



PRINT_NUM       PROC    NEAR
        PUSH    DX
        PUSH    AX

        CMP     AX, 0
        JNZ     not_zero

        PUTs    '0'
        JMP     printedd

not_zero:
        ; AX'in kontrol isareti,
        ; negatifse mutlak yapin:
        CMP     AX, 0
        JNS     positive
        NEG     AX

        PUTs    '-'

positive:
        CALL    PRINT_NUM_UNS
printedd:
        POP     AX
        POP     DX
        RET
PRINT_NUM       ENDP



PRINT_NUM_UNS   PROC    NEAR
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX

        ; sayidan once sifira basilmasini onlemek icin flag:
        MOV     CX, 1

       
        MOV     BX, 10000       ; 2710h - divider.

        ; AX sifir mi?
        CMP     AX, 0
        JZ      print_zero

begin_print:

        ; bolucuyu kontrol edin (sifirsa end_print gidin):
        CMP     BX,0
        JZ      end_print

        ; sayidan once sifira basmaktan kacinin:
        CMP     CX, 0
        JE      calc
        ; if AX<BX ise DIV sonucu sifir olacaktir:
        CMP     AX, BX
        JB      skip
calc:
        MOV     CX, 0   

        MOV     DX, 0
        DIV     BX      ; AX = DX:AX / BX   (DX=remainder).

        ; son rakami yazdir:
        ADD     AL, 30h    
        PUTs    AL


        MOV     AX, DX  

skip:
        ; hesapla BX=BX/10
        PUSH    AX
        MOV     DX, 0
        MOV     AX, BX
        DIV     CS:ten  ; AX = DX:AX / 10   (DX=remainder).
        MOV     BX, AX
        POP     AX

        JMP     begin_print
        
print_zero:
        PUTs    '0'
        
end_print:

        POP     DX
        POP     CX
        POP     BX
        POP     AX
        RET
PRINT_NUM_UNS   ENDP



ten             DW      10      


