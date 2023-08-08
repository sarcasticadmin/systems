# Marco Polo

Use: OpenCPN navigation laptop

## Notes

Ensure that gpsd is outputing data:

```
$ tail -f /dev/ttyACM0
```

gpsd works fine with opencpn just make sure that the following are true:
  - user runnig opencpn is in the `dialout` group
  - daemon is started with `-n` so its not waiting and in NMEA mode.
