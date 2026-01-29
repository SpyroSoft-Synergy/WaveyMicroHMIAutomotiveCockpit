#include "iconcodes.h"

QString IconCode::toString(int code) {
    //https://www.weatherapi.com/docs/weather_conditions.json
    switch (code) {
        case 1000: return "sun";
        case 1003: return "sun_with_cloud";
        case 1006: return "clouds";
        case 1009: return "clouds";
        case 1030: return "clouds";
        case 1063: return "sun_with_cloud";
        case 1066: return "sun_with_cloud";
        case 1069: return "sun_with_cloud";
        case 1072: return "clouds";
        case 1087: return "sun_with_cloud";
        case 1114: return "snow";
        case 1117: return "blizzard";
        case 1135: return "clouds";
        case 1147: return "clouds";
        case 1150: return "rain";
        case 1153: return "rain";
        case 1168: return "rain";
        case 1171: return "rain";
        case 1180: return "rain";
        case 1183: return "rain";
        case 1186: return "rain";
        case 1189: return "rain";
        case 1192: return "rain";
        case 1195: return "rain";
        case 1198: return "rain";
        case 1201: return "rain";
        case 1204: return "rain";
        case 1207: return "rain";
        case 1210: return "snow";
        case 1213: return "snow";
        case 1216: return "snow";
        case 1219: return "snow";
        case 1222: return "snow";
        case 1225: return "snow";
        case 1237: return "snow";
        case 1240: return "rain";
        case 1243: return "rain";
        case 1246: return "rain";
        case 1252: return "rain";
        case 1255: return "snow";
        case 1258: return "snow";
        case 1261: return "snow";
        case 1264: return "snow";
        case 1273: return "rain_with_lightning";
        case 1276: return "rain_with_lightning";
        case 1279: return "lightning";
        case 1282: return "lightning";
    }
    return "";
}
