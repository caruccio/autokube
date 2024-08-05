#!/bin/bash

function kubectl()
{
  ${SHOWKUBECTL_ENABLED:-true} && echo -e "\033[1;36m+\033[0;36m kubectl $*\033[0m" >&2 || true

  command kubectl "$@"
}
