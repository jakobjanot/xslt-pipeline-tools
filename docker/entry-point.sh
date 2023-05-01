#!/bin/bash

set -e
for xspec in $( find /test -type f -name '*.xspec' ); do
  echo "################################################"
  printf "\n"
  echo "TEST $(basename -- $xspec)"
  printf "\n"
  /bin/bash /xspec/bin/xspec.sh -e -t $xspec || exitcode=$?
  printf "\n\n"
done

echo "################################################"
printf "\n"
if [ "$exitcode" == "0" ]; then
    echo "Result: SUCCES"
else
    echo "Result: FAILED"
fi

exit $exitcode