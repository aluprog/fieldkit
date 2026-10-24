# 💃 DANCING — HTB Starting Point

**Machine:** #003 — Day 03  
**Tier:** 0  
**Difficulty:** Easy  
**Platform:** Hack The Box — Starting Point

**Tags:** `#HTB` `#Easy` `#SMB` `#Nmap` `#Port445` `#smbclient` `#FileShares` `#LinuxCommands`

---

## 🎯 Objective

Learn how to discover SMB services with Nmap, enumerate network shares, connect to an accessible share using `smbclient`, navigate directories, and download files to retrieve the flag.

## 🧰 Tools Used

- **Nmap** — Port scanning and service detection.
- **smbclient** — Connecting to and interacting with SMB shares.
- **Terminal commands** — `ls`, `cd`, `get`, and `cat`.
- **Google** — Researching unfamiliar concepts and troubleshooting errors.

**Target IP:** `10.129.49.78`

---

# 📝 TASKS & SOLUTIONS

## Task 1 — Understanding SMB

**Question:** What does the 3-letter acronym SMB stand for?

**Answer:** `Server Message Block`

### 🔍 Process

I couldn't come up with the answer. I had no clue what SMB stood for, so, as I sometimes do when I encounter something unfamiliar, I Googled it.

### 📚 Lesson — What even is SMB?

SMB stands for **Server Message Block**. It is a network protocol that allows computers to share files, folders, printers, and other resources over a network.

For example, imagine a Windows computer has a folder containing documents. Instead of copying those documents manually to another computer, the owner can share the folder over the network. Another authorized computer can connect to that shared folder and access its contents through SMB.

SMB is commonly associated with Windows networks, but Linux can interact with SMB shares too. One popular Linux tool for this is `smbclient`.

Think of SMB as the protocol that makes network file sharing possible, and `smbclient` as one of the tools we can use to interact with it.

### 💭 Note — Is SMB the same as FTP?

No. Both can transfer files, but they are different protocols.

- **SMB:** Commonly used for shared folders and network resources, particularly in Windows environments.
- **FTP:** A protocol designed for transferring files between a client and server.
- **SFTP:** A file-transfer protocol that operates over SSH.

In this machine, SMB is our way into the target's shared files.

---

## Task 2 — Identifying the SMB Port

**Question:** What port does SMB use to operate at?

**Answer:** `445`

### 🔍 Process

I tried a few guesses, including ports `22`, `23`, and `24`, but none was correct. I thought the answer might be in the twenties, but it wasn't. Eventually, I Googled it.

### 📚 Lesson — Why port 445?

SMB commonly operates over **TCP port 445** when using direct-hosted SMB.

Some historical SMB implementations used NetBIOS over TCP/IP, which involved ports such as `139`. However, port `445` is the key port to remember when identifying modern SMB services.

A few useful port associations:

| Port | Common service |
|---|---|
| 21/TCP | FTP |
| 22/TCP | SSH |
| 23/TCP | Telnet |
| 80/TCP | HTTP |
| 139/TCP | NetBIOS session service, historically used with SMB |
| 445/TCP | SMB |

Ports are clues, not absolute proof of what a service is. That is why we use Nmap to investigate the service running behind an open port.

---

## Task 3 — Finding the SMB Service

**Question:** What is the service name for port 445 that came up in our Nmap scan?

**Answer:** `microsoft-ds`

### 🔍 Process

I opened my terminal and ran:

```bash
sudo nmap -sV 10.129.49.78
```

The scan was taking a long time, and it still hadn't finished. I searched online for a way to make Nmap scan faster and found the `-T4` option.

I then ran:

```bash
sudo nmap -sV -T4 10.129.49.78
```

This time, the scan completed in approximately **22.59 seconds**. The service name associated with port 445 was `microsoft-ds`.

### 📚 Lesson — What does `-T4` do?

Nmap's `-T` option controls its **timing template**. The available templates range from `-T0` to `-T5`.

- `-T0` — Extremely slow.
- `-T1` — Very slow.
- `-T2` — Slower and more conservative.
- `-T3` — Default timing.
- `-T4` — Aggressive timing, often useful on reliable networks.
- `-T5` — Very aggressive; may sacrifice reliability.

Using `-T4` asks Nmap to use more aggressive timing settings, which can make scans faster. It does not guarantee a particular scan duration, and it can increase network traffic or cause results to be less reliable on slow or unstable networks.

The `-sV` option asks Nmap to probe discovered services to identify their versions.

The service name `microsoft-ds` is a conventional service label associated with SMB on port 445. It does not mean the scan has identified every detail about the operating system or SMB configuration.

### 💭 Note — Why not always use `-T5`?

Because faster is not always better. Aggressive timing can miss responses on unreliable networks. For authorized lab scans, `-T4` is a useful option, but the default timing can be a better starting point when accuracy and stability matter more than speed.

---

## Task 4 — Listing SMB Shares

**Question:** What is the 'flag' or 'switch' that we can use with the smbclient utility to 'list' the available SMB shares on Dancing?

**Answer:** `-L`

### 🔍 Process

At first, I typed:

```bash
smbclient 10.129.49.78
```

The terminal returned a command-not-found error. I knew I was missing something, so I Googled the command and found:

```bash
smbclient -L 10.129.49.78
```

I was confused about what `-L` actually did. I tried using `sudo` and adding `//` to the target address, but I still didn't understand the command.

Eventually, I suspected that `smbclient` might not even be installed. Instead of checking first, I went straight to Google to find an installation command. After installing it, I checked:

```bash
which smbclient
```

The output was:

```text
/usr/bin/smbclient
```

I then ran:

```bash
smbclient -L //10.129.49.78
```

It asked for a password. I pressed Enter without typing one, and it returned four shares:

```text
Sharename       Type      Comment
---------       ----      -------
ADMIN$          Disk      Remote Admin
C$              Disk      Default share
IPC$            IPC       Remote IPC
WorkShares      Disk
```

It also displayed:

```text
SMB1 disabled -- no workgroup available
```

I had found the answer to the task, but I still didn't understand the difference between listing shares and connecting to one.

### 📚 Lesson — What does `-L` mean?

The `-L` option tells `smbclient` to **list the shares available on a server**.

For example:

```bash
smbclient -L //10.129.49.78
```

This asks the server to show its available shares, subject to the permissions and authentication used.

It does **not** open a particular share for browsing.

The distinction is:

```bash
# List shares on the server
smbclient -L //10.129.49.78

# Connect to one specific share
smbclient //10.129.49.78/WorkShares
```

The `//server/share` format identifies a server and a particular share.

### 💭 Note — What was that SMB1 message?

The message:

```text
SMB1 disabled -- no workgroup available
```

does not necessarily mean the share listing failed. The share list was returned successfully.

It indicates that SMB1-based workgroup browsing was unavailable. SMB1 is an old protocol version, and modern configurations commonly disable it because of security concerns.

The important lesson is to read the entire output. A warning or informational message at the end does not automatically mean the whole command failed.

### 🧠 Extra lesson — What are these four shares?

- `ADMIN$` — A Windows administrative share, commonly associated with remote system administration.
- `C$` — A hidden administrative share that exposes the C: drive to appropriately authorized users.
- `IPC$` — A special share used for inter-process communication and certain network operations.
- `WorkShares` — A regular named share that contains the files we investigate in this machine.

Seeing a share in the list does not mean you have permission to access it. Enumeration and access are two different things.

---

## Task 5 — Counting the Shares

**Question:** How many shares are there on Dancing?

**Answer:** `4`

### 🔍 Process

I overthought this question. I stared at it, wondering whether it meant something more complicated than the obvious answer.

Then I looked at the output again and counted:

1. `ADMIN$`
2. `C$`
3. `IPC$`
4. `WorkShares`

I entered `4`, and it was correct.

### 📚 Lesson

Sometimes a cybersecurity question really is asking for exactly what it says. We don't need to invent a complicated interpretation when the command output already contains the answer.

A useful habit is to identify the evidence first, then answer the question based on that evidence.

**Evidence:** The `smbclient -L` output lists four share names.

**Conclusion:** There are four listed shares.

---

## Task 6 — Finding the Share Accessible with a Blank Password

**Question:** What is the name of the share we are able to access in the end with a blank password?

**Answer:** `WorkShares`

### 🔍 Process

I tried listing the server's shares while adding individual share names to the command:

```bash
sudo smbclient -L //10.129.49.78/WorkShares
```

I also tried:

```bash
sudo smbclient -L //10.129.49.78/ADMIN$
```

That command returned:

```text
do_connect: Connection to 10.129.49.78 failed (Error NT_STATUS_IO_TIMEOUT)
```

I tried `C$` and `IPC$` as well. The results didn't help me understand what I was doing wrong.

At that point, I wanted to solve it myself instead of immediately looking up the answer. I noticed that the `ADMIN$` attempt produced a different result, but I still didn't understand the timeout.

Eventually, I searched online and saw that the answer was `WorkShares`. I was confused because I thought I had already tried it, and it still hadn't worked.

The missing piece was the command I was using: I was continuing to include `-L`.

### 📚 Lesson — Listing a share is not the same as accessing it

This was the central misunderstanding of the machine.

When I ran:

```bash
smbclient -L //10.129.49.78
```

I was asking the server to list the shares.

When I added `/WorkShares` while keeping `-L`, I was still using the list-shares operation rather than opening the share for normal file browsing.

The command I actually needed was:

```bash
smbclient //10.129.49.78/WorkShares
```

When prompted for a password, I pressed Enter to submit a blank password.

That allowed me to connect to `WorkShares` in the lab.

### 💭 Note — Why did the other shares behave differently?

The different results did not necessarily mean that the commands were all doing the same thing.

- Some shares may be visible in the listing but require different permissions to access.
- Administrative shares such as `ADMIN$` and `C$` commonly require elevated credentials.
- `IPC$` is a special-purpose share and is not a normal folder containing the target files.
- A timeout such as `NT_STATUS_IO_TIMEOUT` means the expected network operation did not complete in time. It does not, by itself, identify the exact cause.

The target, network, permissions, and way the command was used can all affect the result. A timeout is not proof that a share exists, nor is it proof that the command syntax is wrong.

The practical lesson is to separate the operations:

1. **Enumerate:** Find out which shares are listed.
2. **Connect:** Attempt to open a specific share.
3. **Navigate:** Explore the directories available inside it.
4. **Retrieve:** Download the relevant file.

---

## Task 7 — Downloading Files Through SMB

**Question:** What is the command we can use within the SMB shell to download the files we find?

**Answer:** `get`

### 🔍 Process

I answered `get` because I remembered learning it during the previous machine, Fawn, where I used FTP.

That earlier experience helped me recognize the command here without having to look it up again.

### 📚 Lesson — Reusing knowledge from Fawn

The `get` command is used in both common `ftp` clients and `smbclient` to download a file from the remote system to the local machine.

For example, inside an SMB session:

```text
smb: \> get flag.txt
```

This downloads `flag.txt` to the local directory from which the client was launched, unless a different local destination has been specified.

One important distinction: `get` is a command **inside the interactive SMB client**, not a standalone Linux command that you run in an ordinary terminal.

This is a good example of transferable knowledge. Learning a command in one context can help you recognize it in another.

---

## Task 8 — Retrieving the Flag

**Question:** Submit the flag located on the SMB share.

**Answer:** `[Insert the accepted Dancing flag here]`

### 🔍 Process

At this point, I couldn't ignore the problem anymore. I wanted to understand why my commands weren't connecting to the share, so I compared what I was doing with the examples I found online.

Then I realized that I kept typing:

```bash
smbclient -L //10.129.49.78/WorkShares
```

I had continued using `-L`, even though I no longer wanted to list the shares. I wanted to connect to one.

I finally ran:

```bash
smbclient //10.129.49.78/WorkShares
```

I pressed Enter when prompted for a password, and this time I was in.

The client displayed:

```text
Try "help" to get a list of possible commands.
smb: \>
```

That prompt was the confirmation I needed: I was now inside the interactive SMB client, connected to the share.

I ran:

```text
ls
```

The output showed two directories:

```text
.          D
..         D
Amy.J      D
James.P    D
```

At first, I thought I could inspect a folder by typing `ls Amy.J`, so I tried that. It didn't show me the contents of the directory in the way I expected.

Then I used:

```text
cd Amy.J
ls
```

Inside `Amy.J`, I found:

```text
worknotes.txt
```

I downloaded it:

```text
get worknotes.txt
```

Then, in my regular Linux terminal, I read the downloaded file:

```bash
cat worknotes.txt
```

It contained:

```text
- start apache server on the linux machine
- secure the ftp server
- setup winrm on dancing
```

That wasn't the flag, so I returned to the SMB session and explored the other directory:

```text
cd ..
cd James.P
ls
```

I found `flag.txt`. I downloaded it:

```text
get flag.txt
```

Finally, in my regular Linux terminal, I read the downloaded flag:

```bash
cat flag.txt
```

And there it was!

### 📚 Lesson — Navigating an SMB share

Once connected to a share, `smbclient` provides an interactive shell with commands similar to those used in a normal terminal.

| Command | Purpose |
|---|---|
| `ls` | List files and directories in the current remote directory |
| `cd Amy.J` | Enter the remote directory named `Amy.J` |
| `cd ..` | Move to the parent remote directory |
| `get worknotes.txt` | Download a remote file |
| `help` | Show available SMB client commands |
| `exit` | Leave the SMB session |

The `D` shown beside `Amy.J` and `James.P` means they are directories. The `A` beside a regular file is an attribute marker, not part of the filename.

When I typed:

```text
ls Amy.J
```

I was still using the SMB client's directory-listing command, not a general Linux command for browsing arbitrary paths. Changing into the directory with `cd Amy.J` and then running `ls` was the clearer approach.

### 💭 Note — Why did `worknotes.txt` matter if it wasn't the flag?

The file was still useful evidence. It showed that I could successfully access and retrieve content from the share, and it contained notes about services and tasks associated with the machine.

But the objective was to find the flag, so I continued exploring rather than assuming the first file I found was the answer.

This is an important enumeration habit: inspect what you discover, understand its relevance, and keep investigating when the objective has not yet been met.

---

# 🧠 OVERALL LESSONS

## 1. Enumeration comes before exploitation

I first used Nmap to identify the service, then used `smbclient` to list available shares, and finally connected to the share that allowed access with a blank password.

That is a useful general workflow:

**Discover → Enumerate → Access → Explore → Retrieve evidence**

## 2. Understand the command before repeating it

My biggest obstacle was not a complicated vulnerability. It was using `-L` for an operation I no longer wanted to perform.

Before repeating a command, ask:

- What does each option do?
- Am I listing resources or connecting to one?
- Am I already inside an interactive client?
- What does the output actually tell me?

## 3. Errors are evidence, not just obstacles

The command-not-found error suggested that `smbclient` was not installed or was not available through my shell's command search path. The timeout showed that a network operation had not completed. The SMB1 message was informational and did not invalidate the share listing.

Different messages mean different things. Reading them carefully helps avoid guessing.

## 4. Don't install tools before checking whether they're installed

I searched for an installation command before verifying whether `smbclient` was present. I eventually ran:

```bash
which smbclient
```

A better first check is:

```bash
command -v smbclient
```

If it returns a path, the command is available. If it returns nothing, investigate whether the package is installed or whether the executable is missing from your `PATH`.

On Debian/Ubuntu-based systems, `smbclient` is generally provided by a package with that name.

## 5. Reuse previous knowledge

Fawn taught me about `get` in FTP. That helped me recognize the same command in the SMB client.

The protocols are different, but some client commands and concepts overlap. Every machine gives me knowledge I can carry into the next one.

---

# 📖 COMMAND REFERENCE

## Nmap

```bash
# Scan the target using default timing
sudo nmap -sV 10.129.49.78

# Use a more aggressive timing template
sudo nmap -sV -T4 10.129.49.78
```

## Check and install smbclient

```bash
# Check whether smbclient is available
command -v smbclient

# Install it on Debian/Ubuntu-based systems if needed
sudo apt update
sudo apt install smbclient
```

## List and connect to SMB shares

```bash
# List shares
smbclient -L //10.129.49.78

# Connect to a specific share
smbclient //10.129.49.78/WorkShares
```

When prompted for the password, submit a blank password only when that is appropriate for the authorized lab.

## Explore and download

Run these commands inside the interactive `smbclient` session:

```text
ls
cd Amy.J
ls
get worknotes.txt
cd ..
cd James.P
ls
get flag.txt
exit
```

After downloading the file, return to the normal Linux terminal:

```bash
cat flag.txt
```

**Remember:** `ls`, `cd`, and `get` are being interpreted by `smbclient` while you see the `smb: \>` prompt. `cat` is a Linux command that you run in your regular terminal.

---

# 🔁 REVIEW PLAN

### Tomorrow — quick recall

Try answering these without looking at the notes:

1. What does SMB stand for?
2. Which TCP port is commonly used by SMB?
3. What does `-sV` do in Nmap?
4. What does Nmap's `-T4` timing template change?
5. What does `smbclient -L` do?
6. How do you connect directly to a specific SMB share?
7. What does a blank password mean in this lab?
8. Which SMB client command downloads a file?
9. How do you enter a remote directory?
10. Why might a listed share still be inaccessible?

### Later review — practical recall

Repeat the workflow in an authorized lab without copying the commands from these notes:

1. Scan the target.
2. Identify SMB.
3. List the shares.
4. Connect to the accessible share.
5. Explore its directories.
6. Download and inspect the relevant file.

The goal is not just to remember the flag. It is to understand the sequence well enough to reproduce it.

---

# 💭 PERSONAL REFLECTION

This machine challenged me in a different way from the previous ones.

I could identify the share listing and even find the correct share name, but I kept repeating a command that didn't match what I wanted to do. I also tried guessing, used `sudo` unnecessarily, and nearly gave up on understanding the problem.

The turning point was recognizing the difference between listing a share and connecting to it. Once I corrected that misunderstanding, the rest of the process became much clearer.

I also learned that I don't need to understand every line of output immediately. I need to slow down, identify what I know, test one thing at a time, and make each command answer a specific question.

**The biggest win today wasn't just finding the flag. It was figuring out why I wasn't getting anywhere.**

---

# 🤖 MY ASSESSMENT

Dancing introduced an important practical skill: **SMB enumeration and share access**.

The key lesson was the difference between:

```bash
smbclient -L //SERVER
```

and:

```bash
smbclient //SERVER/SHARE
```

That distinction is foundational when investigating Windows file-sharing services. You also practiced service detection, interpreting command output, navigating a remote directory tree, and downloading files.

One thing to improve next time is your troubleshooting process. Before installing a tool or searching for a complete solution, check whether the tool exists, read the error carefully, and simplify the command to match your immediate goal. That will help you become more independent as the machines become harder.

You did not need to know everything in advance. You needed to keep asking the right questions until the pieces made sense.

**Day 03: Dancing — completed. One machine, one more set of skills, and one more entry in the FieldKit learning journey.**

*Documentation reminder: replace the flag placeholder above with the exact flag accepted by HTB before publishing this file as `HTB/Dancing.md`.*
