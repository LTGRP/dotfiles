# Aliases and functions

#
# Generally-useful aliases
#
alias axfr='dig AXFR' # Zone transfer
alias be='bundler exec'
alias clip='xclip -selection clipboard' # Put input to x primary clipboard
alias clr='clear'
alias digs='dig +short' # reduce dig output
alias duhso='du -h | sort -Vr | head' # Human-readable disk usage top offenders in curr dir
alias duso='du | sort -Vr | head' # Disk usage top offenders in curr dir
alias egrep='grep  --exclude-dir=".svn"--exclude-dir=".git" -E'
alias egrpe='grep  --exclude-dir=".svn"--exclude-dir=".git" -E' # I always frickin' do that
alias fgrep='grep --exclude-dir=".svn" --exclude-dir=".git" -F'
alias fgrpe='grep --exclude-dir=".svn" --exclude-dir=".git" -F' # I always frickin' do that
alias grep='grep  --exclude-dir=".svn"--exclude-dir=".git"'
alias grpe='grep  --exclude-dir=".svn"--exclude-dir=".git"' # I always frickin' do that
alias grepi='grep --exclude-dir=".svn"--exclude-dir=".git" -i' # case-insensitive grep
alias ll='ls -l'
alias lla='ls -la'
alias llz='ls -lZ'
alias less='less -XF' # X prevents clearing screen after and F ditches pagination if too short
alias nodeactivate='PATH=$(npm bin):$PATH; '
alias rot13="tr '[A-Za-z]' '[N-ZA-Mn-za-m]'" # For REALLY improtant security things
alias screenhere='screen -DRS "$(basename $(pwd))"'
alias shfmtg='shfmt -i 2 -ci' # shfmt by Google's Style guide
alias sortip='sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4' # Sort ip addresses
alias sudo='sudo ' # to allow sudoing with aliases
alias xo='xdg-open'

#
# Packaging
#
alias apts='apt-cache search'
alias aptshow='apt-cache show'
alias aptinst='apt-get install'
alias aptupd='apt-get update'
alias aptupg='apt-get upgrade'
alias aptrm='apt-get remove'

#
# Aliases rather particular to my use-case
#
alias jdate="date '+%Y-%m-%d %H:%M:%S %z'"
alias locksleep='sudo echo && sudo -u csp i3lock -I 10 && sudo pm-suspend'
alias sizerate='$HOME/.bin/sizerate'
# unetbootin and sudo as per https://askubuntu.com/a/1006483/362696
alias unetbootin='xhost local:root && sudo QT_X11_NO_MITSHM=1 unetbootin'

#
# Functions
#
# DecipherMedia.tv (i.e. dm) website etc helpers
dmaddmovie() {
  # Add a movie to decipherscifi's movie data with an easy-to-access key
  jsonfile=$1
  jq --sort-keys --slurpfile oldjson "${jsonfile}" '. | {(.title + " " + .release_year): .} + $oldjson[]'
}


# Ssh
dossh() {
  # Keep trying to connect over ssh
        ssh "$1"
        until [ $? -eq 0 ]; do
                sleep 1; ssh "$1"
        done
}

g() {
  # Google some input directly from cli
  # via Avinash Raj on AskUbuntu https://askubuntu.com/a/486021
  local search=""
  echo "Googling: $@"
  for term in $@; do
      search="$search%20$term"
  done
  xdg-open "https://www.google.com/search?q=$search"
}

hr() {
  # hr print horizontal rule, default with '-' but char can be provided
  # based on: https://www.reddit.com/r/commandline/comments/7zvmze/show_hr_a_cli_program_that_outputs_a_horizontal/durci2h/
  local outchar='-'
  if [ ! -z "${1}" ]; then
    if [ "${#1}" -eq 1 ]; then
      outchar="${1}"
    fi
  fi
  printf "%0.s${outchar}" $(seq 1 $(tput cols))
}

# http get content length from remote url
httplen() {
  curl -L --head "${3}" 2>/dev/null | tr '^M' '\n' | grep -P '^Content-Length:' | cut -d ' ' -f 2
}

# id3 add image to mp3 file with eyeD3
id3img() {
  local imgpath
  imgpath="${1}"
  local mp3file
  mp3file="${2}"

  eyeD3 --add-image "${imgpath}:FRONT_COVER" "${mp3file}"
}

boxscale() {
  # Scale up a video up or down to the specified dimensions, maintaining
  # aspect ratio and letter/pillarboxing as necessary
  local infile=$1
  local dimensions=$2
  local outfile=$3

  ffmpeg -i "${infile}" -vf "scale=${dimensions}:force_original_aspect_ratio=decrease,pad=${dimensions}:(ow-iw)/2:(oh-ih)/2" "${outfile}"
}

# md5sum comparison
md5comp() {
  local md5sum
  local newsum
  md5sum=$(md5sum "$1" | tr -s ' ' | cut -d ' ' -f 1)
  for filename in "$@"; do
    newsum=$(md5sum "$filename" | tr -s ' ' | cut -d ' ' -f 1)
    if [ "$newsum" != "$md5sum" ]; then
      echo "No match"
      return 1
    fi
  done

  echo "Match"
  return 0
}

moshr() {
  # Open mosh to host $1 with a screen session as root
  mosh_screen $1 '' 'sudo'
}

moshs() {
  # Open mosh to host $1 with a screen session as same user
  mosh_screen $1
}


mosh_screen() {
  # Connect to mosh with a screen session.
  #
  # Params:
  #  $1: Hostname
  #  $2: Screen session name. If not given defaults to username
  #  $3: sudo? Sudos if nonempty

  if [ ! -z "$2" ]; then
    screenname=$2
  else
    screenname=$(whoami)
  fi
  if [ ! -z "$3" ]; then
    sudocmd='sudo '
  else
    sudocmd=' '
  fi
  hostnameshellcmd='$(hostname)'
  mosh "${1}" -- bash -c "echo \"Logging into host ${1}  identifying as ${hostnameshellcmd}\"; ${sudocmd} screen -DR -S ${screenname}"
}

# New password maker
newpass() {
  local len
  if [ -z "${1}" ]; then
    len=30
  else
    len="${1}"
  fi
  openssl rand -base64 "${len}" | tr -d '\n' | head -c "${len}"
  echo
}



sshr() {
  # Open ssh to host $1 with a screen session as root
  ssh_screen $1 '' 'sudo'
}


sshs() {
  # Open ssh to host $1 with a screen session as same user
  ssh_screen $1
}

ssh_screen() {
  # Connect to ssh with a screen session.
  #
  # Params:
  #  $1: Hostname
  #  $2: Screen session name. If not given defaults to username
  #  $3: sudo? Sudos if nonempty

  local screenname
  if [ ! -z "$2" ]; then
    screenname=$2
  else
    screenname=$(whoami)
  fi
  local sudocmd
  if [ ! -z "$3" ]; then
    sudocmd='sudo '
  else
    sudocmd=' '
  fi
  local hostnameshellcmd
  hostnameshellcmd='$(hostname)'
  ssh -t ${1} "clear; echo \"Logging into host ${1}  identifying as ${hostnameshellcmd}\"; ${sudocmd} screen -DR -S ${screenname}"
}

uconv() {
  # Convert units using GNU Units but remove the noise
  # Also filter out "to" from the arugments because units doesn't speak Englinewargs[-1]h
  # And my brain always seems to type it this way
  newargs=()
  for arg in "$@"; do
    if [ "${arg}" != 'to' ]; then
      newargs+=("${arg}")
    fi
  done
  units "${newargs[@]/#/}" | head -n 1 | tr -d ' \t' | cut -c 2-
}

uconvu() {
  # Convert units using GNU Units but remove the noise
  # Also filter out "to" from the arugments because units doesn't speak English
  # And my brain always seems to type it this way
  newargs=()
  for arg in "$@"; do
    if [ "${arg}" != 'to' ]; then
      newargs+=("${arg}")
    fi
  done
  res=$(units "${newargs[@]/#/}" | head -n 1 | tr -d ' \t' | cut -c 2-)
  echo "${res}${newargs[-1]}"
}
