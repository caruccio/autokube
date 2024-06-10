#!/bin/bash

function kubectl()
{
  echo -e "\033[32m+ kubectl $*\033[0m" >&2

  command kubectl "$@"
}
