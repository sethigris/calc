# Built a Calculator in Assembly and Orchestrated it with Rust
- *Development Environment*: Linux (Linux Mint).
- *Disclaimer*: For Windows developers who want to test the code, I will advise to use wsl 2.0 or download assembly programming language for windows.

When I first started learning x86-64 assembly, I wanted to build something practical and very basic—a simple arithmetic calculator. What I didn't expect was how much I'd learn about the relationship between low-level and high-level programming by creating a Rust wrapper to compile and run my assembly code.

## The Assembly Calculator

The calculator itself is pure x86-64 assembly—no libraries, no abstractions, just syscalls and registers. It prompts for two numbers and an operator, performs the calculation, and displays the result. Writing it meant thinking about things I usually take for granted:

- **Memory management**: Every byte of storage had to be explicitly allocated in the `.bss` or `.data` sections
- **String conversion**: Converting ASCII input to integers and back required manual loops and arithmetic
- **Control flow**: No `if` statements or `match` expressions—just conditional jumps and labels
- **System calls**: Direct interaction with the Linux kernel for I/O operations

The most challenging part? Writing the `int_to_string` function. In Rust, I'd just use `format!()` or `.to_string()`. In assembly, I had to divide by 10 repeatedly, store remainders, reverse the digit order, and handle negative numbers as a special case. It gave me a visceral appreciation for what compilers do behind the scenes.
Below is the image of the simple arithmetic calculator
(./img/calc.png)

## Enter Rust: The Orchestra Conductor

Once I had working assembly code, I wanted a better way to run it than manually typing NASM and LD commands. That's where Rust came in.

The Rust wrapper doesn't just execute the assembly—it orchestrates the entire build pipeline:

```rust
Command::new("nasm")
    .args(&["-f", "elf64", asm_file, "-o", obj_file])
    .status()?;

Command::new("ld")
    .args(&[obj_file, "-o", exe_file])
    .status()?;

Command::new(format!("./{}", exe_file))
    .status()?;
```

This simple abstraction hides so much complexity. Rust's `std::process::Command` handles process spawning, argument passing, and error handling elegantly—things that would be incredibly tedious in assembly.

## What I Learned

### 1. **Abstraction Has Real Cost (and Value)**

Every convenience in high-level languages—automatic memory management, type inference, string handling—comes with layers of abstraction. Assembly showed me the raw cost of these operations. A simple string-to-integer conversion that's one line in Rust required 40+ lines of carefully crafted assembly.

But those abstractions have value too. The Rust code is readable, maintainable, and safe. It checks for errors, handles edge cases, and expresses intent clearly. The assembly is fast and direct, but fragile and difficult to modify.

### 2. **Different Tools for Different Jobs**

Assembly excels at scenarios requiring precise control—device drivers, bootloaders, performance-critical inner loops. Rust excels at building robust systems with safety guarantees.

Using them together was powerful. The assembly calculator has zero dependencies and runs with direct kernel syscalls. The Rust wrapper provides a polished user experience with error checking, cleanup, and an interactive loop—without slowing down the core calculation.

### 3. **The Build Process is Code Too**

Before this project, I took build tools for granted. Writing the Rust wrapper made me think about compilation as a series of transformations:

```
.asm → (NASM) → .o → (LD) → executable → (run) → output
```

Each step can fail in different ways. The Rust code handles each failure mode gracefully, providing helpful error messages and cleanup. It's basically a custom build system, and it gave me newfound respect for tools like Make, Cargo, and CMake.

### 4. **Interoperability is Surprisingly Elegant**

I expected interfacing assembly with Rust to be painful. It wasn't. The compiled assembly binary runs independently—Rust just spawns it as a subprocess. No FFI, no linking complexities, no ABI concerns.

This loose coupling is actually a strength. The assembly calculator is a complete, standalone program. The Rust wrapper is a separate, complete program. They communicate through standard I/O streams, which is a universal interface that works across languages, platforms, and decades.

## The Bigger Picture

This project crystallized something important for me: **understanding low-level details makes you better at high-level programming.**

When I write Rust now, I think about:
- What syscalls my file I/O might trigger
- How many allocations my string operations cause  
- What the compiled code might look like

And when I need to debug performance issues or understand undefined behavior, I have the mental model to reason about what's actually happening at the machine level.

## Try It Yourself

If you're curious about systems programming, I highly recommend this exercise:
1. Build something simple in assembly (a calculator, string reverser, anything)
2. Write a higher-level wrapper in your language of choice
3. Reflect on the differences

You'll gain perspective on abstraction, performance trade-offs, and the beautiful complexity hiding beneath every line of code you write.

The repository with my full implementation is available—check it out, break it, improve it, and see what you learn!

---

*What low-level projects have taught you surprising lessons? I'd love to hear about your experiences in the comments below.*
