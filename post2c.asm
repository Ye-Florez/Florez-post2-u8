; post2c.asm - MUL/DIV: calculadora de digitos
ORG 100h

section .data
  pA     db "Primer operando (0-9): $"
  pB     db 0Dh, 0Ah, "Segundo operando (0-9): $"
  pOper    db 0Dh, 0Ah, "Operacion * o /: $"
  msgR   db 0Dh, 0Ah, "Resultado: $"
  msgErr db 0Dh, 0Ah, "Division por cero.$"
  crlf   db 0Dh, 0Ah, "$"

section .text
start:
  ; Leer operando A
  mov ah, 09h
  mov dx, pA
  int 21h
  mov ah, 01h
  int 21h             ; AL = ASCII del digito
  sub al, 30h         ; convertir a binario
  mov bl, al          ; guardar en BL

  ; Leer operando B
  mov ah, 09h
  mov dx, pB
  int 21h
  mov ah, 01h
  int 21h
  sub al, 30h
  mov cl, al          ; guardar en CL

  ; Leer operador
  mov ah, 09h
  mov dx, pOper
  int 21h
  mov ah, 01h
  int 21h             ; AL = "*" o "/"
  mov bh, al          ; guardar operador

  ; Mostrar encabezado resultado
  mov ah, 09h
  mov dx, msgR
  int 21h

  cmp bh, 2Ah         ; "*" = 2Ah?
  je .mul
  cmp bh, 2Fh         ; "/" = 2Fh?
  je .div
  jmp .fin

.mul:
  mov al, bl          ; AL = operando A
  mul cl              ; AX = AL * CL (sin signo)
  ; AX contiene el resultado (0-81 maximo para digitos 0-9)
  call imprimirAX
  jmp .fin

.div:
  cmp cl, 0
  je .divCero
  xor ah, ah          ; AH = 0 (extender AL a AX sin signo)
  mov al, bl
  div cl              ; AL = cociente, AH = resto
  push ax             ; guardar resto
  xor ah, ah
  call imprimirAX     ; imprimir cociente
  pop ax
  mov al, ah          ; resto en AL
  xor ah, ah
  ; (opcional: imprimir resto)
  jmp .fin

.divCero:
  mov ah, 09h
  mov dx, msgErr
  int 21h

.fin:
  mov ah, 09h
  mov dx, crlf
  int 21h
  mov ah, 4Ch
  xor al, al
  int 21h

; Subrutina: imprimir AX como numero decimal
imprimirAX:
  mov bx, 10
  xor cx, cx
.divide:
  xor dx, dx
  div bx              ; AX = cociente, DX = digito
  push dx
  inc cx
  test ax, ax
  jnz .divide
.popDigit:
  pop dx
  add dl, 30h
  mov ah, 02h
  int 21h
  loop .popDigit
  ret