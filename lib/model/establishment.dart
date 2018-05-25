class Establishment {

  String _address;
  String get address => _address;
  set address(String address) {
    _address = address;
  }

  String _country;
  String get country => _country;
  set country(String country) {
    _country = country;
  }

  String _description;
  String get description => _description;
  set description(String description) {
    _description = description;
  }

  String _productCategory;
  String get productCategory => _productCategory;
  set productCategory(String productCategory) {
    _productCategory = productCategory;
  }

  double _latitude;
  double get latitude => _latitude;
  set latitude(double latitude) {
    _latitude = latitude;
  }

  double _longitude;
  double get longitude => _longitude;
  set longitude(double longitude) {
    _longitude = longitude;
  }

  String _name;
  String get name => _name;
  set name(String name) {
    _name = name;
  }

  String _proprietor; // hold email address of the user who is the proprietor
  String get proprietor => _proprietor;
  set proprietor(String proprietor) {
    _proprietor = proprietor;
  } 

}