{lib, ...}: {
  lib.hostnameToIpv6Host = string: let
    validChars = lib.stringToCharacters "abcdefghijklmnopqrstuvwxyz-";
    charToCode = char: (lib.lists.findFirstIndex (c: c == char) (throw "unsupported character '${char}'") validChars) + 1;
    codes = lib.map charToCode (lib.stringToCharacters (lib.toLower string));
    codesToFields = codes:
      if (lib.length codes) < 2
      then codes
      else let
        prev = codesToFields (lib.init codes);
        shift = lib.map (p: p * (lib.length validChars)) prev;
        next = (lib.init shift) ++ [((lib.last shift) + (lib.last codes))];
        norm = lib.zipListsWith (a: b: (lib.div a (16 * 16 * 16 * 16)) + (lib.mod b (16 * 16 * 16 * 16))) (next ++ [0]) ([0] ++ next);
        normalized =
          if (lib.head norm) == 0
          then lib.tail norm
          else norm;
      in
        if (lib.length prev) > 4
        then prev
        else if (lib.length normalized) > 4
        then [0] ++ prev
        else normalized;
    fields = lib.map lib.toHexString (lib.takeEnd 4 (codesToFields codes));
  in
    (
      if (lib.length fields) < 4
      then "::"
      else ":"
    )
    + (lib.toLower (lib.join ":" fields));
}
