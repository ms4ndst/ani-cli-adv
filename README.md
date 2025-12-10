<p align=center>
<br>
<a href="http://makeapullrequest.com"><img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg"></a>
<a href="#Linux"><img src="https://img.shields.io/badge/os-linux-brightgreen">
<a href="#MacOS"><img src="https://img.shields.io/badge/os-mac-brightgreen">
<a href="#Android"><img src="https://img.shields.io/badge/os-android-brightgreen">
<a href="#Windows"><img src="https://img.shields.io/badge/os-windows-yellowgreen">
<a href="#iOS"><img src="https://img.shields.io/badge/os-ios-yellow">
<a href="#Steam-deck"><img src="https://img.shields.io/badge/os-steamdeck-yellow">
<br>
<h1 align="center">
<a href="https://discord.gg/aqu7GpqVmR"><img src="https://invidget.switchblade.xyz/aqu7GpqVmR"></a>
<a href="matrix.md"><img src="/.assets/matrix-logo.svg" height=110></a>
<br>
<a href="https://github.com/port19x"><img src="https://img.shields.io/badge/lead-port19x-lightblue"></a>
<a href="https://github.com/CoolnsX"><img src="https://img.shields.io/badge/maintainer-CoolnsX-blue"></a>
<a href="https://github.com/justchokingaround"><img src="https://img.shields.io/badge/maintainer-justchokingaround-blue"></a>
<a href="https://github.com/Derisis13"><img src="https://img.shields.io/badge/maintainer-Derisis13-blue"></a>
<a href="https://github.com/71zenith"><img src="https://img.shields.io/badge/maintainer-71zenith-blue"></a>
<a href="https://github.com/ykhan21"><img src="https://img.shields.io/badge/maintainer-ykhan21-blue"></a>

</p>

<h3 align="center">
A cli to browse and watch anime (alone AND with friends). This tool scrapes the site <a href="https://allmanga.to/">allmanga.</a>
</h3>

<h1 align="center">
	Showcase
</h1>

[ani-cli-demo.webm](https://user-images.githubusercontent.com/44473782/224679247-0856e652-f187-4865-bbcf-5a8e5cf830da.webm)

## Table of Contents

- [Fixing errors](#fixing-errors)
- [Install](#install)
  - [From Source](#installing-from-source)
- [Uninstall](#uninstall)
- [Dependencies](#dependencies)
  - [Ani-Skip](#ani-skip)
- [FAQ](#faq)
- [Homies](#homies)
- [Contribution Guidelines](./CONTRIBUTING.md)
- [Disclaimer](./disclaimer.md)

## Fixing errors

If you encounter `No results found` (and are sure the prompt was correct) or any breaking issue, then make sure you are on **latest version** by typing
`sudo ani-cli -U` to update on Linux, Mac and Android. On Windows, run `ani-cli -U`.
If after this the issue persists then open an issue.

## Install

### Installing from source

*This method works for any unix-like operating system and is a baseline for porting efforts.*

Install dependencies [(See below)](#dependencies)

```sh
git clone "https://github.com/pystardust/ani-cli.git"
sudo cp ani-cli/ani-cli /usr/local/bin
rm -rf ani-cli
```

##### Running the smoke tests on Windows
- From Git Bash:
```sh
sh tests/smoke-favorites.sh
sh tests/smoke-lastwatched.sh
```

#### Windows: Known Problems and Solutions

If you have a problem, please update ani-cli to the latest version with `ani-cli -U`. If you still have a problem, please read further.

- Stuck in "Search anime:". This shouldn't happen if you are using the Windows Terminal + Bash setup described above. It happens if you are using the Git Bash terminal (i.e., the mintty terminal). This is a problem between fzf and mintty, which should be resolved in future versions of fzf. For the time being, either use the Windows Terminal setup described above or, if you are dead-set on using the mintty terminal, run `export MSYS=enable_pcon` before running ani-cli.
- "No such file or directory" or WSL-related errors: This shouldn't happen if you are using the Window Terminal + Bash setup described above. This happens if you run ani-cli in powershell or cmd. This is due WSL's bash.exe being called instead of Git for Windows' bash.exe in `%USERPROFILE%\scoop\shims\ani-cli.cmd`. If you must use powershell or cmd, edit the `%USERPROFILE%\scoop\shims\ani-cli.cmd` file. In File Explorer, go to the `C:\Users\USERNAME\scoop\shims` directory and open the `ani-cli.cmd` file with notepad. Next:
    - If you installed git with scoop, replace `@bash` with `@"%GIT_INSTALL_ROOT%\bin\bash.exe"`, or
    - If you installed git by other means, replace `@bash` with `@"C:\Program Files\Git\bin\bash.exe"`.
This should be fixed if the ani-cli scoop manifest gets updated in [this PR](https://github.com/ScoopInstaller/Extras/pull/13342).
- curl can cause issues. ani-cli has been tested unsuccessfully with curl `7.83.1` and successfully with `7.86.0`. If you run into issues, try installing a newer one with scoop.
- If you installed mpv with scoop, your mpv configuration will get read from `C:\Users\USERNAME\scoop\apps\mpv\current\portable_config`. See [the mpv documentation](https://mpv.io/manual/stable/) regarding `portable_config` for more details.

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
git clone --depth 1 https://github.com/pystardust/ani-cli ~/.ani-cli
cp ~/.ani-cli/ani-cli /usr/local/bin/ani-cli
chmod +x /usr/local/bin/ani-cli
rm -rf ~/.ani-cli
```
note that downloading is going to be very slow. This is an iSH issue, not an ani-cli issue.
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

git clone https://github.com/pystardust/ani-cli.git ~/.ani-cli
cp ~/.ani-cli/ani-cli ~/.local/bin/

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

##### Install ani-cli:

```sh
git clone https://github.com/pystardust/ani-cli.git ~/.ani-cli
cp ~/.ani-cli/ani-cli ~/.local/bin/
```

##### Optional: add desktop entry:

```
echo '[Desktop Entry]
Encoding=UTF-8
Type=Application
Exec=bash -c "source $HOME/.'$(echo $SHELL | sed -nE "s|.*/(.*)\$|\1|p")'rc && konsole --fullscreen -e ani-cli"
Name=ani-cli' > $HOME/.local/share/applications/ani-cli.desktop
```
The .desktop entry will allow to start ani-cli in Konsole directly from "Gaming Mode"
In Steam Desktop app:
`Add game` > `Add a non-steam game` > tick a box for `ani-cli` > `Add selected programs`
</details>

<details><summary><b>FreeBSD</b></summary>

#### Copypaste script:

```sh
sudo pkg install mpv fzf aria2 yt-dlp patch git
git clone "https://github.com/pystardust/ani-cli.git"
sudo cp ani-cli/ani-cli /usr/local/bin
rm -rf ani-cli
```

#### Installation in steps:

##### Install dependencies:

```sh
sudo pkg install mpv fzf aria2 yt-dlp patch
```

##### Install ani-cli:

install git if you haven't already

```sh
sudo pkg install git
```

install from source:

```sh
git clone "https://github.com/pystardust/ani-cli.git"
sudo cp ani-cli/ani-cli /usr/local/bin
rm -rf ani-cli
```

### Windows install (Scoop, optional)

`ani-cli` is also available on Windows via [Scoop](https://scoop.sh/). This is an optional convenience on top of the source install.

We recommend using Windows Terminal with a Git Bash profile. In PowerShell:

```sh
scoop bucket add extras
scoop install extras/windows-terminal
scoop install git
scoop install ani-cli fzf ffmpeg mpv
```

Consider also installing `yt-dlp` and `aria2` for downloading to work.

After installation, open a Git Bash tab in Windows Terminal and run:

```sh
ani-cli -h
```

## Uninstall

- Source install (Linux/macOS/BSD):
```sh
sudo rm /usr/local/bin/ani-cli
```
## Dependencies

- grep
- sed
- curl
- mpv - Video Player
- iina - mpv replacement for MacOS
- aria2c - Download manager
- yt-dlp - m3u8 Downloader
- ffmpeg - m3u8 Downloader (fallback)
- fzf - User interface
- ani-skip (optional)
- patch - Self updating

### Ani-Skip

Ani-skip is a script to automatically skip anime opening sequences, making it easier to watch your favorite shows without having to manually skip the intros each time (from the original [README](https://github.com/synacktraa/ani-skip/tree/master#a-script-to-automatically-skip-anime-opening-sequences-making-it-easier-to-watch-your-favorite-shows-without-having-to-manually-skip-the-intros-each-time)).

For install instructions visit [ani-skip](https://github.com/synacktraa/ani-skip).

Ani-skip uses the external lua script function of mpv and as such – for now – only works with mpv.

**Warning:** For now, ani-skip does **not** seem to work under Windows.

**Note:** It may be, that ani-skip won't know the anime you're trying to watch. Try using the `--skip-title <title>` command line argument. (It uses the [aniskip API](https://github.com/lexesjan/typescript-aniskip-extension/tree/main/src/api/aniskip-http-client) and you can contribute missing anime or ask for including it in the database on their [discord server](https://discord.com/invite/UqT55CbrbE)).

## Favorites and Resume

- Favorites
  - While watching, open the in-player menu and select "favorite" or "unfavorite" to toggle the current series.
  - Stored at `$ANI_CLI_HIST_DIR/favorites` (default: `~/.local/state/ani-cli/favorites`). One entry per line: `<id>\t<title>`.
- Last watched / Resume
  - The most recently watched series and episode are written to `$ANI_CLI_HIST_DIR/last` as `<id>\t<title>\t<episode>`.
  - On interactive startup with no query, ani-cli shows a startup menu with `Resume`, `Favorites`, and `Search`.
  - To disable this startup menu, set `ANI_CLI_STARTUP_MENU=0`.

## FAQ
<details>
	
* Can I change subtitle language or turn them off? - No, the subtitles are baked into the video.
* Can I watch dub? - Yes, use `--dub`.
* Can I change dub language? - No.
* Can I change media source? - No (unless you can scrape that source yourself).
* Can I use vlc? - Yes, use `--vlc` or `export ANI_CLI_PLAYER=vlc`.
* Can I adjust resolution? - Yes, use `-q resolution`, for example `ani-cli -q 1080`.
* How can I download? - Use `-d`, it will download into your working directory.
* Can i change download folder? - Yes, set the `ANI_CLI_DOWNLOAD_DIR` to your desired location.
* How can I bulk download? - `Use -d -e firstepisode-lastepisode`, for example `ani-cli onepiece -d -e 1-1000`.

**Note:** All features are documented in `ani-cli --help`.

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
