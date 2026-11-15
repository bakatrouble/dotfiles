# is_desktop: true in a graphical session that is not an SSH login.

function is_desktop -d "True in a graphical session that is not over SSH"
    not set -q SSH_CONNECTION; and begin; set -q DISPLAY; or set -q WAYLAND_DISPLAY; end
end
