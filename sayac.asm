; hosgeldin mesaji yazdir:
	mov al, 1
	mov bh, 0
	mov bl, 0000_1011b
	mov cx, msgaend - offset msga ; mesaj boyutunu hesapla. 
	mov dl, 0
	mov dh, 0
	push cs
	pop es
	mov bp, offset msga
	mov ah, 13h
	int 10h

xor bx, bx   

wait:  mov ah, 0   ; herhangi bir anahtari bekle...
       int 16h

       cmp al, 27  ; anahtar 'esc' basildiginda cikis yap. 
       je stop

       mov ah, 0eh 
       int 10h

       inc bx ; her tusa basildginda bx'i artirir

       jmp wait


; sonuc mesajini yazdir:
stop:  	
    mov al, 1
	mov bh, 0
	mov cx, msgbend - offset msgb ; mesaj boyutunu hesapla. 
	mov dl, 2
	mov dh, 2
	push cs
	pop es
	mov bp, offset msgb
	mov ah, 13h
	int 10h

mov ax, bx
call print_ax

; herhangi bir tusa basilmasini bekleyin:
mov ah, 0
int 16h

ret ; isletim sisteminden cikis.

msga db "T",154,"m tu",159," say",141,"s",141,"n",141," sayaca",167,"",141,"m. Durdurmak i",135,"in 'Esc' tu",159,"una bas",141,"n...", 0Dh,0Ah,
msgaend:
msgb db 0Dh,0Ah, "Kaydedilen tu",159," say",141,"s",141," "
msgbend: 


   
print_ax proc
cmp ax, 0
jne print_ax_r
    push ax
    mov al, '0'
    mov ah, 0eh
    int 10h
    pop ax
    ret 
print_ax_r:
    pusha
    mov dx, 0
    cmp ax, 0
    je pn_done
    mov bx, 10
    div bx    
    call print_ax_r
    mov ax, dx
    add al, 30h
    mov ah, 0eh
    int 10h    
    jmp pn_done
pn_done:
    popa  
    ret  
endp
