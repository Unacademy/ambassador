#!/bin/sh

if [ ! -z "$DIAGD_ONLY" ]; then
    echo "Not starting, since in diagd-only mode."
    exit 0
fi

# Is there an Envoy running?
AMBEX_PID="$1"

ENVOY_RUNNING=

ENVOY_PID_FILE="${ENVOY_DIR}/envoy.pid"

if [ -r "$ENVOY_PID_FILE" ]; then
    ENVOY_PID=$(cat "${ENVOY_PID_FILE}")

    if kill -0 $ENVOY_PID; then
        ENVOY_RUNNING=yes
    fi
fi

if [ -z "$DRAIN_TIME" ]; then
    DRAIN_TIME=600
fi

if [ -z "$DRAIN_TIME_PARENT" ]; then
    DRAIN_TIME_PARENT=600
fi



if [ -z "$ENVOY_RUNNING" ]; then
    # Envoy isn't running. Start it.
    envoy $ENVOY_DEBUG -c "${ENVOY_BOOTSTRAP_FILE}" --drain-time-s $DRAIN_TIME --parent-shutdown-time-s $DRAIN_TIME_PARENT &
    ENVOY_PID="$!"
    echo "KICK: started Envoy as PID $ENVOY_PID"

    echo "$ENVOY_PID" > "$ENVOY_PID_FILE"
fi

# Once envoy is running, poke Ambex.
echo "KICK: kicking ambex"
kill -HUP "$AMBEX_PID"
