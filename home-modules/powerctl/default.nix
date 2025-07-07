{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.powerctl.enable = lib.mkEnableOption "powerctl";
  };
  config = lib.mkIf config.modules.powerctl.enable {
    home.packages = [
      (pkgs.writeScriptBin "powerctl" ''
        #!${pkgs.python3}/bin/python
        import encodings
        import sys
        import os

        if len(sys.argv) == 2:
            if (sys.argv[1] in (".Lock", ".Xtrlock", ".Xtrlock-s")):
                import time
                abort = False
                try:
                    with open(f"{os.environ["XDG_RUNTIME_DIR"]}/powerctl-last-run", mode="r") as f:
                        if (time.time() - float(f.read())) < 0.25:
                            abort = True
                except Exception:
                    pass
                with open(f"{os.environ["XDG_RUNTIME_DIR"]}/powerctl-last-run{os.getpid()}", mode="w") as f:
                    f.write(f"{time.time()}")
                os.rename(f"{os.environ["XDG_RUNTIME_DIR"]}/powerctl-last-run{os.getpid()}", f"{os.environ["XDG_RUNTIME_DIR"]}/powerctl-last-run")
                if abort:
                    print("Warning: script is run too often, refusing to do anything", file=sys.stderr)
                    sys.exit(1)

        def convert_option(option, data, formatting=True):
            for key in sorted(data, key=len, reverse=True):
                value = data[key]
                substr = f"{{{key}}}" if formatting else f"{key}"
                if substr in option:
                    option = option.replace(substr, value)
            return option

        def convert_options(options):
            while True:
                for key, value in options.items():
                    new_value = convert_option(value, options)
                    if new_value != value:
                        options[key] = new_value
                        break
                else:
                    return

        def wmenu_select(input):
            pipe1_read, pipe1_write = os.pipe()
            pipe2_read, pipe2_write = os.pipe()
            if os.fork():
                os.close(pipe1_read)
                os.close(pipe2_write)
                os.write(pipe1_write, encodings.utf_8.encode("\n".join(input))[0])
                os.close(pipe1_write)
                result = encodings.utf_8.decode(os.read(pipe2_read, 1024))[0]
                os.close(pipe2_read)
                return result
            else:
                os.close(pipe1_write)
                os.close(pipe2_read)
                os.dup2(pipe1_read, 0)
                os.dup2(pipe2_write, 1)
                os.close(pipe1_read)
                os.close(pipe2_write)
                os.execlp("${pkgs.wmenu}/bin/wmenu", "wmenu", "-i")

        def main():
            options = {
                    ".Sync": "sync",
                    #".Lock": "i3lock -c 3f3f3f -f -e",
                    #".Lock-nofork": "{.Lock} --nofork",
                    ".Lock": "{.Lock-nofork} --daemonize",
                    ".Lock-nofork": "swaylock -c 3f3f3f --show-failed-attempts --ignore-empty-password",

                    ".Xtrlock": "{.Lock}",
                    ".Xtrlock-nofork": "{.Lock-nofork}",
                    ".Xtrlock-s": "{.Lock}",
                    ".Xtrlock-s-nofork": "{.Lock-nofork}",

                    #".Xtrlock": "{.Xtrlock-nofork} -f",
                    #".Xtrlock-nofork": "/usr/bin/xtrlock",
                    #".Xtrlock-s": "/usr/local/bin/xtrlock-s -f fdas",
                    #".Xtrlock-s-nofork": "/usr/local/bin/xtrlock-s fdas",

                    ".Suspend": "{.Sync}\nsystemctl suspend",
                    "Suspend": "{.Lock}\n{.Suspend}",
                    ".Hibernate": "{.Sync}\nsystemctl hibernate",
                    "Hibernate": "{.Xtrlock}\n{.Hibernate}",
                    ".Hybrid-sleep": "{.Sync}\nsystemctl hybrid-sleep",
                    "Hybrid-sleep": "{.Xtrlock}\n{.Hybrid-sleep}",
                    "Log out": "qtile cmd-obj -o cmd -f shutdown",
                    "Shutdown": "{.Sync}\nsystemctl poweroff",
                    "Reboot": "{.Sync}\nsystemctl reboot"
                    }

            convert_options(options)

            if len(sys.argv) > 1:
                if sys.argv[1] == "--help":
                    print("Suported commands:")
                    for key in options:
                        print(f"    {key}")
                    return
                for e in sys.argv[1:]:
                    if e.replace("_", " ") in options.keys():
                        res = e.replace("_", " ")
                        break
            else:
                res = wmenu_select(key for key in options.keys() if not key.startswith(".")).strip()
            if res == "all":
                res = wmenu_select(options.keys()).strip()

            command = convert_option(res, options, formatting=False)
            if command is not None:
                print(command)
                os.system(command)

        if __name__ == '__main__':
            main()
      '')
    ];
  };
}
