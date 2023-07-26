-- Load the LuaSocket library
local socket = require("socket")

-- RADIUS server configuration
local radius_server_ip = "127.0.0.1"
local radius_server_port = 1812
local client_secret = "testing123" -- Replace this with the client's secret

-- Function to send a RADIUS packet and receive the response
local function send_radius_packet(username, password)
    local sock = socket.udp()

    -- Generate a random request identifier (1-255)
    local request_id = math.random(1, 255)

    -- Create the RADIUS Access-Request packet
    local packet = string.char(0x01, -- Code: Access-Request
    request_id, -- Identifier
    0x00, 0x00, -- Length (to be filled later)
    0x00, 0x00, 0x00, 0x00, -- Authenticator (to be filled later)
    0x01, -- Attribute: User-Name
    0x00 -- Length of User-Name (to be filled later)
    )

    -- Add the User-Name attribute value
    packet = packet .. username .. string.char(0)

    -- Add the User-Password attribute
    local authenticator = packet:sub(5, 20)
    local password_attribute = string.char(0x02, 0x12) .. authenticator .. password
    packet = packet .. password_attribute

    -- Calculate the packet length and update it in the packet
    local packet_length = string.len(packet)
    packet = packet:sub(1, 3) .. string.char(math.floor(packet_length / 256), packet_length % 256) .. packet:sub(6)

    -- Calculate the message authenticator hash and update it in the packet
    local hash_input = packet .. client_secret
    local hash_output = socket.digest("md5", hash_input)
    packet = packet:sub(1, 20) .. hash_output .. packet:sub(21)

    -- Send the packet to the RADIUS server
    sock:sendto(packet, radius_server_ip, radius_server_port)

    -- Set a timeout for the response
    sock:settimeout(5)

    -- Wait for the response
    local response, err = sock:receive()

    -- Close the socket
    sock:close()

    if response then
        -- Check the RADIUS response code (7th byte in the response)
        local response_code = response:byte(7)
        if response_code == 2 then
            return true -- Access-Accept
        else
            return false -- Access-Reject or other error
        end
    else
        return false, err -- Response not received or error occurred
    end
end

-- Read the username and password from the 'users' file
local username = "bob" -- Replace this with the username from the 'users' file
local password = "test" -- Replace this with the password from the 'users' file

-- Test the authentication function
local authenticated, err = send_radius_packet(username, password)
if authenticated then
    print("Authentication successful.")
else
    print("Authentication failed. Error: " .. (err or "Unknown"))
end
