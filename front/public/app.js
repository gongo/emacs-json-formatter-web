new Vue({
    el: '#main',
    data: {
        original: '{"food": "pizza", "price": 1200, "foodstuff": ["cheese", "cheese", "cheese"]}',
        formatted: '',
        errorMessage: ''
    },
    methods: {
        reformat: function (event) {
            var vm = this;

            if (vm.original === '') {
                return;
            }

            vm.formatted = '';
            vm.errorMessage = '';

            superagent
                .post('https://emacs-json-formatter-api.herokuapp.com/api/format')
                .type('form')
                .send({ q: vm.original })
                .end(function(err, res) {
                    if (res.ok) {
                        vm.formatted = res.text;
                    } else {
                        var reason = res.body.reason;
                        if (res.body.data) {
                            var line = res.body.data.line;
                            var pos  = res.body.data.position;

                            reason += ': line ' + line + ' (pos: ' + pos + ')';
                        }

                        vm.errorMessage = reason;
                    }
                });
        },
        selectFormatted: function(event) {
            event.target.select();
        }
    }
})
