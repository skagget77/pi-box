# pi-box ssh-agent helper.
#
# Sourced from ~/.bashrc in every interactive shell. Keeps ONE ssh-agent
# alive for the lifetime of the container (ssh-agent daemonizes when run
# via `ssh-agent -s`, so it outlives the shell that started it), loads
# the private keys from ~/.ssh, and exports SSH_AUTH_SOCK.
#
# - First shell after the container is (re)created: starts the agent and
#   runs ssh-add (prompts for the passphrase in that shell).
# - Later shells: agent and keys found live -> just export the socket.
# - A key that is added to ~/.ssh after the agent started is picked up on
#   the next shell (the "no identities" check restarts the agent).

# Keep a working agent this shell already has (respect existing env).
if [ -n "${SSH_AUTH_SOCK:-}" ] && ssh-add -l >/dev/null 2>&1; then
    return 0
fi

pi_agent_sock=/tmp/ssh-agent.sock
pi_agent_pid=/tmp/ssh-agent.pid

# Is our agent alive AND holding at least one identity? (ssh-add -l
# returns non-zero for both "cannot connect" and "agent has no identities".)
if [ -S "$pi_agent_sock" ] && SSH_AUTH_SOCK="$pi_agent_sock" ssh-add -l >/dev/null 2>&1; then
    export SSH_AUTH_SOCK="$pi_agent_sock"
    unset SSH_AGENT_PID 2>/dev/null || true
    return 0
fi

# Restart: best-effort kill of a stale agent, then start a fresh one.
kill "$(cat "$pi_agent_pid" 2>/dev/null)" 2>/dev/null
rm -f "$pi_agent_sock"

eval "$(ssh-agent -a "$pi_agent_sock" -s)"
echo "$SSH_AGENT_PID" > "$pi_agent_pid"

for pi_key in "$HOME"/.ssh/*; do
    case "$pi_key" in
        *.pub|config|known_hosts|authorized_keys) continue ;;
    esac
    # Only attempt files that look like private keys.
    head -1 "$pi_key" 2>/dev/null | grep -q 'PRIVATE KEY' || continue
    ssh-add "$pi_key"
done

# The agent outlives this shell; make sure nothing here (e.g. a later
# `ssh-agent -k` or trap) assumes the shell owns it.
unset SSH_AGENT_PID 2>/dev/null || true
