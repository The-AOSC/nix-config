{...}: {
  services.kanata = {
    enable = true;
    keyboards.default = {
      extraDefCfg = ''
        process-unmapped-keys yes
      '';
      config = ''
        #|
        (defsrc                                                             ins  del
          esc  f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12   prnt kp/  kp*  power
          grv  1    2    3    4    5    6    7    8    9    0    -    =     bspc kp-  kp+  nlck
          tab   q    w    e    r    t    y    u    i    o    p    [    ]    \    kp7  kp8  kp9
          caps   a    s    d    f    g    h    j    k    l    ;    '        ret  kp4  kp5  kp6
          lsft    z    x    c    v    b    n    m    ,    .    /            rsft kp1  kp2  kp3
          lctl lmet lalt         spc          ralt      rctl left up   down rght kp0  kp.  kprt)
        |#

        (defsrc)

        (defalias
          rlt (tap-dance-eager 1000 (ralt (layer-while-held ralt-mode-select))))
        (deflayermap (default)
          caps esc
          ralt @rlt)

        (defvirtualkeys
          vkey-mouse-ctl (layer-while-held mouse-ctl)
          vkey-default (multi (on-press release-virtualkey vkey-mouse-ctl)))

        (deflayermap (ralt-mode-select)
          esc (on-press tap-virtualkey vkey-default)
          caps (on-press tap-virtualkey vkey-default)
          m (on-press press-virtualkey vkey-mouse-ctl))

        (defvirtualkeys
          vkey-mlft mlft
          vkey-mrgt mrgt
          vkey-mmid mmid
          vkey-mouse-left  (tap-hold 200 200 (movemouse-left  200 1) (movemouse-left  20 1))
          vkey-mouse-right (tap-hold 200 200 (movemouse-right 200 1) (movemouse-right 20 1))
          vkey-mouse-up    (tap-hold 200 200 (movemouse-up    200 1) (movemouse-up    20 1))
          vkey-mouse-down  (tap-hold 200 200 (movemouse-down  200 1) (movemouse-down  20 1)))
        (deflayermap (mouse-ctl)
          j (multi (on-press press-vkey vkey-mlft) (on-release release-vkey vkey-mlft))
          k (multi (on-press press-vkey vkey-mrgt) (on-release release-vkey vkey-mrgt))
          i (multi (on-press press-vkey vkey-mmid) (on-release release-vkey vkey-mmid))
          o (layer-while-held mouse-ctl-hold)
          n (tap-hold 200 200 (mwheel-down  200 120) (mwheel-down  20 12))
          p (tap-hold 200 200 (mwheel-up    200 120) (mwheel-up    20 12))
          h (tap-hold 200 200 (mwheel-left  200 120) (mwheel-left  20 12))
          l (tap-hold 200 200 (mwheel-right 200 120) (mwheel-right 20 12))
          kp7 (multi (on-press press-vkey vkey-mouse-up)    (on-release release-vkey vkey-mouse-up)
                     (on-press press-vkey vkey-mouse-left)  (on-release release-vkey vkey-mouse-left))
          kp8 (multi (on-press press-vkey vkey-mouse-up)    (on-release release-vkey vkey-mouse-up))
          kp9 (multi (on-press press-vkey vkey-mouse-up)    (on-release release-vkey vkey-mouse-up)
                     (on-press press-vkey vkey-mouse-right) (on-release release-vkey vkey-mouse-right))
          kp4 (multi (on-press press-vkey vkey-mouse-left)  (on-release release-vkey vkey-mouse-left))
          kp6 (multi (on-press press-vkey vkey-mouse-right) (on-release release-vkey vkey-mouse-right))
          kp1 (multi (on-press press-vkey vkey-mouse-down)  (on-release release-vkey vkey-mouse-down)
                     (on-press press-vkey vkey-mouse-left)  (on-release release-vkey vkey-mouse-left))
          kp2 (multi (on-press press-vkey vkey-mouse-down)  (on-release release-vkey vkey-mouse-down))
          kp3 (multi (on-press press-vkey vkey-mouse-down)  (on-release release-vkey vkey-mouse-down)
                     (on-press press-vkey vkey-mouse-right) (on-release release-vkey vkey-mouse-right)))
        (deflayermap (mouse-ctl-hold)
          j (on-press press-vkey vkey-mlft)
          k (on-press press-vkey vkey-mrgt)
          i (on-press press-vkey vkey-mmid))
      '';
    };
  };
}
