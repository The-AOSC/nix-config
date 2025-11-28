{
  osConfig,
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./fish-command-timer.nix
    ./nmcli.nix
  ];
  options = {
    modules.fish.enable = lib.mkEnableOption "fish";
  };
  config = lib.mkIf config.modules.fish.enable {
    home.shell.enableFishIntegration = true;
    programs.fish = {
      enable = true;
      loginShellInit = ''
        ${pkgs.fastfetch}/bin/fastfetch
      '';
      interactiveShellInit = ''
        set -p fish_complete_path ~/.config/fish/completions

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
        alias l='ls -lahv --color=auto --group-directories-first'

        alias sl='ls $argv | rev #'

        alias doasls='doas ls -lahv --color=always --group-directories-first'
        alias watchls='watch --color --no-title --exec ls -lahv --color=always --group-directories-first --'
        alias watchip='watch --color --no-title --interval=0 --exec ip --color'
        alias decolor="sed 's|\x1b\[[;0-9]*m||g'"

        alias cal='cal -m'

        alias disexit='disown && exit'

        alias ttysolitaire='ttysolitaire --no-background-color'

        alias feh='feh -.'

        alias which='alias | command which --tty-only --read-alias'

        alias torl='curl --proxy socks5h://localhost:${builtins.toString osConfig.services.tor.client.socksListenAddress.port}'

        set yt_dlp_opts
        alias yt-dlp='ionice -c 3 yt-dlp --throttled-rate 100K --embed-chapters --embed-metadata --sub-langs all,-live_chat --embed-subs --no-write-auto-subs --format "bestaudio+bestvideo[format_note!=Premium]/best[format_note!=Premium]" --sponsorblock-mark "-all,sponsor" --retry-sleep fragment:20 --socket-timeout 10 --no-overwrites $yt_dlp_opts'
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
        set yt_dlp_cookies --cookies-from-browser firefox:${config.home.homeDirectory}/${config.programs.librewolf.profilesPath}/${config.programs.librewolf.profiles.default.path}
        function yt-dlp-watch
            if echo -- $argv | grep -Pq "(?<=\\[).+?(?=\\])"
                yt-dlp $yt_dlp_cookies --skip-download --mark-watched --sub-langs -en,-ru --no-embed-subs --no-write-auto-subs --simulate -- (echo -- $argv | yt-dlp-grep-id)
            else
                yt-dlp $yt_dlp_cookies --skip-download --mark-watched --sub-langs -en,-ru --no-embed-subs --no-write-auto-subs --simulate -- $argv
            end
        end
        #alias yt-dlp-watch='yt-dlp $yt_dlp_cookies --skip-download --mark-watched --'
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

        alias yt-dlp-clip-mpv='yt-dlp (wl-paste) --sub-langs -en,-ru --no-embed-subs --no-write-auto-subs --no-playlist --newline --throttled-rate 1K --output - | mpv --fs --keep-open -'
        alias ffprobe='ffprobe -hide_banner'

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

        alias mount-usb='doas mount -outf8,uid=(id -u),gid=(id -g)'

        export EUID
      '';
    };
    xdg.configFile = {
      "fish/functions/fish_prompt.fish".source = ./fish_prompt.fish;
    };
  };
}
