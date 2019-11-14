_ = require 'phoenix_html'
_ = require 'bootstrap'
_ = require '../css/app.scss'

{Socket} = require 'phoenix'
{LiveSocket} = require 'phoenix_live_view'

$      = require 'jquery'
jQuery = require 'jquery'

hooks = {}

liveSocket = new LiveSocket("/live", Socket, hooks: hooks)
liveSocket.connect()

$(document).ready ->