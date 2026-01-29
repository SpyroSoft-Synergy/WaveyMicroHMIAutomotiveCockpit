# Wavey

## PRE-REQUISTIES
- Android Debug Bridge
- access to device (target)

---

## CONNECT DEVICE
- Connect target device via usb-c to your machine.

---

## UNINSTALL
- Need to remove old version of application in target device
    ```
    adb uninstall com.spyrosoft.wavey
    ```

---

## INSTALL
- Need to add new version of application to target device
    ```
    adb install {name_of_binary_application}.apk
    ```

---

## LAUNCH
- Start application on target device
    ```
    adb shell am start -n com.spyrosoft.wavey/.GestureScreen --display 0
    adb shell am start -n com.spyrosoft.wavey/.MainScreen --display 1
    ```

---

## ADDIDTIONS
- Do a few reboots of the device to set the `wavey` app as the startup app
    ```
    adb reboot
    ```
