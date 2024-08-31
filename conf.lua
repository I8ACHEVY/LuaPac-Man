function love.conf(t)
  if arg[#arg] == "-debug" then
    t.console = true
  end
end

title = "LuaPacMan"
version = "11.5"
console = false
