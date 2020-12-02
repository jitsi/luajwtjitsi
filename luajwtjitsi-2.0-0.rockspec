package = "luajwtjitsi"
version = "2.0-0"

source = {
	url = "git://github.com/jitsi/luajwtjitsi/",
	tag = "v2.0",
}

description = {
	summary = "JSON Web Tokens for Lua",
	detailed = "Very fast and compatible with pyjwt, php-jwt, ruby-jwt, node-jwt-simple and others",
	homepage = "https://github.com/jitsi/luajwtjitsi/",
	license = "MIT <http://opensource.org/licenses/MIT>"
}

dependencies = {
	"lua >= 5.1",
	"luaossl >= 20190731-0",
	"lua-cjson == 2.1.0-1",
	"lbase64 >= 20120807-3"
}

build = {
	type = "builtin",
	modules = {
		luajwtjitsi = "luajwtjitsi.lua"
	},
	copy_directories = {
		"test"
	}
}
