# Navigation

Navigation application for Wavey. Provides map display and navigation functionality using Qt Location with MapLibre GL.

## QtLocation

This application requires QtLocation, which is not available via standard Qt installers for Qt 6.x. The Docker image includes QtLocation built from source with the required MapLibre GL patches.

If building outside Docker, see `docker/Dockerfile` for the QtLocation build steps. The ICU patch for Linux is available at `docker/maplibre-icu.patch`.
