(require 'elnode)
(require 'json-reformat)

(defvar ejf/api->public-dir
  (concat (file-name-directory
           (or (buffer-file-name) load-file-name))
          "public/"))

(defun ejf/api/error-json-response (reason &optional data)
  (let ((j `(("message" . "JSON formatting error")
             ("reason"  . ,reason))))
    (when data
      (add-to-list 'j `("data" . ,data)))
    (json-encode j)))

(defun ejf/api/json-format-post-handler (httpcon)
  (let ((json (elnode-http-param httpcon "q"))
        (status 200)
        response)
    (if (null json)
        (progn
          (setq status 400)
          (setq response (ejf/api/error-json-response "No JSON data")))
      (condition-case errvar
          (setq response (json-reformat-from-string json))
        (json-reformat-error
         (let ((reason   (nth 1 errvar))
               (line     (nth 2 errvar))
               (position (nth 3 errvar)))
           (setq status 400)
           (setq response (ejf/api/error-json-response "JSON bad format"
                                                   `(("reason"   . ,reason)
                                                     ("line"     . ,line)
                                                     ("position" . ,position))))))
        (error
         (setq status 500)
         (setq response (ejf/api/error-json-response "Unknown server error")))))
    (elnode-http-start httpcon status
                       '("Content-type" . "application/json")
                       '("Access-Control-Allow-Origin" . "*"))
    (elnode-http-return httpcon response)))

(defun ejf/api/json-format-handler (httpcon)
  (elnode-method httpcon
    (GET  (elnode-send-400 httpcon))
    (POST (ejf/api/json-format-post-handler httpcon))))

(defun ejf/api/root-handler (httpcon)
  (elnode-hostpath-dispatcher
   httpcon
   `(("^.*//api/format" . ejf/api/json-format-handler)
     ("^.*//"           . ,(elnode-webserver-handler-maker ejf/api->public-dir)))))

(defun ejf/api/start ()
  (elnode-start
   'ejf/api/root-handler
   :port (string-to-number (or (getenv "PORT") "8080"))
   :host "0.0.0.0"))

(provide 'ejf-api)
