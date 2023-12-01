## ✍️ Conventions

Some conventions to be followed while writing code.  

Definitions:  
1. `PascalCase` - First letter of each word is capitalized
2. `CamelCase`  - First letter of each word is capitalized except the first word
3. `UPPER_CASE` - All letters are capitalized and words are separated by `_`
4. `lower_case` - All letters are lower case and words are separated by `_`

### Files Names
Files Names should be written in `lower_case` and should be descriptive of the contents of the file.

### Instructions
- All instructions and registers should be written in `UPPER_CASE`.
```Assembly

; Load value from memory into AX register
MOV AX, [MemoryLocation]

```

### Variables
- Variables should be written in `camelCase`
- If you want to add a descriptive word before the variable, like `STR`, `ARR`, `CNT` (counter), etc., simply write it first and then add an underscore `_`.
```Assembly

STR_playerOneName  DB 'player one name$'
carSpeed  DB 100H

```

### Procedures
- Procedures should be written in `PascalCase`.
- Procedures should be preceded by a description specifying what they do, the parameters they take and the registers they use.
```Assembly

;; Description: 
;; Input:
;; Registers:
PROC ClearScreen

;code

ENDP ClearScreen

```

### Macros
- Macros should be written in `PascalCase`.
- Macros should be preceded by a description specifying what they do.
```Assembly

;; Description:
SetCursorAtRowCol MACRO row, col

;code

ENDM

```

### Labels & Loops
- Labels should be always written at the beginning of the line without any indentation
- Use specific and meaningful labels names.

### Commenting
- **Section Comments**: Clearly explain the purpose of each section.
```Assembly

; ***************************************
; Section: Data Initialization
; ***************************************

```
- **Instruction Comments**: Add comments for complex or non-obvious instructions.
