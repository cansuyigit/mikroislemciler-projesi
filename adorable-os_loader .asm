     name "loader"
; this is a very basic example of a tiny operating system.

; directive to create boot file:
   #make_boot#

; bu yanlizca bir isletim sistemi yukleyicisidir!
;
; disketin ilk sektorune yuklenebilir:

;   silindir: 0
;   sektor: 1
;   baslik: 0



;=================================================
; mikro isletim sistemi nasil test edilir:
;   1.  micro-os_loader.asm derleyin
;   2.  micro-os_kernel.asm derleyin
;   3.  writebin.asm derleyin
;   4. bos disketi asagdaki surucuye takin:
;   5. komut istemi turunden:
;        writebin loader.bin
;        writebin kernel.bin /k
;=================================================


;
; bu dosyadaki kodun yuklenmesi gerekiyor
; cekirdegi (micro-os_kernel.asm) ve onun uzerindeki kontrolu devretmek.
; cekirdek kodu su konumda diskette olmalidir:

;   silindir: 0
;   sektor: 2
;   baslik: 0

; hafiza tablosu (hex):
; -------------------------------
; 07c0:0000 |   onyukleme sektoru
; 07c0:01ff |   (512 bytes)
; -------------------------------
; 07c0:0200 |    yigin
; 07c0:03ff |   (255 words)
; -------------------------------
; 0800:0000 |    cekirdek
; 0800:1400 | 
;           |   (suanda 5 kb,
;           |    10 sektor
;           |    disketten
;           |    yukleniyor         )
; -------------------------------


;  bu programi test etmek icin diskete yazin.
; derlenmis writebin.asm kullanan disk
; her iki dosyanin da basariyla derlenmesinden sonra,
; komut isteminden sunu yazin: writebin loader.bin   

; Not: disket onyukleme kaydinin uzerine yazilacaktir.
;       disket windows/dos altinda kullanilmayacaktir
;       yeniden bicimlendirirseniz disketteki veriler kaybolabilir.
;       yalnizca bos disketleri kullanin.


; micro-os_loader.asm file produced by this code should be less or   
; equal to 512 bytes, since this is the size of the boot sector.



; on yukleme kaydi yuklendi 0000:7c00
org 7c00h

; yigini baslat:
mov     ax, 07c0h
mov     ss, ax
mov     sp, 03feh ; top of the stack.


; veri segmentini ayarla:
xor     ax, ax
mov     ds, ax

; varsailan video modunu ayarla 80x25:
mov     ah, 00h
mov     al, 03h
int     10h

; hosgeldiniz mesajini yazdir:
lea     si, msg
call    print_string

;===================================
; cekirdegi suraya yukle 0800h:0000h
; 10 baslayan sektorler:
;   silindir: 0
;   sektor: 2
;   baslik: 0

; BIOS surucu numarasini dl olarak ilet,
; yani degismedi:

mov     ah, 02h ; okuma fonksiyonu.
mov     al, 10  ; okunacak sektorler.
mov     ch, 0   ; silindir.
mov     cl, 2   ; sektor.
mov     dh, 0   ; baslik.
; dl degismedi! - surucu numarasi.

; es:bx almayi isaret ediyor
;  veri arabellegi:
mov     bx, 0800h   
mov     es, bx
mov     bx, 0

; okumak!
int     13h
;===================================

; butunluk denetimi:
cmp     es:[0000],0E9h  ; cekirdegin ilk bayti olmalidir 0E9 (jmp).
je     integrity_check_ok

; butunluk kontrolu hatasi
lea     si, err
call    print_string

; herhangi bir anahtari bekle...
mov     ah, 0
int     16h

; sihirli degeri surda sakla 0040h:0072h:
;   0000h - cold boot.
;   1234h - warm boot.
mov     ax, 0040h
mov     ds, ax
mov     w.[0072h], 0000h ; cold boot.
jmp	0ffffh:0000h	     ; yeniden baslat!

;===================================

integrity_check_ok:
;kontrolu cekirdege gecirme :
jmp     0800h:0000h

;===========================================



print_string proc near
push    ax      ; magza kayitlari...
push    si      ;
next_char:      
        mov     al, [si]
        cmp     al, 0
        jz      printed
        inc     si
        mov     ah, 0eh ; teltip islevi .
        int     10h
        jmp     next_char
printed:
pop     si      ; kayitlari yeniden sakla...
pop     ax      ;
ret
print_string endp

                       
                       
                       
;==== veri bolumu =====================

msg  db "Y",154,"kleniyor...",0Dh,0Ah, 0 
     
err  db "sekt",148,"rde ge",135,"ersiz veri: 2, silindir: 0, baslik: 0 - b",154,"t",154,"nl",154,"k kontrol",154," ba",159,"ar",141,"s",141,"z oldu.", 0Dh,0Ah
     db "ogretici 11'e bakin -kendi isletim sisteminizi yapmak.", 0Dh,0Ah
     db "sistem ",159,"imdi yeniden ba",159,"lat",141,"lacak. herhangi bir tu",159,"a bas",141,"n...", 0
    
;======================================

