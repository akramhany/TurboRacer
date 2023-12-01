## ✍️ Naming Conventions

Some Naming conventions to be followed while writing code.  

Definitions:  
1. `PascalCase` - First letter of each word is capitalized
2. `CamelCase`  - First letter of each word is capitalized except the first word
3. `UPPER_CASE` - All letters are capitalized and words are separated by `_`
4. `lower_case` - All letters are lower case and words are separated by `_`

### Files Names
Files Names should be written in `lower_case` and should be descriptive of the contents of the file.

### Variables
- Variables should be written in `camelCase`
- If you want to add a descriptive word before the variable, like `STR`, `ARR`, `CNT` (counter), etc., simply write it first and then add an underscore `_`.
```Assembly

STR_playerOneName  DB 'player one name$'
carSpeed  DB 100H

```

### Procedures
- Procedures should be starting by `PROC` then an underscore `_`, then the name of Procedure in `PascalCase`.
- Procedures should be preceded by a description specifying what they do, the parameters they take and the registers it uses.
```Assembly

;; Description: 
;; Input:
;; Registers:
PROC PROC_ClearScreen

;code

ENDP PROC_ClearScreen

```
