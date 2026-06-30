return function(Tabs)
    local secDiscord = Tabs.info:AddSection("Discord", "solar/chat-round-bold")

    secDiscord:AddDiscord({
        InviteCode = "ny6pJgnR6c",
    })

    secDiscord:AddDivider()

    local secTikTok = Tabs.info:AddSection("TikTok", "solar/music-note-bold")

    secTikTok:AddImage({
        Image = "https://linkspreview.netlify.app/fetchimage/https%3A%2F%2Fwww.tiktok.com%2F%40pnsdg",
        AspectRatio = "1:1",
        Radius = 10,
    })

    secTikTok:AddParagraph({
        Title = "Follow my main don't follow my shit pnsdgayahh account",
        Content = "@pnsdg",
    })

    secTikTok:AddButton({
        Title = "Copy Link",
        Icon = "solar/link-bold",
        Callback = function()
            setclipboard("https://www.tiktok.com/@pnsdg")
        end,
    })

    secTikTok:AddDivider()

    secTikTok:AddImage({
        Image = "https://linkspreview.netlify.app/fetchimage/https%3A%2F%2Fwww.tiktok.com%2F%40pnsdgayahh",
        AspectRatio = "1:1",
        Radius = 10,
    })

    secTikTok:AddParagraph({
        Title = "My dummy account",
        Content = "@pnsdgayahh",
    })

    secTikTok:AddButton({
        Title = "Copy Link",
        Icon = "solar/link-bold",
        Callback = function()
            setclipboard("https://www.tiktok.com/@pnsdgayahh")
        end,
    })

    secTikTok:AddDivider()

    local secYouTube = Tabs.info:AddSection("YouTube", "solar/videocamera-record-bold")

    secYouTube:AddImage({
        Image = "https://linkspreview.netlify.app/fetchimage/https%3A%2F%2FYouTube.com%2F%40pnsdg",
        AspectRatio = "16:9",
        Radius = 10,
    })

    secYouTube:AddParagraph({
        Title = "Subscribe to my main account of you like Minecraft content",
        Content = "@pnsdg",
    })

    secYouTube:AddButton({
        Title = "Copy Link",
        Icon = "solar/link-bold",
        Callback = function()
            setclipboard("https://m.youtube.com/@pnsdg")
        end,
    })

    secYouTube:AddDivider()

    secYouTube:AddImage({
        Image = "https://linkspreview.netlify.app/fetchimage/https%3A%2F%2FYouTube.com%2F%40pnsdgsa",
        AspectRatio = "16:9",
        Radius = 10,
    })

    secYouTube:AddParagraph({
        Title = "Lol I Left this gta account for months",
        Content = "@PnsdgSa",
    })

    secYouTube:AddButton({
        Title = "Copy Link",
        Icon = "solar/link-bold",
        Callback = function()
            setclipboard("https://www.youtube.com/@PnsdgSa")
        end,
    })

    secYouTube:AddDivider()

    secYouTube:AddImage({
        Image = "https://linkspreview.netlify.app/fetchimage/https%3A%2F%2FYouTube.com%2F%40BadpiggyTechTutorial",
        AspectRatio = "16:9",
        Radius = 10,
    })

    secYouTube:AddParagraph({
        Title = "IDK what should post on this one",
        Content = "@BadpiggyTechTutorial",
    })

    secYouTube:AddButton({
        Title = "Copy Link",
        Icon = "solar/link-bold",
        Callback = function()
            setclipboard("https://www.youtube.com/@BadpiggyTechTutorial")
        end,
    })
end
