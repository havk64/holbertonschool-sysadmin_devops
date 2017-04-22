# 0x03. Shell, init files, variables and expansions

### Holberton School SysAdmin Project

by Julien Barbier

---

### Requirements:

- Allowed editors: vi, vim, emacs
- All your scripts will be tested on Ubuntu 14.04 LTS
- All your scripts should be exactly two lines long ($ wc -l file should print 2)
- All your files should end with a new line (why?)
- The first line of all your files should be exactly #!/bin/bash
- This README.md file
- You are not allowed to use &&, || or ;
- You are not allowed to use bc, sed or awk
- All your files must be executable

### Tasks

- [Task 0](0-alias). *<o>*

  Creates an alias.

- [Task 1](1-hello_you). *Hello you*

  Prints `hello user`, where the *user* is the current Linux user.

- [Task 2](2-path). *The path of success is to take massive, determined action*

  Add the dir `/action` to the PATH.
  `/action` should be the last directory the shell looks into when looking for a program.

- [Task 3](3-paths). *If the path be beautiful, let us not ask where it leads*

  Counts the number of directories in the `PATH`

- [Task 4](4-global_variables). *Global variables*

  Lists all environment variables

- [Task 5](5-local_variables). *Local variables*

  Lists all local and environment variables and functions.

- [Task 6](6-create_local_variable). *Local variable*

  Creates a new local variable.

- [Task 7](7-create_global_variable). *Global variable*

  Creates a new global variable.

- [Task 8](8-true_knowledge). *Every addition to true knowledge is an addition to human power*

  Prints the result of the addition of 128 with the value stored in the
  environment variable TRUEKNOWLEDGE, followed by a new line. 

- [Task 9](9-divide_and_rule). *Divide and rule*

  Prints the result of env variables `POWER` divided by `DIVIDE`, followed by a new line.

- [Task 10](10-love_exponent_breath). *Love is anterior to life, posterior to* 
  *death, initial of creation, and the exponent of breath*

  Displays the result of env variables `BREATH` to the power `LOVE`

- [Task 11](11-binary_to_decimal). *There are 10 types of people in the world*
  *-- Those who understand binary, and those who don't*

  Converts a number from base 2 to base 10.

- [Task 12](12-combinations). *Combination*

  Prints all possible combinations of two letters, except `oo`.
  - Letters are lower cases, from `a` to `z`
  - One combination per line
  - The output should be alpha ordered, starting with `aa`
  - Do not print `oo`
  - The script file should contain maximum 64 characters
  
- [Task 13](13-print_float). *Floats*

  Prints an exported number with two decimal places

- [Task 14](14-decimal_to_hexadecimal). *Decimal to Hexadecimal*

  Converts a number(stored in an env variable) from base 10 to base 16

- [Task 17](100-rot13). *Everyone is a proponent of strong encryption*

  Encodes and decodes text using the rot13 encryption.

- [Task 18](101-odd). *The eggs of the brood need to be an odd number*

  Prints every other line from the input, starting with the first line
