local application = require("test.application")

describe("library app", function()
    local app = application()
    it("answers the phone", function()
        app.should.channel.answer()
    end)
    it("says hello", function()
        app.should.channel.say("Hello. Enter a 5 digit zip code to get a list of nearby public libraries.")
    end)
    it("gathers a zip code", function()
        app.should.channel.gather("53212")
    end)
    it("geocodes the zip"), function()
       app.should.http.get({
            data='{"lng":"-87.9076436873173"}',
            data='{"lat":"43.072112173636"}'
        }, nil)
    end)
    it("says the temperature", function()
        app.should.channel.say("The current temperature in Milwaukee is 80 degrees. Thanks for calling!")
    end)
    it("hangs up", function()
        app.should.channel.hangup()
    end)
end)

