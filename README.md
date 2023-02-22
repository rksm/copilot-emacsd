# Copilot setup for Emacs

This accompanies this [blog post](https://robert.kra.hn/posts/2023-02-22-copilot-emacs-setup/).

This is a ready-to-roll setup based on [zerolfx/copilot.el](https://github.com/zerolfx/copilot.el).
It customizes Copilot a bit to be more convenient (for me at least).
Some features:

- Show or accept completion by pressing `M-C-<return>`
- Complete a single word by pressing `M-C-<right>`
- Complete a line by pressing `M-C-<down>`
- Next completion option: `M-C-<next>` (page down)
- Prev completion option: `M-C-<prior>` (page up)
- Deactivate Copilot for some modes by default
- Switch between auto / manual / absolutely no completion with `M-C-<escape>`
- Ctrl-g cancels completion but does not interfere otherwise with normal keybindings
- `<right>` (right arrow) accepts completion

## Installation

```bash
# clone this repo
git clone https://github.com/rksm/copilot-emacsd.git
cd copilot-emacsd
git submodule update --init --recursive
```

You can start with this setup without interfering with your existing Emacs config by running:

```bash
emacs -Q -l path/to/copilot-emacsd/init.el
```
