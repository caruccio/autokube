#!/bin/bash

function kubectl()
{
  ${SHOWKUBECTL_ENABLED:-true} && echo -e "\033[32m+ kubectl $*\033[0m" >&2 || true

  command kubectl "$@"
}
