import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final carApiServiceProvider = Provider<CarApiService>((ref) => CarApiService());

const popularCarBrands = [
  '212',
  'Abarth', 'Acura', 'AION', 'Aito', 'Alfa Romeo', 'Arcfox', 'Aston Martin', 'Audi', 'Avatr',
  'BAIC', 'Bentley', 'Bestune', 'BMW', 'Borgward', 'Brilliance', 'Bugatti', 'BYD',
  'Cadillac', 'Caterham', 'Changan', 'Chery', 'Chevrolet', 'Chrysler', 'Citroen', 'CMC',
  'Daihatsu', 'Deepal', 'Denza', 'DFSK', 'Dodge', 'Dongfeng', 'Dorcen',
  'Exeed',
  'FAW', 'Ferrari', 'Fiat', 'Fisker', 'Ford', 'Forthing', 'Foton',
  'GAC', 'Geely', 'Genesis', 'GMC', 'Great Wall',
  'Haval', 'Honda', 'Hongqi', 'Hummer', 'Hyptec', 'Hyundai',
  'iCaur', 'IM Motors', 'Ineos', 'Infiniti', 'International', 'Isuzu',
  'JAC', 'Jaecoo', 'Jaguar', 'Jeep', 'Jetour',
  'Kaiyi', 'Kia', 'King Long', 'Koenigsegg', 'KTM',
  'Lamborghini', 'Land Rover', 'Leapmotor', 'Lepas', 'Lexus', 'Li Auto', 'Lincoln', 'Livan', 'Lotus', 'LS Auto', 'Lucid', 'Luxgen', 'Lynk and Co',
  'Mahindra', 'Maserati', 'Maxus', 'Maybach', 'Mazda', 'McLaren', 'Mercedes-Benz', 'Mercury', 'MG', 'MHERO', 'MINI', 'Mitsubishi', 'Morgan',
  'Nio', 'Nissan', 'Noble',
  'Omoda', 'Opel', 'Oullim',
  'Pagani', 'Peugeot', 'PGO', 'Polestar', 'Porsche', 'Proton',
  'Rabdan', 'Ram', 'Rely', 'Renault', 'ROEWE', 'Rolls Royce', 'ROX',
  'Saab', 'Seat', 'Seres', 'Škoda', 'Skywell', 'Smart', 'Soueast', 'Spyker', 'Ssangyong', 'Subaru', 'Suzuki',
  'Tank', 'Tata', 'Tesla', 'Toyota',
  'VGV', 'VinFast', 'Volkswagen', 'Volvo', 'Voyah',
  'WEY',
  'Xpeng',
  'Yangwang',
  'Zeekr', 'ZNA', 'Zotye',
];

// Brand → official domain for Clearbit logo API
const _brandDomains = <String, String>{
  'Abarth': 'abarth.com',
  'Acura': 'acura.com',
  'Alfa Romeo': 'alfaromeo.com',
  'Aston Martin': 'astonmartin.com',
  'Audi': 'audi.com',
  'BAIC': 'baic.com.cn',
  'Bentley': 'bentley.com',
  'BMW': 'bmw.com',
  'Bugatti': 'bugatti.com',
  'BYD': 'byd.com',
  'Cadillac': 'cadillac.com',
  'Caterham': 'caterham.com',
  'Changan': 'changan.com.cn',
  'Chery': 'chery.com',
  'Chevrolet': 'chevrolet.com',
  'Chrysler': 'chrysler.com',
  'Citroen': 'citroen.com',
  'Daihatsu': 'daihatsu.co.jp',
  'Dodge': 'dodge.com',
  'Dongfeng': 'dfmc.com.cn',
  'FAW': 'faw.com',
  'Ferrari': 'ferrari.com',
  'Fiat': 'fiat.com',
  'Fisker': 'fiskerinc.com',
  'Ford': 'ford.com',
  'Foton': 'foton.com',
  'GAC': 'gac.com',
  'Geely': 'geely.com',
  'Genesis': 'genesis.com',
  'GMC': 'gmc.com',
  'Great Wall': 'gwm.com',
  'Haval': 'haval.com',
  'Honda': 'honda.com',
  'Hummer': 'hummer.com',
  'Hyundai': 'hyundai.com',
  'Infiniti': 'infiniti.com',
  'Ineos': 'ineosgrenadier.com',
  'Isuzu': 'isuzu.com',
  'JAC': 'jac.com.cn',
  'Jaguar': 'jaguar.com',
  'Jeep': 'jeep.com',
  'Kia': 'kia.com',
  'Koenigsegg': 'koenigsegg.com',
  'KTM': 'ktm.com',
  'Lamborghini': 'lamborghini.com',
  'Land Rover': 'landrover.com',
  'Lexus': 'lexus.com',
  'Li Auto': 'lixiang.com',
  'Lincoln': 'lincoln.com',
  'Lotus': 'lotuscars.com',
  'Lucid': 'lucidmotors.com',
  'Mahindra': 'mahindra.com',
  'Maserati': 'maserati.com',
  'Maxus': 'maxus.com',
  'Maybach': 'mercedes-benz.com',
  'Mazda': 'mazda.com',
  'McLaren': 'mclaren.com',
  'Mercedes-Benz': 'mercedes-benz.com',
  'MG': 'mg.com',
  'MINI': 'mini.com',
  'Mitsubishi': 'mitsubishi-motors.com',
  'Morgan': 'morgan-motor.co.uk',
  'Nio': 'nio.com',
  'Nissan': 'nissan-global.com',
  'Opel': 'opel.com',
  'Pagani': 'pagani.com',
  'Peugeot': 'peugeot.com',
  'Polestar': 'polestar.com',
  'Porsche': 'porsche.com',
  'Proton': 'proton.com',
  'Ram': 'ramtrucks.com',
  'Renault': 'renault.com',
  'Rolls Royce': 'rolls-roycemotorcars.com',
  'Saab': 'saab.com',
  'Seat': 'seat.com',
  'Škoda': 'skoda-auto.com',
  'Smart': 'smart.com',
  'Ssangyong': 'ssangyong.com',
  'Subaru': 'subaru.com',
  'Suzuki': 'suzuki.com',
  'Tank': 'gwm.com',
  'Tata': 'tatamotors.com',
  'Tesla': 'tesla.com',
  'Toyota': 'toyota.com',
  'VinFast': 'vinfast.com',
  'Volkswagen': 'volkswagen.com',
  'Volvo': 'volvocars.com',
  'Xpeng': 'xiaopeng.com',
  'Zeekr': 'zeekr.com',
};

String? brandLogoUrl(String brand) {
  final domain = _brandDomains[brand];
  if (domain == null) return null;
  return 'https://www.google.com/s2/favicons?sz=128&domain=$domain';
}

class BrandLogo extends StatelessWidget {
  final String brand;
  final double size;

  const BrandLogo({super.key, required this.brand, this.size = 32});

  @override
  Widget build(BuildContext context) {
    final url = brandLogoUrl(brand);
    if (url == null) {
      return Icon(Icons.directions_car_outlined, size: size, color: Colors.grey);
    }
    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.contain,
      loadingBuilder: (_, child, progress) =>
          progress == null ? child : SizedBox(width: size, height: size),
      errorBuilder: (_, __, ___) =>
          Icon(Icons.directions_car_outlined, size: size, color: Colors.grey),
    );
  }
}

final carMakesProvider = Provider<List<String>>((ref) => popularCarBrands);

final carModelsProvider = FutureProvider.family<List<String>, String>((ref, make) {
  if (make.isEmpty) return Future.value([]);
  return ref.read(carApiServiceProvider).getModels(make);
});

class CarApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://vpic.nhtsa.dot.gov/api/vehicles',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<List<String>> getModels(String make) async {
    final response = await _dio.get(
      '/getmodelsformake/${Uri.encodeComponent(make)}',
      queryParameters: {'format': 'json'},
    );
    final results = response.data['Results'] as List;
    return results
        .map((e) => (e['Model_Name'] as String).trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }
}
