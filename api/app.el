(require 'ejf-api)

(ejf/api/start)
(while t (accept-process-output nil 1))
