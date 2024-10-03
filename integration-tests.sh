#!/usr/bin/env bash
set -e

./build.sh --load --tag anarion/postfix
cd integration-tests

FIND="$(which find)"

# Support running on macOS with GNU installed under "g*" prefix
if command -v gfind > /dev/null 2>&1; then
    FIND="$(which gfind)"
fi

DOCKER_COMPOSE="docker-compose"
if docker --help | grep -q -F 'compose*'; then
    DOCKER_COMPOSE="docker compose"
fi

run_test() {
    local exit_code
    echo
    echo
    echo "☆☆☆☆☆☆☆☆☆☆ $1 ☆☆☆☆☆☆☆☆☆☆"
    echo
    (
        cd "$1"
        set +e
        $DOCKER_COMPOSE up --build --abort-on-container-exit --exit-code-from tests
        exit_code="$?"

        $DOCKER_COMPOSE down -v
        if [[ "$exit_code" != 0 ]]; then
            exit "$exit_code"
        fi
        set -e
    )
}

if [[ $# -gt 0 ]]; then
    while [[ -n "$1" ]]; do
        run_test "$1"
        shift
    done
else
    for i in `${FIND} -maxdepth 1 -type d | grep -Ev "^./(tester|xoauth2)" | sort`; do
        i="$(basename "$i")"
        if [ "$i" == "." ] || [ "$i" == ".." ]; then
            continue
        fi
        run_test $i
    done
fi
