
<div align="center">
  <h1> Kde-Dots </h1>
  <p> Aesthetic dots for Kde Plasma!?</p>
</div>

<div align="center">

![GitHub Top Language](https://img.shields.io/github/issues/re1san/Kde-Configs?color=6d92bf&style=for-the-badge)
![Cool](https://img.shields.io/badge/WM-Kwin-da696f?style=for-the-badge)
![Cute](https://img.shields.io/badge/Cute-Yes-c585cf?style=for-the-badge)
![GitHub Code Size](https://img.shields.io/github/languages/code-size/re1san/Kde-Configs?color=e1b56a&style=for-the-badge)
![GitHub Repo Stars](https://img.shields.io/github/stars/re1san/Kde-Configs?color=74be88&style=for-the-badge)

</div>

> [!Important]
> <a href="#installation">Installation</a> section is updated and tested on fresh install of Arch linux :)
> Now supports Ubuntu, Opensuse

> [!Note]
> Themes moved to their respective branch

## Showcase
<!-- | <b>Kitty + Starship</b>                                                                                                  |
| -------------------------------------------------------------------------------------------------------------------- |
| <a href="https://github.com/re1san/Kde-Dots/tree/nya"><img src=".github/assests/1.png"  alt="nya"></a>                 | -->
<table>
  <thead>
    <tr>
      <th colspan=2 style="text-align: center">Kitty + Starship</th>
    </tr>
    <tr>
      <th style="text-align: center">Nya</th>
      <th style="text-align: center">Sciss</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        <a href="https://github.com/re1san/Kde-Dots/tree/nya"><img src=".github/assests/nya.png"  alt="nya"></a>
      </td>
      <td>
        <a href="https://github.com/re1san/Kde-Dots/tree/nya"><img src=".github/assests/sciss.png"  alt="sciss"></a>
      </td>
    </tr>
  </tbody>
</table>

<table>
  <thead>
    <tr>
      <th style="text-align: center">
        Spotify + Cava
      </th>
    </tr>
  </thead>
  <tbody>
    <td>
      <a href="https://github.com/re1san/Kde-Dots/tree/nya"><img src=".github/assests/2.png"  alt="nya">
    </td>
  </tbody>
</table>

<table>
  <thead>
    <tr>
      <th style="text-align: center">
        Custom Firefox
      </th>
    </tr>
  </thead>
  <tbody>
    <td>
      <a href="https://github.com/re1san/Kde-Dots/tree/nya"><img src=".github/assests/3.png"  alt="nya">
    </td>
  </tbody>
</table>

<table>
  <thead>
    <tr>
      <th style="text-align: center">
        Custom VS-Code Theme: <a href="https://github.com/re1san/Tsuki">Tsuki</a>
      </th>
    </tr>
  </thead>
  <tbody>
    <td>
      <a href="https://github.com/re1san/Kde-Dots/tree/nya"><img src=".github/assests/4.png"  alt="nya">
    </td>
  </tbody>
</table>

<!-- | <b>Spotify + Cava</b>                                                                                                  |
| -------------------------------------------------------------------------------------------------------------------- |
| <a href="https://github.com/re1san/Kde-Dots/tree/nya"><img src=".github/assests/2.png"  alt="nya"></a>                 | -->

<!-- | <b>Custom Firefox</b>                                                                                                  |
| -------------------------------------------------------------------------------------------------------------------- |
| <a href="https://github.com/re1san/Kde-Dots/tree/nya"><img src=".github/assests/3.png"  alt="nya"></a>                 |

| <b>Custom VS-CODE Theme: <a href="https://github.com/re1san/Tsuki">Tsuki</a></b>                                                                                                  | -->
<!-- | -------------------------------------------------------------------------------------------------------------------- |
| <a href="https://github.com/re1san/Kde-Dots/tree/nya"><img src=".github/assests/4.png"  alt="nya"></a>                 | -->

<details><summary>Other themes that I used before</summary>

| <b>Mori森</b>                                                                                                  |
| -------------------------------------------------------------------------------------------------------------------- |
| <a href="https://github.com/re1san/Kde-Dots/tree/mori"><img src=".github/assests/mori.png"  alt="mori"></a>                 |

| <b> Havana </b>                                                                                                      |
| -------------------------------------------------------------------------------------------------------------------- |
| <a href="https://github.com/re1san/Kde-Dots/tree/havana"><img src="https://raw.githubusercontent.com/re1san/Kde-Configs/havana/.github/assests/S1.png"  alt="havana"></a>     |

| <b> Nx-Desktop </b>                                                                                                  |
| -------------------------------------------------------------------------------------------------------------------- |
| <a href="https://github.com/re1san/Kde-Dots/tree/nx-desk"><img src="https://github.com/re1san/Kde-Configs/raw/nx-desk/.github/assests/nx.png"  alt="nx-desk"></a>   |

</details>

## Installation

**Initial Requirements**
* Arch Linux with Kde Plasma (preferred through `archinstall` script)

**Once you have working setup with Kde Plasma use the command below to run install script**
 ```bash
curl https://raw.githubusercontent.com/re1san/Kde-Dots/main/install.sh -o install.sh && chmod +x install.sh && ./install.sh 2>&1 | tee log.txt
 ```
**After the complete execution of script follow the steps**

* Go to Settings > Appearance and set the following settings
  * Application Style to Lightly
  * Window Deco to Nitrux
  * Fonts > Adjust all fonts to *Lexend* & Fix-width font to *Iosevka Nerd Font*
  * Icons to Reversal-black-dark
  * Change gtk theme (Application Style > Configure GNOME/GTK ... > Select Mori-gtk)

* Latte-dock should start automatically, if not start it from Apps Launcher
* Remove existing kde panel (right click > edit mode > right click on panel > edit > more options > remove panel)
 
**VS-Code Theme**
* Its a custom theme made by me, search for **Tsuki** in Vs-code extensions!
* Or install it from the [marketplace](https://marketplace.visualstudio.com/items?itemName=re1san.tsuki)
* Github [repo](https://github.com/re1san/Tsuki)

**Spotify Theme**
* Make sure you have already signed in to spotify after that run this `spicetify config current_theme Snow && spicetify backup apply`

**Kitty**
* Change default shell to zsh `chsh -s /bin/zsh`
* And launch kitty! (starship already installed using script)

**Firefox config**
1. Type `about:config` into your URL bar. Click on the I accept the risk button if you're shown a warning.
2. Seach for `toolkit.legacyUserProfileCustomizations.stylesheets` and set it to `true`.
3. Install this [theme](https://addons.mozilla.org/en-US/firefox/addon/simplerentfox/).

**Firefox Homepage**
* Follow [this](https://github.com/re1san/Bento)
* Also replace Openweather Api key with your own [here](https://github.com/re1san/Bento/blob/72c8c0bac309bd725c58d21ff524382c684f8951/config.js#L29)

## TODO
- [ ] Merge all configs in one branch 
- [ ] Make installation video (maybe)

## Acknowledgement

Thanks to all these wonderful people for helping me out!

* [Chadcat](https://github.com/chadcat7)
* [Gwen](https://github.com/elythh)
* [Nitrux](https://github.com/Nitrux)
* [Linuxmobile](https://github.com/linuxmobile)

## Misc

*If you loved the theme consider starring this repo, keeps me motivated to maintain it*

Also feel free to open an issue if you face any problems or contribute (like making the script modular instead of writing it all in a single file!)
