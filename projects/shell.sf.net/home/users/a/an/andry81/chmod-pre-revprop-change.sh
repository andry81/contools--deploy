#!/bin/bash

for i in `find /home/svn/p -name pre-revprop-change`; do
  echo $i
  chmod 755 $i
done
