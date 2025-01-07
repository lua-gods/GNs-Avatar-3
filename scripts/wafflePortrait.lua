local waffle = models.waffle:copy("portrait")
models:addChild(waffle)
waffle:setVisible(true)
waffle:setParentType("PORTRAIT")

waffle
:setScale(0.5,0.5,0.5)
:setPos(0,4,-4)

waffle.preRender = function ()
   waffle:setRot(50,-world.getTime(),0)
end