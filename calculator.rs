use std::process::Command;
use std::fs;
use std::io::{self};
use std::path::Path;

fn main() -> io::Result<()> {
    let asm_file = "calculator.asm";
    let obj_file = "calculator.o";
    let exe_file = "calculator";
    
    // Check if assembly file exists
    if !Path::new(asm_file).exists() {
        eprintln!("Error: {} not found!", asm_file);
        eprintln!("Please ensure the assembly file is in the same directory.");
        return Ok(());
    }
    
    println!("Compiling assembly calculator...");
    
    let nasm_output = Command::new("nasm")
        .args(&["-f", "elf64", asm_file, "-o", obj_file])
        .output();
    
    match nasm_output {
        Ok(output) => {
            if !output.status.success() {
                eprintln!("NASM assembly failed:");
                eprintln!("{}", String::from_utf8_lossy(&output.stderr));
                return Ok(());
            }
            println!("Assembly successful!");
        }
        Err(e) => {
            eprintln!("Error running nasm: {}", e);
            eprintln!("Make sure nasm is installed (sudo apt install nasm)");
            return Ok(());
        }
    }
    
    // Link with ld
    let ld_output = Command::new("ld")
        .args(&[obj_file, "-o", exe_file])
        .output();
    
    match ld_output {
        Ok(output) => {
            if !output.status.success() {
                eprintln!("Linking failed:");
                eprintln!("{}", String::from_utf8_lossy(&output.stderr));
                return Ok(());
            }
            println!("Linking successful!");
        }
        Err(e) => {
            eprintln!("Error running ld: {}", e);
            return Ok(());
        }
    }
    
    println!("Running Assembly Calculator");
    
    // Run asm calculator
    let run_output = Command::new(format!("./{}", exe_file))
        .spawn();
    
    match run_output {
        Ok(mut child) => {
            let status = child.wait()?;
            println!("Calculator exited with status: {}", status);
        }
        Err(e) => {
            eprintln!("Error running calculator: {}", e);
        }
    }
    
    // Cleanup object file
    let _ = fs::remove_file(obj_file);
    
    Ok(())
}






