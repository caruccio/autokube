#!/bin/bash

function kubectl()
{
  echo "\033[32m+ kubectl $*\033[0m" >&2

  command kubectl "$@"
}
