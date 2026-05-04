; post2.asm - ADC: suma de 32 bits
ORG 100h

section .data
  ; A = 0x0001FFFF = 131071 decimal
  ; B = 0x00010001 = 65537 decimal
  ; Esperado: A + B = 0x00030000 = 196608 decimal
  aLo   dw 0FFFFh     ; parte baja de A
  aHi   dw 0001h      ; parte alta de A
  bLo   dw 0001h      ; parte baja de B
  bHi   dw 0001h      ; parte alta de B
  resLo dw 0          ; resultado parte baja
  resHi dw 0          ; resultado parte alta
  msg    db "Suma OK: 0003:0000", 0Dh, 0Ah, "$"
  msgRest db "Resta OK: 0001:FFFF", 0Dh, 0Ah, "$"
  msgErr db "Error en suma.$"

section .text
start:
  mov ax, [aLo]
  mov dx, [aHi]
  mov bx, [bLo]
  mov cx, [bHi]

  add ax, bx          ; sumar partes bajas: CF puede activarse
  adc dx, cx          ; sumar partes altas + CF

  mov [resLo], ax
  mov [resHi], dx

  ; Verificar resultado esperado
  cmp ax, 0000h
  jne .error
  cmp dx, 0003h
  jne .error

  mov ah, 09h
  mov dx, msg
  int 21h

  ; Restar B de A usando SBB
  ; A = 0x00030000, B = 0x00010001
  ; Esperado: A - B = 0x0001FFFF
  mov ax, 0000h       ; parte baja de A
  mov dx, 0003h       ; parte alta de A
  mov bx, 0001h       ; parte baja de B
  mov cx, 0001h       ; parte alta de B

  sub ax, bx          ; 0000h - 0001h = FFFFh, CF=1 (prestamo)
  sbb dx, cx          ; 0003h - 0001h - CF(1) = 0001h

  ; Resultado: DX:AX = 0001:FFFFh = 0x0001FFFF
  ; Verificar:
  cmp ax, 0FFFFh
  jne .error
  cmp dx, 0001h
  jne .error

  mov ah, 09h
  mov dx, msgRest
  int 21h

  jmp .fin

.error:
  mov ah, 09h
  mov dx, msgErr
  int 21h

.fin:
  mov ah, 4Ch
  xor al, al
  int 21h