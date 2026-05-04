# Laboratorio Post-Contenido 1 - Unidad 8: Operaciones con Cadenas y Aritmética
---

## Descripción
Este laboratorio implementa en NASM bajo DOSBox operaciones aritméticas 
de precisión múltiple de 32 bits, aritmética BCD empaquetada, y una mini 
calculadora de enteros con conversión ASCII/binaria.

---

## Requisitos
- DOSBox 0.74 o superior
- NASM 2.16 o superio

---

## Archivos

| Archivo      | Descripción                              |
|--------------|------------------------------------------|
| `post2.asm`  | Suma y resta de 32 bits con ADC y SBB    |
| `post2b.asm` | Aritmética BCD empaquetada con DAA y DAS |
| `post2c.asm` | Mini calculadora con MUL y DIV           |

---

## 1. Aritmética de 32 bits — `post2.asm`

En modo real de 16 bits los números de 32 bits se dividen en dos partes 
de 16 bits almacenadas en pares de registros (DX:AX).

### Suma con ADC
La suma se realiza en dos pasos:
- `ADD` suma las partes bajas y puede generar un byte de acarreo (CF)
- `ADC` suma las partes altas propagando el CF automáticamente

```
A = 0x0001FFFF + B = 0x00010001
ADD ax, bx  -> AX = 0000h, CF = 1 (acarreo generado)
ADC dx, cx  -> DX = 0003h (CF propagado correctamente)
Resultado: DX:AX = 0003:0000 
```

### Resta con SBB
La resta funciona de forma similar con el bit de préstamo (borrow):
- `SUB` resta las partes bajas y puede generar un borrow (CF=1)
- `SBB` resta las partes altas descontando el CF automáticamente

```
A = 0x00030000 - B = 0x00010001
SUB ax, bx  -> AX = FFFFh, CF = 1 (prestamo generado)
SBB dx, cx  -> DX = 0001h (borrow propagado correctamente)
Resultado: DX:AX = 0001:FFFF 
```

---

## 2. Aritmética BCD — `post2b.asm`

El formato BCD empaquetado almacena dos dígitos decimales por byte,
un nibble por dígito.

### Suma BCD con DAA
Después de un `ADD` normal el resultado puede no ser BCD válido.
`DAA` corrige AL verificando el nibble bajo y el flag AF:
- Si el nibble bajo > 9 o AF=1 -> suma 6 al nibble bajo
- Si el nibble alto > 9 o CF=1 -> suma 6 al nibble alto

```
47h + 38h = 7Fh  (NO es BCD válido)
DAA aplicado → AL = 85h  (correcto BCD) 
```

### Resta BCD con DAS
`DAS` hace lo mismo tras `SUB`, restando 6 donde sea necesario:

```
73h - 28h = 4Bh  (NO es BCD válido)
DAS aplicado → AL = 45h  (correcto BCD) 

20h - 01h = 1Fh  (nibble bajo Fh > 9, inválido)
DAS aplicado → AL = 19h  (correcto BCD)
```

---

## 3. Mini Calculadora — `post2c.asm`

### Lógica de la calculadora
1. **Entrada:** lee dos dígitos (0-9) desde el teclado con `INT 21h / AH=01h`
2. **Conversión ASCII→binario:** resta `30h` al código ASCII de cada dígito
3. **Operación:** según el operador ingresado (`*` o `/`) ejecuta `MUL` o `DIV`
4. **Conversión binario→ASCII:** la subrutina `imprimirAX` divide repetidamente
   AX entre 10, apila cada dígito y los imprime en orden correcto
5. **Protección:** detecta división por cero antes de ejecutar `DIV`

### Casos de prueba verificados

| Operación | Resultado                 |
|-----------|-------------------------- |
| 7 × 8     | `Resultado: 56`           |
| 9 / 3     | `Resultado: 3`            |
| 5 / 0     | `Division por cero.`      |

---

r