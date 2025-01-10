{...}: {
  services.zapret = {
    enable = true;
    whitelist = [
      "googlevideo.com"
      "youtu.be"
      "youtube.com"
      "ytimg.com"
    ];
    params = [
      "--dpi-desync=fakeddisorder --dpi-desync-split-pos=2,midsld --dpi-desync-ttl=2"
      /*
      # home new
      "--dpi-desync=multisplit --dpi-desync-split-pos=2"
      "--dpi-desync=multidisorder --dpi-desync-split-pos=host+1"
      "--dpi-desync=fake --dpi-desync-ttl=2"
      "--dpi-desync=fake --dpi-desync-ttl=1 --dpi-desync-autottl=3"
      # work new
      #"--dpi-desync=multisplit --dpi-desync-split-pos=1"
      #"--dpi-desync=multidisorder --dpi-desync-split-pos=sniext+4"
      #"--dpi-desync=fake --dpi-desync-ttl=1 --dpi-desync-fake-tls=0x00000000"
      #"--dpi-desync=fake --dpi-desync-fooling=badseq --dpi-desync-fake-tls=0x00000000"
      #"--dpi-desync=fake --dpi-desync-fooling=datanoack --dpi-desync-fake-tls=0x00000000"
      #"--dpi-desync=fake --dpi-desync-fooling=md5sig"
      #"--dpi-desync=fake --dpi-desync-ttl=1 --dpi-desync-autottl=1"
      #"--dpi-desync=fake --dpi-desync-ttl=1 --dpi-desync-autottl=2"
      #"--dpi-desync=fake --dpi-desync-ttl=1 --dpi-desync-autottl=3"
      #"--dpi-desync=fake --dpi-desync-ttl=1 --dpi-desync-autottl=5 --dpi-desync-fake-tls=0x00000000"
      # work old
      "--dpi-desync=multisplit --dpi-desync-split-pos=1,midsld"
      "--dpi-desync=fake --dpi-desync-ttl=3"
      "--dpi-desync=fake --dpi-desync-fooling=badsum"
      "--dpi-desync=fake --dpi-desync-fooling=badseq"
      "--dpi-desync=fake --dpi-desync-fooling=md5sig"
      "--dpi-desync=fakeddisorder --dpi-desync-ttl=3 --dpi-desync-split-pos=midsld"
      "--dpi-desync=fakeddisorder --dpi-desync-fooling=md5sig --dpi-desync-split-pos=midsld"
      "--dpi-desync=multidisorder --dpi-desync-split-pos=sniext+1 --dpi-desync-split-seqovl=sniext"
      "--dpi-desync=fake,multidisorder --dpi-desync-ttl=1 --dpi-desync-autottl=2 --dpi-desync-split-pos=1,midsld --dpi-desync-fake-tls=0x00000000"
      "--dpi-desync=fake,multidisorder --dpi-desync-ttl=1 --dpi-desync-autottl=5 --dpi-desync-split-pos=1"
      # example
      #"--dpi-desync=split2 --dpi-desync-ttl=5 --wssize 1:6 --dpi-desync-fooling=md5sig"
      #"--dpi-desync=fake --dpi-desync-any-protocol --dpi-desync-repeats=6"
      */
    ];
  };
}
