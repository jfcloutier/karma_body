# KarmaBody

A Web app to access the actuators and sensors of a Lego robot's body, real or simulated.

## REST API

Assuming the body is hosted at `http://192.168.50.242:4000`:

```bash
 $ wget -q -O - http://192.168.50.242:4000/api/sensors

{"sensors":[{"id":"touch_in1","type":"touch","host":"http://192.168.50.242:4000","class":"sensor","capabilities":{"domain":["pressed","released"],"sense":"contact"}}]}

$ wget -q -O - http://192.168.50.242:4000/api/sense/touch_in1/contact

{"sensor":"touch_in1","sensed":"released"}
```
