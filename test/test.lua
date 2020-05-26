#!/usr/bin/env lua

-- This tests encoding and decoding JWTs with each of the supported algorithms.
-- It prints out the valid tokens it creates.

-- You can confirm tokens are valid using Python's implementation, copy and paste
-- the tokens printed into the pyjwt command.
--
-- For HMAC algos: pyjwt --key=sekr1t decode TOKEN
-- For RSA algos:  pyjwt --key="$(cat test/pubkey.pem)" decode TOKEN
--
-- You'll need something like this to install the Python dependencies:
--   pip3 install pyjwt
--   pip3 install cryptography
--
-- The RSA keypair used is the JWK example in RFC 7515, converted to PEM files.

local jwt = require "luajwtjitsi"

local function read_file (filename)
	local fh = assert(io.open(filename, "rb"))
	local data = fh:read(_VERSION <= "Lua 5.2" and "*a" or "a")
	fh:close()
	return data
end

-- Test data.
local claim = {
	iss = "12345678",
	nbf = os.time(),
	exp = os.time() + 3600,
}
local header = {
	test = "test123"
}

-- Actual tests.
local TESTS = {
	{ algo = "HS256" },
	{ algo = "HS384" },
	{ algo = "HS512" },
	{ algo = "RS256", rsa = true },
	{ algo = "RS384", rsa = true },
	{ algo = "RS512", rsa = true },
}
for _, test in ipairs(TESTS) do
	-- Select key(s).
	local privkey, pubkey
	if test.rsa then
		privkey = read_file("test/privkey.pem")
		pubkey = read_file("test/pubkey.pem")
	else
		privkey = "sekr1t"
		pubkey = "sekr1t"
	end

	-- Create a token.
	local token = assert(jwt.encode(claim, privkey, test.algo, header))
	assert(type(token) == "string")

	-- Make sure it verifies and decodes.
	local decoded = assert(jwt.decode(token, pubkey, true))
	assert(type(decoded) == "table")
	assert(decoded.iss == claim.iss)
	assert(decoded.nbf == claim.nbf)
	assert(decoded.exp == claim.exp)

	-- Should get an error if signature is corrupted, unless verify is turned off.
	local bad_token = token:sub(1, #token - 10) .. 'aaaaaaaaaa'
	local decoded = assert(jwt.decode(bad_token, pubkey, false))
	assert(type(decoded) == "table")
	local decoded, err = jwt.decode(bad_token, pubkey, true)
	assert(decoded == nil, "expected failure when using bad signature")
	assert(err == "Invalid signature")

	-- Output the tokens for checking with external tool, like pyjwt.
	print("Token for " .. test.algo .. ":\n" .. token .. "\n")
end
