import '../../../core/models/iptv_models.dart';

class WallpaperMapper {
  static String getHeroWallpaper(String channelCleanName, EpgProgram? currentProgram) {
    if (channelCleanName.contains('laliga') || channelCleanName.contains('premier') || channelCleanName.contains('dazn1') || channelCleanName.contains('dazn2')) {
      return 'https://images.unsplash.com/photo-1522778119026-d647f0596c20?q=80&w=1920&auto=format&fit=crop';
    } else if (channelCleanName.contains('premier') || channelCleanName.contains('dazn1') || channelCleanName.contains('dazn2')) {
      return 'https://r2.thesportsdb.com/images/media/league/fanart/wxprwf1707716890.jpg'; // just another laliga fanart for now
    } else if (channelCleanName.contains('f1') || channelCleanName.contains('formula')) {
      return 'https://r2.thesportsdb.com/images/media/league/fanart/hreocd1620552411.jpg';
    } else if (channelCleanName.contains('motogp')) {
      return 'https://r2.thesportsdb.com/images/media/league/fanart/vvwuxq1432213976.jpg';
    } else if (channelCleanName.contains('campeones') || channelCleanName.contains('champions')) {
      return 'https://r2.thesportsdb.com/images/media/league/fanart/r4805d1784729827.jpg';
    } else if (channelCleanName.contains('nba') || channelCleanName.contains('baloncesto') || channelCleanName.contains('acb')) {
      return 'https://images.unsplash.com/photo-1504450758481-7338eba7524a?q=80&w=1920&auto=format&fit=crop';
    } else if (channelCleanName.contains('golf')) {
      return 'https://images.unsplash.com/photo-1535139262971-c51845709a48?q=80&w=1920&auto=format&fit=crop';
    } else if (channelCleanName.contains('tenis')) {
      return 'https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?q=80&w=1920&auto=format&fit=crop';
    } else if (channelCleanName.contains('cine') || channelCleanName.contains('pelicula') || channelCleanName.contains('drama')) {
      return 'https://loremflickr.com/1920/1080/cinema,movie/all?lock=9';
    }

    // Abstract generic for anything else
    return 'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?q=80&w=1920&auto=format&fit=crop'; 
  }
}
