# 0x02. Shell, I/O Redirections and filters

### Holberton School SysAdmin Project

By Julien Barbier

---

### Requirements

- Allowed editors: vi, vim, emacs
- All your scripts will be tested on Ubuntu 14.04 LTS
- All your scripts should be exactly two lines long ($ wc -l file should print 3)
- All your files should end with a new line (why?)
- The first line of all your files should be exactly #!/bin/bash
- A README.md file
- You are not allowed to use backticks, &&, || or ;
- All your files must be executable
- You are *not* allowed to use sed or awk

### Tasks

- [Task 0](0-hello_world). *Hello World*

  The *Hello World* script just prints "Hello World" followed by a new line to standard output.

- [Task 1](1-confused_smiley). *Confused smiley `"(Ôo)'`*

  The script *Confused smiley* displays a confused smiley `"(Ôo)'` to the standard output.

- [Task 2](2-hellofile). *Let's display a file*

  Displays the content of the `/etc/passwd` file.

- [Task 3](3-twofiles). *What about 2?*

  Displays the content of `/etc/passwd` and `/etc/hosts` files

- [Task 4](4-lastlines). *Last lines of a file*

  Displays the last 10 lines of `/etc/passwd` file.

- [Task 5](5-firstlines). *I'd prefer the first ones actually*

  Displays the first 10 lines of `/etc/passwd` file.

- [Task 6](6-third_line). *Line #2*

  Displays the third line of the [`iacta`](https://en.wikipedia.org/wiki/Alea_iacta_est) file.

- [Task 7](8-cwd_state). *Save current state of directory*

  Writes into the file `ls_cwd_content` the result of the command `ls-la`.
  (If the file already exists it ovewrites it, otherwise it's created)

- [Task 8](7-file). *It is a good file that cuts iron without making a noise*

  Creates a file named exactly `\*\\'"Holberton School"\'\\*$\?\*\*\*\*\*:)`
  containing the text `Holberton School` ending by a new line.

- [Task 9](9-duplicate_last_line). *Duplicate last line*

  Duplicates the last line of the [`iacta`](iacta) file.

- [Task 10](10-no_more_js). *No more javascript*

  Deletes all the regular files (not the directories) with a .js extension
  that are present in the current directory and all its subfolders.

- [Task 11](11-directories). *Don't just count your directories, make your directories count*

  Counts the number of directories and sub-directories in the current directory

- [Task 12](12-newest_files). *What's new?*

  Displays the 10 newest files in the current directory.

- [Task 13](13-unique). *Being unique is better than being perfect*

  Takes a list of words as input and prints only words that appear exactly once.

- [Task 14](14-findthatword). *It must be in that file*

  Displays lines containing the pattern "root" from the `/etc/passwd` file.

- [Task 15](15-countthatword). *Count that word*

  Displays the number of lines that contain the pattern "bin" in the file `/etc/passwd`

- [Task 16](16-whatsnext). *What's next?*

  Displays lines containing the patter "root" and 3 lines after in the file `/etc/passwd`

- [Task 17](17-hidethisword). *I hate bins*

  Displays all the lines of the file `/etc/passwd` that do not contain the pattern "bin".

- [Task 18](18-letteronly). *Letters only please*

  Display all lines of the `/etc/ssh/sshd_config` starting with a letter.

- [Task 19](19-AZ). *A to Z*

  Replace all characters `A` and `c` from input to `Z` and `e` respectively.

- [Task 20](20-hiago). *Without C, you would live in hiago*.

  Removes all letters `c` and `C` from the standard input.

- [Task 21](21-reverse). *esreveR*

  Reverses from standard input.

- [Task 22](22-users_and_homes). *DJ Cut Killer*

  Displays all users and their home directories, sorted by users.

- [Task 23](100-empty_casks). *Emtpy casks make the most noise*

  Finds empty files and directories in the current andd all sub-directories and
  displays only its names(without the path).

- [Task 24](101-gifs). *A gif is worth the thousands words*

  Lists all files with a `.gif` extension in the current and all its sub-directories.

- [Task 25](102-acrostic). *Acrostic*

  Decodes acrostics that use the first letter of each line.

- [Task 26](103-the_biggest_fan). *The biggest fan*

  Parses web servers logs in TSV format as input and displays the 11 hosts or
  IP addresses which did the most requests

