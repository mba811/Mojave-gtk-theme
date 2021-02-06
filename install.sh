#! /usr/bin/env bash
set -o physical

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SRC_DIR="${REPO_DIR}/src"

ROOT_UID=0
DEST_DIR=

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share/themes"
else
  DEST_DIR="$HOME/.themes"
fi

THEME_NAME=Mojave
COLOR_VARIANTS=('-light' '-dark')
OPACITY_VARIANTS=('' '-solid')
ALT_VARIANTS=('' '-alt')
SMALL_VARIANTS=('' '-small')
THEME_VARIANTS=('' '-blue' '-purple' '-pink' '-red' '-orange' '-yellow' '-green' '-grey')
ICON_VARIANTS=('' '-normal' '-gnome' '-ubuntu' '-arch' '-manjaro' '-fedora' '-debian' '-void')

usage() {
  printf "%s\n" "Usage: $0 [OPTIONS...]"
  printf "\n%s\n" "OPTIONS:"
  printf "  %-25s%s\n" "-d, --dest DIR" "Specify theme destination directory (Default: ${DEST_DIR})"
  printf "  %-25s%s\n" "-n, --name NAME" "Specify theme name (Default: ${THEME_NAME})"
  printf "  %-25s%s\n" "-o, --opacity VARIANTS" "Specify theme opacity variant(s) [standard|solid] (Default: All variants)"
  printf "  %-25s%s\n" "-c, --color VARIANTS" "Specify theme color variant(s) [light|dark] (Default: All variants)"
  printf "  %-25s%s\n" "-a, --alt VARIANTS" "Specify theme titilebutton variant(s) [standard|alt] (Default: All variants)"
  printf "  %-25s%s\n" "-s, --small VARIANTS" "Specify theme titilebutton size variant(s) [standard|small] (Default: All variants)"
  printf "  %-25s%s\n" "-t, --theme VARIANTS" "Specify primary theme color [blue|purple|pink|red|orange|yellow|green|grey|all] (Default: MacOS blue)"
  printf "  %-25s%s\n" "-i, --icon VARIANTS" "Specify activities icon variant(s) for gnome-shell [standard|normal|gnome|ubuntu|arch|manjaro|fedora|debian|void] (Default: standard variant)"
  printf "  %-25s%s\n" "-g, --gdm" "Install GDM theme, this option need root user authority! please run this with sudo"
  printf "  %-25s%s\n" "-r, --revert" "revert GDM theme, this option need root user authority! please run this with sudo"
  printf "  %-25s%s\n" "-h, --help" "Show this help"
}

install() {
  local dest="${1}"
  local name="${2}"
  local color="${3}"
  local opacity="${4}"
  local alt="${5}"
  local small="${6}"
  local theme="${7}"
  local icon="${8}"

  [[ "${color}" == '-light' ]] && local ELSE_LIGHT="${color}"
  [[ "${color}" == '-dark' ]] && local ELSE_DARK="${color}"

  local THEME_DIR="${1}/${2}${3}${4}${5}${6}${7}"

  [[ -d "${THEME_DIR}" ]] && rm -rf "${THEME_DIR}"

  echo "Installing '${THEME_DIR}'..."

  mkdir -p                                                                                   "${THEME_DIR}"
  cp -r "${REPO_DIR}/COPYING"                                                                "${THEME_DIR}"

  echo "[Desktop Entry]" >>                                                                  "${THEME_DIR}/index.theme"
  echo "Type=X-GNOME-Metatheme" >>                                                           "${THEME_DIR}/index.theme"
  echo "Name=${2}${3}${4}${5}${6}${7}" >>                                                    "${THEME_DIR}/index.theme"
  echo "Comment=An Stylish Gtk+ theme based on Elegant Design" >>                            "${THEME_DIR}/index.theme"
  echo "Encoding=UTF-8" >>                                                                   "${THEME_DIR}/index.theme"
  echo "" >>                                                                                 "${THEME_DIR}/index.theme"
  echo "[X-GNOME-Metatheme]" >>                                                              "${THEME_DIR}/index.theme"
  echo "GtkTheme=${2}${3}${4}${5}${6}${7}" >>                                                "${THEME_DIR}/index.theme"
  echo "MetacityTheme=${2}${3}${4}${5}${6}${7}" >>                                           "${THEME_DIR}/index.theme"
  echo "IconTheme=Mc${2}-circle${3}" >>                                                      "${THEME_DIR}/index.theme"
  echo "CursorTheme=McMojave Cursors" >>                                                     "${THEME_DIR}/index.theme"
  echo "ButtonLayout=close,minimize,maximize:menu" >>                                        "${THEME_DIR}/index.theme"

  mkdir -p                                                                                   "${THEME_DIR}/gnome-shell"
  cp -r "${SRC_DIR}/main/gnome-shell/gnome-shell${color}${opacity}${theme}.css"              "${THEME_DIR}/gnome-shell/gnome-shell.css"
  cp -r "${SRC_DIR}/assets/gnome-shell/common-assets"                                        "${THEME_DIR}/gnome-shell/assets"

  if [[ ${theme} != '-default' ]]; then
    cp -r ${SRC_DIR}/assets/gnome-shell/common-assets${theme}/*'.svg'                        "${THEME_DIR}/gnome-shell/assets"
  fi

  cp -r "${SRC_DIR}/assets/gnome-shell/assets${color}/"*'.svg'                               "${THEME_DIR}/gnome-shell/assets"
  cp -r "${SRC_DIR}/assets/gnome-shell/assets${color}/background.png"                        "${THEME_DIR}/gnome-shell/assets"
  cp -r "${SRC_DIR}/assets/gnome-shell/activities${color}/activities${icon}.svg"             "${THEME_DIR}/gnome-shell/assets/activities.svg"

  cd "${THEME_DIR}/gnome-shell"
  mv -f assets/no-events.svg no-events.svg
  mv -f assets/process-working.svg process-working.svg
  mv -f assets/no-notifications.svg no-notifications.svg

  mkdir -p                                                                                   "${THEME_DIR}/gtk-2.0"
  cp -r "${SRC_DIR}/main/gtk-2.0/gtkrc${color}${theme}"                                      "${THEME_DIR}/gtk-2.0/gtkrc"
  cp -r "${SRC_DIR}/main/gtk-2.0/menubar-toolbar${color}.rc"                                 "${THEME_DIR}/gtk-2.0/menubar-toolbar.rc"
  cp -r "${SRC_DIR}/main/gtk-2.0/common/"*'.rc'                                              "${THEME_DIR}/gtk-2.0"
  cp -r "${SRC_DIR}/assets/gtk-2.0/assets${color}"                                           "${THEME_DIR}/gtk-2.0/assets"

  if [[ ${theme} != '-default' ]]; then
    cp -r "${SRC_DIR}/assets/gtk-2.0/assets${color}${theme}/"*'.png'                         "${THEME_DIR}/gtk-2.0/assets"
  fi

  mkdir -p                                                                                   "${THEME_DIR}/gtk-3.0"
  cp -r "${SRC_DIR}/assets/gtk-3.0/common-assets/assets"                                     "${THEME_DIR}/gtk-3.0"

  if [[ ${theme} != '-default' ]]; then
    cp -r "${SRC_DIR}/assets/gtk-3.0/common-assets/assets${theme}/"*'.png'                   "${THEME_DIR}/gtk-3.0/assets"
  fi

  cp -r "${SRC_DIR}/assets/gtk-3.0/windows-assets/titlebutton${alt}${small}"                 "${THEME_DIR}/gtk-3.0/windows-assets"
  cp -r "${SRC_DIR}/assets/gtk-3.0/thumbnails/thumbnail${color}${theme}.png"                 "${THEME_DIR}/gtk-3.0/thumbnail.png"
  cp -r "${SRC_DIR}/main/gtk-3.0/gtk-dark${opacity}${theme}.css"                             "${THEME_DIR}/gtk-3.0/gtk-dark.css"

  if [[ "${color}" == '-light' ]]; then
    cp -r "${SRC_DIR}/main/gtk-3.0/gtk-light${opacity}${theme}.css"                         "${THEME_DIR}/gtk-3.0/gtk.css"
  else
    cp -r "${SRC_DIR}/main/gtk-3.0/gtk-dark${opacity}${theme}.css"                          "${THEME_DIR}/gtk-3.0/gtk.css"
  fi

  glib-compile-resources --sourcedir="${THEME_DIR}/gtk-3.0" --target="${THEME_DIR}/gtk-3.0/gtk.gresource" "${SRC_DIR}/main/gtk-3.0/gtk.gresource.xml"
  rm -rf "${THEME_DIR}/gtk-3.0/"{assets,windows-assets,gtk.css,gtk-dark.css}
  echo '@import url("resource:///org/gnome/theme/gtk.css");' >>                              "${THEME_DIR}/gtk-3.0/gtk.css"
  echo '@import url("resource:///org/gnome/theme/gtk-dark.css");' >>                         "${THEME_DIR}/gtk-3.0/gtk-dark.css"

  mkdir -p                                                                                   "${THEME_DIR}/metacity-1"
  cp -r "${SRC_DIR}/main/metacity-1/metacity-theme${color}.xml"                              "${THEME_DIR}/metacity-1/metacity-theme-1.xml"
  cp -r "${SRC_DIR}/main/metacity-1/metacity-theme-3.xml"                                    "${THEME_DIR}/metacity-1"
  cp -r "${SRC_DIR}/assets/metacity-1/assets/"*'.png'                                        "${THEME_DIR}/metacity-1"
  cp -r "${SRC_DIR}/assets/metacity-1/thumbnail${color}.png"                                 "${THEME_DIR}/metacity-1/thumbnail.png"
  cd "${THEME_DIR}/metacity-1" && ln -s metacity-theme-1.xml metacity-theme-2.xml

  mkdir -p                                                                                   "${THEME_DIR}/xfwm4"
  cp -r "${SRC_DIR}/assets/xfwm4/assets${color}/"*'.png'                                     "${THEME_DIR}/xfwm4"
  cp -r "${SRC_DIR}/main/xfwm4/themerc${color}"                                              "${THEME_DIR}/xfwm4/themerc"

  mkdir -p                                                                                   "${THEME_DIR}/cinnamon"
  cp -r "${SRC_DIR}/main/cinnamon/cinnamon${color}${opacity}${theme}.css"                    "${THEME_DIR}/cinnamon/cinnamon.css"
  cp -r "${SRC_DIR}/assets/cinnamon/common-assets"                                           "${THEME_DIR}/cinnamon/assets"

  if [[ ${theme} != '-default' ]]; then
    cp -r "${SRC_DIR}/assets/cinnamon/common-assets${theme}/"*'.svg'                         "${THEME_DIR}/cinnamon/assets"
  fi

  cp -r "${SRC_DIR}/assets/cinnamon/assets${color}/"*'.svg'                                  "${THEME_DIR}/cinnamon/assets"
  cp -r "${SRC_DIR}/assets/cinnamon/thumbnails/thumbnail${color}${theme}.png"                "${THEME_DIR}/cinnamon/thumbnail.png"

  mkdir -p                                                                                   "${THEME_DIR}/plank"
  cp -r "${SRC_DIR}/other/plank/${name}${color}/"*'.theme'                                   "${THEME_DIR}/plank"
}

# Backup and install files related to GDM theme
GS_THEME_FILE="/usr/share/gnome-shell/gnome-shell-theme.gresource"
SHELL_THEME_FOLDER="/usr/share/gnome-shell/theme"
ETC_THEME_FOLDER="/etc/alternatives"
ETC_THEME_FILE="/etc/alternatives/gdm3.css"
ETC_NEW_THEME_FILE="/etc/alternatives/gdm3-theme.gresource"
UBUNTU_THEME_FILE="/usr/share/gnome-shell/theme/ubuntu.css"
UBUNTU_NEW_THEME_FILE="/usr/share/gnome-shell/theme/gnome-shell.css"
UBUNTU_YARU_THEME_FILE="/usr/share/gnome-shell/theme/Yaru/gnome-shell-theme.gresource"
POP_OS_THEME_FILE="/usr/share/gnome-shell/theme/Pop/gnome-shell-theme.gresource"

install_gdm() {
  local dest="${1}"
  local name="${2}"
  local color="${3}"
  local opacity="${4}"
  local theme="${5}"

  local GDM_THEME_DIR="${1}/${2}${3}${4}${5}"
  local YARU_GDM_THEME_DIR="$SHELL_THEME_FOLDER/Yaru/${2}${3}${4}${5}"
  local POP_GDM_THEME_DIR="$SHELL_THEME_FOLDER/Pop/${2}${3}${4}${5}"

  echo
  prompt -i "Installing ${2}${3}${4}${5} gdm theme..."

  if [[ -f "$GS_THEME_FILE" ]] && command -v glib-compile-resources >/dev/null ; then
    prompt -i "Installing '$GS_THEME_FILE'..."
    cp -an "$GS_THEME_FILE" "$GS_THEME_FILE.bak"
    glib-compile-resources \
      --sourcedir="$GDM_THEME_DIR/gnome-shell" \
      --target="$GS_THEME_FILE" \
      "${SRC_DIR}/main/gnome-shell/gnome-shell-theme.gresource.xml"
  fi

  if [[ -f "$UBUNTU_THEME_FILE" && -f "$GS_THEME_FILE.bak" ]]; then
    prompt -i "Installing '$UBUNTU_THEME_FILE'..."
    cp -an "$UBUNTU_THEME_FILE" "$UBUNTU_THEME_FILE.bak"
    cp -af "$GDM_THEME_DIR/gnome-shell/gnome-shell.css" "$UBUNTU_THEME_FILE"
  fi

  if [[ -f "$UBUNTU_NEW_THEME_FILE" && -f "$GS_THEME_FILE.bak" ]]; then
    prompt -i "Installing '$UBUNTU_NEW_THEME_FILE'..."
    cp -an "$UBUNTU_NEW_THEME_FILE" "$UBUNTU_NEW_THEME_FILE.bak"
    cp -af "$GDM_THEME_DIR"/gnome-shell/* "$SHELL_THEME_FOLDER"
  fi

  # > Ubuntu 18.04
  if [[ -f "$ETC_THEME_FILE" && -f "$GS_THEME_FILE.bak" ]]; then
    prompt -i "Installing Ubuntu GDM theme..."
    cp -an "$ETC_THEME_FILE" "$ETC_THEME_FILE.bak"
    [[ -d "$SHELL_THEME_FOLDER/$THEME_NAME" ]] && rm -rf "$SHELL_THEME_FOLDER/$THEME_NAME"
    cp -r "$GDM_THEME_DIR/gnome-shell" "$SHELL_THEME_FOLDER/$THEME_NAME"
    cd "$ETC_THEME_FOLDER"
    [[ -f "$ETC_THEME_FILE.bak" ]] && ln -sf "$SHELL_THEME_FOLDER/$THEME_NAME/gnome-shell.css" gdm3.css
  fi

  # > Ubuntu 20.04
  if [[ -d "$SHELL_THEME_FOLDER/Yaru" && -f "$GS_THEME_FILE.bak" ]]; then
    prompt -i "Installing Ubuntu GDM theme..."
    cp -an "$UBUNTU_YARU_THEME_FILE" "$UBUNTU_YARU_THEME_FILE.bak"
    rm -rf "$UBUNTU_YARU_THEME_FILE"
    rm -rf "$YARU_GDM_THEME_DIR" && mkdir -p "$YARU_GDM_THEME_DIR"

    mkdir -p                                                                              "$YARU_GDM_THEME_DIR"/gnome-shell
    mkdir -p                                                                              "$YARU_GDM_THEME_DIR"/gnome-shell/Yaru
    cp -r "$SRC_DIR"/assets/gnome-shell/icons                                             "$YARU_GDM_THEME_DIR"/gnome-shell
    cp -r "$SRC_DIR"/main/gnome-shell/pad-osd.css                                         "$YARU_GDM_THEME_DIR"/gnome-shell
    cp -r "$SRC_DIR"/main/gnome-shell/gnome-shell${color}.css                             "$YARU_GDM_THEME_DIR"/gnome-shell/gdm3.css
    cp -r "$SRC_DIR"/main/gnome-shell/gnome-shell${color}.css                             "$YARU_GDM_THEME_DIR"/gnome-shell/Yaru/gnome-shell.css
    cp -r "$SRC_DIR"/assets/gnome-shell/common-assets                                     "$YARU_GDM_THEME_DIR"/gnome-shell/assets
    cp -r "$SRC_DIR"/assets/gnome-shell/assets${color}/*.svg                              "$YARU_GDM_THEME_DIR"/gnome-shell/assets
    cp -r "$SRC_DIR"/assets/gnome-shell/activities/activities.svg                         "$YARU_GDM_THEME_DIR"/gnome-shell/assets

    cd "$YARU_GDM_THEME_DIR"/gnome-shell
    mv -f assets/no-events.svg no-events.svg
    mv -f assets/process-working.svg process-working.svg
    mv -f assets/no-notifications.svg no-notifications.svg

    glib-compile-resources \
      --sourcedir="$YARU_GDM_THEME_DIR"/gnome-shell \
      --target="$UBUNTU_YARU_THEME_FILE" \
      "$SRC_DIR"/main/gnome-shell/gnome-shell-yaru-theme.gresource.xml

    rm -rf "$YARU_GDM_THEME_DIR"
  fi

  # > Pop_OS 20.04
  if [[ -d "$SHELL_THEME_FOLDER/Pop" && -f "$GS_THEME_FILE.bak" ]]; then
    prompt -i "Installing Pop_OS GDM theme..."
    cp -an "$POP_OS_THEME_FILE" "$POP_OS_THEME_FILE.bak"
    rm -rf "$POP_OS_THEME_FILE"
    rm -rf "$POP_GDM_THEME_DIR" && mkdir -p "$POP_GDM_THEME_DIR"

    mkdir -p                                                                              "$POP_GDM_THEME_DIR"/gnome-shell
    cp -r "$SRC_DIR"/assets/gnome-shell/icons                                             "$POP_GDM_THEME_DIR"/gnome-shell
    cp -r "$SRC_DIR"/main/gnome-shell/pad-osd.css                                         "$POP_GDM_THEME_DIR"/gnome-shell
    cp -r "$SRC_DIR"/main/gnome-shell/gnome-shell${color}.css                             "$POP_GDM_THEME_DIR"/gnome-shell/gdm3.css
    cp -r "$SRC_DIR"/main/gnome-shell/gnome-shell${color}.css                             "$POP_GDM_THEME_DIR"/gnome-shell/gnome-shell.css
    cp -r "$SRC_DIR"/assets/gnome-shell/common-assets                                     "$POP_GDM_THEME_DIR"/gnome-shell/assets
    cp -r "$SRC_DIR"/assets/gnome-shell/assets${color}/*.svg                              "$POP_GDM_THEME_DIR"/gnome-shell/assets
    cp -r "$SRC_DIR"/assets/gnome-shell/activities/activities.svg                         "$POP_GDM_THEME_DIR"/gnome-shell/assets

    cd "$POP_GDM_THEME_DIR"/gnome-shell
    mv -f assets/no-events.svg no-events.svg
    mv -f assets/process-working.svg process-working.svg
    mv -f assets/no-notifications.svg no-notifications.svg

    glib-compile-resources \
      --sourcedir="$POP_GDM_THEME_DIR"/gnome-shell \
      --target="$POP_OS_THEME_FILE" \
      "$SRC_DIR"/main/gnome-shell/gnome-shell-pop-theme.gresource.xml

    rm -rf "$POP_GDM_THEME_DIR"
  fi
}

revert_gdm() {
  if [[ -f "$GS_THEME_FILE.bak" ]]; then
    prompt -w "Reverting '$GS_THEME_FILE'..."
    rm -rf "$GS_THEME_FILE"
    mv "$GS_THEME_FILE.bak" "$GS_THEME_FILE"
  fi

  if [[ -f "$UBUNTU_THEME_FILE.bak" ]]; then
    prompt -w "Reverting '$UBUNTU_THEME_FILE'..."
    rm -rf "$UBUNTU_THEME_FILE"
    mv "$UBUNTU_THEME_FILE.bak" "$UBUNTU_THEME_FILE"
  fi

  if [[ -f "$UBUNTU_NEW_THEME_FILE.bak" ]]; then
    prompt -w "Reverting '$UBUNTU_NEW_THEME_FILE'..."
    rm -rf "$UBUNTU_NEW_THEME_FILE" "$SHELL_THEME_FOLDER"/{assets,no-events.svg,process-working.svg,no-notifications.svg}
    mv "$UBUNTU_NEW_THEME_FILE.bak" "$UBUNTU_NEW_THEME_FILE"
  fi

  # > Ubuntu 18.04
  if [[ -f "$ETC_THEME_FILE.bak" ]]; then

    prompt -w "reverting Ubuntu GDM theme..."

    rm -rf "$ETC_THEME_FILE"
    mv "$ETC_THEME_FILE.bak" "$ETC_THEME_FILE"
    [[ -d $SHELL_THEME_FOLDER/$THEME_NAME ]] && rm -rf $SHELL_THEME_FOLDER/$THEME_NAME
  fi

  # > Ubuntu 20.04
  if [[ -f "$UBUNTU_YARU_THEME_FILE.bak" ]]; then
    prompt -w "reverting Ubuntu GDM theme..."
    rm -rf "$UBUNTU_YARU_THEME_FILE"
    mv "$UBUNTU_YARU_THEME_FILE.bak" "$UBUNTU_YARU_THEME_FILE"
  fi

  # > Pop_OS 20.04
  if [[ -f "$POP_OS_THEME_FILE.bak" ]]; then
    prompt -w "reverting Pop_OS GDM theme..."
    rm -rf "$POP_OS_THEME_FILE"
    mv "$POP_OS_THEME_FILE.bak" "$POP_OS_THEME_FILE"
  fi
}

while [[ $# -gt 0 ]]; do
  case "${1}" in
    -d|--dest)
      dest="${2}"
      if [[ ! -d "${dest}" ]]; then
        echo "Destination directory does not exist. Let's make a new one..."
        mkdir -p "${dest}"
      fi
      dest="$(cd "${dest}"; pwd)"
      shift 2
      ;;
    -n|--name)
      name="${2}"
      shift 2
      ;;
    -g|--gdm)
      gdm='true'
      shift 1
      ;;
    -r|--revert)
      revert='true'
      shift 1
      ;;
    -a|--alt)
      shift
      for alt in "${@}"; do
        case "${alt}" in
          standard)
            alts+=("${ALT_VARIANTS[0]}")
            shift
            ;;
          alt)
            alts+=("${ALT_VARIANTS[1]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized opacity variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -s|--small)
      shift
      for small in "${@}"; do
        case "${small}" in
          standard)
            smalls+=("${SMALL_VARIANTS[0]}")
            shift
            ;;
          small)
            smalls+=("${SMALL_VARIANTS[1]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized opacity variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -o|--opacity)
      shift
      for opacity in "${@}"; do
        case "${opacity}" in
          standard)
            opacities+=("${OPACITY_VARIANTS[0]}")
            shift
            ;;
          solid)
            opacities+=("${OPACITY_VARIANTS[1]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized opacity variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -c|--color)
      shift
      for color in "${@}"; do
        case "${color}" in
          light)
            colors+=("${COLOR_VARIANTS[0]}")
            shift
            ;;
          dark)
            colors+=("${COLOR_VARIANTS[1]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized color variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -t|--theme)
      shift
      for theme in "${@}"; do
        case "${theme}" in
          default)
            themes+=("${THEME_VARIANTS[0]}")
            shift
            ;;
          blue)
            themes+=("${THEME_VARIANTS[1]}")
            shift
            ;;
          purple)
            themes+=("${THEME_VARIANTS[2]}")
            shift
            ;;
          pink)
            themes+=("${THEME_VARIANTS[3]}")
            shift
            ;;
          red)
            themes+=("${THEME_VARIANTS[4]}")
            shift
            ;;
          orange)
            themes+=("${THEME_VARIANTS[5]}")
            shift
            ;;
          yellow)
            themes+=("${THEME_VARIANTS[6]}")
            shift
            ;;
          green)
            themes+=("${THEME_VARIANTS[7]}")
            shift
            ;;
          grey)
            themes+=("${THEME_VARIANTS[8]}")
            shift
            ;;
          all)
            themes+=("${THEME_VARIANTS[@]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            prompt -e "ERROR: Unrecognized theme variant '$1'."
            prompt -i "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -i|--icon)
      shift
      for icon in "${@}"; do
        case "${icon}" in
          standard)
            icons+=("${ICON_VARIANTS[0]}")
            shift
            ;;
          normal)
            icons+=("${ICON_VARIANTS[1]}")
            shift
            ;;
          gnome)
            icons+=("${ICON_VARIANTS[2]}")
            shift
            ;;
          ubuntu)
            icons+=("${ICON_VARIANTS[3]}")
            shift
            ;;
          arch)
            icons+=("${ICON_VARIANTS[4]}")
            shift
            ;;
          manjaro)
            icons+=("${ICON_VARIANTS[5]}")
            shift
            ;;
          fedora)
            icons+=("${ICON_VARIANTS[6]}")
            shift
            ;;
          debian)
            icons+=("${ICON_VARIANTS[7]}")
            shift
            ;;
          void)
            icons+=("${ICON_VARIANTS[8]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized icon variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unrecognized installation option '$1'."
      echo "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
done

# Check command availability
function has_command() {
  command -v $1 > /dev/null
}

if [ ! "$(which sassc 2> /dev/null)" ]; then
  echo sassc needs to be installed to generate the css.
  if has_command zypper; then
    sudo zypper in sassc
  elif has_command apt; then
    sudo apt install sassc
  elif has_command dnf; then
    sudo dnf install -y sassc
  elif has_command yum; then
    sudo yum install sassc
  elif has_command pacman; then
    sudo pacman -S --noconfirm sassc
  fi
fi

SASSC_OPT="-M -t expanded"

parse_theme() {
  for color in "${colors[@]-${COLOR_VARIANTS[@]}}"; do
    for opacity in "${opacities[@]-${OPACITY_VARIANTS[@]}}"; do
      for theme in "${themes[@]-${THEME_VARIANTS[0]}}"; do
        sassc $SASSC_OPT $SRC_DIR/main/gtk-3.0/gtk${color}${opacity}${theme}.{scss,css}
        echo "==> Generating the gtk${color}${opacity}${theme}.css..."
        sassc $SASSC_OPT $SRC_DIR/main/gnome-shell/gnome-shell${color}${opacity}${theme}.{scss,css}
        echo "==> Generating the gnome-shell${color}${opacity}${theme}.css..."
        sassc $SASSC_OPT $SRC_DIR/main/cinnamon/cinnamon${color}${opacity}${theme}.{scss,css}
        echo "==> Generating the cinnamon${color}${opacity}${theme}.css..."
      done
    done
  done
}

install_theme() {
  for color in "${colors[@]-${COLOR_VARIANTS[@]}}"; do
    for opacity in "${opacities[@]-${OPACITY_VARIANTS[@]}}"; do
      for alt in "${alts[@]-${ALT_VARIANTS[@]}}"; do
        for theme in "${themes[@]-${THEME_VARIANTS[0]}}"; do
          for small in "${smalls[@]-${SMALL_VARIANTS[0]}}"; do
            for icon in "${icons[@]-${ICON_VARIANTS[0]}}"; do
              install "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${color}" "${opacity}" "${alt}" "${small}" "${theme}" "${icon}"
            done
          done
        done
      done
    done
  done
}

cd "${SRC_DIR}/main/gtk-3.0" && ./make_gresource_xml.sh

if [[ "${small:-}" == 'small' ]]; then
  cd ${SRC_DIR}/assets/gtk-3.0/windows-assets && ./render-small-assets.sh && ./render-alt-small-assets.sh
fi

if [[ "${gdm:-}" != 'true' && "${revert:-}" != 'true' ]]; then
  parse_theme && install_theme "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${color}" "${opacity}" "${alt}" "${small}" "${theme}" "${icon}"
fi

if [[ "${gdm:-}" == 'true' && "${revert:-}" != 'true' && "$UID" -eq "$ROOT_UID" ]]; then
  parse_theme && install_theme && install_gdm "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${color}" "${opacity}" "${alt}" "${small}" "${theme}" "${icon}"
fi

if [[ "${gdm:-}" != 'true' && "${revert:-}" == 'true' && "$UID" -eq "$ROOT_UID" ]]; then
  revert_gdm
fi

echo
echo Done.
