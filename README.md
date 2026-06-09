
<h1 align="center">ani-cli-adv</h1>

<h3 align="center">
A CLI to browse and watch anime (alone AND with friends). This tool scrapes <a href="https://allanime.day/">allanime.day</a>.
</h3>

**Upstream:** `ani-cli-adv` is a fork of the original [`ani-cli`](https://github.com/pystardust/ani-cli/) by pystardust. This README, the install snippets, and the binary name all refer to **this fork**. Where behavior is unchanged from upstream, links to the original project are preserved.

<h1 align="center">
	Showcase
</h1>

[ani-cli-demo.webm](https://user-images.githubusercontent.com/44473782/224679247-0856e652-f187-4865-bbcf-5a8e5cf830da.webm)

## Table of Contents

- [Version](#version)
- [Fixing errors](#fixing-errors)
- [Install](#install)
  - [Windows](#windows)
  - [Linux / macOS / BSD (from source)](#installing-from-source-linux--macos--bsd)
- [Uninstall](#uninstall)
- [Dependencies](#dependencies)
  - [Ani-Skip](#ani-skip)
- [FAQ](#faq)
- [Homies](#homies)
- [Contribution Guidelines](./CONTRIBUTING.md)
- [Disclaimer](./disclaimer.md)

## Version

Current version: `4.10.5-adv2` (based on upstream `ani-cli` 4.10.4).

### Added / changed in this fork

- Favorites: mark a series as favorite from the in-player menu (`favorite` / `unfavorite`) and store them under `~/.local/state/ani-cli/favorites`.
- Last watched / Resume: remember all watched series and episodes, offering a `Last played` list on interactive startup with the ability to resume from where you left off.
- Startup menu: when launched interactively with no query, show a menu with `Last played`, `Favorites`, and `Search`.
- Remove from last played: remove individual series from the last played list via the in-player menu option `remove_from_last_played`.
- CLI name: install and use this fork as `ani-cli-adv` (binary and manpage), keeping credits pointing to the upstream `ani-cli` project.
- API restored: ported the upstream switch to POST/JSON GraphQL calls plus AES-256-CTR `tobeparsed` decryption, so search, episode listing, and source resolution work again against the current AllAnime API.
- Windows usage: simplified docs and guidance for running via Git Bash.
- README cleanup: removed most distro-specific packaging details, normalized install snippets across platforms, and documented the new features of this fork.

## Fixing errors

If you encounter `No results found` (and are sure the prompt was correct) or any breaking issue, then make sure you are on **latest version** by typing
`sudo ani-cli-adv -U` to update on Linux, Mac and Android. On Windows, run `ani-cli-adv -U`.
If after this the issue persists then open an issue.

## Install

### Windows

The recommended setup is **Windows Terminal + Git Bash + Scoop for dependencies**. Run each block in the shell indicated by its comment.

#### 1. Install Scoop (skip if you already have it)

In **PowerShell**:

```powershell
# Allow running the installer for the current user, then bootstrap Scoop
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```

#### 2. Install Windows Terminal, Git, and runtime dependencies

In **PowerShell**:

```powershell
scoop bucket add extras
scoop install extras/windows-terminal
scoop install git fzf mpv ffmpeg
# Optional, for the -d (download) feature:
scoop install yt-dlp aria2
```

> `scoop install ani-cli` installs the **upstream** project — not this fork. Skip it. The fork ships as `ani-cli-adv` and can coexist with upstream if you want both.

Open Windows Terminal and add a Git Bash profile (Settings → Add a new profile → Duplicate → command: `"C:\Program Files\Git\bin\bash.exe" -li`). All remaining steps run in a **Git Bash** tab.

#### 3. Install ani-cli-adv

In **Git Bash**:

```sh
git clone https://github.com/ms4ndst/ani-cli-adv.git ~/.ani-cli-adv
mkdir -p ~/bin
cp ~/.ani-cli-adv/ani-cli-adv ~/bin/ani-cli-adv
chmod +x ~/bin/ani-cli-adv

# Ensure ~/bin is on PATH for future shells
grep -qxF 'export PATH="$HOME/bin:$PATH"' ~/.bashrc 2>/dev/null \
    || echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
export PATH="$HOME/bin:$PATH"
```

#### 4. Verify

```sh
ani-cli-adv -h
```

If you see the help text, you're done. To update later, run `ani-cli-adv -U`.

#### Running the smoke tests (Git Bash)

```sh
cd ~/.ani-cli-adv
sh tests/smoke-favorites.sh
sh tests/smoke-lastwatched.sh
sh tests/smoke-search.sh    # live API check: search, episode list, decryption
```

#### Windows: Known Problems

If you have a problem, first update with `ani-cli-adv -U`. Then check the list below.

- **Stuck in "Search anime:"** — This happens with the mintty terminal that Git Bash uses by default. Either run from a Git Bash tab inside **Windows Terminal** (recommended) or, if you must stick with mintty, run `export MSYS=enable_pcon` before `ani-cli-adv`.
- **"No such file or directory" / WSL errors when launching from PowerShell or cmd** — WSL's `bash.exe` is being picked up instead of Git's. Run `ani-cli-adv` from a **Git Bash** tab. If you must launch from PowerShell, invoke it explicitly: `& "C:\Program Files\Git\bin\bash.exe" -lc "ani-cli-adv"`.
- **Old curl** — curl `7.83.1` is known broken; `7.86.0`+ works. Git for Windows ships a recent curl, so this only bites if an older one is earlier on PATH. Run `which curl` in Git Bash to confirm.
- **mpv config location** — If you installed mpv via Scoop, mpv reads its config from `%USERPROFILE%\scoop\apps\mpv\current\portable_config`. See the [mpv portable_config docs](https://mpv.io/manual/stable/).

### Installing from source (Linux / macOS / BSD)

*Baseline POSIX install. For Windows, use the section above instead.*

Install dependencies [(See below)](#dependencies)

```sh
git clone "https://github.com/ms4ndst/ani-cli-adv.git" ani-cli-adv
sudo cp ani-cli-adv/ani-cli-adv /usr/local/bin
rm -rf ani-cli-adv
```

<details><summary><b>WSL</b></summary>

Follow the installation instructions of your Linux distribution.

Note that the media player (mpv or vlc) will need to be installed on Windows, not WSL. See the justification for this in the comment [(here)](https://github.com/pystardust/ani-cli/issues/1266#issuecomment-1926945757). Instructions on how to use the media player from WSL instead are also included in the linked comment.

When installing the media player on Windows, make sure that it is on the Windows Path. An easy way to ensure this is to download the media player with a package manager (on Windows, not WSL) such as scoop.

</details><details><summary><b>iOS</b></summary>

Install iSH and VLC from the app store.

Make sure apk is updated using
```apk update; apk upgrade```
then run this:
```sh
apk add grep sed curl fzf git aria2 ncurses patch
apk add ffmpeg
git clone --depth 1 https://github.com/ms4ndst/ani-cli-adv.git ~/.ani-cli-adv
cp ~/.ani-cli-adv/ani-cli-adv /usr/local/bin/ani-cli-adv
chmod +x /usr/local/bin/ani-cli-adv
rm -rf ~/.ani-cli-adv
```
note that downloading is going to be very slow. This is an iSH issue, not an `ani-cli-adv` issue.
</details>

<details><summary><b>Steam Deck</b></summary>

#### Copypaste script:

* Switch to Desktop mode (`STEAM` Button > Power > Switch to Desktop)
* Open `Konsole` (Steam Deck Icon in bottom left corner > System > Konsole)
* Copy the script, paste it in the CLI and press Enter("A" button on Steam Deck)

```sh
[ ! -d ~/.local/bin ] && mkdir ~/.local/bin && echo "export PATH=$HOME/.local/bin:\$PATH" >> ".$(echo $SHELL | sed -nE "s|.*/(.*)\$|\1|p")rc"

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

mkdir ~/.aria2c
curl -o ~/.aria2c/aria2-1.36.0.tar.bz2 https://github.com/q3aql/aria2-static-builds/releases/download/v1.36.0/aria2-1.36.0-linux-gnu-64bit-build1.tar.bz2
tar xvf ~/.aria2c/aria2-1.36.0.tar.bz2 -C ~/.aria2c/
cp ~/.aria2c/aria2-1.36.0-linux-gnu-64bit-build1/aria2c ~/.local/bin/
chmod +x ~/.local/bin/aria2c

curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o ~/.local/bin/yt-dlp
chmod +x ~/.local/bin/yt-dlp

mkdir ~/.patch
curl -o ~/.patch/patch.tar.zst https://mirror.sunred.org/archlinux/core/os/x86_64/patch-2.8-1-x86_64.pkg.tar.zst
tar xvf ~/.patch/patch.tar.zst -C ~/.patch/
cp ~/.patch/usr/bin/patch ~/.local/bin/

git clone https://github.com/ms4ndst/ani-cli-adv.git ~/.ani-cli-adv
cp ~/.ani-cli-adv/ani-cli-adv ~/.local/bin/ani-cli-adv

flatpak install io.mpv.Mpv
```
press enter("A" button on Steam Deck) on questions

#### Installation in steps:

##### Install mpv (Flatpak version):

```sh
flatpak install io.mpv.Mpv
```
press enter("A" button on Steam Deck) on questions

##### Install [fzf](https://github.com/junegunn/fzf):

```sh
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```
press enter("A" button on Steam Deck) on questions

##### Make a ~/.local/bin folder if doesn't exist and add it to $PATH

```sh
[ ! -d ~/.local/bin ] && mkdir ~/.local/bin && echo "export PATH=$HOME/.local/bin:\$PATH" >> ".$(echo $SHELL | sed -nE "s|.*/(.*)\$|\1|p")rc"
```

##### Install [aria2](https://github.com/aria2/aria2) (needed for download feature only):

```sh
mkdir ~/.aria2c
curl -o ~/.aria2c/aria2-1.36.0.tar.bz2 https://github.com/q3aql/aria2-static-builds/releases/download/v1.36.0/aria2-1.36.0-linux-gnu-64bit-build1.tar.bz2
tar xvf ~/.aria2c/aria2-1.36.0.tar.bz2 -C ~/.aria2c/
cp ~/.aria2c/aria2-1.36.0-linux-gnu-64bit-build1/aria2c ~/.local/bin/
chmod +x ~/.local/bin/aria2c
```

##### Install [yt-dlp](https://github.com/yt-dlp/yt-dlp) (needed for download feature only):

```sh
curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o ~/.local/bin/yt-dlp
chmod +x ~/.local/bin/yt-dlp
```

##### Install [patch](https://savannah.gnu.org/projects/patch/) (needed for self-update feature [ -U ] ):

```sh
mkdir ~/.patch
curl -o ~/.patch/patch.tar.zst https://mirror.sunred.org/archlinux/core/os/x86_64/patch-2.8-1-x86_64.pkg.tar.zst
tar xvf ~/.patch/patch.tar.zst -C ~/.patch/
cp ~/.patch/usr/bin/patch ~/.local/bin/
```

##### Install ani-cli-adv:

```sh
git clone https://github.com/ms4ndst/ani-cli-adv.git ~/.ani-cli-adv
cp ~/.ani-cli-adv/ani-cli-adv ~/.local/bin/ani-cli-adv
```

##### Optional: add desktop entry:

```
echo '[Desktop Entry]
Encoding=UTF-8
Type=Application
Exec=bash -c "source $HOME/.'$(echo $SHELL | sed -nE "s|.*/(.*)\$|\1|p")'rc && konsole --fullscreen -e ani-cli-adv"
Name=ani-cli-adv' > $HOME/.local/share/applications/ani-cli-adv.desktop
```
The .desktop entry will allow you to start `ani-cli-adv` in Konsole directly from "Gaming Mode".
In Steam Desktop app:
`Add game` > `Add a non-steam game` > tick a box for `ani-cli-adv` > `Add selected programs`
</details>

<details><summary><b>FreeBSD</b></summary>

#### Copypaste script:

```sh
sudo pkg install mpv fzf aria2 yt-dlp patch git
git clone "https://github.com/ms4ndst/ani-cli-adv.git" ani-cli-adv
sudo cp ani-cli-adv/ani-cli-adv /usr/local/bin/ani-cli-adv
rm -rf ani-cli-adv
```

#### Installation in steps:

##### Install dependencies:

```sh
sudo pkg install mpv fzf aria2 yt-dlp patch
```

##### Install ani-cli-adv:

install git if you haven't already

```sh
sudo pkg install git
```

install from source:

```sh
git clone "https://github.com/ms4ndst/ani-cli-adv.git" ani-cli-adv
sudo cp ani-cli-adv/ani-cli-adv /usr/local/bin/ani-cli-adv
rm -rf ani-cli-adv
```

#### Linux: fixing `permission denied` when running `ani-cli-adv`

If you see `zsh: permission denied: ani-cli-adv` (or similar) after installing:

```sh
sudo chmod 755 /usr/local/bin/ani-cli-adv
ls -l /usr/local/bin/ani-cli-adv   # should show -rwxr-xr-x
```

If the file came from a Windows checkout and has CRLF line endings, also run:

```sh
sudo dos2unix /usr/local/bin/ani-cli-adv
sudo chmod 755 /usr/local/bin/ani-cli-adv
```

</details>

## Uninstall

- Linux / macOS / BSD:
```sh
sudo rm /usr/local/bin/ani-cli-adv
```

- Windows (Git Bash):
```sh
rm ~/bin/ani-cli-adv
rm -rf ~/.ani-cli-adv
# Optional: remove the PATH line we added in step 3
sed -i '/export PATH="\$HOME\/bin:\$PATH"/d' ~/.bashrc
```

## Dependencies

- `grep`
- `sed`
- `curl`
- `mpv` - Video Player
- `iina` - mpv replacement for MacOS
- `aria2c` - Download manager
- `yt-dlp` - m3u8 Downloader
- `ffmpeg` - m3u8 Downloader (fallback)
- `fzf` - User interface
- `ani-skip` (optional)
- `patch` - Self updating

### Ani-Skip

Ani-skip is a script to automatically skip anime opening sequences, making it easier to watch your favorite shows without having to manually skip the intros each time (from the original [README](https://github.com/synacktraa/ani-skip/tree/master#a-script-to-automatically-skip-anime-opening-sequences-making-it-easier-to-watch-your-favorite-shows-without-having-to-manually-skip-the-intros-each-time)).

For install instructions visit [ani-skip](https://github.com/synacktraa/ani-skip).

Ani-skip uses the external lua script function of mpv and as such – for now – only works with mpv.

**Warning:** For now, ani-skip does **not** seem to work under Windows.

**Note:** It may be, that ani-skip won't know the anime you're trying to watch. Try using the `--skip-title <title>` command line argument. (It uses the [aniskip API](https://github.com/lexesjan/typescript-aniskip-extension/tree/main/src/api/aniskip-http-client) and you can contribute missing anime or ask for including it in the database on their [discord server](https://discord.com/invite/UqT55CbrbE)).

## Favorites and Last Played

### Favorites
- **Add/Remove**: While watching, open the in-player menu and select `favorite` or `unfavorite` to toggle the current series.
- **View at startup**: Select `Favorites` from the startup menu to see all your favorited series.
- **Storage**: Stored at `$ANI_CLI_HIST_DIR/favorites` (default: `~/.local/state/ani-cli/favorites`). One entry per line: `<id>\t<title>`.

### Last Played
- **Automatic tracking**: All watched series and episodes are automatically recorded in `$ANI_CLI_HIST_DIR/last` as `<id>\t<title>\t<episode>`.
- **Resume watching**: 
  1. Launch `ani-cli-adv` without any arguments
  2. Select `Last played` from the startup menu
  3. Choose any series from the list to resume from where you left off
- **Remove series**: 
  1. Start watching any series (or resume it)
  2. After an episode finishes, the menu appears
  3. Select `remove_from_last_played` to remove the current series from the list
- **Disable startup menu**: Set `ANI_CLI_STARTUP_MENU=0` to skip the menu and go straight to search.

## FAQ
<details>
	
* Can I change subtitle language or turn them off? - No, the subtitles are baked into the video.
* Can I watch dub? - Yes, use `--dub`.
* Can I change dub language? - No.
* Can I change media source? - No (unless you can scrape that source yourself).
* Can I use vlc? - Yes, use `--vlc` or `export ANI_CLI_PLAYER=vlc`.
* Can I adjust resolution? - Yes, use `-q resolution`, for example `ani-cli-adv -q 1080`.
* How can I download? - Use `-d`, it will download into your working directory.
* Can i change download folder? - Yes, set the `ANI_CLI_DOWNLOAD_DIR` to your desired location.
* How can I bulk download? - `Use -d -e firstepisode-lastepisode`, for example `ani-cli-adv onepiece -d -e 1-1000`.

**Note:** All features are documented in `ani-cli-adv --help`.

</details>

## Homies

* [animdl](https://github.com/justfoolingaround/animdl): Ridiculously efficient, fast and light-weight (supports most sources: allmanga, zoro ... (Python)
* [jerry](https://github.com/justchokingaround/jerry): stream anime with anilist tracking and syncing, with discord presence (Shell)
* [anipy-cli](https://github.com/sdaqo/anipy-cli): ani-cli rewritten in python (Python)
* [mangal](https://github.com/metafates/mangal): Download & read manga from any source with anilist sync (Go)
* [lobster](https://github.com/justchokingaround/lobster): Watch movies and series from the terminal (Shell)
* [mov-cli](https://github.com/mov-cli/mov-cli): Watch everything from your terminal. (Python)
* [dra-cla](https://github.com/CoolnsX/dra-cla): ani-cli equivalent for korean dramas (Shell)
* [redqu](https://github.com/port19x/redqu):  A media centric reddit client (Clojure)
* [doccli](https://github.com/TowarzyszFatCat/doccli):  A cli to watch anime with POLISH subtitles (Python)
* [GoAnime](https://github.com/alvarorichard/GoAnime): A CLI tool to browse, play, and download anime in Portuguese(Go)
* [Curd](https://github.com/Wraient/curd): A CLI tool to watch anime with Anilist, Discord RPC, Skip Intro/Outro/Filler/Recap (Go)
* [FastAnime](https://github.com/Benex254/FastAnime): browser anime experience from the terminal (Python)
* [ani-skip](https://github.com/KilDesu/ani-skip): Automatically skip opening and ending sequences for IINA on MacOS (Typescript, official IINA plugin API)

## Contribution Guidelines

See [CONTRIBUTING.md](./CONTRIBUTING.md) for details on how to open issues and submit pull requests.

## Disclaimer

See [disclaimer.md](./disclaimer.md) for legal and usage disclaimers related to this project.
