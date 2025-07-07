{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.ffprobe-duration.enable = lib.mkEnableOption "ffprobe-duration";
  };
  config = lib.mkIf config.modules.ffprobe-duration.enable {
    home.packages = let
      sbcl = pkgs.sbcl.withPackages (subpkgs:
        with subpkgs; [
          cffi
          parse-float
        ]);
    in [
      (pkgs.writeScriptBin "ffprobe-duration" ''
        #!${sbcl}/bin/sbcl --script
        (require :asdf)

        (handler-bind ((asdf/parse-defsystem:bad-system-name #'muffle-warning))  ; WARNING: System definition file ... contains definition for system "parse-float-tests"
          (asdf:load-system "parse-float"))

        (defun parse-time-string (time-string)
          (let* ((pos1 (position #\: time-string))
                 (pos2 (when pos1 (position #\: time-string :start (1+ pos1)))))
            (if (and pos1 pos2)
                (list (parse-integer time-string :end pos1)
                      (parse-integer time-string :start (1+ pos1) :end pos2)
                      (parse-float:parse-float time-string :start (1+ pos2)))
                '(0 0 0))))

        (let ((total (list 0 0 0)))
          (dolist (arg uiop/image:*command-line-arguments*)
            (let ((result (handler-bind ((sb-int:stream-decoding-error #'(lambda (error)
                                                                           (let ((restart (find-restart 'sb-int:attempt-resync error)))
                                                                             (when restart
                                                                               (warn "the octet sequence ~a cannot be decoded; discarding..."
                                                                                     (sb-int:character-decoding-error-octets error))
                                                                               (invoke-restart restart))))))
                            (uiop/run-program:run-program (list "${pkgs.ffmpeg}/bin/ffprobe" "--" arg)
                                                          :ignore-error-status t
                                                          :output :string
                                                          :error-output :output))))
              (with-input-from-string (stream result)
                (do () (nil)
                    (let ((line (read-line stream nil nil)))
                      (unless line
                        (return))
                      (let ((pos1 (search "Duration: " line)))
                        (when pos1
                          (let ((pos2 (position #\, line :start (+ pos1 10))))
                            (let ((time-string (subseq line (+ pos1 10) pos2)))
                              (destructuring-bind (hours minutes seconds) (parse-time-string time-string)
                                (incf (first total) hours)
                                (incf (second total) minutes)
                                (incf (third total) seconds)
                                (format t "~2dh ~2dm ~2ds  ~s~%"
                                        hours minutes (round seconds)
                                        arg)))))))))))
          (incf (second total) (floor (third total) 60))
          (setf (third total) (rem (third total) 60))
          (incf (first total) (floor (second total) 60))
          (setf (second total) (rem (second total) 60))
          (format t "~2dh ~2dm ~2ds  TOTAL~%"
                  (first total) (second total) (round (third total))))
      '')
    ];
  };
}
