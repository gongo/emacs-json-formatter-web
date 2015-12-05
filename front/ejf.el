(require 'elnode)

(defvar ejf->public-dir
  (concat (file-name-directory
           (or (buffer-file-name) load-file-name))
          "public/"))

(defun ejf/start ()
  (elnode-start
   (elnode-webserver-handler-maker ejf->public-dir)
   :port (string-to-number (or (getenv "PORT") "8080"))
   :host "0.0.0.0"))

(provide 'ejf)
