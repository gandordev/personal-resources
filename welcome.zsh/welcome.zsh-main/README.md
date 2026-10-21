# Custom Ubuntu WSL Welcome Screen for Zsh

This guide documents how to create a professional welcome screen for Ubuntu on WSL using `zsh`.

The welcome screen includes:

- Ubuntu ASCII logo on terminal startup
- Dynamic greeting based on the time of day
- Live clock
- Date and weather
- System information
- Project directory
- Workspace list
- Recent Cursor / VS Code commands
- Cursor-focused development tips

---

## 1. Requirements

This setup assumes:

- You are using Ubuntu on WSL
- Your shell is `zsh`
- Your projects live in:

```bash
~/projects/
````

* Your workspaces live in:

```bash
~/projects/.workspaces/
```

Workspace files can be files such as:

```bash
backoffice.code-workspace
entities.code-workspace
notis.code-workspace
```

---

## 2. Check that you are using zsh

Run:

```bash
echo $SHELL
```

You should see something like:

```bash
/usr/bin/zsh
```

If not, install and enable `zsh`:

```bash
sudo apt update
sudo apt install zsh -y
chsh -s $(which zsh)
```

Then restart WSL from PowerShell or CMD:

```powershell
wsl --shutdown
```

Open Ubuntu again.

---

## 3. Create the required folders

Create the projects folder:

```bash
mkdir -p ~/projects/
```

Create the workspaces folder:

```bash
mkdir -p ~/projects/.workspaces/
```

Example workspace files may look like this:

```bash
~/projects/.workspaces/backoffice.code-workspace
~/projects/.workspaces/entities.code-workspace
~/projects/.workspaces/notis.code-workspace
```

---

## 4. Install optional dependencies

The welcome screen can show the weather using `curl`.

Install it with:

```bash
sudo apt update
sudo apt install curl -y
```

If `curl` is not installed or there is no internet connection, the weather will simply show as unavailable.

---

## 5. Create the welcome script

Create the config folder:

```bash
mkdir -p ~/.config/welcome
```

Create the welcome script:

```bash
nano ~/.config/welcome/welcome.zsh
```

Paste the script from `welcome.zsh`

Save the file:

```text
Ctrl + O
Enter
Ctrl + X
```

---

## 6. Make the script executable

Run:

```bash
chmod +x ~/.config/welcome/welcome.zsh
```

---

## 7. Load the welcome screen from `.zshrc`

Open your `.zshrc`:

```bash
nano ~/.zshrc
```

Add this at the end:

```zsh
# Professional welcome screen
if [[ -f "$HOME/.config/welcome/welcome.zsh" ]]; then
  source "$HOME/.config/welcome/welcome.zsh"
fi
```

Save:

```text
Ctrl + O
Enter
Ctrl + X
```

---

## 8. Reload zsh

Run:

```bash
exec zsh
```

Or close and reopen your Ubuntu WSL terminal.

---

## 9. Test workspaces

List your workspaces:

```bash
ls -l ~/projects/.workspaces/
```

Example output:

```text
altausuario-keycloak.code-workspace
backoffice.code-workspace
dominios-buscador.code-workspace
entities.code-workspace
notis.code-workspace
spam-and-events-consumer.code-workspace
```

The welcome screen should display them as:

```text
› altausuario-keycloak → cursor ~/projects/.workspaces/altausuario-keycloak.code-workspace
› backoffice → cursor ~/projects/.workspaces/backoffice.code-workspace
› dominios-buscador → cursor ~/projects/.workspaces/dominios-buscador.code-workspace
```

---

## 10. Test recent Cursor / VS Code commands

Run a few commands:

```bash
cursor ~/projects/
cursor .
code .
```

Then reload:

```bash
exec zsh
```

The welcome screen should show them under:

```text
Shall we continue where you left off?
```

---

## 11. Useful aliases

Optionally, add these aliases to your `.zshrc`:

```zsh
alias editwelcome='nano ~/.config/welcome/welcome.zsh'
alias reloadzsh='exec zsh'
alias projects='cd ~/projects/'
alias workspaces='cd ~/projects/.workspaces/'
```

Then reload:

```bash
exec zsh
```

Now you can edit the welcome screen with:

```bash
editwelcome
```

Reload zsh with:

```bash
reloadzsh
```

Jump to your projects folder with:

```bash
projects
```

Jump to your workspaces folder with:

```bash
workspaces
```

---

## 12. Disable the welcome screen

Open `.zshrc`:

```bash
nano ~/.zshrc
```

Comment this block:

```zsh
# if [[ -f "$HOME/.config/welcome/welcome.zsh" ]]; then
#   source "$HOME/.config/welcome/welcome.zsh"
# fi
```

Reload:

```bash
exec zsh
```

---

## 13. Notes

The live clock updates the `Time` field in the welcome panel.

The script automatically detects the real row where the `Time` field is printed, so it should not overwrite other fields such as `Kernel`, `Shell`, or `Memory`.

The weather uses:

```bash
https://wttr.in
```

with a short timeout so terminal startup does not become slow.

The welcome screen stops the live clock when you run your first command, which avoids visual glitches while working in the terminal.
