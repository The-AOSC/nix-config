{pkgs, ...}: {
  imports = [
    ./colors.nix
  ];
  home.shell.enableFishIntegration = true;
  programs.fish = {
    enable = true;
    loginShellInit = ''
      ${pkgs.fastfetch}/bin/fastfetch
    '';
    interactiveShellInit = ''
      fish_hybrid_key_bindings
      set -g fish_cursor_insert block

      # Commands to run in interactive sessions can go here

      # fish prompt overide function to late
      function fish_mode_prompt
      end

      alias mv='mv -i'
      alias rm='rm -I --preserve-root'
      alias cp='cp -i'
      export TIME_STYLE=long-iso
      alias ls='ls -lahv --color=auto --group-directories-first'
      alias ll='ls -lahv --color=auto --group-directories-first'
      alias kk='ls -lahv --color=auto --group-directories-first'
      alias l='ls -lahv --color=auto --group-directories-first'

      alias sl='ls $argv | rev #'

      alias doasls='doas ls -lahv --color=always --group-directories-first'
      alias watchls='watch --color --no-title --exec ls -lahv --color=always --group-directories-first --'
      alias watchip='watch --color --no-title --interval=0 --exec ip --color'
      alias view="vim -R"
      alias decolor="sed 's|\x1b\[[;0-9]*m||g'"

      alias cal='cal -m'

      #alias lynxs='/usr/bin/lynx https://duckduckgo.com/lite/'

      alias copy='wezterm start --cwd "$(pwd)" -- fish &> /dev/null & disown'
      alias disexit='disown && exit'

      alias transe='trans -j -b en:ru'
      alias transev='trans -j en:ru'
      alias transed='trans -b en:ru'
      alias transevd='trans en:ru'

      alias transr='trans -j -b ru:en'
      alias transrv='trans -j ru:en'
      alias transrd='trans -b ru:en'
      alias transrvd='trans ru:en'

      alias transer='trans -j -b ru:en'
      alias transerv='trans -j ru:en'
      alias transerd='trans -b ru:en'
      alias transervd='trans ru:en'

      alias transa='trans -j -b :ru'
      alias transav='trans -j :ru'
      alias transad='trans -b :ru'
      alias transavd='trans :ru'

      alias transae='trans -j -b :en'
      alias transaev='trans -j :en'
      alias transaed='trans -b :en'
      alias transaevd='trans :en'

      #alias new-year='alacritty -o font.size=20 -e sh -c "sleep 1; ~/new-year.sh" & disown && exit'

      alias ttysolitaire='ttysolitaire --no-background-color'

      alias weather='curl wttr.in'

      #alias makestrongpasswd='makepasswd --string " !\\"#\$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"'

      alias feh='feh -.'

      alias mypubip='curl -s https://icanhazip.com'  # https://2ip.ru

      alias which='alias | command which --tty-only --read-alias'

      set yt_dlp_opts
      alias yt-dlp='ionice -c 3 yt-dlp --throttled-rate 100K --embed-chapters --embed-metadata --sub-langs all,-live_chat --embed-subs --no-write-auto-subs --format "bestaudio+bestvideo*[format_note!=Premium]/bestaudio+bestvideo*[protocol*=m3u8]" --sponsorblock-mark "-all,sponsor" --retry-sleep fragment:20 --socket-timeout 10 --no-overwrites $yt_dlp_opts'
      alias yt-dlp-section='yt-dlp -o "%(title)s [%(section_start)d - %(section_end)d] [%(id)s].%(ext)s" --download-sections'  # format: "*MM:SS-MM:SS"
      alias yt-dlp-playlist='yt-dlp -o "%(playlist_index)i - %(title)s [%(id)s].%(ext)s"'
      function yt-dlp-autonumber
          if [ (pwd) = ~ ]
              mkdir dumb -p 2> /dev/null
              cd dumb
          end
          #if echo $argv[1] | grep -Pq '^[0-9]+$'
          #set counter $argv[1]
          #set argv $argv[2..]
          #else
          set counter 1
          while true
              count $counter' '* > /dev/null || break
              set counter (math $counter + 1)
          end
          #end
          for id in $argv
              if echo $id | grep -Pq '^[0-9]+$'
                  set counter $id
              else
                  yt-dlp --no-playlist -o "$counter - %(title)s [%(id)s].%(ext)s" -- $id
                  while true
                      set counter (math $counter + 1)
                      count $counter' '* > /dev/null || break
                  end
              end
          end
      end
      function yt-dlp-no-skip-autonumber
          #if echo $argv[1] | grep -Pq '^[0-9]+$'
          #set counter $argv[1]
          #set argv $argv[2..]
          #else
          set counter 1
          #end
          for id in $argv
              if echo $id | grep -Pq '^[0-9]+$'
                  set counter $id
              else
                  yt-dlp --no-playlist -o "$counter - %(title)s [%(id)s].%(ext)s" -- $id
                  set counter (math $counter + 1)
              end
          end
      end
      alias yt-dlp-list-standard='yt-dlp --flat-playlist --print "%(id)s (%(uploader)s) - %(title)s"'
      #alias yt-dlp-grep-id='grep -Po "(?<=\\[).+?(?=\\])"'
      function yt-dlp-grep-id
          if echo -- $argv | grep -Pq "(?<=\\[).+?(?=\\])"
              echo $argv | grep -Po "(?<=\\[).+?(?=\\])"
          else
              grep -Po "(?<=\\[).+?(?=\\])" $argv
          end
      end
      set yt_dlp_cookies --cookies-from-browser vivaldi:Default
      function yt-dlp-watch
          if echo -- $argv | grep -Pq "(?<=\\[).+?(?=\\])"
              yt-dlp --cookies-from-browser vivaldi:Default --skip-download --mark-watched --sub-langs -en,-ru --no-embed-subs --no-write-auto-subs --simulate -- (echo -- $argv | yt-dlp-grep-id)
          else
              yt-dlp --cookies-from-browser vivaldi:Default --skip-download --mark-watched --sub-langs -en,-ru --no-embed-subs --no-write-auto-subs --simulate -- $argv
          end
      end
      #alias yt-dlp-watch='yt-dlp --cookies-from-browser vivaldi:Default --skip-download --mark-watched --'
      alias yt-dlp-list-history='yt-dlp-list-standard :ythistory $yt_dlp_cookies'
      #alias yt-dlp-uploader='yt-dlp --print "%(uploader)s (https://www.youtube.com/%(uploader_id)s/videos) / (https://www.youtube.com/channel/%(uploader_id)s/videos)" --'
      alias yt-dlp-uploader='yt-dlp --print "%(uploader_url)s" --'
      function yt-dlp-infojson
          view (yt-dlp --no-mark-watched --skip-download --dump-single-json  \
              -- $argv | jq | psub)
      end
      function yt-dlp-infojson-comments
          view (yt-dlp --no-mark-watched --skip-download --dump-single-json  \
              --extractor-args youtube:max_comments=all,100,all,100 \
              --write-comments                                      \
              -- $argv | jq | psub)
      end
      alias yt-dlp-comments-infojson='yt-dlp-infojson-comments'

      alias ttyplay='mpv --really-quiet --vo=caca --volume-max=1000'
      alias ttyfbplay='mpv --really-quiet --vo=gpu --volume-max=1000'
      alias mpclip='mpv --fs --keep-open (wl-paste)'
      alias yt-dlp-clip-mpv='yt-dlp (wl-paste) --sub-langs -en,-ru --no-embed-subs --no-write-auto-subs --no-playlist --newline --throttled-rate 1K --output - | mpv --fs --keep-open -'
      #alias mps='mpv --save-position-on-quit'
      alias ffprobe='ffprobe -hide_banner'

      alias test-prog-ls='for pos in (sed resume -e "s/ /\n/g"|grep -P "^[0-9]+\\$"); ls $pos*;echo;end #'

      function serialize-event
          echo "$XDG_RUNTIME_DIR"/fish-events/event(echo $argv|sed 's/[- ]//g')
      end
      function clear-event
          rm -f (serialize-event $argv)
      end
      function set-event
          mkdir --parents "$XDG_RUNTIME_DIR"/fish-events/
          touch (serialize-event $argv)
      end
      function wait-event
          clear-event $argv
          while [ ! -e (serialize-event $argv) ]
              sleep 5
          end
      end
      function clear-events
          rm -I "$XDG_RUNTIME_DIR"/fish-events/event* $argv
      end

      function feh-xkcd
          set link (echo -n "https://"; curl "https://xkcd.com/$argv/" --silent | grep -Pom1 '(?<=<img src="//)imgs.xkcd.com/.+?(?=")')
          echo $link
          feh $link
      end

      alias pwait="command pidwait"

      #alias work-convert='rename ii ИИ *; rename spec СПЕК *; rename sb СБ *; rename sp СП *; rename e3 Э3 *; #'
      #alias work-restore-diff='watch -n0 --color --exec fish -c "diff --color=always (sort want|uniq|psub) (sort have|uniq|psub)" #'

      alias mount-usb='doas mount -outf8,uid=(id -u),gid=(id -g)'

      #alias pagesearch='nix --extra-experimental-features "nix-command flakes" search nixpkgs $argv | decolor | bat #'
      #alias pagefullsearch='nix --extra-experimental-features "nix-command flakes" search $argv &| decolor | bat #'

      #export PASSWORD_STORE_GENERATED_LENGTH="256"
      #export PASSWORD_STORE_CHARACTER_SET="$(for i in (seq 32 126); printf "\x$(printf '%x' $i)"; end)"

      export EUID
    '';
  };
  xdg.configFile."fish/functions/fish_prompt.fish".source = ./fish_prompt.fish;
}
