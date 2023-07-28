-- Load required modules
local http = require "resty.http"
local ffi = require "ffi"
local radius = ffi.load("radius")

ffi.cdef [[
    typedef struct rad_handle rad_handle;
    rad_handle *rad_auth_open();
    void rad_close(rad_handle *h);
    int rad_put_string(rad_handle *h, int type, const char *str);
    int rad_put_addr(rad_handle *h, int type, const char *addr);
    int rad_put_int(rad_handle *h, int type, unsigned int val);
    int rad_send_request(rad_handle *h, const char *secret, unsigned int timeout, unsigned int tries);
    int rad_rcv_request(rad_handle *h);
    int rad_get_attr(rad_handle *h, char **attr, unsigned int *len);
    const char *rad_strerror(rad_handle *h);
]]

-- Configuration for RADIUS server
local radius_server = {
    host = "127.0.0.1", -- RADIUS server IP address
    port = 1812, -- RADIUS server port
    secret = "testing123", -- RADIUS server secret
    timeout = 1000, -- Timeout in milliseconds for RADIUS request
    max_tries = 3 -- Maximum number of tries to send request
}

-- Function to perform RADIUS authentication
local function radius_authentication(username, password)
    local h = radius.rad_auth_open()

    radius.rad_put_string(h, radius.RADIUS_USER_NAME, username)
    radius.rad_put_string(h, radius.RADIUS_USER_PASSWORD, password)

    local rc = radius.rad_send_request(h, radius_server.secret, radius_server.timeout, radius_server.max_tries)

    if rc ~= radius.RADIUS_RC_AUTH_SUCCESS then
        ngx.log(ngx.ERR, "RADIUS authentication failed: ", ffi.string(radius.rad_strerror(h)))
        radius.rad_close(h)
        return false
    end

    local attr = ffi.new("char*[1]")
    local len = ffi.new("unsigned int[1]")

    rc = radius.rad_rcv_request(h)

    while rc > 0 do
        rc = radius.rad_get_attr(h, attr, len)
        if rc > 0 then
            -- Process additional attributes if needed
            -- For example, you can inspect the received attributes to extract user information.
        end
    end

    radius.rad_close(h)

    return true
end

-- Main authentication logic
local function authenticate()
    ngx.req.read_body()
    local args, err = ngx.req.get_post_args()

    if not args then
        ngx.log(ngx.ERR, "Failed to get post args: ", err)
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end

    local username = args.username
    local password = args.password

    if not username or not password then
        ngx.exit(ngx.HTTP_BAD_REQUEST)
    end

    local authenticated = radius_authentication(username, password)

    if authenticated then
        ngx.say("Authentication successful")
    else
        ngx.say("Authentication failed")
        ngx.exit(ngx.HTTP_UNAUTHORIZED)
    end
end

-- Call the main authentication function
authenticate()
