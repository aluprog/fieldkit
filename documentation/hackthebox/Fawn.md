# 🦌 FAWN
### Hack The Box · Starting Point · Tier 0

> **Machine #002 | Day 02 | Status: Completed**
>
> 🎯 **Objective:** Learn the basics of FTP, identify the service and its version, access the server anonymously, and download a flag.
>
> 🧭 **Difficulty:** Very Easy
>
> 🧰 **Tools:** Terminal, OpenVPN, `ping`, Nmap, FTP client
>
> 🏷️ **Tags:** `#HTB` `#FieldKit` `#StartingPoint` `#Fawn` `#Easy` `#FTP` `#Port21` `#Nmap` `#AnonymousLogin` `#FileTransfer`

---

## 📌 01. Machine Overview

**What is Fawn?**

Fawn is a beginner-level Hack The Box Starting Point machine that introduces the File Transfer Protocol (FTP). The exercise focuses on identifying an FTP service, checking its version and operating system, connecting to it, logging in anonymously, listing files, and downloading the flag.

The machine demonstrates an important security lesson: **a service can be working exactly as designed while still exposing files to unauthorized users because of its configuration.**

### 🗺️ Attack path

```text
Connect to HTB through OpenVPN
             |
             v
Test connectivity with ping
             |
             v
Scan the target with Nmap
             |
             v
Discover FTP on TCP port 21
             |
             v
Identify vsftpd 3.0.3
             |
             v
Connect using the FTP client
             |
             v
Log in anonymously
             |
             v
List files and directories
             |
             v
Download flag.txt
             |
             v
Read and submit the flag
```

---

# 🧩 02. Task-by-Task Walkthrough

## 🟢 TASK 1 — Understanding FTP

**❓ Question**

What does the three-letter acronym FTP stand for?

**✅ Answer**

File Transfer Protocol.

**⚙️ Process**

This task was very easy. I recognized the acronym and answered without needing additional research.

**💡 Lesson**

FTP is a network protocol designed to transfer files between a client and a server.

It can be used to upload, download, and manage files on a remote system, depending on the server's permissions and configuration.

**📝 Note — FTP vs. SFTP**

FTP and SFTP are different protocols. Although both can transfer files, SFTP operates through SSH and provides encrypted communication when properly configured. Traditional FTP does not encrypt credentials or file contents by default.

---

## 🟢 TASK 2 — FTP's Default Port

**❓ Question**

Which port does the FTP service usually listen on?

**✅ Answer**

TCP port `21`.

**⚙️ Process**

I almost forgot the answer. My first thought was port 24, but I quickly remembered that FTP usually uses port 21.

**💡 Lesson**

Port numbers are easy to mix up when I haven't practiced for a while. Instead of guessing, I should recall the service associated with the port and verify it through enumeration when needed.

Common ports worth remembering:

| Port | Common service |
|---|---|
| TCP 21 | FTP control connection |
| TCP 22 | SSH |
| TCP 23 | Telnet |
| TCP 25 | SMTP |
| TCP 80 | HTTP |
| TCP 443 | HTTPS |

FTP commonly uses TCP port 21 for its control connection. Traditional active and passive FTP also use separate data connections, whose ports depend on the transfer mode and configuration.

**📝 Note — Why does FTP use more than one connection?**

FTP separates commands and responses from file-transfer data. Port 21 normally carries the control connection, while a separate connection carries directory listings and file contents.

That distinction becomes important when troubleshooting FTP connections through firewalls.

---

## 🟢 TASK 3 — Secure File Transfer

**❓ Question**

FTP sends data in the clear, without encryption. What acronym is used for a later protocol designed to provide similar functionality securely as an extension of SSH?

**✅ Answer**

SFTP — SSH File Transfer Protocol.

**⚙️ Process**

I couldn't immediately recall the answer, even though the concept seemed familiar. I tried SMTP, but that was incorrect. After thinking about it for a while, I searched online and found SFTP.

**💡 Lesson**

I need to distinguish between protocols that have similar-looking names but different purposes.

- **FTP:** File Transfer Protocol.
- **SFTP:** SSH File Transfer Protocol, which transfers files through SSH.
- **SMTP:** Simple Mail Transfer Protocol, used to send email.

The fact that SMTP and SFTP share the letters FTP does not mean they serve the same purpose.

SFTP is not simply FTP with encryption added. It is a different protocol that operates over SSH.

**📝 Note — Is SFTP the same as FTPS?**

No.

- **SFTP** uses SSH.
- **FTPS** uses FTP with TLS encryption.

Both can secure file transfers, but their connection mechanisms and configurations differ.

---

## 🟢 TASK 4 — Testing Connectivity

**❓ Question**

What command can we use to send an ICMP Echo Request to test our connection to the target?

**✅ Answer**

`ping`

**⚙️ Process**

This time, I read the question carefully and remembered the answer from my previous machine, Meow.

I could immediately connect the question to the command I had learned earlier.

```bash
ping -c 4 10.129.45.188
```

**💡 Lesson**

This is a good example of knowledge starting to stick. I didn't need to search for the answer because I had already encountered the same concept.

I should keep reusing previously learned commands across different machines.

A successful ping indicates that the target responds to ICMP Echo Requests. A failed ping, however, does not conclusively prove that the target is unreachable, since ICMP traffic may be blocked.

**📝 Note — Why repeat the same basics on different machines?**

Repeating familiar tasks helps turn knowledge into a habit. The goal is to recognize when a command is useful, understand what its output means, and know its limitations without relying on a walkthrough.

---

## 🟡 TASK 5 — Identifying the FTP Version

**❓ Question**

From your scans, what version is FTP running on the target?

**✅ Answer**

`vsftpd 3.0.3`

**⚙️ Process**

I first ran:

```bash
sudo nmap -sv 10.129.45.188
```

The command kept producing an error. I searched online and discovered that I had made a simple mistake: I used a lowercase `v` instead of an uppercase `V`.

The corrected command was:

```bash
sudo nmap -sV 10.129.45.188
```

After fixing the capitalization, Nmap identified the FTP service and reported its version.

I also learned how to scan a specific port:

```bash
nmap -sV -p 21 10.129.45.188
```

**💡 Lesson**

The mistake was a small one, but it taught me something important about command-line tools: options are exact. Uppercase and lowercase letters can represent different arguments.

In Nmap:

- `-sV` enables service and version detection.
- `-p 21` limits the scan to port 21.
- The target IP tells Nmap which system to scan.

The initial problem wasn't that Nmap was broken. It was that I had supplied an invalid option.

### 📝 Note — What is vsftpd 3.0.3? Is it safe?

**vsftpd** stands for *Very Secure FTP Daemon*. It is an FTP server implementation commonly used on Unix-like operating systems.

Breaking down the result:

- `vsftpd` is the FTP server software.
- `3.0.3` is the detected software version.

The word "Secure" in its name does not mean every deployment is secure. Security depends on the version, configuration, authentication policy, network exposure, and other factors.

Is version 3.0.3 safe?

A version number alone is not enough to make that judgment. You would need to check the applicable security advisories, distribution-specific patches, configuration, and exposed functionality. An old version is a reason to investigate, not automatic proof of a vulnerability.

For this machine, the particularly important finding is that the server allows anonymous access to files.

**🔎 Follow-up investigation**

A version-detection result is a lead for further research. It does not automatically mean that a service is exploitable.

---

## 🟢 TASK 6 — Identifying the Operating System

**❓ Question**

From your scans, what operating system type is running on the target?

**✅ Answer**

Unix.

**⚙️ Process**

I noticed the operating system information in my scan output and identified Unix as the answer.

**💡 Lesson**

Nmap can sometimes infer the operating system from network responses. However, OS detection is an estimate and can depend on network conditions, available responses, and the target's configuration.

The word "Unix" in the scan result should be recorded as the answer reported by the scan, rather than a guarantee of the exact operating system distribution.

**📝 Note — What is Unix?**

Unix is a family of operating systems and an influential operating-system design tradition. Linux is Unix-like, but Linux is not itself the original Unix operating system.

Knowing the likely operating system helps guide later investigation because different systems may have different services, filesystems, and administration practices.

---

## 🟡 TASK 7 — Getting Help from the FTP Client

**❓ Question**

What command do we need to run to display the FTP client's help menu?

**✅ Answer**

`ftp -?`

**⚙️ Process**

I initially assumed that FTP would follow the same help-option conventions as other command-line tools.

I tried:

```bash
ftp -h
```

That did not produce the answer expected by the task. I also considered `nmap -help`, but realized that the question was specifically asking about the FTP client.

After trying `ftp -?`, I found the expected answer.

**💡 Lesson**

I learned that I cannot assume every command-line program implements its help menu in exactly the same way.

The appropriate options depend on the particular program and sometimes the installed implementation or version.

### 📝 Note — Why does `ftp -?` work while Nmap uses `-h` or `--help`?

Each program has its own argument parser and its own conventions.

For the FTP client used in this task, `-?` is the option accepted for displaying usage information. Nmap provides its own help options, including `-h` and `--help`.

The same option can have different meanings in different programs. For example, `-h` can mean help in one application but something else in another.

**Useful habit:** When a help command fails, consult the program's manual page or documentation rather than trying random options indefinitely.

```bash
man ftp
man nmap
```

You can also try:

```bash
ftp --help
nmap --help
```

Support for these options depends on the implementation.

---

## 🟡 TASK 8 — Anonymous FTP Login

**❓ Question**

What username is used over FTP when you want to log in without having an account?

**✅ Answer**

`anonymous`

**⚙️ Process**

At first, I wasn't sure how to connect to the FTP server. I considered searching online, but decided to try it myself first.

I ran:

```bash
ftp 10.129.45.188
```

That was the correct way to start the connection.

When I read the question again, I noticed the phrase "without having an account" and recalled the anonymous FTP username.

I entered the username and was asked for a password. I pressed Enter, but the login failed. I then tried typing `anonymous` and `admin` as the password, but neither worked.

After searching for help, I noticed that I had entered the username with different capitalization from the form accepted by the server. I retried using the expected capitalization and successfully logged in.

I also struggled to leave the FTP session. I tried Ctrl+C and Esc, but neither exited the client as I expected. I eventually found the command:

```text
ftp> exit
```

**💡 Lesson**

This task taught me three things.

1. **Try a reasonable approach before searching for a solution.** I correctly worked out how to start the FTP client by using the target IP.
2. **Read the prompts and pay attention to the exact input.** A username and password are separate fields, and an empty password is different from a missing username.
3. **Learn the controls of interactive programs.** Once inside an FTP client, I am using its own command prompt. Exiting it is different from exiting an ordinary shell.

The capitalization detail is specific to what I observed on this target. FTP implementations and authentication configurations differ, so I should not assume that every server requires the same capitalization behavior.

### 📝 Note — Why could I log in as anonymous?

Anonymous FTP is a configuration that permits users to access certain FTP resources without having a personal account on the server.

The conventional username is `anonymous`. Depending on the server, the password field may accept a blank value, an arbitrary value, or sometimes an email-like string.

In this machine, the server permits the anonymous login used in the exercise. This makes it possible to access files without authenticating as a normal named user.

**Is anonymous FTP always dangerous?**

Not necessarily. It can be intentionally configured to distribute public files. The security concern depends on what the server exposes and whether access is appropriately restricted.

Anonymous access becomes a problem when it exposes files that should not be public or allows unauthorized changes to data.

**🛠️ How to exit FTP**

Use:

```text
ftp> exit
```

Depending on the client, `quit` may also work.

---

## 🟢 TASK 9 — FTP Response Code

**❓ Question**

What response code do we get for the FTP message "Login successful"?

**✅ Answer**

`230`

**⚙️ Process**

After logging in successfully, the terminal displayed output similar to:

```text
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
```

I identified `230` as the response code associated with the successful login.

**💡 Lesson**

FTP uses numeric response codes to communicate the status of commands and operations.

The `230` response indicates that the user has successfully logged in.

This is more reliable than interpreting a response based only on whether the wording looks positive or negative.

**📝 Note — What do the other lines mean?**

- `Remote system type is UNIX.` The server reports its system type to the client.
- `Using binary mode to transfer files.` The client is using binary transfer mode, which is suitable for transferring files without text-mode conversions.

Binary mode is generally appropriate for arbitrary files, including images, archives, executables, and text files.

---

## 🟡 TASK 10 — Listing Remote Files

**❓ Question**

There are a couple of commands we can use to list files and directories on the FTP server. One is `dir`. What is another common command used to list files on a Linux system?

**✅ Answer**

`ls`

**⚙️ Process**

The answer itself was easy because `ls` is one of the most basic Linux commands.

However, after successfully logging in, I spent a while documenting my progress before running the command. When I finally tried to list the files, the FTP session had timed out.

I saw output similar to:

```text
ftp> ls
421 Timeout.
ftp> exit
```

I exited the client, reconnected to the server, and ran `ls` again. It worked.

**💡 Lesson**

Even a correct command can fail when the session or network connection is no longer available.

My delay while taking notes likely contributed to the timeout, although I did not preserve enough diagnostic information to establish the exact cause.

When a command fails, I should distinguish between a problem with the command itself and a problem with the connection or session.

### 📝 Note — Why did FTP time out?

The FTP response code `421` generally indicates that the service is closing the control connection. The accompanying text may describe the specific reason.

Possible causes include an idle-session timeout, a server-side timeout, or another condition that caused the server to close the connection.

In this case, the delay before running `ls` makes an idle timeout plausible, but the exact cause cannot be confirmed from the saved output alone.

When this happens:

1. Read the complete error message.
2. Check whether the session is still active.
3. Reconnect if the server has closed the session.
4. Repeat the command and record the new output.

A useful lesson for my workflow is to complete short interactive tasks before spending a long time writing notes. I can record the output first, then document it afterward.

---

## 🟢 TASK 11 — Downloading a File

**❓ Question**

What command is used to download a file found on the FTP server?

**✅ Answer**

`get`

**⚙️ Process**

I paused to see whether I could recall the command without looking it up. I knew the answer wasn't simply `download`, and eventually remembered the three-letter command `get`.

**💡 Lesson**

FTP clients provide commands specifically for transferring files.

Inside the FTP prompt, I can download a file using:

```text
ftp> get flag.txt
```

The client retrieves the remote file and saves a local copy, usually using the same filename unless a different local filename is specified.

This is different from the shell command `wget`, which is a separate program and is not the FTP client's `get` command.

**📝 Note — Remote vs. local files**

The FTP server stores the remote file. The FTP client downloads a copy to the local machine.

The location where the downloaded file is saved depends on the FTP client's current local working directory and configuration.

---

## 🏁 TASK 12 — Retrieving the Flag

**❓ Question**

Submit the flag located on the FTP server.

**✅ Answer**

`035db21c881520061c53e0536e44f815`

**⚙️ Process**

After logging in anonymously and running `ls`, I saw output that initially looked confusing:

```text
229 Entering Extended Passive Mode (|||49677|)
150 Here comes the directory listing.
-rw-r--r--    1 0        0              32 Jun 04 2021 flag.txt
```

The part I recognized was `flag.txt`, so I used:

```text
ftp> get flag.txt
```

The file downloaded successfully. I opened the downloaded text file and read the flag for submission.

### 🔎 Understanding the confusing output

**1. `229 Entering Extended Passive Mode (|||49677|)`**

This indicates that the server entered Extended Passive Mode (EPSV) and provided port `49677` for the FTP data connection.

In passive FTP, the client establishes the data connection to a port specified by the server. The actual port can vary between sessions.

**2. `150 Here comes the directory listing.`**

The server is indicating that the requested data transfer is about to begin. In this case, it is preparing to send the directory listing.

**3. `-rw-r--r--`**

This is the file permission string:

- `-` indicates a regular file.
- `rw-` means the owner can read and write.
- `r--` means members of the group can read.
- `r--` means other users can read.

These permissions describe the file's reported Unix-style mode. They do not by themselves establish whether the FTP user can modify the file through the server.

**4. `1`**

This is the reported hard-link count.

**5. `0 0`**

These are the reported numeric owner and group IDs. On Unix-like systems, UID `0` and GID `0` commonly correspond to root and the root group, respectively, but the listing alone does not establish the complete account configuration.

**6. `32`**

This is the file size in bytes.

**7. `Jun 04 2021`**

This is the modification date displayed by the server's directory listing.

**8. `flag.txt`**

This is the filename containing the flag.

**💡 Lesson**

I didn't need to understand every column immediately to complete the task, but understanding them afterward makes the result much more useful.

The directory listing gave me several pieces of information about the remote file, and `get` allowed me to retrieve it.

**📝 Note — What does the server reveal through a directory listing?**

Directory listings can reveal filenames, file sizes, permissions, ownership information, and timestamps.

Depending on the server configuration, this information may help an investigator understand the remote filesystem. It can also expose information that the administrator did not intend to make public.

In this machine, the key issue was that anonymous FTP access permitted me to list and download the flag file.

---

# 📚 03. Overall Lessons and Reflection

## 🧠 Technical lessons

1. FTP stands for File Transfer Protocol.
2. TCP port 21 is the standard FTP control port.
3. Traditional FTP does not encrypt its credentials and file contents by default.
4. SFTP transfers files over SSH and is distinct from both FTP and FTPS.
5. `ping` can help test network reachability, with limitations.
6. Nmap's `-sV` option enables service and version detection; option capitalization matters.
7. `vsftpd 3.0.3` identifies the server software and reported version, not its complete security status.
8. FTP clients have their own help options and interactive commands.
9. Anonymous FTP can allow access without a personal account, depending on server configuration.
10. FTP response code `230` indicates successful login.
11. FTP response code `421` indicates that the service is closing the control connection.
12. `ls` lists remote directory contents, and `get` downloads a remote file.
13. Directory-listing output contains useful information about files, permissions, sizes, and timestamps.

## 🧩 What I learned about myself

This machine showed that I am beginning to recall concepts from previous sessions more quickly.

I remembered `ping` from Meow, worked out how to connect to FTP without searching first, and eventually retrieved `get` from memory.

At the same time, I still struggled to recall SFTP and FTP client options. I also lost time because I did not immediately recognize the difference between a command error and a connection timeout.

Those are not failures. They are useful indicators of what needs more practice.

### My troubleshooting rule

> 🛑 Stop → Read → Identify → Test → Observe → Adjust.

I want to use this method whenever I encounter an unfamiliar command, an unexpected error, or a confusing output.

## 🔁 What I would do differently next time

- Recall common port numbers and protocols before looking them up.
- Check command syntax and capitalization before repeatedly rerunning a failed command.
- Use `man` pages and built-in help to learn unfamiliar options.
- Pay attention to the exact FTP login prompt and its response codes.
- Avoid leaving interactive sessions idle for long periods.
- Record command output before spending too long writing explanations.
- Verify the flag and platform submission status before marking the machine complete.

## 📅 Review plan

- **Next session:** Recall the main FTP commands without looking at this write-up.
- **In one week:** Explain FTP, SFTP, FTPS, anonymous access, and the role of TCP port 21.
- **In one month:** Revisit the machine's workflow from memory and compare it with a different service.

The objective is not simply to remember the answer. It is to understand the process well enough to reproduce it independently.

---

# 🛠️ 04. Command Reference

| Purpose | Command |
|---|---|
| Test target connectivity | `ping -c 4 TARGET_IP` |
| Scan common ports | `nmap TARGET_IP` |
| Detect service versions | `nmap -sV TARGET_IP` |
| Scan a specific port | `nmap -sV -p 21 TARGET_IP` |
| Connect to FTP | `ftp TARGET_IP` |
| Display FTP client help | `ftp -?` |
| List remote files | `ls` |
| Download a remote file | `get flag.txt` |
| Exit the FTP client | `exit` |

Replace `TARGET_IP` with the IP address assigned to your current HTB machine. Some FTP client options vary by implementation.

---

# 💭 05. My Assessment

**Fawn was a good test of whether I could carry knowledge from one machine into the next.**

Meow introduced me to basic connectivity, Nmap, and the idea of interacting with a remote service. Fawn built on that foundation by making me identify a particular service and learn how to use its client.

My strongest progress was recognizing familiar concepts more quickly and attempting to solve problems independently before searching online.

The most important areas to improve are command syntax, protocol distinctions, and interpreting error messages. I should also learn to distinguish what I directly observed from what I inferred afterward.

A professional write-up should preserve both: the original evidence and the explanation I developed from it.

**Final takeaway:** Fawn taught me that identifying a service is only the beginning. Understanding how it works, what it exposes, and how to interact with it safely is what makes enumeration useful.

*Machine status: Completed according to my notes. Confirm the flag submission and any remaining platform tasks before treating every completion detail as independently verified.*
