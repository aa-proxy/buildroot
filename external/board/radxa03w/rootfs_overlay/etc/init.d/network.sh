DELAY=1

## TODO: REMOVE
mkdir /var/lib/misc -p

echo "Bringing network DOWN"
ifdown -a

echo "Sleeping for $DELAY seconds..."
sleep $DELAY

printf "Starting network: "
ifup -a
[ $? = 0 ] && echo "OK" || echo "FAIL"
