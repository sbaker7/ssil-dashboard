God.watch do |w|
    w.name = "dashboard"
    w.group = "ssil-dashboard"
    w.dir = "/home/hercules/ssil-dashboard"
    w.env = { 'HOME' => "/home/hercules",
                'PATH' => "/home/hercules/.rbenv/shims:/home/hercules/.rbenv/bin:/home/hercules/.rbenv/shims:/home/hercules/.rbenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games",
                'PTV_DEVELOPER_KEY' => "1000089",
                'PTV_SECURITY_KEY' => "f2faba58-ad71-11e3-8bed-0263a9d0b8a0",
                'SONOS_URI' => "http://202af9d6.ngrok.io/playing",
                'WHEREABOUTS_URI' => "http://128.199.89.147:3000/states",
                'CHOMPY_WEBHOOK_URI' => "https://hooks.slack.com/services/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",
                'KEEN_WEBHOOK_URI' => "https://hooks.slack.com/services/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"
             }
    w.start = "dashing start"
    w.keepalive
end
