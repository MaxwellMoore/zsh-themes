# mlm-powerline — A Custom Powerline-Style ZSH Prompt Theme

`mlm-powerline` is a clean, expressive, powerline-style ZSH prompt theme built for **oh-my-zsh**.  
It provides an elegant command-line interface with clear sections for:

- **User**
- **Directory**
- **Git branch**
- **Git status icons** (clean, dirty, staged, untracked, ahead/behind, diverged)

This repository contains multiple themes, but all examples and documentation here use **mlm-powerline**.

---

## ✨ Features

### ✔ Powerline-inspired segment separators  
Using icons like ``, the prompt flows smoothly from segment to segment.

### ✔ Smart Git segment  
The theme detects Git repositories and displays:

| State | Icons | Description |
|-------|--------|-------------|
| **Clean** | `` | No changes, no untracked files |
| **Dirty** | `` | Modified or unstaged files |
| **Staged** | `` | Staged for commit |
| **Untracked** | `` | Untracked files |
| **Ahead/Behind/Diverged** | ``, ``, `` | Comparison to upstream |

### ✔ Adaptive background colors  
Git segments use distinct background colors for **clean** vs. **dirty** working trees.

### ✔ Simple structure  
The theme is composed of bite-sized rendering functions:

- `render_joint`  
- `render_segment`  
- `render_end_segment`  
- `segment_user`  
- `segment_dir`  
- `segment_git`

---

## 🖼 Prompt Anatomy Diagram

```
┌───────────────────┬────────────────────────┬─────────────────────────────┐
│     USER           │       DIRECTORY        │            GIT              │
├───────────────────┼────────────────────────┼─────────────────────────────┤
│ username           │ ~/current/path         │  main                    │
│ (grey bg)          │ (blue bg)              │ (branch + status icons)     │
└───────────────────┴────────────────────────┴─────────────────────────────┘
```

### Git Variants
The Git segment will appear in one of three states:

| Variant | Example | Description |
|---------|----------|-------------|
| **Standard (no-git)** | `user ~/dir` | No repository detected |
| **git-clean** | ` main ` | Clean working tree |
| **git-dirty** | ` main   ` | Dirty, staged, untracked changes |

---

## 📦 Installation

### 1. Clone this repository

```bash
git clone https://github.com/yourusername/zsh-themes.git ~/.zsh-themes
```

### 2. Symlink or copy the theme file

```bash
ln -s ~/.zsh-themes/mlm-powerline.zsh-theme ~/.oh-my-zsh/custom/themes/mlm-powerline.zsh-theme
```

### 3. Enable the theme

Edit your `~/.zshrc`:

```bash
ZSH_THEME="mlm-powerline"
```

Reload ZSH:

```bash
source ~/.zshrc
```

---

## 🎨 Customization

You can adjust:

- Colors  
- Icons  
- Ordering of segments  
- Git logic  

Inside the theme, the top section includes constants that you can modify:

```zsh
WHITE=15
GREY=238
BLUE=12
PURPLE=93
GREEN=71
YELLOW=220
TEXT_COLOR=$WHITE
USER_COLOR=$GREY
DIR_COLOR=$BLUE
GIT_COLOR=$PURPLE
```

---

## 🧠 How It Works

The theme builds your prompt in three parts:

### 1. **User segment**

```zsh
segment_user() {
  render_segment $USER_COLOR $TEXT_COLOR "%n"
  render_joint $USER_COLOR $DIR_COLOR
}
```

### 2. **Directory segment**

```zsh
segment_dir() {
  render_segment $DIR_COLOR $TEXT_COLOR "%~"
  # If in git repo, join to git segment
}
```

### 3. **Git segment**  
Smart detection + icons + color transitions.

---

## 🤝 Contributing

If you want to add new themes or extend this one, feel free to open a PR or issue!

---

## 📜 License

MIT License. Free to use, modify, and distribute.

---

Enjoy your clean, expressive command line with **mlm-powerline**! 🎉
