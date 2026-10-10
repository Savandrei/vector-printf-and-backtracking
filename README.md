# x86-64 NASM System Programming Modules

A low-level implementation of core data structures, arithmetic parsers, formatted I/O routines, combinatorial algorithms, and bitwise utilities in x86-64 assembly using NASM syntax and the System V AMD64 ABI.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Module Breakdown](#module-breakdown)
   - [Dynamic Vector](#1-dynamic-vector-my_vectorasm)
   - [Reverse Polish Notation Evaluator](#2-reverse-polish-notation-evaluator-reverse_polish_notationasm)
   - [Custom Formatted Output](#3-custom-formatted-output-my_printfasm)
   - [Langford Sequence Engine](#4-langford-sequence-engine-langfordasm)
   - [Numerical and Matrix Utilities](#5-numerical-and-matrix-utilities-bonusasm)
3. [Calling Convention and ABI Standards](#calling-convention-and-abi-standards)
4. [Build and Assembly Instructions](#build-and-assembly-instructions)

---

## Architecture Overview

The codebase consists of five modular translation units targeting Linux x86-64 architectures. The modules interface directly with standard C library primitives (`calloc`, `realloc`, `free`, `printf`, `fgets`, `putc`, `atol`) while handling their own register allocations, stack frames, and control flows.

---

## Module Breakdown

### 1. Dynamic Vector (`my_vector.asm`)

Implements a heap-allocated, dynamically resizing vector for 32-bit signed integers.

#### Structure Layout
The `my_vector` structure is defined with a size of 16 bytes:
```text
+-----------------------+---------+--------+
| Field                 | Type    | Offset |
+-----------------------+---------+--------+
| arr (data buffer ptr) | resq 1  | 0x00   |
| len (element count)   | resd 1  | 0x08   |
| cap (total capacity)  | resd 1  | 0x0C   |
+-----------------------+---------+--------+
```

#### Exported Functions
* `vector *new_vector(int cap)`:
  Allocates the vector header and initial array buffer using `calloc`. If `cap` is passed as 0, it defaults capacity to 1.
* `int set_element(struct vector *v, int elem, int pos)`:
  Writes `elem` at index `pos` if `pos < len`. If the index is out of bounds, prints an error message to standard output and returns `-1`.
* `int get_element(struct vector *v, int pos)`:
  Returns the element stored at index `pos` if `pos < len`. If invalid, prints an error message and returns `-1`.
* `int push_element(struct vector *v, int elem)`:
  Appends an element to the vector. If `len == cap`, doubles capacity (`new_cap = cap * 2`), reallocates memory using `realloc`, updates the array pointer, and increments length.
* `int pop_element(struct vector *v)`:
  Removes and returns the last element. If the vector is empty, prints an error message and returns `-1`. If `2 * len <= cap` and `cap > 1`, reduces capacity by half using `realloc`.
* `void print_vector(struct vector *v)`:
  Outputs the vector structure to standard output in the format:
  ```text
  v -> {([elem0][elem1]...[]...[]), len, cap}
  ```
  Empty capacity slots are rendered as empty brackets (`[]`).
* `void free_vector(struct vector **v)`:
  Deallocates both the dynamic array buffer and the vector control structure using `free`, subsequently setting the caller pointer to `NULL`.

---

### 2. Reverse Polish Notation Evaluator (`reverse_polish_notation.asm`)

A stack-based postfix arithmetic evaluator reading from standard input.

#### Implementation Details
* Reads token lines sequentially from `stdin` into a 100-byte buffer using `fgets`.
* Parses numerical operands using `atol` and pushes them directly onto the hardware stack.
* Detects single-character arithmetic operator tokens:
  * Addition (`+`): Pops two operands, sums them, and pushes the result.
  * Subtraction (`-`): Pops two operands, computes `second_operand - first_operand`, and pushes the result.
  * Multiplication (`*`): Pops two operands, performs signed multiplication using `imul`, and pushes the result.
  * Division (`/`): Pops two operands, computes `numerator / denominator` using unsigned `div` (with `rdx` cleared), and pushes the quotient.
* On end-of-file (EOF), pops the final evaluation result and prints it using format `"%ld\n"`.

---

### 3. Custom Formatted Output (`my_printf.asm`)

A variadic formatted output routine that formats and writes characters to `stdout` via `putc`.

#### Handled Specifiers
* `%c`: Outputs a single character.
* `%s`: Walks and prints a null-terminated string.
* `%lu`: Unsigned 64-bit integer conversion. Extracts digits via repeated integer division by 10 (`div`), stores the ASCII representations on the stack, and outputs them in most-to-least significant order.

#### Argument Access Strategy
The function parses the format string character by character. For the first five variadic parameters, values are read from caller-saved registers preserved on the stack during function prologue. Subsequent variadic parameters are addressed via stack offsets computed relative to the base pointer `rbp`.

---

### 4. Langford Sequence Engine (`langford.asm`)

Provides validation and recursive backtracking generation for Langford sequences of order `n`.

A Langford sequence of order `n` contains each integer from the set `{1, 2, ..., n}` exactly twice, such that between the two occurrences of any integer `k`, there are exactly `k` other numbers. The total sequence length is `2 * n`.

#### Exported Functions
* `int check_langford(int *sequence, int len)`:
  Allocates a tracking buffer using `calloc` to verify occurrence counts and spacing rules. For each value `k` encountered at position `i`, verifies that index `i + k + 1` exists and equals `k`. Returns `1` if valid, `0` otherwise.
* `int **generate_langford_sequences(int n, int *seq_num)`:
  * Checks the solvability condition: a sequence exists if and only if `n mod 4 == 0` or `n mod 4 == 3`. If this condition is not met, sets `*seq_num = 0` and returns `NULL`.
  * For valid values of `n`, allocates a working buffer of size `2 * n` and executes a recursive backtracking algorithm (`backtracking_mess`) to place each pair `(k, k)` in unassigned positions.
  * Collects all valid permutations into a dynamic `int**` array using `realloc` and returns the pointer array alongside the total sequence count in `*seq_num`.

---

### 5. Numerical and Matrix Utilities (`bonus.asm`)

Provides string transformation, binary classification, and matrix analysis routines.

#### Exported Functions
* `void ave(char *src, char *dest, int n)`:
  Applies an affine shift cipher over uppercase ASCII characters:
  ```text
  dest[i] = ((src[i] - 'A' + n) mod 31) + 'A'
  ```
  Applies signed dividend adjustment prior to executing `idiv` to ensure mathematically consistent non-negative modulo operations.
* `void switch_cases(char *src, char *dest)`:
  Toggles ASCII letter case (`+32` for uppercase to lowercase, `-32` for lowercase to uppercase) while transferring non-alphabetic characters unchanged.
* `void heavy(int number)`:
  Evaluates 32-bit integers against bitwise criteria:
  1. Verifies that the most significant bit (bit 31) is set.
  2. Isolates the two middle bytes, swaps their relative order, and evaluates whether the resulting 16-bit integer exceeds 255.
  Prints `"The number is heavy\n"` if true, otherwise `"The number is not heavy\n"`.
* `void flat_matrix(int *mat, int n)`:
  Traverses an `n x n` row-major flattened square matrix column by column, identifies the maximum integer in each column, and prints each maximum on standard output.

---

## Calling Convention and ABI Standards

All routines adhere to the System V AMD64 ABI:
* Integer and pointer arguments are passed in registers: `rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9`.
* Return values are passed via `rax`.
* Non-volatile callee-saved registers (`rbx`, `rbp`, `r12`, `r13`, `r14`, `r15`) are preserved across calls.
* Stack frames maintain 16-byte alignment prior to executing external `call` instructions.

---

## Build and Assembly Instructions

### Prerequisites
* **Assembler:** NASM (2.14 or newer)
* **Compiler / Linker:** GCC
* **Platform:** Linux x86-64

### Object File Assembly
```bash
nasm -f elf64 my_vector.asm -o my_vector.o
nasm -f elf64 reverse_polish_notation.asm -o reverse_polish_notation.o
nasm -f elf64 my_printf.asm -o my_printf.o
nasm -f elf64 langford.asm -o langford.o
nasm -f elf64 bonus.asm -o bonus.o
```

### Linking with Driver Application
```bash
gcc -no-pie -Wall -Wextra main.c \
    my_vector.o \
    reverse_polish_notation.o \
    my_printf.o \
    langford.o \
    bonus.o \
    -o assembly_runner
```
